import Foundation
import SQLite3

func check(_ condition: Bool, _ label: String) throws {
    if !condition { throw TestFailure.failed(label) }
}
enum TestFailure: Error { case failed(String) }
func expectFailure(_ expected: RailwayRepositoryError? = nil, _ body: () async throws -> Void) async throws {
    do { try await body() } catch let e as RailwayRepositoryError {
        if let expected { try check(e == expected, "wrong error: \(e), expected \(expected)") }; return
    }
    throw TestFailure.failed("accepted invalid input")
}
struct Synthetic {
    static let a = StationID("stn_0000000000000001")!, b = StationID("stn_0000000000000002")!, c = StationID("stn_0000000000000003")!
    static let retired = MintedIdentifier("stn_0000000000000004")!
    static let l = LineID("lin_0000000000000001")!, op = OperatorID("opr_0000000000000001")!
    static func snapshot(renamed: Bool = false, reversed: Bool = false) -> RailwayArtifactSnapshot {
        let names = [LocalizedRailName(japanese: "Synthetic Same", english: "Caf\u{e9}", korean: "가상-A")!,
                     LocalizedRailName(japanese: "Synthetic Same", english: "Cafe\u{301}", korean: "가상-B")!,
                     LocalizedRailName(japanese: renamed ? "Synthetic Revised" : "Synthetic C", english: "Synthetic C", korean: "가상-C")!]
        let stations = zip([a,b,c], names).map { Station(id: $0, name: $1, coordinate: GeoCoordinate(latitude: 1, longitude: 2)!, lineIDs: [l]) }
        let lines = [RailwayLine(id: l, operatorID: op, name: names[2], topology: RailwayLineTopology(adjacencies: [StationAdjacency(a,b)!,StationAdjacency(b,c)!])!)]
        let ops = [Operator(id: op, name: names[2])]
        let entities = ([a.rawValue,b.rawValue,c.rawValue,l.rawValue,op.rawValue].map { CanonicalEntity(id: MintedIdentifier($0)!, status: .active) }) + [CanonicalEntity(id: retired, status: .retired(successors: [MintedIdentifier(a.rawValue)!]))]
        let aliases = [ExactStationIndex.Alias(stationID: a, value: ExactValue(" Alias ")!), .init(stationID:b,value:ExactValue("Alias-e\u{301}")!), .init(stationID:a,value:ExactValue("Alias-é")!)]
        return .init(stations: reversed ? stations.reversed() : stations, lines: lines, operators: ops, aliases: reversed ? aliases.reversed() : aliases, entities: reversed ? entities.reversed() : entities)
    }
    static func inputs(_ snapshot: RailwayArtifactSnapshot, revision: Int = 1) throws -> RailwayArtifactBuilder.Inputs {
        let content = RailwayArtifactContent(snapshot)
        return .init(registryBytes: try RailwayArtifact.encode(MappingRegistry(revision: revision, entities: content.entities, references: [])),
                     namesBytes: try RailwayArtifact.encode(content.stations.map(\.name)), networkBytes: try RailwayArtifact.encode(content.lines))
    }
}
@main struct StorageTests {
    static func main() async throws {
        let args = CommandLine.arguments
        if args.count == 3 && args[1] == "--emit-transition" {
            let f = try TransitionFixture.make(.replace)
            let temp = FileManager.default.temporaryDirectory.appendingPathComponent("invented-prior-" + UUID().uuidString)
            defer { try? FileManager.default.removeItem(at: temp) }
            let inputs = RailwayArtifactBuilder.Inputs(registryBytes: f.request.previousRegistry, namesBytes: Data("invented old names".utf8), networkBytes: Data("invented old network".utf8))
            _ = try await RailwayArtifactBuilder.build(snapshot: f.before, dataVersion: ExactValue("before")!, inputs: inputs, output: temp)
            _ = try await IT.publish(f.request, snapshot: f.after, dataVersion: ExactValue("after")!, inputs: f.inputs, previous: temp, output: URL(fileURLWithPath: args[2]))
            return
        }
        if args.count == 3 && args[1] == "--emit" {
            let s = Synthetic.snapshot(reversed: true)
            _ = try await RailwayArtifactBuilder.build(snapshot:s,dataVersion:ExactValue("synthetic-v1")!,inputs:Synthetic.inputs(s),output:URL(fileURLWithPath:args[2]))
            return
        }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("synthetic-storage-" + UUID().uuidString)
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:false)
        defer { try? FileManager.default.removeItem(at:directory) }
        func url(_ name: String) -> URL { directory.appendingPathComponent(name) }
        let snapshot = Synthetic.snapshot(), inputs = try Synthetic.inputs(snapshot)
        let first = url("first.sqlite"), repeatURL = url("repeat.sqlite")
        let metadata = try await RailwayArtifactBuilder.build(snapshot:snapshot,dataVersion:ExactValue("synthetic-v1")!,inputs:inputs,output:first)
        let before = try Data(contentsOf:first)
        let repo = try await SQLiteRailwayRepository.open(first,expected:metadata.current)
        let boundary: any RailwayDataRepository = repo
        let all = try await boundary.allStations()
        try check(try RailwayArtifact.encode(all.map(StoredStation.init)) == RailwayArtifact.encode(RailwayArtifactContent(snapshot).stations), "station payload round trip")
        try check(try await boundary.allLines().first?.topology == snapshot.lines[0].topology, "topology round trip")
        try check(try await boundary.allOperators().first?.name == snapshot.operators[0].name, "operator names")
        try check(try await boundary.line(id:Synthetic.l)?.name == snapshot.lines[0].name, "line fetch")
        try check(try await boundary.railwayOperator(id:Synthetic.op)?.id == Synthetic.op, "operator fetch")
        let same = try await boundary.stations(matching:"Synthetic Same")
        try check(same.map(\.station.id) == [Synthetic.a,Synthetic.b] && same[0].lines.map(\.id) == [Synthetic.l] && same[0].operators.map(\.id) == [Synthetic.op], "distinct IDs and context/order")
        for (query, ids) in [("Caf\u{e9}",[Synthetic.a]),("Cafe\u{301}",[Synthetic.b]),(" Alias ",[Synthetic.a]),("Alias-é",[Synthetic.a]),("Alias-e\u{301}",[Synthetic.b]),("Alias",[]),("synthetic same",[]),("Synthetic",[]),("",[])] {
            try check(try await boundary.stations(matching:query).map(\.station.id) == ids, "scalar exact alias/query")
        }
        let d = await repo.diagnostics()
        for _ in 0..<100 { _ = try await boundary.stations(matching:"Synthetic Same"); _ = try await boundary.station(id:Synthetic.c) }
        let after = await repo.diagnostics()
        try check(after.artifactValidationPasses == d.artifactValidationPasses && after.explicitFullLoads == d.explicitFullLoads && after.queryStationDecodes == d.queryStationDecodes + 300, "no ordinary reparse/reindex")
        let identities = try await repo.identities()
        try check(identities == snapshot.entities.sorted { $0.id < $1.id }, "retirement preservation")
        try check(try await boundary.station(id:StationID(Synthetic.retired.rawValue)!) == nil, "no successor following")
        try await boundary.close(); try await boundary.close()
        try await expectFailure(.closed) { _ = try await boundary.station(id:Synthetic.a) }
        let reopened = try await SQLiteRailwayRepository.open(first)
        try check(try await reopened.stations(matching:"Synthetic Same").count == 2, "reopen")
        try await reopened.close()
        try check(try Data(contentsOf:first) == before, "reader never mutates")
        _ = try await RailwayArtifactBuilder.build(snapshot:Synthetic.snapshot(reversed:true),dataVersion:ExactValue("synthetic-v1")!,inputs:inputs,previous:first,output:repeatURL)
        try check(try Data(contentsOf:repeatURL) == before, "byte-identical repeat with no history duplicate")
        // Different process, different Swift hash seed: output must still match.
        let process = Process(); process.executableURL = URL(fileURLWithPath:args[0]); process.arguments = ["--emit",url("process.sqlite").path]
        try process.run(); process.waitUntilExit(); try check(process.terminationStatus == 0, "child builder")
        try check(try Data(contentsOf:url("process.sqlite")) == before, "cross-process SQLite byte equality")
        print("PASS Domain round-trip, exact search, stable IDs/order, readonly reopen, counters, retirement, cross-process byte determinism")

