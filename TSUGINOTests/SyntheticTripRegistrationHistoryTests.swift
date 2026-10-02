#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticTripRegistrationHistoryTests {
    typealias V = SyntheticRegistrationValue
    typealias C = SyntheticTripRegistrationCodec
    typealias H = SyntheticTripRegistrationHistory
    typealias L = SyntheticTripLegacyHistory
    private let zero = String(repeating:"0",count:64)
    private func s(_ value: String) -> V { .string(value) }
    private func set(_ v: V, _ key: String, _ value: V?) -> V {
        guard case .object(var fields) = v else { fatalError("fixture object") }; fields[key] = value; return .object(fields)
    }
    private func value(_ data: Data) throws -> V { try JSONDecoder().decode(V.self,from:data) }
    private func blob(_ data: Data) -> V { s(data.base64EncodedString()) }
    private func wrapper(_ kind: String, _ id: String, _ payload: V) -> V {
        .object(["format":s("tsugino.synthetic-trip-payload"),"schemaVersion":.integer(1),"subjectKind":s(kind),"subjectID":s(id),"payload":payload])
    }
    private func approval(_ wrapper: V, _ id: String) throws -> V {
        .object(["reviewID":s(id),"author":s("invented-author"),"reviewer":s("invented-owner"),"role":s("owner"),
                 "approvedAt":s("2026-10-02T00:00:00Z"),"subjectKind":wrapper["subjectKind"]!,"subjectID":wrapper["subjectID"]!,
                 "payloadSHA256":s(C.digest(try C.encoded(wrapper))),"approvalReference":s("invented-approval")])
    }
    private func empty(_ schema: Int = 2, _ revision: Int = 0) throws -> Data {
        try C.encoded(.object(["schemaVersion":.integer(schema),"revision":.integer(revision),"entities":.array([]),"references":.array([])]),pretty:true)
    }
    private func target(_ bytes: Data) throws -> Data {
        let v = try value(bytes)
        guard case .integer(let revision) = v["revision"] else { fatalError("fixture revision") }
        return try C.make(.registry,set(set(v,"schemaVersion",.integer(4)),"revision",.integer(revision == Int.max ? Int.max : revision+1))).bytes
    }
    private func pin(_ bytes: Data, _ history: V) throws -> V {
        let v = try value(bytes)
        return .object(["lineageID":s("invented-lineage"),"schemaVersion":v["schemaVersion"]!,"revision":v["revision"]!,
                        "registrySHA256":s(C.digest(bytes)),"historySHA256":s(C.digest(try C.encoded(history)))])
    }
    private func request(_ id: String, _ current: Data, _ history: V, _ next: Data, _ operation: String = "convertLegacy") throws -> V {
        wrapper("request",id,.object(["requestID":s(id),"lineageID":s("invented-lineage"),"operation":s(operation),
            "expectedPrevious":try pin(current,history),"targetRegistryBytes":blob(next),"records":.array([]),
            "profileIDs":.array([]),"evidenceIDs":.array([]),"s9ArtifactIDs":.array([]),"dependencyDigests":.array([])]))
    }
    private struct Fixture { var envelope: V; var current: Data; var checkpoint: V }
    private func fixture(_ bytes: Data? = nil, sidecar: Data? = nil, complete: Bool = true) throws -> Fixture {
        let current = try bytes ?? empty()
        var payload: V = .object(["lineageID":s("invented-lineage"),"ownerAuthority":s("invented-owner"),"registryBytes":blob(current),
            "registrySHA256":s(C.digest(current)),"legacyHistoryState":s(sidecar == nil ? "none":"present"),"historyComplete":.bool(complete),
            "seedInventory":.object(["attachmentRecordIDs":.array([]),"statusRecordIDs":.array([]),"allocationIDs":.array([]),"reviewIDs":.array([]),"selections":.array([])]),"dependencyDigests":.array([])])
        if let sidecar { payload = set(set(payload,"legacyHistoryBytes",blob(sidecar)),"legacyHistorySHA256",s(C.digest(sidecar))) }
        let wrapped = wrapper("baseline","B",payload)
        let baseline = V.object(["payload":wrapped,"approval":try approval(wrapped,"review-B")])
        let history: V = .object(["format":s("tsugino.synthetic-trip-history"),"schemaVersion":.integer(1),"lineageID":s("invented-lineage"),
                                 "baselineSHA256":s(C.digest(try C.encoded(baseline))),"boundaries":.array([])])
        let isFour: Bool
        if case .integer(4) = try value(current)["schemaVersion"] { isFour = true } else { isFour = false }
        let q = try request("Q",current,history,target(current),isFour ? "attach":"convertLegacy")
        let envelope: V = .object(["format":s("tsugino.synthetic-trip-registration"),"schemaVersion":.integer(1),"mode":s("synthetic"),
            "lineageID":s("invented-lineage"),"ownerAuthority":s("invented-owner"),"baseline":baseline,"history":history,"request":q,
            "approvals":.array([try approval(q,"review-Q")]),"profiles":.array([]),"evidence":.array([]),"s9Artifacts":.array([])])
        return Fixture(envelope:envelope,current:current,checkpoint:try pin(current,history))
    }
    private func run(_ f: Fixture, catalog: [SyntheticTripRegistrationClosure.Entry] = []) throws -> SyntheticRegistrationHistoryResult {
        H.validate(envelopeBytes:try C.make(.envelope,f.envelope).bytes,currentRegistryBytes:f.current,
                   currentCheckpointBytes:try C.make(.checkpoint,f.checkpoint).bytes,catalog:catalog)
    }
    private func checked(_ result: SyntheticRegistrationHistoryResult) -> SyntheticRegistrationHistoryReport? {
        guard case .checked(let report) = result else { Issue.record("Expected mechanical integrity: \(result)"); return nil }; return report
    }
    private func expect(_ result: SyntheticRegistrationHistoryResult, _ issues: [SyntheticRegistrationIssue], held: Bool = false, locators: [String]? = nil) {
        switch result {
        case .checked: Issue.record("Unexpected mechanical success")
        case .held(let ds):
            #expect(held); #expect(ds.map(\.issue) == issues)
            if let locators { #expect(ds.map(\.locator) == locators) }
        case .rejected(let ds):
            #expect(!held); #expect(ds.map(\.issue) == issues)
            if let locators { #expect(ds.map(\.locator) == locators) }
        }
    }
    private func resign(_ f: inout Fixture, _ q: V) throws {
        f.envelope = set(set(f.envelope,"request",q),"approvals",.array([try approval(q,"review-" + q["subjectID"]!.text!)]))
    }
    private func append(_ f: inout Fixture) throws {
        let q = f.envelope["request"]!, h = f.envelope["history"]!, prior = h["boundaries"]!.items
        var b: V = .object(["previousRegistryBytes":blob(f.current),"targetRegistryBytes":q["payload"]!["targetRegistryBytes"]!,"request":q,
                           "approvals":f.envelope["approvals"]!,"dependencies":.array([])])
        if let last = prior.last { b = set(b,"previousBoundarySHA256",s(C.digest(try C.encoded(last)))) }
        let history = set(h,"boundaries",.array(prior+[b]))
        f.current = Data(base64Encoded:q["payload"]!["targetRegistryBytes"]!.text!)!
        f.envelope = set(f.envelope,"history",history); f.checkpoint = try pin(f.current,history)
    }
    private func legacyFixture() throws -> (Data,Data) {
        let id = MintedIdentifier("stn_0000000000000001")!
        let old = try MappingRegistry(revision:1,entities:[.init(id:id,status:.active)],references:[])
        let next = try MappingRegistry(revision:2,entities:[.init(id:id,status:.retired(successors:[]))],references:[],formatVersion:3)
        let before = try old.encoded(), after = try next.encoded(), evidence = Data("Invented retirement".utf8)
        let p = L.Payload(schemaVersion:1,id:"legacy-transition",operation:.retire,kind:"stn",previous:try L.Scope(before),target:try L.Scope(after),
            sources:[id],targets:[],beforeEntities:old.entities,afterEntities:next.entities,dispositions:[],
            evidence:[.init(source:ExactValue("invented")!,capture:.synthetic,bytes:evidence,sha256:C.digest(evidence),locator:ExactValue("whole")!,offset:0,
                            quotation:evidence,members:[id],nonNameSupport:ExactValue("invented structure")!)],rationale:ExactValue("invented")!,dependencies:[.init(role:"synthetic",sha256:zero)])
        let a = L.Approval(author:ExactValue("author")!,reviewer:ExactValue("owner")!,role:ExactValue("owner")!,reviewedAt:ExactValue("2026-10-02T00:00:00Z")!,reference:ExactValue("invented")!,payloadSHA256:try L.hash(p))
        let history = L.History(schemaVersion:1,boundaries:[.init(previousRegistry:before,targetRegistry:after,records:[.init(payload:p,approval:a)],previousSHA256:nil)])
        return (after,try RailwayArtifact.encode(history))
    }

    @Test func b01EmptyLegacyConversionIsOnlyMechanical() throws {
        let report = checked(try run(fixture()))
        #expect(report?.conversionOnly == true); #expect(report?.unchangedReplay == false)
        #expect(report?.businessAdmissionRequired == []); #expect(report?.stipulatedSeed == false)
    }
    @Test func b02OriginalSchema3RetirementWithSidecar() throws {
        let (registry,history) = try legacyFixture()
        #expect(checked(try run(fixture(registry,sidecar:history))) != nil)
    }
    @Test func b03Schema2CannotRelabelPureRetirement() throws {
        let (registry,_) = try legacyFixture()
        let invalid = try C.encoded(set(value(registry),"schemaVersion",.integer(2)),pretty:true)
        let f = try fixture(invalid)
        expect(try run(f),[.malformedInput,.malformedInput])
    }
    @Test func b04MissingLegacyHistoryHolds() throws {
        let (registry,_) = try legacyFixture()
        expect(try run(fixture(registry)),[.historyUnavailable],held:true)
    }
    @Test func b05AlteredLegacyHistoryRejects() throws {
        let (registry,history) = try legacyFixture()
        let v = try value(history), boundary = v["boundaries"]!.items[0]
        let altered = try C.encoded(set(v,"boundaries",.array([set(boundary,"previousSHA256",s(zero))])))
        expect(try run(fixture(registry,sidecar:altered)),[.historyConflict])
    }
    @Test func b06ExactCurrentReplayAndLaterStaleReplay() throws {
        var f = try fixture(); try append(&f)
        let report = checked(try run(f)); #expect(report?.unchangedReplay == true)
        let oldRequest = f.envelope["request"]!, oldApprovals = f.envelope["approvals"]!
        let next = try request("R",f.current,f.envelope["history"]!,target(f.current),"attach")
        try resign(&f,next); try append(&f)
        f.envelope = set(set(f.envelope,"request",oldRequest),"approvals",oldApprovals)
        expect(try run(f),[.staleCheckpoint])
    }
    @Test func b07AlteredReplayApproval() throws {
        var f = try fixture(); try append(&f)
        let a = f.envelope["approvals"]!.items[0]
        f.envelope = set(f.envelope,"approvals",.array([set(a,"approvalReference",s("changed"))]))
        expect(try run(f),[.historyConflict,.historyConflict])
    }
    @Test(arguments:["registrySHA256","historySHA256","lineageID","revision"])
    func b08WrongCheckpoint(_ field: String) throws {
        var f = try fixture()
        f.checkpoint = set(f.checkpoint,field,field == "revision" ? .integer(9) : s(field == "lineageID" ? "wrong" : zero))
        expect(try run(f),[.staleCheckpoint,.staleCheckpoint])
    }
    @Test func b09BrokenFirstLinkAndUncertaintyAreBothRetained() throws {
        var f = try fixture(complete:false); try append(&f)
        let h = f.envelope["history"]!, b = h["boundaries"]!.items[0]
        let changed = set(h,"boundaries",.array([set(b,"previousBoundarySHA256",s(zero))]))
        f.envelope = set(f.envelope,"history",changed); f.checkpoint = try pin(f.current,changed)
        expect(try run(f),[.historyConflict,.historyUnavailable])
    }
    @Test func b10UnexplainedConversionDeltaRejects() throws {
        var f = try fixture()
        let next = try value(target(f.current))
        let changed = try C.make(.registry,set(next,"entities",.array([.object(["id":s("stn_0000000000000001"),"state":s("active")])]))).bytes
        let q = set(f.envelope["request"]!,"payload",set(f.envelope["request"]!["payload"]!,"targetRegistryBytes",blob(changed)))
        try resign(&f,q); expect(try run(f),[.historyConflict])
    }
    @Test func b11OverflowDoesNotTrap() throws {
        expect(try run(fixture(empty(2,Int.max))),[.staleCheckpoint])
    }
    @Test func b12DuplicateHistoricalRequestAndReviewIDsReject() throws {
        var f = try fixture(); try append(&f)
        let q = try request("R",f.current,f.envelope["history"]!,target(f.current),"attach")
        try resign(&f,q)
        f.envelope = set(f.envelope,"approvals",.array([try approval(q,"review-Q")]))
        expect(try run(f),[.historyConflict])
    }
    @Test func b13AdmissionRemainsDeferredEvenWithConsistentHistory() throws {
        var f = try fixture(); try append(&f)
        let q = try request("R",f.current,f.envelope["history"]!,target(f.current),"attach")
        try resign(&f,q)
        let report = checked(try run(f)); #expect(report?.businessAdmissionRequired == ["R"])
        #expect(report?.conversionOnly == false)
        try append(&f)
        #expect(checked(try run(f))?.businessAdmissionRequired == ["R"])
    }
    @Test func b14MalformedBoundaryPayloadCannotCrashOrInventDeltaFindings() throws {
        var f = try fixture(); try append(&f)
        let h = f.envelope["history"]!, b = h["boundaries"]!.items[0]
        let bad = set(b,"request",f.envelope["baseline"]!["payload"]!)
        let changed = set(h,"boundaries",.array([bad])); f.envelope = set(f.envelope,"history",changed)
        f.checkpoint = try pin(f.current,changed)
        let result = H.validate(envelopeBytes:try C.encoded(f.envelope),currentRegistryBytes:f.current,currentCheckpointBytes:try C.encoded(f.checkpoint))
        expect(result,[.malformedInput])
    }
    @Test func b15AtomicInputsAndDeterministicDiagnostics() throws {
        var f = try fixture(complete:false)
        f.checkpoint = set(f.checkpoint,"registrySHA256",s(zero))
        let before = try C.make(.envelope,f.envelope).bytes
        let pinBefore = try C.make(.checkpoint,f.checkpoint).bytes, registryBefore = f.current
        for _ in 0..<2 { expect(try run(f),[.staleCheckpoint,.staleCheckpoint,.historyUnavailable]) }
        #expect(try C.make(.envelope,f.envelope).bytes == before)
        #expect(try C.make(.checkpoint,f.checkpoint).bytes == pinBefore); #expect(f.current == registryBefore)
    }

    private func reference(_ trip: Bool, _ attached: Bool = true) throws -> V {
        let sha = String(repeating:"1",count:64)
        let provenance = try SourceReference(inputSHA256:sha,member:.init(name:"invented.txt",sha256:sha),table:"invented",recordIndex:nil,field:"id",providerKey:ExactValue("e\u{301}")!)
        let ref = try ProviderReference(canonicalID:MintedIdentifier("stn_0000000000000001")!,sourceID:"invented",namespace:.gtfsStopID,value:ExactValue("e\u{301}")!,
            status:.absent,firstSeenInputSHA256:sha,provenance:provenance,
            originalNames:[.init(language:ExactValue("ja")!,value:ExactValue("e\u{301}")!,source:provenance)],attachedBy:attached ? "attachment-authority":nil)
        let v = try value(RailwayArtifact.encode(ref))
        return trip ? set(set(v,"canonicalID",s("trp_0000000000000001")),"namespace",s("gtfs.trip_id")) : v
    }
    private func seed(_ missing: Bool = false, conflict: Bool = false) throws -> (Fixture,[SyntheticTripRegistrationClosure.Entry]) {
        let ref = try reference(true)
        let registry = try C.make(.registry,.object(["schemaVersion":.integer(4),"revision":.integer(6),
            "entities":.array([.object(["id":s("trp_0000000000000001"),"state":s("active")])]),"references":.array([ref])])).bytes
        var f = try fixture(registry)
        let record = try C.make(.seedRecord,.object(["recordID":s("seed-attachment"),"kind":s("attachment"),"stipulated":s("synthetic"),
            "reference":conflict ? set(ref,"attachedBy",s("different-authority")) : ref,"authorityID":s("attachment-authority"),"dependencyDigests":.array([])]))
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv: V = .object(["attachmentRecordIDs":.array([s("seed-attachment")]),"statusRecordIDs":.array([]),"allocationIDs":.array([s("allocation-seed")]),
                             "reviewIDs":.array([s("attachment-authority")]),"selections":.array([])])
        let dependency: V = .object(["kind":s("seedRecord"),"id":s("seed-attachment"),"sha256":s(record.sha256)])
        let wrapped = wrapper("baseline","B",set(set(base,"seedInventory",inv),"dependencyDigests",.array([dependency])))
        let approved = V.object(["payload":wrapped,"approval":try approval(wrapped,"review-B")])
        let history = set(f.envelope["history"]!,"baselineSHA256",s(C.digest(try C.encoded(approved))))
        f.envelope = set(set(f.envelope,"baseline",approved),"history",history); f.checkpoint = try pin(f.current,history)
        try resign(&f,request("Q",f.current,history,target(f.current),"attach"))
        return (f,missing ? [] : [.init(kind:"seedRecord",id:"seed-attachment",document:record)])
    }
    @Test func b16StipulatedSeedDoesNotClaimExternalHistoryOrAdmission() throws {
        let (f,catalog) = try seed()
        let report = checked(try run(f,catalog:catalog))
        #expect(report?.stipulatedSeed == true); #expect(report?.businessAdmissionRequired == ["Q"])
    }
    @Test func b17MissingSeedRecordHolds() throws {
        let (f,catalog) = try seed(true)
        expect(try run(f,catalog:catalog),[.historyUnavailable,.historyUnavailable],held:true)
    }
    @Test func b18ContradictorySeedAndMissingCompletenessRejectTogether() throws {
        var (f,catalog) = try seed(false,conflict:true)
        let base = f.envelope["baseline"]!["payload"]!
        let wrapped = set(base,"payload",set(base["payload"]!,"historyComplete",.bool(false)))
        let approved = V.object(["payload":wrapped,"approval":try approval(wrapped,"review-B")])
        let history = set(f.envelope["history"]!,"baselineSHA256",s(C.digest(try C.encoded(approved))))
        f.envelope = set(set(f.envelope,"baseline",approved),"history",history); f.checkpoint = try pin(f.current,history)
        try resign(&f,request("Q",f.current,history,target(f.current),"attach"))
        expect(try run(f,catalog:catalog),[.historyConflict,.historyUnavailable])
    }
    @Test(arguments:[false,true]) func b19LegacyEveryFieldAndOptionalAuthorityPreserved(_ attached: Bool) throws {
        let ref = try reference(false,attached)
        let source: V = .object(["schemaVersion":.integer(2),"revision":.integer(8),"entities":.array([.object(["id":s("stn_0000000000000001"),"state":s("active")])]),"references":.array([ref])])
        // Noncanonical whitespace is legal to the original reader, and remains pinned exactly.
        let bytes = Data(" \n".utf8) + (try C.encoded(source,pretty:true)) + Data("\n".utf8)
        var f = try fixture(bytes)
        #expect(checked(try run(f)) != nil)
        try append(&f); #expect(checked(try run(f))?.unchangedReplay == true)
        #expect(Data(base64Encoded:f.envelope["history"]!["boundaries"]!.items[0]["previousRegistryBytes"]!.text!) == bytes)
        #expect(try value(f.current)["references"]!.items[0]["value"]!.text!.unicodeScalars.map(\.value) == [101,769])
        for field in ["originalNames","attachedBy","firstSeenInputSHA256","value","provenance","status"] {
            var altered = ref
            switch field {
            case "originalNames": altered = set(ref,field,.array([]))
            case "attachedBy": altered = set(ref,field,s("replacement-authority"))
            case "firstSeenInputSHA256": altered = set(ref,field,s(zero))
            case "value": altered = set(ref,field,s("é"))
            case "provenance": altered = set(ref,field,set(ref[field]!,"field",s("changed")))
            default: altered = set(ref,field,.object(["state":s("active")]))
            }
            var proposed = try fixture(bytes)
            let changedTarget = try C.make(.registry,set(value(target(bytes)),"references",.array([altered]))).bytes
            let q = set(proposed.envelope["request"]!,"payload",set(proposed.envelope["request"]!["payload"]!,"targetRegistryBytes",blob(changedTarget)))
            try resign(&proposed,q); expect(try run(proposed),[.historyConflict])
        }
    }
    @Test func b20HistoricalAuthorityCannotBeReallocated() throws {
        var (f,catalog) = try seed()
        let q = f.envelope["request"]!
        f.envelope = set(f.envelope,"approvals",.array([try approval(q,"attachment-authority")]))
        expect(try run(f,catalog:catalog),[.historyConflict])
    }
    @Test func b21RetainedNonTripFieldCannotChangeInBusinessBoundary() throws {
        let ref = try reference(false)
        let bytes = try C.encoded(.object(["schemaVersion":.integer(2),"revision":.integer(0),"entities":.array([.object(["id":s("stn_0000000000000001"),"state":s("active")])]),"references":.array([ref])]),pretty:true)
        var f = try fixture(bytes); try append(&f)
        let changed = try C.make(.registry,set(value(target(f.current)),"references",.array([]))).bytes
        try resign(&f,request("R",f.current,f.envelope["history"]!,changed,"attach"))
        expect(try run(f),[.historyConflict])
    }
    @Test func b22WrongAuthorityAndMissingCompleteness() throws {
        var f = try fixture(complete:false)
        let approval = set(f.envelope["approvals"]!.items[0],"reviewer",s("other-owner"))
        f.envelope = set(f.envelope,"approvals",.array([approval]))
        expect(try run(f),[.approvalConflict,.historyUnavailable])
    }
    @Test func b23TripBodyCannotCollideWithRetainedOtherKind() throws {
        var f = try fixture(); try append(&f)
        let registry = try C.make(.registry,.object(["schemaVersion":.integer(4),"revision":.integer(2),"references":.array([]),"entities":.array([
            .object(["id":s("stn_0000000000000001"),"state":s("active")]),.object(["id":s("trp_0000000000000001"),"state":s("active")])])])).bytes
        try resign(&f,request("R",f.current,f.envelope["history"]!,registry,"register"))
        expect(try run(f),[.historyConflict,.identityConflict])
    }
    @Test func b24SidecarUnsupportedSchemaAndUnknownFieldsRejected() throws {
        let (registry,history) = try legacyFixture()
        for altered in [set(try value(history),"schemaVersion",.integer(99)),set(try value(history),"unknown",s("invented"))] {
            expect(try run(fixture(registry,sidecar:C.encoded(altered))),[.historyConflict])
        }
    }
    @Test func b25WrongCatalogConstructionCannotBypassShapeSafety() throws {
        let (f,_) = try seed(true)
        let wrong = try C.make(.registry,value(empty(4)))
        let result = try run(f,catalog:[.init(kind:"seedRecord",id:"seed-attachment",document:wrong)])
        expect(result,[.malformedInput,.historyUnavailable,.historyUnavailable])
    }
    @Test func b26MissingProfileCannotHideBadHistoryLink() throws {
        var f = try fixture()
        let p = f.envelope["request"]!["payload"]!
        let changed = set(set(p,"profileIDs",.array([s("missing-profile")])),"dependencyDigests",.array([.object(["kind":s("profile"),"id":s("missing-profile"),"sha256":s(zero)])]))
        try resign(&f,set(f.envelope["request"]!,"payload",changed)); try append(&f)
        let h = f.envelope["history"]!, b = set(h["boundaries"]!.items[0],"previousBoundarySHA256",s(zero))
        let history = set(h,"boundaries",.array([b]))
        f.envelope = set(f.envelope,"history",history); f.checkpoint = try pin(f.current,history)
        let result = try run(f)
        expect(result,[.historyConflict,.historyUnavailable,.scopeUnavailable])
        if case .rejected(let ds) = result { #expect(ds.map(\.locator) == ["Q","Q","missing-profile"]) }
    }
    @Test func b27SecondBoundaryLinkAndExactPreviousBytes() throws {
        for field in ["previousBoundarySHA256","previousRegistryBytes"] {
            var f = try fixture(); try append(&f)
            try resign(&f,request("R",f.current,f.envelope["history"]!,target(f.current),"attach")); try append(&f)
            let h = f.envelope["history"]!, bs = h["boundaries"]!.items
            let bad = set(bs[1],field,field == "previousBoundarySHA256" ? s(zero) : blob(try empty(4,99)))
            let history = set(h,"boundaries",.array([bs[0],bad]))
            f.envelope = set(f.envelope,"history",history); f.checkpoint = try pin(f.current,history)
            expect(try run(f),[.historyConflict])
        }
    }
    @Test func b28BaselineApprovalBindsOriginalBytes() throws {
        var f = try fixture()
        let approved = f.envelope["baseline"]!, w = approved["payload"]!
        let payload = set(w["payload"]!,"registryBytes",blob(Data(" ".utf8) + f.current))
        f.envelope = set(f.envelope,"baseline",set(approved,"payload",set(w,"payload",payload)))
        let result = try run(f)
        guard case .rejected(let ds) = result else { Issue.record("Expected changed baseline rejection"); return }
        #expect(ds.contains { $0.issue == .approvalConflict }); #expect(ds.contains { $0.issue == .historyConflict })
    }
    @Test func b29LegacyConversionDoesNotAddRetrospectiveMintingRules() throws {
        let bytes = try C.encoded(.object(["schemaVersion":.integer(2),"revision":.integer(0),"references":.array([]),"entities":.array([
            .object(["id":s("stn_0000000000000001"),"state":s("active")]),.object(["id":s("lin_0000000000000001"),"state":s("active")])])]),pretty:true)
        // The legacy reader accepts this supplied registry; conversion preserves it.
        #expect(throws:Never.self) { _ = try MappingRegistry.decoded(from:bytes) }
        #expect(checked(try run(fixture(bytes))) != nil)
    }
    @Test func b30NoGeneralSchema4LineageReset() throws {
        expect(try run(fixture(empty(4))),[.blockedOperation])
    }
    @Test(arguments:["valid","missing","wrongDigest","cycle"])
    func b31SeedPredecessorChain(_ mode: String) throws {
        var (f,catalog) = try seed()
        let attachment = catalog[0].document
        let current = attachment.value["reference"]!
        let original = try C.make(.seedRecord,set(attachment.value,"reference",set(current,"status",.object(["state":s("active")]))))
        let status = try C.make(.seedRecord,.object(["recordID":s("seed-status"),"kind":s("status"),"stipulated":s("synthetic"),"reference":current,
            "authorityID":s("status-authority"),"predecessorRecordID":s(mode == "cycle" ? "seed-status":"seed-attachment"),
            "predecessorRecordSHA256":s(mode == "wrongDigest" || mode == "cycle" ? zero : original.sha256),"dependencyDigests":.array([])]))
        catalog = [.init(kind:"seedRecord",id:"seed-status",document:status)]
        if mode != "missing" { catalog.append(.init(kind:"seedRecord",id:"seed-attachment",document:original)) }
        let base = f.envelope["baseline"]!["payload"]!["payload"]!, inv = base["seedInventory"]!
        let inventory = set(set(inv,"statusRecordIDs",.array([s("seed-status")])),"reviewIDs",.array([s("attachment-authority"),s("status-authority")]))
        let deps: [V] = [("seed-attachment",original),("seed-status",status)].map { id,doc in .object(["kind":s("seedRecord"),"id":s(id),"sha256":s(doc.sha256)]) }
        let w = wrapper("baseline","B",set(set(base,"seedInventory",inventory),"dependencyDigests",.array(deps)))
        let approved = V.object(["payload":w,"approval":try approval(w,"review-B")])
        let history = set(f.envelope["history"]!,"baselineSHA256",s(C.digest(try C.encoded(approved))))
        f.envelope = set(set(f.envelope,"baseline",approved),"history",history); f.checkpoint = try pin(f.current,history)
        try resign(&f,request("Q",f.current,history,target(f.current),"attach"))
        let result = try run(f,catalog:catalog)
        switch mode {
        case "valid": #expect(checked(result)?.stipulatedSeed == true)
        case "missing": expect(result,[.historyUnavailable],held:true)
        case "wrongDigest": expect(result,[.historyConflict,.historyConflict],locators:["seed-attachment","seed-status"])
        default: expect(result,[.historyConflict,.historyConflict])
        }
    }
    @Test func b32Schema3BridgePreservesRetainedHistoryBytes() throws {
        let (bytes,history) = try legacyFixture()
        let current = try C.encoded(set(value(bytes),"revision",.integer(8)),pretty:true)
        var f = try fixture(current,sidecar:history); try append(&f)
        #expect(checked(try run(f))?.unchangedReplay == true)
        #expect(Data(base64Encoded:f.envelope["baseline"]!["payload"]!["payload"]!["legacyHistoryBytes"]!.text!) == history)
    }
    @Test func b33SameRequestIDCannotAddAnotherBoundary() throws {
        var f = try fixture(); try append(&f)
        try resign(&f,request("Q",f.current,f.envelope["history"]!,target(f.current),"attach")); try append(&f)
        expect(try run(f),[.historyConflict,.historyConflict])
    }

    private func rebase(_ f: inout Fixture, _ payload: V, reviewID: String = "review-B", subjectID: String = "B") throws {
        // New invented fixture root only; no tested history is rewritten by the validator.
        #expect(f.envelope["history"]!["boundaries"]!.items.isEmpty)
        let wrapped = try C.make(.payload,wrapper("baseline",subjectID,payload)).value
        let approved = V.object(["payload":wrapped,"approval":try approval(wrapped,reviewID)])
        let history = set(f.envelope["history"]!,"baselineSHA256",s(C.digest(try C.encoded(approved))))
        f.envelope = set(set(f.envelope,"baseline",approved),"history",history)
        f.current = Data(base64Encoded:payload["registryBytes"]!.text!)!
        f.checkpoint = try pin(f.current,history)
        let operation = f.envelope["request"]!["payload"]!["operation"]!.text!
        try resign(&f,request("Q",f.current,history,target(f.current),operation))
    }
    private func legacyReferences(_ refs: [V]) throws -> Data {
        try C.encoded(.object(["schemaVersion":.integer(2),"revision":.integer(8),
            "entities":.array([.object(["id":s("stn_0000000000000001"),"state":s("active")])]),"references":.array(refs)]),pretty:true)
    }
    @Test(arguments:["attachedBy","retirement"],[true,false])
    func b34LegacyAuthorityCannotBecomeBaselineApproval(_ field: String, _ complete: Bool) throws {
        let old = try reference(false)
        let ref = field == "attachedBy" ? set(old,"attachedBy",s("review-B")) :
            set(old,"status",.object(["state":s("retired"),"review":s("review-B")]))
        let f = try fixture(legacyReferences([ref]),complete:complete)
        expect(try run(f),complete ? [.historyConflict] : [.historyConflict,.historyUnavailable],
               locators:complete ? ["review-B"] : ["review-B","baseline"])
    }
    @Test(arguments:[false,true]) func b35RepeatedRetainedAuthorityAssociationsAreLegal(_ inventoryQuote: Bool) throws {
        let first = set(try reference(false),"status",.object(["state":s("retired"),"review":s("old-retirement")]))
        let second = set(first,"value",s("another invented reference"))
        var f = try fixture(legacyReferences([first,second]))
        if inventoryQuote {
            let base = f.envelope["baseline"]!["payload"]!["payload"]!
            let inv = set(base["seedInventory"]!,"reviewIDs",.array([s("attachment-authority"),s("old-retirement")]))
            try rebase(&f,set(base,"seedInventory",inv))
        }
        #expect(checked(try run(f))?.conversionOnly == true)
        // The same historical IDs are discovered before this incoming fresh approval.
        f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,"attachment-authority")]))
        expect(try run(f),[.historyConflict],locators:["attachment-authority"])
    }
    @Test(arguments:[false,true]) func b36LegacySidecarAuthorityAssociationAndFreshCollision(_ collision: Bool) throws {
        let (registry,sidecar) = try legacyFixture()
        var f = try fixture(registry,sidecar:sidecar)
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(base["seedInventory"]!,"reviewIDs",.array([s("legacy-transition")]))
        try rebase(&f,set(base,"seedInventory",inv),reviewID:collision ? "legacy-transition":"review-B")
        if collision { expect(try run(f),[.historyConflict],locators:["legacy-transition"]) }
        else { #expect(checked(try run(f))?.conversionOnly == true) }
    }
    @Test(arguments:[false,true]) func b37KnownSeedAuthorityCannotHideBehindMissingInventory(_ missingRecord: Bool) throws {
        var (f,catalog) = try seed(missingRecord)
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(base["seedInventory"]!,"reviewIDs",.array([]))
        try rebase(&f,set(base,"seedInventory",inv),reviewID:"attachment-authority")
        expect(try run(f,catalog:catalog),missingRecord ? [.historyConflict,.historyUnavailable,.historyUnavailable] : [.historyConflict,.historyUnavailable],
               locators:missingRecord ? ["attachment-authority","baseline","seed-attachment"] : ["attachment-authority","seed-attachment"])
    }
    private func seedSelection(_ selectedID: String, missingArtifact: Bool) throws -> (Fixture,[SyntheticTripRegistrationClosure.Entry]) {
        var (f,catalog) = try seed()
        let registry = try value(f.current)
        let entities = registry["entities"]!.items + [
            V.object(["id":s("stn_0000000000000002"),"state":s("active")]),
            V.object(["id":s("lin_0000000000000003"),"state":s("active")])]
        let bytes = try C.make(.registry,set(registry,"entities",.array(entities))).bytes
        func uuid(_ n: Int) -> UUID { UUID(uuidString:String(format:"00000000-0000-0000-0000-%012x",n))! }
        let view = SyntheticTripReviewView(sourceRevision:uuid(1),mappingRevision:uuid(2),profileRevision:uuid(3),reviewRevision:uuid(4))
        // Deliberately no C evidence admission: these complete wire inputs only assert an identity.
        let run = SyntheticTripReviewRun(reference:uuid(5),view:view,
            positions:[.init(reference:uuid(6),order:1,classification:.unknown),.init(reference:uuid(7),order:2,classification:.unknown)],
            first:uuid(6),last:uuid(7),intervalEvidence:nil,identity:.reviewed(TripID(selectedID)!,evidence:nil),continuityEvidence:nil,
            origin:.unknownExtent,destination:.unknownExtent,movements:[],prior:nil)
        let packet = try SyntheticTripRegistrationS9Codec.encode(.init(view:view,evidenceReferences:[],runs:[run]))
        let artifact = try C.make(.s9Artifact,.object(["schemaVersion":.integer(1),"artifactID":s("selection-artifact"),
            "packetBytes":blob(packet.bytes),"packetSHA256":s(packet.sha256),"selectedRunReference":s(uuid(5).uuidString.lowercased()),
            "proofBindings":.array([]),"viewBindings":.array([]),"dependencyDigests":.array([])]))
        if !missingArtifact { catalog.append(.init(kind:"s9Artifact",id:"selection-artifact",document:artifact)) }
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(base["seedInventory"]!,"selections",.array([.object(["tripID":s(selectedID),"artifactID":s("selection-artifact")])]))
        let deps = base["dependencyDigests"]!.items + [.object(["kind":s("s9Artifact"),"id":s("selection-artifact"),"sha256":s(artifact.sha256)])]
        let updated = set(set(set(set(base,"registryBytes",blob(bytes)),"registrySHA256",s(C.digest(bytes))),"seedInventory",inv),"dependencyDigests",.array(deps))
        try rebase(&f,updated)
        return (f,catalog)
    }
    @Test(arguments:["stn_0000000000000002","lin_0000000000000003","trp_0000000000000009","trp_0000000000000001"],[false,true])
    func b38SeedSelectionRequiresHeldTripBeforeArtifactAvailability(_ selectedID: String, _ missingArtifact: Bool) throws {
        let (f,catalog) = try seedSelection(selectedID,missingArtifact:missingArtifact)
        let result = try run(f,catalog:catalog), validTarget = selectedID == "trp_0000000000000001"
        if validTarget && !missingArtifact {
            let report = checked(result)
            #expect(report?.stipulatedSeed == true); #expect(report?.businessAdmissionRequired == ["Q"])
        } else {
            let expected: [SyntheticRegistrationIssue] = (validTarget ? [] : [.historyConflict]) + (missingArtifact ? [.historyUnavailable,.snapshotUnavailable] : [])
            expect(result,expected,held:validTarget,locators:Array(repeating:"selection-artifact",count:expected.count))
        }
    }
    @Test(arguments:[false,true]) func b39RetainedProfileApprovalQuoteIsNotLegacyAuthorityReuse(_ collision: Bool) throws {
        var (f,catalog) = try seed()
        let reviewID = collision ? "attachment-authority":"review-profile"
        let p = try C.make(.payload,wrapper("profile","P",.object(["profileID":s("P"),"version":s("1"),"sourceID":s("invented"),
            "publisherScope":s("invented"),"resourceScope":s("invented"),"feedScope":s("invented"),"namespace":s("gtfs.trip_id"),
            "applicableInputSHA256s":.array([]),"uniquenessEvidenceIDs":.array([]),"meaningEvidenceIDs":.array([]),
            "continuityEvidenceIDs":.array([]),"dependencyDigests":.array([])])))
        let profile = try C.make(.approved,.object(["payload":p.value,"approval":try approval(p.value,reviewID)]))
        let dep: V = .object(["kind":s("profile"),"id":s("P"),"sha256":s(profile.sha256)])
        let record = try C.make(.seedRecord,set(catalog[0].document.value,"dependencyDigests",.array([dep])))
        catalog = [.init(kind:"seedRecord",id:"seed-attachment",document:record),.init(kind:"profile",id:"P",document:profile)]
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let quotes = collision ? [s("attachment-authority")] : [s("attachment-authority"),s(reviewID)]
        let inv = set(base["seedInventory"]!,"reviewIDs",.array(quotes))
        let deps: [V] = [dep,.object(["kind":s("seedRecord"),"id":s("seed-attachment"),"sha256":s(record.sha256)])]
        try rebase(&f,set(set(base,"seedInventory",inv),"dependencyDigests",.array(deps)))
        if collision { expect(try run(f,catalog:catalog),[.historyConflict],locators:["attachment-authority"]) }
        else { #expect(checked(try run(f,catalog:catalog))?.businessAdmissionRequired == ["Q"]) }
    }

    @Test(arguments:["attachedBy","retirement"],[true,false])
    func b40BaselineRecordCannotReuseLegacyAuthority(_ field: String, _ complete: Bool) throws {
        let old = try reference(false)
        let ref = field == "attachedBy" ? set(old,"attachedBy",s("B")) :
            set(old,"status",.object(["state":s("retired"),"review":s("B")]))
        // Repeated historical quotations remain associations; the new baseline B is the collision.
        let f = try fixture(legacyReferences([ref,set(ref,"value",s("another invented reference"))]),complete:complete)
        expect(try run(f),complete ? [.historyConflict] : [.historyConflict,.historyUnavailable],
               locators:complete ? ["B"] : ["B","baseline"])
    }
    private func evidence(_ id: String) throws -> SyntheticRegistrationDocument {
        let view = V.object(Dictionary(uniqueKeysWithValues: SyntheticRegistrationSchema.components.enumerated().map {
            ($0.element,s(String(format:"00000000-0000-0000-0000-%012x",$0.offset+1)))
        }))
        return try C.make(.evidence,.object(["evidenceID":s(id),"sha256":s(zero),"locator":s("invented"),"role":s("identity"),
            "profileID":s("P"),"profileVersion":s("1"),"inputSHA256s":.array([]),"view":view,"referenceKeys":.array([]),
            "tripIDs":.array([]),"recordIDs":.array([]),"artifactIDs":.array([]),"disposition":s("supports"),
            "applicability":.array([]),"viewApplicability":.array([])]))
    }
    private func profile(_ id: String, reviewID: String) throws -> SyntheticRegistrationDocument {
        let p = try C.make(.payload,wrapper("profile",id,.object(["profileID":s(id),"version":s("1"),"sourceID":s("invented"),
            "publisherScope":s("invented"),"resourceScope":s("invented"),"feedScope":s("invented"),"namespace":s("gtfs.trip_id"),
            "applicableInputSHA256s":.array([]),"uniquenessEvidenceIDs":.array([]),"meaningEvidenceIDs":.array([]),
            "continuityEvidenceIDs":.array([]),"dependencyDigests":.array([])])))
        return try C.make(.approved,.object(["payload":p.value,"approval":try approval(p.value,reviewID)]))
    }
    private func dependency(_ kind: String, _ id: String, _ doc: SyntheticRegistrationDocument) -> V {
        .object(["kind":s(kind),"id":s(id),"sha256":s(doc.sha256)])
    }
    private func bind(_ f: inout Fixture, _ kind: String, _ id: String, _ doc: SyntheticRegistrationDocument) throws {
        let q = f.envelope["request"]!, p = q["payload"]!
        let field = kind == "profile" ? "profileIDs" : kind == "evidence" ? "evidenceIDs" : "s9ArtifactIDs"
        try resign(&f,set(q,"payload",set(set(p,field,.array([s(id)])),"dependencyDigests",.array([dependency(kind,id,doc)]))))
    }
    private func appendWithDependencies(_ f: inout Fixture, _ entries: [SyntheticTripRegistrationClosure.Entry]) throws {
        try append(&f)
        let h = f.envelope["history"]!, b = h["boundaries"]!.items[0]
        let retained: [V] = entries.map { .object(["kind":s($0.kind),"id":s($0.id),"bytes":blob($0.document.bytes)]) }
        let history = set(h,"boundaries",.array([set(b,"dependencies",.array(retained))]))
        f.envelope = set(f.envelope,"history",history); f.checkpoint = try pin(f.current,history)
    }
    @Test(arguments:["inline","catalog","both","retained"],["valid","collision","incomplete","collisionIncomplete"])
    func b41EvidenceTransportCannotBypassHistoricalAuthority(_ transport: String, _ mode: String) throws {
        var (f,catalog) = try seed()
        let collision = mode.hasPrefix("collision"), complete = !mode.lowercased().contains("incomplete")
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        try rebase(&f,set(base,"historyComplete",.bool(complete)))
        let id = collision ? "attachment-authority" : "new-evidence", doc = try evidence(id)
        let entry = SyntheticTripRegistrationClosure.Entry(kind:"evidence",id:id,document:doc)
        try bind(&f,"evidence",id,doc)
        if transport == "inline" || transport == "both" { f.envelope = set(f.envelope,"evidence",.array([doc.value])) }
        if transport == "catalog" || transport == "both" { catalog.append(entry) }
        if transport == "retained" { try appendWithDependencies(&f,[entry]) }
        let before = try C.make(.envelope,f.envelope).bytes, current = f.current, checkpoint = try C.make(.checkpoint,f.checkpoint).bytes
        let result = try run(f,catalog:catalog)
        if collision || !complete {
            expect(result,(collision ? [.historyConflict] : []) + (complete ? [] : [.historyUnavailable]),held:!collision,
                   locators:(collision ? [id] : []) + (complete ? [] : ["baseline"]))
        } else {
            let report = checked(result)
            #expect(report?.businessAdmissionRequired == ["Q"]); #expect(report?.unchangedReplay == (transport == "retained"))
        }
        #expect(try C.make(.envelope,f.envelope).bytes == before); #expect(f.current == current)
        #expect(try C.make(.checkpoint,f.checkpoint).bytes == checkpoint)
    }
    @Test(arguments:["baseline","approval","request","record","allocation","evidence","profile","profileApproval","artifact"],[false,true])
    func b42MissingHistoricalRecordStillOccupiesItsID(_ introduction: String, _ retained: Bool) throws {
        let initial = try seed(true)
        var f = initial.0
        let catalog = initial.1
        let id = "seed-attachment"
        var deps: [SyntheticTripRegistrationClosure.Entry] = []
        switch introduction {
        case "baseline": try rebase(&f,f.envelope["baseline"]!["payload"]!["payload"]!,subjectID:id)
        case "approval": f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,id)]))
        case "request":
            let q = f.envelope["request"]!
            try resign(&f,set(set(q,"subjectID",s(id)),"payload",set(q["payload"]!,"requestID",s(id))))
        case "record","allocation":
            let record = V.object(["recordID":s(introduction == "record" ? id : "new-record"),
                "allocationRequestID":s(introduction == "allocation" ? id : "new-allocation"),"tripID":s("trp_0000000000000002"),
                "referenceKeys":.array([]),"correspondenceEvidenceIDs":.array([])])
            let q = f.envelope["request"]!
            // B checks identifiers only; these records still require C's complete delta/admission checks.
            try resign(&f,set(q,"payload",set(set(q["payload"]!,"operation",s("register")),"records",.array([record]))))
        default:
            let kind: String, doc: SyntheticRegistrationDocument, documentID: String, field: String
            if introduction == "evidence" {
                kind = "evidence"; documentID = id; field = "evidence"; doc = try evidence(id)
            } else if introduction == "artifact" {
                kind = "s9Artifact"; documentID = id; field = "s9Artifacts"
                let (_,artifacts) = try seedSelection("trp_0000000000000001",missingArtifact:false)
                doc = try C.make(.s9Artifact,set(artifacts.last!.document.value,"artifactID",s(id)))
            } else {
                kind = "profile"; documentID = introduction == "profile" ? id : "P"; field = "profiles"
                doc = try profile(documentID,reviewID:introduction == "profileApproval" ? id : "review-profile")
            }
            try bind(&f,kind,documentID,doc)
            f.envelope = set(f.envelope,field,.array([doc.value]))
            deps = [.init(kind:kind,id:documentID,document:doc)]
        }
        if retained {
            try appendWithDependencies(&f,deps)
            for field in ["profiles","evidence","s9Artifacts"] { f.envelope = set(f.envelope,field,.array([])) }
        }
        expect(try run(f,catalog:catalog),[.historyConflict,.historyUnavailable,.historyUnavailable],
               locators:[id,"baseline",id])
    }
    @Test(arguments:[false,true]) func b43UnlistedSuppliedSeedRecordAlsoReservesItsID(_ collision: Bool) throws {
        let initial = try seed()
        let f = initial.0
        var catalog = initial.1
        let id = collision ? "attachment-authority" : "extra-record"
        let extra = try C.make(.seedRecord,set(catalog[0].document.value,"recordID",s(id)))
        // Extra supplied bytes do not establish lineage membership, but their immutable ID is not exempt.
        catalog.append(.init(kind:"seedRecord",id:id,document:extra))
        if collision { expect(try run(f,catalog:catalog),[.historyConflict],locators:[id]) }
        else { #expect(checked(try run(f,catalog:catalog))?.businessAdmissionRequired == ["Q"]) }
    }
    @Test(arguments:[false,true]) func b44MissingSeedPredecessorCannotBeReintroduced(_ collision: Bool) throws {
        var (f,catalog) = try seed()
        let prior = catalog[0].document, id = "seed-attachment"
        let status = try C.make(.seedRecord,.object(["recordID":s("seed-status"),"kind":s("status"),"stipulated":s("synthetic"),
            "reference":prior.value["reference"]!,"authorityID":s("status-authority"),"predecessorRecordID":s(id),
            "predecessorRecordSHA256":s(prior.sha256),"dependencyDigests":.array([])]))
        catalog = [.init(kind:"seedRecord",id:"seed-status",document:status)]
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(set(set(base["seedInventory"]!,"attachmentRecordIDs",.array([])),"statusRecordIDs",.array([s("seed-status")])),
                      "reviewIDs",.array([s("attachment-authority"),s("status-authority")]))
        try rebase(&f,set(set(base,"seedInventory",inv),"dependencyDigests",.array([dependency("seedRecord","seed-status",status)])))
        if collision { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,id)])) }
        expect(try run(f,catalog:catalog),collision ? [.historyConflict,.historyUnavailable] : [.historyUnavailable],
               held:!collision,locators:collision ? [id,id] : [id])
    }
    @Test(arguments:[false,true],[false,true])
    func b45SelectedArtifactIdentitySurvivesMissingBytes(_ missing: Bool, _ collision: Bool) throws {
        var (f,catalog) = try seedSelection("trp_0000000000000001",missingArtifact:missing)
        let id = "selection-artifact"
        if collision { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,id)])) }
        let result = try run(f,catalog:catalog)
        if collision || missing {
            let issues: [SyntheticRegistrationIssue] = (collision ? [.historyConflict] : []) + (missing ? [.historyUnavailable,.snapshotUnavailable] : [])
            expect(result,issues,held:!collision,locators:Array(repeating:id,count:issues.count))
        } else { #expect(checked(result)?.businessAdmissionRequired == ["Q"]) }
    }
    private func missingDependency(_ kind: String) throws -> (Fixture,[SyntheticTripRegistrationClosure.Entry]) {
        var (f,catalog) = try seed()
        let dep = V.object(["kind":s(kind),"id":s("dependency"),"sha256":s(zero)])
        let seed = try C.make(.seedRecord,set(catalog[0].document.value,"dependencyDigests",.array([dep])))
        catalog = [.init(kind:"seedRecord",id:"seed-attachment",document:seed)]
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        try rebase(&f,set(base,"dependencyDigests",.array([dep,dependency("seedRecord","seed-attachment",seed)])))
        return (f,catalog)
    }
    private func missingIssue(_ kind: String) -> SyntheticRegistrationIssue {
        kind == "evidence" ? .correspondenceUnavailable : kind == "profile" ? .scopeUnavailable :
            kind == "s9Artifact" ? .snapshotUnavailable : .historyUnavailable
    }
    @Test(arguments:["evidence","profile","s9Artifact","seedRecord"],[false,true])
    func b46MissingBaselineDependencyIdentityIsRetained(_ kind: String, _ collision: Bool) throws {
        var (f,catalog) = try missingDependency(kind)
        if collision { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,"dependency")])) }
        let issues: [SyntheticRegistrationIssue] = (collision ? [.historyConflict] : []) + [missingIssue(kind)]
        expect(try run(f,catalog:catalog),issues,held:!collision,locators:Array(repeating:"dependency",count:issues.count))
    }
    @Test(arguments:["evidence","profile","s9Artifact"],[false,true])
    func b47MissingRetainedBoundaryDependencyIdentityIsRetained(_ kind: String, _ collision: Bool) throws {
        var f = try fixture()
        let field = kind == "profile" ? "profileIDs" : kind == "evidence" ? "evidenceIDs" : "s9ArtifactIDs"
        let q = f.envelope["request"]!, dep = V.object(["kind":s(kind),"id":s("dependency"),"sha256":s(zero)])
        try resign(&f,set(q,"payload",set(set(q["payload"]!,field,.array([s("dependency")])),"dependencyDigests",.array([dep]))))
        try append(&f)
        try resign(&f,request("R",f.current,f.envelope["history"]!,target(f.current),"attach"))
        if collision { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,"dependency")])) }
        let issues: [SyntheticRegistrationIssue] = (collision ? [.historyConflict] : []) + [.historyUnavailable,missingIssue(kind)]
        expect(try run(f),issues,held:!collision,locators:(collision ? ["dependency"] : []) + ["Q","dependency"])
    }
    @Test(arguments:[false,true]) func b48RetainedDependencyDigestCannotChangeWhileBytesAreMissing(_ changed: Bool) throws {
        var (f,catalog) = try missingDependency("evidence")
        let q = f.envelope["request"]!
        let dep = V.object(["kind":s("evidence"),"id":s("dependency"),"sha256":s(changed ? String(repeating:"1",count:64) : zero)])
        try resign(&f,set(q,"payload",set(set(q["payload"]!,"evidenceIDs",.array([s("dependency")])),"dependencyDigests",.array([dep]))))
        expect(try run(f,catalog:catalog),changed ? [.historyConflict,.correspondenceUnavailable] : [.correspondenceUnavailable],
               held:!changed,locators:changed ? ["dependency","dependency"] : ["dependency"])
    }
    @Test(arguments:["control","collision","changedDigest"])
    func b49NestedRetainedDependencySurvivesMissingOuterEntry(_ mode: String) throws {
        var (f,catalog) = try missingDependency("evidence")
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        try rebase(&f,set(base,"dependencyDigests",.array([dependency("seedRecord","seed-attachment",catalog[0].document)])))
        let q = f.envelope["request"]!
        if mode == "collision" { f.envelope = set(f.envelope,"approvals",.array([try approval(q,"dependency")])) }
        if mode == "changedDigest" {
            let dep = V.object(["kind":s("evidence"),"id":s("dependency"),"sha256":s(String(repeating:"1",count:64))])
            try resign(&f,set(q,"payload",set(set(q["payload"]!,"evidenceIDs",.array([s("dependency")])),"dependencyDigests",.array([dep]))))
        }
        expect(try run(f,catalog:catalog),mode == "control" ? [.correspondenceUnavailable] : [.historyConflict,.correspondenceUnavailable],
               held:mode == "control",locators:mode == "control" ? ["dependency"] : ["dependency","dependency"])
    }
    @Test(arguments:[false,true]) func b50NestedRetainedProfileApprovalIsStillAnAssociation(_ missingOuterEntry: Bool) throws {
        var (f,catalog) = try seed()
        let profile = try profile("P",reviewID:"review-profile"), dep = dependency("profile","P",profile)
        let record = try C.make(.seedRecord,set(catalog[0].document.value,"dependencyDigests",.array([dep])))
        catalog = [.init(kind:"seedRecord",id:"seed-attachment",document:record),.init(kind:"profile",id:"P",document:profile)]
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(base["seedInventory"]!,"reviewIDs",.array([s("attachment-authority"),s("review-profile")]))
        let deps = [dependency("seedRecord","seed-attachment",record)] + (missingOuterEntry ? [] : [dep])
        try rebase(&f,set(set(base,"seedInventory",inv),"dependencyDigests",.array(deps)))
        if missingOuterEntry { expect(try run(f,catalog:catalog),[.scopeUnavailable],held:true,locators:["P"]) }
        else { #expect(checked(try run(f,catalog:catalog))?.businessAdmissionRequired == ["Q"]) }
    }
    @Test(arguments:["valid","freshApproval","incomplete","conflictIncomplete"],0..<4)
    func b51SharedSeedAuthorityIsAnAssociation(_ mode: String, _ order: Int) throws {
        var (f,catalog) = try seed()
        let first = catalog[0].document, ref = set(first.value["reference"]!,"value",s("second invented key"))
        let second = try C.make(.seedRecord,set(set(first.value,"recordID",s("second-attachment")),"reference",ref))
        let records = order & 1 == 0 ? [first,second] : [second,first]
        let current = try C.make(.registry,set(value(f.current),"references",.array(records.map { $0.value["reference"]! }))).bytes
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(base["seedInventory"]!,"attachmentRecordIDs",.array(records.map { $0.value["recordID"]! }))
        let complete = !mode.lowercased().contains("incomplete"), conflict = mode == "freshApproval" || mode == "conflictIncomplete"
        let updated = set(set(set(set(set(base,"seedInventory",inv),"registryBytes",blob(current)),"registrySHA256",s(C.digest(current))),
            "historyComplete",.bool(complete)),"dependencyDigests",.array(records.map { dependency("seedRecord",$0.value["recordID"]!.text!,$0) }))
        try rebase(&f,updated)
        catalog = records.map { .init(kind:"seedRecord",id:$0.value["recordID"]!.text!,document:$0) }
        if order & 2 != 0 { catalog.reverse() }
        if conflict { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,"attachment-authority")])) }
        let result = try run(f,catalog:catalog)
        if conflict || !complete {
            expect(result,(conflict ? [.historyConflict] : []) + (complete ? [] : [.historyUnavailable]),held:!conflict,
                   locators:(conflict ? ["attachment-authority"] : []) + (complete ? [] : ["baseline"]))
        } else { #expect(checked(result)?.businessAdmissionRequired == ["Q"]) }
    }
    private func objectOrder(_ v: V, reversed: Bool) -> V {
        switch v {
        case .object(let fields):
            let keys = fields.keys.sorted(), order = reversed ? Array(keys.reversed()) : keys
            var result: [String:V] = [:]
            for key in order { result[key] = objectOrder(fields[key]!,reversed:reversed) }
            return .object(result)
        case .array(let values): return .array(values.map { objectOrder($0,reversed:reversed) })
        default: return v
        }
    }
    @Test(arguments:["inline","catalog","both"],["conflict","equivalent","conflictIncomplete","equivalentIncomplete"])
    func b52ProfileVariantsPreserveEveryIndependentConflict(_ transport: String, _ mode: String) throws {
        let conflict = mode.hasPrefix("conflict"), complete = !mode.hasSuffix("Incomplete")
        for order in 0..<4 {
            var f = try fixture(legacyReferences([reference(false)]),complete:complete)
            // Swap which transport's approval collides: neither an inline nor a retained copy wins.
            let old = try profile("P",reviewID:conflict && order & 1 != 0 ? "attachment-authority" : "review-old")
            let new = conflict ? try profile("P",reviewID:order & 1 == 0 ? "attachment-authority" : "review-new") : old
            try bind(&f,"profile","P",old)
            try appendWithDependencies(&f,[.init(kind:"profile",id:"P",document:old)])
            try resign(&f,request("R",f.current,f.envelope["history"]!,target(f.current),"attach"))
            try bind(&f,"profile","P",new)
            var catalog: [SyntheticTripRegistrationClosure.Entry] = [.init(kind:"evidence",id:"unrelated",document:try evidence("unrelated"))]
            if transport != "catalog" { f.envelope = set(f.envelope,"profiles",.array([new.value])) }
            if transport != "inline" { catalog.append(.init(kind:"profile",id:"P",document:new)) }
            if order & 2 != 0 { catalog.reverse() }
            f.envelope = objectOrder(f.envelope,reversed:order & 2 != 0)
            let before = try C.make(.envelope,f.envelope).bytes, current = f.current
            let result = try run(f,catalog:catalog)
            if conflict || !complete {
                expect(result,(conflict ? [.historyConflict,.historyConflict] : []) + (complete ? [] : [.historyUnavailable]),held:!conflict,
                       locators:(conflict ? ["P","attachment-authority"] : []) + (complete ? [] : ["baseline"]))
            } else { #expect(checked(result)?.businessAdmissionRequired == ["R"]) }
            #expect(try C.make(.envelope,f.envelope).bytes == before); #expect(f.current == current)
        }
    }
    @Test(arguments:[false,true]) func b53ConflictingSeedVariantDoesNotReplaceDigestBoundHistory(_ reversed: Bool) throws {
        var (f,catalog) = try seed()
        let held = catalog[0].document
        let other = try C.make(.seedRecord,set(set(held.value,"authorityID",s("review-B")),"reference",
            set(held.value["reference"]!,"attachedBy",s("review-B"))))
        // Only held is baseline-bound; the other copy's authority label is not historical truth.
        catalog.append(.init(kind:"seedRecord",id:"seed-attachment",document:other))
        if reversed { catalog.reverse() }
        f.envelope = objectOrder(f.envelope,reversed:reversed)
        expect(try run(f,catalog:catalog),[.historyConflict],locators:["seed-attachment"])
    }
    @Test(arguments:[false,true]) func b54IdenticalCatalogDuplicatesRemainInvalid(_ reversed: Bool) throws {
        let (f,entries) = try seed()
        var catalog = entries + entries + [.init(kind:"evidence",id:"unrelated",document:try evidence("unrelated"))]
        if reversed { catalog.reverse() }
        expect(try run(f,catalog:catalog),[.historyConflict],locators:["seed-attachment"])
    }
    @Test(arguments:[false,true]) func b55ProfileCatalogIdentityMismatchRemainsMalformed(_ reversed: Bool) throws {
        let (f,entries) = try seed()
        let p = try profile("P",reviewID:"review-P"), wrapper = p.value["payload"]!
        let bad = try C.make(.approved,set(p.value,"payload",set(wrapper,"payload",set(wrapper["payload"]!,"profileID",s("different")))))
        var catalog = entries + [.init(kind:"profile",id:"P",document:bad)]
        if reversed { catalog.reverse() }
        expect(try run(f,catalog:catalog),[.malformedInput],locators:["catalog"])
    }
    @Test(arguments:["seedRecord","s9Artifact"],[false,true])
    func b56ConflictingVariantCannotHideDependencyCycle(_ kind: String, _ reversed: Bool) throws {
        let (f,held) = try seedSelection("trp_0000000000000001",missingArtifact:false)
        let template = held.first { $0.kind == kind }!.document
        let format: SyntheticRegistrationFormat = kind == "seedRecord" ? .seedRecord : .s9Artifact
        let idKey = kind == "seedRecord" ? "recordID" : "artifactID"
        let s0 = try C.make(format,set(template.value,idKey,s("S")))
        let d = try C.make(format,set(set(template.value,idKey,s("D")),"dependencyDigests",.array([dependency(kind,"S",s0)])))
        // Digests are constructed acyclically, but changed S content cannot hide the ID cycle.
        let s1 = try C.make(format,set(s0.value,"dependencyDigests",.array([dependency(kind,"D",d),dependency(kind,"S",s0)])))
        var catalog = held + [.init(kind:kind,id:"S",document:s0),.init(kind:kind,id:"S",document:s1),.init(kind:kind,id:"D",document:d)]
        if reversed { catalog.reverse() }
        expect(try run(f,catalog:catalog),[.historyConflict,.historyConflict] + (kind == "s9Artifact" ? [.snapshotConflict,.snapshotConflict] : []),
               locators:kind == "s9Artifact" ? ["D","S","D","S"] : ["D","S"])
    }
    @Test(arguments:["seedRecord","profile"],["complete","incomplete","collision","collisionIncomplete"])
    func b57EveryExplicitHistoricalVariantRetainsItsNestedIDs(_ kind: String, _ mode: String) throws {
        for reversed in [false,true] {
            var (f,catalog) = try seed()
            let seed = catalog[0].document, e = try evidence("E")
            let depE = dependency("evidence","E",e)
            let x0: SyntheticRegistrationDocument, x1: SyntheticRegistrationDocument
            if kind == "profile" {
                x0 = try profile("X",reviewID:"review-X0")
                let wrapper = x0.value["payload"]!, p = wrapper["payload"]!
                let next = set(wrapper,"payload",set(set(p,"uniquenessEvidenceIDs",.array([s("E")])),"dependencyDigests",.array([depE])))
                x1 = try C.make(.approved,.object(["payload":next,"approval":try approval(next,"review-X1")]))
            } else {
                x0 = try C.make(.seedRecord,set(seed.value,"recordID",s("X")))
                x1 = try C.make(.seedRecord,set(x0.value,"dependencyDigests",.array([depE])))
            }
            let a = try C.make(.seedRecord,set(set(seed.value,"recordID",s("A")),"dependencyDigests",.array([dependency(kind,"X",x0)])))
            let b = try C.make(.seedRecord,set(set(seed.value,"recordID",s("Z")),"dependencyDigests",.array([dependency(kind,"X",x1)])))
            let base = f.envelope["baseline"]!["payload"]!["payload"]!
            let inv = kind == "profile" ? set(base["seedInventory"]!,"reviewIDs",.array([s("attachment-authority"),s("review-X0"),s("review-X1")])) : base["seedInventory"]!
            let complete = !mode.lowercased().contains("incomplete"), collision = mode.hasPrefix("collision")
            let nested = [dependency("seedRecord","A",a),dependency("seedRecord","Z",b),dependency(kind,"X",x0)]
            let held = try C.make(.seedRecord,set(seed.value,"dependencyDigests",.array(nested)))
            catalog[0] = .init(kind:"seedRecord",id:"seed-attachment",document:held)
            let deps = [dependency("seedRecord","seed-attachment",held)] + nested
            try rebase(&f,set(set(set(base,"seedInventory",inv),"historyComplete",.bool(complete)),"dependencyDigests",.array(deps)))
            catalog += [.init(kind:"seedRecord",id:"A",document:a),.init(kind:"seedRecord",id:"Z",document:b),
                .init(kind:kind,id:"X",document:x0),.init(kind:kind,id:"X",document:x1)]
            if reversed { catalog.reverse() }
            if collision { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,"E")])) }
            expect(try run(f,catalog:catalog),(collision ? [.historyConflict,.historyConflict] : [.historyConflict]) +
                (complete ? [] : [.historyUnavailable]) + [.correspondenceUnavailable],
                locators:(collision ? ["E","X"] : ["X"]) + (complete ? [] : ["baseline"]) + ["E"])
        }
    }
    @Test(arguments:[true,false],[false,true])
    func b58ParentClosureUsesItsDeclaredVariant(_ completeInventory: Bool, _ reversed: Bool) throws {
        var (f,catalog) = try seed()
        let e = try evidence("E"), seed = catalog[0].document
        let x0 = try C.make(.seedRecord,set(seed.value,"recordID",s("X")))
        let x1 = try C.make(.seedRecord,set(x0.value,"dependencyDigests",.array([dependency("evidence","E",e)])))
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(base["seedInventory"]!,"attachmentRecordIDs",.array([s("X")]))
        let deps = [dependency("seedRecord","X",x1)] + (completeInventory ? [dependency("evidence","E",e)] : [])
        try rebase(&f,set(set(base,"seedInventory",inv),"dependencyDigests",.array(deps)))
        catalog = [.init(kind:"seedRecord",id:"X",document:x0),.init(kind:"seedRecord",id:"X",document:x1),.init(kind:"evidence",id:"E",document:e)]
        if reversed { catalog.reverse() }
        expect(try run(f,catalog:catalog),[.historyConflict] + (completeInventory ? [] : [.correspondenceUnavailable]),
               locators:completeInventory ? ["X"] : ["X","E"])
    }
    @Test(arguments:["missingPredecessor","continuityConflict","validPredecessor"],[false,true])
    func b59EveryBoundSeedVariantKeepsLocalAndExactPredecessorChecks(_ mode: String, _ reversed: Bool) throws {
        var (f,catalog) = try seed()
        let original = catalog[0].document, e = try evidence("E"), local = mode == "missingPredecessor"
        let s0 = try C.make(.seedRecord,set(set(original.value,"recordID",s("S")),"kind",s(local ? "status" : "attachment")))
        let s1 = try C.make(.seedRecord,set(s0.value,"dependencyDigests",.array([dependency("evidence","E",e)])))
        let zref = set(original.value["reference"]!,"value",s("another invented key"))
        let z = try C.make(.seedRecord,set(set(set(original.value,"recordID",s("Z")),"reference",zref),"dependencyDigests",
            .array([dependency("seedRecord","S",s1),dependency("evidence","E",e)])))
        var refs = [s0.value["reference"]!,zref], attachments = [s("Z")], statuses = [s("S")]
        var deps = [dependency("seedRecord","S",s0),dependency("seedRecord","Z",z),dependency("evidence","E",e)]
        catalog = [.init(kind:"seedRecord",id:"S",document:s0),.init(kind:"seedRecord",id:"S",document:s1),
            .init(kind:"seedRecord",id:"Z",document:z),.init(kind:"evidence",id:"E",document:e)]
        if !local {
            let ref = mode == "continuityConflict" ? set(s0.value["reference"]!,"attachedBy",s("other-authority")) : s0.value["reference"]!
            let t = try C.make(.seedRecord,set(set(set(set(set(original.value,"recordID",s("T")),"kind",s("status")),"reference",ref),
                "predecessorRecordID",s("S")),"predecessorRecordSHA256",s(s0.sha256)))
            refs = [ref,zref]; attachments += [s("S")]; statuses = [s("T")]
            deps += [dependency("seedRecord","T",t)]; catalog.append(.init(kind:"seedRecord",id:"T",document:t))
        }
        let current = try C.make(.registry,set(value(f.current),"references",.array(refs))).bytes
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(set(base["seedInventory"]!,"attachmentRecordIDs",.array(attachments)),"statusRecordIDs",.array(statuses))
        try rebase(&f,set(set(set(set(base,"registryBytes",blob(current)),"registrySHA256",s(C.digest(current))),"seedInventory",inv),"dependencyDigests",.array(deps)))
        if reversed { catalog.reverse() }
        expect(try run(f,catalog:catalog),[.historyConflict] + (mode == "continuityConflict" ? [.historyConflict] : []) + (local ? [.historyUnavailable] : []),
               locators:local ? ["S","S"] : mode == "continuityConflict" ? ["S","T"] : ["S"])
    }
    @Test(arguments:["control","evidenceCollision","authorityCollision"],[false,true])
    func b60ExactPredecessorRetainsNestedIDsDespiteMissingInventory(_ mode: String, _ reversed: Bool) throws {
        var (f,catalog) = try seed()
        let e = try evidence("E"), original = catalog[0].document
        let prior = try C.make(.seedRecord,set(set(set(original.value,"authorityID",s("prior-authority")),"reference",
            set(original.value["reference"]!,"attachedBy",s("prior-authority"))),"dependencyDigests",.array([dependency("evidence","E",e)])))
        let status = try C.make(.seedRecord,.object(["recordID":s("seed-status"),"kind":s("status"),"stipulated":s("synthetic"),
            "reference":prior.value["reference"]!,"authorityID":s("status-authority"),"predecessorRecordID":s("seed-attachment"),
            "predecessorRecordSHA256":s(prior.sha256),"dependencyDigests":.array([])]))
        let base = f.envelope["baseline"]!["payload"]!["payload"]!
        let inv = set(set(set(base["seedInventory"]!,"attachmentRecordIDs",.array([])),"statusRecordIDs",.array([s("seed-status")])),
            "reviewIDs",.array([s("prior-authority"),s("status-authority")]))
        let current = try C.make(.registry,set(value(f.current),"references",.array([prior.value["reference"]!]))).bytes
        try rebase(&f,set(set(set(set(base,"registryBytes",blob(current)),"registrySHA256",s(C.digest(current))),"seedInventory",inv),
            "dependencyDigests",.array([dependency("seedRecord","seed-status",status)])))
        catalog = [.init(kind:"seedRecord",id:"seed-status",document:status),.init(kind:"seedRecord",id:"seed-attachment",document:prior)]
        if reversed { catalog.reverse() }
        let collision = mode != "control", id = mode == "evidenceCollision" ? "E" : "prior-authority"
        if collision { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,id)])) }
        expect(try run(f,catalog:catalog),(collision ? [.historyConflict] : []) + [.historyUnavailable,.correspondenceUnavailable],held:!collision,
               locators:(collision ? [id] : []) + ["seed-attachment","E"])
    }
    @Test(arguments:[false,true],[false,true])
    func b61PredecessorDigestComparisonDoesNotRequireBytes(_ missing: Bool, _ conflict: Bool) throws {
        for order in 0..<4 {
            var (f,catalog) = try seed()
            let template = catalog[0].document, ref = template.value["reference"]!
            let prior = try C.make(.seedRecord,set(set(template.value,"recordID",s("P")),"reference",set(ref,"status",.object(["state":s("active")]))))
            // Rename the status to move its declaration before/after P in canonical record order.
            let statusID = order & 1 == 0 ? "A-status" : "Z-status"
            let status = try C.make(.seedRecord,.object(["recordID":s(statusID),"kind":s("status"),"stipulated":s("synthetic"),
                "reference":ref,"authorityID":s("status-authority"),"predecessorRecordID":s("P"),
                "predecessorRecordSHA256":s(conflict ? zero : prior.sha256),"dependencyDigests":.array([])]))
            let base = f.envelope["baseline"]!["payload"]!["payload"]!
            let inv = set(set(set(base["seedInventory"]!,"attachmentRecordIDs",.array([s("P")])),"statusRecordIDs",.array([s(statusID)])),
                "reviewIDs",.array([s("attachment-authority"),s("status-authority")]))
            try rebase(&f,set(set(base,"seedInventory",inv),"dependencyDigests",.array([
                dependency("seedRecord","P",prior),dependency("seedRecord",statusID,status)])))
            catalog = [.init(kind:"seedRecord",id:statusID,document:status)]
            if !missing { catalog.append(.init(kind:"seedRecord",id:"P",document:prior)) }
            if order & 2 != 0 {
                catalog = try catalog.reversed().map { .init(kind:$0.kind,id:$0.id,document:try C.read($0.document.format,$0.document.bytes)) }
                f.envelope = objectOrder(f.envelope,reversed:true)
            }
            let before = try C.make(.envelope,f.envelope).bytes, current = f.current
            let result = try run(f,catalog:catalog)
            if !missing && !conflict { #expect(checked(result)?.businessAdmissionRequired == ["Q"]) }
            else {
                let conflicts = conflict ? (missing ? ["P"] : ["P",statusID].sorted()) : []
                expect(result,Array(repeating:.historyConflict,count:conflicts.count) + (missing ? [.historyUnavailable] : []),
                    held:!conflict,locators:conflicts + (missing ? ["P"] : []))
            }
            #expect(try C.make(.envelope,f.envelope).bytes == before); #expect(f.current == current)
        }
    }
    @Test(arguments:[false,true],[false,true])
    func b62MissingPredecessorAssertionsCompareWithEachOther(_ conflict: Bool, _ complete: Bool) throws {
        for order in 0..<4 {
            var (f,catalog) = try seed()
            let template = catalog[0].document, ref = template.value["reference"]!
            let second = set(ref,"value",s("second invented key"))
            let digests = [zero,conflict ? String(repeating:"1",count:64) : zero]
            let records = try [ref,second].enumerated().map { i,ref in
                try C.make(.seedRecord,.object(["recordID":s(i == 0 ? "S1" : "S2"),"kind":s("status"),"stipulated":s("synthetic"),
                    "reference":ref,"authorityID":s("attachment-authority"),"predecessorRecordID":s("P"),
                    "predecessorRecordSHA256":s(digests[order & 1 == 0 ? i : 1-i]),"dependencyDigests":.array([])]))
            }
            let current = try C.make(.registry,set(value(f.current),"references",.array([ref,second]))).bytes
            let base = f.envelope["baseline"]!["payload"]!["payload"]!
            let inv = set(set(base["seedInventory"]!,"attachmentRecordIDs",.array([])),"statusRecordIDs",.array([s("S1"),s("S2")]))
            let deps = records.map { dependency("seedRecord",$0.value["recordID"]!.text!,$0) }
            try rebase(&f,set(set(set(set(set(base,"registryBytes",blob(current)),"registrySHA256",s(C.digest(current))),
                "historyComplete",.bool(complete)),"seedInventory",inv),"dependencyDigests",.array(deps)))
            catalog = records.map { .init(kind:"seedRecord",id:$0.value["recordID"]!.text!,document:$0) }
            if order & 2 != 0 { catalog.reverse(); f.envelope = objectOrder(f.envelope,reversed:true) }
            expect(try run(f,catalog:catalog),(conflict ? [.historyConflict] : []) + [.historyUnavailable] + (complete ? [] : [.historyUnavailable]),
                held:!conflict,locators:(conflict ? ["P"] : []) + ["P"] + (complete ? [] : ["baseline"]))
        }
    }
    private func evidencedProfile(_ id: String, _ digest: String) throws -> SyntheticRegistrationDocument {
        let original = try profile(id,reviewID:"review-" + id), wrapper = original.value["payload"]!
        let dependency = V.object(["kind":s("evidence"),"id":s("E"),"sha256":s(digest)])
        let changed = set(wrapper,"payload",set(set(wrapper["payload"]!,"uniquenessEvidenceIDs",.array([s("E")])),"dependencyDigests",.array([dependency])))
        return try C.make(.approved,.object(["payload":changed,"approval":try approval(changed,"review-" + id)]))
    }
    @Test(arguments:["missingEqual","missingConflict","resolvedEqual","resolvedConflict"],["inline","catalog","both"])
    func b63IncomingNestedBindingsCompareBeforeEvidenceLookup(_ mode: String, _ transport: String) throws {
        for reversed in [false,true] {
            var f = try fixture()
            let e = try evidence("E"), p = try evidencedProfile("P",e.sha256)
            let missing = mode.hasPrefix("missing"), conflict = mode.hasSuffix("Conflict")
            let dep = V.object(["kind":s("evidence"),"id":s("E"),"sha256":s(conflict ? zero : e.sha256)])
            let q = f.envelope["request"]!, payload = set(set(set(q["payload"]!,"profileIDs",.array([s("P")])),
                "evidenceIDs",.array([s("E")])),"dependencyDigests",.array([dep,dependency("profile","P",p)]))
            try resign(&f,set(q,"payload",payload))
            var catalog: [SyntheticTripRegistrationClosure.Entry] = [.init(kind:"evidence",id:"unrelated",document:try evidence("unrelated"))]
            if transport != "catalog" {
                f.envelope = set(f.envelope,"profiles",.array([p.value]))
                if !missing { f.envelope = set(f.envelope,"evidence",.array([e.value])) }
            }
            if transport != "inline" {
                catalog.append(.init(kind:"profile",id:"P",document:p))
                if !missing { catalog.append(.init(kind:"evidence",id:"E",document:e)) }
            }
            if reversed { catalog.reverse(); f.envelope = objectOrder(f.envelope,reversed:true) }
            if !missing && !conflict { #expect(checked(try run(f,catalog:catalog))?.conversionOnly == true) }
            else {
                let issues: [SyntheticRegistrationIssue] = (conflict ? [.historyConflict] : []) + (missing ? [.correspondenceUnavailable] : [])
                expect(try run(f,catalog:catalog),issues,held:!conflict,locators:Array(repeating:"E",count:issues.count))
            }
        }
    }
    @Test(arguments:[false,true],[false,true])
    func b64ObservedBindingsDoNotGrantHistoricalMembership(_ conflict: Bool, _ freshApproval: Bool) throws {
        for reversed in [false,true] {
            var f = try fixture()
            let e = try evidence("E"), p1 = try evidencedProfile("P1",e.sha256)
            let p2 = try evidencedProfile("P2",conflict ? zero : e.sha256)
            // These supplied profiles are not retained history or referenced by Q. Their explicit
            // digests still agree or conflict; neither assertion introduces missing evidence E.
            f.envelope = set(f.envelope,"profiles",.array([reversed ? p2.value : p1.value]))
            let catalog = [SyntheticTripRegistrationClosure.Entry(kind:"profile",id:reversed ? "P1" : "P2",document:reversed ? p1 : p2)]
            if freshApproval { f.envelope = set(f.envelope,"approvals",.array([try approval(f.envelope["request"]!,"E")])) }
            expect(try run(f,catalog:catalog),(conflict ? [.historyConflict] : []) + [.correspondenceUnavailable],
                held:!conflict,locators:conflict ? ["E","E"] : ["E"])
        }
    }
    @Test(arguments:["missing","equal","different"],[false,true])
    func b65UnlistedPredecessorBytesMustMatchTheExplicitBinding(_ mode: String, _ complete: Bool) throws {
        for reversed in [false,true] {
            var (f,catalog) = try seed()
            let original = catalog[0].document
            // A mismatching copy must not contribute its authority or reference assertions to history.
            let supplied = mode == "different" ? try C.make(.seedRecord,set(set(original.value,"authorityID",s("review-B")),
                "reference",set(original.value["reference"]!,"attachedBy",s("review-B")))) : original
            let status = try C.make(.seedRecord,.object(["recordID":s("seed-status"),"kind":s("status"),"stipulated":s("synthetic"),
                "reference":original.value["reference"]!,"authorityID":s("status-authority"),"predecessorRecordID":s("seed-attachment"),
                "predecessorRecordSHA256":s(original.sha256),"dependencyDigests":.array([])]))
            let base = f.envelope["baseline"]!["payload"]!["payload"]!
            let inv = set(set(set(base["seedInventory"]!,"attachmentRecordIDs",.array([])),"statusRecordIDs",.array([s("seed-status")])),
                "reviewIDs",.array([s("attachment-authority"),s("status-authority")]))
            try rebase(&f,set(set(set(base,"seedInventory",inv),"historyComplete",.bool(complete)),
                "dependencyDigests",.array([dependency("seedRecord","seed-status",status)])))
            catalog = [.init(kind:"seedRecord",id:"seed-status",document:status)]
            if mode != "missing" { catalog.append(.init(kind:"seedRecord",id:"seed-attachment",document:supplied)) }
            if reversed { catalog.reverse(); f.envelope = objectOrder(f.envelope,reversed:true) }
            let conflict = mode == "different"
            expect(try run(f,catalog:catalog),(conflict ? [.historyConflict] : []) + (complete ? [] : [.historyUnavailable]) + [.historyUnavailable],
                held:!conflict,locators:(conflict ? ["seed-attachment"] : []) + (complete ? [] : ["baseline"]) + ["seed-attachment"])
        }
    }
}
#endif
