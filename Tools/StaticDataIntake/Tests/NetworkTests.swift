import Foundation

// DEC-070 cases for coordinates, topology, membership, the network commands,
// and repeat runs. Every feed, registry, record, identifier, and digest is
// invented: stops `syn-…`, names "Synthetic …", provisional-shaped
// identifiers `stn_…` / `lin_…` counted from 1. Nothing here is a production
// identifier, a real mapping, or a real decision.

enum SyntheticNetwork {
    static let sources = ["SYN-01/synthetic-a", "SYN-02/synthetic-b"]
    static let archives = [String(repeating: "c", count: 64), String(repeating: "e", count: 64)]
    static let stopsMember = String(repeating: "d", count: 64)

    static func id(_ kind: String, _ n: Int) -> MintedIdentifier {
        let alphabet = Array("0123456789abcdefghjkmnpqrstvwxyz")
        var digits: [Character] = []
        var value = n
        repeat { digits.insert(alphabet[value % 32], at: 0); value /= 32 } while value > 0
        return MintedIdentifier(kind + "_" + String(repeating: "0", count: 16 - digits.count) + String(digits))!
    }
    static func stn(_ n: Int) -> MintedIdentifier { id("stn", n) }
    static func lin(_ n: Int) -> MintedIdentifier { id("lin", n) }

    struct Row { let side: Int; let stop: String; var latitude: Double; var longitude: Double }
    struct Station { let id: MintedIdentifier; var rows: [Row] }
    struct Trip { let stops: [String]; var passing: Set<String> = [] }
    struct Line { let id: MintedIdentifier; let side: Int; let route: String; var trips: [Trip] }

    struct Model {
        var stations: [Station]
        var lines: [Line]
    }

    /// Station `n` with one row on side A, at a point derived from `n`.
    static func single(_ n: Int, _ stop: String, side: Int = 0) -> Station {
        Station(id: stn(n), rows: [Row(side: side, stop: stop, latitude: 35 + Double(n) / 1000, longitude: 139 + Double(n) / 1000)])
    }

    static func base() -> Model {
        var stations: [Station] = []
        let singles: [(Int, String)] = [
            (1, "syn-j"), (2, "syn-t1"), (3, "syn-x1"), (4, "syn-x2"), (5, "syn-x3"),
            (6, "syn-m1"), (7, "syn-m2"), (8, "syn-m3"), (9, "syn-m4"), (10, "syn-b1"), (11, "syn-b2"),
            (12, "syn-pj"), (13, "syn-p1"), (14, "syn-p2"), (15, "syn-p3"),
            (16, "syn-e1"), (17, "syn-e2"), (18, "syn-e3"), (19, "syn-e4"), (20, "syn-e5"),
            (21, "syn-v1"), (22, "syn-v2"), (23, "syn-v3"), (24, "syn-vx"),
            (25, "syn-g1"), (26, "syn-g2"), (27, "syn-g3"), (29, "syn-sp3"),
        ]
        stations += singles.map { single($0.0, $0.1) }
        // Two rows of one operator with the same point: a self-pair station.
        stations.append(Station(id: stn(28), rows: [Row(side: 0, stop: "syn-sp1", latitude: 35.5, longitude: 139.5), Row(side: 0, stop: "syn-sp2", latitude: 35.5, longitude: 139.5)]))
        // Cross-operator stations: different points, and identical points.
        stations.append(Station(id: stn(34), rows: [Row(side: 0, stop: "syn-a-diff", latitude: 35.1, longitude: 139.1), Row(side: 1, stop: "syn-b-diff", latitude: 35.2, longitude: 139.2)]))
        stations.append(Station(id: stn(35), rows: [Row(side: 0, stop: "syn-a-same", latitude: 35.3, longitude: 139.3), Row(side: 1, stop: "syn-b-same", latitude: 35.3, longitude: 139.3)]))
        let lines: [Line] = [
            // Loop plus tail: t1 – j, loop j x1 x2 x3 j, full-loop trips both ways.
            Line(id: lin(1), side: 0, route: "syn-route-loop", trips: [
                Trip(stops: ["syn-t1", "syn-j", "syn-x1", "syn-x2", "syn-x3", "syn-j"]),
                Trip(stops: ["syn-j", "syn-x3", "syn-x2", "syn-x1", "syn-j", "syn-t1"]),
            ]),
            // Branch: m1 m2 m3 m4, and b2 b1 joining at m2, running through.
            Line(id: lin(2), side: 0, route: "syn-route-branch", trips: [
                Trip(stops: ["syn-m1", "syn-m2", "syn-m3", "syn-m4"]),
                Trip(stops: ["syn-b2", "syn-b1", "syn-m2", "syn-m3", "syn-m4"]),
            ]),
            // A loop closed only by a partial trip.
            Line(id: lin(3), side: 0, route: "syn-route-partial", trips: [
                Trip(stops: ["syn-pj", "syn-p1", "syn-p2", "syn-p3"]),
                Trip(stops: ["syn-p3", "syn-pj"]),
            ]),
            // Express with pass-through rows, and one that omits a row.
            Line(id: lin(4), side: 0, route: "syn-route-express", trips: [
                Trip(stops: ["syn-e1", "syn-e2", "syn-e3", "syn-e4", "syn-e5"]),
                Trip(stops: ["syn-e1", "syn-e2", "syn-e3", "syn-e4", "syn-e5"], passing: ["syn-e2", "syn-e4"]),
                Trip(stops: ["syn-e1", "syn-e3", "syn-e4", "syn-e5"]),
            ]),
            // Two alternative runs for v1–v3: via v2 (visited by a supporting trip), via vx (not).
            Line(id: lin(5), side: 0, route: "syn-route-runs", trips: [
                Trip(stops: ["syn-v1", "syn-v2", "syn-v3"]),
                Trip(stops: ["syn-v1", "syn-vx", "syn-v3"]),
                Trip(stops: ["syn-v1", "syn-v3"]),
                Trip(stops: ["syn-v1", "syn-v3", "syn-v2"]),
            ]),
            // Contradictory order: a triangle.
            Line(id: lin(6), side: 0, route: "syn-route-triangle", trips: [
                Trip(stops: ["syn-g1", "syn-g2", "syn-g3"]),
                Trip(stops: ["syn-g1", "syn-g3", "syn-g2"]),
            ]),
            // A self-pair: two consecutive rows of one canonical station.
            Line(id: lin(7), side: 0, route: "syn-route-self", trips: [Trip(stops: ["syn-sp1", "syn-sp2", "syn-sp3"])]),
            // Operator B's line.
            Line(id: lin(9), side: 1, route: "syn-route-b", trips: [Trip(stops: ["syn-b-diff", "syn-b-same"])]),
        ]
        return Model(stations: stations, lines: lines)
    }

