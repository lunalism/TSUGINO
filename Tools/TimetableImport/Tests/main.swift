import Foundation
import Darwin

enum TestFailure: Error { case assertion }
var total = 0
func expect(_ v: @autoclosure () throws -> Bool) throws { guard try v() else { throw TestFailure.assertion } }
func test(_ name: String, _ body: () throws -> Void) throws {
    do { try body(); total += 1; print("PASS " + name) }
    catch { print("FAIL " + name + " " + ImportCLI.failure(error)); throw error }
}
func rejects(_ name: String, _ body: () throws -> Void) throws {
    try test(name) { do { try body(); throw TestFailure.assertion } catch is TestFailure { throw TestFailure.assertion } catch {} }
}
func rows(_ i: Wire, _ key: String, _ transform: ([Wire]) -> [Wire]) -> Wire { i.replacing(key,.array(transform(i[key].list))) }
func row(_ i: Wire, _ key: String, _ n: Int, _ field: String, _ value: Wire?) -> Wire {
    rows(i,key) { a in var a = a; a[n] = a[n].replacing(field,value); return a }
}
func command(_ args: [String]) throws -> (Int32,String) {
    let p = Process(), pipe = Pipe(); p.executableURL = URL(fileURLWithPath:CommandLine.arguments[1]); p.arguments = args
    p.standardOutput = pipe; p.standardError = pipe; try p.run()
    let bytes = pipe.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
    return (p.terminationStatus,String(decoding:bytes,as:UTF8.self))
}
func main() throws {
    let e = try ImportFixtures.external(), i = try ImportFixtures.input(e), q = try ImportFixtures.request(i,e), a = try ImportFixtures.approved(q,e)
    let b = try ImportAuthority.apply(q,approval:a,currentState:ImportFixtures.state(i),external:e)
    func outcome(_ input: Wire) throws -> ImportOutcome { try ImportAuthority.convert(input,external:e).outcome }
    func status(_ input: Wire, _ expected: String) throws { try expect(ImportAuthority.status(outcome(input)).hasPrefix("status=" + expected)) }
    func active(_ input: Wire) throws -> TimetableOccurrenceFacts { guard case .success(let f) = try outcome(input) else { throw TestFailure.assertion }; return f }
    func cal(_ input: Wire, _ key: String, _ value: Wire?) -> Wire { input.replacing("calendar",input["calendar"].replacing(key,value)) }
    func exception(_ date: String, _ action: String) -> Wire { .object(["service":i["service"],"date":.string(date),"action":.string(action)]) }
    func event(_ state: String, _ clock: String = "11:00:07") -> Wire {
        if state == "missing" { return .object(["state":.string(state)]) }
        var v: Wire = .object(["state":.string(state),"clock":.string(clock)])
        if state == "exact" || state == "estimated" { v = v.replacing("evidence",.string("invented." + state)) }; return v
    }
    try test("weekly active fourteen visits twenty-eight exact events") {
        let f = try active(i); try expect(f.visits.count == 14 && ImportAuthority.summary(f) == "visits=14 exact=28 estimated=0 missing=0")
        try expect(i["calendar"]["exceptions"].list.count == 17)
    }
    let off = cal(i,"baselines",.array([i["calendar"]["baselines"].list[0].replacing("weekdays",.array(Array(repeating:.bool(false),count:7)))]))
    try test("baseline weekday off") { try status(off,"inactive") }
    try test("explicit removal") { try status(cal(i,"exceptions",.array([exception(ImportFixtures.date,"remove") ])),"inactive") }
    try test("explicit addition overrides off") { try status(cal(off,"exceptions",.array([exception(ImportFixtures.date,"add") ])),"active") }
    try test("addition outside baseline inside coverage") { try status(cal(i.replacing("serviceDate",.string("2041-06-20")),"exceptions",.array([exception("2041-06-20","add")])),"active") }
    try test("outside coverage unavailable") { try status(i.replacing("serviceDate",.string("2041-07-01")),"insufficientEvidence") }
    let only = cal(cal(i,"mode",.string("exceptionOnly")),"baselines",.array([]))
    try test("complete exception only active") { try status(cal(only,"exceptions",.array([exception(ImportFixtures.date,"add")])),"active") }
    try test("complete exception only unlisted inactive") { try status(only,"inactive") }
    try test("exception only incompleteness") { try status(cal(only,"completenessEvidence",nil),"insufficientEvidence") }
    for actions in [["add","add"],["add","remove"]] {
        try test("duplicate conflicting exception " + actions.joined()) { try status(cal(i,"exceptions",.array(actions.map { exception(ImportFixtures.date,$0) })),"invalid") }
    }
    try test("malformed exception action") { try status(cal(i,"exceptions",.array([exception(ImportFixtures.date,"invented.bad")])),"invalid") }
    try test("missing calendar evidence") { try status(i.replacing("calendar",.object([:])),"insufficientEvidence") }
    try test("missing mode") { try status(cal(i,"mode",nil),"insufficientEvidence") }
    try test("incompatible baseline") { try status(cal(only,"baselines",i["calendar"]["baselines"]),"invalid") }
    try test("multiple baselines") { try status(cal(i,"baselines",.array(Array(repeating:i["calendar"]["baselines"].list[0],count:2))),"invalid") }
    try rejects("profile mismatch") { _ = try outcome(i.replacing("profile",i["profile"].replacing("profileID",.string("invented.other")))) }
    for field in ["manifestSHA256","tripSHA256","crosswalkSHA256"] {
        try rejects("S9 pin mismatch " + field) { _ = try outcome(i.replacing("s9",i["s9"].replacing(field,.string(String(repeating:"f",count:64))))) }
    }
    try test("wrong occurrence rejected") { try status(row(i,"visits",0,"occurrence",.string("invented.wrong")),"invalid") }
    try test("original index mismatch") { try status(row(i,"visits",0,"originalIndex",.integer(999)),"invalid") }
    try test("visit count missing") { try status(rows(i,"visits",{ Array($0.dropLast()) }),"insufficientEvidence") }
    try test("visit count extra") { try status(rows(i,"visits",{ $0 + [$0[0]] }),"invalid") }
    try test("duplicate visit index") { try status(row(i,"visits",1,"originalIndex",.integer(0)),"invalid") }
    try test("missing event remains missing") { let f = try active(row(i,"visits",0,"arrival",event("missing"))); try expect(f.visits[0].arrival == .missing) }
    try test("estimated remains estimated") { let f = try active(row(i,"visits",0,"arrival",event("estimated","23:59:59"))); if case .estimated = f.visits[0].arrival {} else { throw TestFailure.assertion } }
    try test("unqualified held") { try status(row(i,"visits",0,"arrival",event("unqualified")),"insufficientEvidence") }
    try test("absent event insufficient not missing") { try status(row(i,"visits",0,"arrival",nil),"insufficientEvidence") }
    for clock in ["xx:00:00","11:60:00","11:00:60","11:00:0 "] {
        try test("malformed clock " + clock) { try status(row(i,"visits",0,"arrival",event("exact",clock)),"invalid") }
    }
    try test("extended hour preserves service date") {
        let extended = rows(i,"visits") { $0.map { $0.replacing("arrival",event("exact","27:11:13")).replacing("departure",event("exact","27:11:13")) } }
        let f = try active(extended); try expect(f.binding.address.serviceDate.label == ImportFixtures.date)
        if case .exact(let t) = f.visits[0].arrival, case .value(let day) = ImportCivilTime.date(ImportFixtures.date) {
            try expect(t.date.timeIntervalSince1970 == Double(day * 86400 + 27 * 3600 + 11 * 60 + 13 - 7200))
        } else { throw TestFailure.assertion }
    }
    try test("unsupported extended hour") { try status(row(i,"visits",0,"arrival",event("exact","72:00:00")),"unsupported") }
    try test("fixed explicit offset") { let f = try active(i); if case .exact(let t) = f.visits[0].arrival { try expect(t.date.timeIntervalSince1970.isFinite) } }
    func interval(_ start: Int64, _ end: Int64, _ offset: Int) -> Wire { .object(["start":.integer(Int(start)),"end":.integer(Int(end)),"offset":.integer(offset)]) }
    func zone(_ rows: [Wire]) -> Wire { .object(["kind":.string("transitions"),"intervals":.array(rows)]) }
    guard case .value(let day) = ImportCivilTime.date(ImportFixtures.date) else { throw TestFailure.assertion }
    let local = day * 86400 + 11 * 3600 + 7
    try test("valid transition table") { try status(i.replacing("zone",zone([interval(ImportCivilTime.minimum,local-100000,0),interval(local-100000,ImportCivilTime.maximum,7200)])),"active") }
    try test("zone gap") { try status(i.replacing("zone",zone([interval(ImportCivilTime.minimum,local-100,0),interval(local-100,ImportCivilTime.maximum,3600)])),"insufficientEvidence") }
    try test("zone fold") { try status(i.replacing("zone",zone([interval(ImportCivilTime.minimum,local-100,3600),interval(local-100,ImportCivilTime.maximum,0)])),"insufficientEvidence") }
    try test("incomplete zone coverage") { try status(i.replacing("zone",zone([interval(local,local+3600,0)])),"insufficientEvidence") }
    for value in [Wire.null,.integer(123),.array([])] {
        try rejects("nested non-string zone kind") { _ = try outcome(i.replacing("zone",.object(["kind":value]))) }
    }
    try test("binding faults precede time faults on active date") {
        let bad = row(row(i,"visits",0,"occurrence",.string("invented.wrong")),"visits",0,"arrival",event("exact","xx:00:00"))
        guard case .invalid(let failure) = try outcome(bad) else { throw TestFailure.assertion }
        try expect(failure.reason == .occurrenceBinding)
    }
    try test("aggregate severity preserves earliest qualification diagnostic") {
        let bad = row(row(i,"visits",0,"arrival",nil),"visits",1,"arrival",event("exact","xx:00:00"))
        guard case .invalid(let failure) = try outcome(bad) else { throw TestFailure.assertion }
        try expect(failure.reason == .timeQualification && failure.diagnostic.event?.originalIndex == 0)
    }
    try test("overlapping zone intervals") { try status(i.replacing("zone",zone([interval(ImportCivilTime.minimum,local+1,0),interval(local,ImportCivilTime.maximum,0)])),"invalid") }
    try test("arithmetic overflow and range") {
        try expect(ImportCivilTime.localCoordinate(day:Int64.max,seconds:1) == nil)
        try expect(ImportCivilTime.add(Int64.max,1) == nil)
        try status(i.replacing("zone",.object(["kind":.string("fixed"),"offset":.integer(Int.max)])),"invalid")
    }
    for key in ["boarding","alighting"] { for value in ["allowed","prohibited","unknown"] {
        try test(key + " " + value) {
            var p: Wire = .object(["value":.string(value)])
            if value != "unknown" { p = p.replacing("evidence",.string("invented." + value)) }
            _ = try active(row(i,"visits",0,key,p))
        }
    } }
    try test("missing eligibility evidence") { try status(row(i,"visits",0,"boarding",.object(["value":.string("allowed")])),"insufficientEvidence") }
    try test("single execution") { try status(i,"active") }
    try test("multiple executions unsupported") { try status(i.replacing("executionEvidence",.string("invented.singleExecution")).replacing("evidence",.array(i["evidence"].list.map { $0["assertion"].text == "singleExecution" ? $0.replacing("assertion",.string("multipleExecutions")) : $0 })),"unsupported") }
    try test("unknown multiplicity held") { try status(i.replacing("evidence",.array(i["evidence"].list.map { $0["assertion"].text == "singleExecution" ? $0.replacing("assertion",.string("unknownMultiplicity")) : $0 })),"insufficientEvidence") }
    try test("equal chronology allowed") { try status(i,"active") }
    try test("chronology conflict") { try status(row(i,"visits",2,"arrival",event("exact","10:00:07")),"invalid") }
    try test("missing estimated excluded from exact chronology") {
        _ = try active(row(row(i,"visits",0,"arrival",event("estimated","23:59:59")),"visits",0,"departure",event("missing")))
    }
    try test("inactive skips malformed event and occurrence") { try status(row(row(off,"visits",0,"arrival",event("exact","xx:00:00")),"visits",0,"occurrence",.string("invented.wrong")),"inactive") }
    try test("inactive cannot skip invalid zone envelope") { try status(off.replacing("zone",zone([interval(ImportCivilTime.minimum,local+1,0),interval(local,ImportCivilTime.maximum,0)])),"invalid") }
    try test("Domain binding mismatch") {
        let f = try active(i), other = TimetableOccurrenceBinding(address:.init(viewID:.init(UUID(uuidString:"bbbbbbbb-bbbb-4ccc-8ddd-eeeeeeeeeeee")!),tripID:f.binding.trip.id,serviceDate:f.binding.address.serviceDate),trip:f.binding.trip)!
        let visit = TimetableVisitFacts(binding:other,originalIndex:0,arrival:.missing,departure:.missing,boarding:.unknown,alighting:.unknown)!
        try expect(TimetableOccurrenceFacts(binding:f.binding,visits:[visit] + f.visits.dropFirst()) == nil)
    }
    try test("deterministic facts and Domain roundtrip") {
        let f = try active(i), first = try ImportAuthority.facts(f,input:i), second = try ImportAuthority.facts(active(i),input:i)
        try expect(first == second && !String(decoding:first,as:UTF8.self).contains("clock"))
        let restored = try ImportAuthority.reconstructFacts(first,external:e)
        try expect(restored.binding.matches(f.binding) && ImportAuthority.facts(restored,input:i) == first)
    }
    for field in ["factsBytes","inputBytes","requestID","operation","s9","profile"] {
        try rejects("request tamper " + field) { _ = try ImportAuthority.request(q.replacing(field,.string("INVENTED TAMPER")),external:e) }
    }
    try rejects("profile approval mismatch") { _ = try ImportAuthority.External(owner:e.owner,s9Files:e.s9.files,manifestSHA:Codec.hash(e.s9.manifest),review:Data("INVENTED changed review".utf8),approval:e.approval) }
    try rejects("missing import approval") { _ = try ImportAuthority.apply(q,approval:nil,currentState:ImportFixtures.state(i),external:e) }
    try rejects("import approval mismatch") { _ = try ImportAuthority.apply(q,approval:a.replacing("reviewID",.string("invented.other")),currentState:ImportFixtures.state(i),external:e) }
    try rejects("profile approval cannot approve import") { _ = try ImportAuthority.apply(q,approval:ImportAuthority.read(e.approval,ImportLimits.approval),currentState:ImportFixtures.state(i),external:e) }
    try rejects("missing dependency") { _ = try outcome(rows(i,"dependencies",{ Array($0.dropFirst()) })) }
    try rejects("tampered dependency") { _ = try outcome(row(i,"dependencies",0,"bytes",Codec.blob(Data("INVENTED CHANGE".utf8)))) }
    let root = i["dependencies"].list[0], pin = root.replacing("bytes",nil).replacing("dependencyDigests",nil)
    try rejects("dependency cycle") { _ = try outcome(row(i,"dependencies",0,"dependencyDigests",.array([pin]))) }
    try rejects("unused dependency") { _ = try outcome(rows(i,"dependencies",{ $0 + [root.replacing("id",.string("invented.zzz.unused"))] })) }
    let imported = ImportAuthority.importedState(ImportFixtures.state(i),bundle:b)
    try test("initial import and full bundle verification") { try expect(!b.replay); _ = try ImportAuthority.verify(b.files,manifestSHA:Codec.hash(b.manifest),external:e) }
    try rejects("duplicate initial import") { _ = try ImportAuthority.prepare(i,state:imported,requestID:"invented.second",approvalReviewID:"invented.second.review",outputID:"invented.second.output",external:e) }
    try rejects("missing completeness assertion") { _ = try ImportAuthority.apply(q,approval:a,currentState:ImportFixtures.state(i).replacing("historyComplete",.bool(false)),external:e) }
    try test("exact replay no new approval or history") { let replay = try ImportAuthority.apply(q,approval:nil,currentState:imported,external:e); try expect(replay.replay && replay.files == b.files) }
    for field in ["serviceDate","viewID","run","profile","s9","zone","calendar","visits"] {
        try rejects("changed input cannot replay " + field) {
            let changed = i.replacing(field,field == "serviceDate" ? .string("2041-05-07") : .string("INVENTED CHANGE"))
            let bytes = try Codec.encode(changed)
            _ = try ImportAuthority.apply(q.replacing("inputBytes",Codec.blob(bytes)).replacing("inputSHA256",.string(Codec.hash(bytes))),approval:nil,currentState:imported,external:e)
        }
    }
    try rejects("changed valid request cannot replace") {
        let newer = try ImportFixtures.request(i.replacing("inputID",.string("invented.new-input")),e)
        _ = try ImportAuthority.apply(newer,approval:ImportFixtures.approved(newer,e),currentState:imported,external:e)
    }
    for field in ["facts.json","history.json","manifest.json"] {
        try rejects("bundle tamper " + field) { var bad = b.files; bad[field] = Data("INVENTED CHANGE".utf8); _ = try ImportAuthority.verify(bad,manifestSHA:Codec.hash(b.manifest),external:e) }
    }
    for field in ["inputID","ownerAuthority","source","revisions","viewID","serviceDate","calendar","zone","visits","dependencies"] {
        try rejects("missing field " + field) { _ = try outcome(i.replacing(field,nil)) }
        try rejects("null field " + field) { _ = try outcome(i.replacing(field,.null)) }
    }
    try rejects("unknown field") { _ = try outcome(i.replacing("inventedUnknown",.bool(true))) }
    try rejects("duplicate JSON keys") { _ = try ImportAuthority.read(Data("{\"a\":1,\"a\":1}".utf8),ImportLimits.input) }
    try rejects("excess nesting") { _ = try ImportAuthority.read(Data((String(repeating:"[",count:33) + "0" + String(repeating:"]",count:33)).utf8),ImportLimits.input) }
    try test("scalar-distinct Unicode retains byte distinction") {
        try expect(!ImportAuthority.exact("é","e\u{301}"))
        try expect(!Codec.equal(.string("é"),.string("e\u{301}")))
    }
    try rejects("scalar-distinct run cannot rebind") { _ = try outcome(i.replacing("run",.string("invented.e\u{301}"))) }
    for (name,limit) in [("input",ImportLimits.input),("review",ImportLimits.review),("approval",ImportLimits.approval),("facts",ImportLimits.facts),("request",ImportLimits.request),("state",ImportLimits.state),("history",ImportLimits.history),("manifest",ImportLimits.manifest)] {
        try test("byte boundary " + name) { try expect(try S9.bounded(Data(repeating:65,count:limit),limit).count == limit) }
        try rejects("byte over bound " + name) { _ = try S9.bounded(Data(repeating:65,count:limit+1),limit) }
    }
    try rejects("visits resource bound") { _ = try outcome(rows(i,"visits",{ Array(repeating:$0[0],count:257) })) }
    try rejects("exceptions resource bound") { _ = try outcome(cal(i,"exceptions",.array(Array(repeating:exception(ImportFixtures.date,"add"),count:257)))) }
    try rejects("zone interval resource bound") { _ = try outcome(i.replacing("zone",zone(Array(repeating:interval(ImportCivilTime.minimum,ImportCivilTime.maximum,0),count:9)))) }
    try rejects("dependency count resource bound") { _ = try outcome(rows(i,"dependencies",{ Array(repeating:$0[0],count:65) })) }
    try rejects("dependency bytes resource bound") { _ = try outcome(row(i,"dependencies",0,"bytes",Codec.blob(Data(repeating:65,count:ImportLimits.dependency+1)))) }
    try test("converter token resource bound typed unsupported") { try status(row(i,"visits",0,"mappingRevision",.string(String(repeating:"i",count:65))),"unsupported") }
    try rejects("source key resource bound") { _ = try outcome(i.replacing("service",.string(String(repeating:"i",count:257)))) }
    func depRows(_ sizes: [Int]) -> [Wire] {
        sizes.enumerated().map { n,size in
            let bytes = Data(repeating:UInt8(65+n%26),count:size)
            return .object(["id":.string(String(format:"invented.review-dependency.%03d",n)),"sha256":.string(Codec.hash(bytes)),"bytes":Codec.blob(bytes),"dependencyDigests":.array([])])
        }
    }
    func pins(_ rr: [Wire]) -> [Wire] { rr.map { $0.replacing("bytes",nil).replacing("dependencyDigests",nil) } }
    try test("independent expanded dependency budget exact one MiB") {
        let rr = depRows(Array(repeating:32768,count:32))
        try expect(ImportAuthority.dependencies(.array(rr),roots:pins(rr)).list.count == 32)
    }
    try rejects("independent expanded dependency budget one byte over") {
        let rr = depRows(Array(repeating:32768,count:32) + [1])
        _ = try ImportAuthority.dependencies(.array(rr),roots:pins(rr))
    }
    try test("independent dependency count exact sixty-four") {
        let rr = depRows(Array(repeating:1,count:64))
        try expect(ImportAuthority.dependencies(.array(rr),roots:pins(rr)).list.count == 64)
    }
    try rejects("independent dependency count sixty-five") {
        let rr = depRows(Array(repeating:1,count:65))
        _ = try ImportAuthority.dependencies(.array(rr),roots:pins(rr))
    }
    try test("independent nesting exactly thirty-two") {
        _ = try ImportAuthority.read(Data((String(repeating:"[",count:32) + "0" + String(repeating:"]",count:32)).utf8),ImportLimits.input)
    }
    try test("independent eight contiguous zone intervals") {
        let width = (ImportCivilTime.maximum-ImportCivilTime.minimum)/8
        let rr = (0..<8).map { n in interval(ImportCivilTime.minimum+Int64(n)*width,n==7 ? ImportCivilTime.maximum : ImportCivilTime.minimum+Int64(n+1)*width,7200) }
        try status(i.replacing("zone",zone(rr)),"active")
    }
    try test("independent maximum supported extended hour") {
        let changed = rows(i,"visits") { $0.map { $0.replacing("arrival",event("exact","71:59:59")).replacing("departure",event("exact","71:59:59")) } }
        _ = try active(changed)
    }
    try test("independent unknown zone string remains unsupported") {
        try status(i.replacing("zone",.object(["kind":.string("invented.future-zone")])),"unsupported")
    }
    try test("independent source key scalar byte distinction") {
        try expect(ImportAuthority.exact("invented.é","invented.é"))
        try expect(!ImportAuthority.exact("invented.é","invented.e\u{301}"))
    }
    try test("independent unknown permission cannot carry affirmative evidence") {
        try status(row(i,"visits",0,"boarding",.object(["value":.string("unknown"),"evidence":.string("invented.allowed")])),"invalid")
    }
    try occurrenceLocatorTests()
    try filesystem(i,q,a,b,imported,e)
    print("PASS TimetableImport invented suite: \(total) non-overlapping cases")
}

do { try main() } catch { print(ImportCLI.failure(error)); exit(1) }
