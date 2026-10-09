import Foundation

enum RegistrationCLI {
    static let commands = ["prepare-registration","inspect-registration","approve-registration","apply-registration","verify-registration-bundle"]
    static func run(_ args: [String]) throws {
        guard let command = args.first, (args.count - 1) % 2 == 0 else { throw ConversionFailure.malformedInput }
        var options: [String:String] = [:]
        for n in stride(from:1,to:args.count,by:2) {
            guard args[n].hasPrefix("--"), options.updateValue(args[n+1],forKey:args[n]) == nil else { throw ConversionFailure.malformedInput }
        }
        func only(_ keys: [String]) throws { guard Set(options.keys) == Set(keys) else { throw ConversionFailure.malformedInput } }
        func get(_ key: String) throws -> String { guard let v = options["--" + key] else { throw ConversionFailure.malformedInput }; return v }
        func bytes(_ key: String, _ limit: Int) throws -> Data { try PrivateIO.read(get(key),sha256:get(key + "-sha256"),limit:limit) }
        func doc(_ key: String, _ limit: Int) throws -> Wire { try Registration.read(bytes(key,limit),limit:limit) }
        let owner = try get("owner"); try Codec.token(.string(owner))
        let contextKeys = ["--registry","--registry-sha256","--history","--history-sha256","--checkpoint","--checkpoint-sha256","--context","--context-sha256",
            "--correspondence","--correspondence-sha256","--dependencies","--dependencies-sha256","--owner"]
        let locationKeys = ["--workspace","--operation-id","--workspace-id","--output-id","--output"]
        let requestKeys = ["--request","--request-sha256"]
        func input() throws -> Registration.Inputs {
            let c = try doc("context",Correspondence.limit)
            guard c["ownerAuthority"].text == owner else { throw ConversionFailure.approvalConflict }
            return try .init(registry:bytes("registry",Limits.registry),history:bytes("history",Limits.history),manifest:bytes("checkpoint",Limits.request),
                context:c,correspondence:bytes("correspondence",Correspondence.limit),dependencies:doc("dependencies",Limits.request))
        }
        func location() throws -> Preparation.Location {
            try .init(workspace:get("workspace"),output:get("output"),operationID:get("operation-id"),workspaceID:get("workspace-id"),outputID:get("output-id"))
        }
        switch command {
        case "prepare-registration":
            try only(contextKeys + locationKeys)
            let (q,reused) = try Preparation.prepare(input(),location:location())
            print((reused ? "preparedReplay" : "prepared") + " approved=false requestSHA256=" + (try Codec.digest(q)))
        case "inspect-registration":
            try only(contextKeys + requestKeys)
            let i = try input(), q = try doc("request",Limits.request)
            try Registration.validate(q,input:i)
            print("requestRepresentationValid approved=false requestSHA256=" + (try Codec.digest(q)))
        case "approve-registration":
            try only(requestKeys + ["--owner","--review-id","--author","--approved-at","--approval-reference","--output"])
            let q = try doc("request",Limits.request)
            guard q["ownerAuthority"].text == owner else { throw ConversionFailure.approvalConflict }
            let a = try Registration.approval(q,reviewID:get("review-id"),author:get("author"),at:get("approved-at"),reference:get("approval-reference"))
            let b = try Codec.encode(a); try PrivateIO.write(get("output"),bytes:b)
            print("approvalRepresentationValid approvalSHA256=" + Codec.hash(b))
        case "apply-registration":
            try only(contextKeys + locationKeys + requestKeys + ["--approval","--approval-sha256"])
            let i = try input(), q = try doc("request",Limits.request), a: Wire
            do { a = try doc("approval",Limits.approval) }
            catch ConversionFailure.historyUnavailable { throw ConversionFailure.approvalMissing }
            let current = try Registration.read(i.manifest,limit:Limits.request)["target"]
            let b = try Registration.apply(i,request:q,approval:a,current:current)
            try Preparation.publish(b,request:q,location:location())
            print((b.replay ? "unchangedReplay" : "registered") + " manifestSHA256=" + Codec.hash(b.manifest))
        case "verify-registration-bundle":
            try only(["--bundle","--manifest-sha256","--owner"])
            let p = try PrivateIO.parent(get("bundle")); defer { p.closeFD() }
            let b = try PrivateIO.readBundleAt(p.fd,p.leaf,owner:owner,manifestSHA:get("manifest-sha256"),registration:true)
            print("bundleValid manifestSHA256=" + Codec.hash(b.manifest))
        default: throw ConversionFailure.malformedInput
        }
    }
}