    static func feeds(_ model: Model, reversed: Bool = false) -> [GTFSStaticFeed] {
        (0..<2).map { side in
            let rows = model.stations.flatMap { $0.rows.filter { $0.side == side } }
            let lines = model.lines.filter { $0.side == side }
            var trips: [GTFSTrip] = []
            var times: [GTFSStopTime] = []
            for line in lines {
                for (index, trip) in line.trips.enumerated() {
                    let tripID = "\(line.route)-\(index)"
                    trips.append(GTFSTrip(tripID: tripID, routeID: line.route, serviceID: "syn-weekday", headsign: nil, shortName: nil, directionID: nil, blockID: nil))
                    for (position, stop) in trip.stops.enumerated() {
                        let passing = trip.passing.contains(stop)
                        times.append(GTFSStopTime(tripID: tripID, stopID: stop, stopSequence: position + 1, arrivalTime: nil, departureTime: nil, stopHeadsign: nil,
                                                  pickupType: passing ? GTFSPickupDropOffType.none : nil, dropOffType: passing ? GTFSPickupDropOffType.none : nil, timepoint: passing ? GTFSTimepoint.approximate : nil))
                    }
                }
            }
            func order<T>(_ items: [T]) -> [T] { reversed ? items.reversed() : items }
            return GTFSStaticFeed(
                agencies: [GTFSAgency(agencyID: "syn-agency-\(side)", name: "Synthetic Transit", url: "https://example.invalid", timezone: "Asia/Tokyo", language: nil)],
                stops: order(rows.map { GTFSStop(stopID: $0.stop, stopCode: nil, name: "Synthetic \($0.stop)", latitude: $0.latitude, longitude: $0.longitude, locationType: nil, parentStation: nil, platformCode: nil) }),
                routes: order(lines.map { GTFSRoute(routeID: $0.route, agencyID: "syn-agency-\(side)", shortName: nil, longName: "Synthetic Line", routeType: 1, color: nil, textColor: nil) }),
                trips: order(trips), stopTimes: order(times), calendars: [], calendarDates: [],
                feedInfo: [GTFSFeedInfo(publisherName: "Synthetic Publisher", publisherURL: "https://example.invalid", language: "ja", startDate: nil, endDate: nil, version: nil)],
                translations: []
            )
        }
    }

    static func sides(_ model: Model, reversed: Bool = false, archives: [String] = archives) -> [NetworkSide] {
        feeds(model, reversed: reversed).enumerated().map { side, feed in
            NetworkSide(sourceID: sources[side], archiveSHA256: archives[side], stopsMemberSHA256: stopsMember, translationsMemberSHA256: nil, feed: feed)
        }
    }

    /// The P2-S5-shaped registry: every row on its station, every route on its line.
    static func registry(_ model: Model, archives: [String] = archives, routesMember: [String]? = nil) -> MappingRegistry {
        var references: [ProviderReference] = []
        func reference(_ id: MintedIdentifier, _ side: Int, _ namespace: ProviderNamespace, _ value: String, member: String, memberSHA: String, table: String, field: String) -> ProviderReference {
            let provenance = try! SourceReference(inputSHA256: archives[side], member: .init(name: member, sha256: memberSHA), table: table, recordIndex: nil, field: field, providerKey: ExactValue(value)!)
            return try! ProviderReference(canonicalID: id, sourceID: sources[side], namespace: namespace, value: ExactValue(value)!, status: .active,
                                          firstSeenInputSHA256: archives[side], provenance: provenance, originalNames: [], attachedBy: "SYN-REVIEW-R")
        }
        for station in model.stations {
            for row in station.rows {
                references.append(reference(station.id, row.side, .gtfsStopID, row.stop, member: "stops.txt", memberSHA: routesMember?[row.side] ?? stopsMember, table: "stops", field: "stop_id"))
            }
        }
        for line in model.lines {
            references.append(reference(line.id, line.side, .gtfsRouteID, line.route, member: "routes.txt", memberSHA: routesMember?[line.side] ?? stopsMember, table: "routes", field: "route_id"))
        }
        let entities = (model.stations.map(\.id) + model.lines.map(\.id)).map { CanonicalEntity(id: $0, status: .active) }
        return try! MappingRegistry(revision: 6, entities: entities, references: references)
    }

    static func build(_ model: Model, coordinates: [CoordinateRecord] = [], topology: [TopologyRecord] = [],
                      shapes: [(MintedIdentifier, ShapeKind)] = [], reversed: Bool = false) throws -> NetworkResult {
        try NetworkArtifacts.build(sides(model, reversed: reversed), registry: registry(model), coordinateRecords: coordinates, topologyRecords: topology, shapes: shapes)
    }

    static func line(_ result: NetworkResult, _ n: Int) -> LineTopologyResult { result.lines.first { $0.lineID == lin(n) }! }
    static func station(_ result: NetworkResult, _ n: Int) -> StationCoordinateResult { result.coordinates.first { $0.stationID == stn(n) }! }
    static func pair(_ a: Int, _ b: Int) -> StationPair { StationPair(stn(a), stn(b))! }
    static func candidate(_ line: LineTopologyResult, _ a: Int, _ b: Int) -> AdjacencyCandidate? { line.candidates.first { $0.pair == pair(a, b) } }

    static func row(_ side: Int, _ stop: String) -> CoordinateRecord.Row { .init(sourceID: sources[side], stopID: ExactValue(stop)!) }

    /// A reviewed choice of the A row of station 34, as the reviewer saw it.
    static func diffRecord(_ result: NetworkResult, latitude: String = "35.1", selected: CoordinateRecord.Row? = nil, reviewID: String = "SYN-REVIEW-C1") throws -> CoordinateRecord {
        let station = SyntheticNetwork.station(result, 34)
        return try CoordinateRecord(
            reviewID: reviewID, stationID: stn(34), members: [row(0, "syn-a-diff"), row(1, "syn-b-diff")], selected: selected ?? row(0, "syn-a-diff"),
            selectedArchiveSHA256: archives[0], latitude: latitude, longitude: "139.1", reason: "Synthetic choice", evidenceSHA256: station.evidenceSHA256
        )
    }

