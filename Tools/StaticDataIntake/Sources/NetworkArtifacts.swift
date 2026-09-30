import CryptoKit
import Foundation

// Station coordinates, line topology, and membership (DEC-070) — in this
// offline tool only (ARCHITECTURE.md §4.1).
//
// Coordinates (§A). Each canonical station's member rows are classified again
// on every run: one row, several rows publishing exactly the same point, or
// several different points. The first two select that exact published point
// automatically, with every row as provenance. Different points need a
// reviewed record naming one member row, its exact point, and a reason; a
// changed or absent chosen row holds the station back. No point is derived,
// averaged, or compared by distance, and none is ever substituted. Previous
// selections are carried forward as history, never overwritten.
//
// Topology (§B). Each line's trips, in `stop_sequence` order and including
// rows a trip passes without stopping, are mapped to canonical stations.
// Consecutive different stations are undirected adjacency candidates: trip
// evidence, not proof of physical adjacency. The possible-shortcut heuristic,
// triangle triggers, and self-pairs are review triggers only; nothing is
// removed automatically. Included adjacencies must form a valid
// `RailwayLineTopology` whose membership equals the stations the line's
// trips serve. Shape checks run on the built graphs of lines the operator
// names; nothing seeds a graph.
//
// Complete `Station` / `RailwayLine` values are not built here: they need
// P2-S7's canonical names (DEC-053).

/// One operator's identified GTFS input.
struct NetworkSide {
    let sourceID: String
    let archiveSHA256: String
    let stopsMemberSHA256: String
    let translationsMemberSHA256: String?
    let feed: GTFSStaticFeed
}

/// Why a run cannot proceed. Each case names a rule, never a value.
enum NetworkError: Error, Equatable {
    case sidesNotTwoSources
    /// A stop row or route has no active registry reference.
    case rowUnmapped
    case routeUnmapped
    /// A reference was last reconciled with another input.
    case registryNotReconciled
    /// A reviewed record breaks its own rules or names something unknown.
    case invalidRecord
    case repeatedRecord
    /// A topology record's decisions are not exactly the line's review cases.
    case topologyDecisionsMismatch
    /// A self-pair on a line whose record does not state its treatment.
    case selfPairTreatmentMissing
    case previousArtifactInvalid
}

// MARK: - Reviewed records (validated)

struct CoordinateRecord: Equatable {
    struct Row: Hashable, Comparable {
        let sourceID: String
        let stopID: ExactValue
        static func < (l: Row, r: Row) -> Bool {
            l.sourceID != r.sourceID ? l.sourceID.utf8.lexicographicallyPrecedes(r.sourceID.utf8) : l.stopID < r.stopID
        }
    }

    let reviewID: String
    let stationID: MintedIdentifier
    /// Every member row the reviewer saw.
    let members: [Row]
    let selected: Row
    /// The input the selected row was reviewed in.
    let selectedArchiveSHA256: String
    /// The exact decoded point, as `String(describing:)` of each `Double`.
    let latitude: String
    let longitude: String
    let reason: String
    let evidenceSHA256: String

    init(
        reviewID: String, stationID: MintedIdentifier, members: [Row], selected: Row, selectedArchiveSHA256: String,
        latitude: String, longitude: String, reason: String, evidenceSHA256: String
    ) throws(NetworkError) {
        guard MappingText.isToken(reviewID), stationID.kind == .station, !members.isEmpty,
              Set(members).count == members.count, members.contains(selected),
              MappingText.isSHA256(selectedArchiveSHA256), MappingText.isSHA256(evidenceSHA256),
              Double(latitude) != nil, Double(longitude) != nil, NetworkText.isReason(reason)
        else { throw .invalidRecord }
        self.reviewID = reviewID
        self.stationID = stationID
        self.members = members.sorted()
        self.selected = selected
        self.selectedArchiveSHA256 = selectedArchiveSHA256
        self.latitude = latitude
        self.longitude = longitude
        self.reason = reason
        self.evidenceSHA256 = evidenceSHA256
    }
}

