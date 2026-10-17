#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Always-run correctness for the §30 workload generators (invented data only):
/// determinism, analytic oracle = independent exhaustive oracle = composed result,
/// out-of-profile invariance and the end-to-end exact/+1 preparation boundaries.
struct PreparedRouteWorkloadTests {
    let p = PreparedRouteFixture()

    func workload(_ id: String) throws -> PreparedRouteWorkload {
        try #require(PreparedRouteWorkloads.matrix.first { $0.id == id })
    }
    /// One hooked composed call: class, last composition checkpoint and solver trace.
    func hooked(_ c: PreparedRouteFixture.Case) async -> (PRSCall, String, PreparedRouteSearchStage?, PRSStageTrace) {
        let trace = PRSStageTrace()
        let hooks = PreparedRouteSearchTestHooks(checkpoint: { trace.mark($0) },
            solver: .init(checkpoint: { trace.solver($0, $1) }, claim: nil, brokenSharedRelationIndex: nil))
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: hooks)
        let call = await PRSHarness.call(searcher, c.request, watchdog: .seconds(600))
        let last = trace.all.last?.stage
        return (call, PRSHarness.fineClass(call, last: last), last, trace)
    }

    @Test func matrixIsFiniteDeterministicAndUnique() {
        let a = PreparedRouteWorkloads.matrix, b = PreparedRouteWorkloads.matrix
        #expect(a.count == 58) // §30.4 unconditional cases; W7p is added only after its pre-check
        #expect(Set(a.map(\.id)).count == a.count)
        #expect(a.map(\.id) == b.map(\.id))
        #expect(a.map(\.seed) == b.map(\.seed))
        for (percent, count) in [(0, 0), (10, 7), (25, 18), (50, 36), (100, 72)] {
            let mask = PreparedRouteWorkloads.w3Mask(percent: percent)
            #expect(mask.feasible.count == count)
            #expect(mask.feasible == PreparedRouteWorkloads.w3Mask(percent: percent).feasible)
            #expect(mask.seed == 0x5453_5547_494E_4F00 + UInt64(percent))
        }
        #expect(PreparedRouteWorkloads.pairs.count == 55 && PreparedRouteWorkloads.pairs.prefix(16).contains {
            $0.boardingIndex == 0 && $0.alightingIndex == 10 })
    }

    /// Small shapes (P ≤ 16 rides): analytic expectation, `ExhaustivePreparedSolverOracle`
    /// and the composed searcher must agree exactly, including §24.4 order.
    @Test(arguments: ["W1-0001", "W1-0002", "W1-0008", "W2a-02", "W2a-03", "W2a-04", "W2a-08", "W2b-2", "W2b-3", "W2b-4",
                      "W2b-8", "W4b", "W4d", "W5-1", "W5-2", "W5t", "W6-0000"])
    func smallShapesMatchAnalyticAndExhaustiveOracle(_ id: String) async throws {
        let w = try workload(id)
        let c = try w.build(p)
        let s = PRSHarness.structural(c)
        let prepared = try #require(s.prepared)
        try #require(prepared.rides.count <= 16) // the oracle preconditions ≤ 16
        let oracle = ExhaustivePreparedSolverOracle().winners(prepared).map { keys in
            keys.map { "\($0.address.tripID.rawValue)/\($0.address.serviceDate.label)/\($0.boardingIndex)-\($0.alightingIndex)" }
        }
        switch w.expectation {
        case let .success(ids), let .successOrSolverCutoff(ids): #expect(oracle == ids)
        default: Issue.record("small shape must have an analytic success expectation")
        }
        let (call, fine, last, _) = await hooked(c)
        #expect(PRSHarness.check(w.expectation, fine: fine, call: call, last: last) == nil, "\(id): \(fine)")
    }

    /// Larger analytic-only shapes still match exactly when they complete.
    @Test(arguments: ["W3-000", "W3-010", "W3a-010", "W4a", "W4c"])
    func analyticOnlyShapesMatch(_ id: String) async throws {
        let w = try workload(id)
        let (call, fine, last, _) = await hooked(try w.build(p))
        #expect(PRSHarness.check(w.expectation, fine: fine, call: call, last: last) == nil)
        if id == "W3-000" || id.hasPrefix("W4") { #expect(call.noResults) }
    }

    @Test func outOfProfileGrowthPreservesResult() async throws {
        var digests: [String?] = []
        for id in ["W6-0000", "W6-0096", "W6p-0384"] {
            let w = try workload(id)
            let c = try w.build(p)
            let s = PRSHarness.structural(c)
            #expect(s.fields["occurrences"] as? Int == 6 && s.fields["targets"] as? Int == 9)
            #expect(s.fields["intervals"] as? Int == 6)
            let (call, fine, last, _) = await hooked(c)
            #expect(PRSHarness.check(w.expectation, fine: fine, call: call, last: last) == nil)
            digests.append(call.digest)
        }
        #expect(Set(digests).count == 1 && digests[0] != nil)
    }

    /// §30.3 end-to-end exact/+1 boundaries. 4,096 rides: preparation SUCCEEDS and the solver
    /// cuts off in indexing; 4,097: preparation refuses (provisional searchIncomplete).
    @Test func rideBoundaryDistinguishesSolverCutoffFromPreparationRefusal() async throws {
        let exact = try workload("W7r-4096").build(p)
        let s = PRSHarness.structural(exact)
        #expect(s.prepared?.rides.count == PreparedInputLimits.rides)
        let (call, fine, last, trace) = await hooked(exact)
        #expect(call.failure == "searchIncomplete" && fine == "I-solver" && last == .preparedInput)
        #expect(trace.last?.0 == .indexing)

        let over = try workload("W7r-4097").build(p)
        let o = PRSHarness.structural(over)
        #expect(o.prepared == nil && o.failedAt == "preparedInput resourceLimit")
        let (overCall, overFine, overLast, overTrace) = await hooked(over)
        #expect(overCall.failure == "searchIncomplete" && overFine == "I-prep" && overLast == .assessment)
        #expect(overTrace.last == nil) // the solver never started
    }

    @Test(arguments: ["W7e-2048", "W7e-2049", "W7o-2880", "W7o-2881", "W7c-23040", "W7c-23041"])
    func preparationBoundaryPairs(_ id: String) async throws {
        let w = try workload(id)
        let (call, fine, last, _) = await hooked(try w.build(p))
        #expect(PRSHarness.check(w.expectation, fine: fine, call: call, last: last) == nil,
                "\(id): \(fine) \(call.failure ?? "") last=\(String(describing: last))")
    }
}
#endif
