import Foundation
import Darwin

struct InventedRNG: RandomNumberGenerator {
    var words: [UInt64], index = 0
    mutating func next() -> UInt64 { defer { index += 1 }; return index < words.count ? words[index] : UInt64.max }
}
func inventedWords(_ body: String) -> [UInt64] {
    var bytes = [UInt8](), buffer: UInt32 = 0, count = 0
    for c in body.utf8 {
        buffer = (buffer << 5) | UInt32(MintedIdentifier.alphabet.firstIndex(of:c)!); count += 5
        if count >= 8 { count -= 8; bytes.append(UInt8(truncatingIfNeeded:buffer >> UInt32(count))) }
    }
    return [bytes.prefix(8).reduce(0) { ($0 << 8) | UInt64($1) }, UInt64(bytes[8]) << 56 | UInt64(bytes[9]) << 48]
}
func registrationGolden() throws {
    let raw = Data(base64Encoded:CorrespondenceGolden.bytes)!, cc = try Codec.read(Data(base64Encoded:CorrespondenceGolden.context)!,limit:Correspondence.limit,canonical:false)
    let co = try Correspondence.read(raw,context:cc)
    try check("Python golden canonical bytes") { try require(Correspondence.canonical(co) == raw) }
    try check("Python golden proposal digest") { try require(Correspondence.proposalDigest(co["payload"]) == CorrespondenceGolden.proposalSHA256) }
    try check("Python golden approved-content digest") { try require(Correspondence.approvedDigest(co["payload"],co["approval"]) == CorrespondenceGolden.approvedContentSHA256) }
    try check("Python golden complete record digest distinct") {
        try require(Codec.hash(raw) == CorrespondenceGolden.recordSHA256)
        try require(Set([CorrespondenceGolden.proposalSHA256,CorrespondenceGolden.approvedContentSHA256,CorrespondenceGolden.recordSHA256]).count == 3)
    }
    try check("Python accepts reordered evidence/whitespace") {
        let p = co["payload"].replacing("evidence",.array(co["payload"]["evidence"].list.reversed()))
        let reordered = Data(" \n".utf8) + (try Codec.encode(co.replacing("payload",p),pretty:true))
        try require(Correspondence.canonical(Correspondence.read(reordered,context:cc)) == raw)
    }
    try fails("Python unapproved not registration authority",.approvalMissing) { _ = try Correspondence.read(Correspondence.canonical(co.replacing("approval",.null)),context:cc) }
    for version: Wire in [.null,.string("1"),.bool(true),.integer(2)] {
        try fails("correspondence strict version") { _ = try Correspondence.read(Correspondence.canonical(co.replacing("schemaVersion",version)),context:cc) }
    }
    for field in ["proposalSHA256","approvedContentSHA256"] {
        try fails("correspondence separate digest rejects mutation",.approvalConflict) { _ = try Correspondence.read(Correspondence.canonical(co.replacing("approval",co["approval"].replacing(field,.string(Fixtures.hash)))),context:cc) }
    }
    for bad in ["1.0","1e0","12345678901234567","-1234567890123456"] {
        try fails("Python number contract") { try RegistrationSyntax.scan(Data(("{\"schemaVersion\":" + bad + "}").utf8),depth:32,integerDigits:16) }
    }
    try fails("correspondence depth32",.resourceLimit) { try RegistrationSyntax.scan(Data((String(repeating:"[",count:33)+"0"+String(repeating:"]",count:33)).utf8),depth:32,integerDigits:16) }
    try fails("Python whitespace scalar parity") { try Correspondence.text(.string("\u{1c}")) }
    try fails("lone surrogate JSON invalid") { _ = try Codec.read(Data("{\"x\":\"\\ud800\"}".utf8),limit:100,canonical:false) }
}
func registrationHappy() throws {
    let i = try RegistrationFixtures.scenario(counts:true), q = try RegistrationFixtures.prepared(i), a = try RegistrationFixtures.approved(q)
    let b = try Registration.apply(i,request:q,approval:a,current:i.context["expectedPrevious"])
    let r = try Registry4.read(i.registry), t = try Registry4.read(b.registry), h = try Registration.read(b.history,limit:Limits.history)
    try check("registration 275 to276 and716 to717") { try require(r["entities"].list.count == 275 && t["entities"].list.count == 276 && r["references"].list.count == 716 && t["references"].list.count == 717) }
    try check("one active Trip one Trip reference") {
        try require(t["entities"].list.filter { $0["id"].text.hasPrefix("trp_") }.count == 1)
        try require(t["references"].list.filter { $0["namespace"].text == "gtfs.trip_id" }.count == 1)
        try require(t["revision"].int == 8 && t["schemaVersion"].int == 4)
    }
    try check("all existing canonical record encodings preserved") {
        try require(Codec.equal(r["entities"],.array(t["entities"].list.filter { !$0["id"].text.hasPrefix("trp_") })))
        try require(Codec.equal(r["references"],.array(t["references"].list.filter { $0["namespace"].text != "gtfs.trip_id" })))
    }
    try check("attachedBy exact introducing approval empty names") {
        let ref = t["references"].list.first { $0["namespace"].text == "gtfs.trip_id" }!
        try require(Codec.equal(ref["attachedBy"],a["reviewID"]) && ref["originalNames"].list.isEmpty)
    }
    try check("v2 exact original v1 and conversion bytes retained") {
        try require(h["schemaVersion"].int == 2 && h["predecessorHistoryBytes"].blob == i.history)
        let old = try Conversion.history(h["predecessorHistoryBytes"].blob,owner:Fixtures.owner).0
        try require(Codec.equal(old["boundaries"],try Codec.read(i.history,limit:Limits.history)["boundaries"]))
        try require(old["boundaries"].list.count == 1 && h["boundaries"].list.count == 1)
    }
    try check("correspondence originals and unresolved six retained") {
        let retained = h["boundaries"].list[0]["request"]
        try require(retained["correspondenceBytes"].blob == i.correspondence)
        let co = try Correspondence.read(retained["correspondenceBytes"].blob,context:i.context["correspondenceContext"])
        try require(co["payload"]["baseline"]["schemaVersion"].int == 2 && co["payload"]["baseline"]["revision"].int == 6)
        try require(co["payload"]["unresolvedPrerequisites"].list.count == 6 && !retained.has("snapshotArtifactID"))
    }
    try check("complete registration bundle verifies") { try require(Registration.verify(b.registry,b.history,b.manifest,owner:Fixtures.owner).files == b.files) }
    try fails("unconverted schema2 refuses",.staleCheckpoint) {
        let s = try Fixtures.scenario()
        _ = try Registration.eligible(RegistrationFixtures.changed(i,registry:s.registry,history:s.history,context:i.context.replacing("expectedPrevious",s.current)))
    }
    try fails("conversion still rejects v2",.unsupportedVersion) { _ = try Conversion.history(b.history,owner:Fixtures.owner) }
}
func registrationContracts() throws {
    let i = try RegistrationFixtures.scenario(), q = try RegistrationFixtures.prepared(i), a = try RegistrationFixtures.approved(q)
    try fails("exact registration approval required",.approvalMissing) { _ = try Registration.apply(i,request:q,approval:.null,current:i.context["expectedPrevious"]) }
    try fails("correspondence approval not operation approval") {
        let co = try Correspondence.read(i.correspondence,context:i.context["correspondenceContext"])
        _ = try Registration.apply(i,request:q,approval:co["approval"],current:i.context["expectedPrevious"])
    }
    for field in ["registrySHA256","historySHA256","lineageID","revision"] {
        let v: Wire = field == "revision" ? .integer(6) : .string(field == "lineageID" ? "fixture.other" : Fixtures.hash)
        try fails("wrong checkpoint " + field,.staleCheckpoint) { _ = try Registration.apply(i,request:q,approval:a,current:i.context["expectedPrevious"].replacing(field,v)) }
    }
    for key in ["requestID","recordID","allocationID","approvalReviewID","operationID","workspaceID","outputID"] {
        let c = i.context.replacing("workflow",i.context["workflow"].replacing(key,.string("fixture.conversion-approval")))
        try fails("retained authority ID collision " + key,.identityConflict) { _ = try Registration.eligible(RegistrationFixtures.changed(i,context:c)) }
    }
    try fails("approval prebind mismatch",.approvalConflict) { _ = try Registration.approval(q,reviewID:"fixture.different-review",author:"fixture.author",at:Fixtures.time,reference:"fixture.review") }
    try fails("generic approval cannot bypass prebind",.approvalConflict) {
        let wrong = try Conversion.approval(q,owner:Fixtures.owner,reviewID:"fixture.different-review",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        _ = try Registration.apply(i,request:q,approval:wrong,current:i.context["expectedPrevious"])
    }
    for field in ["schemaVersion","requestID","reference","preparation","context","targetRegistryBytes"] {
        try fails("request missing " + field) { try Registration.checkRequest(q.replacing(field,nil)) }
        try fails("request null " + field) { try Registration.checkRequest(q.replacing(field,.null)) }
    }
    try fails("registration unknown field") { try Registration.checkRequest(q.replacing("snapshotArtifactID",.string("fixture.unapproved"))) }
    try fails("registration unsupported version",.unsupportedVersion) { try Registration.checkRequest(q.replacing("schemaVersion",.integer(2))) }
    for field in ["format","schemaVersion","ownerAuthority","expectedPrevious","predecessorManifestSHA256","workflow","correspondenceContext","correspondence","profileAcceptance","applicability","provenance","provenanceEvidenceID","dependencyDigests","scope"] {
        try fails("context missing " + field) { try Registration.checkContext(i.context.replacing(field,nil)) }
        try fails("context null " + field) { try Registration.checkContext(i.context.replacing(field,.null)) }
    }
    try fails("context unknown field") { try Registration.checkContext(i.context.replacing("snapshotArtifactID",.string("fixture.unapproved"))) }
    try fails("context unsupported version",.unsupportedVersion) { try Registration.checkContext(i.context.replacing("schemaVersion",.integer(2))) }
    try fails("dependency array bound",.resourceLimit) { try Registration.dependencies(.array(Array(repeating:i.dependencies.list[0],count:Limits.records+1)),context:i.context) }
    try fails("missing dependency bytes holds",.historyUnavailable) {
        var rows = i.dependencies.list; rows[0] = rows[0].replacing("bytes",nil)
        try Registration.dependencies(.array(rows),context:i.context)
    }
    try fails("null dependency bytes rejects") {
        var rows = i.dependencies.list; rows[0] = rows[0].replacing("bytes",.null)
        try Registration.dependencies(.array(rows),context:i.context)
    }
    try fails("request duplicate escaped key") { _ = try Registration.read(Data("{\"x\":1,\"\\u0078\":2}".utf8),limit:100) }
    try fails("request fractional version") { _ = try Registration.read(Data("{\"schemaVersion\":1.0}".utf8),limit:100) }
    try fails("request overflowing integer") { _ = try Registration.read(Data("{\"x\":9223372036854775808}".utf8),limit:100) }
    try fails("approval tampered payload",.approvalConflict) { try Registration.checkApproval(a.replacing("payloadSHA256",.string(Fixtures.hash)),q) }
    try fails("request tampered under old approval",.approvalConflict) { try Registration.checkApproval(a,q.replacing("proposedTripID",.string(Fixtures.id("trp","9")))) }
    try fails("source reference null attachedBy",.referenceConflict) { try Registration.checkRequest(q.replacing("reference",q["reference"].replacing("attachedBy",.null))) }
    try fails("source reference wrong attachedBy",.referenceConflict) { try Registration.checkRequest(q.replacing("reference",q["reference"].replacing("attachedBy",q["requestID"]))) }
    for (field,v): (String,Wire) in [("profileAcceptance",i.context["profileAcceptance"].replacing("version",.string("fixture.other"))),
        ("applicability",i.context["applicability"].replacing("disposition",.string("held"))),
        ("correspondence",i.context["correspondence"].replacing("recordSHA256",.string(Fixtures.hash))),
        ("provenance",i.context["provenance"].replacing("recordIndex",.integer(0)))] {
        try fails("binding mismatch " + field) { _ = try Registration.eligible(RegistrationFixtures.changed(i,context:i.context.replacing(field,v))) }
    }
    try fails("missing closure holds",.historyUnavailable) { _ = try Registration.eligible(RegistrationFixtures.changed(i,dependencies:.array(Array(i.dependencies.list.dropLast())))) }
    try fails("tampered dependency bytes reject",.historyConflict) {
        var rows = i.dependencies.list; rows[0] = rows[0].replacing("bytes",Codec.blob(Data("INVENTED MUTATION".utf8)))
        _ = try Registration.eligible(RegistrationFixtures.changed(i,dependencies:.array(rows)))
    }
    try fails("dependency cycle reject",.historyConflict) {
        var rows = i.dependencies.list
        rows[0] = rows[0].replacing("dependencyDigests",.array([.object(["id":rows[1]["id"],"sha256":rows[1]["sha256"]])]))
        rows[1] = rows[1].replacing("dependencyDigests",.array([.object(["id":rows[0]["id"],"sha256":rows[0]["sha256"]])]))
        try Registration.dependencies(.array(rows),context:i.context)
    }
    let target = try Registry4.read(q["targetRegistryBytes"].blob)
    for bad in [target.replacing("revision",.integer(9)),target.replacing("references",.array(Array(target["references"].list.dropLast()))),
        target.replacing("entities",.array(target["entities"].list + [Fixtures.entity("trp","9")])),
        target.replacing("references",.array(target["references"].list.map { $0["namespace"].text == "gtfs.trip_id" ? $0 : $0.replacing("originalNames",.array([])) }))] {
        try fails("derived exact target rejects semantic mutation",.identityConflict) {
            let bytes = try Codec.encode(bad,pretty:true)
            try Registration.validate(q.replacing("targetRegistryBytes",Codec.blob(bytes)).replacing("targetRegistrySHA256",.string(Codec.hash(bytes))),input:i)
        }
    }
}
func registrationAuthorityAssociations() throws {
    let i = try RegistrationFixtures.scenario()
    func provenance(_ row: Wire) -> Registration.Inputs {
        let rows = i.dependencies.list.map { $0["id"].text == "fixture.provenance" ? row : $0 }.sorted { $0["id"].text < $1["id"].text }
        let c = i.context.replacing("provenanceEvidenceID",row["id"]).replacing("dependencyDigests",.array(rows.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) }))
        return RegistrationFixtures.changed(i,context:c,dependencies:.array(rows))
    }
    let original = i.dependencies.list.first { $0["id"].text == "fixture.provenance" }!
    let oldIDs = ["fixture.attachment","fixture.original-allocation-request","fixture.baseline","fixture.baseline-approval","fixture.conversion","fixture.conversion-approval",Fixtures.id("stn","0")]
    for id in oldIDs {
        try fails("dependency handle cannot repurpose old business ID " + id,.identityConflict) {
            _ = try Registration.eligible(provenance(original.replacing("id",.string(id))))
        }
        try fails("correspondence cannot repurpose uncovered old ID " + id,.identityConflict) {
            _ = try Registration.eligible(RegistrationFixtures.correspondenceID(i,id))
        }
    }
    try fails("correspondence cannot repurpose new dependency handle",.identityConflict) {
        _ = try Registration.eligible(RegistrationFixtures.correspondenceID(i,"fixture.provenance"))
    }
    let retained = try Registration.eligible(i).history["baseline"]["payload"]["records"].list.first { $0["id"].text == "fixture.allocation-record" }!
    let quote: Wire = .object(["id":retained["id"],"sha256":retained["sha256"],"bytes":retained["bytes"],"dependencyDigests":retained["dependencyDigests"]])
    try check("unchanged original retained handle quotation remains eligible") {
        let input = provenance(quote), q = try RegistrationFixtures.prepared(input), a = try RegistrationFixtures.approved(q)
        let b = try Registration.apply(input,request:q,approval:a,current:input.context["expectedPrevious"])
        _ = try Registration.verify(b.registry,b.history,b.manifest,owner:Fixtures.owner)
    }
    let different = Data("INVENTED DIFFERENT AUTHORITY".utf8)
    try fails("retained handle cannot quote different original bytes",.historyConflict) {
        _ = try Registration.eligible(provenance(quote.replacing("bytes",Codec.blob(different)).replacing("sha256",.string(Codec.hash(different)))))
    }
    try fails("retained handle cannot rewrite original dependency pins",.historyConflict) {
        let mapping = i.dependencies.list.first { $0["id"].text == "fixture.mapping" }!
        let pin: Wire = .object(["id":mapping["id"],"sha256":mapping["sha256"]])
        _ = try Registration.eligible(provenance(quote.replacing("dependencyDigests",.array([pin]))))
    }
    try check("existing correspondence business ID resolves original coverage handle") {
        let input = try RegistrationFixtures.retainingCorrespondenceReview(RegistrationFixtures.correspondenceID(i,"fixture.attachment"))
        let q = try RegistrationFixtures.prepared(input), a = try RegistrationFixtures.approved(q)
        let b = try Registration.apply(input,request:q,approval:a,current:input.context["expectedPrevious"])
        _ = try Registration.verify(b.registry,b.history,b.manifest,owner:Fixtures.owner)
    }
    try fails("original correspondence bytes without matching coverage cannot authorize ID",.identityConflict) {
        let input = try RegistrationFixtures.retainingCorrespondenceReview(RegistrationFixtures.correspondenceID(i,"fixture.conversion"))
        _ = try Registration.eligible(input)
    }
    let dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let invalid = provenance(original.replacing("id",.string("fixture.attachment"))), l = RegistrationFixtures.location(invalid,dir)
    var draws = 0
    try fails("authority handle conflict before durable claim and RNG",.identityConflict) {
        _ = try Preparation.prepareForTest(invalid,location:l,draw:{ _ in draws += 1; return .init(id:Fixtures.id("trp","4"),attempts:1) })
    }
    try check("authority handle rejection creates no workspace or candidate") { try require(draws == 0 && !FileManager.default.fileExists(atPath:l.workspace)) }
}
func registrationKeysAndMinting() throws {
    let i = try RegistrationFixtures.scenario(), r = try Registry4.read(i.registry), s = i.context["correspondenceContext"]["source"]
    let reference = Registration.reference(i.context,tripID:Fixtures.id("trp","4"))
    for (state,failure): (String,ConversionFailure) in [("active",.referenceConflict),("absent",.continuityUnavailable),("retired",.referenceConflict)] {
        let ref = reference.replacing("status",.object(["state":.string(state)]))
        try fails("held source key " + state,failure) { try Registration.keyCheck(r.replacing("references",.array([ref])),source:s) }
    }
    try fails("wrong-kind key conflict",.referenceConflict) { try Registration.keyCheck(r.replacing("references",.array([reference.replacing("canonicalID",.string(Fixtures.id("stn","0")))])),source:s) }
    try check("scalar distinct keys no normalization") {
        let a = s.replacing("key",.string("INVENTED_é")), b = reference.replacing("value",.string("INVENTED_e\u{301}"))
        try Registration.keyCheck(r.replacing("references",.array([b])),source:a)
        try require(try Registry4.key(b) != Registry4.key(b.replacing("value",a["key"])))
    }
    let held = try Registration.eligible(i).held
    for kindBody in ["2","1","0"] {
        var rng = InventedRNG(words:inventedWords(String(repeating:kindBody,count:16)) + [UInt64.max,UInt64.max])
        try check("historical cross-kind/retired collision " + kindBody) {
            let draw = try TripMinting.mintForTest(heldBodies:held,using:&rng)
            try require(draw.attempts == 2 && draw.id == "trp_zzzzzzzzzzzzzzzz" && rng.index == 4)
        }
    }
    try check("80bit MSB Crockford golden encoding") {
        var rng = InventedRNG(words:inventedWords("0123456789abcdef"))
        let draw = try TripMinting.mintForTest(heldBodies:[],using:&rng)
        try require(draw.id == "trp_0123456789abcdef" && draw.attempts == 1 && rng.index == 2)
    }
    try check("provider independent minter") {
        var a = InventedRNG(words:[UInt64.max,UInt64.max]), b = a
        try require(TripMinting.mintForTest(heldBodies:held,using:&a).id == TripMinting.mintForTest(heldBodies:held,using:&b).id)
    }
    try fails("eight collisions fail",.collisionExhausted) {
        var rng = InventedRNG(words:Array(repeating:0,count:16))
        do { _ = try TripMinting.mintForTest(heldBodies:held,using:&rng) }
        catch { try require(rng.index == 16); throw error }
    }
    try check("all-history inventory survives a reduced current projection") {
        // A projection is NOT an admitted checkpoint. Valid current contexts cannot delete IDs.
        let reduced = r.replacing("entities",.array(r["entities"].list.filter { $0["id"].text != Fixtures.id("stn","1") }))
        try require(!reduced["entities"].list.contains { $0["id"].text == Fixtures.id("stn","1") })
        try require(held.contains(String(repeating:"1",count:16)))
        var rng = InventedRNG(words:inventedWords(String(repeating:"1",count:16)) + [UInt64.max,UInt64.max])
        try require(TripMinting.mintForTest(heldBodies:held,using:&rng).attempts == 2)
    }
    try fails("deleted historical ID cannot become current context") {
        let reduced = try Codec.encode(r.replacing("entities",.array(r["entities"].list.filter { $0["id"].text != Fixtures.id("stn","1") })),pretty:true)
        _ = try Registration.eligible(RegistrationFixtures.changed(i,registry:reduced))
    }
}
func registrationPreparation() throws {
    let i = try RegistrationFixtures.scenario(), dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let l = RegistrationFixtures.location(i,dir); var calls = 0
    func draw(_ held: Set<String>) throws -> TripMinting.Draw { calls += 1; return .init(id:Fixtures.id("trp","4"),attempts:1) }
    try check("preparation durable claim precedes RNG") {
        let result = try Preparation.prepareForTest(i,location:l,draw:{ held in
            try require(FileManager.default.fileExists(atPath:l.workspace + "/claim.json"))
            try require(FileManager.default.fileExists(atPath:l.workspace + "/location.json"))
            return try draw(held)
        })
        try require(!result.1 && calls == 1)
    }
    let q = try Data(contentsOf:URL(fileURLWithPath:l.workspace + "/request.json"))
    try check("completed preparation exact reopen no redraw") {
        let again = try Preparation.prepareForTest(i,location:l,draw:draw)
        try require(again.1 && (try Codec.encode(again.0)) == q && calls == 1)
    }
    let alt = Preparation.Location(workspace:l.workspace,output:dir + "/alternate-output",operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
    try fails("actual alternate output same token refused",.preparationConflict) { _ = try Preparation.prepareForTest(i,location:alt,draw:draw) }
    try fails("alternate workspace token refused",.preparationConflict) { _ = try Preparation.prepareForTest(i,location:.init(workspace:dir + "/elsewhere",output:l.output,operationID:l.operationID,workspaceID:"fixture.other-workspace",outputID:l.outputID),draw:draw) }
    try check("preparation owner-only modes") {
        var st = stat(); try require(lstat(l.workspace,&st) == 0 && st.st_mode & 0o7777 == 0o700)
        for name in ["claim.json","location.json","request.json"] { try require(lstat(l.workspace + "/" + name,&st) == 0 && st.st_mode & 0o7777 == 0o600) }
    }
    for point in ["claim","draw"] {
        let fresh = Preparation.Location(workspace:dir + "/interrupted-" + point,output:l.output,operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
        try fails("interrupted preparation " + point,.preparationIncomplete) { _ = try Preparation.prepareForTest(i,location:fresh,draw:draw,failAt:point) }
        let before = calls
        try fails("interrupted never redraw " + point,.preparationIncomplete) { _ = try Preparation.prepareForTest(i,location:fresh,draw:draw) }
        try check("interrupted RNG counter unchanged " + point) { try require(calls == before) }
    }
    let bad = RegistrationFixtures.changed(i,context:i.context.replacing("applicability",i.context["applicability"].replacing("disposition",.string("held"))))
    let never = Preparation.Location(workspace:dir + "/never-started",output:l.output,operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
    let before = calls
    try fails("eligibility before claim and RNG",.scopeConflict) { _ = try Preparation.prepareForTest(bad,location:never,draw:draw) }
    try check("failed eligibility no draw or workspace") { try require(calls == before && !FileManager.default.fileExists(atPath:never.workspace)) }
    for (name,invalid): (String,Registration.Inputs) in [
        ("context resource",RegistrationFixtures.changed(i,context:i.context.replacing("workflow",i.context["workflow"].replacing("operationID",.string(String(repeating:"x",count:257)))))),
        ("closure",RegistrationFixtures.changed(i,dependencies:.array([]))),
        ("checkpoint",RegistrationFixtures.changed(i,context:i.context.replacing("predecessorManifestSHA256",.string(Fixtures.hash)))),
        ("correspondence",RegistrationFixtures.changed(i,correspondence:Data("INVENTED INVALID CORRESPONDENCE".utf8)))] {
        let untouched = Preparation.Location(workspace:dir + "/gate-" + name.replacingOccurrences(of:" ",with:"-"),output:l.output,operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
        do { _ = try Preparation.prepareForTest(invalid,location:untouched,draw:draw); throw Assertion.failed } catch is ConversionFailure {}
        try check("no RNG before " + name) { try require(calls == before && !FileManager.default.fileExists(atPath:untouched.workspace)) }
    }
    let unsafe = Preparation.Location(workspace:"relative",output:l.output,operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
    try fails("unsafe preparation path before RNG",.unsafePath) { _ = try Preparation.prepareForTest(i,location:unsafe,draw:draw) }
    try check("unsafe path no RNG") { try require(calls == before) }
    let exhaustion = Preparation.Location(workspace:dir + "/exhausted",output:l.output,operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
    let partial = Preparation.Location(workspace:dir + "/partial-claim",output:l.output,operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID)
    try FileManager.default.createDirectory(atPath:partial.workspace,withIntermediateDirectories:false,attributes:[.posixPermissions:0o700])
    try Fixtures.write(partial.workspace + "/claim.json",Preparation.claim(Registration.eligible(i)))
    try fails("interrupted claim before location cannot redraw",.preparationIncomplete) { _ = try Preparation.prepareForTest(i,location:partial,draw:draw) }
    try check("partial claim no RNG") { try require(calls == before) }
    try fails("collision exhaustion no completed preparation",.collisionExhausted) {
        _ = try Preparation.prepareForTest(i,location:exhaustion,draw:{ held in var rng = InventedRNG(words:Array(repeating:0,count:16)); return try TripMinting.mintForTest(heldBodies:held,using:&rng) })
    }
    try fails("failed preparation cannot redraw",.preparationIncomplete) { _ = try Preparation.prepareForTest(i,location:exhaustion,draw:draw) }
    try check("no accepted registration after failed preparations") { try require(!FileManager.default.fileExists(atPath:l.output)) }
}
func registrationReplayAndHistory() throws {
    let i = try RegistrationFixtures.scenario(), q = try RegistrationFixtures.prepared(i), a = try RegistrationFixtures.approved(q)
    let b = try Registration.apply(i,request:q,approval:a,current:i.context["expectedPrevious"])
    let next = RegistrationFixtures.changed(i,registry:b.registry,history:b.history,manifest:b.manifest), pin = try Conversion.pin(b.registry,b.history,lineage:Fixtures.lineage)
    try check("exact registration replay no RNG same bytes") {
        let replay = try Registration.apply(next,request:q,approval:a,current:pin)
        try require(replay.replay && replay.files == b.files)
        try require(Registry4.read(replay.registry)["revision"].int == 8 && Registration.read(replay.history,limit:Limits.history)["boundaries"].list.count == 1)
    }
    try fails("later checkpoint stale",.staleCheckpoint) { _ = try Registration.apply(next,request:q,approval:a,current:pin.replacing("revision",.integer(9))) }
    try fails("altered approval replay",.staleCheckpoint) { _ = try Registration.apply(next,request:q,approval:a.replacing("author",.string("fixture.other-author")),current:pin) }
    let altered = q.replacing("preparation",q["preparation"].replacing("drawCount",.integer(2)))
    try fails("changed approved request replay",.staleCheckpoint) { _ = try Registration.apply(next,request:altered,approval:RegistrationFixtures.approved(altered),current:pin) }
    let h = try Registration.read(b.history,limit:Limits.history)
    for field in ["predecessorHistorySHA256","lineageID"] {
        try fails("history v2 tamper " + field) { _ = try Registration.verify(b.registry,Codec.encode(h.replacing(field,.string(Fixtures.hash))),b.manifest,owner:Fixtures.owner) }
    }
    try fails("v2 nested predecessor rejected") { _ = try Registration.verify(b.registry,Codec.encode(h.replacing("predecessorHistoryBytes",Codec.blob(b.history)).replacing("predecessorHistorySHA256",.string(Codec.hash(b.history)))),b.manifest,owner:Fixtures.owner) }
    try fails("v2 second new boundary rejected",.resourceLimit) { _ = try Registration.verify(b.registry,Codec.encode(h.replacing("boundaries",.array(h["boundaries"].list+h["boundaries"].list))),b.manifest,owner:Fixtures.owner) }
    try fails("v2 altered boundary operation rejected",.historyConflict) {
        let bs = h["boundaries"].list.map { $0.replacing("operation",.string("attach")) }
        _ = try Registration.verify(b.registry,Codec.encode(h.replacing("boundaries",.array(bs))),b.manifest,owner:Fixtures.owner)
    }
    // Bypass the current key only to exercise history's independent consumed-authority gate.
    let otherSource = i.context["correspondenceContext"]["source"].replacing("key",.string("INVENTED_OTHER_KEY"))
    let cc = i.context["correspondenceContext"].replacing("source",otherSource).replacing("evidence",.array(i.context["correspondenceContext"]["evidence"].list.map { $0.replacing("source",otherSource) }))
    var c = i.context.replacing("correspondenceContext",cc).replacing("provenance",i.context["provenance"].replacing("providerKey",otherSource["key"]))
    for field in ["requestID","approvedContentSHA256"] {
        var binding = c["correspondence"]
        if field == "requestID" { binding = binding.replacing("approvedContentSHA256",.string(Fixtures.hash)) }
        else { binding = binding.replacing("requestID",.string("fixture.different-correspondence")) }
        c = c.replacing("correspondence",binding)
        try fails("consumed correspondence independent " + field,.correspondenceConflict) { _ = try Registration.eligible(RegistrationFixtures.changed(next,context:c)) }
        c = c.replacing("correspondence",i.context["correspondence"])
    }
}
func registrationPublication() throws {
    let i = try RegistrationFixtures.scenario(), dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let l = RegistrationFixtures.location(i,dir)
    let q = try Preparation.prepareForTest(i,location:l,draw:{ _ in .init(id:Fixtures.id("trp","4"),attempts:1) }).0
    let a = try RegistrationFixtures.approved(q), b = try Registration.apply(i,request:q,approval:a,current:i.context["expectedPrevious"])
    for stage in ["write:registry.json","write:history.json","write:manifest.json","rename"] {
        try fails("registration atomic fail " + stage,.publicationFailure) { try PrivateIO.publishInternal(b,to:dir + "/failed",owner:Fixtures.owner,failAt:stage,registration:true) }
        try check("registration fail no partial " + stage) { try require(!FileManager.default.fileExists(atPath:dir + "/failed")) }
    }
    try fails("postcommit durability uncertain",.durabilityUncertain) { try PrivateIO.publishInternal(b,to:l.output,owner:Fixtures.owner,failAt:"parentFsync",registration:true) }
    try check("durability recovery exact bundle verifies") {
        let p = try PrivateIO.parent(l.output); defer { p.closeFD() }
        try require(PrivateIO.readBundleAt(p.fd,p.leaf,owner:Fixtures.owner,manifestSHA:Codec.hash(b.manifest),registration:true).files == b.files)
    }
    try fails("old predecessor rerun no overwrite",.publicationConflict) { try Preparation.publish(b,request:q,location:l) }
    let next = RegistrationFixtures.changed(i,registry:b.registry,history:b.history,manifest:b.manifest)
    let replay = try Registration.apply(next,request:q,approval:a,current:Conversion.pin(b.registry,b.history,lineage:Fixtures.lineage))
    try check("replay exact output after uncertain durability") { try Preparation.publish(replay,request:q,location:l) }
    try fails("same opaque output ID alternate actual destination refused",.preparationConflict) {
        try Preparation.publish(replay,request:q,location:.init(workspace:l.workspace,output:dir + "/other",operationID:l.operationID,workspaceID:l.workspaceID,outputID:l.outputID))
    }
    try check("registration race one winner") {
        let lock = NSLock(); var success = 0, conflict = 0
        DispatchQueue.concurrentPerform(iterations:2) { _ in
            do { try PrivateIO.publishInternal(b,to:dir + "/race",owner:Fixtures.owner,failAt:nil,registration:true); lock.lock(); success += 1; lock.unlock() }
            catch ConversionFailure.publicationConflict { lock.lock(); conflict += 1; lock.unlock() } catch {}
        }
        try require(success == 1 && conflict == 1)
    }
}
func registrationLargeAndBounds() throws {
    try fails("bounded registration context",.resourceLimit) { _ = try Registration.read(Data(repeating:32,count:Correspondence.limit+1),limit:Correspondence.limit) }
    try fails("bounded registration depth",.resourceLimit) { _ = try Registration.read(Data((String(repeating:"[",count:65)+"0"+String(repeating:"]",count:65)).utf8),limit:1000) }
    try fails("bounded authority token") { try Codec.token(.string(String(repeating:"x",count:257))) }
    try fails("worst-case base64 history bound before RNG",.resourceLimit) { try Registration.preflightSizes(previousRegistry:1000,targetRegistry:2000,history:Limits.history,request:1000) }
    try fails("worst-case request bound before RNG",.resourceLimit) { try Registration.preflightSizes(previousRegistry:1000,targetRegistry:2000,history:1000,request:Limits.request+1) }
    try fails("size arithmetic overflow rejects",.resourceLimit) { try Registration.preflightSizes(previousRegistry:Int.max,targetRegistry:2000,history:Int.max,request:1000) }
    let i = try RegistrationFixtures.scenario(large:true)
    try check("invented predecessor at least10MiB") { try require(i.history.count >= 10 * 1024 * 1024) }
    try check("large history preflight viable before RNG") { try Registration.preflight(Registration.eligible(i)) }
    let q = try RegistrationFixtures.prepared(i), a = try RegistrationFixtures.approved(q)
    try check("large v2 envelope complete verification") {
        let b = try Registration.apply(i,request:q,approval:a,current:i.context["expectedPrevious"])
        try require(b.history.count < Limits.history && Registration.verify(b.registry,b.history,b.manifest,owner:Fixtures.owner).files == b.files)
        try require(Registration.read(b.history,limit:Limits.history)["predecessorHistoryBytes"].blob == i.history)
    }
}

let registrationSuites: [(String,() throws -> Void)] = [("registration Python golden",registrationGolden),("registration",registrationHappy),
    ("registration contracts",registrationContracts),("registration authority associations",registrationAuthorityAssociations),("registration keys/minting",registrationKeysAndMinting),("registration preparation",registrationPreparation),
    ("registration replay/history",registrationReplayAndHistory),("registration publication",registrationPublication),("registration large/bounds",registrationLargeAndBounds)]
