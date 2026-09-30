import Foundation

// network-packet and network-build — DEC-070's coordinate, topology, and
// membership commands. Offline tool only; every input and output lies outside
// the repository.
//
// Both read two operators' identified GTFS archives and the provisional
// registry that P2-S5 left (stations and lines bound to these exact inputs),
// plus the reviewer's network records once written.
//
//   - network-packet is read-only. It exports one owner-only file: every
//     station whose member points differ, with every row's exact point and
//     names, and every line's review cases (possible shortcuts, triangle
//     triggers, self-pairs) with their full evidence, each with an empty
//     record template. It decides nothing. Only counts are printed.
//   - network-build publishes, as one new directory: coordinates (with the
//     append-only history carried from `--previous-coordinates`), topology
//     (every candidate's evidence, included or excluded), membership, and a
//     report of aggregates. Held-back stations and lines are listed with
//     their reasons, never filled in.
//
// The registry is read, never written. No distance is computed.

// MARK: - Records file

struct NetworkRecordsFile: Decodable {
    static let currentVersion = 1

    struct Row: Decodable {
        let gtfsSourceID: String
        let stopID: String
        private enum CodingKeys: String, CodingKey, CaseIterable { case gtfsSourceID, stopID }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            gtfsSourceID = try c.decode(String.self, forKey: .gtfsSourceID)
            stopID = try c.decode(String.self, forKey: .stopID)
        }
    }

    struct Selected: Decodable {
        let gtfsSourceID: String
        let gtfsArchiveSHA256: String
        let stopID: String
        private enum CodingKeys: String, CodingKey, CaseIterable { case gtfsSourceID, gtfsArchiveSHA256, stopID }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            gtfsSourceID = try c.decode(String.self, forKey: .gtfsSourceID)
            gtfsArchiveSHA256 = try c.decode(String.self, forKey: .gtfsArchiveSHA256)
            stopID = try c.decode(String.self, forKey: .stopID)
        }
    }

    struct Coordinate: Decodable {
        let reviewID: String
        let stationID: MintedIdentifier
        let members: [Row]
        let selected: Selected
        let latitude: String
        let longitude: String
        let reason: String
        let evidenceSHA256: String
        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, stationID, members, selected, latitude, longitude, reason, evidenceSHA256 }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            stationID = try c.decode(MintedIdentifier.self, forKey: .stationID)
            members = try c.decode([Row].self, forKey: .members)
            selected = try c.decode(Selected.self, forKey: .selected)
            latitude = try c.decode(String.self, forKey: .latitude)
            longitude = try c.decode(String.self, forKey: .longitude)
            reason = try c.decode(String.self, forKey: .reason)
            evidenceSHA256 = try c.decode(String.self, forKey: .evidenceSHA256)
        }
    }

    struct Decision: Decodable {
        let stations: [MintedIdentifier]
        let decision: String
        let reason: String
        /// The intermediates of every alternative run the decision addresses.
        let runs: [[MintedIdentifier]]
        private enum CodingKeys: String, CodingKey, CaseIterable { case stations, decision, reason, runs }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            stations = try c.decode([MintedIdentifier].self, forKey: .stations)
            decision = try c.decode(String.self, forKey: .decision)
            reason = try c.decode(String.self, forKey: .reason)
            runs = try c.decode([[MintedIdentifier]].self, forKey: .runs)
        }
    }

    struct Topology: Decodable {
        let reviewID: String
        let lineID: MintedIdentifier
        let evidenceSHA256: String
        let decisions: [Decision]
        let ignoresSelfPairs: Bool
        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, lineID, evidenceSHA256, decisions, ignoresSelfPairs }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            lineID = try c.decode(MintedIdentifier.self, forKey: .lineID)
            evidenceSHA256 = try c.decode(String.self, forKey: .evidenceSHA256)
            decisions = try c.decodeIfPresent([Decision].self, forKey: .decisions) ?? []
            ignoresSelfPairs = try c.decodeIfPresent(Bool.self, forKey: .ignoresSelfPairs) ?? false
        }
    }

    let coordinates: [Coordinate]
    let topology: [Topology]

    private enum CodingKeys: String, CodingKey, CaseIterable { case schemaVersion, coordinates, topology }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guard try c.decode(Int.self, forKey: .schemaVersion) == Self.currentVersion else { throw MappingText.corrupted("unsupportedSchemaVersion", c) }
        coordinates = try c.decodeIfPresent([Coordinate].self, forKey: .coordinates) ?? []
        topology = try c.decodeIfPresent([Topology].self, forKey: .topology) ?? []
    }

    static func decoded(from data: Data) throws(ProvisionalRegistryError) -> NetworkRecordsFile {
        guard !RegistryJSON.repeatsKey([UInt8](data)) else { throw .records(.repeatedKey) }
        do { return try JSONDecoder().decode(NetworkRecordsFile.self, from: data) } catch { throw .records(.malformed) }
    }

    /// The validated records.
    func validated() throws(ProvisionalRegistryError) -> ([CoordinateRecord], [TopologyRecord]) {
        func row(_ source: String, _ stop: String) throws(ProvisionalRegistryError) -> CoordinateRecord.Row {
            guard MappingText.isToken(source), let value = ExactValue(stop) else { throw .records(.invalidRecord) }
            return .init(sourceID: source, stopID: value)
        }
        var coordinateRecords: [CoordinateRecord] = []
        for entry in coordinates {
            var members: [CoordinateRecord.Row] = []
            for member in entry.members { members.append(try row(member.gtfsSourceID, member.stopID)) }
            do {
                coordinateRecords.append(try CoordinateRecord(
                    reviewID: entry.reviewID, stationID: entry.stationID, members: members,
                    selected: try row(entry.selected.gtfsSourceID, entry.selected.stopID), selectedArchiveSHA256: entry.selected.gtfsArchiveSHA256,
                    latitude: entry.latitude, longitude: entry.longitude, reason: entry.reason, evidenceSHA256: entry.evidenceSHA256
                ))
            } catch let error as ProvisionalRegistryError { throw error } catch { throw .records(.invalidRecord) }
        }
        var topologyRecords: [TopologyRecord] = []
        for entry in topology {
            var decisions: [TopologyRecord.Decision] = []
            for decision in entry.decisions {
                guard decision.stations.count == 2, decision.stations.allSatisfy({ $0.kind == .station }),
                      let pair = StationPair(decision.stations[0], decision.stations[1]), ["include", "exclude"].contains(decision.decision)
                else { throw .records(.invalidRecord) }
                decisions.append(.init(pair: pair, include: decision.decision == "include", reason: decision.reason, runs: decision.runs))
            }
            do {
                topologyRecords.append(try TopologyRecord(
                    reviewID: entry.reviewID, lineID: entry.lineID, evidenceSHA256: entry.evidenceSHA256,
                    decisions: decisions, ignoresSelfPairs: entry.ignoresSelfPairs
                ))
            } catch { throw .records(.invalidRecord) }
        }
        return (coordinateRecords, topologyRecords)
    }
}

