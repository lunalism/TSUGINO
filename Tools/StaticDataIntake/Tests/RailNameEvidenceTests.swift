import Foundation

extension SyntheticNames {
    static func replace(_ input:RailNameInput,sources:[RailNameInput.Static]? = nil,registry:MappingRegistry? = nil,network:NetworkResult? = nil,historical:[RailNameInput.Static]? = nil) throws -> RailNameInput {
        let registry = registry ?? input.registry
        return .init(sources:sources ?? input.sources,railways:input.railways,historical:historical ?? input.historical,registry:registry,registrySHA256:sha256Hex(try registry.encoded()),network:network ?? input.network,documents:input.documents)
    }
    static func translations(_ input:RailNameInput,_ transform:([GTFSTranslation])->[GTFSTranslation]) -> [RailNameInput.Static] {
        input.sources.enumerated().map { side,s in
            guard side == 0 else { return s }
            let f = s.archive.feed
            let feed = GTFSStaticFeed(agencies:f.agencies,stops:f.stops,routes:f.routes,trips:f.trips,stopTimes:f.stopTimes,calendars:f.calendars,calendarDates:f.calendarDates,feedInfo:f.feedInfo,translations:transform(f.translations))
            return .init(sourceID:s.sourceID,archive:.init(sha256:s.archive.sha256,byteCount:s.archive.byteCount,selectedMembers:s.archive.selectedMembers,unselectedMembers:s.archive.unselectedMembers,feed:feed))
        }
    }
}
let railNameEvidenceTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("names: missing selected language and changed alternatives hold exact slots", { _ in
        let input = try SyntheticNames.input();let records = try SyntheticNames.records(input)
        let source = SyntheticNames.translations(input) { $0.filter { !($0.language == "en" && $0.fieldValue == "Synthetic syn-a1") } }
        let held = try RailNames.build(SyntheticNames.replace(input,sources:source),records:records)
        try check(!held.complete && held.statuses.contains { $0.entityID == SyntheticNetwork.stn(1) && $0.language == .en && $0.heldBack == .selectedMissing },"missing selection substituted")
        let more = SyntheticNames.translations(input) { $0 + [.init(tableName:"stops",fieldName:"stop_name",language:"ja",translation:"Synthetic alternative",fieldValue:"Synthetic syn-a1")] }
        let changed = try RailNames.build(SyntheticNames.replace(input,sources:more),records:records)
        try check(changed.statuses.contains { $0.entityID == SyntheticNetwork.stn(1) && $0.language == .ja && $0.heldBack == .relevantEvidenceChanged },"unchanged spelling concealed new alternative")
    }),
    ("names: stale active member provenance and unreconciled absent references fail", { _ in
        let input = try SyntheticNames.input();let refs = input.registry.references
        let old = refs[0]
        let stale = try ProviderReference(canonicalID:old.canonicalID,sourceID:old.sourceID,namespace:old.namespace,value:old.value,status:.active,firstSeenInputSHA256:old.firstSeenInputSHA256,
            provenance:.init(inputSHA256:old.provenance.inputSHA256,member:.init(name:old.provenance.member!.name,sha256:String(repeating:"0",count:64)),table:old.provenance.table,recordIndex:nil,field:old.provenance.field,providerKey:old.provenance.providerKey),originalNames:old.originalNames,attachedBy:old.attachedBy)
        let registry = try MappingRegistry(revision:input.registry.revision,entities:input.registry.entities,references:[stale]+Array(refs.dropFirst()))
        try SyntheticNames.expectFailure { _ = try RailNames.build(SyntheticNames.replace(input,registry:registry),records:.init()) }
        let stationRef = refs.first { $0.namespace == .gtfsStopID }!
        let missing = try ProviderReference(canonicalID:stationRef.canonicalID,sourceID:old.sourceID,namespace:.gtfsStopID,value:SyntheticNames.x("synthetic-absent-row"),status:.active,firstSeenInputSHA256:old.firstSeenInputSHA256,provenance:old.provenance,originalNames:[],attachedBy:"SYN-ABSENT")
        let bad = try MappingRegistry(revision:1,entities:input.registry.entities,references:refs+[missing])
        try SyntheticNames.expectFailure { _ = try RailNames.build(SyntheticNames.replace(input,registry:bad),records:.init()) }
    }),
    ("names: held network shape blocks complete Domain construction", { _ in
        let input = try SyntheticNames.input()
        let network = try NetworkArtifacts.build(input.sources.map(\.networkSide),registry:input.registry,coordinateRecords:[],topologyRecords:[],shapes:[(SyntheticNetwork.lin(1),.loopPlusTail)])
        let result = try RailNames.build(SyntheticNames.replace(input,network:network),records:SyntheticNames.records(input))
        try check(!result.complete && result.stations.isEmpty && result.index == nil,"bad shape ignored")
    }),
    ("names: historical alias requires retained exact source and current binding", { _ in
        let old = try SyntheticNames.input(hash:String(repeating:"7",count:64),rename:"Synthetic Past")
        let current = try SyntheticNames.input(rename:"Synthetic Present")
        let oldEvidence = try RailNames.build(old,records:.init()).evidence
        let refs = try current.registry.references.map { ref -> ProviderReference in
            let names = oldEvidence.filter { $0.entityID == ref.canonicalID }.flatMap(\.candidates).filter { $0.key.providerKey == ref.value }.map { c in
                OriginalName(language:SyntheticNames.x(c.key.language.rawValue),value:c.value,source:c.sightings[0].reference)
            }
            return try .init(canonicalID:ref.canonicalID,sourceID:ref.sourceID,namespace:ref.namespace,value:ref.value,status:ref.status,firstSeenInputSHA256:ref.firstSeenInputSHA256,provenance:ref.provenance,originalNames:names,attachedBy:ref.attachedBy)
        }
        let registry = try MappingRegistry(revision:2,entities:current.registry.entities,references:refs)
        let input = try SyntheticNames.replace(current,registry:registry,historical:[old.sources[0]])
        var records = try SyntheticNames.records(input)
        let e = records.names.first { $0.evidence.entityID == SyntheticNetwork.stn(1) && $0.evidence.language == .ja }!.evidence
        let past = e.candidates.first { $0.key.historicalInput != nil }!
        records.names.append(SyntheticNames.choice(e,candidate:past,id:"SYN-PAST-ALIAS",purpose:.alias,basis:.historicalAlias))
        let first = try RailNames.build(input,records:records)
        try check(first.complete && first.index!.stations(matching:"Synthetic Past").count == 1,"explicit past alias missing")
        let held = try RailNames.build(SyntheticNames.replace(input,historical:[]),records:records,previousNames:first.history)
        try check(!held.complete && held.aliasStatuses.contains { $0.heldBack == .selectedMissing },"unverified historical source retained")
    }),
]
