import Foundation
import Testing
@testable import TSUGINO

/// DEC-089 K1 same-TripID exclusion through the invented prepared composition. Every world,
/// profile, entry and limit case is stipulated test data; no provider or real railway data.
struct PreparedRouteK1ExclusionTests {
    typealias Case = PreparedRouteFixture.Case
    let p = PreparedRouteFixture()
    var f: SolverFixture { p.f }

    static let transferRoute = "invented-a/invented-day/0-1@1000.0-1005.0 | invented-b/invented-day/0-1@1005.0-1010.0"

    func train(_ name: String, _ stops: [String], departure: Double, step: Double,
               rides: [(Int, Int)], day: String = "invented-day") -> SolverFixture.Spec {
        var s = SolverFixture.Spec(); s.name = name; s.stops = stops; s.base = departure; s.step = step; s.day = day
        s.required = rides.map { .init(boardingIndex: $0.0, alightingIndex: $0.1) }; return s
    }
    func link(_ from: Int, _ to: Int, alight: Int = 1, board: Int = 0, form: ConnectionForm = .sameStation,
              kind: Int = 0) -> SolverFixture.Link {
        var l = f.link(from, to, form: form, kind: kind); l.alight = alight; l.board = board; return l
    }
    func longTrip(_ name: String, day: String = "invented-day") -> SolverFixture.Spec {
        train(name, ["O"] + (1...70).map { "invented-l\($0)" } + ["D"], departure: 1000, step: 1, rides: [], day: day)
    }

    /// 0 slow direct O→D, 1 a O→H, 2 b H→D (a→b is the required transfer), 3 loop H,K,H,D,
    /// 4 the same recurring Trip `invented-a` on a prior service date; `extra` follows. `adjust`
    /// edits the two K1 occurrences (3 and 4) only, never their Trip or address.
    func world(links: [SolverFixture.Link] = [], extra: [SolverFixture.Spec] = [],
               loopStops: [String] = ["H", "K", "H", "D"],
               adjust: (inout SolverFixture.Spec) -> Void = { _ in }) throws -> Case {
        var loop = train("invented-loop", loopStops, departure: 1006, step: 5, rides: [(0, 1), (2, 3), (0, 3)])
        var prior = train("invented-a", ["O", "H"], departure: 1000, step: 5, rides: [(0, 1)], day: "invented-day-0")
        adjust(&loop); adjust(&prior)
        return try p.make([train("invented-direct", ["O", "D"], departure: 1000, step: 20, rides: [(0, 1)]),
                           train("invented-a", ["O", "H"], departure: 1000, step: 5, rides: [(0, 1)]),
                           train("invented-b", ["H", "D"], departure: 1005, step: 5, rides: [(0, 1)]),
                           loop, prior] + extra,
                          links: [link(1, 2)] + links)
    }
    func key(_ c: Case, _ from: Int, _ alight: Int, _ to: Int, _ board: Int) -> ConnectionRelationKey {
        .init(from: c.world.bindings[from].address, alightingIndex: alight, to: c.world.bindings[to].address, boardingIndex: board)
    }
    /// Same occurrence (K→H), repeated station visit (H@2→H@0), and cross-date (a@prior H → a O).
    func k1Keys(_ c: Case) -> [ConnectionRelationKey] { [key(c, 3, 1, 3, 2), key(c, 3, 2, 3, 0), key(c, 4, 1, 1, 0)] }

