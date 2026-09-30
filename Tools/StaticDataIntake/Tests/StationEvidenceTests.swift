import Foundation

// All provider-shaped identifiers/codes below are invented.
enum SyntheticStationEvidence {
    static func rows() -> [[String:String]] {
        (1...3).map { n in ["@id":"urn:invented:record:\(n)","@type":"odpt:Station","dc:date":"2099-01-01T00:00:00Z",
            "owl:sameAs":SyntheticNames.titleKey(n).stationReference.text,"odpt:operator":"synthetic:operator:1",
            "odpt:railway":"synthetic:railway:1","odpt:stationCode":"syn-a\(n)-code"] }
    }
    static func snapshot(_ rows:[[String:String]]) throws -> StationEvidenceInput {
        let data = try JSONSerialization.data(withJSONObject:rows,options:[.sortedKeys])
        return try StationEvidenceInput.read(data,sourceID:SyntheticNames.x("SYN-03/station"),
            railwaySourceID:SyntheticNames.x(SyntheticNames.railwaySource),gtfsSourceID:SyntheticNames.x(SyntheticNetwork.sources[0]),sha256:sha256Hex(data))
    }
    static func input(_ rows:[[String:String]]? = rows()) throws -> RailNameInput {
        let b = try SyntheticNames.railwayInput()
        let sources = b.sources.map { source -> RailNameInput.Static in
            let f = source.archive.feed
            let stops = f.stops.map { s in GTFSStop(stopID:s.stopID,stopCode:s.stopID+"-code",name:s.name,latitude:s.latitude,longitude:s.longitude,locationType:s.locationType,parentStation:s.parentStation,platformCode:s.platformCode) }
            let feed = GTFSStaticFeed(agencies:f.agencies,stops:stops,routes:f.routes,trips:f.trips,stopTimes:f.stopTimes,calendars:f.calendars,calendarDates:f.calendarDates,feedInfo:f.feedInfo,translations:f.translations)
            return .init(sourceID:source.sourceID,archive:.init(sha256:source.archive.sha256,byteCount:source.archive.byteCount,selectedMembers:source.archive.selectedMembers,unselectedMembers:source.archive.unselectedMembers,feed:feed))
        }
        var input = RailNameInput(sources:sources,railways:b.railways,historical:[],registry:b.registry,registrySHA256:b.registrySHA256,network:b.network,documents:b.documents)
        input.stationEvidence = try rows.map(snapshot)
        return input
    }
    static func review(_ e:TitleEvidence) throws -> TitleBindingReview {
        try RailNameSelections.Title(reviewID:SyntheticNames.x("SYN-CODE-REVIEW"),reviewer:SyntheticNames.x("Invented reviewer"),date:SyntheticNames.x("2099-01-01"),supersedes:nil,source:e.source,
            stationID:SyntheticNetwork.stn(1),reason:SyntheticNames.x("Explicit scoped Station code proof"),basis:.stationCode,anchors:[]).template(e,accepted:[:])
    }
    static func evidence(_ input:RailNameInput) throws -> TitleEvidence {
        try RailwayTitleBindings.evidence(RailNameCatalog(input),crosswalks:[]).first { $0.source == SyntheticNames.titleKey(1) }!
    }
}
let stationEvidenceTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("station evidence: registered source excluded from GTFS intake", { _ in
        let s = SourceList.tokyoMetroStation
        try check(s.sourceID == "DS-03/tokyometro-station" && s.access == .credentialed && s.url == nil,"source metadata")
        try check(SourceList.source(id:s.sourceID) == nil && SourceList.railwaySource(id:s.sourceID) == nil,"Station selected as intake")
    }),
    ("station evidence: support differs from approval and history repeats", { _ in
        let input = try SyntheticStationEvidence.input();let e = try SyntheticStationEvidence.evidence(input)
        try check(e.stationCodes?.status == .supported && e.stationCodes?.rows[0].recordIndex == 0,"proof/provenance missing")
        try check(e.stationCodes?.inputSHA256 == input.stationEvidence?.sha256 && e.memberProvenance.count > 0,"source provenance missing")
        let packet = try RailNames.build(input,records:.init())
        try check(packet.titleBindings.accepted.isEmpty && packet.titleBindings.held.count == 3,"auto-approved")
        try check(TitleSupportAssessment.assess(e,approved:false).status == .supportedButUnreviewed,"support not assessed")
        let review = try SyntheticStationEvidence.review(e), records = RailNameRecords(titles:[try SyntheticStationEvidence.review(e)])
        let first = try RailNames.build(input,records:records)
        try check(first.titleBindings.accepted[e.source] == review,"explicit review rejected")
        let repeatRun = try RailNames.build(input,records:records,previousNames:first.history,previousTitles:first.titleBindings.history)
        try check(NetworkJSON.encode(first.titleBindings.history) == NetworkJSON.encode(repeatRun.titleBindings.history),"history duplicated")
        var changedRows = SyntheticStationEvidence.rows();changedRows[0]["dc:date"] = "2099-02-01T00:00:00Z"
        let changed = try SyntheticStationEvidence.input(changedRows)
        let carried = try RailNames.build(changed,records:records,previousNames:first.history,previousTitles:first.titleBindings.history)
        try check(carried.titleBindings.accepted.count == 1 && carried.titleBindings.history.choices.count == 1 && carried.titleBindings.history.validations.count == 2,"unchanged evidence did not carry")
        let absent = try RailNames.build(SyntheticStationEvidence.input(nil),records:records,previousTitles:first.titleBindings.history)
        try check(absent.titleBindings.accepted.isEmpty,"omitted source survived")
        try check(try input.registry.encoded() == changed.registry.encoded(),"registry changed")
    }),
    ("station evidence: missing codes unknown scalar references and scope conflicts", { _ in
        for (field,value,status) in [("odpt:stationCode","",StationCodeEvidence.Status.missing),("odpt:stationCode","nonexistent",.missing),("owl:sameAs","different",.missing),("odpt:operator","other",.conflicting),("odpt:railway","other",.conflicting)] {
            var rows = SyntheticStationEvidence.rows(); rows[0][field] = value
            let e = try SyntheticStationEvidence.evidence(SyntheticStationEvidence.input(rows))
            try check(e.stationCodes?.status == status,"incorrect status for \(field)")
        }
        var rows = SyntheticStationEvidence.rows();rows[0]["odpt:stationCode"] = "syn-a1-codeé"
        let composed = try SyntheticStationEvidence.snapshot(rows); rows[0]["odpt:stationCode"] = "syn-a1-codee\u{301}"
        let decomposed = try SyntheticStationEvidence.snapshot(rows)
        try check(composed.rows[0].code != decomposed.rows[0].code,"codes normalized")
        rows[0]["owl:sameAs"] = "urn:invented:é";rows[1]["owl:sameAs"] = "urn:invented:e\u{301}"
        let exact = try SyntheticStationEvidence.snapshot(rows)
        try check(Set(exact.rows.map(\.sameAs)).count == 3,"references collapsed")
    }),
    ("station evidence: duplicate identifiers code conflicts and ambiguous targets", { _ in
        for mode in 0..<3 {
            var rows = SyntheticStationEvidence.rows()
            if mode == 0 { rows.append(rows[0]) }
            if mode == 1 { rows[1]["@id"] = rows[0]["@id"] }
            if mode == 2 { rows[1]["odpt:stationCode"] = rows[0]["odpt:stationCode"] }
            let e = try SyntheticStationEvidence.evidence(SyntheticStationEvidence.input(rows))
            try check(e.stationCodes?.status == .conflicting && e.stationCodes!.rows.count > 1,"conflict lost")
        }
        let input = try SyntheticStationEvidence.input();let e = try SyntheticStationEvidence.evidence(input)
        let m = e.candidates.first { $0.stationID == SyntheticNetwork.stn(1) }!.members[0]
        let alternate = TitleTarget(stationID:SyntheticNetwork.stn(2),members:[m],neighbours:[],lineScopes:[])
        let competing = TitleEvidence(source:e.source,occurrences:e.occurrences,candidates:e.candidates+[alternate],crosswalks:[],inputSHA256:e.inputSHA256,registrySHA256:e.registrySHA256)
        let proof = input.stationEvidence!.assess(competing,catalog:try RailNameCatalog(input))
        try check(proof.status == .ambiguous && Set(proof.matches.map(\.stationID)).count == 2,"multiple targets guessed")
    }),
    ("station evidence: conflict cannot fall back to manual crosswalk", { _ in
        var rows = SyntheticStationEvidence.rows();rows[0]["odpt:operator"] = "wrong"
        let input = try SyntheticStationEvidence.input(rows), crosswalks = [SyntheticNames.crosswalk(1)]
        let e = try RailwayTitleBindings.evidence(RailNameCatalog(input),crosswalks:crosswalks).first { $0.source == SyntheticNames.titleKey(1) }!
        let review = try SyntheticNames.titleReview(e,target:1)
        let result = try RailNames.build(input,records:.init(titles:[review],crosswalks:crosswalks))
        try check(result.titleBindings.accepted.isEmpty && TitleSupportAssessment.assess(e,approved:false).status == .conflicting,"conflict bypassed")
        let noInput = try SyntheticStationEvidence.evidence(SyntheticStationEvidence.input(nil))
        try check(TitleSupportAssessment.assess(noInput,approved:false).status == .unevaluated,"absence labelled as evaluated missing")
    }),
    ("station evidence: strict JSON hashes and repository input boundary", { w in
        let data = Data("[{\"@id\":\"a\",\"@id\":\"b\"}]".utf8)
        try SyntheticNames.expectFailure { _ = try StationEvidenceInput.read(data,sourceID:SyntheticNames.x("s"),railwaySourceID:SyntheticNames.x("r"),gtfsSourceID:SyntheticNames.x("g"),sha256:sha256Hex(data)) }
        try SyntheticNames.expectFailure { _ = try StationEvidenceInput.read(Data("[]".utf8),sourceID:SyntheticNames.x("s"),railwaySourceID:SyntheticNames.x("r"),gtfsSourceID:SyntheticNames.x("g"),sha256:String(repeating:"0",count:64)) }
        do { _ = try RailNameCommand.read(repositoryPath+"/AGENTS.md",root:testRepositoryRoot);throw TestFailure(message:"repository input accepted") }
        catch is IntakeError {} catch is ProvisionalRegistryError {}
        let url = try w.write(Data("[]".utf8),named:"station.json")
        try check(try RailNameCommand.read(url.path,root:testRepositoryRoot) == Data("[]".utf8),"external input rejected")
    })
]
