import Foundation
import Darwin

// Every value, identifier, hash and review is invented.
private struct CrosswalkFixture {
    let source = "SYN/crosswalk"
    let input = String(repeating: "a", count: 64)
    let member = String(repeating: "b", count: 64)
    let id = MintedIdentifier("stn_0000000000000001")!
    var keys = ["syn-one", "syn-two"]
    var status: ProviderReferenceStatus = .active
    var attachment: String? = "syn-assignment"
    var wrongProvenance = false
    var reviewID = "syn-assignment"
    var omitReviews = false
    var wrongTarget = false
    func json(_ object: Any) throws -> Data { try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]) }
    func registry() throws -> Data {
        let refs = try ["syn-one", "syn-two", "é", "e\u{301}", " syn-one "].map { value in
            try ProviderReference(canonicalID: id, sourceID: source, namespace: .gtfsStopID, value: ExactValue(value)!, status: status,
                firstSeenInputSHA256: input,
                provenance: SourceReference(inputSHA256: wrongProvenance ? String(repeating: "c", count: 64) : input,
                    member: .init(name: "stops.txt", sha256: member), table: "stops", recordIndex: nil, field: "stop_id", providerKey: ExactValue(value)!),
                originalNames: [], attachedBy: attachment)
        }
        return try MappingRegistry(revision: 6, entities: [.init(id: id, status: .active)], references: refs).encoded()
    }
    func reviews() throws -> Data {
        try json(["schemaVersion": 1, "inputs": [["gtfsSourceID": source, "gtfsArchiveSHA256": input],
            ["gtfsSourceID": "SYN/other", "gtfsArchiveSHA256": String(repeating: "d", count: 64)]],
            "decisions": [], "stations": omitReviews ? [] : [["reviewID": reviewID,
                "stationID": wrongTarget ? "stn_0000000000000002" : id.rawValue,
                "sides": [["gtfsSourceID": source, "stops": ["syn-one", "syn-two", "é", "e\u{301}", " syn-one "]]]]]])
    }
    func keyData() throws -> Data { try json(["schemaVersion": 1, "sourceID": source, "namespace": "gtfs.stop_id", "values": keys]) }
    func expected(_ r: Data, _ e: Data, _ k: Data, registryHash: String? = nil, revision: Int = 6, count: Int? = nil) -> TripStationCrosswalk.Expectations {
        .init(registrySHA256: registryHash ?? sha256Hex(r), registryRevision: revision, reviewsSHA256: sha256Hex(e),
              keysSHA256: sha256Hex(k), sourceID: source, inputSHA256: input, count: count ?? keys.count)
    }
    func run() throws -> TripStationCrosswalk.Result {
        let r = try registry(), e = try reviews(), k = try keyData()
        return try TripStationCrosswalk.review(registryBytes: r, reviewsBytes: e, keysBytes: k, expected: expected(r,e,k))
    }
}
private func crosswalkReject(_ body: () throws -> Void) throws {
    do { try body() } catch { return }
    throw TestFailure(message: "crosswalk accepted invalid input")
}
private func altered(_ data: Data, _ body: (inout [String: Any]) -> Void) throws -> Data {
    var object = try JSONSerialization.jsonObject(with: data) as! [String: Any]; body(&object)
    return try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
}

