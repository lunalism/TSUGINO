import Foundation

/// Exercises the provider-neutral API on the constructed values, not merely
/// the serialized index. No real name or provider-specific expectation lives here.
struct RailNameSearchAudit: Encodable {
    let canonicalQueries: Int
    let aliasQueries: Int
    let exactProbeQueries: Int
    let duplicateKeys: Int
    static func validate(_ outcome: RailNameOutcome) throws -> Self? {
        guard outcome.complete, let index = outcome.index else { return nil }
        let search: any StationSearching = index
        func check(_ text: String, target: StationID? = nil) throws {
            let expected = ExactValue(text).flatMap { key in index.entries.first { $0.key == key }?.stationIDs } ?? []
            let found = search.stations(matching:text)
            guard found.map({ $0.station.id }) == expected,
                  Set(found.map { $0.station.id }).count == found.count,
                  target.map({ expected.contains($0) }) ?? true,
                  found.allSatisfy({ Set($0.lines.map(\.id)) == $0.station.lineIDs && Set($0.operators.map(\.id)) == Set($0.lines.map(\.operatorID)) }) else { throw NameReviewError.malformed }
        }
        for station in outcome.stations {
            for text in [station.name.japanese,station.name.english,station.name.korean] { try check(text,target:station.id) }
        }
        for alias in outcome.aliases { try check(alias.value.text,target:alias.stationID) }
        var probes = 0
        for entry in index.entries {
            let text = entry.key.text
            for probe in [text," "+text,text+" ",text.lowercased(),text.uppercased(),text.precomposedStringWithCanonicalMapping,text.decomposedStringWithCanonicalMapping,String(text.unicodeScalars.dropLast())] {
                try check(probe); probes += 1
            }
        }
        return .init(canonicalQueries:outcome.stations.count*3,aliasQueries:outcome.aliases.count,
                     exactProbeQueries:probes,duplicateKeys:index.entries.filter { $0.stationIDs.count > 1 }.count)
    }
}
