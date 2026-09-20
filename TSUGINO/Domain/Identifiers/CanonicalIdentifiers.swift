/// Canonical, TSUGINO-owned identifiers for the railway and journey domain
/// (DEC-021, ARCHITECTURE.md §39, RULES.md Rule 9).
///
/// Provider identifiers — ODPT IDs, GTFS `stop_id`, route-provider station codes —
/// are **aliases** resolved through the provider mapping layer (ARCHITECTURE.md §40).
/// They are deliberately absent here: nothing in this file knows that any particular
/// provider exists, which is what lets a provider be replaced without touching the
/// domain (DEC-020).
///
/// The five identifiers are separate nominal types, so the compiler rejects passing a
/// `StationID` where a `LineID` is expected. That mistake is otherwise easy to make and
/// impossible to see in review, because every one of them wraps a `String`.
///
/// **Raw representation.** No accepted document specifies a raw-value type, a character
/// set, or any normalisation, trimming, or case-folding rule for canonical identifiers.
/// These wrappers are therefore deliberately **lossless**: the value handed in is the
/// value stored and the value returned. Inventing validation here would be an
/// undocumented architecture decision, and a canonicalisation rule adopted later would
/// silently change the meaning of already-persisted identifiers.

/// Shared shape for the canonical identifiers below.
///
/// It exists for one reason: to guarantee that every canonical identifier encodes as a
/// bare string rather than as a keyed object. Five hand-written `Codable`
/// implementations could drift apart, and a drifted encoding would only surface as a
/// persistence migration problem long after Phase 1 (ARCHITECTURE.md §41).
///
/// This is an internal implementation detail, not a provider abstraction, and it does
/// not weaken nominal typing: conforming types remain mutually unassignable.
nonisolated protocol CanonicalIdentifier: Hashable, Codable, Sendable {
    /// The canonical value, stored exactly as supplied.
    var rawValue: String { get }

    init(_ rawValue: String)
}

extension CanonicalIdentifier {
    /// Decodes from a single string value, preserving it exactly.
    init(from decoder: any Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes as a single string value, preserving it exactly.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Canonical identifier for a station.
nonisolated struct StationID: CanonicalIdentifier {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Canonical identifier for a railway line.
nonisolated struct LineID: CanonicalIdentifier {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Canonical identifier for an operator.
nonisolated struct OperatorID: CanonicalIdentifier {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Canonical identifier for a trip — one concrete train service.
nonisolated struct TripID: CanonicalIdentifier {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Canonical identifier for a journey.
nonisolated struct JourneyID: CanonicalIdentifier {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
