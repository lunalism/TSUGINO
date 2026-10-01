import Foundation

/// A complete provider-scheduled pair, never imported timetable truth or realtime.
/// Data must validate qualified individual endpoints BEFORE omitting incomplete
/// pairs, and check request-relative admission (DEC-076 E). This value cannot.
nonisolated struct ProviderScheduledContext: Sendable {
    let departure: Date
    let arrival: Date

    init?(departure: Date, arrival: Date) {
        guard departure.timeIntervalSinceReferenceDate.isFinite,
              arrival.timeIntervalSinceReferenceDate.isFinite,
              departure <= arrival else { return nil }
        self.departure = departure
        self.arrival = arrival
    }
}
