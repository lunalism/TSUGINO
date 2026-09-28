import Foundation

// DEC-068 §D2 cases for grouping proposals and reviewed records. Every feed,
// record, and digest is invented. Stops are `syn-…`, codes `Q01`-style
// stand-ins, names "Synthetic …", and nothing here is a production
// identifier or a real mapping.

enum SyntheticGrouping {
    static let archiveA = String(repeating: "c", count: 64)
    static let archiveB = String(repeating: "e", count: 64)
    static let stopsMember = String(repeating: "d", count: 64)
    static let source = "SYN-01/synthetic-gtfs"

    struct Stop {
        let id: String
        let code: String?
        let name: String
        var latitude = 35.0
    }

    /// Two invented lines, Q and R, each with three stops; "Synthetic Hub"
    /// appears once on each line, as two flat rows.
    static let stops: [Stop] = [
        Stop(id: "syn-q1", code: "Q01", name: "Synthetic Alpha"),
        Stop(id: "syn-q2", code: "Q02", name: "Synthetic Hub"),
        Stop(id: "syn-q3", code: "Q03", name: "Synthetic Beta"),
        Stop(id: "syn-r1", code: "R01", name: "Synthetic Gamma"),
        Stop(id: "syn-r2", code: "R02", name: "Synthetic Hub"),
        Stop(id: "syn-r3", code: "R03", name: "Synthetic Delta"),
    ]
    static let routes: [(id: String, agency: String?)] = [("syn-route-q", "syn-agency"), ("syn-route-r", "syn-agency")]
    static let trips: [(route: String, stops: [String])] = [
        ("syn-route-q", ["syn-q1", "syn-q2", "syn-q3"]),
        ("syn-route-r", ["syn-r1", "syn-r2", "syn-r3"]),
    ]
    static let translations: [(name: String, language: String, value: String)] = [
        ("Synthetic Hub", "en", "Synthetic Hub (EN)"),
    ]

    static func feed(
        stops: [Stop] = stops,
        routes: [(id: String, agency: String?)] = routes,
        trips: [(route: String, stops: [String])] = trips,
        translations: [(name: String, language: String, value: String)] = translations,
        agencies: [String?] = ["syn-agency"],
        feedLanguage: String? = "ja",
        reversed: Bool = false
    ) -> GTFSStaticFeed {
        var stopTimes: [GTFSStopTime] = []
        var tripRows: [GTFSTrip] = []
        for (index, trip) in trips.enumerated() {
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
            stops: order(stops.map { GTFSStop(stopID: $0.id, stopCode: $0.code, name: $0.name, latitude: $0.latitude, longitude: 139.0, locationType: nil, parentStation: nil, platformCode: nil) }),
            routes: order(routes.map { GTFSRoute(routeID: $0.id, agencyID: $0.agency, shortName: nil, longName: "Synthetic Line", routeType: 1, color: nil, textColor: nil) }),
            trips: order(tripRows),
            stopTimes: order(stopTimes),
            calendars: [], calendarDates: [],
            feedInfo: feedLanguage.map { [GTFSFeedInfo(publisherName: "Synthetic Publisher", publisherURL: "https://example.invalid", language: $0, startDate: nil, endDate: nil, version: nil)] } ?? [],
            translations: order(translations.map { GTFSTranslation(tableName: "stops", fieldName: "stop_name", language: $0.language, translation: $0.value, fieldValue: $0.name) })
        )
    }

    static func input(_ feed: GTFSStaticFeed, archive: String = archiveA) throws -> GroupingInput {
        try GroupingInput(sourceID: source, archiveSHA256: archive, stopsMemberSHA256: stopsMember, feed: feed)
    }

    static func record(_ reviewID: String, _ candidate: GroupingCandidate, _ decision: GroupingDecision, archive: String = archiveA) throws -> ReviewedGroupingRecord {
        try ReviewedGroupingRecord(
            reviewID: reviewID, sourceID: source, inputSHA256: archive,
            members: candidate.members.map(\.stop), evidenceSHA256: candidate.evidenceSHA256, decision: decision
        )
    }

