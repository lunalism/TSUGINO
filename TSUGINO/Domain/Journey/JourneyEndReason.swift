// Why tracking of a Journey ended (DEC-063 A, FEATURES.md §4.12).

/// The reason a Journey's tracking ended.
nonisolated enum JourneyEndReason: Equatable, Sendable {
    /// Tracking ended after the planned endpoint. It does not mean the
    /// rider's arrival was confirmed (DEC-063 B).
    case trackingCompleted
    case cancelledByUser
    case endedEarlyByUser
}
