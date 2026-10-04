#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Composition only: no hand-built timetable facts and no application adapter.
struct SyntheticTimetableRoutingIntegrationTests {
    private typealias PacketFixture = SyntheticTimetableConversionTests.Fixture
    private typealias F = InternalFixture
    private let interval = SyntheticInternalInterval(boarding: 0, alighting: 1)
    // Literal UTC oracle: 2026-04-12 23:00Z (local April 13 08:00 at +09:00).
    private let ordinaryDeparture = Date(timeIntervalSince1970: 1776034800)

    private func packet() throws -> PacketFixture {
        var f = try PacketFixture()
        f.visits = f.visits.enumerated().map { i, v in
            .init(index: v.index, occurrence: v.occurrence, mappingRevision: v.mappingRevision,
                  arrival: i == 0 ? .missing : .exact(clock: "08:30:00", evidence: "exact"),
                  departure: i == 0 ? .exact(clock: "08:00:00", evidence: "exact") : .missing,
                  boarding: .init(value: .allowed, evidence: "allow"),
                  alighting: .init(value: .allowed, evidence: "allow"))
        }
        return f
    }

    private struct Composition {
        let outcome: SyntheticTimetableOutcome
        let slot: SyntheticInternalSlot
    }
    private func compose(_ f: PacketFixture) -> Composition {
        let outcome = SyntheticTimetableConverter.convert(f.packet)
        let activation: SyntheticInternalActivation
        switch outcome {
        case .success(let facts): activation = .active(facts, [.init(interval: interval, evidence: .affirmed)])
        case .inactive: activation = .inactive
        case .unsupported, .insufficientEvidence, .invalid: activation = .unavailable
        }
        return .init(outcome: outcome, slot: .init(address: f.binding.address, activation: activation))
    }

