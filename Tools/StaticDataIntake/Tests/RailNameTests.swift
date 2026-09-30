import Foundation

// All input names, IDs, reviews, crosswalks and translations are invented.
// These fixtures do not read owner evidence and assert no real permission.
enum SyntheticNames {
    static func x(_ text:String) -> ExactValue { ExactValue(text)! }
    static let model = SyntheticNetwork.Model(stations:[
        SyntheticNetwork.single(1,"syn-a1"), SyntheticNetwork.single(2,"syn-a2"),SyntheticNetwork.single(3,"syn-a3"),
        SyntheticNetwork.single(4,"syn-b1",side:1),SyntheticNetwork.single(5,"syn-b2",side:1)
    ],lines:[
        .init(id:SyntheticNetwork.lin(1),side:0,route:"syn-ra",trips:[.init(stops:["syn-a1","syn-a2","syn-a3"])]),
        .init(id:SyntheticNetwork.lin(2),side:1,route:"syn-rb",trips:[.init(stops:["syn-b1","syn-b2"])])
    ])
    static func registry(_ sources: [RailNameInput.Static]) throws -> MappingRegistry {
        let old = SyntheticNetwork.registry(model,archives:sources.map { $0.archive.sha256 })
        var refs: [ProviderReference] = []
        for ref in old.references {
            let source = sources.first { $0.sourceID == ref.sourceID }!
            let table = ref.namespace == .gtfsStopID ? "stops" : "routes"
            let provenance = try SourceReference(inputSHA256:source.archive.sha256,member:.init(name:table+".txt",sha256:source.archive.memberSHA256(table+".txt")!),table:table,recordIndex:nil,field:ref.namespace == .gtfsStopID ? "stop_id" : "route_id",providerKey:ref.value)
            refs.append(try ProviderReference(canonicalID:ref.canonicalID,sourceID:ref.sourceID,namespace:ref.namespace,value:ref.value,status:.active,firstSeenInputSHA256:source.archive.sha256,provenance:provenance,originalNames:[],attachedBy:"SYN-REVIEW"))
        }
        var entities = old.entities
        for (side,source) in sources.enumerated() {
            let id = SyntheticNetwork.id("opr",side+1), key = x("syn-agency-\(side)")
            entities.append(.init(id:id,status:.active))
            let provenance = try SourceReference(inputSHA256:source.archive.sha256,member:.init(name:"agency.txt",sha256:source.archive.memberSHA256("agency.txt")!),table:"agency",recordIndex:nil,field:"agency_id",providerKey:key)
            refs.append(try .init(canonicalID:id,sourceID:source.sourceID,namespace:.gtfsAgencyID,value:key,status:.active,firstSeenInputSHA256:source.archive.sha256,provenance:provenance,originalNames:[],attachedBy:"SYN-OP"))
        }
        return try MappingRegistry(revision:1,entities:entities,references:refs)
    }
    static func input(hash:String = String(repeating:"a",count:64), rename:String? = nil, reversed:Bool = false) throws -> RailNameInput {
        let feeds = SyntheticNetwork.feeds(model,reversed:reversed)
        let sources = feeds.enumerated().map { side,feed -> RailNameInput.Static in
            let stops = feed.stops.map { s in GTFSStop(stopID:s.stopID,stopCode:nil,name:s.stopID == "syn-a1" ? rename ?? s.name : s.name,latitude:s.latitude,longitude:s.longitude,locationType:nil,parentStation:nil,platformCode:nil) }
            var translations:[GTFSTranslation] = []
            for (table,field,names) in [("stops","stop_name",stops.map(\.name)),("routes","route_long_name",["Synthetic Line"]),("agency","agency_name",["Synthetic Transit"])] {
                for name in names { for lang in ["en","ko"] { translations.append(.init(tableName:table,fieldName:field,language:lang,translation:"Synthetic \(lang) \(name)",fieldValue:name)) } }
            }
            let f = GTFSStaticFeed(agencies:feed.agencies,stops:stops,routes:feed.routes,trips:feed.trips,stopTimes:feed.stopTimes,calendars:feed.calendars,calendarDates:feed.calendarDates,feedInfo:feed.feedInfo,translations:translations)
            let members = ["agency","stops","routes","trips","stop_times","translations"].map { SourceManifest.SelectedMember(name:$0+".txt",byteCount:1,sha256:String(repeating:side == 0 ? "c" : "d",count:64)) }
            return .init(sourceID:SyntheticNetwork.sources[side],archive:.init(sha256:side == 0 ? hash : String(repeating:"b",count:64),byteCount:1,selectedMembers:members,unselectedMembers:[],feed:f))
        }
        let reg = try registry(sources)
        let network = try NetworkArtifacts.build(sources.map(\.networkSide),registry:reg,coordinateRecords:[],topologyRecords:[],shapes:[])
        return .init(sources:sources,railways:[],historical:[],registry:reg,registrySHA256:sha256Hex(try reg.encoded()),network:network,documents:[:])
    }
    static func choice(_ e: NameEvidence, candidate: NameCandidate? = nil, id: String? = nil, purpose:NameChoice.Purpose = .name,
                       value:ExactValue? = nil, rule:StationAliasRule? = nil, basis:NameChoice.Basis = .publishedMember, supersedes:ExactValue? = nil) -> NameChoice {
        let c = candidate ?? e.candidates.first { $0.key.historicalInput == nil }!
        return RailNameSelections.Name(reviewID:x(id ?? "SYN-\(e.entityID.rawValue)-\(e.language.rawValue)"),reviewer:x("Synthetic reviewer"),date:x("2099-01-01"),supersedes:supersedes,
            entityID:e.entityID,language:e.language,purpose:purpose,selected:c.key,value:value ?? c.value,reason:x("Synthetic fixed source choice"),basis:basis,preferredSource:nil,aliasRule:rule).template(e)
    }
    static func records(_ input: RailNameInput) throws -> RailNameRecords {
        .init(names:try RailNames.build(input,records:.init()).evidence.map { choice($0) })
    }
    static func expectFailure(_ body: () throws -> Void) throws {
        do { try body() } catch is NameReviewError { return }
        throw TestFailure(message:"expected named validation error")
    }
}

