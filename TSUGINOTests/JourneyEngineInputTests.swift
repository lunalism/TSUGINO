import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for engine inputs and their ordered structural checks
/// (DEC-064 B, D, E). All identifiers are synthetic and every time is a
/// fixed input.
///
/// The reference Journey is
/// 0: rail, selected, `tr-1` `[a, b, c]`, boarding 0, alighting 2;
/// 1: walk c → d;
/// 2: rail, unselected, d → e;
/// 3: rail, selected, `tr-2` `[e, f, g]`, boarding 0, alighting 2.
struct JourneyEngineInputTests {

    /// A test-only realtime observation, so `observed` can be exercised
    /// without inventing a provider payload.
    struct TestObservation: Sendable {}

    typealias Input = JourneyEngineInput<TestObservation>

    private static let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
    private static let before = Date(timeIntervalSinceReferenceDate: 999)
    private static let after = Date(timeIntervalSinceReferenceDate: 1_060)

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func anchors(_ from: String, _ to: String) throws -> RailLegAnchors {
        let boarding = try Self.station(from)
        let alighting = try Self.station(to)
        return try #require(RailLegAnchors(boardingStationID: boarding, alightingStationID: alighting))
    }

    private static func selection(_ tripID: String, _ stops: [String], _ boarding: Int, _ alighting: Int) throws -> SelectedRailTrip {
        let lineID = try #require(LineID("ln-1"))
        let id = try #require(TripID(tripID))
        let segment = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: stops.count - 1))
        let trip = try #require(
            Trip(
                id: id,
                stopSequence: try stops.map { try Self.station($0) },
                lineSegments: [segment],
                coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: true),
                serviceTypeSegments: []
            )
        )
        return try #require(SelectedRailTrip(trip: trip, boardingIndex: boarding, alightingIndex: alighting))
    }

    private static func journey() throws -> Journey {
        let walk = try #require(WalkingTransfer(fromStationID: try Self.station("c"), toStationID: try Self.station("d")))
        let id = try #require(JourneyID("J-1"))
        return try #require(
            Journey(
                id: id,
                legs: [
                    .rail(.selected(try Self.selection("tr-1", ["a", "b", "c"], 0, 2))),
                    .walkingTransfer(walk),
                    .rail(.unselected(try Self.anchors("d", "e"))),
                    .rail(.selected(try Self.selection("tr-2", ["e", "f", "g"], 0, 2))),
                ]
            )
        )
    }

    private static func active(_ phase: JourneyPhase = .awaitingDeparture(legIndex: 0)) throws -> ActiveJourney {
        let journey = try Self.journey()
        let state = try #require(
            JourneyState(journeyID: journey.id, phase: phase, freshness: .live(updatedAt: Self.t0), lastConfirmedAt: nil, asOf: Self.t0)
        )
        return try ActiveJourney(journey: journey, state: state)
    }

    /// The case name and payload, for exact comparison: the rejection is
    /// deliberately not `Equatable` (DEC-064 G).
    private static func expect(_ input: Input, at now: Date = after, phase: JourneyPhase = .awaitingDeparture(legIndex: 0), rejects expected: JourneyInputRejection?) throws {
        let actual = input.structuralRejection(against: try Self.active(phase), at: now)

        #expect(
            actual.map { String(describing: $0) } == expected.map { String(describing: $0) },
            "expected \(String(describing: expected)), got \(String(describing: actual))"
        )
    }

    /// A valid selection for the unselected leg 2 (d → e).
    private static func fittingSelection(_ tripID: String = "tr-9") throws -> SelectedRailTrip {
        try Self.selection(tripID, ["d", "x", "e"], 0, 2)
    }

    private static func everyInput() throws -> [Input] {
        [
            .observed(TestObservation()),
            .timePassed,
            .selectTrip(legIndex: 2, try Self.fittingSelection()),
            .replaceTrip(legIndex: 0, try Self.selection("tr-1", ["a", "b", "c"], 0, 2)),
            .end(.cancelledByUser),
        ]
    }

    // MARK: - Passing inputs

    @Test func everyValidInputPassesTheStructuralChecks() throws {
        for input in try Self.everyInput() {
            try Self.expect(input, rejects: nil)
        }
    }

    @Test func nowEqualToAsOfIsNotBehind() throws {
        try Self.expect(.timePassed, at: Self.t0, rejects: nil)
    }

    /// A replacement may re-select its own leg's current Trip, for example an
    /// updated snapshot of the same `TripID`.
    @Test func replacingWithTheLegsOwnTripIDPasses() throws {
        try Self.expect(.replaceTrip(legIndex: 0, try Self.selection("tr-1", ["a", "x", "b", "c"], 0, 3)), rejects: nil)
        try Self.expect(.replaceTrip(legIndex: 3, try Self.selection("tr-2", ["e", "g"], 0, 1)), rejects: nil)
    }

    // MARK: - 1. clockBehindJourney

    @Test func backwardClockIsRejectedForEveryInput() throws {
        for input in try Self.everyInput() {
            try Self.expect(input, at: Self.before, rejects: .clockBehindJourney(stateAsOf: Self.t0, requestedAt: Self.before))
        }
    }

    /// The clock is checked before everything else, even on an ended Journey.
    @Test func backwardClockIsReportedBeforeAnEndedJourney() throws {
        try Self.expect(.timePassed, at: Self.before, phase: .ended(.cancelledByUser), rejects: .clockBehindJourney(stateAsOf: Self.t0, requestedAt: Self.before))
    }

    // MARK: - 2. journeyEnded

    @Test(arguments: [JourneyEndReason.trackingCompleted, .cancelledByUser, .endedEarlyByUser])
    func anEndedJourneyRejectsEveryInput(reason: JourneyEndReason) throws {
        for input in try Self.everyInput() {
            try Self.expect(input, phase: .ended(reason), rejects: .journeyEnded)
        }
    }

    // MARK: - 3. legNotFound

    @Test(arguments: [-1, 4, Int.max, Int.min])
    func legIndexOutsideTheJourneyIsNotFound(legIndex: Int) throws {
        try Self.expect(.selectTrip(legIndex: legIndex, try Self.fittingSelection()), rejects: .legNotFound(legIndex: legIndex))
        try Self.expect(.replaceTrip(legIndex: legIndex, try Self.fittingSelection()), rejects: .legNotFound(legIndex: legIndex))
    }

    // MARK: - 4. walkingLegHasNoTrain

    @Test func aWalkingLegHasNoTrain() throws {
        try Self.expect(.selectTrip(legIndex: 1, try Self.fittingSelection()), rejects: .walkingLegHasNoTrain(legIndex: 1))
        try Self.expect(.replaceTrip(legIndex: 1, try Self.fittingSelection()), rejects: .walkingLegHasNoTrain(legIndex: 1))
    }

    // MARK: - 5. selection state

    @Test func selectingForASelectedLegIsAlreadySelected() throws {
        try Self.expect(.selectTrip(legIndex: 0, try Self.selection("tr-1", ["a", "b", "c"], 0, 2)), rejects: .trainAlreadySelected(legIndex: 0))
    }

    @Test func replacingOnAnUnselectedLegHasNothingToReplace() throws {
        try Self.expect(.replaceTrip(legIndex: 2, try Self.fittingSelection()), rejects: .noTrainToReplace(legIndex: 2))
    }

    // MARK: - 6. trainStationsDiffer

    @Test func aTrainWithADifferentAlightingStationDiffers() throws {
        let train = try Self.selection("tr-9", ["d", "x"], 0, 1)

        try Self.expect(
            .selectTrip(legIndex: 2, train),
            rejects: .trainStationsDiffer(legIndex: 2, legStations: try Self.anchors("d", "e"), trainStations: try Self.anchors("d", "x"))
        )
    }

    @Test func aTrainWithADifferentBoardingStationDiffers() throws {
        let train = try Self.selection("tr-9", ["x", "e"], 0, 1)

        try Self.expect(
            .selectTrip(legIndex: 2, train),
            rejects: .trainStationsDiffer(legIndex: 2, legStations: try Self.anchors("d", "e"), trainStations: try Self.anchors("x", "e"))
        )
    }

    /// A replacement is compared with the stations of the leg's current train.
    @Test func aReplacementWithBothStationsDifferentDiffers() throws {
        let train = try Self.selection("tr-9", ["x", "y"], 0, 1)

        try Self.expect(
            .replaceTrip(legIndex: 0, train),
            rejects: .trainStationsDiffer(legIndex: 0, legStations: try Self.anchors("a", "c"), trainStations: try Self.anchors("x", "y"))
        )
    }

    /// The payload keeps both station pairs, so presentation can name the
    /// endpoint that differs.
    @Test func theStationPayloadIdentifiesTheDifferingEndpoint() throws {
        let rejection = try Self.expectRejection(.selectTrip(legIndex: 2, try Self.selection("tr-9", ["d", "x"], 0, 1)))

        guard case .trainStationsDiffer(_, let leg, let train) = rejection else {
            Issue.record("expected trainStationsDiffer, got \(rejection)")
            return
        }
        #expect(leg.boardingStationID == train.boardingStationID, "the boarding station matches")
        #expect(leg.alightingStationID != train.alightingStationID, "the alighting station differs")
    }

    private static func expectRejection(_ input: Input) throws -> JourneyInputRejection {
        try #require(input.structuralRejection(against: try Self.active(), at: Self.after))
    }

    // MARK: - 7. trainAlreadyInJourney

    @Test func selectingATrainUsedOnAnotherLegIsAlreadyInTheJourney() throws {
        try Self.expect(.selectTrip(legIndex: 2, try Self.fittingSelection("tr-1")), rejects: .trainAlreadyInJourney(legIndex: 2, otherLegIndex: 0))
        try Self.expect(.selectTrip(legIndex: 2, try Self.fittingSelection("tr-2")), rejects: .trainAlreadyInJourney(legIndex: 2, otherLegIndex: 3))
    }

    @Test func replacingWithATrainUsedOnAnotherLegIsAlreadyInTheJourney() throws {
        try Self.expect(.replaceTrip(legIndex: 3, try Self.selection("tr-1", ["e", "g"], 0, 1)), rejects: .trainAlreadyInJourney(legIndex: 3, otherLegIndex: 0))
        try Self.expect(.replaceTrip(legIndex: 0, try Self.selection("tr-2", ["a", "c"], 0, 1)), rejects: .trainAlreadyInJourney(legIndex: 0, otherLegIndex: 3))
    }

    // MARK: - Order between checks

    @Test func checksRunInTheDocumentedOrder() throws {
        // walking leg (4) before selection state and stations
        try Self.expect(.replaceTrip(legIndex: 1, try Self.selection("tr-1", ["x", "y"], 0, 1)), rejects: .walkingLegHasNoTrain(legIndex: 1))
        // selection state (5) before stations (6)
        try Self.expect(.selectTrip(legIndex: 0, try Self.selection("tr-9", ["x", "y"], 0, 1)), rejects: .trainAlreadySelected(legIndex: 0))
        // stations (6) before a duplicate TripID (7)
        try Self.expect(
            .selectTrip(legIndex: 2, try Self.selection("tr-1", ["d", "z"], 0, 1)),
            rejects: .trainStationsDiffer(legIndex: 2, legStations: try Self.anchors("d", "e"), trainStations: try Self.anchors("d", "z"))
        )
    }

    // MARK: - UserEndReason

    @Test func userEndReasonsMapToTheirJourneyEndReasons() {
        #expect(UserEndReason.cancelledByUser.journeyEndReason == .cancelledByUser)
        #expect(UserEndReason.endedEarlyByUser.journeyEndReason == .endedEarlyByUser)
    }

    // MARK: - User-facing mapping coverage (DEC-064 E)

    /// Mirrors the DEC-064 E mapping. The switch has no `default`, so adding
    /// a rejection case without deciding its user-facing meaning stops this
    /// test from compiling. Wording is Phase 8.
    private static func mappingRow(_ rejection: JourneyInputRejection) -> String {
        switch rejection {
        case .clockBehindJourney: "device clock behind the journey's last update; check automatic date and time"
        case .journeyEnded: "journey ended; start a new journey"
        case .legNotFound: "that part of the journey no longer exists; reopen the journey"
        case .walkingLegHasNoTrain: "travelled on foot; choose a train for a rail part"
        case .trainAlreadySelected: "a train is already chosen; change it instead"
        case .noTrainToReplace: "no train chosen yet; choose one"
        case .trainStationsDiffer: "the train's boarding and/or alighting station differs; choose a train for the selected stations"
        case .trainAlreadyInJourney: "that train is used for another part; choose a different train"
        case .notAllowedInCurrentPhase: "not possible at the current stage; follow the stage's options or end the journey"
        }
    }

    @Test func everyRejectionHasAUserFacingMappingRow() throws {
        let station = try Self.anchors("a", "b")
        let rejections: [JourneyInputRejection] = [
            .clockBehindJourney(stateAsOf: Self.t0, requestedAt: Self.before),
            .journeyEnded,
            .legNotFound(legIndex: 4),
            .walkingLegHasNoTrain(legIndex: 1),
            .trainAlreadySelected(legIndex: 0),
            .noTrainToReplace(legIndex: 2),
            .trainStationsDiffer(legIndex: 2, legStations: station, trainStations: station),
            .trainAlreadyInJourney(legIndex: 2, otherLegIndex: 0),
            .notAllowedInCurrentPhase(currentPhase: .planning),
        ]

        #expect(Set(rejections.map(Self.mappingRow)).count == rejections.count, "each cause has its own row")
    }
}
