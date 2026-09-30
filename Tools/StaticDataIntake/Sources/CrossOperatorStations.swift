import CryptoKit
import Foundation

// Cross-operator station candidates and canonical-station formation
// (DEC-069 §B–§D) — in this offline tool only (ARCHITECTURE.md §4.1).
//
// Two operators' operator-level identities (P2-S4, reviewed) are compared by
// four keys only: the exact original Japanese value, the exact original
// English value, and the two accepted alias rules applied to Japanese values
// as comparison keys. A pair found by several keys is one candidate that keeps
// every discovery reason. Each candidate gets a DEC-048 rule 3 evidence bundle
// and its digest. Candidates are questions: nothing joins without an accepted
// `same` record whose digest matches.
//
// Coverage limitation (DEC-069 §B4): differently named stations that the two
// alias rules do not relate are not candidates. No spatial discovery exists,
// and no distance is computed: coordinates appear in evidence only as the
// decoded provider values. No identifier is minted here.

/// One operator's identified GTFS input with its reviewed operator-level
/// identities.
struct StationSideInput {
    let grouping: GroupingInput
    /// The `translations.txt` member digest, when the archive has one.
    let translationsMemberSHA256: String?
    /// From the reviewed P2-S4 grouping records: every row in exactly one.
    let identities: [OperatorLevelIdentity]

    var sourceID: String { grouping.sourceID }
    var archiveSHA256: String { grouping.archiveSHA256 }

    func side(_ identity: OperatorLevelIdentity) -> CrossOperatorSide {
        try! CrossOperatorSide(sourceID: sourceID, inputSHA256: archiveSHA256, members: identity.members)
    }
}

/// Why a pair became a candidate. Ordered as DEC-069 §B1 lists the keys.
enum StationCandidateKey: Hashable, Comparable {
    case exactJapanese
    case exactEnglish
    case alias(StationAliasRule)

    static let all: [StationCandidateKey] = [.exactJapanese, .exactEnglish] + StationAliasRule.allCases.map { .alias($0) }

    var name: String {
        switch self {
        case .exactJapanese: "exactJapanese"
        case .exactEnglish: "exactEnglish"
        case .alias(let rule): "alias.\(rule.rawValue)"
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool { all.firstIndex(of: lhs)! < all.firstIndex(of: rhs)! }
}

/// Two original values that matched under one key: the first from the
/// candidate's first side, the second from its second side.
struct StationNameMatch: Hashable {
    let first: OriginalName
    let second: OriginalName

    static func precedes(_ lhs: Self, _ rhs: Self) -> Bool {
        if lhs.first != rhs.first { return OriginalName.precedes(lhs.first, rhs.first) }
        return OriginalName.precedes(lhs.second, rhs.second)
    }
}

struct StationDiscoveryReason: Hashable {
    let key: StationCandidateKey
    /// Sorted. Every pair of values that matched under the key.
    let matches: [StationNameMatch]
    /// For an alias key: the explicit, reversible alias records, one per match.
    let aliasMatches: [StationAliasMatch]
}

/// A stop row's evidence: the grouping evidence (code, routes, neighbours),
/// its original names with their sources, and its coordinates as the decoded
/// values — never compared or measured.
/// Where a row appears in one route's trips: every `stop_sequence` value.
struct StationRoutePositions: Hashable {
    let routeID: ExactValue
    /// Sorted, no repeats.
    let positions: [Int]
}

struct StationMemberEvidence: Hashable {
    let base: GroupingMemberEvidence
    let names: [OriginalName]
    /// Station-order positions per serving route, sorted by route.
    let positions: [StationRoutePositions]
    let latitude: String
    let longitude: String

    var stopID: ExactValue { base.stopID }
}

struct StationRouteTitle: Hashable {
    let routeID: ExactValue
    let longName: ExactValue?
}

/// One side of a candidate: one operator-level identity and its evidence.
struct StationCandidateSide: Hashable {
    let side: CrossOperatorSide
    /// Sorted by stop identifier.
    let members: [StationMemberEvidence]
    /// Every route serving a member, sorted: line membership.
    let routes: [StationRouteTitle]

    /// Multi-line occurrence: how many routes serve the identity.
    var routeCount: Int { routes.count }
}

struct StationCandidate: Hashable {
    /// Two, ordered by source.
    let sides: [StationCandidateSide]
    /// Sorted by key.
    let reasons: [StationDiscoveryReason]
    /// Every other candidate that involves either side, as its pair of sides.
    let otherCandidates: [[CrossOperatorSide]]
    let evidenceSHA256: String

    var pair: [CrossOperatorSide] { sides.map(\.side) }
    var keys: Set<StationCandidateKey> { Set(reasons.map(\.key)) }
    var aliasRules: Set<StationAliasRule> {
        Set(reasons.compactMap { if case .alias(let rule) = $0.key { rule } else { nil } })
    }
}

struct StationCandidateReport: Equatable {
    /// The two sides' sources and inputs, ordered by source.
    let sides: [(sourceID: String, archiveSHA256: String)]
    let candidates: [StationCandidate]

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.sides.map(\.sourceID) == rhs.sides.map(\.sourceID) && lhs.sides.map(\.archiveSHA256) == rhs.sides.map(\.archiveSHA256)
            && lhs.candidates == rhs.candidates
    }
}

/// One canonical station: one operator-level identity, or two joined by an
/// accepted `same` record. Sides ordered by source.
struct CanonicalStationGroup: Hashable {
    let sides: [CrossOperatorSide]

