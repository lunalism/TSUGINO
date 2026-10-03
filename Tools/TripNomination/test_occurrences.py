"""Invented inputs only. No real archive paths, keys, or railway claims."""

import contextlib
import dataclasses
import hashlib
import io
import os
from pathlib import Path
import stat
import struct
import subprocess
import sys
import tempfile
import unittest
from unittest import mock
import warnings
import zipfile
import zlib

import nomination as n
import occurrences as o
from test_nomination import HEADER, TABLE, zip_bytes


STOP_HEADER = b"trip_id,stop_id,stop_sequence\n"
STOPS = STOP_HEADER + b"t,a,1\nt,b,9\n"


def package(stops=STOPS, trips=TABLE, others=(), compression=zipfile.ZIP_DEFLATED):
    return zip_bytes(trips, (("stop_times.txt", stops),) + others, compression)


def raw_package(data=STOPS, method=8, descriptor=False, declared=None, payload=None):
    """Independent ZIP bytes, including dishonest sizes and malformed streams."""
    body, central = bytearray(), bytearray()
    for name, content in ((b"trips.txt", TABLE), (b"stop_times.txt", data)):
        flags = 8 if descriptor else 0
        crc = zlib.crc32(content) & 0xFFFFFFFF
        size = declared if name == b"stop_times.txt" and declared is not None else len(content)
        encoder = zlib.compressobj(wbits=-15)
        compressed = encoder.compress(content) + encoder.flush() if method == 8 else content
        if name == b"stop_times.txt" and payload is not None:
            compressed = payload
        offset = len(body)
        local_values = (0, 0, 0) if descriptor else (crc, len(compressed), size)
        body += struct.pack("<4s5H3I2H", b"PK\x03\x04", 20, flags, method, 0, 0,
                            *local_values, len(name), 0) + name + compressed
        if descriptor:
            body += struct.pack("<4sIII", b"PK\x07\x08", crc, len(compressed), size)
        central += struct.pack("<4s6H3I5H2I", b"PK\x01\x02", 20, 20, flags, method, 0, 0,
                               crc, len(compressed), size, len(name), 0, 0, 0, 0, 0, offset) + name
    return bytes(body + central + struct.pack("<4s4H2IH", b"PK\x05\x06", 0, 0, 2, 2,
                                               len(central), len(body), 0))


class OccurrenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.path = self.root / "invented.zip"

    def install(self, data):
        self.path.write_bytes(data)
        return str(self.path), len(data), hashlib.sha256(data).hexdigest()

    def read(self, stops=STOPS, trips=TABLE, label="N01"):
        return o.read_occurrences(*self.install(package(stops, trips)), label)

    def fails(self, code, raw, label="N01"):
        with self.assertRaises(n.NominationError) as error:
            o.read_occurrences(*self.install(raw), label)
        self.assertEqual(error.exception.code, code)
        self.assertEqual(str(error.exception), code.value)

    def test_interleaving_repeated_visits_and_original_ordinals(self):
        rows = [b"u,x,1\n", b"t,a,2\n", b"v,x,2\n", b"t,b,7\n", b"t,a,10\n", b"v,y,3\n"]
        result = self.read(STOP_HEADER + b"".join(rows))
        self.assertEqual([x.stop_id for x in result.occurrences], ["a", "b", "a"])
        self.assertEqual([x.stop_sequence for x in result.occurrences], ["2", "7", "10"])
        self.assertEqual([x.locator.data_record_ordinal for x in result.occurrences], [1, 3, 4])
        self.assertEqual(result.stop_times_record_count, 6)
        self.assertEqual(result.outcome, o.Outcome.OCCURRENCES)
        self.assertEqual(result.transport_order_inversions, 0)

    def test_all_labels_bind_original_nomination_and_only_associations(self):
        trips = HEADER[:-1] + b",trip_headsign\n" + b"".join(
            ("key%d,route%d,service%d,DO_NOT_EXPOSE\n" % (i, i, i)).encode() for i in range(11))
        args = self.install(package(STOP_HEADER, trips))
        nominations = n.read_nominations(*args)
        for i, candidate in enumerate(nominations.nominations):
            with self.subTest(i=i):
                result = o.read_occurrences(*args, candidate.label)
                self.assertEqual(result.source.locator, candidate.locator)
                self.assertEqual((result.source.trip_id, result.source.route_id, result.source.service_id), candidate.values[:3])
                self.assertEqual([f.name for f in dataclasses.fields(result.source)],
                                 ["label", "trip_id", "route_id", "service_id", "locator"])

    def test_ambiguous_selected_key_anywhere_in_complete_trips(self):
        for last in (b"t,r,s\n", b"t,different,service\n"):
            trips = TABLE + b"".join(("u%d,r,s\n" % i).encode() for i in range(11)) + last
            self.fails(o.Code.AMBIGUOUS_JOIN, package(trips=trips))
        # Unrelated duplicates neither change the selected join nor get deduplicated by nomination.
        result = self.read(trips=TABLE + b"u,r,s\nu,r,s\n")
        self.assertEqual(len(result.occurrences), 2)

    def test_malformed_trips_after_nomination_is_atomic(self):
        self.fails(n.Code.MALFORMED_CSV, package(trips=TABLE + b'"unterminated'))

    def test_unavailable_and_invalid_labels_do_not_substitute(self):
        self.fails(o.Code.NOMINATION_UNAVAILABLE, package(), "N02")
        self.fails(o.Code.NOMINATION_UNAVAILABLE, package(trips=HEADER))
        for label in ("N00", "N11", "n01", "N01\n", "", None):
            with self.subTest(label=label):
                self.fails(n.Code.INVALID_ARGUMENTS, package(), label)

    def test_zero_matches_is_explicit_and_still_hashes_complete_member(self):
        for stops, count in ((STOP_HEADER, 0), (STOP_HEADER + b"u,a,1\n", 1)):
            result = self.read(stops)
            self.assertEqual(result.outcome, o.Outcome.ZERO_MATCHES)
            self.assertEqual(result.occurrences, ())
            self.assertEqual(result.stop_times_record_count, count)
            self.assertEqual(result.stop_times_sha256, hashlib.sha256(stops).hexdigest())

    def test_sequence_gaps_leading_zeroes_and_inversions_preserved(self):
        result = self.read(STOP_HEADER + b"t,a,010\nt,b,2\nt,a,000\nt,c,100\n")
        self.assertEqual([x.stop_sequence for x in result.occurrences], ["010", "2", "000", "100"])
        self.assertEqual(result.transport_order_inversions, 2)
        self.assertEqual([x.locator.data_record_ordinal for x in result.occurrences], [0, 1, 2, 3])

    def test_duplicate_sequence_numeric_equivalence_rejects(self):
        for pair in (("1", "1"), ("1", "001"), ("0", "000")):
            with self.subTest(pair=pair):
                self.fails(o.Code.DUPLICATE_SEQUENCE, package(STOP_HEADER +
                           ("t,a,%s\nu,x,2\nt,a,%s\n" % pair).encode()))

    def test_malformed_sequence_and_required_associations(self):
        for value in ("-1", "+1", "1.0", " 1", "1 ", "１", "1e2", "1\n2"):
            with self.subTest(value=value):
                self.fails(o.Code.MALFORMED_SEQUENCE, package(STOP_HEADER + ('t,a,"%s"\n' % value).encode()))
        for row in (b"t,a,\n", b",a,1\n", b"t,,1\n"):
            self.fails(n.Code.MALFORMED_CSV, package(STOP_HEADER + row))

    def test_very_long_decimal_has_no_integer_overflow_or_digit_limit(self):
        value = "9" * 5000
        result = self.read(STOP_HEADER + ("t,a,%s\nt,b,1\n" % value).encode())
        self.assertEqual(result.occurrences[0].stop_sequence, value)
        self.assertEqual(result.transport_order_inversions, 1)

    def test_exact_unicode_quotes_crlf_bom_spans_and_eof(self):
        header = b"\xef\xbb\xbf" + STOP_HEADER.rstrip(b"\n") + b"\r\n"
        rows = ['t,"é,\r\n東京",01\r\n'.encode(), 't,"e\u0301\"\"\n駅",8'.encode()]
        data = header + b"".join(rows)
        args = self.install(package(data))
        result = o.read_occurrences(*args, "N01")
        self.assertEqual([x.stop_id for x in result.occurrences], ['é,\r\n東京', 'e\u0301"\n駅'])
        offset = len(header)
        for i, (item, row) in enumerate(zip(result.occurrences, rows)):
            self.assertEqual(item.locator, n.Locator(args[2], "stop_times.txt", hashlib.sha256(data).hexdigest(),
                             i, offset, offset + len(row), hashlib.sha256(row).hexdigest()))
            self.assertEqual(data[item.locator.byte_start:item.locator.byte_end], row)
            offset += len(row)

    def test_uninterpretable_time_text_only_becomes_presence(self):
        header = STOP_HEADER[:-1] + b",arrival_time,departure_time,pickup_type,drop_off_type,timepoint,other\n"
        result = self.read(header + b't,a,1,"NOT A TIME\n\x1b[31m", ,,,?,SECRET\n' + b't,b,2,,gibberish,x,y,,SECRET\n')
        a, b = result.occurrences
        self.assertEqual((a.arrival_presence, a.departure_presence), (o.Presence.PRESENT, o.Presence.PRESENT))
        self.assertEqual((b.arrival_presence, b.departure_presence), (o.Presence.EMPTY, o.Presence.PRESENT))
        self.assertEqual((a.pickup_type, a.drop_off_type, a.timepoint), ("", "", "?"))
        self.assertEqual((b.pickup_type, b.drop_off_type, b.timepoint), ("x", "y", ""))
        self.assertEqual([f.name for f in dataclasses.fields(a)],
                         ["stop_id", "stop_sequence", "pickup_type", "drop_off_type", "timepoint",
                          "arrival_presence", "departure_presence", "locator"])
        missing = self.read().occurrences[0]
        self.assertEqual((missing.arrival_presence, missing.departure_presence),
                         (o.Presence.ABSENT_COLUMN, o.Presence.ABSENT_COLUMN))
        self.assertEqual((missing.pickup_type, missing.drop_off_type, missing.timepoint), (None, None, None))

    def test_complete_member_validation_including_after_last_match(self):
        for bad in (b'"unterminated', b'u,x,2,extra\n', b'\n', b'u,\xff,2\n', b'u,\x00,2\n', b'u,x,2\r'):
            with self.subTest(bad=bad):
                self.fails(n.Code.MALFORMED_CSV, package(STOPS + bad))
        self.fails(o.Code.MALFORMED_SEQUENCE, package(STOPS + b'u,x,notNumeric\n'))

    def test_invalid_headers(self):
        for header in (b'', b'\xef\xbb\xbf', b'trip_id,stop_id\n', b'trip_id,stop_id,stop_sequence,\n',
                       b'trip_id,stop_id,stop_sequence,stop_id\n'):
            self.fails(n.Code.MALFORMED_CSV, package(header))

    def test_members_missing_duplicate_nested_encrypted_and_symlink(self):
        self.fails(n.Code.INVALID_MEMBERS, zip_bytes())
        self.fails(n.Code.INVALID_MEMBERS, zip_bytes(others=(("folder/stop_times.txt", STOPS),)))
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            self.fails(n.Code.INVALID_MEMBERS, package(others=(("stop_times.txt", STOPS),)))
        for kind in ("encrypted", "symlink"):
            data = bytearray(package(compression=0))
            with zipfile.ZipFile(io.BytesIO(data)) as z:
                offset = z.getinfo("stop_times.txt").header_offset
            central = data.index(b"PK\x01\x02", data.index(b"PK\x01\x02") + 4)
            if kind == "encrypted":
                struct.pack_into("<H", data, offset + 6, 1)
                struct.pack_into("<H", data, central + 8, 1)
                code = n.Code.UNSUPPORTED_ZIP
            else:
                struct.pack_into("<I", data, central + 38, (stat.S_IFLNK | 0o777) << 16)
                code = n.Code.INVALID_MEMBERS
            self.fails(code, bytes(data))

    def test_stored_deflated_and_descriptor_members(self):
        for method in (0, 8):
            for descriptor in (False, True):
                with self.subTest(method=method, descriptor=descriptor):
                    result = o.read_occurrences(*self.install(raw_package(method=method, descriptor=descriptor)), "N01")
                    self.assertEqual(len(result.occurrences), 2)

    def test_member_crc_size_and_compressed_suffix_corruption(self):
        content = STOPS + b"u,x,2\n"
        raw = bytearray(package(content, compression=0))
        with zipfile.ZipFile(io.BytesIO(raw)) as z:
            info = z.getinfo("stop_times.txt")
        raw[info.header_offset + 30 + len(info.filename) + len(content) - 1] ^= 1
        self.fails(n.Code.MEMBER_INTEGRITY, bytes(raw))
        self.fails(n.Code.MEMBER_INTEGRITY, raw_package(declared=len(STOPS) - 1))
        for content, suffix in ((STOPS + b"hidden", b""), (STOPS, b"extra")):
            enc = zlib.compressobj(wbits=-15)
            payload = enc.compress(content) + enc.flush() + suffix
            self.fails(n.Code.MEMBER_INTEGRITY, raw_package(payload=payload))

    def test_actual_expansion_limit_not_just_declared_size(self):
        enc = zlib.compressobj(wbits=-15)
        payload = enc.compress(b"x" * 4096) + enc.flush()
        with mock.patch.object(o, "MAX_STOP_TIMES_BYTES", 100):
            self.fails(n.Code.RESOURCE_LIMIT, raw_package(payload=payload))

    def test_limits_exact_boundaries_and_overflow_no_truncation(self):
        for limit, value in (("MAX_STOP_TIMES_BYTES", len(STOPS)), ("MAX_OCCURRENCE_RECORDS", 2), ("MAX_MATCHES", 2)):
            with mock.patch.object(o, limit, value):
                self.assertEqual(len(self.read().occurrences), 2)
            with mock.patch.object(o, limit, value - 1):
                self.fails(n.Code.RESOURCE_LIMIT, package())
        for limit, value in (("MAX_COLUMNS", 2), ("MAX_FIELD_BYTES", 5), ("MAX_RECORD_BYTES", 10), ("MAX_DATA_RECORDS", 1)):
            with mock.patch.object(n, limit, value):
                self.fails(n.Code.RESOURCE_LIMIT, package(trips=TABLE + b"u,r,s\n"))
        # Production match limit, not a reduced test cap; the 4097th record must fail.
        rows = b"".join(("t,a,%d\n" % i).encode() for i in range(4097))
        self.fails(n.Code.RESOURCE_LIMIT, package(STOP_HEADER + rows))

    def test_record_limit_counts_unmatched_rows_after_last_match(self):
        with mock.patch.object(o, "MAX_OCCURRENCE_RECORDS", 2):
            self.fails(n.Code.RESOURCE_LIMIT, package(STOPS + b"u,x,1\n"))

    def test_fixed_limits_and_production_total_record_cap(self):
        self.assertEqual((o.MAX_STOP_TIMES_BYTES, o.MAX_OCCURRENCE_RECORDS, o.MAX_MATCHES),
                         (32 * 1024 * 1024, 500_000, 4096))
        # One selected row followed by 500,000 unrelated records. No selected-row
        # cap or early return can stand in for the complete-member record cap.
        data = STOP_HEADER + b"t,a,1\n" + b"u,x,1\n" * 500_000
        self.fails(n.Code.RESOURCE_LIMIT, package(data))

    def test_archive_identity_precedes_all_member_decoding(self):
        args = self.install(package())
        for size, digest in ((args[1] + 1, args[2]), (args[1], "0" * 64)):
            with mock.patch.object(n, "_read_member") as read:
                with self.assertRaises(n.NominationError) as error:
                    o.read_occurrences(args[0], size, digest, "N01")
                self.assertEqual(error.exception.code, n.Code.ARCHIVE_IDENTITY)
                read.assert_not_called()

    def test_one_descriptor_and_only_two_payloads(self):
        raw = bytearray(package(others=(("calendar.txt", b"FORBIDDEN"),)))
        with zipfile.ZipFile(io.BytesIO(raw)) as z:
            info = z.getinfo("calendar.txt")
        start = info.header_offset + 30 + len(info.filename)
        raw[start:start + info.compress_size] = b"\xff" * info.compress_size
        args = self.install(bytes(raw))
        original_hash, original_read, original_open = n._hash_archive, n._read_member, os.open
        descriptors, members, opens = [], [], []
        def hashed(file, size):
            descriptors.append(file.fileno())
            return original_hash(file, size)
        def read(file, info, boundary, name, cap):
            members.append(name)
            descriptors.append(file.fileno())
            class BoundedRead:
                def seek(inner, position):
                    self.assertEqual(position, info.header_offset)
                    return file.seek(position)
                def read(inner, count):
                    self.assertGreaterEqual(file.tell(), info.header_offset)
                    self.assertLessEqual(file.tell() + count, boundary)
                    return file.read(count)
            return original_read(BoundedRead(), info, boundary, name, cap)
        def opened(path, flags, *args, **kwargs):
            if path == self.path.name:
                opens.append(flags)
            return original_open(path, flags, *args, **kwargs)
        with mock.patch.object(n, "_hash_archive", side_effect=hashed), \
             mock.patch.object(n, "_read_member", side_effect=read), \
             mock.patch.object(os, "open", side_effect=opened), \
             mock.patch.object(zipfile.ZipFile, "open", side_effect=AssertionError("generic payload opening forbidden")):
            result = o.read_occurrences(*args, "N01")
        self.assertEqual(len(result.occurrences), 2)
        self.assertEqual(members, [b"trips.txt", b"stop_times.txt"])
        self.assertEqual(len(opens), 1)
        self.assertEqual(len(descriptors), 4)
        self.assertEqual(len(set(descriptors)), 1)
        self.assertTrue(opens[0] & os.O_NOFOLLOW)

    def test_mutation_and_path_replacement_after_extraction_are_atomic(self):
        original = o._extract
        for mode in ("bytes", "replacement", "symlink", "ancestor"):
            with self.subTest(mode=mode):
                folder = self.root / mode
                folder.mkdir()
                self.path = folder / "invented.zip"
                args = self.install(package())
                def changed(*args):
                    result = original(*args)
                    if mode == "bytes":
                        content = bytearray(self.path.read_bytes())
                        content[-1] ^= 1
                        self.path.write_bytes(content)
                    elif mode == "replacement":
                        other = folder / "other.zip"
                        other.write_bytes(self.path.read_bytes())
                        os.replace(other, self.path)
                    elif mode == "symlink":
                        self.path.rename(folder / "original.zip")
                        self.path.symlink_to(folder / "original.zip")
                    else:
                        folder.rename(self.root / "moved")
                        folder.symlink_to(self.root / "moved", target_is_directory=True)
                    return result
                with mock.patch.object(o, "_extract", side_effect=changed):
                    with self.assertRaises(n.NominationError) as error:
                        o.read_occurrences(*args, "N01")
                expected = n.Code.INPUT_UNAVAILABLE if mode == "ancestor" else n.Code.INPUT_CHANGED
                self.assertEqual(error.exception.code, expected)

    def test_final_rehash_independent_of_metadata(self):
        args = self.install(package())
        original = o._extract
        def changed(*args):
            result = original(*args)
            data = bytearray(self.path.read_bytes())
            data[-1] ^= 1
            self.path.write_bytes(data)
            return result
        with mock.patch.object(o, "_extract", side_effect=changed), mock.patch.object(n, "_state", return_value=()):
            with self.assertRaises(n.NominationError) as error:
                o.read_occurrences(*args, "N01")
        self.assertEqual(error.exception.code, n.Code.INPUT_CHANGED)

    def test_symlinks_nonregular_and_unsafe_paths_reject(self):
        args = self.install(package())
        link = self.root / "linked.zip"
        link.symlink_to(self.path)
        folder = self.root / "linked-folder"
        folder.symlink_to(self.root, target_is_directory=True)
        fifo = self.root / "fifo"
        os.mkfifo(fifo)
        for path, code in ((link, n.Code.UNSAFE_PATH), (folder / self.path.name, n.Code.INPUT_UNAVAILABLE),
                           (fifo, n.Code.NOT_REGULAR), (self.root, n.Code.NOT_REGULAR), ("relative", n.Code.UNSAFE_PATH)):
            with self.subTest(code=code):
                with self.assertRaises(n.NominationError) as error:
                    o.read_occurrences(str(path), args[1], args[2], "N01")
                self.assertEqual(error.exception.code, code)

    def test_symlink_substitution_between_stat_and_open(self):
        args = self.install(package())
        original = os.open
        def replaced(path, flags, *args, **kwargs):
            if path == self.path.name:
                self.path.rename(self.root / "original.zip")
                self.path.symlink_to(self.root / "original.zip")
            return original(path, flags, *args, **kwargs)
        with mock.patch.object(os, "open", side_effect=replaced):
            with self.assertRaises(n.NominationError) as error:
                o.read_occurrences(*args, "N01")
        self.assertEqual(error.exception.code, n.Code.INPUT_UNAVAILABLE)

    def test_inputs_unchanged_no_persistence_or_network(self):
        args = self.install(package())
        before = self.path.stat()
        names = list(self.root.iterdir())
        with mock.patch("socket.socket", side_effect=AssertionError("network forbidden")), \
             mock.patch("logging.Logger._log", side_effect=AssertionError("logging forbidden")):
            result = o.read_occurrences(*args, "N01")
        after = self.path.stat()
        self.assertEqual(n._state(before), n._state(after))
        self.assertEqual(hashlib.sha256(self.path.read_bytes()).hexdigest(), args[2])
        self.assertEqual(list(self.root.iterdir()), names)
        for value in (result, result.source, result.source.locator, result.occurrences[0], result.occurrences[0].locator):
            self.assertNotIn(args[2], repr(value))

    def test_cli_counts_zero_and_privacy_safe_atomic_errors(self):
        for data, suffix in ((STOPS, "occurrences; matching records: 2"), (STOP_HEADER, "zeroMatches; matching records: 0")):
            args = self.install(package(data))
            argv = ["--archive", args[0], "--expected-size", str(args[1]), "--expected-sha256", args[2], "--label", "N01"]
            stdout, stderr = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                self.assertEqual(o.main(argv), 0)
            self.assertEqual(stdout.getvalue(), "occurrence extraction: " + suffix + "; transport-order inversions: 0; private values not printed\n")
            self.assertEqual(stderr.getvalue(), "")
        args = self.install(package(STOPS + b'"SECRET_BAD'))
        for argv, code in ((["--SECRET_KEY"], "invalidArguments"),
                           (["--archive", args[0], "--expected-size", str(args[1]), "--expected-sha256", args[2], "--label", "N01"], "malformedCSV")):
            stdout, stderr = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                self.assertEqual(o.main(argv), 1)
            self.assertEqual(stdout.getvalue(), "")
            self.assertEqual(stderr.getvalue(), "occurrence extraction failed: " + code + "\n")

    def test_documented_cli_subprocess_and_no_output_files(self):
        args = self.install(package())
        before = sorted(self.root.iterdir())
        command = [sys.executable, "-B", str(Path(o.__file__)), "--archive", args[0],
                   "--expected-size", str(args[1]), "--expected-sha256", args[2], "--label", "N01"]
        result = subprocess.run(command, capture_output=True, text=True, cwd=self.root, timeout=10)
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "occurrence extraction: occurrences; matching records: 2; transport-order inversions: 0; private values not printed\n")
        self.assertEqual(result.stderr, "")
        self.assertEqual(sorted(self.root.iterdir()), before)


if __name__ == "__main__":
    unittest.main(verbosity=2)
