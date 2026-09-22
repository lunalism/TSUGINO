import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the unordered station adjacency value (DEC-057 D2,
/// ARCHITECTURE.md §5.2.1). All identifiers are synthetic.
struct StationAdjacencyTests {

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func adjacency(_ a: String, _ b: String) throws -> StationAdjacency {
        try #require(StationAdjacency(try Self.station(a), try Self.station(b)))
    }

    // MARK: - Construction

    @Test func constructionStoresExactlyTheTwoStations() throws {
        let a = try Self.station("st-a")
        let b = try Self.station("st-b")
        let subject = try #require(StationAdjacency(a, b))

        #expect(subject.stationIDs == [a, b])
        #expect(subject.stationIDs.count == 2)
    }

    @Test func reversedConstructionIsTheSameValue() throws {
        let forward = try Self.adjacency("st-a", "st-b")
        let reversed = try Self.adjacency("st-b", "st-a")

        #expect(forward == reversed)
        #expect(forward.hashValue == reversed.hashValue)
        #expect(Set([forward, reversed]).count == 1, "argument order carries no meaning")
    }

    @Test func distinctPairsAreUnequal() throws {
        let ab = try Self.adjacency("st-a", "st-b")
        let bc = try Self.adjacency("st-b", "st-c")
        let ac = try Self.adjacency("st-a", "st-c")

        #expect(ab != bc)
        #expect(ab != ac)
        #expect(Set([ab, bc, ac]).count == 3)
    }

    @Test func selfAdjacencyIsRejected() throws {
        let a = try Self.station("st-a")

        #expect(StationAdjacency(a, a) == nil)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesBothStations() throws {
        let original = try Self.adjacency("st-a", "st-b")
        let decoded = try JSONDecoder().decode(
            StationAdjacency.self,
            from: try JSONEncoder().encode(original)
        )

        // Compared as a set: the array order the encoder chose is not a contract.
        #expect(decoded.stationIDs == original.stationIDs)
        #expect(decoded == original)
    }

    /// Pins the wire shape a later migration would have to reason about
    /// (ARCHITECTURE.md §41). Endpoints are compared as a set so nothing about
    /// element order is asserted.
    @Test func encodedFormUsesExactlyTheStationIDsKey() throws {
        let encoded = try JSONEncoder().encode(try Self.adjacency("st-a", "st-b"))
        let object = try #require(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        let endpoints = try #require(object["stationIDs"] as? [String])

        #expect(Set(object.keys) == ["stationIDs"])
        #expect(Set(endpoints) == ["st-a", "st-b"])
        #expect(endpoints.count == 2)
    }

    /// Either encoded order decodes to the same value.
    @Test(arguments: [
        #"{"stationIDs":["st-a","st-b"]}"#,
        #"{"stationIDs":["st-b","st-a"]}"#,
    ])
    func eitherEncodedOrderDecodesToTheSameValue(payload: String) throws {
        let decoded = try JSONDecoder().decode(StationAdjacency.self, from: Data(payload.utf8))

        #expect(decoded == (try Self.adjacency("st-a", "st-b")))
    }

    @Test func missingKeyFailsAsKeyNotFound() {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(StationAdjacency.self, from: Data("{}".utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"stationIDs":"st-a"}"#,
        #"{"stationIDs":[1,2]}"#,
        #"{"stationIDs":{"a":"st-a"}}"#,
    ])
    func wrongTypesFailAsTypeMismatch(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(StationAdjacency.self, from: Data(payload.utf8))
        }

        guard case .typeMismatch? = error else {
            Issue.record("expected .typeMismatch, got \(String(describing: error))")
            return
        }
    }

    /// Zero, one, duplicate-only (which collapses to one), and more than two
    /// identifiers all violate the exactly-two rule, and a blank identifier
    /// fails through `StationID` itself (DEC-051).
    @Test(arguments: [
        #"{"stationIDs":[]}"#,
        #"{"stationIDs":["st-a"]}"#,
        #"{"stationIDs":["st-a","st-a"]}"#,
        #"{"stationIDs":["st-a","st-b","st-c"]}"#,
        #"{"stationIDs":["st-a",""]}"#,
        #"{"stationIDs":["st-a"," "]}"#,
    ])
    func invalidEndpointSetsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(StationAdjacency.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [#""st-a""#, #"["st-a","st-b"]"#, "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(StationAdjacency.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func adjacenciesCrossActorBoundaries() async throws {
        let subject = try Self.adjacency("st-a", "st-b")
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.stationIDs == subject.stationIDs)
    }
}
