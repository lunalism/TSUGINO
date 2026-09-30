// DEC-071: every key is scalar-exact, including deduplication and sorting.
nonisolated struct ExactStationIndex: StationSearching {
    struct Alias: Hashable, Codable, Sendable {
        let stationID: StationID
        let value: ExactValue
    }
    struct Entry: Codable, Equatable, Sendable {
        let key: ExactValue
        let stationIDs: [StationID]
    }
    enum Invalid: Error { case duplicateIdentity, missingContext, membershipMismatch, unknownAlias }
    let entries: [Entry]
    private let matches: [ExactValue: [StationSearchResult]]

    init(stations: [Station], lines: [RailwayLine], operators: [Operator], aliases: [Alias]) throws {
        guard Set(stations.map(\.id)).count == stations.count,
              Set(lines.map(\.id)).count == lines.count,
              Set(operators.map(\.id)).count == operators.count else { throw Invalid.duplicateIdentity }
        let byLine = Dictionary(uniqueKeysWithValues: lines.map { ($0.id, $0) })
        let byOperator = Dictionary(uniqueKeysWithValues: operators.map { ($0.id, $0) })
        var results: [StationID: StationSearchResult] = [:]
        var keys: [ExactValue: Set<StationID>] = [:]
        for station in stations {
            let context = station.lineIDs.compactMap { byLine[$0] }.sorted { $0.id.rawValue.utf8.lexicographicallyPrecedes($1.id.rawValue.utf8) }
            guard !context.isEmpty, context.count == station.lineIDs.count,
                  context.allSatisfy({ byOperator[$0.operatorID] != nil }) else { throw Invalid.missingContext }
            let operatorIDs = Set(context.map(\.operatorID))
            results[station.id] = .init(station: station, lines: context, operators: operatorIDs.compactMap { byOperator[$0] }.sorted { $0.id.rawValue.utf8.lexicographicallyPrecedes($1.id.rawValue.utf8) })
            for text in [station.name.japanese, station.name.english, station.name.korean] {
                guard let key = ExactValue(text) else { throw Invalid.missingContext }
                keys[key, default: []].insert(station.id)
            }
        }
        for line in lines {
            guard Set(line.topology.stationIDs) == Set(stations.filter { $0.lineIDs.contains(line.id) }.map(\.id)) else { throw Invalid.membershipMismatch }
        }
        for alias in aliases {
            guard results[alias.stationID] != nil else { throw Invalid.unknownAlias }
            keys[alias.value, default: []].insert(alias.stationID)
        }
        entries = keys.keys.sorted().map { key in
            Entry(key: key, stationIDs: keys[key]!.sorted { $0.rawValue.utf8.lexicographicallyPrecedes($1.rawValue.utf8) })
        }
        matches = Dictionary(uniqueKeysWithValues: entries.map { ($0.key, $0.stationIDs.map { results[$0]! }) })
    }
    func stations(matching query: String) -> [StationSearchResult] {
        guard let key = ExactValue(query) else { return [] }
        return matches[key] ?? []
    }
}
