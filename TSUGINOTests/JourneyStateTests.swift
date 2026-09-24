import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the value-only runtime-state rules: positions,
/// freshness, and `JourneyState` timestamp and observation consistency
/// (DEC-063 C, D; ARCHITECTURE.md §5.6). All identifiers are synthetic and
/// every time is a fixed input; nothing reads a clock.
struct JourneyStateTests {

    private static let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
    private static let earlier = Date(timeIntervalSinceReferenceDate: 900)
    private static let later = Date(timeIntervalSinceReferenceDate: 1_100)

    private static func journeyID() throws -> JourneyID {
        try #require(JourneyID("J-1"))
    }

    private static func position(_ place: JourneyPosition.Place, _ basis: JourneyPosition.Basis) throws -> JourneyPosition {
        try #require(JourneyPosition(place: place, basis: basis))
    }

    private static func state(
        _ phase: JourneyPhase,
        freshness: RealtimeFreshness = .scheduledOnly,
        lastConfirmedAt: Date? = nil,
        asOf: Date = t0
    ) throws -> JourneyState? {
        JourneyState(
            journeyID: try Self.journeyID(),
            phase: phase,
            freshness: freshness,
            lastConfirmedAt: lastConfirmedAt,
            asOf: asOf
        )
    }

    static let realtimeFreshness: [RealtimeFreshness] = [
        .live(updatedAt: earlier), .delayedUpdate(lastUpdatedAt: earlier), .stale(lastUpdatedAt: earlier),
    ]

    static let nonRealtimeFreshness: [RealtimeFreshness] = [
        .scheduleFallback(lastRealtimeAt: earlier), .scheduleFallback(lastRealtimeAt: nil), .scheduledOnly, .unavailable,
    ]

    // MARK: - JourneyPosition

    @Test func positionPreservesPlaceAndBasis() throws {
        let subject = try Self.position(.betweenStops(after: 2), .observed)

        #expect(subject.place == .betweenStops(after: 2))
        #expect(subject.basis == .observed)
    }

    @Test(arguments: [JourneyPosition.Place.atStop(-1), .betweenStops(after: -1), .atStop(Int.min)])
    func negativePositionIndexIsRejected(place: JourneyPosition.Place) {
        #expect(JourneyPosition(place: place, basis: .scheduleEstimate) == nil)
    }

    @Test func zeroIndexIsValid() {
        #expect(JourneyPosition(place: .atStop(0), basis: .scheduleEstimate) != nil)
        #expect(JourneyPosition(place: .betweenStops(after: 0), basis: .observed) != nil)
    }

    @Test func positionEqualityUsesPlaceAndBasis() throws {
        let observed = try Self.position(.atStop(1), .observed)

        #expect(observed == (try Self.position(.atStop(1), .observed)))
        #expect(observed != (try Self.position(.atStop(1), .scheduleEstimate)))
        #expect(observed != (try Self.position(.betweenStops(after: 1), .observed)))
    }

    // MARK: - RealtimeFreshness

    @Test(arguments: JourneyStateTests.realtimeFreshness)
    func realtimeFreshnessIsRealtimeDerived(freshness: RealtimeFreshness) {
        #expect(freshness.isRealtimeDerived)
        #expect(freshness.timestamp == Self.earlier)
    }

    @Test(arguments: JourneyStateTests.nonRealtimeFreshness)
    func scheduleAndUnavailableFreshnessAreNotRealtimeDerived(freshness: RealtimeFreshness) {
        #expect(!freshness.isRealtimeDerived)
    }

    @Test func freshnessTimestampsAreReportedOnlyWhereCarried() {
        #expect(RealtimeFreshness.scheduleFallback(lastRealtimeAt: Self.earlier).timestamp == Self.earlier)
        #expect(RealtimeFreshness.scheduleFallback(lastRealtimeAt: nil).timestamp == nil)
        #expect(RealtimeFreshness.scheduledOnly.timestamp == nil)
        #expect(RealtimeFreshness.unavailable.timestamp == nil)
    }

    // MARK: - JourneyState: construction

    @Test func constructionPreservesEveryField() throws {
        let phase = JourneyPhase.riding(legIndex: 0, position: try Self.position(.atStop(1), .observed))
        let subject = try #require(
            try Self.state(phase, freshness: .live(updatedAt: Self.earlier), lastConfirmedAt: Self.earlier)
        )

