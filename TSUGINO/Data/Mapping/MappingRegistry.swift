import Foundation

// The canonical mapping registry (DEC-068 §B): the record that owns canonical
// identity. A random draw only picks an identifier's label; an entity exists
// because this registry holds it. Imports look identities up here and never
// mint again.
//
// Nothing here mints, reads provider files, or decides a grouping, binding,
// or revision (ARCHITECTURE.md §4.1). Every registry written before the
// registry-of-record decision is provisional and stays outside the repository
// (DEC-068 §B6, §F).

/// A canonical entity. It is never deleted: a retired entity stays, with the
/// identifiers that succeed it through an identity migration (DEC-068 §B3, §E4).
nonisolated struct CanonicalEntity: Hashable, Sendable, Codable {
    nonisolated enum Status: Hashable, Sendable {
        case active
        /// `successors` is non-empty, sorted, and names held entities of the
        /// same kind, never the entity itself.
        case retired(successors: [MintedIdentifier])
    }

    let id: MintedIdentifier
    let status: Status

    init(id: MintedIdentifier, status: Status) {
        self.id = id
        if case .retired(let successors) = status {
            self.status = .retired(successors: successors.sorted())
        } else {
            self.status = status
        }
    }

    private enum CodingKeys: String, CodingKey, CaseIterable { case id, state, successors }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(MintedIdentifier.self, forKey: .id)
        let state = try container.decode(String.self, forKey: .state)
        let successors = try container.decodeIfPresent([MintedIdentifier].self, forKey: .successors)
        switch (state, successors) {
        case ("active", nil): self.init(id: id, status: .active)
        case ("retired", let successors?): self.init(id: id, status: .retired(successors: successors))
        default: throw MappingText.corrupted("invalidStatus", container)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        switch status {
        case .active:
            try container.encode("active", forKey: .state)
        case .retired(let successors):
            try container.encode("retired", forKey: .state)
            try container.encode(successors, forKey: .successors)
        }
    }
}

/// A registry-wide rule a registry breaks. Each case names a rule, never a
/// value.
nonisolated enum MappingRegistryError: Error, Hashable, Sendable {
    case unsupportedSchemaVersion
    case negativeRevision
    case repeatedIdentifier
    /// A retired entity with no successor, or one naming itself, an entity the
    /// registry does not hold, an entity of another kind, or a repeat.
    case invalidSuccessors
    /// Following successors leads back to an entity already on the path, so
    /// the migration never reaches a current identity.
    case successorCycle
    /// A JSON object in the registry file repeats a key.
    case repeatedKey
    /// Two records for the same reference, bound to the same identifier.
    case repeatedReference
    /// Two records for the same reference, bound to different identifiers.
    case referenceBoundToTwoIdentifiers
    case referenceToUnknownIdentifier
    /// The namespace identifies a different kind of entity.
    case referenceKindMismatch
    case activeReferenceToRetiredIdentifier
}

