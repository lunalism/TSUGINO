import Foundation
import Darwin

enum TestFailure: Error { case assertion }
var total = 0
func expect(_ value: @autoclosure () throws -> Bool) throws { guard try value() else { throw TestFailure.assertion } }
func test(_ name: String, _ body: () throws -> Void) throws {
    do { try body(); total += 1 } catch { print("FAIL " + name + " " + S9CLI.failure(error)); throw error }
}
func rejects(_ name: String, status: String? = nil, _ body: () throws -> Void) throws {
    try test(name) {
        do { try body(); throw TestFailure.assertion }
        catch is TestFailure { throw TestFailure.assertion }
        catch { if let status { try expect(S9CLI.failure(error).hasSuffix("=" + status)) } }
    }
}
func rows(_ i: Wire, _ key: String, _ transform: ([Wire]) -> [Wire]) -> Wire { i.replacing(key,.array(transform(i[key].list))) }
func row(_ i: Wire, _ key: String, _ n: Int, _ field: String, _ value: Wire?) -> Wire {
    rows(i,key) { a in var a = a; a[n] = a[n].replacing(field,value); return a }
}
func reconstruct(_ i: Wire) throws -> S9.Product { try S9.reconstruct(i,artifact:.string("invented.snapshot")) }
func domain(_ i: Wire) throws -> Trip { try JSONDecoder().decode(Trip.self,from:reconstruct(i).trip) }
func retainThroughInterval(_ i: Wire) -> Wire {
    let id = i["intervalEvidence"]["id"].text
    let pins = i["dependencies"].list.filter { $0["id"].text != id }.map { $0.replacing("bytes",nil).replacing("dependencyDigests",nil) }
    return rows(i,"dependencies") { $0.map { $0["id"].text == id ? $0.replacing("dependencyDigests",.array(pins)) : $0 } }
}
func command(_ args: [String]) throws -> (Int32,String) {
    let process = Process(), pipe = Pipe()
    process.executableURL = URL(fileURLWithPath:CommandLine.arguments[1]); process.arguments = args
    process.standardOutput = pipe; process.standardError = pipe
    try process.run(); let bytes = pipe.fileHandleForReading.readDataToEndOfFile(); process.waitUntilExit()
    return (process.terminationStatus,String(decoding:bytes,as:UTF8.self))
}
func main() throws {
    let s = try Invented.fixture(), i = s.input, q = try s.request(), a = try s.approved(q), b = try s.bundle()
    let owner = Invented.owner
    try test("happy initial selection fourteen passengers thirteen movements") {
        let t = try domain(i)
        try expect(t.stopSequence.count == 14 && i["movements"].list.count == 13 && t.lineSegments.count == 1)
        try expect(t.lineSegments[0].startIndex == 0 && t.lineSegments[0].endIndex == 13)
        try expect(!t.coverage.includesServiceOrigin && !t.coverage.includesServiceDestination && t.serviceTypeSegments.isEmpty)
        try expect(!b.replay && b.files.count == 4)
    }
    for target in [Fixtures.id("trp","9"),Fixtures.id("stn","0")] {
        try rejects("exact registered active Trip and kind") { _ = try reconstruct(i.replacing("registeredTripID",.string(target))) }
    }
    try rejects("retired Trip never admitted") {
        var registry = try Registry4.read(i["registeredBundle"]["registryBytes"].blob)
        registry = rows(registry,"entities") { $0.map { Codec.equal($0["id"],i["registeredTripID"]) ? $0.replacing("state",.string("retired")).replacing("successors",.array([])) : $0 } }
        let bytes = try Codec.encode(registry,pretty:true)
        let bad = i.replacing("registeredBundle",i["registeredBundle"].replacing("registryBytes",Codec.blob(bytes)))
            .replacing("registeredCheckpoint",i["registeredCheckpoint"].replacing("registrySHA256",.string(Codec.hash(bytes))))
        _ = try reconstruct(bad)
    }
    for key in ["sourceID","key","inputSHA256"] {
        try rejects("source mismatch " + key) {
            _ = try reconstruct(i.replacing("source",i["source"].replacing(key,.string(key == "inputSHA256" ? String(repeating:"f",count:64) : "invented.other"))))
        }
    }
    for key in ["registrySHA256","historySHA256","manifestSHA256","lineageID","revision"] {
        try rejects("checkpoint mismatch " + key) {
            let value: Wire = key == "revision" ? .integer(9) : .string(key == "lineageID" ? "invented.other-lineage" : String(repeating:"f",count:64))
            _ = try reconstruct(i.replacing("registeredCheckpoint",i["registeredCheckpoint"].replacing(key,value)))
        }
    }
    try test("transport order does not affect Trip or crosswalk") {
        let shuffled = rows(rows(i,"occurrences",{ Array($0.reversed()) }),"movements",{ Array($0.reversed()) })
        let p = try reconstruct(i), other = try reconstruct(shuffled)
        try expect(p.trip == other.trip && p.crosswalk == other.crosswalk)
    }
    try rejects("duplicate occurrence locator") { _ = try reconstruct(row(i,"occurrences",1,"locator",i["occurrences"].list[0]["locator"])) }
    try rejects("duplicate source order") { _ = try reconstruct(row(i,"occurrences",1,"order",.integer(0))) }
    try rejects("unknown classification held",status:"preparationIncomplete") { _ = try reconstruct(row(i,"occurrences",1,"disposition",.string("unknown"))) }
    try rejects("noncontiguous original indices") { _ = try reconstruct(row(i,"occurrences",1,"originalIndex",.integer(2))) }
    try rejects("source and index order disagreement") { _ = try reconstruct(row(i,"occurrences",0,"order",.integer(500))) }
    try test("nonadjacent repeated StationID is a distinct visit") {
        let repeated = try domain(row(i,"occurrences",2,"stationID",i["occurrences"].list[0]["stationID"]))
        try expect(repeated.stopSequence[0].rawValue == repeated.stopSequence[2].rawValue && repeated.stopSequence.count == 14)
    }
    try rejects("adjacent duplicate rejected through Domain",status:"invalidStructure") { _ = try reconstruct(row(i,"occurrences",1,"stationID",i["occurrences"].list[0]["stationID"])) }
    for key in ["stationID","mappingEvidence","classificationEvidence","membership"] {
        try rejects("missing passenger mapping/classification " + key) { _ = try reconstruct(row(i,"occurrences",1,key,nil)) }
    }
    try rejects("station not active in exact registry") { _ = try reconstruct(row(i,"occurrences",1,"stationID",.string(Fixtures.id("stn","9")))) }
    try rejects("line membership required") { _ = try reconstruct(row(i,"occurrences",1,"membership",.array([]))) }
    let passed = i["occurrences"].list[0].replacing("locator",.string("invented.passed")).replacing("order",.integer(5)).replacing("disposition",.string("passed"))
        .replacing("stationID",nil).replacing("originalIndex",nil).replacing("mappingEvidence",nil).replacing("membership",nil)
    let withPassed = rows(i,"occurrences",{ $0 + [passed] })
    try test("passed remains in crosswalk without original index or passenger stop") {
        let p = try reconstruct(withPassed), walk = try S9.read(p.crosswalk,S9Limits.crosswalk)
        try expect(try domain(withPassed).stopSequence.count == 14)
        try expect(walk["occurrences"].list.count == 15 && !walk["occurrences"].list[1].has("originalIndex"))
    }
    try rejects("passed occurrence may not claim original index") { _ = try reconstruct(rows(i,"occurrences",{ $0 + [passed.replacing("originalIndex",.integer(1))] })) }
    try rejects("missing movement") { _ = try reconstruct(rows(i,"movements",{ Array($0.dropFirst()) })) }
    try rejects("movement gap") { _ = try reconstruct(rows(i,"movements",{ Array($0.prefix(4)) + Array($0.dropFirst(5)) })) }
    try rejects("conflicting overlapping movement") { _ = try reconstruct(rows(i,"movements",{ $0 + [$0[0].replacing("lineID",.string(Invented.otherLine))] })) }
    try rejects("unknown movement occurrence") { _ = try reconstruct(row(i,"movements",0,"from",.string("invented.absent"))) }
    try rejects("missing movement evidence") { _ = try reconstruct(row(i,"movements",0,"evidence",nil)) }
    try rejects("movement LineID not active") { _ = try reconstruct(row(i,"movements",0,"lineID",.string(Fixtures.id("lin","9")))) }
    try test("single explicit joined span covers every movement") {
        let span = i["movements"].list[0].replacing("to",i["occurrences"].list[13]["locator"])
        try expect(try domain(retainThroughInterval(i.replacing("movements",.array([span])))).lineSegments.count == 1)
    }
    let multi = rows(i,"movements") { $0.enumerated().map { $0.offset >= 6 ? $0.element.replacing("lineID",.string(Invented.otherLine)) : $0.element } }
        .replacing("continuity",i["continuity"].replacing("disposition",.string("proved")))
    try test("multiline joins at passenger boundary and adjacent same line normalizes") {
        let t = try domain(multi)
        try expect(t.lineSegments.count == 2 && t.lineSegments[0].endIndex == 6 && t.lineSegments[1].startIndex == 6 && t.lineSegments[1].endIndex == 13)
    }
    try rejects("multiline requires affirmative continuity") { _ = try reconstruct(multi.replacing("continuity",i["continuity"])) }
    let splitPassed = rows(withPassed,"movements") { ms in
        let first = ms[0].replacing("to",passed["locator"])
        let second = ms[0].replacing("from",passed["locator"]).replacing("lineID",.string(Invented.otherLine))
        return [first,second] + Array(ms.dropFirst()).map { $0.replacing("lineID",.string(Invented.otherLine)) }
    }.replacing("continuity",multi["continuity"])
    try rejects("passed line boundary has conclusive representation conflict",status:"representationConflict") { _ = try reconstruct(splitPassed) }
    try test("same line can join through passed position") {
        let same = rows(splitPassed,"movements") { $0.map { $0.replacing("lineID",.string(Invented.line)) } }
        try expect(try domain(same).lineSegments.count == 1)
    }
    let endpoint: Wire = .object(["disposition":.string("reached"),"evidence":i["intervalEvidence"]])
    try test("origin reached is independent of destination") {
        let t = try domain(i.replacing("origin",endpoint)); try expect(t.coverage.includesServiceOrigin && !t.coverage.includesServiceDestination)
    }
    try test("destination reached is independent of origin") {
        let t = try domain(i.replacing("destination",endpoint)); try expect(!t.coverage.includesServiceOrigin && t.coverage.includesServiceDestination)
    }
    try test("continued maps false and stays distinct from unknown extent in input") {
        let continued = i.replacing("origin",endpoint.replacing("disposition",.string("continued")))
        try expect(!domain(continued).coverage.includesServiceOrigin && !Codec.equal(continued["origin"],i["origin"]))
    }
    for d in ["reached","continued"] {
        try rejects("endpoint affirmative evidence required " + d) { _ = try reconstruct(i.replacing("origin",.object(["disposition":.string(d)]))) }
    }
    try test("explicit unknown service has no service segments") { try expect(try domain(i).serviceTypeSegments.isEmpty) }
    try rejects("known service outside bounded adapter",status:"scopeConflict") { _ = try reconstruct(i.replacing("serviceType",.string("known"))) }
    try test("Domain full-content roundtrip, never ID-only equality") {
        let p = try reconstruct(i), trip = try JSONDecoder().decode(Trip.self,from:p.trip), encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys,.withoutEscapingSlashes]
        try expect(try encoder.encode(trip) == p.trip)
        let other = try domain(i.replacing("origin",endpoint))
        try expect(trip == other && encoder.encode(other) != p.trip)
    }
    try test("crosswalk exact roundtrip") { let p = try reconstruct(i); try expect(try Codec.encode(S9.read(p.crosswalk,S9Limits.crosswalk)) == p.crosswalk) }
    for field in ["tripBytes","crosswalkBytes","inputBytes"] {
        try rejects("request target/input tamper " + field) { try S9.request(q.replacing(field,Codec.blob(Data("INVENTED TAMPER".utf8))),owner:owner) }
    }
    try rejects("fully rehashed valid Domain target cannot bypass reconstruction") {
        let target = try reconstruct(i.replacing("origin",endpoint)).trip
        let forged = q.replacing("tripBytes",Codec.blob(target)).replacing("tripSHA256",.string(Codec.hash(target)))
        let approval = a.replacing("requestSHA256",.string(try Codec.digest(forged)))
        _ = try S9.apply(forged,approval:approval,currentState:s.state,owner:owner)
    }
    try rejects("fully rehashed crosswalk cannot bypass reconstruction") {
        let walk = try S9.read(q["crosswalkBytes"].blob,S9Limits.crosswalk)
        let changed = row(walk,"occurrences",1,"locator",.string("invented.forged.locator"))
        let bytes = try Codec.encode(changed)
        let forged = q.replacing("crosswalkBytes",Codec.blob(bytes)).replacing("crosswalkSHA256",.string(Codec.hash(bytes)))
        let approval = a.replacing("requestSHA256",.string(try Codec.digest(forged)))
        _ = try S9.apply(forged,approval:approval,currentState:s.state,owner:owner)
    }
    try rejects("request cannot add predecessor") { try S9.request(q.replacing("previousSnapshotArtifactID",.string("invented.previous")),owner:owner) }
    try rejects("missing approval",status:"approvalMissing") { _ = try S9.apply(q,approval:.null,currentState:s.state,owner:owner) }
    for field in ["requestID","reviewID","ownerAuthority","requestFormat","requestSHA256"] {
        try rejects("approval mismatch " + field) { try S9.approval(a.replacing(field,.string("invented.wrong")),request:q) }
    }
    try rejects("approval UTC explicit timestamp required") { _ = try S9.approve(q,owner:owner,reviewer:"invented.reviewer",at:"2001-01-01T01:00:00+01:00",reference:"invented.ref") }
    try rejects("missing dependency") { _ = try reconstruct(rows(i,"dependencies",{ Array($0.dropFirst()) })) }
    try rejects("dependency bytes changed") { _ = try reconstruct(row(i,"dependencies",0,"bytes",Codec.blob(Data("INVENTED CHANGE".utf8)))) }
    let root = i["dependencies"].list[0]
    let rootPin = root.replacing("bytes",nil).replacing("dependencyDigests",nil)
    try rejects("dependency cycle",status:"dependencyConflict") { _ = try reconstruct(row(i,"dependencies",0,"dependencyDigests",.array([rootPin]))) }
    try rejects("dependency edge missing") {
        _ = try reconstruct(row(i,"dependencies",0,"dependencyDigests",.array([rootPin.replacing("id",.string("invented.absent"))])))
    }
    try rejects("unused hidden catalog") {
        _ = try reconstruct(rows(i,"dependencies",{ ($0 + [root.replacing("id",.string("invented.zzz.hidden"))]).sorted { $0["id"].text < $1["id"].text } }))
    }
    try test("reachable dependency child accepted") {
        let child = root.replacing("id",.string("invented.zzz.child")), pin = child.replacing("bytes",nil).replacing("dependencyDigests",nil)
        let changed = row(i,"dependencies",0,"dependencyDigests",.array([pin]))
        _ = try reconstruct(rows(changed,"dependencies",{ $0 + [child] }))
    }
    let selected = try S9.selectedState(s.state,bundle:b)
    try rejects("second initial selection rejected",status:"selectionConflict") {
        let c = s.context.replacing("selectionStateSHA256",.string(try Codec.digest(selected)))
        _ = try S9.prepare(i,context:c,state:selected)
    }
    try rejects("new IDs and new approval cannot hide second selection",status:"selectionConflict") {
        var c = s.context
        for k in S9.workflow { c = c.replacing(k,.string("invented.second." + k)) }
        let nq = try S9.prepare(i,context:c,state:s.state), na = try s.approved(nq)
        _ = try S9.apply(nq,approval:na,currentState:selected,owner:owner)
    }
    try test("exact replay preserves all bytes and history without fresh approval") {
        let replay = try S9.apply(q,approval:a,currentState:selected,owner:owner)
        try expect(replay.replay && replay.files == b.files)
        try expect(try S9.verify(b.files,owner:owner,manifestSHA:Codec.hash(b.manifest)).files == b.files)
    }
    try rejects("replay changed approval") {
        let changed = try S9.approve(q,owner:owner,reviewer:"invented.other",at:Fixtures.time,reference:"invented.other.ref")
        _ = try S9.apply(q,approval:changed,currentState:selected,owner:owner)
    }
    for k in ["sourceRevision","profileRevision","mappingRevision","reviewRevision"] {
        try rejects("replay changed evidence view " + k) {
            let ni = retainThroughInterval(i.replacing("views",i["views"].replacing(k,i["movementReview"])))
            let ns = try s.changed(ni), nq = try ns.request(), na = try ns.approved(nq)
            _ = try S9.apply(nq,approval:na,currentState:selected,owner:owner)
        }
    }
    try rejects("replay changed evidence/input") {
        let ni = row(i,"occurrences",2,"stationID",i["occurrences"].list[0]["stationID"])
        let ns = try s.changed(ni), nq = try ns.request()
        _ = try S9.apply(nq,approval:ns.approved(nq),currentState:selected,owner:owner)
    }
    for k in ["initialSelection","noPreviousSnapshot"] {
        try rejects("initial selection flags required " + k) { _ = try S9.prepare(i,context:s.context.replacing(k,.bool(false)),state:s.state) }
    }
    for token in [s.context["requestID"],i["registeredTripID"],i["inputID"],i["movementReview"]["id"],.string("invented.held.authority"),.string("fixture.new.operationID")] {
        try rejects("workflow collision with retained authority") { _ = try S9.prepare(i,context:s.context.replacing("snapshotArtifactID",token),state:s.state) }
    }
    try rejects("complete history assertion required") {
        let incomplete = s.state.replacing("historyComplete",.bool(false))
        _ = try S9.prepare(i,context:s.context.replacing("selectionStateSHA256",.string(try Codec.digest(incomplete))),state:incomplete)
    }
    try rejects("complete state cannot masquerade as another Trip") { _ = try S9.apply(q,approval:a,currentState:selected.replacing("tripID",.string(Fixtures.id("trp","9"))),owner:owner) }
    for name in b.files.keys.sorted() {
        try rejects("immutable bundle tamper " + name) {
            var files = b.files; files[name] = Data("INVENTED TAMPER".utf8)
            _ = try S9.verify(files,owner:owner,manifestSHA:Codec.hash(b.manifest))
        }
    }
    try test("scalar-distinct Unicode source values remain distinct") {
        let pre: Wire = .string("INVENTED_é"), decomposed: Wire = .string("INVENTED_e\u{301}")
        try expect(pre.text == decomposed.text && !Codec.equal(pre,decomposed))
        try expect(try Codec.encode(S9.read(Codec.encode(pre),100)) != Codec.encode(decomposed))
    }
    try rejects("Unicode canonically equal source key cannot substitute scalars") {
        _ = try reconstruct(i.replacing("source",i["source"].replacing("key",.string(i["source"]["key"].text.precomposedStringWithCanonicalMapping))))
    }
    try rejects("duplicate decoded JSON keys") { _ = try S9.read(Data("{\"x\":1,\"\\u0078\":2}".utf8),100) }
    try rejects("noncanonical JSON") { _ = try S9.read(Data(" {}".utf8),100) }
    for field in ["ownerAuthority","inputID","registeredCheckpoint","source","views","movementReview","occurrences","movements","intervalEvidence","continuity","origin","destination","serviceType","dependencies"] {
        for value: Wire? in [nil,.null] {
            try rejects("missing or null required field " + field) { _ = try reconstruct(i.replacing(field,value)) }
        }
    }
    try rejects("unknown input field") { _ = try reconstruct(i.replacing("surprise",.bool(true))) }
    for n in [0,2,Int.max] { try rejects("unsupported input version",status:"unsupportedVersion") { _ = try reconstruct(i.replacing("schemaVersion",.integer(n))) } }
    for n in [0,2] {
        try rejects("unsupported request version",status:"unsupportedVersion") { try S9.request(q.replacing("schemaVersion",.integer(n)),owner:owner) }
        try rejects("unsupported approval version",status:"unsupportedVersion") { try S9.approval(a.replacing("schemaVersion",.integer(n)),request:q) }
    }
    try bounds(s)
    try filesystem(s,request:q,approval:a,bundle:b,selected:selected)
    print("PASS invented S9 assembly tests=" + String(total))
}