// MARK: - Artifacts

/// Encoded artifacts: deterministic JSON with sorted keys.
enum NetworkJSON {
    static func encode<T: Encodable>(_ value: T) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try! encoder.encode(value)
        data.append(0x0A)
        return data
    }
}

struct CoordinateArtifact: Codable, Equatable {
    static let currentVersion = 1

    struct Provenance: Codable, Equatable {
        let gtfsSourceID: String
        let gtfsArchiveSHA256: String
        let stopsMemberSHA256: String
        let stopID: String
        let latitude: String
        let longitude: String
    }

    /// A former selection, kept for good.
    struct HistoryEntry: Codable, Equatable {
        let rule: String
        let latitude: String
        let longitude: String
        let provenance: [Provenance]
        let reviewID: String?
    }

    struct Station: Codable, Equatable {
        let stationID: String
        /// `selected`, `heldBack`, or `absent` (no member row in these inputs).
        let status: String
        let classification: String?
        /// `singleRow`, `identicalPoints`, or `reviewed`.
        let rule: String?
        let latitude: String?
        let longitude: String?
        let provenance: [Provenance]
        let reviewID: String?
        let heldBack: String?
        let evidenceSHA256: String?
        let history: [HistoryEntry]

        var selection: HistoryEntry? {
            guard status == "selected", let rule, let latitude, let longitude else { return nil }
            return HistoryEntry(rule: rule, latitude: latitude, longitude: longitude, provenance: provenance, reviewID: reviewID)
        }
    }

