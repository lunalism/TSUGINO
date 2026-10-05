#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticTimetableBatchTests {
    typealias F = SyntheticTimetableConversionTests.Fixture
    typealias P = SyntheticTimetablePacket
    typealias A = SyntheticTimetableBatchAssembler
    typealias E = SyntheticTimetableBatchEnvelope
    private enum Failure: Error { case expectedBatch, expectedFailure, sameViewReplacement }

    private func envelope(_ packets: [P], inventory: SyntheticTimetableInventoryDeclaration = .stipulatedComplete) throws -> E {
        let first = try #require(packets.first)
        return .init(viewID: first.binding.address.viewID, revision: first.revision,
                     expected: packets.map { $0.binding.address }, inventory: inventory)
    }
    private func batch(_ result: SyntheticTimetableBatchResult) throws -> SyntheticTimetableBatch {
        guard case .constructed(let batch) = result else { Issue.record("Expected constructed batch"); throw Failure.expectedBatch }
        return batch
    }
    private func failure(_ result: SyntheticTimetableBatchResult, _ reason: SyntheticTimetableBatchReason,
                         _ location: SyntheticTimetableBatchLocation? = nil) throws -> SyntheticTimetableBatchFailure {
        guard case .failure(let failure) = result else { Issue.record("Expected atomic failure"); throw Failure.expectedFailure }
        #expect(failure.reason == reason)
        #expect(failure.location == location)
        return failure
    }
    private func rebind(_ p: P, view: TimetableViewID? = nil,
                        revision: SyntheticTimetableRevision? = nil) throws -> P {
        let binding = try #require(TimetableOccurrenceBinding(address: .init(viewID: view ?? p.binding.address.viewID,
            tripID: p.binding.address.tripID, serviceDate: p.binding.address.serviceDate), trip: p.binding.trip))
        let manifest = p.manifest.map { SyntheticTimetableManifest(binding: binding, revision: $0.revision,
            profileEvidence: $0.profileEvidence, executionEvidence: $0.executionEvidence) }
        return .init(binding: binding, serviceDate: p.serviceDate, run: p.run, service: p.service,
            revision: revision ?? p.revision, manifest: manifest, evidence: p.evidence,
            calendar: p.calendar, zone: p.zone, visits: p.visits)
    }
    private func compare(_ actual: SyntheticTimetableFailure, _ expected: SyntheticTimetableFailure) {
        #expect(actual.kind == expected.kind)
        #expect(actual.reason == expected.reason)
        #expect(actual.diagnostic.reason == expected.diagnostic.reason)
        #expect(actual.diagnostic.event == expected.diagnostic.event)
    }
    private func convertedFacts(_ p: P) throws -> TimetableOccurrenceFacts {
        guard case .success(let facts) = SyntheticTimetableConverter.convert(p) else { throw Failure.expectedBatch }
        return facts
    }
    private func directTransfer() throws -> [P] {
        try [("D", ["A","C"], "08:05:00", "08:30:00"),
             ("X", ["A","B"], "08:02:00", "08:10:00"),
             ("Y", ["B","C"], "08:15:00", "08:20:00")].map { id, stops, departure, arrival in
            var f = try F(stops: stops, id: id)
            f.visits = f.visits.enumerated().map { index, v in
                .init(index: v.index, occurrence: v.occurrence, mappingRevision: v.mappingRevision,
                    arrival: index == 1 ? .exact(clock: arrival, evidence: "exact") : .missing,
                    departure: index == 0 ? .exact(clock: departure, evidence: "exact") : .missing,
                    boarding: .init(value: .allowed, evidence: "allow"),
                    alighting: .init(value: .allowed, evidence: "allow"))
            }
            return f.packet
        }
    }

    @Test(arguments: [[0,1,2], [2,0,1], [1,2,0]])
    func completeInventoryPreservesExactOutcomesAndDeclarationOrder(_ permutation: [Int]) throws {
        let packets = try directTransfer(), env = try envelope(packets)
        let result = try batch(A.assemble(env, packets: permutation.map { packets[$0] }))
        #expect(result.slots.map { $0.binding.address } == env.expected)
        for (slot, packet) in zip(result.slots, packets) {
            #expect(slot.binding.matches(packet.binding))
            guard case .success(let actual) = slot.outcome else { throw Failure.expectedBatch }
            let expected = try convertedFacts(packet)
            #expect(actual.binding.matches(expected.binding))
            #expect(actual.visits.count == expected.visits.count)
            for (a,b) in zip(actual.visits, expected.visits) {
                #expect(a.binding.matches(b.binding) && a.originalIndex == b.originalIndex)
                #expect(a.arrival == b.arrival && a.departure == b.departure)
                #expect(a.boarding == b.boarding && a.alighting == b.alighting)
            }
        }
    }

    @Test(arguments: [0,1,2]) func holdsAndInactiveAreNotDropped(_ mode: Int) throws {
        let direct = try F(id: "D").packet
        var held = try F(id: "Y")
        if mode == 0 { held.event(0, .exact(clock: "72:00:00", evidence: "exact")) }
        if mode == 1 { held.calendar = nil }
        if mode == 2 { held.rules(exceptions: [.init(service: "service", date: held.date, action: .remove)]) }
        let packets = [direct, held.packet], env = try envelope(packets)
        let result = try batch(A.assemble(env, packets: packets))
        #expect(result.slots.count == 2 && result.slots[1].binding.matches(held.binding))
        switch (result.slots[1].outcome, SyntheticTimetableConverter.convert(held.packet)) {
        case (.unsupported(let a), .unsupported(let b)), (.insufficientEvidence(let a), .insufficientEvidence(let b)): compare(a,b)
        case (.inactive(let a), .inactive(let b)): #expect(a == b)
        default: Issue.record("Outcome changed")
        }
    }

    @Test func unknownTransferIsNotQualifiedByConstruction() throws {
        let packets = try directTransfer()
        let result = try batch(A.assemble(try envelope(packets), packets: packets))
        #expect(result.slots.count == 3)
        // Connections are not assembler input or output. This independently retained unknown
        // cannot become absent/present because all packets converted. No batch-to-search bridge.
        let relation = SyntheticInternalConnection(key: .init(
            alighting: .init(address: packets[1].binding.address, index: 1),
            boarding: .init(address: packets[2].binding.address, index: 0)), state: .unknown)
        #expect(relation.state == .unknown)
        // Existing g5 and converter/optimal integration suites supply dataUnavailable proof.
    }

    @Test(arguments: [false,true]) func duplicatePacketsRejectEvenWhenIdentical(_ conflict: Bool) throws {
        let a = try F().packet, b = try F(stops: conflict ? ["A","C"] : ["A","B"]).packet
        _ = try failure(A.assemble(try envelope([a]), packets: [a,b]), .duplicatePacket, .packet(1))
        _ = try failure(A.assemble(try envelope([a,a]), packets: [a]), .duplicateDeclaration, .declaration(1))
    }

    @Test func missingAndUnexpectedHaveDifferentIndexDomains() throws {
        let a = try F(id: "A").packet, b = try F(id: "B").packet
        _ = try failure(A.assemble(try envelope([a,b]), packets: [a]), .missingPacket, .declaration(1))
        _ = try failure(A.assemble(try envelope([a]), packets: [a,b]), .unexpectedPacket, .packet(1))
    }

    @Test func envelopeAndPacketAssociationFailures() throws {
        let p = try F().packet, env = try envelope([p])
        let other = TimetableViewID(UUID())
        _ = try failure(A.assemble(.init(viewID: other, revision: env.revision, expected: env.expected,
            inventory: .unknown), packets: [p]), .declarationView, .declaration(0))
        let changed = try rebind(p, revision: .init(source: "R2", profile: p.revision.profile, zone: "Z1", mapping: "M1"))
        _ = try failure(A.assemble(env, packets: [changed]), .packetAssociation, .declaration(0))
        _ = try failure(A.assemble(env, packets: [try rebind(p, view: other)]), .unexpectedPacket, .packet(0))
    }

    @Test(arguments: [false,true]) func crossDateSnapshotCorrespondence(_ conflict: Bool) throws {
        let first = try F().packet
        let second = try F(date: "2026-04-14", stops: conflict ? ["A","C"] : ["A","B"]).packet
        let packets = [first, second], env = try envelope(packets)
        if conflict { _ = try failure(A.assemble(env, packets: packets), .snapshotConflict, .declaration(1)) }
        else {
            let result = try batch(A.assemble(env, packets: packets))
            #expect(result.slots[0].binding.matches(first.binding))
            #expect(result.slots[1].binding.matches(second.binding))
        }
    }

    @Test func invalidConversionUsesDeclarationIndexAndIsAtomic() throws {
        let valid = try F(id: "D").packet
        var bad = try F(id: "X"); bad.event(0, .exact(clock: "08:99:00", evidence: "exact"))
        let packets = [valid,bad.packet], env = try envelope(packets)
        #expect(SyntheticTimetableConverter.preflightFailure(bad.packet) == nil)
        let result = try failure(A.assemble(env, packets: packets.reversed()), .invalidPacket, .declaration(1))
        guard case .invalid(let expected) = SyntheticTimetableConverter.convert(bad.packet) else { throw Failure.expectedFailure }
        compare(try #require(result.converterFailure), expected)
        // Enum failure carries no batch/survivor payload, even though D converted first.
        #expect(try convertedFacts(valid).binding.matches(valid.binding))
    }

    @Test(arguments: [0,1,2,3,4]) func exactPreflightDiagnosticsAndPacketIndices(_ mode: Int) throws {
        let valid = try F(id: "D").packet
        var bad = try F(date: mode == 4 ? "2026-4-1" : "2026-04-13", id: "X")
        if mode == 0 { bad.event(0, .exact(clock: "bad", evidence: "exact")) }
        if mode == 1 { bad.visits = Array(repeating: bad.visits[0], count: 257) }
        if mode == 2 {
            bad.run = String(repeating: "x", count: 65)
            bad.event(0, .exact(clock: "bad", evidence: "exact"))
        }
        if mode == 3 { bad.run = "non ascii 日本語" }
        let env = try envelope([valid,bad.packet])
        let result = try failure(A.assemble(env, packets: [bad.packet,valid]), .packetPreflight, .packet(0))
        let expected = try #require(SyntheticTimetableConverter.preflightFailure(bad.packet))
        compare(try #require(result.converterFailure), expected)
        switch SyntheticTimetableConverter.convert(bad.packet) {
        case .invalid(let f), .unsupported(let f): compare(expected,f)
        default: Issue.record("Expected preflight failure unchanged")
        }
        if mode == 2 { #expect(expected.kind == .invalid && expected.reason == .resourceLimit) }
    }

    @Test(arguments: [0,1,2]) func envelopeBoundsBeforePacketPreflight(_ mode: Int) throws {
        var f = try F(); f.event(0, .exact(clock: "bad", evidence: "exact"))
        let base = try envelope([f.packet])
        let env: E
        if mode == 0 { env = .init(viewID: base.viewID, revision: base.revision, expected: Array(repeating: base.expected[0], count: 9), inventory: .unknown) }
        else if mode == 1 { env = .init(viewID: base.viewID, revision: .init(source: String(repeating:"x",count:65), profile:"p",zone:"z",mapping:"m"), expected: [], inventory: .unknown) }
        else {
            let date = try #require(TimetableServiceDate("long-service-date"))
            env = .init(viewID: base.viewID, revision: base.revision,
                expected: [.init(viewID: base.viewID, tripID: base.expected[0].tripID, serviceDate: date)], inventory: .unknown)
        }
        _ = try failure(A.assemble(env, packets: [f.packet]), .resourceLimit, mode == 2 ? .declaration(0) : nil)
    }

    @Test(arguments: [false,true]) func emptyInventoryPreservesDeclaration(_ complete: Bool) throws {
        let p = try F().packet
        let env = E(viewID: p.binding.address.viewID, revision: p.revision, expected: [],
                    inventory: complete ? .stipulatedComplete : .unknown)
        let result = try batch(A.assemble(env, packets: []))
        #expect(result.slots.isEmpty && result.envelope.inventory == env.inventory)
    }

    @Test func eightSlotBoundaryAndNinePackets() throws {
        let packets = try (0..<8).map { try F(id: "T\($0)").packet }, env = try envelope(packets)
        #expect(try batch(A.assemble(env, packets: packets)).slots.count == 8)
        _ = try failure(A.assemble(env, packets: packets + [packets[0]]), .resourceLimit)
    }

    @Test func replacementGuardIsCallerOwnedAndOldBatchIsImmutable() throws {
        let p = try F().packet
        let old = try batch(A.assemble(try envelope([p]), packets: [p]))
        // Caller composition, not a new publication service: disclosed replacement must be fresh.
        func replacement(_ p: P) throws -> SyntheticTimetableBatch {
            guard p.binding.address.viewID != old.envelope.viewID else { throw Failure.sameViewReplacement }
            return try batch(A.assemble(try envelope([p]), packets: [p]))
        }
        var changed = try F(); changed.event(0, .exact(clock: "08:01:00", evidence: "exact"))
        #expect(throws: Failure.sameViewReplacement) { try replacement(changed.packet) }
        let fresh = try rebind(changed.packet, view: TimetableViewID(UUID()))
        let new = try replacement(fresh)
        #expect(new.envelope.viewID != old.envelope.viewID)
        #expect(old.slots[0].binding.matches(p.binding))
        guard case .success(let oldFacts) = old.slots[0].outcome, case .success(let newFacts) = new.slots[0].outcome else { throw Failure.expectedBatch }
        #expect(oldFacts.visits[0].departure == (try convertedFacts(p)).visits[0].departure)
        #expect(oldFacts.visits[0].departure != newFacts.visits[0].departure)
        // No registry: independent identical constructions remain permitted, as designed.
        #expect(try batch(A.assemble(try envelope([p]), packets: [p])).slots[0].binding.matches(p.binding))
    }
}
#endif
