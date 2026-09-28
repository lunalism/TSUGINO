import CryptoKit
import Foundation

// Line-binding proposals and reviewed bindings (DEC-068 §D3, §D4) — in this
// offline tool only (ARCHITECTURE.md §4.1).
//
// For one GTFS input and, optionally, one `odpt:Railway` input, the importer
// gathers each route's and each Railway record's official fields and runs
// the §D3 checks: line code against the routes' stop-code prefixes, Japanese
// and English display titles against the routes' long names, and colour. A
// Railway record is a candidate for a route when its line code or a title
// agrees. Candidates are reported as proposals, with every disagreement, and
// bind nothing. In a binding, each record is compared with every bound route
// and each route with every other, so evidence that agrees with one route
// never hides a disagreement with another. Routes and records are bound only
// by an accepted `ReviewedLineBinding` whose evidence digest matches and whose
// acceptances name exactly the checks that disagree. Every route and record
// of the run must be bound, and a binding never crosses operators.
//
// For inputs the operator identifies as launch inputs (`LaunchInputs`), one
// more rule holds and cannot be accepted away: a Railway record whose line
// code is a stop-code prefix of a route is bound with that route. This keeps
// a launch branch record, such as the one DEC-068 §D4 names, on its main
// line's `LineID`. It is not a rule for every feed.
//
// A route's agency is resolved within its feed; the feed's only agency
// stands for a route that names none, as GTFS permits. Binding to an
// `OperatorID` is separate: it needs an active operator reference in the
// registry (DEC-068 §D1). Nothing is written to the registry and no
// identifier is minted or inferred.
//
// A Railway record's station order is kept as evidence with its provenance.
// Which GTFS stops those stations are is not resolved here: that matching
// belongs to canonical station formation (P2-S5), so a record's GTFS stop
// scope is reported as deferred. A stop-code prefix only groups a route's
// stops as evidence for the line-code check; a shared stop may carry the
// main line's code, so a prefix group is never a record's scope. No
// coordinate or distance is read.

/// One GTFS input and, optionally, one `odpt:Railway` input, with the
/// registry their operators and `LineID`s are looked up in.
struct LineBindingInput {
    struct StaticSource {
        let sourceID: String
        let archiveSHA256: String
        /// From the intake manifest.
        let routesMemberSHA256: String
        let stopsMemberSHA256: String
        let feed: GTFSStaticFeed
    }

    struct RailwaySource {
        let sourceID: String
        let inputSHA256: String
        /// In source order: a record's position is its record index.
        let records: [ODPTRailway]
    }

    let gtfs: StaticSource
    let railway: RailwaySource?
    /// Read only: operator references and `LineID` entities.
    let registry: MappingRegistry

    enum Invalid: Error, Equatable {
        case malformedSourceID
        case malformedDigest
        case blankRouteID
        /// The reader forbids this, but the DTOs can be built directly.
        case repeatedRouteID
        case blankRailwayID
        case repeatedRailwayID
        /// A station-order entry with a blank station. It could not be kept as
        /// evidence, and dropping it would lose its position.
        case blankStation
    }

    init(gtfs: StaticSource, railway: RailwaySource?, registry: MappingRegistry) throws(Invalid) {
        guard MappingText.isToken(gtfs.sourceID) else { throw .malformedSourceID }
        guard [gtfs.archiveSHA256, gtfs.routesMemberSHA256, gtfs.stopsMemberSHA256].allSatisfy(MappingText.isSHA256) else {
            throw .malformedDigest
        }
        let routeIDs = gtfs.feed.routes.map { ExactValue($0.routeID) }
        guard routeIDs.allSatisfy({ $0 != nil }) else { throw .blankRouteID }
        guard Set(routeIDs).count == routeIDs.count else { throw .repeatedRouteID }
        if let railway {
            guard MappingText.isToken(railway.sourceID) else { throw .malformedSourceID }
            guard MappingText.isSHA256(railway.inputSHA256) else { throw .malformedDigest }
            let ids = railway.records.map { ExactValue($0.id) }
            guard ids.allSatisfy({ $0 != nil }) else { throw .blankRailwayID }
            guard Set(ids).count == ids.count else { throw .repeatedRailwayID }
            guard railway.records.allSatisfy({ $0.stationOrder.allSatisfy { ExactValue($0.station) != nil } }) else {
                throw .blankStation
            }
        }
        self.gtfs = gtfs
        self.railway = railway
        self.registry = registry
    }

