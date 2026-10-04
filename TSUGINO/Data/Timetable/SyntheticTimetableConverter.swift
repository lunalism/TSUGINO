#if DEBUG
import Foundation

/// DEC-085: synchronous, finite, invented-only and atomic. No retained mutable state.
nonisolated enum SyntheticTimetableConverter {
    typealias Kind = SyntheticTimetableFailureKind
    typealias Reason = SyntheticTimetableReason
    typealias Civil = SyntheticTimetableCivilTime

    private struct Fault {
        let kind: Kind
        let reason: Reason
        let diagnostic: TimetableDiagnostic
    }
    private struct Findings {
        var faults: [Fault] = []
        mutating func add(_ kind: Kind, _ reason: Reason, _ category: TimetableDiagnosticReason,
                          index: Int? = nil, event: TimetableEventKind? = nil, count: Int = 0) {
            let location = index.flatMap { TimetableEventLocation(originalIndex: $0, kind: event, stopCount: count) }
            // All call sites use a non-chronology category. Chronology reuses Domain's diagnostic.
            if let diagnostic = TimetableDiagnostic(reason: category, event: location) {
                faults.append(Fault(kind: kind, reason: reason, diagnostic: diagnostic))
            }
        }
        var outcome: SyntheticTimetableOutcome? {
            guard let primary = faults.min(by: { Self.precedes($0, $1) }),
                  let severity = faults.map(\.kind).max(by: { $0.rawValue < $1.rawValue }) else { return nil }
            let failure = SyntheticTimetableFailure(kind: severity, reason: primary.reason, diagnostic: primary.diagnostic)
            switch severity {
            case .invalid: return .invalid(failure)
            case .unsupported: return .unsupported(failure)
            case .insufficientEvidence: return .insufficientEvidence(failure)
            }
        }
        static func rank(_ category: TimetableDiagnosticReason) -> Int {
            switch category {
            case .viewUnavailable: 0
            case .activationUnavailable: 1
            case .occurrenceBinding: 2
            case .timeQualification: 3
            case .chronologyConflict: 4
            }
        }
        static func precedes(_ a: Fault, _ b: Fault) -> Bool {
            let ac = rank(a.diagnostic.reason), bc = rank(b.diagnostic.reason)
            if ac != bc { return ac < bc }
            let ai = a.diagnostic.event?.originalIndex ?? -1, bi = b.diagnostic.event?.originalIndex ?? -1
            if ai != bi { return ai < bi }
            let ae = a.diagnostic.event?.kind?.rawValue ?? -1, be = b.diagnostic.event?.kind?.rawValue ?? -1
            if ae != be { return ae < be }
            return a.reason.rawValue < b.reason.rawValue
        }
    }

    static func convert(_ packet: SyntheticTimetablePacket) -> SyntheticTimetableOutcome {
        var findings = Findings()
        // Counts are checked without traversing untrusted collections. Text reads use prefixes.
        guard bounded(packet, findings: &findings) else { return findings.outcome! }
        var evidence: [String: SyntheticTimetableEvidence] = [:]
        for item in packet.evidence {
            if evidence.updateValue(item, forKey: item.id) != nil {
                findings.add(.invalid, .referenceConflict, .viewUnavailable)
            }
            if item.revision != packet.revision || item.run != packet.run || item.service != packet.service {
                findings.add(.invalid, .revisionConflict, .viewUnavailable)
            }
            if case .indices(let first, let last, _) = item.scope,
               first < 0 || last < first || last >= Int64(packet.binding.trip.stopSequence.count) {
                findings.add(.invalid, .referenceScope, .viewUnavailable)
            }
        }
        if packet.revision.profile != "invented-civil-day-v1" {
            findings.add(.unsupported, .profileUnsupported, .viewUnavailable)
        }
        let day = parseDate(packet.serviceDate, findings: &findings)
        if packet.binding.address.serviceDate.label != packet.serviceDate {
            findings.add(.invalid, .dateMismatch, .occurrenceBinding)
        }
        if let manifest = packet.manifest {
            if manifest.revision != packet.revision { findings.add(.invalid, .revisionConflict, .viewUnavailable) }
            if !manifest.binding.matches(packet.binding) { findings.add(.invalid, .occurrenceBinding, .occurrenceBinding) }
            require(manifest.profileEvidence, assertion: .profileApplicable, evidence: evidence,
                    findings: &findings, category: .viewUnavailable)
            if let id = manifest.executionEvidence, let item = evidence[id] {
                guardWhole(item, findings: &findings)
                switch item.assertion {
                case .singleExecution: break
                case .multipleExecutions: findings.add(.unsupported, .multiplicity, .viewUnavailable)
                case .unknownMultiplicity: findings.add(.insufficientEvidence, .multiplicity, .viewUnavailable)
                default: findings.add(.invalid, .referenceConflict, .viewUnavailable)
                }
            } else { findings.add(.insufficientEvidence, .referenceUnavailable, .viewUnavailable) }
        } else { findings.add(.insufficientEvidence, .viewUnavailable, .viewUnavailable) }
        validateZone(packet.zone, findings: &findings)
        if let result = findings.outcome { return result }
        guard let day else { return unavailable(.serviceDate, category: .activationUnavailable) }

        let inactive = activation(packet, day: day, evidence: evidence, findings: &findings)
        if let result = findings.outcome { return result }
        if let inactive { return .inactive(inactive) }

        let count = packet.binding.trip.stopSequence.count
        if packet.visits.count < count { findings.add(.insufficientEvidence, .occurrenceBinding, .occurrenceBinding) }
        if packet.visits.count > count { findings.add(.invalid, .occurrenceBinding, .occurrenceBinding) }
        var indices = Set<Int64>(), occurrences = Set<String>()
        var previousIndex: Int64?
        for visit in packet.visits {
            if !indices.insert(visit.index).inserted || !occurrences.insert(visit.occurrence).inserted ||
                visit.index < 0 || visit.index >= Int64(count) ||
                previousIndex.map({ visit.index <= $0 }) == true ||
                visit.mappingRevision != packet.revision.mapping {
                findings.add(.invalid, .occurrenceBinding, .occurrenceBinding,
                             index: visit.index >= 0 && visit.index < Int64(count) ? Int(visit.index) : nil, count: count)
            }
            previousIndex = visit.index
        }
        if let result = findings.outcome { return result }

        var visits: [TimetableVisitFacts] = []
        for (index, input) in packet.visits.enumerated() {
            let arrival = qualify(input.arrival, index: index, selector: .arrival, packet: packet,
                                  day: day, evidence: evidence, findings: &findings)
            let departure = qualify(input.departure, index: index, selector: .departure, packet: packet,
                                    day: day, evidence: evidence, findings: &findings)
            let boarding = permission(input.boarding, index: index, selector: .boarding,
                                      count: count, evidence: evidence, findings: &findings)
            let alighting = permission(input.alighting, index: index, selector: .alighting,
                                      count: count, evidence: evidence, findings: &findings)
            if let arrival, let departure, let boarding, let alighting,
               let visit = TimetableVisitFacts(binding: packet.binding, originalIndex: index,
                    arrival: arrival, departure: departure, boarding: boarding, alighting: alighting) {
                visits.append(visit)
            }
        }
        if let result = findings.outcome { return result }
        if let diagnostic = TimetableOccurrenceFacts.validationDiagnostic(binding: packet.binding, visits: visits) {
            return .invalid(.init(kind: .invalid, reason: .chronologyConflict, diagnostic: diagnostic))
        }
        guard let facts = TimetableOccurrenceFacts(binding: packet.binding, visits: visits) else {
            return unavailable(.occurrenceBinding, category: .occurrenceBinding)
        }
        return .success(facts)
    }

    private static func unavailable(_ reason: Reason, category: TimetableDiagnosticReason) -> SyntheticTimetableOutcome {
        var findings = Findings()
        findings.add(.insufficientEvidence, reason, category)
        return findings.outcome!
    }

    private static func guardWhole(_ item: SyntheticTimetableEvidence, findings: inout Findings) {
        if case .indices = item.scope { findings.add(.invalid, .referenceScope, .viewUnavailable) }
    }
    private static func require(_ id: String?, assertion: SyntheticTimetableAssertion,
                                evidence: [String: SyntheticTimetableEvidence], findings: inout Findings,
                                category: TimetableDiagnosticReason, index: Int? = nil,
                                selector: SyntheticTimetableSelector? = nil, count: Int = 0) {
        let event: TimetableEventKind? = selector == .arrival ? .arrival : selector == .departure ? .departure : nil
        guard let id, let item = evidence[id] else {
            findings.add(.insufficientEvidence, .referenceUnavailable, category, index: index, event: event, count: count)
            return
        }
        var matches = item.assertion == assertion
        if case .indices(let first, let last, let applies) = item.scope {
            if let index, let selector { matches = matches && first <= Int64(index) && last >= Int64(index) && applies == selector }
            else { matches = false }
        }
        if !matches { findings.add(.invalid, .referenceConflict, category, index: index, event: event, count: count) }
    }

    private static func parseDate(_ text: String, findings: inout Findings) -> Int64? {
        switch Civil.date(text) {
        case .value(let day): return day
        case .invalid: findings.add(.invalid, .serviceDate, .activationUnavailable)
        case .unsupported: findings.add(.unsupported, .dateRange, .activationUnavailable)
        }
        return nil
    }

    private static func validateZone(_ zone: SyntheticTimetableZone?, findings: inout Findings) {
        guard let zone else { findings.add(.insufficientEvidence, .zoneUnavailable, .activationUnavailable); return }
        func offset(_ n: Int64) {
            if !(-Civil.offsetLimit...Civil.offsetLimit).contains(n) {
                findings.add(.invalid, .arithmeticRange, .activationUnavailable)
            }
        }
        switch zone {
        case .unsupported: findings.add(.unsupported, .zoneKind, .activationUnavailable)
        case .fixed(let n): offset(n)
        case .transitions(let table):
            if table.isEmpty { findings.add(.insufficientEvidence, .zoneCoverage, .activationUnavailable) }
            var previous: Int64?
            for entry in table {
                offset(entry.offset)
                if entry.start < Civil.minimum || entry.end > Civil.maximum || entry.start >= entry.end {
                    findings.add(.invalid, .zoneIntervals, .activationUnavailable)
                }
                if let previous {
                    if entry.start < previous { findings.add(.invalid, .zoneIntervals, .activationUnavailable) }
                    if entry.start > previous { findings.add(.insufficientEvidence, .zoneCoverage, .activationUnavailable) }
                }
                previous = entry.end
            }
        }
    }

    private static func activation(_ packet: SyntheticTimetablePacket, day: Int64,
                                   evidence: [String: SyntheticTimetableEvidence], findings: inout Findings) -> SyntheticTimetableInactiveReason? {
        guard let calendar = packet.calendar else {
            findings.add(.insufficientEvidence, .activationUnavailable, .activationUnavailable); return nil
        }
        require(calendar.completenessEvidence, assertion: .calendarComplete, evidence: evidence,
                findings: &findings, category: .activationUnavailable)
        let start = parseDate(calendar.coverageStart, findings: &findings)
        let end = parseDate(calendar.coverageEnd, findings: &findings)
        if let start, let end {
            if start > end { findings.add(.invalid, .calendarCoverage, .activationUnavailable) }
            else if day < start || day > end { findings.add(.insufficientEvidence, .calendarCoverage, .activationUnavailable) }
        }
        var baselineActive = false, insideBaseline = false
        for baseline in calendar.baselines {
            let bs = parseDate(baseline.start, findings: &findings), be = parseDate(baseline.end, findings: &findings)
            if let bs, let be, let start, let end {
                if bs > be || bs < start || be > end { findings.add(.invalid, .baselineConflict, .activationUnavailable) }
                insideBaseline = bs <= day && day <= be
                baselineActive = insideBaseline && baseline.weekdays.contains(Int((day + 3) % 7))
            }
        }
        switch calendar.mode {
        case nil: findings.add(.insufficientEvidence, .calendarMode, .activationUnavailable)
        case .unsupported: findings.add(.unsupported, .calendarMode, .activationUnavailable)
        case .weekly:
            if calendar.baselines.isEmpty { findings.add(.insufficientEvidence, .activationUnavailable, .activationUnavailable) }
        case .exceptionOnly:
            if !calendar.baselines.isEmpty { findings.add(.invalid, .baselineConflict, .activationUnavailable) }
        }
        var dates = Set<String>(), requested: SyntheticTimetableExceptionAction?
        for exception in calendar.exceptions {
            if !dates.insert(exception.date).inserted { findings.add(.invalid, .duplicateException, .activationUnavailable) }
            if exception.service != packet.service || exception.action == .invalid {
                findings.add(.invalid, .exceptionRecord, .activationUnavailable)
            }
            let date = parseDate(exception.date, findings: &findings)
            if let date, let start, let end, date < start || date > end {
                findings.add(.invalid, .exceptionRecord, .activationUnavailable)
            }
            if date == day { requested = exception.action }
        }
        if requested == .add { return nil }
        if requested == .remove { return .explicitRemoval }
        if calendar.mode == .exceptionOnly { return .unlistedDate }
        return baselineActive ? nil : insideBaseline ? .baselineOff : .outsideBaseline
    }

    private static func qualify(_ input: SyntheticTimetableEvent?, index: Int, selector: SyntheticTimetableSelector,
                                packet: SyntheticTimetablePacket, day: Int64,
                                evidence: [String: SyntheticTimetableEvidence], findings: inout Findings) -> TimetableTime? {
        let kind: TimetableEventKind = selector == .arrival ? .arrival : .departure
        let count = packet.binding.trip.stopSequence.count
        func fault(_ severity: Kind, _ reason: Reason) {
            findings.add(severity, reason, .timeQualification, index: index, event: kind, count: count)
        }
        guard let input else { fault(.insufficientEvidence, .timeQualification); return nil }
        let clock: String, isExact: Bool
        switch input {
        case .missing: return .missing
        case .unqualified: fault(.insufficientEvidence, .timeQualification); return nil
        case .exact(let text, let id):
            clock = text; isExact = true
            require(id, assertion: .exact, evidence: evidence, findings: &findings,
                    category: .timeQualification, index: index, selector: selector, count: count)
        case .estimated(let text, let id):
            clock = text; isExact = false
            require(id, assertion: .estimated, evidence: evidence, findings: &findings,
                    category: .timeQualification, index: index, selector: selector, count: count)
        }
        let seconds: Int64
        switch Civil.clock(clock) {
        case .invalid: fault(.invalid, .clockSyntax); return nil
        case .unsupported: fault(.unsupported, .hourRange); return nil
        case .value(let value): seconds = value
        }
        guard let local = Civil.localCoordinate(day: day, seconds: seconds), let zone = packet.zone else {
            fault(.invalid, .arithmeticRange); return nil
        }
        switch Civil.resolve(local: local, zone: zone) {
        case .success(let instant): return isExact ? .exact(instant) : .estimated(instant)
        case .failure(let failure):
            switch failure {
            case .arithmeticRange: fault(.invalid, .arithmeticRange)
            case .zoneCoverage: fault(.insufficientEvidence, .zoneCoverage)
            case .nonexistentLocalTime: fault(.insufficientEvidence, .nonexistentLocalTime)
            case .ambiguousLocalTime: fault(.insufficientEvidence, .ambiguousLocalTime)
            }
            return nil
        }
    }

    private static func permission(_ input: SyntheticTimetablePermission?, index: Int,
                                   selector: SyntheticTimetableSelector, count: Int,
                                   evidence: [String: SyntheticTimetableEvidence], findings: inout Findings) -> TimetableEligibility? {
        guard let input else {
            findings.add(.insufficientEvidence, .timeQualification, .timeQualification, index: index, count: count)
            return nil
        }
        switch input.value {
        case .allowed, .prohibited:
            require(input.evidence, assertion: input.value == .allowed ? .allowed : .prohibited,
                    evidence: evidence, findings: &findings, category: .timeQualification,
                    index: index, selector: selector, count: count)
        case .unknown:
            // No affirmative support is required. If supplied, do not silently ignore it.
            if input.evidence != nil {
                findings.add(.invalid, .referenceConflict, .timeQualification, index: index, count: count)
            }
        }
        return input.value
    }

    private static func bounded(_ packet: SyntheticTimetablePacket, findings: inout Findings) -> Bool {
        func resource() { findings.add(.unsupported, .resourceLimit, .viewUnavailable) }
        let snapshots = [packet.binding.trip] + (packet.manifest.map { [$0.binding.trip] } ?? [])
        guard packet.visits.count <= 256, packet.evidence.count <= 64,
              snapshots.allSatisfy({ $0.stopSequence.count <= 256 && $0.lineSegments.count <= 256 && $0.serviceTypeSegments.count <= 256 }),
              packet.calendar.map({ $0.exceptions.count <= 256 }) ?? true else { resource(); return false }
        if case .transitions(let table) = packet.zone, table.count > 8 { resource(); return false }
        // Multiple baselines are a semantic contradiction, not a large array to traverse.
        if let calendar = packet.calendar, calendar.baselines.count > 1 {
            findings.add(.invalid, .baselineConflict, .activationUnavailable); return false
        }
        var total = 0
        func text(_ value: String, limit: Int, syntax: Reason? = nil, ascii: Bool = false) {
            let bytes = Array(value.utf8.prefix(limit + 1))
            if bytes.count > limit {
                if let syntax {
                    findings.add(.invalid, syntax, syntax == .clockSyntax ? .timeQualification : .activationUnavailable)
                } else { resource() }
                return
            }
            total += bytes.count // At most a few thousand bounded fields; cannot overflow Int.
            if ascii && (bytes.isEmpty || !bytes.allSatisfy({ $0 > 32 && $0 < 127 })) {
                findings.add(.invalid, .tokenSyntax, .viewUnavailable)
            }
        }
        func token(_ value: String?) { if let value { text(value, limit: 64, ascii: true) } }
        func revision(_ value: SyntheticTimetableRevision) {
            token(value.source); token(value.profile); token(value.zone); token(value.mapping)
        }
        func date(_ value: String) {
            text(value, limit: 10, syntax: .serviceDate)
            if value.utf8.prefix(11).count != 10 { findings.add(.invalid, .serviceDate, .activationUnavailable) }
        }
        func event(_ value: SyntheticTimetableEvent?) {
            let clock: String
            switch value {
            case .exact(let raw, let ref), .estimated(let raw, let ref): clock = raw; token(ref)
            case .unqualified(let raw): clock = raw
            default: return
            }
            text(clock, limit: 8, syntax: .clockSyntax)
            if clock.utf8.prefix(9).count != 8 { findings.add(.invalid, .clockSyntax, .timeQualification) }
        }
        for trip in snapshots {
            text(trip.id.rawValue, limit: 128)
            for stop in trip.stopSequence { text(stop.rawValue, limit: 128) }
            for segment in trip.lineSegments { text(segment.lineID.rawValue, limit: 128) }
            for segment in trip.serviceTypeSegments { text(segment.serviceTypeID.rawValue, limit: 128) }
        }
        // Include every copied address ID/date as well as its snapshot and every repeated token.
        text(packet.binding.address.tripID.rawValue, limit: 128)
        date(packet.binding.address.serviceDate.label); date(packet.serviceDate)
        token(packet.run); token(packet.service); revision(packet.revision)
        if let manifest = packet.manifest {
            text(manifest.binding.address.tripID.rawValue, limit: 128)
            date(manifest.binding.address.serviceDate.label)
            revision(manifest.revision); token(manifest.profileEvidence); token(manifest.executionEvidence)
        }
        for entry in packet.evidence { token(entry.id); revision(entry.revision); token(entry.run); token(entry.service) }
        if let calendar = packet.calendar {
            date(calendar.coverageStart); date(calendar.coverageEnd); token(calendar.completenessEvidence)
            for b in calendar.baselines { date(b.start); date(b.end) }
            for e in calendar.exceptions { token(e.service); date(e.date) }
        }
        for visit in packet.visits {
            token(visit.occurrence); token(visit.mappingRevision)
            event(visit.arrival); event(visit.departure)
            token(visit.boarding?.evidence); token(visit.alighting?.evidence)
        }
        if total > 65_536 { resource() }
        return findings.outcome == nil
    }
}
#endif
