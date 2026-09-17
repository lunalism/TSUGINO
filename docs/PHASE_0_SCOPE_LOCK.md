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

### 3.3 Documentation

- Living documents are updated **only** if Phase 0 reveals something that changes current truth. The deployment-target decision (DEC-045) and the 2026-09-17 documentation baseline repair are the Phase 0 document changes to date. Otherwise they are not touched.

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

### 5.1 Documentation changes so far (no Xcode project)

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

### 5.2 Subsequent Phase 0 changes (Track A, after this document is accepted)

Expected new paths, following `ARCHITECTURE.md` §4:

```text
TSUGINO.xcodeproj/
TSUGINO/
├── App/
│   ├── TsuginoApp.swift
│   ├── AppEnvironment.swift
│   └── AppConfiguration.swift
├── Shared/
│   ├── Logging/
│   └── Time/                  (Clock, SystemClock, ManualClock)
├── Resources/
│   └── Assets.xcassets
LiveActivityExtension/
├── <extension entry point>
└── Views/                     (throwaway test activity view only)
Tests/
├── DomainTests/               (smoke: clock injection)
└── ApplicationTests/          (smoke: configuration loads)
```

Feature-flag skeleton location: `App/` (as part of `AppConfiguration`) unless implementation shows a better owner; any deviation is noted in the phase report.

Folders **not** expected in Phase 0: `Domain/Journey`, `Domain/Routing`, `Domain/Realtime`, `Domain/Transfer`, `Application/*`, `Data/*`, `Features/*`, `DesignSystem/*`, `Resources/RailData`, `Resources/PixelArt`, `Resources/Localization`.

---

## 6. Acceptance Criteria (ROADMAP Phase 0, verbatim mapping)

| # | Criterion | How it will be proven |
|---|---|---|
| AC1 | iPad is not part of the v1 QA matrix or supported-device configuration | `TARGETED_DEVICE_FAMILY = 1` and `IPHONEOS_DEPLOYMENT_TARGET = 18.0` on all targets; `xcodebuild -showBuildSettings` output recorded |
| AC2 | Clean build | `xcodebuild build` for app + extension, zero errors |
| AC3 | Clean test run | `xcodebuild test` on iPhone simulator, all smoke tests pass |
| AC4 | App installs and launches | Physical iPhone install + launch (Rule 30) |
| AC5 | Live Activity extension is functional | Test activity started and ended on a physical Dynamic Island-capable iPhone; Dynamic Island rendering observed |
| AC6 | Provider evaluation document exists | `docs/PROVIDER_FEASIBILITY_AUDIT.md` |
| AC7 | No production feature depends on an unverified provider assumption | Trivially true in Phase 0 (no production features); registry rows all `Pending verification` and none referenced from configuration |

### 6.1 Required Tests (ROADMAP "Tests")

- app builds
- tests execute
- extension builds
- configuration loads (`AppConfiguration` smoke test)
- clock injection works (`ManualClock` smoke test)

### 6.2 Physical Device Test (ROADMAP)

- install app
- launch app
- start minimal test Live Activity
- end test Live Activity
- confirm Dynamic Island rendering on supported device

Simulator success alone does not satisfy AC4/AC5 (Rule 30, AGENTS §22).

---

## 7. Decision Gate (before Phase 1)

| Item | Owner of decision | Current state | Required output |
|---|---|---|---|
| Deployment target | Decided | **iOS 18.0 minimum (DEC-045)** | None — verify on all targets at bootstrap (AC1) |
| Primary route-search provider direction | Human approval after audit A2/A3 | Open (DEC-004 Provisional) | Audit §10 updated; not required for Track A to proceed |
| Primary realtime provider direction | Human approval after audit A1/A3 | Leaning ODPT-native | Audit §10 updated |
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
4. Build, test, install on device, run §6.2, record results.
5. In parallel (Track B), execute audit actions A1–A3 (Toei full-realtime proof, Tokyo Metro degraded proof) and update the audit.
6. Run §9 drift checklist and the AGENTS §24 phase audit; report.
