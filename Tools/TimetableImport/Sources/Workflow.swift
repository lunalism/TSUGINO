import Foundation

extension ImportAuthority {
    static func address(_ i: Wire) -> Wire { .object(["viewID":i["viewID"],"tripID":i["tripID"],"serviceDate":i["serviceDate"]]) }
    static func facts(_ f: TimetableOccurrenceFacts, input i: Wire) throws -> Data {
        func time(_ t: TimetableTime) throws -> Wire {
            switch t {
            case .missing: return .object(["state":.string("missing")])
            case .exact(let v), .estimated(let v):
                let n = v.date.timeIntervalSince1970
                guard n.isFinite, n >= Double(ImportCivilTime.minimum), n < Double(ImportCivilTime.maximum), n.rounded() == n,
                      let value = Int(exactly:n) else { throw ConversionFailure.malformedInput }
                let exact: Bool; if case .exact = t { exact = true } else { exact = false }
                return .object(["state":.string(exact ? "exact" : "estimated"),"unixSeconds":.integer(value)])
            }
        }
        func permission(_ p: TimetableEligibility) -> Wire {
            switch p { case .allowed: .string("allowed"); case .prohibited: .string("prohibited"); case .unknown: .string("unknown") }
        }
        let visits = try f.visits.map { v in
            Wire.object(["originalIndex":.integer(v.originalIndex),"arrival":try time(v.arrival),"departure":try time(v.departure),
                "boarding":permission(v.boarding),"alighting":permission(v.alighting)])
        }
        return try encode(tagged("occurrence-facts",["address":address(i),"s9":i["s9"],"profile":i["profile"],"visits":.array(visits)]),ImportLimits.facts)
    }
    static func reconstructFacts(_ bytes: Data, external e: External) throws -> TimetableOccurrenceFacts {
        let f = try read(bytes,ImportLimits.facts)
        try shape(f,"occurrence-facts",["address","s9","profile","visits"])
        guard Codec.equal(f["s9"],e.s9Pins), Codec.equal(f["profile"],e.profilePins) else { throw ConversionFailure.staleCheckpoint }
        let a = f["address"]; try Codec.fields(a,["viewID","tripID","serviceDate"])
        let trip = try e.trip()
        guard let uuid = UUID(uuidString:a["viewID"].text), exact(uuid.uuidString.lowercased(),a["viewID"].text),
              Codec.equal(a["tripID"],.string(trip.id.rawValue)), let date = TimetableServiceDate(a["serviceDate"].text),
              case .value = ImportCivilTime.date(date.label) else { throw ConversionFailure.identityConflict }
        let binding = TimetableOccurrenceBinding(address:.init(viewID:.init(uuid),tripID:trip.id,serviceDate:date),trip:trip)!
        try Codec.array(f["visits"],max:256)
        func time(_ t: Wire) throws -> TimetableTime {
            if t["state"].text == "missing" { try Codec.fields(t,["state"]); return .missing }
            try Codec.fields(t,["state","unixSeconds"])
            let n = try integer(t["unixSeconds"])
            guard (ImportCivilTime.minimum..<ImportCivilTime.maximum).contains(n), let instant = TimetableInstant(Date(timeIntervalSince1970:Double(n))) else { throw ConversionFailure.malformedInput }
            switch t["state"].text { case "exact": return .exact(instant); case "estimated": return .estimated(instant); default: throw ConversionFailure.malformedInput }
        }
        func permission(_ p: Wire) throws -> TimetableEligibility {
            switch p.text { case "allowed": return .allowed; case "prohibited": return .prohibited; case "unknown": return .unknown; default: throw ConversionFailure.malformedInput }
        }
        let visits = try f["visits"].list.map { r -> TimetableVisitFacts in
            try Codec.fields(r,["originalIndex","arrival","departure","boarding","alighting"])
            let index = try integer(r["originalIndex"])
            guard let n = Int(exactly:index), let visit = TimetableVisitFacts(binding:binding,originalIndex:n,
                arrival:try time(r["arrival"]),departure:try time(r["departure"]),boarding:try permission(r["boarding"]),alighting:try permission(r["alighting"])) else { throw ConversionFailure.identityConflict }
            return visit
        }
        guard let facts = TimetableOccurrenceFacts(binding:binding,visits:visits) else { throw ConversionFailure.identityConflict }
        return facts
    }
    static func state(_ s: Wire, owner: String, address a: Wire) throws {
        _ = try read(encode(s,ImportLimits.state),ImportLimits.state)
        try shape(s,"import-state",["ownerAuthority","address","historyComplete","imports"])
        guard Codec.equal(s["ownerAuthority"],.string(owner)), Codec.equal(s["address"],a), Codec.equal(s["historyComplete"],.bool(true)) else { throw ConversionFailure.historyUnavailable }
        try Codec.array(s["imports"],max:1)
        for r in s["imports"].list {
            try Codec.fields(r,["manifestSHA256","manifestBytes","historyBytes"])
            try Codec.sha(r["manifestSHA256"]); try Codec.bytes(r["manifestBytes"],limit:ImportLimits.manifest); try Codec.bytes(r["historyBytes"],limit:ImportLimits.history)
            guard Codec.hash(r["manifestBytes"].blob) == r["manifestSHA256"].text else { throw ConversionFailure.historyConflict }
        }
    }
    enum Prepared { case request(Wire), outcome(ImportOutcome) }
    static func prepare(_ i: Wire, state s: Wire, requestID: String, approvalReviewID: String, outputID: String, external e: External) throws -> Prepared {
        let result = try convert(i,external:e)
        try state(s,owner:e.owner,address:address(i))
        guard s["imports"].list.isEmpty else { throw ConversionFailure.historyConflict }
        let tokens = [requestID,approvalReviewID,outputID]
        for t in tokens { try token(t) }
        guard Set(tokens.map { Data($0.utf8) }).count == 3,
              !tokens.contains(where:{ exact($0,i["inputID"].text) || exact($0,e.owner) }) else { throw ConversionFailure.identityConflict }
        guard case .success(let f) = result.outcome else { return .outcome(result.outcome) }
        let bytes = try facts(f,input:i)
        _ = try reconstructFacts(bytes,external:e)
        let q = tagged("import-request",["requestID":.string(requestID),"approvalReviewID":.string(approvalReviewID),"outputID":.string(outputID),
            "ownerAuthority":.string(e.owner),"operation":.string(operation),"address":address(i),"s9":e.s9Pins,"profile":e.profilePins,
            "inputBytes":Codec.blob(try encode(i,ImportLimits.input)),"inputSHA256":.string(try Codec.digest(i)),"initialState":s,
            "factsBytes":Codec.blob(bytes),"factsSHA256":.string(Codec.hash(bytes)),"dependencyDigests":result.dependencies])
        _ = try encode(q,ImportLimits.request); return .request(q)
    }
    @discardableResult static func request(_ q: Wire, external e: External) throws -> TimetableOccurrenceFacts {
        _ = try read(encode(q,ImportLimits.request),ImportLimits.request)
        try shape(q,"import-request",["requestID","approvalReviewID","outputID","ownerAuthority","operation","address","s9","profile","inputBytes","inputSHA256","initialState","factsBytes","factsSHA256","dependencyDigests"])
        try Codec.bytes(q["inputBytes"],limit:ImportLimits.input); try Codec.bytes(q["factsBytes"],limit:ImportLimits.facts)
        let i = try read(q["inputBytes"].blob,ImportLimits.input)
        let p = try prepare(i,state:q["initialState"],requestID:q["requestID"].text,approvalReviewID:q["approvalReviewID"].text,outputID:q["outputID"].text,external:e)
        guard case .request(let expected) = p, Codec.equal(expected,q) else { throw ConversionFailure.historyConflict }
        return try reconstructFacts(q["factsBytes"].blob,external:e)
    }
    static func approve(_ q: Wire, external e: External, reviewer: String, at: String, reference: String) throws -> Wire {
        _ = try request(q,external:e)
        try token(reviewer); try token(reference); try Codec.timestamp(.string(at))
        return tagged("import-approval",["requestFormat":q["format"],"requestID":q["requestID"],"requestSHA256":.string(try Codec.digest(q)),
            "ownerAuthority":q["ownerAuthority"],"reviewID":q["approvalReviewID"],"reviewer":.string(reviewer),"approvedAt":.string(at),"approvalReference":.string(reference)])
    }
    static func approval(_ a: Wire, request q: Wire, external e: External) throws {
        if case .null = a { throw ConversionFailure.approvalMissing }
        _ = try read(encode(a,ImportLimits.approval),ImportLimits.approval)
        try shape(a,"import-approval",["requestFormat","requestID","requestSHA256","ownerAuthority","reviewID","reviewer","approvedAt","approvalReference"])
        let expected = try approve(q,external:e,reviewer:a["reviewer"].text,at:a["approvedAt"].text,reference:a["approvalReference"].text)
        guard Codec.equal(a,expected) else { throw ConversionFailure.approvalConflict }
    }
    struct Bundle {
        let files: [String:Data], replay: Bool
        var manifest: Data { files["manifest.json"]! }
    }
    static func bundle(_ q: Wire, approval a: Wire, external e: External) throws -> Bundle {
        try approval(a,request:q,external:e)
        let h = tagged("import-history",["ownerAuthority":q["ownerAuthority"],"operation":.string(operation),"request":q,"approval":a])
        let hb = try encode(h,ImportLimits.history)
        let m = tagged("import-bundle",["operation":.string(operation),"outputID":q["outputID"],"address":q["address"],"s9":q["s9"],"profile":q["profile"],
            "factsSHA256":q["factsSHA256"],"historySHA256":.string(Codec.hash(hb)),"requestSHA256":.string(try Codec.digest(q)),"approvalSHA256":.string(try Codec.digest(a)),
            "dependencyRootSHA256":.string(try Codec.digest(q["dependencyDigests"]))])
        let files = ["facts.json":q["factsBytes"].blob,"history.json":hb,"manifest.json":try encode(m,ImportLimits.manifest)]
        guard files.values.reduce(0,{ $0 + $1.count }) <= ImportLimits.bundle else { throw ConversionFailure.resourceLimit }
        return .init(files:files,replay:false)
    }
    static func verify(_ files: [String:Data], manifestSHA: String, external e: External) throws -> Bundle {
        guard Set(files.keys) == Set(ImportIO.fileLimits.keys), files.values.reduce(0,{ $0 + $1.count }) <= ImportLimits.bundle else { throw ConversionFailure.resourceLimit }
        for (name,limit) in ImportIO.fileLimits { _ = try S9.bounded(files[name]!,limit) }
        guard Codec.hash(files["manifest.json"]!) == manifestSHA else { throw ConversionFailure.historyConflict }
        let h = try read(files["history.json"]!,ImportLimits.history)
        try shape(h,"import-history",["ownerAuthority","operation","request","approval"])
        let b = try bundle(h["request"],approval:h["approval"],external:e)
        guard b.files == files else { throw ConversionFailure.historyConflict }
        return .init(files:files,replay:true)
    }
    static func importedState(_ initial: Wire, bundle b: Bundle) -> Wire {
        initial.replacing("imports",.array([.object(["manifestSHA256":.string(Codec.hash(b.manifest)),"manifestBytes":Codec.blob(b.manifest),"historyBytes":Codec.blob(b.files["history.json"]!)])]))
    }
    static func apply(_ q: Wire, approval supplied: Wire?, currentState s: Wire, external e: External) throws -> Bundle {
        _ = try request(q,external:e); try state(s,owner:e.owner,address:q["address"])
        let a: Wire
        if let supplied { a = supplied }
        else if let retained = s["imports"].list.first {
            a = try read(retained["historyBytes"].blob,ImportLimits.history)["approval"]
        } else { throw ConversionFailure.approvalMissing }
        let b = try bundle(q,approval:a,external:e)
        if s["imports"].list.isEmpty {
            guard Codec.equal(s,q["initialState"]) else { throw ConversionFailure.historyConflict }; return b
        }
        guard Codec.equal(s,importedState(q["initialState"],bundle:b)) else { throw ConversionFailure.historyConflict }
        return .init(files:b.files,replay:true)
    }
    static func status(_ o: ImportOutcome) -> String {
        switch o { case .success: return "status=active"; case .inactive: return "status=inactive"
        case .insufficientEvidence(let f): return "status=insufficientEvidence reason=" + f.reason.rawValue
        case .unsupported(let f): return "status=unsupported reason=" + f.reason.rawValue
        case .invalid(let f): return "status=invalid reason=" + f.reason.rawValue }
    }
    static func summary(_ f: TimetableOccurrenceFacts) -> String {
        var exact = 0, estimated = 0, missing = 0
        for v in f.visits { for t in [v.arrival,v.departure] { switch t { case .exact: exact += 1; case .estimated: estimated += 1; case .missing: missing += 1 } } }
        return "visits=\(f.visits.count) exact=\(exact) estimated=\(estimated) missing=\(missing)"
    }
}
