import Foundation
import Darwin

/// Offline, supplied-memory verification of a caller-approved schema-2 baseline.
/// Hashes pin approval premises; this does not authenticate or reapprove source evidence.
enum TripStationCrosswalk {
    static let maxKeys = 64
    static let maxBytes = 16 * 1024 * 1024
    static let maxRecords = 100_000
    enum Failure: String, Error { case invalidInput, identityMismatch, revisionMismatch, resourceLimit, unsafePath, changedInput, invalidRegistry, invalidReviews }
    enum Outcome: String { case resolved, referenceAbsent, referenceInactive, entityInactive, reviewEvidenceMissing, reviewEvidenceMismatch, sourceRevisionMismatch, invalidMemberProvenance, wrongMemberName, wrongProvenanceTable, wrongProvenanceField, inconsistentMemberIdentity, assignmentMembershipMismatch, assignmentTargetMismatch, crossOperatorEvidenceMissing, crossOperatorEvidenceMismatch }
    // ABI 2 diagnostic words: 0 = notEvaluated, 1 = matched, 2 = mismatched.
    // A mismatch dominates; otherwise any unevaluated occurrence prevents a match.
    enum CheckStatus: UInt64 {
        case notEvaluated = 0, matched = 1, mismatched = 2
        var label: String { switch self { case .notEvaluated: return "notEvaluated"; case .matched: return "matched"; case .mismatched: return "mismatched" } }
        static func aggregate(_ statuses: [CheckStatus]) -> CheckStatus {
            if statuses.contains(.mismatched) { return .mismatched }
            return !statuses.isEmpty && statuses.allSatisfy { $0 == .matched } ? .matched : .notEvaluated
        }
    }
    struct Result {
        let outcomes: [Outcome]
        // Private memory only. Never printed by the command; no partial prospective indices.
        let stations: [StationID?]
        let repeated: Int
        let reviewEvidence: CheckStatus
        let memberIdentity: CheckStatus
        var ready: Bool { outcomes.allSatisfy { $0 == .resolved } }
        var prospectiveIndices: [Int]? { ready ? Array(outcomes.indices) : nil }
        var summary: String {
            let resolved = outcomes.filter { $0 == .resolved }.count
            return "requested: \(outcomes.count); resolved: \(resolved); held: \(outcomes.count - resolved); repeated occurrences: \(repeated); registry revision matched: true; evidence closure: \(reviewEvidence.label); member identity: \(memberIdentity.label); ready for later crosswalk construction: \(ready)\n"
        }
    }
    struct Keys: Decodable {
        let schemaVersion: Int
        let sourceID: String
        let namespace: String
        let values: [ExactValue]
        init(sourceID: String, namespace: String, values: [ExactValue]) {
            self.schemaVersion = 1; self.sourceID = sourceID; self.namespace = namespace; self.values = values
        }
        enum CodingKeys: String, CodingKey, CaseIterable { case schemaVersion, sourceID, namespace, values }
        init(from decoder: Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            schemaVersion = try c.decode(Int.self, forKey: .schemaVersion)
            sourceID = try c.decode(String.self, forKey: .sourceID)
            namespace = try c.decode(String.self, forKey: .namespace)
            values = try c.decode([ExactValue].self, forKey: .values)
        }
    }
    struct Expectations {
        let registrySHA256: String
        let registryRevision: Int
        let reviewsSHA256: String
        var keysSHA256: String? = nil
        let sourceID: String
        let inputSHA256: String
        let count: Int
        func validate() throws {
            guard ([registrySHA256, reviewsSHA256, inputSHA256] + [keysSHA256].compactMap { $0 }).allSatisfy(MappingText.isSHA256),
                  MappingText.isToken(sourceID), registryRevision >= 0, (1...maxKeys).contains(count) else { throw Failure.invalidInput }
        }
    }
    static func review(registryBytes: Data, reviewsBytes: Data, keysBytes: Data, expected: Expectations) throws -> Result {
        try expected.validate()
        guard [registryBytes, reviewsBytes, keysBytes].allSatisfy({ $0.count <= maxBytes }) else { throw Failure.resourceLimit }
        guard let keysHash = expected.keysSHA256, sha256Hex(keysBytes) == keysHash else { throw Failure.identityMismatch }
        guard !RegistryJSON.repeatsKey(Array(keysBytes)) else { throw Failure.invalidInput }
        let keys: Keys
        do { keys = try JSONDecoder().decode(Keys.self, from: keysBytes) } catch { throw Failure.invalidInput }
        return try verify(registryBytes: registryBytes, reviewsBytes: reviewsBytes, keys: keys, expected: expected)
    }
    /// Shared in-memory core: both adapters use the same identity and closure checks.
    static func verify(registryBytes: Data, reviewsBytes: Data, keys: Keys, expected: Expectations) throws -> Result {
        try expected.validate()
        guard registryBytes.count <= maxBytes, reviewsBytes.count <= maxBytes else { throw Failure.resourceLimit }
        guard sha256Hex(registryBytes) == expected.registrySHA256,
              sha256Hex(reviewsBytes) == expected.reviewsSHA256 else { throw Failure.identityMismatch }
        guard keys.schemaVersion == 1, keys.namespace == ProviderNamespace.gtfsStopID.rawValue,
              keys.sourceID.utf8.elementsEqual(expected.sourceID.utf8), keys.values.count == expected.count else { throw Failure.invalidInput }
        let registry: MappingRegistry
        do { registry = try MappingRegistry.decoded(from: registryBytes) } catch { throw Failure.invalidRegistry }
        guard registry.revision == expected.registryRevision else { throw Failure.revisionMismatch }
        guard registry.entities.count + registry.references.count <= maxRecords else { throw Failure.resourceLimit }
        let reviews: CrossOperatorRecordsFile
        do { reviews = try CrossOperatorRecordsFile.decoded(from: reviewsBytes) } catch { throw Failure.invalidReviews }
        let nestedCount = reviews.stations.reduce(0) { total, row in
            total + row.sides.count + row.sides.reduce(0) { $0 + $1.stops.count }
        } + reviews.decisions.reduce(0) { total, row in
            total + row.sides.count + row.sides.reduce(0) { $0 + $1.stops.count }
        }
        guard registry.entities.count + registry.references.count + reviews.inputs.count
                + reviews.stations.count + reviews.decisions.count + nestedCount <= maxRecords else { throw Failure.resourceLimit }
        guard reviews.inputs.count == 2, Set(reviews.inputs.map(\.gtfsSourceID)).count == 2,
              reviews.inputs.allSatisfy({ MappingText.isToken($0.gtfsSourceID) && MappingText.isSHA256($0.gtfsArchiveSHA256) }),
              reviews.inputs.contains(where: { $0.gtfsSourceID == expected.sourceID && $0.gtfsArchiveSHA256 == expected.inputSHA256 }),
              Set(reviews.stations.map(\.reviewID)).count == reviews.stations.count,
              Set(reviews.stations.map(\.stationID)).count == reviews.stations.count,
              Set(reviews.decisions.map(\.reviewID)).count == reviews.decisions.count else { throw Failure.invalidReviews }
        // Full accepted assignment file is allowed; unused unrelated assignments are not
        // evidence for selected keys. Conflicting member claims anywhere fail closed.
        var members = Set<ProviderReferenceKey>()
        for assignment in reviews.stations {
            guard MappingText.isToken(assignment.reviewID), assignment.stationID.kind == .station,
                  (1...2).contains(assignment.sides.count), Set(assignment.sides.map(\.gtfsSourceID)).count == assignment.sides.count else { throw Failure.invalidReviews }
            for side in assignment.sides {
                guard reviews.inputs.contains(where: { $0.gtfsSourceID == side.gtfsSourceID }), !side.stops.isEmpty else { throw Failure.invalidReviews }
                for text in side.stops {
                    guard let value = ExactValue(text), members.insert(.init(sourceID: side.gtfsSourceID, namespace: .gtfsStopID, value: value)).inserted else { throw Failure.invalidReviews }
                }
            }
        }
        // Only provenance inside the already hash/schema/revision-verified registry
        // may establish this private member identity. No publisher authentication implied.
        var requestedMemberHashes = Set<String>()
        var provenanceValidatedValues = Set<ExactValue>()
        var evidenceChecks: [CheckStatus] = []
        func resolve(_ value: ExactValue) -> (Outcome, StationID?) {
            evidenceChecks.append(.notEvaluated)
            let key = ProviderReferenceKey(sourceID: expected.sourceID, namespace: .gtfsStopID, value: value)
            guard let ref = registry.reference(for: key) else { return (.referenceAbsent, nil) }
            guard ref.status == .active else { return (.referenceInactive, nil) }
            guard registry.entity(ref.canonicalID)?.status == .active, ref.canonicalID.kind == .station,
                  registry.resolve(key) == ref.canonicalID else { return (.entityInactive, nil) }
            let provenance = ref.provenance
            guard provenance.inputSHA256 == expected.inputSHA256 else { return (.sourceRevisionMismatch, nil) }
            guard provenance.isGTFSPosition, let member = provenance.member,
                  provenance.recordIndex == nil, MappingText.isSHA256(member.sha256) else { return (.invalidMemberProvenance, nil) }
            guard member.name == "stops.txt" else { return (.wrongMemberName, nil) }
            guard provenance.table == "stops" else { return (.wrongProvenanceTable, nil) }
            guard provenance.field == "stop_id" else { return (.wrongProvenanceField, nil) }
            guard provenance.providerKey == value else { return (.sourceRevisionMismatch, nil) }
            requestedMemberHashes.insert(member.sha256)
            provenanceValidatedValues.insert(value)
            // DEC-068: attachedBy is the permanent introducing authority, not the
            // current station assignment ID. Schema validation checks a present token;
            // approved hash-pinned registry/history is the authority premise. Legacy nil
            // is preserved, never filled in. Neither form proves assignment membership.
            // No suffix/prefix relationship or canonical-target-only lookup is used.
            evidenceChecks[evidenceChecks.count - 1] = .mismatched
            guard let assignment = reviews.stations.first(where: { row in
                row.sides.contains { side in
                    side.gtfsSourceID == expected.sourceID && side.stops.contains { ExactValue($0) == value }
                }
            }) else {
                return (reviews.stations.contains { $0.stationID == ref.canonicalID }
                    ? .assignmentMembershipMismatch : .reviewEvidenceMissing, nil)
            }
            guard assignment.stationID == ref.canonicalID else { return (.assignmentTargetMismatch, nil) }
            do {
                var sides: [CrossOperatorSide] = []
                for side in assignment.sides {
                    guard let input = reviews.inputs.first(where: { $0.gtfsSourceID == side.gtfsSourceID }) else { return (.reviewEvidenceMismatch, nil) }
                    var sources: [SourceReference] = []
                    for text in side.stops {
                        guard let memberValue = ExactValue(text), let memberRef = registry.reference(for: .init(sourceID: side.gtfsSourceID, namespace: .gtfsStopID, value: memberValue)),
                              memberRef.status == .active, memberRef.canonicalID == assignment.stationID,
                              memberRef.provenance.inputSHA256 == input.gtfsArchiveSHA256,
                              memberRef.provenance.providerKey == memberValue,
                              memberRef.provenance.member?.name == "stops.txt" else { return (.reviewEvidenceMismatch, nil) }
                        sources.append(memberRef.provenance)
                    }
                    sides.append(try CrossOperatorSide(sourceID: side.gtfsSourceID, inputSHA256: input.gtfsArchiveSHA256, members: sources))
                }
                let typed = try ReviewedStationAssignment(reviewID: assignment.reviewID, stationID: assignment.stationID, sides: sides)
                _ = try ReviewedStationAssignmentSet([typed])
                guard typed.sides.contains(where: { $0.sourceID == expected.sourceID && $0.members.contains(ref.provenance) }) else { return (.reviewEvidenceMismatch, nil) }
                if typed.sides.count == 2 {
                    // The pinned approved file must explicitly join these exact sides.
                    let matches = reviews.decisions.filter { decision in
                        decision.sides.count == 2 && Set(decision.sides.map(\.gtfsSourceID)).count == 2 && decision.sides.allSatisfy { d in
                            let values = d.stops.compactMap(ExactValue.init)
                            return values.count == d.stops.count && Set(values).count == values.count && typed.sides.contains { s in s.sourceID == d.gtfsSourceID && s.members.map(\.providerKey).sorted() == values.sorted() }
                        }
                    }
                    guard matches.count == 1 else { return (.crossOperatorEvidenceMissing, nil) }
                    let decision = matches[0]
                    guard decision.outcome == "same" else { return (.crossOperatorEvidenceMismatch, nil) }
                    let rules = decision.citedAliasRules.compactMap(StationAliasRule.init(rawValue:))
                    let provenance = decision.evidenceProvenance.compactMap(CrossOperatorEvidenceProvenance.init)
                    guard rules.count == decision.citedAliasRules.count,
                          provenance.count == decision.evidenceProvenance.count else { return (.crossOperatorEvidenceMismatch, nil) }
                    do {
                        _ = try ReviewedCrossOperatorRecord(reviewID: decision.reviewID, sides: typed.sides,
                            evidenceSHA256: decision.evidenceSHA256, outcome: .same, reason: decision.reason,
                            citedAliasRules: rules, evidenceProvenance: provenance)
                    } catch { return (.crossOperatorEvidenceMismatch, nil) }
                }
                evidenceChecks[evidenceChecks.count - 1] = .matched
                return (.resolved, StationID(ref.canonicalID.rawValue))
            } catch { return (.reviewEvidenceMismatch, nil) }
        }
        let resolved = keys.values.map(resolve)
        // Invalidate every participating occurrence, not just a later one. This
        // is deterministic even when member disagreement also breaks assignment closure.
        let answers = resolved.enumerated().map { index, answer -> (Outcome, StationID?) in
            if requestedMemberHashes.count > 1 && provenanceValidatedValues.contains(keys.values[index]) {
                return (.inconsistentMemberIdentity, nil)
            }
            return answer
        }
        let memberStatus: CheckStatus = requestedMemberHashes.count > 1 ? .mismatched
            : (keys.values.allSatisfy { provenanceValidatedValues.contains($0) } ? .matched : .notEvaluated)
        return .init(outcomes: answers.map(\.0), stations: answers.map(\.1), repeated: keys.values.count - Set(keys.values).count,
                     reviewEvidence: .aggregate(evidenceChecks), memberIdentity: memberStatus)
    }

