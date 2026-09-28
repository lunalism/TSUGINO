import Foundation

// DEC-068 §D3–D4 cases for line-binding proposals and reviewed bindings.
// Every feed, record, identifier, and digest is invented: routes are
// `syn-route-…`, Railway records `syn:Railway.…`, line codes the `Q` / `Qb`
// stand-ins, names "Synthetic …" and 合成…, and colours made up. Nothing here
// is a production identifier or a real mapping.

enum SyntheticLines {
    static let archive = String(repeating: "c", count: 64)
    static let otherArchive = String(repeating: "e", count: 64)
    static let routesMember = String(repeating: "a", count: 64)
    static let stopsMember = String(repeating: "d", count: 64)
    static let railwayInput = String(repeating: "b", count: 64)
    static let gtfsSource = "SYN-01/synthetic-gtfs"
    static let railwaySource = "SYN-03/synthetic-railway"

    static let operatorA = MintedIdentifier("opr_0000000000000001")!
    static let operatorB = MintedIdentifier("opr_0000000000000002")!
    static let lineQ = MintedIdentifier("lin_0000000000000001")!
    static let lineR = MintedIdentifier("lin_0000000000000002")!
    static let lineSpare = MintedIdentifier("lin_0000000000000003")!
    static let unheldLine = MintedIdentifier("lin_zzzzzzzzzzzzzzzz")!

    struct Route {
        let id: String
        var agency: String? = "syn-agency"
        let longName: String
        let english: String
        var color: String?
    }

    struct Record {
        let id: String
        var operatorReference = "syn:Operator.A"
        let lineCode: String
        var titles: [(String, String)]
        var color: String?
        var stations: [String] = []
    }

    /// Line Q serves a main part and a branch part (codes `Qb…`) in one
    /// route, as two trips. `syn-q3` is shared: the branch trip starts there,
    /// but it is coded under the main line. Line R is a plain line.
    static let stops: [(id: String, code: String)] = [
        ("syn-q1", "Q01"), ("syn-q2", "Q02"), ("syn-q3", "Q03"),
        ("syn-qb1", "Qb01"), ("syn-qb2", "Qb02"),
        ("syn-r1", "R01"), ("syn-r2", "R02"),
    ]
    static let routes = [
        Route(id: "syn-route-q", longName: "合成キュー線", english: "Synthetic Q Line", color: "A1B2C3"),
        Route(id: "syn-route-r", longName: "合成アール線", english: "Synthetic R Line", color: "D4E5F6"),
    ]
    static let trips: [(route: String, stops: [String])] = [
        ("syn-route-q", ["syn-q1", "syn-q2", "syn-q3"]),
        ("syn-route-q", ["syn-q3", "syn-qb1", "syn-qb2"]),
        ("syn-route-r", ["syn-r1", "syn-r2"]),
    ]
    /// The main record, the branch record, and line R's record, in that order.
    static let records = [
        Record(id: "syn:Railway.Q", lineCode: "Q", titles: [("en", "Synthetic Q Line"), ("ja", "合成キュー線")], color: "#A1B2C3",
               stations: ["syn:Station.Q1", "syn:Station.Q2", "syn:Station.Q3"]),
        Record(id: "syn:Railway.Qb", lineCode: "Qb", titles: [("en", "Synthetic Q Branch Line"), ("ja", "合成キュー線支線")], color: "#A1B2C3",
               stations: ["syn:Station.Q3", "syn:Station.Qb1", "syn:Station.Qb2"]),
        Record(id: "syn:Railway.R", lineCode: "R", titles: [("en", "Synthetic R Line"), ("ja", "合成アール線")], color: "#D4E5F6",
               stations: ["syn:Station.R1", "syn:Station.R2"]),
    ]

    static func feed(
        routes: [Route] = routes,
        agencies: [String?] = ["syn-agency"],
        stopCodes: [String: String] = [:],
        extraStops: [(id: String, code: String)] = [],
        extraTrips: [(route: String, stops: [String])] = [],
        reversed: Bool = false
    ) -> GTFSStaticFeed {
        var tripRows: [GTFSTrip] = []
        var stopTimes: [GTFSStopTime] = []
        for (index, trip) in (trips + extraTrips).enumerated() {
            let tripID = "syn-trip-\(index)"
            tripRows.append(GTFSTrip(tripID: tripID, routeID: trip.route, serviceID: "syn-weekday", headsign: nil, shortName: nil, directionID: nil, blockID: nil))
            for (position, stop) in trip.stops.enumerated() {
                stopTimes.append(GTFSStopTime(
                    tripID: tripID, stopID: stop, stopSequence: position + 1, arrivalTime: nil, departureTime: nil,
                    stopHeadsign: nil, pickupType: nil, dropOffType: nil, timepoint: nil
                ))
            }
        }
        func order<T>(_ rows: [T]) -> [T] { reversed ? rows.reversed() : rows }
        return GTFSStaticFeed(
            agencies: agencies.map { GTFSAgency(agencyID: $0, name: "Synthetic Transit", url: "https://example.invalid", timezone: "Asia/Tokyo", language: nil) },
            stops: order((stops + extraStops).map { GTFSStop(stopID: $0.id, stopCode: stopCodes[$0.id] ?? $0.code, name: "Synthetic Stop", latitude: 35.0, longitude: 139.0, locationType: nil, parentStation: nil, platformCode: nil) }),
            routes: order(routes.map { GTFSRoute(routeID: $0.id, agencyID: $0.agency, shortName: nil, longName: $0.longName, routeType: 1, color: $0.color, textColor: nil) }),
            trips: order(tripRows),
            stopTimes: order(stopTimes),
            calendars: [], calendarDates: [],
            feedInfo: [GTFSFeedInfo(publisherName: "Synthetic Publisher", publisherURL: "https://example.invalid", language: "ja", startDate: nil, endDate: nil, version: nil)],
            translations: order(routes.map { GTFSTranslation(tableName: "routes", fieldName: "route_long_name", language: "en", translation: $0.english, fieldValue: $0.longName) })
        )
    }

