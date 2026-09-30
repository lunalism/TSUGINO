import Foundation

// DEC-069 cases for cross-operator candidates, reviewed records, station
// formation, the station commands, and repeat runs. Every feed, record,
// registry, identifier, and digest is invented: stops `syn-a-…` / `syn-b-…`,
// codes `P` / `T` / `Q` stand-ins, names 合成… and "Synthetic …". Nothing
// here is a production identifier, a real mapping, or a real decision.

enum SyntheticStations {
    static let sourceA = "SYN-01/synthetic-a"
    static let sourceB = "SYN-02/synthetic-b"
    static let operatorA = MintedIdentifier("opr_0000000000000001")!
    static let operatorB = MintedIdentifier("opr_0000000000000002")!
    static let stations: [MintedIdentifier] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b"].map { (last: String) -> MintedIdentifier in
        MintedIdentifier("stn_000000000000000" + last)!
    }

    static func common(language: String = "ja") -> [String: String] {
        [
            "calendar.txt": """
                service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
                syn-weekday,1,1,1,1,1,0,0,20990101,20991231

                """,
            "feed_info.txt": """
                feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version
                Synthetic Publisher,https://example.invalid,\(language),20990101,20991231,syn-1

                """,
        ]
    }

    /// Operator A: line P (six stops) and line T (two stops). 合成ハブ is on
    /// both lines, as two rows that P2-S4 groups into one identity.
    enum SharedCode { case none, withinGroup, acrossStations }

    static func tablesA(extraStop: Bool = false, hubLatitude: String = "35.001", sharedCode: SharedCode = .none, sequenceStep: Int = 1) -> [String: String] {
        var tables = common()
        tables["agency.txt"] = """
            agency_id,agency_name,agency_url,agency_timezone,agency_lang
            syn-agency-a,合成交通A,https://example.invalid,Asia/Tokyo,ja

            """
        tables["stops.txt"] = """
            stop_id,stop_code,stop_name,stop_lat,stop_lon
            syn-a-hub1,P01,合成ハブ,\(hubLatitude),139.001
            syn-a-ke,P02,合成ヶ丘,35.002,139.002
            syn-a-sub,P03,合成台,35.003,139.003
            syn-a-twin,P04,合成双子,35.004,139.004
            syn-a-east,P05,合成東,35.005,139.005
            syn-a-gc,P06,合成ガ,35.006,139.006
            syn-a-hub2,T01,合成ハブ,35.011,139.011
            syn-a-alone,T02,合成孤立,35.012,139.012

            """
        tables["routes.txt"] = """
            route_id,agency_id,route_long_name,route_type
            syn-route-p,syn-agency-a,合成ピー線,1
            syn-route-t,syn-agency-a,合成ティー線,1

            """
        tables["trips.txt"] = """
            route_id,service_id,trip_id
            syn-route-p,syn-weekday,syn-a-t1
            syn-route-t,syn-weekday,syn-a-t2

            """
        // Line P's stop_sequence values step by `sequenceStep`, in the same order.
        let lineP = ["syn-a-hub1", "syn-a-ke", "syn-a-sub", "syn-a-twin", "syn-a-east", "syn-a-gc"].enumerated()
            .map { "syn-a-t1,05:0\($0.offset):00,05:0\($0.offset):00,\($0.element),\(($0.offset + 1) * sequenceStep)" }
        tables["stop_times.txt"] = (["trip_id,arrival_time,departure_time,stop_id,stop_sequence"] + lineP + [
            "syn-a-t2,06:00:00,06:00:00,syn-a-hub2,1",
            "syn-a-t2,06:01:00,06:01:00,syn-a-alone,2",
        ]).joined(separator: "\n") + "\n"
        tables["translations.txt"] = """
            table_name,field_name,language,translation,field_value
            stops,stop_name,en,Synthetic Hub,合成ハブ
            stops,stop_name,en,Gokei-oka,合成ヶ丘
            stops,stop_name,en,Gosei-dai,合成台
            stops,stop_name,en,Synthetic Twin,合成双子
            stops,stop_name,en,Synthetic East,合成東
            stops,stop_name,en,Gc A,合成ガ
            stops,stop_name,en,Synthetic Alone,合成孤立

            """
        switch sharedCode {
        case .none: break
        case .withinGroup:
            // Both hub rows carry P01; line T gains a P-coded stop so the code
            // still fits it, and P2-S4 groups them as before.
            tables["stops.txt"] = tables["stops.txt"]!.replacingOccurrences(of: "syn-a-hub2,T01", with: "syn-a-hub2,P01")
                .replacingOccurrences(of: "syn-a-alone,T02", with: "syn-a-alone,P07")
        case .acrossStations:
            // Two separate stations of one operator, both on line P, with one code.
            tables["stops.txt"] = tables["stops.txt"]!.replacingOccurrences(of: "syn-a-east,P05", with: "syn-a-east,P06")
        }
        if extraStop {
            // Changed evidence: a new same-name row on line T.
            tables["stops.txt"]! += "syn-a-hub3,T03,合成ハブ,35.013,139.013\n"
            tables["stop_times.txt"]! += "syn-a-t2,06:02:00,06:02:00,syn-a-hub3,3\n"
        }
        return tables
    }

    /// Operator B: line Q (six stops). 合成カ゛ is written decomposed (カ +
    /// U+3099) while A writes 合成ガ precomposed.
    static func tablesB(secondHub: Bool = false) -> [String: String] {
        var tables = common()
        tables["agency.txt"] = """
            agency_id,agency_name,agency_url,agency_timezone,agency_lang
            syn-agency-b,合成交通B,https://example.invalid,Asia/Tokyo,ja

            """
        tables["stops.txt"] = """
            stop_id,stop_code,stop_name,stop_lat,stop_lon
            syn-b-hub,Q01,合成ハブ,35.101,139.101
            syn-b-ke,Q02,合成ケ丘,35.102,139.102
            syn-b-sub,Q03,合成台〈合成前〉,35.103,139.103
            syn-b-twin,Q04,合成双子,35.104,139.104
            syn-b-east,Q05,合成ひがし,35.105,139.105
            syn-b-gd,Q06,合成カ\u{3099},35.106,139.106

            """
        tables["routes.txt"] = """
            route_id,agency_id,route_long_name,route_type
            syn-route-q,syn-agency-b,合成キュー線,1

            """
        tables["trips.txt"] = """
            route_id,service_id,trip_id
            syn-route-q,syn-weekday,syn-b-t1

            """
        tables["stop_times.txt"] = """
            trip_id,arrival_time,departure_time,stop_id,stop_sequence
            syn-b-t1,05:00:00,05:00:00,syn-b-hub,1
            syn-b-t1,05:01:00,05:01:00,syn-b-ke,2
            syn-b-t1,05:02:00,05:02:00,syn-b-sub,3
            syn-b-t1,05:03:00,05:03:00,syn-b-twin,4
            syn-b-t1,05:04:00,05:04:00,syn-b-east,5
            syn-b-t1,05:05:00,05:05:00,syn-b-gd,6

            """
        tables["translations.txt"] = """
            table_name,field_name,language,translation,field_value
            stops,stop_name,en,Synthetic Hub,合成ハブ
            stops,stop_name,en,Gokei-oka,合成ケ丘
            stops,stop_name,en,Gosei-dai Synthetic-mae,合成台〈合成前〉
            stops,stop_name,en,Synthetic Twin,合成双子
            stops,stop_name,en,Synthetic East,合成ひがし
            stops,stop_name,en,Gc B,合成カ\u{3099}

            """
        if secondHub {
            // A second B row, on a second line, with another Japanese name but
            // the same English one. P2-S4 holds its grouping back (names are
            // not uniform), so it stays its own identity and competes with
            // the hub through the exact English key.
            tables["stops.txt"]! += "syn-b-hub2,R01,合成ハブ西,35.121,139.121\nsyn-b-r2,R02,合成アール,35.122,139.122\n"
            tables["routes.txt"]! += "syn-route-r,syn-agency-b,合成アール線,1\n"
            tables["trips.txt"]! += "syn-route-r,syn-weekday,syn-b-t2\n"
            tables["stop_times.txt"]! += "syn-b-t2,07:00:00,07:00:00,syn-b-hub2,1\nsyn-b-t2,07:01:00,07:01:00,syn-b-r2,2\n"
            tables["translations.txt"]! += "stops,stop_name,en,Synthetic Hub,合成ハブ西\nstops,stop_name,en,Synthetic R Two,合成アール\n"
        }
        return tables
    }

    struct Side {
        let source: String
        let archive: URL
        let records: URL
    }

    static func write(_ tables: [String: String], _ workspace: Workspace, _ name: String) throws -> URL {
        try workspace.write(ZipWriter.archive(tables.keys.sorted().map { ZipEntry($0, Data(tables[$0]!.utf8)) }), named: name)
    }

    static func read(_ archive: URL) async throws -> IdentifiedArchive {
        try await ArchiveReading.read(
            requestedPath: archive.path, resolvedPath: resolvedPath(archive.path)!, checked: FileIdentity(path: archive.path)!,
            repositoryRoot: testRepositoryRoot, limits: .standard
        )
    }

    /// P2-S4 records for one side: its grouping proposals, all accepted.
    static func writeP2S4Records(_ workspace: Workspace, _ name: String, source: String, archive: URL) async throws -> URL {
        let read = try await read(archive)
        let input = try GroupingInput(sourceID: source, archiveSHA256: read.sha256, stopsMemberSHA256: read.memberSHA256("stops.txt")!, feed: read.feed)
        let groupings = StationGrouping.propose(input).proposals.enumerated().map { index, candidate -> [String: Any] in
            ["reviewID": "SYN-REVIEW-G\(index + 1)", "stops": candidate.members.map(\.stopID.text),
             "evidenceSHA256": candidate.evidenceSHA256, "decision": "accepted"]
        }
        let object: [String: Any] = ["schemaVersion": 1, "gtfsSourceID": source, "gtfsArchiveSHA256": read.sha256, "groupings": groupings]
        let url = workspace.archives.appendingPathComponent(name)
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]).write(to: url)
        return url
    }

    static func sides(_ workspace: Workspace, _ tag: String, a: [String: String] = tablesA(), b: [String: String] = tablesB()) async throws -> [Side] {
        let archiveA = try write(a, workspace, "a-\(tag).zip")
        let archiveB = try write(b, workspace, "b-\(tag).zip")
        return [
            Side(source: sourceA, archive: archiveA, records: try await writeP2S4Records(workspace, "records-a-\(tag).json", source: sourceA, archive: archiveA)),
            Side(source: sourceB, archive: archiveB, records: try await writeP2S4Records(workspace, "records-b-\(tag).json", source: sourceB, archive: archiveB)),
        ]
    }

    /// A registry with both operators bound to their agencies and eleven
    /// provisional station entities, as `mint` would leave them.
    static func registry(_ sides: [Side], sameOperator: Bool = false) async throws -> MappingRegistry {
        var references: [ProviderReference] = []
        for (side, identity) in zip(sides, [operatorA, sameOperator ? operatorA : operatorB]) {
            let read = try await read(side.archive)
            let agency = read.feed.agencies[0].agencyID!
            let provenance = try SourceReference(
                inputSHA256: read.sha256, member: .init(name: "agency.txt", sha256: read.memberSHA256("agency.txt")!),
                table: "agency", recordIndex: nil, field: "agency_id", providerKey: ExactValue(agency)!
            )
            references.append(try ProviderReference(
                canonicalID: identity, sourceID: side.source, namespace: .gtfsAgencyID, value: ExactValue(agency)!, status: .active,
                firstSeenInputSHA256: read.sha256, provenance: provenance, originalNames: [], attachedBy: "SYN-REVIEW-O"
            ))
        }
        return try MappingRegistry(
            revision: 3, entities: ([operatorA, operatorB] + stations).map { CanonicalEntity(id: $0, status: .active) }, references: references
        )
    }

    static func writeRegistry(_ registry: MappingRegistry, _ workspace: Workspace, _ name: String) throws -> URL {
        let url = workspace.archives.appendingPathComponent(name)
        try registry.encoded().write(to: url)
        return url
    }

    static func request(_ sides: [Side], registry: URL, cross: URL?, previous: ([Side], URL)? = nil, output: URL) -> StationRunRequest {
        func map(_ sides: [Side]) -> [StationRunRequest.Side] {
            sides.map { .init(gtfsSourceID: $0.source, archivePath: $0.archive.path, recordsPath: $0.records.path, railwaySourceID: nil, railwayPath: nil) }
        }
        return StationRunRequest(
            sides: map(sides), registryPath: registry.path, crossRecordsPath: cross?.path,
            previous: previous.map { .init(sides: map($0.0), crossRecordsPath: $0.1.path) }, outputPath: output.path
        )
    }

    static func load(_ sides: [Side], registry: MappingRegistry, cross: URL? = nil) async throws -> StationCommand.Loaded {
        try await StationCommand.load(
            request(sides, registry: URL(fileURLWithPath: "/unused"), cross: nil, output: URL(fileURLWithPath: "/unused")).sides,
            crossRecords: cross?.path, registry: registry, testRepositoryRoot, previous: false
        )
    }

    /// The candidate whose first side has this stop.
    static func candidate(_ report: StationCandidateReport, _ stop: String) -> StationCandidate {
        report.candidates.first { $0.sides[0].side.members.contains { $0.providerKey.text == stop } }!
    }

    static func sideJSON(_ side: CrossOperatorSide) -> [String: Any] {
        ["gtfsSourceID": side.sourceID, "stops": side.members.map(\.providerKey.text)]
    }

    /// The reviewer's decisions for the fixture: the hub, ヶ/ケ, and subtitle
    /// pairs are the same station, the twins ambiguous, the east pair distinct.
    static func decisions(_ report: StationCandidateReport, overrides: [String: [String: Any]] = [:], omit: Set<String> = []) -> [[String: Any]] {
        let plan: [(String, String, [String], [String])] = [
            ("syn-a-east", "distinct", [], ["evidence:originalNames"]),
            ("syn-a-hub1", "same", [], ["evidence:stationCodes", "evidence:lineMembership"]),
            ("syn-a-ke", "same", ["orthographicKe"], []),
            ("syn-a-sub", "same", ["subtitleBracket"], []),
            ("syn-a-twin", "ambiguous", [], ["evidence:coordinates"]),
        ]
        return plan.filter { !omit.contains($0.0) }.enumerated().map { index, entry in
            let candidate = candidate(report, entry.0)
            var record: [String: Any] = [
                "reviewID": "SYN-REVIEW-X\(index + 1)", "sides": candidate.pair.map(sideJSON), "evidenceSHA256": candidate.evidenceSHA256,
                "outcome": entry.1, "reason": "Synthetic decision", "citedAliasRules": entry.2, "evidenceProvenance": entry.3,
            ]
            for (key, value) in overrides[entry.0] ?? [:] { record[key] = value }
            return record
        }
    }

    static func writeCross(_ workspace: Workspace, _ name: String, _ loaded: StationCommand.Loaded, decisions: [[String: Any]], stations: [[String: Any]] = []) throws -> URL {
        let object: [String: Any] = [
            "schemaVersion": 1,
            "inputs": loaded.sides.map { ["gtfsSourceID": $0.sourceID, "gtfsArchiveSHA256": $0.archiveSHA256] },
            "decisions": decisions, "stations": stations,
        ]
        let url = workspace.archives.appendingPathComponent(name)
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]).write(to: url)
        return url
    }

    /// One assignment per group, stations in order.
    static func assignments(_ groups: [CanonicalStationGroup], ids: [MintedIdentifier] = stations) -> [[String: Any]] {
        zip(groups, ids).enumerated().map { index, pair in
            ["reviewID": "SYN-REVIEW-S\(index + 1)", "stationID": pair.1.rawValue, "sides": pair.0.sides.map(sideJSON)]
        }
    }

    /// Everything a registry run needs, fully decided and assigned.
    static func decidedRun(_ workspace: Workspace, _ tag: String, a: [String: String] = tablesA()) async throws -> (sides: [Side], registry: URL, cross: URL) {
        let sides = try await sides(workspace, tag, a: a)
        let registry = try await registry(sides)
        let registryURL = try writeRegistry(registry, workspace, "registry-\(tag).json")
        let undecided = try await load(sides, registry: registry)
        let decided = try writeCross(workspace, "decided-\(tag).json", undecided, decisions: decisions(undecided.formation.report))
        let formed = try await load(sides, registry: registry, cross: decided)
        let cross = try writeCross(workspace, "cross-\(tag).json", undecided, decisions: decisions(undecided.formation.report),
                                   stations: assignments(formed.formation.groups))
        return (sides, registryURL, cross)
    }

    static func runRegistry(_ request: StationRunRequest) async -> Result<StationRegistryResult, ProvisionalRegistryError> {
        do { return .success(try await StationRegistryCommand.run(request, repositoryRoot: testRepositoryRoot)) } catch { return .failure(error) }
    }

    static func expectFailure(_ request: StationRunRequest, _ workspace: Workspace) async throws -> ProvisionalRegistryError {
        let before = try workspace.outputEntries()
        guard case .failure(let error) = await runRegistry(request) else { throw TestFailure(message: "expected a failure, the run succeeded") }
        try check(try workspace.outputEntries() == before, "the output directory changed after a failure")
        try check(SyntheticRun.safe(error.description) && !error.description.contains("stn_"), "unsafe error text: \(error.description)")
        return error
    }

    static func resolve(_ registry: MappingRegistry, _ source: String, _ namespace: ProviderNamespace, _ value: String) -> MintedIdentifier? {
        registry.resolve(ProviderReferenceKey(sourceID: source, namespace: namespace, value: ExactValue(value)!))
    }
}