    static func precedes(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.sides.first.map { l in rhs.sides.first.map { CrossOperatorSide.precedes(l, $0) } ?? false } ?? true
    }
}

struct StationFormation: Equatable {
    let report: StationCandidateReport
    /// Candidates no record decided. A registry run needs none.
    let unreviewed: [StationCandidate]
    let same: Int
    let distinct: Int
    let ambiguous: Int
    /// Every operator-level identity of both sides in exactly one group,
    /// sorted. Complete only when `unreviewed` is empty.
    let groups: [CanonicalStationGroup]
}

/// Why a reviewed record could not be applied. Each case names the record,
/// never a provider value.
enum StationFormationError: Error, Equatable {
    case sidesNotTwoSources
    /// The record names another source or input.
    case recordForOtherInput(reviewID: String)
    /// The record's identities are not exactly one candidate's.
    case notACandidate(reviewID: String)
    /// The evidence changed since the record was reviewed.
    case evidenceChanged(reviewID: String)
    /// A cited alias rule that did not relate this candidate's names. An
    /// alias is never invented to permit a merge.
    case aliasNotUsed(reviewID: String)
    /// A `same` on a candidate whose Japanese names an alias rule related,
    /// with no exact Japanese match, that cites no alias rule (DEC-069 §C3).
    case aliasNotCited(reviewID: String)
    /// A `same` on a candidate whose names differ, with no alias rule relating
    /// them, that names no evidence provenance.
    case sameWithoutBasis(reviewID: String)
}

enum CrossOperatorStations {
    // MARK: - Candidates