struct TopologyRecord: Equatable {
    struct Decision: Equatable {
        let pair: StationPair
        let include: Bool
        let reason: String
        /// The intermediates of every alternative run this decision addresses.
        let runs: [[MintedIdentifier]]
    }

    let reviewID: String
    let lineID: MintedIdentifier
    let evidenceSHA256: String
    let decisions: [Decision]
    /// Present when the line has self-pairs: they are never adjacencies, and
    /// the reviewer states that they are ignored as such.
    let ignoresSelfPairs: Bool

    init(reviewID: String, lineID: MintedIdentifier, evidenceSHA256: String, decisions: [Decision], ignoresSelfPairs: Bool) throws(NetworkError) {
        guard MappingText.isToken(reviewID), lineID.kind == .line, MappingText.isSHA256(evidenceSHA256),
              decisions.allSatisfy({ NetworkText.isReason($0.reason) }),
              Set(decisions.map(\.pair)).count == decisions.count
        else { throw .invalidRecord }
        self.reviewID = reviewID
        self.lineID = lineID
        self.evidenceSHA256 = evidenceSHA256
        self.decisions = decisions.sorted { $0.pair < $1.pair }
        self.ignoresSelfPairs = ignoresSelfPairs
    }
}

enum NetworkText {
    /// Printable ASCII, spaces allowed, not blank. Project text.
    static func isReason(_ text: String) -> Bool {
        let bytes = Array(text.utf8)
        return bytes.contains { $0 != 0x20 } && bytes.allSatisfy { (0x20...0x7E).contains($0) }
    }

    static func point(_ value: Double) -> String { String(describing: value) }
}

/// Two distinct stations, unordered: the smaller identifier first.
struct StationPair: Hashable, Comparable {
    let first: MintedIdentifier
    let second: MintedIdentifier

    init?(_ a: MintedIdentifier, _ b: MintedIdentifier) {
        guard a != b else { return nil }
        (first, second) = a < b ? (a, b) : (b, a)
    }

    static func < (l: StationPair, r: StationPair) -> Bool { l.first != r.first ? l.first < r.first : l.second < r.second }
}

// MARK: - Results

/// A member row with its exact published point.
struct CoordinateRow: Hashable {
    let sourceID: String
    let archiveSHA256: String
    let stopsMemberSHA256: String
    let stopID: ExactValue
    let latitude: Double
    let longitude: Double
    let names: [OriginalName]

    var row: CoordinateRecord.Row { .init(sourceID: sourceID, stopID: stopID) }
    var point: [String] { [NetworkText.point(latitude), NetworkText.point(longitude)] }
}

enum CoordinateClass: String {
    case singleRow, identicalPoints, differentPoints
}

enum CoordinateHoldBack: String {
    /// Different points and no reviewed record.
    case reviewRequired
    /// The chosen row is no longer a member.
    case selectedRowAbsent
    /// The chosen row's exact point changed.
    case selectedPointChanged
    /// Other evidence changed since the review (members or their points).
    case reviewStale
    /// The point is not a valid `GeoCoordinate`.
    case invalidPoint
    /// The record was reviewed on another input than the chosen row's.
    case selectedInputChanged
    /// An active station with no row in these inputs.
    case noMemberRows
}

struct StationCoordinateResult: Equatable {
    enum Outcome: Equatable {
        case selected(coordinate: GeoCoordinate, provenance: [CoordinateRow], reviewID: String?)
        case heldBack(CoordinateHoldBack)
    }

    let stationID: MintedIdentifier
    /// Sorted by source, then stop.
    let rows: [CoordinateRow]
    let classification: CoordinateClass
    let evidenceSHA256: String
    let outcome: Outcome
}

enum CandidateClass: String {
    case included, possibleShortcut, triangleTrigger
}

