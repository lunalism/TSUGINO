nonisolated enum TimetableEventKind: Int, Sendable {
    case arrival
    case departure
}

/// A location within a supplied snapshot, never a raw source-row index.
nonisolated struct TimetableEventLocation: Equatable, Sendable {
    let originalIndex: Int
    let kind: TimetableEventKind?

    init?(originalIndex: Int, kind: TimetableEventKind? = nil, stopCount: Int) {
        guard originalIndex >= 0, originalIndex < stopCount else { return nil }
        self.originalIndex = originalIndex
        self.kind = kind
    }

    func precedes(_ other: TimetableEventLocation) -> Bool {
        guard let kind, let otherKind = other.kind else { return false }
        return originalIndex < other.originalIndex
            || (originalIndex == other.originalIndex && kind.rawValue < otherKind.rawValue)
    }
}

/// Bounded categories; this slice does not implement activation or source interpretation.
nonisolated enum TimetableDiagnosticReason: Sendable {
    case viewUnavailable
    case activationUnavailable
    case occurrenceBinding
    case timeQualification
    case chronologyConflict
}

nonisolated struct TimetableDiagnostic: Sendable {
    let reason: TimetableDiagnosticReason
    let event: TimetableEventLocation?
    let laterEvent: TimetableEventLocation?

    init?(reason: TimetableDiagnosticReason, event: TimetableEventLocation? = nil,
          laterEvent: TimetableEventLocation? = nil) {
        switch reason {
        case .viewUnavailable, .activationUnavailable:
            guard event == nil, laterEvent == nil else { return nil }
        case .occurrenceBinding, .timeQualification:
            guard laterEvent == nil else { return nil }
        case .chronologyConflict:
            guard let event, let laterEvent, event.precedes(laterEvent) else { return nil }
        }
        self.reason = reason
        self.event = event
        self.laterEvent = laterEvent
    }
}
