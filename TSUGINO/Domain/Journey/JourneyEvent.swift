// Something that happened to a Journey, as a Phase 5 output (DEC-063 F).
//
// Notifications consume events (DEC-010, Phase 10); Live Activities read
// state instead (DEC-030). An interruption or an ending is a `phaseChanged`
// event to `interrupted` or `ended`, which already carries its reason, so
// there is no separate event for either. Detecting any event is Phase 5.

import Foundation

/// What kind of change a `JourneyEvent` reports.
nonisolated enum JourneyEventKind: Sendable {
    case phaseChanged(from: JourneyPhase, to: JourneyPhase)
    case legStarted(legIndex: Int)
    case tripSelected(legIndex: Int)
    case tripReplaced(legIndex: Int)
    case freshnessChanged(from: RealtimeFreshness, to: RealtimeFreshness)
    case recovered
}

/// A change to a Journey at a given instant.
nonisolated struct JourneyEvent: Sendable {
    let occurredAt: Date
    let kind: JourneyEventKind

    /// Fails for a change that changes nothing — `phaseChanged` or
    /// `freshnessChanged` with equal ends — and for a negative leg index.
    init?(occurredAt: Date, kind: JourneyEventKind) {
        switch kind {
        case .phaseChanged(let from, let to):
            guard from != to else { return nil }
        case .freshnessChanged(let from, let to):
            guard from != to else { return nil }
        case .legStarted(let legIndex), .tripSelected(let legIndex), .tripReplaced(let legIndex):
            guard legIndex >= 0 else { return nil }
        case .recovered:
            break
        }

        self.occurredAt = occurredAt
        self.kind = kind
    }
}