        let changed = Synthetic.snapshot(renamed:true)
        let revision2 = try await RailwayArtifactBuilder.build(snapshot:changed,dataVersion:ExactValue("synthetic-v2")!,inputs:Synthetic.inputs(changed,revision:2),previous:first,output:url("revision2.sqlite"))
        try check(revision2.revisions.count == 2 && revision2.revisions[0] == metadata.current, "append-only revision history")
        let next = try await SQLiteRailwayRepository.open(url("revision2.sqlite"),expected:revision2.current)
        let nextIdentities = try await next.identities(), nextStation = try await next.station(id:Synthetic.c)
        try check(nextIdentities == identities && nextStation?.name.japanese == "Synthetic Revised", "data revision retains identity")
        try await next.close()
        let secondRepeat = url("second-repeat.sqlite")
        _ = try await RailwayArtifactBuilder.build(snapshot:changed,dataVersion:ExactValue("synthetic-v2")!,inputs:Synthetic.inputs(changed,revision:2),previous:url("revision2.sqlite"),output:secondRepeat)
        try check(try Data(contentsOf:secondRepeat) == Data(contentsOf:url("revision2.sqlite")), "multi-revision repeat bytes")
        // Changing an earlier history entry without updating the current pinned
        // revision must fail the revision chain, even when all fields look valid.
        let tamperedURL = url("tampered-history.sqlite")
        try FileManager.default.copyItem(at:url("revision2.sqlite"),to:tamperedURL)
        let tampered = RailwaySQLiteConnectionTestEdit(revision2)
        let edit = try RailwaySQLiteConnection(path:tamperedURL.path,writing:true)
        try edit.withStatement("UPDATE metadata SET payload=?",bindings:[try RailwayArtifact.encode(tampered)]) { q in
            try check(sqlite3_step(q) == SQLITE_DONE,"history mutation fixture")
        }
        try edit.close()
        try await expectFailure(.historyMismatch) { _ = try await SQLiteRailwayRepository.open(tamperedURL,expected:revision2.current) }

