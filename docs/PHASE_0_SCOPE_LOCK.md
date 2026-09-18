# TSUGINO — PHASE_0_SCOPE_LOCK.md

**Phase:** 0 — Project Bootstrap + Feasibility Baseline
**Repository:** `lunalism/TSUGINO` (GitHub)
**Local path:** `/Volumes/Data/dev/TSUGINO`
**Baseline:** `main` == `origin/main` == `9867038` (parent `24cd610`); working tree clean at branch creation
**Active branch:** `phase/00-bootstrap-feasibility`
**Platform:** iPhone only (DEC-044)
**Minimum deployment target:** iOS 18.0 (DEC-045)
**Date:** 2026-09-17
**Status:** Active

This is the Scope Lock required by `AGENTS.md` §5.1 (Anti-Drift Protocol) before substantial Phase 0 work begins. It restates the phase boundary from `ROADMAP.md` in executable terms. It does not change any living document; where it appears to disagree with one, the living document wins and this file must be corrected.

---

## 1. Phase Goal

From `ROADMAP.md` Phase 0:

> Create a clean iOS project and validate the highest-risk external dependencies before domain implementation expands.

Phase 0 has **two independent tracks** that share an exit criterion:

- **Track A — Bootstrap:** a buildable, testable, dependency-free iPhone-only Xcode project with the canonical folder skeleton, configuration, clock, logging, feature-flag foundation, and a Live Activity extension shell verified on a physical device.
- **Track B — Feasibility:** the provider audit and data-source/license registry (`docs/PROVIDER_FEASIBILITY_AUDIT.md`) advanced far enough that major provider risks are known.

---

## 2. Platform Scope Lock

> **iPhone only, iOS 18.0 minimum.** (DEC-044, DEC-045, Rule 51, Rule 52, AGENTS §5.2)

Concretely for Phase 0:

- `TARGETED_DEVICE_FAMILY` = iPhone (`1`) for the app target and the extension target.
- `IPHONEOS_DEPLOYMENT_TARGET` = `18.0` for the app target, the extension target, and all test targets; no `@available` branching below iOS 18.
- No iPad layouts, size-class branching for tablets, split-view, or iPad QA.
- Do not leave iPad enabled "because it happens to run."
- Verifying this exclusion is a Phase 0 acceptance criterion, not optional.

---

## 3. In Scope (Phase 0)

### 3.1 Track A — Bootstrap (ROADMAP "Included" + "Implementation Tasks")

- Xcode project with app target `TSUGINO` (SwiftUI), iPhone-only
- bundle identifier, signing, deployment target iOS 18.0 (DEC-045)
- basic app shell (launch → single placeholder screen; no product UI)
- Widget/Live Activity extension shell target (ActivityKit-capable), iPhone-only
- unit test target(s) mirroring ownership: at minimum `DomainTests` and `ApplicationTests` scaffolds may be created empty or with smoke tests
- **zero third-party dependencies** (no SPM packages, no CocoaPods, no Carthage)
- build configurations (Debug / Release at minimum) and `AppEnvironment` / `AppConfiguration` structure with no secrets committed (Rule 42)
- canonical folder structure from `ARCHITECTURE.md` §4 — **create only folders that receive a file in Phase 0**; do not create empty ceremony folders (ARCH §4.4)
- logging foundation (structured categories, `os.Logger`-based; ARCH §36, Rule 33)
- `Clock` abstraction with system and deterministic implementations (ARCH §38, Rule 38)
- feature-flag mechanism skeleton with owner/purpose/removal fields (ARCH §42, Rule 41) — no product flags yet
- initial physical-device build/install
- minimal **test** Live Activity that can be started and ended on device to confirm capability (throwaway content; not the product Live Activity)

### 3.2 Track B — Feasibility

- `docs/PROVIDER_FEASIBILITY_AUDIT.md` (created in this change)
- initial data-source/license registry (contained in the audit §7)
- verification actions A1–A6 from the audit §9, executed as **research without code in the app**
- Decision Gate inputs recorded (audit §10)

