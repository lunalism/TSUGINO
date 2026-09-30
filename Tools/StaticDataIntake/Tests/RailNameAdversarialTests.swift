import Foundation

// One focused adversarial review: regressions for gaps found during that pass.
let railNameAdversarialTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("names: adversarial anchors cannot combine neighbours from unrelated line scopes", { _ in
        let input = try SyntheticNames.railwayInput();let records = try SyntheticNames.titleRecords(input,anchored:true)
        let good = try RailNames.build(input,records:records)
        let e = good.titleBindings.evidence.first { $0.source == SyntheticNames.titleKey(2) }!
        let targets = e.candidates.map { target in
            TitleTarget(stationID:target.stationID,members:target.members,neighbours:target.neighbours,lineScopes:[
                .init(lineID:SyntheticNetwork.lin(1),neighbours:[SyntheticNetwork.stn(1)]),
                .init(lineID:SyntheticNetwork.lin(2),neighbours:[SyntheticNetwork.stn(3)])])
        }
        let bad = TitleEvidence(source:e.source,occurrences:e.occurrences,candidates:targets,crosswalks:e.crosswalks,inputSHA256:e.inputSHA256,registrySHA256:e.registrySHA256)
        let direct = good.titleBindings.accepted.filter { $0.value.basis == .authoritativeCrosswalk }
        let review = try SyntheticNames.titleReview(bad,target:2,anchors:[SyntheticNames.titleKey(1),SyntheticNames.titleKey(3)],accepted:direct)
        try check(RailwayTitleBindings.anchoredHold(review,bad,direct:direct,all:good.titleBindings.evidence) == .bindingUnresolved,"union-only neighbour support accepted")
    }),
    ("names: adversarial new member invalidates an unchanged selected spelling", { _ in
        let input = try SyntheticNames.input();let old = try SyntheticNames.records(input)
        let refs = try input.registry.references.map { ref -> ProviderReference in
            guard ref.namespace == .gtfsStopID && ref.value == SyntheticNames.x("syn-a2") else { return ref }
            return try .init(canonicalID:SyntheticNetwork.stn(1),sourceID:ref.sourceID,namespace:ref.namespace,value:ref.value,status:ref.status,firstSeenInputSHA256:ref.firstSeenInputSHA256,provenance:ref.provenance,originalNames:ref.originalNames,attachedBy:"SYN-REVISED-BINDING")
        }
        let registry = try MappingRegistry(revision:2,entities:input.registry.entities,references:refs)
        let network = try NetworkArtifacts.build(input.sources.map(\.networkSide),registry:registry,coordinateRecords:[],topologyRecords:[],shapes:[])
        let held = try RailNames.build(SyntheticNames.replace(input,registry:registry,network:network),records:old)
        try check(held.statuses.contains { $0.entityID == SyntheticNetwork.stn(1) && $0.language == .ja && $0.heldBack == .relevantEvidenceChanged },"new member hidden behind stable spelling")
        try check(!held.complete,"identity change produced complete payload")
    }),
    ("names: adversarial subtitle rule cannot invent a different subtitle", { _ in
        let input = try SyntheticNames.input(rename:"Synthetic Base〈First〉");var records = try SyntheticNames.records(input)
        let e = records.names.first { $0.evidence.entityID == SyntheticNetwork.stn(1) && $0.evidence.language == .ja }!.evidence
        records.names.append(SyntheticNames.choice(e,id:"SYN-INVENTED-SUBTITLE",purpose:.alias,value:SyntheticNames.x("Synthetic Base〈Unpublished〉"),rule:.subtitleBracket))
        let held = try RailNames.build(input,records:records)
        try check(!held.complete && held.aliasStatuses[0].heldBack == .rationaleUnverifiable,"comparison rule authored an unsupported alias")
    }),
    ("names: adversarial title history cannot reactivate a superseded binding", { _ in
        let input = try SyntheticNames.railwayInput();let old = try SyntheticNames.titleRecords(input)
        let first = try RailNames.build(input,records:old)
        var next = old
        let binding = old.titles[0]
        next.titles[0] = try SyntheticNames.titleReview(binding.evidence,target:1,id:"SYN-BIND-NEW",supersedes:binding.reviewID)
        let second = try RailNames.build(input,records:next,previousNames:first.history,previousTitles:first.titleBindings.history)
        try SyntheticNames.expectFailure { _ = try RailNames.build(input,records:old,previousNames:second.history,previousTitles:second.titleBindings.history) }
    }),
]
