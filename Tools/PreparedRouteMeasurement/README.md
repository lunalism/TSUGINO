# Prepared route search — bounded invented measurement (consumer §30)

This method is frozen before any experiment run. The governing specification is
[consumer §30](../../docs/PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#30-bounded-invented-workload-and-measurement-experiment-design--2026-10-16);
this file records how the harness implements it.

## Scope

**Data.** All data is invented. There is no real or provider data, no private input and no
physical device.

**Placement.**

- Production code, the Xcode project and the schemes are unchanged.
- The harness lives in the test target:
  - `TSUGINOTests/Support/PreparedRouteWorkloads.swift`: generators and analytic expectations.
  - `TSUGINOTests/Support/PreparedRouteMeasurementProbe.swift`: clock, memory and CPU probe,
    and the emitter.
  - `TSUGINOTests/PreparedRouteWorkloadTests.swift`: always-run correctness tests.
  - `TSUGINOTests/PreparedRouteMeasurementTests.swift`: the measurement passes. These are
    disabled unless `TSUGINO_PRS_MEASURE=1`.
- The driver is `run.py` in this folder.

**Results are not policy.** Nothing here selects a production limit, timeout, profile, horizon,
ride cap or mapping.

## Procedure

1. **Correctness gate, run separately before the experiment.**
   - `PreparedRouteWorkloadTests` checks determinism. It also checks that, for P ≤ 16 rides,
     the analytic oracle, `ExhaustivePreparedSolverOracle` and the composed result agree.
   - It checks that out-of-profile growth leaves the identities unchanged.
   - It checks the end-to-end exact/+1 boundaries W7r, W7e, W7o and W7c. At 4,096 rides the
     prepared input is built and the solver cuts off in indexing. At 4,097, preparation refuses.
   - The §29.5 regression set is run, plus the Release app/extension build.
2. **`python3 Tools/PreparedRouteMeasurement/run.py run`.**
   - Builds both variants with `build-for-testing` into DerivedData under
     `/private/tmp/tsugino-prs-measure-<UTC>/`. Builds happen before the experiment clock.
   - Then runs these passes. Each `xcodebuild test-without-building` invocation is one fresh
     test-host process.

| Pass | Variant | Calls per admitted case | Instrumentation |
|---|---|---|---|
| discovery | V-D | 1 | Structural pre-check (S5–S8 one stage at a time, outside the call); analytic oracle (+ exhaustive oracle when P ≤ 16 rides); one call with composition and solver hooks |
| reference | V-D | 1 warm-up + 3 | No hooks |
| timing | V-O | 1 warm-up + 7 | No hooks |
| stage | V-O | 1 warm-up + 5 | Composition hooks only (`solver: nil` keeps the production solve path) |
| memory | V-O | 1 warm-up + 3, **one fresh process per case** | No hooks |
| cancel | V-O | 126 samples | Composition hooks only |

There is one process per group in each pass (W1, W2a, W2b, W3, W4, W5, W6, W7, W8). Timed repetitions
rotate the admitted cases (repetition r starts at offset r mod n).

### Build variants

- **V-D:** the standard Debug configuration (`-Onone`, `DEBUG`, testability).
- **V-O:** Debug with `SWIFT_OPTIMIZATION_LEVEL=-O SWIFT_COMPILATION_MODE=wholemodule` on the
  command line. This is an *optimized DEBUG-condition test build*. **It is not Release.**
- Release itself is not measurable in-tree, because the test target is Debug-only.

The Simulator is the explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`.

### Implementation choices within §30

- **Discovery.** Discovery is the §30.5 "discovery pass" and fixes the admitted set and the class
  of each case. Later samples must match that class, otherwise they are class U.
- **Unhooked samples** cannot see the last checkpoint, so they inherit I-prep or I-solver from
  discovery.
- **Family stop rule.** It applies to the size ladders W1, W2a, W2b, W3 (ascending f), W5 and W6.
  After the first solver cutoff, exactly one more size runs.
  - W1 256 and 257 always run.
  - W3a, W4, W5t, W6p and W7 are fixed cases.
  - **W8 is a configuration ladder over one fixed workload**, so every one of its four
    `maximumWork` values runs. The rule's rationale ("larger sizes only re-measure
    time-to-cutoff under the same ceiling") does not apply, because each value is a different
    ceiling. All four W8 cases are inside the 60-case envelope.
- **W7p pre-check.** Discovery measures `assessment.logicalPayloadBytes` for 1 and 2 near-maximal
  `Spec` slots (72 stops, 192-byte tokens), predicts the 96,000,000-byte crossing, then confirms it
  on actual constructor values.
  - The pair is included only if the under side builds P and the over side fails exactly with P
    `resourceLimit`.
  - The pre-check result, included or excluded, is recorded as a `precheck` record.
- **W3 mask.** SplitMix64 with seed `0x5453_5547_494E_4F00 + percent`, a Fisher–Yates selection over
  relation indices in generator order, and `Int((f × 72).rounded(.toNearestOrAwayFromZero))`
  feasible relations.

### Metrics

| Metric | Definition |
|---|---|
| `wholeNs` | `ContinuousClock` immediately before creating the harness-owned search `Task` and after its result. Includes the `@concurrent` hop and unwinding |
| `stageNs` | Composition-hook marks written to a `Synchronization.Mutex` buffer. `hop` = first mark − call start; every stage = mark(k) − mark(k−1); `preparation` = `preparedInput` − `scope`; `solve` = `solve` − `preparedInput` |
| `cpuUserNs`, `cpuSystemNs` | Process-wide `getrusage(RUSAGE_SELF)` deltas; not per thread |
| `solverUsage` | `InternalSolverUsage` at the last solver stage entry seen by the DEBUG solver hook (`observedAt`), in logical credits. It is exact only when `observedAt` is `terminal`. At a cutoff it is a lower bound ≤ the limit |
| `structural` | Constructor-reported counts and `logicalPayloadBytes` (logical accounting, not memory) |
| `memory` | `task_info(TASK_VM_INFO)` `phys_footprint` at F0 (test start), F1 (after setup), and per call before, after return (result retained) and after release. `peak` is `ledger_phys_footprint_peak` (process lifetime) when the returned count covers it; otherwise a 1 ms sampling task, which may miss spikes. `peakMethod` records which. `maxrss` is `getrusage` `ru_maxrss` |
| `cancel` | See below |

**Cancellation (`cancel`).**

- `tReqNs` is the harness clock immediately before `Task.cancel()`.
- **Delayed mode.** The hook at the checkpoint before the target stage starts a canceller. The
  canceller sleeps δ × the stage-pass median of the target stage, then cancels. δ ∈ {0.1, 0.5,
  0.9}, 5 repetitions.
  - Preparation targets on W7o-2880: closure, evidence, assessment, preparedInput.
  - Solver targets on W2a-08 and W1-0256: δ is relative to the whole solve stage.
- **Boundary mode.** On W2a-03 the hook cancels its own task at each of the 12 checkpoints,
  3 repetitions each.
- **Landing stage** is classified afterwards from the marks. A request after the
  `preparedInput` mark is "solve (substage unverified)".
- **`observedAt`** is the first mark taken while the task was already cancelled.
  `latencyNs` = that mark − `tReq`.
- Inside the solver the observation is not visible to composition hooks. There,
  `throwLatencyNs` = call end − `tReq` is the caller-visible figure.

### Outcome classes (§30.8)

| Class | Meaning |
|---|---|
| C | Completed and oracle-checked |
| R | Expected canonical failure |
| I-prep | `searchIncomplete` before the `preparedInput` checkpoint (provisional mapping) |
| I-solver | `searchIncomplete` after the `preparedInput` checkpoint |
| X | Experimental cancellation |
| W | Watchdog cancellation: 60 s in V-O, 180 s in V-D |
| H | External 20-min process cap, or the process ended without an `end` record. The driver then terminates the host and verifies that no host process remains |
| S | Setup failure |
| U | Unexpected result; stops the experiment |

- Only C carries winners, and only as a count plus a SHA-256 digest of the ordered `trip/day/b-a`
  identities. Partial route sets are never emitted.
- Elapsed time never certifies completion.

### Containment

- **Concurrency.** Strictly serial. Run with `-parallel-testing-enabled NO` and a `.serialized`
  suite. The only concurrent helpers are the watchdog, the canceller and the optional sampler.
- **Envelope.** 1,506 search calls and 4 h of wall clock from the first discovery invocation.
  Both are passed to every process and checked before every call. The driver also checks them
  before every invocation.
- **Per-process cap.** 20 min.
- **Memory guard.** 2 GiB of `phys_footprint` between calls.
- **No automatic retries.**
- The in-process watchdog cannot interrupt synchronous preparation constructors. Only the external
  cap ends a stuck synchronous stage.

## Artifacts

- `results.json`: metadata (toolchain, Simulator, host, Git, SHA-256 of production and harness
  files), process log, every record, admitted sets and halt reason.
- `RESULTS.md`: summary and limitations.
- `/private/tmp/tsugino-prs-measure-<UTC>/` holds DerivedData, logs and per-process JSONL. It is
  local evidence only, kept until the independent review ends, then deleted.
- The driver refuses to overwrite an existing `results.json`.

## Limitations

- Invented stress shapes, not representative timetable workloads (§16.2).
- Simulator on the Mac host, not physical-iPhone timing, memory, thermal or jetsam behaviour.
- V-D and V-O are not Release.
- Logical credits and bytes are not measured memory or time.
- Process footprint is not per-call allocation.
