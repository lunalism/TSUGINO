import Foundation
import SQLite3

// Internal connection, confined to the repository actor or offline builder.
nonisolated final class RailwaySQLiteConnection {
    private(set) var handle: OpaquePointer?
    private(set) var validationPasses = 0
    static let tables: [(String, String)] = [
        ("metadata", "CREATE TABLE metadata (id INTEGER PRIMARY KEY CHECK(id=1), payload BLOB NOT NULL)"),
        ("operators", "CREATE TABLE operators (id BLOB PRIMARY KEY, payload BLOB NOT NULL) WITHOUT ROWID"),
        ("lines", "CREATE TABLE lines (id BLOB PRIMARY KEY, payload BLOB NOT NULL) WITHOUT ROWID"),
        ("stations", "CREATE TABLE stations (id BLOB PRIMARY KEY, payload BLOB NOT NULL) WITHOUT ROWID"),
        ("aliases", "CREATE TABLE aliases (key BLOB, id BLOB, PRIMARY KEY(key,id)) WITHOUT ROWID"),
        ("entities", "CREATE TABLE entities (id BLOB PRIMARY KEY, payload BLOB NOT NULL) WITHOUT ROWID"),
        ("search", "CREATE TABLE search (key BLOB, id BLOB, PRIMARY KEY(key,id)) WITHOUT ROWID")
    ]
    static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    init(path: String, writing: Bool = false) throws {
        if !writing {
            let attributes: [FileAttributeKey: Any]
            do { attributes = try FileManager.default.attributesOfItem(atPath: path) }
            catch { throw RailwayRepositoryError.unavailable }
            guard attributes[.type] as? FileAttributeType == .typeRegular else { throw RailwayRepositoryError.malformed }
            guard let bytes = attributes[.size] as? NSNumber, bytes.intValue <= RailwayArtifact.maxBytes else { throw RailwayRepositoryError.resourceLimit }
            guard !["-wal", "-shm", "-journal"].contains(where: { FileManager.default.fileExists(atPath: path + $0) }) else { throw RailwayRepositoryError.malformed }
        }
        let flags = writing ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE : SQLITE_OPEN_READONLY
        guard sqlite3_open_v2(path, &handle, flags | SQLITE_OPEN_NOMUTEX, nil) == SQLITE_OK else {
            if let handle { sqlite3_close(handle) }; handle = nil; throw RailwayRepositoryError.unavailable
        }
        sqlite3_limit(handle, SQLITE_LIMIT_LENGTH, Int32(RailwayArtifact.maxRecordBytes))
        sqlite3_limit(handle, SQLITE_LIMIT_SQL_LENGTH, 64 * 1024)
        do {
            try execute("PRAGMA trusted_schema=OFF")
            if !writing { try execute("PRAGMA query_only=ON"); try execute("BEGIN") }
        } catch { try? close(); throw error }
    }
    deinit { if let handle { sqlite3_close_v2(handle) } }
    func close() throws {
        guard let h = handle else { return }
        guard sqlite3_close(h) == SQLITE_OK else { throw RailwayRepositoryError.unavailable }
        handle = nil
    }
    func execute(_ sql: String) throws {
        guard let handle else { throw RailwayRepositoryError.closed }
        guard sqlite3_exec(handle, sql, nil, nil, nil) == SQLITE_OK else { throw RailwayRepositoryError.malformed }
    }
    func withStatement<T>(_ sql: String, bindings: [Data] = [], _ body: (OpaquePointer) throws -> T) throws -> T {
        guard let handle else { throw RailwayRepositoryError.closed }
        var pointer: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &pointer, nil) == SQLITE_OK, let statement = pointer else { throw RailwayRepositoryError.malformed }
        defer { sqlite3_finalize(statement) }
        for (offset, bytes) in bindings.enumerated() {
            let code = bytes.withUnsafeBytes { sqlite3_bind_blob(statement, Int32(offset + 1), $0.baseAddress, Int32($0.count), Self.transient) }
            guard code == SQLITE_OK else { throw RailwayRepositoryError.malformed }
        }
        return try body(statement)
    }
    func rows(_ sql: String, bindings: [Data] = []) throws -> [[Data]] {
        try withStatement(sql, bindings: bindings) { statement in
            var rows: [[Data]] = []
            while true {
                let status = sqlite3_step(statement)
                if status == SQLITE_DONE { return rows }
                guard status == SQLITE_ROW else { throw RailwayRepositoryError.malformed }
                guard rows.count < RailwayArtifact.maxRecords else { throw RailwayRepositoryError.resourceLimit }
                var row: [Data] = []
                for col in 0..<sqlite3_column_count(statement) {
                    guard sqlite3_column_type(statement, col) == SQLITE_BLOB else { throw RailwayRepositoryError.malformed }
                    let n = Int(sqlite3_column_bytes(statement, col))
                    guard n <= RailwayArtifact.maxRecordBytes else { throw RailwayRepositoryError.resourceLimit }
                    row.append(n == 0 ? Data() : Data(bytes: sqlite3_column_blob(statement, col)!, count: n))
                }
                rows.append(row)
            }
        }
    }
    func scalarText(_ sql: String) throws -> String {
        try withStatement(sql) { s in
            guard sqlite3_step(s) == SQLITE_ROW, let text = sqlite3_column_text(s, 0) else { throw RailwayRepositoryError.malformed }
            let result = String(cString: text)
            guard sqlite3_step(s) == SQLITE_DONE else { throw RailwayRepositoryError.malformed }
            return result
        }
    }
    func insert(_ table: String, _ values: [Data]) throws {
        // Table identifiers are internal constants, never caller/source text.
        let sql = "INSERT INTO \(table) VALUES (" + Array(repeating: "?", count: values.count).joined(separator: ",") + ")"
        try withStatement(sql, bindings: values) { s in
            guard sqlite3_step(s) == SQLITE_DONE else { throw RailwayRepositoryError.malformed }
        }
    }
    func validateSchema() throws {
        guard try ["1", "2"].contains(scalarText("PRAGMA user_version")) else { throw RailwayRepositoryError.unsupportedSchema }
        guard try scalarText("PRAGMA application_id") == "1414743879" else { throw RailwayRepositoryError.malformed }
        guard try scalarText("PRAGMA integrity_check") == "ok" else { throw RailwayRepositoryError.malformed }
        var actual: [String: String] = [:]
        try withStatement("SELECT name,sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' ORDER BY name") { s in
            while true {
                let code = sqlite3_step(s); if code == SQLITE_DONE { break }
                guard code == SQLITE_ROW, let name = sqlite3_column_text(s, 0), let sql = sqlite3_column_text(s, 1) else { throw RailwayRepositoryError.malformed }
                guard actual.count < Self.tables.count else { throw RailwayRepositoryError.malformed }
                actual[String(cString: name)] = String(cString: sql)
            }
        }
        guard actual == Dictionary(uniqueKeysWithValues: Self.tables) else { throw RailwayRepositoryError.malformed }
    }
    func readArtifact() throws -> (RailwayArtifactMetadata, RailwayArtifactContent) {
        validationPasses += 1
        try validateSchema()
        let meta = try rows("SELECT payload FROM metadata WHERE id=1")
        guard meta.count == 1 else { throw RailwayRepositoryError.malformed }
        let metadata = try RailwayArtifact.decode(RailwayArtifactMetadata.self, meta[0][0])
        try RailwayArtifact.validate(metadata)
        guard try scalarText("PRAGMA user_version") == String(metadata.schemaVersion) else { throw RailwayRepositoryError.malformed }
        func records<T: Codable>(_ table: String, _ type: T.Type, id: (T) -> String) throws -> [T] {
            try rows("SELECT id,payload FROM \(table) ORDER BY id").map { row in
                let record = try RailwayArtifact.decode(type, row[1])
                guard row[0] == Data(id(record).utf8) else { throw RailwayRepositoryError.malformed }
                return record
            }
        }
        let stations = try records("stations", StoredStation.self) { $0.id.rawValue }
        let lines = try records("lines", StoredLine.self) { $0.id.rawValue }
        let operators = try records("operators", Operator.self) { $0.id.rawValue }
        let entities = try records("entities", CanonicalEntity.self) { $0.id.rawValue }
        let aliases = try rows("SELECT key,id FROM aliases ORDER BY key,id").map { row -> ExactStationIndex.Alias in
            guard let text = String(data: row[0], encoding: .utf8), let key = ExactValue(text),
                  let textID = String(data: row[1], encoding: .utf8), let id = StationID(textID) else { throw RailwayRepositoryError.malformed }
            return .init(stationID: id, value: key)
        }
        let raw = RailwayArtifactContent(stations: stations, lines: lines, operators: operators, aliases: aliases, entities: entities)
        let content = RailwayArtifactContent(try raw.snapshot())
        guard try RailwayArtifact.encode(raw) == RailwayArtifact.encode(content),
              try RailwayArtifact.digest(RailwayArtifact.encode(content)) == metadata.current.contentSHA256 else { throw RailwayRepositoryError.malformed }
        let index = try RailwayArtifact.validate(content, schemaVersion: metadata.schemaVersion)
        let expected = index.entries.flatMap { entry in entry.stationIDs.map { [Data(entry.key.text.utf8), Data($0.rawValue.utf8)] } }
        guard try rows("SELECT key,id FROM search ORDER BY key,id") == expected else { throw RailwayRepositoryError.malformed }
        return (metadata, content)
    }
}