    let artifactVersion: Int
    let stations: [Station]

    static func decoded(from data: Data) throws(ProvisionalRegistryError) -> CoordinateArtifact {
        guard !RegistryJSON.repeatsKey([UInt8](data)),
              let artifact = try? JSONDecoder().decode(CoordinateArtifact.self, from: data), artifact.artifactVersion == currentVersion,
              Set(artifact.stations.map(\.stationID)).count == artifact.stations.count
        else { throw .network("previousArtifactInvalid") }
        return artifact
    }

    /// The run's coordinates, with every previous selection kept as history:
    /// a changed or lost selection is appended, never overwritten.
    static func make(_ results: [StationCoordinateResult], previous: CoordinateArtifact?) -> CoordinateArtifact {
        func provenance(_ row: CoordinateRow) -> Provenance {
            .init(gtfsSourceID: row.sourceID, gtfsArchiveSHA256: row.archiveSHA256, stopsMemberSHA256: row.stopsMemberSHA256,
                  stopID: row.stopID.text, latitude: row.point[0], longitude: row.point[1])
        }
        let before = Dictionary(uniqueKeysWithValues: (previous?.stations ?? []).map { ($0.stationID, $0) })
        func history(_ id: String, replacing current: HistoryEntry?) -> [HistoryEntry] {
            guard let old = before[id] else { return [] }
            if let last = old.selection, last != current { return old.history + [last] }
            return old.history
        }
        var stations: [Station] = results.map { result in
            let id = result.stationID.rawValue
            switch result.outcome {
            case .selected(let coordinate, let rows, let reviewID):
                let rule = result.classification == .differentPoints ? "reviewed" : result.classification.rawValue
                let entry = HistoryEntry(rule: rule, latitude: NetworkText.point(coordinate.latitude), longitude: NetworkText.point(coordinate.longitude),
                                         provenance: rows.map(provenance), reviewID: reviewID)
                return Station(stationID: id, status: "selected", classification: result.classification.rawValue, rule: rule,
                               latitude: entry.latitude, longitude: entry.longitude, provenance: entry.provenance, reviewID: reviewID,
                               heldBack: nil, evidenceSHA256: result.evidenceSHA256, history: history(id, replacing: entry))
            case .heldBack(let reason):
                return Station(stationID: id, status: "heldBack", classification: result.classification.rawValue, rule: nil,
                               latitude: nil, longitude: nil, provenance: result.rows.map(provenance), reviewID: nil,
                               heldBack: reason.rawValue, evidenceSHA256: result.evidenceSHA256, history: history(id, replacing: nil))
            }
        }
        let current = Set(stations.map(\.stationID))
        for old in previous?.stations ?? [] where !current.contains(old.stationID) {
            stations.append(Station(stationID: old.stationID, status: "absent", classification: nil, rule: nil, latitude: nil, longitude: nil,
                                    provenance: [], reviewID: nil, heldBack: nil, evidenceSHA256: nil, history: history(old.stationID, replacing: nil)))
        }
        return CoordinateArtifact(artifactVersion: currentVersion, stations: stations.sorted { $0.stationID < $1.stationID })
    }
}