    /// Same-descriptor, no-follow traversal, bounded reads; every input is owner-only.
    /// No subprocess, copy, output file or private diagnostic is produced.
    final class Input {
        let file: ArchiveFile
        let path: String
        let bytes: Data
        init(path: String, root: FileIdentity) throws {
            guard path.hasPrefix("/") else { throw Failure.unsafePath }
            let parts = path.dropFirst().split(separator: "/", omittingEmptySubsequences: false)
            guard !parts.isEmpty, parts.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else { throw Failure.unsafePath }
            var parent = open("/", O_RDONLY | O_DIRECTORY | O_CLOEXEC)
            guard parent >= 0 else { throw Failure.unsafePath }
            defer { close(parent) }
            for part in parts.dropLast() {
                let next = openat(parent, String(part), O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
                guard next >= 0 else { throw Failure.unsafePath }
                close(parent); parent = next
            }
            // Open through the held parent; ArchiveFile provides bounded descriptor reads.
            // F_GETPATH below also proves the opened file's actual outside-repository location.
            let fd = openat(parent, String(parts.last!), O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK)
            guard fd >= 0 else { throw Failure.unsafePath }
            defer { close(fd) }
            var info = stat()
            guard fstat(fd, &info) == 0, info.st_uid == getuid(), info.st_mode & 0o077 == 0,
                  info.st_mode & S_IFMT == S_IFREG, let actual = descriptorPath(fd),
                  !isInsideRepository(actual, repositoryRoot: root) else { throw Failure.unsafePath }
            // Existing ArchiveFile has a path initializer. Hold and compare identities
            // across that second open; no bytes are read from a substituted file.
            let opened = try ArchiveFile(resolvedPath: actual, limit: Int64(maxBytes))
            guard FileIdentity(descriptor: opened.descriptor) == FileIdentity(descriptor: fd),
                  ArchiveFile.state(of: fd) == opened.initialState else { throw Failure.changedInput }
            guard let data = try opened.readAll(maximum: Int64(maxBytes)) else { throw Failure.resourceLimit }
            self.file = opened; self.path = path; self.bytes = data
            try verify()
        }
        func verify() throws {
            // Re-traversal disallows ancestor symlink substitution as well as leaf replacement.
            let parts = path.dropFirst().split(separator: "/")
            var fd = open("/", O_RDONLY | O_DIRECTORY | O_CLOEXEC)
            guard fd >= 0 else { throw Failure.changedInput }
            defer { close(fd) }
            for (i, part) in parts.enumerated() {
                let next = openat(fd, String(part), O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK | (i == parts.count - 1 ? 0 : O_DIRECTORY))
                guard next >= 0 else { throw Failure.changedInput }
                close(fd); fd = next
            }
            guard FileIdentity(descriptor: fd) == FileIdentity(descriptor: file.descriptor),
                  ArchiveFile.state(of: file.descriptor) == file.initialState,
                  let now = try file.readAll(maximum: Int64(maxBytes)), now == bytes else { throw Failure.changedInput }
        }
    }
    static func run(registryPath: String, reviewsPath: String, keysPath: String, expected: Expectations, root: FileIdentity) throws -> Result {
        try expected.validate()
        let r = try Input(path: registryPath, root: root)
        let e = try Input(path: reviewsPath, root: root)
        let k = try Input(path: keysPath, root: root)
        let result = try review(registryBytes: r.bytes, reviewsBytes: e.bytes, keysBytes: k.bytes, expected: expected)
        try r.verify(); try e.verify(); try k.verify()
        return result
    }
}
