// Provider-neutral, local-only exact station lookup (DEC-071). No locale,
// provider reference, persistence choice or UI is exposed by this boundary.
nonisolated struct StationSearchResult: Sendable {
    let station: Station
    let lines: [RailwayLine]
    let operators: [Operator]
}

nonisolated protocol StationSearching: Sendable {
    func stations(matching query: String) -> [StationSearchResult]
}
