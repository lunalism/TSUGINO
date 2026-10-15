import Foundation

/// Composition checkpoints (consumer §27.3 S0–S10). Each is followed by a cancellation check.
nonisolated enum PreparedRouteSearchStage: CaseIterable, Hashable, Sendable {
    case entry, configuration, capture, viewValidity, endpoints, scope
    case declarations, closure, evidence, assessment, preparedInput, solve
}

/// PROVISIONAL user-visible mappings, pending owner confirmation for production
/// (consumer §27.9, §28.6). Pinned by tests; this implementation is not acceptance.
nonisolated enum PreparedRouteSearchProvisionalMapping {
    /// The request window [L, U] is not inside the captured view's validity interval.
    static var windowOutsideViewValidity: RouteSearchFailure { .unsupportedRequest }
    /// A preparation safeguard (`resourceLimit`) over otherwise consistent input.
    static var preparationResourceLimit: RouteSearchFailure { .searchIncomplete }
}

/// Typed preparation failures, mapped explicitly before any generic fallback.
nonisolated enum PreparedRouteSearchFailureMapping {
    static func closure(_ failure: SearchInputClosureConstructionFailure) -> RouteSearchFailure {
        failure == .resourceLimit ? PreparedRouteSearchProvisionalMapping.preparationResourceLimit : .dataUnavailable
    }
    static func evidence(_ failure: ConnectionEvidenceFailure) -> RouteSearchFailure {
        failure == .resourceLimit ? PreparedRouteSearchProvisionalMapping.preparationResourceLimit : .dataUnavailable
    }
    static func prepared(_ failure: PreparedInputFailure) -> RouteSearchFailure {
        failure == .resourceLimit ? PreparedRouteSearchProvisionalMapping.preparationResourceLimit : .dataUnavailable
    }
}

#if DEBUG
/// Test-only seam, absent from Release. The checkpoint runs before each cancellation check.
nonisolated struct PreparedRouteSearchTestHooks: Sendable {
    var checkpoint: (@Sendable (PreparedRouteSearchStage) async throws -> Void)?
    var solver: InternalSolverTestHooks?
}
#endif

