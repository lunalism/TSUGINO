// A stated change of station on foot within a Journey (DEC-062 D,
// ARCHITECTURE.md §5.5).
//
// Structural validity means only that the walk is **stated**. It never claims
// that a pedestrian connection exists, whether it is inside or outside fare
// gates, its accessibility, its length, or its duration. Verifying the
// connection is Phase 2 dataset validation; walking time, route, and exits are
// Phase 10 transfer guidance (ARCHITECTURE.md §14). No surface may present a
// stated walk as a verified connection.

/// A walk between two distinct canonical stations.
nonisolated struct WalkingTransfer: Hashable, Codable, Sendable {
    let fromStationID: StationID
    let toStationID: StationID

    /// Fails when both ends are the same station: a same-station transfer
    /// needs no walking leg (DEC-062 D1).
    init?(fromStationID: StationID, toStationID: StationID) {
        guard fromStationID != toStationID else { return nil }

        self.fromStationID = fromStationID
        self.toStationID = toStationID
    }
}

extension WalkingTransfer {
    private enum CodingKeys: String, CodingKey {
        case fromStationID, toStationID
    }

    /// Decodes with exactly the same rule as direct construction.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let walk = Self(
            fromStationID: try container.decode(StationID.self, forKey: .fromStationID),
            toStationID: try container.decode(StationID.self, forKey: .toStationID)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A walking transfer must connect two different stations."
                )
            )
        }

        self = walk
    }
}
