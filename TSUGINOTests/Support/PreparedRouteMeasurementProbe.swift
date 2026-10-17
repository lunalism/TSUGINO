#if DEBUG
import CryptoKit
import Foundation
import Synchronization
import Testing
@testable import TSUGINO

/// Consumer §30.6 instrumentation, test target only. Composition-hook marks go into a
/// preallocated lock-protected buffer: no actor hop and no suspension inside the hook.
final class PRSStageTrace: Sendable {
    struct Mark: Sendable {
        let stage: PreparedRouteSearchStage
        let at: ContinuousClock.Instant
        let cancelled: Bool
    }
    private let marks = Mutex<[Mark]>([])
    private let solverLast = Mutex<(InternalSolverStage, InternalSolverUsage)?>(nil)
    private let solverStages = Mutex<[(InternalSolverStage, ContinuousClock.Instant)]>([])
    init() { marks.withLock { $0.reserveCapacity(16) } }
    func mark(_ stage: PreparedRouteSearchStage) {
        let m = Mark(stage: stage, at: .now, cancelled: Task.isCancelled)
        marks.withLock { $0.append(m) }
    }
    func solver(_ stage: InternalSolverStage, _ usage: InternalSolverUsage) {
        let now = ContinuousClock.now
        solverLast.withLock { $0 = (stage, usage) }
        // tieCollection is entered at every destination-reaching prefix; keep first entries only.
        solverStages.withLock { s in if s.last?.0 != stage { s.append((stage, now)) } }
    }
    var all: [Mark] { marks.withLock { $0 } }
    var last: (InternalSolverStage, InternalSolverUsage)? { solverLast.withLock { $0 } }
    var solverEntries: [(InternalSolverStage, ContinuousClock.Instant)] { solverStages.withLock { $0 } }
}

final class PRSBox<T: Sendable>: Sendable {
    private let value: Mutex<T>
    init(_ v: T) { value = Mutex(v) }
    func set(_ v: T) { value.withLock { $0 = v } }
    func get() -> T { value.withLock { $0 } }
}

enum PRSProbe {
    static func ns(_ d: Duration) -> Int64 {
        let c = d.components
        return c.seconds * 1_000_000_000 + c.attoseconds / 1_000_000_000
    }
    /// `task_info(TASK_VM_INFO)`: instantaneous `phys_footprint` and, where the returned
    /// count covers it, the process-lifetime `ledger_phys_footprint_peak`.
    static func footprint() -> (current: Int64?, peak: Int64?) {
        var info = task_vm_info_data_t()
        let capacity = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size
        var count = mach_msg_type_number_t(capacity)
        let kr = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: capacity) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return (nil, nil) }
        func covers<V>(_ path: KeyPath<task_vm_info_data_t, V>) -> Bool {
            guard let offset = MemoryLayout<task_vm_info_data_t>.offset(of: path) else { return false }
            return Int(count) * MemoryLayout<natural_t>.size >= offset + MemoryLayout<V>.size
        }
        return (covers(\.phys_footprint) ? Int64(info.phys_footprint) : nil,
                covers(\.ledger_phys_footprint_peak) ? Int64(info.ledger_phys_footprint_peak) : nil)
    }
    /// Process-wide `getrusage(RUSAGE_SELF)`; not per thread. `ru_maxrss` is bytes on Darwin.
    static func usage() -> (user: Int64, system: Int64, maxrss: Int64) {
        var r = rusage()
        getrusage(RUSAGE_SELF, &r)
        func ns(_ t: timeval) -> Int64 { Int64(t.tv_sec) * 1_000_000_000 + Int64(t.tv_usec) * 1_000 }
        return (ns(r.ru_utime), ns(r.ru_stime), Int64(r.ru_maxrss))
    }
    static var thermal: String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: "nominal"
        case .fair: "fair"
        case .serious: "serious"
        case .critical: "critical"
        @unknown default: "unknown"
        }
    }
    static let memoryGuard: Int64 = 2 * 1_024 * 1_024 * 1_024
}

/// One bounded JSON line per record (`PRS_MEASURE {json}`), appended to the driver's file.
final class PRSEmitter: @unchecked Sendable {
    private let handle: FileHandle?
    private let inflight: String?
    let common: [String: Any]
    init(environment: [String: String]) {
        if let path = environment["TSUGINO_PRS_OUT"] {
            if !FileManager.default.fileExists(atPath: path) { FileManager.default.createFile(atPath: path, contents: nil) }
            handle = FileHandle(forWritingAtPath: path)
            handle?.seekToEndOfFile()
        } else { handle = nil }
        inflight = environment["TSUGINO_PRS_INFLIGHT"]
        common = ["schema": 1, "runID": environment["TSUGINO_PRS_RUN"] ?? "local",
                  "variant": environment["TSUGINO_PRS_VARIANT"] ?? "unlabelled",
                  "pass": environment["TSUGINO_PRS_PASS"] ?? "none"]
    }
    func emit(_ fields: [String: Any]) {
        var record = common.merging(fields) { _, new in new }
        record["utc"] = ISO8601DateFormatter().string(from: Date())
        record["thermalState"] = PRSProbe.thermal
        guard let data = try? JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]),
              let json = String(data: data, encoding: .utf8) else { return }
        let line = "PRS_MEASURE " + json
        print(line)
        handle?.write(Data((line + "\n").utf8))
    }
    /// Overwritten marker so the driver can attribute a forced kill (class H).
    func inFlight(_ text: String) {
        guard let inflight else { return }
        try? Data(text.utf8).write(to: URL(fileURLWithPath: inflight))
    }
}

