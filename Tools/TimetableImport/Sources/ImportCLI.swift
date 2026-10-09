import Foundation

enum ImportCLI {
    static func run(_ args: [String]) throws -> String {
        guard let command = args.first, (args.count - 1) % 2 == 0 else { throw ConversionFailure.malformedInput }
        var options: [String:String] = [:]
        for n in stride(from:1,to:args.count,by:2) {
            guard args[n].hasPrefix("--"), options.updateValue(args[n+1],forKey:args[n]) == nil else { throw ConversionFailure.malformedInput }
        }
        func get(_ key: String) throws -> String { guard let v = options["--" + key] else { throw ConversionFailure.malformedInput }; return v }
        func only(_ keys: [String]) throws { guard Set(options.keys) == Set((keys + ["owner"]).map { "--" + $0 }) else { throw ConversionFailure.malformedInput } }
        func raw(_ key: String, _ limit: Int) throws -> Data { try ImportIO.read(get(key),sha:get(key + "-sha256"),limit:limit) }
        func doc(_ key: String, _ limit: Int) throws -> Wire { try ImportAuthority.read(raw(key,limit),limit) }
        let owner = try get("owner"); try ImportAuthority.token(owner)
        let profileKeys = ["profile-review","profile-review-sha256"]
        let externalKeys = profileKeys + ["profile-approval","profile-approval-sha256","s9-bundle","s9-manifest-sha256"]
        let requestKeys = ["request","request-sha256"]
        func external() throws -> ImportAuthority.External {
            let b = try S9IO.readBundle(get("s9-bundle"),owner:owner,manifestSHA:get("s9-manifest-sha256"))
            return try .init(owner:owner,s9Files:b.files,manifestSHA:get("s9-manifest-sha256"),review:raw("profile-review",ImportLimits.review),approval:raw("profile-approval",ImportLimits.approval))
        }
        switch command {
        case "approve-profile-review":
            try only(profileKeys + ["profile-id","review-id","reviewer","approved-at","approval-reference","output"])
            let a = try ImportAuthority.profileApproval(review:raw("profile-review",ImportLimits.review),owner:owner,profile:get("profile-id"),reviewID:get("review-id"),
                reviewer:get("reviewer"),at:get("approved-at"),reference:get("approval-reference"))
            let bytes = try ImportAuthority.encode(a,ImportLimits.approval)
            try ImportIO.write(get("output"),bytes:bytes,limit:ImportLimits.approval)
            return "profileApprovalCreated approvalSHA256=" + Codec.hash(bytes)
        case "prepare-import":
            try only(externalKeys + ["input","input-sha256","state","state-sha256","request-id","approval-review-id","output-id","output"])
            let e = try external()
            let result = try ImportAuthority.prepare(doc("input",ImportLimits.input),state:doc("state",ImportLimits.state),requestID:get("request-id"),approvalReviewID:get("approval-review-id"),outputID:get("output-id"),external:e)
            switch result {
            case .outcome(let o): return ImportAuthority.status(o)
            case .request(let q):
                let bytes = try ImportAuthority.encode(q,ImportLimits.request)
                try ImportIO.write(get("output"),bytes:bytes,limit:ImportLimits.request)
                return "prepared approved=false requestSHA256=" + Codec.hash(bytes)
            }
        case "inspect-import":
            try only(externalKeys + requestKeys)
            let f = try ImportAuthority.request(doc("request",ImportLimits.request),external:external())
            return "requestValid approved=false " + ImportAuthority.summary(f)
        case "approve-import":
            try only(externalKeys + requestKeys + ["reviewer","approved-at","approval-reference","output"])
            let a = try ImportAuthority.approve(doc("request",ImportLimits.request),external:external(),reviewer:get("reviewer"),at:get("approved-at"),reference:get("approval-reference"))
            let bytes = try ImportAuthority.encode(a,ImportLimits.approval)
            try ImportIO.write(get("output"),bytes:bytes,limit:ImportLimits.approval)
            return "importApprovalCreated approvalSHA256=" + Codec.hash(bytes)
        case "apply-import":
            let hasApproval = options["--approval"] != nil || options["--approval-sha256"] != nil
            try only(externalKeys + requestKeys + ["state","state-sha256","output"] + (hasApproval ? ["approval","approval-sha256"] : []))
            let e = try external(), q = try doc("request",ImportLimits.request), s = try doc("state",ImportLimits.state)
            let a: Wire?
            do { a = hasApproval ? try doc("approval",ImportLimits.approval) : nil }
            catch ConversionFailure.historyUnavailable { throw ConversionFailure.approvalMissing }
            let b = try ImportAuthority.apply(q,approval:a,currentState:s,external:e)
            try ImportIO.publish(b,path:get("output"),external:e)
            return (b.replay ? "unchangedReplay" : "occurrenceImported") + " manifestSHA256=" + Codec.hash(b.manifest)
        case "verify-import-bundle":
            try only(externalKeys + ["bundle","manifest-sha256"])
            let b = try ImportIO.readBundle(get("bundle"),external:external(),manifestSHA:get("manifest-sha256"))
            return "bundleValid unchangedReplay manifestSHA256=" + Codec.hash(b.manifest)
        default: throw ConversionFailure.malformedInput
        }
    }
    static func failure(_ error: Error) -> String { S9CLI.failure(error) }
}
