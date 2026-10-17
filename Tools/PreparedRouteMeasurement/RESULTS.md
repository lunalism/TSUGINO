# Prepared route search — invented measurement results, 2026-10-16

**Evidence only.** These are invented stress shapes (consumer §16.2 class "invented stress"), not
representative timetable workloads. The Simulator runs on the Mac host; nothing here measures a
physical iPhone. **V-O is an optimized DEBUG-condition test build, not Release.** No production
limit, policy, mapping, profile, horizon, ride cap or timeout follows from these figures. The method
is in [README.md](README.md), frozen before the run, and every sample is in `results.json`.

**Provenance of `results.json`.** The committed `results.json` is a **sanitized derivative** of the
raw run record, not a byte-identical copy.

- The raw record (SHA-256 `5ae1014a15cf4fba3f12f4dd42ee66c604debcef30e5bbd4a9e2e29132420664`) is preserved outside version control as
  `/private/tmp/tsugino-prs-measure-20261016T190846Z/results.raw.json`.
- Exactly two kinds of field were transformed, to remove a persistent hardware identifier and a
  user-specific absolute path:
  - `metadata.host.power`: the battery identifier is replaced by `(id=<removed>)`. The power source
    and state are kept.
  - `processes[kind=build].command` (2 entries): the absolute checkout path is replaced by `<repo>`.
- A top-level `sanitization` object records the raw SHA-256, the transformed fields, the
  placeholders and the reason.
- A structural comparison against the raw record found exactly those 4 differences: 3 changed
  values and the added object.
- Every record (1,558, including 1,460 samples), sample value, timestamp, outcome, route digest,
  count, ordering, admitted set and run-time source fingerprint is unchanged.
- The Simulator UDID is kept. It identifies a Simulator instance, not hardware, and is already in
  the published §30 destination.

## Run and accounting

| | |
|---|---|
| Run | `20261016T190846Z`. Builds 19:08–19:13 UTC. Experiment 19:13:13–20:07:42 UTC: **3,269 s (54.5 min)** of the 4 h budget |
| Calls | **1,460 of the 1,506 ceiling**: discovery 58, V-D reference 232, V-O timing 464, V-O stage 348, memory 232, cancel 126. Halt: none |
| Processes | 2 `build-for-testing` + 95 test-host processes (9 each for discovery, reference, timing and stage; 58 fresh memory processes; 1 cancel); every exit code 0. No external kill |
| Classes | discovery: 40 C, 12 I-solver, 6 I-prep. Every timed/memory sample matched its discovery class. Cancel: 109 X, 17 C (request after completion). **No W, H, S or U** in any pass |
| Skipped | W2a-12 and W2b-8 (§30.5 family stop, one size after the first solver cutoff). W8: all four limits ran by design (README) |
| W7p pre-check | **Included at 81/82 slots.** Actual crossing from constructor values: 81 slots → assessment 95,596,884 logical bytes, P built (95,597,204); 82 → 96,776,154 → P `resourceLimit`. The §30.3 estimate of ≈ 77/78 was an upper-bound guess; the pre-check fixed the pair |
| Not in results | Before the official run, 14 harness-validation calls on dev builds exercised every pass type (W4 discovery, stage, memory, cancel boundary). They are not in `results.json` |

**Environment.**

- **Host:** Apple M2 (Mac14,15), 8 CPUs, 16 GiB, macOS 26.6.2 (25G83). AC power. Thermal state
  `nominal` in every record.
- **Load:** recorded **once**, before the builds: load averages 115.71 / 69.16 / 36.27. This deviates
  from §30.6, which asks for load at the start and end of each process; the driver now records it
  per process for future runs. Test launches themselves raise the load average (see Variability).
