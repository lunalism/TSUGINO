"""Bounded untimed occurrence extraction, private memory API and counts-only CLI.

No real-input authorization, classification, identity proof or S9 acceptance.
Uses nomination's ZIP/CSV primitives; does not call the reader twice or reopen
an archive to read a second payload. Python 3.9+, standard library only.
"""

from dataclasses import dataclass
from enum import Enum
import hashlib
import os
import re
import stat
import struct
import sys
from typing import Optional
import zipfile
import zlib

import nomination as n


MAX_STOP_TIMES_BYTES = 32 * 1024 * 1024
MAX_OCCURRENCE_RECORDS = 500_000
MAX_MATCHES = 4096


class Code(Enum):
    NOMINATION_UNAVAILABLE = "nominationUnavailable"
    AMBIGUOUS_JOIN = "ambiguousSelectedKey"
    MALFORMED_SEQUENCE = "malformedSequence"
    DUPLICATE_SEQUENCE = "duplicateSequence"


class Presence(Enum):
    ABSENT_COLUMN = "absentColumn"
    EMPTY = "empty"
    PRESENT = "present"


class Outcome(Enum):
    OCCURRENCES = "occurrences"
    ZERO_MATCHES = "zeroMatches"


@dataclass(frozen=True, repr=False)
class SourceAssociation:
    label: str
    trip_id: str
    route_id: str
    service_id: str
    locator: n.Locator


@dataclass(frozen=True, repr=False)
class Occurrence:
    stop_id: str
    stop_sequence: str
    pickup_type: Optional[str]
    drop_off_type: Optional[str]
    timepoint: Optional[str]
    arrival_presence: Presence
    departure_presence: Presence
    locator: n.Locator


@dataclass(frozen=True, repr=False)
class OccurrenceBatch:
    source: SourceAssociation
    occurrences: tuple
    outcome: Outcome
    stop_times_sha256: str
    stop_times_record_count: int
    transport_order_inversions: int


def _selected_trip(data, archive_digest, label):
    # The approved nomination parser validates the COMPLETE trips table first.
    batch = n._nominate(data, archive_digest)
    candidate = next((x for x in batch.nominations if x.label == label), None)
    if candidate is None:
        raise n.NominationError(Code.NOMINATION_UNAVAILABLE)
    columns = batch.columns
    trip_index = columns.index("trip_id")
    trip = candidate.values[trip_index]
    records = n._records(data)
    next(records)  # Already validated header.
    if sum(values[trip_index] == trip for values, _, _ in records) != 1:
        # Even an identical duplicate beyond the ten-choice window is ambiguous.
        raise n.NominationError(Code.AMBIGUOUS_JOIN)
    return SourceAssociation(label, trip, candidate.values[columns.index("route_id")],
                             candidate.values[columns.index("service_id")], candidate.locator)


def _extract(data, source, archive_digest):
    records = n._records(data)
    first = next(records, None)
    if first is None:
        raise n.NominationError(n.Code.MALFORMED_CSV)
    columns = first[0]
    required = ("trip_id", "stop_id", "stop_sequence")
    if (any(not c for c in columns) or len(set(columns)) != len(columns)
            or any(c not in columns for c in required)):
        raise n.NominationError(n.Code.MALFORMED_CSV)
    indices = {c: i for i, c in enumerate(columns)}
    member_digest = hashlib.sha256(data).hexdigest()
    matches = []
    sequences = set()
    previous = None
    inversions = 0
    count = 0

    def optional(values, field):
        return values[indices[field]] if field in indices else None

    def presence(values, field):
        value = optional(values, field)
        return Presence.ABSENT_COLUMN if value is None else (Presence.EMPTY if value == "" else Presence.PRESENT)

    for ordinal, (values, start, end) in enumerate(records):
        if ordinal >= MAX_OCCURRENCE_RECORDS:
            raise n.NominationError(n.Code.RESOURCE_LIMIT)
        count += 1
        if len(values) != len(columns) or any(not values[indices[c]] for c in required):
            raise n.NominationError(n.Code.MALFORMED_CSV)
        sequence = values[indices["stop_sequence"]]
        if not re.fullmatch(r"[0-9]+", sequence):
            raise n.NominationError(Code.MALFORMED_SEQUENCE)
        if values[indices["trip_id"]] != source.trip_id:
            continue
        if len(matches) >= MAX_MATCHES:
            raise n.NominationError(n.Code.RESOURCE_LIMIT)
        # Decimal equivalence only: preserve the original scalar in the result.
        # Avoid integer conversion/overflow and Python's variable digit limits.
        key = sequence.lstrip("0") or "0"
        if key in sequences:
            raise n.NominationError(Code.DUPLICATE_SEQUENCE)
        sequences.add(key)
        order = (len(key), key)
        if previous is not None and order < previous:
            inversions += 1
        previous = order
        matches.append(Occurrence(
            values[indices["stop_id"]], sequence,
            optional(values, "pickup_type"), optional(values, "drop_off_type"), optional(values, "timepoint"),
            presence(values, "arrival_time"), presence(values, "departure_time"),
            n.Locator(archive_digest, "stop_times.txt", member_digest, ordinal, start, end,
                      hashlib.sha256(data[start:end]).hexdigest())))
    return OccurrenceBatch(source, tuple(matches), Outcome.OCCURRENCES if matches else Outcome.ZERO_MATCHES,
                           member_digest, count, inversions)


