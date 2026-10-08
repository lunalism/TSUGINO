import Foundation

// Separate schema-4 parser: shared schema-2 types and consumers stay closed.
enum Registry4 {
    static let kinds = ["stn", "lin", "opr", "trp"]
    static func kind(_ v: Wire) throws -> String {
        let b = Array(v.text.utf8)
        guard b.count == 20, b[3] == 95, b.dropFirst(4).allSatisfy(MintedIdentifier.alphabet.contains),
              kinds.contains(String(decoding: b.prefix(3), as: UTF8.self)) else { throw ConversionFailure.malformedInput }
        return String(decoding: b.prefix(3), as: UTF8.self)
    }
    static func reference(_ v: Wire) throws {
        try Codec.fields(v, ["canonicalID","sourceID","namespace","value","status","firstSeenInputSHA256","provenance","originalNames"], ["attachedBy"])
        let k = try kind(v["canonicalID"])
        let ns = v["namespace"].text
        let legacy = ProviderNamespace(rawValue: ns)
        guard legacy != nil || ns == "gtfs.trip_id", (legacy?.kind.rawValue ?? "trp") == k else { throw ConversionFailure.identityConflict }
        try Codec.token(v["sourceID"]); try Codec.sha(v["firstSeenInputSHA256"])
        guard ExactValue(v["value"].text) != nil else { throw ConversionFailure.malformedInput }
        if v.has("attachedBy") { try Codec.token(v["attachedBy"]) }
        if ns == "gtfs.trip_id" && v["attachedBy"].text.isEmpty { throw ConversionFailure.approvalMissing }
        // Reuse unchanged exact-value/provenance/name/status validators, never reinterpret keys.
        let d = JSONDecoder()
        do {
            let status = try d.decode(ProviderReferenceStatus.self, from: Codec.encode(v["status"]))
            guard try Codec.encode(v["status"]) == encoded(status) else { throw ConversionFailure.malformedInput }
            let p = try d.decode(SourceReference.self, from: Codec.encode(v["provenance"]))
            guard try Codec.encode(v["provenance"]) == encoded(p), p.isGTFSPosition == (legacy?.isGTFS ?? true) else { throw ConversionFailure.malformedInput }
            try Codec.array(v["originalNames"], max: Limits.records)
            let names = try d.decode([OriginalName].self, from: Codec.encode(v["originalNames"]))
            guard names.allSatisfy({ $0.source.isGTFSPosition == p.isGTFSPosition }), Set(names).count == names.count,
                  try Codec.encode(v["originalNames"]) == encoded(names.sorted(by: OriginalName.precedes)) else { throw ConversionFailure.malformedInput }
        } catch let f as ConversionFailure { throw f } catch { throw ConversionFailure.malformedInput }
    }
    static func encoded<T: Encodable>(_ v: T) throws -> Data {
        let e = JSONEncoder(); e.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]; return try e.encode(v)
    }
    static func key(_ ref: Wire) throws -> Data { try Codec.encode(.array([ref["sourceID"],ref["namespace"],ref["value"]])) }
    static func read(_ bytes: Data) throws -> Wire {
        let v = try Codec.read(bytes, limit: Limits.registry, pretty: true)
        try validate(v); return v
    }
    static func validate(_ v: Wire) throws {
        try Codec.version(v, [4]); try Codec.fields(v, ["schemaVersion","revision","entities","references"])
        guard case .integer(let revision) = v["revision"], revision >= 0 else { throw ConversionFailure.malformedInput }
        try Codec.array(v["entities"], max: Limits.entities); try Codec.array(v["references"], max: Limits.references)
        let es = v["entities"].list
        try Codec.ordered(es.map { Data($0["id"].text.utf8) })
        var index: [String: Wire] = [:]
        for e in es {
            try Codec.fields(e, ["id","state"], ["successors"]); let k = try kind(e["id"])
            guard ["active","retired"].contains(e["state"].text) else { throw ConversionFailure.malformedInput }
            if e["state"].text == "active" { guard case .null = e["successors"] else { throw ConversionFailure.malformedInput } }
            else {
                guard k != "trp" else { throw ConversionFailure.identityConflict }
                try Codec.tokens(e["successors"], max: Limits.entities)
                for s in e["successors"].list { guard try kind(s) == k, s.text != e["id"].text else { throw ConversionFailure.identityConflict } }
            }
            index[e["id"].text] = e
        }
        var finished = Set<String>(), visiting = Set<String>()
        // Iterative graph walk: large registries cannot overflow the Swift call stack.
        for e in es {
            var stack: [(String,Bool)] = [(e["id"].text,false)]
            while let (id, exiting) = stack.popLast() {
                if exiting { visiting.remove(id); finished.insert(id); continue }
                if visiting.contains(id) { throw ConversionFailure.identityConflict }
                if finished.contains(id) { continue }
                guard let row = index[id] else { throw ConversionFailure.identityConflict }
                visiting.insert(id); stack.append((id,true))
                for s in row["successors"].list.reversed() { stack.append((s.text,false)) }
            }
        }
        let refs = v["references"].list
        // Order by the full scalar-exact tuple, not an encoded/escaped key's collation.
        for (a,b) in zip(refs, refs.dropFirst()) { guard less(a,b) else { throw ConversionFailure.identityConflict } }
        for r in refs {
            try reference(r)
            guard let entity = index[r["canonicalID"].text], r["status"]["state"].text != "active" || entity["state"].text == "active" else { throw ConversionFailure.identityConflict }
        }
    }
    static func less(_ a: Wire, _ b: Wire) -> Bool {
        for field in ["sourceID","namespace","value"] {
            let l = Data(a[field].text.utf8), r = Data(b[field].text.utf8)
            if l != r { return l.lexicographicallyPrecedes(r) }
        }
        return false
    }
    static func legacy(_ bytes: Data) throws -> Wire {
        let original = try Codec.read(bytes, limit: Limits.registry, canonical: false)
        try Codec.version(original, [2])
        try Codec.array(original["entities"], max: Limits.entities); try Codec.array(original["references"], max: Limits.references)
        do {
            let r = try MappingRegistry.decoded(from: bytes)
            // Canonical comparison view; original bytes are always retained, never rehashed as this view.
            return try Codec.read(r.encoded(), limit: Limits.registry, pretty: true)
        } catch { throw ConversionFailure.malformedInput }
    }
    static func target(_ previous: Data) throws -> Data {
        let p = try legacy(previous)
        guard p["revision"].int < Int.max else { throw ConversionFailure.resourceLimit }
        let next = p.replacing("schemaVersion", .integer(4)).replacing("revision", .integer(p["revision"].int + 1))
        try validate(next)
        return try Codec.encode(next, pretty: true)
    }
    static func conversion(_ previous: Data, _ target: Data) throws {
        let t = try read(target)
        guard !t["entities"].list.contains(where: { $0["id"].text.hasPrefix("trp_") }),
              !t["references"].list.contains(where: { $0["namespace"].text == "gtfs.trip_id" }),
              try self.target(previous) == target else { throw ConversionFailure.identityConflict }
    }
}
