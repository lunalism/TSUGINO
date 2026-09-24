// How the plan's final alighting point was reached (DEC-063 B).
//
// Neither basis is the rider's arrival. Confirming that the rider arrived
// needs rider-side evidence and is outside this contract; no surface may
// present either basis as confirmed arrival.

/// The basis on which a Journey reached its planned endpoint.
nonisolated enum PlannedEndBasis: Equatable, Sendable {
    /// Clock time passed the final leg's scheduled arrival. Phase 5 produces
    /// it only when it has a scheduled final-arrival time to compare against
    /// the supplied clock; this type stores the result, never a timetable.
    case schedule

    /// Realtime observed the selected **train** at the final alighting stop.
    /// Train location never establishes that the rider arrived.
    case trainObservedAtFinalStop
}
