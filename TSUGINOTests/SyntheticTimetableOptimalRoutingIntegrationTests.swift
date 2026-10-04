#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Test-only composition of DEC-085 conversion and DEC-086 prepared optimal admission.
/// Reuses the converter source fixture; never creates replacement timetable facts.
struct SyntheticTimetableOptimalRoutingIntegrationTests {
    private typealias F = InternalFixture
    private typealias PacketFixture = SyntheticTimetableConversionTests.Fixture
    private let interval = SyntheticInternalInterval(boarding: 0, alighting: 1)
    // Independent UTC oracle: April 13 08:00 +09:00 = April 12 23:00Z.
    private let morning: Double = 1776034800

    private struct Converted {
        let packet: SyntheticTimetablePacket
        let outcome: SyntheticTimetableOutcome
        let inventory: SyntheticInternalInventory
        let departure: Date
        let arrival: Date
    }
    private enum Failure: Error { case expectedFacts, expectedCandidate, expectedUnavailable }

    private func convert(_ id: String, stops: [String], departure: String, arrival: String,
                         departureUnix: Double, arrivalUnix: Double, missingZone: Bool = false) throws -> Converted {
        var f = try PacketFixture(stops: stops, id: id)
        // Evidence references are packet-local; each Trip has a distinct source
        // run while the invented calendar service may be shared by many runs.
        f.run = "run-" + id
        f.evidence = f.evidence.map {
            .init(id: $0.id, revision: $0.revision, run: f.run, service: $0.service,
                  assertion: $0.assertion, scope: $0.scope)
        }
        f.visits = f.visits.enumerated().map { i, v in
            .init(index: v.index, occurrence: v.occurrence, mappingRevision: v.mappingRevision,
                  arrival: i == 1 ? .exact(clock: arrival, evidence: "exact") : .missing,
                  departure: i == 0 ? .exact(clock: departure, evidence: "exact") : .missing,
                  boarding: .init(value: .allowed, evidence: "allow"),
                  alighting: .init(value: .allowed, evidence: "allow"))
        }
        if missingZone { f.zone = nil }
        let packet = f.packet
        let outcome = SyntheticTimetableConverter.convert(packet)
        let activation: SyntheticInternalActivation
        switch outcome {
        case .success(let facts): activation = .active(facts, [.init(interval: interval, evidence: .affirmed)])
        case .inactive: activation = .inactive
        case .unsupported, .insufficientEvidence, .invalid: activation = .unavailable
        }
        return .init(packet: packet, outcome: outcome,
                     inventory: .init(trip: packet.binding.trip, intervals: [interval],
                         slots: [.init(address: packet.binding.address, activation: activation)]),
                     departure: Date(timeIntervalSince1970: departureUnix), arrival: Date(timeIntervalSince1970: arrivalUnix))
    }

