import Foundation

enum Conversion {
    static let baselineFormat = "tsugino.trip-registry-baseline"
    static let historyFormat = "tsugino.trip-registry-history"
    static let requestFormat = "tsugino.trip-registry-conversion-request"
    static let approvalFormat = "tsugino.trip-registry-approval"
    static let manifestFormat = "tsugino.trip-registry-conversion-bundle"

    struct Bundle {
        let registry: Data, history: Data, manifest: Data
        let replay: Bool
        var files: [String: Data] { ["registry.json":registry, "history.json":history, "manifest.json":manifest] }
    }
    static func checkPin(_ p: Wire) throws {
        try Codec.fields(p, ["lineageID","schemaVersion","revision","registrySHA256","historySHA256"])
        try Codec.token(p["lineageID"]); try Codec.version(p, [2,4])
        guard p["revision"].int >= 0 else { throw ConversionFailure.malformedInput }
        try Codec.sha(p["registrySHA256"]); try Codec.sha(p["historySHA256"])
    }
    static func pin(_ registry: Data, _ history: Data, lineage: String) throws -> Wire {
        let r = try Codec.read(registry, limit: Limits.registry, canonical: false)
        return .object(["lineageID":.string(lineage), "schemaVersion":r["schemaVersion"], "revision":r["revision"],
                        "registrySHA256":.string(Codec.hash(registry)), "historySHA256":.string(Codec.hash(history))])
    }
    static func approval(_ payload: Wire, owner: String, reviewID: String, author: String, at: String, reference: String) throws -> Wire {
        let a: Wire = .object(["format":.string(approvalFormat), "schemaVersion":.integer(1), "reviewID":.string(reviewID),
            "author":.string(author), "reviewer":.string(owner), "role":.string("owner"), "approvedAt":.string(at),
            "subjectFormat":payload["format"], "subjectID":payload.has("baselineID") ? payload["baselineID"] : payload["requestID"],
            "payloadSHA256":.string(try Codec.digest(payload)), "approvalReference":.string(reference)])
        try checkApproval(a, payload, owner:owner); return a
    }
    static func checkApproval(_ a: Wire, _ payload: Wire, owner: String) throws {
        if case .null = a { throw ConversionFailure.approvalMissing }
        try Codec.tagged(a, approvalFormat)
        try Codec.fields(a, ["format","schemaVersion","reviewID","author","reviewer","role","approvedAt","subjectFormat","subjectID","payloadSHA256","approvalReference"])
        for k in ["reviewID","author","reviewer","subjectID","approvalReference"] { try Codec.token(a[k]) }
        try Codec.timestamp(a["approvedAt"]); try Codec.sha(a["payloadSHA256"])
        guard a["reviewer"].text == owner, a["role"].text == "owner", Codec.equal(a["subjectFormat"],payload["format"]),
              Codec.equal(a["subjectID"],payload.has("baselineID") ? payload["baselineID"] : payload["requestID"]),
              a["payloadSHA256"].text == (try Codec.digest(payload)) else { throw ConversionFailure.approvalConflict }
    }
    static func dependencies(_ v: Wire) throws -> [String: String] {
        try Codec.array(v, max: Limits.records)
        var d: [String: String] = [:]
        try Codec.ordered(v.list.map { Data($0["id"].text.utf8) })
        for row in v.list {
            try Codec.fields(row, ["id","sha256"]); try Codec.token(row["id"]); try Codec.sha(row["sha256"])
            d[row["id"].text] = row["sha256"].text
        }
        return d
    }
    // The complete inventory is an explicit owner assertion, not discovery or person authentication.
    // Opaque ORIGINAL authority bytes are retained; old approvals are never translated/re-authored.
    static func baseline(_ b: Wire, owner: String) throws -> Set<String> {
        let (ids,missing) = try baselineReport(b,owner:owner)
        if missing { throw ConversionFailure.historyUnavailable }
        return ids
    }
    private static func baselineReport(_ b: Wire, owner: String) throws -> (Set<String>,Bool) {
        try Codec.fields(b, ["payload"], ["approval"])
        let p = b["payload"]
        try Codec.tagged(p, baselineFormat)
        try Codec.fields(p, ["format","schemaVersion","baselineID","lineageID","ownerAuthority","registryBytes","registrySHA256","revision","legacyHistoryState","historyComplete","heldIdentifiers","allocationIDs","reviewIDs","dependencyDigests","records"])
        for k in ["baselineID","lineageID","ownerAuthority"] { try Codec.token(p[k]) }
        guard p["ownerAuthority"].text == owner else { throw ConversionFailure.approvalConflict }
        try Codec.bytes(p["registryBytes"], limit: Limits.registry); try Codec.sha(p["registrySHA256"])
        let registry = try Registry4.legacy(p["registryBytes"].blob)
        guard Codec.hash(p["registryBytes"].blob) == p["registrySHA256"].text, p["revision"].int == registry["revision"].int else { throw ConversionFailure.historyConflict }
        // This bounded slice admits schema 2 only; schema-3 DEC-073 sidecars are not fabricated or relabelled.
        guard p["legacyHistoryState"].text == "none" else { throw ConversionFailure.historyConflict }
        guard case .bool = p["historyComplete"] else { throw ConversionFailure.malformedInput }
        try Codec.tokens(p["heldIdentifiers"], max: Limits.entities); try Codec.tokens(p["allocationIDs"]); try Codec.tokens(p["reviewIDs"])
        let held = Set(p["heldIdentifiers"].list.map(\.text)), allocations = Set(p["allocationIDs"].list.map(\.text)), reviews = Set(p["reviewIDs"].list.map(\.text))
        guard held == Set(registry["entities"].list.map { $0["id"].text }), held.isDisjoint(with:allocations.union(reviews)) else { throw ConversionFailure.historyConflict }
        var neededReviews = Set<String>()
        for r in registry["references"].list {
            if r.has("attachedBy") { neededReviews.insert(r["attachedBy"].text) }
            if r["status"]["state"].text == "retired" { neededReviews.insert(r["status"]["review"].text) }
        }
        let pins = try dependencies(p["dependencyDigests"])
        try Codec.array(p["records"], max: Limits.records)
        try Codec.ordered(p["records"].list.map { Data($0["id"].text.utf8) })
        var records: [String: Wire] = [:], heldCoverage = Set<String>(), allocationCoverage = Set<String>(), reviewCoverage = Set<String>(), sharedCoverage = Set<String>()
        var missing = !p["historyComplete"].flag || !neededReviews.isSubset(of: reviews)
        for r in p["records"].list {
            try Codec.fields(r, ["id","kind","sha256","heldIdentifiers","allocationIDs","reviewIDs","dependencyDigests"], ["bytes"])
            try Codec.token(r["id"]); try Codec.sha(r["sha256"])
            guard ["allocation","review","evidence"].contains(r["kind"].text), pins[r["id"].text] == r["sha256"].text else { throw ConversionFailure.historyConflict }
            try Codec.tokens(r["heldIdentifiers"],max:Limits.entities); try Codec.tokens(r["allocationIDs"]); try Codec.tokens(r["reviewIDs"])
            let hh = Set(r["heldIdentifiers"].list.map(\.text)), aa = Set(r["allocationIDs"].list.map(\.text)), rr = Set(r["reviewIDs"].list.map(\.text))
            guard hh.isSubset(of:held), aa.isSubset(of: allocations), rr.isSubset(of: reviews),
                  r["kind"].text == "allocation" || (aa.isEmpty && hh.isEmpty),
                  r["kind"].text != "evidence" || rr.isEmpty,
                  heldCoverage.isDisjoint(with:hh), allocationCoverage.isDisjoint(with: aa), reviewCoverage.isDisjoint(with: rr) else { throw ConversionFailure.historyConflict }
            heldCoverage.formUnion(hh); sharedCoverage.formUnion(aa.intersection(rr))
            allocationCoverage.formUnion(aa); reviewCoverage.formUnion(rr)
            _ = try dependencies(r["dependencyDigests"])
            if r.has("bytes") {
                try Codec.bytes(r["bytes"], limit: Limits.record)
                guard Codec.hash(r["bytes"].blob) == r["sha256"].text else { throw ConversionFailure.historyConflict }
            } else { missing = true }
            records[r["id"].text] = r
        }
        if heldCoverage != held || allocationCoverage != allocations || reviewCoverage != reviews { missing = true }
        guard allocations.intersection(reviews).isSubset(of:sharedCoverage) else { throw ConversionFailure.historyConflict }
        for id in pins.keys where records[id] == nil { missing = true }
        // Validate all present edges even when another required artifact is absent.
        var done = Set<String>(), visiting = Set<String>()
        for id in records.keys.sorted() {
            var stack: [(String,Bool)] = [(id,false)]
            while let (key, exit) = stack.popLast() {
                if exit { visiting.remove(key); done.insert(key); continue }
                if visiting.contains(key) { throw ConversionFailure.historyConflict }
                if done.contains(key) { continue }
                guard let row = records[key] else { missing = true; continue }
                visiting.insert(key); stack.append((key,true))
                for (child,sha) in try dependencies(row["dependencyDigests"]).sorted(by: { $0.key < $1.key }) {
                    guard pins[child] == sha else { throw ConversionFailure.historyConflict }
                    stack.append((child,false))
                }
            }
        }
        // Reserve all retained IDs; one identifier cannot be reintroduced as another authority.
        var ids = held.union(allocations).union(reviews)
        for id in records.keys { guard ids.insert(id).inserted else { throw ConversionFailure.historyConflict } }
        guard ids.insert(p["baselineID"].text).inserted else { throw ConversionFailure.historyConflict }
        if b.has("approval") {
            try checkApproval(b["approval"], p, owner:owner)
            guard p["ownerAuthority"].text == owner, ids.insert(b["approval"]["reviewID"].text).inserted else { throw ConversionFailure.approvalConflict }
        } else { missing = true }
        return (ids,missing)
    }
    static func checkRequest(_ q: Wire) throws {
        try Codec.tagged(q, requestFormat)
        try Codec.fields(q, ["format","schemaVersion","requestID","lineageID","ownerAuthority","operation","expectedPrevious","targetRegistryBytes","targetRegistrySHA256","dependencyDigests"])
        for k in ["requestID","lineageID","ownerAuthority"] { try Codec.token(q[k]) }
        guard q["operation"].text == "convertSchema2To4" else { throw ConversionFailure.identityConflict }
        try checkPin(q["expectedPrevious"])
        guard q["expectedPrevious"]["schemaVersion"].int == 2, Codec.equal(q["lineageID"],q["expectedPrevious"]["lineageID"]) else { throw ConversionFailure.staleCheckpoint }
        try Codec.bytes(q["targetRegistryBytes"], limit: Limits.registry); try Codec.sha(q["targetRegistrySHA256"])
        let t = try Registry4.read(q["targetRegistryBytes"].blob)
        guard q["expectedPrevious"]["revision"].int < Int.max,
              t["revision"].int == q["expectedPrevious"]["revision"].int + 1,
              Codec.hash(q["targetRegistryBytes"].blob) == q["targetRegistrySHA256"].text else { throw ConversionFailure.staleCheckpoint }
        guard !t["entities"].list.contains(where: { $0["id"].text.hasPrefix("trp_") }), !t["references"].list.contains(where: { $0["namespace"].text == "gtfs.trip_id" }) else { throw ConversionFailure.identityConflict }
        _ = try dependencies(q["dependencyDigests"])
    }
    static func initialHistory(_ baseline: Wire) throws -> Wire {
        .object(["format":.string(historyFormat), "schemaVersion":.integer(1), "lineageID":baseline["payload"]["lineageID"],
                 "baseline":baseline, "baselineSHA256":.string(try Codec.digest(baseline)), "boundaries":.array([])])
    }
    static func boundary(_ previous: Data, history: Data, request: Wire, approval: Wire) throws -> Wire {
        .object(["operation":.string("convertSchema2To4"), "previousRegistryBytes":Codec.blob(previous),
                 "targetRegistryBytes":request["targetRegistryBytes"], "previousHistorySHA256":.string(Codec.hash(history)),
                 "request":request, "requestSHA256":.string(try Codec.digest(request)), "approval":approval,
                 "approvalSHA256":.string(try Codec.digest(approval))])
    }
    static func history(_ bytes: Data, owner: String) throws -> (Wire,Data,Set<String>) {
        let h = try Codec.read(bytes, limit: Limits.history)
        try Codec.tagged(h, historyFormat)
        try Codec.fields(h, ["format","schemaVersion","lineageID","baseline","baselineSHA256","boundaries"])
        try Codec.token(h["lineageID"]); try Codec.sha(h["baselineSHA256"])
        guard h["baselineSHA256"].text == (try Codec.digest(h["baseline"])), Codec.equal(h["lineageID"],h["baseline"]["payload"]["lineageID"]) else { throw ConversionFailure.historyConflict }
        var (ids,missing) = try baselineReport(h["baseline"], owner:owner)
        try Codec.array(h["boundaries"], max: Limits.boundaries)
        let previous = h["baseline"]["payload"]["registryBytes"].blob
        let initial = try Codec.encode(initialHistory(h["baseline"]))
        if let b = h["boundaries"].list.first {
            try Codec.fields(b, ["operation","previousRegistryBytes","targetRegistryBytes","previousHistorySHA256","request","requestSHA256","approval","approvalSHA256"])
            let q = b["request"], a = b["approval"]
            if case .null = a { throw ConversionFailure.malformedInput }
            try checkRequest(q)
            do { try checkApproval(a,q,owner:owner) } catch let f as ConversionFailure where f.held { missing = true }
            guard ids.insert(q["requestID"].text).inserted, ids.insert(a["reviewID"].text).inserted,
                  q["ownerAuthority"].text == owner, Codec.equal(q["lineageID"],h["lineageID"]),
                  Codec.equal(q["expectedPrevious"], try pin(previous,initial,lineage:h["lineageID"].text)),
                  Codec.equal(q["dependencyDigests"],h["baseline"]["payload"]["dependencyDigests"]),
                  Codec.equal(b, try boundary(previous,history:initial,request:q,approval:a)) else { throw ConversionFailure.historyConflict }
            try Registry4.conversion(previous,q["targetRegistryBytes"].blob)
            if missing { throw ConversionFailure.historyUnavailable }
            return (h,q["targetRegistryBytes"].blob,ids)
        }
        if missing { throw ConversionFailure.historyUnavailable }
        return (h,previous,ids)
    }
    static func context(_ registry: Data, history bytes: Data, current: Wire, owner: String) throws -> (Wire,Set<String>) {
        try checkPin(current)
        guard current["registrySHA256"].text == Codec.hash(registry), current["historySHA256"].text == Codec.hash(bytes) else { throw ConversionFailure.staleCheckpoint }
        let (h, latest, ids) = try history(bytes, owner:owner)
        guard latest == registry, Codec.equal(current, try pin(registry,bytes,lineage:h["lineageID"].text)) else { throw ConversionFailure.staleCheckpoint }
        return (h,ids)
    }
    static func prepare(_ registry: Data, history bytes: Data, current: Wire, owner: String, requestID: String) throws -> Wire {
        let (h,ids) = try context(registry,history:bytes,current:current,owner:owner)
        guard h["boundaries"].list.isEmpty, !ids.contains(requestID) else { throw ConversionFailure.staleCheckpoint }
        let target = try Registry4.target(registry)
        let q: Wire = .object(["format":.string(requestFormat), "schemaVersion":.integer(1), "requestID":.string(requestID),
            "lineageID":h["lineageID"], "ownerAuthority":.string(owner), "operation":.string("convertSchema2To4"),
            "expectedPrevious":current, "targetRegistryBytes":Codec.blob(target), "targetRegistrySHA256":.string(Codec.hash(target)),
            "dependencyDigests":h["baseline"]["payload"]["dependencyDigests"]])
        try checkRequest(q); return q
    }
    static func apply(_ registry: Data, history bytes: Data, current: Wire, request: Wire, approval: Wire, owner: String) throws -> Bundle {
        try checkRequest(request)
        var approvalMissing = false
        do { try checkApproval(approval,request,owner:owner) }
        catch ConversionFailure.approvalMissing { approvalMissing = true }
        try checkPin(current)
        guard current["registrySHA256"].text == Codec.hash(registry), current["historySHA256"].text == Codec.hash(bytes) else { throw ConversionFailure.staleCheckpoint }
        guard request["ownerAuthority"].text == owner, Codec.equal(request["lineageID"],current["lineageID"]) else { throw ConversionFailure.approvalConflict }
        // A missing retained artifact cannot mask a conflict provable from supplied current bytes.
        if current["schemaVersion"].int == 2 {
            guard Codec.equal(current,request["expectedPrevious"]) else { throw ConversionFailure.staleCheckpoint }
            try Registry4.conversion(registry,request["targetRegistryBytes"].blob)
        } else {
            guard registry == request["targetRegistryBytes"].blob else { throw ConversionFailure.staleCheckpoint }
        }
        let (h,ids) = try context(registry,history:bytes,current:current,owner:owner)
        guard request["ownerAuthority"].text == owner, Codec.equal(request["lineageID"],h["lineageID"]) else { throw ConversionFailure.approvalConflict }
        if let b = h["boundaries"].list.first {
            guard Codec.equal(b["request"],request) else { throw ConversionFailure.staleCheckpoint }
            if approvalMissing { throw ConversionFailure.approvalMissing }
            guard Codec.equal(b["approval"],approval) else { throw ConversionFailure.staleCheckpoint }
            return try bundle(registry,bytes,request:request,approval:approval,replay:true)
        }
        guard !ids.contains(request["requestID"].text), !ids.contains(approval["reviewID"].text), request["requestID"].text != approval["reviewID"].text,
              Codec.equal(current,request["expectedPrevious"]), Codec.equal(request["dependencyDigests"],h["baseline"]["payload"]["dependencyDigests"]) else { throw ConversionFailure.staleCheckpoint }
        try Registry4.conversion(registry,request["targetRegistryBytes"].blob)
        if approvalMissing { throw ConversionFailure.approvalMissing }
        let next = h.replacing("boundaries",.array([try boundary(registry,history:bytes,request:request,approval:approval)]))
        let encoded = try Codec.encode(next)
        guard encoded.count <= Limits.history else { throw ConversionFailure.resourceLimit }
        return try bundle(request["targetRegistryBytes"].blob,encoded,request:request,approval:approval,replay:false)
    }
    static func bundle(_ registry: Data, _ history: Data, request: Wire, approval: Wire, replay: Bool) throws -> Bundle {
        let boundaries = try Codec.read(history,limit:Limits.history)["boundaries"].list
        guard boundaries.count == 1 else { throw ConversionFailure.historyConflict }
        let m: Wire = .object(["format":.string(manifestFormat), "schemaVersion":.integer(1), "lineageID":request["lineageID"],
            "predecessor":request["expectedPrevious"], "target":try pin(registry,history,lineage:request["lineageID"].text),
            "requestSHA256":.string(try Codec.digest(request)), "approvalSHA256":.string(try Codec.digest(approval)),
            "boundarySHA256":.string(try Codec.digest(boundaries[0]))])
        let bytes = try Codec.encode(m)
        guard registry.count + history.count + bytes.count <= Limits.bundle else { throw ConversionFailure.resourceLimit }
        return .init(registry:registry,history:history,manifest:bytes,replay:replay)
    }
    static func verify(_ registry: Data, _ historyBytes: Data, _ manifest: Data, owner: String) throws -> Bundle {
        let m = try Codec.read(manifest,limit:Limits.request)
        try Codec.tagged(m,manifestFormat); try Codec.fields(m,["format","schemaVersion","lineageID","predecessor","target","requestSHA256","approvalSHA256","boundarySHA256"])
        let (h,_,_) = try history(historyBytes,owner:owner)
        guard h["boundaries"].list.count == 1, let b = h["boundaries"].list.first else { throw ConversionFailure.historyConflict }
        _ = try context(registry,history:historyBytes,current:m["target"],owner:owner)
        let result = try bundle(registry,historyBytes,request:b["request"],approval:b["approval"],replay:true)
        guard result.manifest == manifest else { throw ConversionFailure.historyConflict }
        return result
    }
}
