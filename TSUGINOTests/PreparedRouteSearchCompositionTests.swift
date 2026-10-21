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

    // MARK: Local/express (Phase 3 test list; DEC-086 objective, §24.4 order)

    /// Invented train serving exactly `stops`, evenly timed, with only the declared intervals.
    func train(_ name: String, _ stops: [String], departure: Double, step: Double,
               rides: [(Int, Int)]) -> SolverFixture.Spec {
        var s = SolverFixture.Spec(); s.name = name; s.stops = stops; s.base = departure; s.step = step
        s.required = rides.map { .init(boardingIndex: $0.0, alightingIndex: $0.1) }; return s
    }
    /// Independent oracle winners, rendered like `summary` rail legs (same-station links only).
    func oracleRoutes(_ c: PreparedRouteFixture.Case) throws -> [String] {
        try oracleRoutes(PreparedInternalSearchInput(assessment: c.world.assessment, objective: .init(reference: p.objective)))
    }
    func oracleRoutes(_ prepared: PreparedInternalSearchInput) throws -> [String] {
        try ExhaustivePreparedSolverOracle().winners(prepared).map { keys in
            try keys.map { key in
                let ride = try #require(prepared.rides.first { $0.key == key })
                return "\(key.address.tripID.rawValue)/\(key.address.serviceDate.label)/\(key.boardingIndex)-\(key.alightingIndex)"
                    + "@\(ride.context.departure.timeIntervalSinceReferenceDate)-\(ride.context.arrival.timeIntervalSinceReferenceDate)"
            }.joined(separator: " | ")
        }
    }
    /// Composed = direct solver = oracle, exact routes in order, one capture; returns the routes.
    func localExpressRoutes(_ specs: [SolverFixture.Spec], links: [SolverFixture.Link] = []) async throws -> [String] {
        let c = try p.make(specs, links: links)
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let composed = p.summary(try await p.searcher(c, supplier).search(c.request))
        #expect(composed == p.summary(try await p.direct(c)))
        #expect(await supplier.captures == ["V1"])
        let routes = Array(composed.dropFirst(2))
        #expect(routes == (try oracleRoutes(c)))
        #expect(composed.dropFirst().first == (routes.isEmpty ? "noResults" : "omissions 0"))
        return routes
    }

    @Test func expressSkippingStopsArrivesEarlierAndWins() async throws {
        let local = train("invented-local", ["O", "A", "B", "D"], departure: 1000, step: 10, rides: [(0, 3)])
        let express = train("invented-express", ["O", "D"], departure: 1005, step: 15, rides: [(0, 1)])
        #expect(try await localExpressRoutes([local, express]) == ["invented-express/invented-day/0-1@1005.0-1020.0"])
    }

    /// A skipped station is absent from the express's own stop sequence. Here the express omits
    /// the requested origin (0) or destination (1); it is still prepared as an earlier usable ride,
    /// but none of its rides touches that endpoint, so the slower local is the only result.
    @Test(arguments: 0...1) func expressCannotUseUnservedRequestedStation(_ variant: Int) async throws {
        let local = train("invented-local", ["O", "M", "D"], departure: 1000, step: 10, rides: [(0, 2)])
        let express = variant == 0
            ? train("invented-express", ["U", "D"], departure: 1000, step: 15, rides: [(0, 1)])
            : train("invented-express", ["O", "E"], departure: 1000, step: 12, rides: [(0, 1)])
        let prepared = try PreparedInternalSearchInput(assessment: p.make([local, express]).world.assessment,
                                                       objective: .init(reference: p.objective))
        let rides = prepared.rides.filter { $0.train.trip.id.rawValue == "invented-express" }
        #expect(rides.count == 1)
        #expect(rides.allSatisfy { $0.context.arrival < p.date(1020) }) // earlier than the local
        if variant == 0 {
            let origin = try p.station("O")
            #expect(rides.allSatisfy { $0.train.anchors.boardingStationID != origin })
        } else {
            let destination = try p.station("D")
            #expect(rides.allSatisfy { $0.train.anchors.alightingStationID != destination })
        }
        #expect(try await localExpressRoutes([local, express]) == ["invented-local/invented-day/0-2@1000.0-1020.0"])
    }

    /// Equal arrival and equal (zero) changes: both distinct trips survive in §24.4 order,
    /// whatever the supplied order. Equal arrival with an extra change (1) is not a tie.
    @Test(arguments: 0...1) func equalOptimaNeedEqualArrivalAndEqualChanges(_ variant: Int) async throws {
        let express = train("invented-express", ["O", "D"], departure: 1010, step: 10, rides: [(0, 1)])
        if variant == 0 {
            let local = train("invented-local", ["O", "A", "D"], departure: 1000, step: 10, rides: [(0, 2)])
            let expected = ["invented-express/invented-day/0-1@1010.0-1020.0", "invented-local/invented-day/0-2@1000.0-1020.0"]
            #expect(try await localExpressRoutes([local, express]) == expected)
            #expect(try await localExpressRoutes([express, local]) == expected)
        } else {
            let first = train("invented-local-a", ["O", "M"], departure: 1000, step: 5, rides: [(0, 1)])
            let second = train("invented-local-b", ["M", "D"], departure: 1005, step: 15, rides: [(0, 1)])
            #expect(try await localExpressRoutes([first, second, express], links: [f.link(0, 1)])
                    == ["invented-express/invented-day/0-1@1010.0-1020.0"])
        }
    }

    /// Local O→M then express M→D (arrives 1015) beats the local through to D (1020) only with
    /// positive, feasible directional evidence (0). No relation (1), qualified absence (2) or an
    /// allowance the gap cannot meet (3) leaves the slower local; the shared station M never
    /// implies a connection. Unknown evidence (4) is dataUnavailable, not a fabricated transfer.
    @Test(arguments: 0...4) func localToExpressTransferNeedsExplicitDirectionalEvidence(_ variant: Int) async throws {
        let local = train("invented-local", ["O", "M", "D"], departure: 1000, step: 10, rides: [(0, 1), (0, 2)])
        let express = train("invented-express", ["M", "D"], departure: 1012, step: 3, rides: [(0, 1)])
        let links: [SolverFixture.Link] = switch variant {
        case 0: [f.link(0, 1, allowance: 2)]
        case 1: []
        case 2: [f.link(0, 1, kind: 1)]
        case 3: [f.link(0, 1, allowance: 5)]
        default: [f.link(0, 1, kind: 2)]
        }
        if variant == 4 {
            let c = try p.make([local, express], links: links)
            #expect(await run(c) == ("data", ["V1"]))
            #expect(throws: PreparedInputFailure.assessmentNotQualified) {
                try PreparedInternalSearchInput(assessment: c.world.assessment, objective: .init(reference: p.objective))
            }
            return
        }
        // Variants 1 and 3 share a result; the prepared relation state tells them apart.
        let prepared = try PreparedInternalSearchInput(assessment: p.make([local, express], links: links).world.assessment,
                                                       objective: .init(reference: p.objective))
        let states: [[PreparedConnectionState]] = [[.feasible], [], [.absentUnderCompleteAuthority], [.infeasible]]
        #expect(prepared.connections.map(\.state) == states[variant])
        if variant == 0 || variant == 3 {
            // Invented timing: the local reaches M at 1010 and the express leaves M at 1012, a
            // 2-second gap that an allowance of 2 meets and an allowance of 5 does not.
            let arrive = try #require(prepared.rides.first { $0.key.address.tripID.rawValue == "invented-local" && $0.key.alightingIndex == 1 })
            let leave = try #require(prepared.rides.first { $0.key.address.tripID.rawValue == "invented-express" })
            #expect(leave.context.departure.timeIntervalSince(arrive.context.arrival) == 2)
        }
        let routes = try await localExpressRoutes([local, express], links: links)
        #expect(routes == (variant == 0
            ? ["invented-local/invented-day/0-1@1000.0-1010.0 | invented-express/invented-day/0-1@1012.0-1015.0"]
            : ["invented-local/invented-day/0-2@1000.0-1020.0"]))
    }

    // MARK: Profile-boundary relations (DEC-088 D4)

    /// The case with the named stations/lines removed from its profile; everything else unchanged.
    func restricted(_ c: PreparedRouteFixture.Case, stations: [String] = [], lines: [String] = []) throws -> PreparedRouteFixture.Case {
        var c = c
        let base = c.profile
        var s = base.stations, l = base.lines
        for name in stations { s.remove(try p.station(name)) }
        for name in lines { l.remove(try f.need(LineID(name))) }
        c.profile = try f.need(InternalSearchProfileDefinition(identity: base.identity, stations: s, lines: l,
            trips: base.trips, maximumElapsedDuration: base.maximumElapsedDuration, maximumRailRides: base.maximumRailRides,
            connectionPolicy: base.connectionPolicy, serviceDateInterpretation: base.serviceDateInterpretation))
        return c
    }
    func requiredKeys(_ c: PreparedRouteFixture.Case) throws -> [ConnectionRelationKey] {
        try p.prepareThroughProducers(c).0.connections.required.map(ConnectionRelationKey.init)
    }
    /// Composed = the unchanged solver over the producer-built P = independent oracle over that
    /// P, exact routes in order, one capture. Returns the routes.
    func boundaryRoutes(_ c: PreparedRouteFixture.Case) async throws -> [String] {
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let composed = p.summary(try await p.searcher(c, supplier).search(c.request))
        let prepared = try p.prepareThroughProducers(c).1
        #expect(composed == p.summary(try await InternalRouteSolver().solve(prepared, configuration: c.configuration)))
        #expect(await supplier.captures == ["V1"])
        let routes = Array(composed.dropFirst(2))
        #expect(routes == (try oracleRoutes(prepared)))
        return routes
    }
    func link(_ from: Int, _ to: Int, alight: Int = 1, board: Int = 0, form: ConnectionForm = .sameStation,
              allowance: Double = 0) -> SolverFixture.Link {
        var l = f.link(from, to, form: form, allowance: allowance); l.alight = alight; l.board = board; return l
    }
    func slowDirect() -> SolverFixture.Spec { train("invented-direct", ["O", "D"], departure: 1000, step: 20, rides: [(0, 1)]) }

    /// A walking relation whose alighting (0) or boarding (1) station X is outside the profile is
    /// provably untraversable and dropped, so even missing evidence for it no longer fails the call.
    @Test(arguments: 0...1) func boundaryRelationIsExcludedEvenWithoutEvidence(_ variant: Int) async throws {
        let a = train("invented-a", ["O", variant == 0 ? "X" : "Y"], departure: 1000, step: 5, rides: [(0, 1)])
        let b = train("invented-b", [variant == 0 ? "Y" : "X", "D"], departure: 1006, step: 4, rides: [(0, 1)])
        let full = try p.make([slowDirect(), a, b], links: [link(1, 2, form: .walking, allowance: 1)])
        // With X in the profile, the walking transfer is the earliest route and is required.
        let walk = variant == 0 ? "walk X->Y" : "walk Y->X"
        let unrestricted = try await p.searcher(full, InventedPreparedRouteViewSupplier(full.view)).search(full.request)
        #expect(p.summary(unrestricted).last?.contains(walk) == true)
        var unknown = full; unknown.parts.setEntry(full.firstKey, nil)
        #expect(await run(unknown) == ("data", ["V1"]))
        for missing in [false, true] {
            var c = try restricted(full, stations: ["X"])
            if missing { c.parts.setEntry(full.firstKey, nil) }
            #expect(try requiredKeys(c).isEmpty)
            #expect(try await boundaryRoutes(c) == ["invented-direct/invented-day/0-1@1000.0-1020.0"])
        }
    }

    /// Relations whose alighting and boarding stations are both in the profile stay required:
    /// plain (0), untraversable only because a line is outside the profile (1), and repeated
    /// station visits addressed by exact index (2).
    @Test(arguments: 0...2) func relationsAtProfileStationsStayRequired(_ variant: Int) async throws {
        let b = train("invented-b", ["H", "D"], departure: 1005, step: 5, rides: [(0, 1)])
        switch variant {
        case 0:
            let a = train("invented-a", ["O", "H"], departure: 1000, step: 5, rides: [(0, 1)])
            let c = try p.make([slowDirect(), a, b], links: [link(1, 2)])
            #expect(try requiredKeys(c) == [c.firstKey])
            #expect(try await boundaryRoutes(c) == ["invented-a/invented-day/0-1@1000.0-1005.0 | invented-b/invented-day/0-1@1005.0-1010.0"])
            var missing = c; missing.parts.setEntry(c.firstKey, nil)
            #expect(await run(missing) == ("data", ["V1"]))
        case 1:
            var a = train("invented-a", ["O", "M", "H"], departure: 995, step: 5, rides: [(0, 2)]); a.through = true
            let c = try restricted(try p.make([slowDirect(), a, b], links: [link(1, 2, alight: 2)]), lines: ["invented-line-b"])
            #expect(try requiredKeys(c) == [c.firstKey]) // the ride is gone, but only a line excludes it
            #expect(try await boundaryRoutes(c) == ["invented-direct/invented-day/0-1@1000.0-1020.0"])
            var missing = c; missing.parts.setEntry(c.firstKey, nil)
            #expect(await run(missing) == ("data", ["V1"]))
        default:
            let a = train("invented-a", ["O", "H", "X", "H"], departure: 1000, step: 5, rides: [(0, 1)])
            let full = try p.make([slowDirect(), a, b],
                links: [link(1, 2), link(1, 2, alight: 3), link(1, 2, alight: 2, form: .walking)])
            let keys = full.world.assessment.closure.connections.required.map(ConnectionRelationKey.init)
            let c = try restricted(full, stations: ["X"])
            #expect(try requiredKeys(c) == [keys[0], keys[1]]) // H at indices 1 and 3 kept; X at index 2 dropped
            #expect(try await boundaryRoutes(c) == ["invented-a/invented-day/0-1@1000.0-1005.0 | invented-b/invented-day/0-1@1005.0-1010.0"])
        }
    }

    /// The exclusion depends on station membership only, never on the service date: the same
    /// recurring Trip on a prior service date whose events fall inside [L, U] is treated alike.
    @Test(arguments: [true, false]) func boundaryExclusionIgnoresServiceDate(_ outside: Bool) throws {
        let station = outside ? "X" : "H"
        var prior = train("invented-a", ["O", station], departure: 1000, step: 5, rides: [(0, 1)]); prior.day = "invented-day-0"
        let current = train("invented-a", ["O", station], departure: 1000, step: 5, rides: [(0, 1)])
        let b = train("invented-b", [outside ? "Y" : "H", "D"], departure: 1006, step: 4, rides: [(0, 1)])
        let form: ConnectionForm = outside ? .walking : .sameStation
        let full = try p.make([slowDirect(), prior, current, b],
                              links: [link(1, 3, form: form, allowance: 1), link(2, 3, form: form, allowance: 1)])
        let c = try restricted(full, stations: outside ? ["X"] : [])
        let keys = full.world.assessment.closure.connections.required.map(ConnectionRelationKey.init)
        #expect(Set(keys.map(\.from.serviceDate.label)) == ["invented-day-0", "invented-day"])
        #expect(try requiredKeys(c) == (outside ? [] : keys))
    }

    /// Runs only the S6 producer and S7 closure, so a test can assert the closure's typed failure.
    @discardableResult
    func closureOnly(_ c: PreparedRouteFixture.Case) throws -> RequestScopedSearchInputClosure {
        let scope = try f.need(InternalSearchScope(profile: c.profile, request: c.request, viewID: c.view.id))
        let d = try PreparedRouteDeclarationProducer.declarations(view: c.view, scope: scope)
        return try RequestScopedSearchInputClosure(scope: scope, inventory: c.view.inventory, railway: c.view.railway,
            occurrences: d.occurrences, connections: d.connections, dependencies: d.dependencies)
    }

    /// Relations the closure rejects keep that exact rejection even where a station is outside
    /// the profile, so D4 never filters them away. In variants 0, 1, 4, 7, 8, 9 and 10, `extra[0]`
    /// is the single malformed relation and sits at the boundary station X on at least one side.
    /// Variants 2, 5 and 6 use the valid excludable relation (a@1 at H → e@0 at X): duplicated (2),
    /// beside a duplicated occurrence address (5), or alone (6). Variant 3's `extra[0]` is the
    /// in-profile H/H key, whose duplicate is what the closure rejects, followed by the excludable
    /// relation. The closure's typed failure (its implemented constructor contract) is asserted,
    /// and the composed call stays dataUnavailable (consumer §27.5).
    /// Cases: index-0 alighting (0); last-index boarding (1); duplicated excludable key (2);
    /// duplicated in-profile key beside an excludable one (3); undeclared address (4);
    /// duplicated occurrence address (5); valid excludable alone succeeds (6); out-of-range
    /// alighting (7); out-of-range boarding (8); wrong view ID (9); negative boarding (10).
    @Test(arguments: 0...10) func boundaryRelationsFailingClosureChecksStayRejected(_ variant: Int) async throws {
        let a = train("invented-a", ["O", "H"], departure: 1000, step: 5, rides: [(0, 1)])
        let b = train("invented-b", ["H", "D"], departure: 1005, step: 5, rides: [(0, 1)])
        let e = train("invented-e", ["X", "D"], departure: 1000, step: 30, rides: [(0, 1)])
        let g = train("invented-g", ["H", "X"], departure: 1000, step: 30, rides: [(0, 1)])
        var c = try restricted(try p.make([slowDirect(), a, b, e, g], links: [link(1, 2)]), stations: ["X"])
        let bindings = c.world.bindings
        func address(_ i: Int) -> TimetableOccurrenceAddress { bindings[i].address }
        let inProfile = c.firstKey
        // Valid and excludable: alights a at H, boards e at X (outside the profile).
        let excludable = ConnectionRelationKey(from: address(1), alightingIndex: 1, to: address(3), boardingIndex: 0)
        let ghost = TimetableOccurrenceAddress(viewID: c.view.id, tripID: try f.need(TripID("invented-ghost")),
                                               serviceDate: try f.need(TimetableServiceDate("invented-day")))
        let foreign = TimetableOccurrenceAddress(viewID: TimetableViewID(f.uuid(7)), tripID: address(3).tripID,
                                                 serviceDate: address(3).serviceDate)
        let extra: [ConnectionRelationKey] = switch variant {
        case 0: [.init(from: address(3), alightingIndex: 0, to: address(2), boardingIndex: 0)]   // alights X at index 0
        case 1: [.init(from: address(1), alightingIndex: 1, to: address(4), boardingIndex: 1)]   // boards X at last index
        case 2: [excludable, excludable]
        case 3: [inProfile, excludable]
        case 4: [.init(from: address(4), alightingIndex: 1, to: ghost, boardingIndex: 0)]        // alights X, undeclared to
        case 7: [.init(from: address(1), alightingIndex: 2, to: address(3), boardingIndex: 0)]   // boards X; alighting 2 == count
        case 8: [.init(from: address(4), alightingIndex: 1, to: address(2), boardingIndex: 5)]   // alights X; boarding past end
        case 9: [.init(from: address(4), alightingIndex: 1, to: foreign, boardingIndex: 0)]      // alights X; other view
        case 10: [.init(from: address(4), alightingIndex: 1, to: address(2), boardingIndex: -1)] // alights X; negative
        default: [excludable]
        }
        #expect(try PreparedRouteDeclarationProducer.untraversableAtProfileBoundary(extra[0],
            kept: Dictionary(uniqueKeysWithValues: bindings.map { ($0.address, $0.trip) }),
            scope: try f.need(InternalSearchScope(profile: c.profile, request: c.request, viewID: c.view.id)))
            == [2, 5, 6].contains(variant))
        c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete,
                                  targets: c.parts.relations.targets + extra)
        if variant == 5 {
            c.parts.occurrences = .init(reference: c.parts.occurrences.reference, completeness: .declaredComplete,
                                        entries: c.parts.occurrences.entries + [c.parts.occurrences.entries[1]])
        }
        if variant == 6 {
            #expect(try requiredKeys(c) == [inProfile])
            #expect(try await boundaryRoutes(c) == ["invented-a/invented-day/0-1@1000.0-1005.0 | invented-b/invented-day/0-1@1005.0-1010.0"])
            return
        }
        let failure: SearchInputClosureConstructionFailure = variant == 5 ? .declarationConflict : .connectionTargetConflict
        #expect(throws: failure) { try self.closureOnly(c) }
        #expect(await run(c) == ("data", ["V1"]))
        #expect(await runStages(c, view: c.view).1.last == .declarations) // rejected by the closure (S7)
    }

    /// D4 and the preparation relation limit (D2 unchanged). The limit applies to the retained,
    /// projected relations: more than `ConnectionEvidenceLimits.relations` retained in-profile
    /// relations is searchIncomplete (0). The same number of valid boundary relations is
    /// legitimately excluded and the call succeeds (1). A malformed (2) or duplicated (3) relation
    /// among them is not excluded, so the closure still rejects it.
    @Test(arguments: 0...3) func boundaryExclusionAndRelationLimit(_ variant: Int) async throws {
        let outside = (0..<40).map { "invented-x\($0)" }   // stations removed from the profile
        let inside = (0..<60).map { "invented-y\($0)" }
        let more = (0..<40).map { "invented-z\($0)" }
        let u = train("invented-u", outside, departure: 1000, step: 1, rides: [])
        let v = train("invented-v", inside, departure: 1000, step: 1, rides: [])
        let w = train("invented-w", more, departure: 1000, step: 1, rides: [])
        var c = try restricted(try p.make([slowDirect(), u, v, w]), stations: outside)
        let address = c.world.bindings.map(\.address)
        func keys(_ from: Int, _ fromStops: Int, _ to: Int, _ toStops: Int) -> [ConnectionRelationKey] {
            (1..<fromStops).flatMap { alight in (0..<(toStops - 1)).map { board in
                ConnectionRelationKey(from: address[from], alightingIndex: alight, to: address[to], boardingIndex: board) } }
        }
        let boundary = keys(1, outside.count, 2, inside.count)   // every one alights at a removed station
        let retained = keys(2, inside.count, 3, more.count)      // every station in the profile
        #expect(boundary.count > ConnectionEvidenceLimits.relations && retained.count > ConnectionEvidenceLimits.relations)
        #expect(boundary.count < SearchInputClosureLimits.connections && retained.count < SearchInputClosureLimits.connections)
        let extra: [ConnectionRelationKey] = switch variant {
        case 0: retained
        case 1: boundary
        case 2: boundary + [.init(from: address[1], alightingIndex: 0, to: address[2], boardingIndex: 0)]
        default: boundary + [boundary[0]]
        }
        c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete, targets: extra)
        #expect(await run(c).0 == ["incomplete", "success", "data", "data"][variant])
        switch variant {
        case 0:
            // The closure accepts every retained relation; the evidence relation limit is what refuses.
            let closure = try closureOnly(c)
            #expect(closure.connections.required.count == retained.count)
            #expect(throws: ConnectionEvidenceFailure.resourceLimit) {
                try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closure)
            }
        case 1:
            #expect(try requiredKeys(c).isEmpty)
            #expect(try await boundaryRoutes(c) == ["invented-direct/invented-day/0-1@1000.0-1020.0"])
        default: #expect(throws: SearchInputClosureConstructionFailure.connectionTargetConflict) { try self.closureOnly(c) }
        }
    }

    /// NB-2: the closure's own relation-count limit (checked before any structural check) applies to
    /// the retained, projected relations. More than `SearchInputClosureLimits.connections` retained
    /// in-profile relations are still a D2 searchIncomplete (0). The same number of valid boundary-only
    /// relations is excluded before that count, so the call succeeds (1); before D4 this was
    /// searchIncomplete. A malformed relation among them is therefore no longer masked by the count
    /// limit and reaches the closure's rejection, giving dataUnavailable (2). The byte budget is not
    /// exercised: bounded tokens keep at most `connections` targets far below it, and the count check
    /// fires first.
    @Test(arguments: 0...2) func boundaryExclusionPrecedesClosureCountLimit(_ variant: Int) async throws {
        let outside = (0..<72).map { "invented-x\($0)" }, inside = (0..<72).map { "invented-y\($0)" }
        let u = train("invented-u", outside, departure: 1000, step: 1, rides: [])
        let vs = (0..<5).map { train("invented-v\($0)", inside, departure: 1000, step: 1, rides: []) }
        let w = train("invented-w", inside, departure: 1000, step: 1, rides: [])
        var c = try restricted(try p.make([slowDirect(), u] + vs + [w]), stations: outside)
        let address = c.world.bindings.map(\.address)   // 0 direct, 1 u, 2...6 v0...v4, 7 w
        func keys(_ from: Int, _ to: Int) -> [ConnectionRelationKey] {
            (1..<72).flatMap { alight in (0..<71).map { board in
                ConnectionRelationKey(from: address[from], alightingIndex: alight, to: address[to], boardingIndex: board) } }
        }
        let boundary = (2...6).flatMap { keys(1, $0) }   // every key alights at a removed station
        let retained = (2...6).flatMap { keys($0, 7) }   // every station in the profile
        #expect(boundary.count > SearchInputClosureLimits.connections && retained.count > SearchInputClosureLimits.connections)
        let extra: [ConnectionRelationKey] = switch variant {
        case 0: retained
        case 1: boundary
        default: boundary + [.init(from: address[1], alightingIndex: 0, to: address[2], boardingIndex: 0)]
        }
        c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete, targets: extra)
        #expect(await run(c).0 == ["incomplete", "success", "data"][variant])
        switch variant {
        case 0: #expect(throws: SearchInputClosureConstructionFailure.resourceLimit) { try self.closureOnly(c) }
        case 1:
            #expect(try closureOnly(c).connections.required.isEmpty)
            #expect(try await boundaryRoutes(c) == ["invented-direct/invented-day/0-1@1000.0-1020.0"])
        default:
            #expect(throws: SearchInputClosureConstructionFailure.connectionTargetConflict) { try self.closureOnly(c) }
        }
    }

    /// Producer/closure agreement: an excluded relation has no ride at the excluded endpoint, and
    /// the producer's interval projection drops exactly what the closure would reject as profileConflict.
    @Test func boundaryPredicateMatchesPreparedRidesAndClosure() throws {
        let a = train("invented-a", ["O", "H", "X", "H"], departure: 1000, step: 5, rides: [(0, 1), (0, 2), (2, 3)])
        let b = train("invented-b", ["H", "D"], departure: 1005, step: 5, rides: [(0, 1)])
        let x = train("invented-x", ["X", "D"], departure: 1000, step: 30, rides: [(0, 1)])
        // Kept: a@1→b and a@3→b (H). Excluded: a@2 (X)→b alighting, and a@1→x@0 (X) boarding.
        let full = try p.make([slowDirect(), a, b, x], links: [link(1, 2), link(1, 2, alight: 2, form: .walking),
            link(1, 2, alight: 3), link(1, 3, form: .walking)])
        let c = try restricted(full, stations: ["X"])
        let scope = try f.need(InternalSearchScope(profile: c.profile, request: c.request, viewID: c.view.id))
        let (closure, prepared) = try p.prepareThroughProducers(c)
        let kept = Dictionary(uniqueKeysWithValues: closure.occurrences.required.map { ($0.binding.address, $0.binding.trip) })
        let required = Set(closure.connections.required.map(ConnectionRelationKey.init))
        var excludedCount = 0
        for key in c.view.relations.targets {
            let excluded = PreparedRouteDeclarationProducer.untraversableAtProfileBoundary(key, kept: kept, scope: scope)
            #expect(excluded == !required.contains(key))
            guard excluded else { continue }
            excludedCount += 1
            let alights = prepared.rides.contains { $0.key.address == key.from && $0.key.alightingIndex == key.alightingIndex }
            let boards = prepared.rides.contains { $0.key.address == key.to && $0.key.boardingIndex == key.boardingIndex }
            let alightOutside = try #require(kept[key.from]).stopSequence[key.alightingIndex] == (try p.station("X"))
            let boardOutside = try #require(kept[key.to]).stopSequence[key.boardingIndex] == (try p.station("X"))
            // The side at the removed station has no ride; the in-profile side does, so the
            // exclusion is due to the boundary station, not to both rides being absent anyway.
            #expect(alightOutside != boardOutside)
            #expect(alights == !alightOutside)
            #expect(boards == !boardOutside)
        }
        #expect(excludedCount == 2)
        // Unfiltered intervals: the closure throws profileConflict, as the producer predicted by dropping some.
        let d = try PreparedRouteDeclarationProducer.declarations(view: c.view, scope: scope)
        #expect(d.occurrences.required.map(\.intervals.count) != c.view.occurrences.entries.map(\.intervals.count))
        let unfiltered = c.view.occurrences.entries.map {
            SearchInputOccurrenceRequirement(binding: $0.binding, applicabilityReference: c.view.occurrences.reference,
                                             intervalAuthority: $0.intervalAuthority, intervals: $0.intervals)
        }
        #expect(throws: SearchInputClosureConstructionFailure.profileConflict) {
            try RequestScopedSearchInputClosure(scope: scope, inventory: c.view.inventory, railway: c.view.railway,
                occurrences: .init(applicability: d.occurrences.applicability, completeness: d.occurrences.completeness,
                                   required: unfiltered),
                connections: d.connections, dependencies: d.dependencies)
        }
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
        // Intent/bounds beat coverage. DEC-088 D1: a window outside view validity is
        // dataUnavailable, the same category as the unresolved dependency, so the stage
        // reached is what shows the window check (S5) fired before coverage (S6–S8).
        outside.endpoints[try p.station("O")] = .active
        outside.dependencies = .init(reference: c.parts.dependencies.reference, unresolved: [try f.ref("invented-dependency")])
        #expect(await run(c, view: outside.view) == ("data", ["V1"]))
        let throughEndpoints: [PreparedRouteSearchStage] = [.entry, .configuration, .capture, .viewValidity, .endpoints]
        #expect(await runStages(c, view: outside.view) == ("data", throughEndpoints))
        var dependencyOnly = c.parts; dependencyOnly.dependencies = outside.dependencies
        #expect(await runStages(c, view: dependencyOnly.view)
                == ("data", throughEndpoints + [.scope, .declarations, .closure, .evidence]))
        var edge = c.parts; edge.validUntil = p.date(2900) // inclusive U = L + duration
        #expect(await run(c, view: edge.view).0 == "success")
        edge.validFrom = p.date(901)
        #expect(await runStages(c, view: edge.view) == ("data", throughEndpoints))
        // Origin active in the view but outside the profile: unconstructible scope stays
        // unsupportedRequest, at the same stage as the D1 window failure.
        var stranger = c.parts
        stranger.endpoints[try p.station("Z")] = .active
        let request = try f.need(RouteSearchRequest(origin: p.station("Z"), destination: p.station("D"),
                                                    departNotBefore: p.date(900)))
        #expect(await run(c, view: stranger.view, request: request).0 == "unsupported")
        #expect(await runStages(c, view: stranger.view, request: request) == ("unsupported", throughEndpoints))
        // Both failures together: the unconstructible scope is detected first.
        var both = outside; both.endpoints[try p.station("Z")] = .active
        #expect(await runStages(c, view: both.view, request: request) == ("unsupported", throughEndpoints))
    }

    /// Outcome plus every checkpoint reached, to tell equal-category failures apart by stage.
    func runStages(_ c: PreparedRouteFixture.Case, view: PreparedRouteSearchView,
                   request: RouteSearchRequest? = nil) async -> (String, [PreparedRouteSearchStage]) {
        let recorder = PreparedRouteStageRecorder()
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(view),
                                  hooks: .init(checkpoint: { await recorder.record($0) }))
        let outcome = await p.outcome { try await searcher.search(request ?? c.request) }
        return (outcome, await recorder.stages)
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
            // Both occurrences stay, but the transfer station H is outside the profile: DEC-088 D4
            // drops the provably untraversable relation (formerly kept and required).
            #expect(closure.occurrences.required.allSatisfy { $0.intervals.count == ($0.binding.trip.id.rawValue == "invented-direct" ? 1 : 0) })
            #expect(closure.connections.required.isEmpty && prepared.connections.isEmpty)
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

    /// DEC-088 D1 end to end: the window failure reaches the Application owner and presentation
    /// as an ordinary dataUnavailable failure with the existing retry/edit/search actions.
    @MainActor @Test func windowOutsideViewValidityIsPublishedAsDataUnavailable() async throws {
        let c = try p.make([direct()])
        var late = c.parts; late.validFrom = p.date(901)
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(late.view))
        let environment = AppEnvironment(configuration: try .forTesting(), clock: FixedAppClock(now: p.date(900)),
            logging: AppLogging(subsystem: "prepared-route-test", sink: RecordingLogSink()), routeSearching: searcher)
        guard case let .ready(owner) = environment.makeRouteSearchCoordinator() else { Issue.record("Expected owner"); return }
        let intent = RouteSearchIntent(origin: try p.station("O"), destination: try p.station("D"), departure: .now)
        guard case .accepted = owner.submit(intent) else { Issue.record("Expected acceptance"); return }
        await owner.completionCheckpointForTesting()()
        guard case let .failed(attempt, .dataUnavailable) = owner.state else { Issue.record("Expected dataUnavailable"); return }
        let presentation = RouteSearchPresentation.map(.current(owner.state))
        #expect(presentation.status == .dataUnavailable)
        #expect(presentation.actions == [.retry(attempt.id), .edit, .search])
        owner.dispose()
    }

    @Test func provisionalMappingsArePinnedAtOnePoint() {
        #expect(p.label(PreparedRouteSearchProvisionalMapping.windowOutsideViewValidity) == "data") // DEC-088 D1
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
