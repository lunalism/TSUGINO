import Foundation
import CryptoKit
import CoreFoundation

// Editorial records only, DEC-071. These types never resolve provider IDs
// globally, mint identity, or write the MappingRegistry. All text participating
// in evidence, equality or ordering uses ExactValue (never String keys).
nonisolated enum RailNameLanguage: String, Codable, CaseIterable, Sendable { case ja, en, ko }
nonisolated enum NameReviewError: Error, Equatable {
    case schema, malformed, duplicate, staleRegistry, unknownEntity, invalidHistory, incompleteNetwork
}

/// Fixed-schema, typed, length-prefixed digest. Arrays must already be in
/// semantic order. Object keys are fixed ASCII schema keys, never provider text.
nonisolated enum NameDigest {
    static func of<T: Encodable>(_ value: T) -> String {
        let data = try! JSONEncoder().encode(value)
        let object = try! JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        var bytes = Data()
        func field(_ value: String) {
            bytes.append(contentsOf: String(value.utf8.count).utf8); bytes.append(58); bytes.append(contentsOf: value.utf8)
        }
        func visit(_ value: Any) {
            if value is NSNull { field("null") }
            else if let s = value as? String { field("text"); field(s) }
            else if let array = value as? [Any] { field("array"); field(String(array.count)); array.forEach(visit) }
            else if let object = value as? [String: Any] {
                field("object"); field(String(object.count))
                for key in object.keys.sorted() { field(key); visit(object[key]!) }
            } else if let number = value as? NSNumber {
                field(CFGetTypeID(number) == CFBooleanGetTypeID() ? "boolean" : "number"); field(number.stringValue)
            }
        }
        field("tsugino.names.v1"); visit(object)
        return SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
}

nonisolated struct NameSourceKey: Codable, Hashable, Sendable {
    let sourceID: ExactValue
    let namespace: ExactValue
    let providerKey: ExactValue
    let parentKey: ExactValue?
    let field: ExactValue
    let language: RailNameLanguage
    /// Non-nil only for explicitly historical evidence. Current archive hashes
    /// live in sightings, not semantic source identity.
    var historicalInput: String? = nil
}
nonisolated struct NameSighting: Codable, Hashable, Sendable {
    let sourceID: ExactValue
    let reference: SourceReference
    let arrayPosition: Int?
    let documentSHA256: String?
    static func precedes(_ a: Self, _ b: Self) -> Bool {
        if a.sourceID != b.sourceID { return a.sourceID < b.sourceID }
        if a.reference != b.reference { return SourceReference.precedes(a.reference,b.reference) }
        if a.arrayPosition != b.arrayPosition { return (a.arrayPosition ?? -1) < (b.arrayPosition ?? -1) }
        return (a.documentSHA256 ?? "") < (b.documentSHA256 ?? "")
    }
}
nonisolated struct NameCandidate: Codable, Hashable, Sendable {
    let key: NameSourceKey
    let value: ExactValue
    let sightings: [NameSighting]
    /// For authored inputs and title bindings, the full verified semantic
    /// dependency digest. Archive hashes/physical positions are excluded.
    let dependencySHA256: String?
    var authorship: AuthoredRailName? = nil
    static func precedes(_ a: Self, _ b: Self) -> Bool {
        let x = [a.key.sourceID.text, a.key.namespace.text, a.key.providerKey.text, a.key.parentKey?.text ?? "", a.key.field.text, a.key.language.rawValue, a.key.historicalInput ?? "", a.value.text]
        let y = [b.key.sourceID.text, b.key.namespace.text, b.key.providerKey.text, b.key.parentKey?.text ?? "", b.key.field.text, b.key.language.rawValue, b.key.historicalInput ?? "", b.value.text]
        for (l,r) in zip(x,y) where !l.unicodeScalars.elementsEqual(r.unicodeScalars) { return l.utf8.lexicographicallyPrecedes(r.utf8) }
        return false
    }
    var semantic: Semantic { .init(key: key, value: value, dependencySHA256: dependencySHA256) }
    struct Semantic: Codable, Hashable, Sendable {
        let key: NameSourceKey
        let value: ExactValue
        let dependencySHA256: String?
    }
}
nonisolated struct NameMember: Codable, Hashable, Sendable {
    let sourceID: ExactValue
    let namespace: ProviderNamespace
    let value: ExactValue
    let entityID: MintedIdentifier
    let lineIDs: [MintedIdentifier]
    let codes: [ExactValue]
    var attachmentReview: ExactValue? = nil
    static func precedes(_ a: Self, _ b: Self) -> Bool {
        for (l,r) in zip([a.sourceID.text,a.namespace.rawValue,a.value.text,a.entityID.rawValue],
                         [b.sourceID.text,b.namespace.rawValue,b.value.text,b.entityID.rawValue]) where !l.unicodeScalars.elementsEqual(r.unicodeScalars) {
            return l.utf8.lexicographicallyPrecedes(r.utf8)
        }
        return false
    }
}
nonisolated struct RetainedRailName: Codable, Hashable, Sendable {
    let sourceID: ExactValue
    let namespace: ProviderNamespace
    let providerKey: ExactValue
    let original: OriginalName
    static func precedes(_ a: Self, _ b: Self) -> Bool {
        if a.sourceID != b.sourceID { return a.sourceID < b.sourceID }
        if a.namespace != b.namespace { return a.namespace.rawValue < b.namespace.rawValue }
        if a.providerKey != b.providerKey { return a.providerKey < b.providerKey }
        return OriginalName.precedes(a.original,b.original)
    }
}
nonisolated struct NameEvidence: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    let entityID: MintedIdentifier
    let language: RailNameLanguage
    let members: [NameMember]
    let candidates: [NameCandidate]
    let bindingDependencies: [String]
    let issues: [NameHold]
    /// Full current original-name sightings including alternatives.
    let memberProvenance: [NameSighting]
    let inputSHA256: [String]
    let registrySHA256: String
    var registryOriginals: [RetainedRailName] = []

    struct Semantic: Codable, Equatable {
        let entityID: MintedIdentifier
        let language: RailNameLanguage
        let members: [NameMember]
        let candidates: [NameCandidate.Semantic]
        let bindingDependencies: [String]
        let issues: [NameHold]
    }
    var semantic: Semantic { .init(entityID: entityID, language: language, members: members,
        candidates: candidates.map(\.semantic), bindingDependencies: bindingDependencies, issues: issues) }
}
nonisolated enum NameHold: String, Codable, Sendable, CaseIterable {
    case reviewRequired, selectedMissing, valueChanged, relevantEvidenceChanged, bindingUnresolved
    case rationaleUnverifiable, unknownEntity, missingLanguage, networkIncomplete
}
nonisolated struct NameChoice: Codable, Equatable, Sendable {
    enum Purpose: String, Codable, Sendable { case name, alias }
    enum Basis: String, Codable, Sendable { case publishedMember, preferredSource, authoredApproval, historicalAlias }
    var schemaVersion: Int = 1
    let reviewID: ExactValue
    let reviewer: ExactValue
    let date: ExactValue
    let supersedes: ExactValue?
    let purpose: Purpose
    let selected: NameSourceKey
    let value: ExactValue
    let reason: ExactValue
    let basis: Basis
    let preferredSource: ExactValue?
    let aliasRule: StationAliasRule?
    let evidence: NameEvidence
    let selectionEvidenceSHA256: String
    let reviewEvidenceSHA256: String

    struct Semantic: Encodable {
        let evidence: NameEvidence.Semantic
        let selected: NameSourceKey
        let value: ExactValue
        let reason: ExactValue
        let basis: Basis
        let preferredSource: ExactValue?
        let aliasRule: StationAliasRule?
        let purpose: Purpose
    }
    func semanticDigest(_ current: NameEvidence) -> String {
        NameDigest.of(Semantic(evidence: current.semantic, selected: selected, value: value, reason: reason,
            basis: basis, preferredSource: preferredSource, aliasRule: aliasRule, purpose: purpose))
    }
    func validateRecord() throws {
        guard schemaVersion == 1, evidence.schemaVersion == 1 else { throw NameReviewError.schema }
        guard MappingText.isToken(reviewID.text), MappingText.isToken(date.text),
              selected.language == evidence.language,
              selectionEvidenceSHA256 == semanticDigest(evidence), reviewEvidenceSHA256 == NameDigest.of(evidence),
              !evidence.candidates.isEmpty, Set(evidence.candidates.map(\.key)).count == evidence.candidates.count,
              Set(evidence.members).count == evidence.members.count,
              supersedes != reviewID else { throw NameReviewError.malformed }
    }
    func hold(in current: NameEvidence) -> NameHold? {
        guard current.entityID == evidence.entityID, current.language == evidence.language else { return .unknownEntity }
        if let issue = current.issues.first { return issue }
        guard let row = current.candidates.first(where: { $0.key == selected }) else { return .selectedMissing }
        let expected: ExactValue
        if let rule = aliasRule {
            guard purpose == .alias else { return .rationaleUnverifiable }
            guard rule.relates(row.value,value), rule != .subtitleBracket || rule.comparisonKey(row.value) == value else { return .rationaleUnverifiable }
            expected = value
        } else { expected = row.value }
        guard expected == value else { return .valueChanged }
        if selected.historicalInput != nil && (purpose != .alias || basis != .historicalAlias) { return .rationaleUnverifiable }
        switch basis {
        case .preferredSource:
            guard preferredSource == selected.sourceID else { return .rationaleUnverifiable }
        case .authoredApproval:
            guard selected.namespace.text == "authored", row.dependencySHA256 != nil else { return .rationaleUnverifiable }
        case .historicalAlias:
            guard purpose == .alias, selected.historicalInput != nil else { return .rationaleUnverifiable }
        case .publishedMember:
            guard selected.namespace.text != "authored", preferredSource == nil else { return .rationaleUnverifiable }
        }
        guard semanticDigest(current) == selectionEvidenceSHA256, current.semantic == evidence.semantic else { return .relevantEvidenceChanged }
        return nil
    }
}

