import Foundation
import Testing
@testable import TSUGINO

/// Consumer §34 exploration-only relation lists: completeness against original-input scans for
/// every ride pair, exhaustive-oracle and trace parity, winner-cap discovery order, phantom
/// corruption against independent admission, exact construction accounting, cutoffs and
/// cancellation. Invented data only.
struct InternalSolverRelationIndexTests {
    let f = SolverFixture()
    let pr = PreparedRouteFixture()

    func config(_ p: PreparedInternalSearchInput, work: Int? = nil, slots: Int? = nil,
                keys: Int? = nil, bytes: Int? = nil) -> InternalSolverExecutionConfiguration {
        let c = InternalSolverExecutionConfiguration.inventedEvaluation(objective: p.objective)
        return .init(objective: c.objective, maximumWork: work ?? c.maximumWork,
            maximumRetainedSlots: slots ?? c.maximumRetainedSlots, maximumWinners: c.maximumWinners,
            maximumIdentityKeys: keys ?? c.maximumIdentityKeys, maximumLogicalBytes: bytes ?? c.maximumLogicalBytes)
    }
    func keys(_ result: RouteSearchResult) throws -> [[PreparedTimetableRideKey]] {
        guard case let .internalSuccess(success) = result else { Issue.record("Expected scoped success"); return [] }
        guard case let .alternatives(batch) = success.outcome else { return [] }
        return try batch.candidates.map { route in
            try route.legs.compactMap { leg in
                guard case let .rail(rail) = leg else { return nil }
                guard case let .matched(train) = rail.travel, case let .timetable(context) = rail.scheduledContext else {
                    throw RouteSearchFailure.dataUnavailable
                }
                return PreparedTimetableRideKey(address: context.binding.address,
                    boardingIndex: train.boardingIndex, alightingIndex: train.alightingIndex)
            }
        }
    }

    // MARK: Independent original-input definitions (test-side, no solver code)

    /// The current scan semantics: the first relation with the transition key, accepted if feasible.
    func scanAccepts(_ p: PreparedInternalSearchInput, _ x: Int, _ y: Int) -> Bool {
        let a = p.rides[x].key, b = p.rides[y].key
        let key = ConnectionRelationKey(from: a.address, alightingIndex: a.alightingIndex, to: b.address, boardingIndex: b.boardingIndex)
        guard let r = p.connections.firstIndex(where: { $0.key == key }) else { return false }
        return p.connections[r].state == .feasible
    }
    func bruteLists(_ p: PreparedInternalSearchInput) -> (out: [[Int]], into: [[Int]], outgoing: [Bool]) {
        let out = p.rides.map { ride in p.connections.indices.filter {
            p.connections[$0].state == .feasible && p.connections[$0].key.from == ride.key.address
                && p.connections[$0].key.alightingIndex == ride.key.alightingIndex } }
        let into = p.rides.map { ride in p.connections.indices.filter {
            p.connections[$0].state == .feasible && p.connections[$0].key.to == ride.key.address
                && p.connections[$0].key.boardingIndex == ride.key.boardingIndex } }
        // Original outgoing definition: any feasible relation from the ride's endpoint.
        let outgoing = p.rides.map { ride in p.connections.contains {
            $0.state == .feasible && $0.key.from == ride.key.address && $0.key.alightingIndex == ride.key.alightingIndex } }
        return (out, into, outgoing)
    }
    /// Every mismatch between built lists and the original-input scan, over every ride pair.
    func mismatches(_ p: PreparedInternalSearchInput, outgoing: [Bool], out: [[Int]], into: [[Int]]) -> [String] {
        var found: [String] = []
        let brute = bruteLists(p)
        if out != brute.out { found.append("O lists differ") }
        if into != brute.into { found.append("In lists differ") }
        if outgoing != brute.outgoing { found.append("outgoing differs") }
        for x in p.rides.indices {
            for y in p.rides.indices where !Set(out[x]).isDisjoint(with: into[y]) != scanAccepts(p, x, y) {
                found.append("pair \(x)->\(y)")
            }
        }
        return found
    }

    // MARK: Adversarial shapes

