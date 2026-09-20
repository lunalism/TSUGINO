// Canonical, TSUGINO-owned identifiers for the railway and journey domain
// (DEC-021, DEC-051, ARCHITECTURE.md §39, RULES.md Rule 9).
//
// Provider identifiers are aliases resolved through the provider mapping layer
// (ARCHITECTURE.md §40). They are deliberately absent here: nothing in this file
// knows that any particular provider exists, which is what lets a provider be
// replaced without touching the domain (DEC-020).
//
// The five identifiers are separate nominal types, so the compiler rejects passing
// a `StationID` where a `LineID` is expected. That mistake is otherwise easy to
// make and impossible to see in review, because every one of them wraps a `String`.
//
// Validity and losslessness are separate concerns (DEC-051). A value must carry at
// least one non-whitespace character to identify anything, so blank values are
// rejected. A value that passes is then stored byte-for-byte: no trimming, no case
// folding, no Unicode normalisation, no separator rewriting. Rejecting blanks does
// not authorise normalising the values that remain.

/// Shared invariant and `Codable` mechanics for the five canonical identifiers.
///
/// It exists only so that the blank-value rule (DEC-051) and the encoded
/// representation are defined once instead of five times. Five hand-written copies
/// could drift apart, and a drifted invariant or encoding would surface far from
/// this file.
///
/// It is **not** a domain-level identifier abstraction. Do not use it as an erased
/// identifier type, as existential storage (`any CanonicalIdentifier`), or as a
/// generic substitute for naming the identifier a value actually is. Those uses
/// would undo the nominal typing this file exists to provide.
nonisolated protocol CanonicalIdentifier: Hashable, Codable, Sendable {
    /// The canonical value, stored exactly as supplied.
    var rawValue: String { get }

    /// Fails when `rawValue` is blank; otherwise preserves it exactly (DEC-051).
    init?(_ rawValue: String)
}

extension CanonicalIdentifier {
    /// Whether a candidate value can identify something.
    ///
    /// Uses the Swift standard library's `Character.isWhitespace`, so the rule holds
    /// for every Unicode whitespace scalar without depending on Foundation.
    ///
    /// Deliberately `fileprivate`: it is the shared implementation of the five
    /// initialisers below (DEC-051), not a reusable blankness API. A caller that
    /// pre-checks a value instead of handling `init?`'s `nil` would duplicate the
    /// invariant where it could drift.
    fileprivate static func isBlank(_ rawValue: String) -> Bool {
        rawValue.allSatisfy(\.isWhitespace)
    }

    /// Decodes from a single string value, applying exactly the same validity rule
    /// as direct construction and preserving a valid value exactly.
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let identifier = Self(rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "A canonical identifier must contain at least one non-whitespace character."
            )
        }

        self = identifier
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

    init?(_ rawValue: String) {
        guard !Self.isBlank(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

/// Canonical identifier for a railway line.
nonisolated struct LineID: CanonicalIdentifier {
    let rawValue: String

    init?(_ rawValue: String) {
        guard !Self.isBlank(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

/// Canonical identifier for an operator.
nonisolated struct OperatorID: CanonicalIdentifier {
    let rawValue: String

    init?(_ rawValue: String) {
        guard !Self.isBlank(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

/// Canonical identifier for a trip — one concrete train service.
nonisolated struct TripID: CanonicalIdentifier {
    let rawValue: String

    init?(_ rawValue: String) {
        guard !Self.isBlank(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

/// Canonical identifier for a journey.
nonisolated struct JourneyID: CanonicalIdentifier {
    let rawValue: String

    init?(_ rawValue: String) {
        guard !Self.isBlank(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}