        #expect(subject.journeyID == (try Self.journeyID()))
        #expect(subject.phase == phase)
        #expect(subject.freshness == .live(updatedAt: Self.earlier))
        #expect(subject.lastConfirmedAt == Self.earlier)
        #expect(subject.asOf == Self.t0)
    }

    // MARK: - JourneyState: timestamps (DEC-063 D1, D2)

    @Test func lastConfirmedAtAfterAsOfIsRejected() throws {
        #expect(try Self.state(.planning, lastConfirmedAt: Self.later) == nil)
    }

    @Test func lastConfirmedAtAtOrBeforeAsOfIsAccepted() throws {
        #expect(try Self.state(.planning, lastConfirmedAt: Self.t0) != nil)
        #expect(try Self.state(.planning, lastConfirmedAt: Self.earlier) != nil)
    }

    @Test(arguments: [
        RealtimeFreshness.live(updatedAt: later), .delayedUpdate(lastUpdatedAt: later),
        .stale(lastUpdatedAt: later), .scheduleFallback(lastRealtimeAt: later),
    ])
    func freshnessTimestampAfterAsOfIsRejected(freshness: RealtimeFreshness) throws {
        #expect(try Self.state(.planning, freshness: freshness) == nil)
    }

    @Test func freshnessTimestampEqualToAsOfIsAccepted() throws {
        #expect(try Self.state(.planning, freshness: .live(updatedAt: Self.t0)) != nil)
    }

    // MARK: - JourneyState: honest bases (DEC-063 D3, D4)

    @Test(arguments: JourneyStateTests.nonRealtimeFreshness)
    func observedPositionWithoutRealtimeIsRejected(freshness: RealtimeFreshness) throws {
        let phase = JourneyPhase.riding(legIndex: 0, position: try Self.position(.atStop(0), .observed))

        #expect(try Self.state(phase, freshness: freshness) == nil)
    }

    @Test(arguments: JourneyStateTests.realtimeFreshness)
    func observedPositionWithRealtimeIsAccepted(freshness: RealtimeFreshness) throws {
        let phase = JourneyPhase.riding(legIndex: 0, position: try Self.position(.atStop(0), .observed))

        #expect(try Self.state(phase, freshness: freshness) != nil)
    }

    @Test(arguments: JourneyStateTests.realtimeFreshness + JourneyStateTests.nonRealtimeFreshness)
    func scheduleEstimatedPositionIsAcceptedWithAnyFreshness(freshness: RealtimeFreshness) throws {
        let phase = JourneyPhase.riding(legIndex: 0, position: try Self.position(.betweenStops(after: 0), .scheduleEstimate))

        #expect(try Self.state(phase, freshness: freshness) != nil)
    }

    @Test(arguments: JourneyStateTests.realtimeFreshness + JourneyStateTests.nonRealtimeFreshness)
    func ridingWithoutPositionIsAcceptedWithAnyFreshness(freshness: RealtimeFreshness) throws {
        #expect(try Self.state(.riding(legIndex: 0, position: nil), freshness: freshness) != nil)
    }

    @Test(arguments: JourneyStateTests.nonRealtimeFreshness)
    func trainObservedEndpointWithoutRealtimeIsRejected(freshness: RealtimeFreshness) throws {
        #expect(try Self.state(.plannedEndReached(.trainObservedAtFinalStop), freshness: freshness) == nil)
    }

    @Test(arguments: JourneyStateTests.realtimeFreshness)
    func trainObservedEndpointWithRealtimeIsAccepted(freshness: RealtimeFreshness) throws {
        #expect(try Self.state(.plannedEndReached(.trainObservedAtFinalStop), freshness: freshness) != nil)
    }

    /// Scheduled guidance can reach its planned endpoint only on the schedule
    /// basis, which claims no observation of train or rider.
    @Test(arguments: JourneyStateTests.realtimeFreshness + JourneyStateTests.nonRealtimeFreshness)
    func scheduleEndpointIsAcceptedWithAnyFreshness(freshness: RealtimeFreshness) throws {
        #expect(try Self.state(.plannedEndReached(.schedule), freshness: freshness) != nil)
    }

    // MARK: - Phase equality

    @Test func phaseEqualityDistinguishesEveryPayload() throws {
        #expect(JourneyPhase.awaitingDeparture(legIndex: 0) != .awaitingDeparture(legIndex: 1))
        #expect(JourneyPhase.plannedEndReached(.schedule) != .plannedEndReached(.trainObservedAtFinalStop))
        #expect(JourneyPhase.interrupted(.missedTrain, legIndex: 0) != .interrupted(.missedTrain, legIndex: nil))
        #expect(JourneyPhase.ended(.cancelledByUser) != .ended(.trackingCompleted))
        #expect(JourneyPhase.transferring(.walking(legIndex: 1)) != .transferring(.atStation(afterRailLeg: 1)))
        #expect(
            JourneyPhase.riding(legIndex: 0, position: try Self.position(.atStop(0), .observed))
                != .riding(legIndex: 0, position: try Self.position(.atStop(0), .scheduleEstimate))
        )
    }

    // MARK: - Concurrency

    @Test func statesCrossActorBoundaries() async throws {
        let subject = try #require(try Self.state(.awaitingDeparture(legIndex: 0), freshness: .live(updatedAt: Self.earlier)))
        let received = await Task.detached { subject }.value

        #expect(received.journeyID == subject.journeyID)
        #expect(received.phase == subject.phase)
        #expect(received.freshness == subject.freshness)
        #expect(received.asOf == subject.asOf)
    }
}
