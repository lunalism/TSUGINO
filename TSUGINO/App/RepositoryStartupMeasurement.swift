#if REPOSITORY_STARTUP_MEASUREMENT
import Foundation
import os

/// Opt-in, non-shipping instrumentation. No artifact is bundled or installed here.
enum RepositoryStartupMeasurement {
    static func start() {
        let arguments = ProcessInfo.processInfo.arguments
        guard let position = arguments.firstIndex(of: "--repository-startup"),
              arguments.indices.contains(position + 2) else { return }
        let mode = arguments[position + 1], sample = arguments[position + 2]
        guard ["baseline", "enabled", "workload"].contains(mode),
              !sample.isEmpty, sample.utf8.allSatisfy({ (48...57).contains($0) }) else { return }
        let hook = DispatchTime.now().uptimeNanoseconds
        Task.detached(priority: .userInitiated) {
            let log = OSLog(subsystem: "com.lunalism.TSUGINO.measurement", category: "Startup")
            os_signpost(.event, log: log, name: "Startup hook", "%{public}s", mode)
            let directory = URL.documentsDirectory.appendingPathComponent("StartupMeasurement", isDirectory: true)
            var result: [String: Any] = ["mode": mode, "sample": sample, "hookUptimeNs": hook,
                                        "instrumentation": 1]
            func milliseconds(_ start: UInt64, _ end: UInt64) -> Double { Double(end - start) / 1_000_000 }
            do {
                if mode == "workload" {
                    result["workload"] = try await RepositoryDeviceMeasurement.run(directory.appendingPathComponent("railway.sqlite"))
                }
                if mode == "enabled" {
                    let start = DispatchTime.now().uptimeNanoseconds
                    os_signpost(.begin, log: log, name: "Repository open and validation")
                    let repository = try await SQLiteRailwayRepository.open(directory.appendingPathComponent("railway.sqlite"))
                    let opened = DispatchTime.now().uptimeNanoseconds
                    os_signpost(.end, log: log, name: "Repository open and validation")
                    let queryStart = DispatchTime.now().uptimeNanoseconds
                    let matches = try await repository.stations(matching: "Invented Same")
                    let ready = DispatchTime.now().uptimeNanoseconds
                    os_signpost(.event, log: log, name: "Repository first query ready")
                    let diagnostic = await repository.diagnostics()
                    guard matches.count == 2, Set(matches.map { $0.station.id }).count == 2,
                          diagnostic.artifactValidationPasses == 1, diagnostic.explicitFullLoads == 0 else {
                        throw RailwayRepositoryError.malformed
                    }
                    result["openStartAfterHookMs"] = milliseconds(hook, start)
                    result["openIncludingValidationMs"] = milliseconds(start, opened)
                    result["firstQueryMs"] = milliseconds(queryStart, ready)
                    result["readyAfterHookMs"] = milliseconds(hook, ready)
                    result["validationPasses"] = diagnostic.artifactValidationPasses
                    result["fullLoads"] = diagnostic.explicitFullLoads
                    result["matchedDistinctStations"] = matches.count
                    try await repository.close()
                }
                result["status"] = "ok"
            } catch { result["status"] = "failed" }
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                let bytes = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
                try bytes.write(to: directory.appendingPathComponent("\(mode)-\(sample).json"), options: .atomic)
            } catch { os_signpost(.event, log: log, name: "Measurement output failed") }
        }
    }
}
#endif
