// Canonical three-language name shared by the railway models (DEC-053,
// ARCHITECTURE.md §39.1). `Operator` uses it now; `Station` and `RailwayLine`
// use the same value in S3.
//
// Provider-supplied names are normalisation inputs, not the canonical source
// (Rule 26, DEC-041, DEC-042). Nothing here performs locale lookup or
// device-language selection: resolution is a read-time concern that never
// mutates what is stored.
//
// Validity and losslessness are separate concerns, exactly as for canonical
// identifiers (DEC-051). A name must carry at least one non-whitespace
// character to name anything, so blank names are rejected. A name that passes
// is stored byte-for-byte: no trimming, no case folding, no Unicode
// normalisation.

/// The canonical Japanese, English, and Korean names of a railway entity.
///
/// All three are required. A missing canonical Korean name is supplied from
/// TSUGINO's canonical dataset rather than stored as a blank string (DEC-053);
/// this type has no representation for "absent".
nonisolated struct LocalizedRailName: Hashable, Codable, Sendable {
    let japanese: String
    let english: String
    let korean: String

    /// Fails when any one of the three names is blank; otherwise preserves all
    /// three exactly. The three values may be identical — some names are written
    /// the same way in more than one language.
    init?(japanese: String, english: String, korean: String) {
        guard
            !Self.isBlank(japanese),
            !Self.isBlank(english),
            !Self.isBlank(korean)
        else { return nil }

        self.japanese = japanese
        self.english = english
        self.korean = korean
    }

    /// Whether a candidate name can name anything.
    ///
    /// Uses the Swift standard library's `Character.isWhitespace`, so the rule
    /// covers every Unicode whitespace scalar without depending on Foundation.
    static func isBlank(_ name: String) -> Bool {
        name.allSatisfy(\.isWhitespace)
    }
}

extension LocalizedRailName {
    private enum CodingKeys: String, CodingKey {
        case japanese, english, korean
    }

    /// Decodes with exactly the same validity rule as direct construction, so a
    /// decoded value can never be one `init` would have rejected.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let name = Self(
            japanese: try container.decode(String.self, forKey: .japanese),
            english: try container.decode(String.self, forKey: .english),
            korean: try container.decode(String.self, forKey: .korean)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Each canonical name must contain at least one non-whitespace character."
                )
            )
        }

        self = name
    }
}
