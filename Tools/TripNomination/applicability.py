"""Synthetic-verified applicability check for the accepted Toei trip-key profile.

The result establishes source-profile applicability only. It is not Trip identity,
correspondence, allocation, registration, calendar interpretation or S9 acceptance.
"""
from dataclasses import dataclass
from enum import Enum
import json
import math
import os
import re
import stat
import sys
import zipfile

import nomination as n
import occurrences as o
from session import _Arguments, _Terminal, SessionError


PROFILE = "toei-20260921-trip-id-applicability-00"
MAX_MEMBER_BYTES = 32 * 1024 * 1024
MAX_ROWS = 500_000
TIME_SHAPE = re.compile(r"[0-9]+:[0-5][0-9]:[0-5][0-9]\Z")


class Disposition(str, Enum):
    ELIGIBLE = "eligible"
    HELD = "held"
    EXCLUDED = "excluded"


class Status(str, Enum):
    MATCHED = "matchedProfile"
    EXCLUDED = "excluded"
    NOT_EVALUATED = "notEvaluated"


class Reason(str, Enum):
    ARCHIVE_IDENTITY_MISMATCH = "archiveIdentityMismatch"
    CANDIDATE_MISSING = "candidateMissing"
    DUPLICATE_EXACT_KEY = "duplicateExactKeyConflict"
    TRIPS_ROW_MALFORMED = "tripsRowMalformed"
    MISSING_ROUTE = "missingRouteAssociation"
    MISSING_SERVICE = "missingServiceAssociation"
    MEMBER_MALFORMED = "relevantMemberMalformed"
    FREQUENCY_MEMBER_MALFORMED = "frequencyMemberMalformed"
    FREQUENCY_MATCH = "candidateFrequencyMatch"
    FLEX_LOCATION = "flexibleLocationReference"
    BOOKING_RULE = "bookingRuleReference"
    BOOKING_RULE_MISSING = "bookingRuleMissingOrAmbiguous"
    BOOKING_RULE_MALFORMED = "bookingRuleMalformed"
    NONORDINARY_PICKUP = "nonordinaryPickupDropOff"
    CONTINUOUS_PICKUP = "continuousPickupBehavior"
    WINDOW_INVALID = "pickupWindowInvalidCombination"
    FLEX_STRUCTURE_INVALID = "flexStructureInvalid"
    FLEX_REFERENCE_INVALID = "flexReferenceInvalid"
    OCCURRENCE_PROFILE_MISMATCH = "occurrenceProfileMismatch"
    OCCURRENCE_COUNT_MISMATCH = "occurrenceCountMismatch"
    FIELD_SEMANTICS = "fieldSemanticsInsufficient"
    ROUTE_MISSING_OR_AMBIGUOUS = "routeMissingOrAmbiguous"
    BOOKING_ONLY = "bookingRuleReference"
    CONTINUOUS_ONLY = "continuousPickupBehavior"


@dataclass(frozen=True)
class Result:
    candidate_found: bool
    trips_row_exact_match_count: int
    occurrence_count: int
    service_association_present: bool
    route_association_present: bool
    matching_frequency_row_count: int
    flexible_indicator_count: int
    exact_key_status: str
    frequency_status: Status
    flexible_status: Status
    applicability: Disposition
    reasons: tuple

    def aggregate(self):
        return {
            "candidateFound": self.candidate_found,
            "tripsRowExactMatchCount": self.trips_row_exact_match_count,
            "occurrenceCount": self.occurrence_count,
            "serviceAssociationPresent": self.service_association_present,
            "routeAssociationPresent": self.route_association_present,
            "matchingFrequencyRowCount": self.matching_frequency_row_count,
            "flexibleIndicatorCount": self.flexible_indicator_count,
            "exactKeyUniqueness": self.exact_key_status,
            "frequencyStatus": self.frequency_status.value,
            "flexibleStatus": self.flexible_status.value,
            "applicability": self.applicability.value,
            "reasons": [x.value for x in self.reasons],
        }


class _Held(Exception):
    def __init__(self, reason):
        self.reason = reason


