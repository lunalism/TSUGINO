import Foundation

/// Offline, bounded evidence import. Locators select bytes, never normalized
/// text. The narrow web-extract grammar is deliberately fail-closed; another
/// extractor/layout needs an explicit locator, not a guessed correspondence.
enum PublishedNameInput {
    struct Approval: Codable {
        let schemaVersion: Int
        let reference: ExactValue
        let entityID: MintedIdentifier
        let language: RailNameLanguage
        let value: ExactValue
        let provenance: ExactValue
    }
    struct Extract: Decodable { let kind: String; let capturedAt: String; let result: String }
    struct Located { let section: String; let context: String; let host: String }
    static func host(_ text: String) throws -> String {
        guard let url = URLComponents(string:text), url.scheme == "https", let host = url.host,
              !host.isEmpty, url.user == nil, url.password == nil, url.query == nil else { throw NameReviewError.malformed }
        return host.lowercased()
    }
    static func same(_ a: String, _ b: String) -> Bool { a.utf8.elementsEqual(b.utf8) }
    static func has(_ text: String, _ part: String) -> Bool { Data(text.utf8).range(of:Data(part.utf8)) != nil }
    static func located(_ c: PublishedRailName.Capture, _ input: RailNameInput) throws -> Located {
        guard MappingText.isSHA256(c.artifactSHA256), input.documents[c.documentID] == c.artifactSHA256,
              let data = input.documentBytes[c.documentID], data.count <= 16 * 1024 * 1024,
              sha256Hex(data) == c.artifactSHA256, c.context.text.utf8.count <= 16 * 1024 else { throw NameReviewError.malformed }
        let body: Data
        switch c.kind {
        case .rawHTML: body = data; guard c.toolReference == nil else { throw NameReviewError.malformed }
        case .webToolExtract:
            let extract = try RailNameCommand.decode(Extract.self,data:data)
            guard has(extract.kind,"extract"), same(extract.capturedAt,c.capturedAt.text), c.toolReference != nil else { throw NameReviewError.malformed }
            body = Data(extract.result.utf8)
        }
        guard c.sectionOffset >= 0, c.sectionLength > 0, c.sectionLength <= body.count,
              c.sectionOffset <= body.count-c.sectionLength, c.contextOffset >= 0,
              c.context.text.utf8.count <= c.sectionLength, c.contextOffset <= c.sectionLength-c.context.text.utf8.count else { throw NameReviewError.malformed }
        let section = body.subdata(in:c.sectionOffset..<c.sectionOffset+c.sectionLength)
        guard let text = String(data:section,encoding:.utf8),
              section.subdata(in:c.contextOffset..<c.contextOffset+c.context.text.utf8.count) == Data(c.context.text.utf8) else { throw NameReviewError.malformed }
        if c.kind == .webToolExtract {
            let header = text.components(separatedBy:"\n").prefix(3).joined(separator:"\n")
            guard has(header,"("+c.sourceURL.text+")"), has(header,"cite"+c.toolReference!.text+"") else { throw NameReviewError.malformed }
        }
        return .init(section:text,context:c.context.text,host:try host(c.sourceURL.text))
    }
    static func agencyHost(_ member: NameMember, _ catalog: RailNameCatalog) throws -> String {
        guard let source = catalog.input.sources.first(where: { same($0.sourceID,member.sourceID.text) }),
              let agency = source.archive.feed.agencies.first(where: { $0.agencyID.map { same($0,member.value.text) } == true }) else { throw NameReviewError.unknownEntity }
        return try host(agency.url)
    }
    /// Returns exactly one link label, preserving scalars and spaces.
    static func label(_ row: String, id: Int) throws -> String {
        let marker = "cite\(id)†"
        guard let start = row.range(of:marker,options:.literal),
              let end = row.range(of:"",options:.literal,range:start.upperBound..<row.endIndex),
              !has(String(row[end.upperBound...]),marker) else { throw NameReviewError.malformed }
        return String(row[start.upperBound..<end.lowerBound])
    }
    static func candidate(_ p: PublishedRailName, _ catalog: RailNameCatalog) throws -> NameCandidate {
        let input = catalog.input
        guard p.schemaVersion == 1, catalog.entityIDs.contains(p.entityID),
              let approvalBytes = input.documentBytes[p.approvalDocumentID],
              input.documents[p.approvalDocumentID] == p.approvalSHA256,
              sha256Hex(approvalBytes) == p.approvalSHA256 else { throw NameReviewError.malformed }
        let approval = try RailNameCommand.decode(Approval.self,data:approvalBytes)
        guard approval.schemaVersion == 1, approval.reference == p.approvalReference, approval.entityID == p.entityID,
              approval.language == p.language, approval.value == p.value else { throw NameReviewError.malformed }
        let a = try located(p.capture,input)
        let members = catalog.members[p.entityID] ?? []
        let namespace: ProviderNamespace = p.entityID.kind == .station ? .gtfsStopID : .gtfsAgencyID
        guard let member = members.first(where: { $0.sourceID == p.memberSourceID && $0.namespace == namespace && $0.value == p.memberKey }) else { throw NameReviewError.unknownEntity }
        var dependencies = [member]
        var rationaleContext: ExactValue?
        switch p.support {
        case .stationCodeRow, .linkedStationCode:
            guard p.entityID.kind == .station, let line = p.lineID, let code = p.stationCode, let link = p.linkID,
                  link >= 0, member.lineIDs.contains(line), member.codes.contains(code),
                  let op = catalog.lineOperators[line],
                  let agency = catalog.members[op]?.first(where: { $0.sourceID == member.sourceID && $0.namespace == .gtfsAgencyID }),
                  try agencyHost(agency,catalog) == a.host else { throw NameReviewError.malformed }
            let targets = Set(catalog.members.values.flatMap { $0 }.filter {
                $0.sourceID == member.sourceID && $0.namespace == .gtfsStopID && $0.codes.contains(code)
            }.map(\.entityID))
            guard targets == [p.entityID], p.capture.kind == .webToolExtract,
                  !has(a.context,"\n"), same(try label(a.context,id:link),p.value.text) else { throw NameReviewError.malformed }
            dependencies.append(agency)
            if p.support == .stationCodeRow {
                guard p.supportingCapture == nil, has(a.context,"†Image: "+code.text+"") else { throw NameReviewError.malformed }
                // Exactly one code marker and one selected name in this table row.
                guard a.context.components(separatedBy:"†Image:").count == 2,
                      a.context.components(separatedBy:"cite").count == 3 else { throw NameReviewError.malformed }
            } else {
                guard let capture = p.supportingCapture, capture.kind == .webToolExtract,
                      let reference = p.capture.toolReference else { throw NameReviewError.malformed }
                let b = try located(capture,input)
                let header = b.section.components(separatedBy:"\n").prefix(3).joined(separator:"\n")
                guard b.host == a.host, has(header,"Source: click({\"ref_id\":\""+reference.text+"\",\"id\":\(link)})"),
                      has(b.section.components(separatedBy:"\n").first ?? "","/"+code.text+" |"),
                      has(b.context,"/"+code.text+" |") else { throw NameReviewError.malformed }
                rationaleContext = ExactValue(b.context)
            }
        case .operatorWebsite, .operatorLink:
            guard p.entityID.kind == .railwayOperator, p.lineID == nil, p.stationCode == nil, p.linkID == nil,
                  p.supportingCapture == nil else { throw NameReviewError.malformed }
            let expected = try agencyHost(member,catalog)
            if p.support == .operatorWebsite {
                guard a.host == expected, p.capture.kind == .webToolExtract, has(a.context,p.value.text),
                      !has(a.context,"\n"), !has(a.context,"http") else { throw NameReviewError.malformed }
                // Web-extractor line numbers are sightings, but surrounding
                // words can change the meaning of an operator-name assertion.
                rationaleContext = ExactValue(a.context.replacingOccurrences(of:"^L[0-9]+: *",with:"",options:.regularExpression))
            } else {
                // Narrow raw-HTML anchor form: one href and plain visible text.
                // HTML entities are not decoded into invented selected text.
                guard p.capture.kind == .rawHTML, a.context.hasPrefix("<a "), a.context.hasSuffix("</a>"),
                      let href = a.context.range(of:"href=\"",options:.literal),
                      let end = a.context.range(of:"\"",options:.literal,range:href.upperBound..<a.context.endIndex),
                      let open = a.context.firstIndex(of:">"), let close = a.context.range(of:"</a>",options:.literal),
                      open < close.lowerBound else { throw NameReviewError.malformed }
                let visible = String(a.context[a.context.index(after:open)..<close.lowerBound])
                guard !has(visible,"<"), has(visible,p.value.text),
                      a.context.components(separatedBy:"href=").count == 2,
                      try host(String(a.context[href.upperBound..<end.lowerBound])) == expected else { throw NameReviewError.malformed }
                rationaleContext = ExactValue(visible)
            }
        }
        // Capture positions/hashes may change without changing the selection.
        // Every carry-forward reruns all checks above. Earlier full sightings
        // and choices remain in the shared append-only evidence history.
        struct Semantic: Encodable {
            let id: ExactValue; let entityID: MintedIdentifier; let language: RailNameLanguage; let value: ExactValue
            let sourceURL: ExactValue; let supportingURL: ExactValue?; let support: PublishedRailName.Support
            let members: [NameMember]; let lineID: MintedIdentifier?; let code: ExactValue?
            let approvalReference: ExactValue; let reason: ExactValue
            let rationaleContext: ExactValue?
        }
        let digest = NameDigest.of(Semantic(id:p.id,entityID:p.entityID,language:p.language,value:p.value,
            sourceURL:p.capture.sourceURL,supportingURL:p.supportingCapture?.sourceURL,support:p.support,
            members:dependencies.sorted(by:NameMember.precedes),lineID:p.lineID,code:p.stationCode,approvalReference:p.approvalReference,reason:p.reason,rationaleContext:rationaleContext))
        let source = ExactValue("published-source")!
        let captures = [p.capture] + (p.supportingCapture.map { [$0] } ?? [])
        let sightings = try captures.enumerated().map { i,c in NameSighting(sourceID:source,
            reference:try SourceReference(inputSHA256:c.artifactSHA256,member:nil,table:nil,recordIndex:i,field:"publishedText",providerKey:p.id),
            arrayPosition:nil,documentSHA256:c.artifactSHA256) }
        return .init(key:.init(sourceID:source,namespace:ExactValue("editorial.publishedName")!,providerKey:p.id,
                              parentKey:p.capture.sourceURL,field:ExactValue("publishedText")!,language:p.language),
                     value:p.value,sightings:sightings,dependencySHA256:digest,publication:p)
    }
}
