import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for canonical railway line identity and topology (DEC-053,
/// DEC-055, DEC-057, ARCHITECTURE.md §5.2).
///
/// Every topology here is synthetic; no canonical Tokyo line data appears.
struct RailwayLineTests {

    private static func name(
        japanese: String = "浅草線",
        english: String = "Asakusa Line",
        korean: String = "아사쿠사선"
    ) throws -> LocalizedRailName {
        try #require(LocalizedRailName(japanese: japanese, english: english, korean: korean))
    }

    private static func id(_ raw: String) throws -> LineID {
        try #require(LineID(raw))
    }

    private static func operatorID(_ raw: String) throws -> OperatorID {
        try #require(OperatorID(raw))
    }

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func edge(_ a: String, _ b: String) throws -> StationAdjacency {
        try #require(StationAdjacency(try Self.station(a), try Self.station(b)))
    }

    private static func topology(_ pairs: (String, String)...) throws -> RailwayLineTopology {
        try #require(RailwayLineTopology(adjacencies: Set(try pairs.map { try Self.edge($0.0, $0.1) })))
    }

    /// A valid line whose fields all default to the fixtures above.
    private static func line(
        id: String = "ln-1",
        operatorID: String = "op-1",
        name: LocalizedRailName? = nil,
        topology: RailwayLineTopology? = nil
    ) throws -> RailwayLine {
        RailwayLine(
            id: try Self.id(id),
            operatorID: try Self.operatorID(operatorID),
            name: try name ?? Self.name(),
            topology: try topology ?? Self.topology(("a", "b"), ("b", "c"))
        )
    }

    // A valid nested name and topology for hand-written payloads, so each
    // malformed case fails for its intended reason and not for a missing key.
    private static let validName = #"{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}"#
    private static let validTopology = #"{"adjacencies":[{"stationIDs":["a","b"]},{"stationIDs":["b","c"]}]}"#

    // MARK: - Construction

    @Test func constructionPreservesEveryField() throws {
        let id = try Self.id("ln-1")
        let operatorID = try Self.operatorID("op-1")
        let name = try Self.name()
        let topology = try Self.topology(("a", "b"), ("b", "c"), ("c", "a"))
        let subject = RailwayLine(id: id, operatorID: operatorID, name: name, topology: topology)

        #expect(subject.id == id)
        #expect(subject.operatorID == operatorID)
        #expect(subject.name == name)
        #expect(subject.name.korean == "아사쿠사선")
        #expect(subject.topology == topology)
        #expect(subject.topology.stationIDs.count == 3)
    }

    // MARK: - Identity semantics (ID only)

    @Test func sameIDWithDifferentOperatorNameAndTopologyComparesEqual() throws {
        let a = try Self.line()
        let revised = try Self.line(
            operatorID: "op-2",
            name: try Self.name(english: "Asakusa Line (revised)"),
            topology: try Self.topology(("a", "b"), ("b", "c"), ("c", "d"))
        )

        #expect(a == revised)
        #expect(a.operatorID != revised.operatorID, "the operators really do differ")
        #expect(a.name != revised.name, "the names really do differ")
        #expect(a.topology != revised.topology, "the topologies really do differ")
    }

    @Test func sameIDWithDifferentTopologyHashesIdenticallyAndDeduplicates() throws {
        let a = try Self.line()
        let corrected = try Self.line(topology: try Self.topology(("a", "b"), ("b", "c"), ("c", "d")))
        let renamed = try Self.line(name: try Self.name(japanese: "都営浅草線"))

        #expect(a.hashValue == corrected.hashValue)
        #expect(a.hashValue == renamed.hashValue)
        #expect(Set([a, corrected, renamed]).count == 1, "a corrected line is the same line")
    }

    @Test func dictionaryKeyingFollowsIdentityNotDescriptiveData() throws {
        var table: [RailwayLine: Int] = [:]
        table[try Self.line()] = 1
        table[try Self.line(
            operatorID: "op-2",
            name: try Self.name(korean: "아사쿠사 선"),
            topology: try Self.topology(("x", "y"))
        )] = 2
        table[try Self.line(id: "ln-2")] = 3

        #expect(table.count == 2)
        #expect(table[try Self.line()] == 2, "the second write replaced the first")
    }

    @Test func differentIDsCompareUnequalEvenWithIdenticalMetadata() throws {
        let operatorID = try Self.operatorID("op-1")
        let name = try Self.name()
        let topology = try Self.topology(("a", "b"), ("b", "c"))
        let a = RailwayLine(id: try Self.id("ln-1"), operatorID: operatorID, name: name, topology: topology)
        let b = RailwayLine(id: try Self.id("ln-2"), operatorID: operatorID, name: name, topology: topology)

        #expect(a != b)
        #expect(a.topology == b.topology, "the topologies really are identical")
        #expect(Set([a, b]).count == 2)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = try Self.line(topology: try Self.topology(("j", "a"), ("a", "b"), ("b", "j"), ("j", "t")))
        let decoded = try JSONDecoder().decode(
            RailwayLine.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so every descriptive field is compared explicitly:
        // `decoded == original` alone would pass even if the operator, name, or
        // topology had been lost. The adjacency set is compared as a set,
        // because encoded collection order is not a contract.
        #expect(decoded.id == original.id)
        #expect(decoded.operatorID == original.operatorID)
        #expect(decoded.name.japanese == original.name.japanese)
        #expect(decoded.name.english == original.name.english)
        #expect(decoded.name.korean == original.name.korean)
        #expect(decoded.topology.adjacencies == original.topology.adjacencies)
        #expect(decoded.topology.stationIDs == original.topology.stationIDs)
    }

    /// A regression guard for the encoded stored fields, not a general proof
    /// that `RailwayLine` has no other stored properties. It would catch a
    /// colour, capability set, or provider ID added as a `Codable` member,
    /// which is the realistic way DEC-055 D5 or DEC-054 would be broken; a
    /// non-`Codable` member would slip past it.
    @Test func encodedShapeContainsOnlyIDOperatorIDNameAndTopology() throws {
        let data = try JSONEncoder().encode(try Self.line())
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "operatorID", "name", "topology"])
    }

    /// The nested topology is encoded through its own keyed shape, with the
    /// derived membership absent; values are looked up by key, so nothing
    /// about ordering is asserted.
    @Test func encodedTopologyIsNestedUnderItsOwnKeys() throws {
        let data = try JSONEncoder().encode(try Self.line())
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let topology = try #require(object["topology"] as? [String: Any])
        let adjacencies = try #require(topology["adjacencies"] as? [[String: Any]])

        #expect(Set(topology.keys) == ["adjacencies"])
        #expect(adjacencies.count == 2)
    }

    @Test(arguments: [
        // missing required key
        #"{"operatorID":"op-1","name":\#(validName),"topology":\#(validTopology)}"#,
        #"{"id":"ln-1","name":\#(validName),"topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":"op-1","topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName)}"#,
        // wrong field type
        #"{"id":1,"operatorID":"op-1","name":\#(validName),"topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":["op-1"],"name":\#(validName),"topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":"Asakusa Line","topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":"a-b"}"#,
        // invalid canonical identifier (DEC-051)
        #"{"id":"","operatorID":"op-1","name":\#(validName),"topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":" ","name":\#(validName),"topology":\#(validTopology)}"#,
        // invalid nested LocalizedRailName (DEC-053)
        #"{"id":"ln-1","operatorID":"op-1","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"\t"},"topology":\#(validTopology)}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":{"japanese":"浅草線","korean":"아사쿠사선"},"topology":\#(validTopology)}"#,
        // invalid nested topology (DEC-057)
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":{"adjacencies":[]}}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":{"adjacencies":[{"stationIDs":["a","b"]},{"stationIDs":["c","d"]}]}}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":{"adjacencies":[{"stationIDs":["a","a"]}]}}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":{}}"#,
        // not an object
        #""ln-1""#,
        "[]",
        "null",
    ])
    func malformedPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailwayLine.self, from: Data(payload.utf8))
        }
    }

    /// An empty or disconnected nested topology fails through
    /// `RailwayLineTopology`'s own decoding as `dataCorrupted` — the line
    /// decoder adds nothing of its own.
    @Test(arguments: [
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":{"adjacencies":[]}}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":\#(validName),"topology":{"adjacencies":[{"stationIDs":["a","b"]},{"stationIDs":["c","d"]}]}}"#,
    ])
    func invalidNestedTopologyFailsAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailwayLine.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    // MARK: - Concurrency

    @Test func railwayLinesCrossActorBoundaries() async throws {
        let topology = try Self.topology(("a", "b"), ("b", "c"), ("c", "a"))
        let subject = try Self.line(topology: topology)
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.operatorID == subject.operatorID)
        #expect(received.name == subject.name)
        #expect(received.topology == topology)
        #expect(received.topology.adjacencies == subject.topology.adjacencies)
        #expect(received.topology.stationIDs == subject.topology.stationIDs)
    }
}