/// Outcome of one harness-owned search call (§30.6 M1/M4/M5).
struct PRSCall {
    var outcome = "U"          // C, R, I, X, W, U
    var failure: String?
    var identities: [[String]]?
    var noResults = false
    var omissions = 0
    var start: ContinuousClock.Instant
    var end: ContinuousClock.Instant
    var cpuUser: Int64 = 0
    var cpuSystem: Int64 = 0
    var watchdogFired = false
    /// The terminal value, retained only until the caller releases it (M7 "after return").
    var raw: Result<RouteSearchResult, any Error>?
    var wholeNs: Int64 { PRSProbe.ns(start.duration(to: end)) }

    var digest: String? {
        guard let identities else { return nil }
        let text = identities.map { $0.joined(separator: " ") }.joined(separator: "\n")
        return SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

enum PRSHarness {
    /// Ride-key identities of a completed result; never partial (only from a terminal success).
    static func identities(_ result: RouteSearchResult) -> (ids: [[String]], noResults: Bool, omissions: Int)? {
        guard case let .internalSuccess(success) = result else { return nil }
        switch success.outcome {
        case .noResults: return ([], true, 0)
        case let .alternatives(batch):
            var out: [[String]] = []
            for route in batch.candidates {
                var keys: [String] = []
                for leg in route.legs {
                    guard case let .rail(rail) = leg else { continue }
                    guard case let .matched(train) = rail.travel, case let .timetable(context) = rail.scheduledContext else { return nil }
                    let a = context.binding.address
                    keys.append("\(a.tripID.rawValue)/\(a.serviceDate.label)/\(train.boardingIndex)-\(train.alightingIndex)")
                }
                out.append(keys)
            }
            return (out, false, batch.omissions.count)
        }
    }

    static func failureLabel(_ f: RouteSearchFailure) -> String {
        switch f {
        case let .invalidEndpoint(role, reason): "invalidEndpoint \(role) \(reason)"
        case .unsupportedRequest: "unsupportedRequest"
        case .dataUnavailable: "dataUnavailable"
        case .configurationUnavailable: "configurationUnavailable"
        case .searchIncomplete: "searchIncomplete"
        case .noUsableAlternatives: "noUsableAlternatives"
        case .providerUnavailable: "providerUnavailable"
        case .rateLimited: "rateLimited"
        case .malformedResponse: "malformedResponse"
        }
    }

    /// Harness-owned task plus an elapsed-time watchdog that only cancels (class W); elapsed
    /// time never certifies completion. The watchdog cannot interrupt synchronous constructors.
    static func call(_ searcher: PreparedRouteSearcher, _ request: RouteSearchRequest, watchdog: Duration,
                     onTask: (@Sendable (Task<RouteSearchResult, any Error>) -> Void)? = nil) async -> PRSCall {
        let fired = PRSBox(false)
        let u0 = PRSProbe.usage()
        let start = ContinuousClock.now
        let task = Task { try await searcher.search(request) }
        onTask?(task)
        let dog = Task {
            try await Task.sleep(for: watchdog)
            fired.set(true)
            task.cancel()
        }
        let result = await task.result
        let end = ContinuousClock.now
        dog.cancel()
        let u1 = PRSProbe.usage()
        var call = PRSCall(start: start, end: end)
        call.cpuUser = u1.user - u0.user; call.cpuSystem = u1.system - u0.system
        call.watchdogFired = fired.get()
        call.raw = result
        switch result {
        case let .success(value):
            if let ids = identities(value) {
                call.outcome = "C"; call.identities = ids.ids; call.noResults = ids.noResults; call.omissions = ids.omissions
            } else { call.outcome = "U"; call.failure = "noncanonical success" }
        case let .failure(error):
            if error is CancellationError { call.outcome = call.watchdogFired ? "W" : "X"; call.failure = "CancellationError" }
            else if let f = error as? RouteSearchFailure {
                call.failure = failureLabel(f)
                if case .searchIncomplete = f { call.outcome = "I" } else { call.outcome = "R" }
            } else { call.outcome = "U"; call.failure = "noncanonical \(error)" }
        }
        return call
    }

    static func stageNs(_ marks: [PRSStageTrace.Mark], start: ContinuousClock.Instant) -> [String: Int64] {
        var out: [String: Int64] = [:]
        guard let first = marks.first else { return out }
        out["hop"] = PRSProbe.ns(start.duration(to: first.at))
        for (a, b) in zip(marks, marks.dropFirst()) { out["\(b.stage)"] = PRSProbe.ns(a.at.duration(to: b.at)) }
        if let s = marks.firstIndex(where: { $0.stage == .scope }), let p = marks.firstIndex(where: { $0.stage == .preparedInput }) {
            out["preparation"] = PRSProbe.ns(marks[s].at.duration(to: marks[p].at))
        }
        return out
    }

    /// Fine class (§30.8) from a hooked call: I-prep vs I-solver by the last checkpoint reached.
    static func fineClass(_ call: PRSCall, last: PreparedRouteSearchStage?) -> String {
        guard call.outcome == "I" else { return call.outcome }
        return last == .preparedInput ? "I-solver" : "I-prep"
    }

    /// Structural pass (§30.6 M6), outside timed calls: S5–S8 one stage at a time.
    struct Structural {
        var fields: [String: Any] = [:]
        var prepared: PreparedInternalSearchInput?
        var assessmentBytes: Int?
        var failedAt: String?
    }
    static func structural(_ c: PreparedRouteFixture.Case) -> Structural {
        var s = Structural()
        let view = c.view
        s.fields["slots"] = view.inventory.slots.count
        s.fields["inventoryBytes"] = view.inventory.logicalPayloadBytes
        guard let scope = InternalSearchScope(profile: c.profile, request: c.request, viewID: view.id) else {
            s.failedAt = "scope"; s.fields["failedAt"] = "scope"; return s
        }
        let declarations: PreparedRouteDeclarations
        do { declarations = try PreparedRouteDeclarationProducer.declarations(view: view, scope: scope) }
        catch { s.failedAt = "declarations \(error)"; s.fields["failedAt"] = s.failedAt; return s }
        s.fields["occurrences"] = declarations.occurrences.required.count
        s.fields["intervals"] = declarations.occurrences.required.reduce(0) { $0 + $1.intervals.count }
        s.fields["targets"] = declarations.connections.required.count
        let closure: RequestScopedSearchInputClosure
        do {
            closure = try RequestScopedSearchInputClosure(scope: scope, inventory: view.inventory, railway: view.railway,
                occurrences: declarations.occurrences, connections: declarations.connections, dependencies: declarations.dependencies)
        } catch { s.failedAt = "closure \(error)"; s.fields["failedAt"] = s.failedAt; return s }
        s.fields["closureBytes"] = closure.logicalPayloadBytes
        let evidence: QualifiedConnectionEvidenceView
        do { evidence = try PreparedRouteConnectionEvidenceProducer.evidence(view: view, closure: closure) }
        catch { s.failedAt = "evidence \(error)"; s.fields["failedAt"] = s.failedAt; return s }
        let assessment: ResolvedSearchInputAssessment
        do { assessment = try ResolvedSearchInputAssessment(closure: closure, connections: evidence) }
        catch { s.failedAt = "assessment \(error)"; s.fields["failedAt"] = s.failedAt; return s }
        s.assessmentBytes = assessment.logicalPayloadBytes
        s.fields["assessmentBytes"] = assessment.logicalPayloadBytes
        s.fields["remainingHolds"] = assessment.remainingHolds.count
        do {
            let p = try PreparedInternalSearchInput(assessment: assessment, objective: .init(reference: PreparedRouteFixture().objective))
            s.prepared = p
            s.fields["rides"] = p.rides.count
            s.fields["preparedBytes"] = p.logicalPayloadBytes
            var states: [String: Int] = [:]
            for r in p.connections { states["\(r.state)", default: 0] += 1 }
            s.fields["relationsByState"] = states
        } catch { s.failedAt = "preparedInput \(error)"; s.fields["failedAt"] = s.failedAt }
        return s
    }

    static func usageFields(_ last: (InternalSolverStage, InternalSolverUsage)?) -> [String: Any]? {
        guard let (stage, u) = last else { return nil }
        return ["work": u.work, "slots": u.retainedSlots, "keys": u.identityKeys, "bytes": u.logicalBytes, "observedAt": "\(stage)"]
    }

    /// Correctness of a completed or cut-off outcome against the analytic expectation.
    /// Returns nil when admissible, else the mismatch reason (class U).
    static func check(_ expectation: PreparedRouteWorkload.Expectation, fine: String, call: PRSCall,
                      last: PreparedRouteSearchStage?) -> String? {
        switch expectation {
        case let .success(ids):
            guard fine == "C" else { return "expected C, got \(fine) \(call.failure ?? "")" }
            return call.identities == ids ? nil : "identity mismatch"
        case let .successOrSolverCutoff(ids):
            if fine == "I-solver" { return nil }
            guard fine == "C" else { return "expected C or I-solver, got \(fine) \(call.failure ?? "")" }
            return call.identities == ids ? nil : "identity mismatch"
        case .solverCutoff:
            return fine == "I-solver" ? nil : "expected I-solver, got \(fine) \(call.failure ?? "")"
        case let .preparationCutoff(stage):
            guard fine == "I-prep" else { return "expected I-prep, got \(fine) \(call.failure ?? "")" }
            return last == stage ? nil : "expected last checkpoint \(stage), got \(last.map { "\($0)" } ?? "none")"
        }
    }
}
#endif