/// Data-owned RouteSearching over one captured prepared view. INVENTED INTEGRATION
/// ONLY: not registered in AppEnvironment; live routing stays unconfigured. Profile,
/// objective and execution configuration are immutable bindings chosen by the composer.
/// It only sequences and maps: B/A/P constructors and the solver own every truth check.
/// All per-call state is local; no retry, partial result or publication (DEC-087).
nonisolated struct PreparedRouteSearcher: RouteSearching {
    private let supplier: any PreparedRouteViewSupplying
    let profile: InternalSearchProfileDefinition
    let objective: InternalRouteObjectiveDefinition
    let configuration: InternalSolverExecutionConfiguration
    #if DEBUG
    private var hooks: PreparedRouteSearchTestHooks?
    #endif

    init(supplier: any PreparedRouteViewSupplying, profile: InternalSearchProfileDefinition,
         objective: InternalSearchPolicyReference, configuration: InternalSolverExecutionConfiguration) {
        self.supplier = supplier; self.profile = profile
        self.objective = InternalRouteObjectiveDefinition(reference: objective)
        self.configuration = configuration
    }
    #if DEBUG
    init(supplier: any PreparedRouteViewSupplying, profile: InternalSearchProfileDefinition,
         objective: InternalSearchPolicyReference, configuration: InternalSolverExecutionConfiguration,
         hooks: PreparedRouteSearchTestHooks) {
        self.init(supplier: supplier, profile: profile, objective: objective, configuration: configuration)
        self.hooks = hooks
    }
    #endif

    @concurrent
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        do {
            return try await run(request)
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let failure = error as? RouteSearchFailure { throw failure }
            throw RouteSearchFailure.dataUnavailable
        }
    }

    private func run(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        try await checkpoint(.entry)
        // S1 configuration (DEC-079 1): the solver meter's own validation plus objective
        // correspondence, so the solver's objective-mismatch dataUnavailable is unreachable.
        _ = try InternalSolverMeter(configuration)
        guard configuration.objective.hasSameDefinition(as: objective) else {
            throw RouteSearchFailure.configurationUnavailable
        }
        try await checkpoint(.configuration)

        // S2 one capture (E2). Everything below reads only this value.
        let captured = await supplier.currentView()
        try await checkpoint(.capture)

        // S3 shared-view validity (DEC-079 2).
        guard let view = captured, view.supports(profile) else { throw RouteSearchFailure.dataUnavailable }
        try await checkpoint(.viewValidity)

        // S4 endpoints (DEC-079 3), origin then destination, from the captured view only.
        for (station, role) in [(request.origin, RouteSearchEndpointRole.origin), (request.destination, .destination)] {
            if case let .invalid(reason) = view.disposition(of: station) {
                throw RouteSearchFailure.invalidEndpoint(role, reason)
            }
        }
        try await checkpoint(.endpoints)

        // S5 profile intent/bounds (DEC-079 4).
        guard let scope = InternalSearchScope(profile: profile, request: request, viewID: view.id) else {
            throw RouteSearchFailure.unsupportedRequest
        }
        guard view.covers(scope) else { throw PreparedRouteSearchProvisionalMapping.windowOutsideViewValidity }
        try await checkpoint(.scope)

        // S6–S8 coverage (DEC-079 5): synchronous bounded constructors; cancellation
        // arriving inside one is observed at the next checkpoint only.
        let declarations: PreparedRouteDeclarations
        do throws(SearchInputClosureConstructionFailure) {
            declarations = try PreparedRouteDeclarationProducer.declarations(view: view, scope: scope)
        } catch { throw PreparedRouteSearchFailureMapping.closure(error) }
        try await checkpoint(.declarations)

        let closure: RequestScopedSearchInputClosure
        do throws(SearchInputClosureConstructionFailure) {
            closure = try RequestScopedSearchInputClosure(scope: scope, inventory: view.inventory, railway: view.railway,
                occurrences: declarations.occurrences, connections: declarations.connections,
                dependencies: declarations.dependencies)
        } catch { throw PreparedRouteSearchFailureMapping.closure(error) }
        try await checkpoint(.closure)

        let evidence: QualifiedConnectionEvidenceView
        do throws(ConnectionEvidenceFailure) {
            evidence = try PreparedRouteConnectionEvidenceProducer.evidence(view: view, closure: closure)
        } catch { throw PreparedRouteSearchFailureMapping.evidence(error) }
        try await checkpoint(.evidence)

        let assessment: ResolvedSearchInputAssessment
        do throws(ConnectionEvidenceFailure) {
            assessment = try ResolvedSearchInputAssessment(closure: closure, connections: evidence)
        } catch { throw PreparedRouteSearchFailureMapping.evidence(error) }
        // Unknown required evidence (DEC-086), even when a usable direct ride exists.
        guard assessment.isTechnicallyQualified else { throw RouteSearchFailure.dataUnavailable }
        try await checkpoint(.assessment)

        let prepared: PreparedInternalSearchInput
        do throws(PreparedInputFailure) {
            prepared = try PreparedInternalSearchInput(assessment: assessment, objective: objective)
        } catch { throw PreparedRouteSearchFailureMapping.prepared(error) }
        try await checkpoint(.preparedInput)

        // S9 unchanged solver with its own meter and §24.8 terminal outcomes; S10 return.
        let result = try await solve(prepared)
        try await checkpoint(.solve)
        return result
    }

    private func checkpoint(_ stage: PreparedRouteSearchStage) async throws {
        #if DEBUG
        try await hooks?.checkpoint?(stage)
        #endif
        try Task.checkCancellation()
    }

    private func solve(_ input: PreparedInternalSearchInput) async throws -> RouteSearchResult {
        #if DEBUG
        if let solverHooks = hooks?.solver {
            return try await InternalRouteSolver().solveForTesting(input, configuration: configuration, hooks: solverHooks)
        }
        #endif
        return try await InternalRouteSolver().solve(input, configuration: configuration)
    }
}
