// One undirected adjacency between two stations on a line (DEC-057 D2,
// ARCHITECTURE.md §5.2.1).
//
// A provider-neutral Domain value, not a canonical entity: it has no
// identifier and no direction, distance, duration, track, platform,
// operator, line, provider, or transfer metadata. It is deliberately an
// *adjacency*, not a *connection*, so it cannot be mistaken for a transfer or
// interchange relationship (DEC-048, Rule 16). It imports nothing.

/// Two distinct canonical stations that are directly adjacent on a line.
///
/// The pair is unordered: `(a, b)` and `(b, a)` are the same value, compare
/// equal, and hash identically, which the two-element `Set` makes structural
/// rather than validated. A self-adjacency `(a, a)` names nothing and is
/// rejected. Equality and hashing are complete-value (DEC-057 D2).
nonisolated struct StationAdjacency: Hashable, Codable, Sendable {
    /// Exactly two distinct station identifiers.
    let stationIDs: Set<StationID>

    /// Fails when both arguments are the same station; otherwise stores the
    /// unordered pair. Argument order has no meaning.
    init?(_ first: StationID, _ second: StationID) {
        guard first != second else { return nil }
        self.stationIDs = [first, second]
    }
}

extension StationAdjacency {
    private enum CodingKeys: String, CodingKey {
        case stationIDs
    }

    /// Decodes with exactly the same validity rule as direct construction: a
    /// decoded value can never be one `init` would have rejected. Each element
    /// is decoded through `StationID`, so a blank identifier fails there; a
    /// missing key or a wrong type keeps its normal keyed-container error.
    /// The remaining rule — exactly two *distinct* identifiers — is applied
    /// after set collapse, so zero, one, duplicate-only, or more than two
    /// elements are reported as `dataCorrupted`. Element order is not a
    /// contract.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stationIDs = try container.decode(Set<StationID>.self, forKey: .stationIDs)

        guard stationIDs.count == 2 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath + [CodingKeys.stationIDs],
                    debugDescription: "A station adjacency must name exactly two distinct stations."
                )
            )
        }

        self.stationIDs = stationIDs
    }
}
