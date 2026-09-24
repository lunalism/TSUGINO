import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the minimal Journey event vocabulary (DEC-063 F).
/// Events are Phase 5 outputs; these tests check only their local rules.
/// An interruption or an ending is a `phaseChanged` event carrying its
/// reason — there is no separate event kind for either.
struct JourneyEventTests {

    private static let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
    private static let earlier = Date(timeIntervalSinceReferenceDate: 900)

    private static func event(_ kind: JourneyEventKind) -> JourneyEvent? {
        JourneyEvent(occurredAt: Self.t0, kind: kind)
    }

    // MARK: - phaseChanged

    @Test func phaseChangeBetweenDifferentPhasesIsValid() throws {
        let subject = try #require(Self.event(.phaseChanged(from: .planning, to: .awaitingDeparture(legIndex: 0))))

        #expect(subject.occurredAt == Self.t0)
        guard case .phaseChanged(let from, let to) = subject.kind else {
            Issue.record("expected a phase change")
            return
        }
        #expect(from == .planning)
        #expect(to == .awaitingDeparture(legIndex: 0))
    }

    @Test(arguments: [
        JourneyPhase.planning,
        .riding(legIndex: 0, position: nil),
        .interrupted(.missedTrain, legIndex: 0),
        .ended(.cancelledByUser),
    ])
    func phaseChangeToTheSamePhaseIsRejected(phase: JourneyPhase) {
        #expect(Self.event(.phaseChanged(from: phase, to: phase)) == nil)
    }

    /// A change only in the payload is still a change.
    @Test func phaseChangeWithinTheSameCaseIsValid() {
        #expect(Self.event(.phaseChanged(from: .awaitingDeparture(legIndex: 0), to: .awaitingDeparture(legIndex: 2))) != nil)
        #expect(Self.event(.phaseChanged(from: .interrupted(.missedTrain, legIndex: 0), to: .interrupted(.wrongTrain, legIndex: 0))) != nil)
    }

    /// An interruption is reported as a phase change carrying its reason.
    @Test func interruptionIsAPhaseChangeCarryingItsReason() throws {
        let subject = try #require(
            Self.event(.phaseChanged(from: .riding(legIndex: 0, position: nil), to: .interrupted(.serviceCancelled, legIndex: 0)))
        )

        guard case .phaseChanged(_, .interrupted(let reason, let legIndex)) = subject.kind else {
            Issue.record("expected a phase change to interrupted")
            return
        }
        #expect(reason == .serviceCancelled)
        #expect(legIndex == 0)
    }

    /// An ending is reported as a phase change carrying its reason.
    @Test func endingIsAPhaseChangeCarryingItsReason() throws {
        let subject = try #require(
            Self.event(.phaseChanged(from: .plannedEndReached(.schedule), to: .ended(.trackingCompleted)))
        )

        guard case .phaseChanged(_, .ended(let reason)) = subject.kind else {
            Issue.record("expected a phase change to ended")
            return
        }
        #expect(reason == .trackingCompleted)
    }

    // MARK: - freshnessChanged

    @Test func freshnessChangeBetweenDifferentValuesIsValid() {
        #expect(Self.event(.freshnessChanged(from: .live(updatedAt: Self.earlier), to: .stale(lastUpdatedAt: Self.earlier))) != nil)
        #expect(Self.event(.freshnessChanged(from: .live(updatedAt: Self.earlier), to: .live(updatedAt: Self.t0))) != nil)
        #expect(Self.event(.freshnessChanged(from: .scheduledOnly, to: .unavailable)) != nil)
    }

    @Test(arguments: [
        RealtimeFreshness.live(updatedAt: earlier), .scheduledOnly, .unavailable, .scheduleFallback(lastRealtimeAt: nil),
    ])
    func freshnessChangeToTheSameValueIsRejected(freshness: RealtimeFreshness) {
        #expect(Self.event(.freshnessChanged(from: freshness, to: freshness)) == nil)
    }

    // MARK: - Leg indices

    @Test(arguments: [-1, Int.min])
    func negativeLegIndicesAreRejected(legIndex: Int) {
        #expect(Self.event(.legStarted(legIndex: legIndex)) == nil)
        #expect(Self.event(.tripSelected(legIndex: legIndex)) == nil)
        #expect(Self.event(.tripReplaced(legIndex: legIndex)) == nil)
    }

    @Test(arguments: [0, 3])
    func nonNegativeLegIndicesAreValid(legIndex: Int) {
        #expect(Self.event(.legStarted(legIndex: legIndex)) != nil)
        #expect(Self.event(.tripSelected(legIndex: legIndex)) != nil)
        #expect(Self.event(.tripReplaced(legIndex: legIndex)) != nil)
    }

    // MARK: - recovered

    @Test func recoveredIsValid() {
        #expect(Self.event(.recovered) != nil)
    }

    // MARK: - Concurrency

    @Test func eventsCrossActorBoundaries() async throws {
        let subject = try #require(Self.event(.tripSelected(legIndex: 1)))
        let received = await Task.detached { subject }.value

        #expect(received.occurredAt == subject.occurredAt)
        guard case .tripSelected(let legIndex) = received.kind else {
            Issue.record("expected a trip selection")
            return
        }
        #expect(legIndex == 1)
    }
}
