import Foundation

// Integration cases for the provisional-registry and mint commands. Every
// archive, Railway file, registry, record, identifier, and digest is
// invented: stops `syn-…`, routes `syn-route-…`, Railway records
// `syn:Railway.…`, codes `Q` / `Qb` / `R`, names "Synthetic …" and 合成….
// Every output goes to the run's temporary directory; nothing here is a
// production identifier or a real mapping.

enum SyntheticRun {
    static let gtfsSource = "SYN-01/synthetic-gtfs"
    static let railwaySource = "SYN-03/synthetic-railway"
    static let operatorA = MintedIdentifier("opr_0000000000000001")!
    static let lineQ = MintedIdentifier("lin_0000000000000001")!
    static let lineR = MintedIdentifier("lin_0000000000000002")!

    static func tables(agencyName: String = "Synthetic Transit", secondQRoute: Bool = false) -> [String: String] {
        var tables: [String: String] = [
            "agency.txt": """
                agency_id,agency_name,agency_url,agency_timezone,agency_lang
                syn-agency,\(agencyName),https://example.invalid,Asia/Tokyo,ja

                """,
            "stops.txt": """
                stop_id,stop_code,stop_name,stop_lat,stop_lon
                syn-q1,Q01,Synthetic Alpha,35.0,139.0
                syn-q2,Q02,Synthetic Hub,35.0,139.0
                syn-q3,Q03,Synthetic Beta,35.0,139.0
                syn-qb1,Qb01,Synthetic Gamma,35.0,139.0
                syn-r1,R01,Synthetic Delta,35.0,139.0
                syn-r2,R02,Synthetic Hub,35.0,139.0

                """,
            "routes.txt": """
                route_id,agency_id,route_long_name,route_type,route_color
                syn-route-q,syn-agency,合成キュー線,1,A1B2C3
                syn-route-r,syn-agency,合成アール線,1,D4E5F6

                """,
            "trips.txt": """
                route_id,service_id,trip_id
                syn-route-q,syn-weekday,syn-t1
                syn-route-q,syn-weekday,syn-t2
                syn-route-r,syn-weekday,syn-t3

                """,
            "stop_times.txt": """
                trip_id,arrival_time,departure_time,stop_id,stop_sequence
                syn-t1,05:00:00,05:00:00,syn-q1,1
                syn-t1,05:05:00,05:05:00,syn-q2,2
                syn-t1,05:10:00,05:10:00,syn-q3,3
                syn-t2,06:00:00,06:00:00,syn-q3,1
                syn-t2,06:05:00,06:05:00,syn-qb1,2
                syn-t3,07:00:00,07:00:00,syn-r1,1
                syn-t3,07:05:00,07:05:00,syn-r2,2

                """,
            "calendar.txt": """
                service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
                syn-weekday,1,1,1,1,1,0,0,20990101,20991231

                """,
            "feed_info.txt": """
                feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version
                Synthetic Publisher,https://example.invalid,ja,20990101,20991231,syn-1

                """,
            "translations.txt": """
                table_name,field_name,language,translation,field_value
                routes,route_long_name,en,Synthetic Q Line,合成キュー線
                routes,route_long_name,en,Synthetic R Line,合成アール線

                """,
        ]
        if secondQRoute {
            // A second route of line Q, e.g. a through section, sharing syn-q3.
            tables["stops.txt"]! += "syn-q4,Q04,Synthetic Epsilon,35.0,139.0\n"
            tables["routes.txt"]! += "syn-route-q2,syn-agency,合成キュー線,1,A1B2C3\n"
            tables["trips.txt"]! += "syn-route-q2,syn-weekday,syn-t4\n"
            tables["stop_times.txt"]! += "syn-t4,08:00:00,08:00:00,syn-q3,1\nsyn-t4,08:05:00,08:05:00,syn-q4,2\n"
        }
        return tables
    }

