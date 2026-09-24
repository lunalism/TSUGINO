import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for a selected Trip snapshot with boarding and alighting
/// indices (DEC-062 C, ARCHITECTURE.md §5.5). All identifiers are synthetic.
///
/// `SelectedRailTrip` is deliberately not `Equatable` (DEC-062 B), so every
/// comparison here reads the snapshot's fields and the indices explicitly.
struct SelectedRailTripTests {

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func trip(
        id: String = "tr-1",
        _ stops: [String] = ["a", "b", "c", "d"],
        coverage: TripCoverage = TripCoverage(includesServiceOrigin: true, includesServiceDestination: true)
    ) throws -> Trip {
        let lineID = try #require(LineID("ln-1"))
        let tripID = try #require(TripID(id))
        let segment = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: stops.count - 1))
        return try #require(
            Trip(
                id: tripID,
                stopSequence: try stops.map { try Self.station($0) },
                lineSegments: [segment],
                coverage: coverage,
                serviceTypeSegments: []
            )
        )
    }

    private static let validTrip =
        #"{"id":"tr-1","stopSequence":["a","b","c","d"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":3}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true},"serviceTypeSegments":[]}"#

    private static func payload(trip: String = validTrip, boarding: String = "0", alighting: String = "2") -> String {
        #"{"trip":\#(trip),"boardingIndex":\#(boarding),"alightingIndex":\#(alighting)}"#
    }

    // MARK: - Construction

    @Test func constructionPreservesTheSnapshotAndIndices() throws {
        let trip = try Self.trip()
        let subject = try #require(SelectedRailTrip(trip: trip, boardingIndex: 1, alightingIndex: 3))

        #expect(subject.trip.id == trip.id)
        #expect(subject.trip.stopSequence == trip.stopSequence)
        #expect(subject.boardingIndex == 1)
        #expect(subject.alightingIndex == 3)
        #expect(subject.boardingStationID == (try Self.station("b")))
        #expect(subject.alightingStationID == (try Self.station("d")))
    }

    @Test func fullTraversalAndOneMovementAreValid() throws {
        let trip = try Self.trip()

        #expect(SelectedRailTrip(trip: trip, boardingIndex: 0, alightingIndex: 3) != nil)
        #expect(SelectedRailTrip(trip: trip, boardingIndex: 2, alightingIndex: 3) != nil)
    }

    /// A loop-plus-tail run visits its junction twice; the index says which
    /// visit the rider boards at.
    @Test func boardingAtTheSecondVisitOfARepeatedStationIsAddressedByIndex() throws {
        let trip = try Self.trip(["j", "a", "b", "j", "t"])
        let first = try #require(SelectedRailTrip(trip: trip, boardingIndex: 0, alightingIndex: 4))
        let second = try #require(SelectedRailTrip(trip: trip, boardingIndex: 3, alightingIndex: 4))

        #expect(first.boardingStationID == second.boardingStationID)
        #expect(first.boardingIndex != second.boardingIndex)
    }

    /// A partial snapshot is valid; its indices can only address represented
    /// stops.
    @Test func partialCoverageSnapshotIsValid() throws {
        let trip = try Self.trip(coverage: TripCoverage(includesServiceOrigin: false, includesServiceDestination: false))

        #expect(SelectedRailTrip(trip: trip, boardingIndex: 0, alightingIndex: 1) != nil)
    }

    // MARK: - Rejection (never trapped)

    @Test(arguments: [
        (-1, 2), (Int.min, 2),       // negative boarding
        (2, 2), (0, 0),              // equal
        (3, 1), (Int.max, Int.min),  // reversed
        (0, 4), (0, Int.max),        // beyond the traversal
    ])
    func invalidIndicesAreRejected(sample: (Int, Int)) throws {
        #expect(SelectedRailTrip(trip: try Self.trip(), boardingIndex: sample.0, alightingIndex: sample.1) == nil)
    }

    /// A full lap of a loop ends where it began and carries the rider nowhere.
    @Test func sameStationAtBothEndsIsRejected() throws {
        let loop = try Self.trip(["a", "b", "c", "a"])

        #expect(SelectedRailTrip(trip: loop, boardingIndex: 0, alightingIndex: 3) == nil)
        #expect(SelectedRailTrip(trip: loop, boardingIndex: 0, alightingIndex: 2) != nil)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesTheSnapshotAndIndices() throws {
        let original = try #require(
            SelectedRailTrip(trip: try Self.trip(["j", "a", "b", "j", "t"]), boardingIndex: 3, alightingIndex: 4)
        )
        let decoded = try JSONDecoder().decode(SelectedRailTrip.self, from: try JSONEncoder().encode(original))

        #expect(decoded.trip.id == original.trip.id)
        #expect(decoded.trip.stopSequence == original.trip.stopSequence)
        #expect(decoded.trip.lineSegments == original.trip.lineSegments)
        #expect(decoded.trip.coverage == original.trip.coverage)
        #expect(decoded.trip.serviceTypeSegments == original.trip.serviceTypeSegments)
        #expect(decoded.boardingIndex == 3)
        #expect(decoded.alightingIndex == 4)
    }

    /// Anchors are derived, never encoded a second time (DEC-062 C2).
    @Test func encodedShapeContainsOnlyTheSnapshotAndIndices() throws {
        let data = try JSONEncoder().encode(
            try #require(SelectedRailTrip(trip: try Self.trip(), boardingIndex: 0, alightingIndex: 2))
        )
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(object.keys) == ["trip", "boardingIndex", "alightingIndex"])
    }

    @Test(arguments: [
        #"{"boardingIndex":0,"alightingIndex":2}"#,
        #"{"trip":\#(validTrip),"alightingIndex":2}"#,
        #"{"trip":\#(validTrip),"boardingIndex":0}"#,
    ])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(SelectedRailTrip.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        Self.payload(boarding: "-1"),
        Self.payload(boarding: "2", alighting: "2"),
        Self.payload(boarding: "3", alighting: "1"),
        Self.payload(alighting: "4"),
        Self.payload(alighting: "9223372036854775807"),
        Self.payload(boarding: "-9223372036854775808"),
        // same station at both ends
        Self.payload(
            trip: #"{"id":"tr-1","stopSequence":["a","b","a"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true},"serviceTypeSegments":[]}"#
        ),
        // invalid nested Trip
        Self.payload(
            trip: #"{"id":"tr-1","stopSequence":["a","a","b"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true},"serviceTypeSegments":[]}"#
        ),
    ])
    func invalidPayloadsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(SelectedRailTrip.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    // MARK: - Concurrency

    @Test func selectionsCrossActorBoundaries() async throws {
        let subject = try #require(SelectedRailTrip(trip: try Self.trip(), boardingIndex: 1, alightingIndex: 3))
        let received = await Task.detached { subject }.value

        #expect(received.trip.id == subject.trip.id)
        #expect(received.trip.stopSequence == subject.trip.stopSequence)
        #expect(received.boardingIndex == 1)
        #expect(received.alightingIndex == 3)
    }
}
