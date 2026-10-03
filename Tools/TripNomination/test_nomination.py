"""Wholly invented inputs; no real-archive path, network or provider fixtures."""

import contextlib
import hashlib
import io
import os
from pathlib import Path
import stat
import struct
import tempfile
import unittest
from unittest import mock
import warnings
import zipfile
import zlib

import nomination as n


HEADER = b"trip_id,route_id,service_id\n"
TABLE = HEADER + b"t,r,s\n"


def zip_bytes(data=TABLE, others=(), compression=zipfile.ZIP_DEFLATED):
    out = io.BytesIO()
    with zipfile.ZipFile(out, "w", compression=compression) as archive:
        archive.writestr("trips.txt", data)
        for name, value in others:
            archive.writestr(name, value)
    return out.getvalue()


def raw_zip(data=TABLE, method=0, flags=0, descriptor=False, declared=None, payload=None):
    """Independent ZIP fixture builder, for malformed metadata/stream controls."""
    name = b"trips.txt"
    crc = zlib.crc32(data) & 0xFFFFFFFF
    if payload is None:
        if method == 8:
            compressor = zlib.compressobj(wbits=-15)
            payload = compressor.compress(data) + compressor.flush()
        else:
            payload = data
    length = len(data) if declared is None else declared
    flags |= 8 if descriptor else 0
    local_values = (0, 0, 0) if descriptor else (crc, len(payload), length)
    local = struct.pack("<4s5H3I2H", b"PK\x03\x04", 20, flags, method, 0, 0,
                        *local_values, len(name), 0) + name + payload
    if descriptor:
        local += struct.pack("<4s3I", b"PK\x07\x08", crc, len(payload), length)
    central = struct.pack("<4s6H3I5H2I", b"PK\x01\x02", 20, 20, flags, method, 0, 0,
                          crc, len(payload), length, len(name), 0, 0, 0, 0, 0, 0) + name
    end = struct.pack("<4s4H2IH", b"PK\x05\x06", 0, 0, 1, 1, len(central), len(local), 0)
    return local + central + end


class NominationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tsugino-nomination-invented-")
        self.addCleanup(self.temp.cleanup)
        # macOS's system temporary root may itself have a symlink alias.
        self.root = Path(os.path.realpath(self.temp.name))
        self.path = self.root / "invented.zip"

    def install(self, data):
        self.path.write_bytes(data)
        return str(self.path), len(data), hashlib.sha256(data).hexdigest()

    def read(self, data=TABLE, **kwargs):
        return n.read_nominations(*self.install(zip_bytes(data, **kwargs)))

    def fails(self, code, archive):
        args = self.install(archive)
        with self.assertRaises(n.NominationError) as caught:
            n.read_nominations(*args)
        self.assertEqual(caught.exception.code, code)
        self.assertEqual(str(caught.exception), code.value)

    def test_source_order_and_duplicates_are_preserved(self):
        result = self.read(HEADER + b"z,r,s\na,r,s\nz,r,s\n")
        self.assertEqual([x.label for x in result.nominations], ["N01", "N02", "N03"])
        self.assertEqual([x.values[0] for x in result.nominations], ["z", "a", "z"])
        self.assertEqual([x.locator.data_record_ordinal for x in result.nominations], [0, 1, 2])

    def test_zero_fewer_ten_and_more_records(self):
        for count in (0, 1, 9, 10, 11, 25):
            with self.subTest(count=count):
                result = self.read(HEADER + b"".join(b"t%d,r,s\n" % i for i in range(count)))
                self.assertEqual(len(result.nominations), min(count, 10))
                self.assertEqual([x.values[0] for x in result.nominations],
                                 ["t%d" % i for i in range(min(count, 10))])

    def test_exact_spans_with_quotes_newlines_crlf_and_no_final_terminator(self):
        header = b"trip_id,route_id,service_id\r\n"
        first = b'"a,\r\nb","r""q",s\r\n'
        last = b'last,r,"s\nx"'
        data = header + first + last
        result = self.read(data)
        a, b = result.nominations
        self.assertEqual(a.values, ("a,\r\nb", 'r"q', "s"))
        self.assertEqual(b.values, ("last", "r", "s\nx"))
        self.assertEqual((a.locator.byte_start, a.locator.byte_end), (len(header), len(header + first)))
        self.assertEqual((b.locator.byte_start, b.locator.byte_end), (len(header + first), len(data)))
        for choice, raw in ((a, first), (b, last)):
            loc = choice.locator
            self.assertEqual(data[loc.byte_start:loc.byte_end], raw)
            self.assertEqual(loc.record_sha256, hashlib.sha256(raw).hexdigest())
            self.assertEqual(loc.member_sha256, hashlib.sha256(data).hexdigest())
            self.assertEqual(loc.archive_sha256, hashlib.sha256(self.path.read_bytes()).hexdigest())
            self.assertEqual(loc.member_name, "trips.txt")

    def test_lf_record_terminator_and_optional_empty_field(self):
        data = HEADER[:-1] + b",extra\n" + b"t,r,s,\n" + b"u,r,s,"
        result = self.read(data)
        self.assertEqual(result.nominations[0].values, ("t", "r", "s", ""))
        self.assertEqual(data[result.nominations[0].locator.byte_start:result.nominations[0].locator.byte_end], b"t,r,s,\n")
        self.assertEqual(result.nominations[1].values[-1], "")

    def test_scalar_exact_unicode_whitespace_and_bom(self):
        data = b"\xef\xbb\xbf" + HEADER + 'é,r,s\ne\u0301,r,s\n t\u3000,r,s\n\ufeffx,r,s\n'.encode()
        result = self.read(data)
        self.assertEqual([x.values[0] for x in result.nominations], ["é", "e\u0301", " t\u3000", "\ufeffx"])
        self.assertNotEqual(result.nominations[0].values, result.nominations[1].values)
        self.assertEqual(result.nominations[0].locator.byte_start, 3 + len(HEADER))

    def test_malformed_csv_never_skips_or_substitutes(self):
        for bad in (b'"open,r,s', b'a"b,r,s\n', b'"a"x,r,s\n', b't,r\n',
                    b't,r,s,extra\n', b'\n', b't,r,s\rb,r,s\n', b',r,s\n',
                    b't,,s\n', b't,r,\n', b't,\x00,s\n', b'\xff,r,s\n'):
            with self.subTest(bad=bad):
                self.fails(n.Code.MALFORMED_CSV, zip_bytes(HEADER + bad + b"later,r,s\n"))

    def test_malformed_eleventh_record_rejects_whole_result(self):
        self.fails(n.Code.MALFORMED_CSV, zip_bytes(HEADER + b"t,r,s\n" * 10 + b'"unterminated'))

    def test_header_validation(self):
        for header in (b'', b'\xef\xbb\xbf', b'trip_id,route_id\n', b'trip_id,route_id,service_id,trip_id\n',
                       b'trip_id,route_id,service_id,\n', b'TRIP_ID,route_id,service_id\n'):
            with self.subTest(header=header):
                self.fails(n.Code.MALFORMED_CSV, zip_bytes(header))

    def test_invalid_and_duplicate_member_names(self):
        for name in ('trips.txt', '../x', '/x', 'dir/x', 'x\\y', '.hidden'):
            with self.subTest(name=name), warnings.catch_warnings():
                warnings.simplefilter('ignore', UserWarning)  # Intentional duplicate fixture.
                self.fails(n.Code.INVALID_MEMBERS, zip_bytes(others=((name, b'ignored'),)))
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', UserWarning)
            self.fails(n.Code.INVALID_MEMBERS, zip_bytes(others=(('x', b'1'), ('x', b'2'))))
        # zipfile's writer truncates names at NUL: mutate encoded metadata so
        # this fixture actually contains the malformed name being tested.
        raw = zip_bytes(others=(('axb', b'ignored'),)).replace(b'axb', b'a\x00b')
        self.fails(n.Code.INVALID_MEMBERS, raw)

    def test_missing_or_nested_trips_and_member_symlink(self):
        for name in ('TRIPS.TXT', 'folder/trips.txt', 'trips.txt'):
            with self.subTest(name=name):
                out = io.BytesIO()
                with zipfile.ZipFile(out, 'w') as archive:
                    info = zipfile.ZipInfo(name)
                    if name == 'trips.txt':
                        info.create_system = 3
                        info.external_attr = (stat.S_IFLNK | 0o777) << 16
                    archive.writestr(info, TABLE)
                self.fails(n.Code.INVALID_MEMBERS, out.getvalue())

    def test_stored_deflated_and_descriptor_controls(self):
        for method in (0, 8):
            for descriptor in (False, True):
                with self.subTest(method=method, descriptor=descriptor):
                    result = n.read_nominations(*self.install(raw_zip(method=method, descriptor=descriptor)))
                    self.assertEqual(result.nominations[0].values, ('t', 'r', 's'))

    def test_encrypted_or_unsupported_selected_member(self):
        for flags, method in ((1, 0), (64, 0), (0, 12)):
            with self.subTest(flags=flags, method=method):
                self.fails(n.Code.UNSUPPORTED_ZIP, raw_zip(flags=flags, method=method))

    def test_invalid_zip_and_envelope(self):
        self.fails(n.Code.INVALID_ARCHIVE, b'not a zip')
        for field, value in ((4, 1), (6, 1), (8, 2)):
            with self.subTest(field=field):
                raw = bytearray(raw_zip())
                struct.pack_into('<H', raw, len(raw) - 22 + field, value)
                self.fails(n.Code.UNSUPPORTED_ZIP, bytes(raw))
        raw = bytearray(raw_zip())
        struct.pack_into('<I', raw, len(raw) - 22 + 16, 0)
        self.fails(n.Code.INVALID_ARCHIVE, bytes(raw))

    def test_local_and_central_disagreement(self):
        for offset, replacement in ((0, b'FAIL'), (30, b'X'), (8, b'\x08\x00')):
            with self.subTest(offset=offset):
                raw = bytearray(raw_zip())
                raw[offset:offset + len(replacement)] = replacement
                code = n.Code.INVALID_MEMBERS if offset == 30 else n.Code.INVALID_ARCHIVE
                self.fails(code, bytes(raw))

    def test_crc_and_actual_size_are_checked_independently(self):
        raw = bytearray(raw_zip())
        raw[39] ^= 1
        self.fails(n.Code.MEMBER_INTEGRITY, bytes(raw))
        self.fails(n.Code.MEMBER_INTEGRITY, raw_zip(declared=len(TABLE) + 1))
        # A malicious ZIP declares the prefix's size AND matching CRC while its
        # deflate stream expands to more bytes. ZipExtFile can hide that suffix.
        compressor = zlib.compressobj(wbits=-15)
        payload = compressor.compress(TABLE + b'hidden') + compressor.flush()
        self.fails(n.Code.MEMBER_INTEGRITY, raw_zip(method=8, payload=payload))

    def test_truncated_deflate_and_trailing_compressed_bytes(self):
        compressor = zlib.compressobj(wbits=-15)
        payload = compressor.compress(TABLE) + compressor.flush()
        for corrupted in (payload[:-1], payload + b'extra'):
            with self.subTest(payload=corrupted):
                self.fails(n.Code.MEMBER_INTEGRITY, raw_zip(method=8, payload=corrupted))

    def test_descriptor_integrity(self):
        raw = bytearray(raw_zip(descriptor=True))
        raw[39 + len(TABLE) + 4] ^= 1
        self.fails(n.Code.MEMBER_INTEGRITY, bytes(raw))
        raw = bytearray(raw_zip(descriptor=True))
        struct.pack_into('<I', raw, 22, len(TABLE) + 1)
        self.fails(n.Code.MEMBER_INTEGRITY, bytes(raw))

    def test_central_count_understatement_and_truncated_directory(self):
        raw = bytearray(zip_bytes(others=(('extra', b'x'),)))
        struct.pack_into('<HH', raw, len(raw) - 22 + 8, 1, 1)
        self.fails(n.Code.INVALID_ARCHIVE, bytes(raw))
        raw = bytearray(raw_zip())
        central = raw.index(b'PK\x01\x02')
        struct.pack_into('<H', raw, central + 28, 65535)
        self.fails(n.Code.INVALID_ARCHIVE, bytes(raw))

    def test_corrupt_unselected_content_is_never_decoded(self):
        raw = bytearray(zip_bytes(others=(('stop_times.txt', b'not authorized'),)))
        with zipfile.ZipFile(io.BytesIO(raw)) as archive:
            other = archive.getinfo('stop_times.txt')
            start = other.header_offset + 30 + len(other.filename)
            raw[start:start + other.compress_size] = b'\xff' * other.compress_size
        result = n.read_nominations(*self.install(bytes(raw)))
        self.assertEqual(result.nominations[0].values, ('t', 'r', 's'))

    def test_resource_limits(self):
        cases = [('MAX_DIRECTORY_BYTES', 20, raw_zip()),
                 ('MAX_MEMBERS', 1, zip_bytes(others=(('extra.txt', b'x'),))),
                 ('MAX_TRIPS_BYTES', len(TABLE) - 1, raw_zip()),
                 ('MAX_RECORD_BYTES', 5, raw_zip()),
                 ('MAX_FIELD_BYTES', 6, raw_zip()),
                 ('MAX_COLUMNS', 2, raw_zip()),
                 ('MAX_DATA_RECORDS', 1, zip_bytes(HEADER + b't,r,s\nu,r,s\n'))]
        for constant, limit, raw in cases:
            with self.subTest(constant=constant), mock.patch.object(n, constant, limit):
                self.fails(n.Code.RESOURCE_LIMIT, raw)
        with self.assertRaises(n.NominationError) as error:
            n.read_nominations('/unused', n.MAX_ARCHIVE_BYTES + 1, '0' * 64)
        self.assertEqual(error.exception.code, n.Code.INVALID_ARGUMENTS)

    def test_inflation_over_actual_limit_even_with_small_declared_size(self):
        compressor = zlib.compressobj(wbits=-15)
        payload = compressor.compress(b'x' * 1000) + compressor.flush()
        with mock.patch.object(n, 'MAX_TRIPS_BYTES', 100):
            self.fails(n.Code.RESOURCE_LIMIT, raw_zip(method=8, payload=payload))

    def test_exact_field_and_record_limit(self):
        row = b'abcdefghij,r,s\n'
        with mock.patch.object(n, 'MAX_FIELD_BYTES', 10):
            self.assertEqual(self.read(HEADER + row).nominations[0].values[0], 'abcdefghij')
        with mock.patch.object(n, 'MAX_RECORD_BYTES', len(HEADER)):
            self.assertEqual(len(self.read().nominations), 1)

    def test_identity_rejected_before_member_decoding(self):
        args = self.install(raw_zip())
        for size, digest in ((args[1] + 1, args[2]), (args[1], '0' * 64)):
            with self.subTest(size=size, digest=digest), mock.patch.object(n, '_read_trips') as read:
                with self.assertRaises(n.NominationError) as error:
                    n.read_nominations(args[0], size, digest)
                self.assertEqual(error.exception.code, n.Code.ARCHIVE_IDENTITY)
                read.assert_not_called()

    def test_changed_bytes_during_read_reject(self):
        args = self.install(raw_zip())
        original = n._nominate
        def change(*values):
            result = original(*values)
            content = bytearray(self.path.read_bytes())
            content[40] ^= 1
            self.path.write_bytes(content)
            return result
        with mock.patch.object(n, '_nominate', side_effect=change):
            with self.assertRaises(n.NominationError) as error:
                n.read_nominations(*args)
        self.assertEqual(error.exception.code, n.Code.INPUT_CHANGED)

    def test_same_bytes_replaced_path_reject(self):
        args = self.install(raw_zip())
        original = n._nominate
        def replace(*values):
            result = original(*values)
            other = self.root / 'replacement.zip'
            other.write_bytes(self.path.read_bytes())
            os.replace(other, self.path)
            return result
        with mock.patch.object(n, '_nominate', side_effect=replace):
            with self.assertRaises(n.NominationError) as error:
                n.read_nominations(*args)
        self.assertEqual(error.exception.code, n.Code.INPUT_CHANGED)

    def test_symlink_final_and_ancestor_reject(self):
        args = self.install(raw_zip())
        link = self.root / 'link.zip'
        link.symlink_to(self.path)
        directory = self.root / 'linked-directory'
        directory.symlink_to(self.root, target_is_directory=True)
        for path, code in ((link, n.Code.UNSAFE_PATH), (directory / self.path.name, n.Code.INPUT_UNAVAILABLE)):
            with self.subTest(path=path):
                with self.assertRaises(n.NominationError) as error:
                    n.read_nominations(str(path), args[1], args[2])
                self.assertEqual(error.exception.code, code)

    def test_symlink_swap_between_stat_and_open_reject(self):
        args = self.install(raw_zip())
        original = os.open
        def swap(path, flags, *extra, **kwargs):
            if path == self.path.name:
                self.path.rename(self.root / 'original.zip')
                self.path.symlink_to(self.root / 'original.zip')
            return original(path, flags, *extra, **kwargs)
        with mock.patch.object(n.os, 'open', side_effect=swap):
            with self.assertRaises(n.NominationError) as error:
                n.read_nominations(*args)
        self.assertEqual(error.exception.code, n.Code.INPUT_UNAVAILABLE)

    def test_symlink_swap_after_processing_reject(self):
        args = self.install(raw_zip())
        original = n._nominate
        def swap(*values):
            result = original(*values)
            self.path.rename(self.root / 'original.zip')
            self.path.symlink_to(self.root / 'original.zip')
            return result
        with mock.patch.object(n, '_nominate', side_effect=swap):
            with self.assertRaises(n.NominationError) as error:
                n.read_nominations(*args)
        self.assertEqual(error.exception.code, n.Code.INPUT_CHANGED)

    def test_ancestor_symlink_substitution_after_processing_reject(self):
        folder = self.root / 'source'
        folder.mkdir()
        self.path = folder / 'invented.zip'
        args = self.install(raw_zip())
        original = n._nominate
        def swap(*values):
            result = original(*values)
            folder.rename(self.root / 'moved')
            folder.symlink_to(self.root / 'moved', target_is_directory=True)
            return result
        with mock.patch.object(n, '_nominate', side_effect=swap):
            with self.assertRaises(n.NominationError) as error:
                n.read_nominations(*args)
        self.assertEqual(error.exception.code, n.Code.INPUT_UNAVAILABLE)

    def test_final_hash_detects_change_even_if_metadata_comparison_is_bypassed(self):
        args = self.install(raw_zip())
        original = n._nominate
        def change(*values):
            result = original(*values)
            data = bytearray(self.path.read_bytes())
            data[-1] ^= 1
            self.path.write_bytes(data)
            return result
        with mock.patch.object(n, '_nominate', side_effect=change), mock.patch.object(n, '_state', return_value=()):
            with self.assertRaises(n.NominationError) as error:
                n.read_nominations(*args)
        self.assertEqual(error.exception.code, n.Code.INPUT_CHANGED)

    def test_one_archive_descriptor_and_only_trips_payload_read(self):
        args = self.install(zip_bytes(others=(('stop_times.txt', b'NOT CSV'), ('calendar.txt', b'NOT CSV'))))
        descriptors = []
        original_hash, original_read = n._hash_archive, n._read_trips
        opens = []
        original_open = os.open
        def opened(path, flags, *extra, **kwargs):
            if path == self.path.name:
                opens.append(path)
            return original_open(path, flags, *extra, **kwargs)
        def hashed(file, size):
            descriptors.append(file.fileno())
            return original_hash(file, size)
        def selected(file, info, boundary):
            self.assertEqual(info.filename, 'trips.txt')
            descriptors.append(file.fileno())
            class TracedFile:
                def seek(inner, pos):
                    self.assertEqual(pos, info.header_offset)
                    return file.seek(pos)
                def read(inner, count):
                    self.assertGreaterEqual(file.tell(), info.header_offset)
                    self.assertLessEqual(file.tell() + count, boundary)
                    return file.read(count)
            return original_read(TracedFile(), info, boundary)
        with mock.patch.object(n.os, 'open', side_effect=opened), \
             mock.patch.object(n, '_hash_archive', side_effect=hashed), \
             mock.patch.object(n, '_read_trips', side_effect=selected) as read, \
             mock.patch.object(zipfile.ZipFile, 'open', side_effect=AssertionError('no generic member opening')):
            result = n.read_nominations(*args)
        self.assertEqual(len(result.nominations), 1)
        self.assertEqual(opens, [self.path.name])
        self.assertEqual(len(descriptors), 3)
        self.assertEqual(len(set(descriptors)), 1)
        self.assertEqual(read.call_count, 1)

    def test_inputs_and_permissions_unchanged_no_output_files(self):
        args = self.install(raw_zip())
        self.path.chmod(0o600)
        before = self.path.stat()
        names = list(self.root.iterdir())
        n.read_nominations(*args)
        after = self.path.stat()
        self.assertEqual(hashlib.sha256(self.path.read_bytes()).hexdigest(), args[2])
        self.assertEqual((before.st_mode, before.st_size, before.st_mtime_ns, before.st_ctime_ns),
                         (after.st_mode, after.st_size, after.st_mtime_ns, after.st_ctime_ns))
        self.assertEqual(list(self.root.iterdir()), names)

    def test_invalid_arguments_and_nonregular_paths(self):
        for size, digest in ((True, '0' * 64), (0, '0' * 64), (1, 'secret'), (1, 'A' * 64)):
            with self.subTest(size=size, digest=digest):
                with self.assertRaises(n.NominationError) as error:
                    n.read_nominations('/unused', size, digest)
                self.assertEqual(error.exception.code, n.Code.INVALID_ARGUMENTS)
        for path in ('relative.zip', '/a/../b', '/a//b'):
            with self.subTest(path=path):
                with self.assertRaises(n.NominationError) as error:
                    n.read_nominations(path, 1, '0' * 64)
                self.assertEqual(error.exception.code, n.Code.UNSAFE_PATH)
        for path in (self.root, self.root / 'fifo'):
            if path != self.root:
                os.mkfifo(path)
            with self.subTest(path=path):
                with self.assertRaises(n.NominationError) as error:
                    n.read_nominations(str(path), 1, '0' * 64)
                self.assertEqual(error.exception.code, n.Code.NOT_REGULAR)

    def test_private_repr_cli_success_and_errors(self):
        args = self.install(zip_bytes(HEADER + b'SECRET_KEY,r,s\n'))
        result = n.read_nominations(*args)
        self.assertNotIn('SECRET_KEY', repr(result))
        self.assertNotIn('SECRET_KEY', repr(result.nominations[0]))
        self.assertNotIn(args[2], repr(result.nominations[0].locator))
        output, errors = io.StringIO(), io.StringIO()
        argv = ['--archive', args[0], '--expected-size', str(args[1]), '--expected-sha256', args[2]]
        with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
            self.assertEqual(n.main(argv), 0)
        self.assertEqual(output.getvalue(), 'nomination records available: 1; private values not printed\n')
        self.assertEqual(errors.getvalue(), '')
        for argv in (['--SECRET_KEY'], ['--archive', '/SECRET_KEY'],
                     ['--archive', '/SECRET_KEY', '--expected-size', 'SECRET_KEY', '--expected-sha256', 'x']):
            with self.subTest(argv=argv):
                output, errors = io.StringIO(), io.StringIO()
                with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
                    self.assertEqual(n.main(argv), 1)
                self.assertEqual(output.getvalue(), '')
                self.assertEqual(errors.getvalue(), 'nomination failed: invalidArguments\n')

    def test_cli_data_and_path_errors_are_redacted_and_atomic(self):
        args = self.install(zip_bytes(HEADER + b'SECRET_KEY,r,s\n"SECRET_BAD'))
        for path, code in ((args[0], 'malformedCSV'), (str(self.root / 'SECRET_MISSING'), 'inputUnavailable')):
            with self.subTest(code=code):
                output, errors = io.StringIO(), io.StringIO()
                argv = ['--archive', path, '--expected-size', str(args[1]), '--expected-sha256', args[2]]
                with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
                    self.assertEqual(n.main(argv), 1)
                self.assertEqual(output.getvalue(), '')
                self.assertEqual(errors.getvalue(), 'nomination failed: ' + code + '\n')


if __name__ == '__main__':
    unittest.main(verbosity=2)