    static func propose(_ inputs: [StationSideInput]) throws(StationFormationError) -> StationCandidateReport {
        guard inputs.count == 2, inputs[0].sourceID != inputs[1].sourceID else { throw .sidesNotTwoSources }
        let sides = inputs.sorted { $0.sourceID.utf8.lexicographicallyPrecedes($1.sourceID.utf8) }

        struct Identity {
            let side: CrossOperatorSide
            let evidence: StationCandidateSide
            let japanese: [OriginalName]
            let english: [OriginalName]
        }
        let identities: [[Identity]] = sides.map { input in
            let byStop = Dictionary(uniqueKeysWithValues: memberEvidence(input).map { ($0.stopID, $0) })
            let titles = Dictionary(input.grouping.feed.routes.compactMap { route in
                ExactValue(route.routeID).map { ($0, route.longName.flatMap(ExactValue.init)) }
            }, uniquingKeysWith: { first, _ in first })
            return input.identities.map { identity in
                let members = identity.members.map { byStop[$0.providerKey]! }
                let routes = Set(members.flatMap { $0.base.routes.map(\.routeID) }).sorted()
                    .map { StationRouteTitle(routeID: $0, longName: titles[$0] ?? nil) }
                let names = members.flatMap(\.names)
                return Identity(
                    side: input.side(identity),
                    evidence: StationCandidateSide(side: input.side(identity), members: members, routes: routes),
                    japanese: names.filter { StationGrouping.displayLanguage($0.language.text) == "ja" },
                    english: names.filter { StationGrouping.displayLanguage($0.language.text) == "en" }
                )
            }
        }

        // Every match, by pair of identities and key.
        struct Pair: Hashable { let first: Int; let second: Int }
        var found: [Pair: [StationCandidateKey: Set<StationNameMatch>]] = [:]
        func index(_ names: (Identity) -> [OriginalName], _ key: (ExactValue) -> ExactValue, side: Int) -> [ExactValue: [(Int, OriginalName)]] {
            var index: [ExactValue: [(Int, OriginalName)]] = [:]
            for (position, identity) in identities[side].enumerated() {
                for name in names(identity) { index[key(name.value), default: []].append((position, name)) }
            }
            return index
        }
        func collect(_ candidateKey: StationCandidateKey, _ names: (Identity) -> [OriginalName], _ key: (ExactValue) -> ExactValue, related: (ExactValue, ExactValue) -> Bool) {
            let left = index(names, key, side: 0)
            let right = index(names, key, side: 1)
            for (value, firsts) in left {
                guard let seconds = right[value] else { continue }
                for (i, first) in firsts {
                    for (j, second) in seconds where related(first.value, second.value) {
                        found[Pair(first: i, second: j), default: [:]][candidateKey, default: []].insert(StationNameMatch(first: first, second: second))
                    }
                }
            }
        }
        collect(.exactJapanese, \.japanese, { $0 }, related: ==)
        collect(.exactEnglish, \.english, { $0 }, related: ==)
        for rule in StationAliasRule.allCases {
            collect(.alias(rule), \.japanese, rule.comparisonKey, related: rule.relates)
        }

        // One candidate per pair; other candidates listed per side.
        let pairs = found.keys.sorted { lhs, rhs in
            let (l, r) = ([identities[0][lhs.first].side, identities[1][lhs.second].side], [identities[0][rhs.first].side, identities[1][rhs.second].side])
            if l[0] != r[0] { return CrossOperatorSide.precedes(l[0], r[0]) }
            return CrossOperatorSide.precedes(l[1], r[1])
        }
        let sideInputs = sides.map { ($0.sourceID, $0.archiveSHA256, $0.grouping.stopsMemberSHA256) }
        let candidates = pairs.map { pair -> StationCandidate in
            let reasons = found[pair]!.keys.sorted().map { key -> StationDiscoveryReason in
                let matches = found[pair]![key]!.sorted(by: StationNameMatch.precedes)
                var aliases: [StationAliasMatch] = []
                if case .alias(let rule) = key {
                    aliases = matches.map { try! StationAliasMatch(rule: rule, $0.first, $0.second) }
                }
                return StationDiscoveryReason(key: key, matches: matches, aliasMatches: aliases)
            }
            let others = pairs.filter { $0 != pair && ($0.first == pair.first || $0.second == pair.second) }
                .map { [identities[0][$0.first].side, identities[1][$0.second].side] }
            let candidateSides = [identities[0][pair.first].evidence, identities[1][pair.second].evidence]
            return StationCandidate(
                sides: candidateSides, reasons: reasons, otherCandidates: others,
                evidenceSHA256: digest(sideInputs, candidateSides, reasons, others)
            )
        }
        return StationCandidateReport(sides: sides.map { ($0.sourceID, $0.archiveSHA256) }, candidates: candidates)
    }

