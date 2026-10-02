#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticTripRegistrationCodecTests {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias F = SyntheticRegistrationFormat
    typealias E = SyntheticTripRegistrationClosure.Entry
    private let zero = String(repeating: "0", count: 64)
    private func u(_ n: Int) -> UUID { UUID(uuidString: String(format: "00000000-0000-0000-0000-%012x", n))! }
    private func s(_ text: String) -> V { .string(text) }
    private func array(_ items: String...) -> V { .array(items.map(s)) }
    private func json(_ text: String) throws -> V { try JSONDecoder().decode(V.self, from: Data(text.utf8)) }
    private func replacing(_ v: V, _ key: String, _ new: V?) -> V {
        guard case .object(var fields) = v else { fatalError("test object") }
        fields[key] = new; return .object(fields)
    }
    private func expectIssue(_ issue: SyntheticRegistrationIssue, _ body: () throws -> Void) {
        do { try body(); Issue.record("Expected representation failure") }
        catch let actual as SyntheticRegistrationIssue { #expect(actual == issue) }
        catch { Issue.record("Unexpected error type") }
    }
    private func issues(_ result: SyntheticRegistrationClosureResult, invalid: Bool) -> [SyntheticRegistrationIssue] {
        switch result {
        case .completeRepresentation: Issue.record("Expected findings"); return []
        case .invalid(let ds): #expect(invalid); return ds.map(\.issue)
        case .incomplete(let ds): #expect(!invalid); return ds.map(\.issue)
        }
    }
    private func complete(_ result: SyntheticRegistrationClosureResult) {
        guard case .completeRepresentation = result else { Issue.record("Expected representation closure"); return }
    }
    private func dep(_ kind: String, _ id: String, _ doc: SyntheticRegistrationDocument? = nil) -> V {
        .object(["kind": s(kind), "id": s(id), "sha256": s(doc?.sha256 ?? zero)])
    }
    private func viewValue() -> V {
        .object(["sourceRevision": s(u(1).uuidString.lowercased()), "mappingRevision": s(u(2).uuidString.lowercased()),
                 "profileRevision": s(u(3).uuidString.lowercased()), "reviewRevision": s(u(4).uuidString.lowercased())])
    }
    private func profile(_ evidence: SyntheticRegistrationDocument? = nil) throws -> SyntheticRegistrationDocument {
        let payload: V = .object(["profileID": s("P"), "version": s("1"), "sourceID": s("S"), "publisherScope": s("invented"),
                                  "resourceScope": s("r"), "feedScope": s("f"), "namespace": s("gtfs.trip_id"), "applicableInputSHA256s": .array([]),
                                  "uniquenessEvidenceIDs": evidence == nil ? .array([]) : array("E"), "meaningEvidenceIDs": .array([]),
                                  "continuityEvidenceIDs": .array([]), "dependencyDigests": .array(evidence.map { [dep("evidence","E",$0)] } ?? [])])
        return try C.make(.payload, wrapper("profile","P",payload))
    }
    private func wrapper(_ kind: String, _ id: String, _ payload: V) -> V {
        .object(["format": s("tsugino.synthetic-trip-payload"), "schemaVersion": .integer(1), "subjectKind": s(kind), "subjectID": s(id), "payload": payload])
    }
    private func approval(_ doc: SyntheticRegistrationDocument, _ id: String = "review-P") -> V {
        .object(["reviewID": s(id), "author": s("invented-author"), "reviewer": s("invented-owner"), "role": s("owner"),
                 "approvedAt": s("2026-10-02T00:00:00Z"), "subjectKind": doc.value["subjectKind"]!, "subjectID": doc.value["subjectID"]!,
                 "payloadSHA256": s(doc.sha256), "approvalReference": s("invented-review")])
    }
    private func approved(_ doc: SyntheticRegistrationDocument) throws -> SyntheticRegistrationDocument {
        try C.make(.approved, .object(["payload": doc.value, "approval": approval(doc)]))
    }
    private func evidence(_ value: String = "e\u{301}") throws -> SyntheticRegistrationDocument {
        try C.make(.evidence, .object(["evidenceID": s("E"), "sha256": s(zero), "locator": s(value), "role": s("identity"),
                                      "profileID": s("P"), "profileVersion": s("1"), "inputSHA256s": .array([]), "view": viewValue(),
                                      "referenceKeys": .array([]), "tripIDs": array("T"), "recordIDs": .array([]), "artifactIDs": .array([]),
                                      "disposition": s("supports"), "applicability": .array([]), "viewApplicability": .array([])]))
    }
    private func packet(_ variant: Int = 0) -> SyntheticTripReviewPacket {
        let view = SyntheticTripReviewView(sourceRevision: u(1), mappingRevision: u(2), profileRevision: u(3), reviewRevision: u(4))
        let classifications: [SyntheticTripClassification] = [
            .passenger(.resolved(StationID("A")!, membership: [LineID("L2")!,LineID("L1")!], evidence: u(21)), evidence: u(20)),
            .passed(evidence: u(22)), .passenger(.unavailable,evidence:nil), .passenger(.impossible,evidence:u(23)), .unknown,
            .passenger(.resolved(StationID("A")!, membership: [], evidence:nil), evidence:nil), .passed(evidence:nil)]
        let identities: [SyntheticTripIdentity] = [.reviewed(TripID("T")!,evidence:u(25)), .unresolved, .impossible, .awaitingRegistration, .reviewed(TripID("T")!,evidence:nil)]
        let boundaries: [SyntheticTripBoundary] = [.reached(evidence:u(26)), .continued(evidence:u(27)), .unknownExtent, .reached(evidence:nil), .continued(evidence:nil)]
        let lines: [SyntheticTripLineMapping] = [.resolved(LineID("L1")!,evidence:u(28)), .unavailable, .impossible, .resolved(LineID("L1")!,evidence:nil)]
        let positions: [SyntheticTripPosition] = [.init(reference:u(10),order:40,classification:classifications[variant % classifications.count]),
                                                 .init(reference:u(11),order:nil,classification:.passed(evidence:u(29))),
                                                 .init(reference:u(12),order:90,classification:classifications[0])]
        let run = SyntheticTripReviewRun(reference:u(9),view:view,positions:positions,first:u(10),last:u(12),intervalEvidence:u(30),
                                        identity:identities[variant % identities.count],continuityEvidence:u(31),
                                        origin:boundaries[variant % boundaries.count],destination:boundaries[(variant+1) % boundaries.count],
                                        movements:[.init(from:u(10),to:u(11),line:lines[variant % lines.count]), .init(from:u(11),to:u(12),line:.resolved(LineID("L2")!,evidence:u(32)))],prior:nil)
        return .init(view:view,evidenceReferences:Set((20...32).map(u)),runs:[run])
    }
    private func artifact(_ id: String, _ previous: String? = nil, _ dependencies: [V] = [], _ proofs: [V] = []) throws -> SyntheticRegistrationDocument {
        let packet = try SyntheticTripRegistrationS9Codec.encode(packet(),predecessors:previous.map { [u(9):$0] } ?? [:])
        return try C.make(.s9Artifact, .object(["schemaVersion": .integer(1), "artifactID": s(id), "packetBytes": s(packet.bytes.base64EncodedString()),
                                             "packetSHA256": s(packet.sha256), "selectedRunReference": s(u(9).uuidString.lowercased()),
                                             "proofBindings": .array(proofs), "viewBindings": .array([]), "dependencyDigests": .array(dependencies)]))
    }

    @Test func a01IndependentGoldenPayloadAndDigest() throws {
        // Literal bytes + SHA generated with Python json(sort_keys,separators)/hashlib,
        // not via this Swift encoder. Fixed fixture, no runtime oracle generation.
        let golden = #"{"format":"tsugino.synthetic-trip-payload","payload":{"applicableInputSHA256s":[],"continuityEvidenceIDs":[],"dependencyDigests":[],"feedScope":"f","meaningEvidenceIDs":[],"namespace":"gtfs.trip_id","profileID":"P","publisherScope":"invented","resourceScope":"r","sourceID":"S","uniquenessEvidenceIDs":[],"version":"1"},"schemaVersion":1,"subjectID":"P","subjectKind":"profile"}"#
        let doc = try profile()
        #expect(doc.bytes == Data(golden.utf8))
        #expect(doc.sha256 == "9c21a6f14c084eafea53472441c82e5784398f1513927171d0def0c3e0667375")
        #expect(C.digest(Data("abc".utf8)) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        #expect(try C.read(.payload,Data(golden.utf8)).bytes == doc.bytes)
    }
    @Test(arguments: ["null","true","false","\"1\"","1.5","9223372036854775808"])
    func a02MalformedVersion(_ token: String) throws {
        let raw = String(decoding:try profile().bytes,as:UTF8.self).replacingOccurrences(of:"\"schemaVersion\":1",with:"\"schemaVersion\":\(token)")
        expectIssue(.malformedInput) { _ = try C.read(.payload,Data(raw.utf8)) }
    }
    @Test(arguments:[0,2,99,-1]) func a03UnsupportedVersion(_ version: Int) throws {
        expectIssue(.unsupportedVersion) { _ = try C.make(.payload,replacing(try profile().value,"schemaVersion",.integer(version))) }
    }
    @Test func a04MissingTagUnknownKeysAndDuplicateKeys() throws {
        let p = try profile()
        for key in ["schemaVersion","subjectKind","format"] {
            expectIssue(.malformedInput) { _ = try C.make(.payload,replacing(p.value,key,nil)) }
        }
        expectIssue(.malformedInput) { _ = try C.make(.payload,replacing(p.value,"secret",s("not allowed"))) }
        let raw = String(decoding:p.bytes,as:UTF8.self)
        let duplicate = raw.replacingOccurrences(of:"\"schemaVersion\":1",with:"\"schemaVersion\":1,\"schemaVersion\":1")
        expectIssue(.malformedInput) { _ = try C.read(.payload,Data(duplicate.utf8)) }
        let escaped = raw.replacingOccurrences(of:"\"schemaVersion\":1",with:"\"schemaVersion\":1,\"schemaVersi\\u006fn\":1")
        expectIssue(.malformedInput) { _ = try C.read(.payload,Data(escaped.utf8)) }
    }
    @Test(arguments:["1.0","1e0","1.000"]) func a05NoncanonicalNumericSpelling(_ token:String) throws {
        let raw = String(decoding:try profile().bytes,as:UTF8.self).replacingOccurrences(of:"\"schemaVersion\":1",with:"\"schemaVersion\":\(token)")
        expectIssue(.malformedInput) { _ = try C.read(.payload,Data(raw.utf8)) }
    }
    @Test func a06ScalarExactAndCanonicalSets() throws {
        let a = try evidence("é"), b = try evidence("e\u{301}")
        #expect(a.bytes != b.bytes); #expect(a.sha256 != b.sha256)
        #expect(try C.read(.evidence,b.bytes).value["locator"]!.text!.unicodeScalars.map(\.value) == [101,769])
        let unordered = replacing(b.value,"tripIDs",array("Z","A"))
        let canonical = try C.make(.evidence,unordered)
        #expect(canonical.value["tripIDs"]!.items.compactMap(\.text) == ["A","Z"])
        expectIssue(.malformedInput) { _ = try C.read(.evidence,C.encoded(unordered)) }
        expectIssue(.malformedInput) { _ = try C.make(.evidence,replacing(b.value,"tripIDs",array("A","A"))) }
    }
    @Test(arguments:0..<7) func a07S9EveryInputVariantAndPredecessorRoundTrip(_ variant:Int) throws {
        let doc = try SyntheticTripRegistrationS9Codec.encode(packet(variant),predecessors:[u(9):"A0"])
        let decoded = try SyntheticTripRegistrationS9Codec.decode(doc.bytes)
        #expect(decoded.predecessors == [u(9):"A0"])
        #expect(decoded.packet.runs[0].prior == nil)
        #expect(decoded.packet.runs[0].positions.map(\.reference) == [u(10),u(11),u(12)])
        #expect(decoded.packet.runs[0].positions.map(\.order) == [40,nil,90])
        #expect(decoded.packet.runs[0].intervalEvidence == u(30))
        #expect(decoded.packet.runs[0].continuityEvidence == u(31))
        #expect(decoded.packet.runs[0].movements.map(\.from) == [u(10),u(11)])
        #expect(decoded.packet.runs[0].movements.map(\.to) == [u(11),u(12)])
        #expect(decoded.packet.evidenceReferences == Set((20...32).map(u)))
        #expect(decoded.packet.view == packet().view)
        #expect(try SyntheticTripRegistrationS9Codec.encode(decoded.packet,predecessors:decoded.predecessors).bytes == doc.bytes)
        let last = doc.value["runs"]!.items[0]["positions"]!.items[2]["classification"]!
        #expect(last["evidence"]!.text == u(20).uuidString.lowercased())
        #expect(last["mapping"]!["evidence"]!.text == u(21).uuidString.lowercased())
        #expect(last["mapping"]!["membership"]!.items.compactMap(\.text) == ["L1","L2"])
        #expect(last["mapping"]!["stationID"]!.text == "A")
    }
    @Test func a08S9MissingOptionalIsNotNullAndBadTagsFail() throws {
        let packet = try SyntheticTripRegistrationS9Codec.encode(packet())
        let text = String(decoding:packet.bytes,as:UTF8.self)
        let null = text.replacingOccurrences(of:"\"tag\":\"passed\"",with:"\"tag\":\"passed\",\"order\":null")
        expectIssue(.malformedInput) { _ = try C.read(.s9Packet,Data(null.utf8)) }
        let bad = text.replacingOccurrences(of:"\"tag\":\"passed\"",with:"\"tag\":\"maybe\"")
        expectIssue(.malformedInput) { _ = try C.read(.s9Packet,Data(bad.utf8)) }
    }
    @Test func a09ProfileApprovalDomainsAndIdentifierBacklink() throws {
        let e = try evidence(), p = try approved(profile(e))
        complete(SyntheticTripRegistrationClosure.validate(roots:[p],catalog:[E(kind:"evidence",id:"E",document:e)]))
        #expect(p.sha256 != p.value["approval"]!["payloadSHA256"]!.text)
        let badApproval = replacing(p.value["approval"]!,"payloadSHA256",s(p.sha256))
        let changed = try C.make(.approved,replacing(p.value,"approval",badApproval))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[changed],catalog:[E(kind:"evidence",id:"E",document:e)]),invalid:true) == [.approvalConflict])
    }
    @Test func a10MissingApprovalAndDependencyHold() throws {
        let e = try evidence(), p = try C.make(.approved,.object(["payload":profile(e).value]))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[p],catalog:[]),invalid:false) == [.approvalMissing,.correspondenceUnavailable])
    }
    @Test func a11AlteredDependencyDoesNotBecomeMissing() throws {
        let e = try evidence(), p = try approved(profile(e)), changed = try evidence("different")
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[p],catalog:[E(kind:"evidence",id:"E",document:changed)]),invalid:true) == [.historyConflict])
    }
    @Test func a12ThreeLevelPredecessorClosure() throws {
        let a0 = try artifact("A0"), a1 = try artifact("A1","A0",[dep("s9Artifact","A0",a0)]),
            a2 = try artifact("A2","A1",[dep("s9Artifact","A1",a1),dep("s9Artifact","A0",a0)])
        let catalog = [E(kind:"s9Artifact",id:"A1",document:a1), E(kind:"s9Artifact",id:"A0",document:a0)]
        complete(SyntheticTripRegistrationClosure.validate(roots:[a2],catalog:catalog))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[a2],catalog:[catalog[0]]),invalid:false) == [.snapshotUnavailable])
        let changed = try C.make(.s9Artifact,replacing(a0.value,"selectedRunReference",s(u(999).uuidString.lowercased())))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[a2],catalog:[catalog[0],E(kind:"s9Artifact",id:"A0",document:changed)]),invalid:true) == [.historyConflict])
    }
    @Test func a13ConflictingCatalogAndMissingDependencyRetainBoth() throws {
        let e = try evidence(), e2 = try evidence("other"), p = try approved(profile(e)), a = try artifact("A","missing",[dep("s9Artifact","missing")])
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[p,a],catalog:[E(kind:"evidence",id:"E",document:e),E(kind:"evidence",id:"E",document:e2)]),invalid:true) == [.historyConflict,.snapshotUnavailable])
    }
    @Test func a14CycleCannotHideBehindWrongDigests() throws {
        let a = try artifact("A","B",[dep("s9Artifact","B")]), b = try artifact("B","A",[dep("s9Artifact","A")])
        let result = issues(SyntheticTripRegistrationClosure.validate(roots:[],catalog:[E(kind:"s9Artifact",id:"A",document:a),E(kind:"s9Artifact",id:"B",document:b)]),invalid:true)
        #expect(result.contains(.historyConflict))
    }
    @Test func a15ExistingReadersStillRejectSchema4() throws {
        let doc = try C.make(.registry,.object(["schemaVersion":.integer(4),"revision":.integer(0),"entities":.array([]),"references":.array([])]))
        #expect(throws:(any Error).self) { _ = try MappingRegistry.decoded(from:doc.bytes) }
        #expect(throws:(any Error).self) { _ = try MappingRegistry.decodedForIdentityTransition(from:doc.bytes) }
        #expect(MintedIdentifier("trp_0000000000000001") == nil)
        #expect(ProviderNamespace(rawValue:"gtfs.trip_id") == nil)
    }
    @Test func a16RepresentationIsNotBusinessApproval() throws {
        // Unsupported business facts remain representable; slice A does not admit them.
        let a = try artifact("A") // Deliberately missing proof/view bindings; slice C owns applicability.
        complete(SyntheticTripRegistrationClosure.validate(roots:[a],catalog:[]))
        let e = try evidence()
        let contradictory = try C.make(.evidence,replacing(e.value,"disposition",s("contradicts")))
        complete(SyntheticTripRegistrationClosure.validate(roots:[contradictory],catalog:[]))
    }

    private func baseline() throws -> SyntheticRegistrationDocument {
        let payload: V = .object(["lineageID":s("L"),"ownerAuthority":s("invented-owner"),"registryBytes":s("e30="),
                                  "registrySHA256":s(C.digest(Data("{}".utf8))),"legacyHistoryState":s("none"),"historyComplete":.bool(true),
                                  "seedInventory":.object(["attachmentRecordIDs":.array([]),"statusRecordIDs":.array([]),"allocationIDs":.array([]),
                                                           "reviewIDs":.array([]),"selections":.array([])]),"dependencyDigests":.array([])])
        let wrapper = try C.make(.payload,wrapper("baseline","B",payload))
        return try C.make(.approved,.object(["payload":wrapper.value,"approval":approval(wrapper,"review-B")]))
    }
    private func request(_ e: SyntheticRegistrationDocument, _ p: SyntheticRegistrationDocument, _ artifact: SyntheticRegistrationDocument) throws -> SyntheticRegistrationDocument {
        let payload: V = .object(["requestID":s("Q"),"lineageID":s("L"),"operation":s("reviseSnapshot"),
                                  "expectedPrevious":.object(["lineageID":s("L"),"schemaVersion":.integer(4),"revision":.integer(1),"registrySHA256":s(zero),"historySHA256":s(zero)]),
                                  "targetRegistryBytes":s("e30="),"records":.array([.object(["recordID":s("selection"),"tripID":s("T"),"mode":s("initialSelection"),
                                                                                        "nextArtifactID":s("A"),"correspondenceEvidenceIDs":array("E")])]),
                                  "profileIDs":array("P"),"evidenceIDs":array("E"),"s9ArtifactIDs":array("A"),
                                  "dependencyDigests":.array([dep("profile","P",p),dep("evidence","E",e),dep("s9Artifact","A",artifact)])])
        return try C.make(.payload,wrapper("request","Q",payload))
    }
    @Test func a17FullEnvelopeAcyclicBytesAndApprovalMutation() throws {
        let e = try evidence(), p = try approved(profile(e)), a = try artifact("A"), b = try baseline(), q = try request(e,p,a)
        let history: V = .object(["format":s("tsugino.synthetic-trip-history"),"schemaVersion":.integer(1),"lineageID":s("L"),"baselineSHA256":s(b.sha256),"boundaries":.array([])])
        let env = try C.make(.envelope,.object(["format":s("tsugino.synthetic-trip-registration"),"schemaVersion":.integer(1),"mode":s("synthetic"),"lineageID":s("L"),
                                              "ownerAuthority":s("invented-owner"),"baseline":b.value,"history":history,"request":q.value,"approvals":.array([approval(q,"review-Q")]),
                                              "profiles":.array([p.value]),"evidence":.array([e.value]),"s9Artifacts":.array([a.value])]))
        #expect(try C.read(.envelope,env.bytes).bytes == env.bytes)
        complete(SyntheticTripRegistrationClosure.validate(roots:[env],catalog:[]))
        let changedAuthority = try C.make(.envelope,replacing(env.value,"ownerAuthority",s("another-assertion")))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[changedAuthority],catalog:[]),invalid:true) == [.approvalConflict])
        // Even with digest integrity, '{}' is no registry: slice A intentionally does not validate it.
        let b2 = try C.make(.approved,replacing(b.value,"approval",replacing(b.value["approval"]!,"approvalReference",s("altered"))))
        #expect(b.sha256 != b2.sha256) // Complete approved baseline, not just payload, is hashed.
        let baselineMutation = try C.make(.envelope,replacing(env.value,"baseline",b2.value))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[baselineMutation],catalog:[]),invalid:true) == [.historyConflict])
        let p2 = try C.make(.approved,replacing(p.value,"approval",replacing(p.value["approval"]!,"approvalReference",s("altered"))))
        let env2 = try C.make(.envelope,replacing(env.value,"profiles",.array([p2.value])))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[env2],catalog:[]),invalid:true) == [.historyConflict])
        let mutatedRequest = replacing(q.value,"payload",replacing(q.value["payload"]!,"targetRegistryBytes",s("W10=")))
        let env3 = try C.make(.envelope,replacing(env.value,"request",mutatedRequest))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[env3],catalog:[]),invalid:true) == [.approvalConflict])
    }
    @Test func a18GoldenHistoryDoesNotValidateCheckpoint() throws {
        // Independent Python json/hashlib fixture, not generated by production encoding.
        let literal = #"{"baselineSHA256":"0000000000000000000000000000000000000000000000000000000000000000","boundaries":[],"format":"tsugino.synthetic-trip-history","lineageID":"L","schemaVersion":1}"#
        let doc = try C.read(.history,Data(literal.utf8))
        #expect(doc.sha256 == "6163152e4d6e18a52b866fa5b6ce539013290516ace7759d40e263603296b92b")
        complete(SyntheticTripRegistrationClosure.validate(roots:[doc],catalog:[]))
    }
    @Test(arguments:["2026-10-02","2026-10-02T00:00:00+00:00","2026-10-02T00:00:00.000Z","not-a-time"])
    func a19ApprovalTimestampIsStrict(_ timestamp:String) throws {
        let doc = try profile()
        expectIssue(.malformedInput) { _ = try C.make(.approval,replacing(approval(doc),"approvedAt",s(timestamp))) }
    }
    @Test func a20CycleWithoutInventoryStillRejects() throws {
        let a = try artifact("A","B"), b = try artifact("B","A")
        let result = issues(SyntheticTripRegistrationClosure.validate(roots:[a,b],catalog:[]),invalid:true)
        #expect(result.contains(.snapshotConflict)); #expect(result.contains(.snapshotUnavailable))
    }
    @Test(arguments:0..<8) func a21EveryProofRoleAndViewAssociationRoundTrips(_ roleIndex:Int) throws {
        let role = SyntheticRegistrationSchema.roles[roleIndex]
        var scope: V = .object(["tripID":s("T"),"profileID":s("P"),"profileVersion":s("1"),"sourceID":s("S"),"referenceKeys":.array([]),"view":viewValue()])
        if ["classification","mapping","origin","destination"].contains(role) { scope = replacing(scope,"occurrence",s(u(12).uuidString.lowercased())) }
        if ["interval","continuity","movement"].contains(role) { scope = replacing(replacing(scope,"from",s(u(10).uuidString.lowercased())),"to",s(u(12).uuidString.lowercased())) }
        if role == "movement" { scope = replacing(scope,"lineID",s("L1")) }
        let proof: V = .object(["runReference":s(u(9).uuidString.lowercased()),"role":s(role),"proofUUID":s(u(20+roleIndex).uuidString.lowercased()),"evidenceID":s("E"),"scope":scope])
        let a = try artifact("A",nil,[],[proof])
        let views = SyntheticRegistrationSchema.components.enumerated().reversed().map { i,component in
            V.object(["component":s(component),"revisionUUID":s(u(i+1).uuidString.lowercased()),"evidenceID":s("E"),"profileID":s("P"),"profileVersion":s("1")])
        }
        let doc = try C.make(.s9Artifact,replacing(a.value,"viewBindings",.array(views)))
        let read = try C.read(.s9Artifact,doc.bytes)
        #expect(try C.encoded(read.value["proofBindings"]!.items[0]) == C.encoded(proof))
        #expect(read.value["viewBindings"]!.items.compactMap { $0["component"]?.text } == SyntheticRegistrationSchema.components)
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[doc],catalog:[]),invalid:false) == [.scopeUnavailable,.correspondenceUnavailable])
    }
    @Test func a22MalformedNestedAndOptionalFields() throws {
        let a = try artifact("A")
        expectIssue(.malformedInput) { _ = try C.make(.s9Artifact,replacing(a.value,"packetBytes",s("not-base64"))) }
        expectIssue(.malformedInput) { _ = try C.make(.s9Artifact,replacing(a.value,"packetSHA256",s(zero.uppercased()+"0"))) }
        let raw = String(decoding:try C.make(.approved,.object(["payload":profile().value])).bytes,as:UTF8.self)
        expectIssue(.malformedInput) { _ = try C.read(.approved,Data(("{\"approval\":null,"+raw.dropFirst()).utf8)) }
        let p = try profile()
        let invalidKind = replacing(p.value,"subjectKind",s("unrecognized"))
        expectIssue(.malformedInput) { _ = try C.make(.payload,invalidKind) }
        expectIssue(.unsupportedVersion) { _ = try C.make(.payload,replacing(invalidKind,"schemaVersion",.integer(99))) }
    }
    @Test func a23MalformedSelectedPacketPlusMissingDependencyRejects() throws {
        let a = try artifact("A","missing",[dep("s9Artifact","missing")])
        let badBytes = Data("{}".utf8)
        let bad = try C.make(.s9Artifact,replacing(replacing(a.value,"packetBytes",s(badBytes.base64EncodedString())),"packetSHA256",s(C.digest(badBytes))))
        #expect(issues(SyntheticTripRegistrationClosure.validate(roots:[bad],catalog:[]),invalid:true) == [.malformedInput,.snapshotUnavailable])
    }
    @Test func a24RegistrySyntaxRetainsEveryFieldWithoutAdmittingBindings() throws {
        let source: V = .object(["inputSHA256":s(zero),"member":.object(["name":s("invented.txt"),"sha256":s(zero)]),"table":s("invented"),"field":s("trip_id"),"providerKey":s("e\u{301}")])
        let names: [V] = ["z","a"].map { .object(["language":s("en"),"value":s($0),"source":source]) }
        let ref: V = .object(["canonicalID":s("trp_0000000000000001"),"sourceID":s("S"),"namespace":s("gtfs.trip_id"),"value":s("e\u{301}"),
                              "status":.object(["state":s("absent")]),"firstSeenInputSHA256":s(zero),"provenance":source,"originalNames":.array(names),"attachedBy":s("review-original")])
        let registry: V = .object(["schemaVersion":.integer(4),"revision":.integer(1),"entities":.array([.object(["id":s("trp_0000000000000001"),"state":s("active")])]),"references":.array([ref])])
        let doc = try C.make(.registry,registry), decoded = try C.read(.registry,doc.bytes)
        let retained = decoded.value["references"]!.items[0]
        #expect(retained["value"]!.text!.unicodeScalars.map(\.value) == [101,769])
        #expect(retained["attachedBy"]!.text == "review-original")
        #expect(retained["status"]!["state"]!.text == "absent")
        #expect(try C.encoded(retained["provenance"]!) == C.encoded(source))
        #expect(retained["originalNames"]!.items.compactMap { $0["value"]?.text } == ["a","z"])
        expectIssue(.malformedInput) { _ = try C.make(.registry,replacing(registry,"revision",.integer(-1))) }
        expectIssue(.malformedInput) { _ = try C.make(.registry,replacing(registry,"entities",.array([.object(["id":s("bad"),"state":s("active")])]))) }
    }
    @Test func a25NoSilentScalarCoalescingIntoMembershipSet() throws {
        let doc = try SyntheticTripRegistrationS9Codec.encode(packet())
        let text = String(decoding:doc.bytes,as:UTF8.self).replacingOccurrences(of:#"["L1","L2"]"#,with:#"["e\u0301","é"]"#)
        // Build the canonical wire spelling while retaining both scalar-distinct values.
        let wire = try C.make(.s9Packet,json(text))
        expectIssue(.malformedInput) { _ = try SyntheticTripRegistrationS9Codec.decode(wire.bytes) }
    }
    @Test func a26DuplicateRequestIDsAndBlockedModeTags() throws {
        let e = try evidence(), p = try approved(profile(e)), a = try artifact("A"), q = try request(e,p,a)
        let record = q.value["payload"]!["records"]!.items[0]
        let duplicate = replacing(q.value,"payload",replacing(q.value["payload"]!,"records",.array([record,record])))
        expectIssue(.malformedInput) { _ = try C.make(.payload,duplicate) }
        let badInitial = replacing(record,"previousArtifactID",s("old"))
        let bad = replacing(q.value,"payload",replacing(q.value["payload"]!,"records",.array([badInitial])))
        expectIssue(.malformedInput) { _ = try C.make(.payload,bad) }
        let mode = replacing(q.value,"payload",replacing(q.value["payload"]!,"operation",s("split")))
        expectIssue(.malformedInput) { _ = try C.make(.payload,mode) }
        let conversion = replacing(q.value,"payload",replacing(replacing(q.value["payload"]!,"operation",s("convertLegacy")),"records",.array([.object([:])])))
        expectIssue(.malformedInput) { _ = try C.make(.payload,conversion) }
    }
    @Test(arguments:["null","1.5","9223372036854775808"])
    func a27UnsupportedVersionPrecedesUnsafeContents(_ content:String) {
        let raw = "{\"schemaVersion\":99,\"payload\":\(content)}"
        expectIssue(.unsupportedVersion) { _ = try C.read(.payload,Data(raw.utf8)) }
    }
    @Test func a28DuplicateS9RunsCannotLosePredecessors() throws {
        let p = packet()
        let repeated = SyntheticTripReviewPacket(view:p.view,evidenceReferences:p.evidenceReferences,runs:[p.runs[0],p.runs[0]])
        expectIssue(.malformedInput) { _ = try SyntheticTripRegistrationS9Codec.encode(repeated) }
    }
}
#endif
