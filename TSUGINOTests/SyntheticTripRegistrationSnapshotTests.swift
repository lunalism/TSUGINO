#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Invented C2 inputs only. No filesystem loader, allocator, or real registry execution.
struct SyntheticTripRegistrationSnapshotTests {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias A = SyntheticTripRegistrationAdmission
    typealias Entry = SyntheticTripRegistrationClosure.Entry
    typealias D = SyntheticRegistrationDiagnostic
    private let trip = "trp_0000000000000001"
    private let secondTrip = "trp_0000000000000002"
    private let oldInput = String(repeating: "1", count: 64)
    private let nextInput = String(repeating: "2", count: 64)
    private let zero = String(repeating: "0", count: 64)

    private func s(_ text: String) -> V { .string(text) }
    private func list(_ values: [String]) -> V { .array(values.map(s)) }
    private func set(_ value: V, _ field: String, _ replacement: V?) -> V {
        guard case .object(var fields) = value else { fatalError("Invented fixture object required") }
        fields[field] = replacement
        return .object(fields)
    }
    private func decode(_ bytes: Data) throws -> V { try JSONDecoder().decode(V.self, from: bytes) }
    private func same(_ a: V?, _ b: V?) throws -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case let (a?, b?): return try C.encoded(a) == C.encoded(b)
        default: return false
        }
    }
    private func blob(_ bytes: Data) -> V { s(bytes.base64EncodedString()) }
    private func raw(_ value: V) -> Data { Data(base64Encoded: value.text!)! }
    private func wrapper(_ kind: String, _ id: String, _ payload: V) -> V {
        .object(["format": s("tsugino.synthetic-trip-payload"), "schemaVersion": .integer(1),
                 "subjectKind": s(kind), "subjectID": s(id), "payload": payload])
    }
    private func approval(_ payload: V, _ id: String) throws -> V {
        .object(["reviewID": s(id), "author": s("invented-author"), "reviewer": s("invented-owner"),
                 "role": s("owner"), "approvedAt": s("2026-10-02T00:00:00Z"),
                 "subjectKind": payload["subjectKind"]!, "subjectID": payload["subjectID"]!,
                 "payloadSHA256": s(C.digest(try C.encoded(payload))), "approvalReference": s("invented-owner-review")])
    }
    private func approved(_ wrapped: V, _ review: String) throws -> V {
        let canonical = try C.make(.payload, wrapped).value
        return .object(["payload": canonical, "approval": try approval(canonical, review)])
    }
    private func entity(_ id: String, retired: Bool = false) -> V {
        var value: V = .object(["id": s(id), "state": s(retired ? "retired" : "active")])
        if retired { value = set(value, "successors", .array([])) }
        return value
    }
    private func key(_ value: String = "invented-run") -> V {
        .object(["sourceID": s("invented"), "namespace": s("gtfs.trip_id"), "value": s(value)])
    }
    private func reference(_ key: V, tripID: String? = nil, input: String? = nil,
                           authority: String = "review-Q", state: String = "active") -> V {
        let input = input ?? nextInput
        let provenance: V = .object(["inputSHA256": s(input),
            "member": .object(["name": s("invented.txt"), "sha256": s(input)]),
            "table": s("invented"), "field": s("id"), "providerKey": key["value"]!])
        let status: V = state == "retired" ? .object(["state": s(state), "review": s("seed-retirement")]) : .object(["state": s(state)])
        return .object(["canonicalID": s(tripID ?? trip), "sourceID": key["sourceID"]!,
            "namespace": key["namespace"]!, "value": key["value"]!, "status": status,
            "firstSeenInputSHA256": s(input), "provenance": provenance, "originalNames": .array([]),
            "attachedBy": s(authority)])
    }
    private func registry(_ revision: Int, entities: [V], references: [V], schema: Int = 4) throws -> Data {
        let value: V = .object(["schemaVersion": .integer(schema), "revision": .integer(revision),
                                "entities": .array(entities), "references": .array(references)])
        return schema == 4 ? try C.make(.registry, value).bytes : try C.encoded(value, pretty: true)
    }
    private func checkpoint(_ bytes: Data, _ history: V) throws -> V {
        let value = try decode(bytes)
        return .object(["lineageID": s("invented-lineage"), "schemaVersion": value["schemaVersion"]!,
            "revision": value["revision"]!, "registrySHA256": s(C.digest(bytes)),
            "historySHA256": s(C.digest(try C.encoded(history)))])
    }
    private struct Fixture {
        var envelope: V
        var current: Data
        var checkpoint: V
        var catalog: [Entry] = []
    }
    private func base(_ bytes: Data, seeds: [Entry] = []) throws -> Fixture {
        let seedIDs = seeds.map(\.id)
        let authorities = Array(Set(seeds.compactMap { $0.document.value["authorityID"]?.text })).sorted()
        let inventory: V = .object(["attachmentRecordIDs": list(seedIDs), "statusRecordIDs": .array([]),
            "allocationIDs": seedIDs.isEmpty ? .array([]) : list(["allocation-seed"]),
            "reviewIDs": list(authorities), "selections": .array([])])
        let wrapped = wrapper("baseline", "B", .object(["lineageID": s("invented-lineage"),
            "ownerAuthority": s("invented-owner"), "registryBytes": blob(bytes), "registrySHA256": s(C.digest(bytes)),
            "legacyHistoryState": s("none"), "historyComplete": .bool(true), "seedInventory": inventory,
            "dependencyDigests": .array(seeds.map(binding))]))
        let baseline = try approved(wrapped, "review-B")
        let history: V = .object(["format": s("tsugino.synthetic-trip-history"), "schemaVersion": .integer(1),
            "lineageID": s("invented-lineage"), "baselineSHA256": s(C.digest(try C.encoded(baseline))), "boundaries": .array([])])
        let envelope: V = .object(["format": s("tsugino.synthetic-trip-registration"), "schemaVersion": .integer(1),
            "mode": s("synthetic"), "lineageID": s("invented-lineage"), "ownerAuthority": s("invented-owner"),
            "baseline": baseline, "history": history, "profiles": .array([]), "evidence": .array([]), "s9Artifacts": .array([])])
        return Fixture(envelope: envelope, current: bytes, checkpoint: try checkpoint(bytes, history), catalog: seeds)
    }
    private func request(_ f: inout Fixture, id: String, operation: String, records: [V], target: Data) throws {
        let payload: V = .object(["requestID": s(id), "lineageID": s("invented-lineage"), "operation": s(operation),
            "expectedPrevious": f.checkpoint, "targetRegistryBytes": blob(target), "records": .array(records),
            "profileIDs": .array([]), "evidenceIDs": .array([]), "s9ArtifactIDs": .array([]), "dependencyDigests": .array([])])
        try resign(&f, wrapper("request", id, payload))
    }
    private func resign(_ f: inout Fixture, _ request: V) throws {
        let canonical = try C.make(.payload, request).value
        f.envelope = set(set(f.envelope, "request", canonical), "approvals", .array([try approval(canonical, "review-" + canonical["subjectID"]!.text!)]))
    }
    private func changeRequest(_ f: inout Fixture, _ transform: (V) throws -> V) throws {
        let q = f.envelope["request"]!
        try resign(&f, set(q, "payload", transform(q["payload"]!)))
    }
    private func binding(_ entry: Entry) -> V {
        .object(["kind": s(entry.kind), "id": s(entry.id), "sha256": s(entry.document.sha256)])
    }
    private func inline(_ f: Fixture) throws -> [Entry] {
        let evidence = try f.envelope["evidence"]!.items.map {
            Entry(kind: "evidence", id: $0["evidenceID"]!.text!, document: try C.make(.evidence, $0))
        }
        let profiles = try f.envelope["profiles"]!.items.map {
            Entry(kind: "profile", id: $0["payload"]!["subjectID"]!.text!, document: try C.make(.approved, $0))
        }
        return evidence + profiles
    }
    private func rebind(_ f: inout Fixture) throws {
        let evidence = try f.envelope["evidence"]!.items.map {
            Entry(kind: "evidence", id: $0["evidenceID"]!.text!, document: try C.make(.evidence, $0))
        }
        let profiles = try f.envelope["profiles"]!.items.map { profile in
            let wrapped = profile["payload"]!, payload = wrapped["payload"]!
            let wanted = ["uniquenessEvidenceIDs", "meaningEvidenceIDs", "continuityEvidenceIDs"].flatMap { payload[$0]!.items.compactMap(\.text) }
            let deps = evidence.filter { wanted.contains($0.id) }.map(binding)
            return try approved(set(wrapped, "payload", set(payload, "dependencyDigests", .array(deps))), profile["approval"]!["reviewID"]!.text!)
        }
        f.envelope = set(f.envelope, "profiles", .array(profiles))
        let entries = try inline(f)
        try changeRequest(&f) { payload in
            set(set(set(payload, "profileIDs", list(profiles.map { $0["payload"]!["subjectID"]!.text! })),
                    "evidenceIDs", list(evidence.map(\.id))), "dependencyDigests", .array(entries.map(binding)))
        }
    }
    private func evidence(_ id: String, profile: String, keys: [V], trips: [String], records: [String], inputs: [String]) -> V {
        .object(["evidenceID": s(id), "sha256": s(zero), "locator": s("invented-whole-record"), "role": s("identity"),
            "profileID": s(profile), "profileVersion": s("1"), "inputSHA256s": list(inputs),
            "view": .object(["sourceRevision": s("00000000-0000-0000-0000-000000000001"),
                "mappingRevision": s("00000000-0000-0000-0000-000000000002"),
                "profileRevision": s("00000000-0000-0000-0000-000000000003"),
                "reviewRevision": s("00000000-0000-0000-0000-000000000004")]),
            "referenceKeys": .array(keys), "tripIDs": list(trips), "recordIDs": list(records), "artifactIDs": .array([]),
            "disposition": s("supports"), "applicability": .array([]), "viewApplicability": .array([])])
    }
    private func supply(_ f: inout Fixture, prefix: String = "Q", inputs: [String]? = nil) throws {
        let records = f.envelope["request"]!["payload"]!["records"]!.items
        let claims = records.flatMap { $0["referenceKeys"]?.items ?? [$0["key"] ?? key()] }
        var keys: [V] = [], seen = Set<Data>()
        for claim in claims {
            if seen.insert(try C.encoded(claim)).inserted { keys.append(claim) }
        }
        let profileID = "P-" + prefix, inputs = inputs ?? [nextInput]
        let ids = ["unique", "meaning", "continuity", "correspondence"].map { "E-" + prefix + "-" + $0 }
        let evidence = ids.map { self.evidence($0, profile: profileID, keys: keys,
            trips: Array(Set(records.map { $0["tripID"]!.text! })).sorted(), records: records.map { $0["recordID"]!.text! }, inputs: inputs) }
        let profile = wrapper("profile", profileID, .object(["profileID": s(profileID), "version": s("1"),
            "sourceID": s("invented"), "publisherScope": s("invented"), "resourceScope": s("invented"), "feedScope": s("invented"),
            "namespace": s("gtfs.trip_id"), "applicableInputSHA256s": list(inputs),
            "uniquenessEvidenceIDs": list([ids[0]]), "meaningEvidenceIDs": list([ids[1]]), "continuityEvidenceIDs": list([ids[2]]), "dependencyDigests": .array([])]))
        f.envelope = set(set(f.envelope, "profiles", .array([try approved(profile, "review-" + profileID)])), "evidence", .array(evidence))
        try changeRequest(&f) { set($0, "records", .array(records.map { set($0, "correspondenceEvidenceIDs", list([ids[3]])) })) }
        try rebind(&f)
    }
    private func mutateEvidence(_ f: inout Fixture, purpose: String, field: String, value: V) throws {
        let changed = f.envelope["evidence"]!.items.map { evidence in
            evidence["evidenceID"]!.text!.hasSuffix("-" + purpose) ? set(evidence, field, value) : evidence
        }
        f.envelope = set(f.envelope, "evidence", .array(changed)); try rebind(&f)
    }
    private func mutateProfile(_ f: inout Fixture, field: String, value: V) throws {
        let profile = f.envelope["profiles"]!.items[0], wrapped = profile["payload"]!
        let changed = try approved(set(wrapped, "payload", set(wrapped["payload"]!, field, value)), profile["approval"]!["reviewID"]!.text!)
        f.envelope = set(f.envelope, "profiles", .array([changed])); try rebind(&f)
    }
    private func alterProfileApproval(_ f: inout Fixture, missing: Bool) throws {
        let profile = f.envelope["profiles"]!.items[0]
        let changed = set(profile, "approval", missing ? nil : set(profile["approval"]!, "reviewer", s("unrelated-owner")))
        f.envelope = set(f.envelope, "profiles", .array([changed]))
        // The request approves these exact incomplete/invalid profile bytes. It cannot supply
        // the missing profile approval or turn another reviewer's assertion into the owner's.
        let entries = try inline(f)
        try changeRequest(&f) { set($0, "dependencyDigests", .array(entries.map(binding))) }
    }
    private func append(_ f: inout Fixture) throws {
        let q = f.envelope["request"]!, history = f.envelope["history"]!, prior = history["boundaries"]!.items
        let entries = try inline(f) + f.catalog
        let dependencies = q["payload"]!["dependencyDigests"]!.items.map { binding -> V in
            let entry = entries.first { $0.kind == binding["kind"]!.text! && $0.id == binding["id"]!.text! }!
            return .object(["kind": s(entry.kind), "id": s(entry.id), "bytes": blob(entry.document.bytes)])
        }
        var boundary: V = .object(["previousRegistryBytes": blob(f.current), "targetRegistryBytes": q["payload"]!["targetRegistryBytes"]!,
            "request": q, "approvals": f.envelope["approvals"]!, "dependencies": .array(dependencies)])
        if let last = prior.last { boundary = set(boundary, "previousBoundarySHA256", s(C.digest(try C.encoded(last)))) }
        let retained = try C.make(.history, set(history, "boundaries", .array(prior + [boundary]))).value
        f.current = raw(q["payload"]!["targetRegistryBytes"]!)
        f.envelope = set(f.envelope, "history", retained); f.checkpoint = try checkpoint(f.current, retained)
    }
    private func converted(entities: [V] = [], completeHistory: Bool = true) throws -> Fixture {
        var f = try base(registry(0, entities: entities, references: [], schema: 2))
        if !completeHistory {
            let b = f.envelope["baseline"]!["payload"]!
            let approvedBase = try approved(set(b,"payload",set(b["payload"]!,"historyComplete",.bool(false))),"review-B")
            f.envelope = set(f.envelope,"baseline",approvedBase)
            let history = set(f.envelope["history"]!,"baselineSHA256",s(C.digest(try C.encoded(approvedBase))))
            f.envelope = set(f.envelope,"history",history); f.checkpoint = try checkpoint(f.current,history)
        }
        try request(&f, id: "conversion", operation: "convertLegacy", records: [], target: registry(1, entities: entities, references: []))
        try append(&f)
        return f
    }
    private func u(_ n: Int) -> UUID { UUID(uuidString: String(format:"00000000-0000-0000-0000-%012x",n))! }
    private func uv(_ n: Int) -> V { s(u(n).uuidString.lowercased()) }
    private func snapshot(_ id: String, into f: inout Fixture, prior: String? = nil, viewNumber: Int = 2,
                          stops: [String] = ["A","B","A","C"], split: Bool = false, proofShift: Int = 0, sourceKey: V? = nil, identityKey: V? = nil) throws {
        let sourceKey = sourceKey ?? key()
        let view = SyntheticTripReviewView(sourceRevision:u(1),mappingRevision:u(viewNumber),profileRevision:u(3),reviewRevision:u(4))
        let line = LineID("L")!, positions = stops.enumerated().map { i, name in
            SyntheticTripPosition(reference:u(100+i),order:(i+1)*10,
                classification:.passenger(.resolved(StationID(name)!,membership:[line],evidence:u(300+i)),evidence:u(200+i)))
        }
        let end = 100+stops.count-1, movement = 400+proofShift
        let moves: [SyntheticTripMovement] = split ? [
            .init(from:u(100),to:u(101),line:.resolved(line,evidence:u(movement))),
            .init(from:u(101),to:u(end),line:.resolved(line,evidence:u(movement)))] : [
            .init(from:u(100),to:u(end),line:.resolved(line,evidence:u(movement)))]
        let run = SyntheticTripReviewRun(reference:u(5),view:view,positions:positions,first:u(100),last:u(end),intervalEvidence:u(10),
            identity:.reviewed(TripID(trip)!,evidence:u(11)),continuityEvidence:u(12),
            origin:.reached(evidence:u(13)),destination:.reached(evidence:u(14)),movements:moves,prior:nil)
        let proofs = Set([10,11,12,13,14,movement] + stops.indices.map { 200+$0 } + stops.indices.map { 300+$0 })
        let packet = try SyntheticTripRegistrationS9Codec.encode(.init(view:view,evidenceReferences:Set(proofs.map(u)),runs:[run]),
            predecessors:prior.map { [u(5):$0] } ?? [:])
        let wire = packet.value, profileID = "AP-"+id, evidenceID = "AE-"+id, scopeID = "AS-"+id
        let baseScope: V = .object(["tripID":s(trip),"profileID":s(profileID),"profileVersion":s("1"),"sourceID":s("invented"),
            "referenceKeys":.array([sourceKey]),"view":wire["view"]!])
        var bindings: [V] = []
        func proof(_ role: String, _ n: Int, _ fields: [String: V] = [:]) {
            var scope = baseScope
            for (k,v) in fields { scope = set(scope,k,v) }
            bindings.append(.object(["runReference":uv(5),"role":s(role),"proofUUID":uv(n),"evidenceID":s(evidenceID),"scope":scope]))
        }
        proof("interval",10,["from":uv(100),"to":uv(end)]); proof("continuity",12,["from":uv(100),"to":uv(end)])
        proof("identity",11,["referenceKeys":.array([identityKey ?? sourceKey])]); proof("origin",13,["occurrence":uv(100)]); proof("destination",14,["occurrence":uv(end)])
        for i in stops.indices { proof("classification",200+i,["occurrence":uv(100+i)]); proof("mapping",300+i,["occurrence":uv(100+i)]) }
        proof("movement",movement,["from":uv(100),"to":uv(end),"lineID":s("L")])
        let views: [V] = SyntheticRegistrationSchema.components.map {
            .object(["component":s($0),"revisionUUID":wire["view"]![$0]!,"evidenceID":s(evidenceID),"profileID":s(profileID),"profileVersion":s("1")])
        }
        let keys = identityKey.map { (try? same($0,sourceKey)) == true ? [sourceKey]:[sourceKey,$0] } ?? [sourceKey]
        var e = evidence(evidenceID,profile:profileID,keys:keys,trips:[trip],records:[],inputs:[nextInput])
        e = set(set(e,"view",wire["view"]!),"artifactIDs",list([id]))
        e = set(e,"applicability",.array(bindings.map { set(set($0,"proofUUID",nil),"evidenceID",nil) }))
        e = set(e,"viewApplicability",.array(views.map { set(set($0,"evidenceID",nil),"inputSHA256s",list([nextInput])) }))
        var source = set(e,"evidenceID",s(scopeID)); source = set(set(source,"applicability",.array([])),"viewApplicability",.array([]))
        let sourceDoc = try C.make(.evidence,source), eDoc = try C.make(.evidence,e)
        let sourceEntry = Entry(kind:"evidence",id:scopeID,document:sourceDoc)
        let profile = try C.make(.approved,approved(wrapper("profile",profileID,.object([
            "profileID":s(profileID),"version":s("1"),"sourceID":s("invented"),"namespace":s("gtfs.trip_id"),
            "publisherScope":s("invented"),"resourceScope":s("invented"),"feedScope":s("invented"),"applicableInputSHA256s":list([nextInput]),
            "uniquenessEvidenceIDs":list([scopeID]),"meaningEvidenceIDs":list([scopeID]),"continuityEvidenceIDs":list([scopeID]),
            "dependencyDigests":.array([binding(sourceEntry)])])),"review-"+profileID))
        var deps = [sourceEntry,Entry(kind:"evidence",id:evidenceID,document:eDoc),Entry(kind:"profile",id:profileID,document:profile)]
        if let prior { deps += try closure([prior],f) }
        let artifact = try C.make(.s9Artifact,.object(["schemaVersion":.integer(1),"artifactID":s(id),"packetBytes":blob(packet.bytes),
            "packetSHA256":s(packet.sha256),"selectedRunReference":uv(5),"proofBindings":.array(bindings),"viewBindings":.array(views),
            "dependencyDigests":.array(deps.map(binding))]))
        f.catalog += [sourceEntry,Entry(kind:"evidence",id:evidenceID,document:eDoc),Entry(kind:"profile",id:profileID,document:profile),
                      Entry(kind:"s9Artifact",id:id,document:artifact)]
    }
    private func closure(_ ids: [String], _ f: Fixture) throws -> [Entry] {
        var entries: [Entry] = []
        for id in ids {
            let a = try #require(f.catalog.first { $0.kind == "s9Artifact" && $0.id == id })
            for d in a.document.value["dependencyDigests"]!.items {
                let entry = try #require(f.catalog.first { $0.kind == d["kind"]!.text! && $0.id == d["id"]!.text! })
                if !entries.contains(where: { $0.kind == entry.kind && $0.id == entry.id }) { entries.append(entry) }
            }
            if !entries.contains(where: { $0.kind == a.kind && $0.id == a.id }) { entries.append(a) }
        }
        return entries
    }
    private func bind(_ f: inout Fixture, ids: [String]) throws {
        let entries = try inline(f) + closure(ids,f)
        try changeRequest(&f) { set(set($0,"s9ArtifactIDs",list(ids)),"dependencyDigests",.array(entries.map(binding))) }
    }
    private func correspondence(_ f: inout Fixture, ids: [String], selected: String, prefix: String) throws {
        try supply(&f,prefix:prefix)
        let artifact = try #require(f.catalog.first { $0.id == selected && $0.kind == "s9Artifact" })
        let view = try C.read(.s9Packet,raw(artifact.document.value["packetBytes"]!)).value["view"]!
        f.envelope = set(f.envelope,"evidence",.array(f.envelope["evidence"]!.items.map { set(set($0,"artifactIDs",list(ids)),"view",view) }))
        try rebind(&f); try bind(&f,ids:ids)
    }
    private func registration(_ artifact: String? = "A0", stops: [String] = ["A","B","A","C"], completeHistory: Bool = true) throws -> Fixture {
        var f = try converted(completeHistory:completeHistory)
        var r: V = .object(["recordID":s("register-T"),"allocationRequestID":s("allocation-T"),"tripID":s(trip),
            "referenceKeys":.array([key()]),"correspondenceEvidenceIDs":.array([])])
        if let artifact { r = set(r,"snapshotArtifactID",s(artifact)) }
        try request(&f,id:"Q",operation:"register",records:[r],target:registry(2,entities:[entity(trip)],references:[reference(key())]))
        if let artifact { try snapshot(artifact,into:&f,stops:stops); try correspondence(&f,ids:[artifact],selected:artifact,prefix:"Q") }
        else { try supply(&f) }
        return f
    }
    private func select(_ f: inout Fixture, id: String, artifact: String, previous: String? = nil) throws {
        let current = try decode(f.current)
        guard case .integer(let rev) = current["revision"]! else { fatalError("fixture") }
        var r: V = .object(["recordID":s("record-"+id),"tripID":s(trip),"mode":s(previous == nil ? "initialSelection":"revision"),
            "nextArtifactID":s(artifact),"correspondenceEvidenceIDs":.array([])])
        if let previous { r = set(r,"previousArtifactID",s(previous)) }
        try request(&f,id:id,operation:"reviseSnapshot",records:[r],target:registry(rev+1,entities:current["entities"]!.items,references:current["references"]!.items))
        try correspondence(&f,ids:previous.map { [artifact,$0] } ?? [artifact],selected:artifact,prefix:id)
    }
    private func mutateArtifact(_ f: inout Fixture, _ id: String = "A0", _ transform: (V) throws -> V) throws {
        let i = try #require(f.catalog.firstIndex { $0.kind == "s9Artifact" && $0.id == id })
        f.catalog[i] = .init(kind:"s9Artifact",id:id,document:try C.make(.s9Artifact,transform(f.catalog[i].document.value)))
        try bind(&f,ids:f.envelope["request"]!["payload"]!["s9ArtifactIDs"]!.items.map { $0.text! })
    }
    private func run(_ f: Fixture) throws -> SyntheticRegistrationResult {
        A.validate(envelopeBytes:try C.make(.envelope,f.envelope).bytes,currentRegistryBytes:f.current,
            currentCheckpointBytes:try C.make(.checkpoint,f.checkpoint).bytes,catalog:f.catalog)
    }
    private func candidate(_ f: Fixture, replay: Bool = false) throws -> SyntheticRegistrationCandidate {
        switch try run(f) {
        case .candidateDelta(let c): #expect(!replay); return c
        case .unchangedReplay(let c): #expect(replay); return c
        case .held(let d), .rejected(let d): Issue.record("Unexpected diagnostics: \(d)"); throw TestFailure.unexpected
        }
    }
    enum TestFailure: Error { case unexpected }
    private func diagnostics(_ f: Fixture, rejected: Bool) throws -> [D] {
        switch try run(f) {
        case .held(let d): #expect(!rejected); return d
        case .rejected(let d): #expect(rejected); return d
        default: throw TestFailure.unexpected
        }
    }

    @Test(arguments:[false,true]) func s01RegistrationAndLosslessRepeatedVisits(_ withSnapshot: Bool) throws {
        let f = try registration(withSnapshot ? "A0":nil), bytes = try C.make(.envelope,f.envelope).bytes
        let c = try candidate(f)
        #expect(c.recordIDs == ["register-T"])
        #expect(c.registryBytes == raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        #expect(c.selections.count == (withSnapshot ? 1:0))
        if withSnapshot {
            let selected = try #require(c.selections.first)
            #expect(selected.candidate.trip.stopSequence.map(\.rawValue) == ["A","B","A","C"])
            #expect(selected.candidate.crosswalk.map(\.originalIndex) == [0,1,2,3])
            #expect(c.revalidation.count == 1)
            #expect(c.revalidation[0].uses.map(\.rawValue) == SyntheticRegistrationDownstreamUse.allCases.map(\.rawValue))
        }
        #expect(try C.make(.envelope,f.envelope).bytes == bytes)
    }
    @Test func s02FirstSelectionAndReplay() throws {
        var f = try registration(nil); try append(&f); try snapshot("A0",into:&f)
        try select(&f,id:"S",artifact:"A0")
        let c = try candidate(f); #expect(c.revalidation.last?.reason == .initialSelection)
        try append(&f)
        let replay = try candidate(f,replay:true)
        #expect(replay.registryBytes == c.registryBytes); #expect(replay.historyBytes == c.historyBytes)
        #expect(replay.checkpointBytes == c.checkpointBytes)
    }
    @Test func s03KnownPreviousSelectionRejectsInitial() throws {
        var f = try registration(); try append(&f); try select(&f,id:"S",artifact:"A0")
        let ds = try diagnostics(f,rejected:true)
        #expect(ds.map(\.issue) == [.snapshotConflict]); #expect(ds[0].locator == "record-S")
    }
    @Test func s04FullPredecessorChainAndChangedViewRevision() throws {
        var f = try registration(); try append(&f)
        try snapshot("A1",into:&f,prior:"A0",viewNumber:22,stops:["A","C"])
        try select(&f,id:"S1",artifact:"A1",previous:"A0"); _ = try candidate(f); try append(&f)
        try snapshot("A2",into:&f,prior:"A1",viewNumber:23)
        try select(&f,id:"S2",artifact:"A2",previous:"A1")
        let c = try candidate(f)
        #expect(c.selections[0].artifactID == "A2")
        #expect(c.revalidation.last?.previousArtifactID == "A1")
        #expect(c.revalidation.last?.reason == .snapshotViewOrEvidenceChanged)
    }
    @Test func s05SameViewContradictionRemainsRejected() throws {
        var f = try registration(); try append(&f)
        try snapshot("A1",into:&f,prior:"A0",stops:["A","C"])
        try select(&f,id:"S",artifact:"A1",previous:"A0")
        #expect(try diagnostics(f,rejected:true).contains { $0.issue == .snapshotConflict && $0.locator == "A1" })
    }
    @Test(arguments:[false,true]) func s06SplitUnsplitProofApplicability(_ changedProof: Bool) throws {
        var f = try registration(); try append(&f)
        try snapshot("A1",into:&f,prior:"A0",split:true,proofShift:changedProof ? 1:0)
        try select(&f,id:"S",artifact:"A1",previous:"A0")
        if changedProof { #expect(try diagnostics(f,rejected:true).contains { $0.issue == .snapshotConflict && $0.locator == "A1" }) }
        else {
            let c = try candidate(f)
            #expect(c.selections[0].candidate.trip.stopSequence.map(\.rawValue) == ["A","B","A","C"])
            #expect(c.revalidation.last?.reason == .snapshotViewOrEvidenceChanged)
        }
    }
    @Test(arguments:["missingProof","wrongOccurrence","missingView","wrongView"])
    func s07ProofAndViewBindings(_ mutation: String) throws {
        var f = try registration()
        try mutateArtifact(&f) { a in
            switch mutation {
            case "missingProof": return set(a,"proofBindings",.array(Array(a["proofBindings"]!.items.dropFirst())))
            case "wrongOccurrence":
                var b = a["proofBindings"]!.items
                let i = b.firstIndex { $0["role"]?.text == "classification" }!
                b[i] = set(b[i],"scope",set(b[i]["scope"]!,"occurrence",uv(999)))
                return set(a,"proofBindings",.array(b))
            case "missingView": return set(a,"viewBindings",.array(Array(a["viewBindings"]!.items.dropFirst())))
            default:
                var b = a["viewBindings"]!.items; b[0] = set(b[0],"revisionUUID",uv(999)); return set(a,"viewBindings",.array(b))
            }
        }
        let ds = try diagnostics(f,rejected:mutation.hasPrefix("wrong"))
        #expect(ds.contains { $0.issue == (mutation.hasPrefix("wrong") ? .snapshotConflict : mutation == "missingView" ? .scopeUnavailable : .correspondenceUnavailable) && $0.locator == "A0" })
    }
    @Test func s08MissingHistoryCannotEstablishFirstSelection() throws {
        var f = try registration(nil,completeHistory:false); try append(&f)
        try snapshot("A0",into:&f); try select(&f,id:"S",artifact:"A0")
        let ds = try diagnostics(f,rejected:false)
        #expect(ds.allSatisfy { $0.issue == .historyUnavailable })
        #expect(ds.contains { $0.locator == "record-S" })
    }
    private func mutatePacket(_ f: inout Fixture, _ id: String = "A0", _ change: (V) throws -> V) throws {
        try mutateArtifact(&f,id) { a in
            let p = try C.make(.s9Packet,change(C.read(.s9Packet,raw(a["packetBytes"]!)).value))
            return set(set(a,"packetBytes",blob(p.bytes)),"packetSHA256",s(p.sha256))
        }
    }
    private func strip(_ f: inout Fixture, kind: String, id: String) {
        f.catalog.removeAll { $0.kind == kind && $0.id == id }
        let h = f.envelope["history"]!
        f.envelope = set(f.envelope,"history",set(h,"boundaries",.array(h["boundaries"]!.items.map { b in
            set(b,"dependencies",.array(b["dependencies"]!.items.filter { $0["kind"]?.text != kind || $0["id"]?.text != id }))
        })))
        // Intentionally do not repair retained links/checkpoints: missing retained bytes is
        // uncertainty plus any independently provable history mismatch, never fabricated data.
    }
    private func ordered(_ d: [D]) -> Bool {
        d == d.sorted { $0.issue.rawValue == $1.issue.rawValue ? $0.locator.utf8.lexicographicallyPrecedes($1.locator.utf8) : $0.issue.rawValue < $1.issue.rawValue }
    }
    @Test(arguments:[false,true]) func s09MissingPredecessorAndIndependentConflict(_ conflict: Bool) throws {
        var f = try registration("A1")
        try snapshot("A0",into:&f)
        try mutatePacket(&f,"A1") { p in set(p,"runs",.array(p["runs"]!.items.map { set($0,"priorArtifactID",s("A0")) })) }
        let dep = try #require(f.catalog.first { $0.id == "A0" && $0.kind == "s9Artifact" })
        try mutateArtifact(&f,"A1") { a in set(a,"dependencyDigests",.array(a["dependencyDigests"]!.items + [binding(dep)])) }
        try bind(&f,ids:["A1","A0"])
        f.catalog.removeAll { $0.kind == "s9Artifact" && $0.id == "A0" }
        if conflict {
            // Selected request target is conclusively wrong even when its prior is absent.
            let i = try #require(f.catalog.firstIndex { $0.kind == "s9Artifact" && $0.id == "A1" })
            let a = f.catalog[i].document.value
            let wire = try C.read(.s9Packet,raw(a["packetBytes"]!)).value
            let p = try C.make(.s9Packet,set(wire,"runs",.array(wire["runs"]!.items.map { set($0,"identity",set($0["identity"]!,"tripID",s(secondTrip))) })))
            f.catalog[i] = .init(kind:"s9Artifact",id:"A1",document:try C.make(.s9Artifact,set(set(a,"packetBytes",blob(p.bytes)),"packetSHA256",s(p.sha256))))
            let changedBinding = binding(f.catalog[i])
            try changeRequest(&f) { p in set(p,"dependencyDigests",.array(p["dependencyDigests"]!.items.map { d in d["id"]?.text == "A1" ? changedBinding : d })) }
        }
        let ds = try diagnostics(f,rejected:conflict)
        #expect(ordered(ds)); #expect(ds.contains { $0.issue == .snapshotUnavailable && $0.locator == "A0" })
        #expect(ds.contains { $0.issue == .snapshotConflict } == conflict)
    }
    @Test(arguments:["missing","wrong","lookalike"])
    func s10ExactSelectedPredecessor(_ mode: String) throws {
        var f = try registration(); try append(&f)
        try snapshot("lookalike",into:&f)
        try snapshot("A1",into:&f,prior:mode == "lookalike" ? "lookalike":"A0",viewNumber:22)
        try select(&f,id:"S",artifact:"A1",previous:"A0")
        if mode != "lookalike" {
            try mutatePacket(&f,"A1") { p in set(p,"runs",.array(p["runs"]!.items.map { set($0,"priorArtifactID",mode == "missing" ? nil:s("lookalike")) })) }
        }
        let ds = try diagnostics(f,rejected:true)
        #expect(ds.contains { $0.issue == .snapshotConflict && $0.locator == "record-S" }); #expect(ordered(ds))
    }
    @Test(arguments:[false,true]) func s11UnselectedRunIsNeverSkipped(_ conflict: Bool) throws {
        var f = try registration()
        try mutatePacket(&f) { p in
            var extra = set(p["runs"]!.items[0],"reference",uv(6))
            extra = set(extra,"identity",.object(["tag":s(conflict ? "impossible":"unresolved")]))
            return set(p,"runs",.array(p["runs"]!.items + [extra]))
        }
        let ds = try diagnostics(f,rejected:conflict)
        #expect(ds == (conflict ? [D(issue:.snapshotConflict,locator:"A0"),D(issue:.correspondenceUnavailable,locator:"A0")] : [D(issue:.correspondenceUnavailable,locator:"A0")]))
    }
    @Test(arguments:["unrelated","contradiction","contradictionMissing","incidental"])
    func s12CompetingEvidenceAndScope(_ mode: String) throws {
        var f = try registration()
        let original = try #require(f.catalog.first { $0.id == "AE-A0" })
        var value = set(original.document.value,"evidenceID",s("competing"))
        value = set(value,"disposition",s("contradicts"))
        if mode == "unrelated" { value = set(set(value,"tripIDs",list([secondTrip])),"view",set(value["view"]!,"mappingRevision",uv(999))) }
        let competing = Entry(kind:"evidence",id:"competing",document:try C.make(.evidence,value))
        f.catalog.append(competing)
        if mode != "incidental" {
            try changeRequest(&f) { p in set(set(p,"evidenceIDs",.array(p["evidenceIDs"]!.items + [s("competing")])),"dependencyDigests",.array(p["dependencyDigests"]!.items + [binding(competing)])) }
        }
        if mode == "contradictionMissing" {
            f.catalog.removeAll { $0.id == "AE-A0" }
        }
        if mode == "unrelated" || mode == "incidental" { _ = try candidate(f) }
        else {
            let ds = try diagnostics(f,rejected:true)
            #expect(ds.contains { $0.issue == .snapshotConflict && $0.locator == "A0" }); #expect(ordered(ds))
            if mode == "contradictionMissing" { #expect(ds.contains { $0.issue == .correspondenceUnavailable }) }
            else { #expect(ds == [D(issue:.snapshotConflict,locator:"A0")]) }
        }
    }
    @Test(arguments:[false,true]) func s13RetainedRequiredS9AndReplay(_ replay: Bool) throws {
        var f = try registration()
        // Move the already complete artifact closure into the conversion's approved request.
        let h = f.envelope["history"]!, oldBoundary = h["boundaries"]!.items[0]
        var q = oldBoundary["request"]!, p = q["payload"]!
        let entries = try closure(["A0"],f)
        p = set(set(p,"s9ArtifactIDs",list(["A0"])),"dependencyDigests",.array(entries.map(binding)))
        q = try C.make(.payload,set(q,"payload",p)).value
        var b = set(set(oldBoundary,"request",q),"approvals",.array([try approval(q,"review-conversion")]))
        b = set(b,"dependencies",.array(entries.map { .object(["kind":s($0.kind),"id":s($0.id),"bytes":blob($0.document.bytes)]) }))
        let history = try C.make(.history,set(h,"boundaries",.array([b]))).value
        f.envelope = set(f.envelope,"history",history); f.checkpoint = try checkpoint(f.current,history)
        let pin = f.checkpoint
        try changeRequest(&f) { set($0,"expectedPrevious",pin) }
        if replay { try append(&f) }
        #expect(try candidate(f,replay:replay).selections.count == 1)
        if case .outsideC1 = A.validateIdentityOnly(envelopeBytes:try C.make(.envelope,f.envelope).bytes,currentRegistryBytes:f.current,
            currentCheckpointBytes:try C.make(.checkpoint,f.checkpoint).bytes,catalog:f.catalog) {} else { Issue.record("C1 capability gate lost") }
    }
    @Test(arguments:[false,true]) func s14AtomicMultipleSelections(_ broken: Bool) throws {
        var f = try registration(nil); try append(&f); try snapshot("A0",into:&f); try select(&f,id:"S",artifact:"A0")
        // Duplicate target is an established record-accounting conflict independent of proof.
        try changeRequest(&f) { p in set(p,"records",.array(p["records"]!.items + [set(p["records"]!.items[0],"recordID",s("second-selection"))])) }
        if broken { f.catalog.removeAll { $0.id == "AE-A0" } }
        let before = try C.make(.envelope,f.envelope).bytes, ds = try diagnostics(f,rejected:true)
        #expect(ds.contains { $0.issue == .snapshotConflict && $0.locator == "record-S" })
        #expect(ds.contains { $0.issue == .snapshotConflict && $0.locator == "second-selection" })
        #expect(ordered(ds)); #expect(try C.make(.envelope,f.envelope).bytes == before)
    }
    @Test(arguments:[false,true]) func s15ReplayCannotBypassMissingRetainedProof(_ stale: Bool) throws {
        var f = try registration(); try append(&f)
        let original = f.envelope["request"]!, approvals = f.envelope["approvals"]!
        if stale {
            try snapshot("A1",into:&f,prior:"A0",viewNumber:22); try select(&f,id:"S",artifact:"A1",previous:"A0"); try append(&f)
            f.envelope = set(set(f.envelope,"request",original),"approvals",approvals)
        } else {
            strip(&f,kind:"evidence",id:"AE-A0")
            f.checkpoint = try checkpoint(f.current,f.envelope["history"]!)
        }
        let ds = try diagnostics(f,rejected:stale)
        #expect(ds.contains { $0.issue == (stale ? .staleCheckpoint:.correspondenceUnavailable) }); #expect(ordered(ds))
    }
    @Test func s16KnownSelectionSurvivesUnavailableArtifact() throws {
        var f = try registration(); try append(&f); try snapshot("A1",into:&f)
        try select(&f,id:"S",artifact:"A1")
        strip(&f,kind:"s9Artifact",id:"A0")
        let ds = try diagnostics(f,rejected:true)
        #expect(ds.contains { $0.issue == .snapshotConflict && $0.locator == "record-S" })
        #expect(ds.contains { $0.issue == .snapshotUnavailable && $0.locator == "A0" }); #expect(ordered(ds))
    }
    @Test func s17CyclicDeclaredPredecessorRejectsWithoutFabrication() throws {
        var f = try registration()
        // A self-edge cannot have a consistent cryptographic digest. Both the explicit
        // graph cycle and the established binding mismatch must survive that fact.
        let i = try #require(f.catalog.firstIndex { $0.id == "A0" && $0.kind == "s9Artifact" })
        let a = f.catalog[i].document.value, wire = try C.read(.s9Packet,raw(a["packetBytes"]!)).value
        let packet = try C.make(.s9Packet,set(wire,"runs",.array(wire["runs"]!.items.map { set($0,"priorArtifactID",s("A0")) })))
        var changed = set(set(a,"packetBytes",blob(packet.bytes)),"packetSHA256",s(packet.sha256))
        changed = set(changed,"dependencyDigests",.array(a["dependencyDigests"]!.items + [.object(["kind":s("s9Artifact"),"id":s("A0"),"sha256":s(zero)])]))
        f.catalog[i] = .init(kind:"s9Artifact",id:"A0",document:try C.make(.s9Artifact,changed))
        let deps = try inline(f) + f.catalog
        try changeRequest(&f) { set($0,"dependencyDigests",.array(deps.map(binding))) }
        let ds = try diagnostics(f,rejected:true)
        #expect(ds.contains { $0.issue == .snapshotConflict && $0.locator == "A0" })
        #expect(ds.contains { $0.issue == .historyConflict && $0.locator == "A0" }); #expect(ordered(ds))
    }
    @Test(arguments:["interval","identity","continuity","origin","destination","classification","mapping","movement"])
    func s18EveryPrivateProofRoleRequiresItsOwnBinding(_ role: String) throws {
        var f = try registration()
        try mutateArtifact(&f) { a in set(a,"proofBindings",.array(a["proofBindings"]!.items.filter { $0["role"]?.text != role })) }
        #expect(try diagnostics(f,rejected:false) == [D(issue:.correspondenceUnavailable,locator:"A0")])
    }
    @Test(arguments:[false,true]) func s19ChangedViewCannotInheritOldAuthority(_ conflicting: Bool) throws {
        var f = try registration(); try append(&f)
        try snapshot("A1",into:&f,prior:"A0",viewNumber:22); try select(&f,id:"S",artifact:"A1",previous:"A0")
        f.catalog.removeAll { $0.id == "AP-A1" }
        if conflicting {
            // Preserve the profile dependency binding, remove bytes only, then change the
            // selected target directly and update only the approved artifact digest.
            let i = try #require(f.catalog.firstIndex { $0.id == "A1" && $0.kind == "s9Artifact" })
            let a = f.catalog[i].document.value, wire = try C.read(.s9Packet,raw(a["packetBytes"]!)).value
            let packet = try C.make(.s9Packet,set(wire,"runs",.array(wire["runs"]!.items.map { set($0,"identity",set($0["identity"]!,"tripID",s(secondTrip))) })))
            f.catalog[i] = .init(kind:"s9Artifact",id:"A1",document:try C.make(.s9Artifact,set(set(a,"packetBytes",blob(packet.bytes)),"packetSHA256",s(packet.sha256))))
            let binding = binding(f.catalog[i])
            try changeRequest(&f) { p in set(p,"dependencyDigests",.array(p["dependencyDigests"]!.items.map { $0["id"]?.text == "A1" ? binding:$0 })) }
        }
        let ds = try diagnostics(f,rejected:conflicting)
        #expect(ds.contains { $0.issue == .scopeUnavailable && $0.locator == "AP-A1" })
        #expect(ds.contains { $0.issue == .snapshotConflict } == conflicting); #expect(ordered(ds))
    }
    @Test(arguments:[false,true]) func s20IncidentalArtifactAndAlteredReplay(_ altered: Bool) throws {
        var f = try registration(nil)
        try snapshot("unrelated",into:&f)
        if altered {
            try append(&f)
            try changeRequest(&f) { p in set(p,"records",.array(p["records"]!.items.map { set($0,"recordID",s("changed-record")) })) }
            #expect(try diagnostics(f,rejected:true).contains { $0.issue == .historyConflict })
        } else { #expect(try candidate(f).selections.isEmpty) }
    }
    @Test func s21InitialSelectionMustHaveNoPriorEvenAtSameTrip() throws {
        var f = try registration(nil); try append(&f)
        try snapshot("A0",into:&f); try snapshot("A1",into:&f,prior:"A0")
        try select(&f,id:"S",artifact:"A1")
        #expect(try diagnostics(f,rejected:true) == [D(issue:.snapshotConflict,locator:"record-S")])
    }
    @Test(arguments:[false,true]) func s22AtomicRegistrationRecordOrder(_ reversed: Bool) throws {
        var f = try registration()
        let first = f.envelope["request"]!["payload"]!["records"]!.items[0]
        var second = set(set(set(set(first,"recordID",s("register-second")),"allocationRequestID",s("allocation-second")),"tripID",s(secondTrip)),"snapshotArtifactID",nil)
        second = set(second,"referenceKeys",.array([key("second-run")]))
        let records = reversed ? [second,first]:[first,second]
        try changeRequest(&f) { p in
            set(set(p,"records",.array(records)),"targetRegistryBytes",blob(try registry(2,entities:[entity(trip),entity(secondTrip)],references:[reference(key()),reference(key("second-run"),tripID:secondTrip)])))
        }
        try correspondence(&f,ids:["A0"],selected:"A0",prefix:"Q")
        let c = try candidate(f)
        #expect(c.recordIDs == records.map { $0["recordID"]!.text! }); #expect(c.selections.count == 1)
        #expect(c.revalidation.count == 1); #expect(c.revalidation[0].recordID == "register-T")
    }
    @Test func s23ReferenceBindingChangeEmitsObligations() throws {
        var f = try registration(); try append(&f)
        let r: V = .object(["recordID":s("attach-extra"),"tripID":s(trip),"key":key("new-key"),"mode":s("newKey"),"correspondenceEvidenceIDs":.array([])])
        let old = try decode(f.current)
        try request(&f,id:"attach",operation:"attach",records:[r],target:registry(3,entities:old["entities"]!.items,
            references:old["references"]!.items + [reference(key("new-key"),authority:"review-attach")]))
        try supply(&f,prefix:"attach")
        let c = try candidate(f)
        #expect(c.revalidation.last?.reason == .referenceBindingChanged)
        #expect(c.revalidation.last?.artifactID == "A0")
        #expect(c.revalidation.last?.uses.count == 5)
    }
    @Test(arguments:[false,true]) func s24MappingUncertaintySurvivesIndependentRejection(_ unavailable: Bool) throws {
        var f = try registration()
        try mutatePacket(&f) { p in
            var run = p["runs"]!.items[0], positions = run["positions"]!.items
            positions[1] = set(positions[1],"classification",set(positions[1]["classification"]!,"mapping",.object(["tag":s(unavailable ? "unavailable":"impossible")])))
            run = set(set(run,"positions",.array(positions)),"identity",.object(["tag":s("impossible")]))
            return set(p,"runs",.array([run]))
        }
        try mutateArtifact(&f) { a in set(a,"proofBindings",.array(a["proofBindings"]!.items.filter {
            $0["role"]?.text != "identity" && !($0["role"]?.text == "mapping" && $0["scope"]?["occurrence"]?.text == u(101).uuidString.lowercased())
        })) }
        #expect(try diagnostics(f,rejected:true) == [D(issue:.snapshotConflict,locator:"A0")] + (unavailable ? [D(issue:.correspondenceUnavailable,locator:"A0")]:[]))
    }
    @Test(arguments:[false,true]) func s25RepresentationAndOrderPreserveDiagnostics(_ inlineArtifact: Bool) throws {
        var f = try registration()
        try mutateArtifact(&f) { a in
            var b = a["proofBindings"]!.items
            let index = b.firstIndex { $0["role"]?.text == "classification" }!
            b[index] = set(b[index],"scope",set(b[index]["scope"]!,"occurrence",uv(999)))
            return set(a,"proofBindings",.array(b))
        }
        let expected = try diagnostics(f,rejected:true)
        #expect(expected == [D(issue:.snapshotConflict,locator:"A0"),D(issue:.correspondenceUnavailable,locator:"A0")])
        if inlineArtifact {
            let artifact = try #require(f.catalog.first { $0.kind == "s9Artifact" && $0.id == "A0" })
            f.envelope = set(f.envelope,"s9Artifacts",.array([artifact.document.value]))
            f.catalog.removeAll { $0.kind == "s9Artifact" && $0.id == "A0" }
        }
        f.catalog.reverse()
        #expect(try diagnostics(f,rejected:true) == expected)
    }
    @Test(arguments:[false,true]) func s26SameRunMustCoverHeldReferenceInput(_ covered: Bool) throws {
        var f = try registration(nil); try append(&f); try snapshot("A0",into:&f); try select(&f,id:"S",artifact:"A0")
        let inputs = covered ? [nextInput,oldInput]:[oldInput]
        try supply(&f,prefix:"S",inputs:inputs)
        f.envelope = set(f.envelope,"evidence",.array(f.envelope["evidence"]!.items.map { set($0,"artifactIDs",list(["A0"])) }))
        try rebind(&f); try bind(&f,ids:["A0"])
        if covered { _ = try candidate(f) }
        else { #expect(try diagnostics(f,rejected:false) == [D(issue:.correspondenceUnavailable,locator:"record-S")]) }
    }
    private func registryKeyFixture(_ binding: String, operation: String, splitIdentity: Bool = false) throws -> Fixture {
        var f = try registration(nil)
        var t = f.envelope["request"]!["payload"]!["records"]!.items[0]
        let k = key("K"), other = key("other-U")
        let tKeys = binding == "coherent" ? [key(),k]:[key()]
        let uKey = binding == "conflict" ? k:other
        t = set(t,"referenceKeys",.array(tKeys))
        let u: V = .object(["recordID":s("register-U"),"allocationRequestID":s("allocate-U"),"tripID":s(secondTrip),
            "referenceKeys":.array([uKey]),"correspondenceEvidenceIDs":.array([])])
        try changeRequest(&f) { p in set(set(p,"records",.array([t,u])),"targetRegistryBytes",blob(try registry(2,
            entities:[entity(trip),entity(secondTrip)],references:tKeys.map { reference($0) } + [reference(uKey,tripID:secondTrip)]))) }
        try supply(&f)
        if operation == "register" {
            try snapshot("A0",into:&f,sourceKey:k,identityKey:splitIdentity ? key():nil)
            try changeRequest(&f) { p in set(p,"records",.array(p["records"]!.items.map { r in
                r["recordID"]?.text == "register-T" ? set(r,"snapshotArtifactID",s("A0")):r
            })) }
            try correspondence(&f,ids:["A0"],selected:"A0",prefix:"Q")
        } else {
            try append(&f)
            if operation == "revision" {
                try snapshot("old",into:&f); try select(&f,id:"old-selection",artifact:"old"); try append(&f)
            }
            try snapshot("A0",into:&f,prior:operation == "revision" ? "old":nil,viewNumber:22,sourceKey:k,identityKey:splitIdentity ? key():nil)
            try select(&f,id:"S",artifact:"A0",previous:operation == "revision" ? "old":nil)
        }
        return f
    }
    @Test(arguments:["register","initialSelection","revision"],["conflict","coherent","unbound"])
    func s27ArtifactKeyAgainstHeldAndPlannedBindings(_ operation: String, _ binding: String) throws {
        let f = try registryKeyFixture(binding,operation:operation), before = try C.make(.envelope,f.envelope).bytes
        if binding == "conflict" {
            #expect(try diagnostics(f,rejected:true) == [D(issue:.referenceConflict,locator:operation == "register" ? "register-T":"record-S")])
        } else {
            let c = try candidate(f)
            #expect(c.selections[0].artifactID == "A0")
            #expect(c.registryBytes == raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        }
        #expect(try C.make(.envelope,f.envelope).bytes == before)
    }
    @Test(arguments:[false,true]) func s28ConflictingSelectionCannotReplay(_ conflict: Bool) throws {
        var f = try registryKeyFixture(conflict ? "conflict":"coherent",operation:"initialSelection")
        try append(&f)
        let history = try C.make(.history,f.envelope["history"]!).bytes
        if conflict { #expect(try diagnostics(f,rejected:true) == [D(issue:.referenceConflict,locator:"record-S")]) }
        else { #expect(try candidate(f,replay:true).historyBytes == history) }
        #expect(try C.make(.history,f.envelope["history"]!).bytes == history)
    }
    @Test(arguments:["conflict","unbound"]) func s29MissingCorrespondenceDoesNotEraseKnownBinding(_ binding: String) throws {
        var f = try registryKeyFixture(binding,operation:"initialSelection")
        try changeRequest(&f) { p in set(p,"records",.array(p["records"]!.items.map { set($0,"correspondenceEvidenceIDs",.array([])) })) }
        let ds = try diagnostics(f,rejected:binding == "conflict")
        #expect(ds == (binding == "conflict" ? [D(issue:.referenceConflict,locator:"record-S")]:[]) + [D(issue:.correspondenceUnavailable,locator:"record-S")])
    }
    private func negativeWithBinding(_ name: String, control: String, missing: Bool, reverse: Bool) throws -> Fixture {
        var f = try registration()
        let a = try #require(f.catalog.first { $0.id == "A0" && $0.kind == "s9Artifact" }).document.value
        let e = try #require(f.catalog.first { $0.id == "AE-A0" }).document.value
        let view = SyntheticRegistrationSchema.components.contains(name)
        let field = view ? "viewBindings":"proofBindings"
        let selected = try #require(a[field]!.items.first { $0[view ? "component":"role"]?.text == name })
        if missing {
            try mutateArtifact(&f) { a in set(a,field,.array(a[field]!.items.filter { !((try? same($0,selected)) ?? false) })) }
        }
        var negative = set(set(e,"evidenceID",s("narrow-negative")),"disposition",s(control == "unresolved" ? "unresolved":"contradicts"))
        if view {
            let claim = set(set(selected,"evidenceID",nil),"inputSHA256s",list([nextInput]))
            negative = set(set(negative,"applicability",.array([])),"viewApplicability",.array([claim]))
        } else {
            let claim = set(set(selected,"proofUUID",nil),"evidenceID",nil)
            negative = set(set(negative,"viewApplicability",.array([])),"applicability",.array([claim]))
        }
        if control == "unrelated" { negative = set(negative,"view",set(e["view"]!,"mappingRevision",uv(999))) }
        let entry = Entry(kind:"evidence",id:"narrow-negative",document:try C.make(.evidence,negative))
        f.catalog.append(entry)
        if control != "unapproved" {
            try changeRequest(&f) { p in set(set(p,"evidenceIDs",.array(p["evidenceIDs"]!.items + [s(entry.id)])),
                "dependencyDigests",.array(p["dependencyDigests"]!.items + [binding(entry)])) }
        }
        if reverse { f.catalog.reverse() }
        return f
    }
    @Test(arguments:["interval","identity","continuity","origin","destination","classification","mapping","movement"],
          ["negative","unrelated","unapproved","unresolved"])
    func s30EveryMissingProofBindingRetainsIndependentContradictions(_ role: String, _ control: String) throws {
        for reverse in [false,true] {
            let f = try negativeWithBinding(role,control:control,missing:true,reverse:reverse)
            #expect(try diagnostics(f,rejected:control == "negative") ==
                (control == "negative" ? [D(issue:.snapshotConflict,locator:"A0")]:[]) + [D(issue:.correspondenceUnavailable,locator:"A0")])
        }
    }
    @Test(arguments:["sourceRevision","mappingRevision","profileRevision","reviewRevision"],
          ["negative","unrelated","unapproved","unresolved"])
    func s31EveryMissingViewBindingRetainsIndependentContradictions(_ component: String, _ control: String) throws {
        for reverse in [false,true] {
            let f = try negativeWithBinding(component,control:control,missing:true,reverse:reverse)
            #expect(try diagnostics(f,rejected:control == "negative") ==
                (control == "negative" ? [D(issue:.snapshotConflict,locator:"A0")]:[]) + [D(issue:.scopeUnavailable,locator:"A0")])
        }
    }
    @Test(arguments:["interval","identity","continuity","origin","destination","classification","mapping","movement",
        "sourceRevision","mappingRevision","profileRevision","reviewRevision"],[false,true])
    func s32CompleteBindingsKeepNegativeAndUnapprovedControls(_ name: String, _ approved: Bool) throws {
        for reverse in [false,true] {
            let f = try negativeWithBinding(name,control:approved ? "negative":"unapproved",missing:false,reverse:reverse)
            if approved { #expect(try diagnostics(f,rejected:true) == [D(issue:.snapshotConflict,locator:"A0")]) }
            else { _ = try candidate(f) }
        }
    }
    @Test(arguments:[false,true]) func s33LaterAttachmentCannotContradictRetainedSelection(_ conflict: Bool) throws {
        var f = try registryKeyFixture("unbound",operation:"initialSelection"); try append(&f)
        let target = conflict ? secondTrip:trip, current = try decode(f.current)
        let record: V = .object(["recordID":s("attach-K"),"tripID":s(target),"key":key("K"),"mode":s("newKey"),"correspondenceEvidenceIDs":.array([])])
        try request(&f,id:"attach",operation:"attach",records:[record],target:registry(4,entities:current["entities"]!.items,
            references:current["references"]!.items + [reference(key("K"),tripID:target,authority:"review-attach")]))
        try supply(&f,prefix:"attach")
        if conflict { #expect(try diagnostics(f,rejected:true) == [D(issue:.referenceConflict,locator:"attach")]) }
        else { _ = try candidate(f) }
    }
    @Test(arguments:["register","initialSelection","revision"])
    func s34OtherProofRolesCannotHideKeyConflictBehindCoherentIdentity(_ operation: String) throws {
        let f = try registryKeyFixture("conflict",operation:operation,splitIdentity:true)
        #expect(try diagnostics(f,rejected:true) == [D(issue:.referenceConflict,locator:operation == "register" ? "register-T":"record-S")])
    }
    @Test(arguments:["conflict","coherent","differentInput","differentSource","missingConflict","missingCoherent","missingHistorical"],[false,true])
    func s35HistoricalSourceClaimsSurviveRevision(_ mode: String, _ replay: Bool) throws {
        var f = try registryKeyFixture("unbound",operation:"initialSelection")
        if mode == "missingHistorical" {
            // Missing affirmative applicability is uncertainty, never a K/T assertion.
            let i = try #require(f.catalog.firstIndex { $0.id == "AE-A0" })
            let e = f.catalog[i]
            f.catalog[i] = Entry(kind:e.kind,id:e.id,document:try C.make(.evidence,set(e.document.value,"applicability",.array([]))))
            let replacement = binding(f.catalog[i])
            try mutateArtifact(&f) { a in set(a,"dependencyDigests",.array(a["dependencyDigests"]!.items.map {
                $0["kind"]?.text == "evidence" && $0["id"]?.text == "AE-A0" ? replacement:$0
            })) }
            #expect(try diagnostics(f,rejected:false) == [D(issue:.correspondenceUnavailable,locator:"A0")])
        } else { _ = try candidate(f) }
        try append(&f)
        // A0 claims unregistered K/T. A1 changes only mapping revision and uses J instead.
        try snapshot("A1",into:&f,prior:"A0",viewNumber:23)
        try select(&f,id:"revision",artifact:"A1",previous:"A0")
        let artifactViews = try ["A0","A1"].map { id in
            let a = try #require(f.catalog.first { $0.kind == "s9Artifact" && $0.id == id })
            return try C.read(.s9Packet,raw(a.document.value["packetBytes"]!)).value["view"]!
        }
        for field in ["sourceRevision","profileRevision","reviewRevision"] {
            #expect(try same(artifactViews[0][field],artifactViews[1][field]))
        }
        #expect(try !same(artifactViews[0]["mappingRevision"],artifactViews[1]["mappingRevision"]))
        if mode != "missingHistorical" {
            let revised = try candidate(f)
            #expect(revised.selections[0].artifactID == "A1")
        }
        try append(&f)
        let coherent = mode == "coherent" || mode == "missingCoherent"
        let target = coherent ? trip:secondTrip, current = try decode(f.current)
        let input = mode == "differentInput" ? String(repeating:"c",count:64):nextInput
        let k = mode == "differentSource" ? set(key("K"),"sourceID",s("other-source")):key("K")
        let record: V = .object(["recordID":s("attach-K"),"tripID":s(target),"key":k,"mode":s("newKey"),"correspondenceEvidenceIDs":.array([])])
        try request(&f,id:"attach",operation:"attach",records:[record],target:registry(5,entities:current["entities"]!.items,
            references:current["references"]!.items + [reference(k,tripID:target,input:input,authority:"review-attach")]))
        try supply(&f,prefix:"attach",inputs:[input])
        if mode == "differentSource" { try mutateProfile(&f,field:"sourceID",value:s("other-source")) }
        if mode == "missingConflict" || mode == "missingCoherent" {
            try changeRequest(&f) { p in set(p,"records",.array(p["records"]!.items.map { set($0,"correspondenceEvidenceIDs",.array([])) })) }
        }
        if replay { try append(&f) }
        let before = try C.make(.envelope,f.envelope).bytes, history = try C.make(.history,f.envelope["history"]!).bytes
        for reversed in [false,true] {
            var ordered = f
            if reversed { ordered.catalog.reverse() }
            if mode == "missingHistorical" {
                #expect(try diagnostics(ordered,rejected:false) == [D(issue:.correspondenceUnavailable,locator:"A0")])
            } else if mode == "conflict" || mode.hasPrefix("missing") {
                let conflict = mode != "missingCoherent"
                #expect(try diagnostics(ordered,rejected:conflict) ==
                    (conflict ? [D(issue:.referenceConflict,locator:"attach")]:[]) +
                    (mode.hasPrefix("missing") ? [D(issue:.correspondenceUnavailable,locator:"attach-K")]:[]))
            } else {
                let c = try candidate(ordered,replay:replay)
                #expect(c.selections[0].artifactID == "A1")
                #expect(c.registryBytes == raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
            }
        }
        #expect(try C.make(.envelope,f.envelope).bytes == before)
        #expect(try C.make(.history,f.envelope["history"]!).bytes == history)
    }

}
#endif