struct TopologyArtifact: Encodable {
    struct Run: Encodable { let intermediates: [String]; let trips: [String]; let qualifies: Bool }
    struct Candidate: Encodable {
        let stations: [String]
        let classification: String
        let included: Bool?
        let reviewID: String?
        let forward: Int
        let backward: Int
        let supportTrips: [String]
        let alternativeRuns: [Run]
    }
    struct SelfPair: Encodable { let station: String; let trips: [String] }
    struct Line: Encodable {
        let lineID: String
        let status: String
        let heldBack: String?
        let reviewID: String?
        let routes: [String]
        let tripCount: Int
        let servedStations: [String]
        let adjacencies: [[String]]
        let candidates: [Candidate]
        let selfPairs: [SelfPair]
        let evidenceSHA256: String
    }
    let artifactVersion: Int
    let lines: [Line]

    static func candidates(_ line: LineTopologyResult) -> [Candidate] {
        line.candidates.map { c in
            Candidate(stations: [c.pair.first.rawValue, c.pair.second.rawValue], classification: c.classification.rawValue,
                      included: c.included, reviewID: c.reviewID,
                      forward: c.forward, backward: c.backward, supportTrips: c.supportTrips,
                      alternativeRuns: c.alternativeRuns.map { .init(intermediates: $0.intermediates.map(\.rawValue), trips: $0.trips, qualifies: $0.qualifies) })
        }
    }

    static func make(_ lines: [LineTopologyResult]) -> TopologyArtifact {
        TopologyArtifact(artifactVersion: 1, lines: lines.map { line in
            let adjacencies = (line.topology?.adjacencies ?? []).map { $0.stationIDs.map(\.rawValue).sorted() }.sorted { $0.lexicographicallyPrecedes($1) }
            return Line(
                lineID: line.lineID.rawValue, status: line.topology == nil ? "heldBack" : "built", heldBack: line.heldBack?.rawValue,
                reviewID: line.reviewID, routes: line.routes, tripCount: line.tripCount, servedStations: line.servedStations.map(\.rawValue),
                adjacencies: adjacencies, candidates: candidates(line),
                selfPairs: line.selfPairs.map { .init(station: $0.station.rawValue, trips: $0.trips) }, evidenceSHA256: line.evidenceSHA256
            )
        })
    }
}

struct MembershipArtifact: Encodable {
    struct Station: Encodable { let stationID: String; let lineIDs: [String] }
    struct Line: Encodable { let lineID: String; let stationIDs: [String]; let agreesWithStations: Bool }
    let artifactVersion: Int
    let stations: [Station]
    let lines: [Line]

    static func make(_ result: NetworkResult) -> MembershipArtifact {
        let stations = result.membership.keys.sorted().map { Station(stationID: $0.rawValue, lineIDs: result.membership[$0]!.map(\.rawValue)) }
        let lines = result.lines.map { line in
            // DEC-057 D9: the line's stations are exactly those listing it.
            let listing = result.membership.filter { $0.value.contains(line.lineID) }.keys.sorted()
            return Line(lineID: line.lineID.rawValue, stationIDs: line.servedStations.map(\.rawValue),
                        agreesWithStations: line.topology.map { Set($0.stationIDs.map(\.rawValue)) == Set(listing.map(\.rawValue)) } ?? false)
        }
        return MembershipArtifact(artifactVersion: 1, stations: stations, lines: lines)
    }
}

