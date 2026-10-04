import Foundation

nonisolated struct RouteSearchIntent: Sendable {
    enum Departure: Sendable { case now, at(Date) }
    let origin: StationID
    let destination: StationID
    let departure: Departure
}

/// Invocation identity, not request equality or a persisted entity identifier.
nonisolated struct RouteSearchAttemptID: Equatable, Sendable {
    private final class Token: Sendable {}
    private let token: Token
    fileprivate init() { token = Token() }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.token === rhs.token }
}

nonisolated struct RouteSearchAttempt: Sendable {
    let id: RouteSearchAttemptID
    let intent: RouteSearchIntent
    let request: RouteSearchRequest
}
nonisolated enum RouteSearchSubmission: Sendable {
    case accepted(RouteSearchAttemptID)
    case invalidRequest, disposed, noMatchingFailure
}
nonisolated enum RouteSearchLifecycleState: Sendable {
    case idle
    case searching(RouteSearchAttempt)
    case completed(RouteSearchAttempt, RouteSearchResult)
    case failed(RouteSearchAttempt, RouteSearchFailure)
    case cancelled(RouteSearchAttempt)
    case contractViolation(RouteSearchAttempt)
    case disposed
}

/// DEC-087: owns only one consumer's current request/result, never recent history.
/// No production provider choice, ranking, admission, cache or Journey mutation.
@MainActor
final class RouteSearchCoordinator {
    private let searcher: any RouteSearching
    private let clock: any AppClock
    private var task: Task<Void, Never>?
    private(set) var state: RouteSearchLifecycleState = .idle

    init(searcher: any RouteSearching, clock: any AppClock) {
        self.searcher = searcher; self.clock = clock
    }
    deinit { task?.cancel() }

    @discardableResult
    func submit(_ intent: RouteSearchIntent) -> RouteSearchSubmission {
        if case .disposed = state { return .disposed }
        guard intent.origin != intent.destination else { return .invalidRequest }
        let instant: Date
        switch intent.departure {
        case .now: instant = clock.now
        case .at(let explicit): instant = explicit
        }
        guard let request = RouteSearchRequest(origin: intent.origin, destination: intent.destination,
                                              departNotBefore: instant) else { return .invalidRequest }
        let attempt = RouteSearchAttempt(id: .init(), intent: intent, request: request)
        // One non-suspending transaction. Replacing state revokes old publication
        // authority before any cancelled worker can resume on this actor.
        let oldTask = task
        state = .searching(attempt)
        oldTask?.cancel()
        task = Task { [weak self, searcher, attempt] in
            let outcome: Completion
            do {
                try Task.checkCancellation()
                outcome = .success(try await searcher.search(attempt.request))
            } catch is CancellationError { outcome = .cancelled }
            catch let failure as RouteSearchFailure { outcome = .failure(failure) }
            catch { outcome = .contractViolation }
            // Do not unwrap/retain self across the port await. Every terminal path
            // uses this guard, even for ports deliberately ignoring cancellation.
            self?.finish(attempt.id, outcome)
        }
        return .accepted(attempt.id)
    }

    @discardableResult
    func retry(_ expectedID: RouteSearchAttemptID) -> RouteSearchSubmission {
        if case .disposed = state { return .disposed }
        guard case .failed(let attempt, _) = state, attempt.id == expectedID else { return .noMatchingFailure }
        return submit(attempt.intent)
    }

    @discardableResult
    func cancel(_ expectedID: RouteSearchAttemptID) -> Bool {
        guard case .searching(let attempt) = state, attempt.id == expectedID else { return false }
        state = .cancelled(attempt)
        task?.cancel(); task = nil
        return true
    }

    func dispose() {
        state = .disposed
        task?.cancel(); task = nil
    }

    private enum Completion {
        case success(RouteSearchResult), failure(RouteSearchFailure), cancelled, contractViolation
    }
    private func finish(_ id: RouteSearchAttemptID, _ completion: Completion) {
        guard case .searching(let current) = state, current.id == id else { return }
        task = nil
        switch completion {
        case .success(let result): state = .completed(current, result)
        case .failure(let failure): state = .failed(current, failure)
        case .cancelled: state = .cancelled(current)
        case .contractViolation: state = .contractViolation(current)
        }
    }

    #if DEBUG
    /// Read-only test barrier for the captured worker (including obsolete work).
    /// Exposes neither its cancellation handle nor a state-mutation callback.
    func completionCheckpointForTesting() -> @Sendable () async -> Void {
        let captured = task
        return { await captured?.value }
    }
    #endif
}
