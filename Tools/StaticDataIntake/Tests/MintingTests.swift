import Foundation

// DEC-068 §A and §B cases for the tool-only minter and assigner. Every record
// and identifier here is invented: sources are `SYN-…`, provider values
// `syn-…`, and digests repeat one hexadecimal digit. No identifier minted
// here is a production identifier.

/// A generator that returns scripted 64-bit values and counts its draws.
struct ScriptedGenerator: RandomNumberGenerator {
    var values: [UInt64]
    var draws = 0

    mutating func next() -> UInt64 {
        precondition(draws < values.count, "the script ran out of values")
        defer { draws += 1 }
        return values[draws]
    }
}

/// A seeded SplitMix64 generator: deterministic, for tests only.
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

enum SyntheticMapping {
    static let digestA = String(repeating: "a", count: 64)
    static let digestB = String(repeating: "b", count: 64)

    /// The identifier a scripted pair of draws produces.
    static func identifier(_ kind: CanonicalKind, draw index: UInt64) -> MintedIdentifier {
        var generator = ScriptedGenerator(values: pair(index))
        return IdentifierMinter.identifier(kind, from: bits(&generator))
    }

    /// Two 64-bit values that give a body unique to `index`.
    static func pair(_ index: UInt64) -> [UInt64] {
        [0x0123_4567_89AB_CDEF &+ index &* 0x1_0000_0001, index << 48]
    }

    static func script(_ indices: [UInt64]) -> ScriptedGenerator {
        ScriptedGenerator(values: indices.flatMap(pair))
    }

    private static func bits(_ generator: inout ScriptedGenerator) -> [UInt8] {
        let high = generator.next()
        let low = generator.next()
        return (0..<8).map { UInt8(truncatingIfNeeded: high >> (56 - 8 * $0)) }
            + [UInt8(truncatingIfNeeded: low >> 56), UInt8(truncatingIfNeeded: low >> 48)]
    }

    static func key(_ value: String, _ namespace: ProviderNamespace = .gtfsRouteID) -> ProviderReferenceKey {
        ProviderReferenceKey(sourceID: "SYN-01/synthetic-gtfs", namespace: namespace, value: ExactValue(value)!)
    }

    static func reference(_ id: MintedIdentifier, _ value: String, status: ProviderReferenceStatus = .active) throws -> ProviderReference {
        let key = key(value)
        return try ProviderReference(
            canonicalID: id,
            sourceID: key.sourceID,
            namespace: key.namespace,
            value: key.value,
            status: status,
            firstSeenInputSHA256: digestA,
            provenance: SourceReference(
                inputSHA256: digestB,
                member: .init(name: "routes.txt", sha256: digestA),
                table: "routes",
                recordIndex: nil,
                field: "route_id",
                providerKey: key.value
            ),
            originalNames: []
        )
    }
}

func mintExpecting(_ kind: CanonicalKind, _ registry: MappingRegistry, _ generator: inout ScriptedGenerator) -> Result<MintedIdentifier, IdentifierMintingError> {
    do {
        return .success(try IdentifierMinter.mint(kind, for: registry, using: &generator))
    } catch {
        return .failure(error)
    }
}

