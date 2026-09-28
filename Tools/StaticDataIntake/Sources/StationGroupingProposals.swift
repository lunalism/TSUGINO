import CryptoKit
import Foundation

// Operator-level station grouping proposals (DEC-068 §D2) — in this offline
// tool only (ARCHITECTURE.md §4.1).
//
// Every `stops` row is its own operator-level identity by default. Names only
// generate candidates. For each candidate the importer gathers structural
// evidence and runs the §D2 checks:
//   - one operator;
//   - no shared route;
//   - codes that fit their routes;
//   - neighbouring stops on every serving route;
//   - uniform name signals.
// A candidate that passes is a *proposal*, and one that fails is *held back*,
// with its findings and source references. Neither merges anything. Rows
// become one identity only through an accepted `ReviewedGroupingRecord` whose
// evidence digest matches; a failed check is accepted only through that
// record's own exception.
//
// One input at a time, so rows of different operators or inputs are never
// related. No coordinate or distance is read, and no identifier is minted.

/// One identified GTFS input: its source, archive digest, `stops.txt` member
/// digest (from the intake manifest), and the reader's DTOs.
struct GroupingInput {
    let sourceID: String
    let archiveSHA256: String
    let stopsMemberSHA256: String
    let feed: GTFSStaticFeed

    enum Invalid: Error, Equatable {
        case malformedSourceID
        case malformedDigest
        case blankStopID
        /// The reader forbids this, but the DTOs can be built directly; a
        /// repeated row would otherwise land in two identities.
        case repeatedStopID
    }

    init(sourceID: String, archiveSHA256: String, stopsMemberSHA256: String, feed: GTFSStaticFeed) throws(Invalid) {
        guard MappingText.isToken(sourceID) else { throw .malformedSourceID }
        guard MappingText.isSHA256(archiveSHA256), MappingText.isSHA256(stopsMemberSHA256) else { throw .malformedDigest }
        guard feed.stops.allSatisfy({ ExactValue($0.stopID) != nil }) else { throw .blankStopID }
        guard Set(feed.stops.map { ExactValue($0.stopID)! }).count == feed.stops.count else { throw .repeatedStopID }
        self.sourceID = sourceID
        self.archiveSHA256 = archiveSHA256
        self.stopsMemberSHA256 = stopsMemberSHA256
        self.feed = feed
    }

    /// The source reference of a `stops.stop_id` value.
    func stopReference(_ stopID: ExactValue) -> SourceReference {
        try! SourceReference(
            inputSHA256: archiveSHA256,
            member: .init(name: "stops.txt", sha256: stopsMemberSHA256),
            table: "stops",
            recordIndex: nil,
            field: "stop_id",
            providerKey: stopID
        )
    }
}

/// A name value listed as a hint: the published `stop_name` (no language) or
/// one of its `translations`.
struct GroupingNameHint: Hashable {
    let language: ExactValue?
    let value: ExactValue
}

/// Who operates a route: an agency the feed defines, the feed's only agency
/// when it has no `agency_id`, or unknown.
enum GroupingRouteOperator: Hashable {
    case agency(ExactValue)
    case soleAgency
    case unresolved
}

/// One route serving a member, with its stop-sequence neighbours.
struct GroupingRouteContext: Hashable {
    let routeID: ExactValue
    let routeOperator: GroupingRouteOperator
    /// Stops adjacent to the member in any trip of this route, sorted.
    let neighbors: [ExactValue]
    /// Whether the member's code prefix is shared by another stop of this route.
    let codeFitsRoute: Bool
}

struct GroupingMemberEvidence: Hashable {
    let stop: SourceReference
    let code: ExactValue?
    /// Hints, never proof: sorted, the published name first.
    let names: [GroupingNameHint]
    /// Sorted by route.
    let routes: [GroupingRouteContext]
    /// Whether the names include a Japanese and an English value: the published
    /// name in the feed's language, or a translation. A script-specific
    /// reading such as `ja-Hrkt` is not a Japanese name.
    let hasJapaneseAndEnglish: Bool

