import Foundation

/// A finite, already-qualified instant. Qualification is a Data obligation.
/// Wrapping enum payloads prevents construction with a nonfinite Date.
nonisolated struct TimetableInstant: Equatable, Sendable {
    let date: Date
    init?(_ date: Date) {
        guard date.timeIntervalSinceReferenceDate.isFinite else { return nil }
        self.date = date
    }
}

nonisolated enum TimetableTime: Equatable, Sendable {
    case missing
    case exact(TimetableInstant)
    case estimated(TimetableInstant)
}

nonisolated enum TimetableEligibility: Sendable {
    case allowed
    case prohibited
    case unknown
}
