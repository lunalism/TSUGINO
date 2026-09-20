import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the capability vocabulary and the derived guidance tier
/// (DEC-022, DEC-047, DEC-054, ARCHITECTURE.md §51).
struct RailCapabilityTests {

    // MARK: - Vocabulary

    @Test func vocabularyHasExactlyTheNineAcceptedCases() {
        #expect(RailCapability.allCases.count == 9)
        #expect(Set(RailCapability.allCases.map(\.rawValue)) == [
            "staticSchedule",
            "tripUpdates",
            "vehiclePosition",
            "alerts",
            "serviceStatus",
            "platform",
            "recommendedCar",
            "recommendedDoor",
            "exitGuidance",
        ])
    }

    @Test func rawValuesAreDistinct() {
        #expect(Set(RailCapability.allCases.map(\.rawValue)).count == RailCapability.allCases.count)
    }

    @Test func serviceStatusIsSeparateFromAlerts() {
        #expect(RailCapability.serviceStatus != RailCapability.alerts)
        #expect(Set<RailCapability>([.alerts, .serviceStatus]).count == 2)
    }

    // MARK: - Equality, hashing, set behaviour

    @Test func equalityAndHashing() {
        #expect(RailCapability.tripUpdates == RailCapability.tripUpdates)
        #expect(RailCapability.tripUpdates != RailCapability.vehiclePosition)

        let set: Set<RailCapability> = [.tripUpdates, .tripUpdates, .alerts]
        #expect(set.count == 2)
        #expect(set.contains(.tripUpdates))
        #expect(!set.contains(.staticSchedule))
    }

    // MARK: - Codable

    @Test(arguments: RailCapability.allCases)
    func atomicCapabilityRoundTrips(capability: RailCapability) throws {
        let decoded = try JSONDecoder().decode(
            RailCapability.self,
            from: try JSONEncoder().encode(capability)
        )

        #expect(decoded == capability)
        #expect(decoded.rawValue == capability.rawValue)
    }

    @Test func capabilitySetRoundTrips() throws {
        let original: Set<RailCapability> = [.staticSchedule, .alerts, .serviceStatus]
        let decoded = try JSONDecoder().decode(
            Set<RailCapability>.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded == original)
    }

    @Test(arguments: [#""realtimeTracking""#, #""TRIPUPDATES""#, #""trip_updates""#, #""unknown""#])
    func unknownRawValuesFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RailCapability.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Tier derivation

    /// Split by expected tier and explicitly typed: one combined array of
    /// `(Set, Tier)` tuples pushed the type checker past its budget.
    @Test(arguments: [
        [RailCapability.tripUpdates],
        [.tripUpdates, .vehiclePosition],
        [.tripUpdates, .staticSchedule],
        [.tripUpdates, .staticSchedule, .vehiclePosition, .alerts, .serviceStatus],
    ] as [Set<RailCapability>])
    func realtimeTierIsDerivedFromTripUpdates(declared: Set<RailCapability>) {
        #expect(RailCapabilityTier(declared: declared) == .realtimeJourneyTracking)
    }

    @Test(arguments: [
        [RailCapability.staticSchedule],
        [.staticSchedule, .alerts],
        [.staticSchedule, .serviceStatus],
        [.staticSchedule, .alerts, .serviceStatus],
        [.staticSchedule, .vehiclePosition],
    ] as [Set<RailCapability>])
    func scheduledTierIsDerivedFromStaticScheduleWithoutTripUpdates(declared: Set<RailCapability>) {
        #expect(RailCapabilityTier(declared: declared) == .scheduledJourneyGuidance)
    }

    @Test(arguments: [
        [],
        [RailCapability.alerts],
        [.serviceStatus],
        [.alerts, .serviceStatus],
        [.vehiclePosition],
        [.platform],
        [.recommendedCar],
        [.recommendedDoor],
        [.exitGuidance],
        [.platform, .recommendedCar, .recommendedDoor, .exitGuidance],
    ] as [Set<RailCapability>])
    func deferredTierIsDerivedWithoutScheduleOrTripUpdates(declared: Set<RailCapability>) {
        #expect(RailCapabilityTier(declared: declared) == .deferredOrUnsupported)
    }

    @Test func tripUpdatesTakePrecedenceOverStaticSchedule() {
        #expect(
            RailCapabilityTier(declared: [.staticSchedule, .tripUpdates]) == .realtimeJourneyTracking
        )
    }

    @Test func supplementaryCapabilitiesNeverPromoteATier() {
        let supplements: Set<RailCapability> = [
            .vehiclePosition, .alerts, .serviceStatus,
            .platform, .recommendedCar, .recommendedDoor, .exitGuidance,
        ]

        #expect(RailCapabilityTier(declared: supplements) == .deferredOrUnsupported)

        for supplement in supplements {
            #expect(
                RailCapabilityTier(declared: [.staticSchedule, supplement]) == .scheduledJourneyGuidance,
                "\(supplement) must not promote a scheduled service"
            )
        }
    }

    /// A `Set` is unordered, so this is a guard against a future derivation that
    /// walked a sequence and returned on first match.
    @Test func insertionOrderDoesNotAffectTheDerivedTier() {
        var forwards: Set<RailCapability> = []
        for capability in [RailCapability.staticSchedule, .alerts, .tripUpdates] {
            forwards.insert(capability)
        }

        var backwards: Set<RailCapability> = []
        for capability in [RailCapability.tripUpdates, .alerts, .staticSchedule] {
            backwards.insert(capability)
        }

        #expect(RailCapabilityTier(declared: forwards) == RailCapabilityTier(declared: backwards))
        #expect(RailCapabilityTier(declared: forwards) == .realtimeJourneyTracking)
    }

    /// Derivation takes the declared set and nothing else: no operator, no
    /// provider, no names. Two different operators declaring the same set must
    /// therefore land on the same tier (Rule 10, DEC-054).
    @Test func derivationIgnoresWhoDeclaredTheSet() throws {
        let declared: Set<RailCapability> = [.staticSchedule, .serviceStatus]
        let tier = RailCapabilityTier(declared: declared)

        let nameA = try #require(LocalizedRailName(japanese: "甲", english: "A", korean: "가"))
        let nameB = try #require(LocalizedRailName(japanese: "乙", english: "B", korean: "나"))
        _ = Operator(id: try #require(OperatorID("op-a")), name: nameA)
        _ = Operator(id: try #require(OperatorID("op-b")), name: nameB)

        // The operators are constructed only to show they are not inputs: the
        // derivation signature takes no operator, so it cannot consult one.
        #expect(tier == .scheduledJourneyGuidance)
        #expect(RailCapabilityTier(declared: declared) == tier)
    }

    // MARK: - Concurrency

    @Test func capabilitiesAndTiersCrossActorBoundaries() async {
        let declared: Set<RailCapability> = [.tripUpdates, .vehiclePosition]
        let tier = RailCapabilityTier(declared: declared)
        let received = await Task.detached { (declared, tier) }.value

        #expect(received.0 == declared)
        #expect(received.1 == tier)
    }
}
