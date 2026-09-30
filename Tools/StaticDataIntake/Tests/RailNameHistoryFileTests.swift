import Foundation

private func historyRejects(_ body: () throws -> Void) throws {
    do { try body() } catch is TestFailure { throw TestFailure(message:"unexpected test failure") }
    catch { return }
    throw TestFailure(message:"invalid history accepted")
}
private func historyJSON(_ value: Any) throws -> Data {
    try JSONSerialization.data(withJSONObject:value,options:[.sortedKeys,.withoutEscapingSlashes])
}
private func historyFixture() throws -> RailNameHistoryArtifact {
    let input = try SyntheticNames.railwayInput()
    let built = try RailNames.build(input,records:SyntheticNames.titleRecords(input))
    return .init(names:built.history,titles:built.titleBindings.history)
}
let railNameHistoryFileTests: [(name:String,body:(Workspace) async throws -> Void)] = [
    ("name history: lossless v1 conversion preserves all records and deterministic v2 repeats", { w in
        let original = try historyFixture()
        let old = NetworkJSON.encode(original)
        let migrated = try RailNameHistoryFile.encode(RailNameHistoryFile.decode(old))
        let file = try w.write(migrated,named:"history-v2.json")
        let restored = try RailNameHistoryFile.read(file.path,root:testRepositoryRoot)
        try check(NetworkJSON.encode(restored) == old,"conversion lost records/provenance/order")
        try check(try RailNameHistoryFile.encode(restored) == migrated,"repeat changed history")
        let input = try SyntheticNames.railwayInput()
        let repeated = try RailNames.build(input,records:SyntheticNames.titleRecords(input),previousNames:restored.names,previousTitles:restored.titles)
        try check(try RailNameHistoryFile.encode(.init(names:repeated.history,titles:repeated.titleBindings.history)) == migrated,"repeat duplicated history")
    }),
    ("name history: scalar-distinct immutable evidence is never collapsed", { _ in
        let original = try historyFixture()
        var a = original.names.observations[0], b = a
        let sighting = a.memberProvenance[0]
        func retained(_ value: String) -> RetainedRailName {
            .init(sourceID:sighting.sourceID,namespace:.gtfsStopID,providerKey:SyntheticNames.x("synthetic-key"),original:.init(language:SyntheticNames.x("ja"),value:SyntheticNames.x(value),source:sighting.reference))
        }
        a.registryOriginals = [retained("Caf\u{e9}")]; b.registryOriginals = [retained("Cafe\u{301}")]
        let history = RailNameHistoryArtifact(names:.init(observations:[a,b]),titles:.init())
        let restored = try RailNameHistoryFile.decode(RailNameHistoryFile.encode(history))
        try check(restored.names.observations == [a,b] && a != b,"scalar-distinct values folded")
        try check(NetworkJSON.encode(restored) == NetworkJSON.encode(history),"exact encoding lost")
    }),
    ("name history: writer and legacy reader handle history beyond former 16 MiB", { w in
        var evidence = try historyFixture().names.observations[0]
        let sighting = evidence.memberProvenance[0]
        // Many distinct retained originals, rather than duplicate history entries.
        evidence.registryOriginals = (0..<6000).map { n in
            .init(sourceID:sighting.sourceID,namespace:.gtfsStopID,providerKey:SyntheticNames.x("synthetic-\(n)"),original:.init(language:SyntheticNames.x("ja"),value:SyntheticNames.x("\(n)-"+String(repeating:"s",count:800)+"e\u{301}"),source:sighting.reference))
        }
        let choice = SyntheticNames.choice(evidence)
        var names = NameHistory(choices:[choice],observations:[evidence])
        names.append(choice,evidence:evidence)
        try names.validate()
        let original = RailNameHistoryArtifact(names:names,titles:.init())
        let old = NetworkJSON.encode(original)
        try check(old.count > RailNameHistoryFile.storedLimit,"fixture did not reproduce old failure")
        let legacyFile = try w.write(old,named:"large-v1.json")
        let converted = try RailNameHistoryFile.encode(RailNameHistoryFile.read(legacyFile.path,root:testRepositoryRoot))
        try check(converted.count < RailNameHistoryFile.storedLimit,"evidence not shared")
        let newFile = try w.write(converted,named:"large-v2.json")
        let restored = try RailNameHistoryFile.read(newFile.path,root:testRepositoryRoot)
        try check(NetworkJSON.encode(restored) == old,"large history lost original evidence")
        try check(try RailNameHistoryFile.encode(restored) == converted,"large repeat differs")
        var verified = restored.names; try verified.validate()
        // Legitimate but excessive unique retained evidence is rejected by the
        // writer before publishing, not truncated to fit the reader.
        for count in [3,10] {
            let distinct = (0..<count).map { n -> NameEvidence in
                var next = evidence
                next.registryOriginals.append(.init(sourceID:sighting.sourceID,namespace:.gtfsStopID,providerKey:SyntheticNames.x("revision-\(n)"),original:.init(language:SyntheticNames.x("ja"),value:SyntheticNames.x("Synthetic retained revision \(n)"),source:sighting.reference)))
                return next
            }
            let oversized = RailNameHistoryArtifact(names:.init(observations:distinct),titles:.init())
            try historyRejects { _ = try RailNameHistoryFile.encode(oversized) }
        }
    }),
    ("name history: dangling corrupt unused and duplicate evidence fails closed", { _ in
        let bytes = try RailNameHistoryFile.encode(historyFixture())
        let original = try JSONSerialization.jsonObject(with:bytes) as! [String:Any]
        var missing = original; missing["evidence"] = [String:Any]()
        try historyRejects { _ = try RailNameHistoryFile.decode(historyJSON(missing)) }
        var corrupt = original; var pool = corrupt["evidence"] as! [String:Any]
        let key = pool.keys.sorted()[0]; pool[key] = ["changed":true]; corrupt["evidence"] = pool
        try historyRejects { _ = try RailNameHistoryFile.decode(historyJSON(corrupt)) }
        var unused = original; pool = unused["evidence"] as! [String:Any]
        let extra: [String:Any] = ["synthetic":"unused"]
        pool[sha256Hex(try historyJSON(extra))] = extra; unused["evidence"] = pool
        try historyRejects { _ = try RailNameHistoryFile.decode(historyJSON(unused)) }
        try historyRejects { _ = try RailNameHistoryFile.decode(Data("{\"schemaVersion\":2,\"schemaVersion\":1}".utf8)) }
        var unknown = original; unknown["schemaVersion"] = 3
        try historyRejects { _ = try RailNameHistoryFile.decode(historyJSON(unknown)) }
        var legacy = try JSONSerialization.jsonObject(with:NetworkJSON.encode(historyFixture())) as! [String:Any]
        legacy["unknownOriginals"] = ["must never be silently lost"]
        try historyRejects { _ = try RailNameHistoryFile.decode(historyJSON(legacy)) }
    }),
    ("name history: bounded files nesting and reference expansion", { w in
        let empty = try RailNameHistoryFile.encode(.init(names:.init(),titles:.init()))
        var tooLarge = empty; tooLarge.append(Data(repeating:32,count:RailNameHistoryFile.storedLimit))
        try historyRejects { _ = try RailNameHistoryFile.decode(tooLarge) }
        let sparse = try w.write(Data(),named:"oversized-history.json")
        let handle = try FileHandle(forWritingTo:sparse)
        try handle.truncate(atOffset:UInt64(RailNameHistoryFile.legacyLimit+1));try handle.close()
        try historyRejects { _ = try RailNameHistoryFile.read(sparse.path,root:testRepositoryRoot) }
        let nested = String(repeating:"[",count:65)+String(repeating:"]",count:65)
        try historyRejects { _ = try RailNameHistoryFile.decode(Data(nested.utf8)) }
        var bomb = try JSONSerialization.jsonObject(with:RailNameHistoryFile.encode(historyFixture())) as! [String:Any]
        let pool = bomb["evidence"] as! [String:Any], key = pool.keys.sorted()[0]
        var names = bomb["names"] as! [String:Any]
        names["observations"] = Array(repeating:key,count:RailNameHistoryFile.referenceLimit)
        bomb["names"] = names
        try historyRejects { _ = try RailNameHistoryFile.decode(historyJSON(bomb)) }
    }),
]
