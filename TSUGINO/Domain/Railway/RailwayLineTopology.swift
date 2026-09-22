// Canonical undirected adjacent-station topology of a line (DEC-057 D1, D3,
// D4, ARCHITECTURE.md §5.2.1).
//
// A line owns only which of its stations are directly adjacent. Direction,
// order, traversal, repeated visits, and stopping patterns belong to `Trip`
// (DEC-055, DEC-057 D10); display order and provider station numbering are
// mapping-layer data. The value therefore carries no paths, segments, branch
// or path identifiers, closure flags, direction, terminals, station order,
// transfer edges, weights, or display metadata, and it imports nothing.
//
// Cycles, junctions of any degree, branches, loop-plus-tail shapes, and
// multiple routes between two stations are all ordinary graphs here; no
// launch-line, regional, degree, size, or planarity rule exists (DEC-057 D7,
// D8). Connectedness is checked as an internal invariant only — there is no
// neighbours, path-search, or other graph API (DEC-057 D11, D12).

/// An undirected simple connected graph of station adjacencies.
///
/// `adjacencies` is the stored canonical state. Membership is derived from
/// it and never stored or encoded, so an orphan station is unrepresentable.
/// Equality and hashing are complete-value over the adjacency set; the value
/// has no identifier. Insertion order and encoded element order carry no
/// meaning.
nonisolated struct RailwayLineTopology: Hashable, Codable, Sendable {
    let adjacencies: Set<StationAdjacency>

    /// Fails when the set is empty or the graph it forms is not connected.
    /// Each adjacency already guarantees two distinct stations, and the `Set`
    /// already collapses duplicates, so those need no further check here.
    init?(adjacencies: Set<StationAdjacency>) {
        guard !adjacencies.isEmpty, Self.isConnected(adjacencies) else { return nil }
        self.adjacencies = adjacencies
    }

    /// Every station that appears in any adjacency — the line's membership,
    /// derived rather than stored (DEC-057 D12).
    var stationIDs: Set<StationID> {
        adjacencies.reduce(into: []) { $0.formUnion($1.stationIDs) }
    }

    /// Whether every station reachable through the adjacencies forms one
    /// component. Internal validation only, not a traversal API: a breadth-
    /// first walk from an arbitrary station over an adjacency map built for
    /// the purpose. Deterministic in result regardless of set iteration order.
    private static func isConnected(_ adjacencies: Set<StationAdjacency>) -> Bool {
        var neighbours: [StationID: Set<StationID>] = [:]
        for adjacency in adjacencies {
            for station in adjacency.stationIDs {
                neighbours[station, default: []].formUnion(adjacency.stationIDs.subtracting([station]))
            }
        }

        guard let start = neighbours.keys.first else { return false }

        var visited: Set<StationID> = [start]
        var frontier: [StationID] = [start]
        while let current = frontier.popLast() {
            for next in neighbours[current, default: []] where visited.insert(next).inserted {
                frontier.append(next)
            }
        }

        return visited.count == neighbours.count
    }
}

extension RailwayLineTopology {
    private enum CodingKeys: String, CodingKey {
        case adjacencies
    }

    /// Decodes with exactly the same validity rule as direct construction.
    /// Each element is decoded through `StationAdjacency`, so an invalid
    /// nested adjacency fails there; a missing key or a wrong type keeps its
    /// normal keyed-container error. Repeated encoded adjacencies collapse
    /// under `Set` semantics — multiplicity has no meaning — and the resulting
    /// graph must still be non-empty and connected, or decoding fails with
    /// `dataCorrupted`. The derived `stationIDs` is never encoded or decoded.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let topology = Self(
            adjacencies: try container.decode(Set<StationAdjacency>.self, forKey: .adjacencies)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath + [CodingKeys.adjacencies],
                    debugDescription: "A railway line topology must be a non-empty, connected set of station adjacencies."
                )
            )
        }

        self = topology
    }
}
