import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for `JourneyLeg` and `RailLeg`: their start and end
/// stations and the shared keyed `kind` / payload encoding (DEC-062 A, E, F;
/// ARCHITECTURE.md §5.5). All identifiers are synthetic.
///
/// Neither enum is `Equatable` (DEC-062 B); tests pattern-match and compare
/// the payload fields explicitly.
struct JourneyLegTests {

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
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

    private static func unselected(_ boarding: String, _ alighting: String) throws -> RailLeg {
        .unselected(
            try #require(
                RailLegAnchors(boardingStationID: try Self.station(boarding), alightingStationID: try Self.station(alighting))
            )
        )
    }

    private static func selected(_ stops: [String], _ boarding: Int, _ alighting: Int) throws -> RailLeg {
        .selected(try #require(SelectedRailTrip(trip: try Self.trip(stops), boardingIndex: boarding, alightingIndex: alighting)))
    }

    private static func walk(_ from: String, _ to: String) throws -> JourneyLeg {
        .walkingTransfer(try #require(WalkingTransfer(fromStationID: try Self.station(from), toStationID: try Self.station(to))))
    }

    private static func object(_ value: some Encodable) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: try JSONEncoder().encode(value)) as? [String: Any])
    }

    private static let anchorsPayload = #"{"boardingStationID":"a","alightingStationID":"b"}"#
    private static let selectionPayload =
        #"{"trip":{"id":"tr-1","stopSequence":["a","b","c"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true},"serviceTypeSegments":[]},"boardingIndex":0,"alightingIndex":2}"#
    private static let walkPayload = #"{"fromStationID":"a","toStationID":"b"}"#
    private static let railPayload = #"{"kind":"unselected","unselected":\#(anchorsPayload)}"#

    private static func expectDecodingError<Value: Decodable>(
        _ type: Value.Type,
        _ payload: String,
        _ matches: (DecodingError) -> Bool,
        _ expectation: String
    ) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(type, from: Data(payload.utf8))
        }

        guard let error, matches(error) else {
            Issue.record("expected \(expectation) for \(payload), got \(String(describing: error))")
            return
        }
    }

    private static func isKeyNotFound(_ error: DecodingError) -> Bool {
        if case .keyNotFound = error { true } else { false }
    }

    private static func isDataCorrupted(_ error: DecodingError) -> Bool {
        if case .dataCorrupted = error { true } else { false }
    }

    // MARK: - Start and end stations (DEC-062 E)

    @Test func unselectedRailLegStartsAndEndsAtItsAnchors() throws {
        let leg = JourneyLeg.rail(try Self.unselected("a", "b"))

        #expect(leg.startStationID == (try Self.station("a")))
        #expect(leg.endStationID == (try Self.station("b")))
    }

    @Test func selectedRailLegStartsAndEndsAtTheIndexedStops() throws {
        let leg = JourneyLeg.rail(try Self.selected(["j", "a", "b", "j", "t"], 3, 4))

        #expect(leg.startStationID == (try Self.station("j")))
        #expect(leg.endStationID == (try Self.station("t")))
    }

    @Test func walkingTransferStartsAndEndsAtItsStations() throws {
        let leg = try Self.walk("a", "b")

        #expect(leg.startStationID == (try Self.station("a")))
        #expect(leg.endStationID == (try Self.station("b")))
    }

    // MARK: - Encoded shape (DEC-062 F)

    @Test func unselectedRailLegEncodesKindAndOnePayload() throws {
        let object = try Self.object(JourneyLeg.rail(try Self.unselected("a", "b")))
        let rail = try #require(object["rail"] as? [String: Any])

        #expect(Set(object.keys) == ["kind", "rail"])
        #expect(object["kind"] as? String == "rail")
        #expect(Set(rail.keys) == ["kind", "unselected"])
        #expect(rail["kind"] as? String == "unselected")
    }

    @Test func selectedRailLegEncodesKindAndOnePayload() throws {
        let rail = try #require(
            try Self.object(JourneyLeg.rail(try Self.selected(["a", "b", "c"], 0, 2)))["rail"] as? [String: Any]
        )
        let selected = try #require(rail["selected"] as? [String: Any])

        #expect(Set(rail.keys) == ["kind", "selected"])
        #expect(rail["kind"] as? String == "selected")
        #expect(Set(selected.keys) == ["trip", "boardingIndex", "alightingIndex"])
    }

    @Test func walkingTransferEncodesKindAndOnePayload() throws {
        let object = try Self.object(try Self.walk("a", "b"))

        #expect(Set(object.keys) == ["kind", "walkingTransfer"])
        #expect(object["kind"] as? String == "walkingTransfer")
    }

    @Test func everyCaseRoundTrips() throws {
        let legs: [JourneyLeg] = [
            .rail(try Self.unselected("a", "b")),
            .rail(try Self.selected(["j", "a", "b", "j", "t"], 3, 4)),
            try Self.walk("a", "b"),
        ]
        let decoded = try JSONDecoder().decode([JourneyLeg].self, from: try JSONEncoder().encode(legs))

        guard
            case .rail(.unselected(let anchors)) = decoded[0],
            case .rail(.selected(let selection)) = decoded[1],
            case .walkingTransfer(let walk) = decoded[2]
        else {
            Issue.record("a case changed during the round trip")
            return
        }

        #expect(anchors == (try #require(RailLegAnchors(boardingStationID: try Self.station("a"), alightingStationID: try Self.station("b")))))
        #expect(selection.trip.stopSequence == (try Self.trip(["j", "a", "b", "j", "t"])).stopSequence)
        #expect(selection.boardingIndex == 3)
        #expect(selection.alightingIndex == 4)
        #expect(walk == (try #require(WalkingTransfer(fromStationID: try Self.station("a"), toStationID: try Self.station("b")))))
    }

    // MARK: - JourneyLeg decoding

    @Test(arguments: [
        #"{"rail":\#(railPayload)}"#,
        #"{"kind":"rail"}"#,
        #"{"kind":"walkingTransfer"}"#,
    ])
    func journeyLegMissingKindOrPayloadFailsAsKeyNotFound(payload: String) {
        Self.expectDecodingError(JourneyLeg.self, payload, Self.isKeyNotFound, ".keyNotFound")
    }

    @Test(arguments: [
        // unknown kind
        #"{"kind":"bus","rail":\#(railPayload)}"#,
        #"{"kind":"Rail","rail":\#(railPayload)}"#,
        #"{"kind":"","rail":\#(railPayload)}"#,
        // contradictory payload, alongside or instead of the named one
        #"{"kind":"rail","rail":\#(railPayload),"walkingTransfer":\#(walkPayload)}"#,
        #"{"kind":"rail","walkingTransfer":\#(walkPayload)}"#,
        #"{"kind":"walkingTransfer","walkingTransfer":\#(walkPayload),"rail":\#(railPayload)}"#,
        #"{"kind":"walkingTransfer","rail":\#(railPayload)}"#,
        // invalid nested value
        #"{"kind":"walkingTransfer","walkingTransfer":{"fromStationID":"a","toStationID":"a"}}"#,
        #"{"kind":"rail","rail":{"kind":"unselected","unselected":{"boardingStationID":"a","alightingStationID":"a"}}}"#,
    ])
    func journeyLegInvalidPayloadsFailAsDataCorrupted(payload: String) {
        Self.expectDecodingError(JourneyLeg.self, payload, Self.isDataCorrupted, ".dataCorrupted")
    }

    @Test(arguments: [
        #"{"kind":1,"rail":\#(railPayload)}"#,
        #"{"kind":"rail","rail":"unselected"}"#,
    ])
    func journeyLegWrongTypesFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(JourneyLeg.self, from: Data(payload.utf8))
        }
    }

    // MARK: - RailLeg decoding

    @Test(arguments: [
        #"{"unselected":\#(anchorsPayload)}"#,
        #"{"kind":"unselected"}"#,
        #"{"kind":"selected"}"#,
    ])
    func railLegMissingKindOrPayloadFailsAsKeyNotFound(payload: String) {
        Self.expectDecodingError(RailLeg.self, payload, Self.isKeyNotFound, ".keyNotFound")
    }

    @Test(arguments: [
        // unknown kind
        #"{"kind":"planned","unselected":\#(anchorsPayload)}"#,
        // contradictory payload, alongside or instead of the named one
        #"{"kind":"unselected","unselected":\#(anchorsPayload),"selected":\#(selectionPayload)}"#,
        #"{"kind":"unselected","selected":\#(selectionPayload)}"#,
        #"{"kind":"selected","selected":\#(selectionPayload),"unselected":\#(anchorsPayload)}"#,
        #"{"kind":"selected","unselected":\#(anchorsPayload)}"#,
        // invalid nested value
        #"{"kind":"selected","selected":{"trip":{"id":"tr-1","stopSequence":["a","b","c"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true},"serviceTypeSegments":[]},"boardingIndex":2,"alightingIndex":0}}"#,
        #"{"kind":"unselected","unselected":{"boardingStationID":"","alightingStationID":"b"}}"#,
    ])
    func railLegInvalidPayloadsFailAsDataCorrupted(payload: String) {
        Self.expectDecodingError(RailLeg.self, payload, Self.isDataCorrupted, ".dataCorrupted")
    }

    // MARK: - Concurrency

    @Test func legsCrossActorBoundaries() async throws {
        let subject = JourneyLeg.rail(try Self.selected(["a", "b", "c"], 0, 2))
        let received = await Task.detached { subject }.value

        #expect(received.startStationID == subject.startStationID)
        #expect(received.endStationID == subject.endStationID)
    }
}
