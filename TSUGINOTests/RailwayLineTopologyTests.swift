import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the undirected connected station-adjacency graph
/// (DEC-057 D3–D4, D7–D8, ARCHITECTURE.md §5.2.1).
///
/// Every shape here is synthetic — a chain, a cycle, a branch, a loop with a
/// tail — and none names a real line. Nothing asserts encoded element order,
/// a degree limit, a station count limit, or any regional rule.
struct RailwayLineTopologyTests {

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func edge(_ a: String, _ b: String) throws -> StationAdjacency {
        try #require(StationAdjacency(try Self.station(a), try Self.station(b)))
    }

    private static func edges(_ pairs: (String, String)...) throws -> Set<StationAdjacency> {
        Set(try pairs.map { try Self.edge($0.0, $0.1) })
    }

    private static func topology(_ pairs: (String, String)...) throws -> RailwayLineTopology {
        try #require(RailwayLineTopology(adjacencies: Set(try pairs.map { try Self.edge($0.0, $0.1) })))
    }

    private static func stations(_ raws: String...) throws -> Set<StationID> {
        Set(try raws.map { try Self.station($0) })
    }

    // MARK: - Valid shapes

    @Test func singleAdjacencyIsAValidTopology() throws {
        let subject = try Self.topology(("a", "b"))

        #expect(subject.adjacencies.count == 1)
        #expect(subject.stationIDs == (try Self.stations("a", "b")))
    }

    @Test func chainIsValid() throws {
        let subject = try Self.topology(("a", "b"), ("b", "c"), ("c", "d"))

        #expect(subject.adjacencies.count == 3)
        #expect(subject.stationIDs == (try Self.stations("a", "b", "c", "d")))
    }

    /// Closure is expressed by the final adjacency alone: no station repeats,
    /// no first/last convention, no self-edge (DEC-057 D7).
    @Test func cycleIsValid() throws {
        let subject = try Self.topology(("a", "b"), ("b", "c"), ("c", "a"))

        #expect(subject.adjacencies.count == 3)
        #expect(subject.stationIDs == (try Self.stations("a", "b", "c")))
    }

    /// A junction is simply a station in three or more adjacencies.
    @Test func branchWithDegreeThreeJunctionIsValid() throws {
        let subject = try Self.topology(("a", "b"), ("b", "c"), ("b", "d"))

        #expect(subject.adjacencies.count == 3)
        #expect(subject.stationIDs == (try Self.stations("a", "b", "c", "d")))
        let junction = try Self.station("b")
        #expect(subject.adjacencies.filter { $0.stationIDs.contains(junction) }.count == 3)
    }

    /// The junction participates in the loop and the tail; nothing is stored
    /// twice beyond its appearance in several adjacencies.
    @Test func loopPlusTailIsValid() throws {
        let subject = try Self.topology(("j", "a"), ("a", "b"), ("b", "j"), ("j", "t1"), ("t1", "t2"))

        #expect(subject.adjacencies.count == 5)
        #expect(subject.stationIDs == (try Self.stations("j", "a", "b", "t1", "t2")))
        let junction = try Self.station("j")
        #expect(subject.adjacencies.filter { $0.stationIDs.contains(junction) }.count == 3)
    }

    /// Two distinct routes between `a` and `d` are an ordinary graph.
    @Test func multiplePathsBetweenStationsAreValid() throws {
        let subject = try Self.topology(("a", "b"), ("b", "d"), ("a", "c"), ("c", "d"))

        #expect(subject.adjacencies.count == 4)
        #expect(subject.stationIDs == (try Self.stations("a", "b", "c", "d")))
    }

    // MARK: - Rejection (never trapped)

    @Test func emptyTopologyIsRejected() {
        #expect(RailwayLineTopology(adjacencies: []) == nil)
    }

    @Test(arguments: [
        [("a", "b"), ("c", "d")],
        [("a", "b"), ("b", "c"), ("x", "y")],
        [("a", "b"), ("b", "a"), ("p", "q"), ("q", "r"), ("r", "p")],
    ])
    func disconnectedTopologyIsRejected(pairs: [(String, String)]) throws {
        let adjacencies = Set(try pairs.map { try Self.edge($0.0, $0.1) })

        #expect(RailwayLineTopology(adjacencies: adjacencies) == nil)
    }

    // MARK: - Set semantics

    @Test func duplicateAndReversedAdjacenciesCollapse() throws {
        let adjacencies = try Self.edges(("a", "b"), ("b", "a"), ("a", "b"), ("b", "c"))
        let subject = try #require(RailwayLineTopology(adjacencies: adjacencies))

        #expect(subject.adjacencies.count == 2, "multiplicity and orientation carry no meaning")
        #expect(subject.stationIDs == (try Self.stations("a", "b", "c")))
    }

