import Foundation
import Testing
@testable import TSUGINO

/// Consumer §32.6 metered merge-sort winner ordering: canonical §24.4 order for every count
/// and discovery permutation, exact ordering-stage accounting, cutoffs inside the sort and
/// cancellation at the ordering/admission/finalization checkpoints. Invented data only.
struct InternalSolverWinnerOrderingTests {
    let f = SolverFixture()

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
        #expect(batch.omissions.isEmpty)
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

    // MARK: Independent §24.4 order and comparator cost (test-side, no solver code)

    struct Fields { let uuid: [UInt8], trip: [UInt8], day: [UInt8], board: Int, alight: Int }
    func fields(_ k: PreparedTimetableRideKey) -> Fields {
        let u = k.address.viewID.rawValue.uuid
        return .init(uuid: [u.0,u.1,u.2,u.3,u.4,u.5,u.6,u.7,u.8,u.9,u.10,u.11,u.12,u.13,u.14,u.15],
                     trip: Array(k.address.tripID.rawValue.utf8), day: Array(k.address.serviceDate.label.utf8),
                     board: k.boardingIndex, alight: k.alightingIndex)
    }
    /// Expected order and the solver comparator's charges: (less?, work, differing pairs, scratch bytes).
    func compare(_ lhs: [PreparedTimetableRideKey], _ rhs: [PreparedTimetableRideKey]) -> (Bool, Int, Int, Int) {
        var work = 0
        for (a, b) in zip(lhs, rhs) {
            work += 1
            if a == b { continue }
            let x = fields(a), y = fields(b)
            work += 1
            let scratch = 320 + 3 * (x.uuid.count + x.trip.count + x.day.count + y.uuid.count + y.trip.count + y.day.count)
            for (l, r) in [(x.uuid, y.uuid), (x.trip, y.trip), (x.day, y.day)] {
                for (lb, rb) in zip(l, r) {
                    work += 1
                    if lb != rb { return (lb < rb, work, 1, scratch) }
                }
                if l.count != r.count { return (l.count < r.count, work, 1, scratch) }
            }
            if x.board != y.board { return (x.board < y.board, work, 1, scratch) }
            return (x.alight < y.alight, work, 1, scratch)
        }
        return (lhs.count < rhs.count, work, 0, 0)
    }
    /// The §32.6 bottom-up merge replayed on discovery-ordered winners: expected sorted output and
    /// the exact ordering-stage (work, slots, bytes, comparisons) excluding the next stage entry.
    func expectedOrdering(_ discovered: [[PreparedTimetableRideKey]]) -> ([[PreparedTimetableRideKey]], Int, Int, Int, Int) {
        let n = discovered.count
        var work = 1, slots = 2 * n + 1, bytes = 24 * n + 72, comparisons = 0
        var order = Array(0..<n), width = 1
        while width < n {
            var out: [Int] = [], low = 0
            while low < n {
                let middle = min(low + width, n), high = min(middle + width, n)
                var i = low, j = middle
                while i < middle && j < high {
                    let (less, w, differing, scratch) = compare(discovered[order[j]], discovered[order[i]])
                    work += 2 + w; slots += 9 * differing; bytes += scratch; comparisons += 1
                    if less { out.append(order[j]); j += 1 } else { out.append(order[i]); i += 1 }
                }
                work += (middle - i) + (high - j)
                out += order[i..<middle] + order[j..<high]
                low = high
            }
            order = out; width *= 2
        }
        for w in discovered { work += 1; slots += w.count + 1; bytes += 8 * w.count + 24 }
        return (order.map { discovered[$0] }, work, slots, bytes, comparisons)
    }
    func sortedByIndependentOrder(_ ids: [[PreparedTimetableRideKey]]) -> [[PreparedTimetableRideKey]] {
        ids.sorted { compare($0, $1).0 }
    }

    actor Usage {
        var entries: [(InternalSolverStage, InternalSolverUsage)] = []
        func record(_ s: InternalSolverStage, _ u: InternalSolverUsage) { entries.append((s, u)) }
        func first(_ s: InternalSolverStage) -> InternalSolverUsage? { entries.first { $0.0 == s }?.1 }
    }
    func traced(_ p: PreparedInternalSearchInput) async throws -> (RouteSearchResult, Usage) {
        let usage = Usage()
        let r = try await InternalRouteSolver().solveForTesting(p, configuration: config(p),
            hooks: .init(checkpoint: { s, u in await usage.record(s, u) }))
        return (r, usage)
    }

    /// Direct ties in a chosen discovery order (P ride order = spec order for direct rides).
    func ties(_ count: Int, _ mode: String) throws -> PreparedInternalSearchInput {
        var names = (0..<count).map { "d-" + String(format: "%04d", $0) }
        switch mode {
        case "descending": names.reverse()
        case "permuted":
            var rng = PRSSplitMix64(state: 0x5453_5547_494E_4F32 &+ UInt64(count))
            for i in stride(from: names.count - 1, to: 0, by: -1) { names.swapAt(i, Int(rng.next() % UInt64(i + 1))) }
        default: break
        }
        // Zero winners: one ride outside the request window, so P has no usable ride (scoped noResults).
        if count == 0 { return try f.prepare([f.ride("d-late", arrival: 3010, departure: 3000)]) }
        return try f.prepare(names.map { f.ride($0) })
    }

    // MARK: Canonical order, counts and permutations