    static func railwayJSON(operator railwayOperator: String = "syn:Operator.A") -> Data {
        func record(_ id: String, _ code: String, _ ja: String, _ en: String, _ color: String, _ stations: [String]) -> String {
            let order = stations.enumerated().map { #"{"odpt:index": \#($0.offset + 1), "odpt:station": "\#($0.element)"}"# }.joined(separator: ", ")
            return """
                {"@type": "odpt:Railway", "@id": "\(id)", "owl:sameAs": "\(id.replacingOccurrences(of: "syn:Railway.", with: "syn:SameAs."))", "odpt:operator": "\(railwayOperator)", \
                "odpt:lineCode": "\(code)", "odpt:color": "\(color)", "odpt:railwayTitle": {"ja": "\(ja)", "en": "\(en)"}, \
                "odpt:stationOrder": [\(order)]}
                """
        }
        return Data(("[" + [
            record("syn:Railway.Q", "Q", "合成キュー線", "Synthetic Q Line", "#A1B2C3", ["syn:Station.Q1", "syn:Station.Q2", "syn:Station.Q3"]),
            record("syn:Railway.Qb", "Qb", "合成キュー線支線", "Synthetic Q Branch Line", "#A1B2C3", ["syn:Station.Q3", "syn:Station.Qb1"]),
            record("syn:Railway.R", "R", "合成アール線", "Synthetic R Line", "#D4E5F6", ["syn:Station.R1", "syn:Station.R2"]),
        ].joined(separator: ",") + "]").utf8)
    }

    /// A registry holding three provisional entities, as `mint` would leave
    /// them, and no reference.
    static let minted = try! MappingRegistry(
        revision: 1,
        entities: [operatorA, lineQ, lineR].map { CanonicalEntity(id: $0, status: .active) },
        references: []
    )

    struct Inputs {
        let archive: URL
        let railway: URL
        let records: URL
    }

    static func writeArchive(_ workspace: Workspace, _ name: String, agencyName: String = "Synthetic Transit", secondQRoute: Bool = false) throws -> URL {
        let tables = tables(agencyName: agencyName, secondQRoute: secondQRoute)
        let data = ZipWriter.archive(tables.keys.sorted().map { ZipEntry($0, Data(tables[$0]!.utf8)) })
        return try workspace.write(data, named: name)
    }

    static func writeRegistry(_ registry: MappingRegistry, _ workspace: Workspace, _ name: String) throws -> URL {
        let url = workspace.archives.appendingPathComponent(name)
        try registry.encoded().write(to: url)
        return url
    }

    /// The reviewer's records for an archive and Railway file: the operator
    /// binding, both line bindings with their evidence digests, and any
    /// extra revision records.
    static func writeRecords(
        _ workspace: Workspace, _ name: String, archive: URL, railway: URL,
        operatorID: MintedIdentifier = operatorA, revisions: [[String: Any]] = [],
        railwaySourceID: String = railwaySource, linesAndGroupings: Bool = true
    ) async throws -> URL {
        let identity = FileIdentity(path: archive.path)!
        let read = try await ArchiveReading.read(
            requestedPath: archive.path, resolvedPath: resolvedPath(archive.path)!, checked: identity,
            repositoryRoot: testRepositoryRoot, limits: .standard
        )
        let railwayData = try Data(contentsOf: railway)
        let records = try await ODPTRailwayReader.read(railwayData)
        let railwaySHA = sha256Hex(railwayData)

        // The digests a reviewer sees: evidence with the operator bound.
        func reference(_ source: String, _ namespace: ProviderNamespace, _ value: String, _ provenance: SourceReference) -> ProviderReference {
            try! ProviderReference(
                canonicalID: operatorA, sourceID: source, namespace: namespace, value: ExactValue(value)!, status: .active,
                firstSeenInputSHA256: provenance.inputSHA256, provenance: provenance, originalNames: []
            )
        }
        let withOperator = try MappingRegistry(revision: 1, entities: minted.entities, references: [
            reference(gtfsSource, .gtfsAgencyID, "syn-agency", try SourceReference(
                inputSHA256: read.sha256, member: .init(name: "agency.txt", sha256: read.memberSHA256("agency.txt")!),
                table: "agency", recordIndex: nil, field: "agency_id", providerKey: ExactValue("syn-agency")!)),
            reference(railwaySource, .odptOperator, "syn:Operator.A", try SourceReference(
                inputSHA256: railwaySHA, member: nil, table: nil, recordIndex: 0, field: "odpt:operator", providerKey: ExactValue("syn:Railway.Q")!)),
        ])
        let input = try LineBindingInput(
            gtfs: .init(sourceID: gtfsSource, archiveSHA256: read.sha256, routesMemberSHA256: read.memberSHA256("routes.txt")!,
                        stopsMemberSHA256: read.memberSHA256("stops.txt")!, feed: read.feed),
            railway: .init(sourceID: railwaySource, inputSHA256: railwaySHA, records: records),
            registry: withOperator
        )
        let q = LineBinding.evidence(for: [input.routeMember(ExactValue("syn-route-q")!), input.railwayMember(0), input.railwayMember(1)], in: input)!
        let r = LineBinding.evidence(for: [input.routeMember(ExactValue("syn-route-r")!), input.railwayMember(2)], in: input)!

        var object: [String: Any] = [
            "schemaVersion": 1,
            "gtfsSourceID": gtfsSource,
            "gtfsArchiveSHA256": read.sha256,
            "railwaySourceID": railwaySourceID,
            "railwayInputSHA256": railwaySHA,
            "operators": [["reviewID": "SYN-REVIEW-O1", "operatorID": operatorID.rawValue, "gtfsAgencyID": "syn-agency", "odptOperator": "syn:Operator.A"]],
            "lines": [
                ["reviewID": "SYN-REVIEW-L1", "lineID": lineQ.rawValue, "routes": ["syn-route-q"], "railwayRecords": ["syn:Railway.Q", "syn:Railway.Qb"],
                 "evidenceSHA256": q.evidenceSHA256,
                 "acceptances": [["railwayRecord": "syn:Railway.Qb", "reason": "Synthetic branch", "checks": ["japaneseTitle", "englishTitle"]]]],
                ["reviewID": "SYN-REVIEW-L2", "lineID": lineR.rawValue, "routes": ["syn-route-r"], "railwayRecords": ["syn:Railway.R"],
                 "evidenceSHA256": r.evidenceSHA256, "acceptances": []],
            ],
            "revisions": revisions,
        ]
        if !linesAndGroupings { object["lines"] = [] }
        let url = workspace.archives.appendingPathComponent(name)
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]).write(to: url)
        return url
    }

    static func inputs(_ workspace: Workspace, _ tag: String, agencyName: String = "Synthetic Transit", revisions: [[String: Any]] = []) async throws -> Inputs {
        let archive = try writeArchive(workspace, "feed-\(tag).zip", agencyName: agencyName)
        let railway = try workspace.write(railwayJSON(), named: "railway-\(tag).json")
        let records = try await writeRecords(workspace, "records-\(tag).json", archive: archive, railway: railway, revisions: revisions)
        return Inputs(archive: archive, railway: railway, records: records)
    }

    static func request(
        _ current: Inputs, previous: Inputs? = nil, registry: URL?, output: URL, launch: LaunchInputs = .none,
        railwaySourceID: String = railwaySource
    ) -> ProvisionalRegistryRequest {
        ProvisionalRegistryRequest(
            gtfsSourceID: gtfsSource, railwaySourceID: railwaySourceID,
            current: .init(archivePath: current.archive.path, railwayPath: current.railway.path, recordsPath: current.records.path),
            previous: previous.map { .init(archivePath: $0.archive.path, railwayPath: $0.railway.path, recordsPath: $0.records.path) },
            registryPath: registry?.path, outputPath: output.path, launchInputs: launch
        )
    }

    static func run(_ request: ProvisionalRegistryRequest, hooks: ProvisionalRegistryCommand.TestHooks = .init()) async -> Result<ProvisionalRegistryResult, ProvisionalRegistryError> {
        do { return .success(try await ProvisionalRegistryCommand.run(request, repositoryRoot: testRepositoryRoot, hooks: hooks)) }
        catch { return .failure(error) }
    }

    /// A failing run leaves the output directory exactly as it was.
    static func expectFailure(_ request: ProvisionalRegistryRequest, _ workspace: Workspace, hooks: ProvisionalRegistryCommand.TestHooks = .init()) async throws -> ProvisionalRegistryError {
        let before = try workspace.outputEntries()
        let result = await run(request, hooks: hooks)
        guard case .failure(let error) = result else { throw TestFailure(message: "expected a failure, the run succeeded") }
        let after = try workspace.outputEntries()
        try check(after == before, "the output directory changed after a failure: \(after)")
        try check(safe(error.description), "unsafe error text: \(error.description)")
        return error
    }

    /// No provider value, invented name, identifier, review text, or path.
    static func safe(_ text: String) -> Bool {
        !["syn-", "syn:", "Synthetic ", "合成", "opr_", "lin_", "REVIEW", "/private/", "/var/", "/Volumes/", "/Users/", ".json", ".zip"]
            .contains { text.contains($0) }
    }

    /// A first run on the minted registry: its output directory.
    static func firstRun(_ workspace: Workspace) async throws -> (Inputs, URL) {
        let inputs = try await inputs(workspace, "a")
        let registry = try writeRegistry(minted, workspace, "minted.json")
        let output = workspace.output.appendingPathComponent("run-1")
        guard case .success = await run(request(inputs, registry: registry, output: output)) else { throw TestFailure(message: "first run failed") }
        return (inputs, output)
    }
}

