# Validated SQLite repository results — 2026-10-01

These are **optimized macOS CLI repository measurements**, including normal open
validation. They are not app startup, Simulator timing or physical-iPhone results.
[Predeclared method](METHOD.md), [all final samples/fingerprints](results.json),
and [complete pre-fix samples](before-membership-fix.json) retain the evidence.

Environment: Apple M2, 16 GiB RAM, macOS 26.6.2, Swift 6.4 in language mode 5,
`-O`, system SQLite 3.51.0. Five fresh-process samples per case, alternating
baseline/history order; no concurrent builds/tests during the timed runs. OS
caches and unrelated host activity were uncontrolled. Artifacts used the system
temporary filesystem. Preparation at the workspace returned `unavailable`; its
precise cause is unverified, and hard-link probes succeeded at both locations.
Do not treat the temporary-filesystem result as proof of workspace publication.

Launch data: 258 stations / 15 lines / 2 operators / 6 explicit aliases. Scale:
25,800 / 1,500 / 200 / 600. Every value/ID is invented. The history case applies
one reviewed replacement: active counts stay constant, one retired ID and a
second build revision are retained. It is not a maximum-history stress test.

Values below are **median [minimum–maximum]**, five samples. Preparation and
fixture/input encoding are excluded from runtime timings.

## Runtime timing

| Active stations / case | Artifact bytes | Open + validation ms | First query ms | Open + first query ms | Full Domain load after open ms |
|---|---:|---:|---:|---:|---:|
| 258 / baseline | 184,320 | 23.86 [21.61–32.56] | 0.116 [0.097–0.163] | 23.97 [21.71–32.73] | 3.50 [3.21–5.92] |
| 258 / reviewed history | 184,320 | 23.74 [21.58–31.36] | 0.097 [0.088–0.223] | 23.84 [21.67–31.48] | 3.52 [3.20–5.27] |
| 25,800 / baseline | 15,974,400 | 2245.84 [1799.65–2694.97] | 0.657 [0.633–0.795] | 2246.63 [1800.30–2695.62] | 448.59 [317.96–544.70] |
| 25,800 / reviewed history | 15,974,400 | 2178.05 [1802.64–2948.52] | 0.808 [0.576–1.816] | 2178.86 [1803.21–2949.89] | 344.21 [325.60–444.90] |

The full-load sample is a separate fresh process; it retains all returned
stations/lines/operators through memory sampling. Line/operator context has
already been loaded during open, so the post-open full-load time largely decodes
stations. Raw samples retain that process's separate open time too.

| Active stations / case | Warm per-query median ms | Warm p95 ms | Close ms | Reopen ms | Query after reopen ms |
|---|---:|---:|---:|---:|---:|
| 258 / baseline | 0.036 [0.030–0.045] | 0.056 [0.050–0.115] | 0.128 [0.097–0.211] | 18.06 [17.35–27.34] | 0.101 [0.061–0.139] |
| 258 / reviewed history | 0.036 [0.030–0.043] | 0.056 [0.049–0.089] | 0.115 [0.098–0.155] | 19.64 [17.43–26.18] | 0.087 [0.062–0.124] |
| 25,800 / baseline | 0.220 [0.178–0.227] | 0.434 [0.345–0.536] | 0.536 [0.415–1.198] | 2491.43 [1777.92–2856.22] | 0.711 [0.576–0.948] |
| 25,800 / reviewed history | 0.198 [0.177–0.209] | 0.420 [0.341–0.621] | 0.474 [0.434–0.572] | 2249.39 [1751.22–2615.60] | 0.633 [0.576–1.445] |

Warm samples are 3×1,024 exact queries after one priming pass. Per-process p95s
are summarized across five processes, not pooled into a synthetic global p95.
Full scalar-exact and same-name/alias correctness checks passed; every timed
workload consumed exactly 2,688 results. Reopen performs complete validation
again, and preserved the same exact first-query identities/order.

## Memory and ordinary-access work

| Active stations / case | Ordinary peak RSS MiB | Full-load process peak RSS MiB | RSS change: primed → third warm pass MiB |
|---|---:|---:|---:|
| 258 / baseline | 11.73 [11.67–11.81] | 11.66 [11.59–11.70] | 0.047 [0.000–0.047] |
| 258 / reviewed history | 11.70 [11.66–11.84] | 11.61 [11.53–11.69] | 0.031 [0.000–0.078] |
| 25,800 / baseline | 202.91 [202.66–203.53] | 202.64 [200.05–206.00] | 0.047 [0.000–0.078] |
| 25,800 / reviewed history | 202.88 [202.47–203.47] | 202.86 [202.75–202.89] | 0.031 [0.000–0.078] |

Process peak includes open/validation and cannot attribute allocation to one
phase. Current RSS samples before/after open, after priming, each warm pass,
full load and reopen are retained in JSON. An untimed metadata/identity inspection
checks fixture correctness before warm queries; memory peaks include that work.
The small warm RSS changes include the harness's timing array, allocator behavior
and page granularity; they are not leak proofs or isolated repository allocations.
Reopen samples retain the closed first repository object until the end of the
process, so they do not measure memory reclamation after releasing that object.

Across **all 20 final ordinary samples**:

