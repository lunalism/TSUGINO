import Foundation

// name-packet / name-build. A manifest names identified external inputs;
// every path is checked using existing intake/publication primitives. The
// command performs no acquisition, translates nothing, and never writes a registry.
struct RailNameRun: Codable {
    struct Archive: Codable { let sourceID: String; let path: String; let sha256: String }
    struct Railway: Codable { let sourceID: String; let path: String; let sha256: String }
    struct Document: Codable { let id: ExactValue; let path: String; let sha256: String }
    struct Shape: Codable { let lineID: MintedIdentifier; let kind: String }
    let schemaVersion: Int
    let archives: [Archive]
    let railways: [Railway]
    let historicalArchives: [Archive]
    let registryPath: String
    let registrySHA256: String
    let networkRecordsPath: String?
    let shapes: [Shape]
    let documents: [Document]
}
struct RailNameHistoryArtifact: Codable {
    var schemaVersion: Int = 1
    let names: NameHistory
    let titles: TitleHistory
}
struct RailNamePacket: Encodable {
    let schemaVersion = 1
    let notice = "Provider-bearing review evidence: owner-only, outside the repository. No choice is proposed or authorized. DEC-071."
    let names: [NameEvidence]
    let titles: [TitleEvidence]
    let titleStatuses: [TitleBindingResult.Status]
    let statuses: [RailNameOutcome.Status]
    let aliasStatuses: [RailNameOutcome.Status]
    let unusedReviews: Int
    let requiredNameRecordFields = ["schemaVersion", "reviewID", "reviewer", "date", "supersedes", "purpose", "selected", "value", "reason", "basis", "preferredSource", "aliasRule", "evidence", "selectionEvidenceSHA256", "reviewEvidenceSHA256"]
}
/// Arrays are explicitly ordered. Do not use synthesized Domain Set Codable
/// output for reproducible files; Domain values themselves keep their contracts.
struct NamedNetworkArtifact: Encodable {
    struct NamedStation: Encodable {
        let id: StationID
        let name: LocalizedRailName
        let coordinate: GeoCoordinate
        let lineIDs: [LineID]
    }
    struct NamedLine: Encodable {
        struct Topology: Encodable { let adjacencies: [[StationID]] }
        let id: LineID
        let operatorID: OperatorID
        let name: LocalizedRailName
        let topology: Topology
    }
    let schemaVersion = 1
    let complete: Bool
    let operators: [Operator]
    let stations: [NamedStation]
    let lines: [NamedLine]
    init(_ outcome: RailNameOutcome) {
        complete = outcome.complete
        operators = outcome.operators.sorted { $0.id.rawValue < $1.id.rawValue }
        stations = outcome.stations.sorted { $0.id.rawValue < $1.id.rawValue }.map { .init(id:$0.id,name:$0.name,coordinate:$0.coordinate,lineIDs:$0.lineIDs.sorted { $0.rawValue < $1.rawValue }) }
        lines = outcome.lines.sorted { $0.id.rawValue < $1.id.rawValue }.map { line in
            let edges = line.topology.adjacencies.map { $0.stationIDs.sorted { $0.rawValue < $1.rawValue } }.sorted { a,b in
                a.map(\.rawValue).lexicographicallyPrecedes(b.map(\.rawValue))
            }
            return .init(id:line.id,operatorID:line.operatorID,name:line.name,topology:.init(adjacencies:edges))
        }
    }
}
struct RailNameReport: Encodable {
    let schemaVersion = 1
    let complete: Bool
    let nameSlots: Int
    let validatedNameSlots: Int
    let heldNameSlots: Int
    let validatedBindings: Int
    let heldBindings: Int
    let heldAliases: Int
    let networkComplete: Bool
    let unusedReviews: Int
    let unusedAuthored: Int
    let unusedCrosswalks: Int
    let constructedOperators: Int
    let constructedLines: Int
    let constructedStations: Int
    let choices: Int
    let validations: Int
    let observations: Int
    let registrySHA256: String
    let inputs: [String]
    init(_ o: RailNameOutcome, registrySHA256: String, inputs: [String]) {
        complete = o.complete;networkComplete = o.networkComplete;nameSlots=o.statuses.count;validatedNameSlots=o.statuses.filter { $0.heldBack == nil }.count
        heldNameSlots=nameSlots-validatedNameSlots;validatedBindings=o.titleBindings.accepted.count;heldBindings=o.titleBindings.held.count
        heldAliases=o.aliasStatuses.filter { $0.heldBack != nil }.count
        unusedReviews=o.unusedReviews;unusedAuthored=o.unusedAuthored;unusedCrosswalks=o.unusedCrosswalks
        constructedOperators=o.operators.count;constructedLines=o.lines.count;constructedStations=o.stations.count
        choices=o.history.choices.count+o.titleBindings.history.choices.count;validations=o.history.validations.count+o.titleBindings.history.validations.count
        observations=o.history.observations.count+o.titleBindings.history.observations.count
        self.registrySHA256=registrySHA256;self.inputs=inputs
    }
}
enum RailNameCommand {
    static func read(_ path: String, root: FileIdentity) throws -> Data {
        let checked = try StationCommand.checkedPath(path,"name input",root)
        return try ProvisionalRegistryCommand.readFile(checked,"name input",root)
    }
    static func decode<T: Decodable>(_ type: T.Type, data: Data) throws -> T {
        guard !RegistryJSON.repeatsKey([UInt8](data)) else { throw NameReviewError.duplicate }
        do { return try JSONDecoder().decode(type,from:data) } catch { throw NameReviewError.malformed }
    }
    static func load(_ config: RailNameRun, root: FileIdentity) async throws -> RailNameInput {
        guard config.schemaVersion == 1 else { throw NameReviewError.schema }
        guard config.archives.count == 2, Set(config.documents.map(\.id)).count == config.documents.count else { throw NameReviewError.malformed }
        let registryData = try read(config.registryPath,root:root)
        guard sha256Hex(registryData) == config.registrySHA256 else { throw NameReviewError.staleRegistry }
        let registry = try MappingRegistry.decoded(from:registryData)
        func archive(_ config: RailNameRun.Archive) async throws -> RailNameInput.Static {
            guard MappingText.isToken(config.sourceID), MappingText.isSHA256(config.sha256) else { throw NameReviewError.malformed }
            let checked = try ArchiveReading.checkedPath(config.path,role:"name archive",repositoryRoot:root)
            let read = try await ArchiveReading.read(requestedPath:config.path,resolvedPath:checked.resolved,checked:checked.identity,repositoryRoot:root,limits:.standard)
            guard read.sha256 == config.sha256 else { throw NameReviewError.malformed }
            return .init(sourceID:config.sourceID,archive:read)
        }
        var sources: [RailNameInput.Static] = [], historical: [RailNameInput.Static] = [], railways: [RailNameInput.Railway] = []
        for a in config.archives { sources.append(try await archive(a)) }
        for a in config.historicalArchives { historical.append(try await archive(a)) }
        for r in config.railways {
            let read = try await RailwayValidation.readChecked(r.path,root)
            guard sha256Hex(read.data) == r.sha256, MappingText.isToken(r.sourceID) else { throw NameReviewError.malformed }
            railways.append(.init(sourceID:r.sourceID,sha256:r.sha256,records:read.records))
        }
        var documents: [ExactValue:String] = [:]
        for d in config.documents {
            let data = try read(d.path,root:root)
            guard sha256Hex(data) == d.sha256 else { throw NameReviewError.malformed }
            documents[d.id] = d.sha256
        }
        var coordinateRecords: [CoordinateRecord] = [], topologyRecords: [TopologyRecord] = []
        if let p = config.networkRecordsPath { (coordinateRecords,topologyRecords) = try NetworkRecordsFile.decoded(from:read(p,root:root)).validated() }
        let shapes = try config.shapes.map { s -> (MintedIdentifier,ShapeKind) in
            guard s.lineID.kind == .line else { throw NameReviewError.malformed }
            switch s.kind {
            case "loopPlusTail":return (s.lineID,.loopPlusTail)
            case "branch":return (s.lineID,.branch)
            default:throw NameReviewError.malformed
            }
        }
        let network = try NetworkArtifacts.build(sources.map(\.networkSide),registry:registry,coordinateRecords:coordinateRecords,topologyRecords:topologyRecords,shapes:shapes)
        return .init(sources:sources,railways:railways,historical:historical,registry:registry,registrySHA256:config.registrySHA256,network:network,documents:documents)
    }
    /// Packet and build both publish a NEW owner-only directory. A build with
    /// held names publishes explicit diagnostics/history but no named dataset.
    /// CLI returns failure for incomplete build, after preserving that evidence.
    static func run(configPath: String, recordsPath: String?, previousPath: String?, outputPath: String,
                    packetOnly: Bool, selectionsPath: String? = nil, root: FileIdentity) async throws -> RailNameReport {
        let publication = try StationRegistryCommand.outputDirectory(outputPath,root)
        let config = try decode(RailNameRun.self,data:read(configPath,root:root))
        let records = try recordsPath.map { try decode(RailNameRecords.self,data:read($0,root:root)) } ?? .init()
        let previous = try previousPath.map { try decode(RailNameHistoryArtifact.self,data:read($0,root:root)) }
        guard previous?.schemaVersion ?? 1 == 1 else { throw NameReviewError.schema }
        let input = try await load(config,root:root)
        let outcome = try RailNames.build(input,records:records,previousNames:previous?.names ?? .init(),previousTitles:previous?.titles ?? .init())
        let report = RailNameReport(outcome,registrySHA256:input.registrySHA256,inputs:(input.sources.map { $0.archive.sha256 } + input.railways.map(\.sha256)).sorted())
        var files: [(String,Data)] = [
            ("packet.json",NetworkJSON.encode(RailNamePacket(names:outcome.evidence,titles:outcome.titleBindings.evidence,titleStatuses:outcome.titleBindings.statuses,statuses:outcome.statuses,aliasStatuses:outcome.aliasStatuses,unusedReviews:outcome.unusedReviews))),
            ("report.json",NetworkJSON.encode(report))
        ]
        if let selectionsPath {
            guard packetOnly else { throw NameReviewError.malformed }
            let selections = try decode(RailNameSelections.self,data:read(selectionsPath,root:root))
            files.append(("review-templates.json", NetworkJSON.encode(try selections.templates(outcome,records:records))))
        }
        if !packetOnly {
            files += [("history.json",NetworkJSON.encode(RailNameHistoryArtifact(names:outcome.history,titles:outcome.titleBindings.history))),
                ("names.json",NetworkJSON.encode(NamedNetworkArtifact(outcome))),
                ("index.json",NetworkJSON.encode(outcome.index?.entries ?? []))]
        }
        // Recheck registry bytes before publishing; it is never modified here.
        guard sha256Hex(try read(config.registryPath,root:root)) == config.registrySHA256 else { throw NameReviewError.staleRegistry }
        try publication.publish(files,ownerOnlyFiles:true)
        return report
    }
}