/// One observed alternative run between a candidate's stations.
struct AlternativeRun: Hashable, Comparable {
    /// The stations strictly between, in observed order.
    let intermediates: [MintedIdentifier]
    /// Trips showing this run, sorted.
    let trips: [String]
    /// Whether every supporting trip of the candidate avoids all intermediates.
    let qualifies: Bool

    static func < (l: Self, r: Self) -> Bool { l.intermediates.lexicographicallyPrecedes(r.intermediates) }
}

struct AdjacencyCandidate: Equatable {
    let pair: StationPair
    /// Trips in which the two stations are consecutive, sorted.
    let supportTrips: [String]
    /// Traversals first → second, and second → first.
    let forward: Int
    let backward: Int
    let alternativeRuns: [AlternativeRun]
    let classification: CandidateClass
    /// Whether the candidate is in the topology, and the review that decided
    /// it when one did. `nil` when the line is held back before deciding.
    let included: Bool?
    let reviewID: String?

    var needsReview: Bool { classification != .included }
}

enum LineHoldBack: String {
    /// An active line with no route in these inputs.
    case noRoutes
    case reviewRequired
    case reviewStale
    /// No included adjacency.
    case empty
    case disconnected
    case membershipMismatch
}

struct LineTopologyResult: Equatable {
    let lineID: MintedIdentifier
    /// Bound routes, as source and route.
    let routes: [String]
    let tripCount: Int
    let candidates: [AdjacencyCandidate]
    /// Stations that appeared twice in a row, with their trips.
    let selfPairs: [(station: MintedIdentifier, trips: [String])]
    /// Stations the line's trips serve.
    let servedStations: [MintedIdentifier]
    let evidenceSHA256: String
    let topology: RailwayLineTopology?
    let heldBack: LineHoldBack?
    let reviewID: String?

    static func == (l: Self, r: Self) -> Bool {
        l.lineID == r.lineID && l.routes == r.routes && l.tripCount == r.tripCount && l.candidates == r.candidates
            && l.selfPairs.map(\.station) == r.selfPairs.map(\.station) && l.selfPairs.map(\.trips) == r.selfPairs.map(\.trips)
            && l.servedStations == r.servedStations && l.evidenceSHA256 == r.evidenceSHA256 && l.topology == r.topology
            && l.heldBack == r.heldBack && l.reviewID == r.reviewID
    }
}

enum ShapeKind: String {
    /// One cycle, one degree-3 junction, one tail end.
    case loopPlusTail
    /// Acyclic, one degree-3 junction, three ends.
    case branch
}

struct ShapeCheck: Equatable {
    let lineID: MintedIdentifier
    let expected: ShapeKind
    let passed: Bool
    /// The measured shape, as counts only.
    let cycles: Int
    let degreeCounts: [Int: Int]
}

struct NetworkResult: Equatable {
    let coordinates: [StationCoordinateResult]
    let lines: [LineTopologyResult]
    /// Each station's lines: those whose trips serve its rows.
    let membership: [MintedIdentifier: [MintedIdentifier]]
    let shapes: [ShapeCheck]
    let unusedCoordinateRecords: Int
    let unusedTopologyRecords: Int
}

// MARK: - Building

enum NetworkArtifacts {
    struct Mapped {
        /// Every active station and line entity of the registry.
        let stations: [MintedIdentifier]
        let lines: [MintedIdentifier]
        let rows: [MintedIdentifier: [CoordinateRow]]
        let stationOfRow: [String: [ExactValue: MintedIdentifier]]
        let lineOfRoute: [String: [ExactValue: MintedIdentifier]]
    }