    func routeMember(_ routeID: ExactValue) -> LineBindingMember {
        try! LineBindingMember(sourceID: gtfs.sourceID, reference: SourceReference(
            inputSHA256: gtfs.archiveSHA256,
            member: .init(name: "routes.txt", sha256: gtfs.routesMemberSHA256),
            table: "routes", recordIndex: nil, field: "route_id", providerKey: routeID
        ))
    }

    func railwayMember(_ index: Int) -> LineBindingMember {
        let railway = railway!
        return try! LineBindingMember(sourceID: railway.sourceID, reference: SourceReference(
            inputSHA256: railway.inputSHA256, member: nil, table: nil,
            recordIndex: index, field: "@id", providerKey: ExactValue(railway.records[index].id)!
        ))
    }

    func stopReference(_ stopID: ExactValue) -> SourceReference {
        try! SourceReference(
            inputSHA256: gtfs.archiveSHA256,
            member: .init(name: "stops.txt", sha256: gtfs.stopsMemberSHA256),
            table: "stops", recordIndex: nil, field: "stop_id", providerKey: stopID
        )
    }
}

/// The inputs an operator identifies as launch inputs for a run, by source and
/// SHA-256 (DEC-068 §H). The identities are supplied with the run and are
/// not kept in the repository. When a run's GTFS input and `odpt:Railway`
/// input are both identified, `LineBinding.apply` refuses to split a line
/// code's family across `LineID`s.
struct LaunchInputs: Equatable {
    struct Identity: Hashable {
        let sourceID: String
        let inputSHA256: String
    }

    let identities: Set<Identity>

    static let none = LaunchInputs(identities: [])

    func identifies(_ input: LineBindingInput) -> Bool {
        guard let railway = input.railway else { return false }
        return identities.contains(Identity(sourceID: input.gtfs.sourceID, inputSHA256: input.gtfs.archiveSHA256))
            && identities.contains(Identity(sourceID: railway.sourceID, inputSHA256: railway.inputSHA256))
    }
}

/// The stops a route serves whose code has one letter prefix: evidence for
/// the line-code check, never a Railway record's station scope.
struct LineCodeGroup: Hashable {
    let prefix: String
    /// Sorted by stop identifier.
    let stops: [SourceReference]
}

/// A route's agency, resolved within its feed. This is not an operator: an
/// `OperatorID` needs an active registry reference for the agency.
enum RouteAgency: Hashable {
    /// An `agency_id` the feed defines: the route's own, or the only
    /// agency's when the route names none.
    case agency(ExactValue)
    /// The route names no agency and the feed's only agency has no
    /// `agency_id`, as GTFS permits for one agency. There is no value to
    /// look an operator reference up by.
    case soleAgencyWithoutID
    /// The route names an agency the feed does not define, or names none in
    /// a feed with several agencies.
    case unresolved
}

struct RouteBindingEvidence: Hashable {
    let member: LineBindingMember
    let agency: RouteAgency
    /// The agency's active operator reference, if the registry holds one.
    let operatorID: MintedIdentifier?
    /// The long name in the feed's language, and its `translations`, by
    /// display language (`ja-Hrkt` and other readings excluded).
    let japaneseTitles: [ExactValue]
    let englishTitles: [ExactValue]
    let color: ExactValue?
    /// Sorted by prefix.
    let codeGroups: [LineCodeGroup]
    /// Every stop the route serves, sorted.
    let stops: [SourceReference]

    var routeID: ExactValue { member.reference.providerKey }
}

struct RailwayBindingEvidence: Hashable {
    let member: LineBindingMember
    let operatorReference: ExactValue?
    let operatorID: MintedIdentifier?
    let lineCode: ExactValue?
    let japaneseTitles: [ExactValue]
    let englishTitles: [ExactValue]
    let color: ExactValue?
    /// `odpt:stationOrder`, every entry in source order.
    let stationOrder: [RailwayStationEvidence]
}

