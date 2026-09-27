import Foundation

// Canonical identifier minting (DEC-068 §A, §B) — in this offline tool only;
// the app never mints (ARCHITECTURE.md §4.1, §39).
//
// A mint draws 80 bits from the system's cryptographically secure generator
// and writes them in the DEC-068 §A form. It takes only the kind and the
// registry, so an identifier can never encode provider data. The operator's
// build draws only from `SystemRandomNumberGenerator`; the entry points that
// accept another generator exist only in the test runner's build
// (`-D INTAKE_TESTING`), as DEC-066's test hooks do.
//
// Every identifier minted before the registry-of-record decision is
// provisional, never a production identifier (DEC-068 §B6, §F).

enum IdentifierMintingError: Error, Equatable {
    /// Every one of `IdentifierMinter.maximumDraws` consecutive draws collided,
    /// which points to a broken random source, not to chance.
    case consecutiveCollisions
}

enum IdentifierMinter {
    /// A run fails after this many consecutive collisions (DEC-068 §A5).
    static let maximumDraws = 8

    /// Mints one identifier of `kind` that `registry` has never held.
    static func mint(_ kind: CanonicalKind, for registry: MappingRegistry) throws(IdentifierMintingError) -> MintedIdentifier {
        var generator = SystemRandomNumberGenerator()
        return try draw(kind, registry, &generator)
    }

    #if INTAKE_TESTING
    /// The test runner's entry point, with an injected generator.
    static func mint<Generator: RandomNumberGenerator>(
        _ kind: CanonicalKind,
        for registry: MappingRegistry,
        using generator: inout Generator
    ) throws(IdentifierMintingError) -> MintedIdentifier {
        try draw(kind, registry, &generator)
    }
    #endif

    /// A candidate collides when its body equals the body of any identifier
    /// the registry has ever held, of any kind, active or retired. Comparing
    /// bodies rather than whole identifiers is the stricter check: it also
    /// keeps a body from being reused under another kind.
    fileprivate static func draw<Generator: RandomNumberGenerator>(
        _ kind: CanonicalKind,
        _ registry: MappingRegistry,
        _ generator: inout Generator
    ) throws(IdentifierMintingError) -> MintedIdentifier {
        let heldBodies = Set(registry.heldIdentifiers.map(\.body))
        for _ in 0..<maximumDraws {
            let candidate = identifier(kind, from: randomBits(&generator))
            if !heldBodies.contains(candidate.body) { return candidate }
        }
        throw .consecutiveCollisions
    }

    /// Ten bytes (80 bits) from two 64-bit draws: all of the first, and the two
    /// most significant bytes of the second.
    private static func randomBits<Generator: RandomNumberGenerator>(_ generator: inout Generator) -> [UInt8] {
        let high = generator.next()
        let low = generator.next()
        return (0..<8).map { UInt8(truncatingIfNeeded: high >> (56 - 8 * $0)) }
            + [UInt8(truncatingIfNeeded: low >> 56), UInt8(truncatingIfNeeded: low >> 48)]
    }

    /// Writes 80 bits as 16 five-bit groups, most significant first, in the
    /// DEC-068 §A alphabet, after the kind prefix and an underscore.
    static func identifier(_ kind: CanonicalKind, from bits: [UInt8]) -> MintedIdentifier {
        precondition(bits.count == 10, "an identifier body is exactly 80 bits")
        var body: [UInt8] = []
        var buffer: UInt32 = 0
        var buffered = 0
        for byte in bits {
            buffer = (buffer << 8) | UInt32(byte)
            buffered += 8
            while buffered >= 5 {
                buffered -= 5
                body.append(MintedIdentifier.alphabet[Int((buffer >> UInt32(buffered)) & 0x1F)])
            }
        }
        // 16 groups of 5 bits use the 80 bits exactly, so the form is always
        // valid; a failure here is a programming error, never input.
        return MintedIdentifier(kind.rawValue + "_" + String(decoding: body, as: UTF8.self))!
    }
}

/// What an import does with one provider reference (DEC-068 §B1, §B2).
enum IdentifierAssignment: Equatable {
    /// The registry already holds the reference: its identifier is reused and
    /// nothing is drawn. This includes an absent reference; moving it back to
    /// active is revision reconciliation, a later P2-S4 step.
    case existing(MintedIdentifier)
    /// The reference was new, and a mint was explicitly requested.
    case minted(MintedIdentifier)
    /// The reference was new, and no mint was requested: it is reported, never
    /// minted automatically.
    case unassigned
}

enum IdentifierAssignmentError: Error, Equatable {
    /// A retired reference never resolves again (DEC-068 §E1). Its reappearance
    /// is for reconciliation to report as a conflict.
    case retiredReference
    case minting(IdentifierMintingError)
}

enum IdentifierAssigner {
    static func assign(
        _ key: ProviderReferenceKey,
        in registry: MappingRegistry,
        mintIfNew: Bool
    ) throws(IdentifierAssignmentError) -> IdentifierAssignment {
        var generator = SystemRandomNumberGenerator()
        return try assign(key, registry, mintIfNew, &generator)
    }

    #if INTAKE_TESTING
    /// The test runner's entry point, with an injected generator.
    static func assign<Generator: RandomNumberGenerator>(
        _ key: ProviderReferenceKey,
        in registry: MappingRegistry,
        mintIfNew: Bool,
        using generator: inout Generator
    ) throws(IdentifierAssignmentError) -> IdentifierAssignment {
        try assign(key, registry, mintIfNew, &generator)
    }
    #endif

    private static func assign<Generator: RandomNumberGenerator>(
        _ key: ProviderReferenceKey,
        _ registry: MappingRegistry,
        _ mintIfNew: Bool,
        _ generator: inout Generator
    ) throws(IdentifierAssignmentError) -> IdentifierAssignment {
        if let reference = registry.reference(for: key) {
            if case .retired = reference.status { throw .retiredReference }
            return .existing(reference.canonicalID)
        }
        guard mintIfNew else { return .unassigned }
        do {
            return .minted(try IdentifierMinter.draw(key.namespace.kind, registry, &generator))
        } catch {
            throw .minting(error)
        }
    }
}
