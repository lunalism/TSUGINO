#if DEBUG
import Foundation

/// Digest/representation findings only. No successful registry-candidate case exists.
nonisolated struct SyntheticRegistrationDiagnostic: Equatable, Sendable {
    let issue: SyntheticRegistrationIssue
    let locator: String
}
nonisolated enum SyntheticRegistrationClosureResult: Sendable {
    case completeRepresentation
    case incomplete([SyntheticRegistrationDiagnostic])
    case invalid([SyntheticRegistrationDiagnostic])
}

nonisolated enum SyntheticTripRegistrationClosure {
    typealias V = SyntheticRegistrationValue
    struct Entry: Sendable {
        let kind: String
        let id: String
        let document: SyntheticRegistrationDocument
    }
    private struct Key: Hashable { let kind: String; let id: String }

    /// Caller supplies invented records only. This does not load files, resolve a registry,
    /// authenticate a reviewer, validate evidence applicability, or replay a checkpoint.
    static func validate(roots: [SyntheticRegistrationDocument], catalog: [Entry]) -> SyntheticRegistrationClosureResult {
        var findings: [SyntheticRegistrationDiagnostic] = []
        func add(_ issue: SyntheticRegistrationIssue, _ id: String) {
            let diagnostic = SyntheticRegistrationDiagnostic(issue: issue, locator: id)
            if !findings.contains(diagnostic) { findings.append(diagnostic) }
        }
        var byKey: [Key: SyntheticRegistrationDocument] = [:]
        var globalIDs: [String: (String, Data)] = [:]
        for entry in catalog {
            guard SyntheticRegistrationSchema.kinds.contains(entry.kind), MappingText.isToken(entry.id),
                  matches(entry) else { add(.malformedInput, "catalog"); continue }
            let key = Key(kind: entry.kind, id: entry.id)
            if byKey[key] != nil { add(.historyConflict, entry.id) }
            if let old = globalIDs[entry.id], old.0 != entry.kind || old.1 != entry.document.bytes { add(.historyConflict, entry.id) }
            else { globalIDs[entry.id] = (entry.kind, entry.document.bytes) }
            // Never choose a winner to claim success; retain one only for independent checks.
            if byKey[key] == nil { byKey[key] = entry.document }
        }

        // Envelopes/history retain their own dependency bytes. Read those as syntax only;
        // this is not history replay or validation of their business assertions.
        func collect(_ value: V) {
            if case .object(let object) = value {
                func insert(_ kind: String, _ id: String?, _ format: SyntheticRegistrationFormat, _ value: V) {
                    guard let id else { return }
                    do {
                        let doc = try SyntheticTripRegistrationCodec.make(format, value)
                        let entry = Entry(kind: kind, id: id, document: doc)
                        guard matches(entry) else { add(.malformedInput, id); return }
                        let key = Key(kind: kind, id: id)
                        if let old = byKey[key], old.bytes != doc.bytes { add(.historyConflict, id) }
                        if let old = globalIDs[id], old.0 != kind || old.1 != doc.bytes { add(.historyConflict, id) }
                        if byKey[key] == nil { byKey[key] = doc; globalIDs[id] = (kind,doc.bytes) }
                    } catch let issue as SyntheticRegistrationIssue { add(issue,id) }
                    catch { add(.malformedInput,id) }
                }
                if object["evidenceID"] != nil && object["disposition"] != nil { insert("evidence",object["evidenceID"]?.text,.evidence,value) }
                if object["artifactID"] != nil && object["packetBytes"] != nil { insert("s9Artifact",object["artifactID"]?.text,.s9Artifact,value) }
                if object["payload"]?["subjectKind"]?.text == "profile" { insert("profile",object["payload"]?["subjectID"]?.text,.approved,value) }
                if object["stipulated"]?.text == "synthetic" { insert("seedRecord",object["recordID"]?.text,.seedRecord,value) }
                if let kind = object["kind"]?.text, let id = object["id"]?.text, let base64 = object["bytes"]?.text,
                   let bytes = Data(base64Encoded: base64) {
                    let format: SyntheticRegistrationFormat = kind == "evidence" ? .evidence : kind == "profile" ? .approved : kind == "s9Artifact" ? .s9Artifact : .seedRecord
                    do {
                        let doc = try SyntheticTripRegistrationCodec.read(format, bytes)
                        insert(kind,id,format,doc.value)
                    } catch let issue as SyntheticRegistrationIssue { add(issue,id) }
                    catch { add(.malformedInput,id) }
                }
                for child in object.values { collect(child) }
            } else { for child in value.items { collect(child) } }
        }
        for root in roots { collect(root.value) }

        // Identities of immutable review/payload/operation records, across all supplied roots.
        // Equal repeated copies are references; changed content cannot reuse an ID.
        var immutable: [String: Data] = [:]
        func remember(_ id: String?, _ value: V) {
            guard let id, let bytes = try? SyntheticTripRegistrationCodec.encoded(value) else { return }
            if let prior = immutable[id], prior != bytes { add(.historyConflict, id) }
            else { immutable[id] = bytes }
        }
        func inspect(_ value: V) {
            guard case .object(let object) = value else {
                for item in value.items { inspect(item) }; return
            }
            if object["payloadSHA256"] != nil { remember(object["reviewID"]?.text, value) }
            if object["format"]?.text == "tsugino.synthetic-trip-payload" {
                remember(object["subjectID"]?.text, value)
                let field = object["subjectKind"]?.text == "profile" ? "profileID" : "requestID"
                if let inner = object["payload"]?[field]?.text, inner != object["subjectID"]?.text { add(.historyConflict, object["subjectID"]!.text!) }
            }
            if object["disposition"] != nil { remember(object["evidenceID"]?.text, value) }
            if object["packetBytes"] != nil { remember(object["artifactID"]?.text, value) }
            if object["stipulated"] != nil { remember(object["recordID"]?.text, value) }
            if object["recordID"] != nil && object["tripID"] != nil {
                remember(object["recordID"]?.text, value); remember(object["allocationRequestID"]?.text, value)
            }
            if let wrapper = object["payload"], wrapper["format"]?.text == "tsugino.synthetic-trip-payload" {
                let id = wrapper["subjectID"]!.text!
                if let approval = object["approval"] { checkApproval(approval, wrapper, add) }
                else { add(.approvalMissing, id) }
            }
            // Requests inside envelopes/boundaries use a separate approvals array.
            if let request = object["request"], let approvals = object["approvals"] {
                let matching = approvals.items.filter { $0["subjectID"]?.text == request["subjectID"]?.text }
                if matching.isEmpty { add(.approvalMissing, request["subjectID"]!.text!) }
                if matching.count > 1 { add(.approvalConflict, request["subjectID"]!.text!) }
                for approval in approvals.items { checkApproval(approval, request, add) }
            }
            // Local byte-digest checks, not validity/replay of the opaque registry/history.
            for (bytesKey, digestKey) in [("registryBytes","registrySHA256"),("legacyHistoryBytes","legacyHistorySHA256")] {
                if let raw = object[bytesKey]?.text, let bytes = Data(base64Encoded: raw), let expected = object[digestKey]?.text,
                   SyntheticTripRegistrationCodec.digest(bytes) != expected { add(.historyConflict, object["lineageID"]?.text ?? "baseline") }
            }
            if object["legacyHistoryState"]?.text == "present", object["legacyHistoryBytes"] == nil || object["legacyHistorySHA256"] == nil {
                add(.historyUnavailable, object["lineageID"]?.text ?? "baseline")
            }
            if object["legacyHistoryState"]?.text == "none", object["legacyHistoryBytes"] != nil || object["legacyHistorySHA256"] != nil {
                add(.historyConflict, object["lineageID"]?.text ?? "baseline")
            }
            if let baseline = object["baseline"], let expected = object["history"]?["baselineSHA256"]?.text,
               let bytes = try? SyntheticTripRegistrationCodec.encoded(baseline), SyntheticTripRegistrationCodec.digest(bytes) != expected {
                add(.historyConflict, object["lineageID"]?.text ?? "baseline")
            }
            if let authority = object["ownerAuthority"]?.text,
               let boundAuthority = object["baseline"]?["payload"]?["payload"]?["ownerAuthority"]?.text,
               !authority.utf8.elementsEqual(boundAuthority.utf8) {
                add(.approvalConflict, object["lineageID"]?.text ?? "baseline")
            }
            for child in object.values { inspect(child) }
        }

        let documents = roots + catalog.map(\.document) + byKey.keys.sorted(by: precedes).compactMap { byKey[$0] }
        for doc in documents { inspect(doc.value) }

        func missing(_ key: Key) {
            add(key.kind == "s9Artifact" ? .snapshotUnavailable : key.kind == "profile" ? .scopeUnavailable : key.kind == "evidence" ? .correspondenceUnavailable : .historyUnavailable, key.id)
        }
        func body(_ value: V) -> V {
            if value["payload"]?["format"]?.text == "tsugino.synthetic-trip-payload" { return value["payload"]!["payload"]! }
            if value["format"]?.text == "tsugino.synthetic-trip-payload" { return value["payload"]! }
            return value
        }
        func inventory(_ value: V) -> [Key: String] {
            var result: [Key: String] = [:]
            for dep in body(value)["dependencyDigests"]?.items ?? [] {
                result[Key(kind: dep["kind"]!.text!, id: dep["id"]!.text!)] = dep["sha256"]!.text!
            }
            return result
        }
        var unsafeArtifacts = Set<String>()
        func direct(_ value: V) -> Set<Key> {
            let b = body(value)
            var keys = Set<Key>()
            func one(_ kind: String, _ id: String?) { if let id { keys.insert(Key(kind: kind, id: id)) } }
            func many(_ kind: String, _ values: V?) { for v in values?.items ?? [] { one(kind, v.text) } }
            many("profile", b["profileIDs"]); many("evidence", b["evidenceIDs"]); many("s9Artifact", b["s9ArtifactIDs"])
            for name in ["uniquenessEvidenceIDs","meaningEvidenceIDs","continuityEvidenceIDs","correspondenceEvidenceIDs"] { many("evidence", b[name]) }
            for record in b["records"]?.items ?? [] {
                many("evidence", record["correspondenceEvidenceIDs"])
                for name in ["snapshotArtifactID","previousArtifactID","nextArtifactID"] { one("s9Artifact",record[name]?.text) }
            }
            for binding in (b["proofBindings"]?.items ?? []) + (b["viewBindings"]?.items ?? []) {
                one("evidence", binding["evidenceID"]?.text)
                one("profile", binding["profileID"]?.text ?? binding["scope"]?["profileID"]?.text)
            }
            if let encoded = b["packetBytes"]?.text, let bytes = Data(base64Encoded: encoded) {
                if SyntheticTripRegistrationCodec.digest(bytes) != b["packetSHA256"]?.text { add(.historyConflict, b["artifactID"]!.text!) }
                do {
                    let packet = try SyntheticTripRegistrationCodec.read(.s9Packet, bytes)
                    for run in packet.value["runs"]!.items { one("s9Artifact", run["priorArtifactID"]?.text) }
                } catch let issue as SyntheticRegistrationIssue {
                    unsafeArtifacts.insert(b["artifactID"]!.text!); add(issue, b["artifactID"]!.text!)
                } catch {
                    unsafeArtifacts.insert(b["artifactID"]!.text!); add(.malformedInput, b["artifactID"]!.text!)
                }
            }
            if let seed = b["seedInventory"] {
                many("seedRecord", seed["attachmentRecordIDs"]); many("seedRecord", seed["statusRecordIDs"])
                for selection in seed["selections"]!.items { one("s9Artifact", selection["artifactID"]?.text) }
            }
            // Seed records may carry opaque, digest-bound evidence/profile/artifact premises.
            // Their predecessor/status semantics are slice B, never inferred here.
            if b["stipulated"]?.text == "synthetic" { keys.formUnion(inventory(value).keys) }
            return keys
        }

        // Traverse declared digest edges too: a cycle cannot be concealed as an extra inventory item.
        var active = Set<Key>(), finished = Set<Key>()
        func visit(_ key: Key) {
            if active.contains(key) { add(key.kind == "s9Artifact" ? .snapshotConflict : .historyConflict, key.id); return }
            guard !finished.contains(key), let doc = byKey[key] else { return }
            active.insert(key)
            for next in Set(inventory(doc.value).keys).union(direct(doc.value)).sorted(by: precedes) { visit(next) }
            active.remove(key); finished.insert(key)
        }
        for key in byKey.keys.sorted(by: precedes) { visit(key) }

        func checkClosure(_ value: V, _ locator: String) {
            let declared = inventory(value)
            var reached = Set<Key>(), unresolved = false
            func follow(_ key: Key) {
                guard reached.insert(key).inserted else { return }
                guard let doc = byKey[key] else { unresolved = true; missing(key); return }
                for next in direct(doc.value).sorted(by: precedes) { follow(next) }
                if unsafeArtifacts.contains(body(doc.value)["artifactID"]?.text ?? "") { unresolved = true }
            }
            for key in direct(value).sorted(by: precedes) { follow(key) }
            if unsafeArtifacts.contains(body(value)["artifactID"]?.text ?? "") { unresolved = true }
            for key in reached where declared[key] == nil { missing(key) }
            if !unresolved && !Set(declared.keys).isSubset(of: reached) { add(.historyConflict, locator) }
            for (key, digest) in declared {
                guard let doc = byKey[key] else { missing(key); continue }
                if doc.sha256 != digest { add(.historyConflict, key.id) }
            }
        }
        // Each nested approved baseline/profile/request is checked, without replaying boundaries.
        func walk(_ v: V) {
            if case .object(let fields) = v {
                if fields["dependencyDigests"] != nil {
                    let id = fields["requestID"]?.text ?? fields["profileID"]?.text ?? fields["artifactID"]?.text ?? fields["recordID"]?.text ?? fields["lineageID"]?.text ?? "closure"
                    checkClosure(v, id)
                }
                for child in fields.values { walk(child) }
            } else { for child in v.items { walk(child) } }
        }
        for doc in documents { walk(doc.value) }

        findings.sort { $0.issue.rawValue == $1.issue.rawValue ? $0.locator.utf8.lexicographicallyPrecedes($1.locator.utf8) : $0.issue.rawValue < $1.issue.rawValue }
        if findings.isEmpty { return .completeRepresentation }
        if findings.contains(where: { $0.issue.rawValue < SyntheticRegistrationIssue.approvalMissing.rawValue }) { return .invalid(findings) }
        return .incomplete(findings)
    }

    private static func precedes(_ a: Key, _ b: Key) -> Bool {
        SyntheticRegistrationSchema.less([a.kind,a.id], [b.kind,b.id])
    }
    private static func matches(_ entry: Entry) -> Bool {
        let v = entry.document.value
        switch (entry.kind, entry.document.format) {
        case ("evidence", .evidence): return v["evidenceID"]?.text == entry.id
        case ("profile", .approved): return v["payload"]?["subjectKind"]?.text == "profile" && v["payload"]?["subjectID"]?.text == entry.id && v["payload"]?["payload"]?["profileID"]?.text == entry.id
        case ("s9Artifact", .s9Artifact): return v["artifactID"]?.text == entry.id
        case ("seedRecord", .seedRecord): return v["recordID"]?.text == entry.id
        default: return false
        }
    }
    private static func checkApproval(_ approval: V, _ wrapper: V, _ add: (SyntheticRegistrationIssue, String) -> Void) {
        let id = wrapper["subjectID"]!.text!
        guard let bytes = try? SyntheticTripRegistrationCodec.encoded(wrapper),
              approval["subjectKind"]?.text == wrapper["subjectKind"]?.text,
              approval["subjectID"]?.text == id,
              approval["payloadSHA256"]?.text == SyntheticTripRegistrationCodec.digest(bytes) else { add(.approvalConflict, id); return }
        // No owner authentication, evidence-disposition assessment or operation admission.
    }
}
#endif