let stationTests: [TestCase] = [
    ("candidates come only from the four keys, one per pair, keeping every discovery reason", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let loaded = try await SyntheticStations.load(sides, registry: try await SyntheticStations.registry(sides))
        let report = loaded.formation.report
        let firsts = report.candidates.map { $0.sides[0].side.members.map(\.providerKey.text) }
        try check(firsts == [["syn-a-east"], ["syn-a-hub1", "syn-a-hub2"], ["syn-a-ke"], ["syn-a-sub"], ["syn-a-twin"]], "\(firsts)")
        func keys(_ stop: String) -> [String] { SyntheticStations.candidate(report, stop).reasons.map(\.key.name) }
        try check(keys("syn-a-hub1") == ["exactJapanese", "exactEnglish"], "hub: \(keys("syn-a-hub1"))")
        try check(keys("syn-a-ke") == ["exactEnglish", "alias.orthographicKe"], "ke: \(keys("syn-a-ke"))")
        try check(keys("syn-a-sub") == ["alias.subtitleBracket"], "subtitle: \(keys("syn-a-sub"))")
        try check(keys("syn-a-twin") == ["exactJapanese", "exactEnglish"], "twin")
        try check(keys("syn-a-east") == ["exactEnglish"], "english only")
        // Both hub rows matched: every match is kept.
        let hub = SyntheticStations.candidate(report, "syn-a-hub1")
        try check(hub.reasons[0].matches.count == 2 && hub.sides[0].routeCount == 2, "both hub rows, two lines")
        // No candidate for the composed / decomposed pair, or for a row with no counterpart.
        let stops = Set(report.candidates.flatMap { $0.pair.flatMap { $0.members.map(\.providerKey.text) } })
        try check(!stops.contains("syn-a-gc") && !stops.contains("syn-b-gd") && !stops.contains("syn-a-alone"), "exact Unicode values only")
    }),
    ("alias matches keep both originals and their sources, and the comparison key never replaces a value", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let report = try await SyntheticStations.load(sides, registry: try await SyntheticStations.registry(sides)).formation.report
        let ke = SyntheticStations.candidate(report, "syn-a-ke").reasons.first { $0.key == .alias(.orthographicKe) }!
        try check(ke.aliasMatches.count == 1, "one alias match")
        let match = ke.aliasMatches[0]
        try check(Set(match.originals.map(\.value.text)) == ["合成ヶ丘", "合成ケ丘"], "both originals preserved")
        try check(match.comparisonKey.text == "合成ケ丘" && match.originals.allSatisfy { $0.source.field == "stop_name" }, "derived key; stop_name sources")
        try check(Set(match.originals.map(\.source.providerKey.text)) == ["syn-a-ke", "syn-b-ke"], "each original's own row")
        let sub = SyntheticStations.candidate(report, "syn-a-sub").reasons[0].aliasMatches[0]
        try check(Set(sub.originals.map(\.value.text)) == ["合成台", "合成台〈合成前〉"] && sub.comparisonKey.text == "合成台", "subtitle originals")
        // The packet shows the originals exactly and the key separately.
        let loaded = try await SyntheticStations.load(sides, registry: try await SyntheticStations.registry(sides))
        let text = String(decoding: StationPacketCommand.make(loaded).encoded(), as: UTF8.self)
        try check(text.contains("合成台〈合成前〉") && text.contains("\"comparisonKey\" : \"合成台\""), "originals and key in the packet")
    }),
    ("candidates and digests are deterministic: repeated, and independent of row order", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let registry = try await SyntheticStations.registry(sides)
        let first = try await SyntheticStations.load(sides, registry: registry).formation.report
        let again = try await SyntheticStations.load(sides, registry: registry).formation.report
        try check(first == again, "repeatable")
        // The same tables with every row reversed.
        // stop_times keeps its order: the reader requires rows in stop_sequence order.
        func reversed(_ tables: [String: String]) -> [String: String] {
            tables.filter { $0.key != "stop_times.txt" }.mapValues { table in
                var lines = table.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
                let header = lines.removeFirst()
                return ([header] + lines.reversed()).joined(separator: "\n") + "\n"
            }.merging(["stop_times.txt": tables["stop_times.txt"]!]) { $1 }
        }
        let flipped = try await SyntheticStations.sides(workspace, "r", a: reversed(SyntheticStations.tablesA()), b: reversed(SyntheticStations.tablesB()))
        let other = try await SyntheticStations.load(flipped, registry: try await SyntheticStations.registry(flipped)).formation.report
        try check(other.candidates.map { $0.pair.map(\.members).map { $0.map(\.providerKey) } } == first.candidates.map { $0.pair.map(\.members).map { $0.map(\.providerKey) } },
                  "same candidates in the same order")
        try check(other.candidates.map { $0.reasons.map(\.key) } == first.candidates.map { $0.reasons.map(\.key) }, "same reasons")
    }),
    ("changed evidence changes the digest: a new competing candidate, a new member, or a coordinate", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let base = try await SyntheticStations.load(sides, registry: try await SyntheticStations.registry(sides)).formation.report
        let hub = SyntheticStations.candidate(base, "syn-a-hub1")
        try check(hub.otherCandidates.isEmpty, "no competitor at first")
        for (tag, a, b) in [("c", SyntheticStations.tablesA(), SyntheticStations.tablesB(secondHub: true)),
                            ("m", SyntheticStations.tablesA(extraStop: true), SyntheticStations.tablesB()),
                            ("g", SyntheticStations.tablesA(hubLatitude: "35.0015"), SyntheticStations.tablesB())] {
            let changed = try await SyntheticStations.sides(workspace, tag, a: a, b: b)
            let report = try await SyntheticStations.load(changed, registry: try await SyntheticStations.registry(changed)).formation.report
            let after = SyntheticStations.candidate(report, "syn-a-hub1")
            try check(after.evidenceSHA256 != hub.evidenceSHA256, "\(tag): digest changed")
            if tag == "c" { try check(after.otherCandidates.count == 1, "the competing B row is listed") }
        }
    }),
    ("applying decisions forms stations: same joins two, distinct and ambiguous keep two, nothing joins without a record", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let registry = try await SyntheticStations.registry(sides)
        let undecided = try await SyntheticStations.load(sides, registry: registry)
        try check(undecided.formation.unreviewed.count == 5 && undecided.formation.groups.count == 13, "undecided: every identity alone")
        let cross = try SyntheticStations.writeCross(workspace, "cross.json", undecided, decisions: SyntheticStations.decisions(undecided.formation.report))
        let formed = try await SyntheticStations.load(sides, registry: registry, cross: cross).formation
        try check(formed.unreviewed.isEmpty && formed.same == 3 && formed.distinct == 1 && formed.ambiguous == 1, "outcomes")
        try check(formed.groups.count == 10 && formed.groups.filter { $0.sides.count == 2 }.count == 3, "7 + 6 identities, 3 merged")
        let twin = formed.groups.filter { $0.sides.contains { $0.members.contains { $0.providerKey.text.hasSuffix("-twin") } } }
        try check(twin.count == 2 && twin.allSatisfy { $0.sides.count == 1 }, "the ambiguous pair stays two stations")
        // A partial set leaves the rest undecided, never guessed.
        let partial = try SyntheticStations.writeCross(workspace, "partial.json", undecided,
                                                       decisions: SyntheticStations.decisions(undecided.formation.report, omit: ["syn-a-ke"]))
        let rest = try await SyntheticStations.load(sides, registry: registry, cross: partial).formation
        try check(rest.unreviewed.count == 1 && rest.groups.count == 11, "one candidate unreviewed; its pair not joined")
    }),
    ("a same record cites only an alias rule that related the names, and needs a basis when the Japanese names differ", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let registry = try await SyntheticStations.registry(sides)
        let undecided = try await SyntheticStations.load(sides, registry: registry)
        let report = undecided.formation.report
        func outcome(_ overrides: [String: [String: Any]]) async throws -> ProvisionalRegistryError? {
            let url = try SyntheticStations.writeCross(workspace, "o-\(UUID().uuidString).json", undecided, decisions: SyntheticStations.decisions(report, overrides: overrides))
            do { _ = try await SyntheticStations.load(sides, registry: registry, cross: url); return nil } catch let error as ProvisionalRegistryError { return error }
        }
        // Citing a rule that did not relate the names: never an invented alias.
        try check(try await outcome(["syn-a-hub1": ["citedAliasRules": ["subtitleBracket"]]]) == .stations("aliasNotUsed"), "hub cites subtitle")
        try check(try await outcome(["syn-a-ke": ["citedAliasRules": ["subtitleBracket"]]]) == .stations("aliasNotUsed"), "ke cites subtitle")
        // No exact Japanese match, no citation, no provenance.
        try check(try await outcome(["syn-a-sub": ["citedAliasRules": []]]) == .stations("aliasNotCited"), "subtitle without citation")
        // An alias rule related the names: provenance does not replace the citation.
        try check(try await outcome(["syn-a-ke": ["citedAliasRules": [], "evidenceProvenance": ["evidence:stationCodes"]]]) == .stations("aliasNotCited"), "ke provenance only")
        try check(try await outcome(["syn-a-east": ["outcome": "same", "evidenceProvenance": []]]) == .stations("sameWithoutBasis"), "differently named, no basis")
        // Differently named, same on documented evidence with its provenance.
        try check(try await outcome(["syn-a-east": ["outcome": "same", "evidenceProvenance": ["evidence:stationCodes", "external:SYN-SOURCE-1"]]]) == nil, "same with provenance")
        // Alias rules only support a merge; unknown rules and provenance are invalid records.
        try check(try await outcome(["syn-a-twin": ["citedAliasRules": ["orthographicKe"]]]) == .records(.invalidRecord), "citation on ambiguous")
        try check(try await outcome(["syn-a-ke": ["citedAliasRules": ["widthFolding"]]]) == .records(.invalidRecord), "unknown rule")
        try check(try await outcome(["syn-a-ke": ["evidenceProvenance": ["evidence:distance"]]]) == .records(.invalidRecord), "unknown evidence item")
    }),
    ("conflicting, overlapping, stale, or foreign decisions are refused", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let registry = try await SyntheticStations.registry(sides)
        let undecided = try await SyntheticStations.load(sides, registry: registry)
        let report = undecided.formation.report
        func refused(_ decisions: [[String: Any]]) async throws -> ProvisionalRegistryError? {
            let url = try SyntheticStations.writeCross(workspace, "r-\(UUID().uuidString).json", undecided, decisions: decisions)
            do { _ = try await SyntheticStations.load(sides, registry: registry, cross: url); return nil } catch let error as ProvisionalRegistryError { return error }
        }
        var decisions = SyntheticStations.decisions(report)
        // Two decisions for one pair, and one review twice.
        try check(try await refused(decisions + [decisions[0].merging(["reviewID": "SYN-REVIEW-X9"]) { $1 }]) == .stations("repeatedPair"), "repeated pair")
        try check(try await refused(decisions + [decisions[1].merging(["sides": decisions[0]["sides"]!, "reviewID": decisions[1]["reviewID"]!]) { $1 }]) == .stations("repeatedReviewID"), "repeated review")
        // A side naming only part of an operator-level identity overlaps the full one.
        let hub = SyntheticStations.candidate(report, "syn-a-hub1")
        let partialSides: [[String: Any]] = [["gtfsSourceID": SyntheticStations.sourceA, "stops": ["syn-a-hub1"]], SyntheticStations.sideJSON(hub.pair[1])]
        try check(try await refused(decisions + [["reviewID": "SYN-REVIEW-X8", "sides": partialSides, "evidenceSHA256": hub.evidenceSHA256,
                                                  "outcome": "distinct", "reason": "Synthetic"]]) == .stations("overlappingSides"), "overlap")
        // Rows never proposed together.
        let pairing: [[String: Any]] = [["gtfsSourceID": SyntheticStations.sourceA, "stops": ["syn-a-gc"]], ["gtfsSourceID": SyntheticStations.sourceB, "stops": ["syn-b-gd"]]]
        try check(try await refused(decisions + [["reviewID": "SYN-REVIEW-X7", "sides": pairing, "evidenceSHA256": String(repeating: "a", count: 64),
                                                  "outcome": "same", "reason": "Synthetic", "evidenceProvenance": ["evidence:stationCodes"]]]) == .stations("notACandidate"), "not a candidate")
        // A digest the candidate no longer has.
        decisions[2]["evidenceSHA256"] = String(repeating: "b", count: 64)
        try check(try await refused(decisions) == .stations("evidenceChanged"), "stale digest")
        // A record file for other inputs.
        let other = try JSONSerialization.data(withJSONObject: ["schemaVersion": 1, "inputs": [["gtfsSourceID": SyntheticStations.sourceA, "gtfsArchiveSHA256": String(repeating: "c", count: 64)],
                                                                                                 ["gtfsSourceID": SyntheticStations.sourceB, "gtfsArchiveSHA256": undecided.sides[1].archiveSHA256]]])
        let otherURL = workspace.archives.appendingPathComponent("other.json")
        try other.write(to: otherURL)
        do { _ = try await SyntheticStations.load(sides, registry: registry, cross: otherURL); throw TestFailure(message: "foreign records accepted") }
        catch let error as ProvisionalRegistryError { try check(error == .records(.forOtherInput), "\(error)") }
    }),
    ("station-registry attaches exact stop_id and stop_code references by assignment, with ambiguous pairs as two unrelated stations", { workspace in
        let (sides, registry, cross) = try await SyntheticStations.decidedRun(workspace, "a")
        let output = workspace.output.appendingPathComponent("stations-1")
        guard case .success(let result) = await SyntheticStations.runRegistry(SyntheticStations.request(sides, registry: registry, cross: cross, output: output))
        else { throw TestFailure(message: "the station run failed") }
        let written = try MappingRegistry.decoded(from: try Data(contentsOf: output.appendingPathComponent("registry.json")))
        try check(written == result.registry && written.revision == 4, "published; one revision")
        let (a, b) = (SyntheticStations.sourceA, SyntheticStations.sourceB)
        let hub = SyntheticStations.resolve(written, a, .gtfsStopID, "syn-a-hub1")
        try check(hub != nil && hub?.kind == .station, "hub resolves to a station")
        try check(SyntheticStations.resolve(written, a, .gtfsStopID, "syn-a-hub2") == hub && SyntheticStations.resolve(written, b, .gtfsStopID, "syn-b-hub") == hub, "one hub station across operators")
        try check(SyntheticStations.resolve(written, a, .gtfsStopCode, "T01") == hub, "codes follow their rows")
        try check(SyntheticStations.resolve(written, a, .gtfsStopID, "syn-a-ke") == SyntheticStations.resolve(written, b, .gtfsStopID, "syn-b-ke"), "ヶ / ケ joined")
        let twinA = SyntheticStations.resolve(written, a, .gtfsStopID, "syn-a-twin")!, twinB = SyntheticStations.resolve(written, b, .gtfsStopID, "syn-b-twin")!
        try check(twinA != twinB, "ambiguous: two stations")
        try check(written.references.filter { $0.canonicalID == twinA }.allSatisfy { $0.sourceID == a }
                  && written.references.filter { $0.canonicalID == twinB }.allSatisfy { $0.sourceID == b }, "no reference relates the two")
        // Exact values: the decomposed row is its own station with its original scalars.
        let decomposed = written.reference(for: ProviderReferenceKey(sourceID: b, namespace: .gtfsStopID, value: ExactValue("syn-b-gd")!))!
        try check(decomposed.originalNames.contains { $0.value.text.unicodeScalars.map(\.value).suffix(2) == [0x30AB, 0x3099] }, "decomposed spelling kept")
        try check(decomposed.canonicalID != SyntheticStations.resolve(written, a, .gtfsStopID, "syn-a-gc"), "composed and decomposed are not joined")
        // Every stop reference was attached by its assignment's review.
        let stops = written.references.filter { $0.namespace == .gtfsStopID }
        try check(stops.count == 14 && stops.allSatisfy { $0.attachedBy?.hasPrefix("SYN-REVIEW-S") == true }, "14 rows attached by review")
        let report = result.report
        try check(report.stations.total == 10 && report.stations.merged == 3 && report.stations.duplicateAssignments == 0
                  && report.stations.unmappedIdentities == 0 && report.stations.unassignedStationEntities == 1, "\(report.stations)")
        try check(report.sides.map(\.operatorLevelIdentities) == [7, 6] && report.sides.map(\.singletonStations) == [4, 3], "sides")
        try check(report.candidates.total == 5 && report.candidates.same == 3 && report.candidates.ambiguous == 1 && report.candidates.distinct == 1, "candidates")
        try check(report.registry.activeStationReferences == 28, "14 stop_id + 14 stop_code")
        let text = String(decoding: report.encoded(), as: UTF8.self)
        try check(SyntheticRun.safe(text) && !text.contains("stn_"), "report holds aggregates only")
    }),
    ("a repeat run against its own output is byte-identical with no revision increase; without the previous inputs it is refused", { workspace in
        let (sides, registry, cross) = try await SyntheticStations.decidedRun(workspace, "a")
        let first = workspace.output.appendingPathComponent("stations-1")
        guard case .success = await SyntheticStations.runRegistry(SyntheticStations.request(sides, registry: registry, cross: cross, output: first)) else {
            throw TestFailure(message: "first run failed")
        }
        let own = first.appendingPathComponent("registry.json")
        let second = workspace.output.appendingPathComponent("stations-2")
        guard case .success(let again) = await SyntheticStations.runRegistry(
            SyntheticStations.request(sides, registry: own, cross: cross, previous: (sides, cross), output: second)) else {
            throw TestFailure(message: "repeat run failed")
        }
        try check(try Data(contentsOf: own) == (try Data(contentsOf: second.appendingPathComponent("registry.json"))), "byte-identical registry")
        try check(again.report.registry.previousRevision == again.report.registry.revision, "no revision increase")
        try check(again.report.reconciliation.allSatisfy { $0.newAttached == 0 && $0.changed == 0 && $0.absent == 0 }, "nothing new, changed, or absent")
        let missing = try await SyntheticStations.expectFailure(
            SyntheticStations.request(sides, registry: own, cross: cross, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(missing == .reconciliation("previousInput.required"), "\(missing)")
    }),
    ("station-registry refuses undecided candidates, unassigned or foreign groups, unknown stations, a shared operator, and a rebinding", { workspace in
        let (sides, registryURL, cross) = try await SyntheticStations.decidedRun(workspace, "a")
        let registry = try MappingRegistry.decoded(from: try Data(contentsOf: registryURL))
        let undecided = try await SyntheticStations.load(sides, registry: registry)
        let decisions = SyntheticStations.decisions(undecided.formation.report)
        let formed = try await SyntheticStations.load(sides, registry: registry, cross: try SyntheticStations.writeCross(workspace, "d.json", undecided, decisions: decisions))
        let groups = formed.formation.groups
        func run(_ decisions: [[String: Any]], _ stations: [[String: Any]], registry url: URL = registryURL) async throws -> ProvisionalRegistryError {
            let file = try SyntheticStations.writeCross(workspace, "f-\(UUID().uuidString).json", undecided, decisions: decisions, stations: stations)
            return try await SyntheticStations.expectFailure(
                SyntheticStations.request(sides, registry: url, cross: file, output: workspace.output.appendingPathComponent("x")), workspace)
        }
        let all = SyntheticStations.assignments(groups)
        try check(try await run(SyntheticStations.decisions(undecided.formation.report, omit: ["syn-a-ke"]), all) == .stations("unreviewedCandidates"), "undecided")
        try check(try await run(decisions, Array(all.dropLast())) == .stations("unassignedGroup"), "unassigned group")
        var split = all
        let hubIndex = groups.firstIndex { $0.sides.count == 2 && $0.sides[0].members.count == 2 }!
        split[hubIndex]["sides"] = [["gtfsSourceID": SyntheticStations.sourceA, "stops": ["syn-a-hub1"]]]
        try check(try await run(decisions, split) == .stations("assignmentNotAGroup"), "not a group")
        var unknown = all
        unknown[0]["stationID"] = "stn_zzzzzzzzzzzzzzzz"
        try check(try await run(decisions, unknown) == .stations("unknownStation"), "unknown station")
        var twice = all
        twice[1]["stationID"] = twice[0]["stationID"]!
        try check(try await run(decisions, twice) == .stations("stationInTwoAssignments"), "one station twice")
        let shared = try SyntheticStations.writeRegistry(try await SyntheticStations.registry(sides, sameOperator: true), workspace, "shared.json")
        try check(try await run(decisions, all, registry: shared) == .stations("sidesShareOperator"), "shared operator")
        // After a first run, a different assignment would rebind held references.
        let first = workspace.output.appendingPathComponent("stations-1")
        guard case .success = await SyntheticStations.runRegistry(SyntheticStations.request(sides, registry: registryURL, cross: cross, output: first)) else {
            throw TestFailure(message: "first run failed")
        }
        let own = first.appendingPathComponent("registry.json")
        func rerun(_ ids: [MintedIdentifier], _ name: String) async throws -> ProvisionalRegistryError {
            let file = try SyntheticStations.writeCross(workspace, name, undecided, decisions: decisions, stations: SyntheticStations.assignments(groups, ids: ids))
            return try await SyntheticStations.expectFailure(
                SyntheticStations.request(sides, registry: own, cross: file, previous: (sides, cross), output: workspace.output.appendingPathComponent("y")), workspace)
        }
        // Every station moved: some now hold the other operator's references.
        try check(try await rerun(Array(SyntheticStations.stations.reversed()), "reversed.json") == .stations("stationHeldElsewhere"), "moved across operators")
        // Two one-operator stations swapped: their held references would rebind.
        let aOnly = groups.indices.filter { groups[$0].sides.count == 1 && groups[$0].sides[0].sourceID == SyntheticStations.sourceA }
        var ids = Array(SyntheticStations.stations.prefix(groups.count))
        ids.swapAt(aOnly[0], aOnly[1])
        let rebind = try await rerun(ids, "swapped.json")
        try check(rebind == .records(.identityMismatch), "\(rebind)")
    }),
    ("station-packet exports every candidate with evidence, templates, and groups once decided, printing only counts", { workspace in
        let (sides, registry, _) = try await SyntheticStations.decidedRun(workspace, "a")
        let output = workspace.output.appendingPathComponent("packet.json")
        let (packet, summary) = try await StationPacketCommand.run(
            SyntheticStations.request(sides, registry: registry, cross: nil, output: output), repositoryRoot: testRepositoryRoot)
        try check(summary == StationPacketSummary(candidates: 5, reviewed: 0, unreviewed: 5, groups: nil), "\(summary)")
        try check(packet.groups == nil && packet.assignmentTemplate == nil && packet.candidates.allSatisfy { $0.recordTemplate.outcome.isEmpty }, "decides nothing")
        try check(packet.candidates.filter(\.sameNeedsCitationOrProvenance).count == 3, "ヶ / ケ, subtitle, and english-only need a basis")
        try check(SyntheticRun.safe(summary.report()), "summary holds counts only")
        let bytes = try Data(contentsOf: output)
        try check(bytes == packet.encoded(), "published as built")
        // With every candidate decided: groups and an assignment proposal.
        let loaded = try await SyntheticStations.load(sides, registry: try MappingRegistry.decoded(from: try Data(contentsOf: registry)))
        let decided = try SyntheticStations.writeCross(workspace, "decided-only.json", loaded, decisions: SyntheticStations.decisions(loaded.formation.report))
        let (full, fullSummary) = try await StationPacketCommand.run(
            SyntheticStations.request(sides, registry: registry, cross: decided, output: workspace.output.appendingPathComponent("packet-2.json")),
            repositoryRoot: testRepositoryRoot)
        try check(fullSummary.groups == 10 && full.groups?.count == 10, "groups")
        try check(full.availableStationIDs?.count == 11 && full.assignmentTemplate?.count == 10
                  && full.assignmentTemplate!.allSatisfy { $0.reviewID.isEmpty }, "a proposal to adopt, not a record")
        // Refuses to replace an existing file.
        do { _ = try await StationPacketCommand.run(SyntheticStations.request(sides, registry: registry, cross: nil, output: output), repositoryRoot: testRepositoryRoot)
             throw TestFailure(message: "replaced a file") }
        catch let error as ProvisionalRegistryError { try check(error == .output(.outputExists), "\(error)") }
    }),
    ("review fix: a station holding another source's references cannot be assigned, so no operators join without a same record", { workspace in
        let (sides, registryURL, cross) = try await SyntheticStations.decidedRun(workspace, "a")
        var registry = try MappingRegistry.decoded(from: try Data(contentsOf: registryURL))
        // An earlier run for another pair left a reference on the first station.
        let other = "SYN-09/synthetic-other", sha = String(repeating: "a", count: 64)
        let provenance = try SourceReference(inputSHA256: sha, member: .init(name: "stops.txt", sha256: sha), table: "stops", recordIndex: nil,
                                             field: "stop_id", providerKey: ExactValue("syn-c1")!)
        registry = try MappingRegistry(revision: registry.revision, entities: registry.entities, references: registry.references + [
            try ProviderReference(canonicalID: SyntheticStations.stations[0], sourceID: other, namespace: .gtfsStopID, value: ExactValue("syn-c1")!,
                                  status: .active, firstSeenInputSHA256: sha, provenance: provenance, originalNames: [], attachedBy: "SYN-REVIEW-C1"),
        ])
        let url = try SyntheticStations.writeRegistry(registry, workspace, "held.json")
        let refused = try await SyntheticStations.expectFailure(
            SyntheticStations.request(sides, registry: url, cross: cross, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(refused == .stations("stationHeldElsewhere"), "\(refused)")
    }),
    ("review fix: one code on two rows of one station is one reference; one code on two stations is refused by name", { workspace in
        let (sides, registry, cross) = try await SyntheticStations.decidedRun(workspace, "w", a: SyntheticStations.tablesA(sharedCode: .withinGroup))
        let output = workspace.output.appendingPathComponent("stations-w")
        guard case .success(let result) = await SyntheticStations.runRegistry(SyntheticStations.request(sides, registry: registry, cross: cross, output: output))
        else { throw TestFailure(message: "shared code within a station failed") }
        let hub = SyntheticStations.resolve(result.registry, SyntheticStations.sourceA, .gtfsStopID, "syn-a-hub2")
        try check(hub != nil && SyntheticStations.resolve(result.registry, SyntheticStations.sourceA, .gtfsStopCode, "P01") == hub, "one P01 reference on the hub")
        let (acrossSides, acrossRegistry, acrossCross) = try await SyntheticStations.decidedRun(workspace, "x", a: SyntheticStations.tablesA(sharedCode: .acrossStations))
        let refused = try await SyntheticStations.expectFailure(
            SyntheticStations.request(acrossSides, registry: acrossRegistry, cross: acrossCross, output: workspace.output.appendingPathComponent("y")), workspace)
        try check(refused == .stations("stopCodeInTwoStations"), "\(refused)")
    }),
    ("review fix: station-order positions are evidence, in the digest and the packet", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let loaded = try await SyntheticStations.load(sides, registry: try await SyntheticStations.registry(sides))
        let hub = SyntheticStations.candidate(loaded.formation.report, "syn-a-hub1")
        try check(hub.sides[0].members.first { $0.stopID.text == "syn-a-hub1" }?.positions.map(\.positions) == [[1]], "position recorded")
        let packet = StationPacketCommand.make(loaded)
        try check(packet.candidates.first { $0.evidenceSHA256 == hub.evidenceSHA256 }?.sides[0].members[0].routes[0].positions == [1], "position in the packet")
        // Same order and neighbours, other stop_sequence values.
        let shifted = try await SyntheticStations.sides(workspace, "s", a: SyntheticStations.tablesA(sequenceStep: 10))
        let after = try await SyntheticStations.load(shifted, registry: try await SyntheticStations.registry(shifted))
        let moved = SyntheticStations.candidate(after.formation.report, "syn-a-hub1")
        try check(moved.sides[0].members[0].base.routes == hub.sides[0].members[0].base.routes, "neighbours unchanged")
        try check(moved.evidenceSHA256 != hub.evidenceSHA256, "positions change the digest")
    }),
    ("review fix: the packet treats a station record written in any side or stop order as assigned", { workspace in
        let sides = try await SyntheticStations.sides(workspace, "a")
        let registry = try await SyntheticStations.registry(sides)
        let registryURL = try SyntheticStations.writeRegistry(registry, workspace, "r.json")
        let undecided = try await SyntheticStations.load(sides, registry: registry)
        let decisions = SyntheticStations.decisions(undecided.formation.report)
        let formed = try await SyntheticStations.load(sides, registry: registry, cross: try SyntheticStations.writeCross(workspace, "d.json", undecided, decisions: decisions))
        let hub = formed.formation.groups.first { $0.sides.count == 2 && $0.sides[0].members.count == 2 }!
        let reversed: [[String: Any]] = hub.sides.reversed().map { ["gtfsSourceID": $0.sourceID, "stops": Array($0.members.map(\.providerKey.text).reversed())] }
        let one: [[String: Any]] = [["reviewID": "SYN-REVIEW-S1", "stationID": SyntheticStations.stations[0].rawValue, "sides": reversed]]
        let file = try SyntheticStations.writeCross(workspace, "one.json", undecided, decisions: decisions, stations: one)
        let (packet, _) = try await StationPacketCommand.run(
            SyntheticStations.request(sides, registry: registryURL, cross: file, output: workspace.output.appendingPathComponent("p.json")), repositoryRoot: testRepositoryRoot)
        try check(packet.assignmentTemplate?.count == 9, "the assigned hub is not proposed again: \(packet.assignmentTemplate?.count ?? -1)")
        try check(!(packet.assignmentTemplate ?? []).contains { $0.stationID == SyntheticStations.stations[0].rawValue }, "its station is not offered again")
    }),
]
