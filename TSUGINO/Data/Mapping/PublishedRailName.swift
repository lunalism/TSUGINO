import Foundation

/// DEC-071 published-source evidence, provisional review schema 1. Captures
/// authenticate retained artifacts only, not a remote page or its publisher.
/// No identity creation, translation permission, or publication grant is implied.
nonisolated struct PublishedRailName: Codable, Hashable, Sendable {
    enum Kind: String, Codable, Sendable { case rawHTML, webToolExtract }
    enum Support: String, Codable, Sendable { case stationCodeRow, linkedStationCode, operatorWebsite, operatorLink }
    struct Capture: Codable, Hashable, Sendable {
        let documentID: ExactValue
        let artifactSHA256: String
        let kind: Kind
        let sourceURL: ExactValue
        let capturedAt: ExactValue
        /// UTF-8 byte offsets within raw HTML or the wrapper's `result` string.
        /// The section includes the source header; context is within that section.
        let sectionOffset: Int
        let sectionLength: Int
        let contextOffset: Int
        let context: ExactValue
        let toolReference: ExactValue?
    }
    var schemaVersion: Int = 1
    let id: ExactValue
    let entityID: MintedIdentifier
    let language: RailNameLanguage
    let value: ExactValue
    let capture: Capture
    let supportingCapture: Capture?
    let support: Support
    let memberSourceID: ExactValue
    let memberKey: ExactValue
    let lineID: MintedIdentifier?
    let stationCode: ExactValue?
    let linkID: Int?
    /// Identified owner approval, retained verbatim in an independently hashed
    /// document. The importer checks its exact target/language/value tuple.
    let approvalDocumentID: ExactValue
    let approvalSHA256: String
    let approvalReference: ExactValue
    let reason: ExactValue
}