let tripStationCrosswalkTests: [TestCase] = [
    ("crosswalk accepted station producer output preserves distinct attachment authorities", { workspace in
        let (sides, registry, cross) = try await SyntheticStations.decidedRun(workspace, "postmortem")
        let output = workspace.output.appendingPathComponent("postmortem-stations")
        guard case .success(let accepted) = await SyntheticStations.runRegistry(
            SyntheticStations.request(sides, registry: registry, cross: cross, output: output)) else {
            throw TestFailure(message: "invented accepted producer failed")
        }
        let r = try accepted.registry.encoded(), e = try Data(contentsOf: cross)
        let reviews = try CrossOperatorRecordsFile.decoded(from: e)
        let refs = accepted.registry.references.filter { $0.sourceID == SyntheticStations.sourceA && $0.namespace == .gtfsStopID }
        try check(!refs.isEmpty && refs.allSatisfy { accepted.registry.resolve($0.key) == $0.canonicalID }, "producer references do not resolve")
        try check(refs.allSatisfy { ref in
            reviews.stations.contains { assignment in
                assignment.stationID == ref.canonicalID && assignment.sides.contains { $0.gtfsSourceID == ref.sourceID && $0.stops.contains(ref.value.text) }
            } && !reviews.stations.contains { $0.reviewID == ref.attachedBy }
        }, "producer authority mismatch not reproduced")
        let input = reviews.inputs.first { $0.gtfsSourceID == SyntheticStations.sourceA }!
        let result = try TripStationCrosswalk.verify(registryBytes: r, reviewsBytes: e,
            keys: .init(sourceID: input.gtfsSourceID, namespace: "gtfs.stop_id", values: refs.map(\.value)),
            expected: .init(registrySHA256: sha256Hex(r), registryRevision: accepted.registry.revision,
                reviewsSHA256: sha256Hex(e), sourceID: input.gtfsSourceID, inputSHA256: input.gtfsArchiveSHA256, count: refs.count))
        try check(result.ready && result.reviewEvidence == .matched && result.memberIdentity == .matched,
                  "accepted producer output did not verify")
        // The accepted producer preserves existing schema-2 legacy nil authorities
        // on an unchanged replay; absence is not permission to bypass membership.
        let legacy = try altered(r) { object in
            var rows = object["references"] as! [[String:Any]]
            for i in rows.indices { rows[i].removeValue(forKey:"attachedBy") }
            object["references"] = rows
        }
        let legacyURL = try workspace.write(legacy, named:"syn-legacy-registry.json")
        guard case .success(let replay) = await SyntheticStations.runRegistry(
            SyntheticStations.request(sides, registry:legacyURL, cross:cross, previous:(sides,cross),
                output:workspace.output.appendingPathComponent("syn-legacy-replay"))) else {
            throw TestFailure(message:"accepted legacy replay failed")
        }
        try check(replay.registry.references.allSatisfy { $0.attachedBy == nil },"legacy authority fabricated")
        let legacyBytes = try replay.registry.encoded()
        let legacyResult = try TripStationCrosswalk.verify(registryBytes:legacyBytes,reviewsBytes:e,
            keys:.init(sourceID:input.gtfsSourceID,namespace:"gtfs.stop_id",values:refs.map(\.value)),
            expected:.init(registrySHA256:sha256Hex(legacyBytes),registryRevision:replay.registry.revision,
                reviewsSHA256:sha256Hex(e),sourceID:input.gtfsSourceID,inputSHA256:input.gtfsArchiveSHA256,count:refs.count))
        try check(legacyResult.ready,"producer-accepted legacy state rejected")
    }),
    ("crosswalk active exact bindings and prospective order", { _ in
        let result = try CrosswalkFixture().run()
        try check(result.ready && result.outcomes == [.resolved,.resolved] && result.prospectiveIndices == [0,1], "not resolved")
    }),
    ("crosswalk exact membership cannot be replaced by target or authority", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), k = try f.keyData()
        for wrongMembers in [["syn-unused"], ["SYN-ONE"], [" syn-one", "syn-two "]] {
            let e = try altered(f.reviews()) { object in
                var rows = object["stations"] as! [[String:Any]]
                rows[0]["sides"] = [["gtfsSourceID":f.source,"stops":wrongMembers]]
                object["stations"] = rows
            }
            let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
            try check(result.outcomes.allSatisfy { $0 == .assignmentMembershipMismatch }
                && result.reviewEvidence == .mismatched && result.memberIdentity == .matched && !result.ready,
                "same target/authority bypassed exact membership")
        }
    }),
    ("crosswalk diagnostic not evaluated is distinct from mismatch", { _ in
        var f = CrosswalkFixture(); f.keys = ["syn-missing"]
        let absent = try f.run()
        try check(absent.reviewEvidence == .notEvaluated && absent.memberIdentity == .notEvaluated && !absent.ready,"absent falsely diagnosed")
        f.keys = ["syn-one", "syn-missing"]
        let partial = try f.run()
        try check(partial.outcomes == [.resolved,.referenceAbsent] && partial.reviewEvidence == .notEvaluated
            && partial.memberIdentity == .notEvaluated && !partial.ready && partial.prospectiveIndices == nil,"partial readiness or diagnostic claim")
        f.keys = ["syn-one"]; f.wrongProvenance = true
        let invalid = try f.run()
        try check(invalid.reviewEvidence == .notEvaluated && invalid.memberIdentity == .notEvaluated,"unusable provenance called conflict")
        try check(TripStationCrosswalk.CheckStatus.aggregate([.matched,.mismatched,.notEvaluated]) == .mismatched,"mismatch hidden")
    }),
    ("crosswalk fabricated authority cannot change approved registry bytes", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        let fabricated = try altered(r) { object in
            var refs = object["references"] as! [[String:Any]]
            refs[0]["attachedBy"] = "syn-fabricated-authority"; object["references"] = refs
        }
        do {
            _ = try TripStationCrosswalk.review(registryBytes:fabricated,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
            throw TestFailure(message:"fabricated authority bypassed accepted hash")
        } catch TripStationCrosswalk.Failure.identityMismatch { }
        let malformed = try altered(r) { object in
            var refs = object["references"] as! [[String:Any]]
            refs[0]["attachedBy"] = "invalid authority token"; object["references"] = refs
        }
        do {
            _ = try TripStationCrosswalk.review(registryBytes:malformed,reviewsBytes:e,keysBytes:k,expected:f.expected(malformed,e,k))
            throw TestFailure(message:"malformed authority accepted")
        } catch TripStationCrosswalk.Failure.invalidRegistry { }
        // A caller-reapproved opaque token cannot be authenticated without its
        // historical authority records; never infer that relationship from spelling.
    }),
    ("crosswalk absent reference holds entire proposal", { _ in
        var f = CrosswalkFixture(); f.keys = ["syn-one", "syn-missing"]
        let r = try f.run(); try check(r.outcomes == [.resolved,.referenceAbsent] && !r.ready && r.prospectiveIndices == nil, "partial ready")
    }),
    ("crosswalk absent state does not resolve", { _ in
        var f = CrosswalkFixture(); f.status = .absent
        try check(try f.run().outcomes == [.referenceInactive,.referenceInactive], "inactive resolved")
    }),
    ("crosswalk retired reference does not resolve", { _ in
        var f = CrosswalkFixture(); f.status = .retired(review: "syn-retirement")
        try check(try f.run().outcomes == [.referenceInactive,.referenceInactive], "retired resolved")
    }),
    ("crosswalk wrong entity kind fails registry validation", { _ in
        let f = CrosswalkFixture(); let r = Data(String(decoding: try f.registry(), as: UTF8.self).replacingOccurrences(of: f.id.rawValue, with: "lin_0000000000000001").utf8)
        let e = try f.reviews(), k = try f.keyData()
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)) }
    }),
    ("crosswalk registry hash mismatch", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k,registryHash:String(repeating:"0",count:64))) }
    }),
    ("crosswalk registry revision mismatch", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k,revision:7)) }
    }),
    ("crosswalk unsupported registry schema", { _ in
        let f = CrosswalkFixture(), r = try altered(f.registry()) { $0["schemaVersion"] = 3 }, e = try f.reviews(), k = try f.keyData()
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)) }
    }),
    ("crosswalk scalar exact composed and decomposed occurrences", { _ in
        var f = CrosswalkFixture(); f.keys = ["é", "e\u{301}"]
        let r = try f.run(); try check(r.ready && r.repeated == 0, "normalized")
    }),
    ("crosswalk no trimming and exact whitespace key", { _ in
        var f = CrosswalkFixture(); f.keys = [" syn-one ", "syn-one "]
        try check(try f.run().outcomes == [.resolved,.referenceAbsent], "trimmed")
    }),
    ("crosswalk repeats preserved and distinct keys same station", { _ in
        var f = CrosswalkFixture(); f.keys = ["syn-two", "syn-one", "syn-two"]
        let r = try f.run(); try check(r.ready && r.repeated == 1 && r.stations.count == 3 && r.prospectiveIndices == [0,1,2], "deduplicated")
        try check(r.stations.allSatisfy { $0?.rawValue == f.id.rawValue }, "wrong target")
    }),
    ("crosswalk legacy missing attachment requires exact closure", { _ in
        var f = CrosswalkFixture(); f.attachment = nil
        try check(try f.run().ready, "legacy nil rejected despite exact approved closure")
        f.omitReviews = true
        try check(try !f.run().ready, "legacy nil bypassed closure")
    }),
    ("crosswalk missing assignment held", { _ in
        var f = CrosswalkFixture(); f.omitReviews = true
        try check(try f.run().outcomes.allSatisfy { $0 == .reviewEvidenceMissing }, "missing assignment")
    }),
    ("crosswalk assignment identity independent of introducing authority", { _ in
        var f = CrosswalkFixture(); f.reviewID = "syn-wrong-review"
        try check(try f.run().ready, "independent assignment authority rejected")
    }),
    ("crosswalk mismatched assignment target held", { _ in
        var f = CrosswalkFixture(); f.wrongTarget = true
        try check(try f.run().outcomes.allSatisfy { $0 == .assignmentTargetMismatch }, "wrong target evidence")
    }),
    ("crosswalk source provenance mismatch held", { _ in
        var f = CrosswalkFixture(); f.wrongProvenance = true
        try check(try f.run().outcomes.allSatisfy { $0 == .sourceRevisionMismatch }, "wrong revision")
    }),
    ("crosswalk duplicate assignment claims rejected", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), k = try f.keyData()
        let e = try altered(f.reviews()) { object in var rows = object["stations"] as! [[String: Any]]; rows.append(rows[0]); object["stations"] = rows }
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)) }
    }),
    ("crosswalk key bound and count mismatch", { _ in
        var f = CrosswalkFixture(); f.keys = Array(repeating:"syn-one",count:65)
        try crosswalkReject { _ = try f.run() }
        f.keys = ["syn-one"]
        let r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k,count:2)) }
    }),
    ("crosswalk registry member name table and field rules are typed", { _ in
        let f = CrosswalkFixture(), e = try f.reviews(), k = try f.keyData()
        let rules: [(String,String,TripStationCrosswalk.Outcome)] = [
            ("name","routes.txt",.wrongMemberName), ("table","routes",.wrongProvenanceTable), ("field","stop_code",.wrongProvenanceField)]
        for (field,value,outcome) in rules {
            let r = try altered(f.registry()) { object in
                var refs = object["references"] as! [[String:Any]]
                for index in refs.indices {
                    var p = refs[index]["provenance"] as! [String:Any]
                    if field == "name" { var m = p["member"] as! [String:Any]; m["name"] = value; p["member"] = m }
                    else { p[field] = value }
                    refs[index]["provenance"] = p
                }
                object["references"] = refs
            }
            let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
            try check(result.outcomes == [outcome,outcome] && !result.ready,"provenance rule accepted")
        }
    }),
    ("crosswalk missing or non GTFS member provenance fails closed", { _ in
        let f = CrosswalkFixture(), e = try f.reviews(), k = try f.keyData()
        for odpt in [false,true] {
            let r = try altered(f.registry()) { object in
                var refs = object["references"] as! [[String:Any]]
                for index in refs.indices {
                    var p = refs[index]["provenance"] as! [String:Any]
                    p.removeValue(forKey:"member")
                    if odpt { p.removeValue(forKey:"table"); p["recordIndex"] = 0 }
                    refs[index]["provenance"] = p
                }
                object["references"] = refs
            }
            do {
                let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
                try check(result.outcomes == [.invalidMemberProvenance,.invalidMemberProvenance],"non GTFS resolved")
            } catch TripStationCrosswalk.Failure.invalidRegistry { } // Existing model rejects malformed/mixed provenance first.
        }
    }),
    ("crosswalk malformed member hash rejected by registry decoder", { _ in
        let f = CrosswalkFixture(), e = try f.reviews(), k = try f.keyData()
        let r = try altered(f.registry()) { object in
            var refs = object["references"] as! [[String:Any]]
            var p = refs[0]["provenance"] as! [String:Any], m = p["member"] as! [String:Any]
            m["sha256"] = "invented-invalid"; p["member"] = m; refs[0]["provenance"] = p; object["references"] = refs
        }
        do {
            _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
            throw TestFailure(message:"malformed hash accepted")
        } catch TripStationCrosswalk.Failure.invalidRegistry { }
    }),
    ("crosswalk member disagreement invalidates all participating occurrences", { _ in
        let f = CrosswalkFixture(), e = try f.reviews()
        let r = try altered(f.registry()) { object in
            var refs = object["references"] as! [[String:Any]]
            let index = refs.firstIndex { $0["value"] as? String == "syn-two" }!
            var p = refs[index]["provenance"] as! [String:Any], m = p["member"] as! [String:Any]
            m["sha256"] = String(repeating:"f",count:64); p["member"] = m; refs[index]["provenance"] = p; object["references"] = refs
        }
        for values in [["syn-one","syn-two","syn-one"],["syn-two","syn-one","syn-two"]] {
            var ordered = f; ordered.keys = values; let k = try ordered.keyData()
            let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:ordered.expected(r,e,k))
            try check(result.outcomes.allSatisfy { $0 == .inconsistentMemberIdentity } && result.stations.allSatisfy { $0 == nil } && result.prospectiveIndices == nil && !result.ready,"member disagreement accepted or order dependent")
        }
    }),
    ("crosswalk separate valid assignments must share requested member identity", { _ in
        let f = CrosswalkFixture(), k = try f.keyData()
        let r = try altered(f.registry()) { object in
            var refs = (object["references"] as! [[String:Any]]).filter { ["syn-one","syn-two"].contains($0["value"] as! String) }
            let index = refs.firstIndex { $0["value"] as? String == "syn-two" }!
            refs[index]["canonicalID"] = "stn_0000000000000002"; refs[index]["attachedBy"] = "syn-second"
            object["references"] = refs
            var entities = object["entities"] as! [[String:Any]]
            var second = entities[0]; second["id"] = "stn_0000000000000002"; entities.append(second); object["entities"] = entities
        }
        let e = try altered(f.reviews()) { object in
            object["stations"] = [
                ["reviewID":"syn-assignment","stationID":f.id.rawValue,"sides":[["gtfsSourceID":f.source,"stops":["syn-one"]]]],
                ["reviewID":"syn-second","stationID":"stn_0000000000000002","sides":[["gtfsSourceID":f.source,"stops":["syn-two"]]]]]
        }
        try check(try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)).ready,"separate valid closures failed")
        let different = try altered(r) { object in
            var refs = object["references"] as! [[String:Any]]
            let index = refs.firstIndex { $0["value"] as? String == "syn-two" }!
            var p = refs[index]["provenance"] as! [String:Any], m = p["member"] as! [String:Any]
            m["sha256"] = String(repeating:"f",count:64); p["member"] = m; refs[index]["provenance"] = p; object["references"] = refs
        }
        let result = try TripStationCrosswalk.review(registryBytes:different,reviewsBytes:e,keysBytes:k,expected:f.expected(different,e,k))
        try check(result.outcomes == [.inconsistentMemberIdentity,.inconsistentMemberIdentity] && result.stations.allSatisfy { $0 == nil } && !result.ready
            && result.reviewEvidence == .matched && result.memberIdentity == .mismatched,"independent member diagnostic failed")
    }),
    ("crosswalk unverified registry cannot supply member identity", { _ in
        let f = CrosswalkFixture(), e = try f.reviews(), k = try f.keyData()
        let r = try altered(f.registry()) { object in
            var refs = object["references"] as! [[String:Any]]; var p = refs[0]["provenance"] as! [String:Any]
            p["table"] = "wrong"; refs[0]["provenance"] = p; object["references"] = refs
        }
        do {
            _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k,registryHash:String(repeating:"0",count:64)))
            throw TestFailure(message:"unverified provenance used")
        } catch TripStationCrosswalk.Failure.identityMismatch { }
        do {
            _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k,revision:7))
            throw TestFailure(message:"wrong revision provenance used")
        } catch TripStationCrosswalk.Failure.revisionMismatch { }
    }),
    ("crosswalk combined decoded record budget includes nested members", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), k = try f.keyData()
        let e = try altered(f.reviews()) { object in
            var rows = object["stations"] as! [[String:Any]]
            rows[0]["sides"] = [["gtfsSourceID":f.source,"stops":Array(repeating:"syn-one",count:TripStationCrosswalk.maxRecords)]]
            object["stations"] = rows
        }
        do {
            _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
            throw TestFailure(message:"combined budget accepted")
        } catch TripStationCrosswalk.Failure.resourceLimit { }
    }),
    ("crosswalk byte bound", { _ in
        let f = CrosswalkFixture(), r = Data(repeating:32,count:TripStationCrosswalk.maxBytes+1), e = try f.reviews(), k = try f.keyData()
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)) }
    }),
    ("crosswalk malformed duplicate unknown keys rejected", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews()
        for k in [Data("{\"schemaVersion\":1,\"schemaVersion\":1}".utf8), Data("[]".utf8), try altered(f.keyData()) { $0["times"] = [] }, try altered(f.keyData()) { $0["values"] = [""] }] {
            try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)) }
        }
    }),
    ("crosswalk unexpected source namespace schema rejected", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews()
        for (field,value) in [("sourceID","SYN/wrong"),("namespace","gtfs.stop_code"),("schemaVersion","future")] {
            let k = try altered(f.keyData()) { $0[field] = value }
            try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)) }
        }
    }),
    ("crosswalk deterministic aggregate no private pairs", { _ in
        let f = CrosswalkFixture(), a = try f.run(), b = try f.run()
        try check(a.summary == b.summary && a.outcomes == b.outcomes && a.stations == b.stations, "nondeterministic")
        for privateValue in f.keys + [f.id.rawValue, f.source, f.input, f.member] { try check(!a.summary.contains(privateValue), "private output") }
    }),
    ("crosswalk read only files no outputs and permission guards", { w in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        let paths = try [r,e,k].enumerated().map { pair -> String in
            let u = try w.write(pair.element,named:"syn-crosswalk-\(pair.offset).json")
            chmod(u.path,0o600); return resolvedPath(u.path)!
        }
        let before = try FileManager.default.contentsOfDirectory(atPath:w.archives.path).sorted()
        let result = try TripStationCrosswalk.run(registryPath:paths[0],reviewsPath:paths[1],keysPath:paths[2],expected:f.expected(r,e,k),root:testRepositoryRoot)
        try check(result.ready && before == FileManager.default.contentsOfDirectory(atPath:w.archives.path).sorted(), "wrote files")
        for (i,p) in paths.enumerated() { try check(try Data(contentsOf:URL(fileURLWithPath:p)) == [r,e,k][i], "mutated input") }
        chmod(paths[2],0o644)
        try crosswalkReject { _ = try TripStationCrosswalk.run(registryPath:paths[0],reviewsPath:paths[1],keysPath:paths[2],expected:f.expected(r,e,k),root:testRepositoryRoot) }
    }),
    ("crosswalk symlink and mutation rejected", { w in
        let original = try w.write(Data("synthetic".utf8),named:"syn-original").path
        let path = resolvedPath(original)!; chmod(path,0o600)
        let input = try TripStationCrosswalk.Input(path:path,root:testRepositoryRoot)
        try Data("changed".utf8).write(to:URL(fileURLWithPath:path))
        try crosswalkReject { try input.verify() }
        let link = (path as NSString).deletingLastPathComponent + "/syn-link"
        try FileManager.default.createSymbolicLink(atPath:link,withDestinationPath:path)
        try crosswalkReject { _ = try TripStationCrosswalk.Input(path:link,root:testRepositoryRoot) }
    }),
    ("crosswalk evidence and key hash mismatch", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        for (badE,badK) in [(Data("changed".utf8),k),(e,Data("changed".utf8))] {
            try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:badE,keysBytes:badK,expected:f.expected(r,e,k)) }
        }
    }),
    ("crosswalk accepted maximum preserves every occurrence", { _ in
        var f = CrosswalkFixture(); f.keys = Array(repeating:"syn-one",count:64)
        let result = try f.run()
        try check(result.ready && result.stations.count == 64 && result.repeated == 63 && result.prospectiveIndices == Array(0..<64), "max bound changed")
    }),
    ("crosswalk assignment dependencies must resolve without fallback", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), k = try f.keyData()
        let e = try altered(f.reviews()) { object in
            var rows = object["stations"] as! [[String:Any]]
            rows[0]["sides"] = [["gtfsSourceID":f.source,"stops":["syn-one","syn-two","syn-unavailable"]]]
            object["stations"] = rows
        }
        let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
        try check(!result.ready && result.outcomes.allSatisfy { $0 == .reviewEvidenceMismatch }, "dependency ignored")
    }),
    ("crosswalk merged assignment requires exact same decision", { _ in
        let f = CrosswalkFixture(), k = try f.keyData()
        let r = try altered(f.registry()) { object in
            var refs = object["references"] as! [[String:Any]]
            var other = refs[0]; other["sourceID"] = "SYN/other"; other["value"] = "syn-other"
            var provenance = other["provenance"] as! [String:Any]
            provenance["inputSHA256"] = String(repeating:"d",count:64); provenance["providerKey"] = "syn-other"
            other["provenance"] = provenance; refs.append(other); object["references"] = refs
        }
        let e = try altered(f.reviews()) { object in
            var rows = object["stations"] as! [[String:Any]]
            var sides = rows[0]["sides"] as! [[String:Any]]
            sides.append(["gtfsSourceID":"SYN/other","stops":["syn-other"]]); rows[0]["sides"] = sides
            object["stations"] = rows
            object["decisions"] = [["reviewID":"syn-merge","sides":sides,"evidenceSHA256":String(repeating:"e",count:64),"outcome":"same","reason":"Synthetic reviewed merge"]]
        }
        let good = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k))
        try check(good.ready,"reviewed merged assignment not resolved")
        for (field,value) in [("evidenceSHA256","invalid"),("reason",""),("outcome","ambiguous")] {
            let bad = try altered(e) { object in
                var rows = object["decisions"] as! [[String:Any]]
                rows[0][field] = value; object["decisions"] = rows
            }
            let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:bad,keysBytes:k,expected:f.expected(r,bad,k))
            try check(result.outcomes.allSatisfy { $0 == .crossOperatorEvidenceMismatch }
                && result.reviewEvidence == .mismatched && result.memberIdentity == .matched,"invalid same evidence or independent diagnostic accepted")
        }
        for bad in [try altered(e) { $0["decisions"] = [] }, try altered(e) { object in
            var decisions = object["decisions"] as! [[String:Any]]; decisions[0]["outcome"] = "distinct"; object["decisions"] = decisions
        }] {
            let result = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:bad,keysBytes:k,expected:f.expected(r,bad,k))
            try check(!result.ready,"missing/conflicting merge proof accepted")
        }
    }),
    ("crosswalk on-disk size and ancestor symlink guards", { w in
        let original = try w.write(Data(),named:"syn-oversized"); let path = resolvedPath(original.path)!
        chmod(path,0o600)
        let handle = try FileHandle(forWritingTo:URL(fileURLWithPath:path)); try handle.truncate(atOffset:UInt64(TripStationCrosswalk.maxBytes+1)); try handle.close()
        try crosswalkReject { _ = try TripStationCrosswalk.Input(path:path,root:testRepositoryRoot) }
        let link = (path as NSString).deletingLastPathComponent + "/syn-directory-link"
        try FileManager.default.createSymbolicLink(atPath:link,withDestinationPath:(path as NSString).deletingLastPathComponent)
        try crosswalkReject { _ = try TripStationCrosswalk.Input(path:link+"/syn-oversized",root:testRepositoryRoot) }
    }),
    ("crosswalk unrelated approved assignment allowed conflicting member rejected", { _ in
        let f = CrosswalkFixture(), r = try f.registry(), k = try f.keyData()
        let e = try altered(f.reviews()) { object in
            var rows = object["stations"] as! [[String:Any]]
            rows.append(["reviewID":"syn-unrelated", "stationID":"stn_0000000000000002", "sides":[["gtfsSourceID":f.source,"stops":["syn-unused"]]]])
            object["stations"] = rows
        }
        try check(try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:e,keysBytes:k,expected:f.expected(r,e,k)).ready,"unrelated approved row treated as dependency")
        let bad = try altered(e) { object in
            var rows = object["stations"] as! [[String:Any]]
            rows[1]["sides"] = [["gtfsSourceID":f.source,"stops":["syn-one"]]]; object["stations"] = rows
        }
        try crosswalkReject { _ = try TripStationCrosswalk.review(registryBytes:r,reviewsBytes:bad,keysBytes:k,expected:f.expected(r,bad,k)) }
    }),
    ("crosswalk final permission and replacement changes rejected", { w in
        let url = try w.write(Data("synthetic".utf8),named:"syn-state"); let path = resolvedPath(url.path)!
        chmod(path,0o600)
        let input = try TripStationCrosswalk.Input(path:path,root:testRepositoryRoot)
        chmod(path,0o644)
        try crosswalkReject { try input.verify() }
        chmod(path,0o600)
        let second = try TripStationCrosswalk.Input(path:path,root:testRepositoryRoot)
        try FileManager.default.removeItem(atPath:path)
        try Data("synthetic".utf8).write(to:URL(fileURLWithPath:path)); chmod(path,0o600)
        try crosswalkReject { try second.verify() }
    }),
    ("crosswalk actual CLI aggregate only deterministic no output artifact", { w in
        let f = CrosswalkFixture(), r = try f.registry(), e = try f.reviews(), k = try f.keyData()
        let paths = try [r,e,k].enumerated().map { pair -> String in
            let u = try w.write(pair.element,named:"syn-cli-\(pair.offset).json"); chmod(u.path,0o600); return resolvedPath(u.path)!
        }
        let args = ["trip-station-crosswalk-review", "--registry",paths[0],"--registry-sha256",sha256Hex(r),"--registry-revision","6",
                    "--reviews",paths[1],"--reviews-sha256",sha256Hex(e),"--keys",paths[2],"--keys-sha256",sha256Hex(k),
                    "--source",f.source,"--input-sha256",f.input,"--namespace","gtfs.stop_id","--expected-count","2"]
        let before = try FileManager.default.contentsOfDirectory(atPath:w.archives.path).sorted()
        var reports: [Data] = []
        for _ in 0..<2 {
            let p = Process(); p.executableURL = URL(fileURLWithPath:repositoryPath+"/Tools/StaticDataIntake/.build/static-data-intake")
            p.arguments = args; p.environment = ["PATH":"", "HOME":w.root.path] // no external command discovery
            let out = Pipe(), err = Pipe(); p.standardOutput = out; p.standardError = err
            try p.run(); p.waitUntilExit()
            let bytes = out.fileHandleForReading.readDataToEndOfFile(), errors = err.fileHandleForReading.readDataToEndOfFile()
            try check(p.terminationStatus == 0 && errors.isEmpty,"CLI failed")
            let text = String(decoding:bytes,as:UTF8.self)
            try check(text == (try f.run()).summary,"wrong aggregate")
            for secret in paths + f.keys + [f.id.rawValue,f.source,f.member] { try check(!text.contains(secret),"private CLI output") }
            reports.append(bytes)
        }
        try check(reports[0] == reports[1] && before == FileManager.default.contentsOfDirectory(atPath:w.archives.path).sorted(),"nondeterministic or file creation")
    }),

]
