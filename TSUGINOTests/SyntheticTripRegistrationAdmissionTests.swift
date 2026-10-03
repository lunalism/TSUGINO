#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Invented C1 inputs only. No filesystem loader, ID allocator, or snapshot admission.
struct SyntheticTripRegistrationAdmissionTests {
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
        let claims = records.flatMap { $0["referenceKeys"]?.items ?? [$0["key"]! ] }
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
    private func converted(entities: [V] = []) throws -> Fixture {
        var f = try base(registry(0, entities: entities, references: [], schema: 2))
        try request(&f, id: "conversion", operation: "convertLegacy", records: [], target: registry(1, entities: entities, references: []))
        try append(&f)
        return f
    }
    private func completeS9Artifact() throws -> Entry {
        func uuid(_ n: Int) -> UUID { UUID(uuidString: String(format: "00000000-0000-0000-0000-%012x", n))! }
        let view = SyntheticTripReviewView(sourceRevision: uuid(1), mappingRevision: uuid(2),
            profileRevision: uuid(3), reviewRevision: uuid(4))
        // A complete wire packet, as in the slice-B controls; no C2 evidence admission is claimed.
        let run = SyntheticTripReviewRun(reference: uuid(5), view: view,
            positions: [.init(reference: uuid(6), order: 1, classification: .unknown),
                        .init(reference: uuid(7), order: 2, classification: .unknown)],
            first: uuid(6), last: uuid(7), intervalEvidence: nil,
            identity: .reviewed(TripID(trip)!, evidence: nil), continuityEvidence: nil,
            origin: .unknownExtent, destination: .unknownExtent, movements: [], prior: nil)
        let packet = try SyntheticTripRegistrationS9Codec.encode(.init(view: view, evidenceReferences: [], runs: [run]))
        let artifact = try C.make(.s9Artifact, .object(["schemaVersion": .integer(1), "artifactID": s("conversion-artifact"),
            "packetBytes": blob(packet.bytes), "packetSHA256": s(packet.sha256),
            "selectedRunReference": s(uuid(5).uuidString.lowercased()),
            "proofBindings": .array([]), "viewBindings": .array([]), "dependencyDigests": .array([])]))
        return Entry(kind: "s9Artifact", id: "conversion-artifact", document: artifact)
    }
    private func registrationRecord(_ id: String = "register-T", tripID: String? = nil, keys: [V]? = nil) -> V {
        .object(["recordID": s(id), "allocationRequestID": s("allocation-" + id), "tripID": s(tripID ?? trip),
            "referenceKeys": .array(keys ?? [key()]), "correspondenceEvidenceIDs": .array([])])
    }
    private func registration() throws -> Fixture {
        var f = try converted()
        try request(&f, id: "Q", operation: "register", records: [registrationRecord()],
                    target: registry(2, entities: [entity(trip)], references: [reference(key())]))
        try supply(&f)
        return f
    }
    private func attachment() throws -> Fixture {
        var f = try registration(); try append(&f)
        let newKey = key("invented-alias")
        let record: V = .object(["recordID": s("attach-T"), "tripID": s(trip), "key": newKey,
            "mode": s("newKey"), "correspondenceEvidenceIDs": .array([])])
        let current = try decode(f.current)
        try request(&f, id: "R", operation: "attach", records: [record], target: registry(3,
            entities: current["entities"]!.items, references: current["references"]!.items + [reference(newKey, authority: "review-R")]))
        try supply(&f, prefix: "R")
        return f
    }
    private func returning(twoReferences: Bool = false, retiredReference: Bool = false, retiredEntity: Bool = false) throws -> Fixture {
        let keys = twoReferences ? [key(), key("invented-second-key")] : [key()]
        let refs = keys.map { key in
            var ref = reference(key, input: oldInput, authority: "seed-authority", state: retiredReference ? "retired" : "absent")
            if retiredReference { ref = set(ref, "status", .object(["state": s("retired"), "review": s("seed-authority")])) }
            let name: V = .object(["language": s("ja"), "value": s("invented-old-name"), "source": ref["provenance"]!])
            return set(ref, "originalNames", .array([name]))
        }
        let seeds = try refs.enumerated().map { index, ref in
            let id = "seed-attachment-" + String(index)
            let document = try C.make(.seedRecord, .object(["recordID": s(id), "kind": s("attachment"),
                "stipulated": s("synthetic"), "reference": ref, "authorityID": s("seed-authority"), "dependencyDigests": .array([])]))
            return Entry(kind: "seedRecord", id: id, document: document)
        }
        var f = try base(registry(6, entities: [entity(trip, retired: retiredEntity)], references: refs), seeds: seeds)
        let records = refs.enumerated().map { index, _ -> V in
            .object(["recordID": s("return-" + String(index)), "tripID": s(trip), "key": keys[index],
                "mode": s("returning"), "previousRecordSHA256": s(seeds[index].document.sha256), "correspondenceEvidenceIDs": .array([])])
        }
        let next = zip(refs, keys).map { prior, key in
            set(set(reference(key, authority: "seed-authority"), "firstSeenInputSHA256", prior["firstSeenInputSHA256"]!), "originalNames", prior["originalNames"]!)
        }
        try request(&f, id: "Q", operation: "attach", records: records, target: registry(7, entities: [entity(trip, retired: retiredEntity)], references: next))
        try supply(&f, inputs: [oldInput, nextInput])
        return f
    }
    private func run(_ f: Fixture) throws -> SyntheticRegistrationC1Result {
        A.validateIdentityOnly(envelopeBytes: try C.make(.envelope, f.envelope).bytes,
            currentRegistryBytes: f.current, currentCheckpointBytes: try C.make(.checkpoint, f.checkpoint).bytes, catalog: f.catalog)
    }
    private func assertMechanicallyChecked(_ f: Fixture, replay: Bool, conversionOnly: Bool = false) throws {
        let envelope = try C.make(.envelope, f.envelope)
        let closure = SyntheticTripRegistrationClosure.validate(roots: [envelope], catalog: f.catalog)
        guard case .completeRepresentation = closure else { Issue.record("Expected complete A representation, received \(closure)"); return }
        let history = SyntheticTripRegistrationHistory.validate(envelopeBytes: envelope.bytes,
            currentRegistryBytes: f.current, currentCheckpointBytes: try C.make(.checkpoint, f.checkpoint).bytes, catalog: f.catalog)
        guard case .checked(let report) = history else { Issue.record("Expected mechanically checked B history, received \(history)"); return }
        #expect(report.unchangedReplay == replay)
        #expect(report.conversionOnly == conversionOnly)
        #expect(report.businessAdmissionRequired == (conversionOnly ? [] : ["Q"]))
    }
    private func candidate(_ result: SyntheticRegistrationC1Result, replay: Bool = false) -> SyntheticRegistrationC1Candidate? {
        switch result {
        case .candidate(let value): #expect(!replay); return value
        case .unchangedReplay(let value): #expect(replay); return value
        default: Issue.record("Expected C1 candidate, received \(result)"); return nil
        }
    }
    private func expect(_ result: SyntheticRegistrationC1Result, _ pairs: [(SyntheticRegistrationIssue, String)], held: Bool = false) {
        let expected = pairs.map { D(issue: $0.0, locator: $0.1) }
        switch result {
        case .held(let diagnostics): #expect(held); #expect(diagnostics == expected)
        case .rejected(let diagnostics): #expect(!held); #expect(diagnostics == expected)
        default: Issue.record("Expected diagnostic-only result, received \(result)")
        }
    }
    private func assertCandidate(_ f: Fixture, _ candidate: SyntheticRegistrationC1Candidate) throws {
        let target = raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!)
        #expect(candidate.registryBytes == target)
        #expect(candidate.recordIDs == f.envelope["request"]!["payload"]!["records"]!.items.map { $0["recordID"]!.text! })
        let actualHistory = try decode(candidate.historyBytes), prior = f.envelope["history"]!["boundaries"]!.items
        let actualBoundaries = actualHistory["boundaries"]!.items
        #expect(actualBoundaries.count == prior.count + 1)
        #expect(try C.encoded(.array(Array(actualBoundaries.dropLast()))) == C.encoded(.array(prior)))
        #expect(actualHistory["format"]?.text == "tsugino.synthetic-trip-history")
        #expect(try same(actualHistory["schemaVersion"], .integer(1)))
        #expect(actualHistory["lineageID"]?.text == "invented-lineage")
        #expect(try same(actualHistory["baselineSHA256"], f.envelope["history"]!["baselineSHA256"]))
        let last = try #require(actualBoundaries.last)
        #expect(raw(last["previousRegistryBytes"]!) == f.current)
        #expect(raw(last["targetRegistryBytes"]!) == target)
        #expect(try C.encoded(last["request"]!) == C.encoded(f.envelope["request"]!))
        #expect(try C.encoded(last["approvals"]!) == C.encoded(f.envelope["approvals"]!))
        if let previous = prior.last { #expect(last["previousBoundarySHA256"]?.text == C.digest(try C.encoded(previous))) }
        else { #expect(last["previousBoundarySHA256"] == nil) }
        let entries = try inline(f)
        #expect(last["dependencies"]!.items.count == entries.count)
        for entry in entries {
            let retained = try #require(last["dependencies"]!.items.first { $0["kind"]?.text == entry.kind && $0["id"]?.text == entry.id })
            #expect(raw(retained["bytes"]!) == entry.document.bytes)
        }
        let actualCheckpoint = try decode(candidate.checkpointBytes), targetValue = try decode(target)
        let expectedCheckpoint: V = .object(["lineageID": s("invented-lineage"), "schemaVersion": .integer(4),
            "revision": targetValue["revision"]!, "registrySHA256": s(C.digest(target)), "historySHA256": s(C.digest(candidate.historyBytes))])
        #expect(try C.encoded(actualCheckpoint) == C.encoded(expectedCheckpoint))
        #expect(try C.read(.history, candidate.historyBytes).bytes == candidate.historyBytes)
        #expect(try C.read(.checkpoint, candidate.checkpointBytes).bytes == candidate.checkpointBytes)
    }

    @Test func c01IdentityOnlyRegistrationProducesExactAtomicCandidate() throws {
        let f = try registration(), original = try C.make(.envelope, f.envelope).bytes
        let result = try #require(candidate(run(f)))
        try assertCandidate(f, result)
        #expect(!result.stipulatedSeed)
        #expect(try C.make(.envelope, f.envelope).bytes == original)
        #expect(try decode(result.registryBytes)["entities"]!.items.count == 1)
        #expect(try decode(result.registryBytes)["references"]!.items.count == 1)
    }
    @Test func c02NewKeyAttachmentReusesActiveTripAndRetainsOldReference() throws {
        let f = try attachment(), result = try #require(candidate(run(f)))
        try assertCandidate(f, result)
        #expect(!result.stipulatedSeed)
        let before = try decode(f.current), after = try decode(result.registryBytes)
        #expect(try C.encoded(before["entities"]!) == C.encoded(after["entities"]!))
        #expect(try after["references"]!.items.contains { try same($0, before["references"]!.items[0]) })
    }
    @Test func c03ReturningReferencePreservesPermanentAttachment() throws {
        let f = try returning(), result = try #require(candidate(run(f)))
        try assertCandidate(f, result)
        #expect(result.stipulatedSeed)
        let previous = try decode(f.current)["references"]!.items[0], next = try decode(result.registryBytes)["references"]!.items[0]
        #expect(try same(next["attachedBy"], previous["attachedBy"]))
        #expect(try same(next["firstSeenInputSHA256"], previous["firstSeenInputSHA256"]))
        #expect(try same(next["originalNames"], previous["originalNames"]))
        #expect(next["provenance"]?["inputSHA256"]?.text == nextInput)
        #expect(next["status"]?["state"]?.text == "active")
    }
    @Test func c04RepeatedHistoricalAuthorityAcrossReferencesIsLegal() throws {
        let f = try returning(twoReferences: true), result = try #require(candidate(run(f)))
        try assertCandidate(f, result)
        #expect(try decode(result.registryBytes)["references"]!.items.map { $0["attachedBy"]!.text! } == ["seed-authority", "seed-authority"])
    }
    @Test(arguments: ["trp_bad", "stn_0000000000000001", "Trp_0000000000000001"])
    func c05RegistrationRequiresSuppliedTripKind(_ id: String) throws {
        var f = try registration()
        try changeRequest(&f) { set($0, "records", .array([set($0["records"]!.items[0], "tripID", s(id))])) }
        expect(try run(f), [(.historyConflict, "Q"), (.identityConflict, "register-T"), (.referenceConflict, "register-T"),
                            (.scopeUnavailable, "register-T"), (.correspondenceUnavailable, "register-T")])
    }
    @Test(arguments: ["trp_0000000000000099", "stn_0000000000000001"])
    func c06AttachmentRequiresExistingTrip(_ id: String) throws {
        var f = try attachment()
        try changeRequest(&f) { set($0, "records", .array([set($0["records"]!.items[0], "tripID", s(id))])) }
        expect(try run(f), [(.identityConflict, "attach-T"), (.referenceConflict, "attach-T"),
                            (.scopeUnavailable, "attach-T"), (.correspondenceUnavailable, "attach-T")])
    }
    @Test func c07ExistingKeyCannotBeDeclaredNew() throws {
        var f = try attachment()
        try changeRequest(&f) { set($0, "records", .array([set($0["records"]!.items[0], "key", key())])) }
        expect(try run(f), [(.historyConflict, "R"), (.referenceConflict, "attach-T"),
                            (.scopeUnavailable, "attach-T"), (.correspondenceUnavailable, "attach-T")])
    }
    @Test(arguments: [false, true]) func c08ReturnRequiresCompleteRetainedPredecessorDigest(_ rowOnly: Bool) throws {
        var f = try returning()
        let wrong = rowOnly ? C.digest(try C.encoded(decode(f.current)["references"]!.items[0])) : zero
        try changeRequest(&f) { set($0, "records", .array([set($0["records"]!.items[0], "previousRecordSHA256", s(wrong))])) }
        expect(try run(f), [(.historyConflict, "return-0")])
    }
    @Test(arguments: ["attachedBy", "firstSeenInputSHA256", "canonicalID", "originalNames"])
    func c09ReturnCannotReplacePermanentBinding(_ field: String) throws {
        var f = try returning()
        let payload = f.envelope["request"]!["payload"]!, target = try decode(raw(payload["targetRegistryBytes"]!))
        let replacement = field == "attachedBy" ? "review-Q" : field == "canonicalID" ? secondTrip : nextInput
        let changed = set(target, "references", .array([set(target["references"]!.items[0], field, field == "originalNames" ? .array([]) : s(replacement))]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        var findings: [(SyntheticRegistrationIssue, String)] = field == "originalNames" ? [] : [(.historyConflict, "Q")]
        if field == "canonicalID" { findings.append((.referenceConflict, "Q")) }
        findings.append((.referenceConflict, "return-0"))
        expect(try run(f), findings)
    }
    @Test(arguments: ["unique", "meaning"])
    func c10MissingPurposeSupportHolds(_ purpose: String) throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: purpose, field: "disposition", value: s("unresolved"))
        expect(try run(f), [(.scopeUnavailable, "register-T")], held: true)
    }
    @Test(arguments: ["unique", "meaning", "continuity", "correspondence"])
    func c11ApplicableContradictionRejects(_ purpose: String) throws {
        var f = try returning()
        try mutateEvidence(&f, purpose: purpose, field: "disposition", value: s("contradicts"))
        expect(try run(f), [(.referenceConflict, "return-0")])
    }
    @Test func c12MissingCorrespondenceHolds() throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: "correspondence", field: "disposition", value: s("unresolved"))
        expect(try run(f), [(.correspondenceUnavailable, "register-T")], held: true)
    }
    @Test(arguments: ["referenceKeys", "tripIDs", "recordIDs", "inputSHA256s"])
    func c13EmptyEvidenceScopeIsNotWildcard(_ field: String) throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: "correspondence", field: field, value: .array([]))
        expect(try run(f), [(.correspondenceUnavailable, "register-T")], held: true)
    }
    @Test(arguments: ["profileID", "profileVersion", "referenceKeys", "tripIDs", "recordIDs", "inputSHA256s"])
    func c14UnrelatedSupportCannotAuthorizeCorrespondence(_ field: String) throws {
        var f = try registration()
        let replacement: V
        switch field {
        case "profileID", "profileVersion": replacement = s("unrelated")
        case "referenceKeys": replacement = .array([key("unrelated")])
        case "tripIDs": replacement = list([secondTrip])
        case "recordIDs": replacement = list(["unrelated-record"])
        default: replacement = list([oldInput])
        }
        try mutateEvidence(&f, purpose: "correspondence", field: field, value: replacement)
        expect(try run(f), [(.correspondenceUnavailable, "register-T")], held: true)
    }
    @Test(arguments: ["sourceID", "applicableInputSHA256s", "uniquenessEvidenceIDs", "meaningEvidenceIDs"])
    func c15ApprovedProfileMustCoverSourceInputAndPurposes(_ field: String) throws {
        var f = try registration()
        try mutateProfile(&f, field: field, value: field == "sourceID" ? s("unrelated") : .array([]))
        expect(try run(f), [(.scopeUnavailable, "register-T")], held: true)
    }
    @Test(arguments: ["unique", "meaning", "correspondence"])
    func c16UnrelatedContradictionIsNotAnApplicableConflict(_ purpose: String) throws {
        var f = try registration()
        let extra = set(set(f.envelope["evidence"]!.items.first { $0["evidenceID"]!.text!.hasSuffix("-" + purpose) }!,
            "evidenceID", s("E-extra")), "disposition", s("contradicts"))
        f.envelope = set(f.envelope, "evidence", .array(f.envelope["evidence"]!.items + [set(extra, "recordIDs", list(["unrelated-record"]))]))
        try rebind(&f)
        #expect(candidate(try run(f)) != nil)
    }
    @Test(arguments: ["old", "next", "both"])
    func c17ReturnContinuityCoversBothInputHashes(_ missing: String) throws {
        var f = try returning()
        let hashes = missing == "old" ? [nextInput] : missing == "next" ? [oldInput] : []
        try mutateEvidence(&f, purpose: "continuity", field: "inputSHA256s", value: list(hashes))
        expect(try run(f), [(.scopeUnavailable, "return-0")], held: true)
    }
    @Test func c18ContradictionSurvivesAnIndependentEvidenceGap() throws {
        var f = try returning()
        try mutateEvidence(&f, purpose: "continuity", field: "disposition", value: s("unresolved"))
        try mutateEvidence(&f, purpose: "correspondence", field: "disposition", value: s("contradicts"))
        expect(try run(f), [(.referenceConflict, "return-0"), (.scopeUnavailable, "return-0")])
    }
    @Test(arguments: ["trp_0000000000000002", "stn_0000000000000002"])
    func c19UnexplainedTripOrNonTripTargetDeltaRejectsAtomically(_ extraID: String) throws {
        var f = try registration()
        let target = try decode(raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        let changed = set(target, "entities", .array(target["entities"]!.items + [entity(extraID)]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        expect(try run(f), [(.historyConflict, "Q")])
    }
    @Test func c20AnUnclaimedReferenceCannotEscapeAccounting() throws {
        var f = try registration()
        let target = try decode(raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        let changed = set(target, "references", .array(target["references"]!.items + [reference(key("unclaimed"))]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        expect(try run(f), [(.historyConflict, "Q")])
    }
    @Test(arguments: [false, true])
    func c21RecordOrderAndOneBatchAuthorityArePreserved(_ reverse: Bool) throws {
        var f = try converted()
        let records = [registrationRecord("register-Z", keys: [key("z")]), registrationRecord("register-A", tripID: secondTrip, keys: [key("a")])]
        try request(&f, id: "Q", operation: "register", records: reverse ? Array(records.reversed()) : records,
            target: registry(2, entities: [entity(trip), entity(secondTrip)], references: [reference(key("z")), reference(key("a"), tripID: secondTrip)]))
        try supply(&f)
        let result = try #require(candidate(run(f)))
        try assertCandidate(f, result)
        #expect(result.recordIDs == (reverse ? ["register-A", "register-Z"] : ["register-Z", "register-A"]))
    }
    @Test func c22OneUnsupportedRecordPreventsWholeBatchCandidate() throws {
        var f = try converted()
        try request(&f, id: "Q", operation: "register", records: [registrationRecord("register-A"), registrationRecord("register-B", tripID: secondTrip, keys: [key("second")])],
            target: registry(2, entities: [entity(trip), entity(secondTrip)], references: [reference(key()), reference(key("second"), tripID: secondTrip)]))
        try supply(&f)
        try mutateEvidence(&f, purpose: "correspondence", field: "recordIDs", value: list(["register-A"]))
        expect(try run(f), [(.correspondenceUnavailable, "register-B")], held: true)
    }
    @Test func c23CurrentTargetReplayReturnsUnchangedExactBytes() throws {
        var f = try registration(); try append(&f)
        let result = try #require(candidate(run(f), replay: true))
        #expect(result.registryBytes == f.current)
        #expect(result.historyBytes == (try C.encoded(f.envelope["history"]!)))
        #expect(result.checkpointBytes == (try C.make(.checkpoint, f.checkpoint).bytes))
        #expect(result.recordIDs == ["register-T"])
    }
    @Test func c24ReplayCannotBypassRetainedCorrespondenceAdmission() throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: "correspondence", field: "disposition", value: s("contradicts"))
        try append(&f)
        expect(try run(f), [(.referenceConflict, "register-T")])
    }
    @Test func c25ReplayCannotBypassRetainedScopeUncertainty() throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: "unique", field: "disposition", value: s("unresolved")); try append(&f)
        expect(try run(f), [(.scopeUnavailable, "register-T")], held: true)
    }
    @Test func c26HistoricalInvalidBoundaryBlocksLaterValidAttachment() throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: "correspondence", field: "disposition", value: s("contradicts")); try append(&f)
        let extraKey = key("later-key"), before = try decode(f.current)
        let record: V = .object(["recordID": s("attach-later"), "tripID": s(trip), "key": extraKey, "mode": s("newKey"), "correspondenceEvidenceIDs": .array([])])
        try request(&f, id: "R", operation: "attach", records: [record], target: registry(3, entities: before["entities"]!.items,
            references: before["references"]!.items + [reference(extraKey, authority: "review-R")]))
        try supply(&f, prefix: "R")
        expect(try run(f), [(.referenceConflict, "register-T")])
    }
    @Test func c27LaterBoundaryMakesOldReplayStale() throws {
        var f = try attachment()
        let history = f.envelope["history"]!, old = history["boundaries"]!.items.last!
        try append(&f)
        f.envelope = set(set(f.envelope, "request", old["request"]!), "approvals", old["approvals"]!)
        expect(try run(f), [(.staleCheckpoint, "Q")])
    }
    @Test func c28PureConversionIsExplicitlyOutsideC1() throws {
        var f = try base(registry(0, entities: [], references: [], schema: 2))
        try request(&f, id: "conversion", operation: "convertLegacy", records: [], target: registry(1, entities: [], references: []))
        guard case .outsideC1(let limits, let diagnostics) = try run(f) else { Issue.record("Expected conversion-only scope limit"); return }
        #expect(limits.map(\.requestID) == ["conversion"])
        #expect(limits.map(\.reason) == [.conversionOnly])
        #expect(diagnostics.isEmpty)
    }
    @Test(arguments: [false, true])
    func c29SnapshotRegistrationIsOutsideC1EvenOnReplay(_ replay: Bool) throws {
        var f = try registration()
        try changeRequest(&f) { payload in
            let record = set(payload["records"]!.items[0], "snapshotArtifactID", s("missing-snapshot"))
            let dep: V = .object(["kind": s("s9Artifact"), "id": s("missing-snapshot"), "sha256": s(zero)])
            return set(set(set(payload, "records", .array([record])), "s9ArtifactIDs", list(["missing-snapshot"])),
                       "dependencyDigests", .array(payload["dependencyDigests"]!.items + [dep]))
        }
        // Retention here keeps an explicitly missing C2 dependency missing; no invented artifact.
        if replay {
            let payload = f.envelope["request"]!["payload"]!, history = f.envelope["history"]!, prior = history["boundaries"]!.items
            let dependencies = try inline(f).map { V.object(["kind": s($0.kind), "id": s($0.id), "bytes": blob($0.document.bytes)]) }
            let boundary: V = .object(["previousRegistryBytes": blob(f.current), "targetRegistryBytes": payload["targetRegistryBytes"]!,
                "request": f.envelope["request"]!, "approvals": f.envelope["approvals"]!, "dependencies": .array(dependencies),
                "previousBoundarySHA256": s(C.digest(try C.encoded(prior.last!)))])
            let retained = try C.make(.history, set(history, "boundaries", .array(prior + [boundary]))).value
            f.current = raw(payload["targetRegistryBytes"]!); f.envelope = set(f.envelope, "history", retained)
            f.checkpoint = try checkpoint(f.current, retained)
        }
        guard case .outsideC1(let limits, let diagnostics) = try run(f) else { Issue.record("C2 must remain outside C1"); return }
        #expect(limits.map(\.requestID) == ["Q"])
        #expect(limits.map(\.reason) == [.snapshotAdmission])
        #expect(diagnostics.contains(D(issue: .snapshotUnavailable, locator: "missing-snapshot")))
        #expect(!diagnostics.contains { $0.issue == .referenceConflict || $0.issue == .identityConflict })
    }
    @Test(arguments: ["initialSelection", "revision"])
    func c30SnapshotSelectionAndRevisionRemainOutsideC1(_ mode: String) throws {
        var f = try converted()
        var record: V = .object(["recordID": s("snapshot-record"), "tripID": s(trip), "mode": s(mode),
            "nextArtifactID": s("next-snapshot"), "correspondenceEvidenceIDs": .array([])])
        if mode == "revision" { record = set(record, "previousArtifactID", s("previous-snapshot")) }
        try request(&f, id: "Q", operation: "reviseSnapshot", records: [record], target: registry(2, entities: [], references: []))
        let ids = mode == "revision" ? ["next-snapshot", "previous-snapshot"] : ["next-snapshot"]
        try changeRequest(&f) { payload in
            set(set(payload, "s9ArtifactIDs", list(ids)), "dependencyDigests", .array(ids.map {
                .object(["kind": s("s9Artifact"), "id": s($0), "sha256": s(zero)])
            }))
        }
        guard case .outsideC1(let limits, _) = try run(f) else { Issue.record("Expected snapshot scope limit"); return }
        #expect(limits.map(\.requestID) == ["Q"]); #expect(limits.map(\.reason) == [.snapshotAdmission])
    }
    @Test func c31CanonicallyEquivalentUnicodeKeysRemainDistinct() throws {
        var f = try converted()
        let decomposed = key("e\u{301}"), composed = key("é")
        try request(&f, id: "Q", operation: "register", records: [registrationRecord(keys: [decomposed, composed])],
            target: registry(2, entities: [entity(trip)], references: [reference(decomposed), reference(composed)]))
        try supply(&f)
        let result = try #require(candidate(run(f)))
        let scalars = try decode(result.registryBytes)["references"]!.items.map { $0["value"]!.text!.unicodeScalars.map(\.value) }
        #expect(scalars.contains([101, 769])); #expect(scalars.contains([233])); #expect(scalars.count == 2)
    }
    @Test func c32EvidenceRoleIsDescriptiveAndApprovedPurposeSlotsAreUsed() throws {
        var f = try registration()
        f.envelope = set(f.envelope, "evidence", .array(f.envelope["evidence"]!.items.map { set($0, "role", s("invented-source-assertion")) }))
        try rebind(&f)
        #expect(candidate(try run(f)) != nil)
    }
    @Test func c33CatalogEvidenceAndInlineEvidenceProduceIdenticalCandidate() throws {
        let f = try registration(), original = try #require(candidate(run(f)))
        var catalogOnly = f
        catalogOnly.catalog = try inline(f)
        catalogOnly.envelope = set(set(catalogOnly.envelope, "profiles", .array([])), "evidence", .array([]))
        let other = try #require(candidate(run(catalogOnly)))
        #expect(other.registryBytes == original.registryBytes)
        #expect(other.historyBytes == original.historyBytes)
        #expect(other.checkpointBytes == original.checkpointBytes)
    }
    @Test(arguments: ["unique", "meaning", "continuity", "correspondence", "uncited"])
    func c34EveryNamedContradictionIsCheckedWithoutExpandingEvidencePurpose(_ purpose: String) throws {
        var f = try registration()
        let extra = set(set(f.envelope["evidence"]!.items[0], "evidenceID", s("E-extra-negative")), "disposition", s("contradicts"))
        f.envelope = set(f.envelope, "evidence", .array(f.envelope["evidence"]!.items + [extra]))
        if purpose == "correspondence" {
            try changeRequest(&f) { payload in
                let record = payload["records"]!.items[0]
                return set(payload, "records", .array([set(record, "correspondenceEvidenceIDs", .array(record["correspondenceEvidenceIDs"]!.items + [s("E-extra-negative")]))]))
            }
        } else if purpose != "uncited" {
            let field = purpose == "unique" ? "uniquenessEvidenceIDs" : purpose + "EvidenceIDs"
            let values = f.envelope["profiles"]!.items[0]["payload"]!["payload"]![field]!.items
            try mutateProfile(&f, field: field, value: .array(values + [s("E-extra-negative")]))
        }
        try rebind(&f)
        if purpose == "uncited" { #expect(candidate(try run(f)) != nil) }
        else { expect(try run(f), [(.referenceConflict, "register-T")]) }
    }
    @Test func c35ScopeAndCorrespondenceCannotBeBorrowedAcrossProfiles() throws {
        var f = try registration()
        let originals = f.envelope["evidence"]!.items
        let extraEvidence = originals.map { set(set($0, "evidenceID", s($0["evidenceID"]!.text! + "-second")), "profileID", s("P-second")) }
        let old = f.envelope["profiles"]!.items[0]["payload"]!["payload"]!
        var second = set(set(old, "profileID", s("P-second")), "uniquenessEvidenceIDs", .array([]))
        for field in ["meaningEvidenceIDs", "continuityEvidenceIDs"] {
            second = set(second, field, list(old[field]!.items.map { $0.text! + "-second" }))
        }
        let profile = try approved(wrapper("profile", "P-second", second), "review-P-second")
        let altered = originals.map { $0["evidenceID"]!.text!.hasSuffix("-correspondence") ? set($0, "recordIDs", list(["unrelated"])) : $0 }
        f.envelope = set(set(f.envelope, "profiles", .array(f.envelope["profiles"]!.items + [profile])), "evidence", .array(altered + extraEvidence))
        try changeRequest(&f) { payload in
            let record = payload["records"]!.items[0]
            return set(payload, "records", .array([set(record, "correspondenceEvidenceIDs", list(["E-Q-correspondence", "E-Q-correspondence-second"]))]))
        }
        try rebind(&f)
        expect(try run(f), [(.scopeUnavailable, "register-T"), (.correspondenceUnavailable, "register-T")], held: true)
    }
    @Test(arguments: ["unique", "correspondence", "profile"])
    func c36UnavailableDependencyBytesRemainMissingNotContradictory(_ missing: String) throws {
        var f = try registration()
        if missing == "profile" { f.envelope = set(f.envelope, "profiles", .array([])) }
        else {
            f.envelope = set(f.envelope, "evidence", .array(f.envelope["evidence"]!.items.filter { !$0["evidenceID"]!.text!.hasSuffix("-" + missing) }))
        }
        // Keep the approved request and its expected digests unchanged.
        let findings: [(SyntheticRegistrationIssue, String)]
        switch missing {
        case "unique": findings = [(.scopeUnavailable, "register-T"), (.correspondenceUnavailable, "E-Q-unique")]
        case "correspondence": findings = [(.correspondenceUnavailable, "E-Q-correspondence"), (.correspondenceUnavailable, "register-T")]
        default: findings = [(.scopeUnavailable, "P-Q"), (.scopeUnavailable, "register-T")]
        }
        expect(try run(f), findings, held: true)
    }
    @Test(arguments: [false, true])
    func c37DuplicateEntityAndReferenceClaimsRejectEveryClaimant(_ sameEntity: Bool) throws {
        var f = try converted()
        let secondID = sameEntity ? trip : secondTrip
        let secondKey = sameEntity ? key("second-key") : key()
        let records = [registrationRecord("record-A"), registrationRecord("record-B", tripID: secondID, keys: [secondKey])]
        let entities = sameEntity ? [entity(trip)] : [entity(trip), entity(secondTrip)]
        let references = sameEntity ? [reference(key()), reference(secondKey)] : [reference(key())]
        try request(&f, id: "Q", operation: "register", records: records, target: registry(2, entities: entities, references: references))
        try supply(&f)
        if sameEntity { expect(try run(f), [(.identityConflict, "record-A"), (.identityConflict, "record-B")]) }
        else { expect(try run(f), [(.referenceConflict, "record-A"), (.referenceConflict, "record-B")]) }
    }
    @Test(arguments: [false, true])
    func c38HistoricalOtherKindBodyIsNeverAvailableForTripRegistration(_ retired: Bool) throws {
        let station = retired ? set(entity("stn_0000000000000001", retired: true),
            "successors", list(["stn_0000000000000002"])) : entity("stn_0000000000000001")
        let entities = retired ? [station, entity("stn_0000000000000002")] : [station]
        // The body is already retired in the original-valid schema-2 baseline and stays so
        // through lossless conversion. Reserving only active historical bodies would miss it.
        var f = try converted(entities: entities)
        _ = try MappingRegistry.decoded(from: raw(f.envelope["baseline"]!["payload"]!["payload"]!["registryBytes"]!))
        try assertMechanicallyChecked(f, replay: true, conversionOnly: true)
        #expect(try C.encoded(decode(f.current)["entities"]!) == C.encoded(.array(entities)))
        try request(&f, id: "Q", operation: "register", records: [registrationRecord()],
            target: registry(2, entities: entities + [entity(trip)], references: [reference(key())]))
        try supply(&f)
        let mechanical = SyntheticTripRegistrationHistory.validate(envelopeBytes: try C.make(.envelope, f.envelope).bytes,
            currentRegistryBytes: f.current, currentCheckpointBytes: try C.make(.checkpoint, f.checkpoint).bytes, catalog: f.catalog)
        guard case .rejected(let diagnostics) = mechanical else { Issue.record("Expected B body conflict"); return }
        #expect(diagnostics == [D(issue: .identityConflict, locator: "Q")])
        expect(try run(f), [(.identityConflict, "Q"), (.identityConflict, "register-T")])
    }
    @Test func c39NewReferenceRequiresCurrentAttachingApproval() throws {
        var f = try registration()
        let target = try decode(raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        let changed = set(target, "references", .array([set(target["references"]!.items[0], "attachedBy", s("unrelated-authority"))]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        expect(try run(f), [(.referenceConflict, "register-T")])
    }
    @Test(arguments: ["profile", "correspondence"])
    func c40MechanicalUncertaintyCannotHideIndependentBusinessConflict(_ missing: String) throws {
        var f = try registration()
        let target = try decode(raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        let changed = set(target, "references", .array([set(target["references"]!.items[0], "attachedBy", s("wrong-authority"))]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        if missing == "profile" { f.envelope = set(f.envelope, "profiles", .array([])) }
        else { f.envelope = set(f.envelope, "evidence", .array(f.envelope["evidence"]!.items.filter { !$0["evidenceID"]!.text!.hasSuffix("-correspondence") })) }
        let mechanical = SyntheticTripRegistrationHistory.validate(envelopeBytes: try C.make(.envelope, f.envelope).bytes,
            currentRegistryBytes: f.current, currentCheckpointBytes: try C.make(.checkpoint, f.checkpoint).bytes, catalog: f.catalog)
        guard case .held(let diagnostics) = mechanical else { Issue.record("Control must be mechanically held"); return }
        let absent = D(issue: missing == "profile" ? .scopeUnavailable : .correspondenceUnavailable,
                       locator: missing == "profile" ? "P-Q" : "E-Q-correspondence")
        #expect(diagnostics == [absent])
        if missing == "profile" {
            expect(try run(f), [(.referenceConflict, "register-T"), (.scopeUnavailable, "P-Q"), (.scopeUnavailable, "register-T")])
        } else {
            expect(try run(f), [(.referenceConflict, "register-T"), (.correspondenceUnavailable, "E-Q-correspondence"), (.correspondenceUnavailable, "register-T")])
        }
    }
    @Test func c41HistoricallyHeldTripCannotBeRegisteredAgainWithoutDuplicateTargetEntity() throws {
        var f = try registration(); try append(&f)
        let newKey = key("second-registration-key"), current = try decode(f.current)
        try request(&f, id: "R", operation: "register", records: [registrationRecord("reregister-T", keys: [newKey])],
            target: registry(3, entities: current["entities"]!.items,
                references: current["references"]!.items + [reference(newKey, authority: "review-R")]))
        try supply(&f, prefix: "R")
        let mechanical = SyntheticTripRegistrationHistory.validate(envelopeBytes: try C.make(.envelope, f.envelope).bytes,
            currentRegistryBytes: f.current, currentCheckpointBytes: try C.make(.checkpoint, f.checkpoint).bytes, catalog: f.catalog)
        guard case .checked = mechanical else { Issue.record("Control must pass mechanical B checks"); return }
        expect(try run(f), [(.identityConflict, "reregister-T")])
    }
    @Test(arguments: [false, true])
    func c42RetiredReferenceOrTripCannotReturn(_ retiredReference: Bool) throws {
        let f = try returning(retiredReference: retiredReference, retiredEntity: !retiredReference)
        if retiredReference { expect(try run(f), [(.historyConflict, "Q"), (.referenceConflict, "return-0")]) }
        else { expect(try run(f), [(.identityConflict, "return-0"), (.referenceConflict, "Q")]) }
    }
    @Test func c43RegistrationCannotCreateRetiredTrip() throws {
        var f = try registration()
        let target = try decode(raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        let changed = set(target, "entities", .array([entity(trip, retired: true)]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        expect(try run(f), [(.referenceConflict, "Q"), (.blockedOperation, "register-T")])
    }
    @Test(arguments: [false, true], ["unique", "meaning", "continuity", "correspondence"])
    func c44UnapprovedProfileCannotMakeEvidenceAConclusiveConflict(_ missing: Bool, _ purpose: String) throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: purpose, field: "disposition", value: s("contradicts"))
        try alterProfileApproval(&f, missing: missing)
        expect(try run(f), [(missing ? .approvalMissing : .approvalConflict, "P-Q")], held: missing)
    }
    @Test(arguments: [false, true], ["unique", "meaning", "continuity", "correspondence"])
    func c45RequestApprovalGatesOnlyItsOwnCorrespondenceAssertion(_ missing: Bool, _ purpose: String) throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: purpose, field: "disposition", value: s("contradicts"))
        let approvals = missing ? [] : [set(f.envelope["approvals"]!.items[0], "reviewer", s("unrelated-owner"))]
        f.envelope = set(f.envelope, "approvals", .array(approvals))
        if purpose == "correspondence" {
            expect(try run(f), [(missing ? .approvalMissing : .approvalConflict, "Q")], held: missing)
        } else if missing {
            expect(try run(f), [(.referenceConflict, "register-T"), (.approvalMissing, "Q")])
        } else {
            expect(try run(f), [(.approvalConflict, "Q"), (.referenceConflict, "register-T")])
        }
    }
    @Test(arguments: [false, true])
    func c46UnapprovedProfileCannotHideIndependentReferenceBindingConflict(_ missing: Bool) throws {
        var f = try registration()
        let target = try decode(raw(f.envelope["request"]!["payload"]!["targetRegistryBytes"]!))
        let changed = set(target, "references", .array([set(target["references"]!.items[0], "attachedBy", s("wrong-authority"))]))
        try changeRequest(&f) { set($0, "targetRegistryBytes", blob(try C.make(.registry, changed).bytes)) }
        try alterProfileApproval(&f, missing: missing)
        if missing {
            expect(try run(f), [(.referenceConflict, "register-T"), (.approvalMissing, "P-Q")])
        } else {
            expect(try run(f), [(.approvalConflict, "P-Q"), (.referenceConflict, "register-T")])
        }
    }
    @Test(arguments: [false, true], ["unique", "meaning", "continuity", "correspondence"])
    func c47EnvelopeOwnerLabelCannotReplaceBaselineEvidenceAuthority(_ profileUsesEnvelopeOwner: Bool, _ purpose: String) throws {
        var f = try registration()
        try mutateEvidence(&f, purpose: purpose, field: "disposition", value: s("contradicts"))
        if profileUsesEnvelopeOwner { try alterProfileApproval(&f, missing: false) }
        // Preserve the baseline and its owner. This unbound envelope-label change cannot
        // remove an established negative assertion or grant the other reviewer authority.
        f.envelope = set(f.envelope, "ownerAuthority", s("unrelated-owner"))
        var findings: [(SyntheticRegistrationIssue, String)] = [(.approvalConflict, "B")]
        if !profileUsesEnvelopeOwner { findings.append((.approvalConflict, "P-Q")) }
        findings += [(.approvalConflict, "Q"), (.approvalConflict, "conversion"), (.approvalConflict, "invented-lineage")]
        if !profileUsesEnvelopeOwner { findings.append((.referenceConflict, "register-T")) }
        expect(try run(f), findings)
    }
    @Test(arguments: [false, true])
    func c48RetainedConversionWithRequiredS9CannotAdmitRegistrationOrReplay(_ replay: Bool) throws {
        let artifact = try completeS9Artifact()
        var f = try base(registry(0, entities: [], references: [], schema: 2))
        f.catalog = [artifact]
        try request(&f, id: "conversion", operation: "convertLegacy", records: [], target: registry(1, entities: [], references: []))
        try changeRequest(&f) { set(set($0, "s9ArtifactIDs", list([artifact.id])),
            "dependencyDigests", .array([binding(artifact)])) }
        try assertMechanicallyChecked(f, replay: false, conversionOnly: true)
        try append(&f)
        let conversion = f.envelope["history"]!["boundaries"]!.items[0]
        #expect(conversion["dependencies"]!.items.count == 1)
        #expect(raw(conversion["dependencies"]!.items[0]["bytes"]!) == artifact.document.bytes)
        try request(&f, id: "Q", operation: "register", records: [registrationRecord()],
            target: registry(2, entities: [entity(trip)], references: [reference(key())]))
        try supply(&f)
        if replay { try append(&f) }
        try assertMechanicallyChecked(f, replay: replay)
        let original = try C.make(.envelope, f.envelope).bytes
        guard case .outsideC1(let limits, let diagnostics) = try run(f) else {
            Issue.record("Required retained conversion artifact must prevent a C1 candidate or unchanged replay"); return
        }
        #expect(limits == [SyntheticRegistrationC1Limit(requestID: "conversion", reason: .snapshotAdmission)])
        #expect(diagnostics.isEmpty)
        #expect(try C.make(.envelope, f.envelope).bytes == original)
    }
    @Test(arguments: [false, true], [false, true])
    func c49PlainConversionAndUnrelatedS9PreserveRegistrationAndReplay(_ unrelatedArtifact: Bool, _ replay: Bool) throws {
        var f = try converted()
        if unrelatedArtifact { f.envelope = set(f.envelope, "s9Artifacts", .array([try completeS9Artifact().document.value])) }
        // Supplying an artifact does not make it a dependency of conversion or registration.
        try assertMechanicallyChecked(f, replay: true, conversionOnly: true)
        try request(&f, id: "Q", operation: "register", records: [registrationRecord()],
            target: registry(2, entities: [entity(trip)], references: [reference(key())]))
        try supply(&f)
        if replay { try append(&f) }
        try assertMechanicallyChecked(f, replay: replay)
        let result = try #require(candidate(run(f), replay: replay))
        if replay {
            #expect(result.registryBytes == f.current)
            #expect(result.historyBytes == (try C.encoded(f.envelope["history"]!)))
            #expect(result.checkpointBytes == (try C.make(.checkpoint, f.checkpoint).bytes))
            #expect(result.recordIDs == ["register-T"])
        } else {
            try assertCandidate(f, result)
        }
    }
}
#endif
