"""Offline, memory-only trips.txt nomination. No source/identity authentication.

Run with Python 3.9+ and -B. The CLI prints only a count; private results are
available through read_nominations(), never serialized or logged by this module.
"""

import argparse
from contextlib import contextmanager
from dataclasses import dataclass
from enum import Enum
import hashlib
import os
import re
import stat
import struct
import sys
import zipfile
import zlib


MAX_ARCHIVE_BYTES = 16 * 1024 * 1024
MAX_DIRECTORY_BYTES = 1024 * 1024
MAX_MEMBERS = 1024
MAX_TRIPS_BYTES = 2 * 1024 * 1024
MAX_RECORD_BYTES = 256 * 1024
MAX_FIELD_BYTES = 64 * 1024
MAX_COLUMNS = 64
MAX_DATA_RECORDS = 100_000
MAX_CHOICES = 10
CHUNK_BYTES = 64 * 1024


class Code(Enum):
    INVALID_ARGUMENTS = "invalidArguments"
    UNSAFE_PATH = "unsafePath"
    INPUT_UNAVAILABLE = "inputUnavailable"
    NOT_REGULAR = "notRegularFile"
    ARCHIVE_IDENTITY = "archiveIdentityMismatch"
    INPUT_CHANGED = "inputChanged"
    INVALID_ARCHIVE = "invalidArchive"
    INVALID_MEMBERS = "invalidMembers"
    UNSUPPORTED_ZIP = "unsupportedZip"
    RESOURCE_LIMIT = "resourceLimit"
    MEMBER_INTEGRITY = "memberIntegrityMismatch"
    MALFORMED_CSV = "malformedCSV"


class NominationError(Exception):
    """A finite code only: never embed paths, provider text or library errors."""

    def __init__(self, code):
        self.code = code
        super().__init__(code.value)


@dataclass(frozen=True, repr=False)
class Locator:
    archive_sha256: str
    member_name: str
    member_sha256: str
    data_record_ordinal: int
    byte_start: int
    byte_end: int
    record_sha256: str


@dataclass(frozen=True, repr=False)
class Nomination:
    label: str
    values: tuple
    locator: Locator


@dataclass(frozen=True, repr=False)
class NominationBatch:
    columns: tuple
    nominations: tuple


@contextmanager
def _parent(path):
    # Descriptor-relative traversal prevents ancestor symlink races; no resolve(),
    # directory listing, search, or opening a second archive pathname.
    if not isinstance(path, str) or not path.startswith("/") or "\x00" in path:
        raise NominationError(Code.UNSAFE_PATH)
    parts = path.split("/")[1:]
    if not parts or any(p in ("", ".", "..") for p in parts):
        raise NominationError(Code.UNSAFE_PATH)
    fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in parts[:-1]:
            new_fd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd)
            fd = new_fd
        yield fd, parts[-1]
    finally:
        os.close(fd)


def _state(s):
    return s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns, s.st_ctime_ns, s.st_mode


def _hash_archive(file, size):
    file.seek(0)
    digest = hashlib.sha256()
    remaining = size
    while remaining:
        chunk = file.read(min(CHUNK_BYTES, remaining))
        if not chunk:
            raise NominationError(Code.INPUT_CHANGED)
        digest.update(chunk)
        remaining -= len(chunk)
    if file.read(1):
        raise NominationError(Code.INPUT_CHANGED)
    return digest.hexdigest()


