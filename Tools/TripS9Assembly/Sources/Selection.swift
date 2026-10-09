import Foundation

extension S9 {
    static func context(_ c: Wire, input i: Wire, state s: Wire, product p: Product) throws {
        _ = try encode(c,S9Limits.context)
        try shape(c,"assembly-context",["ownerAuthority","operation","registeredCheckpoint","inputSHA256","movementReviewSHA256","snapshotArtifactID","requestID","approvalReviewID","outputID","dependencyDigests","selectionStateSHA256","initialSelection","noPreviousSnapshot"])
        for k in workflow { try Codec.token(c[k]) }
        for k in ["inputSHA256","movementReviewSHA256","selectionStateSHA256"] { try Codec.sha(c[k]) }
        guard c["operation"].text == operation, Codec.equal(c["ownerAuthority"],i["ownerAuthority"]),
              Codec.equal(c["registeredCheckpoint"],i["registeredCheckpoint"]), c["inputSHA256"].text == (try Codec.digest(i)),
              Codec.equal(c["movementReviewSHA256"],i["movementReview"]["sha256"]), Codec.equal(c["dependencyDigests"],p.roots),
              c["selectionStateSHA256"].text == (try Codec.digest(s)),
              Codec.equal(c["initialSelection"],.bool(true)), Codec.equal(c["noPreviousSnapshot"],.bool(true)) else { throw ConversionFailure.staleCheckpoint }
        var reserved = try state(s,owner:i["ownerAuthority"],trip:i["registeredTripID"])
        guard s["selections"].list.isEmpty else { throw S9Failure.selectionConflict }
        reserved.formUnion(p.activeIDs)
        reserved.formUnion([i["inputID"].text,i["ownerAuthority"].text,i["source"]["sourceID"].text,i["registeredCheckpoint"]["lineageID"].text])
        reserved.formUnion(p.roots.list.map { $0["id"].text })
        // Explicitly retained, validated identity authority inventory. Never mine opaque evidence.
        let h = try read(i["registeredBundle"]["historyBytes"].blob,Limits.history)
        let old = h["predecessorHistoryBytes"].blob
        reserved.formUnion(try Conversion.history(old,owner:i["ownerAuthority"].text).2)
        let q = h["boundaries"].list[0]["request"]
        reserved.formUnion(Registration.workflowFields.map { q["context"]["workflow"][$0].text })
        reserved.insert(q["context"]["correspondence"]["requestID"].text)
        reserved.formUnion(q["dependencies"].list.map { $0["id"].text })
        let tokens = workflow.map { c[$0].text }
        guard Set(tokens).count == tokens.count, tokens.allSatisfy({ !reserved.contains($0) }) else { throw ConversionFailure.identityConflict }
    }
    static func prepare(_ i: Wire, context c: Wire, state s: Wire) throws -> Wire {
        let p = try reconstruct(i,artifact:c["snapshotArtifactID"])
        try context(c,input:i,state:s,product:p)
        let q = tagged("snapshot-request",["requestID":c["requestID"],"ownerAuthority":i["ownerAuthority"],"operation":.string(operation),
            "context":c,"inputBytes":Codec.blob(try encode(i,S9Limits.input)),"inputSHA256":c["inputSHA256"],"selectionState":s,
            "tripBytes":Codec.blob(p.trip),"tripSHA256":.string(Codec.hash(p.trip)),"crosswalkBytes":Codec.blob(p.crosswalk),"crosswalkSHA256":.string(Codec.hash(p.crosswalk)),
            "snapshotArtifactID":c["snapshotArtifactID"],"registeredTripID":i["registeredTripID"],"registeredCheckpoint":i["registeredCheckpoint"],
            "dependencyDigests":p.roots,"initialSelection":.bool(true),"noPreviousSnapshot":.bool(true)])
        _ = try encode(q,S9Limits.request); return q
    }
    @discardableResult static func request(_ q: Wire, owner: String) throws -> Product {
        _ = try encode(q,S9Limits.request)
        try shape(q,"snapshot-request",["requestID","ownerAuthority","operation","context","inputBytes","inputSHA256","selectionState","tripBytes","tripSHA256","crosswalkBytes","crosswalkSHA256","snapshotArtifactID","registeredTripID","registeredCheckpoint","dependencyDigests","initialSelection","noPreviousSnapshot"])
        try Codec.token(.string(owner))
        guard Codec.equal(q["ownerAuthority"],.string(owner)) else { throw ConversionFailure.approvalConflict }
        try Codec.bytes(q["inputBytes"],limit:S9Limits.input); try Codec.bytes(q["tripBytes"],limit:S9Limits.trip); try Codec.bytes(q["crosswalkBytes"],limit:S9Limits.crosswalk)
        let i = try read(q["inputBytes"].blob,S9Limits.input)
        let expected = try prepare(i,context:q["context"],state:q["selectionState"])
        guard Codec.equal(q,expected) else { throw ConversionFailure.historyConflict }
        return try reconstruct(i,artifact:q["snapshotArtifactID"])
    }
    static func approve(_ q: Wire, owner: String, reviewer: String, at: String, reference: String) throws -> Wire {
        try request(q,owner:owner)
        try Codec.token(.string(reviewer)); try Codec.timestamp(.string(at)); try Codec.token(.string(reference))
        return tagged("snapshot-approval",["requestFormat":q["format"],"requestID":q["requestID"],"requestSHA256":.string(try Codec.digest(q)),
            "ownerAuthority":q["ownerAuthority"],"reviewID":q["context"]["approvalReviewID"],"reviewer":.string(reviewer),"approvedAt":.string(at),"approvalReference":.string(reference)])
    }
    static func approval(_ a: Wire, request q: Wire) throws {
        if case .null = a { throw ConversionFailure.approvalMissing }
        _ = try encode(a,S9Limits.approval)
        try shape(a,"snapshot-approval",["requestFormat","requestID","requestSHA256","ownerAuthority","reviewID","reviewer","approvedAt","approvalReference"])
        let expected = try approve(q,owner:q["ownerAuthority"].text,reviewer:a["reviewer"].text,at:a["approvedAt"].text,reference:a["approvalReference"].text)
        guard Codec.equal(a,expected) else { throw ConversionFailure.approvalConflict }
    }
    struct Bundle {
        let files: [String:Data], replay: Bool
        var manifest: Data { files["manifest.json"]! }
    }
    static func bundle(_ q: Wire, approval a: Wire, replay: Bool = false) throws -> Bundle {
        try request(q,owner:q["ownerAuthority"].text); try approval(a,request:q)
        let h = tagged("snapshot-history",["operation":.string(operation),"ownerAuthority":q["ownerAuthority"],"registeredCheckpoint":q["registeredCheckpoint"],
            "tripID":q["registeredTripID"],"snapshotArtifactID":q["snapshotArtifactID"],"tripSHA256":q["tripSHA256"],"crosswalkSHA256":q["crosswalkSHA256"],
            "request":q,"requestSHA256":.string(try Codec.digest(q)),"approval":a,"approvalSHA256":.string(try Codec.digest(a)),"dependencyDigests":q["dependencyDigests"],
            "initialSelection":.bool(true),"noPreviousSnapshot":.bool(true),"downstreamRevalidation":.array(obligations.map(Wire.string))])
        let hb = try encode(h,S9Limits.history)
        let m = tagged("snapshot-bundle",["operation":.string(operation),"registeredCheckpoint":q["registeredCheckpoint"],"tripID":q["registeredTripID"],"snapshotArtifactID":q["snapshotArtifactID"],
            "tripSHA256":q["tripSHA256"],"crosswalkSHA256":q["crosswalkSHA256"],"historySHA256":.string(Codec.hash(hb)),"requestSHA256":.string(try Codec.digest(q)),
            "approvalSHA256":.string(try Codec.digest(a)),"dependencyRootSHA256":.string(try Codec.digest(q["dependencyDigests"]))])
        let files = ["trip.json":q["tripBytes"].blob,"crosswalk.json":q["crosswalkBytes"].blob,"history.json":hb,"manifest.json":try encode(m,S9Limits.manifest)]
        guard files.values.reduce(0,{ $0 + $1.count }) <= S9Limits.bundle else { throw ConversionFailure.resourceLimit }
        return .init(files:files,replay:replay)
    }
    static func verify(_ files: [String:Data], owner: String, manifestSHA: String) throws -> Bundle {
        guard Set(files.keys) == Set(S9IO.fileLimits.keys), files.values.reduce(0,{ $0 + $1.count }) <= S9Limits.bundle else { throw ConversionFailure.resourceLimit }
        for (name,limit) in S9IO.fileLimits { _ = try bounded(files[name]!,limit) }
        try Codec.sha(.string(manifestSHA))
        guard Codec.hash(files["manifest.json"]!) == manifestSHA else { throw ConversionFailure.historyConflict }
        let h = try read(files["history.json"]!,S9Limits.history)
        try shape(h,"snapshot-history",["operation","ownerAuthority","registeredCheckpoint","tripID","snapshotArtifactID","tripSHA256","crosswalkSHA256","request","requestSHA256","approval","approvalSHA256","dependencyDigests","initialSelection","noPreviousSnapshot","downstreamRevalidation"])
        guard Codec.equal(h["ownerAuthority"],.string(owner)) else { throw ConversionFailure.approvalConflict }
        let expected = try bundle(h["request"],approval:h["approval"],replay:true)
        guard expected.files == files else { throw ConversionFailure.historyConflict }
        return expected
    }
    static func selectedState(_ s: Wire, bundle b: Bundle) throws -> Wire {
        let h = try read(b.files["history.json"]!,S9Limits.history)
        return s.replacing("selections",.array([.object(["tripID":h["tripID"],"snapshotArtifactID":h["snapshotArtifactID"],"manifestSHA256":.string(Codec.hash(b.manifest)),
            "historyBytes":Codec.blob(b.files["history.json"]!),"manifestBytes":Codec.blob(b.manifest)])]))
    }
    static func apply(_ q: Wire, approval a: Wire, currentState s: Wire, owner: String) throws -> Bundle {
        try request(q,owner:owner); try approval(a,request:q)
        _ = try state(s,owner:q["ownerAuthority"],trip:q["registeredTripID"])
        let b = try bundle(q,approval:a)
        if s["selections"].list.isEmpty {
            guard Codec.equal(s,q["selectionState"]) else { throw S9Failure.selectionConflict }; return b
        }
        // A replay is only the exact original request/approval/history/manifest and inventory.
        guard Codec.equal(s,try selectedState(q["selectionState"],bundle:b)) else { throw S9Failure.selectionConflict }
        return .init(files:b.files,replay:true)
    }
}