def _csv(data, required, max_rows=MAX_ROWS):
    """Use the nomination reader's strict scalar-preserving CSV tokenizer."""
    records = n._records(data)
    first = next(records, None)
    if first is None:
        raise _Held(Reason.MEMBER_MALFORMED)
    header = first[0]
    if (any(not x for x in header) or len(set(header)) != len(header)
            or any(x not in header for x in required)):
        raise _Held(Reason.MEMBER_MALFORMED)
    rows = []
    for index, (values, _, _) in enumerate(records):
        if index >= max_rows or len(values) != len(header):
            raise _Held(Reason.MEMBER_MALFORMED)
        rows.append(dict(zip(header, values)))
    return header, rows


def _member(file, size, name, required=False):
    try:
        info, boundary = n._directory(file, size, name)
    except n.NominationError as exc:
        if not required and exc.code == n.Code.INVALID_MEMBERS:
            return None
        raise _Held(Reason.MEMBER_MALFORMED) from None
    try:
        return n._read_member(file, info, boundary, name.encode("ascii"), MAX_MEMBER_BYTES)
    except n.NominationError:
        raise _Held(Reason.MEMBER_MALFORMED) from None


def _archive_members(file, size):
    file.seek(0)
    try:
        with zipfile.ZipFile(file, "r") as archive:
            names = [i.filename for i in archive.infolist()]
    except (zipfile.BadZipFile, OSError):
        raise _Held(Reason.MEMBER_MALFORMED) from None
    return set(names)


def _time_shape(value):
    return bool(TIME_SHAPE.fullmatch(value))


def _booking_targets(data, wanted):
    _, rows = _csv(data, ("booking_rule_id", "booking_type"))
    found = {}
    integer_fields = ("prior_notice_duration_min", "prior_notice_duration_max",
                      "prior_notice_last_day", "prior_notice_start_day")
    time_fields = ("prior_notice_last_time", "prior_notice_start_time")
    for row in rows:
        key = row["booking_rule_id"]
        if not key:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if key not in wanted:
            continue
        if key in found:
            raise _Held(Reason.BOOKING_RULE_MISSING)
        typ = row["booking_type"]
        if typ not in ("0", "1", "2"):
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        values = {field: row.get(field, "") for field in integer_fields + time_fields}
        for field in integer_fields:
            value = values[field]
            if value and (not value.isascii() or not value.isdigit()):
                raise _Held(Reason.BOOKING_RULE_MALFORMED)
        for field in time_fields:
            value = values[field]
            if value and not _time_shape(value):
                raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if typ == "1":
            if not values["prior_notice_duration_min"]:
                raise _Held(Reason.BOOKING_RULE_MALFORMED)
        elif values["prior_notice_duration_min"]:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if typ in ("0", "2") and values["prior_notice_duration_max"]:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if typ == "2":
            if not values["prior_notice_last_day"]:
                raise _Held(Reason.BOOKING_RULE_MALFORMED)
        elif values["prior_notice_last_day"]:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if bool(values["prior_notice_last_day"]) != bool(values["prior_notice_last_time"]):
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        start_day = values["prior_notice_start_day"]
        start_time = values["prior_notice_start_time"]
        if bool(start_day) != bool(start_time):
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if typ == "0" and start_day:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        if typ == "1" and values["prior_notice_duration_max"] and start_day:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        service_id = row.get("prior_notice_service_id", "")
        if typ != "2" and service_id:
            raise _Held(Reason.BOOKING_RULE_MALFORMED)
        # For type 2, service_id remains opaque. Calendar interpretation and
        # referential checking are explicitly outside this untimed verifier.
        found[key] = True
    if set(found) != wanted:
        raise _Held(Reason.BOOKING_RULE_MISSING)


def _coordinate_structure(geometry):
    """Check polygon array/ring structure only, not geometric topology."""
    coordinates = geometry.get("coordinates")
    if not isinstance(coordinates, list) or not coordinates:
        return False
    polygons = [coordinates] if geometry["type"] == "Polygon" else coordinates
    for polygon in polygons:
        if not isinstance(polygon, list) or not polygon:
            return False
        for ring in polygon:
            if not isinstance(ring, list) or len(ring) < 4:
                return False
            for position in ring:
                if (not isinstance(position, list) or len(position) < 2
                        or any(type(value) not in (int, float) or not math.isfinite(value)
                               for value in position)):
                    return False
            if ring[0] != ring[-1]:
                return False
    return True


