#if DEBUG
import Foundation

/// Caller stipulations for an invented world, NOT certificates of real coverage or
/// admission. A candidate array alone never proves that a search was complete.
nonisolated enum SyntheticOptimalRouteInput: Sendable {
    case completeInventedUniverse(scope: InternalSearchScope, candidates: [RouteCandidate])
    case unknownRequiredEvidence
    case incompleteEnumeration
}

/// Selection before any admission handoff. This is deliberately not RouteSearchResult.
nonisolated struct SyntheticOptimalRouteSelection: Sendable {
    let scope: InternalSearchScope
    let candidates: [RouteCandidate]
    private init(scope: InternalSearchScope, candidates: [RouteCandidate]) {
        self.scope = scope; self.candidates = candidates
    }

    private typealias Atom = SyntheticOptimalRouteAtom
    private typealias Descriptor = SyntheticOptimalRouteDescriptor

    /// Finite fixture ceilings only: 64 candidates, 7 legs, 256 entries per snapshot
    /// array, 128 UTF-8 bytes per identifier/date. No configurable production defaults.
    static func select(_ input: SyntheticOptimalRouteInput) throws -> Self {
        let scope: InternalSearchScope, candidates: [RouteCandidate]
        switch input {
        case .unknownRequiredEvidence: throw RouteSearchFailure.dataUnavailable
        case .incompleteEnumeration: throw RouteSearchFailure.searchIncomplete
        case .completeInventedUniverse(let s, let c): scope = s; candidates = c
        }
        guard candidates.count <= 64 else { throw RouteSearchFailure.searchIncomplete }
        var entries: [Descriptor] = []
        var snapshots: [TripID: Trip] = [:]
        var endpoints: [[Atom]: Date] = [:]
        for candidate in candidates {
            guard candidate.legs.count <= 7 else { throw RouteSearchFailure.searchIncomplete }
            var contexts: [TimetableRideContext] = [], forms: [Int] = []
            var walking = false
            for leg in candidate.legs {
                switch leg {
                case .walkingTransfer: walking = true
                case .rail(let rail):
                    guard case .matched(let train) = rail.travel,
                          case .timetable(let context) = rail.scheduledContext else { throw RouteSearchFailure.dataUnavailable }
                    let trip = train.trip
                    try Descriptor.checkBounds(context)
                    if let old = snapshots[trip.id] {
                        guard old.stopSequence == trip.stopSequence, old.lineSegments == trip.lineSegments,
                              old.serviceTypeSegments == trip.serviceTypeSegments, old.coverage == trip.coverage else {
                            throw RouteSearchFailure.dataUnavailable
                        }
                    }
                    snapshots[trip.id] = trip
                    // Same event identity cannot gain another time through a different interval.
                    for (index, kind, time) in [(context.boardingIndex, 0, context.departure), (context.alightingIndex, 1, context.arrival)] {
                        let key = Descriptor.address(context) + [.number(index), .number(kind)]
                        if let old = endpoints[key], old != time { throw RouteSearchFailure.dataUnavailable }
                        endpoints[key] = time
                    }
                    if !contexts.isEmpty { forms.append(walking ? 1 : 0) }
                    contexts.append(context); walking = false
                }
            }
            // Reuse canonical association/scope checks; this does not authenticate
            // eligibility, continuity or transfers stipulated by the invented caller.
            guard let batch = RouteSearchBatch(candidates: [candidate], omissions: []),
                  InternalSearchSuccess(scope: scope, outcome: .alternatives(batch)) != nil else {
                throw RouteSearchFailure.dataUnavailable
            }
            entries.append(.init(contexts: contexts, forms: forms))
        }
        // Validate all input, including slower alternatives, before objective exclusion.
        // No dominance pruning, wall-clock use, first-K shortcut or production optimality claim.
        var kernel = SyntheticOptimalRouteKernel(entries)
        while !kernel.isComplete { kernel.advance() }
        return .init(scope: scope, candidates: kernel.winners.map { candidates[$0] })
    }
}
#endif