/// Encodable only: `decoded(from:)` is the one way to read a registry, so the
/// repeated-key check can never be bypassed through a `Decodable` conformance.
nonisolated struct MappingRegistry: Equatable, Sendable, Encodable {
    /// The only schema this code reads. Any other version is rejected, never
    /// reinterpreted (Rule 39). Version 2 added a reference's attaching review
    /// (`attachedBy`). Version 1 files are rejected rather than migrated: every
    /// registry so far is provisional and may be discarded and regenerated
    /// (DEC-068 §B6); no registry of record exists.
    static let schemaVersion = 2

    let revision: Int
    /// Sorted by identifier.
    let entities: [CanonicalEntity]
    /// Sorted by reference key.
    let references: [ProviderReference]

    private let entityIndex: [MintedIdentifier: Int]
    private let referenceIndex: [ProviderReferenceKey: Int]

    static let empty = try! MappingRegistry(revision: 0, entities: [], references: [])

    init(revision: Int, entities: [CanonicalEntity], references: [ProviderReference]) throws(MappingRegistryError) {
        guard revision >= 0 else { throw .negativeRevision }

        let sortedEntities = entities.sorted { $0.id < $1.id }
        var entityIndex: [MintedIdentifier: Int] = [:]
        for (position, entity) in sortedEntities.enumerated() {
            guard entityIndex.updateValue(position, forKey: entity.id) == nil else { throw .repeatedIdentifier }
        }
        for entity in sortedEntities {
            guard case .retired(let successors) = entity.status else { continue }
            guard !successors.isEmpty, Set(successors).count == successors.count else { throw .invalidSuccessors }
            for successor in successors {
                guard successor != entity.id, successor.kind == entity.id.kind, entityIndex[successor] != nil else {
                    throw .invalidSuccessors
                }
            }
        }

        try Self.rejectSuccessorCycles(sortedEntities, entityIndex)

        let sortedReferences = references.sorted { $0.key < $1.key }
        var referenceIndex: [ProviderReferenceKey: Int] = [:]
        for (position, reference) in sortedReferences.enumerated() {
            if let earlier = referenceIndex.updateValue(position, forKey: reference.key) {
                throw sortedReferences[earlier].canonicalID == reference.canonicalID
                    ? .repeatedReference : .referenceBoundToTwoIdentifiers
            }
            guard let entityPosition = entityIndex[reference.canonicalID] else { throw .referenceToUnknownIdentifier }
            guard reference.namespace.kind == reference.canonicalID.kind else { throw .referenceKindMismatch }
            if reference.status == .active, sortedEntities[entityPosition].status != .active {
                throw .activeReferenceToRetiredIdentifier
            }
        }

        self.revision = revision
        self.entities = sortedEntities
        self.references = sortedReferences
        self.entityIndex = entityIndex
        self.referenceIndex = referenceIndex
    }

    /// Depth-first over the successor graph, iteratively: a path that returns
    /// to an entity still on it is a cycle.
    private static func rejectSuccessorCycles(
        _ entities: [CanonicalEntity],
        _ index: [MintedIdentifier: Int]
    ) throws(MappingRegistryError) {
        func successors(_ position: Int) -> [Int] {
            guard case .retired(let ids) = entities[position].status else { return [] }
            return ids.compactMap { index[$0] }
        }
        // 0: not visited, 1: on the current path, 2: finished.
        var state = [UInt8](repeating: 0, count: entities.count)
        for start in entities.indices where state[start] == 0 {
            var stack: [(position: Int, next: Int)] = [(start, 0)]
            state[start] = 1
            while let top = stack.last {
                let children = successors(top.position)
                if top.next < children.count {
                    stack[stack.count - 1].next += 1
                    let child = children[top.next]
                    if state[child] == 1 { throw .successorCycle }
                    if state[child] == 0 {
                        state[child] = 1
                        stack.append((child, 0))
                    }
                } else {
                    state[top.position] = 2
                    stack.removeLast()
                }
            }
        }
    }

    /// Every identifier the registry has ever held: entities are never deleted.
    var heldIdentifiers: [MintedIdentifier] { entities.map(\.id) }

    func entity(_ id: MintedIdentifier) -> CanonicalEntity? {
        entityIndex[id].map { entities[$0] }
    }

    /// The record for a reference, whatever its status.
    func reference(for key: ProviderReferenceKey) -> ProviderReference? {
        referenceIndex[key].map { references[$0] }
    }

    /// The identifier a reference resolves to. Only an active reference
    /// resolves (DEC-068 §E1).
    func resolve(_ key: ProviderReferenceKey) -> MintedIdentifier? {
        guard let reference = reference(for: key), reference.status == .active else { return nil }
        return reference.canonicalID
    }

    /// Deterministic JSON: sorted keys, sorted records, no escaped slashes. The
    /// same registry always gives the same bytes.
    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    /// The only way to read a registry file. The platform decoder keeps one
    /// value of a repeated key without saying so, which could silently rebind
    /// a reference, so repeated keys are rejected here first.
    static func decoded(from data: Data) throws -> MappingRegistry {
        guard !RegistryJSON.repeatsKey([UInt8](data)) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "\(MappingRegistryError.repeatedKey)"))
        }
        return try JSONDecoder().decode(RegistryFile.self, from: data).registry
    }

    // MARK: - Codable

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable { case schemaVersion, revision, entities, references }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.schemaVersion, forKey: .schemaVersion)
        try container.encode(revision, forKey: .revision)
        try container.encode(entities, forKey: .entities)
        try container.encode(references, forKey: .references)
    }

    static func == (lhs: MappingRegistry, rhs: MappingRegistry) -> Bool {
        lhs.revision == rhs.revision && lhs.entities == rhs.entities && lhs.references == rhs.references
    }
}

