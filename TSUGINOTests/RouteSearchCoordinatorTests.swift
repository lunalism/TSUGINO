#if DEBUG
import Foundation
import Synchronization
import Testing
@testable import TSUGINO

@MainActor
struct RouteSearchCoordinatorTests {
    private typealias F = InternalFixture
    private func intent(_ destination: String = "B", at: Date? = nil) -> RouteSearchIntent {
        .init(origin: F.station("A"), destination: F.station(destination), departure: at.map { .at($0) } ?? .now)
    }
    private func accepted(_ value: RouteSearchSubmission) throws -> RouteSearchAttemptID {
        guard case .accepted(let id) = value else { throw TestFailure.expected }; return id
    }
    private enum TestFailure: Error { case expected, raw }

    @Test(arguments: [0,1,2,3]) func replacementRejectsEveryObsoleteTerminal(_ oldOutcome: Int) async throws {
        let port = LifecyclePort(), clock = LifecycleClock(F.date(100))
        let owner = RouteSearchCoordinator(searcher: port, clock: clock)
        let old = try accepted(owner.submit(intent()))
        let oldDone = owner.completionCheckpointForTesting()
        await port.waitForCalls(1)
        clock.set(F.date(110))
        let current = try accepted(owner.submit(intent("C")))
        let currentDone = owner.completionCheckpointForTesting()
        #expect(old != current && !owner.cancel(old))
        await port.waitForCalls(2)
        await port.complete(1, .success(.noResults)); await currentDone()
        let outcome: Result<RouteSearchResult, any Error>
        switch oldOutcome {
        case 0: outcome = .success(.noResults)
        case 1: outcome = .failure(RouteSearchFailure.dataUnavailable)
        case 2: outcome = .failure(CancellationError())
        default: outcome = .failure(TestFailure.raw)
        }
        await port.complete(0, outcome); await oldDone()
        guard case .completed(let attempt, .noResults) = owner.state else { throw TestFailure.expected }
        #expect(attempt.id == current && attempt.request.destination == F.station("C"))
        #expect(attempt.request.departNotBefore == F.date(110) && clock.reads == 2)
    }

    @Test func replacementClearsCompletedAnswerAndIdenticalRequestsHaveNewIdentity() async throws {
        let port = LifecyclePort(), owner = RouteSearchCoordinator(searcher: port, clock: FixedAppClock(now: F.date(100)))
        let first = try accepted(owner.submit(intent()))
        let done = owner.completionCheckpointForTesting(); await port.waitForCalls(1)
        await port.complete(0, .success(.noResults)); await done()
        let second = try accepted(owner.submit(intent()))
        let secondDone = owner.completionCheckpointForTesting()
        guard case .searching(let attempt) = owner.state else { throw TestFailure.expected }
        #expect(first != second && attempt.id == second)
        let third = try accepted(owner.submit(intent())) // second worker has not started
        let thirdDone = owner.completionCheckpointForTesting()
        #expect(third != second)
        await secondDone(); await port.waitForCalls(2)
        #expect(await port.count == 2) // first and third only
        await port.complete(1, .success(.noResults)); await thirdDone()
        guard case .completed(let final, _) = owner.state else { throw TestFailure.expected }
        #expect(final.id == third)
    }

