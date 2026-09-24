// Where a Journey stands in its selected plan (DEC-063 A, ARCHITECTURE.md
// §5.6, §6).
//
// The phases are deliberately neutral: none claims that the rider boarded,
// passed a station, or arrived. How a phase was established comes from the
// state's freshness and each basis. The documented names — Boarding, OnTrain,
// Arrived, and the rest — are presentation labels derived from these phases
// by presentation mappers. Which phase may follow which, and how any phase is
// reached, are Phase 5 transition rules (DEC-050); nothing here encodes them.

/// A Journey's neutral phase within its selected plan.
nonisolated enum JourneyPhase: Equatable, Sendable {
    /// Tracking has not started.
    case planning

    /// Before the departure of the rail leg at `legIndex`.
    case awaitingDeparture(legIndex: Int)

    /// Within the selected ride of the rail leg at `legIndex`, optionally at a
    /// known position on its stated basis.
    case riding(legIndex: Int, position: JourneyPosition?)

    /// Between two rail legs.
    case transferring(TransferPoint)

    /// The plan's final alighting point has been reached on the stated basis —
    /// never the rider's confirmed arrival (DEC-063 B).
    case plannedEndReached(PlannedEndBasis)

    /// The plan has diverged, optionally at the leg where it happened.
    case interrupted(JourneyInterruptionReason, legIndex: Int?)

    /// Tracking is over.
    case ended(JourneyEndReason)
}
