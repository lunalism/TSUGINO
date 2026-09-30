import Foundation

// Invented published text, identities, captures and approvals only.
enum SyntheticPublished {
    static func input(value: String = "Synthetic Café", suffix: String = "", station: Bool = false, linked: Bool = false, raw: Bool = false, operatorWording: String = "website") throws -> RailNameInput {
        let old = try SyntheticNames.input()
        let sources = old.sources.map { s -> RailNameInput.Static in
            let f = s.archive.feed
            let stops = f.stops.map { GTFSStop(stopID:$0.stopID,stopCode:$0.stopID == "syn-a1" ? "Q01" : nil,name:$0.name,latitude:$0.latitude,longitude:$0.longitude,locationType:$0.locationType,parentStation:$0.parentStation,platformCode:$0.platformCode) }
            let feed = GTFSStaticFeed(agencies:f.agencies,stops:stops,routes:f.routes,trips:f.trips,stopTimes:f.stopTimes,calendars:f.calendars,calendarDates:f.calendarDates,feedInfo:f.feedInfo,translations:f.translations)
            return .init(sourceID:s.sourceID,archive:.init(sha256:s.archive.sha256,byteCount:s.archive.byteCount,selectedMembers:s.archive.selectedMembers,unselectedMembers:s.archive.unselectedMembers,feed:feed))
        }
        let x = SyntheticNames.x
        let entity = station ? SyntheticNetwork.stn(1) : SyntheticNetwork.id("opr",1)
        let row = station ? (linked ? "L1: cite2†\(value)" : "L1: | cite1†Image: Q01 cite2†\(value) |") : (raw ? "<a href=\"https://example.invalid/about#company\">\(value)</a>" : "L1: \(value) \(operatorWording)")
        let url = raw ? "https://guide.invalid/operators" : "https://example.invalid/names"
        let header = "Synthetic source (\(url))\ncitesyn0 Source: open\n"
        let text = raw ? row+suffix : header+row+suffix
        let bytes = raw ? Data(text.utf8) : NetworkJSON.encode(["kind":"web-tool extract; not raw bytes","capturedAt":"2099-01-01","result":text])
        let capture = PublishedRailName.Capture(documentID:x("capture"),artifactSHA256:sha256Hex(bytes),kind:raw ? .rawHTML : .webToolExtract,sourceURL:x(url),capturedAt:x("2099-01-01"),sectionOffset:0,sectionLength:text.utf8.count,contextOffset:raw ? 0 : header.utf8.count,context:x(row),toolReference:raw ? nil : x("syn0"))
        let approval = PublishedNameInput.Approval(schemaVersion:1,reference:x("SYN-APPROVAL"),entityID:entity,language:.ko,value:x(value),provenance:x("Synthetic owner approval; no real authority"))
        let approvalData = NetworkJSON.encode(approval)
        var docs = [x("capture"):bytes,x("approval"):approvalData]
        var support: PublishedRailName.Capture?
        if linked {
            let title = "Synthetic /Q01 | Station (https://example.invalid/station)"
            let body = title+"\ncitesyn1 Source: click({\"ref_id\":\"syn0\",\"id\":2});\nL1: Synthetic station"
            let data = NetworkJSON.encode(["kind":"web-tool extract","capturedAt":"2099-01-01","result":body])
            docs[x("support")] = data
            support = .init(documentID:x("support"),artifactSHA256:sha256Hex(data),kind:.webToolExtract,sourceURL:x("https://example.invalid/station"),capturedAt:x("2099-01-01"),sectionOffset:0,sectionLength:body.utf8.count,contextOffset:0,context:x(title),toolReference:x("syn1"))
        }
        var input = RailNameInput(sources:sources,railways:[],historical:[],registry:old.registry,registrySHA256:old.registrySHA256,network:old.network,documents:docs.mapValues(sha256Hex))
        input.documentBytes = docs
        input.publishedNames = [.init(id:x("SYN-PUBLISHED"),entityID:entity,language:.ko,value:x(value),capture:capture,supportingCapture:support,support:station ? (linked ? .linkedStationCode : .stationCodeRow) : (raw ? .operatorLink : .operatorWebsite),memberSourceID:x(sources[0].sourceID),memberKey:x(station ? "syn-a1" : "syn-agency-0"),lineID:station ? SyntheticNetwork.lin(1) : nil,stationCode:station ? x("Q01") : nil,linkID:station ? 2 : nil,approvalDocumentID:x("approval"),approvalSHA256:sha256Hex(approvalData),approvalReference:x("SYN-APPROVAL"),reason:x("Synthetic exact source and scoped evidence"))]
        return input
    }
    static func change(_ input: RailNameInput, _ edit: (inout [String:Any]) -> Void) throws -> RailNameInput {
        var i = input
        var p = try JSONSerialization.jsonObject(with:NetworkJSON.encode(i.publishedNames[0])) as! [String:Any]
        edit(&p)
        i.publishedNames = [try JSONDecoder().decode(PublishedRailName.self,from:JSONSerialization.data(withJSONObject:p))]
        return i
    }
    static func records(_ input: RailNameInput) throws -> RailNameRecords {
        let packet = try RailNames.build(input,records:.init())
        return .init(names:packet.evidence.map { e in SyntheticNames.choice(e,candidate:e.candidates.first { $0.publication != nil }) })
    }
    static func held(_ input: RailNameInput) throws {
        let result = try RailNames.build(input,records:.init())
        let e = result.evidence.first { $0.entityID == input.publishedNames[0].entityID && $0.language == .ko }!
        try check(e.issues.contains(.rationaleUnverifiable) && e.unverifiedPublications == input.publishedNames,"invalid publication not held/retained")
    }
}

let publishedNameTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("published: distinct evidence exact Unicode and provider-authored rejection remains", { _ in
        let input = try SyntheticPublished.input(value:"Synthetic Cafe\u{301}")
        let outcome = try RailNames.build(input,records:SyntheticPublished.records(input))
        try check(outcome.complete,"published source held")
        let candidate = outcome.evidence.flatMap(\.candidates).first { $0.publication != nil }!
        try check(candidate.authorship == nil && candidate.value != ExactValue("Synthetic Café")!,"authorship or Unicode collapsed")
        let old = try SyntheticNames.input(); let base = try SyntheticNames.records(old)
        let authored = AuthoredRailName(id:SyntheticNames.x("bad"),entityID:candidate.publication!.entityID,language:.ko,value:candidate.value,author:SyntheticNames.x("source"),reviewer:SyntheticNames.x("review"),approvalID:SyntheticNames.x("approval"),method:.providerSupplied,reason:SyntheticNames.x("published is not authored"),authorizationReferences:[],lineage:[])
        try SyntheticNames.expectFailure { try RailNameRecords(names:base.names,authored:[authored]).validate() }
        _ = try RailNameSearchAudit.validate(outcome)
    }),
    ("published: raw anchor and scoped station row and explicit clicked-code evidence", { _ in
        for input in [try SyntheticPublished.input(raw:true),try SyntheticPublished.input(station:true),try SyntheticPublished.input(station:true,linked:true)] {
            try check(try RailNames.build(input,records:SyntheticPublished.records(input)).complete,"supported evidence rejected")
        }
    }),
    ("published: mismatched source target code link and unsupported exact value hold", { _ in
        let input = try SyntheticPublished.input(station:true)
        for field in ["memberKey","stationCode","value"] {
            try SyntheticPublished.held(SyntheticPublished.change(input) { $0[field] = "Synthetic wrong" })
        }
        try SyntheticPublished.held(SyntheticPublished.change(input) { p in var c = p["capture"] as! [String:Any];c["sourceURL"] = "https://other.invalid/names";p["capture"] = c })
        try SyntheticPublished.held(SyntheticPublished.change(input) { $0["entityID"] = SyntheticNetwork.stn(2).rawValue })
        try SyntheticPublished.held(SyntheticPublished.change(input) { $0["lineID"] = SyntheticNetwork.lin(2).rawValue })
        try SyntheticPublished.held(SyntheticPublished.change(try SyntheticPublished.input(station:true,linked:true)) { $0["linkID"] = 9 })
        try SyntheticPublished.held(SyntheticPublished.change(try SyntheticPublished.input(value:"Synthetic Café")) { $0["value"] = "Synthetic Cafe\u{301}" })
    }),
    ("published: conflicting scoped code and unrelated context cannot establish a target", { _ in
        let input = try SyntheticPublished.input(station:true)
        let catalog = try RailNameCatalog(input)
        var conflict = catalog
        let old = conflict.members[SyntheticNetwork.stn(2)]![0]
        conflict.members[SyntheticNetwork.stn(2)] = [.init(sourceID:old.sourceID,namespace:old.namespace,value:old.value,entityID:old.entityID,lineIDs:old.lineIDs,codes:[SyntheticNames.x("Q01")],attachmentReview:old.attachmentReview)]
        try SyntheticNames.expectFailure { _ = try PublishedNameInput.candidate(input.publishedNames[0],conflict) }
        try SyntheticPublished.held(SyntheticPublished.change(input) { p in var c = p["capture"] as! [String:Any];c["context"] = "Synthetic name absent from captured material";p["capture"] = c })
    }),
    ("published: changed capture carries only revalidated evidence and preserves history deterministically", { _ in
        let a = try SyntheticPublished.input();let records = try SyntheticPublished.records(a)
        let first = try RailNames.build(a,records:records)
        let b = try SyntheticPublished.input(suffix:"\nUnrelated new footer")
        let second = try RailNames.build(b,records:records,previousNames:first.history)
        try check(second.complete && second.history.choices == first.history.choices,"unchanged selection did not carry")
        try check(second.history.observations.count > first.history.observations.count && Array(second.history.observations.prefix(first.history.observations.count)) == first.history.observations,"earliest evidence lost")
        let repeatRun = try RailNames.build(b,records:records,previousNames:second.history)
        let h = RailNameHistoryArtifact(names:second.history,titles:second.titleBindings.history)
        let bytes = try RailNameHistoryFile.encode(h)
        try check(bytes == RailNameHistoryFile.encode(.init(names:repeatRun.history,titles:repeatRun.titleBindings.history)),"repeat duplicates")
        let decoded = try RailNameHistoryFile.decode(bytes)
        try check(decoded.names == h.names,"publication history round trip lost evidence")
        let changed = try SyntheticPublished.change(b) { $0["stationCode"] = "WRONG" }
        let held = try RailNames.build(changed,records:records,previousNames:second.history)
        try check(!held.complete && held.history.choices == second.history.choices,"invalid change substituted/lost old choice")
    }),
    ("published: bounded malformed locators tampered bytes duplicate keys and missing evidence", { _ in
        let input = try SyntheticPublished.input()
        for n in [-1,Int.max] {
            try SyntheticPublished.held(SyntheticPublished.change(input) { p in var c = p["capture"] as! [String:Any];c["sectionOffset"] = n;p["capture"] = c })
        }
        var missing = input;missing.documentBytes = [:];try SyntheticPublished.held(missing)
        var changed = input;changed.documentBytes[SyntheticNames.x("capture")] = Data("tampered".utf8);try SyntheticPublished.held(changed)
        var oversized = input;oversized.documentBytes[SyntheticNames.x("capture")] = Data(repeating:65,count:16*1024*1024+1);try SyntheticPublished.held(oversized)
        try SyntheticPublished.held(SyntheticPublished.change(input) { p in var c = p["capture"] as! [String:Any];c["context"] = String(repeating:"x",count:16385);p["capture"] = c })
        try SyntheticNames.expectFailure { _ = try RailNameCommand.decode(PublishedNameInput.Extract.self,data:Data("{\"kind\":\"extract\",\"kind\":\"extract\"}".utf8)) }
        var duplicate = input;duplicate.publishedNames += duplicate.publishedNames
        try SyntheticNames.expectFailure { _ = try RailNames.build(duplicate,records:.init()) }
    }),
    ("published: changed rationale context behind unchanged spelling requires review", { _ in
        let old = try SyntheticPublished.input();let records = try SyntheticPublished.records(old)
        let first = try RailNames.build(old,records:records)
        let revised = try SyntheticPublished.input(operatorWording:"former operator")
        let second = try RailNames.build(revised,records:records,previousNames:first.history)
        try check(!second.complete && second.statuses.contains { $0.heldBack == .relevantEvidenceChanged },"changed statement silently carried")
        try check(second.history.choices == first.history.choices,"old choice overwritten")
    }),
    ("published: old evidence encoding remains byte-identical without new optional fields", { _ in
        let old = try SyntheticNames.input();let result = try RailNames.build(old,records:SyntheticNames.records(old))
        let bytes = NetworkJSON.encode(result.history)
        try check(!PublishedNameInput.has(String(decoding:bytes,as:UTF8.self),"publication"),"optional absent fields changed old format")
        try check(NetworkJSON.encode(JSONDecoder().decode(NameHistory.self,from:bytes)) == bytes,"old logical bytes changed")
    })
]