    /// Each row's evidence, with its original names and their sources: the
    /// published `stop_name` in the feed's language, and each `stops.stop_name`
    /// translation of it.
    static func memberEvidence(_ input: StationSideInput) -> [StationMemberEvidence] {
        let feed = input.grouping.feed
        let feedLanguage = feed.feedInfo.first.map(\.language) ?? (feed.agencies.count == 1 ? feed.agencies[0].language : nil)
        let stopsMember = SourceReference.Member(name: "stops.txt", sha256: input.grouping.stopsMemberSHA256)
        func reference(_ member: SourceReference.Member, _ table: String, _ field: String, _ stopID: ExactValue) -> SourceReference {
            try! SourceReference(inputSHA256: input.archiveSHA256, member: member, table: table, recordIndex: nil, field: field, providerKey: stopID)
        }
        var translations: [ExactValue: [(ExactValue, ExactValue)]] = [:]
        for row in feed.translations where row.tableName == "stops" && row.fieldName == "stop_name" {
            guard let key = row.fieldValue.flatMap(ExactValue.init), let language = ExactValue(row.language),
                  let value = ExactValue(row.translation) else { continue }
            translations[key, default: []].append((language, value))
        }
        var tripRoute: [String: ExactValue] = [:]
        for trip in feed.trips { tripRoute[trip.tripID] = ExactValue(trip.routeID) }
        var positions: [ExactValue: [ExactValue: Set<Int>]] = [:]
        for stopTime in feed.stopTimes {
            guard let route = tripRoute[stopTime.tripID], let stop = ExactValue(stopTime.stopID) else { continue }
            positions[stop, default: [:]][route, default: []].insert(stopTime.stopSequence)
        }
        let base = StationGrouping.memberEvidence(input.grouping)
        return zip(feed.stops, base).map { stop, evidence in
            var names: [OriginalName] = []
            if let published = ExactValue(stop.name) {
                if let language = feedLanguage.flatMap(ExactValue.init) {
                    names.append(OriginalName(language: language, value: published, source: reference(stopsMember, "stops", "stop_name", evidence.stopID)))
                }
                if let sha = input.translationsMemberSHA256 {
                    let member = SourceReference.Member(name: "translations.txt", sha256: sha)
                    for (language, value) in translations[published] ?? [] {
                        names.append(OriginalName(language: language, value: value, source: reference(member, "translations", "translation", evidence.stopID)))
                    }
                }
            }
            var seen = Set<[String]>()
            names = names.filter { seen.insert([$0.language.text, $0.value.text]).inserted }.sorted(by: OriginalName.precedes)
            let routePositions = (positions[evidence.stopID] ?? [:]).keys.sorted().map {
                StationRoutePositions(routeID: $0, positions: positions[evidence.stopID]![$0]!.sorted())
            }
            return StationMemberEvidence(
                base: evidence, names: names, positions: routePositions, latitude: String(describing: stop.latitude), longitude: String(describing: stop.longitude)
            )
        }
    }

