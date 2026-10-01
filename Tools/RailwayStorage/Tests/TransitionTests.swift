import Foundation

typealias IT = IdentityTransition
struct TransitionFixture {
    let before: RailwayArtifactSnapshot
    let after: RailwayArtifactSnapshot
    let previous: MappingRegistry
    let target: MappingRegistry
    let inputs: RailwayArtifactBuilder.Inputs
    let request: IT.Request
    static func make(_ operation: IT.Operation, kind: CanonicalKind = .station, status: ProviderReferenceStatus? = nil, includeReferences: Bool = true) throws -> Self {
        let before = Synthetic.snapshot()
        let sources: [MintedIdentifier]
        switch kind {
        case .station: sources = (operation == .merge ? [Synthetic.b.rawValue, Synthetic.c.rawValue] : [Synthetic.c.rawValue]).map { MintedIdentifier($0)! }
        case .line: sources = [MintedIdentifier(Synthetic.l.rawValue)!]
        case .railwayOperator: sources = [MintedIdentifier(Synthetic.op.rawValue)!]
        }
        let targets = (operation == .retire ? [] : operation == .split ? [5,6] : [5]).map { MintedIdentifier(kind.rawValue + "_000000000000000\($0)")! }
        let refStatus = status ?? (operation == .retire ? .absent : .active)
        let namespace: ProviderNamespace = kind == .station ? .gtfsStopID : kind == .line ? .gtfsRouteID : .gtfsAgencyID
        var refs = try sources.enumerated().map { offset, id -> ProviderReference in
            let key = ExactValue(offset == 0 ? "Synthetic-é" : "Synthetic-e\u{301}")!
            let sha = String(repeating: "1", count: 64)
            let provenance = try SourceReference(inputSHA256: sha, member: .init(name: "invented.txt", sha256: sha), table: "invented", recordIndex: nil, field: "id", providerKey: key)
            return try ProviderReference(canonicalID: id, sourceID: "synthetic", namespace: namespace, value: key, status: refStatus,
                firstSeenInputSHA256: sha, provenance: provenance,
                originalNames: [.init(language: ExactValue("ja")!, value: ExactValue("Invented original")!, source: provenance)], attachedBy: "original-\(offset)")
        }.sorted { $0.key < $1.key }
        if !includeReferences { refs = [] }
        let previous = try MappingRegistry(revision: 10, entities: before.entities, references: refs)
        let afterEntities = before.entities.map { sources.contains($0.id) ? CanonicalEntity(id: $0.id, status: .retired(successors: targets)) : $0 } + targets.map { CanonicalEntity(id: $0, status: .active) }
        let afterRefs = try refs.enumerated().map { i, r in
            operation == .retire ? r : try IT.transferred(r, to: targets[i % targets.count], authority: "disposition-\(i)")
        }
        let target = try MappingRegistry(revision: 11, entities: afterEntities, references: afterRefs, formatVersion: 3)
        let after = try snapshot(afterEntities)
        let content = RailwayArtifactContent(after)
        let inputs = RailwayArtifactBuilder.Inputs(registryBytes: try target.encoded(), namesBytes: try RailwayArtifact.encode(content.stations.map(\.name)), networkBytes: try RailwayArtifact.encode(content.lines))
        let oldBytes = try previous.encoded()
        let dispositions = try zip(refs, afterRefs).enumerated().map { i, pair in
            IT.Disposition(id: "disposition-\(i)", action: operation == .retire ? .retainHistorical : .transfer,
                before: pair.0, after: pair.1, afterSHA256: try IT.hash(pair.1),
                predecessor: .init(registrySHA256: RailwayArtifact.digest(oldBytes), recordSHA256: try IT.hash(pair.0), bindingVersionID: nil), reviewAuthority: "disposition-\(i)")
        }
        let evidence = Data("Wholly invented structural identity review; no provider data.".utf8)
        let payload = IT.Payload(schemaVersion: 1, id: "transition-1", operation: operation, kind: kind.rawValue,
            previous: try IT.Scope(oldBytes), target: try IT.Scope(inputs.registryBytes), sources: sources.sorted(), targets: targets.sorted(),
            beforeEntities: sources.sorted().compactMap { previous.entity($0) },
            afterEntities: (sources + targets).sorted().compactMap { target.entity($0) }, dispositions: dispositions,
            evidence: [.init(source: ExactValue("synthetic fixture")!, capture: .synthetic, bytes: evidence, sha256: RailwayArtifact.digest(evidence),
                locator: ExactValue("whole invented document")!, offset: 0, quotation: evidence, members: (sources + targets).sorted(), nonNameSupport: ExactValue("Invented code continuity and explicit structural review")!)],
            rationale: ExactValue("Synthetic application of reviewed identity transition")!,
            dependencies: [.init(role: "names", sha256: RailwayArtifact.digest(inputs.namesBytes)), .init(role: "network", sha256: RailwayArtifact.digest(inputs.networkBytes))])
        let record = try approved(payload)
        return .init(before: before, after: after, previous: previous, target: target, inputs: inputs,
            request: .init(previousRegistry: oldBytes, targetRegistry: inputs.registryBytes, recordsBytes: try RailwayArtifact.encode([record]), previousHistory: nil))
    }
    static func approved(_ payload: IT.Payload) throws -> IT.Record {
        .init(payload: payload, approval: .init(author: ExactValue("Synthetic author")!, reviewer: ExactValue("Synthetic reviewer")!, role: ExactValue("fixture only")!, reviewedAt: ExactValue("2026-10-01T00:00:00Z")!, reference: ExactValue("invented approval")!, payloadSHA256: try IT.hash(payload)))
    }
    static func snapshot(_ entities: [CanonicalEntity]) throws -> RailwayArtifactSnapshot {
        let active = entities.filter { $0.status == .active }
        let stationIDs = active.filter { $0.id.kind == .station }.map { StationID($0.id.rawValue)! }.sorted { $0.rawValue < $1.rawValue }
        let line = LineID(active.first { $0.id.kind == .line }!.id.rawValue)!
        let op = OperatorID(active.first { $0.id.kind == .railwayOperator }!.id.rawValue)!
        let name = LocalizedRailName(japanese: "Invented", english: "Invented", korean: "Synthetic")!
        let edges = Set(zip(stationIDs, stationIDs.dropFirst()).map { StationAdjacency($0, $1)! })
        return .init(stations: stationIDs.map { Station(id: $0, name: name, coordinate: GeoCoordinate(latitude: 1, longitude: 2)!, lineIDs: [line]) },
            lines: [.init(id: line, operatorID: op, name: name, topology: RailwayLineTopology(adjacencies: edges)!)],
            operators: [.init(id: op, name: name)], aliases: [], entities: entities)
    }
}
func rejected(_ label: String, _ body: () throws -> Void) throws {
    do { try body() } catch { return }
    throw TestFailure.failed("accepted: " + label)
}
func transitionChecks(_ directory: URL) async throws {
    var count = 0
    for (operation, kind, mode) in [(IT.Operation.retire, CanonicalKind.station, "absent"), (.replace,.station,"active"), (.merge,.station,"active"), (.split,.station,"active"), (.replace,.line,"active"), (.replace,.railwayOperator,"active"), (.retire,.station,"empty"), (.retire,.station,"withdrawn")] {
        let f = try TransitionFixture.make(operation, kind: kind, status: mode == "withdrawn" ? .retired(review: "withdrawal-review") : nil, includeReferences: mode != "empty")
        let root = directory.appendingPathComponent("transition-\(count)"); count += 1
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        let old = root.appendingPathComponent("old.sqlite")
        let oldInputs = RailwayArtifactBuilder.Inputs(registryBytes: f.request.previousRegistry, namesBytes: Data("invented old names".utf8), networkBytes: Data("invented old network".utf8))
        let oldMetadata = try await RailwayArtifactBuilder.build(snapshot: f.before, dataVersion: ExactValue("before")!, inputs: oldInputs, output: old)
        let oldBytes = try Data(contentsOf: old)
        let output = root.appendingPathComponent("output")
        let receipt = try await IT.publish(f.request, snapshot: f.after, dataVersion: ExactValue("after")!, inputs: f.inputs, previous: old, output: output)
        let artifact = output.appendingPathComponent("railway.sqlite")
        let repository = try await SQLiteRailwayRepository.open(artifact)
        try check(try await repository.identities() == f.target.entities, "applied \(operation) identities")
        let metadata = try await repository.metadata()
        try check(metadata.schemaVersion == 2 && metadata.revisions.count == 2 && metadata.revisions.first == oldMetadata.current, "schema conversion/build history")
        let records = try IT.decode([IT.Record].self, f.request.recordsBytes)
        for id in records[0].payload.sources where id.kind == .station {
            try check(try await repository.station(id: StationID(id.rawValue)!) == nil, "no successor following")
        }
        let historyBytes = try Data(contentsOf: output.appendingPathComponent("history.json"))
        let history = try IT.decode(IT.History.self, historyBytes)
        try check(history.boundaries.count == 1 && history.boundaries[0].previousRegistry == f.request.previousRegistry, "all original bytes retained")
        try check(history.boundaries[0].records[0].payload.dispositions.map(\.before.attachedBy) == f.previous.references.map(\.attachedBy), "old attachment authority")
        try check(receipt.registrySchemaFrom == 2 && receipt.registrySchemaTo == 3, "conversion receipt")
        try await repository.close()
        let reopened = try await SQLiteRailwayRepository.open(artifact)
        try check(try await reopened.identities() == f.target.entities, "reopen transition")
        try await reopened.close()
        for repeatNumber in 0..<2 {
            let replay = repeatNumber == 1
            let request = IT.Request(previousRegistry: f.request.previousRegistry, targetRegistry: f.request.targetRegistry,
                                     recordsBytes: f.request.recordsBytes, previousHistory: replay ? historyBytes : nil)
            let repeatOutput = root.appendingPathComponent("repeat-\(repeatNumber)")
            _ = try await IT.publish(request, snapshot: f.after, dataVersion: ExactValue("after")!, inputs: f.inputs, previous: replay ? artifact : old, output: repeatOutput)
            for file in ["railway.sqlite", "history.json", "receipt.json"] {
                try check(try Data(contentsOf: output.appendingPathComponent(file)) == Data(contentsOf: repeatOutput.appendingPathComponent(file)), "identical \(file) repeat")
            }
        }
        try check(try Data(contentsOf: old) == oldBytes, "input artifact immutable")
        // Valid reviews but invalid target Domain data fail before any package appears.
        let invalid = RailwayArtifactSnapshot(stations: [], lines: f.after.lines, operators: f.after.operators, aliases: [], entities: f.after.entities)
        let failed = root.appendingPathComponent("failed")
        do { _ = try await IT.publish(f.request, snapshot: invalid, dataVersion: ExactValue("after")!, inputs: f.inputs, previous: old, output: failed); throw TestFailure.failed("published invalid target") }
        catch is TestFailure { throw TestFailure.failed("published invalid target") } catch {}
        try check(!FileManager.default.fileExists(atPath: failed.path), "atomic failure")
        IT.failBeforePublication = true
        do { _ = try await IT.publish(f.request, snapshot: f.after, dataVersion: ExactValue("after")!, inputs: f.inputs, previous: old, output: failed); IT.failBeforePublication = false; throw TestFailure.failed("injected failure ignored") }
        catch is TestFailure { throw TestFailure.failed("injected failure ignored") } catch { IT.failBeforePublication = false }
        try check(!FileManager.default.fileExists(atPath: failed.path), "late failure publishes nothing")
        try check(!FileManager.default.contentsOfDirectory(atPath: root.path).contains { $0.hasPrefix(".transition-") }, "no staging debris")
        if operation == .replace && kind == .station {
            let childOutput = root.appendingPathComponent("other-process")
            let process = Process(); process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0]); process.arguments = ["--emit-transition", childOutput.path]
            try process.run(); process.waitUntilExit(); try check(process.terminationStatus == 0, "cross-process transition builder")
            for file in ["railway.sqlite", "history.json", "receipt.json"] { try check(try Data(contentsOf: output.appendingPathComponent(file)) == Data(contentsOf: childOutput.appendingPathComponent(file)), "cross-process transition determinism") }
        }
        if operation == .split {
            try await subsequentTransition(f, previousArtifact: artifact, historyBytes: historyBytes, root: root)
            let descriptive = root.appendingPathComponent("descriptive.sqlite")
            let rebuilt = try await RailwayArtifactBuilder.build(snapshot: f.after, dataVersion: ExactValue("descriptive")!, inputs: f.inputs,
                previous: artifact, output: descriptive, retainedHistory: historyBytes)
            try check(rebuilt.revisions.count == 3, "descriptive build retains migration history")
            let downgraded = try MappingRegistry(revision: 12, entities: f.target.entities, references: f.target.references).encoded()
            try await rejectedAsync("implicit reverse conversion") {
                _ = try await RailwayArtifactBuilder.build(snapshot: f.after, dataVersion: ExactValue("downgrade")!,
                    inputs: .init(registryBytes: downgraded, namesBytes: f.inputs.namesBytes, networkBytes: f.inputs.networkBytes),
                    previous: artifact, output: root.appendingPathComponent("downgrade.sqlite"), retainedHistory: historyBytes)
            }
            try await rejectedAsync("lost external history") { _ = try await RailwayArtifactBuilder.build(snapshot: f.after, dataVersion: ExactValue("lost-history")!, inputs: f.inputs,
                previous: artifact, output: root.appendingPathComponent("lost-history.sqlite")) }
        }
        print("PASS applied \(operation.rawValue) \(kind.rawValue), schema conversion, reopen, authority/history, two byte-identical repeats, atomic rejection")
    }
    let fixture = try TransitionFixture.make(.split)
    let valid = try JSONSerialization.jsonObject(with: fixture.request.recordsBytes) as! [[String: Any]]
    func mutated(_ label: String, resign: Bool = true, _ edit: (inout [String: Any]) -> Void) throws {
        var item = valid[0]; var payload = item["payload"] as! [String: Any]; edit(&payload); item["payload"] = payload
        if resign {
            // Re-sign malformed-but-decodable fixture payloads to exercise semantic checks.
            let raw = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys, .withoutEscapingSlashes])
            if let decoded = try? JSONDecoder().decode(IT.Payload.self, from: raw) {
                var approval = item["approval"] as! [String: Any]; approval["payloadSHA256"] = try IT.hash(decoded); item["approval"] = approval
            }
        }
        let raw = try JSONSerialization.data(withJSONObject: [item], options: [.sortedKeys, .withoutEscapingSlashes])
        try rejected(label) { _ = try IT.validate(.init(previousRegistry: fixture.request.previousRegistry, targetRegistry: fixture.request.targetRegistry, recordsBytes: raw, previousHistory: nil)) }
    }
    try mutated("stale scope") { var p = $0["previous"] as! [String:Any]; p["revision"] = 9; $0["previous"] = p }
    try mutated("wrong kind") { $0["kind"] = "lin" }
    try mutated("wrong cardinality") { $0["operation"] = "merge" }
    try mutated("overlap/circular source") { $0["targets"] = $0["sources"] }
    try mutated("missing disposition") { $0["dispositions"] = [] }
    try mutated("duplicate current versions") { let ds = $0["dispositions"] as! [[String:Any]]; $0["dispositions"] = ds + ds }
    try mutated("altered old attachment") { var ds = $0["dispositions"] as! [[String:Any]]; var before = ds[0]["before"] as! [String:Any]; before["attachedBy"] = "fabricated"; ds[0]["before"] = before; $0["dispositions"] = ds }
    try mutated("stale predecessor") { var ds = $0["dispositions"] as! [[String:Any]]; var pred = ds[0]["predecessor"] as! [String:Any]; pred["bindingVersionID"] = "unknown"; ds[0]["predecessor"] = pred; $0["dispositions"] = ds }
    try mutated("old authority reused as transition ID") { $0["id"] = "original-0" }
    try mutated("old authority reused") { var ds = $0["dispositions"] as! [[String:Any]]; ds[0]["reviewAuthority"] = "original-0"; $0["dispositions"] = ds }
    try mutated("unsupported record") { $0["schemaVersion"] = 99 }
    try mutated("changed evidence") { var es = $0["evidence"] as! [[String:Any]]; es[0]["sha256"] = String(repeating: "0", count: 64); $0["evidence"] = es }
    try mutated("unapproved payload", resign: false) { $0["rationale"] = "Changed" }
    try mutated("unknown field") { $0["unknown"] = true }
    try rejected("duplicate records") { let records = try IT.decode([IT.Record].self, fixture.request.recordsBytes); _ = try IT.validate(.init(previousRegistry: fixture.request.previousRegistry, targetRegistry: fixture.request.targetRegistry, recordsBytes: RailwayArtifact.encode(records+records), previousHistory: nil)) }
    let withdrawn = try TransitionFixture.make(.retire, status: .retired(review: "withdrawal-review"))
    _ = try IT.validate(withdrawn.request)
    try rejected("pure retirement with active reference") { _ = try TransitionFixture.make(.retire, status: .active) }
    let pure = try TransitionFixture.make(.retire)
    try rejected("v2 empty successor list") { _ = try MappingRegistry(revision: 11, entities: pure.target.entities, references: pure.target.references) }
    try rejected("ordinary reader rejects v3") { _ = try MappingRegistry.decoded(from: pure.request.targetRegistry) }
    for sameTarget in [true, false] {
        let ref = fixture.target.references[0]
        let other = try IT.transferred(ref, to: sameTarget ? ref.canonicalID : MintedIdentifier(Synthetic.a.rawValue)!, authority: "other")
        try rejected("two current records") { _ = try MappingRegistry(revision: 11, entities: fixture.target.entities, references: [ref, other], formatVersion: 3) }
    }
    let hidden = try MappingRegistry(revision: fixture.target.revision, entities: fixture.target.entities.map {
        $0.id == Synthetic.retired ? CanonicalEntity(id: $0.id, status: .retired(successors: [MintedIdentifier(Synthetic.b.rawValue)!])) : $0
    }, references: fixture.target.references, formatVersion: 3)
    let hiddenBytes = try hidden.encoded()
    var hiddenPayload = valid[0]["payload"] as! [String: Any]
    hiddenPayload["target"] = try JSONSerialization.jsonObject(with: RailwayArtifact.encode(IT.Scope(hiddenBytes)))
    let hiddenP = try JSONDecoder().decode(IT.Payload.self, from: JSONSerialization.data(withJSONObject: hiddenPayload))
    try rejected("unaccounted snapshot status change with reviewed exact scope") {
        _ = try IT.validate(.init(previousRegistry: fixture.request.previousRegistry, targetRegistry: hiddenBytes,
            recordsBytes: RailwayArtifact.encode([TransitionFixture.approved(hiddenP)]), previousHistory: nil))
    }
    let a = MintedIdentifier(Synthetic.a.rawValue)!, b = MintedIdentifier(Synthetic.b.rawValue)!
    try rejected("actual successor cycle") { _ = try MappingRegistry(revision: 1, entities: [.init(id: a, status: .retired(successors: [b])), .init(id: b, status: .retired(successors: [a]))], references: [], formatVersion: 3) }
    try rejected("oversized input") { _ = try IT.decode(IT.History.self, Data(repeating: 0, count: IT.maxBytes + 1)) }
    print("PASS transition rejection matrix: exact scope, kinds/cardinality, dispositions/versions, prior authority, evidence, old-format semantics and bounds")
}

