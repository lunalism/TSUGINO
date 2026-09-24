import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the `JourneyEngine` protocol boundary (DEC-064 B, C).
///
/// `ScheduledOnlyTestEngine` is **test-only**. It binds `Observation = Never`,
/// applies the shared structural checks, and otherwise returns a no-change
/// result at `now`. It implements no transition and is not production
/// behaviour; the real engine is Phase 5.
struct JourneyEngineTests {

    struct ScheduledOnlyTestEngine: JourneyEngine {
        typealias Observation = Never

        func transition(from current: ActiveJourney, input: JourneyEngineInput<Never>, at now: Date) -> JourneyTransitionOutcome {
            if let rejection = input.structuralRejection(against: current, at: now) {
                return .rejected(rejection)
            }
            guard
                let state = JourneyState(
                    journeyID: current.state.journeyID,
                    phase: current.state.phase,
                    freshness: current.state.freshness,
                    lastConfirmedAt: current.state.lastConfirmedAt,
                    asOf: now
                ),
                let next = try? ActiveJourney(journey: current.journey, state: state),
                let result = JourneyTransitionResult(previous: current, next: next, events: [], recoveryProposal: nil)
            else {
                // Unreachable for this double; a real engine's inability to
                // build a result is a Phase 5 defect, never a silent no-change.
                return .rejected(.notAllowedInCurrentPhase(currentPhase: current.state.phase))
            }
            return .applied(result)
        }
    }

    private static let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
    private static let t1 = Date(timeIntervalSinceReferenceDate: 1_060)

    private static func station(_ raw: String) throws -> StationID {
        try #require(StationID(raw))
    }

    private static func active(_ phase: JourneyPhase) throws -> ActiveJourney {
        let walk = try #require(WalkingTransfer(fromStationID: try Self.station("b"), toStationID: try Self.station("c")))
        let first = try #require(RailLegAnchors(boardingStationID: try Self.station("a"), alightingStationID: try Self.station("b")))
        let last = try #require(RailLegAnchors(boardingStationID: try Self.station("c"), alightingStationID: try Self.station("d")))
        let id = try #require(JourneyID("J-1"))
        let journey = try #require(Journey(id: id, legs: [.rail(.unselected(first)), .walkingTransfer(walk), .rail(.unselected(last))]))
        let state = try #require(
            JourneyState(journeyID: journey.id, phase: phase, freshness: .scheduledOnly, lastConfirmedAt: nil, asOf: Self.t0)
        )
        return try ActiveJourney(journey: journey, state: state)
    }

    private static func selection() throws -> SelectedRailTrip {
        let lineID = try #require(LineID("ln-1"))
        let tripID = try #require(TripID("tr-1"))
        let segment = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: 1))
        let trip = try #require(
            Trip(
                id: tripID,
                stopSequence: [try Self.station("b"), try Self.station("c")],
                lineSegments: [segment],
                coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: true),
                serviceTypeSegments: []
            )
        )
        return try #require(SelectedRailTrip(trip: trip, boardingIndex: 0, alightingIndex: 1))
    }

    /// Used through the protocol, as a caller holding any engine would.
    private static let engine: any JourneyEngine<Never> = ScheduledOnlyTestEngine()

    // MARK: - Applied no-change

    @Test func timePassedWithNothingChangingIsAppliedWithAsOfAtNow() throws {
        let current = try Self.active(.planning)

        guard case .applied(let result) = Self.engine.transition(from: current, input: .timePassed, at: Self.t1) else {
            Issue.record("expected an applied result")
            return
        }
        #expect(result.next.journey == current.journey, "the Journey is unchanged")
        #expect(result.next.state.phase == current.state.phase, "the phase is unchanged")
        #expect(result.next.state.asOf == Self.t1, "asOf advances to the supplied now")
        #expect(result.previous.state.asOf == Self.t0)
        #expect(result.events.isEmpty)
    }

    // MARK: - Rejections are distinguishable from no change

    @Test func aStructuralFailureIsRejectedNotApplied() throws {
        let outcome = Self.engine.transition(from: try Self.active(.planning), input: .selectTrip(legIndex: 1, try Self.selection()), at: Self.t1)

        guard case .rejected(.walkingLegHasNoTrain(let legIndex)) = outcome else {
            Issue.record("expected walkingLegHasNoTrain, got \(outcome)")
            return
        }
        #expect(legIndex == 1)
    }

    @Test func aBackwardClockIsRejectedNotClamped() throws {
        let outcome = Self.engine.transition(from: try Self.active(.planning), input: .timePassed, at: Date(timeIntervalSinceReferenceDate: 999))

        guard case .rejected(.clockBehindJourney(let stateAsOf, let requestedAt)) = outcome else {
            Issue.record("expected clockBehindJourney, got \(outcome)")
            return
        }
        #expect(stateAsOf == Self.t0)
        #expect(requestedAt == Date(timeIntervalSinceReferenceDate: 999))
    }

    @Test func anEndedJourneyRejectsTimePassing() throws {
        let outcome = Self.engine.transition(from: try Self.active(.ended(.trackingCompleted)), input: .timePassed, at: Self.t1)

        guard case .rejected(.journeyEnded) = outcome else {
            Issue.record("expected journeyEnded, got \(outcome)")
            return
        }
    }

    // MARK: - Concurrency

    /// The protocol is `Sendable`, so an engine can run off the main actor
    /// (DEC-027).
    @Test func theEngineRunsAcrossActorBoundaries() async throws {
        let engine = Self.engine
        let current = try Self.active(.planning)
        let outcome = await Task.detached { engine.transition(from: current, input: .end(.endedEarlyByUser), at: Self.t1) }.value

        guard case .applied(let result) = outcome else {
            Issue.record("expected an applied result")
            return
        }
        #expect(result.next.state.asOf == Self.t1)
    }
}
