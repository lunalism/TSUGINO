// A Journey's runtime state at one instant (DEC-063 D, ARCHITECTURE.md
// §5.6).
//
// Separate from the route definition and never written into `Journey`
// (DEC-062). It stores no current or next station, remaining-stop count, or
// progress: those are derived from the position and the Journey by Phase 5
// (DEC-011), and progress is an approximate presentation value (DEC-038).
// Every time is an input — the Domain reads no clock — which keeps state
// deterministic. Whether the state fits its Journey is checked by
// `ActiveJourney`.

import Foundation

/// The runtime state of the Journey identified by `journeyID`.
nonisolated struct JourneyState: Sendable {
    let journeyID: JourneyID
    let phase: JourneyPhase

    /// The current leg's freshness only (DEC-063 C).
    let freshness: RealtimeFreshness

    /// The last realtime-confirmed progress, if any.
    let lastConfirmedAt: Date?

    /// The instant this state describes.
    let asOf: Date

    /// Fails unless, from the value alone (DEC-063 D):
    ///
    /// 1. `lastConfirmedAt`, when present, is not after `asOf`;
    /// 2. the freshness timestamp, when present, is not after `asOf`;
    /// 3. an `observed` position has realtime-derived freshness;
    /// 4. a `trainObservedAtFinalStop` endpoint has realtime-derived freshness.
    ///
    /// Scheduled guidance therefore cannot carry an observation.
    init?(
        journeyID: JourneyID,
        phase: JourneyPhase,
        freshness: RealtimeFreshness,
        lastConfirmedAt: Date?,
        asOf: Date
    ) {
        if let lastConfirmedAt, lastConfirmedAt > asOf { return nil }
        if let timestamp = freshness.timestamp, timestamp > asOf { return nil }
        if Self.claimsObservation(phase), !freshness.isRealtimeDerived { return nil }

        self.journeyID = journeyID
        self.phase = phase
        self.freshness = freshness
        self.lastConfirmedAt = lastConfirmedAt
        self.asOf = asOf
    }

    /// Whether the phase states something realtime observed.
    private static func claimsObservation(_ phase: JourneyPhase) -> Bool {
        switch phase {
        case .riding(_, let position?): position.basis == .observed
        case .plannedEndReached(.trainObservedAtFinalStop): true
        default: false
        }
    }
}
