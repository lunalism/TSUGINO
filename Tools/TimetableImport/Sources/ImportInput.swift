import Foundation

// Tool-local normalized values. Source/profile authority is checked by ImportAuthority before conversion.
nonisolated struct ImportRevision: Equatable, Sendable {
    let source: String
    let profile: String
    let zone: String
    let mapping: String
}
nonisolated enum ImportSelector: Int, Sendable { case arrival, departure, boarding, alighting }
nonisolated enum ImportAssertion: Sendable {
    case profileApplicable, calendarComplete, singleExecution, multipleExecutions, unknownMultiplicity
    case exact, estimated, allowed, prohibited
}
nonisolated enum ImportScope: Sendable {
    case wholeRun
    case indices(first: Int64, last: Int64, selector: ImportSelector)
}
nonisolated struct ImportEvidence: Sendable {
    let id: String
    let revision: ImportRevision
    let run: String
    let service: String
    let assertion: ImportAssertion
    let scope: ImportScope
}
nonisolated struct ImportManifest: Sendable {
    let binding: TimetableOccurrenceBinding
    let revision: ImportRevision
    let profileEvidence: String?
    let executionEvidence: String?
}
nonisolated struct ImportWeekdays: Sendable {
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
nonisolated struct ImportBaseline: Sendable {
    let start: String
    let end: String
    let weekdays: ImportWeekdays
}
nonisolated enum ImportCalendarMode: Sendable { case weekly, exceptionOnly, unsupported }
nonisolated enum ImportExceptionAction: Sendable { case add, remove, invalid }
nonisolated struct ImportException: Sendable {
    let service: String
    let date: String
    let action: ImportExceptionAction
}
nonisolated struct ImportCalendar: Sendable {
    let mode: ImportCalendarMode?
    let coverageStart: String
    let coverageEnd: String
    let baselines: [ImportBaseline]
    let exceptions: [ImportException]
    let completenessEvidence: String?
}
nonisolated struct ImportZoneInterval: Sendable {
    let start: Int64
    let end: Int64
    let offset: Int64
}
nonisolated enum ImportZone: Sendable {
    case fixed(offset: Int64)
    case transitions([ImportZoneInterval])
    case unsupported
}
nonisolated enum ImportEvent: Sendable {
    case missing
    case exact(clock: String, evidence: String?)
    case estimated(clock: String, evidence: String?)
    case unqualified(clock: String)
}
nonisolated struct ImportPermission: Sendable {
    let value: TimetableEligibility
    let evidence: String?
}
nonisolated struct ImportVisit: Sendable {
    let index: Int64
    let occurrence: String
    let mappingRevision: String
    let expectedOccurrence: String?
    let arrival: ImportEvent?
    let departure: ImportEvent?
    let boarding: ImportPermission?
    let alighting: ImportPermission?
}
nonisolated struct ImportPacket: Sendable {
    let binding: TimetableOccurrenceBinding
    let serviceDate: String
    let run: String
    let service: String
    let revision: ImportRevision
    let manifest: ImportManifest?
    let evidence: [ImportEvidence]
    let calendar: ImportCalendar?
    let zone: ImportZone?
    let visits: [ImportVisit]
}

nonisolated enum ImportInactiveReason: Sendable { case baselineOff, outsideBaseline, unlistedDate, explicitRemoval }
nonisolated enum ImportFailureKind: Int, Sendable { case insufficientEvidence, unsupported, invalid }
/// Fixed reasons only: never carry an input string or external error.
nonisolated enum ImportReason: String, Sendable {
    case resourceLimit, tokenSyntax, revisionConflict, viewUnavailable, profileUnsupported
    case referenceConflict, referenceUnavailable, referenceScope, multiplicity
    case serviceDate, dateRange, dateMismatch, activationUnavailable, calendarCoverage
    case calendarCompleteness, calendarMode, baselineConflict, duplicateException, exceptionRecord
    case zoneUnavailable, zoneKind, zoneIntervals, zoneCoverage, arithmeticRange
    case occurrenceBinding, timeQualification, clockSyntax, hourRange
    case nonexistentLocalTime, ambiguousLocalTime, chronologyConflict
}
nonisolated struct ImportFailure: Sendable {
    // Aggregate severity and primary diagnostic intentionally need not name the same fault.
    let kind: ImportFailureKind
    let reason: ImportReason
    let diagnostic: TimetableDiagnostic
}
nonisolated enum ImportOutcome: Sendable {
    case success(TimetableOccurrenceFacts)
    case inactive(ImportInactiveReason)
    case unsupported(ImportFailure)
    case insufficientEvidence(ImportFailure)
    case invalid(ImportFailure)
}
