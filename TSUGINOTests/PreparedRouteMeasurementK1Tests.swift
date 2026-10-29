#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// The §30.6 structural pass runs the same DEC-089 K1-only check as the composition, so it never
/// builds P (or feeds the exhaustive oracle) where the real search fails. Invented data only; the
/// worlds come from the K1 suite's fixtures.
struct PreparedRouteMeasurementK1Tests {
    let k1 = PreparedRouteK1ExclusionTests()
    var p: PreparedRouteFixture { k1.p }
    static let transferIDs = [["invented-a/invented-day/0-1", "invented-b/invented-day/0-1"]]

    /// One hooked composed call: harness class and last composition checkpoint.
    func hooked(_ c: PreparedRouteFixture.Case) async -> (PRSCall, String, PreparedRouteSearchStage?) {
        let trace = PRSStageTrace()
        let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: .init(checkpoint: { trace.mark($0) }))
        let call = await PRSHarness.call(searcher, c.request, watchdog: .seconds(600))
        let last = trace.all.last?.stage
        return (call, PRSHarness.fineClass(call, last: last), last)
    }
    func oracle(_ s: PRSHarness.Structural) -> [[String]]? {
        s.prepared.map { prepared in ExhaustivePreparedSolverOracle().winners(prepared).map { keys in
            keys.map { "\($0.address.tripID.rawValue)/\($0.address.serviceDate.label)/\($0.boardingIndex)-\($0.alightingIndex)" }
        } }
    }
    /// The K1 world with one K1-only key (0 same occurrence, 1 repeated visit, 2 cross-date) and `entry`.
    func k1Only(_ variant: Int, _ entry: PreparedRouteConnectionEntry?) throws -> PreparedRouteFixture.Case {
        let base = try k1.world()
        let k = k1.k1Keys(base)[variant]
        var c = k1.declaring(base, [k])
        c.parts.setEntry(k, entry)
        #expect(try k1.declarations(c).k1OnlyExcluded == [k])
        return c
    }

    /// (1, 5) A K1-only supplied positive fails both paths at the evidence step: the structural pass
    /// stops with the validator's typed failure and builds no P, so no exhaustive-oracle comparison
    /// can be reported, and the analytic success expectation is a class U mismatch, as for the call.
    @Test(arguments: 0...2) func k1OnlyPositiveFailsStructuralAndComposedPaths(_ variant: Int) async throws {
        let c = try k1Only(variant, .positive(try k1.qualifiedPositive(try k1.world())))
        let s = PRSHarness.structural(c)
        #expect(s.failedAt == "evidence trainChangeConflict")
        #expect(s.fields["failedAt"] as? String == "evidence trainChangeConflict")
        #expect(s.prepared == nil && s.assessmentBytes == nil && s.fields["assessmentBytes"] == nil)
        #expect(s.fields["targets"] as? Int == 1) // closure fields before the failure are unchanged
        #expect(oracle(s) == nil)
        let (call, fine, last) = await hooked(c)
        #expect(call.outcome == "R" && call.failure == "dataUnavailable" && last == .closure)
        #expect(PRSHarness.check(.success(Self.transferIDs), fine: fine, call: call, last: last) == "expected C, got R dataUnavailable")
    }

    /// (2) A K1-only absence with a contradictory relation (0), endpoint-wide (1) or event-independence
    /// (2) premise keeps its existing typed failure in the structural pass; the call is dataUnavailable.
    @Test(arguments: 0...2) func k1OnlyContradictoryAbsenceKeepsItsTypedFailure(_ variant: Int) async throws {
        let q: ConnectionEvidencePremise = .qualified(try k1.ref("invented-k1-absent"))
        let c = try k1Only(0, .absence(relation: variant == 0 ? .contradictory : q,
                                       endpointWideContext: variant == 1 ? .contradictory : q,
                                       eventIndependent: variant == 2 ? .contradictory : q))
        let s = PRSHarness.structural(c)
        #expect(s.failedAt == (variant == 0 ? "evidence qualificationConflict" : "evidence applicabilityConflict"))
        #expect(s.prepared == nil)
        let (call, _, last) = await hooked(c)
        #expect(call.failure == "dataUnavailable" && last == .closure)
    }

    /// (3) A K1-only qualified (0), insufficient (1) or unsupported (2) absence, under complete or unknown
    /// authority, is never accounted: P has no relation for the key and no absentUnderCompleteAuthority
    /// state, and structural pass, exhaustive oracle and call agree on the transfer route.
    @Test(arguments: 0...5) func k1OnlyAcceptedAbsenceCreatesNoNegativeEvidence(_ variant: Int) async throws {
        let premise: ConnectionEvidencePremise = switch variant % 3 {
        case 0: .qualified(try k1.ref("invented-k1-absent"))
        case 1: .insufficientEvidence
        default: .unsupported
        }
        var c = try k1Only(0, .absence(relation: premise, endpointWideContext: premise, eventIndependent: premise))
        c.parts.connections = .init(review: c.parts.connections.review, completeness: variant < 3 ? .declaredComplete : .unknown,
                                    entries: c.parts.connections.entries)
        let s = PRSHarness.structural(c)
        #expect(s.failedAt == nil)
        let prepared = try #require(s.prepared)
        let k = k1.k1Keys(c)[0]
        #expect(!prepared.connections.contains { $0.key == k })
        #expect(prepared.connections.allSatisfy { $0.state == .feasible })
        #expect((s.fields["relationsByState"] as? [String: Int]) == ["feasible": 1])
        #expect(oracle(s) == Self.transferIDs)
        let (call, fine, last) = await hooked(c)
        #expect(PRSHarness.check(.success(Self.transferIDs), fine: fine, call: call, last: last) == nil)
    }

    /// D4 still takes a same-Trip relation alighting outside the profile first: its supplied positive
    /// is never read, and both paths succeed with the transfer route.
    @Test func d4FirstRelationKeepsItsPositiveUnread() async throws {
        var c = k1.declaring(try k1.world(loopStops: ["H", "X", "H", "D"]), [])
        let k = k1.key(c, 3, 1, 3, 2)
        c = k1.declaring(c, [k])
        c.parts.setEntry(k, .positive(try k1.qualifiedPositive(c)))
        let b = c.profile
        c.profile = try p.f.need(InternalSearchProfileDefinition(identity: b.identity,
            stations: b.stations.subtracting([try p.station("X")]), lines: b.lines, trips: b.trips,
            maximumElapsedDuration: b.maximumElapsedDuration, maximumRailRides: b.maximumRailRides,
            connectionPolicy: b.connectionPolicy, serviceDateInterpretation: b.serviceDateInterpretation))
        #expect(try k1.declarations(c).k1OnlyExcluded.isEmpty)
        let s = PRSHarness.structural(c)
        #expect(s.failedAt == nil && oracle(s) == Self.transferIDs)
        let (call, fine, last) = await hooked(c)
        #expect(PRSHarness.check(.success(Self.transferIDs), fine: fine, call: call, last: last) == nil)
    }

    /// (6) With a K1-only positive present, existing failures still win in the structural pass as in
    /// the call: closure resourceLimit (0), evidence resourceLimit (1), contradictory required
    /// positive (2). Resource limits keep their I-prep classification at the same checkpoint.
    @Test(arguments: 0...2) func existingFailuresPrecedeTheK1CheckInTheStructuralPass(_ variant: Int) async throws {
        let base = try k1.world(extra: [k1.longTrip("invented-long-a"), k1.longTrip("invented-long-b")])
        let k = k1.k1Keys(base)[0]
        var c = k1.declaring(base, [k])
        c.parts.setEntry(k, .positive(try k1.qualifiedPositive(c)))
        switch variant {
        case 0:
            c.parts.dependencies = .init(reference: c.parts.dependencies.reference,
                unresolved: try (0...SearchInputClosureLimits.dependencies).map { try p.f.ref("invented-dependency-\($0)") })
        case 1:
            c = k1.declaring(c, (1...71).flatMap { a in (0...70).map { b in k1.key(c, 5, a, 6, b) } })
        default:
            c.parts.editPositive(c.firstKey) { e in .init(form: e.form, alighting: e.alighting, interchange: e.interchange,
                boarding: e.boarding, total: e.total, fromArrival: e.fromArrival, toDeparture: e.toDeparture,
                relation: .contradictory, genuineChange: e.genuineChange, componentPartition: e.componentPartition,
                endpointWideContext: e.endpointWideContext) }
        }
        let s = PRSHarness.structural(c)
        #expect(s.failedAt == ["closure resourceLimit", "evidence resourceLimit", "evidence qualificationConflict"][variant])
        let (call, fine, last) = await hooked(c)
        switch variant {
        case 0: #expect(fine == "I-prep" && last == .declarations)
        case 1: #expect(fine == "I-prep" && last == .closure)
        default: #expect(call.failure == "dataUnavailable" && last == .closure)
        }
    }

    /// The structural pass at the exact limits, with ten K1-only keys, mirrors the composition: 2,048
    /// required relations reach the assessment (2,047 held, so P is refused as not qualified) or stop
    /// at the K1 positive; 2,049 and 23,040 stop at the evidence count guard; 23,041 at the closure.
    @Test(arguments: [(2_048, false), (2_048, true), (2_049, true), (23_040, true), (23_041, true)])
    func structuralPassAtExactRelationLimits(_ required: Int, _ positive: Bool) throws {
        let (c, _) = try k1.boundaryCase(required: required, longTrips: required > 2_049 ? 4 : 2, k1: 10, positive: positive)
        let s = PRSHarness.structural(c)
        let expected = switch (required, positive) {
        case (2_048, false): "preparedInput assessmentNotQualified"
        case (2_048, true): "evidence trainChangeConflict"
        case (23_041, _): "closure resourceLimit"
        default: "evidence resourceLimit"
        }
        #expect(s.failedAt == expected)
        #expect(s.prepared == nil)
        #expect(s.fields["targets"] as? Int == required)
        if required == 2_048 && !positive { #expect(s.fields["remainingHolds"] as? Int == 2_047) }
    }

    /// (4) No §30 workload has a K1-only key, so the added check is a no-op for every one of them: the
    /// validator accepts the empty list and the structural pass never stops on a K1 failure.
    @Test func existingWorkloadsAreUnaffectedByTheK1Check() throws {
        for workload in PreparedRouteWorkloads.matrix {
            let c = try workload.build(p)
            let d = try k1.declarations(c)
            #expect(d.k1OnlyExcluded.isEmpty, "\(workload.id)")
            #expect(throws: Never.self) { try PreparedRouteK1Validator.validate(d.k1OnlyExcluded, authority: c.view.connections) }
            let s = PRSHarness.structural(c)
            #expect(!(s.failedAt ?? "").contains("trainChangeConflict"), "\(workload.id)")
        }
    }
}
#endif
