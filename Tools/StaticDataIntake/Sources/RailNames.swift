import Foundation

struct RailNameOutcome {
    struct Status: Codable {
        let entityID: MintedIdentifier
        let language: RailNameLanguage
        let reviewID: ExactValue?
        let heldBack: NameHold?
    }
    let evidence: [NameEvidence]
    let statuses: [Status]
    let aliasStatuses: [Status]
    let titleBindings: TitleBindingResult
    let history: NameHistory
    let aliases: [ExactStationIndex.Alias]
    let operators: [Operator]
    let lines: [RailwayLine]
    let stations: [Station]
    let index: ExactStationIndex?
    let unusedReviews: Int
    let unusedAuthored: Int
    let unusedCrosswalks: Int
    let networkComplete: Bool
    var complete: Bool { index != nil && unusedReviews == 0 && unusedAuthored == 0 && unusedCrosswalks == 0 && titleBindings.held.isEmpty && statuses.allSatisfy { $0.heldBack == nil } && aliasStatuses.allSatisfy { $0.heldBack == nil } }
}
enum RailNames {
    static func build(_ input: RailNameInput, records: RailNameRecords, previousNames: NameHistory = .init(), previousTitles: TitleHistory = .init()) throws -> RailNameOutcome {
        try records.validate()
        var history = previousNames; try history.validate()
        let catalog = try RailNameCatalog(input)
        let titles = try RailwayTitleBindings.build(catalog,records:records,previous:previousTitles)
        var candidates = catalog.candidates
        var issues: [MintedIdentifier: Set<NameHold>] = [:]
        var bindingDigests: [MintedIdentifier: [String]] = [:]
        for e in titles.evidence {
            if let review = titles.accepted[e.source] {
                bindingDigests[review.stationID,default:[]].append(review.selectionEvidenceSHA256)
                for occurrence in e.occurrences {
                    for title in occurrence.titles {
                        guard let lang = RailNameLanguage(rawValue:title.language.text) else { continue }
                        candidates[review.stationID,default:[]].append(.init(key:.init(sourceID:e.source.sourceID,
                            namespace:try RailNameCatalog.exact("editorial.railwayTitle"),providerKey:e.source.stationReference,
                            parentKey:occurrence.railwayID,field:try RailNameCatalog.exact("odpt:stationTitle"),language:lang),
                            value:title.value,sightings:[occurrence.sighting],dependencySHA256:review.selectionEvidenceSHA256))
                    }
                }
            } else {
                for target in e.candidates { issues[target.stationID,default:[]].insert(.bindingUnresolved) }
            }
        }
        // Authored evidence is explicitly supplied and reviewed; this code
        // never produces a translation or assumes permission to do so.
        let publishedCandidates = candidates
        for authored in records.authored.sorted(by: { $0.id < $1.id }) {
            guard catalog.entityIDs.contains(authored.entityID) else { throw NameReviewError.unknownEntity }
            let base = publishedCandidates[authored.entityID] ?? []
            let lineage = authored.lineage.compactMap { key in base.first { $0.key == key } }
            guard lineage.count == authored.lineage.count else { issues[authored.entityID,default:[]].insert(.rationaleUnverifiable);continue }
            struct Dependencies: Encodable { let authored: AuthoredRailName; let lineage: [NameCandidate.Semantic] }
            let dep = NameDigest.of(Dependencies(authored:authored,lineage:lineage.map(\.semantic)))
            let source = try RailNameCatalog.exact("authored")
            let key = NameSourceKey(sourceID:source,namespace:source,providerKey:authored.id,parentKey:nil,
                field:try RailNameCatalog.exact("value"),language:authored.language)
            candidates[authored.entityID,default:[]].append(.init(key:key,value:authored.value,sightings:lineage.flatMap(\.sightings),dependencySHA256:dep,authorship:authored))
        }
        var evidence: [NameEvidence] = []
        for id in catalog.entityIDs {
            for lang in RailNameLanguage.allCases {
                let rows = (candidates[id] ?? []).filter { $0.key.language == lang }.sorted(by:NameCandidate.precedes)
                // Conflicting source cells are never silently resolved.
                guard Set(rows.map(\.key)).count == rows.count else { throw NameReviewError.duplicate }
                evidence.append(.init(entityID:id,language:lang,members:catalog.members[id] ?? [],candidates:rows,
                    bindingDependencies:(bindingDigests[id] ?? []).sorted(),issues:(issues[id] ?? []).sorted { $0.rawValue < $1.rawValue },
                    memberProvenance:catalog.provenance[id] ?? [],inputSHA256:catalog.inputHashes,registrySHA256:input.registrySHA256,
                    registryOriginals:input.registry.references.filter { $0.canonicalID == id }.flatMap { ref in
                        ref.originalNames.map { RetainedRailName(sourceID:ExactValue(ref.sourceID)!,namespace:ref.namespace,providerKey:ref.value,original:$0) }
                    }.sorted(by:RetainedRailName.precedes)))
            }
        }
        for e in evidence where !history.observations.contains(where: { NameDigest.of($0) == NameDigest.of(e) }) { history.observations.append(e) }
        var statuses: [RailNameOutcome.Status] = []
        var selected: [MintedIdentifier:[RailNameLanguage:ExactValue]] = [:]
        var used = Set<ExactValue>(), aliases: [ExactStationIndex.Alias] = []
        let sortedRecords = records.names.sorted { $0.reviewID < $1.reviewID }
        for review in sortedRecords { try history.retain(review) }
        for e in evidence {
            let review = sortedRecords.first { $0.purpose == .name && $0.evidence.entityID == e.entityID && $0.evidence.language == e.language }
            let hold = review.map { $0.hold(in:e) } ?? .some(.reviewRequired)
            statuses.append(.init(entityID:e.entityID,language:e.language,reviewID:review?.reviewID,heldBack:hold))
            if let review, hold == nil {
                selected[e.entityID,default:[:]][e.language] = review.value; used.insert(review.reviewID); history.append(review,evidence:e)
            }
        }
        var aliasStatuses: [RailNameOutcome.Status] = []
        let replaced = Set(history.choices.compactMap(\.supersedes))
        for old in history.choices where old.purpose == .alias && !replaced.contains(old.reviewID) && !sortedRecords.contains(where: { $0.reviewID == old.reviewID }) {
            aliasStatuses.append(.init(entityID:old.evidence.entityID,language:old.evidence.language,reviewID:old.reviewID,heldBack:.reviewRequired))
        }
        for review in sortedRecords where review.purpose == .alias {
            let current = evidence.first { $0.entityID == review.evidence.entityID && $0.language == review.evidence.language }
            let hold = current.map { review.hold(in:$0) } ?? .some(.unknownEntity)
            aliasStatuses.append(.init(entityID:review.evidence.entityID,language:review.evidence.language,reviewID:review.reviewID,heldBack:hold))
            if let e = current, hold == nil {
                aliases.append(.init(stationID:StationID(e.entityID.rawValue)!,value:review.value)); used.insert(review.reviewID);history.append(review,evidence:e)
            }
        }
        let usedAuthored = Set(sortedRecords.filter { used.contains($0.reviewID) && $0.selected.namespace.text == "authored" }.map { $0.selected.providerKey })
        let usedTitleIDs = Set(titles.accepted.values.map(\.reviewID))
        let usedCrosswalkIDs = Set(titles.evidence.filter { titles.accepted[$0.source] != nil }.flatMap(\.crosswalks).map(\.id))
        let unused = records.names.count-used.count + records.titles.count-usedTitleIDs.count
        let unusedAuthored = records.authored.count-usedAuthored.count
        let unusedCrosswalks = records.crosswalks.count-usedCrosswalkIDs.count
        func name(_ id: MintedIdentifier) -> LocalizedRailName? {
            guard let values = selected[id], let ja = values[.ja], let en = values[.en], let ko = values[.ko] else { return nil }
            return .init(japanese:ja.text,english:en.text,korean:ko.text)
        }
        let completeNames = catalog.entityIDs.allSatisfy { name($0) != nil }
        let completeNetwork = input.network.coordinates.allSatisfy { if case .selected = $0.outcome { return true };return false }
            && input.network.lines.allSatisfy { $0.topology != nil }
            && input.network.shapes.allSatisfy(\.passed) && input.network.unusedCoordinateRecords == 0 && input.network.unusedTopologyRecords == 0
        var operators: [Operator] = [], lines: [RailwayLine] = [], stations: [Station] = []
        var index: ExactStationIndex?
        if completeNames && completeNetwork && aliasStatuses.allSatisfy({ $0.heldBack == nil }) && unused == 0 && unusedAuthored == 0 && unusedCrosswalks == 0 && titles.held.isEmpty {
            operators = catalog.entityIDs.filter { $0.kind == .railwayOperator }.map { .init(id:OperatorID($0.rawValue)!,name:name($0)!) }
            for line in input.network.lines {
                guard let op = catalog.lineOperators[line.lineID] else { throw NameReviewError.incompleteNetwork }
                lines.append(.init(id:LineID(line.lineID.rawValue)!,operatorID:OperatorID(op.rawValue)!,name:name(line.lineID)!,topology:line.topology!))
            }
            for c in input.network.coordinates {
                guard case .selected(let point,_,_) = c.outcome else { throw NameReviewError.incompleteNetwork }
                stations.append(.init(id:StationID(c.stationID.rawValue)!,name:name(c.stationID)!,coordinate:point,
                    lineIDs:Set((input.network.membership[c.stationID] ?? []).map { LineID($0.rawValue)! })))
            }
            index = try ExactStationIndex(stations:stations,lines:lines,operators:operators,aliases:aliases)
        }
        return .init(evidence:evidence,statuses:statuses,aliasStatuses:aliasStatuses,titleBindings:titles,history:history,aliases:aliases,
            operators:operators,lines:lines,stations:stations,index:index,unusedReviews:unused,unusedAuthored:unusedAuthored,unusedCrosswalks:unusedCrosswalks,networkComplete:completeNetwork)
    }
}
