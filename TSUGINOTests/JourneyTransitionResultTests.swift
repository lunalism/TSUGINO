import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for applied transition results and recovery proposals
/// (DEC-064 C, F). All identifiers are synthetic and every time is a fixed
/// input. Nothing here asserts how a transition is reached.
///
/// The reference Journey is
/// 0: rail, selected, `tr-1` `[a, b, c]`, boarding 0, alighting 2;
/// 1: walk c → d;
/// 2: rail, unselected, d → e.
struct JourneyTransitionResultTests {

    private static let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
    private static let t1 = Date(timeIntervalSinceReferenceDate: 1_060)

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func journey(_ id: String = "J-1") throws -> Journey {
        let lineID = try #require(LineID("ln-1"))
        let tripID = try #require(TripID("tr-1"))
        let segment = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: 2))
        let trip = try #require(
            Trip(
                id: tripID,
                stopSequence: try ["a", "b", "c"].map { try Self.station($0) },
                lineSegments: [segment],
                coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: true),
                serviceTypeSegments: []
            )
        )
        let selection = try #require(SelectedRailTrip(trip: trip, boardingIndex: 0, alightingIndex: 2))
        let walk = try #require(WalkingTransfer(fromStationID: try Self.station("c"), toStationID: try Self.station("d")))
        let anchors = try #require(RailLegAnchors(boardingStationID: try Self.station("d"), alightingStationID: try Self.station("e")))
        let journeyID = try #require(JourneyID(id))
        return try #require(
            Journey(id: journeyID, legs: [.rail(.selected(selection)), .walkingTransfer(walk), .rail(.unselected(anchors))])
        )
    }

    private static func active(_ phase: JourneyPhase, asOf: Date, journeyID: String = "J-1") throws -> ActiveJourney {
        let journey = try Self.journey(journeyID)
        let state = try #require(
            JourneyState(journeyID: journey.id, phase: phase, freshness: .scheduledOnly, lastConfirmedAt: nil, asOf: asOf)
        )
        return try ActiveJourney(journey: journey, state: state)
    }

    private static func event(at date: Date) throws -> JourneyEvent {
        try #require(JourneyEvent(occurredAt: date, kind: .tripSelected(legIndex: 2)))
    }

    private static func proposal(_ reason: JourneyInterruptionReason, _ legs: [Int]) throws -> JourneyRecoveryProposal {
        try #require(JourneyRecoveryProposal(reason: reason, reselectableLegIndices: legs))
    }

    private static let riding = JourneyPhase.riding(legIndex: 0, position: nil)
    private static let missed = JourneyPhase.interrupted(.missedTrain, legIndex: 0)

    // MARK: - Valid results

    /// A no-change result: the Journey and phase are the same, and `asOf`
    /// advances.
    @Test func noChangeResultWithAdvancedAsOfIsValid() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.riding, asOf: Self.t1)
        let subject = try #require(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: nil))

        #expect(subject.next.journey == subject.previous.journey)
        #expect(subject.next.state.phase == subject.previous.state.phase)
        #expect(subject.next.state.asOf == Self.t1)
        #expect(subject.events.isEmpty)
        #expect(subject.recoveryProposal == nil)
    }

    @Test func equalAsOfIsValid() throws {
        let pair = try Self.active(Self.riding, asOf: Self.t0)

        #expect(JourneyTransitionResult(previous: pair, next: pair, events: [], recoveryProposal: nil) != nil)
    }

    @Test func eventsAtBothEndsOfTheWindowAreValid() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.riding, asOf: Self.t1)
        let events = [try Self.event(at: Self.t0), try Self.event(at: Self.t1)]

        #expect(JourneyTransitionResult(previous: previous, next: next, events: events, recoveryProposal: nil) != nil)
    }

    @Test func interruptionWithAMatchingProposalIsValid() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.missed, asOf: Self.t1)
        let subject = try #require(
            JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: try Self.proposal(.missedTrain, [0, 2]))
        )

        #expect(subject.recoveryProposal?.reselectableLegIndices == [0, 2])
    }

    @Test func interruptionWithoutAProposalIsValid() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.missed, asOf: Self.t1)

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: nil) != nil)
    }

    // MARK: - Rejected results

    @Test func aDifferentJourneyIsRejected() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.riding, asOf: Self.t1, journeyID: "J-2")

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: nil) == nil)
    }

    @Test func backwardAsOfIsRejected() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t1)
        let next = try Self.active(Self.riding, asOf: Self.t0)

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: nil) == nil)
    }

    @Test(arguments: [
        Date(timeIntervalSinceReferenceDate: 999),
        Date(timeIntervalSinceReferenceDate: 1_061),
    ])
    func eventsOutsideTheWindowAreRejected(date: Date) throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.riding, asOf: Self.t1)

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [try Self.event(at: date)], recoveryProposal: nil) == nil)
    }

    @Test func aProposalWithoutAnInterruptionIsRejected() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.riding, asOf: Self.t1)

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: try Self.proposal(.missedTrain, [0])) == nil)
    }

    @Test func aProposalWithADifferentReasonIsRejected() throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.missed, asOf: Self.t1)

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: try Self.proposal(.serviceCancelled, [0])) == nil)
    }

    @Test(arguments: [[1], [0, 1], [3], [0, 9]])
    func proposalLegsThatAreNotRailOrNotInTheJourneyAreRejected(legs: [Int]) throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.missed, asOf: Self.t1)

        #expect(JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: try Self.proposal(.missedTrain, legs)) == nil)
    }

    // MARK: - JourneyRecoveryProposal

    @Test func proposalPreservesReasonAndLegs() throws {
        let subject = try Self.proposal(.serviceCancelled, [0, 2, 5])

        #expect(subject.reason == .serviceCancelled)
        #expect(subject.reselectableLegIndices == [0, 2, 5])
    }

    @Test(arguments: [[Int](), [-1], [2, 0], [0, 0], [0, 2, 2], [1, 3, 2]])
    func emptyNegativeUnsortedOrDuplicateLegsAreRejected(legs: [Int]) {
        #expect(JourneyRecoveryProposal(reason: .missedTrain, reselectableLegIndices: legs) == nil)
    }

    // MARK: - Concurrency

    @Test func resultsCrossActorBoundaries() async throws {
        let previous = try Self.active(Self.riding, asOf: Self.t0)
        let next = try Self.active(Self.missed, asOf: Self.t1)
        let subject = try #require(
            JourneyTransitionResult(previous: previous, next: next, events: [], recoveryProposal: try Self.proposal(.missedTrain, [0]))
        )
        let received = await Task.detached { subject }.value

        #expect(received.next.state.phase == Self.missed)
        #expect(received.recoveryProposal?.reselectableLegIndices == [0])
    }
}