    private func search(_ c: Composition, _ f: PacketFixture, mismatch: Int = 0,
                        start: Date? = nil) async throws -> RouteSearchResult {
        // Stipulated association: R1 / invented-civil-day-v1 / Z1 / M1 belongs to
        // F.viewID and F.interpretation in this artificial world. Domain facts do
        // not retain/authenticate the revision tokens. No inference from a packet.
        // Exactly this dated slot is the complete execution universe in W; [0,1]
        // is its complete interval inventory. No other run/date can contribute.
        // One ride means no directional connection inventory is required.
        let lower = start ?? ordinaryDeparture
        let cfg = F.configuration(cap: 1, duration: 3600, stations: ["A", "B"], lines: ["L1"])
        var trip = f.binding.trip
        if mismatch == 1 { trip = try PacketFixture(stops: ["A", "C"]).binding.trip }
        let inventory = SyntheticInternalInventory(trip: trip,
            intervals: mismatch == 3 ? nil : [interval], slots: [c.slot])
        let view = SyntheticInternalView(
            id: mismatch == 2 ? TimetableViewID(UUID(uuidString: "00000000-0000-0000-0000-000000000099")!) : F.viewID,
            validFrom: lower, validUntil: lower.addingTimeInterval(3600),
            stations: [F.station("A"): [.active], F.station("B"): [.active]], lines: [F.line("L1")],
            policies: .init(qualifiedManifest: F.interpretation, directionalTotalAllowance: F.connectionPolicy),
            inventories: [inventory], connections: [])
        let request = try #require(RouteSearchRequest(origin: F.station("A"), destination: F.station("B"), departNotBefore: lower))
        return try await SyntheticInternalRouteSearcher(configuration: cfg, view: view).search(request)
    }
    private func unavailable(_ c: Composition, _ f: PacketFixture, mismatch: Int = 0) async throws {
        do { _ = try await search(c, f, mismatch: mismatch); Issue.record("Expected coverage failure, not a result or omission") }
        catch RouteSearchFailure.dataUnavailable {}
    }
    private func active(_ c: Composition, _ f: PacketFixture) throws -> TimetableOccurrenceFacts {
        guard case .success(let converted) = c.outcome,
              case .active(let supplied, let continuity) = c.slot.activation else {
            throw CheckFailure.expectedActive
        }
        #expect(supplied.binding.matches(f.binding))
        #expect(supplied.binding.matches(converted.binding))
        #expect(supplied.visits.map(\.originalIndex) == [0, 1])
        #expect(c.slot.address == f.binding.address)
        #expect(continuity.count == 1 && continuity[0].interval == interval && continuity[0].evidence == .affirmed)
        for (a, b) in zip(supplied.visits, converted.visits) {
            #expect(a.arrival == b.arrival && a.departure == b.departure)
            #expect(a.boarding == b.boarding && a.alighting == b.alighting)
        }
        return supplied
    }
    private enum CheckFailure: Error { case expectedActive, expectedCandidate, expectedFailure }
    private func candidate(_ result: RouteSearchResult, _ f: PacketFixture, departure: Date, arrival: Date) throws {
        guard case .internalSuccess(let success) = result,
              case .alternatives(let batch) = success.outcome else { throw CheckFailure.expectedCandidate }
        #expect(success.scope.viewID == f.binding.address.viewID)
        #expect(batch.candidates.count == 1 && batch.omissions.isEmpty)
        let candidate = try #require(batch.candidates.first)
        #expect(candidate.origin == F.station("A") && candidate.destination == F.station("B"))
        #expect(candidate.legs.count == 1 && candidate.transferCount == 0)
        guard case .rail(let rail) = candidate.legs[0], case .matched(let train) = rail.travel,
              case .timetable(let context) = rail.scheduledContext else { throw CheckFailure.expectedCandidate }
        #expect(train.boardingIndex == 0 && train.alightingIndex == 1)
        #expect(context.boardingIndex == 0 && context.alightingIndex == 1)
        #expect(context.binding.matches(f.binding) && context.matches(train))
        #expect(context.binding.address.serviceDate.label == "2026-04-13")
        #expect(train.trip.stopSequence == f.binding.trip.stopSequence)
        #expect(train.trip.lineSegments == f.binding.trip.lineSegments)
        #expect(train.trip.serviceTypeSegments == f.binding.trip.serviceTypeSegments)
        #expect(train.trip.coverage == f.binding.trip.coverage)
        #expect(context.departure == departure && context.arrival == arrival)
    }
    private func noResults(_ result: RouteSearchResult, _ f: PacketFixture) {
        guard case .internalSuccess(let success) = result, case .noResults = success.outcome else {
            Issue.record("Expected scoped noResults"); return
        }
        #expect(success.scope.viewID == f.binding.address.viewID)
        #expect(success.scope.request.origin == F.station("A") && success.scope.request.destination == F.station("B"))
    }

