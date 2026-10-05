#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Invented test composition only: batch declarations do not establish request coverage.
struct SyntheticTimetableBatchRoutingIntegrationTests {
    private typealias F = InternalFixture
    private typealias PacketFixture = SyntheticTimetableConversionTests.Fixture
    private let interval = SyntheticInternalInterval(boarding: 0, alighting: 1)
    // April 13 08:00 +09:00 = April 12 23:00 UTC, independently stipulated.
    private let morning: Double = 1776034800
    private enum Mode: CaseIterable { case ordinary, unsupported, insufficient, inactive }
    private enum Failure: Error { case expectedBatch, expectedFacts, expectedResult, invalidSlot }

    private func packets(_ mode: Mode = .ordinary, view: TimetableViewID = F.viewID) throws -> [SyntheticTimetablePacket] {
        try [("D", ["A","C"], "08:05:00", "08:30:00"),
             ("X", ["A","B"], "08:02:00", "08:10:00"),
             ("Y", ["B","C"], "08:15:00", "08:20:00")].map { id, stops, departure, arrival in
            var f = try PacketFixture(stops: stops, id: id)
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
            if id == "Y" {
                switch mode {
                case .ordinary: break
                case .unsupported: f.event(1, .exact(clock: "72:00:00", evidence: "exact"), arrival: true)
                case .insufficient: f.zone = nil
                case .inactive: f.rules(exceptions: [.init(service: f.service, date: f.date, action: .remove)])
                }
            }
            let p = f.packet
            let binding = try #require(TimetableOccurrenceBinding(address: .init(viewID: view,
                tripID: p.binding.address.tripID, serviceDate: p.binding.address.serviceDate), trip: p.binding.trip))
            let manifest = p.manifest.map { SyntheticTimetableManifest(binding: binding, revision: $0.revision,
                profileEvidence: $0.profileEvidence, executionEvidence: $0.executionEvidence) }
            return .init(binding: binding, serviceDate: p.serviceDate, run: p.run, service: p.service,
                         revision: p.revision, manifest: manifest, evidence: p.evidence,
                         calendar: p.calendar, zone: p.zone, visits: p.visits)
        }
    }

    private func assemble(_ packets: [SyntheticTimetablePacket]) throws -> SyntheticTimetableBatchResult {
        let first = try #require(packets.first)
        return SyntheticTimetableBatchAssembler.assemble(.init(viewID: first.binding.address.viewID,
            revision: first.revision, expected: packets.map { $0.binding.address }, inventory: .stipulatedComplete),
            packets: Array(packets.reversed())) // declaration, not packet input order
    }
    private func batch(_ result: SyntheticTimetableBatchResult) throws -> SyntheticTimetableBatch {
        guard case .constructed(let value) = result else { throw Failure.expectedBatch }
        return value
    }

    private func inventories(_ batch: SyntheticTimetableBatch) throws -> [SyntheticInternalInventory] {
        try batch.slots.map { slot in
            let activation: SyntheticInternalActivation
            switch slot.outcome {
            case .success(let facts): activation = .active(facts, [.init(interval: interval, evidence: .affirmed)])
            case .inactive: activation = .inactive
            case .unsupported, .insufficientEvidence: activation = .unavailable
            case .invalid: throw Failure.invalidSlot // assembler must never construct this
            }
            let input = SyntheticInternalSlot(address: slot.binding.address, activation: activation)
            #expect(input.address == slot.binding.address)
            if case .success(let original) = slot.outcome {
                guard case .active(let supplied, let continuity) = input.activation else { throw Failure.expectedFacts }
                try sameFacts(supplied, original)
                #expect(continuity.count == 1 && continuity[0].interval == interval && continuity[0].evidence == .affirmed)
            } else {
                switch (slot.outcome, input.activation) {
                case (.inactive, .inactive), (.unsupported, .unavailable), (.insufficientEvidence, .unavailable): break
                default: Issue.record("Slot was omitted or reclassified")
                }
            }
            return .init(trip: slot.binding.trip, intervals: [interval], slots: [input])
        }
    }

    private func sameFacts(_ a: TimetableOccurrenceFacts, _ b: TimetableOccurrenceFacts) throws {
        #expect(a.binding.matches(b.binding)) // includes the full snapshot, not ID-only equality
        #expect(a.visits.count == b.visits.count && a.visits.map(\.originalIndex) == [0,1])
        for (x,y) in zip(a.visits, b.visits) {
            #expect(x.binding.matches(y.binding) && x.originalIndex == y.originalIndex)
            #expect(x.arrival == y.arrival && x.departure == y.departure)
            #expect(x.boarding == y.boarding && x.alighting == y.alighting)
            #expect(x.boarding == .allowed && x.alighting == .allowed)
        }
        #expect(a.visits[0].arrival == .missing && a.visits[1].departure == .missing)
        let minutes = ["D": (5,30), "X": (2,10), "Y": (15,20)]
        let times = try #require(minutes[a.binding.address.tripID.rawValue])
        #expect(a.visits[0].departure == .exact(try #require(TimetableInstant(Date(timeIntervalSince1970: morning + Double(times.0 * 60))))))
        #expect(a.visits[1].arrival == .exact(try #require(TimetableInstant(Date(timeIntervalSince1970: morning + Double(times.1 * 60))))))
    }

    private func search(_ result: SyntheticTimetableBatchResult, unknownConnection: Bool = false,
                        viewOverride: TimetableViewID? = nil,
                        invoke: (SyntheticOptimalRouteSearcher, RouteSearchRequest) async throws -> RouteSearchResult = { try await $0.search($1) }) async throws -> RouteSearchResult? {
        guard case .constructed(let batch) = result else { return nil }
        // Independent invented-world stipulations: exactly D/X/Y on this date, all
        // [0,1] intervals, active stations/line, allowed passenger endpoints and
        // affirmed continuity; no additional Trip/date can compete in this hour.
        // All directional pairs are explicitly absent except X[1] -> Y[0], whose
        // same-station allowance is 0 + 60 + 0 seconds with affirmed evidence.
        // R1/profile/Z1/M1 is stipulated applicable to each supplied view and the
        // fixture policies. Neither tokens nor the batch declaration authenticate
        // coverage or calendar/zone agreement. No global-unknown mapping is defined.
        let rows = try inventories(batch)
        #expect(rows.count == 3 && rows.map { $0.trip.id.rawValue } == ["D","X","Y"])
        let key = F.key(rows[1], 1, rows[2], 0)
        let relation = unknownConnection ? SyntheticInternalConnection(key: key, state: .unknown) : F.present(key, 60)
        let connections = F.connections(rows, overrides: [relation])
        #expect(connections.count == 6)
        #expect(connections.first { $0.key == key }?.state == relation.state)
        #expect(connections.filter { $0.key != key }.allSatisfy { $0.state == .absent })
        let view = F.view(rows, connections: connections, id: viewOverride ?? batch.envelope.viewID,
            from: Date(timeIntervalSince1970: morning).timeIntervalSinceReferenceDate,
            until: Date(timeIntervalSince1970: morning + 3600).timeIntervalSinceReferenceDate)
        let cfg = F.configuration(trips: ["D","X","Y"], cap: 2, duration: 3600, stations: ["A","B","C"], lines: ["L1"])
        let request = try #require(RouteSearchRequest(origin: F.station("A"), destination: F.station("C"),
                                                       departNotBefore: Date(timeIntervalSince1970: morning)))
        return try await invoke(SyntheticOptimalRouteSearcher(configuration: cfg, view: view, workLimit: 100_000), request)
    }

    private func assertResult(_ result: RouteSearchResult?, batch: SyntheticTimetableBatch, ids: [String]) throws {
        guard let result, case .internalSuccess(let success) = result,
              case .alternatives(let alternatives) = success.outcome else { throw Failure.expectedResult }
        #expect(success.scope.viewID == batch.envelope.viewID)
        #expect(success.scope.profile.connectionPolicy == F.connectionPolicy)
        #expect(success.scope.profile.serviceDateInterpretation == F.interpretation)
        #expect(alternatives.omissions.isEmpty)
        #expect(F.keys(alternatives) == [ids.map { "\($0)/2026-04-13/0-1" }])
        let candidate = try #require(alternatives.candidates.first)
        #expect(candidate.origin == F.station("A") && candidate.destination == F.station("C"))
        #expect(candidate.transferCount == ids.count - 1 && candidate.legs.count == ids.count)
        for leg in candidate.legs {
            guard case .rail(let rail) = leg, case .matched(let train) = rail.travel,
                  case .timetable(let context) = rail.scheduledContext else { throw Failure.expectedResult }
            let slot = try #require(batch.slots.first { $0.binding.address == context.binding.address })
            guard case .success(let facts) = slot.outcome else { throw Failure.expectedFacts }
            try sameFacts(facts, facts)
            #expect(context.binding.matches(slot.binding) && context.matches(train))
            #expect(context.binding.address.serviceDate.label == "2026-04-13")
            #expect(context.boardingIndex == 0 && context.alightingIndex == 1)
            #expect(train.boardingIndex == 0 && train.alightingIndex == 1)
            guard case .exact(let departure) = facts.visits[0].departure,
                  case .exact(let arrival) = facts.visits[1].arrival else { throw Failure.expectedFacts }
            #expect(context.departure == departure.date && context.arrival == arrival.date)
        }
    }

    @Test func completeBatchReachesCanonicalTransfer() async throws {
        let result = try assemble(packets())
        try assertResult(await search(result), batch: batch(result), ids: ["X","Y"])
    }

    @Test(arguments: [Mode.unsupported, .insufficient])
    private func requiredHeldSlotPreventsDirectFallback(_ mode: Mode) async throws {
        let inputs = try packets(mode), result = try assemble(inputs), value = try batch(result)
        let held = value.slots[2]
        #expect(held.binding.matches(inputs[2].binding))
        let diagnostic: SyntheticTimetableFailure
        switch held.outcome {
        case .unsupported(let f): #expect(mode == .unsupported && f.kind == .unsupported); diagnostic = f
        case .insufficientEvidence(let f): #expect(mode == .insufficient && f.kind == .insufficientEvidence); diagnostic = f
        default: throw Failure.expectedFacts
        }
        switch SyntheticTimetableConverter.convert(inputs[2]) {
        case .unsupported(let f), .insufficientEvidence(let f):
            #expect(diagnostic.reason == f.reason && diagnostic.diagnostic.reason == f.diagnostic.reason)
            #expect(diagnostic.diagnostic.event == f.diagnostic.event)
        default: throw Failure.expectedFacts
        }
        await #expect { try await search(result) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
    }

    @Test func unknownConnectionPreventsDirectFallback() async throws {
        let result = try assemble(packets())
        await #expect { try await search(result, unknownConnection: true) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
    }

    @Test func inactiveSlotAllowsQualifiedDirect() async throws {
        let result = try assemble(packets(.inactive))
        try assertResult(await search(result), batch: batch(result), ids: ["D"])
    }

    @Test func freshAndRetainedViewsRemainExactAndCannotBeMixed() async throws {
        let old = try assemble(packets()), retained = try batch(old)
        let v2 = TimetableViewID(try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000099")))
        let fresh = try assemble(packets(view: v2)), new = try batch(fresh)
        try assertResult(await search(old), batch: retained, ids: ["X","Y"])
        try assertResult(await search(fresh), batch: new, ids: ["X","Y"])
        for (a,b) in zip(retained.slots, new.slots) {
            #expect(a.binding.address.viewID == F.viewID && b.binding.address.viewID == v2)
            #expect(!a.binding.matches(b.binding))
        }
        await #expect { try await search(old, viewOverride: v2) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
        try assertResult(await search(old), batch: retained, ids: ["X","Y"])
    }

    @Test func failedAssemblyNeverInvokesSearch() async throws {
        let inputs = try packets()
        let result = SyntheticTimetableBatchAssembler.assemble(.init(viewID: F.viewID, revision: inputs[0].revision,
            expected: inputs.map { $0.binding.address }, inventory: .stipulatedComplete), packets: Array(inputs.prefix(2)))
        guard case .failure(let failure) = result else { throw Failure.expectedBatch }
        #expect(failure.reason == .missingPacket && failure.location == .declaration(2))
        let output = try await search(result) { _, _ in
            Issue.record("Failed assembly must never invoke search")
            throw Failure.expectedResult
        }
        #expect(output == nil)
    }
}
#endif