/// Aggregates only: counts, hashes, and source identifiers.
struct NetworkReport: Encodable, Equatable {
    struct Shape: Encodable, Equatable { let expected: String; let passed: Bool; let cycles: Int; let degreeCounts: [String: Int] }
    let reportVersion: Int
    let inputs: [String: String]
    let stations: Int
    let stationsByClassification: [String: Int]
    let selectedByRule: [String: Int]
    let heldBackStations: [String: Int]
    let absentStations: Int
    let historyEntries: Int
    let lines: Int
    let builtLines: Int
    let heldBackLines: [String: Int]
    let membershipAgreement: Int
    let candidates: [String: Int]
    let included: Int
    let excluded: Int
    let selfPairs: Int
    let shapes: [Shape]
    let unusedCoordinateRecords: Int
    let unusedTopologyRecords: Int

    static func make(_ result: NetworkResult, _ coordinates: CoordinateArtifact, _ membership: MembershipArtifact, inputs: [NetworkSide]) -> NetworkReport {
        func count<S: Sequence>(_ values: S) -> [String: Int] where S.Element == String { Dictionary(grouping: values, by: { $0 }).mapValues(\.count) }
        let allCandidates = result.lines.flatMap(\.candidates)
        return NetworkReport(
            reportVersion: 1,
            inputs: Dictionary(uniqueKeysWithValues: inputs.map { ($0.sourceID, $0.archiveSHA256) }),
            stations: result.coordinates.count,
            stationsByClassification: count(result.coordinates.map(\.classification.rawValue)),
            selectedByRule: count(coordinates.stations.compactMap { $0.status == "selected" ? $0.rule : nil }),
            heldBackStations: count(coordinates.stations.compactMap(\.heldBack)),
            absentStations: coordinates.stations.filter { $0.status == "absent" }.count,
            historyEntries: coordinates.stations.reduce(0) { $0 + $1.history.count },
            lines: result.lines.count,
            builtLines: result.lines.filter { $0.topology != nil }.count,
            heldBackLines: count(result.lines.compactMap { $0.heldBack?.rawValue }),
            membershipAgreement: membership.lines.filter(\.agreesWithStations).count,
            candidates: count(allCandidates.map(\.classification.rawValue)),
            included: allCandidates.filter { $0.included == true }.count,
            excluded: allCandidates.filter { $0.included == false }.count,
            selfPairs: result.lines.reduce(0) { $0 + $1.selfPairs.count },
            shapes: result.shapes.map { .init(expected: $0.expected.rawValue, passed: $0.passed, cycles: $0.cycles,
                                              degreeCounts: Dictionary(uniqueKeysWithValues: $0.degreeCounts.map { (String($0.key), $0.value) })) },
            unusedCoordinateRecords: result.unusedCoordinateRecords, unusedTopologyRecords: result.unusedTopologyRecords
        )
    }
}

/// The owner-only review export.
struct NetworkPacket: Encodable {
    static let notice = "Contains provider values. Keep outside the repository with its inputs; never commit or publish. Possible shortcuts and triangles are review triggers, not proof; nothing is removed automatically (DEC-070)."

    struct Row: Encodable {
        let gtfsSourceID: String
        let gtfsArchiveSHA256: String
        let stopID: String
        let latitude: String
        let longitude: String
        let names: [String]
    }
    struct CoordinateTemplate: Encodable {
        let reviewID: String
        let stationID: String
        let members: [[String: String]]
        let selected: [String: String]
        let latitude: String
        let longitude: String
        let reason: String
        let evidenceSHA256: String
    }
    struct CoordinateCase: Encodable {
        let stationID: String
        let status: String
        let rows: [Row]
        let evidenceSHA256: String
        let recordTemplate: CoordinateTemplate
    }
    /// `runs` lists every alternative run the decision must address.
    struct DecisionTemplate: Encodable { let stations: [String]; let decision: String; let reason: String; let runs: [[String]] }
    struct TopologyTemplate: Encodable {
        let reviewID: String
        let lineID: String
        let evidenceSHA256: String
        let decisions: [DecisionTemplate]
        let ignoresSelfPairs: Bool
    }
    struct TopologyCase: Encodable {
        let lineID: String
        let status: String
        let reviewCandidates: [TopologyArtifact.Candidate]
        let selfPairs: [TopologyArtifact.SelfPair]
        let evidenceSHA256: String
        let recordTemplate: TopologyTemplate
    }

