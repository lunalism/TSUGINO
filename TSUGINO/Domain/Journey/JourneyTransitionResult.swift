// What one applied engine transition produced (DEC-064 C).
//
// Both ends are `ActiveJourney` values, so the next state is already
// consistent with its Journey (DEC-063 E). This constructor adds only what
// relates the two ends. How the next pair was reached is Phase 5 behaviour.

/// The previous and next pair of an applied transition, with its events and
/// any recovery proposal.
nonisolated struct JourneyTransitionResult: Sendable {
    let previous: ActiveJourney
    let next: ActiveJourney
    let events: [JourneyEvent]
    let recoveryProposal: JourneyRecoveryProposal?

    /// Fails unless (DEC-064 C):
    ///
    /// 1. both pairs describe the same Journey;
    /// 2. the next state's `asOf` is not earlier than the previous one's;
    /// 3. every event occurred within that time window, inclusive;
    /// 4. a recovery proposal appears only when the next phase is an
    ///    interruption with the same reason — an interruption without a
    ///    proposal is valid;
    /// 5. every proposed leg exists in the next Journey and is a rail leg.
    init?(
        previous: ActiveJourney,
        next: ActiveJourney,
        events: [JourneyEvent],
        recoveryProposal: JourneyRecoveryProposal?
    ) {
        let start = previous.state.asOf
        let end = next.state.asOf

        guard
            next.journey.id == previous.journey.id,
            end >= start,
            events.allSatisfy({ start <= $0.occurredAt && $0.occurredAt <= end }),
            Self.isValid(recoveryProposal, for: next)
        else { return nil }

        self.previous = previous
        self.next = next
        self.events = events
        self.recoveryProposal = recoveryProposal
    }

    private static func isValid(_ proposal: JourneyRecoveryProposal?, for next: ActiveJourney) -> Bool {
        guard let proposal else { return true }
        guard case .interrupted(let reason, _) = next.state.phase, reason == proposal.reason else { return false }

        let legs = next.journey.legs
        return proposal.reselectableLegIndices.allSatisfy { index in
            guard index < legs.count, case .rail = legs[index] else { return false }
            return true
        }
    }
}
