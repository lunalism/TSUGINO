import Foundation

/// Caller-supplied, identified bytes only. No network or credential handling.
struct StationEvidenceInput {
    let sourceID: ExactValue
    let railwaySourceID: ExactValue
    let gtfsSourceID: ExactValue
    let sha256: String
    let rows: [StationCodeEvidence.Row]

    static func read(_ data: Data, sourceID: ExactValue, railwaySourceID: ExactValue,
                     gtfsSourceID: ExactValue, sha256: String) throws -> Self {
        guard data.count <= 16 * 1024 * 1024, MappingText.isSHA256(sha256), sha256Hex(data) == sha256 else { throw NameReviewError.malformed }
        struct Row: Decodable {
            let id: ExactValue; let sameAs: ExactValue; let operatorReference: ExactValue
            let railway: ExactValue; let code: String?; let date: ExactValue; let type: ExactValue
            enum CodingKeys: String, CodingKey {
                case id = "@id", sameAs = "owl:sameAs", operatorReference = "odpt:operator"
                case railway = "odpt:railway", code = "odpt:stationCode", date = "dc:date", type = "@type"
            }
        }
        let decoded = try RailNameCommand.decode([Row].self,data:data)
        guard decoded.allSatisfy({ $0.type == ExactValue("odpt:Station")! }) else { throw NameReviewError.malformed }
        return .init(sourceID:sourceID,railwaySourceID:railwaySourceID,gtfsSourceID:gtfsSourceID,sha256:sha256,
            rows:decoded.enumerated().map { i,r in .init(id:r.id,sameAs:r.sameAs,operatorReference:r.operatorReference,
                railway:r.railway,code:r.code.flatMap(ExactValue.init),recordIndex:i,date:r.date) })
    }

    func assess(_ evidence: TitleEvidence, catalog: RailNameCatalog) -> StationCodeEvidence {
        let own = rows.filter { $0.sameAs == evidence.source.stationReference }
        // Keep every row competing on an identity or scoped code. Duplicate
        // identical rows also conflict; no dictionary silently overwrites them.
        let relevant = rows.filter { r in own.contains { o in
            r.id == o.id || r.sameAs == o.sameAs || (o.code != nil && r.code == o.code && r.operatorReference == o.operatorReference && r.railway == o.railway)
        } }.sorted { $0.recordIndex < $1.recordIndex }
        var reasons = Set<String>(), matches = Set<StationCodeEvidence.Match>()
        var conflicting = false
        if own.isEmpty { reasons.insert("stationReferenceMissing") }
        if own.count > 1 || relevant.count > own.count { conflicting = true; reasons.insert("duplicateOrConflictingIdentityOrCode") }
        for row in own {
            let scopes = evidence.occurrences.filter { occurrence in
                guard let rail = catalog.input.railways.first(where: { ExactValue($0.sourceID) == railwaySourceID })?.records.first(where: { ExactValue($0.id) == occurrence.railwayID }) else { return false }
                return row.railway == occurrence.sameAs && row.operatorReference == ExactValue(rail.operatorReference)
                    && catalog.lineOperators[occurrence.lineID] == occurrence.operatorID
            }
            guard scopes.count == evidence.occurrences.count, !scopes.isEmpty else {
                conflicting = true; reasons.insert("operatorOrRailwayScopeConflict");continue
            }
            guard let code = row.code else { reasons.insert("stationCodeMissing");continue }
            for target in evidence.candidates {
                for member in target.members where member.sourceID == gtfsSourceID && member.namespace == .gtfsStopID && member.codes.contains(code)
                    && scopes.allSatisfy({ member.lineIDs.contains($0.lineID) }) {
                    matches.insert(.init(stationID:target.stationID,gtfsSourceID:gtfsSourceID,stopID:member.value,code:code))
                }
            }
        }
        let ordered = matches.sorted { a,b in a.stationID == b.stationID ? a.stopID < b.stopID : a.stationID < b.stationID }
        let targets = Set(matches.map(\.stationID))
        let status: StationCodeEvidence.Status
        if conflicting { status = .conflicting }
        else if targets.count > 1 { status = .ambiguous; reasons.insert("multipleCanonicalTargets") }
        else if own.count == 1 && targets.count == 1 { status = .supported }
        else { status = .missing; if !own.isEmpty && own[0].code != nil { reasons.insert("activeScopedGTFSCodeMissing") } }
        return .init(sourceID:sourceID,railwaySourceID:railwaySourceID,gtfsSourceID:gtfsSourceID,inputSHA256:sha256,
                     rows:relevant,matches:ordered,status:status,reasons:reasons.sorted())
    }
}

/// Evidence availability is independent of approval. No supplied evidence is
/// "unevaluated", not a fabricated assertion that evidence does not exist.
struct TitleSupportAssessment: Codable {
    enum Status: String, Codable, CaseIterable { case unevaluated, supportedButUnreviewed, supportedAndReviewed, missing, ambiguous, conflicting }
    let source: EditorialStationKey
    let status: Status
    let reasons: [String]
    static func assess(_ e: TitleEvidence, approved: Bool) -> Self {
        let supported: Status = approved ? .supportedAndReviewed : .supportedButUnreviewed
        if let s = e.stationCodes {
            switch s.status {
            case .missing: return .init(source:e.source,status:.missing,reasons:s.reasons)
            case .ambiguous: return .init(source:e.source,status:.ambiguous,reasons:s.reasons)
            case .conflicting: return .init(source:e.source,status:.conflicting,reasons:s.reasons)
            case .supported:
                if !e.crosswalks.isEmpty && RailwayTitleBindings.directTarget(e) != RailwayTitleBindings.codeTarget(e) {
                    return .init(source:e.source,status:.conflicting,reasons:["crosswalkDisagreesWithStationCode"])
                }
                return .init(source:e.source,status:supported,reasons:[])
            }
        }
        if !e.crosswalks.isEmpty {
            return .init(source:e.source,status:RailwayTitleBindings.directTarget(e) == nil ? .conflicting : supported,
                         reasons:RailwayTitleBindings.directTarget(e) == nil ? ["crosswalkUnresolvedOrConflicting"] : [])
        }
        return .init(source:e.source,status:approved ? .supportedAndReviewed : .unevaluated,
                     reasons:approved ? [] : ["noStationSnapshotOrCrosswalkEvaluated"])
    }
}
