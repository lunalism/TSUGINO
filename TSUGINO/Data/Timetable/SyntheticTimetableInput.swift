#if DEBUG
import Foundation

// DEC-085: invented immutable inputs only. No decoder, file reader or real profile.
nonisolated struct SyntheticTimetableRevision: Equatable, Sendable {
    let source: String
    let profile: String
    let zone: String
    let mapping: String
}
nonisolated enum SyntheticTimetableSelector: Int, Sendable { case arrival, departure, boarding, alighting }
nonisolated enum SyntheticTimetableAssertion: Sendable {
    case profileApplicable, calendarComplete, singleExecution, multipleExecutions, unknownMultiplicity
    case exact, estimated, allowed, prohibited
}
nonisolated enum SyntheticTimetableScope: Sendable {
    case wholeRun
    case indices(first: Int64, last: Int64, selector: SyntheticTimetableSelector)
}
nonisolated struct SyntheticTimetableEvidence: Sendable {
    let id: String
    let revision: SyntheticTimetableRevision
    let run: String
    let service: String
    let assertion: SyntheticTimetableAssertion
    let scope: SyntheticTimetableScope
}
nonisolated struct SyntheticTimetableManifest: Sendable {
    let binding: TimetableOccurrenceBinding
    let revision: SyntheticTimetableRevision
    let profileEvidence: String?
    let executionEvidence: String?
}
nonisolated struct SyntheticTimetableWeekdays: Sendable {
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool

    func contains(_ mondayIndex: Int) -> Bool {
        [monday, tuesday, wednesday, thursday, friday, saturday, sunday][mondayIndex]
    }
}
nonisolated struct SyntheticTimetableBaseline: Sendable {
    let start: String
    let end: String
    let weekdays: SyntheticTimetableWeekdays
}
nonisolated enum SyntheticTimetableCalendarMode: Sendable { case weekly, exceptionOnly, unsupported }
nonisolated enum SyntheticTimetableExceptionAction: Sendable { case add, remove, invalid }
nonisolated struct SyntheticTimetableException: Sendable {
    let service: String
    let date: String
    let action: SyntheticTimetableExceptionAction
}
nonisolated struct SyntheticTimetableCalendar: Sendable {
    let mode: SyntheticTimetableCalendarMode?
    let coverageStart: String
    let coverageEnd: String
    let baselines: [SyntheticTimetableBaseline]
    let exceptions: [SyntheticTimetableException]
    let completenessEvidence: String?
}
nonisolated struct SyntheticTimetableZoneInterval: Sendable {
    let start: Int64
    let end: Int64
    let offset: Int64
}
nonisolated enum SyntheticTimetableZone: Sendable {
    case fixed(offset: Int64)
    case transitions([SyntheticTimetableZoneInterval])
    case unsupported
}
nonisolated enum SyntheticTimetableEvent: Sendable {
    case missing
    case exact(clock: String, evidence: String?)
    case estimated(clock: String, evidence: String?)
    case unqualified(clock: String)
}
nonisolated struct SyntheticTimetablePermission: Sendable {
    let value: TimetableEligibility
    let evidence: String?
}
nonisolated struct SyntheticTimetableVisit: Sendable {
    let index: Int64
    let occurrence: String
    let mappingRevision: String
    let arrival: SyntheticTimetableEvent?
    let departure: SyntheticTimetableEvent?
    let boarding: SyntheticTimetablePermission?
    let alighting: SyntheticTimetablePermission?
}
nonisolated struct SyntheticTimetablePacket: Sendable {
    let binding: TimetableOccurrenceBinding
    let serviceDate: String
    let run: String
    let service: String
    let revision: SyntheticTimetableRevision
    let manifest: SyntheticTimetableManifest?
    let evidence: [SyntheticTimetableEvidence]
    let calendar: SyntheticTimetableCalendar?
    let zone: SyntheticTimetableZone?
    let visits: [SyntheticTimetableVisit]
}

nonisolated enum SyntheticTimetableInactiveReason: Sendable { case baselineOff, outsideBaseline, unlistedDate, explicitRemoval }
nonisolated enum SyntheticTimetableFailureKind: Int, Sendable { case insufficientEvidence, unsupported, invalid }
/// Fixed reasons only: never carry an input string or external error.
nonisolated enum SyntheticTimetableReason: String, Sendable {
    case resourceLimit, tokenSyntax, revisionConflict, viewUnavailable, profileUnsupported
    case referenceConflict, referenceUnavailable, referenceScope, multiplicity
    case serviceDate, dateRange, dateMismatch, activationUnavailable, calendarCoverage
    case calendarCompleteness, calendarMode, baselineConflict, duplicateException, exceptionRecord
    case zoneUnavailable, zoneKind, zoneIntervals, zoneCoverage, arithmeticRange
    case occurrenceBinding, timeQualification, clockSyntax, hourRange
    case nonexistentLocalTime, ambiguousLocalTime, chronologyConflict
}
nonisolated struct SyntheticTimetableFailure: Sendable {
    // Aggregate severity and primary diagnostic intentionally need not name the same fault.
    let kind: SyntheticTimetableFailureKind
    let reason: SyntheticTimetableReason
    let diagnostic: TimetableDiagnostic
}
nonisolated enum SyntheticTimetableOutcome: Sendable {
    case success(TimetableOccurrenceFacts)
    case inactive(SyntheticTimetableInactiveReason)
    case unsupported(SyntheticTimetableFailure)
    case insufficientEvidence(SyntheticTimetableFailure)
    case invalid(SyntheticTimetableFailure)
}
#endif