/// Decodes the registry file, for `MappingRegistry.decoded(from:)` only.
private nonisolated struct RegistryFile: Decodable {
    let registry: MappingRegistry

    init(from decoder: any Decoder) throws {
        typealias Keys = MappingRegistry.CodingKeys
        try MappingText.rejectUnknownKeys(decoder, Keys.self)
        let container = try decoder.container(keyedBy: Keys.self)
        // The version is checked before anything else is read, so a future
        // schema is never partly interpreted.
        guard try container.decode(Int.self, forKey: .schemaVersion) == MappingRegistry.schemaVersion else {
            throw MappingText.corrupted("\(MappingRegistryError.unsupportedSchemaVersion)", container)
        }
        do {
            registry = try MappingRegistry(
                revision: container.decode(Int.self, forKey: .revision),
                entities: container.decode([CanonicalEntity].self, forKey: .entities),
                references: container.decode([ProviderReference].self, forKey: .references)
            )
        } catch let error as MappingRegistryError {
            throw MappingText.corrupted("\(error)", container)
        }
    }
}

/// Finds a repeated key in any JSON object. Only strings and structure are
/// tracked; the grammar is left to the decoder that runs next. Keys are
/// compared by their decoded Unicode scalars, so an escaped spelling of the
/// same key is a repeat. Also used by the offline tool for reviewed-record
/// files.
nonisolated enum RegistryJSON {
    static func repeatsKey(_ bytes: [UInt8]) -> Bool {
        // For each open container: whether it is an object, its keys so far,
        // and whether the next string is a key.
        var stack: [(isObject: Bool, keys: Set<[UInt32]>, expectsKey: Bool)] = []
        var index = 0
        while index < bytes.count {
            switch bytes[index] {
            case UInt8(ascii: "{"):
                stack.append((true, [], true))
                index += 1
            case UInt8(ascii: "["):
                stack.append((false, [], false))
                index += 1
            case UInt8(ascii: "}"), UInt8(ascii: "]"):
                if !stack.isEmpty { stack.removeLast() }
                index += 1
            case UInt8(ascii: ","):
                if let top = stack.last, top.isObject { stack[stack.count - 1].expectsKey = true }
                index += 1
            case UInt8(ascii: "\""):
                var end = index + 1
                while end < bytes.count, bytes[end] != UInt8(ascii: "\"") {
                    end += bytes[end] == UInt8(ascii: "\\") ? 2 : 1
                }
                end = min(end + 1, bytes.count)
                if let top = stack.last, top.isObject, top.expectsKey {
                    let literal = Data(bytes[index..<end])
                    let key = (try? JSONSerialization.jsonObject(with: literal, options: [.fragmentsAllowed])) as? String
                    let scalars = key.map { $0.unicodeScalars.map(\.value) } ?? literal.map(UInt32.init)
                    guard stack[stack.count - 1].keys.insert(scalars).inserted else { return true }
                    stack[stack.count - 1].expectsKey = false
                }
                index = end
            default:
                index += 1
            }
        }
        return false
    }
}
