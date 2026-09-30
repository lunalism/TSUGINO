import Foundation

// DEC-071's editorial exception: not a ProviderNamespace and never an ID
// resolver. Exact source references target existing stations only.
nonisolated struct EditorialStationKey: Codable, Hashable, Sendable {
    let sourceID: ExactValue
    let stationReference: ExactValue
}
nonisolated struct EditorialTitle: Codable, Hashable, Sendable {
    let language: ExactValue
    let value: ExactValue
}
nonisolated struct TitleOccurrence: Codable, Hashable, Sendable {
    let source: EditorialStationKey
    let railwayID: ExactValue
    let sameAs: ExactValue
    let lineID: MintedIdentifier
    let operatorID: MintedIdentifier
    let logicalIndex: Int
    let titles: [EditorialTitle]
    let sighting: NameSighting
    struct Semantic: Codable, Hashable {
        let source: EditorialStationKey
        let railwayID: ExactValue
        let sameAs: ExactValue
        let lineID: MintedIdentifier
        let operatorID: MintedIdentifier
        let logicalIndex: Int
        let titles: [EditorialTitle]
    }
    var semantic: Semantic { .init(source: source, railwayID: railwayID, sameAs: sameAs, lineID: lineID,
        operatorID: operatorID, logicalIndex: logicalIndex, titles: titles) }
}
nonisolated struct TitleTarget: Codable, Hashable, Sendable {
    struct Scope: Codable, Hashable, Sendable {
        let lineID: MintedIdentifier
        let neighbours: [MintedIdentifier]
    }
    let stationID: MintedIdentifier
    let members: [NameMember]
    let neighbours: [MintedIdentifier]
    let lineScopes: [Scope]
}
/// An owner's review of a retained authoritative document, not an inference
/// from names. The command verifies document bytes before using assertions.
nonisolated struct TitleCrosswalk: Codable, Hashable, Sendable {
    let id: ExactValue
    let source: EditorialStationKey
    let gtfsSourceID: ExactValue
    let stopID: ExactValue
    let documentID: ExactValue
    let documentSHA256: String
    let citation: ExactValue
    let reviewer: ExactValue
    let reason: ExactValue
}
nonisolated struct TitleEvidence: Codable, Equatable, Sendable {
    let source: EditorialStationKey
    let occurrences: [TitleOccurrence]
    let candidates: [TitleTarget]
    let crosswalks: [TitleCrosswalk]
    let inputSHA256: [String]
    let registrySHA256: String
    var memberProvenance: [NameSighting] = []
    var networkEvidenceSHA256: [String] = []
    var semanticSHA256: String {
        struct Semantic: Encodable {
            let source: EditorialStationKey
            let occurrences: [TitleOccurrence.Semantic]
            let candidates: [TitleTarget]
            let crosswalks: [TitleCrosswalk]
        }
        return NameDigest.of(Semantic(source: source, occurrences: occurrences.map(\.semantic), candidates: candidates, crosswalks: crosswalks))
    }
}
nonisolated struct TitleBindingReview: Codable, Equatable, Sendable {
    enum Basis: String, Codable, Sendable { case authoritativeCrosswalk, anchoredNeighbours }
    var schemaVersion: Int = 1
    let reviewID: ExactValue
    let reviewer: ExactValue
    let date: ExactValue
    let supersedes: ExactValue?
    let stationID: MintedIdentifier
    let reason: ExactValue
    let basis: Basis
    /// Direct reviews have no anchors. Anchored reviews need two distinct,
    /// already-validated DIRECT source bindings, never a circular chain.
    let anchors: [EditorialStationKey]
    let anchorReviewDigests: [String]
    let evidence: TitleEvidence
    let selectionEvidenceSHA256: String
    let reviewEvidenceSHA256: String
    func semanticDigest(_ current: TitleEvidence) -> String {
        struct Value: Encodable {
            let evidence: String
            let stationID: MintedIdentifier
            let reason: ExactValue
            let basis: Basis
            let anchors: [EditorialStationKey]
            let anchorReviewDigests: [String]
        }
        return NameDigest.of(Value(evidence: current.semanticSHA256, stationID: stationID, reason: reason, basis: basis, anchors: anchors, anchorReviewDigests: anchorReviewDigests))
    }
    func validateRecord() throws {
        guard schemaVersion == 1 else { throw NameReviewError.schema }
        guard stationID.kind == .station, MappingText.isToken(reviewID.text), MappingText.isToken(date.text),
              supersedes != reviewID, selectionEvidenceSHA256 == semanticDigest(evidence),
              reviewEvidenceSHA256 == NameDigest.of(evidence), !evidence.occurrences.isEmpty,
              Set(evidence.occurrences.map { NameDigest.of($0.semantic) }).count == evidence.occurrences.count,
              Set(anchors).count == anchors.count else { throw NameReviewError.malformed }
    }
}
nonisolated struct TitleValidation: Codable, Equatable, Sendable {
    let reviewID: ExactValue
    let evidence: TitleEvidence
    let anchorEvidence: [String]
    let validatorVersion: Int
    let evidenceSHA256: String
    let previousValidationSHA256: String?
    var identity: String {
        struct Key: Encodable { let reviewID: ExactValue; let evidence: String; let version: Int }
        return NameDigest.of(Key(reviewID:reviewID,evidence:NameDigest.of(evidence),version:validatorVersion))
    }
}
nonisolated struct TitleHistory: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    var choices: [TitleBindingReview] = []
    var validations: [TitleValidation] = []
    var observations: [TitleEvidence] = []
}

nonisolated struct AuthoredRailName: Codable, Hashable, Sendable {
    enum Method: String, Codable, Sendable { case human, machineAssisted, providerSupplied }
    let id: ExactValue
    let entityID: MintedIdentifier
    let language: RailNameLanguage
    let value: ExactValue
    let author: ExactValue
    let reviewer: ExactValue
    let approvalID: ExactValue
    let method: Method
    let reason: ExactValue
    /// Explicit references are evidence of the owner's authorization decision,
    /// not a tool-generated legal conclusion or an ODPT permission claim.
    let authorizationReferences: [ExactValue]
    let lineage: [NameSourceKey]
}
nonisolated struct RailNameRecords: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    var names: [NameChoice] = []
    var titles: [TitleBindingReview] = []
    var authored: [AuthoredRailName] = []
    var crosswalks: [TitleCrosswalk] = []
    func validate() throws {
        guard schemaVersion == 1 else { throw NameReviewError.schema }
        let reviews = names.map(\.reviewID) + titles.map(\.reviewID)
        guard Set(reviews).count == reviews.count,
              Set(titles.map { $0.evidence.source }).count == titles.count,
              Set(authored.map(\.id)).count == authored.count,
              Set(crosswalks.map(\.id)).count == crosswalks.count else { throw NameReviewError.duplicate }
        var nameKeys = Set<String>()
        for n in names {
            try n.validateRecord()
            if n.purpose == .name {
                let key = n.evidence.entityID.rawValue + ":" + n.evidence.language.rawValue
                guard nameKeys.insert(key).inserted else { throw NameReviewError.duplicate }
            } else if n.evidence.entityID.kind != .station { throw NameReviewError.malformed }
        }
        for t in titles { try t.validateRecord() }
        for a in authored {
            guard !a.authorizationReferences.isEmpty, Set(a.lineage).count == a.lineage.count,
                  a.method != .providerSupplied else { throw NameReviewError.malformed }
        }
        guard crosswalks.allSatisfy({ MappingText.isSHA256($0.documentSHA256) }) else { throw NameReviewError.malformed }
    }
}