Track B status (2026-09-18):

- **B1 — transport and static acquisition: completed.** The four official Toei resources (GTFS Static; GTFS-RT TripUpdate, VehiclePosition, Alert) were acquired once from `api.odpt.org` with the Keychain-held developer token; GTFS Static arrived through a validated redirect to ODPT-operated storage without the credential. Static ZIP structure, CRCs, required files, identifier uniqueness, and internal references verified (audit §6.1.1).
- **B2 — semantic join proof: completed — PASS WITH LIMITATIONS.** Decoded against the canonical GTFS-Realtime 2.0 schema with temporary external tooling: Toei exact `trip_id` join static ↔ TripUpdate ↔ VehiclePosition was **116/116** in one snapshot, one-to-one, no collisions; static stop resolution from realtime `stop_sequence` succeeded for all observed records (3,200/3,200 stop-time updates; 116/116 vehicle positions).
- **B3 — short temporal study: completed — PASS WITH LIMITATIONS.** Six additional observation sets at ≈5-minute intervals over ≈25 minutes (19:15–19:40 JST, Friday weekday service); 18/18 requests succeeded, no retries or redirects. Exact TripUpdate ↔ VehiclePosition `trip_id` joins stayed **100%** in every snapshot; static trip and `stop_sequence` resolution stayed **100%**; headers advanced normally; no timestamp stale beyond 60 s and none future-dated; clean trip-set churn between snapshots; R5 absent in all six; Alerts empty in all six; vehicle status overwhelmingly `STOPPED_AT` with one `IN_TRANSIT_TO`. B2 + B3 = seven observed snapshots during one evening (audit §6.1.2) — not a multi-day or uptime study.
- **B4 — offline static route-coverage and localization audit: completed — PASS WITH LIMITATIONS.** Using only the verified static ZIP (no network, no credential): sanitized R5 is the **Nippori-Toneri Liner**; its realtime absence is **NOT SCHEDULE-EXPLAINED** — 11 scheduled trips overlapped the B2 instant and 23 overlapped the B3 window while realtime showed none; the reason remains unresolved and the line is not concluded unsupported. Static localization (`translations.txt`, JA/EN only): route names JA 6/6, EN 6/6, KO 0/6; canonical station names JA 141/141, EN 141/141, KO 0/141; trip headsigns JA/EN 54/54, KO 0/54. **TSUGINO must own Korean canonical names and Korean search aliases**; provider JA/EN strings remain input material rather than the sole source of truth (DEC-041, DEC-042, ARCHITECTURE §39.1). No code, localization resource, dependency, fixture, or raw data was added (audit §6.1.3).
- No source code, dependency, fixture, or project-setting was added; no raw payload, credential, signed URL, or scratch path was committed. **DEC-004 remains Provisional**; no provider is selected.
- Main pending items: all seven realtime snapshots from one evening (no multi-day/rush-hour/long-duration study); R5 realtime publication scope unresolved; missing-`trip_id` fallback; `STOPPED_AT`-dominant vehicle status unexplained; Alert content unobserved; through-service not assessed; Tokyo Metro degraded path untested; other operators' JP/EN/KO coverage and cross-operator canonical identity (A4); project-owned Korean dataset (implementation phase); commercial terms (A2); production decoder decision (RK-11).
- Next Track B evidence work: determine the provider's R5 realtime publication scope; evaluate Tokyo Metro's alerts-only degraded path; test cross-operator canonical station identity; prepare and separately review the project-owned Korean localization dataset during the appropriate implementation phase; confirm commercial and operational terms; plus, if required by the decision gate, a later multi-window observation and real Alert-content observation when naturally available.

### 3.3 Documentation

- Living documents are updated **only** if Phase 0 reveals something that changes current truth. The deployment-target decision (DEC-045), the 2026-09-17 documentation baseline repair, and the 2026-09-18 Simulator-first workflow rule (`AGENTS.md` §22) are the Phase 0 document changes to date. Otherwise they are not touched.

---

