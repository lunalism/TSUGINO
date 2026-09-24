// Why a runtime state does not fit its Journey (DEC-063 E).
//
// The only Phase 1 typed error. It names which pairing rule failed so the
// Phase 6 recovery path for a persisted Journey (`invalidPersistedJourney`,
// DEC-031) and structured diagnostics (DEC-033) can act on it. It invents no
// provider, route-search, realtime, persistence, transfer-guidance, or
// transition error; those belong to their owning phases (ARCHITECTURE.md §34).

/// A `JourneyState` that does not fit its `Journey`.
nonisolated enum ActiveJourneyInconsistency: Error {
    /// The state describes a different Journey.
    case journeyMismatch

    /// A leg index in the phase is negative or beyond the Journey's legs.
    case legIndexOutOfRange(Int)

    /// The phase needs a different kind of leg at this index.
    case legKindMismatch(legIndex: Int)

    /// The phase needs a selected Trip on this rail leg.
    case legNotSelected(legIndex: Int)

    /// The position lies outside this leg's boarding and alighting stops.
    case positionOutOfRange(legIndex: Int)
}
