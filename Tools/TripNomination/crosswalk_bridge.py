"""Synthetic-verified same-process bridge. Real use needs fresh occurrence authorization."""
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import struct
import sys

import nomination as n
from occurrences import read_occurrences
from session import _Arguments, _Terminal, SessionError

ABI_VERSION = 2
MAX_KEY_BYTES = 4096
MAX_FRAME_BYTES = 8 + 64 * (4 + MAX_KEY_BYTES)
PROFILE = "toei-20260921-passenger-00"
FIELDS = ("requestedMappingCount", "resolvedMappingCount", "heldMappingCount", "repeatedOccurrenceCount",
          "registryIdentityMatched", "reviewEvidenceMatched", "memberIdentityConsistent", "readyForPrivateCrosswalk")


class BridgeError(Exception):
    """Only fixed codes supplied by this module; never wrap private error text."""


def encode_keys(values):
    if not 1 <= len(values) <= 64:
        raise BridgeError("invalidKeyFrame")
    frame = bytearray(struct.pack(">II", ABI_VERSION, len(values)))
    try:
        for value in values:
            raw = value.encode("utf-8", errors="strict")
            if not 1 <= len(raw) <= MAX_KEY_BYTES:
                raise BridgeError("invalidKeyFrame")
            frame.extend(struct.pack(">I", len(raw)))
            frame.extend(raw)
        return frame
    except (UnicodeError, AttributeError):
        frame[:] = b"\0" * len(frame)
        raise BridgeError("invalidKeyFrame") from None
    except BaseException:
        frame[:] = b"\0" * len(frame)
        raise


class Library:
    """Hash-pin and load the held file descriptor, not a re-openable path."""
    def __init__(self, path, expected_sha256):
        known = Path(__file__).resolve().parents[1] / "StaticDataIntake/.build/libtsugino-crosswalk.dylib"
        if path != str(known) or not re.fullmatch(r"[0-9a-f]{64}", expected_sha256):
            raise BridgeError("invalidLibrary")
        self.fd = None
        try:
            with n._parent(path) as (parent, name):
                fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
            self.fd = fd
            before = os.fstat(fd)
            if not stat.S_ISREG(before.st_mode) or not 0 < before.st_size <= 64 * 1024 * 1024:
                raise BridgeError("invalidLibrary")
            digest = hashlib.sha256()
            offset = 0
            while offset < before.st_size:
                data = os.pread(fd, min(1024*1024, before.st_size-offset), offset)
                if not data:
                    raise BridgeError("invalidLibrary")
                digest.update(data); offset += len(data)
            if digest.hexdigest() != expected_sha256 or n._state(os.fstat(fd)) != n._state(before):
                raise BridgeError("libraryIdentityMismatch")
            self.lib = ctypes.CDLL("/dev/fd/%d" % fd)
            version = self.lib.tsugino_crosswalk_abi_version
            version.argtypes = []; version.restype = ctypes.c_uint32
            if version() != ABI_VERSION:
                raise BridgeError("unsupportedABI")
            self.call = self.lib.tsugino_crosswalk_review_v2
            self.call.argtypes = [ctypes.POINTER(ctypes.c_ubyte), ctypes.c_uint64,
                                  ctypes.POINTER(ctypes.c_ubyte), ctypes.c_uint64,
                                  ctypes.POINTER(ctypes.c_uint64), ctypes.c_uint64]
            self.call.restype = ctypes.c_int32
            if n._state(os.fstat(fd)) != n._state(before):
                raise BridgeError("libraryChanged")
        except BridgeError:
            self.close(); raise
        except Exception:
            self.close(); raise BridgeError("invalidLibrary") from None

    def close(self):
        if self.fd is not None:
            os.close(self.fd); self.fd = None

    def verify(self, configuration, frame):
        config = json.dumps(configuration, ensure_ascii=True, separators=(",", ":")).encode("ascii")
        if not 1 <= len(config) <= 65536 or not 8 <= len(frame) <= MAX_FRAME_BYTES:
            raise BridgeError("invalidArguments")
        cbuf = (ctypes.c_ubyte * len(config)).from_buffer_copy(config)
        kbuf = (ctypes.c_ubyte * len(frame)).from_buffer(frame)
        output = (ctypes.c_uint64 * 8)()
        try:
            status = self.call(cbuf, len(config), kbuf, len(frame), output, 8)
            if status not in (0, 1):
                raise BridgeError({2:"invalidBridgeInput",3:"artifactIdentityMismatch",4:"invalidMappingArtifacts",5:"unsafeOrChangedInput"}.get(status,"invalidBridgeResult"))
            result = dict(zip(FIELDS, map(int, output)))
            for name in (FIELDS[4], FIELDS[7]):
                if result[name] not in (0, 1):
                    raise BridgeError("invalidBridgeResult")
                result[name] = bool(result[name])
            for name in FIELDS[5:7]:
                if result[name] not in (0, 1, 2):
                    raise BridgeError("invalidBridgeResult")
                result[name] = ("notEvaluated", "matched", "mismatched")[result[name]]
            count = configuration["expectedCount"]
            if (result[FIELDS[0]] != count or result[FIELDS[1]] + result[FIELDS[2]] != count
                    or result[FIELDS[3]] >= count or result[FIELDS[7]] != (status == 0)
                    or not result[FIELDS[4]]
                    or (status == 0 and (result[FIELDS[2]] != 0 or any(result[x] != "matched" for x in FIELDS[5:7])))):
                raise BridgeError("invalidBridgeResult")
            return result
        finally:
            ctypes.memset(cbuf, 0, len(config))
            ctypes.memset(output, 0, ctypes.sizeof(output))
            # kbuf aliases caller's mutable memory, no opaque Swift lifetime crosses ABI.