    /// Resolves every stop row and route through the registry. Every one must
    /// hold an active reference last reconciled with this input.
    static func map(_ sides: [NetworkSide], registry: MappingRegistry) throws(NetworkError) -> Mapped {
        guard sides.count == 2, sides[0].sourceID != sides[1].sourceID else { throw .sidesNotTwoSources }
        var rows: [MintedIdentifier: [CoordinateRow]] = [:]
        var stationOfRow: [String: [ExactValue: MintedIdentifier]] = [:]
        var lineOfRoute: [String: [ExactValue: MintedIdentifier]] = [:]
        for side in sides {
            let input = try? GroupingInput(sourceID: side.sourceID, archiveSHA256: side.archiveSHA256, stopsMemberSHA256: side.stopsMemberSHA256, feed: side.feed)
            guard let input else { throw .invalidRecord }
            let names = Dictionary(uniqueKeysWithValues: CrossOperatorStations.memberEvidence(
                StationSideInput(grouping: input, translationsMemberSHA256: side.translationsMemberSHA256, identities: [])
            ).map { ($0.stopID, $0.names) })
            for stop in side.feed.stops {
                guard let value = ExactValue(stop.stopID) else { throw .rowUnmapped }
                let key = ProviderReferenceKey(sourceID: side.sourceID, namespace: .gtfsStopID, value: value)
                guard let reference = registry.reference(for: key), reference.status == .active, reference.canonicalID.kind == .station else {
                    throw .rowUnmapped
                }
                guard reference.provenance.inputSHA256 == side.archiveSHA256 else { throw .registryNotReconciled }
                stationOfRow[side.sourceID, default: [:]][value] = reference.canonicalID
                rows[reference.canonicalID, default: []].append(CoordinateRow(
                    sourceID: side.sourceID, archiveSHA256: side.archiveSHA256, stopsMemberSHA256: side.stopsMemberSHA256,
                    stopID: value, latitude: stop.latitude, longitude: stop.longitude, names: names[value] ?? []
                ))
            }
            for route in side.feed.routes {
                guard let value = ExactValue(route.routeID) else { throw .routeUnmapped }
                let key = ProviderReferenceKey(sourceID: side.sourceID, namespace: .gtfsRouteID, value: value)
                guard let reference = registry.reference(for: key), reference.status == .active, reference.canonicalID.kind == .line else {
                    throw .routeUnmapped
                }
                guard reference.provenance.inputSHA256 == side.archiveSHA256 else { throw .registryNotReconciled }
                lineOfRoute[side.sourceID, default: [:]][value] = reference.canonicalID
            }
        }
        for key in rows.keys { rows[key]!.sort { $0.row < $1.row } }
        let active = registry.entities.filter { $0.status == .active }.map(\.id)
        return Mapped(stations: active.filter { $0.kind == .station }, lines: active.filter { $0.kind == .line },
                      rows: rows, stationOfRow: stationOfRow, lineOfRoute: lineOfRoute)
    }

    // MARK: Coordinates

    static func coordinateEvidence(_ stationID: MintedIdentifier, _ rows: [CoordinateRow]) -> String {
        var bytes: [UInt8] = []
        func field(_ text: String) { bytes += Array(String(text.utf8.count).utf8) + [0x3A] + Array(text.utf8) }
        field("tsugino.coordinate-evidence.v1")
        field(stationID.rawValue)
        field(String(rows.count))
        for row in rows {
            field(row.sourceID); field(row.stopID.text); field(row.point[0]); field(row.point[1])
            field(String(row.names.count))
            for name in row.names { field(name.language.text); field(name.value.text) }
        }
        return hexString(SHA256.hash(data: bytes))
    }