    /// Shared endpoints and several intervals per occurrence, recurring TripID on two dates,
    /// feasible/infeasible/absent relations, relations to endpoints with no ride, walking and
    /// same-station forms, repeated stations and zero duration.
    func adversarial(_ variant: Int) throws -> PreparedInternalSearchInput {
        var a = f.ride("inv-a"); a.stops = ["O", "M", "H", "O2"]; a.step = variant % 2 == 0 ? 0 : 5
        a.required = [.init(boardingIndex: 0, alightingIndex: 2), .init(boardingIndex: 1, alightingIndex: 2),
                      .init(boardingIndex: 0, alightingIndex: 3)]
        var b = f.ride("inv-b"); b.stops = ["H", "K", "D"]; b.base = 1030; b.step = 0
        b.required = [.init(boardingIndex: 0, alightingIndex: 2), .init(boardingIndex: 1, alightingIndex: 2),
                      .init(boardingIndex: 0, alightingIndex: 1)]
        var c = f.ride("inv-a", day: "invented-day-2"); c.stops = ["O", "M", "H", "O2"]; c.step = 0; c.base = 1040
        c.required = [.init(boardingIndex: 2, alightingIndex: 3)]
        var d = f.ride("inv-d"); d.stops = ["J", "H", "D"]; d.base = 1031; d.step = 0
        d.required = [.init(boardingIndex: 0, alightingIndex: 2), .init(boardingIndex: 1, alightingIndex: 2)]
        let direct = f.ride("inv-z", arrival: variant >= 2 ? 1030 : 1100)
        var links: [SolverFixture.Link] = []
        var l1 = f.link(0, 1); l1.alight = 2; l1.board = 0; links.append(l1)                       // shared endpoints
        var l2 = f.link(0, 1, form: .walking, allowance: 99); l2.alight = 2; l2.board = 1; links.append(l2) // infeasible
        var l3 = f.link(0, 3, form: .walking); l3.alight = 2; l3.board = 0; links.append(l3)      // walking
        var l4 = f.link(0, 3, kind: 1); l4.alight = 2; l4.board = 1; links.append(l4)             // qualified absent
        var l6 = f.link(1, 0, form: .walking); l6.alight = 1; l6.board = 2; links.append(l6)      // to-endpoint with no ride
        var l7 = f.link(2, 1, form: .walking); l7.alight = 3; l7.board = 0; links.append(l7)
        if variant >= 1 { var l8 = f.link(3, 1, form: .walking); l8.alight = 1; l8.board = 1; links.append(l8) }
        return try f.prepare([a, b, c, d, direct], links: links)
    }
    /// A recurring TripID on two dates joined through another trip: the trip-repeat check (not the
    /// lists) must refuse the second ride.
    func recurring() throws -> PreparedInternalSearchInput {
        var a = f.ride("inv-recur"); a.stops = ["O", "A", "B", "D"]; a.step = 0
        a.required = [.init(boardingIndex: 0, alightingIndex: 1)]
        var c = a; c.day = "invented-other-day"; c.required = [.init(boardingIndex: 2, alightingIndex: 3)]
        var l = f.link(1, 2); l.board = 2
        return try f.prepare([a, f.ride("inv-middle", "A", "B", arrival: 1000), c], links: [f.link(0, 1), l])
    }
    func workloadInputs() throws -> [(String, PreparedInternalSearchInput)] {
        try ["W2a-04", "W2b-4", "W3-025", "W3a-010", "W5-3", "W4b", "W6p-0384"].map { id in
            let w = try #require(PreparedRouteWorkloads.matrix.first { $0.id == id })
            return (id, try pr.prepareThroughProducers(w.build(pr)).1)
        } + [("recurring", try recurring())]
    }

    // MARK: Completeness and equivalence

