#if DEBUG
import Foundation

nonisolated enum SyntheticRegistrationSnapshotValues {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    static func bytes(_ v: V) -> Data { (try? C.encoded(v)) ?? Data() }
    static func equal(_ a: V?, _ b: V?) -> Bool {
        switch (a,b) { case (nil,nil): true; case let (a?,b?): bytes(a) == bytes(b); default: false }
    }
    static func blob(_ v: V?) -> Data? { v?.text.flatMap { Data(base64Encoded: $0) } }
    static func replacing(_ v: V, _ name: String, _ value: V) -> V {
        guard case .object(var fields) = v else { return v }; fields[name] = value; return .object(fields)
    }
    static func subset(_ a: [V], _ b: [V]) -> Bool { a.allSatisfy { item in b.contains { equal(item,$0) } } }
}

/// Complete packet replay, never a public-field candidate factory. Supplied bytes only.
nonisolated struct SyntheticTripRegistrationReconstruction {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias X = SyntheticRegistrationSnapshotValues
    struct Reconstructed: Sendable {
        let artifact: SyntheticRegistrationDocument
        let packet: SyntheticTripRegistrationS9Codec.DeferredPacket
        let candidate: SyntheticTripReviewCandidate
    }
    let documents: [String: [SyntheticRegistrationDocument]]
    let owner: String
    var diagnostics: [SyntheticRegistrationDiagnostic] = []
    private var authorizedEvidence: [String: V] = [:]
    private var active = Set<String>()
    private var finished = Set<String>()
    private var results: [String: Reconstructed] = [:]

    mutating func add(_ issue: SyntheticRegistrationIssue, _ id: String) {
        let d = SyntheticRegistrationDiagnostic(issue: issue, locator: id)
        if !diagnostics.contains(d) { diagnostics.append(d) }
    }
    func variants(_ kind: String, _ id: String) -> [SyntheticRegistrationDocument] {
        (documents[kind + ":" + id] ?? []).sorted { $0.bytes.lexicographicallyPrecedes($1.bytes) }
    }
    mutating func resolve(_ kind: String, _ id: String, in payload: V) -> SyntheticRegistrationDocument? {
        let issue: SyntheticRegistrationIssue = kind == "s9Artifact" ? .snapshotUnavailable : kind == "profile" ? .scopeUnavailable : .correspondenceUnavailable
        guard let digest = payload["dependencyDigests"]?.items.first(where: { $0["kind"]?.text == kind && $0["id"]?.text == id })?["sha256"]?.text else {
            add(issue,id); return nil
        }
        let copies = variants(kind,id)
        guard let found = copies.first(where: { $0.sha256 == digest }) else {
            add(copies.isEmpty ? issue : .historyConflict,id); return nil
        }
        return found
    }
    func approved(_ wrapper: V, _ approvals: [V]) -> Bool {
        guard approvals.count == 1 else { return false }
        let a = approvals[0]
        return X.equal(a["reviewer"],.string(owner)) && a["role"]?.text == "owner" &&
            X.equal(a["subjectKind"],wrapper["subjectKind"]) && X.equal(a["subjectID"],wrapper["subjectID"]) &&
            a["payloadSHA256"]?.text == C.digest(X.bytes(wrapper))
    }
    /// Authority comes from exact approved closures, never incidental catalog contents.
    /// Collect before replay so a competing bound assertion cannot disappear by visit order.
    mutating func authorize(_ wrapper: V, approvals: [V]) {
        guard approved(wrapper,approvals) else { return }
        for d in wrapper["payload"]!["dependencyDigests"]!.items where d["kind"]?.text == "evidence" {
            if let doc = variants("evidence",d["id"]!.text!).first(where: { $0.sha256 == d["sha256"]?.text }) {
                authorizedEvidence[doc.sha256] = doc.value
            }
        }
    }
    mutating func profile(_ id: String, in payload: V) -> V? {
        guard let doc = resolve("profile",id,in:payload) else { return nil }
        let wrapper = doc.value["payload"]!
        guard wrapper["subjectKind"]?.text == "profile", wrapper["subjectID"]?.text == id,
              wrapper["payload"]?["profileID"]?.text == id else { add(.historyConflict,id); return nil }
        guard let approval = doc.value["approval"] else { add(.approvalMissing,id); return nil }
        guard approved(wrapper,[approval]) else { add(.approvalConflict,id); return nil }
        return wrapper["payload"]!
    }
    /// Only exact bound dependency copies can establish a claim. Conflicting copies remain B errors.
    mutating func evidence(in payload: V) -> [V] {
        payload["dependencyDigests"]!.items.filter { $0["kind"]?.text == "evidence" }.compactMap {
            resolve("evidence",$0["id"]!.text!,in:payload)?.value
        }
    }
    mutating func required(in payload: V) {
        for d in payload["dependencyDigests"]!.items where d["kind"]?.text == "s9Artifact" {
            _ = reconstruct(d["id"]!.text!,in:payload)
        }
    }
    mutating func reconstruct(_ id: String, in payload: V) -> Reconstructed? {
        guard let doc = resolve("s9Artifact",id,in:payload) else { return nil }
        if active.contains(id) { add(.snapshotConflict,id); return nil }
        if finished.contains(doc.sha256) { return results[doc.sha256] }
        active.insert(id)
        defer { active.remove(id); finished.insert(doc.sha256) }
        let start = diagnostics.count
        let a = doc.value
        guard let bytes = X.blob(a["packetBytes"]), C.digest(bytes) == a["packetSHA256"]?.text,
              let deferred = try? SyntheticTripRegistrationS9Codec.decode(bytes),
              let wire = try? C.read(.s9Packet,bytes).value else { add(.snapshotConflict,id); return nil }
        var blocked = false
        var runs: [SyntheticTripReviewRun] = []
        for run in deferred.packet.runs {
            var prior: SyntheticTripReviewCandidate?
            if let previous = deferred.predecessors[run.reference] {
                prior = reconstruct(previous,in:a)?.candidate
                if prior == nil { blocked = true }
                if let prior, case .reviewed(let target, _) = run.identity,
                   !prior.trip.id.rawValue.utf8.elementsEqual(target.rawValue.utf8) { add(.snapshotConflict,id); blocked = true }
            }
            runs.append(.init(reference:run.reference,view:run.view,positions:run.positions,first:run.first,last:run.last,
                intervalEvidence:run.intervalEvidence,identity:run.identity,continuityEvidence:run.continuityEvidence,
                origin:run.origin,destination:run.destination,movements:run.movements,prior:prior))
        }
        // A missing predecessor never becomes a fake prior. Nil permits independent local
        // checks only; blocked prevents any resulting candidate from escaping.
        let packet = SyntheticTripReviewPacket(view:deferred.packet.view,evidenceReferences:deferred.packet.evidenceReferences,runs:runs)
        let associationOK = associations(a,wire)
        var candidates: [UUID: SyntheticTripReviewCandidate] = [:]
        switch SyntheticTripReviewValidator.validate(packet) {
        case .invalidPacket: add(.snapshotConflict,id); blocked = true
        case .reviewed(let records):
            for record in records {
                switch record.outcome {
                case .candidate(let candidate): candidates[record.reference] = candidate
                case .held: add(.correspondenceUnavailable,id); blocked = true
                case .rejected(let issues):
                    add(.snapshotConflict,id); blocked = true
                    if issues.contains(where: { [.unknownClassification,.identityUnresolved,.coverageEvidenceMissing,.registrationRequired].contains($0.reason) }) ||
                        runs.first(where: { $0.reference == record.reference }).map({ mappingUncertainty($0,issues) }) == true {
                        add(.correspondenceUnavailable,id)
                    }
                }
            }
        }
        guard let selected = UUID(uuidString:a["selectedRunReference"]!.text!), deferred.packet.runs.contains(where: { $0.reference == selected }) else {
            add(.snapshotConflict,id); return nil
        }
        guard !blocked, associationOK, diagnostics.count == start, let candidate = candidates[selected] else { return nil }
        let result = Reconstructed(artifact:doc,packet:deferred,candidate:candidate)
        results[doc.sha256] = result
        return result
    }

    /// DEC-082's mapping reason includes both impossibility and unavailability. Preserve
    /// a hold only at a diagnosed occurrence with an actually missing mapping/proof.
    private func mappingUncertainty(_ run: SyntheticTripReviewRun, _ issues: [SyntheticTripReviewDiagnostic]) -> Bool {
        let locations = Set(issues.filter { $0.reason == .mappingUnavailable }.flatMap(\.locations))
        for p in run.positions where locations.contains(p.reference) {
            if case .passenger(let mapping, _) = p.classification {
                switch mapping { case .unavailable, .resolved(_, _, nil): return true; default: break }
            }
        }
        for m in run.movements where locations.contains(m.from) {
            switch m.line { case .unavailable, .resolved(_, nil): return true; default: break }
        }
        return false
    }

    private struct Use {
        let run: V
        let role: String
        let proof: V
        let fields: [String: V]
    }
    /// Normalize only contiguous identical movement proof/line uses, matching DEC-082 storage.
    private func uses(_ wire: V) -> [Use] {
        var result: [Use] = []
        for run in wire["runs"]!.items {
            func append(_ role: String, _ proof: V?, _ fields: [String: V] = [:]) {
                if let proof { result.append(.init(run:run,role:role,proof:proof,fields:fields)) }
            }
            let span = ["from":run["first"]!,"to":run["last"]!]
            append("interval",run["intervalEvidence"],span); append("continuity",run["continuityEvidence"],span)
            append("identity",run["identity"]?["evidence"])
            append("origin",run["origin"]?["evidence"],["occurrence":run["first"]!])
            append("destination",run["destination"]?["evidence"],["occurrence":run["last"]!])
            for p in run["positions"]!.items {
                append("classification",p["classification"]?["evidence"],["occurrence":p["reference"]!])
                append("mapping",p["classification"]?["mapping"]?["evidence"],["occurrence":p["reference"]!])
            }
            var movement: [V] = [], canJoin = false
            for m in run["movements"]!.items {
                guard m["line"]?["tag"]?.text == "resolved", m["line"]?["evidence"] != nil else { canJoin = false; continue }
                if canJoin, let last = movement.last, X.equal(last["to"],m["from"]), X.equal(last["line"],m["line"]) {
                    movement[movement.count-1] = X.replacing(last,"to",m["to"]!)
                } else { movement.append(m) }
                canJoin = true
            }
            for m in movement { append("movement",m["line"]?["evidence"],["from":m["from"]!,"to":m["to"]!,"lineID":m["line"]!["lineID"]!]) }
        }
        return result
    }
    private func structural(_ binding: V, _ use: Use) -> Bool {
        guard X.equal(binding["runReference"],use.run["reference"]), binding["role"]?.text == use.role,
              X.equal(binding["proofUUID"],use.proof), let scope = binding["scope"] else { return false }
        if let trip = use.run["identity"]?["tripID"], !X.equal(scope["tripID"],trip) { return false }
        guard X.equal(scope["view"],use.run["view"]) else { return false }
        for field in ["occurrence","from","to","lineID"] { if !X.equal(scope[field],use.fields[field]) { return false } }
        return true
    }
    private func encloses(_ e: V, _ p: V, _ scope: V, artifact: String) -> Bool {
        let keys = scope["referenceKeys"]!.items
        return !keys.isEmpty && !e["inputSHA256s"]!.items.isEmpty &&
            X.equal(e["profileID"],scope["profileID"]) && X.equal(e["profileVersion"],scope["profileVersion"]) &&
            X.equal(p["profileID"],scope["profileID"]) && X.equal(p["version"],scope["profileVersion"]) &&
            X.equal(p["sourceID"],scope["sourceID"]) && X.equal(e["view"],scope["view"]) &&
            e["tripIDs"]!.items.contains(where: { X.equal($0,scope["tripID"]) }) &&
            e["artifactIDs"]!.items.contains(where: { $0.text == artifact }) &&
            X.subset(keys,e["referenceKeys"]!.items) && X.subset(e["inputSHA256s"]!.items,p["applicableInputSHA256s"]!.items) &&
            keys.allSatisfy { X.equal($0["sourceID"],p["sourceID"]) && X.equal($0["namespace"],p["namespace"]) }
    }
    mutating func admitScopeProfile(_ p: V, scope: V, artifact: String) -> Bool {
        var valid = true
        for purpose in ["uniquenessEvidenceIDs","meaningEvidenceIDs","continuityEvidenceIDs"] {
            var known = false, support = false
            for id in p[purpose]!.items.compactMap(\.text) {
                guard let e = resolve("evidence",id,in:p)?.value, encloses(e,p,scope,artifact:artifact) else { continue }
                if e["disposition"]?.text == "contradicts" { add(.snapshotConflict,artifact); known = true; valid = false }
                if e["disposition"]?.text == "supports" { known = true; support = true }
            }
            if !known { add(.scopeUnavailable,artifact); valid = false }
            if !support { valid = false }
        }
        return valid
    }
    /// A competing claim supplies its own exact scope; a missing chosen binding cannot
    /// erase it. Resolve only the profile bytes explicitly bound by this artifact.
    private func approvedProfileIfAvailable(_ id: String, in payload: V) -> V? {
        guard let digest = payload["dependencyDigests"]?.items.first(where: { $0["kind"]?.text == "profile" && $0["id"]?.text == id })?["sha256"]?.text,
              let doc = variants("profile",id).first(where: { $0.sha256 == digest }),
              let wrapper = doc.value["payload"], wrapper["subjectKind"]?.text == "profile",
              wrapper["subjectID"]?.text == id, wrapper["payload"]?["profileID"]?.text == id,
              let approval = doc.value["approval"], approved(wrapper,[approval]) else { return nil }
        return wrapper["payload"]
    }
    private struct Claim {
        let role: String
        let run: V
        let scope: V
        let profile: V
        let disposition: String
        let inputs: [V]
    }
    private func proofClaims(_ artifact: V, _ wire: V) -> [Claim] {
        let actual = uses(wire), id = artifact["artifactID"]!.text!
        var claims: [Claim] = []
        for digest in authorizedEvidence.keys.sorted() {
            let e = authorizedEvidence[digest]!
            for claim in e["applicability"]!.items {
                let scope = claim["scope"]!
                guard let use = actual.first(where: { use in
                    structural(.object(["runReference":claim["runReference"]!,"role":claim["role"]!,
                        "scope":scope,"proofUUID":use.proof]),use)
                }), let profile = approvedProfileIfAvailable(scope["profileID"]!.text!,in:artifact),
                      encloses(e,profile,scope,artifact:id) else { continue }
                claims.append(.init(role:use.role,run:use.run,scope:scope,profile:profile,disposition:e["disposition"]!.text!,inputs:e["inputSHA256s"]!.items))
            }
        }
        return claims
    }
    /// Explicit, approved selected-run key/Trip assertions in any proof role. No inference from a station/name or
    /// mere binding-table label, and no requirement that an unbound source key be registered.
    struct SourceClaim {
        let scope: V
        let inputs: [V]
    }
    func selectedSourceClaims(_ artifact: V, _ wire: V) -> [SourceClaim] {
        proofClaims(artifact,wire).filter {
            $0.disposition == "supports" &&
                $0.run["identity"]?["tag"]?.text == "reviewed" &&
                X.equal($0.run["reference"],artifact["selectedRunReference"])
        }.map { SourceClaim(scope:$0.scope,inputs:$0.inputs) }
    }
    private mutating func independentClaims(_ artifact: V, _ wire: V) -> Bool {
        let id = artifact["artifactID"]!.text!
        var valid = true
        for claim in proofClaims(artifact,wire) {
            if !admitScopeProfile(claim.profile,scope:claim.scope,artifact:id) { valid = false }
            if claim.disposition == "contradicts" { add(.snapshotConflict,id); valid = false }
        }
        for digest in authorizedEvidence.keys.sorted() {
            let e = authorizedEvidence[digest]!
            guard e["disposition"]?.text == "contradicts", X.equal(e["view"],wire["view"]),
                  e["artifactIDs"]!.items.contains(where: { $0.text == id }),
                  let p = approvedProfileIfAvailable(e["profileID"]!.text!,in:artifact),
                  X.equal(e["profileVersion"],p["version"]) else { continue }
            for claim in e["viewApplicability"]!.items {
                guard let component = claim["component"]?.text,
                      X.equal(claim["revisionUUID"],wire["view"]?[component]),
                      X.equal(claim["profileID"],p["profileID"]), X.equal(claim["profileVersion"],p["version"]),
                      !claim["inputSHA256s"]!.items.isEmpty,
                      X.subset(claim["inputSHA256s"]!.items,e["inputSHA256s"]!.items),
                      X.subset(claim["inputSHA256s"]!.items,p["applicableInputSHA256s"]!.items) else { continue }
                add(.snapshotConflict,id); valid = false
            }
        }
        return valid
    }
    private mutating func associations(_ a: V, _ wire: V) -> Bool {
        let id = a["artifactID"]!.text!, actual = uses(wire)
        _ = evidence(in:a) // Still report absent explicitly required records.
        let available = authorizedEvidence.keys.sorted().compactMap { authorizedEvidence[$0] }
        var valid = independentClaims(a,wire)
        // Extra/misbound entries are structural inconsistencies, not merely missing support.
        for binding in a["proofBindings"]!.items where !actual.contains(where: { structural(binding,$0) }) {
            add(.snapshotConflict,id); valid = false
        }
        for use in actual {
            let bound = a["proofBindings"]!.items.filter { structural($0,use) }
            if bound.isEmpty { add(.correspondenceUnavailable,id); valid = false; continue }
            if bound.count != 1 { add(.snapshotConflict,id); valid = false }
            for binding in bound {
                let scope = binding["scope"]!
                guard let p = profile(scope["profileID"]!.text!,in:a) else { valid = false; continue }
                if !X.equal(p["version"],scope["profileVersion"]) || !X.equal(p["sourceID"],scope["sourceID"]) {
                    add(.snapshotConflict,id); valid = false; continue
                }
                if !admitScopeProfile(p,scope:scope,artifact:id) { valid = false }
                let claim: V = .object(["runReference":use.run["reference"]!,"role":.string(use.role),"scope":scope])
                var selectedSupport = false, selectedKnown = false
                for e in available where e["applicability"]!.items.contains(where: { X.equal($0,claim) }) && encloses(e,p,scope,artifact:id) {
                    if e["disposition"]?.text == "contradicts" { add(.snapshotConflict,id); valid = false }
                    if X.equal(e["evidenceID"],binding["evidenceID"]) {
                        selectedKnown = e["disposition"]?.text != "unresolved"
                        selectedSupport = e["disposition"]?.text == "supports"
                    }
                }
                if !selectedKnown { add(.correspondenceUnavailable,id); valid = false }
                if !selectedSupport { valid = false }
            }
        }
        for component in SyntheticRegistrationSchema.components {
            let bindings = a["viewBindings"]!.items.filter { $0["component"]?.text == component }
            if bindings.isEmpty { add(.scopeUnavailable,id); valid = false; continue }
            if bindings.count != 1 { add(.snapshotConflict,id); valid = false }
            for binding in bindings {
                guard X.equal(binding["revisionUUID"],wire["view"]?[component]) else { add(.snapshotConflict,id); valid = false; continue }
                guard let p = profile(binding["profileID"]!.text!,in:a) else { valid = false; continue }
                if !X.equal(binding["profileVersion"],p["version"]) { add(.snapshotConflict,id); valid = false; continue }
                var selectedKnown = false, selectedSupport = false
                for e in available where X.equal(e["profileID"],binding["profileID"]) && X.equal(e["profileVersion"],binding["profileVersion"]) &&
                    X.equal(e["view"],wire["view"]) && e["artifactIDs"]!.items.contains(where: { $0.text == id }) {
                    let claims = e["viewApplicability"]!.items.filter { claim in
                        ["component","revisionUUID","profileID","profileVersion"].allSatisfy { X.equal(claim[$0],binding[$0]) } &&
                            !claim["inputSHA256s"]!.items.isEmpty && X.subset(claim["inputSHA256s"]!.items,e["inputSHA256s"]!.items) &&
                            X.subset(claim["inputSHA256s"]!.items,p["applicableInputSHA256s"]!.items)
                    }
                    if claims.isEmpty { continue }
                    if e["disposition"]?.text == "contradicts" { add(.snapshotConflict,id); valid = false }
                    if X.equal(e["evidenceID"],binding["evidenceID"]) {
                        selectedKnown = e["disposition"]?.text != "unresolved"
                        selectedSupport = e["disposition"]?.text == "supports"
                    }
                }
                if !selectedKnown { add(.scopeUnavailable,id); valid = false }
                if !selectedSupport { valid = false }
            }
        }
        return valid
    }
}
#endif