def run(archive, expected_size, expected_sha256, label, expected_count, expected_inversions,
        profile, configuration, library):
    if (expected_count != 14 or expected_inversions != 0 or profile != PROFILE
            or configuration.get("expectedCount") != expected_count
            or configuration.get("inputSHA256") != expected_sha256
            or configuration.get("namespace") != "gtfs.stop_id"):
        raise BridgeError("invalidExpectations")
    required = {"registryPath", "reviewsPath", "registrySHA256", "reviewsSHA256", "registryRevision", "sourceID", "inputSHA256", "namespace", "expectedCount"}
    if (set(configuration) != required or type(configuration["registryRevision"]) is not int
            or configuration["registryRevision"] < 0
            or any(not isinstance(configuration[k], str) or not re.fullmatch(r"[0-9a-f]{64}", configuration[k])
                   for k in ("registrySHA256", "reviewsSHA256", "inputSHA256"))
            or any(not isinstance(configuration[k], str) or not configuration[k].startswith("/") or "\0" in configuration[k]
                   for k in ("registryPath", "reviewsPath"))
            or not isinstance(configuration["sourceID"], str) or not re.fullmatch(r"[!-~]+", configuration["sourceID"])):
        raise BridgeError("invalidArguments")
    batch = None
    frame = None
    try:
        batch = read_occurrences(archive, expected_size, expected_sha256, label)  # exactly once, no retry
        if (batch.source.label != label or batch.source.locator.archive_sha256 != expected_sha256
                or len(batch.occurrences) != expected_count
                or batch.transport_order_inversions != expected_inversions):
            raise BridgeError("unexpectedOccurrences")
        if any(x.pickup_type != "0" or x.drop_off_type != "0" for x in batch.occurrences):
            raise BridgeError("passengerProfileMismatch")
        frame = encode_keys([x.stop_id for x in batch.occurrences])
        result = library.verify(configuration, frame)
        result.update(occurrenceCount=expected_count, passengerProfileMatchedCount=expected_count,
                      sourceOrderPreserved=True)
        return result
    except n.NominationError:
        raise BridgeError("occurrenceReadFailed") from None
    finally:
        if frame is not None:
            frame[:] = b"\0" * len(frame)
        batch = None  # Reference disposal is not secure memory erasure.


def main(argv=None):
    parser = _Arguments(description="Memory-only crosswalk review; real use separately gated.", allow_abbrev=False)
    for flag in ("archive","expected-sha256","label","profile","library","library-sha256",
                 "registry","registry-sha256","reviews","reviews-sha256","source","input-sha256","namespace"):
        parser.add_argument("--"+flag, required=True)
    for flag in ("expected-size","expected-count","expected-inversions","registry-revision"):
        parser.add_argument("--"+flag, type=int, required=True)
    library = None
    try:
        a = parser.parse_args(argv)
        config = dict(registryPath=a.registry, reviewsPath=a.reviews, registrySHA256=a.registry_sha256,
                      reviewsSHA256=a.reviews_sha256, registryRevision=a.registry_revision, sourceID=a.source,
                      inputSHA256=a.input_sha256, namespace=a.namespace, expectedCount=a.expected_count)
        with _Terminal() as terminal:
            library = Library(a.library, a.library_sha256)
            result = run(a.archive,a.expected_size,a.expected_sha256,a.label,a.expected_count,a.expected_inversions,a.profile,config,library)
            terminal.write(json.dumps(result, sort_keys=True)+"\n")
            return 0 if result["readyForPrivateCrosswalk"] else 1
    except BridgeError as e:
        print("crosswalk bridge failed: "+str(e), file=sys.stderr)
    except SessionError:
        print("crosswalk bridge failed: localTerminalRequired", file=sys.stderr)
    except KeyboardInterrupt:
        print("crosswalk bridge failed: cancelled", file=sys.stderr)
        return 130
    except Exception:
        print("crosswalk bridge failed: internalError", file=sys.stderr)
    finally:
        if library is not None:
            library.close()
    return 1


if __name__ == "__main__":
    sys.exit(main())
