nonisolated enum RouteUnresolvedReason: Sendable {
    case notSupplied
    case noVerifiedMatch
}

/// Validated payload prevents enum construction from bypassing line invariants.
/// This states a complete continuous ride; it does not certify its evidence.
nonisolated struct UnresolvedRouteRailTravel: Sendable {
    let anchors: RailLegAnchors
    let lineSequence: [LineID]
    let reason: RouteUnresolvedReason

    /// Input must already have adjacent duplicates collapsed. Nonadjacent repeats
    /// are valid; normalization and evidence admission remain Data responsibilities.
    init?(anchors: RailLegAnchors, lineSequence: [LineID], reason: RouteUnresolvedReason) {
        guard !lineSequence.isEmpty,
              !zip(lineSequence, lineSequence.dropFirst()).contains(where: { $0 == $1 })
        else { return nil }
        self.anchors = anchors
        self.lineSequence = lineSequence
        self.reason = reason
    }
}

nonisolated enum RouteRailTravel: Sendable {
    case unresolved(UnresolvedRouteRailTravel)
    case matched(TrainCandidate)

    var anchors: RailLegAnchors {
        switch self {
        case .unresolved(let ride): ride.anchors
        case .matched(let train): train.anchors
        }
    }

    var lineSequence: [LineID] {
        switch self {
        case .unresolved(let ride): ride.lineSequence
        case .matched(let train): train.lineSequence
        }
    }
}

nonisolated struct RouteRailProposal: Sendable {
    let travel: RouteRailTravel
    let scheduledContext: ProviderScheduledContext?

    init(travel: RouteRailTravel, scheduledContext: ProviderScheduledContext?) {
        self.travel = travel
        self.scheduledContext = scheduledContext
    }
}
