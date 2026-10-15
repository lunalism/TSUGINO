import Foundation
import Testing
@testable import TSUGINO

/// Invented captured views derived from SolverFixture worlds: the same view ID,
/// inventory, declarations and evidence, so composed and direct-solver outcomes are
/// comparable. Stipulated values only; no source, provider or real railway data.
struct PreparedRouteFixture {
    let f = SolverFixture()
    var objective: InternalSearchPolicyReference { .init(key: f.uuid(98), revision: f.uuid(99)) }
    func date(_ n: Double) -> Date { Date(timeIntervalSinceReferenceDate: n) }
    func station(_ s: String) throws -> StationID { try f.need(StationID(s)) }

    /// Mutable copy of every captured-view member, so a test changes exactly one.
    struct Parts {
        var validFrom: Date
        var validUntil: Date
        var connectionPolicy: InternalSearchPolicyReference
        var serviceDateInterpretation: InternalSearchPolicyReference
        var inventory: TimetableOccurrenceInventoryView
        var endpoints: [StationID: PreparedRouteEndpointDisposition]
        var occurrences: PreparedRouteOccurrenceDomain
        var relations: PreparedRouteRelationDomain
        var dependencies: PreparedRouteDependencyDomain
        var connections: PreparedRouteConnectionAuthority
        var view: PreparedRouteSearchView {
            .init(validFrom: validFrom, validUntil: validUntil, connectionPolicy: connectionPolicy,
                  serviceDateInterpretation: serviceDateInterpretation, inventory: inventory, endpoints: endpoints,
                  occurrences: occurrences, relations: relations, dependencies: dependencies, connections: connections)
        }
        mutating func editPositive(_ key: ConnectionRelationKey,
                                   _ edit: (PreparedRoutePositiveConnectionEntry) -> PreparedRoutePositiveConnectionEntry) {
            guard case let .positive(positive) = connections.entries[key] else { Issue.record("Expected positive entry"); return }
            var entries = connections.entries
            entries[key] = .positive(edit(positive))
            connections = .init(review: connections.review, completeness: connections.completeness, entries: entries)
        }
        mutating func setEntry(_ key: ConnectionRelationKey, _ entry: PreparedRouteConnectionEntry?) {
            var entries = connections.entries
            entries[key] = entry
            connections = .init(review: connections.review, completeness: connections.completeness, entries: entries)
        }
    }
    struct Case {
        let world: SolverFixture.World
        var parts: Parts
        var profile: InternalSearchProfileDefinition
        var request: RouteSearchRequest
        var configuration: InternalSolverExecutionConfiguration
        var view: PreparedRouteSearchView { parts.view }
        var firstKey: ConnectionRelationKey { ConnectionRelationKey(world.assessment.closure.connections.required[0]) }
    }

    func make(_ specs: [SolverFixture.Spec], links: [SolverFixture.Link] = [],
              occurrenceComplete: Bool = true, connectionComplete: Bool = true, evidenceComplete: Bool = true,
              dependency: Bool = false, maximumRides: Int = 7) throws -> Case {
        let world = try f.world(specs, links: links, occurrenceComplete: occurrenceComplete,
            connectionComplete: connectionComplete, evidenceComplete: evidenceComplete, dependency: dependency,
            maximumRides: maximumRides, origin: "O", destination: "D")
        let a = world.assessment, c = a.closure
        let parts = Parts(validFrom: date(0), validUntil: date(10_000),
            connectionPolicy: c.scope.profile.connectionPolicy,
            serviceDateInterpretation: c.scope.profile.serviceDateInterpretation,
            inventory: c.inventory,
            endpoints: Dictionary(uniqueKeysWithValues: c.scope.profile.stations.map { ($0, PreparedRouteEndpointDisposition.active) }),
            occurrences: .init(reference: c.occurrences.applicability.reference, completeness: c.occurrences.completeness,
                entries: c.occurrences.required.map {
                    .init(binding: $0.binding, intervalAuthority: $0.intervalAuthority, intervals: $0.intervals)
                }),
            relations: .init(reference: c.connections.applicability.reference, completeness: c.connections.completeness,
                targets: c.connections.required.map { ConnectionRelationKey($0) }),
            dependencies: .init(reference: c.dependencies.applicability.reference, unresolved: c.dependencies.unresolved),
            connections: .init(review: a.connections.qualification.review, completeness: a.connections.completeness,
                entries: Dictionary(uniqueKeysWithValues: a.connections.records.map { ($0.key, entry($0.state)) })))
        return Case(world: world, parts: parts, profile: c.scope.profile, request: c.scope.request,
                    configuration: .inventedEvaluation(objective: .init(reference: objective)))
    }

    /// Supplied form of an existing checked state: the inverse of the producer.
    func entry(_ state: ConnectionEvidenceState) -> PreparedRouteConnectionEntry {
        switch state {
        case let .present(p):
            .positive(.init(form: p.form, alighting: p.allowance.alighting, interchange: p.allowance.interchange,
                boarding: p.allowance.boarding, total: p.allowance.total, fromArrival: p.fromArrival,
                toDeparture: p.toDeparture, relation: .qualified(p.relation), genuineChange: .qualified(p.genuineChange),
                componentPartition: .qualified(p.componentPartition), endpointWideContext: .qualified(p.endpointWideContext)))
        case let .absent(n):
            .absence(relation: .qualified(n.relation), endpointWideContext: .qualified(n.endpointWideContext),
                     eventIndependent: .qualified(n.eventIndependent))
        case let .unavailable(reason): .unavailable(reason)
        }
    }

