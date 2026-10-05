#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// E2 test composition only. No production supplier, scheduling policy or new engine.
struct SyntheticRouteCaptureIsolationTests {
    private typealias F = InternalFixture
    private enum Failure: Error { case expectedResult }
    private let configuration = F.configuration(trips: ["T1"], cap: 1, duration: 100)

    private func view(_ version: Int, unavailable: Bool = false) throws -> SyntheticInternalView {
        // Explicit complete invented request universe: one dated T1, all original
        // eligible intervals, allowed endpoints and affirmed continuity. One ride
        // maximum; no inter-Trip connections exist. Policy association is stipulated.
        let original = F.inventory("T1", stops: version == 1 ? ["A","B","D"] : ["A","C","D"],
            times: version == 1 ? [100,120,150] : [100,130,170], label: "2026-04-13")
        let id = TimetableViewID(try #require(UUID(uuidString: version == 1
            ? "00000000-0000-0000-0000-000000000001" : "00000000-0000-0000-0000-000000000002")))
        let source = try #require(original.slots?.first)
        guard case .active(let facts, let continuity) = source.activation else { throw Failure.expectedResult }
        let binding = try #require(TimetableOccurrenceBinding(address: .init(viewID: id, tripID: original.trip.id,
            serviceDate: source.address.serviceDate), trip: original.trip))
        let visits = try facts.visits.map { v in
            try #require(TimetableVisitFacts(binding: binding, originalIndex: v.originalIndex,
                arrival: v.arrival, departure: v.departure, boarding: v.boarding, alighting: v.alighting))
        }
        let newFacts = try #require(TimetableOccurrenceFacts(binding: binding, visits: visits))
        let inventory = SyntheticInternalInventory(trip: original.trip, intervals: original.intervals,
            slots: [.init(address: binding.address, activation: unavailable ? .unavailable : .active(newFacts, continuity))])
        return F.view([inventory], id: id)
    }

    /// Own and join every controlled worker, including assertion/error exits.
    private func withCall(_ port: CapturePort,
                          _ body: (Task<RouteSearchResult, any Error>) async throws -> Void) async throws {
        let task = Task { try await port.search(F.request()) }
        do {
            try await body(task)
            task.cancel()
            _ = await task.result
        } catch {
            task.cancel()
            _ = await task.result
            throw error
        }
    }

    private func assertOutput(_ result: RouteSearchResult, view: SyntheticInternalView, last: Int = 2) throws {
        guard case .internalSuccess(let success) = result,
              case .alternatives(let batch) = success.outcome else { throw Failure.expectedResult }
        #expect(success.scope.viewID == view.id)
        #expect(success.scope.profile.serviceDateInterpretation == view.policies.qualifiedManifest)
        #expect(success.scope.profile.connectionPolicy == view.policies.directionalTotalAllowance)
        #expect(batch.omissions.isEmpty && F.keys(batch) == [["T1/2026-04-13/0-\(last)"]])
        let candidate = try #require(batch.candidates.first)
        #expect(candidate.origin == F.station("A") && candidate.destination == F.station("D"))
        #expect(candidate.transferCount == 0 && candidate.legs.count == 1)
        guard case .rail(let rail) = candidate.legs[0], case .matched(let train) = rail.travel,
              case .timetable(let context) = rail.scheduledContext else { throw Failure.expectedResult }
        let slot = try #require(view.inventories.first?.slots?.first)
        guard case .active(let facts, let continuity) = slot.activation else { throw Failure.expectedResult }
        #expect(context.binding.matches(facts.binding) && context.matches(train))
        #expect(context.binding.address == slot.address && context.binding.address.viewID == view.id)
        #expect(train.boardingIndex == 0 && train.alightingIndex == last)
        #expect(context.boardingIndex == 0 && context.alightingIndex == last)
        #expect(facts.visits.map(\.originalIndex) == Array(0...last))
        #expect(continuity.contains { $0.interval == .init(boarding: 0, alighting: last) && $0.evidence == .affirmed })
        #expect(facts.visits.allSatisfy { $0.boarding == .allowed && $0.alighting == .allowed })
        guard case .exact(let departure) = facts.visits[0].departure,
              case .exact(let arrival) = facts.visits[last].arrival else { throw Failure.expectedResult }
        #expect(context.departure == departure.date && context.arrival == arrival.date)
        #expect(context.departure == F.date(100))
        #expect(context.arrival == F.date(view.id == F.viewID ? 150 : 170))
    }

    @Test func capturedViewSurvivesReplacementAndLaterCaptureUsesNewView() async throws {
        let v1 = try view(1), v2 = try view(2), supplier = CaptureSupplier(v1)
        let gate = RoutingTestGate()
        let port = CapturePort(configuration: configuration, supplier: supplier,
            afterCapture: { ordinal in if ordinal == 0 { try await gate.wait() } })
        try await withCall(port) { a in
            await gate.waitUntilEntered() // V1 already read, before any engine work
            await supplier.replace(v2)
            let b = try await port.search(F.request()) // finishes while A is suspended
            try assertOutput(b, view: v2)
            await gate.release()
            try assertOutput(await a.value, view: v1)
        }
        #expect(await supplier.reads == [v1.id, v2.id])
        #expect(v1.inventories[0].trip.stopSequence == [F.station("A"),F.station("B"),F.station("D")])
    }

    @Test func overlappingEnginesKeepAccountingAndCanonicalStateIndependent() async throws {
        let v = F.view([F.inventory("T1", stops: ["A","D"], times: [100,150], label: "2026-04-13")])
        let baseline = CaptureEvents()
        let oracle = SyntheticOptimalRouteSearcher(configuration: configuration, view: v, workLimit: 100_000,
            checkpoint: { await baseline.record(0, $0) })
        try assertOutput(await oracle.search(F.request()), view: v, last: 1)
        let expected = await baseline.stages(0)
        let gate = RoutingTestGate(), events = CaptureEvents(), supplier = CaptureSupplier(v)
        // The existing allowance is exactly the measured charge count for this
        // deterministic one-Trip fixture, not a new unit or production budget.
        let port = CapturePort(configuration: configuration, supplier: supplier, limit: expected.count,
            checkpoint: { ordinal, stage in
                await events.record(ordinal, stage)
                if ordinal == 0 && stage == .admission { try await gate.wait() }
            })
        try await withCall(port) { a in
            await gate.waitUntilEntered() // A has already discovered and selected
            try assertOutput(await port.search(F.request()), view: v, last: 1)
            await gate.release()
            try assertOutput(await a.value, view: v, last: 1)
        }
        // Trace order is not an accepted contract; one interval avoids variable
        // multi-key sorting work. Each call independently consumes the full allowance.
        #expect(await events.stages(0).count == expected.count)
        #expect(await events.stages(1).count == expected.count)
        #expect(await supplier.reads == [v.id,v.id])
    }

    @Test func cancellingOneSuspendedCallDoesNotCancelAnother() async throws {
        let v = try view(1), supplier = CaptureSupplier(v), aGate = RoutingTestGate(), bGate = RoutingTestGate()
        let events = CaptureEvents()
        let port = CapturePort(configuration: configuration, supplier: supplier,
            afterCapture: { ordinal in try await (ordinal == 0 ? aGate : bGate).wait() },
            checkpoint: { await events.record($0, $1) })
        try await withCall(port) { a in
            await aGate.waitUntilEntered()
            try await withCall(port) { b in
                await bGate.waitUntilEntered()
                a.cancel()
                await #expect { try await a.value } throws: { $0 is CancellationError }
                #expect(await events.stages(0).isEmpty)
                #expect(await aGate.cancellationObserved)
                #expect(await bGate.cancellationObserved == false)
                await bGate.release()
                try assertOutput(await b.value, view: v)
            }
        }
        #expect(await supplier.reads == [v.id,v.id])
    }

    @Test func cancellationBeforeCaptureReadsNothing() async throws {
        let supplier = CaptureSupplier(try view(1)), ready = RoutingTestGate(), events = CaptureEvents()
        let port = CapturePort(configuration: configuration, supplier: supplier, checkpoint: { await events.record($0,$1) })
        // Gate belongs to the test caller; cancellation is deliberately swallowed
        // there solely to enter the port with an already-cancelled task.
        let task = Task {
            do { try await ready.wait() } catch is CancellationError {}
            return try await port.search(F.request())
        }
        await ready.waitUntilEntered()
        task.cancel()
        await #expect { try await task.value } throws: { $0 is CancellationError }
        _ = await task.result
        #expect(await supplier.reads.isEmpty)
        #expect(await events.stages(0).isEmpty)
    }

    @Test(arguments: [false, true])
    func pendingFailureIsIsolatedAndObservedCancellationWins(_ cancel: Bool) async throws {
        let bad = try view(1, unavailable: true), good = try view(2), supplier = CaptureSupplier(bad)
        let gate = RoutingTestGate()
        let port = CapturePort(configuration: configuration, supplier: supplier,
            afterCapture: { ordinal in if ordinal == 0 { try await gate.wait() } })
        try await withCall(port) { a in
            await gate.waitUntilEntered()
            await supplier.replace(good)
            try assertOutput(await port.search(F.request()), view: good)
            if cancel { a.cancel() }
            await gate.release()
            await #expect { try await a.value } throws: {
                if cancel { return $0 is CancellationError }
                if case RouteSearchFailure.dataUnavailable = $0 { return true }
                return false
            }
        }
        #expect(await supplier.reads == [bad.id,good.id])
    }

    @Test(arguments: [false, true])
    func admissionAbortHasNoPartialSuccessOrEffectOnOtherCall(_ cancel: Bool) async throws {
        let v = try view(1), supplier = CaptureSupplier(v), gate = RoutingTestGate()
        let port = CapturePort(configuration: configuration, supplier: supplier,
            checkpoint: { ordinal, stage in
                if ordinal == 0 && stage == .admission {
                    try await gate.wait()
                    throw RouteSearchFailure.searchIncomplete
                }
            })
        try await withCall(port) { a in
            await gate.waitUntilEntered()
            try assertOutput(await port.search(F.request()), view: v)
            if cancel { a.cancel() }
            await gate.release()
            await #expect { try await a.value } throws: {
                if cancel { return $0 is CancellationError }
                if case RouteSearchFailure.searchIncomplete = $0 { return true }
                return false
            }
        }
    }
}

