#if DEBUG
import Foundation
import SwiftUI
import Synchronization
import Testing
@testable import TSUGINO

@MainActor
struct RouteSearchCompositionTests {
    private typealias F = InternalFixture
    private enum Failure: Error { case unexpected }

    private func environment(_ port: (any RouteSearching)?, _ clock: any AppClock) throws -> AppEnvironment {
        AppEnvironment(configuration: try .forTesting(), clock: clock,
                       logging: AppLogging(subsystem: "composition-test", sink: RecordingLogSink()),
                       routeSearching: port)
    }
    private func ready(_ environment: AppEnvironment) throws -> RouteSearchCoordinator {
        guard case .ready(let owner) = environment.makeRouteSearchCoordinator() else { throw Failure.unexpected }
        return owner
    }
    private func submit(_ owner: RouteSearchCoordinator, explicit: Date? = nil) throws -> RouteSearchAttemptID {
        let intent = RouteSearchIntent(origin: F.station("A"), destination: F.station("D"),
                                       departure: explicit.map { .at($0) } ?? .now)
        guard case .accepted(let id) = owner.submit(intent) else { throw Failure.unexpected }
        return id
    }

    @Test(arguments: [false, true])
    func constructionIsInertAndSubmissionUsesInjectedDependencies(_ explicit: Bool) async throws {
        let port = CompositionPort(), clock = CompositionClock(F.date(100))
        let env = try environment(port, clock)
        let owner = try ready(env)
        defer { owner.dispose() }
        guard case .idle = owner.state else { throw Failure.unexpected }
        #expect(clock.reads == 0)
        #expect(await port.count == 0)
        clock.set(F.date(200)) // proves the factory retained the dependency, not a captured Date
        let id = try submit(owner, explicit: explicit ? F.date(50) : nil)
        let done = owner.completionCheckpointForTesting()
        await port.waitForCalls(1)
        let request = await port.request(0)
        #expect(request.origin == F.station("A") && request.destination == F.station("D"))
        #expect(request.departNotBefore == F.date(explicit ? 50 : 200))
        #expect(clock.reads == (explicit ? 0 : 1))
        await port.complete(0, .success(.noResults)); await done()
        guard case .completed(let attempt, .noResults) = owner.state else { throw Failure.unexpected }
        #expect(attempt.id == id)
        #expect(await port.count == 1)
    }

    @Test func separateEnvironmentsDoNotUseAmbientDependencies() async throws {
        let portA = CompositionPort(), portB = CompositionPort()
        let clockA = CompositionClock(F.date(100)), clockB = CompositionClock(F.date(300))
        let a = try ready(environment(portA, clockA)), b = try ready(environment(portB, clockB))
        defer { a.dispose(); b.dispose() }
        _ = try submit(a); let doneA = a.completionCheckpointForTesting()
        _ = try submit(b); let doneB = b.completionCheckpointForTesting()
        await portA.waitForCalls(1); await portB.waitForCalls(1)
        #expect(await portA.request(0).departNotBefore == F.date(100))
        #expect(await portB.request(0).departNotBefore == F.date(300))
        #expect(clockA.reads == 1 && clockB.reads == 1)
        await portA.complete(0, .failure(RouteSearchFailure.dataUnavailable))
        await portB.complete(0, .success(.noResults))
        await doneA(); await doneB()
        guard case .failed(_, .dataUnavailable) = a.state,
              case .completed(_, .noResults) = b.state else { throw Failure.unexpected }
    }

    @Test func consumerDisposalIsIndependentAndEnvironmentDoesNotCacheOwners() async throws {
        let port = CompositionPort(), env = try environment(port, FixedAppClock(now: F.date(100)))
        let copiedEnvironment = env
        let a = try ready(env), b = try ready(copiedEnvironment)
        #expect(a !== b)
        let hostA = CompositionConsumer(owner: a), hostB = CompositionConsumer(owner: b)
        defer { hostA.end(); hostB.end() }
        let idA = try submit(a); let doneA = a.completionCheckpointForTesting()
        await port.waitForCalls(1)
        let idB = try submit(b); let doneB = b.completionCheckpointForTesting()
        await port.waitForCalls(2)
        #expect(idA != idB)
        hostA.end()
        #expect(hostA.owner == nil && hostB.owner === b)
        guard case .disposed = a.state, case .searching(let active) = b.state else { throw Failure.unexpected }
        #expect(active.id == idB)
        await port.complete(0, .success(.noResults)); await doneA() // fake deliberately ignores cancellation
        guard case .disposed = a.state, case .searching = b.state else { throw Failure.unexpected }
        await port.complete(1, .success(.noResults)); await doneB()
        guard case .completed(let completed, .noResults) = b.state else { throw Failure.unexpected }
        #expect(completed.id == idB)
        let fresh = try ready(env)
        defer { fresh.dispose() }
        #expect(fresh !== a && fresh !== b)
        guard case .idle = fresh.state else { throw Failure.unexpected }
    }