    var stopID: ExactValue { stop.providerKey }
}

/// A failed check, with the stops and routes it concerns.
struct GroupingFinding: Hashable {
    let check: GroupingCheck
    let stops: [ExactValue]
    let routes: [ExactValue]
}

/// A candidate grouping and its evidence. With no findings it is a proposal;
/// with findings it is held back.
struct GroupingCandidate: Hashable {
    /// Sorted by stop identifier.
    let members: [GroupingMemberEvidence]
    /// Sorted by check, then stops, then routes.
    let findings: [GroupingFinding]
    /// The digest a reviewed record must name.
    let evidenceSHA256: String

    var failedChecks: Set<GroupingCheck> { Set(findings.map(\.check)) }
}

struct GroupingReport: Equatable {
    let sourceID: String
    let archiveSHA256: String
    /// Candidates that passed every check, sorted by first member.
    let proposals: [GroupingCandidate]
    /// Candidates that failed a check, sorted by first member.
    let heldBack: [GroupingCandidate]
}

/// One operator-level identity: its `stops` rows, sorted.
struct OperatorLevelIdentity: Hashable {
    let members: [SourceReference]
}

struct GroupingOutcome: Equatable {
    /// The proposals and held-back candidates the records were checked against.
    let report: GroupingReport
    /// Every row of the input, in exactly one identity, sorted by first member.
    let identities: [OperatorLevelIdentity]
    /// Records applied, and records whose rejection kept members apart.
    let acceptedReviews: [String]
    let rejectedReviews: [String]
    /// Proposals no record decided: their rows stay separate.
    let unreviewedProposals: [GroupingCandidate]
    /// Held-back candidates no record accepted: their rows stay separate.
    let heldBack: [GroupingCandidate]
}

/// Why a reviewed record could not be applied. Each case names the record,
/// never a provider value.
enum GroupingApplicationError: Error, Equatable {
    /// The record names another source or archive, or another `stops.txt`.
    case recordForOtherInput(reviewID: String)
    /// A member is not a row of this input.
    case unknownMember(reviewID: String)
    /// The members are rows of this input but not exactly one candidate: rows
    /// the importer never proposed together — for example, rows with no name
    /// in common — cannot be grouped in P2-S4, and nothing merges.
    case notACandidate(reviewID: String)
    /// An acceptance of a candidate that spans operators. The boundary cannot
    /// be waived (DEC-068 §D5).
    case crossesOperatorBoundary(reviewID: String)
    /// The evidence changed since the record was reviewed.
    case evidenceChanged(reviewID: String)
    /// An acceptance whose exception does not waive exactly the failed checks:
    /// missing when a check failed, present when none did, or waiving other
    /// checks.
    case exceptionMismatch(reviewID: String)
}

enum StationGrouping {
    // MARK: - Proposals

