import Foundation

enum S9CLI {
    static func run(_ args: [String]) throws -> String {
        guard let command = args.first, (args.count - 1) % 2 == 0 else { throw ConversionFailure.malformedInput }
        var options: [String:String] = [:]
        for n in stride(from:1,to:args.count,by:2) {
            guard args[n].hasPrefix("--"), options.updateValue(args[n+1],forKey:args[n]) == nil else { throw ConversionFailure.malformedInput }
        }
        func get(_ key: String) throws -> String { guard let v = options["--" + key] else { throw ConversionFailure.malformedInput }; return v }
        func only(_ keys: [String]) throws { guard Set(options.keys) == Set(keys + ["--owner"]) else { throw ConversionFailure.malformedInput } }
        func doc(_ key: String, _ limit: Int) throws -> Wire { try S9.read(S9IO.read(get(key),sha:get(key + "-sha256"),limit:limit),limit) }
        let owner = try get("owner"); try Codec.token(.string(owner))
        let requestKeys = ["--request","--request-sha256"]
        switch command {
        case "prepare-snapshot":
            try only(["--input","--input-sha256","--context","--context-sha256","--state","--state-sha256","--output"])
            let i = try doc("input",S9Limits.input), c = try doc("context",S9Limits.context), s = try doc("state",S9Limits.state)
            guard Codec.equal(i["ownerAuthority"],.string(owner)) else { throw ConversionFailure.approvalConflict }
            let q = try S9.prepare(i,context:c,state:s), bytes = try S9.encode(q,S9Limits.request)
            try S9IO.write(get("output"),bytes:bytes,limit:S9Limits.request)
            return "prepared approved=false requestSHA256=" + Codec.hash(bytes)
        case "inspect-snapshot":
            try only(requestKeys)
            let q = try doc("request",S9Limits.request), p = try S9.request(q,owner:owner)
            let t = try JSONDecoder().decode(Trip.self,from:p.trip)
            return "requestValid approved=false requestSHA256=" + (try Codec.digest(q)) + " passengerCount=" + String(t.stopSequence.count) + " segmentCount=" + String(t.lineSegments.count)
        case "approve-snapshot":
            try only(requestKeys + ["--reviewer","--approved-at","--approval-reference","--output"])
            let q = try doc("request",S9Limits.request)
            let a = try S9.approve(q,owner:owner,reviewer:get("reviewer"),at:get("approved-at"),reference:get("approval-reference")), bytes = try S9.encode(a,S9Limits.approval)
            try S9IO.write(get("output"),bytes:bytes,limit:S9Limits.approval)
            return "approvalCreated approvalSHA256=" + Codec.hash(bytes)
        case "apply-snapshot":
            try only(requestKeys + ["--approval","--approval-sha256","--state","--state-sha256","--output"])
            let q = try doc("request",S9Limits.request), s = try doc("state",S9Limits.state), a: Wire
            do { a = try doc("approval",S9Limits.approval) }
            catch ConversionFailure.historyUnavailable { throw ConversionFailure.approvalMissing }
            let b = try S9.apply(q,approval:a,currentState:s,owner:owner)
            try S9IO.publish(b,path:get("output"),owner:owner)
            return (b.replay ? "unchangedReplay" : "snapshotSelected") + " manifestSHA256=" + Codec.hash(b.manifest)
        case "verify-snapshot-bundle":
            try only(["--bundle","--manifest-sha256"])
            let b = try S9IO.readBundle(get("bundle"),owner:owner,manifestSHA:get("manifest-sha256"))
            return "bundleValid unchangedReplay manifestSHA256=" + Codec.hash(b.manifest)
        default: throw ConversionFailure.malformedInput
        }
    }
    static func failure(_ error: Error) -> String {
        if let f = error as? S9Failure { return "rejected status=" + f.rawValue }
        if let f = error as? ConversionFailure { return (f.held ? "held status=" : "rejected status=") + f.rawValue }
        return "rejected status=invalidStructure"
    }
}