/// One `odpt:stationOrder` entry: its `odpt:index` and its station value
/// with provenance (record index and `odpt:stationOrder[n].odpt:station`).
/// Evidence only, not a provider-reference record (DEC-068 §D6).
struct RailwayStationEvidence: Hashable {
    let index: Int
    let station: SourceReference
}

/// A check that fails for one member: a Railway record against the routes
/// bound with it, or a route against the other routes bound with it.
struct LineBindingFinding: Hashable {
    enum Kind: String, Hashable {
        /// Some compared value differs.
        case differs
        /// Nothing differs, but some comparison has no usable value —
        /// including a record bound with no route.
        case missing
    }

    let check: LineBindingCheck
    let member: LineBindingMember
    let kind: Kind
    /// The bound routes the member disagrees with; for `uniqueCounterpart`,
    /// the routes outside the binding the record is also a candidate for.
    let routes: [ExactValue]
}

/// Members and the evidence a reviewed binding of exactly these members must
/// name: a route and its candidate records, or any set a reviewer asks for.
struct LineBindingProposal: Hashable {
    /// Routes by route identifier, then records by record index.
    let members: [LineBindingMember]
    /// Sorted by member, then check.
    let findings: [LineBindingFinding]
    let evidenceSHA256: String
}

struct LineBindingReport: Equatable {
    /// Sorted by route.
    let routes: [RouteBindingEvidence]
    /// In record order.
    let railwayRecords: [RailwayBindingEvidence]
    /// One per route, sorted by route. A record that is a candidate for
    /// several routes appears in each, with a `uniqueCounterpart` finding.
    let proposals: [LineBindingProposal]
    /// Railway records no route is a candidate for.
    let unmatchedRecords: [LineBindingMember]
}

/// Which GTFS stops a bound member covers.
enum StaticStopScope: Hashable {
    /// Every stop the route serves in its trips.
    case served([SourceReference])
    /// Not resolved in P2-S4: matching a Railway record's stations to GTFS
    /// stops belongs to canonical station formation. Nothing partial is
    /// presented in its place.
    case deferred
}

/// A bound provider record, with its provenance for later status scoping
/// (DEC-068 §D4).
struct BoundLineMember: Hashable {
    let member: LineBindingMember
    let staticScope: StaticStopScope
    /// A Railway record's own station order, with provenance; empty for a route.
    let stationOrder: [RailwayStationEvidence]
    let acceptedChecks: [LineBindingCheck]
}

struct BoundLine: Hashable {
    let lineID: MintedIdentifier
    let operatorID: MintedIdentifier
    let reviewID: String
    /// By route identifier.
    let routes: [BoundLineMember]
    /// In record order.
    let railwayRecords: [BoundLineMember]
}

struct LineBindingOutcome: Equatable {
    let report: LineBindingReport
    /// Sorted by `LineID`. Every route and record of the input is in exactly one.
    let lines: [BoundLine]
}

/// Why reviewed bindings could not be applied. Each case names a record or a
/// count, never a provider value.
enum LineBindingApplicationError: Error, Equatable {
    /// A member names another source or input, or another `routes.txt`.
    case recordForOtherInput(reviewID: String)
    /// A member is not a route or Railway record of this input.
    case unknownMember(reviewID: String)
    /// The `LineID` is not an active entity of the registry.
    case unknownLine(reviewID: String)
    /// A route's agency cannot be resolved within its feed.
    case agencyUnresolved(reviewID: String)
    /// A member's agency or `odpt:operator` has no active operator reference
    /// in the registry, or has no value to look one up by. No `OperatorID` is
    /// inferred.
    case operatorUnbound(reviewID: String)
    /// Members of different operators. This cannot be accepted (DEC-068 §D5).
    case crossesOperatorBoundary(reviewID: String)
    /// The evidence changed since the record was reviewed.
    case evidenceChanged(reviewID: String)
    /// A member's acceptance does not name exactly its failed checks:
    /// missing when one fails, present when none does, or naming others.
    case acceptanceMismatch(reviewID: String)
    /// In a launch input, a Railway record is not bound with a route whose
    /// stop-code prefix is its line code. No acceptance can allow this.
    case launchLineSplit(reviewID: String)
    /// Routes or records no reviewed binding names. The run fails.
    case unbound(routes: Int, railwayRecords: Int)
}

