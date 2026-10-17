#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Deterministic fault injection for the post-run harness fixes (consumer §31.7): the real
/// `PRSRunner` memory and cancel passes and the real emitter output, with only the searcher
/// replaced through the test-target `makeSearcher` factory. No production seam; invented data only.
struct PreparedRouteHarnessFaultTests {
    let p = PreparedRouteFixture()
    typealias Factory = (PreparedRouteFixture.Case, PreparedRouteSearchTestHooks?) -> PreparedRouteSearcher

    /// Parks at `entry` until cancelled, so only the watchdog can end the call (class W).
    static let parkAtEntry = PreparedRouteSearchTestHooks(checkpoint: { stage in
        if stage == .entry { try await Task.sleep(for: .seconds(3_600)) }
    }, solver: nil)

    struct Run {
        let records: [[String: Any]]
        let inflight: String?
        var samples: [[String: Any]] { records.filter { $0["kind"] as? String == "sample" } }
        var stops: [[String: Any]] { records.filter { $0["kind"] as? String == "stop" } }
        var end: [String: Any]? { records.last.flatMap { $0["kind"] as? String == "end" ? $0 : nil } }
    }

    func run(pass: String, cases: String, watchdog: Int = 60, budget: Int = 100,
             makeSearcher: Factory? = nil) async throws -> Run {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("prs-fault-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let out = dir.appendingPathComponent("out.jsonl"), inflight = dir.appendingPathComponent("inflight")
        let env = ["TSUGINO_PRS_PASS": pass, "TSUGINO_PRS_GROUP": "fault", "TSUGINO_PRS_CASES": cases,
                   "TSUGINO_PRS_WATCHDOG": "\(watchdog)", "TSUGINO_PRS_CALL_BUDGET": "\(budget)",
                   "TSUGINO_PRS_DEADLINE": "\(Int(Date().timeIntervalSince1970) + 600)",
                   "TSUGINO_PRS_OUT": out.path, "TSUGINO_PRS_INFLIGHT": inflight.path,
                   "TSUGINO_PRS_RUN": "fault-injection", "TSUGINO_PRS_VARIANT": "fault-injection"]
        await PRSRunner(environment: env, f0: PRSProbe.footprint(), makeSearcher: makeSearcher).run()
        let records = try String(contentsOf: out, encoding: .utf8).split(separator: "\n").map { line in
            #expect(line.hasPrefix("PRS_MEASURE "))
            let object = try JSONSerialization.jsonObject(with: Data(line.dropFirst("PRS_MEASURE ".count).utf8))
            let record = try #require(object as? [String: Any])
            // Common schema of every emitted record.
            #expect(record["schema"] as? Int == 1 && record["runID"] as? String == "fault-injection")
            #expect(record["variant"] as? String == "fault-injection" && record["pass"] as? String == pass)
            #expect(record["utc"] is String && record["thermalState"] is String)
            return record
        }
        return Run(records: records, inflight: try? String(contentsOf: inflight, encoding: .utf8))
    }

    // MARK: Memory pass

    /// A watchdog stop is class W (not a correctness failure) for any discovery class, and ends
    /// the case after that call without a stop record.
    @Test(arguments: [("W1-0001", "C"), ("W2a-10", "I-solver")])
    func memoryPassWatchdogStopIsClassWAndEndsCase(_ id: String, _ discovery: String) async throws {
        let p = p
        let run = try await run(pass: "memory", cases: "\(id)=\(discovery)", watchdog: 1) { c, hooks in
            #expect(hooks == nil)
            return p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: Self.parkAtEntry)
        }
        let s = try #require(run.samples.first)
        #expect(run.samples.count == 1 && run.stops.isEmpty)
        #expect(s["caseID"] as? String == id && s["class"] as? String == "W" && s["mismatch"] == nil)
        #expect(s["watchdogFired"] as? Bool == true && s["failure"] as? String == "CancellationError")
        #expect(s["repetition"] as? Int == -1 && s["warmup"] as? Bool == true && s["winnerDigest"] == nil)
        let memory = try #require(s["memory"] as? [String: Any])
        #expect(Set(memory.keys) == ["f0", "f1", "before", "after", "released", "peak", "peakMethod", "maxrss"])
        let end = try #require(run.end)
        #expect(end["calls"] as? Int == 1 && end["stopped"] as? Bool == false)
        #expect(run.inflight == "")
    }

    /// An outcome that contradicts discovery is class U and stops the process.
    @Test func memoryPassUnexpectedOutcomeIsClassUAndStops() async throws {
        let p = p
        let run = try await run(pass: "memory", cases: "W1-0001=C") { c, _ in
            p.searcher(c, InventedPreparedRouteViewSupplier(nil)) // S3 dataUnavailable: class R
        }
        let s = try #require(run.samples.first)
        #expect(run.samples.count == 1)
        #expect(s["class"] as? String == "U" && s["mismatch"] as? String == "class R != discovery C")
        #expect(s["failure"] as? String == "dataUnavailable" && s["memory"] is [String: Any])
        #expect(run.stops.count == 1 && (run.stops.first?["reason"] as? String)?.hasPrefix("class U at W1-0001") == true)
        let end = try #require(run.end)
        #expect(end["calls"] as? Int == 1 && end["stopped"] as? Bool == true)
    }

