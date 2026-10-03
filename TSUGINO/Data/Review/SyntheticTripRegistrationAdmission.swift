#if DEBUG
import Foundation

/// Capability limits for callers deliberately using the identity-only C1 entry point.
nonisolated struct SyntheticRegistrationC1Limit: Equatable, Sendable {
    enum Reason: Equatable, Sendable { case snapshotAdmission, conversionOnly }
    let requestID: String
    let reason: Reason
}
nonisolated enum SyntheticRegistrationC1Result: Sendable {
    case candidate(SyntheticRegistrationC1Candidate)
    case unchangedReplay(SyntheticRegistrationC1Candidate)
    case held([SyntheticRegistrationDiagnostic])
    case rejected([SyntheticRegistrationDiagnostic])
    case outsideC1([SyntheticRegistrationC1Limit], [SyntheticRegistrationDiagnostic])
}

nonisolated enum SyntheticRegistrationResult: Sendable {
    case candidateDelta(SyntheticRegistrationCandidate)
    case unchangedReplay(SyntheticRegistrationCandidate)
    case held([SyntheticRegistrationDiagnostic])
    case rejected([SyntheticRegistrationDiagnostic])
}

/// Complete synthetic business admission only; never registry execution or authentication.
nonisolated struct SyntheticRegistrationCandidate: Sendable {
    let registryBytes: Data
    let historyBytes: Data
    let checkpointBytes: Data
    let recordIDs: [String]
    let stipulatedSeed: Bool
    let selections: [SyntheticRegistrationSelectedSnapshot]
    /// Retained and incoming obligations remain explicit, including on unchanged replay.
    let revalidation: [SyntheticRegistrationRevalidation]
    fileprivate init(_ core: SyntheticRegistrationC1Candidate, _ snapshots: SyntheticTripRegistrationSnapshots) {
        registryBytes = core.registryBytes; historyBytes = core.historyBytes; checkpointBytes = core.checkpointBytes
        recordIDs = core.recordIDs; stipulatedSeed = core.stipulatedSeed
        selections = snapshots.selections.keys.sorted { $0.lexicographicallyPrecedes($1) }.compactMap { snapshots.selections[$0] }
        revalidation = snapshots.obligations
    }
}

/// Supplied-memory, identity-only synthetic output. No authentication, allocation or publication.
/// The private constructor prevents a mechanically checked B report from becoming C1 admission.
nonisolated struct SyntheticRegistrationC1Candidate: Sendable {
    let registryBytes: Data
    let historyBytes: Data
    let checkpointBytes: Data
    let recordIDs: [String]
    /// Admission begins at this stipulated synthetic premise, not verified external lineage.
    let stipulatedSeed: Bool
    fileprivate init(registry: Data, history: Data, checkpoint: Data, records: [String], seed: Bool) {
        registryBytes = registry; historyBytes = history; checkpointBytes = checkpoint
        recordIDs = records; stipulatedSeed = seed
    }
}

