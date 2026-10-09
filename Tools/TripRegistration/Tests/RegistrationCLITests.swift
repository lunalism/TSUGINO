import Foundation
import Darwin

func registrationCLI() throws {
    let i = try RegistrationFixtures.scenario(), dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let l = RegistrationFixtures.location(i,dir)
    for (name,bytes) in ["registry":i.registry,"history":i.history,"checkpoint":i.manifest,"context":try Codec.encode(i.context),"correspondence":i.correspondence,"dependencies":try Codec.encode(i.dependencies)] { try Fixtures.write(dir + "/" + name,bytes) }
    let executable = URL(fileURLWithPath:CommandLine.arguments[0]).deletingLastPathComponent().appendingPathComponent("trip-registry-conversion").path
    func call(_ args: [String], status: Int32 = 0) throws -> String {
        let p = Process(); p.executableURL = URL(fileURLWithPath:executable); p.arguments = args
        let output = Pipe(); p.standardOutput = output; p.standardError = output
        try p.run(); let bytes = output.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
        let text = String(decoding:bytes,as:UTF8.self)
        try require(p.terminationStatus == status)
        let forbidden = ["INVENTED_PRIVATE", "INVENTED_PUBLISHER", "INVENTED_LOCATOR", "fixture.trip-feed", "trp_", "stn_", "lin_", "opr_", dir, "Traceback", "Fatal error"]
        for value in forbidden { try require(!text.contains(value)) }
        return text
    }
    var common = [String]()
    for key in ["registry","history","checkpoint","context","correspondence","dependencies"] {
        let b = try Data(contentsOf:URL(fileURLWithPath:dir + "/" + key))
        common += ["--" + key,dir + "/" + key,"--" + key + "-sha256",Codec.hash(b)]
    }
    common += ["--owner",Fixtures.owner]
    let location = ["--workspace",l.workspace,"--operation-id",l.operationID,"--workspace-id",l.workspaceID,"--output-id",l.outputID,"--output",l.output]
    try check("registration CLI production RNG prepare invented") { try require(call(["prepare-registration"] + common + location).hasPrefix("prepared approved=false")) }
    let bytes = try Data(contentsOf:URL(fileURLWithPath:l.workspace + "/request.json")), q = try Registration.read(bytes,limit:Limits.request)
    let request = ["--request",l.workspace + "/request.json","--request-sha256",Codec.hash(bytes)]
    try check("registration CLI prepared reopen") { try require(call(["prepare-registration"] + common + location).hasPrefix("preparedReplay")) }
    try check("registration CLI inspect explicitly unapproved") { try require(call(["inspect-registration"] + common + request).contains("approved=false")) }
    let approvalPath = dir + "/approval.json"
    try check("registration CLI explicit separate approval") {
        _ = try call(["approve-registration"] + request + ["--owner",Fixtures.owner,"--review-id",q["context"]["workflow"]["approvalReviewID"].text,"--author","fixture.author","--approved-at",Fixtures.time,"--approval-reference","fixture.review","--output",approvalPath])
    }
    let a = try Data(contentsOf:URL(fileURLWithPath:approvalPath)), approval = ["--approval",approvalPath,"--approval-sha256",Codec.hash(a)]
    try check("registration CLI missing approval held") { _ = try call(["apply-registration"] + common + location + request + ["--approval",dir + "/missing","--approval-sha256",Fixtures.hash],status:3) }
    try check("registration CLI apply RNGfree") { try require(call(["apply-registration"] + common + location + request + approval).hasPrefix("registered")) }
    let m = try Data(contentsOf:URL(fileURLWithPath:l.output + "/manifest.json"))
    try check("registration CLI verify closure") { _ = try call(["verify-registration-bundle","--bundle",l.output,"--manifest-sha256",Codec.hash(m),"--owner",Fixtures.owner]) }
    var current = [String]()
    for key in ["registry","history","checkpoint"] {
        let file = l.output + "/" + (key == "checkpoint" ? "manifest" : key) + ".json", b = try Data(contentsOf:URL(fileURLWithPath:file))
        current += ["--" + key,file,"--" + key + "-sha256",Codec.hash(b)]
    }
    for key in ["context","correspondence","dependencies"] { let b = try Data(contentsOf:URL(fileURLWithPath:dir + "/" + key)); current += ["--" + key,dir + "/" + key,"--" + key + "-sha256",Codec.hash(b)] }
    current += ["--owner",Fixtures.owner]
    try check("registration CLI retained replay") { try require(call(["apply-registration"] + current + location + request + approval).hasPrefix("unchangedReplay")) }
    try check("registration CLI prepared reopen after commit same candidate") { try require(call(["prepare-registration"] + common + location).hasPrefix("preparedReplay")) }
    try check("registration CLI old predecessor cannot republish") { _ = try call(["apply-registration"] + common + location + request + approval,status:2) }
    try check("conversion command rejects registration request") { _ = try call(["inspect"] + request + ["--owner",Fixtures.owner],status:2) }
    try check("conversion verify rejects registration manifest") { _ = try call(["verify-bundle","--bundle",l.output,"--manifest-sha256",Codec.hash(m),"--owner",Fixtures.owner],status:2) }
    try check("registration CLI deterministic injection unavailable") { _ = try call(["prepare-registration"] + common + location + ["--rng-seed","INVENTED_PRIVATE_SECRET"],status:2) }
    try check("registration CLI caller secret unknown command safe") { _ = try call(["INVENTED_PRIVATE_SECRET","--owner",Fixtures.owner],status:2) }
    let symlink = dir + "/symlink-context"; try FileManager.default.createSymbolicLink(atPath:symlink,withDestinationPath:dir + "/context")
    let unsafe = common.map { $0 == dir + "/context" ? symlink : $0 }
    try check("registration CLI unsafe input safe fixed error") { _ = try call(["prepare-registration"] + unsafe + location,status:2) }
    try check("production binary excludes deterministic test hook symbols") {
        let p = Process(); p.executableURL = URL(fileURLWithPath:"/usr/bin/nm"); p.arguments = [executable]
        let output = Pipe(); p.standardOutput = output; p.standardError = output
        try p.run(); let text = String(decoding:output.fileHandleForReading.readDataToEndOfFile(),as:UTF8.self); p.waitUntilExit()
        try require(p.terminationStatus == 0)
        for name in ["mintForTest","prepareForTest","publishForTest"] { try require(!text.contains(name)) }
    }
}
