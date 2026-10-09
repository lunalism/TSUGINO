import Foundation

// Entirely invented authority, registry, source key, occurrences and opaque evidence.
// Existing TripRegistration fixture constructors are compiled unchanged, never private inputs.
enum ImportS9Fixture {
    static let owner = Fixtures.owner
    static let line = Fixtures.id("lin","2"), otherLine = Fixtures.id("lin","5")
    static func station(_ n: Int) -> String { "stn_" + String(format:"%016d",n) }
    static func registration() throws -> Conversion.Bundle {
        let original = try RegistrationFixtures.scenario()
        let entities = (0..<14).map { CanonicalEntity(id:MintedIdentifier(station($0))!,status:.active) }
            + [line,otherLine].map { CanonicalEntity(id:MintedIdentifier($0)!,status:.active) }
        let raw = try MappingRegistry(revision:6,entities:entities,references:[]).encoded()
        let authorityBaseline = try Fixtures.approvedBaseline(raw)
        let h0 = try Codec.encode(Conversion.initialHistory(authorityBaseline))
        let current = try Conversion.pin(raw,h0,lineage:Fixtures.lineage)
        let cq = try Conversion.prepare(raw,history:h0,current:current,owner:owner,requestID:"invented.conversion")
        let ca = try Conversion.approval(cq,owner:owner,reviewID:"invented.conversion.review",author:"invented.author",at:Fixtures.time,reference:"invented.review")
        let converted = try Conversion.apply(raw,history:h0,current:current,request:cq,approval:ca,owner:owner)
        let old = original.context["correspondenceContext"]
        let baseline = old["baseline"].replacing("registrySHA256",.string(Codec.hash(raw)))
        let evidence = Wire.array(old["evidence"].list.map { $0.replacing("baseline",baseline) })
        let cc = old.replacing("baseline",baseline).replacing("evidence",evidence)
        let co = try Correspondence.read(original.correspondence,context:old)
        let p = co["payload"].replacing("baseline",baseline).replacing("evidence",evidence)
        var a = co["approval"].replacing("proposalSHA256",.string(try Correspondence.proposalDigest(p)))
        a = a.replacing("approvedContentSHA256",.string(try Correspondence.approvedDigest(p,a)))
        let cb = try Correspondence.canonical(co.replacing("payload",p).replacing("approval",a))
        let c = original.context.replacing("correspondenceContext",cc)
            .replacing("expectedPrevious",try Conversion.pin(converted.registry,converted.history,lineage:Fixtures.lineage))
            .replacing("predecessorManifestSHA256",.string(Codec.hash(converted.manifest)))
            .replacing("correspondence",.object(["requestID":p["requestID"],"proposalSHA256":a["proposalSHA256"],"approvedContentSHA256":a["approvedContentSHA256"],"recordSHA256":.string(Codec.hash(cb))]))
        let i = Registration.Inputs(registry:converted.registry,history:converted.history,manifest:converted.manifest,context:c,correspondence:cb,dependencies:original.dependencies)
        let q = try RegistrationFixtures.prepared(i), approval = try RegistrationFixtures.approved(q)
        return try Registration.apply(i,request:q,approval:approval,current:c["expectedPrevious"])
    }
    struct Scenario {
        let input: Wire, context: Wire, state: Wire
        func request() throws -> Wire { try S9.prepare(input,context:context,state:state) }
        func approved(_ q: Wire) throws -> Wire { try S9.approve(q,owner:owner,reviewer:"invented.reviewer",at:Fixtures.time,reference:"invented.s9.review") }
        func bundle() throws -> S9.Bundle { let q = try request(); return try S9.apply(q,approval:approved(q),currentState:state,owner:owner) }
        func changed(_ i: Wire) throws -> Scenario {
            let p = try S9.reconstruct(i,artifact:context["snapshotArtifactID"])
            return .init(input:i,context:context.replacing("inputSHA256",.string(try Codec.digest(i))).replacing("dependencyDigests",p.roots)
                .replacing("movementReviewSHA256",i["movementReview"]["sha256"]),state:state)
        }
    }
    static func fixture() throws -> Scenario {
        let b = try registration(), h = try S9.read(b.history,Limits.history), regq = h["boundaries"].list[0]["request"]
        let checkpoint = try Conversion.pin(b.registry,b.history,lineage:Fixtures.lineage).replacing("manifestSHA256",.string(Codec.hash(b.manifest)))
        let source = regq["context"]["correspondenceContext"]["source"]
        var records: [Wire] = []
        func evidence(_ id: String) -> Wire {
            let bytes = Data(("INVENTED OPAQUE EVIDENCE " + id).utf8)
            let p: Wire = .object(["id":.string("invented." + id),"sha256":.string(Codec.hash(bytes))])
            records.append(p.replacing("bytes",Codec.blob(bytes)).replacing("dependencyDigests",.array([])))
            return p
        }
        let views: Wire = .object(Dictionary(uniqueKeysWithValues:["sourceRevision","profileRevision","mappingRevision","reviewRevision"].map { ($0,evidence($0)) }))
        let movementReview = evidence("movement-review"), interval = evidence("interval"), continuity = evidence("continuity")
        let membership = evidence("membership")
        var occurrences: [Wire] = [], movements: [Wire] = []
        for n in 0..<14 {
            occurrences.append(.object(["locator":.string("invented.occurrence." + String(n)),"order":.integer(n * 10),"disposition":.string("passenger"),"stationID":.string(station(n)),"originalIndex":.integer(n),
                "classificationEvidence":evidence("classification." + String(n)),"mappingEvidence":evidence("station-mapping." + String(n)),
                "membership":.array([.object(["lineID":.string(line),"evidence":membership]),.object(["lineID":.string(otherLine),"evidence":membership])])]))
            if n > 0 { movements.append(.object(["from":occurrences[n-1]["locator"],"to":occurrences[n]["locator"],"lineID":.string(line),"evidence":evidence("movement." + String(n))])) }
        }
        records.sort { $0["id"].text < $1["id"].text }
        let i = S9.tagged("assembly-input",["ownerAuthority":.string(owner),"inputID":.string("invented.input"),"registeredCheckpoint":checkpoint,"registeredTripID":regq["proposedTripID"],
            "registeredBundle":.object(["registryBytes":Codec.blob(b.registry),"historyBytes":Codec.blob(b.history),"manifestBytes":Codec.blob(b.manifest)]),
            "source":.object(["sourceID":source["sourceID"],"namespace":source["namespace"],"key":source["key"],"inputSHA256":source["inputSHA256"]]),"views":views,"movementReview":movementReview,
            "occurrences":.array(occurrences),"movements":.array(movements),"intervalEvidence":interval,"continuity":.object(["disposition":.string("notApplicable"),"evidence":continuity]),
            "origin":.object(["disposition":.string("unknownExtent")]),"destination":.object(["disposition":.string("unknownExtent")]),"serviceType":.string("unknown"),"dependencies":.array(records)])
        let s = S9.tagged("selection-state",["ownerAuthority":.string(owner),"tripID":regq["proposedTripID"],"historyComplete":.bool(true),"retainedAuthorityIDs":.array([.string("invented.held.authority")]),"selections":.array([])])
        let product = try S9.reconstruct(i,artifact:.string("invented.snapshot"))
        let c = S9.tagged("assembly-context",["ownerAuthority":.string(owner),"operation":.string(S9.operation),"registeredCheckpoint":checkpoint,"inputSHA256":.string(try Codec.digest(i)),"movementReviewSHA256":movementReview["sha256"],
            "snapshotArtifactID":.string("invented.snapshot"),"requestID":.string("invented.request"),"approvalReviewID":.string("invented.approval"),"outputID":.string("invented.bundle"),
            "dependencyDigests":product.roots,"selectionStateSHA256":.string(try Codec.digest(s)),"initialSelection":.bool(true),"noPreviousSnapshot":.bool(true)])
        return .init(input:i,context:c,state:s)
    }
}