- **Toolchain:** Xcode 27.1 (27A9275), Swift 6.4 (language mode 5), iOS Simulator SDK 27.1.
- **Simulator:** iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`, runtime iOS 26.3.
- **Source:** HEAD `c2917e3f511ef33d5b471dc620adc8448723fa88`, with the harness uncommitted. Source
  SHA-256 values are in `results.json` metadata.

**Correctness gate (separate, before the run).** V-D, `/private/tmp/tsugino-prs-gate`:

- **220 tests passed, 0 failed**, including the 6 new `PreparedRouteWorkloadTests` (31 cases).
  `PreparedRouteMeasurementTests` was **skipped** by default.
- Release app plus `TSUGINOLiveActivity.appex`: **BUILD SUCCEEDED**.
- Empty diff under `TSUGINO/`, `TSUGINOLiveActivity/`, `TSUGINO.xcodeproj/`.

## Observations

All figures are median [min–max] over the measured repetitions; warm-up calls are excluded.
**Whole-call** figures come from the unhooked V-O timing pass (n = 7) or the V-D reference pass
(n = 3). **Stage** figures come from the separately run, hooked V-O stage pass (n = 5) and are
labelled as such. The two were measured in different processes and are not additive (see
Variability).

**Correctness and boundaries** (discovery, V-D):

- Every completed case matched its analytic identity list. Cases with P ≤ 16 rides also matched
  `ExhaustivePreparedSolverOracle`.
- W6 kept identical identities (9 winners) from 0 to 2,844 filtered out-of-profile occurrences,
  with exactly 6 projected occurrences and 9 targets.
- The §30.3 boundaries behaved as predicted:

| Boundary | Exact | +1 |
|---|---|---|
| W7r (P rides) | P built with 4,096 rides; solver cut off in indexing | preparation refused at P (last checkpoint `assessment`) |
| W7e (relations) | 2,048: scoped `noResults` | 2,049: refused at evidence (`closure`) |
| W7o (occurrences) | 2,880: completed with 24 winners | 2,881: refused at closure (`declarations`) |
| W7c (connections) | 23,040: refused at evidence (`closure`) | 23,041: refused at closure (`declarations`) |

**Where the invented 100M-credit ceiling cuts off:**

- W2a: from width 10.
- W2b: from depth 6.
- W3: from 50% feasible connections.
- W5: from 5 loops.
- W1: the 257th tie, at the winner cap.
- W8: 64M completed W2a-08, which used 54.8M credits; 1M, 4M and 16M cut off.

**Elapsed time (V-O):**

- The slowest completed whole call (timing pass) was **W1-0256 at 93.1 ms** [65.9–117.2]. In the
  separate stage pass its solve stage was 72.7 ms (ordering 256 ties).
- Every solver cutoff at the 100M ceiling returned within **≤ 20 ms** whole-call median (max
  47.6 ms, W2a-10).
- The lowest work limits returned in about 1.2–1.7 ms (W8).
- V-D was **about 3–107× slower** than V-O for the same case, by the ratio of whole-call medians
  from the separate reference and timing passes. These ratios carry the ≈ 2× between-process
  variation. Solver-heavy shapes exceed 70× (W2b-7 107×, W5-5 95×); preparation-heavy shapes are
  lower (W7c-23040 4.8×, W7p-82 3.1×).

**Preparation versus solve (V-O stage pass only; within-process splits):**

- **Preparation dominates the large domain shapes:**
  - W7o-2880: closure 15.6, preparedInput 11.6, assessment 6.2 ms; solve 3.8 ms.
  - W6-2844: preparation 17.1 ms; solve 0.35 ms.
  - W7c-23040: closure 34.9 ms, then refused.
- **Solve dominates tie-heavy shapes:** W1-0256 is 72.7 ms solve against 2.9 ms preparation.

**Credits are not time.**

- V-O stage-pass solve ns per completed work credit ranged from about **0.02 (W3) to 0.8 (W1-0256)**.
  This excludes W7p-81 (≈ 0.0002), whose credits are almost all the inherited-payload charge.
  A credit-based limit therefore bounds very different elapsed times depending on shape.
- Profile-filtered filler still raises solver credits (W6: 2.44M → 9.67M). The solver charges
  P's inherited logical payload, which includes the whole captured inventory, as work.
- That growth is a meter effect: W6's stage-pass solve time stayed at about 0.35 ms.

**CPU.** Process-wide `getrusage` CPU / whole-call elapsed was about 0.8–1.3 (median per case,
timing pass). This is consistent with a mostly single-threaded call, but it is a process-level
figure, not a per-thread measurement.

**Memory** (V-O, one fresh test-host process per case, 1 warm-up + 3 calls). All figures are
**process-level observations**, not per-call allocation:

- **Method.** `task_info(TASK_VM_INFO)` was read at F0 (test start, before any fixture), at F1
  (after the workload and searcher were built, before the warm-up call), and around each call.
  `peak` is the kernel's process-lifetime `ledger_phys_footprint_peak`, read after each call
  returned. It was available in every process, so the 1 ms sampler was never used.
- **"peak − F1"** in the table is the largest lifetime peak read after any of the 4 calls, minus
  F1. It was at most **8.2 MiB** (W7c-23040) and below 1 MiB for every W1–W5 and W8 shape.
- **What it is not.** The lifetime peak also covers setup, the test runner and every thread in the
  process. `phys_footprint` does not grow when a call reuses pages the allocator already holds,
  and shared or compressed pages are counted differently from allocations. So "peak − F1" is
  neither the call's allocated memory nor an upper bound on call-attributable peak memory.
- W7p-81/82 carry about **96 MB of constructor-reported logical bytes**. The process showed
  ≤ 2.9 MiB F1 − F0 setup growth and ≤ 0.3 MiB peak − F1. Logical-byte accounting is therefore far
  larger than the observed process footprint for these shapes; the cause (for example shared
  copy-on-write snapshots) was not measured.
- Residual footprint after release (last call's `released` − F1) was ≤ 0.3 MiB.

**Cancellation** (V-O):

- **Boundary self-cancel:** observed at the same checkpoint in all 36 samples; throw latency
  ≤ 0.025 ms.
- **Preparation** (W7o-2880, 60 samples):
  - Requests landed in closure ×7, evidence ×2, assessment ×12 and preparedInput ×29. Five landed
    in solve, and five arrived after completion, which returned C.
  - Observation latency was always at the next checkpoint and never exceeded the containing
    synchronous stage's duration (0 of 50).
  - Medians by landing stage: closure 5.8 ms (max 11.6), assessment 2.4 ms (max 5.7),
    preparedInput 6.6 ms (max 10.9).
- **Solver** (W2a-08, W1-0256): caller-visible throw latency had a median of about 0.2 ms, max
  6.1 ms. The substage was not verified.
- **Landing drift:** δ targeting landed later than intended on these short stages, so coverage by
  target stage is uneven (evidence: 2 samples).
- **No latency bound is claimed.**

**Variability.**

- **Within a process,** maxima are often 2–5× the median, especially for sub-millisecond calls.
  Ranges are retained with no outlier deletion.
- **Between processes and runs,** absolute milliseconds moved by about **2×**:
  - In the stage pass (composition hooks), 21 cases took up to about 2× the unhooked timing pass.
    For example, W6-2844 had preparation 17.1 ms against a whole-call median of 10.5 ms in the
    timing pass.
  - Identical workloads differed: W2a-08 solved in 8.7 ms and W8-064M in 4.7 ms, both at
    54.8M credits.
  - The reviewer's bounded rerun of W1-0256, W7o-2880 and W6-2844 (18 calls) measured about
    half the official stage-pass figures, with identical classes and digests.
- **Stage-pass figures** therefore describe the split between stages within a process. Do not
  compare them with or add them to whole-call medians from other passes.
- **Conclusions** here hold only at the order-of-magnitude level.

## Limitations and unfinished coverage

- **Not Release:** no Release-configuration measurement (the test target is Debug-only).
- **Not iPhone:** no physical-iPhone timing, memory, thermal or jetsam evidence.
- **Not representative:** invented shapes only; real workloads (G1/G3) are untouched.
- **Memory is process-level:** process `phys_footprint` and its lifetime peak relative to the
  post-setup F1 baseline; not per-call allocation and not a bound on call-attributable memory.
- **Solver usage at a cutoff is a lower bound:** it is the last observed stage entry, ≤ the limit.
- **Solver substage of cancellation is unverified** in V-O.
- **Uneven cancellation coverage:** the evidence target landed only twice.
- **Single host:** one host, one run, n = 7 V-O repetitions; no confidence intervals. Absolute ms
  figures vary by about 2× across processes and runs. Load was not recorded per process.

## Post-run harness changes and their verification (2026-10-17)

**The official run used the harness recorded in `results.json`, not the final files.** After the
run, review corrections changed three harness files. `results.json` keeps the run-time
fingerprints unchanged:

| File | Fingerprint used by the official run (`results.json`) | Changed after the run |
|---|---|---|
| `TSUGINOTests/PreparedRouteMeasurementTests.swift` | `6e330d2b58cadd54c9a5e4818211e6963296440f22a744474dbaf1c4f3f02724` | Yes: memory-pass W handling, cancel-pass reconciliation, and a test-target `makeSearcher` factory used only by the fault tests |
| `TSUGINOTests/PreparedRouteWorkloadTests.swift` | `62579a7265ef40b65cf11e2be37e9008b58239fb385bb8da189476e9d873434d` | Yes: `#require` before the exhaustive-oracle precondition |
| `Tools/PreparedRouteMeasurement/run.py` | `8f0abbb0e930c3214e4caad098dbd55b07d98d9a51a8e33e4e12dba9b39e3f3e` | Yes: `vm.loadavg` at the start and end of each test-host process. Later (publication sanitization), metadata records only the `pmset` power-source line, and recorded build commands use `<repo>` |
| `TSUGINOTests/Support/PreparedRouteMeasurementProbe.swift` | `33e81714e453494cfbbc377816132dafe5ddab133c880ced07c5fc3fce538d0e` | No |
| `TSUGINOTests/Support/PreparedRouteWorkloads.swift` | `02fa3c5c6db78bb98fe468c175014574be44b6ab114ea77a347dc270051998c9` | No |
| `Tools/PreparedRouteMeasurement/README.md` | `117ab43eda813a9a4679fa9078a989193e0f1c8606140ef40340094bc52028b6` | No (frozen method) |

