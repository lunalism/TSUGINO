import Foundation
import SQLite3
import Darwin

// Offline only. The caller supplies identified, already reviewed/validated inputs;
// this builder validates Domain/identity consistency, never editorial approval.
nonisolated enum RailwayArtifactBuilder {
    struct Inputs: Sendable {
        let registryBytes: Data
        let namesBytes: Data
        let networkBytes: Data
    }
    @concurrent static func build(snapshot: RailwayArtifactSnapshot, dataVersion: ExactValue, inputs: Inputs, previous: URL? = nil, output: URL, authorization: IdentityTransition.Authorization? = nil, retainedHistory: Data? = nil) async throws -> RailwayArtifactMetadata {
        guard !FileManager.default.fileExists(atPath: output.path) else { throw RailwayRepositoryError.unavailable }
        guard [inputs.registryBytes, inputs.namesBytes, inputs.networkBytes].allSatisfy({ !$0.isEmpty && $0.count <= RailwayArtifact.maxBytes }) else { throw RailwayRepositoryError.resourceLimit }
        guard authorization == nil || retainedHistory == nil else { throw RailwayRepositoryError.historyMismatch }
        if let retainedHistory {
            let h = try IdentityTransition.decode(IdentityTransition.History.self, retainedHistory)
            guard let last = h.boundaries.last else { throw RailwayRepositoryError.historyMismatch }
            _ = try IdentityTransition.validate(.init(previousRegistry: last.previousRegistry, targetRegistry: last.targetRegistry,
                recordsBytes: RailwayArtifact.encode(last.records), previousHistory: retainedHistory))
        }
        let transitionHistory = authorization?.historyBytes ?? retainedHistory
        let registry = try transitionHistory == nil ? MappingRegistry.decoded(from: inputs.registryBytes)
            : MappingRegistry.decodedForIdentityTransition(from: inputs.registryBytes)
        if let authorization {
            guard authorization.targetRegistry == inputs.registryBytes, previous != nil else { throw RailwayRepositoryError.historyMismatch }
            let h = try IdentityTransition.decode(IdentityTransition.History.self, authorization.historyBytes)
            for r in h.boundaries.last!.records {
                guard r.payload.dependencies.contains(.init(role: "names", sha256: RailwayArtifact.digest(inputs.namesBytes))),
                      r.payload.dependencies.contains(.init(role: "network", sha256: RailwayArtifact.digest(inputs.networkBytes))) else { throw RailwayRepositoryError.historyMismatch }
            }
        }
        guard transitionHistory == nil || registry.formatVersion == 3 else { throw RailwayRepositoryError.unsupportedSchema }
        let schema = registry.formatVersion == 3 ? 2 : 1
        let content = RailwayArtifactContent(snapshot)
        guard registry.entities == content.entities else { throw RailwayRepositoryError.malformed }
        let index = try RailwayArtifact.validate(content, schemaVersion: schema)
        let contentBytes = try RailwayArtifact.encode(content)
        guard contentBytes.count <= RailwayArtifact.maxBytes else { throw RailwayRepositoryError.resourceLimit }
        var buildInputs: [RailwayBuildInput] = []
        if let transitionHistory { buildInputs.append(.init(role: "identity-transitions", sha256: RailwayArtifact.digest(transitionHistory))) }
        var revision = RailwayArtifactRevision(dataVersion: dataVersion, registryRevision: registry.revision, inputs: buildInputs + [
            .init(role: "names", sha256: RailwayArtifact.digest(inputs.namesBytes)),
            .init(role: "network", sha256: RailwayArtifact.digest(inputs.networkBytes)),
            .init(role: "registry", sha256: RailwayArtifact.digest(inputs.registryBytes))
        ], contentSHA256: RailwayArtifact.digest(contentBytes), previousSHA256: nil)
        var history: [RailwayArtifactRevision] = []
        if let previous {
            let old = try RailwaySQLiteConnection(path: previous.path)
            defer { try? old.close() }
            let (metadata, prior) = try old.readArtifact()
            if let authorization {
                let expected = authorization.replay ? authorization.targetRegistry : authorization.previousRegistry
                let previousRegistry = try IdentityTransition.registry(expected)
                guard metadata.current.registryRevision == previousRegistry.revision,
                      metadata.current.inputs.first(where: { $0.role == "registry" })?.sha256 == RailwayArtifact.digest(expected),
                      prior.entities == previousRegistry.entities else { throw RailwayRepositoryError.historyMismatch }
                let priorHistory = metadata.current.inputs.first(where: { $0.role == "identity-transitions" })?.sha256
                guard priorHistory == authorization.previousHistorySHA256 else { throw RailwayRepositoryError.historyMismatch }
                if authorization.replay {
                    guard revision.dataVersion == metadata.current.dataVersion,
                          revision.inputs == metadata.current.inputs,
                          revision.contentSHA256 == metadata.current.contentSHA256 else { throw RailwayRepositoryError.historyMismatch }
                }
            } else {
                guard prior.entities == content.entities else { throw RailwayRepositoryError.identityMigrationRequired }
                guard metadata.current.inputs.first(where: { $0.role == "identity-transitions" })?.sha256 == transitionHistory.map(RailwayArtifact.digest) else { throw RailwayRepositoryError.historyMismatch }
                if let retainedHistory {
                    let h = try IdentityTransition.decode(IdentityTransition.History.self, retainedHistory)
                    try IdentityTransition.bridge(IdentityTransition.registry(h.boundaries.last!.targetRegistry), registry)
                }
            }
            history = metadata.revisions
            guard revision.registryRevision >= metadata.current.registryRevision else { throw RailwayRepositoryError.historyMismatch }
            if revision.dataVersion == metadata.current.dataVersion && revision.registryRevision == metadata.current.registryRevision && revision.inputs == metadata.current.inputs && revision.contentSHA256 == metadata.current.contentSHA256 {
                revision = metadata.current // repeat: retain the same chain, no duplicate
            }
            else {
                guard !history.contains(where: { $0.dataVersion == dataVersion }) else { throw RailwayRepositoryError.historyMismatch }
                if revision.registryRevision == metadata.current.registryRevision {
                    guard revision.inputs.first(where: { $0.role == "registry" }) == metadata.current.inputs.first(where: { $0.role == "registry" }) else { throw RailwayRepositoryError.historyMismatch }
                }
                revision = .init(dataVersion: revision.dataVersion, registryRevision: revision.registryRevision, inputs: revision.inputs, contentSHA256: revision.contentSHA256, previousSHA256: try RailwayArtifact.digest(RailwayArtifact.encode(metadata.current)))
                history.append(revision)
            }
        } else {
            guard transitionHistory == nil else { throw RailwayRepositoryError.historyMismatch }
            history = [revision]
        }
        let metadata = RailwayArtifactMetadata(schemaVersion: schema, revisions: history)
        try RailwayArtifact.validate(metadata)
        // Exclusive scratch beside destination. Never overwrite prior artifacts.
        let temporary = output.deletingLastPathComponent().appendingPathComponent(".railway-build-" + UUID().uuidString)
        guard FileManager.default.createFile(atPath: temporary.path, contents: Data(), attributes: [.posixPermissions: 0o600]) else { throw RailwayRepositoryError.unavailable }
        defer { try? FileManager.default.removeItem(at: temporary) }
        let db = try RailwaySQLiteConnection(path: temporary.path, writing: true)
        do {
            try db.execute("PRAGMA page_size=4096; PRAGMA journal_mode=DELETE; PRAGMA synchronous=FULL; PRAGMA auto_vacuum=NONE; PRAGMA application_id=1414743879; PRAGMA user_version=\(schema); BEGIN")
            for (_, sql) in RailwaySQLiteConnection.tables { try db.execute(sql) }
            try db.withStatement("INSERT INTO metadata VALUES (1,?)", bindings: [try RailwayArtifact.encode(metadata)]) { s in
                guard sqlite3_step(s) == SQLITE_DONE else { throw RailwayRepositoryError.malformed }
            }
            for op in content.operators { try db.insert("operators", [Data(op.id.rawValue.utf8), RailwayArtifact.encode(op)]) }
            for line in content.lines { try db.insert("lines", [Data(line.id.rawValue.utf8), RailwayArtifact.encode(line)]) }
            for station in content.stations { try db.insert("stations", [Data(station.id.rawValue.utf8), RailwayArtifact.encode(station)]) }
            for alias in content.aliases { try db.insert("aliases", [Data(alias.value.text.utf8), Data(alias.stationID.rawValue.utf8)]) }
            for entity in content.entities { try db.insert("entities", [Data(entity.id.rawValue.utf8), RailwayArtifact.encode(entity)]) }
            for entry in index.entries { for id in entry.stationIDs { try db.insert("search", [Data(entry.key.text.utf8), Data(id.rawValue.utf8)]) } }
            try db.execute("COMMIT"); try db.close()
            let check = try RailwaySQLiteConnection(path: temporary.path)
            _ = try check.readArtifact(); try check.close()
            // POSIX link is exclusive even if another writer creates output now.
            guard link(temporary.path, output.path) == 0 else { throw RailwayRepositoryError.unavailable }
        } catch { try? db.close(); throw error }
        return metadata
    }
}
