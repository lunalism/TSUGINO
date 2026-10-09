import Foundation

// All bounds are single-occurrence design limits, independent of private real artifact sizes.
enum ImportLimits {
    static let input = 4 * 1024 * 1024, review = 2 * 1024 * 1024
    static let approval = 16 * 1024, facts = 256 * 1024, request = 6 * 1024 * 1024
    static let state = 12 * 1024 * 1024, history = 8 * 1024 * 1024, manifest = 16 * 1024
    static let bundle = 9 * 1024 * 1024, dependencies = 64, dependency = 32 * 1024
    static let expanded = 1024 * 1024, depth = 32
}

enum ImportAuthority {
    static let operation = "importDatedOccurrenceFacts"
    static func tagged(_ name: String, _ fields: [String:Wire]) -> Wire {
        .object(fields.merging(["format":.string("tsugino.p3t1-" + name),"schemaVersion":.integer(1)]) { a,_ in a })
    }
    static func shape(_ value: Wire, _ name: String, _ fields: [String]) throws {
        try Codec.tagged(value,"tsugino.p3t1-" + name)
        try Codec.fields(value,["format","schemaVersion"] + fields)
    }
    static func encode(_ value: Wire, _ limit: Int) throws -> Data { try S9.bounded(Codec.encode(value),limit) }
    static func read(_ bytes: Data, _ limit: Int) throws -> Wire {
        // Depth check precedes the unchanged duplicate-key and canonical decoder.
        var depth = 0, quoted = false, escaped = false
        for byte in try S9.bounded(bytes,limit) {
            if quoted { if escaped { escaped = false } else if byte == 92 { escaped = true } else if byte == 34 { quoted = false } }
            else if byte == 34 { quoted = true }
            else if byte == 123 || byte == 91 { depth += 1; guard depth <= ImportLimits.depth else { throw ConversionFailure.resourceLimit } }
            else if byte == 125 || byte == 93 { depth -= 1 }
        }
        return try Codec.read(bytes,limit:limit)
    }
    static func token(_ text: String) throws { try Codec.token(.string(text)) }
    static func exact(_ a: String, _ b: String) -> Bool { Data(a.utf8) == Data(b.utf8) }
    static func integer(_ v: Wire) throws -> Int64 {
        guard case .integer(let i) = v, let n = Int64(exactly:i) else { throw ConversionFailure.malformedInput }; return n
    }
    static func text(_ v: Wire) throws -> String {
        guard case .string(let s) = v, s.utf8.count <= 256 else { throw ConversionFailure.malformedInput }; return s
    }
    static func optionalText(_ v: Wire, _ key: String) throws -> String? { v.has(key) ? try text(v[key]) : nil }
    static func profileApproval(review: Data, owner: String, profile: String, reviewID: String,
                                reviewer: String, at: String, reference: String) throws -> Wire {
        _ = try S9.bounded(review,ImportLimits.review)
        for t in [owner,profile,reviewID,reviewer,reference] { try token(t) }; try Codec.timestamp(.string(at))
        return tagged("source-profile-approval",["ownerAuthority":.string(owner),"profileID":.string(profile),"reviewID":.string(reviewID),
            "profileReviewSHA256":.string(Codec.hash(review)),"reviewer":.string(reviewer),"approvedAt":.string(at),"approvalReference":.string(reference)])
    }
    struct External {
        let owner: String, s9: S9.Bundle, review: Data, approval: Data
        init(owner: String, s9Files: [String:Data], manifestSHA: String, review: Data, approval: Data) throws {
            try token(owner)
            self.owner = owner
            self.s9 = try S9.verify(s9Files,owner:owner,manifestSHA:manifestSHA)
            self.review = try S9.bounded(review,ImportLimits.review)
            self.approval = try S9.bounded(approval,ImportLimits.approval)
            let a = try read(approval,ImportLimits.approval)
            try shape(a,"source-profile-approval",["ownerAuthority","profileID","reviewID","profileReviewSHA256","reviewer","approvedAt","approvalReference"])
            let expected = try profileApproval(review:review,owner:owner,profile:a["profileID"].text,reviewID:a["reviewID"].text,
                reviewer:a["reviewer"].text,at:a["approvedAt"].text,reference:a["approvalReference"].text)
            guard Codec.equal(a,expected) else { throw ConversionFailure.approvalConflict }
        }
        var s9Pins: Wire { .object(["manifestSHA256":.string(Codec.hash(s9.manifest)),"tripSHA256":.string(Codec.hash(s9.files["trip.json"]!)),
            "crosswalkSHA256":.string(Codec.hash(s9.files["crosswalk.json"]!))]) }
        var profilePins: Wire {
            let a = try! ImportAuthority.read(approval,ImportLimits.approval) // Validated in the sole initializer.
            return .object(["profileID":a["profileID"],"reviewID":a["reviewID"],"reviewSHA256":.string(Codec.hash(review)),"approvalSHA256":.string(Codec.hash(approval))])
        }
        func trip() throws -> Trip { try JSONDecoder().decode(Trip.self,from:s9.files["trip.json"]!) }
        func crosswalk() throws -> Wire { try S9.read(s9.files["crosswalk.json"]!,S9Limits.crosswalk) }
    }
    struct Conversion { let outcome: ImportOutcome, dependencies: Wire }
    static func convert(_ input: Wire, external e: External) throws -> Conversion {
        // Validation also applies to direct API callers, not only CLI-decoded bytes.
        let i = try read(encode(input,ImportLimits.input),ImportLimits.input)
        try shape(i,"import-input",["ownerAuthority","inputID","s9","profile","source","revisions","viewID","tripID","serviceDate","run","service",
            "profileEvidence","executionEvidence","evidence","calendar","zone","visits","dependencies"])
        for k in ["ownerAuthority","inputID"] { try Codec.token(i[k]) }
        for k in ["run","service"] {
            guard case .string = i[k], ExactValue(i[k].text) != nil, i[k].text.utf8.count <= 256 else { throw ConversionFailure.malformedInput }
        }
        guard Codec.equal(i["ownerAuthority"],.string(e.owner)), Codec.equal(i["s9"],e.s9Pins), Codec.equal(i["profile"],e.profilePins) else { throw ConversionFailure.staleCheckpoint }
        let trip = try e.trip(), walk = try e.crosswalk()
        guard Codec.equal(i["tripID"],.string(trip.id.rawValue)), let uuid = UUID(uuidString:i["viewID"].text),
              exact(uuid.uuidString.lowercased(),i["viewID"].text), let date = TimetableServiceDate(i["serviceDate"].text) else { throw ConversionFailure.identityConflict }
        let source = i["source"]
        try Codec.fields(source,["archiveSHA256","revision","s9Source"])
        try Codec.sha(source["archiveSHA256"]); try Codec.token(source["revision"])
        guard Codec.equal(source["s9Source"],walk["source"]), Codec.equal(i["run"],walk["source"]["key"]) else { throw ConversionFailure.referenceConflict }
        let rev = i["revisions"]
        try Codec.fields(rev,["source","profile","zone","mapping","review"])
        for k in ["source","profile","zone","mapping","review"] { try Codec.token(rev[k]) }
        guard Codec.equal(rev["source"],source["revision"]), Codec.equal(rev["profile"],i["profile"]["profileID"]) else { throw ConversionFailure.referenceConflict }
        let revision = ImportRevision(source:rev["source"].text,profile:rev["profile"].text,zone:rev["zone"].text,mapping:rev["mapping"].text)
        let address = TimetableOccurrenceAddress(viewID:TimetableViewID(uuid),tripID:trip.id,serviceDate:date)
        guard let binding = TimetableOccurrenceBinding(address:address,trip:trip) else { throw ConversionFailure.identityConflict }
        try Codec.array(i["evidence"],max:64)
        var roots: [Wire] = [], evidence: [ImportEvidence] = []
        for row in i["evidence"].list {
            try Codec.fields(row,["id","revisions","run","service","assertion","scope","pin"])
            try Codec.token(row["id"]); try S9.pin(row["pin"]); roots.append(row["pin"])
            guard Codec.equal(row["revisions"],rev), Codec.equal(row["run"],i["run"]), Codec.equal(row["service"],i["service"]) else { throw ConversionFailure.referenceConflict }
            let assertion: ImportAssertion
            switch row["assertion"].text {
            case "profileApplicable": assertion = .profileApplicable
            case "calendarComplete": assertion = .calendarComplete
            case "singleExecution": assertion = .singleExecution
            case "multipleExecutions": assertion = .multipleExecutions
            case "unknownMultiplicity": assertion = .unknownMultiplicity
            case "exact": assertion = .exact
            case "estimated": assertion = .estimated
            case "allowed": assertion = .allowed
            case "prohibited": assertion = .prohibited
            default: throw ConversionFailure.malformedInput
            }
            let s = row["scope"], scope: ImportScope
            if s["kind"].text == "wholeRun" { try Codec.fields(s,["kind"]); scope = .wholeRun }
            else {
                try Codec.fields(s,["kind","first","last","selector"])
                guard s["kind"].text == "indices" else { throw ConversionFailure.malformedInput }
                let selector: ImportSelector
                switch s["selector"].text { case "arrival": selector = .arrival; case "departure": selector = .departure
                case "boarding": selector = .boarding; case "alighting": selector = .alighting; default: throw ConversionFailure.malformedInput }
                scope = .indices(first:try integer(s["first"]),last:try integer(s["last"]),selector:selector)
            }
            evidence.append(.init(id:row["id"].text,revision:revision,run:i["run"].text,service:i["service"].text,assertion:assertion,scope:scope))
        }
        let closure = try dependencies(i["dependencies"],roots:roots)
        let calendar = try calendar(i["calendar"]), zone = try zone(i["zone"])
        try Codec.array(i["visits"],max:256)
        let passengers = walk["occurrences"].list.filter { $0["disposition"].text == "passenger" }
        var visits: [ImportVisit] = []
        for row in i["visits"].list {
            try Codec.fields(row,["originalIndex","occurrence","mappingRevision"],["arrival","departure","boarding","alighting"])
            let n = try integer(row["originalIndex"])
            try Codec.token(row["mappingRevision"]); try Codec.token(row["occurrence"])
            let expectedOccurrence = n >= 0 && n < Int64(passengers.count) ? passengers[Int(n)]["locator"].text : nil
            visits.append(.init(index:n,occurrence:row["occurrence"].text,mappingRevision:row["mappingRevision"].text,expectedOccurrence:expectedOccurrence,
                arrival:try event(row,"arrival"),departure:try event(row,"departure"),boarding:try permission(row,"boarding"),alighting:try permission(row,"alighting")))
        }
        let manifest = ImportManifest(binding:binding,revision:revision,profileEvidence:try text(i["profileEvidence"]),executionEvidence:try text(i["executionEvidence"]))
        let packet = ImportPacket(binding:binding,serviceDate:i["serviceDate"].text,run:i["run"].text,service:i["service"].text,revision:revision,
            manifest:manifest,evidence:evidence,calendar:calendar,zone:zone,visits:visits)
        let outcome = ImportConverter.convert(packet)
        return .init(outcome:outcome,dependencies:closure)
    }
    static func dependencies(_ rows: Wire, roots: [Wire]) throws -> Wire {
        try Codec.array(rows,max:ImportLimits.dependencies)
        var total = 0
        for row in rows.list {
            try Codec.bytes(row["bytes"],limit:ImportLimits.dependency)
            total += row["bytes"].blob.count
            try Codec.array(row["dependencyDigests"],max:ImportLimits.dependencies)
        }
        guard total <= ImportLimits.expanded else { throw ConversionFailure.resourceLimit }
        return try S9.closure(rows,roots:roots)
    }
    static func calendar(_ c: Wire) throws -> ImportCalendar? {
        // Explicit empty object represents missing evidence, not an inferred calendar.
        if Codec.equal(c,.object([:])) { return nil }
        try Codec.fields(c,["coverageStart","coverageEnd","baselines","exceptions"],["mode","completenessEvidence"])
        try Codec.array(c["baselines"],max:2); try Codec.array(c["exceptions"],max:256)
        let mode: ImportCalendarMode?
        switch try optionalText(c,"mode") { case nil: mode = nil; case "weekly": mode = .weekly; case "exceptionOnly": mode = .exceptionOnly; default: mode = .unsupported }
        var baselines: [ImportBaseline] = []
        for b in c["baselines"].list {
            try Codec.fields(b,["start","end","weekdays"]); try Codec.array(b["weekdays"],max:7)
            guard b["weekdays"].list.count == 7 else { throw ConversionFailure.malformedInput }
            for flag in b["weekdays"].list { guard case .bool = flag else { throw ConversionFailure.malformedInput } }
            let w = b["weekdays"].list.map(\.flag)
            baselines.append(.init(start:try text(b["start"]),end:try text(b["end"]),weekdays:.init(monday:w[0],tuesday:w[1],wednesday:w[2],thursday:w[3],friday:w[4],saturday:w[5],sunday:w[6])))
        }
        let exceptions = try c["exceptions"].list.map { row -> ImportException in
            try Codec.fields(row,["service","date","action"])
            let action: ImportExceptionAction
            switch try text(row["action"]) { case "add": action = .add; case "remove": action = .remove; default: action = .invalid }
            return .init(service:try text(row["service"]),date:try text(row["date"]),action:action)
        }
        return .init(mode:mode,coverageStart:try text(c["coverageStart"]),coverageEnd:try text(c["coverageEnd"]),baselines:baselines,exceptions:exceptions,completenessEvidence:try optionalText(c,"completenessEvidence"))
    }
    static func zone(_ z: Wire) throws -> ImportZone? {
        if Codec.equal(z,.object([:])) { return nil }
        let kind = try text(z["kind"])
        switch kind {
        case "fixed": try Codec.fields(z,["kind","offset"]); return .fixed(offset:try integer(z["offset"]))
        case "transitions":
            try Codec.fields(z,["kind","intervals"]); try Codec.array(z["intervals"],max:8)
            return .transitions(try z["intervals"].list.map { r in
                try Codec.fields(r,["start","end","offset"])
                return .init(start:try integer(r["start"]),end:try integer(r["end"]),offset:try integer(r["offset"])) })
        default: try Codec.fields(z,["kind"]); return .unsupported
        }
    }
    static func event(_ row: Wire, _ key: String) throws -> ImportEvent? {
        guard row.has(key) else { return nil }; let e = row[key]
        switch e["state"].text {
        case "missing": try Codec.fields(e,["state"]); return .missing
        case "exact","estimated":
            try Codec.fields(e,["state","clock"],["evidence"])
            let clock = try text(e["clock"]), evidence = try optionalText(e,"evidence")
            return e["state"].text == "exact" ? .exact(clock:clock,evidence:evidence) : .estimated(clock:clock,evidence:evidence)
        case "unqualified": try Codec.fields(e,["state","clock"]); return .unqualified(clock:try text(e["clock"]))
        default: throw ConversionFailure.malformedInput
        }
    }
    static func permission(_ row: Wire, _ key: String) throws -> ImportPermission? {
        guard row.has(key) else { return nil }; let p = row[key]
        try Codec.fields(p,["value"],["evidence"])
        let value: TimetableEligibility
        switch p["value"].text { case "allowed": value = .allowed; case "prohibited": value = .prohibited; case "unknown": value = .unknown; default: throw ConversionFailure.malformedInput }
        return .init(value:value,evidence:try optionalText(p,"evidence"))
    }
}