    @Test(arguments: [false,true]) func cancellationOrDisposalBlocksLateCompletion(_ dispose: Bool) async throws {
        let port = LifecyclePort(), clock = LifecycleClock(F.date(100))
        let owner = RouteSearchCoordinator(searcher: port, clock: clock)
        let id = try accepted(owner.submit(intent())); let done = owner.completionCheckpointForTesting()
        await port.waitForCalls(1)
        if dispose { owner.dispose(); owner.dispose() } else { #expect(owner.cancel(id)) }
        await port.complete(0, .success(.noResults)); await done()
        if dispose {
            guard case .disposed = owner.state, case .disposed = owner.submit(intent()), case .disposed = owner.retry(id) else { throw TestFailure.expected }
        } else {
            guard case .cancelled(let a) = owner.state, case .noMatchingFailure = owner.retry(id) else { throw TestFailure.expected }
            #expect(a.id == id && !owner.cancel(id))
        }
        #expect(clock.reads == 1)
        #expect(await port.count == 1)
    }

    @Test(arguments: [false,true]) func cancellationBeforeInvocationMakesZeroCalls(_ dispose: Bool) async throws {
        let port = LifecyclePort(), clock = LifecycleClock(F.date(100))
        let owner = RouteSearchCoordinator(searcher: port, clock: clock)
        let id = try accepted(owner.submit(intent())); let done = owner.completionCheckpointForTesting()
        if dispose { owner.dispose() } else { #expect(owner.cancel(id)) }
        await done()
        #expect(await port.count == 0)
        #expect(clock.reads == 1)
    }

    @Test(arguments: [false,true]) func retryMatchesFailureAndResolvesOriginalIntent(_ explicit: Bool) async throws {
        let port = LifecyclePort(), clock = LifecycleClock(F.date(100))
        let owner = RouteSearchCoordinator(searcher: port, clock: clock)
        let first = try accepted(owner.submit(intent(at: explicit ? F.date(50) : nil)))
        let done = owner.completionCheckpointForTesting(); await port.waitForCalls(1)
        await port.complete(0, .failure(RouteSearchFailure.dataUnavailable)); await done()
        clock.set(F.date(200))
        let second = try accepted(owner.retry(first)); let secondDone = owner.completionCheckpointForTesting()
        #expect(first != second)
        guard case .searching(let a) = owner.state, case .noMatchingFailure = owner.retry(first) else { throw TestFailure.expected }
        #expect(a.request.departNotBefore == F.date(explicit ? 50 : 200))
        #expect(clock.reads == (explicit ? 0 : 2))
        await port.waitForCalls(2)
        await port.complete(1, .failure(RouteSearchFailure.searchIncomplete)); await secondDone()
        guard case .noMatchingFailure = owner.retry(first) else { throw TestFailure.expected }
        #expect(clock.reads == (explicit ? 0 : 2))
    }

    @Test func invalidInputsAndInvalidRetryPreserveExistingState() async throws {
        let port = LifecyclePort(), clock = LifecycleClock(F.date(100))
        let owner = RouteSearchCoordinator(searcher: port, clock: clock)
        let id = try accepted(owner.submit(intent())); let done = owner.completionCheckpointForTesting()
        guard case .invalidRequest = owner.submit(intent("A")),
              case .invalidRequest = owner.submit(intent(at: Date(timeIntervalSinceReferenceDate: .infinity))) else { throw TestFailure.expected }
        #expect(clock.reads == 1)
        clock.set(Date(timeIntervalSinceReferenceDate: .nan))
        guard case .invalidRequest = owner.submit(intent("C")), case .searching(let a) = owner.state else { throw TestFailure.expected }
        #expect(a.id == id && clock.reads == 2)
        await port.waitForCalls(1)
        await port.complete(0, .failure(RouteSearchFailure.dataUnavailable)); await done()
        guard case .invalidRequest = owner.retry(id), case .failed(let failed, .dataUnavailable) = owner.state else { throw TestFailure.expected }
        #expect(failed.id == id && clock.reads == 3)
        #expect(await port.count == 1)
    }

    @Test(arguments: [0,1,2,3]) func canonicalResultsRetainScopeContextAndOmissions(_ mode: Int) async throws {
        let inventory = F.inventory()
        let slot = try #require(inventory.slots?.first)
        guard case .active(let facts, _) = slot.activation else { throw TestFailure.expected }
        let train = try #require(TrainCandidate(trip: inventory.trip, boardingIndex: 0, alightingIndex: 2))
        let context = try #require(TimetableRideContext(train: train, facts: facts))
        let rail = try #require(RouteRailProposal(travel: .matched(train), scheduledContext: .timetable(context)))
        let candidate = try #require(RouteCandidate(legs: [.rail(rail)]))
        let omission = try #require(RouteAlternativeOmission(alternativeIndex: 1, reasons: [.unknownMapping]))
        let batch = try #require(RouteSearchBatch(candidates: [candidate], omissions: [omission]))
        let scope = try #require(InternalSearchScope(profile: F.configuration().profile, request: F.request(), viewID: F.viewID))
        let outcome: RouteSearchResult
        switch mode {
        case 0: outcome = .noResults
        case 1: outcome = .internalSuccess(try #require(InternalSearchSuccess(scope: scope, outcome: .noResults)))
        case 2: outcome = .alternatives(batch)
        default: outcome = .internalSuccess(try #require(InternalSearchSuccess(scope: scope, outcome: .alternatives(batch))))
        }
        let port = LifecyclePort(), owner = RouteSearchCoordinator(searcher: port, clock: FixedAppClock(now: F.date(100)))
        let id = try accepted(owner.submit(intent("D"))); let done = owner.completionCheckpointForTesting()
        await port.waitForCalls(1); await port.complete(0, .success(outcome)); await done()
        guard case .completed(let a, let result) = owner.state else { throw TestFailure.expected }
        #expect(a.id == id)
        let actualBatch: RouteSearchBatch?
        switch (mode,result) {
        case (0,.noResults): actualBatch = nil
        case (1,.internalSuccess(let s)):
            #expect(s.scope.viewID == scope.viewID)
            guard case .noResults = s.outcome else { throw TestFailure.expected }; actualBatch = nil
        case (2,.alternatives(let b)): actualBatch = b
        case (3,.internalSuccess(let s)):
            #expect(s.scope.profile.identity == scope.profile.identity && s.scope.viewID == scope.viewID)
            #expect(s.scope.lowerBound == scope.lowerBound && s.scope.upperBound == scope.upperBound)
            guard case .alternatives(let b) = s.outcome else { throw TestFailure.expected }; actualBatch = b
        default: throw TestFailure.expected
        }
        if let b = actualBatch {
            #expect(b.candidates.count == 1 && b.omissions.count == 1)
            #expect(b.omissions[0].alternativeIndex == 1 && b.omissions[0].reasons == [.unknownMapping])
            guard case .rail(let r) = b.candidates[0].legs[0], case .matched(let t) = r.travel,
                  case .timetable(let c) = r.scheduledContext else { throw TestFailure.expected }
            #expect(c.binding.matches(facts.binding) && c.matches(t))
            #expect(c.boardingIndex == 0 && c.alightingIndex == 2)
            #expect(c.departure == context.departure && c.arrival == context.arrival)
            #expect(t.trip.stopSequence == inventory.trip.stopSequence && t.trip.lineSegments == inventory.trip.lineSegments)
        }
    }

    @Test(arguments: Array(0..<11)) func failuresRemainFailuresAndCancellationIsSeparate(_ mode: Int) async throws {
        let omission = try #require(RouteAlternativeOmission(alternativeIndex: 0, reasons: [.invalidStructure]))
        let failures: [RouteSearchFailure] = [.invalidEndpoint(.destination,.retired), .unsupportedRequest, .dataUnavailable,
            .providerUnavailable, .rateLimited, .configurationUnavailable, .malformedResponse,
            .noUsableAlternatives(try #require(RouteSearchRejections(omissions: [omission]))), .searchIncomplete]
        let error: any Error
        if mode < 9 { error = failures[mode] }
        else if mode == 9 { error = CancellationError() }
        else { error = TestFailure.raw }
        let port = LifecyclePort(), owner = RouteSearchCoordinator(searcher: port, clock: FixedAppClock(now: F.date(100)))
        let id = try accepted(owner.submit(intent())); let done = owner.completionCheckpointForTesting()
        await port.waitForCalls(1); await port.complete(0, .failure(error)); await done()
        switch (mode,owner.state) {
        case (0,.failed(let a,.invalidEndpoint(.destination,.retired))),
             (1,.failed(let a,.unsupportedRequest)), (2,.failed(let a,.dataUnavailable)),
             (3,.failed(let a,.providerUnavailable)), (4,.failed(let a,.rateLimited)),
             (5,.failed(let a,.configurationUnavailable)), (6,.failed(let a,.malformedResponse)),
             (8,.failed(let a,.searchIncomplete)), (9,.cancelled(let a)), (10,.contractViolation(let a)): #expect(a.id == id)
        case (7,.failed(let a,.noUsableAlternatives(let r))):
            #expect(a.id == id && r.omissions.count == 1)
            #expect(r.omissions[0].alternativeIndex == 0 && r.omissions[0].reasons == [.invalidStructure])
        default: throw TestFailure.expected
        }
    }

    @Test func foreignIDsAndOwnerReleaseCannotPublish() async throws {
        let port = LifecyclePort(), clock = FixedAppClock(now: F.date(100))
        var owner: RouteSearchCoordinator? = RouteSearchCoordinator(searcher: port, clock: clock)
        weak var weakOwner = owner
        let id = try accepted(owner!.submit(intent())); let done = owner!.completionCheckpointForTesting()
        await port.waitForCalls(1)
        let otherPort = LifecyclePort(), other = RouteSearchCoordinator(searcher: otherPort, clock: clock)
        let otherID = try accepted(other.submit(intent())); let otherDone = other.completionCheckpointForTesting()
        #expect(id != otherID && !other.cancel(id))
        guard case .noMatchingFailure = other.retry(id) else { throw TestFailure.expected }
        other.dispose(); await otherDone() // zero calls before invocation
        owner = nil
        #expect(weakOwner == nil) // worker does not keep owner alive across await
        await port.complete(0, .success(.noResults)); await done()
    }
}

/// Deliberately ignores task cancellation; completion is controlled without sleeps.
private actor LifecyclePort: RouteSearching {
    private var requests: [RouteSearchRequest] = []
    private var pending: [Int: CheckedContinuation<RouteSearchResult, any Error>] = [:]
    private var waiters: [(Int, CheckedContinuation<Void, Never>)] = []
    var count: Int { requests.count }
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        let index = requests.count
        requests.append(request)
        return try await withCheckedThrowingContinuation { continuation in
            pending[index] = continuation
            let ready = waiters.filter { $0.0 <= requests.count }
            waiters.removeAll { $0.0 <= requests.count }
            for (_, waiter) in ready { waiter.resume() }
        }
    }
    func waitForCalls(_ count: Int) async {
        if requests.count >= count { return }
        await withCheckedContinuation { waiters.append((count,$0)) }
    }
    func complete(_ index: Int, _ result: Result<RouteSearchResult, any Error>) {
        pending.removeValue(forKey: index)!.resume(with: result)
    }
}
private nonisolated final class LifecycleClock: AppClock {
    private struct Value { var date: Date; var reads = 0 }
    private let value: Mutex<Value>
    init(_ date: Date) { value = Mutex(Value(date: date)) }
    var now: Date { value.withLock { $0.reads += 1; return $0.date } }
    var reads: Int { value.withLock { $0.reads } }
    func set(_ date: Date) { value.withLock { $0.date = date } }
}
#endif