    @Test(arguments: 0..<4) func listsEqualOriginalScanForEveryRidePair(_ variant: Int) async throws {
        let p = try adversarial(variant)
        let index = try await InternalRouteSolver().relationIndexForTesting(p)
        #expect(mismatches(p, outgoing: index.outgoing, out: index.outgoingRelations, into: index.incomingRelations).isEmpty)
        #expect(index.outgoingRelations.allSatisfy { $0 == $0.sorted() } && index.incomingRelations.allSatisfy { $0 == $0.sorted() })
        // Several rides share endpoints, so one relation is listed for more than one ride.
        #expect(index.outgoingRelations.flatMap { $0 }.count > Set(index.outgoingRelations.flatMap { $0 }).count)
    }
    @Test func workloadListsEqualOriginalScanForEveryRidePair() async throws {
        for (id, p) in try workloadInputs() {
            let index = try await InternalRouteSolver().relationIndexForTesting(p)
            #expect(mismatches(p, outgoing: index.outgoing, out: index.outgoingRelations, into: index.incomingRelations).isEmpty, "\(id)")
        }
    }
    /// A dropped entry is invisible to admission; the every-pair check is what detects it.
    @Test func droppedEntryIsDetectedByTheEquivalenceCheck() async throws {
        let p = try adversarial(1)
        let index = try await InternalRouteSolver().relationIndexForTesting(p)
        var out = index.outgoingRelations
        let z = try #require(out.indices.first { !out[$0].isEmpty })
        out[z].removeFirst()
        #expect(!mismatches(p, outgoing: index.outgoing, out: out, into: index.incomingRelations).isEmpty)
    }
    @Test(arguments: 0..<4) func exhaustiveOracleParity(_ variant: Int) async throws {
        let p = try adversarial(variant)
        let r = try await InternalRouteSolver().solve(p, configuration: config(p))
        #expect(try keys(r) == ExhaustivePreparedSolverOracle().winners(p))
    }
    @Test func adversarialMaskOracleParity() async throws {
        for mask in 0..<32 {
            let specs = [f.ride("invented-a","O","H",arrival:1000), f.ride("invented-b","O","H",arrival:1000),
                f.ride("invented-c","H","J",arrival:1000), f.ride("invented-d","J","D",arrival:1000),
                f.ride("invented-e","H","D",arrival:1000), f.ride("invented-f",arrival:mask % 2 == 0 ? 1000 : 1001)]
            let possible = [f.link(0,2), f.link(1,2), f.link(2,3), f.link(0,4), f.link(1,4)]
            let p = try f.prepare(specs, links: possible.enumerated().filter { mask & (1 << $0.offset) != 0 }.map(\.element),
                                  reverseEvidence: mask % 2 == 0)
            #expect(try keys(await InternalRouteSolver().solve(p, configuration: config(p))) == ExhaustivePreparedSolverOracle().winners(p))
        }
    }

    // MARK: Trace parity and discovery order

    /// Test-side replay of the scan-based DFS (current candidate order, trip check, linear key
    /// scan, bound): the number of destination-reaching appends, i.e. tieCollection entries.
    func replayTieEntries(_ p: PreparedInternalSearchInput) -> Int {
        let bound = min(p.scope.profile.maximumRailRides, p.rides.count)
        let canExtend = bruteLists(p).outgoing
        var path: [Int] = [], next = [0], ties = 0
        while !next.isEmpty {
            if next[next.count - 1] == p.rides.count { next.removeLast(); if !path.isEmpty { path.removeLast() }; continue }
            let c = next[next.count - 1]; next[next.count - 1] += 1
            let ride = p.rides[c]
            if path.isEmpty {
                if ride.train.anchors.boardingStationID != p.scope.request.origin { continue }
            } else {
                if path.contains(where: { p.rides[$0].train.trip.id == ride.train.trip.id }) { continue }
                if !scanAccepts(p, path[path.count - 1], c) { continue }
            }
            if path.count >= bound { continue }
            path.append(c)
            if ride.train.anchors.alightingStationID == p.scope.request.destination { ties += 1 }
            if path.count < bound && canExtend[c] { next.append(0) } else { path.removeLast() }
        }
        return ties
    }
    actor Stages {
        var entries: [(InternalSolverStage, InternalSolverUsage)] = []
        func record(_ s: InternalSolverStage, _ u: InternalSolverUsage) { entries.append((s, u)) }
        func count(_ s: InternalSolverStage) -> Int { entries.filter { $0.0 == s }.count }
        func first(_ s: InternalSolverStage) -> InternalSolverUsage? { entries.first { $0.0 == s }?.1 }
    }
    @Test func traceParityWithScanReplay() async throws {
        var inputs = try (0..<4).map { ("adversarial-\($0)", try adversarial($0)) }
        inputs += try workloadInputs()
        for (id, p) in inputs {
            let stages = Stages()
            _ = try await InternalRouteSolver().solveForTesting(p, configuration: config(p),
                hooks: .init(checkpoint: { s, u in await stages.record(s, u) }))
            #expect(await stages.count(.tieCollection) == replayTieEntries(p), "\(id)")
        }
    }
    /// 17 × 16 two-ride equal ties precede a strictly earlier direct ride in P order: the cap is
    /// reached before the direct ride is explored (as with the scan solver). Moving the direct
    /// ride first makes the same search complete, so the outcome depends on discovery order.
    @Test(arguments: [false, true]) func winnerCapFollowsUnchangedDiscoveryOrder(_ directFirst: Bool) async throws {
        let firsts = (0..<17).map { f.ride("cap-a-\(String(format: "%02d", $0))", "O", "H", arrival: 1010) }
        let seconds = (0..<16).map { f.ride("cap-b-\(String(format: "%02d", $0))", "H", "D", arrival: 1030, departure: 1010) }
        let direct = f.ride("cap-direct", arrival: 1020)
        let specs = directFirst ? [direct] + firsts + seconds : firsts + seconds + [direct]
        let offset = directFirst ? 1 : 0
        let links = (0..<17).flatMap { a in (0..<16).map { b in f.link(offset + a, offset + 17 + b) } }
        let p = try f.prepare(specs, links: links)
        do {
            let winners = try keys(await InternalRouteSolver().solve(p, configuration: config(p)))
            #expect(directFirst && winners.count == 1)
        } catch RouteSearchFailure.searchIncomplete {
            #expect(!directFirst)
        }
        #expect(replayTieEntries(p) >= (directFirst ? 1 : 257))
    }