    static func railway(_ records: [Record] = records) -> [ODPTRailway] {
        records.map { record in
            ODPTRailway(
                id: record.id, sameAs: record.id, operatorReference: record.operatorReference, lineCode: record.lineCode,
                title: ODPTLanguageMap(entries: record.titles.map { .init(language: $0.0, text: $0.1) }),
                color: record.color, ascendingRailDirection: nil, descendingRailDirection: nil,
                stationOrder: record.stations.enumerated().map { ODPTStationOrderEntry(index: $0.offset + 1, station: $0.element, title: nil) }
            )
        }
    }

    /// Operators A and B, each with an operator reference, and three
    /// `LineID`s. Invented, and never written anywhere.
    static let registry: MappingRegistry = {
        func reference(_ id: MintedIdentifier, _ source: String, _ namespace: ProviderNamespace, _ value: String) -> ProviderReference {
            let key = ExactValue(value)!
            let provenance = namespace.isGTFS
                ? try! SourceReference(inputSHA256: archive, member: .init(name: "agency.txt", sha256: routesMember), table: "agency", recordIndex: nil, field: "agency_id", providerKey: key)
                : try! SourceReference(inputSHA256: railwayInput, member: nil, table: nil, recordIndex: 0, field: "odpt:operator", providerKey: key)
            return try! ProviderReference(
                canonicalID: id, sourceID: source, namespace: namespace, value: key, status: .active,
                firstSeenInputSHA256: provenance.inputSHA256, provenance: provenance, originalNames: []
            )
        }
        return try! MappingRegistry(
            revision: 1,
            entities: [operatorA, operatorB, lineQ, lineR, lineSpare].map { CanonicalEntity(id: $0, status: .active) },
            references: [
                reference(operatorA, gtfsSource, .gtfsAgencyID, "syn-agency"),
                reference(operatorA, railwaySource, .odptOperator, "syn:Operator.A"),
                reference(operatorB, railwaySource, .odptOperator, "syn:Operator.B"),
            ]
        )
    }()

    static func input(
        _ feed: GTFSStaticFeed = feed(),
        _ railway: [ODPTRailway]? = railway(),
        archive: String = archive
    ) throws -> LineBindingInput {
        try LineBindingInput(
            gtfs: .init(sourceID: gtfsSource, archiveSHA256: archive, routesMemberSHA256: routesMember, stopsMemberSHA256: stopsMember, feed: feed),
            railway: railway.map { .init(sourceID: railwaySource, inputSHA256: railwayInput, records: $0) },
            registry: registry
        )
    }

    static func proposal(_ report: LineBindingReport, _ routeID: String) -> LineBindingProposal {
        report.proposals.first { $0.members[0].reference.providerKey.text == routeID }!
    }

    /// A reviewed binding of exactly a proposal's members, accepting every
    /// disagreement it reports unless `acceptances` is given.
    static func binding(
        _ reviewID: String,
        _ line: MintedIdentifier,
        _ proposal: LineBindingProposal,
        acceptances: [LineBindingAcceptance]? = nil
    ) throws -> ReviewedLineBinding {
        let failed = Dictionary(grouping: proposal.findings, by: \.member).mapValues { $0.map(\.check) }
        return try ReviewedLineBinding(
            reviewID: reviewID, lineID: line, members: proposal.members, evidenceSHA256: proposal.evidenceSHA256,
            acceptances: try acceptances ?? failed.map { try LineBindingAcceptance(member: $0.key, reason: "Synthetic review", acceptedChecks: $0.value) }
        )
    }

    static func findings(_ proposal: LineBindingProposal) -> [String] {
        proposal.findings.map { "\($0.member.reference.providerKey.text) \($0.check.rawValue) \($0.kind.rawValue)" }
    }
}

func bindExpecting(_ bindings: [ReviewedLineBinding], _ input: LineBindingInput) throws -> Result<LineBindingOutcome, LineBindingApplicationError> {
    do {
        return .success(try LineBinding.apply(try ReviewedLineBindingSet(bindings), to: input))
    } catch let error as LineBindingApplicationError {
        return .failure(error)
    }
}

