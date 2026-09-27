import Foundation

// The DEC-068 §A minted-identifier form, checked here and nowhere in Domain.
//
// Domain identifiers keep DEC-051's rule: any value with a non-whitespace
// character, preserved exactly. This file adds no Domain rule. It only
// recognises the form the registry mints and holds: a kind prefix, an
// underscore, and 16 lowercase Crockford base32 characters — 20 ASCII
// characters in all. Minting itself happens only in the offline tool
// (ARCHITECTURE.md §4.1, §39); the app never mints.

/// The entity kinds DEC-068 §A1 mints for, with their identifier prefixes.
nonisolated enum CanonicalKind: String, CaseIterable, Hashable, Sendable {
    case station = "stn"
    case line = "lin"
    case railwayOperator = "opr"
}

/// A canonical identifier in the DEC-068 §A form. It is an opaque label: its
/// characters mean nothing beyond the kind prefix, and it is compared as an
/// exact string.
nonisolated struct MintedIdentifier: Hashable, Comparable, Sendable, Codable {
    /// Lowercase Crockford base32, without `i`, `l`, `o`, or `u`.
    static let alphabet: [UInt8] = Array("0123456789abcdefghjkmnpqrstvwxyz".utf8)
    static let bodyLength = 16
    static let length = 20

    let rawValue: String
    let kind: CanonicalKind

    /// Fails unless `rawValue` is exactly the DEC-068 §A form. There is no
    /// leniency: uppercase, substitute letters, separators, and any other
    /// length are rejected, never mapped.
    init?(_ rawValue: String) {
        let bytes = Array(rawValue.utf8)
        guard bytes.count == Self.length,
              bytes[3] == UInt8(ascii: "_"),
              let kind = CanonicalKind(rawValue: String(decoding: bytes[0..<3], as: UTF8.self)),
              bytes[4...].allSatisfy(Self.alphabet.contains)
        else { return nil }
        self.rawValue = rawValue
        self.kind = kind
    }

    /// The 16 characters after the underscore.
    var body: String {
        String(decoding: rawValue.utf8.dropFirst(4), as: UTF8.self)
    }

    /// Byte order, so sorting never depends on locale or Unicode collation.
    static func < (lhs: MintedIdentifier, rhs: MintedIdentifier) -> Bool {
        lhs.rawValue.utf8.lexicographicallyPrecedes(rhs.rawValue.utf8)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let identifier = MintedIdentifier(try container.decode(String.self)) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "malformedIdentifier")
        }
        self = identifier
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
