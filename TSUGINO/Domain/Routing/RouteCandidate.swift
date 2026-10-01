import Foundation

nonisolated enum RouteCandidateLeg: Sendable {
    case rail(RouteRailProposal)
    case walkingTransfer(WalkingTransfer)

    var startStationID: StationID {
        switch self {
        case .rail(let ride): ride.travel.anchors.boardingStationID
        case .walkingTransfer(let walk): walk.fromStationID
        }
    }

    var endStationID: StationID {
        switch self {
        case .rail(let ride): ride.travel.anchors.alightingStationID
        case .walkingTransfer(let walk): walk.toStationID
        }
    }

    fileprivate var isRail: Bool {
        if case .rail = self { true } else { false }
    }
}

/// A structurally valid search proposal, not selection or an active Journey.
/// Contexts retain their origin and timetable binding; this constructor does not
/// authenticate result-wide Data coherence, activation or connection feasibility.
nonisolated struct RouteCandidate: Sendable {
    let legs: [RouteCandidateLeg]

    init?(legs: [RouteCandidateLeg]) {
        guard let first = legs.first, let last = legs.last,
              first.isRail, last.isRail else { return nil }
        guard !zip(legs, legs.dropFirst()).contains(where: {
            $0.endStationID != $1.startStationID || (!$0.isRail && !$1.isRail)
        }) else { return nil }

        var seenTrips: Set<TripID> = []
        var previousArrival: Date?
        for leg in legs {
            guard case .rail(let ride) = leg else { continue }
            if case .matched(let train) = ride.travel,
               !seenTrips.insert(train.trip.id).inserted { return nil }
            if let context = ride.scheduledContext {
                // Compare either context origin without resetting across nil/walks. Ordered pairs
                // make checking consecutive retained pairs transitively sufficient.
                if let previousArrival, previousArrival > context.departure { return nil }
                previousArrival = context.arrival
            }
        }
        self.legs = legs
    }

    // Safe because the sole initializer requires nonempty rail-first/last legs.
    var origin: StationID { legs[0].startStationID }
    var destination: StationID { legs[legs.count - 1].endStationID }
    var transferCount: Int { legs.filter(\.isRail).count - 1 }
}
