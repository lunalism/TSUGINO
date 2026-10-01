import Foundation
import CryptoKit

// Runtime metadata identifies inputs, but never embeds provider/editorial records.
nonisolated struct RailwayBuildInput: Codable, Equatable, Sendable {
    let role: String
    let sha256: String
}
nonisolated struct RailwayArtifactRevision: Codable, Equatable, Sendable {
    let dataVersion: ExactValue
    let registryRevision: Int
    let inputs: [RailwayBuildInput]
    let contentSHA256: String
    let previousSHA256: String?
}
nonisolated struct RailwayArtifactMetadata: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let revisions: [RailwayArtifactRevision]
    var current: RailwayArtifactRevision { revisions[revisions.count - 1] }
}

// Canonical arrays avoid Set iteration order in Domain Codable shapes.
// These are storage DTOs; the Domain encodings remain unchanged.
nonisolated struct StoredStation: Codable, Sendable {
    let id: StationID
    let name: LocalizedRailName
    let coordinate: GeoCoordinate
    let lineIDs: [LineID]
    init(_ s: Station) {
        id = s.id; name = s.name; coordinate = s.coordinate
        lineIDs = s.lineIDs.sorted { RailwayArtifact.less($0.rawValue, $1.rawValue) }
    }
    func domain() throws -> Station {
        guard lineIDs.count == Set(lineIDs).count else { throw RailwayRepositoryError.malformed }
        return Station(id: id, name: name, coordinate: coordinate, lineIDs: Set(lineIDs))
    }
}
nonisolated struct StoredLine: Codable, Sendable {
    let id: LineID
    let operatorID: OperatorID
    let name: LocalizedRailName
    let edges: [[StationID]]
    init(_ l: RailwayLine) {
        id = l.id; operatorID = l.operatorID; name = l.name
        edges = l.topology.adjacencies.map { $0.stationIDs.sorted { RailwayArtifact.less($0.rawValue, $1.rawValue) } }
            .sorted { a, b in
                a.map(\.rawValue).lexicographicallyPrecedes(b.map(\.rawValue), by: RailwayArtifact.less)
            }
    }
    func domain() throws -> RailwayLine {
        let pairs = try edges.map { ids -> StationAdjacency in
            guard ids.count == 2, let edge = StationAdjacency(ids[0], ids[1]) else { throw RailwayRepositoryError.malformed }
            return edge
        }
        guard Set(pairs).count == pairs.count, let topology = RailwayLineTopology(adjacencies: Set(pairs)) else { throw RailwayRepositoryError.malformed }
        return RailwayLine(id: id, operatorID: operatorID, name: name, topology: topology)
    }
}
nonisolated struct RailwayArtifactSnapshot: Sendable {
    let stations: [Station]
    let lines: [RailwayLine]
    let operators: [Operator]
    let aliases: [ExactStationIndex.Alias]
    // All held canonical identities, including retired ones; no provider references.
    let entities: [CanonicalEntity]
}
nonisolated struct RailwayArtifactContent: Codable, Sendable {
    let stations: [StoredStation]
    let lines: [StoredLine]
    let operators: [Operator]
    let aliases: [ExactStationIndex.Alias]
    let entities: [CanonicalEntity]

    init(stations: [StoredStation], lines: [StoredLine], operators: [Operator], aliases: [ExactStationIndex.Alias], entities: [CanonicalEntity]) {
        self.stations = stations; self.lines = lines; self.operators = operators
        self.aliases = aliases; self.entities = entities
    }
    init(_ s: RailwayArtifactSnapshot) {
        stations = s.stations.sorted { RailwayArtifact.less($0.id.rawValue, $1.id.rawValue) }.map(StoredStation.init)
        lines = s.lines.sorted { RailwayArtifact.less($0.id.rawValue, $1.id.rawValue) }.map(StoredLine.init)
        operators = s.operators.sorted { RailwayArtifact.less($0.id.rawValue, $1.id.rawValue) }
        aliases = s.aliases.sorted { a, b in a.value == b.value ? RailwayArtifact.less(a.stationID.rawValue, b.stationID.rawValue) : a.value < b.value }
        entities = s.entities.sorted { $0.id < $1.id }
    }
    func snapshot() throws -> RailwayArtifactSnapshot {
        .init(stations: try stations.map { try $0.domain() }, lines: try lines.map { try $0.domain() }, operators: operators, aliases: aliases, entities: entities)
    }
}
nonisolated enum RailwayArtifact {
    static let schemaVersion = 1
    static let maxBytes = 256 * 1024 * 1024
    static let maxRecordBytes = 8 * 1024 * 1024
    static let maxRecords = 100_000
    static let maxHistory = 1_024
    static func less(_ a: String, _ b: String) -> Bool { a.utf8.lexicographicallyPrecedes(b.utf8) }
    static func encode<T: Encodable>(_ value: T) throws -> Data {
        let e = JSONEncoder(); e.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try e.encode(value)
    }
    static func digest(_ bytes: Data) -> String { SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined() }
    static func decode<T: Codable>(_ type: T.Type, _ bytes: Data) throws -> T {
        guard bytes.count <= maxRecordBytes else { throw RailwayRepositoryError.resourceLimit }
        do {
            let v = try JSONDecoder().decode(type, from: bytes)
            // Reject unknown/duplicate keys, noncanonical order/encoding, and lossy Set collapse.
            guard try encode(v) == bytes else { throw RailwayRepositoryError.malformed }
            return v
        } catch let e as RailwayRepositoryError { throw e }
        catch { throw RailwayRepositoryError.malformed }
    }
    static func validHash(_ text: String) -> Bool { text.utf8.count == 64 && text.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) } }
    static func validate(_ content: RailwayArtifactContent, schemaVersion: Int = 1) throws -> ExactStationIndex {
        let s = try content.snapshot()
        guard !s.stations.isEmpty, !s.lines.isEmpty, !s.operators.isEmpty,
              s.stations.count + s.lines.count + s.operators.count + s.entities.count + s.aliases.count <= maxRecords,
              Set(s.aliases).count == s.aliases.count else { throw RailwayRepositoryError.malformed }
        do {
            // Reuse accepted retirement, successor-kind and cycle validation, without references.
            _ = try MappingRegistry(revision: 0, entities: s.entities, references: [], formatVersion: schemaVersion == 2 ? 3 : 2)
            let active = Set(s.entities.filter { $0.status == .active }.map { $0.id.rawValue })
            let domainIDs = s.stations.map { $0.id.rawValue } + s.lines.map { $0.id.rawValue } + s.operators.map { $0.id.rawValue }
            guard Set(domainIDs) == active,
                  s.stations.allSatisfy({ MintedIdentifier($0.id.rawValue)?.kind == .station }),
                  s.lines.allSatisfy({ MintedIdentifier($0.id.rawValue)?.kind == .line }),
                  s.operators.allSatisfy({ MintedIdentifier($0.id.rawValue)?.kind == .railwayOperator }) else { throw RailwayRepositoryError.malformed }
            return try ExactStationIndex(stations: s.stations, lines: s.lines, operators: s.operators, aliases: s.aliases)
        } catch { throw RailwayRepositoryError.malformed }
    }
    static func validate(_ metadata: RailwayArtifactMetadata) throws {
        guard [1, 2].contains(metadata.schemaVersion) else { throw RailwayRepositoryError.unsupportedSchema }
        guard !metadata.revisions.isEmpty, metadata.revisions.count <= maxHistory else { throw RailwayRepositoryError.historyMismatch }
        if metadata.schemaVersion == 2 {
            guard metadata.current.inputs.contains(where: { $0.role == "identity-transitions" }) else { throw RailwayRepositoryError.historyMismatch }
        }
        if metadata.schemaVersion == 1 {
            guard !metadata.revisions.contains(where: { $0.inputs.contains(where: { $0.role == "identity-transitions" }) }) else { throw RailwayRepositoryError.unsupportedSchema }
        }
        var versions = Set<ExactValue>(); var previous = -1
        var previousDigest: String?
        var previousRegistryHash: String?
        for r in metadata.revisions {
            guard r.previousSHA256 == previousDigest,
                  versions.insert(r.dataVersion).inserted, r.registryRevision >= previous,
                  r.registryRevision >= 0, validHash(r.contentSHA256),
                  r.inputs.count >= 3, r.inputs.count <= 32,
                  Set(r.inputs.map(\.role)).count == r.inputs.count,
                  r.inputs.map(\.role) == r.inputs.map(\.role).sorted(),
                  Set(r.inputs.map(\.role)).isSuperset(of: ["registry", "network", "names"]),
                  r.inputs.allSatisfy({ MappingText.isToken($0.role) && validHash($0.sha256) }) else { throw RailwayRepositoryError.historyMismatch }
            let registryHash = r.inputs.first { $0.role == "registry" }!.sha256
            if r.registryRevision == previous, registryHash != previousRegistryHash {
                throw RailwayRepositoryError.historyMismatch
            }
            previousRegistryHash = registryHash
            previous = r.registryRevision
            previousDigest = try digest(encode(r))
        }
    }
}
