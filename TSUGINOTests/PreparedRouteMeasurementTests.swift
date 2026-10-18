#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Consumer §30 measurement passes. DISABLED unless the driver sets TSUGINO_PRS_MEASURE=1
/// (passed as TEST_RUNNER_TSUGINO_PRS_MEASURE). Invented data only; serial execution.
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["TSUGINO_PRS_MEASURE"] == "1"))
struct PreparedRouteMeasurementTests {
    @Test func measure() async {
        let f0 = PRSProbe.footprint() // M7 F0: before any fixture exists
        await PRSRunner(environment: ProcessInfo.processInfo.environment, f0: f0).run()
    }
}

final class PRSRunner {
    let env: [String: String]
    let emitter: PRSEmitter
    let p = PreparedRouteFixture()
    let pass: String
    let watchdog: Duration
    let budget: Int
    let deadline: Date
    let f0: (current: Int64?, peak: Int64?)
    var calls = 0
    var stopped = false
    /// Searcher construction for the memory and cancel passes. The driver always uses the
    /// default; `PreparedRouteHarnessFaultTests` replaces it to inject faults (test target only).
    let makeSearcher: (PreparedRouteFixture.Case, PreparedRouteSearchTestHooks?) -> PreparedRouteSearcher

    init(environment: [String: String], f0: (current: Int64?, peak: Int64?),
         makeSearcher: ((PreparedRouteFixture.Case, PreparedRouteSearchTestHooks?) -> PreparedRouteSearcher)? = nil) {
        env = environment
        emitter = PRSEmitter(environment: environment)
        pass = environment["TSUGINO_PRS_PASS"] ?? "none"
        watchdog = .seconds(Int(environment["TSUGINO_PRS_WATCHDOG"] ?? "") ?? 60)
        budget = Int(environment["TSUGINO_PRS_CALL_BUDGET"] ?? "") ?? 0
        deadline = Date(timeIntervalSince1970: Double(environment["TSUGINO_PRS_DEADLINE"] ?? "") ?? 0)
        self.f0 = f0
        let p = self.p
        self.makeSearcher = makeSearcher ?? { c, hooks in
            hooks.map { p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: $0) }
                ?? p.searcher(c, InventedPreparedRouteViewSupplier(c.view))
        }
    }

    func run() async {
        switch pass {
        case "discovery": await discovery()
        case "reference", "timing", "stage": await timed()
        case "memory": await memory()
        case "cancel": await cancel()
        default: emitter.emit(["kind": "stop", "reason": "unknown pass \(pass)"])
        }
        emitter.inFlight("")
        emitter.emit(["kind": "end", "calls": calls, "stopped": stopped])
    }

    /// §30.5 call-count and wall-time ceilings, checked before every search call.
    func admit(_ id: String) -> Bool {
        guard !stopped else { return false }
        guard calls < budget, Date() < deadline else {
            emitter.emit(["kind": "stop", "reason": calls >= budget ? "call envelope exhausted" : "wall-clock envelope exhausted",
                          "caseID": id])
            stopped = true
            return false
        }
        calls += 1
        emitter.inFlight(id)
        return true
    }
    func memoryGuard(_ id: String) -> Bool {
        if let current = PRSProbe.footprint().current, current > PRSProbe.memoryGuard {
            emitter.emit(["kind": "stop", "reason": "memory guard phys_footprint \(current) > 2 GiB", "caseID": id])
            return true
        }
        return false
    }

    // MARK: Workload lookup

    var group: String { env["TSUGINO_PRS_GROUP"] ?? "" }
    /// "id=class,id=class" from the discovery pass.
    var admitted: [(String, String)] {
        (env["TSUGINO_PRS_CASES"] ?? "").split(separator: ",").compactMap { item in
            let parts = item.split(separator: "=")
            return parts.count == 2 ? (String(parts[0]), String(parts[1])) : nil
        }
    }
    func workload(_ id: String, cls: String) -> PreparedRouteWorkload? {
        if id.hasPrefix("W7p-"), let n = Int(id.dropFirst(4)) { return PreparedRouteWorkloads.w7p(n, over: cls == "I-prep") }
        return PreparedRouteWorkloads.matrix.first { $0.id == id }
    }
    func expectedIdentities(_ w: PreparedRouteWorkload) -> [[String]]? {
        switch w.expectation {
        case let .success(ids), let .successOrSolverCutoff(ids): ids
        default: nil
        }
    }
    func base(_ w: PreparedRouteWorkload) -> [String: Any] {
        var r: [String: Any] = ["caseID": w.id, "family": w.group, "size": w.size]
        if let seed = w.seed { r["seed"] = String(seed, radix: 16) }
        return r
    }
    func callFields(_ call: PRSCall) -> [String: Any] {
        var r: [String: Any] = ["wholeNs": call.wholeNs, "cpuUserNs": call.cpuUser, "cpuSystemNs": call.cpuSystem,
                                "watchdogFired": call.watchdogFired]
        if let failure = call.failure { r["failure"] = failure }
        if call.outcome == "C" {
            r["winners"] = call.identities?.count ?? 0; r["omissions"] = call.omissions; r["noResults"] = call.noResults
            r["winnerDigest"] = call.digest
        }
        return r
    }
    func hooks(_ trace: PRSBox<PRSStageTrace>, solver: Bool) -> PreparedRouteSearchTestHooks {
        PreparedRouteSearchTestHooks(checkpoint: { trace.get().mark($0) },
            solver: solver ? .init(checkpoint: { trace.get().solver($0, $1) }, claim: nil, brokenSharedRelationIndex: nil) : nil)
    }

    // MARK: Discovery (V-D): structural pre-check, correctness, one diagnostic call

    func discovery() async {
        // Optional explicit case list (§32 matched protocol); otherwise the whole group.
        let only = (env["TSUGINO_PRS_ONLY"] ?? "").split(separator: ",").map(String.init)
        var list = PreparedRouteWorkloads.matrix.filter { only.isEmpty ? $0.group == group : only.contains($0.id) }
        if only.isEmpty, group == "W7" { list += payloadPrecheck() }
        var ladder: [String: Int] = [:]
        for w in list {
            if stopped { return }
            if let l = w.ladder, let remaining = ladder[l], remaining <= 0, !w.alwaysRuns {
                emitter.emit(base(w).merging(["kind": "skip", "reason": "family stop (§30.5) in \(l)"]) { $1 }); continue
            }
            let t0 = ContinuousClock.now
            let c: PreparedRouteFixture.Case
            do { c = try w.build(p) } catch {
                emitter.emit(base(w).merging(["kind": "sample", "class": "S", "failure": "setup \(error)"]) { $1 })
                if let l = w.ladder { ladder[l] = 0 }
                continue
            }
            let setupNs = PRSProbe.ns(t0.duration(to: .now))
            let s = PRSHarness.structural(c)
            var oracle: [[String]]?
            if let prepared = s.prepared, prepared.rides.count <= 16 {
                oracle = ExhaustivePreparedSolverOracle().winners(prepared).map { keys in
                    keys.map { "\($0.address.tripID.rawValue)/\($0.address.serviceDate.label)/\($0.boardingIndex)-\($0.alightingIndex)" }
                }
            }
            guard admit(w.id) else { return }
            let trace = PRSBox(PRSStageTrace())
            let searcher = p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: hooks(trace, solver: true))
            let call = await PRSHarness.call(searcher, c.request, watchdog: watchdog)
            let marks = trace.get().all
            let last = marks.last?.stage
            let fine = PRSHarness.fineClass(call, last: last)
            var mismatch = fine == "W" ? nil : PRSHarness.check(w.expectation, fine: fine, call: call, last: last)
            if mismatch == nil, fine == "C", let oracle, oracle != call.identities { mismatch = "exhaustive oracle mismatch" }
            if mismatch == nil, let projected = w.projected,
               s.fields["occurrences"] as? Int != projected.occurrences || s.fields["targets"] as? Int != projected.targets {
                mismatch = "projection counts"
            }
            var record = base(w).merging(callFields(call)) { $1 }
            record["kind"] = "sample"; record["repetition"] = 0; record["warmup"] = false
            record["class"] = mismatch == nil ? fine : "U"
            record["observedClass"] = fine
            if let mismatch { record["mismatch"] = mismatch }
            record["lastCheckpoint"] = last.map { "\($0)" }
            record["stageNs"] = PRSHarness.stageNs(marks, start: call.start)
            record["solverUsage"] = PRSHarness.usageFields(trace.get().last)
            record["solverStageEntryNs"] = Dictionary(trace.get().solverEntries.map { ("\($0.0)", PRSProbe.ns(call.start.duration(to: $0.1))) }) { a, _ in a }
            record["structural"] = s.fields
            record["setupNs"] = setupNs
            record["oracle"] = oracle == nil ? "analytic" : "analytic+exhaustive"
            emitter.emit(record)
            if mismatch != nil {
                emitter.emit(["kind": "stop", "reason": "class U at \(w.id): \(mismatch!)"]); stopped = true; return
            }
            if let l = w.ladder, !w.alwaysRuns {
                if fine == "W" { ladder[l] = 0 }
                else if let remaining = ladder[l] { ladder[l] = remaining - 1 }
                else if fine == "I-solver" { ladder[l] = 1 }
            }
            if memoryGuard(w.id) { stopped = true; return }
        }
    }

    /// §30.3 W7p structural pre-check: find the exact 96,000,000-byte crossing from actual
    /// constructor values; include the pair only if every upstream constructor succeeds.
    func payloadPrecheck() -> [PreparedRouteWorkload] {
        func measure(_ n: Int) -> PRSHarness.Structural? {
            guard let c = try? PreparedRouteWorkloads.w7p(n, over: false).build(p) else { return nil }
            return PRSHarness.structural(c)
        }
        let cap = PreparedInputLimits.logicalPayloadBytes
        var record: [String: Any] = ["kind": "precheck", "caseID": "W7p"]
        defer { emitter.emit(record) }
        guard let one = measure(1)?.assessmentBytes, let two = measure(2)?.assessmentBytes, two > one else {
            record["included"] = false; record["reason"] = "small W7p shapes not constructible"; return []
        }
        var n = 1 + (cap - one) / (two - one) + 1
        record["perSlotBytes"] = two - one; record["predictedOver"] = n
        for _ in 0..<8 {
            guard let s = measure(n), let bytes = s.assessmentBytes else { break }
            if bytes <= cap { n += 1; continue }
            guard let below = measure(n - 1), let belowBytes = below.assessmentBytes else { break }
            if belowBytes > cap { n -= 1; continue }
            record["under"] = ["slots": n - 1, "assessmentBytes": belowBytes, "failedAt": below.failedAt ?? "none",
                               "preparedBytes": below.fields["preparedBytes"] ?? NSNull()]
            record["over"] = ["slots": n, "assessmentBytes": bytes, "failedAt": s.failedAt ?? "none"]
            let underOK = below.prepared != nil
            let overOK = s.failedAt == "preparedInput resourceLimit"
            record["included"] = underOK && overOK
            if underOK && overOK {
                return [PreparedRouteWorkloads.w7p(n - 1, over: false), PreparedRouteWorkloads.w7p(n, over: true)]
            }
            record["reason"] = underOK ? "over side did not fail exactly at P resourceLimit" : "under side P did not construct"
            return []
        }
        record["included"] = false; record["reason"] = record["reason"] ?? "crossing not reached by constructible inputs"
        return []
    }

    // MARK: Timed passes: V-D reference (1+3), V-O whole-call (1+7), V-O stage (1+5)

    func timed() async {
        let reps = Int(env["TSUGINO_PRS_REPS"] ?? "") ?? (pass == "reference" ? 3 : pass == "timing" ? 7 : 5)
        let staged = pass == "stage"
        struct Item { let w: PreparedRouteWorkload; let cls: String; let c: PreparedRouteFixture.Case; let trace: PRSBox<PRSStageTrace>
                      let searcher: PreparedRouteSearcher; var dead = false }
        var items: [Item] = []
        for (id, cls) in admitted {
            guard let w = workload(id, cls: cls) else { emitter.emit(["kind": "skip", "caseID": id, "reason": "unknown case"]); continue }
            do {
                let c = try w.build(p)
                let trace = PRSBox(PRSStageTrace())
                let supplier = InventedPreparedRouteViewSupplier(c.view)
                let searcher = staged ? p.searcher(c, supplier, hooks: hooks(trace, solver: false)) : p.searcher(c, supplier)
                items.append(Item(w: w, cls: cls, c: c, trace: trace, searcher: searcher))
            } catch { emitter.emit(base(w).merging(["kind": "sample", "class": "S", "failure": "setup \(error)"]) { $1 }) }
        }
        for warm in [true, false] {
            for r in 0..<(warm ? 1 : reps) {
                for k in 0..<items.count {
                    let i = (k + r) % items.count
                    if items[i].dead { continue }
                    guard admit(items[i].w.id) else { return }
                    let item = items[i]
                    item.trace.set(PRSStageTrace())
                    let call = await PRSHarness.call(item.searcher, item.c.request, watchdog: watchdog)
                    let marks = item.trace.get().all
                    let observed = staged ? PRSHarness.fineClass(call, last: marks.last?.stage) : call.outcome
                    var cls = observed
                    var mismatch: String?
                    switch (item.cls, call.outcome) {
                    case ("C", "C"): if call.identities != expectedIdentities(item.w) { mismatch = "identity mismatch" }
                    case (let d, "I") where d.hasPrefix("I-"):
                        if staged, observed != d { mismatch = "stage class \(observed) != discovery \(d)" } else { cls = d }
                    case ("R", "R"): break
                    case (_, "W"): break
                    default: mismatch = "class \(call.outcome) != discovery \(item.cls)"
                    }
                    var record = base(item.w).merging(callFields(call)) { $1 }
                    record["kind"] = "sample"; record["repetition"] = warm ? -1 : r; record["warmup"] = warm
                    record["class"] = mismatch == nil ? cls : "U"
                    if let mismatch { record["mismatch"] = mismatch }
                    if staged {
                        record["stageNs"] = PRSHarness.stageNs(marks, start: call.start)
                        record["lastCheckpoint"] = marks.last.map { "\($0.stage)" }
                    }
                    emitter.emit(record)
                    if let mismatch { emitter.emit(["kind": "stop", "reason": "class U at \(item.w.id): \(mismatch)"]); stopped = true; return }
                    if call.outcome == "W" { items[i].dead = true; emitter.emit(base(item.w).merging(["kind": "skip", "reason": "watchdog stop; remaining samples skipped"]) { $1 }) }
                    if memoryGuard(item.w.id) { stopped = true; return }
                }
            }
        }
    }

    // MARK: Memory (V-O, fresh process per case, 1 + 3 calls)

    func memory() async {
        guard let (id, cls) = admitted.first, let w = workload(id, cls: cls) else {
            emitter.emit(["kind": "stop", "reason": "no memory case"]); return
        }
        let c: PreparedRouteFixture.Case
        do { c = try w.build(p) } catch {
            emitter.emit(base(w).merging(["kind": "sample", "class": "S", "failure": "setup \(error)"]) { $1 }); return
        }
        let searcher = makeSearcher(c, nil)
        let f1 = PRSProbe.footprint()
        for rep in -1..<3 {
            guard admit(w.id) else { return }
            let before = PRSProbe.footprint()
            let sampled = PRSBox<Int64>(0)
            var sampler: Task<Void, Never>?
            if before.peak == nil {
                sampler = Task.detached {
                    while !Task.isCancelled {
                        if let v = PRSProbe.footprint().current, v > sampled.get() { sampled.set(v) }
                        try? await Task.sleep(for: .milliseconds(1))
                    }
                }
            }
            var call = await PRSHarness.call(searcher, c.request, watchdog: watchdog)
            sampler?.cancel()
            let after = PRSProbe.footprint() // completed result still retained in `call.raw`
            call.raw = nil
            let released = PRSProbe.footprint()
            var mismatch: String?
            if call.outcome != "W", cls == "C" ? (call.outcome != "C" || call.identities != expectedIdentities(w))
                                               : (cls.hasPrefix("I-") ? call.outcome != "I" : call.outcome != cls) {
                mismatch = "class \(call.outcome) != discovery \(cls)"
            }
            var record = base(w).merging(callFields(call)) { $1 }
            record["kind"] = "sample"; record["repetition"] = rep; record["warmup"] = rep < 0
            record["class"] = mismatch == nil ? (cls.hasPrefix("I-") && call.outcome == "I" ? cls : call.outcome) : "U"
            if let mismatch { record["mismatch"] = mismatch }
            let peakMethod = after.peak != nil ? "ledger_phys_footprint_peak (process lifetime)" : "sampled 1 ms task (may miss spikes)"
            record["memory"] = ["f0": f0.current ?? NSNull(), "f1": f1.current ?? NSNull(), "before": before.current ?? NSNull(),
                                "after": after.current ?? NSNull(), "released": released.current ?? NSNull(),
                                "peak": after.peak ?? (sampled.get() > 0 ? sampled.get() : NSNull() as Any),
                                "peakMethod": peakMethod, "maxrss": PRSProbe.usage().maxrss] as [String: Any]
            emitter.emit(record)
            if let mismatch { emitter.emit(["kind": "stop", "reason": "class U at \(w.id): \(mismatch)"]); stopped = true; return }
            if memoryGuard(w.id) || call.outcome == "W" { return }
        }
    }

    // MARK: Cancellation (§30.6 M8)

    enum CancelMode { case delayed(after: PreparedRouteSearchStage, delay: Duration), boundary(PreparedRouteSearchStage) }

    func cancel() async {
        // "W7o-2880:closure=123;evidence=4|W2a-08:solve=99" (M2 medians in ns)
        var medians: [String: [String: Int64]] = [:]
        for carrier in (env["TSUGINO_PRS_MEDIANS"] ?? "").split(separator: "|") {
            let parts = carrier.split(separator: ":")
            guard parts.count == 2 else { continue }
            medians[String(parts[0])] = Dictionary(uniqueKeysWithValues: parts[1].split(separator: ";").compactMap { kv in
                let x = kv.split(separator: "="); return x.count == 2 ? (String(x[0]), Int64(x[1]) ?? 0) : nil })
        }
        let classes = Dictionary(admitted, uniquingKeysWith: { a, _ in a })
        var plan: [(String, String, CancelMode, Double, Int)] = []
        let stages = PreparedRouteSearchStage.allCases
        for target in [PreparedRouteSearchStage.closure, .evidence, .assessment, .preparedInput] {
            let previous = stages[stages.firstIndex(of: target)! - 1]
            for delta in [0.1, 0.5, 0.9] { for r in 0..<5 {
                let d = Double(medians["W7o-2880"]?["\(target)"] ?? 0) * delta
                plan.append(("W7o-2880", "\(target)", .delayed(after: previous, delay: .nanoseconds(Int64(d))), delta, r))
            } }
        }
        for carrier in ["W2a-08", "W1-0256"] {
            for delta in [0.1, 0.5, 0.9] { for r in 0..<5 {
                let d = Double(medians[carrier]?["solve"] ?? 0) * delta
                plan.append((carrier, "solve", .delayed(after: .preparedInput, delay: .nanoseconds(Int64(d))), delta, r))
            } }
        }
        for stage in stages { for r in 0..<3 { plan.append(("W2a-03", "\(stage)", .boundary(stage), 0, r)) } }

        var built: [String: PreparedRouteFixture.Case] = [:]
        for carrier in Set(plan.map(\.0)) {
            guard let cls = classes[carrier], let w = workload(carrier, cls: cls) else {
                emitter.emit(["kind": "skip", "caseID": carrier, "reason": "carrier not admitted by discovery"]); continue
            }
            if carrier != "W2a-03", medians[carrier] == nil {
                emitter.emit(["kind": "skip", "caseID": carrier, "reason": "no M2 stage medians"]); continue
            }
            do { built[carrier] = try w.build(p) } catch {
                emitter.emit(["kind": "sample", "caseID": carrier, "class": "S", "failure": "setup \(error)"])
            }
        }
        for (carrier, target, mode, delta, r) in plan {
            guard let c = built[carrier] else { continue }
            guard admit(carrier) else { return }
            let trace = PRSStageTrace()
            let taskBox = PRSBox<Task<RouteSearchResult, any Error>?>(nil)
            let request = PRSBox<ContinuousClock.Instant?>(nil)
            let canceller = PRSBox<Task<Void, Never>?>(nil)
            let hooks = PreparedRouteSearchTestHooks(checkpoint: { stage in
                if case let .boundary(k) = mode, stage == k {
                    request.set(.now)
                    withUnsafeCurrentTask { $0?.cancel() }
                }
                trace.mark(stage)
                if case let .delayed(after, delay) = mode, stage == after {
                    canceller.set(Task.detached {
                        try? await Task.sleep(for: delay)
                        while taskBox.get() == nil { await Task.yield() }
                        request.set(.now)
                        taskBox.get()?.cancel()
                    })
                }
            }, solver: nil)
            let searcher = makeSearcher(c, hooks)
            var call = await PRSHarness.call(searcher, c.request, watchdog: watchdog, onTask: { taskBox.set($0) })
            await canceller.get()?.value
            call.raw = nil
            let marks = trace.all
            var fields: [String: Any] = ["target": target, "delta": delta]
            if let tReq = request.get() {
                fields["tReqNs"] = PRSProbe.ns(call.start.duration(to: tReq))
                var landing = "entry"
                if let first = marks.first, tReq > first.at {
                    landing = "after final checkpoint"
                    for (a, b) in zip(marks, marks.dropFirst()) where tReq > a.at && tReq <= b.at { landing = "\(b.stage)"; break }
                    if landing == "after final checkpoint", let lastMark = marks.last, lastMark.stage != .solve {
                        landing = lastMark.stage == .preparedInput ? "solve (substage unverified)" : "after \(lastMark.stage)"
                    }
                }
                if case let .boundary(k) = mode { landing = "\(k) (boundary self-cancel)" }
                fields["landingStage"] = landing
                if let observed = marks.first(where: { $0.cancelled }) {
                    fields["observedAt"] = "\(observed.stage)"
                    fields["latencyNs"] = PRSProbe.ns(tReq.duration(to: observed.at))
                } else if call.outcome == "X" {
                    fields["observedAt"] = "inside solve (not visible to composition hooks)"
                }
                if call.outcome == "X" { fields["throwLatencyNs"] = PRSProbe.ns(tReq.duration(to: call.end)) }
                if call.outcome == "C" { fields["note"] = tReq > call.end ? "request after completion" : "completed before observation" }
            } else {
                fields["note"] = "no cancellation request issued before completion"
            }
            var record: [String: Any] = ["kind": "sample", "caseID": carrier, "family": "W9", "repetition": r, "warmup": false,
                                         "class": call.outcome, "lastCheckpoint": marks.last.map { "\($0.stage)" } ?? NSNull(),
                                         "cancel": fields, "stageNs": PRSHarness.stageNs(marks, start: call.start)]
            record.merge(callFields(call)) { $1 }
            let unexpected = call.outcome == "C"
                ? call.identities != workload(carrier, cls: "C").flatMap(expectedIdentities)
                : !["X", "W"].contains(call.outcome)
            if unexpected {
                record["class"] = "U"; record["mismatch"] = "unexpected cancel-pass outcome \(call.outcome)"
                emitter.emit(record); emitter.emit(["kind": "stop", "reason": "class U in cancel pass"]); stopped = true; return
            }
            emitter.emit(record)
            if memoryGuard(carrier) { stopped = true; return }
        }
    }
}
#endif