let provisionalRegistryTests: [TestCase] = [
    ("a first run publishes the registry and a safe report together, binding operators and lines by review", { workspace in
        let (_, output) = try await SyntheticRun.firstRun(workspace)
        let entries = try FileManager.default.contentsOfDirectory(atPath: output.path).sorted()
        try check(entries == ["registry.json", "report.json"], "\(entries)")
        let left = try workspace.outputEntries()
        try check(left == ["run-1"], "no temporary directory left: \(left)")

        let registry = try MappingRegistry.decoded(from: try Data(contentsOf: output.appendingPathComponent("registry.json")))
        func resolve(_ source: String, _ namespace: ProviderNamespace, _ value: String) -> MintedIdentifier? {
            registry.resolve(ProviderReferenceKey(sourceID: source, namespace: namespace, value: ExactValue(value)!))
        }
        try check(resolve(SyntheticRun.gtfsSource, .gtfsAgencyID, "syn-agency") == SyntheticRun.operatorA, "agency")
        try check(resolve(SyntheticRun.railwaySource, .odptOperator, "syn:Operator.A") == SyntheticRun.operatorA, "odpt operator")
        try check(resolve(SyntheticRun.gtfsSource, .gtfsRouteID, "syn-route-q") == SyntheticRun.lineQ, "route Q")
        try check(resolve(SyntheticRun.railwaySource, .odptRailwayID, "syn:Railway.Qb") == SyntheticRun.lineQ, "branch on line Q")
        try check(resolve(SyntheticRun.railwaySource, .odptRailwayLineCode, "Qb") == SyntheticRun.lineQ, "branch code on line Q")
        // owl:sameAs is its own reference, with its own provenance.
        try check(resolve(SyntheticRun.railwaySource, .odptRailwaySameAs, "syn:SameAs.Qb") == SyntheticRun.lineQ, "branch sameAs on line Q")
        let sameAs = registry.reference(for: ProviderReferenceKey(sourceID: SyntheticRun.railwaySource, namespace: .odptRailwaySameAs, value: ExactValue("syn:SameAs.Qb")!))
        try check(sameAs?.provenance.recordIndex == 1 && sameAs?.provenance.field == "owl:sameAs"
            && sameAs?.provenance.providerKey.text == "syn:Railway.Qb" && sameAs?.attachedBy != nil, "sameAs provenance")
        try check(resolve(SyntheticRun.gtfsSource, .gtfsRouteID, "syn-route-r") == SyntheticRun.lineR, "route R")
        let attached = registry.reference(for: ProviderReferenceKey(sourceID: SyntheticRun.gtfsSource, namespace: .gtfsRouteID, value: ExactValue("syn-route-q")!))
        try check(attached?.attachedBy == "SYN-REVIEW-L1:0", "the binding's review is kept: \(String(describing: attached?.attachedBy))")
        try check(registry.entities == SyntheticRun.minted.entities && registry.revision == 2, "no entity minted; one revision step")
        try check(!registry.references.contains { $0.namespace == .gtfsStopID || $0.namespace == .gtfsStopCode }, "no station reference in P2-S4")

        let reportData = try Data(contentsOf: output.appendingPathComponent("report.json"))
        let report = String(decoding: reportData, as: UTF8.self)
        try check(!["syn-", "syn:", "Synthetic ", "合成", "opr_", "lin_", "REVIEW"].contains { report.contains($0) }, "report leaks a value")
        let object = try JSONSerialization.jsonObject(with: reportData) as! [String: Any]
        let lines = object["lines"] as! [String: Int]
        try check(lines == ["lines": 2, "routes": 2, "railwayRecords": 3, "acceptedChecks": 2], "\(lines)")
        let grouping = object["grouping"] as! [String: Int]
        try check(grouping["stopRows"] == 6 && grouping["operatorLevelIdentities"] == 6, "\(grouping)")
        try check((object["reconciliation"] as! [Any]).count == 4, "two sources, two phases")
    }),
    ("an identical rerun with its previous inputs publishes byte-identical output", { workspace in
        let (inputs, first) = try await SyntheticRun.firstRun(workspace)
        let registry = first.appendingPathComponent("registry.json")
        let output = workspace.output.appendingPathComponent("run-2")
        guard case .success(let result) = await SyntheticRun.run(SyntheticRun.request(inputs, previous: inputs, registry: registry, output: output)) else {
            throw TestFailure(message: "rerun failed")
        }
        let before = try Data(contentsOf: registry)
        let after = try Data(contentsOf: output.appendingPathComponent("registry.json"))
        try check(before == after, "registry bytes differ")
        try check(result.report.registry.revision == 2 && result.report.reconciliation.allSatisfy { $0.changed == 0 && $0.newAttached == 0 }, "\(result.report.reconciliation)")
    }),
    ("a reviewed change on a new input is reconciled, keeping identities and history", { workspace in
        let (inputs, first) = try await SyntheticRun.firstRun(workspace)
        let renamed = try await SyntheticRun.inputs(workspace, "b", agencyName: "Synthetic Transit Renamed")
        let output = workspace.output.appendingPathComponent("run-2")
        let result = await SyntheticRun.run(SyntheticRun.request(renamed, previous: inputs, registry: first.appendingPathComponent("registry.json"), output: output))
        guard case .success(let success) = result else { throw TestFailure(message: "\(result)") }
        try check(success.report.registry.revision == 3, "revision")
        try check(success.report.reconciliation[0].changed == 1, "the agency name changed: \(success.report.reconciliation[0])")
        let agency = success.registry.reference(for: ProviderReferenceKey(sourceID: SyntheticRun.gtfsSource, namespace: .gtfsAgencyID, value: ExactValue("syn-agency")!))!
        try check(agency.canonicalID == SyntheticRun.operatorA && agency.originalNames.count == 2, "name history kept beside the new name")
    }),
    ("a missing or mismatched previous input fails with nothing published", { workspace in
        let (inputs, first) = try await SyntheticRun.firstRun(workspace)
        let registry = first.appendingPathComponent("registry.json")
        let missing = try await SyntheticRun.expectFailure(
            SyntheticRun.request(inputs, registry: registry, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(missing == .reconciliation("previousInput.incomplete"), "\(missing)")

        let other = try await SyntheticRun.inputs(workspace, "b", agencyName: "Synthetic Transit Renamed")
        let mismatched = try await SyntheticRun.expectFailure(
            SyntheticRun.request(inputs, previous: other, registry: registry, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(mismatched == .reconciliation("previousInput.notLastReconciled"), "\(mismatched)")
    }),
    ("an undecided transition and conflicts stop the run before publication", { workspace in
        let (inputs, first) = try await SyntheticRun.firstRun(workspace)
        let registryURL = first.appendingPathComponent("registry.json")

        // Retiring a value present in the input is DEC-068's undecided reuse case.
        let retire: [String: Any] = ["reviewID": "SYN-REVIEW-R1", "source": "gtfs", "namespace": "gtfs.route_id", "value": "syn-route-r", "action": "retire"]
        let withRetire = SyntheticRun.Inputs(
            archive: inputs.archive, railway: inputs.railway,
            records: try await SyntheticRun.writeRecords(workspace, "records-retire.json", archive: inputs.archive, railway: inputs.railway, revisions: [retire])
        )
        let undecided = try await SyntheticRun.expectFailure(
            SyntheticRun.request(withRetire, previous: inputs, registry: registryURL, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(undecided == .undecided("retireObservedValue"), "\(undecided)")

        // A retired route that reappears is a conflict.
        let registry = try MappingRegistry.decoded(from: try Data(contentsOf: registryURL))
        let retired = try MappingRegistry(revision: registry.revision, entities: registry.entities, references: registry.references.map { reference in
            guard reference.value.text == "syn-route-r" else { return reference }
            return try ProviderReference(
                canonicalID: reference.canonicalID, sourceID: reference.sourceID, namespace: reference.namespace, value: reference.value,
                status: .retired(review: "SYN-REVIEW-R0"), firstSeenInputSHA256: reference.firstSeenInputSHA256,
                provenance: reference.provenance, originalNames: reference.originalNames, attachedBy: reference.attachedBy
            )
        })
        let retiredURL = try SyntheticRun.writeRegistry(retired, workspace, "retired.json")
        let conflict = try await SyntheticRun.expectFailure(
            SyntheticRun.request(inputs, previous: inputs, registry: retiredURL, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(conflict == .conflicts(["retiredValueReappeared": 1]), "\(conflict)")

        // A record that would rebind a held key is refused.
        let rebinding = SyntheticRun.Inputs(
            archive: inputs.archive, railway: inputs.railway,
            records: try await SyntheticRun.writeRecords(workspace, "records-rebind.json", archive: inputs.archive, railway: inputs.railway,
                                                         operatorID: MintedIdentifier("opr_0000000000000009")!)
        )
        let rebind = try await SyntheticRun.expectFailure(
            SyntheticRun.request(rebinding, previous: inputs, registry: registryURL, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(rebind == .records(.identityMismatch), "\(rebind)")
    }),
    ("records for other inputs, repeated keys, or an unheld line are refused", { workspace in
        let inputs = try await SyntheticRun.inputs(workspace, "a")
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        let other = try await SyntheticRun.inputs(workspace, "b", agencyName: "Synthetic Transit Renamed")
        let crossed = SyntheticRun.Inputs(archive: inputs.archive, railway: inputs.railway, records: other.records)
        let forOther = try await SyntheticRun.expectFailure(SyntheticRun.request(crossed, registry: registry, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(forOther == .records(.forOtherInput), "\(forOther)")

        let text = try String(contentsOf: inputs.records, encoding: .utf8)
        let repeated = workspace.archives.appendingPathComponent("repeated.json")
        try Data(text.replacingOccurrences(of: #"{"gtfsArchiveSHA256""#, with: #"{"schemaVersion":1,"gtfsArchiveSHA256""#).utf8).write(to: repeated)
        let repeatedKey = try await SyntheticRun.expectFailure(SyntheticRun.request(
            SyntheticRun.Inputs(archive: inputs.archive, railway: inputs.railway, records: repeated), registry: registry,
            output: workspace.output.appendingPathComponent("x")), workspace)
        try check(repeatedKey == .records(.repeatedKey), "\(repeatedKey)")

        let empty = try SyntheticRun.writeRegistry(.empty, workspace, "empty.json")
        let unheld = try await SyntheticRun.expectFailure(SyntheticRun.request(inputs, registry: empty, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(unheld == .reconciliation("attachToUnknownIdentity"), "\(unheld)")
    }),
    ("inputs or outputs inside the repository are refused, and nothing is written there", { workspace in
        let inputs = try await SyntheticRun.inputs(workspace, "a")
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        let inside = URL(fileURLWithPath: repositoryPath).appendingPathComponent("provisional-registry-test-output")
        let outputError = try await SyntheticRun.expectFailure(SyntheticRun.request(inputs, registry: registry, output: inside), workspace)
        try check(outputError == .output(.pathInsideRepository(role: "output")), "\(outputError)")
        try check(!FileManager.default.fileExists(atPath: inside.path), "written inside the repository")

        let readme = URL(fileURLWithPath: repositoryPath).appendingPathComponent("Tools/StaticDataIntake/README.md")
        let insideInput = SyntheticRun.Inputs(archive: readme, railway: inputs.railway, records: inputs.records)
        let inputError = try await SyntheticRun.expectFailure(SyntheticRun.request(insideInput, registry: registry, output: workspace.output.appendingPathComponent("x")), workspace)
        try check(inputError == .input(.pathInsideRepository(role: "archive")), "\(inputError)")
    }),
    ("an existing output, or one that appears before the rename, is never replaced", { workspace in
        let inputs = try await SyntheticRun.inputs(workspace, "a")
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        let output = workspace.output.appendingPathComponent("taken")
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: false)
        let exists = try await SyntheticRun.expectFailure(SyntheticRun.request(inputs, registry: registry, output: output), workspace)
        try check(exists == .output(.outputExists), "\(exists)")

        let racing = workspace.output.appendingPathComponent("racing")
        var hooks = ProvisionalRegistryCommand.TestHooks()
        hooks.beforePublication = { try? FileManager.default.createDirectory(at: racing, withIntermediateDirectories: false) }
        let result = await SyntheticRun.run(SyntheticRun.request(inputs, registry: registry, output: racing), hooks: hooks)
        try check(result == .failure(.output(.outputExists)), "\(result)")
        try check(try FileManager.default.contentsOfDirectory(atPath: racing.path).isEmpty, "the racing directory was written into")
        let left = try workspace.outputEntries()
        try check(left == ["racing", "taken"], "temporary directory left: \(left)")
    }),
    ("a failure part-way through publication leaves no partial pair and no temporary directory", { workspace in
        let inputs = try await SyntheticRun.inputs(workspace, "a")
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        var hooks = ProvisionalRegistryCommand.TestHooks()
        hooks.afterFirstFile = { throw TestFailure(message: "simulated") }
        let failure = try await SyntheticRun.expectFailure(
            SyntheticRun.request(inputs, registry: registry, output: workspace.output.appendingPathComponent("x")), workspace, hooks: hooks)
        try check(failure == .output(.publicationFailed(errno: EIO)), "\(failure)")
        let left = try workspace.outputEntries()
        try check(left.isEmpty, "\(left)")
    }),
    ("the Railway source identifier is bound to the reviewed records and cannot substitute the registry's source", { workspace in
        let (inputs, first) = try await SyntheticRun.firstRun(workspace)
        let registry = first.appendingPathComponent("registry.json")
        // Records written for one Railway source, run under another.
        let crossed = try await SyntheticRun.expectFailure(
            SyntheticRun.request(inputs, previous: inputs, registry: registry, output: workspace.output.appendingPathComponent("x"), railwaySourceID: "SYN-04/other-railway"),
            workspace)
        try check(crossed == .records(.forOtherInput), "\(crossed)")
        // Records and run agree on another source, but the registry holds
        // these Railway values under the first source.
        let other = SyntheticRun.Inputs(archive: inputs.archive, railway: inputs.railway,
            records: try await SyntheticRun.writeRecords(workspace, "records-other.json", archive: inputs.archive, railway: inputs.railway, railwaySourceID: "SYN-04/other-railway"))
        let substituted = try await SyntheticRun.expectFailure(
            SyntheticRun.request(other, registry: registry, output: workspace.output.appendingPathComponent("x"), railwaySourceID: "SYN-04/other-railway"), workspace)
        try check(substituted == .sourceMismatch, "\(substituted)")
    }),
    ("mint makes provisional station identifiers only on request, adding entities and no reference (DEC-069 §D2)", { workspace in
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        let output = workspace.output.appendingPathComponent("s.json")
        let minted = try ProvisionalMint.run(kind: .station, count: 3, registryPath: registry.path, outputPath: output.path, repositoryRoot: testRepositoryRoot)
        let stations = minted.entities.filter { $0.id.kind == .station }
        try check(stations.count == 3 && minted.entities.count == SyntheticRun.minted.entities.count + 3, "three station entities added")
        try check(minted.references == SyntheticRun.minted.references && minted.revision == SyntheticRun.minted.revision + 1, "no reference, one revision")
        try check(try MappingRegistry.decoded(from: try Data(contentsOf: output)) == minted, "published as minted")
        // Zero is not a request.
        do {
            _ = try ProvisionalMint.run(kind: .station, count: 0, registryPath: nil,
                                        outputPath: workspace.output.appendingPathComponent("z.json").path, repositoryRoot: testRepositoryRoot)
            throw TestFailure(message: "minted zero")
        } catch let error as ProvisionalRegistryError {
            try check(error == .arguments, "\(error)")
        }
    }),
    ("review-packet exports the digests a reviewer needs to a new file, printing only counts", { workspace in
        let full = try await SyntheticRun.inputs(workspace, "a")
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        let operatorsOnly = SyntheticRun.Inputs(archive: full.archive, railway: full.railway,
            records: try await SyntheticRun.writeRecords(workspace, "records-operators.json", archive: full.archive, railway: full.railway, linesAndGroupings: false))
        let output = workspace.output.appendingPathComponent("packet.json")
        let request = ReviewPacketRequest(
            gtfsSourceID: SyntheticRun.gtfsSource, railwaySourceID: SyntheticRun.railwaySource,
            inputs: .init(archivePath: operatorsOnly.archive.path, railwayPath: operatorsOnly.railway.path, recordsPath: operatorsOnly.records.path),
            registryPath: registry.path, outputPath: output.path
        )
        let (packet, summary) = try await ReviewPacketCommand.run(request, repositoryRoot: testRepositoryRoot)
        try check(try workspace.outputEntries() == ["packet.json"], "one new file")

        // The digests are the ones a full run checks: the full records,
        // written from the same evidence, pass.
        let fullRecords = try JSONSerialization.jsonObject(with: Data(contentsOf: full.records)) as! [String: Any]
        let digests = (fullRecords["lines"] as! [[String: Any]]).map { $0["evidenceSHA256"] as! String }
        try check(packet.lineProposals.map(\.evidenceSHA256) == digests, "packet digests match the reviewed records")
        try check(packet.lineProposals[0].routes == ["syn-route-q"] && packet.lineProposals[0].railwayRecords == ["syn:Railway.Q", "syn:Railway.Qb"], "Q proposal")
        try check(packet.lineProposals[0].findings.map(\.check) == ["japaneseTitle", "englishTitle"], "branch findings")
        try check(packet.routes.allSatisfy { $0.operatorID == SyntheticRun.operatorA.rawValue }, "operators resolve as they will once applied")
        try check(packet.activeLineIDs == [SyntheticRun.lineQ.rawValue, SyntheticRun.lineR.rawValue], "line IDs to name")
        try check(packet.groupingHeldBack.count == 1 && packet.notice.contains("never commit"), "grouping and notice")

        // The packet holds provider values; the printed summary holds none.
        let written = String(decoding: try Data(contentsOf: output), as: UTF8.self)
        try check(written.contains("syn-route-q"), "the packet is the reviewer's material")
        try check(SyntheticRun.safe(summary.report()), "summary leaks: \(summary.report())")
        try check(summary.lineProposals == 2 && summary.groupingHeldBack == 1, "\(summary)")

        // Never replaces a file, never writes inside the repository.
        do {
            _ = try await ReviewPacketCommand.run(request, repositoryRoot: testRepositoryRoot)
            throw TestFailure(message: "an existing packet was replaced")
        } catch let error as ProvisionalRegistryError {
            try check(error == .output(.outputExists), "\(error)")
        }
        let inside = ReviewPacketRequest(
            gtfsSourceID: SyntheticRun.gtfsSource, railwaySourceID: SyntheticRun.railwaySource, inputs: request.inputs, registryPath: registry.path,
            outputPath: URL(fileURLWithPath: repositoryPath).appendingPathComponent("review-packet-test.json").path
        )
        do {
            _ = try await ReviewPacketCommand.run(inside, repositoryRoot: testRepositoryRoot)
            throw TestFailure(message: "a packet was written inside the repository")
        } catch let error as ProvisionalRegistryError {
            try check(error == .output(.pathInsideRepository(role: "output")), "\(error)")
        }
    }),
    ("review-packet exports exact evidence for a reviewer-selected set of several routes and records, which provisional-registry accepts unchanged", { workspace in
        let archive = try SyntheticRun.writeArchive(workspace, "feed-q2.zip", secondQRoute: true)
        let railway = try workspace.write(SyntheticRun.railwayJSON(), named: "railway-q2.json")
        let operatorsOnly = try await SyntheticRun.writeRecords(workspace, "records-operators.json", archive: archive, railway: railway, linesAndGroupings: false)
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        let selections: [[String: Any]] = [
            ["label": "SYN-SELECT-Q", "routes": ["syn-route-q", "syn-route-q2"], "railwayRecords": ["syn:Railway.Q", "syn:Railway.Qb"]],
            ["label": "SYN-SELECT-R", "routes": ["syn-route-r"], "railwayRecords": ["syn:Railway.R"]],
        ]
        let result = try await SyntheticSelection.packet(workspace, archive: archive, railway: railway, records: operatorsOnly, registry: registry, selections: selections)
        guard case .success(let (packet, summary)) = result else { throw TestFailure(message: "\(result)") }
        try check(summary.selections == 2 && SyntheticRun.safe(summary.report()), "summary: \(summary.report())")
        let q = packet.selectedLineEvidence[0]
        try check(q.routes == ["syn-route-q", "syn-route-q2"] && q.railwayRecords == ["syn:Railway.Q", "syn:Railway.Qb"], "members")
        // Checked against both routes: the branch code is not a prefix on q2.
        try check(q.findings.map { "\($0.member) \($0.check)" } == [
            "syn:Railway.Qb lineCode", "syn:Railway.Qb japaneseTitle", "syn:Railway.Qb englishTitle",
        ], "\(q.findings)")

        // Records written from the packet, digests and acceptances unchanged.
        var records = try JSONSerialization.jsonObject(with: Data(contentsOf: operatorsOnly)) as! [String: Any]
        records["lines"] = zip(packet.selectedLineEvidence, [SyntheticRun.lineQ, SyntheticRun.lineR]).map { evidence, line -> [String: Any] in
            let byMember = Dictionary(grouping: evidence.findings, by: \.member)
            return [
                "reviewID": "SYN-REVIEW-\(evidence.label)", "lineID": line.rawValue, "routes": evidence.routes,
                "railwayRecords": evidence.railwayRecords, "evidenceSHA256": evidence.evidenceSHA256,
                "acceptances": byMember.keys.sorted().map { member -> [String: Any] in
                    [(evidence.routes.contains(member) ? "route" : "railwayRecord"): member, "reason": "Synthetic review", "checks": byMember[member]!.map(\.check)]
                },
            ]
        }
        let full = workspace.archives.appendingPathComponent("records-full.json")
        try JSONSerialization.data(withJSONObject: records, options: [.sortedKeys]).write(to: full)
        let run = await SyntheticRun.run(SyntheticRun.request(
            SyntheticRun.Inputs(archive: archive, railway: railway, records: full), registry: registry, output: workspace.output.appendingPathComponent("run")))
        guard case .success(let outcome) = run else { throw TestFailure(message: "\(run)") }
        let q2 = outcome.registry.resolve(ProviderReferenceKey(sourceID: SyntheticRun.gtfsSource, namespace: .gtfsRouteID, value: ExactValue("syn-route-q2")!))
        try check(q2 == SyntheticRun.lineQ && outcome.report.lines.lines == 2 && outcome.report.lines.routes == 3, "two routes, one LineID")
    }),
    ("an ambiguous selection is exported with its ambiguity; mismatched selections are refused by kind", { workspace in
        let archive = try SyntheticRun.writeArchive(workspace, "feed-q2.zip", secondQRoute: true)
        let railway = try workspace.write(SyntheticRun.railwayJSON(), named: "railway-q2.json")
        let operatorsOnly = try await SyntheticRun.writeRecords(workspace, "records-operators.json", archive: archive, railway: railway, linesAndGroupings: false)
        let registry = try SyntheticRun.writeRegistry(SyntheticRun.minted, workspace, "minted.json")
        func packet(_ selections: [[String: Any]], hashes: [String: String] = [:]) async throws -> Result<(ReviewPacket, ReviewPacketSummary), ProvisionalRegistryError> {
            try await SyntheticSelection.packet(workspace, archive: archive, railway: railway, records: operatorsOnly, registry: registry, selections: selections, overrides: hashes)
        }

        // Record Q is also a candidate of route q, left out: exported as a
        // uniqueCounterpart finding naming it.
        let ambiguous = try await packet([["label": "SYN-SELECT-A", "routes": ["syn-route-q2"], "railwayRecords": ["syn:Railway.Q"]]])
        guard case .success(let (result, _)) = ambiguous else { throw TestFailure(message: "\(ambiguous)") }
        let counterpart = result.selectedLineEvidence[0].findings.first { $0.check == "uniqueCounterpart" }
        try check(counterpart?.routes == ["syn-route-q"], "\(result.selectedLineEvidence[0].findings)")

        let cases: [([[String: Any]], [String: String], ProvisionalRegistryError.SelectionProblem)] = [
            ([["label": "SYN-SELECT-X", "routes": ["syn-route-x"]]], [:], .unknownMember),
            ([["label": "SYN-SELECT-X", "railwayRecords": ["syn:Railway.X"]]], [:], .unknownMember),
            ([["label": "SYN-SELECT-X", "routes": ["syn-route-q", "syn-route-q"]]], [:], .repeatedMember),
            ([["label": "SYN-SELECT-X", "routes": ["syn-route-q"]], ["label": "SYN-SELECT-Y", "routes": ["syn-route-q"]]], [:], .memberInTwoSelections),
            ([["label": "SYN-SELECT-X"]], [:], .invalidSelection),
            ([["label": "SYN SELECT", "routes": ["syn-route-q"]]], [:], .invalidSelection),
            ([["label": "SYN-SELECT-X", "routes": ["syn-route-q"]]], ["gtfsArchiveSHA256": String(repeating: "e", count: 64)], .forOtherInput),
            ([["label": "SYN-SELECT-X", "routes": ["syn-route-q"]]], ["railwaySourceID": "SYN-04/other-railway"], .forOtherInput),
        ]
        for (selections, overrides, expected) in cases {
            let refused = try await packet(selections, hashes: overrides)
            guard case .failure(let error) = refused else { throw TestFailure(message: "accepted: \(expected)") }
            try check(error == .selection(expected) && SyntheticRun.safe(error.description), "\(expected): \(error)")
        }
        let left = try workspace.outputEntries()
        try check(left.count == 1, "only the accepted packet was published: \(left)")
    }),
    ("a selection crossing operators, or with an unbound operator, is refused", { workspace in
        let archive = try SyntheticRun.writeArchive(workspace, "feed.zip")
        // One operator per Railway input (DEC-067): every record is operator B.
        let railway = try workspace.write(SyntheticRun.railwayJSON(operator: "syn:Operator.B"), named: "railway-b.json")
        let registry = try SyntheticRun.writeRegistry(try MappingRegistry(
            revision: 1, entities: SyntheticRun.minted.entities + [CanonicalEntity(id: MintedIdentifier("opr_0000000000000002")!, status: .active)], references: []
        ), workspace, "minted-b.json")
        // Operator B unbound: only the agency has an operator record.
        let written = try await SyntheticRun.writeRecords(workspace, "records-written.json", archive: archive, railway: railway, linesAndGroupings: false)
        var agencyOnly = try JSONSerialization.jsonObject(with: Data(contentsOf: written)) as! [String: Any]
        agencyOnly["operators"] = [["reviewID": "SYN-REVIEW-O1", "operatorID": SyntheticRun.operatorA.rawValue, "gtfsAgencyID": "syn-agency"]]
        let onlyA = workspace.archives.appendingPathComponent("records-a.json")
        try JSONSerialization.data(withJSONObject: agencyOnly, options: [.sortedKeys]).write(to: onlyA)
        let unbound = try await SyntheticSelection.packet(workspace, archive: archive, railway: railway, records: onlyA, registry: registry,
                                                           selections: [["label": "SYN-SELECT-R", "routes": ["syn-route-r"], "railwayRecords": ["syn:Railway.R"]]])
        try check(unbound.failureValue == .selection(.operatorUnbound), "\(unbound)")

        // Operator B bound to its own identity: route r and record R cross.
        var records = try JSONSerialization.jsonObject(with: Data(contentsOf: onlyA)) as! [String: Any]
        var operators = records["operators"] as! [[String: Any]]
        operators.append(["reviewID": "SYN-REVIEW-O2", "operatorID": "opr_0000000000000002", "odptOperator": "syn:Operator.B"])
        records["operators"] = operators
        let both = workspace.archives.appendingPathComponent("records-ab.json")
        try JSONSerialization.data(withJSONObject: records, options: [.sortedKeys]).write(to: both)
        let crossing = try await SyntheticSelection.packet(workspace, archive: archive, railway: railway, records: both, registry: registry,
                                                            selections: [["label": "SYN-SELECT-R", "routes": ["syn-route-r"], "railwayRecords": ["syn:Railway.R"]]])
        try check(crossing.failureValue == .selection(.crossesOperatorBoundary), "\(crossing)")
    }),
    ("mint adds provisional entities on request and publishes a new registry file only", { workspace in
        let output = workspace.output.appendingPathComponent("minted.json")
        let minted = try ProvisionalMint.run(kind: .line, count: 3, registryPath: nil, outputPath: output.path, repositoryRoot: testRepositoryRoot)
        try check(minted.entities.count == 3 && minted.entities.allSatisfy { $0.id.kind == .line } && minted.references.isEmpty && minted.revision == 1, "\(minted)")
        try check(try MappingRegistry.decoded(from: try Data(contentsOf: output)) == minted, "published bytes")
        let more = try ProvisionalMint.run(kind: .railwayOperator, count: 1, registryPath: output.path,
                                           outputPath: workspace.output.appendingPathComponent("more.json").path, repositoryRoot: testRepositoryRoot)
        try check(more.entities.count == 4 && more.revision == 2 && Set(minted.entities).isSubset(of: Set(more.entities)), "existing entities kept")
        do {
            _ = try ProvisionalMint.run(kind: .line, count: 1, registryPath: nil, outputPath: output.path, repositoryRoot: testRepositoryRoot)
            throw TestFailure(message: "an existing file was replaced")
        } catch let error as ProvisionalRegistryError {
            try check(error == .output(.outputExists), "\(error)")
        }
    }),
]

enum SyntheticSelection {
    /// Writes a selection file for the inputs (with any field overridden) and
    /// runs review-packet into a new file in the workspace output.
    static func packet(
        _ workspace: Workspace, archive: URL, railway: URL, records: URL, registry: URL,
        selections: [[String: Any]], overrides: [String: String] = [:]
    ) async throws -> Result<(ReviewPacket, ReviewPacketSummary), ProvisionalRegistryError> {
        var object: [String: Any] = [
            "schemaVersion": 1,
            "gtfsSourceID": SyntheticRun.gtfsSource, "gtfsArchiveSHA256": sha256Hex(try Data(contentsOf: archive)),
            "railwaySourceID": SyntheticRun.railwaySource, "railwayInputSHA256": sha256Hex(try Data(contentsOf: railway)),
            "selections": selections,
        ]
        for (key, value) in overrides { object[key] = value }
        let selection = workspace.archives.appendingPathComponent("selection-\(UUID().uuidString).json")
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]).write(to: selection)
        let request = ReviewPacketRequest(
            gtfsSourceID: SyntheticRun.gtfsSource, railwaySourceID: SyntheticRun.railwaySource,
            inputs: .init(archivePath: archive.path, railwayPath: railway.path, recordsPath: records.path),
            registryPath: registry.path, selectionPath: selection.path,
            outputPath: workspace.output.appendingPathComponent("packet-\(UUID().uuidString).json").path
        )
        do { return .success(try await ReviewPacketCommand.run(request, repositoryRoot: testRepositoryRoot)) }
        catch { return .failure(error) }
    }
}

extension Result {
    var failureValue: Failure? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