        try await expectFailure(.incompatibleData) { _ = try await SQLiteRailwayRepository.open(first,expected:revision2.current) }
        try await expectFailure(.historyMismatch) { _ = try await RailwayArtifactBuilder.build(snapshot:changed,dataVersion:ExactValue("synthetic-v1")!,inputs:Synthetic.inputs(changed),previous:first,output:url("reused-version.sqlite")) }
        try await expectFailure(.unavailable) { _ = try await RailwayArtifactBuilder.build(snapshot:snapshot,dataVersion:ExactValue("synthetic-v1")!,inputs:inputs,output:first) }
        let missing = RailwayArtifactSnapshot(stations:Array(snapshot.stations.dropLast()),lines:snapshot.lines,operators:snapshot.operators,aliases:snapshot.aliases,entities:snapshot.entities)
        try await expectFailure(.malformed) { _ = try await RailwayArtifactBuilder.build(snapshot:missing,dataVersion:ExactValue("bad")!,inputs:inputs,output:url("missing.sqlite")) }
        let noHistory = RailwayArtifactSnapshot(stations:snapshot.stations,lines:snapshot.lines,operators:snapshot.operators,aliases:snapshot.aliases,entities:snapshot.entities.filter { $0.id != Synthetic.retired })
        try await expectFailure(.identityMigrationRequired) { _ = try await RailwayArtifactBuilder.build(snapshot:noHistory,dataVersion:ExactValue("bad")!,inputs:Synthetic.inputs(noHistory),previous:first,output:url("lost.sqlite")) }
        let firstRevision = metadata.current
        let changedRegistryInputs = firstRevision.inputs.map { $0.role == "registry" ? RailwayBuildInput(role:$0.role,sha256:String(repeating:"0",count:64)) : $0 }
        let invalidSameRegistryRevision = RailwayArtifactRevision(dataVersion:ExactValue("synthetic-conflict")!,registryRevision:firstRevision.registryRevision,inputs:changedRegistryInputs,contentSHA256:firstRevision.contentSHA256,previousSHA256:try RailwayArtifact.digest(RailwayArtifact.encode(firstRevision)))
        try await expectFailure(.historyMismatch) { try RailwayArtifact.validate(.init(schemaVersion:1,revisions:[firstRevision,invalidSameRegistryRevision])) }
        print("PASS compatible data revisions, metadata pinning, history retention, no overwrite, invalid membership, identity-transition hold")

