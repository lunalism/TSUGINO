import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for a stated walk between stations (DEC-062 D,
/// ARCHITECTURE.md §5.5). Structural validity asserts nothing about whether a
/// real pedestrian connection exists; that is Phase 2 / Phase 10. All
/// identifiers are synthetic.
struct WalkingTransferTests {

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func walk(_ from: String, _ to: String) throws -> WalkingTransfer {
        try #require(WalkingTransfer(fromStationID: try Self.station(from), toStationID: try Self.station(to)))
    }

    // MARK: - Construction

    @Test func constructionPreservesBothStations() throws {
        let subject = try Self.walk("a", "b")

        #expect(subject.fromStationID == (try Self.station("a")))
        #expect(subject.toStationID == (try Self.station("b")))
    }

    /// A same-station transfer needs no walking leg.
    @Test func sameStationAtBothEndsIsRejected() throws {
        let a = try Self.station("a")

        #expect(WalkingTransfer(fromStationID: a, toStationID: a) == nil)
    }

    @Test func equalityAndHashingUseBothStations() throws {
        let ab = try Self.walk("a", "b")

        #expect(ab == (try Self.walk("a", "b")))
        #expect(ab.hashValue == (try Self.walk("a", "b")).hashValue)
        #expect(ab != (try Self.walk("b", "a")), "direction matters")
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesBothStations() throws {
        let original = try Self.walk("a", "b")
        let decoded = try JSONDecoder().decode(WalkingTransfer.self, from: try JSONEncoder().encode(original))

        #expect(decoded == original)
    }

    /// A regression guard for the encoded shape: a walking time, distance,
    /// route, or guidance field would appear here (DEC-062 D).
    @Test func encodedShapeContainsOnlyTheTwoStations() throws {
        let data = try JSONEncoder().encode(try Self.walk("a", "b"))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(object.keys) == ["fromStationID", "toStationID"])
    }

    @Test(arguments: [#"{"toStationID":"b"}"#, #"{"fromStationID":"a"}"#])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(WalkingTransfer.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"fromStationID":"a","toStationID":"a"}"#,
        #"{"fromStationID":"","toStationID":"b"}"#,
    ])
    func invalidPayloadsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(WalkingTransfer.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }
}
