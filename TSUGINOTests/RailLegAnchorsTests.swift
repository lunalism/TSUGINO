import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for a rail leg's station anchors and the pure
/// anchor-preservation check (DEC-062 C, ARCHITECTURE.md §5.5). All
/// identifiers are synthetic.
struct RailLegAnchorsTests {

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func anchors(_ boarding: String, _ alighting: String) throws -> RailLegAnchors {
        try #require(
            RailLegAnchors(boardingStationID: try Self.station(boarding), alightingStationID: try Self.station(alighting))
        )
    }

    private static func trip(_ stops: [String]) throws -> Trip {
        let lineID = try #require(LineID("ln-1"))
        let tripID = try #require(TripID("tr-1"))
        let segment = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: stops.count - 1))
        return try #require(
            Trip(
                id: tripID,
                stopSequence: try stops.map { try Self.station($0) },
                lineSegments: [segment],
                coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: true),
                serviceTypeSegments: []
            )
        )
    }

    private static func selection(_ stops: [String], _ boarding: Int, _ alighting: Int) throws -> SelectedRailTrip {
        try #require(SelectedRailTrip(trip: try Self.trip(stops), boardingIndex: boarding, alightingIndex: alighting))
    }

    // MARK: - Construction

    @Test func constructionPreservesBothStations() throws {
        let subject = try Self.anchors("a", "b")

        #expect(subject.boardingStationID == (try Self.station("a")))
        #expect(subject.alightingStationID == (try Self.station("b")))
    }

    @Test func sameStationAtBothEndsIsRejected() throws {
        let a = try Self.station("a")

        #expect(RailLegAnchors(boardingStationID: a, alightingStationID: a) == nil)
    }

    @Test func equalityAndHashingUseBothStations() throws {
        let ab = try Self.anchors("a", "b")

        #expect(ab == (try Self.anchors("a", "b")))
        #expect(ab.hashValue == (try Self.anchors("a", "b")).hashValue)
        #expect(ab != (try Self.anchors("b", "a")), "direction matters")
        #expect(ab != (try Self.anchors("a", "c")))
    }

    // MARK: - Anchor preservation (DEC-062 C4)

    @Test func selectionAtTheSameStationsIsAdmitted() throws {
        let anchors = try Self.anchors("b", "d")

        #expect(anchors.admits(try Self.selection(["a", "b", "c", "d", "e"], 1, 3)))
    }

    @Test(arguments: [(0, 3), (1, 2), (1, 4), (2, 4)])
    func selectionThatChangesAnAnchorIsNotAdmitted(sample: (Int, Int)) throws {
        let anchors = try Self.anchors("b", "d")

        #expect(!anchors.admits(try Self.selection(["a", "b", "c", "d", "e"], sample.0, sample.1)))
    }

    /// A repeated station is addressed by index; any visit that boards and
    /// alights at the anchored stations preserves the anchors.
    @Test func selectionAtEitherVisitOfARepeatedStationIsAdmitted() throws {
        let anchors = try Self.anchors("j", "t")
        let stops = ["j", "a", "b", "j", "t"]

        #expect(anchors.admits(try Self.selection(stops, 0, 4)))
        #expect(anchors.admits(try Self.selection(stops, 3, 4)))
    }

    @Test func derivedAnchorsMatchTheSelectedStops() throws {
        let selection = try Self.selection(["a", "b", "c"], 0, 2)

        #expect(selection.anchors == (try Self.anchors("a", "c")))
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesBothStations() throws {
        let original = try Self.anchors("a", "b")
        let decoded = try JSONDecoder().decode(RailLegAnchors.self, from: try JSONEncoder().encode(original))

        #expect(decoded == original)
    }

    @Test func encodedShapeContainsOnlyTheTwoStations() throws {
        let data = try JSONEncoder().encode(try Self.anchors("a", "b"))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(object.keys) == ["boardingStationID", "alightingStationID"])
    }

    @Test(arguments: [
        #"{"alightingStationID":"b"}"#,
        #"{"boardingStationID":"a"}"#,
    ])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailLegAnchors.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"boardingStationID":"a","alightingStationID":"a"}"#,
        #"{"boardingStationID":"","alightingStationID":"b"}"#,
        #"{"boardingStationID":"a","alightingStationID":" "}"#,
    ])
    func invalidPayloadsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailLegAnchors.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }
}
