#if DEBUG
import Foundation

/// Controlled synthetic-only DEC-076 implementation. Closures are seams for test
/// clients/view stores, not a provider framework. No fixtures or production wiring.
nonisolated struct SyntheticRouteSearcher: RouteSearching {
    let loadView: @Sendable () async throws -> SyntheticRouteDataView
    let fetch: @Sendable (RouteSearchRequest, String) async throws -> SyntheticRouteEnvelope
    // Controlled cancellation checkpoint between alternatives. No sleeps, polling
    // or detached tasks; a suspended test client/checkpoint owns its cancellation.
    let checkpoint: @Sendable () async throws -> Void

    init(
        loadView: @escaping @Sendable () async throws -> SyntheticRouteDataView,
        fetch: @escaping @Sendable (RouteSearchRequest, String) async throws -> SyntheticRouteEnvelope,
        checkpoint: @escaping @Sendable () async throws -> Void = {}
    ) {
        self.loadView = loadView
        self.fetch = fetch
        self.checkpoint = checkpoint
    }

    /// Explicit generic-executor execution under approachable concurrency. All
    /// working state is local; reentrant/overlapping calls share no mutable batch.
    @concurrent
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        try Task.checkCancellation()
        let view: SyntheticRouteDataView
        do { view = try await loadView() }
        catch {
            try preserveCancellation(error)
            throw RouteSearchFailure.dataUnavailable
        }
        try Task.checkCancellation()
        guard view.usable, !view.id.isEmpty,
              view.trips.allSatisfy({ $0.key == $0.value.trip.id && $0.value.viewID == view.id })
        else { throw RouteSearchFailure.dataUnavailable }
        try validateEndpoint(request.origin, role: .origin, view: view)
        try validateEndpoint(request.destination, role: .destination, view: view)

        let envelope: SyntheticRouteEnvelope
        do {
            try Task.checkCancellation()
            envelope = try await fetch(request, view.id)
        } catch {
            try preserveCancellation(error)
            switch error {
            case SyntheticRouteClientFailure.rateLimited: throw RouteSearchFailure.rateLimited
            case SyntheticRouteClientFailure.configuration: throw RouteSearchFailure.configurationUnavailable
            case SyntheticRouteClientFailure.malformed: throw RouteSearchFailure.malformedResponse
            case SyntheticRouteClientFailure.unsupportedIntent: throw RouteSearchFailure.unsupportedRequest
            default: throw RouteSearchFailure.providerUnavailable
            }
        }
        try Task.checkCancellation()
        guard envelope.viewID == view.id else { throw RouteSearchFailure.dataUnavailable }
        guard let alternatives = envelope.alternatives,
              envelope.explicitlyNoResults == alternatives.isEmpty
        else { throw RouteSearchFailure.malformedResponse }
        if alternatives.isEmpty {
            try Task.checkCancellation()
            return .noResults
        }

        var candidates: [RouteCandidate] = []
        var omissions: [RouteAlternativeOmission] = []
        for (index, alternative) in alternatives.enumerated() {
            try Task.checkCancellation()
            do {
                candidates.append(try SyntheticRouteAdmission.candidate(alternative, request: request, view: view))
            } catch let rejection as RouteAdmissionRejection {
                // Deterministic first failed check; one reason is nonempty, unique
                // and in declaration order. No synthetic reference/text escapes.
                guard let omission = RouteAlternativeOmission(alternativeIndex: index, reasons: [rejection.reason])
                else { throw RouteSearchFailure.malformedResponse }
                omissions.append(omission)
            }
            do { try await checkpoint() }
            catch {
                try preserveCancellation(error)
                throw RouteSearchFailure.malformedResponse
            }
            try Task.checkCancellation()
        }
        try Task.checkCancellation()
        if candidates.isEmpty {
            guard let rejected = RouteSearchRejections(omissions: omissions)
            else { throw RouteSearchFailure.malformedResponse }
            throw RouteSearchFailure.noUsableAlternatives(rejected)
        }
        guard let batch = RouteSearchBatch(candidates: candidates, omissions: omissions)
        else { throw RouteSearchFailure.malformedResponse }
        return .alternatives(batch)
    }

    private func preserveCancellation(_ error: any Error) throws {
        if error is CancellationError { throw CancellationError() }
        try Task.checkCancellation()
    }

    private func validateEndpoint(_ station: StationID, role: RouteSearchEndpointRole,
                                  view: SyntheticRouteDataView) throws {
        let reason: RouteSearchEndpointFailureReason
        switch view.stations[station] ?? .unknown {
        case .active:
            // Synthetic endpoint support includes an available outbound
            // mapping; no canonical ID is sent as a guessed provider reference.
            let matches = view.stationMappings.values.filter {
                if case .active(let id) = $0 { id == station } else { false }
            }
            guard !matches.isEmpty else { throw RouteSearchFailure.invalidEndpoint(role, .unknown) }
            return
        case .unknown: reason = .unknown
        case .retired: reason = .retired
        case .conflicting: reason = .conflicting
        case .unsupported: reason = .unsupported
        }
        throw RouteSearchFailure.invalidEndpoint(role, reason)
    }
}
#endif
