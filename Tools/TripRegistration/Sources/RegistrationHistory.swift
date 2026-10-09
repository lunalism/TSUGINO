import Foundation

extension Registration {
    static func boundary(_ previous: Data, history: Data, request q: Wire, approval a: Wire) throws -> Wire {
        .object(["operation":.string(operation),"previousRegistryBytes":Codec.blob(previous),"targetRegistryBytes":q["targetRegistryBytes"],
            "previousHistorySHA256":.string(Codec.hash(history)),"request":q,"requestSHA256":.string(try Codec.digest(q)),"approval":a,"approvalSHA256":.string(try Codec.digest(a))])
    }
    static func history(_ predecessor: Data, previous: Data, request q: Wire, approval a: Wire) throws -> Data {
        let h: Wire = .object(["format":.string(Conversion.historyFormat),"schemaVersion":.integer(2),"lineageID":q["lineageID"],
            "predecessorHistoryBytes":Codec.blob(predecessor),"predecessorHistorySHA256":.string(Codec.hash(predecessor)),
            "boundaries":.array([try boundary(previous,history:predecessor,request:q,approval:a)])])
        let bytes = try Codec.encode(h)
        guard bytes.count <= Limits.history else { throw ConversionFailure.resourceLimit }; return bytes
    }
    static func manifest(_ registry: Data, _ h: Data, q: Wire, a: Wire, b: Wire) throws -> Data {
        let m: Wire = .object(["format":.string(manifestFormat),"schemaVersion":.integer(1),"operation":.string(operation),"lineageID":q["lineageID"],
            "predecessor":q["expectedPrevious"],"target":try Conversion.pin(registry,h,lineage:q["lineageID"].text),
            "predecessorManifestSHA256":q["context"]["predecessorManifestSHA256"],"requestSHA256":.string(try Codec.digest(q)),
            "approvalSHA256":.string(try Codec.digest(a)),"boundarySHA256":.string(try Codec.digest(b))])
        return try Codec.encode(m)
    }
    static func verify(_ registry: Data, _ historyBytes: Data, _ manifestBytes: Data, owner: String) throws -> Conversion.Bundle {
        let h = try read(historyBytes,limit:Limits.history), m = try read(manifestBytes,limit:Limits.request)
        try Codec.version(h,[2]); guard h["format"].text == Conversion.historyFormat else { throw ConversionFailure.malformedInput }
        try Codec.fields(h,["format","schemaVersion","lineageID","predecessorHistoryBytes","predecessorHistorySHA256","boundaries"])
        try Codec.bytes(h["predecessorHistoryBytes"],limit:Limits.history); try Codec.sha(h["predecessorHistorySHA256"])
        try Codec.array(h["boundaries"],max:1)
        guard h["boundaries"].list.count == 1 else { throw ConversionFailure.historyConflict }
        let b = h["boundaries"].list[0]
        try Codec.fields(b,["operation","previousRegistryBytes","targetRegistryBytes","previousHistorySHA256","request","requestSHA256","approval","approvalSHA256"])
        try Codec.bytes(b["previousRegistryBytes"],limit:Limits.registry)
        let q = b["request"], a = b["approval"], oldHistory = h["predecessorHistoryBytes"].blob
        try checkRequest(q); try checkApproval(a,q)
        guard q["ownerAuthority"].text == owner, Codec.equal(h["lineageID"],q["lineageID"]),
              Codec.hash(oldHistory) == h["predecessorHistorySHA256"].text,
              Codec.equal(b,try boundary(b["previousRegistryBytes"].blob,history:oldHistory,request:q,approval:a)) else { throw ConversionFailure.historyConflict }
        // Explicit v1 dispatch: unchanged legacy validator rejects v2/nested roots.
        let (old,latest,_) = try Conversion.history(oldHistory,owner:owner)
        guard old["boundaries"].list.count == 1, latest == b["previousRegistryBytes"].blob else { throw ConversionFailure.historyConflict }
        let cb = old["boundaries"].list[0]
        let predecessorManifest = try Conversion.bundle(latest,oldHistory,request:cb["request"],approval:cb["approval"],replay:true).manifest
        let input = Inputs(registry:latest,history:oldHistory,manifest:predecessorManifest,context:q["context"],correspondence:q["correspondenceBytes"].blob,dependencies:q["dependencies"])
        try validate(q,input:input)
        guard registry == q["targetRegistryBytes"].blob else { throw ConversionFailure.identityConflict }
        try Codec.tagged(m,manifestFormat)
        try Codec.fields(m,["format","schemaVersion","operation","lineageID","predecessor","target","predecessorManifestSHA256","requestSHA256","approvalSHA256","boundarySHA256"])
        let expected = try manifest(registry,historyBytes,q:q,a:a,b:b)
        guard expected == manifestBytes else { throw ConversionFailure.historyConflict }
        guard registry.count + historyBytes.count + manifestBytes.count <= Limits.bundle else { throw ConversionFailure.resourceLimit }
        return .init(registry:registry,history:historyBytes,manifest:manifestBytes,replay:true)
    }
    static func apply(_ i: Inputs, request q: Wire, approval a: Wire, current: Wire) throws -> Conversion.Bundle {
        try checkRequest(q)
        var missingApproval = false
        do { try checkApproval(a,q) } catch ConversionFailure.approvalMissing { missingApproval = true }
        try Conversion.checkPin(current)
        guard current["registrySHA256"].text == Codec.hash(i.registry), current["historySHA256"].text == Codec.hash(i.history),
              Codec.equal(current["lineageID"],q["lineageID"]), Codec.equal(i.context,q["context"]), i.correspondence == q["correspondenceBytes"].blob,
              Codec.equal(i.dependencies,q["dependencies"]) else { throw ConversionFailure.staleCheckpoint }
        let h = try read(i.history,limit:Limits.history)
        if h["schemaVersion"].int == 2 {
            let verified = try verify(i.registry,i.history,i.manifest,owner:q["ownerAuthority"].text)
            let retained = h["boundaries"].list[0]
            if missingApproval { throw ConversionFailure.approvalMissing }
            guard Codec.equal(retained["request"],q), Codec.equal(retained["approval"],a),
                  Codec.equal(current,try Conversion.pin(i.registry,i.history,lineage:q["lineageID"].text)) else { throw ConversionFailure.staleCheckpoint }
            return verified
        }
        guard Codec.equal(current,q["expectedPrevious"]) else { throw ConversionFailure.staleCheckpoint }
        try validate(q,input:i)
        if missingApproval { throw ConversionFailure.approvalMissing }
        let next = try history(i.history,previous:i.registry,request:q,approval:a)
        let b = try boundary(i.registry,history:i.history,request:q,approval:a)
        let m = try manifest(q["targetRegistryBytes"].blob,next,q:q,a:a,b:b)
        _ = try verify(q["targetRegistryBytes"].blob,next,m,owner:q["ownerAuthority"].text)
        return .init(registry:q["targetRegistryBytes"].blob,history:next,manifest:m,replay:false)
    }
}