def _location_targets(names, file, size, group_ids, location_ids):
    if group_ids:
        if "location_groups.txt" not in names:
            raise _Held(Reason.FLEX_REFERENCE_INVALID)
        data = _member(file, size, "location_groups.txt", True)
        _, rows = _csv(data, ("location_group_id",))
        keys = [r["location_group_id"] for r in rows]
        if any(not x for x in keys) or len(keys) != len(set(keys)):
            raise _Held(Reason.FLEX_REFERENCE_INVALID)
        if not group_ids.issubset(set(keys)):
            raise _Held(Reason.FLEX_REFERENCE_INVALID)
    if location_ids:
        if "locations.geojson" not in names:
            raise _Held(Reason.FLEX_REFERENCE_INVALID)
        raw = _member(file, size, "locations.geojson", True)
        try:
            obj = json.loads(raw.decode("utf-8"))
            if obj.get("type") != "FeatureCollection" or not isinstance(obj.get("features"), list):
                raise ValueError()
            ids = []
            for feature in obj["features"]:
                if (not isinstance(feature, dict) or feature.get("type") != "Feature"
                        or not isinstance(feature.get("properties"), dict)
                        or not isinstance(feature.get("geometry"), dict)
                        or feature["geometry"].get("type") not in ("Polygon", "MultiPolygon")
                        or not _coordinate_structure(feature["geometry"])):
                    raise ValueError()
                ids.append(feature["id"])
            if any(not isinstance(x, str) or not x for x in ids) or len(ids) != len(set(ids)):
                raise ValueError()
        except (UnicodeError, ValueError, TypeError, KeyError, AttributeError, OverflowError):
            raise _Held(Reason.FLEX_REFERENCE_INVALID) from None
        if not location_ids.issubset(set(ids)):
            raise _Held(Reason.FLEX_REFERENCE_INVALID)


