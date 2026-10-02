/// Declaration order is the canonical, privacy-safe diagnostic order (DEC-076 B).
nonisolated enum RouteAlternativeRejectionReason: Int, CaseIterable, Sendable {
    case malformedAlternative
    case endpointMismatch
    case unknownMapping
    case retiredMapping
    case conflictingMapping
    case unsupportedPortion
    case insufficientContinuity
    case unverifiedTransfer
    case invalidStructure
    case inconsistentTrainEvidence
    case invalidScheduledContext
}

nonisolated struct RouteAlternativeOmission: Sendable {
    let alternativeIndex: Int
    let reasons: [RouteAlternativeRejectionReason]

    init?(alternativeIndex: Int, reasons: [RouteAlternativeRejectionReason]) {
        guard alternativeIndex >= 0, !reasons.isEmpty,
              !zip(reasons, reasons.dropFirst()).contains(where: { $0.rawValue >= $1.rawValue })
        else { return nil }
        self.alternativeIndex = alternativeIndex
        self.reasons = reasons
    }
}

nonisolated struct RouteSearchBatch: Sendable {
    let candidates: [RouteCandidate]
    let omissions: [RouteAlternativeOmission]

    init?(candidates: [RouteCandidate], omissions: [RouteAlternativeOmission]) {
        let (count, overflow) = candidates.count.addingReportingOverflow(omissions.count)
        guard !candidates.isEmpty, !overflow,
              omissions.allSatisfy({ $0.alternativeIndex < count }),
              !zip(omissions, omissions.dropFirst()).contains(where: {
                  $0.alternativeIndex >= $1.alternativeIndex
              }) else { return nil }
        self.candidates = candidates
        self.omissions = omissions
    }
}

/// A validated all-omitted payload: raw enum arrays cannot bypass these rules.
nonisolated struct RouteSearchRejections: Sendable {
    let omissions: [RouteAlternativeOmission]

    init?(omissions: [RouteAlternativeOmission]) {
        guard !omissions.isEmpty,
              omissions.enumerated().allSatisfy({ $0.offset == $0.element.alternativeIndex })
        else { return nil }
        self.omissions = omissions
    }
}

nonisolated enum RouteSearchResult: Sendable {
    case noResults
    case alternatives(RouteSearchBatch)
    case internalSuccess(InternalSearchSuccess)
}

nonisolated enum RouteSearchEndpointRole: Sendable {
    case origin
    case destination
}

nonisolated enum RouteSearchEndpointFailureReason: Sendable {
    case unknown
    case retired
    case conflicting
    case unsupported
}

/// Typed vocabulary only. No async behavior, retries, admission or cancellation
/// implementation is introduced by these values. Never carries provider text.
nonisolated enum RouteSearchFailure: Error, Sendable {
    case invalidEndpoint(RouteSearchEndpointRole, RouteSearchEndpointFailureReason)
    case unsupportedRequest
    case dataUnavailable
    case providerUnavailable
    case rateLimited
    case configurationUnavailable
    case malformedResponse
    case noUsableAlternatives(RouteSearchRejections)
}
