// One recurring canonical scheduled run (DEC-060, ARCHITECTURE.md §5.3).
//
// `Trip` is identity, an ordered passenger-stop traversal, the canonical lines
// that traversal runs on, and what the traversal covers — nothing else. It
// carries no provider reference, identifier, or code (Rule 9, DEC-021 — those
// are mapping-layer aliases, §40), no operator (a line's operator is not proof
// of who runs a given service, DEC-060 D), no service brand or class (S4b), no
// schedule, calendar, direction, destination, or headsign (DEC-060 F, G).
//
// What a Trip identifies: **one recurring canonical scheduled run
// definition** — not one dated physical run, and not a bare stopping-pattern
// template. Two separately published departures are different Trips even with
// identical structure, so a Trip is never deduplicated by structural equality;
// a corrected traversal, segment list, or coverage for the same logical run
// keeps its `TripID`. Matching provider records to logical runs is Phase 2
// mapping and provenance work. A particular dated execution, its calendar,
// cancellation, delay, and live progress belong to later schedule, realtime,
// and Journey contracts (DEC-011, DEC-050).

/// A concrete recurring train service, identified by its canonical `TripID`.
///
/// **Identity is the ID alone (DEC-060 A).** Equality and hashing use only
/// `id`, so a corrected traversal is the same Trip: descriptive data changes
/// for editorial or data-quality reasons and must not make a stored value
/// denote a different service. Because of that, `Codable` and actor-transfer
/// tests must compare the structural properties explicitly.
nonisolated struct Trip: Codable, Sendable {
    let id: TripID

    /// The ordered **passenger stops** of this run (DEC-060 B).
    ///
    /// Stops only: a station the service passes without stopping is simply
    /// absent, which is how an express or limited-stop pattern is expressed —
    /// so consecutive entries need not be adjacent in `RailwayLineTopology`
    /// (DEC-057 D10). A station may recur at non-adjacent positions, which is
    /// what makes a loop-plus-tail run representable; an individual visit is
    /// addressed by its **index**, the only unambiguous address once a station
    /// repeats.
    let stopSequence: [StationID]

    /// The canonical lines this run traverses, in traversal order (DEC-060 C).
    ///
    /// Consecutive segments meet at one shared boundary stop, together cover
    /// the whole traversal, and never repeat a line back to back. A multi-line
    /// through service is therefore several segments over one traversal — one
    /// Trip, not a transfer (DEC-009, Rule 16).
    let lineSegments: [TripLineSegment]

    /// What the represented traversal covers of the real service (DEC-060 C2).
    ///
    /// `stopSequence.first` is the service's actual origin only when
    /// `coverage.includesServiceOrigin` is true, and `stopSequence.last` its
    /// actual destination only when `coverage.includesServiceDestination` is
    /// true. A genuine short-turn and a partial representation ending at the
    /// same station are therefore different states, and no consumer may treat
    /// them alike (DEC-038, Rule 50).
    let coverage: TripCoverage

    /// Fails unless the traversal and its segments satisfy every rule in
    /// DEC-060 B and C. Never traps: each index is compared against the stop
    /// count before anything is used to address the collection, and no
    /// arithmetic is performed on a decoded index, so an arbitrary payload
    /// cannot overflow or form an invalid range.
    ///
    /// `TripID`, each `StationID` and `LineID`, every `TripLineSegment`, and
    /// `TripCoverage` each enforce their own rule, so this initialiser repeats
    /// none of them; it enforces only what needs the whole value.
    init?(
        id: TripID,
        stopSequence: [StationID],
        lineSegments: [TripLineSegment],
        coverage: TripCoverage
    ) {
        guard
            Self.isValidStopSequence(stopSequence),
            Self.isValidSegmentList(lineSegments, coveringStopCount: stopSequence.count)
        else { return nil }

        self.id = id
        self.stopSequence = stopSequence
        self.lineSegments = lineSegments
        self.coverage = coverage
    }

    /// At least two represented stops, and no station immediately repeated.
    ///
    /// A run with fewer than two passenger stops carries nobody anywhere, and
    /// the same station twice in a row describes no movement. Repeats at
    /// non-adjacent positions are deliberately permitted, so there is no
    /// whole-sequence uniqueness rule.
    private static func isValidStopSequence(_ stopSequence: [StationID]) -> Bool {
        guard stopSequence.count >= 2 else { return false }

        return !zip(stopSequence, stopSequence.dropFirst()).contains { $0 == $1 }
    }

    /// Non-empty, in range, joined at exactly one shared endpoint each, fully
    /// covering the traversal, and never repeating a line back to back.
    ///
    /// The join rule `next.startIndex == previous.endIndex` is the whole
    /// continuity check: with each segment's own `startIndex < endIndex`, it
    /// makes ranges strictly progress, so a gap, an overlap wider than the
    /// shared endpoint, a nested range, a duplicate range, and any
    /// non-progressing order are all excluded without adding to or
    /// subtracting from a decoded index.
    private static func isValidSegmentList(
        _ segments: [TripLineSegment],
        coveringStopCount stopCount: Int
    ) -> Bool {
        guard let first = segments.first, let last = segments.last else { return false }
        guard first.startIndex == 0, last.endIndex == stopCount - 1 else { return false }

        return !zip(segments, segments.dropFirst()).contains { previous, next in
            next.startIndex != previous.endIndex || next.lineID == previous.lineID
        }
    }
}

extension Trip: Hashable {
    // Written out rather than synthesised: synthesis would fold the traversal,
    // the segments, and the coverage into identity, which is precisely what
    // DEC-060 rules out — and it would make two separately published
    // departures with identical structure the same Trip.

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Trip {
    private enum CodingKeys: String, CodingKey {
        case id, stopSequence, lineSegments, coverage
    }

    /// Decodes with exactly the same rules as direct construction, so a
    /// decoded Trip can never be one `init` would have rejected. Nested values
    /// fail through their own decoders — a blank identifier through `TripID`,
    /// `StationID`, or `LineID`, an invalid span through `TripLineSegment` —
    /// and a missing key or wrong type keeps its normal keyed-container error.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let trip = Self(
            id: try container.decode(TripID.self, forKey: .id),
            stopSequence: try container.decode([StationID].self, forKey: .stopSequence),
            lineSegments: try container.decode([TripLineSegment].self, forKey: .lineSegments),
            coverage: try container.decode(TripCoverage.self, forKey: .coverage)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A trip must have at least two stops with no adjacent duplicate, and line segments that are joined, covering, and never repeat a line back to back."
                )
            )
        }

        self = trip
    }
}
