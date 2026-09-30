import Foundation

// The two accepted station alias rules (DEC-048, DEC-068 §C5, DEC-069 §B).
//
// Each rule is an explicit, named record used only as a comparison key: it
// derives a key from a value and never rewrites the value. A match keeps both
// original values exactly as decoded, each with its source reference, so the
// relation can always be traced back and undone. Only these two rules exist;
// adding or extending one needs a new accepted decision (DEC-069 §B2).
//
// Applying the rules to real inputs, and forming candidates from them, is
// tool-only (ARCHITECTURE.md §4.1).

/// A provider-orthography or presentation alias rule.
nonisolated enum StationAliasRule: String, Codable, CaseIterable, Hashable, Comparable, Sendable {
    /// ヶ (U+30F6, small) and ケ (U+30B1, full-size) compare as one character.
    /// No other character is folded: not ヵ, not a half-width form, and no
    /// Unicode normalization.
    case orthographicKe
    /// A trailing bracketed subtitle 〈…〉 (U+3008 … U+3009) is left out of the
    /// comparison. It applies only when the subtitle ends the value, has
    /// content, contains no further bracket, and leaves a non-blank base.
    case subtitleBracket

    static func < (lhs: StationAliasRule, rhs: StationAliasRule) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

    /// The comparison key: the value itself when the rule changes nothing.
    /// The value is never modified; the key is a separate, derived value.
    func comparisonKey(_ value: ExactValue) -> ExactValue {
        switch self {
        case .orthographicKe:
            var scalars = String.UnicodeScalarView()
            for scalar in value.text.unicodeScalars {
                scalars.append(scalar.value == 0x30F6 ? Unicode.Scalar(0x30B1)! : scalar)
            }
            return ExactValue(String(scalars)) ?? value
        case .subtitleBracket:
            let codes: [UInt32] = value.text.unicodeScalars.map(\.value)
            let close = codes.count - 1
            guard close >= 0, codes[close] == 0x3009 else { return value }
            guard let open = codes.lastIndex(of: 0x3008) else { return value }
            // A non-empty base before the bracket, and content inside it.
            guard open > 0, open + 1 < close else { return value }
            let content = codes[(open + 1)..<close]
            guard !content.contains(0x3008), !content.contains(0x3009) else { return value }
            var base = String.UnicodeScalarView()
            base.append(contentsOf: value.text.unicodeScalars.prefix(open))
            return ExactValue(String(base)) ?? value
        }
    }

    /// Whether the rule relates two values: they differ exactly, and their
    /// comparison keys are equal. Equal values need no alias.
    func relates(_ lhs: ExactValue, _ rhs: ExactValue) -> Bool {
        lhs != rhs && comparisonKey(lhs) == comparisonKey(rhs)
    }
}

/// One application of an alias rule to two original values. It holds both
/// originals and their sources, so the relation is reversible: nothing is
/// rewritten, and the key is derived, never stored in place of a value.
nonisolated struct StationAliasMatch: Hashable, Sendable {
    let rule: StationAliasRule
    /// Ordered by value (UTF-8), so a match is the same whichever side came first.
    let first: OriginalName
    let second: OriginalName

    enum Invalid: Error, Hashable, Sendable {
        /// The rule does not relate the two values.
        case notRelated
    }

    init(rule: StationAliasRule, _ lhs: OriginalName, _ rhs: OriginalName) throws(Invalid) {
        guard rule.relates(lhs.value, rhs.value) else { throw .notRelated }
        self.rule = rule
        if lhs.value < rhs.value {
            (first, second) = (lhs, rhs)
        } else {
            (first, second) = (rhs, lhs)
        }
    }

    /// The shared comparison key.
    var comparisonKey: ExactValue { rule.comparisonKey(first.value) }

    /// The originals, exactly as decoded, with their sources.
    var originals: [OriginalName] { [first, second] }
}
