// Why a rider asks to end a Journey (DEC-064 B4).
//
// Only a rider-initiated reason can be requested. `trackingCompleted` is
// produced by the engine after the planned endpoint, so it is not a case here
// and cannot be sent as an input.

/// A reason a rider may give for ending a Journey.
nonisolated enum UserEndReason: Equatable, Sendable {
    case cancelledByUser
    case endedEarlyByUser

    /// The matching end reason stored in `JourneyPhase.ended`.
    var journeyEndReason: JourneyEndReason {
        switch self {
        case .cancelledByUser: .cancelledByUser
        case .endedEarlyByUser: .endedEarlyByUser
        }
    }
}
