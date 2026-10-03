"""Memory-only owner inspection. Synthetic approval grants no real-input access."""

import re
import sys
import termios

from nomination import NominationError
from occurrences import MAX_MATCHES, read_occurrences
from session import SessionError, _Arguments, _Terminal, _display


LOCATOR_FIELDS = ("archive_sha256", "member_name", "member_sha256", "data_record_ordinal",
                  "byte_start", "byte_end", "record_sha256")
GAPS = ("classification", "ordering", "provenance", "identity", "mapping", "movement", "endpoints")
MAX_EVIDENCE_REFS = 16


def _references(values):
    """Opaque labels and owner-asserted digests only; never paths or file reads."""
    if len(values) > MAX_EVIDENCE_REFS:
        raise SessionError("invalidEvidenceReferences")
    refs = {}
    for value in values:
        if not isinstance(value, str) or not re.fullmatch(r"E(?:0[1-9]|1[0-6]):[0-9a-f]{64}", value):
            raise SessionError("invalidEvidenceReferences")
        label, digest = value.split(":")
        if label in refs:
            raise SessionError("invalidEvidenceReferences")
        refs[label] = digest
    return refs


def _locator(value):
    return "".join("  " + field + "=" + _display(getattr(value, field)) + "\n"
                   for field in LOCATOR_FIELDS)


class _Review:
    """Original immutable result plus bounded, unverified annotations; no admission."""

    def __init__(self, result, refs):
        self.result = result
        self.refs = dict(refs)
        self.labels = {"O%04d" % (i + 1): i for i in range(len(result.occurrences))}
        self.gaps = [{"classification", "ordering"} for _ in result.occurrences]
        self.links = [set() for _ in result.occurrences]
        self.current = 0

    def inspect(self, index):
        item = self.result.occurrences[index]
        text = "O%04d (source transport position, not a canonical index)\n" % (index + 1)
        for field in ("stop_id", "stop_sequence", "pickup_type", "drop_off_type", "timepoint"):
            text += "  " + field + "=" + _display(getattr(item, field)) + "\n"
        for field in ("arrival_presence", "departure_presence"):
            text += "  " + field + "=" + _display(getattr(item, field).value) + "\n"
        text += _locator(item.locator)
        text += "  classification=unknown; railway order=unverified\n"
        text += "  gaps=" + ",".join(g for g in GAPS if g in self.gaps[index]) + "\n"
        text += "  unopened evidence references=" + ",".join(sorted(self.links[index])) + "\n"
        return text

    def source(self):
        source = self.result.source
        text = "Fixed original nomination (owner confirmation is not authenticated):\n"
        for field in ("label", "trip_id", "route_id", "service_id"):
            text += "  " + field + "=" + _display(getattr(source, field)) + "\n"
        return text + _locator(source.locator)

    def summary(self):
        return ("All %d occurrences retained; all classifications unknown; no S9 acceptance.\n"
                "Transport-order inversions: %d; railway order unverified.\n"
                % (len(self.result.occurrences), self.result.transport_order_inversions)
                + "".join("  %s gaps: %d\n" % (g, sum(g in row for row in self.gaps)) for g in GAPS)
                + "Zero recorded optional gaps does not establish evidence or readiness.\n")

    def handle(self, command):
        if command == "source":
            return self.source()
        if command == "summary":
            return self.summary()
        if command == "refs":
            return "References only; content unopened, digest/applicability unverified:\n" + "".join(
                label + ":" + self.refs[label] + "\n" for label in sorted(self.refs))
        if command in ("next", "prev"):
            self.current = max(0, min(len(self.result.occurrences) - 1,
                                      self.current + (1 if command == "next" else -1)))
            return self.inspect(self.current)
        parts = command.split(" ")
        if len(parts) == 2 and parts[0] == "inspect" and parts[1] in self.labels:
            self.current = self.labels[parts[1]]
            return self.inspect(self.current)
        if len(parts) == 3 and parts[1] in self.labels:
            index = self.labels[parts[1]]
            if parts[0] == "gap" and parts[2] in GAPS:
                self.gaps[index].add(parts[2])
                return "Gap recorded in memory; classification remains unknown.\n"
            if parts[0] == "link" and parts[2] in self.refs:
                self.links[index].add(parts[2])
                return "Unopened reference linked in memory; no gap resolved.\n"
        return "Invalid command; review unchanged.\n"

    def clear(self):
        self.result = None
        self.refs.clear()
        self.labels.clear()
        self.gaps.clear()
        self.links.clear()


def run_session(path, expected_size, expected_sha256, label, expected_count,
                expected_inversions, evidence_refs=()):
    # Bounds are additional assertions, never extractor limit overrides.
    if (type(expected_count) is not int or not 1 <= expected_count <= MAX_MATCHES
            or type(expected_inversions) is not int or not 0 <= expected_inversions < expected_count):
        raise SessionError("invalidExpectations")
    refs = _references(evidence_refs)
    with _Terminal() as terminal:
        # Exactly one reader call, no nomination UI, retries or alternate candidates.
        result = read_occurrences(path, expected_size, expected_sha256, label)
        if (len(result.occurrences) != expected_count
                or result.transport_order_inversions != expected_inversions):
            raise SessionError("unexpectedResult")
        review = _Review(result, refs)
        del result
        try:
            terminal.write(
                "Private occurrence inspection; no evidence content is opened.\n"
                "All state is memory-only and lost at exit. Values use ASCII JSON escaping.\n"
                "Commands: source, inspect O0001, next, prev, summary, refs,\n"
                "gap O0001 <reason>, link O0001 E01, cancel, exit.\n"
                "Gap reasons: " + ", ".join(GAPS) + "\n"
                + review.summary() + review.inspect(0))
            while True:
                command = terminal.command()
                if command is None or command in ("cancel", "exit"):
                    terminal.write("Session ended; no review retained outside this session.\n")
                    return
                terminal.write(review.handle(command))
        finally:
            review.clear()


def main(argv=None):
    parser = _Arguments(description="Private memory-only occurrence inspection; no saved output.",
                        allow_abbrev=False)
    parser.add_argument("--archive", required=True)
    parser.add_argument("--expected-size", required=True, type=int)
    parser.add_argument("--expected-sha256", required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--expected-count", required=True, type=int)
    parser.add_argument("--expected-inversions", required=True, type=int)
    parser.add_argument("--evidence-ref", action="append", default=[])
    try:
        args = parser.parse_args(argv)
        run_session(args.archive, args.expected_size, args.expected_sha256, args.label,
                    args.expected_count, args.expected_inversions, args.evidence_ref)
        return 0
    except NominationError as error:
        print("review failed: " + error.code.value, file=sys.stderr)
    except SessionError as error:
        print("review failed: " + str(error), file=sys.stderr)
    except (OSError, termios.error):
        print("review failed: terminalUnavailable", file=sys.stderr)
    except KeyboardInterrupt:
        print("Review cancelled; memory-only state discarded.", file=sys.stderr)
        return 130
    except Exception:
        # Never expose a traceback/local variables for an unexpected caller failure.
        print("review failed: internalError", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
