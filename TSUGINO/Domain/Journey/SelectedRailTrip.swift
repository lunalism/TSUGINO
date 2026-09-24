// A rail leg's chosen Trip and where the rider boards and alights on it
// (DEC-062 C, ARCHITECTURE.md §5.5).
//
// The Trip is embedded as a snapshot of what the user selected (DEC-007,
// DEC-008). Boarding and alighting are addressed by **index** into its
// `stopSequence`, the only unambiguous address once a Trip visits a station
// more than once (DEC-060 B). The stations are derived from those indices and
// never stored a second time.
//
// Deliberately not `Equatable` (DEC-062 B): `Trip` equality is ID-only, so a
// synthesised comparison would call two different snapshots of the same
// `TripID` equal. Nothing in S5a needs to compare selections. Reconciling a
// snapshot with a later correction of the same Trip is Phase 5 / Phase 6.

/// A selected Trip snapshot with the rider's boarding and alighting stops.
nonisolated struct SelectedRailTrip: Codable, Sendable {
    let trip: Trip
    let boardingIndex: Int
    let alightingIndex: Int

    /// Fails unless `0 <= boardingIndex < alightingIndex <=
    /// trip.stopSequence.count - 1` and the stations at those indices differ
    /// (DEC-062 C2, C3). Never traps: every index is compared against the
    /// stop count before it addresses the collection, and `count - 1` cannot
    /// overflow because a valid Trip has at least two stops.
    init?(trip: Trip, boardingIndex: Int, alightingIndex: Int) {
        guard
            boardingIndex >= 0,
            boardingIndex < alightingIndex,
            alightingIndex <= trip.stopSequence.count - 1,
            trip.stopSequence[boardingIndex] != trip.stopSequence[alightingIndex]
        else { return nil }

        self.trip = trip
        self.boardingIndex = boardingIndex
        self.alightingIndex = alightingIndex
    }

    /// The station at `boardingIndex` in the snapshot.
    var boardingStationID: StationID {
        trip.stopSequence[boardingIndex]
    }

    /// The station at `alightingIndex` in the snapshot.
    var alightingStationID: StationID {
        trip.stopSequence[alightingIndex]
    }
}

extension SelectedRailTrip {
    private enum CodingKeys: String, CodingKey {
        case trip, boardingIndex, alightingIndex
    }

    /// Decodes with exactly the same rules as direct construction. The Trip
    /// fails through its own decoder; arbitrary decoded indices are validated
    /// by `init` before any use as an index.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let selection = Self(
            trip: try container.decode(Trip.self, forKey: .trip),
            boardingIndex: try container.decode(Int.self, forKey: .boardingIndex),
            alightingIndex: try container.decode(Int.self, forKey: .alightingIndex)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A selected rail trip must satisfy 0 <= boardingIndex < alightingIndex <= stop count - 1, with different stations at the two indices."
                )
            )
        }

        self = selection
    }
}
