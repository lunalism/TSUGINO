import Foundation
import Testing
@testable import TSUGINO

/// Entirely invented railway world. Opaque day labels, zero-pattern UUIDs and
/// repeated fake digests; no provider/source/calendar/clock or private fixtures.
struct QualifiedConnectionEvidenceTests {
    private func need<T>(_ value: T?) throws -> T { try #require(value) }
    private func uuid(_ n: UInt8) -> UUID { UUID(uuid: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,n)) }
    private func ref(_ s: String = "invented-evidence") throws -> TimetableQualificationReference {
        try need(TimetableQualificationReference(s))
    }
    private func instant(_ n: Double) throws -> TimetableInstant { try need(.init(Date(timeIntervalSinceReferenceDate: n))) }
    private func allowance(_ total: Double = 60) throws -> ConnectionAllowance {
        try .init(alighting: 0, interchange: total, boarding: 0, total: total)
    }
    private func trip(_ name: String, stops: [String], line: String = "invented-line", service: Bool = false,
                      coverage: Bool = false) throws -> Trip {
        try need(Trip(id: need(TripID(name)), stopSequence: stops.map { try need(StationID($0)) },
            lineSegments: [need(.init(lineID: need(LineID(line)), startIndex: 0, endIndex: stops.count - 1))],
            coverage: .init(includesServiceOrigin: coverage, includesServiceDestination: false),
            serviceTypeSegments: service ? [need(.init(serviceTypeID: need(ServiceTypeID("invented-service")),
                startIndex: 0, endIndex: stops.count - 1))] : []))
    }
    private struct World {
        let from: TimetableOccurrenceBinding
        let to: TimetableOccurrenceBinding
        let scope: InternalSearchScope
        let qualification: TimetableInventoryQualification
    }
    private func world(from: Trip? = nil, to: Trip? = nil, day: String = "invented-opaque-day",
                       view: UInt8 = 1, profileRevision: UInt8 = 2, policy: UInt8 = 3,
                       interpretation: UInt8 = 4, lower: Double = 100, duration: Double = 4000,
                       review: String = "invented-inventory-review", staticVersion: String = "invented-static",
                       staticHash: String = String(repeating: "a", count: 64),
                       extraStation: Bool = false, reverseRequest: Bool = false) throws -> World {
        let f = try from ?? trip("invented-from", stops: ["invented-origin","invented-mid","invented-hub","invented-tail"])
        let t = try to ?? trip("invented-to", stops: ["invented-hub","invented-next","invented-more","invented-end"])
        let v = TimetableViewID(uuid(view))
        let railway = RailwayArtifactRevision(dataVersion: try need(ExactValue(staticVersion)), registryRevision: 0,
            inputs: [], contentSHA256: staticHash, previousSHA256: nil)
        let q = try need(TimetableInventoryQualification(viewID: v, source: ref("invented-source"),
            profile: ref("invented-source-profile"), zone: ref("invented-zone"), mapping: ref("invented-mapping"),
            review: ref(review), railway: railway))
        var stations = Set(f.stopSequence + t.stopSequence)
        if extraStation { stations.insert(try need(StationID("invented-extra"))) }
        let profile = try need(InternalSearchProfileDefinition(identity: .init(key: uuid(5), revision: uuid(profileRevision)),
            stations: stations, lines: Set((f.lineSegments + t.lineSegments).map(\.lineID)), trips: Set([f.id,t.id]),
            maximumElapsedDuration: duration, maximumRailRides: 3,
            connectionPolicy: .init(key: uuid(6), revision: uuid(policy)),
            serviceDateInterpretation: .init(key: uuid(7), revision: uuid(interpretation))))
        let request = try need(RouteSearchRequest(origin: reverseRequest ? t.stopSequence.last! : f.stopSequence[0],
            destination: reverseRequest ? f.stopSequence[0] : t.stopSequence.last!,
            departNotBefore: Date(timeIntervalSinceReferenceDate: lower)))
        let scope = try need(InternalSearchScope(profile: profile, request: request, viewID: v))
        return try World(from: need(.init(address: .init(viewID: v, tripID: f.id, serviceDate: need(.init(day))), trip: f)),
            to: need(.init(address: .init(viewID: v, tripID: t.id, serviceDate: need(.init(day))), trip: t)),
            scope: scope, qualification: q)
    }
    private func key(_ w: World, a: Int = 2, b: Int = 0, reverse: Bool = false) -> ConnectionRelationKey {
        .init(from: reverse ? w.to.address : w.from.address, alightingIndex: a,
              to: reverse ? w.from.address : w.to.address, boardingIndex: b)
    }
    private func applicability(_ w: World, name: String = "invented-connection-domain") throws -> SearchInputClosureApplicability {
        try .init(reference: ref(name), scope: w.scope, qualification: w.qualification)
    }
    private func qualification(_ w: World, name: String = "invented-connection-domain",
                               review: String = "invented-connection-review") throws -> ConnectionEvidenceQualification {
        try .init(applicability: applicability(w, name: name), policy: w.scope.profile.connectionPolicy, review: ref(review))
    }
    private func positive(_ w: World, key: ConnectionRelationKey? = nil, form: ConnectionForm = .sameStation,
                          total: Double = 60, fromBase: Double = 100, toBase: Double = 200,
                          relation: ConnectionEvidencePremise? = nil, change: ConnectionEvidencePremise? = nil,
                          partition: ConnectionEvidencePremise? = nil, context: ConnectionEvidencePremise? = nil)
        throws -> ConnectionEvidenceState {
        let k = key ?? self.key(w)
        return try .qualifyingPositive(form: form, allowance: allowance(total),
            fromArrival: instant(fromBase + Double(k.alightingIndex * 10)),
            toDeparture: instant(toBase + Double(k.boardingIndex * 10) + 1),
            relation: relation ?? .qualified(ref("invented-directional-relation")),
            genuineChange: change ?? .qualified(ref("invented-genuine-change")),
            componentPartition: partition ?? .qualified(ref("invented-components-once")),
            endpointWideContext: context ?? .qualified(ref("invented-endpoint-wide")))
    }
    private func negative(context: ConnectionEvidencePremise? = nil,
                          time: ConnectionEvidencePremise? = nil) throws -> ConnectionEvidenceState {
        try .qualifyingAbsence(relation: .qualified(ref("invented-negative-relation")),
            endpointWideContext: context ?? .qualified(ref("invented-negative-context")),
            eventIndependent: time ?? .qualified(ref("invented-event-independent")))
    }
    private func record(_ w: World, key: ConnectionRelationKey? = nil, state: ConnectionEvidenceState? = nil,
                        from: TimetableOccurrenceBinding? = nil, to: TimetableOccurrenceBinding? = nil,
                        target: String = "invented-connection-domain", review: String = "invented-connection-review")
        throws -> ConnectionEvidenceRecord {
        try .init(key: key ?? self.key(w), fromBinding: from ?? w.from, toBinding: to ?? w.to,
            targetApplicability: ref(target), review: ref(review), state: state ?? positive(w))
    }
    private func view(_ w: World, records: [ConnectionEvidenceRecord]? = nil, keys: [ConnectionRelationKey]? = nil,
                      completeness: TimetableInventoryCompleteness = .declaredComplete,
                      qualification: ConnectionEvidenceQualification? = nil) throws -> QualifiedConnectionEvidenceView {
        let records = try records ?? [record(w)]
        return try .init(qualification: qualification ?? self.qualification(w), declaredKeys: keys ?? records.map(\.key),
            completeness: completeness, records: records)
    }
    // kinds: 0 active; 1 inactive; 2 unsupported; 3 insufficient; 4 unloaded.
    private func slot(_ w: World, binding: TimetableOccurrenceBinding, base: Double, kind: Int,
                      endpoint: Int, arrival: Bool, time: Int, permission: Int,
                      intervalUnknown: Bool = false) throws -> TimetableOccurrenceInventorySlot {
        let state: TimetableInventoryOccurrenceState
        switch kind {
        case 1: state = .inactive
        case 2: state = .unavailable(.unsupported)
        case 3: state = .unavailable(.insufficientEvidence)
        default:
            let visits = try binding.trip.stopSequence.indices.map { i in
                let a = try instant(base + Double(i * 10)), d = try instant(base + Double(i * 10) + 1)
                let modified: TimetableTime = time == 1 ? .missing : time == 2 ? .estimated(arrival ? a : d) : .exact(arrival ? a : d)
                let eligibility: TimetableEligibility = permission == 1 ? .unknown : permission == 2 ? .prohibited : .allowed
                return try need(TimetableVisitFacts(binding: binding, originalIndex: i,
                    arrival: i == endpoint && arrival ? modified : .exact(a),
                    departure: i == endpoint && !arrival ? modified : .exact(d),
                    boarding: i == endpoint && !arrival ? eligibility : .allowed,
                    alighting: i == endpoint && arrival ? eligibility : .allowed))
            }
            let intervals: [TimetableVerifiedRideInterval] = intervalUnknown ? [] : [.init(boardingIndex: 0, alightingIndex: binding.trip.stopSequence.count - 1)]
            state = try .active(need(.init(binding: binding, visits: visits)),
                .init(binding: binding, authority: ref("invented-interval"), completeness: intervalUnknown ? .unknown : .declaredComplete,
                    declared: intervals))
        }
        return .init(qualification: w.qualification, binding: binding, state: state)
    }
    private func closure(_ w: World, keys: [ConnectionRelationKey]? = nil, fromKind: Int = 0, toKind: Int = 0,
                         fromTime: Int = 0, toTime: Int = 0, fromPermission: Int = 0, toPermission: Int = 0,
                         fromBase: Double = 100, toBase: Double = 200,
                         domainUnknown: Bool = false, occurrenceUnknown: Bool = false,
                         intervalUnknown: Bool = false, dependency: Bool = false) throws -> RequestScopedSearchInputClosure {
        let keys = keys ?? [key(w)]
        var slots: [TimetableOccurrenceInventorySlot] = []
        if fromKind != 4 { slots.append(try slot(w, binding: w.from, base: fromBase, kind: fromKind,
            endpoint: keys.first?.alightingIndex ?? 2, arrival: true, time: fromTime, permission: fromPermission,
            intervalUnknown: intervalUnknown)) }
        if toKind != 4 { slots.append(try slot(w, binding: w.to, base: toBase, kind: toKind,
            endpoint: keys.first?.boardingIndex ?? 0, arrival: false, time: toTime, permission: toPermission)) }
        let inventory = try TimetableOccurrenceInventoryView(qualification: w.qualification,
            declaredAddresses: slots.map(\.binding.address), completeness: .declaredComplete, suppliedSlots: slots)
        let requirements = try [w.from,w.to].map { binding in
            SearchInputOccurrenceRequirement(binding: binding, applicabilityReference: try ref("invented-occurrences"),
                intervalAuthority: try ref("invented-interval"),
                intervals: [.init(boardingIndex: 0, alightingIndex: binding.trip.stopSequence.count - 1)])
        }
        return try .init(scope: w.scope, inventory: inventory, railway: w.qualification.railway,
            occurrences: .init(applicability: applicability(w, name: "invented-occurrences"),
                completeness: occurrenceUnknown ? .unknown : .declaredComplete, required: requirements),
            connections: .init(applicability: applicability(w), completeness: domainUnknown ? .unknown : .declaredComplete,
                required: keys.map { .init(from: $0.from, alightingIndex: $0.alightingIndex,
                    to: $0.to, boardingIndex: $0.boardingIndex, applicabilityReference: try ref("invented-connection-domain")) }),
            dependencies: .init(applicability: applicability(w, name: "invented-dependencies"),
                unresolved: dependency ? [ref("invented-external-dependency")] : []))
    }
    private func rejects(_ error: ConnectionEvidenceFailure, _ body: () throws -> Void) {
        do { try body(); Issue.record("Expected \(error)") }
        catch let actual as ConnectionEvidenceFailure { #expect(actual == error) }
        catch { Issue.record("Unexpected error: \(error)") }
    }

    @Test func positiveResolutionIsImmutableLocalAccountingOnly() throws {
        let w = try world(), b = try closure(w), a = try view(w)
        let result = try ResolvedSearchInputAssessment(closure: b, connections: a)
        #expect(result.connectionAccounting == [.present]); #expect(result.remainingHolds.isEmpty)
        #expect(result.isTechnicallyQualified); #expect(b.holds == [.connectionUnresolved(0)])
        #expect(!b.isTechnicallyQualified); #expect(result.closure.holds == b.holds)
        #expect(result.connections.records.count == a.records.count)
        #expect(result.connections.records[0].fromBinding.matches(a.records[0].fromBinding))
        func send<T: Sendable>(_: T) {}
        send(result); send(a); send(result.connectionAccounting)
        // No route candidate, result, gap verdict, source authentication or search completion.
    }
    @Test func explicitWalkingDerivesDistinctAnchors() throws {
        let w = try world(), k = key(w, a: 3)
        let a = try view(w, records: [record(w, key: k, state: positive(w, key: k, form: .walking))])
        let result = try ResolvedSearchInputAssessment(closure: closure(w, keys: [k]), connections: a)
        #expect(result.connectionAccounting == [.present])
        #expect(a.records[0].fromBinding.trip.stopSequence[k.alightingIndex] != a.records[0].toBinding.trip.stopSequence[k.boardingIndex])
    }
    @Test(arguments: [ConnectionForm.sameStation, .walking])
    func formCannotRelabelDerivedAnchors(_ form: ConnectionForm) throws {
        let w = try world(), k = key(w, a: form == .sameStation ? 3 : 2)
        rejects(.formConflict) { _ = try view(w, records: [record(w, key: k, state: positive(w, key: k, form: form))]) }
    }
    @Test func reverseIsDistinctAndNeverInferred() throws {
        let w = try world(), forward = key(w), reverse = key(w, a: 1, b: 1, reverse: true)
        #expect(forward != reverse)
        let a = try view(w, records: [record(w, key: reverse, state: .unavailable(.unsupported), from: w.to, to: w.from)])
        rejects(.targetConflict) { _ = try ResolvedSearchInputAssessment(closure: closure(w), connections: a) }
        #expect(try view(w, records: [], keys: []).records.isEmpty) // Station equality creates nothing.
    }
    @Test(arguments: [false,true])
    func sameRecurringTripCannotBecomeTransfer(_ lineChange: Bool) throws {
        let w = try world()
        let t: Trip
        if lineChange {
            t = try need(.init(id: w.from.trip.id, stopSequence: w.from.trip.stopSequence,
                lineSegments: [need(.init(lineID: need(LineID("invented-line")), startIndex: 0, endIndex: 2)),
                    need(.init(lineID: need(LineID("invented-second-line")), startIndex: 2, endIndex: 3))],
                coverage: w.from.trip.coverage, serviceTypeSegments: []))
        } else { t = w.from.trip }
        let binding = try need(TimetableOccurrenceBinding(address: w.from.address, trip: t))
        let k = ConnectionRelationKey(from: binding.address, alightingIndex: 2, to: binding.address, boardingIndex: 2)
        rejects(.trainChangeConflict) { _ = try view(w, records: [record(w, key: k, from: binding, to: binding)]) }
    }
    @Test(arguments: [0,1,2,3])
    func knownContradictoryPremisesReject(_ field: Int) throws {
        let w = try world()
        rejects([.qualificationConflict,.trainChangeConflict,.allowanceConflict,.applicabilityConflict][field]) {
            _ = try positive(w, relation: field == 0 ? .contradictory : nil,
                change: field == 1 ? .contradictory : nil, partition: field == 2 ? .contradictory : nil,
                context: field == 3 ? .contradictory : nil)
        } // Includes known through-continuity and double-counted/omitted partition contradictions.
    }
    @Test(arguments: [0,1,2,3], [false,true])
    func missingPositivePremiseRemainsUnavailable(_ field: Int, _ unsupported: Bool) throws {
        let w = try world(), premise: ConnectionEvidencePremise = unsupported ? .unsupported : .insufficientEvidence
        let state = try positive(w, relation: field == 0 ? premise : nil, change: field == 1 ? premise : nil,
            partition: field == 2 ? premise : nil, context: field == 3 ? premise : nil)
        let result = try ResolvedSearchInputAssessment(closure: closure(w), connections: view(w, records: [record(w,state:state)]))
        #expect(result.connectionAccounting == [.held(unsupported ? .unsupported : .insufficientEvidence)])
        #expect(result.remainingHolds == [.connectionUnresolved(0)])
    }
    @Test func contradictionIsNotHiddenBehindMissingPremise() throws {
        let w = try world()
        rejects(.trainChangeConflict) { _ = try positive(w, relation: .insufficientEvidence, change: .contradictory) }
    }
    @Test func zeroAndOrdinaryPartitionRequireExplicitAssociation() throws {
        let ordinary = try ConnectionAllowance(alighting: 10, interchange: 20, boarding: 30, total: 60)
        #expect(ordinary.total == 60)
        let zero = try ConnectionAllowance(alighting: -0.0, interchange: -0.0, boarding: -0.0, total: -0.0)
        #expect([zero.alighting,zero.interchange,zero.boarding,zero.total].allSatisfy { $0 == 0 && $0.sign == .plus })
        let w = try world()
        #expect(try ResolvedSearchInputAssessment(closure: closure(w), connections: view(w,records:[record(w,state:positive(w,total:0))])).isTechnicallyQualified)
        // A zero allowance alone has no connection identity, context or train-change premise.
    }
    @Test(arguments: [-1.0, Double.nan, Double.infinity, -Double.infinity], [0,1,2,3])
    func invalidAllowanceFieldRejects(_ value: Double, _ field: Int) {
        var values = [0.0,0,0,0]; values[field] = value
        rejects(.allowanceConflict) { _ = try ConnectionAllowance(alighting: values[0], interchange: values[1], boarding: values[2], total: values[3]) }
    }
    @Test(arguments: [0,1,2,3])
    func inexactMismatchAndOverflowReject(_ kind: Int) {
        let large = 9_007_199_254_740_992.0
        let values: [[Double]] = [[1,2,3,7],[large,1,0,large],[large,0,1,large],[.greatestFiniteMagnitude,.greatestFiniteMagnitude,0,.greatestFiniteMagnitude]]
        let v = values[kind]
        rejects(.allowanceConflict) { _ = try ConnectionAllowance(alighting:v[0],interchange:v[1],boarding:v[2],total:v[3]) }
    }
    @Test(arguments: [TimetableInventoryCompleteness.declaredComplete,.unknown])
    func explicitAbsenceNeedsCompleteNegativeAuthority(_ completeness: TimetableInventoryCompleteness) throws {
        let w = try world(), b = try closure(w)
        let result = try ResolvedSearchInputAssessment(closure:b,connections:view(w,records:[record(w,state:negative())],completeness:completeness))
        #expect(result.connectionAccounting == [completeness == .declaredComplete ? .absentUnderCompleteAuthority : .held(.negativeScopeUnknown)])
        #expect(result.isTechnicallyQualified == (completeness == .declaredComplete))
    }
    @Test(arguments: [0,1,2,3,4])
    func EventIndependentNegativeDoesNotInventActiveInstants(_ kind: Int) throws {
        let w = try world(), b = try closure(w,fromKind:kind,fromTime:1)
        let result = try ResolvedSearchInputAssessment(closure:b,connections:view(w,records:[record(w,state:negative())]))
        #expect(result.connectionAccounting == [.absentUnderCompleteAuthority])
        #expect(result.remainingHolds == b.holds.filter { $0 != .connectionUnresolved(0) })
    }
    @Test(arguments: [false,true])
    func timeDependentOrUnknownNegativeRemainsHeld(_ unsupported: Bool) throws {
        let w = try world()
        let state = try negative(time:unsupported ? .unsupported : .insufficientEvidence)
        let result = try ResolvedSearchInputAssessment(closure:closure(w),connections:view(w,records:[record(w,state:state)]))
        #expect(result.connectionAccounting == [.held(unsupported ? .unsupported : .insufficientEvidence)])
    }
    @Test(arguments: [TimetableInventoryCompleteness.declaredComplete,.unknown])
    func emptyEvidenceScopeDoesNotInventRequiredness(_ completeness: TimetableInventoryCompleteness) throws {
        let w = try world(), a = try view(w,records:[],keys:[],completeness:completeness)
        #expect(a.completeness == completeness)
        rejects(.targetConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w),connections:a) }
        let result = try ResolvedSearchInputAssessment(closure:closure(w,keys:[],domainUnknown:true),connections:a)
        #expect(result.remainingHolds == [.connectionDomainUnknown]); #expect(!result.isTechnicallyQualified)
    }
    @Test(arguments: [0,1,2,3])
    func declarationRequiresExactlyOneExplicitRecord(_ kind: Int) throws {
        let w = try world(), r = try record(w), k = key(w)
        rejects(.declarationConflict) {
            switch kind {
            case 0: _ = try view(w,records:[r],keys:[k,k])
            case 1: _ = try view(w,records:[r,r],keys:[k])
            case 2: _ = try view(w,records:[],keys:[k])
            default: _ = try view(w,records:[r],keys:[])
            }
        }
    }
    @Test func contradictoryDuplicateDoesNotLastWin() throws {
        let w = try world()
        rejects(.declarationConflict) { _ = try view(w,records:[record(w),record(w,state:negative())],keys:[key(w)]) }
    }
    @Test(arguments: [0,1,2,3,4,5,6,7,8,9,10])
    func exactGenerationCompatibility(_ variant: Int) throws {
        let base = try world(), changed: World
        switch variant {
        case 0: changed = try world(view:9)
        case 1: changed = try world(profileRevision:9)
        case 2: changed = try world(policy:9)
        case 3: changed = try world(interpretation:9)
        case 4: changed = try world(lower:101)
        case 5: changed = try world(duration:4001)
        case 6: changed = try world(review:"invented-other-review")
        case 7: changed = try world(staticVersion:"invented-other-static")
        case 8: changed = try world(staticHash:String(repeating:"b",count:64))
        case 9: changed = try world(extraStation:true)
        default: changed = try world(reverseRequest:true)
        }
        rejects(.qualificationConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(base),connections:view(changed)) }
    }
    @Test func qualificationCannotPretendDifferentPolicyMatches() throws {
        let w = try world()
        rejects(.policyConflict) { _ = try ConnectionEvidenceQualification(applicability:applicability(w),
            policy:.init(key:uuid(6),revision:uuid(99)),review:ref()) }
    }
    @Test(arguments: [false,true])
    func recordAuthorityMustMatchExactly(_ target: Bool) throws {
        let w = try world()
        rejects(.qualificationConflict) { _ = try view(w,records:[record(w,target:target ? "invented-wrong" : "invented-connection-domain",
            review:target ? "invented-connection-review" : "invented-wrong")]) }
    }
    @Test(arguments: [-1,0,4,Int.max])
    func originalAlightingIndexValidatedBeforeIndexing(_ index: Int) throws {
        let w = try world()
        rejects(.targetConflict) { _ = try view(w,records:[record(w,key:key(w,a:index),state:.unavailable(.unsupported))]) }
    }
    @Test(arguments: [-1,3,Int.max])
    func originalBoardingIndexValidatedBeforeIndexing(_ index: Int) throws {
        let w = try world()
        rejects(.targetConflict) { _ = try view(w,records:[record(w,key:key(w,b:index),state:.unavailable(.unsupported))]) }
    }
    @Test(arguments: [0,1,2,3], [false,true])
    func fullSnapshotsMatchEvenForNegativeOrUnloaded(_ variant: Int, _ changeTo: Bool) throws {
        let w = try world(), original = changeTo ? w.to : w.from
        var names = original.trip.stopSequence.map(\.rawValue)
        if variant == 0 { names[names.count-1] = "invented-changed-stop" }
        let changed = try trip(original.trip.id.rawValue,stops:names,
            line:variant == 1 ? "invented-changed-line" : "invented-line",service:variant == 2,coverage:variant == 3)
        let binding = try need(TimetableOccurrenceBinding(address:original.address,trip:changed))
        let r = try record(w,state:negative(),from:changeTo ? nil : binding,to:changeTo ? binding : nil)
        rejects(.snapshotConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w,fromKind:4,toKind:4),connections:view(w,records:[r])) }
    }
    @Test func sameTripConflictsAcrossRecordsAndDatesReject() throws {
        let w = try world(), changed = try trip("invented-from",stops:["invented-origin","invented-mid","invented-hub","invented-different"])
        let binding = try need(TimetableOccurrenceBinding(address:.init(viewID:w.scope.viewID,tripID:changed.id,
            serviceDate:need(.init("invented-other-day"))),trip:changed))
        let k = ConnectionRelationKey(from:binding.address,alightingIndex:2,to:w.to.address,boardingIndex:1)
        rejects(.snapshotConflict) { _ = try view(w,records:[record(w),record(w,key:k,state:.unavailable(.unsupported),from:binding)]) }
    }
    @Test(arguments: [false,true], [1,2])
    func missingOrEstimatedEndpointRetainsHold(_ from: Bool, _ time: Int) throws {
        let w = try world(), result = try ResolvedSearchInputAssessment(closure:closure(w,fromTime:from ? time : 0,toTime:from ? 0 : time),connections:view(w))
        #expect(result.connectionAccounting == [.held(.exactEventMissing)])
        #expect(result.remainingHolds == [.connectionUnresolved(0)])
    }
    @Test(arguments: [false,true])
    func unknownPermissionRetainsHoldAndProhibitionConflicts(_ from: Bool) throws {
        let w = try world(), held = try closure(w,fromPermission:from ? 1 : 0,toPermission:from ? 0 : 1)
        #expect(try ResolvedSearchInputAssessment(closure:held,connections:view(w)).connectionAccounting == [.held(.permissionUnknown)])
        rejects(.endpointConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w,fromPermission:from ? 2 : 0,toPermission:from ? 0 : 2),connections:view(w)) }
    }
    @Test(arguments: [false,true])
    func staleExactEndpointRejects(_ from: Bool) throws {
        let w = try world()
        rejects(.applicabilityConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w,fromBase:from ? 101 : 100,toBase:from ? 200 : 201),connections:view(w)) }
    }
    @Test func heldEndpointDoesNotHideOtherKnownContradiction() throws {
        let w = try world()
        rejects(.applicabilityConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w,fromTime:1,toBase:201),connections:view(w)) }
    }
    @Test(arguments: [1,2,3,4], [false,true])
    func nonactiveEndpointsNeverResolvePositive(_ kind: Int, _ from: Bool) throws {
        let w = try world(), b = try closure(w,fromKind:from ? kind : 0,toKind:from ? 0 : kind)
        let result = try ResolvedSearchInputAssessment(closure:b,connections:view(w))
        let reasons: [ConnectionAssessmentHold] = [.endpointInactive,.endpointUnsupported,.endpointInsufficientEvidence,.endpointNotLoaded]
        #expect(result.connectionAccounting == [.held(reasons[kind-1])]); #expect(result.remainingHolds == b.holds)
    }
    @Test func exactIndexAndAddressSetsCannotBeSubstituted() throws {
        let w = try world(), changedKey = key(w,b:1)
        let a = try view(w,records:[record(w,key:changedKey,state:negative())])
        rejects(.targetConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w),connections:a) }
        let extra = try view(w,records:[record(w),record(w,key:changedKey,state:negative())])
        rejects(.targetConflict) { _ = try ResolvedSearchInputAssessment(closure:closure(w),connections:extra) }
    }
    @Test func accountingUsesBOrderAndRemovesOnlyResolvedIndices() throws {
        let w = try world(), k0 = key(w), k1 = key(w,a:3), k2 = key(w,a:1,b:1)
        let b = try closure(w,keys:[k0,k1,k2],domainUnknown:true,occurrenceUnknown:true,intervalUnknown:true,dependency:true)
        let a = try view(w,records:[record(w,key:k2,state:.unavailable(.unsupported)),
            record(w,key:k1,state:negative()),record(w)])
        let result = try ResolvedSearchInputAssessment(closure:b,connections:a)
        #expect(result.connectionAccounting == [.present,.absentUnderCompleteAuthority,.held(.unsupported)])
        #expect(result.remainingHolds == b.holds.filter { $0 != .connectionUnresolved(0) && $0 != .connectionUnresolved(1) })
        #expect(result.remainingHolds.contains(.connectionDomainUnknown)); #expect(result.remainingHolds.contains(.intervalUnknown(occurrence:0,interval:0)))
        #expect(result.remainingHolds.contains(.dependencyUnresolved(0))); #expect(!result.isTechnicallyQualified)
    }
    @Test func allConnectionsResolvedCannotRepairUnknownRequiredDomain() throws {
        let w = try world(), result = try ResolvedSearchInputAssessment(closure:closure(w,domainUnknown:true),connections:view(w))
        #expect(result.remainingHolds == [.connectionDomainUnknown]); #expect(!result.isTechnicallyQualified)
    }
    @Test(arguments: [150.0,1000.0])
    func evidenceResolutionDoesNotEvaluateTrainGap(_ toBase: Double) throws {
        let w = try world(), a = try view(w,records:[record(w,state:positive(w,total:300,toBase:toBase))])
        let result = try ResolvedSearchInputAssessment(closure:closure(w,toBase:toBase),connections:a)
        #expect(result.connectionAccounting == [.present]); #expect(result.isTechnicallyQualified)
        // Short and long invented schedules both resolve evidence. No gap helper/API is present.
    }
    @Test func positiveMayResolveUnderUnknownEvidenceScope() throws {
        let w = try world()
        #expect(try ResolvedSearchInputAssessment(closure:closure(w),connections:view(w,completeness:.unknown)).connectionAccounting == [.present])
    }

    private func maximumWorld(stops: Int = 72, textBytes: Int = 192) throws -> World {
        func text(_ prefix: String) -> String { prefix + String(repeating:"x",count:max(0,textBytes-prefix.utf8.count)) }
        func make(_ side: String) throws -> Trip {
            try need(Trip(id:need(TripID(text("invented-max-\(side)-trip-"))),
                stopSequence:(0..<stops).map { try need(StationID(text("invented-max-\(side)-stop-\($0)-"))) },
                lineSegments:(0..<(stops-1)).map { try need(TripLineSegment(lineID:need(LineID(text("invented-max-\(side)-line-\($0)-"))),startIndex:$0,endIndex:$0+1)) },
                coverage:.init(includesServiceOrigin:false,includesServiceDestination:false),
                serviceTypeSegments:(0..<(stops-1)).map { try need(TripServiceTypeSegment(serviceTypeID:need(ServiceTypeID(text("invented-max-\(side)-service-\($0)-"))),startIndex:$0,endIndex:$0+1)) }))
        }
        return try world(from:make("from"),to:make("to"),day:text("invented-max-day-"))
    }
    @Test func generatedMaximumActualViewAndAssessmentAndPlusOne() throws {
        let w = try maximumWorld(), n = ConnectionEvidenceLimits.relations
        let keys = (0..<n).map { key(w,a:1+$0/71,b:$0%71) }
        let records = try keys.map { k in try record(w,key:k,state:positive(w,key:k,form:.walking)) }
        let a = try view(w,records:records)
        #expect(a.records.count == 2048); #expect(a.logicalPayloadBytes <= ConnectionEvidenceLimits.viewPayloadBytes)
        let b = try closure(w,keys:keys)
        let assessment = try ResolvedSearchInputAssessment(closure:b,connections:a)
        #expect(assessment.connectionAccounting == Array(repeating:.present,count:n))
        #expect(assessment.isTechnicallyQualified); #expect(!b.isTechnicallyQualified)
        #expect(assessment.logicalPayloadBytes <= ConnectionEvidenceLimits.assessmentPayloadBytes)
        let extraKey = key(w,a:1+n/71,b:n%71)
        rejects(.resourceLimit) { _ = try view(w,records:records,keys:keys+[extraKey]) }
        rejects(.resourceLimit) { _ = try view(w,records:records+[records[0]],keys:keys) }
        let largerB = try closure(w,keys:keys+[extraKey])
        rejects(.resourceLimit) { _ = try ResolvedSearchInputAssessment(closure:largerB,connections:a) }
    }
    @Test func oversizedTopLevelRejectsBeforeHostileBinding() throws {
        let w = try maximumWorld(stops:73), r = try record(w,state:.unavailable(.unsupported))
        rejects(.resourceLimit) { _ = try view(w,records:Array(repeating:r,count:ConnectionEvidenceLimits.relations+1),keys:[]) }
    }
    @Test(arguments: [72,73], [192,193])
    func inheritedSnapshotAndActualTextBounds(_ stops: Int, _ bytes: Int) throws {
        let w = try maximumWorld(stops:stops,textBytes:bytes)
        if stops == 72 && bytes == 192 { #expect(try view(w,records:[record(w,state:.unavailable(.unsupported))]).records.count == 1) }
        else { rejects(.resourceLimit) { _ = try view(world(),records:[record(w,state:.unavailable(.unsupported))]) } }
    }
    @Test func canonicallyEqualKeySpellingStillBoundedBeforeHashing() throws {
        let composed = String(repeating:"é",count:65), decomposed = String(repeating:"e\u{301}",count:65)
        #expect(composed == decomposed); #expect(composed.utf8.count < decomposed.utf8.count)
        let w = try world(from:trip(composed,stops:["invented-origin","invented-mid","invented-hub","invented-tail"]))
        let address = TimetableOccurrenceAddress(viewID:w.scope.viewID,tripID:try need(TripID(decomposed)),serviceDate:w.from.address.serviceDate)
        let k = ConnectionRelationKey(from:address,alightingIndex:2,to:w.to.address,boardingIndex:0)
        rejects(.resourceLimit) { _ = try view(w,records:[record(w,key:k)]) }
    }
    @Test func allRetainedReferenceCopiesUseExistingExactBound() throws {
        let w = try world(), token = String(repeating:"q",count:192), q = try ref(token)
        let state = try ConnectionEvidenceState.qualifyingPositive(form:.sameStation,allowance:allowance(),
            fromArrival:instant(120),toDeparture:instant(201),relation:.qualified(q),genuineChange:.qualified(q),
            componentPartition:.qualified(q),endpointWideContext:.qualified(q))
        let qualification = try self.qualification(w,name:token,review:token)
        let a = try view(w,records:[record(w,state:state,target:token,review:token)],qualification:qualification)
        #expect(a.logicalPayloadBytes > (try view(w)).logicalPayloadBytes)
        #expect(TimetableQualificationReference(String(repeating:"q",count:193)) == nil)
    }
    @Test(arguments: [false,true])
    func logicalPayloadExactBoundaryAndOverflow(_ assessment: Bool) throws {
        let limit = assessment ? ConnectionEvidenceLimits.assessmentPayloadBytes : ConnectionEvidenceLimits.viewPayloadBytes
        var budget = ConnectionEvidencePayloadBudget(limit:limit)
        try budget.include(limit); #expect(budget.used == limit)
        rejects(.resourceLimit) { try budget.include(1) }
        rejects(.resourceLimit) { try budget.include(Int.max) }
        rejects(.resourceLimit) { try budget.include(-1) }
        #expect(budget.used == limit)
    }
    @Test func mismatchedBindingAddressRejectsBeforeAnchorUse() throws {
        let w = try world(), other = try world(day:"invented-other-day")
        rejects(.targetConflict) { _ = try view(w,records:[record(w,from:other.from)]) }
    }
    @Test func positiveUnsupportedDominatesUnprovedButNotContradiction() throws {
        let w = try world(), state = try positive(w,relation:.insufficientEvidence,context:.unsupported)
        if case .unavailable(.unsupported) = state {} else { Issue.record("Expected unsupported") }
        rejects(.allowanceConflict) { _ = try positive(w,relation:.unsupported,partition:.contradictory) }
    }
}
