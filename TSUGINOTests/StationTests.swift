import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for canonical station identity, coordinate, and line
/// membership (DEC-048, DEC-053, DEC-055, DEC-056, ARCHITECTURE.md §5.1).
///
/// Every coordinate here is synthetic; no canonical Tokyo station data appears.
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

    private static func coordinate(latitude: Double = 35.5, longitude: Double = 139.5) throws -> GeoCoordinate {
        try #require(GeoCoordinate(latitude: latitude, longitude: longitude))
    }

    /// A valid station whose fields all default to the fixtures above.
    private static func station(
        id: String = "st-1",
        name: LocalizedRailName? = nil,
        coordinate: GeoCoordinate? = nil,
        lineIDs: Set<LineID> = []
    ) throws -> Station {
        Station(
            id: try Self.id(id),
            name: try name ?? Self.name(),
            coordinate: try coordinate ?? Self.coordinate(),
            lineIDs: lineIDs
        )
    }

    // A valid nested name and coordinate for hand-written payloads, so each
    // malformed case fails for its intended reason and not for a missing key.
    private static let validName = #"{"japanese":"市ヶ谷","english":"Ichigaya","korean":"이치가야"}"#
    private static let validCoordinate = #"{"latitude":35.5,"longitude":139.5}"#

    // MARK: - Construction

    @Test func constructionPreservesEveryField() throws {
        let id = try Self.id("st-1")
        let name = try Self.name()
        let coordinate = try Self.coordinate(latitude: -12.25, longitude: 45.75)
        let lines = try Self.lines("ln-a", "ln-b")
        let subject = Station(id: id, name: name, coordinate: coordinate, lineIDs: lines)

        #expect(subject.id == id)
        #expect(subject.name == name)
        #expect(subject.name.korean == "이치가야")
        #expect(subject.coordinate == coordinate)
        #expect(subject.coordinate.latitude == -12.25)
        #expect(subject.coordinate.longitude == 45.75)
        #expect(subject.lineIDs == lines)
    }

    @Test func emptyLineMembershipIsAccepted() throws {
        let subject = try Self.station(lineIDs: [])

        #expect(subject.lineIDs.isEmpty)
    }

    /// Membership is unordered and duplicate-free by construction (DEC-055 D2):
    /// two stations built from the same lines in different order, or with a
    /// line repeated, hold the same set. Nothing here inspects encoded order.
    @Test func lineMembershipIsUnorderedAndDuplicateFree() throws {
        let a = try Self.line("ln-a")
        let b = try Self.line("ln-b")
        let forwards = try Self.station(lineIDs: [a, b])
        let backwards = try Self.station(lineIDs: [b, a])
        let repeated = try Self.station(lineIDs: [a, b, a])

        #expect(forwards.lineIDs == backwards.lineIDs)
        #expect(repeated.lineIDs == forwards.lineIDs)
        #expect(repeated.lineIDs.count == 2)
    }

    // MARK: - Identity semantics (ID only)

    @Test func sameIDWithDifferentNameCoordinateAndLinesComparesEqual() throws {
        let a = try Self.station(lineIDs: try Self.lines("ln-a"))
        let revised = try Self.station(
            name: try Self.name(japanese: "市ケ谷"),
            coordinate: try Self.coordinate(latitude: 35.6, longitude: 139.6),
            lineIDs: try Self.lines("ln-a", "ln-b")
        )

        #expect(a == revised)
        #expect(a.name != revised.name, "the names really do differ")
        #expect(a.coordinate != revised.coordinate, "the coordinates really do differ")
        #expect(a.lineIDs != revised.lineIDs, "the memberships really do differ")
    }

    @Test func sameIDWithDifferentCoordinateHashesIdenticallyAndDeduplicates() throws {
        let a = try Self.station()
        let moved = try Self.station(coordinate: try Self.coordinate(latitude: -35.5, longitude: -139.5))
        let renamed = try Self.station(name: try Self.name(english: "Ichigaya (revised)"), lineIDs: try Self.lines("ln-a"))

        #expect(a.hashValue == moved.hashValue)
        #expect(a.hashValue == renamed.hashValue)
        #expect(Set([a, moved, renamed]).count == 1, "a corrected station is the same station")
    }

    @Test func dictionaryKeyingFollowsIdentityNotDescriptiveData() throws {
        var table: [Station: Int] = [:]
        table[try Self.station()] = 1
        table[try Self.station(
            name: try Self.name(korean: "이치가야역"),
            coordinate: try Self.coordinate(latitude: 1, longitude: 2),
            lineIDs: try Self.lines("ln-a")
        )] = 2
        table[try Self.station(id: "st-2")] = 3

        #expect(table.count == 2)
        #expect(table[try Self.station()] == 2, "the second write replaced the first")
    }

    @Test func differentIDsCompareUnequalEvenWithIdenticalMetadata() throws {
        let name = try Self.name()
        let coordinate = try Self.coordinate()
        let lines = try Self.lines("ln-a")
        let a = Station(id: try Self.id("st-1"), name: name, coordinate: coordinate, lineIDs: lines)
        let b = Station(id: try Self.id("st-2"), name: name, coordinate: coordinate, lineIDs: lines)

        #expect(a != b)
        #expect(a.coordinate == b.coordinate, "the coordinates really are identical")
        #expect(Set([a, b]).count == 2)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = try Self.station(
            coordinate: try Self.coordinate(latitude: -89.999999, longitude: 179.999999),
            lineIDs: try Self.lines("ln-a", "ln-b")
        )
        let decoded = try JSONDecoder().decode(
            Station.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so every descriptive field is compared explicitly:
        // `decoded == original` alone would pass even if the name, coordinate,
        // or line membership had been lost. Membership is compared as a set,
        // never as a serialised array, because encoded element order is not a
        // contract.
        #expect(decoded.id == original.id)
        #expect(decoded.name.japanese == original.name.japanese)
        #expect(decoded.name.english == original.name.english)
        #expect(decoded.name.korean == original.name.korean)
        #expect(decoded.coordinate.latitude == original.coordinate.latitude)
        #expect(decoded.coordinate.longitude == original.coordinate.longitude)
        #expect(decoded.lineIDs == original.lineIDs)
    }

    @Test func emptyLineMembershipRoundTrips() throws {
        let original = try Self.station(lineIDs: [])
        let decoded = try JSONDecoder().decode(
            Station.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded.lineIDs.isEmpty)
    }

    /// A regression guard for the encoded stored fields, not a general proof
    /// that `Station` has no other stored properties. It would catch an
    /// `operatorID`, provider ID, station code, or provider-coordinate
    /// collection added as a `Codable` member, which is the realistic way
    /// DEC-055 D1 or DEC-056 would be broken; a non-`Codable` member would
    /// slip past it.
    @Test func encodedShapeContainsOnlyIDNameCoordinateAndLineIDs() throws {
        let data = try JSONEncoder().encode(try Self.station(lineIDs: try Self.lines("ln-a")))
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "name", "coordinate", "lineIDs"])
    }

    /// The nested coordinate is encoded through `GeoCoordinate`'s own keyed
    /// shape; values are looked up by key, so nothing about ordering or
    /// numeric formatting is asserted.
    @Test func encodedCoordinateIsNestedUnderItsOwnKeys() throws {
        let data = try JSONEncoder().encode(
            try Self.station(coordinate: try Self.coordinate(latitude: 10, longitude: 20))
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let coordinate = try #require(object["coordinate"] as? [String: Any])

        #expect(Set(coordinate.keys) == ["latitude", "longitude"])
        #expect(coordinate["latitude"] as? Double == 10)
        #expect(coordinate["longitude"] as? Double == 20)
    }

    /// The encoded membership is read back as a set of decoded identifiers; the
    /// array order the encoder happened to choose is never asserted.
    @Test func encodedLineMembershipDecodesAsASet() throws {
        let lines = try Self.lines("ln-a", "ln-b", "ln-c")
        let data = try JSONEncoder().encode(try Self.station(lineIDs: lines))
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let encoded = try #require(object["lineIDs"] as? [String])

        #expect(Set(try encoded.map { try Self.line($0) }) == lines)
        #expect(encoded.count == lines.count, "no element is repeated in the encoded form")
    }

    @Test(arguments: [
        // missing required key
        #"{"name":\#(validName),"coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        #"{"id":"st-1","coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":\#(validCoordinate)}"#,
        // wrong field type
        #"{"id":1,"name":\#(validName),"coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        #"{"id":"st-1","name":"Ichigaya","coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":"35.5,139.5","lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":\#(validCoordinate),"lineIDs":"ln-a"}"#,
        // invalid nested canonical identifier (DEC-051)
        #"{"id":"","name":\#(validName),"coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":\#(validCoordinate),"lineIDs":["ln-a"," "]}"#,
        // invalid nested LocalizedRailName (DEC-053)
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"","korean":"이치가야"},"coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        #"{"id":"st-1","name":{"japanese":"市ヶ谷","english":"Ichigaya"},"coordinate":\#(validCoordinate),"lineIDs":[]}"#,
        // invalid nested GeoCoordinate (DEC-056)
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":35.5},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"longitude":139.5},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":"35.5","longitude":139.5},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":90.000001,"longitude":139.5},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":35.5,"longitude":-180.000001},"lineIDs":[]}"#,
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

    /// A nested coordinate that is out of range or, with a decoder able to
    /// produce it, non-finite fails through `GeoCoordinate`'s own decoding as
    /// `dataCorrupted` — the Station decoder adds nothing of its own.
    @Test(arguments: [
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":-91,"longitude":0},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":0,"longitude":181},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":"nan","longitude":0},"lineIDs":[]}"#,
        #"{"id":"st-1","name":\#(validName),"coordinate":{"latitude":0,"longitude":"inf"},"lineIDs":[]}"#,
    ])
    func invalidNestedCoordinateFailsAsDataCorrupted(payload: String) {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )

        let error = #expect(throws: DecodingError.self) {
            try decoder.decode(Station.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    // MARK: - Concurrency

    @Test func stationsCrossActorBoundaries() async throws {
        let subject = try Self.station(
            coordinate: try Self.coordinate(latitude: -12.5, longitude: 45.25),
            lineIDs: try Self.lines("ln-a")
        )
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.name == subject.name)
        #expect(received.coordinate.latitude == -12.5)
        #expect(received.coordinate.longitude == 45.25)
        #expect(received.lineIDs == subject.lineIDs)
    }
}
