#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Entirely invented DEC-085 fixtures, unrelated to any transport feed.
struct SyntheticTimetableConversionTests {
    typealias C = SyntheticTimetableConverter
    typealias P = SyntheticTimetablePacket
    typealias E = SyntheticTimetableEvidence
    typealias V = SyntheticTimetableVisit
    typealias R = SyntheticTimetableRevision
    typealias Z = SyntheticTimetableZoneInterval
    typealias Civil = SyntheticTimetableCivilTime

    struct Fixture {
        let revision = R(source: "R1", profile: "invented-civil-day-v1", zone: "Z1", mapping: "M1")
        let binding: TimetableOccurrenceBinding
        var manifest: SyntheticTimetableManifest?
        var evidence: [E]
        var calendar: SyntheticTimetableCalendar?
        var zone: SyntheticTimetableZone? = .fixed(offset: 32400)
        var visits: [V]
        var date: String
        var run = "run"
        var service = "service"
        init(date: String = "2026-04-13", stops: [String] = ["A", "B"], id: String = "T1") throws {
            self.date = date
            let tripID = try #require(TripID(id))
            let stationIDs = try stops.map { try #require(StationID($0)) }
            let lineID = try #require(LineID("L1"))
            let line = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: stops.count - 1))
            let trip = try #require(Trip(id: tripID, stopSequence: stationIDs, lineSegments: [line],
                                       coverage: .init(includesServiceOrigin: true, includesServiceDestination: true),
                                       serviceTypeSegments: []))
            let serviceDate = try #require(TimetableServiceDate(date))
            let uuid = UUID(uuid: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1))
            binding = try #require(TimetableOccurrenceBinding(address: .init(viewID: .init(uuid), tripID: tripID,
                                                                            serviceDate: serviceDate), trip: trip))
            manifest = .init(binding: binding, revision: revision, profileEvidence: "profile", executionEvidence: "once")
            let evidenceRevision = revision
            evidence = [("profile", SyntheticTimetableAssertion.profileApplicable), ("once", .singleExecution),
                        ("calendar", .calendarComplete), ("exact", .exact), ("estimate", .estimated),
                        ("allow", .allowed), ("deny", .prohibited)].map {
                E(id: $0.0, revision: evidenceRevision, run: "run", service: "service", assertion: $0.1, scope: .wholeRun)
            }
            calendar = .init(mode: .weekly, coverageStart: "2026-04-01", coverageEnd: "2026-04-30",
                baselines: [.init(start: "2026-04-01", end: "2026-04-30", weekdays: Self.weekdays)],
                exceptions: [], completenessEvidence: "calendar")
            visits = stops.indices.map {
                V(index: Int64($0), occurrence: "O\($0)", mappingRevision: "M1", arrival: .missing,
                  departure: .exact(clock: $0 == 0 ? "08:00:00" : "08:30:00", evidence: "exact"),
                  boarding: .init(value: .unknown, evidence: nil), alighting: .init(value: .unknown, evidence: nil))
            }
        }
        static let weekdays = SyntheticTimetableWeekdays(monday: true, tuesday: true, wednesday: true,
            thursday: true, friday: true, saturday: false, sunday: false)
        var packet: P { .init(binding: binding, serviceDate: date, run: run, service: service, revision: revision,
            manifest: manifest, evidence: evidence, calendar: calendar, zone: zone, visits: visits) }
        mutating func rules(mode: SyntheticTimetableCalendarMode? = .weekly, complete: String? = "calendar",
                            start: String = "2026-04-01", end: String = "2026-04-30",
                            baselineEnd: String = "2026-04-30", exceptions: [SyntheticTimetableException] = []) {
            calendar = .init(mode: mode, coverageStart: start, coverageEnd: end,
                baselines: mode == .weekly ? [.init(start: start, end: baselineEnd, weekdays: Self.weekdays)] : [],
                exceptions: exceptions, completenessEvidence: complete)
        }
        mutating func event(_ index: Int, _ time: SyntheticTimetableEvent?, arrival: Bool = false) {
            let old = visits[index]
            visits[index] = .init(index: old.index, occurrence: old.occurrence, mappingRevision: old.mappingRevision,
                arrival: arrival ? time : old.arrival, departure: arrival ? old.departure : time,
                boarding: old.boarding, alighting: old.alighting)
        }
        mutating func transition(at: Int64, before: Int64, after: Int64) {
            zone = .transitions([.init(start: Civil.minimum, end: at, offset: before),
                                 .init(start: at, end: Civil.maximum, offset: after)])
        }
    }

    private func facts(_ fixture: Fixture) throws -> TimetableOccurrenceFacts {
        guard case .success(let facts) = C.convert(fixture.packet) else { Issue.record("Expected atomic success"); throw Failure.expectedSuccess }
        return facts
    }
    private enum Failure: Error { case expectedSuccess, expectedFailure }
    private func failure(_ fixture: Fixture, kind: SyntheticTimetableFailureKind,
                         reason: SyntheticTimetableReason? = nil) throws -> SyntheticTimetableFailure {
        let result = C.convert(fixture.packet)
        let value: SyntheticTimetableFailure
        switch result {
        case .invalid(let f): #expect(kind == .invalid); value = f
        case .unsupported(let f): #expect(kind == .unsupported); value = f
        case .insufficientEvidence(let f): #expect(kind == .insufficientEvidence); value = f
        default: Issue.record("Expected zero facts, got success/inactive"); throw Failure.expectedFailure
        }
        #expect(value.kind == kind)
        if let reason { #expect(value.reason == reason) }
        return value
    }
    private func exactSeconds(_ time: TimetableTime) throws -> Double {
        guard case .exact(let value) = time else { throw Failure.expectedSuccess }
        return value.date.timeIntervalSince1970
    }
    private func coordinate(_ date: String, _ clock: String = "00:00:00") throws -> Int64 {
        guard case .value(let d) = Civil.date(date), case .value(let s) = Civil.clock(clock),
              let result = Civil.localCoordinate(day: d, seconds: s) else { throw Failure.expectedSuccess }
        return result
    }

    @Test func ordinaryAndRepeatedVisitsPreserveBindingAndTags() throws {
        var f = try Fixture(stops: ["A", "B", "A"])
        f.event(2, .estimated(clock: "07:00:00", evidence: "estimate"))
        let result = try facts(f)
        #expect(result.binding.matches(f.binding))
        #expect(result.visits.map(\.originalIndex) == [0,1,2])
        #expect(result.visits[0].arrival == .missing)
        #expect(try exactSeconds(result.visits[0].departure) == 1776034800)
        if case .estimated = result.visits[2].departure {} else { Issue.record("Estimate promoted/lost") }
    }
    @Test func calendarAdditionRemovalAndExceptionOnly() throws {
        var f = try Fixture(date: "2026-04-18")
        if case .inactive(.baselineOff) = C.convert(f.packet) {} else { Issue.record("Saturday active") }
        f.rules(baselineEnd: "2026-04-17", exceptions: [.init(service: "service", date: f.date, action: .add)])
        _ = try facts(f)
        f.rules(exceptions: [.init(service: "service", date: f.date, action: .remove)])
        f.event(0, .exact(clock: "08:75:00", evidence: nil))
        if case .inactive(.explicitRemoval) = C.convert(f.packet) {} else { Issue.record("Inactive event inspected") }
        f.rules(mode: .exceptionOnly)
        if case .inactive(.unlistedDate) = C.convert(f.packet) {} else { Issue.record("Complete absence not inactive") }
        f.rules(mode: .exceptionOnly, complete: nil)
        _ = try failure(f, kind: .insufficientEvidence)
    }
    @Test(arguments: [false, true]) func duplicateAndConflictingExceptionsCannotHideBehindRemoval(_ conflict: Bool) throws {
        var f = try Fixture()
        f.rules(exceptions: [.init(service: "service", date: f.date, action: .remove),
                             .init(service: "service", date: f.date, action: conflict ? .add : .remove)])
        _ = try failure(f, kind: .invalid, reason: .duplicateException)
    }
    @Test func allCalendarRecordsValidatedAndMissingCoverageNotInactive() throws {
        var f = try Fixture()
        f.rules(exceptions: [.init(service: "other", date: "2026-04-14", action: .add)])
        _ = try failure(f, kind: .invalid)
        f.rules(exceptions: [.init(service: "service", date: "2026-05-01", action: .add)])
        _ = try failure(f, kind: .invalid)
        f.rules(start: "2026-04-20")
        _ = try failure(f, kind: .insufficientEvidence, reason: .calendarCoverage)
        f.calendar = nil
        _ = try failure(f, kind: .insufficientEvidence, reason: .activationUnavailable)
        f.rules(mode: nil)
        _ = try failure(f, kind: .insufficientEvidence)
        f.rules(mode: .unsupported)
        _ = try failure(f, kind: .unsupported)
        f.rules(start: "2026-04-30", end: "2026-04-01")
        _ = try failure(f, kind: .invalid)
    }
    @Test(arguments: [("23:50:00","24:10:00",85800.0,87000.0), ("25:10:00","25:30:00",90600.0,91800.0)])
    func extendedHoursUseCivilRollover(_ c: (String,String,Double,Double)) throws {
        var f = try Fixture()
        f.event(0, .exact(clock: c.0, evidence: "exact")); f.event(1, .exact(clock: c.1, evidence: "exact"))
        let result = try facts(f), base = Double(try coordinate("2026-04-13")) - 32400
        #expect(try exactSeconds(result.visits[0].departure) == base + c.2)
        #expect(try exactSeconds(result.visits[1].departure) == base + c.3)
    }
    @Test func leapDayAndYearEndSpillover() throws {
        for date in ["2000-02-29", "2099-12-31"] {
            var f = try Fixture(date: date)
            f.rules(start: date, end: date, baselineEnd: date, exceptions: [.init(service: "service", date: date, action: .add)])
            f.zone = .fixed(offset: -50400)
            f.event(0, .exact(clock: "71:59:59", evidence: "exact")); f.event(1, .exact(clock: "71:59:59", evidence: "exact"))
            _ = try facts(f)
        }
        for date in ["2026-02-30", "2100-02-29", "2026-4-13", "2026-04-13 "] {
            let f = try Fixture(date: date); _ = try failure(f, kind: .invalid)
        }
        let f = try Fixture(date: "2100-01-01"); _ = try failure(f, kind: .unsupported, reason: .dateRange)
    }
    @Test(arguments: ["25:10", "08:75:00", "08:00:60", "-1:00:00", "008:00:00", "08:00:0０"])
    func malformedClockIsInvalid(_ text: String) throws {
        var f = try Fixture(); f.event(0, .exact(clock: text, evidence: "exact"))
        _ = try failure(f, kind: .invalid)
    }
    @Test(arguments: ["72:00:00", "99:59:59"])
    func wellFormedOutOfProfileHourIsUnsupported(_ text: String) throws {
        var f = try Fixture(); f.event(0, .exact(clock: text, evidence: "exact"))
        _ = try failure(f, kind: .unsupported, reason: .hourRange)
    }
    @Test(arguments: [false, true]) func gapAndFoldRejectWithoutGuessing(_ fold: Bool) throws {
        var f = try Fixture()
        f.transition(at: try coordinate(f.date, "02:00:00"), before: fold ? 3600 : 0, after: fold ? 0 : 3600)
        f.event(0, .exact(clock: "02:30:00", evidence: "exact"))
        _ = try failure(f, kind: .insufficientEvidence, reason: fold ? .ambiguousLocalTime : .nonexistentLocalTime)
    }
    @Test func civilRolloverDoesNotAddElapsedSecondsFromMidnight() throws {
        var f = try Fixture()
        f.transition(at: try coordinate("2026-04-14"), before: 0, after: 3600)
        f.event(0, .exact(clock: "24:10:00", evidence: "exact"))
        _ = try failure(f, kind: .insufficientEvidence, reason: .nonexistentLocalTime)
    }
    @Test func zoneCoverageEndpointsAndInactiveStructure() throws {
        var f = try Fixture()
        let local = try coordinate(f.date, "08:00:00")
        f.zone = .transitions([.init(start: local-50400, end: local+50400, offset: 0)])
        _ = try failure(f, kind: .insufficientEvidence, reason: .zoneCoverage)
        f.event(1, .exact(clock: "08:00:00", evidence: "exact"))
        f.zone = .transitions([.init(start: local-50400, end: local+50401, offset: 0)])
        _ = try facts(f)
        f.transition(at: local, before: 0, after: 0) // Boundary belongs only to the second interval.
        _ = try facts(f)
        f.rules(exceptions: [.init(service: "service", date: f.date, action: .remove)])
        f.zone = nil; _ = try failure(f, kind: .insufficientEvidence, reason: .zoneUnavailable)
        f.zone = .unsupported; _ = try failure(f, kind: .unsupported, reason: .zoneKind)
        f.zone = .transitions([.init(start: local-50400, end: local+1, offset: 0), .init(start: local, end: local+50401, offset: 0)])
        _ = try failure(f, kind: .invalid, reason: .zoneIntervals)
        f.zone = .transitions([.init(start: local-50400, end: local-1, offset: 0), .init(start: local, end: local+50401, offset: 0)])
        _ = try failure(f, kind: .insufficientEvidence, reason: .zoneCoverage)
    }
    @Test func missingEstimatedUnknownAndChronologyAreSeparate() throws {
        var f = try Fixture()
        f.event(0, .missing); f.event(1, .estimated(clock: "07:00:00", evidence: "estimate"))
        _ = try facts(f)
        f.event(0, .unqualified(clock: "08:00:00")); _ = try failure(f, kind: .insufficientEvidence)
        f.event(0, nil); _ = try failure(f, kind: .insufficientEvidence)
        f.event(0, .exact(clock: "08:30:00", evidence: "exact")); f.event(1, .exact(clock: "08:00:00", evidence: "exact"))
        let failure = try failure(f, kind: .invalid, reason: .chronologyConflict)
        #expect(failure.diagnostic.event?.originalIndex == 0)
        #expect(failure.diagnostic.laterEvent?.originalIndex == 1)
    }
    @Test func arrivalDepartureAndExactSubsequenceUseDomainValidation() throws {
        var f = try Fixture(stops: ["A","B","A"])
        f.event(0, .exact(clock: "09:00:00", evidence: "exact"), arrival: true)
        _ = try failure(f, kind: .invalid, reason: .chronologyConflict)
        f.event(0, .missing, arrival: true)
        f.event(1, .estimated(clock: "23:00:00", evidence: "estimate"))
        f.event(2, .exact(clock: "07:59:59", evidence: "exact"))
        _ = try failure(f, kind: .invalid, reason: .chronologyConflict)
        f.event(2, .exact(clock: "08:00:00", evidence: "exact")); _ = try facts(f)
    }
    @Test func severityDoesNotReorderPrimaryDiagnostic() throws {
        var f = try Fixture()
        f.event(0, .exact(clock: "08:00:00", evidence: nil)); f.event(1, .exact(clock: "08:75:00", evidence: "exact"))
        let result = try failure(f, kind: .invalid, reason: .referenceUnavailable)
        #expect(result.diagnostic.event?.originalIndex == 0)
        #expect(result.diagnostic.event?.kind == .departure)
    }
    @Test func exactSnapshotRevisionAndDateMustMatch() throws {
        var f = try Fixture()
        let other = try Fixture(stops: ["A","C"])
        f.manifest = .init(binding: other.binding, revision: f.revision, profileEvidence: "profile", executionEvidence: "once")
        _ = try failure(f, kind: .invalid, reason: .occurrenceBinding)
        f.manifest = nil; _ = try failure(f, kind: .insufficientEvidence, reason: .viewUnavailable)
        f = try Fixture(); f.date = "2026-04-14"
        _ = try failure(f, kind: .invalid, reason: .dateMismatch)
        let old = f.evidence[0]
        f.evidence[0] = .init(id: old.id, revision: .init(source: "R2", profile: old.revision.profile, zone: "Z1", mapping: "M1"),
            run: old.run, service: old.service, assertion: old.assertion, scope: old.scope)
        _ = try failure(f, kind: .invalid, reason: .revisionConflict)
    }
    @Test func evidenceUniquenessMultiplicityAndScope() throws {
        var f = try Fixture(); f.evidence.append(f.evidence[0])
        _ = try failure(f, kind: .invalid, reason: .referenceConflict)
        for assertion in [SyntheticTimetableAssertion.multipleExecutions, .unknownMultiplicity] {
            f = try Fixture()
            f.evidence[1] = .init(id: "once", revision: f.revision, run: f.run, service: f.service, assertion: assertion, scope: .wholeRun)
            _ = try failure(f, kind: assertion == .multipleExecutions ? .unsupported : .insufficientEvidence, reason: .multiplicity)
        }
        f = try Fixture()
        f.evidence[3] = .init(id: "exact", revision: f.revision, run: f.run, service: f.service,
            assertion: .exact, scope: .indices(first: 0, last: 0, selector: .arrival))
        _ = try failure(f, kind: .invalid, reason: .referenceConflict)
        f.rules(exceptions: [.init(service: f.service, date: f.date, action: .remove)])
        if case .inactive = C.convert(f.packet) {} else { Issue.record("Inactive event support inspected") }
    }
    @Test(arguments: [0,1,2,3,4]) func indexMappingFailuresAreAtomic(_ mode: Int) throws {
        var f = try Fixture(stops: ["A","B","A"])
        switch mode {
        case 0: f.visits.removeLast()
        case 1: f.visits.swapAt(0,2)
        default:
            let v = f.visits[1]
            f.visits[1] = .init(index: mode == 2 ? Int64.max : v.index, occurrence: mode == 3 ? "O0" : v.occurrence,
                mappingRevision: mode == 4 ? "M2" : "M1", arrival: v.arrival, departure: v.departure, boarding: v.boarding, alighting: v.alighting)
        }
        _ = try failure(f, kind: mode == 0 ? .insufficientEvidence : .invalid, reason: .occurrenceBinding)
    }
    @Test func eligibilityRequiresMatchingScopedEvidence() throws {
        var f = try Fixture(); let v = f.visits[0]
        func replace(_ permission: SyntheticTimetablePermission?) {
            f.visits[0] = .init(index: v.index, occurrence: v.occurrence, mappingRevision: v.mappingRevision,
                arrival: v.arrival, departure: v.departure, boarding: permission, alighting: v.alighting)
        }
        replace(.init(value: .allowed, evidence: "allow")); _ = try facts(f)
        replace(.init(value: .prohibited, evidence: "deny")); _ = try facts(f)
        replace(.init(value: .allowed, evidence: "deny")); _ = try failure(f, kind: .invalid)
        replace(.init(value: .allowed, evidence: nil)); _ = try failure(f, kind: .insufficientEvidence)
        replace(nil); _ = try failure(f, kind: .insufficientEvidence)
    }
    @Test func collectionBoundsBeforeInactiveAndNoInputMutation() throws {
        var f = try Fixture(); let original = f.packet
        f.rules(exceptions: [.init(service: f.service, date: f.date, action: .remove)])
        f.visits = Array(repeating: f.visits[0], count: 257)
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
        #expect(original.visits.count == 2)
        for mode in 0..<3 {
            f = try Fixture()
            if mode == 0 { f.evidence = Array(repeating: f.evidence[0], count: 65) }
            if mode == 1 { f.rules(exceptions: Array(repeating: .init(service: "service", date: f.date, action: .add), count: 257)) }
            if mode == 2 { f.zone = .transitions(Array(repeating: .init(start: 0,end: 1,offset: 0), count: 9)) }
            _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
        }
        f = try Fixture(stops: (0..<257).map { "S\($0)" })
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
    }
    @Test func boundedTokensAndTotalRepeatedText() throws {
        var f = try Fixture(); f.run = String(repeating: "x", count: 65)
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
        f = try Fixture(id: String(repeating: "x", count: 129))
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
        // Each ID is legal individually; two copied snapshots exceed the aggregate budget.
        f = try Fixture(stops: (0..<256).map { String(repeating: "x", count: 125) + String($0) })
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
        f = try Fixture(); f.run = "日本語"
        _ = try failure(f, kind: .invalid, reason: .tokenSyntax)
    }
    @Test func numericExtremesDoNotTrapAndKnownEpochsAreCorrect() throws {
        #expect(try coordinate("2000-01-01") == 946684800)
        #expect(try coordinate("2099-12-31") + 4 * 86400 == Civil.maximum)
        #expect(Civil.localCoordinate(day: Int64.max, seconds: 0) == nil)
        #expect(Civil.add(Int64.max, 1) == nil)
        for offset in [Int64.min, Int64.max, -50401, 50401] {
            var f = try Fixture(); f.zone = .fixed(offset: offset)
            _ = try failure(f, kind: .invalid, reason: .arithmeticRange)
        }
        var f = try Fixture(); f.zone = .transitions([.init(start: Int64.min, end: Int64.max, offset: 0)])
        _ = try failure(f, kind: .invalid, reason: .zoneIntervals)
    }
    @Test func missingInteriorAndOutOfRangeHaveCorrectDiagnostics() throws {
        var f = try Fixture(stops: ["A","B","C"])
        f.visits.remove(at: 1)
        let missing = try failure(f, kind: .insufficientEvidence, reason: .occurrenceBinding)
        #expect(missing.diagnostic.event == nil)
        f = try Fixture(); let v = f.visits[0]
        f.visits[0] = .init(index: Int64.max, occurrence: v.occurrence, mappingRevision: v.mappingRevision,
                           arrival: v.arrival, departure: v.departure, boarding: v.boarding, alighting: v.alighting)
        let unbound = try failure(f, kind: .invalid, reason: .occurrenceBinding)
        #expect(unbound.diagnostic.event == nil)
        f = try Fixture(); f.event(0, .exact(clock: "008:00:00", evidence: "exact"))
        let clock = try failure(f, kind: .invalid, reason: .clockSyntax)
        #expect(clock.diagnostic.reason == .timeQualification)
    }
    @Test func allowedCollectionLimitsAndDuplicateBaseline() throws {
        var f = try Fixture(stops: (0..<256).map { "S\($0)" })
        _ = try facts(f)
        for i in f.evidence.count..<64 {
            f.evidence.append(.init(id: "extra\(i)", revision: f.revision, run: f.run, service: f.service,
                                    assertion: .exact, scope: .wholeRun))
        }
        _ = try facts(f)
        // Eight contiguous intervals, with a neutral offset: semantic result is unchanged.
        let span = (Civil.maximum - Civil.minimum) / 8
        f.zone = .transitions((0..<8).map {
            .init(start: Civil.minimum + Int64($0)*span,
                  end: $0 == 7 ? Civil.maximum : Civil.minimum + Int64($0+1)*span, offset: 0)
        })
        _ = try facts(f)
        // 256 unique valid exceptions, no enumeration in the converter itself.
        var dates: [String] = []
        for month in 1...12 {
            for day in 1...28 { dates.append(String(format: "2026-%02d-%02d", month, day)) }
        }
        f.rules(mode: .exceptionOnly, start: "2026-01-01", end: "2026-12-31",
                exceptions: dates.prefix(256).map { .init(service: "service", date: $0, action: .add) })
        _ = try facts(f)
        let baseline = SyntheticTimetableBaseline(start: "2026-04-01", end: "2026-04-30", weekdays: Fixture.weekdays)
        f.calendar = .init(mode: .weekly, coverageStart: "2026-04-01", coverageEnd: "2026-04-30",
                           baselines: [baseline, baseline], exceptions: [], completenessEvidence: "calendar")
        _ = try failure(f, kind: .invalid, reason: .baselineConflict)
    }
    @Test func nestedSnapshotBoundsAndExistingSegmentInvariants() throws {
        var f = try Fixture(stops: (0..<256).map { "S\($0)" })
        let b = f.binding
        let lines = try (0..<255).map { i in
            let id = try #require(LineID("L\(i)"))
            return try #require(TripLineSegment(lineID: id, startIndex: i, endIndex: i+1))
        }
        let types = try (0..<255).map { i in
            let id = try #require(ServiceTypeID("T\(i)"))
            return try #require(TripServiceTypeSegment(serviceTypeID: id, startIndex: i, endIndex: i+1))
        }
        let trip = try #require(Trip(id: b.trip.id, stopSequence: b.trip.stopSequence, lineSegments: lines,
                                    coverage: b.trip.coverage, serviceTypeSegments: types))
        let binding = try #require(TimetableOccurrenceBinding(address: b.address, trip: trip))
        let manifest = SyntheticTimetableManifest(binding: binding, revision: f.revision, profileEvidence: "profile", executionEvidence: "once")
        let packet = P(binding: binding, serviceDate: f.date, run: f.run, service: f.service, revision: f.revision,
                       manifest: manifest, evidence: f.evidence, calendar: f.calendar, zone: f.zone, visits: f.visits)
        if case .success = C.convert(packet) {} else { Issue.record("Maximum structurally possible segment list rejected") }
        // Existing Trip requires one movement per segment: <=256 stops imply <=255 segments.
        // Over-limit snapshot tested independently in manifest, not just the packet binding.
        let oversized = try Fixture(stops: (0..<257).map { "S\($0)" })
        f = try Fixture()
        f.manifest = .init(binding: oversized.binding, revision: f.revision, profileEvidence: "profile", executionEvidence: "once")
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
    }
    @Test func exactTokenAndSnapshotIDLimits() throws {
        var f = try Fixture(id: String(repeating: "t", count: 128))
        // Unused but well-formed token exactly at 64 bytes is still part of the checked input.
        f.evidence.append(.init(id: String(repeating: "x", count: 64), revision: f.revision,
            run: f.run, service: f.service, assertion: .exact, scope: .wholeRun))
        _ = try facts(f)
        f.evidence.append(.init(id: String(repeating: "y", count: 65), revision: f.revision,
            run: f.run, service: f.service, assertion: .exact, scope: .wholeRun))
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
    }
    @Test func exactAggregateTextBoundaryCountsRepeatedCopies() throws {
        // Two snapshots contribute 60,276 stop-ID bytes. Other copied tokens/date/clock
        // fields contribute 5,260 bytes, including one unused four-byte evidence ID.
        // Total is exactly 65,536; adding one ASCII byte to that ID crosses the boundary.
        let stops = (0..<256).map { i in
            String(repeating: "x", count: (i < 186 ? 118 : 117) - 3) + String(format: "%03d", i)
        }
        var f = try Fixture(stops: stops)
        f.evidence.append(.init(id: "pads", revision: f.revision, run: f.run, service: f.service,
                                assertion: .exact, scope: .wholeRun))
        _ = try facts(f)
        f.evidence[f.evidence.count-1] = .init(id: "padsx", revision: f.revision, run: f.run, service: f.service,
                                             assertion: .exact, scope: .wholeRun)
        _ = try failure(f, kind: .unsupported, reason: .resourceLimit)
    }
}
#endif
