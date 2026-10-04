#if DEBUG
import Foundation

/// Normal search can only generate from finite invented facts. No mutation hook.
nonisolated struct SyntheticInternalRouteSearcher: RouteSearching {
    let configuration: SyntheticInternalConfiguration?
    let view: SyntheticInternalView?
    let workLimit: Int?
    let checkpoint: @Sendable (SyntheticInternalStage) async throws -> Void

    init(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?, workLimit: Int? = nil,
         checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void = { _ in }) {
        self.configuration = configuration; self.view = view
        self.workLimit = workLimit; self.checkpoint = checkpoint
    }

    @concurrent
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        var engine = SyntheticInternalRouteEngine(configuration: configuration, view: view, workLimit: workLimit, checkpoint: checkpoint)
        do {
            let prepared = try await engine.prepare(request)
            var candidates: [RouteCandidate] = []
            var omissions: [RouteAlternativeOmission] = []
            for (index, path) in prepared.paths.enumerated() {
                try await engine.step(.admission)
                let claims = try Self.claims(path, prepared)
                switch try await engine.admit(claims, prepared: prepared) {
                case .success(let candidate): candidates.append(candidate)
                case .failure(let rejection):
                    guard let omission = RouteAlternativeOmission(alternativeIndex: index, reasons: [rejection.reason]) else { throw RouteSearchFailure.dataUnavailable }
                    omissions.append(omission)
                }
            }
            return try await engine.finalize(prepared: prepared, candidates: candidates, omissions: omissions)
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let canonical = error as? RouteSearchFailure { throw canonical }
            throw RouteSearchFailure.dataUnavailable
        }
    }

    static func claims(_ path: [SyntheticInternalRideKey], _ prepared: SyntheticInternalPrepared) throws -> [SyntheticInternalRide] {
        try path.map { key in
            guard let ride = prepared.rides[key] else { throw RouteSearchFailure.dataUnavailable }
            return ride
        }
    }
}

nonisolated struct SyntheticInternalRejection: Error, Sendable {
    let reason: RouteAlternativeRejectionReason
}

extension SyntheticInternalRouteEngine {
    /// Shared outcome path for normal execution and the failure-only generated-claim harness.
    mutating func finalize(prepared: SyntheticInternalPrepared, candidates: [RouteCandidate],
                           omissions: [RouteAlternativeOmission]) async throws -> RouteSearchResult {
        try await finalize(prepared: prepared, candidates: candidates, omissions: omissions,
                           expected: prepared.paths.count, optimal: false)
    }

    /// The optimal entry freezes selected count without rewriting prepared.paths.
    mutating func finalizeOptimal(prepared: SyntheticInternalPrepared, selectedCount: Int,
                                 candidates: [RouteCandidate], omissions: [RouteAlternativeOmission]) async throws -> RouteSearchResult {
        try await finalize(prepared: prepared, candidates: candidates, omissions: omissions,
                           expected: selectedCount, optimal: true)
    }

    private mutating func finalize(prepared: SyntheticInternalPrepared, candidates: [RouteCandidate],
                                   omissions: [RouteAlternativeOmission], expected: Int, optimal: Bool) async throws -> RouteSearchResult {
        try await step(.finish)
        guard expected >= 0, candidates.count <= expected,
              omissions.count == expected - candidates.count else {
            throw optimal ? RouteSearchFailure.searchIncomplete : RouteSearchFailure.dataUnavailable
        }
        let outcome: InternalSearchSuccess.Outcome
        if expected == 0 { outcome = .noResults }
        else if candidates.isEmpty {
            guard let rejected = RouteSearchRejections(omissions: omissions) else { throw RouteSearchFailure.dataUnavailable }
            throw RouteSearchFailure.noUsableAlternatives(rejected)
        } else {
            if optimal && !omissions.isEmpty { throw RouteSearchFailure.searchIncomplete }
            guard let batch = RouteSearchBatch(candidates: candidates, omissions: omissions) else { throw RouteSearchFailure.dataUnavailable }
            outcome = .alternatives(batch)
        }
        guard let success = InternalSearchSuccess(scope: prepared.scope, outcome: outcome) else { throw RouteSearchFailure.dataUnavailable }
        try Task.checkCancellation()
        return .internalSuccess(success)
    }

