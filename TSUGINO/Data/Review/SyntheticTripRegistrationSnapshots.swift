#if DEBUG
import Foundation

nonisolated enum SyntheticRegistrationDownstreamUse: String, CaseIterable, Sendable {
    case datedTimetableFacts, originalIndexAssociations, rideContexts, continuityEligibility, dataViewBindings
}
nonisolated struct SyntheticRegistrationRevalidation: Sendable {
    enum Reason: String, Sendable { case initialSelection, snapshotViewOrEvidenceChanged, referenceBindingChanged }
    let recordID: String
    let tripID: String
    let previousArtifactID: String?
    let artifactID: String
    let reason: Reason
    let uses: [SyntheticRegistrationDownstreamUse]
}
nonisolated struct SyntheticRegistrationSelectedSnapshot: Sendable {
    let tripID: String
    let artifactID: String
    let candidate: SyntheticTripReviewCandidate
}

/// Selection state is derived from immutable history. No stored flags or consumer rebinding.
nonisolated struct SyntheticTripRegistrationSnapshots {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias X = SyntheticRegistrationSnapshotValues
    var reconstruction: SyntheticTripRegistrationReconstruction
    var selections: [Data: SyntheticRegistrationSelectedSnapshot] = [:]
    var selectedIDs: [Data: String] = [:]
    var obligations: [SyntheticRegistrationRevalidation] = []
    var completeHistory = false
    private var heldBindings: [Data: Set<Data>] = [:]
    private var selectedScopes: [Data: [V]] = [:]
    // Historical assertions retain their exact enclosing source/view/profile and input scope.
    // They are evidence, not implicit attachments or permanent key reservations.
    private var historicalClaims: [SyntheticTripRegistrationReconstruction.SourceClaim] = []

    mutating func baseline(_ payload: V) {
        if case .bool(true) = payload["historyComplete"] { completeHistory = true }
        if let bytes = X.blob(payload["registryBytes"]), let registry = try? C.read(.registry,bytes).value { observeBindings(registry) }
        reconstruction.required(in:payload)
        for item in payload["seedInventory"]!["selections"]!.items {
            let target = item["tripID"]!.text!, id = item["artifactID"]!.text!
            selectedIDs[Data(target.utf8)] = id
            if let doc = reconstruction.resolve("s9Artifact",id,in:payload), let bytes = X.blob(doc.value["packetBytes"]),
               let wire = try? C.read(.s9Packet,bytes).value {
                let claims = reconstruction.selectedSourceClaims(doc.value,wire)
                historicalClaims += claims
                let scopes = claims.map(\.scope)
                selectedScopes[Data(target.utf8)] = scopes
                reconcileBindings(scopes,locator:id)
            }
            if let r = reconstruction.reconstruct(id,in:payload) {
                if r.candidate.trip.id.rawValue.utf8.elementsEqual(target.utf8) {
                    selections[Data(target.utf8)] = .init(tripID:target,artifactID:id,candidate:r.candidate)
                } else { reconstruction.add(.snapshotConflict,id) }
            }
        }
    }
    mutating func inspect(_ wrapper: V, approvals: [V], old: V?, next: V?) {
        if let old { observeBindings(old) }; if let next { observeBindings(next) }
        let p = wrapper["payload"]!, qid = p["requestID"]!.text!, operation = p["operation"]!.text!
        // A later new-key attachment/registration must not contradict an already selected
        // run merely because this request carries no new snapshot record.
        for scopes in selectedScopes.values { reconcileBindings(scopes,locator:qid) }
        if let old { reconcileHistoricalClaims(old,locator:qid) }
        if let next { reconcileHistoricalClaims(next,locator:qid) }
        reconstruction.required(in:p)
        // Required conversion artifacts are reconstructed too, but conversion grants no selection.
        if operation == "convertLegacy" { return }
        let records = p["records"]!.items
        var claims: [Data: [String]] = [:]
        for r in records where operation == "reviseSnapshot" || r["snapshotArtifactID"] != nil {
            claims[Data(r["tripID"]!.text!.utf8),default:[]].append(r["recordID"]!.text!)
        }
        for ids in claims.values where ids.count > 1 { for id in ids { reconstruction.add(.snapshotConflict,id) } }
        if operation == "reviseSnapshot", let old, let next {
            if !X.equal(old["entities"],next["entities"]) || !X.equal(old["references"],next["references"]) {
                reconstruction.add(.historyConflict,qid)
            }
        }
        for record in records {
            let rid = record["recordID"]!.text!, trip = record["tripID"]!.text!, key = Data(trip.utf8)
            guard let artifact = (operation == "reviseSnapshot" ? record["nextArtifactID"] : record["snapshotArtifactID"])?.text else {
                if operation == "attach", let current = selections[key] {
                    obligations.append(.init(recordID:rid,tripID:trip,previousArtifactID:current.artifactID,
                        artifactID:current.artifactID,reason:.referenceBindingChanged,uses:SyntheticRegistrationDownstreamUse.allCases))
                }
                continue
            }
            let retained = selections[key]
            let retainedID = selectedIDs[key]
            let mode = record["mode"]?.text ?? "registration"
            if operation == "reviseSnapshot" {
                if !trip.hasPrefix("trp_") || old?["entities"]?.items.contains(where: { X.equal($0["id"],record["tripID"]) && $0["state"]?.text == "active" }) != true {
                    reconstruction.add(.identityConflict,rid)
                }
                if !completeHistory { reconstruction.add(.historyUnavailable,rid) }
                if mode == "initialSelection", retainedID != nil { reconstruction.add(.snapshotConflict,rid) }
                if mode == "revision" {
                    if let retainedID {
                        if record["previousArtifactID"]?.text != retainedID { reconstruction.add(.snapshotConflict,rid) }
                    } else if completeHistory { reconstruction.add(.snapshotConflict,rid) }
                    if let previous = record["previousArtifactID"]?.text { _ = reconstruction.reconstruct(previous,in:p) }
                }
            }
            // Inspect safe selected-run associations even when reconstruction is held elsewhere.
            let doc = reconstruction.resolve("s9Artifact",artifact,in:p)
            var selectedRun: V?
            if let doc, let bytes = X.blob(doc.value["packetBytes"]),
               let wire = try? C.read(.s9Packet,bytes).value {
                let claims = reconstruction.selectedSourceClaims(doc.value,wire)
                historicalClaims += claims
                let scopes = claims.map(\.scope)
                selectedScopes[key] = scopes
                reconcileBindings(scopes,locator:rid)
                selectedRun = wire["runs"]!.items.first { X.equal($0["reference"],doc.value["selectedRunReference"]) }
                if let selectedRun {
                    if let target = selectedRun["identity"]?["tripID"], !X.equal(target,record["tripID"]) { reconstruction.add(.snapshotConflict,rid) }
                    if mode == "initialSelection", selectedRun["priorArtifactID"] != nil { reconstruction.add(.snapshotConflict,rid) }
                    if mode == "revision", !X.equal(selectedRun["priorArtifactID"],record["previousArtifactID"]) { reconstruction.add(.snapshotConflict,rid) }
                } else { reconstruction.add(.snapshotConflict,rid) }
            }
            if let selectedRun, let doc {
                correspondence(wrapper,approvals,record,artifact:doc.value,run:selectedRun,registry:next ?? old)
            }
            selectedIDs[key] = artifact
            guard let result = reconstruction.reconstruct(artifact,in:p) else { continue }
            if !result.candidate.trip.id.rawValue.utf8.elementsEqual(trip.utf8) { reconstruction.add(.snapshotConflict,rid); continue }
            selections[key] = .init(tripID:trip,artifactID:artifact,candidate:result.candidate)
            var changed = retained == nil
            if let retained {
                changed = !retained.candidate.matches(view:result.candidate.view,trip:result.candidate.trip) ||
                    !sameCrosswalk(retained.candidate.crosswalk,result.candidate.crosswalk)
                // Enclosing approval, applicability and evidence changes matter even at equal TripID.
                if let oldArtifact = reconstruction.resolve("s9Artifact",retained.artifactID,in:p) {
                    for field in ["proofBindings","viewBindings"] where !X.equal(oldArtifact.value[field],result.artifact.value[field]) { changed = true }
                    let oldProofs = oldArtifact.value["dependencyDigests"]!.items.filter { ["profile","evidence"].contains($0["kind"]!.text!) }
                    let newProofs = result.artifact.value["dependencyDigests"]!.items.filter { ["profile","evidence"].contains($0["kind"]!.text!) }
                    if !X.equal(.array(oldProofs),.array(newProofs)) { changed = true }
                } else { changed = true }
            }
            if changed {
                obligations.append(.init(recordID:rid,tripID:trip,previousArtifactID:retained?.artifactID,artifactID:artifact,
                    reason:retained == nil ? .initialSelection : .snapshotViewOrEvidenceChanged,uses:SyntheticRegistrationDownstreamUse.allCases))
            }
        }
    }
    private func referenceKey(_ key: V) -> Data {
        X.bytes(.array([key["sourceID"]!,key["namespace"]!,key["value"]!]))
    }
    private mutating func observeBindings(_ registry: V) {
        for ref in registry["references"]!.items {
            heldBindings[referenceKey(ref),default:[]].insert(Data(ref["canonicalID"]!.text!.utf8))
        }
    }
    private mutating func reconcileBindings(_ scopes: [V], locator: String) {
        for scope in scopes {
            let target = Data(scope["tripID"]!.text!.utf8)
            for key in scope["referenceKeys"]!.items {
                if heldBindings[referenceKey(key)]?.contains(where: { $0 != target }) == true {
                    reconstruction.add(.referenceConflict,locator)
                }
            }
        }
    }
    private mutating func reconcileHistoricalClaims(_ registry: V, locator: String) {
        for claim in historicalClaims {
            for ref in registry["references"]!.items {
                guard claim.scope["referenceKeys"]!.items.contains(where: { referenceKey($0) == referenceKey(ref) }),
                      claim.inputs.contains(where: {
                          X.equal($0,ref["provenance"]?["inputSHA256"]) || X.equal($0,ref["firstSeenInputSHA256"])
                      }) else { continue }
                if !X.equal(claim.scope["tripID"],ref["canonicalID"]) { reconstruction.add(.referenceConflict,locator) }
            }
        }
    }
    private func sameCrosswalk(_ a: [SyntheticTripCrosswalkEntry], _ b: [SyntheticTripCrosswalkEntry]) -> Bool {
        a.count == b.count && zip(a,b).allSatisfy { $0.sourceOccurrence == $1.sourceOccurrence && $0.sourceOrder == $1.sourceOrder && $0.originalIndex == $1.originalIndex }
    }
    private mutating func correspondence(_ wrapper: V, _ approvals: [V], _ r: V, artifact: V, run: V, registry: V?) {
        // A missing or inconsistent owner approval cannot turn a claimed negative into authority.
        guard reconstruction.approved(wrapper,approvals) else { return }
        let p = wrapper["payload"]!, rid = r["recordID"]!.text!, id = artifact["artifactID"]!.text!
        let refs = registry?["references"]?.items.filter { X.equal($0["canonicalID"],r["tripID"]) && $0["status"]?["state"]?.text != "retired" } ?? []
        var supported = false, knownNegative = false
        for eid in r["correspondenceEvidenceIDs"]!.items.compactMap(\.text) {
            guard let e = reconstruction.resolve("evidence",eid,in:p)?.value,
                  let profile = reconstruction.profile(e["profileID"]!.text!,in:p) else { continue }
            let matches = X.equal(profile["version"],e["profileVersion"]) && X.equal(e["view"],run["view"]) &&
                e["tripIDs"]!.items.contains(where: { X.equal($0,r["tripID"]) }) && e["recordIDs"]!.items.contains(where: { $0.text == rid }) &&
                e["artifactIDs"]!.items.contains(where: { $0.text == id }) &&
                (r["previousArtifactID"] == nil || e["artifactIDs"]!.items.contains(where: { X.equal($0,r["previousArtifactID"]) })) &&
                !e["inputSHA256s"]!.items.isEmpty && X.subset(e["inputSHA256s"]!.items,profile["applicableInputSHA256s"]!.items) &&
                refs.contains(where: { ref in
                    X.equal(profile["sourceID"],ref["sourceID"]) && X.equal(profile["namespace"],ref["namespace"]) &&
                    e["inputSHA256s"]!.items.contains(where: { X.equal($0,ref["provenance"]?["inputSHA256"]) }) &&
                    e["referenceKeys"]!.items.contains { k in ["sourceID","namespace","value"].allSatisfy { X.equal(k[$0],ref[$0]) } }
                })
            if !matches { continue }
            let applicableKeys = e["referenceKeys"]!.items.filter { key in
                refs.contains { ref in ["sourceID","namespace","value"].allSatisfy { X.equal(key[$0],ref[$0]) } }
            }
            let scope: V = .object(["tripID":r["tripID"]!,"profileID":profile["profileID"]!,"profileVersion":profile["version"]!,
                "sourceID":profile["sourceID"]!,"referenceKeys":.array(applicableKeys),"view":run["view"]!])
            let completeProfile = reconstruction.admitScopeProfile(profile,scope:scope,artifact:id)
            if e["disposition"]?.text == "contradicts" { knownNegative = true; reconstruction.add(.snapshotConflict,rid) }
            if completeProfile && e["disposition"]?.text == "supports" { supported = true }
        }
        if !supported && !knownNegative { reconstruction.add(.correspondenceUnavailable,rid) }
    }
}
#endif
