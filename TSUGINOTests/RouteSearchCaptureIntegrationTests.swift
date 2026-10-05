#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@MainActor
struct RouteSearchCaptureIntegrationTests {
    private typealias F = InternalFixture
    private let configuration = F.configuration(trips: ["T1"], cap: 1, duration: 100)
    private enum Failure: Error { case expectedFacts, expectedResult }

    private func view(_ version: Int = 1) throws -> SyntheticInternalView {
        // Complete invented one-date, one-Trip, [0,1] domain, allowed endpoints,
        // affirmed continuity, no inter-Trip connections; no source qualification claim.
        // F.view stipulates station/line membership, validity [0,1000] and coherent
        // interpretation/connection policies for both revisions. Completeness is invented.
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
        return F.view([input], id: id, from: 0, until: 1000)
    }
    private func assertOutput(_ result: RouteSearchResult, _ view: SyntheticInternalView) throws {
        guard case .internalSuccess(let success) = result, case .alternatives(let batch) = success.outcome else { throw Failure.expectedResult }
        #expect(success.scope.viewID == view.id)
        #expect(success.scope.lowerBound == F.date(100) && success.scope.upperBound == F.date(200))
        #expect(success.scope.profile.identity == configuration.profile.identity)
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

    @Test func replacementCancelsSuspendedCaptureAndPublishesOnlyV2() async throws {
        try await exercise(replace: true)
    }

    @Test func explicitCancellationStopsAtCaptureAndRetainsCancelledAttempt() async throws {
        try await exercise(replace: false)
    }

    private func exercise(replace: Bool) async throws {
        let v1 = try view(), v2 = try view(2)
        let supplier = ApplicationCaptureSupplier(v1), gate = RoutingTestGate()
        let events = ApplicationCaptureEvents()
        let searcher = SyntheticOptimalRouteSearcher(configuration: configuration, workLimit: 100_000,
            captureView: {
                let (ordinal, retained) = await supplier.read()
                if ordinal == 1 {
                    // Read is atomic before suspension. The nonthrowing supplier returns
                    // its retained value; the actual engine observes cancellation next.
                    do { try await gate.wait() } catch { #expect(error is CancellationError) }
                }
                return retained
            }, checkpoint: { await events.record($0) })
        let environment = AppEnvironment(configuration: try .forTesting(),
            clock: FixedAppClock(now: F.date(0)),
            logging: AppLogging(subsystem: "capture-integration-test", sink: RecordingLogSink()),
            routeSearching: searcher)
        guard case .ready(let owner) = environment.makeRouteSearchCoordinator() else { throw Failure.expectedResult }
        var joins: [@Sendable () async -> Void] = []
        let intent = RouteSearchIntent(origin: F.station("A"), destination: F.station("D"), departure: .at(F.date(100)))
        do {
            guard case .accepted(let a) = owner.submit(intent) else { throw Failure.expectedResult }
            joins.append(owner.completionCheckpointForTesting())
            await gate.waitUntilEntered()
            #expect(await supplier.capturedIDs == [v1.id])
            #expect(await events.stages == [.configuration])
            if replace {
                await supplier.replace(v2)
                // E2 replacement alone leaves A searching and its gate uncancelled.
                guard case .searching(let before) = owner.state else { throw Failure.expectedResult }
                #expect(before.id == a)
                #expect(await gate.cancellationObserved == false)
                guard case .accepted(let b) = owner.submit(intent) else { throw Failure.expectedResult }
                joins.append(owner.completionCheckpointForTesting())
                #expect(a != b)
                await joins[1]()
                await joins[0]()
                guard case .completed(let attempt, let result) = owner.state else { throw Failure.expectedResult }
                #expect(attempt.id == b && attempt.request.departNotBefore == F.date(100))
                try assertOutput(result, v2)
                #expect(await supplier.capturedIDs == [v1.id, v2.id])
            } else {
                #expect(owner.cancel(a))
                await joins[0]()
                guard case .cancelled(let attempt) = owner.state else { throw Failure.expectedResult }
                #expect(attempt.id == a)
                #expect(await supplier.capturedIDs == [v1.id])
                #expect(await events.stages == [.configuration])
            }
            #expect(await gate.cancellationObserved)
        } catch {
            owner.dispose()
            await gate.release()
            for join in joins { await join() }
            throw error
        }
        owner.dispose()
        await gate.release()
        for join in joins { await join() }
    }
}

private actor ApplicationCaptureSupplier {
    private var value: SyntheticInternalView
    private(set) var capturedIDs: [TimetableViewID] = []
    init(_ value: SyntheticInternalView) { self.value = value }
    func read() -> (Int, SyntheticInternalView) {
        capturedIDs.append(value.id)
        return (capturedIDs.count, value)
    }
    func replace(_ value: SyntheticInternalView) { self.value = value }
}
private actor ApplicationCaptureEvents {
    private(set) var stages: [SyntheticInternalStage] = []
    func record(_ stage: SyntheticInternalStage) { stages.append(stage) }
}
#endif
