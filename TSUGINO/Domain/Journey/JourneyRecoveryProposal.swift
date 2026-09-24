// A suggestion of how a rider might recover from an interruption
// (DEC-064 F).
//
// It names only rail legs whose train selection can be reopened for their
// unchanged stations. That is an available action, never a promise that
// another train exists, can be caught, or fits: presentation says "choose
// another train", never "another train is available". Ending the Journey is
// always separately available and is not listed; replanning is not offered.
// Whether an interruption deserves a proposal, and which legs it names, are
// Phase 5 decisions.

/// Rail legs whose train selection may be reopened after an interruption.
nonisolated struct JourneyRecoveryProposal: Sendable {
    let reason: JourneyInterruptionReason
    let reselectableLegIndices: [Int]

    /// Fails unless the indices are non-empty, non-negative, strictly
    /// ascending, and therefore unique. Whether each names a rail leg of the
    /// Journey is checked by `JourneyTransitionResult`. With nothing to
    /// reselect there is no proposal, so an empty one cannot exist.
    init?(reason: JourneyInterruptionReason, reselectableLegIndices: [Int]) {
        guard
            let first = reselectableLegIndices.first,
            first >= 0,
            !zip(reselectableLegIndices, reselectableLegIndices.dropFirst()).contains(where: { $0 >= $1 })
        else { return nil }

        self.reason = reason
        self.reselectableLegIndices = reselectableLegIndices
    }
}
