import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for pairing a runtime state with its Journey and the typed
/// `ActiveJourneyInconsistency` error (DEC-063 E, ARCHITECTURE.md §5.6). All
/// identifiers are synthetic. Nothing here asserts transition order or how a
/// phase is reached; those are Phase 5.
///
/// The reference Journey is
/// 0: rail, selected, trip `[a, b, c]`, boarding 0, alighting 2;
/// 1: walk c → d;
/// 2: rail, unselected, d → e;
/// 3: rail, selected, trip `[e, f, g]`, boarding 0, alighting 2.
struct ActiveJourneyTests {

    private static let t0 = Date(timeIntervalSinceReferenceDate: 1_000)

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func selected(_ tripID: String, _ stops: [String], _ boarding: Int, _ alighting: Int) throws -> JourneyLeg {
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
        return .rail(.selected(try #require(SelectedRailTrip(trip: trip, boardingIndex: boarding, alightingIndex: alighting))))
    }

    private static func unselected(_ from: String, _ to: String) throws -> JourneyLeg {
        .rail(.unselected(try #require(RailLegAnchors(boardingStationID: try Self.station(from), alightingStationID: try Self.station(to)))))
    }

    private static func walk(_ from: String, _ to: String) throws -> JourneyLeg {
        .walkingTransfer(try #require(WalkingTransfer(fromStationID: try Self.station(from), toStationID: try Self.station(to))))
    }

    private static func journey(_ legs: [JourneyLeg]) throws -> Journey {
        let id = try #require(JourneyID("J-1"))
        return try #require(Journey(id: id, legs: legs))
    }

    /// The mixed reference Journey described above.
    private static func mixed() throws -> Journey {
        try Self.journey([
            try Self.selected("tr-1", ["a", "b", "c"], 0, 2),
            try Self.walk("c", "d"),
            try Self.unselected("d", "e"),
            try Self.selected("tr-2", ["e", "f", "g"], 0, 2),
        ])
    }

    /// Every leg unselected.
    private static func allUnselected() throws -> Journey {
        try Self.journey([try Self.unselected("a", "b"), try Self.unselected("b", "c")])
    }

    /// One selected leg boarding at index 1 and alighting at index 3, so a
    /// position can fall before boarding or beyond alighting.
    private static func midTrip() throws -> Journey {
        try Self.journey([try Self.selected("tr-1", ["x", "a", "b", "c", "y"], 1, 3)])
    }

    private static func state(_ phase: JourneyPhase, journeyID: String = "J-1") throws -> JourneyState {
        let id = try #require(JourneyID(journeyID))
        return try #require(
            JourneyState(
                journeyID: id,
                phase: phase,
                freshness: .live(updatedAt: Self.t0),
                lastConfirmedAt: nil,
                asOf: Self.t0
            )
        )
    }

    private static func position(_ place: JourneyPosition.Place) throws -> JourneyPosition {
        try #require(JourneyPosition(place: place, basis: .observed))
    }

    /// Pairs and returns the thrown inconsistency, or `nil` when the pair is
    /// valid. The `catch` binding is statically `ActiveJourneyInconsistency`:
    /// typed throws guarantees at compile time that no other error escapes.
    private static func inconsistency(_ journey: Journey, _ phase: JourneyPhase, journeyID: String = "J-1") throws -> ActiveJourneyInconsistency? {
        let state = try Self.state(phase, journeyID: journeyID)
        do {
            _ = try ActiveJourney(journey: journey, state: state)
            return nil
        } catch {
            return error
        }
    }

    /// The error is not `Equatable` (DEC-063 G), so the case and payload are
    /// compared through their description.
    private static func expect(
        _ journey: Journey,
        _ phase: JourneyPhase,
        throws expected: ActiveJourneyInconsistency,
        journeyID: String = "J-1"
    ) throws {
        let actual = try Self.inconsistency(journey, phase, journeyID: journeyID)

        #expect(
            actual.map { String(describing: $0) } == String(describing: expected),
            "\(phase) expected \(expected), got \(String(describing: actual))"
        )
    }

    // MARK: - Valid pairs

    @Test func everyValidPhaseOnTheMixedJourneyPairs() throws {
        let journey = try Self.mixed()
        let phases: [JourneyPhase] = [
            .planning,
            .awaitingDeparture(legIndex: 0),
            .riding(legIndex: 0, position: nil),
            .riding(legIndex: 0, position: try Self.position(.atStop(0))),
            .riding(legIndex: 0, position: try Self.position(.atStop(2))),
            .riding(legIndex: 0, position: try Self.position(.betweenStops(after: 1))),
            .transferring(.walking(legIndex: 1)),
            .awaitingDeparture(legIndex: 2),
            .transferring(.atStation(afterRailLeg: 2)),
            .awaitingDeparture(legIndex: 3),
            .riding(legIndex: 3, position: nil),
            .plannedEndReached(.schedule),
            .plannedEndReached(.trainObservedAtFinalStop),
            .interrupted(.missedTrain, legIndex: 0),
            .interrupted(.wrongDirection, legIndex: 1),
            .interrupted(.serviceSuspended, legIndex: nil),
            .ended(.trackingCompleted),
            .ended(.cancelledByUser),
            .ended(.endedEarlyByUser),
        ]

        for phase in phases {
            #expect(try Self.inconsistency(journey, phase) == nil, "\(phase) must pair")
        }
    }

    @Test func pairPreservesJourneyAndState() throws {
        let journey = try Self.mixed()
        let state = try Self.state(.transferring(.walking(legIndex: 1)))
        let subject = try ActiveJourney(journey: journey, state: state)

        #expect(subject.journey == journey)
        #expect(subject.state.phase == state.phase)
        #expect(subject.state.journeyID == journey.id)
    }

    /// `planning`, the planned endpoint, interruption, and ending impose no
    /// selection requirement, so they pair even with an all-unselected
    /// Journey; so does waiting for a later, unselected leg (DEC-008).
    @Test func phasesWithoutSelectionRequirementsPairWithAnAllUnselectedJourney() throws {
        let journey = try Self.allUnselected()
        let phases: [JourneyPhase] = [
            .planning,
            .awaitingDeparture(legIndex: 1),
            .transferring(.atStation(afterRailLeg: 0)),
            .plannedEndReached(.schedule),
            .interrupted(.invalidPersistedJourney, legIndex: nil),
            .interrupted(.missedTrain, legIndex: 1),
            .ended(.cancelledByUser),
        ]

        for phase in phases {
            #expect(try Self.inconsistency(journey, phase) == nil, "\(phase) must pair")
        }
    }

    @Test func positionsAtTheBoardingAndAlightingBoundsPair() throws {
        let journey = try Self.midTrip()
        let places: [JourneyPosition.Place] = [.atStop(1), .atStop(3), .betweenStops(after: 1), .betweenStops(after: 2)]

        for place in places {
            #expect(try Self.inconsistency(journey, .riding(legIndex: 0, position: try Self.position(place))) == nil)
        }
    }

    // MARK: - journeyMismatch

    @Test func stateForAnotherJourneyIsAMismatch() throws {
        try Self.expect(try Self.mixed(), .planning, throws: .journeyMismatch, journeyID: "J-2")
    }

    /// The mismatch is reported first, before any leg rule.
    @Test func mismatchIsReportedBeforeLegRules() throws {
        try Self.expect(try Self.mixed(), .riding(legIndex: 9, position: nil), throws: .journeyMismatch, journeyID: "J-2")
    }

    // MARK: - legIndexOutOfRange

    @Test(arguments: [
        (JourneyPhase.awaitingDeparture(legIndex: -1), -1),
        (.awaitingDeparture(legIndex: 4), 4),
        (.riding(legIndex: 4, position: nil), 4),
        (.riding(legIndex: Int.max, position: nil), Int.max),
        (.transferring(.walking(legIndex: -1)), -1),
        (.transferring(.walking(legIndex: 4)), 4),
        (.transferring(.atStation(afterRailLeg: -1)), -1),
        (.transferring(.atStation(afterRailLeg: 3)), 4),
        (.transferring(.atStation(afterRailLeg: Int.max)), Int.max),
        (.interrupted(.missedTrain, legIndex: 4), 4),
        (.interrupted(.missedTrain, legIndex: -1), -1),
    ])
    func legIndicesOutsideTheJourneyAreOutOfRange(sample: (JourneyPhase, Int)) throws {
        try Self.expect(try Self.mixed(), sample.0, throws: .legIndexOutOfRange(sample.1))
    }

    // MARK: - legKindMismatch

    @Test(arguments: [
        (JourneyPhase.awaitingDeparture(legIndex: 1), 1),
        (.riding(legIndex: 1, position: nil), 1),
        (.transferring(.walking(legIndex: 0)), 0),
        (.transferring(.walking(legIndex: 2)), 2),
        (.transferring(.atStation(afterRailLeg: 0)), 1),
        (.transferring(.atStation(afterRailLeg: 1)), 1),
    ])
    func phasesOnTheWrongKindOfLegAreKindMismatches(sample: (JourneyPhase, Int)) throws {
        try Self.expect(try Self.mixed(), sample.0, throws: .legKindMismatch(legIndex: sample.1))
    }

    // MARK: - legNotSelected

    @Test func ridingAnUnselectedLegIsNotSelected() throws {
        try Self.expect(try Self.mixed(), .riding(legIndex: 2, position: nil), throws: .legNotSelected(legIndex: 2))
        try Self.expect(try Self.allUnselected(), .riding(legIndex: 0, position: nil), throws: .legNotSelected(legIndex: 0))
    }

    /// First-leg readiness (DEC-007): waiting for the first leg needs its
    /// train selected; waiting for a later leg does not (DEC-008).
    @Test func awaitingAnUnselectedFirstLegIsNotSelected() throws {
        try Self.expect(try Self.allUnselected(), .awaitingDeparture(legIndex: 0), throws: .legNotSelected(legIndex: 0))
        #expect(try Self.inconsistency(try Self.allUnselected(), .awaitingDeparture(legIndex: 1)) == nil)
    }

    // MARK: - positionOutOfRange

    @Test(arguments: [
        JourneyPosition.Place.atStop(0),          // before boarding
        .atStop(4),                               // beyond alighting
        .betweenStops(after: 0),                  // before boarding
        .betweenStops(after: 3),                  // after the alighting stop
        .atStop(Int.max),
    ])
    func positionsOutsideTheSelectionAreOutOfRange(place: JourneyPosition.Place) throws {
        try Self.expect(try Self.midTrip(), .riding(legIndex: 0, position: try Self.position(place)), throws: .positionOutOfRange(legIndex: 0))
    }

    // MARK: - Error type

    /// The construction uses typed throws, so the thrown error is statically
    /// `ActiveJourneyInconsistency`; this also checks it at run time.
    @Test func pairingThrowsOnlyActiveJourneyInconsistency() throws {
        let state = try Self.state(.riding(legIndex: 2, position: nil))

        #expect(throws: ActiveJourneyInconsistency.self) {
            try ActiveJourney(journey: try Self.mixed(), state: state)
        }
    }

    // MARK: - Concurrency

    @Test func pairsCrossActorBoundaries() async throws {
        let subject = try ActiveJourney(journey: try Self.mixed(), state: try Self.state(.awaitingDeparture(legIndex: 0)))
        let received = await Task.detached { subject }.value

        #expect(received.journey == subject.journey)
        #expect(received.state.phase == subject.state.phase)
    }
}
