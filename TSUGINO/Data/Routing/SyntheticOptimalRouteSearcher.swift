#if DEBUG
import Foundation

/// DEC-086 adapter over DEC-081 preparation/admission, not another discovery engine.
/// The caller must stipulate a complete qualified INVENTED inventory. Successful
/// exhaustive preparation proves completion only within that artificial universe.
nonisolated struct SyntheticOptimalRouteSearcher: RouteSearching {
    let configuration: SyntheticInternalConfiguration?
    let view: SyntheticInternalView?
    let workLimit: Int
    let checkpoint: @Sendable (SyntheticInternalStage) async throws -> Void

    init(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?, workLimit: Int,
         checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void = { _ in }) {
        self.configuration = configuration; self.view = view
        self.workLimit = workLimit; self.checkpoint = checkpoint
    }

    @concurrent
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        try await run(request, rejecting: [])
    }

    fileprivate func run(_ request: RouteSearchRequest, rejecting indices: Set<Int>) async throws -> RouteSearchResult {
        var engine = SyntheticInternalRouteEngine(configuration: configuration, view: view,
            workLimit: workLimit, checkpoint: checkpoint)
        do {
            let session = try await PreparedOptimalSession.open(request, engine: &engine)
            return try await session.admit(engine: &engine, rejecting: indices)
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let canonical = error as? RouteSearchFailure { throw canonical }
            throw RouteSearchFailure.dataUnavailable
        }
    }
}

/// No caller can supply prepared state, a handle, a completion flag or a descriptor.
/// Handle ordinals never escape their owning session or become omission indices.
private nonisolated struct PreparedOptimalSession {
    private struct Handle: Sendable { let pathOrdinal: Int }
    private let prepared: SyntheticInternalPrepared
    private let selected: [Handle]
    private init(prepared: SyntheticInternalPrepared, selected: [Handle]) {
        self.prepared = prepared; self.selected = selected
    }

    static func open(_ request: RouteSearchRequest, engine: inout SyntheticInternalRouteEngine) async throws -> Self {
        let prepared = try await engine.prepare(request)
        let selectionStart = engine.experiment == nil ? nil : ContinuousClock.now
        var advances = 0
        try await engine.step(.ordering)
        guard prepared.paths.count <= 64 else { throw RouteSearchFailure.searchIncomplete }
        var descriptors: [SyntheticOptimalRouteDescriptor] = []
        for path in prepared.paths {
            try await engine.step(.ordering)
            guard !path.isEmpty else { throw RouteSearchFailure.dataUnavailable }
            guard path.count <= 4 else { throw RouteSearchFailure.searchIncomplete }
            // Bound before resolving/materializing keys. Claims are the original values.
            let rides = try SyntheticInternalRouteSearcher.claims(path, prepared)
            var forms: [Int] = []
            for (i, ride) in rides.enumerated() {
                try await engine.step(.ordering)
                try SyntheticOptimalRouteDescriptor.checkBounds(ride.context)
                if i > 0 {
                    try await engine.step(.ordering)
                    let key = SyntheticInternalRouteEngine.connectionKey(rides[i - 1].key, ride.key)
                    guard case .present(let form, _, .affirmed) = prepared.connections[key] else {
                        throw RouteSearchFailure.dataUnavailable
                    }
                    forms.append(form == .walking ? 1 : 0)
                }
            }
            descriptors.append(.init(contexts: rides.map(\.context), forms: forms))
        }
        var kernel = SyntheticOptimalRouteKernel(descriptors)
        while !kernel.isComplete {
            try await engine.step(.sorting)
            kernel.advance()
            if engine.experiment != nil { advances += 1 }
        }
        guard prepared.paths.isEmpty || !kernel.winners.isEmpty else { throw RouteSearchFailure.searchIncomplete }
        if let selectionStart { engine.recordSelection(selectionStart.duration(to: .now), advances: advances) }
        return .init(prepared: prepared, selected: kernel.winners.map { Handle(pathOrdinal: $0) })
    }

    func admit(engine: inout SyntheticInternalRouteEngine, rejecting indices: Set<Int>) async throws -> RouteSearchResult {
        var candidates: [RouteCandidate] = []
        var omissions: [RouteAlternativeOmission] = []
        for (index, handle) in selected.enumerated() {
            try await engine.step(.admission)
            // Handle construction and lookup are private to this exact session.
            guard prepared.paths.indices.contains(handle.pathOrdinal) else { throw RouteSearchFailure.dataUnavailable }
            let path = prepared.paths[handle.pathOrdinal]
            for _ in path { try await engine.step(.admission) }
            var claims = try SyntheticInternalRouteSearcher.claims(path, prepared)
            if indices.contains(index) {
                // Failure-only harness: impossible original index, never repaired evidence.
                let first = claims[0]
                claims[0] = .init(key: .init(address: first.key.address, boarding: first.key.boarding, alighting: -1),
                                  train: first.train, context: first.context)
            }
            switch try await engine.admit(claims, prepared: prepared) {
            case .success(let candidate): candidates.append(candidate)
            case .failure(let rejection):
                guard let omission = RouteAlternativeOmission(alternativeIndex: index, reasons: [rejection.reason]) else {
                    throw RouteSearchFailure.dataUnavailable
                }
                omissions.append(omission)
            }
        }
        return try await engine.finalizeOptimal(prepared: prepared, selectedCount: selected.count,
                                                candidates: candidates, omissions: omissions)
    }
}

