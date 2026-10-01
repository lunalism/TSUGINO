# Authorized physical-iPhone checks — 2026-10-01

**Bounded synthetic physical startup and workload evidence is collected.
P2-S8 overall and Phase 2 remain open for the separate gates below.** This is the authorized iPhone 17 Pro Max, not Simulator.

## Device, preparation and boundaries

Exact paired identity matched the earlier owner-only inventory. Live device
checks confirmed USB, booted state, iOS 27.0 and Developer Mode after the owner
completed its restart/confirmation. Deployment target is iOS 18, device family
is iPhone; the signed optimized Release app and extension build passed for this
specific device. No other physical device was targeted. Initial scoped app
inventory found no installed TSUGINO app. Installation and the later measurement
update were in place; no uninstall, reset or app-container deletion occurred.
Temporary signing overrides were command-line-only; project settings are unchanged.

The owner confirmed Airplane Mode on, Wi-Fi off, cable connected and device
unlocked. All workload network checkpoints were `NWPathMonitor.unsatisfied`.
This did not send test network requests. All 20 before/after condition checkpoints
were thermal state nominal, battery 100%/charging and Low Power Mode off. Reported
physical memory was 12,263,424,000 bytes, available filesystem space
106,905,600,000 bytes. Raw device identity, profiles, logs and source snapshots
remain in durable owner-only evidence outside Git.

The existing compile-flagged startup probe gained only a separate device-workload
mode. The enabled startup path and repository validation are unchanged. New work
runs in a detached task / concurrent function; battery-property sampling uses only
a small main-actor read. Production composition never enables this probe.
A bounded incremental measurement build added free-storage condition reporting
before collecting any performance samples. Existing Simulator and correctness
results were reused; no broad suite was rerun.

## Completed offline workload

[Predeclared method](METHOD.md); [all samples and summaries](workload-results.json).
Launch-sized invented data: 258 stations, 15 lines, two operators, six aliases.
Two 184,320-byte cohorts: ordinary runtime artifact and one with an actually
applied synthetic replacement, one retained retirement and two build revisions.
Five fresh workload processes each, one 1,024-query priming pass and three timed
passes per process. Preparation/build/install/copy excluded; OS caches uncontrolled.
The final workload completed before the launch-runner build began. The preliminary
smoke check is excluded. No accepted numeric performance threshold is invented.

Median [minimum–maximum], milliseconds unless noted:

| Metric | Ordinary artifact | Transition history artifact |
|---|---:|---:|
| Open including validation | 24.164 [14.471–29.800] | 19.711 [15.990–27.724] |
| First exact query | 0.061 [0.050–0.144] | 0.069 [0.044–0.116] |
| Per-run warm-query median | 0.0129 [0.0125–0.0130] | 0.0126 [0.0123–0.0127] |
| Per-run warm-query p95 | 0.0251 [0.0248–0.0364] | 0.0241 [0.0235–0.0244] |
| Reopen including validation | 9.432 [9.332–10.327] | 9.375 [9.295–9.614] |
| Full Domain load after reopen | 1.685 [1.624–1.840] | 1.697 [1.675–1.716] |
| Ordinary peak RSS, MiB | 31.875 [31.844–31.922] | 31.875 [31.812–32.141] |
| Peak RSS through full load, MiB | 32.141 [32.094–32.172] | 32.172 [32.094–32.375] |

Warm-pass RSS growth was 0…0.031 MiB ordinary and 0.016…0.047 MiB with history.
Snapshot RSS/process high-water are not physical footprint, allocation counts or
leak proof; full-load peak includes earlier work in that process. Query figures
summarize each run's median/p95, not a pooled percentile. Ranges overlap and do
not establish a history performance advantage. No first-frame timing follows
from these repository measurements.

All ten runs passed exact composed/decomposed distinction, explicit whitespace
alias and miss, two separate same-name results, stable ordering, close/reopen and
full Domain counts. Each consumed 2,688 results in the timed query passes. Every
ordinary-access interval retained one validation pass, zero full loads and 3,589
matched-station decodes. Reopen revalidated once; subsequent explicit Domain load
is separate. Persisted SQL index rebuilding is absent by source inspection, not
an invented counter. Artifact hashes matched before/after every workload; revision
and retirement counts matched the cohort. No real registry or artifacts were used.