def _directory(file, size):
    # Bound the central directory BEFORE zipfile allocates ZipInfo objects.
    # This is the ordinary single-disk ZIP envelope, without ZIP64 records.
    file.seek(max(0, size - 65557))
    tail = file.read(65557)
    candidates = []
    offset = tail.find(b"PK\x05\x06")
    while offset >= 0:
        if offset + 22 <= len(tail):
            fields = struct.unpack_from("<4s4H2IH", tail, offset)
            if offset + 22 + fields[-1] == len(tail):
                candidates.append((offset, fields))
        offset = tail.find(b"PK\x05\x06", offset + 1)
    if len(candidates) != 1:
        raise NominationError(Code.INVALID_ARCHIVE)
    offset, (_, disk, cd_disk, on_disk, total, cd_size, cd_start, _) = candidates[0]
    eocd_start = max(0, size - 65557) + offset
    if disk or cd_disk or on_disk != total or total == 65535 or cd_start == 0xFFFFFFFF:
        raise NominationError(Code.UNSUPPORTED_ZIP)
    if total > MAX_MEMBERS or cd_size > MAX_DIRECTORY_BYTES:
        raise NominationError(Code.RESOURCE_LIMIT)
    if cd_start + cd_size != eocd_start:
        raise NominationError(Code.INVALID_ARCHIVE)
    file.seek(cd_start)
    directory = file.read(cd_size)
    position = 0
    count = 0
    while position < len(directory):
        if position + 46 > len(directory) or directory[position:position + 4] != b"PK\x01\x02":
            raise NominationError(Code.INVALID_ARCHIVE)
        name_length, extra_length, comment_length = struct.unpack_from("<3H", directory, position + 28)
        position += 46 + name_length + extra_length + comment_length
        count += 1
        if count > MAX_MEMBERS:
            raise NominationError(Code.RESOURCE_LIMIT)
    if position != len(directory) or count != total:
        raise NominationError(Code.INVALID_ARCHIVE)
    with zipfile.ZipFile(file, "r") as archive:
        infos = archive.infolist()  # Only directory metadata; never ZipFile.open().
    if len(infos) != total:
        raise NominationError(Code.INVALID_ARCHIVE)
    seen = set()
    offsets = set()
    for info in infos:
        # Reuse the existing intake's root-level ASCII member-name policy.
        name = info.orig_filename
        if (len(name) > 255 or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", name)
                or name != info.filename or name in seen):
            raise NominationError(Code.INVALID_MEMBERS)
        kind = stat.S_IFMT(info.external_attr >> 16)
        if kind not in (0, stat.S_IFREG) or info.volume != 0:
            raise NominationError(Code.INVALID_MEMBERS)
        if not 0 <= info.header_offset < cd_start or info.header_offset in offsets:
            raise NominationError(Code.INVALID_ARCHIVE)
        seen.add(name)
        offsets.add(info.header_offset)
    selected = [i for i in infos if i.filename == "trips.txt"]
    if len(selected) != 1:
        raise NominationError(Code.INVALID_MEMBERS)
    info = selected[0]
    boundary = min([o for o in offsets if o > info.header_offset] + [cd_start])
    return info, boundary


def _read_trips(file, info, boundary):
    # Decode only this member. Explicit zlib accounting avoids relying on
    # ZipExtFile's declared-size truncation to establish decompressed length.
    if info.flag_bits & ~0x080E or info.compress_type not in (0, 8) or info.extract_version > 20:
        raise NominationError(Code.UNSUPPORTED_ZIP)
    if info.file_size > MAX_TRIPS_BYTES or info.compress_size > MAX_ARCHIVE_BYTES:
        raise NominationError(Code.RESOURCE_LIMIT)
    file.seek(info.header_offset)
    header = file.read(30)
    if len(header) != 30:
        raise NominationError(Code.INVALID_ARCHIVE)
    signature, version, flags, method, _, _, crc, compressed, expanded, nlen, xlen = struct.unpack(
        "<4s5H3I2H", header)
    if (signature != b"PK\x03\x04" or flags != info.flag_bits or method != info.compress_type
            or version > 20 or nlen != len(b"trips.txt")):
        raise NominationError(Code.INVALID_ARCHIVE)
    end = info.header_offset + 30 + nlen + xlen + info.compress_size
    if end > boundary:
        raise NominationError(Code.INVALID_ARCHIVE)
    if file.read(nlen) != b"trips.txt":
        raise NominationError(Code.INVALID_MEMBERS)
    extra = file.read(xlen)
    pos = 0
    while pos < len(extra):
        if pos + 4 > len(extra):
            raise NominationError(Code.INVALID_ARCHIVE)
        tag, length = struct.unpack_from("<HH", extra, pos)
        if tag == 1:
            raise NominationError(Code.UNSUPPORTED_ZIP)
        pos += 4 + length
    if pos != len(extra):
        raise NominationError(Code.INVALID_ARCHIVE)
    if not flags & 8 and (crc, compressed, expanded) != (info.CRC, info.compress_size, info.file_size):
        raise NominationError(Code.MEMBER_INTEGRITY)
    if flags & 8 and any(local not in (0, central) for local, central in
                         zip((crc, compressed, expanded), (info.CRC, info.compress_size, info.file_size))):
        raise NominationError(Code.MEMBER_INTEGRITY)
    data = bytearray()
    remaining = info.compress_size
    decoder = zlib.decompressobj(-15) if method == 8 else None
    while remaining:
        chunk = file.read(min(CHUNK_BYTES, remaining))
        if not chunk:
            raise NominationError(Code.MEMBER_INTEGRITY)
        remaining -= len(chunk)
        if decoder is not None:
            chunk = decoder.decompress(chunk, MAX_TRIPS_BYTES + 1 - len(data))
        data.extend(chunk)
        if len(data) > MAX_TRIPS_BYTES or (decoder is not None and decoder.unconsumed_tail):
            raise NominationError(Code.RESOURCE_LIMIT)
        if decoder is not None and decoder.unused_data:
            raise NominationError(Code.MEMBER_INTEGRITY)
    if decoder is not None and not decoder.eof:
        raise NominationError(Code.MEMBER_INTEGRITY)
    if len(data) != info.file_size or zlib.crc32(data) & 0xFFFFFFFF != info.CRC:
        raise NominationError(Code.MEMBER_INTEGRITY)
    if flags & 8:
        # Optional signature followed by CRC, compressed size, expanded size.
        if end + 12 > boundary:
            raise NominationError(Code.INVALID_ARCHIVE)
        descriptor = file.read(4)
        if descriptor == b"PK\x07\x08":
            if end + 16 > boundary:
                raise NominationError(Code.INVALID_ARCHIVE)
            descriptor = file.read(4)
        descriptor += file.read(8)
        if struct.unpack("<III", descriptor) != (info.CRC, info.compress_size, info.file_size):
            raise NominationError(Code.MEMBER_INTEGRITY)
    return bytes(data)


