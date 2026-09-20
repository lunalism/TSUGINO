import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for canonical operator identity (DEC-049, DEC-053,
/// ARCHITECTURE.md §5.7).
struct OperatorTests {

    private static func name(
        japanese: String = "東京都交通局",
        english: String = "Toei",
        korean: String = "도영"
    ) throws -> LocalizedRailName {
        try #require(LocalizedRailName(japanese: japanese, english: english, korean: korean))
    }

    private static func id(_ raw: String) throws -> OperatorID {
        try #require(OperatorID(raw))
    }

    // MARK: - Construction

    @Test func constructionPreservesIDAndName() throws {
        let id = try Self.id("op-1")
        let name = try Self.name()
        let subject = Operator(id: id, name: name)

        #expect(subject.id == id)
        #expect(subject.name == name)
        #expect(subject.name.korean == "도영")
    }

    // MARK: - Identity semantics (ID only)

    @Test func sameIDWithDifferentNamesComparesEqual() throws {
        let id = try Self.id("op-1")
        let a = Operator(id: id, name: try Self.name())
        let renamed = Operator(id: id, name: try Self.name(english: "Tokyo Metropolitan Bureau"))

        #expect(a == renamed)
        #expect(a.name != renamed.name, "the names really do differ")
    }

    @Test func sameIDWithDifferentNamesHashesIdentically() throws {
        let id = try Self.id("op-1")
        let a = Operator(id: id, name: try Self.name())
        let renamed = Operator(id: id, name: try Self.name(japanese: "東京都交通局（改称）"))

        #expect(a.hashValue == renamed.hashValue)
        #expect(Set([a, renamed]).count == 1, "a renamed operator is the same operator")
    }

    @Test func differentIDsCompareUnequalEvenWithIdenticalNames() throws {
        let name = try Self.name()
        let a = Operator(id: try Self.id("op-1"), name: name)
        let b = Operator(id: try Self.id("op-2"), name: name)

        #expect(a != b)
        #expect(Set([a, b]).count == 2)
    }

    @Test func dictionaryKeyingFollowsIdentityNotDisplayText() throws {
        let id = try Self.id("op-1")
        var table: [Operator: Int] = [:]
        table[Operator(id: id, name: try Self.name())] = 1
        table[Operator(id: id, name: try Self.name(korean: "도쿄도교통국"))] = 2
        table[Operator(id: try Self.id("op-2"), name: try Self.name())] = 3

        #expect(table.count == 2)
        #expect(table[Operator(id: id, name: try Self.name())] == 2, "the second write replaced the first")
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesBothFields() throws {
        let original = Operator(id: try Self.id("op-1"), name: try Self.name())
        let decoded = try JSONDecoder().decode(
            Operator.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so the name is compared explicitly: `decoded ==
        // original` alone would pass even if the name had been lost.
        #expect(decoded.id == original.id)
        #expect(decoded.name.japanese == original.name.japanese)
        #expect(decoded.name.english == original.name.english)
        #expect(decoded.name.korean == original.name.korean)
    }

    /// A regression guard for the encoded shape, not a general proof that
    /// `Operator` has no other stored properties. It would catch a capability
    /// set or provider ID added as a `Codable` member, which is the realistic
    /// way DEC-049's prohibition would be broken; a non-`Codable` member would
    /// slip past it.
    @Test func encodedShapeContainsOnlyIDAndName() throws {
        let data = try JSONEncoder().encode(
            Operator(id: try Self.id("op-1"), name: try Self.name())
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "name"])
    }

    // MARK: - Concurrency

    @Test func operatorsCrossActorBoundaries() async throws {
        let subject = Operator(id: try Self.id("op-1"), name: try Self.name())
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.name == subject.name)
    }
}