    /// SHA-256 over a length-prefixed encoding of both inputs, both sides'
    /// evidence, the discovery reasons, and the other candidates. It changes
    /// whenever anything a reviewer saw changes.
    private static func digest(
        _ inputs: [(String, String, String)], _ sides: [StationCandidateSide],
        _ reasons: [StationDiscoveryReason], _ others: [[CrossOperatorSide]]
    ) -> String {
        var bytes: [UInt8] = []
        func field(_ text: String) { bytes += Array(String(text.utf8.count).utf8) + [0x3A] + Array(text.utf8) }
        func optional(_ value: ExactValue?) { if let value { field("1"); field(value.text) } else { field("0") } }
        func name(_ name: OriginalName) {
            field(name.language.text); field(name.value.text)
            field(name.source.member?.name ?? ""); field(name.source.field); field(name.source.providerKey.text)
        }
        field("tsugino.cross-operator-evidence.v1")
        for (sourceID, archive, stopsMember) in inputs { field(sourceID); field(archive); field(stopsMember) }
        for side in sides {
            field(side.side.sourceID)
            field(String(side.routes.count))
            for route in side.routes { field(route.routeID.text); optional(route.longName) }
            field(String(side.members.count))
            for member in side.members {
                field(member.stopID.text)
                optional(member.base.code)
                field(member.latitude); field(member.longitude)
                field(String(member.names.count))
                for entry in member.names { name(entry) }
                field(String(member.base.routes.count))
                for route in member.base.routes {
                    field(route.routeID.text)
                    field(route.codeFitsRoute ? "fits" : "misfits")
                    field(String(route.neighbors.count))
                    for neighbor in route.neighbors { field(neighbor.text) }
                }
                field(String(member.positions.count))
                for route in member.positions {
                    field(route.routeID.text)
                    field(route.positions.map(String.init).joined(separator: ","))
                }
            }
        }
        field(String(reasons.count))
        for reason in reasons {
            field(reason.key.name)
            field(String(reason.matches.count))
            for match in reason.matches { name(match.first); name(match.second) }
        }
        field(String(others.count))
        for pair in others {
            for side in pair {
                field(side.sourceID)
                field(String(side.members.count))
                for member in side.members { field(member.providerKey.text) }
            }
        }
        return hexString(SHA256.hash(data: bytes))
    }

    // MARK: - Applying reviewed records

    /// Applies the records to the candidates of the same inputs and forms the
    /// canonical station groups. Every identity starts alone; only an
    /// accepted `same` joins two. Candidates no record decides are returned,
    /// not guessed.
    static func apply(
        _ records: ReviewedCrossOperatorSet, to inputs: [StationSideInput]
    ) throws(StationFormationError) -> StationFormation {
        let report = try propose(inputs)
        let known = Set(report.sides.map { [$0.sourceID, $0.archiveSHA256] })
        var decided = Set<String>()
        var joined: [[CrossOperatorSide]] = []
        var counts = (same: 0, distinct: 0, ambiguous: 0)
        for record in records.records {
            guard record.sides.allSatisfy({ known.contains([$0.sourceID, $0.inputSHA256]) }) else {
                throw .recordForOtherInput(reviewID: record.reviewID)
            }
            guard let candidate = report.candidates.first(where: { $0.pair == record.sides }) else {
                throw .notACandidate(reviewID: record.reviewID)
            }
            guard candidate.evidenceSHA256 == record.evidenceSHA256 else { throw .evidenceChanged(reviewID: record.reviewID) }
            switch record.outcome {
            case .same:
                guard Set(record.citedAliasRules).isSubset(of: candidate.aliasRules) else { throw .aliasNotUsed(reviewID: record.reviewID) }
                if !candidate.keys.contains(.exactJapanese) {
                    // An alias rule that related the names is cited; with none,
                    // other documented evidence is named by provenance.
                    if !candidate.aliasRules.isEmpty {
                        guard !record.citedAliasRules.isEmpty else { throw .aliasNotCited(reviewID: record.reviewID) }
                    } else {
                        guard !record.evidenceProvenance.isEmpty else { throw .sameWithoutBasis(reviewID: record.reviewID) }
                    }
                }
                joined.append(record.sides)
                counts.same += 1
            case .distinct: counts.distinct += 1
            case .ambiguous: counts.ambiguous += 1
            }
            decided.insert(candidate.evidenceSHA256)
        }

        let joinedSides = Set(joined.flatMap { $0 })
        var groups = joined.map(CanonicalStationGroup.init)
        for input in inputs {
            for identity in input.identities where !joinedSides.contains(input.side(identity)) {
                groups.append(CanonicalStationGroup(sides: [input.side(identity)]))
            }
        }
        groups.sort(by: CanonicalStationGroup.precedes)
        return StationFormation(
            report: report,
            unreviewed: report.candidates.filter { !decided.contains($0.evidenceSHA256) },
            same: counts.same, distinct: counts.distinct, ambiguous: counts.ambiguous,
            groups: groups
        )
    }
}