/// No success-capable public mutation hook, replacement state or admission callback.
nonisolated enum SyntheticOptimalHandoffFailureHarness {
    enum Failure: Error { case expectedRejection }
    @concurrent
    static func rejectSelectedClaims(searcher: SyntheticOptimalRouteSearcher, request: RouteSearchRequest,
                                     selectedIndices: Set<Int>) async throws -> Never {
        _ = try await searcher.run(request, rejecting: selectedIndices)
        throw Failure.expectedRejection
    }
}
/// Bounded experiment: successful complete oracle qualification is mandatory on
/// EVERY invocation, before pruning. End-to-end cost includes both passes.
nonisolated struct SyntheticPruningRouteExperiment: RouteSearching {
    let configuration: SyntheticInternalConfiguration?
    let view: SyntheticInternalView?
    let workLimit: Int
    let checkpoint: @Sendable (SyntheticPruningMode, SyntheticInternalStage) async throws -> Void
    init(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?,
         workLimit: Int = SyntheticPruningBounds.workLimit,
         checkpoint: @escaping @Sendable (SyntheticPruningMode, SyntheticInternalStage) async throws -> Void = { _, _ in }) {
        self.configuration = configuration; self.view = view; self.workLimit = workLimit; self.checkpoint = checkpoint
    }
    @concurrent
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        try await compare(request).pruned.result
    }
    @concurrent
    func compare(_ request: RouteSearchRequest) async throws -> SyntheticPruningComparison {
        try await compare(request, rejecting: [])
    }
    fileprivate func compare(_ request: RouteSearchRequest, rejecting: Set<Int>) async throws -> SyntheticPruningComparison {
        try Task.checkCancellation()
        guard workLimit >= 0 && workLimit <= SyntheticPruningBounds.workLimit else {
            throw RouteSearchFailure.configurationUnavailable
        }
        let start = ContinuousClock.now
        try SyntheticPruningBounds.validate(configuration, view, request)
        let oracle = try await pass(request, mode: .exhaustive, rejecting: [])
        let pruned = try await pass(request, mode: .pruned, rejecting: rejecting)
        return .init(oracle: oracle, pruned: pruned, elapsed: start.duration(to: .now))
    }
    /// Observes the existing exhaustive pass independently for certificate tests.
    /// Not a replacement search entry; the published compare/search stays two-pass.
    @concurrent
    func observeOracleForCertificateTests(_ request: RouteSearchRequest) async throws -> SyntheticPruningPass {
        try Task.checkCancellation()
        guard workLimit >= 0 && workLimit <= SyntheticPruningBounds.workLimit else {
            throw RouteSearchFailure.configurationUnavailable
        }
        try SyntheticPruningBounds.validate(configuration, view, request)
        return try await pass(request, mode: .exhaustive, rejecting: [])
    }

    private func pass(_ request: RouteSearchRequest, mode: SyntheticPruningMode, rejecting: Set<Int>) async throws -> SyntheticPruningPass {
        let start = ContinuousClock.now
        var engine = SyntheticInternalRouteEngine(configuration: configuration, view: view, workLimit: workLimit,
            checkpoint: { try await checkpoint(mode, $0) }, experiment: mode)
        do {
            let session = try await PreparedOptimalSession.open(request, engine: &engine)
            let admissionStart = ContinuousClock.now
            let result = try await session.admit(engine: &engine, rejecting: rejecting)
            engine.recordAdmission(admissionStart.duration(to: .now))
            return .init(result: result, metrics: engine.metrics, elapsed: start.duration(to: .now))
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let canonical = error as? RouteSearchFailure { throw canonical }
            throw RouteSearchFailure.dataUnavailable
        }
    }
}
nonisolated enum SyntheticPruningRejectionHarness {
    enum Failure: Error { case expectedRejection }
    @concurrent
    static func reject(_ experiment: SyntheticPruningRouteExperiment, request: RouteSearchRequest,
                       indices: Set<Int>) async throws -> Never {
        _ = try await experiment.compare(request, rejecting: indices)
        throw Failure.expectedRejection
    }
}
#endif
