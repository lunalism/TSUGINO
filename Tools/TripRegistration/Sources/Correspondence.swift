import Foundation

// Adapter for the published Python correspondence v1 contract. Original bytes are
// retained separately; canonicalization here is Python's digest domain, not Codec's.
enum Correspondence {
    static let format = "tsugino.trip-correspondence-request"
    static let contextFormat = "tsugino.trip-correspondence-context"
    static let roles = ["candidateApplicability", "firstRealTripBaselineAudit", "passengerClassification", "sourceOrder", "sourceProfileAcceptance", "stationCrosswalk"]
    static let prerequisites = ["endpointDispositions", "immutableS9SnapshotAcceptance", "movementEvidence", "p3T1RealImport", "productionRegistryAdoption", "realTripRegistrationToolingCheckpoint"]
    static let limit = 256 * 1024

    static func canonical(_ v: Wire) throws -> Data {
        func string(_ s: String) -> String {
            var result = "\""
            for c in s.unicodeScalars {
                switch c.value {
                case 34: result += "\\\""
                case 92: result += "\\\\"
                case 8: result += "\\b"
                case 9: result += "\\t"
                case 10: result += "\\n"
                case 12: result += "\\f"
                case 13: result += "\\r"
                case 0..<32: result += String(format: "\\u%04x", c.value)
                default: result.unicodeScalars.append(c)
                }
            }
            return result + "\""
        }
        func render(_ w: Wire) -> String {
            switch w {
            case .object(let o): return "{" + o.keys.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }.map { string($0) + ":" + render(o[$0]!) }.joined(separator:",") + "}"
            case .array(let a): return "[" + a.map(render).joined(separator:",") + "]"
            case .string(let s): return string(s)
            case .integer(let i): return String(i)
            case .bool(let b): return b ? "true" : "false"
            case .null: return "null"
            }
        }
        let b = Data(render(v).utf8)
        guard b.count <= limit else { throw ConversionFailure.resourceLimit }; return b
    }
    static func text(_ v: Wire, max: Int = 1024) throws {
        func whitespace(_ c: Unicode.Scalar) -> Bool {
            (9...13).contains(c.value) || (28...32).contains(c.value) || [0x85,0xa0,0x1680,0x2028,0x2029,0x202f,0x205f,0x3000].contains(c.value) || (0x2000...0x200a).contains(c.value)
        }
        guard case .string = v, !v.text.unicodeScalars.allSatisfy(whitespace) else { throw ConversionFailure.malformedInput }
        guard v.text.utf8.count <= max else { throw ConversionFailure.resourceLimit }
    }
    static func token(_ v: Wire) throws {
        let b = Array(v.text.utf8)
        func alpha(_ c: UInt8) -> Bool { (48...57).contains(c) || (65...90).contains(c) || (97...122).contains(c) }
        guard !b.isEmpty, b.count <= 128, alpha(b[0]), b.allSatisfy({ alpha($0) || [46,95,58,45].contains($0) }) else { throw ConversionFailure.malformedInput }
    }
    static func source(_ s: Wire) throws {
        try Codec.fields(s,["sourceID","namespace","key","profileID","profileVersion","inputSHA256","publisherID","resourceID","feedRevision"])
        for k in ["sourceID","profileID","profileVersion","publisherID","resourceID","feedRevision"] { try text(s[k]) }
        try text(s["key"],max:4096); try Codec.sha(s["inputSHA256"])
        guard s["namespace"].text == "gtfs.trip_id" else { throw ConversionFailure.scopeConflict }
    }
    static func baseline(_ b: Wire) throws {
        try Codec.fields(b,["lineageID","schemaVersion","revision","registrySHA256"])
        try token(b["lineageID"]); try Codec.sha(b["registrySHA256"])
        try Codec.version(b,[2])
        guard b["revision"].int == 6 else { throw ConversionFailure.staleCheckpoint }
    }
    static func mapping(_ m: Wire) throws {
        try Codec.fields(m,["version","sha256"]); try text(m["version"]); try Codec.sha(m["sha256"])
    }
    static func evidence(_ e: Wire, source s: Wire, baseline b: Wire, mapping m: Wire) throws -> Wire {
        try Codec.array(e,max:7)
        var rolesSeen = Set<String>(), ids = Set<String>()
        for r in e.list {
            try Codec.fields(r,["role","evidenceID","sha256","locator","source","baseline","mapping"])
            try token(r["role"]); try token(r["evidenceID"]); try Codec.sha(r["sha256"]); try text(r["locator"],max:4096)
            try source(r["source"]); try baseline(r["baseline"]); try mapping(r["mapping"])
            guard (roles + ["s9Review"]).contains(r["role"].text), rolesSeen.insert(r["role"].text).inserted,
                  ids.insert(r["evidenceID"].text).inserted, Codec.equal(r["source"],s), Codec.equal(r["baseline"],b), Codec.equal(r["mapping"],m) else { throw ConversionFailure.correspondenceConflict }
        }
        guard Set(roles).isSubset(of:rolesSeen) else { throw ConversionFailure.correspondenceUnavailable }
        return .array(e.list.sorted { $0["role"].text < $1["role"].text })
    }
    static func context(_ c: Wire) throws -> Wire {
        try Codec.tagged(c,contextFormat)
        try Codec.fields(c,["format","schemaVersion","ownerAuthority","source","baseline","mapping","evidence"])
        try token(c["ownerAuthority"]); try source(c["source"]); try baseline(c["baseline"]); try mapping(c["mapping"])
        return c.replacing("evidence",try evidence(c["evidence"],source:c["source"],baseline:c["baseline"],mapping:c["mapping"]))
    }
    static func proposalDigest(_ p: Wire) throws -> String {
        Codec.hash(try canonical(.object(["domain":.string(format + "/proposal/v1"),"format":.string(format),"schemaVersion":.integer(1),"payload":p])))
    }
    static func approvedDigest(_ p: Wire, _ a: Wire) throws -> String {
        let metadata = a.replacing("approvedContentSHA256",nil)
        return Codec.hash(try canonical(.object(["domain":.string(format + "/approval/v1"),"format":.string(format),"schemaVersion":.integer(1),"payload":p,"ownerApproval":metadata])))
    }
    static func read(_ bytes: Data, context supplied: Wire) throws -> Wire {
        // Python accepts whitespace/escaping variants, limits depth32 and integer lexemes16.
        let d = try Codec.read(bytes,limit:limit,canonical:false)
        try RegistrationSyntax.scan(bytes,depth:32,integerDigits:16)
        try Codec.tagged(d,format); try Codec.fields(d,["format","schemaVersion","payload","approval"])
        let c = try context(supplied), p = d["payload"], a = d["approval"]
        try Codec.fields(p,["requestID","ownerAuthority","mode","source","baseline","mapping","baselineCapability","evidence","conclusion","unresolvedPrerequisites"])
        try token(p["requestID"]); try token(p["ownerAuthority"])
        try source(p["source"]); try baseline(p["baseline"]); try mapping(p["mapping"])
        guard p["mode"].text == "distinctNewRun", p["baselineCapability"].text == "noTripIdentityStateInIdentifiedBaseline" else { throw ConversionFailure.correspondenceConflict }
        for k in ["ownerAuthority","source","baseline","mapping"] { guard Codec.equal(p[k],c[k]) else { throw ConversionFailure.correspondenceConflict } }
        let e = try evidence(p["evidence"],source:p["source"],baseline:p["baseline"],mapping:p["mapping"])
        guard Codec.equal(e,c["evidence"]) else { throw ConversionFailure.correspondenceConflict }
        let con = p["conclusion"]
        try Codec.fields(con,["distinctNewRunRequested","existingCanonicalTripTarget","priorCanonicalTripBinding","acceptedCanonicalCompetitors","externalSemanticCompetition","semanticDistinctnessFromAllSourceRows","affirmativeReasoning","basisEvidenceIDs"])
        guard Codec.equal(con["distinctNewRunRequested"],.bool(true)), Codec.equal(con["existingCanonicalTripTarget"],.null),
              con["priorCanonicalTripBinding"].text == "noneStructurallyPossibleInPriorBaseline", con["acceptedCanonicalCompetitors"].text == "noneStructurallyPossibleInPriorBaseline",
              con["externalSemanticCompetition"].text == "notGloballyDisproved", Codec.equal(con["semanticDistinctnessFromAllSourceRows"],.bool(false)) else { throw ConversionFailure.correspondenceConflict }
        try text(con["affirmativeReasoning"],max:8192)
        try Codec.array(con["basisEvidenceIDs"],max:e.list.count)
        let basis = con["basisEvidenceIDs"].list
        for id in basis { try token(id) }
        let ids = Set(e.list.map { $0["evidenceID"].text }), bs = Set(basis.map(\.text))
        let required = Set(e.list.filter { ["sourceProfileAcceptance","candidateApplicability"].contains($0["role"].text) }.map { $0["evidenceID"].text })
        guard basis.count == bs.count, required.isSubset(of:bs), bs.isSubset(of:ids) else { throw ConversionFailure.correspondenceConflict }
        try Codec.array(p["unresolvedPrerequisites"],max:6)
        for id in p["unresolvedPrerequisites"].list { try token(id) }
        guard p["unresolvedPrerequisites"].list.count == 6, Set(p["unresolvedPrerequisites"].list.map(\.text)) == Set(prerequisites) else { throw ConversionFailure.correspondenceConflict }
        let normalized = p.replacing("evidence",e).replacing("conclusion",con.replacing("basisEvidenceIDs",.array(bs.sorted().map(Wire.string))))
            .replacing("unresolvedPrerequisites",.array(prerequisites.map(Wire.string)))
        if case .null = a { throw ConversionFailure.approvalMissing }
        try Codec.fields(a,["authorityID","approvedAt","proposalSHA256","approvedContentSHA256"])
        try token(a["authorityID"]); try Codec.timestamp(a["approvedAt"]); try Codec.sha(a["proposalSHA256"]); try Codec.sha(a["approvedContentSHA256"])
        guard a["approvedAt"].text.utf8.count == 20, let year = Int(a["approvedAt"].text.prefix(4)), year > 0 else { throw ConversionFailure.malformedInput }
        guard a["authorityID"].text == c["ownerAuthority"].text, a["proposalSHA256"].text == (try proposalDigest(normalized)),
              a["approvedContentSHA256"].text == (try approvedDigest(normalized,a)) else { throw ConversionFailure.approvalConflict }
        return d.replacing("payload",normalized)
    }
}

enum RegistrationSyntax {
    static func scan(_ bytes: Data, depth maximum: Int = 64, integerDigits: Int = 19) throws {
        var depth = 0, quoted = false, escaped = false, number = [UInt8]()
        func validateNumber() throws {
            if !number.isEmpty {
                guard number.count <= integerDigits else { throw ConversionFailure.resourceLimit }
                guard number.enumerated().allSatisfy({ (48...57).contains($0.element) || ($0.offset == 0 && $0.element == 45) }) else { throw ConversionFailure.malformedInput }
            }
        }
        for b in bytes {
            if quoted {
                if escaped { escaped = false } else if b == 92 { escaped = true } else if b == 34 { quoted = false }
            } else if b == 34 { try validateNumber(); number = []; quoted = true }
            else {
                if b == 123 || b == 91 { depth += 1; guard depth <= maximum else { throw ConversionFailure.resourceLimit } }
                if b == 125 || b == 93 { depth -= 1 }
                if !number.isEmpty && ![9,10,13,32,44,93,125,58].contains(b) { number.append(b) }
                else {
                    try validateNumber(); number = []
                    if (48...57).contains(b) || b == 45 { number.append(b) }
                }
            }
        }
        try validateNumber()
    }
}
