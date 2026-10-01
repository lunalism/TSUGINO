#if DEBUG
import Foundation

// Internal synthetic vocabulary, not a real provider schema or a public proof
// system. Test fixtures stipulate review/qualification; these flags do not
// authenticate evidence. Excluded from Release and never wired into the app.
nonisolated enum SyntheticRouteResolution<Value: Sendable>: Sendable {
    case active(Value)
    case unknown, retired, conflicting, unsupported
}

nonisolated enum SyntheticRouteStatus: Sendable {
    case active, unknown, retired, conflicting, unsupported
}

nonisolated struct SyntheticTripEvidence: Sendable {
    let viewID: String
    let trip: Trip
    let reviewed: Bool
    /// Explicit occurrence correspondence, not station-name matching. An absent
    /// or ambiguous occurrence has no entry; invalid entries are contradictions.
    let occurrences: [String: Int]
}

nonisolated struct SyntheticInterchange: Hashable, Sendable {
    let station: StationID
    let fromLine: LineID
    let toLine: LineID
}

nonisolated struct SyntheticWalkingConnection: Hashable, Sendable {
    let from: StationID
    let to: StationID
    let fromLine: LineID
    let toLine: LineID
}

nonisolated struct SyntheticRouteDataView: Sendable {
    let id: String
    let usable: Bool
    let stations: [StationID: SyntheticRouteStatus]
    let lines: [LineID: SyntheticRouteStatus]
    let stationMappings: [String: SyntheticRouteResolution<StationID>]
    let lineMappings: [String: SyntheticRouteResolution<LineID>]
    let trainMappings: [String: SyntheticRouteResolution<TripID>]
    let trips: [TripID: SyntheticTripEvidence]
    let memberships: [StationID: Set<LineID>]
    let serviceTypes: Set<ServiceTypeID>
    let interchanges: Set<SyntheticInterchange>
    let walks: Set<SyntheticWalkingConnection>
}

nonisolated struct SyntheticRailFragment: Sendable {
    let from: String
    let to: String
    let line: String
}

nonisolated struct SyntheticRailInput: Sendable {
    let fragments: [SyntheticRailFragment]
    let continuousRide: Bool
    let independentRouteEvidence: Bool
    let trainReference: String?
    let boardingOccurrence: String?
    let alightingOccurrence: String?
    /// Only the ridden endpoints are supplied to the reusable time validator.
    let scheduled: RouteScheduledEndpoints
    /// Explicitly outside the ride, retained only to verify they are not consumed.
    let unusedTripEndpoints: [Date]
}

nonisolated enum SyntheticRouteLeg: Sendable {
    case rail(SyntheticRailInput)
    case walk(from: String, to: String)
}

nonisolated struct SyntheticRouteAlternative: Sendable {
    let wellFormed: Bool
    let legs: [SyntheticRouteLeg]
    /// One affirmative train-change assertion for each inter-ride boundary.
    let trainChanges: [Bool]
    let assertsDepartureIntent: Bool
}

nonisolated struct SyntheticRouteEnvelope: Sendable {
    /// The synthetic client stamps the view used to interpret its references.
    let viewID: String
    /// nil means broken/undelimited envelope; [] is not automatically no-results.
    let alternatives: [SyntheticRouteAlternative]?
    let explicitlyNoResults: Bool
}

nonisolated enum SyntheticRouteClientFailure: Error {
    case unavailable, rateLimited, configuration, malformed, unsupportedIntent
}
#endif