    @Test func derivedStationIDsIsTheUnionOfAllEndpoints() throws {
        let subject = try Self.topology(("a", "b"), ("b", "c"))

        #expect(subject.stationIDs == (try Self.stations("a", "b", "c")))
        #expect(subject.stationIDs.count == 3)
    }

    // MARK: - Equality and hashing (complete value)

    @Test func equalityAndHashingUseTheWholeAdjacencySet() throws {
        let a = try Self.topology(("a", "b"), ("b", "c"))
        let sameInOtherOrder = try Self.topology(("c", "b"), ("b", "a"))
        let longer = try Self.topology(("a", "b"), ("b", "c"), ("c", "d"))

        #expect(a == sameInOtherOrder)
        #expect(a.hashValue == sameInOtherOrder.hashValue)
        #expect(a != longer)
        #expect(Set([a, sameInOtherOrder, longer]).count == 2)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesTheAdjacencySet() throws {
        let original = try Self.topology(("j", "a"), ("a", "b"), ("b", "j"), ("j", "t"))
        let decoded = try JSONDecoder().decode(
            RailwayLineTopology.self,
            from: try JSONEncoder().encode(original)
        )

        // Compared as sets: encoded collection order is not a contract.
        #expect(decoded.adjacencies == original.adjacencies)
        #expect(decoded.stationIDs == original.stationIDs)
        #expect(decoded == original)
    }

    /// Pins the wire shape (ARCHITECTURE.md §41) and proves the derived
    /// `stationIDs` is not encoded. Elements are compared as sets.
    @Test func encodedFormUsesExactlyTheAdjacenciesKeyAndOmitsStationIDs() throws {
        let encoded = try JSONEncoder().encode(try Self.topology(("a", "b"), ("b", "c")))
        let object = try #require(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        let adjacencies = try #require(object["adjacencies"] as? [[String: Any]])

        #expect(Set(object.keys) == ["adjacencies"])
        #expect(object["stationIDs"] == nil)
        #expect(adjacencies.count == 2)
        let endpointSets = Set(try adjacencies.map { Set(try #require($0["stationIDs"] as? [String])) })
        #expect(endpointSets == [["a", "b"], ["b", "c"]])
    }

    /// A repeated encoded adjacency is not an error: it collapses and the
    /// resulting graph is still valid.
    @Test func repeatedEncodedAdjacenciesCollapseToAValidTopology() throws {
        let payload = #"{"adjacencies":[{"stationIDs":["a","b"]},{"stationIDs":["b","a"]},{"stationIDs":["b","c"]}]}"#
        let decoded = try JSONDecoder().decode(RailwayLineTopology.self, from: Data(payload.utf8))

        #expect(decoded.adjacencies.count == 2)
        #expect(decoded == (try Self.topology(("a", "b"), ("b", "c"))))
    }

    @Test func missingKeyFailsAsKeyNotFound() {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailwayLineTopology.self, from: Data("{}".utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"adjacencies":"a-b"}"#,
        #"{"adjacencies":[["a","b"]]}"#,
        #"{"adjacencies":{"stationIDs":["a","b"]}}"#,
    ])
    func wrongTypesFailAsTypeMismatch(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailwayLineTopology.self, from: Data(payload.utf8))
        }

        guard case .typeMismatch? = error else {
            Issue.record("expected .typeMismatch, got \(String(describing: error))")
            return
        }
    }

    /// Empty and disconnected graphs fail the topology invariant; an invalid
    /// nested adjacency fails through `StationAdjacency`'s own decoding.
    @Test(arguments: [
        #"{"adjacencies":[]}"#,
        #"{"adjacencies":[{"stationIDs":["a","b"]},{"stationIDs":["c","d"]}]}"#,
        #"{"adjacencies":[{"stationIDs":["a","a"]}]}"#,
        #"{"adjacencies":[{"stationIDs":["a"]}]}"#,
        #"{"adjacencies":[{"stationIDs":["a","b","c"]}]}"#,
        #"{"adjacencies":[{"stationIDs":["a",""]}]}"#,
    ])
    func invalidGraphsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailwayLineTopology.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [#""a-b""#, #"[{"stationIDs":["a","b"]}]"#, "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailwayLineTopology.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func topologiesCrossActorBoundaries() async throws {
        let subject = try Self.topology(("a", "b"), ("b", "c"), ("c", "a"))
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.adjacencies == subject.adjacencies)
        #expect(received.stationIDs == subject.stationIDs)
    }
}
