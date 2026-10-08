import Foundation
import Darwin

// Explicit paths and byte pins only. No defaults, discovery, implicit approval or real-data execution here.
func run() throws {
    let args = Array(CommandLine.arguments.dropFirst())
    guard let command = args.first else { throw ConversionFailure.malformedInput }
    var options: [String:String] = [:]
    guard (args.count - 1) % 2 == 0 else { throw ConversionFailure.malformedInput }
    for i in stride(from:1,to:args.count,by:2) {
        guard args[i].hasPrefix("--"), options.updateValue(args[i+1],forKey:args[i]) == nil else { throw ConversionFailure.malformedInput }
    }
    func only(_ keys: [String]) throws { guard Set(options.keys) == Set(keys) else { throw ConversionFailure.malformedInput } }
    func get(_ key: String) throws -> String { guard let v = options["--" + key] else { throw ConversionFailure.malformedInput }; return v }
    func read(_ key: String, _ limit: Int) throws -> Data {
        do { return try PrivateIO.read(get(key),sha256:get(key + "-sha256"),limit:limit) }
        catch ConversionFailure.historyUnavailable where key == "approval" { throw ConversionFailure.approvalMissing }
    }
    func doc(_ key: String, _ limit: Int) throws -> Wire { try Codec.read(read(key,limit),limit:limit) }
    let owner = try get("owner"); try Codec.token(.string(owner))
    let contextKeys = ["--registry","--registry-sha256","--history","--history-sha256","--checkpoint","--checkpoint-sha256","--owner"]
    func context() throws -> (Data,Data,Wire) {
        let r = try read("registry",Limits.registry), h = try read("history",Limits.history), p = try doc("checkpoint",Limits.request)
        if p["format"].text == Conversion.manifestFormat {
            _ = try Conversion.verify(r,h,try Codec.encode(p),owner:owner); return (r,h,p["target"])
        }
        try Conversion.checkPin(p); return (r,h,p)
    }
    switch command {
    case "prepare-conversion":
        try only(contextKeys + ["--request-id","--output"])
        let (r,h,p) = try context()
        let q = try Conversion.prepare(r,history:h,current:p,owner:owner,requestID:get("request-id"))
        let b = try Codec.encode(q); try PrivateIO.write(get("output"),bytes:b)
        print("prepared requestSHA256=" + Codec.hash(b))
    case "inspect":
        try only(["--request","--request-sha256","--owner"])
        let q = try doc("request",Limits.request); try Conversion.checkRequest(q)
        guard q["ownerAuthority"].text == owner else { throw ConversionFailure.approvalConflict }
        print("requestRepresentationValid approved=false requestSHA256=" + (try Codec.digest(q)))
    case "approve":
        try only(["--request","--request-sha256","--owner","--review-id","--author","--approved-at","--approval-reference","--output"])
        let q = try doc("request",Limits.request); try Conversion.checkRequest(q)
        guard q["ownerAuthority"].text == owner else { throw ConversionFailure.approvalConflict }
        let a = try Conversion.approval(q,owner:owner,reviewID:get("review-id"),author:get("author"),at:get("approved-at"),reference:get("approval-reference"))
        let b = try Codec.encode(a); try PrivateIO.write(get("output"),bytes:b)
        print("approvalRepresentationValid approvalSHA256=" + Codec.hash(b))
    case "apply":
        try only(contextKeys + ["--request","--request-sha256","--approval","--approval-sha256","--output"])
        let (r,h,p) = try context(), q = try doc("request",Limits.request)
        let a: Wire
        do { a = try doc("approval",Limits.approval) }
        catch ConversionFailure.approvalMissing { a = .null }
        let b = try Conversion.apply(r,history:h,current:p,request:q,approval:a,owner:owner)
        try PrivateIO.publish(b,to:get("output"),owner:owner)
        print((b.replay ? "unchangedReplay" : "converted") + " manifestSHA256=" + Codec.hash(b.manifest))
    case "verify-bundle":
        try only(["--bundle","--manifest-sha256","--owner"])
        let b = try PrivateIO.readBundle(get("bundle"),owner:owner,manifestSHA:get("manifest-sha256"))
        print("bundleValid manifestSHA256=" + Codec.hash(b.manifest))
    default: throw ConversionFailure.malformedInput
    }
}
do { try run() }
catch let f as ConversionFailure { print((f.held ? "held:" : "rejected:") + f.rawValue); exit(f.held ? 3 : 2) }
catch { print("rejected:malformedInput"); exit(2) }
