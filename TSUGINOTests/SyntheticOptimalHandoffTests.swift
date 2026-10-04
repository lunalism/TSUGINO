#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticOptimalHandoffTests {
    private typealias F = InternalFixture
    // Invented complete finite inventories/intervals/slots and every directional
    // connection (explicit absent unless supplied). No real completeness claim.
    private func searcher(_ items: [SyntheticInternalInventory], overrides: [SyntheticInternalConnection] = [],
                          workLimit: Int = 100_000,
                          checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void = { _ in }) -> SyntheticOptimalRouteSearcher {
        .init(configuration: F.configuration(trips: Array(Set(items.map { $0.trip.id.rawValue })), cap: 4),
              view: F.view(items, connections: F.connections(items, overrides: overrides)),
              workLimit: workLimit, checkpoint: checkpoint)
    }
    private func direct(_ id: String, _ arrival: Double = 150, label: String = "d-a") -> SyntheticInternalInventory {
        F.inventory(id, stops: ["A", "D"], times: [100, arrival], label: label)
    }
    private func assertParity(_ searcher: SyntheticOptimalRouteSearcher) async throws -> RouteSearchBatch {
        let batch = try F.batch(await searcher.search(F.request()))
        let all = try await SyntheticInternalRouteSearcher(configuration: searcher.configuration, view: searcher.view).search(F.request())
        guard case .internalSuccess(let success) = all, case .alternatives(let original) = success.outcome else {
            throw F.FixtureError.expectedBatch
        }
        let selected = try SyntheticOptimalRouteSelection.select(.completeInventedUniverse(scope: success.scope, candidates: original.candidates))
        let expected = try #require(RouteSearchBatch(candidates: selected.candidates, omissions: []))
        #expect(F.keys(batch) == F.keys(expected))
        #expect(batch.omissions.isEmpty)
        return batch
    }
    @Test(arguments: [140.0, 160.0]) func fastestDirectOrTransfer(_ directArrival: Double) async throws {
        let d = direct("direct", directArrival), a = F.inventory("first", stops: ["A", "B"], times: [100,110])
        let b = F.inventory("second", stops: ["B", "D"], times: [120,150])
        let s = searcher([d,a,b], overrides: [F.present(F.key(a,1,b,0),5)])
        let batch = try await assertParity(s)
        #expect(F.keys(batch) == (directArrival < 150 ? [["direct/d-a/0-1"]] : [["first/d-a/0-1","second/d-a/0-1"]]))
    }
    @Test func throughServiceWinsEqualArrivalWithFewerChanges() async throws {
        let through = F.inventory("through", stops: ["A","B","D"], times: [100,110,150], segments: [("L1",0,1),("L2",1,2)])
        let a = F.inventory("first", stops: ["A","B"], times: [100,110]), b = F.inventory("second", stops: ["B","D"], times: [120,150])
        let batch = try await assertParity(searcher([a,b,through], overrides: [F.present(F.key(a,1,b,0),5)]))
        #expect(F.keys(batch) == [["through/d-a/0-2"]])
        #expect(batch.candidates[0].transferCount == 0)
        guard case .rail(let rail) = batch.candidates[0].legs[0], case .matched(let train) = rail.travel else { throw F.FixtureError.expectedBatch }
        #expect(train.trip.lineSegments == through.trip.lineSegments)
    }
    @Test func tiedHandlesPreserveDatesRepeatedVisitsSnapshotsAndOrder() async throws {
        let repeated = F.inventory("repeat", stops: ["A","B","A","D"], times: [100,110,120,150], label: "day-1")
        let anotherDate = F.inventory("repeat", stops: ["A","B","A","D"], times: [100,110,120,150], label: "day-2")
        // Same snapshot, two explicitly inventoried dates; retain original indices.
        let combined = SyntheticInternalInventory(trip: repeated.trip, intervals: repeated.intervals,
                                                   slots: repeated.slots! + anotherDate.slots!)
        let z = direct("z"), slow = direct("a-slow",190)
        for items in [[slow,z,combined], [combined,z,slow]] {
            let batch = try await assertParity(searcher(items))
            #expect(F.keys(batch) == [["repeat/day-1/0-3"],["repeat/day-1/2-3"],["repeat/day-2/0-3"],["repeat/day-2/2-3"],["z/d-a/0-1"]])
            for candidate in batch.candidates.prefix(4) {
                guard case .rail(let rail) = candidate.legs[0], case .matched(let train) = rail.travel,
                      case .timetable(let context) = rail.scheduledContext else { throw F.FixtureError.expectedBatch }
                #expect(context.binding.address.viewID == F.viewID)
                #expect(context.matches(train))
                #expect(train.trip.stopSequence == repeated.trip.stopSequence)
                #expect(train.trip.lineSegments == repeated.trip.lineSegments)
                #expect(context.arrival == F.date(150))
                #expect(context.departure == F.date(context.boardingIndex == 0 ? 100 : 120))
            }
        }
    }
    @Test(arguments: [false, true]) func directionalConnectionAssociation(_ walking: Bool) async throws {
        let a = F.inventory("a", stops: ["A","B"], times: [100,110])
        let b = F.inventory("b", stops: [walking ? "C" : "B","D"], times: [120,150])
        let batch = try await assertParity(searcher([a,b], overrides: [F.present(F.key(a,1,b,0),10,walking: walking)]))
        #expect(batch.candidates[0].legs.count == (walking ? 3 : 2))
        if walking {
            guard case .walkingTransfer(let w) = batch.candidates[0].legs[1] else { throw F.FixtureError.expectedBatch }
            #expect(w.fromStationID == F.station("B") && w.toStationID == F.station("C"))
        }
        let reversed = searcher([a,b], overrides: [F.present(F.key(b,0,a,1),10,walking: walking)])
        guard case .internalSuccess(let empty) = try await reversed.search(F.request()) else { throw F.FixtureError.expectedBatch }
        if case .noResults = empty.outcome {} else { Issue.record("Reverse relation must not grant forward travel") }
    }
    @Test(arguments: [[0], [1], [0,1]]) func selectedRejectionsUseFrozenIndicesNotExploredOrdinals(_ rejected: [Int]) async throws {
        let all = rejected.count == 2
        let s = searcher([direct("a-slow",190),direct("b"),direct("c")])
        // Explored ordinal 0 is slow; selected indices are b=0,c=1.
        do {
            try await SyntheticOptimalHandoffFailureHarness.rejectSelectedClaims(searcher: s, request: F.request(), selectedIndices: Set(rejected))
        } catch RouteSearchFailure.noUsableAlternatives(let rejections) {
            #expect(all)
            #expect(rejections.omissions.map(\.alternativeIndex) == [0,1])
            #expect(rejections.omissions.allSatisfy { $0.reasons == [.inconsistentTrainEvidence] })
        } catch RouteSearchFailure.searchIncomplete { #expect(!all) }
    }
    @Test func incompleteInventoryWithGoodDirectIsUnavailable() async throws {
        let missing = SyntheticInternalInventory(trip: direct("missing").trip, intervals: nil, slots: nil)
        await #expect {
            try await searcher([direct("good"),missing]).search(F.request())
        } throws: { if case RouteSearchFailure.dataUnavailable = $0 { true } else { false } }
    }
    @Test func completeEmptyIsScopedAndNotRejected() async throws {
        let old = direct("empty")
        let empty = SyntheticInternalInventory(trip: old.trip, intervals: old.intervals, slots: [])
        let result = try await searcher([empty]).search(F.request())
        guard case .internalSuccess(let success) = result else { throw F.FixtureError.expectedBatch }
        #expect(success.scope.viewID == F.viewID)
        if case .noResults = success.outcome {} else { Issue.record("Expected scoped empty") }
    }
    @Test func budgetAndCancellationAtEveryNewBoundary() async throws {
        // Two rides give a fixed insertion-sort comparison count regardless of
        // randomized dictionary iteration. Do not compare numeric budgets across
        // different three-or-more-key preparation orders.
        let items = [direct("b"),direct("c")]
        let s = searcher(items)
        let preparation = HandoffCounter()
        var engine = SyntheticInternalRouteEngine(configuration: s.configuration, view: s.view, workLimit: 100_000,
            checkpoint: { stage in await preparation.record(stage) })
        _ = try await engine.prepare(F.request())
        let preparedCount = await preparation.count
        let whole = HandoffCounter()
        _ = try await searcher(items, checkpoint: { stage in await whole.record(stage) }).search(F.request())
        let fullCount = await whole.count
        #expect(fullCount > preparedCount)
        // Every exact budget prefix from post-prepare through finish must fail,
        // proving one continuous counter. Includes descriptors, kernel and claims.
        for budget in preparedCount..<fullCount {
            await #expect {
                try await searcher(items, workLimit: budget).search(F.request())
            } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
        }
        _ = try await searcher(items, workLimit: fullCount).search(F.request())
        for offset in 1...(fullCount - preparedCount) {
            let counter = HandoffCounter()
            await #expect(throws: CancellationError.self) {
                try await searcher(items, checkpoint: { stage in
                    await counter.record(stage)
                    if await counter.count == preparedCount + offset { throw CancellationError() }
                }).search(F.request())
            }
        }
    }
    @Test func completeAlternativeCeilingNeverReturnsFirst64() async throws {
        let items = (0..<65).map { direct("t\($0)") }
        // Cap one ride avoids unrelated connection enumeration for this bound test.
        let s = SyntheticOptimalRouteSearcher(configuration: F.configuration(trips: items.map { $0.trip.id.rawValue }, cap: 1),
            view: F.view(items), workLimit: 100_000)
        await #expect { try await s.search(F.request()) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
    }
}
private actor HandoffCounter {
    private(set) var count = 0
    func record(_ stage: SyntheticInternalStage) { count += 1 }
}
#endif