enum LineBinding {
    // MARK: - Evidence and proposals

    static func propose(_ input: LineBindingInput) -> LineBindingReport {
        let routes = routeEvidence(input)
        let records = railwayEvidence(input)
        let candidates = candidateRoutes(routes, records)

        var proposals: [LineBindingProposal] = []
        for route in routes {
            let members = records.indices.filter { candidates[$0].contains(route.routeID) }
            proposals.append(evidence(input, [route], members.map { records[$0] }, candidates: members.map { candidates[$0] }))
        }
        return LineBindingReport(
            routes: routes,
            railwayRecords: records,
            proposals: proposals,
            unmatchedRecords: records.indices.filter { candidates[$0].isEmpty }.map { records[$0].member }
        )
    }

    /// The findings and digest for a binding of exactly these members — for
    /// a reviewer who binds other than a proposal's members, such as several
    /// routes, or one candidate of an ambiguous record. `nil` unless the
    /// members are distinct routes and records of this input.
    static func evidence(for members: [LineBindingMember], in input: LineBindingInput) -> LineBindingProposal? {
        let report = propose(input)
        guard let (routes, indices) = resolve(members, report) else { return nil }
        let candidates = candidateRoutes(report.routes, report.railwayRecords)
        return evidence(input, routes, indices.map { report.railwayRecords[$0] }, candidates: indices.map { candidates[$0] })
    }

    /// The members' route evidence, by route, and record indices, sorted; `nil`
    /// if a member is not in the report or is named twice.
    private static func resolve(_ members: [LineBindingMember], _ report: LineBindingReport) -> ([RouteBindingEvidence], [Int])? {
        guard !members.isEmpty, Set(members).count == members.count else { return nil }
        var routes: [RouteBindingEvidence] = []
        var indices: [Int] = []
        for member in members {
            switch member.kind {
            case .staticRoute:
                guard let route = report.routes.first(where: { $0.member == member }) else { return nil }
                routes.append(route)
            case .railwayRecord:
                guard let index = member.reference.recordIndex, report.railwayRecords.indices.contains(index),
                      report.railwayRecords[index].member == member
                else { return nil }
                indices.append(index)
            }
        }
        return (routes.sorted { $0.routeID < $1.routeID }, indices.sorted())
    }