    let packetVersion: Int
    let notice: String
    let coordinateCases: [CoordinateCase]
    let topologyCases: [TopologyCase]

    static func make(_ result: NetworkResult) -> NetworkPacket {
        let coordinateCases = result.coordinates.filter { $0.classification == .differentPoints }.map { station -> CoordinateCase in
            let status: String
            switch station.outcome { case .selected: status = "reviewed"; case .heldBack(let reason): status = reason.rawValue }
            return CoordinateCase(
                stationID: station.stationID.rawValue, status: status,
                rows: station.rows.map { .init(gtfsSourceID: $0.sourceID, gtfsArchiveSHA256: $0.archiveSHA256, stopID: $0.stopID.text,
                                               latitude: $0.point[0], longitude: $0.point[1], names: $0.names.map { "\($0.language.text) \($0.value.text)" }) },
                evidenceSHA256: station.evidenceSHA256,
                recordTemplate: .init(
                    reviewID: "", stationID: station.stationID.rawValue,
                    members: station.rows.map { ["gtfsSourceID": $0.sourceID, "stopID": $0.stopID.text] },
                    selected: ["gtfsSourceID": "", "gtfsArchiveSHA256": "", "stopID": ""], latitude: "", longitude: "", reason: "",
                    evidenceSHA256: station.evidenceSHA256
                )
            )
        }
        let topologyCases = result.lines.filter { line in line.candidates.contains(where: \.needsReview) || !line.selfPairs.isEmpty }.map { line in
            let review = TopologyArtifact.candidates(line).filter { $0.classification != CandidateClass.included.rawValue }
            return TopologyCase(
                lineID: line.lineID.rawValue, status: line.heldBack?.rawValue ?? "reviewed", reviewCandidates: review,
                selfPairs: line.selfPairs.map { .init(station: $0.station.rawValue, trips: $0.trips) }, evidenceSHA256: line.evidenceSHA256,
                recordTemplate: .init(reviewID: "", lineID: line.lineID.rawValue, evidenceSHA256: line.evidenceSHA256,
                                      decisions: review.map { .init(stations: $0.stations, decision: "", reason: "", runs: $0.alternativeRuns.map(\.intermediates)) },
                                      ignoresSelfPairs: false)
            )
        }
        return NetworkPacket(packetVersion: 1, notice: notice, coordinateCases: coordinateCases, topologyCases: topologyCases)
    }
}

// MARK: - Commands

struct NetworkRequest {
    struct Side { let gtfsSourceID: String; let archivePath: String }
    let sides: [Side]
    let registryPath: String
    let recordsPath: String?
    let previousCoordinatesPath: String?
    let shapes: [(MintedIdentifier, ShapeKind)]
    let outputPath: String
}

struct NetworkBuildOutcome {
    let result: NetworkResult
    let coordinates: CoordinateArtifact
    let report: NetworkReport
}

