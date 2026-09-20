// Rail capability vocabulary and the derived guidance tier (DEC-022, DEC-049,
// DEC-054, ARCHITECTURE.md §51).
//
// Capabilities are declared at the applicable service/feed scope — never as a
// fixed property of an operator, a line, or a provider (Rule 10). Phase 1
// defines the vocabulary and the pure derivation only: it creates no carrier
// and attaches capabilities to nothing. Service/feed-scoped declaration,
// ingestion, and attachment are Phase 4 concerns (DEC-054).
//
// A capability is declared only after the applicable evidence gates have been
// satisfied (DEC-046). Presence in a declared set therefore already means that
// capability passed its gate, which is why no second "verified" flag exists.

/// One atomic capability a rail service or feed may declare.
///
/// `serviceStatus` is deliberately separate from `alerts`: service-status
/// information and alert resources are distinct data concepts, and conflating
/// them would make a service's declared coverage unrepresentable (DEC-054).
///
/// Raw values are stable lowerCamelCase strings so a declared set stays legible
/// and migratable (ARCHITECTURE.md §41). An unrecognised raw value fails to
/// decode; there is no `unknown` case, because no accepted rule asks for one.
nonisolated enum RailCapability: String, Hashable, Codable, Sendable, CaseIterable {
    case staticSchedule
    case tripUpdates
    case vehiclePosition
    case alerts
    case serviceStatus
    case platform
    case recommendedCar
    case recommendedDoor
    case exitGuidance
}

/// The guidance tier derived from a declared capability set (DEC-047, DEC-054).
///
/// The tier says what a service's declared data can honestly support. It makes
/// no claim about live availability at a particular instant: runtime freshness,
/// observed state, and degraded behaviour are separate, later concerns
/// (DEC-024, Rule 12).
nonisolated enum RailCapabilityTier: String, Hashable, Codable, Sendable, CaseIterable {
    /// Trip-level realtime is declared, so actual journey progress may be shown
    /// within the limits of DEC-024 and DEC-038.
    case realtimeJourneyTracking

    /// A timetable is declared without trip-level realtime. Progress is
    /// clock-based and explicitly scheduled; it is never presented as observed.
    case scheduledJourneyGuidance

    /// Not enough declared data for journey guidance.
    case deferredOrUnsupported
}

extension RailCapabilityTier {
    /// Derives the tier from a declared capability set.
    ///
    /// A pure function of the set: operator and provider identity, names,
    /// provenance, and realtime freshness are all excluded by DEC-054, so the
    /// same set always yields the same tier regardless of who declared it.
    ///
    /// `tripUpdates` takes precedence over `staticSchedule`, and
    /// `vehiclePosition` is a supplement that never promotes a tier on its own.
    /// Unusual or incomplete combinations are not rejected — Phase 1 keeps every
    /// combination representable (DEC-054).
    init(declared capabilities: Set<RailCapability>) {
        if capabilities.contains(.tripUpdates) {
            self = .realtimeJourneyTracking
        } else if capabilities.contains(.staticSchedule) {
            self = .scheduledJourneyGuidance
        } else {
            self = .deferredOrUnsupported
        }
    }
}
