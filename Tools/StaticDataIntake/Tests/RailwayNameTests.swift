import Foundation

extension SyntheticNames {
    static let railwaySource = "SYN-03/editorial"
    static func titleKey(_ n:Int) -> EditorialStationKey { .init(sourceID:x(railwaySource),stationReference:x("urn:synthetic:station:\(n)")) }
    static func railwayInput(hash:String = String(repeating:"f",count:64), duplicate:Bool = false, branch:Bool = false) throws -> RailNameInput {
        let base = try input()
        var refs = base.registry.references
        func attach(_ ns:ProviderNamespace,_ key:String,_ id:MintedIdentifier) throws {
            refs.append(try .init(canonicalID:id,sourceID:railwaySource,namespace:ns,value:x(key),status:.active,
                firstSeenInputSHA256:hash,provenance:.init(inputSHA256:hash,member:nil,table:nil,recordIndex:0,field:ns == .odptOperator ? "odpt:operator" : ns == .odptRailwayID ? "@id" : "owl:sameAs",providerKey:x(key)),originalNames:[],attachedBy:"SYN-TITLE-LINE"))
        }
        try attach(.odptRailwayID,"urn:synthetic:railway:1",SyntheticNetwork.lin(1))
        try attach(.odptRailwaySameAs,"synthetic:railway:1",SyntheticNetwork.lin(1))
        try attach(.odptOperator,"synthetic:operator:1",SyntheticNetwork.id("opr",1))
        var stations = (1...3).map { n in ODPTStationOrderEntry(index:n,station:titleKey(n).stationReference.text,
            title:.init(entries:[.init(language:"ja",text:"Synthetic Title \(n)"),.init(language:"en",text:"Synthetic English \(n)")])) }
        if duplicate { stations.append(stations[0]) }
        var rails = [ODPTRailway(id:"urn:synthetic:railway:1",sameAs:"synthetic:railway:1",operatorReference:"synthetic:operator:1",lineCode:"SYN",title:.init(entries:[.init(language:"en",text:"Synthetic Railway")]),color:nil,ascendingRailDirection:nil,descendingRailDirection:nil,stationOrder:stations)]
        if branch {
            try attach(.odptRailwayID,"urn:synthetic:railway:branch",SyntheticNetwork.lin(1))
            try attach(.odptRailwaySameAs,"synthetic:railway:branch",SyntheticNetwork.lin(1))
            rails.append(.init(id:"urn:synthetic:railway:branch",sameAs:"synthetic:railway:branch",operatorReference:"synthetic:operator:1",lineCode:"SYN",title:.init(entries:[.init(language:"en",text:"Synthetic Branch")]),color:nil,ascendingRailDirection:nil,descendingRailDirection:nil,stationOrder:[stations[1],stations[2]]))
        }
        let reg = try MappingRegistry(revision:2,entities:base.registry.entities,references:refs)
        return .init(sources:base.sources,railways:[.init(sourceID:railwaySource,sha256:hash,records:rails)],historical:[],registry:reg,registrySHA256:sha256Hex(try reg.encoded()),network:base.network,documents:[x("synthetic-crosswalk"):String(repeating:"9",count:64)])
    }
    static func crosswalk(_ n:Int, stop:Int? = nil, id:String? = nil) -> TitleCrosswalk {
        .init(id:x(id ?? "SYN-XW-\(n)"),source:titleKey(n),gtfsSourceID:x(SyntheticNetwork.sources[0]),stopID:x("syn-a\(stop ?? n)"),documentID:x("synthetic-crosswalk"),documentSHA256:String(repeating:"9",count:64),citation:x("Invented assertion \(n)"),reviewer:x("Synthetic reviewer"),reason:x("Invented explicit source-to-member crosswalk"))
    }
    static func titleReview(_ e:TitleEvidence, target:Int, anchors:[EditorialStationKey] = [], accepted:[EditorialStationKey:TitleBindingReview] = [:], id:String? = nil, supersedes:ExactValue? = nil) throws -> TitleBindingReview {
        try RailNameSelections.Title(reviewID:x(id ?? "SYN-BIND-\(target)"),reviewer:x("Synthetic reviewer"),date:x("2099-01-01"),supersedes:supersedes,source:e.source,stationID:SyntheticNetwork.stn(target),reason:x("Synthetic unique non-name support"),basis:anchors.isEmpty ? .authoritativeCrosswalk : .anchoredNeighbours,anchors:anchors).template(e,accepted:accepted)
    }
    static func titleRecords(_ input:RailNameInput, anchored:Bool = false) throws -> RailNameRecords {
        let xw = (anchored ? [1,3] : [1,2,3]).map { crosswalk($0) }
        let packet = try RailNames.build(input,records:.init(crosswalks:xw))
        var titles:[TitleBindingReview] = []
        for n in (anchored ? [1,3] : [1,2,3]) {
            titles.append(try titleReview(packet.titleBindings.evidence.first { $0.source == titleKey(n) }!,target:n))
        }
        if anchored {
            let direct = try RailNames.build(input,records:.init(titles:titles,crosswalks:xw))
            titles.append(try titleReview(packet.titleBindings.evidence.first { $0.source == titleKey(2) }!,target:2,anchors:[titleKey(1),titleKey(3)],accepted:direct.titleBindings.accepted))
        }
        let resolved = try RailNames.build(input,records:.init(titles:titles,crosswalks:xw))
        return .init(names:resolved.evidence.map { choice($0) },titles:titles,crosswalks:xw)
    }
}

let railwayNameTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("names: Railway titles require supported editorial bindings without registry mutation", { _ in
        let input = try SyntheticNames.railwayInput();let before = try input.registry.encoded()
        let pending = try RailNames.build(input,records:.init())
        try check(pending.titleBindings.held.count == 3 && !pending.complete,"names established identity")
        let records = try SyntheticNames.titleRecords(input)
        let result = try RailNames.build(input,records:records)
        try check(result.complete && result.titleBindings.accepted.count == 3,"direct bindings failed")
        try check(try input.registry.encoded() == before,"registry changed")
        try check(result.evidence.filter { $0.entityID == SyntheticNetwork.stn(1) && $0.language == .en }[0].candidates.count == 2,"alternative title lost")
    }),
    ("names: anchored correspondence requires two independent direct anchors", { _ in
        let input = try SyntheticNames.railwayInput();let records = try SyntheticNames.titleRecords(input,anchored:true)
        let first = try RailNames.build(input,records:records)
        try check(first.complete,"anchored target unresolved")
        let again = try RailNames.build(input,records:records,previousNames:first.history,previousTitles:first.titleBindings.history)
        try check(NetworkJSON.encode(first.titleBindings.history) == NetworkJSON.encode(again.titleBindings.history),"title history duplicated")
        let withoutAnchor = RailNameRecords(names:records.names,titles:records.titles.filter { $0.evidence.source != SyntheticNames.titleKey(1) },crosswalks:records.crosswalks)
        let held = try RailNames.build(input,records:withoutAnchor)
        try check(held.titleBindings.held[SyntheticNames.titleKey(2)] == .rationaleUnverifiable,"missing/circular anchor allowed")
    }),
    ("names: conflicting crosswalk and out-of-scope target never choose best guess", { _ in
        let input = try SyntheticNames.railwayInput();let records = try SyntheticNames.titleRecords(input)
        let conflicts = records.crosswalks + [SyntheticNames.crosswalk(1,stop:2,id:"SYN-CONFLICT")]
        let packet = try RailNames.build(input,records:.init(crosswalks:conflicts))
        let bad = try SyntheticNames.titleReview(packet.titleBindings.evidence.first { $0.source == SyntheticNames.titleKey(1) }!,target:1)
        let result = try RailNames.build(input,records:.init(titles:[bad],crosswalks:conflicts))
        try check(result.titleBindings.held[SyntheticNames.titleKey(1)] == .bindingUnresolved,"conflicting support accepted")
        let outside = try SyntheticNames.titleReview(packet.titleBindings.evidence.first { $0.source == SyntheticNames.titleKey(1) }!,target:5)
        let wrong = try RailNames.build(input,records:.init(titles:[outside],crosswalks:conflicts))
        try check(wrong.titleBindings.held[SyntheticNames.titleKey(1)] == .unknownEntity,"cross-line target imported")
    }),
    ("names: complete branch occurrence scope retained and changed occurrence held", { _ in
        let base = try SyntheticNames.railwayInput();let old = try SyntheticNames.titleRecords(base)
        let branch = try SyntheticNames.railwayInput(branch:true)
        let stale = try RailNames.build(branch,records:old)
        try check(!stale.complete && stale.titleBindings.held[SyntheticNames.titleKey(2)] == .relevantEvidenceChanged,"new branch occurrence omitted")
        let fresh = try RailNames.build(branch,records:SyntheticNames.titleRecords(branch))
        try check(fresh.complete && fresh.titleBindings.evidence.first { $0.source == SyntheticNames.titleKey(2) }!.occurrences.count == 2,"legitimate overlap collapsed")
    }),
    ("names: duplicate title source occurrence fails closed", { _ in
        let input = try SyntheticNames.railwayInput(duplicate:true)
        try SyntheticNames.expectFailure { _ = try SyntheticNames.titleRecords(input) }
    }),
    ("names: changed Railway bytes unchanged evidence retains reviewed choice", { _ in
        let firstInput = try SyntheticNames.railwayInput();let records = try SyntheticNames.titleRecords(firstInput,anchored:true)
        let first = try RailNames.build(firstInput,records:records)
        let next = try RailNames.build(SyntheticNames.railwayInput(hash:String(repeating:"8",count:64)),records:records,previousNames:first.history,previousTitles:first.titleBindings.history)
        try check(next.complete && next.titleBindings.history.choices == first.titleBindings.history.choices,"hash-only change demanded review")
        try check(next.titleBindings.history.validations.count == 6,"new sighting lost")
    }),
]