def read_occurrences(path, expected_size, expected_sha256, label):
    """Reconstruct a nominated label in identified bytes; return only a full result.

    Labels must have been explicitly nominated by the owner. This API cannot
    authenticate that action. Archive digest + label deterministically binds the
    exact original nomination locator, which is returned privately with the result.
    """
    if (type(expected_size) is not int or not 0 < expected_size <= n.MAX_ARCHIVE_BYTES
            or not isinstance(expected_sha256, str)
            or not re.fullmatch(r"[0-9a-f]{64}", expected_sha256)
            or not isinstance(label, str) or not re.fullmatch(r"N(?:0[1-9]|10)", label)):
        raise n.NominationError(n.Code.INVALID_ARGUMENTS)
    try:
        with n._parent(path) as (parent, name):
            prior = os.stat(name, dir_fd=parent, follow_symlinks=False)
            if stat.S_ISLNK(prior.st_mode):
                raise n.NominationError(n.Code.UNSAFE_PATH)
            if not stat.S_ISREG(prior.st_mode):
                raise n.NominationError(n.Code.NOT_REGULAR)
            fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
        with os.fdopen(fd, "rb", buffering=0) as file:
            initial = os.fstat(file.fileno())
            if not stat.S_ISREG(initial.st_mode) or n._state(initial) != n._state(prior):
                raise n.NominationError(n.Code.INPUT_CHANGED)
            if initial.st_size != expected_size or n._hash_archive(file, expected_size) != expected_sha256:
                raise n.NominationError(n.Code.ARCHIVE_IDENTITY)
            trips, trips_end = n._directory(file, expected_size)
            stops, stops_end = n._directory(file, expected_size, "stop_times.txt")
            source = _selected_trip(n._read_trips(file, trips, trips_end), expected_sha256, label)
            data = n._read_member(file, stops, stops_end, b"stop_times.txt", MAX_STOP_TIMES_BYTES)
            result = _extract(data, source, expected_sha256)
            if (n._hash_archive(file, expected_size) != expected_sha256
                    or n._state(os.fstat(file.fileno())) != n._state(initial)):
                raise n.NominationError(n.Code.INPUT_CHANGED)
            with n._parent(path) as (parent, name):
                if n._state(os.stat(name, dir_fd=parent, follow_symlinks=False)) != n._state(initial):
                    raise n.NominationError(n.Code.INPUT_CHANGED)
            return result
    except n.NominationError:
        raise
    except UnicodeError:
        raise n.NominationError(n.Code.INVALID_ARCHIVE) from None
    except (zipfile.BadZipFile, struct.error, zlib.error, EOFError, NotImplementedError):
        raise n.NominationError(n.Code.INVALID_ARCHIVE) from None
    except OSError:
        raise n.NominationError(n.Code.INPUT_UNAVAILABLE) from None


def main(argv=None):
    parser = n._Arguments(description="Untimed occurrences; counts only, no private values.")
    parser.add_argument("--archive", required=True)
    parser.add_argument("--expected-size", required=True, type=int)
    parser.add_argument("--expected-sha256", required=True)
    parser.add_argument("--label", required=True)
    try:
        args = parser.parse_args(argv)
        result = read_occurrences(args.archive, args.expected_size, args.expected_sha256, args.label)
        print("occurrence extraction: %s; matching records: %d; transport-order inversions: %d; private values not printed"
              % (result.outcome.value, len(result.occurrences), result.transport_order_inversions))
        return 0
    except n.NominationError as error:
        print("occurrence extraction failed: " + error.code.value, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
