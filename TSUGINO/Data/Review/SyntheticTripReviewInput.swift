#if DEBUG
import Foundation

/// Stipulated invented evidence only. No source parser, authentication or registry authority.
nonisolated struct SyntheticTripReviewView: Hashable, Sendable {
    let sourceRevision: UUID
    let mappingRevision: UUID
    let profileRevision: UUID
    let reviewRevision: UUID
}
nonisolated enum SyntheticTripStationMapping: Sendable {
    case resolved(StationID, membership: Set<LineID>, evidence: UUID?)
    case unavailable
    case impossible
}
nonisolated enum SyntheticTripClassification: Sendable {
    case passenger(SyntheticTripStationMapping, evidence: UUID?)
    case passed(evidence: UUID?)
    case unknown
}
nonisolated struct SyntheticTripPosition: Sendable {
    /// Stable invented within-artifact locator, not a station or cross-revision identity.
    let reference: UUID
    let order: Int?
    let classification: SyntheticTripClassification
}
nonisolated enum SyntheticTripIdentity: Sendable {
    case reviewed(TripID, evidence: UUID?)
    case unresolved
    case impossible
    case awaitingRegistration
}
nonisolated enum SyntheticTripBoundary: Sendable {
    case reached(evidence: UUID?)
    case continued(evidence: UUID?)
    case unknownExtent
}
nonisolated enum SyntheticTripLineMapping: Sendable {
    case resolved(LineID, evidence: UUID?)
    case unavailable
    case impossible
}
nonisolated struct SyntheticTripMovement: Sendable {
    let from: UUID
    let to: UUID
    let line: SyntheticTripLineMapping
}
nonisolated struct SyntheticTripReviewRun: Sendable {
    let reference: UUID
    let view: SyntheticTripReviewView
    let positions: [SyntheticTripPosition]
    /// Explicit proposed passenger-boundary occurrences, selected before validation.
    let first: UUID
    let last: UUID
    let intervalEvidence: UUID?
    let identity: SyntheticTripIdentity
    let continuityEvidence: UUID?
    let origin: SyntheticTripBoundary
    let destination: SyntheticTripBoundary
    /// Ordered source-occurrence spans, including any passed line-boundary position.
    let movements: [SyntheticTripMovement]
    let prior: SyntheticTripReviewCandidate?
}
nonisolated struct SyntheticTripReviewPacket: Sendable {
    let view: SyntheticTripReviewView
    /// Invented evidence references resolvable within this packet. Presence is not authentication.
    let evidenceReferences: Set<UUID>
    let runs: [SyntheticTripReviewRun]
}

nonisolated enum SyntheticTripReviewReason: Int, CaseIterable, Sendable {
    case invalidPacket, orderConflict, unknownClassification, classificationConflict
    case mappingUnavailable, identityUnresolved, identityConflict, revisionMismatch
    case coverageEvidenceMissing, representationConflict, invalidStructure, registrationRequired
}
nonisolated struct SyntheticTripReviewDiagnostic: Sendable {
    let reason: SyntheticTripReviewReason
    /// Data-only invented locators. No raw strings, messages, source values or private paths.
    let locations: [UUID]
}
nonisolated enum SyntheticTripReviewOutcome: Sendable {
    case candidate(SyntheticTripReviewCandidate)
    case held([SyntheticTripReviewDiagnostic])
    case rejected([SyntheticTripReviewDiagnostic])
}
nonisolated struct SyntheticTripReviewRecord: Sendable {
    let reference: UUID
    let outcome: SyntheticTripReviewOutcome
}
nonisolated enum SyntheticTripReviewResult: Sendable {
    case invalidPacket
    case reviewed([SyntheticTripReviewRecord])
}
#endif
