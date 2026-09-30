import Foundation

let railNameCommandTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("names: offline packet build repeat and publication boundaries", { w in
        var archives:[RailNameRun.Archive] = []
        var sources:[RailNameInput.Static] = []
        for side in 0..<2 {
            var tables = SyntheticNetwork.tables(SyntheticNames.model,side:side)
            var translations = "table_name,field_name,language,translation,field_value\n"
            for (table,field,values) in [("stops","stop_name",SyntheticNames.model.stations.flatMap { $0.rows.filter { $0.side == side }.map { "Synthetic \($0.stop)" } }), ("routes","route_long_name",["Synthetic Line"]),("agency","agency_name",["Synthetic Transit"])] {
                for value in values { for lang in ["en","ko"] {
                    translations += "\(table),\(field),\(lang),Synthetic \(lang) \(value),\(value)\n"
                } }
            }
            tables["translations.txt"] = translations
            let url = try w.write(ZipWriter.archive(tables.keys.sorted().map { ZipEntry($0,Data(tables[$0]!.utf8)) }),named:"names-\(side).zip")
            let a = try await ArchiveReading.read(requestedPath:url.path,resolvedPath:resolvedPath(url.path)!,checked:FileIdentity(path:url.path)!,repositoryRoot:testRepositoryRoot,limits:.standard)
            sources.append(.init(sourceID:SyntheticNetwork.sources[side],archive:a))
            archives.append(.init(sourceID:SyntheticNetwork.sources[side],path:url.path,sha256:a.sha256))
        }
        let registry = try SyntheticNames.registry(sources).encoded()
        let registryURL = try w.write(registry,named:"names-registry.json")
        let config = RailNameRun(schemaVersion:1,archives:archives,railways:[],historicalArchives:[],registryPath:registryURL.path,registrySHA256:sha256Hex(registry),networkRecordsPath:nil,shapes:[],documents:[])
        let configURL = try w.write(NetworkJSON.encode(config),named:"name-inputs.json")
        let input = try await RailNameCommand.load(config,root:testRepositoryRoot)
        let records = try SyntheticNames.records(input)
        let recordsURL = try w.write(NetworkJSON.encode(records),named:"reviewed-names.json")
        let packet = w.output.appendingPathComponent("packet")
        let p = try await RailNameCommand.run(configPath:configURL.path,recordsPath:nil,previousPath:nil,outputPath:packet.path,packetOnly:true,root:testRepositoryRoot)
        try check(!p.complete && p.heldNameSlots == 27,"packet selected names")
        let first = w.output.appendingPathComponent("first"), second = w.output.appendingPathComponent("second")
        let one = try await RailNameCommand.run(configPath:configURL.path,recordsPath:recordsURL.path,previousPath:nil,outputPath:first.path,packetOnly:false,root:testRepositoryRoot)
        try check(one.complete,"command did not construct")
        let two = try await RailNameCommand.run(configPath:configURL.path,recordsPath:recordsURL.path,previousPath:first.appendingPathComponent("history.json").path,outputPath:second.path,packetOnly:false,root:testRepositoryRoot)
        try check(two.complete && two.choices == one.choices && two.validations == one.validations,"history repeat")
        for filename in ["packet.json","report.json","history.json","names.json","index.json"] {
            try check(try Data(contentsOf:first.appendingPathComponent(filename)) == Data(contentsOf:second.appendingPathComponent(filename)),"repeat differs: \(filename)")
            let attributes = try FileManager.default.attributesOfItem(atPath:second.appendingPathComponent(filename).path)
            try check((attributes[.posixPermissions] as! NSNumber).intValue == 0o600,"non-private file")
        }
        try check(try Data(contentsOf:registryURL) == registry,"registry modified")
        do {
            _ = try await RailNameCommand.run(configPath:configURL.path,recordsPath:nil,previousPath:nil,outputPath:repositoryPath+"/name-boundary-must-not-exist",packetOnly:true,root:testRepositoryRoot)
            throw TestFailure(message:"repository output accepted")
        } catch is IntakeError {} catch is ProvisionalRegistryError {} // publication uses existing boundary errors
    }),
    ("names: superseded choice cannot be resurrected and broken validation chain fails", { _ in
        let input = try SyntheticNames.input();let old = try SyntheticNames.records(input);let first = try RailNames.build(input,records:old)
        var next = old
        next.names[0] = SyntheticNames.choice(old.names[0].evidence,id:"SYN-NEW",supersedes:old.names[0].reviewID)
        let second = try RailNames.build(input,records:next,previousNames:first.history)
        try SyntheticNames.expectFailure { _ = try RailNames.build(input,records:old,previousNames:second.history) }
        var bad = second.history
        let v = bad.validations[0]
        bad.validations[0] = .init(choiceID:v.choiceID,evidence:v.evidence,validatorVersion:1,dependencyChecks:v.dependencyChecks,evidenceSHA256:v.evidenceSHA256,previousValidationSHA256:"invented-invalid")
        try SyntheticNames.expectFailure { _ = try RailNames.build(input,records:next,previousNames:bad) }
    }),
    ("names: explicit aliases preserve whitespace both originals and omitted alias holdback", { _ in
        let input = try SyntheticNames.input(rename:"SyntheticヶHill〈View〉");var records = try SyntheticNames.records(input)
        let e = records.names.first { $0.evidence.entityID == SyntheticNetwork.stn(1) && $0.evidence.language == .ja }!.evidence
        records.names.append(SyntheticNames.choice(e,id:"SYN-ALIAS",purpose:.alias,value:SyntheticNames.x("SyntheticヶHill"),rule:.subtitleBracket))
        records.names.append(SyntheticNames.choice(e,id:"SYN-ALIAS-KE",purpose:.alias,value:SyntheticNames.x("SyntheticケHill〈View〉"),rule:.orthographicKe))
        let first = try RailNames.build(input,records:records)
        try check(first.complete && first.index!.stations(matching:"SyntheticヶHill").count == 1,"explicit rule alias absent")
        try check(first.index!.stations(matching:"SyntheticケHill〈View〉").count == 1,"orthographic alias absent")
        try check(first.index!.stations(matching:" SyntheticヶHill").isEmpty,"query trimmed")
        let held = try RailNames.build(input,records:.init(names:records.names.filter { $0.purpose == .name }),previousNames:first.history)
        try check(!held.complete && held.aliasStatuses.filter { $0.heldBack != nil }.count == 2,"alias silently removed")
    }),
    ("names: authored provenance is explicit and changed lineage holds", { _ in
        let input = try SyntheticNames.input();let packet = try RailNames.build(input,records:.init())
        let base = packet.evidence.first { $0.entityID == SyntheticNetwork.stn(1) && $0.language == .ja }!.candidates[0]
        let authored = AuthoredRailName(id:SyntheticNames.x("SYN-AUTHORED"),entityID:SyntheticNetwork.stn(1),language:.ko,value:SyntheticNames.x("Invented Korean placeholder"),author:SyntheticNames.x("Synthetic author"),reviewer:SyntheticNames.x("Synthetic reviewer"),approvalID:SyntheticNames.x("SYN-APPROVAL"),method:.human,reason:SyntheticNames.x("Synthetic provenance exercise"),authorizationReferences:[SyntheticNames.x("Synthetic authorization only")],lineage:[base.key])
        let draft = try RailNames.build(input,records:.init(authored:[authored]))
        let choices = draft.evidence.map { e -> NameChoice in
            if e.entityID == authored.entityID && e.language == .ko {
                return SyntheticNames.choice(e,candidate:e.candidates.first { $0.authorship != nil }!,basis:.authoredApproval)
            }
            return SyntheticNames.choice(e)
        }
        let records = RailNameRecords(names:choices,authored:[authored])
        let result = try RailNames.build(input,records:records)
        try check(result.complete,"authored evidence rejected")
        try check(result.history.choices.contains { $0.evidence.candidates.contains { $0.authorship == authored } },"authorship lost")
        let changed = try RailNames.build(SyntheticNames.input(rename:"Synthetic Changed"),records:records,previousNames:result.history)
        try check(!changed.complete && changed.statuses.contains { $0.entityID == authored.entityID && $0.language == .ko && $0.heldBack == .relevantEvidenceChanged },"changed authored lineage reused")
    }),
]
