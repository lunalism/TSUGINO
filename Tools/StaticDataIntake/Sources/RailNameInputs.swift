import Foundation

// Identified, freshly decoded evidence. Never reads a saved packet as current
// truth. The current registry is checked for each source before name extraction.
struct RailNameInput {
    struct Static {
        let sourceID: String
        let archive: IdentifiedArchive
        var networkSide: NetworkSide { .init(sourceID: sourceID, archiveSHA256: archive.sha256,
            stopsMemberSHA256: archive.memberSHA256("stops.txt")!, translationsMemberSHA256: archive.memberSHA256("translations.txt"), feed: archive.feed) }
    }
    struct Railway {
        let sourceID: String
        let sha256: String
        let records: [ODPTRailway]
    }
    var stationEvidence: StationEvidenceInput? = nil
    var publishedNames: [PublishedRailName] = []
    var documentBytes: [ExactValue: Data] = [:]
    let sources: [Static]
    let railways: [Railway]
    let historical: [Static]
    let registry: MappingRegistry
    let registrySHA256: String
    let network: NetworkResult
    /// Documents opened/hash checked by the command, indexed by exact IDs.
    let documents: [ExactValue: String]
}

struct RailNameCatalog {
    let input: RailNameInput
    var members: [MintedIdentifier: [NameMember]] = [:]
    var candidates: [MintedIdentifier: [NameCandidate]] = [:]
    var provenance: [MintedIdentifier: [NameSighting]] = [:]
    var lineOperators: [MintedIdentifier: MintedIdentifier] = [:]
    var occurrences: [EditorialStationKey: [TitleOccurrence]] = [:]
    var entityIDs: [MintedIdentifier] { input.registry.entities.filter { $0.status == .active }.map(\.id).sorted() }
    var inputHashes: [String] { (input.sources.map { $0.archive.sha256 } + input.railways.map(\.sha256) + input.historical.map { $0.archive.sha256 } + (input.stationEvidence.map { [$0.sha256] } ?? [])).sorted() }

