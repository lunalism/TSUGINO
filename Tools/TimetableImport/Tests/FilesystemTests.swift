import Foundation
import Darwin

func filesystem(_ i: Wire, _ q: Wire, _ a: Wire, _ b: ImportAuthority.Bundle, _ imported: Wire, _ e: ImportAuthority.External) throws {
    let dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let bundlePath = dir + "/bundle"
    for point in ["write:facts.json","write:history.json","write:manifest.json","rename"] {
        try rejects("precommit publication " + point) { try ImportIO.publishForTest(b,path:bundlePath,external:e,failAt:point) }
        try test("precommit no partial publication " + point) { try expect(!FileManager.default.fileExists(atPath:bundlePath)); try expect(FileManager.default.contentsOfDirectory(atPath:dir).isEmpty) }
    }
    try test("postcommit uncertainty retains complete verifiable bundle") {
        do { try ImportIO.publishForTest(b,path:bundlePath,external:e,failAt:"parentFsync"); throw TestFailure.assertion }
        catch ConversionFailure.durabilityUncertain {}
        let retained = try ImportIO.readBundle(bundlePath,external:e,manifestSHA:Codec.hash(b.manifest)); try expect(retained.files == b.files)
    }
    try rejects("exclusive publication refuses overwrite") { try ImportIO.publish(b,path:bundlePath,external:e) }
    try test("read-only replay same output") {
        let replay = try ImportAuthority.apply(q,approval:nil,currentState:imported,external:e)
        try ImportIO.publish(replay,path:bundlePath,external:e)
    }
    try rejects("replay cannot fork into absent output") {
        let replay = try ImportAuthority.apply(q,approval:nil,currentState:imported,external:e)
        try ImportIO.publish(replay,path:dir + "/fork",external:e)
    }
    try test("private modes") {
        var s = stat(); try expect(lstat(bundlePath,&s) == 0 && s.st_mode & 0o7777 == 0o700)
        for name in ImportIO.fileLimits.keys { try expect(lstat(bundlePath + "/" + name,&s) == 0 && s.st_mode & 0o7777 == 0o600 && s.st_nlink == 1 && s.st_uid == getuid()) }
    }
    try test("bundle extra directory entry rejected within fixed inventory bound") {
        try ImportIO.write(bundlePath + "/invented-extra",bytes:Data("INVENTED EXTRA".utf8),limit:1024)
        do { _ = try ImportIO.readBundle(bundlePath,external:e,manifestSHA:Codec.hash(b.manifest)); throw TestFailure.assertion }
        catch ConversionFailure.unsafePath {}
    }
    let file = dir + "/private.json", bytes = try Codec.encode(i)
    try ImportIO.write(file,bytes:bytes,limit:ImportLimits.input)
    try test("stable exact pinned private read") { try expect(try ImportIO.read(file,sha:Codec.hash(bytes),limit:ImportLimits.input) == bytes) }
    try rejects("wrong digest") { _ = try ImportIO.read(file,sha:String(repeating:"f",count:64),limit:ImportLimits.input) }
    try rejects("file overwrite") { try ImportIO.write(file,bytes:bytes,limit:ImportLimits.input) }
    let linkPath = dir + "/alias.json"
    try expect(symlink(file,linkPath) == 0)
    try rejects("symlink read") { _ = try ImportIO.read(linkPath,sha:Codec.hash(bytes),limit:ImportLimits.input) }
    try rejects("symlink parent") { _ = try ImportIO.read("/tmp/" + URL(fileURLWithPath:dir).lastPathComponent + "/private.json",sha:Codec.hash(bytes),limit:ImportLimits.input) }
    let hard = dir + "/hard.json"; try expect(link(file,hard) == 0)
    try rejects("hard link read") { _ = try ImportIO.read(file,sha:Codec.hash(bytes),limit:ImportLimits.input) }
    unlink(hard)
    chmod(file,0o644)
    try rejects("permissive file read") { _ = try ImportIO.read(file,sha:Codec.hash(bytes),limit:ImportLimits.input) }
    chmod(file,0o600)
    try rejects("repository output") { try ImportIO.write(URL(fileURLWithPath:#filePath).deletingLastPathComponent().appendingPathComponent("forbidden.json").path,bytes:bytes,limit:ImportLimits.input) }
    // Full production CLI workflow. Every artifact and S9 dependency here is invented.
    let s9Path = dir + "/s9"; try S9IO.publish(.init(files:e.s9.files,replay:false),path:s9Path,owner:e.owner)
    func save(_ name: String, _ data: Data) throws -> [String] {
        let path = dir + "/" + name
        try ImportIO.write(path,bytes:data,limit:ImportLimits.state)
        return [path,Codec.hash(data)]
    }
    let review = try save("review.json",e.review), input = try save("input.json",bytes), state = try save("state.json",Codec.encode(ImportFixtures.state(i)))
    let approvalPath = dir + "/profile-approval.json"
    try test("CLI profile approval materialization invented only") {
        let r = try command(["approve-profile-review","--owner",e.owner,"--profile-review",review[0],"--profile-review-sha256",review[1],"--profile-id",ImportFixtures.profile,
            "--review-id",ImportFixtures.reviewID,"--reviewer","invented.profile-reviewer","--approved-at",Fixtures.time,"--approval-reference","invented.profile-approval","--output",approvalPath])
        try expect(r.0 == 0 && r.1.hasPrefix("profileApprovalCreated"))
        try expect(try ImportIO.read(approvalPath,sha:Codec.hash(e.approval),limit:ImportLimits.approval) == e.approval)
    }
    let common = ["--owner",e.owner,"--s9-bundle",s9Path,"--s9-manifest-sha256",Codec.hash(e.s9.manifest),"--profile-review",review[0],"--profile-review-sha256",review[1],
        "--profile-approval",approvalPath,"--profile-approval-sha256",Codec.hash(e.approval)]
    let requestPath = dir + "/request.json", importApprovalPath = dir + "/import-approval.json"
    let qFlags = ["--request",requestPath,"--request-sha256",try Codec.digest(q)]
    try test("CLI prepare active request") {
        let r = try command(["prepare-import"] + common + ["--input",input[0],"--input-sha256",input[1],"--state",state[0],"--state-sha256",state[1],
            "--request-id","invented.import-request","--approval-review-id","invented.import-review","--output-id","invented.import-output","--output",requestPath])
        try expect(r.0 == 0 && r.1.hasPrefix("prepared approved=false"))
    }
    try test("CLI inspect privacy-safe aggregate result") {
        let r = try command(["inspect-import"] + common + qFlags)
        try expect(r.0 == 0 && r.1.trimmingCharacters(in:.whitespacesAndNewlines) == "requestValid approved=false visits=14 exact=28 estimated=0 missing=0")
        for privateValue in [i["tripID"].text,i["service"].text,i["run"].text,dir,"11:00:07"] { try expect(!r.1.contains(privateValue)) }
    }
    try test("CLI import approval distinct") {
        let r = try command(["approve-import"] + common + qFlags + ["--reviewer","invented.import-reviewer","--approved-at",Fixtures.time,"--approval-reference","invented.import-approval","--output",importApprovalPath])
        try expect(r.0 == 0 && r.1.hasPrefix("importApprovalCreated"))
    }
    let applyFlags = common + qFlags + ["--state",state[0],"--state-sha256",state[1],"--approval",importApprovalPath,"--approval-sha256",try Codec.digest(a)]
    let cliBundle = dir + "/cli-bundle"
    try test("CLI apply and verify") {
        let r = try command(["apply-import"] + applyFlags + ["--output",cliBundle]); try expect(r.0 == 0 && r.1.hasPrefix("occurrenceImported"))
        let v = try command(["verify-import-bundle"] + common + ["--bundle",cliBundle,"--manifest-sha256",Codec.hash(b.manifest)])
        try expect(v.0 == 0 && v.1.hasPrefix("bundleValid unchangedReplay"))
    }
    let savedState = try save("imported-state.json",Codec.encode(imported))
    try test("CLI replay without fresh approval") {
        let r = try command(["apply-import"] + common + qFlags + ["--state",savedState[0],"--state-sha256",savedState[1],"--output",cliBundle])
        try expect(r.0 == 0 && r.1.hasPrefix("unchangedReplay"))
    }
    try test("same-path concurrent processes one atomic winner") {
        let target = dir + "/race-bundle", processes = [Process(),Process()], outputs = [Pipe(),Pipe()]
        for n in 0..<2 {
            processes[n].executableURL = URL(fileURLWithPath:CommandLine.arguments[1]); processes[n].arguments = ["apply-import"] + applyFlags + ["--output",target]
            processes[n].standardOutput = outputs[n]; processes[n].standardError = outputs[n]; try processes[n].run()
        }
        for n in 0..<2 { _ = outputs[n].fileHandleForReading.readDataToEndOfFile(); processes[n].waitUntilExit() }
        try expect(processes.filter { $0.terminationStatus == 0 }.count == 1)
        _ = try ImportIO.readBundle(target,external:e,manifestSHA:Codec.hash(b.manifest))
    }
    try test("CLI inactive creates no request") {
        let inactive = i.replacing("serviceDate",.string("2041-05-10"))
        let ii = try save("inactive.json",Codec.encode(inactive)), ss = try save("inactive-state.json",Codec.encode(ImportFixtures.state(inactive))), output = dir + "/inactive-request"
        let r = try command(["prepare-import"] + common + ["--input",ii[0],"--input-sha256",ii[1],"--state",ss[0],"--state-sha256",ss[1],
            "--request-id","invented.inactive-request","--approval-review-id","invented.inactive-review","--output-id","invented.inactive-output","--output",output])
        try expect(r.0 == 0 && r.1.trimmingCharacters(in:.whitespacesAndNewlines) == "status=inactive" && !FileManager.default.fileExists(atPath:output))
    }
    for args in [["unknown","--owner",e.owner],["inspect-import","--owner",e.owner,"--owner",e.owner],["inspect-import","--owner",e.owner,"--unknown",dir]] {
        try test("CLI rejects unknown duplicate missing options privately") { let r = try command(args); try expect(r.0 != 0 && !r.1.contains(dir)) }
    }
    try test("fixed unexpected-error diagnostics") { try expect(ImportCLI.failure(NSError(domain:"INVENTED PRIVATE VALUE",code:1)) == "rejected status=invalidStructure") }
}
