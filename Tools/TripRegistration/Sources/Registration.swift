import Foundation

// Real offline formats, never synthetic tags or runtime schema admission.
enum Registration {
    static let requestFormat = "tsugino.trip-registry-registration-request"
    static let contextFormat = "tsugino.trip-registry-registration-context"
    static let manifestFormat = "tsugino.trip-registry-registration-bundle"
    static let operation = "registerFirstTrip"
    static let workflowFields = ["requestID","recordID","allocationID","approvalReviewID","operationID","workspaceID","outputID"]
    struct Inputs {
        let registry: Data, history: Data, manifest: Data, context: Wire, correspondence: Data, dependencies: Wire
    }
    struct Eligible {
        let input: Inputs, history: Wire, correspondence: Wire, held: Set<String>, inventorySHA: String
    }
    static func read(_ bytes: Data, limit: Int) throws -> Wire {
        guard !bytes.isEmpty, bytes.count <= limit else { throw ConversionFailure.resourceLimit }
        try RegistrationSyntax.scan(bytes)
        return try Codec.read(bytes,limit:limit)
    }
    static func checkContext(_ c: Wire) throws {
        try Codec.tagged(c,contextFormat)
        try Codec.fields(c,["format","schemaVersion","ownerAuthority","expectedPrevious","predecessorManifestSHA256","workflow","correspondenceContext","correspondence","profileAcceptance","applicability","provenance","provenanceEvidenceID","dependencyDigests","scope"])
        try Codec.token(c["ownerAuthority"]); try Conversion.checkPin(c["expectedPrevious"]); try Codec.sha(c["predecessorManifestSHA256"])
        guard c["expectedPrevious"]["schemaVersion"].int == 4 else { throw ConversionFailure.staleCheckpoint }
        try Codec.fields(c["workflow"],workflowFields)
        for k in workflowFields { try Codec.token(c["workflow"][k]) }
        guard Set(workflowFields.map { c["workflow"][$0].text }).count == workflowFields.count else { throw ConversionFailure.identityConflict }
        let cc = try Correspondence.context(c["correspondenceContext"])
        guard cc["ownerAuthority"].text == c["ownerAuthority"].text else { throw ConversionFailure.approvalConflict }
        let co = c["correspondence"]
        try Codec.fields(co,["requestID","proposalSHA256","approvedContentSHA256","recordSHA256"]); try Correspondence.token(co["requestID"])
        for k in ["proposalSHA256","approvedContentSHA256","recordSHA256"] { try Codec.sha(co[k]) }
        let pa = c["profileAcceptance"]
        try Codec.fields(pa,["profileID","version","disposition"])
        guard Codec.equal(pa["profileID"],cc["source"]["profileID"]), Codec.equal(pa["version"],cc["source"]["profileVersion"]), pa["disposition"].text == "accepted" else { throw ConversionFailure.scopeConflict }
        let ap = c["applicability"]
        try Codec.fields(ap,["evidenceID","sha256","disposition"]); try Codec.token(ap["evidenceID"]); try Codec.sha(ap["sha256"])
        let ae = cc["evidence"].list.first { $0["role"].text == "candidateApplicability" }!
        guard Codec.equal(ap["evidenceID"],ae["evidenceID"]), Codec.equal(ap["sha256"],ae["sha256"]), ap["disposition"].text == "eligible" else { throw ConversionFailure.scopeConflict }
        try Codec.token(c["provenanceEvidenceID"])
        let p = c["provenance"], s = cc["source"]
        try Codec.fields(p,["inputSHA256","member","table","field","providerKey"])
        try Codec.fields(p["member"],["name","sha256"]); try Codec.sha(p["member"]["sha256"])
        guard Codec.equal(p["inputSHA256"],s["inputSHA256"]), Codec.equal(p["providerKey"],s["key"]), p["member"]["name"].text == "trips.txt",
              p["table"].text == "trips", p["field"].text == "trip_id", c["scope"].text == "identityOnlyOneTripOneReference" else { throw ConversionFailure.scopeConflict }
        let pins = try Conversion.dependencies(c["dependencyDigests"])
        for row in cc["evidence"].list { guard pins[row["evidenceID"].text] == row["sha256"].text else { throw ConversionFailure.historyConflict } }
        guard pins[cc["mapping"]["version"].text] == cc["mapping"]["sha256"].text, pins[c["provenanceEvidenceID"].text] != nil else { throw ConversionFailure.historyUnavailable }
        guard try Codec.encode(c).count <= Correspondence.limit else { throw ConversionFailure.resourceLimit }
    }
    // Full supplied byte closure; opaque authority is never parsed to invent IDs.
    static func dependencies(_ rows: Wire, context c: Wire) throws {
        try Codec.array(rows,max:Limits.records)
        try Codec.ordered(rows.list.map { Data($0["id"].text.utf8) })
        let pins = try Conversion.dependencies(c["dependencyDigests"])
        var index: [String:Wire] = [:], total = 0, missing = false
        for r in rows.list {
            try Codec.fields(r,["id","sha256","dependencyDigests"],["bytes"])
            try Codec.token(r["id"]); try Codec.sha(r["sha256"])
            guard pins[r["id"].text] == r["sha256"].text else { throw ConversionFailure.historyConflict }
            _ = try Conversion.dependencies(r["dependencyDigests"])
            if r.has("bytes") {
                try Codec.bytes(r["bytes"],limit:Limits.record)
                total += r["bytes"].blob.count
                guard total <= Limits.history else { throw ConversionFailure.resourceLimit }
                guard Codec.hash(r["bytes"].blob) == r["sha256"].text else { throw ConversionFailure.historyConflict }
            } else { missing = true }
            index[r["id"].text] = r
        }
        for id in pins.keys where index[id] == nil { missing = true }
        var visited = Set<String>(), active = Set<String>()
        for start in index.keys.sorted() {
            var stack: [(String,Bool)] = [(start,false)]
            while let (id,exit) = stack.popLast() {
                if exit { active.remove(id); visited.insert(id); continue }
                if active.contains(id) { throw ConversionFailure.historyConflict }
                if visited.contains(id) { continue }
                guard let row = index[id] else { missing = true; continue }
                active.insert(id); stack.append((id,true))
                for (child,sha) in try Conversion.dependencies(row["dependencyDigests"]).sorted(by:{$0.key < $1.key}) {
                    guard pins[child] == sha else { throw ConversionFailure.historyConflict }; stack.append((child,false))
                }
            }
        }
        // No unreferenced catalog that might conceal another authority assertion.
        var reachable = Set<String>(), pending = c["correspondenceContext"]["evidence"].list.map { $0["evidenceID"].text }
        pending += [c["correspondenceContext"]["mapping"]["version"].text,c["provenanceEvidenceID"].text]
        while let id = pending.popLast() {
            if !reachable.insert(id).inserted { continue }
            if let r = index[id] { pending += r["dependencyDigests"].list.map { $0["id"].text } }
        }
        guard Set(pins.keys) == reachable else { throw ConversionFailure.historyConflict }
        if missing { throw ConversionFailure.historyUnavailable }
    }
    static func heldInventory(_ h: Wire) throws -> Set<String> {
        var ids = Set(h["baseline"]["payload"]["heldIdentifiers"].list.map(\.text))
        var registries = [h["baseline"]["payload"]["registryBytes"].blob]
        for b in h["boundaries"].list { registries += [b["previousRegistryBytes"].blob,b["targetRegistryBytes"].blob] }
        for bytes in registries {
            let r = try Codec.read(bytes,limit:Limits.registry,canonical:false)
            ids.formUnion(r["entities"].list.map { $0["id"].text })
        }
        var bodyOwners: [String:String] = [:]
        for id in ids {
            _ = try Registry4.kind(.string(id)); let body = String(id.dropFirst(4))
            if let old = bodyOwners[body], old != id { throw ConversionFailure.identityConflict }; bodyOwners[body] = id
        }
        return Set(bodyOwners.keys)
    }
    static func keyCheck(_ r: Wire, source s: Wire) throws {
        for ref in r["references"].list {
            if Codec.equal(ref["sourceID"],s["sourceID"]), Codec.equal(ref["namespace"],s["namespace"]), Codec.equal(ref["value"],s["key"]) {
                if ref["status"]["state"].text == "absent", ref["canonicalID"].text.hasPrefix("trp_") { throw ConversionFailure.continuityUnavailable }
                throw ConversionFailure.referenceConflict
            }
        }
    }
    static func retainedAssociations(_ rows: Wire, correspondence: Data, correspondenceID: String, retained: [Wire], oldIDs: Set<String>) throws {
        for row in rows.list {
            if oldIDs.contains(row["id"].text) {
                // A catalog handle cannot become a historical business/review/allocation token.
                guard let old = retained.first(where: { Codec.equal($0["id"],row["id"]) }) else { throw ConversionFailure.identityConflict }
                guard Codec.equal(old["sha256"],row["sha256"]), old["bytes"].blob == row["bytes"].blob,
                      Codec.equal(old["dependencyDigests"],row["dependencyDigests"]) else { throw ConversionFailure.historyConflict }
            }
            if row["id"].text == correspondenceID {
                guard row["sha256"].text == Codec.hash(correspondence), row["bytes"].blob == correspondence else { throw ConversionFailure.identityConflict }
            }
        }
        if oldIDs.contains(correspondenceID) {
            // Existing correspondence is quoted business authority, not necessarily fresh.
            // Resolve its original handle/explicit coverage without mining opaque record bytes.
            let originals = retained.filter {
                $0["id"].text == correspondenceID || ($0["allocationIDs"].list + $0["reviewIDs"].list).contains { $0.text == correspondenceID }
            }
            guard originals.contains(where: { $0["sha256"].text == Codec.hash(correspondence) && $0["bytes"].blob == correspondence }) else { throw ConversionFailure.identityConflict }
        }
    }
    static func eligible(_ i: Inputs) throws -> Eligible {
        try checkContext(i.context); let c = i.context, owner = c["ownerAuthority"].text
        guard try Codec.encode(i.dependencies).count <= Limits.request else { throw ConversionFailure.resourceLimit }
        let r = try Registry4.read(i.registry)
        try keyCheck(r,source:c["correspondenceContext"]["source"])
        // A retained registration consumes correspondence even if caller changes operation IDs.
        if let h = try? read(i.history,limit:Limits.history), h["schemaVersion"].int == 2 {
            _ = try verify(i.registry,i.history,i.manifest,owner:owner)
            let old = h["boundaries"].list[0]["request"]["context"]["correspondence"], next = c["correspondence"]
            if Codec.equal(old["requestID"],next["requestID"]) || Codec.equal(old["approvedContentSHA256"],next["approvedContentSHA256"]) { throw ConversionFailure.correspondenceConflict }
            throw ConversionFailure.staleCheckpoint
        }
        let bundle = try Conversion.verify(i.registry,i.history,i.manifest,owner:owner)
        guard Codec.hash(bundle.manifest) == c["predecessorManifestSHA256"].text else { throw ConversionFailure.staleCheckpoint }
        let (h,ids) = try Conversion.context(i.registry,history:i.history,current:c["expectedPrevious"],owner:owner)
        guard h["boundaries"].list.count == 1 else { throw ConversionFailure.historyConflict }
        guard !r["entities"].list.contains(where:{$0["id"].text.hasPrefix("trp_")}) else { throw ConversionFailure.identityConflict }
        let cc = c["correspondenceContext"], legacy = h["baseline"]["payload"]
        guard cc["baseline"]["schemaVersion"].int == 2, cc["baseline"]["revision"].int == legacy["revision"].int,
              Codec.equal(cc["baseline"]["registrySHA256"],legacy["registrySHA256"]), Codec.equal(cc["baseline"]["lineageID"],h["lineageID"]),
              Codec.equal(c["expectedPrevious"]["lineageID"],h["lineageID"]) else { throw ConversionFailure.staleCheckpoint }
        let co = try Correspondence.read(i.correspondence,context:cc), expected = c["correspondence"]
        guard Codec.hash(i.correspondence) == expected["recordSHA256"].text, Codec.equal(co["payload"]["requestID"],expected["requestID"]),
              Codec.equal(co["approval"]["proposalSHA256"],expected["proposalSHA256"]), Codec.equal(co["approval"]["approvedContentSHA256"],expected["approvedContentSHA256"]) else { throw ConversionFailure.correspondenceConflict }
        try dependencies(i.dependencies,context:c)
        let retained = h["baseline"]["payload"]["records"].list
        try retainedAssociations(i.dependencies,correspondence:i.correspondence,correspondenceID:expected["requestID"].text,retained:retained,oldIDs:ids)
        var reserved = ids
        // Existing authority associations may be quoted; new workflow IDs may not reuse them.
        reserved.formUnion(cc["evidence"].list.map { $0["evidenceID"].text }); reserved.insert(expected["requestID"].text)
        reserved.formUnion(c["dependencyDigests"].list.map { $0["id"].text })
        for k in workflowFields { guard !reserved.contains(c["workflow"][k].text) else { throw ConversionFailure.identityConflict } }
        // Existing retained handles quoted by new closure must have exactly the same bytes/pins.
        var uniqueBytes: [String:Int] = [:]
        for row in retained + i.dependencies.list { uniqueBytes[row["sha256"].text] = row["bytes"].blob.count }
        uniqueBytes[Codec.hash(i.correspondence)] = i.correspondence.count
        guard uniqueBytes.values.reduce(0,+) <= Limits.history else { throw ConversionFailure.resourceLimit }
        let held = try heldInventory(h)
        let sha = try Codec.digest(.array(held.sorted().map(Wire.string)))
        return .init(input:i,history:h,correspondence:co,held:held,inventorySHA:sha)
    }
    static func reference(_ c: Wire, tripID: String) -> Wire {
        let s = c["correspondenceContext"]["source"]
        return .object(["canonicalID":.string(tripID),"sourceID":s["sourceID"],"namespace":.string("gtfs.trip_id"),"value":s["key"],
            "status":.object(["state":.string("active")]),"firstSeenInputSHA256":s["inputSHA256"],"provenance":c["provenance"],"originalNames":.array([]),"attachedBy":c["workflow"]["approvalReviewID"]])
    }
    static func target(_ registry: Data, context c: Wire, tripID: String) throws -> Data {
        var r = try Registry4.read(registry)
        guard try Registry4.kind(.string(tripID)) == "trp", r["revision"].int < Int.max else { throw ConversionFailure.resourceLimit }
        let e: Wire = .object(["id":.string(tripID),"state":.string("active")])
        let es = (r["entities"].list + [e]).sorted { $0["id"].text < $1["id"].text }
        let refs = (r["references"].list + [reference(c,tripID:tripID)]).sorted(by:Registry4.less)
        r = r.replacing("revision",.integer(r["revision"].int + 1)).replacing("entities",.array(es)).replacing("references",.array(refs))
        try Registry4.validate(r); let bytes = try Codec.encode(r,pretty:true)
        guard bytes.count <= Limits.registry else { throw ConversionFailure.resourceLimit }; return bytes
    }
    static func request(_ e: Eligible, draw: TripMinting.Draw) throws -> Wire {
        let i = e.input, c = i.context, t = try target(i.registry,context:c,tripID:draw.id)
        guard (1...8).contains(draw.attempts), !e.held.contains(String(draw.id.dropFirst(4))) else { throw ConversionFailure.identityConflict }
        let q: Wire = .object(["format":.string(requestFormat),"schemaVersion":.integer(1),"operation":.string(operation),"requestID":c["workflow"]["requestID"],
            "lineageID":c["expectedPrevious"]["lineageID"],"ownerAuthority":c["ownerAuthority"],"expectedPrevious":c["expectedPrevious"],"context":c,
            "proposedTripID":.string(draw.id),"targetRegistryBytes":Codec.blob(t),"targetRegistrySHA256":.string(Codec.hash(t)),"reference":reference(c,tripID:draw.id),
            "correspondenceBytes":Codec.blob(i.correspondence),"dependencies":i.dependencies,
            "preparation":.object(["algorithm":.string("osCSPRNG80Crockford-v1"),"drawCount":.integer(draw.attempts),"heldBodyInventorySHA256":.string(e.inventorySHA)])])
        try checkRequest(q); return q
    }
    static func checkRequest(_ q: Wire) throws {
        try Codec.tagged(q,requestFormat)
        try Codec.fields(q,["format","schemaVersion","operation","requestID","lineageID","ownerAuthority","expectedPrevious","context","proposedTripID","targetRegistryBytes","targetRegistrySHA256","reference","correspondenceBytes","dependencies","preparation"])
        let c = q["context"]; try checkContext(c)
        guard q["operation"].text == operation, Codec.equal(q["requestID"],c["workflow"]["requestID"]), Codec.equal(q["ownerAuthority"],c["ownerAuthority"]),
              Codec.equal(q["expectedPrevious"],c["expectedPrevious"]), Codec.equal(q["lineageID"],q["expectedPrevious"]["lineageID"]), try Registry4.kind(q["proposedTripID"]) == "trp" else { throw ConversionFailure.identityConflict }
        try Codec.bytes(q["targetRegistryBytes"],limit:Limits.registry); try Codec.sha(q["targetRegistrySHA256"])
        guard Codec.hash(q["targetRegistryBytes"].blob) == q["targetRegistrySHA256"].text else { throw ConversionFailure.historyConflict }
        _ = try Registry4.read(q["targetRegistryBytes"].blob)
        guard Codec.equal(q["reference"],reference(c,tripID:q["proposedTripID"].text)) else { throw ConversionFailure.referenceConflict }
        try Registry4.reference(q["reference"])
        try Codec.bytes(q["correspondenceBytes"],limit:Correspondence.limit)
        let co = try Correspondence.read(q["correspondenceBytes"].blob,context:c["correspondenceContext"])
        let pins = c["correspondence"]
        guard Codec.hash(q["correspondenceBytes"].blob) == pins["recordSHA256"].text, Codec.equal(co["payload"]["requestID"],pins["requestID"]),
              Codec.equal(co["approval"]["proposalSHA256"],pins["proposalSHA256"]), Codec.equal(co["approval"]["approvedContentSHA256"],pins["approvedContentSHA256"]) else { throw ConversionFailure.correspondenceConflict }
        try dependencies(q["dependencies"],context:c)
        try Codec.fields(q["preparation"],["algorithm","drawCount","heldBodyInventorySHA256"])
        try Codec.sha(q["preparation"]["heldBodyInventorySHA256"])
        guard q["preparation"]["algorithm"].text == "osCSPRNG80Crockford-v1", (1...8).contains(q["preparation"]["drawCount"].int) else { throw ConversionFailure.malformedInput }
        guard try Codec.encode(q).count <= Limits.request else { throw ConversionFailure.resourceLimit }
    }
    static func validate(_ q: Wire, input i: Inputs) throws {
        try checkRequest(q)
        guard Codec.equal(q["context"],i.context), q["correspondenceBytes"].blob == i.correspondence, Codec.equal(q["dependencies"],i.dependencies) else { throw ConversionFailure.scopeConflict }
        let e = try eligible(i)
        guard !e.held.contains(String(q["proposedTripID"].text.dropFirst(4))), q["preparation"]["heldBodyInventorySHA256"].text == e.inventorySHA,
              q["targetRegistryBytes"].blob == (try target(i.registry,context:i.context,tripID:q["proposedTripID"].text)) else { throw ConversionFailure.identityConflict }
    }
    static func approval(_ q: Wire, reviewID: String, author: String, at: String, reference: String) throws -> Wire {
        try checkRequest(q)
        guard reviewID == q["context"]["workflow"]["approvalReviewID"].text else { throw ConversionFailure.approvalConflict }
        return try Conversion.approval(q,owner:q["ownerAuthority"].text,reviewID:reviewID,author:author,at:at,reference:reference)
    }
    static func checkApproval(_ a: Wire, _ q: Wire) throws {
        try Conversion.checkApproval(a,q,owner:q["ownerAuthority"].text)
        guard Codec.equal(a["reviewID"],q["context"]["workflow"]["approvalReviewID"]) else { throw ConversionFailure.approvalConflict }
    }
    // Calculate with a fixed-width placeholder without drawing. Include a maximum-sized
    // approval and base64 expansion. Publication itself checks every actual byte limit again.
    static func preflight(_ e: Eligible) throws {
        let i = e.input, t = try target(i.registry,context:i.context,tripID:"trp_zzzzzzzzzzzzzzzz")
        let sizing = Eligible(input:i,history:e.history,correspondence:e.correspondence,held:[],inventorySHA:e.inventorySHA)
        let q = try request(sizing,draw:.init(id:"trp_zzzzzzzzzzzzzzzz",attempts:8))
        let qb = try Codec.encode(q)
        try preflightSizes(previousRegistry:i.registry.count,targetRegistry:t.count,history:i.history.count,request:qb.count)
    }
    static func preflightSizes(previousRegistry: Int, targetRegistry: Int, history: Int, request: Int) throws {
        func base64(_ n: Int) throws -> Int {
            guard n >= 0, n <= Limits.history else { throw ConversionFailure.resourceLimit }
            return ((n + 2) / 3) * 4
        }
        guard previousRegistry <= Limits.registry, targetRegistry <= Limits.registry, request <= Limits.request else { throw ConversionFailure.resourceLimit }
        let h = try base64(history) + base64(previousRegistry) + base64(targetRegistry) + request + Limits.approval + 12288
        guard h <= Limits.history, targetRegistry + h + 8192 <= Limits.bundle else { throw ConversionFailure.resourceLimit }
    }
}