    private static func routeEvidence(_ input: LineBindingInput) -> [RouteBindingEvidence] {
        let feed = input.gtfs.feed

        var tripRoute: [String: ExactValue] = [:]
        for trip in feed.trips { tripRoute[trip.tripID] = ExactValue(trip.routeID) }
        var served: [ExactValue: Set<ExactValue>] = [:]
        for stopTime in feed.stopTimes {
            guard let route = tripRoute[stopTime.tripID], let stop = ExactValue(stopTime.stopID) else { continue }
            served[route, default: []].insert(stop)
        }
        var codes: [ExactValue: ExactValue] = [:]
        for stop in feed.stops {
            if let id = ExactValue(stop.stopID), let code = stop.stopCode.flatMap(ExactValue.init) { codes[id] = code }
        }

        // Feed-scoped agency resolution. With one agency, a route that names
        // none is that agency's; its `agency_id` may itself be absent.
        let knownAgencies = Set(feed.agencies.compactMap { $0.agencyID.flatMap(ExactValue.init) })
        let soleAgency: RouteAgency = feed.agencies.count == 1
            ? (feed.agencies[0].agencyID.flatMap(ExactValue.init).map(RouteAgency.agency) ?? .soleAgencyWithoutID)
            : .unresolved
        let feedLanguage = feed.feedInfo.first.map(\.language) ?? (feed.agencies.count == 1 ? feed.agencies[0].language : nil)

        var translations: [ExactValue: [(language: String, value: ExactValue)]] = [:]
        for row in feed.translations where row.tableName == "routes" && row.fieldName == "route_long_name" {
            guard let key = row.fieldValue.flatMap(ExactValue.init), let value = ExactValue(row.translation) else { continue }
            translations[key, default: []].append((row.language, value))
        }

        return feed.routes.map { route -> RouteBindingEvidence in
            let routeID = ExactValue(route.routeID)!
            let agency: RouteAgency
            if let named = route.agencyID.flatMap(ExactValue.init) {
                agency = knownAgencies.contains(named) ? .agency(named) : .unresolved
            } else {
                agency = soleAgency
            }
            var operatorID: MintedIdentifier?
            if case .agency(let value) = agency {
                operatorID = input.registry.resolve(ProviderReferenceKey(sourceID: input.gtfs.sourceID, namespace: .gtfsAgencyID, value: value))
            }

            var values: [(language: String, value: ExactValue)] = []
            if let longName = route.longName.flatMap(ExactValue.init) {
                if let feedLanguage { values.append((feedLanguage, longName)) }
                values += translations[longName] ?? []
            }

            let stops = (served[routeID] ?? []).sorted()
            var byPrefix: [String: [SourceReference]] = [:]
            for stop in stops {
                guard let prefix = codes[stop].map(StationGrouping.codePrefix), !prefix.isEmpty else { continue }
                byPrefix[prefix, default: []].append(input.stopReference(stop))
            }

            return RouteBindingEvidence(
                member: input.routeMember(routeID),
                agency: agency,
                operatorID: operatorID,
                japaneseTitles: titles(values, "ja"),
                englishTitles: titles(values, "en"),
                color: route.color.flatMap(ExactValue.init),
                codeGroups: byPrefix.keys.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }
                    .map { LineCodeGroup(prefix: $0, stops: byPrefix[$0]!) },
                stops: stops.map(input.stopReference)
            )
        }
        .sorted { $0.routeID < $1.routeID }
    }

    private static func railwayEvidence(_ input: LineBindingInput) -> [RailwayBindingEvidence] {
        guard let railway = input.railway else { return [] }
        return railway.records.indices.map { index in
            let record = railway.records[index]
            let operatorReference = ExactValue(record.operatorReference)
            let values = record.title.entries.compactMap { entry in ExactValue(entry.text).map { (entry.language, $0) } }
            // `LineBindingInput` refuses a blank station, so every entry is kept.
            let stationOrder = record.stationOrder.enumerated().map { position, entry in
                RailwayStationEvidence(index: entry.index, station: try! SourceReference(
                    inputSHA256: railway.inputSHA256, member: nil, table: nil, recordIndex: index,
                    field: "odpt:stationOrder[\(position)].odpt:station", providerKey: ExactValue(entry.station)!
                ))
            }
            return RailwayBindingEvidence(
                member: input.railwayMember(index),
                operatorReference: operatorReference,
                operatorID: operatorReference.flatMap {
                    input.registry.resolve(ProviderReferenceKey(sourceID: railway.sourceID, namespace: .odptOperator, value: $0))
                },
                lineCode: ExactValue(record.lineCode),
                japaneseTitles: titles(values, "ja"),
                englishTitles: titles(values, "en"),
                color: record.color.flatMap(ExactValue.init),
                stationOrder: stationOrder
            )
        }
    }

    /// For each record, the routes it is a candidate for: its line code is a
    /// stop-code prefix of the route, or a title agrees. Colour alone never
    /// makes a candidate.
    private static func candidateRoutes(_ routes: [RouteBindingEvidence], _ records: [RailwayBindingEvidence]) -> [Set<ExactValue>] {
        records.map { record in
            Set(routes.filter { route in
                [LineBindingCheck.lineCode, .japaneseTitle, .englishTitle].contains { finding($0, route, record) == nil }
            }.map(\.routeID))
        }
    }

    /// Whether a check disagrees between two routes, and how: they share no
    /// stop-code prefix, display title, or colour.
    private static func finding(_ check: LineBindingCheck, _ route: RouteBindingEvidence, _ other: RouteBindingEvidence) -> LineBindingFinding.Kind? {
        func compare(_ lhs: [ExactValue], _ rhs: [ExactValue]) -> LineBindingFinding.Kind? {
            if lhs.isEmpty || rhs.isEmpty { return .missing }
            return Set(lhs).isDisjoint(with: rhs) ? .differs : nil
        }
        switch check {
        case .lineCode:
            if route.codeGroups.isEmpty || other.codeGroups.isEmpty { return .missing }
            return Set(route.codeGroups.map(\.prefix)).isDisjoint(with: other.codeGroups.map(\.prefix)) ? .differs : nil
        case .japaneseTitle:
            return compare(route.japaneseTitles, other.japaneseTitles)
        case .englishTitle:
            return compare(route.englishTitles, other.englishTitles)
        case .color:
            guard let left = route.color.flatMap(colorKey), let right = other.color.flatMap(colorKey) else { return .missing }
            return left == right ? nil : .differs
        case .uniqueCounterpart:
            return nil
        }
    }

    /// Whether a check disagrees between one route and one record, and how.
    /// `uniqueCounterpart` is decided by the caller.
    private static func finding(_ check: LineBindingCheck, _ route: RouteBindingEvidence, _ record: RailwayBindingEvidence) -> LineBindingFinding.Kind? {
        func compare(_ lhs: [ExactValue], _ rhs: [ExactValue]) -> LineBindingFinding.Kind? {
            if lhs.isEmpty || rhs.isEmpty { return .missing }
            return Set(lhs).isDisjoint(with: rhs) ? .differs : nil
        }
        switch check {
        case .lineCode:
            guard let code = record.lineCode, !route.codeGroups.isEmpty else { return .missing }
            return route.codeGroups.contains { $0.prefix.unicodeScalars.elementsEqual(code.text.unicodeScalars) } ? nil : .differs
        case .japaneseTitle:
            return compare(route.japaneseTitles, record.japaneseTitles)
        case .englishTitle:
            return compare(route.englishTitles, record.englishTitles)
        case .color:
            guard let left = route.color.flatMap(colorKey), let right = record.color.flatMap(colorKey) else { return .missing }
            return left == right ? nil : .differs
        case .uniqueCounterpart:
            return nil
        }
    }

    /// The findings and digest for a binding of these routes and records.
    /// Each record is compared with every route, and each route with every
    /// other: a check fails for a member when any comparison disagrees.
    private static func evidence(
        _ input: LineBindingInput,
        _ routes: [RouteBindingEvidence],
        _ records: [RailwayBindingEvidence],
        candidates: [Set<ExactValue>]
    ) -> LineBindingProposal {
        let checks = LineBindingCheck.allCases.filter { $0 != .uniqueCounterpart }
        var findings: [LineBindingFinding] = []

        /// One finding from a member's comparisons, if any fails.
        func combine(_ check: LineBindingCheck, _ member: LineBindingMember, _ results: [(ExactValue, LineBindingFinding.Kind?)]) {
            let failed = results.filter { $0.1 != nil }
            guard !failed.isEmpty else { return }
            let kind: LineBindingFinding.Kind = failed.contains { $0.1 == .differs } ? .differs : .missing
            findings.append(LineBindingFinding(check: check, member: member, kind: kind, routes: failed.map(\.0).sorted()))
        }

        if routes.count > 1 {
            for route in routes {
                let others = routes.filter { $0.routeID != route.routeID }
                for check in checks {
                    combine(check, route.member, others.map { ($0.routeID, finding(check, route, $0)) })
                }
            }
        }

        let boundRoutes = Set(routes.map(\.routeID))
        for (record, routesForRecord) in zip(records, candidates) {
            for check in checks {
                if routes.isEmpty {
                    findings.append(LineBindingFinding(check: check, member: record.member, kind: .missing, routes: []))
                } else {
                    combine(check, record.member, routes.map { ($0.routeID, finding(check, $0, record)) })
                }
            }
            let others = routesForRecord.subtracting(boundRoutes).sorted()
            if !others.isEmpty {
                findings.append(LineBindingFinding(check: .uniqueCounterpart, member: record.member, kind: .differs, routes: others))
            }
        }
        findings.sort { lhs, rhs in
            if lhs.member != rhs.member { return LineBindingMember.precedes(lhs.member, rhs.member) }
            return lhs.check < rhs.check
        }
        return LineBindingProposal(
            members: routes.map(\.member) + records.map(\.member),
            findings: findings,
            evidenceSHA256: digest(input, routes, records, findings)
        )
    }

    /// Title values in one display language. A script-specific reading such
    /// as `ja-Hrkt` counts for none (the grouping rule, shared).
    private static func titles(_ values: [(language: String, value: ExactValue)], _ language: String) -> [ExactValue] {
        Array(Set(values.filter { StationGrouping.displayLanguage($0.language) == language }.map(\.value))).sorted()
    }

    /// Six hexadecimal digits, after one optional `#`, uppercased: GTFS
    /// writes a colour without `#` and ODPT with it. Used only to compare;
    /// the values themselves are kept as written. Anything else has no key.
    private static func colorKey(_ color: ExactValue) -> String? {
        var bytes = Array(color.text.utf8)
        if bytes.first == UInt8(ascii: "#") { bytes.removeFirst() }
        guard bytes.count == 6, bytes.allSatisfy({ ($0 >= 0x30 && $0 <= 0x39) || ($0 | 0x20 >= 0x61 && $0 | 0x20 <= 0x66) }) else {
            return nil
        }
        return String(decoding: bytes, as: UTF8.self).uppercased()
    }

    /// SHA-256 over a length-prefixed encoding of the inputs' identity, every
    /// route's and record's evidence, and the findings.
    private static func digest(
        _ input: LineBindingInput,
        _ routes: [RouteBindingEvidence],
        _ records: [RailwayBindingEvidence],
        _ findings: [LineBindingFinding]
    ) -> String {
        var bytes: [UInt8] = []
        func field(_ text: String) {
            bytes += Array(String(text.utf8.count).utf8) + [0x3A] + Array(text.utf8)
        }
        func optional(_ text: String?) {
            if let text { field("1"); field(text) } else { field("0") }
        }
        func list(_ values: [ExactValue]) {
            field(String(values.count))
            for value in values { field(value.text) }
        }
        func references(_ values: [SourceReference]) {
            field(String(values.count))
            for value in values { field(value.field); field(value.providerKey.text) }
        }
        func member(_ member: LineBindingMember) {
            field(member.sourceID)
            field(member.reference.inputSHA256)
            optional(member.reference.member?.sha256)
            optional(member.reference.recordIndex.map(String.init))
            field(member.reference.providerKey.text)
        }
        field("tsugino.line-binding-evidence.v1")
        field(input.gtfs.sourceID)
        field(input.gtfs.archiveSHA256)
        field(input.gtfs.routesMemberSHA256)
        field(input.gtfs.stopsMemberSHA256)
        optional(input.railway?.sourceID)
        optional(input.railway?.inputSHA256)

        field(String(routes.count))
        for route in routes {
            member(route.member)
            switch route.agency {
            case .agency(let value): field("agency"); field(value.text)
            case .soleAgencyWithoutID: field("sole-without-id")
            case .unresolved: field("unresolved")
            }
            optional(route.operatorID?.rawValue)
            list(route.japaneseTitles)
            list(route.englishTitles)
            optional(route.color?.text)
            field(String(route.codeGroups.count))
            for group in route.codeGroups { field(group.prefix); references(group.stops) }
            references(route.stops)
        }

        field(String(records.count))
        for record in records {
            member(record.member)
            optional(record.operatorReference?.text)
            optional(record.operatorID?.rawValue)
            optional(record.lineCode?.text)
            list(record.japaneseTitles)
            list(record.englishTitles)
            optional(record.color?.text)
            field(String(record.stationOrder.count))
            for entry in record.stationOrder {
                field(String(entry.index)); field(entry.station.field); field(entry.station.providerKey.text)
            }
        }

        field(String(findings.count))
        for finding in findings {
            field(finding.check.rawValue)
            member(finding.member)
            field(finding.kind.rawValue)
            list(finding.routes)
        }
        return hexString(SHA256.hash(data: bytes))
    }

    // MARK: - Applying reviewed bindings

    /// Binds every route and Railway record of the input through the
    /// reviewed records. The evidence is gathered here, from the same input,
    /// so records are never checked against one input and applied to another.
    static func apply(
        _ bindings: ReviewedLineBindingSet,
        to input: LineBindingInput,
        launchInputs: LaunchInputs = .none
    ) throws(LineBindingApplicationError) -> LineBindingOutcome {
        let report = propose(input)
        let candidates = candidateRoutes(report.routes, report.railwayRecords)
        let routesMember = SourceReference.Member(name: "routes.txt", sha256: input.gtfs.routesMemberSHA256)

        var bindingOfRoute: [ExactValue: String] = [:]
        var bindingOfRecord: [Int: String] = [:]
        var lines: [BoundLine] = []

        for record in bindings.records {
            let reviewID = record.reviewID

            // Every member is a route or record of this input.
            for member in record.staticRoutes {
                guard member.sourceID == input.gtfs.sourceID,
                      member.reference.inputSHA256 == input.gtfs.archiveSHA256,
                      member.reference.member == routesMember
                else { throw .recordForOtherInput(reviewID: reviewID) }
            }
            for member in record.railwayRecords {
                guard let railway = input.railway, member.sourceID == railway.sourceID,
                      member.reference.inputSHA256 == railway.inputSHA256
                else { throw .recordForOtherInput(reviewID: reviewID) }
            }
            guard let (routes, indices) = resolve(record.members, report) else { throw .unknownMember(reviewID: reviewID) }
            let records = indices.map { report.railwayRecords[$0] }

            guard input.registry.entity(record.lineID)?.status == .active else { throw .unknownLine(reviewID: reviewID) }

            // The operator boundary: each agency resolves in its feed, every
            // member has an active operator reference, and all name one operator.
            guard routes.allSatisfy({ $0.agency != .unresolved }) else { throw .agencyUnresolved(reviewID: reviewID) }
            let operators = routes.map(\.operatorID) + records.map(\.operatorID)
            guard let operatorID = operators.first ?? nil, operators.allSatisfy({ $0 != nil }) else {
                throw .operatorUnbound(reviewID: reviewID)
            }
            guard operators.allSatisfy({ $0 == operatorID }) else { throw .crossesOperatorBoundary(reviewID: reviewID) }

            let evidence = evidence(input, routes, records, candidates: indices.map { candidates[$0] })
            guard evidence.evidenceSHA256 == record.evidenceSHA256 else { throw .evidenceChanged(reviewID: reviewID) }

            func accepted(_ member: LineBindingMember) throws(LineBindingApplicationError) -> [LineBindingCheck] {
                let failed = Set(evidence.findings.filter { $0.member == member }.map(\.check))
                let acceptance = record.acceptances.first { $0.member == member }
                guard Set(acceptance?.acceptedChecks ?? []) == failed else { throw .acceptanceMismatch(reviewID: reviewID) }
                return failed.sorted()
            }
            var boundRoutes: [BoundLineMember] = []
            for route in routes {
                boundRoutes.append(BoundLineMember(
                    member: route.member, staticScope: .served(route.stops), stationOrder: [], acceptedChecks: try accepted(route.member)
                ))
            }
            var boundMembers: [BoundLineMember] = []
            for railwayRecord in records {
                boundMembers.append(BoundLineMember(
                    member: railwayRecord.member, staticScope: .deferred,
                    stationOrder: railwayRecord.stationOrder, acceptedChecks: try accepted(railwayRecord.member)
                ))
            }

            for route in routes { bindingOfRoute[route.routeID] = reviewID }
            for index in indices { bindingOfRecord[index] = reviewID }
            lines.append(BoundLine(
                lineID: record.lineID,
                operatorID: operatorID,
                reviewID: reviewID,
                routes: boundRoutes,
                railwayRecords: boundMembers
            ))
        }

        // Launch inputs: a record and every route whose stop-code prefix is
        // its line code are in one binding. Not acceptable otherwise. A route
        // or record left unbound is reported as unbound below.
        if launchInputs.identifies(input) {
            for (index, record) in report.railwayRecords.enumerated() {
                guard let recordBinding = bindingOfRecord[index] else { continue }
                for route in report.routes where finding(.lineCode, route, record) == nil {
                    guard let routeBinding = bindingOfRoute[route.routeID] else { continue }
                    guard routeBinding == recordBinding else {
                        throw .launchLineSplit(reviewID: recordBinding)
                    }
                }
            }
        }

        let unboundRoutes = report.routes.count - bindingOfRoute.count
        let unboundRecords = report.railwayRecords.count - bindingOfRecord.count
        guard unboundRoutes == 0, unboundRecords == 0 else {
            throw .unbound(routes: unboundRoutes, railwayRecords: unboundRecords)
        }

        return LineBindingOutcome(report: report, lines: lines.sorted { $0.lineID < $1.lineID })
    }
}
