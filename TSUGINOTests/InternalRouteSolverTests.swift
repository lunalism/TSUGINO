import Foundation
import Testing
@testable import TSUGINO

struct InternalRouteSolverTests {
    let f = SolverFixture()
    func config(_ p: PreparedInternalSearchInput, work: Int? = nil, slots: Int? = nil,
                winners: Int? = nil, keys: Int? = nil, bytes: Int? = nil) -> InternalSolverExecutionConfiguration {
        let c = InternalSolverExecutionConfiguration.inventedEvaluation(objective: p.objective)
        return .init(objective: c.objective, maximumWork: work ?? c.maximumWork,
            maximumRetainedSlots: slots ?? c.maximumRetainedSlots, maximumWinners: winners ?? c.maximumWinners,
            maximumIdentityKeys: keys ?? c.maximumIdentityKeys, maximumLogicalBytes: bytes ?? c.maximumLogicalBytes)
    }
    func keys(_ result: RouteSearchResult) throws -> [[PreparedTimetableRideKey]] {
        guard case let .internalSuccess(success) = result else { Issue.record("Expected scoped internal success"); return [] }
        switch success.outcome {
        case .noResults: return []
        case .alternatives(let batch):
            #expect(batch.omissions.isEmpty)
            return batch.candidates.map { route in
                route.legs.compactMap { leg in
                    guard case let .rail(rail) = leg else { return nil }
                    guard case let .matched(train) = rail.travel, case let .timetable(context) = rail.scheduledContext else {
                        Issue.record("Noncanonical rail"); return nil
                    }
                    #expect(context.matches(train))
                    return PreparedTimetableRideKey(address: context.binding.address,
                        boardingIndex: train.boardingIndex, alightingIndex: train.alightingIndex)
                }
            }
        }
    }
    @discardableResult func parity(_ p: PreparedInternalSearchInput) async throws -> RouteSearchResult {
        let result = try await InternalRouteSolver().solve(p, configuration: config(p))
        #expect(try keys(result) == ExhaustivePreparedSolverOracle().winners(p))
        return result
    }
    func failure(_ expected: String, _ body: () async throws -> RouteSearchResult) async {
        do { _ = try await body(); Issue.record("Expected \(expected)") }
        catch is CancellationError { #expect(expected == "cancelled") }
        catch let error as RouteSearchFailure {
            let actual: String
            switch error {
            case .searchIncomplete: actual = "incomplete"
            case .dataUnavailable: actual = "data"
            case .configurationUnavailable: actual = "configuration"
            case .noUsableAlternatives: actual = "rejected"
            default: actual = "unexpected"
            }
            #expect(actual == expected)
        } catch { Issue.record("Noncanonical error escaped: \(error)") }
    }
    @Test(arguments: 0...5) func exactObjectiveAllTiesBestLast(_ variant: Int) async throws {
        let direct = f.ride("invented-z-direct", arrival: variant == 0 ? 1005 : variant == 1 ? 1015 : 1020)
        let a = f.ride("invented-a", "O", "H", arrival:1005)
        let b = f.ride("invented-b", "H", "D", arrival:variant == 2 ? 1020 : 1010, departure:1005)
        let other = f.ride("invented-c-direct", arrival:variant >= 3 ? 1010 : 1030, departure:1001)
        let p = try f.prepare([direct,a,b,other], links:[f.link(1,2)])
        let result = try await parity(p), winners = try keys(result)
        #expect(!winners.isEmpty)
        if variant == 0 { #expect(winners[0][0].address.tripID == TripID(direct.name)) }
        if variant == 1 { #expect(winners[0].count == 2) }
        if variant == 2 { #expect(winners[0].count == 1) }
        if variant >= 3 { #expect(winners.count == 1 && winners[0][0].address.tripID.rawValue == other.name) }
    }
    @Test func allDistinctDatedTiesAndStoragePermutations() async throws {
        let a = f.ride("invented-é", day:"invented-day-b")
        let b = f.ride("invented-e\u{301}", day:"invented-day-a")
        let c = f.ride("invented-z", departure:1002)
        let one = try f.prepare([a,b,c]), two = try f.prepare([c,b,a])
        #expect(one.rides[0].train.trip.id == one.rides[1].train.trip.id) // Swift canonical equivalence, dates distinct.
        #expect(one.rides[0].key != one.rides[1].key)
        let x = try keys(await parity(one)), y = try keys(await parity(two))
        #expect(x == y && x.count == 3)
        #expect(x[0][0].address.tripID.rawValue == "invented-e\u{301}") // retained decomposed e sorts before ASCII z.
    }
    @Test func originalIndicesNumericOrderRepeatedVisitsAndThrough() async throws {
        var s = f.ride("invented-through"); s.stops = (0..<12).map { $0 == 11 ? "D" : ($0 == 2 || $0 == 10 ? "O" : "S\($0)") }
        s.step = 0; s.through = true
        s.required = [.init(boardingIndex:10,alightingIndex:11), .init(boardingIndex:2,alightingIndex:11)]
        let p = try f.prepare([s]), result = try await parity(p), k = try keys(result)
        #expect(k.map { $0[0].boardingIndex } == [2,10])
        #expect(k.allSatisfy { $0.count == 1 })
    }
    @Test(arguments: [false,true]) func exactDirectionalWalkAndSameStation(_ walking: Bool) async throws {
        let p = try f.prepare([f.ride("invented-a", "O", "H",arrival:1005),
            f.ride("invented-b", walking ? "J" : "H", "D", departure:1005)],
            links:[f.link(0,1,form: walking ? .walking : .sameStation)])
        let result = try await parity(p)
        if case let .internalSuccess(s) = result, case let .alternatives(b) = s.outcome {
            #expect(b.candidates[0].legs.count == (walking ? 3 : 2))
            if walking, case let .walkingTransfer(w) = b.candidates[0].legs[1] {
                #expect(w.fromStationID.rawValue == "H" && w.toStationID.rawValue == "J")
            }
        } else { Issue.record("Expected route") }
    }
    @Test(arguments: 0...3) func noInferredReverseAbsentOrInfeasibleEdge(_ kind: Int) async throws {
        let a = f.ride("invented-a", "O", "H",arrival:1005), b = f.ride("invented-b", "H", "D",departure:1005)
        var links: [SolverFixture.Link] = []
        if kind == 1 { links = [f.link(1,0,allowance:0)] } // valid evidence but reverse chronology infeasible.
        if kind == 2 { links = [f.link(0,1,kind:1)] }
        if kind == 3 { links = [f.link(0,1,allowance:1)] }
        // Reverse relation joins D→O, hence walking form.
        if kind == 1 { links[0].form = .walking }
        let p = try f.prepare([a,b], links:links)
        #expect(try keys(await parity(p)).isEmpty)
    }
    @Test func stationRevisitZeroDurationAndRideCap() async throws {
        let specs = [f.ride("invented-a","O","A",arrival:1000), f.ride("invented-b","A","B",arrival:1000),
                     f.ride("invented-c","B","A",arrival:1000), f.ride("invented-d","A","D",arrival:1000)]
        let links = [f.link(0,1),f.link(1,2),f.link(2,3)]
        let p = try f.prepare(specs,links:links)
        #expect(try keys(await parity(p))[0].count == 4)
        let capped = try f.prepare(specs,links:links,maximumRides:3)
        #expect(try keys(await parity(capped)).isEmpty)
    }
    @Test func recurringTripCannotRepeatAcrossDates() async throws {
        var a = f.ride("invented-recur"); a.stops = ["O","A","B","D"]; a.step = 0
        a.required = [.init(boardingIndex:0,alightingIndex:1)]
        var c = a; c.day = "invented-other-day"; c.required = [.init(boardingIndex:2,alightingIndex:3)]
        let b = f.ride("invented-middle","A","B",arrival:1000)
        var l = f.link(1,2); l.board = 2
        let p = try f.prepare([a,b,c],links:[f.link(0,1),l])
        #expect(try keys(await parity(p)).isEmpty)
    }
    @Test func independentExhaustiveAdversarialParity() async throws {
        // Different used-Trip prefixes at the same station; no dominance or visited-station pruning.
        for mask in 0..<32 {
            let specs = [f.ride("invented-a","O","H",arrival:1000),f.ride("invented-b","O","H",arrival:1000),
                f.ride("invented-c","H","J",arrival:1000),f.ride("invented-d","J","D",arrival:1000),
                f.ride("invented-e","H","D",arrival:1000),f.ride("invented-f",arrival:mask % 2 == 0 ? 1000 : 1001)]
            let possible = [f.link(0,2),f.link(1,2),f.link(2,3),f.link(0,4),f.link(1,4)]
            let links = possible.enumerated().filter { mask & (1 << $0.offset) != 0 }.map(\.element)
            _ = try await parity(f.prepare(specs,links:links,reverseEvidence: mask % 2 == 0))
        }
    }
    @Test(arguments: InternalSolverStage.allCases) func stageCutoffNeverReturnsPrefix(_ stage: InternalSolverStage) async throws {
        let p = try f.prepare([f.ride("invented-z"),f.ride("invented-a")])
        let hooks = InternalSolverTestHooks(checkpoint: { current,_ in if current == stage { throw RouteSearchFailure.searchIncomplete } })
        await failure("incomplete") { try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:hooks) }
    }
    @Test(arguments: InternalSolverStage.allCases) func cancellationAtEveryStageWinsPendingFailure(_ stage: InternalSolverStage) async throws {
        let p = try f.prepare([f.ride("invented-z"),f.ride("invented-a")])
        let gate = SolverTestGate()
        let task = Task {
            try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint: { current,_ in
                if current == stage { await gate.pause(); throw RouteSearchFailure.searchIncomplete }
            }))
        }
        await gate.waitUntilPaused(); task.cancel(); await gate.release()
        await failure("cancelled") { try await task.value }
    }
    @Test func cancellationBeforeEntryAndInvalidConfiguration() async throws {
        let p = try f.prepare([f.ride("invented-a")]), gate = SolverTestGate()
        let task = Task { await gate.pause(); return try await InternalRouteSolver().solve(p,configuration:config(p,work:0)) }
        await gate.waitUntilPaused(); task.cancel(); await gate.release()
        await failure("cancelled") { try await task.value }
        await failure("configuration") { try await InternalRouteSolver().solve(p,configuration:config(p,work:0)) }
    }
    @Test func exactAndPlusOneWholeInvocationMeters() async throws {
        let p = try f.prepare([f.ride("invented-z"),f.ride("invented-a")]), report = SolverUsageRecorder()
        _ = try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint:{ s,u in
            if s == .terminal { await report.record(u) }
        }))
        let u = try #require(await report.usage)
        let exact = config(p,work:u.work,slots:u.retainedSlots,keys:u.identityKeys,bytes:u.logicalBytes)
        _ = try await InternalRouteSolver().solve(p,configuration:exact)
        for d in 0..<4 {
            let below = config(p,work:u.work - (d == 0 ? 1 : 0),slots:u.retainedSlots - (d == 1 ? 1 : 0),
                               keys:u.identityKeys - (d == 2 ? 1 : 0),bytes:u.logicalBytes - (d == 3 ? 1 : 0))
            await failure("incomplete") { try await InternalRouteSolver().solve(p,configuration:below) }
        }
        print("SOLVER_EXACT work=\(u.work) slots=\(u.retainedSlots) keys=\(u.identityKeys) logical=\(u.logicalBytes)")
    }
    @Test func overflowAndAtomicMeterPreflight() throws {
        let p = try f.prepare([f.ride("invented-a")])
        var m = try InternalSolverMeter(config(p,work:10,slots:10,keys:10,bytes:10))
        try m.charge(work:10,slots:10,keys:10,bytes:10)
        #expect(throws: (any Error).self) { try m.charge(bytes:1) }
        #expect(m.usage.work == 10 && m.usage.logicalBytes == 10)
        #expect(throws: (any Error).self) { _ = try InternalSolverMeter.product(Int.max,2) }
        #expect(throws: (any Error).self) { _ = try InternalSolverMeter.product(-1,1) }
        #expect(try InternalSolverMeter.product(Int.max,1) == Int.max)
    }
    @Test func selectedWinnerEnvelopeStressAndPlusOne() async throws {
        for n in [32,128,256,257] {
            let p = try f.prepare((0..<n).map { f.ride("invented-\(String(format:"%04d",n-$0))") })
            if n == 257 {
                await failure("incomplete") { try await InternalRouteSolver().solve(p,configuration:config(p)) }
            } else {
                let report = SolverUsageRecorder()
                let r = try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint:{s,u in
                    if s == .terminal { await report.record(u) }
                }))
                #expect(try keys(r).count == n)
                let u = try #require(await report.usage)
                print("SOLVER_STRESS ties=\(n) work=\(u.work) slots=\(u.retainedSlots) keys=\(u.identityKeys) logical=\(u.logicalBytes)")
            }
        }
    }
    @Test func overlapIndependentAndOffMainActor() async throws {
        let p = try f.prepare([f.ride("invented-a")]), gate = SolverTestGate()
        let blocked = Task { try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint:{s,_ in
            assertOffMainThread()
            if s == .ordering { await gate.pause() }
        })) }
        await gate.waitUntilPaused()
        let other = try await parity(p)
        #expect(try keys(other).count == 1)
        blocked.cancel(); await gate.release()
        await failure("cancelled") { try await blocked.value }
    }
    @Test func sharedObjectiveAndProjectionFailures() async throws {
        let p = try f.prepare([f.ride("invented-a","O","H",arrival:1005),f.ride("invented-b","H","D",departure:1005)],links:[f.link(0,1)])
        let different = InternalSolverExecutionConfiguration.inventedEvaluation(objective:.init(reference:.init(key:f.uuid(1),revision:f.uuid(2))))
        await failure("data") { try await InternalRouteSolver().solve(p,configuration:different) }
        await failure("data") { try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(brokenSharedRelationIndex:0)) }
    }
    @Test(arguments: 0...4) func localDefectMappingsAndContiguousAllRejected(_ kind: Int) async throws {
        let p = try f.prepare([f.ride("invented-a"),f.ride("invented-b")])
        let expected: [RouteAlternativeRejectionReason] = [.endpointMismatch,.inconsistentTrainEvidence,.invalidScheduledContext,.unverifiedEligibility,.unverifiedTransfer]
        let wrong = try #require(TrainCandidate(trip:f.world([f.ride("invented-other","X","Y")]).bindings[0].trip,boardingIndex:0,alightingIndex:1))
        let hooks = InternalSolverTestHooks(claim:{ _, c in
            var c = c
            switch kind {
            case 0: c.trains[0] = wrong; c.tokens[0] = -1 // precedence before inconsistent token.
            case 1: c.tokens[0] = -1
            case 2: c.arrivals[0] = Date(timeIntervalSinceReferenceDate:1009)
            case 3: c.eligibilityTokens = [-1]
            default: c.transitions.append(.init(key:.init(from:c.keys[0].address,alightingIndex:1,to:c.keys[0].address,boardingIndex:0),form:.walking))
            }
            return c
        })
        do { _ = try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:hooks); Issue.record("Expected rejection") }
        catch RouteSearchFailure.noUsableAlternatives(let r) {
            #expect(r.omissions.map(\.alternativeIndex) == [0,1])
            #expect(r.omissions.allSatisfy { $0.reasons == [expected[kind]] })
        }
    }
    @Test func mixedAdmissionIsIncompleteAndNeverReplacedWithSlower() async throws {
        let p = try f.prepare([f.ride("invented-a"),f.ride("invented-b"),f.ride("invented-slower",arrival:1020)])
        let hook = InternalSolverTestHooks(claim:{ i,c in var c=c; if i == 0 { c.tokens[0] = -1 }; return c })
        await failure("incomplete") { try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:hook) }
    }
    func claim(_ p: PreparedInternalSearchInput, _ tokens: [Int]) -> SolverAdmissionClaim {
        let rides = tokens.map { p.rides[$0] }
        let transitions = zip(rides,rides.dropFirst()).map { x,y in
            let key = ConnectionRelationKey(from:x.key.address,alightingIndex:x.key.alightingIndex,
                                            to:y.key.address,boardingIndex:y.key.boardingIndex)
            let edge = p.connections.firstIndex { $0.key == key }!
            return SolverTransitionClaim(key:key,form:p.positiveEvidence(at:edge)!.form)
        }
        return .init(tokens:tokens,keys:rides.map(\.key),trains:rides.map(\.train),contexts:rides.map(\.context),
            departures:rides.map { $0.context.departure },arrivals:rides.map { $0.context.arrival },
            eligibilityTokens:tokens,transitions:transitions)
    }
    @Test func invalidStructureAndInfeasibleMappings() async throws {
        let p = try f.prepare([f.ride("invented-direct"),f.ride("invented-a","O","H",arrival:1000),
            f.ride("invented-b","H","D",arrival:1000)],links:[f.link(1,2,allowance:1)])
        let invalid = claim(p,[]), infeasible = claim(p,[1,2])
        for (c,reason) in [(invalid,RouteAlternativeRejectionReason.invalidStructure), (infeasible,.infeasibleConnection)] {
            do {
                _ = try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(claim:{_,_ in c}))
                Issue.record("Expected rejection")
            } catch RouteSearchFailure.noUsableAlternatives(let r) {
                #expect(r.omissions.count == 1 && r.omissions[0].reasons == [reason])
            }
        }
    }
    @Test func transferOnlyAllTiesAndPermutedEvidence() async throws {
        let specs = [f.ride("invented-b","O","H",arrival:1000),f.ride("invented-a","O","H",arrival:1000),
                     f.ride("invented-d","H","D",arrival:1000),f.ride("invented-c","H","D",arrival:1000)]
        let links = [f.link(0,2),f.link(0,3),f.link(1,2),f.link(1,3)]
        let a = try f.prepare(specs,links:links), b = try f.prepare(specs,links:links.reversed(),reverseEvidence:true)
        let x = try keys(await parity(a)), y = try keys(await parity(b))
        #expect(x.count == 4 && x == y)
    }
    @Test func realWorkCutoffsAtEveryStageAfterProof() async throws {
        let p = try f.prepare([f.ride("invented-z"),f.ride("invented-a")]), recorder = SolverStageRecorder()
        _ = try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint:{s,u in await recorder.record(s,u)}))
        for stage in InternalSolverStage.allCases {
            let usage = try #require(await recorder.first(stage))
            let limit = usage.work - (stage == .terminal ? 1 : 0)
            await failure("incomplete") { try await InternalRouteSolver().solve(p,configuration:config(p,work:limit)) }
        }
    }
    @Test(arguments: 0..<5) func invalidConfigurationDimensionsAndCeilings(_ dimension: Int) async throws {
        let p = try f.prepare([f.ride("invented-a")])
        for invalid in [0,-1,Int.max] {
            await failure("configuration") {
                try await InternalRouteSolver().solve(p,configuration:config(p,work:dimension == 0 ? invalid : nil,
                    slots:dimension == 1 ? invalid : nil,winners:dimension == 2 ? invalid : nil,
                    keys:dimension == 3 ? invalid : nil,bytes:dimension == 4 ? invalid : nil))
            }
        }
    }
    @Test func retainedComparatorUUIDUnsignedBytesPrefixNumericAndEquivalentClaims() throws {
        let p = try f.prepare([f.ride("invented-a")]), solver = InternalRouteSolver()
        func key(_ uuid: UInt8, _ trip: String, _ day: String = "day", _ board: Int = 2, _ alight: Int = 20) throws -> PreparedTimetableRideKey {
            .init(address:.init(viewID:.init(f.uuid(uuid)),tripID:try #require(TripID(trip)),
                serviceDate:try #require(TimetableServiceDate(day))),boardingIndex:board,alightingIndex:alight)
        }
        let a = try key(1,"é"), b = try key(2,"a"), c = try key(1,"z")
        #expect(try solver.orderedForTesting(p,lhs:[a],rhs:[b])) // UUID dominates text.
        #expect(try solver.orderedForTesting(p,lhs:[c],rhs:[a])) // unsigned UTF-8, no locale.
        #expect(try solver.orderedForTesting(p,lhs:[c],rhs:[c,a])) // strict sequence prefix.
        #expect(try solver.orderedForTesting(p,lhs:[key(1,"a")],rhs:[key(1,"aa")]))
        #expect(try solver.orderedForTesting(p,lhs:[key(1,"a","a")],rhs:[key(1,"a","aa")]))
        #expect(try solver.orderedForTesting(p,lhs:[key(1,"a","day",2)],rhs:[key(1,"a","day",10)]))
        #expect(try !solver.orderedForTesting(p,lhs:[key(1,"é")],rhs:[key(1,"e\u{301}")])) // equal existing keys resolve once.
        #expect(try !solver.orderedForTesting(p,lhs:[c],rhs:[c]))
    }
    func assertOffMainThread() { #expect(!Thread.isMainThread) }
    @Test func branchingStressAndOracleProofDespiteOperationalCutoff() async throws {
        for layers in [2,3,4] {
            let specs = (0..<(layers*3)).map { i in
                f.ride("invented-layer-\(i)", i/3 == 0 ? "O" : "H\(i/3)",
                       i/3 == layers-1 ? "D" : "H\(i/3+1)", arrival:1000)
            }
            var links: [SolverFixture.Link] = []
            for layer in 0..<(layers-1) {
                for a in 0..<3 { for b in 0..<3 { links.append(f.link(layer*3+a,(layer+1)*3+b)) } }
            }
            let p = try f.prepare(specs,links:links), report = SolverUsageRecorder()
            let expected = ExhaustivePreparedSolverOracle().winners(p)
            #expect(expected.count == (layers == 2 ? 9 : layers == 3 ? 27 : 81))
            do {
                let result = try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint:{ s,u in
                    await report.record(u)
                }))
                #expect(try keys(result) == expected)
                let u = try #require(await report.usage)
                print("SOLVER_BRANCH layers=\(layers) complete=\(expected.count) work=\(u.work) slots=\(u.retainedSlots) keys=\(u.identityKeys) logical=\(u.logicalBytes)")
            } catch RouteSearchFailure.searchIncomplete {
                #expect(layers == 4) // Explicit refusal, never a truncated optimal set.
                let u = try #require(await report.usage)
                print("SOLVER_BRANCH layers=\(layers) cutoff work-last-checkpoint=\(u.work) oracle-winners=\(expected.count)")
            }
        }
    }
    @Test func selectedMeterCeilingsExactPlusOneAndOverflow() throws {
        let p = try f.prepare([f.ride("invented-a")]), c = config(p)
        var m = try InternalSolverMeter(c)
        try m.charge(work:c.maximumWork,slots:c.maximumRetainedSlots,keys:c.maximumIdentityKeys,bytes:c.maximumLogicalBytes)
        for d in 0..<4 {
            #expect(throws:(any Error).self) { try m.charge(work:d == 0 ? 1 : 0,slots:d == 1 ? 1 : 0,keys:d == 2 ? 1 : 0,bytes:d == 3 ? 1 : 0) }
        }
        #expect(m.usage.work == c.maximumWork && m.usage.identityKeys == c.maximumIdentityKeys)
        #expect(throws:(any Error).self) { try m.charge(work:Int.max) }
    }
    @Test func rawHookErrorsAreContained() async throws {
        enum InventedFailure: Error { case example }
        let p = try f.prepare([f.ride("invented-a")])
        await failure("data") { try await InternalRouteSolver().solveForTesting(p,configuration:config(p),hooks:.init(checkpoint:{_,_ in throw InventedFailure.example})) }
    }

}

private actor SolverUsageRecorder {
    var usage: InternalSolverUsage?
    func record(_ u: InternalSolverUsage) { usage = u }
}
/// Two-way deterministic barrier; no elapsed-time correctness dependency.
private actor SolverTestGate {
    var paused = false
    var observer: CheckedContinuation<Void,Never>?
    var continuation: CheckedContinuation<Void,Never>?
    func pause() async {
        paused = true; observer?.resume(); observer = nil
        await withCheckedContinuation { continuation = $0 }
    }
    func waitUntilPaused() async {
        if paused { return }; await withCheckedContinuation { observer = $0 }
    }
    func release() { continuation?.resume(); continuation = nil }
}

private actor SolverStageRecorder {
    var records: [InternalSolverStage:InternalSolverUsage] = [:]
    func record(_ s: InternalSolverStage, _ u: InternalSolverUsage) { if records[s] == nil { records[s] = u } }
    func first(_ s: InternalSolverStage) -> InternalSolverUsage? { records[s] }
}
