/// A locally consistent scoped payload, never a certificate of completed search.
/// Data/runtime still establish coverage, activation, policy resolution, connections
/// and completion before emitting it. No input inventory is inferred from candidates.
nonisolated struct InternalSearchSuccess: Sendable {
    nonisolated enum Outcome: Sendable {
        case noResults
        case alternatives(RouteSearchBatch)
    }

    let scope: InternalSearchScope
    let outcome: Outcome

    init?(scope: InternalSearchScope, outcome: Outcome) {
        if case .alternatives(let batch) = outcome {
            guard batch.candidates.allSatisfy({ Self.matches($0, scope: scope) }) else { return nil }
        }
        // Retain the whole batch, including original candidate/omission ordering.
        // noResults checks structure only; zero actual handoffs is a runtime duty.
        self.scope = scope
        self.outcome = outcome
    }

    private static func matches(_ candidate: RouteCandidate, scope: InternalSearchScope) -> Bool {
        guard candidate.origin == scope.request.origin,
              candidate.destination == scope.request.destination,
              candidate.transferCount < scope.profile.maximumRailRides else { return false }
        for leg in candidate.legs {
            switch leg {
            case .walkingTransfer(let walk):
                guard scope.profile.stations.contains(walk.fromStationID),
                      scope.profile.stations.contains(walk.toStationID) else { return false }
            case .rail(let ride):
                guard case .matched(let train) = ride.travel,
                      case .timetable(let context) = ride.scheduledContext,
                      context.matches(train), context.binding.address.viewID == scope.viewID,
                      scope.profile.trips.contains(train.trip.id),
                      train.lineSequence.allSatisfy({ scope.profile.lines.contains($0) }),
                      train.trip.stopSequence[train.boardingIndex...train.alightingIndex]
                        .allSatisfy({ scope.profile.stations.contains($0) }),
                      scope.contains(context.departure), scope.contains(context.arrival)
                else { return false }
            }
        }
        return true
    }
}