    /// A topology record deciding every review case of a line.
    static func decide(_ line: LineTopologyResult, include: (StationPair) -> Bool = { _ in true }, selfPairs: Bool = false, reviewID: String? = nil) throws -> TopologyRecord {
        try TopologyRecord(
            reviewID: reviewID ?? "SYN-REVIEW-T\(line.lineID.body.suffix(2))", lineID: line.lineID, evidenceSHA256: line.evidenceSHA256,
            decisions: line.candidates.filter(\.needsReview).map { .init(pair: $0.pair, include: include($0.pair), reason: "Synthetic decision", runs: $0.alternativeRuns.map(\.intermediates)) },
            ignoresSelfPairs: selfPairs
        )
    }

    /// Records deciding every base review case: include everything, ignore self-pairs.
    static func allDecided(_ model: Model) throws -> [TopologyRecord] {
        let first = try build(model)
        return try first.lines.filter { $0.heldBack == .reviewRequired }.map { try decide($0, selfPairs: !$0.selfPairs.isEmpty) }
    }
}

extension SyntheticNetwork {
    /// The model's two feeds as synthetic archives.
    static func tables(_ model: Model, side: Int) -> [String: String] {
        let rows = model.stations.flatMap { $0.rows.filter { $0.side == side } }
        let lines = model.lines.filter { $0.side == side }
        var stopTimes = "trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type,timepoint\n"
        var trips = "route_id,service_id,trip_id\n"
        for line in lines {
            for (index, trip) in line.trips.enumerated() {
                let tripID = "\(line.route)-\(index)"
                trips += "\(line.route),syn-weekday,\(tripID)\n"
                for (position, stop) in trip.stops.enumerated() {
                    let time = String(format: "05:%02d:00", position)
                    let passing = trip.passing.contains(stop)
                    stopTimes += "\(tripID),\(time),\(time),\(stop),\(position + 1),\(passing ? "1" : "0"),\(passing ? "1" : "0"),1\n"
                }
            }
        }
        return [
            "agency.txt": "agency_id,agency_name,agency_url,agency_timezone,agency_lang\nsyn-agency-\(side),Synthetic Transit,https://example.invalid,Asia/Tokyo,ja\n",
            "stops.txt": "stop_id,stop_name,stop_lat,stop_lon\n" + rows.map { "\($0.stop),Synthetic \($0.stop),\($0.latitude),\($0.longitude)\n" }.joined(),
            "routes.txt": "route_id,agency_id,route_long_name,route_type\n" + lines.map { "\($0.route),syn-agency-\(side),Synthetic Line,1\n" }.joined(),
            "trips.txt": trips,
            "stop_times.txt": stopTimes,
            "calendar.txt": "service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date\nsyn-weekday,1,1,1,1,1,0,0,20990101,20991231\n",
            "feed_info.txt": "feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version\nSynthetic Publisher,https://example.invalid,ja,20990101,20991231,syn-1\n",
        ]
    }

    struct Files { let archives: [URL]; let registry: URL; let sides: [NetworkSide] }

    static func files(_ model: Model, _ workspace: Workspace) async throws -> Files {
        var urls: [URL] = []
        var sides: [NetworkSide] = []
        for side in 0..<2 {
            let tables = tables(model, side: side)
            let url = try workspace.write(ZipWriter.archive(tables.keys.sorted().map { ZipEntry($0, Data(tables[$0]!.utf8)) }), named: "network-\(side).zip")
            let read = try await ArchiveReading.read(requestedPath: url.path, resolvedPath: resolvedPath(url.path)!, checked: FileIdentity(path: url.path)!,
                                                     repositoryRoot: testRepositoryRoot, limits: .standard)
            urls.append(url)
            sides.append(NetworkSide(sourceID: sources[side], archiveSHA256: read.sha256, stopsMemberSHA256: read.memberSHA256("stops.txt")!,
                                     translationsMemberSHA256: nil, feed: read.feed))
        }
        let registryURL = workspace.archives.appendingPathComponent("network-registry.json")
        try SyntheticNetwork.registry(model, archives: sides.map(\.archiveSHA256), routesMember: sides.map(\.stopsMemberSHA256)).encoded().write(to: registryURL)
        return Files(archives: urls, registry: registryURL, sides: sides)
    }

    static func request(_ files: Files, records: URL? = nil, previous: URL? = nil, shapes: [(MintedIdentifier, ShapeKind)] = [], output: URL) -> NetworkRequest {
        NetworkRequest(sides: (0..<2).map { .init(gtfsSourceID: sources[$0], archivePath: files.archives[$0].path) }, registryPath: files.registry.path,
                       recordsPath: records?.path, previousCoordinatesPath: previous?.path, shapes: shapes, outputPath: output.path)
    }

    /// The reviewer's records for every review case of the files, as JSON.
    static func writeRecords(_ files: Files, _ model: Model, _ workspace: Workspace) throws -> URL {
        let registry = try MappingRegistry.decoded(from: try Data(contentsOf: files.registry))
        let first = try NetworkArtifacts.build(files.sides, registry: registry, coordinateRecords: [], topologyRecords: [], shapes: [])
        let diff = station(first, 34)
        let coordinates: [[String: Any]] = [[
            "reviewID": "SYN-REVIEW-C1", "stationID": stn(34).rawValue,
            "members": diff.rows.map { ["gtfsSourceID": $0.sourceID, "stopID": $0.stopID.text] },
            "selected": ["gtfsSourceID": sources[0], "gtfsArchiveSHA256": files.sides[0].archiveSHA256, "stopID": "syn-a-diff"],
            "latitude": "35.1", "longitude": "139.1", "reason": "Synthetic choice", "evidenceSHA256": diff.evidenceSHA256,
        ]]
        let topology: [[String: Any]] = first.lines.filter { $0.heldBack == .reviewRequired }.map { line in
            ["reviewID": "SYN-REVIEW-T\(line.lineID.body.suffix(2))", "lineID": line.lineID.rawValue, "evidenceSHA256": line.evidenceSHA256,
             "ignoresSelfPairs": !line.selfPairs.isEmpty,
             "decisions": line.candidates.filter(\.needsReview).map { ["stations": [$0.pair.first.rawValue, $0.pair.second.rawValue], "decision": "include", "reason": "Synthetic decision",
                                                                         "runs": $0.alternativeRuns.map { $0.intermediates.map(\.rawValue) }] }]
        }
        let url = workspace.archives.appendingPathComponent("network-records.json")
        try JSONSerialization.data(withJSONObject: ["schemaVersion": 1, "coordinates": coordinates, "topology": topology], options: [.sortedKeys]).write(to: url)
        return url
    }
}