## Startup rejection diagnosis and bounded resolution

The title-only screen matches Release AppShellView. The separate runner was
installed and its container accessible. Both it and TSUGINO used the same valid,
unexpired provisioning profile and developer certificate, with authorized device
inclusion and compatible entitlements. No missing Settings Verify/Trust button
was established. Xcode's generic “Developer App Certificate is not trusted” error
was an insufficient diagnosis; earlier requests to look for such a button did not
identify the cause.

The installed runner also failed through direct CoreDevice launch. A filtered
live Console stream from the specifically authorized phone then showed SpringBoard
reporting **`Profile Needs Network Validation`**, reason **`Requires Network
Validation`**, followed by `online-auth-agent` authentication. The relevant
accessibility-text observation is preserved as a labeled Console extract, not
misrepresented as a raw system logarchive. Original CoreDevice errors and saved
XCTest diagnostics are retained separately. CLI device-log archive collection
required unavailable root privileges; live Console provided the specific evidence.

After the owner temporarily connected Wi-Fi, the **same installed runner** launched
successfully, without rebuilding, re-signing, reinstalling, deleting data or
changing trust/security settings. The owner restored Wi-Fi off/Airplane Mode on;
the same runner then relaunched offline successfully. This isolates the immediate
blocker to incomplete network validation, not an observed bad signature or missing
manual trust setting. It does not establish a permanent offline authorization
lifetime or a policy for future newly signed builds.

Apple's installed `xcodebuild.xctestrun` documentation provides
`UseDestinationArtifacts`: existing installed test/app artifacts, no installation.
A separate owner-only test-run descriptor used that mode and selected only the
previously unrun baseline/enabled startup checks. **2/2 passed offline**, with
first-frame metrics exported and the enabled probe reporting one validation pass,
zero explicit full loads and two distinct same-name results. The synthetic artifact
remained byte-identical. This is a connection/recovery check, **not the prescribed
five-pair performance cohort**, not responsive-to-input evidence and not a new
improvement/regression claim. The previously passed ten workload processes,
Simulator checks and correctness suites were not rerun.

## Completed formal physical startup cohorts

The same authorized iPhone 17 Pro Max, iOS 27.0, ran the existing optimized
Release app and XCTest runner (Swift `-O`, Xcode 27) using
`test-without-building` and `UseDestinationArtifacts`. **40/40 passed**: five
alternating baseline/enabled pairs for each metric and each artifact. The 2/2
recovery checks, XCTest preliminary launches and earlier failed attempts are
excluded. Neither installed binary was rebuilt or reinstalled; no app data was
deleted. Only the dedicated synthetic fixture was exchanged between cohorts.
Prior measurement files were archived before their fixed filenames were reused;
each resulting cohort has its own retained container, result bundle and metrics.

[Method](METHOD.md); [all 40 samples, probe values and paired differences](startup-results.json).
Each launch was force-terminated. This is process-cold, with uncontrolled OS caches
and XCTest preliminary launches, not reboot/disk-cold. Collection was serial, with
setup/copy/export excluded and no concurrent builds or workload reruns.
Offline settings are the owner's continued confirmation of Airplane Mode on and
Wi-Fi off; scoped checks verified the same connected USB device. The startup probe
does not resample network, thermal or battery conditions. Earlier workload's 20
network/thermal snapshots belong to that workload, not these launches.

The installed SDK's `XCTMetric.h` defines default `XCTApplicationLaunchMetric`
as time to the first frame displayed; `waitUntilResponsive: true` includes first
frame display and main-thread readiness to accept input. In this title-only shell,
**responsive does not mean search-UI readiness, a successful interaction, or
measured touch latency**. Repository readiness is independently hook-relative,
not launch-relative. No common process-start timestamp is available to derive
launch-to-data-ready. The two launch metrics use different processes; do not
subtract their medians to invent a post-frame interval.

Milliseconds, median [minimum–maximum]; paired difference is enabled minus baseline:

| Artifact / metric | Baseline | Repository enabled | Paired difference |
|---|---:|---:|---:|
| ordinary / firstFrame | 135.314 [133.992–136.728] | 135.486 [132.700–137.626] | -0.885 [-2.614–3.634] |
| ordinary / responsive | 133.638 [133.023–137.980] | 134.537 [132.049–137.638] | -1.006 [-2.075–4.000] |
| history / firstFrame | 134.998 [132.608–137.749] | 135.203 [132.641–136.280] | 0.205 [-5.108–2.858] |
| history / responsive | 132.964 [131.989–138.533] | 134.652 [133.899–136.126] | 1.538 [-3.881–4.138] |

All five paired differences, milliseconds, in collection-pair order:

- ordinary / firstFrame: +0.204, +3.634, -0.885, -1.791, -2.614.
- ordinary / responsive: +4.000, -2.075, +0.952, -1.994, -1.006.
- history / firstFrame: +2.858, +0.205, +1.958, -3.664, -5.108.
- history / responsive: +1.538, +2.807, -3.881, -2.531, +4.138.

No accepted numeric threshold is invented. The small cohorts have overlapping
ranges and mixed paired signs; they establish neither improvement nor regression,
nor statistical equivalence. Responsive medians below first-frame medians reflect
separate launches and sampling variation, not reversal of the metric endpoints.

Enabled-process probe timings, milliseconds, median [minimum–maximum]:

| Artifact / launch metric | Open including validation | First exact query | Ready after app-init hook |
|---|---:|---:|---:|
| ordinary / firstFrame | 40.928 [38.112–44.438] | 0.099 [0.061–0.206] | 43.371 [40.751–46.901] |
| ordinary / responsive | 41.210 [39.952–42.796] | 0.100 [0.059–0.132] | 43.859 [42.542–46.359] |
| history / firstFrame | 40.905 [40.291–42.205] | 0.094 [0.068–0.116] | 43.467 [43.094–44.997] |
| history / responsive | 42.187 [40.818–44.005] | 0.082 [0.056–0.150] | 44.618 [43.141–46.431] |

All 20 enabled launches reported status OK, one validation pass, zero explicit full
loads and two distinct same-name matches. The unchanged startup hook dispatches
repository open/validation/query off the main actor. Main-thread first rendering
does not await repository readiness. Probe files are the final launch per test;
their readiness is not falsely aligned to a process-relative XCTest timestamp.

Both artifacts remained 184,320 bytes and matched their prepared source before
and after each cohort:

- ordinary: SHA-256 `094d8985ae8260562cea8e7dcd839b4265837a2e466659ed1b1dc6fee61e1642`.
- history: SHA-256 `598266e674d6fd7ef17dab028478e50e04b0e64b7b45bbd1f7dbada4f4e90615`.

The recorded built app executable hash also remained unchanged. Raw device/signing
identity, test logs, archived containers and collection descriptors remain
owner-only outside Git. Public samples contain only invented data and safe metrics.
Instruments' previous attachment timeout was not retested or claimed fixed;
XCTest supplied the documented first-frame/responsive metrics.

## Accepted-criteria audit and remaining gates

ROADMAP's P2-S8 criterion requires a measured storage decision, a test proving no
ordinary full static-data reparsing, and passing reopen/data-version/identifier-
retirement migration tests. DEC-072/073 and the existing verification record cover
those synthetic checks, including actually applied transitions, atomic failure,
retained authority/history, reopen and byte-identical reruns. They were not rerun.
Final validated-repository macOS measurements, Simulator startup attribution,
the ten physical offline workload processes and these startup pairs now supply
the requested bounded synthetic performance/device evidence. The current title-only
shell has no search UI; exact-search speed/correctness/offline evidence is through
the repository, as required for this slice. Cache/telemetry limits above remain.
No additional mandatory synthetic technical measurement is identified by the
accepted criteria; future shipping composition may need new startup attribution.

**P2-S8 overall and Phase 2 remain open.** Registry-of-record/production-ID decision,
real repository delivery, Q3 publication, Q4 new Metro-derived translations and
ODPT item 5/app-bundling gates remain unchanged. Synthetic device evidence neither
promotes provisional IDs nor authorizes distribution. Phase 2 exit also needs its
separate scope/exit audit, including the unresolved S9/S10 planning relevance.
No real artifacts, code changes, broad suite/build reruns, commit, push or merge
occurred in this continuation.
