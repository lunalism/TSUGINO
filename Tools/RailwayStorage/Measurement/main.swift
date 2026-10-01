import Foundation
import Darwin
import SQLite3

func clockNS() -> UInt64 { DispatchTime.now().uptimeNanoseconds }
func elapsed(_ start: UInt64) -> Double { Double(clockNS() - start) / 1_000_000 }
func memory() -> [String: Int64] {
    var usage = rusage(); getrusage(RUSAGE_SELF, &usage)
    var info = mach_task_basic_info(); var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
    let result = withUnsafeMutablePointer(to: &info) { ptr in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count) }
    }
    return ["rss": result == KERN_SUCCESS ? Int64(info.resident_size) : -1, "peak": Int64(usage.ru_maxrss)]
}
func require(_ value: Bool) throws { if !value { throw NSError(domain: "synthetic-measurement", code: 1) } }
func identifier(_ prefix: String, _ n: Int) -> String {
    let alphabet = Array("0123456789abcdefghjkmnpqrstvwxyz")
    var number = n, digits = ""
    repeat { digits.insert(alphabet[number % 32], at: digits.startIndex); number /= 32 } while number > 0
    return prefix + "_" + String(repeating: "0", count: 16 - digits.count) + digits
}
func names(_ i: Int) -> LocalizedRailName {
    LocalizedRailName(japanese: i < 2 ? "Invented Same" : "Invented JP \(i)",
        english: i == 0 ? "Café" : i == 1 ? "Cafe\u{301}" : "Invented EN \(i)", korean: "Invented KO \(i)")!
}
func fixture(_ scale: Int, replacement: Bool) -> RailwayArtifactSnapshot {
    let n = 258 * scale, lineCount = 15 * scale, opCount = 2 * scale
    let ids = (0..<n).map { StationID(identifier("stn", replacement && $0 == 0 ? n + 1 : $0 + 1))! }
    let lines = (0..<lineCount).map { LineID(identifier("lin", $0 + 1))! }
    let ops = (0..<opCount).map { OperatorID(identifier("opr", $0 + 1))! }
    let stations = (0..<n).map { i in Station(id: ids[i], name: names(i), coordinate: GeoCoordinate(latitude: 1, longitude: 2)!, lineIDs: [lines[i * lineCount / n]]) }
    var groups = Array(repeating: [StationID](), count: lineCount)
    for i in 0..<n { groups[i * lineCount / n].append(ids[i]) }
    let railways = (0..<lineCount).map { i in RailwayLine(id: lines[i], operatorID: ops[i % opCount], name: names(n + i), topology: RailwayLineTopology(adjacencies: Set(zip(groups[i], groups[i].dropFirst()).map { StationAdjacency($0,$1)! }))!) }
    let operators = (0..<opCount).map { Operator(id: ops[$0], name: names(n + lineCount + $0)) }
    var entities = (ids.map(\.rawValue) + lines.map(\.rawValue) + ops.map(\.rawValue)).map { CanonicalEntity(id: MintedIdentifier($0)!, status: .active) }
    if replacement { entities.append(.init(id: MintedIdentifier(identifier("stn",1))!, status: .retired(successors: [MintedIdentifier(ids[0].rawValue)!]))) }
    return .init(stations: stations, lines: railways, operators: operators,
        aliases: (0..<(6 * scale)).map { .init(stationID: ids[$0], value: ExactValue(" Alias \($0) ")!) }, entities: entities)
}
func inputs(_ snapshot: RailwayArtifactSnapshot, modern: Bool) throws -> RailwayArtifactBuilder.Inputs {
    let content = RailwayArtifactContent(snapshot)
    return .init(registryBytes: try MappingRegistry(revision: modern ? 2 : 1, entities: content.entities, references: [], formatVersion: modern ? 3 : 2).encoded(),
        namesBytes: try RailwayArtifact.encode(content.stations.map(\.name)), networkBytes: try RailwayArtifact.encode(content.lines))
}
func queries(_ scale: Int) -> [String] {
    (0..<1024).map { i in
        switch i % 8 {
        case 0: return "Invented Same"
        case 1: return "Café"
        case 2: return "Cafe\u{301}"
        case 3: return " Alias \(i % (6 * scale)) "
        case 4: return "Invented EN \(2 + (i * 17) % (258 * scale - 2))"
        case 5: return "Invented KO \(2 + (i * 23) % (258 * scale - 2))"
        case 6: return "missing"
        default: return "Alias 0"
        }
    }
}
func diagnostics(_ d: SQLiteRailwayRepository.Diagnostics) -> [String: Int] {
    ["validationPasses":d.artifactValidationPasses,"fullLoads":d.explicitFullLoads,"stationDecodes":d.queryStationDecodes]
}
@main struct Measurement {
    static func main() async throws {
        let a = CommandLine.arguments
        let mode = a[1], scale = Int(a[2])!, modern = a[3] == "history", url = URL(fileURLWithPath: a[4])
        var result: [String: Any] = ["mode":mode,"scale":scale,"history":modern,"sqlite":String(cString:sqlite3_libversion())]
        if mode == "prepare" {
            let start = clockNS(), before = fixture(scale,replacement:false), oldInputs = try inputs(before,modern:false)
            let after = modern ? fixture(scale,replacement:true) : before, targetInputs = try inputs(after,modern:modern)
            result["fixtureMs"] = elapsed(start)
            let oldURL = modern ? url.deletingLastPathComponent().appendingPathComponent("previous.sqlite") : url
            let build = clockNS()
            _ = try await RailwayArtifactBuilder.build(snapshot:before,dataVersion:ExactValue("synthetic-before")!,inputs:oldInputs,output:oldURL)
            result["baselineBuildMs"] = elapsed(build)
            if modern {
                let source = MintedIdentifier(identifier("stn",1))!, target = MintedIdentifier(identifier("stn",258 * scale + 1))!
                let evidence = Data("Invented reviewed code/structural continuity for measurement".utf8)
                let p = IdentityTransition.Payload(schemaVersion:1,id:"measurement-transition",operation:.replace,kind:"stn",
                    previous:try .init(oldInputs.registryBytes),target:try .init(targetInputs.registryBytes),sources:[source],targets:[target],
                    beforeEntities:before.entities.filter { $0.id == source },afterEntities:after.entities.filter { $0.id == source || $0.id == target }.sorted { $0.id < $1.id }, dispositions:[],
                    evidence:[.init(source:ExactValue("invented measurement evidence")!,capture:.synthetic,bytes:evidence,sha256:RailwayArtifact.digest(evidence),locator:ExactValue("whole document")!,offset:0,quotation:evidence,members:[source,target],nonNameSupport:ExactValue("Invented structural continuity, explicitly reviewed")!)],
                    rationale:ExactValue("Synthetic benchmark replacement")!,dependencies:[.init(role:"names",sha256:RailwayArtifact.digest(targetInputs.namesBytes)),.init(role:"network",sha256:RailwayArtifact.digest(targetInputs.networkBytes))])
                let record = IdentityTransition.Record(payload:p,approval:.init(author:ExactValue("Synthetic author")!,reviewer:ExactValue("Synthetic reviewer")!,role:ExactValue("fixture")!,reviewedAt:ExactValue("2026-10-01T00:00:00Z")!,reference:ExactValue("invented measurement approval")!,payloadSHA256:try IdentityTransition.hash(p)))
                let request = IdentityTransition.Request(previousRegistry:oldInputs.registryBytes,targetRegistry:targetInputs.registryBytes,recordsBytes:try RailwayArtifact.encode([record]),previousHistory:nil)
                let transition = clockNS()
                _ = try await IdentityTransition.publish(request,snapshot:after,dataVersion:ExactValue("synthetic-after")!,inputs:targetInputs,previous:oldURL,output:url)
                result["transitionBuildMs"] = elapsed(transition)
                result["historyBytes"] = try Data(contentsOf:url.appendingPathComponent("history.json")).count
            }
            result["memory"] = memory()
        } else {
            result["beforeMemory"] = memory()
            let t = clockNS(), repo = try await SQLiteRailwayRepository.open(url)
            result["openMs"] = elapsed(t); result["afterOpenMemory"] = memory()
            let d0 = await repo.diagnostics(); result["afterOpenCounters"] = diagnostics(d0)
            if mode == "full" {
                let t = clockNS()
                let stations = try await repo.allStations(), lines = try await repo.allLines(), operators = try await repo.allOperators()
                result["fullLoadMs"] = elapsed(t)
                try require(stations.count == 258 * scale && lines.count == 15 * scale && operators.count == 2 * scale)
                result["loadedMemory"] = memory()
                result["counts"] = [stations.count,lines.count,operators.count]
                withExtendedLifetime((stations,lines,operators)) {}
            } else {
                let t = clockNS(), first = try await repo.stations(matching:"Invented Same")
                result["firstQueryMs"] = elapsed(t); try require(first.count == 2)
                let composed = try await repo.stations(matching:"Café"), decomposed = try await repo.stations(matching:"Cafe\u{301}")
                try require(composed.count == 1 && decomposed.count == 1 && composed[0].station.id != decomposed[0].station.id)
                try require(try await repo.stations(matching:" Alias 0 ").count == 1)
                try require(try await repo.stations(matching:"Alias 0").isEmpty)
                let metadata = try await repo.metadata(), identities = try await repo.identities()
                try require(metadata.revisions.count == (modern ? 2 : 1))
                try require(identities.filter { $0.status != .active }.count == (modern ? 1 : 0))
                result["metadataBytes"] = try RailwayArtifact.encode(metadata).count
                let q = queries(scale)
                for query in q { _ = try await repo.stations(matching:query) }
                result["primedMemory"] = memory()
                var timings: [Double] = [], memorySeries: [[String:Int64]] = [], consumed = 0
                for _ in 0..<3 {
                    for query in q { let t = clockNS(); let hits = try await repo.stations(matching:query); timings.append(elapsed(t)); consumed += hits.count }
                    memorySeries.append(memory())
                }
                timings.sort(); result["warmMedianMs"] = timings[timings.count/2]; result["warmP95Ms"] = timings[Int(Double(timings.count-1)*0.95)]
                result["warmPassMemory"] = memorySeries; result["consumedResults"] = consumed
                let d1 = await repo.diagnostics(); result["afterOrdinaryCounters"] = diagnostics(d1)
                try require(d1.artifactValidationPasses == d0.artifactValidationPasses && d1.explicitFullLoads == d0.explicitFullLoads)
                result["ordinaryPeakMemory"] = memory()
                let close = clockNS(); try await repo.close(); result["closeMs"] = elapsed(close)
                let reopen = clockNS(); let second = try await SQLiteRailwayRepository.open(url); result["reopenMs"] = elapsed(reopen)
                let again = clockNS(); let hits = try await second.stations(matching:"Invented Same"); result["reopenFirstMs"] = elapsed(again)
                try require(hits.map(\.station.id) == first.map(\.station.id)); result["reopenCounters"] = diagnostics(await second.diagnostics())
                try await second.close(); result["afterReopenMemory"] = memory()
            }
            try await repo.close()
        }
        print(String(decoding:try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys]),as:UTF8.self))
    }
}
