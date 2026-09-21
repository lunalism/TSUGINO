import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for canonical railway line identity (DEC-053, DEC-055,
/// ARCHITECTURE.md §5.2).
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

    // MARK: - Construction

    @Test func constructionPreservesIDOperatorAndName() throws {
        let id = try Self.id("ln-1")
        let operatorID = try Self.operatorID("op-1")
        let name = try Self.name()
        let subject = RailwayLine(id: id, operatorID: operatorID, name: name)

        #expect(subject.id == id)
        #expect(subject.operatorID == operatorID)
        #expect(subject.name == name)
        #expect(subject.name.korean == "아사쿠사선")
    }

    // MARK: - Identity semantics (ID only)

    @Test func sameIDWithDifferentOperatorAndNameComparesEqual() throws {
        let id = try Self.id("ln-1")
        let a = RailwayLine(id: id, operatorID: try Self.operatorID("op-1"), name: try Self.name())
        let revised = RailwayLine(
            id: id,
            operatorID: try Self.operatorID("op-2"),
            name: try Self.name(english: "Asakusa Line (revised)")
        )

        #expect(a == revised)
        #expect(a.operatorID != revised.operatorID, "the operators really do differ")
        #expect(a.name != revised.name, "the names really do differ")
    }

    @Test func sameIDHashesIdenticallyAndDeduplicates() throws {
        let id = try Self.id("ln-1")
        let a = RailwayLine(id: id, operatorID: try Self.operatorID("op-1"), name: try Self.name())
        let revised = RailwayLine(id: id, operatorID: try Self.operatorID("op-2"), name: try Self.name(japanese: "都営浅草線"))

        #expect(a.hashValue == revised.hashValue)
        #expect(Set([a, revised]).count == 1, "a corrected line is the same line")
    }

    @Test func dictionaryKeyingFollowsIdentityNotDescriptiveData() throws {
        let id = try Self.id("ln-1")
        var table: [RailwayLine: Int] = [:]
        table[RailwayLine(id: id, operatorID: try Self.operatorID("op-1"), name: try Self.name())] = 1
        table[RailwayLine(id: id, operatorID: try Self.operatorID("op-2"), name: try Self.name(korean: "아사쿠사 선"))] = 2
        table[RailwayLine(id: try Self.id("ln-2"), operatorID: try Self.operatorID("op-1"), name: try Self.name())] = 3

        #expect(table.count == 2)
        #expect(
            table[RailwayLine(id: id, operatorID: try Self.operatorID("op-1"), name: try Self.name())] == 2,
            "the second write replaced the first"
        )
    }

    @Test func differentIDsCompareUnequalEvenWithIdenticalMetadata() throws {
        let operatorID = try Self.operatorID("op-1")
        let name = try Self.name()
        let a = RailwayLine(id: try Self.id("ln-1"), operatorID: operatorID, name: name)
        let b = RailwayLine(id: try Self.id("ln-2"), operatorID: operatorID, name: name)

        #expect(a != b)
        #expect(Set([a, b]).count == 2)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = RailwayLine(
            id: try Self.id("ln-1"),
            operatorID: try Self.operatorID("op-1"),
            name: try Self.name()
        )
        let decoded = try JSONDecoder().decode(
            RailwayLine.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so every descriptive field is compared explicitly:
        // `decoded == original` alone would pass even if the operator or the
        // name had been lost.
        #expect(decoded.id == original.id)
        #expect(decoded.operatorID == original.operatorID)
        #expect(decoded.name.japanese == original.name.japanese)
        #expect(decoded.name.english == original.name.english)
        #expect(decoded.name.korean == original.name.korean)
    }

    /// A regression guard for the encoded stored fields, not a general proof
    /// that `RailwayLine` has no other stored properties. It would catch a
    /// colour, station sequence, capability set, or provider ID added as a
    /// `Codable` member, which is the realistic way DEC-055 D4/D5 or DEC-054
    /// would be broken; a non-`Codable` member would slip past it.
    @Test func encodedShapeContainsOnlyIDOperatorIDAndName() throws {
        let data = try JSONEncoder().encode(
            RailwayLine(id: try Self.id("ln-1"), operatorID: try Self.operatorID("op-1"), name: try Self.name())
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "operatorID", "name"])
    }

    @Test(arguments: [
        // missing required key
        #"{"operatorID":"op-1","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}}"#,
        #"{"id":"ln-1","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}}"#,
        #"{"id":"ln-1","operatorID":"op-1"}"#,
        // wrong field type
        #"{"id":1,"operatorID":"op-1","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}}"#,
        #"{"id":"ln-1","operatorID":["op-1"],"name":{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":"Asakusa Line"}"#,
        // invalid canonical identifier (DEC-051)
        #"{"id":"","operatorID":"op-1","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}}"#,
        #"{"id":"ln-1","operatorID":" ","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"아사쿠사선"}}"#,
        // invalid nested LocalizedRailName (DEC-053)
        #"{"id":"ln-1","operatorID":"op-1","name":{"japanese":"浅草線","english":"Asakusa Line","korean":"\t"}}"#,
        #"{"id":"ln-1","operatorID":"op-1","name":{"japanese":"浅草線","korean":"아사쿠사선"}}"#,
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

    // MARK: - Concurrency

    @Test func railwayLinesCrossActorBoundaries() async throws {
        let subject = RailwayLine(id: try Self.id("ln-1"), operatorID: try Self.operatorID("op-1"), name: try Self.name())
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.operatorID == subject.operatorID)
        #expect(received.name == subject.name)
    }
}
