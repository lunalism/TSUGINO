import Foundation
import Testing
@testable import TSUGINO

/// Invented labels and IDs only; no source acquisition or real translations.
struct ExactStationIndexTests {
    @Test func scalarEqualityHashAndEncodedShape() throws {
        for field in 0..<3 {
            var a = ["Synthetic A","Synthetic B","Synthetic C"], b = a
            a[field] = "Caf\u{e9}";b[field] = "Cafe\u{301}"
            let x = try #require(LocalizedRailName(japanese:a[0],english:a[1],korean:a[2]))
            let y = try #require(LocalizedRailName(japanese:b[0],english:b[1],korean:b[2]))
            #expect(x != y)
            #expect(Set([x,y,x]).count == 2)
            let data = try JSONEncoder().encode(x)
            #expect(try JSONDecoder().decode(LocalizedRailName.self,from:data) == x)
            let shape = try #require(JSONSerialization.jsonObject(with:data) as? [String:String])
            #expect(Set(shape.keys) == ["japanese","english","korean"])
            #expect(shape[["japanese","english","korean"][field]]?.unicodeScalars.elementsEqual(a[field].unicodeScalars) == true)
        }
    }
    private func fixture() throws -> (stations:[Station],lines:[RailwayLine],operators:[Operator]) {
        let name = try #require(LocalizedRailName(japanese:"Synthetic Shared",english:"Caf\u{e9}",korean:" Synthetic Padded "))
        let other = try #require(LocalizedRailName(japanese:"Synthetic Shared",english:"Cafe\u{301}",korean:"Synthetic Other"))
        let a = try #require(StationID("synthetic-a")), b = try #require(StationID("synthetic-b"))
        let c = try #require(StationID("synthetic-c")), d = try #require(StationID("synthetic-d"))
        let l1 = try #require(LineID("synthetic-line-a")), l2 = try #require(LineID("synthetic-line-b"))
        let o1 = try #require(OperatorID("synthetic-op-a")), o2 = try #require(OperatorID("synthetic-op-b"))
        let point = try #require(GeoCoordinate(latitude:1,longitude:2))
        let edge1 = try #require(StationAdjacency(a,c)), edge2 = try #require(StationAdjacency(b,d))
        let top1 = try #require(RailwayLineTopology(adjacencies:[edge1])), top2 = try #require(RailwayLineTopology(adjacencies:[edge2]))
        return ([.init(id:a,name:name,coordinate:point,lineIDs:[l1]),.init(id:b,name:other,coordinate:point,lineIDs:[l2]),
                 .init(id:c,name:name,coordinate:point,lineIDs:[l1]),.init(id:d,name:other,coordinate:point,lineIDs:[l2])],
                [.init(id:l1,operatorID:o1,name:name,topology:top1),.init(id:l2,operatorID:o2,name:other,topology:top2)],
                [.init(id:o1,name:name),.init(id:o2,name:other)])
    }
    @Test func fullExactLookupPreservesDistinctIdentitiesAndContext() throws {
        let f = try fixture()
        let search: any StationSearching = try ExactStationIndex(stations:f.stations.reversed(),lines:f.lines.reversed(),operators:f.operators.reversed(),aliases:[])
        let matches = search.stations(matching:"Synthetic Shared")
        #expect(matches.map(\.station.id.rawValue) == ["synthetic-a","synthetic-b","synthetic-c","synthetic-d"])
        #expect(matches[0].operators[0].id != matches[1].operators[0].id)
        #expect(matches[0].lines[0].id != matches[1].lines[0].id)
        #expect(search.stations(matching:"Caf\u{e9}").map(\.station.id.rawValue) == ["synthetic-a","synthetic-c"])
        #expect(search.stations(matching:"Cafe\u{301}").map(\.station.id.rawValue) == ["synthetic-b","synthetic-d"])
        #expect(search.stations(matching:" Synthetic Padded ").count == 2)
        for query in ["Synthetic Padded","synthetic shared","Synthetic","", " \t\n"] { #expect(search.stations(matching:query).isEmpty) }
    }
    @Test func explicitAliasDeduplicationAndScalarKeyOrder() throws {
        let f = try fixture(), a = f.stations[0].id
        let aliases = ["Synthetic Shared","Cafe\u{301}","Cafe\u{301}"].map { ExactStationIndex.Alias(stationID:a,value:ExactValue($0)!) }
        let index = try ExactStationIndex(stations:f.stations,lines:f.lines,operators:f.operators,aliases:aliases)
        #expect(index.stations(matching:"Cafe\u{301}").map(\.station.id.rawValue) == ["synthetic-a","synthetic-b","synthetic-d"])
        #expect(index.entries.map(\.key) == index.entries.map(\.key).sorted())
        let other = try ExactStationIndex(stations:f.stations.reversed(),lines:f.lines.reversed(),operators:f.operators.reversed(),aliases:aliases.reversed())
        #expect(index.entries == other.entries)
    }
    @Test func incompleteContextAndUnknownAliasFail() throws {
        let f = try fixture()
        #expect(throws:ExactStationIndex.Invalid.self) { try ExactStationIndex(stations:f.stations,lines:f.lines,operators:[],aliases:[]) }
        #expect(throws:ExactStationIndex.Invalid.self) { try ExactStationIndex(stations:Array(f.stations.dropLast()),lines:f.lines,operators:f.operators,aliases:[]) }
        #expect(throws:ExactStationIndex.Invalid.self) { try ExactStationIndex(stations:f.stations,lines:f.lines,operators:f.operators,aliases:[.init(stationID:StationID("synthetic-absent")!,value:ExactValue("Synthetic alias")!)]) }
    }
}