## 4. Explicitly Out of Scope (Phase 0)

From `ROADMAP.md` Phase 0 "Explicitly Excluded" plus project-wide rules:

- production route search or any route-provider client/DTO/adapter (Phase 3)
- production realtime tracking, ODPT/GTFS-RT client, protobuf decoding (Phase 4)
- `JourneyEngine`, Journey/Trip/Station domain models beyond what a smoke test needs (Phase 1, Phase 5)
- static rail data ingestion, station search, canonical mapping tables (Phase 2)
- persistence, `JourneyRepository`, SwiftData/SQLite decisions (Phase 6)
- design tokens, pixel assets, animation system (Phase 7)
- any product screen: Home, Station Search, Route Results, Train Selection, Active Journey (Phase 8)
- product Live Activity / Dynamic Island content or mapper (Phase 9)
- notifications, transfer guidance (Phase 10)
- localization resources beyond the default development language (Phase 11) — the `LanguageResolver` rule is documented, not implemented, in Phase 0
- **any third-party dependency**
- **iPad support in any form**
- App Store metadata, TestFlight distribution
- creating versioned or dated copies of documents (`*_v2.md`, `*_2026-09-17.md`); documents are revised in place

If any of the above appears necessary during Phase 0: **stop, explain, propose the smallest roadmap change, wait for approval** (AGENTS §5.1 "Phase Expansion Requires Approval", Rule 45).

---

## 5. Files / Subsystems Expected to Change

### 5.1 Documentation changes (Phase 0 baseline; project bootstrap is recorded in §5.2)

New:

- `docs/PROVIDER_FEASIBILITY_AUDIT.md`
- `docs/PHASE_0_SCOPE_LOCK.md`

Living documents touched by the 2026-09-17 baseline repair (minimal, current-truth only):

- `docs/DECISIONS.md` — DEC-045 added; DEC-041 status wording clarified
- `docs/PRODUCT.md` §7.1 — iOS 18.0 minimum
- `docs/ARCHITECTURE.md` §2.8 (iOS 18.0), §4 (`RouteProviders` candidates note), §5.2 (`RailwayLine.nameKorean`)
- `docs/ROADMAP.md` Phase 0 — deployment target iOS 18.0; Phase 3 — JP/EN/KO route content
- `docs/FEATURES.md` — duplicate §4.3 heading removed; §2.1 Station Search covers Japanese / English / Korean + canonical aliases
- `docs/DESIGN.md` §12 — Station Search covers Japanese / English / Korean; §34 — criterion 8 includes Korean

### 5.2 Track A project structure (Steps A1–A5 — as on disk)

Step A1 (native Xcode project bootstrap) is complete and GUI-validated; Step A2 (application infrastructure foundation) and Step A3 (Debug Live Activity bootstrap control) are implemented. The tree below is the **actual** structure, using the real filenames on disk; it follows `ARCHITECTURE.md` §4 ownership (`App/`, `Features/`, `Shared/`, `Resources/`) with only the folders that received a file.

