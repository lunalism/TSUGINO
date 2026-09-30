import Foundation

/// Editorial proof only: never a registry reference or a source of canonical names.
nonisolated struct StationCodeEvidence: Codable, Equatable, Sendable {
    enum Status: String, Codable, Sendable { case supported, missing, ambiguous, conflicting }
    struct Row: Codable, Hashable, Sendable {
        let id: ExactValue
        let sameAs: ExactValue
        let operatorReference: ExactValue
        let railway: ExactValue
        let code: ExactValue?
        let recordIndex: Int
        let date: ExactValue
        struct Semantic: Codable, Hashable {
            let id: ExactValue
            let sameAs: ExactValue
            let operatorReference: ExactValue
            let railway: ExactValue
            let code: ExactValue?
        }
        var semantic: Semantic { .init(id:id,sameAs:sameAs,operatorReference:operatorReference,railway:railway,code:code) }
    }
    struct Match: Codable, Hashable, Sendable {
        let stationID: MintedIdentifier
        let gtfsSourceID: ExactValue
        let stopID: ExactValue
        let code: ExactValue
    }
    let sourceID: ExactValue
    let railwaySourceID: ExactValue
    let gtfsSourceID: ExactValue
    let inputSHA256: String
    /// Includes identity/code competitors, not only the exact-reference rows.
    let rows: [Row]
    let matches: [Match]
    let status: Status
    let reasons: [String]
    struct Semantic: Codable {
        let sourceID: ExactValue
        let railwaySourceID: ExactValue
        let gtfsSourceID: ExactValue
        let rows: [Row.Semantic]
        let matches: [Match]
        let status: Status
        let reasons: [String]
    }
    var semantic: Semantic { .init(sourceID:sourceID,railwaySourceID:railwaySourceID,gtfsSourceID:gtfsSourceID,
        rows:rows.map(\.semantic).sorted { NameDigest.of($0) < NameDigest.of($1) },matches:matches,status:status,reasons:reasons) }
}