def _records(data):
    """Strict UTF-8 CSV with byte spans, LF/CRLF and optional initial BOM.

    Spans are [start, end), include the entire record terminator (if present),
    include quotes/escapes, and exclude the previous terminator and initial BOM.
    Embedded CR/LF inside quotes belongs to that record and is preserved.
    """
    index = 3 if data.startswith(b"\xef\xbb\xbf") else 0
    while index < len(data):
        start = index
        fields = []
        done = False
        while not done:
            field_start = index
            value = bytearray()
            quoted = index < len(data) and data[index] == 34
            closed = False
            if quoted:
                index += 1
            while index < len(data):
                if index - field_start > MAX_FIELD_BYTES or index - start > MAX_RECORD_BYTES:
                    raise NominationError(Code.RESOURCE_LIMIT)
                byte = data[index]
                if byte == 0:
                    raise NominationError(Code.MALFORMED_CSV)
                if quoted and not closed:
                    if byte == 34:
                        if index + 1 < len(data) and data[index + 1] == 34:
                            value.append(34)
                            index += 2
                            continue
                        closed = True
                    else:
                        value.append(byte)
                    index += 1
                    continue
                if byte in (44, 10, 13):
                    break
                if closed or byte == 34:
                    raise NominationError(Code.MALFORMED_CSV)
                value.append(byte)
                index += 1
            if quoted and not closed:
                raise NominationError(Code.MALFORMED_CSV)
            if index - field_start > MAX_FIELD_BYTES:
                raise NominationError(Code.RESOURCE_LIMIT)
            try:
                fields.append(value.decode("utf-8", errors="strict"))
            except UnicodeError:
                raise NominationError(Code.MALFORMED_CSV) from None
            if len(fields) > MAX_COLUMNS:
                raise NominationError(Code.RESOURCE_LIMIT)
            if index == len(data):
                done = True
            elif data[index] == 44:
                index += 1
            else:
                if data[index] == 13:
                    if data[index:index + 2] != b"\r\n":
                        raise NominationError(Code.MALFORMED_CSV)
                    index += 2
                else:
                    index += 1
                done = True
            if index - start > MAX_RECORD_BYTES:
                raise NominationError(Code.RESOURCE_LIMIT)
        yield tuple(fields), start, index