```text
TSUGINO.xcodeproj/
├── project.pbxproj                          (objectVersion 77, file-system-synchronized groups)
└── xcshareddata/xcschemes/TSUGINO.xcscheme  (shared scheme: build app + extension, test TSUGINOTests)

TSUGINO/                                     (app target, com.lunalism.TSUGINO)
├── App/
│   ├── TSUGINOApp.swift                     (@main SwiftUI App; composition root builds AppEnvironment.live() once and injects it)
│   ├── Environment/
│   │   └── AppEnvironment.swift             (A2 — immutable composition root: configuration, clock, logging; SwiftUI @Entry)
│   ├── Configuration/
│   │   ├── AppConfiguration.swift           (A2 — BuildMode debug/release/test, typed AppConfigurationError, live() = single #if DEBUG site)
│   │   └── FeatureFlags.swift               (A2 — FeatureFlag enum w/ owner/purpose/removal criteria; FeatureFlags set; Release defaults all-off)
│   └── Debug/
│       ├── BootstrapActivityRequesting.swift        (A3/A5 — smallest ActivityKit boundary mirroring real semantics: throwing request, non-throwing async update/end, existingHandles() over the public `Activity.activities` collection, handle exposes current syntheticValue; ActivityKitBootstrapActivities is the app's only ActivityKit call site, pushType nil)
│       └── DebugLiveActivityBootstrapController.swift (A3/A5 — @MainActor @Observable controller: typed Status incl. `reconciling`, idempotent reconcile(), start/update/end, one retained handle; only `request` can fail, matching ActivityKit; visibility policy)
├── Features/
│   └── AppShell/
│       ├── AppShellView.swift               (root screen: "TSUGINO"; shows the debug section only when AppConfiguration says so)
│       └── DebugLiveActivityBootstrapSection.swift (A3/A5 — engineering control: Start/Update/End + typed status, accessibility IDs; runs reconcile() once per view identity and disables controls until it completes; not product UI)
├── Shared/
│   ├── LiveActivity/
│   │   └── TSUGINOLiveActivityAttributes.swift  (single ActivityAttributes type; also a member of the extension target)
│   ├── Time/
│   │   └── AppClock.swift                   (A2 — AppClock protocol, SystemAppClock, FixedAppClock; no timers/sleep)
│   └── Logging/
│       └── AppLogging.swift                 (A2/A3/A5 — LogCategory app/configuration/liveActivity, fixed LogEvent vocabulary incl. 14 bootstrap events (4 reconciliation), AppLogSink, os.Logger sink)
├── Resources/
│   └── Assets.xcassets/                     (AppIcon, AccentColor)
└── Info.plist                               (NSSupportsLiveActivities = YES; merged with generated plist)

TSUGINOLiveActivity/                         (Widget Extension target, com.lunalism.TSUGINO.LiveActivity)
├── TSUGINOLiveActivityBundle.swift          (@main WidgetBundle)
├── TSUGINOLiveActivity.swift                (ActivityConfiguration: Lock Screen + Dynamic Island, synthetic value only)
├── Assets.xcassets/                         (AccentColor, WidgetBackground)
└── Info.plist                               (NSExtension → com.apple.widgetkit-extension)

TSUGINOTests/                                (unit-test bundle, com.lunalism.TSUGINOTests, hosted by TSUGINO.app)
├── TSUGINOTests.swift                       (Swift Testing smoke test)
├── AppClockTests.swift                      (A2)
├── AppConfigurationTests.swift              (A2)
├── AppEnvironmentTests.swift                (A2)
├── AppLoggingTests.swift                    (A2/A3 — no unified-log assertions)
├── FeatureFlagsTests.swift                  (A2)
├── DebugLiveActivityBootstrapTests.swift    (A3/A5 — visibility policy, status labels, lifecycle policy and reconciliation policy via fakes)
└── Support/
    ├── RecordingLogSink.swift               (A2 — test-only AppLogSink; not in the app target)
    └── FakeBootstrapActivities.swift        (A3/A5 — test-only BootstrapActivityRequesting/Handle fakes; scripts zero/one/many pre-existing handles)
```

Accepted Step A1 implementation decisions:

- `.gitignore` includes `xcuserdata/`, `DerivedData/`, `*.xcuserstate`.
- Explicit `Info.plist` files for app and extension (with `GENERATE_INFOPLIST_FILE = YES`).
- Extension links `WidgetKit` / `SwiftUI` explicitly, mirroring Xcode's widget template.
- No App Group, no entitlements, no persistence, no `#Preview` blocks.
- Every target: `IPHONEOS_DEPLOYMENT_TARGET = 18.0`, `TARGETED_DEVICE_FAMILY = 1`, `SUPPORTS_MACCATALYST = NO`, `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO`, `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO`, automatic signing.

Test-target note:

- An **extension-specific unit-test target is deferred**: Xcode provides no natural native test-host structure for a widget/app extension, and adding one would introduce artificial project complexity.
- Shared `ActivityAttributes` behavior is currently covered through `TSUGINOTests` (the attributes file is a member of the app target).
- This deferral does **not** waive the Live Activity state-mapping tests required later (`ARCHITECTURE.md` §44.5, `ROADMAP.md` Phase 9); those will need their own ownership decision when the mapper exists.

Track A status:

- **Implemented (A1):** Xcode project, app shell, Live Activity extension shell, test target.
- **Implemented (A2):** `AppEnvironment`, `AppConfiguration`, clock abstraction (`AppClock`, as named in ARCHITECTURE.md §38), typed feature flags (one placeholder Debug-only flag `debugLiveActivityBootstrapControl`, off in Release and test), privacy-safe `os.Logger` logging foundation, and 25 deterministic tests. No `project.pbxproj` change was needed (synchronized folders).
- **Implemented (A3):** the Debug-only manual Live Activity bootstrap control — visible only for `buildMode == .debug` with `debugLiveActivityBootstrapControl` enabled (Release configurations reject the flag, so Release can never show it); start/update/end of a synthetic activity through `ActivityKitBootstrapActivities` (`pushType: nil`, no App Group, no tokens, no persisted IDs); 18 deterministic tests using fakes (the boundary has no artificial update/end failure paths). `TSUGINOLiveActivityAttributes` is declared `nonisolated` so its `ActivityAttributes` conformance is usable from ActivityKit's nonisolated APIs under the app target's MainActor default isolation. Validated on simulator and on a physical iPhone 12 (Lock Screen lifecycle; see A4).
- **Completed (A4 — physical-device validation, 2026-09-17):** Debug build for a physical iPhone 12 (iOS 27.0) with automatic development signing; the Team ID was supplied only as an ephemeral command-line override and **no `DEVELOPMENT_TEAM` value was written to the project**. App and Live Activity extension both signed; extension embedded under `PlugIns/`; `NSSupportsLiveActivities = true`, `MinimumOSVersion = 18.0`, `UIDeviceFamily = [1]` verified on the built products. Install and launch on the device succeeded. Manual §6.2 Lock Screen lifecycle passed in full (see §6.3).
- **Pending (Dynamic Island-capable device):** the Dynamic Island portion of AC5 / §6.2. The iPhone 12 has no Dynamic Island, so that portion is **N/A on this device, not a failure**; Lock Screen Live Activities remain enabled on such hardware — iOS simply does not present the Dynamic Island UI. No device-model detection or app-level disabling behavior is required. Physical Dynamic Island validation is deferred until an iPhone 14 Pro (or later Dynamic Island-capable iPhone) is available and must cover: compact leading/trailing, minimal, expanded leading/trailing/bottom, update propagation, and end dismissal.
- **Completed (A5 — Simulator Dynamic Island validation and reconciliation fix, 2026-09-18):** on the iPhone 17 Simulator (iOS 26.3), the Lock Screen and Dynamic Island compact/expanded presentations were exercised manually (§6.4). The first End after an App Switcher kill/relaunch failed: the relaunched process built a fresh controller with no retained handle, so End was logged as `end ignored (reason=noActiveActivity)` while the system-owned activity stayed active. Diagnosed from SpringBoard process-lifecycle records and the app's fixed-vocabulary log; fixed by adding reconciliation with the public `Activity<TSUGINOLiveActivityAttributes>.activities` collection inside the existing Debug bootstrap boundary (see "Reconciliation" below). After the fix, kill/relaunch restored `Active (value 2)` automatically and End dismissed both presentations. 54 deterministic tests. Simulator evidence only — it does not replace the pending physical Dynamic Island validation.

Reconciliation (A5, Debug bootstrap only):

