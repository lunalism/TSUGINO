import Foundation
import Testing
@testable import TSUGINO

/// Stipulated invented world only: opaque day labels, zero-pattern UUIDs,
/// artificial identifiers/elapsed instants/digests. No source or fixture.
struct SolverFixture {
    func need<T>(_ value: T?) throws -> T { try #require(value) }
    func uuid(_ n: UInt8) -> UUID { UUID(uuid: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,n)) }
    func ref(_ s: String) throws -> TimetableQualificationReference { try need(.init(s)) }
    func time(_ n: Double) throws -> TimetableTime {
        try .exact(need(.init(Date(timeIntervalSinceReferenceDate: n))))
    }
    struct Spec {
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
    struct Link {
        var from = 0
        var alight = 1
        var to = 1
        var board = 0
        var form: ConnectionForm = .walking
        var total = 0.0
        // positive/absent/unavailable
        var kind = 0
    }
    struct World {
        let assessment: ResolvedSearchInputAssessment
        let bindings: [TimetableOccurrenceBinding]
    }
    func world(_ specs: [Spec] = [Spec()], links: [Link] = [],
                       lower: Double = 900, duration: Double = 2000,
                       occurrenceComplete: Bool = true, connectionComplete: Bool = true,
                       evidenceComplete: Bool = true, dependency: Bool = false,
                       requestReversed: Bool = false, reverseEvidence: Bool = false, maximumRides: Int = 7, origin: String? = nil, destination: String? = nil) throws -> World {
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
            trips: Set(bindings.map(\.trip.id)), maximumElapsedDuration: duration, maximumRailRides: maximumRides,
            connectionPolicy: .init(key: uuid(94), revision: uuid(95)),
            serviceDateInterpretation: .init(key: uuid(96), revision: uuid(97))))
        let start = try origin.map { try need(StationID($0)) } ?? bindings[0].trip.stopSequence[0]
        let end = try destination.map { try need(StationID($0)) } ?? bindings.last!.trip.stopSequence.last!
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

    func prepare(_ specs: [Spec], links: [Link] = [], maximumRides: Int = 7,
                 origin: String = "O", destination: String = "D", reverseEvidence: Bool = false) throws -> PreparedInternalSearchInput {
        let w = try world(specs, links: links, reverseEvidence: reverseEvidence,
                          maximumRides: maximumRides, origin: origin, destination: destination)
        return try .init(assessment: w.assessment, objective: .init(reference: .init(key: uuid(98), revision: uuid(99))))
    }
    func ride(_ name: String, _ from: String = "O", _ to: String = "D", arrival: Double = 1010,
              departure: Double = 1000, day: String = "invented-day") -> Spec {
        var s = Spec(); s.name = name; s.stops = [from,to]; s.base = departure
        s.step = arrival - departure; s.day = day
        s.required = [.init(boardingIndex: 0, alightingIndex: 1)]; return s
    }
    func link(_ from: Int, _ to: Int, form: ConnectionForm = .sameStation, allowance: Double = 0, kind: Int = 0) -> Link {
        var l = Link(); l.from = from; l.to = to; l.form = form; l.total = allowance; l.kind = kind; return l
    }
}