    static func propose(_ input: GroupingInput) -> GroupingReport {
        let feed = input.feed
        let stopIDs = feed.stops.map { ExactValue($0.stopID)! }

        // Routes and neighbours, from trips and their ordered stop sequences.
        var tripRoute: [String: ExactValue] = [:]
        for trip in feed.trips { tripRoute[trip.tripID] = ExactValue(trip.routeID) }
        var sequences: [String: [GTFSStopTime]] = [:]
        for stopTime in feed.stopTimes { sequences[stopTime.tripID, default: []].append(stopTime) }
        var served: [ExactValue: Set<ExactValue>] = [:]
        var neighbors: [ExactValue: [ExactValue: Set<ExactValue>]] = [:]
        for (tripID, times) in sequences {
            guard let route = tripRoute[tripID] else { continue }
            let ordered = times.sorted { $0.stopSequence < $1.stopSequence }.compactMap { ExactValue($0.stopID) }
            for (position, stop) in ordered.enumerated() {
                served[stop, default: []].insert(route)
                if position > 0 { neighbors[stop, default: [:]][route, default: []].insert(ordered[position - 1]) }
                if position + 1 < ordered.count { neighbors[stop, default: [:]][route, default: []].insert(ordered[position + 1]) }
            }
        }

        // Code prefixes: the leading ASCII letters of `stop_code`.
        var codes: [ExactValue: ExactValue] = [:]
        for stop in feed.stops { if let code = stop.stopCode.flatMap(ExactValue.init) { codes[ExactValue(stop.stopID)!] = code } }
        var routePrefixStops: [ExactValue: [String: Set<ExactValue>]] = [:]
        for (stop, routes) in served {
            guard let prefix = codes[stop].map(codePrefix), !prefix.isEmpty else { continue }
            for route in routes { routePrefixStops[route, default: [:]][prefix, default: []].insert(stop) }
        }

        // Route operators. With one agency, a route that omits `agency_id`
        // is that agency's, so it compares equal to a route that names it.
        // An `agency_id` the feed does not define is unresolved.
        let knownAgencies = Set(feed.agencies.compactMap { $0.agencyID.flatMap(ExactValue.init) })
        let soleAgency: GroupingRouteOperator? = feed.agencies.count == 1
            ? (feed.agencies[0].agencyID.flatMap(ExactValue.init).map(GroupingRouteOperator.agency) ?? .soleAgency)
            : nil
        var routeOperators: [ExactValue: GroupingRouteOperator] = [:]
        for route in feed.routes {
            guard let routeID = ExactValue(route.routeID) else { continue }
            if let agency = route.agencyID.flatMap(ExactValue.init) {
                routeOperators[routeID] = knownAgencies.contains(agency) ? .agency(agency) : .unresolved
            } else {
                routeOperators[routeID] = soleAgency ?? .unresolved
            }
        }

        // The published name's language: `feed_info`, or else the only agency.
        let feedLanguage = feed.feedInfo.first.map(\.language) ?? (feed.agencies.count == 1 ? feed.agencies[0].language : nil)

        // Name hints: the published name and its `stops.stop_name` translations.
        var translations: [ExactValue: [GroupingNameHint]] = [:]
        for row in feed.translations where row.tableName == "stops" && row.fieldName == "stop_name" {
            guard let key = row.fieldValue.flatMap(ExactValue.init), let value = ExactValue(row.translation) else { continue }
            translations[key, default: []].append(GroupingNameHint(language: ExactValue(row.language), value: value))
        }

        var evidence: [GroupingMemberEvidence] = []
        for (index, stop) in feed.stops.enumerated() {
            let stopID = stopIDs[index]
            var names: [GroupingNameHint] = []
            if let published = ExactValue(stop.name) {
                names.append(GroupingNameHint(language: nil, value: published))
                names += translations[published] ?? []
            }
            let code = codes[stopID]
            let prefix = code.map(codePrefix) ?? ""
            let routes = (served[stopID] ?? []).sorted().map { route in
                GroupingRouteContext(
                    routeID: route,
                    routeOperator: routeOperators[route] ?? .unresolved,
                    neighbors: (neighbors[stopID]?[route] ?? []).sorted(),
                    codeFitsRoute: !prefix.isEmpty && (routePrefixStops[route]?[prefix]?.subtracting([stopID]).isEmpty == false)
                )
            }
            let languages = Set(names.compactMap { $0.language.flatMap { displayLanguage($0.text) } })
                .union(names.contains { $0.language == nil } ? [feedLanguage.flatMap(displayLanguage) ?? ""] : [])
            evidence.append(GroupingMemberEvidence(
                stop: input.stopReference(stopID), code: code, names: sortedHints(Set(names)), routes: routes,
                hasJapaneseAndEnglish: languages.isSuperset(of: ["ja", "en"])
            ))
        }

        // Candidates: rows linked by a shared name value, in any language,
        // within one operator boundary. A row's operator is established when
        // it is served, and every serving route has the same resolved
        // operator. Rows of different established operators are never linked,
        // so another operator's same-name row cannot absorb a valid proposal.
        // Rows with no established operator are linked only with each other;
        // they fail the boundary and are held back.
        func establishedOperator(_ member: GroupingMemberEvidence) -> GroupingRouteOperator? {
            let operators = Set(member.routes.map(\.routeOperator))
            guard operators.count == 1, let only = operators.first, only != .unresolved else { return nil }
            return only
        }
        let operatorOf = evidence.map(establishedOperator)
        var parent = Array(evidence.indices)
        func root(_ i: Int) -> Int {
            var i = i
            while parent[i] != i { parent[i] = parent[parent[i]]; i = parent[i] }
            return i
        }
        struct NameKey: Hashable {
            let routeOperator: GroupingRouteOperator?
            let value: ExactValue
        }
        var firstWithName: [NameKey: Int] = [:]
        for (index, member) in evidence.enumerated() {
            for hint in member.names {
                let key = NameKey(routeOperator: operatorOf[index], value: hint.value)
                if let other = firstWithName[key] {
                    let (a, b) = (root(index), root(other))
                    if a != b { parent[max(a, b)] = min(a, b) }
                } else {
                    firstWithName[key] = index
                }
            }
        }
        var components: [Int: [GroupingMemberEvidence]] = [:]
        for index in evidence.indices { components[root(index), default: []].append(evidence[index]) }

        // Rows with no established operator could belong to any operator, so
        // one that shares a name with a candidate competes with it.
        var unestablishedByName: [ExactValue: Set<ExactValue>] = [:]
        for (index, member) in evidence.enumerated() where operatorOf[index] == nil {
            for hint in member.names { unestablishedByName[hint.value, default: []].insert(member.stopID) }
        }

        var proposals: [GroupingCandidate] = []
        var heldBack: [GroupingCandidate] = []
        for members in components.values where members.count >= 2 {
            let sorted = members.sorted { $0.stopID < $1.stopID }
            let memberIDs = Set(sorted.map(\.stopID))
            let competitors = Set(sorted.flatMap { $0.names.flatMap { unestablishedByName[$0.value] ?? [] } })
                .subtracting(memberIDs)
            let findings = check(sorted, competitors: competitors.sorted())
            let candidate = GroupingCandidate(
                members: sorted, findings: findings, evidenceSHA256: digest(input, sorted, findings)
            )
            if findings.isEmpty { proposals.append(candidate) } else { heldBack.append(candidate) }
        }
        let order: (GroupingCandidate, GroupingCandidate) -> Bool = { $0.members[0].stopID < $1.members[0].stopID }
        return GroupingReport(
            sourceID: input.sourceID, archiveSHA256: input.archiveSHA256,
            proposals: proposals.sorted(by: order), heldBack: heldBack.sorted(by: order)
        )
    }

