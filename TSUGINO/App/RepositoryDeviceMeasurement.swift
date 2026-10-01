#if REPOSITORY_STARTUP_MEASUREMENT
import Foundation
import Darwin
import CryptoKit
import Network
import UIKit

/// Measurement-only device workload; never part of ordinary app composition.
nonisolated enum RepositoryDeviceMeasurement {
    static func clock() -> UInt64 { DispatchTime.now().uptimeNanoseconds }
    static func elapsed(_ start: UInt64) -> Double { Double(clock() - start) / 1_000_000 }
    static func require(_ value: Bool) throws { if !value { throw RailwayRepositoryError.malformed } }
    static func memory() -> [String: Int64] {
        var usage = rusage(); getrusage(RUSAGE_SELF, &usage)
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        let status = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return ["rss": status == KERN_SUCCESS ? Int64(info.resident_size) : -1, "peak": Int64(usage.ru_maxrss)]
    }
    static func digest(_ url: URL) throws -> String { SHA256.hash(data: try Data(contentsOf: url)).map { String(format: "%02x", $0) }.joined() }
    static func counters(_ d: SQLiteRailwayRepository.Diagnostics) -> [String: Int] {
        ["validationPasses": d.artifactValidationPasses, "fullLoads": d.explicitFullLoads, "stationDecodes": d.queryStationDecodes]
    }
    static func networkStatus() async -> String {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                monitor.cancel()
                continuation.resume(returning: path.status == .unsatisfied ? "unsatisfied" : path.status == .satisfied ? "satisfied" : "requiresConnection")
            }
            monitor.start(queue: DispatchQueue(label: "startup.measurement.network"))
        }
    }
    static func conditions() async -> [String: Any] {
        let battery = await MainActor.run { () -> [String: Any] in
            UIDevice.current.isBatteryMonitoringEnabled = true
            return ["batteryLevel": UIDevice.current.batteryLevel, "batteryState": UIDevice.current.batteryState.rawValue]
        }
        let storage = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        let freeBytes = (storage?[.systemFreeSize] as? NSNumber)?.int64Value ?? -1
        return ["availableStorageBytes": freeBytes, "battery": battery, "thermalState": ProcessInfo.processInfo.thermalState.rawValue,
                "lowPowerMode": ProcessInfo.processInfo.isLowPowerModeEnabled,
                "physicalMemoryBytes": ProcessInfo.processInfo.physicalMemory]
    }
    @concurrent static func run(_ url: URL) async throws -> [String: Any] {
        var result: [String: Any] = [:]
        let beforeHash = try digest(url)
        result["artifactSHA256"] = beforeHash
        result["conditionsBefore"] = await conditions()
        let networkBefore = await networkStatus(); result["networkBefore"] = networkBefore
        try require(networkBefore == "unsatisfied")
        result["beforeMemory"] = memory()
        let opened = clock(), repository = try await SQLiteRailwayRepository.open(url)
        result["openIncludingValidationMs"] = elapsed(opened)
        result["openedMemory"] = memory()
        let d0 = await repository.diagnostics(); result["openCounters"] = counters(d0)
        let start = clock(), first = try await repository.stations(matching: "Invented Same")
        result["firstQueryMs"] = elapsed(start)
        try require(first.count == 2 && Set(first.map { $0.station.id }).count == 2)
        try require(first.map { $0.station.id.rawValue } == first.map { $0.station.id.rawValue }.sorted())
        let composed = try await repository.stations(matching: "Café")
        let decomposed = try await repository.stations(matching: "Cafe\u{301}")
        try require(composed.count == 1 && decomposed.count == 1 && composed[0].station.id != decomposed[0].station.id)
        try require(try await repository.stations(matching: " Alias 0 ").map { $0.station.id } == composed.map { $0.station.id })
        try require(try await repository.stations(matching: "Alias 0").isEmpty)
        let metadata = try await repository.metadata(), identities = try await repository.identities()
        result["revisionCount"] = metadata.revisions.count
        result["retiredCount"] = identities.filter { $0.status != .active }.count
        let queries = (0..<1024).map { i -> String in
            switch i % 8 {
            case 0: return "Invented Same"
            case 1: return "Café"
            case 2: return "Cafe\u{301}"
            case 3: return " Alias \(i % 6) "
            case 4: return "Invented EN \(2 + (i * 17) % 256)"
            case 5: return "Invented KO \(2 + (i * 23) % 256)"
            case 6: return "missing"
            default: return "Alias 0"
            }
        }
        for query in queries { _ = try await repository.stations(matching: query) }
        result["primedMemory"] = memory()
        var timings: [Double] = [], snapshots: [[String: Int64]] = [], consumed = 0
        for _ in 0..<3 {
            for query in queries {
                let t = clock(), hits = try await repository.stations(matching: query)
                timings.append(elapsed(t)); consumed += hits.count
            }
            snapshots.append(memory())
        }
        timings.sort()
        result["warmMedianMs"] = timings[timings.count / 2]
        result["warmP95Ms"] = timings[Int(Double(timings.count - 1) * 0.95)]
        result["warmPassMemory"] = snapshots; result["consumedResults"] = consumed
        let d1 = await repository.diagnostics(); result["afterOrdinaryCounters"] = counters(d1)
        try require(consumed == 2688 && d0.artifactValidationPasses == 1 && d1.artifactValidationPasses == 1 && d1.explicitFullLoads == 0)
        let close = clock(); try await repository.close(); result["closeMs"] = elapsed(close)
        let reopen = clock(), second = try await SQLiteRailwayRepository.open(url)
        result["reopenMs"] = elapsed(reopen)
        try require(try await second.stations(matching: "Invented Same").map { $0.station.id } == first.map { $0.station.id })
        result["reopenCounters"] = counters(await second.diagnostics())
        let load = clock()
        let stations = try await second.allStations(), lines = try await second.allLines(), operators = try await second.allOperators()
        result["fullDomainLoadMs"] = elapsed(load)
        try require(stations.count == 258 && lines.count == 15 && operators.count == 2)
        result["fullLoadMemory"] = memory()
        withExtendedLifetime((stations, lines, operators)) {}
        try await second.close()
        let networkAfter = await networkStatus(); result["networkAfter"] = networkAfter
        try require(networkAfter == "unsatisfied" && digest(url) == beforeHash)
        result["conditionsAfter"] = await conditions()
        result["exactSearchChecks"] = "passed"
        return result
    }
}
#endif