def _nominate(data, archive_digest):
    records = _records(data)
    first = next(records, None)
    if first is None:
        raise NominationError(Code.MALFORMED_CSV)
    columns = first[0]
    required = ("trip_id", "route_id", "service_id")
    if (any(not c for c in columns) or len(set(columns)) != len(columns)
            or any(c not in columns for c in required)):
        raise NominationError(Code.MALFORMED_CSV)
    required_indices = tuple(columns.index(c) for c in required)
    digest = hashlib.sha256(data).hexdigest()
    choices = []
    # Validate the entire bounded table; a malformed later row cannot be hidden
    # by the display cap. Repeated source identifiers are NOT deduplicated.
    for ordinal, (values, start, end) in enumerate(records):
        if ordinal >= MAX_DATA_RECORDS:
            raise NominationError(Code.RESOURCE_LIMIT)
        if len(values) != len(columns) or any(not values[i] for i in required_indices):
            raise NominationError(Code.MALFORMED_CSV)
        if ordinal < MAX_CHOICES:
            choices.append(Nomination(
                "N%02d" % (ordinal + 1), values,
                Locator(archive_digest, "trips.txt", digest, ordinal, start, end,
                        hashlib.sha256(data[start:end]).hexdigest())))
    return NominationBatch(columns, tuple(choices))


def read_nominations(path, expected_size, expected_sha256):
    """Return an immutable private batch only after every check passes.

    Caller must keep fields/locators in local memory; no serialization, logging,
    real-use authorization or durable identity is supplied by this API.
    """
    if (type(expected_size) is not int or not 0 < expected_size <= MAX_ARCHIVE_BYTES
            or not isinstance(expected_sha256, str)
            or not re.fullmatch(r"[0-9a-f]{64}", expected_sha256)):
        raise NominationError(Code.INVALID_ARGUMENTS)
    try:
        with _parent(path) as (parent, name):
            prior = os.stat(name, dir_fd=parent, follow_symlinks=False)
            if stat.S_ISLNK(prior.st_mode):
                raise NominationError(Code.UNSAFE_PATH)
            if not stat.S_ISREG(prior.st_mode):
                raise NominationError(Code.NOT_REGULAR)
            fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
        # No BufferedReader cache: the final digest must reread descriptor bytes,
        # not cached pre-mutation data from a previous seek/read.
        with os.fdopen(fd, "rb", buffering=0) as file:
            initial = os.fstat(file.fileno())
            if not stat.S_ISREG(initial.st_mode) or _state(initial) != _state(prior):
                raise NominationError(Code.INPUT_CHANGED)
            if initial.st_size != expected_size or _hash_archive(file, expected_size) != expected_sha256:
                raise NominationError(Code.ARCHIVE_IDENTITY)
            info, boundary = _directory(file, expected_size)
            data = _read_trips(file, info, boundary)
            result = _nominate(data, expected_sha256)
            if _hash_archive(file, expected_size) != expected_sha256 or _state(os.fstat(file.fileno())) != _state(initial):
                raise NominationError(Code.INPUT_CHANGED)
            with _parent(path) as (parent, name):
                current = os.stat(name, dir_fd=parent, follow_symlinks=False)
                if _state(current) != _state(initial):
                    raise NominationError(Code.INPUT_CHANGED)
            return result
    except NominationError:
        raise
    except UnicodeError:
        raise NominationError(Code.INVALID_ARCHIVE) from None
    except (zipfile.BadZipFile, struct.error, zlib.error, EOFError, NotImplementedError):
        raise NominationError(Code.INVALID_ARCHIVE) from None
    except OSError:
        # Includes inaccessible paths, symlink races, non-directory ancestors.
        raise NominationError(Code.INPUT_UNAVAILABLE) from None


class _Arguments(argparse.ArgumentParser):
    def error(self, message):
        raise NominationError(Code.INVALID_ARGUMENTS)


def main(argv=None):
    parser = _Arguments(description="Offline trips-only nomination; count-only output.")
    parser.add_argument("--archive", required=True)
    parser.add_argument("--expected-size", required=True, type=int)
    parser.add_argument("--expected-sha256", required=True)
    try:
        args = parser.parse_args(argv)
        result = read_nominations(args.archive, args.expected_size, args.expected_sha256)
        print("nomination records available: %d; private values not printed" % len(result.nominations))
        return 0
    except NominationError as error:
        print("nomination failed: " + error.code.value, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