    /// The DEC-068 §D2 checks. Each failure names the stops and routes it
    /// concerns.
    private static func check(_ members: [GroupingMemberEvidence], competitors: [ExactValue]) -> [GroupingFinding] {
        var findings: [GroupingFinding] = []
        let allStops = members.map(\.stopID)

        // A member served by no route has no established operator, so the
        // boundary cannot be shown to hold: the check fails, and since it is
        // not waivable, such a row is never grouped.
        let operators = Set(members.flatMap { $0.routes.map(\.routeOperator) })
        if operators.count > 1 || operators.contains(.unresolved) || members.contains(where: \.routes.isEmpty) {
            findings.append(GroupingFinding(
                check: .oneOperator, stops: allStops,
                routes: Set(members.flatMap { $0.routes.map(\.routeID) }).sorted()
            ))
        }

        for i in members.indices {
            for j in members.indices where j > i {
                let shared = Set(members[i].routes.map(\.routeID)).intersection(members[j].routes.map(\.routeID))
                if !shared.isEmpty {
                    findings.append(GroupingFinding(
                        check: .noSharedRoute, stops: [members[i].stopID, members[j].stopID], routes: shared.sorted()
                    ))
                }
            }
        }

        for member in members {
            if member.code.map(codePrefix)?.isEmpty ?? true {
                findings.append(GroupingFinding(check: .codeConsistency, stops: [member.stopID], routes: []))
            } else {
                for route in member.routes where !route.codeFitsRoute {
                    findings.append(GroupingFinding(check: .codeConsistency, stops: [member.stopID], routes: [route.routeID]))
                }
            }
            if member.routes.isEmpty {
                findings.append(GroupingFinding(check: .neighborContext, stops: [member.stopID], routes: []))
            }
            for route in member.routes where route.neighbors.isEmpty {
                findings.append(GroupingFinding(check: .neighborContext, stops: [member.stopID], routes: [route.routeID]))
            }
        }

        let missingNames = members.filter { !$0.hasJapaneseAndEnglish }.map(\.stopID)
        if !missingNames.isEmpty {
            findings.append(GroupingFinding(check: .nameEvidence, stops: missingNames, routes: []))
        }

        if Set(members.map { Set($0.names) }).count > 1 {
            findings.append(GroupingFinding(check: .noCompetingCandidate, stops: allStops, routes: []))
        }
        if !competitors.isEmpty {
            findings.append(GroupingFinding(check: .noCompetingCandidate, stops: competitors, routes: []))
        }

        return findings.sorted { lhs, rhs in
            if lhs.check != rhs.check { return lhs.check < rhs.check }
            if lhs.stops != rhs.stops { return lhs.stops.lexicographicallyPrecedes(rhs.stops) }
            return lhs.routes.lexicographicallyPrecedes(rhs.routes)
        }
    }

