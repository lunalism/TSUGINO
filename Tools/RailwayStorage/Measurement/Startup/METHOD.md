# Simulator app-startup attribution — method declared before runs

Scope: P2-S8 synthetic measurement only. One Release (-O) app binary compiled
with REPOSITORY_STARTUP_MEASUREMENT, baseline/enabled arguments, explicit iPhone
17 iOS 26.5 Simulator. No production composition change or bundled dataset.
Launch dataset: 258 stations, 15 lines, 2 operators, six aliases from the existing
deterministic builder. Copy into the measurement installation's sandbox.

Five paired process-cold launches, alternating baseline/enabled order. Force
terminate between launches. Same installation/artifact/binary/instrument template.
No cache purging: filesystem/dyld/Simulator/host caches are uncontrolled. Record
all samples and median/min/max; no numeric acceptance threshold is invented.
Build, artifact generation, install and trace export are excluded from runtime.

Use Instruments App Launch system events for launch-to-first-frame/responsive
attribution where exposed. Never substitute onAppear or an app-init timestamp for
first frame. Record any unavailable metric as unavailable. App probe independently
records init-hook-relative open start, open+normal validation completion, first
exact query duration and repository-ready time. Open includes all validation and
context preparation: no separate validator-only timer is claimed. Record original
monotonic hook time for correlation. Baseline performs no repository work. Results
are written only after measurements on a detached task. Assertions require two
separate same-name results, one validation pass and zero full-load calls.

Instrumented modes do not block the main actor or first rendering. The hook only
schedules work; no file read or await occurs in App.init. Code is absent unless the
measurement compilation flag is explicitly set. Physical-device follow-up is
separate, requires a named authorized device, and is never inferred from Simulator
results. Previous macOS measurements remain separate evidence.

## Actual collection method and recovery

The App Launch template exposed an empty Simulator lifecycle table; its diagnostic
traces are not samples. Collection used a separate Release UI-test runner launching
the same installed app by bundle identifier, with `XCTApplicationLaunchMetric()`
for first frame. Installed Xcode 27 `XCTMetric.h` documents that default initializer
as time to display the first frame; responsive-to-input timing is a separate metric
and was not measured here. Ten serial tests recorded five alternating pairs, one
metric iteration each after XCTest's preliminary launch. Last-launch probe records
were reconciled against the saved metric CSV exports. No measurements were repeated
during recovery. Raw logs, result bundle, original report, runner source and exact
source fingerprints are retained in durable owner-only evidence, outside Git.
The earlier `run.py` is retained as the attempted Instruments collection method;
it is not the successful first-frame measurement runner.