/// Short atomic reference operations only. No search runs on this actor.
private actor CaptureSupplier {
    private var current: SyntheticInternalView
    private(set) var reads: [TimetableViewID] = []
    init(_ view: SyntheticInternalView) { current = view }
    func replace(_ view: SyntheticInternalView) { current = view }
    func capture() -> (Int, SyntheticInternalView) {
        let ordinal = reads.count
        let value = current
        reads.append(value.id)
        return (ordinal,value)
    }
}
private actor CaptureEvents {
    private var values: [Int:[SyntheticInternalStage]] = [:]
    func record(_ ordinal: Int, _ stage: SyntheticInternalStage) { values[ordinal, default: []].append(stage) }
    func stages(_ ordinal: Int) -> [SyntheticInternalStage] { values[ordinal] ?? [] }
}

/// Only valid fixed configuration is supplied by these tests. Not a production
/// preflight adapter: that integration remains separately unresolved.
private nonisolated struct CapturePort: RouteSearching {
    let configuration: SyntheticInternalConfiguration
    let supplier: CaptureSupplier
    var limit: Int = 100_000
    var afterCapture: @Sendable (Int) async throws -> Void = { _ in }
    var checkpoint: @Sendable (Int, SyntheticInternalStage) async throws -> Void = { _, _ in }

    @concurrent
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        try Task.checkCancellation()
        let (ordinal, view) = await supplier.capture()
        try Task.checkCancellation()
        try await afterCapture(ordinal)
        try Task.checkCancellation()
        return try await SyntheticOptimalRouteSearcher(configuration: configuration, view: view, workLimit: limit,
            checkpoint: { stage in try await checkpoint(ordinal, stage) }).search(request)
    }
}
#endif
