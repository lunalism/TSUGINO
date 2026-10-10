import Foundation
import Testing
@testable import TSUGINO

/// Stipulated invented world only: opaque day labels, zero-pattern UUIDs,
/// artificial identifiers/elapsed instants/digests. No source or private fixture.
struct PreparedInternalSearchInputTests {
    private func need<T>(_ value: T?) throws -> T { try #require(value) }
    private func uuid(_ n: UInt8) -> UUID { UUID(uuid: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,n)) }
    private func ref(_ s: String) throws -> TimetableQualificationReference { try need(.init(s)) }
    private func time(_ n: Double) throws -> TimetableTime {
        try .exact(need(.init(Date(timeIntervalSinceReferenceDate: n))))
    }
    private struct Spec {
        var name = "invented-trip"
        var day = "invented-day"
        var stops = ["invented-start", "invented-hub", "invented-end"]
        var through = false
        var base = 1000.0
        var step = 10.0
        // kind: active/inactive/unavailable/not loaded
        var kind = 0
        var required = [TimetableVerifiedRideInterval(boardingIndex: 0, alightingIndex: 2)]
        var positives: [TimetableVerifiedRideInterval]? = nil
        var intervalComplete = true
        var boarding: [Int: TimetableEligibility] = [:]
        var alighting: [Int: TimetableEligibility] = [:]
        var arrivals: [Int: TimetableTime] = [:]
        var departures: [Int: TimetableTime] = [:]
    }
    private struct Link {
        var from = 0
        var alight = 1
        var to = 1
        var board = 0
        var form: ConnectionForm = .walking
        var total = 0.0
        // positive/absent/unavailable
        var kind = 0
    }
    private struct World {
        let assessment: ResolvedSearchInputAssessment
        let bindings: [TimetableOccurrenceBinding]
    }
    private func world(_ specs: [Spec] = [Spec()], links: [Link] = [],
                       lower: Double = 900, duration: Double = 2000,
                       occurrenceComplete: Bool = true, connectionComplete: Bool = true,
                       evidenceComplete: Bool = true, dependency: Bool = false,
                       requestReversed: Bool = false, reverseEvidence: Bool = false) throws -> World {
        let view = TimetableViewID(uuid(91))
        let bindings = try specs.map { spec in
            let stops = try spec.stops.map { try need(StationID($0)) }
            let split = spec.through ? max(1, stops.count / 2) : stops.count - 1
            var segments = [try need(TripLineSegment(lineID: need(LineID("invented-line-a")), startIndex: 0, endIndex: split))]
            if spec.through { segments.append(try need(.init(lineID: need(LineID("invented-line-b")), startIndex: split, endIndex: stops.count - 1))) }
            let trip = try need(Trip(id: need(TripID(spec.name)), stopSequence: stops, lineSegments: segments,
                coverage: .init(includesServiceOrigin: false, includesServiceDestination: true),
                serviceTypeSegments: [need(.init(serviceTypeID: need(ServiceTypeID("invented-service")), startIndex: 0, endIndex: stops.count - 1))]))
            return try need(TimetableOccurrenceBinding(address: .init(viewID: view, tripID: trip.id,
                serviceDate: need(.init(spec.day))), trip: trip))
        }
        let railway = try RailwayArtifactRevision(dataVersion: need(ExactValue("invented-static")), registryRevision: 0,
            inputs: [], contentSHA256: String(repeating: "b", count: 64), previousSHA256: nil)
        let qualification = try need(TimetableInventoryQualification(viewID: view,
            source: ref("invented-source"), profile: ref("invented-profile"), zone: ref("invented-zone"),
            mapping: ref("invented-mapping"), review: ref("invented-review"), railway: railway))
        let profile = try need(InternalSearchProfileDefinition(identity: .init(key: uuid(92), revision: uuid(93)),
            stations: Set(bindings.flatMap(\.trip.stopSequence)), lines: Set(bindings.flatMap(\.trip.lineSegments).map(\.lineID)),
            trips: Set(bindings.map(\.trip.id)), maximumElapsedDuration: duration, maximumRailRides: 7,
            connectionPolicy: .init(key: uuid(94), revision: uuid(95)),
            serviceDateInterpretation: .init(key: uuid(96), revision: uuid(97))))
        let start = bindings[0].trip.stopSequence[0], end = bindings.last!.trip.stopSequence.last!
        let request = try need(RouteSearchRequest(origin: requestReversed ? end : start,
            destination: requestReversed ? start : end, departNotBefore: Date(timeIntervalSinceReferenceDate: lower)))
        let scope = try need(InternalSearchScope(profile: profile, request: request, viewID: view))
        func applicability(_ name: String) throws -> SearchInputClosureApplicability {
            try .init(reference: ref(name), scope: scope, qualification: qualification)
        }
        var slots: [TimetableOccurrenceInventorySlot] = []
        for (spec,binding) in zip(specs,bindings) where spec.kind != 3 {
            let state: TimetableInventoryOccurrenceState
            if spec.kind == 1 { state = .inactive }
            else if spec.kind == 2 { state = .unavailable(.insufficientEvidence) }
            else {
                let visits = try binding.trip.stopSequence.indices.map { i in
                    try need(TimetableVisitFacts(binding: binding, originalIndex: i,
                        arrival: spec.arrivals[i] ?? time(spec.base + Double(i) * spec.step),
                        departure: spec.departures[i] ?? time(spec.base + Double(i) * spec.step),
                        boarding: spec.boarding[i] ?? .allowed, alighting: spec.alighting[i] ?? .allowed))
                }
                state = try .active(need(.init(binding: binding, visits: visits)),
                    .init(binding: binding, authority: ref("invented-interval-authority"),
                        completeness: spec.intervalComplete ? .declaredComplete : .unknown,
                        declared: spec.positives ?? spec.required))
            }
            slots.append(.init(qualification: qualification, binding: binding, state: state))
        }
        let inventory = try TimetableOccurrenceInventoryView(qualification: qualification,
            declaredAddresses: slots.map(\.binding.address), completeness: .declaredComplete, suppliedSlots: slots)
        let targets = try links.map { link in
            SearchInputConnectionTarget(from: bindings[link.from].address, alightingIndex: link.alight,
                to: bindings[link.to].address, boardingIndex: link.board, applicabilityReference: try ref("invented-connection-domain"))
        }
        let closure = try RequestScopedSearchInputClosure(scope: scope, inventory: inventory, railway: railway,
            occurrences: .init(applicability: applicability("invented-occurrence-domain"),
                completeness: occurrenceComplete ? .declaredComplete : .unknown,
                required: zip(specs,bindings).map { spec,binding in
                    .init(binding: binding, applicabilityReference: try ref("invented-occurrence-domain"),
                        intervalAuthority: try ref("invented-interval-authority"), intervals: spec.required)
                }),
            connections: .init(applicability: applicability("invented-connection-domain"),
                completeness: connectionComplete ? .declaredComplete : .unknown, required: targets),
            dependencies: .init(applicability: applicability("invented-dependencies"),
                unresolved: dependency ? [ref("invented-dependency")] : []))
        var records = try zip(links,targets).map { link,target in
            let state: ConnectionEvidenceState
            if link.kind == 1 {
                state = try .qualifyingAbsence(relation: .qualified(ref("invented-absent")),
                    endpointWideContext: .qualified(ref("invented-wide")), eventIndependent: .qualified(ref("invented-time-independent")))
            } else if link.kind == 2 { state = .unavailable(.insufficientEvidence) }
            else {
                state = try .qualifyingPositive(form: link.form,
                    allowance: .init(alighting: 0, interchange: link.total, boarding: 0, total: link.total),
                    fromArrival: need(.init(Date(timeIntervalSinceReferenceDate: specs[link.from].base + Double(link.alight) * specs[link.from].step))),
                    toDeparture: need(.init(Date(timeIntervalSinceReferenceDate: specs[link.to].base + Double(link.board) * specs[link.to].step))),
                    relation: .qualified(ref("invented-relation")), genuineChange: .qualified(ref("invented-change")),
                    componentPartition: .qualified(ref("invented-partition")), endpointWideContext: .qualified(ref("invented-wide")))
            }
            return try ConnectionEvidenceRecord(key: .init(target), fromBinding: bindings[link.from], toBinding: bindings[link.to],
                targetApplicability: ref("invented-connection-domain"), review: ref("invented-connection-review"), state: state)
        }
        if reverseEvidence { records.reverse() }
        let evidence = try QualifiedConnectionEvidenceView(qualification: .init(applicability: applicability("invented-connection-domain"),
            policy: profile.connectionPolicy, review: ref("invented-connection-review")), declaredKeys: records.map(\.key),
            completeness: evidenceComplete ? .declaredComplete : .unknown, records: records)
        return try World(assessment: .init(closure: closure, connections: evidence), bindings: bindings)
    }