    @Test(arguments: [false, true]) func configuredHandoffPreservesCanonicalPayload(_ failure: Bool) async throws {
        let inventory = F.inventory()
        let slot = try #require(inventory.slots?.first)
        guard case .active(let facts, _) = slot.activation else { throw Failure.unexpected }
        let train = try #require(TrainCandidate(trip: inventory.trip, boardingIndex: 0, alightingIndex: 2))
        let context = try #require(TimetableRideContext(train: train, facts: facts))
        let rail = try #require(RouteRailProposal(travel: .matched(train), scheduledContext: .timetable(context)))
        let candidate = try #require(RouteCandidate(legs: [.rail(rail)]))
        let omission = try #require(RouteAlternativeOmission(alternativeIndex: 1, reasons: [.unknownMapping]))
        let batch = try #require(RouteSearchBatch(candidates: [candidate], omissions: [omission]))
        let scope = try #require(InternalSearchScope(profile: F.configuration().profile, request: F.request(), viewID: F.viewID))
        let result = try #require(InternalSearchSuccess(scope: scope, outcome: .alternatives(batch)))
        let port = CompositionPort(), owner = try ready(environment(port, FixedAppClock(now: F.date(100))))
        defer { owner.dispose() }
        _ = try submit(owner); let done = owner.completionCheckpointForTesting()
        await port.waitForCalls(1)
        if failure { await port.complete(0, .failure(RouteSearchFailure.searchIncomplete)) }
        else { await port.complete(0, .success(.internalSuccess(result))) }
        await done()
        if failure {
            guard case .failed(_, .searchIncomplete) = owner.state else { throw Failure.unexpected }
        } else {
            guard case .completed(_, .internalSuccess(let actual)) = owner.state,
                  case .alternatives(let actualBatch) = actual.outcome,
                  case .rail(let actualRail) = actualBatch.candidates[0].legs[0],
                  case .matched(let actualTrain) = actualRail.travel,
                  case .timetable(let actualContext) = actualRail.scheduledContext else { throw Failure.unexpected }
            #expect(actual.scope.viewID == scope.viewID && actual.scope.profile.identity == scope.profile.identity)
            #expect(actual.scope.lowerBound == scope.lowerBound && actual.scope.upperBound == scope.upperBound)
            #expect(actualBatch.candidates.count == 1 && actualBatch.omissions.count == 1)
            #expect(actualBatch.omissions[0].alternativeIndex == 1 && actualBatch.omissions[0].reasons == [.unknownMapping])
            #expect(actualTrain.trip.stopSequence == train.trip.stopSequence && actualTrain.trip.lineSegments == train.trip.lineSegments)
            #expect(actualContext.binding.matches(facts.binding) && actualContext.matches(train))
            #expect(actualContext.boardingIndex == 0 && actualContext.alightingIndex == 2)
            #expect(actualContext.departure == context.departure && actualContext.arrival == context.arrival)
        }
    }

    @Test(arguments: [0, 1, 2, 3]) func absentAndLiveDefaultsStayUnconfigured(_ mode: Int) throws {
        let clock = CompositionClock(F.date(100))
        let env: AppEnvironment
        switch mode {
        case 0: env = try environment(nil, clock)
        case 1: env = AppEnvironment(configuration: try .forTesting(), clock: clock,
                                     logging: AppLogging(subsystem: "test", sink: RecordingLogSink()))
        case 2: env = .live()
        default: env = EnvironmentValues().appEnvironment
        }
        guard case .notConfigured = env.makeRouteSearchCoordinator() else { throw Failure.unexpected }
        #expect(clock.reads == 0)
    }
}

/// The future lifetime host receives only the owner, not AppEnvironment.
@MainActor
private final class CompositionConsumer {
    private(set) var owner: RouteSearchCoordinator?
    init(owner: RouteSearchCoordinator) { self.owner = owner }
    func end() { owner?.dispose(); owner = nil }
}

private actor CompositionPort: RouteSearching {
    private var requests: [RouteSearchRequest] = []
    private var pending: [Int: CheckedContinuation<RouteSearchResult, any Error>] = [:]
    private var waiters: [(Int, CheckedContinuation<Void, Never>)] = []
    var count: Int { requests.count }
    func request(_ index: Int) -> RouteSearchRequest { requests[index] }
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
        await withCheckedContinuation { waiters.append((count, $0)) }
    }
    func complete(_ index: Int, _ result: Result<RouteSearchResult, any Error>) {
        pending.removeValue(forKey: index)!.resume(with: result)
    }
}
private nonisolated final class CompositionClock: AppClock {
    private struct Value { var date: Date; var reads = 0 }
    private let value: Mutex<Value>
    init(_ date: Date) { value = Mutex(Value(date: date)) }
    var now: Date { value.withLock { $0.reads += 1; return $0.date } }
    var reads: Int { value.withLock { $0.reads } }
    func set(_ date: Date) { value.withLock { $0.date = date } }
}
#endif
