// Local prepared railway data only. No storage format, provider, minting or UI.
// Async boundary keeps opening, IO and decoding off the main actor.
nonisolated protocol RailwayDataRepository: Sendable {
    func station(id: StationID) async throws -> Station?
    func line(id: LineID) async throws -> RailwayLine?
    func railwayOperator(id: OperatorID) async throws -> Operator?
    func allStations() async throws -> [Station]
    func allLines() async throws -> [RailwayLine]
    func allOperators() async throws -> [Operator]
    func stations(matching query: String) async throws -> [StationSearchResult]
    func close() async throws
}

nonisolated enum RailwayRepositoryError: Error, Equatable, Sendable {
    case unavailable, closed, malformed, unsupportedSchema, incompatibleData
    case resourceLimit, identityMigrationRequired, historyMismatch
}