nonisolated struct NameValidation: Codable, Equatable, Sendable {
    let choiceID: ExactValue
    let evidence: NameEvidence
    let validatorVersion: Int
    let dependencyChecks: [String]
    let evidenceSHA256: String
    let previousValidationSHA256: String?
    var identity: String {
        struct Key: Encodable { let choiceID: ExactValue; let evidence: String; let version: Int }
        return NameDigest.of(Key(choiceID:choiceID,evidence:NameDigest.of(evidence),version:validatorVersion))
    }
}
nonisolated struct NameHistory: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    var choices: [NameChoice] = []
    var validations: [NameValidation] = []
    var observations: [NameEvidence] = []
    // Choices and full sightings are immutable; failed/current status is a
    // separate output. No timestamps generated by the runner enter history.
    mutating func validate() throws {
        guard schemaVersion == 1 else { throw NameReviewError.schema }
        guard Set(choices.map(\.reviewID)).count == choices.count,
              Set(validations.map(\.identity)).count == validations.count,
              Set(observations.map { NameDigest.of($0) }).count == observations.count else { throw NameReviewError.invalidHistory }
        var prefix = NameHistory()
        for c in choices { try c.validateRecord(); try prefix.retain(c) }
        guard observations.allSatisfy({ $0.schemaVersion == 1 }) else { throw NameReviewError.invalidHistory }
        var prior: [ExactValue:String] = [:]
        for v in validations {
            guard v.evidenceSHA256 == NameDigest.of(v.evidence), v.previousValidationSHA256 == prior[v.choiceID],
                  v.validatorVersion == 1,
                  v.dependencyChecks == Self.checks,
                  let c = choices.first(where: { $0.reviewID == v.choiceID }), c.hold(in: v.evidence) == nil else { throw NameReviewError.invalidHistory }
            prior[v.choiceID] = v.identity
        }
    }
    static let checks = ["exactValue", "activeBinding", "completeMembersAndCandidates", "rationaleDependencies"]
    mutating func retain(_ choice: NameChoice) throws {
        guard !choices.contains(where: { $0.supersedes == choice.reviewID }) else { throw NameReviewError.invalidHistory }
        if let predecessor = choice.supersedes {
            guard !choices.contains(where: { $0.supersedes == predecessor && $0.reviewID != choice.reviewID }) else { throw NameReviewError.invalidHistory }
        }
        if let old = choices.first(where: { $0.reviewID == choice.reviewID }) {
            guard old == choice else { throw NameReviewError.invalidHistory }
        } else {
            if let predecessor = choice.supersedes {
                guard let old = choices.first(where: { $0.reviewID == predecessor }), old.evidence.entityID == choice.evidence.entityID,
                      old.evidence.language == choice.evidence.language, old.purpose == choice.purpose else { throw NameReviewError.invalidHistory }
            }
            let replaced = Set(choices.compactMap(\.supersedes))
            let leaves = choices.filter { old in
                old.evidence.entityID == choice.evidence.entityID && old.evidence.language == choice.evidence.language &&
                old.purpose == choice.purpose && !replaced.contains(old.reviewID) &&
                (choice.purpose == .name || old.value == choice.value)
            }
            guard leaves.isEmpty || leaves.contains(where: { $0.reviewID == choice.supersedes }) else { throw NameReviewError.invalidHistory }
            choices.append(choice)
        }
    }
    mutating func append(_ choice: NameChoice, evidence: NameEvidence) {
        let v = NameValidation(choiceID: choice.reviewID, evidence: evidence, validatorVersion: 1, dependencyChecks: Self.checks,
            evidenceSHA256:NameDigest.of(evidence),previousValidationSHA256:validations.last { $0.choiceID == choice.reviewID }?.identity)
        if !validations.contains(where: { $0.identity == v.identity }) { validations.append(v) }
    }
}
