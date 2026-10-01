# Simulator app-startup attribution — 2026-10-01

Actual Simulator attribution is complete; P2-S8 and Phase 2 remain open.
This report reconciles the interrupted run without repeating measurements.

## Requirement and method

ROADMAP Phase 2 Performance Tasks require **app startup impact**. P2-S8 also
requires measured storage choice, no repeated full parsing, reopen, data-version
and retirement migration tests. Physical cold-launch, search, memory and offline
checks remain P2-S11 requirements, subject to specific-device authorization under
AGENTS §22. DEC-072's recommendation to revisit the choice if iPhone measurements
change the balance does not replace those checks. Five pairs are our measurement
method, not an accepted performance threshold.

Release `-O`, Swift 5, Xcode 27; iPhone 17 Simulator, iOS 26.5 (23F77), on Apple M2,
16 GiB, macOS 26.6.2. Invented launch-sized data: 258 stations, 15 lines, two
operators, six aliases; 184,320 bytes. One installed binary and artifact for all
samples. Preparation/build/install are outside timing; OS caches uncontrolled.
Process-cold is not guaranteed storage-cold. Same automation overhead in both modes.

The compile-flagged probe schedules a detached task from app initialization. Normal
`@concurrent` repository open performs all validation off the main actor; initial
rendering does not wait for it. No production data wiring, validation bypass or
result cache was added. Source inspection confirms the absence of main-actor file
reads/awaits in the startup hook; this is not a thread-profiler claim.

Instruments' Simulator lifecycle table was empty, so its captures were excluded.
A separate measurement-only UI-test runner used `XCTApplicationLaunchMetric()` to
measure the first displayed frame. Five pairs alternated baseline/enabled order;
XCTest preliminary launches are excluded from its recorded metric. All ten
measurement tests passed. [All recorded samples and hashes](results.json) are
retained; [method](METHOD.md) records the collection correction. No responsiveness
metric is claimed. Original logs, traces, result bundle and runner sources remain
owner-only, outside Git.

## Measured results

Milliseconds, median [minimum–maximum]:

| Metric | Baseline | Repository enabled |
|---|---:|---:|
| Launch → first frame | 841.142 [783.752–906.693] | 818.334 [805.860–844.312] |
| Open including validation/context preparation | N/A | 37.832 [36.654–64.216] |
| First exact query | N/A | 0.120 [0.103–0.173] |
| App-init hook → repository ready | N/A | 40.326 [39.354–68.313] |

Paired enabled-minus-baseline first-frame delta: median **+3.170 ms**, range
**−80.069 to +22.108 ms**. No improvement or regression is demonstrated. The
unpaired medians are not the paired effect. Open timing includes validation and
context preparation; no validator-only timing is invented. Readiness is relative
to the app-init hook, not process launch. These are not physical-iPhone results.

Every enabled probe asserted one validation pass, zero explicit full loads and
two distinct same-name search results. Installed executable and artifact hashes
remained unchanged. Ten saved checks and five pairs were reused in recovery;
no tests, builds or measurements were repeated.

## Preservation and remaining gates

Original branch `phase/02-static-data`, HEAD `31732d7`, zero ahead/behind tracked
upstream. Recovery matched all 229 pre-startup files except the expected app-entry
hook; no files were missing. Only the expected probe, method and attempted runner
were added during measurement. Existing SQLite/transition implementation and prior
measurements match saved fingerprints. Nine saved evidence hashes and exported
metric values were checked before preserving originals in durable owner-only
storage. Machine-specific paths, logs and device identifiers are excluded here.

Physical cold-launch/search/memory/offline checks remain outstanding. Follow the
[device procedure](../DEVICE_PROCEDURE.md) only after authorization identifies a
specific supported iPhone; never use the reserved device. Registry-of-record,
production IDs, real-data delivery, Q3/Q4 and publication/bundling gates remain
unchanged. No completion declaration, real-data changes, commit, push or merge.