    static func exact(_ s: String) throws -> ExactValue {
        guard let e = ExactValue(s) else { throw NameReviewError.malformed }; return e
    }
    func reference(_ source: String, _ namespace: ProviderNamespace, _ key: String, _ hash: String) throws -> ProviderReference {
        let k = ProviderReferenceKey(sourceID: source, namespace: namespace, value: try Self.exact(key))
        guard let ref = input.registry.reference(for: k), ref.status == .active,
              input.registry.entities.contains(where: { $0.id == ref.canonicalID && $0.status == .active }) else { throw NameReviewError.unknownEntity }
        guard ref.provenance.inputSHA256 == hash else { throw NameReviewError.staleRegistry }
        if let archive = input.sources.first(where: { $0.sourceID == source })?.archive {
            guard let member = ref.provenance.member,
                  archive.memberSHA256(member.name) == member.sha256 else { throw NameReviewError.staleRegistry }
        }
        return ref
    }
    init(_ input: RailNameInput) throws {
        self.input = input
        let sources = input.sources.map(\.sourceID) + input.railways.map(\.sourceID)
        guard Set(sources).count == sources.count, sources.allSatisfy(MappingText.isToken),
              input.historical.allSatisfy({ sources.contains($0.sourceID) }),
              Set(input.historical.map { $0.sourceID + $0.archive.sha256 }).count == input.historical.count else { throw NameReviewError.duplicate }
        // Every active registry source must be provided; omitting a Railway
        // input must not remove alternative names from review evidence.
        guard input.registry.references.filter({ $0.status == .active }).allSatisfy({ sources.contains($0.sourceID) }) else { throw NameReviewError.staleRegistry }
        // Reconciliation is a prerequisite, including active references no
        // longer encountered while scanning the rows. No stale aliases survive
        // merely because another row still names the same entity.
        for ref in input.registry.references where ref.status == .active {
            if let source = input.sources.first(where: { $0.sourceID == ref.sourceID }) {
                let feed = source.archive.feed
                let values: [String]
                let table: String
                switch ref.namespace {
                case .gtfsAgencyID: values = feed.agencies.compactMap(\.agencyID);table = "agency"
                case .gtfsRouteID: values = feed.routes.map(\.routeID);table = "routes"
                case .gtfsStopID: values = feed.stops.map(\.stopID);table = "stops"
                case .gtfsStopCode: values = feed.stops.compactMap(\.stopCode);table = "stops"
                default: throw NameReviewError.staleRegistry
                }
                guard values.compactMap(ExactValue.init).contains(ref.value),
                      ref.provenance.inputSHA256 == source.archive.sha256,
                      ref.provenance.member?.name == table + ".txt",
                      ref.provenance.member?.sha256 == source.archive.memberSHA256(table + ".txt") else { throw NameReviewError.staleRegistry }
            } else if let source = input.railways.first(where: { $0.sourceID == ref.sourceID }) {
                let values: [String]
                switch ref.namespace {
                case .odptRailwayID: values = source.records.map(\.id)
                case .odptRailwaySameAs: values = source.records.map(\.sameAs)
                case .odptRailwayLineCode: values = source.records.map(\.lineCode)
                case .odptOperator: values = source.records.map(\.operatorReference)
                default: throw NameReviewError.staleRegistry
                }
                guard values.compactMap(ExactValue.init).contains(ref.value), ref.provenance.inputSHA256 == source.sha256 else { throw NameReviewError.staleRegistry }
            }
        }
        _ = try NetworkArtifacts.map(input.sources.map(\.networkSide), registry: input.registry)
        for source in input.sources { try appendStatic(source, historical: false) }
        for source in input.historical { try appendStatic(source, historical: true) }
        for source in input.railways { try appendRailway(source) }
        for id in members.keys { members[id] = members[id]!.sorted(by:NameMember.precedes) }
        for id in candidates.keys { candidates[id] = candidates[id]!.sorted(by: NameCandidate.precedes) }
        for id in provenance.keys { provenance[id] = provenance[id]!.sorted(by:NameSighting.precedes) }
        for key in occurrences.keys { occurrences[key] = occurrences[key]!.sorted { a,b in a.railwayID == b.railwayID ? a.logicalIndex < b.logicalIndex : a.railwayID < b.railwayID } }
    }
    mutating func appendStatic(_ source: RailNameInput.Static, historical: Bool) throws {
        let feed = source.archive.feed
        // This slice reads the accepted Japanese static-feed profile. A base
        // label cannot be relabelled Japanese when its declared language differs.
        guard feed.feedInfo.contains(where: { $0.language == "ja" }) || feed.agencies.contains(where: { $0.language == "ja" }) else { throw NameReviewError.malformed }
        guard feed.feedInfo.allSatisfy({ $0.language == "ja" }),
              feed.agencies.allSatisfy({ $0.language == nil || $0.language == "ja" }) else { throw NameReviewError.malformed }
        let nsSource = try Self.exact(source.sourceID)
        let hash = source.archive.sha256
        func sighting(_ table: String, _ field: String, _ key: ExactValue) throws -> NameSighting {
            guard let member = source.archive.memberSHA256(table + ".txt") else { throw NameReviewError.malformed }
            return .init(sourceID: nsSource, reference: try .init(inputSHA256: hash,
                member: .init(name: table + ".txt", sha256: member), table: table, recordIndex: nil, field: field, providerKey: key), arrayPosition: nil, documentSHA256: nil)
        }
        // Source originals + all translations, keyed by exact provider values.
        func names(_ table: String, _ field: String, _ key: ExactValue, _ published: String, _ namespace: ProviderNamespace) throws -> [NameCandidate] {
            var values: [(RailNameLanguage, ExactValue, NameSighting, String)] = []
            if let value = ExactValue(published) { values.append((.ja, value, try sighting(table, field, key), field)) }
            for t in feed.translations where t.tableName == table && t.fieldName == field && t.fieldValue.flatMap(ExactValue.init) == ExactValue(published) {
                guard let lang = RailNameLanguage(rawValue: t.language), let value = ExactValue(t.translation) else { continue }
                values.append((lang, value, try sighting("translations", "translation", key), "translations." + table + "." + field))
            }
            return values.map { lang,value,sighting,field in
                .init(key: .init(sourceID: nsSource, namespace: try! Self.exact(namespace.rawValue), providerKey: key,
                    parentKey: nil, field: try! Self.exact(field), language: lang, historicalInput: historical ? hash : nil),
                      value: value, sightings: [sighting], dependencySHA256: nil)
            }
        }
        let routes = Dictionary(uniqueKeysWithValues: feed.trips.map { (try! Self.exact($0.tripID), try! Self.exact($0.routeID)) })
        var rowRoutes: [ExactValue: Set<ExactValue>] = [:]
        for row in feed.stopTimes {
            if let route = routes[try Self.exact(row.tripID)] { rowRoutes[try Self.exact(row.stopID), default: []].insert(route) }
        }
        func resolve(_ ns: ProviderNamespace, _ key: String) throws -> ProviderReference? {
            if !historical { return try reference(source.sourceID, ns, key, hash) }
            return input.registry.reference(for: .init(sourceID: source.sourceID, namespace: ns, value: try Self.exact(key)))
        }
        func lineIDs(_ routes: [ExactValue]) throws -> [MintedIdentifier] {
            try Array(Set(routes.map { try reference(source.sourceID, .gtfsRouteID, $0.text, hash).canonicalID })).sorted()
        }
        let rows: [(ProviderNamespace,String,String,String,String,String?)] =
            feed.stops.map { (.gtfsStopID,$0.stopID,"stops","stop_name",$0.name,$0.stopCode) } +
            feed.routes.map { (.gtfsRouteID,$0.routeID,"routes","route_long_name",$0.longName ?? $0.shortName ?? "",nil) } +
            feed.agencies.map { (.gtfsAgencyID,$0.agencyID ?? "","agency","agency_name",$0.name,nil) }
        for (namespace,key,table,field,value,code) in rows {
            guard let ref = try resolve(namespace,key) else { continue }
            let exactKey = try Self.exact(key)
            var found = try names(table,field,exactKey,value,namespace)
            if historical {
                // Retained original history must attest to this historical
                // sighting. It never becomes a current canonical-name source.
                found = found.filter { candidate in ref.originalNames.contains { old in
                    old.language.text == candidate.key.language.rawValue && old.value == candidate.value && old.source.inputSHA256 == hash && candidate.sightings.contains { sighting in
                        old.source.member == sighting.reference.member && old.source.table == sighting.reference.table &&
                        old.source.field == sighting.reference.field && old.source.providerKey == sighting.reference.providerKey
                    }
                } }
            } else {
                let lines: [MintedIdentifier]
                if namespace == .gtfsStopID { lines = try lineIDs(Array(rowRoutes[exactKey] ?? [])) }
                else if namespace == .gtfsRouteID { lines = [ref.canonicalID] }
                else { lines = [] }
                members[ref.canonicalID, default: []].append(.init(sourceID: nsSource, namespace: namespace,
                    value: exactKey, entityID: ref.canonicalID, lineIDs: lines, codes: code.flatMap(ExactValue.init).map { [$0] } ?? [], attachmentReview:ref.attachedBy.flatMap(ExactValue.init)))
                provenance[ref.canonicalID, default: []].append(try sighting(table,namespace == .gtfsAgencyID ? "agency_id" : namespace == .gtfsRouteID ? "route_id" : "stop_id",exactKey))
            }
            candidates[ref.canonicalID, default: []] += found
        }
        if !historical {
            for route in feed.routes {
                let line = try reference(source.sourceID,.gtfsRouteID,route.routeID,hash).canonicalID
                let agency = route.agencyID ?? (feed.agencies.count == 1 ? feed.agencies[0].agencyID : nil)
                guard let agency else { throw NameReviewError.unknownEntity }
                let op = try reference(source.sourceID,.gtfsAgencyID,agency,hash).canonicalID
                if let old = lineOperators[line], old != op { throw NameReviewError.malformed }
                lineOperators[line] = op
            }
        }
    }
    mutating func appendRailway(_ source: RailNameInput.Railway) throws {
        for (index, rail) in source.records.enumerated() {
            let line = try reference(source.sourceID,.odptRailwayID,rail.id,source.sha256).canonicalID
            let same = try reference(source.sourceID,.odptRailwaySameAs,rail.sameAs,source.sha256).canonicalID
            let op = try reference(source.sourceID,.odptOperator,rail.operatorReference,source.sha256).canonicalID
            guard line == same, lineOperators[line] == op else { throw NameReviewError.malformed }
            let sourceID = try Self.exact(source.sourceID), railID = try Self.exact(rail.id)
            func sighting(_ field: String, position: Int? = nil) throws -> NameSighting {
                .init(sourceID: sourceID, reference: try .init(inputSHA256: source.sha256, member: nil, table: nil,
                    recordIndex: index, field: field, providerKey: railID), arrayPosition: position, documentSHA256: nil)
            }
            members[line, default: []].append(.init(sourceID: sourceID, namespace: .odptRailwayID, value: railID,
                entityID: line, lineIDs: [line], codes: [try Self.exact(rail.lineCode)],
                attachmentReview:try reference(source.sourceID,.odptRailwayID,rail.id,source.sha256).attachedBy.flatMap(ExactValue.init)))
            provenance[line, default: []].append(try sighting("@id"))
            for title in rail.title.entries {
                guard let lang = RailNameLanguage(rawValue:title.language), let value = ExactValue(title.text) else { continue }
                candidates[line, default: []].append(.init(key: .init(sourceID:sourceID,namespace:try Self.exact("odpt.railwayTitle"),providerKey:railID,parentKey:nil,field:try Self.exact("odpt:railwayTitle"),language:lang),value:value,sightings:[try sighting("odpt:railwayTitle."+title.language)],dependencySHA256:nil))
            }
            for (position, station) in rail.stationOrder.enumerated() {
                let key = EditorialStationKey(sourceID:sourceID,stationReference:try Self.exact(station.station))
                let titles = try (station.title?.entries ?? []).map { EditorialTitle(language:try Self.exact($0.language),value:try Self.exact($0.text)) }.sorted { $0.language < $1.language }
                occurrences[key,default:[]].append(.init(source:key,railwayID:railID,sameAs:try Self.exact(rail.sameAs),lineID:line,operatorID:op,
                    logicalIndex:station.index,titles:titles,sighting:try sighting("odpt:stationOrder.odpt:stationTitle",position:position)))
            }
        }
    }
}
