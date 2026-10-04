#if DEBUG
import Foundation

/// Experiment modes only. Neither certifies a real inventory or enables live routing.
nonisolated enum SyntheticPruningMode: Sendable { case exhaustive, pruned }
nonisolated struct SyntheticPruningMetrics: Sendable {
    var qualificationWork = 0, discoveryWork = 0, postWork = 0, pairChecks = 0
    var prefixes = 0, prunedPrefixes = 0, completePaths = 0
    var qualifiedRides = 0, qualifiedEdges = 0, kernelAdvances = 0
    var selectionTime: Duration = .zero, admissionTime: Duration = .zero
    var peakFrontierPaths = 0, peakFrontierKeys = 0, peakCompletePaths = 0, peakCompleteKeys = 0
    var qualificationTime: Duration = .zero, discoveryTime: Duration = .zero
    mutating func observe(stack: [[SyntheticInternalRideKey]], complete: [[SyntheticInternalRideKey]]) {
        peakFrontierPaths = max(peakFrontierPaths, stack.count)
        peakFrontierKeys = max(peakFrontierKeys, stack.reduce(0) { $0 + $1.count })
        peakCompletePaths = max(peakCompletePaths, complete.count)
        peakCompleteKeys = max(peakCompleteKeys, complete.reduce(0) { $0 + $1.count })
    }
}

/// Bounds apply before engine normalization, not to construction by the caller.
/// Counts are structural storage units, never estimates of process memory.
nonisolated enum SyntheticPruningBounds {
    static let workLimit = 200_000
    static func require(_ condition: Bool) throws {
        guard condition else { throw RouteSearchFailure.searchIncomplete }
    }
    static func text(_ value: String) throws { try require(value.utf8.prefix(129).count <= 128) }
    static func address(_ value: TimetableOccurrenceAddress) throws {
        try text(value.tripID.rawValue); try text(value.serviceDate.label)
    }
    static func trip(_ trip: Trip) throws {
        try require(trip.stopSequence.count <= 4 && trip.lineSegments.count <= 4 && trip.serviceTypeSegments.count <= 4)
        try text(trip.id.rawValue)
        for id in trip.stopSequence { try text(id.rawValue) }
        for segment in trip.lineSegments { try text(segment.lineID.rawValue) }
        for segment in trip.serviceTypeSegments { try text(segment.serviceTypeID.rawValue) }
    }
    static func validate(_ configuration: SyntheticInternalConfiguration?, _ view: SyntheticInternalView?,
                         _ request: RouteSearchRequest) throws {
        try text(request.origin.rawValue); try text(request.destination.rawValue)
        if let configuration {
            let p = configuration.profile
            try require(p.maximumRailRides <= 4 && p.stations.count <= 16 && p.lines.count <= 8 && p.trips.count <= 10)
            for id in p.stations { try text(id.rawValue) }
            for id in p.lines { try text(id.rawValue) }
            for id in p.trips { try text(id.rawValue) }
        }
        guard let view else { return }
        try require(view.inventories.count <= 10 && view.connections.count <= 1024 && view.stations.count <= 16 && view.lines.count <= 8)
        for (id, states) in view.stations { try text(id.rawValue); try require(states.count <= 5) }
        for id in view.lines { try text(id.rawValue) }
        for inventory in view.inventories {
            try trip(inventory.trip)
            try require((inventory.intervals?.count ?? 0) <= 6 && (inventory.slots?.count ?? 0) <= 2)
            for slot in inventory.slots ?? [] {
                try address(slot.address)
                if case .active(let facts, let continuity) = slot.activation {
                    try require(facts.visits.count <= 4 && continuity.count <= 6)
                    try trip(facts.binding.trip); try address(facts.binding.address)
                    for visit in facts.visits { try trip(visit.binding.trip); try address(visit.binding.address) }
                }
            }
        }
        for connection in view.connections {
            try address(connection.key.alighting.address); try address(connection.key.boarding.address)
        }
    }
}
nonisolated struct SyntheticPruningPass: Sendable {
    let result: RouteSearchResult
    let metrics: SyntheticPruningMetrics
    let elapsed: Duration
}
nonisolated struct SyntheticPruningComparison: Sendable {
    let oracle: SyntheticPruningPass
    let pruned: SyntheticPruningPass
    let elapsed: Duration
}
#endif
