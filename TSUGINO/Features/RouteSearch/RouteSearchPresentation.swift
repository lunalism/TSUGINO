/// Supplied by the lifetime host, never looked up or observed by the mapper.
nonisolated enum RouteSearchPresentationSource: Sendable {
    case notConfigured
    case current(RouteSearchLifecycleState)
}

/// Descriptors only: the host must invoke the existing guarded coordinator API.
nonisolated enum RouteSearchPresentationAction: Equatable, Sendable {
    case search, edit
    case retry(RouteSearchAttemptID)
    case cancel(RouteSearchAttemptID)

    var copy: RouteSearchCopy {
        switch self {
        case .search: .search
        case .edit: .edit
        case .retry: .retry
        case .cancel: .cancel
        }
    }
}

/// Immutable projection. `source` retains the entire original canonical evidence.
/// Only status/feedback/action copy is user-facing. No source/debug stringification.
nonisolated struct RouteSearchPresentation: Sendable {
    let source: RouteSearchPresentationSource
    let status: RouteSearchCopy?
    let actions: [RouteSearchPresentationAction]
    let feedback: RouteSearchCopy?

    /// Original candidate order, with no selection, relabeling or dropped alternatives.
    var alternatives: [RouteCandidate] {
        guard case .current(.completed(_, let result)) = source else { return [] }
        switch result {
        case .alternatives(let batch): return batch.candidates
        case .internalSuccess(let success):
            if case .alternatives(let batch) = success.outcome { return batch.candidates }
            return []
        case .noResults: return []
        }
    }

    static func map(_ source: RouteSearchPresentationSource,
                    feedback: RouteSearchDraftFeedback? = nil) -> Self {
        let status: RouteSearchCopy?
        let actions: [RouteSearchPresentationAction]
        var canShowDraftFeedback = true
        switch source {
        case .notConfigured:
            status = .notConfigured; actions = []; canShowDraftFeedback = false
        case .current(let state):
            switch state {
            case .idle: status = .idle; actions = [.search, .edit]
            case .searching(let attempt): status = .searching; actions = [.cancel(attempt.id), .edit, .search]
            case .completed(_, let result):
                switch result {
                case .noResults: status = .noResults
                case .alternatives: status = .alternatives
                case .internalSuccess(let success):
                    switch success.outcome {
                    case .noResults: status = .noResults
                    case .alternatives: status = .alternatives
                    }
                }
                actions = [.edit, .search]
            case .failed(let attempt, let failure):
                switch failure {
                case .invalidEndpoint: status = .invalidEndpoint
                case .unsupportedRequest: status = .unsupportedRequest
                case .dataUnavailable: status = .dataUnavailable
                case .providerUnavailable: status = .providerUnavailable
                case .rateLimited: status = .rateLimited
                case .configurationUnavailable: status = .configurationUnavailable
                case .malformedResponse: status = .malformedResponse
                case .noUsableAlternatives: status = .noUsableAlternatives
                case .searchIncomplete: status = .searchIncomplete
                }
                actions = [.retry(attempt.id), .edit, .search]
            case .cancelled: status = .cancelled; actions = [.edit, .search]
            case .contractViolation: status = .contractViolation; actions = [.edit, .search]
            case .disposed: status = nil; actions = []; canShowDraftFeedback = false
            }
        }
        return Self(source: source, status: status, actions: actions,
                    feedback: canShowDraftFeedback && feedback?.hasRejection == true ? .invalidRequest : nil)
    }
}

/// Draft identity is separate from search invocation identity and contains no inputs.
nonisolated struct RouteSearchDraftID: Equatable, Sendable {
    private final class Token: Sendable {}
    private let token = Token()
    fileprivate init() {}
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.token === rhs.token }
}

/// P1 supplementary bookkeeping only. The host reports synchronous submission results
/// against its current draft ID and remaps current coordinator state after every action.
/// No task, coordinator, clock, draft content, history or persistence is owned here.
nonisolated struct RouteSearchDraftFeedback: Sendable {
    private(set) var draftID = RouteSearchDraftID()
    private(set) var hasRejection = false

    mutating func draftEdited() {
        draftID = RouteSearchDraftID()
        hasRejection = false
    }

    mutating func recordSubmission(_ outcome: RouteSearchSubmission, for draft: RouteSearchDraftID) {
        guard draft == draftID else { return } // delayed feedback cannot label a different draft
        switch outcome {
        case .invalidRequest: hasRejection = true
        case .accepted, .disposed: hasRejection = false
        case .noMatchingFailure: break // stale retry adds no notice; remap the current owner
        }
    }
    // A false stale cancel likewise needs no mutation: remap the owner's current state.
}
