import Foundation

enum S9Failure: String, Error {
    case representationConflict, invalidStructure, selectionConflict, dependencyConflict
}

enum S9Limits {
    static let input = 24 * 1024 * 1024, dependency = 2 * 1024 * 1024
    static let expanded = 16 * 1024 * 1024, trip = 512 * 1024, crosswalk = 4 * 1024 * 1024
    static let context = 1024 * 1024, request = 40 * 1024 * 1024, approval = 16 * 1024
    static let state = 48 * 1024 * 1024, history = 48 * 1024 * 1024, manifest = 16 * 1024
    static let bundle = 56 * 1024 * 1024, occurrences = 2048, movements = 4096, dependencies = 256
    static let depth = 64, token = 256, selected = 4096
}

// S9 formats never alias synthetic packet or identity-registration approval formats.
enum S9 {
    static let operation = "selectInitialUntimedTripSnapshot"
    static let workflow = ["snapshotArtifactID", "requestID", "approvalReviewID", "outputID"]
    static let obligations = ["datedTimetableFacts", "originalIndexAssociations", "rideContexts", "continuityEligibility", "dataViewBindings"]
    static func tagged(_ name: String, _ fields: [String: Wire]) -> Wire {
        .object(fields.merging(["format":.string("tsugino.p2s9-" + name), "schemaVersion":.integer(1)]) { a,_ in a })
    }
    static func shape(_ v: Wire, _ name: String, _ fields: [String]) throws {
        try Codec.tagged(v,"tsugino.p2s9-" + name)
        try Codec.fields(v,["format","schemaVersion"] + fields)
    }
    static func bounded(_ b: Data, _ limit: Int) throws -> Data {
        guard !b.isEmpty, b.count <= limit else { throw ConversionFailure.resourceLimit }; return b
    }
    static func encode(_ v: Wire, _ limit: Int) throws -> Data { try bounded(Codec.encode(v),limit) }
    static func read(_ b: Data, _ limit: Int) throws -> Wire { try Registration.read(b,limit:limit) }
    static func pin(_ id: Wire) throws {
        try Codec.fields(id,["id","sha256"]); try Codec.token(id["id"]); try Codec.sha(id["sha256"])
    }
    static func pins(_ v: Wire, max: Int = S9Limits.dependencies) throws -> [String:String] {
        try Codec.array(v,max:max); try Codec.ordered(v.list.map { Data($0["id"].text.utf8) })
        var result: [String:String] = [:]
        for p in v.list { try pin(p); result[p["id"].text] = p["sha256"].text }; return result
    }
    static func checkpoint(_ c: Wire) throws {
        try Codec.fields(c,["lineageID","schemaVersion","revision","registrySHA256","historySHA256","manifestSHA256"])
        try Codec.token(c["lineageID"]); try Codec.version(c,[4])
        guard case .integer(let n) = c["revision"], n >= 0 else { throw ConversionFailure.malformedInput }
        for k in ["registrySHA256","historySHA256","manifestSHA256"] { try Codec.sha(c[k]) }
    }
    static func source(_ s: Wire) throws {
        try Codec.fields(s,["sourceID","namespace","key","inputSHA256"])
        try Codec.token(s["sourceID"]); try Codec.sha(s["inputSHA256"])
        guard s["namespace"].text == "gtfs.trip_id", case .string = s["key"],
              ExactValue(s["key"].text) != nil, s["key"].text.utf8.count <= S9Limits.token else { throw ConversionFailure.malformedInput }
    }
    static func identity(_ i: Wire) throws -> Set<String> {
        let c = i["registeredCheckpoint"], b = i["registeredBundle"]
        try checkpoint(c); try Codec.fields(b,["registryBytes","historyBytes","manifestBytes"])
        for (k,limit) in [("registry",Limits.registry),("history",Limits.history),("manifest",Limits.request)] {
            try Codec.bytes(b[k + "Bytes"],limit:limit)
            guard Codec.hash(b[k + "Bytes"].blob) == c[k + "SHA256"].text else { throw ConversionFailure.staleCheckpoint }
        }
        let r = try Registry4.read(b["registryBytes"].blob)
        _ = try Registration.verify(b["registryBytes"].blob,b["historyBytes"].blob,b["manifestBytes"].blob,owner:i["ownerAuthority"].text)
        let m = try read(b["manifestBytes"].blob,Limits.request)
        guard Codec.equal(m["lineageID"],c["lineageID"]), Codec.equal(r["revision"],c["revision"]),
              try Registry4.kind(i["registeredTripID"]) == "trp",
              r["entities"].list.contains(where: { Codec.equal($0["id"],i["registeredTripID"]) && $0["state"].text == "active" }) else { throw ConversionFailure.identityConflict }
        let s = i["source"]; try source(s)
        guard r["references"].list.contains(where: {
            Codec.equal($0["canonicalID"],i["registeredTripID"]) && Codec.equal($0["sourceID"],s["sourceID"]) &&
            Codec.equal($0["namespace"],s["namespace"]) && Codec.equal($0["value"],s["key"]) &&
            Codec.equal($0["firstSeenInputSHA256"],s["inputSHA256"]) && $0["status"]["state"].text == "active"
        }) else { throw ConversionFailure.referenceConflict }
        return Set(r["entities"].list.filter { $0["state"].text == "active" }.map { $0["id"].text })
    }
    // The caller supplies the complete S9 history inventory, explicitly attested by owner.
    // A tool cannot discover omitted external history or authenticate a human by a string.
    static func state(_ s: Wire, owner: Wire, trip: Wire) throws -> Set<String> {
        _ = try encode(s,S9Limits.state)
        try shape(s,"selection-state",["ownerAuthority","tripID","historyComplete","retainedAuthorityIDs","selections"])
        guard Codec.equal(s["ownerAuthority"],owner), Codec.equal(s["tripID"],trip), Codec.equal(s["historyComplete"],.bool(true)) else { throw ConversionFailure.historyUnavailable }
        try Codec.tokens(s["retainedAuthorityIDs"],max:S9Limits.selected)
        try Codec.array(s["selections"],max:1)
        var ids = Set(s["retainedAuthorityIDs"].list.map(\.text))
        for row in s["selections"].list {
            try Codec.fields(row,["tripID","snapshotArtifactID","manifestSHA256","historyBytes","manifestBytes"])
            guard Codec.equal(row["tripID"],trip), try Registry4.kind(row["tripID"]) == "trp" else { throw ConversionFailure.identityConflict }
            try Codec.token(row["snapshotArtifactID"]); try Codec.sha(row["manifestSHA256"])
            try Codec.bytes(row["historyBytes"],limit:S9Limits.history); try Codec.bytes(row["manifestBytes"],limit:S9Limits.manifest)
            guard Codec.hash(row["manifestBytes"].blob) == row["manifestSHA256"].text else { throw S9Failure.selectionConflict }
            ids.insert(row["snapshotArtifactID"].text)
        }
        return ids
    }
    struct Product { let trip: Data, crosswalk: Data, roots: Wire, activeIDs: Set<String> }
    static func reconstruct(_ i: Wire, artifact: Wire) throws -> Product {
        _ = try encode(i,S9Limits.input)
        try shape(i,"assembly-input",["ownerAuthority","inputID","registeredCheckpoint","registeredTripID","registeredBundle","source","views","movementReview","occurrences","movements","intervalEvidence","continuity","origin","destination","serviceType","dependencies"])
        try Codec.token(i["ownerAuthority"]); try Codec.token(i["inputID"]); try Codec.token(artifact)
        let activeIDs = try identity(i)
        let views = i["views"]
        try Codec.fields(views,["sourceRevision","profileRevision","mappingRevision","reviewRevision"])
        var roots: [Wire] = []
        func evidence(_ p: Wire) throws { try pin(p); roots.append(p) }
        for k in ["sourceRevision","profileRevision","mappingRevision","reviewRevision"] { try evidence(views[k]) }
        try evidence(i["movementReview"]); try evidence(i["intervalEvidence"])
        let co = i["continuity"]; try Codec.fields(co,["disposition","evidence"])
        guard ["notApplicable","proved"].contains(co["disposition"].text) else { throw ConversionFailure.continuityUnavailable }
        try evidence(co["evidence"])
        guard i["serviceType"].text == "unknown" else { throw ConversionFailure.scopeConflict }
        func endpoint(_ e: Wire) throws -> Bool {
            try Codec.fields(e,["disposition"], ["evidence"])
            guard ["reached","continued","unknownExtent"].contains(e["disposition"].text) else { throw ConversionFailure.malformedInput }
            if e.has("evidence") { try evidence(e["evidence"]) }
            else if e["disposition"].text != "unknownExtent" { throw ConversionFailure.preparationIncomplete }
            return e["disposition"].text == "reached"
        }
        let origin = try endpoint(i["origin"]), destination = try endpoint(i["destination"])
        try Codec.array(i["occurrences"],max:S9Limits.occurrences)
        var occurrences = i["occurrences"].list
        for o in occurrences {
            try Codec.fields(o,["locator","order","disposition","classificationEvidence"],["stationID","originalIndex","mappingEvidence","membership"])
            try Codec.token(o["locator"])
            guard case .integer(let n) = o["order"], n >= 0 else { throw ConversionFailure.malformedInput }
        }
        occurrences.sort { $0["order"].int < $1["order"].int }
        guard Set(occurrences.map { $0["locator"].text }).count == occurrences.count,
              Set(occurrences.map { $0["order"].int }).count == occurrences.count else { throw ConversionFailure.identityConflict }
        var stops: [StationID] = [], index: [String:Int] = [:], cross: [Wire] = []
        for (position,o) in occurrences.enumerated() {
            index[o["locator"].text] = position
            try evidence(o["classificationEvidence"])
            if o["disposition"].text == "passenger" {
                guard try Registry4.kind(o["stationID"]) == "stn", activeIDs.contains(o["stationID"].text),
                      case .integer(let n) = o["originalIndex"], n == stops.count,
                      let station = StationID(o["stationID"].text) else { throw S9Failure.invalidStructure }
                try evidence(o["mappingEvidence"])
                try Codec.array(o["membership"],max:S9Limits.dependencies)
                try Codec.ordered(o["membership"].list.map { Data($0["lineID"].text.utf8) })
                for m in o["membership"].list {
                    try Codec.fields(m,["lineID","evidence"])
                    guard try Registry4.kind(m["lineID"]) == "lin", activeIDs.contains(m["lineID"].text) else { throw ConversionFailure.identityConflict }
                    try evidence(m["evidence"])
                }
                stops.append(station)
            } else if o["disposition"].text == "passed" {
                guard !["stationID","originalIndex","mappingEvidence","membership"].contains(where:o.has) else { throw S9Failure.invalidStructure }
            } else { throw ConversionFailure.preparationIncomplete }
            cross.append(o)
        }
        guard stops.count >= 2, occurrences.first?["disposition"].text == "passenger", occurrences.last?["disposition"].text == "passenger" else { throw S9Failure.invalidStructure }
        try Codec.array(i["movements"],max:S9Limits.movements)
        var spans: [(a:Int,b:Int,line:String)] = []
        for m in i["movements"].list {
            try Codec.fields(m,["from","to","lineID","evidence"])
            try Codec.token(m["from"]); try Codec.token(m["to"]); try evidence(m["evidence"])
            guard let a = index[m["from"].text], let b = index[m["to"].text], a < b,
                  try Registry4.kind(m["lineID"]) == "lin", activeIDs.contains(m["lineID"].text) else { throw S9Failure.invalidStructure }
            for o in occurrences[a...b] where o["disposition"].text == "passenger" {
                guard o["membership"].list.contains(where: { Codec.equal($0["lineID"],m["lineID"]) }) else { throw S9Failure.invalidStructure }
            }
            spans.append((a,b,m["lineID"].text))
        }
        spans.sort { $0.a == $1.a ? $0.b < $1.b : $0.a < $1.a }
        guard spans.first?.a == 0, spans.last?.b == occurrences.count - 1 else { throw S9Failure.invalidStructure }
        var normalized: [(a:Int,b:Int,line:String)] = []
        for s in spans {
            if let last = normalized.last {
                guard s.a == last.b else { throw S9Failure.invalidStructure }
                if last.line == s.line { normalized[normalized.count - 1].b = s.b; continue }
                guard occurrences[s.a]["disposition"].text == "passenger" else { throw S9Failure.representationConflict }
            }
            normalized.append(s)
        }
        var segments: [TripLineSegment] = []
        for s in normalized {
            guard occurrences[s.a]["disposition"].text == "passenger", occurrences[s.b]["disposition"].text == "passenger",
                  let line = LineID(s.line), let segment = TripLineSegment(lineID:line,startIndex:occurrences[s.a]["originalIndex"].int,endIndex:occurrences[s.b]["originalIndex"].int) else { throw S9Failure.representationConflict }
            segments.append(segment)
        }
        guard co["disposition"].text == "proved" || normalized.count == 1 else { throw ConversionFailure.continuityUnavailable }
        guard let id = TripID(i["registeredTripID"].text), let trip = Trip(id:id,stopSequence:stops,lineSegments:segments,coverage:.init(includesServiceOrigin:origin,includesServiceDestination:destination),serviceTypeSegments:[]) else { throw S9Failure.invalidStructure }
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys,.withoutEscapingSlashes]
        let tripBytes = try bounded(encoder.encode(trip),S9Limits.trip)
        let decoded = try JSONDecoder().decode(Trip.self,from:tripBytes)
        guard try encoder.encode(decoded) == tripBytes else { throw S9Failure.invalidStructure }
        let walk = tagged("crosswalk",["registeredCheckpoint":i["registeredCheckpoint"],"tripID":i["registeredTripID"],"snapshotArtifactID":artifact,"source":i["source"],"views":views,"occurrences":.array(cross)])
        let walkBytes = try encode(walk,S9Limits.crosswalk)
        guard try Codec.encode(read(walkBytes,S9Limits.crosswalk)) == walkBytes else { throw S9Failure.invalidStructure }
        let rootPins = try closure(i["dependencies"],roots:roots)
        return .init(trip:tripBytes,crosswalk:walkBytes,roots:rootPins,activeIDs:activeIDs)
    }
    static func closure(_ records: Wire, roots: [Wire]) throws -> Wire {
        try Codec.array(records,max:S9Limits.dependencies)
        try Codec.ordered(records.list.map { Data($0["id"].text.utf8) })
        var rows: [String:Wire] = [:], unique: [String:Int] = [:]
        for r in records.list {
            try Codec.fields(r,["id","sha256","bytes","dependencyDigests"]); try pin(r.replacing("bytes",nil).replacing("dependencyDigests",nil))
            try Codec.bytes(r["bytes"],limit:S9Limits.dependency)
            guard Codec.hash(r["bytes"].blob) == r["sha256"].text else { throw S9Failure.dependencyConflict }
            _ = try pins(r["dependencyDigests"])
            rows[r["id"].text] = r; unique[r["sha256"].text] = r["bytes"].blob.count
        }
        guard unique.values.reduce(0,+) <= S9Limits.expanded else { throw ConversionFailure.resourceLimit }
        var visited = Set<String>(), active = Set<String>()
        for root in roots {
            var pending: [(Wire,Bool)] = [(root,false)]
            while let (p,exit) = pending.popLast() {
                let id = p["id"].text
                if exit { active.remove(id); visited.insert(id); continue }
                guard let row = rows[id], Codec.equal(row["sha256"],p["sha256"]) else { throw S9Failure.dependencyConflict }
                if active.contains(id) { throw S9Failure.dependencyConflict }
                if visited.contains(id) { continue }
                active.insert(id); pending.append((p,true))
                pending += row["dependencyDigests"].list.reversed().map { ($0,false) }
            }
        }
        guard visited == Set(rows.keys) else { throw S9Failure.dependencyConflict }
        return .array(records.list.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) })
    }
}
