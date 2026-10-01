import Foundation

/// Already-qualified input only. No date, zone, rollover or timetable parser.
/// Qualification is an upstream adapter obligation, never proven by a Date.
nonisolated struct RouteScheduledEndpoints: Sendable {
    let departure: Date?
    let arrival: Date?
}

/// Reusable DEC-076 E checks, separate from synthetic evidence assumptions.
nonisolated enum RouteScheduleAdmission {
    static func contexts(
        for rides: [RouteScheduledEndpoints],
        request: RouteSearchRequest,
        assertsDepartureIntent: Bool
    ) throws -> [ProviderScheduledContext?] {
        var previous: Date?
        // Validate ALL known ridden inputs before discarding any incomplete pair.
        for ride in rides {
            try Task.checkCancellation()
            for event in [ride.departure, ride.arrival].compactMap({ $0 }) {
                guard event.timeIntervalSinceReferenceDate.isFinite,
                      event >= request.departNotBefore,
                      previous.map({ $0 <= event }) ?? true
                else { throw RouteAdmissionRejection(.invalidScheduledContext) }
                previous = event
            }
        }
        return try rides.map { ride in
            try Task.checkCancellation()
            guard let departure = ride.departure, let arrival = ride.arrival else {
                guard assertsDepartureIntent else { throw RouteAdmissionRejection(.invalidScheduledContext) }
                return nil
            }
            guard let context = ProviderScheduledContext(departure: departure, arrival: arrival)
            else { throw RouteAdmissionRejection(.invalidScheduledContext) }
            return context
        }
    }
}

/// Internal control flow, never a public error or evidence/proof token.
nonisolated struct RouteAdmissionRejection: Error {
    let reason: RouteAlternativeRejectionReason
    init(_ reason: RouteAlternativeRejectionReason) { self.reason = reason }
}