- A new controller starts in `reconciling`; the Debug section runs `reconcile()` once per view identity and keeps Start/Update/End disabled until it completes, so controls cannot race the existing-activity check.
- Exactly one existing TSUGINO activity is adopted with its current synthetic value; Update and End then route to it and a duplicate Start is rejected by the existing retained-handle rule.
- More than one existing Debug bootstrap activity is an ambiguous state: all are ended immediately (none is arbitrarily selected), nothing is retained, and the status becomes `ended`, from which Start creates a fresh activity at value 1.
- Reconciliation is idempotent per controller instance (a repeated call is a no-op and never rewinds adopted state).
- Four fixed log events (`reconcile started / found none / adopted (syntheticValue=N) / cleaned up (count=N)`) carry integers only; no activity identifiers are persisted, displayed, or logged; no App Group, push token, or general persistence was added.
- This is scoped to the Phase 0 Debug bootstrap; it is **not** the Phase 9 `LiveActivityCoordinator` (`ARCHITECTURE.md` §30), which remains unimplemented.

Workflow rule (2026-09-18): further Phase 0 development and validation use an explicitly selected iPhone Simulator by default; any physical-device step requires explicit user authorization (`AGENTS.md` §22). The physical iPhone 12 record in §6.3 is retained unchanged.

Folders **not** expected in Phase 0: `Domain/Journey`, `Domain/Routing`, `Domain/Realtime`, `Domain/Transfer`, `Application/*`, `Data/*`, other `Features/*`, `DesignSystem/*`, `Resources/RailData`, `Resources/PixelArt`, `Resources/Localization`.

---

## 6. Acceptance Criteria (ROADMAP Phase 0, verbatim mapping)

| # | Criterion | How it will be proven |
|---|---|---|
| AC1 | iPad is not part of the v1 QA matrix or supported-device configuration | `TARGETED_DEVICE_FAMILY = 1` and `IPHONEOS_DEPLOYMENT_TARGET = 18.0` on all targets; `xcodebuild -showBuildSettings` output recorded |
| AC2 | Clean build | `xcodebuild build` for app + extension, zero errors |
| AC3 | Clean test run | `xcodebuild test` on iPhone simulator, all smoke tests pass |
| AC4 | App installs and launches | Physical iPhone install + launch (Rule 30) — **PASS** (iPhone 12, iOS 27.0, 2026-09-17; §6.3) |
| AC5 | Live Activity extension is functional | Test activity started and ended on a physical Dynamic Island-capable iPhone; Dynamic Island rendering observed — **PARTIAL**: extension functional and Lock Screen start/update/end lifecycle passed on a physical iPhone 12 (§6.3); Dynamic Island compact/expanded, update propagation, end dismissal, and process-relaunch reconciliation passed on the iPhone 17 **Simulator** (§6.4, Simulator evidence only); physical Dynamic Island rendering **pending** on a Dynamic Island-capable device (N/A on iPhone 12) |
| AC6 | Provider evaluation document exists | `docs/PROVIDER_FEASIBILITY_AUDIT.md` |
| AC7 | No production feature depends on an unverified provider assumption | Trivially true in Phase 0 (no production features); registry rows all `Pending verification` and none referenced from configuration |

### 6.1 Required Tests (ROADMAP "Tests")

- app builds
- tests execute
- extension builds
- configuration loads (`AppConfiguration` smoke test)
- clock injection works (`ManualClock` smoke test)

### 6.2 Physical Device Test (ROADMAP)

- install app — done (iPhone 12)
- launch app — done (iPhone 12)
- start minimal test Live Activity — done (iPhone 12, Lock Screen)
- end test Live Activity — done (iPhone 12, Lock Screen)
- confirm Dynamic Island rendering on supported device — **pending** (requires a Dynamic Island-capable iPhone; N/A on iPhone 12). Simulator rendering exercised — see §6.4.

Simulator success alone does not satisfy AC4/AC5 (Rule 30, AGENTS §22).

### 6.3 Physical Device Validation Record (2026-09-17)

Device class: iPhone 12 (no Dynamic Island) · OS: iOS 27.0 · Deployment target: iOS 18.0 · Device family: iPhone-only. No device identifiers, signing identities, or local paths are recorded here by design.

Build / sign / install:

