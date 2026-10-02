#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticTripReviewTests {
    private enum Failure: Error { case expectedCandidate, expectedRecords }
    private func u(_ n: Int) -> UUID { UUID(uuidString: String(format: "00000000-0000-0000-0000-%012x", n))! }
    private func station(_ name: String) -> StationID { StationID(name)! }
    private func line(_ name: String) -> LineID { LineID(name)! }
    private func view(_ revision: Int = 1) -> SyntheticTripReviewView {
        .init(sourceRevision: u(100 + revision), mappingRevision: u(200), profileRevision: u(300), reviewRevision: u(400))
    }
    private func p(_ n: Int, _ name: String, order: Int? = nil) -> SyntheticTripPosition {
        .init(reference: u(n), order: order ?? n * 10,
              classification: .passenger(.resolved(station(name), membership: [line("L1"), line("L2")], evidence: u(900)), evidence: u(900)))
    }
    private func passed(_ n: Int) -> SyntheticTripPosition { .init(reference: u(n), order: n * 10, classification: .passed(evidence: u(900))) }
    private func unknown(_ n: Int) -> SyntheticTripPosition { .init(reference: u(n), order: n * 10, classification: .unknown) }
    private func movement(_ from: Int, _ to: Int, _ name: String) -> SyntheticTripMovement {
        .init(from: u(from), to: u(to), line: .resolved(line(name), evidence: u(900)))
    }
    private func run(positions: [SyntheticTripPosition]? = nil, movements: [SyntheticTripMovement]? = nil,
                     identity: SyntheticTripIdentity? = nil, origin: SyntheticTripBoundary? = nil,
                     destination: SyntheticTripBoundary? = nil, revision: Int = 1,
                     prior: SyntheticTripReviewCandidate? = nil, first: Int = 1, last: Int = 3,
                     reference: Int = 500, intervalKnown: Bool = true, continuityKnown: Bool = true) -> SyntheticTripReviewRun {
        .init(reference: u(reference), view: view(revision), positions: positions ?? [p(1,"A"),p(2,"B"),p(3,"C")],
              first: u(first), last: u(last), intervalEvidence: intervalKnown ? u(900) : nil,
              identity: identity ?? .reviewed(TripID("invented-run")!, evidence: u(900)), continuityEvidence: continuityKnown ? u(900) : nil,
              origin: origin ?? .reached(evidence: u(900)), destination: destination ?? .reached(evidence: u(900)),
              movements: movements ?? [movement(first,last,"L1")], prior: prior)
    }
    private func records(_ runs: [SyntheticTripReviewRun], revision: Int = 1, evidence: Set<UUID>? = nil) throws -> [SyntheticTripReviewRecord] {
        let result = SyntheticTripReviewValidator.validate(.init(view: view(revision), evidenceReferences: evidence ?? [u(900)], runs: runs))
        guard case .reviewed(let records) = result else { throw Failure.expectedRecords }
        return records
    }
    private func candidate(_ run: SyntheticTripReviewRun, revision: Int = 1, evidence: Set<UUID>? = nil) throws -> SyntheticTripReviewCandidate {
        guard case .candidate(let value) = try records([run], revision: revision, evidence: evidence)[0].outcome else { throw Failure.expectedCandidate }; return value
    }
    private func expect(_ run: SyntheticTripReviewRun, rejected: Bool, reasons: [SyntheticTripReviewReason]) throws {
        let outcome = try records([run], revision: run.view == view() ? 1 : 2)[0].outcome
        switch outcome {
        case .held(let d): #expect(!rejected); #expect(d.map(\.reason) == reasons)
        case .rejected(let d): #expect(rejected); #expect(d.map(\.reason) == reasons)
        case .candidate: Issue.record("Unexpected candidate")
        }
    }

    @Test func s01OriginalOrderIsNotCanonicalIndex() throws {
        let positions = [p(1,"A",order:10),p(2,"B",order:30),p(3,"C",order:90)]
        let a = try candidate(run(positions:positions)), b = try candidate(run(positions:positions.reversed()))
        #expect(a.trip.stopSequence == [station("A"),station("B"),station("C")])
        #expect(a.crosswalk.map(\.sourceOrder) == [10,30,90])
        #expect(a.crosswalk.map(\.originalIndex) == [0,1,2])
        #expect(a.crosswalk.map(\.sourceOccurrence) == b.crosswalk.map(\.sourceOccurrence))
        #expect(a.matches(view: b.view, trip: b.trip))
        #expect(a.trip.lineSegments == [TripLineSegment(lineID:line("L1"),startIndex:0,endIndex:2)!])
        #expect(a.trip.serviceTypeSegments.isEmpty)
    }
    @Test func s02RepeatedVisitsRemainDistinct() throws {
        let c = try candidate(run(positions:[p(1,"A"),p(2,"B"),p(3,"A"),p(4,"C")],last:4))
        #expect(c.trip.stopSequence == [station("A"),station("B"),station("A"),station("C")])
        #expect(c.crosswalk.map(\.originalIndex) == [0,1,2,3])
    }
    @Test func s03PassedPositionAndSameLineNormalization() throws {
        let c = try candidate(run(positions:[p(1,"A"),passed(2),p(3,"C")],movements:[movement(1,2,"L1"),movement(2,3,"L1")]))
        #expect(c.trip.stopSequence == [station("A"),station("C")])
        #expect(c.crosswalk.map(\.originalIndex) == [0,nil,1])
        #expect(c.trip.lineSegments == [TripLineSegment(lineID:line("L1"),startIndex:0,endIndex:1)!])
    }
    @Test func s04UnknownCannotBeCroppedOrTreatedAsPass() throws {
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")]),rejected:false,reasons:[.unknownClassification])
        let unproved = SyntheticTripPosition(reference:u(2),order:20,classification:.passed(evidence:nil))
        try expect(run(positions:[p(1,"A"),unproved,p(3,"C")]),rejected:false,reasons:[.unknownClassification])
    }
    @Test(arguments:[0,1,2]) func s05OrderingConflicts(_ variant:Int) throws {
        var positions=[p(1,"A"),p(2,"B"),p(3,"C")]
        if variant == 0 { positions[1]=p(2,"B",order:10) }
        if variant == 1 { positions.insert(positions[0],at:0) }
        if variant == 2 { positions[1] = .init(reference:u(2),order:nil,classification:.unknown) }
        try expect(run(positions:positions),rejected:true,reasons:[.orderConflict])
    }
    @Test(arguments:[false,true]) func s06MappingOutcomes(_ impossible:Bool) throws {
        let mapping: SyntheticTripStationMapping = impossible ? .impossible : .unavailable
        let b = SyntheticTripPosition(reference:u(2),order:20,classification:.passenger(mapping,evidence:u(900)))
        try expect(run(positions:[p(1,"A"),b,p(3,"C")]),rejected:impossible,reasons:[.mappingUnavailable])
    }
    @Test func s07IdentityIsReviewedNotPatternEquality() throws {
        try expect(run(identity:.unresolved),rejected:false,reasons:[.identityUnresolved])
        let a=run(identity:.reviewed(TripID("X")!,evidence:u(900))), b=run(identity:.reviewed(TripID("Y")!,evidence:u(900)),reference:501)
        let output=try records([b,a]);#expect(output.map(\.reference)==[u(500),u(501)])
        let ids=output.compactMap { record -> TripID? in if case .candidate(let c)=record.outcome { return c.trip.id }; return nil }
        #expect(ids == [TripID("X")!,TripID("Y")!])
    }
    @Test(arguments:[0,1,2,3]) func s08IndependentPartialCoverage(_ bits:Int) throws {
        let origin: SyntheticTripBoundary = bits & 1 == 0 ? .continued(evidence:u(900)) : .reached(evidence:u(900))
        let destination: SyntheticTripBoundary = bits & 2 == 0 ? .unknownExtent : .reached(evidence:u(900))
        let c=try candidate(run(positions:[unknown(0),p(1,"A"),p(2,"B"),p(3,"C"),unknown(4)],origin:origin,destination:destination))
        #expect(c.trip.coverage.includesServiceOrigin == (bits & 1 != 0))
        #expect(c.trip.coverage.includesServiceDestination == (bits & 2 != 0))
        #expect(c.crosswalk.count == 3)
        if bits & 2 == 0 { guard case .unknownExtent=c.destinationEvidence else { Issue.record("Unknown extent lost");return } }
        try expect(run(origin:.reached(evidence:nil)),rejected:false,reasons:[.coverageEvidenceMissing])
    }
    @Test func s09LineBoundaryNeedsPassengerOccurrence() throws {
        let movements=[movement(1,2,"L1"),movement(2,3,"L2")]
        let c=try candidate(run(movements:movements));#expect(c.trip.lineSegments.count==2)
        try expect(run(positions:[p(1,"A"),passed(2),p(3,"C")],movements:movements),rejected:true,reasons:[.representationConflict])
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],movements:movements),rejected:false,reasons:[.unknownClassification])
    }
    @Test func s10RevisionCannotReuseOldIndices() throws {
        let old=try candidate(run(positions:[p(1,"A"),p(3,"C")]))
        let revised=try candidate(run(revision:2,prior:old),revision:2)
        #expect(old.trip.id==revised.trip.id)
        #expect(old.crosswalk.map(\.originalIndex)==[0,1])
        #expect(revised.crosswalk.map(\.originalIndex)==[0,1,2])
        #expect(revised.revisionObligation == .revalidationRequired)
        #expect(!old.matches(view:revised.view,trip:revised.trip))
        #expect(!old.matches(view:old.view,trip:revised.trip))
        try expect(run(prior:old),rejected:true,reasons:[.revisionMismatch])
        let removed=try candidate(run(positions:[p(1,"A"),p(3,"C")],revision:1,prior:revised))
        #expect(removed.revisionObligation == .revalidationRequired)
    }
    @Test(arguments:[false,true]) func s11SegmentAndCoverageRevisions(_ coverageOnly:Bool) throws {
        let old=try candidate(run(movements:[movement(1,2,"L1"),movement(2,3,"L2")]))
        try expect(run(prior:old),rejected:true,reasons:[.revisionMismatch])
        let changed=try candidate(run(movements: coverageOnly ? [movement(1,2,"L1"),movement(2,3,"L2")] : nil,
                                      origin:coverageOnly ? .unknownExtent : .reached(evidence:u(900)),revision:2,prior:old),revision:2)
        #expect(changed.trip.stopSequence==old.trip.stopSequence)
        #expect((changed.trip.lineSegments == old.trip.lineSegments) == coverageOnly)
        #expect((changed.trip.coverage != old.trip.coverage) == coverageOnly)
        #expect(changed.revisionObligation == .revalidationRequired)
        let unchanged=try candidate(run(movements:[movement(1,2,"L1"),movement(2,3,"L2")],prior:old))
        #expect(unchanged.revisionObligation == .unchanged)
    }
    @Test func s12FragmentsNeverMerge() throws {
        let a=run(positions:[p(1,"A"),p(3,"B")],identity:.unresolved), b=run(positions:[p(1,"B"),p(3,"C")],identity:.unresolved,reference:501)
        let output=try records([a,b]);#expect(output.count==2)
        for record in output { guard case .held(let d)=record.outcome else { Issue.record("Fragment emitted");continue };#expect(d.map(\.reason)==[.identityUnresolved]) }
        try expect(run(continuityKnown:false),rejected:false,reasons:[.coverageEvidenceMissing])
    }
    @Test func s13InvalidStructureCannotBeSalvaged() throws {
        try expect(run(positions:[p(1,"A"),passed(2),p(3,"A")]),rejected:true,reasons:[.invalidStructure])
        try expect(run(positions:[p(1,"A")],first:1,last:1),rejected:true,reasons:[.invalidStructure])
    }
    @Test func s14SharedPacketAndRegistrationGates() throws {
        let wrong=run(revision:2)
        for packet in [SyntheticTripReviewPacket(view:view(),evidenceReferences:[u(900)],runs:[run(),wrong]),
                       .init(view:view(),evidenceReferences:[],runs:[run()]),
                       .init(view:view(),evidenceReferences:[u(900)],runs:[run(),run()])] {
            guard case .invalidPacket=SyntheticTripReviewValidator.validate(packet) else { Issue.record("Shared packet salvaged");continue }
        }
        let changed=run(positions:[p(1,"A"),p(2,"C"),p(3,"B")],reference:501)
        guard case .invalidPacket=SyntheticTripReviewValidator.validate(.init(view:view(),evidenceReferences:[u(900)],runs:[run(),changed])) else { Issue.record("Competing snapshot definitions admitted");return }
        try expect(run(identity:.awaitingRegistration),rejected:false,reasons:[.registrationRequired])
    }
    @Test func deterministicAccountingDiagnosticsAndKnownContradiction() throws {
        let b=SyntheticTripPosition(reference:u(2),order:20,classification:.passenger(.impossible,evidence:u(900)))
        let bad=run(positions:[p(1,"A"),b,p(3,"C")],identity:.unresolved,reference:502)
        let held=run(identity:.unresolved,reference:501)
        let output=try records([bad,run(),held]);#expect(output.map(\.reference)==[u(500),u(501),u(502)])
        guard case .rejected(let diagnostics)=output[2].outcome else { Issue.record("Known contradiction hidden");return }
        #expect(diagnostics.map(\.reason)==[.mappingUnavailable,.identityUnresolved])
        #expect(diagnostics[0].locations==[u(2)])
        #expect(diagnostics[1].locations.isEmpty)
    }
    @Test func missingEvidenceDoesNotEraseOrInventContradictions() throws {
        let a=SyntheticTripPosition(reference:u(1),order:10,classification:.passenger(
            .resolved(station("A"),membership:[line("L2")],evidence:u(900)),evidence:u(900)))
        try expect(run(positions:[a,unknown(2),p(3,"C")]),rejected:true,reasons:[.unknownClassification,.mappingUnavailable])
        // A known passed boundary stays impossible despite an unrelated missing identity.
        try expect(run(positions:[p(1,"A"),passed(2),p(3,"C")],movements:[movement(1,2,"L1"),movement(2,3,"L2")],identity:.unresolved),
                   rejected:true,reasons:[.identityUnresolved,.representationConflict])
        let unknownTail = SyntheticTripMovement(from:u(3),to:u(4),line:.unavailable)
        try expect(run(positions:[p(1,"A"),passed(2),p(3,"C"),p(4,"D")],
                       movements:[movement(1,2,"L1"),movement(2,3,"L2"),unknownTail],last:4),
                   rejected:true,reasons:[.mappingUnavailable,.representationConflict])
        // Unknown second line may still be L1: do not invent a conclusive line change.
        let uncertain=SyntheticTripMovement(from:u(2),to:u(3),line:.unavailable)
        try expect(run(positions:[p(1,"A"),passed(2),p(3,"C")],movements:[movement(1,2,"L1"),uncertain]),
                   rejected:false,reasons:[.mappingUnavailable])
    }
    @Test(arguments:[0,1,2,3]) func conclusiveSequenceRejectsDespiteUnrelatedMissingEvidence(_ missing:Int) throws {
        let input=run(positions:[p(1,"A"),passed(2),p(3,"A")],
                      identity:missing == 0 ? .unresolved : nil,
                      origin:missing == 3 ? .reached(evidence:nil) : nil,
                      intervalKnown:missing != 1,continuityKnown:missing != 2)
        let reason:SyntheticTripReviewReason = missing == 0 ? .identityUnresolved : .coverageEvidenceMissing
        try expect(input,rejected:true,reasons:[reason,.invalidStructure])
        guard case .rejected(let diagnostics)=try records([input])[0].outcome else {
            Issue.record("Conclusive structure hidden by hold");return
        }
        #expect(diagnostics[0].locations.isEmpty)
        #expect(diagnostics[1].locations==[u(3)])
        // An unknown elsewhere does not erase this already proved adjacency.
        try expect(run(positions:[p(1,"A"),passed(2),p(3,"A"),unknown(4),p(5,"C")],last:5),
                   rejected:true,reasons:[.unknownClassification,.invalidStructure])
    }
    @Test func provedIntervalBoundaryCannotBeHiddenByUnknownMovement() throws {
        let uncertain=SyntheticTripMovement(from:u(1),to:u(3),line:.unavailable)
        try expect(run(positions:[passed(1),p(2,"B"),p(3,"C")],movements:[uncertain]),
                   rejected:true,reasons:[.mappingUnavailable,.representationConflict])
        try expect(run(positions:[p(1,"A"),p(2,"B"),passed(3)],movements:[uncertain]),
                   rejected:true,reasons:[.mappingUnavailable,.representationConflict])
        try expect(run(positions:[unknown(1),p(2,"B"),p(3,"C")],movements:[uncertain]),
                   rejected:false,reasons:[.unknownClassification,.mappingUnavailable])
    }
    @Test func reviewedPredecessorIdentityRejectsDespiteUnknownClassification() throws {
        let prior=try candidate(run(identity:.reviewed(TripID("X")!,evidence:u(900))))
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],
                       identity:.reviewed(TripID("Y")!,evidence:u(900)),prior:prior),
                   rejected:true,reasons:[.unknownClassification,.identityConflict])
        // An unreviewed proposed label cannot prove a conflicting identity.
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],
                       identity:.reviewed(TripID("Y")!,evidence:nil),prior:prior),
                   rejected:false,reasons:[.unknownClassification,.identityUnresolved])
    }
    @Test func unknownPositionsCannotProvePassengerAdjacency() throws {
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"A")]),
                   rejected:false,reasons:[.unknownClassification])
        let unmapped=SyntheticTripPosition(reference:u(2),order:20,classification:.passenger(.unavailable,evidence:u(900)))
        try expect(run(positions:[p(1,"A"),unmapped,p(3,"A")]),
                   rejected:false,reasons:[.mappingUnavailable])
        let unprovedPass=SyntheticTripPosition(reference:u(2),order:20,classification:.passed(evidence:nil))
        try expect(run(positions:[p(1,"A"),unprovedPass,p(3,"A")],identity:.unresolved),
                   rejected:false,reasons:[.unknownClassification,.identityUnresolved])
    }
    @Test(arguments:[false,true]) func affirmativeBoundaryRevisionSurvivesUnknownInterior(_ terminus:Bool) throws {
        let prior=try candidate(run())
        let input=run(positions:[p(1,"A"),unknown(2),p(3,"C")],
                      origin:terminus ? nil : .continued(evidence:u(900)),
                      destination:terminus ? .continued(evidence:u(900)) : nil,prior:prior)
        try expect(input,rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        guard case .rejected(let diagnostics)=try records([input])[0].outcome else {
            Issue.record("Known boundary revision hidden");return
        }
        #expect(diagnostics[0].locations==[u(2)])
        #expect(diagnostics[1].locations.isEmpty)
        // The opposite affirmative change is also a conflict at the same boundary.
        let continued=try candidate(run(origin:terminus ? nil : .continued(evidence:u(900)),
                                        destination:terminus ? .continued(evidence:u(900)) : nil))
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],prior:continued),
                   rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        // New views do not assert that the old immutable coverage facts still apply.
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],
                       origin:terminus ? nil : .continued(evidence:u(900)),
                       destination:terminus ? .continued(evidence:u(900)) : nil,revision:2,prior:prior),
                   rejected:false,reasons:[.unknownClassification])
    }
    @Test func uncertainAndCompatibleBoundaryAssertionsDoNotProveRevisionConflict() throws {
        let prior=try candidate(run())
        for boundary:SyntheticTripBoundary in [.unknownExtent,.continued(evidence:nil),.reached(evidence:nil),.reached(evidence:u(900))] {
            let missing:Bool
            switch boundary { case .continued(nil),.reached(nil):missing=true;default:missing=false }
            let reasons:[SyntheticTripReviewReason]=missing ? [.unknownClassification,.coverageEvidenceMissing] : [.unknownClassification]
            try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],origin:boundary,prior:prior),rejected:false,reasons:reasons)
            try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],destination:boundary,prior:prior),rejected:false,reasons:reasons)
        }
        let unknownPrior=try candidate(run(origin:.unknownExtent,destination:.unknownExtent))
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],prior:unknownPrior),
                   rejected:false,reasons:[.unknownClassification])
        // No corresponding endpoint or reviewed identity: do not invent the association.
        try expect(run(positions:[unknown(0),p(1,"A"),unknown(2),p(3,"C")],
                       origin:.continued(evidence:u(900)),prior:prior,first:0),
                   rejected:false,reasons:[.unknownClassification])
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],identity:.unresolved,
                       origin:.continued(evidence:u(900)),prior:prior),
                   rejected:false,reasons:[.unknownClassification,.identityUnresolved])
    }
    @Test func exactPredecessorOccurrenceFactsSurviveUnrelatedUnknowns() throws {
        let prior=try candidate(run())
        try expect(run(positions:[p(1,"D"),unknown(2),p(3,"C")],prior:prior),
                   rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        try expect(run(positions:[p(1,"A",order:11),unknown(2),p(3,"C")],prior:prior),
                   rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        let priorWithPass=try candidate(run(positions:[p(1,"A"),passed(2),p(3,"C")]))
        try expect(run(positions:[unknown(1),p(2,"B"),p(3,"C")],prior:priorWithPass),
                   rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        try expect(run(positions:[unknown(1),passed(2),p(3,"C")],prior:prior),
                   rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        try expect(run(positions:[p(1,"D"),unknown(2),p(3,"C")],revision:2,prior:prior),
                   rejected:false,reasons:[.unknownClassification])
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],movements:[movement(1,3,"L2")],prior:prior),
                   rejected:true,reasons:[.unknownClassification,.revisionMismatch])
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],movements:[movement(1,3,"L2")],revision:2,prior:prior),
                   rejected:false,reasons:[.unknownClassification])
        let twoLines=try candidate(run(movements:[movement(1,2,"L1"),movement(2,3,"L2")]))
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C")],
                       movements:[movement(1,2,"L1"),movement(2,3,"L2")],prior:twoLines),
                   rejected:false,reasons:[.unknownClassification])
        let unproved=SyntheticTripPosition(reference:u(1),order:10,classification:
            .passenger(.resolved(station("D"),membership:[line("L1")],evidence:u(900)),evidence:nil))
        try expect(run(positions:[unproved,unknown(2),p(3,"C")],prior:prior),
                   rejected:false,reasons:[.unknownClassification])
    }
    @Test(arguments: [false, true]) func passengerDispositionConflictDoesNotRequireMapping(_ resolved: Bool) throws {
        let prior = try candidate(run(positions:[p(1,"A"),passed(2),p(3,"C")]))
        let mapping: SyntheticTripStationMapping = resolved
            ? .resolved(station("B"),membership:[line("L1")],evidence:nil) : .unavailable
        let passenger = SyntheticTripPosition(reference:u(2),order:20,
            classification:.passenger(mapping,evidence:u(900)))
        let input = run(positions:[p(1,"A"),passenger,p(3,"C")],prior:prior)
        guard case .rejected(let diagnostics) = try records([input])[0].outcome else {
            Issue.record("Affirmative disposition conflict hidden by missing mapping"); return
        }
        #expect(diagnostics.map(\.reason) == [.mappingUnavailable,.revisionMismatch])
        #expect(diagnostics.map(\.locations) == [[u(2)],[]])
    }
    @Test(arguments: [false, true], [0,1,2,3,4])
    func uncertainDispositionOrCorrespondenceDoesNotProveConflict(_ resolved: Bool, _ control: Int) throws {
        let prior = try candidate(run(positions:[p(1,"A"),passed(2),p(3,"C")]))
        let mapping: SyntheticTripStationMapping = resolved
            ? .resolved(station("B"),membership:[line("L1")],evidence:nil) : .unavailable
        // Missing classification, changed view, absent occurrence, unresolved identity,
        // and an unproved identity label each withhold a required comparison premise.
        let reference = u(control == 2 ? 20 : 2)
        let passenger = SyntheticTripPosition(reference:reference,order:20,
            classification:.passenger(mapping,evidence:control == 0 ? nil : u(900)))
        let identity: SyntheticTripIdentity = control == 3 ? .unresolved
            : .reviewed(TripID("invented-run")!,evidence:control == 4 ? nil : u(900))
        let revision = control == 1 ? 2 : 1
        let input = run(positions:[p(1,"A"),passenger,p(3,"C")],identity:identity,revision:revision,prior:prior)
        guard case .held(let diagnostics) = try records([input],revision:revision)[0].outcome else {
            Issue.record("Uncertainty fabricated a disposition conflict"); return
        }
        let reasons: [SyntheticTripReviewReason] = control == 0 ? [.unknownClassification,.mappingUnavailable]
            : control >= 3 ? [.mappingUnavailable,.identityUnresolved] : [.mappingUnavailable]
        let locations: [[UUID]] = control == 0 ? [[reference],[reference]]
            : control >= 3 ? [[reference],[]] : [[reference]]
        #expect(diagnostics.map(\.reason) == reasons)
        #expect(diagnostics.map(\.locations) == locations)
    }
    @Test func completeStructuralRevisionSurvivesUnrelatedReviewHold() throws {
        let prior=try candidate(run())
        try expect(run(positions:[p(1,"A"),p(2,"D"),p(3,"C")],prior:prior,continuityKnown:false),
                   rejected:true,reasons:[.revisionMismatch,.coverageEvidenceMissing])
        try expect(run(movements:[movement(1,2,"L1"),movement(2,3,"L2")],prior:prior,continuityKnown:false),
                   rejected:true,reasons:[.revisionMismatch,.coverageEvidenceMissing])
        try expect(run(prior:prior,continuityKnown:false),rejected:false,reasons:[.coverageEvidenceMissing])
        try expect(run(positions:[p(1,"A"),p(2,"D"),p(3,"C")],revision:2,prior:prior,continuityKnown:false),
                   rejected:false,reasons:[.coverageEvidenceMissing])
    }
    @Test(arguments: [0,1,2,3,4,5]) func movementProofRevisionPrecedesClassificationHold(_ variant:Int) throws {
        func span(_ a:Int,_ b:Int,_ proof:Int) -> SyntheticTripMovement {
            .init(from:u(a),to:u(b),line:.resolved(line("L1"),evidence:u(proof)))
        }
        let proofs:Set<UUID> = [u(900),u(901)]
        let priorSpans = variant == 1 ? [span(1,2,900),span(2,3,901)] : [span(1,3,900)]
        let prior = try candidate(run(movements:priorSpans),evidence:proofs)
        let spans:[SyntheticTripMovement]
        switch variant {
        case 0,4: spans = [span(1,3,901)]
        case 1: spans = [span(1,2,901),span(2,3,900)]
        case 3: spans = [span(1,2,900),span(2,3,900)]
        case 5: spans = [span(1,2,900),.init(from:u(2),to:u(3),line:.unavailable)]
        default: spans = [span(1,3,900)]
        }
        let revision = variant == 4 ? 2 : 1
        let input = run(positions:[p(1,"A"),unknown(2),p(3,"C")],movements:spans,revision:revision,prior:prior)
        let output = try records([input],revision:revision,evidence:proofs)[0].outcome
        let diagnostics:[SyntheticTripReviewDiagnostic]
        if variant <= 1 {
            guard case .rejected(let d) = output else { Issue.record("Established proof change hidden");return }
            diagnostics = d
            #expect(d.map(\.reason) == [.unknownClassification,.revisionMismatch])
            #expect(d[1].locations.isEmpty)
        } else {
            guard case .held(let d) = output else { Issue.record("Uncertainty fabricated a revision");return }
            diagnostics = d
            #expect(d.map(\.reason) == (variant == 5 ? [.unknownClassification,.mappingUnavailable] : [.unknownClassification]))
            if variant == 5 { #expect(d[1].locations == [u(2)]) }
        }
        #expect(diagnostics[0].locations == [u(2)])
    }
    @Test(arguments: [0,1,2,3,4,5,6]) func establishedReviewProofChangesPrecedeHold(_ role:Int) throws {
        let prior = try candidate(run())
        let classification: SyntheticTripClassification = role == 5
            ? .passenger(.resolved(station("A"),membership:[line("L1"),line("L2")],evidence:u(900)),evidence:u(901))
            : .passenger(.resolved(station("A"),membership:[line("L1"),line("L2")],evidence:u(role == 6 ? 901 : 900)),evidence:u(900))
        let input = SyntheticTripReviewRun(reference:u(500),view:view(),
            positions:[.init(reference:u(1),order:10,classification:classification),unknown(2),p(3,"C")],
            first:u(1),last:u(3),intervalEvidence:u(role == 0 ? 901 : 900),
            identity:.reviewed(TripID("invented-run")!,evidence:u(role == 1 ? 901 : 900)),
            continuityEvidence:u(role == 2 ? 901 : 900),
            origin:.reached(evidence:u(role == 3 ? 901 : 900)),
            destination:.reached(evidence:u(role == 4 ? 901 : 900)),movements:[movement(1,3,"L1")],prior:prior)
        guard case .rejected(let d) = try records([input],evidence:[u(900),u(901)])[0].outcome else {
            Issue.record("Established review proof change hidden");return
        }
        #expect(d.map(\.reason) == [.unknownClassification,.revisionMismatch])
        #expect(d[0].locations == [u(2)])
        #expect(d[1].locations.isEmpty)
    }
    @Test(arguments: [false, true]) func completeMovementSubdivisionIsUnchanged(_ splitPredecessor: Bool) throws {
        let positions = [p(1,"A"),passed(2),p(3,"C"),p(4,"D")]
        let unsplit = [movement(1,4,"L1")]
        let split = [movement(1,2,"L1"),movement(2,4,"L1")]
        let prior = try candidate(run(positions:positions, movements:splitPredecessor ? split : unsplit,last:4))
        let current = try candidate(run(positions:positions, movements:splitPredecessor ? unsplit : split,prior:prior,last:4))
        guard case .unchanged = current.revisionObligation else { Issue.record("Equivalent evidence became a revision"); return }
        #expect(current.matches(view:prior.view,trip:prior.trip))
        #expect(current.trip.stopSequence == [station("A"),station("C"),station("D")])
        #expect(current.trip.lineSegments == prior.trip.lineSegments)
        #expect(current.crosswalk.map(\.sourceOccurrence) == [u(1),u(2),u(3),u(4)])
        #expect(current.crosswalk.map(\.originalIndex) == [0,nil,1,2])
    }
    @Test(arguments: [1, 2]) func changedMovementProofPreservesRevisionRules(_ revision: Int) throws {
        let prior = try candidate(run())
        let changed = SyntheticTripMovement(from:u(1),to:u(3),line:.resolved(line("L1"),evidence:u(901)))
        let input = run(movements:[changed],revision:revision,prior:prior)
        let outcome = try records([input],revision:revision,evidence:[u(900),u(901)])[0].outcome
        if revision == 1 {
            guard case .rejected(let diagnostics) = outcome else { Issue.record("Changed proof was not rejected"); return }
            #expect(diagnostics.map(\.reason) == [.revisionMismatch])
            #expect(diagnostics[0].locations.isEmpty)
        } else {
            guard case .candidate(let value) = outcome else { Issue.record("Changed view did not permit review"); return }
            guard case .revalidationRequired = value.revisionObligation else { Issue.record("Missing revision obligation"); return }
            #expect(value.trip.stopSequence == prior.trip.stopSequence)
        }
    }
    @Test(arguments: [false, true]) func movementProofAssociationIsNotASet(_ shiftBoundary: Bool) throws {
        func span(_ a:Int,_ b:Int,_ proof:Int) -> SyntheticTripMovement {
            .init(from:u(a),to:u(b),line:.resolved(line("L1"),evidence:u(proof)))
        }
        let positions = [p(1,"A"),passed(2),p(3,"C"),p(4,"D")]
        let evidence:Set<UUID> = [u(900),u(901)]
        let prior = try candidate(run(positions:positions,movements:[span(1,2,900),span(2,4,901)],last:4),evidence:evidence)
        // Same global proof set, but either swap applicability or move its boundary.
        let changed = shiftBoundary ? [span(1,3,900),span(3,4,901)] : [span(1,2,901),span(2,4,900)]
        let input = run(positions:positions,movements:changed,prior:prior,last:4)
        guard case .rejected(let diagnostics) = try records([input],evidence:evidence)[0].outcome else {
            Issue.record("Evidence-to-span association was erased"); return
        }
        #expect(diagnostics.map(\.reason) == [.revisionMismatch])
        #expect(diagnostics[0].locations.isEmpty)
    }
    @Test(arguments:["L1","L2"]) func splitAndUnsplitMovementRevisionOutcomesAgree(_ lineName:String) throws {
        let prior=try candidate(run(positions:[p(1,"A"),passed(2),p(3,"C"),p(4,"D")],last:4))
        for revision in [1,2] {
            var observed:[[SyntheticTripReviewDiagnostic]]=[]
            for spans in [[movement(1,4,lineName)],[movement(1,2,lineName),movement(2,4,lineName)]] {
                let input=run(positions:[p(1,"A"),passed(2),p(3,"C"),unknown(4)],movements:spans,
                              revision:revision,prior:prior,last:4)
                let rejects=revision == 1 && lineName == "L2"
                let reasons:[SyntheticTripReviewReason]=rejects ? [.unknownClassification,.revisionMismatch] : [.unknownClassification]
                try expect(input,rejected:rejects,reasons:reasons)
                switch try records([input],revision:revision)[0].outcome {
                case .held(let d),.rejected(let d): observed.append(d)
                case .candidate:Issue.record("Unknown snapshot emitted")
                }
            }
            #expect(observed.count==2)
            #expect(observed[0].map(\.reason)==observed[1].map(\.reason))
            #expect(observed[0].map(\.locations)==observed[1].map(\.locations))
            #expect(observed[0][0].locations==[u(4)])
        }
    }
    @Test func normalizedComparisonExcludesBoundaryOnlyContact() throws {
        let spans=[movement(1,3,"L1"),movement(3,4,"L2")]
        let prior=try candidate(run(positions:[p(1,"A"),passed(2),p(3,"C"),p(4,"D")],movements:spans,last:4))
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C"),p(4,"D")],
                       movements:[movement(1,2,"L1"),movement(2,3,"L1"),movement(3,4,"L2")],prior:prior,last:4),
                   rejected:false,reasons:[.unknownClassification])
    }
    @Test func normalizationNeverBridgesUnknownOrConflictingLines() throws {
        let positions=[p(1,"A"),p(2,"B"),p(3,"C"),p(4,"D")]
        let lines=[movement(1,2,"L1"),movement(2,3,"L2"),movement(3,4,"L1")]
        let prior=try candidate(run(positions:positions,movements:lines,last:4))
        let uncertain=SyntheticTripMovement(from:u(2),to:u(3),line:.unavailable)
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C"),p(4,"D")],
                       movements:[movement(1,2,"L1"),uncertain,movement(3,4,"L1")],prior:prior,last:4),
                   rejected:false,reasons:[.unknownClassification,.mappingUnavailable])
        // L1/L2/L1 remains three distinct intervals, even with a shared identity/view.
        try expect(run(positions:[p(1,"A"),unknown(2),p(3,"C"),p(4,"D")],movements:lines,prior:prior,last:4),
                   rejected:false,reasons:[.unknownClassification])
        try expect(run(positions:[p(1,"A"),passed(2),unknown(3),p(4,"D")],
                       movements:[movement(1,2,"L1"),movement(2,4,"L2")],last:4),
                   rejected:true,reasons:[.unknownClassification,.representationConflict])
    }
    @Test func passedAnchoredMovementEvidenceDoesNotNeedPassengerIndices() throws {
        let positions=[p(1,"A"),passed(2),p(3,"B"),p(4,"C"),passed(5),p(6,"D")]
        let prior=try candidate(run(positions:positions,last:6))
        let before=SyntheticTripMovement(from:u(1),to:u(2),line:.unavailable)
        let after=SyntheticTripMovement(from:u(5),to:u(6),line:.unavailable)
        for middle in [[movement(2,5,"L2")],[movement(2,3,"L2"),movement(3,4,"L2"),movement(4,5,"L2")]] {
            try expect(run(positions:[p(1,"A"),passed(2),unknown(3),p(4,"C"),passed(5),p(6,"D")],
                           movements:[before]+middle+[after],prior:prior,last:6),
                       rejected:true,reasons:[.unknownClassification,.mappingUnavailable,.revisionMismatch])
        }
    }
    @Test func extremeOrderingAndInvalidMovementReferencesAreSafe() throws {
        let c=try candidate(run(positions:[p(1,"A",order:Int.min),p(2,"B",order:0),p(3,"C",order:Int.max)]))
        #expect(c.crosswalk.map(\.originalIndex)==[0,1,2])
        try expect(run(movements:[movement(3,1,"L1")]),rejected:true,reasons:[.invalidStructure])
        try expect(run(movements:[movement(1,99,"L1")]),rejected:true,reasons:[.invalidStructure])
        try expect(run(first:99),rejected:true,reasons:[.invalidStructure])
    }
}
#endif