The final fingerprints are in the hand-off manifest; a file cannot record its own digest.

**Effect on recorded samples: none.** The fixes would not change any recorded classification:

- No call in any pass fired the watchdog (0 of 1,460 `watchdogFired`), so the memory-pass W fix
  never applied. The memory pass recorded 160 C, 48 I-solver and 24 I-prep samples, each
  matching discovery.
- The cancel pass recorded only 109 X and 17 C. The run-time code already checked C identities
  against the analytic expectation. All 17 C winner digests equal the discovery digest of the same
  carrier, which was checked analytically (W2a-08 ×9, W7o-2880 ×5, W1-0256 ×3; W2a-08 was also
  checked by the exhaustive oracle). No R, I or other outcome occurred, so the new
  reconciliation would assign the same classes.
- Load was recorded once, as stated above. The per-process fields do not exist in this run's
  `results.json`.

No rerun was performed, and none is needed for classification. The recorded results are not
rewritten; the only later change to `results.json` is the metadata sanitization described under
"Provenance of `results.json`".

**Added verification files** (test target and Tools only; no production seam):

- `TSUGINOTests/PreparedRouteHarnessFaultTests.swift` (`#if DEBUG`, always run). It runs the real
  `PRSRunner` memory and cancel passes and parses the real emitter output, replacing only the
  searcher through the test-target factory. A DEBUG composition hook parked at `entry` makes
  watchdog firing deterministic. A nil view, a 1-credit configuration and another case's view
  inject R, I and wrong-identity C outcomes.