    /// Control: the default searcher completes all 1 + 3 calls with oracle-checked identities.
    @Test func memoryPassDefaultSearcherCompletesAllCalls() async throws {
        let run = try await run(pass: "memory", cases: "W1-0001=C")
        #expect(run.samples.map { $0["class"] as? String } == ["C", "C", "C", "C"])
        #expect(run.samples.map { $0["repetition"] as? Int } == [-1, 0, 1, 2] && run.stops.isEmpty)
        #expect(run.samples.allSatisfy { ($0["memory"] as? [String: Any])?["peakMethod"] is String })
        #expect(run.end?["calls"] as? Int == 4 && run.end?["stopped"] as? Bool == false)
    }

    // MARK: Cancel pass (only W2a-03 admitted, so the plan is its 36 boundary self-cancels)

    /// Real boundary cancellations stay class X; an outcome other than X, W or an oracle-checked
    /// C (here R at S3) is class U and stops the pass.
    @Test func cancelPassReconcilesUnexpectedFailure() async throws {
        let p = p
        let run = try await run(pass: "cancel", cases: "W2a-03=C") { c, hooks in
            p.searcher(c, InventedPreparedRouteViewSupplier(nil), hooks: hooks!)
        }
        // entry, configuration, capture × 3 cancel before S3; viewValidity r0 then fails at S3.
        #expect(run.samples.map { $0["class"] as? String } == Array(repeating: "X", count: 9) + ["U"])
        for s in run.samples.prefix(9) {
            let cancel = try #require(s["cancel"] as? [String: Any])
            #expect((cancel["landingStage"] as? String)?.hasSuffix("(boundary self-cancel)") == true)
            #expect(cancel["observedAt"] as? String == cancel["target"] as? String)
            #expect(cancel["latencyNs"] is Int && cancel["throwLatencyNs"] is Int && cancel["tReqNs"] is Int)
            #expect(s["family"] as? String == "W9" && s["stageNs"] is [String: Any] && s["mismatch"] == nil)
        }
        let u = try #require(run.samples.last)
        #expect(u["mismatch"] as? String == "unexpected cancel-pass outcome R" && u["failure"] as? String == "dataUnavailable")
        #expect(run.stops.map { $0["reason"] as? String } == ["class U in cancel pass"])
        #expect(run.end?["calls"] as? Int == 10 && run.end?["stopped"] as? Bool == true)
    }

    @Test func cancelPassReconcilesSolverCutoff() async throws {
        let p = p
        let run = try await run(pass: "cancel", cases: "W2a-03=C") { c, _ in
            let e = c.configuration
            return p.searcher(c, InventedPreparedRouteViewSupplier(c.view), configuration: .init(objective: e.objective,
                maximumWork: 1, maximumRetainedSlots: e.maximumRetainedSlots, maximumWinners: e.maximumWinners,
                maximumIdentityKeys: e.maximumIdentityKeys, maximumLogicalBytes: e.maximumLogicalBytes))
        }
        #expect(run.samples.map { $0["class"] as? String } == ["U"])
        #expect(run.samples.first?["mismatch"] as? String == "unexpected cancel-pass outcome I")
        #expect(run.end?["calls"] as? Int == 1 && run.end?["stopped"] as? Bool == true)
    }

    @Test func cancelPassRejectsCompletionWithWrongIdentities() async throws {
        let p = p
        let other = try #require(PreparedRouteWorkloads.matrix.first { $0.id == "W2a-04" }).build(p)
        let run = try await run(pass: "cancel", cases: "W2a-03=C") { _, _ in
            p.searcher(other, InventedPreparedRouteViewSupplier(other.view)) // completes with W2a-04's 16 routes
        }
        let u = try #require(run.samples.first)
        #expect(run.samples.count == 1 && u["class"] as? String == "U" && u["winners"] as? Int == 16)
        #expect(u["mismatch"] as? String == "unexpected cancel-pass outcome C")
        #expect(run.end?["stopped"] as? Bool == true)
    }

    /// An oracle-checked completion is admissible; the call envelope then stops the pass.
    @Test func cancelPassAcceptsOracleCheckedCompletionThenStopsAtEnvelope() async throws {
        let p = p
        let run = try await run(pass: "cancel", cases: "W2a-03=C", budget: 2) { c, _ in
            p.searcher(c, InventedPreparedRouteViewSupplier(c.view))
        }
        #expect(run.samples.map { $0["class"] as? String } == ["C", "C"])
        #expect(run.samples.allSatisfy {
            ($0["cancel"] as? [String: Any])?["note"] as? String == "no cancellation request issued before completion" })
        #expect(run.stops.map { $0["reason"] as? String } == ["call envelope exhausted"])
        #expect(run.end?["calls"] as? Int == 2 && run.end?["stopped"] as? Bool == true)
    }

    /// A watchdog stop is admissible in the cancel pass and the plan continues.
    @Test func cancelPassAcceptsWatchdogStop() async throws {
        let p = p
        let run = try await run(pass: "cancel", cases: "W2a-03=C", watchdog: 1, budget: 2) { c, _ in
            p.searcher(c, InventedPreparedRouteViewSupplier(c.view), hooks: Self.parkAtEntry)
        }
        #expect(run.samples.map { $0["class"] as? String } == ["W", "W"])
        #expect(run.samples.allSatisfy { $0["watchdogFired"] as? Bool == true && $0["mismatch"] == nil })
        #expect(run.stops.map { $0["reason"] as? String } == ["call envelope exhausted"])
        #expect(run.end?["calls"] as? Int == 2)
    }
}
#endif