let lineBindingTests: [TestCase] = [
    ("one route and a main and a branch Railway record bind to one LineID, each keeping its own provenance", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let q = SyntheticLines.proposal(report, "syn-route-q")
        try check(q.members.map(\.reference.providerKey.text) == ["syn-route-q", "syn:Railway.Q", "syn:Railway.Qb"], "Q proposal members")
        try check(SyntheticLines.findings(q) == ["syn:Railway.Qb japaneseTitle differs", "syn:Railway.Qb englishTitle differs"], "\(SyntheticLines.findings(q))")
        try check(report.unmatchedRecords.isEmpty, "unmatched records")

        let bindings = [
            try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q),
            try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r")),
        ]
        guard case .success(let outcome) = try bindExpecting(bindings, input) else { throw TestFailure(message: "apply failed") }
        try check(outcome.lines.map(\.lineID) == [SyntheticLines.lineQ, SyntheticLines.lineR], "exactly the two reviewed LineIDs")
        let line = outcome.lines[0]
        try check(line.operatorID == SyntheticLines.operatorA && line.reviewID == "SYN-REVIEW-L1", "operator and review")
        try check(line.routes.count == 1 && line.railwayRecords.count == 2, "both Railway records on the one LineID")

        let main = line.railwayRecords[0], branch = line.railwayRecords[1]
        try check(branch.member.sourceID == SyntheticLines.railwaySource
            && branch.member.reference.recordIndex == 1 && branch.member.reference.field == "@id"
            && branch.member.reference.providerKey.text == "syn:Railway.Qb"
            && branch.member.reference.inputSHA256 == SyntheticLines.railwayInput, "branch provenance")
        try check(main.member.reference.recordIndex == 0 && main.member.reference.providerKey.text == "syn:Railway.Q", "main provenance")
        try check(line.routes[0].staticScope == .served(report.routes[0].stops)
            && report.routes[0].stops.map(\.providerKey.text) == ["syn-q1", "syn-q2", "syn-q3", "syn-qb1", "syn-qb2"], "route scope")
        try check(branch.acceptedChecks == [.japaneseTitle, .englishTitle] && main.acceptedChecks.isEmpty, "accepted checks")
    }),
    ("a branch keeps its whole station order, including a stop shared with the main line, and its GTFS scope is deferred", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let bindings = [
            try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q")),
            try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r")),
        ]
        guard case .success(let outcome) = try bindExpecting(bindings, input) else { throw TestFailure(message: "apply failed") }
        let branch = outcome.lines[0].railwayRecords[1]
        try check(branch.stationOrder.map(\.station.providerKey.text) == ["syn:Station.Q3", "syn:Station.Qb1", "syn:Station.Qb2"], "the shared station is kept, in order")
        try check(branch.stationOrder.enumerated().allSatisfy { position, entry in
            entry.index == position + 1 && entry.station.recordIndex == 1 && entry.station.member == nil
                && entry.station.inputSHA256 == SyntheticLines.railwayInput
                && entry.station.field == "odpt:stationOrder[\(position)].odpt:station"
        }, "station-order provenance")
        try check(branch.staticScope == .deferred && outcome.lines[0].railwayRecords[0].staticScope == .deferred, "no GTFS scope is presented")

        // The prefix group is evidence only: it misses the shared stop, which
        // is coded under the main line although the branch trip serves it.
        let qbGroup = report.routes[0].codeGroups.first { $0.prefix == "Qb" }
        try check(qbGroup?.stops.map(\.providerKey.text) == ["syn-qb1", "syn-qb2"], "prefix group")
        try check(report.routes[0].codeGroups.first { $0.prefix == "Q" }?.stops.map(\.providerKey.text).contains("syn-q3") == true, "shared stop coded Q")

        // Dropping the shared station, reordering, or renumbering an
        // `odpt:index` each changes the evidence.
        var dropped = SyntheticLines.records
        dropped[1].stations = ["syn:Station.Qb1", "syn:Station.Qb2"]
        var reordered = SyntheticLines.records
        reordered[1].stations = ["syn:Station.Qb1", "syn:Station.Q3", "syn:Station.Qb2"]
        var renumbered = SyntheticLines.railway()
        let old = renumbered[1]
        renumbered[1] = ODPTRailway(
            id: old.id, sameAs: old.sameAs, operatorReference: old.operatorReference, lineCode: old.lineCode, title: old.title,
            color: old.color, ascendingRailDirection: nil, descendingRailDirection: nil,
            stationOrder: old.stationOrder.map { ODPTStationOrderEntry(index: $0.index + 10, station: $0.station, title: nil) }
        )
        for railway in [SyntheticLines.railway(dropped), SyntheticLines.railway(reordered), renumbered] {
            let changed = try SyntheticLines.input(SyntheticLines.feed(), railway)
            try check(try bindExpecting(bindings, changed) == .failure(.evidenceChanged(reviewID: "SYN-REVIEW-L1")), "station order is evidence")
        }
    }),
    ("one LineID may bind several static routes, with no second LineID, and still only once each", { _ in
        var routes = SyntheticLines.routes
        routes.append(SyntheticLines.Route(id: "syn-route-q2", longName: "合成キュー線", english: "Synthetic Q Line", color: "A1B2C3"))
        let feed = SyntheticLines.feed(routes: routes, extraStops: [("syn-q4", "Q04")], extraTrips: [("syn-route-q2", ["syn-q3", "syn-q4"])])
        let input = try SyntheticLines.input(feed)
        let report = LineBinding.propose(input)
        // Proposed route by route, the main record is ambiguous between them.
        let q = SyntheticLines.proposal(report, "syn-route-q"), q2 = SyntheticLines.proposal(report, "syn-route-q2")
        try check(q.findings.contains { $0.check == .uniqueCounterpart && $0.routes.map(\.text) == ["syn-route-q2"] }, "ambiguous in Q")
        try check(q2.findings.contains { $0.check == .uniqueCounterpart }, "ambiguous in Q2")

        let members = [q.members[0], q2.members[0]] + q.members.dropFirst()
        let both = LineBinding.evidence(for: members, in: input)!
        try check(both.members.map(\.reference.providerKey.text) == ["syn-route-q", "syn-route-q2", "syn:Railway.Q", "syn:Railway.Qb"], "members")
        // Each record is compared with both routes: the branch code is not a
        // prefix on the second route, and that is reported, not hidden by
        // agreement with the first.
        try check(SyntheticLines.findings(both) == [
            "syn:Railway.Qb lineCode differs", "syn:Railway.Qb japaneseTitle differs", "syn:Railway.Qb englishTitle differs",
        ], "\(SyntheticLines.findings(both))")
        try check(both.findings[0].routes.map(\.text) == ["syn-route-q2"] && both.findings[1].routes.map(\.text) == ["syn-route-q", "syn-route-q2"], "disagreeing routes")
        let qBinding = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, both)
        let rBinding = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r"))
        guard case .success(let outcome) = try bindExpecting([qBinding, rBinding], input) else { throw TestFailure(message: "apply failed") }
        try check(outcome.lines.map(\.lineID) == [SyntheticLines.lineQ, SyntheticLines.lineR], "no second LineID")
        try check(outcome.lines[0].routes.map(\.member.reference.providerKey.text) == ["syn-route-q", "syn-route-q2"], "two routes, one LineID")

        let rWithQ2 = try ReviewedLineBinding(
            reviewID: "SYN-REVIEW-L2", lineID: SyntheticLines.lineR,
            members: SyntheticLines.proposal(report, "syn-route-r").members + [q2.members[0]], evidenceSHA256: both.evidenceSHA256
        )
        do {
            _ = try ReviewedLineBindingSet([qBinding, rWithQ2])
            throw TestFailure(message: "a route bound to two LineIDs was accepted")
        } catch let error as ReviewedLineBindingSet.Invalid {
            try check(error == .conflictingBinding, "\(error)")
        }
        // Leaving the second route out leaves it unbound.
        let qOnly = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q)
        try check(try bindExpecting([qOnly, rBinding], input) == .failure(.unbound(routes: 1, railwayRecords: 0)), "second route unbound")
    }),
    ("the branch record cannot be bound to a second LineID by the checks alone", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let q = SyntheticLines.proposal(report, "syn-route-q")
        let r = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r"))
        let mainMembers = Array(q.members.prefix(2)), branch = q.members[2]

        // On its own, the branch record has no route to agree with, and its
        // route is bound elsewhere: every check needs an explicit acceptance.
        let alone = LineBinding.evidence(for: [branch], in: input)!
        try check(SyntheticLines.findings(alone) == [
            "syn:Railway.Qb lineCode missing", "syn:Railway.Qb japaneseTitle missing", "syn:Railway.Qb englishTitle missing",
            "syn:Railway.Qb color missing", "syn:Railway.Qb uniqueCounterpart differs",
        ], "\(SyntheticLines.findings(alone))")
        let mainEvidence = LineBinding.evidence(for: mainMembers, in: input)!
        let main = try ReviewedLineBinding(reviewID: "SYN-REVIEW-L1", lineID: SyntheticLines.lineQ, members: mainMembers, evidenceSHA256: mainEvidence.evidenceSHA256)
        let second = try ReviewedLineBinding(reviewID: "SYN-REVIEW-L3", lineID: SyntheticLines.lineSpare, members: [branch], evidenceSHA256: alone.evidenceSHA256)
        try check(try bindExpecting([main, r, second], input) == .failure(.acceptanceMismatch(reviewID: "SYN-REVIEW-L3")), "second LineID from the checks")

        // Left out of the one binding, it is unbound; with another set's
        // digest, the record does not match its evidence.
        try check(try bindExpecting([main, r], input) == .failure(.unbound(routes: 0, railwayRecords: 1)), "branch left unbound")
        let stale = try ReviewedLineBinding(reviewID: "SYN-REVIEW-L1", lineID: SyntheticLines.lineQ, members: mainMembers, evidenceSHA256: q.evidenceSHA256)
        try check(try bindExpecting([stale, r], input) == .failure(.evidenceChanged(reviewID: "SYN-REVIEW-L1")), "digest of other members")
        // Bound under two LineIDs, it conflicts.
        do {
            _ = try ReviewedLineBindingSet([try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q), second])
            throw TestFailure(message: "a second LineID was accepted")
        } catch let error as ReviewedLineBindingSet.Invalid {
            try check(error == .conflictingBinding, "\(error)")
        }
    }),
    ("nothing binds without reviewed records, and every unbound route or record fails the run", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        try check(try bindExpecting([], input) == .failure(.unbound(routes: 2, railwayRecords: 3)), "no records")
        let q = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q"))
        try check(try bindExpecting([q], input) == .failure(.unbound(routes: 1, railwayRecords: 1)), "missing review of R")
    }),
    ("a disagreement never binds by itself: acceptances must name exactly the disagreeing checks", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let q = SyntheticLines.proposal(report, "syn-route-q")
        let r = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r"))
        let main = q.members[1], branch = q.members[2]
        let variants: [[LineBindingAcceptance]] = [
            [],
            [try LineBindingAcceptance(member: branch, reason: "Synthetic review", acceptedChecks: [.japaneseTitle])],
            [try LineBindingAcceptance(member: branch, reason: "Synthetic review", acceptedChecks: [.japaneseTitle, .englishTitle, .color])],
            [try LineBindingAcceptance(member: branch, reason: "Synthetic review", acceptedChecks: [.japaneseTitle, .englishTitle]),
             try LineBindingAcceptance(member: main, reason: "Synthetic review", acceptedChecks: [.color])],
        ]
        for acceptances in variants {
            let binding = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q, acceptances: acceptances)
            let result = try bindExpecting([binding, r], input)
            try check(result == .failure(.acceptanceMismatch(reviewID: "SYN-REVIEW-L1")), "\(acceptances.count) acceptances: \(result)")
        }
    }),
    ("colour, code, and title disagreements are reported, and absent or reading-only values are missing", { _ in
        var records = SyntheticLines.records
        records[0].color = "#000000"
        records[1].color = nil
        records[1].titles = [("ja-Hrkt", "ごうせいきゅーせんしせん"), ("en", "Synthetic Q Branch Line")]
        let report = LineBinding.propose(try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records)))
        let q = SyntheticLines.proposal(report, "syn-route-q")
        try check(SyntheticLines.findings(q) == [
            "syn:Railway.Q color differs",
            "syn:Railway.Qb japaneseTitle missing", "syn:Railway.Qb englishTitle differs", "syn:Railway.Qb color missing",
        ], "\(SyntheticLines.findings(q))")

        // A branch code the route does not serve is a code disagreement.
        // With no title agreeing either, the record is no candidate at all.
        let recodedInput = try SyntheticLines.input(SyntheticLines.feed(stopCodes: ["syn-qb1": "Q04", "syn-qb2": "Q05"]))
        let recoded = LineBinding.propose(recodedInput)
        try check(recoded.unmatchedRecords.map(\.reference.providerKey.text) == ["syn:Railway.Qb"], "unmatched once recoded")
        let members = SyntheticLines.proposal(recoded, "syn-route-q").members + recoded.unmatchedRecords
        let explicit = LineBinding.evidence(for: members, in: recodedInput)!
        try check(SyntheticLines.findings(explicit) == [
            "syn:Railway.Qb lineCode differs", "syn:Railway.Qb japaneseTitle differs", "syn:Railway.Qb englishTitle differs",
        ], "\(SyntheticLines.findings(explicit))")
    }),
    ("a record that is a candidate for two routes is reported as ambiguous in both", { _ in
        var records = SyntheticLines.records
        // Line code R, but line Q's titles.
        records[2].titles = [("en", "Synthetic Q Line"), ("ja", "合成キュー線")]
        let input = try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records))
        let report = LineBinding.propose(input)
        let q = SyntheticLines.proposal(report, "syn-route-q"), r = SyntheticLines.proposal(report, "syn-route-r")
        try check(q.members.map(\.reference.providerKey.text).contains("syn:Railway.R") && r.members.count == 2, "in both proposals")
        let ambiguous = q.findings.first { $0.check == .uniqueCounterpart }
        try check(ambiguous?.routes.map(\.text) == ["syn-route-r"], "Q proposal names the other route")
        try check(r.findings.map(\.check) == [.japaneseTitle, .englishTitle, .uniqueCounterpart], "\(r.findings.map(\.check))")

        // The reviewer binds the record to route R. Its ambiguity must be
        // accepted with its other disagreements, and route Q is bound
        // without it, on that member set's own evidence.
        let qMembers = q.members.filter { $0.reference.providerKey.text != "syn:Railway.R" }
        let qEvidence = LineBinding.evidence(for: qMembers, in: input)!
        let qBinding = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, qEvidence)
        let rBinding = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, r)
        guard case .success(let outcome) = try bindExpecting([qBinding, rBinding], input) else { throw TestFailure(message: "apply failed") }
        try check(outcome.lines[1].railwayRecords[0].acceptedChecks == [.japaneseTitle, .englishTitle, .uniqueCounterpart], "ambiguity accepted")

        let unaccepted = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, r, acceptances: [
            try LineBindingAcceptance(member: r.members[1], reason: "Synthetic review", acceptedChecks: [.japaneseTitle, .englishTitle]),
        ])
        try check(try bindExpecting([qBinding, unaccepted], input) == .failure(.acceptanceMismatch(reviewID: "SYN-REVIEW-L2")), "ambiguity not accepted")
    }),
    ("a record no route is a candidate for is listed as unmatched and fails the run unless bound", { _ in
        var records = SyntheticLines.records
        records.append(SyntheticLines.Record(id: "syn:Railway.Qx", lineCode: "Qx", titles: [("en", "Synthetic Qx Line"), ("ja", "合成キューエックス線")], color: "#123456"))
        let input = try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records))
        let report = LineBinding.propose(input)
        try check(report.unmatchedRecords.map(\.reference.providerKey.text) == ["syn:Railway.Qx"], "unmatched")
        let bindings = [
            try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q")),
            try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r")),
        ]
        try check(try bindExpecting(bindings, input) == .failure(.unbound(routes: 0, railwayRecords: 1)), "unmatched record left unbound")
    }),
    ("a binding never crosses operators, and an operator reference the registry does not hold fails", { _ in
        var records = SyntheticLines.records
        records[1].operatorReference = "syn:Operator.B"
        var input = try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records))
        var report = LineBinding.propose(input)
        try check(report.railwayRecords[1].operatorID == SyntheticLines.operatorB, "record operator resolved")
        let r = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r"))
        let crossing = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q"))
        try check(try bindExpecting([crossing, r], input) == .failure(.crossesOperatorBoundary(reviewID: "SYN-REVIEW-L1")), "cross-operator")

        records[1].operatorReference = "syn:Operator.Unknown"
        input = try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records))
        report = LineBinding.propose(input)
        let unbound = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q"))
        try check(try bindExpecting([unbound, r], input) == .failure(.operatorUnbound(reviewID: "SYN-REVIEW-L1")), "no registry reference for the record's operator")
    }),
    ("a route's agency resolves within its feed, and binding its operator needs an active registry reference", { _ in
        func outcome(_ routes: [SyntheticLines.Route], agencies: [String?]) throws -> (LineBindingReport, Result<LineBindingOutcome, LineBindingApplicationError>) {
            let input = try SyntheticLines.input(SyntheticLines.feed(routes: routes, agencies: agencies), nil)
            let report = LineBinding.propose(input)
            let bindings = [
                try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q")),
                try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r")),
            ]
            return (report, try bindExpecting(bindings, input))
        }
        let unnamed = SyntheticLines.routes.map { route -> SyntheticLines.Route in var route = route; route.agency = nil; return route }

        // Valid single-agency feed: routes name no agency, and the only
        // agency has an active operator reference.
        let (single, bound) = try outcome(unnamed, agencies: ["syn-agency"])
        try check(single.routes.allSatisfy { $0.agency == .agency(ExactValue("syn-agency")!) && $0.operatorID == SyntheticLines.operatorA }, "sole agency")
        try check(bound.map { $0.lines.map(\.operatorID) } == .success([SyntheticLines.operatorA, SyntheticLines.operatorA]), "\(bound)")

        // The only agency has no `agency_id`: the feed resolves it, but there
        // is no value to bind an operator by, so nothing is inferred.
        let (withoutID, noKey) = try outcome(unnamed, agencies: [nil])
        try check(withoutID.routes.allSatisfy { $0.agency == .soleAgencyWithoutID && $0.operatorID == nil }, "sole agency without id")
        try check(noKey == .failure(.operatorUnbound(reviewID: "SYN-REVIEW-L1")), "\(noKey)")

        // A defined agency with no operator reference in the registry.
        let other = SyntheticLines.routes.map { route -> SyntheticLines.Route in var route = route; route.agency = "syn-agency-2"; return route }
        let (missing, missingResult) = try outcome(other, agencies: ["syn-agency-2"])
        try check(missing.routes[0].agency == .agency(ExactValue("syn-agency-2")!) && missing.routes[0].operatorID == nil, "resolved agency, no operator")
        try check(missingResult == .failure(.operatorUnbound(reviewID: "SYN-REVIEW-L1")), "\(missingResult)")

        // An agency the feed does not define, and no agency in a feed with two.
        let undefined = SyntheticLines.routes.map { route -> SyntheticLines.Route in var route = route; route.agency = "syn-agency-x"; return route }
        let (_, undefinedResult) = try outcome(undefined, agencies: ["syn-agency"])
        try check(undefinedResult == .failure(.agencyUnresolved(reviewID: "SYN-REVIEW-L1")), "\(undefinedResult)")
        let (two, twoResult) = try outcome(unnamed, agencies: ["syn-agency", "syn-agency-2"])
        try check(two.routes[0].agency == .unresolved && twoResult == .failure(.agencyUnresolved(reviewID: "SYN-REVIEW-L1")), "\(twoResult)")
    }),
    ("a record whose evidence changed after review no longer applies", { _ in
        let reviewed = LineBinding.propose(try SyntheticLines.input())
        let bindings = [
            try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(reviewed, "syn-route-q")),
            try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(reviewed, "syn-route-r")),
        ]
        var routes = SyntheticLines.routes
        routes[0].color = "A1B2C4"
        var records = SyntheticLines.records
        records[1].titles[0] = ("en", "Synthetic Q Branch")
        let changes: [LineBindingInput] = [
            try SyntheticLines.input(SyntheticLines.feed(routes: routes)),
            try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records)),
            try SyntheticLines.input(SyntheticLines.feed(stopCodes: ["syn-qb2": "Q09"])),
        ]
        for (index, changed) in changes.enumerated() {
            try check(try bindExpecting(bindings, changed) == .failure(.evidenceChanged(reviewID: "SYN-REVIEW-L1")), "change \(index)")
        }
        try check(try bindExpecting(bindings, try SyntheticLines.input()).map(\.lines.count) == .success(2), "unchanged input still binds")
    }),
    ("records naming another input, an unknown route or record, or an unheld LineID are refused", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let q = SyntheticLines.proposal(report, "syn-route-q")
        let r = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r"))

        let other = LineBinding.propose(try SyntheticLines.input(archive: SyntheticLines.otherArchive))
        let foreign = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(other, "syn-route-q"))
        try check(try bindExpecting([foreign, r], input) == .failure(.recordForOtherInput(reviewID: "SYN-REVIEW-L1")), "other archive")

        let unknownRoute = try LineBindingMember(sourceID: SyntheticLines.gtfsSource, reference: SourceReference(
            inputSHA256: SyntheticLines.archive, member: .init(name: "routes.txt", sha256: SyntheticLines.routesMember),
            table: "routes", recordIndex: nil, field: "route_id", providerKey: ExactValue("syn-route-x")!))
        let wrongIndex = try LineBindingMember(sourceID: SyntheticLines.railwaySource, reference: SourceReference(
            inputSHA256: SyntheticLines.railwayInput, member: nil, table: nil, recordIndex: 0, field: "@id", providerKey: ExactValue("syn:Railway.Qb")!))
        let pastEnd = try LineBindingMember(sourceID: SyntheticLines.railwaySource, reference: SourceReference(
            inputSHA256: SyntheticLines.railwayInput, member: nil, table: nil, recordIndex: 7, field: "@id", providerKey: ExactValue("syn:Railway.Q")!))
        for members in [[unknownRoute] + q.members.dropFirst(), [q.members[0], wrongIndex], [q.members[0], pastEnd]] {
            let binding = try ReviewedLineBinding(reviewID: "SYN-REVIEW-L1", lineID: SyntheticLines.lineQ, members: members, evidenceSHA256: q.evidenceSHA256)
            try check(try bindExpecting([binding, r], input) == .failure(.unknownMember(reviewID: "SYN-REVIEW-L1")), "unknown member")
        }

        let unheld = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.unheldLine, q)
        try check(try bindExpecting([unheld, r], input) == .failure(.unknownLine(reviewID: "SYN-REVIEW-L1")), "LineID not in the registry")

        let noRailway = try SyntheticLines.input(SyntheticLines.feed(), nil)
        try check(try bindExpecting([try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q), r], noRailway)
            == .failure(.recordForOtherInput(reviewID: "SYN-REVIEW-L1")), "Railway members with no Railway input")
    }),
    ("a provider record bound twice, to one LineID or two, is refused", { _ in
        let report = LineBinding.propose(try SyntheticLines.input())
        let q = SyntheticLines.proposal(report, "syn-route-q"), r = SyntheticLines.proposal(report, "syn-route-r")
        let branch = q.members[2]
        let rWithBranch = try ReviewedLineBinding(reviewID: "SYN-REVIEW-L2", lineID: SyntheticLines.lineR, members: r.members + [branch], evidenceSHA256: r.evidenceSHA256)
        let cases: [([ReviewedLineBinding], ReviewedLineBindingSet.Invalid)] = [
            ([try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q), rWithBranch], .conflictingBinding),
            ([try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q), try SyntheticLines.binding("SYN-REVIEW-L3", SyntheticLines.lineQ, q)], .duplicateBinding),
            ([try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q), try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineR, r)], .repeatedReviewID),
        ]
        for (records, expected) in cases {
            do {
                _ = try ReviewedLineBindingSet(records)
                throw TestFailure(message: "accepted: expected \(expected)")
            } catch let error as ReviewedLineBindingSet.Invalid {
                try check(error == expected, "\(error) != \(expected)")
            }
        }
    }),
    ("output is deterministic: row order and record order do not change it", { _ in
        let input = try SyntheticLines.input()
        let reversed = try SyntheticLines.input(SyntheticLines.feed(reversed: true))
        let report = LineBinding.propose(input)
        try check(LineBinding.propose(reversed) == report && LineBinding.propose(input) == report, "report")
        let bindings = [
            try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q")),
            try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r")),
        ]
        let first = try bindExpecting(bindings, input), second = try bindExpecting(bindings.reversed(), reversed)
        try check(first == second, "outcome")
        guard case .success(let outcome) = first else { throw TestFailure(message: "apply failed") }
        try check(outcome.lines.map(\.reviewID) == ["SYN-REVIEW-L1", "SYN-REVIEW-L2"], "sorted by LineID")
    }),
    ("every reference is exact: routes, Railway records, and stops name their input, member, position, field, and key", { _ in
        let report = LineBinding.propose(try SyntheticLines.input())
        let route = report.routes[0]
        let reference = route.member.reference
        try check(route.member.sourceID == SyntheticLines.gtfsSource && reference.inputSHA256 == SyntheticLines.archive
            && reference.member == .init(name: "routes.txt", sha256: SyntheticLines.routesMember)
            && reference.table == "routes" && reference.field == "route_id" && reference.recordIndex == nil
            && reference.providerKey.text == "syn-route-q", "route reference")
        try check(route.agency == .agency(ExactValue("syn-agency")!) && route.japaneseTitles.map(\.text) == ["合成キュー線"] && route.englishTitles.map(\.text) == ["Synthetic Q Line"], "route titles")
        try check(route.codeGroups.map(\.prefix) == ["Q", "Qb"], "code groups")
        let stop = route.codeGroups[1].stops[0]
        try check(stop.member == .init(name: "stops.txt", sha256: SyntheticLines.stopsMember) && stop.table == "stops"
            && stop.field == "stop_id" && stop.providerKey.text == "syn-qb1", "stop reference")
        for (index, record) in report.railwayRecords.enumerated() {
            let ref = record.member.reference
            try check(record.member.sourceID == SyntheticLines.railwaySource && ref.inputSHA256 == SyntheticLines.railwayInput
                && ref.member == nil && ref.table == nil && ref.recordIndex == index && ref.field == "@id"
                && ref.providerKey.text == SyntheticLines.records[index].id, "record \(index) reference")
        }
    }),
    ("a GTFS input without Railway records binds each route alone", { _ in
        let input = try SyntheticLines.input(SyntheticLines.feed(), nil)
        let report = LineBinding.propose(input)
        try check(report.proposals.allSatisfy { $0.members.count == 1 && $0.findings.isEmpty }, "route-only proposals")
        let bindings = [
            try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, SyntheticLines.proposal(report, "syn-route-q")),
            try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r")),
        ]
        try check(try bindExpecting(bindings, input).map(\.lines.count) == .success(2), "bound")
    }),
    ("in launch inputs, a branch record cannot be split from its main line's LineID even with every check accepted", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let q = SyntheticLines.proposal(report, "syn-route-q")
        let mainMembers = Array(q.members.prefix(2)), branch = q.members[2]
        let main = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, LineBinding.evidence(for: mainMembers, in: input)!)
        let split = try SyntheticLines.binding("SYN-REVIEW-L3", SyntheticLines.lineSpare, LineBinding.evidence(for: [branch], in: input)!)
        let r = try SyntheticLines.binding("SYN-REVIEW-L2", SyntheticLines.lineR, SyntheticLines.proposal(report, "syn-route-r"))
        let launch = LaunchInputs(identities: [
            .init(sourceID: SyntheticLines.gtfsSource, inputSHA256: SyntheticLines.archive),
            .init(sourceID: SyntheticLines.railwaySource, inputSHA256: SyntheticLines.railwayInput),
        ])
        func apply(_ bindings: [ReviewedLineBinding], _ launchInputs: LaunchInputs) throws -> Result<LineBindingOutcome, LineBindingApplicationError> {
            do { return .success(try LineBinding.apply(try ReviewedLineBindingSet(bindings), to: input, launchInputs: launchInputs)) }
            catch let error as LineBindingApplicationError { return .failure(error) }
        }
        let attempted = try apply([main, split, r], launch)
        try check(attempted == .failure(.launchLineSplit(reviewID: "SYN-REVIEW-L3")), "\(attempted)")

        // The one-LineID binding passes the launch rule.
        let whole = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, q)
        try check(try apply([whole, r], launch).map(\.lines.count) == .success(2), "launch binding")

        // The rule is for identified launch inputs only: elsewhere a fully
        // accepted split is the reviewer's decision, and only one identified
        // input is not enough.
        try check(try apply([main, split, r], .none).map(\.lines.count) == .success(3), "not a launch input")
        let half = LaunchInputs(identities: [.init(sourceID: SyntheticLines.gtfsSource, inputSHA256: SyntheticLines.archive)])
        try check(try apply([main, split, r], half).map(\.lines.count) == .success(3), "one identified input")

        // Records bound without their route leave the route unbound, and
        // that is what the launch run reports.
        let recordsOnly = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, LineBinding.evidence(for: Array(q.members.dropFirst()), in: input)!)
        let unboundRoute = try apply([recordsOnly, r], launch)
        try check(unboundRoute == .failure(.unbound(routes: 1, railwayRecords: 0)), "\(unboundRoute)")
    }),
    ("unrelated routes bound together report every contradiction, and nothing binds without accepting each", { _ in
        let input = try SyntheticLines.input()
        let report = LineBinding.propose(input)
        let members = report.routes.map(\.member) + report.railwayRecords.map(\.member)
        let merged = LineBinding.evidence(for: members, in: input)!
        let findings = SyntheticLines.findings(merged)
        for route in ["syn-route-q", "syn-route-r"] {
            try check(["lineCode", "japaneseTitle", "englishTitle", "color"].allSatisfy { findings.contains("\(route) \($0) differs") }, "\(route): \(findings)")
        }
        // The R record agrees with route R but not route Q: the finding
        // names route Q.
        let rTitle = merged.findings.first { $0.member.reference.providerKey.text == "syn:Railway.R" && $0.check == .japaneseTitle }
        try check(rTitle?.routes.map(\.text) == ["syn-route-q"], "\(String(describing: rTitle))")

        let unaccepted = try ReviewedLineBinding(reviewID: "SYN-REVIEW-L1", lineID: SyntheticLines.lineQ, members: members, evidenceSHA256: merged.evidenceSHA256)
        try check(try bindExpecting([unaccepted], input) == .failure(.acceptanceMismatch(reviewID: "SYN-REVIEW-L1")), "no acceptance")
        let accepted = try SyntheticLines.binding("SYN-REVIEW-L1", SyntheticLines.lineQ, merged)
        guard case .success(let outcome) = try bindExpecting([accepted], input) else { throw TestFailure(message: "fully accepted binding failed") }
        try check(outcome.lines.count == 1 && outcome.lines[0].routes.allSatisfy { $0.acceptedChecks == [.lineCode, .japaneseTitle, .englishTitle, .color] }, "route acceptances recorded")
    }),
    ("a blank station-order entry is refused rather than dropped", { _ in
        var records = SyntheticLines.records
        records[1].stations = ["syn:Station.Q3", " ", "syn:Station.Qb2"]
        do {
            _ = try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records))
            throw TestFailure(message: "blank station accepted")
        } catch let error as LineBindingInput.Invalid {
            try check(error == .blankStation, "\(error)")
        }
    }),
    ("colour is compared by key only: source values stay as written", { _ in
        var records = SyntheticLines.records
        records[0].color = "#a1b2c3"
        let report = LineBinding.propose(try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records)))
        try check(!report.proposals[0].findings.contains { $0.check == .color }, "case and # ignored in comparison")
        try check(report.railwayRecords[0].color?.text == "#a1b2c3" && report.routes[0].color?.text == "A1B2C3", "values kept byte-exact")
        records[0].color = "A1B2C3 "
        let spaced = LineBinding.propose(try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(records)))
        try check(spaced.proposals[0].findings.contains { $0.check == .color && $0.kind == .missing }, "a malformed colour has no key")
    }),
    ("an input with a repeated route or Railway identifier is refused", { _ in
        do {
            _ = try SyntheticLines.input(SyntheticLines.feed(routes: SyntheticLines.routes + [SyntheticLines.routes[0]]))
            throw TestFailure(message: "repeated route accepted")
        } catch let error as LineBindingInput.Invalid {
            try check(error == .repeatedRouteID, "\(error)")
        }
        do {
            _ = try SyntheticLines.input(SyntheticLines.feed(), SyntheticLines.railway(SyntheticLines.records + [SyntheticLines.records[0]]))
            throw TestFailure(message: "repeated record accepted")
        } catch let error as LineBindingInput.Invalid {
            try check(error == .repeatedRailwayID, "\(error)")
        }
    }),
]
