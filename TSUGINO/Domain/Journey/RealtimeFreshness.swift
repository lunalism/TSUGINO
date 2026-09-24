// How fresh the current leg's realtime information is (DEC-063 C, DEC-024).
//
// It describes the **current leg's** service only. Classifying a feed into
// these cases from data age and provider thresholds is Phase 4 / Phase 5;
// this type stores the classification. Stale or unavailable realtime is
// degraded freshness, never an interruption by itself.

import Foundation

/// The freshness of the current leg's realtime information.
nonisolated enum RealtimeFreshness: Equatable, Sendable {
    case live(updatedAt: Date)
    case delayedUpdate(lastUpdatedAt: Date)
    case stale(lastUpdatedAt: Date)

    /// Realtime was expected but is not usable; timetable guidance is still
    /// available.
    case scheduleFallback(lastRealtimeAt: Date?)

    /// The service has no verified trip-level realtime (DEC-046, DEC-047).
    case scheduledOnly

    /// Insufficient data for current guidance, realtime or timetable.
    case unavailable

    /// Whether this freshness comes from realtime observation, which an
    /// `observed` position or observed endpoint requires (DEC-063 D).
    var isRealtimeDerived: Bool {
        switch self {
        case .live, .delayedUpdate, .stale: true
        case .scheduleFallback, .scheduledOnly, .unavailable: false
        }
    }

    /// The instant this freshness refers to, if it carries one.
    var timestamp: Date? {
        switch self {
        case .live(let date), .delayedUpdate(let date), .stale(let date): date
        case .scheduleFallback(let date): date
        case .scheduledOnly, .unavailable: nil
        }
    }
}
