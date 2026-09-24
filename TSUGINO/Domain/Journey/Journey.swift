// A passenger's route definition (DEC-062, ARCHITECTURE.md §5.4).
//
// `Journey` is identity and its legs in order — nothing that changes as the
// ride progresses. Current leg, phase, freshness, and interruption are
// `JourneyState` (§5.6, slice S5b); progression, binding, and replacement are
// Phase 5 (DEC-011, DEC-050); timestamps and persistence are Phase 6. Origin
// and destination are not stored: they are the first leg's start and the last
// leg's end.

/// A route definition made of rail legs and stated walks, identified by its
/// canonical `JourneyID`.
///
/// **Identity is the ID alone (DEC-062 B).** Equality and hashing use only
/// `id`; `legs` is descriptive, and because legs are deliberately not
/// `Equatable`, `Codable` and actor-transfer tests compare their contents
/// explicitly.
nonisolated struct Journey: Codable, Sendable {
    let id: JourneyID

    /// The legs in travel order, addressed by position.
    let legs: [JourneyLeg]

    /// Fails unless every DEC-062 E invariant holds:
    ///
    /// 1. at least one leg, and the first and last legs are rail legs;
    /// 2. each leg ends at the station where the next begins;
    /// 3. no two consecutive walking legs;
    /// 4. no two selected rail legs share a `TripID`, whatever lies between
    ///    them — unselected legs do not count.
    ///
    /// Each leg's own rules are enforced by its value types, so they are not
    /// repeated here. An all-unselected Journey is valid; readiness to track is
    /// S5b / Phase 5.
    init?(id: JourneyID, legs: [JourneyLeg]) {
        guard
            Self.hasRailLegsAtBothEnds(legs),
            Self.isContinuous(legs),
            Self.hasNoConsecutiveWalks(legs),
            Self.hasUniqueSelectedTripIDs(legs)
        else { return nil }

        self.id = id
        self.legs = legs
    }

    /// Non-empty, beginning at a boarding station and ending at an alighting
    /// station (DEC-062 E1, E3).
    private static func hasRailLegsAtBothEnds(_ legs: [JourneyLeg]) -> Bool {
        guard let first = legs.first, let last = legs.last else { return false }

        return first.isRail && last.isRail
    }

    /// Compares canonical `StationID`s only (DEC-062 E2). Whether a real
    /// transfer path exists between two legs is Phase 2 / Phase 10.
    private static func isContinuous(_ legs: [JourneyLeg]) -> Bool {
        !zip(legs, legs.dropFirst()).contains { previous, next in
            previous.endStationID != next.startStationID
        }
    }

    /// A walk from A to C is one leg; Phase 1 has no pathway model that could
    /// justify an intermediate station (DEC-062 E4).
    private static func hasNoConsecutiveWalks(_ legs: [JourneyLeg]) -> Bool {
        !zip(legs, legs.dropFirst()).contains { previous, next in
            !previous.isRail && !next.isRail
        }
    }

    /// Journey-wide `TripID` uniqueness across selected rail legs
    /// (DEC-062 E5).
    ///
    /// A conservative structural rule: a `TripID` is a recurring run
    /// (DEC-060 A) and the Journey stores no service date or execution
    /// identity, so a second occurrence cannot be told apart from one ride
    /// cut into a fake transfer or backward travel through one run. It does
    /// not claim that riding the same recurring run twice is impossible;
    /// allowing reuse needs a later decision that adds such an identity.
    private static func hasUniqueSelectedTripIDs(_ legs: [JourneyLeg]) -> Bool {
        var seen: Set<TripID> = []

        for leg in legs {
            guard case .rail(.selected(let selection)) = leg else { continue }
            guard seen.insert(selection.trip.id).inserted else { return false }
        }

        return true
    }
}

private extension JourneyLeg {
    nonisolated var isRail: Bool {
        if case .rail = self { true } else { false }
    }
}

extension Journey: Hashable {
    // Written out rather than synthesised: identity is the `JourneyID` alone
    // (DEC-062 B), and legs are deliberately not `Equatable`.

    static func == (lhs: Journey, rhs: Journey) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Journey {
    private enum CodingKeys: String, CodingKey {
        case id, legs
    }

    /// Decodes with exactly the same rules as direct construction, so a
    /// decoded Journey can never be one `init` would have rejected. Legs fail
    /// through their own decoders; a missing key or wrong type keeps its
    /// normal keyed-container error.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let journey = Self(
            id: try container.decode(JourneyID.self, forKey: .id),
            legs: try container.decode([JourneyLeg].self, forKey: .legs)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A journey must have rail legs at both ends, continuous stations between legs, no consecutive walking legs, and no TripID selected twice."
                )
            )
        }

        self = journey
    }
}
