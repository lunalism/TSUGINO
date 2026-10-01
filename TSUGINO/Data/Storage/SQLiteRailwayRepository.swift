import Foundation

/// One serialized read-only connection, holding a consistent read transaction.
/// Prepared artifacts must not be edited in place. No runtime importer or minter.
actor SQLiteRailwayRepository: RailwayDataRepository {
    private let connection: RailwaySQLiteConnection
    private let storedMetadata: RailwayArtifactMetadata
    private let lines: [RailwayLine]
    private let operators: [Operator]
    private var isClosed = false
    private var stationDecodes = 0
    private var explicitFullLoads = 0
    nonisolated struct Diagnostics: Equatable, Sendable {
        let artifactValidationPasses: Int
        let queryStationDecodes: Int
        let explicitFullLoads: Int
    }
    private init(connection: RailwaySQLiteConnection, metadata: RailwayArtifactMetadata, content: RailwayArtifactContent) throws {
        self.connection = connection; storedMetadata = metadata
        lines = try content.lines.map { try $0.domain() }; operators = content.operators
    }
    @concurrent static func open(_ url: URL, expected: RailwayArtifactRevision? = nil) async throws -> SQLiteRailwayRepository {
        let connection = try RailwaySQLiteConnection(path: url.path)
        do {
            let (metadata, content) = try connection.readArtifact()
            if let expected, metadata.current != expected { throw RailwayRepositoryError.incompatibleData }
            return try SQLiteRailwayRepository(connection: connection, metadata: metadata, content: content)
        } catch { try? connection.close(); throw error }
    }
    private func checkOpen() throws { if isClosed { throw RailwayRepositoryError.closed } }
    func metadata() throws -> RailwayArtifactMetadata { try checkOpen(); return storedMetadata }
    func identities() throws -> [CanonicalEntity] {
        try checkOpen()
        return try connection.rows("SELECT payload FROM entities ORDER BY id").map { try RailwayArtifact.decode(CanonicalEntity.self, $0[0]) }
    }
    func diagnostics() -> Diagnostics { .init(artifactValidationPasses: connection.validationPasses, queryStationDecodes: stationDecodes, explicitFullLoads: explicitFullLoads) }
    func station(id: StationID) throws -> Station? {
        try checkOpen()
        let rows = try connection.rows("SELECT payload FROM stations WHERE id=?", bindings: [Data(id.rawValue.utf8)])
        guard let row = rows.first else { return nil }
        stationDecodes += 1
        return try RailwayArtifact.decode(StoredStation.self, row[0]).domain()
    }
    func line(id: LineID) throws -> RailwayLine? { try checkOpen(); return lines.first { $0.id == id } }
    func railwayOperator(id: OperatorID) throws -> Operator? { try checkOpen(); return operators.first { $0.id == id } }
    func allStations() throws -> [Station] {
        try checkOpen(); explicitFullLoads += 1
        return try connection.rows("SELECT payload FROM stations ORDER BY id").map { row in
            stationDecodes += 1
            return try RailwayArtifact.decode(StoredStation.self, row[0]).domain()
        }
    }
    func allLines() throws -> [RailwayLine] { try checkOpen(); return lines }
    func allOperators() throws -> [Operator] { try checkOpen(); return operators }
    func stations(matching query: String) throws -> [StationSearchResult] {
        try checkOpen()
        guard ExactValue(query) != nil else { return [] }
        return try connection.rows("SELECT id FROM search WHERE key=? ORDER BY id", bindings: [Data(query.utf8)]).map { row in
            guard let text = String(data: row[0], encoding: .utf8), let id = StationID(text), let station = try station(id: id) else { throw RailwayRepositoryError.malformed }
            let context = lines.filter { station.lineIDs.contains($0.id) }
            let operatorIDs = Set(context.map(\.operatorID))
            return StationSearchResult(station: station, lines: context, operators: operators.filter { operatorIDs.contains($0.id) })
        }
    }
    func close() throws {
        if !isClosed { try connection.close(); isClosed = true }
    }
}