def _evaluate(file, size, label, expected_count):
    names = _archive_members(file, size)
    trips_data = _member(file, size, "trips.txt", True)
    try:
        _, trip_rows = _csv(trips_data, ("trip_id", "route_id", "service_id"))
    except _Held:
        raise _Held(Reason.TRIPS_ROW_MALFORMED)
    selected_trip_rows = [r for r in trip_rows if r.get("trip_id", "")]
    candidate_row = next((r for i, r in enumerate(selected_trip_rows[:10], 1) if "N%02d" % i == label), None)
    if candidate_row is None:
        raise _Held(Reason.CANDIDATE_MISSING)
    if not candidate_row["service_id"]:
        raise _Held(Reason.MISSING_SERVICE)
    if not candidate_row["route_id"]:
        raise _Held(Reason.MISSING_ROUTE)
    try:
        source = o._selected_trip(trips_data, "", label)
    except n.NominationError as exc:
        reason = Reason.DUPLICATE_EXACT_KEY if exc.code == o.Code.AMBIGUOUS_JOIN else Reason.CANDIDATE_MISSING
        raise _Held(reason) from None
    exact_count = sum(1 for row in trip_rows if row["trip_id"] == source.trip_id)
    # _selected_trip validates the complete table and exact scalar key count.
    if exact_count != 1:
        raise _Held(Reason.DUPLICATE_EXACT_KEY)
    if not source.service_id:
        raise _Held(Reason.MISSING_SERVICE)
    if not source.route_id:
        raise _Held(Reason.MISSING_ROUTE)

    route_data = _member(file, size, "routes.txt", True)
    _, routes = _csv(route_data, ("route_id",))
    route_rows = [r for r in routes if r["route_id"] == source.route_id]
    if len(route_rows) != 1:
        raise _Held(Reason.ROUTE_MISSING_OR_AMBIGUOUS)
    route = route_rows[0]
    continuous_fields = ("continuous_pickup", "continuous_drop_off")
    route_modes = {}
    for field in continuous_fields:
        value = route.get(field, "")
        if value not in ("", "0", "1", "2", "3"):
            raise _Held(Reason.FIELD_SEMANTICS)
        route_modes[field] = "1" if value == "" else value

    stop_data = _member(file, size, "stop_times.txt", True)
    _, all_stops = _csv(stop_data, ("trip_id", "stop_sequence"))
    selected = [row for row in all_stops if row["trip_id"] == source.trip_id]
    route_trip_ids = {row["trip_id"] for row in trip_rows if row["route_id"] == source.route_id}
    if len(selected) != expected_count or not selected:
        raise _Held(Reason.OCCURRENCE_COUNT_MISMATCH)
    sequences = []
    for row in selected:
        seq = row["stop_sequence"]
        if not seq.isascii() or not seq.isdigit():
            raise _Held(Reason.MEMBER_MALFORMED)
        key = seq.lstrip("0") or "0"
        if key in sequences:
            raise _Held(Reason.MEMBER_MALFORMED)
        if row.get("trip_id") == source.trip_id:
            sequences.append(key)
    if sequences != sorted(sequences, key=lambda x: (len(x), x)):
        raise _Held(Reason.MEMBER_MALFORMED)

    frequencies = 0
    if "frequencies.txt" in names:
        freq_data = _member(file, size, "frequencies.txt", True)
        _, freq_rows = _csv(freq_data, ("trip_id",))
        matching = [r for r in freq_rows if r["trip_id"] == source.trip_id]
        for row in matching:
            if not all(row.get(x, "") for x in ("start_time", "end_time", "headway_secs")):
                raise _Held(Reason.FREQUENCY_MEMBER_MALFORMED)
            if (not _time_shape(row["start_time"]) or not _time_shape(row["end_time"])
                    or not row["headway_secs"].isascii() or not row["headway_secs"].isdigit()
                    or int(row["headway_secs"]) <= 0):
                raise _Held(Reason.FREQUENCY_MEMBER_MALFORMED)
            exact = row.get("exact_times", "")
            if exact not in ("", "0", "1"):
                raise _Held(Reason.FREQUENCY_MEMBER_MALFORMED)
        if matching and len({r["start_time"] for r in matching}) != len(matching):
            raise _Held(Reason.FREQUENCY_MEMBER_MALFORMED)
        frequencies = len(matching)

    booking_ids = set()
    group_ids = set()
    location_ids = set()
    flexible_count = 0
    excluded = False
    for index, row in enumerate(selected):
        # The accepted Passenger dependency is explicit 0/0. Other valid
        # GTFS pickup/drop-off modes conflict with that profile; unknown codes hold.
        for field in ("pickup_type", "drop_off_type"):
            value = row.get(field, "")
            if value not in ("", "0", "1", "2", "3"):
                raise _Held(Reason.FIELD_SEMANTICS)
            if value in ("1", "2", "3"):
                excluded = True
                flexible_count += 1
            elif value != "0":
                raise _Held(Reason.OCCURRENCE_PROFILE_MISMATCH)

        group = row.get("location_group_id", "")
        location = row.get("location_id", "")
        start = row.get("start_pickup_drop_off_window", "")
        end = row.get("end_pickup_drop_off_window", "")
        stop = row.get("stop_id", "")
        if (group and location) or ((group or location) and stop):
            raise _Held(Reason.FLEX_STRUCTURE_INVALID)
        if sum(bool(value) for value in (stop, group, location)) != 1:
            raise _Held(Reason.FLEX_STRUCTURE_INVALID)
        if bool(start) != bool(end):
            raise _Held(Reason.WINDOW_INVALID)
        has_window = bool(start and end)
        if has_window:
            if not _time_shape(start) or not _time_shape(end):
                raise _Held(Reason.WINDOW_INVALID)
            if row.get("arrival_time", "") or row.get("departure_time", ""):
                raise _Held(Reason.WINDOW_INVALID)
            if row.get("pickup_type", "") in ("0", "3") or row.get("drop_off_type", "") == "0":
                raise _Held(Reason.WINDOW_INVALID)
            flexible_count += 1
            excluded = True
        if (group or location) and not has_window:
            raise _Held(Reason.WINDOW_INVALID)
        if group:
            group_ids.add(group)
        if location:
            location_ids.add(location)
        pickup_rule = row.get("pickup_booking_rule_id", "")
        drop_rule = row.get("drop_off_booking_rule_id", "")
        if pickup_rule:
            booking_ids.add(pickup_rule); flexible_count += 1; excluded = True
        if drop_rule:
            booking_ids.add(drop_rule); flexible_count += 1; excluded = True

        # Continuous behavior is defined only from this stop to the next.
        # Validate enum and window compatibility even at the terminal row;
        # do not create an outgoing interval after the final occurrence.
        effective = {}
        for field in continuous_fields:
            value = row.get(field, "")
            if value not in ("", "0", "1", "2", "3"):
                raise _Held(Reason.FIELD_SEMANTICS)
            if has_window and value not in ("", "1"):
                raise _Held(Reason.WINDOW_INVALID)
            effective[field] = route_modes[field] if value == "" else value
        # Continuous pickup/drop-off applies only when the ordinary stop-time
        # event does not independently define passenger service at this stop.
        if index < len(selected) - 1:
            mode = effective["continuous_pickup"]
            if mode in ("0", "2", "3"):
                excluded = True
                flexible_count += 1
        if index < len(selected) - 1:
            mode = effective["continuous_drop_off"]
            if mode in ("0", "2", "3"):
                excluded = True
                flexible_count += 1

    route_windows = any(
        row["trip_id"] in route_trip_ids and
        (row.get("start_pickup_drop_off_window", "") or row.get("end_pickup_drop_off_window", ""))
        for row in all_stops)
    if route_windows and any(mode != "1" for mode in route_modes.values()):
        raise _Held(Reason.WINDOW_INVALID)
    _location_targets(names, file, size, group_ids, location_ids)
    if booking_ids:
        if "booking_rules.txt" not in names:
            raise _Held(Reason.BOOKING_RULE_MISSING)
        _booking_targets(_member(file, size, "booking_rules.txt", True), booking_ids)

    if frequencies:
        excluded = True
    reasons = tuple(([Reason.FREQUENCY_MATCH] if frequencies else []) +
                    ([Reason.FLEX_LOCATION] if group_ids or location_ids or any(
                        r.get("start_pickup_drop_off_window", "") or r.get("pickup_booking_rule_id", "") or
                        r.get("drop_off_booking_rule_id", "") or r.get("pickup_type", "") in ("2", "3") or
                        r.get("drop_off_type", "") in ("2", "3") for r in selected) else []) +
                    ([Reason.BOOKING_ONLY] if booking_ids else []) +
                    ([Reason.CONTINUOUS_ONLY] if any(
                        ((route_modes[f] if selected[i].get(f, "") == "" else selected[i].get(f)) in ("0", "2", "3"))
                        for i in range(len(selected) - 1) for f in continuous_fields) else []) +
                    ([Reason.NONORDINARY_PICKUP] if any(
                        r.get("pickup_type", "") in ("1", "2", "3") or r.get("drop_off_type", "") in ("1", "2", "3") for r in selected) else []))
    return source, exact_count, len(selected), frequencies, flexible_count, excluded, reasons


