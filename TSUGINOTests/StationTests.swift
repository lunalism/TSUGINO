import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for canonical station identity and line membership
/// (DEC-048, DEC-053, DEC-055, ARCHITECTURE.md §5.1).
struct StationTests {

    private static func name(
        japanese: String = "市ヶ谷",
        english: String = "Ichigaya",
        korean: String = "이치가야"
    ) throws -> LocalizedRailName {
        try #require(LocalizedRailName(japanese: japanese, english: english, korean: korean))
    }

    private static func id(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func line(_ raw: String) throws -> LineID {
        try #require(LineID(raw))
    }

    private static func lines(_ raws: String...) throws -> Set<LineID> {
        Set(try raws.map { try Self.line($0) })
    }

    // MARK: - Construction

    @Test func constructionPreservesIDNameAndLines() throws {
        let id = try Self.id("st-1")
        let name = try Self.name()
        let lines = try Self.lines("ln-a", "ln-b")
        let subject = Station(id: id, name: name, lineIDs: lines)

        #expect(subject.id == id)
        #expect(subject.name == name)
        #expect(subject.name.korean == "이치가야")
        #expect(subject.lineIDs == lines)
    }

    @Test func emptyLineMembershipIsAccepted() throws {
        let subject = Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: [])

        #expect(subject.lineIDs.isEmpty)
    }

    /// Membership is unordered and duplicate-free by construction (DEC-055 D2):
    /// two stations built from the same lines in different order, or with a
    /// line repeated, hold the same set. Nothing here inspects encoded order.
    @Test func lineMembershipIsUnorderedAndDuplicateFree() throws {
        let a = try Self.line("ln-a")
        let b = try Self.line("ln-b")
        let forwards = Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: [a, b])
        let backwards = Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: [b, a])
        let repeated = Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: [a, b, a])

        #expect(forwards.lineIDs == backwards.lineIDs)
        #expect(repeated.lineIDs == forwards.lineIDs)
        #expect(repeated.lineIDs.count == 2)
    }

    // MARK: - Identity semantics (ID only)

    @Test func sameIDWithDifferentNameAndLinesComparesEqual() throws {
        let id = try Self.id("st-1")
        let a = Station(id: id, name: try Self.name(), lineIDs: try Self.lines("ln-a"))
        let revised = Station(
            id: id,
            name: try Self.name(japanese: "市ケ谷"),
            lineIDs: try Self.lines("ln-a", "ln-b")
        )

        #expect(a == revised)
        #expect(a.name != revised.name, "the names really do differ")
        #expect(a.lineIDs != revised.lineIDs, "the memberships really do differ")
    }

    @Test func sameIDHashesIdenticallyAndDeduplicates() throws {
        let id = try Self.id("st-1")
        let a = Station(id: id, name: try Self.name(), lineIDs: [])
        let revised = Station(id: id, name: try Self.name(english: "Ichigaya (revised)"), lineIDs: try Self.lines("ln-a"))

        #expect(a.hashValue == revised.hashValue)
        #expect(Set([a, revised]).count == 1, "a corrected station is the same station")
    }

    @Test func dictionaryKeyingFollowsIdentityNotDescriptiveData() throws {
        let id = try Self.id("st-1")
        var table: [Station: Int] = [:]
        table[Station(id: id, name: try Self.name(), lineIDs: [])] = 1
        table[Station(id: id, name: try Self.name(korean: "이치가야역"), lineIDs: try Self.lines("ln-a"))] = 2
        table[Station(id: try Self.id("st-2"), name: try Self.name(), lineIDs: [])] = 3

        #expect(table.count == 2)
        #expect(table[Station(id: id, name: try Self.name(), lineIDs: [])] == 2, "the second write replaced the first")
    }

    @Test func differentIDsCompareUnequalEvenWithIdenticalMetadata() throws {
        let name = try Self.name()
        let lines = try Self.lines("ln-a")
        let a = Station(id: try Self.id("st-1"), name: name, lineIDs: lines)
        let b = Station(id: try Self.id("st-2"), name: name, lineIDs: lines)

        #expect(a != b)
        #expect(Set([a, b]).count == 2)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = Station(
            id: try Self.id("st-1"),
            name: try Self.name(),
            lineIDs: try Self.lines("ln-a", "ln-b")
        )
        let decoded = try JSONDecoder().decode(
            Station.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so every descriptive field is compared explicitly:
        // `decoded == original` alone would pass even if the name or the line
        // membership had been lost. Membership is compared as a set, never as
        // a serialised array, because encoded element order is not a contract.
        #expect(decoded.id == original.id)
        #expect(decoded.name.japanese == original.name.japanese)
        #expect(decoded.name.english == original.name.english)
        #expect(decoded.name.korean == original.name.korean)
        #expect(decoded.lineIDs == original.lineIDs)
    }

    @Test func emptyLineMembershipRoundTrips() throws {
        let original = Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: [])
        let decoded = try JSONDecoder().decode(
            Station.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded.lineIDs.isEmpty)
    }

    /// A regression guard for the encoded stored fields, not a general proof
    /// that `Station` has no other stored properties. It would catch an
    /// `operatorID`, coordinate, provider ID, or station code added as a
    /// `Codable` member, which is the realistic way DEC-055 D1 or the S3b
    /// gate would be broken; a non-`Codable` member would slip past it.
    @Test func encodedShapeContainsOnlyIDNameAndLineIDs() throws {
        let data = try JSONEncoder().encode(
            Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: try Self.lines("ln-a"))
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "name", "lineIDs"])
    }

    /// The encoded membership is read back as a set of decoded identifiers; the
    /// array order the encoder happened to choose is never asserted.
    @Test func encodedLineMembershipDecodesAsASet() throws {
        let lines = try Self.lines("ln-a", "ln-b", "ln-c")
        let data = try JSONEncoder().encode(
            Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: lines)
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let encoded = try #require(object["lineIDs"] as? [String])

        #expect(Set(try encoded.map { try Self.line($0) }) == lines)
        #expect(encoded.count == lines.count, "no element is repeated in the encoded form")
    }

    @Test(arguments: [
        // missing required key
        #"{"name":{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"},"lineIDs":[]}"#,
        #"{"id":"st-1","lineIDs":[]}"#,
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"}}"#,
        // wrong field type
        #"{"id":1,"name":{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"},"lineIDs":[]}"#,
        #"{"id":"st-1","name":"Ichigaya","lineIDs":[]}"#,
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"},"lineIDs":"ln-a"}"#,
        // invalid nested canonical identifier (DEC-051)
        #"{"id":"","name":{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"},"lineIDs":[]}"#,
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"},"lineIDs":["ln-a"," "]}"#,
        // invalid nested LocalizedRailName (DEC-053)
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"","korean":"이치가야"},"lineIDs":[]}"#,
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"Ichigaya"},"lineIDs":[]}"#,
        // not an object
        #""st-1""#,
        "[]",
        "null",
    ])
    func malformedPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Station.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func stationsCrossActorBoundaries() async throws {
        let subject = Station(id: try Self.id("st-1"), name: try Self.name(), lineIDs: try Self.lines("ln-a"))
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.name == subject.name)
        #expect(received.lineIDs == subject.lineIDs)
    }
}