        for (i,sql,expected) in [
            ("schema","PRAGMA user_version=999",RailwayRepositoryError.unsupportedSchema),
            ("index","DELETE FROM search",.malformed),
            ("alias","DELETE FROM aliases",.malformed),
            ("payload","UPDATE stations SET payload=x'7b7d'",.malformed),
            ("schema-extra","CREATE TABLE unexpected (x)",.malformed),
            ("application","PRAGMA application_id=0",.malformed)
        ] {
            let path=url(i+".sqlite"); try FileManager.default.copyItem(at:first,to:path)
            let db=try RailwaySQLiteConnection(path:path.path,writing:true); try db.execute(sql); try db.close()
            let bytes=try Data(contentsOf:path)
            try await expectFailure(expected) { _ = try await SQLiteRailwayRepository.open(path) }
            try check(try Data(contentsOf:path)==bytes,"rejection does not mutate")
        }
        let oversized = url("oversized.sqlite")
        _ = FileManager.default.createFile(atPath:oversized.path,contents:Data())
        let oversizedHandle = try FileHandle(forWritingTo:oversized)
        try oversizedHandle.truncate(atOffset:UInt64(RailwayArtifact.maxBytes)+1); try oversizedHandle.close()
        try await expectFailure(.resourceLimit) { _ = try await SQLiteRailwayRepository.open(oversized) }
        let junk=url("junk"); try Data("not SQLite".utf8).write(to:junk)
        try await expectFailure(.malformed) { _ = try await SQLiteRailwayRepository.open(junk) }
        let symlink=url("symlink"); try FileManager.default.createSymbolicLink(at:symlink,withDestinationURL:first)
        try await expectFailure(.malformed) { _ = try await SQLiteRailwayRepository.open(symlink) }
        let journal=URL(fileURLWithPath:first.path+"-journal"); try Data([0]).write(to:journal)
        try await expectFailure(.malformed) { _ = try await SQLiteRailwayRepository.open(first) }; try FileManager.default.removeItem(at:journal)
        try check(try Data(contentsOf:first)==before,"original artifact retained")
        print("PASS unsupported/malformed schema, corrupted content/index, symlinks and sidecars rejected without mutation")
        try await transitionChecks(directory)
        print("SQLite engine: \(String(cString:sqlite3_libversion()))")
        print("All synthetic storage checks passed. SQLite bytes: \(before.count); SHA-256: \(RailwayArtifact.digest(before))")
    }
}

func RailwaySQLiteConnectionTestEdit(_ metadata: RailwayArtifactMetadata) -> RailwayArtifactMetadata {
    var revisions = metadata.revisions
    let r = revisions[0]
    revisions[0] = .init(dataVersion:ExactValue("altered-prior-version")!,registryRevision:r.registryRevision,inputs:r.inputs,contentSHA256:r.contentSHA256,previousSHA256:r.previousSHA256)
    return .init(schemaVersion:metadata.schemaVersion,revisions:revisions)
}