    /// The language a value counts for as a display name: the primary
    /// subtag, lowercased (`ja` for `ja-JP`), when the tag has no script
    /// subtag or names that language's display script (`ja-Jpan`,
    /// `en-Latn`). A script-specific reading or transliteration — `ja-Hrkt`
    /// kana, `ja-Latn` romaji — counts for no language, so it never stands in
    /// for a Japanese or English name. Shared with line binding.
    static func displayLanguage(_ tag: String) -> String? {
        let subtags = tag.lowercased().split(separator: "-", omittingEmptySubsequences: false).map(String.init)
        guard let primary = subtags.first, !primary.isEmpty else { return nil }
        if subtags.count > 1, subtags[1].count == 4, subtags[1].utf8.allSatisfy({ (0x61...0x7A).contains($0) }) {
            let displayScripts = ["ja": "jpan", "en": "latn"]
            guard displayScripts[primary] == subtags[1] else { return nil }
        }
        return primary
    }

    /// Leading ASCII letters: the observed line-letter part of a code
    /// (DEC-067 Context). A code with none fails `codeConsistency`.
    static func codePrefix(_ code: ExactValue) -> String {
        String(decoding: code.text.utf8.prefix { (0x41...0x5A).contains($0) || (0x61...0x7A).contains($0) }, as: UTF8.self)
    }

    private static func sortedHints(_ hints: Set<GroupingNameHint>) -> [GroupingNameHint] {
        hints.sorted { lhs, rhs in
            switch (lhs.language, rhs.language) {
            case (nil, .some): return true
            case (.some, nil): return false
            case let (l?, r?) where l != r: return l < r
            default: return lhs.value < rhs.value
            }
        }
    }