    // MARK: Phantom corruption against independent admission

    func corrupted(_ p: PreparedInternalSearchInput, from x: Int, to y: Int, relation r: Int) async throws -> RouteSearchResult {
        try await InternalRouteSolver().solveForTesting(p, configuration: config(p), hooks: .init(corruptRelationIndex: { out, into in
            out[x].append(r); out[x].sort(); into[y].append(r); into[y].sort()
        }))
    }
    func twoRide(_ kind: Int, allowance: Double = 0) throws -> PreparedInternalSearchInput {
        // Only the phantom transition can reach D; a decoy relation supplies an existing index.
        try f.prepare([f.ride("ph-a", "O", "H", arrival: 1005), f.ride("ph-b", "H", "D", departure: 1005),
                       f.ride("ph-c", "X", "Y", arrival: 1005), f.ride("ph-d", "Y", "Z", departure: 1005)],
                      links: [kind == 0 ? f.link(2, 3) : f.link(0, 1, allowance: allowance, kind: kind == 2 ? 1 : 0)],
                      destination: "D")
    }
    @Test func phantomToInfeasibleRelationIsRejectedByAdmission() async throws {
        let p = try twoRide(1, allowance: 99)
        #expect(p.connections[0].state == .infeasible)
        do { _ = try await corrupted(p, from: 0, to: 1, relation: 0); Issue.record("Expected rejection") }
        catch RouteSearchFailure.noUsableAlternatives(let r) {
            #expect(r.omissions.count == 1 && r.omissions[0].reasons == [.infeasibleConnection])
        }
    }
    @Test(arguments: [0, 2]) func phantomWithoutPositiveEvidenceIsDataUnavailable(_ kind: Int) async throws {
        // kind 0: the phantom's index belongs to a relation with another key (no relation has the
        // transition key); kind 2: the relation is qualified absent (no positive evidence).
        let p = try twoRide(kind)
        if kind == 2 { #expect(p.connections[0].state == .absentUnderCompleteAuthority) }
        do { _ = try await corrupted(p, from: 0, to: 1, relation: 0); Issue.record("Expected dataUnavailable") }
        catch RouteSearchFailure.dataUnavailable {}
    }

    // MARK: Accounting, resources, cutoffs and cancellation

    /// Indexing-stage delta from the approved accounting: payload, storage, per-ride snapshot and
    /// order key, per-relation evidence check, then 1 + R + 4,096·P·F + E for the lists.
    @Test func exactConstructionAccountingAndStorage() async throws {
        for (id, p) in try workloadInputs() + [("adversarial-3", try adversarial(3))] {
            let stages = Stages()
            _ = try await InternalRouteSolver().solveForTesting(p, configuration: config(p),
                hooks: .init(checkpoint: { s, u in await stages.record(s, u) }))
            let i = try #require(await stages.first(.indexing)), e = try #require(await stages.first(.exploration))
            let rides = p.rides.count, relations = p.connections.count
            let feasible = p.connections.filter { $0.state == .feasible }.count
            let brute = bruteLists(p), entries = brute.out.joined().count + brute.into.joined().count
            let perRide = p.rides.reduce(0) { sum, ride in
                let a = ride.key.address
                return sum + 4_096 * (ride.train.trip.stopSequence.count + 1) + 16 + a.tripID.rawValue.utf8.count + a.serviceDate.label.utf8.count
            }
            let construction = 1 + relations + 4_096 * rides * feasible + entries
            #expect(e.work - i.work == p.logicalPayloadBytes + 1 + perRide + 4_096 * relations + construction + 1, "\(id)")
            // Slots: payload 1, ride arrays P + 1, order keys 4P, list headers 2P, entries E.
            #expect(e.retainedSlots - i.retainedSlots == 1 + (rides + 1) + 4 * rides + 2 * rides + entries, "\(id)")
        }
    }
    @Test func exactAndPlusOneWholeInvocation() async throws {
        let p = try workloadInputs()[0].1
        let stages = Stages()
        _ = try await InternalRouteSolver().solveForTesting(p, configuration: config(p),
            hooks: .init(checkpoint: { s, u in await stages.record(s, u) }))
        let u = try #require(await stages.first(.terminal))
        _ = try await InternalRouteSolver().solve(p, configuration: config(p, work: u.work, slots: u.retainedSlots,
                                                                         keys: u.identityKeys, bytes: u.logicalBytes))
        for d in 0..<4 {
            let below = config(p, work: u.work - (d == 0 ? 1 : 0), slots: u.retainedSlots - (d == 1 ? 1 : 0),
                               keys: u.identityKeys - (d == 2 ? 1 : 0), bytes: u.logicalBytes - (d == 3 ? 1 : 0))
            await expectIncomplete { try await InternalRouteSolver().solve(p, configuration: below) }
        }
    }
    func expectIncomplete(_ body: () async throws -> RouteSearchResult) async {
        do { _ = try await body(); Issue.record("Expected searchIncomplete, got a result") }
        catch RouteSearchFailure.searchIncomplete {}
        catch { Issue.record("Expected searchIncomplete, got \(error)") }
    }
    /// Work and slot limits inside the construction pass (preflight, first state check, first pair,
    /// first entry, last charge) and every work limit across the first exploration frames,
    /// which include intersection lookups and merge steps, are searchIncomplete.
    @Test func cutoffsInsideConstructionAndLookupNeverReturnOutput() async throws {
        let p = try f.prepare([f.ride("cl-a", "O", "H", arrival: 1005), f.ride("cl-b", "H", "D", departure: 1005)],
                              links: [f.link(0, 1)])
        let stages = Stages()
        _ = try await InternalRouteSolver().solveForTesting(p, configuration: config(p),
            hooks: .init(checkpoint: { s, u in await stages.record(s, u) }))
        let e = try #require(await stages.first(.exploration)), t = try #require(await stages.first(.tieCollection))
        let i = try #require(await stages.first(.indexing))
        // P = 2, R = F = 1, E = 2: construction = 1 + 1 + 4,096·2 + 2, ending one charge before exploration entry.
        let start = e.work - 1 - (1 + 1 + 4_096 * 2 + 2)
        for limit in [start, start + 1, start + 2, start + 2 + 4_096, e.work - 2, e.work - 1] {
            await expectIncomplete { try await InternalRouteSolver().solve(p, configuration: config(p, work: limit)) }
        }
        await expectIncomplete { try await InternalRouteSolver().solve(p, configuration: config(p, slots: i.retainedSlots + 1 + 3 + 8 + 4 + 1)) }
        for limit in e.work..<t.work {
            await expectIncomplete { try await InternalRouteSolver().solve(p, configuration: config(p, work: limit)) }
        }
    }
    @Test(arguments: [InternalSolverStage.indexing, .exploration]) func cancellationAtIndexingAndExploration(_ stage: InternalSolverStage) async throws {
        let p = try adversarial(3)
        let task = Task {
            try await InternalRouteSolver().solveForTesting(p, configuration: config(p), hooks: .init(checkpoint: { s, _ in
                if s == stage { withUnsafeCurrentTask { $0?.cancel() } }
            }))
        }
        do { _ = try await task.value; Issue.record("Expected cancellation") }
        catch is CancellationError {}
        catch { Issue.record("Expected CancellationError, got \(error)") }
    }
}