def assess(path, expected_size, expected_sha256, label, expected_occurrence_count, profile=PROFILE):
    """Assess one explicitly selected synthetic/authorized candidate; never print IDs."""
    if (profile != PROFILE or type(expected_size) is not int or not 0 < expected_size <= n.MAX_ARCHIVE_BYTES
            or type(expected_occurrence_count) is not int or expected_occurrence_count != 14
            or not isinstance(expected_sha256, str) or not re.fullmatch(r"[0-9a-f]{64}", expected_sha256)
            or not isinstance(label, str) or not re.fullmatch(r"N(?:0[1-9]|10)", label)):
        return Result(False, 0, 0, False, False, 0, 0, "notEvaluated", Status.NOT_EVALUATED,
                      Status.NOT_EVALUATED, Disposition.HELD, (Reason.CANDIDATE_MISSING,))
    try:
        with n._parent(path) as (parent, name):
            prior = os.stat(name, dir_fd=parent, follow_symlinks=False)
            if stat.S_ISLNK(prior.st_mode) or not stat.S_ISREG(prior.st_mode):
                raise n.NominationError(n.Code.UNSAFE_PATH)
            fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
        with os.fdopen(fd, "rb", buffering=0) as file:
            initial = os.fstat(file.fileno())
            if initial.st_size != expected_size or n._hash_archive(file, expected_size) != expected_sha256:
                raise _Held(Reason.ARCHIVE_IDENTITY_MISMATCH)
            try:
                data = _evaluate(file, expected_size, label, expected_occurrence_count)
            except _Held as exc:
                raise exc
            if n._hash_archive(file, expected_size) != expected_sha256 or n._state(os.fstat(file.fileno())) != n._state(initial):
                raise n.NominationError(n.Code.INPUT_CHANGED)
            with n._parent(path) as (parent, name):
                if n._state(os.stat(name, dir_fd=parent, follow_symlinks=False)) != n._state(initial):
                    raise n.NominationError(n.Code.INPUT_CHANGED)
            source, exact, count, frequencies, flexible, excluded, reasons = data
            frequency_status = Status.EXCLUDED if frequencies else Status.MATCHED
            flexible_status = Status.EXCLUDED if flexible else Status.MATCHED
            disposition = Disposition.EXCLUDED if excluded else Disposition.ELIGIBLE
            return Result(True, exact, count, bool(source.service_id), bool(source.route_id), frequencies,
                          flexible, "unique", frequency_status, flexible_status, disposition, reasons)
    except _Held as exc:
        disposition = Disposition.HELD
        reason = (Reason.ARCHIVE_IDENTITY_MISMATCH if exc.reason == Reason.ARCHIVE_IDENTITY_MISMATCH else exc.reason)
        return Result(False, 0, 0, False, False, 0, 0, "notEvaluated", Status.NOT_EVALUATED,
                      Status.NOT_EVALUATED, disposition, (reason,))
    except n.NominationError as exc:
        reason = Reason.ARCHIVE_IDENTITY_MISMATCH if exc.code == n.Code.ARCHIVE_IDENTITY else Reason.MEMBER_MALFORMED
        return Result(False, 0, 0, False, False, 0, 0, "notEvaluated", Status.NOT_EVALUATED,
                      Status.NOT_EVALUATED, Disposition.HELD, (reason,))