| Observed or inspected operation | At open | Ordinary query-phase delta | At reopen |
|---|---:|---:|---:|
| Measured complete artifact validation invocations | 1 | 0 | 1 on new connection |
| Measured explicit full station-load calls | 0 | 0 | 0 |
| Measured queried station-record decodes | 0 | 3,589 including first/correctness/priming/timed queries | 2 for first query |
| In-memory exact-index oracle construction, derived from one call per validation | 1 | 0 | 1 |
| Persisted SQL index rebuild/write, established by read-only code path | 0 | 0 | 0 |

The oracle/write rows are source-derived, not a newly instrumented rebuild
counter. Runtime never reads provider inputs; ordinary access does not repeatedly
decode the complete station dataset. Explicit full-load mode intentionally does
one all-stations decode and is measured separately. No check was disabled.

## Setup and history overhead

| Active stations / case | Fixture + input encoding ms | Baseline artifact build ms | Additional reviewed transition build ms | External history bytes |
|---|---:|---:|---:|---:|
| 258 / baseline | 5.89 [4.11–9.75] | 53.85 [39.48–57.79] | — | — |
| 258 / reviewed history | 5.87 [5.01–8.06] | 45.00 [38.89–58.93] | 79.83 [65.43–100.82] | 57151 |
| 25,800 / baseline | 473.59 [383.06–529.10] | 3764.34 [3065.12–5964.42] | — | — |
| 25,800 / reviewed history | 509.45 [461.97–696.18] | 3620.11 [3128.93–4115.72] | 7011.73 [6013.39–9396.80] | 5502151 |

Transition preparation includes review/snapshot/history validation, a new artifact
and staged reopen/publication; it is not runtime startup cost. Runtime metadata
is 467 bytes in baseline versus 1,092 bytes with history. Full editorial history
is external: 57,151 bytes at launch size and 5,502,151 bytes at scale. Both runtime
cases occupy the same number of SQLite pages (180 KiB / 15.23 MiB). The overlapping
open-time ranges do not establish a measurable one-boundary history penalty.
This does not prove that maximum supported history has no overhead.

## Bounded measured fix

The original membership validator scanned every station for every line: 3,870
probes at launch size and 38,700,000 at scale. It now accumulates declared members
once and compares the same exact membership sets against each line topology.
Both-direction rejection, valid shared membership, unknown context, scalar keys,
stable order and complete Domain/transition correctness remain covered.

| Scale case | Original open ms | Final open ms | Original peak RSS MiB | Final peak RSS MiB |
|---|---:|---:|---:|---:|
| 25,800 / baseline | 5276.42 [4747.48–6435.99] | 2245.84 [1799.65–2694.97] | 200.38 [200.27–200.44] | 202.91 [202.66–203.53] |
| 25,800 / reviewed history | 5393.40 [4888.31–6341.03] | 2178.05 [1802.64–2948.52] | 200.33 [198.84–200.86] | 202.88 [202.47–203.47] |

Observed scale medians improve substantially, with about 2.5 MiB more peak RSS
for the membership map. These sequential cohorts have uncontrolled host/cache
variation; do not claim a statistical confidence interval or attribute every
millisecond of difference to the fix. Launch-sized timings overlap. Even after
the fix, 100× validation takes seconds and about 203 MiB peak RSS on this Mac;
that is a capacity warning, not evidence of acceptable iPhone startup.

All four runtime artifact hashes remain identical before/after the fix and
across all five preparations. Reads leave artifacts unchanged. Existing
prototype files remain untouched. The earlier prototype's 3.08/95.96 ms SQLite
open-plus-first-query medians used different fixtures, caching and validation;
no controlled speed ratio or regression claim against them is valid.

## Verification and accepted-criteria audit

Before modification, all 175 saved correctness source fingerprints matched.
After the bounded fix: the synthetic storage/transition runner passed, **25/25**
affected name-tool cases passed, and **8/8** focused Simulator index/repository
tests passed (zero failures/skips), including new membership regressions.
The optimized measurement harness compiled and all **40 total pre/post samples**
passed behavior/read-immutability checks. No broad suite, clean app build, UI
feature or physical-device work ran. Earlier full suites/Release results remain
historical; they are not claimed to have been rerun on this optimization.

**Met:** measured storage decision; final validated-repository artifact/open/query/
load/memory/reopen evidence at both sizes and a representative history case;
ordinary-use no repeated full parse; unchanged deterministic artifacts; existing
version/migration/history correctness, rechecked through the affected runner.

**Remaining technical evidence:** actual paired baseline/repository-enabled app
startup attribution and physical-iPhone cold launch/search/memory/offline checks.
The app has no repository startup hook today. [Exact minimal procedure and its
instrumentation/device prerequisites](DEVICE_PROCEDURE.md) cover that remaining
work. The slice-specific synthetic repository criteria pass, but these macOS
measurements do not close broader Phase 2 app/device acceptance. P2-S8 and Phase 2
are not declared complete; no accepted criterion was waived.

**Separate gates:** production registry/IDs, real repository delivery, Q3
publication, Q4 new Metro-derived translation and ODPT item 5 bundling remain
unchanged. No real artifacts, production IDs, acquisition, distribution, commit,
push or merge occurred.
