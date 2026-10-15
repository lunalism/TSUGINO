import Foundation
import Testing
@testable import TSUGINO

/// Invented-only end-to-end composition (consumer §28.6). Every world, profile,
/// policy reference and solver configuration is stipulated test data.
struct PreparedRouteSearchCompositionTests {
    let p = PreparedRouteFixture()
    var f: SolverFixture { p.f }

    func direct() -> SolverFixture.Spec { f.ride("invented-direct") }
    func transfer() -> [SolverFixture.Spec] {
        [f.ride("invented-a", "O", "H", arrival: 1005), f.ride("invented-b", "H", "D", arrival: 1010, departure: 1005)]
    }
    func run(_ c: PreparedRouteFixture.Case, view: PreparedRouteSearchView?? = nil,
             request: RouteSearchRequest? = nil) async -> (String, [String]) {
        let supplier = InventedPreparedRouteViewSupplier(view ?? c.view)
        let result = await p.outcome { try await p.searcher(c, supplier).search(request ?? c.request) }
        return (result, await supplier.captures)
    }

    // MARK: Success parity

    @Test(arguments: 0...6) func composedEqualsDirectSolver(_ variant: Int) async throws {
        let specs: [SolverFixture.Spec]
        var links: [SolverFixture.Link] = []
        switch variant {
        case 0: specs = [direct()]
        case 1: specs = [f.ride("invented-slow", arrival: 1020)] + transfer(); links = [f.link(1, 2)]
        case 2:
            specs = [f.ride("invented-slow", arrival: 1030), f.ride("invented-a", "O", "H1", arrival: 1005),
                     f.ride("invented-b", "H2", "D", arrival: 1015, departure: 1010)]
            links = [f.link(1, 2, form: .walking, allowance: 5)]
        case 3: specs = [direct()] + transfer(); links = [f.link(1, 2)] // equal arrival: fewer changes wins
        case 4: specs = [f.ride("invented-z"), f.ride("invented-y", departure: 1001), f.ride("invented-x", arrival: 1020)]
        case 5: specs = [f.ride("invented-a", "O", "H", arrival: 1005), f.ride("invented-b", "H", "D", departure: 1000)]
        default: specs = transfer(); links = [f.link(1, 0, form: .walking)] // only a reverse, infeasible relation
        }
        let c = try p.make(specs, links: links)
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let composed = try await p.searcher(c, supplier).search(c.request)
        let expected = try await p.direct(c)
        #expect(p.summary(composed) == p.summary(expected))
        #expect(!p.summary(composed).contains("noncanonical"))
        let prepared = try PreparedInternalSearchInput(assessment: c.world.assessment, objective: .init(reference: p.objective))
        #expect(ExhaustivePreparedSolverOracle().winners(prepared).count == max(0, p.summary(expected).count - 2))
        #expect(await supplier.captures == ["V1"])
        if variant == 4 { #expect(p.summary(composed).count == 4) } // both equal optima, §24.4 order
        if variant >= 5 { #expect(p.summary(composed).last == "noResults") }
    }

    // MARK: Preflight order (DEC-079)

    @Test func preflightOrderAndPrecedence() async throws {
        let c = try p.make([direct()])
        var bad = c.parts
        bad.endpoints[try p.station("O")] = .invalid(.retired)
        // Configuration beats a missing view: no capture, no lower probing.
        var invalid = c
        invalid.configuration = .init(objective: .init(reference: p.objective), maximumWork: 0, maximumRetainedSlots: 1,
                                      maximumWinners: 1, maximumIdentityKeys: 1, maximumLogicalBytes: 1)
        #expect(await run(invalid, view: .some(nil)) == ("configuration", []))
        // View validity beats endpoints.
        #expect(await run(c, view: .some(nil)) == ("data", ["V1"]))
        var policy = bad; policy.connectionPolicy = .init(key: f.uuid(1), revision: f.uuid(2))
        #expect(await run(c, view: policy.view).0 == "data")
        var dates = bad; dates.serviceDateInterpretation = .init(key: f.uuid(3), revision: f.uuid(4))
        #expect(await run(c, view: dates.view).0 == "data")
        var interval = bad; interval.validUntil = interval.validFrom
        #expect(await run(c, view: interval.view).0 == "data")
        // Endpoints beat intent/bounds.
        var outside = bad; outside.validUntil = p.date(1000)
        #expect(await run(c, view: outside.view).0 == "endpoint origin retired")
        // Intent/bounds beat coverage; the provisional window mapping is unsupportedRequest.
        outside.endpoints[try p.station("O")] = .active
        outside.dependencies = .init(reference: c.parts.dependencies.reference, unresolved: [try f.ref("invented-dependency")])
        #expect(await run(c, view: outside.view) == ("unsupported", ["V1"]))
        var edge = c.parts; edge.validUntil = p.date(2900) // inclusive U = L + duration
        #expect(await run(c, view: edge.view).0 == "success")
        edge.validFrom = p.date(901)
        #expect(await run(c, view: edge.view).0 == "unsupported")
        // Origin active in the view but outside the profile.
        var stranger = c.parts
        stranger.endpoints[try p.station("Z")] = .active
        let request = try f.need(RouteSearchRequest(origin: p.station("Z"), destination: p.station("D"),
                                                    departNotBefore: p.date(900)))
        #expect(await run(c, view: stranger.view, request: request).0 == "unsupported")
    }

    @Test(arguments: [RouteSearchEndpointFailureReason.unknown, .retired, .conflicting, .unsupported])
    func endpointDispositionsFromCapturedViewOnly(_ reason: RouteSearchEndpointFailureReason) async throws {
        let c = try p.make([direct()])
        var origin = c.parts; origin.endpoints[try p.station("O")] = .invalid(reason)
        #expect(await run(c, view: origin.view).0 == "endpoint origin \(reason)")
        var destination = c.parts; destination.endpoints[try p.station("D")] = .invalid(reason)
        #expect(await run(c, view: destination.view).0 == "endpoint destination \(reason)")
        var both = destination; both.endpoints[try p.station("O")] = .invalid(.unsupported)
        #expect(await run(c, view: both.view).0 == "endpoint origin unsupported")
        var missing = c.parts; missing.endpoints[try p.station("D")] = nil
        #expect(await run(c, view: missing.view).0 == "endpoint destination unknown")
    }

    // MARK: Profile projection (DEC-080 V1)

    @Test(arguments: 0...2) func profileProjectionDropsNonProfileMembers(_ variant: Int) async throws {
        var specs = [direct(), f.ride("invented-a", "O", "H", arrival: 1005)]
        var links: [SolverFixture.Link] = []
        switch variant {
        case 0: specs.append(f.ride("invented-outside", "H", "D", arrival: 1006, departure: 1005)); links = [f.link(1, 2)]
        case 1: specs.append(f.ride("invented-b", "H", "D", arrival: 1006, departure: 1005)); links = [f.link(1, 2)]
        default:
            var through = SolverFixture.Spec()
            through.name = "invented-through"; through.stops = ["O", "M", "D"]; through.through = true
            through.base = 990; through.step = 5
            through.required = [.init(boardingIndex: 0, alightingIndex: 1), .init(boardingIndex: 0, alightingIndex: 2),
                                .init(boardingIndex: 1, alightingIndex: 2)]
            specs.append(through)
        }
        var c = try p.make(specs, links: links)
        let base = c.profile
        var stations = base.stations, lines = base.lines, trips = base.trips
        switch variant {
        case 0: trips.remove(try f.need(TripID("invented-outside")))
        case 1: stations.remove(try p.station("H"))
        default: lines.remove(try f.need(LineID("invented-line-b")))
        }
        c.profile = try f.need(InternalSearchProfileDefinition(identity: base.identity, stations: stations, lines: lines,
            trips: trips, maximumElapsedDuration: base.maximumElapsedDuration, maximumRailRides: base.maximumRailRides,
            connectionPolicy: base.connectionPolicy, serviceDateInterpretation: base.serviceDateInterpretation))
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let result = try await p.searcher(c, supplier).search(c.request)
        let routes = p.summary(result).dropFirst(2)
        #expect(Array(routes) == ["invented-direct/invented-day/0-1@1000.0-1010.0"])
        let (closure, prepared) = try p.prepareThroughProducers(c)
        // No profileConflict; only connection holds, which the assessment then resolves.
        #expect(closure.holds.allSatisfy { if case .connectionUnresolved = $0 { true } else { false } })
        #expect(prepared.assessment.isTechnicallyQualified)
        switch variant {
        case 0:
            #expect(closure.occurrences.required.count == 2 && closure.connections.required.isEmpty)
            let smaller = try p.make([direct(), f.ride("invented-a", "O", "H", arrival: 1005)])
            #expect(smaller.profile.hasSameDefinition(as: c.profile))
            #expect(p.summary(result) == p.summary(try await p.direct(smaller)))
        case 1:
            // Endpoints of the relation remain in the profile: the target is kept.
            #expect(closure.occurrences.required.allSatisfy { $0.intervals.count == ($0.binding.trip.id.rawValue == "invented-direct" ? 1 : 0) })
            #expect(closure.connections.required.count == 1 && prepared.connections.count == 1)
        default:
            let through = try #require(closure.occurrences.required.last)
            #expect(through.intervals == [.init(boardingIndex: 0, alightingIndex: 1)])
            #expect(prepared.rides.count == 3) // direct, invented-a and the kept line-a interval
        }
    }

    @Test func requiredWholeSuppliedDomainKeepsOutOfWindowDatesOutsideScope() async throws {
        var late = f.ride("invented-direct", arrival: 5010, departure: 5000); late.day = "invented-day-2"
        let c = try p.make([direct(), late])
        let (closure, prepared) = try p.prepareThroughProducers(c)
        #expect(closure.occurrences.required.count == 2) // R1: requiredness ignores dates
        #expect(prepared.intervalAccounting.map(\.state) == [.usable(rideIndex: 0), .outsideScope])
        let composed = try await p.searcher(c, InventedPreparedRouteViewSupplier(c.view)).search(c.request)
        #expect(p.summary(composed) == p.summary(try await p.direct(c)))
    }

    // MARK: Coverage and evidence (DEC-086 unknown required evidence)

    @Test(arguments: 0...17) func unknownOrContradictoryInputIsDataUnavailableDespiteDirectRide(_ variant: Int) async throws {
        var specs = [direct()] + transfer()
        var links = [f.link(1, 2)]
        var flags = (occurrence: true, connection: true, evidence: true, dependency: false)
        switch variant {
        case 0: flags.occurrence = false
        case 1: flags.connection = false
        case 2: var s = f.ride("invented-unloaded"); s.kind = 3; specs.append(s)
        case 3: var s = f.ride("invented-unavailable"); s.kind = 2; specs.append(s)
        case 4: var s = f.ride("invented-unknown-interval"); s.intervalComplete = false; s.positives = []; specs.append(s)
        case 5: links = [f.link(1, 2, kind: 2)]
        case 8: flags.dependency = true
        case 10: links = [f.link(1, 2, kind: 1)]; flags.evidence = false
        case 13: specs[2].kind = 1 // positive evidence at an inactive endpoint stays held (G2 not adopted)
        case 14: var s = f.ride("invented-unknown-permission"); s.boarding = [0: .unknown]; specs.append(s)
        case 15: var s = f.ride("invented-missing-event"); s.arrivals = [1: .missing]; specs.append(s)
        default: break
        }
        var c = try p.make(specs, links: links, occurrenceComplete: flags.occurrence, connectionComplete: flags.connection,
                           evidenceComplete: flags.evidence, dependency: flags.dependency)
        let key = c.firstKey
        switch variant {
        case 6: c.parts.setEntry(key, nil) // missing entry: insufficient evidence, never absence
        case 7: c.parts.editPositive(key) { e in .init(form: e.form, alighting: e.alighting, interchange: e.interchange,
            boarding: e.boarding, total: e.total, fromArrival: nil, toDeparture: e.toDeparture, relation: e.relation,
            genuineChange: e.genuineChange, componentPartition: e.componentPartition, endpointWideContext: e.endpointWideContext) }
        case 9: c.parts.editPositive(key) { e in .init(form: e.form, alighting: e.alighting, interchange: e.interchange,
            boarding: e.boarding, total: e.total, fromArrival: e.fromArrival, toDeparture: e.toDeparture, relation: .contradictory,
            genuineChange: e.genuineChange, componentPartition: e.componentPartition, endpointWideContext: e.endpointWideContext) }
        case 11: c.parts.editPositive(key) { e in .init(form: e.form, alighting: 1, interchange: 1,
            boarding: 0, total: 3, fromArrival: e.fromArrival, toDeparture: e.toDeparture, relation: e.relation,
            genuineChange: e.genuineChange, componentPartition: e.componentPartition, endpointWideContext: e.endpointWideContext) }
        case 12: c.parts.editPositive(key) { e in .init(form: e.form, alighting: e.alighting, interchange: e.interchange,
            boarding: e.boarding, total: e.total, fromArrival: TimetableInstant(p.date(1004)), toDeparture: e.toDeparture,
            relation: e.relation, genuineChange: e.genuineChange, componentPartition: e.componentPartition,
            endpointWideContext: e.endpointWideContext) }
        case 16:
            let ghost = TimetableOccurrenceAddress(viewID: c.view.id, tripID: try f.need(TripID("invented-ghost")),
                                                   serviceDate: try f.need(TimetableServiceDate("invented-day")))
            c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete,
                targets: c.parts.relations.targets + [.init(from: key.from, alightingIndex: 1, to: ghost, boardingIndex: 0)])
        case 17:
            c.parts.occurrences = .init(reference: c.parts.occurrences.reference, completeness: .declaredComplete,
                                        entries: c.parts.occurrences.entries + [c.parts.occurrences.entries[0]])
        default: break
        }
        // The direct ride alone would succeed; partial or direct-only output is never returned.
        #expect(try await p.direct(p.make([direct()])).isScopedAlternatives)
        #expect(await run(c) == ("data", ["V1"]))
    }

    @Test func suppliedExaminedInstantsPassThroughUnchanged() throws {
        var c = try p.make([direct()] + transfer(), links: [f.link(1, 2)])
        let key = c.firstKey
        let shifted = try f.need(TimetableInstant(p.date(1004)))
        c.parts.editPositive(key) { e in .init(form: e.form, alighting: e.alighting, interchange: e.interchange,
            boarding: e.boarding, total: e.total, fromArrival: shifted, toDeparture: e.toDeparture, relation: e.relation,
            genuineChange: e.genuineChange, componentPartition: e.componentPartition, endpointWideContext: e.endpointWideContext) }
        let scope = try f.need(InternalSearchScope(profile: c.profile, request: c.request, viewID: c.view.id))
        let d = try PreparedRouteDeclarationProducer.declarations(view: c.view, scope: scope)
        let closure = try RequestScopedSearchInputClosure(scope: scope, inventory: c.view.inventory, railway: c.view.railway,
            occurrences: d.occurrences, connections: d.connections, dependencies: d.dependencies)
        let evidence = try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closure)
        guard case let .present(positive) = try #require(evidence.records.first).state else {
            Issue.record("Expected positive"); return
        }
        #expect(positive.fromArrival == shifted) // not the inventory's 1005
        #expect(throws: ConnectionEvidenceFailure.applicabilityConflict) {
            try ResolvedSearchInputAssessment(closure: closure, connections: evidence)
        }
        c.parts.setEntry(key, nil)
        let missing = try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closure)
        guard case .unavailable(.insufficientEvidence) = try #require(missing.records.first).state else {
            Issue.record("Missing evidence must stay insufficient, never absent"); return
        }
    }

    @Test func suppliedDatedPairAbsenceResolvesInactiveEndpoint() async throws {
        var specs = [direct()] + transfer()
        specs[2].kind = 1
        let c = try p.make(specs, links: [f.link(1, 2, kind: 1)])
        let composed = try await p.searcher(c, InventedPreparedRouteViewSupplier(c.view)).search(c.request)
        #expect(p.summary(composed) == p.summary(try await p.direct(c)))
        #expect(Array(p.summary(composed).dropFirst(2)) == ["invented-direct/invented-day/0-1@1000.0-1010.0"])
    }

    // MARK: Safeguards and cutoff

    @Test func preparationSafeguardsAndSolverCutoffAreSearchIncomplete() async throws {
        let c = try p.make([direct()])
        var dependencies = c.parts
        dependencies.dependencies = .init(reference: c.parts.dependencies.reference,
            unresolved: try (0...SearchInputClosureLimits.dependencies).map { try f.ref("invented-dependency-\($0)") })
        #expect(await run(c, view: dependencies.view).0 == "incomplete") // closure resourceLimit
        var occurrences = c.parts
        occurrences.occurrences = .init(reference: c.parts.occurrences.reference, completeness: .declaredComplete,
            entries: Array(repeating: c.parts.occurrences.entries[0], count: SearchInputClosureLimits.occurrences + 1))
        #expect(await run(c, view: occurrences.view).0 == "incomplete") // closure occurrence limit, after projection

        var long = SolverFixture.Spec()
        long.stops = ["O"] + (1...70).map { "invented-l\($0)" } + ["D"]
        var other = long; other.name = "invented-other"
        let wide = try p.make([long, other])
        let (from, to) = (wide.world.bindings[0].address, wide.world.bindings[1].address)
        var relations = wide.parts
        relations.relations = .init(reference: wide.parts.relations.reference, completeness: .declaredComplete,
            targets: Array((1...71).flatMap { a in (0...70).map { b in
                ConnectionRelationKey(from: from, alightingIndex: a, to: to, boardingIndex: b) } }
                .prefix(ConnectionEvidenceLimits.relations + 1)))
        #expect(await run(wide, view: relations.view).0 == "incomplete") // evidence resourceLimit

        let tied = try p.make([f.ride("invented-z"), f.ride("invented-y", departure: 1001)])
        for configuration in [
            InternalSolverExecutionConfiguration(objective: tied.configuration.objective,
                maximumWork: tied.configuration.maximumWork, maximumRetainedSlots: tied.configuration.maximumRetainedSlots,
                maximumWinners: 1, maximumIdentityKeys: tied.configuration.maximumIdentityKeys,
                maximumLogicalBytes: tied.configuration.maximumLogicalBytes),
            InternalSolverExecutionConfiguration(objective: tied.configuration.objective, maximumWork: 50,
                maximumRetainedSlots: 1_000, maximumWinners: 8, maximumIdentityKeys: 1_000, maximumLogicalBytes: 1 << 24)] {
            let supplier = InventedPreparedRouteViewSupplier(tied.view)
            let searcher = p.searcher(tied, supplier, configuration: configuration)
            #expect(await p.outcome { try await searcher.search(tied.request) } == "incomplete")
        }
    }

    @Test func closureLimitsApplyToProjectedDomainOnly() async throws {
        var c = try p.make([direct(), f.ride("invented-outside", arrival: 1005)])
        let base = c.profile
        c.profile = try f.need(InternalSearchProfileDefinition(identity: base.identity, stations: base.stations,
            lines: base.lines, trips: [try f.need(TripID("invented-direct"))],
            maximumElapsedDuration: base.maximumElapsedDuration, maximumRailRides: base.maximumRailRides,
            connectionPolicy: base.connectionPolicy, serviceDateInterpretation: base.serviceDateInterpretation))
        let outside = c.parts.occurrences.entries[1]
        c.parts.occurrences = .init(reference: c.parts.occurrences.reference, completeness: .declaredComplete,
            entries: [c.parts.occurrences.entries[0]]
                + Array(repeating: outside, count: SearchInputClosureLimits.occurrences + 1))
        // Only the unprojected supplied domain exceeds the closure's occurrence limit.
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let result = try await p.searcher(c, supplier).search(c.request)
        #expect(Array(p.summary(result).dropFirst(2)) == ["invented-direct/invented-day/0-1@1000.0-1010.0"])
    }

    @Test func provisionalMappingsArePinnedAtOnePoint() {
        #expect(p.label(PreparedRouteSearchProvisionalMapping.windowOutsideViewValidity) == "unsupported")
        #expect(p.label(PreparedRouteSearchProvisionalMapping.preparationResourceLimit) == "incomplete")
        #expect(p.label(PreparedRouteSearchFailureMapping.closure(.resourceLimit)) == "incomplete")
        #expect(p.label(PreparedRouteSearchFailureMapping.evidence(.resourceLimit)) == "incomplete")
        #expect(p.label(PreparedRouteSearchFailureMapping.prepared(.resourceLimit)) == "incomplete")
        #expect(p.label(PreparedRouteSearchFailureMapping.closure(.profileConflict)) == "data")
        #expect(p.label(PreparedRouteSearchFailureMapping.evidence(.endpointConflict)) == "data")
        #expect(p.label(PreparedRouteSearchFailureMapping.prepared(.assessmentNotQualified)) == "data")
        #expect(p.label(PreparedRouteSearchFailureMapping.prepared(.permissionUnknown(occurrence: 0, interval: 0))) == "data")
    }

    // MARK: Configuration

    @Test func configurationValidatedBeforeCaptureIncludingObjective() async throws {
        let c = try p.make([direct()])
        let objective = c.configuration.objective
        let other = InternalRouteObjectiveDefinition(reference: .init(key: f.uuid(7), revision: f.uuid(8)))
        let invalid: [InternalSolverExecutionConfiguration] = [
            .inventedEvaluation(objective: other),
            .init(objective: objective, maximumWork: 0, maximumRetainedSlots: 1, maximumWinners: 1,
                  maximumIdentityKeys: 1, maximumLogicalBytes: 1),
            .init(objective: objective, maximumWork: 100_000_001, maximumRetainedSlots: 1, maximumWinners: 1,
                  maximumIdentityKeys: 1, maximumLogicalBytes: 1),
            .init(objective: objective, maximumWork: 1, maximumRetainedSlots: 1, maximumWinners: 257,
                  maximumIdentityKeys: 1, maximumLogicalBytes: 1)]
        for configuration in invalid {
            let supplier = InventedPreparedRouteViewSupplier(c.view)
            let searcher = p.searcher(c, supplier, configuration: configuration)
            #expect(await p.outcome { try await searcher.search(c.request) } == "configuration")
            #expect(await supplier.captures.isEmpty)
        }
        // The direct solver reports the same objective mismatch as dataUnavailable (§24.8);
        // composition makes it unreachable for a valid configuration.
        let prepared = try PreparedInternalSearchInput(assessment: c.world.assessment, objective: objective)
        #expect(await p.outcome { try await InternalRouteSolver().solve(prepared, configuration: invalid[0]) } == "data")
    }

    // MARK: Cancellation

    @Test(arguments: PreparedRouteSearchStage.allCases) func cancellationAtEveryStageBoundary(_ stage: PreparedRouteSearchStage) async throws {
        let c = try p.make([direct()] + transfer(), links: [f.link(1, 2)])
        let recorder = PreparedRouteStageRecorder(), supplier = InventedPreparedRouteViewSupplier(c.view)
        let searcher = p.searcher(c, supplier, hooks: .init(checkpoint: { s in
            await recorder.record(s)
            if s == stage { withUnsafeCurrentTask { $0?.cancel() } }
        }))
        #expect(await p.outcome(Task { try await searcher.search(c.request) }) == "cancelled")
        let all = PreparedRouteSearchStage.allCases
        #expect(await recorder.stages == Array(all[...all.firstIndex(of: stage)!]))
        #expect(await supplier.captures == (stage == .entry || stage == .configuration ? [] : ["V1"]))
    }

    @Test func cancellationBeforeEntryInsideSolverAndBeforePendingFailure() async throws {
        let c = try p.make([direct()])
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let plain = p.searcher(c, supplier)
        #expect(await p.outcome(Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await plain.search(c.request)
        }) == "cancelled")
        #expect(await supplier.captures.isEmpty)

        let solverStages = PreparedRouteStageRecorder()
        let inside = p.searcher(c, supplier, hooks: .init(checkpoint: { await solverStages.record($0) },
            solver: .init(checkpoint: { stage, _ in if stage == .exploration { withUnsafeCurrentTask { $0?.cancel() } } })))
        #expect(await p.outcome(Task { try await inside.search(c.request) }) == "cancelled")
        #expect(await solverStages.stages.last == .preparedInput)

        struct Pending: Error {}
        let pending = p.searcher(c, supplier, hooks: .init(checkpoint: { stage in
            if stage == .assessment { withUnsafeCurrentTask { $0?.cancel() }; throw Pending() }
        }))
        #expect(await p.outcome(Task { try await pending.search(c.request) }) == "cancelled")
        let generic = p.searcher(c, supplier, hooks: .init(checkpoint: { if $0 == .assessment { throw Pending() } }))
        #expect(await p.outcome(Task { try await generic.search(c.request) }) == "data")
        // A pending canonical failure also loses to observed cancellation, and is rethrown unchanged otherwise.
        let canonical = p.searcher(c, supplier, hooks: .init(checkpoint: { stage in
            if stage == .scope { withUnsafeCurrentTask { $0?.cancel() }; throw RouteSearchFailure.invalidEndpoint(.origin, .unknown) }
        }))
        #expect(await p.outcome(Task { try await canonical.search(c.request) }) == "cancelled")
        let rethrown = p.searcher(c, supplier, hooks: .init(checkpoint: { stage in
            if stage == .scope { throw RouteSearchFailure.invalidEndpoint(.origin, .unknown) }
        }))
        #expect(await p.outcome(Task { try await rethrown.search(c.request) }) == "endpoint origin unknown")
    }

    // MARK: Replacement, overlap and isolation

    @Test func inFlightCallKeepsV1AfterReplacementAndLaterCallCapturesV2() async throws {
        let v1 = try p.make([direct()])
        let v2 = try p.make([f.ride("invented-direct", arrival: 1020), f.ride("invented-v2", arrival: 1015)])
        let supplier = InventedPreparedRouteViewSupplier(v1.view), gate = RoutingTestGate()
        let recorder = PreparedRouteStageRecorder()
        // Both cases bind the same invented profile shape; the searcher's profile admits both worlds.
        let profile = try f.need(InternalSearchProfileDefinition(identity: v1.profile.identity, stations: v1.profile.stations,
            lines: v1.profile.lines, trips: v1.profile.trips.union(v2.profile.trips),
            maximumElapsedDuration: v1.profile.maximumElapsedDuration, maximumRailRides: v1.profile.maximumRailRides,
            connectionPolicy: v1.profile.connectionPolicy, serviceDateInterpretation: v1.profile.serviceDateInterpretation))
        var bound = v1; bound.profile = profile
        let searcher = p.searcher(bound, supplier, hooks: .init(checkpoint: { stage in
            if stage == .closure, await recorder.claim() { try await gate.wait() }
        }))
        let first = Task { try await searcher.search(v1.request) }
        await gate.waitUntilEntered()
        await supplier.replace(v2.view, label: "V2")
        let second = try await searcher.search(v1.request)
        await gate.release()
        let firstResult = try await first.value
        #expect(Array(p.summary(firstResult).dropFirst(2)) == ["invented-direct/invented-day/0-1@1000.0-1010.0"])
        #expect(Array(p.summary(second).dropFirst(2)) == ["invented-v2/invented-day/0-1@1000.0-1015.0"])
        #expect(await supplier.captures == ["V1", "V2"])
        #expect(await gate.cancellationObserved == false)
    }

    @Test func overlappingCallsAreIndependentAndEachCapturesOnce() async throws {
        let c = try p.make([direct()])
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let gateA = RoutingTestGate(), gateB = RoutingTestGate(), recorder = PreparedRouteStageRecorder()
        let searcher = p.searcher(c, supplier, hooks: .init(checkpoint: { stage in
            guard stage == .evidence else { return }
            switch await recorder.next() {
            case 1: try await gateA.wait()
            case 2: try await gateB.wait()
            default: break
            }
        }))
        let a = Task { try await searcher.search(c.request) }
        await gateA.waitUntilEntered()
        let b = Task { try await searcher.search(c.request) }
        await gateB.waitUntilEntered()
        // Both calls are in flight; cancelling A must not affect B or the supplier.
        a.cancel()
        #expect(await p.outcome(a) == "cancelled")
        #expect(await gateA.cancellationObserved)
        #expect(await gateB.cancellationObserved == false)
        await gateB.release()
        let other = try await b.value
        #expect(p.summary(other) == p.summary(try await p.direct(c)))
        #expect(await supplier.captures == ["V1", "V1"])
        let after = try await searcher.search(c.request)
        #expect(p.summary(after) == p.summary(other))
        #expect(await supplier.captures == ["V1", "V1", "V1"])
        await gateA.release()
    }

    @MainActor @Test func mainActorCallerRunsEveryStageOffMain() async throws {
        let c = try p.make([direct()] + transfer(), links: [f.link(1, 2)])
        let recorder = PreparedRouteStageRecorder()
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: .init(checkpoint: { stage in
            await recorder.record(stage, main: PreparedRouteFixture.isMainThread())
        }))
        _ = try await searcher.search(c.request)
        #expect(await recorder.stages == PreparedRouteSearchStage.allCases)
        #expect(await recorder.onMain.allSatisfy { !$0 })
    }

    // MARK: Application lifecycle (DEC-087), unchanged coordinator

    @MainActor @Test func coordinatorPublishesCompletedFailedAndCancelledAttempts() async throws {
        let c = try p.make([direct()])
        let gate = RoutingTestGate()
        func owner(_ view: PreparedRouteSearchView?, gated: Bool = false) throws -> RouteSearchCoordinator {
            let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(view), hooks: .init(checkpoint: { stage in
                if gated, stage == .closure { try await gate.wait() }
            }))
            let environment = AppEnvironment(configuration: try .forTesting(), clock: FixedAppClock(now: p.date(900)),
                logging: AppLogging(subsystem: "prepared-route-test", sink: RecordingLogSink()), routeSearching: searcher)
            guard case let .ready(owner) = environment.makeRouteSearchCoordinator() else { throw CancellationError() }
            return owner
        }
        let intent = RouteSearchIntent(origin: try p.station("O"), destination: try p.station("D"), departure: .now)

        let completed = try owner(c.view)
        guard case .accepted = completed.submit(intent) else { Issue.record("Expected acceptance"); return }
        await completed.completionCheckpointForTesting()()
        guard case let .completed(attempt, result) = completed.state else { Issue.record("Expected completion"); return }
        #expect(attempt.request.departNotBefore == p.date(900))
        #expect(p.summary(result) == p.summary(try await p.direct(c)))
        completed.dispose()

        let failed = try owner(nil)
        guard case .accepted = failed.submit(intent) else { Issue.record("Expected acceptance"); return }
        await failed.completionCheckpointForTesting()()
        guard case .failed(_, .dataUnavailable) = failed.state else { Issue.record("Expected dataUnavailable"); return }
        failed.dispose()

        let cancelled = try owner(c.view, gated: true)
        guard case let .accepted(id) = cancelled.submit(intent) else { Issue.record("Expected acceptance"); return }
        let join = cancelled.completionCheckpointForTesting()
        await gate.waitUntilEntered()
        #expect(cancelled.cancel(id))
        await join()
        guard case .cancelled = cancelled.state else { Issue.record("Expected cancellation"); return }
        #expect(await gate.cancellationObserved)
        cancelled.dispose()
        await gate.release()
    }
}

private extension RouteSearchResult {
    var isScopedAlternatives: Bool {
        if case let .internalSuccess(success) = self, case .alternatives = success.outcome { return true }
        return false
    }
}