class EvidenceError(Exception):
    def __init__(self, reason):
        self.reason = reason


def held_result(reason):
    return Result(False, 0, 0, False, False, 0, 0, "notEvaluated", Status.NOT_EVALUATED,
                  Status.NOT_EVALUATED, Disposition.HELD, (reason,))


def read_applicability(path, expected_size, expected_sha256, label, expected_count, profile=PROFILE):
    """Typed in-memory outcome for one explicitly selected candidate."""
    if (type(expected_size) is not int or expected_size <= 0 or expected_size > n.MAX_ARCHIVE_BYTES
            or not isinstance(expected_sha256, str) or not re.fullmatch(r"[0-9a-f]{64}", expected_sha256)
            or not isinstance(label, str) or not re.fullmatch(r"N(?:0[1-9]|10)", label)
            or expected_count != 14 or profile != PROFILE):
        raise EvidenceError(Reason.CANDIDATE_MISSING)
    result = assess(path, expected_size, expected_sha256, label, expected_count, profile)
    if result.applicability == Disposition.HELD:
        raise EvidenceError(result.reasons[0] if result.reasons else Reason.MEMBER_MALFORMED)
    return result


def main(argv=None):
    parser = _Arguments(description="Memory-only trip source-profile applicability review.", allow_abbrev=False)
    parser.add_argument("--archive", required=True)
    parser.add_argument("--expected-size", type=int, required=True)
    parser.add_argument("--expected-sha256", required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--expected-count", "--expected-occurrence-count", dest="expected_count", type=int, required=True)
    parser.add_argument("--profile", required=True)
    try:
        args = parser.parse_args(argv)
        with _Terminal() as terminal:
            result = assess(args.archive, args.expected_size, args.expected_sha256, args.label,
                            args.expected_count, args.profile)
            terminal.write(json.dumps(result.aggregate(), sort_keys=True) + "\n")
            return 0 if result.applicability == Disposition.ELIGIBLE else 1
    except n.NominationError as exc:
        print("applicability failed: " + exc.code.value, file=sys.stderr)
    except SessionError:
        print("applicability failed: localTerminalRequired", file=sys.stderr)
    except EvidenceError as exc:
        print("applicability failed: " + exc.reason.value, file=sys.stderr)
    except Exception:
        print("applicability failed: internalError", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
