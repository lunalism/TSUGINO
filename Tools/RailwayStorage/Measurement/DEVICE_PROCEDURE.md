# Remaining paired app-startup and physical-iPhone procedure

This is the retained physical-device procedure. The owner subsequently authorized
one specific iPhone 17 Pro Max; its completed synthetic workload and five-pair
startup cohorts are recorded in [Physical/RESULTS.md](Physical/RESULTS.md).
The [Simulator startup report](Startup/RESULTS.md) remains separate evidence.
ROADMAP's Phase 2 Performance Tasks require app-startup attribution, and its
Physical Device Test requires cold launch, search speed, memory and offline search.
CLI timing cannot replace those checks. Future physical steps still require
specific-device authorization; completed evidence is not ongoing device access.
`LunaTestphone` must never be used.

## Authorization and instrumentation for a future run

The owner must identify one permitted supported iPhone and authorize installation,
launch and Instruments recording on that device. Record model, iOS, available
memory/storage, power/thermal state and the exact approved device identifier in
owner-only evidence. Do not enumerate or select another device automatically.

Normal app composition does not open a railway repository. The completed Simulator
run used the `REPOSITORY_STARTUP_MEASUREMENT` compile flag and
`--repository-startup baseline N` / `--repository-startup enabled N` arguments.
The enabled probe opens the prepared launch artifact in its measurement sandbox.
Keep the probe out of shipping builds and do not choose final dependency wiring:

- Compile one optimized app binary from the same source revision with a dedicated
  measurement-only flag. Default behavior stays unchanged. Use the existing baseline/enabled modes. The current probe has no separate
  history-mode argument; a history follow-up requires explicitly installing and
  identifying that synthetic artifact before a separate set of pairs.
- Baseline: normal app launch with the hook inert. Enabled: start the repository's
  normal async open from the same declared startup point, off the main actor,
  then perform the fixed `Invented Same` exact query. Never disable validation.
- Record hook-relative open start/end and first-query durations separately;
  these are not process-launch-relative. For process launch timing, use XCTest launch metrics (the functioning path used
  here) or Instruments App Launch for first-frame/responsiveness attribution. A SwiftUI `onAppear` timestamp alone is
  not a first-frame measurement. Record both first frame and data-ready time.
- Record existing validation/full-load/decode counters and current/peak memory.
  Do not add a result cache or otherwise change repository behavior.
- Copy only the already prepared invented launch artifacts into this test app's
  sandbox; preserve byte hashes. Do not bundle provider data or modify a real
  registry. Use the same binary and installation within each paired artifact cohort.

The startup hook and separate measurement-only workload mode have now been run
on the specifically authorized device. Existing correctness/build records remain
separate from physical measurements. Do not rerun passed workloads solely to
collect startup metrics.

## Verified runner preflight correction (2026-10-01)

The authorized physical runner was installed and correctly signed, but SpringBoard
reported `Profile Needs Network Validation`. The generic Xcode trust message did
not establish a missing Settings trust button. One launch of the unchanged runner
while the owner temporarily enabled connectivity succeeded; the same installation
then launched offline after Wi-Fi was disabled again. For this observed state,
resolve network validation as setup **before** the offline timing cohort. Do not
weaken signature validation, repeatedly request nonexistent trust settings or
assume all future signatures are permanently authorized offline.

Use documented `UseDestinationArtifacts` in a separate test-run descriptor to
reuse the verified installed runner/application without installation. A bounded
offline baseline/enabled connection check passed 2/2; it is not the full five-pair
measurement set. Keep preflight/setup, original failed attempts and recovery checks
separate from performance samples. Existing app data remains untouched.

## Run sequence after that authorization

1. Record artifact/executable/source hashes, build optimization, device/OS,
   instrumentation versions and test conditions. Establish normal thermal state;
   do not combine the measurement with builds or unrelated intensive tasks.
2. Enable airplane mode and disable Wi-Fi. Confirm the prepared artifact is local.
   Do not reboot, purge caches or claim disk-cold behavior unless a separate
   explicitly documented procedure actually does so.
3. For five paired repetitions, fully terminate the app between each launch.
   Alternate baseline/enabled order. Measure the baseline and launch-sized
   repository mode separately, retaining every sample and outlier. Repeat the
   same five pairs for the launch-sized transition-history artifact, reusing the
   recorded baseline only if conditions remain the same; otherwise collect new
   paired baselines. Do not treat force-quit/process-cold as guaranteed storage-cold.
4. For each pair, record launch→first frame, launch→responsive, repository open,
   first exact query, hook→data ready, and paired first-frame/responsive deltas.
   Launch→data ready requires a shared process-start clock and is unavailable in
   this probe; do not relabel hook-relative timing.
   Baseline has no repository data-ready time; do not subtract unrelated CLI time
   from an app launch measurement.
5. In a separate workload process (not inside startup timing), run the same 1,024-query sequence, one priming pass and
   three timed passes. Verify same-name two-result and exact composed/decomposed
   behavior, whitespace alias and misses. Record query median/p95, current/peak
   memory at each pass, counter deltas, close/reopen and retained Domain load.
6. Confirm all queries work offline, no source is acquired, ordinary validation/
   full-load counts do not grow, and input artifact hashes remain unchanged.
7. Report all samples plus median/range and observed thermal/cache limitations.
   There is no accepted numeric startup/memory threshold to invent. A material
   issue requires an evidence-backed bounded fix and affected checks, not relaxed
   validation. Keep this evidence separate from production-registry and
   publication/bundling authorization.

A Simulator rehearsal may validate the hook and collection method first, using
an explicitly selected iPhone Simulator. It must remain labeled Simulator and
cannot close the physical-device criterion. No UI search feature is needed for
these repository-driven measurements.
