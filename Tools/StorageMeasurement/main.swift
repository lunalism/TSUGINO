// Invented-data measurement only. Not an app backend or a provider importer.
import Foundation
import Darwin
import CSQLite

enum Failure: Error { case invalid(String) }
func require(_ value: Bool, _ label: String) throws { if !value { throw Failure.invalid(label) } }
func now() -> Double { Double(DispatchTime.now().uptimeNanoseconds) / 1e6 }
func peak() -> Int64 { var r = rusage(); getrusage(RUSAGE_SELF, &r); return Int64(r.ru_maxrss) }
let encoder: JSONEncoder = { let e = JSONEncoder(); e.outputFormatting = [.sortedKeys]; return e }()
let decoder = JSONDecoder()
var fullFixtureParses = 0
func readFixture(_ path: String) throws -> Fixture {
    fullFixtureParses += 1
    return try decoder.decode(Fixture.self, from: boundedData(path))
}
let maxArtifact = 256 * 1024 * 1024
func boundedData(_ path: String) throws -> Data {
    let size = (try FileManager.default.attributesOfItem(atPath: path)[.size] as! NSNumber).intValue
    try require(size <= maxArtifact, "artifact bound")
    return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
}
struct Context: Codable { let operators: [Operator]; let lines: [RailwayLine] }
struct Fixture: Codable { let context: Context; let stations: [Station]; let aliases: [ExactStationIndex.Alias] }
func label(_ stem: String) -> LocalizedRailName {
    LocalizedRailName(japanese: "架空-" + stem, english: "Invented-" + stem, korean: "가상-" + stem)!
}
func sid(_ i: Int) -> StationID { StationID(String(format: "synthetic-station-%06d", i))! }
func fixture(_ n: Int) -> Fixture {
    let multiplier = n / 258, lineCount = multiplier * 15, opCount = multiplier * 2
    let ops = (0..<opCount).map { Operator(id: OperatorID("synthetic-operator-\($0)")!, name: label("Operator-\($0)")) }
    let lids = (0..<lineCount).map { LineID(String(format: "synthetic-line-%05d", $0))! }
    let stations = (0..<n).map { i -> Station in
        var name = label(String(format: "%06d", i))
        if i == 0 { name = LocalizedRailName(japanese: "架空-é", english: "Invented-Same", korean: "가상-첫째")! }
        if i == 1 { name = LocalizedRailName(japanese: "架空-e\u{301}", english: "Invented-Same", korean: "가상-둘째")! }
        return Station(id: sid(i), name: name, coordinate: GeoCoordinate(latitude: 0.1 + Double(i % 100) / 1000, longitude: 0.2)!, lineIDs: [lids[i * lineCount / n]])
    }
    var groups = Array(repeating: [StationID](), count: lineCount)
    for i in 0..<n { groups[i * lineCount / n].append(sid(i)) }
    let lines = groups.enumerated().map { i, ids in
        RailwayLine(id: lids[i], operatorID: ops[i % opCount].id, name: label("Line-\(i)"), topology: RailwayLineTopology(adjacencies: Set(zip(ids, ids.dropFirst()).map { StationAdjacency($0, $1)! }))!)
    }
    let aliases = (0..<(6 * multiplier)).map { i in
        ExactStationIndex.Alias(stationID: sid(i), value: ExactValue(i == 0 ? " Invented alias " : "Invented-alias-\(i)")!)
    }
    return Fixture(context: Context(operators: ops, lines: lines), stations: stations, aliases: aliases)
}
struct Slot: Codable { let offset: Int; let count: Int }
struct Directory: Codable {
    let schema: Int
    let dataVersion: String
    let context: Context
    let ids: [String]
    let slots: [Slot]
    let entries: [ExactStationIndex.Entry]
}
protocol Store: AnyObject {
    var context: Context { get }
    var recordDecodes: Int { get }
    var indexDecodes: Int { get }
    var cacheCount: Int { get }
    func search(_ query: String) throws -> [Station]
    func all() throws -> [Station]
    func close() throws
}
// FIFO, identical for both representations. No unbounded station cache.
class Cache {
    var values: [String: Station] = [:]
    var queue: [String] = []
    var recordDecodes = 0
    func station(_ id: String, bytes: () throws -> Data) throws -> Station {
        if let v = values[id] { return v }
        let v = try decoder.decode(Station.self, from: bytes()); recordDecodes += 1
        if queue.count == 256 { values.removeValue(forKey: queue.removeFirst()) }
        queue.append(id); values[id] = v
        return v
    }
}
final class Compact: Cache, Store {
    var bytes: Data
    let directory: Directory
    let start: Int
    let positions: [String: Int]
    var context: Context { directory.context }
    var indexDecodes: Int { 1 }
    var cacheCount: Int { values.count }
    init(_ path: String) throws {
        bytes = try boundedData(path)
        try require(bytes.count >= 8, "header")
        let count = bytes.prefix(8).reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }
        try require(count <= 64 * 1024 * 1024 && count <= bytes.count - 8, "directory bound")
        start = 8 + Int(count)
        directory = try PropertyListDecoder().decode(Directory.self, from: bytes.subdata(in: 8..<start))
        try require(directory.schema == 1 && directory.dataVersion == "synthetic-v1", "unsupported version")
        try require(directory.ids.count == directory.slots.count && Set(directory.ids).count == directory.ids.count, "directory ids")
        for slot in directory.slots { try require(slot.offset >= 0 && slot.count >= 0 && slot.offset <= bytes.count - start && slot.count <= bytes.count - start - slot.offset, "slot bound") }
        positions = Dictionary(uniqueKeysWithValues: directory.ids.enumerated().map { ($1, $0) })
        super.init()
    }
    func load(_ id: String) throws -> Station {
        guard let i = positions[id] else { throw Failure.invalid("unknown target") }
        let slot = directory.slots[i]
        return try station(id) { bytes.subdata(in: (start + slot.offset)..<(start + slot.offset + slot.count)) }
    }
    func search(_ query: String) throws -> [Station] {
        guard let key = ExactValue(query) else { return [] }
        let entries = directory.entries
        var lo = 0, hi = entries.count
        while lo < hi { let mid = (lo + hi) / 2; if entries[mid].key < key { lo = mid + 1 } else { hi = mid } }
        guard lo < entries.count, entries[lo].key == key else { return [] }
        return try entries[lo].stationIDs.map { try load($0.rawValue) }
    }
    func all() throws -> [Station] { try directory.ids.map(load) }
    func close() throws { bytes = Data(); values.removeAll(); queue.removeAll() }
}
let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
func sqlOK(_ result: Int32) throws { try require(result == SQLITE_OK || result == SQLITE_DONE, "sqlite failure") }
func statement(_ db: OpaquePointer?, _ sql: String) throws -> OpaquePointer {
    var s: OpaquePointer?; try sqlOK(sqlite3_prepare_v2(db, sql, -1, &s, nil)); return s!
}
func bind(_ s: OpaquePointer, _ index: Int32, _ data: Data) throws {
    try data.withUnsafeBytes { b in try sqlOK(sqlite3_bind_blob(s, index, b.baseAddress, Int32(b.count), transient)) }
}
func blob(_ s: OpaquePointer, _ index: Int32) -> Data { Data(bytes: sqlite3_column_blob(s, index)!, count: Int(sqlite3_column_bytes(s, index))) }
final class SQLiteStore: Cache, Store {
    var db: OpaquePointer?
    var query: OpaquePointer?
    let context: Context
    var indexDecodes: Int { 0 }
    var cacheCount: Int { values.count }
    init(_ path: String) throws {
        let size = (try FileManager.default.attributesOfItem(atPath: path)[.size] as! NSNumber).intValue
        try require(size <= maxArtifact, "artifact bound")
        var connection: OpaquePointer?
        try sqlOK(sqlite3_open_v2(path, &connection, SQLITE_OPEN_READONLY, nil))
        do {
            let version = try statement(connection, "PRAGMA user_version")
            defer { sqlite3_finalize(version) }
            try require(sqlite3_step(version) == SQLITE_ROW && sqlite3_column_int(version, 0) == 1, "unsupported version")
            let meta = try statement(connection, "SELECT value FROM metadata WHERE key='context'")
            defer { sqlite3_finalize(meta) }
            try require(sqlite3_step(meta) == SQLITE_ROW, "context")
            context = try decoder.decode(Context.self, from: blob(meta, 0))
            let dataVersion = try statement(connection, "SELECT value FROM metadata WHERE key='dataVersion'")
            defer { sqlite3_finalize(dataVersion) }
            try require(sqlite3_step(dataVersion) == SQLITE_ROW && blob(dataVersion, 0) == Data("synthetic-v1".utf8), "unsupported data version")
            query = try statement(connection, "SELECT stations.id, stations.payload FROM keys JOIN stations ON keys.id=stations.id WHERE keys.key=? ORDER BY stations.id")
        } catch { sqlite3_close(connection); throw error }
        db = connection
        super.init()
    }
    func search(_ text: String) throws -> [Station] {
        let s = query!
        sqlite3_reset(s); sqlite3_clear_bindings(s)
        try bind(s, 1, Data(text.utf8))
        var result: [Station] = []
        while true {
            let status = sqlite3_step(s)
            if status == SQLITE_DONE { break }
            try require(status == SQLITE_ROW, "query")
            let id = String(decoding: blob(s, 0), as: UTF8.self)
            result.append(try station(id) { blob(s, 1) })
        }
        return result
    }
    func all() throws -> [Station] {
        let s = try statement(db, "SELECT id,payload FROM stations ORDER BY id")
        defer { sqlite3_finalize(s) }
        var result: [Station] = []
        while true {
            let status = sqlite3_step(s); if status == SQLITE_DONE { break }
            try require(status == SQLITE_ROW, "load")
            result.append(try station(String(decoding: blob(s, 0), as: UTF8.self)) { blob(s, 1) })
        }
        return result
    }
    func close() throws {
        if let query { try sqlOK(sqlite3_finalize(query)); self.query = nil }
        if let db { try sqlOK(sqlite3_close(db)); self.db = nil }
        values.removeAll(); queue.removeAll()
    }
    deinit { if let query { sqlite3_finalize(query) }; if let db { sqlite3_close(db) } }
}
func open(_ kind: String, _ path: String) throws -> any Store { if kind == "compact" { return try Compact(path) }; return try SQLiteStore(path) }
func prepare(_ kind: String, _ f: Fixture, _ path: String) throws {
    let index = try ExactStationIndex(stations: f.stations, lines: f.context.lines, operators: f.context.operators, aliases: f.aliases)
    if kind == "compact" {
        var payload = Data(), slots: [Slot] = []
        for station in f.stations { let bytes = try encoder.encode(station); slots.append(Slot(offset: payload.count, count: bytes.count)); payload.append(bytes) }
        let d = Directory(schema: 1, dataVersion: "synthetic-v1", context: f.context, ids: f.stations.map { $0.id.rawValue }, slots: slots, entries: index.entries)
        let e = PropertyListEncoder(); e.outputFormat = .binary
        let header = try e.encode(d)
        var output = Data((0..<8).reversed().map { UInt8(truncatingIfNeeded: UInt64(header.count) >> ($0 * 8)) })
        output.append(header); output.append(payload)
        try output.write(to: URL(fileURLWithPath: path), options: .withoutOverwriting)
        let fd = Darwin.open(path, O_RDONLY); try require(fd >= 0, "open for sync"); defer { Darwin.close(fd) }; try require(fsync(fd) == 0, "sync")
    } else {
        try require(!FileManager.default.fileExists(atPath: path), "output exists")
        var db: OpaquePointer?; try sqlOK(sqlite3_open(path, &db)); defer { sqlite3_close(db) }
        try sqlOK(sqlite3_exec(db, "PRAGMA journal_mode=DELETE; PRAGMA synchronous=FULL; PRAGMA user_version=1; BEGIN; CREATE TABLE stations(id BLOB PRIMARY KEY,payload BLOB NOT NULL) WITHOUT ROWID; CREATE TABLE keys(key BLOB,id BLOB,PRIMARY KEY(key,id)) WITHOUT ROWID; CREATE TABLE metadata(key TEXT PRIMARY KEY,value BLOB NOT NULL);", nil, nil, nil))
        let stationInsert = try statement(db, "INSERT INTO stations VALUES(?,?)")
        let keyInsert = try statement(db, "INSERT INTO keys VALUES(?,?)")
        let metaInsert = try statement(db, "INSERT INTO metadata VALUES(?,?)")
        defer { sqlite3_finalize(stationInsert); sqlite3_finalize(keyInsert); sqlite3_finalize(metaInsert) }
        for station in f.stations {
            sqlite3_reset(stationInsert); try bind(stationInsert, 1, Data(station.id.rawValue.utf8)); try bind(stationInsert, 2, encoder.encode(station)); try sqlOK(sqlite3_step(stationInsert))
        }
        for entry in index.entries { for id in entry.stationIDs {
            sqlite3_reset(keyInsert); try bind(keyInsert, 1, Data(entry.key.text.utf8)); try bind(keyInsert, 2, Data(id.rawValue.utf8)); try sqlOK(sqlite3_step(keyInsert))
        } }
        for (key, value) in [("context", try encoder.encode(f.context)), ("dataVersion", Data("synthetic-v1".utf8))] {
            sqlite3_reset(metaInsert); try sqlOK(sqlite3_bind_text(metaInsert, 1, key, -1, transient)); try bind(metaInsert, 2, value); try sqlOK(sqlite3_step(metaInsert))
        }
        try sqlOK(sqlite3_exec(db, "COMMIT", nil, nil, nil))
    }
}
func same(_ a: Station, _ b: Station) -> Bool { a.id == b.id && a.name == b.name && a.coordinate == b.coordinate && a.lineIDs == b.lineIDs }
func queries(_ f: Fixture) -> [String] { f.stations.flatMap { [$0.name.japanese, $0.name.english, $0.name.korean] } + f.aliases.map { $0.value.text } + ["absent", "Invented alias", "invented-same", "架空-", " ", ""] }
func verify(_ kind: String, _ path: String, _ f: Fixture) throws -> Int {
    let oracle = try ExactStationIndex(stations: f.stations, lines: f.context.lines, operators: f.context.operators, aliases: f.aliases)
    let store = try open(kind, path)
    try require(store.context.lines.count == f.context.lines.count && store.context.operators.count == f.context.operators.count, "context count")
    for (a,b) in zip(store.context.lines, f.context.lines) { try require(a.id == b.id && a.operatorID == b.operatorID && a.name == b.name && a.topology == b.topology, "line payload") }
    for (a,b) in zip(store.context.operators, f.context.operators) { try require(a.id == b.id && a.name == b.name, "operator payload") }
    let qs = queries(f)
    for q in qs {
        let got = try store.search(q), expected = oracle.stations(matching: q).map(\.station)
        try require(got.count == expected.count && zip(got, expected).allSatisfy(same), "search payload/order")
    }
    try require(try store.search("架空-é").map(\.id) == [sid(0)], "composed")
    try require(try store.search("架空-e\u{301}").map(\.id) == [sid(1)], "decomposed")
    try require(try store.search("Invented-Same").map(\.id) == [sid(0),sid(1)], "same name")
    try require(try store.search("Invented alias").isEmpty, "no implicit alias")
    try require(store.cacheCount <= 256, "cache bound")
    try store.close()
    let reopened = try open(kind, path)
    let all = try reopened.all()
    try require(all.count == f.stations.count && zip(all, f.stations).allSatisfy(same), "reopen full payload")
    try reopened.close()
    return qs.count
}
func emit(_ value: [String: Any]) throws { let data = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys]); print(String(decoding: data, as: UTF8.self)) }
// Fixed bounded workload generated without reading the full fixture in the reader process.
func workload(_ n: Int) -> [String] {
    (0..<1024).map { i in
        switch i % 8 {
        case 0: return "架空-é"
        case 1: return "架空-e\u{301}"
        case 2: return "Invented-Same"
        case 3: return " Invented alias "
        case 4: return "missing-\(i)"
        default: return String(format: "Invented-%06d", 2 + ((i * 97) % (n - 2)))
        }
    }
}
do {
    let args = CommandLine.arguments
    let mode = args[1]
    if mode == "generate" {
        let n = Int(args[2])!; try require(n == 258 || n == 25800, "size")
        try encoder.encode(fixture(n)).write(to: URL(fileURLWithPath: args[3]), options: .withoutOverwriting)
        try emit(["stations": n]); exit(0)
    }
    let kind = args[2], path = args[3]
    try require(kind == "compact" || kind == "sqlite", "backend")
    if mode == "prepare" || mode == "verify" {
        let t = now(), f = try readFixture(args[4])
        if mode == "prepare" { try prepare(kind, f, path); try emit(["prepare_ms": now()-t, "peak_bytes": peak(), "full_fixture_parses": fullFixtureParses]) }
        else { let count = try verify(kind, path, f); try emit(["verified_queries": count, "stations": f.stations.count]) }
    } else if mode == "read" {
        let qs = workload(Int(args[4])!), t = now(); var store: (any Store)? = try open(kind, path)
        let opened = now(); let first = try store!.search("架空-é"); let ready = now()
        try require(first.map(\.id) == [sid(0)], "first query")
        var checksum = 0
        for q in qs { checksum += try store!.search(q).count }
        var samples: [Double] = []
        let ordinary = now()
        for _ in 0..<3 { for q in qs { let start = now(); checksum += try store!.search(q).count; samples.append((now()-start)*1000) } }
        let ordinaryMS = now() - ordinary
        samples.sort()
        let decodes = store!.recordDecodes, indexes = store!.indexDecodes, occupancy = store!.cacheCount
        let closed = now(); try store!.close(); store = nil; let closeMS = now()-closed
        let re = now(); store = try open(kind, path); let reResult = try store!.search("架空-é"); let reopenMS = now()-re
        try require(reResult.map(\.id) == [sid(0)], "reopen query")
        try emit(["open_ms": opened-t, "first_query_ms": ready-opened, "ready_ms": ready-t, "warm_median_us": samples[samples.count/2], "warm_p95_us": samples[Int(Double(samples.count)*0.95)], "ordinary_3072_queries_ms": ordinaryMS, "record_decodes": decodes, "index_decodes": indexes, "full_fixture_parses": fullFixtureParses, "cache_count": occupancy, "close_ms": closeMS, "reopen_ready_ms": reopenMS, "peak_bytes": peak(), "checksum": checksum])
        try store!.close()
    } else if mode == "load" {
        let t = now(), store = try open(kind, path), opened = now()
        let all = try store.all(), loaded = now()
        try emit(["load_open_ms": opened-t, "decode_all_ms": loaded-opened, "load_total_ms": loaded-t, "stations": all.count, "record_decodes": store.recordDecodes, "peak_bytes": peak()])
        withExtendedLifetime(all) {}; try store.close()
    } else { throw Failure.invalid("mode") }
} catch { fputs("prototype failure: \(error)\n", stderr); exit(1) }
