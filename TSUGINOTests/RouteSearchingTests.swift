#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct RouteSearchingTests {
    private typealias F = RoutingFixture

    @Test func rawFailuresAreContainedAndUnsupportedIntentIsExplicit() async throws {
        // R23/R25/R35; no raw client messages escape or become noResults.
        let errors: [any Error & Sendable] = [SyntheticRouteClientFailure.unavailable,
            SyntheticRouteClientFailure.rateLimited, SyntheticRouteClientFailure.configuration,
            SyntheticRouteClientFailure.malformed, SyntheticRouteClientFailure.unsupportedIntent,
            F.FixtureError.rawClientError]
        for (index, error) in errors.enumerated() {
            let searcher: any RouteSearching = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, _ in throw error })
            do { _ = try await searcher.search(F.request()); Issue.record("Expected typed failure") }
            catch let failure as RouteSearchFailure {
                switch (index, failure) {
                case (0, .providerUnavailable), (1, .rateLimited), (2, .configurationUnavailable),
                     (3, .malformedResponse), (4, .unsupportedRequest), (5, .providerUnavailable): break
                default: Issue.record("Incorrect failure category")
                }
            }
        }
    }

    @Test func unavailableOrMixedViewsFailAsWholeCalls() async throws {
        // R33/R34 Data-view boundary. A broken view is not a salvaged partial batch.
        for view in [F.view(usable: false), F.view(id: ""), F.view(tripViewID: "different-revision")] {
            let counter = RoutingCallCounter()
            let searcher = SyntheticRouteSearcher(loadView: { view }, fetch: { _, id in
                await counter.increment()
                return SyntheticRouteEnvelope(viewID: id, alternatives: [F.alternative()], explicitlyNoResults: false)
            })
            do { _ = try await searcher.search(F.request()); Issue.record("Expected data unavailable") }
            catch RouteSearchFailure.dataUnavailable {}
            #expect(await counter.count == 0)
        }
        let mismatched = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, _ in
            SyntheticRouteEnvelope(viewID: "changed", alternatives: [F.alternative()], explicitlyNoResults: false)
        })
        do { _ = try await mismatched.search(F.request()); Issue.record("Expected view mismatch") }
        catch RouteSearchFailure.dataUnavailable {}
        let raw = SyntheticRouteSearcher(loadView: { throw F.FixtureError.rawClientError }, fetch: { _, id in
            Issue.record("Client reached after view failure")
            return SyntheticRouteEnvelope(viewID: id, alternatives: [], explicitlyNoResults: true)
        })
        do { _ = try await raw.search(F.request()); Issue.record("Expected data unavailable") }
        catch RouteSearchFailure.dataUnavailable {}
    }

    @Test func cancellationBeforeWorkPreventsViewAndClientAccess() async throws {
        let count = RoutingCallCounter()
        let searcher = SyntheticRouteSearcher(loadView: { await count.increment(); return F.view() }, fetch: { _, id in
            await count.increment()
            return SyntheticRouteEnvelope(viewID: id, alternatives: [], explicitlyNoResults: true)
        })
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await searcher.search(F.request())
        }
        do { _ = try await task.value; Issue.record("Cancellation became result") }
        catch is CancellationError {}
        #expect(await count.count == 0)
    }

    @Test func cancellationDuringClientSuspensionPropagatesToOwnedWork() async throws {
        // R24: inherited task cancellation reaches the cancellation-aware fake client.
        let gate = RoutingTestGate()
        let searcher = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, id in
            try await gate.wait()
            return SyntheticRouteEnvelope(viewID: id, alternatives: [F.alternative()], explicitlyNoResults: false)
        })
        let task = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        task.cancel()
        do { _ = try await task.value; Issue.record("Cancellation became result") }
        catch is CancellationError {}
        #expect(await gate.cancellationObserved)
    }

    @Test func cancellationAtNormalizationCheckpointReturnsNoPartialBatch() async throws {
        // R24 after a usable alternative already exists locally.
        let gate = RoutingTestGate()
        let searcher = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, id in
            SyntheticRouteEnvelope(viewID: id, alternatives: [F.alternative(), F.alternative(wellFormed: false)], explicitlyNoResults: false)
        }, checkpoint: { try await gate.wait() })
        let task = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        task.cancel()
        do { _ = try await task.value; Issue.record("Returned partial result") }
        catch is CancellationError {}
    }

    @Test func cancellationAtFinalCheckpointStillReturnsNoResult() async throws {
        let gate = RoutingTestGate()
        let searcher = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, id in
            SyntheticRouteEnvelope(viewID: id, alternatives: [F.alternative()], explicitlyNoResults: false)
        }, checkpoint: { try await gate.wait() })
        let task = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        task.cancel()
        do { _ = try await task.value; Issue.record("Returned final batch after cancellation") }
        catch is CancellationError {}
    }

    @Test func cancellationTakesPrecedenceOverRawFailure() async throws {
        let searcher = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, _ in
            withUnsafeCurrentTask { $0?.cancel() }
            throw F.FixtureError.rawClientError
        })
        let task = Task { try await searcher.search(F.request()) }
        do { _ = try await task.value; Issue.record("Returned result") }
        catch is CancellationError {}
        // Explicit client cancellation is likewise not an outage.
        let explicit = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, _ in throw CancellationError() })
        do { _ = try await explicit.search(F.request()); Issue.record("Returned result") }
        catch is CancellationError {}
    }

    @Test func concurrentCallsRetainTheirViewsAndIndependentResults() async throws {
        // R34 Data half + R33 same-ID revisions in SEPARATE calls. No UI supersession.
        let firstTrip = F.trip(stops: ["A", "B", "D"])
        let secondTrip = F.trip(stops: ["A", "C", "E"], partial: true)
        let store = RoutingViewStore(F.view(id: "one", trip: firstTrip))
        let firstGate = RoutingTestGate()
        let secondGate = RoutingTestGate()
        let searcher = SyntheticRouteSearcher(loadView: { await store.get() }, fetch: { request, id in
            if request.destination == F.station("D") { try await firstGate.wait() }
            else { try await secondGate.wait() }
            let destination = request.destination == F.station("D") ? "D" : "E"
            let input = F.alternative([F.ride("A", destination, reference: "run", board: "visit-0", alight: "visit-2")])
            return SyntheticRouteEnvelope(viewID: id, alternatives: [input], explicitlyNoResults: false)
        })
        let first = Task { try await searcher.search(F.request()) }
        await firstGate.waitUntilEntered()
        await store.set(F.view(id: "two", trip: secondTrip))
        let second = Task { try await searcher.search(F.request("A", "E")) }
        await secondGate.waitUntilEntered()
        await secondGate.release()
        let secondBatch = try F.batch(await second.value)
        await firstGate.release()
        let firstBatch = try F.batch(await first.value)
        for (batch, original) in [(firstBatch, firstTrip), (secondBatch, secondTrip)] {
            guard case .matched(let train) = try F.rail(batch.candidates[0]).travel else { Issue.record("Missing snapshot"); continue }
            #expect(train.trip.id == original.id)
            #expect(train.trip.stopSequence == original.stopSequence)
            #expect(train.trip.lineSegments == original.lineSegments)
            #expect(train.trip.coverage == original.coverage)
            #expect(train.trip.serviceTypeSegments == original.serviceTypeSegments)
        }
        #expect(firstBatch.candidates[0].destination == F.station("D"))
        #expect(secondBatch.candidates[0].destination == F.station("E"))
    }
    @Test func cancellationWhileLoadingViewNeverReachesClient() async throws {
        let gate = RoutingTestGate()
        let count = RoutingCallCounter()
        let searcher = SyntheticRouteSearcher(loadView: { try await gate.wait(); return F.view() }, fetch: { _, id in
            await count.increment()
            return SyntheticRouteEnvelope(viewID: id, alternatives: [], explicitlyNoResults: true)
        })
        let task = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        task.cancel()
        do { _ = try await task.value; Issue.record("Returned result after cancellation") }
        catch is CancellationError {}
        #expect(await count.count == 0)
    }

    @Test func cancellingOneConcurrentCallDoesNotCancelTheOther() async throws {
        let cancelledGate = RoutingTestGate()
        let survivingGate = RoutingTestGate()
        let searcher = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { request, id in
            if request.destination == F.station("D") { try await cancelledGate.wait() }
            else { try await survivingGate.wait() }
            return SyntheticRouteEnvelope(viewID: id, alternatives: [], explicitlyNoResults: true)
        })
        let cancelled = Task { try await searcher.search(F.request()) }
        let surviving = Task { try await searcher.search(F.request("A", "E")) }
        await cancelledGate.waitUntilEntered()
        await survivingGate.waitUntilEntered()
        cancelled.cancel()
        do { _ = try await cancelled.value; Issue.record("Returned cancelled result") }
        catch is CancellationError {}
        await survivingGate.release()
        if case .noResults = try await surviving.value {} else { Issue.record("Expected surviving result") }
        #expect(await survivingGate.cancellationObserved == false)
    }

}

#endif
