// Typed errors of the `odpt:Railway` reader (DEC-067 §G).
//
// The reader contract is based on the retained audit's observed shape, not
// on the ODPT specification, which has not been verified. So only input that
// is not UTF-8 text in the RFC 8259 JSON grammar is `invalid`; any other
// departure is `unsupported`,
// meaning the reader does not handle that shape — never that the provider's
// data is wrong. Errors carry a record index and a field name only: no
// provider value ever appears in an error.

/// Where a shape problem was found. `recordIndex` is 0-based into the
/// top-level array and is `nil` for a problem with the array itself. `field`
/// names the JSON field, and a station-order entry is named with its
/// 0-based position, such as `odpt:stationOrder[2].odpt:index`.
nonisolated struct ODPTRailwayLocation: Hashable, Sendable {
    let recordIndex: Int?
    let field: String?
}

nonisolated enum ODPTRailwayReadError: Error, Hashable, Sendable {
    case invalid(ODPTRailwayInvalidInput)
    case unsupported(ODPTRailwayUnsupportedInput, at: ODPTRailwayLocation)
}

nonisolated enum ODPTRailwayInvalidInput: Hashable, Sendable {
    case invalidUTF8
    case malformedJSON
}

nonisolated enum ODPTRailwayUnsupportedInput: Hashable, Sendable {
    case topLevelNotArray
    case recordNotObject
    /// `@type` is not the string `odpt:Railway`.
    case unexpectedType
    case missingField
    case wrongFieldType
    /// A language map has a value that is not a string.
    case titleValueNotString
    /// Station-order indices, in source order, are not exactly 1, 2, …, n.
    case stationOrderIndicesNotContiguous
    /// A second record repeats an earlier record's `@id`, `owl:sameAs`, or
    /// line code.
    case duplicateValue
    /// A record's operator differs from the first record's.
    case mixedOperators
    /// A JSON object repeats a key. RFC 8259 permits this but leaves the
    /// meaning undefined, and the parser would keep only one value, so the
    /// provider's values could not be preserved as stated. `field` names the
    /// repeated key only when it is one of the reader's field names, or a
    /// language tag inside a title map; any other key is not named, since it
    /// is provider text.
    case duplicateKey
    /// Well-formed JSON that the platform parser cannot read — nesting beyond
    /// its depth limit, a number outside its range, or a lone-surrogate
    /// escape. RFC 8259 lets parsers set such limits (§8.2, §9).
    case platformParserLimit
}
