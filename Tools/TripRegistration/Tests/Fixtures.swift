import Foundation
import Darwin

// Every label/value/authority below is invented. No fixture opens any existing private file.
enum Fixtures {
    static let owner = "fixture.owner", lineage = "fixture.provisional.lineage"
    static let time = "2001-01-01T00:00:00Z"
    static let hash = String(repeating:"1",count:64)
    static func id(_ kind: String, _ body: Character) -> String { kind + "_" + String(repeating:String(body),count:16) }
    static func entity(_ kind: String, _ body: Character) -> Wire { .object(["id":.string(id(kind,body)),"state":.string("active")]) }
    static func legacy(complex: Bool = false) throws -> Data {
        let s = MintedIdentifier(id("stn","0"))!, l = MintedIdentifier(id("lin","2"))!, o = MintedIdentifier(id("opr","3"))!
        var es = [CanonicalEntity(id:s,status:.active),CanonicalEntity(id:l,status:.active),CanonicalEntity(id:o,status:.active)]
        var refs: [ProviderReference] = []
        if complex {
            es.append(CanonicalEntity(id:MintedIdentifier(id("stn","1"))!,status:.retired(successors:[s])))
            for (i,ns) in ProviderNamespace.allCases.enumerated() {
                let source = try SourceReference(inputSHA256:hash,member:ns.isGTFS ? .init(name:"fixture.csv",sha256:hash) : nil,
                    table:ns.isGTFS ? "fixture" : nil,recordIndex:ns.isGTFS ? nil : i,field:"fixtureField",providerKey:ExactValue("FIXTURE_ROW_" + String(i))!)
                let target = ns.kind == .station ? s : ns.kind == .line ? l : o
                let status: ProviderReferenceStatus = i % 3 == 0 ? .active : i % 3 == 1 ? .absent : .retired(review:"fixture.withdrawal")
                refs.append(try ProviderReference(canonicalID:target,sourceID:"fixture.source",namespace:ns,value:ExactValue("FIXTURE_PROVIDER_" + String(i))!,
                    status:status,firstSeenInputSHA256:hash,provenance:source,
                    originalNames:[OriginalName(language:ExactValue("xx")!,value:ExactValue("FIXTURE_NAME_e\u{301}")!,source:source),
                                   OriginalName(language:ExactValue("xx")!,value:ExactValue("FIXTURE_NAME_é")!,source:source)],
                    attachedBy:i % 2 == 0 ? nil : "fixture.attachment"))
            }
        }
        return try MappingRegistry(revision:6,entities:es,references:refs).encoded()
    }
    static func record(_ name: String, kind: String, allocations: [Wire] = [], reviews: [Wire] = [], deps: [Wire] = []) throws -> Wire {
        let original = try Codec.encode(.object(["inventedOriginalAuthority":.string(name)]))
        return .object(["id":.string(name),"kind":.string(kind),"sha256":.string(Codec.hash(original)),"bytes":Codec.blob(original),
                        "heldIdentifiers":.array(allocations),"allocationIDs":.array(kind == "allocation" ? [.string("fixture.original-allocation-request")] : []),"reviewIDs":.array(reviews),"dependencyDigests":.array(deps)])
    }
    static func approvedBaseline(_ registry: Data) throws -> Wire {
        let r = try Registry4.legacy(registry)
        let allocations = r["entities"].list.map { $0["id"] }
        var reviews = Set<String>()
        for ref in r["references"].list {
            if ref.has("attachedBy") { reviews.insert(ref["attachedBy"].text) }
            if ref["status"]["state"].text == "retired" { reviews.insert(ref["status"]["review"].text) }
        }
        let rr = reviews.sorted().map(Wire.string)
        var records = [try record("fixture.allocation-record",kind:"allocation",allocations:allocations)]
        if !rr.isEmpty { records.append(try record("fixture.review-record",kind:"review",reviews:rr)) }
        let p: Wire = .object(["format":.string(Conversion.baselineFormat),"schemaVersion":.integer(1),"baselineID":.string("fixture.baseline"),
            "lineageID":.string(lineage),"ownerAuthority":.string(owner),"registryBytes":Codec.blob(registry),"registrySHA256":.string(Codec.hash(registry)),
            "revision":r["revision"],"legacyHistoryState":.string("none"),"historyComplete":.bool(true),"heldIdentifiers":.array(allocations),"allocationIDs":.array([.string("fixture.original-allocation-request")]),
            "reviewIDs":.array(rr),"dependencyDigests":.array(records.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) }),"records":.array(records)])
        return try resign(p)
    }
    static func resign(_ payload: Wire) throws -> Wire {
        .object(["payload":payload,"approval":try Conversion.approval(payload,owner:owner,reviewID:"fixture.baseline-approval",author:"fixture.author",at:time,reference:"fixture.baseline-review")])
    }
    struct Scenario {
        let registry: Data, history: Data, current: Wire, request: Wire, approval: Wire
        func apply() throws -> Conversion.Bundle { try Conversion.apply(registry,history:history,current:current,request:request,approval:approval,owner:owner) }
    }
    static func scenario(complex: Bool = false) throws -> Scenario {
        let r = try legacy(complex:complex), b = try approvedBaseline(r)
        let h = try Codec.encode(Conversion.initialHistory(b)), p = try Conversion.pin(r,h,lineage:lineage)
        let q = try Conversion.prepare(r,history:h,current:p,owner:owner,requestID:"fixture.conversion")
        let a = try Conversion.approval(q,owner:owner,reviewID:"fixture.conversion-approval",author:"fixture.author",at:time,reference:"fixture.conversion-review")
        return .init(registry:r,history:h,current:p,request:q,approval:a)
    }
    static func directory() throws -> String {
        let p = "/private/tmp/tsugino-invented-conversion-" + UUID().uuidString
        guard mkdir(p,0o700) == 0, chmod(p,0o700) == 0 else { throw ConversionFailure.publicationFailure }; return p
    }
    static func write(_ path: String, _ bytes: Data) throws {
        try bytes.write(to:URL(fileURLWithPath:path)); guard chmod(path,0o600) == 0 else { throw ConversionFailure.publicationFailure }
    }
}
