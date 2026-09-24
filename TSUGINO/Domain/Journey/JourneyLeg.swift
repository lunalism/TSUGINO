// One position in a Journey's route definition (DEC-062 A, ARCHITECTURE.md
// §5.5).
//
// A leg is a rail ride or a stated walk between stations. It carries no
// planned trip (Phase 3 route search), realtime state (Phase 4 / S5b),
// transfer guidance (Phase 10), or identifier — legs are addressed by
// position in `Journey.legs`. Not `Equatable` (DEC-062 B).

/// A rail leg or a walking transfer within a Journey.
nonisolated enum JourneyLeg: Codable, Sendable {
    case rail(RailLeg)
    case walkingTransfer(WalkingTransfer)

    /// The station this leg begins at (DEC-062 E).
    var startStationID: StationID {
        switch self {
        case .rail(let rail): rail.startStationID
        case .walkingTransfer(let walk): walk.fromStationID
        }
    }

    /// The station this leg ends at (DEC-062 E).
    var endStationID: StationID {
        switch self {
        case .rail(let rail): rail.endStationID
        case .walkingTransfer(let walk): walk.toStationID
        }
    }
}

extension JourneyLeg {
    // One keyed pattern shared with `RailLeg` (DEC-062 F): a `kind`
    // discriminator and exactly one payload key named after the case.
    private enum CodingKeys: String, CodingKey {
        case kind, rail, walkingTransfer
    }

    private enum Kind: String {
        case rail, walkingTransfer
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
                debugDescription: "Unknown journey leg kind \(rawKind.debugDescription)."
            )
        }

        switch kind {
        case .rail:
            try Self.rejectContradictoryPayload(.walkingTransfer, in: container)
            self = .rail(try container.decode(RailLeg.self, forKey: .rail))
        case .walkingTransfer:
            try Self.rejectContradictoryPayload(.rail, in: container)
            self = .walkingTransfer(try container.decode(WalkingTransfer.self, forKey: .walkingTransfer))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .rail(let rail):
            try container.encode(Kind.rail.rawValue, forKey: .kind)
            try container.encode(rail, forKey: .rail)
        case .walkingTransfer(let walk):
            try container.encode(Kind.walkingTransfer.rawValue, forKey: .kind)
            try container.encode(walk, forKey: .walkingTransfer)
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
            debugDescription: "A journey leg carries a payload for a different kind."
        )
    }
}
