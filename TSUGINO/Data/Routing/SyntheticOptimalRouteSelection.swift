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

    private enum Atom: Hashable {
        case text([UInt8]), number(Int)
        static func symbol(_ value: String) -> Self { .text(Array(value.utf8)) }
        static func less(_ a: Self, _ b: Self) -> Bool {
            switch (a, b) {
            case (.text(let x), .text(let y)): return x.lexicographicallyPrecedes(y)
            case (.number(let x), .number(let y)): return x < y
            case (.number, .text): return true
            case (.text, .number): return false
            }
        }
    }
    private struct Entry {
        let candidate: RouteCandidate
        let key: [Atom]
        let contexts: [TimetableRideContext]
        var arrival: Date { contexts[contexts.count - 1].arrival }
    }

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
        var entries: [Entry] = []
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
                    guard trip.stopSequence.count <= 256, trip.lineSegments.count <= 256,
                          trip.serviceTypeSegments.count <= 256 else { throw RouteSearchFailure.searchIncomplete }
                    let texts = [trip.id.rawValue, context.binding.address.serviceDate.label]
                        + trip.stopSequence.map(\.rawValue) + trip.lineSegments.map { $0.lineID.rawValue }
                        + trip.serviceTypeSegments.map { $0.serviceTypeID.rawValue }
                    guard texts.allSatisfy({ $0.utf8.prefix(129).count <= 128 }) else { throw RouteSearchFailure.searchIncomplete }
                    if let old = snapshots[trip.id] {
                        guard old.stopSequence == trip.stopSequence, old.lineSegments == trip.lineSegments,
                              old.serviceTypeSegments == trip.serviceTypeSegments, old.coverage == trip.coverage else {
                            throw RouteSearchFailure.dataUnavailable
                        }
                    }
                    snapshots[trip.id] = trip
                    // Same event identity cannot gain another time through a different interval.
                    for (index, kind, time) in [(context.boardingIndex, 0, context.departure), (context.alightingIndex, 1, context.arrival)] {
                        let key = address(context) + [.number(index), .number(kind)]
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
            var key: [Atom] = []
            for (i, c) in contexts.enumerated() {
                if i > 0 {
                    let previous = contexts[i - 1]
                    key += address(previous) + [.number(previous.alightingIndex)]
                    key += address(c) + [.number(c.boardingIndex)]
                    key += [.symbol(previous.binding.trip.stopSequence[previous.alightingIndex].rawValue),
                            .symbol(c.binding.trip.stopSequence[c.boardingIndex].rawValue), .number(forms[i - 1])]
                }
                key += address(c) + [.number(c.boardingIndex), .number(c.alightingIndex)]
            }
            entries.append(.init(candidate: candidate, key: key, contexts: contexts))
        }
        // Validate all input, including slower alternatives, before objective exclusion.
        // No dominance pruning, wall-clock use, first-K shortcut or production optimality claim.
        guard let best = entries.min(by: {
            $0.arrival != $1.arrival ? $0.arrival < $1.arrival : $0.candidate.transferCount < $1.candidate.transferCount
        }) else { return .init(scope: scope, candidates: []) }
        var seen: Set<[Atom]> = []
        let winners = entries.filter {
            $0.arrival == best.arrival && $0.candidate.transferCount == best.candidate.transferCount && seen.insert($0.key).inserted
        }.sorted { $0.key.lexicographicallyPrecedes($1.key, by: Atom.less) }
        return .init(scope: scope, candidates: winners.map(\.candidate))
    }
    private static func address(_ context: TimetableRideContext) -> [Atom] {
        let a = context.binding.address
        // Canonical fixed-width uppercase UUID spelling has UUID byte order.
        return [.symbol(a.viewID.rawValue.uuidString), .symbol(a.tripID.rawValue), .symbol(a.serviceDate.label)]
    }
}
#endif