func bounds(_ s: Invented.Scenario) throws {
    let i = s.input, first = i["dependencies"].list[0]
    try rejects("occurrence count bound",status:"resourceLimit") { _ = try reconstruct(i.replacing("occurrences",.array(Array(repeating:i["occurrences"].list[0],count:S9Limits.occurrences + 1)))) }
    try rejects("movement count bound",status:"resourceLimit") { _ = try reconstruct(i.replacing("movements",.array(Array(repeating:i["movements"].list[0],count:S9Limits.movements + 1)))) }
    try rejects("dependency count bound",status:"resourceLimit") { _ = try reconstruct(i.replacing("dependencies",.array(Array(repeating:first,count:S9Limits.dependencies + 1)))) }
    try rejects("individual decoded dependency bound",status:"resourceLimit") { _ = try reconstruct(row(i,"dependencies",0,"bytes",Codec.blob(Data(repeating:65,count:S9Limits.dependency + 1)))) }
    try rejects("unique expanded dependency bound",status:"resourceLimit") {
        let rows: [Wire] = (0..<9).map { n in
            let bytes = Data(repeating:UInt8(n + 65),count:S9Limits.dependency)
            return .object(["id":.string("invented.large." + String(n)),"sha256":.string(Codec.hash(bytes)),"bytes":Codec.blob(bytes),"dependencyDigests":.array([])])
        }
        _ = try S9.closure(.array(rows),roots:rows.map { $0.replacing("bytes",nil).replacing("dependencyDigests",nil) })
    }
    try test("equal dependency bytes count once against expanded bound") {
        let bytes = Data(repeating:65,count:S9Limits.dependency)
        let records: [Wire] = (0..<9).map { n in .object(["id":.string("invented.equal." + String(n)),"sha256":.string(Codec.hash(bytes)),"bytes":Codec.blob(bytes),"dependencyDigests":.array([])]) }
        let pins = records.map { $0.replacing("bytes",nil).replacing("dependencyDigests",nil) }
        try expect(try S9.closure(.array(records),roots:pins).list.count == 9)
    }
    try rejects("token length bound") { _ = try reconstruct(i.replacing("inputID",.string(String(repeating:"a",count:S9Limits.token + 1)))) }
    try rejects("nesting bound",status:"resourceLimit") { _ = try S9.read(Data((String(repeating:"[",count:65) + "0" + String(repeating:"]",count:65)).utf8),1000) }
    // Exercise the decoder gate used by every externally supplied artifact category.
    let limits = [("input",S9Limits.input),("trip",S9Limits.trip),("crosswalk",S9Limits.crosswalk),("context",S9Limits.context),("request",S9Limits.request),("approval",S9Limits.approval),("state",S9Limits.state),("history",S9Limits.history),("manifest",S9Limits.manifest)]
    for (name,limit) in limits {
        try rejects("encoded resource gate " + name,status:"resourceLimit") { _ = try S9.read(Data(repeating:32,count:limit + 1),limit) }
    }
    try rejects("whole bundle bound",status:"resourceLimit") {
        _ = try S9.verify(["history.json":Data(repeating:65,count:S9Limits.bundle + 1)],owner:Invented.owner,manifestSHA:Fixtures.hash)
    }
}