- `Tools/PreparedRouteMeasurement/test_run.py` (Python `unittest`). It drives the real
  `Experiment.invoke`/`run` with real child processes standing in for `xcodebuild`, and a
  synthetic `sh` for `sysctl`, `simctl` and `pgrep`. It never touches xcodebuild, the Simulator
  or a device.

**Checks run on 2026-10-17** (explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`,
fresh DerivedData outside the repository):

| Check | Result |
|---|---|
| `xcodebuild … -only-testing:TSUGINOTests/PreparedRouteHarnessFaultTests -only-testing:TSUGINOTests/PreparedRouteMeasurementTests test` (Debug) | `TEST SUCCEEDED`: 8 fault functions (9 cases) passed; the measurement suite was skipped |
| Same fault suite with the two Swift fixes reverted to their exact run-time code, then restored (SHA-256 verified) | 4 of 8 functions (5 of 9 cases) failed as expected (both watchdog cases, R and I reconciliation, and the wrong-identity mismatch label). The run-time code already made wrong-identity C class U, under a different label |
| `python3 -B -I Tools/PreparedRouteMeasurement/test_run.py` | 8 tests OK: per-process `loadStart`/`loadEnd`, memory W counted without halting, class U halt with no further process, memory-guard family stop, missing `end` record → H with cleanup check, process-cap kill → H, call-envelope halt, full `run()` schema |
| Same driver tests against a scratch copy of `run.py` without the load fields | 2 tests failed as expected |
| `python3 -B -I Tools/PreparedRouteMeasurement/test_run.py` after the sanitization change | 9 tests OK; the added test checks that recorded metadata and build commands contain no battery identifier or checkout path |
| Same driver tests in a mirrored scratch copy with the previous recording restored | Only the added test failed, as expected |

These checks make test-only search calls on invented data: 23 per execution of the fault suite.
No timing or memory figure comes from them, and they are separate from the 1,460 official calls,
the 14 pre-run validation calls and the reviewer's 18 rerun calls.

**Still unverified.**

- The final harness and driver have not executed a measurement experiment.
- Per-process load recording has run only against synthetic processes. The real `sysctl -n
  vm.loadavg` command it calls works on this host but was not captured in a real run.
- A watchdog firing inside a real long-running search, as opposed to a parked hook, has not been
  observed.
- The memory-guard, H and envelope paths of the Swift runner are unchanged since the run and were
  not re-exercised there. The driver's handling of them is covered only synthetically.

## Per-case timing (V-D discovery work; V-D/V-O whole call; V-O CPU and stages)

| Case | Discovery class | Winners | Solver work (V-D) | V-D whole ms (n=3) | V-O whole ms (n=7) | V-O CPU ms | V-O prep ms | V-O solve ms |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| W1-0001 | C | 1 | 83617 | 0.914 [0.629–0.972] | 0.091 [0.078–0.302] | 0.134 [0.097–0.290] | 0.045 [0.037–0.096] | 0.029 [0.018–0.047] |
| W1-0002 | C | 2 | 165764 | 1.439 [0.891–1.486] | 0.114 [0.073–0.221] | 0.127 [0.088–0.227] | 0.046 [0.038–0.053] | 0.026 [0.021–0.031] |
| W1-0008 | C | 8 | 702242 | 9.441 [7.527–9.498] | 0.222 [0.201–0.524] | 0.256 [0.220–0.416] | 0.080 [0.073–0.157] | 0.105 [0.099–0.189] |
| W1-0032 | C | 32 | 3595154 | 109.253 [105.605–113.869] | 2.109 [1.304–3.367] | 1.904 [1.317–2.009] | 0.308 [0.245–0.832] | 1.067 [1.045–1.202] |
| W1-0064 | C | 64 | 9311566 | 415.393 [402.143–428.065] | 4.896 [4.361–14.638] | 4.693 [4.374–8.087] | 0.545 [0.445–2.501] | 4.303 [3.880–6.840] |
| W1-0128 | C | 128 | 27116002 | 1650.004 [1607.411–1665.505] | 23.573 [16.125–30.098] | 19.882 [16.041–25.054] | 0.953 [0.908–1.621] | 21.271 [15.520–37.794] |
| W1-0256 | C | 256 | 88209662 | 6368.431 [5777.842–6451.925] | 93.133 [65.910–117.226] | 78.693 [64.378–85.567] | 2.884 [2.821–6.729] | 72.646 [61.156–90.582] |
| W1-0257 | I-solver | — | 5118353 (last at tieCollection) | 273.179 [178.178–295.642] | 5.908 [4.494–8.148] | 5.922 [4.518–7.255] | 2.081 [1.820–3.474] | — |
| W2a-02 | C | 4 | 887495 | 3.353 [3.086–4.298] | 0.325 [0.185–0.454] | 0.370 [0.221–0.497] | 0.187 [0.143–0.212] | 0.103 [0.101–0.136] |
| W2a-03 | C | 9 | 2444041 | 12.428 [7.901–12.985] | 0.549 [0.332–0.657] | 0.445 [0.357–0.702] | 0.263 [0.189–0.301] | 0.308 [0.249–0.332] |
| W2a-04 | C | 16 | 5531107 | 32.853 [26.863–37.799] | 1.187 [0.622–2.594] | 1.106 [0.651–1.270] | 0.356 [0.272–0.397] | 0.715 [0.585–0.767] |
| W2a-06 | C | 36 | 20135707 | 141.957 [117.961–160.632] | 2.127 [2.004–3.760] | 2.166 [2.032–3.624] | 0.637 [0.517–0.647] | 2.703 [2.572–2.928] |
| W2a-08 | C | 64 | 54840071 | 439.494 [324.656–457.289] | 6.557 [5.346–12.241] | 6.525 [5.365–8.288] | 1.008 [0.860–1.130] | 8.687 [8.039–19.102] |
| W2a-09 | C | 81 | 83974702 | 690.339 [442.829–719.559] | 8.844 [8.042–22.884] | 8.826 [8.010–13.864] | 1.227 [0.945–2.141] | 13.044 [12.091–18.193] |
| W2a-10 | I-solver | — | 99915309 (last at admission) | 982.468 [593.762–1024.409] | 14.950 [12.109–47.617] | 14.627 [11.463–21.306] | 1.762 [1.551–2.057] | — |
| W2a-11 | I-solver | — | 99839400 (last at admission) | 1232.122 [924.578–1477.484] | 19.964 [15.120–32.380] | 19.077 [15.160–23.843] | 1.779 [1.532–1.912] | — |
| W2b-2 | C | 4 | 887877 | 4.783 [4.281–4.856] | 0.370 [0.181–2.797] | 0.407 [0.222–0.441] | 0.202 [0.144–1.047] | 0.136 [0.098–0.170] |
| W2b-3 | C | 8 | 3552102 | 18.199 [15.995–20.434] | 0.407 [0.333–0.726] | 0.429 [0.361–0.754] | 0.234 [0.220–0.250] | 0.368 [0.350–0.378] |
| W2b-4 | C | 16 | 12158081 | 58.872 [54.276–78.391] | 1.518 [0.813–1.694] | 1.533 [0.842–1.561] | 0.321 [0.296–0.666] | 1.155 [1.101–1.341] |
| W2b-5 | C | 32 | 37305816 | 194.329 [187.113–300.959] | 3.177 [2.277–4.643] | 3.043 [2.250–3.859] | 0.439 [0.368–0.497] | 3.853 [3.636–3.893] |
| W2b-6 | I-solver | — | 90708564 (last at finalization) | 795.444 [641.056–878.860] | 8.419 [6.720–11.405] | 7.892 [6.747–10.179] | 0.574 [0.451–1.262] | — |
| W2b-7 | I-solver | — | 98118896 (last at tieCollection) | 328.601 [304.378–450.013] | 3.078 [3.000–6.053] | 3.116 [3.041–5.337] | 0.544 [0.511–0.753] | — |
| W3-000 | C | 0 | 6076080 | 15.228 [13.196–17.650] | 1.414 [0.968–1.522] | 1.448 [1.006–1.545] | 0.628 [0.617–1.362] | 0.100 [0.099–0.200] |
| W3-010 | C | 2 | 19598135 | 51.140 [44.729–52.348] | 1.966 [1.380–3.298] | 1.780 [1.415–2.149] | 1.219 [0.607–2.072] | 0.356 [0.352–5.347] |
| W3-025 | C | 9 | 44473398 | 108.365 [83.932–116.793] | 2.238 [2.021–4.710] | 2.222 [2.057–3.180] | 0.614 [0.600–1.228] | 0.871 [0.862–1.717] |
| W3-050 | I-solver | — | 98049919 (last at tieCollection) | 231.205 [198.744–250.558] | 4.457 [3.814–8.760] | 4.304 [3.739–4.977] | 0.638 [0.614–2.200] | — |
| W3-100 | I-solver | — | 99052152 (last at tieCollection) | 237.448 [236.706–297.059] | 4.918 [3.983–8.871] | 4.757 [3.937–5.593] | 1.206 [0.607–3.141] | — |
| W3a-010 | C | 2 | 19593325 | 41.450 [36.629–52.375] | 1.798 [1.230–1.903] | 1.368 [1.271–1.860] | 1.016 [0.740–3.854] | 0.357 [0.352–0.723] |
| W4a | C | 0 | 1279038 | 7.176 [6.974–8.122] | 0.954 [0.656–1.035] | 0.972 [0.690–1.074] | 1.246 [0.736–6.895] | 0.097 [0.058–0.104] |
| W4b | C | 0 | 28970742 | 72.618 [70.387–76.033] | 1.351 [1.238–1.815] | 1.360 [1.271–1.862] | 0.775 [0.413–4.412] | 1.081 [0.704–1.274] |
| W4c | C | 0 | 173274 | 3.565 [3.199–3.717] | 0.540 [0.478–0.809] | 0.572 [0.509–0.842] | 0.738 [0.485–0.959] | 0.014 [0.007–0.017] |
| W4d | C | 0 | 2282313 | 9.320 [7.690–9.355] | 0.484 [0.327–0.579] | 0.489 [0.359–0.584] | 0.216 [0.195–0.331] | 0.083 [0.079–0.123] |
| W5-1 | C | 1 | 230350 | 1.670 [1.665–3.096] | 0.118 [0.109–0.133] | 0.138 [0.125–0.163] | 0.147 [0.097–0.156] | 0.050 [0.031–0.057] |
| W5-2 | C | 1 | 1064436 | 5.125 [4.927–5.484] | 0.212 [0.205–0.235] | 0.229 [0.222–0.250] | 0.155 [0.139–0.240] | 0.069 [0.059–0.124] |
| W5-3 | C | 1 | 6518289 | 25.023 [21.844–26.484] | 0.475 [0.473–0.502] | 0.494 [0.489–0.524] | 0.216 [0.210–0.277] | 0.250 [0.246–0.394] |
| W5-4 | C | 1 | 35171876 | 113.145 [112.997–121.273] | 1.400 [1.375–1.431] | 1.424 [1.389–1.509] | 0.484 [0.288–0.586] | 1.629 [1.056–1.647] |
| W5-5 | I-solver | — | 99735472 (last at tieCollection) | 297.878 [286.876–299.808] | 3.128 [3.082–3.181] | 3.131 [3.095–3.198] | 0.666 [0.528–0.924] | — |
| W5t | C | 2 | 509065 | 2.265 [2.248–3.387] | 0.145 [0.127–0.160] | 0.164 [0.142–0.204] | 0.175 [0.084–0.184] | 0.081 [0.048–0.090] |
| W6-0000 | C | 9 | 2444041 | 16.854 [15.275–19.241] | 0.644 [0.350–1.653] | 0.535 [0.406–0.685] | 0.272 [0.225–0.306] | 0.319 [0.264–0.344] |
| W6-0096 | C | 9 | 2688041 | 19.724 [18.298–25.288] | 0.968 [0.571–1.474] | 0.935 [0.570–1.292] | 0.817 [0.630–1.020] | 0.333 [0.275–0.441] |
| W6-0384 | C | 9 | 3420041 | 23.704 [21.567–32.080] | 1.341 [1.248–2.743] | 1.359 [1.257–2.761] | 2.489 [1.968–4.046] | 0.377 [0.265–0.420] |
| W6-1536 | C | 9 | 6348041 | 46.441 [45.541–47.073] | 5.040 [4.416–8.836] | 5.054 [4.430–7.881] | 9.654 [7.532–10.613] | 0.352 [0.301–0.549] |
| W6-2844 | C | 9 | 9672541 | 74.150 [72.107–75.681] | 10.545 [9.482–16.400] | 10.339 [9.459–13.782] | 17.098 [16.473–27.326] | 0.349 [0.341–0.489] |
| W6p-0384 | C | 9 | 3797828 | 18.799 [15.962–18.954] | 1.642 [1.260–3.175] | 1.640 [1.283–2.556] | 2.341 [1.743–2.628] | 0.252 [0.195–0.267] |
| W7r-4096 | I-solver | — | 1 (last at indexing) | 175.326 [158.877–183.783] | 11.525 [10.020–18.011] | 11.234 [9.998–13.898] | 13.517 [12.035–22.191] | — |
| W7r-4097 | I-prep | — | — | 120.004 [108.151–127.425] | 11.227 [8.788–16.398] | 11.159 [8.752–12.521] | — | — |
| W7e-2048 | C | 0 | 17188860 | 282.902 [264.769–324.289] | 22.947 [21.057–29.399] | 21.893 [20.696–25.436] | 25.450 [21.039–34.534] | 0.697 [0.667–0.709] |
| W7e-2049 | I-prep | — | — | 15.458 [14.959–15.842] | 2.642 [2.411–3.973] | 2.665 [2.461–3.925] | — | — |
| W7o-2880 | C | 24 | 69632884 | 314.773 [304.919–319.271] | 40.041 [28.177–59.112] | 36.563 [27.941–45.317] | 36.323 [26.721–40.198] | 3.760 [3.167–5.894] |
| W7o-2881 | I-prep | — | — | 14.195 [11.043–18.754] | 1.262 [0.985–1.695] | 1.234 [0.991–1.532] | — | — |
| W7c-23040 | I-prep | — | — | 180.344 [168.151–209.846] | 37.405 [28.790–54.590] | 31.057 [28.536–35.540] | — | — |
| W7c-23041 | I-prep | — | — | 15.267 [15.064–16.833] | 2.369 [2.100–3.738] | 2.348 [2.147–2.683] | — | — |
| W7p-81 | C | 0 | 95597216 | 7.444 [6.085–7.988] | 2.215 [0.986–3.230] | 1.754 [0.999–2.203] | 1.989 [1.176–2.239] | 0.016 [0.011–0.017] |
| W7p-82 | I-prep | — | — | 5.928 [5.650–6.588] | 1.897 [0.864–7.618] | 1.271 [0.891–1.924] | — | — |
| W8-001M | I-solver | — | 1 (last at indexing) | 9.939 [7.655–13.335] | 1.153 [0.694–2.327] | 0.884 [0.740–1.175] | 0.573 [0.560–0.599] | — |
| W8-004M | I-solver | — | 3968326 (last at tieCollection) | 15.639 [12.247–19.817] | 1.275 [0.706–1.461] | 1.259 [0.741–1.409] | 0.565 [0.551–0.792] | — |
| W8-016M | I-solver | — | 15863703 (last at tieCollection) | 50.834 [47.455–120.407] | 1.729 [1.328–2.695] | 1.734 [1.304–1.801] | 0.583 [0.556–1.079] | — |
| W8-064M | C | 64 | 54840071 | 622.167 [537.686–795.460] | 8.214 [6.844–11.771] | 7.238 [6.738–8.734] | 0.564 [0.555–1.051] | 4.747 [4.648–5.606] |

## Memory (V-O, fresh process per case)

Process-level `phys_footprint` observations; see the method under Observations. "peak − F1" is
not per-call allocation and not an upper bound on call-attributable memory.

| Case | F1−F0 MiB | peak−F1 MiB (max of 4 calls) | residual after release MiB | peak method |
|---|---:|---:|---:|---|
| W1-0001 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W1-0002 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W1-0008 | 0.2 | 0.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W1-0032 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W1-0064 | 0.2 | 0.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W1-0128 | 0.2 | 0.4 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W1-0256 | 0.5 | 0.8 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W1-0257 | 0.4 | 0.9 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W2a-02 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2a-03 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2a-04 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2a-06 | 0.2 | 0.3 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W2a-08 | 0.2 | 0.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W2a-09 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2a-10 | 0.3 | 0.3 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W2a-11 | 0.3 | 0.4 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W2b-2 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2b-3 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2b-4 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2b-5 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W2b-6 | 0.2 | 0.2 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W2b-7 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W3-000 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W3-010 | 0.3 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W3-025 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W3-050 | 0.2 | 0.3 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W3-100 | 0.3 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W3a-010 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W4a | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W4b | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W4c | 0.1 | 0.3 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W4d | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W5-1 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W5-2 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W5-3 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W5-4 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W5-5 | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W5t | 0.2 | 0.2 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W6-0000 | 0.1 | 0.3 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W6-0096 | 0.3 | 0.4 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W6-0384 | 1.1 | 1.4 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W6-1536 | 4.7 | 5.5 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W6-2844 | 6.3 | 6.8 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W6p-0384 | 1.3 | 1.4 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W7r-4096 | 0.3 | 2.0 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W7r-4097 | 0.2 | 2.3 | 0.3 | ledger_phys_footprint_peak (process lifetime) |
| W7e-2048 | 2.9 | 5.0 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W7e-2049 | 2.8 | 2.4 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W7o-2880 | 3.7 | 5.8 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W7o-2881 | 3.6 | 5.8 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W7c-23040 | 2.6 | 8.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W7c-23041 | 2.7 | 3.0 | 0.0 | ledger_phys_footprint_peak (process lifetime) |
| W7p-81 | 2.3 | 0.3 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W7p-82 | 2.9 | 0.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W8-001M | 0.3 | 0.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W8-004M | 0.2 | 0.2 | 0.1 | ledger_phys_footprint_peak (process lifetime) |
| W8-016M | 0.3 | 0.3 | 0.2 | ledger_phys_footprint_peak (process lifetime) |
| W8-064M | 0.1 | 0.3 | 0.2 | ledger_phys_footprint_peak (process lifetime) |

## Cancellation (V-O)

| Carrier | Target | δ | n | Landing stages | Observed at | Latency ms (median [min–max]) | Throw latency ms | Outcomes |
|---|---|---:|---:|---|---|---:|---:|---|
| W1-0256 | solve | 0.1 | 5 | solve (substage unverified) | inside solve (not visible to composition hooks) | — | 0.182 [0.163–6.062] | X |
| W1-0256 | solve | 0.5 | 5 | solve (substage unverified) | inside solve (not visible to composition hooks) | — | 0.231 [0.195–0.696] | X |
| W1-0256 | solve | 0.9 | 5 | after final checkpoint, solve (substage unverified) | inside solve (not visible to composition hooks), — | — | 0.137 [0.129–0.145] | C, X |
| W2a-03 | assessment | 0 | 3 | assessment (boundary self-cancel) | assessment | 0.000 [0.000–0.000] | 0.012 [0.011–0.012] | X |
| W2a-03 | capture | 0 | 3 | capture (boundary self-cancel) | capture | 0.000 [0.000–0.000] | 0.007 [0.007–0.008] | X |
| W2a-03 | closure | 0 | 3 | closure (boundary self-cancel) | closure | 0.000 [0.000–0.000] | 0.010 [0.009–0.011] | X |
| W2a-03 | configuration | 0 | 3 | configuration (boundary self-cancel) | configuration | 0.000 [0.000–0.000] | 0.008 [0.007–0.019] | X |
| W2a-03 | declarations | 0 | 3 | declarations (boundary self-cancel) | declarations | 0.000 [0.000–0.000] | 0.009 [0.009–0.011] | X |
| W2a-03 | endpoints | 0 | 3 | endpoints (boundary self-cancel) | endpoints | 0.000 [0.000–0.000] | 0.007 [0.006–0.007] | X |
| W2a-03 | entry | 0 | 3 | entry (boundary self-cancel) | entry | 0.000 [0.000–0.008] | 0.009 [0.008–0.025] | X |
| W2a-03 | evidence | 0 | 3 | evidence (boundary self-cancel) | evidence | 0.000 [0.000–0.000] | 0.011 [0.011–0.012] | X |
| W2a-03 | preparedInput | 0 | 3 | preparedInput (boundary self-cancel) | preparedInput | 0.000 [0.000–0.000] | 0.013 [0.012–0.014] | X |
| W2a-03 | scope | 0 | 3 | scope (boundary self-cancel) | scope | 0.000 [0.000–0.000] | 0.007 [0.006–0.007] | X |
| W2a-03 | solve | 0 | 3 | solve (boundary self-cancel) | solve | 0.000 [0.000–0.000] | 0.016 [0.016–0.017] | X |
| W2a-03 | viewValidity | 0 | 3 | viewValidity (boundary self-cancel) | viewValidity | 0.000 [0.000–0.000] | 0.006 [0.006–0.014] | X |
| W2a-08 | solve | 0.1 | 5 | after final checkpoint, solve (substage unverified) | inside solve (not visible to composition hooks), — | — | 0.097 [0.092–0.257] | C, X |
| W2a-08 | solve | 0.5 | 5 | after final checkpoint, solve (substage unverified) | inside solve (not visible to composition hooks), — | — | 2.225 [2.225–2.225] | C, X |
| W2a-08 | solve | 0.9 | 5 | after final checkpoint, solve (substage unverified) | inside solve (not visible to composition hooks), — | — | 0.902 [0.131–1.673] | C, X |
| W7o-2880 | assessment | 0.1 | 5 | after final checkpoint, assessment, preparedInput | assessment, preparedInput, — | 6.270 [3.099–9.706] | 6.976 [3.582–10.669] | C, X |
| W7o-2880 | assessment | 0.5 | 5 | assessment, preparedInput | assessment, preparedInput | 8.480 [0.906–10.848] | 9.307 [1.325–11.502] | X |
| W7o-2880 | assessment | 0.9 | 5 | preparedInput | preparedInput | 4.644 [3.246–9.568] | 5.087 [3.664–10.052] | X |
| W7o-2880 | closure | 0.1 | 5 | closure | closure | 6.861 [4.353–11.634] | 7.706 [4.610–11.894] | X |
| W7o-2880 | closure | 0.5 | 5 | assessment, closure, evidence, preparedInput | assessment, closure, evidence, preparedInput | 2.212 [0.166–9.042] | 2.475 [0.442–9.500] | X |
| W7o-2880 | closure | 0.9 | 5 | assessment, preparedInput | assessment, preparedInput | 3.789 [0.630–9.215] | 4.220 [0.891–9.907] | X |
| W7o-2880 | evidence | 0.1 | 5 | assessment, evidence, preparedInput | assessment, evidence, preparedInput | 3.028 [0.447–5.915] | 3.274 [0.709–6.334] | X |
| W7o-2880 | evidence | 0.5 | 5 | assessment | assessment | 2.296 [1.819–5.716] | 2.553 [2.080–6.004] | X |
| W7o-2880 | evidence | 0.9 | 5 | after final checkpoint, preparedInput, solve (substage unverified) | inside solve (not visible to composition hooks), preparedInput, — | 6.714 [4.636–8.030] | 6.267 [1.294–9.308] | C, X |
| W7o-2880 | preparedInput | 0.1 | 5 | preparedInput, solve (substage unverified) | inside solve (not visible to composition hooks), preparedInput | 7.780 [5.225–10.910] | 6.585 [0.724–11.367] | X |
| W7o-2880 | preparedInput | 0.5 | 5 | after final checkpoint, preparedInput, solve (substage unverified) | inside solve (not visible to composition hooks), preparedInput, — | 6.619 [1.355–7.667] | 4.600 [1.131–8.400] | C, X |
| W7o-2880 | preparedInput | 0.9 | 5 | after final checkpoint, preparedInput, solve (substage unverified) | inside solve (not visible to composition hooks), preparedInput, — | 7.119 [5.437–8.801] | 3.487 [0.882–9.495] | C, X |