    private func search(_ rows: [Converted], connection: (Int, Int)? = nil,
                        start: Double) async throws -> RouteSearchResult {
        // EXPLICIT invented-world stipulations, not conclusions from conversion:
        // These exact Trip snapshots, one dated slot each and interval [0,1] each
        // exhaust inventory in the one-hour window. No other Trip/date can compete.
        // Each active interval has affirmed continuity; source permissions carry
        // the fixture's allow evidence. Every directional pair is explicitly absent
        // except the supplied same-station connection with a total 60s allowance.
        // Packet-local R1 / invented-civil-day-v1 / Z1 / M1 revisions are stipulated
        // to correspond to F.viewID, F.interpretation and F.connectionPolicy here.
        // Domain facts do not retain/authenticate those revision-token associations.
        let inventories = rows.map(\.inventory)
        let overrides = connection.map { a, b in
            [F.present(F.key(inventories[a], 1, inventories[b], 0), 60)]
        } ?? []
        let cfg = F.configuration(trips: rows.map { $0.packet.binding.trip.id.rawValue }, cap: 2,
                                  duration: 3600, stations: ["A", "B", "D"], lines: ["L1"])
        let view = F.view(inventories, connections: F.connections(inventories, overrides: overrides),
                          from: Date(timeIntervalSince1970: start).timeIntervalSinceReferenceDate,
                          until: Date(timeIntervalSince1970: start + 3600).timeIntervalSinceReferenceDate)
        let request = try #require(RouteSearchRequest(origin: F.station("A"), destination: F.station("D"),
                                                      departNotBefore: Date(timeIntervalSince1970: start)))
        return try await SyntheticOptimalRouteSearcher(configuration: cfg, view: view, workLimit: 100_000).search(request)
    }

    private func facts(_ row: Converted) throws -> TimetableOccurrenceFacts {
        guard case .success(let converted) = row.outcome,
              let slot = row.inventory.slots?.first,
              case .active(let supplied, let continuity) = slot.activation else { throw Failure.expectedFacts }
        #expect(row.packet.revision == .init(source: "R1", profile: "invented-civil-day-v1", zone: "Z1", mapping: "M1"))
        #expect(slot.address == row.packet.binding.address && slot.address.viewID == F.viewID)
        #expect(supplied.binding.matches(converted.binding) && supplied.binding.matches(row.packet.binding))
        #expect(supplied.visits.count == 2 && supplied.visits.map(\.originalIndex) == [0,1])
        #expect(continuity.count == 1 && continuity[0].interval == interval && continuity[0].evidence == .affirmed)
        for (a, b) in zip(supplied.visits, converted.visits) {
            #expect(a.arrival == b.arrival && a.departure == b.departure)
            #expect(a.boarding == b.boarding && a.alighting == b.alighting)
            #expect(a.boarding == .allowed && a.alighting == .allowed)
        }
        #expect(supplied.visits[0].arrival == .missing && supplied.visits[1].departure == .missing)
        #expect(supplied.visits[0].departure == .exact(try #require(TimetableInstant(row.departure))))
        #expect(supplied.visits[1].arrival == .exact(try #require(TimetableInstant(row.arrival))))
        return supplied
    }

    private func candidates(_ result: RouteSearchResult, rows: [Converted], expected: [[String]]) throws {
        // Check every conversion/consumer boundary, including objective exclusions.
        for row in rows { _ = try facts(row) }
        guard case .internalSuccess(let success) = result,
              case .alternatives(let batch) = success.outcome else { throw Failure.expectedCandidate }
        #expect(success.scope.viewID == F.viewID)
        #expect(success.scope.profile.connectionPolicy == F.connectionPolicy)
        #expect(success.scope.profile.serviceDateInterpretation == F.interpretation)
        #expect(batch.omissions.isEmpty && batch.candidates.count == expected.count)
        #expect(F.keys(batch) == expected.map { $0.map { "\($0)/2026-04-13/0-1" } })
        for candidate in batch.candidates {
            #expect(candidate.origin == F.station("A") && candidate.destination == F.station("D"))
            #expect(candidate.transferCount == candidate.legs.count - 1) // all fixture links are same-station
            for leg in candidate.legs {
                guard case .rail(let rail) = leg, case .matched(let train) = rail.travel,
                      case .timetable(let context) = rail.scheduledContext else { throw Failure.expectedCandidate }
                let row = try #require(rows.first { $0.packet.binding.address == context.binding.address })
                let converted = try facts(row)
                #expect(context.binding.matches(converted.binding) && context.matches(train))
                #expect(context.binding.address.serviceDate.label == "2026-04-13")
                #expect(context.boardingIndex == 0 && context.alightingIndex == 1)
                #expect(train.boardingIndex == 0 && train.alightingIndex == 1)
                #expect(train.trip.stopSequence == row.packet.binding.trip.stopSequence)
                #expect(train.trip.lineSegments == row.packet.binding.trip.lineSegments)
                #expect(train.trip.serviceTypeSegments == row.packet.binding.trip.serviceTypeSegments)
                #expect(train.trip.coverage == row.packet.binding.trip.coverage)
                #expect(context.departure == row.departure && context.arrival == row.arrival)
            }
        }
    }

    @Test(arguments: [20, 40, 30])
    func convertedDirectVersusTransfer(_ directMinutes: Int) async throws {
        let direct = try convert("direct", stops: ["A","D"], departure: "08:00:00", arrival: "08:\(directMinutes):00",
                                 departureUnix: morning, arrivalUnix: morning + Double(directMinutes * 60))
        let first = try convert("first", stops: ["A","B"], departure: "08:00:00", arrival: "08:10:00",
                                departureUnix: morning, arrivalUnix: morning + 600)
        let second = try convert("second", stops: ["B","D"], departure: "08:15:00", arrival: "08:30:00",
                                 departureUnix: morning + 900, arrivalUnix: morning + 1800)
        let rows = [direct,first,second]
        // 20: faster direct; 40: faster transfer; 30: equal arrival, fewer changes.
        try candidates(await search(rows, connection: (1,2), start: morning), rows: rows,
                       expected: directMinutes <= 30 ? [["direct"]] : [["first","second"]])
    }

    @Test func distinctConvertedEqualOptimaAllSurviveAdmission() async throws {
        let a = try convert("a", stops: ["A","D"], departure: "08:05:00", arrival: "08:30:00",
                            departureUnix: morning + 300, arrivalUnix: morning + 1800)
        let z = try convert("z", stops: ["A","D"], departure: "08:00:00", arrival: "08:30:00",
                            departureUnix: morning, arrivalUnix: morning + 1800)
        let rows = [z,a] // identity order, not input or departure order
        try candidates(await search(rows, start: morning), rows: rows, expected: [["a"],["z"]])
    }

    @Test func convertedMidnightTransferKeepsOriginalServiceDateAndInstants() async throws {
        // April 13 23:50 +09:00 = 14:50Z; 24:10 = April 14 00:10 +09:00.
        let start: Double = 1776091800
        let direct = try convert("direct", stops: ["A","D"], departure: "23:50:00", arrival: "24:20:00",
                                 departureUnix: start, arrivalUnix: 1776093600)
        let first = try convert("first", stops: ["A","B"], departure: "23:50:00", arrival: "23:55:00",
                                departureUnix: start, arrivalUnix: 1776092100)
        let second = try convert("second", stops: ["B","D"], departure: "24:00:00", arrival: "24:10:00",
                                 departureUnix: 1776092400, arrivalUnix: 1776093000)
        let rows = [direct,first,second]
        try candidates(await search(rows, connection: (1,2), start: start), rows: rows, expected: [["first","second"]])
    }

    @Test func unavailableConversionPreventsUsableDirectFallback() async throws {
        let good = try convert("good", stops: ["A","D"], departure: "08:00:00", arrival: "08:30:00",
                               departureUnix: morning, arrivalUnix: morning + 1800)
        let unknown = try convert("unknown", stops: ["A","D"], departure: "08:00:00", arrival: "08:20:00",
                                  departureUnix: morning, arrivalUnix: morning + 1200, missingZone: true)
        _ = try facts(good)
        guard case .insufficientEvidence(let failure) = unknown.outcome,
              let slot = unknown.inventory.slots?.first, case .unavailable = slot.activation else { throw Failure.expectedUnavailable }
        #expect(failure.kind == .insufficientEvidence && failure.reason == .zoneUnavailable)
        #expect(slot.address == unknown.packet.binding.address)
        // The unqualified clocks cannot establish a faster, slower or absent route.
        await #expect { try await search([good,unknown], start: morning) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
    }
}
#endif
