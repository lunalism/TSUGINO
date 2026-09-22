import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for one recurring canonical scheduled run (DEC-060,
/// ARCHITECTURE.md §5.3).
///
/// Every station, line, and trip identifier here is synthetic; no real Tokyo
/// or Airport Rail record appears. Nothing asserts encoded collection order,
/// topology adjacency, a remaining-stop count, or a display label.
struct TripTests {

    private static func tripID(_ raw: String) throws -> TripID {
        try #require(TripID(raw))
    }

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func stops(_ raws: String...) throws -> [StationID] {
        try raws.map { try Self.station($0) }
    }

    private static func line(_ raw: String) throws -> LineID {
        try #require(LineID(raw))
    }

    private static func segment(_ raw: String, _ start: Int, _ end: Int) throws -> TripLineSegment {
        let lineID = try Self.line(raw)
        return try #require(TripLineSegment(lineID: lineID, startIndex: start, endIndex: end))
    }

    private static let complete = TripCoverage(includesServiceOrigin: true, includesServiceDestination: true)

    /// A valid trip whose fields all default to a simple two-line run.
    private static func trip(
        id: String = "tr-1",
        stops stopSequence: [StationID]? = nil,
        segments: [TripLineSegment]? = nil,
        coverage: TripCoverage = complete
    ) throws -> Trip {
        try #require(
            Trip(
                id: try Self.tripID(id),
                stopSequence: try stopSequence ?? Self.stops("a", "b", "c"),
                lineSegments: try segments ?? [Self.segment("ln-1", 0, 2)],
                coverage: coverage
            )
        )
    }

    // A valid nested payload fragment so each malformed case fails for its
    // intended reason rather than for a missing key.
    private static let validStops = #"["a","b","c"]"#
    private static let validSegments = #"[{"lineID":"ln-1","startIndex":0,"endIndex":2}]"#
    private static let validCoverage = #"{"includesServiceOrigin":true,"includesServiceDestination":true}"#

    private static func payload(
        id: String = #""tr-1""#,
        stops: String = validStops,
        segments: String = validSegments,
        coverage: String = validCoverage
    ) -> String {
        #"{"id":\#(id),"stopSequence":\#(stops),"lineSegments":\#(segments),"coverage":\#(coverage)}"#
    }

    private static func decode(_ payload: String) throws -> Trip {
        try JSONDecoder().decode(Trip.self, from: Data(payload.utf8))
    }

    // MARK: - Construction

    @Test func constructionPreservesEveryField() throws {
        let id = try Self.tripID("tr-1")
        let stops = try Self.stops("a", "b", "c", "d")
        let segments = [try Self.segment("ln-1", 0, 2), try Self.segment("ln-2", 2, 3)]
        let coverage = TripCoverage(includesServiceOrigin: true, includesServiceDestination: false)
        let subject = try #require(
            Trip(id: id, stopSequence: stops, lineSegments: segments, coverage: coverage)
        )

        #expect(subject.id == id)
        #expect(subject.stopSequence == stops)
        #expect(subject.lineSegments == segments)
        #expect(subject.coverage == coverage)
    }

    // MARK: - Identity (ID only)

    @Test func sameIDWithDifferentStructureComparesEqual() throws {
        let a = try Self.trip()
        let corrected = try Self.trip(
            stops: try Self.stops("a", "b", "c", "d"),
            segments: [try Self.segment("ln-1", 0, 3)],
            coverage: TripCoverage(includesServiceOrigin: false, includesServiceDestination: false)
        )

        #expect(a == corrected, "a corrected run is the same Trip")
        #expect(a.stopSequence != corrected.stopSequence, "the traversals really do differ")
        #expect(a.lineSegments != corrected.lineSegments, "the segments really do differ")
        #expect(a.coverage != corrected.coverage, "the coverage really does differ")
    }

    @Test func sameIDHashesIdenticallyAndDeduplicates() throws {
        let a = try Self.trip()
        let corrected = try Self.trip(stops: try Self.stops("a", "x", "c"))

        #expect(a.hashValue == corrected.hashValue)
        #expect(Set([a, corrected]).count == 1)
    }

    /// Two separately published departures are different Trips even when their
    /// structure is identical: identity is never derived from structure.
    @Test func differentIDsWithIdenticalStructureCompareUnequal() throws {
        let morning = try Self.trip(id: "tr-morning")
        let evening = try Self.trip(id: "tr-evening")

        #expect(morning != evening)
        #expect(morning.stopSequence == evening.stopSequence, "the structures really are identical")
        #expect(morning.lineSegments == evening.lineSegments)
        #expect(morning.coverage == evening.coverage)
        #expect(Set([morning, evening]).count == 2)
    }

    @Test func dictionaryKeyingFollowsIdentityNotStructure() throws {
        var table: [Trip: Int] = [:]
        table[try Self.trip()] = 1
        table[try Self.trip(stops: try Self.stops("a", "b", "c", "d"), segments: [try Self.segment("ln-1", 0, 3)])] = 2
        table[try Self.trip(id: "tr-2")] = 3

        #expect(table.count == 2)
        #expect(table[try Self.trip()] == 2, "the second write replaced the first")
    }

    // MARK: - Stop traversal

    @Test func minimalTwoStopTripIsValid() throws {
        let subject = try Self.trip(stops: try Self.stops("a", "b"), segments: [try Self.segment("ln-1", 0, 1)])

        #expect(subject.stopSequence.count == 2)
    }

    @Test(arguments: [0, 1])
    func fewerThanTwoStopsIsRejected(count: Int) throws {
        let stops = try Array(Self.stops("a", "b").prefix(count))

        #expect(
            Trip(
                id: try Self.tripID("tr-1"),
                stopSequence: stops,
                lineSegments: [try Self.segment("ln-1", 0, 1)],
                coverage: Self.complete
            ) == nil
        )
    }

    @Test(arguments: [
        ["a", "a", "b"],
        ["a", "b", "b"],
        ["a", "b", "b", "c"],
    ])
    func adjacentDuplicateStopIsRejected(raws: [String]) throws {
        let stops = try raws.map { try Self.station($0) }

        #expect(
            Trip(
                id: try Self.tripID("tr-1"),
                stopSequence: stops,
                lineSegments: [try Self.segment("ln-1", 0, stops.count - 1)],
                coverage: Self.complete
            ) == nil
        )
    }

    /// Shape 4: a loop-plus-tail run revisits its junction at a non-adjacent
    /// position, which is exactly what the repeat rule exists for.
    @Test func loopPlusTailWithRepeatedStationIsValid() throws {
        let stops = try Self.stops("j", "a", "b", "j", "t1", "t2")
        let subject = try Self.trip(stops: stops, segments: [try Self.segment("ln-1", 0, 5)])

        #expect(subject.stopSequence.count == 6)
        #expect(subject.stopSequence[0] == subject.stopSequence[3], "the junction really does repeat")
        #expect(Set(subject.stopSequence).count == 5, "no whole-sequence uniqueness rule applies")
    }

    /// Shape 3: a circular run returns to where it began.
    @Test func circularTraversalIsValid() throws {
        let stops = try Self.stops("a", "b", "c", "a")
        let subject = try Self.trip(stops: stops, segments: [try Self.segment("ln-1", 0, 3)])

        #expect(subject.stopSequence.first == subject.stopSequence.last)
    }

    /// Shape 2: an express lists only the stations it stops at; the skipped
    /// ones are simply absent, and no topology adjacency is consulted.
    @Test func expressShapedTraversalNeedsNoTopologyAdjacency() throws {
        let subject = try Self.trip(
            stops: try Self.stops("a", "d"),
            segments: [try Self.segment("ln-1", 0, 1)]
        )

        #expect(subject.stopSequence.count == 2)
    }

    /// Shapes 5 and 6: a branch-shaped run and a short-turn are ordinary
    /// traversals; a Trip asserts nothing about a line's full extent.
    @Test(arguments: [["a", "j", "b1", "b2"], ["a", "b", "c"]])
    func branchAndShortTurnShapesAreValid(raws: [String]) throws {
        let stops = try raws.map { try Self.station($0) }
        let subject = try Self.trip(stops: stops, segments: [try Self.segment("ln-1", 0, stops.count - 1)])

        #expect(subject.stopSequence == stops)
    }

    // MARK: - Segment boundaries

    struct SegmentSpan: Sendable {
        let line: String
        let start: Int
        let end: Int
    }

    struct InvalidSegmentCase: Sendable {
        let name: String
        let spans: [SegmentSpan]
    }

    /// Every boundary failure mode over one five-stop traversal `[a,b,c,d,e]`.
    static let invalidSegmentCases: [InvalidSegmentCase] = [
        InvalidSegmentCase(name: "wider overlap", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 3), SegmentSpan(line: "ln-2", start: 2, end: 4),
        ]),
        InvalidSegmentCase(name: "gap", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 1), SegmentSpan(line: "ln-2", start: 2, end: 4),
        ]),
        InvalidSegmentCase(name: "nested range", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 4), SegmentSpan(line: "ln-2", start: 1, end: 3),
        ]),
        InvalidSegmentCase(name: "duplicate range", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 4), SegmentSpan(line: "ln-2", start: 0, end: 4),
        ]),
        InvalidSegmentCase(name: "non-progressing chain", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 2), SegmentSpan(line: "ln-2", start: 2, end: 3),
            SegmentSpan(line: "ln-3", start: 2, end: 4),
        ]),
        InvalidSegmentCase(name: "adjacent same line", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 2), SegmentSpan(line: "ln-1", start: 2, end: 4),
        ]),
        InvalidSegmentCase(name: "end beyond the traversal", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 7),
        ]),
        InvalidSegmentCase(name: "first segment not at zero", spans: [
            SegmentSpan(line: "ln-1", start: 1, end: 4),
        ]),
        InvalidSegmentCase(name: "final segment short of the end", spans: [
            SegmentSpan(line: "ln-1", start: 0, end: 3),
        ]),
        InvalidSegmentCase(name: "reversed order", spans: [
            SegmentSpan(line: "ln-1", start: 2, end: 4), SegmentSpan(line: "ln-2", start: 0, end: 2),
        ]),
    ]

    /// Shape 7.
    @Test func oneLineTripUsesOneCoveringSegment() throws {
        let subject = try Self.trip()

        #expect(subject.lineSegments.count == 1)
        #expect(subject.lineSegments[0].startIndex == 0)
        #expect(subject.lineSegments[0].endIndex == subject.stopSequence.count - 1)
    }

    /// Shapes 8 and 9: one traversal, two lines, meeting at a single shared
    /// boundary index — one Trip, no transfer.
    @Test func twoLineThroughServiceSharesOneBoundaryIndex() throws {
        let subject = try Self.trip(
            stops: try Self.stops("a", "b", "x", "c", "d"),
            segments: [try Self.segment("ln-1", 0, 2), try Self.segment("ln-2", 2, 4)]
        )

        #expect(subject.lineSegments.count == 2)
        #expect(subject.lineSegments[0].endIndex == subject.lineSegments[1].startIndex)
        #expect(subject.stopSequence[2] == (try Self.station("x")), "the boundary station belongs to both")
    }

    @Test func threeLineThroughServiceIsValid() throws {
        let subject = try Self.trip(
            stops: try Self.stops("a", "b", "c", "d"),
            segments: [
                try Self.segment("ln-1", 0, 1),
                try Self.segment("ln-2", 1, 2),
                try Self.segment("ln-3", 2, 3),
            ]
        )

        #expect(subject.lineSegments.count == 3)
    }

    /// A run may leave a line and return to it later.
    @Test func nonAdjacentReuseOfALineIsValid() throws {
        let subject = try Self.trip(
            stops: try Self.stops("a", "b", "c", "d"),
            segments: [
                try Self.segment("ln-1", 0, 1),
                try Self.segment("ln-2", 1, 2),
                try Self.segment("ln-1", 2, 3),
            ]
        )

        #expect(subject.lineSegments[0].lineID == subject.lineSegments[2].lineID)
    }

    @Test func emptySegmentListIsRejected() throws {
        #expect(
            Trip(
                id: try Self.tripID("tr-1"),
                stopSequence: try Self.stops("a", "b"),
                lineSegments: [],
                coverage: Self.complete
            ) == nil
        )
    }

    /// Every boundary failure mode over one five-stop traversal `[a,b,c,d,e]`.
    @Test(arguments: TripTests.invalidSegmentCases)
    func invalidSegmentListsAreRejected(sample: InvalidSegmentCase) throws {
        let segments = try sample.spans.map { try Self.segment($0.line, $0.start, $0.end) }

        #expect(
            Trip(
                id: try Self.tripID("tr-1"),
                stopSequence: try Self.stops("a", "b", "c", "d", "e"),
                lineSegments: segments,
                coverage: Self.complete
            ) == nil,
            "\(sample.name) must be rejected"
        )
    }

    // MARK: - Coverage

    /// Shapes 10–12, and the distinction the coverage value exists for: a
    /// genuine short-turn ending at `c` and a partial representation ending at
    /// the same `c` are different states, though their traversals match.
    @Test func shortTurnAndTrailingPartialShareATraversalButNotCoverage() throws {
        let stops = try Self.stops("a", "b", "c")
        let shortTurn = try Self.trip(stops: stops, coverage: Self.complete)
        let trailingPartial = try Self.trip(
            stops: stops,
            coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: false)
        )

        #expect(shortTurn.stopSequence == trailingPartial.stopSequence)
        #expect(shortTurn.coverage.includesServiceDestination == true)
        #expect(trailingPartial.coverage.includesServiceDestination == false)
        #expect(shortTurn.coverage != trailingPartial.coverage)
    }

    @Test(arguments: [(true, false), (false, true), (false, false)])
    func partialCoverageStatesAreValidTrips(sample: (Bool, Bool)) throws {
        let subject = try Self.trip(
            coverage: TripCoverage(
                includesServiceOrigin: sample.0,
                includesServiceDestination: sample.1
            )
        )

        #expect(subject.coverage.includesServiceOrigin == sample.0)
        #expect(subject.coverage.includesServiceDestination == sample.1)
        #expect(subject.stopSequence.count >= 2, "a partial Trip still needs two represented stops")
        #expect(subject.lineSegments.isEmpty == false)
    }

    @Test func coverageDoesNotParticipateInIdentity() throws {
        let complete = try Self.trip(coverage: Self.complete)
        let middleOnly = try Self.trip(
            coverage: TripCoverage(includesServiceOrigin: false, includesServiceDestination: false)
        )

        #expect(complete == middleOnly)
        #expect(complete.coverage != middleOnly.coverage)
    }

    /// Coverage relaxes nothing: a partial Trip must still satisfy every
    /// traversal and segment rule.
    @Test func partialCoverageDoesNotRelaxOtherInvariants() throws {
        let partial = TripCoverage(includesServiceOrigin: false, includesServiceDestination: false)

        #expect(
            Trip(
                id: try Self.tripID("tr-1"),
                stopSequence: try Self.stops("a"),
                lineSegments: [try Self.segment("ln-1", 0, 1)],
                coverage: partial
            ) == nil
        )
        #expect(
            Trip(
                id: try Self.tripID("tr-1"),
                stopSequence: try Self.stops("a", "b", "c"),
                lineSegments: [try Self.segment("ln-1", 0, 1)],
                coverage: partial
            ) == nil
        )
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = try Self.trip(
            stops: try Self.stops("j", "a", "b", "j", "t"),
            segments: [try Self.segment("ln-1", 0, 3), try Self.segment("ln-2", 3, 4)],
            coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: false)
        )
        let decoded = try JSONDecoder().decode(
            Trip.self,
            from: try JSONEncoder().encode(original)
        )

        // Equality is ID-only, so every structural field is compared
        // explicitly: `decoded == original` alone would pass even if the
        // traversal, segments, or coverage had been lost.
        #expect(decoded.id == original.id)
        #expect(decoded.stopSequence == original.stopSequence)
        #expect(decoded.lineSegments == original.lineSegments)
        #expect(decoded.coverage == original.coverage)
    }

    /// A regression guard for the encoded stored fields, not a general proof
    /// that `Trip` has no other stored properties. It would catch a provider
    /// reference, schedule, direction, destination, or service type added as a
    /// `Codable` member, which is the realistic way DEC-060 F–H would be
    /// broken; a non-`Codable` member would slip past it.
    @Test func encodedShapeContainsOnlyTheFourFields() throws {
        let data = try JSONEncoder().encode(try Self.trip())
        let object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(Set(object.keys) == ["id", "stopSequence", "lineSegments", "coverage"])
    }

    @Test(arguments: [
        #"{"stopSequence":["a","b","c"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true}}"#,
        #"{"id":"tr-1","lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true}}"#,
        #"{"id":"tr-1","stopSequence":["a","b","c"],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true}}"#,
        #"{"id":"tr-1","stopSequence":["a","b","c"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}]}"#,
    ])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Trip.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"id":1,"stopSequence":["a","b","c"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true}}"#,
        #"{"id":"tr-1","stopSequence":"a","lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true}}"#,
        #"{"id":"tr-1","stopSequence":["a","b","c"],"lineSegments":{"lineID":"ln-1"},"coverage":{"includesServiceOrigin":true,"includesServiceDestination":true}}"#,
        #"{"id":"tr-1","stopSequence":["a","b","c"],"lineSegments":[{"lineID":"ln-1","startIndex":0,"endIndex":2}],"coverage":true}"#,
    ])
    func wrongTypesFailAsTypeMismatch(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Trip.self, from: Data(payload.utf8))
        }

        guard case .typeMismatch? = error else {
            Issue.record("expected .typeMismatch, got \(String(describing: error))")
            return
        }
    }

    /// Every Trip-level invariant, and every nested one, fails as
    /// `dataCorrupted` — the Trip decoder adds nothing of its own.
    @Test(arguments: [
        // stop traversal
        Self.payload(stops: #"[]"#),
        Self.payload(stops: #"["a"]"#),
        Self.payload(stops: #"["a","a","c"]"#),
        Self.payload(stops: #"["a",""]"#),
        // segment list
        Self.payload(segments: #"[]"#),
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":1,"endIndex":2}]"#),
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":0,"endIndex":1}]"#),
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":0,"endIndex":9}]"#),
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":0,"endIndex":1},{"lineID":"ln-2","startIndex":0,"endIndex":2}]"#),
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":0,"endIndex":1},{"lineID":"ln-1","startIndex":1,"endIndex":2}]"#),
        // nested segment invariant
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":-1,"endIndex":2}]"#),
        Self.payload(segments: #"[{"lineID":"ln-1","startIndex":2,"endIndex":2}]"#),
        Self.payload(segments: #"[{"lineID":"","startIndex":0,"endIndex":2}]"#),
        // nested identifier
        Self.payload(id: #""""#),
    ])
    func invalidStructuresFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Trip.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    /// Extreme decoded indices are rejected without trapping.
    @Test(arguments: [
        #"[{"lineID":"ln-1","startIndex":0,"endIndex":9223372036854775807}]"#,
        #"[{"lineID":"ln-1","startIndex":-9223372036854775808,"endIndex":2}]"#,
    ])
    func extremeDecodedIndicesAreRejectedSafely(segments: String) {
        #expect(throws: DecodingError.self) {
            try Self.decode(Self.payload(segments: segments))
        }
    }

    @Test(arguments: [#""tr-1""#, "[]", "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Trip.self, from: Data(payload.utf8))
        }
    }

    @Test func validMultiLinePayloadDecodes() throws {
        let decoded = try Self.decode(
            Self.payload(
                stops: #"["a","b","x","c"]"#,
                segments: #"[{"lineID":"ln-1","startIndex":0,"endIndex":2},{"lineID":"ln-2","startIndex":2,"endIndex":3}]"#
            )
        )

        #expect(decoded.stopSequence.count == 4)
        #expect(decoded.lineSegments.count == 2)
        #expect(decoded.lineSegments[0].endIndex == decoded.lineSegments[1].startIndex)
    }

    // MARK: - Concurrency

    @Test func tripsCrossActorBoundaries() async throws {
        let subject = try Self.trip(
            stops: try Self.stops("a", "b", "x", "c"),
            segments: [try Self.segment("ln-1", 0, 2), try Self.segment("ln-2", 2, 3)],
            coverage: TripCoverage(includesServiceOrigin: false, includesServiceDestination: true)
        )
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.stopSequence == subject.stopSequence)
        #expect(received.lineSegments == subject.lineSegments)
        #expect(received.coverage == subject.coverage)
    }
}
