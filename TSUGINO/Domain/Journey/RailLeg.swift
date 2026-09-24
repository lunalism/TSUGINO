// A rail leg's selection state (DEC-062 A, C; ARCHITECTURE.md §5.5).
//
// A leg is either anchored to two stations with no Trip yet, or bound to a
// selected Trip snapshot. Moving from one to the other — and replacing a
// selection — is Phase 5 behaviour (DEC-050); this type only states which
// case holds. Not `Equatable` (DEC-062 B).

/// Whether a rail leg has a selected Trip.
nonisolated enum RailLeg: Codable, Sendable {
    /// Boarding and alighting stations only; no Trip has been selected.
    case unselected(RailLegAnchors)

    /// A selected Trip snapshot with boarding and alighting indices.
    case selected(SelectedRailTrip)

    /// The station this leg boards at.
    var startStationID: StationID {
        switch self {
        case .unselected(let anchors): anchors.boardingStationID
        case .selected(let selection): selection.boardingStationID
        }
    }

    /// The station this leg alights at.
    var endStationID: StationID {
        switch self {
        case .unselected(let anchors): anchors.alightingStationID
        case .selected(let selection): selection.alightingStationID
        }
    }
}

extension RailLeg {
    // One keyed pattern shared with `JourneyLeg` (DEC-062 F): a `kind`
    // discriminator and exactly one payload key named after the case.
    private enum CodingKeys: String, CodingKey {
        case kind, unselected, selected
    }

    private enum Kind: String {
        case unselected, selected
    }

    /// Rejects a missing `kind` (`keyNotFound`), an unknown `kind`
    /// (`dataCorrupted`), a payload key of the other case (`dataCorrupted`,
    /// checked before the next rule), and a missing payload for the named
    /// case (`keyNotFound`). Nested values fail through their own decoders.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawKind = try container.decode(String.self, forKey: .kind)

        guard let kind = Kind(rawValue: rawKind) else {
            throw DecodingError.dataCorruptedError(
                forKey: .kind,
                in: container,
                debugDescription: "Unknown rail leg kind \(rawKind.debugDescription)."
            )
        }

        switch kind {
        case .unselected:
            try Self.rejectContradictoryPayload(.selected, in: container)
            self = .unselected(try container.decode(RailLegAnchors.self, forKey: .unselected))
        case .selected:
            try Self.rejectContradictoryPayload(.unselected, in: container)
            self = .selected(try container.decode(SelectedRailTrip.self, forKey: .selected))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .unselected(let anchors):
            try container.encode(Kind.unselected.rawValue, forKey: .kind)
            try container.encode(anchors, forKey: .unselected)
        case .selected(let selection):
            try container.encode(Kind.selected.rawValue, forKey: .kind)
            try container.encode(selection, forKey: .selected)
        }
    }

    private static func rejectContradictoryPayload(
        _ key: CodingKeys,
        in container: KeyedDecodingContainer<CodingKeys>
    ) throws {
        guard container.contains(key) else { return }

        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "A rail leg carries a payload for a different kind."
        )
    }
}
