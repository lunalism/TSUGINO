import Foundation

/// Explicit origin of scheduled context. Neither branch implies actual operation.
/// Shared projections support ordering, not mixed-source search admission.
nonisolated enum RouteScheduledContext: Sendable {
    case provider(ProviderScheduledContext)
    case timetable(TimetableRideContext)

    var departure: Date {
        switch self {
        case .provider(let context): context.departure
        case .timetable(let context): context.departure
        }
    }

    var arrival: Date {
        switch self {
        case .provider(let context): context.arrival
        case .timetable(let context): context.arrival
        }
    }
}