    static func stopIDs(_ candidate: GroupingCandidate) -> [String] { candidate.members.map(\.stopID.text) }
    static func identities(_ outcome: GroupingOutcome) -> [[String]] { outcome.identities.map { $0.members.map(\.providerKey.text) } }
    static let separate = [["syn-q1"], ["syn-q2"], ["syn-q3"], ["syn-r1"], ["syn-r2"], ["syn-r3"]]
}

func applyExpecting(_ records: [ReviewedGroupingRecord], _ report: GroupingReport, _ input: GroupingInput) -> Result<GroupingOutcome, GroupingApplicationError> {
    do {
        let outcome = try StationGrouping.apply(try ReviewedGroupingSet(records), to: input)
        precondition(outcome.report == report, "the test's report was not made from its input")
        return .success(outcome)
    } catch let error as GroupingApplicationError {
        return .failure(error)
    } catch {
        return .failure(.notACandidate(reviewID: "unexpected: \(error)"))
    }
}

let groupingTests: [TestCase] = [
    ("an input with a repeated stop row is refused before any proposal", { _ in
        let repeated = SyntheticGrouping.stops + [SyntheticGrouping.stops[0]]
        do {
            _ = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: repeated))
            throw TestFailure(message: "a repeated stop row was accepted")
        } catch let error as GroupingInput.Invalid {
            try check(error == .repeatedStopID, "\(error)")
        }
    }),
    ("equal names with full evidence are proposed, but nothing merges without a record", { _ in
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed())
        let report = StationGrouping.propose(input)
        try check(report.proposals.count == 1 && report.heldBack.isEmpty, "\(report.proposals.count) proposals, \(report.heldBack.count) held back")
        let proposal = report.proposals[0]
        try check(SyntheticGrouping.stopIDs(proposal) == ["syn-q2", "syn-r2"], "members")
        try check(proposal.findings.isEmpty, "findings")
        let q2 = proposal.members[0]
        try check(q2.routes.map(\.routeID.text) == ["syn-route-q"] && q2.routes[0].neighbors.map(\.text) == ["syn-q1", "syn-q3"], "neighbour context")
        try check(q2.names.map(\.value.text) == ["Synthetic Hub", "Synthetic Hub (EN)"], "names listed as hints")
        try check(q2.stop.member?.name == "stops.txt" && q2.stop.inputSHA256 == SyntheticGrouping.archiveA && q2.stop.field == "stop_id", "source reference")

        guard case .success(let outcome) = applyExpecting([], report, input) else { throw TestFailure(message: "apply failed") }
        try check(SyntheticGrouping.identities(outcome) == SyntheticGrouping.separate, "rows merged without a record")
        try check(outcome.unreviewedProposals == [proposal], "the unreviewed proposal is reported")
    }),
    ("only an accepted reviewed record merges; a rejected one keeps the rows apart", { _ in
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed())
        let report = StationGrouping.propose(input)
        let accepted = try SyntheticGrouping.record("SYN-REVIEW-G1", report.proposals[0], .accepted(exception: nil))
        guard case .success(let merged) = applyExpecting([accepted], report, input) else { throw TestFailure(message: "apply failed") }
        try check(SyntheticGrouping.identities(merged) == [["syn-q1"], ["syn-q2", "syn-r2"], ["syn-q3"], ["syn-r1"], ["syn-r3"]], "\(SyntheticGrouping.identities(merged))")
        try check(merged.acceptedReviews == ["SYN-REVIEW-G1"] && merged.unreviewedProposals.isEmpty, "accepted")

        let rejected = try SyntheticGrouping.record("SYN-REVIEW-G2", report.proposals[0], .rejected)
        guard case .success(let apart) = applyExpecting([rejected], report, input) else { throw TestFailure(message: "apply failed") }
        try check(SyntheticGrouping.identities(apart) == SyntheticGrouping.separate && apart.rejectedReviews == ["SYN-REVIEW-G2"], "rejected")
    }),
    ("a record whose evidence changed no longer applies", { _ in
        let reviewed = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed()))
        let record = try SyntheticGrouping.record("SYN-REVIEW-G1", reviewed.proposals[0], .accepted(exception: nil))
        var trips = SyntheticGrouping.trips
        trips[1] = ("syn-route-r", ["syn-r2", "syn-r3"])
        let changedInput = try SyntheticGrouping.input(SyntheticGrouping.feed(trips: trips))
        let changed = StationGrouping.propose(changedInput)
        try check(changed.proposals.count == 1 && changed.proposals[0].evidenceSHA256 != record.evidenceSHA256, "evidence digest")
        let result = applyExpecting([record], changed, changedInput)
        try check(result == .failure(.evidenceChanged(reviewID: "SYN-REVIEW-G1")), "\(result)")

        // A neighbour replaced by another, with the count unchanged.
        let swapped = SyntheticGrouping.stops + [SyntheticGrouping.Stop(id: "syn-r4", code: "R04", name: "Synthetic Zeta")]
        var swappedTrips = SyntheticGrouping.trips
        swappedTrips[1] = ("syn-route-r", ["syn-r1", "syn-r2", "syn-r4"])
        let swappedInput = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: swapped, trips: swappedTrips))
        let swappedResult = applyExpecting([record], StationGrouping.propose(swappedInput), swappedInput)
        try check(swappedResult == .failure(.evidenceChanged(reviewID: "SYN-REVIEW-G1")), "a swapped neighbour: \(swappedResult)")
    }),
    ("rows that share a route are contradictory and held back with their source references", { _ in
        var trips = SyntheticGrouping.trips
        trips.append(("syn-route-q", ["syn-q1", "syn-r2", "syn-q3"]))
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed(trips: trips))
        let report = StationGrouping.propose(input)
        try check(report.proposals.isEmpty && report.heldBack.count == 1, "held back")
        let held = report.heldBack[0]
        let shared = held.findings.filter { $0.check == .noSharedRoute }
        try check(shared.map { $0.stops.map(\.text) } == [["syn-q2", "syn-r2"]] && shared[0].routes.map(\.text) == ["syn-route-q"], "\(held.findings)")
        try check(held.failedChecks.contains(.codeConsistency), "a Q route serving an R-coded row")
        try check(held.members.allSatisfy { $0.stop.member?.name == "stops.txt" && $0.stop.table == "stops" }, "source references")
        guard case .success(let outcome) = applyExpecting([], report, input) else { throw TestFailure(message: "apply failed") }
        try check(SyntheticGrouping.identities(outcome) == SyntheticGrouping.separate && outcome.heldBack == [held], "kept separate")
    }),
    ("a row linked only through some of its names is a competing candidate", { _ in
        var stops = SyntheticGrouping.stops
        stops.append(SyntheticGrouping.Stop(id: "syn-s1", code: "S01", name: "Synthetic Hub Annex"))
        stops.append(SyntheticGrouping.Stop(id: "syn-s2", code: "S02", name: "Synthetic Epsilon"))
        var trips = SyntheticGrouping.trips
        trips.append(("syn-route-s", ["syn-s1", "syn-s2"]))
        var routes = SyntheticGrouping.routes
        routes.append(("syn-route-s", "syn-agency"))
        var translations = SyntheticGrouping.translations
        translations.append(("Synthetic Hub Annex", "en", "Synthetic Hub (EN)"))
        let report = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(stops: stops, routes: routes, trips: trips, translations: translations)))
        try check(report.proposals.isEmpty && report.heldBack.count == 1, "held back")
        try check(SyntheticGrouping.stopIDs(report.heldBack[0]) == ["syn-q2", "syn-r2", "syn-s1"], "members")
        try check(report.heldBack[0].failedChecks == [.noCompetingCandidate], "\(report.heldBack[0].findings)")
    }),
    ("incomplete evidence is held back: a missing code, and a row with no neighbouring stop", { _ in
        var stops = SyntheticGrouping.stops
        stops[1] = SyntheticGrouping.Stop(id: "syn-q2", code: nil, name: "Synthetic Hub")
        stops.append(SyntheticGrouping.Stop(id: "syn-t1", code: "T01", name: "Synthetic Hub"))
        let routes = SyntheticGrouping.routes + [("syn-route-t", "syn-agency")]
        let trips = SyntheticGrouping.trips + [("syn-route-t", ["syn-t1"])]
        let report = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(stops: stops, routes: routes, trips: trips)))
        try check(report.heldBack.count == 1 && SyntheticGrouping.stopIDs(report.heldBack[0]) == ["syn-q2", "syn-r2", "syn-t1"], "held back")
        let findings = report.heldBack[0].findings
        try check(findings.contains(GroupingFinding(check: .codeConsistency, stops: [ExactValue("syn-q2")!], routes: [])), "missing code")
        try check(findings.contains(GroupingFinding(check: .neighborContext, stops: [ExactValue("syn-t1")!], routes: [ExactValue("syn-route-t")!])), "no neighbouring stop")
    }),
    ("a row served by no route has no established operator: it is never grouped, and it competes", { _ in
        let unservedPair = [
            SyntheticGrouping.Stop(id: "syn-u1", code: "Q01", name: "Synthetic Hub"),
            SyntheticGrouping.Stop(id: "syn-u2", code: "R01", name: "Synthetic Hub"),
        ]
        let pairInput = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: unservedPair, trips: []))
        let pairReport = StationGrouping.propose(pairInput)
        let held = pairReport.heldBack[0]
        try check(held.failedChecks.contains(.oneOperator), "\(held.findings)")
        let waivable = held.failedChecks.filter(\.isWaivable).sorted()
        let decision: GroupingDecision = waivable.isEmpty
            ? .accepted(exception: nil)
            : .accepted(exception: try GroupingException(reason: "Everything waivable", waivedChecks: waivable))
        let result = applyExpecting([try SyntheticGrouping.record("SYN-REVIEW-N1", held, decision)], pairReport, pairInput)
        try check(result == .failure(.crossesOperatorBoundary(reviewID: "SYN-REVIEW-N1")), "\(result)")

        // Beside an established pair, the unserved row only competes; it can
        // never join the pair, even when the pair is accepted by exception.
        let stops = SyntheticGrouping.stops + [SyntheticGrouping.Stop(id: "syn-x1", code: "Q09", name: "Synthetic Hub")]
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: stops))
        let report = StationGrouping.propose(input)
        let pair = report.heldBack[0]
        try check(SyntheticGrouping.stopIDs(pair) == ["syn-q2", "syn-r2"] && pair.failedChecks == [.noCompetingCandidate], "\(pair.findings)")
        let accepted = try SyntheticGrouping.record("SYN-REVIEW-N2", pair, .accepted(exception: try GroupingException(reason: "Reviewed competitor", waivedChecks: [.noCompetingCandidate])))
        guard case .success(let outcome) = applyExpecting([accepted], report, input) else { throw TestFailure(message: "apply failed") }
        try check(SyntheticGrouping.identities(outcome).contains(["syn-q2", "syn-r2"]) && SyntheticGrouping.identities(outcome).contains(["syn-x1"]), "the unserved row joined a grouping")
    }),
    ("an exception waives exactly the failed checks of its one grouping", { _ in
        var stops = SyntheticGrouping.stops
        stops[1] = SyntheticGrouping.Stop(id: "syn-q2", code: nil, name: "Synthetic Hub")
        stops += [
            SyntheticGrouping.Stop(id: "syn-q4", code: nil, name: "Synthetic Port"),
            SyntheticGrouping.Stop(id: "syn-r4", code: "R04", name: "Synthetic Port"),
        ]
        let trips: [(route: String, stops: [String])] = [
            ("syn-route-q", ["syn-q1", "syn-q2", "syn-q3", "syn-q4"]),
            ("syn-route-r", ["syn-r1", "syn-r2", "syn-r3", "syn-r4"]),
        ]
        let translations = SyntheticGrouping.translations + [("Synthetic Port", "en", "Synthetic Port (EN)")]
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: stops, trips: trips, translations: translations))
        let report = StationGrouping.propose(input)
        try check(report.heldBack.count == 2 && report.heldBack.allSatisfy { $0.failedChecks == [.codeConsistency] }, "two held back")
        let hub = report.heldBack.first { SyntheticGrouping.stopIDs($0) == ["syn-q2", "syn-r2"] }!

        let exception = try GroupingException(reason: "Synthetic reviewed exception", waivedChecks: [.codeConsistency])
        let record = try SyntheticGrouping.record("SYN-REVIEW-X1", hub, .accepted(exception: exception))
        guard case .success(let outcome) = applyExpecting([record], report, input) else { throw TestFailure(message: "apply failed") }
        let identities = SyntheticGrouping.identities(outcome)
        try check(identities.contains(["syn-q2", "syn-r2"]), "the excepted grouping merged")
        try check(identities.contains(["syn-q4"]) && identities.contains(["syn-r4"]), "the exception reached another grouping")
        try check(outcome.heldBack.map(SyntheticGrouping.stopIDs) == [["syn-q4", "syn-r4"]], "the other candidate stays held back")

        let tooWide = try SyntheticGrouping.record("SYN-REVIEW-X2", hub, .accepted(exception: try GroupingException(reason: "Too wide", waivedChecks: [.codeConsistency, .noSharedRoute])))
        let missing = try SyntheticGrouping.record("SYN-REVIEW-X3", hub, .accepted(exception: nil))
        for bad in [tooWide, missing] {
            let result = applyExpecting([bad], report, input)
            try check(result == .failure(.exceptionMismatch(reviewID: bad.reviewID)), "\(result)")
        }
        let clean = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed()))
        let needless = try SyntheticGrouping.record("SYN-REVIEW-X4", clean.proposals[0], .accepted(exception: exception))
        let result = applyExpecting([needless], clean, try SyntheticGrouping.input(SyntheticGrouping.feed()))
        try check(result == .failure(.exceptionMismatch(reviewID: "SYN-REVIEW-X4")), "an exception on a clean proposal: \(result)")
    }),
    ("a record must name exactly one candidate of this input", { _ in
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed())
        let report = StationGrouping.propose(input)
        let proposal = report.proposals[0]
        let partial = try ReviewedGroupingRecord(
            reviewID: "SYN-REVIEW-P1", sourceID: SyntheticGrouping.source, inputSHA256: SyntheticGrouping.archiveA,
            members: [proposal.members[0].stop, input.stopReference(ExactValue("syn-q1")!)],
            evidenceSHA256: proposal.evidenceSHA256, decision: .accepted(exception: nil)
        )
        try check(applyExpecting([partial], report, input) == .failure(.notACandidate(reviewID: "SYN-REVIEW-P1")), "partial members")

        let other = try SyntheticGrouping.input(SyntheticGrouping.feed(), archive: SyntheticGrouping.archiveB)
        let foreign = try SyntheticGrouping.record("SYN-REVIEW-P2", StationGrouping.propose(other).proposals[0], .accepted(exception: nil), archive: SyntheticGrouping.archiveB)
        try check(applyExpecting([foreign], report, input) == .failure(.recordForOtherInput(reviewID: "SYN-REVIEW-P2")), "other input")
    }),
    ("another operator's same-name row cannot absorb a valid proposal; an unestablished one competes", { _ in
        let stops = SyntheticGrouping.stops + [
            SyntheticGrouping.Stop(id: "syn-s1", code: "S01", name: "Synthetic Hub"),
            SyntheticGrouping.Stop(id: "syn-s2", code: "S02", name: "Synthetic Epsilon"),
        ]
        let trips = SyntheticGrouping.trips + [("syn-route-s", ["syn-s1", "syn-s2"])]
        let routes: [(id: String, agency: String?)] = [("syn-route-q", "syn-agency-a"), ("syn-route-r", "syn-agency-a"), ("syn-route-s", "syn-agency-b")]
        let report = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(
            stops: stops, routes: routes, trips: trips, agencies: ["syn-agency-a", "syn-agency-b"]
        )))
        try check(report.proposals.map(SyntheticGrouping.stopIDs) == [["syn-q2", "syn-r2"]], "\(report.heldBack.map(\.findings))")
        try check(report.heldBack.isEmpty, "the other operator's row was reported as a candidate")

        let unserved = SyntheticGrouping.stops + [SyntheticGrouping.Stop(id: "syn-u1", code: "Q09", name: "Synthetic Hub")]
        let competing = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(stops: unserved)))
        try check(competing.proposals.isEmpty && competing.heldBack.count == 1, "held back")
        let finding = competing.heldBack[0].findings.first { $0.check == .noCompetingCandidate }
        try check(SyntheticGrouping.stopIDs(competing.heldBack[0]) == ["syn-q2", "syn-r2"] && finding?.stops.map(\.text) == ["syn-u1"], "\(competing.heldBack[0].findings)")
    }),
    ("a candidate without Japanese and English name evidence is held back", { _ in
        let noEnglish = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(translations: [])))
        try check(noEnglish.proposals.isEmpty && noEnglish.heldBack.first?.failedChecks == [.nameEvidence], "no English: \(String(describing: noEnglish.heldBack.first?.findings))")
        try check(noEnglish.heldBack[0].findings[0].stops.map(\.text) == ["syn-q2", "syn-r2"], "the rows missing names")

        let englishFeed = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(feedLanguage: "en")))
        try check(englishFeed.heldBack.first?.failedChecks == [.nameEvidence], "no Japanese in an English feed")

        let unknownLanguage = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(feedLanguage: nil)))
        try check(unknownLanguage.heldBack.first?.failedChecks == [.nameEvidence], "the published name's language is unknown")

        var withJapanese = SyntheticGrouping.translations
        withJapanese.append(("Synthetic Hub", "ja-JP", "合成ハブ"))
        let translated = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(translations: withJapanese, feedLanguage: "en")))
        try check(translated.proposals.count == 1, "a ja-JP translation did not count: \(translated.heldBack.map(\.findings))")
    }),
    ("the operator boundary cannot be crossed, even with an exception for other checks", { _ in
        var stops = SyntheticGrouping.stops
        stops[1] = SyntheticGrouping.Stop(id: "syn-q2", code: nil, name: "Synthetic Hub")
        // Both routes name agencies the feed does not define, so neither row
        // has an established operator.
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed(
            stops: stops, routes: [("syn-route-q", "syn-agency-x"), ("syn-route-r", "syn-agency-y")]
        ))
        let report = StationGrouping.propose(input)
        let held = report.heldBack[0]
        try check(held.failedChecks == [.oneOperator, .codeConsistency], "\(held.findings)")
        do {
            _ = try GroupingException(reason: "Cross operator", waivedChecks: [.oneOperator, .codeConsistency])
            throw TestFailure(message: "the operator boundary was waivable")
        } catch let error as GroupingException.Invalid {
            try check(error == .nonWaivableCheck, "\(error)")
        }
        let otherChecks = try GroupingException(reason: "Only the code", waivedChecks: [.codeConsistency])
        for decision in [GroupingDecision.accepted(exception: otherChecks), .accepted(exception: nil)] {
            let record = try SyntheticGrouping.record("SYN-REVIEW-B1", held, decision)
            let result = applyExpecting([record], report, input)
            try check(result == .failure(.crossesOperatorBoundary(reviewID: "SYN-REVIEW-B1")), "\(result)")
        }
        let rejected = try SyntheticGrouping.record("SYN-REVIEW-B2", held, .rejected)
        guard case .success(let apart) = applyExpecting([rejected], report, input) else { throw TestFailure(message: "a rejection failed") }
        try check(apart.identities.count == 6, "rows merged across operators")
    }),
    ("a route without agency_id belongs to the feed's only agency; an undefined agency is unresolved", { _ in
        let mixed = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(routes: [("syn-route-q", "syn-agency"), ("syn-route-r", nil)])))
        try check(mixed.proposals.count == 1 && mixed.heldBack.isEmpty, "a sole-agency feed was split: \(mixed.heldBack.map(\.findings))")
        let undefined = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(routes: [("syn-route-q", "syn-agency"), ("syn-route-r", "syn-agency-x")])))
        try check(undefined.proposals.isEmpty && undefined.heldBack.isEmpty, "a row with an undefined agency was proposed with another operator's row")
    }),
    ("a record naming an unknown row, another stops.txt, or rows never proposed together is refused", { _ in
        let input = try SyntheticGrouping.input(SyntheticGrouping.feed())
        let report = StationGrouping.propose(input)
        let digest = report.proposals[0].evidenceSHA256
        func record(_ id: String, _ members: [SourceReference]) throws -> ReviewedGroupingRecord {
            try ReviewedGroupingRecord(reviewID: id, sourceID: SyntheticGrouping.source, inputSHA256: SyntheticGrouping.archiveA, members: members, evidenceSHA256: digest, decision: .accepted(exception: nil))
        }
        let unknown = try record("SYN-REVIEW-U1", [input.stopReference(ExactValue("syn-q2")!), input.stopReference(ExactValue("syn-nowhere")!)])
        try check(applyExpecting([unknown], report, input) == .failure(.unknownMember(reviewID: "SYN-REVIEW-U1")), "unknown row")

        let otherMember = try report.proposals[0].members.map {
            try SourceReference(inputSHA256: SyntheticGrouping.archiveA, member: .init(name: "stops.txt", sha256: String(repeating: "9", count: 64)), table: "stops", recordIndex: nil, field: "stop_id", providerKey: $0.stopID)
        }
        try check(applyExpecting([try record("SYN-REVIEW-U2", otherMember)], report, input) == .failure(.recordForOtherInput(reviewID: "SYN-REVIEW-U2")), "another stops.txt")

        let differentNames = try record("SYN-REVIEW-U3", [input.stopReference(ExactValue("syn-q1")!), input.stopReference(ExactValue("syn-r1")!)])
        try check(applyExpecting([differentNames], report, input) == .failure(.notACandidate(reviewID: "SYN-REVIEW-U3")), "rows never proposed together")
    }),
    ("proposals, findings, and digests do not depend on row order or coordinates", { _ in
        let forward = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed()))
        let backward = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(reversed: true)))
        try check(forward == backward, "row order changed the report")
        let moved = SyntheticGrouping.stops.map { stop in
            var copy = stop
            copy.latitude = 10.0
            return copy
        }
        let relocated = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(stops: moved)))
        try check(relocated == forward, "coordinates changed the report")
    }),
    ("operators stay separate: same-name stations of two inputs, and a feed with two operators", { _ in
        let operatorA = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: [SyntheticGrouping.Stop(id: "syn-a1", code: "Q01", name: "Synthetic Hub")], trips: [("syn-route-q", ["syn-a1"])]))
        let operatorB = try SyntheticGrouping.input(SyntheticGrouping.feed(stops: [SyntheticGrouping.Stop(id: "syn-b1", code: "R01", name: "Synthetic Hub")], trips: [("syn-route-r", ["syn-b1"])]), archive: SyntheticGrouping.archiveB)
        for input in [operatorA, operatorB] {
            let report = StationGrouping.propose(input)
            try check(report.proposals.isEmpty && report.heldBack.isEmpty, "a single row became a candidate")
        }
        do {
            _ = try ReviewedGroupingRecord(
                reviewID: "SYN-REVIEW-O1", sourceID: SyntheticGrouping.source, inputSHA256: SyntheticGrouping.archiveA,
                members: [operatorA.stopReference(ExactValue("syn-a1")!), operatorB.stopReference(ExactValue("syn-b1")!)],
                evidenceSHA256: SyntheticGrouping.archiveA, decision: .accepted(exception: nil)
            )
            throw TestFailure(message: "a record spanned two inputs")
        } catch let error as ReviewedGroupingRecord.Invalid {
            try check(error == .memberOutsideInput, "\(error)")
        }

        let twoOperators = StationGrouping.propose(try SyntheticGrouping.input(SyntheticGrouping.feed(
            routes: [("syn-route-q", "syn-agency-a"), ("syn-route-r", "syn-agency-b")], agencies: ["syn-agency-a", "syn-agency-b"]
        )))
        try check(twoOperators.proposals.isEmpty && twoOperators.heldBack.isEmpty, "rows of two operators became one candidate")
    }),
]