    func declaring(_ c: Case, _ keys: [ConnectionRelationKey]) -> Case {
        var c = c
        c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete,
                                  targets: c.parts.relations.targets + keys)
        return c
    }
    func scope(_ c: Case) throws -> InternalSearchScope {
        try f.need(InternalSearchScope(profile: c.profile, request: c.request, viewID: c.view.id))
    }
    func declarations(_ c: Case) throws -> PreparedRouteDeclarations {
        try PreparedRouteDeclarationProducer.declarations(view: c.view, scope: scope(c))
    }
    func requiredKeys(_ c: Case) throws -> [ConnectionRelationKey] {
        try declarations(c).connections.required.map(ConnectionRelationKey.init)
    }
    @discardableResult
    func closureOnly(_ c: Case) throws -> RequestScopedSearchInputClosure {
        let d = try declarations(c)
        return try RequestScopedSearchInputClosure(scope: scope(c), inventory: c.view.inventory, railway: c.view.railway,
            occurrences: d.occurrences, connections: d.connections, dependencies: d.dependencies)
    }
    func kept(_ c: Case) -> [TimetableOccurrenceAddress: Trip] {
        Dictionary(c.world.bindings.map { ($0.address, $0.trip) }, uniquingKeysWith: { first, _ in first })
    }
    func run(_ c: Case) async -> String {
        await p.outcome { try await p.searcher(c, InventedPreparedRouteViewSupplier(c.view)).search(c.request) }
    }
    func runStages(_ c: Case) async -> (String, [PreparedRouteSearchStage]) {
        let recorder = PreparedRouteStageRecorder()
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view),
                                  hooks: .init(checkpoint: { await recorder.record($0) }))
        return (await p.outcome { try await searcher.search(c.request) }, await recorder.stages)
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
    /// Composed = the unchanged solver over the producer-built P = independent oracle over that P.
    func routes(_ c: Case) async throws -> [String] {
        let supplier = InventedPreparedRouteViewSupplier(c.view)
        let composed = p.summary(try await p.searcher(c, supplier).search(c.request))
        let prepared = try p.prepareThroughProducers(c).1
        #expect(composed == p.summary(try await InternalRouteSolver().solve(prepared, configuration: c.configuration)))
        #expect(await supplier.captures == ["V1"])
        let routes = Array(composed.dropFirst(2))
        #expect(routes == (try oracleRoutes(prepared)))
        return routes
    }
    func qualifiedPositive(_ c: Case) throws -> PreparedRoutePositiveConnectionEntry {
        let entry = try #require(c.parts.connections.entries[c.firstKey])
        guard case let .positive(positive) = entry else { throw ConnectionEvidenceFailure.formConflict }
        return positive
    }
    func ref(_ s: String) throws -> TimetableQualificationReference { try f.ref(s) }

    // MARK: Exclusion (requirements 1–4, 13, 14)

    /// Same occurrence (0), repeated station visit (1) and cross-date same recurring Trip (2) are
    /// excluded under K1 and reported K1-only, so missing or unavailable evidence no longer fails
    /// the call: the only required relation is the a→b transfer.
    @Test(arguments: 0...2) func sameTripRelationsAreExcluded(_ variant: Int) async throws {
        let base = try world()
        let k = k1Keys(base)[variant]
        for entry: PreparedRouteConnectionEntry? in [nil, .unavailable(.insufficientEvidence), .unavailable(.unsupported)] {
            var c = declaring(base, [k])
            c.parts.setEntry(k, entry)
            let d = try declarations(c)
            #expect(d.k1OnlyExcluded == [k])
            #expect(d.connections.required.map(ConnectionRelationKey.init) == [base.firstKey])
            #expect(try await routes(c) == [Self.transferRoute])
        }
        #expect(k.from.tripID == k.to.tripID)
        #expect(variant == 2 ? k.from.serviceDate != k.to.serviceDate : k.from == k.to)
    }

    // MARK: Distinct TripIDs stay required (requirement 5)

    /// Distinct TripIDs are never K1-excluded: a near-identical ID with identical stops and times (0),
    /// a distinct Trip on another service date (1), and the a→b through-style transfer itself (2).
    @Test(arguments: 0...2) func distinctTripIDsStayRequired(_ variant: Int) async throws {
        var twin = train("invented-a-2", ["O", "H"], departure: 1000, step: 5, rides: [(0, 1)])
        twin.day = "invented-day"
        let other = train("invented-b", ["H", "D"], departure: 1005, step: 5, rides: [(0, 1)], day: "invented-day-0")
        let base = try world(extra: [twin, other])
        let k = [key(base, 1, 1, 5, 0), key(base, 1, 1, 6, 0), base.firstKey][variant]
        var c = variant == 2 ? base : declaring(base, [k])
        #expect(!PreparedRouteDeclarationProducer.sameRecurringTrip(k, kept: kept(c), scope: try scope(c)))
        #expect(try declarations(c).k1OnlyExcluded.isEmpty)
        #expect(try requiredKeys(c).contains(k))
        c.parts.setEntry(k, nil)
        #expect(await run(c) == "data") // unknown required evidence (DEC-086)
    }

    // MARK: D4 precedence (requirement 6)

    /// A same-Trip relation alighting at X outside the profile meets both D4 and K1. D4 takes it, so
    /// it is not K1-only and its supplied positive is never read, exactly as before DEC-089.
    @Test func d4TakesPrecedenceOverK1() async throws {
        var c = declaring(try world(loopStops: ["H", "X", "H", "D"]), [])
        let k = key(c, 3, 1, 3, 2)
        c = declaring(c, [k])
        c.parts.setEntry(k, .positive(try qualifiedPositive(c)))
        let base = c.profile
        c.profile = try f.need(InternalSearchProfileDefinition(identity: base.identity,
            stations: base.stations.subtracting([try p.station("X")]), lines: base.lines, trips: base.trips,
            maximumElapsedDuration: base.maximumElapsedDuration, maximumRailRides: base.maximumRailRides,
            connectionPolicy: base.connectionPolicy, serviceDateInterpretation: base.serviceDateInterpretation))
        let s = try scope(c)
        #expect(PreparedRouteDeclarationProducer.untraversableAtProfileBoundary(k, kept: kept(c), scope: s))
        #expect(PreparedRouteDeclarationProducer.sameRecurringTrip(k, kept: kept(c), scope: s))
        let d = try declarations(c)
        #expect(d.k1OnlyExcluded.isEmpty)
        #expect(d.connections.required.map(ConnectionRelationKey.init) == [c.firstKey])
        #expect(try await routes(c) == [Self.transferRoute])
    }

    // MARK: Structural rejection is preserved (requirements 7–10)

    /// K1 never hides a relation the closure rejects, even with a same-Trip key and a supplied positive:
    /// duplicated K1 key (0); valid K1 key beside a duplicated occurrence address (1); same-Trip
    /// index-0 alighting (2); same-Trip last-index boarding (3); same TripID in another view (4);
    /// same TripID at an undeclared occurrence (5); same-Trip out-of-range alighting (6).
    @Test(arguments: 0...6) func structurallyRejectedSameTripRelationsStayRejected(_ variant: Int) async throws {
        let base = try world()
        let valid = k1Keys(base)[0]
        let loop = base.world.bindings[3].address
        let foreign = TimetableOccurrenceAddress(viewID: TimetableViewID(f.uuid(7)), tripID: loop.tripID, serviceDate: loop.serviceDate)
        let undeclared = TimetableOccurrenceAddress(viewID: base.view.id, tripID: loop.tripID,
                                                    serviceDate: try f.need(TimetableServiceDate("invented-day-9")))
        let extra: [ConnectionRelationKey] = switch variant {
        case 0: [valid, valid]
        case 1: [valid]
        case 2: [key(base, 3, 0, 3, 2)]
        case 3: [key(base, 3, 1, 3, 3)]
        case 4: [.init(from: loop, alightingIndex: 1, to: foreign, boardingIndex: 2)]
        case 5: [.init(from: loop, alightingIndex: 1, to: undeclared, boardingIndex: 2)]
        default: [key(base, 3, 4, 3, 2)]
        }
        var c = declaring(base, extra)
        c.parts.setEntry(extra[0], .positive(try qualifiedPositive(c)))
        if variant == 1 {
            c.parts.occurrences = .init(reference: c.parts.occurrences.reference, completeness: .declaredComplete,
                                        entries: c.parts.occurrences.entries + [c.parts.occurrences.entries[3]])
        }
        #expect(PreparedRouteDeclarationProducer.sameRecurringTrip(extra[0], kept: kept(c), scope: try scope(c)) == (variant <= 1))
        #expect(try declarations(c).k1OnlyExcluded.isEmpty)
        let failure: SearchInputClosureConstructionFailure = variant == 1 ? .declarationConflict : .connectionTargetConflict
        #expect(throws: failure) { try self.closureOnly(c) }
        #expect(await runStages(c) == ("data", [.entry, .configuration, .capture, .viewValidity, .endpoints, .scope, .declarations]))
    }

    /// Applicability is stamped, not validated, by the producer: every emitted target carries the
    /// relation domain's own reference, which the closure then checks; K1 keys are never emitted.
    @Test func emittedTargetsKeepStampedApplicability() throws {
        let c = declaring(try world(), k1Keys(try world()))
        let d = try declarations(c)
        #expect(d.connections.applicability.reference == c.parts.relations.reference)
        #expect(d.connections.required.allSatisfy { $0.applicabilityReference == c.parts.relations.reference })
        #expect(Set(d.k1OnlyExcluded).isDisjoint(with: d.connections.required.map(ConnectionRelationKey.init)))
        #expect(try closureOnly(c).connections.required.count == 1)
    }

    // MARK: K1-only entries (requirements 11–15)

    /// Every supplied positive for a K1-only relation is a contradiction whatever its contents:
    /// qualified (0), insufficient genuine change (1), contradictory relation premise (2), missing
    /// examined instant (3), invalid allowance (4). The validator throws trainChangeConflict inside
    /// the evidence stage, before its checkpoint; the published outcome is dataUnavailable.
    @Test(arguments: 0...4) func k1OnlyPositivesAreRejectedWhateverTheirContents(_ variant: Int) async throws {
        let base = try world()
        let k = k1Keys(base)[variant % 3]
        var c = declaring(base, [k])
        let e = try qualifiedPositive(c)
        let positive = PreparedRoutePositiveConnectionEntry(form: e.form,
            alighting: variant == 4 ? 1 : e.alighting, interchange: variant == 4 ? 1 : e.interchange,
            boarding: e.boarding, total: variant == 4 ? 3 : e.total,
            fromArrival: variant == 3 ? nil : e.fromArrival, toDeparture: e.toDeparture,
            relation: variant == 2 ? .contradictory : e.relation,
            genuineChange: variant == 1 ? .insufficientEvidence : e.genuineChange,
            componentPartition: e.componentPartition, endpointWideContext: e.endpointWideContext)
        #expect(await run(c) == "success")
        c.parts.setEntry(k, .positive(positive))
        #expect(throws: ConnectionEvidenceFailure.trainChangeConflict) {
            try PreparedRouteK1Validator.validate([k], authority: c.view.connections)
        }
        let (outcome, stages) = await runStages(c)
        #expect(outcome == "data")
        #expect(stages.last == .closure)
    }

    /// K1-only absences keep only their existing premise validation: a contradictory relation (0),
    /// endpoint-wide (1) or event-independence (2) premise keeps its typed failure → dataUnavailable;
    /// qualified (3), insufficient (4) and unsupported (5) premises are accepted and never counted.
    @Test(arguments: 0...5) func k1OnlyAbsencesKeepOnlyExistingPremiseValidation(_ variant: Int) async throws {
        let base = try world()
        let k = k1Keys(base)[0]
        var c = declaring(base, [k])
        let q: ConnectionEvidencePremise = .qualified(try ref("invented-k1-absent"))
        let premise: ConnectionEvidencePremise = switch variant {
        case 0, 1, 2: .contradictory
        case 3: q
        case 4: .insufficientEvidence
        default: .unsupported
        }
        c.parts.setEntry(k, .absence(relation: variant == 0 || variant >= 3 ? premise : q,
                                     endpointWideContext: variant == 1 || variant >= 3 ? premise : q,
                                     eventIndependent: variant == 2 || variant >= 3 ? premise : q))
        if variant <= 2 {
            let failure: ConnectionEvidenceFailure = variant == 0 ? .qualificationConflict : .applicabilityConflict
            #expect(throws: failure) { try PreparedRouteK1Validator.validate([k], authority: c.view.connections) }
            #expect(await runStages(c).0 == "data")
            #expect(await runStages(c).1.last == .closure)
        } else {
            #expect(try await routes(c) == [Self.transferRoute])
            let evidence = try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closureOnly(c))
            #expect(!evidence.declaredKeys.contains(k)) // never accounted as absentUnderCompleteAuthority
        }
    }

    /// Unknown versus qualified absence authority on excluded and still-required relations. A K1-only
    /// qualified absence is never accounted, so the authority's completeness cannot matter for it (0, 1).
    /// A still-required qualified absence (a→loop) is unchanged: resolved under declaredComplete
    /// authority (2) and held, hence dataUnavailable (DEC-086), under unknown authority (3).
    @Test(arguments: 0...3) func absenceAuthorityOnExcludedAndRequiredRelations(_ variant: Int) async throws {
        let base = try world(links: variant >= 2 ? [link(1, 3, kind: 1)] : [])
        let k = k1Keys(base)[0]
        var c = declaring(base, [k])
        let q: ConnectionEvidencePremise = .qualified(try ref("invented-k1-absent"))
        c.parts.setEntry(k, .absence(relation: q, endpointWideContext: q, eventIndependent: q))
        let completeness: TimetableInventoryCompleteness = variant % 2 == 0 ? .declaredComplete : .unknown
        c.parts.connections = .init(review: c.parts.connections.review, completeness: completeness,
                                    entries: c.parts.connections.entries)
        #expect(try declarations(c).k1OnlyExcluded == [k])
        if variant == 3 {
            #expect(await runStages(c).1.last == .evidence) // held at assessment, after the K1 check passed
            #expect(await run(c) == "data")
        } else {
            #expect(try await routes(c) == [Self.transferRoute])
        }
    }

    /// Positives the validator must never read keep their existing (ignored) handling: a same-Trip
    /// key absent from the relation domain (0), and a same-Trip relation whose occurrence the
    /// profile projects out (1).
    @Test(arguments: 0...1) func unreadPositivesKeepExistingHandling(_ variant: Int) async throws {
        let base = try world()
        var c = variant == 0 ? base : declaring(base, [k1Keys(base)[0]])
        c.parts.setEntry(k1Keys(base)[0], .positive(try qualifiedPositive(base)))
        if variant == 1 {
            let b = c.profile
            c.profile = try f.need(InternalSearchProfileDefinition(identity: b.identity, stations: b.stations, lines: b.lines,
                trips: b.trips.subtracting([try f.need(TripID("invented-loop"))]),
                maximumElapsedDuration: b.maximumElapsedDuration, maximumRailRides: b.maximumRailRides,
                connectionPolicy: b.connectionPolicy, serviceDateInterpretation: b.serviceDateInterpretation))
        }
        #expect(try declarations(c).k1OnlyExcluded.isEmpty)
        #expect(try await routes(c) == [Self.transferRoute])
    }

    // MARK: Mixed failures and limits (requirements 16–17)

    /// With a K1-only positive present, every existing closure and evidence failure still wins:
    /// closure conflict (0), closure resourceLimit (1), evidence resourceLimit (2), contradictory
    /// required positive (3). A missing required entry (4) is an assessment hold, which comes after
    /// the evidence stage, so there the K1 rejection is observed first (before `.evidence`).
    @Test(arguments: 0...4) func existingFailuresPrecedeK1Rejection(_ variant: Int) async throws {
        let base = try world(extra: [longTrip("invented-long-a"), longTrip("invented-long-b")])
        let k = k1Keys(base)[0]
        var c = declaring(base, [k])
        c.parts.setEntry(k, .positive(try qualifiedPositive(c)))
        switch variant {
        case 0: c = declaring(c, [key(c, 3, 0, 3, 2)])
        case 1:
            c.parts.dependencies = .init(reference: c.parts.dependencies.reference,
                unresolved: try (0...SearchInputClosureLimits.dependencies).map { try f.ref("invented-dependency-\($0)") })
        case 2:
            let retained = (1...71).flatMap { a in (0...70).map { b in key(c, 5, a, 6, b) } }
            #expect(retained.count > ConnectionEvidenceLimits.relations && retained.count < SearchInputClosureLimits.connections)
            c = declaring(c, retained)
        case 3:
            c.parts.editPositive(c.firstKey) { e in .init(form: e.form, alighting: e.alighting, interchange: e.interchange,
                boarding: e.boarding, total: e.total, fromArrival: e.fromArrival, toDeparture: e.toDeparture,
                relation: .contradictory, genuineChange: e.genuineChange, componentPartition: e.componentPartition,
                endpointWideContext: e.endpointWideContext) }
            #expect(throws: ConnectionEvidenceFailure.qualificationConflict) {
                try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: self.closureOnly(c))
            }
        default: c.parts.setEntry(c.firstKey, nil)
        }
        let throughScope: [PreparedRouteSearchStage] = [.entry, .configuration, .capture, .viewValidity, .endpoints, .scope]
        let expected: (String, [PreparedRouteSearchStage]) = switch variant {
        case 0: ("data", throughScope + [.declarations])
        case 1: ("incomplete", throughScope + [.declarations])
        case 2: ("incomplete", throughScope + [.declarations, .closure])
        default: ("data", throughScope + [.declarations, .closure])
        }
        #expect(await runStages(c) == expected)
        if variant == 4 { // control: without the K1 positive, the hold is reached after `.evidence`
            c.parts.setEntry(k, nil)
            #expect(await runStages(c) == ("data", throughScope + [.declarations, .closure, .evidence]))
        }
    }

    /// K1-only relations are no longer required targets, so they do not count toward the evidence
    /// relation limit (0) or the closure connection limit (1); before DEC-089 both calls were
    /// searchIncomplete. Numeric limits are unchanged. Removing the limit condition lets the call
    /// reach later checks: one K1-only positive among them is now dataUnavailable (2).
    @Test(arguments: 0...2) func k1ExclusionPrecedesCountLimits(_ variant: Int) async throws {
        // Four dates of one long recurring Trip, staying within the inventory's six service dates.
        let days = ["invented-day", "invented-day-0", "invented-day-l0", "invented-day-l1"]
        let long = variant == 1 ? days.map { longTrip("invented-long", day: $0) } : [longTrip("invented-long")]
        let base = try world(extra: long)
        func pairs(_ from: Int, _ to: Int) -> [ConnectionRelationKey] {
            (1...71).flatMap { a in (0...70).map { b in key(base, from, a, to, b) } }
        }
        let keys = variant == 1 ? ((0..<4).flatMap { pairs(5 + $0, 5 + ($0 + 1) % 4) } + pairs(5, 5)) : pairs(5, 5)
        #expect(keys.count > (variant == 1 ? SearchInputClosureLimits.connections : ConnectionEvidenceLimits.relations))
        var c = declaring(base, keys)
        if variant == 2 { c.parts.setEntry(keys[17], .positive(try qualifiedPositive(c))) }
        let d = try declarations(c)
        #expect(d.k1OnlyExcluded == keys)
        #expect(d.connections.required.map(ConnectionRelationKey.init) == [c.firstKey])
        if variant == 2 { #expect(await run(c) == "data") } else { #expect(try await routes(c) == [Self.transferRoute]) }
    }

    // MARK: Cancellation and determinism (requirements 18–19)

    @Test(arguments: PreparedRouteSearchStage.allCases) func cancellationAtEveryStageWithK1Exclusions(_ stage: PreparedRouteSearchStage) async throws {
        let base = try world()
        let c = declaring(base, k1Keys(base))
        let recorder = PreparedRouteStageRecorder()
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: .init(checkpoint: { s in
            await recorder.record(s)
            if s == stage { withUnsafeCurrentTask { $0?.cancel() } }
        }))
        #expect(await p.outcome(Task { try await searcher.search(c.request) }) == "cancelled")
        let all = PreparedRouteSearchStage.allCases
        #expect(await recorder.stages == Array(all[...all.firstIndex(of: stage)!]))
    }

    /// Cancellation observed at a checkpoint before the evidence stage wins over a pending K1 rejection.
    @Test(arguments: [PreparedRouteSearchStage.declarations, .closure]) func cancellationBeforeK1Rejection(_ stage: PreparedRouteSearchStage) async throws {
        let base = try world()
        var c = declaring(base, k1Keys(base))
        c.parts.setEntry(k1Keys(base)[1], .positive(try qualifiedPositive(c)))
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: .init(checkpoint: { s in
            if s == stage { withUnsafeCurrentTask { $0?.cancel() } }
        }))
        #expect(await p.outcome(Task { try await searcher.search(c.request) }) == "cancelled")
    }

    /// Supplied order only decides order: the required set, K1-only set and result are invariant
    /// under permutation; `k1OnlyExcluded` follows supplied order; and among several K1-only entries
    /// the first failing one in supplied order decides the typed failure (both publish as data).
    @Test func determinismAcrossPermutations() async throws {
        let base = try world()
        let k = k1Keys(base)
        let all = base.parts.relations.targets + k
        var outcomes: Set<[String]> = []
        for order in [all, Array(all.reversed()), Array(all[2...] + all[..<2])] {
            var c = base
            c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete, targets: order)
            let d = try declarations(c)
            #expect(d.k1OnlyExcluded == order.filter(k.contains))
            #expect(d.connections.required.map(ConnectionRelationKey.init) == [base.firstKey])
            outcomes.insert(try await routes(c))
        }
        #expect(outcomes == [[Self.transferRoute]])
        var c = declaring(base, k)
        c.parts.setEntry(k[0], .positive(try qualifiedPositive(c)))
        c.parts.setEntry(k[1], .absence(relation: .contradictory, endpointWideContext: .insufficientEvidence,
                                        eventIndependent: .insufficientEvidence))
        #expect(throws: ConnectionEvidenceFailure.trainChangeConflict) {
            try PreparedRouteK1Validator.validate([k[0], k[1]], authority: c.view.connections)
        }
        #expect(throws: ConnectionEvidenceFailure.qualificationConflict) {
            try PreparedRouteK1Validator.validate([k[1], k[0]], authority: c.view.connections)
        }
        #expect(await run(c) == "data")
    }

    // MARK: Predicate equivalence and parity (requirements 20–22)

    /// Over a grid of same- and distinct-Trip keys, including wrong-view, undeclared and every
    /// out-of-range index, the shared guard accepts exactly what the closure accepts as a target,
    /// K1 holds exactly for accepted same-TripID keys, and D4 never applies (all stations in profile).
    @Test func k1PredicateMatchesClosureTargetAcceptance() throws {
        let c = try world()
        let s = try scope(c), keptTrips = kept(c), d = try declarations(c)
        let loop = c.world.bindings[3].address
        var addresses = c.world.bindings.map(\.address)
        addresses.append(.init(viewID: TimetableViewID(f.uuid(7)), tripID: loop.tripID, serviceDate: loop.serviceDate))
        addresses.append(.init(viewID: c.view.id, tripID: loop.tripID, serviceDate: try f.need(TimetableServiceDate("invented-day-9"))))
        var accepted = 0, sameTrip = 0
        for from in addresses { for to in addresses { for alight in -1...4 { for board in -1...4 {
            let k = ConnectionRelationKey(from: from, alightingIndex: alight, to: to, boardingIndex: board)
            let target = SearchInputConnectionTarget(from: from, alightingIndex: alight, to: to, boardingIndex: board,
                                                     applicabilityReference: c.parts.relations.reference)
            let closureAccepts = (try? RequestScopedSearchInputClosure(scope: s, inventory: c.view.inventory, railway: c.view.railway,
                occurrences: d.occurrences, connections: .init(applicability: d.connections.applicability,
                    completeness: .declaredComplete, required: [target]), dependencies: d.dependencies)) != nil
            let k1 = PreparedRouteDeclarationProducer.sameRecurringTrip(k, kept: keptTrips, scope: s)
            #expect(k1 == (closureAccepts && from.tripID == to.tripID))
            #expect(!PreparedRouteDeclarationProducer.untraversableAtProfileBoundary(k, kept: keptTrips, scope: s))
            if closureAccepts { accepted += 1 }
            if k1 { sameTrip += 1 }
        } } } }
        #expect(accepted > 0 && sameTrip > 0 && sameTrip < accepted)
    }

    /// Independent parity: the reference world declares the same-Trip relations as required with
    /// qualified absences, which the existing closure, evidence view and assessment accept. K1 instead
    /// excludes them. The composed result equals the direct solver and the independent oracle over the
    /// reference P, and the oracle over the producer-built P, so the exclusion removes no itinerary.
    /// a→loop@0 makes loop rides reachable, so the same-occurrence relation is not vacuous.
    @Test func exclusionMatchesQualifiedAbsenceReference() async throws {
        let c = try world(links: [link(1, 3), link(3, 3, alight: 1, board: 2, form: .walking, kind: 1),
                                  link(3, 3, alight: 2, board: 0, kind: 1), link(4, 1, alight: 1, board: 0, form: .walking, kind: 1)])
        let k = k1Keys(c)
        let reference = c.world.assessment.closure.connections.required.map(ConnectionRelationKey.init)
        #expect(Set(k).isSubset(of: reference))
        let d = try declarations(c)
        #expect(d.k1OnlyExcluded == k)
        #expect(Set(d.connections.required.map(ConnectionRelationKey.init)) == Set(reference).subtracting(k))
        let referenceP = try PreparedInternalSearchInput(assessment: c.world.assessment, objective: .init(reference: p.objective))
        let composed = try await routes(c)
        #expect(composed == (try oracleRoutes(referenceP)))
        #expect(composed == Array(p.summary(try await p.direct(c)).dropFirst(2)))
        #expect(composed == [Self.transferRoute])
    }

    /// Existing invented workloads are accounted for, counted independently of the producer. Only
    /// the W6 family declares same-TripID relations (its filler Trips on consecutive dates), and every
    /// one is between Trips the profile projects out, so the projection drops them before D4 or K1.
    /// No workload has a same-TripID relation between retained Trips, and none has a K1-only exclusion.
    @Test func existingWorkloadsHaveNoK1Exclusions() throws {
        var projectedSameTrip: [String] = []
        for workload in PreparedRouteWorkloads.matrix {
            let c = try workload.build(p)
            let sameTrip = c.parts.relations.targets.filter { $0.from.tripID == $0.to.tripID }
            let retained = sameTrip.filter { c.profile.trips.contains($0.from.tripID) }
            #expect(retained.isEmpty, "\(workload.id)")
            if !sameTrip.isEmpty { projectedSameTrip.append(workload.id) }
            #expect(try declarations(c).k1OnlyExcluded.isEmpty, "\(workload.id)")
        }
        #expect(projectedSameTrip == ["W6-0096", "W6-0384", "W6-1536", "W6-2844", "W6p-0384"])
    }

    // MARK: Itinerary-level TripID rule and optimal-route parity

    // In these worlds every relation a candidate could use joins distinct TripIDs and carries a
    // qualified positive, so the connection evidence permits each piece. Only the itinerary rule (no
    // TripID twice in one candidate) can remove a path. Same-TripID relations appear only as extra K1
    // keys with no entry, never as qualified absences in a reference P. Winners are hand-written.

    static let day0 = "invented-day-0"

    func leg(_ trip: String, _ boarding: Int, _ alighting: Int, _ departure: Double, _ arrival: Double,
             day: String = "invented-day") -> String {
        "invented-\(trip)/\(day)/\(boarding)-\(alighting)@\(departure)-\(arrival)"
    }
    func route(_ legs: String...) -> String { legs.joined(separator: " | ") }
    func occurrence(_ c: Case, _ trip: String, _ day: String = "invented-day") throws -> TimetableOccurrenceAddress {
        try #require(c.world.bindings.first { $0.address.tripID.rawValue == trip && $0.address.serviceDate.label == day }).address
    }
    /// Specs in supplied (0), reversed (1) or rotated (2) order, links remapped and, for 1–2, supplied
    /// in reverse, so occurrence, ride and relation order all change.
    func permuted(_ specs: [SolverFixture.Spec], links: [SolverFixture.Link], _ variant: Int) throws -> Case {
        let n = specs.count
        let order: [Int] = switch variant {
        case 0: Array(0..<n)
        case 1: Array((0..<n).reversed())
        default: Array(1..<n) + [0]
        }
        var position = Array(repeating: 0, count: n)
        for (i, s) in order.enumerated() { position[s] = i }
        let remapped = links.map { l in var l = l; l.from = position[l.from]; l.to = position[l.to]; return l }
        return try p.make(order.map { specs[$0] }, links: variant == 0 ? remapped : Array(remapped.reversed()))
    }
    /// Adds same-Trip keys with no entry: appended in supplied order (0), placed first otherwise, so the
    /// already reversed links keep their reversed order in the relation domain.
    func declaringK1(_ c: Case, _ keys: [ConnectionRelationKey], _ variant: Int) throws -> Case {
        var c = c
        let targets = c.parts.relations.targets
        c.parts.relations = .init(reference: c.parts.relations.reference, completeness: .declaredComplete,
                                  targets: variant == 0 ? targets + keys : keys + targets)
        #expect(try declarations(c).k1OnlyExcluded == keys)
        return c
    }
    /// The itinerary is built only from retained rides joined by feasible relations, from origin to
    /// destination, arriving at `arrival`: the evidence permits every piece of it.
    func expectFeasiblePieces(_ prepared: PreparedInternalSearchInput,
                              _ legs: [(TimetableOccurrenceAddress, Int, Int)], arriving arrival: Double) {
        let rides = legs.compactMap { leg in
            prepared.rides.first { $0.key.address == leg.0 && $0.key.boardingIndex == leg.1 && $0.key.alightingIndex == leg.2 }
        }
        #expect(rides.count == legs.count)
        #expect(rides.first?.train.anchors.boardingStationID == prepared.scope.request.origin)
        #expect(rides.last?.train.anchors.alightingStationID == prepared.scope.request.destination)
        #expect(rides.last?.context.arrival.timeIntervalSinceReferenceDate == arrival)
        for (x, y) in zip(legs, legs.dropFirst()) {
            #expect(prepared.connections.contains { $0.state == .feasible && $0.key.from == x.0
                && $0.key.alightingIndex == x.2 && $0.key.to == y.0 && $0.key.boardingIndex == y.1 })
        }
    }
    /// Composed, solver and oracle over the producer-built P (`routes`), then solver and oracle over
    /// the world's own P, which never declared the K1 keys; the caller checks hand-written winners.
    func allRoutes(_ c: Case) async throws -> [String] {
        let composed = try await routes(c)
        let worldP = try PreparedInternalSearchInput(assessment: c.world.assessment, objective: .init(reference: p.objective))
        #expect(composed == (try oracleRoutes(worldP)))
        #expect(composed == Array(p.summary(try await p.direct(c)).dropFirst(2)))
        return composed
    }

    /// Cross-date: `invented-r` on day-0 (O→X) and on day (Y→D), joined through the distinct Trip x by
    /// qualified positives. r|x|r would arrive at 1040, before the valid r|x|z (1045) and slow (1050), but
    /// repeats a TripID (0). Control (1): the same world with the second occurrence renamed `invented-r2`
    /// wins with exactly that path, so nothing but TripID identity removed it.
    @Test(arguments: 0...1) func crossDateRepeatedTripIDItineraryIsRejected(_ variant: Int) async throws {
        let second = variant == 0 ? "invented-r" : "invented-r2"
        let stops = ["O", "X", "Y", "D"]
        let base = try p.make([train("invented-slow", ["O", "D"], departure: 1000, step: 50, rides: [(0, 1)]),
                               train("invented-r", stops, departure: 1000, step: 10, rides: [(0, 1)], day: Self.day0),
                               train("invented-x", ["X", "Y"], departure: 1012, step: 8, rides: [(0, 1)]),
                               train(second, stops, departure: 1010, step: 10, rides: [(2, 3)]),
                               train("invented-z", ["Y", "D"], departure: 1030, step: 15, rides: [(0, 1)])],
                              links: [link(1, 2), link(2, 3, board: 2), link(2, 4)])
        let r0 = try occurrence(base, "invented-r", Self.day0), r1 = try occurrence(base, second)
        let c = variant == 0 ? try declaringK1(base, [.init(from: r0, alightingIndex: 1, to: r1, boardingIndex: 1),
                                                      .init(from: r0, alightingIndex: 1, to: r0, boardingIndex: 2)], 0) : base
        #expect((r0.tripID == r1.tripID) == (variant == 0))
        expectFeasiblePieces(try p.prepareThroughProducers(c).1,
                             [(r0, 0, 1), (try occurrence(c, "invented-x"), 0, 1), (r1, 2, 3)], arriving: 1040)
        let last = variant == 0 ? leg("z", 0, 1, 1030, 1045) : leg("r2", 2, 3, 1030, 1040)
        #expect(try await allRoutes(c) == [route(leg("r", 0, 1, 1000, 1010, day: Self.day0), leg("x", 0, 1, 1012, 1020), last)])
    }

    /// Repeated station visit: loop H,K,H,D boards at H, rides to K, y returns to H, and boarding the
    /// same loop occurrence again at H would reach D at 1036, before the valid a|loop|y|w (1045) and
    /// slow (1060) (0). Control (1): the loop's second ride on a distinct `invented-loop-2` with the same
    /// stops and times wins with exactly that path.
    @Test(arguments: 0...1) func repeatedStationVisitThroughTheSameTripIsRejected(_ variant: Int) async throws {
        let stops = ["H", "K", "H", "D"]
        var specs = [train("invented-slow", ["O", "D"], departure: 1000, step: 60, rides: [(0, 1)]),
                     train("invented-a", ["O", "H"], departure: 1000, step: 5, rides: [(0, 1)]),
                     train("invented-loop", stops, departure: 1006, step: 10, rides: variant == 0 ? [(0, 1), (2, 3)] : [(0, 1)]),
                     train("invented-y", ["K", "H"], departure: 1017, step: 4, rides: [(0, 1)]),
                     train("invented-w", ["H", "D"], departure: 1030, step: 15, rides: [(0, 1)])]
        if variant == 1 { specs.append(train("invented-loop-2", stops, departure: 1006, step: 10, rides: [(2, 3)])) }
        let base = try p.make(specs, links: [link(1, 2), link(2, 3), link(3, variant == 0 ? 2 : 5, board: 2), link(3, 4)])
        let loop = try occurrence(base, "invented-loop"), back = try occurrence(base, variant == 0 ? "invented-loop" : "invented-loop-2")
        let c = variant == 0 ? try declaringK1(base, [.init(from: loop, alightingIndex: 1, to: loop, boardingIndex: 2),
                                                      .init(from: loop, alightingIndex: 2, to: loop, boardingIndex: 0)], 0) : base
        expectFeasiblePieces(try p.prepareThroughProducers(c).1, [(try occurrence(c, "invented-a"), 0, 1), (loop, 0, 1),
                             (try occurrence(c, "invented-y"), 0, 1), (back, 2, 3)], arriving: 1036)
        let last = variant == 0 ? leg("w", 0, 1, 1030, 1045) : leg("loop-2", 2, 3, 1026, 1036)
        #expect(try await allRoutes(c) == [route(leg("a", 0, 1, 1000, 1005), leg("loop", 0, 1, 1006, 1016),
                                                 leg("y", 0, 1, 1017, 1021), last)])
    }

    /// Tied earliest arrival at 1040 with one (d), two (a|b) and three (c|e|b) rides: the fewest rides
    /// wins alone, under three input orders (0–2), with K1 keys on both winning occurrences. Control (3):
    /// with d one second slower, a|b alone wins over the equally early c|e|b.
    @Test(arguments: 0...3) func tiedEarliestArrivalPrefersFewestRides(_ variant: Int) async throws {
        let specs = [train("invented-d", ["O", "D"], departure: 1000, step: variant == 3 ? 41 : 40, rides: [(0, 1)]),
                     train("invented-a", ["O", "H"], departure: 1000, step: 10, rides: [(0, 1)]),
                     train("invented-b", ["H", "D"], departure: 1015, step: 25, rides: [(0, 1)]),
                     train("invented-c", ["O", "K"], departure: 1000, step: 5, rides: [(0, 1)]),
                     train("invented-e", ["K", "H"], departure: 1006, step: 4, rides: [(0, 1)])]
        let base = try permuted(specs, links: [link(1, 2), link(3, 4), link(4, 2)], variant % 3)
        let d = try occurrence(base, "invented-d"), b = try occurrence(base, "invented-b")
        let c = try declaringK1(base, [.init(from: d, alightingIndex: 1, to: d, boardingIndex: 0),
                                       .init(from: b, alightingIndex: 1, to: b, boardingIndex: 0)], variant % 3)
        let prepared = try p.prepareThroughProducers(c).1
        let a = try occurrence(c, "invented-a")
        expectFeasiblePieces(prepared, [(a, 0, 1), (b, 0, 1)], arriving: 1040)
        expectFeasiblePieces(prepared, [(try occurrence(c, "invented-c"), 0, 1), (try occurrence(c, "invented-e"), 0, 1), (b, 0, 1)],
                             arriving: 1040)
        let expected = variant == 3 ? route(leg("a", 0, 1, 1000, 1010), leg("b", 0, 1, 1015, 1040)) : leg("d", 0, 1, 1000, 1040)
        #expect(try await allRoutes(c) == [expected])
    }

    /// Three distinct two-ride routes tie in arrival (1040) and rides; all survive in canonical order
    /// (TripID bytes, a shorter prefix first) whatever the input order (0–2), and the slow direct ride
    /// does not. Specs are supplied out of canonical order, and chronological order disagrees with it at
    /// both legs: c reaches its transfer before a, and b-2 departs before b.
    @Test(arguments: 0...2) func equalOptimaAllSurviveInCanonicalOrder(_ variant: Int) async throws {
        let specs = [train("invented-c", ["O", "K"], departure: 1000, step: 8, rides: [(0, 1)]),
                     train("invented-e", ["K", "D"], departure: 1020, step: 20, rides: [(0, 1)]),
                     train("invented-slow", ["O", "D"], departure: 1000, step: 50, rides: [(0, 1)]),
                     train("invented-a", ["O", "H"], departure: 1000, step: 10, rides: [(0, 1)]),
                     train("invented-b-2", ["H", "D"], departure: 1012, step: 28, rides: [(0, 1)]),
                     train("invented-b", ["H", "D"], departure: 1015, step: 25, rides: [(0, 1)])]
        let base = try permuted(specs, links: [link(0, 1), link(3, 4), link(3, 5)], variant)
        let a = try occurrence(base, "invented-a"), e = try occurrence(base, "invented-e")
        let c = try declaringK1(base, [.init(from: a, alightingIndex: 1, to: a, boardingIndex: 0),
                                       .init(from: e, alightingIndex: 1, to: e, boardingIndex: 0)], variant)
        #expect(try await allRoutes(c) == [route(leg("a", 0, 1, 1000, 1010), leg("b", 0, 1, 1015, 1040)),
                                           route(leg("a", 0, 1, 1000, 1010), leg("b-2", 0, 1, 1012, 1040)),
                                           route(leg("c", 0, 1, 1000, 1008), leg("e", 0, 1, 1020, 1040))])
    }

    /// The TripID rule is per candidate: `invented-r` on two service dates starts two separate optimal
    /// routes, both sharing b, and both survive (day before day-0 by date bytes) whatever the input order
    /// (0–2), with cross-date K1 keys between the two occurrences in both directions.
    @Test(arguments: 0...2) func sameTripIDOnSeparateCandidatesIsAllowed(_ variant: Int) async throws {
        let specs = [train("invented-b", ["H", "D"], departure: 1015, step: 25, rides: [(0, 1)]),
                     train("invented-r", ["O", "H"], departure: 1000, step: 10, rides: [(0, 1)], day: Self.day0),
                     train("invented-r", ["O", "H"], departure: 1002, step: 10, rides: [(0, 1)])]
        let base = try permuted(specs, links: [link(1, 0), link(2, 0)], variant)
        let r0 = try occurrence(base, "invented-r", Self.day0), r1 = try occurrence(base, "invented-r")
        let c = try declaringK1(base, [.init(from: r0, alightingIndex: 1, to: r1, boardingIndex: 0),
                                       .init(from: r1, alightingIndex: 1, to: r0, boardingIndex: 0)], variant)
        let b = leg("b", 0, 1, 1015, 1040)
        #expect(try await allRoutes(c) == [route(leg("r", 0, 1, 1002, 1012), b), route(leg("r", 0, 1, 1000, 1010, day: Self.day0), b)])
    }

    /// No admissible itinerary: the only way to D is `invented-r` day-0 O→H, then the same recurring Trip
    /// on day H→D. The only declared relation is that K1 key, so the scoped result is noResults in the
    /// composition, solver and oracle (0). Control (1): the second occurrence renamed `invented-r2`, with
    /// that relation as a qualified positive, yields exactly the two-ride route.
    @Test(arguments: 0...1) func noAdmissibleItineraryWhenOnlyK1RelationsJoinTheRides(_ variant: Int) async throws {
        let stops = ["O", "H", "D"]
        let second = variant == 0 ? "invented-r" : "invented-r2"
        let base = try p.make([train("invented-r", stops, departure: 1000, step: 10, rides: [(0, 1)], day: Self.day0),
                               train(second, stops, departure: 1005, step: 10, rides: [(1, 2)])],
                              links: variant == 0 ? [] : [link(0, 1, board: 1)])
        let r0 = try occurrence(base, "invented-r", Self.day0), r1 = try occurrence(base, second)
        let c = variant == 0 ? try declaringK1(base, [.init(from: r0, alightingIndex: 1, to: r1, boardingIndex: 1)], 0) : base
        let composed = p.summary(try await p.searcher(c, InventedPreparedRouteViewSupplier(c.view)).search(c.request))
        if variant == 0 {
            #expect(try declarations(c).connections.required.isEmpty)
            #expect(composed.count == 2 && composed.last == "noResults")
            #expect(p.summary(try await p.direct(c)) == composed)
            #expect(try await allRoutes(c).isEmpty)
        } else {
            #expect(try await allRoutes(c) == [route(leg("r", 0, 1, 1000, 1010, day: Self.day0), leg("r2", 1, 2, 1015, 1025))])
        }
    }

    // MARK: Exact relation-limit boundaries and K1 eligibility independence

    static let throughScope: [PreparedRouteSearchStage] = [.entry, .configuration, .capture, .viewValidity, .endpoints, .scope]

    /// The K1 world plus `n` long Trips (72 stops, the stop limit) on one date. Required relations are
    /// the a→b transfer plus `required - 1` distinct-TripID keys between the long Trips (ordered pairs,
    /// alighting 1...71, boarding 0...70); `k1` extra same-occurrence keys on the first long Trip are
    /// K1-only, one carrying a supplied positive when `positive`.
    func boundaryCase(required: Int, longTrips n: Int, k1 count: Int,
                      positive: Bool) throws -> (case: Case, k1: [ConnectionRelationKey]) {
        let base = try world(extra: (0..<n).map { longTrip("invented-long-\($0)") })
        var distinct: [ConnectionRelationKey] = []
        distinct.reserveCapacity(required)
        outer: for i in 0..<n { for j in 0..<n where i != j { for a in 1...71 { for b in 0...70 {
            guard distinct.count < required - 1 else { break outer }
            distinct.append(key(base, 5 + i, a, 5 + j, b))
        } } } }
        let extra = (0..<count).map { key(base, 5, 1 + $0, 5, 70 - $0) }
        var c = declaring(base, distinct + extra)
        if positive { c.parts.setEntry(extra[0], .positive(try qualifiedPositive(c))) }
        #expect(distinct.count == required - 1)
        #expect(c.parts.relations.targets.count == required + count)
        return (c, extra)
    }

    /// The exact evidence relation limit, 2,048, with no K1 keys (0), ten K1-only keys (1), and ten
    /// with one supplied positive (2). At 2,048 the producer's count guard passes: the view and the
    /// assessment are built (no payload resourceLimit), and the call is held after `.evidence` for the
    /// 2,047 missing entries, or the K1 positive is rejected before `.evidence`. At 2,049 the guard
    /// refuses first, before K1 validation, whatever the K1 entries. Without K1 exclusion, 2,048 plus
    /// ten keys would exceed the limit.
    @Test(arguments: [2_048, 2_049], 0...2) func evidenceRelationLimitBoundaryWithK1Keys(_ required: Int, _ variant: Int) async throws {
        #expect(ConnectionEvidenceLimits.relations == 2_048)
        let (c, extra) = try boundaryCase(required: required, longTrips: 2, k1: variant == 0 ? 0 : 10, positive: variant == 2)
        let d = try declarations(c)
        #expect(d.k1OnlyExcluded == extra)
        #expect(d.connections.required.count == required)
        let closure = try closureOnly(c)
        #expect(closure.connections.required.count == required)
        if required == 2_048 {
            let evidence = try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closure)
            #expect(evidence.records.count == 2_048)
            let assessment = try ResolvedSearchInputAssessment(closure: closure, connections: evidence)
            #expect(assessment.remainingHolds.count == 2_047)
            if variant == 2 {
                #expect(throws: ConnectionEvidenceFailure.trainChangeConflict) {
                    try PreparedRouteK1Validator.validate(d.k1OnlyExcluded, authority: c.view.connections)
                }
            }
        } else {
            #expect(throws: ConnectionEvidenceFailure.resourceLimit) {
                try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closure)
            }
        }
        let expected: (String, [PreparedRouteSearchStage]) = switch (required, variant) {
        case (2_048, 2): ("data", Self.throughScope + [.declarations, .closure])
        case (2_048, _): ("data", Self.throughScope + [.declarations, .closure, .evidence])
        default: ("incomplete", Self.throughScope + [.declarations, .closure])
        }
        #expect(await runStages(c) == expected)
    }

    /// The exact closure connection limit, 23,040, with the same three K1 variants. 23,040 targets pass
    /// the closure; the evidence count guard (2,048) then refuses at the evidence step. 23,041 are
    /// refused by the closure itself, one checkpoint earlier. Both precede K1 validation, so a K1-only
    /// positive cannot change either outcome; without K1 exclusion, 23,040 plus ten keys would exceed
    /// the closure limit.
    @Test(arguments: [23_040, 23_041], 0...2) func closureConnectionLimitBoundaryWithK1Keys(_ required: Int, _ variant: Int) async throws {
        #expect(SearchInputClosureLimits.connections == 23_040)
        let (c, extra) = try boundaryCase(required: required, longTrips: 4, k1: variant == 0 ? 0 : 10, positive: variant == 2)
        let d = try declarations(c)
        #expect(d.k1OnlyExcluded == extra)
        #expect(d.connections.required.count == required)
        if required == 23_040 {
            let closure = try closureOnly(c)
            #expect(closure.connections.required.count == 23_040)
            #expect(throws: ConnectionEvidenceFailure.resourceLimit) {
                try PreparedRouteConnectionEvidenceProducer.evidence(view: c.view, closure: closure)
            }
            #expect(await runStages(c) == ("incomplete", Self.throughScope + [.declarations, .closure]))
        } else {
            #expect(throws: SearchInputClosureConstructionFailure.resourceLimit) { try self.closureOnly(c) }
            #expect(await runStages(c) == ("incomplete", Self.throughScope + [.declarations]))
        }
    }

    /// K1 eligibility reads only the four structural conditions and TripID identity. Each variant
    /// changes one fact of the loop and the prior-date `invented-a`, never today's `invented-a` (the
    /// cross-date key's boarding endpoint, which also carries the required transfer): not loaded (1),
    /// inactive (2), boarding and alighting prohibited at the loop keys' indices and the prior-date
    /// alighting (3), absolute event times shifted with every key's time order kept (4). The K1-only
    /// set equals that of the unchanged world (0), the evidence stage still passes without K1
    /// entries, and a K1-only positive is still rejected before `.evidence`. Downstream holds and
    /// routes may differ and are not asserted.
    @Test(arguments: 0...4) func k1EligibilityIgnoresLoadedActiveEligibilityAndTimes(_ variant: Int) async throws {
        let base = try world()
        let reference = try declarations(declaring(base, k1Keys(base))).k1OnlyExcluded
        #expect(reference == k1Keys(base))
        let varied = try world(adjust: { s in
            switch variant {
            case 1: s.kind = 3
            case 2: s.kind = 1
            case 3: s.boarding = [0: .prohibited, 2: .prohibited]; s.alighting = [1: .prohibited, 2: .prohibited]
            case 4: s.base += 500; s.step = 7
            default: break
            }
        })
        #expect(k1Keys(varied) == k1Keys(base))
        for address in [varied.world.bindings[3].address, varied.world.bindings[4].address] {
            let slot = varied.view.inventory.slots.first { $0.binding.address == address }
            let baseSlot = base.view.inventory.slots.first { $0.binding.address == address }
            switch (variant, slot?.state, baseSlot?.state) {
            case (0, .active?, .active?), (2, .inactive?, .active?): break
            case (1, nil, .active?): break
            case let (3, .active(facts, _)?, .active?):
                #expect(facts.visits[1].alighting == .prohibited && facts.visits[0].boarding == .prohibited)
            case let (4, .active(facts, _)?, .active(baseFacts, _)?):
                #expect("\(facts.visits[1].arrival)" != "\(baseFacts.visits[1].arrival)")
            default: Issue.record("variant \(variant) did not change the intended fact")
            }
        }
        let c = declaring(varied, k1Keys(varied))
        #expect(try declarations(c).k1OnlyExcluded == reference)
        let s = try scope(c)
        #expect(k1Keys(c).allSatisfy { PreparedRouteDeclarationProducer.sameRecurringTrip($0, kept: kept(c), scope: s) })
        #expect(await runStages(c).1.contains(.evidence))
        var rejected = c
        rejected.parts.setEntry(k1Keys(c)[0], .positive(try qualifiedPositive(c)))
        #expect(await runStages(rejected) == ("data", Self.throughScope + [.declarations, .closure]))
    }
}
