"""Synthetic-only private terminal review tests; no retained real artifacts."""

import contextlib
import hashlib
import io
import json
import os
from pathlib import Path
import pty
import select
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock

import nomination as n
import occurrences as o
import review_session as r
import session as s
from test_occurrences import package, STOP_HEADER
from test_session import MemoryTerminal


class ReviewTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tsugino-review-invented-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.path = self.root / "invented.zip"

    def install(self, stops=STOP_HEADER + b"t,a,001\nt,b,7\nt,a,10\n", trips=None):
        data = package(stops) if trips is None else package(stops, trips)
        self.path.write_bytes(data)
        return str(self.path), len(data), hashlib.sha256(data).hexdigest()

    def argv(self, args, label="N01", count=3, inversions=0):
        return ["--archive", args[0], "--expected-size", str(args[1]), "--expected-sha256", args[2],
                "--label", label, "--expected-count", str(count), "--expected-inversions", str(inversions)]

    def test_original_objects_source_order_repeated_visits_and_locators(self):
        header = b"\xef\xbb\xbftrip_id,stop_id,stop_sequence\r\n"
        rows = [b"u,x,1\r\n", b't,"a,\r\nq",010\r\n', b"t,b,002\r\n", b't,"a,\r\nq",20']
        args = self.install(header + b"".join(rows))
        result = o.read_occurrences(*args, "N01")
        review = r._Review(result, {})
        self.assertIs(review.result, result)
        self.assertEqual([x.stop_sequence for x in result.occurrences], ["010", "002", "20"])
        offset = len(header) + len(rows[0])
        for index, row in enumerate(rows[1:]):
            item = result.occurrences[index]
            self.assertEqual(item.locator, n.Locator(args[2], "stop_times.txt",
                             hashlib.sha256(header + b"".join(rows)).hexdigest(),
                             index + 1, offset, offset + len(row), hashlib.sha256(row).hexdigest()))
            output = review.handle("inspect O%04d" % (index + 1))
            for field in r.LOCATOR_FIELDS:
                self.assertIn("  " + field + "=" + s._display(getattr(item.locator, field)) + "\n", output)
            self.assertIn('stop_sequence=' + s._display(item.stop_sequence), output)
            offset += len(row)
        self.assertEqual(result.occurrences[0].stop_id, result.occurrences[2].stop_id)
        self.assertEqual(len(review.labels), 3)
        self.assertIn("Transport-order inversions: 1", review.summary())

    def test_only_permitted_fields_safe_display_and_no_classification_inference(self):
        header = STOP_HEADER[:-1] + b",arrival_time,departure_time,pickup_type,drop_off_type,timepoint,extra\n"
        args = self.install(header + 't,"é\u202e\u001b[2J",01,RAW_TIME,RAW_TIME,1,1,0,SECRET\n'.encode())
        review = r._Review(o.read_occurrences(*args, "N01"), {})
        output = review.inspect(0)
        self.assertNotIn("RAW_TIME", output)
        self.assertNotIn("SECRET", output)
        self.assertIn('arrival_presence="present"', output)
        self.assertIn("classification=unknown", output)
        self.assertIn("railway order=unverified", output)
        self.assertTrue(all(c == "\n" or 32 <= ord(c) <= 126 for c in output))
        self.assertEqual(json.loads(output.split("stop_id=", 1)[1].splitlines()[0]), 'é\u202e\u001b[2J')
        for cmd in ("stop O0001", "pass O0001", "classify O0001 stop", "crop O0001", "N02", "confirm"):
            self.assertEqual(review.handle(cmd), "Invalid command; review unchanged.\n")
        self.assertIn("all classifications unknown", review.summary())

    def test_absent_empty_and_presence_are_distinct(self):
        args = self.install(STOP_HEADER[:-1] + b",pickup_type,arrival_time\nt,a,1,,\n")
        output = r._Review(o.read_occurrences(*args, "N01"), {}).inspect(0)
        for expected in ('pickup_type=""', 'drop_off_type=null', 'arrival_presence="empty"',
                         'departure_presence="absentColumn"'):
            self.assertIn(expected, output)

    def test_explicit_allowlist_and_gap_links_never_open_or_resolve(self):
        result = o.read_occurrences(*self.install(), "N01")
        refs = r._references(["E01:" + "a" * 64])
        review = r._Review(result, refs)
        with mock.patch("builtins.open", side_effect=AssertionError("no evidence IO")), \
                mock.patch("os.open", side_effect=AssertionError("no evidence IO")):
            self.assertIn("linked", review.handle("link O0002 E01"))
            self.assertIn("recorded", review.handle("gap O0002 mapping"))
            self.assertIn("Invalid", review.handle("link O0002 E02"))
            self.assertIn("Invalid", review.handle("gap O0002 resolved"))
            self.assertIn("digest/applicability unverified", review.handle("refs"))
        self.assertEqual(review.links, [set(), {"E01"}, set()])
        self.assertEqual(review.gaps[1], {"classification", "ordering", "mapping"})
        self.assertIn("classification=unknown", review.inspect(1))
        self.assertIn("mapping gaps: 1", review.summary())
        self.assertIn("all classifications unknown", review.summary())

    def test_bad_references_and_expectations_fail_before_archive_access(self):
        for refs in (("/private/path",), ("E01:" + "A" * 64,), ("E17:" + "a" * 64,),
                     ("E01:" + "a" * 64,) * 2, ("E01:" + "a" * 64,) * 17):
            with self.subTest(refs=refs), mock.patch.object(r, "read_occurrences") as reader:
                with self.assertRaisesRegex(s.SessionError, "invalidEvidenceReferences"):
                    r.run_session("unused", 1, "unused", "N01", 3, 0, refs)
                reader.assert_not_called()
        for count, inversions in ((0, 0), (4097, 0), (3, -1), (3, 3), (True, 0)):
            with mock.patch.object(r, "read_occurrences") as reader:
                with self.assertRaisesRegex(s.SessionError, "invalidExpectations"):
                    r.run_session("unused", 1, "unused", "N01", count, inversions)
                reader.assert_not_called()

    def test_result_mismatch_has_no_display_or_retry(self):
        args = self.install()
        for count, inversions in ((2, 0), (3, 1), (14, 0)):
            terminal = MemoryTerminal([])
            with mock.patch.object(r, "_Terminal", return_value=terminal), \
                    mock.patch.object(r, "read_occurrences", wraps=o.read_occurrences) as reader:
                with self.assertRaisesRegex(s.SessionError, "unexpectedResult"):
                    r.run_session(*args, "N01", count, inversions)
                reader.assert_called_once_with(*args, "N01")
            self.assertEqual(terminal.output, [])

    def test_fixed_candidate_no_substitution(self):
        args = self.install(trips=b"trip_id,route_id,service_id\nu,r,s\nt,r,s\n")
        terminal = MemoryTerminal(["N01", "source", "exit"])
        with mock.patch.object(r, "_Terminal", return_value=terminal), \
                mock.patch.object(r, "read_occurrences", wraps=o.read_occurrences) as reader:
            r.run_session(*args, "N02", 3, 0)
            reader.assert_called_once_with(*args, "N02")
        self.assertIn('label="N02"', "".join(terminal.output))
        self.assertIn("Invalid command", "".join(terminal.output))

    def test_reader_failure_and_zero_matches_have_no_partial_display(self):
        for stops, label in ((STOP_HEADER + b"t,a,1\n\"broken", "N01"), (STOP_HEADER, "N01"),
                             (STOP_HEADER, "N02")):
            terminal = MemoryTerminal([])
            args = self.install(stops)
            with mock.patch.object(r, "_Terminal", return_value=terminal):
                with self.assertRaises((n.NominationError, s.SessionError)):
                    r.run_session(*args, label, 3, 0)
            self.assertEqual(terminal.output, [])

    def test_identity_failure_before_display(self):
        args = self.install()
        for bad in ((args[0], args[1] + 1, args[2]), (args[0], args[1], "0" * 64)):
            terminal = MemoryTerminal([])
            with mock.patch.object(r, "_Terminal", return_value=terminal):
                with self.assertRaises(n.NominationError):
                    r.run_session(*bad, "N01", 3, 0)
            self.assertEqual(terminal.output, [])

    def test_cancel_eof_interrupt_clear_all_review_state(self):
        args = self.install()
        original = r._Review
        for ending in ("exit", "cancel", None, KeyboardInterrupt()):
            held = []
            def capture(*values):
                review = original(*values)
                held.append(review)
                return review
            terminal = MemoryTerminal([])
            terminal.command = mock.Mock(side_effect=["gap O0002 identity", "link O0002 E01", ending])
            with mock.patch.object(r, "_Review", side_effect=capture), \
                    mock.patch.object(r, "_Terminal", return_value=terminal):
                if isinstance(ending, BaseException):
                    with self.assertRaises(KeyboardInterrupt):
                        r.run_session(*args, "N01", 3, 0, ["E01:" + "a" * 64])
                else:
                    self.assertIsNone(r.run_session(*args, "N01", 3, 0, ["E01:" + "a" * 64]))
            self.assertIsNone(held[0].result)
            for field in ("refs", "labels", "gaps", "links"):
                self.assertFalse(getattr(held[0], field))

    def test_terminal_guard_precedes_reader_and_errors_are_redacted(self):
        args = self.install()
        with mock.patch.object(s._Terminal, "_check", side_effect=s.SessionError("localTerminalRequired")), \
                mock.patch.object(r, "read_occurrences") as reader, contextlib.redirect_stderr(io.StringIO()) as errors:
            self.assertEqual(r.main(self.argv(args)), 1)
            reader.assert_not_called()
            self.assertEqual(errors.getvalue(), "review failed: localTerminalRequired\n")
        for extra in (["SECRET"], ["--expected-count", "SECRET"]):
            with contextlib.redirect_stderr(io.StringIO()) as errors:
                self.assertEqual(r.main(self.argv(args) + extra), 1)
            self.assertEqual(errors.getvalue(), "review failed: invalidArguments\n")
        with mock.patch.object(r, "run_session", side_effect=RuntimeError("SECRET")), \
                contextlib.redirect_stderr(io.StringIO()) as errors:
            self.assertEqual(r.main(self.argv(args)), 1)
        self.assertEqual(errors.getvalue(), "review failed: internalError\n")

    def test_no_write_logging_network_or_subprocess_in_session(self):
        args = self.install()
        terminal = MemoryTerminal(["source", "gap O0002 movement", "link O0002 E01", "exit"])
        original_open = os.open
        def read_only_open(path, flags, *values, **kwargs):
            self.assertEqual(flags & os.O_ACCMODE, os.O_RDONLY)
            self.assertFalse(flags & (os.O_CREAT | os.O_TRUNC | os.O_APPEND))
            return original_open(path, flags, *values, **kwargs)
        with mock.patch.object(r, "_Terminal", return_value=terminal), \
                mock.patch("os.open", side_effect=read_only_open), \
                mock.patch("builtins.open", side_effect=AssertionError("unexpected file IO")), \
                mock.patch("socket.socket", side_effect=AssertionError("network")), \
                mock.patch("subprocess.Popen", side_effect=AssertionError("subprocess")), \
                mock.patch("logging.Logger._log", side_effect=AssertionError("logging")):
            self.assertIsNone(r.run_session(*args, "N01", 3, 0, ["E01:" + "a" * 64]))

    def test_terminal_write_failure_clears_review(self):
        args = self.install()
        held = []
        original = r._Review
        def capture(*values):
            review = original(*values)
            held.append(review)
            return review
        terminal = MemoryTerminal([])
        terminal.write = mock.Mock(side_effect=OSError("PRIVATE_DETAIL"))
        with mock.patch.object(r, "_Review", side_effect=capture), \
                mock.patch.object(r, "_Terminal", return_value=terminal), \
                contextlib.redirect_stderr(io.StringIO()) as errors:
            self.assertEqual(r.main(self.argv(args)), 1)
        self.assertEqual(errors.getvalue(), "review failed: terminalUnavailable\n")
        self.assertIsNone(held[0].result)
        self.assertFalse(held[0].gaps)

    def terminal_process(self, argv, commands):
        pid, master = pty.fork()
        if pid == 0:
            env = dict(os.environ)
            for key in ("SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY"):
                env.pop(key, None)
            os.execve(sys.executable, [sys.executable, "-B", "-W", "error", r.__file__] + argv, env)
        output, sent, finished = bytearray(), 0, False
        deadline = time.monotonic() + 10
        try:
            while time.monotonic() < deadline:
                ready, _, _ = select.select([master], [], [], 0.1)
                if ready:
                    try:
                        chunk = os.read(master, 65536)
                    except OSError as error:
                        if error.errno != 5:
                            raise
                        break
                    if not chunk:
                        break
                    output.extend(chunk)
                    if output.count(b"Command (input is not echoed)> ") > sent and sent < len(commands):
                        os.write(master, commands[sent])
                        sent += 1
            else:
                self.fail("invented terminal session timed out")
            _, status = os.waitpid(pid, 0)
            finished = True
            return os.waitstatus_to_exitcode(status), bytes(output).replace(b"\r\n", b"\n")
        finally:
            if not finished:
                os.kill(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            os.close(master)

    def test_actual_cli_inspection_gaps_bounded_commands_and_no_persistence(self):
        args = self.install()
        before = (self.path.read_bytes(), self.path.stat().st_mode, list(self.root.iterdir()))
        code, output = self.terminal_process(self.argv(args) + ["--evidence-ref", "E01:" + "a" * 64],
            [b"next\n", b"gap O0002 mapping\n", b"link O0002 E01\n", b"inspect O0002\n",
             b"next\n", b"prev\n", b"source\n", b"summary\n", b"refs\n", b"x" * 40 + b"\n", b"exit\n"])
        self.assertEqual(code, 0)
        for expected in (b'stop_sequence="001"', b'stop_sequence="7"', b'stop_sequence="10"',
                         b"classification,ordering,mapping", b"unopened evidence references=E01",
                         b"all classifications unknown", b"Invalid command", b"no review retained"):
            self.assertIn(expected, output)
        self.assertNotIn(b"x" * 40, output)
        self.assertEqual((self.path.read_bytes(), self.path.stat().st_mode, list(self.root.iterdir())), before)

    def test_actual_cli_mismatch_failure_cancel_eof_and_redirected_terminal(self):
        args = self.install()
        code, output = self.terminal_process(self.argv(args, count=14), [])
        self.assertEqual((code, output), (1, b"review failed: unexpectedResult\n"))
        code, output = self.terminal_process(self.argv((args[0], args[1], "0" * 64)), [])
        self.assertEqual((code, output), (1, b"review failed: archiveIdentityMismatch\n"))
        for command in (b"cancel\n", b"\x04", b"\x03"):
            code, output = self.terminal_process(self.argv(args), [command])
            self.assertEqual(code, 130 if command == b"\x03" else 0)
            self.assertIn(b"discarded" if command == b"\x03" else b"no review retained", output)
        result = subprocess.run([sys.executable, "-B", r.__file__] + self.argv(args), capture_output=True)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, b"")
        self.assertIn(result.stderr, (b"review failed: interactiveTerminalRequired\n",
                                      b"review failed: localTerminalRequired\n"))


if __name__ == "__main__":
    unittest.main()