    static func coordinates(_ mapped: Mapped, records: [CoordinateRecord]) throws(NetworkError) -> (results: [StationCoordinateResult], unused: Int) {
        guard Set(records.map(\.reviewID)).count == records.count, Set(records.map(\.stationID)).count == records.count else {
            throw .repeatedRecord
        }
        let byStation = Dictionary(uniqueKeysWithValues: records.map { ($0.stationID, $0) })
        let stations = Set(mapped.stations).union(mapped.rows.keys)
        guard byStation.keys.allSatisfy(stations.contains) else { throw .invalidRecord }
        var used = 0
        let results = stations.sorted().map { stationID -> StationCoordinateResult in
            guard let rows = mapped.rows[stationID] else {
                return StationCoordinateResult(stationID: stationID, rows: [], classification: .singleRow,
                                               evidenceSHA256: coordinateEvidence(stationID, []), outcome: .heldBack(.noMemberRows))
            }
            let points = Set(rows.map(\.point))
            let classification: CoordinateClass = rows.count == 1 ? .singleRow : (points.count == 1 ? .identicalPoints : .differentPoints)
            let evidence = coordinateEvidence(stationID, rows)
            func select(_ row: CoordinateRow, _ provenance: [CoordinateRow], _ reviewID: String?) -> StationCoordinateResult.Outcome {
                guard let coordinate = GeoCoordinate(latitude: row.latitude, longitude: row.longitude) else { return .heldBack(.invalidPoint) }
                return .selected(coordinate: coordinate, provenance: provenance, reviewID: reviewID)
            }
            let outcome: StationCoordinateResult.Outcome
            switch classification {
            case .singleRow, .identicalPoints:
                outcome = select(rows[0], rows, nil)
            case .differentPoints:
                if let record = byStation[stationID] {
                    if let chosen = rows.first(where: { $0.row == record.selected }) {
                        if chosen.point != [record.latitude, record.longitude] {
                            outcome = .heldBack(.selectedPointChanged)
                        } else if record.selectedArchiveSHA256 != chosen.archiveSHA256 {
                            outcome = .heldBack(.selectedInputChanged)
                        } else if record.evidenceSHA256 != evidence || record.members != rows.map(\.row) {
                            outcome = .heldBack(.reviewStale)
                        } else {
                            used += 1
                            outcome = select(chosen, [chosen], record.reviewID)
                        }
                    } else {
                        outcome = .heldBack(.selectedRowAbsent)
                    }
                } else {
                    outcome = .heldBack(.reviewRequired)
                }
            }
            return StationCoordinateResult(stationID: stationID, rows: rows, classification: classification, evidenceSHA256: evidence, outcome: outcome)
        }
        return (results, records.count - used)
    }

    // MARK: Topology

    static func lineEvidence(
        _ lineID: MintedIdentifier, routes: [String], candidates: [AdjacencyCandidate],
        selfPairs: [(station: MintedIdentifier, trips: [String])], served: [MintedIdentifier]
    ) -> String {
        var bytes: [UInt8] = []
        func field(_ text: String) { bytes += Array(String(text.utf8.count).utf8) + [0x3A] + Array(text.utf8) }
        field("tsugino.topology-evidence.v1")
        field(lineID.rawValue)
        field(String(routes.count)); routes.forEach(field)
        field(String(served.count)); served.forEach { field($0.rawValue) }
        field(String(candidates.count))
        for candidate in candidates {
            field(candidate.pair.first.rawValue); field(candidate.pair.second.rawValue)
            field(candidate.classification.rawValue)
            field(String(candidate.forward)); field(String(candidate.backward))
            field(String(candidate.supportTrips.count)); candidate.supportTrips.forEach(field)
            field(String(candidate.alternativeRuns.count))
            for run in candidate.alternativeRuns {
                field(run.qualifies ? "qualifies" : "visited")
                field(String(run.intermediates.count)); run.intermediates.forEach { field($0.rawValue) }
                field(String(run.trips.count)); run.trips.forEach(field)
            }
        }
        field(String(selfPairs.count))
        for pair in selfPairs { field(pair.station.rawValue); field(String(pair.trips.count)); pair.trips.forEach(field) }
        return hexString(SHA256.hash(data: bytes))
    }