    /// SHA-256 over a length-prefixed encoding of the input identity, every
    /// member's evidence, and the findings. It changes whenever anything a
    /// reviewer saw changes.
    private static func digest(_ input: GroupingInput, _ members: [GroupingMemberEvidence], _ findings: [GroupingFinding]) -> String {
        var bytes: [UInt8] = []
        func field(_ text: String) {
            bytes += Array(String(text.utf8.count).utf8) + [0x3A] + Array(text.utf8)
        }
        func optional(_ value: ExactValue?) {
            if let value { field("1"); field(value.text) } else { field("0") }
        }
        field("tsugino.grouping-evidence.v1")
        field(input.sourceID)
        field(input.archiveSHA256)
        field(input.stopsMemberSHA256)
        field(String(members.count))
        for member in members {
            field(member.stopID.text)
            optional(member.code)
            field(member.hasJapaneseAndEnglish ? "ja+en" : "names-incomplete")
            field(String(member.names.count))
            for hint in member.names { optional(hint.language); field(hint.value.text) }
            field(String(member.routes.count))
            for route in member.routes {
                field(route.routeID.text)
                switch route.routeOperator {
                case .agency(let agency): field("agency"); field(agency.text)
                case .soleAgency: field("sole")
                case .unresolved: field("unresolved")
                }
                field(route.codeFitsRoute ? "fits" : "misfits")
                field(String(route.neighbors.count))
                for neighbor in route.neighbors { field(neighbor.text) }
            }
        }
        field(String(findings.count))
        for finding in findings {
            field(finding.check.rawValue)
            field(String(finding.stops.count))
            for stop in finding.stops { field(stop.text) }
            field(String(finding.routes.count))
            for route in finding.routes { field(route.text) }
        }
        return hexString(SHA256.hash(data: bytes))
    }

    // MARK: - Applying reviewed records

    /// Builds the operator-level identities: every row alone, except the
    /// members of each accepted record whose evidence and exception match.
    /// The proposals are made here, from the same input, so records can never
    /// be checked against one input and applied to another.
    static func apply(_ records: ReviewedGroupingSet, to input: GroupingInput) throws(GroupingApplicationError) -> GroupingOutcome {
        let report = propose(input)
        let candidates = report.proposals + report.heldBack
        let stopsMember = SourceReference.Member(name: "stops.txt", sha256: input.stopsMemberSHA256)
        let rows = Set(input.feed.stops.map { ExactValue($0.stopID)! })
        var accepted: [String] = []
        var rejected: [String] = []
        var decided = Set<String>()
        var acceptedCandidates = Set<String>()
        var merged: [[SourceReference]] = []

        for record in records.records {
            guard record.sourceID == input.sourceID, record.inputSHA256 == input.archiveSHA256,
                  record.members.allSatisfy({ $0.member == stopsMember })
            else { throw .recordForOtherInput(reviewID: record.reviewID) }
            guard record.members.allSatisfy({ rows.contains($0.providerKey) }) else {
                throw .unknownMember(reviewID: record.reviewID)
            }
            guard let candidate = candidates.first(where: { $0.members.map(\.stop) == record.members }) else {
                throw .notACandidate(reviewID: record.reviewID)
            }
            guard candidate.evidenceSHA256 == record.evidenceSHA256 else {
                throw .evidenceChanged(reviewID: record.reviewID)
            }
            switch record.decision {
            case .accepted(let exception):
                guard !candidate.failedChecks.contains(.oneOperator) else {
                    throw .crossesOperatorBoundary(reviewID: record.reviewID)
                }
                let waived = Set(exception?.waivedChecks ?? [])
                guard waived == candidate.failedChecks, (exception == nil) == candidate.failedChecks.isEmpty else {
                    throw .exceptionMismatch(reviewID: record.reviewID)
                }
                merged.append(record.members)
                accepted.append(record.reviewID)
                acceptedCandidates.insert(candidate.evidenceSHA256)
            case .rejected:
                rejected.append(record.reviewID)
            }
            decided.insert(candidate.evidenceSHA256)
        }

        let grouped = Set(merged.flatMap { $0.map(\.providerKey) })
        var identities = merged.map(OperatorLevelIdentity.init)
        for stop in input.feed.stops {
            let stopID = ExactValue(stop.stopID)!
            if !grouped.contains(stopID) { identities.append(OperatorLevelIdentity(members: [input.stopReference(stopID)])) }
        }
        identities.sort { $0.members[0].providerKey < $1.members[0].providerKey }

        return GroupingOutcome(
            report: report,
            identities: identities,
            acceptedReviews: accepted,
            rejectedReviews: rejected,
            unreviewedProposals: report.proposals.filter { !decided.contains($0.evidenceSHA256) },
            heldBack: report.heldBack.filter { !acceptedCandidates.contains($0.evidenceSHA256) }
        )
    }
}
