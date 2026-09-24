import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for a passenger's route definition (DEC-062,
/// ARCHITECTURE.md §5.4). All identifiers are synthetic; no real railway
/// record appears. Nothing here asserts progression, readiness to track, or
/// that a stated walk is a verified pedestrian connection.
///
/// Legs are deliberately not `Equatable` (DEC-062 B), so legs are described
/// by plain specs and compared through their fields.
struct JourneyTests {

    // MARK: - Leg specs

    /// A plain, `Sendable` description of one leg, so invariant cases can be
    /// test arguments and can run through both construction and decoding.
    enum LegSpec: Sendable, CustomTestStringConvertible {
        case selected(trip: String, stops: [String], boarding: Int, alighting: Int)
        case unselected(String, String)
        case walk(String, String)

        var testDescription: String {
            switch self {
            case let .selected(trip, stops, boarding, alighting): "\(trip)\(stops)[\(boarding)→\(alighting)]"
            case let .unselected(from, to): "unselected \(from)→\(to)"
            case let .walk(from, to): "walk \(from)→\(to)"
            }
        }
    }

    struct JourneyCase: Sendable, CustomTestStringConvertible {
        let name: String
        let legs: [LegSpec]

        var testDescription: String { name }
    }

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func trip(_ id: String, _ stops: [String]) throws -> Trip {
        let lineID = try #require(LineID("ln-1"))
        let tripID = try #require(TripID(id))
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

    private static func leg(_ spec: LegSpec) throws -> JourneyLeg {
        switch spec {
        case let .selected(trip, stops, boarding, alighting):
            .rail(.selected(try #require(
                SelectedRailTrip(trip: try Self.trip(trip, stops), boardingIndex: boarding, alightingIndex: alighting)
            )))
        case let .unselected(from, to):
            .rail(.unselected(try #require(
                RailLegAnchors(boardingStationID: try Self.station(from), alightingStationID: try Self.station(to))
            )))
        case let .walk(from, to):
            .walkingTransfer(try #require(
                WalkingTransfer(fromStationID: try Self.station(from), toStationID: try Self.station(to))
            ))
        }
    }

    private static func legs(_ specs: [LegSpec]) throws -> [JourneyLeg] {
        try specs.map { try Self.leg($0) }
    }

    private static func journeyID(_ raw: String = "J-1") throws -> JourneyID {
        try #require(JourneyID(raw))
    }

    private static func journey(id: String = "J-1", _ specs: [LegSpec]) throws -> Journey? {
        Journey(id: try Self.journeyID(id), legs: try Self.legs(specs))
    }

    /// Encodes each leg on its own and assembles a Journey payload, so the
    /// decoder can be handed structures `init` would refuse to build.
    private static func journeyPayload(id: String = #""J-1""#, _ specs: [LegSpec]) throws -> String {
        let legs = try String(decoding: JSONEncoder().encode(Self.legs(specs)), as: UTF8.self)
        return #"{"id":\#(id),"legs":\#(legs)}"#
    }

    private static func decode(_ payload: String) throws -> Journey {
        try JSONDecoder().decode(Journey.self, from: Data(payload.utf8))
    }

    private static func expectDataCorrupted(_ payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try Self.decode(payload)
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    /// The station IDs of every leg's ends, for explicit comparison.
    private static func endpoints(_ journey: Journey) -> [[StationID]] {
        journey.legs.map { [$0.startStationID, $0.endStationID] }
    }

    // A loop-plus-tail snapshot: j at 0 and 3, a at 1 and 4.
    private static let loopStops = ["j", "a", "b", "j", "a", "t"]
    // Same TripID, a stop inserted before b.
    private static let insertedStops = ["j", "a", "x", "b", "j", "a", "t"]
    // Same TripID, the leading j removed.
    private static let removedStops = ["a", "b", "j", "a", "t"]

    // MARK: - Construction and identity

    @Test func constructionPreservesIDAndLegs() throws {
        let subject = try #require(try Self.journey([
            .selected(trip: "tr-1", stops: ["a", "b", "c"], boarding: 0, alighting: 2),
            .walk("c", "d"),
            .unselected("d", "e"),
        ]))

        #expect(subject.id == (try Self.journeyID()))
        #expect(subject.legs.count == 3)
        #expect(Self.endpoints(subject) == [
            [try Self.station("a"), try Self.station("c")],
            [try Self.station("c"), try Self.station("d")],
            [try Self.station("d"), try Self.station("e")],
        ])
    }

    @Test func sameIDWithDifferentLegsComparesEqual() throws {
        let a = try #require(try Self.journey([.unselected("a", "b")]))
        let replanned = try #require(try Self.journey([.unselected("a", "b"), .unselected("b", "c")]))

        #expect(a == replanned, "identity is the JourneyID alone")
        #expect(a.hashValue == replanned.hashValue)
        #expect(Set([a, replanned]).count == 1)
        #expect(a.legs.count != replanned.legs.count, "the legs really do differ")
    }

    @Test func differentIDsWithIdenticalLegsCompareUnequal() throws {
        let morning = try #require(try Self.journey(id: "J-1", [.unselected("a", "b")]))
        let evening = try #require(try Self.journey(id: "J-2", [.unselected("a", "b")]))

        #expect(morning != evening)
        #expect(Self.endpoints(morning) == Self.endpoints(evening))
        #expect(Set([morning, evening]).count == 2)
    }

    // MARK: - Valid shapes

    static let validCases: [JourneyCase] = [
        JourneyCase(name: "one unselected leg", legs: [.unselected("a", "b")]),
        JourneyCase(name: "all unselected", legs: [.unselected("a", "b"), .unselected("b", "c"), .unselected("c", "d")]),
        JourneyCase(name: "one selected leg", legs: [
            .selected(trip: "tr-1", stops: ["a", "b", "c"], boarding: 0, alighting: 2),
        ]),
        JourneyCase(name: "selected then unselected at the same station", legs: [
            .selected(trip: "tr-1", stops: ["a", "b", "c"], boarding: 0, alighting: 1),
            .unselected("b", "d"),
        ]),
        JourneyCase(name: "unselected then selected", legs: [
            .unselected("a", "b"),
            .selected(trip: "tr-1", stops: ["b", "c", "d"], boarding: 0, alighting: 2),
        ]),
        JourneyCase(name: "selected, walk, selected on different trips", legs: [
            .selected(trip: "tr-1", stops: ["a", "b"], boarding: 0, alighting: 1),
            .walk("b", "c"),
            .selected(trip: "tr-2", stops: ["c", "d"], boarding: 0, alighting: 1),
        ]),
        JourneyCase(name: "unselected, walk, unselected", legs: [
            .unselected("a", "b"), .walk("b", "c"), .unselected("c", "d"),
        ]),
        JourneyCase(name: "boarding at the second visit of a repeated station", legs: [
            .unselected("x", "j"),
            .selected(trip: "tr-1", stops: loopStops, boarding: 3, alighting: 5),
        ]),
        JourneyCase(name: "unselected legs are never counted as duplicates", legs: [
            .selected(trip: "tr-1", stops: ["a", "b"], boarding: 0, alighting: 1),
            .unselected("b", "c"),
            .unselected("c", "b"),
            .unselected("b", "c"),
        ]),
    ]

    @Test(arguments: JourneyTests.validCases)
    func validJourneysAreAcceptedAndDecode(sample: JourneyCase) throws {
        let built = try #require(try Self.journey(sample.legs), "\(sample.name) must be accepted")
        let decoded = try Self.decode(try Self.journeyPayload(sample.legs))

        #expect(built.legs.count == sample.legs.count)
        #expect(Self.endpoints(decoded) == Self.endpoints(built))
    }

    /// A multi-line through service is one selected leg, never two legs and
    /// never a transfer (DEC-009, Rule 16).
    @Test func throughServiceIsOneSelectedLeg() throws {
        let stops = try ["a", "b", "x", "c", "d"].map { try Self.station($0) }
        let first = try #require(LineID("ln-1"))
        let second = try #require(LineID("ln-2"))
        let segments = [
            try #require(TripLineSegment(lineID: first, startIndex: 0, endIndex: 2)),
            try #require(TripLineSegment(lineID: second, startIndex: 2, endIndex: 4)),
        ]
        let throughID = try #require(TripID("tr-through"))
        let through = try #require(
            Trip(
                id: throughID,
                stopSequence: stops,
                lineSegments: segments,
                coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: true),
                serviceTypeSegments: []
            )
        )
        let leg = JourneyLeg.rail(.selected(try #require(SelectedRailTrip(trip: through, boardingIndex: 0, alightingIndex: 4))))
        let subject = try #require(Journey(id: try Self.journeyID(), legs: [leg]))

        #expect(subject.legs.count == 1)
        guard case .rail(.selected(let selection)) = subject.legs[0] else {
            Issue.record("expected one selected rail leg")
            return
        }
        #expect(selection.trip.lineSegments.count == 2)
    }

    // MARK: - Invalid structure

    static let invalidStructureCases: [JourneyCase] = [
        JourneyCase(name: "no legs", legs: []),
        JourneyCase(name: "walk only", legs: [.walk("a", "b")]),
        JourneyCase(name: "starts with a walk", legs: [.walk("a", "b"), .unselected("b", "c")]),
        JourneyCase(name: "ends with a walk", legs: [.unselected("a", "b"), .walk("b", "c")]),
        JourneyCase(name: "consecutive walks", legs: [
            .unselected("a", "b"), .walk("b", "c"), .walk("c", "d"), .unselected("d", "e"),
        ]),
        // continuity, across every kind of neighbour
        JourneyCase(name: "unselected → unselected gap", legs: [.unselected("a", "b"), .unselected("c", "d")]),
        JourneyCase(name: "selected → unselected gap", legs: [
            .selected(trip: "tr-1", stops: ["a", "b"], boarding: 0, alighting: 1), .unselected("c", "d"),
        ]),
        JourneyCase(name: "unselected → selected gap", legs: [
            .unselected("a", "b"), .selected(trip: "tr-1", stops: ["c", "d"], boarding: 0, alighting: 1),
        ]),
        JourneyCase(name: "selected → selected gap", legs: [
            .selected(trip: "tr-1", stops: ["a", "b"], boarding: 0, alighting: 1),
            .selected(trip: "tr-2", stops: ["c", "d"], boarding: 0, alighting: 1),
        ]),
        JourneyCase(name: "rail → walk gap", legs: [.unselected("a", "b"), .walk("c", "d"), .unselected("d", "e")]),
        JourneyCase(name: "walk → rail gap", legs: [.unselected("a", "b"), .walk("b", "c"), .unselected("d", "e")]),
        JourneyCase(name: "reversed legs", legs: [.unselected("b", "c"), .unselected("a", "b")]),
    ]

    @Test(arguments: JourneyTests.invalidStructureCases)
    func invalidStructuresAreRejectedByConstructionAndDecoding(sample: JourneyCase) throws {
        #expect(try Self.journey(sample.legs) == nil, "\(sample.name) must be rejected")
        Self.expectDataCorrupted(try Self.journeyPayload(sample.legs))
    }

    // MARK: - Journey-wide TripID uniqueness (DEC-062 E5)

    /// Directly consecutive duplicates at an equal, lower, and higher join
    /// index. The loop-plus-tail snapshot makes continuity hold at a repeated
    /// station in every case, so only uniqueness can reject them.
    static let directDuplicateCases: [JourneyCase] = [
        JourneyCase(name: "equal index", legs: [
            .selected(trip: "tr-L", stops: loopStops, boarding: 0, alighting: 1),
            .selected(trip: "tr-L", stops: loopStops, boarding: 1, alighting: 2),
        ]),
        JourneyCase(name: "lower index", legs: [
            .selected(trip: "tr-L", stops: loopStops, boarding: 3, alighting: 4),
            .selected(trip: "tr-L", stops: loopStops, boarding: 1, alighting: 2),
        ]),
        JourneyCase(name: "higher index", legs: [
            .selected(trip: "tr-L", stops: loopStops, boarding: 0, alighting: 1),
            .selected(trip: "tr-L", stops: loopStops, boarding: 4, alighting: 5),
        ]),
    ]

    enum Separator: String, Sendable, CaseIterable {
        case walk, unselected, differentTrip
    }

    enum Snapshot: String, Sendable, CaseIterable {
        case identical, inserted, removed
    }

    enum Direction: String, Sendable, CaseIterable {
        case lower, higher
    }

    /// First occurrence alights at `a`, a separator moves from `a` to `b`,
    /// and the second occurrence boards at `b` and alights at the next `j`.
    private static func separatedLegs(
        separator: Separator,
        snapshot: Snapshot,
        direction: Direction,
        secondTripID: String = "tr-L"
    ) -> [LegSpec] {
        let first: LegSpec = switch direction {
        case .higher: .selected(trip: "tr-L", stops: loopStops, boarding: 0, alighting: 1)
        case .lower: .selected(trip: "tr-L", stops: loopStops, boarding: 3, alighting: 4)
        }
        let middle: LegSpec = switch separator {
        case .walk: .walk("a", "b")
        case .unselected: .unselected("a", "b")
        case .differentTrip: .selected(trip: "tr-M", stops: ["a", "b"], boarding: 0, alighting: 1)
        }
        let second: LegSpec = switch snapshot {
        case .identical: .selected(trip: secondTripID, stops: loopStops, boarding: 2, alighting: 3)
        case .inserted: .selected(trip: secondTripID, stops: insertedStops, boarding: 3, alighting: 4)
        case .removed: .selected(trip: secondTripID, stops: removedStops, boarding: 1, alighting: 2)
        }
        return [first, middle, second]
    }

    @Test(arguments: JourneyTests.directDuplicateCases)
    func directDuplicateTripIDsAreRejectedByConstructionAndDecoding(sample: JourneyCase) throws {
        #expect(try Self.journey(sample.legs) == nil, "\(sample.name) must be rejected")
        Self.expectDataCorrupted(try Self.journeyPayload(sample.legs))
    }

    /// The control for the direct cases: the same shapes on a different
    /// TripID are accepted, so only the duplicate is at fault.
    @Test(arguments: JourneyTests.directDuplicateCases)
    func directNeighboursOnDifferentTripIDsAreAccepted(sample: JourneyCase) throws {
        guard case let .selected(_, stops, boarding, alighting) = sample.legs[1] else {
            Issue.record("expected a selected second leg")
            return
        }
        let legs = [sample.legs[0], .selected(trip: "tr-N", stops: stops, boarding: boarding, alighting: alighting)]

        #expect(try Self.journey(legs) != nil)
        #expect(try Self.decode(try Self.journeyPayload(legs)).legs.count == 2)
    }

    @Test(arguments: Separator.allCases, Snapshot.allCases)
    func duplicateTripIDsSeparatedByAnotherLegAreRejected(separator: Separator, snapshot: Snapshot) throws {
        for direction in Direction.allCases {
            let legs = Self.separatedLegs(separator: separator, snapshot: snapshot, direction: direction)

            #expect(
                try Self.journey(legs) == nil,
                "\(separator) / \(snapshot) / \(direction) must be rejected"
            )
            Self.expectDataCorrupted(try Self.journeyPayload(legs))
        }
    }

    /// The control for the separated cases: the same shapes with a different
    /// TripID satisfy every other invariant and are accepted.
    @Test(arguments: Separator.allCases, Snapshot.allCases)
    func separatedLegsOnDifferentTripIDsAreAccepted(separator: Separator, snapshot: Snapshot) throws {
        for direction in Direction.allCases {
            let legs = Self.separatedLegs(separator: separator, snapshot: snapshot, direction: direction, secondTripID: "tr-N")

            #expect(try Self.journey(legs) != nil, "\(separator) / \(snapshot) / \(direction) must be accepted")
            #expect(try Self.decode(try Self.journeyPayload(legs)).legs.count == 3)
        }
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesIDAndEveryLeg() throws {
        let original = try #require(try Self.journey([
            .selected(trip: "tr-1", stops: Self.loopStops, boarding: 3, alighting: 5),
            .walk("t", "u"),
            .unselected("u", "v"),
        ]))
        let decoded = try JSONDecoder().decode(Journey.self, from: try JSONEncoder().encode(original))

        // Identity is ID-only and legs are not Equatable, so every leg is
        // compared through its fields.
        #expect(decoded.id == original.id)
        #expect(Self.endpoints(decoded) == Self.endpoints(original))
        guard
            case .rail(.selected(let selection)) = decoded.legs[0],
            case .walkingTransfer = decoded.legs[1],
            case .rail(.unselected) = decoded.legs[2]
        else {
            Issue.record("a leg changed kind during the round trip")
            return
        }
        #expect(selection.trip.id == (try #require(TripID("tr-1"))))
        #expect(selection.trip.stopSequence == (try Self.trip("tr-1", Self.loopStops)).stopSequence)
        #expect(selection.boardingIndex == 3)
        #expect(selection.alightingIndex == 5)
    }

    /// A regression guard for the encoded shape: stored origin, destination,
    /// current leg, state, or timestamps would appear here (DEC-062).
    @Test func encodedShapeContainsOnlyIDAndLegs() throws {
        let data = try JSONEncoder().encode(try #require(try Self.journey([.unselected("a", "b")])))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(object.keys) == ["id", "legs"])
    }

    @Test(arguments: [#"{"legs":[]}"#, #"{"id":"J-1"}"#])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try Self.decode(payload)
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test func invalidNestedValuesFailAsDataCorrupted() throws {
        let blankID = try Self.journeyPayload(id: #""""#, [.unselected("a", "b")])
        let sameStationLeg = #"{"id":"J-1","legs":[{"kind":"rail","rail":{"kind":"unselected","unselected":{"boardingStationID":"a","alightingStationID":"a"}}}]}"#
        let unknownKind = #"{"id":"J-1","legs":[{"kind":"ferry","ferry":{}}]}"#

        Self.expectDataCorrupted(blankID)
        Self.expectDataCorrupted(sameStationLeg)
        Self.expectDataCorrupted(unknownKind)
    }

    @Test(arguments: [#""J-1""#, "[]", "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try Self.decode(payload)
        }
    }

    // MARK: - Concurrency

    @Test func journeysCrossActorBoundaries() async throws {
        let subject = try #require(try Self.journey([
            .selected(trip: "tr-1", stops: ["a", "b"], boarding: 0, alighting: 1),
            .walk("b", "c"),
            .unselected("c", "d"),
        ]))
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(Self.endpoints(received) == Self.endpoints(subject))
    }
}
