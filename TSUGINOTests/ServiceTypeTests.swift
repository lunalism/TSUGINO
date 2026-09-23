import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the canonical operator-scoped service type (DEC-061 C,
/// ARCHITECTURE.md §5.3). All identifiers and names are synthetic.
struct ServiceTypeTests {

    private static func name(
        japanese: String = "急行",
        english: String = "Express",
        korean: String = "급행"
    ) throws -> LocalizedRailName {
        try #require(LocalizedRailName(japanese: japanese, english: english, korean: korean))
    }

    private static func id(_ raw: String) throws -> ServiceTypeID {
        try #require(ServiceTypeID(raw))
    }

    private static func operatorID(_ raw: String) throws -> OperatorID {
        try #require(OperatorID(raw))
    }

    private static func serviceType(
        id: String = "st-1",
        operatorID: String = "op-1",
        name: LocalizedRailName? = nil
    ) throws -> ServiceType {
        ServiceType(
            id: try Self.id(id),
            operatorID: try Self.operatorID(operatorID),
            name: try name ?? Self.name()
        )
    }

    // MARK: - Construction

    @Test func constructionPreservesEveryField() throws {
        let id = try Self.id("st-1")
        let operatorID = try Self.operatorID("op-1")
        let name = try Self.name()
        let subject = ServiceType(id: id, operatorID: operatorID, name: name)

        #expect(subject.id == id)
        #expect(subject.operatorID == operatorID)
        #expect(subject.name == name)
        #expect(subject.name.korean == "급행")
    }

    // MARK: - Identity semantics (ID only)

    @Test func sameIDWithDifferentDescriptiveFieldsComparesEqual() throws {
        let a = try Self.serviceType()
        let corrected = try Self.serviceType(
            operatorID: "op-2",
            name: try Self.name(english: "Rapid Express")
        )

        #expect(a == corrected, "a corrected service type is the same service type")
        #expect(a.operatorID != corrected.operatorID, "the operators really do differ")
        #expect(a.name != corrected.name, "the names really do differ")
    }

    @Test func sameIDHashesIdenticallyAndDeduplicates() throws {
        let a = try Self.serviceType()
        let renamed = try Self.serviceType(name: try Self.name(japanese: "急行（改称）"))

        #expect(a.hashValue == renamed.hashValue)
        #expect(Set([a, renamed]).count == 1)
    }

    /// Operator scope: the same label on two operators is two service types,
    /// distinguished by identity, never merged by name.
    @Test func sameLabelOnTwoOperatorsIsTwoServiceTypes() throws {
        let name = try Self.name()
        let first = try Self.serviceType(id: "st-a", operatorID: "op-1", name: name)
        let second = try Self.serviceType(id: "st-b", operatorID: "op-2", name: name)

        #expect(first != second)
        #expect(first.name == second.name, "the labels really are identical")
        #expect(Set([first, second]).count == 2)
    }

    @Test func dictionaryKeyingFollowsIdentityNotDescriptiveData() throws {
        var table: [ServiceType: Int] = [:]
        table[try Self.serviceType()] = 1
        table[try Self.serviceType(name: try Self.name(korean: "급행 열차"))] = 2
        table[try Self.serviceType(id: "st-2")] = 3

        #expect(table.count == 2)
        #expect(table[try Self.serviceType()] == 2, "the second write replaced the first")
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = try Self.serviceType()
        let decoded = try JSONDecoder().decode(
            ServiceType.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so the descriptive fields are compared
        // explicitly: `decoded == original` alone would pass even if they had
        // been lost.
        #expect(decoded.id == original.id)
        #expect(decoded.operatorID == original.operatorID)
        #expect(decoded.name == original.name)
    }

    /// A regression guard for the encoded shape. It would catch a rank, fare,
    /// seating, brand, or provider code added as a `Codable` member, which is
    /// the realistic way DEC-061 C would be broken; a non-`Codable` member
    /// would slip past it.
    @Test func encodedShapeContainsOnlyIDOperatorAndName() throws {
        let data = try JSONEncoder().encode(try Self.serviceType())
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "operatorID", "name"])
        #expect(object["id"] as? String == "st-1")
        #expect(object["operatorID"] as? String == "op-1")
    }

    private static let validName = #"{"japanese":"急行","english":"Express","korean":"급행"}"#

    @Test(arguments: [
        #"{"operatorID":"op-1","name":\#(validName)}"#,
        #"{"id":"st-1","name":\#(validName)}"#,
        #"{"id":"st-1","operatorID":"op-1"}"#,
    ])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ServiceType.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    /// A blank identifier fails through the identifier's own rule (DEC-051).
    @Test(arguments: [
        #"{"id":"","operatorID":"op-1","name":\#(validName)}"#,
        #"{"id":" ","operatorID":"op-1","name":\#(validName)}"#,
        #"{"id":"st-1","operatorID":"","name":\#(validName)}"#,
    ])
    func blankIdentifiersFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ServiceType.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [#""st-1""#, "[]", "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ServiceType.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func serviceTypesCrossActorBoundaries() async throws {
        let subject = try Self.serviceType()
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.operatorID == subject.operatorID)
        #expect(received.name == subject.name)
    }
}