let networkTests: [TestCase] = [
    ("coordinates: one row and identical points select the exact published point with all provenance and no review", { _ in
        let result = try SyntheticNetwork.build(SyntheticNetwork.base())
        let single = SyntheticNetwork.station(result, 1)
        guard case .selected(let coordinate, let provenance, let review) = single.outcome else { throw TestFailure(message: "single not selected") }
        try check(single.classification == .singleRow && review == nil && provenance.count == 1, "one row")
        try check(coordinate.latitude == 35.001 && coordinate.longitude == 139.001, "exact point")
        let same = SyntheticNetwork.station(result, 35)
        guard case .selected(_, let rows, let sameReview) = same.outcome else { throw TestFailure(message: "identical not selected") }
        try check(same.classification == .identicalPoints && sameReview == nil && Set(rows.map(\.sourceID)).count == 2, "identical points keep both operators' rows")
        let diff = SyntheticNetwork.station(result, 34)
        try check(diff.classification == .differentPoints && diff.outcome == .heldBack(.reviewRequired), "different points need review")
    }),
    ("coordinates: a reviewed choice selects one exact member point; a changed, absent, or stale choice holds the station back", { _ in
        let model = SyntheticNetwork.base()
        let first = try SyntheticNetwork.build(model)
        let chosen = try SyntheticNetwork.build(model, coordinates: [try SyntheticNetwork.diffRecord(first)])
        guard case .selected(let coordinate, let provenance, let review) = SyntheticNetwork.station(chosen, 34).outcome else { throw TestFailure(message: "not selected") }
        try check(coordinate.latitude == 35.1 && provenance.map(\.stopID.text) == ["syn-a-diff"] && review == "SYN-REVIEW-C1", "the chosen row's exact point")
        // The recorded point no longer matches the chosen row.
        let changed = try SyntheticNetwork.build(model, coordinates: [try SyntheticNetwork.diffRecord(first, latitude: "35.1000001")])
        try check(SyntheticNetwork.station(changed, 34).outcome == .heldBack(.selectedPointChanged), "changed point")
        // The chosen row is not a member.
        var gone = model
        gone.stations[gone.stations.firstIndex { $0.id == SyntheticNetwork.stn(34) }!].rows.append(SyntheticNetwork.Row(side: 1, stop: "syn-b-diff2", latitude: 35.25, longitude: 139.25))
        let goneFirst = try SyntheticNetwork.build(gone)
        gone.stations[gone.stations.firstIndex { $0.id == SyntheticNetwork.stn(34) }!].rows.removeAll { $0.stop == "syn-b-diff2" }
        let absentRecord = try CoordinateRecord(
            reviewID: "SYN-REVIEW-C2", stationID: SyntheticNetwork.stn(34),
            members: [SyntheticNetwork.row(0, "syn-a-diff"), SyntheticNetwork.row(1, "syn-b-diff"), SyntheticNetwork.row(1, "syn-b-diff2")],
            selected: SyntheticNetwork.row(1, "syn-b-diff2"), selectedArchiveSHA256: SyntheticNetwork.archives[1], latitude: "35.25", longitude: "139.25",
            reason: "Synthetic choice", evidenceSHA256: SyntheticNetwork.station(goneFirst, 34).evidenceSHA256)
        try check(SyntheticNetwork.station(try SyntheticNetwork.build(gone, coordinates: [absentRecord]), 34).outcome == .heldBack(.selectedRowAbsent), "absent row")
        // Another member's point moved: the evidence the reviewer saw changed.
        var moved = model
        let index = moved.stations.firstIndex { $0.id == SyntheticNetwork.stn(34) }!
        moved.stations[index].rows[1].latitude = 35.21
        try check(SyntheticNetwork.station(try SyntheticNetwork.build(moved, coordinates: [try SyntheticNetwork.diffRecord(first)]), 34).outcome == .heldBack(.reviewStale), "stale")
        // An invalid point is held back, never clamped.
        var invalid = model
        invalid.stations[0].rows[0].latitude = 95
        try check(SyntheticNetwork.station(try SyntheticNetwork.build(invalid), 1).outcome == .heldBack(.invalidPoint), "invalid point")
    }),
    ("coordinates: records are unique, name known stations, and a record no longer needed is reported, not applied", { _ in
        let model = SyntheticNetwork.base()
        let first = try SyntheticNetwork.build(model)
        let record = try SyntheticNetwork.diffRecord(first)
        do { _ = try SyntheticNetwork.build(model, coordinates: [record, try SyntheticNetwork.diffRecord(first, reviewID: "SYN-REVIEW-C9")]); throw TestFailure(message: "duplicate accepted") }
        catch let error as NetworkError { try check(error == .repeatedRecord, "\(error)") }
        let unknown = try CoordinateRecord(reviewID: "SYN-REVIEW-C3", stationID: SyntheticNetwork.stn(99), members: [SyntheticNetwork.row(0, "syn-x")], selected: SyntheticNetwork.row(0, "syn-x"),
                                           selectedArchiveSHA256: SyntheticNetwork.archives[0], latitude: "1", longitude: "1", reason: "Synthetic", evidenceSHA256: record.evidenceSHA256)
        do { _ = try SyntheticNetwork.build(model, coordinates: [unknown]); throw TestFailure(message: "unknown station accepted") }
        catch let error as NetworkError { try check(error == .invalidRecord, "\(error)") }
        // The points became identical: the automatic rule applies and the record is unused.
        var same = model
        let index = same.stations.firstIndex { $0.id == SyntheticNetwork.stn(34) }!
        same.stations[index].rows[1].latitude = 35.1; same.stations[index].rows[1].longitude = 139.1
        let result = try SyntheticNetwork.build(same, coordinates: [record])
        guard case .selected(_, _, nil) = SyntheticNetwork.station(result, 34).outcome else { throw TestFailure(message: "identical points not automatic") }
        try check(result.unusedCoordinateRecords == 1, "reported unused")
        // A record needs a reason and a member selection.
        do { _ = try CoordinateRecord(reviewID: "SYN-REVIEW-C4", stationID: SyntheticNetwork.stn(34), members: [SyntheticNetwork.row(0, "syn-a-diff")], selected: SyntheticNetwork.row(1, "syn-b-diff"),
                                      selectedArchiveSHA256: SyntheticNetwork.archives[0], latitude: "35.1", longitude: "139.1", reason: "Synthetic", evidenceSHA256: record.evidenceSHA256)
             throw TestFailure(message: "a non-member selection accepted") }
        catch let error as NetworkError { try check(error == .invalidRecord, "\(error)") }
    }),
    ("coordinate revisions: points are classified again, and every previous selection is kept as history, never overwritten", { _ in
        let model = SyntheticNetwork.base()
        let first = try SyntheticNetwork.build(model, coordinates: [try SyntheticNetwork.diffRecord(try SyntheticNetwork.build(model))])
        let artifact1 = CoordinateArtifact.make(first.coordinates, previous: nil)
        try check(artifact1.stations.allSatisfy(\.history.isEmpty), "no history at first")
        // Same inputs again: the artifact is unchanged.
        try check(CoordinateArtifact.make(first.coordinates, previous: artifact1) == artifact1, "an unchanged rerun adds no history")
        // A revision: the identical-point station now differs; the reviewed choice moved; one station's row is gone.
        var revised = model
        let same = revised.stations.firstIndex { $0.id == SyntheticNetwork.stn(35) }!
        revised.stations[same].rows[1].latitude = 35.31
        let diff = revised.stations.firstIndex { $0.id == SyntheticNetwork.stn(34) }!
        revised.stations[diff].rows[0].latitude = 35.11
        revised.stations.removeAll { $0.id == SyntheticNetwork.stn(2) }
        revised.lines[0].trips = revised.lines[0].trips.map { SyntheticNetwork.Trip(stops: $0.stops.filter { $0 != "syn-t1" }) }
        let second = try SyntheticNetwork.build(revised, coordinates: [try SyntheticNetwork.diffRecord(try SyntheticNetwork.build(model))])
        try check(SyntheticNetwork.station(second, 35).outcome == .heldBack(.reviewRequired), "automatic becomes a review case")
        try check(SyntheticNetwork.station(second, 34).outcome == .heldBack(.selectedPointChanged), "a moved reviewed point needs review")
        let artifact2 = CoordinateArtifact.make(second.coordinates, previous: artifact1)
        func entry(_ n: Int) -> CoordinateArtifact.Station { artifact2.stations.first { $0.stationID == SyntheticNetwork.stn(n).rawValue }! }
        try check(entry(35).history.count == 1 && entry(35).history[0].rule == "identicalPoints" && entry(35).history[0].provenance.count == 2, "identical selection kept")
        try check(entry(34).history.count == 1 && entry(34).history[0].reviewID == "SYN-REVIEW-C1" && entry(34).history[0].latitude == "35.1", "reviewed selection kept")
        try check(entry(2).status == "absent" && entry(2).history.count == 1, "an absent station keeps its history")
        try check(entry(34).latitude == nil && entry(34).status == "heldBack", "nothing substituted")
        // The next run keeps the history and appends nothing new.
        let artifact3 = CoordinateArtifact.make(second.coordinates, previous: artifact2)
        try check(artifact3 == artifact2, "history is carried, not duplicated")
    }),
    ("topology: a loop plus tail from full-loop trips is included unflagged and passes its shape check; direction is kept as evidence only", { _ in
        let result = try SyntheticNetwork.build(SyntheticNetwork.base(), topology: try SyntheticNetwork.allDecided(SyntheticNetwork.base()),
                                                shapes: [(SyntheticNetwork.lin(1), .loopPlusTail), (SyntheticNetwork.lin(2), .loopPlusTail)])
        let loop = SyntheticNetwork.line(result, 1)
        try check(loop.heldBack == nil && loop.topology?.adjacencies.count == 5 && loop.candidates.allSatisfy { $0.classification == .included }, "built, nothing flagged")
        let closing = SyntheticNetwork.candidate(loop, 1, 3)!
        try check(!closing.alternativeRuns.isEmpty && closing.alternativeRuns.allSatisfy { !$0.qualifies }, "the long way round is observed but not qualifying")
        try check(closing.forward + closing.backward == 2 && closing.supportTrips.count == 2, "both directions recorded")
        try check(result.shapes.first { $0.lineID == SyntheticNetwork.lin(1) }!.passed, "loop plus tail passes")
        let wrong = result.shapes.first { $0.lineID == SyntheticNetwork.lin(2) }!
        try check(!wrong.passed && SyntheticNetwork.line(result, 2).topology != nil, "a mismatch is reported, the graph unchanged")
    }),
    ("topology: a branch running through to the main line forms one degree-3 junction and passes its shape check", { _ in
        let result = try SyntheticNetwork.build(SyntheticNetwork.base(), topology: try SyntheticNetwork.allDecided(SyntheticNetwork.base()),
                                                shapes: [(SyntheticNetwork.lin(2), .branch), (SyntheticNetwork.lin(1), .branch)])
        let branch = SyntheticNetwork.line(result, 2)
        try check(branch.topology?.adjacencies.count == 5 && SyntheticNetwork.candidate(branch, 7, 10) != nil, "junction adjacency from the branch trip")
        let check2 = result.shapes.first { $0.lineID == SyntheticNetwork.lin(2) }!
        try check(check2.passed && check2.cycles == 0 && check2.degreeCounts[3] == 1 && check2.degreeCounts[1] == 3, "branch shape")
        try check(!result.shapes.first { $0.lineID == SyntheticNetwork.lin(1) }!.passed, "a loop is not a branch")
    }),
    ("topology: an adjacency supported only by a partial trip is flagged for review and never removed automatically", { _ in
        let model = SyntheticNetwork.base()
        let result = try SyntheticNetwork.build(model)
        let partial = SyntheticNetwork.line(result, 3)
        let closing = SyntheticNetwork.candidate(partial, 12, 15)!
        try check(closing.classification == .possibleShortcut && closing.alternativeRuns.contains(where: \.qualifies), "partial-loop flag")
        try check(partial.heldBack == .reviewRequired && partial.topology == nil, "held for review, not decided")
        let kept = try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(partial)])
        try check(SyntheticNetwork.line(kept, 3).topology?.adjacencies.count == 4, "included by review: the loop closes")
        let dropped = try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(partial, include: { _ in false })])
        let line = SyntheticNetwork.line(dropped, 3)
        try check(line.topology?.adjacencies.count == 3 && SyntheticNetwork.candidate(line, 12, 15)?.included == false && SyntheticNetwork.candidate(line, 12, 15)?.reviewID != nil,
                  "excluded only by review, with its evidence kept")
    }),
    ("topology: pass-through rows keep physical order; only a trip that omits a row flags a possible shortcut", { _ in
        var model = SyntheticNetwork.base()
        let withPass = SyntheticNetwork.line(try SyntheticNetwork.build(model), 4)
        try check(withPass.candidates.filter(\.needsReview).map(\.pair) == [SyntheticNetwork.pair(16, 18)], "only the omitted-row pair: \(withPass.candidates.filter(\.needsReview).map(\.pair))")
        // Without the omitting trip, the express with pass-through rows flags nothing.
        model.lines[3].trips.removeLast()
        let clean = SyntheticNetwork.line(try SyntheticNetwork.build(model), 4)
        try check(clean.heldBack == nil && clean.candidates.allSatisfy { $0.classification == .included } && clean.topology?.adjacencies.count == 4, "pass-through rows: no flag")
    }),
    ("topology: with several alternative runs, one qualifying run is enough to flag, and every run is kept", { _ in
        let line = SyntheticNetwork.line(try SyntheticNetwork.build(SyntheticNetwork.base()), 5)
        let candidate = SyntheticNetwork.candidate(line, 21, 23)!
        try check(candidate.alternativeRuns.count == 2, "two runs: \(candidate.alternativeRuns.count)")
        try check(candidate.alternativeRuns.filter(\.qualifies).map(\.intermediates) == [[SyntheticNetwork.stn(24)]], "via vx qualifies; via v2 is visited by a supporting trip")
        try check(candidate.classification == .possibleShortcut, "flagged")
    }),
    ("topology: a triangle is a review trigger; decisions must cover exactly the review cases; membership and emptiness are checked", { _ in
        let model = SyntheticNetwork.base()
        let triangle = SyntheticNetwork.line(try SyntheticNetwork.build(model), 6)
        try check(triangle.candidates.filter { $0.classification == .triangleTrigger }.count == 3 && triangle.heldBack == .reviewRequired, "three triggers, held")
        let partialDecision = try TopologyRecord(reviewID: "SYN-REVIEW-T6", lineID: SyntheticNetwork.lin(6), evidenceSHA256: triangle.evidenceSHA256,
                                                 decisions: [.init(pair: SyntheticNetwork.pair(25, 26), include: true, reason: "Synthetic", runs: [])], ignoresSelfPairs: false)
        do { _ = try SyntheticNetwork.build(model, topology: [partialDecision]); throw TestFailure(message: "incomplete decisions accepted") }
        catch let error as NetworkError { try check(error == .topologyDecisionsMismatch, "\(error)") }
        let path = try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(triangle, include: { $0 != SyntheticNetwork.pair(25, 27) })])
        try check(SyntheticNetwork.line(path, 6).topology?.adjacencies.count == 2, "a reviewed path")
        let lost = try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(triangle, include: { $0 == SyntheticNetwork.pair(26, 27) })])
        try check(SyntheticNetwork.line(lost, 6).heldBack == .membershipMismatch, "a served station left out")
        let none = try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(triangle, include: { _ in false })])
        try check(SyntheticNetwork.line(none, 6).heldBack == .empty, "nothing included")
    }),
    ("topology: a self-pair is never an adjacency and needs a record stating its treatment; a disconnected line is held back", { _ in
        var model = SyntheticNetwork.base()
        let self1 = SyntheticNetwork.line(try SyntheticNetwork.build(model), 7)
        try check(self1.selfPairs.map(\.station) == [SyntheticNetwork.stn(28)] && self1.heldBack == .reviewRequired, "held without a record")
        do { _ = try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(self1)]); throw TestFailure(message: "untreated self-pair accepted") }
        catch let error as NetworkError { try check(error == .selfPairTreatmentMissing, "\(error)") }
        let treated = SyntheticNetwork.line(try SyntheticNetwork.build(model, topology: [try SyntheticNetwork.decide(self1, selfPairs: true)]), 7)
        try check(treated.topology?.adjacencies.count == 1 && treated.selfPairs.count == 1, "built, evidence kept")
        model.stations += [SyntheticNetwork.single(30, "syn-d1"), SyntheticNetwork.single(31, "syn-d2"), SyntheticNetwork.single(32, "syn-d3"), SyntheticNetwork.single(33, "syn-d4")]
        model.lines.append(SyntheticNetwork.Line(id: SyntheticNetwork.lin(8), side: 0, route: "syn-route-split", trips: [
            SyntheticNetwork.Trip(stops: ["syn-d1", "syn-d2"]), SyntheticNetwork.Trip(stops: ["syn-d3", "syn-d4"])]))
        try check(SyntheticNetwork.line(try SyntheticNetwork.build(model), 8).heldBack == .disconnected, "disconnected")
    }),
    ("topology: a review whose evidence changed is stale and holds the line back", { _ in
        var model = SyntheticNetwork.base()
        let record = try SyntheticNetwork.decide(SyntheticNetwork.line(try SyntheticNetwork.build(model), 3))
        model.lines[2].trips.append(SyntheticNetwork.Trip(stops: ["syn-pj", "syn-p1"]))
        try check(SyntheticNetwork.line(try SyntheticNetwork.build(model, topology: [record]), 3).heldBack == .reviewStale, "stale review")
    }),
    ("membership: each station lists the lines serving its rows, and every built line agrees with them", { _ in
        let model = SyntheticNetwork.base()
        let result = try SyntheticNetwork.build(model, topology: try SyntheticNetwork.allDecided(model))
        try check(result.membership[SyntheticNetwork.stn(1)] == [SyntheticNetwork.lin(1)], "one line")
        try check(result.membership[SyntheticNetwork.stn(34)] == [SyntheticNetwork.lin(9)] && result.membership[SyntheticNetwork.stn(35)] == [SyntheticNetwork.lin(9)], "B-served stations")
        let artifact = MembershipArtifact.make(result)
        try check(artifact.lines.allSatisfy(\.agreesWithStations) && artifact.lines.count == 8, "every line agrees")
    }),
    ("results are deterministic: repeated, and independent of row order", { _ in
        let model = SyntheticNetwork.base()
        let records = try SyntheticNetwork.allDecided(model)
        let a = try SyntheticNetwork.build(model, topology: records, shapes: [(SyntheticNetwork.lin(1), .loopPlusTail)])
        let b = try SyntheticNetwork.build(model, topology: records, shapes: [(SyntheticNetwork.lin(1), .loopPlusTail)])
        let c = try SyntheticNetwork.build(model, topology: records, shapes: [(SyntheticNetwork.lin(1), .loopPlusTail)], reversed: true)
        try check(a == b && a == c, "equal results")
        try check(NetworkJSON.encode(TopologyArtifact.make(a.lines)) == NetworkJSON.encode(TopologyArtifact.make(c.lines)), "identical bytes")
    }),
    ("the registry must map every row and route, reconciled with these exact inputs", { _ in
        var model = SyntheticNetwork.base()
        let registry = SyntheticNetwork.registry(model)
        model.stations[0].rows.append(SyntheticNetwork.Row(side: 0, stop: "syn-unmapped", latitude: 35, longitude: 139))
        do { _ = try NetworkArtifacts.build(SyntheticNetwork.sides(model), registry: registry, coordinateRecords: [], topologyRecords: [], shapes: []); throw TestFailure(message: "unmapped row accepted") }
        catch let error as NetworkError { try check(error == .rowUnmapped, "\(error)") }
        let base = SyntheticNetwork.base()
        let other = SyntheticNetwork.registry(base, archives: [String(repeating: "a", count: 64), SyntheticNetwork.archives[1]])
        do { _ = try NetworkArtifacts.build(SyntheticNetwork.sides(base), registry: other, coordinateRecords: [], topologyRecords: [], shapes: []); throw TestFailure(message: "stale registry accepted") }
        catch let error as NetworkError { try check(error == .registryNotReconciled, "\(error)") }
    }),
    ("no distance is computed: the network sources hold no distance or trigonometric code", { _ in
        for file in ["NetworkArtifacts.swift", "NetworkCommand.swift"] {
            let text = try String(contentsOfFile: repositoryPath + "/Tools/StaticDataIntake/Sources/" + file, encoding: .utf8)
            for token in ["haversine", "distance(", "sin(", "cos(", "atan2(", "sqrt(", "CLLocation"] {
                try check(!text.contains(token), "\(file) contains \(token)")
            }
        }
    }),
    ("network-packet exports coordinate and topology review cases with empty templates, deciding nothing", { workspace in
        let model = SyntheticNetwork.base()
        let files = try await SyntheticNetwork.files(model, workspace)
        let output = workspace.output.appendingPathComponent("network-packet.json")
        let (packet, _) = try await NetworkCommand.packet(SyntheticNetwork.request(files, output: output), repositoryRoot: testRepositoryRoot)
        try check(packet.coordinateCases.map(\.stationID) == [SyntheticNetwork.stn(34).rawValue] && packet.coordinateCases[0].rows.count == 2, "one different-point station, both rows")
        try check(packet.topologyCases.count == 5 && packet.topologyCases.allSatisfy { $0.recordTemplate.reviewID.isEmpty && $0.recordTemplate.decisions.allSatisfy { $0.decision.isEmpty } }, "five lines, empty templates")
        try check(packet.coordinateCases[0].recordTemplate.reviewID.isEmpty && packet.coordinateCases[0].recordTemplate.latitude.isEmpty, "no chosen point")
        try check(try Data(contentsOf: output) == NetworkJSON.encode(packet), "published as built")
    }),
    ("network-build publishes coordinates, topology, membership, and an aggregate report; a rerun is byte-identical and the registry untouched", { workspace in
        let model = SyntheticNetwork.base()
        let files = try await SyntheticNetwork.files(model, workspace)
        let registryBefore = try Data(contentsOf: files.registry)
        let records = try SyntheticNetwork.writeRecords(files, model, workspace)
        let shapes: [(MintedIdentifier, ShapeKind)] = [(SyntheticNetwork.lin(1), .loopPlusTail), (SyntheticNetwork.lin(2), .branch)]
        let first = workspace.output.appendingPathComponent("network-1")
        let outcome = try await NetworkCommand.build(SyntheticNetwork.request(files, records: records, shapes: shapes, output: first), repositoryRoot: testRepositoryRoot)
        let entries = try FileManager.default.contentsOfDirectory(atPath: first.path).sorted()
        try check(entries == ["coordinates.json", "membership.json", "report.json", "topology.json"], "\(entries)")
        let report = outcome.report
        try check(report.builtLines == 8 && report.heldBackLines.isEmpty && report.membershipAgreement == 8, "every line built and agreeing")
        try check(report.heldBackStations.isEmpty && report.selectedByRule["reviewed"] == 1 && report.selectedByRule["identicalPoints"] == 2, "\(report.selectedByRule)")
        try check(report.shapes.allSatisfy(\.passed) && report.shapes.count == 2 && report.excluded == 0, "shapes pass")
        let text = String(decoding: NetworkJSON.encode(report), as: UTF8.self)
        try check(SyntheticRun.safe(text) && !text.contains("stn_") && !text.contains("lin_"), "aggregates only")
        // Every candidate's evidence is kept in the topology artifact.
        let topology = try JSONSerialization.jsonObject(with: try Data(contentsOf: first.appendingPathComponent("topology.json"))) as! [String: Any]
        let lines = topology["lines"] as! [[String: Any]]
        try check(lines.allSatisfy { ($0["candidates"] as! [[String: Any]]).allSatisfy { ($0["supportTrips"] as! [String]).count > 0 } }, "support kept")
        // A rerun against its own coordinates is byte-identical.
        let second = workspace.output.appendingPathComponent("network-2")
        _ = try await NetworkCommand.build(SyntheticNetwork.request(files, records: records, previous: first.appendingPathComponent("coordinates.json"), shapes: shapes, output: second),
                                           repositoryRoot: testRepositoryRoot)
        for name in entries {
            try check(try Data(contentsOf: first.appendingPathComponent(name)) == (try Data(contentsOf: second.appendingPathComponent(name))), "\(name) byte-identical")
        }
        try check(try Data(contentsOf: files.registry) == registryBefore, "the registry is read, never written")
    }),
    ("network commands refuse malformed records and existing outputs, leaving the output directory unchanged", { workspace in
        let model = SyntheticNetwork.base()
        let files = try await SyntheticNetwork.files(model, workspace)
        let bad = workspace.archives.appendingPathComponent("bad.json")
        try Data(#"{"schemaVersion": 1, "coordinates": [], "extra": true}"#.utf8).write(to: bad)
        let before = try workspace.outputEntries()
        do { _ = try await NetworkCommand.build(SyntheticNetwork.request(files, records: bad, output: workspace.output.appendingPathComponent("x")), repositoryRoot: testRepositoryRoot)
             throw TestFailure(message: "malformed records accepted") }
        catch let error as ProvisionalRegistryError { try check(error == .records(.malformed), "\(error)") }
        try check(try workspace.outputEntries() == before, "nothing published")
        let output = workspace.output.appendingPathComponent("p.json")
        _ = try await NetworkCommand.packet(SyntheticNetwork.request(files, output: output), repositoryRoot: testRepositoryRoot)
        do { _ = try await NetworkCommand.packet(SyntheticNetwork.request(files, output: output), repositoryRoot: testRepositoryRoot); throw TestFailure(message: "replaced") }
        catch let error as ProvisionalRegistryError { try check(error == .output(.outputExists), "\(error)") }
    }),
    ("review fix: an active station without rows and a line without routes are held back, and their records reported unused, not fatal", { _ in
        let model = SyntheticNetwork.base()
        let base = SyntheticNetwork.registry(model)
        let registry = try MappingRegistry(revision: base.revision, entities: base.entities + [CanonicalEntity(id: SyntheticNetwork.stn(40), status: .active), CanonicalEntity(id: SyntheticNetwork.lin(12), status: .active)],
                                           references: base.references)
        let first = try NetworkArtifacts.build(SyntheticNetwork.sides(model), registry: registry, coordinateRecords: [], topologyRecords: [], shapes: [])
        try check(SyntheticNetwork.station(first, 40).outcome == .heldBack(.noMemberRows), "listed as held back")
        try check(SyntheticNetwork.line(first, 12).heldBack == .noRoutes, "line without routes held back")
        let record = try CoordinateRecord(reviewID: "SYN-REVIEW-C5", stationID: SyntheticNetwork.stn(40), members: [SyntheticNetwork.row(0, "syn-old")], selected: SyntheticNetwork.row(0, "syn-old"),
                                          selectedArchiveSHA256: SyntheticNetwork.archives[0], latitude: "35", longitude: "139", reason: "Synthetic", evidenceSHA256: String(repeating: "f", count: 64))
        let line = try TopologyRecord(reviewID: "SYN-REVIEW-T12", lineID: SyntheticNetwork.lin(12), evidenceSHA256: String(repeating: "f", count: 64), decisions: [], ignoresSelfPairs: false)
        let again = try NetworkArtifacts.build(SyntheticNetwork.sides(model), registry: registry, coordinateRecords: [record], topologyRecords: [line], shapes: [])
        try check(again.unusedCoordinateRecords == 1 && again.unusedTopologyRecords == 1, "reported unused")
        let artifact = CoordinateArtifact.make(again.coordinates, previous: nil)
        try check(artifact.stations.first { $0.stationID == SyntheticNetwork.stn(40).rawValue }?.heldBack == "noMemberRows", "in the artifact")
    }),
    ("review fix: a coordinate record reviewed on another input than the chosen row's holds the station back", { _ in
        let model = SyntheticNetwork.base()
        let first = try SyntheticNetwork.build(model)
        let good = try SyntheticNetwork.diffRecord(first)
        let wrong = try CoordinateRecord(reviewID: good.reviewID, stationID: good.stationID, members: good.members, selected: good.selected,
                                         selectedArchiveSHA256: SyntheticNetwork.archives[1], latitude: good.latitude, longitude: good.longitude,
                                         reason: good.reason, evidenceSHA256: good.evidenceSHA256)
        let result = try SyntheticNetwork.build(model, coordinates: [wrong])
        try check(SyntheticNetwork.station(result, 34).outcome == .heldBack(.selectedInputChanged) && result.unusedCoordinateRecords == 1, "input changed, not applied")
    }),
    ("review fix: a topology decision must address every alternative run of its candidate", { _ in
        let model = SyntheticNetwork.base()
        let line = SyntheticNetwork.line(try SyntheticNetwork.build(model), 5)
        let record = try SyntheticNetwork.decide(line)
        let short = try TopologyRecord(reviewID: record.reviewID, lineID: record.lineID, evidenceSHA256: record.evidenceSHA256,
                                       decisions: record.decisions.map { .init(pair: $0.pair, include: $0.include, reason: $0.reason, runs: Array($0.runs.prefix(1))) },
                                       ignoresSelfPairs: false)
        do { _ = try SyntheticNetwork.build(model, topology: [short]); throw TestFailure(message: "a decision missing a run accepted") }
        catch let error as NetworkError { try check(error == .topologyDecisionsMismatch, "\(error)") }
        try check(SyntheticNetwork.line(try SyntheticNetwork.build(model, topology: [record]), 5).topology != nil, "every run addressed")
    }),
    ("review fix: stale records are not counted as used", { _ in
        var model = SyntheticNetwork.base()
        let first = try SyntheticNetwork.build(model)
        let coordinate = try SyntheticNetwork.diffRecord(first)
        let topology = try SyntheticNetwork.decide(SyntheticNetwork.line(first, 3))
        model.stations[model.stations.firstIndex { $0.id == SyntheticNetwork.stn(34) }!].rows[1].latitude = 35.21
        model.lines[2].trips.append(SyntheticNetwork.Trip(stops: ["syn-pj", "syn-p1"]))
        let result = try SyntheticNetwork.build(model, coordinates: [coordinate], topology: [topology])
        try check(result.unusedCoordinateRecords == 1 && result.unusedTopologyRecords == 1, "stale records unused: \(result.unusedCoordinateRecords), \(result.unusedTopologyRecords)")
    }),
]
