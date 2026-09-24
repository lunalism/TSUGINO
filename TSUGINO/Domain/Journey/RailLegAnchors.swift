// The known boarding and alighting stations of a rail leg (DEC-062 C,
// ARCHITECTURE.md §5.5).
//
// An unselected rail leg is exactly these two stations — the user's choice
// (DEC-047) or, later, a route-search result. There is deliberately no Trip,
// stop index, time, or route here: those do not exist until a Trip is
// selected, so none of them can be invented.
//
// Anchors carry only canonical identifiers, so complete-value equality is
// truthful (DEC-062 B). They import nothing.

/// The boarding and alighting stations a rail leg is anchored to.
nonisolated struct RailLegAnchors: Hashable, Codable, Sendable {
    let boardingStationID: StationID
    let alightingStationID: StationID

    /// Fails when both ends are the same station: a leg that ends where it
    /// began carries the rider nowhere (DEC-062 C3).
    init?(boardingStationID: StationID, alightingStationID: StationID) {
        guard boardingStationID != alightingStationID else { return nil }

        self.init(validatedBoarding: boardingStationID, alighting: alightingStationID)
    }

    /// For callers in this file that already hold two distinct stations —
    /// the anchors derived from a `SelectedRailTrip`, whose own invariant
    /// guarantees distinct ends. Keeping it `fileprivate` stops it becoming a
    /// way around the rule above.
    fileprivate init(validatedBoarding boarding: StationID, alighting: StationID) {
        self.boardingStationID = boarding
        self.alightingStationID = alighting
    }

    /// Whether `selection` may become the selected Trip of a leg anchored
    /// here: it must board and alight at exactly these stations
    /// (DEC-062 C4).
    ///
    /// A pure check, nothing more. Selecting a Trip at other stations is a
    /// replan, not a selection; and *performing* a binding — choosing when to
    /// bind, or replacing a leg inside a Journey — is Phase 5 behaviour
    /// (DEC-011, DEC-050).
    func admits(_ selection: SelectedRailTrip) -> Bool {
        selection.anchors == self
    }
}

extension RailLegAnchors {
    private enum CodingKeys: String, CodingKey {
        case boardingStationID, alightingStationID
    }

    /// Decodes with exactly the same rule as direct construction. A missing
    /// key or a wrong type keeps its normal keyed-container error; a blank
    /// identifier fails through `StationID` itself (DEC-051).
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let anchors = Self(
            boardingStationID: try container.decode(StationID.self, forKey: .boardingStationID),
            alightingStationID: try container.decode(StationID.self, forKey: .alightingStationID)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A rail leg's boarding and alighting stations must differ."
                )
            )
        }

        self = anchors
    }
}

extension SelectedRailTrip {
    /// The stations this selection boards and alights at, derived from the
    /// Trip snapshot and never stored a second time (DEC-062 C2).
    nonisolated var anchors: RailLegAnchors {
        RailLegAnchors(validatedBoarding: boardingStationID, alighting: alightingStationID)
    }
}