| Check | Result |
|---|---|
| Physical Debug build (app + extension) | PASS |
| Automatic development signing via ephemeral command-line team override | PASS |
| `DEVELOPMENT_TEAM` written to the project | No (verified; project unchanged) |
| App and Live Activity extension signing | PASS |
| Extension embedded in the app (`PlugIns/`) | PASS |
| `NSSupportsLiveActivities` / `MinimumOSVersion = 18.0` / `UIDeviceFamily = [1]` | PASS |
| Physical install and launch | PASS |

Manual Live Activity lifecycle (Lock Screen):

| Step | Result |
|---|---|
| Debug bootstrap controls visible (TSUGINO · DEBUG · Live Activity bootstrap · Start / Update / End) | PASS |
| Initial state `Idle` | PASS |
| Start → app state `Active · 1` | PASS |
| Live Activity appeared on the Lock Screen | PASS |
| Update → app state and Lock Screen value `2` | PASS |
| End → app state `Ended` | PASS |
| Live Activity disappeared from the Lock Screen | PASS |
| Start again → value reset to `Active · 1` | PASS |
| Final End completed cleanup; no TSUGINO Live Activity remained active | PASS |

Dynamic Island:

| Item | Status |
|---|---|
| Dynamic Island rendering on iPhone 12 | N/A — hardware has no Dynamic Island (not a failure) |
| Physical Dynamic Island validation | **Pending** — deferred until an iPhone 14 Pro is available |
| Required future coverage | compact leading/trailing, minimal, expanded leading/trailing/bottom, update propagation, end dismissal |

Validation split: **iPhone 12 Lock Screen lifecycle — completed; Dynamic Island-capable device — pending.** Dynamic Island has **not** been physically validated. Lock Screen Live Activities are not disabled on iPhones without Dynamic Island.

### 6.4 Simulator Runtime Validation Record (2026-09-18)

Environment: iPhone 17 Simulator (Dynamic Island-capable model), iOS 26.3, Debug build, no signing. **Simulator runtime evidence only** — nothing in this section is physical-device evidence, and it does not change AC5 from PARTIAL. No device identifiers, activity identifiers, or local paths are recorded here by design.

Manual sequence (user-performed, before the reconciliation fix):

| Step | Result |
|---|---|
| Start → app `Active (value 1)`; Lock Screen Live Activity displayed value 1 | PASS |
| Update → value 2 propagated to the Lock Screen | PASS |
| Dynamic Island compact presentation rendered (leading/trailing visible, no clipping) | PASS |
| Dynamic Island expanded presentation rendered (leading/trailing/bottom, no clipping or overlap) | PASS |
| Update → value 3 propagated to the Dynamic Island presentation | PASS |
| End after an App Switcher kill and relaunch | **FAIL** (app showed `Idle`; activity remained at value 3 on Lock Screen and Dynamic Island) |

Diagnosis: SpringBoard recorded the app process as "killed from app switcher" and relaunched; the new process logged `environment composed` followed by `live activity bootstrap end ignored (reason=noActiveActivity)` for each End tap, and the ActivityKit daemon recorded no end for the activity. Root cause: the controller's handle existed only in memory and nothing reconciled with the public activities collection. Fixed as described in §5.2 (A5).

Manual sequence (user-performed, after the fix — Path B):

| Step | Result |
|---|---|
| Start → `Active (value 1)` | PASS |
| Update → `Active (value 2)`; Dynamic Island displayed value 2 | PASS |
| App killed from the App Switcher, relaunched from the Home Screen → app automatically showed `Active (value 2)` (not `Idle`) | PASS |
| End → `Ended`; activity disappeared from both the Dynamic Island and the Lock Screen | PASS |
| Start again → value reset to `Active (value 1)` | PASS |
| Final End removed the remaining activity | PASS |

Evidence classification:

