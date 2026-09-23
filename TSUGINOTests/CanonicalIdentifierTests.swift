import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the canonical domain identifiers (DEC-021, DEC-051,
/// DEC-061, ARCHITECTURE.md §39).
struct CanonicalIdentifierTests {

    // MARK: - Shared contract across all six types

    /// Exercises the shared contract against one concrete identifier type without
    /// erasing it: `Identifier` is bound to a single nominal type per call, so the
    /// six types are never funnelled through one domain type.
    private static func assertSharedContract<Identifier: CanonicalIdentifier>(
        for type: Identifier.Type
    ) throws {
        // Valid values are accepted and preserved exactly.
        for raw in ["A", "S-001", " A ", "駅-001", "aBc-01", "S/001#a", "\ta\n"] {
            let identifier = try #require(Identifier(raw), "\(type) rejected a valid value: \(raw.debugDescription)")
            #expect(identifier.rawValue == raw)
        }

        // Blank values are rejected (DEC-051).
        for blank in ["", " ", "\t", "\n", "\t\n", "   \t\n", "\u{00A0}", "\u{3000}"] {
            #expect(Identifier(blank) == nil, "\(type) accepted a blank value: \(blank.debugDescription)")
        }

        // Equality and hashing.
        let a = try #require(Identifier("X-1"))
        let sameAsA = try #require(Identifier("X-1"))
        let b = try #require(Identifier("X-2"))
        #expect(a == sameAsA)
        #expect(a != b)
        #expect(Set([a, sameAsA, b]).count == 2)

        // Codable round trip preserves the raw value exactly, as a bare string.
        let unicode = try #require(Identifier(" Mixed Case / 駅 #1 "))
        let data = try JSONEncoder().encode(unicode)
        let decoded = try JSONDecoder().decode(Identifier.self, from: data)
        #expect(decoded == unicode)
        #expect(decoded.rawValue == " Mixed Case / 駅 #1 ")

        // Decoding applies the same validity rule as direct construction.
        for invalid in ["\"\"", "\" \"", "\"\\t\\n\""] {
            #expect(throws: DecodingError.self) {
                try JSONDecoder().decode(Identifier.self, from: Data(invalid.utf8))
            }
        }
    }

    @Test func stationIDSatisfiesTheSharedContract() throws {
        try Self.assertSharedContract(for: StationID.self)
    }

    @Test func lineIDSatisfiesTheSharedContract() throws {
        try Self.assertSharedContract(for: LineID.self)
    }

    @Test func operatorIDSatisfiesTheSharedContract() throws {
        try Self.assertSharedContract(for: OperatorID.self)
    }

    @Test func tripIDSatisfiesTheSharedContract() throws {
        try Self.assertSharedContract(for: TripID.self)
    }

    @Test func journeyIDSatisfiesTheSharedContract() throws {
        try Self.assertSharedContract(for: JourneyID.self)
    }

    @Test func serviceTypeIDSatisfiesTheSharedContract() throws {
        try Self.assertSharedContract(for: ServiceTypeID.self)
    }

    // MARK: - Validity rule (DEC-051)

    @Test(arguments: ["", " ", "  ", "\t", "\n", "\r\n", "\t \n", "\u{00A0}", "\u{2028}", "\u{3000}"])
    func blankValuesAreRejected(blank: String) {
        #expect(StationID(blank) == nil)
    }

    @Test(arguments: ["A", "1", "-", " A", "A ", " A ", "\tA\n", "駅", "a b"])
    func valuesWithANonWhitespaceCharacterAreAccepted(raw: String) throws {
        let identifier = try #require(StationID(raw))

        #expect(identifier.rawValue == raw)
    }

    // MARK: - Losslessness (validity does not authorise normalisation)

    @Test(arguments: [
        "  S-001  ",
        "s-001",
        "S-001",
        "駅-001",
        "S/001#a",
        "\tS-001\n",
    ])
    func validValuesAreStoredWithoutNormalisation(raw: String) throws {
        let identifier = try #require(StationID(raw))

        #expect(identifier.rawValue == raw)
    }

    @Test func caseAndSurroundingWhitespaceRemainSignificant() throws {
        let upper = try #require(StationID("S-001"))
        let lower = try #require(StationID("s-001"))
        let padded = try #require(StationID(" S-001"))

        #expect(upper != lower)
        #expect(upper != padded)
        #expect(padded.rawValue == " S-001")
    }

    // MARK: - Nominal distinctness

    /// A regression guard for six separate concrete declarations. The compiler —
    /// not this test — is what prevents assigning one identifier type to another;
    /// collapsing them into a single generic or typealias would fail here.
    @Test func theSixIdentifiersAreSeparateConcreteDeclarations() {
        let names = Set(
            [StationID.self, LineID.self, OperatorID.self, TripID.self, JourneyID.self, ServiceTypeID.self]
                .map { String(describing: $0) }
        )

        #expect(names == ["StationID", "LineID", "OperatorID", "TripID", "JourneyID", "ServiceTypeID"])
    }

    @Test func identicalRawStringsDoNotCollideAcrossTypedCollections() throws {
        let shared = "1130"
        let station = try #require(StationID(shared))
        let line = try #require(LineID(shared))

        #expect(Set([station]).contains(station))
        #expect(Set([line]).contains(line))
        #expect(station.rawValue == line.rawValue)
    }

    // MARK: - Codable

    @Test func identifiersEncodeAsASingleStringValue() throws {
        let data = try JSONEncoder().encode(try #require(JourneyID("J-42")))

        #expect(String(data: data, encoding: .utf8) == "\"J-42\"")
    }

    @Test func blankPayloadsFailAsDataCorrupted() throws {
        for invalid in ["\"\"", "\" \"", "\"\\t\\n\""] {
            let error = #expect(throws: DecodingError.self) {
                try JSONDecoder().decode(StationID.self, from: Data(invalid.utf8))
            }

            guard case .dataCorrupted? = error else {
                Issue.record("expected .dataCorrupted for \(invalid), got \(String(describing: error))")
                continue
            }
        }
    }

    @Test(arguments: ["123", "null", "true", "{\"rawValue\":\"S-001\"}", "[\"S-001\"]"])
    func nonStringPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(StationID.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    /// The app target defaults to `MainActor` isolation, so domain values must be
    /// explicitly `nonisolated` and `Sendable` to cross actor boundaries
    /// (ARCHITECTURE.md §21, §22). The guarantee is compile-time; this check simply
    /// keeps the crossing exercised and deterministic.
    @Test func identifiersCrossActorBoundaries() async throws {
        let id = try #require(StationID("S-001"))
        let received = await Task.detached { id }.value

        #expect(received == id)
    }
}
