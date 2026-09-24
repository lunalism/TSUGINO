// A Journey paired with its runtime state (DEC-063 E, ARCHITECTURE.md §5.6).
//
// This is the only place a state's consistency with its Journey is checked.
// It imposes no ordering: which phase may follow which, that legs advance, and
// how any phase is reached are Phase 5 transition rules (DEC-050). A Journey
// whose leg was replaced keeps its `JourneyID` and is simply paired again.
// Not `Codable`: persistence and its format are Phase 6.

/// A Journey and a runtime state that fits it.
nonisolated struct ActiveJourney: Sendable {
    let journey: Journey
    let state: JourneyState

    /// Throws `ActiveJourneyInconsistency` naming the first failed rule,
    /// checked in this order (DEC-063 E):
    ///
    /// 1. the state describes this Journey — `journeyMismatch`;
    /// 2. every leg index in the phase is in range — `legIndexOutOfRange`;
    /// 3. each phase points at the right kind of leg — `legKindMismatch`;
    /// 4. riding needs a selected leg, and waiting for the first leg needs it
    ///    selected (first-leg readiness, DEC-007) — `legNotSelected`;
    /// 5. a position lies within the leg's selected boarding and alighting
    ///    stops — `positionOutOfRange`.
    ///
    /// `planning`, `plannedEndReached`, and `ended` fit any Journey; waiting
    /// for a later leg may point at an unselected leg (DEC-008).
    init(journey: Journey, state: JourneyState) throws(ActiveJourneyInconsistency) {
        guard state.journeyID == journey.id else { throw .journeyMismatch }

        try Self.validate(state.phase, against: journey.legs)

        self.journey = journey
        self.state = state
    }

    private static func validate(_ phase: JourneyPhase, against legs: [JourneyLeg]) throws(ActiveJourneyInconsistency) {
        switch phase {
        case .planning, .plannedEndReached, .ended:
            return

        case .awaitingDeparture(let legIndex):
            let leg = try rail(at: legIndex, in: legs)
            if legIndex == 0, case .unselected = leg { throw .legNotSelected(legIndex: legIndex) }

        case .riding(let legIndex, let position):
            guard case .selected(let selection) = try rail(at: legIndex, in: legs) else {
                throw .legNotSelected(legIndex: legIndex)
            }
            if let position, !contains(position.place, in: selection) {
                throw .positionOutOfRange(legIndex: legIndex)
            }

        case .transferring(.walking(let legIndex)):
            try checkRange(legIndex, in: legs)
            guard case .walkingTransfer = legs[legIndex] else { throw .legKindMismatch(legIndex: legIndex) }

        case .transferring(.atStation(let railLegIndex)):
            // Both legs are range-checked before either kind. `railLegIndex`
            // is below `legs.count` once the first check passes, so adding one
            // cannot overflow.
            try checkRange(railLegIndex, in: legs)
            try checkRange(railLegIndex + 1, in: legs)
            _ = try rail(at: railLegIndex, in: legs)
            _ = try rail(at: railLegIndex + 1, in: legs)

        case .interrupted(_, let legIndex):
            if let legIndex { try checkRange(legIndex, in: legs) }
        }
    }

    private static func checkRange(_ legIndex: Int, in legs: [JourneyLeg]) throws(ActiveJourneyInconsistency) {
        guard legIndex >= 0, legIndex < legs.count else { throw .legIndexOutOfRange(legIndex) }
    }

    /// The rail leg at `legIndex`, after the range and kind checks.
    private static func rail(at legIndex: Int, in legs: [JourneyLeg]) throws(ActiveJourneyInconsistency) -> RailLeg {
        try checkRange(legIndex, in: legs)
        guard case .rail(let rail) = legs[legIndex] else { throw .legKindMismatch(legIndex: legIndex) }
        return rail
    }

    /// Whether `place` lies within the selection's boarding and alighting
    /// stops: a stop in `boardingIndex...alightingIndex`, or a movement after
    /// a stop in `boardingIndex..<alightingIndex`.
    private static func contains(_ place: JourneyPosition.Place, in selection: SelectedRailTrip) -> Bool {
        switch place {
        case .atStop(let index):
            (selection.boardingIndex...selection.alightingIndex).contains(index)
        case .betweenStops(after: let index):
            (selection.boardingIndex..<selection.alightingIndex).contains(index)
        }
    }
}
