#if DEBUG
import Foundation

/// Slice B reports mechanical integrity only. No candidate bytes or admission capability escape.
nonisolated enum SyntheticRegistrationHistoryResult: Sendable {
    case checked(SyntheticRegistrationHistoryReport)
    case held([SyntheticRegistrationDiagnostic])
    case rejected([SyntheticRegistrationDiagnostic])
}
nonisolated struct SyntheticRegistrationHistoryReport: Sendable {
    let unchangedReplay: Bool
    let conversionOnly: Bool
    let stipulatedSeed: Bool
    /// Includes retained boundaries, not merely the incoming request. Slice C must validate these.
    let businessAdmissionRequired: [String]
    fileprivate init(replay: Bool, conversion: Bool, seed: Bool, deferred: [String]) {
        unchangedReplay = replay; conversionOnly = conversion; stipulatedSeed = seed
        businessAdmissionRequired = deferred
    }
}

nonisolated enum SyntheticTripRegistrationHistory {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias Entry = SyntheticTripRegistrationClosure.Entry

    /// All bytes are invented, supplied in memory. The independently supplied current checkpoint
    /// pins the entire retained history. This neither authenticates it nor reads/mutates a registry.
    static func validate(envelopeBytes: Data, currentRegistryBytes: Data,
                         currentCheckpointBytes: Data, catalog: [Entry] = []) -> SyntheticRegistrationHistoryResult {
        var audit = Audit(catalog: catalog)
        return audit.run(envelopeBytes, currentRegistryBytes, currentCheckpointBytes)
    }

    private static func bytes(_ value: V?) -> Data? { value?.text.flatMap { Data(base64Encoded: $0) } }
    private static func encoded(_ value: V) -> Data { (try? C.encoded(value)) ?? Data() }
    private static func equal(_ a: V?, _ b: V?) -> Bool {
        switch (a,b) { case (nil,nil): true; case let (a?,b?): encoded(a) == encoded(b); default: false }
    }
    private static func number(_ value: V?) -> Int? { if case .integer(let n) = value { n } else { nil } }
    private static func replacing(_ value: V, _ key: String, _ new: V) -> V {
        guard case .object(var fields) = value else { return value }; fields[key] = new; return .object(fields)
    }
    private static func referenceKey(_ ref: V) -> Data {
        encoded(.array([ref["sourceID"]!,ref["namespace"]!,ref["value"]!]))
    }

    private struct Audit {
        var catalog: [Entry]
        var findings: [SyntheticRegistrationDiagnostic] = []
        var documents: [String: [SyntheticRegistrationDocument]] = [:]
        // Tokens are ASCII; byte equality for payload text is always obtained through encoding.
        var IDs: [String: Data] = [:]
        enum RetainedKind: String { case authority, allocation, seedRecord, s9Artifact, profile, evidence }
        var retainedIDs: [String: RetainedKind] = [:]
        var knownAuthorities = Set<String>()
        var retainedProfileApprovals = Set<String>()
        var suppliedDependencies: [String: Set<RetainedKind>] = [:]
        struct Binding: Hashable { let kind: RetainedKind; let id: String; let digest: String }
        var observedBindings = Set<Binding>()
        var retainedBindings = Set<Binding>()
        var owner = "", lineage = ""
        var deferred: [String] = []

        mutating func add(_ issue: SyntheticRegistrationIssue, _ locator: String) {
            let d = SyntheticRegistrationDiagnostic(issue: issue, locator: locator)
            if !findings.contains(d) { findings.append(d) }
        }
        /// A fresh record/approval/allocation cannot reuse even an identically quoted old ID.
        mutating func reserve(_ id: String, _ content: Data, retainedProfileApproval: Bool = false) {
            // A baseline inventory may quote the approval of its digest-bound profile dependency.
            // That quotation cannot turn an actual legacy/seed authority into a profile approval.
            let inventoryQuote = retainedProfileApproval && retainedIDs[id] == .authority && !knownAuthorities.contains(id)
            if IDs[id] != nil || (retainedIDs[id] != nil && !inventoryQuote) { add(.historyConflict,id) }
            if IDs[id] == nil { IDs[id] = content }
            if retainedProfileApproval { retainedProfileApprovals.insert(id) }
        }
        /// Inventory, registry references and legacy history may quote one old authority repeatedly.
        /// Check both directions so discovery order cannot conceal a fresh introduction collision.
        mutating func retain(_ id: String, as kind: RetainedKind, inventoryOnly: Bool = false) {
            let inventoryQuote = inventoryOnly && (
                (kind == .authority && retainedProfileApprovals.contains(id)) ||
                suppliedDependencies[id]?.contains(kind) == true)
            if (IDs[id] != nil && !inventoryQuote) || retainedIDs[id].map({ $0 != kind }) == true { add(.historyConflict,id) }
            if retainedIDs[id] == nil { retainedIDs[id] = kind }
            if kind == .authority && !inventoryOnly { knownAuthorities.insert(id) }
        }
        mutating func dependencies(_ values: [V], historical: Bool) {
            var visited = Set<Binding>()
            walkDependencies(values,historical:historical,visited:&visited)
        }
        func declarations(_ value: V) -> [V] {
            let payload = body(value)
            var values = payload["dependencyDigests"]?.items ?? []
            // A paired predecessor ID/SHA is an explicit binding, not an ID-only association.
            if payload["stipulated"]?.text == "synthetic",
               let prior = payload["predecessorRecordID"], let digest = payload["predecessorRecordSHA256"] {
                values.append(.object(["kind":.string("seedRecord"),"id":prior,"sha256":digest]))
            }
            return values
        }
        mutating func walkDependencies(_ values: [V], historical: Bool, visited: inout Set<Binding>) {
            for d in values {
                let id = d["id"]!.text!, digest = d["sha256"]!.text!
                let kind = RetainedKind(rawValue:d["kind"]!.text!)!
                let binding = Binding(kind:kind,id:id,digest:digest)
                // Explicit incompatible hashes contradict even when neither payload is available.
                // Observing an incoming/catalog assertion does not establish historical membership.
                if observedBindings.contains(where: { $0.id == id && $0 != binding }) { add(.historyConflict,id) }
                observedBindings.insert(binding)
                if historical {
                    retain(id,as:kind,inventoryOnly:true)
                    retainedBindings.insert(binding)
                }
                // An incomplete outer closure cannot erase a nested assertion in exact retained bytes.
                // Never derive historical membership from unrelated catalog bytes or a digest mismatch.
                let key = d["kind"]!.text! + ":" + id, document = resolved(key,digest:digest)
                if document == nil && !variants(key).isEmpty { add(.historyConflict,id) }
                guard let doc = document,
                      visited.insert(binding).inserted else { continue }
                walkDependencies(declarations(doc.value),historical:historical,visited:&visited)
                if kind == .seedRecord && historical { retain(doc.value["authorityID"]!.text!,as:.authority) }
            }
        }
        mutating func read(_ format: SyntheticRegistrationFormat, _ data: Data, _ locator: String) -> SyntheticRegistrationDocument? {
            do { return try C.read(format,data) }
            catch let issue as SyntheticRegistrationIssue { add(issue,locator) }
            catch { add(.malformedInput,locator) }
            return nil
        }
        mutating func registry(_ data: Data, _ locator: String) -> V? {
            guard !data.isEmpty, data.count <= C.maximumBytes, !RegistryJSON.repeatsKey(Array(data)),
                  let raw = try? JSONDecoder().decode(V.self,from:data),
                  let version = number(raw["schemaVersion"]) else { add(.malformedInput,locator); return nil }
            if version == 4 {
                guard let value = read(.registry,data,locator)?.value else { return nil }
                validateRegistry4(value,locator)
                return value
            }
            guard version == 2 || version == 3 else { add(.unsupportedVersion,locator); return nil }
            do {
                let legacy = try MappingRegistry.decodedForIdentityTransition(from:data)
                // Comparison view only. Exact original bytes remain pinned separately.
                return try JSONDecoder().decode(V.self,from:legacy.encoded())
            } catch { add(.malformedInput,locator); return nil }
        }
        mutating func validateRegistry4(_ value: V, _ locator: String) {
            let entities = value["entities"]!.items, references = value["references"]!.items
            let trips = entities.filter { $0["id"]!.text!.hasPrefix("trp_") }
            // Reuse the actual legacy reader for the entire non-Trip comparison view.
            let legacy = V.object(["schemaVersion":.integer(3),"revision":value["revision"]!,
                "entities":.array(entities.filter { !$0["id"]!.text!.hasPrefix("trp_") }),
                "references":.array(references.filter { $0["namespace"]?.text != "gtfs.trip_id" })])
            if (try? MappingRegistry.decodedForIdentityTransition(from:encoded(legacy))) == nil { add(.historyConflict,locator) }
            for trip in trips {
                let body = trip["id"]!.text!.dropFirst(4)
                if entities.filter({ $0["id"]!.text!.dropFirst(4) == body }).count > 1 { add(.identityConflict,locator) }
            }
            for ref in references where ref["namespace"]?.text == "gtfs.trip_id" {
                do {
                    let source = try JSONDecoder().decode(SourceReference.self,from:encoded(ref["provenance"]!))
                    let names = try JSONDecoder().decode([OriginalName].self,from:encoded(ref["originalNames"]!))
                    if !source.isGTFSPosition || !names.allSatisfy({ $0.source.isGTFSPosition }) { add(.historyConflict,locator) }
                } catch { add(.historyConflict,locator) }
                guard let entity = trips.first(where:{ equal($0["id"],ref["canonicalID"]) }) else { add(.referenceConflict,locator); continue }
                if ref["status"]?["state"]?.text == "active" && entity["state"]?.text != "active" { add(.referenceConflict,locator) }
            }
            // Trip transitions are not admitted here; historical seed structure must still be safe.
            for trip in trips {
                let id = trip["id"]!.text!
                for successor in trip["successors"]?.items ?? [] {
                    if successor.text == id || !trips.contains(where:{ equal($0["id"],successor) }) { add(.historyConflict,locator) }
                }
                var visited = Set<String>(), active = Set<String>()
                func visit(_ id: String) -> Bool {
                    if active.contains(id) { return false }; if visited.contains(id) { return true }
                    active.insert(id)
                    for s in trips.first(where:{ $0["id"]?.text == id })?["successors"]?.items ?? [] {
                        if !visit(s.text!) { return false }
                    }
                    active.remove(id); visited.insert(id); return true
                }
                if !visit(id) { add(.historyConflict,locator) }
            }
        }
        func variants(_ key: String) -> [SyntheticRegistrationDocument] {
            (documents[key] ?? []).sorted { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        }
        func resolved(_ key: String, digest: String?) -> SyntheticRegistrationDocument? {
            let matches = variants(key).filter { digest == nil || $0.sha256 == digest }
            return matches.count == 1 ? matches[0] : nil
        }
        func historicalVariants(_ kind: RetainedKind, _ id: String) -> [SyntheticRegistrationDocument] {
            let bindings = retainedBindings.filter { $0.kind == kind && $0.id == id }
            let supplied = variants(kind.rawValue + ":" + id)
            // No declared digest: only an unambiguous supplied record can be inspected.
            if bindings.isEmpty { return supplied.count == 1 ? supplied : [] }
            return supplied.filter { bindings.contains(Binding(kind:kind,id:id,digest:$0.sha256)) }
        }
        @discardableResult
        mutating func insert(_ kind: String, _ id: String, _ doc: SyntheticRegistrationDocument, locator: String) -> Bool {
            let v = doc.value
            let matches: Bool
            switch (kind,doc.format) {
            case ("seedRecord",.seedRecord): matches = v["recordID"]?.text == id
            case ("s9Artifact",.s9Artifact): matches = v["artifactID"]?.text == id
            case ("evidence",.evidence): matches = v["evidenceID"]?.text == id
            case ("profile",.approved): matches = v["payload"]?["subjectKind"]?.text == "profile" &&
                v["payload"]?["subjectID"]?.text == id && v["payload"]?["payload"]?["profileID"]?.text == id
            default: matches = false
            }
            guard matches, MappingText.isToken(id) else { add(.malformedInput,locator); return false }
            let key = kind + ":" + id
            if documents[key]?.contains(where: { $0.bytes == doc.bytes }) == true { return true }
            if documents[key] != nil { add(.historyConflict,id) }
            documents[key,default:[]].append(doc)
            return true
        }
        mutating func collect(_ value: V) {
            if case .object(let fields) = value {
                if let id = fields["evidenceID"]?.text, fields["disposition"] != nil,
                   let doc = try? C.make(.evidence,value) { insert("evidence",id,doc,locator:id) }
                if fields["payload"]?["subjectKind"]?.text == "profile",
                   let id = fields["payload"]?["subjectID"]?.text,
                   let doc = try? C.make(.approved,value) { insert("profile",id,doc,locator:id) }
                if let kind = fields["kind"]?.text, let id = fields["id"]?.text,
                   let data = bytes(fields["bytes"]), SyntheticRegistrationSchema.kinds.contains(kind) {
                    let format: SyntheticRegistrationFormat = kind == "profile" ? .approved : kind == "evidence" ? .evidence : kind == "s9Artifact" ? .s9Artifact : .seedRecord
                    if let doc = read(format,data,id) { insert(kind,id,doc,locator:id) }
                }
                if let id = fields["artifactID"]?.text, fields["packetBytes"] != nil,
                   let doc = try? C.make(.s9Artifact,value) { insert("s9Artifact",id,doc,locator:id) }
                for key in fields.keys.sorted() { collect(fields[key]!) }
            } else if case .array(let values) = value { for child in values { collect(child) } }
        }
        func body(_ v: V) -> V {
            if v["payload"]?["format"]?.text == "tsugino.synthetic-trip-payload" { return v["payload"]!["payload"]! }
            if v["format"]?.text == "tsugino.synthetic-trip-payload" { return v["payload"]! }
            return v
        }
        func digestInventory(_ v: V) -> [String:String] {
            Dictionary(uniqueKeysWithValues:(body(v)["dependencyDigests"]?.items ?? []).map {
                ($0["kind"]!.text! + ":" + $0["id"]!.text!,$0["sha256"]!.text!)
            })
        }
        func direct(_ v: V) -> (keys: Set<String>, unsafe: Bool) {
            let b = body(v)
            var keys = Set<String>(), unsafe = false
            func one(_ kind: String, _ id: String?) { if let id { keys.insert(kind + ":" + id) } }
            func many(_ kind: String, _ values: V?) { for id in values?.items ?? [] { one(kind,id.text) } }
            many("profile",b["profileIDs"]); many("evidence",b["evidenceIDs"]); many("s9Artifact",b["s9ArtifactIDs"])
            for name in ["uniquenessEvidenceIDs","meaningEvidenceIDs","continuityEvidenceIDs","correspondenceEvidenceIDs"] { many("evidence",b[name]) }
            for record in b["records"]?.items ?? [] {
                many("evidence",record["correspondenceEvidenceIDs"])
                for name in ["snapshotArtifactID","previousArtifactID","nextArtifactID"] { one("s9Artifact",record[name]?.text) }
            }
            for binding in (b["proofBindings"]?.items ?? []) + (b["viewBindings"]?.items ?? []) {
                one("evidence",binding["evidenceID"]?.text)
                one("profile",binding["profileID"]?.text ?? binding["scope"]?["profileID"]?.text)
            }
            if let data = bytes(b["packetBytes"]) {
                if let packet = try? C.read(.s9Packet,data) {
                    for run in packet.value["runs"]!.items { one("s9Artifact",run["priorArtifactID"]?.text) }
                } else { unsafe = true }
            }
            if let seed = b["seedInventory"] {
                many("seedRecord",seed["attachmentRecordIDs"]); many("seedRecord",seed["statusRecordIDs"])
                for selection in seed["selections"]!.items { one("s9Artifact",selection["artifactID"]?.text) }
            }
            if b["stipulated"]?.text == "synthetic" { keys.formUnion(digestInventory(v).keys) }
            return (keys,unsafe)
        }
        /// A still supplies strict/approval diagnostics. Its single-ID lookup cannot resolve
        /// conflicting copies in each parent's digest context, so recompute only these affected
        /// integrity/availability diagnostics, examining every immutable variant independently.
        mutating func variantRepresentation(_ envelope: V, _ entries: [Entry]) {
            var immutable: [String:Data] = [:]
            func remember(_ id: String?, _ v: V) {
                guard let id else { return }; let data = encoded(v)
                if let old = immutable[id], old != data { add(.historyConflict,id) }
                else { immutable[id] = data }
            }
            func missing(_ key: String) {
                let parts = key.split(separator:":",maxSplits:1), kind = parts[0]
                add(kind == "profile" ? .scopeUnavailable : kind == "evidence" ? .correspondenceUnavailable :
                    kind == "s9Artifact" ? .snapshotUnavailable : .historyUnavailable,String(parts[1]))
            }
            func closure(_ v: V, _ locator: String) {
                let declared = digestInventory(v), own = direct(v)
                var reached = Set<String>(), unresolved = own.unsafe
                func follow(_ key: String) {
                    guard reached.insert(key).inserted else { return }
                    let supplied = variants(key)
                    guard !supplied.isEmpty else { unresolved = true; missing(key); return }
                    if declared[key] == nil { missing(key) }
                    guard let doc = resolved(key,digest:declared[key]) else {
                        unresolved = true
                        if declared[key] != nil { add(.historyConflict,String(key.split(separator:":",maxSplits:1)[1])) }
                        return
                    }
                    for (nested,digest) in digestInventory(doc.value) {
                        if let outer = declared[nested], outer != digest { add(.historyConflict,String(nested.split(separator:":",maxSplits:1)[1])) }
                    }
                    let next = direct(doc.value)
                    unresolved = unresolved || next.unsafe
                    for child in next.keys.sorted() { follow(child) }
                }
                for key in own.keys.sorted() { follow(key) }
                for key in reached where declared[key] == nil { missing(key) }
                if !unresolved && !Set(declared.keys).isSubset(of:reached) { add(.historyConflict,locator) }
                for (key,digest) in declared {
                    if variants(key).isEmpty { missing(key) }
                    else if resolved(key,digest:digest) == nil { add(.historyConflict,String(key.split(separator:":",maxSplits:1)[1])) }
                }
            }
            func inspect(_ v: V) {
                guard case .object(let f) = v else { for item in v.items { inspect(item) }; return }
                if f["payloadSHA256"] != nil { remember(f["reviewID"]?.text,v) }
                if f["format"]?.text == "tsugino.synthetic-trip-payload" {
                    remember(f["subjectID"]?.text,v)
                    let field = f["subjectKind"]?.text == "profile" ? "profileID" : "requestID"
                    if let inner = f["payload"]?[field]?.text, inner != f["subjectID"]?.text { add(.historyConflict,f["subjectID"]!.text!) }
                }
                if f["disposition"] != nil { remember(f["evidenceID"]?.text,v) }
                if f["packetBytes"] != nil {
                    remember(f["artifactID"]?.text,v)
                    if let data = bytes(f["packetBytes"]), C.digest(data) != f["packetSHA256"]?.text { add(.historyConflict,f["artifactID"]!.text!) }
                }
                if f["stipulated"] != nil { remember(f["recordID"]?.text,v) }
                if f["recordID"] != nil && f["tripID"] != nil { remember(f["recordID"]?.text,v); remember(f["allocationRequestID"]?.text,v) }
                for (dataKey,digestKey) in [("registryBytes","registrySHA256"),("legacyHistoryBytes","legacyHistorySHA256")] {
                    if let data = bytes(f[dataKey]), let digest = f[digestKey]?.text, C.digest(data) != digest { add(.historyConflict,f["lineageID"]?.text ?? "baseline") }
                }
                if f["legacyHistoryState"]?.text == "present", f["legacyHistoryBytes"] == nil || f["legacyHistorySHA256"] == nil { add(.historyUnavailable,f["lineageID"]?.text ?? "baseline") }
                if f["legacyHistoryState"]?.text == "none", f["legacyHistoryBytes"] != nil || f["legacyHistorySHA256"] != nil { add(.historyConflict,f["lineageID"]?.text ?? "baseline") }
                if let base = f["baseline"], let digest = f["history"]?["baselineSHA256"]?.text, C.digest(encoded(base)) != digest { add(.historyConflict,f["lineageID"]?.text ?? "baseline") }
                if f["dependencyDigests"] != nil {
                    closure(v,f["requestID"]?.text ?? f["profileID"]?.text ?? f["artifactID"]?.text ?? f["recordID"]?.text ?? f["lineageID"]?.text ?? "closure")
                }
                for key in f.keys.sorted() { inspect(f[key]!) }
            }
            inspect(envelope)
            for entry in entries { inspect(entry.document.value) }
        }
        /// A's lookup has one inspection witness per ID. Conflicting variants must not hide
        /// declared/direct cycle edges behind that witness. This is the same ID graph rule,
        /// not evidence applicability or historical membership of an unbound variant.
        mutating func variantCycles(_ entries: [Entry]) {
            guard documents.values.contains(where: { $0.count > 1 }) else { return }
            var graph: [String: Set<String>] = [:]
            for entry in entries {
                let key = entry.kind + ":" + entry.id
                graph[key,default:[]].formUnion(Set(digestInventory(entry.document.value).keys).union(direct(entry.document.value).keys))
            }
            var active = Set<String>(), finished = Set<String>()
            func visit(_ key: String) {
                if active.contains(key) {
                    let parts = key.split(separator:":",maxSplits:1)
                    add(parts[0] == "s9Artifact" ? .snapshotConflict : .historyConflict,String(parts[1])); return
                }
                guard !finished.contains(key), let edges = graph[key] else { return }
                active.insert(key)
                for next in edges.sorted() { visit(next) }
                active.remove(key); finished.insert(key)
            }
            for key in graph.keys.sorted() { visit(key) }
        }
        mutating func approve(_ wrapper: V, _ approvals: [V], fresh: Bool, retainedProfile: Bool = false) {
            let id = wrapper["subjectID"]!.text!
            if approvals.isEmpty { add(.approvalMissing,id) }
            if approvals.count > 1 { add(.approvalConflict,id) }
            for approval in approvals {
                if !equal(approval["subjectKind"],wrapper["subjectKind"]) || !equal(approval["subjectID"],wrapper["subjectID"]) ||
                    approval["payloadSHA256"]?.text != C.digest(encoded(wrapper)) ||
                    !equal(approval["reviewer"],.string(owner)) { add(.approvalConflict,id) }
                if fresh { reserve(approval["reviewID"]!.text!,encoded(approval),retainedProfileApproval:retainedProfile) }
            }
        }
        func checkpoint(_ registry: V, _ registryBytes: Data, _ history: V) -> V {
            .object(["lineageID":.string(lineage),"schemaVersion":registry["schemaVersion"]!,"revision":registry["revision"]!,
                     "registrySHA256":.string(C.digest(registryBytes)),"historySHA256":.string(C.digest(encoded(history)))])
        }
        mutating func inventory(_ baseline: V, _ registry: V) {
            if !equal(baseline["historyComplete"],.bool(true)) { add(.historyUnavailable,"baseline") }
            let inv = baseline["seedInventory"]!
            for id in inv["allocationIDs"]!.items { retain(id.text!,as:.allocation,inventoryOnly:true) }
            for id in inv["reviewIDs"]!.items { retain(id.text!,as:.authority,inventoryOnly:true) }
            let attachments = inv["attachmentRecordIDs"]!.items.compactMap(\.text)
            let statuses = inv["statusRecordIDs"]!.items.compactMap(\.text)
            var records: [String: [V]] = [:], referenced = Set<String>()
            for (kind, ids) in [("attachment",attachments),("status",statuses)] {
                for id in ids {
                    // A declared historical record ID remains occupied when its bytes are missing.
                    // A resolved seed document was already reserved once by the collection pass.
                    retain(id,as:.seedRecord,inventoryOnly:true)
                    let supplied = historicalVariants(.seedRecord,id)
                    guard !supplied.isEmpty else {
                        if documents["seedRecord:" + id] == nil { add(.historyUnavailable,id) }
                        continue
                    }
                    for doc in supplied {
                        let r = doc.value, ref = r["reference"]!, priorID = r["predecessorRecordID"]?.text
                        if r["kind"]?.text != kind { add(.historyConflict,id) }
                        let authority = r["authorityID"]!.text!
                        retain(authority,as:.authority)
                        if let priorID { retain(priorID,as:.seedRecord,inventoryOnly:true) }
                        if !inv["reviewIDs"]!.items.contains(where: { $0.text == authority }) { add(.historyUnavailable,id) }
                        if (priorID == nil) != (r["predecessorRecordSHA256"] == nil) { add(.historyConflict,id) }
                        if r["kind"]?.text == "attachment" {
                            if priorID != nil || !equal(ref["attachedBy"],r["authorityID"]) { add(.historyConflict,id) }
                        } else if priorID == nil { add(.historyUnavailable,id) }
                        if ref["status"]?["state"]?.text == "retired" && !equal(ref["status"]?["review"],r["authorityID"]) { add(.historyConflict,id) }
                    }
                    records[id] = supplied.map(\.value)
                }
            }
            for id in records.keys.sorted() {
              for r in records[id]! {
                let ref = r["reference"]!
                let priorID = r["predecessorRecordID"]?.text
                if let priorID {
                    referenced.insert(priorID)
                    if records[priorID] == nil { add(.historyUnavailable,priorID) }
                    let candidates = historicalVariants(.seedRecord,priorID).map(\.value)
                    if !candidates.isEmpty {
                        guard let prior = candidates.first(where: { C.digest(encoded($0)) == r["predecessorRecordSHA256"]?.text }) else { add(.historyConflict,id); continue }
                        let before = prior["reference"]!
                        if referenceKey(before) != referenceKey(ref) ||
                            ["canonicalID","attachedBy","firstSeenInputSHA256"].contains(where:{ !equal(before[$0],ref[$0]) }) {
                            add(.historyConflict,id)
                        }
                        if before["status"]?["state"]?.text == "retired" && !equal(before,ref) { add(.historyConflict,id) }
                    } else { add(.historyUnavailable,priorID) }
                }
              }
                var active = Set<String>(), finished = Set<String>()
                func visit(_ key: String) {
                    if active.contains(key) { add(.historyConflict,id); return }
                    guard !finished.contains(key), let rows = records[key] else { return }
                    active.insert(key)
                    for prior in Set(rows.compactMap { $0["predecessorRecordID"]?.text }).sorted() { visit(prior) }
                    active.remove(key); finished.insert(key)
                }
                visit(id)
            }
            var terminals = Set<Data>()
            for id in records.keys.sorted() where !referenced.contains(id) {
                for r in records[id]! {
                    let ref = r["reference"]!, key = referenceKey(ref)
                    if !terminals.insert(key).inserted { add(.historyConflict,id) }
                    if !registry["references"]!.items.contains(where:{ equal($0,ref) }) { add(.historyConflict,id) }
                }
            }
            if number(registry["schemaVersion"]) == 4 {
                for ref in registry["references"]!.items where ref["namespace"]?.text == "gtfs.trip_id" {
                    if !terminals.contains(referenceKey(ref)) { add(.historyUnavailable,"baseline") }
                }
            }
            for selection in inv["selections"]!.items {
                let id = selection["artifactID"]!.text!
                retain(id,as:.s9Artifact,inventoryOnly:true)
                if !registry["entities"]!.items.contains(where: {
                    $0["id"]!.text!.hasPrefix("trp_") && equal($0["id"],selection["tripID"])
                }) { add(.historyConflict,id) }
                let artifacts = historicalVariants(.s9Artifact,id)
                guard !artifacts.isEmpty else {
                    if documents["s9Artifact:" + id] == nil { add(.historyUnavailable,id) }
                    continue
                }
                for artifact in artifacts {
                    guard let data = bytes(artifact.value["packetBytes"]), let packet = read(.s9Packet,data,id) else { continue }
                    let run = packet.value["runs"]!.items.first { equal($0["reference"],artifact.value["selectedRunReference"]) }
                    if run == nil || !equal(run?["identity"]?["tripID"],selection["tripID"]) { add(.historyConflict,id) }
                }
            }
        }
        /// Universal preservation rules only; full explanation of Trip deltas is slice C.
        mutating func retained(_ old: V, _ next: V, _ id: String) {
            let entities = next["entities"]!.items
            let oldNonTrip = old["entities"]!.items.filter { !$0["id"]!.text!.hasPrefix("trp_") }
            let nextNonTrip = entities.filter { !$0["id"]!.text!.hasPrefix("trp_") }
            if !equal(.array(oldNonTrip),.array(nextNonTrip)) { add(.historyConflict,id) }
            let oldRefs = old["references"]!.items.filter { $0["namespace"]?.text != "gtfs.trip_id" }
            let nextRefs = next["references"]!.items.filter { $0["namespace"]?.text != "gtfs.trip_id" }
            if !equal(.array(oldRefs),.array(nextRefs)) { add(.historyConflict,id) }
            for entity in old["entities"]!.items {
                if !entities.contains(where:{ equal($0,entity) }) { add(.historyConflict,id) }
            }
            for ref in old["references"]!.items {
                guard let new = next["references"]!.items.first(where:{ referenceKey($0) == referenceKey(ref) }) else { add(.historyConflict,id); continue }
                if ref["namespace"]?.text != "gtfs.trip_id" {
                    if !equal(ref,new) { add(.historyConflict,id) }
                } else if ["canonicalID","attachedBy","firstSeenInputSHA256"].contains(where:{ !equal(ref[$0],new[$0]) }) ||
                    (ref["status"]?["state"]?.text == "retired" && !equal(ref,new)) { add(.historyConflict,id) }
            }
        }
        mutating func delta(_ request: V, _ old: V?, _ next: V?, _ fresh: Bool) {
            let p = request["payload"]!, id = p["requestID"]!.text!, op = p["operation"]!.text!
            if fresh {
                reserve(id,encoded(request))
                for record in p["records"]!.items {
                    reserve(record["recordID"]!.text!,encoded(record))
                    if let allocation = record["allocationRequestID"]?.text { reserve(allocation,encoded(record)) }
                }
            }
            if op != "convertLegacy", !deferred.contains(id) { deferred.append(id) }
            guard let old, let next else { return }
            let rev = number(old["revision"])!
            if rev == Int.max || number(next["revision"]) != rev + 1 { add(.staleCheckpoint,id) }
            if number(next["schemaVersion"]) != 4 { add(.unsupportedVersion,id) }
            if op == "convertLegacy" {
                if ![2,3].contains(number(old["schemaVersion"])!) { add(.unsupportedVersion,id) }
                if !equal(old["entities"],next["entities"]) || !equal(old["references"],next["references"]) { add(.historyConflict,id) }
            } else {
                if number(old["schemaVersion"]) != 4 { add(.blockedOperation,id) }
                retained(old,next,id)
            }
        }
        mutating func run(_ input: Data, _ currentBytes: Data, _ pinBytes: Data) -> SyntheticRegistrationHistoryResult {
            guard let envelope = read(.envelope,input,"envelope") else { return finish(nil) }
            let e = envelope.value
            let pin = read(.checkpoint,pinBytes,"current")
            collect(e)
            var catalogKeys = Set<String>()
            for entry in catalog {
                guard insert(entry.kind,entry.id,entry.document,locator:"catalog") else { continue }
                // The original catalog requires unique keys; identical copies across transports
                // are references, but duplicate entries within that catalog remain invalid.
                if !catalogKeys.insert(entry.kind + ":" + entry.id).inserted { add(.historyConflict,entry.id) }
            }
            var ordered: [Entry] = []
            for key in documents.keys.sorted() {
                let parts = key.split(separator:":",maxSplits:1), kind = String(parts[0]), id = String(parts[1])
                for document in variants(key) {
                    ordered.append(.init(kind:kind,id:id,document:document))
                    reserve(id,document.bytes)
                }
                suppliedDependencies[id,default:[]].insert(RetainedKind(rawValue:kind)!)
            }
            // Every supplied, identity-checked immutable record contributes explicit assertions,
            // including unreferenced catalog copies. Only later retained traversal grants history.
            for entry in ordered { dependencies(declarations(entry.document.value),historical:false) }
            // Prepopulate A deterministically. With conflicting variants, preserve its syntax and
            // approval checks but resolve integrity/availability in each parent's digest context.
            let conflicts = documents.values.contains { $0.count > 1 }
            let contextual: Set<SyntheticRegistrationIssue> = [.historyConflict,.snapshotConflict,.historyUnavailable,
                .scopeUnavailable,.correspondenceUnavailable,.snapshotUnavailable]
            switch SyntheticTripRegistrationClosure.validate(roots:[envelope],catalog:ordered) {
            case .completeRepresentation: break
            case .incomplete(let ds), .invalid(let ds):
                for d in ds where !conflicts || !contextual.contains(d.issue) { add(d.issue,d.locator) }
            }
            if conflicts { variantRepresentation(e,ordered) }
            variantCycles(ordered)
            owner = e["ownerAuthority"]!.text!; lineage = e["lineageID"]!.text!
            let baselineRecord = e["baseline"]!, wrapper = baselineRecord["payload"]!, base = wrapper["payload"]!
            reserve(wrapper["subjectID"]!.text!,encoded(wrapper))
            dependencies(base["dependencyDigests"]!.items,historical:true)
            let history = e["history"]!, boundaries = history["boundaries"]!.items
            if !equal(base["lineageID"],.string(lineage)) || !equal(history["lineageID"],.string(lineage)) { add(.historyConflict,"baseline") }
            let baseBytes = bytes(base["registryBytes"])!, baseline = registry(baseBytes,"baseline")
            approve(wrapper,baselineRecord["approval"].map { [$0] } ?? [],fresh:true)
            if let baseline {
                inventory(base,baseline)
                let version = number(baseline["schemaVersion"])!
                if version == 4 && !baseline["references"]!.items.contains(where: {
                    $0["namespace"]?.text == "gtfs.trip_id" && ["absent","retired"].contains($0["status"]?["state"]?.text ?? "")
                }) { add(.blockedOperation,"baseline") }
                if version == 3 && bytes(base["legacyHistoryBytes"]) == nil { add(.historyUnavailable,"baseline") }
                if let sidecar = bytes(base["legacyHistoryBytes"]) {
                    if version != 3 { add(.historyConflict,"baseline") }
                    else {
                        do {
                            let original = try MappingRegistry.decodedForIdentityTransition(from:baseBytes)
                            for id in try SyntheticTripLegacyHistory.validateRetained(sidecar,current:original) {
                                retain(id,as:.authority)
                            }
                        } catch { add(.historyConflict,"baseline") }
                    }
                }
                // Known baseline authorities remain reserved even with missing inventory/sidecar.
                for ref in baseline["references"]!.items {
                    for id in [ref["attachedBy"]?.text,ref["status"]?["review"]?.text].compactMap({ $0 }) {
                        retain(id,as:.authority)
                    }
                }
            }
            // Examine every wrapper/approval pairing; an identical approval is only introduced once.
            // Historical membership is established from exact baseline-bound variants, not transport.
            let profiles = ordered.filter { $0.kind == "profile" }
            let baselineApprovals = Set(profiles.compactMap { entry -> Data? in
                guard retainedBindings.contains(Binding(kind:.profile,id:entry.id,digest:entry.document.sha256)),
                      let approval = entry.document.value["approval"] else { return nil }
                return encoded(approval)
            })
            var seenProfileApprovals = Set<Data>()
            for entry in profiles {
                let profile = entry.document.value, approvalBytes = profile["approval"].map(encoded)
                let fresh = approvalBytes.map { seenProfileApprovals.insert($0).inserted } ?? false
                approve(profile["payload"]!,profile["approval"].map { [$0] } ?? [],fresh:fresh,
                        retainedProfile:approvalBytes.map { baselineApprovals.contains($0) } ?? false)
            }
            var prefix = replacing(history,"boundaries",.array([]))
            var previousBytes = baseBytes, previous = baseline, priorBoundary: V?
            var retainedRequests: [String: (Int,V)] = [:]
            for (index,boundary) in boundaries.enumerated() {
                guard boundary["request"]?["subjectKind"]?.text == "request" else { add(.malformedInput,"history"); continue }
                let request = boundary["request"]!, p = request["payload"]!, id = p["requestID"]!.text!
                if !equal(p["lineageID"],.string(lineage)) { add(.historyConflict,id) }
                let expectedLink = priorBoundary.map { V.string(C.digest(encoded($0))) }
                if !equal(boundary["previousBoundarySHA256"],expectedLink) || bytes(boundary["previousRegistryBytes"]) != previousBytes ||
                    !equal(boundary["targetRegistryBytes"],p["targetRegistryBytes"]) { add(.historyConflict,id) }
                if let previous, !equal(p["expectedPrevious"],checkpoint(previous,previousBytes,prefix)) { add(.staleCheckpoint,id) }
                checkDependencies(p,boundary["dependencies"]!.items,id)
                dependencies(p["dependencyDigests"]!.items,historical:true)
                approve(request,boundary["approvals"]!.items,fresh:true)
                let targetBytes = bytes(boundary["targetRegistryBytes"])!, target = registry(targetBytes,id)
                delta(request,previous,target,true)
                retainedRequests[id] = (index,boundary)
                prefix = replacing(prefix,"boundaries",.array(Array(boundaries.prefix(index+1))))
                previousBytes = targetBytes; previous = target; priorBoundary = boundary
            }
            let current = registry(currentBytes,"current")
            if currentBytes != previousBytes { add(.staleCheckpoint,"current") }
            if let previous, let pin, !equal(pin.value,checkpoint(previous,previousBytes,history)) { add(.staleCheckpoint,"current") }
            let request = e["request"]!, p = request["payload"]!, id = p["requestID"]!.text!
            dependencies(p["dependencyDigests"]!.items,historical:false)
            if !equal(p["lineageID"],.string(lineage)) { add(.historyConflict,id) }
            var replay = false
            if let (index,boundary) = retainedRequests[id] {
                replay = true
                if !equal(request,boundary["request"]) || !equal(e["approvals"],boundary["approvals"]) { add(.historyConflict,id) }
                if index != boundaries.count-1 { add(.staleCheckpoint,id) }
                // Closure already rejects changed bytes for any retained dependency ID.
                checkDependencies(p,boundary["dependencies"]!.items,id)
                approve(request,e["approvals"]!.items,fresh:false)
            } else {
                if current != nil, let pin, !equal(p["expectedPrevious"],pin.value) { add(.staleCheckpoint,id) }
                approve(request,e["approvals"]!.items,fresh:true)
                delta(request,current,registry(bytes(p["targetRegistryBytes"])!,id),true)
            }
            return finish(.init(replay:replay,conversion:p["operation"]?.text == "convertLegacy",
                                seed:number(baseline?["schemaVersion"]) == 4,deferred:deferred))
        }
        mutating func checkDependencies(_ payload: V, _ retained: [V], _ id: String) {
            let declared = payload["dependencyDigests"]!.items
            for d in declared {
                guard let found = retained.first(where:{ equal($0["kind"],d["kind"]) && equal($0["id"],d["id"]) }) else { add(.historyUnavailable,id); continue }
                if bytes(found["bytes"]).map(C.digest) != d["sha256"]?.text { add(.historyConflict,id) }
            }
            for item in retained where !declared.contains(where:{ equal($0["kind"],item["kind"]) && equal($0["id"],item["id"]) }) { add(.historyConflict,id) }
        }
        func finish(_ report: SyntheticRegistrationHistoryReport?) -> SyntheticRegistrationHistoryResult {
            let sorted = findings.sorted { $0.issue.rawValue == $1.issue.rawValue ? $0.locator.utf8.lexicographicallyPrecedes($1.locator.utf8) : $0.issue.rawValue < $1.issue.rawValue }
            if sorted.contains(where:{ $0.issue.rawValue < SyntheticRegistrationIssue.approvalMissing.rawValue }) { return .rejected(sorted) }
            if !sorted.isEmpty { return .held(sorted) }
            guard let report else { return .rejected([.init(issue:.malformedInput,locator:"envelope")]) }
            return .checked(report)
        }
    }
}
#endif
