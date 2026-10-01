import Foundation
import Darwin

// DEC-073: offline review evidence only. None of these records enter the app.
nonisolated enum IdentityTransition {
    static let maxBytes = 16 * 1024 * 1024
    static let maxBoundaries = 128
    enum Failure: Error, Equatable { case malformed, stale, approval, disposition, delta, history, resourceLimit, publication }
    enum Operation: String, Codable, Sendable { case retire, replace, merge, split }
    struct Scope: Codable, Equatable, Sendable {
        let schema: Int
        let revision: Int
        let sha256: String
        init(_ bytes: Data) throws {
            let r = try registry(bytes)
            schema = r.formatVersion; revision = r.revision; sha256 = RailwayArtifact.digest(bytes)
        }
    }
    struct Evidence: Codable, Equatable, Sendable {
        enum Capture: String, Codable, Sendable { case raw, extract, synthetic }
        let source: ExactValue
        let capture: Capture
        let bytes: Data
        let sha256: String
        let locator: ExactValue
        let offset: Int
        let quotation: Data
        let members: [MintedIdentifier]
        // Reviewer identifies non-name support, not an inferred join by this tool.
        let nonNameSupport: ExactValue
    }
    struct Predecessor: Codable, Equatable, Sendable {
        let registrySHA256: String
        let recordSHA256: String
        let bindingVersionID: String?
    }
    struct Disposition: Codable, Equatable, Sendable {
        enum Action: String, Codable, Sendable { case retainHistorical, transfer }
        let id: String
        let action: Action
        let before: ProviderReference
        let after: ProviderReference
        let afterSHA256: String
        let predecessor: Predecessor
        // For transfer, this ID is also the new immutable bindingVersionID.
        let reviewAuthority: String
    }
    struct Payload: Codable, Equatable, Sendable {
        let schemaVersion: Int
        let id: String
        let operation: Operation
        let kind: String
        let previous: Scope
        let target: Scope
        let sources: [MintedIdentifier]
        let targets: [MintedIdentifier]
        let beforeEntities: [CanonicalEntity]
        let afterEntities: [CanonicalEntity]
        let dispositions: [Disposition]
        let evidence: [Evidence]
        let rationale: ExactValue
        let dependencies: [RailwayBuildInput]
    }
    struct Approval: Codable, Equatable, Sendable {
        let author: ExactValue
        let reviewer: ExactValue
        let role: ExactValue
        let reviewedAt: ExactValue
        let reference: ExactValue
        let payloadSHA256: String
    }
    struct Record: Codable, Equatable, Sendable { let payload: Payload; let approval: Approval }
    struct Boundary: Codable, Equatable, Sendable {
        let previousRegistry: Data
        let targetRegistry: Data
        let records: [Record]
        let previousSHA256: String?
    }
    struct History: Codable, Equatable, Sendable {
        let schemaVersion: Int
        let boundaries: [Boundary]
    }
    struct Request: Sendable {
        let previousRegistry: Data
        let targetRegistry: Data
        let recordsBytes: Data
        let previousHistory: Data?
    }
    // Construction confined to successful validation; callers cannot forge capability.
    struct Authorization: Sendable {
        let previousRegistry: Data
        let targetRegistry: Data
        let historyBytes: Data
        let replay: Bool
        let previousHistorySHA256: String?
        fileprivate init(_ request: Request, _ history: Data, _ replay: Bool) {
            previousRegistry = request.previousRegistry; targetRegistry = request.targetRegistry
            historyBytes = history; self.replay = replay
            previousHistorySHA256 = request.previousHistory.map(RailwayArtifact.digest)
        }
    }
    static func hash<T: Encodable>(_ value: T) throws -> String { try RailwayArtifact.digest(RailwayArtifact.encode(value)) }
    static func registry(_ bytes: Data) throws -> MappingRegistry {
        guard !bytes.isEmpty, bytes.count <= maxBytes else { throw Failure.resourceLimit }
        return try MappingRegistry.decodedForIdentityTransition(from: bytes)
    }
    static func decode<T: Codable>(_ type: T.Type, _ bytes: Data) throws -> T {
        guard !bytes.isEmpty, bytes.count <= maxBytes else { throw Failure.resourceLimit }
        guard !RegistryJSON.repeatsKey(Array(bytes)) else { throw Failure.malformed }
        let v = try JSONDecoder().decode(type, from: bytes)
        guard try RailwayArtifact.encode(v) == bytes else { throw Failure.malformed }
        return v
    }
    static func transferred(_ ref: ProviderReference, to target: MintedIdentifier, authority: String) throws -> ProviderReference {
        try ProviderReference(canonicalID: target, sourceID: ref.sourceID, namespace: ref.namespace, value: ref.value,
            status: ref.status, firstSeenInputSHA256: ref.firstSeenInputSHA256, provenance: ref.provenance,
            originalNames: ref.originalNames, attachedBy: authority)
    }
    // Ordinary checkpoint bridges can change sightings/descriptions/status, never identity
    // or attachment authority. The pinned runtime build remains independently required.
    static func bridge(_ old: MappingRegistry, _ next: MappingRegistry) throws {
        guard next.revision >= old.revision, old.entities == next.entities,
              Set(old.references.map(\.key)).isSubset(of: Set(next.references.map(\.key))) else { throw Failure.history }
        for r in old.references {
            guard let n = next.reference(for: r.key), r.canonicalID == n.canonicalID,
                  r.attachedBy == n.attachedBy, r.firstSeenInputSHA256 == n.firstSeenInputSHA256,
                  Set(r.originalNames).isSubset(of: Set(n.originalNames)) else { throw Failure.history }
            if case .retired = r.status { guard n == r else { throw Failure.history } }
        }
    }
    static func validate(_ request: Request) throws -> Authorization {
        let records = try decode([Record].self, request.recordsBytes)
        var history = try request.previousHistory.map { try decode(History.self, $0) } ?? History(schemaVersion: 1, boundaries: [])
        guard history.schemaVersion == 1, history.boundaries.count <= maxBoundaries else { throw Failure.history }
        // Existing attachment/withdrawal authority IDs cannot be recycled as
        // a new transition or binding version, including legacy first attachments.
        let initial = try registry(history.boundaries.first?.previousRegistry ?? request.previousRegistry)
        var reviews = Set(initial.references.compactMap(\.attachedBy))
        for r in initial.references { if case .retired(let review) = r.status { reviews.insert(review) } }
        var versions: [ProviderReferenceKey: String] = [:]
        var priorDigest: String?, lastRegistry: MappingRegistry?
        for boundary in history.boundaries {
            guard boundary.previousSHA256 == priorDigest else { throw Failure.history }
            let previous = try registry(boundary.previousRegistry)
            if let lastRegistry { try bridge(lastRegistry, previous) }
            try validateBoundary(boundary, reviews: &reviews, versions: &versions)
            priorDigest = try hash(boundary); lastRegistry = try registry(boundary.targetRegistry)
        }
        let replay = history.boundaries.last.map {
            $0.previousRegistry == request.previousRegistry && $0.targetRegistry == request.targetRegistry && $0.records == records
        } ?? false
        if !replay {
            if let lastRegistry { try bridge(lastRegistry, registry(request.previousRegistry)) }
            let boundary = Boundary(previousRegistry: request.previousRegistry, targetRegistry: request.targetRegistry,
                                    records: records, previousSHA256: priorDigest)
            try validateBoundary(boundary, reviews: &reviews, versions: &versions)
            history = History(schemaVersion: 1, boundaries: history.boundaries + [boundary])
        }
        guard history.boundaries.count <= maxBoundaries else { throw Failure.resourceLimit }
        let bytes = try RailwayArtifact.encode(history)
        guard bytes.count <= maxBytes else { throw Failure.resourceLimit }
        return Authorization(request, bytes, replay)
    }
    private static func validateBoundary(_ b: Boundary, reviews: inout Set<String>, versions: inout [ProviderReferenceKey: String]) throws {
        let old = try registry(b.previousRegistry), target = try registry(b.targetRegistry)
        let oldScope = try Scope(b.previousRegistry), targetScope = try Scope(b.targetRegistry)
        guard target.formatVersion == 3, old.revision < Int.max, target.revision == old.revision + 1,
              !b.records.isEmpty, b.records.count <= 1024,
              b.records.map({ $0.payload.id }) == b.records.map({ $0.payload.id }).sorted() else { throw Failure.stale }
        var entities = Dictionary(uniqueKeysWithValues: old.entities.map { ($0.id, $0) })
        var references = Dictionary(uniqueKeysWithValues: old.references.map { ($0.key, $0) })
        for r in old.references {
            if let authority = r.attachedBy { reviews.insert(authority) }
            if case .retired(let review) = r.status { reviews.insert(review) }
        }
        var participants = Set<MintedIdentifier>()
        for record in b.records {
            let p = record.payload, approval = record.approval
            guard p.schemaVersion == 1, p.previous == oldScope, p.target == targetScope else { throw Failure.stale }
            guard MappingText.isToken(p.id), reviews.insert(p.id).inserted,
                  approval.payloadSHA256 == (try hash(p)),
                  ISO8601DateFormatter().date(from: approval.reviewedAt.text) != nil else { throw Failure.approval }
            guard p.sources == p.sources.sorted(), p.targets == p.targets.sorted(),
                  p.sources.allSatisfy({ $0.kind.rawValue == p.kind }), p.targets.allSatisfy({ $0.kind.rawValue == p.kind }),
                  p.sources.allSatisfy({ old.entity($0)?.status == .active }),
                  p.targets.allSatisfy({ old.entity($0) == nil && target.entity($0)?.status == .active }) else { throw Failure.delta }
            switch p.operation {
            case .retire: guard p.sources.count == 1 && p.targets.isEmpty else { throw Failure.delta }
            case .replace: guard p.sources.count == 1 && p.targets.count == 1 else { throw Failure.delta }
            case .merge: guard p.sources.count >= 2 && p.targets.count == 1 else { throw Failure.delta }
            case .split: guard p.sources.count == 1 && p.targets.count >= 2 else { throw Failure.delta }
            }
            for id in p.sources + p.targets { guard participants.insert(id).inserted else { throw Failure.delta } }
            guard p.beforeEntities == p.sources.compactMap({ old.entity($0) }),
                  p.afterEntities == (p.sources + p.targets).sorted().compactMap({ target.entity($0) }) else { throw Failure.delta }
            for id in p.sources {
                let e = CanonicalEntity(id: id, status: .retired(successors: p.targets))
                guard target.entity(id) == e else { throw Failure.delta }; entities[id] = e
            }
            for id in p.targets { entities[id] = target.entity(id)! }
            guard !p.evidence.isEmpty, p.evidence.count <= 1024,
                  !p.dependencies.isEmpty, p.dependencies.count <= 32,
                  Set(p.dependencies.map(\.role)).count == p.dependencies.count,
                  p.dependencies.allSatisfy({ MappingText.isToken($0.role) && RailwayArtifact.validHash($0.sha256) }) else { throw Failure.approval }
            var supported = Set<MintedIdentifier>()
            for e in p.evidence {
                guard !e.bytes.isEmpty, e.bytes.count <= maxBytes, e.sha256 == RailwayArtifact.digest(e.bytes),
                      e.offset >= 0, e.offset <= e.bytes.count, !e.quotation.isEmpty,
                      e.quotation.count <= e.bytes.count - e.offset,
                      e.bytes.subdata(in: e.offset..<(e.offset + e.quotation.count)) == e.quotation,
                      !e.members.isEmpty, Set(e.members).count == e.members.count,
                      Set(e.members).isSubset(of: Set(p.sources + p.targets)) else { throw Failure.approval }
                supported.formUnion(e.members)
            }
            guard supported == Set(p.sources + p.targets) else { throw Failure.approval }
            let affected = old.references.filter { p.sources.contains($0.canonicalID) }
            guard p.dispositions.map({ $0.before.key }) == affected.map(\.key) else { throw Failure.disposition }
            for d in p.dispositions {
                guard MappingText.isToken(d.id), reviews.insert(d.id).inserted, d.reviewAuthority == d.id,
                      old.reference(for: d.before.key) == d.before, target.reference(for: d.before.key) == d.after,
                      d.afterSHA256 == (try hash(d.after)),
                      d.predecessor.registrySHA256 == oldScope.sha256,
                      d.predecessor.recordSHA256 == (try hash(d.before)),
                      d.predecessor.bindingVersionID == versions[d.before.key] else { throw Failure.disposition }
                switch d.action {
                case .retainHistorical:
                    guard d.before.status != .active, d.before == d.after else { throw Failure.disposition }
                case .transfer:
                    guard p.targets.contains(d.after.canonicalID),
                          d.before.status == .active || d.before.status == .absent,
                          d.after == (try transferred(d.before, to: d.after.canonicalID, authority: d.id)) else { throw Failure.disposition }
                    versions[d.before.key] = d.id
                }
                references[d.before.key] = d.after
            }
        }
        guard entities.values.sorted(by: { $0.id < $1.id }) == target.entities,
              references.values.sorted(by: { $0.key < $1.key }) == target.references else { throw Failure.delta }
    }

    #if RAILWAY_STORAGE_TESTING
    nonisolated(unsafe) static var failBeforePublication = false
    #endif

    struct Receipt: Codable, Equatable {
        let schemaVersion: Int
        let previousRegistrySHA256: String
        let targetRegistrySHA256: String
        let registrySchemaFrom: Int
        let registrySchemaTo: Int
        let recordsSHA256: String
        let historySHA256: String
        let artifactSHA256: String
    }
    @concurrent static func publish(_ request: Request, snapshot: RailwayArtifactSnapshot,
        dataVersion: ExactValue, inputs: RailwayArtifactBuilder.Inputs, previous: URL, output: URL) async throws -> Receipt {
        let authorization = try validate(request)
        guard inputs.registryBytes == request.targetRegistry,
              !FileManager.default.fileExists(atPath: output.path) else { throw Failure.publication }
        let stage = output.deletingLastPathComponent().appendingPathComponent(".transition-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: stage, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: stage) }
        let artifact = stage.appendingPathComponent("railway.sqlite")
        _ = try await RailwayArtifactBuilder.build(snapshot: snapshot, dataVersion: dataVersion, inputs: inputs,
                                                   previous: previous, output: artifact, authorization: authorization)
        let receipt = Receipt(schemaVersion: 1, previousRegistrySHA256: RailwayArtifact.digest(request.previousRegistry),
            targetRegistrySHA256: RailwayArtifact.digest(request.targetRegistry), registrySchemaFrom: try Scope(request.previousRegistry).schema,
            registrySchemaTo: 3, recordsSHA256: RailwayArtifact.digest(request.recordsBytes),
            historySHA256: RailwayArtifact.digest(authorization.historyBytes), artifactSHA256: RailwayArtifact.digest(try Data(contentsOf: artifact)))
        for (name, bytes) in [("history.json", authorization.historyBytes), ("receipt.json", try RailwayArtifact.encode(receipt))] {
            guard FileManager.default.createFile(atPath: stage.appendingPathComponent(name).path, contents: bytes,
                                                attributes: [.posixPermissions: 0o600]) else { throw Failure.publication }
            guard try Data(contentsOf: stage.appendingPathComponent(name)) == bytes else { throw Failure.publication }
        }
        #if RAILWAY_STORAGE_TESTING
        if failBeforePublication { throw Failure.publication }
        #endif
        // macOS exclusive same-filesystem atomic directory publication. No overwrite.
        guard renamex_np(stage.path, output.path, UInt32(RENAME_EXCL)) == 0 else { throw Failure.publication }
        return receipt
    }
}
