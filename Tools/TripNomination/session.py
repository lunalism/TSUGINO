"""Local terminal nomination session. Real execution needs separate authorization."""

import argparse
import json
import os
import stat
import sys
import termios

from nomination import NominationError, read_nominations


MAX_COMMAND_BYTES = 32
IDENTIFIERS = ("trip_id", "route_id", "service_id")


class SessionError(Exception):
    """Only fixed, non-private error codes may cross the command-line boundary."""


def _display(value):
    # ASCII JSON string escaping is injective and suppresses ESC, C0/C1,
    # bidi/format controls, line separators and all other non-ASCII scalars.
    # The original immutable candidate is never replaced by this display text.
    return json.dumps(value, ensure_ascii=True)


class _Terminal:
    def _check(self):
        if any(key in os.environ for key in ("SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY")):
            raise SessionError("localTerminalRequired")
        states = [os.fstat(fd) for fd in (0, 1, 2)]
        if (not all(os.isatty(fd) for fd in (0, 1, 2))
                or not all(stat.S_ISCHR(s.st_mode) for s in states)
                or len({s.st_rdev for s in states}) != 1
                or os.tcgetpgrp(0) != os.getpgrp()):
            raise SessionError("interactiveTerminalRequired")

    def __enter__(self):
        self._check()
        self.input = os.dup(0)
        self.output = None
        self.saved = None
        try:
            self.output = os.dup(1)
            self.saved = termios.tcgetattr(self.input)
            if not self.saved[3] & termios.ICANON:
                raise SessionError("canonicalTerminalRequired")
            quiet = list(self.saved)
            quiet[3] &= ~(termios.ECHO | termios.ECHONL)
            termios.tcsetattr(self.input, termios.TCSANOW, quiet)
            return self
        except BaseException:
            self.__exit__(None, None, None)
            raise

    def __exit__(self, *_):
        try:
            if self.saved is not None:
                termios.tcsetattr(self.input, termios.TCSANOW, self.saved)
        finally:
            os.close(self.input)
            if self.output is not None:
                os.close(self.output)

    def write(self, text):
        # Recheck redirection/foreground state before every private write. A
        # duplicate terminal fd prevents an intervening stdout replacement from
        # redirecting this write to a file or pipe.
        self._check()
        data = text.encode("ascii")
        while data:
            written = os.write(self.output, data)
            if not written:
                raise SessionError("terminalUnavailable")
            data = data[written:]

    def command(self):
        self.write("Command (input is not echoed)> ")
        value = os.read(self.input, MAX_COMMAND_BYTES + 1)
        self.write("\n")
        if not value:
            return None  # EOF exits without returning the selection.
        if len(value) > MAX_COMMAND_BYTES or not value.endswith(b"\n"):
            termios.tcflush(self.input, termios.TCIFLUSH)
            return ""  # Do not interpret a truncated label/command or its suffix.
        try:
            return value[:-1].decode("ascii")
        except UnicodeError:
            return ""


class _Selection:
    """Private live state; selection retains object identity, including locator."""

    def __init__(self, batch):
        self.batch = batch
        self.choices = {candidate.label: candidate for candidate in batch.nominations}
        self.pending = None
        self.selected = None

    def _candidate(self, candidate, locator=False):
        text = candidate.label + "\n"
        for column in IDENTIFIERS:
            text += "  " + column + "=" + _display(candidate.values[self.batch.columns.index(column)]) + "\n"
        if locator:
            loc = candidate.locator
            for field in ("archive_sha256", "member_name", "member_sha256", "data_record_ordinal",
                          "byte_start", "byte_end", "record_sha256"):
                text += "  " + field + "=" + _display(getattr(loc, field)) + "\n"
        return text

    def listing(self):
        if not self.batch.nominations:
            return "No nomination choices in this validated input.\n"
        return "".join(self._candidate(c) for c in self.batch.nominations)

    def handle(self, command):
        if command in self.choices:
            self.pending = self.choices[command]
            return (self._candidate(self.pending)
                    + "Pending only. Type confirm to retain this choice; cancel exits.\n")
        if command == "confirm":
            if self.pending is None:
                return "No pending choice. Enter an exact label first.\n"
            self.selected = self.pending
            self.pending = None
            return "Confirmed in memory; selection is lost when this session ends.\n" + self._candidate(self.selected, True)
        if command == "inspect":
            if self.selected is None:
                return "No confirmed selection.\n"
            return "Confirmed choice (original values and locator):\n" + self._candidate(self.selected, True)
        if command == "list":
            return self.listing()
        self.pending = None
        return "Invalid command. Pending choice cleared; confirmed selection unchanged.\n"

    def clear(self):
        self.pending = None
        self.selected = None


def run_session(path, expected_size, expected_sha256):
    """No private object is returned when the live session exits."""
    with _Terminal() as terminal:
        # Terminal qualification precedes archive access. Reader validation is
        # unchanged and finishes atomically before any candidate is displayed.
        batch = read_nominations(path, expected_size, expected_sha256)
        selection = _Selection(batch)
        try:
            terminal.write(
                "Private owner nomination; no real S9 acceptance.\n"
                "Selection is memory-only and lost when this session ends.\n"
                "Values use ASCII JSON escaping; originals remain unchanged.\n"
                "Commands: N01-N10, confirm, inspect, list, cancel, exit.\n"
                + selection.listing())
            while True:
                command = terminal.command()
                if command is None or command in ("cancel", "exit"):
                    terminal.write("Session ended; no selection retained outside this session.\n")
                    return
                terminal.write(selection.handle(command))
        finally:
            selection.clear()


class _Arguments(argparse.ArgumentParser):
    def error(self, message):
        raise SessionError("invalidArguments")


def main(argv=None):
    parser = _Arguments(description="Private local terminal nomination; no saved output.")
    parser.add_argument("--archive", required=True)
    parser.add_argument("--expected-size", required=True, type=int)
    parser.add_argument("--expected-sha256", required=True)
    try:
        args = parser.parse_args(argv)
        run_session(args.archive, args.expected_size, args.expected_sha256)
        return 0
    except NominationError as error:
        print("nomination failed: " + error.code.value, file=sys.stderr)
    except SessionError as error:
        print("session unavailable: " + str(error), file=sys.stderr)
    except (OSError, termios.error):
        print("session unavailable: terminalUnavailable", file=sys.stderr)
    except KeyboardInterrupt:
        print("Session cancelled; selection lost.", file=sys.stderr)
        return 130
    return 1


if __name__ == "__main__":
    sys.exit(main())
