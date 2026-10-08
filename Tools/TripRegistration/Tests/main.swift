import Foundation
import Darwin

enum Assertion: Error { case failed }
var cases = 0
func require(_ b: @autoclosure () throws -> Bool) throws { guard try b() else { throw Assertion.failed } }
func check(_ name: String, _ body: () throws -> Void) throws {
    do { try body(); cases += 1 } catch { print("FAIL " + name); throw error }
}
func fails(_ name: String, _ expected: ConversionFailure? = nil, _ body: () throws -> Void) throws {
    try check(name) {
        do { try body(); throw Assertion.failed }
        catch let f as ConversionFailure { if let expected { try require(f == expected) } else { try require(!f.held) } }
    }
}
func encode(_ v: Wire) throws -> Data { try Codec.encode(v) }
func targetRequest(_ s: Fixtures.Scenario, _ target: Wire) throws -> (Wire,Wire) {
    let b = try Codec.encode(target,pretty:true)
    let q = s.request.replacing("targetRegistryBytes",Codec.blob(b)).replacing("targetRegistrySHA256",.string(Codec.hash(b)))
    return (q,try Conversion.approval(q,owner:Fixtures.owner,reviewID:"fixture.conversion-approval",author:"fixture.author",at:Fixtures.time,reference:"fixture.review"))
}
func happy() throws {
    let s = try Fixtures.scenario(complex:true), b = try s.apply(), p = try Registry4.legacy(s.registry), t = try Registry4.read(b.registry)
    try check("minimal conversion") { let m = try Fixtures.scenario(); try require(try Registry4.read(m.apply().registry)["revision"].int == 7) }
    try check("complex conversion revision") { try require(t["schemaVersion"].int == 4 && t["revision"].int == 7) }
    try check("all entities exact") { try require(Codec.equal(p["entities"],t["entities"])) }
    try check("all reference fields exact") { try require(Codec.equal(p["references"],t["references"])) }
    try check("eight namespaces") { try require(Set(t["references"].list.map { $0["namespace"].text }) == Set(ProviderNamespace.allCases.map(\.rawValue))) }
    try check("nil and retained attachment") { try require(t["references"].list.contains { !$0.has("attachedBy") }); try require(t["references"].list.contains { $0.has("attachedBy") }) }
    try check("active absent retired references") { try require(Set(t["references"].list.map { $0["status"]["state"].text }) == ["active","absent","retired"]) }
    try check("retired successors retained") { try require(t["entities"].list.contains { $0["state"].text == "retired" && $0["successors"].list.count == 1 }) }
    try check("deterministic registry history manifest") { let n = try s.apply(); try require(n.files == b.files) }
    try check("legacy original bytes retained") { let h = try Codec.read(b.history,limit:Limits.history); try require(h["baseline"]["payload"]["registryBytes"].blob == s.registry); try require(h["boundaries"].list[0]["previousRegistryBytes"].blob == s.registry) }
    try check("valid legacy whitespace retained") {
        let raw = Data(" \n".utf8) + s.registry + Data("\n".utf8)
        let root = try Fixtures.approvedBaseline(raw), h = try encode(Conversion.initialHistory(root)), pin = try Conversion.pin(raw,h,lineage:Fixtures.lineage)
        let q = try Conversion.prepare(raw,history:h,current:pin,owner:Fixtures.owner,requestID:"fixture.whitespace")
        let a = try Conversion.approval(q,owner:Fixtures.owner,reviewID:"fixture.whitespace-review",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        let n = try Conversion.apply(raw,history:h,current:pin,request:q,approval:a,owner:Fixtures.owner)
        try require(n.registry == b.registry)
        try require(try Codec.read(n.history,limit:Limits.history)["baseline"]["payload"]["registryBytes"].blob == raw)
    }
    try check("manifest authoritative byte digests") {
        let m = try Codec.read(b.manifest,limit:Limits.request), h = try Codec.read(b.history,limit:Limits.history)
        try require(m["target"]["registrySHA256"].text == Codec.hash(b.registry) && m["target"]["historySHA256"].text == Codec.hash(b.history))
        try require(m["requestSHA256"].text == Codec.digest(s.request)); try require(m["approvalSHA256"].text == Codec.digest(s.approval))
        try require(m["boundarySHA256"].text == Codec.digest(h["boundaries"].list[0]))
    }
    try check("schema2 runtime remains closed") {
        do { _ = try MappingRegistry.decoded(from:b.registry); throw Assertion.failed } catch is DecodingError {}
        try require(MintedIdentifier(Fixtures.id("trp","4")) == nil && ProviderNamespace(rawValue:"gtfs.trip_id") == nil)
    }
}
func codecs() throws {
    let s = try Fixtures.scenario(complex:true), t = try Registry4.read(s.request["targetRegistryBytes"].blob)
    for v in ["TRP_0000000000000000","trp_iiiiiiiiiiiiiiii","trp_000","bad_0000000000000000"] {
        try fails("identifier rejects " + String(v.count)) { _ = try Registry4.kind(.string(v)) }
    }
    try check("schema4 recognizes fixed invented Trip form") { try require(Registry4.kind(.string(Fixtures.id("trp","4"))) == "trp") }
    for n in [3,4,5] { try fails("unsupported predecessor " + String(n),.unsupportedVersion) { _ = try Registry4.legacy(Codec.encode(t.replacing("schemaVersion",.integer(n)),pretty:true)) } }
    for v: Wire in [.null,.bool(true),.string("2")] { try fails("malformed schema") { _ = try Registry4.legacy(Codec.encode(t.replacing("schemaVersion",v),pretty:true)) } }
    try fails("fractional schema") { _ = try Registry4.legacy(Data("{\"schemaVersion\":2.5}".utf8)) }
    try fails("duplicate decoded JSON key") { _ = try Codec.read(Data("{\"x\":1,\"\\u0078\":2}".utf8),limit:100) }
    try fails("invalid utf8") { _ = try Codec.read(Data([255]),limit:10) }
    try fails("noncanonical newformat") { _ = try Codec.read(Data(" {}".utf8),limit:10) }
    for v: Wire in [.string(""),.integer(1),.null] {
        try fails("invalid attachedBy") { try Registry4.reference(t["references"].list[0].replacing("attachedBy",v)) }
    }
    try fails("unknown field") { try Registry4.validate(t.replacing("surprise",.bool(true))) }
    try fails("active successor field") { try Registry4.validate(t.replacing("entities",.array([Fixtures.entity("stn","0").replacing("successors",.array([]))]))) }
    try fails("duplicate entity") { try Registry4.validate(t.replacing("entities",.array(t["entities"].list + [t["entities"].list[0]]))) }
    for next in [Fixtures.id("stn","1"),Fixtures.id("stn","9"),Fixtures.id("lin","2")] {
        let bad = Fixtures.entity("stn","1").replacing("state",.string("retired")).replacing("successors",.array([.string(next)]))
        try fails("bad successor graph") { try Registry4.validate(t.replacing("entities",.array(t["entities"].list.map { $0["id"].text == bad["id"].text ? bad : $0 }))) }
    }
    try fails("schema2 unknown field") { _ = try Registry4.legacy(Codec.encode(try Registry4.legacy(s.registry).replacing("surprise",.bool(true)),pretty:true)) }
    try fails("schema4 bad namespace kind") { try Registry4.reference(t["references"].list[0].replacing("namespace",.string("gtfs.trip_id"))) }
    try check("scalar distinct values remain two keys") {
        let r = t["references"].list[0]
        let a = r.replacing("value",.string("FIXTURE_é")), b = r.replacing("value",.string("FIXTURE_e\u{301}"))
        try require(try Registry4.key(a) != Registry4.key(b))
        let both = [a,b].sorted(by:Registry4.less)
        try Registry4.validate(t.replacing("references",.array(both)))
    }
}
func histories() throws {
    let s = try Fixtures.scenario(complex:true), h = try Codec.read(s.history,limit:Limits.history), root = h["baseline"], p = root["payload"]
    try check("complete root authority closure") { _ = try Conversion.baseline(root,owner:Fixtures.owner) }
    try fails("missing root approval",.historyUnavailable) { _ = try Conversion.baseline(.object(["payload":p]),owner:Fixtures.owner) }
    try fails("explicit incomplete history",.historyUnavailable) { _ = try Conversion.baseline(Fixtures.resign(p.replacing("historyComplete",.bool(false))),owner:Fixtures.owner) }
    try fails("missing retained bytes",.historyUnavailable) {
        let rows = p["records"].list.map { $0.replacing("bytes",nil) }
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("missing allocation coverage",.historyUnavailable) {
        let rows = p["records"].list.map { $0.replacing("heldIdentifiers",.array([])) }
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("missing review coverage",.historyUnavailable) {
        let rows = p["records"].list.map { $0.replacing("reviewIDs",.array([])) }
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("missing required review inventory",.historyUnavailable) {
        let rows = p["records"].list.map { $0.replacing("reviewIDs",.array([])) }
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("reviewIDs",.array([])).replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("changed original authority bytes",.historyConflict) {
        var rows = p["records"].list; rows[0] = rows[0].replacing("bytes",Codec.blob(Data("changed".utf8)))
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("known conflict wins over missing bytes",.historyConflict) {
        var rows = p["records"].list; rows[0] = rows[0].replacing("bytes",nil); rows[1] = rows[1].replacing("bytes",Codec.blob(Data("changed".utf8)))
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("owner mismatch even missing approval",.approvalConflict) { _ = try Conversion.baseline(.object(["payload":p.replacing("ownerAuthority",.string("fixture.other-owner"))]),owner:Fixtures.owner) }
    try fails("sidecar not silently fabricated",.historyConflict) { _ = try Conversion.baseline(Fixtures.resign(p.replacing("legacyHistoryState",.string("present"))),owner:Fixtures.owner) }
    try fails("root content changed under old approval",.approvalConflict) { _ = try Conversion.baseline(root.replacing("payload",p.replacing("historyComplete",.bool(false))),owner:Fixtures.owner) }
    try fails("retained allocation inventory changed",.historyConflict) { _ = try Conversion.baseline(Fixtures.resign(p.replacing("heldIdentifiers",.array([]))),owner:Fixtures.owner) }
    try fails("declared missing dependency",.historyUnavailable) {
        let pins = p["dependencyDigests"].list + [.object(["id":.string("fixture.z-missing"),"sha256":.string(Fixtures.hash)])]
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("dependencyDigests",.array(pins))),owner:Fixtures.owner)
    }
    try check("legacy explicit no allocation-request tokens") {
        let rows = p["records"].list.map { $0.replacing("allocationIDs",.array([])) }
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("allocationIDs",.array([])).replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("missing retained allocation tokens",.historyUnavailable) {
        let rows = p["records"].list.map { $0.replacing("allocationIDs",.array([])) }
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("dependent digest mismatch",.historyConflict) {
        var rows = p["records"].list
        rows[0] = rows[0].replacing("dependencyDigests",.array([.object(["id":rows[1]["id"],"sha256":.string(Fixtures.hash)])]))
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("incomplete baseline cannot mask conflicting boundary",.historyConflict) {
        let b = try s.apply(), completed = try Codec.read(b.history,limit:Limits.history)
        let incomplete = try Fixtures.resign(p.replacing("historyComplete",.bool(false)))
        var boundaries = completed["boundaries"].list
        boundaries[0] = boundaries[0].replacing("requestSHA256",.string(Fixtures.hash))
        let bad = completed.replacing("baseline",incomplete).replacing("baselineSHA256",.string(try Codec.digest(incomplete))).replacing("boundaries",.array(boundaries))
        _ = try Conversion.history(encode(bad),owner:Fixtures.owner)
    }
    try fails("dependency cycle",.historyConflict) {
        var rows = p["records"].list
        rows[0] = rows[0].replacing("dependencyDigests",.array([.object(["id":rows[1]["id"],"sha256":rows[1]["sha256"]])]))
        rows[1] = rows[1].replacing("dependencyDigests",.array([.object(["id":rows[0]["id"],"sha256":rows[0]["sha256"]])]))
        _ = try Conversion.baseline(Fixtures.resign(p.replacing("records",.array(rows))),owner:Fixtures.owner)
    }
    try fails("missing entire history",.resourceLimit) { _ = try Conversion.history(Data(),owner:Fixtures.owner) }
}
func requests() throws {
    let s = try Fixtures.scenario(complex:true), t = try Registry4.read(s.request["targetRegistryBytes"].blob)
    try fails("unapproved request",.approvalMissing) { _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:s.request,approval:.null,owner:Fixtures.owner) }
    try fails("missing approval cannot mask target mutation",.identityConflict) {
        let (q,_) = try targetRequest(s,t.replacing("references",.array(t["references"].list.map { $0.replacing("originalNames",.array([])) })))
        _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:q,approval:.null,owner:Fixtures.owner)
    }
    try fails("missing approval cannot mask history hash conflict",.staleCheckpoint) {
        _ = try Conversion.apply(s.registry,history:s.history,current:s.current.replacing("historySHA256",.string(Fixtures.hash)),request:s.request,approval:.null,owner:Fixtures.owner)
    }
    let root = try Codec.read(s.history,limit:Limits.history)["baseline"]["payload"]
    let incomplete = try encode(Conversion.initialHistory(Fixtures.resign(root.replacing("historyComplete",.bool(false)))))
    let incompletePin = try Conversion.pin(s.registry,incomplete,lineage:Fixtures.lineage)
    let incompleteRequest = s.request.replacing("expectedPrevious",incompletePin)
    try fails("incomplete root cannot mask incoming business mutation",.identityConflict) {
        let changed = try Codec.encode(t.replacing("references",.array(t["references"].list.map { $0.replacing("originalNames",.array([])) })),pretty:true)
        let q = incompleteRequest.replacing("targetRegistryBytes",Codec.blob(changed)).replacing("targetRegistrySHA256",.string(Codec.hash(changed)))
        _ = try Conversion.apply(s.registry,history:incomplete,current:incompletePin,request:q,approval:.null,owner:Fixtures.owner)
    }
    try fails("incomplete root cannot mask incoming owner conflict",.approvalConflict) {
        _ = try Conversion.apply(s.registry,history:incomplete,current:incompletePin,request:incompleteRequest.replacing("ownerAuthority",.string("fixture.other-owner")),approval:.null,owner:Fixtures.owner)
    }
    try fails("approval digest mismatch",.approvalConflict) { _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:s.request,approval:s.approval.replacing("payloadSHA256",.string(Fixtures.hash)),owner:Fixtures.owner) }
    for bad in ["2001-01-01T00:00:00.1Z","2001-01-01T00:00:00+00:00","not-a-time"] { try fails("strict timestamp") { try Conversion.checkApproval(s.approval.replacing("approvedAt",.string(bad)),s.request,owner:Fixtures.owner) } }
    for field in ["TripID","correspondence","records","snapshotArtifactID"] { try fails("disallowed request field") { try Conversion.checkRequest(s.request.replacing(field,.string("fixture"))) } }
    try fails("expected target hash mismatch",.staleCheckpoint) { try Conversion.checkRequest(s.request.replacing("targetRegistrySHA256",.string(Fixtures.hash))) }
    try fails("retained allocation request ID cannot be reused",.staleCheckpoint) {
        let q = s.request.replacing("requestID",.string("fixture.original-allocation-request"))
        let a = try Conversion.approval(q,owner:Fixtures.owner,reviewID:"fixture.new-review",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:q,approval:a,owner:Fixtures.owner)
    }
    try fails("retained review ID cannot be reused",.staleCheckpoint) {
        let a = try Conversion.approval(s.request,owner:Fixtures.owner,reviewID:"fixture.attachment",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:s.request,approval:a,owner:Fixtures.owner)
    }
    try fails("predecessor hash mismatch",.staleCheckpoint) { _ = try Conversion.apply(s.registry,history:s.history,current:s.current.replacing("registrySHA256",.string(Fixtures.hash)),request:s.request,approval:s.approval,owner:Fixtures.owner) }
    try fails("predecessor revision mismatch",.staleCheckpoint) { _ = try Conversion.apply(s.registry,history:s.history,current:s.current.replacing("revision",.integer(5)),request:s.request,approval:s.approval,owner:Fixtures.owner) }
    var mutated: [(String,Wire)] = [
        ("target revision",t.replacing("revision",.integer(8))),
        ("removed entity",t.replacing("entities",.array(Array(t["entities"].list.dropLast())))),
        ("new entity",t.replacing("entities",.array(t["entities"].list + [Fixtures.entity("stn","9")]))),
        ("removed reference",t.replacing("references",.array(Array(t["references"].list.dropLast())))),
        ("dropped reference field",t.replacing("references",.array([t["references"].list[0].replacing("provenance",nil)])))]
    for field in ["value","attachedBy","firstSeenInputSHA256","originalNames","provenance","status"] {
        var refs = t["references"].list
        let value: Wire = field == "originalNames" ? .array([]) : field == "status" ? .object(["state":.string("absent")]) : field == "provenance" ? refs[0][field].replacing("field",.string("altered")) : .string(field == "firstSeenInputSHA256" ? String(repeating:"2",count:64) : "FIXTURE_CHANGED")
        refs[0] = refs[0].replacing(field,value); refs.sort(by:Registry4.less)
        mutated.append(("reference mutation " + field,t.replacing("references",.array(refs))))
    }
    for (name,bad) in mutated {
        try fails(name) {
            let (q,a) = try targetRequest(s,bad)
            _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:q,approval:a,owner:Fixtures.owner)
        }
    }
    let trip = Fixtures.entity("trp","4")
    try fails("Trip entity conversion blocked",.identityConflict) {
        let (q,a) = try targetRequest(s,t.replacing("entities",.array(t["entities"].list + [trip])))
        _ = try Conversion.apply(s.registry,history:s.history,current:s.current,request:q,approval:a,owner:Fixtures.owner)
    }
    try fails("Trip source reference conversion blocked",.identityConflict) {
        let ref = t["references"].list.first { $0["namespace"].text == "gtfs.agency_id" }!
            .replacing("canonicalID",trip["id"]).replacing("namespace",.string("gtfs.trip_id")).replacing("attachedBy",.string("fixture.trip-review"))
        let next = t.replacing("entities",.array(t["entities"].list + [trip])).replacing("references",.array((t["references"].list + [ref]).sorted(by:Registry4.less)))
        try Registry4.validate(next)
        try Conversion.checkRequest(targetRequest(s,next).0)
    }
}
func replays() throws {
    let s = try Fixtures.scenario(), b = try s.apply(), pin = try Conversion.pin(b.registry,b.history,lineage:Fixtures.lineage)
    let replay = try Conversion.apply(b.registry,history:b.history,current:pin,request:s.request,approval:s.approval,owner:Fixtures.owner)
    try check("unchanged replay exact bytes") { try require(replay.replay && replay.files == b.files) }
    try check("replay one boundary revision seven") { try require(try Codec.read(replay.history,limit:Limits.history)["boundaries"].list.count == 1); try require(Registry4.read(replay.registry)["revision"].int == 7) }
    try fails("replay old checkpoint",.staleCheckpoint) { _ = try Conversion.apply(b.registry,history:b.history,current:s.current,request:s.request,approval:s.approval,owner:Fixtures.owner) }
    try fails("replay changed predecessor",.staleCheckpoint) { _ = try Conversion.apply(s.registry,history:b.history,current:pin,request:s.request,approval:s.approval,owner:Fixtures.owner) }
    try fails("replay changed history") { let h = try Codec.read(b.history,limit:Limits.history).replacing("baselineSHA256",.string(Fixtures.hash)); _ = try Conversion.apply(b.registry,history:encode(h),current:pin,request:s.request,approval:s.approval,owner:Fixtures.owner) }
    try fails("replay changed approval",.staleCheckpoint) { _ = try Conversion.apply(b.registry,history:b.history,current:pin,request:s.request,approval:s.approval.replacing("author",.string("fixture.other-author")),owner:Fixtures.owner) }
    try fails("replay changed request under old approval",.approvalConflict) { _ = try Conversion.apply(b.registry,history:b.history,current:pin,request:s.request.replacing("requestID",.string("fixture.changed-request")),approval:s.approval,owner:Fixtures.owner) }
    try fails("replay changed request with fresh approval",.staleCheckpoint) {
        let q = s.request.replacing("requestID",.string("fixture.changed-request"))
        let a = try Conversion.approval(q,owner:Fixtures.owner,reviewID:"fixture.other-approval",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        _ = try Conversion.apply(b.registry,history:b.history,current:pin,request:q,approval:a,owner:Fixtures.owner)
    }
    try fails("no next conversion from schema4",.staleCheckpoint) { _ = try Conversion.prepare(b.registry,history:b.history,current:pin,owner:Fixtures.owner,requestID:"fixture.next") }
    try fails("duplicate retained boundary",.resourceLimit) { let h = try Codec.read(b.history,limit:Limits.history); _ = try Conversion.history(encode(h.replacing("boundaries",.array(h["boundaries"].list + h["boundaries"].list))),owner:Fixtures.owner) }
    try fails("null retained boundary approval malformed",.malformedInput) {
        let h = try Codec.read(b.history,limit:Limits.history)
        _ = try Conversion.history(encode(h.replacing("boundaries",.array([h["boundaries"].list[0].replacing("approval",.null)]))),owner:Fixtures.owner)
    }
    try fails("mutated manifest") { let m = try Codec.read(b.manifest,limit:Limits.request); _ = try Conversion.verify(b.registry,b.history,encode(m.replacing("boundarySHA256",.string(Fixtures.hash))),owner:Fixtures.owner) }
}
func publication() throws {
    let dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let s = try Fixtures.scenario(complex:true), b = try s.apply(), original = dir + "/original.json"
    try Fixtures.write(original,s.registry)
    for stage in ["write:history.json","write:manifest.json","write:registry.json","rename"] {
        try fails("atomic injected " + stage,.publicationFailure) {
            try PrivateIO.publishForTest(b,to:dir + "/failed",owner:Fixtures.owner,failAt:stage)
        }
        try check("failure predecessor and staging preserved " + stage) {
            try require(!FileManager.default.fileExists(atPath:dir + "/failed"))
            try require(Data(contentsOf:URL(fileURLWithPath:original)) == s.registry)
            try require(!FileManager.default.contentsOfDirectory(atPath:dir).contains { $0.hasPrefix(".conversion-stage-") })
        }
    }
    try check("atomic private bundle success") {
        try PrivateIO.publish(b,to:dir + "/accepted",owner:Fixtures.owner)
        let accepted = try PrivateIO.readBundle(dir + "/accepted",owner:Fixtures.owner,manifestSHA:Codec.hash(b.manifest))
        try require(accepted.files == b.files)
        var mode = stat(); try require(lstat(dir + "/accepted",&mode) == 0 && mode.st_mode & 0o7777 == 0o700)
        for name in PrivateIO.names { try require(lstat(dir + "/accepted/" + name,&mode) == 0 && mode.st_mode & 0o7777 == 0o600) }
        try require(Data(contentsOf:URL(fileURLWithPath:original)) == s.registry)
    }
    try fails("existing output not overwritten",.publicationConflict) { try PrivateIO.publish(b,to:dir + "/accepted",owner:Fixtures.owner) }
    let replay = try Conversion.apply(b.registry,history:b.history,current:Conversion.pin(b.registry,b.history,lineage:Fixtures.lineage),request:s.request,approval:s.approval,owner:Fixtures.owner)
    try check("replay same published bundle") { try PrivateIO.publish(replay,to:dir + "/accepted",owner:Fixtures.owner) }
    try fails("replay cannot publish new identity") { try PrivateIO.publish(replay,to:dir + "/new-replay",owner:Fixtures.owner) }
    try check("concurrent publication exactly one success") {
        let lock = NSLock(); var successes = 0, conflicts = 0
        DispatchQueue.concurrentPerform(iterations:2) { _ in
            do { try PrivateIO.publish(b,to:dir + "/race",owner:Fixtures.owner); lock.lock(); successes += 1; lock.unlock() }
            catch ConversionFailure.publicationConflict { lock.lock(); conflicts += 1; lock.unlock() }
            catch {}
        }
        try require(successes == 1 && conflicts == 1)
        _ = try PrivateIO.readBundle(dir + "/race",owner:Fixtures.owner,manifestSHA:Codec.hash(b.manifest))
    }
    try fails("relative output",.unsafePath) { try PrivateIO.publish(b,to:"relative",owner:Fixtures.owner) }
    try fails("path escape",.unsafePath) { try PrivateIO.publish(b,to:dir + "/../escape",owner:Fixtures.owner) }
    try fails("public parent",.unsafePath) { try PrivateIO.publish(b,to:"/private/tmp/public-parent",owner:Fixtures.owner) }
    let link = dir + "/link"; try FileManager.default.createSymbolicLink(atPath:link,withDestinationPath:original)
    try fails("input symlink",.unsafePath) { _ = try PrivateIO.read(link,sha256:Codec.hash(s.registry),limit:Limits.registry) }
    let linkDir = dir + "/linked-dir"; try FileManager.default.createSymbolicLink(atPath:linkDir,withDestinationPath:dir)
    try fails("ancestor symlink",.unsafePath) { try PrivateIO.publish(b,to:linkDir + "/bad",owner:Fixtures.owner) }
    chmod(original,0o644)
    try fails("input public mode",.unsafePath) { _ = try PrivateIO.read(original,sha256:Codec.hash(s.registry),limit:Limits.registry) }
    chmod(original,0o600)
    try fails("input hash mismatch",.historyConflict) { _ = try PrivateIO.read(original,sha256:Fixtures.hash,limit:Limits.registry) }
    try fails("missing required file",.historyUnavailable) { _ = try PrivateIO.read(dir + "/missing",sha256:Fixtures.hash,limit:Limits.history) }
}
func bounds() throws {
    try fails("bounded JSON byte count",.resourceLimit) { _ = try Codec.read(Data("{}".utf8),limit:1) }
    try fails("bounded JSON depth",.resourceLimit) { _ = try Codec.read(Data((String(repeating:"[",count:65) + "0" + String(repeating:"]",count:65)).utf8),limit:1000) }
    try fails("bounded record count",.resourceLimit) { try Codec.array(.array(Array(repeating:.null,count:Limits.records+1)),max:Limits.records) }
    try fails("bounded entity count",.resourceLimit) { try Codec.array(.array(Array(repeating:.null,count:Limits.entities+1)),max:Limits.entities) }
    try fails("bounded reference count",.resourceLimit) { try Codec.array(.array(Array(repeating:.null,count:Limits.references+1)),max:Limits.references) }
    try fails("checked revision overflow",.resourceLimit) {
        let r = try Registry4.legacy(Fixtures.legacy()).replacing("revision",.integer(Int.max)); _ = try Registry4.target(Codec.encode(r,pretty:true))
    }
    try fails("fixed optional null rejection") { try Codec.fields(.object(["x":.null]),[],["x"]) }
}
func cli() throws {
    let dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let s = try Fixtures.scenario(complex:true)
    for (name,bytes) in ["registry":s.registry,"history":s.history,"checkpoint":try encode(s.current)] { try Fixtures.write(dir + "/" + name,bytes) }
    let executable = URL(fileURLWithPath:CommandLine.arguments[0]).deletingLastPathComponent().appendingPathComponent("trip-registry-conversion").path
    func call(_ args: [String], status: Int32 = 0) throws -> String {
        let p = Process(); p.executableURL = URL(fileURLWithPath:executable); p.arguments = args
        let output = Pipe(); p.standardOutput = output; p.standardError = output
        try p.run(); let bytes = output.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
        let text = String(decoding:bytes,as:UTF8.self)
        try require(p.terminationStatus == status)
        for forbidden in ["FIXTURE_PROVIDER_","FIXTURE_NAME_","FIXTURE_ROW_",Fixtures.id("stn","0"),dir,"Traceback"] { try require(!text.contains(forbidden)) }
        return text
    }
    let common = ["--registry",dir + "/registry","--registry-sha256",Codec.hash(s.registry),"--history",dir + "/history","--history-sha256",Codec.hash(s.history),"--checkpoint",dir + "/checkpoint","--checkpoint-sha256",try Codec.digest(s.current),"--owner",Fixtures.owner]
    try check("CLI invented prepare") { _ = try call(["prepare-conversion"] + common + ["--request-id","fixture.cli-request","--output",dir + "/request"]) }
    let q = try Data(contentsOf:URL(fileURLWithPath:dir + "/request")), requestArgs = ["--request",dir + "/request","--request-sha256",Codec.hash(q)]
    try check("CLI inspect no approval") { try require(call(["inspect"] + requestArgs + ["--owner",Fixtures.owner]).contains("approved=false")) }
    try check("CLI explicit approve") { _ = try call(["approve"] + requestArgs + ["--owner",Fixtures.owner,"--review-id","fixture.cli-approval","--author","fixture.author","--approved-at",Fixtures.time,"--approval-reference","fixture.review","--output",dir + "/approval"]) }
    let a = try Data(contentsOf:URL(fileURLWithPath:dir + "/approval")), approvalArgs = ["--approval",dir + "/approval","--approval-sha256",Codec.hash(a)]
    try check("CLI invented apply") { try require(call(["apply"] + common + requestArgs + approvalArgs + ["--output",dir + "/bundle"]).hasPrefix("converted")) }
    let m = try Data(contentsOf:URL(fileURLWithPath:dir + "/bundle/manifest.json"))
    try check("CLI verify bundle") { _ = try call(["verify-bundle","--bundle",dir + "/bundle","--manifest-sha256",Codec.hash(m),"--owner",Fixtures.owner]) }
    let r = try Data(contentsOf:URL(fileURLWithPath:dir + "/bundle/registry.json")), h = try Data(contentsOf:URL(fileURLWithPath:dir + "/bundle/history.json"))
    let current = ["--registry",dir + "/bundle/registry.json","--registry-sha256",Codec.hash(r),"--history",dir + "/bundle/history.json","--history-sha256",Codec.hash(h),"--checkpoint",dir + "/bundle/manifest.json","--checkpoint-sha256",Codec.hash(m),"--owner",Fixtures.owner]
    try check("CLI unchanged replay") { try require(call(["apply"] + current + requestArgs + approvalArgs + ["--output",dir + "/bundle"]).hasPrefix("unchangedReplay")) }
    try check("CLI stale output no clobber") { _ = try call(["apply"] + common + requestArgs + approvalArgs + ["--output",dir + "/bundle"],status:2) }
    try check("CLI invalid secret argument safe") { _ = try call(["FIXTURE_PROVIDER_SECRET","--owner",Fixtures.owner],status:2) }
    try check("CLI missing explicit paths") { _ = try call(["prepare-conversion","--owner",Fixtures.owner],status:2) }
    try check("CLI missing approval held") { _ = try call(["apply"] + common + requestArgs + ["--approval",dir + "/missing","--approval-sha256",Fixtures.hash,"--output",dir + "/missing-approval-output"],status:3) }
    try check("CLI predecessor unchanged") { try require(Data(contentsOf:URL(fileURLWithPath:dir + "/registry")) == s.registry) }
}
let suites: [(String,() throws -> Void)] = [("conversion",happy),("codecs",codecs),("history",histories),("requests",requests),("replay",replays),("publication",publication),("bounds",bounds),("CLI",cli)]
do {
    for (name,run) in suites { try run(); print("PASS " + name) }
    print("PASS \(suites.count) functions / \(cases) cases; invented fixtures only")
} catch { print("FAILED standalone conversion tests"); exit(1) }
