import Foundation
import Darwin

// All evidence, source keys and authority in this file are deliberately INVENTED.
enum RegistrationFixtures {
    static func scenario(large: Bool = false, counts: Bool = false) throws -> Registration.Inputs {
        var raw = try Fixtures.legacy(complex:true)
        if counts {
            let es = (0..<275).map { CanonicalEntity(id:MintedIdentifier("stn_" + String(format:"%016x",$0))!,status:.active) }
            let p = try SourceReference(inputSHA256:Fixtures.hash,member:.init(name:"invented-stops.txt",sha256:Fixtures.hash),table:"invented",recordIndex:nil,field:"invented",providerKey:ExactValue("INVENTED_ROW")!)
            let refs = try (0..<716).map { n in
                try ProviderReference(canonicalID:es[n % 275].id,sourceID:"fixture.feed",namespace:.gtfsStopID,value:ExactValue("INVENTED_STOP_" + String(format:"%04d",n))!,status:.active,firstSeenInputSHA256:Fixtures.hash,provenance:p,originalNames:[],attachedBy:nil)
            }
            raw = try MappingRegistry(revision:6,entities:es,references:refs).encoded()
        }
        var baseline = try Fixtures.approvedBaseline(raw)
        if large {
            var rows = baseline["payload"]["records"].list
            for n in 0..<3 {
                let bytes = Data(repeating:UInt8(65+n),count:2_700_000)
                rows.append(.object(["id":.string("fixture.large." + String(n)),"kind":.string("evidence"),"sha256":.string(Codec.hash(bytes)),"bytes":Codec.blob(bytes),
                    "heldIdentifiers":.array([]),"allocationIDs":.array([]),"reviewIDs":.array([]),"dependencyDigests":.array([])]))
            }
            rows.sort { $0["id"].text < $1["id"].text }
            let p = baseline["payload"].replacing("records",.array(rows)).replacing("dependencyDigests",.array(rows.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) }))
            baseline = try Fixtures.resign(p)
        }
        let h0 = try Codec.encode(Conversion.initialHistory(baseline)), current = try Conversion.pin(raw,h0,lineage:Fixtures.lineage)
        let cq = try Conversion.prepare(raw,history:h0,current:current,owner:Fixtures.owner,requestID:"fixture.conversion")
        let ca = try Conversion.approval(cq,owner:Fixtures.owner,reviewID:"fixture.conversion-approval",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        let converted = try Conversion.apply(raw,history:h0,current:current,request:cq,approval:ca,owner:Fixtures.owner)
        let source: Wire = .object(["sourceID":.string("fixture.trip-feed"),"namespace":.string("gtfs.trip_id"),"key":.string("INVENTED_PRIVATE_é_e\u{301}_東京_한글"),
            "profileID":.string("fixture.profile"),"profileVersion":.string("fixture.v1"),"inputSHA256":.string(Fixtures.hash),"publisherID":.string("INVENTED_PUBLISHER"),"resourceID":.string("INVENTED_RESOURCE"),"feedRevision":.string("INVENTED_FEED_REVISION")])
        let b: Wire = .object(["lineageID":.string(Fixtures.lineage),"schemaVersion":.integer(2),"revision":.integer(6),"registrySHA256":.string(Codec.hash(raw))])
        let mappingBytes = Data("INVENTED MAPPING AUTHORITY".utf8)
        let mapping: Wire = .object(["version":.string("fixture.mapping"),"sha256":.string(Codec.hash(mappingBytes))])
        var evidence = [Wire](), dependencies = [Wire]()
        func dependency(_ id: String, _ bytes: Data) -> Wire { .object(["id":.string(id),"sha256":.string(Codec.hash(bytes)),"bytes":Codec.blob(bytes),"dependencyDigests":.array([])]) }
        for role in Correspondence.roles {
            let id = "fixture.evidence." + role, bytes = Data(("INVENTED ACCEPTED AUTHORITY " + role).utf8)
            evidence.append(.object(["role":.string(role),"evidenceID":.string(id),"sha256":.string(Codec.hash(bytes)),"locator":.string("INVENTED_LOCATOR_" + role),"source":source,"baseline":b,"mapping":mapping]))
            dependencies.append(dependency(id,bytes))
        }
        dependencies.append(dependency("fixture.mapping",mappingBytes))
        dependencies.append(dependency("fixture.provenance",Data("INVENTED PROVENANCE AUTHORITY".utf8)))
        dependencies.sort { $0["id"].text < $1["id"].text }
        let cc: Wire = .object(["format":.string(Correspondence.contextFormat),"schemaVersion":.integer(1),"ownerAuthority":.string(Fixtures.owner),"source":source,"baseline":b,"mapping":mapping,"evidence":.array(evidence)])
        let conclusion: Wire = .object(["distinctNewRunRequested":.bool(true),"existingCanonicalTripTarget":.null,"priorCanonicalTripBinding":.string("noneStructurallyPossibleInPriorBaseline"),
            "acceptedCanonicalCompetitors":.string("noneStructurallyPossibleInPriorBaseline"),"externalSemanticCompetition":.string("notGloballyDisproved"),"semanticDistinctnessFromAllSourceRows":.bool(false),
            "affirmativeReasoning":.string("INVENTED owner reviewed scoped recurring meaning; no global competition claim."),
            "basisEvidenceIDs":.array([.string("fixture.evidence.candidateApplicability"),.string("fixture.evidence.sourceProfileAcceptance")])])
        let payload: Wire = .object(["requestID":.string("fixture.correspondence"),"ownerAuthority":.string(Fixtures.owner),"mode":.string("distinctNewRun"),"source":source,"baseline":b,"mapping":mapping,
            "baselineCapability":.string("noTripIdentityStateInIdentifiedBaseline"),"evidence":.array(evidence),"conclusion":conclusion,"unresolvedPrerequisites":.array(Correspondence.prerequisites.map(Wire.string))])
        let a: Wire = .object(["authorityID":.string(Fixtures.owner),"approvedAt":.string(Fixtures.time),"proposalSHA256":.string(try Correspondence.proposalDigest(payload))])
        let approval = a.replacing("approvedContentSHA256",.string(try Correspondence.approvedDigest(payload,a)))
        let correspondence = try Correspondence.canonical(.object(["format":.string(Correspondence.format),"schemaVersion":.integer(1),"payload":payload,"approval":approval]))
        let provenance: Wire = .object(["inputSHA256":source["inputSHA256"],"member":.object(["name":.string("trips.txt"),"sha256":.string(Fixtures.hash)]),"table":.string("trips"),"field":.string("trip_id"),"providerKey":source["key"]])
        let workflow = Wire.object(Dictionary(uniqueKeysWithValues:Registration.workflowFields.map { ($0,Wire.string("fixture.new." + $0)) }))
        let context: Wire = .object(["format":.string(Registration.contextFormat),"schemaVersion":.integer(1),"ownerAuthority":.string(Fixtures.owner),
            "expectedPrevious":try Conversion.pin(converted.registry,converted.history,lineage:Fixtures.lineage),"predecessorManifestSHA256":.string(Codec.hash(converted.manifest)),"workflow":workflow,
            "correspondenceContext":cc,"correspondence":.object(["requestID":payload["requestID"],"proposalSHA256":approval["proposalSHA256"],"approvedContentSHA256":approval["approvedContentSHA256"],"recordSHA256":.string(Codec.hash(correspondence))]),
            "profileAcceptance":.object(["profileID":source["profileID"],"version":source["profileVersion"],"disposition":.string("accepted")]),
            "applicability":.object(["evidenceID":evidence[0]["evidenceID"],"sha256":evidence[0]["sha256"],"disposition":.string("eligible")]),
            "provenance":provenance,"provenanceEvidenceID":.string("fixture.provenance"),"dependencyDigests":.array(dependencies.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) }),"scope":.string("identityOnlyOneTripOneReference")])
        return .init(registry:converted.registry,history:converted.history,manifest:converted.manifest,context:context,correspondence:correspondence,dependencies:.array(dependencies))
    }
    static func changed(_ i: Registration.Inputs, registry: Data? = nil, history: Data? = nil, manifest: Data? = nil, context: Wire? = nil, correspondence: Data? = nil, dependencies: Wire? = nil) -> Registration.Inputs {
        .init(registry:registry ?? i.registry,history:history ?? i.history,manifest:manifest ?? i.manifest,context:context ?? i.context,correspondence:correspondence ?? i.correspondence,dependencies:dependencies ?? i.dependencies)
    }
    static func prepared(_ i: Registration.Inputs) throws -> Wire {
        try Registration.request(Registration.eligible(i),draw:.init(id:Fixtures.id("trp","4"),attempts:1))
    }
    static func approved(_ q: Wire) throws -> Wire {
        try Registration.approval(q,reviewID:q["context"]["workflow"]["approvalReviewID"].text,author:"fixture.author",at:Fixtures.time,reference:"fixture.registration-review")
    }
    static func correspondenceID(_ i: Registration.Inputs, _ id: String) throws -> Registration.Inputs {
        let co = try Correspondence.read(i.correspondence,context:i.context["correspondenceContext"])
        let p = co["payload"].replacing("requestID",.string(id))
        var a = co["approval"].replacing("proposalSHA256",.string(try Correspondence.proposalDigest(p)))
        a = a.replacing("approvedContentSHA256",.string(try Correspondence.approvedDigest(p,a)))
        let bytes = try Correspondence.canonical(co.replacing("payload",p).replacing("approval",a))
        let pin: Wire = .object(["requestID":.string(id),"proposalSHA256":a["proposalSHA256"],"approvedContentSHA256":a["approvedContentSHA256"],"recordSHA256":.string(Codec.hash(bytes))])
        return changed(i,context:i.context.replacing("correspondence",pin),correspondence:bytes)
    }
    static func retainingCorrespondenceReview(_ i: Registration.Inputs) throws -> Registration.Inputs {
        let old = try Conversion.history(i.history,owner:Fixtures.owner).0, root = old["baseline"]["payload"]
        let rows = root["records"].list.map { r -> Wire in
            guard r["id"].text == "fixture.review-record" else { return r }
            return r.replacing("bytes",Codec.blob(i.correspondence)).replacing("sha256",.string(Codec.hash(i.correspondence)))
        }
        let payload = root.replacing("records",.array(rows)).replacing("dependencyDigests",.array(rows.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) }))
        let h0 = try Codec.encode(Conversion.initialHistory(Fixtures.resign(payload))), raw = root["registryBytes"].blob
        let current = try Conversion.pin(raw,h0,lineage:Fixtures.lineage)
        let q = try Conversion.prepare(raw,history:h0,current:current,owner:Fixtures.owner,requestID:"fixture.conversion")
        let a = try Conversion.approval(q,owner:Fixtures.owner,reviewID:"fixture.conversion-approval",author:"fixture.author",at:Fixtures.time,reference:"fixture.review")
        let b = try Conversion.apply(raw,history:h0,current:current,request:q,approval:a,owner:Fixtures.owner)
        let c = i.context.replacing("expectedPrevious",try Conversion.pin(b.registry,b.history,lineage:Fixtures.lineage)).replacing("predecessorManifestSHA256",.string(Codec.hash(b.manifest)))
        return changed(i,registry:b.registry,history:b.history,manifest:b.manifest,context:c)
    }
    static func location(_ i: Registration.Inputs, _ dir: String) -> Preparation.Location {
        let w = i.context["workflow"]
        return .init(workspace:dir + "/workspace",output:dir + "/bundle",operationID:w["operationID"].text,workspaceID:w["workspaceID"].text,outputID:w["outputID"].text)
    }
}