func rejectedAsync(_ label: String, _ body: () async throws -> Void) async throws {
    do { try await body() } catch { return }
    throw TestFailure.failed("accepted: " + label)
}
func subsequentTransition(_ f: TransitionFixture, previousArtifact: URL, historyBytes: Data, root: URL) async throws {
    let source = MintedIdentifier("stn_0000000000000005")!, successor = MintedIdentifier("stn_0000000000000007")!
    let entities = f.target.entities.map { $0.id == source ? CanonicalEntity(id: source, status: .retired(successors: [successor])) : $0 } + [CanonicalEntity(id: successor, status: .active)]
    let refs = try f.target.references.map { r in r.canonicalID == source ? try IT.transferred(r, to: successor, authority: "next-disposition") : r }
    let registry = try MappingRegistry(revision: 12, entities: entities, references: refs, formatVersion: 3)
    let snapshot = try TransitionFixture.snapshot(entities), content = RailwayArtifactContent(snapshot)
    let inputs = RailwayArtifactBuilder.Inputs(registryBytes: try registry.encoded(), namesBytes: try RailwayArtifact.encode(content.stations.map(\.name)), networkBytes: try RailwayArtifact.encode(content.lines))
    let oldRef = f.target.references.first { $0.canonicalID == source }!, newRef = refs.first { $0.key == oldRef.key }!
    let d = IT.Disposition(id: "next-disposition", action: .transfer, before: oldRef, after: newRef, afterSHA256: try IT.hash(newRef),
        predecessor: .init(registrySHA256: RailwayArtifact.digest(f.request.targetRegistry), recordSHA256: try IT.hash(oldRef), bindingVersionID: oldRef.attachedBy), reviewAuthority: "next-disposition")
    let evidence = Data("Invented subsequent structural review".utf8)
    let payload = IT.Payload(schemaVersion: 1, id: "next-transition", operation: .replace, kind: "stn", previous: try IT.Scope(f.request.targetRegistry), target: try IT.Scope(inputs.registryBytes),
        sources: [source], targets: [successor], beforeEntities: [f.target.entity(source)!], afterEntities: [registry.entity(source)!, registry.entity(successor)!], dispositions: [d],
        evidence: [.init(source: ExactValue("synthetic second checkpoint")!, capture: .synthetic, bytes: evidence, sha256: RailwayArtifact.digest(evidence), locator: ExactValue("whole document")!, offset: 0, quotation: evidence, members: [source, successor], nonNameSupport: ExactValue("Explicit invented identity continuity")!)], rationale: ExactValue("Second reviewed transition")!, dependencies: [.init(role: "names", sha256: RailwayArtifact.digest(inputs.namesBytes)), .init(role: "network", sha256: RailwayArtifact.digest(inputs.networkBytes))])
    let records = try RailwayArtifact.encode([TransitionFixture.approved(payload)])
    let request = IT.Request(previousRegistry: f.request.targetRegistry, targetRegistry: inputs.registryBytes, recordsBytes: records, previousHistory: historyBytes)
    let out = root.appendingPathComponent("second-transition")
    _ = try await IT.publish(request, snapshot: snapshot, dataVersion: ExactValue("second-transition")!, inputs: inputs, previous: previousArtifact, output: out)
    let newHistory = try Data(contentsOf: out.appendingPathComponent("history.json"))
    let h = try IT.decode(IT.History.self, newHistory), oldH = try IT.decode(IT.History.self, historyBytes)
    try check(h.boundaries.count == 2 && h.boundaries[0] == oldH.boundaries[0], "immutable prior transition history")
    try check(registry.entity(MintedIdentifier(Synthetic.c.rawValue)!) == f.target.entity(MintedIdentifier(Synthetic.c.rawValue)!), "old direct successors not flattened")
    let again = root.appendingPathComponent("second-transition-repeat")
    _ = try await IT.publish(.init(previousRegistry: request.previousRegistry, targetRegistry: request.targetRegistry, recordsBytes: records, previousHistory: newHistory),
        snapshot: snapshot, dataVersion: ExactValue("second-transition")!, inputs: inputs, previous: out.appendingPathComponent("railway.sqlite"), output: again)
    for file in ["railway.sqlite", "history.json", "receipt.json"] { try check(try Data(contentsOf: out.appendingPathComponent(file)) == Data(contentsOf: again.appendingPathComponent(file)), "second transition repeat") }
    try await rejectedAsync("lost prior manifest") {
        _ = try await IT.publish(.init(previousRegistry: request.previousRegistry, targetRegistry: request.targetRegistry, recordsBytes: records, previousHistory: nil),
            snapshot: snapshot, dataVersion: ExactValue("second-transition")!, inputs: inputs, previous: previousArtifact, output: root.appendingPathComponent("lost-manifest"))
    }
    print("PASS second applied transition, predecessor version, immutable successor chain, retained history and byte-identical replay")
}