    // Pre-selection workload model. Actual canonical values + original assessment;
    // all snapshots/references charged by value, never by assumed COW allocation.
    private struct StudyRide { let address: TimetableOccurrenceAddress; let board: Int; let alight: Int; let train: TrainCandidate; let context: TimetableRideContext }
    private struct StudyInterval { let occurrence: Int; let interval: Int; let ride: Int }
    private struct StudyRelation { let key: ConnectionRelationKey; let evidenceIndex: Int; let state: Int }
    private func generated(_ count: Int, relations: Int = 0, textSize: Int = 32, stops: Int = 72) throws -> World {
        var specs: [Spec] = []
        var remaining = count
        while remaining > 0 {
            var s = Spec(); s.name = "invented-generated-\(specs.count)"; s.through = true
            s.stops = (0..<stops).map { "invented-stop-\($0)".padding(toLength: textSize, withPad: "x", startingAt: 0) }
            s.required = (1...min(48,remaining)).map { .init(boardingIndex: 0, alightingIndex: $0) }
            specs.append(s); remaining -= s.required.count
        }
        var links: [Link] = []
        for i in 0..<relations {
            var link = Link(); link.from = i % specs.count; link.to = (link.from + 1) % specs.count
            link.alight = 1 + i / specs.count; link.kind = i % 3 == 0 ? 1 : 0
            link.form = .walking; link.total = 1
            links.append(link)
        }
        return try world(specs,links:links)
    }
    @Test func numericWorkloadStudyBeforeLimitSelection() throws {
        for count in [256,1024,4096,5120] {
            let w = try generated(count,relations: count == 4096 || count == 5120 ? 2048 : 0)
            let start = ContinuousClock.now
            var rides: [StudyRide] = [], intervals: [StudyInterval] = []
            let closure = w.assessment.closure
            let loaded = Dictionary(uniqueKeysWithValues: closure.inventory.slots.map { ($0.binding.address,$0) })
            var logical = 256 + w.assessment.logicalPayloadBytes
            for (oi,req) in closure.occurrences.required.enumerated() {
                guard case let .active(facts,_) = loaded[req.binding.address]!.state else { throw StudyError.unexpected }
                for (ii,interval) in req.intervals.enumerated() {
                    let train = try need(TrainCandidate(trip: req.binding.trip, boardingIndex: interval.boardingIndex, alightingIndex: interval.alightingIndex))
                    let context = try need(TimetableRideContext(train: train,facts:facts))
                    rides.append(.init(address:req.binding.address,board:interval.boardingIndex,alight:interval.alightingIndex,train:train,context:context))
                    intervals.append(.init(occurrence:oi,interval:ii,ride:rides.count-1))
                    // trip in train + binding in context + key, each actual spelling.
                    let trip = train.trip
                    let tripBytes = 48 + trip.id.rawValue.utf8.count + trip.stopSequence.reduce(0) { $0 + 16 + $1.rawValue.utf8.count }
                        + trip.lineSegments.reduce(0) { $0 + 32 + $1.lineID.rawValue.utf8.count }
                        + trip.serviceTypeSegments.reduce(0) { $0 + 32 + $1.serviceTypeID.rawValue.utf8.count }
                    let addressBytes = 48 + req.binding.address.tripID.rawValue.utf8.count + req.binding.address.serviceDate.label.utf8.count
                    logical += 2 * tripBytes + 2 * addressBytes + 112
                }
            }
            let relations = w.assessment.connections.records.enumerated().map { StudyRelation(key:$0.element.key,evidenceIndex:$0.offset,state:0) }
            logical += relations.reduce(0) { n,r in n + 48 + 96 + r.key.from.tripID.rawValue.utf8.count + r.key.to.tripID.rawValue.utf8.count + r.key.from.serviceDate.label.utf8.count + r.key.to.serviceDate.label.utf8.count }
            #expect(rides.count == count && intervals.count == count)
            #expect(relations.count == w.assessment.connectionAccounting.count)
            print("PREPARED_MODEL count=\(count) relations=\(relations.count) assessment=\(w.assessment.logicalPayloadBytes) logical=\(logical) construction=\(start.duration(to:.now)) layouts=\(MemoryLayout<StudyRide>.stride)/\(MemoryLayout<StudyInterval>.stride)/\(MemoryLayout<StudyRelation>.stride)")
        }
    }
    private enum StudyError: Error { case unexpected }
    private func objective(_ revision: UInt8 = 99) -> InternalRouteObjectiveDefinition {
        .init(reference: .init(key: uuid(98), revision: uuid(revision)))
    }
    private func prepare(_ w: World) throws -> PreparedInternalSearchInput {
        try .init(assessment: w.assessment, objective: objective())
    }
    private func rejects(_ error: PreparedInputFailure, _ body: () throws -> Void) {
        #expect(throws: error, performing: body)
    }
    @Test func qualificationRetainsWholeAssessmentAndExactScope() throws {
        let w = try world(), p = try prepare(w)
        #expect(p.assessment.isTechnicallyQualified)
        #expect(p.assessment.logicalPayloadBytes == w.assessment.logicalPayloadBytes)
        #expect(p.assessment.closure.holds == w.assessment.closure.holds)
        #expect(p.assessment.closure.occurrenceAccounting == w.assessment.closure.occurrenceAccounting)
        #expect(p.assessment.closure.inventory.qualification == w.assessment.closure.inventory.qualification)
        #expect(p.assessment.connections.qualification.review == w.assessment.connections.qualification.review)
        #expect(p.scope.profile.hasSameDefinition(as: w.assessment.closure.scope.profile))
        #expect(p.scope.request.departNotBefore == w.assessment.closure.scope.request.departNotBefore)
        #expect(p.scope.lowerBound == w.assessment.closure.scope.lowerBound)
        #expect(p.scope.upperBound == w.assessment.closure.scope.upperBound)
        #expect(p.logicalPayloadBytes > w.assessment.logicalPayloadBytes)
    }
    @Test(arguments: 0...7) func everyKindOfRemainingHoldRefusesAtomically(_ kind: Int) throws {
        var s = Spec(); var second = Spec(); second.name = "invented-other"
        if kind == 3 { s.kind = 2 }
        if kind == 4 { s.kind = 3 }
        if kind == 5 { s.positives = []; s.intervalComplete = false }
        var link = Link(); link.kind = kind == 6 ? 2 : 1
        let w = try world(kind >= 6 ? [s,second] : [s], links: kind >= 6 ? [link] : [],
            occurrenceComplete: kind != 1, connectionComplete: kind != 2,
            evidenceComplete: kind != 7, dependency: kind == 0)
        #expect(!w.assessment.remainingHolds.isEmpty)
        rejects(.assessmentNotQualified) { _ = try prepare(w) }
    }
    @Test func changedAssessmentIsRetainedRatherThanSilentlySubstituted() throws {
        let a = try prepare(world()), b = try prepare(world(requestReversed:true))
        #expect(a.scope.request.origin != b.scope.request.origin)
        #expect(a.assessment.closure.scope.request.origin == a.scope.request.origin)
        #expect(b.assessment.closure.scope.request.origin == b.scope.request.origin)
    }
    @Test func exactCanonicalRideSnapshotAndOriginalIndices() throws {
        let w = try world(), p = try prepare(w), r = try need(p.rides.first)
        #expect(r.train.boardingIndex == 0 && r.train.alightingIndex == 2)
        #expect(r.key.address == w.bindings[0].address)
        #expect(r.context.binding.matches(w.bindings[0]))
        #expect(r.context.matches(r.train))
        #expect(r.train.trip.stopSequence == w.bindings[0].trip.stopSequence)
        #expect(r.train.trip.lineSegments == w.bindings[0].trip.lineSegments)
        #expect(r.train.trip.serviceTypeSegments == w.bindings[0].trip.serviceTypeSegments)
        #expect(r.train.trip.coverage == w.bindings[0].trip.coverage)
        #expect(r.context.departure == Date(timeIntervalSinceReferenceDate:1000))
        #expect(r.context.arrival == Date(timeIntervalSinceReferenceDate:1020))
        #expect(p.intervalAccounting.map(\.state) == [.usable(rideIndex:0)])
    }
    @Test(arguments: [false,true]) func inactiveAndQualifiedAbsentStayDistinct(_ inactive: Bool) throws {
        var s = Spec(); if inactive { s.kind = 1 } else { s.positives = [] }
        let p = try prepare(world([s]))
        #expect(p.rides.isEmpty)
        #expect(p.intervalAccounting.map(\.state) == [inactive ? .inactive : .absentUnderCompleteAuthority])
        #expect(p.assessment.closure.occurrenceAccounting == (inactive ? [.inactive] : [.active([.absentUnderCompleteAuthority])]))
    }
    @Test(arguments: [false,true]) func prohibitedEndpointSkipsOtherUnknownPermissionAndUnusedEvents(_ boarding: Bool) throws {
        var s = Spec()
        s.boarding[0] = boarding ? .prohibited : .unknown
        s.alighting[2] = boarding ? .unknown : .prohibited
        s.departures[0] = .missing; s.arrivals[2] = .missing
        let p = try prepare(world([s]))
        #expect(p.rides.isEmpty)
        #expect(p.intervalAccounting.map(\.state) == [.prohibitedEndpoint])
    }
    @Test(arguments: [false,true]) func remainingUnknownPermissionRejects(_ boarding: Bool) throws {
        var s = Spec(); if boarding { s.boarding[0] = .unknown } else { s.alighting[2] = .unknown }
        rejects(.permissionUnknown(occurrence:0,interval:0)) { _ = try prepare(world([s])) }
    }
    @Test(arguments: [false,true], [false,true]) func missingOrEstimatedRequiredEventRejects(_ departure: Bool, _ estimated: Bool) throws {
        var s = Spec()
        let value: TimetableTime = estimated ? .estimated(try need(.init(Date(timeIntervalSinceReferenceDate:departure ? 1000 : 1020)))) : .missing
        if departure { s.departures[0] = value } else { s.arrivals[2] = value }
        rejects(.exactEventMissing(occurrence:0,interval:0)) { _ = try prepare(world([s])) }
    }
    @Test(arguments: [false,true]) func outsideScopeCannotHideOtherMissingEvent(_ departureOutside: Bool) throws {
        var s = Spec()
        if departureOutside { s.arrivals[2] = .missing } else { s.departures[0] = .missing }
        rejects(.exactEventMissing(occurrence:0,interval:0)) {
            _ = try prepare(world([s],lower:departureOutside ? 1005 : 900,duration:departureOutside ? 100 : 110))
        }
    }
    @Test(arguments: [false,true]) func exactOutsideScopeIsLocalExclusion(_ departureOutside: Bool) throws {
        let p = try prepare(world(lower:departureOutside ? 1005 : 900,duration:departureOutside ? 100 : 110))
        #expect(p.rides.isEmpty)
        #expect(p.intervalAccounting.map(\.state) == [.outsideScope])
        #expect(p.assessment.isTechnicallyQualified)
    }
    @Test func inclusiveLowerAndUpperEndpointEquality() throws {
        let p = try prepare(world(lower:1000,duration:20))
        #expect(p.rides.count == 1)
        #expect(p.rides[0].context.departure == p.scope.lowerBound)
        #expect(p.rides[0].context.arrival == p.scope.upperBound)
    }
    @Test func repeatedVisitAndSpanningThroughServiceStayOneRide() throws {
        var s = Spec(); s.stops = ["invented-start","invented-repeat","invented-middle","invented-repeat","invented-end"]
        s.through = true; s.required = [.init(boardingIndex:3,alightingIndex:4),.init(boardingIndex:0,alightingIndex:4)]
        let p = try prepare(world([s]))
        #expect(p.rides.map(\.key.boardingIndex) == [3,0])
        #expect(p.rides.map(\.context.boardingIndex) == [3,0])
        #expect(p.rides[1].train.lineSequence.map(\.rawValue) == ["invented-line-a","invented-line-b"])
        #expect(p.rides[1].context.binding.trip.lineSegments.count == 2)
        #expect(p.rides.count == 2) // No fragment token at the internal line boundary.
    }
    @Test func occurrenceDatesAndDeclarationOrderArePreservedWithoutInferredIntervals() throws {
        var a = Spec(); a.required = [.init(boardingIndex:1,alightingIndex:2),.init(boardingIndex:0,alightingIndex:1)]
        var b = a; b.day = "invented-other-day"
        let p = try prepare(world([a,b]))
        #expect(p.rides.count == 4)
        #expect(p.rides.map(\.key.boardingIndex) == [1,0,1,0])
        #expect(p.rides[0].key != p.rides[2].key)
        #expect(p.intervalAccounting.map(\.occurrenceIndex) == [0,0,1,1])
        #expect(p.intervalAccounting.map(\.intervalIndex) == [0,1,0,1])
    }
    @Test func laterUnknownIntervalRejectsInsteadOfReturningPreparedPrefix() throws {
        var a = Spec(), b = Spec(); b.name = "invented-second"; b.boarding[0] = .unknown
        a.required = [.init(boardingIndex:0,alightingIndex:1)]
        rejects(.permissionUnknown(occurrence:1,interval:0)) { _ = try prepare(world([a,b])) }
    }
    @Test(arguments: 0...3) func connectionStatesKeepOriginalFormAllowanceAndDirection(_ kind: Int) throws {
        var a = Spec(), b = Spec(); b.name = "invented-second"; b.base = 1020
        var link = Link(); link.total = kind == 1 ? 11 : kind == 3 ? 0 : 10
        if kind == 2 { link.kind = 1 }
        if kind == 3 { b.base = 1010; b.stops = ["invented-hub","invented-next","invented-end"]; link.form = .sameStation }
        a.required = [.init(boardingIndex:0,alightingIndex:1)]
        let w = try world([a,b],links:[link]), p = try prepare(w)
        #expect(p.connections.count == 1)
        #expect(p.connections[0].key == ConnectionRelationKey(w.assessment.closure.connections.required[0]))
        #expect(p.connections[0].key.from == w.bindings[0].address)
        #expect(p.connections[0].key.to == w.bindings[1].address)
        #expect(p.connections[0].state == (kind == 2 ? .absentUnderCompleteAuthority : kind == 1 ? .infeasible : .feasible))
        if kind == 2 { #expect(p.positiveEvidence(at:0) == nil) }
        else {
            let evidence = try need(p.positiveEvidence(at:0))
            #expect(evidence.form == link.form && evidence.allowance.total == link.total)
            guard case let .present(original) = w.assessment.connections.records[0].state else { throw StudyError.unexpected }
            #expect(evidence.allowance == original.allowance)
            #expect(evidence.fromArrival == original.fromArrival && evidence.toDeparture == original.toDeparture)
            #expect(evidence.endpointWideContext == original.endpointWideContext)
        }
        #expect(p.positiveEvidence(at:-1) == nil && p.positiveEvidence(at:1) == nil)
    }
    @Test func relationRetainedWithoutUsableIncidentRide() throws {
        var a = Spec(), b = Spec(); a.boarding[0] = .prohibited; b.name = "invented-second"; b.base = 1050
        let p = try prepare(world([a,b],links:[Link()]))
        #expect(p.rides.count == 1)
        #expect(p.intervalAccounting[0].state == .prohibitedEndpoint)
        #expect(p.connections.count == 1 && p.connections[0].state == .feasible)
    }
    @Test func multipleIncidentIntervalsDoNotExpandCartesianPairs() throws {
        var a = Spec(), b = Spec(); b.name = "invented-second"; b.base = 1050
        let intervals: [TimetableVerifiedRideInterval] = [.init(boardingIndex:0,alightingIndex:1),.init(boardingIndex:0,alightingIndex:2),.init(boardingIndex:1,alightingIndex:2)]
        a.required = intervals; b.required = intervals
        let p = try prepare(world([a,b],links:[Link()]))
        #expect(p.rides.count == 6 && p.connections.count == 1)
    }
    @Test func connectionOutputFollowsBOrderRatherThanEvidenceOrder() throws {
        let a = Spec(); var b = Spec(); b.name = "invented-second"; b.base = 1050
        var first = Link(), second = Link(); first.alight = 2; second.alight = 1
        let p = try prepare(world([a,b],links:[first,second],reverseEvidence:true))
        #expect(p.connections.map(\.key.alightingIndex) == [2,1])
        #expect(p.connections.map(\.evidenceIndex) == [1,0])
        #expect(p.rides.count == 2)
    }
    @Test(arguments: [0,1,2,3,4,5,6,7,8,9]) func exactBinary64ThresholdDecisions(_ kind: Int) throws {
        let big = 9_007_199_254_740_992.0
        let cases: [(Double,Double,Double,Bool)] = [
            (10,15,5,true), (10,15.0.nextUp,5,true), (10,15.0.nextDown,5,false), (10,10,0,true),
            (.greatestFiniteMagnitude,.greatestFiniteMagnitude,.greatestFiniteMagnitude,false),
            (big,big,1,false), (big,big+4,3,true), (big,big+2,2,true),
            (1,1,.leastNonzeroMagnitude,false), (-Double.greatestFiniteMagnitude,Double.greatestFiniteMagnitude,Double.greatestFiniteMagnitude,true)]
        let c = cases[kind]
        #expect(try PreparedConnectionGap.permits(arrival:c.0,departure:c.1,allowance:c.2) == c.3)
    }
    @Test(arguments: [Double.nan,Double.infinity,-Double.infinity,-1.0]) func invalidArithmeticPremisesRefuse(_ invalid: Double) {
        rejects(.arithmeticConflict) { _ = try PreparedConnectionGap.permits(arrival:10,departure:20,allowance:invalid) }
    }
    @Test func positiveOverflowIsNormalProjectedInfeasibility() throws {
        var a = Spec(), b = Spec(); a.base = .greatestFiniteMagnitude; a.step = 0
        b.name = "invented-second"; b.base = a.base; b.step = 0
        var link = Link(); link.total = .greatestFiniteMagnitude
        let p = try prepare(world([a,b],links:[link],lower:0,duration:.greatestFiniteMagnitude))
        #expect(p.connections[0].state == .infeasible)
        #expect(p.rides.count == 2)
    }
    @Test func fixedObjectiveBindsAllAcceptedObligationsAndExactReference() throws {
        let o = objective()
        #expect(o.version == .acceptedDEC086V1)
        #expect(o.obligations == [.earliestExactFinalArrival,.fewerGenuineTrainChanges,.noInternalThroughServiceChange,
            .allDistinctEqualOptima,.reproducibilityOnly,.optimumAndAllTiesProvedBeforeSuccess,.noFirstFound,.noFirstK,
            .cutoffMeansSearchIncomplete,.unknownRequiredEvidenceMeansDataUnavailable,.selectBeforeFrozenHandoffs,
            .preserveEveryAdmittedWinner,.mixedWinnerRejectionMeansSearchIncomplete,.allRejectedMeansUnscopedNoUsableAlternatives])
        #expect(o == objective() && o.hasSameDefinition(as:objective()))
        #expect(o != objective(100) && !o.hasSameDefinition(as:objective(100)))
        let w = try world(), a = try PreparedInternalSearchInput(assessment:w.assessment,objective:o)
        let b = try PreparedInternalSearchInput(assessment:w.assessment,objective:objective(100))
        #expect(!a.objective.hasSameDefinition(as:b.objective))
        // Version is closed; no arbitrary ranking fields or mutable latest lookup.
    }
    @Test func emptyUsableInputAndDirectPlusTransferInputHaveOnlyInputValues() throws {
        var empty = Spec(); empty.kind = 1
        let zero = try prepare(world([empty]))
        #expect(zero.rides.isEmpty && zero.connections.isEmpty)
        var first = Spec()
        first.required = [.init(boardingIndex:0,alightingIndex:2),.init(boardingIndex:0,alightingIndex:1)]
        var second = Spec(); second.name = "invented-second"; second.base = 1050
        let p: PreparedInternalSearchInput = try prepare(world([first,second],links:[Link()]))
        #expect(p.rides.count == 3 && p.connections[0].state == .feasible)
        #expect(p.rides[0].train.anchors.alightingStationID == p.scope.request.destination)
        #expect(p.rides[1].key.address == p.connections[0].key.from)
        #expect(p.rides[1].key.alightingIndex == p.connections[0].key.alightingIndex)
        #expect(p.rides[2].key.address == p.connections[0].key.to)
        #expect(p.rides[2].key.boardingIndex == p.connections[0].key.boardingIndex)
        let fields = Set(Mirror(reflecting:p).children.compactMap(\.label))
        #expect(fields == ["assessment","objective","rides","intervalAccounting","connections","logicalPayloadBytes"])
        // Type/shape has no paths, result, winner, completion Bool, comparator,
        // runtime budget or route-level canonical value. No interpretation of emptiness.
    }
    @Test func nonisolatedSendableConstructionOffMainActor() async throws {
        let w = try world(), o = objective()
        let p = try await Task.detached { try PreparedInternalSearchInput(assessment:w.assessment,objective:o) }.value
        #expect(p.rides.count == 1)
    }
    @Test(arguments: 0...4) func topLevelExactAndPlusOneGuardsBeforeNestedWork(_ dimension: Int) throws {
        var counts = [SearchInputClosureLimits.occurrences,TimetableInventoryLimits.addresses,
            PreparedInputLimits.intervals,PreparedInputLimits.relations,PreparedInputLimits.rides]
        func check(_ c: [Int]) throws {
            try PreparedInputLimits.checkCounts(occurrences:c[0],inventory:c[1],intervals:c[2],relations:c[3],rides:c[4])
        }
        try check(counts)
        counts[dimension] += 1
        rejects(.resourceLimit) { try check(counts) }
        counts[dimension] = Int.max
        rejects(.resourceLimit) { try check(counts) }
        counts[dimension] = -1
        rejects(.resourceLimit) { try check(counts) }
    }
    @Test func logicalBudgetExactPlusOneAndOverflowAreAtomic() throws {
        var b = PreparedInputPayloadBudget()
        try b.include(PreparedInputLimits.logicalPayloadBytes)
        #expect(b.used == PreparedInputLimits.logicalPayloadBytes)
        rejects(.resourceLimit) { try b.include(1) }
        #expect(b.used == PreparedInputLimits.logicalPayloadBytes)
        rejects(.resourceLimit) { try b.include(Int.max) }
        rejects(.resourceLimit) { try b.include(-1) }
        #expect(b.used == PreparedInputLimits.logicalPayloadBytes)
    }
    @Test func actualRideExactLimitAndPlusOne() throws {
        let accepted = try prepare(generated(PreparedInputLimits.rides,relations:PreparedInputLimits.relations))
        #expect(accepted.rides.count == PreparedInputLimits.rides)
        #expect(accepted.connections.count == PreparedInputLimits.relations)
        #expect(accepted.intervalAccounting.count == PreparedInputLimits.rides)
        #expect(accepted.logicalPayloadBytes <= PreparedInputLimits.logicalPayloadBytes)
        print("PREPARED_ACTUAL maximum-rides=\(accepted.rides.count) relations=\(accepted.connections.count) logical=\(accepted.logicalPayloadBytes)")
        rejects(.resourceLimit) { _ = try prepare(generated(PreparedInputLimits.rides+1)) }
        rejects(.resourceLimit) { _ = try prepare(generated(5120)) }
        rejects(.resourceLimit) { _ = try prepare(generated(PreparedInputLimits.rides,relations:2048,textSize:64)) }
    }
    @Test func structuralLedgerMaximumWithNoUsableRides() throws {
        var specs: [Spec] = []
        for i in 0..<(PreparedInputLimits.intervals/48) {
            var s = Spec(); s.name = "invented-ledger-\(i/6)"; s.day = "invented-day-\(i%6)"; s.kind = 1
            s.stops = (0..<72).map { "invented-stop-\($0)" }
            s.required = (1...48).map { .init(boardingIndex:0,alightingIndex:$0) }
            specs.append(s)
        }
        let p = try prepare(world(specs))
        #expect(p.rides.isEmpty && p.intervalAccounting.count == PreparedInputLimits.intervals)
        #expect(p.intervalAccounting.last?.state == .inactive)
        print("PREPARED_LEDGER count=\(p.intervalAccounting.count) logical=\(p.logicalPayloadBytes)")
    }
    @Test func payloadStressUsesActualSnapshotTextWithoutAssumingSharing() throws {
        let short = try prepare(generated(256,textSize:32)), long = try prepare(generated(256,textSize:192))
        #expect(long.logicalPayloadBytes > short.logicalPayloadBytes)
        // Both real canonical copies add 72 * 160 bytes each per token; inherited
        // assessment also grows copy-by-copy. Repeated COW storage is not treated as free.
        #expect(long.logicalPayloadBytes - short.logicalPayloadBytes >= 256 * 2 * 72 * 160)
    }
}