    func searcher(_ c: Case, _ supplier: InventedPreparedRouteViewSupplier,
                  configuration: InternalSolverExecutionConfiguration? = nil,
                  hooks: PreparedRouteSearchTestHooks? = nil) -> PreparedRouteSearcher {
        if let hooks {
            return .init(supplier: supplier, profile: c.profile, objective: objective,
                         configuration: configuration ?? c.configuration, hooks: hooks)
        }
        return .init(supplier: supplier, profile: c.profile, objective: objective, configuration: configuration ?? c.configuration)
    }

    /// The same P SolverFixture builds, solved directly by the existing solver.
    func direct(_ c: Case) async throws -> RouteSearchResult {
        let prepared = try PreparedInternalSearchInput(assessment: c.world.assessment, objective: .init(reference: objective))
        return try await InternalRouteSolver().solve(prepared, configuration: c.configuration)
    }

    /// The composition's S5–S8 steps run directly, for inspecting intermediate values.
    func prepareThroughProducers(_ c: Case) throws -> (RequestScopedSearchInputClosure, PreparedInternalSearchInput) {
        let view = c.view
        let scope = try f.need(InternalSearchScope(profile: c.profile, request: c.request, viewID: view.id))
        let d = try PreparedRouteDeclarationProducer.declarations(view: view, scope: scope)
        let closure = try RequestScopedSearchInputClosure(scope: scope, inventory: view.inventory, railway: view.railway,
            occurrences: d.occurrences, connections: d.connections, dependencies: d.dependencies)
        let evidence = try PreparedRouteConnectionEvidenceProducer.evidence(view: view, closure: closure)
        let assessment = try ResolvedSearchInputAssessment(closure: closure, connections: evidence)
        return (closure, try PreparedInternalSearchInput(assessment: assessment, objective: .init(reference: objective)))
    }

    /// Canonical outcome text: scope, then each candidate's legs with exact events.
    func summary(_ result: RouteSearchResult) -> [String] {
        guard case let .internalSuccess(success) = result else { return ["noncanonical"] }
        let s = success.scope
        var lines = ["scope \(s.viewID.rawValue) \(s.lowerBound.timeIntervalSinceReferenceDate) "
            + "\(s.upperBound.timeIntervalSinceReferenceDate) \(s.profile.identity.key) \(s.profile.trips.count)"]
        switch success.outcome {
        case .noResults: lines.append("noResults")
        case let .alternatives(batch):
            lines.append("omissions \(batch.omissions.count)")
            for route in batch.candidates {
                lines.append(route.legs.map { leg in
                    switch leg {
                    case let .rail(rail):
                        guard case let .matched(train) = rail.travel, case let .timetable(context) = rail.scheduledContext
                        else { return "noncanonical" }
                        let a = context.binding.address
                        return "\(a.tripID.rawValue)/\(a.serviceDate.label)/\(train.boardingIndex)-\(train.alightingIndex)"
                            + "@\(context.departure.timeIntervalSinceReferenceDate)-\(context.arrival.timeIntervalSinceReferenceDate)"
                    case let .walkingTransfer(walk):
                        return "walk \(walk.fromStationID.rawValue)->\(walk.toStationID.rawValue)"
                    }
                }.joined(separator: " | "))
            }
        }
        return lines
    }

    func label(_ error: any Error) -> String {
        if error is CancellationError { return "cancelled" }
        guard let failure = error as? RouteSearchFailure else { return "noncanonical \(error)" }
        switch failure {
        case let .invalidEndpoint(role, reason): return "endpoint \(role) \(reason)"
        case .unsupportedRequest: return "unsupported"
        case .dataUnavailable: return "data"
        case .configurationUnavailable: return "configuration"
        case .searchIncomplete: return "incomplete"
        case .noUsableAlternatives: return "rejected"
        default: return "unexpected \(failure)"
        }
    }
    func outcome(_ body: () async throws -> RouteSearchResult) async -> String {
        do {
            if case .internalSuccess = try await body() { return "success" }
            return "noncanonical success"
        } catch { return label(error) }
    }
    func outcome(_ task: Task<RouteSearchResult, any Error>) async -> String {
        await outcome { try await task.value }
    }

    nonisolated static func isMainThread() -> Bool { Thread.isMainThread }
}

/// Replaceable invented supplier: one linearized read per call, recording each capture.
actor InventedPreparedRouteViewSupplier: PreparedRouteViewSupplying {
    private var current: (label: String, view: PreparedRouteSearchView?)
    private(set) var captures: [String] = []
    init(_ view: PreparedRouteSearchView?, label: String = "V1") { current = (label, view) }
    func currentView() -> PreparedRouteSearchView? {
        captures.append(current.label)
        return current.view
    }
    func replace(_ view: PreparedRouteSearchView?, label: String) { current = (label, view) }
}

actor PreparedRouteStageRecorder {
    private(set) var stages: [PreparedRouteSearchStage] = []
    private(set) var onMain: [Bool] = []
    private var claimed = false
    private var count = 0
    func next() -> Int { count += 1; return count }
    func record(_ stage: PreparedRouteSearchStage, main: Bool = false) { stages.append(stage); onMain.append(main) }
    /// True exactly once, so only the first call blocks at a gate.
    func claim() -> Bool { defer { claimed = true }; return !claimed }
}
