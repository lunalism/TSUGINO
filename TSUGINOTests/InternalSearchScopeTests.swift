import Foundation
import Testing
@testable import TSUGINO

/// Slice A constructor cases only; no coverage, policy resolution or search proof.
struct InternalSearchScopeTests {
    private func uuid(_ n: Int) -> UUID {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UInt8(n)))
    }
    private func profile(stations: [String] = ["A", "B"], lines: [String] = ["L"],
                         trips: [String] = ["T"], duration: Double = 7200, rides: Int = 3,
                         revision: Int = 2, connection: Int = 4, interpretation: Int = 6)
        throws -> InternalSearchProfileDefinition? {
        InternalSearchProfileDefinition(identity: .init(key: uuid(1), revision: uuid(revision)),
            stations: Set(try stations.map { try #require(StationID($0)) }),
            lines: Set(try lines.map { try #require(LineID($0)) }),
            trips: Set(try trips.map { try #require(TripID($0)) }),
            maximumElapsedDuration: duration, maximumRailRides: rides,
            connectionPolicy: .init(key: uuid(3), revision: uuid(connection)),
            serviceDateInterpretation: .init(key: uuid(5), revision: uuid(interpretation)))
    }
    private func request(_ lower: Double = 100, origin: String = "A", destination: String = "B") throws -> RouteSearchRequest {
        let from = try #require(StationID(origin)), to = try #require(StationID(destination))
        return try #require(RouteSearchRequest(origin: from, destination: to,
            departNotBefore: Date(timeIntervalSinceReferenceDate: lower)))
    }
    private func scope(_ lower: Double = 100, duration: Double = 7200, view: Int = 7) throws -> InternalSearchScope? {
        InternalSearchScope(profile: try #require(try profile(duration: duration)), request: try request(lower), viewID: TimetableViewID(uuid(view)))
    }

    @Test func preservesFullDefinitionRequestAndView() throws {
        let p = try #require(try profile()), r = try request(), v = TimetableViewID(uuid(7))
        let s = try #require(InternalSearchScope(profile: p, request: r, viewID: v))
        #expect(s.profile.hasSameDefinition(as: p))
        #expect(s.profile.stations == Set([try #require(StationID("A")), try #require(StationID("B"))]))
        #expect(s.profile.lines == Set([try #require(LineID("L"))]))
        #expect(s.profile.trips == Set([try #require(TripID("T"))]))
        #expect(s.profile.maximumElapsedDuration == 7200 && s.profile.maximumRailRides == 3)
        #expect(s.profile.connectionPolicy == InternalSearchPolicyReference(key: uuid(3), revision: uuid(4)))
        #expect(s.profile.serviceDateInterpretation == InternalSearchPolicyReference(key: uuid(5), revision: uuid(6)))
        #expect(s.request.origin == r.origin && s.request.destination == r.destination)
        #expect(s.request.departNotBefore == r.departNotBefore && s.viewID == v)
        #expect(s.lowerBound == r.departNotBefore)
        #expect(s.upperBound == Date(timeIntervalSinceReferenceDate: 7300))
    }

    @Test(arguments: [0, 1, 2]) func emptyDomainRejects(_ field: Int) throws {
        #expect(try profile(stations: field == 0 ? [] : ["A", "B"],
            lines: field == 1 ? [] : ["L"], trips: field == 2 ? [] : ["T"]) == nil)
    }
    @Test func domainDoesNotInventMembershipEvidence() throws {
        // No relation between these sets is supplied. A singleton station domain is
        // structurally valid even though no distinct-endpoint request fits it.
        #expect(try profile(stations: ["A"]) != nil)
    }
    @Test(arguments: [Double.nan, Double.infinity, -Double.infinity, 0, -0.0, -1])
    func invalidDurationsReject(_ duration: Double) throws {
        #expect(try profile(duration: duration) == nil)
    }
    @Test func rideCapValidationHasNoInventedProductionMaximum() throws {
        for cap in [Int.min, -1, 0] { #expect(try profile(rides: cap) == nil) }
        for cap in [1, Int.max] { #expect(try profile(rides: cap)?.maximumRailRides == cap) }
    }
    @Test func requestMustBelongToDeclaredStationDomain() throws {
        let p = try #require(try profile()), v = TimetableViewID(uuid(7))
        for r in [try request(origin: "X"), try request(destination: "X")] {
            #expect(InternalSearchScope(profile: p, request: r, viewID: v) == nil)
        }
    }
    @Test func boundsAreInclusiveAndFinite() throws {
        let s = try #require(try scope())
        for n in [100.0, 101, 7300] { #expect(s.contains(Date(timeIntervalSinceReferenceDate: n))) }
        for n in [99.0, 7301, .nan, .infinity, -.infinity] {
            #expect(!s.contains(Date(timeIntervalSinceReferenceDate: n)))
        }
    }
    @Test func overflowNoAdvanceAndRoundedAdvanceReject() throws {
        #expect(try scope(Double.greatestFiniteMagnitude, duration: Double.greatestFiniteMagnitude) == nil)
        let large = 9_007_199_254_740_992.0
        #expect(try scope(large, duration: 0.25) == nil)
        #expect(try scope(large, duration: 3) == nil) // Advances, but rounds the exact horizon.
        #expect(try scope(large, duration: 2)?.upperBound == Date(timeIntervalSinceReferenceDate: large + 2))
    }
    @Test func representableCrossZeroAndSmallBoundsRemainValid() throws {
        #expect(try scope(-100, duration: 200)?.upperBound == Date(timeIntervalSinceReferenceDate: 100))
        let tiny = Double.leastNonzeroMagnitude
        #expect(try scope(0, duration: tiny)?.upperBound == Date(timeIntervalSinceReferenceDate: tiny))
    }
    @Test func semanticComparisonExaminesEverySuppliedConstraint() throws {
        let p = try #require(try profile())
        #expect(p.hasSameDefinition(as: try #require(try profile(stations: ["B", "A"])) ))
        let changes = try [profile(stations: ["A", "B", "C"]), profile(lines: ["L", "M"]),
            profile(trips: ["T", "U"]), profile(duration: 1), profile(rides: 1),
            profile(connection: 8), profile(interpretation: 9)]
        for changed in changes {
            let other = try #require(changed)
            #expect(p.identity == other.identity)
            #expect(!p.hasSameDefinition(as: other))
        }
        // Conflicts can be compared locally, not globally prevented by construction.
        let revised = try #require(try profile(revision: 10))
        #expect(p.identity.key == revised.identity.key && p.identity != revised.identity)
        #expect(!p.hasSameDefinition(as: revised))
        let rekeyed = try #require(InternalSearchProfileDefinition(identity: .init(key: uuid(11), revision: p.identity.revision),
            stations: p.stations, lines: p.lines, trips: p.trips, maximumElapsedDuration: p.maximumElapsedDuration,
            maximumRailRides: p.maximumRailRides, connectionPolicy: p.connectionPolicy,
            serviceDateInterpretation: p.serviceDateInterpretation))
        #expect(!p.hasSameDefinition(as: rekeyed))
    }
    @Test func independentValuesTransferAcrossTasks() async throws {
        let first = try #require(try scope()), second = try #require(try scope(200, duration: 100, view: 8))
        let returned = await Task.detached { (first, second) }.value
        #expect(returned.0.viewID != returned.1.viewID)
        #expect(returned.0.upperBound == Date(timeIntervalSinceReferenceDate: 7300))
        #expect(returned.1.upperBound == Date(timeIntervalSinceReferenceDate: 300))
        #expect(!returned.0.profile.hasSameDefinition(as: returned.1.profile))
    }
}