nonisolated enum SyntheticTripRegistrationAdmission {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias Entry = SyntheticTripRegistrationClosure.Entry

    static func validateIdentityOnly(envelopeBytes: Data, currentRegistryBytes: Data,
                                    currentCheckpointBytes: Data, catalog: [Entry] = []) -> SyntheticRegistrationC1Result {
        var audit = Audit()
        return audit.run(envelopeBytes,currentRegistryBytes,currentCheckpointBytes,catalog)
    }

    static func validate(envelopeBytes: Data, currentRegistryBytes: Data,
                         currentCheckpointBytes: Data, catalog: [Entry] = []) -> SyntheticRegistrationResult {
        var audit = Audit(includeSnapshots: true)
        let result = audit.run(envelopeBytes,currentRegistryBytes,currentCheckpointBytes,catalog)
        switch result {
        case .candidate(let core):
            guard let snapshots = audit.snapshots else { return .rejected([.init(issue:.malformedInput,locator:"envelope")]) }
            return .candidateDelta(.init(core,snapshots))
        case .unchangedReplay(let core):
            guard let snapshots = audit.snapshots else { return .rejected([.init(issue:.malformedInput,locator:"envelope")]) }
            return .unchangedReplay(.init(core,snapshots))
        case .held(let diagnostics): return .held(diagnostics)
        case .rejected(let diagnostics): return .rejected(diagnostics)
        case .outsideC1(_, let diagnostics): return .held(diagnostics)
        }
    }

    private static func encoded(_ v: V) -> Data { (try? C.encoded(v)) ?? Data() }
    private static func equal(_ a: V?, _ b: V?) -> Bool {
        switch (a,b) { case (nil,nil): true; case let (a?,b?): encoded(a) == encoded(b); default: false }
    }
    private static func blob(_ v: V?) -> Data? { v?.text.flatMap { Data(base64Encoded:$0) } }
    private static func key(_ v: V) -> Data {
        encoded(.array([v["sourceID"]!,v["namespace"]!,v["value"]!]))
    }
    private static func replacing(_ v: V, _ field: String, _ value: V) -> V {
        guard case .object(var fields) = v else { return v }; fields[field] = value; return .object(fields)
    }
    private static func trip(_ id: String) -> Bool {
        let bytes = Array(id.utf8), alphabet = Array("0123456789abcdefghjkmnpqrstvwxyz".utf8)
        return bytes.count == 20 && bytes.prefix(4).elementsEqual("trp_".utf8) && bytes.dropFirst(4).allSatisfy(alphabet.contains)
    }
    private static func registry(_ bytes: Data) -> V? {
        guard !bytes.isEmpty, bytes.count <= C.maximumBytes, !RegistryJSON.repeatsKey(Array(bytes)) else { return nil }
        if let doc = try? C.read(.registry,bytes) { return doc.value }
        guard let legacy = try? MappingRegistry.decodedForIdentityTransition(from:bytes),
              let encoded = try? legacy.encoded() else { return nil }
        return try? JSONDecoder().decode(V.self,from:encoded)
    }

    private struct Audit {
        var includeSnapshots = false
        var snapshots: SyntheticTripRegistrationSnapshots?
        var findings: [SyntheticRegistrationDiagnostic] = []
        var limits: [SyntheticRegistrationC1Limit] = []
        var documents: [String: [SyntheticRegistrationDocument]] = [:]
        var bodies = Set<String>()
        var keys = Set<Data>()
        // Latest complete record for each historically held key, never just a registry row hash.
        var predecessors: [Data: Set<String>] = [:]
        var owner = ""

        mutating func add(_ issue: SyntheticRegistrationIssue, _ id: String) {
            let value = SyntheticRegistrationDiagnostic(issue:issue,locator:id)
            if !findings.contains(value) { findings.append(value) }
        }
        mutating func limit(_ id: String, _ reason: SyntheticRegistrationC1Limit.Reason) {
            guard !includeSnapshots else { return }
            let value = SyntheticRegistrationC1Limit(requestID:id,reason:reason)
            if !limits.contains(value) { limits.append(value) }
        }
        func variants(_ kind: String, _ id: String) -> [SyntheticRegistrationDocument] {
            (documents[kind + ":" + id] ?? []).sorted { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        }
        func resolve(_ kind: String, _ id: String, _ payload: V) -> SyntheticRegistrationDocument? {
            guard let digest = payload["dependencyDigests"]?.items.first(where:{ $0["kind"]?.text == kind && $0["id"]?.text == id })?["sha256"]?.text else { return nil }
            let matching = variants(kind,id).filter { $0.sha256 == digest }
            return matching.count == 1 ? matching[0] : nil
        }
        mutating func insert(_ kind: String, _ id: String, _ doc: SyntheticRegistrationDocument) {
            let v = doc.value
            let matches: Bool
            switch (kind,doc.format) {
            case ("profile",.approved): matches = v["payload"]?["subjectKind"]?.text == "profile" &&
                v["payload"]?["subjectID"]?.text == id && v["payload"]?["payload"]?["profileID"]?.text == id
            case ("evidence",.evidence): matches = v["evidenceID"]?.text == id
            case ("seedRecord",.seedRecord): matches = v["recordID"]?.text == id
            case ("s9Artifact",.s9Artifact): matches = v["artifactID"]?.text == id
            default: matches = false
            }
            guard matches, MappingText.isToken(id) else { return }
            let k = kind + ":" + id
            if documents[k]?.contains(where:{ $0.bytes == doc.bytes }) != true { documents[k,default:[]].append(doc) }
        }
        mutating func collect(_ v: V) {
            guard case .object(let fields) = v else { for child in v.items { collect(child) }; return }
            if let id = fields["evidenceID"]?.text, let doc = try? C.make(.evidence,v) { insert("evidence",id,doc) }
            if fields["payload"]?["subjectKind"]?.text == "profile", let id = fields["payload"]?["subjectID"]?.text,
               let doc = try? C.make(.approved,v) { insert("profile",id,doc) }
            if let id = fields["artifactID"]?.text, let doc = try? C.make(.s9Artifact,v) { insert("s9Artifact",id,doc) }
            if let kind = fields["kind"]?.text, let id = fields["id"]?.text, let bytes = blob(fields["bytes"]) {
                let format: SyntheticRegistrationFormat = kind == "profile" ? .approved : kind == "evidence" ? .evidence : kind == "seedRecord" ? .seedRecord : .s9Artifact
                if let doc = try? C.read(format,bytes) { insert(kind,id,doc) }
            }
            for k in fields.keys.sorted() { collect(fields[k]!) }
        }
        mutating func observe(_ registry: V) {
            for entity in registry["entities"]!.items { bodies.insert(String(entity["id"]!.text!.dropFirst(4))) }
            for ref in registry["references"]!.items { keys.insert(key(ref)) }
        }
        mutating func seed(_ baseline: V, _ registry: V) {
            observe(registry)
            let inventory = baseline["seedInventory"]!
            if !inventory["selections"]!.items.isEmpty || baseline["dependencyDigests"]!.items.contains(where:{ $0["kind"]?.text == "s9Artifact" }) {
                limit("baseline",.snapshotAdmission)
            }
            var records: [SyntheticRegistrationDocument] = []
            for name in ["attachmentRecordIDs","statusRecordIDs"] {
                for id in inventory[name]!.items.compactMap(\.text) {
                    if let doc = resolve("seedRecord",id,baseline) { records.append(doc) }
                }
            }
            // B validates the complete chain and inventory. Only exact bound terminal records
            // can supply a predecessor; unavailable or ambiguous bytes never fabricate one.
            let used = Set(records.compactMap { $0.value["predecessorRecordID"]?.text })
            for doc in records {
                let ref = doc.value["reference"]!
                keys.insert(key(ref)); bodies.insert(String(ref["canonicalID"]!.text!.dropFirst(4)))
                if !used.contains(doc.value["recordID"]!.text!), registry["references"]!.items.contains(where:{ equal($0,ref) }) {
                    predecessors[key(ref),default:[]].insert(doc.sha256)
                }
                if doc.value["dependencyDigests"]!.items.contains(where:{ $0["kind"]?.text == "s9Artifact" }) { limit("baseline",.snapshotAdmission) }
            }
        }
        func approved(_ p: V, _ approvals: [V]) -> Bool {
            guard approvals.count == 1 else { return false }
            let a = approvals[0]
            return equal(a["reviewer"],.string(owner)) && equal(a["subjectID"],p["subjectID"]) &&
                equal(a["subjectKind"],p["subjectKind"]) && a["payloadSHA256"]?.text == C.digest(encoded(p))
        }
        func covers(_ e: V, _ profile: V, _ record: V, _ ref: V, _ inputs: Set<String>) -> Bool {
            // The approved record names the actual key/Trip/record tuple. Empty lists never
            // mean universal coverage. C1 supplies no S9 view, so no view is manufactured here.
            equal(e["profileID"],profile["profileID"]) && equal(e["profileVersion"],profile["version"]) &&
            equal(profile["sourceID"],ref["sourceID"]) && equal(profile["namespace"],ref["namespace"]) &&
            e["referenceKeys"]!.items.contains(where:{ key($0) == key(ref) }) &&
            e["tripIDs"]!.items.contains(where:{ equal($0,record["tripID"]) }) &&
            e["recordIDs"]!.items.contains(where:{ equal($0,record["recordID"]) }) &&
            inputs.isSubset(of:Set(e["inputSHA256s"]!.items.compactMap(\.text)))
        }
        mutating func evidence(_ request: V, _ record: V, _ ref: V, _ before: V?, requestApproved: Bool) {
            let id = record["recordID"]!.text!, input = ref["provenance"]!["inputSHA256"]!.text!
            let currentInputs: Set<String> = [input]
            var continuityInputs = currentInputs
            if let before { continuityInputs.insert(before["provenance"]!["inputSHA256"]!.text!) }
            var matchedProfile = false, complete = false, missingScope = false, missingCorrespondence = false
            for profileID in request["profileIDs"]!.items.compactMap(\.text) {
                guard let doc = resolve("profile",profileID,request) else { continue }
                let p = doc.value["payload"]!["payload"]!
                guard equal(p["sourceID"],ref["sourceID"]), equal(p["namespace"],ref["namespace"]),
                      currentInputs.isSubset(of:Set(p["applicableInputSHA256s"]!.items.compactMap(\.text))) else { continue }
                matchedProfile = true
                // Missing approval is B's approval uncertainty, not evidence of a negative claim.
                // Independent key/target/history conflicts are checked outside this gate.
                guard approved(doc.value["payload"]!,doc.value["approval"].map { [$0] } ?? []) else { continue }
                // Purpose is an approved association too. An unrelated S9-only assertion is
                // not a C1 contradiction merely because some enclosing labels happen to match.
                let purposes: [(V,Set<String>,V)] = [(p["uniquenessEvidenceIDs"]!,currentInputs,p),
                    (p["meaningEvidenceIDs"]!,currentInputs,p),(p["continuityEvidenceIDs"]!,continuityInputs,p),
                    (record["correspondenceEvidenceIDs"]!,continuityInputs,request)]
                var known: [Bool] = []
                for (index,purpose) in purposes.enumerated() {
                    let (ids,inputs,subject) = purpose
                    if index == 3 && !requestApproved { known.append(false); continue }
                    var covered = false
                    for evidenceID in ids.items.compactMap(\.text) {
                        // Only the exact bytes bound by this assertion's approved subject can
                        // establish its disposition. B still diagnoses conflicting/missing copies.
                        guard let e = resolve("evidence",evidenceID,subject), covers(e.value,p,record,ref,inputs) else { continue }
                        if e.value["disposition"]?.text == "contradicts" { add(.referenceConflict,id); covered = true }
                        if e.value["disposition"]?.text == "supports" { covered = true }
                    }
                    known.append(covered)
                }
                // Missing prior-input scope for a return cannot hide a contradiction whose
                // current key/target/input applicability is already explicit.
                let scoped = known.prefix(3).allSatisfy { $0 } &&
                    continuityInputs.isSubset(of:Set(p["applicableInputSHA256s"]!.items.compactMap(\.text)))
                missingScope = missingScope || !scoped
                missingCorrespondence = missingCorrespondence || (requestApproved && !known[3])
                // Purpose comes from the approved lists and operation, not invented role tokens.
                // A known negative is not uncertainty; its rejection was recorded above. With no
                // conflict, completeness necessarily consists of positive support under one profile.
                if requestApproved && scoped && known[3] { complete = true }
            }
            if !complete {
                if !matchedProfile || missingScope { add(.scopeUnavailable,id) }
                if missingCorrespondence || (requestApproved && record["correspondenceEvidenceIDs"]!.items.isEmpty) { add(.correspondenceUnavailable,id) }
            }
        }
        mutating func admit(_ wrapper: V, _ approvals: [V], _ old: V?, _ next: V?) {
            let p = wrapper["payload"]!, id = p["requestID"]!.text!, operation = p["operation"]!.text!
            let records = p["records"]!.items
            if operation == "reviseSnapshot" || records.contains(where:{ $0["snapshotArtifactID"] != nil }) ||
                !p["s9ArtifactIDs"]!.items.isEmpty || p["dependencyDigests"]!.items.contains(where:{ $0["kind"]?.text == "s9Artifact" }) {
                limit(id,.snapshotAdmission)
            }
            // Mechanical conversion does not admit any required S9 dependency. Inspect its
            // capability boundary before skipping conversion-only business checks.
            if operation == "convertLegacy" { return }
            guard operation == "register" || operation == "attach", let old, let next else { return }
            var entities = old["entities"]!.items, references = old["references"]!.items
            let suppliedEntities = next["entities"]!.items, suppliedRefs = next["references"]!.items
            var entityClaims: [String: [String]] = [:], keyClaims: [Data: [String]] = [:]
            for record in records {
                let rid = record["recordID"]!.text!
                if operation == "register" { entityClaims[record["tripID"]!.text!,default:[]].append(rid) }
                let claimed = operation == "register" ? record["referenceKeys"]!.items : [record["key"]!]
                for ref in claimed { keyClaims[key(ref),default:[]].append(rid) }
            }
            for ids in entityClaims.values where ids.count > 1 { for rid in ids { add(.identityConflict,rid) } }
            for ids in keyClaims.values where ids.count > 1 { for rid in ids { add(.referenceConflict,rid) } }
            for record in records {
                let rid = record["recordID"]!.text!, target = record["tripID"]!.text!
                if !trip(target) { add(.identityConflict,rid) }
                if operation == "register" {
                    if bodies.contains(String(target.dropFirst(4))) { add(.identityConflict,rid) }
                    if let supplied = suppliedEntities.first(where:{ equal($0["id"],record["tripID"]) }) {
                        if supplied["state"]?.text != "active" { add(.blockedOperation,rid) }
                        if !entities.contains(where:{ equal($0["id"],supplied["id"]) }) { entities.append(supplied) }
                    } else { add(.identityConflict,rid) }
                } else if !old["entities"]!.items.contains(where:{ equal($0["id"],record["tripID"]) && $0["state"]?.text == "active" }) {
                    add(.identityConflict,rid)
                }
                let claimed = operation == "register" ? record["referenceKeys"]!.items : [record["key"]!]
                if claimed.isEmpty { add(.correspondenceUnavailable,rid) }
                for claim in claimed {
                    let k = key(claim), prior = old["references"]!.items.first(where:{ key($0) == k })
                    let returning = record["mode"]?.text == "returning"
                    if returning {
                        if let prior {
                            if prior["status"]?["state"]?.text != "absent" || !equal(prior["canonicalID"],record["tripID"]) { add(.referenceConflict,rid) }
                        } else { add(.referenceConflict,rid) }
                        if let hashes = predecessors[k], !hashes.isEmpty {
                            if hashes.count != 1 || !hashes.contains(record["previousRecordSHA256"]!.text!) { add(.historyConflict,rid) }
                        } else { add(.historyUnavailable,rid) }
                    } else if keys.contains(k) { add(.referenceConflict,rid) }
                    guard let ref = suppliedRefs.first(where:{ key($0) == k }) else { add(.referenceConflict,rid); continue }
                    if !equal(ref["canonicalID"],record["tripID"]) || ref["status"]?["state"]?.text != "active" { add(.referenceConflict,rid) }
                    if returning, let prior {
                        if ["attachedBy","firstSeenInputSHA256"].contains(where:{ !equal(prior[$0],ref[$0]) }) ||
                            !prior["originalNames"]!.items.allSatisfy({ name in ref["originalNames"]!.items.contains(where:{ equal($0,name) }) }) {
                            add(.referenceConflict,rid)
                        }
                    } else if !returning {
                        if approvals.count == 1 && !equal(ref["attachedBy"],approvals[0]["reviewID"]) { add(.referenceConflict,rid) }
                        if ref["attachedBy"] == nil || !equal(ref["firstSeenInputSHA256"],ref["provenance"]?["inputSHA256"]) { add(.referenceConflict,rid) }
                    }
                    evidence(p,record,ref,returning ? prior : nil,requestApproved:approved(wrapper,approvals))
                    if let index = references.firstIndex(where:{ key($0) == k }) { references[index] = ref }
                    else { references.append(ref) }
                }
            }
            // A record explains only its held/new entity and named reference changes. Everything
            // else, including non-Trip data, old Trip state and unclaimed sightings, stays frozen.
            let expected = replacing(replacing(replacing(old,"revision",next["revision"]!),"entities",.array(entities)),"references",.array(references))
            if let canonical = try? C.make(.registry,expected) {
                if canonical.bytes != (try? C.make(.registry,next).bytes) { add(.historyConflict,id) }
            } else { add(.historyConflict,id) }
            for record in records {
                let claimed = operation == "register" ? record["referenceKeys"]!.items : [record["key"]!]
                for ref in claimed { predecessors[key(ref)] = [C.digest(encoded(record))] }
            }
        }
        mutating func run(_ input: Data, _ current: Data, _ checkpoint: Data, _ catalog: [Entry]) -> SyntheticRegistrationC1Result {
            let mechanical = SyntheticTripRegistrationHistory.validate(envelopeBytes:input,currentRegistryBytes:current,currentCheckpointBytes:checkpoint,catalog:catalog)
            var checked: SyntheticRegistrationHistoryReport?
            switch mechanical {
            case .checked(let report): checked = report
            case .held(let ds), .rejected(let ds): findings = ds
            }
            guard let envelope = try? C.read(.envelope,input) else { return finish(nil,false) }
            let e = envelope.value, base = e["baseline"]!["payload"]!["payload"]!
            // The baseline fixes the authority; an inconsistent envelope label cannot grant
            // approval or suppress a contradiction under the retained authority.
            owner = base["ownerAuthority"]!.text!
            collect(e)
            for entry in catalog { insert(entry.kind,entry.id,entry.document) }
            if includeSnapshots {
                snapshots = .init(reconstruction:.init(documents:documents,owner:owner))
                snapshots?.reconstruction.authorize(e["baseline"]!["payload"]!, approvals:e["baseline"]!["approval"].map { [$0] } ?? [])
                for b in e["history"]!["boundaries"]!.items {
                    snapshots?.reconstruction.authorize(b["request"]!, approvals:b["approvals"]!.items)
                }
                snapshots?.reconstruction.authorize(e["request"]!, approvals:e["approvals"]!.items)
                snapshots?.baseline(base)
            }
            let baseline = blob(base["registryBytes"]).flatMap(registry)
            if let baseline { seed(base,baseline) }
            let h = e["history"]!, boundaries = h["boundaries"]!.items
            for boundary in boundaries {
                let request = boundary["request"]!
                guard request["subjectKind"]?.text == "request" else { continue }
                let old = blob(boundary["previousRegistryBytes"]).flatMap(registry)
                let next = blob(boundary["targetRegistryBytes"]).flatMap(registry)
                if let old { observe(old) }
                admit(request,boundary["approvals"]!.items,old,next)
                snapshots?.inspect(request,approvals:boundary["approvals"]!.items,old:old,next:next)
                if let next { observe(next) }
            }
            let request = e["request"]!, p = request["payload"]!, requestID = p["requestID"]!.text!
            // A retained replay is admitted above. Altered reuse still receives its own safe checks.
            let identicalReplay = boundaries.contains { equal($0["request"],request) && equal($0["approvals"],e["approvals"]) }
            if !identicalReplay {
                if let current = registry(current) { observe(current) }
                admit(request,e["approvals"]!.items,registry(current),blob(p["targetRegistryBytes"]).flatMap(registry))
                snapshots?.inspect(request,approvals:e["approvals"]!.items,old:registry(current),next:blob(p["targetRegistryBytes"]).flatMap(registry))
            }
            for d in snapshots?.reconstruction.diagnostics ?? [] { add(d.issue,d.locator) }
            if p["operation"]?.text == "convertLegacy" { limit(requestID,.conversionOnly) }
            guard checked != nil, findings.isEmpty, limits.isEmpty else { return finish(nil,false) }
            do {
                let replay = checked!.unchangedReplay
                let target = replay ? current : blob(p["targetRegistryBytes"])!
                var history = h
                if !replay {
                    let dependencies = try p["dependencyDigests"]!.items.map { d -> V in
                        guard let doc = resolve(d["kind"]!.text!,d["id"]!.text!,p) else { throw SyntheticRegistrationIssue.historyUnavailable }
                        return .object(["kind":d["kind"]!,"id":d["id"]!,"bytes":.string(doc.bytes.base64EncodedString())])
                    }
                    var fields: [String: V] = ["previousRegistryBytes":.string(current.base64EncodedString()),"targetRegistryBytes":p["targetRegistryBytes"]!,
                        "request":request,"approvals":e["approvals"]!,"dependencies":.array(dependencies)]
                    if let last = boundaries.last { fields["previousBoundarySHA256"] = .string(C.digest(encoded(last))) }
                    history = replacing(h,"boundaries",.array(boundaries + [.object(fields)]))
                }
                let historyBytes = try C.make(.history,history).bytes, r = try C.read(.registry,target).value
                let pin: V = .object(["lineageID":e["lineageID"]!,"schemaVersion":r["schemaVersion"]!,"revision":r["revision"]!,
                    "registrySHA256":.string(C.digest(target)),"historySHA256":.string(C.digest(historyBytes))])
                let candidate = SyntheticRegistrationC1Candidate(registry:target,history:historyBytes,checkpoint:try C.make(.checkpoint,pin).bytes,
                    records:p["records"]!.items.compactMap { $0["recordID"]?.text },seed:checked!.stipulatedSeed)
                return finish(candidate,replay)
            } catch let issue as SyntheticRegistrationIssue { add(issue,requestID) }
            catch { add(.malformedInput,requestID) }
            return finish(nil,false)
        }
        func finish(_ candidate: SyntheticRegistrationC1Candidate?, _ replay: Bool) -> SyntheticRegistrationC1Result {
            let sorted = findings.sorted { $0.issue.rawValue == $1.issue.rawValue ? $0.locator.utf8.lexicographicallyPrecedes($1.locator.utf8) : $0.issue.rawValue < $1.issue.rawValue }
            if sorted.contains(where:{ $0.issue.rawValue < SyntheticRegistrationIssue.approvalMissing.rawValue }) { return .rejected(sorted) }
            if !limits.isEmpty { return .outsideC1(limits.sorted { $0.requestID.utf8.lexicographicallyPrecedes($1.requestID.utf8) },sorted) }
            if !sorted.isEmpty { return .held(sorted) }
            guard let candidate else { return .rejected([.init(issue:.malformedInput,locator:"envelope")]) }
            return replay ? .unchangedReplay(candidate) : .candidate(candidate)
        }
    }
}
#endif