enum NetworkCommand {
    static func load(_ request: NetworkRequest, _ root: FileIdentity) async throws(ProvisionalRegistryError) -> (NetworkResult, [NetworkSide]) {
        guard request.sides.count == 2, request.sides[0].gtfsSourceID != request.sides[1].gtfsSourceID,
              request.sides.allSatisfy({ MappingText.isToken($0.gtfsSourceID) }) else { throw .arguments }
        let registryChecked = try StationCommand.checkedPath(request.registryPath, "registry", root)
        let registryData = try ProvisionalRegistryCommand.readFile(registryChecked, "registry", root)
        let registry: MappingRegistry
        do { registry = try MappingRegistry.decoded(from: registryData) } catch { throw .registryFile }
        var sides: [NetworkSide] = []
        for side in request.sides {
            let checked = try StationCommand.checkedPath(side.archivePath, "archive", root)
            let read: IdentifiedArchive
            do {
                read = try await ArchiveReading.read(requestedPath: side.archivePath, resolvedPath: checked.resolved, checked: checked.identity,
                                                     repositoryRoot: root, limits: .standard)
            } catch { throw .input(error) }
            sides.append(NetworkSide(sourceID: side.gtfsSourceID, archiveSHA256: read.sha256, stopsMemberSHA256: read.memberSHA256("stops.txt")!,
                                     translationsMemberSHA256: read.memberSHA256("translations.txt"), feed: read.feed))
        }
        var coordinateRecords: [CoordinateRecord] = []
        var topologyRecords: [TopologyRecord] = []
        if let path = request.recordsPath {
            let checked = try StationCommand.checkedPath(path, "network records", root)
            (coordinateRecords, topologyRecords) = try NetworkRecordsFile.decoded(from: try ProvisionalRegistryCommand.readFile(checked, "network records", root)).validated()
        }
        do {
            let result = try NetworkArtifacts.build(sides, registry: registry, coordinateRecords: coordinateRecords,
                                                    topologyRecords: topologyRecords, shapes: request.shapes)
            return (result, sides)
        } catch {
            throw .network(kind(error))
        }
    }

    static func build(_ request: NetworkRequest, repositoryRoot root: FileIdentity) async throws(ProvisionalRegistryError) -> NetworkBuildOutcome {
        let publication = try StationRegistryCommand.outputDirectory(request.outputPath, root)
        var previous: CoordinateArtifact?
        if let path = request.previousCoordinatesPath {
            let checked = try StationCommand.checkedPath(path, "previous coordinates", root)
            previous = try CoordinateArtifact.decoded(from: try ProvisionalRegistryCommand.readFile(checked, "previous coordinates", root))
        }
        let (result, sides) = try await load(request, root)
        let coordinates = CoordinateArtifact.make(result.coordinates, previous: previous)
        let membership = MembershipArtifact.make(result)
        let report = NetworkReport.make(result, coordinates, membership, inputs: sides)
        do {
            try publication.publish([
                ("coordinates.json", NetworkJSON.encode(coordinates)),
                ("membership.json", NetworkJSON.encode(membership)),
                ("report.json", NetworkJSON.encode(report)),
                ("topology.json", NetworkJSON.encode(TopologyArtifact.make(result.lines))),
            ])
        } catch { throw .output(error) }
        return NetworkBuildOutcome(result: result, coordinates: coordinates, report: report)
    }

    static func packet(_ request: NetworkRequest, repositoryRoot root: FileIdentity) async throws(ProvisionalRegistryError) -> (NetworkPacket, NetworkResult) {
        guard request.previousCoordinatesPath == nil else { throw .arguments }
        let publication: ManifestPublication
        do {
            let name = (request.outputPath as NSString).lastPathComponent
            guard !name.isEmpty, name != ".", name != "..", !request.outputPath.hasSuffix("/") else { throw IntakeError.outputNameInvalid }
            let requested = (request.outputPath as NSString).deletingLastPathComponent
            guard let parent = resolvedPath(requested.isEmpty ? "." : requested) else { throw IntakeError.pathUnavailable(role: "output directory", errno: errno) }
            guard !isInsideRepository(parent, repositoryRoot: root) else { throw IntakeError.pathInsideRepository(role: "output") }
            publication = try ManifestPublication(checkedDirectory: parent, name: name, repositoryRoot: root)
            guard !publication.targetExists() else { throw IntakeError.outputExists }
        } catch let error as IntakeError { throw .output(error) } catch { throw .output(.publicationFailed(errno: EIO)) }
        let (result, _) = try await load(request, root)
        let packet = NetworkPacket.make(result)
        do { try publication.publish(NetworkJSON.encode(packet)) } catch { throw .output(error) }
        return (packet, result)
    }
}