func filesystem(_ s: Invented.Scenario, request q: Wire, approval a: Wire, bundle b: S9.Bundle, selected: Wire) throws {
    let dir = try Fixtures.directory(); defer { try? FileManager.default.removeItem(atPath:dir) }
    let owner = Invented.owner, sha = Codec.hash(b.manifest)
    for fail in ["write:trip.json","write:history.json","rename"] {
        try rejects("precommit failure " + fail,status:"publicationFailure") { try S9IO.publishForTest(b,path:dir + "/precommit",owner:owner,failAt:fail) }
        try test("no partial final bundle after precommit failure") { try expect(!FileManager.default.fileExists(atPath:dir + "/precommit")) }
    }
    try rejects("postcommit durability uncertainty",status:"durabilityUncertain") { try S9IO.publishForTest(b,path:dir + "/uncertain",owner:owner,failAt:"parentFsync") }
    try test("uncertain publication independently verifies without retry") { try expect(try S9IO.readBundle(dir + "/uncertain",owner:owner,manifestSHA:sha).files == b.files) }
    try rejects("uncertain publication never silently overwritten",status:"publicationConflict") { try S9IO.publish(b,path:dir + "/uncertain",owner:owner) }
    try test("same path concurrent publication has exactly one winner") {
        let lock = NSLock(), group = DispatchGroup(); var results: [String] = []
        for _ in 0..<2 {
            group.enter(); DispatchQueue.global().async {
                let result: String
                do { try S9IO.publish(b,path:dir + "/race",owner:owner); result = "success" }
                catch { result = S9CLI.failure(error) }
                lock.lock(); results.append(result); lock.unlock(); group.leave()
            }
        }
        group.wait()
        try expect(results.filter { $0 == "success" }.count == 1 && results.filter { $0 == "rejected status=publicationConflict" }.count == 1)
        try expect(try S9IO.readBundle(dir + "/race",owner:owner,manifestSHA:sha).files == b.files)
    }
    try test("published replay changes no bytes") {
        let replay = try S9.apply(q,approval:a,currentState:selected,owner:owner)
        try S9IO.publish(replay,path:dir + "/race",owner:owner)
        try expect(try S9IO.readBundle(dir + "/race",owner:owner,manifestSHA:sha).files == b.files)
    }
    let input = try Codec.encode(s.input), state = try Codec.encode(s.state), context = try Codec.encode(s.context)
    try Fixtures.write(dir + "/input",input); try Fixtures.write(dir + "/state",state); try Fixtures.write(dir + "/context",context)
    let prepare = ["prepare-snapshot","--owner",owner,"--input",dir + "/input","--input-sha256",Codec.hash(input),"--state",dir + "/state","--state-sha256",Codec.hash(state),"--context",dir + "/context","--context-sha256",Codec.hash(context),"--output",dir + "/request"]
    try test("production CLI prepare is unapproved and deterministic") {
        let result = try command(prepare)
        try expect(result.0 == 0 && result.1 == "prepared approved=false requestSHA256=" + (try Codec.digest(q)) + "\n")
        try expect(try S9IO.read(dir + "/request",sha:Codec.digest(q),limit:S9Limits.request) == Codec.encode(q))
    }
    let requestKeys = ["--owner",owner,"--request",dir + "/request","--request-sha256",try Codec.digest(q)]
    try test("production CLI inspect independently reconstructs approved=false") {
        let result = try command(["inspect-snapshot"] + requestKeys)
        try expect(result.0 == 0 && result.1.contains("approved=false") && result.1.contains("passengerCount=14 segmentCount=1"))
    }
    try test("production CLI explicit approval separate from inspection") {
        let result = try command(["approve-snapshot"] + requestKeys + ["--reviewer","invented.reviewer","--approved-at",Fixtures.time,"--approval-reference","invented.s9.review","--output",dir + "/approval"])
        try expect(result.0 == 0 && result.1 == "approvalCreated approvalSHA256=" + (try Codec.digest(a)) + "\n")
    }
    try test("production CLI apply and standalone verify") {
        let apply = try command(["apply-snapshot"] + requestKeys + ["--approval",dir + "/approval","--approval-sha256",try Codec.digest(a),"--state",dir + "/state","--state-sha256",Codec.hash(state),"--output",dir + "/cli-bundle"])
        try expect(apply.0 == 0 && apply.1 == "snapshotSelected manifestSHA256=" + sha + "\n")
        let verify = try command(["verify-snapshot-bundle","--owner",owner,"--bundle",dir + "/cli-bundle","--manifest-sha256",sha])
        try expect(verify.0 == 0 && verify.1 == "bundleValid unchangedReplay manifestSHA256=" + sha + "\n")
    }
    try test("CLI missing approval holds") {
        let r = try command(["apply-snapshot"] + requestKeys + ["--approval",dir + "/absent","--approval-sha256",try Codec.digest(a),"--state",dir + "/state","--state-sha256",Codec.hash(state),"--output",dir + "/never"])
        try expect(r.0 != 0 && r.1 == "held status=approvalMissing\n")
    }
    try test("files and directories have private modes") {
        var file = stat(), folder = stat()
        try expect(stat(dir + "/request",&file) == 0 && file.st_mode & 0o7777 == 0o600 && file.st_nlink == 1)
        try expect(stat(dir + "/cli-bundle",&folder) == 0 && folder.st_mode & 0o7777 == 0o700)
    }
    try rejects("exclusive request output",status:"publicationConflict") { try S9IO.write(dir + "/request",bytes:input,limit:S9Limits.input) }
    try rejects("relative private path") { _ = try S9IO.read("relative",sha:Codec.hash(input),limit:S9Limits.input) }
    try rejects("repository path") { _ = try PrivateIO.parent(URL(fileURLWithPath:#filePath).deletingLastPathComponent().path + "/blocked") }
    guard symlink(dir + "/input",dir + "/symlink") == 0 else { throw TestFailure.assertion }
    try rejects("symlink leaf") { _ = try S9IO.read(dir + "/symlink",sha:Codec.hash(input),limit:S9Limits.input) }
    guard symlink(dir,dir + "/ancestor-link") == 0 else { throw TestFailure.assertion }
    try rejects("symlink ancestor") { _ = try S9IO.read(dir + "/ancestor-link/input",sha:Codec.hash(input),limit:S9Limits.input) }
    guard link(dir + "/input",dir + "/hardlink") == 0 else { throw TestFailure.assertion }
    try rejects("hard link ambiguity") { _ = try S9IO.read(dir + "/input",sha:Codec.hash(input),limit:S9Limits.input) }
    unlink(dir + "/hardlink")
    chmod(dir + "/input",0o644)
    try rejects("nonprivate file") { _ = try S9IO.read(dir + "/input",sha:Codec.hash(input),limit:S9Limits.input) }
    chmod(dir + "/input",0o600)
    guard mkdir(dir + "/nonprivate",0o755) == 0, chmod(dir + "/nonprivate",0o755) == 0 else { throw TestFailure.assertion }
    try rejects("nonprivate parent directory") { _ = try PrivateIO.parent(dir + "/nonprivate/file") }
    guard mkfifo(dir + "/fifo",0o600) == 0 else { throw TestFailure.assertion }
    try rejects("nonregular file no blocking") { _ = try S9IO.read(dir + "/fifo",sha:Codec.hash(input),limit:S9Limits.input) }
    try Fixtures.write(dir + "/cli-bundle/unexpected",Data("INVENTED EXTRA".utf8))
    try rejects("unexpected hidden bundle catalog") { _ = try S9IO.readBundle(dir + "/cli-bundle",owner:owner,manifestSHA:sha) }
    try test("malicious caller text never reaches diagnostics") {
        let secret = "INVENTED_SECRET_\n/hidden/path_é"
        let result = try command(["inspect-snapshot","--owner",owner,"--request",dir + "/" + secret,"--request-sha256",try Codec.digest(q)])
        try expect(result.0 != 0 && !result.1.contains(secret) && !result.1.contains(dir) && result.1 == "rejected status=unsafePath\n")
        let unknown = try command([secret,"--owner",owner]); try expect(unknown.1 == "rejected status=malformedInput\n")
        try expect(S9CLI.failure(NSError(domain:secret,code:1)) == "rejected status=invalidStructure")
    }
}
do { try main() } catch { print(S9CLI.failure(error)); exit(1) }