    @Test func ordinaryWithMissingUnusedCounterparts() async throws {
        let f = try packet(), c = compose(f)
        let facts = try active(c, f)
        #expect(facts.visits[0].arrival == .missing && facts.visits[1].departure == .missing)
        #expect(facts.visits[0].departure == .exact(TimetableInstant(ordinaryDeparture)!))
        #expect(facts.visits[1].arrival == .exact(TimetableInstant(ordinaryDeparture.addingTimeInterval(1800))!))
        try candidate(await search(c, f), f, departure: ordinaryDeparture, arrival: ordinaryDeparture.addingTimeInterval(1800))
    }
    @Test func midnightCrossingKeepsServiceDate() async throws {
        var f = try packet()
        f.event(0, .exact(clock: "23:50:00", evidence: "exact"))
        f.event(1, .exact(clock: "24:10:00", evidence: "exact"), arrival: true)
        let c = compose(f), facts = try active(c, f)
        // 2026-04-13 14:50Z and 15:10Z; both retain service date April 13.
        let departure = Date(timeIntervalSince1970: 1776091800), arrival = Date(timeIntervalSince1970: 1776093000)
        #expect(facts.visits[0].departure == .exact(TimetableInstant(departure)!))
        #expect(facts.visits[1].arrival == .exact(TimetableInstant(arrival)!))
        try candidate(await search(c, f, start: departure), f, departure: departure, arrival: arrival)
    }
    @Test func inactiveIsCompleteNegativeWithoutEventFacts() async throws {
        var f = try packet()
        f.rules(exceptions: [.init(service: f.service, date: f.date, action: .remove)])
        f.event(0, .exact(clock: "08:75:00", evidence: "exact"))
        let c = compose(f)
        guard case .inactive(.explicitRemoval) = c.outcome, case .inactive = c.slot.activation else { throw CheckFailure.expectedFailure }
        noResults(try await search(c, f), f)
    }
    @Test(arguments: [false, true], [false, true])
    func requiredEndpointQualityIsCoverageFailure(_ arrival: Bool, _ estimated: Bool) async throws {
        var f = try packet()
        let clock = arrival ? "08:30:00" : "08:00:00"
        f.event(arrival ? 1 : 0, estimated ? .estimated(clock: clock, evidence: "estimate") : .missing, arrival: arrival)
        let c = compose(f), facts = try active(c, f)
        let value = arrival ? facts.visits[1].arrival : facts.visits[0].departure
        let date = ordinaryDeparture.addingTimeInterval(arrival ? 1800 : 0)
        #expect(value == (estimated ? .estimated(TimetableInstant(date)!) : .missing))
        try await unavailable(c, f)
    }
    @Test(arguments: [0, 1, 2, 3])
    func conversionFailuresRetainDiagnosticsAndNeverBecomeInactive(_ mode: Int) async throws {
        var f = try packet()
        let expectedKind: SyntheticTimetableFailureKind
        let expectedReason: SyntheticTimetableReason
        switch mode {
        case 0: f.zone = .unsupported; expectedKind = .unsupported; expectedReason = .zoneKind
        case 1: f.zone = nil; expectedKind = .insufficientEvidence; expectedReason = .zoneUnavailable
        case 2: f.event(0, .exact(clock: "08:75:00", evidence: "exact")); expectedKind = .invalid; expectedReason = .clockSyntax
        default:
            f.manifest = .init(binding: f.binding,
                revision: .init(source: "R2", profile: f.revision.profile, zone: f.revision.zone, mapping: f.revision.mapping),
                profileEvidence: "profile", executionEvidence: "once")
            expectedKind = .invalid; expectedReason = .revisionConflict
        }
        let c = compose(f), failure: SyntheticTimetableFailure
        switch c.outcome {
        case .unsupported(let v): #expect(expectedKind == .unsupported); failure = v
        case .insufficientEvidence(let v): #expect(expectedKind == .insufficientEvidence); failure = v
        case .invalid(let v): #expect(expectedKind == .invalid); failure = v
        default: throw CheckFailure.expectedFailure
        }
        #expect(failure.kind == expectedKind && failure.reason == expectedReason)
        #expect(failure.diagnostic.reason == (mode == 3 ? .viewUnavailable : mode == 2 ? .timeQualification : .activationUnavailable))
        guard case .unavailable = c.slot.activation else { throw CheckFailure.expectedFailure }
        try await unavailable(c, f)
    }
    @Test(arguments: [1, 2, 3])
    func searchRejectsSnapshotViewAndUnknownInventory(_ mismatch: Int) async throws {
        let f = try packet(), c = compose(f)
        _ = try active(c, f)
        try await unavailable(c, f, mismatch: mismatch)
        _ = try active(c, f) // The rejected consumer cannot relabel the original value.
    }
    @Test(arguments: [false, true])
    func legitimateExclusionsAreNotCoverageFailures(_ outsideWindow: Bool) async throws {
        var f = try packet()
        if !outsideWindow {
            let v = f.visits[0]
            f.visits[0] = .init(index: v.index, occurrence: v.occurrence, mappingRevision: v.mappingRevision,
                arrival: v.arrival, departure: v.departure, boarding: .init(value: .prohibited, evidence: "deny"), alighting: v.alighting)
        }
        let c = compose(f)
        _ = try active(c, f)
        noResults(try await search(c, f, start: outsideWindow ? ordinaryDeparture.addingTimeInterval(1) : nil), f)
    }
}
#endif
