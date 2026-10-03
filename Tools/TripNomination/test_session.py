"""Invented archives and private in-memory terminal captures only; no real inputs."""

import contextlib
import csv
import hashlib
import io
import json
import logging
import os
from pathlib import Path
import pty
import select
import signal
import stat
import subprocess
import sys
import tempfile
import termios
import time
from types import SimpleNamespace
import unittest
from unittest import mock

import nomination as n
import session as s
from test_nomination import HEADER, TABLE, zip_bytes


class MemoryTerminal:
    def __init__(self, commands):
        self.commands = iter(commands)
        self.output = []

    def __enter__(self):
        return self

    def __exit__(self, *_):
        pass

    def write(self, text):
        self.output.append(text)

    def command(self):
        return next(self.commands)


class SessionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tsugino-session-invented-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(os.path.realpath(self.temp.name))
        self.path = self.root / "invented.zip"

    def install(self, table=TABLE):
        data = zip_bytes(table, others=(("stop_times.txt", b"not even valid CSV"),))
        self.path.write_bytes(data)
        return str(self.path), len(data), hashlib.sha256(data).hexdigest()

    def batch(self, table=TABLE):
        return n.read_nominations(*self.install(table))

    def argv(self, args):
        return ["--archive", args[0], "--expected-size", str(args[1]), "--expected-sha256", args[2]]

    def test_every_label_selects_original_candidate_and_exact_locator(self):
        header = b"service_id,extra,trip_id,route_id\r\n"
        records = [b's,hidden,"z,\r\nx",r\r\n'] + [b's,hidden,z%d,r\r\n' % i for i in range(1, 11)]
        args = self.install(header + b"".join(records))
        batch = n.read_nominations(*args)
        state = s._Selection(batch)
        self.assertEqual(len(batch.nominations), 10)
        for index, original in enumerate(batch.nominations):
            with self.subTest(label=original.label):
                state.handle("N%02d" % (index + 1))
                self.assertIs(state.pending, original)
                output = state.handle("confirm")
                self.assertIs(state.selected, original)
                self.assertIs(state.selected.locator, original.locator)
                loc = state.selected.locator
                self.assertEqual(loc.data_record_ordinal, index)
                self.assertEqual(loc.byte_start, len(header) + sum(map(len, records[:index])))
                self.assertEqual(loc.byte_end, loc.byte_start + len(records[index]))
                self.assertEqual(loc.record_sha256, hashlib.sha256(records[index]).hexdigest())
                self.assertEqual(loc.member_sha256, hashlib.sha256(header + b"".join(records)).hexdigest())
                self.assertEqual(loc.archive_sha256, args[2])
                self.assertEqual(loc.member_name, "trips.txt")
                for name, value in vars(loc).items():
                    self.assertIn("  " + name + "=" + json.dumps(value) + "\n", output)
                self.assertNotIn("hidden", output)
        self.assertNotIn("N11", state.listing())

    def test_confirmation_and_inspection_require_explicit_choice(self):
        batch = self.batch(HEADER + b"first,r,s\nsecond,r,s\n")
        state = s._Selection(batch)
        self.assertIn("No pending", state.handle("confirm"))
        self.assertIn("No confirmed", state.handle("inspect"))
        state.handle("N01")
        self.assertIsNone(state.selected)
        state.handle("confirm")
        state.handle("N02")
        self.assertIs(state.selected, batch.nominations[0])
        self.assertIn('trip_id="first"', state.handle("inspect"))
        state.handle("confirm")
        self.assertIs(state.selected, batch.nominations[1])
        self.assertIn('trip_id="second"', state.handle("inspect"))
        self.assertIsNone(state.pending)

    def test_invalid_input_clears_pending_never_selects_or_replaces_confirmed(self):
        batch = self.batch(HEADER + b"first,r,s\nsecond,r,s\n")
        for invalid in ("", "1", "N00", "N03", "N11", "n01", " N01", "N01 ", "N01\nconfirm", "\x1b[31m"):
            with self.subTest(invalid=repr(invalid)):
                state = s._Selection(batch)
                state.handle("N01")
                output = state.handle(invalid)
                self.assertIn("Invalid command", output)
                self.assertIsNone(state.pending)
                state.handle("confirm")
                self.assertIsNone(state.selected)
                state.handle("N01")
                state.handle("confirm")
                state.handle("N02")
                state.handle(invalid)
                state.handle("confirm")
                self.assertIs(state.selected, batch.nominations[0])
                self.assertNotIn("\x1b", output)

    def test_listing_is_source_order_and_only_required_identifiers(self):
        batch = self.batch(b"trip_id,route_id,service_id,trip_headsign\nz,r,s,SECRET\na,r,s,PRIVATE\n")
        state = s._Selection(batch)
        self.assertEqual(state.listing(), 'N01\n  trip_id="z"\n  route_id="r"\n  service_id="s"\n'
                         'N02\n  trip_id="a"\n  route_id="r"\n  service_id="s"\n')
        self.assertIsNone(state.selected)

    def test_unicode_and_terminal_controls_are_escaped_without_changing_originals(self):
        values = ('é/e\u0301/서울/🚆\x1b[2J\x1b]0;title\x07', 'r\r\n\t\b\x7f\x9b', 's\u202e\u2066\u2028\u2029"\\')
        buffer = io.StringIO(newline="")
        writer = csv.writer(buffer)
        writer.writerow(("trip_id", "route_id", "service_id"))
        writer.writerow(values)
        batch = self.batch(buffer.getvalue().encode("utf-8"))
        state = s._Selection(batch)
        state.handle("N01")
        output = state.handle("confirm")
        self.assertIs(state.selected, batch.nominations[0])
        self.assertEqual(state.selected.values, values)
        self.assertTrue(all(c == "\n" or 32 <= ord(c) <= 126 for c in output))
        for column, value in zip(s.IDENTIFIERS, values):
            encoded = next(line.split("=", 1)[1] for line in output.splitlines() if line.startswith("  " + column + "="))
            self.assertEqual(json.loads(encoded), value)
        self.assertIn("\\u001b", output)
        self.assertIn("\\u202e", output)

    def test_empty_batch_never_selects(self):
        state = s._Selection(self.batch(HEADER))
        self.assertEqual(state.listing(), "No nomination choices in this validated input.\n")
        for command in ("N01", "confirm", "inspect", "list"):
            state.handle(command)
            self.assertIsNone(state.selected)

    def test_cancel_exit_and_eof_discard_selection_without_returning_private_objects(self):
        batch = self.batch()
        for ending in ("cancel", "exit", None):
            for commands in ((ending,), ("N01", ending), ("N01", "confirm", "inspect", ending)):
                with self.subTest(commands=commands):
                    terminal = MemoryTerminal(commands)
                    state = s._Selection(batch)
                    with mock.patch.object(s, "_Terminal", return_value=terminal), mock.patch.object(s, "read_nominations", return_value=batch), mock.patch.object(s, "_Selection", return_value=state):
                        self.assertIsNone(s.run_session("unused", 1, "unused"))
                    self.assertIsNone(state.selected)
                    self.assertIsNone(state.pending)
                    self.assertIn("lost when this session ends", "".join(terminal.output))
                    self.assertIn("no selection retained outside", terminal.output[-1])

    def test_interrupt_clears_live_selection(self):
        state = s._Selection(self.batch())
        terminal = MemoryTerminal(())
        terminal.command = mock.Mock(side_effect=["N01", "confirm", KeyboardInterrupt])
        with mock.patch.object(s, "_Terminal", return_value=terminal), mock.patch.object(s, "read_nominations", return_value=state.batch), mock.patch.object(s, "_Selection", return_value=state):
            with self.assertRaises(KeyboardInterrupt):
                s.run_session("unused", 1, "unused")
        self.assertIsNone(state.selected)
        self.assertIsNone(state.pending)

    def test_validation_failure_never_displays_any_candidate(self):
        for table, wrong_hash in ((HEADER + b"PRIVATE_FIRST,r,s\n\"broken", False), (HEADER + b"PRIVATE_FIRST,r,s\n", True)):
            with self.subTest(wrong_hash=wrong_hash):
                args = self.install(table)
                if wrong_hash:
                    args = args[:2] + ("0" * 64,)
                terminal = MemoryTerminal(())
                errors = io.StringIO()
                with mock.patch.object(s, "_Terminal", return_value=terminal), contextlib.redirect_stderr(errors):
                    self.assertEqual(s.main(self.argv(args)), 1)
                self.assertEqual(terminal.output, [])
                self.assertEqual(errors.getvalue(), "nomination failed: " + ("archiveIdentityMismatch" if wrong_hash else "malformedCSV") + "\n")

    def test_session_delegates_to_reader_once_no_files_logs_network_or_input_changes(self):
        args = self.install()
        before = self.path.read_bytes(), self.path.stat().st_mode, sorted(self.root.iterdir())
        terminal = MemoryTerminal(("N01", "confirm", "inspect", "exit"))
        original_open = os.open

        def readonly_open(path, flags, *rest, **kwargs):
            self.assertEqual(flags & (os.O_WRONLY | os.O_RDWR | os.O_CREAT | os.O_TRUNC | os.O_APPEND), 0)
            return original_open(path, flags, *rest, **kwargs)

        with mock.patch.object(s, "_Terminal", return_value=terminal), mock.patch.object(s, "read_nominations", wraps=n.read_nominations) as reader, mock.patch("os.open", side_effect=readonly_open), mock.patch("builtins.open", side_effect=AssertionError("unexpected file open")), mock.patch.object(logging.Logger, "_log", side_effect=AssertionError("unexpected log")), mock.patch("socket.socket", side_effect=AssertionError("unexpected network")):
            self.assertIsNone(s.run_session(*args))
            reader.assert_called_once_with(*args)
        self.assertEqual((self.path.read_bytes(), self.path.stat().st_mode, sorted(self.root.iterdir())), before)

    def test_redirection_and_background_terminal_reject_before_archive_access(self):
        device = SimpleNamespace(st_mode=stat.S_IFCHR, st_rdev=42)
        for bad_fd in (0, 1, 2, None):
            with self.subTest(bad_fd=bad_fd), mock.patch.dict(os.environ, {}, clear=True), mock.patch("os.fstat", return_value=device), mock.patch("os.isatty", side_effect=lambda fd: fd != bad_fd), mock.patch("os.tcgetpgrp", return_value=10), mock.patch("os.getpgrp", return_value=11 if bad_fd is None else 10), mock.patch.object(s, "read_nominations") as reader:
                with self.assertRaisesRegex(s.SessionError, "interactiveTerminalRequired"):
                    s.run_session("never opened", 1, "unused")
                reader.assert_not_called()

    def test_different_terminal_and_ssh_are_rejected(self):
        devices = [SimpleNamespace(st_mode=stat.S_IFCHR, st_rdev=x) for x in (42, 43, 42)]
        with mock.patch.dict(os.environ, {}, clear=True), mock.patch("os.fstat", side_effect=devices), mock.patch("os.isatty", return_value=True):
            with self.assertRaisesRegex(s.SessionError, "interactiveTerminalRequired"):
                s._Terminal()._check()
        for key in ("SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY"):
            with self.subTest(key=key), mock.patch.dict(os.environ, {key: "present"}, clear=True):
                with self.assertRaisesRegex(s.SessionError, "localTerminalRequired"):
                    s._Terminal()._check()

    def test_bounded_input_never_interprets_a_partial_or_nonascii_command(self):
        terminal = s._Terminal()
        terminal.input = 999
        terminal.write = mock.Mock()
        for raw, expected, flush in ((b"N01\n", "N01", False), (b"", None, False), (b"N01", "", True),
                                     (b"x" * 32 + b"\n", "", True), ("Ｎ01\n".encode(), "", False)):
            with self.subTest(raw=raw), mock.patch("os.read", return_value=raw) as read, mock.patch("termios.tcflush") as flushed:
                self.assertEqual(terminal.command(), expected)
                read.assert_called_once_with(999, 33)
                self.assertEqual(flushed.called, flush)

    def test_terminal_rechecks_before_private_write(self):
        terminal = s._Terminal()
        terminal.output = 999
        terminal._check = mock.Mock(side_effect=s.SessionError("interactiveTerminalRequired"))
        with mock.patch("os.write") as write:
            with self.assertRaises(s.SessionError):
                terminal.write("PRIVATE")
            write.assert_not_called()

    def test_terminal_restores_echo_and_closes_descriptors_on_exit_and_interrupt(self):
        for interrupt in (False, True):
            with self.subTest(interrupt=interrupt):
                master, slave = pty.openpty()
                original = termios.tcgetattr(slave)
                duplicate = os.dup
                try:
                    with mock.patch.object(s._Terminal, "_check"), mock.patch("os.dup", side_effect=lambda _: duplicate(slave)):
                        try:
                            with s._Terminal() as terminal:
                                self.assertFalse(termios.tcgetattr(slave)[3] & (termios.ECHO | termios.ECHONL))
                                self.assertTrue(termios.tcgetattr(slave)[3] & termios.ICANON)
                                if interrupt:
                                    raise KeyboardInterrupt
                        except KeyboardInterrupt:
                            pass
                    self.assertEqual(termios.tcgetattr(slave), original)
                    for fd in (terminal.input, terminal.output):
                        with self.assertRaises(OSError):
                            os.fstat(fd)
                finally:
                    os.close(slave)
                    os.close(master)

    def test_noncanonical_terminal_rejects_before_reader_and_closes_duplicates(self):
        master, slave = pty.openpty()
        settings = termios.tcgetattr(slave)
        settings[3] &= ~termios.ICANON
        termios.tcsetattr(slave, termios.TCSANOW, settings)
        # Noncanonical tcgetattr exposes VMIN/VTIME as integers, not bytes.
        # Compare against the actual installed state, not its setter input.
        settings = termios.tcgetattr(slave)
        duplicate = os.dup
        duplicates = []

        def save_duplicate(_):
            fd = duplicate(slave)
            duplicates.append(fd)
            return fd

        try:
            with mock.patch.object(s._Terminal, "_check"), mock.patch("os.dup", side_effect=save_duplicate), mock.patch.object(s, "read_nominations") as reader:
                with self.assertRaisesRegex(s.SessionError, "canonicalTerminalRequired"):
                    s.run_session("never opened", 1, "unused")
                reader.assert_not_called()
            self.assertEqual(termios.tcgetattr(slave), settings)
            for fd in duplicates:
                with self.assertRaises(OSError):
                    os.fstat(fd)
        finally:
            os.close(slave)
            os.close(master)

    def test_redirected_cli_and_argument_errors_never_echo_private_inputs(self):
        args = self.install(HEADER + b"PRIVATE_ROW,r,s\n")
        script = str(Path(s.__file__).resolve())
        result = subprocess.run([sys.executable, "-B", script] + self.argv(args), capture_output=True, check=False)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, b"")
        self.assertIn(result.stderr, (b"session unavailable: interactiveTerminalRequired\n", b"session unavailable: localTerminalRequired\n"))
        errors = io.StringIO()
        with contextlib.redirect_stderr(errors):
            self.assertEqual(s.main(self.argv(args) + ["PRIVATE_ARGUMENT"]), 1)
        self.assertEqual(errors.getvalue(), "session unavailable: invalidArguments\n")

    def terminal_process(self, args, commands):
        """Execute the documented CLI with a controlling PTY; capture invented text in RAM."""
        pid, master = pty.fork()
        if pid == 0:
            env = dict(os.environ)
            for key in ("SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY"):
                env.pop(key, None)
            os.execve(sys.executable, [sys.executable, "-B", "-W", "error", str(Path(s.__file__).resolve())] + self.argv(args), env)
        output = bytearray()
        sent = 0
        finished = False
        deadline = time.monotonic() + 10
        try:
            while time.monotonic() < deadline:
                ready, _, _ = select.select([master], [], [], 0.1)
                if ready:
                    try:
                        chunk = os.read(master, 65536)
                    except OSError as error:
                        if error.errno != 5:  # PTY hangup on platforms using EIO.
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
            return os.waitstatus_to_exitcode(status), bytes(output)
        finally:
            if not finished:
                os.kill(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            os.close(master)

    def test_actual_terminal_confirmation_inspection_and_no_files(self):
        args = self.install(b"trip_id,route_id,service_id,extra\nfirst,r,s,NEVER_DISPLAY\nsecond,r,s,NEVER_DISPLAY\n")
        before = self.path.read_bytes(), sorted(self.root.iterdir())
        code, output = self.terminal_process(args, [b"confirm\n", b"N99\n", b"N02\n", b"confirm\n", b"inspect\n", b"exit\n"])
        self.assertEqual(code, 0)
        self.assertIn(b"No pending choice", output)
        self.assertIn(b"Invalid command", output)
        self.assertIn(b"Confirmed in memory", output)
        self.assertIn(b'  data_record_ordinal=1', output)
        self.assertEqual(output.count(b'  archive_sha256="' + args[2].encode() + b'"'), 2)
        self.assertNotIn(b"NEVER_DISPLAY", output)
        self.assertNotIn(b"N99", output)  # Input echo is disabled too.
        self.assertEqual((self.path.read_bytes(), sorted(self.root.iterdir())), before)

    def test_actual_terminal_cancel_eof_and_validation_failure(self):
        args = self.install()
        for commands in ([b"cancel\n"], [b"\x04"], [b"N01\n", b"cancel\n"]):
            with self.subTest(commands=commands):
                code, output = self.terminal_process(args, commands)
                self.assertEqual(code, 0)
                self.assertNotIn(b"Confirmed in memory", output)
                self.assertIn(b"no selection retained outside", output)
        code, output = self.terminal_process(args[:2] + ("0" * 64,), [])
        self.assertEqual(code, 1)
        self.assertEqual(output.replace(b"\r\n", b"\n"), b"nomination failed: archiveIdentityMismatch\n")


if __name__ == "__main__":
    unittest.main()
