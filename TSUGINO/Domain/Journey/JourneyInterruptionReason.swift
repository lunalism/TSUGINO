// Why a Journey diverged from its plan (DEC-063 A, DEC-031, Rule 19).
//
// Degraded realtime — stale or unavailable data — is freshness, not a reason
// here. Detecting any of these is Phase 5 (DEC-050).

/// The reason a Journey is interrupted.
nonisolated enum JourneyInterruptionReason: Equatable, Sendable {
    case missedTrain
    case wrongTrain
    case wrongDirection
    case serviceCancelled
    case destinationChanged
    case serviceSuspended
    case invalidPersistedJourney
    case unsupportedServiceChange
}