| Item | Status |
|---|---|
| Physical iPhone 12 Lock Screen lifecycle (§6.3) | PASS — historical evidence retained |
| Simulator Lock Screen lifecycle | PASS |
| Simulator Dynamic Island compact | PASS |
| Simulator Dynamic Island expanded | PASS |
| Simulator update propagation | PASS |
| Simulator end dismissal | PASS (after the reconciliation fix) |
| Simulator process-relaunch reconciliation | PASS |
| Dynamic Island minimal | NOT EXERCISED — system-selected multi-activity state (the bootstrap retains one activity; not a failure) |
| Physical Dynamic Island validation | **Pending** |
| AC5 | **PARTIAL** — physical Dynamic Island validation not completed |

---

## 7. Decision Gate (before Phase 1)

| Item | Owner of decision | Current state | Required output |
|---|---|---|---|
| Deployment target | Decided | **iOS 18.0 minimum (DEC-045)** | None — verify on all targets at bootstrap (AC1) |
| Primary route-search provider direction | Human approval after audit A2/A3 | Open (DEC-004 Provisional) | Audit §10 updated; not required for Track A to proceed |
| Primary realtime provider direction | Human approval after audit A1/A3 | ODPT platform, GTFS static + GTFS-RT first (audit §8.2); Toei join proof PASS WITH LIMITATIONS across seven snapshots of one evening — B2 single snapshot + B3 six-snapshot study (audit §6.1.1–§6.1.2); B4 static audit PASS WITH LIMITATIONS — JA/EN names complete, Korean project-owned, R5 realtime absence unresolved (audit §6.1.3); no provider selected | Audit §14 updated |
| Canonical ID strategy | Already decided | DEC-021 | None |
| Licensing viability for initial Tokyo scope | Human approval after audit A1/A2 | Unknown | Registry rows verified |

---

## 8. Exit Criteria

> Phase 0 is complete when the project is structurally ready and major provider risks are known well enough to continue.

Both tracks must reach this state. A buildable project with an unexamined provider landscape is **not** Phase 0 complete; a thorough audit with no project is **not** Phase 0 complete either.

---

## 9. Drift Checklist (to be run before each Phase 0 commit and at phase close)

- [ ] Did this change implement anything not listed in §3?
- [ ] Did it touch any file outside §5?
- [ ] Did it add a dependency?
- [ ] Did it add iPad support or leave iPad enabled?
- [ ] Did it add a provider client, DTO, or network call?
- [ ] Did it create domain models beyond smoke-test needs?
- [ ] Did it create empty ceremony folders?
- [ ] Did it create a versioned/dated copy of any document?
- [ ] Did it change a living document without a corresponding reason and (if significant) a decision record?
- [ ] Does the diff still match this Scope Lock?

---

## 10. Git Discipline for Phase 0

- Work only on `phase/00-bootstrap-feasibility`; never on `main` (AGENTS §27–§28).
- Small, reviewable commits: documentation → project bootstrap → configuration/clock/logging/flags → extension shell → device verification.
- Each commit message is phase-relevant (`phase0: ...` or Conventional Commits with Phase 0 context).
- No commit or push without explicit instruction.
- Merge method follows current project convention (to be confirmed by the human; not assumed).

---

## 11. Next Implementation Step (after this document is accepted)

1. Create the Xcode project and targets per §5.2 (Track A), iPhone-only, iOS 18.0, dependency-free.
2. Add `Clock`, logging, `AppConfiguration`, feature-flag skeleton, smoke tests.
3. Add Live Activity extension shell with throwaway test activity.
4. Build, test, install on device, run §6.2, record results — done for iPhone 12 Lock Screen (§6.3) and for the iPhone 17 Simulator Dynamic Island/Lock Screen sequence incl. relaunch reconciliation (§6.4); physical Dynamic Island portion pending on capable hardware, to be separately authorized.
5. In parallel (Track B), execute audit actions A1–A3 (Toei full-realtime proof, Tokyo Metro degraded proof) and update the audit — Toei single-snapshot proof (B1/B2), six-snapshot short temporal study (B3), and offline static route/localization audit (B4) done (§3.2); R5 realtime scope, Tokyo Metro degraded path, cross-operator identity, project-owned Korean dataset, and commercial confirmation remain.
6. Run §9 drift checklist and the AGENTS §24 phase audit; report.