    /// The observed evidence for every line: candidates, runs, flags, and self-pairs.
    static func topology(_ sides: [NetworkSide], _ mapped: Mapped, records: [TopologyRecord]) throws(NetworkError) -> (results: [LineTopologyResult], unused: Int) {
        guard Set(records.map(\.reviewID)).count == records.count, Set(records.map(\.lineID)).count == records.count else { throw .repeatedRecord }
        let byLine = Dictionary(uniqueKeysWithValues: records.map { ($0.lineID, $0) })
        let lines = Set(mapped.lines).union(mapped.lineOfRoute.values.flatMap(\.values))
        guard byLine.keys.allSatisfy(lines.contains) else { throw .invalidRecord }

        // Trip sequences per line, in stop_sequence order, every row kept.
        struct Sequence { let trip: String; let stations: [MintedIdentifier] }
        var sequences: [MintedIdentifier: [Sequence]] = [:]
        var routesOfLine: [MintedIdentifier: [String]] = [:]
        for side in sides {
            for (route, line) in mapped.lineOfRoute[side.sourceID] ?? [:] { routesOfLine[line, default: []].append("\(side.sourceID) \(route.text)") }
            var tripLine: [String: MintedIdentifier] = [:]
            for trip in side.feed.trips {
                if let route = ExactValue(trip.routeID), let line = mapped.lineOfRoute[side.sourceID]?[route] { tripLine[trip.tripID] = line }
            }
            var times: [String: [GTFSStopTime]] = [:]
            for stopTime in side.feed.stopTimes where tripLine[stopTime.tripID] != nil { times[stopTime.tripID, default: []].append(stopTime) }
            for (trip, rows) in times {
                var stations: [MintedIdentifier] = []
                for row in rows.sorted(by: { $0.stopSequence < $1.stopSequence }) {
                    guard let value = ExactValue(row.stopID), let station = mapped.stationOfRow[side.sourceID]?[value] else { throw .rowUnmapped }
                    stations.append(station)
                }
                sequences[tripLine[trip]!, default: []].append(Sequence(trip: "\(side.sourceID) \(trip)", stations: stations))
            }
        }

        var used = 0
        let results = try lines.sorted().map { lineID throws(NetworkError) -> LineTopologyResult in
            let trips = (sequences[lineID] ?? []).sorted { $0.trip.utf8.lexicographicallyPrecedes($1.trip.utf8) }
            let hasRoutes = routesOfLine[lineID]?.isEmpty == false
            var support: [StationPair: Set<String>] = [:]
            var direction: [StationPair: (Int, Int)] = [:]
            var selfPairs: [MintedIdentifier: Set<String>] = [:]
            var served = Set<MintedIdentifier>()
            for sequence in trips {
                served.formUnion(sequence.stations)
                for (a, b) in zip(sequence.stations, sequence.stations.dropFirst()) {
                    guard let pair = StationPair(a, b) else { selfPairs[a, default: []].insert(sequence.trip); continue }
                    support[pair, default: []].insert(sequence.trip)
                    var counts = direction[pair] ?? (0, 0)
                    if a == pair.first { counts.0 += 1 } else { counts.1 += 1 }
                    direction[pair] = counts
                }
            }
            let stationsOfTrip = Dictionary(uniqueKeysWithValues: trips.map { ($0.trip, Set($0.stations)) })

            // Alternative runs: consecutive occurrences of a and b in one trip,
            // at least two apart, with neither between them.
            var runs: [StationPair: [[MintedIdentifier]: Set<String>]] = [:]
            for sequence in trips {
                var positions: [MintedIdentifier: [Int]] = [:]
                for (index, station) in sequence.stations.enumerated() { positions[station, default: []].append(index) }
                for pair in support.keys {
                    guard let pa = positions[pair.first], let pb = positions[pair.second] else { continue }
                    let merged = (pa.map { ($0, true) } + pb.map { ($0, false) }).sorted { $0.0 < $1.0 }
                    for (x, y) in zip(merged, merged.dropFirst()) where x.1 != y.1 && y.0 - x.0 >= 2 {
                        runs[pair, default: [:]][Array(sequence.stations[(x.0 + 1)..<y.0]), default: []].insert(sequence.trip)
                    }
                }
            }

            // Possible-shortcut heuristic: some run whose intermediates no
            // supporting trip visits.
            var candidates: [StationPair: (runs: [AlternativeRun], shortcut: Bool)] = [:]
            for pair in support.keys {
                let supporting = support[pair]!
                let observed = (runs[pair] ?? [:]).map { intermediates, tripIDs -> AlternativeRun in
                    let set = Set(intermediates)
                    let qualifies = supporting.allSatisfy { stationsOfTrip[$0]!.isDisjoint(with: set) }
                    return AlternativeRun(intermediates: intermediates, trips: tripIDs.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }, qualifies: qualifies)
                }.sorted()
                candidates[pair] = (observed, observed.contains(where: \.qualifies))
            }
            // Triangle triggers among candidates that are not possible shortcuts.
            var neighbours: [MintedIdentifier: Set<MintedIdentifier>] = [:]
            for (pair, value) in candidates where !value.shortcut {
                neighbours[pair.first, default: []].insert(pair.second)
                neighbours[pair.second, default: []].insert(pair.first)
            }
            var triangle = Set<StationPair>()
            for (pair, value) in candidates where !value.shortcut {
                for c in neighbours[pair.first, default: []].intersection(neighbours[pair.second, default: []]) {
                    triangle.insert(pair)
                    triangle.insert(StationPair(pair.first, c)!)
                    triangle.insert(StationPair(pair.second, c)!)
                }
            }
            func classify(_ pair: StationPair) -> CandidateClass {
                candidates[pair]!.shortcut ? .possibleShortcut : (triangle.contains(pair) ? .triangleTrigger : .included)
            }
            let routes = (routesOfLine[lineID] ?? []).sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }
            let selfPairList = selfPairs.keys.sorted().map { (station: $0, trips: selfPairs[$0]!.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }) }
            let servedList = served.sorted()
            let pairs = support.keys.sorted()
            func candidateList(included: (StationPair) -> Bool?, reviewID: (StationPair) -> String?) -> [AdjacencyCandidate] {
                pairs.map { pair in
                    AdjacencyCandidate(
                        pair: pair, supportTrips: support[pair]!.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) },
                        forward: direction[pair]!.0, backward: direction[pair]!.1, alternativeRuns: candidates[pair]!.runs,
                        classification: classify(pair), included: included(pair), reviewID: reviewID(pair)
                    )
                }
            }
            let evidenceList = candidateList(included: { _ in nil }, reviewID: { _ in nil })
            let evidence = lineEvidence(lineID, routes: routes, candidates: evidenceList, selfPairs: selfPairList, served: servedList)
            let review = Set(pairs.filter { classify($0) != .included })
            func result(_ list: [AdjacencyCandidate], _ topology: RailwayLineTopology?, _ held: LineHoldBack?, _ reviewID: String?) -> LineTopologyResult {
                LineTopologyResult(
                    lineID: lineID, routes: routes, tripCount: trips.count, candidates: list, selfPairs: selfPairList,
                    servedStations: servedList, evidenceSHA256: evidence, topology: topology, heldBack: held, reviewID: reviewID
                )
            }

            guard hasRoutes else { return result(evidenceList, nil, .noRoutes, nil) }
            var decision: [StationPair: (Bool, String)] = [:]
            let record = byLine[lineID]
            if !review.isEmpty || !selfPairList.isEmpty {
                guard let record else { return result(evidenceList, nil, .reviewRequired, nil) }
                guard record.evidenceSHA256 == evidence else { return result(evidenceList, nil, .reviewStale, nil) }
                guard Set(record.decisions.map(\.pair)) == review else { throw .topologyDecisionsMismatch }
                // Each decision addresses every alternative run of its candidate.
                for item in record.decisions {
                    guard Set(item.runs) == Set(candidates[item.pair]!.runs.map(\.intermediates)), Set(item.runs).count == item.runs.count else {
                        throw .topologyDecisionsMismatch
                    }
                }
                guard selfPairList.isEmpty || record.ignoresSelfPairs else { throw .selfPairTreatmentMissing }
                used += 1
                for item in record.decisions { decision[item.pair] = (item.include, record.reviewID) }
            }
            let list = candidateList(included: { decision[$0]?.0 ?? true }, reviewID: { decision[$0]?.1 })
            let included = Set(list.filter { $0.included == true }.map { StationAdjacency(StationID($0.pair.first.rawValue)!, StationID($0.pair.second.rawValue)!)! })
            let reviewID = decision.isEmpty && selfPairList.isEmpty ? nil : record?.reviewID
            guard !included.isEmpty else { return result(list, nil, .empty, reviewID) }
            guard let topology = RailwayLineTopology(adjacencies: included) else { return result(list, nil, .disconnected, reviewID) }
            guard topology.stationIDs == Set(servedList.map { StationID($0.rawValue)! }) else { return result(list, nil, .membershipMismatch, reviewID) }
            return result(list, topology, nil, reviewID)
        }
        return (results, records.count - used)
    }

    // MARK: Shapes

    static func shape(_ line: LineTopologyResult, expected: ShapeKind) -> ShapeCheck {
        guard let topology = line.topology else {
            return ShapeCheck(lineID: line.lineID, expected: expected, passed: false, cycles: 0, degreeCounts: [:])
        }
        var degree: [StationID: Int] = [:]
        for adjacency in topology.adjacencies { for station in adjacency.stationIDs { degree[station, default: 0] += 1 } }
        let cycles = topology.adjacencies.count - degree.count + 1
        let counts = Dictionary(grouping: degree.values, by: { $0 }).mapValues(\.count)
        let others = counts.filter { $0.key != 1 && $0.key != 3 }
        let passed: Bool
        switch expected {
        case .loopPlusTail: passed = cycles == 1 && counts[3] == 1 && counts[1] == 1 && others.keys.allSatisfy { $0 == 2 }
        case .branch: passed = cycles == 0 && counts[3] == 1 && counts[1] == 3 && others.keys.allSatisfy { $0 == 2 }
        }
        return ShapeCheck(lineID: line.lineID, expected: expected, passed: passed, cycles: cycles, degreeCounts: counts)
    }

    // MARK: Everything

    static func build(
        _ sides: [NetworkSide], registry: MappingRegistry, coordinateRecords: [CoordinateRecord], topologyRecords: [TopologyRecord],
        shapes: [(MintedIdentifier, ShapeKind)]
    ) throws(NetworkError) -> NetworkResult {
        let sorted = sides.sorted { $0.sourceID.utf8.lexicographicallyPrecedes($1.sourceID.utf8) }
        let mapped = try map(sorted, registry: registry)
        let coordinates = try coordinates(mapped, records: coordinateRecords)
        let lines = try topology(sorted, mapped, records: topologyRecords)
        var membership: [MintedIdentifier: Set<MintedIdentifier>] = [:]
        for line in lines.results { for station in line.servedStations { membership[station, default: []].insert(line.lineID) } }
        let byLine = Dictionary(uniqueKeysWithValues: lines.results.map { ($0.lineID, $0) })
        guard shapes.allSatisfy({ byLine[$0.0] != nil }), Set(shapes.map(\.0)).count == shapes.count else { throw .invalidRecord }
        return NetworkResult(
            coordinates: coordinates.results, lines: lines.results,
            membership: membership.mapValues { $0.sorted() },
            shapes: shapes.map { shape(byLine[$0.0]!, expected: $0.1) }.sorted { $0.lineID < $1.lineID },
            unusedCoordinateRecords: coordinates.unused, unusedTopologyRecords: lines.unused
        )
    }
}
