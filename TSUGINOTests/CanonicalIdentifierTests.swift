import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the canonical domain identifiers (DEC-021, ARCHITECTURE.md §39).
struct CanonicalIdentifierTests {

    // MARK: - Equality

    @Test func sameRawValueComparesEqual() {
        #expect(StationID("S-001") == StationID("S-001"))
        #expect(LineID("L-001") == LineID("L-001"))
        #expect(OperatorID("O-001") == OperatorID("O-001"))
        #expect(TripID("T-001") == TripID("T-001"))
        #expect(JourneyID("J-001") == JourneyID("J-001"))
    }

    @Test func differentRawValuesCompareUnequal() {
        #expect(StationID("S-001") != StationID("S-002"))
        #expect(LineID("L-001") != LineID("L-002"))
        #expect(OperatorID("O-001") != OperatorID("O-002"))
        #expect(TripID("T-001") != TripID("T-002"))
        #expect(JourneyID("J-001") != JourneyID("J-002"))
    }

    // MARK: - Hashing

    @Test func hashBasedCollectionsTreatEqualValuesAsOneMember() {
        let set: Set<StationID> = [StationID("S-001"), StationID("S-001"), StationID("S-002")]

        #expect(set.count == 2)
        #expect(set.contains(StationID("S-001")))
        #expect(!set.contains(StationID("S-003")))
    }

    @Test func identifiersAreUsableAsDictionaryKeys() {
        // The provider mapping layer keys tables by canonical ID (ARCHITECTURE.md §40).
        var table: [LineID: Int] = [:]
        table[LineID("L-001")] = 1
        table[LineID("L-001")] = 2 // same key, must overwrite rather than add
        table[LineID("L-002")] = 3

        #expect(table.count == 2)
        #expect(table[LineID("L-001")] == 2)
    }

    // MARK: - Nominal distinctness

    /// The compiler already rejects assigning one identifier type to another, so there is
    /// nothing to assert at runtime about that. What is worth proving is the consequence
    /// that actually bites: identical raw strings must not collapse into one another in
    /// storage or lookup.
    @Test func identicalRawStringsStayInSeparateTypedNamespaces() {
        let shared = "1130"

        var stations: Set<StationID> = []
        var lines: Set<LineID> = []
        stations.insert(StationID(shared))
        lines.insert(LineID(shared))

        #expect(stations.contains(StationID(shared)))
        #expect(lines.contains(LineID(shared)))
        #expect(StationID(shared).rawValue == LineID(shared).rawValue)
    }

    @Test func eachIdentifierIsADistinctConcreteType() {
        // Distinct metatypes: a single generic bucket would make these all the same type.
        let types: [Any.Type] = [
            StationID.self, LineID.self, OperatorID.self, TripID.self, JourneyID.self,
        ]
        let names = Set(types.map { String(describing: $0) })

        #expect(names.count == 5)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesRawValueExactly() throws {
        let original = TripID("Toei.Asakusa.1234A")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TripID.self, from: data)

        #expect(decoded == original)
        #expect(decoded.rawValue == original.rawValue)
    }

    /// Encoding as a bare string keeps the persisted form stable and migration-legible
    /// (ARCHITECTURE.md §41). A keyed object would be a silent schema change.
    @Test func identifiersEncodeAsASingleStringValue() throws {
        let data = try JSONEncoder().encode(JourneyID("J-42"))

        #expect(String(data: data, encoding: .utf8) == "\"J-42\"")
    }

    @Test func decodingAcceptsAnyStringBecauseNoValidationRuleIsAccepted() throws {
        let data = Data("\"\"".utf8)
        let decoded = try JSONDecoder().decode(StationID.self, from: data)

        #expect(decoded.rawValue.isEmpty)
    }

    // MARK: - Losslessness

    /// No accepted document defines trimming, case folding, or any other normalisation
    /// for canonical identifiers, so none may be applied (DEC-021, Rule 9).
    @Test(arguments: [
        "  S-001  ",
        "s-001",
        "S-001",
        "",
        "駅-001",
        "S/001#a",
    ])
    func constructionIsLosslessAndAppliesNoNormalisation(raw: String) {
        #expect(StationID(raw).rawValue == raw)
    }

    @Test func caseAndWhitespaceRemainSignificant() {
        #expect(StationID("S-001") != StationID("s-001"))
        #expect(StationID("S-001") != StationID(" S-001"))
    }

    @Test func losslessThroughCodable() throws {
        let raw = "  Mixed Case / 駅 #1  "
        let data = try JSONEncoder().encode(OperatorID(raw))
        let decoded = try JSONDecoder().decode(OperatorID.self, from: data)

        #expect(decoded.rawValue == raw)
    }

    // MARK: - Concurrency

    /// The app target defaults to `MainActor` isolation, so domain values must be
    /// explicitly `nonisolated` and `Sendable` to cross actor boundaries
    /// (ARCHITECTURE.md §21, §22).
    @Test func identifiersAreSendable() async {
        let id = StationID("S-001")
        let received = await Task.detached { id }.value

        #expect(received == id)
    }
}