    mutating func admit(_ claims: [SyntheticInternalRide], prepared: SyntheticInternalPrepared)
        async throws -> Result<RouteCandidate, SyntheticInternalRejection> {
        func reject(_ reason: RouteAlternativeRejectionReason) -> Result<RouteCandidate, SyntheticInternalRejection> { .failure(.init(reason: reason)) }
        guard !claims.isEmpty else { return reject(.invalidStructure) }
        for ride in claims {
            try await step(.admission)
            guard let truth = prepared.rides[ride.key],
                  Self.sameAddress(ride.context.binding.address, ride.key.address),
                  ride.key.boarding == ride.train.boardingIndex, ride.key.alighting == ride.train.alightingIndex,
                  ride.context.matches(ride.train), truth.context.binding.matches(ride.context.binding),
                  truth.context.boardingIndex == ride.context.boardingIndex,
                  truth.context.alightingIndex == ride.context.alightingIndex else { return reject(.inconsistentTrainEvidence) }
        }
        let scope = prepared.scope
        guard claims.first?.train.anchors.boardingStationID == scope.request.origin,
              claims.last?.train.anchors.alightingStationID == scope.request.destination else { return reject(.endpointMismatch) }
        guard claims.count <= scope.profile.maximumRailRides else { return reject(.invalidStructure) }
        var previousArrival: Date?
        var seen: Set<TripID> = []
        for ride in claims {
            try await step(.admission)
            guard seen.insert(ride.train.trip.id).inserted else { return reject(.invalidStructure) }
            guard scope.profile.trips.contains(ride.train.trip.id),
                  ride.train.lineSequence.allSatisfy({ scope.profile.lines.contains($0) }),
                  ride.train.trip.stopSequence[ride.key.boarding...ride.key.alighting].allSatisfy({ scope.profile.stations.contains($0) }) else { return reject(.unsupportedPortion) }
            guard let truth = prepared.rides[ride.key], truth.context.departure == ride.context.departure,
                  truth.context.arrival == ride.context.arrival, scope.contains(ride.context.departure), scope.contains(ride.context.arrival),
                  ride.context.departure <= ride.context.arrival,
                  previousArrival.map({ $0 <= ride.context.departure }) ?? true else { return reject(.invalidScheduledContext) }
            previousArrival = ride.context.arrival
        }
        for ride in claims {
            try await step(.admission)
            guard let slot = prepared.slots[ride.key.address], case .active(let facts, _) = slot.slot.activation else { throw RouteSearchFailure.dataUnavailable }
            guard facts.visits[ride.key.boarding].boarding == .allowed,
                  facts.visits[ride.key.alighting].alighting == .allowed else { return reject(.unverifiedEligibility) }
            guard case .exact = facts.visits[ride.key.boarding].departure,
                  case .exact = facts.visits[ride.key.alighting].arrival else { return reject(.insufficientScheduledEvidence) }
        }
        for ride in claims {
            try await step(.admission)
            let interval = SyntheticInternalInterval(boarding: ride.key.boarding, alighting: ride.key.alighting)
            guard prepared.slots[ride.key.address]?.continuity[interval] == .affirmed else { return reject(.insufficientContinuity) }
        }
        var legs: [RouteCandidateLeg] = []
        for (i, ride) in claims.enumerated() {
            try await step(.admission)
            if i > 0 {
                let previous = claims[i - 1]
                guard case .present(let form, let allowance, .affirmed) = prepared.connections[Self.connectionKey(previous.key, ride.key)] else { return reject(.unverifiedTransfer) }
                guard SyntheticInternalArithmetic.permits(arrival: previous.context.arrival, departure: ride.context.departure, allowance: allowance.total) else { return reject(.infeasibleConnection) }
                if form == .walking {
                    guard let walk = WalkingTransfer(fromStationID: previous.train.anchors.alightingStationID, toStationID: ride.train.anchors.boardingStationID) else { return reject(.invalidStructure) }
                    legs.append(.walkingTransfer(walk))
                } else if previous.train.anchors.alightingStationID != ride.train.anchors.boardingStationID { return reject(.unverifiedTransfer) }
            }
            guard let rail = RouteRailProposal(travel: .matched(ride.train), scheduledContext: .timetable(ride.context)) else { return reject(.inconsistentTrainEvidence) }
            legs.append(.rail(rail))
        }
        guard let candidate = RouteCandidate(legs: legs) else { return reject(.invalidStructure) }
        return .success(candidate)
    }
}

/// Test-only defensive seam, not a RouteSearching implementation or configuration.
/// It must throw the shared all-rejected failure; it cannot return a search result.
nonisolated enum SyntheticInternalFailureHarness {
    nonisolated enum Failure: Error { case noGeneratedHandoffs, unexpectedAdmission }

    @concurrent
    static func rejectGeneratedAlightingClaims(searcher: SyntheticInternalRouteSearcher, request: RouteSearchRequest,
                                               replacementIndex: Int) async throws -> Never {
        var engine = SyntheticInternalRouteEngine(configuration: searcher.configuration, view: searcher.view,
            workLimit: searcher.workLimit, checkpoint: searcher.checkpoint)
        do {
            let prepared = try await engine.prepare(request)
            guard !prepared.paths.isEmpty else { throw Failure.noGeneratedHandoffs }
            var omissions: [RouteAlternativeOmission] = []
            for (index, path) in prepared.paths.enumerated() {
                try await engine.step(.admission)
                var claims = try SyntheticInternalRouteSearcher.claims(path, prepared)
                let original = claims[0]
                claims[0] = SyntheticInternalRide(key: .init(address: original.key.address,
                    boarding: original.key.boarding, alighting: replacementIndex), train: original.train, context: original.context)
                switch try await engine.admit(claims, prepared: prepared) {
                case .success: throw Failure.unexpectedAdmission
                case .failure(let rejection):
                    guard let omission = RouteAlternativeOmission(alternativeIndex: index, reasons: [rejection.reason]) else { throw RouteSearchFailure.dataUnavailable }
                    omissions.append(omission)
                }
            }
            _ = try await engine.finalize(prepared: prepared, candidates: [], omissions: omissions)
            throw Failure.unexpectedAdmission
        } catch { try Task.checkCancellation(); throw error }
    }
}
#endif