let railNameTests: [(name: String, body: (Workspace) async throws -> Void)] = [
    ("names: complete synthetic Domain construction and exact lookup", { _ in
        let input = try SyntheticNames.input(); let result = try RailNames.build(input,records:SyntheticNames.records(input))
        try check(result.complete,"not complete")
        try check(result.stations.count == 5 && result.lines.count == 2 && result.operators.count == 2,"wrong construction")
        for station in result.stations { for text in [station.name.japanese,station.name.english,station.name.korean] {
            try check(result.index!.stations(matching:text).contains { $0.station.id == station.id },"name not indexed")
        } }
        try check(result.index!.stations(matching:"").isEmpty && result.index!.stations(matching:"  ").isEmpty,"blank query")
        try check(result.index!.stations(matching:"Synthetic").isEmpty,"prefix match escaped")
    }),
    ("names: composed and decomposed values remain distinct through Domain and lookup", { _ in
        let a = LocalizedRailName(japanese:"Synthetic",english:"Caf\u{e9}",korean:"가상")!
        let b = LocalizedRailName(japanese:"Synthetic",english:"Cafe\u{301}",korean:"가상")!
        try check(a != b && Set([a,b]).count == 2,"Domain collapsed Unicode")
        let input = try SyntheticNames.input(rename:"Caf\u{e9}")
        let result = try RailNames.build(input,records:SyntheticNames.records(input))
        try check(result.index!.stations(matching:"Caf\u{e9}").count == 1,"exact match missing")
        try check(result.index!.stations(matching:"Cafe\u{301}").isEmpty,"canonical equivalence leaked")
        let data = NetworkJSON.encode(a);let decoded = try JSONDecoder().decode(LocalizedRailName.self,from:data)
        try check(decoded == a && decoded != b,"round trip")
    }),
    ("names: changed archive unchanged evidence carries with append-only provenance", { _ in
        let a = try SyntheticNames.input();let records = try SyntheticNames.records(a);let first = try RailNames.build(a,records:records)
        let b = try SyntheticNames.input(hash:String(repeating:"e",count:64))
        let second = try RailNames.build(b,records:records,previousNames:first.history)
        try check(second.complete,"unchanged meaning held back")
        try check(second.history.choices == first.history.choices,"choice rewritten")
        try check(second.history.validations.count > first.history.validations.count,"new provenance absent")
        try check(Array(second.history.validations.prefix(first.history.validations.count)) == first.history.validations,"history prefix lost")
        let repeatRun = try RailNames.build(b,records:records,previousNames:second.history)
        try check(NetworkJSON.encode(repeatRun.history) == NetworkJSON.encode(second.history),"duplicate history")
        try check(NetworkJSON.encode(NamedNetworkArtifact(second)) == NetworkJSON.encode(NamedNetworkArtifact(repeatRun)),"nondeterministic Domain export")
    }),
    ("names: selected change holds back with no silent substitution; failed sightings persist", { _ in
        let a = try SyntheticNames.input();let records = try SyntheticNames.records(a);let first = try RailNames.build(a,records:records)
        let b = try SyntheticNames.input(hash:String(repeating:"e",count:64),rename:"Synthetic Changed")
        let second = try RailNames.build(b,records:records,previousNames:first.history)
        try check(!second.complete && second.stations.isEmpty,"constructed incomplete names")
        try check(second.statuses.contains { $0.heldBack == .valueChanged },"change not reported")
        try check(second.history.observations.count > first.history.observations.count,"failed sighting lost")
    }),
    ("names: explicit new review supersedes without replacing history", { _ in
        let a = try SyntheticNames.input();let old = try SyntheticNames.records(a);let first = try RailNames.build(a,records:old)
        let b = try SyntheticNames.input(hash:String(repeating:"e",count:64),rename:"Synthetic Changed")
        let packet = try RailNames.build(b,records:.init())
        var choices = old.names
        for (i,review) in old.names.enumerated() where review.evidence.entityID == SyntheticNetwork.stn(1) {
            let e = packet.evidence.first { $0.entityID == review.evidence.entityID && $0.language == review.evidence.language }!
            choices[i] = SyntheticNames.choice(e,id:review.reviewID.text+"-v2",supersedes:review.reviewID)
        }
        let result = try RailNames.build(b,records:.init(names:choices),previousNames:first.history)
        try check(result.complete && result.history.choices.count == first.history.choices.count+3,"replacement not appended")
    }),
    ("names: unused and duplicate reviews cannot complete", { _ in
        let input = try SyntheticNames.input();var records = try SyntheticNames.records(input)
        records.names.append(records.names[0]);try SyntheticNames.expectFailure { _ = try RailNames.build(input,records:records) }
    }),
    ("names: byte-identical output under raw row reordering", { _ in
        let a = try SyntheticNames.input();let b = try SyntheticNames.input(reversed:true);let records = try SyntheticNames.records(a)
        let first = try RailNames.build(a,records:records);let second = try RailNames.build(b,records:records)
        try check(first.complete && second.complete,"reorder changed review")
        try check(NetworkJSON.encode(first.history) == NetworkJSON.encode(second.history),"reordered history")
    }),
]
