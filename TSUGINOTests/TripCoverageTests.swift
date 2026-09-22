import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for what a Trip's represented traversal covers
/// (DEC-060 C2, ARCHITECTURE.md §5.3).
struct TripCoverageTests {

    // MARK: - The four states

    @Test(arguments: [
        (true, true),    // complete service
        (true, false),   // trailing partial: real origin, ends before the real destination
        (false, true),   // leading partial: begins after the real origin, reaches the destination
        (false, false),  // middle only
    ])
    func everyCombinationIsValidAndPreserved(sample: (Bool, Bool)) {
        let coverage = TripCoverage(
            includesServiceOrigin: sample.0,
            includesServiceDestination: sample.1
        )

        #expect(coverage.includesServiceOrigin == sample.0)
        #expect(coverage.includesServiceDestination == sample.1)
    }

    /// Construction is total: there is no combination to reject, so there is
    /// no failable initialiser to test against.
    @Test func theFourStatesAreDistinctValues() {
        let states = [
            TripCoverage(includesServiceOrigin: true, includesServiceDestination: true),
            TripCoverage(includesServiceOrigin: true, includesServiceDestination: false),
            TripCoverage(includesServiceOrigin: false, includesServiceDestination: true),
            TripCoverage(includesServiceOrigin: false, includesServiceDestination: false),
        ]

        #expect(Set(states).count == 4)
    }

    // MARK: - Equality and hashing (complete value)

    @Test func equalityAndHashingUseBothFlags() {
        let complete = TripCoverage(includesServiceOrigin: true, includesServiceDestination: true)
        let sameAsComplete = TripCoverage(includesServiceOrigin: true, includesServiceDestination: true)
        let trailingPartial = TripCoverage(includesServiceOrigin: true, includesServiceDestination: false)

        #expect(complete == sameAsComplete)
        #expect(complete.hashValue == sameAsComplete.hashValue)
        #expect(complete != trailingPartial)
    }

    // MARK: - Codable

    @Test(arguments: [(true, true), (true, false), (false, true), (false, false)])
    func everyStateRoundTrips(sample: (Bool, Bool)) throws {
        let original = TripCoverage(
            includesServiceOrigin: sample.0,
            includesServiceDestination: sample.1
        )
        let decoded = try JSONDecoder().decode(
            TripCoverage.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded.includesServiceOrigin == original.includesServiceOrigin)
        #expect(decoded.includesServiceDestination == original.includesServiceDestination)
        #expect(decoded == original)
    }

    @Test func encodedFormUsesExactlyTheTwoCoverageKeys() throws {
        let encoded = try JSONEncoder().encode(
            TripCoverage(includesServiceOrigin: true, includesServiceDestination: false)
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )

        #expect(Set(object.keys) == ["includesServiceOrigin", "includesServiceDestination"])
        #expect(object["includesServiceOrigin"] as? Bool == true)
        #expect(object["includesServiceDestination"] as? Bool == false)
    }

    @Test(arguments: [
        #"{"includesServiceOrigin":true}"#,
        #"{"includesServiceDestination":true}"#,
        #"{"includesServiceOrigin":"yes","includesServiceDestination":true}"#,
        "null",
        "[]",
    ])
    func malformedPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TripCoverage.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func coverageCrossesActorBoundaries() async throws {
        let coverage = TripCoverage(includesServiceOrigin: false, includesServiceDestination: true)
        let received = await Task.detached { coverage }.value

        #expect(received == coverage)
        #expect(received.includesServiceOrigin == false)
        #expect(received.includesServiceDestination == true)
    }
}