    @Test(arguments: [0, 1, 2, 3, 7, 8, 9, 255, 256], ["ascending", "descending", "permuted"])
    func canonicalOrderAndExactOrderingAccounting(_ count: Int, _ mode: String) async throws {
        let p = try ties(count, mode)
        let (result, usage) = try await traced(p)
        let got = try keys(result)
        // Discovery order of direct ties is P ride order.
        let discovered = count == 0 ? [] : p.rides.map { [$0.key] }
        let (sorted, work, slots, bytes, comparisons) = expectedOrdering(discovered)
        #expect(got == sorted && got == sortedByIndependentOrder(discovered) && got.count == count)
        if p.rides.count <= 16 { #expect(got == ExhaustivePreparedSolverOracle().winners(p)) }
        let a = try #require(await usage.first(.ordering)), b = try #require(await usage.first(.admission))
        // Ordering-stage delta, excluding the admission entry's own unit charge.
        #expect(b.work - a.work - 1 == work)
        #expect(b.retainedSlots - a.retainedSlots == slots && b.logicalBytes - a.logicalBytes == bytes)
        #expect(b.identityKeys == a.identityKeys)
        let bound = count <= 1 ? 0 : count * Int(ceil(Foundation.log2(Double(count))))
        #expect(comparisons <= bound)
        if mode == "descending", count == 256 { #expect(comparisons == 1_024) }
    }

    /// Multi-ride equal optima (pair-equal prefix tokens), mixed dated/decomposed spellings and
    /// numeric original indices keep the exhaustive-oracle order.
    @Test func multiRideAndIdentityEdgeTiesMatchOracle() async throws {
        let l = PreparedRouteWorkloads.layered(f, prefixes: ["A", "B"], width: 3, stations: ["O", "H", "D"])
        let layered = try f.prepare(l.specs, links: l.links)
        #expect(try keys(await traced(layered).0) == ExhaustivePreparedSolverOracle().winners(layered))

        var through = f.ride("invented-through")
        through.stops = (0..<12).map { $0 == 11 ? "D" : ($0 == 2 || $0 == 10 ? "O" : "S\($0)") }
        through.step = 0; through.base = 1010; through.through = true
        through.required = [.init(boardingIndex: 10, alightingIndex: 11), .init(boardingIndex: 2, alightingIndex: 11)]
        let edges = [f.ride("invented-é", day: "invented-day-b"), f.ride("invented-e\u{301}", day: "invented-day-a"),
                     f.ride("invented-z"), f.ride("invented-a", day: "invented-day-aa")]
        for specs in [edges + [through], Array(([through] + edges).reversed())] {
            let p = try f.prepare(specs)
            let got = try keys(await traced(p).0)
            #expect(got == ExhaustivePreparedSolverOracle().winners(p))
            #expect(got == sortedByIndependentOrder(got) && got.count == 6)
        }
    }

    // MARK: Resource boundaries, cutoffs and cancellation

    /// Exact final usage completes; one unit less in any dimension refuses with no output.
    @Test(arguments: [9, 256]) func exactAndPlusOneWholeInvocation(_ count: Int) async throws {
        let p = try ties(count, "descending")
        let (_, usage) = try await traced(p)
        let u = try #require(await usage.first(.terminal))
        _ = try await InternalRouteSolver().solve(p, configuration: config(p, work: u.work, slots: u.retainedSlots,
                                                                         keys: u.identityKeys, bytes: u.logicalBytes))
        for d in 0..<4 {
            let below = config(p, work: u.work - (d == 0 ? 1 : 0), slots: u.retainedSlots - (d == 1 ? 1 : 0),
                               keys: u.identityKeys - (d == 2 ? 1 : 0), bytes: u.logicalBytes - (d == 3 ? 1 : 0))
            await #expect(throws: RouteSearchFailure.self) { _ = try await InternalRouteSolver().solve(p, configuration: below) }
        }
    }

    /// Work and slot limits that land inside the sort (preflight, first comparison, mid-merge,
    /// last permuted copy) and at the following admission/finalization entries are searchIncomplete.
    @Test func cutoffsInsideOrderingAndLaterStagesNeverReturnOutput() async throws {
        let p = try ties(9, "descending")
        let (_, usage) = try await traced(p)
        let o = try #require(await usage.first(.ordering)), a = try #require(await usage.first(.admission))
        let fin = try #require(await usage.first(.finalization))
        let workLimits = [o.work, o.work + 1, o.work + 2, (o.work + a.work) / 2, a.work - 2, a.work - 1, fin.work - 1]
        for limit in workLimits {
            await expectIncomplete { try await InternalRouteSolver().solve(p, configuration: config(p, work: limit)) }
        }
        // Slot preflight for index/scratch/output (2n + 1) and the last by-value permuted copy.
        for limit in [o.retainedSlots + 2 * 9, a.retainedSlots - 1] {
            await expectIncomplete { try await InternalRouteSolver().solve(p, configuration: config(p, slots: limit)) }
        }
    }
    func expectIncomplete(_ body: () async throws -> RouteSearchResult) async {
        do { _ = try await body(); Issue.record("Expected searchIncomplete, got a result") }
        catch RouteSearchFailure.searchIncomplete {}
        catch { Issue.record("Expected searchIncomplete, got \(error)") }
    }

    /// Cancellation requested at the ordering, admission and finalization checkpoints of a
    /// multi-winner search wins with CancellationError and no output.
    @Test(arguments: [InternalSolverStage.ordering, .admission, .finalization])
    func cancellationAroundOrderingWins(_ stage: InternalSolverStage) async throws {
        let p = try ties(9, "descending")
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