let mintingTests: [TestCase] = [
    ("the system generator mints the exact DEC-068 form for every kind", { _ in
        for kind in CanonicalKind.allCases {
            var seen = Set<MintedIdentifier>()
            for _ in 0..<200 {
                let id = try IdentifierMinter.mint(kind, for: .empty)
                try check(id.kind == kind && id.rawValue.utf8.count == 20, "form of \(id.rawValue)")
                try check(id.rawValue.hasPrefix(kind.rawValue + "_"), "prefix of \(id.rawValue)")
                try check(MintedIdentifier(id.rawValue) == id, "round trip of \(id.rawValue)")
                seen.insert(id)
            }
            try check(seen.count == 200, "repeated identifiers from the system generator")
        }
    }),
    ("80 bits are written as 16 base32 groups, most significant first", { _ in
        let zeros = IdentifierMinter.identifier(.line, from: Array(repeating: 0, count: 10))
        try check(zeros.rawValue == "lin_0000000000000000", zeros.rawValue)
        let ones = IdentifierMinter.identifier(.station, from: Array(repeating: 0xFF, count: 10))
        try check(ones.rawValue == "stn_zzzzzzzzzzzzzzzz", ones.rawValue)
        // 0x08 0x42 0x10 … puts the value 1 in every five-bit group.
        let pattern: [UInt8] = [0x08, 0x42, 0x10, 0x84, 0x21, 0x08, 0x42, 0x10, 0x84, 0x21]
        let unit = IdentifierMinter.identifier(.railwayOperator, from: pattern)
        try check(unit.rawValue == "opr_1111111111111111", unit.rawValue)
    }),
    ("minting takes no provider value: the same input under two generators gives different identifiers", { _ in
        var first = SeededGenerator(state: 1)
        var second = SeededGenerator(state: 2)
        let key = SyntheticMapping.key("syn-route-q")
        guard case .minted(let a) = try IdentifierAssigner.assign(key, in: .empty, mintIfNew: true, using: &first),
              case .minted(let b) = try IdentifierAssigner.assign(key, in: .empty, mintIfNew: true, using: &second)
        else { throw TestFailure(message: "expected two mints") }
        try check(a != b, "identifiers followed the provider value")
        var replay = SeededGenerator(state: 1)
        try check(try IdentifierMinter.mint(.line, for: .empty, using: &replay) == a, "a seeded generator is not deterministic")
    }),
    ("a collision with an active or retired identifier of any kind is redrawn", { _ in
        let heldActive = SyntheticMapping.identifier(.line, draw: 0)
        let heldRetired = SyntheticMapping.identifier(.line, draw: 1)
        let otherKind = SyntheticMapping.identifier(.station, draw: 2)
        let successor = SyntheticMapping.identifier(.line, draw: 9)
        let registry = try MappingRegistry(revision: 1, entities: [
            CanonicalEntity(id: heldActive, status: .active),
            CanonicalEntity(id: heldRetired, status: .retired(successors: [successor])),
            CanonicalEntity(id: otherKind, status: .active),
            CanonicalEntity(id: successor, status: .active),
        ], references: [])
        var generator = SyntheticMapping.script([0, 1, 2, 3])
        let result = mintExpecting(.line, registry, &generator)
        try check(result == .success(SyntheticMapping.identifier(.line, draw: 3)), "\(result)")
        try check(generator.draws == 8, "expected 4 draws of two values, got \(generator.draws) values")
    }),
    ("seven collisions still mint on the eighth draw; eight fail without minting", { _ in
        let held = (0..<8).map { UInt64($0) }.map { SyntheticMapping.identifier(.station, draw: $0) }
        let registry = try MappingRegistry(revision: 1, entities: held.map { CanonicalEntity(id: $0, status: .active) }, references: [])
        try check(registry.heldIdentifiers.count == 8, "held")

        var sevenThenFree = SyntheticMapping.script([0, 1, 2, 3, 4, 5, 6, 100])
        let seventh = mintExpecting(.station, try MappingRegistry(revision: 1, entities: Array(held.prefix(7)).map { CanonicalEntity(id: $0, status: .active) }, references: []), &sevenThenFree)
        try check(seventh == .success(SyntheticMapping.identifier(.station, draw: 100)), "\(seventh)")

        var allHeld = SyntheticMapping.script([0, 1, 2, 3, 4, 5, 6, 7, 100])
        let eighth = mintExpecting(.station, registry, &allHeld)
        try check(eighth == .failure(.consecutiveCollisions), "\(eighth)")
        try check(allHeld.draws == 16, "the minter drew past its limit: \(allHeld.draws) values")
        try check(IdentifierMinter.maximumDraws == 8, "limit")
    }),
    ("re-importing a held reference reuses its identifier and draws nothing", { _ in
        let line = SyntheticMapping.identifier(.line, draw: 0)
        let absentLine = SyntheticMapping.identifier(.line, draw: 1)
        let registry = try MappingRegistry(revision: 3, entities: [
            CanonicalEntity(id: line, status: .active), CanonicalEntity(id: absentLine, status: .active),
        ], references: [
            SyntheticMapping.reference(line, "syn-route-q"),
            SyntheticMapping.reference(absentLine, "syn-route-r", status: .absent),
        ])
        var generator = ScriptedGenerator(values: [])
        let active = try IdentifierAssigner.assign(SyntheticMapping.key("syn-route-q"), in: registry, mintIfNew: true, using: &generator)
        let absent = try IdentifierAssigner.assign(SyntheticMapping.key("syn-route-r"), in: registry, mintIfNew: true, using: &generator)
        try check(active == .existing(line) && absent == .existing(absentLine), "\(active), \(absent)")
        try check(generator.draws == 0, "a held reference was re-minted")
    }),
    ("a new reference is reported, and minted only when explicitly requested", { _ in
        var generator = SyntheticMapping.script([5])
        let key = SyntheticMapping.key("syn-route-new")
        try check(try IdentifierAssigner.assign(key, in: .empty, mintIfNew: false, using: &generator) == .unassigned, "minted without a request")
        try check(generator.draws == 0, "drew without a request")
        let minted = try IdentifierAssigner.assign(key, in: .empty, mintIfNew: true, using: &generator)
        try check(minted == .minted(SyntheticMapping.identifier(.line, draw: 5)), "\(minted)")
    }),
    ("a retired reference is never reassigned", { _ in
        let old = SyntheticMapping.identifier(.line, draw: 0)
        let successor = SyntheticMapping.identifier(.line, draw: 1)
        let registry = try MappingRegistry(revision: 2, entities: [
            CanonicalEntity(id: old, status: .retired(successors: [successor])), CanonicalEntity(id: successor, status: .active),
        ], references: [SyntheticMapping.reference(old, "syn-route-q", status: .retired(review: "SYN-REVIEW-1"))])
        var generator = ScriptedGenerator(values: [])
        do {
            _ = try IdentifierAssigner.assign(SyntheticMapping.key("syn-route-q"), in: registry, mintIfNew: true, using: &generator)
            throw TestFailure(message: "a retired reference was assigned")
        } catch let error as IdentifierAssignmentError {
            try check(error == .retiredReference && generator.draws == 0, "\(error)")
        }
    }),
]
