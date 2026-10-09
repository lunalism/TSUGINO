import Foundation

enum ImportFixtures {
    static let profile = "invented.calendar-profile.1", reviewID = "invented.calendar-review.1"
    static let date = "2041-05-06", view = "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee"
    static let review = Data("INVENTED profile evidence only; no real railway source".utf8)
    static func approval() throws -> Data {
        try Codec.encode(ImportAuthority.profileApproval(review:review,owner:Fixtures.owner,profile:profile,reviewID:reviewID,
            reviewer:"invented.profile-reviewer",at:Fixtures.time,reference:"invented.profile-approval"))
    }
    static func external() throws -> ImportAuthority.External {
        let b = try ImportS9Fixture.fixture().bundle()
        return try .init(owner:Fixtures.owner,s9Files:b.files,manifestSHA:Codec.hash(b.manifest),review:review,approval:approval())
    }
    static func input(_ e: ImportAuthority.External) throws -> Wire {
        let walk = try e.crosswalk()
        let rev: Wire = .object(["source":.string("invented.source.1"),"profile":.string(profile),"zone":.string("invented.zone.1"),"mapping":.string("invented.mapping.1"),"review":.string("invented.review.1")])
        let names = ["profileApplicable","singleExecution","calendarComplete","exact","allowed","estimated","prohibited"]
        var dependencies: [Wire] = []
        let evidence: [Wire] = names.map { name in
            let bytes = Data(("INVENTED normalized evidence " + name).utf8)
            let pin: Wire = .object(["id":.string("invented.dependency." + name),"sha256":.string(Codec.hash(bytes))])
            dependencies.append(pin.replacing("bytes",Codec.blob(bytes)).replacing("dependencyDigests",.array([])))
            return .object(["id":.string("invented." + name),"revisions":rev,"run":walk["source"]["key"],"service":.string("invented.service"),
                "assertion":.string(name),"scope":.object(["kind":.string("wholeRun")]),"pin":pin])
        }
        dependencies.sort { $0["id"].text < $1["id"].text }
        let calendar: Wire = .object(["mode":.string("weekly"),"coverageStart":.string("2041-05-01"),"coverageEnd":.string("2041-06-30"),
            "baselines":.array([.object(["start":.string("2041-05-01"),"end":.string("2041-06-15"),"weekdays":.array(Array(repeating:.bool(true),count:7))])]),
            "exceptions":.array((10...26).map { .object(["service":.string("invented.service"),"date":.string("2041-05-\($0)"),"action":.string("remove")]) }),"completenessEvidence":.string("invented.calendarComplete")])
        let visits: [Wire] = (0..<14).map { n in
            let clock = String(format:"11:%02d:07",n * 2)
            let event: Wire = .object(["state":.string("exact"),"clock":.string(clock),"evidence":.string("invented.exact")])
            let permission: Wire = .object(["value":.string("allowed"),"evidence":.string("invented.allowed")])
            return .object(["originalIndex":.integer(n),"occurrence":walk["occurrences"].list[n]["locator"],"mappingRevision":rev["mapping"],
                "arrival":event,"departure":event,"boarding":permission,"alighting":permission])
        }
        return ImportAuthority.tagged("import-input",["ownerAuthority":.string(e.owner),"inputID":.string("invented.timetable-input"),"s9":e.s9Pins,"profile":e.profilePins,
            "source":.object(["archiveSHA256":.string(Codec.hash(Data("INVENTED ARCHIVE PIN ONLY".utf8))),"revision":rev["source"],"s9Source":walk["source"]]),
            "revisions":rev,"viewID":.string(view),"tripID":walk["tripID"],"serviceDate":.string(date),"run":walk["source"]["key"],"service":.string("invented.service"),
            "profileEvidence":.string("invented.profileApplicable"),"executionEvidence":.string("invented.singleExecution"),"evidence":.array(evidence),"calendar":calendar,
            "zone":.object(["kind":.string("fixed"),"offset":.integer(7200)]),"visits":.array(visits),"dependencies":.array(dependencies)])
    }
    static func state(_ i: Wire) -> Wire { ImportAuthority.tagged("import-state",["ownerAuthority":i["ownerAuthority"],"address":ImportAuthority.address(i),"historyComplete":.bool(true),"imports":.array([])]) }
    static func request(_ i: Wire, _ e: ImportAuthority.External) throws -> Wire {
        let p = try ImportAuthority.prepare(i,state:state(i),requestID:"invented.import-request",approvalReviewID:"invented.import-review",outputID:"invented.import-output",external:e)
        guard case .request(let q) = p else { if case .outcome(let o) = p { print(ImportAuthority.status(o)) }; throw TestFailure.assertion }; return q
    }
    static func approved(_ q: Wire, _ e: ImportAuthority.External) throws -> Wire {
        try ImportAuthority.approve(q,external:e,reviewer:"invented.import-reviewer",at:Fixtures.time,reference:"invented.import-approval")
    }
}
