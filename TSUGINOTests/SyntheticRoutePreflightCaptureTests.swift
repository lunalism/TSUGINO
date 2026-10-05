#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticRoutePreflightCaptureTests {
    private typealias F = InternalFixture
    private let configuration = F.configuration(trips: ["T1"], cap: 1, duration: 100)
    private enum Failure: Error { case expectedFacts, expectedResult }

    private func view(_ version: Int = 1, incoherent: Bool = false) throws -> SyntheticInternalView {
        // Complete invented one-date, one-Trip, [0,1] domain, allowed endpoints,
        // affirmed continuity, no inter-Trip connections; no source qualification claim.
        let row = F.inventory("T1", stops: ["A","D"], times: [100, version == 1 ? 150 : 160], label: "2026-04-13")
        let id = TimetableViewID(try #require(UUID(uuidString: version == 1
            ? "00000000-0000-0000-0000-000000000001" : "00000000-0000-0000-0000-000000000002")))
        let slot = try #require(row.slots?.first)
        guard case .active(let facts, let continuity) = slot.activation else { throw Failure.expectedFacts }
        let binding = try #require(TimetableOccurrenceBinding(address: .init(viewID: id,
            tripID: row.trip.id, serviceDate: slot.address.serviceDate), trip: row.trip))
        let visits = try facts.visits.map { v in
            try #require(TimetableVisitFacts(binding: binding, originalIndex: v.originalIndex,
                arrival: v.arrival, departure: v.departure, boarding: v.boarding, alighting: v.alighting))
        }
        let newFacts = try #require(TimetableOccurrenceFacts(binding: binding, visits: visits))
        let input = SyntheticInternalInventory(trip: row.trip, intervals: row.intervals,
            slots: [.init(address: binding.address, activation: .active(newFacts, continuity))])
        return F.view([input], id: id, from: incoherent ? 1000 : 0, until: 1000)
    }
    private func searcher(_ supplier: PreflightSupplier, limit: Int = 100_000,
                          checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void = { _ in }) -> SyntheticOptimalRouteSearcher {
        .init(configuration: configuration, workLimit: limit, captureView: { await supplier.read() }, checkpoint: checkpoint)
    }
    private func assertOutput(_ result: RouteSearchResult, _ view: SyntheticInternalView) throws {
        guard case .internalSuccess(let success) = result, case .alternatives(let batch) = success.outcome else { throw Failure.expectedResult }
        #expect(success.scope.viewID == view.id)
        #expect(success.scope.profile.serviceDateInterpretation == view.policies.qualifiedManifest)
        #expect(success.scope.profile.connectionPolicy == view.policies.directionalTotalAllowance)
        #expect(batch.omissions.isEmpty && F.keys(batch) == [["T1/2026-04-13/0-1"]])
        let candidate = try #require(batch.candidates.first)
        #expect(candidate.origin == F.station("A") && candidate.destination == F.station("D"))
        #expect(candidate.transferCount == 0 && candidate.legs.count == 1)
        guard case .rail(let rail) = candidate.legs[0], case .matched(let train) = rail.travel,
              case .timetable(let context) = rail.scheduledContext,
              let slot = view.inventories[0].slots?.first,
              case .active(let facts, _) = slot.activation else { throw Failure.expectedResult }
        #expect(context.binding.matches(facts.binding) && context.matches(train))
        #expect(context.binding.address == slot.address)
        #expect(context.boardingIndex == 0 && context.alightingIndex == 1)
        #expect(train.boardingIndex == 0 && train.alightingIndex == 1)
        #expect(context.departure == F.date(100) && context.arrival == F.date(view.id == F.viewID ? 150 : 160))
    }
    private func withCall(_ s: SyntheticOptimalRouteSearcher,
                          _ body: (Task<RouteSearchResult, any Error>) async throws -> Void) async throws {
        let task = Task { try await s.search(F.request()) }
        do { try await body(task); task.cancel(); _ = await task.result }
        catch { task.cancel(); _ = await task.result; throw error }
    }

    @Test(arguments: [0,1,2,3])
    func preflightFailureDoesNotRead(_ mode: Int) async throws {
        let supplier = PreflightSupplier(try view())
        let cfg: SyntheticInternalConfiguration? = mode == 0 ? nil : mode == 1
            ? .init(profile: configuration.profile, permitted: false) : configuration
        let limit = mode == 2 ? -1 : mode == 3 ? 0 : 100_000
        let s = SyntheticOptimalRouteSearcher(configuration: cfg, workLimit: limit, captureView: { await supplier.read() })
        #expect(await supplier.count == 0) // construction has no read side effect
        await #expect { try await s.search(F.request()) } throws: {
            if mode == 3, case RouteSearchFailure.searchIncomplete = $0 { return true }
            if mode != 3, case RouteSearchFailure.configurationUnavailable = $0 { return true }
            return false
        }
        #expect(await supplier.count == 0)
    }

    @Test(arguments: [false,true])
    func configurationCheckpointCompletesBeforeCapture(_ cancel: Bool) async throws {
        let supplier = PreflightSupplier(try view()), gate = RoutingTestGate()
        let s = searcher(supplier, checkpoint: { stage in if stage == .configuration { try await gate.wait() } })
        try await withCall(s) { task in
            await gate.waitUntilEntered()
            #expect(await supplier.count == 0)
            if cancel { task.cancel() }
            await gate.release()
            if cancel {
                await #expect { try await task.value } throws: { $0 is CancellationError }
            } else { try assertOutput(await task.value, view()) }
        }
        #expect(await supplier.count == (cancel ? 0 : 1))
    }

    @Test func alreadyCancelledEntryDoesNotReadEvenWithInvalidConfiguration() async throws {
        let supplier = PreflightSupplier(nil), gate = RoutingTestGate()
        let s = SyntheticOptimalRouteSearcher(configuration: nil, workLimit: -1, captureView: { await supplier.read() })
        let task = Task {
            do { try await gate.wait() } catch is CancellationError {}
            return try await s.search(F.request())
        }
        await gate.waitUntilEntered(); task.cancel()
        await #expect { try await task.value } throws: { $0 is CancellationError }
        _ = await task.result
        #expect(await supplier.count == 0)
    }

    @Test(arguments: [false,true])
    func missingAndIncoherentCapturedViewsUseExistingFailure(_ incoherent: Bool) async throws {
        let supplier = PreflightSupplier(incoherent ? try view(incoherent: true) : nil)
        await #expect { try await searcher(supplier).search(F.request()) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
        #expect(await supplier.count == 1)
    }

    @Test(arguments: [0,1,2])
    func cancellationImmediatelyAfterReadWinsOverCapturedValue(_ mode: Int) async throws {
        let supplier = PreflightSupplier(mode == 0 ? nil : try view(incoherent: mode == 1))
        let gate = RoutingTestGate(), events = PreflightEvents()
        let s = SyntheticOptimalRouteSearcher(configuration: configuration, workLimit: 100_000, captureView: {
            let retained = await supplier.read()
            // Supplier remains nonthrowing. The gate only controls return timing;
            // cancellation is observed by qualification immediately after the await.
            do { try await gate.wait() } catch { #expect(error is CancellationError) }
            return retained
        }, checkpoint: { await events.record($0) })
        try await withCall(s) { task in
            await gate.waitUntilEntered(); task.cancel()
            await #expect { try await task.value } throws: { $0 is CancellationError }
        }
        #expect(await supplier.count == 1)
        #expect(await events.stages == [.configuration])
    }

    @Test func fixedAndCapturedPathsAgreeAndShareUninterruptedAllowance() async throws {
        let v = try view(), baseline = PreflightEvents()
        let fixed = SyntheticOptimalRouteSearcher(configuration: configuration, view: v, workLimit: 100_000,
            checkpoint: { await baseline.record($0) })
        try assertOutput(await fixed.search(F.request()), v)
        let count = await baseline.stages.count
        #expect(count > 1)
        // Every prefix includes configuration, qualification, preparation, selection
        // and admission. No allowance reset after the one read, no added charge unit.
        for allowance in 0...count {
            let supplier = PreflightSupplier(v), events = PreflightEvents()
            let captured = searcher(supplier, limit: allowance, checkpoint: { await events.record($0) })
            let reference = SyntheticOptimalRouteSearcher(configuration: configuration, view: v, workLimit: allowance)
            if allowance == count {
                try assertOutput(await captured.search(F.request()), v)
                try assertOutput(await reference.search(F.request()), v)
            } else {
                for s in [captured,reference] {
                    await #expect { try await s.search(F.request()) } throws: {
                        if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
                    }
                }
            }
            #expect(await supplier.count == (allowance == 0 ? 0 : 1))
            #expect(await events.stages.count == allowance)
        }
    }

    @Test func laterReplacementCannotRelabelRetainedCapture() async throws {
        let v1 = try view(), v2 = try view(2), supplier = PreflightSupplier(v1), gate = RoutingTestGate()
        let first = InternalFirstCheckpoint()
        let s = searcher(supplier, checkpoint: { stage in
            if stage == .validation, await first.claim() { try await gate.wait() }
        })
        try await withCall(s) { a in
            await gate.waitUntilEntered()
            await supplier.replace(v2)
            try assertOutput(await s.search(F.request()), v2)
            await gate.release()
            try assertOutput(await a.value, v1)
        }
        #expect(await supplier.count == 2)
    }
}
private actor PreflightSupplier {
    private var value: SyntheticInternalView?
    private(set) var count = 0
    init(_ view: SyntheticInternalView?) { value = view }
    func read() -> SyntheticInternalView? { count += 1; return value }
    func replace(_ view: SyntheticInternalView?) { value = view }
}
private actor PreflightEvents {
    private(set) var stages: [SyntheticInternalStage] = []
    func record(_ stage: SyntheticInternalStage) { stages.append(stage) }
}
#endif
