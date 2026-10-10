# TSUGINO — ROADMAP.md

## First real Candidate-B inventory pilot complete; request closure next — 2026-10-10

**`FIRST_REAL_P3_T1_OCCURRENCE_INVENTORY_PILOT_COMPLETE`** records the supplied owner
execution and **27/27 PASS** independent review, with no unresolved findings. This
documentation task does not reopen any private authority or rerun the pilot. Execution
used published commit `0c9b06741b8f1ce8ebce428e943b9c55d78d9a50`, service date
`2026-03-16`, view UUID `3e8a2c14-1f90-4d85-9af1-0f5e7c22a641` and only interval
`0...13`. Receipt: **1959 bytes**, SHA-256
`be25f8f4ff1097ff373d4d7a2c3f00451814971098e4eb3acd053a4f83779c3c`.
The implementation-stage unstaged/publication-pending and next-pilot wording below
is historical; the values were published before this separately authorized real pilot.

Both published verifiers returned **`bundleValid unchangedReplay`** read-only. The exact
accepted DEC-074 provisional static compatibility authority is **217088 bytes**,
SHA-256 `c0e38b0a4220a116cbaa9add736e66ce8fdfa58b48e550e2975de0e23fcbc151`,
schema **1**, data version **`p2s8-local-provisional-20261001`**, registry revision **6**.
**14 stations /
1 active represented line** and applicable station/line memberships passed. Exact S9
Trip/facts binding passed: **14 visits / 28 exact events / 0 estimated / 0 missing /
14 boarding allowed / 14 alighting allowed / 0 chronology contradictions**.

Actual production `TimetableOccurrenceInventoryView` construction passed with **1 declared
address / 1 slot / 1 Trip snapshot / 1 service date / 1 active / 0 inactive / 0 unavailable /
1 explicit interval `0...13`**. **15466 bytes** is production
logical accounting, not measured heap usage. Occurrence **`declaredComplete`** means only
that the owner-authorized one-address pilot declaration was supplied exactly and completely;
it establishes no complete Trip/date/timetable/search-relevant/alternative/network universe.
Interval completeness remains **`unknown`**: only `0...13` was positively authorized and
verified; no other subinterval was inferred absent. Details: [producer §18](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#18-first-real-production-occurrence-inventory-pilot--2026-10-10).

This proves lossless compatibility across one accepted real `RailwayArtifactRevision`,
S9 Trip, `TimetableOccurrenceBinding`, `TimetableOccurrenceFacts` and production inventory.
It proves neither search-input closure, transfer feasibility, connection inventory, solver
completeness, fastest/all-tied routes nor runtime adoption/delivery. Broader status remains
**`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**; Phase 3 **In Progress**;
live/default routing remains unconfigured.

Repository-contract audit selects **`P3_REQUEST_SCOPED_SEARCH_INPUT_CLOSURE_NEXT`**:
**Boundary B then Boundary A**, followed by separately qualified solver-input composition.
DEC-079/080 require sufficient request-relative input coverage before internal success or
`noResults`; DEC-086 additionally requires completed optimum/all-equal-optima proof. A valid
occurrence inventory and valid directional connection records each describe supplied evidence;
neither determines all required evidence for a request. B can expose unresolved exact connection
requirements without defining A's walking/interchange/allowance payload. Unknown required
evidence must block qualification, including when a direct ride exists. A direct candidate's
existence does not prove no faster valid transfer alternative was omitted.

[Consumer §20](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#20-post-inventory-pre-solver-boundary-audit--2026-10-10)
records accepted-versus-Proposed authority, A/B comparison, §17 manifest reuse and the smallest
invented-only immutable Data slice over the existing request, explicit finite scope, static
revision, inventory and independently substantiated membership/dependency declarations.
This is local consistency over supplied qualified authority, not a self-authenticating closure
flag or completed search. Production horizon duration, ride/resource policy, solver/adoption
and delivery remain unresolved; no number or synthetic requiredness policy is promoted.
**`NO_NEW_PRODUCT_DECISION_REQUIRED`** for this technical boundary under Accepted search truth.

Exact next safe action, **not begun**: separately authorize the smallest invented-only
production Data request-scoped search-input closure values and focused tests described in
consumer §20.5, retaining an explicit unresolved connection-evidence seam and fail-closed
qualification. Do not implement connection payloads, solver, real access or runtime wiring.

## Candidate-B immutable occurrence inventory values — 2026-10-10

The owner-authorized invented-only Candidate-B implementation now lives in
`TSUGINO/Data/Timetable/TimetableOccurrenceInventory.swift`, with focused invented
coverage in `TSUGINOTests/TimetableOccurrenceInventoryTests.swift`.
**`P3_T1_OCCURRENCE_INVENTORY_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`**.
Author verification passed 90 test functions / 164 expanded cases and the standard
Release app/extension build. Independent non-author review passed all 24 criteria,
reran the focused suite (18 functions / 48 cases) and a fresh Release build. Two
Unicode byte-accounting findings were fixed with regressions; no findings remain.
Existing unmodified Domain/AppIntents/asset-catalog warnings remain; no warning is
attributable to the new inventory source/tests. Work is unstaged/uncommitted for owner
publication review; HEAD/main remain unchanged. The
previous next-implementation wording below describes the preceding published audit.

The pure production Data value retains an exact supplied qualification/static revision,
independently declared ordered finite addresses and exactly one snapshot-bound slot per
address. Active facts/explicit intervals, inactive and unavailable qualification holds
remain distinct. Complete/unknown address and interval declarations are scoped to their
supplied authority, including distinct empty declarations; none is search completeness
or `noResults`. Original indices and full recurring Trip snapshots remain intact across
dates. Interval structure survives missing/estimated events and prohibited/unknown
permissions. Domain is unchanged. Static authority is referenced through the existing
`RailwayArtifactRevision`; no station/line/topology copy is introduced.

**`NUMERIC_PRODUCTION_LIMITS_IMPLEMENTATION_EVIDENCE`** is recorded in
[producer §17](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#17-candidate-b-invented-only-production-values--2026-10-10):
pre-constant generated invented measurements, independent reproduction, finite per-axis
bounds and a separate conservative expanded-payload cap. These are technical safeguards,
not promised network capacity or product/solver policy.

No real/private artifact access, IO/network/persistence, transfer/connection authority,
solver/search/horizon/optimality, AppEnvironment, Journey or UI adoption belongs to this
change. No real production inventory is accepted. P3-T1 remains scope-incomplete and
Phase 3 remains In Progress. No new product decision is required.

Next safe action after independent approval, **not begun**: owner review and publication
of these unstaged values; only after publication, separately assess and authorize one
bounded real inventory pilot using accepted S9/timetable authorities without search or
solver execution. Real inventory construction is excluded from implementation/publication.

## First real direct-route admission bridge complete; occurrence inventory next — 2026-10-10

**`FIRST_REAL_P3_T1_DIRECT_ROUTE_ADMISSION_BRIDGE_COMPLETE`.** This governing
overlay records supplied owner execution/review results, without reopening private
S9, timetable, harness or receipt artifacts. Earlier next-Candidate-A and unconstructed
interval statements below are historical for this completed pilot. The execution used
repository commit `6a76f0f8d6e025887bb60ad689e44ef87edb2fcb`, service date
**`2026-03-16`** and exactly the authorized original-index interval **`0...13`**.

| Supplied private evidence | Bytes | SHA-256 |
|---|---:|---|
| Execution receipt | 2159 | `04911e66091966abcb37fad81fe71418f717a7c8e3a19338c791df6113a3901a` |
| Independent review | 2743 | `89844972cbb0b6a182270060ac418fcf466d3c9fe06cd52b2c04ef18912c7b1e` |

Both published S9 and full timetable verifiers passed `bundleValid unchangedReplay`
read-only. Exact Trip/facts binding and distinct endpoint stations passed; coverage
remained **false/false**, preserving unknown service origin/destination. Boarding at
index 0 was allowed with exact departure; alighting at index 13 was allowed with
exact arrival. Actual production `TrainCandidate`, `TimetableRideContext`,
`RouteRailProposal` and `RouteCandidate` construction passed: context matched train,
departure <= arrival, full snapshot/binding/original indices/endpoints were preserved,
and timetable origin/matched travel remained intact. Aggregate: **one rail leg /
zero walking legs / zero transfers / one line in the ridden line sequence**.

Author and independent reviewer each compiled exact repository production/tool sources
without DEBUG flags and ran the same bounded composition. Independent review:
**25/25 PASS**, no unresolved findings. No provider context, RouteScheduleAdmission,
searcher/solver, fastest/completeness claim, canonical candidate serialization or
repository/runtime mutation occurred. The candidate existed only in memory. This
establishes one known direct ride, not enumeration, transfers, optimal/tie completeness,
complete dated inventory, solver readiness, launch-wide coverage or runtime adoption.
**`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`** is unchanged; Phase 3
remains In Progress.

Repository-only next-boundary assessment:
**`NO_ADDITIONAL_DIRECT_RIDE_CASE_REQUIRED_BEFORE_INVENTORY_BOUNDARY`**. Repeated
indices, multi-Line traversal, missing/estimated endpoints and permission distinctions
already have focused production-contract/invented regression coverage. No materially
different unresolved constructor/source shape currently requires another real pilot;
another ordinary interval/date would repeat the same proof. New evidence of an
unsupported shape would justify revisiting this conclusion, not a quota of examples.

Primary next task: **`P3_T1_REAL_OCCURRENCE_INVENTORY_ADAPTER_NEXT`** (Candidate B).
Recommend a production-compiled immutable **Data/Timetable** value with one qualified
view/revision authority, independently declared finite dated-address scope, exact
snapshot-bound active/inactive/unavailable slots, separately declared evidenced
original-index interval availability and explicit scoped completeness. Complete empty
and unknown empty remain distinct; a complete address set is not complete search input.
Known holds remain visible. Static station/line authority is referenced by exact
compatible revision, not duplicated; connections/allowances and solver horizon,
enumeration, optimization and accounting remain separate. Initial implementation
should use invented inputs/tests only, with no real access, IO, persistence, solver
or runtime wiring. **`NO_NEW_PRODUCT_DECISION_REQUIRED`** for this technical boundary;
**`NUMERIC_PRODUCTION_LIMITS_REQUIRE_SEPARATE_IMPLEMENTATION_EVIDENCE`**.

Detailed minimum contract, ownership, completeness/interval semantics and completion
criteria: [producer §§15–16](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#15-first-real-direct-route-admission-bridge--2026-10-10).
Next safe action, **not begun**: separately authorize the invented-only Candidate-B
immutable Data value and focused tests described there. This documentation/audit task
accesses no private artifact, constructs no real candidate and changes no runtime/source.

## First real P3-T1 dated occurrence import complete; routing handoff — 2026-10-10

**`FIRST_REAL_P3_T1_DATED_OCCURRENCE_IMPORT_COMPLETE`.** This governing overlay
records the owner's supplied execution and independent-review results, without
accessing private timetable artifacts again. The occurrence-locator correction was
published at `6bbb99bf963769e4ebc5d8563d562962f461944f`. Earlier stopped-preparation,
unpublished-tool and pending-import statements below remain historical records;
they no longer describe this exact completed pilot. Accepted semantic decisions
and broader coverage/runtime gates remain unchanged.

Service date: **`2026-03-16`**. Request ID:
`p3t1.first-real-import.request.20261010.001`. Owner approval review ID:
`p3t1.first-real-import.approval.20261010.001`, approvedAt `2026-10-10T01:34:51Z`.

| Supplied artifact | Bytes | SHA-256 |
|---|---:|---|
| Import request | 76481 | `77fb98c726c3fd4d3ef810ffecf091d84292407abc5536e6b982131995f87da1` |
| Owner import approval | 450 | `6e876719aff1a9a2a7d79110573f0bca226b5aab668aad3f0a58d43e8de03a24` |
| Published occurrence facts | 3145 | `4e8c2d93845c0dd86ccb1e26b05384c420c4a6cbaab583241569c637294d1936` |
| Import history | 77086 | `54a6f8f0e528bbdb33cd8323417eb9e2ab5f5eed1e9e7c953e70261435beee70` |
| Import manifest | 1251 | `4a6c7d68b0604a36b15fd8da6d4388fe6230fb4ed748b091f222e221b88f9098` |

Dependency-root SHA-256:
`1fe9505914ea696dd4daaef8663112c7215a0c09874167c0d4da2b0ddde54aa4`;
**38 records / 17 direct roots / 1767 decoded bytes / 59 assertions**.
Accepted facts: **14 visits, original indices `0...13`, 28 exact events,
0 estimated, 0 missing, boarding allowed at 14 visits, alighting allowed at
14 visits, 0 chronology contradictions**. Actual Domain `TimetableOccurrenceFacts`
construction and deterministic round-trip passed in the supplied execution.

`approve-import` was invoked exactly once; `apply-import` executed exactly once,
returning `occurrenceImported` with ordinary success, no durability uncertainty,
no retry and no second apply. The published bundle contains exactly `facts.json`,
`history.json`, `manifest.json`. Published verification returned
`bundleValid unchangedReplay`: that verifier was read-only, not a second apply.
Independent execution review approved **25/25**, with no unresolved material finding.
S9 and source-profile authority remained unchanged; the GTFS archive was not reopened
during approval/apply. These are supplied execution facts, not newly rerun checks.

The accepted result covers **one Trip / one service date / one approved profile**.
Broader classification: **`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**.
Current Accepted authority does not define this single pilot as full P3-T1 completion.
The implemented owner-only import capability, this imported occurrence, launch-wide
timetable coverage and runtime adoption are distinct. No arbitrary additional-Trip
quota or full-feed requirement is introduced for the bounded pilot. Phase 3 remains
In Progress; real routing/search/Journey/runtime adoption remains absent.

Repository-only handoff assessment: existing production values support
`TimetableOccurrenceFacts → TrainCandidate → TimetableRideContext →
RouteScheduledContext.timetable → RouteRailProposal → RouteCandidate`.
**`REAL_TIMETABLE_FACTS_CAN_REPRESENT_ONE_CANONICAL_DIRECT_RIDE`** is a type/contract
readiness finding, not a private candidate construction or interval certification.
The smallest justified next task is
**`P3_T1_REAL_FACTS_TO_DIRECT_ROUTE_ADMISSION_BRIDGE_NEXT`** (Candidate A), with
**`NO_NEW_PRODUCT_DECISION_REQUIRED`** for composition of already Accepted values.
Candidate B's production inventory adapter and Candidate C's production solver are
broader tasks; neither is a prerequisite to that one explicit direct-ride harness.

For a future separately authorized harness, explicit original indices `0` and `13`
stay within the represented snapshot and retain unknown service-endpoint extent
(coverage false/false). `TrainCandidate` also requires distinct endpoint stations;
that cannot be certified from the supplied safe aggregate. Future private verification
must check it and fail closed, without selecting another interval automatically.
Exact facts and allowed endpoints fit the context's data shape in principle; provenance,
activation, eligibility and relevant S9 movement/continuity authority remain external
admission obligations. No graph search, fastest/all-alternatives claim or runtime wiring
follows. Detailed constructor, test-reuse and solver-prerequisite audit:
[producer §§13–14](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#13-first-real-dated-occurrence-import--2026-10-10).

Next safe action, **not begun here**: obtain separate owner authorization for the
bounded private Candidate-A harness against the exact pinned S9/import authorities
and an explicit owner-supplied original-index interval; verify those authorities and
compose one candidate through existing production constructors, failing closed on
any mismatch. This documentation/audit task accesses no private timetable artifact,
constructs no real route candidate and performs no search/runtime action.

## P3-T1 occurrence-locator bound correction — 2026-10-10

The original owner-only import adapter was published at
`d2b052cd2a49f2ab044cc7db9112747e555ab718`. The owner reports first real normalized
binding succeeded, then request preparation stopped with
`P3_T1_REAL_IMPORT_RESOURCE_LIMIT` before creating any request/facts/bundle.
P3-T1 imposed an unintended downstream resource restriction on an already accepted
S9 authority value: generic converter ASCII tokens were limited to 64 bytes, and
the same helper incorrectly checked opaque S9 occurrence locators. S9 accepts up
to 256 bytes; the supplied safe aggregate for accepted real locators is 172–176 bytes.
This is a downstream resource-contract defect, with no timetable semantic change.

The bounded correction introduces a dedicated 256-byte occurrence-locator limit,
preserving printable ASCII syntax and exact crosswalk byte equality. Generic
converter tokens remain 64 bytes. All other envelope/count/dependency/ID limits
and the 64 KiB total counted-text ceiling remain unchanged; locators count normally.
Dedicated invented fixtures cover full S9-to-Domain conversion at 64/65/176/255/256,
257 rejection, a one-byte same-length binding mismatch, generic 64/65 boundaries,
syntax rejection and exact/overflow aggregate accounting. The normal short fixture,
S9 implementation, Domain and app/runtime sources remain unchanged.

This task accesses no real/private railway artifact and creates no real request,
facts or bundle. The prior attempt's retained profile approval, normalized input
and initial state are next-task context only; the one-use source archive grant was
consumed. Real preparation remains stopped pending correction publication. After
publication, separately revalidate exact retained hashes/security and independently
review reuse of those artifacts, without reopening the GTFS archive. No resume,
owner import approval, apply, runtime adoption or Phase 3 completion occurs here.
Historical implementation/preparation records below remain unchanged.

Correction verification: author production build and complete **206-case invented
suite PASS**. Separate non-author review approves **15/15 criteria**, no material
findings, with independent production rebuild and complete **206-case PASS** rerun;
counts are reported separately, not added. The unchanged timetable suites pass
**82 tests / seven suites**, zero failures/skips, on an explicit iPhone 17 / iOS 26.5
Simulator. The complete unchanged S9 suite passes **185 cases**, including its large
invented retained-history envelope. Production symbol/source isolation,
privacy, resource-contract and whitespace audits pass. No physical device is used.
The seven-file correction remains unstaged/uncommitted for owner publication review;
HEAD/upstream stay `d2b052cd2a49f2ab044cc7db9112747e555ab718` and main stays
`e8a463d51f14b3cb1027960c63244b694579a71b`. P3-T1 remains partial and Phase 3
In Progress; no real import or runtime adoption follows from tooling verification.

**`P3_T1_OCCURRENCE_LOCATOR_BOUND_CORRECTION_IMPLEMENTED_AND_APPROVED`.** This is
tooling correction approval only; real preparation remains stopped pending publication.

## First real S9 snapshot selected; P3-T1 readiness overlay — 2026-10-09

**First real authoritative untimed Trip snapshot selection: complete.** Execution verdict:
`FIRST_REAL_P2_S9_SNAPSHOT_SELECTION_COMPLETE`. This governing overlay records supplied
owner execution/review facts; earlier dated pending-gate, stopped-preparation, uncommitted
publication and next-step records below are preserved as history. Their unresolved identity,
classification, ordering, mapping, movement and snapshot statements no longer apply to this
exact accepted candidate. This documentation-only audit opens no private or timetable source.

Request `p2s9.first-snapshot.request.20261009.001` and approval
`p2s9.first-snapshot.approval.20261009.001` (`approvedAt` `2026-10-09T12:57:48Z`) selected
one immutable untimed snapshot. The [complete selection pins, sizes and readiness audit](P2_S9_REAL_READINESS.md#first-real-authoritative-untimed-trip-snapshot-selection-complete--2026-10-09)
records exact request/approval/Trip/crosswalk/history/manifest/dependency-root SHA-256 values.
Trip/crosswalk/history/manifest sizes: **551 / 11,416 / 54,005,988 / 1,067 bytes**.
Dependency closure: **8 records / 7 direct roots / 8 context pins / 1,808,356 unique decoded bytes**.

Accepted structure: **14 Passenger stops / 0 Passed / original indices 0...13**, one full
represented single-Line segment, continuity `notApplicable`; origin and destination each
`unknownExtent`, coverage **false/false**, service unknown with `serviceTypeSegments = []`.
Recurring identity, real registration, source correspondence, classification/order,
**14/14 Station correspondence**, **13/13 movement**, line construction, continuity,
independent endpoint dispositions, unknown service type, immutable crosswalk/snapshot,
owner approval and bundle verification are resolved for this candidate.

Exactly **one** `approve-snapshot` and **one** `apply-snapshot`; result `snapshotSelected`,
no durability uncertainty, retry or second apply. Bundle files are exactly `trip.json`,
`crosswalk.json`, `history.json`, `manifest.json`. Published verifier `bundleValid unchangedReplay`
is read-only verification, not a second apply. Separate non-author execution review **25/25**,
no unresolved finding; revision-8 identity registry/history/manifest unchanged.

**`FIRST_REAL_P2_S9_CANDIDATE_ACCEPTED`** is the narrow scope conclusion under Accepted
DEC-074/075/078/082/083/084. Repository authority does not define this single pilot as the
whole required real S9 scope, nor prescribe an additional Trip/run count. Broader S9 closure
requires explicit declared-scope reconciliation and acceptance accounting; no slice-wide or
launch-wide/full-feed completion is claimed. This does not impose full-feed acceptance on a
bounded timetable pilot for this accepted Trip. P3-T1 real import stays **incomplete**;
Phase 3 stays **In Progress**, with all launch scope preserved.

**`P3_T1_S9_HANDOFF_READY_FOR_THIS_TRIP`**: registered canonical Trip, exact immutable
snapshot/crosswalk, source/checkpoint/artifact and evidence/profile/mapping/view bindings
plus downstream revalidation obligations now supply this Trip's structural prerequisite.
Accepted DEC-078 producer semantics and DEC-085 DEBUG invented converter already implement
dated/snapshot/index bindings, activation/exception precedence, civil-day extended hours,
explicit offset rules, gap/fold rejection, qualified times and typed outcomes. Published
synthetic converter-to-all-distinct/optimal/batch routing integrations do not qualify Toei.

**Exactly one next classification: `P3_T1_SOURCE_PROFILE_EVIDENCE_REQUIRED_NEXT`.** Accepted
stop/pass/order and recurring-key profiles do not accept retained Toei calendar/time semantics.
Remaining real prerequisites are exact authorized source/member/revision bindings; a reviewed
service/calendar/exception/extended-hour profile; zone/offset provenance; exact time-row-to-S9
associations and applicable eligibility; one-execution-per-service-date evidence; then reviewed
real tooling, retained dependency closure, immutable import output/history and independent
real acceptance. **`NO_NEW_PRODUCT_DECISION_REQUIRED`** for the next evidence assessment
under DEC-078/085. No real adapter/import execution is started or source compatibility assumed.
Production registry, app delivery, route-engine adoption, Phase 5 consumption and public
rights/bundling remain separate gates; applicable local-use authorization still applies.

The exact next safe action is to scope an owner-only calendar/time interpretation evidence
review for this accepted Trip, with exact owner input bindings and narrow access/output
boundaries for separate authorization. That action has not begun. Only ROADMAP and the
readiness assessment change; historical records are retained verbatim.

## P2-S9 resource-envelope correction overlay — 2026-10-09

Real S9 request preparation stopped with `S9_REQUEST_PREPARATION_FAILED` before creating
an input or request: the exact registeredBundle base64 fields alone require 34,770,572
bytes, exceeding the published 24 MiB input limit. The authoritative revision-8 checkpoint
is valid and remains unchanged; the defect is the tool's enclosing resource envelope.
Schema 1, exact retained authority bytes and all semantic/subordinate limits remain unchanged.
The correction sets input/request/state/history/bundle limits to 64/112/192/128/144 MiB.
See [nesting rationale and bounds](../Tools/TripS9Assembly/README.md#resource-envelope-correction--2026-10-09).
Author and independent production builds each pass, with complete 185-check invented
suite reruns. Independent non-author review approves all 17 correction criteria. Fresh
unchanged iPhone Simulator regressions pass 230 synthetic S9, 390 registration C2 and
188 Domain invocations (808 total across 289 test functions), with zero failures or skips.
Privacy and diff checks pass; the correction remains unstaged/uncommitted for owner
publication review.
No real/private railway artifact is accessed in this correction. Real preparation has not
resumed, and no real S9 input/context/state/request, snapshot or approval exists. No approval
or apply occurs. P2-S9 remains incomplete; no P3-T1 real import or runtime adoption begins.
Earlier implementation/publication and readiness records below are preserved historically.

## P2-S9 assembly adapter implementation overlay — 2026-10-09

Phase 3 retains P2-S9 ownership. `Tools/TripS9Assembly` implements the bounded owner-only
macOS initial untimed snapshot assembly workflow for one already registered Trip. It
retains exact normalized input and complete evidence bytes, reconstructs the unchanged
Domain Trip and occurrence crosswalk, separates preparation from owner approval, and
publishes a verified immutable S9 history/bundle with exclusive atomic private I/O.
Production build and the complete invented suite pass (176 checks). Independent non-author
review passes all 27 criteria, with an independent production build and full 176-check rerun.
Unchanged Simulator regressions pass: 230 synthetic S9, 390 registration C2 and 188 Domain
invocations (808 total; 289 test functions), with zero failures or skips. Privacy/diff audit
passes. The adapter remains unstaged/uncommitted for owner review and publication.
See [tool contract and limits](../Tools/TripS9Assembly/README.md) and the
[current readiness overlay](P2_S9_REAL_READINESS.md).

No real movement-review artifact, archive, mapping/network evidence, registry bundle,
TripID or provider key is accessed in this implementation task. No real snapshot or S9
approval is created. Registry mutation, P3-T1 import, runtime adoption, routing, SQLite and
app/shared implementation remain outside this slice. P2-S9 and Phase 3 remain incomplete.
Historical roadmap records below are preserved.

## 1. Purpose

This document defines the implementation order for TSUGINO.

It is a **living roadmap**. Phase boundaries may change when implementation, provider limitations, licensing, performance testing, physical-device testing, or new product decisions reveal better sequencing.

The roadmap exists to protect three things:

1. architectural integrity,
2. implementation focus,
3. reliable phase-by-phase verification.

A phase is complete only when its exit criteria are satisfied.

---

## 2. Roadmap Principles

### 2.1 Build Foundations Before Features

Do not begin with polished screens while the core Journey model, provider boundaries, or realtime semantics remain unstable.

### 2.2 Validate Risk Early

The highest-risk unknowns should be tested before large implementation investment.

Examples:

- route provider suitability
- realtime data quality
- trip identity matching
- Live Activity behavior
- licensing constraints
- background refresh behavior

### 2.3 One Phase, One Main Goal

A phase may contain multiple tasks, but it should have one dominant objective.

### 2.4 Explicitly Exclude Future Work

Each phase must state what is **not** included.

This prevents accidental scope expansion.

### 2.5 Physical Device Testing Matters

Features involving:

- Dynamic Island
- Live Activity
- background behavior
- notifications
- location
- animation performance
- battery usage

must be verified on real iPhone hardware.

### 2.6 Documentation Moves With Implementation

If implementation changes product truth, the relevant living documents must be updated during the same phase.

---

# Phase 0 — Project Bootstrap + Feasibility Baseline

## Goal

Create a clean iOS project and validate the highest-risk external dependencies before domain implementation expands.

## Included

- iPhone-only product target
- explicit exclusion of iPad device support for v1
- Xcode project bootstrap
- bundle identifier
- signing
- deployment target (iOS 18.0 minimum, DEC-045)
- basic app shell
- basic Widget / Live Activity extension shell
- test targets
- dependency-free baseline
- environment configuration structure
- project folder structure
- provider feasibility audit
- initial data-source/license registry
- initial physical-device build

## Explicitly Excluded

- production route search
- production realtime tracking
- polished UI
- journey engine
- transfer guidance
- pixel animation system

## Implementation Tasks

- create canonical project structure
- create `AppEnvironment`
- create `AppConfiguration`
- establish build configurations
- create test targets
- add Live Activity extension target
- establish logging foundation
- establish clock abstraction
- establish feature flag mechanism
- verify app installation on target iPhone
- verify iPad is excluded from the supported device family and release configuration
- verify Live Activity capability on target device
- document provider candidates
- document known licensing constraints

## Research Tasks

Evaluate:

- ODPT
- GTFS / GTFS-RT availability
- route-search provider candidates
- trip identity quality
- station naming/mapping strategy
- car/door guidance data availability

## Tests

- app builds
- tests execute
- extension builds
- configuration loads
- clock injection works

## Physical Device Test

- install app
- launch app
- start a minimal test Live Activity
- end the test Live Activity
- confirm Dynamic Island rendering on supported device

## Acceptance Criteria

- iPad is not part of the v1 QA matrix or supported-device configuration
- clean build
- clean test run
- app installs and launches
- Live Activity extension is functional
- provider evaluation document exists
- no production feature depends on an unverified provider assumption

## Exit Criteria

Phase 0 is complete when the project is structurally ready and major provider risks are known well enough to continue.

## Decision Gate

Before Phase 1, confirm:

- deployment target — decided: iOS 18.0 minimum (DEC-045)
- primary route-search provider direction
- primary realtime provider direction
- canonical ID strategy
- licensing viability for initial Tokyo scope

---

# Phase 1 — Core Domain + Canonical Railway Model

## Goal

Build a provider-independent railway and journey domain.

## Included

- canonical IDs
- Station
- RailwayLine
- Operator
- Trip
- Stop sequence
- Journey
- JourneyLeg
- JourneyState
- JourneyPhase
- JourneyEvent
- capability model — `RailCapability`, declared at **service/feed scope**; `Operator` is canonical identity only and owns no capability set (DEC-049)
- typed errors
- deterministic Clock

## Explicitly Excluded

- live provider networking
- GTFS or ODPT production ingestion
- canonical mapping-table population (Phase 2)
- route-search API integration
- realtime provider integration (Phase 4)
- **JourneyEngine runtime behaviour — Phase 5 owns it (DEC-050)**
- **capability carrier and attachment** — Phase 1 defines the `RailCapability` vocabulary and the pure tier derivation only; it creates no service/feed carrier and attaches capabilities to no model. Service/feed-scoped declaration, ingestion, and attachment are **Phase 4** (DEC-054)
- **railway line colour** — no colour type, contract, token, or placeholder field; ownership and representation are decided after the ODPT licensing gate, most plausibly in Phase 2 (DEC-055 D5)
- production persistence and recovery implementation
- Live Activity production UI
- pixel animations
- persistence schema beyond test scaffolding
- physical-device-dependent feature implementation

## Implementation Tasks

- define typed identifiers
- define canonical railway models
- define Journey models
- define capability declarations
- define domain validation rules
- define through-service representation
- define realtime freshness model
- define interruption/recovery model
- define provider-neutral domain protocol boundaries assigned to Phase 1, including the **`JourneyEngine` protocol boundary without its runtime behaviour** (DEC-050). `RouteSearching` (with `RouteCandidate` and `TrainCandidate`) is **not** defined in Phase 1: DEC-064 assigns it to Phase 3, which already includes it, and live route-search integration stays in Phase 3 (`DECISIONS.md` §4 “Route Search Provider”)

### Slice S3 — Station and RailwayLine (DEC-055, DEC-056, DEC-057)

Phase 1 is implemented in slices; S1 (canonical identifiers, DEC-051) and S2 (`LocalizedRailName`, `Operator`, `RailCapability`; DEC-053, DEC-054) are complete. S3 covers `Station` and `RailwayLine` in three sub-slices and is **complete** (2026-09-22): each sub-slice was implemented and independently audited, and DEC-055's completion rule is satisfied. S4 (`Trip`, in sub-slices S4a and S4b; DEC-060, DEC-061) is **complete** (2026-09-23). S5 (Journey structure and runtime state, in sub-slices S5a and S5b; DEC-062, DEC-063) is **complete** (2026-09-24). S6 (domain protocol boundary; DEC-064) is **complete** (2026-09-25). **Phase 1 is complete** (2026-09-25); see the Phase 1 Completion Record below.

- **S3a — identity and relationship core: complete** (`a9c93bc`, `b668d41`; independently approved 2026-09-21). `Station { id, name, lineIDs: Set<LineID> }` (the S3a shape; S3b adds the required `coordinate`) and `RailwayLine { id, operatorID, name }`; provider-neutral, `nonisolated`, `Hashable` / `Codable` / `Sendable`, non-failable from already-valid components, explicitly ID-only equality and hashing; `Station.lineIDs` is unordered canonical membership and `Station` owns **no** operator identity (a station's operators are those of its lines). S3a itself added no coordinates, colour, topology, provider mappings, or railway data.
- **S3b — coordinate contract: complete** (`9f83f38`, `090f019`; independently approved 2026-09-21). Added the provider-neutral `GeoCoordinate` value (WGS 84 latitude/longitude in decimal degrees; finite, inclusive `-90...90` / `-180...180`; failable construction; decode-side validation with `DecodingError.dataCorrupted`; complete-value equality; no framework import) and the **required** `Station.coordinate: GeoCoordinate`, giving `Station { id, name, coordinate, lineIDs }` with ID-only identity unchanged — coordinates are descriptive and never participate in identity. Representative-point selection, provenance, and actual coordinates stay in Phase 2.
- **S3c — railway topology contract: complete** (`3e75a2d`, `47b9c88`; independently approved 2026-09-22). Canonical topology is **undirected adjacent-station topology**, not an ordered sequence: `StationAdjacency` (exactly two distinct `StationID`s, unordered, failable) and `RailwayLineTopology` (`Set<StationAdjacency>`, non-empty and connected, derived unencoded `stationIDs`), plus the **required** `RailwayLine.topology`, giving `RailwayLine { id, operatorID, name, topology }` with ID-only identity unchanged — a corrected topology is the same line. Chains, cycles, branches, and loop-plus-tail shapes are supported generically by adjacency, with no operator or launch-line special case; connectedness is an internal invariant check, not a public graph or route-search API. `Trip` keeps the ordered stop traversal, whose order expresses structural direction and may repeat and skip stations; no direction field is stored (DEC-060 §G); no route search, Trip behaviour, topology data, or provider-alias mapping was added.
- **S3 completion rule — satisfied.** S3 is complete only when S3a is implemented and audited; S3b is contract-locked and implemented, or an accepted decision moves coordinates out of Phase 1; S3c is contract-locked and implemented, or an accepted decision moves canonical topology out of Phase 1; and the resulting scope passes its independent audit. **All four conditions are met**: neither coordinates nor topology were moved out of Phase 1, and the final S3c adversarial review reported no material findings. Verification at `47b9c88`: full suite **358/358 executed cases passed, 0 failed, 0 skipped**; Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. No physical-device validation is claimed for S3 or required by it.
- **Not Phase 1 deliverables.** Line colour (deferred beyond Phase 1 pending ownership and licensing resolution — DEC-055 D5); actual coordinates and representative-point selection, topology records and adjacency population, provider-alias mapping (including the Marunouchi branch record), station/line mappings, and Tokyo railway datasets (Phase 2); provider networking and ingestion (Phases 2–4).

### Slice S4 — Trip and Stop Sequence

**Status: complete (2026-09-23).** Contracts accepted (DEC-060, 2026-09-22; DEC-061, 2026-09-23); S4a and S4b implemented and independently approved. S4 follows the closed Slice S3.

**Purpose.** Define and implement the canonical *structural* representation of a `Trip` — one concrete train service — covering: ordered stop traversal; repeated station visits; intermediate topological stations skipped by a service; a railway-line association that remains compatible with through service; and the minimum relationship, if any, between `Trip` and `ServiceType`.

**To settle before implementation.** The S4 contract decision must answer, at minimum:

- how a Trip represents one or more `RailwayLine`s;
- how ordered stop traversal is represented;
- how non-adjacent repeated station visits are supported;
- whether adjacent duplicate visits are valid;
- whether scheduled times are excluded from or included in this slice;
- whether `ServiceType` belongs in S4 and, if so, its minimum structural scope;
- whether direction or destination is stored, derived, or deferred;
- how through service remains representable without treating it as a transfer.

**All of these are now answered by DEC-060**, which replaces the former `ARCHITECTURE.md` §5.3 sketch: `Trip` stores `id`, an ordered `stopSequence` of passenger stops (≥ 2, no adjacent duplicate, non-adjacent repeats required), non-empty `lineSegments` that are ordered, joined at exactly one shared boundary index, covering, and normalised — so a multi-line through service is one Trip rather than a transfer — and a `coverage` value stating whether the represented traversal reaches the real service's origin and destination, so a partial representation is never mistaken for a complete one. `providerReferences` and a singular `lineID` are rejected; `scheduledTimes`, direction, destination, and headsign are deferred with their reasons recorded; `ServiceType` is deferred to **S4b**.

**S4 is subdivided (DEC-060 H):**

- **S4a — Trip structure: complete** (`12c7edb`; independently approved 2026-09-22). Implements the DEC-060 §A–§G contract: `Trip`, `TripLineSegment`, and `TripCoverage`; `TripID`-only entity equality and hashing; an ordered passenger-stop traversal that rejects adjacent duplicate stations while supporting legitimate non-adjacent repeats; explicit closed-index railway-line segments meeting at exactly one shared boundary index, so a multi-line through service is one Trip and never implies a transfer; complete, leading-partial, trailing-partial, and middle-only coverage states, which is what distinguishes a genuine short-turn from an incomplete continuation; and invariant-preserving `Codable` decoding. Verification at `12c7edb`: full suite **476/476 executed cases passed, 0 failed, 0 skipped** (118 of them new to S4a); Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. The independent adversarial review approved it with no material findings, having inspected that evidence rather than rerunning the commands. No physical-device validation is claimed or required.
- **S4b — service class: complete** (`9f0278b`, status record `c54cd87`; independently approved 2026-09-23). Contract accepted (DEC-061, 2026-09-23). DEC-061 introduces `ServiceTypeID` and an operator-scoped `ServiceType { id, operatorID, name }` with ID-only identity, and attaches types to `Trip` through `serviceTypeSegments` — closed passenger-stop ranges on the `lineSegments` index conventions, where a shared boundary index is the only permitted overlap, joined segments differ in type, and **gaps (and an empty list) mean unknown**, so full coverage is not required; a type change at a passed station is left as a gap. The list is a required initialiser argument and a required `Codable` key (`[]` = unknown). Train brand, supplemental fare, and seat reservation are defined as separate, ride-scoped future facts with no finalised vocabulary; their implementation is **moved out of Phase 1** and nothing is attached to `Trip` for them. Evidence: the two inspected GTFS feeds do not establish any of the four facts (`PROVIDER_FEASIBILITY_AUDIT.md` §6.8); ODPT train-timetable payload verification is a separate evidence task. Fast-transfer exit doors, transfer walking time, and next-train wait time are outside S4b. **Implementation** (`9f0278b`): `ServiceTypeID`, `ServiceType`, `TripServiceTypeSegment`, and `Trip.serviceTypeSegments` with the DEC-061 §E rules; every DEC-060 invariant unchanged. Verification at `9f0278b`: full suite **565/565 executed cases passed, 0 failed, 0 skipped** (89 of them new to S4b); Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. The first independent review of `1704784..9f0278b` found one documentation finding — this roadmap still recorded S4b as unimplemented — and no code finding; `c54cd87` corrected it, and the independent re-review of `1704784..c54cd87` approved with no material findings. No physical-device validation is claimed or required. **Still deferred, not implemented:** train brand, supplemental fare, and seating (moved out of Phase 1 by DEC-061 §G); service-type records, provider aliases, `serviceTypeID`-to-`ServiceType` and operator consistency checks, and passenger-stop verification (Phase 2 dataset validation and mapping); ODPT train-timetable payload verification (separate evidence task).

S4a and S4b are both implemented and independently approved, so both sub-slices are disposed of: S4b's service-type contract is decided and implemented, and its brand, fare, and seating facts are explicitly moved out of Phase 1 by accepted DEC-061 §G. Phase 1 as a whole remains in progress.

**Inherited accepted facts** (not reopened by S4): through service is **not** a transfer (DEC-009, Rule 16); repeated `StationID`s **must** be representable in ordered Trip traversal, and consecutive Trip stops are **not** required to be adjacent in `RailwayLineTopology` — topology adjacency and Trip stop order are different concepts (DEC-057 D10); service brands are **never** `RailwayLine` identities (DEC-057, DEC-058 §7); remaining-stop calculation belongs to Trip/Journey progression, never to a line's topology (DEC-011); actual provider data, identifiers, and mappings are not Phase 1 deliverables.

**S4 completion rule.** S4 may be marked complete only when **all** of the following hold:

1. the Trip / stop-sequence contract is accepted in a decision record;
2. that accepted contract is implemented with focused tests;
3. the implementation demonstrates ordered traversal; express or limited-stop behaviour without requiring consecutive stops to be topology-adjacent; legitimate non-adjacent repeated station visits; and through-service compatibility without a fake transfer or a service-brand-as-`LineID` shortcut;
4. phase ownership and the exclusions below remain intact;
5. the implementation and its completion record pass independent review.

This rule is **structural**. Satisfying it claims nothing about populated datasets, real provider coverage, or operational through-service integration.

**S4 completion rule — satisfied** (2026-09-23). (1) The contract is accepted in DEC-060 and DEC-061. (2) It is implemented with focused tests — S4a at `12c7edb`, S4b at `9f0278b`. (3) The S4a tests demonstrate ordered traversal, express and limited-stop traversal without topology adjacency, legitimate non-adjacent repeats, and multi-line through service as one Trip with no fake transfer and no brand-as-`LineID`; S4b adds service-type segments that may change along one run without affecting any of these. (4) Phase ownership and the exclusions below are intact: no real data, provider mapping, brand, fare, seating, UI, or persistence was added. (5) The implementation and its completion records passed independent review — S4a approved 2026-09-22; S4b approved on re-review of `1704784..c54cd87`, 2026-09-23. Verification at `9f0278b`: full suite **565/565 executed cases passed, 0 failed, 0 skipped**; Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5.

**Excluded from S4.** Actual Tokyo railway records; actual Airport Rail records or brands; provider identifiers, mappings, aliases, provenance, and payload validation (Phase 2); provider networking (Phases 2–4); route search and pathfinding (Phase 3+); realtime behaviour and capability attachment (Phase 4); timetable computation; `JourneyEngine` behaviour, live progression, and current/next-station or remaining-stop calculation (Phase 5, DEC-011, DEC-050); persistence; UI, localized rendering, and Live Activities.

### Slice S5 — Journey Structure and Runtime State

**Status: complete (2026-09-24).** Contracts accepted (DEC-062, 2026-09-23; DEC-063, 2026-09-24); S5a (`bd1ae2f`) and S5b (`62530b3`) implemented and independently reviewed. S6 and Phase 1 remain open.

**S5 is subdivided (DEC-062):**

- **S5a — Journey structure: complete** (`bd1ae2f`; contract DEC-062, accepted 2026-09-23). Verification at `bd1ae2f`: full suite **709/709 executed cases passed, 0 failed, 0 skipped** (144 of them new to S5a); Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. The independent review of `7bde467..bd1ae2f` found no actionable correctness defects. No physical-device validation is claimed or required. Contract: `Journey { id, legs }` with `JourneyID`-only identity and position-addressed legs; `JourneyLeg` = `rail(RailLeg)` | `walkingTransfer(WalkingTransfer)`; `RailLeg` = `unselected(RailLegAnchors)` (boarding and alighting stations only — no Trip, index, time, or route) | `selected(SelectedRailTrip)` (a `Trip` snapshot with boarding and alighting **indices**, anchors derived); a selection must preserve an unselected leg's anchors (`RailLegAnchors.admits`), and performing the binding is Phase 5. Journey invariants: non-empty; rail first and last; station **continuity** between consecutive legs using local values only; no consecutive walking legs; a leg's two ends are distinct stations; and **Journey-wide `TripID` uniqueness** — no two selected rail legs carry the same `TripID`, whatever lies between them (unselected legs do not count; a through service is one selected leg). This conservative rule does not claim that riding the same recurring run twice is impossible; permitting reuse needs a later decision adding service-date or execution identity. An all-unselected Journey is structurally valid. A walking transfer is **stated, not verified**: pedestrian-connection verification is Phase 2, and walking time and guidance are Phase 10. Legs are not `Equatable`. Both enums encode as one keyed `kind` discriminator plus one payload key named after the case, rejecting unknown, missing, contradictory, and invalid payloads.
- **S5b — Journey runtime state: complete** (`62530b3`; contract DEC-063, accepted 2026-09-24). Verification at `62530b3`: full suite **819/819 executed cases passed, 0 failed, 0 skipped** (110 of them new to S5b); Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. `ActiveJourney` uses typed throws, which compiles in the project's Swift 5 language mode. The independent review of `feb204d..62530b3` found no actionable correctness regression. No physical-device validation is claimed or required. Contract: `JourneyPhase` stores neutral phases — `planning`, `awaitingDeparture(leg)`, `riding(leg, position?)`, `transferring(walking(leg) | atStation(afterRailLeg:))`, `plannedEndReached(schedule | trainObservedAtFinalStop)`, `interrupted(reason, leg?)`, `ended(reason)` — and the documented names (Boarding, OnTrain, Arrived, …) become derived presentation labels. `plannedEndReached` never asserts the rider's arrival: its `schedule` basis is produced by Phase 5 only against a scheduled final-arrival time, and `trainObservedAtFinalStop` concerns the train; confirmed arrival needs rider-side evidence and a later decision. `JourneyState { journeyID, phase, freshness, lastConfirmedAt?, asOf }` checks its timestamps and observed-basis freshness alone; `ActiveJourney(journey:state:)` checks the pair and throws `ActiveJourneyInconsistency` (`journeyMismatch`, `legIndexOutOfRange`, `legKindMismatch`, `legNotSelected` including first-leg readiness, `positionOutOfRange`) — the Phase 1 typed-error deliverable. `RealtimeFreshness` describes the current leg — `scheduleFallback` means timetable guidance is still available, `unavailable` means insufficient data for current guidance; stale data alone is not an interruption. `JourneyEvent` is a minimal output vocabulary with no separate interruption or ending event. `ActiveJourney` uses typed throws where the language mode allows, otherwise ordinary `throws` documented to throw only `ActiveJourneyInconsistency`. No S5b type is `Codable` or `Hashable`. Transitions, ordering, detection, and derived stations are Phase 5; recovery proposals are S6.

**S5b tests** must cover: `JourneyPosition` rejecting negative indices; `JourneyState` rejecting `lastConfirmedAt` or freshness timestamps after `asOf`, an `observed` position or `trainObservedAtFinalStop` endpoint with `scheduledOnly`, `scheduleFallback`, or `unavailable` freshness, and accepting them with `live`, `delayedUpdate`, or `stale`; `ActiveJourney` accepting every phase on a mixed Journey (selected, walking, unselected, same-station change) and throwing exactly the specified error for each invalid case — mismatched `journeyID`, negative and too-large leg indices in every phase that carries one (including `atStation` with no next leg), wrong leg kinds, riding an unselected leg, `awaitingDeparture(0)` on an unselected first leg while `awaitingDeparture(i > 0)` on an unselected leg is accepted, and positions before boarding or beyond alighting; `planning`, `plannedEndReached`, `ended`, and `interrupted` pairing with an all-unselected Journey; and `JourneyEvent` rejecting equal `from`/`to` and negative leg indices, with an interruption expressed as `phaseChanged(to: .interrupted(reason, leg))` and an ending as `phaseChanged(to: .ended(reason))`, each carrying its reason (no separate interruption or ending event kind); and, if ordinary `throws` is used, a test that every failing pair throws only `ActiveJourneyInconsistency`.

**S5a tests** must cover: `JourneyID`-only identity with explicit comparison of legs; anchor and walking-endpoint distinctness; selected-index bounds, ordering, and distinct end stations; boarding at a repeated station by index; `admits` accepting anchor-preserving and rejecting anchor-changing selections; continuity across every combination of unselected, selected, and walking legs; rail-first and rail-last; consecutive walking legs; duplicate `TripID`s rejected when directly consecutive and when separated by a walking, an unselected, or a different-Trip leg, at lower and higher indices, with identical and with incompatible snapshots, including repeated-station continuity on a loop-plus-tail snapshot, through construction and decoding; unselected legs not counted; different `TripID`s accepted when every other invariant holds; a multi-line through service as one leg; an all-unselected Journey; and `Codable` round-trips plus rejection of missing, unknown, contradictory, and invalid payloads, extreme decoded indices, and every Journey invariant.

**Excluded from S5b.** Transition graph, ordering, and how phases are reached; detection of events, interruptions, and arrival; freshness classification and thresholds; confirmed rider arrival; derived current/next station, remaining stops, and progress; recovery proposals (S6); persistence and encoding (Phase 6); presentation labels and Live Activity mapping (Phases 8–9); notifications (Phase 10); any change to `Journey`.

**Excluded from S5a.** Runtime state, phase, current leg, freshness, events, errors, and readiness (S5b); binding, replacement, progression, reconciliation, and time-dependent checks (Phase 5); service-date or execution identity for a later recurrence of the same `TripID` (a later decision); planned trips and route search (Phase 3); realtime state (Phase 4); pedestrian-connection and interchange verification (Phase 2); transfer guidance, walking time, exit doors, and next-train wait (Phase 10); persistence and timestamps (Phase 6); brand, fare, and seating (DEC-061 §G); UI and Live Activities.

**S5 completion rule.** S5 may be marked complete only when S5a and S5b are each accepted in a decision record, implemented with focused tests, and independently reviewed, with the exclusions above intact. S5 may instead close with S5b deferred **only** if a new accepted decision both **names the phase that replaces S5b** and **revises the affected Phase 1 acceptance criteria** (and any Included deliverable it removes from Phase 1); deferral alone is not completion.

**S5 completion rule — satisfied** (2026-09-24). S5a and S5b are each accepted in a decision record (DEC-062; DEC-063 as corrected at `feb204d`), implemented with focused tests (`bd1ae2f`; `62530b3`), and independently reviewed with no actionable finding, and the S5a and S5b exclusions are intact; S5b was not deferred, so no acceptance-criteria revision was needed. Verification of the final state at `62530b3`: **819/819 executed cases passed, 0 failed, 0 skipped**; Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. Completing S5 claims **no** physical-device validation and **no** Phase 5 transitions, progression, detection, or schedule comparison; **no** confirmed rider arrival; **no** recovery proposal or `JourneyEngine` protocol (S6); and **no** Phase 6 persistence or encoding of runtime state.

### Slice S6 — Domain Protocol Boundary

**Status: complete (2026-09-25).** Contract accepted (DEC-064, 2026-09-24); implemented at `fcccadc`. Verification at `fcccadc`: full suite **871/871 executed cases passed, 0 failed, 0 skipped** (52 of them new to S6); Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. The independent review of `da1ab73..fcccadc` found no actionable correctness regression. The only engine in the codebase is a test-only double (`Observation = Never`); no production transition exists. No physical-device validation is claimed or required. Phase 1 is closed by the Phase 1 Completion Record below.

**Scope (DEC-064).** The `JourneyEngine<Observation>` protocol — synchronous, pure, non-throwing, `Sendable`, with `transition(from: ActiveJourney, input:, at now:) -> JourneyTransitionOutcome` — whose `Observation` is supplied by Phase 4 and bound by the Phase 5 engine; `JourneyEngineInput` (`observed`, `timePassed`, `selectTrip`, `replaceTrip`, `end(UserEndReason)`); `JourneyTransitionOutcome` (`applied` with a valid result whose `next.state.asOf` equals the supplied `now` and which may leave the Journey and phase unchanged, or `rejected`); `JourneyTransitionResult` (same `JourneyID`, `asOf` not backwards, events inside the time window, a proposal only with a matching interruption, proposal legs in range and rail); `JourneyInputRejection` with a documented user-facing meaning and next step for every case, and the shared `structuralRejection` checks (backward `now` rejected for every input; an ended journey rejecting every input, including `timePassed` and `observed`; missing leg; walking leg; selection state; stations that differ; a `TripID` already selected on another leg, excluding a `replaceTrip` target's own `TripID`); and `JourneyRecoveryProposal` naming only reselectable rail legs. `RouteSearching`, `RouteCandidate`, and `TrainCandidate` are Phase 3.

**S6 tests** must cover: every structural check producing exactly its rejection and payload, in order, including a backward `now` for `timePassed`, `observed`, and every command, and an ended journey rejecting every input with `journeyEnded`; valid inputs passing, including `replaceTrip` with the leg's own current `TripID`, while a `TripID` selected on another leg is rejected; the `trainStationsDiffer` payload identifying the mismatched boarding and/or alighting station; every result and proposal rule accepted and rejected; a test-only engine with `Observation = Never` returning `.applied` for `timePassed` with the Journey and phase unchanged and `asOf` advanced to `now`, and `.rejected` for a structural failure, crossing actor boundaries; and exhaustive coverage of the rejection cases for the user-facing mapping.

**Excluded from S6.** Engine implementation, transitions, phase-dependent rules, and proposal content (Phase 5); realtime observation schema and provider validation (Phase 4 / 5); route search, candidates, and replanning (Phase 3); acting on proposals and persistence (Phase 6); localized rejection and proposal wording and UI (Phase 8); device context.

**S6 completion rule.** S6 may be marked complete only when DEC-064 is accepted, its contract is implemented with focused tests, and the implementation and completion record pass independent review. A **Phase 1 closure audit** follows S6 before Phase 1 is marked complete.

**S6 completion rule — satisfied** (2026-09-25). DEC-064 is accepted (`da1ab73`); its contract is implemented with focused tests (`fcccadc`) covering the S6 test list above; and the implementation passed independent review of `da1ab73..fcccadc` with no actionable correctness regression. The S6 exclusions are intact. Verification of the final state at `fcccadc`: **871/871 executed cases passed, 0 failed, 0 skipped**; Debug build and clean Release build of the app and extension succeeded; iPhone 17 simulator, iOS 26.5. This completion record, as first written at `8714d32`, passed independent review of `fcccadc..8714d32` with no actionable issue. Completing S6 claims **no** production `JourneyEngine` (the only conformer is a test-only double); **no** Phase 5 transitions, phase-dependent rules, or proposal content; **no** realtime observation schema (Phase 4), route search or replanning (Phase 3), persistence (Phase 6), or rejection wording and UI (Phase 8); and **no** physical-device validation. The Phase 1 closure audit follows in the Phase 1 Completion Record.

## Tests

Test:

- identifier equality
- station/line validation
- line topology — adjacency, connectedness, branches, cycles (DEC-057); never a global station order
- stop ordering — Trip-level actual traversal order, including repeated and skipped stations
- trip stopping patterns
- express/local differences
- through-service representation
- journey leg ordering
- invalid journey rejection
- deterministic time behavior

## Acceptance Criteria

- Domain imports no SwiftUI
- Domain imports no provider SDK
- provider IDs are not canonical IDs
- models support multi-leg journeys
- through service is representable without hacks

## Exit Criteria

Core railway truth can be represented without knowing which provider supplies the data.

## Phase 1 Completion Record

**Status: complete (2026-09-25)**, on `phase/01-core-domain` after the closure audit. The record is structural: it claims **no** real railway data, provider mapping, route search, realtime integration, production `JourneyEngine`, Phase 5 transitions, persistence, UI, or physical-device validation.

**Completion basis.** Phase completion requires scope satisfied, tests passing, relevant physical-device tests passing, documentation current, an architecture audit passed, and known blockers resolved or deferred (Rule 46; §Phase Completion). Independent review is a per-slice requirement only where a slice's completion rule or decision states it (S3–S6). S1 and S2 have no completion rule, and no accepted rule requires their independent review for Phase 1 closure.

**Slices.**

- **S1 — canonical identifiers** (DEC-051). `05c5790` added `StationID`, `LineID`, `OperatorID`, `TripID`, and `JourneyID` with 18 test cases. An independent S1 audit (recorded in DEC-051 and `ef99789`) found that construction accepted an empty string; `ef99789` made construction reject blank values, with 41 executed identifier cases and the suite at 95/95. No re-review of `ef99789` is recorded.
- **S2 — `LocalizedRailName`, `Operator`, `RailCapability`** (DEC-053, DEC-054). `0cc4c60` added the name value and `Operator` (48 cases; suite 142/142); `717ec4f` added the capability vocabulary and derived tier (42 cases; suite 185/185). An independent S2 audit is recorded only in `30fb145`, which resolved its four LOW findings without behaviour change and accepted three notes as non-blocking. No re-review of `30fb145` is recorded.
- **S3–S6**: complete under their completion rules above (S3 at `47b9c88`; S4 at `9f0278b` / `c54cd87`; S5 at `bd1ae2f` / `62530b3`; S6 at `fcccadc`, record reviewed at `8714d32`), each independently reviewed.

**Acceptance criteria — pass.** Domain imports no SwiftUI and no provider SDK: every `TSUGINO/Domain` file imports `Foundation` only, and Domain references no type declared outside Domain. Provider IDs are not canonical IDs: DEC-051 identifiers, and no canonical model carries a provider ID (Rule 9, DEC-021). Multi-leg journeys: DEC-062 `Journey` / `JourneyLeg` (`JourneyTests`, `ActiveJourneyTests`). Through service without hacks: DEC-060 `Trip.lineSegments` (`TripTests.twoLineThroughServiceSharesOneBoundaryIndex`, `threeLineThroughServiceIsValid`; `JourneyTests.throughServiceIsOneSelectedLeg`). **Exit criterion — met structurally.**

**Included deliverables — all delivered.** Canonical IDs (S1); `Station`, `RailwayLine` (S3); `Operator` and the `RailCapability` model without attachment (S2, DEC-049, DEC-054); `Trip` and stop sequence (S4); `Journey`, `JourneyLeg` (S5a); `JourneyState`, `JourneyPhase`, `JourneyEvent`, freshness and interruption (S5b); recovery proposals and the `JourneyEngine` boundary (S6, DEC-050, DEC-064); typed errors `ActiveJourneyInconsistency` (DEC-063) and `JourneyInputRejection` (DEC-064). `RouteSearching` is Phase 3 (DEC-064). **Deterministic Clock:** satisfied by the existing Phase 0 `AppClock` abstraction (`TSUGINO/Shared/Time/AppClock.swift`, `6dd9c84`; `ARCHITECTURE.md` §38 Deterministic Time), with `SystemAppClock` for production and `FixedAppClock` for tests, covered by `AppClockTests`. Phase 1 added **no** clock code: Domain never reads a clock — it contains no `Date()` or `Date.now` — and takes time explicitly, e.g. `JourneyEngine.transition(from:input:at:)` and `structuralRejection(against:at:)`, which the S5b and S6 tests drive with fixed instants.

**Tests and builds.** Full suite at `c0a1cdf` (no non-documentation change since `fcccadc`): **871/871 executed cases passed, 0 failed, 0 skipped** (re-run for this record); iPhone 17 simulator, iOS 26.5. Debug build and clean Release build of the app and extension succeeded at `fcccadc`. Phase 1 has no physical-device test requirement.

**Known finding carried forward.** The repository-wide Swift concurrency-isolation warnings (Parking Lot) remain unowned and non-blocking under Swift 5 language mode; they must be resolved by one decision before any Swift 6 language-mode migration.

---

# Phase 2 — Static Railway Data + Canonical Mapping

**Status: COMPLETE — local provisional baseline foundation (2026-10-01), under
Accepted DEC-075 and the final acceptance audit below.** This is not production
delivery readiness. S9, S10, S8 delivery and all applicable identity/publication/
bundling gates remain open follow-ups. Phase 3 has not started. Earlier dated
records retain the status at their original verification stage.

## Goal

Create a reliable local railway topology foundation.

## Included

- GTFS static ingestion
- stations
- lines
- stop sequences
- service metadata
- canonical/provider ID mappings
- static data versioning
- station search index
- Tokyo baseline dataset — Toei + Tokyo Metro: the 15 accepted lines/services (13 subway lines plus Tokyo Sakura Tram and the Nippori-Toneri Liner; DEC-047, DEC-058)
- Tier 1 expansion candidates as **gated data work, not accepted support** (DEC-058 §5): TWR Rinkai Line, Tsukuba Express, Tama Monorail, Yurikamome — payload verification, Basic-License compliance, service/feed capability declaration, and canonical mapping before any promotion; no realtime promised

## Explicitly Excluded

- realtime tracking
- route search UI
- journey progression
- transfer car/door guidance

## Implementation Tasks

- build static data importer
- normalize provider IDs
- generate canonical mappings — cross-operator canonical station identity for Toei ↔ Tokyo Metro is **analyzed and accepted (DEC-048; audit A4/§6.5, 2026-09-19)**: 285 operator-level identities → **258 proposed canonical station groups**, resolved by station codes and topology, never by names or coordinates alone. Carry it forward as a **planning input, not an accepted identifier set** — the production canonical ID format is still undecided (Rule 9, DEC-021). Each canonical station must retain every provider station identifier and code, **both providers' original name strings**, and any alias rule as an **explicit, reversible source-mapping entry** (市ヶ谷 / 市ケ谷 orthographic alias; 押上 / 押上〈スカイツリー前〉 subtitle variant). **Toei 新宿 and Tokyo Metro 新宿 remain two separate canonical groups with no inferred transfer edge** until authoritative evidence arrives; merging them later yields 257 groups and requires a controlled identity migration (RK-18, Rule 39). The 320 m span used to corroborate the analysis is **not** an implementation threshold and must not be coded as a merge rule (audit A4, RK-14, RK-18)
- choose measured storage format
- implement `RailwayDataRepository`
- implement local station search
- build Japanese/English/Korean station localization dataset
- implement localized search aliases
- implement data-version metadata
- implement migration strategy
- keep project-owned canonical data non-restorable: the canonical dataset must not be a copy from which all or most of a Basic-License provider feed (Tokyo Metro) can be reconstructed (audit §3.6.3, DS-15)
- record obtained date/time and handle Center update notices for Basic-License static/reference data (Guideline §2.2 — Tokyo Metro; Toei needs no such license duty)
- gate any offline bundling of normalized Basic-License static data in the shipped binary on the ODPT written confirmation (audit §3.12 item 5)
- represent route/pathway data availability so contest-period-limited resources (Toei GTFS-Pathways, audit RK-17) can disappear without breaking route topology

### Slice Plan (DEC-065)

**Status: accepted with DEC-065 (2026-09-25; §D amended 2026-09-26); P2-S2 design accepted with DEC-066 (2026-09-26); P2-S3 design accepted with DEC-067 (2026-09-27); P2-S4 design accepted with DEC-068 (2026-09-28); P2-S5 design accepted with DEC-069 (2026-09-30); P2-S6 design accepted with DEC-070 (2026-09-30).** P2-S0, P2-S1, P2-S2, P2-S3, and P2-S4 are complete; P2-S3's real-feed validation passed on 2026-09-29 on newly identified Tokyo Metro inputs (recovery record below). P2-S4 is *implemented* and **complete** (2026-09-30): the criteria audit found every criterion met. Its provisional real-data runs passed for both operators, and the owner accepted the newer Toei snapshot and its recorded difference explanation on 2026-09-30 (P2-S4 real-data acceptance record, below). Production identifiers, the registry of record, Tokyo Metro publication, and app bundling remain gated. P2-S5 (DEC-069) is *implemented* and **complete** (2026-09-30): the criteria audit found every criterion met, on synthetic tests and a provisional real-data run that met every baseline. Production identifiers, the registry of record, publication, and app bundling remain gated. P2-S6 (DEC-070) is *implemented* and **complete** (2026-09-30): the criteria audit combines the accepted synthetic evidence with the real-data acceptance below, including 258 selected coordinates, 15 connected topologies, both shape checks, and a byte-identical repeat. P2-S7 (DEC-071) is **implemented and complete for local real-data acceptance** (2026-09-30): 825 reviewed canonical slots, six explicit aliases, complete named Domain values and exact search, with all five repeat artifacts identical; the completion audit is below. Production identifiers, the registry of record, publication, and app bundling remain gated. Each slice starts only when the decisions listed for it are accepted. Answering a later slice's questions is **not** a precondition for an earlier slice.

| Slice | Kind | Content | Depends on | Decisions needed before it starts |
|---|---|---|---|---|
| **P2-S0** | documentation | Documentation lock: the public-repository boundary, P2-S1 scope, synthetic fixtures with local validation, and this plan (DEC-065) | — | — |
| **P2-S1** | implementation | Toei-only static GTFS **table reader** → provider DTOs (DEC-065 §B, §C, §D) | S0 | **DEC-065 only** |
| **P2-S2** | implementation | Static source intake in an offline macOS developer tool: archive member policy, streaming of the named tables with the system `bsdtar`, input consistency, and a source manifest (DEC-066) | S1 | **DEC-066 only** (accepted) |
| P2-S3 | implementation | Tokyo Metro static GTFS through the unchanged P2-S1 reader, plus an `odpt:Railway` DTO reader; invented synthetic fixtures only, real inputs local (DEC-067) | S1, S2 | **DEC-067 only** (accepted) |
| P2-S4 | implementation | Operator-level identities (149 → 141 Toei, 185 → 144 Tokyo Metro) and line mapping to the 15 baseline `LineID`s, with the Marunouchi branch record as an alias (DEC-057 D6) | S2, S3 (including P2-S3's real-data validation, for completion) | **DEC-068** (accepted) for code and synthetic tests. Completion needs real-data acceptance on identified snapshots (DEC-068 §H). Minting production identifiers, or committing any real mapping record for either operator, needs the pending registry-of-record decision (DEC-068 §F1). Publishing any Tokyo Metro-derived mapping also needs the ODPT Q3 reply or a separate accepted publication decision (DEC-065 §A) |
| P2-S5 | implementation | Cross-operator station identity from name and alias candidates, compared with DEC-048 (DEC-065 §E as amended by DEC-069) | S4 | **DEC-069** (accepted), with DEC-068. Production identifiers, committed real records, and Tokyo Metro publication stay gated as for S4 (DEC-068 §F) |
| P2-S6 | implementation | Validated representative coordinates, undirected line topology, and membership artifacts (DEC-070). Complete `Station` and `RailwayLine` construction waits for P2-S7's required names (DEC-053) | S5 | **DEC-070** (accepted), with DEC-056, DEC-057, DEC-068, DEC-069. Production identifiers, committed real records, and Tokyo Metro publication stay gated (DEC-068 §F) |
| P2-S7 | implementation | Reviewed Japanese/English/Korean names, explicit aliases, scalar-exact index/lookup, complete named Domain construction | S6 | **DEC-071 is accepted (2026-09-30).** Implementation and separate local real acceptance are complete; the criteria audit and verification are recorded below. This does not authorize publication or bundling. Real name selection/authorship and Korean review are separate; Q4 still gates new Tokyo Metro-derived translations. Q3, production-registry and P2-S8 gates remain unchanged |
| P2-S8 | implementation | Storage measurement, `RailwayDataRepository`, data-version metadata, migration strategy | S6 | **DEC-072 Accepted** for system SQLite after measurement. Bounded synthetic repository implementation is recorded below; **DEC-073 is Accepted** for reviewed canonical transitions; synthetic implementation/verification is recorded below. Synthetic technical acceptance and DEC-074 private provisional real SQLite acceptance/local-baseline milestone are complete (records below). Phase 2 baseline-foundation exit passed under DEC-075; P2-S8 production delivery remains open and all applicable gates are unchanged |
| P2-S9 | implementation | `Trip` structure import: stop sequences **without times**, with passenger-stop verification (DEC-061 F) | S4 | Accepted exit-only deferral (DEC-075): P2-S9 remains required before canonical passenger-stop Trip consumption and P3-T1 real timetable import; authorize its bounded work separately |
| P2-S10 | evidence | Tier 1 payload evidence (DEC-058 §4, DEC-059); no capability declaration | S0 | Explicit authorization for Basic-License data access; accepted exit-only deferral (DEC-075), required before candidate capability/support claims through Track A |
| P2-S11 | evidence | Physical-device measurements (cold launch, search speed, memory, offline search) | S7, S8 | explicit device authorization (`AGENTS.md` §22); `LunaTestphone` is never used |

**P2-S0 completion record** (2026-09-25). DEC-065 was accepted after product and technical review, including the four P2-S1 reader policies (DEC-065 §D): a missing final line terminator is tolerated, unused columns are ignored, only UTF-8 is supported, and a blank time with no `timepoint` value is reported as unsupported. This slice plan and the timetable planning issue are recorded. Sources were checked: the GTFS Schedule Reference (gtfs.org, published 2026-04-27) for DEC-065 §D; the cited audit sections, figures, and hashes; and the repository's public visibility. Documentation only: no code, fixture, or provider data was added. The decisions listed for later slices remain open.

**P2-S1 completion record** (2026-09-26; implementation approved after review). The Toei-only static GTFS table reader is implemented under `TSUGINO/Data/GTFS/Static/`: provider DTOs for the nine tables and typed `invalid` / `unsupported` errors carrying table and line. The only way in is the `@concurrent` `GTFSStaticTableReader.read(_:)`; the CSV layer and row decoder are `fileprivate` in the reader's file, so no other code can run parsing or validation synchronously or on the main actor. It adds no dependency, archive handling, networking, canonical identifier, Domain value, search, persistence, fare reading, or timetable, passenger-stop, or colour interpretation.

- **Rule audit.** Every rule was checked against the GTFS Schedule Reference (revised 2026-04-27, canonical source text) and labelled specification, observed Toei shape, or reader policy. DEC-065 §D was amended on 2026-09-26 as recorded there.
- **Review.** An adversarial pass found and fixed three issues: a repeated `stop_sequence` could be masked by an earlier source-order decrease (repeats are now checked across the table first, so they are always invalid); an integer too large for the reader was called invalid although the specification sets no bound (now unsupported); and DEC-065's wording on unsupported rows did not match the code (aligned). Independent Codex review of the working tree then found one defect — a header with an empty field name was accepted — which was fixed (now invalid, as the first line must name its fields). A final Codex review of the fixed state found no actionable defect.
- **Tests.** 137 focused cases, all synthetic, cover every §D case, the cross-table references, determinism, a stable first reported problem, and a main-actor caller. Full suite: **1008/1008 executed cases passed, 0 failed, 0 skipped**. Debug build and clean Release build of the app and extension succeeded. iPhone 17 simulator, iOS 26.5.
- **Local validation.** The pinned 2026-09-16 archive (SHA-256 `f10d03cd…`) was not available, so the reconciliation against that snapshot is **still outstanding**. The current public, credential-free Toei archive was read instead, fetched on 2026-09-25 and again on 2026-09-26 with the same result: SHA-256 `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`, `feed_version` 20260921. It read with **0 invalid and 0 unsupported rows**: 149 `stops` rows, all `location_type` 0; 6 routes; 5,600 trips; 122,798 `stop_times` rows; 404 `translations` rows (Japanese 202 / English 202 / Korean 0); 141 distinct stop names, 8 of them appearing twice. The hash differs from the pinned archive, so **no equivalence to the recorded snapshot is claimed**. That archive has LF line endings and no byte-order mark, so the CRLF and BOM paths are covered by synthetic tests only. The archive, its contents, and the validation driver stayed outside the repository.

**P2-S2 completion record** (2026-09-26; implementation reviewed and committed). The offline static source intake tool is implemented in `Tools/StaticDataIntake/`, following DEC-066:

- **Build.** It is built by `build.sh` with `xcrun swiftc` from its own sources and the unchanged P2-S1 reader sources. `test.sh` builds and runs a separate test runner with `-D INTAKE_TESTING`. The only repository change outside the tool is one `.gitignore` entry for `.build/`. There is no Xcode target, no dependency, no networking, and no credential; the app target and `TSUGINOTests` are unchanged.
- **How it works.** `bsdtar` reads the archive only as `/dev/fd/3`, from the single opened descriptor. That descriptor is duplicated to a number of 10 or above before spawning, because a descriptor that already is fd 3 would otherwise be closed in the child. Every run rewinds the shared offset, and hashing uses `pread`.
- **Test-only code is absent from the operator build.** The test-only entry point and hooks exist only in the runner's binary: the operator binary has none of their symbols.
- **Review.** An independent Codex review and an adversarial review of the stable change found a check-to-use gap. The output directory was re-opened by path at publication, so a path component swapped for a symlink could have redirected the manifest into the repository. The archive had a similar gap between its path check and its opening. Both are fixed, as recorded in the DEC-066 amendment: a pinned directory descriptor, and checks on the opened archive. A pipe read error is no longer taken as end of output. A second Codex review of the fixed change found two more issues, both fixed:
  - the final archive check compared only identity, so an archive directory moved into the repository during intake could pass; it now also checks the boundary;
  - withdrawing a manifest after a failed directory `fsync` could remove another process's file. The tool now never deletes by name after publication: the complete manifest stays, and a distinct error is reported.
- **Tests.** The runner passes **34/34**, 8 unit and 26 integration cases, on synthetic archives created in, and removed from, a temporary directory. It covers every case listed above, plus:
  - a FIFO archive;
  - a same-size rewrite;
  - a symlink retarget that exercises the path-identity check alone;
  - three check-to-use races: an output directory, and an archive directory, each swapped for a repository symlink, and an archive replaced between its check and its opening;
  - an archive directory moved into a stand-in repository root during intake, with its identity unchanged.

  A failed directory `fsync` cannot be triggered in a test; its handling (report, never delete) is covered by review only. `TSUGINOTests` still passes **1008/1008**. Debug build and clean Release build of the app and extension succeeded. iPhone 17 simulator, iOS 26.5.
- **Local validation, not committed.** The tool was run on the current public, credential-free Toei archive: SHA-256 `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`, 779,699 bytes, `feed_version` 20260921. It published a manifest with 9 selected members (5,306,535 bytes in total) and 2 unselected members (the two fare tables, by name only), and the reader reported 0 invalid and 0 unsupported rows. Two runs produced byte-identical manifests, and re-running onto an existing manifest was refused. The pinned 2026-09-16 archive (`f10d03cd…`) was not available; **no equivalence to it is claimed**. The archive and manifests stayed outside the repository.
- **Observed and accepted.** An archive truncated only in its central directory still streams through its local headers, with every selected member's CRC checked. This is consistent with DEC-066's selected-members-only integrity guarantee.
- **Remaining limits.**
  - Renaming the pinned output directory itself into the repository during intake is narrowed but cannot be fully excluded.
  - If the tool is killed by a signal during publication, a hidden `.static-data-intake-*.tmp` file may remain in the output directory, which lies outside the repository.
  - A copy of the tool placed inside another Git repository would check that repository's boundary instead.

**P2-S3 completion record** (2026-09-28). Implemented and reviewed as DEC-067 decides:

- **Static GTFS.** Tokyo Metro static GTFS is read through the **unchanged** P2-S1 reader. Fully invented, Tokyo Metro-shaped tests cover:
  - a byte-order mark on every table;
  - flat stops with line-letter codes, including a two-letter branch code;
  - first-row `pickup_type` 1 and last-row `drop_off_type` 1;
  - blank-time `timepoint` 0 rows;
  - `field_value` translations.

  No reader rule changed.
- **`odpt:Railway` reader.** A DTO reader in `TSUGINO/Data/ODPT/Railway/` with a single `@concurrent` entry point. It keeps source order and provider values, sorts title maps by language key, and reports typed invalid or unsupported errors that carry only a record index and a field name. It mints no identifier and matches nothing to GTFS routes. The branch shape is kept as a distinct record.
  - Implementation found that Foundation's JSON parser tolerates trailing commas and repeated keys. The reader now makes a trailing comma invalid and a repeated key unsupported, as recorded in the DEC-067 amendment.
  - The implementation review (2026-09-27, including a Codex pass) found three more gaps. All are fixed with regression tests and recorded in the DEC-067 amendment:
    - The platform parser refuses some well-formed JSON — deep nesting, out-of-range numbers, lone-surrogate escapes — which the reader had reported as invalid. The reader now checks the RFC 8259 grammar itself, with an iterative recognizer. It reports such input as unsupported (`platformParserLimit`).
    - A repeated-key error echoed any key, including provider text. It now names the key only when it is a reader field name, or a language tag inside a title map.
    - `validate-railway` read to end of file without a bound, so a file growing during the read escaped the 8 MiB limit. It now reads no more than the size recorded at open, and fails as changed otherwise.
- **Tool.**
  - The committed source list gains the verified, credentialed DS-03 entry, with no URL.
  - The read-only `validate-railway` command applies DEC-066's boundary checks and an 8 MiB limit. It writes nothing, prints only the DEC-067 §E aggregates, and reports failures without any provider value.
  - The intake contract is unchanged: the Toei manifest is byte-identical to P2-S2's.
  - Test-only overloads remain absent from the operator binary.
- **Tests and builds.**
  - Focused app tests pass **87/87**.
  - The tool runner passes **43/43**: 8 unit, 26 intake integration, and 9 DS-03 and `validate-railway` cases.
  - `TSUGINOTests` passes **1095/1095**.
  - Debug build and clean Release build of the app and extension succeeded. iPhone 17 simulator, iOS 26.5.
  - The Release build reports 75 warnings, the same count as before P2-S3. All are existing ones: actor-isolation warnings in existing `Domain` files, `AppIcon` asset warnings, and an App Intents metadata notice. None comes from P2-S3 code in `TSUGINO/Data/ODPT/`.
- **Review.** An independent adversarial review, with Codex passes on a frozen tree, found four issues. All four are fixed with regression tests: the three gaps above, plus a follow-up narrowing of repeated-key naming to title maps. The final Codex pass on the fixed tree reported no findings. **Verdict: P2-S3 passes review.**
- **Local real-data validation: passed on 2026-09-29, on newly identified inputs.**
  - On 2026-09-28 the owner-only Tokyo Metro inputs — the static archive `9a077f8f…` and the 2026-09-18 `odpt:Railway` snapshot — were not available, and none was fetched. They remain historical audit evidence.
  - On 2026-09-29 the owner acquired a new pair, and the committed readers accepted both with 0 invalid and 0 unsupported: static GTFS `76f04623…a277e1` and `odpt:Railway` `90b16083…3b97f6c`. The owner accepted these as the P2-S3 inputs (recovery record, items 4, 6, and 7).
  - This establishes compatibility with these two snapshots only. It is not a claim that either file is byte-identical to its audited counterpart, or about later provider revisions.

**P2-S4 progress** (DEC-068). Synthetic Steps 1–5 below are implemented and reviewed. On 2026-09-30 the criteria audit and real-data acceptance made P2-S4 **implemented and complete** (DEC-068 §H2; acceptance record below). Its steps are recorded here as they landed.

- **Step 1 — identifier form, minting, and registry contracts** (2026-09-28; reviewed). Synthetic only: no registry of real entities exists, no mapping record has been made, and no production identifier has been minted.
  - **App.** `TSUGINO/Data/Mapping/` holds the DEC-068 §A identifier form and the registry, provider-reference, exact-value, provenance, and status records. Decoding checks every rule, and encoding is deterministic. There is no minting in the app.
  - **Tool.** The minter and the lookup-or-mint assignment are in `Tools/StaticDataIntake/`. Generator injection exists only in the test runner's build.
  - **Review.** An adversarial review, including Codex passes on a frozen tree, found that decoding and construction could produce registries the contract forbids. All are fixed with regression tests:
    - unknown keys are rejected at every level instead of being dropped on re-encode;
    - a repeated JSON key is rejected instead of silently keeping one value, and the registry can be read only through its checked decoder, which has no `Decodable` bypass;
    - a retirement review must be printable ASCII when constructed, so every constructible registry decodes;
    - provenance, including every original name's source, must match its namespace (GTFS member and table, or `odpt:Railway` record index);
    - retirement successor cycles are rejected;
    - each original name value carries its own source reference, and several values may share a language, so a renamed value is kept beside the old one (DEC-068 §C3, §E3);
    - project and schema text — source, member, table, and field names, and review identifiers — is printable ASCII.

    The final Codex pass on the fixed tree reported no findings. **Verdict: Step 1 passes review.**
  - **Tests and builds.**
    - Focused app tests pass **85/85**, all on invented records.
    - The tool runner passes **51/51**: 8 unit, 26 intake integration, 9 DS-03 and `validate-railway`, and 8 minting cases.
    - `TSUGINOTests` passes **1180/1180**.
    - Debug and clean Release builds of the app and extension succeeded. iPhone 17 simulator, iOS 26.5.
    - The Release build reports the existing 75 warnings; none comes from `Data/Mapping`.
    - The operator binary has no generator-injection entry point, and the app binary has no minting.
- **Step 2 — grouping proposals and reviewed grouping records** (2026-09-28; reviewed). Synthetic only: no real grouping, mapping, or identifier.
  - **App.** `Data/Mapping/StationGrouping.swift` holds the reviewed grouping record, its per-grouping exception, and the record set. A record names its members' `stops.stop_id` source references in one input, the digest of the evidence reviewed, and the decision.
  - **Tool.** Candidates come from shared name values among rows of one established operator. Each gets the DEC-068 §D2 evidence and checks: one operator, no shared route, code fit, stop-sequence neighbours, Japanese and English name evidence, and uniform names. It is then proposed or held back, with findings and source references. Rows merge only through an accepted record whose evidence digest matches, and a failed check only through that record's own exception. Coordinates are not read.
  - **Review.** An adversarial review, including Codex passes on frozen trees, found eight defects. All are fixed with regression tests:
    - an exception could waive the one-operator check and merge rows of two operators. The operator boundary is now non-waivable (DEC-068 §D5): no exception can name it, and an acceptance of a candidate that spans operators fails;
    - applying records took a report separately from its input, so identities could mix two archives. Proposals are now made from the one input inside the apply step;
    - in a one-agency feed, a route without `agency_id` was treated as a different operator from a route naming that agency. Such a route now resolves to the feed's only agency, and an `agency_id` the feed does not define is unresolved;
    - a row served by no route contributed no operator, so it passed the boundary and could be merged by an exception. It now has no established operator, fails the boundary, and is never grouped;
    - a candidate lacking Japanese or English name evidence was proposed. It is now held back by a `nameEvidence` check. The published name counts in the feed's language, and a `ja` or `en` translation counts;
    - in a feed with several agencies, another operator's same-name row pulled a valid pair into a candidate that crossed operators, which could never be accepted. Candidates now form only among rows of one established operator. A row with no established operator — no route, an undefined agency, or several agencies — forms candidates only with such rows, which the boundary holds back. Where it shares a name with a candidate, it is reported against that candidate as a competing row;
    - a record naming an unknown row, another input's `stops.txt`, or rows never proposed together failed with one generic error. Each now fails with a distinct error. Rows with no name in common cannot be grouped in P2-S4, and nothing merges;
    - a `stop_id` repeated in an input built without the reader would sit in two identities. The grouping input now refuses it.

    The final Codex pass on the fixed tree reported no findings. **Verdict: Step 2 passes review.**
  - **Tests and builds.**
    - Focused app tests pass **93/93**: 8 grouping-record cases and the 85 Step 1 cases, all on invented records.
    - The tool runner passes **68/68**: 8 unit, 26 intake integration, 9 DS-03 and `validate-railway`, 8 minting, and 17 grouping cases, on invented feeds.
    - `TSUGINOTests` passes **1188/1188**.
    - Debug and clean Release builds of the app and extension succeeded. iPhone 17 simulator, iOS 26.5.
    - The Release build reports the existing 75 warnings, which predate Step 2; none comes from `Data/Mapping`.
    - The operator binary has no generator-injection entry point, and the app binary has no proposal, apply, or minting code.
  - **Not done.** Step 2 does not complete P2-S4, which remains neither implemented nor complete. Real-data validation is outstanding (DEC-068 §H).
- **Step 3 — reviewed line bindings** (2026-09-28; reviewed). Synthetic only: no real binding, mapping, or identifier.
  - **App.** `Data/Mapping/LineBinding.swift` holds the reviewed binding record, its per-member acceptance, and the record set. A record binds static routes and `odpt:Railway` records to one `LineID`, naming each member's source reference and the evidence digest. No accepted rule limits a line to one route (`ARCHITECTURE.md` §40), so a record may hold several. The set rejects a repeated review, a provider record bound twice to one `LineID` or to two, and a `LineID` in two records.
  - **Tool.** Official-field checks — line code against stop-code prefixes, Japanese and English display titles against route long names, colour, and a unique counterpart — propose each route with its candidate records and report every disagreement. They never bind.
    - In a binding, each record is compared with every bound route, and each route with every other. Agreement with one route never hides a disagreement with another.
    - Applying requires, for every route and record: a reviewed binding whose evidence digest matches and whose acceptances name exactly the failed checks; a `LineID` the registry holds; a route agency resolved within its feed (a route naming no agency takes the feed's only agency); and an active registry operator reference for every member, all naming one operator. No `OperatorID` is minted or inferred. An unbound route or record fails the run.
    - **Launch inputs.** The rule applies only when the operator identifies **both** the run's GTFS input and its Railway input, each by source and SHA-256, as launch inputs. Then a Railway record whose line code is a stop-code prefix of a route must be bound with that route. No acceptance can waive this, so a launch branch record cannot be split from its main line's `LineID` (DEC-068 §D4). The identities are supplied with the run, not kept in the repository. For other inputs, a fully accepted split is the reviewer's decision. The rule is tested only on invented feeds: it is not evidence that the real launch feeds satisfy it or bind correctly.
  - **Branch provenance.** A Railway record keeps its own reference and its whole station order: each entry's `odpt:index` and station, with its record index and field. A blank station is refused rather than dropped. Matching stations to GTFS stops belongs to canonical station formation, so a record's GTFS stop scope is recorded as *deferred*. A stop-code prefix group is check evidence only, because a shared stop may carry the main line's code.
  - **Step 2 correction.** A Japanese or English name counts only in a display language: no script subtag, or `Jpan` / `Latn`. A `ja-Hrkt` or `ja-Latn` reading satisfies neither Step 2's `nameEvidence` check nor Step 3's title checks.
  - **Review.** The first Codex pass on the frozen tree reported no findings. An adversarial review found and fixed these, each with regression tests:
    - in a launch input, accepting every disagreement could split a branch record onto a second `LineID`;
    - agreement with any one bound route hid a disagreement with another, and unrelated routes could be bound with no acceptance;
    - a blank station-order entry was dropped from the evidence;
    - `odpt:index` values were not part of the evidence;
    - in a launch input, a line-code route left unbound was reported as a split rather than as unbound.

    The final Codex pass on the fixed code tree (`b233f2a5ad5760db`) reported no findings. **Verdict: Step 3 passes review.** P2-S4 as a whole remains neither implemented nor complete, and its real-data validation is outstanding (DEC-068 §H).
  - **Tests and builds.**
    - Focused app tests pass **99/99**: 6 line-binding, 8 grouping-record, and 85 registry cases.
    - The tool runner passes **91/91**, including 18 grouping and 22 line-binding cases, on invented `Q` / `Qb` feeds.
    - `TSUGINOTests` passes **1194/1194**.
    - Debug and clean Release builds of the app and extension succeeded. iPhone 17 simulator.
    - The Release build reports the existing 75 warnings; none comes from `Data/Mapping`.
  - **Limits.**
    - An agency without `agency_id` cannot be bound to an operator: no DEC-068 §C1 namespace identifies it.
    - A branch record's GTFS scope is deferred.
    - The launch rule assumes a launch line code's stops are served only by its line's routes, as the audit observed. A launch input where that fails, fails the run until reviewed.
    - Whether each launch input's bindings give its baseline line count is checked at real-data acceptance (DEC-068 §H).
    - Colour is compared as six hexadecimal digits, ignoring one leading `#` and case. Values are kept as written.
  - **Open items.**
    - P2-S3's real Tokyo Metro validation passed on 2026-09-29 (recovery record below).
    - The actual launch bindings and baseline checks passed in the 2026-09-30 provisional runs (acceptance record below): 6 Toei route bindings, and 9 Tokyo Metro routes and 10 Railway records bound to 9 `LineID`s, with the branch record on the Marunouchi `LineID`.
    - If a launch feed has an agency without `agency_id`, a DEC-068 decision on how to reference it may be needed.
- **Step 4 — feed-revision reconciliation** (2026-09-28; reviewed). Synthetic only: no real registry, reference, or identifier.
  - **App.** `Data/Mapping/ReviewedRevision.swift` holds the two reviewed revision records — *attach* a provider key the registry has never held to an existing identity, and *retire* an active or absent reference — and their set: one record per review and per reference.
    - Registry schema version 2 adds `attachedBy` to a provider reference: the review that attached it, kept for good, as a retirement already keeps its review. A rerun verifies that same review.
    - Version 1 files are rejected rather than silently migrated. They are regenerated, which is possible only because every registry so far is provisional and holds no production identity (DEC-068 §C1 as amended 2026-09-28).
  - **Tool.** `RevisionReconciliation` reconciles a validated registry with the references observed in one identified input of one source. The observations are grouped into entities by the new input's own reviewed groupings and bindings, and every observed `stop_id` carries its serving routes.
    - The registry stores no routes. Route changes are therefore found against the *previous input*: the one the registry was last reconciled with for this source. It is required once the registry holds an active reference of the source. It must cover every namespace of an active reference that the run covers, and contain each such reference with its provenance on the previous input's hash.
    - It reports the DEC-068 §E3 categories, in this order of precedence:
      - Only the exact key — source, namespace, and value, scalar by scalar — links an observation to the registry. A respelled provider key is therefore *new*, and the old key goes *absent*; it is never a change.
      - A retired key that reappears is a *conflict*.
      - A held key is *unchanged* or *changed*: changed when its names differ from those seen in the input it was last seen in, or its serving routes differ from the previous input's (reported, not stored). Name history is append-only: every value keeps its first-sighting source, and each later sighting is recorded beside it with its own source. An identical entry is not added twice. An absent key returns to active and is reported as reactivated.
      - A new provider key stays *unassigned* unless a reviewed record attaches it. A new code (`stop_code`, Railway `lineCode`) on an entity anchored by a held or attached provider key is a descriptive *change* of that identity and needs no review.
      - A held reference of the source, in a namespace the input covers, that is not observed goes *absent*: kept, not current, never deleted.
  - **Conflicts fail the run.** These are: a retired key reappearing; one entity resolving to two identities (a merge); one identity's references in two entities (a split); an entity on a retired identity; and two stop rows already grouped — held on one identity — that now share a route, unless the previous input shows they already did (a grouping accepted with a reviewed exception). Without that evidence, the route conflict fails closed. Rows grouped for the first time are settled by their own review. Reviewed records are idempotent: rerunning a run's records against its own output changes nothing, while a record that would rebind or re-retire under another review is still refused. Every conflict is collected and the run fails with no registry, summary, or report produced. Merges and splits need an identity migration, which Step 4 does not perform.
  - **Registry.** Canonical identifiers, first sightings, and entities never change. The revision advances only when a reference changes, so a repeat run is a fixed point. Output is byte-identical for the same registry, input, and records. The summary holds only counts, the source, hashes, and revisions.
  - **Tests and builds.**
    - Focused app tests pass **109/109**: 4 revision-record, 6 line-binding, 8 grouping-record, and 91 registry cases (85 before schema version 2).
    - The tool runner passes **112/112**, including 21 revision cases, on invented registries and inputs.
    - `TSUGINOTests` passes **1204/1204**.
    - Debug and clean Release builds of the app and extension succeeded. iPhone 17 simulator.
    - The Release build reports the existing 75 warnings; none comes from `Data/Mapping`.
  - **Review.** Codex passes on frozen trees and an adversarial review found and fixed these, each with regression tests:
    - before review: a re-observed name overwrote its first-sighting source. Name history is now append-only;
    - observations carried no route evidence, so a route change or newly shared route was reported as unchanged. Fixed with the previous-input comparison;
    - the route conflict would also have blocked a new grouping accepted by review. It now covers only rows already held on one identity;
    - rerunning a run's reviewed records against its own output failed, so a retry was not a fixed point. Records already applied are now left alone;
    - a substitute attach record with the same key and identity was accepted as already applied, because the registry did not store which review attached a reference. Fixed by schema version 2's `attachedBy`, which a rerun verifies;
    - a same-source previous input that covered no namespace, or omitted an active reference, passed its check vacuously, so route changes and conflicts could be missed. It must now cover and contain every active reference the run covers.

    The final Codex pass on the fixed code tree (`fe5bea64482569e0`) reported no findings. **Verdict: Step 4 passes review.** P2-S4 as a whole remains neither implemented nor complete.
  - **Open contract questions.**
    - *Value reuse.* Retiring a value that is present in the input — DEC-068 §E1's reuse case — stops with `undecided(.retireObservedValue)`. The registry holds one reference per key, and DEC-068 does not say how a reused value's new meaning is recorded.
    - *Resolving conflicts.* DEC-068 §E3 says a conflict fails "until a reviewed record resolves it" but defines no such record. The identity-migration record (§E4) is also undefined. Both remain conflicts.
    - *Route history.* The previous raw input must be retained outside the repository to reconcile the next one (DEC-068 §C3 allows this). Route changes are reported, not stored in the registry.
    - *Interpretations to confirm.* A dropped name counts as a descriptive change. Codes are descriptive and provider keys identifying. The caller declares which namespaces an input covers. Recording every sighting grows name history by one entry per name per new input.
  - **Not done.** Turning feeds into observations, writing a registry or report (the provisional-registry command), and real-data acceptance. P2-S4 remains neither implemented nor complete, and its real-data validation is outstanding (DEC-068 §H).
- **Step 5 — provisional-registry command** (2026-09-28; reviewed). Synthetic only: no real registry, record, or identifier.
  - **Scope.** The offline tool gains `mint`, `review-packet`, and `provisional-registry` (DEC-068 §B2, §G). It adds no fetching, credentials, or real data, and no production identity or Domain change.
    - Every registry these commands write is provisional (§B6).
    - No `StationID` exists in P2-S4 (§D2), so the registry holds only operators and lines. Station grouping runs and is checked in its established place, but is reported only as counts.
  - **`mint`.** On explicit request only, it adds *n* provisional operator or line entities — never a station — to a registry, or to an empty one. It publishes the result as a new file, never replacing one.
  - **`review-packet`.** Read-only. From the identified inputs, the registry, and a records file whose operator records are written, it exports one new file:
    - every grouping proposal and held-back candidate (Step 2);
    - every line proposal and unmatched Railway record (Step 3), with evidence digests computed as they will resolve once the operator records apply;
    - the operator keys, and the registry's active operator and line identifiers;
    - with a selection file, the exact evidence and digest for each reviewer-chosen member set, such as several routes of one line. It comes from the same Step 3 evidence path `provisional-registry` checks, so the digest is accepted unchanged. It refuses:
      - a selection file for other sources or inputs;
      - unknown, repeated, or cross-input members;
      - a member in two selections;
      - an unresolved agency, an unbound operator, or members of different operators.

      An ambiguous selection is exported with its `uniqueCounterpart` finding.

    The packet holds provider values: it stays with the inputs and is never committed. Only counts are printed.
  - **`provisional-registry` inputs.** All are outside the repository and read-only:
    - one GTFS archive of a known source, read by the intake's own stages (`ArchiveReading`);
    - optionally one `odpt:Railway` file, read by validate-railway's checked read;
    - the provisional registry (schema version 2);
    - the reviewer's records file (schema version 1). It names both source identifiers and both input hashes, and is refused for any other, on a repeated key, or on an unknown key;
    - once the registry holds references of a source, the previous inputs and records it was last reconciled with;
    - optional launch-input identities for the line-binding rule.
  - **Stages, in order.** Path checks; reading and identifying every input; a Railway-source check; grouping; operator reconciliation; line binding against the reconciled operators; line reconciliation.
    - The Railway-source check refuses the run if a Railway `@id`, `owl:sameAs`, or operator value observed here is held under another source identifier (`sourceMismatch`).
    - A reviewed operator record or line binding attaches its new keys, one attach record per key, with review identifier `<reviewID>:<n>`.
    - Railway `@id`, `owl:sameAs`, and line code are each their own reference, with their own provenance (DEC-068 §C1).
    - A held key must already resolve to the record's identity. The command never rebinds a key: that fails with `identityMismatch`.
    - Step 4's undecided transitions and conflicts stop the run.
    - The run's registry advances one revision when a reference changed.
  - **Output contract.** A new directory holding `registry.json` and `report.json`, published by one `RENAME_EXCL` rename of a complete temporary directory (`DirectoryPublication`). The pair appears whole or not at all, and never replaces an existing entry. Nothing is published unless every stage has passed. On any failure before the rename, the files written and the temporary directory are removed.
  - **Exposure.** The report and printed output hold only counts, hashes, revisions, and source identifiers. Errors name a stage and an error kind; review identifiers and provider values are stripped. One exception predates this step: intake errors can name an archive member, as DEC-066 accepted.
  - **Review (once).** It found and fixed, each with regression tests:
    - Railway `owl:sameAs` was not recorded, against DEC-068 §C1 and `ARCHITECTURE.md` §40;
    - the operator-supplied Railway source identifier was checked against nothing, so a different identifier could silently duplicate the mapping under a new source. It is now bound to the records file and checked against the registry;
    - `mint`'s programmatic entry accepted the station kind;
    - no review export existed, so a reviewer could not obtain the evidence digests the records need. `review-packet` now provides them;
    - the packet gave line proposals only one route at a time, although Step 3 permits a binding of several routes. This gap is closed: `review-packet --select` exports the exact evidence for any reviewer-chosen member set, and `provisional-registry` accepts it unchanged.
  - **Tests and builds.**
    - The tool runner passes **128/128**, including 16 provisional-registry cases on invented archives, Railway files, registries, and records. They cover:
      - a first run with `owl:sameAs` provenance, and an identical, byte-identical rerun;
      - a reviewed change;
      - a missing or mismatched previous input;
      - the undecided transition, a conflict, and a rebind;
      - records for other inputs or sources, a Railway-source substitution, a repeated key, and an unheld line;
      - repository paths;
      - an existing or racing output, and a failure part-way through publication;
      - `mint`, including the station refusal;
      - `review-packet`, whose digests are the ones a full run accepts;
      - a selected two-route, two-record binding, whose packet digest and findings `provisional-registry` accepts unchanged;
      - an ambiguous selection;
      - refused selections, including crossing and unbound operators.
    - Before this review's tool-only fixes, the final gate passed: `TSUGINOTests` **1204/1204**, and Debug and clean Release builds of the app and extension (the existing 75 Release warnings, none from `Data/Mapping`). The fixes and the member-selection export changed no app code or build integration, so the gate was not rerun.
  - **Operational limits.**
    - *Durability.* Publication uses `fsync`, as manifest publication does, not `F_FULLFSYNC`, so a power loss can still lose a just-published output that the drive had cached.
    - *Crash leftovers.* A crash before the rename can leave a hidden temporary directory beside the output, never at the output name.
    - *Same-user interference.* A process running as the same user could add a file to the 0700 temporary directory before the rename.
    - *Railway source list.* One Railway source entry, `DS-03/tokyometro-railway`, is defined (2026-09-29), apart from the intake sources. `review-packet` and `provisional-registry` refuse any other `--railway-source`. The identifier is still bound to the records and checked against the registry.
    - An agency without `agency_id` cannot be bound to an operator.
    - Observed-value reuse and conflict-resolution or identity-migration records remain undecided (Step 4).
  - **Not done at Step 5.** Real-data acceptance on identified snapshots (DEC-068 §H), whose P2-S3 prerequisite passed on 2026-09-29. It was completed on 2026-09-30 (acceptance record below).
- **Real-data acceptance preflight** (2026-09-28; rows 1–3 and 5 amended 2026-09-29 by the accepted recovery item 4; DEC-068 §H). Nothing was minted, no reviewed record was written, and no archive, manifest, packet, registry, or record was committed. Every local output stays outside the repository.

  | Row | Source snapshot | Expected aggregate | Reviewed records needed | Pass condition | Status |
  |---|---|---|---|---|---|
  | 1. P2-S3 Tokyo Metro static | owner-only archive acquired 2026-09-29T13:56:51Z, SHA-256 `76f046236893b136f0d84b2e2ce21db67375a90e63c9e594732e1bec48a277e1` (1,135,582 bytes, `feed_version` 20260921) | 0 invalid, 0 unsupported; §E aggregates recorded; every difference from the audit stated | none | intake reports 0 invalid and 0 unsupported on that hash, and every difference is stated without claiming a match | **Passed** 2026-09-29: agency 1, stops 185, routes 9, trips 9,706, `stop_times` 176,385, calendar 2, `calendar_dates` 20, `feed_info` 1, translations 494 |
  | 2. P2-S3 Tokyo Metro Railway | owner-only `odpt:Railway` snapshot acquired 2026-09-29T13:56:51Z, SHA-256 `90b16083b4acfd73d4ad4dc840f6702e57799279d05d1e6781961c8ab3b97f6c` (49,842 bytes) | 10 records, 0 invalid, 0 unsupported | none | validate-railway reports these on that hash | **Passed** 2026-09-29: 10 records, 10 distinct line codes, 186 station-order entries |
  | 3. Toei, audited snapshot | pinned archive `f10d03cd…` (779,674 bytes) | 149 rows → 141 identities; 6 route bindings | one operator record; a decision on each of the 8 grouping candidates; 6 line bindings | a provisional run on that hash reproduces the audit's aggregates | **Historical**: pinned archive not available; row 4 stands in (DEC-068 §H2) |
  | 4. Toei, other snapshot | current public archive `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4` (779,699 bytes, `feed_version` 20260921) | recorded, not assumed (below) | as row 3, written for this hash | a provisional run succeeds, and every difference from the audit is explained and reviewed | **Passed 2026-09-30** (149 → 141, 8 accepted, 0 held back, 6 bindings); the differences observed in the available audit aggregates were explained, and reviewed by the owner |
  | 5. Tokyo Metro P2-S4 | rows 1–2 inputs (the 2026-09-29 pair) | 185 rows → 144 identities; 9 routes and 10 Railway records → 9 `LineID`s, the branch record on the Marunouchi `LineID`; official-field checks agree 9/9 | one operator record; decisions on 32 grouping candidates; 9 line bindings (the branch with its accepted disagreements); both inputs identified as launch inputs | a provisional run with the launch rule succeeds, and every difference from the audit is explained and reviewed | **Passed 2026-09-30** (185 → 144; 9 routes and 10 records → 9 `LineID`s; branch retained; official-field agreement 9/9; differences reviewed with recovery item 4) |

  P2-S4 is complete only when row 3 or row 4, and row 5, pass (DEC-068 §H2).
  - **Historical audit inputs.** The audit's Tokyo Metro static archive `9a077f8f…` (1,113,444 bytes, `feed_version` 20260528; 185 `stops`, 9 routes, 9,544 trips, 172,168 `stop_times`, 494 `translations`), its 2026-09-18 `odpt:Railway` snapshot `90b16083…b97f6c` (49,842 bytes), and the pinned Toei archive `f10d03cd…` are historical audit evidence, not acceptance inputs. The new Tokyo Metro static archive is demonstrably a different archive from `9a077f8f…`: its SHA-256, size, `feed_version`, and three table counts differ. Whether the new Railway file is byte-identical to the 2026-09-18 snapshot is **unknown**: its size, the shortened hash, and every recorded aggregate agree, but the audit kept only a shortened hash. It is therefore neither claimed identical nor claimed different. The comparison and its limits are in the recovery record (items 6 and 7).
  - **Row 4, local run.** Two credential-free requests went to the audited public source: `api-public.odpt.org` answered 302, and the redirect was checked before it was followed (HTTPS, an Azure Blob host, no user information, no credential or cookie sent). The archive's SHA-256 equals the one recorded on 2026-09-25 and 2026-09-26.
    - Intake: 0 invalid, 0 unsupported; 9 selected and 2 unselected members.
    - Rows: agency 1, stops 149, routes 6, trips 5,600, `stop_times` 122,798, calendar 4, `calendar_dates` 51, `feed_info` 1, translations 404.
    - `review-packet`, on an empty registry with no reviewed record: 8 grouping proposals of 2 rows each, 0 held back. If a reviewer accepted all 8, the result would be 141 identities from 149 rows.
    - Line evidence: 6 route-only proposals with 0 findings. All 6 routes have Japanese and English titles and code prefixes; 4 have a colour. The one agency has an `agency_id`.
  - **Row 4, differences from the audit's pinned archive.** The hash differs, so no equivalence is claimed. `calendar_dates` is 51 rather than 39, and the size 779,699 bytes rather than 779,674. The other audited counts are equal. These are the differences visible in the audit's aggregates, not necessarily every byte-level or row-level difference. They were explained and accepted on 2026-09-30 (acceptance record below).
  - **Outstanding gates.**
    - Rows 1 and 2 passed on 2026-09-29. The audited Tokyo Metro inputs were never located, and are historical evidence only.
    - The pinned Toei archive `f10d03cd…` (row 3) is historical. Row 4 stands in for it.
    - Rows 4 and 5: the reviewed records and provisional runs were completed on 2026-09-30 (acceptance record below). Both passed; the owner reviewed row 4's explained differences on 2026-09-30.
    - The Tokyo Metro Railway source identifier is resolved: `DS-03/tokyometro-railway` is defined in the tool's source list.
- **Real-data recovery record** (proposed 2026-09-28; item 4 **accepted by the owner on 2026-09-29**). The owner does not recall retaining the audited Tokyo Metro files, and a targeted local search found none. So `9a077f8f…` and `90b16083…` are no longer treated as files presumed to exist. On 2026-09-29 the prerequisites of item 5 were checked, the owner acquired a new pair (item 2), and both committed readers validated it (item 6). Nothing has been minted, reviewed, or run beyond those two readers.
  1. **What can be acquired now.** These were verified on 2026-09-28 from the public catalog pages on `ckan.odpt.org`, unauthenticated; no provider file was downloaded.
     - **Static GTFS:** dataset `train-tokyometro`, resource `d4f11962-1c5a-4316-9a16-7fb229c227ea`, format GTFS/GTFS-JP. Host `api.odpt.org`, path `/api/v4/files/TokyoMetro/data/TokyoMetro-Train-GTFS.zip`, with an `acl:consumerKey` query parameter. This matches DEC-067's recorded metadata.
     - **`odpt:Railway`:** dataset `r_route-tokyometro`, resource `81d953eb-65f8-4dfd-ba99-cd43d41e8b9b`, format JSON. Host `api.odpt.org`, path `/api/v4/odpt:Railway`, with an `odpt:operator` filter and an `acl:consumerKey` query parameter.
     - **Terms.** Both datasets are labelled with the Basic License (S2), so an ODPT developer registration is required (S2 Art. 14(1)). The access token must be managed so that it is not disclosed to a third party (S5 Art. 5(1)(5)). Access frequency is at the Center's discretion (S5 Art. 4(4)). The dated establishment and revision lines on the current terms site match the audit's S2, S2a, and S6 records, with none newer. That was a date-level check on 2026-09-28; the full texts were read on 2026-09-29 (item 5).
     - **Prerequisites.** The owner's ODPT access token, which was not inspected, requested, or used by the agent; the owner entered it at a hidden prompt in their own terminal. On 2026-09-29 the official API specification was read from the developer site's public page asset, without a credential: the request rules (§1.3–1.6), `GET /api/v4/odpt:Railway` and its definition (§3.2.3, §3.3.3), the File API (§6), the member-portal addendum, and the update history, whose entries since the audit do not affect these two requests.
  2. **One-time local acquisition, by the operator, outside the repository.** No network client is added to the app or the intake tool (DEC-067 §C).
     - Use a new owner-only directory (mode 700; `umask 077`; files 600) outside the repository.
     - Read the token only into the acquiring process: from an existing environment variable, or from a hidden prompt such as `read -rs`. Never from a command argument, a committed or shell-history file, or a log. Shell tracing is off, and the token-bearing URL is never printed.
     - **Static GTFS:** one GET to the path above, with no automatic redirect. Check the `Location` in memory before use: `https`, an ODPT Azure Blob host, port 443, no user information. Then make one GET to it without the token, `Authorization`, cookies, or `Referer`, and discard the `Location`.
     - **Railway:** one GET for the Tokyo Metro operator, with no redirect followed; the response must be JSON.
     - **Local acquisition record (600, never committed).** For each file: UTC acquisition time, dataset and resource identifiers, the query-free host and path, the HTTP status, the redirect host only, the exact byte count, and the SHA-256. It holds no token, signed URL, response body, or other header.
     - The files are Basic-License data. They are never redistributed (S2 Art. 8(4)) and are kept deletable, as audit §6.2 records.
  3. **Validation and review, all outputs outside the repository.**
     - `static-data-intake --source DS-03/tokyometro-static-gtfs --archive … --obtained-at … --output …` and `validate-railway --input …`. Record only aggregates and hashes. Compare them with the audit's aggregates (§6.2.2), stating every difference, and never claiming a match.
     - Then `mint` provisional operator and line entities, write the operator record, and run `review-packet` with the Railway input (and `--select` for any multi-member binding). A human reviewer writes the grouping decisions and the line bindings — the branch record with its accepted disagreements — from the packet. Finally run `provisional-registry` with both inputs identified as `--launch-input`.
     - The packet, registry, records, and report stay with the inputs and are never committed.
  4. **Matrix amendment** (accepted 2026-09-29).
     - Rows 1–2's `9a077f8f…` and `90b16083…` stay recorded as **historical audit evidence**, and are no longer acceptance inputs.
     - The newly identified pair (item 6), recorded by hash, byte count, and acquisition time, is the P2-S3 and P2-S4 Tokyo Metro acceptance input. Its aggregates and every difference from the audit were reviewed (item 7). This is DEC-068 §H2's "any other snapshot" rule, and the ROADMAP P2-S3 criterion that any other archive is "recorded without claiming a match".
     - The same applies to Toei: row 3 (`f10d03cd…`) is historical, and row 4 (`dd575706…`) is the acceptance input.
     - New bytes are never said to reproduce the old snapshots.
  5. **Prerequisites and remaining gates.**
     - *Before the Tokyo Metro run:* the owner approved replacing the missing historical files with a newly identified pair on 2026-09-28. The Railway source identifier `DS-03/tokyometro-railway` (dataset `r_route-tokyometro`, resource `81d953eb-65f8-4dfd-ba99-cd43d41e8b9b`, credentialed, no URL) is defined in the tool's source list, apart from the intake sources, under audit registry row DS-03, which already lists `r_route-tokyometro`. Its test passed on 2026-09-29 (the full runner: 129 passed, 0 failed). Also on 2026-09-29, before any request: the full current Basic License (with its Specific Terms appendix), the Center Use Rules, and the Developer Guideline were read in English and in the governing Japanese; their dated lines match the audit's S2, S2a, S5, and S6 records, with none newer. The `odpt:operator` filter value in the official catalog entry for resource `81d953eb…` is the Tokyo Metro operator, as the acquisition used.
     - *Only if a case arises:* agencies without `agency_id`; observed-value reuse; conflict-resolution and identity-migration records.
     - *Before production identifiers or any committed mapping record:* the registry-of-record decision (DEC-068 §F1).
     - *Before publishing any Tokyo Metro-derived mapping:* the ODPT Q3 reply or a separate publication decision (DEC-065 §A, DEC-068 §F3).
     - *Before bundling data in the app:* ODPT item 5 and P2-S8.
     - Canonical stations remain P2-S5.
  6. **Acquisition and reader validation** (2026-09-29). The owner ran the one-time acquisition once, at 2026-09-29T13:56:51Z, into a new owner-only directory outside the repository. Both files, the local acquisition record, and the intake manifest are mode 600 there and are not committed. SHA-256 values were recomputed from the saved bytes and equal the acquisition record.
     - **Static GTFS** (`DS-03/tokyometro-static-gtfs`): the API answered 302 and the redirect was checked before it was followed; the Azure download answered 200. 1,135,582 bytes, SHA-256 `76f046236893b136f0d84b2e2ce21db67375a90e63c9e594732e1bec48a277e1`.
       - Intake: 0 invalid, 0 unsupported; `feed_version` 20260921; 9 selected and 2 unselected members.
       - Rows: agency 1, stops 185, routes 9, trips 9,706, `stop_times` 176,385, calendar 2, `calendar_dates` 20, `feed_info` 1, translations 494.
       - **Differences from the audit's archive** (`9a077f8f…`, 1,113,444 bytes, `feed_version` 20260528). The hash differs, so this is a different archive and no equivalence is claimed. Size: 22,138 bytes larger. `feed_version`: 20260921, not 20260528. Trips: 9,706, not 9,544 (+162). `stop_times`: 176,385, not 172,168 (+4,217). `calendar_dates`: 20, not 26 (−6). Equal: agency, stops, routes, calendar, `feed_info`, translations, and the 11 archive members. Item 7 explains these differences for P2-S3. P2-S4's reviewed run reconciles station and route content.
     - **`odpt:Railway`** (`DS-03/tokyometro-railway`): the API answered 200 with JSON, and no redirect occurred. 49,842 bytes, SHA-256 `90b16083b4acfd73d4ad4dc840f6702e57799279d05d1e6781961c8ab3b97f6c`.
       - `validate-railway`: 0 invalid, 0 unsupported; 10 records; 10 distinct line codes (a count only); 186 station-order entries.
       - Record title languages: ja 10, en 10, ko 9, zh-Hans 9, zh-Hant 9. Station-order title languages: ja, en, ko, zh-Hans, zh-Hant, and ja-Hrkt, 186 each.
       - **Comparison with the audit's snapshot** (`90b16083…b97f6c`, 49,842 bytes). Every recorded aggregate is equal: the record count, the distinct line-code count, the station-order total (the sum of the audit's per-line counts), and the record-title and station-title language coverage. The byte count and the recorded hash prefix and suffix also agree. But the audit records only an abbreviated hash, and no repository document or commit holds the full value. So an exact snapshot match **cannot be established**, and none is claimed.
     - **Not done (P2-S4):** `mint`, the operator record, grouping decisions, line bindings, `review-packet`, and `provisional-registry`.
  7. **Assessment and acceptance** (2026-09-29). Both files were re-verified against the acquisition record by byte count and SHA-256 before this assessment.
     - **The static archive is suitable as the identified P2-S3 input.** P2-S3 asks whether the unchanged P2-S1 reader handles a real Tokyo Metro feed. On `76f04623…a277e1` it reads the full feed with 0 invalid and 0 unsupported, and the archive has the audit's shape:
       - the same 11 members by name, with the same 9 selected and the same 2 fare tables unselected;
       - equal counts in every table that carries network or identity content: agency 1, stops 185, routes 9, translations 494, calendar 2, `feed_info` 1.
     - **The differences are an explained schedule revision, not an equivalence.**
       - `feed_version` moved from 20260528 to 20260921, so the provider republished the feed.
       - Every count difference is in a service table: trips +162 (+1.7%), `stop_times` +4,217 (+2.4%), `calendar_dates` −6. The 22,138-byte growth is consistent with that.
       - This explains the *kind* of change. It does not show that the two archives agree elsewhere: equal counts do not prove equal rows, and the old archive is not available to compare. The two archives are therefore not claimed equivalent, and the new one is not said to reproduce the audit.
       - Station and route content is compared in P2-S4's reviewed run, through its reconciliation report.
     - **Railway.** The size (49,842 bytes), the audit's shortened hash (`90b16083…b97f6c`), and every DEC-067 §E aggregate agree with the audit. The audit records no full hash, so exact snapshot identity is **unverified**. The new file is identified by its own full SHA-256 (item 6), and it is not said to be the audited snapshot.
     - **P2-S3 real-feed criterion: met on the newly identified inputs.**
       - Intake reports 0 invalid and 0 unsupported, and `validate-railway` reports 10 records with 0 invalid and 0 unsupported. Only DEC-067 §E counts, totals, and hashes are recorded.
       - The criterion's wording names the *retained* files. But DEC-067 §C1 accepts operator-supplied local inputs, §C2 expects fresh copies to be acquired manually, out of band, and the criterion itself allows "any other archive … recorded without claiming a match".
       - So no new decision record is needed, only the ROADMAP amendment.
       - The owner accepted item 4 on 2026-09-29, so P2-S3's real-feed validation is complete on these inputs.
     - **Accepted matrix change** (owner, 2026-09-29).
       - Rows 1 and 2 take the new inputs, `76f04623…a277e1` (1,135,582 bytes) and `90b16083…3b97f6c` (49,842 bytes), both acquired at 2026-09-29T13:56:51Z.
       - Pass conditions: a 0-invalid, 0-unsupported reader result with the §E aggregates recorded, and every difference from the audit stated, as above. Both rows pass.
       - `9a077f8f…` and the 2026-09-18 Railway snapshot remain historical audit evidence.
       - For Toei, the amendment only relabels row 3 as historical: DEC-068 §H2 already accepts row 4 in place of row 3.
     - **What P2-S4 real-data acceptance still needs** (P2-S4 stays incomplete until all of it passes):
       - *Tokyo Metro, row 5 on the new pair:*
         - `mint` provisional operator and line identities, outside the repository;
         - the reviewer's operator record;
         - `review-packet` with the Railway input;
         - reviewed grouping decisions — the audit had 32 candidates; this snapshot's count is recorded, not assumed;
         - 9 line bindings, the branch record with its accepted disagreements;
         - `provisional-registry` with both inputs as `--launch-input`.
         - The expected aggregates (185 rows → 144 identities; 9 routes and 10 Railway records → 9 `LineID`s; official-field checks 9/9) are compared, and every difference from the audit is explained in the reconciliation report and reviewed.
       - *Toei, row 4:* the same reviewed records and the provisional run on `dd575706…`, with its `calendar_dates` and size differences explained.
       - *Not required for completion, but still gating later work:* the registry-of-record decision (DEC-068 §F1) before any production identifier or committed mapping record; the ODPT Q3 reply or a publication decision (DEC-065 §A, DEC-068 §F3) before publishing any Tokyo Metro-derived mapping.
- **P2-S4 real-data acceptance record** (2026-09-30; DEC-068 §H). Everything below was produced outside the repository. Registries are provisional (§B6): no identifier in them is a production identifier. Nothing generated is committed.
  - **Provisional registry.** One registry is shared by both operators. On the owner's explicit request, `mint` added 2 provisional operator and 15 provisional line entities: an owner-only planning note intends 1 operator and 9 lines for Tokyo Metro, and 1 and 6 for Toei. No `StationID` exists. The checked decoder accepts it, all 17 identifiers are unique and in DEC-068 §A form, and it held 0 references before the runs.
  - **Operator records** (one per input). The owner approved both bindings after reviewing the operator-review worksheet, and they were verified before being written:
    - both intended operators are distinct active entities;
    - all input hashes are the accepted ones;
    - each archive's single agency matches;
    - all 10 Tokyo Metro Railway records carry the single ODPT operator value.

    Regenerated packets resolve every agency, operator value, route, and Railway record to its operator.
  - **Grouping and line records.** Tokyo Metro: 32 grouping records and 9 line bindings. Toei: 8 grouping records and 6 line bindings. Each copies its members and evidence digest exactly from the regenerated packets, and the worksheets were re-checked against those packets before writing.
    - **Approval provenance.** The owner approved every proposal after ChatGPT reviewed the supplied grouping and line-binding worksheets. No physical survey, and no inspection of evidence absent from those worksheets, is claimed.
    - **Meaning.** A station grouping establishes operator-level identity only. It creates no transfer edge, walking time, or shared-platform assumption.
    - **The Marunouchi branch.** Its Railway record names the branch, while the GTFS route names the whole line. So its `japaneseTitle` and `englishTitle` disagreements (2 accepted checks) were accepted explicitly, and both Railway records keep their own provenance under the Marunouchi `LineID`.
    - Each of the 15 `LineID`s is assigned once, from its operator's intended pool. The assignment is kept owner-only.
  - **Runs.** `provisional-registry`, chained: Tokyo Metro first, with both accepted files identified as launch inputs (static `76f04623…a277e1`, Railway `90b16083…3b97f6c`); then Toei (`dd575706…2b42d8c4`), from Tokyo Metro's output registry.

    | Run | Grouping | Lines | Registry after the run |
    |---|---|---|---|
    | Tokyo Metro | 185 rows → 144 identities; 32 proposals, all accepted; 0 held back | 9 `LineID`s; 9 routes, 10 Railway records; 2 accepted checks | revision 2 → 3; 41 active references |
    | Toei | 149 rows → 141 identities; 8 proposals, all accepted; 0 held back | 6 `LineID`s; 6 routes | revision 3 → 4; 48 active references |

    - **Final registry:** 2 operators, 15 lines, and no `StationID`.
      - 48 active references, 0 absent, 0 retired. Every key is held once, and no line reference crosses operators.
      - Tokyo Metro: its agency and ODPT operator on one operator; 9 route references; 10 each of Railway `@id`, `owl:sameAs`, and line code across 9 `LineID`s. The branch line holds 1 route and 2 Railway records.
      - Toei: its agency on the other operator, and 6 route references on 6 `LineID`s.
    - **Reconciliation:** 0 unassigned, 0 absent, 0 retired, and no conflict.
      - The 10 Railway line codes are reported as *changed*. A code on an identity already anchored by a reviewed key is a descriptive attachment made without review (DEC-068 §E3), which is also why those 10 references carry no `attachedBy`.
      - All other references were attached by a reviewed record.
    - **Official fields.** Each of the 9 Tokyo Metro routes agrees with its main Railway record on line code, both titles, and colour (9/9). The branch record agrees on code and colour, and its two title disagreements are the accepted ones.
    - **Determinism.** Three repeat runs, each supplying its previous inputs and records, gave byte-identical registries with no revision increase and zero changes:
      - Tokyo Metro against its own output;
      - Toei against its own output;
      - Tokyo Metro against the final combined registry.
  - **Toei differences from the audit's pinned archive** (row 4; `f10d03cd…`, 779,674 bytes, not available).
    - **Observed differences.** Among the audit's recorded aggregates, two differ: `calendar_dates` 39 → 51 (+12 service-exception dates) and archive size +25 bytes. The historical archive is unavailable, so these are **not claimed to be the only byte-level or row-level differences**.
    - **Equal aggregates.** Every other recorded aggregate, including every identity and line aggregate, equals the audit's: stops 149, routes 6, trips 5,600, `stop_times` 122,798, translations 404, 8 grouping candidates → 141 identities, and 6 route bindings.
    - **Explanation.** A calendar-exception difference changes service dates, not station or line identity. These first runs had no previous Toei registry state, so the reconciliation report cannot show audit differences itself: the explanation rests on the aggregates above.
    - **Basis of acceptance.** Acceptance rests on the successful reviewed grouping and binding run on the identified newer snapshot (`dd575706…`), with matching baseline counts and deterministic reruns. It does **not** establish equivalence with the historical archive.
    - **Owner review** (2026-09-30). The owner accepted the newer Toei snapshot and this difference explanation for P2-S4 acceptance, as DEC-068 §H2 requires.
  - **Criteria audit** (2026-09-30), against the P2-S4 completion criteria:

    | Criterion group | Evidence | Verdict |
    |---|---|---|
    | Minting and registry | Step 1 (reviewed; 85 app and 8 minting cases); the operator binary has no generator entry point | met |
    | Values and provenance | Steps 1–2 (scalar round-trip, invented ヶ / ケ and 〈…〉 stand-ins, full provenance) | met |
    | Operator-level grouping | Step 2 (18 grouping cases; non-waivable operator boundary; two operators' shared name stays two identities) | met |
    | Lines | Step 3 (22 line-binding cases on invented `Q` / `Qb` feeds; unbound fails; disagreements never bind on their own) | met |
    | Revisions | Step 4 (21 revision cases; every §E transition and category; conflicts fail) | met |
    | Determinism | Steps 4–5; the real repeat runs above | met |
    | Boundaries | no real record, registry, or importer output committed; no Tokyo Metro provider value committed (only DEC-067 catalog metadata, hashes, and aggregates); no distance constant; no dependency | met |
    | Suite and builds | `TSUGINOTests` 1204/1204 and Debug and Release builds on the Step 5 tree. Since then the app changed only by one visibility widening in `MappingRegistry.swift`, inside that tree, and later commits changed tool and docs only. Tool runner 129/129 on the current code | met |
    | Real data: P2-S3 first | recovery record, accepted 2026-09-29 | met |
    | Real data: Tokyo Metro | the runs above (185 → 144; 9 routes and 10 records → 9 `LineID`s; branch retained; 9/9) | met |
    | Real data: Toei | the runs above (149 → 141; groupings reviewed; 0 held back; 6 bindings); the observed differences explained, and reviewed by the owner on 2026-09-30 | met |

    **Verdict: P2-S4 is implemented and complete** (2026-09-30). Every criterion in the audit is met. The provisional registry and every run artifact stay outside the repository and hold no production identifier.
  - **Gates that stay open** after completion:
    - production identifiers and the registry of record (DEC-068 §F1): the provisional registry is not it;
    - publishing any Tokyo Metro-derived mapping (the ODPT Q3 reply or a publication decision; DEC-065 §A, DEC-068 §F3);
    - bundling canonical data in the app (ODPT item 5, P2-S8);
    - canonical stations (P2-S5) and the later Phase 2 slices (P2-S6 to P2-S8);
    - the open Step 4 contract questions: value reuse, conflict-resolution and identity-migration records.
- **P2-S5 implementation record** (2026-09-30; DEC-069; approved by the owner). Synthetic only: no real candidate, decision, assignment, or `StationID` exists, and nothing was minted.
  - **App (`Data/Mapping/`).**
    - `StationAliasRule` holds the two accepted rules as explicit comparison keys: ヶ / ケ, and a trailing 〈…〉 subtitle. No other character is folded, and there is no normalization.
    - A `StationAliasMatch` keeps both original values exactly as decoded, each with its source, so the relation is reversible. The key never replaces a value.
    - `ReviewedCrossOperatorRecord` has the outcome `same`, `distinct`, or `ambiguous`, with an evidence digest, a reason, cited alias rules (on `same` only), and evidence provenance: an evidence item, or an external reference.
    - Its set refuses a repeated review or pair, overlapping sides, and an identity in two `same` records.
    - `ReviewedStationAssignment` assigns one provisional `StationID` to one group.
  - **Tool.**
    - **Candidates.** Exact original Japanese, exact original English, and the two alias rules on Japanese values. There is one candidate per pair of operator-level identities, with every discovery reason and match kept, in a deterministic order. No distance is computed.
    - **Evidence and digest.** Each side's identifiers, codes, names with sources, routes and line titles, neighbours, station-order positions, coordinates as the decoded values, the discovery reasons, and every other candidate involving either side.
    - **Formation.** Only an accepted `same` joins two identities, one per operator. It must cite each alias rule that related the names. With differing names and no alias, it must name its evidence by provenance. It can never cite a rule that did not apply.
    - **`station-packet`** is the owner-only review export: every candidate, with its evidence, digest, and record template. Once every candidate is decided, it adds the groups and an assignment proposal from held, unused `StationID`s. It prints only counts.
    - **`station-registry`** needs every candidate decided and every group assigned.
      - It refuses a `StationID` that holds another source's references, so nothing joins operators without a reviewed `same`.
      - It attaches exact `stop_id` references by assignment review, with `stop_code` as a descriptive code. A code shared by two stations of one source is refused by name.
      - It uses the Step 4 reconciliation per source. The previous inputs are required once station references exist.
    - **`mint --kind station`** works on explicit request. P2-S4's station-grouping evidence builder is shared, and its behaviour is unchanged.
  - **Tests and builds.**
    - Focused app tests: 10 new cases (alias keys and exact scalars, reversibility, records, sets, assignments).
    - The tool runner passes **144/144**, including 15 station cases on invented two-operator feeds. They cover:
      - the four keys, deduplication, and discovery reasons;
      - exact Unicode values (a composed and a decomposed spelling are never joined);
      - alias reversibility;
      - determinism under row reordering;
      - changed evidence: a competing candidate, a new member, a coordinate, or positions;
      - the three outcomes;
      - alias-citation and basis rules;
      - conflicting, overlapping, stale, and foreign decisions;
      - an ambiguous pair as two stations with no registry relation;
      - assignment refusals;
      - rebinding;
      - a byte-identical repeat run with no revision increase;
      - the packet.
    - `TSUGINOTests` passes **1214/1214**. The Debug and clean Release builds of the app and extension succeeded on the iPhone 17 simulator, with the existing 75 Release warnings, none from `Data/Mapping`.
  - **Review.** One focused adversarial review of the frozen change found five issues, each fixed with a regression test:
    - **High:** an assignment could reuse a `StationID` that held another source's references, joining operators without a `same`.
    - **Medium:** rows sharing a `stop_code` failed the run. A code is now one reference per station, and a code shared by two stations is refused by name.
    - **Medium:** a `same` could replace a required alias citation with provenance.
    - **Low:** station-order positions were missing from the evidence and digest.
    - **Low:** the packet's assignment template compared station records unsorted.

    The fixes changed tool code only. The tool runner was rerun: 144/144.
- **P2-S5 real-data acceptance record** (2026-09-30; DEC-069 §A, §F). Everything was produced locally, outside the repository, and nothing generated is committed. The registry is provisional (DEC-068 §B6): none of its identifiers is a production identifier.
  - **Inputs** (re-verified by hash): Toei `dd575706…2b42d8c4`; Tokyo Metro `76f04623…a277e1`, with Railway `90b16083…3b97f6c`; P2-S4's approved records; the final shared P2-S4 registry (2 operators, 15 lines, 48 references). The results are compared with A4, with no equivalence claimed.
  - **Candidates.** `station-packet` gave 29 candidates, one-to-one, with no competing candidate. By key: exact Japanese 27, exact English 28, ヶ / ケ 1, 〈…〉 1. The combinations: 27 exact Japanese and English, 1 English plus ヶ / ケ, and 1 subtitle only.
  - **Decisions.** The owner approved all 29 worksheet recommendations after ChatGPT reviewed the supplied worksheet. No physical survey, and no verification beyond that evidence, is claimed. The records copy each candidate's sides and evidence digest exactly from the packet, which was checked against the worksheet first.
    - 27 `same`, among them 市ヶ谷 / 市ケ谷, citing the orthographic rule, and 押上 / 押上〈スカイツリー前〉, citing the subtitle rule.
    - 1 `distinct`: 早稲田 (audit §6.5).
    - 1 `ambiguous`: 新宿.
  - **Derived count.** The regenerated packet derived 258 groups from these outcomes, not from a seeded figure. It matched the baseline, so minting went ahead.
  - **Minting and assignment.** On the owner's explicit authorization, `mint --kind station` added exactly 258 provisional `StationID`s to a copy of the shared registry. The packet's complete assignment proposal was adopted: 258 station records, each group once, and each `StationID` once.
  - **Runs.** `station-registry`, then a repeat run against its own output, supplying the previous inputs and records.
    - The repeat gave a byte-identical registry (SHA-256 `9fda4419…8364b`), with the revision unchanged at 6, and zero new, changed, absent, or unassigned references.

    | Measure | Result | DEC-069 §A2 baseline |
    |---|---|---|
    | Input rows → operator-level identities | 149 → 141 (Toei), 185 → 144 (Tokyo Metro): 285 | 285 |
    | Canonical stations | 258 | 258 |
    | Cross-operator merged | 27 | 27 |
    | Toei-only / Tokyo Metro-only | 114 / 117 | 114 / 117 |
    | Duplicate assignments / unmapped identities | 0 / 0 | 0 / 0 |
    | 市ヶ谷 / 市ケ谷 | one station; both originals kept | one station |
    | 押上 / 押上〈スカイツリー前〉 | one station; the subtitle string kept | one station |
    | 新宿 | two stations; no reference or relation links them | two stations, ambiguous |

  - **Registry.**
    - Entities: 2 operators, 15 lines, and 258 stations. The 48 operator and line references are unchanged.
    - References: 334 `stop_id` (149 + 185), all active. Each was attached by its assignment's review, with `stops.txt` provenance on the accepted archives.
    - 334 `stop_code` references are descriptive codes.
    - The registry holds only entities and references: no relationship, link, or transfer edge exists.
  - **Historical comparisons** (DEC-069 §A3; not pass conditions).
    - Candidates: 29 here, against A4's 54. A4's 25 spatial-only candidates are not generated, by design (§B4).
    - Distinct: 1 here, against A4's 26. A4's other 25 distinct classifications were exactly those spatial-only candidates.
    - A4 resolved all 27 of its merges from name-based candidates, and this run also has 27.
    - **Totals reproduced, not equivalence.** The aggregate totals match A4's. Whether they are the same station pairs is **unverified**: A4's 285-row mapping was never recorded, and these snapshots differ from A4's (the Toei archive is newer; the Tokyo Metro static archive is newer, and the Railway file's identity is unknown). Only the three named outcomes and 早稲田 are checked pair by pair.
  - **Criteria audit** (2026-09-30):

    | Criterion | Evidence | Verdict |
    |---|---|---|
    | Inputs: the identified snapshots, compared without an equivalence claim | this record | met |
    | Candidates: the four keys, one per pair, every reason kept, deterministic | synthetic station cases; the real packet | met |
    | Review: a record for every candidate with its digest; an unreviewed candidate fails | synthetic cases; 29 of 29 decided | met |
    | `same` rules: converging evidence, citations only when used, provenance for a differently named `same`, no invented alias | synthetic cases (including the review fix); real citations for 市ヶ谷 and 押上 | met |
    | Ambiguity: two stations, no registry relation or transfer edge | a synthetic case; real 新宿 | met |
    | Aliases explicit and reversible, originals preserved | app and tool cases; real originals kept | met |
    | No distance constant | code search; no distance computed | met |
    | Station minting and attachment; deterministic output | synthetic cases; the real run and byte-identical repeat | met |
    | Suite and builds | tool runner 144/144; `TSUGINOTests` 1214/1214; Debug and clean Release on the P2-S5 tree, whose code is unchanged since | met |
    | Real-data baselines (§A2) and comparisons (§A3) | the table above | met |
    | Provisional identifiers; production minting waits for DEC-068 §F1 | this record | met |

    **Verdict: P2-S5 is implemented and complete** (2026-09-30).
  - **Gates that stay open:**
    - production identifiers and the registry of record (DEC-068 §F1);
    - publishing any Tokyo Metro-derived mapping (DEC-068 §F3);
    - app bundling (ODPT item 5, P2-S8);
    - P2-S6 to P2-S8;
    - the Step 4 contract questions;
    - the P2-S5 coverage limit: differently named stations that the two alias rules do not relate are not candidates, and spatial discovery is deferred.
- **P2-S6 implementation record** (2026-09-30; DEC-070; commit `822cca5`; approved by the owner). This implementation step used synthetic data only and did not touch the real registry. Subsequent real-data acceptance is recorded below.
  - **Tool** (offline; app code unchanged). The build now compiles the Domain `GeoCoordinate`, `StationAdjacency`, `RailwayLineTopology`, and identifier types, so validation uses the real Domain rules.
    - **Inputs.** Two identified archives and the P2-S5 registry. Every stop row and route must resolve to an active reference last reconciled with those exact inputs. The registry is read, never written.
    - **Coordinates.** Every active station is classified again on each run.
      - One row, or identical points: the exact published point, with every row as provenance.
      - Different points: a reviewed record, checked for the member set, the chosen row, its exact point, the input it was reviewed on, and the evidence digest.
      - Held-back reasons: `reviewRequired`, `selectedPointChanged`, `selectedRowAbsent`, `selectedInputChanged`, `reviewStale`, `invalidPoint`, `noMemberRows`.
      - Another point is never substituted.
      - `--previous-coordinates` carries earlier selections forward as append-only history. A changed or lost selection is appended, never overwritten, and an absent station keeps its history.
    - **Topology.**
      - Each line's trips, in `stop_sequence` order and including pass-through rows, give undirected candidates, with their support, observed directions, and alternative runs kept.
      - The possible-shortcut heuristic uses DEC-070's exact quantifiers. Triangles among the other candidates are triggers. Self-pairs need a stated treatment.
      - Each topology decision lists every alternative run it addresses. Nothing is removed automatically.
      - Held-back reasons: `noRoutes`, `reviewRequired`, `reviewStale`, `empty`, `disconnected`, `membershipMismatch`.
      - Shape checks (loop plus tail, branch) run on the built graphs of lines named by `--loop-tail-line` / `--branch-line`, with nothing seeded.
    - **Outputs.**
      - `network-packet` is the owner-only review export: every different-point station with every row's point and names, and every line's review cases with full evidence, each with an empty template.
      - `network-build` publishes `coordinates.json`, `topology.json`, `membership.json` (with DEC-057 D9 agreement per line), and an aggregate-only `report.json`, as one new directory.
      - The same inputs give byte-identical outputs.
  - **Tests and builds.**
    - The tool runner passes **167/167**, including 23 network cases. They cover:
      - coordinates: one-row and identical-point provenance; reviewed selections; changed, absent, stale, and other-input choices; invalid points; unused and duplicate records; no-row stations;
      - revisions and append-only history;
      - topology: a loop plus tail from full-loop trips, unflagged; a branch; a partial-loop edge flagged for review and never removed; pass-through rows versus an omitted row; one qualifying run of several flagging, with every run addressed; triangle triggers; decision mismatch; membership, empty, and disconnected lines; self-pairs; stale reviews; no-route lines;
      - shape pass and fail with the graph unchanged;
      - membership agreement;
      - determinism under row reordering;
      - registry reconciliation;
      - no distance code;
      - the two commands, including a byte-identical rerun with the registry untouched.
    - `TSUGINOTests` passes **1214/1214**. The Debug and clean Release builds of the app and extension succeeded on the iPhone 17 simulator, with the existing 75 Release warnings.
  - **Review.** One focused adversarial review confirmed the heuristic's quantifiers, run and triangle logic, digests, history, shape math, and determinism. It found four issues, each fixed with a regression test:
    - **Medium:** an active station without rows, or a line without routes, was omitted instead of held back, and a leftover record for it aborted the run.
    - **Medium:** a coordinate record's input hash was not checked. A record reviewed on another input now holds the station back, so each new snapshot is reviewed again.
    - **Low/medium:** a topology decision did not address each alternative run.
    - **Low:** stale records were counted as used.

    The fixes changed tool code only. The tool runner was rerun: 167/167.
- **P2-S6 real-data acceptance record** (2026-09-30; DEC-070 §A–D). All provider-bearing records, packets, worksheets, provenance, logs, and outputs remain owner-only outside the repository (directories 700, files 600). No generated provider data is committed or published. The registry and its identifiers remain provisional.
  - **Scope lock.** Finish P2-S6's coordinate review, network artifacts, repeat verification, and criteria audit on the accepted P2-S5 inputs. Only this ROADMAP changes in the repository. No code, dependencies, architecture, global selection policy, identity changes, app bundling, physical-device work, or P2-S7 work is included.
  - **Inputs and worksheet verification.** Recomputed SHA-256 values match the accepted inputs:

    | Input | SHA-256 |
    |---|---|
    | Toei static archive | `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4` |
    | Tokyo Metro static archive | `76f046236893b136f0d84b2e2ce21db67375a90e63c9e594732e1bec48a277e1` |
    | Tokyo Metro Railway snapshot, retained binding evidence | `90b16083b4acfd73d4ad4dc840f6702e57799279d05d1e6781961c8ab3b97f6c` |
    | Final P2-S5 registry, revision 6 | `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b` |
    | Saved and freshly regenerated network packet, byte-identical | `45c62951833f3cd0e466f4516e9c94035e40f6152b07cca985ca712982e01c92` |

    The final P2-S5 first-run and repeat registries are byte-identical. The saved coordinate worksheet matches all 50 packet cases: station, every member row, operator, displayed name, exact decoded point, displayed source/hash prefix, and full evidence digest. Fresh packet regeneration on the accepted archives and final registry verifies the full hashes behind those displayed prefixes. There are **50 different-point cases**, not 58: the 58 multi-row stations comprise 50 different-point and 8 identical-point stations. The packet contains **zero topology review cases**.
  - **Owner approval and fixed records.** The owner explicitly approved the convention after ChatGPT reviewed the worksheets: for a station containing both operators, select a Toei member row; within the selected operator, sort exact `stop_id` values in ascending ASCII lexicographic order and select the first; single-operator stations use the same ordering. One fixed reviewed coordinate record was written for each of the 50 cases (27 cross-operator, 7 Toei-only, 16 Tokyo Metro-only), copying the chosen row's exact decoded point, source, accepted input hash, complete member set, and evidence digest. The companion evidence retains every alternative point, published row, names, and full registry source reference, including the member hash, table, field, and provider key.
    - This is a **representative published-point convention**, with no accuracy, entrance, platform, or station-centre claim. **No physical survey** or inspection of evidence absent from the worksheets and retained inputs is claimed.
    - These are fixed reviews on the identified evidence, **not a global automatic selection policy**. DEC-070 §A7 still governs reclassification, stale/changed/absent choices, renewed review on later inputs, and append-only history. Later snapshots must not silently recompute these choices.
  - **Runs and independent checks.** `network-build` used the 50 approved records and zero topology records. Oedo and Marunouchi were identified through their approved P2-S4 line bindings, checked against the final registry's route references; their IDs were passed solely for shape validation, with no graph seeded. A second run supplied the first run's `coordinates.json` through `--previous-coordinates`.

    | Measure | Verified result |
    |---|---|
    | Selected coordinates / held-back / absent stations | **258 / 0 / 0** |
    | Selection rules | 200 single-row, 8 identical-point, 50 reviewed |
    | Exact source equality and provenance | all 258 selections equal their published source points as decoded; all 334 source rows retained; identical-point selections retain every member's provenance; all reviewed alternatives retained separately |
    | Built connected line topologies / held-back lines | **15 / 0** |
    | Bidirectional station/line membership | **15/15** agreements; independently reconstructed from GTFS trips and stop times |
    | Undirected candidates / included / excluded | **320 / 320 / 0**; output edge sets equal independently reconstructed consecutive-pair sets, including pass-through rows |
    | Possible shortcuts / triangle triggers / self-pairs | **0 / 0 / 0**; no qualifying alternative run or triangle found |
    | Unused coordinate / topology reviews | **0 / 0** |
    | Oedo loop plus tail | **PASS**: 1 cycle; degrees 1: 1, 2: 36, 3: 1 |
    | Marunouchi branch | **PASS**: 0 cycles; degrees 1: 3, 2: 24, 3: 1 |
    | Repeat and history | all four artifacts byte-identical; **0 history entries**, no duplicates |
    | Registry | unchanged SHA-256 and revision 6 throughout |

    Source-point verification reread `stops.txt` from both accepted archives and checked archive/member hashes, selected row identity, decoded values, and retained provenance. Independent graph checks verified connectedness, exact edge sets, membership in both directions, no self-pairs or triangles, and both degree/cycle shapes. No check failed and no contract was weakened.
  - **Artifact hashes** (identical in both runs where applicable):

    | Artifact | SHA-256 |
    |---|---|
    | Approved network records | `d1fe1ae21afaae05417ca432ea66b41813040b82edbf93791d35091171e537bd` |
    | Full coordinate review evidence and alternatives | `613590209b7eb714a1b76e4d9adb40ed9e26a186765e80f58128193ec7dcfeb4` |
    | Approval log | `a5e86e3d6b50d0cccabc714cb5d13b2d95ce9811b2dd3335a2cfdcd6da59bb53` |
    | `coordinates.json` | `993f27c2629be9062ea8d9e442c3a27ffcfa201b303f785a73b9dfc681949f15` |
    | `topology.json` | `dbcead1a8e38536c104a95787c8c3ee69a828bdd6d7aa10d4b5eb9bcf1303348` |
    | `membership.json` | `2c3655c8ddbb9f2131f8b1f3899ecc10a018834291fa8811f3aec88011311b1b` |
    | `report.json` | `5bbde41c449e7bc4469ecc76be8f66a73ac9f308ce07eccd1c32cd74a3f3c463` |
    | Acceptance audit | `0b71cd997547559bf99ae39d95579f83d5dd861145a9e9e5ca1c3f431f5bd05b` |

  - **Criteria audit** (DEC-070 and the accepted P2-S6 criteria):

    | Criterion | Evidence | Verdict |
    |---|---|---|
    | Exact published coordinates, all-row provenance for identical points, explicit reviewed choices for different points, no derived point or distance | existing synthetic network cases; all 258 real selections and retained source evidence | met |
    | Changed, absent, stale, other-input, invalid, no-row and automatic-to-reviewed handling; no silent replacement; append-only history | existing synthetic cases, including adversarial-review regressions; unchanged real repeat with no duplicate history | met |
    | Undirected GTFS sequence evidence, pass-through rows, exact shortcut quantifiers, multiple runs, full/partial loops, triangles, self-pairs, mandatory reviews | existing synthetic cases; 320 real candidates with support/directions/alternative runs retained and zero triggers | met |
    | Empty, disconnected and membership failure handling | existing synthetic cases; 15 real connected graphs and exact bidirectional membership | met |
    | Unseeded Oedo and Marunouchi shape checks | existing synthetic pass/fail cases; reviewed binding identification and both real shapes pass | met |
    | Determinism, registry immutability and repeat history | existing synthetic row-order/command cases; four byte-identical real artifacts and unchanged registry hash | met |
    | Required synthetic suite and builds | accepted evidence at `822cca5`: tool runner **167/167**, including 23 network cases; `TSUGINOTests` **1214/1214**; Debug and clean Release app/extension builds on iPhone 17 simulator, existing 75 Release warnings | met |
    | Local real-data acceptance and measured counts | all results above; owner-only artifacts, no held-back item or unused review | met |
    | Scope and architecture | code unchanged; outputs limited to coordinate, topology, membership and review evidence; no new policy or later-slice feature | met |

    **Verdict: P2-S6 is implemented and complete** (2026-09-30). Existing synthetic evidence was audited rather than rerun; no additional broad tests or builds were run because no code defect or code change was required. Physical-device validation is not required by this offline slice and none was performed. The drift audit found only the intended ROADMAP change in the repository; documentation remains uncommitted.
  - **Limitations and remaining gates.** These points have no verified physical meaning or accuracy; GTFS adjacency is observed sequence evidence, not physical-survey proof, and zero flags does not make the heuristic a complete physical-adjacency classifier. These results do not establish equivalence to older audit snapshots. Complete `Station` / `RailwayLine` construction and canonical names wait for P2-S7; bundling waits for P2-S8. Production identifiers and the registry of record (DEC-068 §F1), Tokyo Metro publication (§F3), and the existing licensing/contract gates remain open. Phase 2 as a whole is not complete.
- **P2-S7 design acceptance.** Owner-approved DEC-071 was committed as `b20c4cd` on 2026-09-30, with dated DEC-053/068 amendments preserving historical text and synchronized architecture references. The acceptance commit records design-only status at that point. DEC-071 remains the sole authoritative contract; `P2_S7_DESIGN_DRAFT.md` is only the dated language-evidence inventory. No push or merge was authorized.
- **P2-S7 synthetic implementation record** (2026-09-30; DEC-071; synthetic implementation implemented and reviewed). **P2-S7 is not complete: separate real-data review and acceptance remain outstanding.**
  - **Scope and boundaries.** Reviewed three-language names and explicit aliases; full source/alternative evidence and append-only choice, observation and validation history; the limited Railway title sidecar; deterministic exact lookup; complete named Domain construction; offline packet/template/build commands. All new fixtures, labels, identifiers, assertions and authorizations are invented. The synthetic implementation turn did not read or modify real evidence, author real translations or review records, mint identifiers, change a real registry, select a delivery format, add UI/fuzzy search, bundle data or start P2-S8.
  - **Ownership and exactness.** `LocalizedRailName` implements scalar-exact equality/hashing while retaining its String fields and Codable shape. Domain's `StationSearching` exposes local full-name/alias results with station/line/operator context; Data's `ExactStationIndex` uses `ExactValue`, sorts keys/results, returns all distinct matches, and validates bidirectional membership. Domain imports no Data type. Entity identity remains ID-only.
  - **Evidence validity.** The tool verifies current identified sources/member hashes and active reconciled registry references, then recomputes complete candidate/member/binding evidence. Only unchanged relevant evidence carries the same review forward. New provenance and validation predecessor links append without replacing original choices or failed sightings. Selected changes, missing historical sources, new members/alternatives, stale references, unresolved bindings and unverifiable rationale fail or hold back; superseded reviews cannot be reactivated and aliases cannot disappear silently. Registry original-name history is retained beside all current alternatives; agency translations and Railway title sightings remain editorial evidence, not registry mutations.
  - **Limited title bindings.** Full source references target existing stations through reviewed document crosswalks or two independently validated direct anchors. Every occurrence and branch scope is retained, with competing targets, current members, attachment-review references and network evidence. Structural support must uniquely match on each validated scoped line; names, URI suffixes and line membership alone never resolve identity. No provider namespace, general resolver, minting, merging or migration was added.
  - **Offline workflow and determinism.** `name-packet` exports review evidence and optionally computes templates from explicit selections; templates are not approvals. `name-build` reuses P2-S6 validation and publishes complete Operator/Station/RailwayLine values only with all required names and network inputs valid and no unresolved/unused reviews. Held-back builds preserve diagnostics/history with empty named payload/index; malformed inputs fail before publication. Five artifacts (`packet.json`, `report.json`, `history.json`, `names.json`, `index.json`) are compared byte-for-byte with `--previous`; the synthetic command test also verifies no duplicate choices/validations, an unchanged registry, repository-output rejection and private file modes. Output directories are new/external `0700`, files `0600`. DEC-070's coordinate contract is unchanged.
  - **Focused adversarial review.** One bounded pass covered identity boundaries, scalar equality/hash/index/query/serialization, evidence changes, append-only history, binding conflicts/ambiguity and deterministic repeats. It found that structural neighbours could be combined across line scopes, and that a subtitle comparison could authorize an unpublished replacement subtitle. Fixes require neighbour support on each validated line and limit subtitle derivation to removal of the published subtitle. Regression cases cover both, changed members behind an unchanged spelling and superseded title-review reuse. No repeated clean-review rounds were run.
  - **Verification — passed.** Focused tool checks: **25/25**. Focused app search tests: **4/4**. On stable source, the full tool suite ran once: **192/192**, zero failures, synthetic temporary root removed. The full app suite ran once on the explicitly selected **iPhone 17 / iOS 26.5 Simulator**: **585 test functions / 1,218 executed cases**, zero failures or skips (Xcode result summary). Explicit **Debug build** and **clean Release build** each ran once and passed, including validation of the embedded `TSUGINOLiveActivity.appex`. The optimized offline tool build also passed. Existing Swift-6-mode actor-isolation, asset-catalog and AppIntents-metadata warnings remain; no new runtime warnings or failing gates. No physical device was accessed. Logs are local at `/private/tmp/tsugino-p2s7-{focused,tool-suite,tool-build,app-focused,app-suite,debug-build,release-build}.log`; the app result is `/private/tmp/tsugino-p2s7-dd/Logs/Test/Test-TSUGINO-2026.09.30_16-39-18-+0900.xcresult`.
  - **Diff, data and Git audit.** Diff whitespace checks passed. A changed-file/public-data boundary scan found no real input/archive/review artifacts, credentials or real evidence paths; the only new artifacts are Swift source/tests, with invented fixtures. No Data import enters Domain, no dependency/project-file changes were needed, and no unrelated files changed. Branch `phase/02-static-data`, HEAD `b20c4cd9344dd21423f61420c0eaba96972a9fed`; upstream `origin/phase/02-static-data` remains at `ba0e717` (one local design commit ahead, zero behind). The verified implementation handoff contained **26 files**, comprising Domain/Data name/search types, tool commands/publication option, synthetic tests/build scripts, tool README and three documentation updates. Nothing was pushed or merged.
  - **Finalization verification (2026-09-30).** Owner authorized committing the reviewed synthetic implementation, with real acceptance still outstanding. Reconfirmed branch/HEAD/upstream and the exact 26-file handoff; no implementation code changed. Existing full-suite and app-build evidence above was retained. Because no source-hash manifest was recorded at those runs, performed bounded compiler reproductions: the current optimized production tool is byte-identical to the saved verified binary (SHA-256 `92ea362120dc2b19ced0356504635c64c444414dbe0a40f8a522fd9c987cf351`). The unoptimized test-runner binary was not byte-identical, so only the 25 focused name checks were rerun against its current-source reproduction: 25 passed. No full suite, Xcode build or new broad review was run. Captured a content manifest for 158 Swift/script inputs (SHA-256 `766fb0792b3fc7b27e2f25023392ccb471820a28c836f7726bfd5463a1f7d70a`); compiler proof and source/test records are retained locally under `/private/tmp/p2s7-finalize-proof/`. Final staged-path, whitespace and public-data checks passed. The implementation is **implemented and reviewed**, not real-data complete. The owner's next authorization is read-only real-evidence inspection and review export only; it approves no name, binding, alias, author/reviewer or translation.
  - **Operational findings.** Initial tool compilation needed a writable temporary Swift/Clang module cache; sandboxed Simulator discovery required authorized CoreSimulator access. One optimized tool build was interrupted because source files changed while it was compiling; it was restarted after edits stabilized. These are reported execution issues, not passing gates. A command regression initially expected `0600` files from the shared publisher's existing private-directory/`0644` behavior; this slice now explicitly requests `0600` files without changing other commands' default.
  - **Limitations and next real review.** JSON artifacts are offline evidence, not a shipping persistence decision. Supported rationale checks are finite: published/preferred source, explicit author/lineage approval, historical alias, reviewed document crosswalk and two direct structural anchors. A document hash proves bytes; its authoritative meaning remains the named reviewer's assertion. Unsupported evidence dependencies require further review, not automatic inference. Before any real selections, separately approve real scope, sources, Korean authorship/terminology and a Korean-competent reviewer; resolve Q4 where new Metro-derived translations are required. Then review title bindings/names/aliases against the final reconciled registry and strict P2-S6 inputs, supply both reviewed shape IDs, prove full 258-station/15-line/2-operator coverage and both distinct shared-name results, zero unresolved/unused reviews, retained originals, unchanged identities/network artifacts, and byte-identical repeat. Q3, production-registry and P2-S8/ODPT bundling gates remain unchanged. No ODPT reply or translation/publication permission is assumed.


- **P2-S7 bounded Station-code evidence follow-up** (2026-09-30; owner-authorized implementation under DEC-071; original pre-commit record).
  - **Scope.** Distinct credentialed source `DS-03/tokyometro-station` under existing audit row DS-03, with catalog dataset/resource metadata and no source URL; excluded from GTFS intake and Railway source selection. The public ODPT specification v4.16 (2026-09-03), §3.2.5/§3.3.5 and Railway StationOrder §3.3.3, documents the possible identifier/code bridge. Station codes are optional; documented schema capability is not verified payload correspondence. Zero verified real bindings is bounded evidence, not proof of impossibility.
  - **Implementation.** Optional identified Station input in the existing offline name manifest; external-path/byte-hash checks, bounded strict JSON decoding; exact full reference, operator/record scope, code and active GTFS-member join to existing StationIDs. Typed editorial proof preserves source/hash/row/date, exact fields, competitors and GTFS/binding provenance. Explicit `stationCode` reviews are separate from support discovery. Missing/conflicting/ambiguous support holds; no names, URI-suffix inference, registry changes, automatic approval or structural-inference expansion.
  - **Inventory correction and remaining limitation.** Packet `titleSupport` and report `bindingSupportCounts` now compute unevaluated, supported-but-unreviewed, supported-and-reviewed, missing, ambiguous and conflicting cases. These fields replace the prior export helper's hard-coded zero-positive-support assessment for future inventories; existing private packets/worksheets are not rewritten. The structural validator's narrower two-immediate-crosswalk-anchor basis remains a separate known limitation; no general graph proof or new rule engine is added.
  - **Verification.** First focused tool run: 31/31 passed. Stable full tool suite: 198/198 passed; synthetic temporary root removed. Affected app model tests: 3/3 passed on the established iPhone 17 / iOS 26.5 Simulator, including necessary Debug app compilation. No full app suite or clean Release rebuild was repeated. The initial compiler attempt was blocked by sandbox module-cache permissions; the actual runs used a writable temporary cache. Existing actor-isolation/AppIntents warnings remain; no warning was attributed to the added evidence model/tests. No physical device was accessed.
  - **Manual acquisition preparation.** A standalone script and offline verifier were prepared in durable owner-only storage outside the repository. Syntax verification and 10 invented-response tests passed with sockets blocked: one filtered GET construction, no redirects, status/content rejection, size/time/truncation limits, malformed/duplicate JSON, credential-echo rejection, exclusive private publication, failed-write cleanup, safe error output, and refusal of hidden-prompt fallback to echo. Acquisition script SHA-256 `3e2e455dadc587afc995fa9c90e52ffdd9aa009a45746ae571efc1a069a09240`. The owner must enter the developer token only in their terminal; no token was accessed and no authenticated request was made.
  - **Changed subsystems.** Data/Mapping proof and title-review model; tool source metadata, Station reader/assessment, name input/packet/report, title validation/history; focused tool/app tests; tool README and architecture/roadmap records. No Domain, UI, app client, identity namespace, real input or accepted registry/network artifact changed. Whitespace and changed-file public-data boundary checks passed; only public source metadata and invented fixtures are in the repository.
  - **Status and next step.** Branch remains `phase/02-static-data` at `0a32d66`, two commits ahead of its existing upstream; implementation is uncommitted. Owner-run acquisition is followed by hash/schema/scope/uniqueness validation and a new owner-only candidate inventory. Any binding or name selection requires separate review. No translation, author/reviewer appointment, minting, publication, commit, push, merge or P2-S8 work occurred. Q3/Q4 and production-registry/bundling gates remain unchanged. **P2-S7 real acceptance is outstanding.**


- **P2-S7 bounded history carry-forward repair** (2026-09-30; owner-authorized; original pre-commit record).
  - **Cause and scope.** The offline history writer emitted 33,954,513-byte and 36,398,648-byte provisional v1 histories, while `RailNameCommand.read` delegated to `ProvisionalRegistryCommand.readFile` with a 16,777,216-byte cap. Even the first file's compact JSON was 17,564,816 bytes. Its 186 title evidence bundles were each embedded three times (choice, validation, observation); the choices/history entries themselves were not duplicates. Later authored-name evidence also repeats across those record types. Scope is the offline envelope, compatibility reader, focused tests and documentation, not app models, identity, translation policy or P2-S8 storage selection.
  - **Fix and limits.** Tool-only v2 history stores identical immutable full evidence once by digest and references it from ordered logical v1 histories. Exact originals, alternatives, choice/validation IDs, first sightings, evidence and provenance are retained. Legacy v1 input is bounded at 64 MiB for migration; new stored files remain bounded at 16 MiB, with a conservative 64 MiB expansion budget, 100,000 references and depth 64. Both reader and writer enforce the limits; unknown/lossy schema conversions, corrupt/dangling/unused evidence and excessive size fail closed. Existing history/dependency validation remains authoritative. The compatibility conversion writes only new output directories; it never rewrites the original history. Other input limits stay unchanged.
  - **Verification.** Six focused checks passed, including the command's byte-identical five-artifact repeat. The full tool suite passed **203/203** with synthetic temporary files removed. One subsequent focused recompile/check passed after correcting only the runner's category-count summary (36 name tests); implementation and test behavior were unchanged. Regressions cover v1/v2 lossless conversion, writer output readable by its reader, retained history larger than 16 MiB, scalar-distinct values, all prior records, deterministic repeats without duplicate history, unknown/duplicate fields, corrupt/missing/unused references, nesting, stored-file and expansion bounds. The optimized offline CLI built successfully. No app model/integration changed in this repair, so no app suite, app/extension build or device check was repeated. Source hashes identify tested code; whitespace and changed-file public-data boundary scans passed.
  - **Real continuation and equivalence.** New owner-only outputs validate **120** unchanged approved Korean names (114 stations, 6 lines) and **186** editorial bindings; zero held bindings or unused records. Both former histories are retained in full: the original history is an exact prefix and every entry from the isolated partial-name validation is present. Current totals are **306 choices, 306 validations, 1,131 observations**, with no duplicates. All **five artifacts are byte-identical** on the `--previous` repeat. The current packet, incomplete named output and empty index also remain byte-identical to the earlier isolated validation. New v2 history is **8,745,312 bytes** (expanded compact logical JSON: **19,328,165 bytes**; conservative reference-expansion budget used: **27,723,272 bytes**). History SHA-256: `a5b39c36b7f3a9e16778982ac29ae39bc21cb62623b926ef7f5c10ee3ca8c5f1`. All **176 pre-existing evidence artifacts** remain byte-unchanged; 131 recorded input/evidence hashes were rechecked. Registry SHA-256 remains `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`; accepted network artifacts are unchanged. Detailed retention comparisons, test/source fingerprints, both runs and a review-status worksheet remain owner-only outside the repository.
  - **Remaining review and limits.** Each name-build intentionally exits 1 because **705 required language slots remain unapproved**, including 5 conflicting slots, 153 existing Metro Korean candidate slots and 2 operator Korean names. Six alias proposals remain unapproved. No additional approval, translation, acquisition, identity change or independent physical verification is claimed. The existing generator/reviewer/owner attribution correction and all source/reading/approval provenance are preserved unchanged. Q3/publication, Q4-dependent authoring, production-registry and P2-S8 gates remain in force. Code remains uncommitted on `phase/02-static-data` at `0a32d66` (two ahead of upstream); no commit, push or merge. **P2-S7 remains incomplete.**


- **P2-S7 Station/history finalization** (2026-09-30). The owner authorized committing the bounded Station-evidence and history-v2 implementation, tests and documentation after verification. Pre-commit baseline: `phase/02-static-data` at `0a32d66`, two commits ahead of upstream, with exactly 16 intended modified/untracked files. Inspection confirmed exact scoped Station-code joins, support separate from approval, lossless typed v1 conversion, immutable evidence sharing, preserved source/provenance and bounded writer/reader compatibility. All 80 saved tool-source/test fingerprints and the CLI binary hash match; the affected app files match saved implementation fingerprints and the existing 3/3 Simulator-test log confirms success. Existing 203/203 tool tests, focused checks, CLI build, retention audit and all five byte-identical real repeat artifacts are reused. No code change or verification gap required new tests/builds. Input and owner-only package hashes, staged paths, whitespace and public-data boundary are checked for this commit; no real artifact enters Git. Earlier uncommitted-status paragraphs above describe their original runs, not this finalization.
  - **Editorial handoff.** Remaining review is 545 single-valued Japanese/English language slots, 5 conflicting slots across 3 entities, 144 station and 9 line provider-Korean slots, 2 operator-Korean slots (including retained published alternatives), and 6 explicit alias proposals. A new self-contained owner-only worksheet is authorized; every recommendation remains unapproved and is specific to its evidence, with no source-order or coordinate-convention default. The 120 approved Toei Korean names and 186 bindings remain unchanged. Operator web candidates remain separate from accepted-input coverage until their source/evidence and editorial requirements are met. No new translations, acquisition, identity changes, publication or P2-S8 work; Q3/Q4 and production-registry gates remain. **P2-S7 is implemented and partially reviewed, but not complete.** No push or merge is authorized.

- **P2-S7 owner editorial approvals and real validation** (2026-09-30). **P2-S7 remains incomplete.** Baseline `phase/02-static-data` at `5d4a29c62d0346c3e1258d10cd892716e24b2a3a`, clean, three commits ahead and zero behind `origin/phase/02-static-data`. Scope: owner-only editorial records, official-source evidence capture, offline validation/history repeat and this ROADMAP; no implementation change or broad tests/builds.
  - **Approval provenance and evidence match.** Owner approved the reported recommendations after conversational review; no physical inspection or independent verification of every spelling is claimed. The saved worksheet SHA-256 remains `6348889d8bac0078fc7394ad2f3a24d17dc2b9957e6e2728cca71f3609f3e0a2`. Fresh extraction equals all 825 reviewed name-evidence objects and all 186 title-evidence objects. The 545 single-valued Japanese/English slots, five conflict selections, 148 unchanged provider-Korean candidates and six explicit Japanese aliases were recorded with exact values, all competing originals, scope, reason and digests. A matching source key cites evidence for an owner-selected value; ID/source order does not select a canonical value and no coordinate convention is applied.
  - **Actual coverage.** **818/825 canonical slots validate:** 275 Japanese, 275 English and 268 Korean; station slots 769/774, line slots 45/45, operator slots 4/6. All six explicit aliases validate through scalar-exact evidence/rule checks. All 186 approved title bindings validate with zero missing, ambiguous, conflicting or held bindings. Existing 120 Toei Korean approvals, authorship corrections and all binding records remain unchanged. There are zero unused reviews, authored records or crosswalks.
  - **Seven held owner-approved intents, not rejected editorial choices.** Five exact published Korean alternatives and two operator names are preserved as approved intents outside the repository, but not counted as validated canonical records. The existing catalog has no published-web name input path, and `RailNameRecords.validate` explicitly rejects `AuthoredRailName.method == providerSupplied`. Relabelling published text as human/machine-authored translation would misstate provenance. This is an implementation/workflow limitation, not a new translation-policy requirement or proof that sources are unavailable. Public source capture retained one raw official UTF-8 HTML response with the exact operator text; direct Tokyo Metro downloads failed (HTTP 403 confirmed for the route page), while separately retained official web-tool extracts corroborate the other six exact values. Extracted text is not claimed to be untouched HTTP bytes or a machine-validated source-to-entity binding. No value was substituted or normalized.
  - **Network, Domain and search verdict.** Reused P2-S6 validation reports `networkComplete: true`, including the required shapes and reviewed coordinates. The complete-name gate correctly withholds the entire named Domain dataset and exact-search index: **0 constructed operators/lines/stations**, empty index. The two distinct Shinjuku identities and their member/line context remain in the approved evidence; a passing real local-search API result, complete Domain construction, full bidirectional named membership and every required real query are **not claimed** while seven slots remain held. Existing synthetic scalar-exact search evidence is unchanged, not rerun.
  - **History and repeat.** Initial build and `--previous` repeat each intentionally exit 1 for the same seven held slots. All five output artifacts are byte-identical; every prior logical choice, validation and observation remains an unchanged prefix, with no duplicate entries. All 206 pre-existing owner-only artifacts and 131 previously recorded input/evidence hashes were rechecked unchanged, including the final registry and accepted network evidence. Registry SHA-256 remains `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`. Output directories are owner-only `0700`, files `0600`.
  - **Repeat artifact SHA-256:** `history.json` = `713b53daccc203a6572acc666f2e22af3d5692c67fbd0ecd69d23ad4c94e8229`; `index.json` = `2ba33ca0557f1bb5b7ba88d67f9d0093c7185a36ec51fe2b7bd9372d3e001d6d`; `names.json` = `11ca186c598b43a360ef626131989eef80e111cb3e9a7b5aa15816fea3c72552`; `packet.json` = `57eccb5b8ca4d3693ef300ef90b00dc8aefc5040563ac8cf31f726d87ca7baaf`; `report.json` = `508625c7e4aee290efcd72817e5a94417ad033fccc668c41c8f2c82826d52b91`.
  - **Remaining acceptance work and gates.** Add the smallest supported published-source name evidence route: exact captured value and locator, explicit existing-target/lineage support, source identity/hash/provenance, bounded validation, and focused missing/mismatch/history regressions. Then consume the seven existing owner approvals without requesting new editorial decisions, rerun the real workflow and prove Domain/search/membership and repeat criteria. No new translation, identifier, registry mutation, publication, commit, push, merge or P2-S8 work occurred. Q3/publication, Q4-dependent translation, production-registry and P2-S8 gates remain unchanged. No criterion was weakened to claim completion.

- **P2-S7 bounded published-source import and local real acceptance — COMPLETE** (2026-09-30; DEC-071 §A–E). Earlier incomplete records above describe their original runs and are retained as history. Baseline: `phase/02-static-data` at `5d4a29c62d0346c3e1258d10cd892716e24b2a3a`, three ahead/zero behind the tracked upstream, with only the existing ROADMAP edit. That edit is preserved. This turn changes the bounded Data/tool evidence path, its synthetic regressions and documentation; implementation remains uncommitted.
  - **Contract and scope.** DEC-071 already permits identified published-name evidence; no policy amendment or new decision was required. `PublishedRailName` schema 1 and optional candidate/evidence fields keep published text separate from authored translations and preserve old logical encodings/digests. `providerSupplied` authored records remain rejected. Exact approved text, language, existing target, source URL, capture time/kind, byte locator/context, artifact hash, non-name support, reason and approval reference are retained. Raw HTML and web-tool extracts are distinguished explicitly: hashes identify retained artifacts, not remote-page authenticity; extracts are not original response bytes. The importer checks actual captured text, active scoped station-code/agency correspondence or an explicit captured link chain. It does not infer identity from a name or URI suffix, mint identifiers, change title bindings or invent a source preference.
  - **Evidence, history and bounds.** All seven already-approved selections validate: six use identified web-tool extracts and one uses retained raw HTML. Bounded supplemental public extracts supplied explicit code/link support; no authenticated acquisition or new translation occurred. Existing provider originals, alternatives, approval/authorship provenance and all earlier records remain unchanged. Failed imports hold the affected language and retain the attempted evidence. Same-value carry-forward reruns evidence checks and includes surrounding operator wording/supporting station-page title as semantic dependencies; changed statements require review. Reader limits remain 16 MiB per document, with 64 MiB total documents, 1,024 records/documents and 16 KiB contexts. History envelope v2 retains its existing stored/expanded bounds and lossless compatibility; no P2-S8 format decision was made.
  - **Verification.** Final affected checks: **33/33**, including eight new publication cases; final stable full tool suite: **211/211**, zero failures, temporary root removed. The optimized CLI build passes. Shared evidence/name compatibility checks pass on the explicitly selected iPhone Simulator: **16 tests in two suites**; no changed-file warnings. App source fingerprints remained unchanged after those checks, so no app rerun was needed. A pre-final 210-test pass preceded the concrete context-dependency finding; the fix has a regression, affected checks and the final full tool pass. The superseded pre-fix packet attempt was stopped without accepting its output. No broad app suite, Debug/clean Release gate repeat or physical-device operation occurred. Prior synthetic full-app/build evidence above remains applicable to unchanged behavior.
  - **Approval provenance.** The owner had already approved the seven exact values after conversational review; this import records those existing approvals without asking again or authoring replacements. All prior **818 canonical choices**, **six explicit aliases**, **120 Toei authored Korean records** (including their attribution correction) and **186 title bindings** are retained unchanged. No physical inspection, physical survey or independent verification of every spelling is claimed. The coordinate convention remains fixed reviewed published representative points under DEC-070, with no accuracy, entrance/platform or station-centre claim.
  - **Actual result.** **825/825 canonical slots** validate: **275 Japanese, 275 English, 275 Korean**, covering **258 stations, 15 lines and two operators**. All **six aliases** and **186 bindings** validate. Required held slots, unresolved bindings, unused reviews/authored records/crosswalks: **zero**. Complete Domain construction succeeds using the accepted coordinate/topology/membership evidence. All **258** selected points equal their published source points; all **15** line graphs and bidirectional membership exactly match the accepted network artifacts, with both previously accepted shape checks retained and revalidated by the network workflow.
  - **Real search.** The provider-neutral local API passes **774 canonical station-name queries**, **6 alias queries** and **6192 exact-key/probe checks** (including whitespace, case and Unicode composition variants). Every distinct result retains operator/line context. Both distinct 新宿 stations remain separately returned; the required explicit Japanese spelling/subtitle aliases work. Unselected provider alternatives are retained as evidence and are not silently added as search aliases.
  - **Repeat and retention.** Both real builds exit successfully; the second consumes the first history. **All five artifacts are byte-identical**, with no lost or duplicate choices, sightings or validations. Name history contains **831 choices**, **831 validations** and **952 observations**; title history remains **186/186/186**. Stored history is **9,768,856 bytes**, within the unchanged cap. All **240 pre-existing evidence files** are byte-unchanged, including the accepted registry, network artifacts, Station snapshot and previous reviews. Registry SHA-256 remains `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`. Real inputs, logs, records and outputs remain owner-only outside Git.

    | Acceptance criterion | Evidence and verdict |
    |---|---|
    | Scalar-exact names/aliases/query equality, hashing, ordering and serialization | accepted synthetic cases, publication Unicode regressions, focused app checks and real API probes — met |
    | Full reviewed baseline, explicit aliases, no unresolved or unused required review | 825/825 canonical slots, six aliases, 186 bindings; zero holds/unused records — met |
    | Source/target validity, alternatives, authored/published distinction and change handling | scoped capture checks; missing/mismatch/conflict/context-change regressions; unchanged original approvals — met |
    | Complete Domain values, exact published coordinates and bidirectional membership | 258 stations, 15 connected lines, two operators; accepted network equality and shape gates — met |
    | All names/aliases searchable; same-name identities distinct | real local API checks and two distinct 新宿 results with different context — met |
    | Append-only originals/choices/provenance and deterministic history repeat | old history prefixes/evidence pool retained; five identical artifacts; unchanged registry/network evidence — met |
    | Scope, architecture, verification and public-data boundary | Data/tool-only evidence path; provider-neutral Domain unchanged; synthetic/focused checks pass; no real artifact enters repository — met |

    | Owner-only artifact | SHA-256 |
    |---|---|
    | `history.json` | `395b4394759c7ca5c9b3069482406e14754fc08cdf73db5adbc68df0761defe9` |
    | `index.json` | `f9512ea38506ed550c8cb0da2681d737ec6785c8320a118a517ce4f98211f6dc` |
    | `names.json` | `8a27cce6872006ff50b2d06799c5cd22e2c7c598258ae2795c26eb21c4e749c5` |
    | `packet.json` | `4280176cceb24894dba7e80166ec562048b77e43bc2a063373bee0f66b6f2798` |
    | `report.json` | `89908baa427e396378296c330645d07523d6310979bce8f836ee2011cbf8e9e3` |
    | Approved names/aliases records | `70d0a166bac1a4c71d33693221238f35503a086dbc21b30e57a5506efddedf94` |
    | Acceptance audit | `118bc2934b8ad0d77b3ae56b91ce6b4d61ad2e5f0ad6e06d2295dbc42631c61a` |
    | Final verification record | `7f140befbed6b101a1d2e2c2e31542f2ce2905d2eb68d45c44a39196c9a10ee8` |

  - **Verdict and limits.** **P2-S7 is complete for the accepted local provisional real-data scope.** This is not Phase 2 completion, a production-registry promotion, permission to publish/bundle data, or independent proof of spelling/geographic accuracy. Q3/publication, Q4 for new Metro-derived translations, DEC-068 production-registry and P2-S8 gates remain unchanged. No new translation, credential access, identifier creation, delivery/UI/persistence work, commit, push or merge occurred. The working tree contains only the intended code/tests/docs; whitespace/data-boundary and drift checks pass. No remaining P2-S7 acceptance blocker was found.


- **P2-S7 commit finalization** (2026-09-30). The owner authorized committing the published-source importer, synthetic regressions and local provisional acceptance record, followed by a normal push of `phase/02-static-data`; no merge or P2-S8 work is authorized. Pre-commit HEAD is `5d4a29c`, three ahead/zero behind the tracked upstream, with exactly twelve intended code/test/documentation paths and nothing staged. All 64 saved source/test fingerprints, the CLI binary and saved acceptance-package hashes match the final verified version. The 33 affected checks, 211 tool tests, 16 focused Simulator tests, CLI build, 825/825 names, six aliases, 186 bindings, complete Domain/search validation, retained history and five byte-identical repeat artifacts are reused; no code change or verification gap required rerunning tests/builds. Earlier uncommitted-status statements describe their original runs. Only intended source, invented fixtures and documentation enter this commit; real artifacts remain unchanged and outside Git. Q3/Q4, production-registry and P2-S8 gates remain unchanged.


**P2-S8 synthetic storage-measurement prototype** (2026-09-30; bounded owner authorization, not slice completion). Starting HEAD `31732d7` on `phase/02-static-data` matched both tracked and live upstream; the working tree was clean. The isolated `Tools/StorageMeasurement/` macOS CLI compares indexed compact-file and system SQLite representations, using unchanged Domain types and the existing exact-search oracle. No final `RailwayDataRepository`, app wiring, real artifacts, production identities, translation or delivery is introduced. No new package dependency is added.

- **Method and observations:** [measurement report](../Tools/StorageMeasurement/RESULTS.md), [predeclared method](../Tools/StorageMeasurement/README.md), and [raw aggregate samples/fingerprints](../Tools/StorageMeasurement/results.json). Identical invented fixtures at 258 stations/15 lines/two operators/six aliases and 25,800/1,500/200/600; five fresh-process repetitions per backend/size, alternating order, optimized Swift macOS CLI. Cold means process-cold with uncontrolled OS caches, not a physical-iPhone or app launch. Artifact size, preparation, open/first query, warm search, full decode/load, peak RSS, ordinary-access counters and close/reopen are separately recorded, including ranges. Preparation outliers are retained and their cause is not claimed.
- **Results:** SQLite open-to-first-query medians 3.08/95.96 ms versus compact 9.12/660.44 ms; scale ordinary peak RSS 26.45 versus 56.56 MiB. Compact files are smaller and warm lookup is faster. Both show zero full-fixture parses during ordinary repeated access. These observations support **Proposed DEC-072**, not an accepted storage choice or iPhone performance claim. The provisional name-history v2 envelope does not choose the app format.
- **Focused verification:** optimized standalone prototype build; 20/20 artifact/oracle checks comprising 787,920 exact queries plus complete Domain payload/context and reopen comparisons; independent Unicode composition, same-name identity and explicit-alias assertions; stable ordering and bounded-cache counters; eight unsupported-version/framing/size checks, with clean error exits confirmed. Saved source/binary fingerprints match measured code. No broad suite, app/extension build, UI or device test ran; none is claimed.
- **Remaining:** accept or revise the measured storage proposal before implementing the final backend, repository contract, version metadata and supported migration/retirement checks. The narrow compatibility plan is in DEC-072; no merge/split or successor-following policy is invented. Registry-of-record/production-ID, Q3/publication, Q4 translation and item 5/bundling gates are unchanged. **P2-S8 remains incomplete.** Prototype code, invented-data measurements and documentation are left uncommitted; real evidence was neither read nor modified.

**P2-S8 bounded synthetic SQLite repository** (2026-09-30; DEC-072 accepted by the owner for storage design). Domain now owns the async `RailwayDataRepository` boundary; Data owns its read-only system-SQLite actor backend, canonical storage DTOs and validation. The offline deterministic builder and invented checks live in `Tools/RailwayStorage/`; no app importer, data installation, UI or new package dependency is introduced. The original measurement prototype and all its saved source fingerprints remain unchanged. Its historical Proposed wording is evidence from the measurement stage; DEC-072 is now Accepted.

- **Artifact/compatibility:** canonical stations/lines/operators, explicit aliases, persisted scalar-exact search, complete canonical identity/retirement state, separate schema/data/registry metadata, input/content hashes and chained revision metadata. Editorial originals, alternatives, captures and full choice/sighting histories remain outside runtime storage. Open performs one complete integrity/semantic/index validation, then ordinary access uses SQLite without re-parsing the dataset or rebuilding the index. Those semantics are more conservative than the prototype, so its startup measurements are not claimed for the repository. Read-only failures, unsupported versions and incompatible pinned revisions do not mutate artifacts. The [implementation notes](../Tools/RailwayStorage/README.md) document bounds and input-tracing limits.
- **Verification:** focused synthetic storage checks pass; full app suite **590/590**, zero failures/skips, with Debug app/extension build on iPhone 17 Simulator (iOS 26.5). A final diagnostic-only correction was covered by the focused storage checks and **2/2** repository app integration tests; the broad suite was not repeated. **Clean Release app/extension build passed** on the same Simulator. No physical device was touched. Existing unrelated Swift 6 warnings remain; no new storage-path diagnostic was found.
- **Determinism/history:** fresh-process, reordered-input and previous-history outputs compare byte-for-byte. Fixed invented artifact: 32,768 bytes, SHA-256 `7b81c41b6e4ccb960c8011297332c91b36fff9e48f508887752febe1e4938bc0`, SQLite 3.51.0. Two-revision repeats are also identical, with no duplicate history. Identity/retirement metadata remains unchanged across supported descriptive-data revisions. Cross-engine byte equality is not assumed.
- **Focused review:** one in-session adversarial review found and fixed unbound earlier revision metadata (digest chain plus tamper regression), missing reader enforcement of same-registry-revision/hash consistency, and a fixed rather than measured validation-pass diagnostic. Relevant checks were rerun; no repeated broad review or unrelated cleanup occurred. [Verification record and fingerprints](../Tools/RailwayStorage/VERIFICATION.md).
- **Verdict:** the authorized synthetic repository is implemented and verified; **P2-S8 is not complete**. DEC-068 requires reviewed canonical identity transitions, but their input contract remains unresolved. The builder rejects entity-state changes rather than inventing merge/split or successor-following behavior. Existing-retirement preservation is proven; execution of a new retirement migration is not. Unsupported schema handling is rejection without mutation, not an invented conversion of a nonexistent predecessor. No real repository acceptance/production delivery is claimed. Registry-of-record/production-ID, Q3/publication, Q4 translation and ODPT item 5/bundling gates remain unchanged. All implementation/docs are uncommitted; real evidence was neither read nor changed.

**P2-S8 canonical-transition design draft** (2026-10-01; documentation only). Git was verified at `31732d7` on `phase/02-static-data`, synchronized with tracked and live upstream; all uncommitted SQLite and measurement work is preserved. **DEC-073 is Proposed, not accepted.** It is the sole proposed authority for the remaining reviewed canonical identity-transition contract and its synthetic application/reopen/repeat acceptance plan. It distinguishes provider reconciliation, canonical identity changes and storage migration; identifies two prospective DEC-068 amendments: reviewed current provider-binding version transitions with immutable predecessor/attachment authority, and pure retirement with zero successors, distinguished from replacement, merge and split. The refinement specifies one current version per key/revision, explicit reference dispositions, bounded version conversion, and focused application/reopen/repeat and ordinary-reconciliation rejection cases. Provider-value reuse stays separate. No accepted identity, review or storage rule is amended by this draft. See DEC-073 rather than duplicating its schema here. No code, test/build, real-artifact change, minting, commit, push or merge occurred. The existing fail-closed implementation and P2-S8 migration criterion are unchanged; **P2-S8 remains incomplete**. Q3/Q4, registry-of-record/production-ID and delivery/bundling gates remain intact.

**Completion rules, proportionate to the kind of slice:**

- **Implementation slices** close with focused tests for the slice, the full test suite passing, and Debug and Release builds of the app and extension on the iPhone 17 simulator.
- **Documentation and evidence slices** close with their sources checked (cited documents, sections, figures, and hashes) and the owner's review. No build or test run is required when no code changes.
- Every slice gets a short completion record in this roadmap.
- **Independent review** is required only where an accepted decision mandates it. No accepted decision currently mandates it for a Phase 2 slice; the owner may request it for any slice.
- The **full phase audit** (§Phase Audit; `AGENTS.md` §24) is reserved for Phase 2 closure.

**Slice-specific criteria:**

- **P2-S1:**
  - Every accepted, rejected, and unsupported case in DEC-065 §D has a test, including the valid cases: a BOM, CRLF and LF endings, quoted fields with doubled quotes, `stop_sequence` gaps, blank optional times, and times past `24:00:00`. Each rejection asserts its typed error with table and line context. Unsupported input is reported as unsupported, never as invalid.
  - Output is deterministic: the same input gives equal DTOs.
  - Parsing runs off the main actor.
  - All fixtures are synthetic (DEC-065 §C).
  - The branch contains no provider row, bulk identifier list, archive, mapping, credential, or evidence path.
  - **Local validation, not committed:** run against the pinned Toei archive or the Toei static archive read from its public, credential-free source (DEC-065 §C). Against the pinned archive (SHA-256 `f10d03cd951565379e5c397cf9043d0db58b5030b670c29f7c56ac43fe3efbe2`), the reader reproduces the audit aggregates (§6.1.3, §6.5): 149 `stops` rows, all `location_type` 0; 6 routes; 5,600 trips; 404 `translations` rows (Japanese 202 / English 202 / Korean 0); 141 distinct stop names, 8 of them on two lines; zero invalid and zero unsupported rows. Only aggregates are recorded. If only a newer upstream archive is available, its hash and aggregates are recorded without claiming they match the audit.
- **P2-S2 (DEC-066):**
  - **Tool integration tests — required for completion.** They run in the macOS test runner against synthetic archives created in a temporary directory, never committed:
    - a valid archive produces the expected manifest and a clean reader result;
    - two runs on the same input produce byte-identical manifests;
    - each unsafe name class rejects the whole archive — path separator, `..`, absolute path, folder entry, leading dot, control character, non-ASCII — including when the unsafe member would not be read;
    - a duplicated name rejects the archive before any member is streamed;
    - a missing required table rejects the archive;
    - a CRC error and a truncation in a selected member reject the archive, and the bytes streamed so far are discarded;
    - a damaged unselected member is accepted and recorded by name only, confirming the documented integrity limit;
    - an archive over its size limit, one selected member over its limit, and selected members together over their limit each fail;
    - a reader rejection (invalid or unsupported) fails the intake;
    - after every failure, no manifest and no temporary file remains;
    - an existing output file is never overwritten, including one created by another actor after the tool's preliminary check and before publication: publication fails with `EEXIST` and leaves that file untouched;
    - a controlled change to the archive during intake fails without publishing a manifest, both when its bytes are modified in place and when its path is replaced by another file;
    - archive and output paths inside the repository are refused, including through a symlink;
    - a `sourceURL` with user information, a query, or a fragment is rejected, and a `credentialed` source is recorded without any URL.
  - **Unit tests** in the same runner cover the name policy, the limits, SHA-256 known-answer vectors, the `obtainedAt` format, and deterministic manifest encoding.
  - **Boundaries:** the app target and `TSUGINOTests` are unchanged. No third-party dependency and no Xcode target are added. Build artifacts appear only under the git-ignored `Tools/StaticDataIntake/.build/`.
  - **Local validation, not committed:** the tool is run on the current public Toei archive, and on the pinned 2026-09-16 archive if it becomes available. The archive SHA-256, `feed_version`, and selected-member hashes are recorded as aggregates, with a clean reader result. No equivalence is claimed between different hashes.
  - **Suite and builds:** the full `TSUGINOTests` suite and the Debug and Release builds of the app and extension still pass. No archive, member bytes, manifest, signed URL, token, or local path is committed.
- **P2-S3 (DEC-067):**
  - **GTFS, focused tests.** Fully invented, Tokyo Metro-shaped synthetic tests of the **unchanged** P2-S1 reader are accepted. They cover:
    - a byte-order mark;
    - flat stops with line-letter `stop_code` values, including a two-letter branch code;
    - first rows with `pickup_type` 1 and last rows with `drop_off_type` 1;
    - intermediate blank-time rows with `timepoint` 0;
    - `field_value`-keyed translations.

    No reader rule changes.
  - **`odpt:Railway` reader, focused tests.** Every accepted, invalid, and unsupported case in the scoped contract of DEC-067 §G is tested, using invented records only, including a separate branch record kept as its own DTO. The tests also cover deterministic output, source order preserved, title-map language keys preserved, and parsing off the main actor.
  - **Tool.** The P2-S2 runner still passes, with added cases:
    - the DS-03 source entry is `credentialed`, carries the verified catalog metadata, and a manifest from it has no URL;
    - `validate-railway` (DEC-067 §F) prints exactly the §E aggregates for a valid invented input;
    - `validate-railway` refuses repository paths (including through a symlink), a non-regular file, and an input over its limit;
    - `validate-railway` exits non-zero on a reader failure without printing a provider value, and writes no file.
  - **Boundaries.** No copied Tokyo Metro row or value, no identifier or line-code list, no mapping, manifest, credential, or token is committed. There is no fetching or token handling, no canonical identifier, and no route-to-Railway matching (P2-S4).
  - **Local validation, not committed.**
    - When the owner-only inputs are available, the intake command on the retained static archive reports 0 invalid and 0 unsupported rows. It is expected to reproduce the audit's counts — 185 `stops` rows, 9 routes, 9,544 trips, 172,168 `stop_times` rows, 494 `translations` rows — for SHA-256 `9a077f8f…`; any other archive is recorded without claiming a match.
    - `validate-railway` on the retained snapshot reports 10 records.
    - Only the DEC-067 §E counts, totals, and hashes are recorded. If the inputs are unavailable, this validation is recorded as outstanding.
    - *Amended 2026-09-29 (accepted recovery item 4):* the identified inputs are the 2026-09-29 owner-acquired pair, and the historical inputs above are audit evidence only. **Passed** on that pair: intake 0 invalid, 0 unsupported on `76f04623…a277e1`; `validate-railway` 10 records, 0 invalid, 0 unsupported on `90b16083…3b97f6c`.
  - **Suite and builds.** The full suite and the Debug and Release builds of the app and extension pass.
- **P2-S4 (DEC-068).** P2-S4 is *implemented* when the synthetic criteria pass, and *complete* only when the real-data criteria also pass (DEC-068 §H).
  - **Minting and registry, synthetic tests.**
    - Minted identifiers have exactly the DEC-068 §A form: prefix, underscore, 16 lowercase Crockford base32 characters.
    - Uppercase, substitute letters, and other lengths are rejected.
    - Minting takes only the kind and the registry. With an injected test generator, the same provider input under two generators gives different identifiers.
    - A forced collision with an active or a retired identifier of any kind is discarded and redrawn, and 8 consecutive collisions fail the run without minting.
    - Re-importing looks identities up and never re-mints. A retired identifier is never reused.
    - Registry decoding rejects an unknown schema version, a repeated identifier, a malformed identifier, a reference bound to two identifiers, and a blank original value. Encoding is deterministic.
    - The production minter has no injectable generator. The Domain identifier types are unchanged, as DEC-051 decides.
  - **Values and provenance.**
    - Decoded values round-trip scalar for scalar, and composed and decomposed spellings stay distinct. Invented stand-ins cover the ヶ / ケ and 〈…〉 shapes.
    - Every reference carries its source, namespace, input and member hashes, table or record index, field, and provider key.
    - No mapping record contains source bytes, and none claims byte-for-byte preservation.
  - **Operator-level grouping, on invented feeds.**
    - No rows are merged without a reviewed grouping record, even when the Japanese names, English names, and code prefixes all match.
    - A proposal is made only with the DEC-068 §D2 evidence, including route and neighbouring-stop context.
    - Contradictory, competing, or insufficient candidates are held back and listed with every member's source reference.
    - A reviewed exception applies to its one grouping only.
    - An invented station name used by both operators stays two identities, with no relation or transfer edge.
  - **Lines, on invented feeds.**
    - Every route and Railway record binds to exactly one `LineID` through a reviewed binding record.
    - An invented `Q` / `Qb` pair gives one `LineID`: the `Qb` record is bound with its own provenance, and no second `LineID` is created.
    - An unbound route or record fails the run.
    - A disagreement in the official-field checks is reported and never binds on its own.
  - **Revisions, on invented revised feeds.**
    - Each DEC-068 §E status transition and each reported category is tested.
    - An omitted reference becomes absent: it is kept as history and does not resolve.
    - Only a reviewed record retires a reference, and a retired value that reappears is a conflict.
    - A conflict fails the run.
    - A merge or split without an explicit identity migration is refused.
    - A canonical identifier never changes.
  - **Determinism.** The same inputs, reviewed records, and registry give byte-identical output.
  - **Boundaries.**
    - No real mapping, reference, grouping, binding, or registry record, and no importer output, is committed, for either operator.
    - No Tokyo Metro value is committed.
    - No distance constant exists, no dependency is added, and heavy work stays off the main actor.
  - **Suite and builds.** The full suite and the Debug and Release builds of the app and extension pass.
  - **Real-data acceptance — required for completion, not committed.** Registries from local runs are provisional and stay outside the repository.
    - P2-S3's real Tokyo Metro validation has passed first.
    - **Toei:** on an identified snapshot — operator-level identities, reviewed groupings and held-back candidates, and 6 route bindings. On the audited snapshot the expected result is 149 rows forming 141 identities. On any other snapshot, every difference is explained and reviewed.
    - **Tokyo Metro:** on identified owner-only snapshots — 185 rows forming 144 identities; 9 routes and 10 Railway records bound to 9 `LineID`s, with the branch record bound to the Marunouchi `LineID`; the official-field checks agree 9/9.
    - Only counts, totals, and hashes are recorded. Until both operators pass, P2-S4 stays implemented but incomplete, unless a new accepted decision revises this condition.
- **P2-S5 (DEC-069; amended 2026-09-30).** The original criterion is preserved in DEC-069's amendment list: a deterministic importer on the pinned inputs, reproducing DEC-048's aggregates.
  - **Inputs.** P2-S4's identified snapshots (Toei `dd575706…`; Tokyo Metro `76f04623…` and `90b16083…`), the reviewed P2-S4 records, and the shared provisional registry, all outside the repository. They are compared with the historical A4 analysis, with no equivalence claimed.
  - **Candidates.** Exact original Japanese, exact original English, and the two accepted alias rules: ヶ / ケ, and the 〈…〉 subtitle.
    - One candidate per pair, keeping every discovery reason, in a deterministic order.
    - No spatial candidates. Differently named stations not related by the two alias rules may be missed.
  - **Review.** Every candidate gets a reviewed `same`, `distinct`, or `ambiguous` record with its evidence digest; an unreviewed candidate fails the run.
    - `same` joins exactly two identities, needs converging structural evidence, and cites an alias rule only when one was used.
    - A differently named `same` needs a reason and the provenance of its evidence.
  - **Synthetic tests** cover:
    - the keys, deduplication, and discovery reasons;
    - the alias rules as explicit, reversible comparison keys, with originals preserved;
    - the outcomes and the refusals of `same`;
    - an invented same-name pair kept `ambiguous`: two stations, with no registry relation and no transfer edge;
    - station minting and attachment;
    - deterministic output.

    Toei 新宿 and Tokyo Metro 新宿 stay separate with no transfer edge, and **no distance constant exists**.
  - **Suite and builds.** The full suite, and the Debug and Release builds of the app and extension, pass.
  - **Real-data acceptance, local and not committed.**
    - A run on the identified inputs is checked against the **expected baselines** (DEC-048's historical figures, pending the actual run): 285 identities; 27 merged, 114 Toei-only, and 117 Tokyo Metro-only groups, 258 in total; 0 duplicates; 0 unmapped; 市ヶ谷 / 市ケ谷 and 押上 / 押上〈スカイツリー前〉 merged; 新宿 separate and ambiguous.
    - A mismatch stops acceptance until it is explained and the owner has reviewed it. It never changes a reviewed outcome or forces a merge.
    - A4's 54 candidates and 26 distinct classifications are recorded as comparisons only.
    - A rerun is byte-identical.
  - **Identifiers.** `StationID`s are provisional and minted independently of any analysis key. P2-S5 completes without production identifiers, which wait for the registry-of-record decision (DEC-068 §F1). Publication and bundling stay gated.
- **P2-S6 (DEC-070; accepted 2026-09-30).** The original criterion still applies: every canonical station has exactly one `GeoCoordinate` with recorded provenance, or is held back; every topology is connected, and its derived membership equals every `Station.lineIDs` (DEC-057 D9); the Oedo loop-plus-tail shape and the Marunouchi branch validate. DEC-070 narrows the output and adds:
  - **Coordinates.**
    - One row, or several rows with an identical point: that exact published point, with the provenance of every row and no selection review.
    - Several different points: one member row's exact point, chosen by a reviewed record giving the row's source, input hash, `stop_id`, the exact point, and a reason.
    - On each input the points are classified again. A formerly automatic station whose points now differ, or a reviewed choice that changes or disappears, is held back for review.
    - Previous selections are kept as history. A point is never substituted.
    - No derived point and no distance.
  - **Topology.**
    - Consecutive GTFS rows, including pass-through rows, give undirected adjacency candidates (DEC-057). They are trip evidence, not proof of physical adjacency.
    - The possible-shortcut heuristic (a review trigger, not a classifier): a candidate {a, b} is flagged when there exists an alternative run of the same line between a and b, with intermediates, such that every trip showing a and b consecutive visits none of them.
    - Flagged candidates, triangle triggers, and self-pairs need a reviewed record. Nothing is removed automatically, and graph reachability alone never flags.
    - Unexpected topology is also held back by the connectedness, membership, and shape checks.
    - Evidence is kept for every candidate.
  - **Shapes.** Oedo (one cycle, one degree-3 junction, one tail end) and Marunouchi (acyclic, one degree-3 junction, three ends) are checked on graphs built without seeding. A mismatch stops acceptance for owner review.
  - **Synthetic tests** cover the coordinate rules and revisions; the heuristic with its quantifiers, including partial-loop support flagged but not removed; triangle triggers and self-pairs; review enforcement; the failure checks; the shape checks; determinism; and no distance constant. The full suite and the Debug and Release builds pass.
  - **Real-data acceptance, local and not committed.** Every station has a coordinate with provenance, or is explicitly held back. Every line is built, reviewed where required, connected, and agrees in membership. The shape checks pass, the rerun is byte-identical, and the counts are recorded, not assumed.
  - **Boundary.** P2-S6 produces coordinate, topology, and membership artifacts only. Complete `Station` / `RailwayLine` values wait for P2-S7 names.
- **P2-S7:** through the local search API, every baseline station is found by its Japanese, English, and Korean names and by its recorded aliases, including 市ヶ谷 / 市ケ谷 and 押上〈スカイツリー前〉; both 新宿 stations are returned and can be told apart by operator and lines. Station search UI is Phase 8. **Accepted extension (DEC-071, 2026-09-30):** DEC-071 §A–E specifies Unicode-scalar-exact comparison throughout, evidence-validated name carry-forward with append-only provenance, explicit editorial station-title bindings, complete named Domain values, and synthetic implementation before separate local real-data acceptance. It does not relax DEC-070 or the translation/publication/production/bundling gates.
- **P2-S8:** the storage decision is recorded with measurements; a test proves ordinary use does not re-parse the full static dataset (Rule 15); reopen, data-version, and identifier-retirement migration tests pass.
- **P2-S10 / P2-S11:** evidence is recorded as dated aggregates with its sources, under the authorization given; nothing is declared or promoted by the evidence alone.

**Phase 2 exit relevance (DEC-075, accepted 2026-10-01).** S1–S8 technical/local acceptance, including DEC-074 real SQLite acceptance, and S11 evidence serve baseline-foundation exit. S9/S10 and production delivery are explicitly deferred from exit only, with their owners/triggers retained. S11 was performed under specific-device authorization; no further device access is implied.

**Accepted milestone and timetable placement — DEC-074 (2026-10-01).**
The owner accepted the local-baseline milestone boundary requiring private
provisional real SQLite acceptance in P2-S8, and P3-T1's planning ownership and
dependency placement. Timetable semantics/implementation are not accepted.
S9/S10 remain outstanding with their existing prerequisites/triggers; DEC-075
subsequently resolved their overall exit disposition as exit-only deferral. Private integration was separately
authorized; its actual result is recorded below. Neither acceptance nor that local
milestone closes overall P2-S8/Phase 2 or grants production/distribution permission.

**Accepted overall exit disposition — DEC-075 (2026-10-01).** S9/S10 and S8
production delivery are not prerequisites to baseline-foundation Phase 2 exit.
S9 remains mandatory before canonical passenger-stop Trip consumption and P3-T1
real import; S10/Track A remains mandatory before candidate capability/support
claims. Production registry, shipping composition and applicable publication/
bundling gates continue to block their specific deliverables. The separate final
audit below records completion of the foundation, not completion of these follow-ups.

### Timetable Ownership — Planning Assigned, Semantic Contract Still Open

DEC-060 §F defers service days, calendar exceptions, extended-hour rollover, time
zones, schedule-to-identity mapping and Clock semantics to a separate contract.
DEC-074 now assigns planning ownership to **P3-T1 — Timetable Contract and Static
Schedule Import**, before consumption of imported schedules in Phase 3 and
scheduled runtime behavior in Phase 5. The semantic contract and implementation
remain unaccepted. P2-S9 imports no times; Phase 2 is not expanded into timetable
implementation. Scheduled Journey Guidance remains a required product capability
whose timetable data prerequisite is not yet fulfilled.


## Performance Tasks

Measure:

- app startup impact
- static data size
- station search latency
- memory usage
- decode/load time

## Tests

- importer fixtures
- duplicate station handling
- Japanese/English/Korean canonical names
- cross-language station aliases
- mapping stability
- reopen/durability
- data-version migration
- station search correctness

## Physical Device Test

- cold launch
- station search speed
- memory usage
- offline station search

## Acceptance Criteria

- Tokyo baseline stations searchable locally
- no repeated full static-data parsing during ordinary app use
- canonical mappings are deterministic
- storage decision is documented

## Exit Criteria

Static railway topology is stable enough for route and realtime integration.

**Accepted interpretation (DEC-075):** assess this for the identified **local
provisional baseline foundation**, retaining the four acceptance criteria above,
DEC-074 real SQLite acceptance and required verification/device evidence. P2-S9,
P2-S10 and production delivery are not prerequisites to this phase exit; they
remain open, owned follow-ups with mandatory triggers. A separate final audit is
required. Completion grants no production readiness, identity promotion, shipping,
publication or bundling permission and does not start Phase 3.


## Final Phase 2 Acceptance Audit — 2026-10-01

**Verdict: PASS — Phase 2 is complete under Accepted DEC-075's local provisional
baseline-foundation scope.** This is the separate final audit required by that
decision, not a completion claim based on planning acceptance alone. Overall
P2-S8 production delivery remains incomplete; S9/S10 remain required follow-ups.
Phase 3 has not started. Earlier dated records that left phase exit open describe
the evidence and authorization available at that time.

### Accepted exit criteria mapped to evidence

| Accepted criterion | Identified evidence and result |
|---|---|
| Tokyo baseline stations searchable locally | Accepted S7: 825 canonical slots, six explicit aliases, 186 editorial bindings. DEC-074 private SQLite acceptance round-trips all 258 stations, 15 lines and two operators; 774 exact index keys / 780 key-target pairs, all six aliases and both distinct Shinjuku identities pass. Scalar-exact queries retain composed/decomposed distinctions. **PASS.** |
| No repeated full static-data parsing during ordinary app use | S8 regression/counter evidence and ordinary-access workloads show persisted-index queries and matched-record decoding; validation occurs once per open, with explicit full loads counted separately. DEC-074 real access preserves those counts. Shipping composition is still unwired; this validates the repository access path, not an unimplemented search UI. **PASS.** |
| Canonical mappings are deterministic | Accepted S4/S5 mappings and S6/S7 repeat/history checks; DEC-074 preserves the provisional registry and all approvals, compares complete Domain values, and produces three byte-identical SQLite artifacts with one build-history entry and no duplicates. DEC-073 synthetic migration proves reviewed transitions, immutable earlier bindings and deterministic reruns. **PASS.** |
| Storage decision is documented | Accepted DEC-072 selects system SQLite from the compact-file comparison, with measured limitations; DEC-073 supplies reviewed identity transitions and explicit version rejection. Prototype and final validated-repository measurements remain separately identified. **PASS.** |
| Static railway topology is stable enough for route and realtime integration, under DEC-075's local provisional baseline interpretation | S6 validates 258 exact published coordinate selections, zero held-back stations, 15 connected topologies and bidirectional membership; Oedo loop-plus-tail and Marunouchi branch checks pass, with no unexpected shortcut/triangle/self-pair or unused review. Four network repeat artifacts match. S7 constructs complete named Domain values; DEC-074 reproduces coordinates, topology and membership through SQLite, with metadata, reopen and repeat acceptance. This is foundation readiness, not Trip passenger-stop or schedule acceptance. **PASS.** |

### Supporting slice and verification audit

| Scope / required audit area | Saved evidence and conclusion |
|---|---|
| S0–S3 source boundary and intake | The earlier accepted completion records retain source registration, strict offline parsing, identified GTFS/Railway inputs and real validation. Credentialed/provider artifacts stay outside Git. The later 211-test tool suite retains the accumulated intake regression evidence. |
| S4–S5 identity and mapping | Earlier completion matrices record reviewed line/station mappings, deterministic repeats and 285 operator station identities resolved to 258 canonical stations through 27 reviewed groups. The two Shinjuku identities remain distinct. IDs are provisional; no production promotion is inferred. |
| S6 coordinates/network | Accepted real audit reports 258 selections, 15 connected lines and agreed memberships, 320 included adjacency candidates, zero held-back/unresolved cases and passing shape checks. Exact source points and alternatives/provenance remain retained. Reviewed representative coordinates make no accuracy, entrance, platform, station-centre or physical-survey claim. |
| S7 names/search | Local acceptance records all 825 names, six aliases and 186 bindings, complete Domain construction and five byte-identical repeats without duplicate/lost history. Published evidence stays distinct from authored names, and extracts from raw source bytes. Approval history and translation limits are unchanged. |
| S8 storage/version/transition behavior | [DEC-073 verification](../Tools/RailwayStorage/DEC073_VERIFICATION.md) proves newly applied pure retirement, replacement, merge and split; version handling, stale/conflicting records, complete delta accounting, failure atomicity, historical authority, reopen and deterministic repeat behavior. Runtime exposes retirement/history without automatic successor following. DEC-074 supplies separate private real integration acceptance. |
| Tests and builds | Reuse 211 tool tests, 591 app tests, final 40 affected registry/repository checks, Debug/Release app-and-extension evidence and incremental Release. Later index changes have 25 affected name-tool checks, eight app checks and the storage/transition runner. The private integration adapter has three focused synthetic checks. These are stage-specific saved results, not a newly rerun broad suite. |
| Performance requirements | [Prototype comparison](../Tools/StorageMeasurement/RESULTS.md), [validated repository measurements](../Tools/RailwayStorage/Measurement/RESULTS.md), [Simulator startup](../Tools/RailwayStorage/Measurement/Startup/RESULTS.md) and [physical results](../Tools/RailwayStorage/Measurement/Physical/RESULTS.md) cover artifact size, startup attribution, search latency, memory and decode/load. Setup costs are separate from runtime; no physical results are inferred from macOS/Simulator timing. |
| S11 / required physical checks | Authorized iPhone evidence includes ten prior workload processes (five per ordinary/history artifact), exact search and memory/reopen checks, 20 offline network checkpoints, and 40 formal startup observations: five paired baseline/repository runs per metric/artifact. The 2/2 recovery checks are excluded from that cohort. Cold launch, repository search speed, memory and offline search evidence are recorded. No further device access is needed for this audit. |
| Scope and architecture | Reuse the [focused final review](../Tools/RailwayStorage/FINAL_REVIEW.md): protected Domain, system SQLite, read-only actor repository and offline builder; measurement code requires its compile flag, absent from normal configurations/composition. No new implementation review or later-phase feature is introduced by this audit. |
| Documentation and findings | DEC-075 acceptance and this roadmap synchronize the exact exit interpretation. No known material defect or unmet amended exit criterion remains in the saved evidence. Retained limitations and delivery work below are not silently marked complete. |
| Working tree / change boundary | Audit at `69464c1` on `phase/02-static-data`, tracking `origin/phase/02-static-data`, three ahead / zero behind the locally tracked ref; no fresh remote synchronization claim. Only DECISIONS and ROADMAP are modified, with nothing staged or untracked. This audit adds documentation only; no commit, push, merge or Phase 3 execution. |

### Evidence integrity and limits

The saved eight DEC-073 log hashes and six affected-measurement log hashes match.
Final measured source fingerprints match, accounting for the already documented
extra-blank-line removal in the measurement build script: its current bytes plus
that newline reproduce the historical fingerprint, and its corrected hash matches
the final review inventory. No executable statement changed. Reviewed code remains
unchanged; documentation is the intended exception. No new test/build/measurement
run or implementation review was required.

The private DEC-074 package's 50 manifest entries and all 279 preserved originals
match their saved hashes. The acceptance record identifies 59 S7 input-manifest
entries, 21 source/registry/document inputs and accepted S6 artifacts. Its three
217,088-byte SQLite outputs match exactly; metadata identifies runtime schema 1,
registry revision 6 and the local provisional data version. Accepted names, aliases,
bindings, first sightings, prior choices and source/network records remain retained.
Hashes identify retained bytes; they do not independently authenticate a publisher.
No owner-only artifact, adapter, machine-specific log or path is added to Git.

Physical startup is process-cold under recorded cache limitations, not guaranteed
cold filesystem cache. Title-only responsiveness measures first-frame/main-thread
input readiness, not search-UI readiness or touch latency. Offline settings were
owner-confirmed; workload checkpoints supply network evidence, not per-launch
thermal/network telemetry. Peak RSS is not a leak proof or physical-footprint
measurement. The overlapping samples demonstrate neither improvement nor
regression; no unaccepted performance threshold is invented. SQLite repeat identity
is demonstrated for the recorded engine/environment, not promised across engines.

### Retained follow-ups and deliverable-specific gates

| Open owner / gate | Prerequisite, trigger and remaining deliverable |
|---|---|
| **P2-S9** | S4 mappings, authorized identified inputs and DEC-060/061 passenger-stop verification. Must complete canonical Trip structure import **without times** before passenger-stop Trip consumption and P3-T1 real timetable import. Exit deferral is not cancellation, acceptance of existing GTFS rows as stops, or authorization to implement now. |
| **P2-S10 / Track A** | S0/source boundary and explicit access authorization. Repeated candidate payload evidence remains mandatory before any expansion candidate capability/support claim; DEC-058/059's other eligibility gates also remain. No candidate is promoted by this audit. |
| **P2-S8 production registry / DEC-068 §F1** | Owner decision on registry-of-record location, backup and delivery, plus explicit identity adoption/migration, precedes production ID allocation/adoption and committing real identity records. Private provisional acceptance does not supply that decision. |
| **P2-S8 delivery/composition** | Separately scoped real-artifact installation/selection and shipping repository composition with compatibility/recovery handling remain unimplemented. Their applicable identity and rights gates must pass before production consumers rely on delivered data. Measurement instrumentation is not delivery wiring. No shipping phase is silently assigned. |
| **Q3 / DEC-065 §A** | Affected Metro-derived public mappings remain blocked pending the ODPT reply or separately accepted publication decision. Private acceptance and safe aggregate reporting do not grant publication rights. |
| **ODPT item 5 / applicable compliance** | Shipped-app data bundling remains blocked pending written confirmation and applicable attribution/update/non-restorability obligations. Neither phase closure nor production-registry planning grants bundling permission. |
| **Q4** | New Metro-derived translation authoring remains blocked. Reuse of accepted exact published names in this private acceptance does not resolve that question. |
| **P3-T1 planning owner** | Timetable contract/import placement is accepted, but semantics and implementation are not. Calendars, service dates, extended-hour rollover, time zones, schedule-to-identity mapping and Clock semantics need design acceptance. Real import additionally requires verified S9 passenger-stop mapping, S4 provenance, this local baseline and authorized inputs; scheduled runtime/presentation consumers depend on that contract. S9 imports no times. |

These obligations block their named activities, not all independent synthetic or
provider-evaluation work. Starting any next slice still requires its own authorized
scope. **The completed milestone is the local foundation; production delivery,
expansion support and scheduled guidance remain incomplete.**

---

# Phase 3 — Route Search Provider Integration


## Owner-accepted first Toei calendar/time evidence profile — 2026-10-09

The owner explicitly accepts the exact retained Toei GTFS 20260921 calendar/time
evidence profile for the already accepted first P2-S9 Trip snapshot only:

| Approval binding | Exact safe metadata |
|---|---|
| Profile ID | `p3t1.toei-20260921.calendar-time-profile.1` |
| Review ID | `p3t1.toei-20260921.calendar-time-review.20261009.001` |
| Review SHA-256 | `c45370a1e69d6c08d1ed4c7bfd601af728a7fb804ca121eb1a8234798a5e29c9` |
| Owner approvedAt | `2026-10-09T14:03:35Z` |

Acceptance establishes the scoped weekly calendar/completeness and unique exceptions,
14 original-index time/eligibility bindings, exact qualification of 28 events,
one execution per service date, pinned explicit fixed-offset provenance/unique
inversion and compatible chronology. It does not grant real import execution,
shipping profile authority, runtime installation, launch coverage or Phase 3 exit.
Historical source-profile-required wording below records earlier gates; this dated
owner acceptance resolves that evidence gate only for the exact retained candidate.

The separately authorized bounded implementation is `Tools/TimetableImport`: an
owner-only macOS normalized-input adapter using invented fixtures only. It reuses
unchanged Domain values and published S9 verification, keeps S9/profile authority
external by exact digests, separates profile approval from exact import-request
approval, and supports one Trip/one explicit service date. No GTFS parsing/source
acquisition, real/private artifact access, real approval materialization, real
normalized input, real request, real timetable facts or runtime adoption occurs in
this implementation task. DEC-078/085 product semantics are unchanged;
`NO_NEW_PRODUCT_DECISION_REQUIRED`. See the tool README for wire formats, bounds,
private publication, state, replay and verification instructions.

Root verification: standalone production build **PASS**; complete new-tool invented
suite **186 cases PASS**; unchanged timetable values/ride contexts/conversion/batch
and three timetable-to-routing integration suites **82 Swift Testing tests / 7 suites
PASS** on an explicit iPhone 17 / iOS 26.5 Simulator. These are disjoint verification
groups; superseded setup attempts are excluded. Production symbol inspection found
no synthetic timetable types or test fault hooks. Tracked/new-file whitespace and
privacy audits pass. The unchanged published S9 production verifier and complete
invented S9 suite passed **185 cases**, including its large external-history envelope.
The timetable input/request/bundle retain only external S9 pins, not nested S9 history.
Separate non-author independent review **APPROVED 29/29 criteria, zero unresolved
material findings**. The reviewer independently rebuilt production and reran the complete
final **186-case invented suite: PASS**; this rerun confirms the same cases and is not
added to the root count. Review tightened non-string/null zone kinds and bounded bundle
directory enumeration; persistent regression cases cover both and exact resource limits.
The final production binary SHA-256 is
`dfd6addfc12c2ce8b324db8744d60b1401b5f80a120e6a63839bcbca0237efab`.
No real/private railway artifact was accessed by author or reviewer. No physical-device
step or full app Release build was required for this offline tool; app/shared production
and existing tool source remain unchanged. `git diff --check`, per-new-file whitespace,
privacy and scope audits pass. Implementation remains unstaged/uncommitted for owner
publication review; published Phase-3 HEAD remains
`389ca38494996fdc31770f8d064f5649db7e5334` and main remains
`e8a463d51f14b3cb1027960c63244b694579a71b`.

**`P3_T1_REAL_IMPORT_ADAPTER_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`.** This verdict
establishes tooling only, not real approval/input/request/facts/bundle materialization.
The next safe action is owner review and publication of this implementation. After
publication, separately materialize the granted profile approval, bind exact accepted
S9/source rows for one explicit date, prepare exactly one unapproved real import request,
independently verify target facts and stop for owner digest approval. Do not approve or
apply a real import in this implementation/publication task.
P3-T1 remains partial and Phase 3 In Progress; broader P2-S9 closure, validated real
import, production registry/data delivery, route-search adoption and Journey remain
separate gates. The existing DEBUG synthetic implementation remains reference/test
code and is not compiled into the standalone production adapter.

## Planning Assessment — 2026-10-01 (Proposed Sequence Only)

**Authorization and baseline.** This session starts Phase 3 planning, not
implementation or decision acceptance. Verified repository root
`/Volumes/Data/dev/TSUGINO`, origin `https://github.com/lunalism/TSUGINO.git`, branch
`main`, and HEAD `e8a463d51f14b3cb1027960c63244b694579a71b`. After a successful
`git fetch origin`, `origin/main` matches HEAD, upstream is `origin/main`, and
ahead/behind is 0/0. The starting working tree is clean. AGENTS §28 and existing
branches use `phase/<number>-<name>`; `phase/03-route-search` is a proposed name
consistent with that convention, not an existing or approved branch. No branch
is created in this session.

**Scope lock.** Assess accepted Phase 3 scope and propose its smallest ordered
slices. Only this ROADMAP planning record changes. No source, tests, schema,
accepted decision, provider selection, real artifact, translation, credential,
device, delivery or capability change. No test/build reruns, commit, push or merge.
Verification is a documentation/reference, diff and working-tree review. The
accepted Phase 3 goal, acceptance/exit criteria and decision gate below remain
unchanged; the proposals here do not become contracts by being recorded.

### Accepted scope and existing foundation

Phase 3 remains **replaceable route-search provider integration**: `RouteSearching`,
canonical `RouteCandidate`, alternatives, client/DTO/adapter/mapping, transfers,
through-service continuity, scheduled train context, JP/EN/KO route content,
recoverable provider errors, basic diagnostics and caching only where permitted.
DEC-064 also places `TrainCandidate` definition here; it does not move Phase 5
selection/binding/progression behavior into Phase 3. ARCHITECTURE §10 is a shape
sketch, not a fully specified route contract. No implementation of these three
route types was found in the app source inventory.

Existing DEC-060/061/062 contracts provide Trip traversal/coverage/service-type
segments, position-addressed selection, rail legs, stated walking transfers and
Journey continuity. They are constraints to reuse, not proof of real passenger
stops or verified walking connections. Line topology cannot supply Trip stops;
equal names cannot establish identity. A line/operator change alone is not a
transfer (DEC-009). A candidate is not automatically an active Journey or an
explicit user train selection.

DEC-075's completed Phase 2 foundation supplies private provisional acceptance of
258 stations, 15 lines and two operators, reviewed names/aliases, mappings,
coordinates/topology and SQLite/version/history behavior. Reuse the final Phase 2
audit above; no fresh tests, builds, private evidence access or device work is
needed for this assessment. This is not production adoption or shipping composition.

**Provider status.** DEC-004 remains **Provisional**. The feasibility audit §10
and DS-11–13 leave Ekispert, NAVITIME and Jorudan as candidates, with commercial
terms and payload suitability pending. Its older “before Phase 3” provider-direction
gate is not satisfied by starting this planning session: DEC-074/075 explicitly
permit independent evaluation and synthetic work, not unselected live integration.
The recorded Toei static/realtime joins are not evidence of a commercial route
provider's train-identity join. This assessment adds no current price/license claims.

### Proposed smallest ordered slices

The ordinal labels below describe a proposed sequence, not newly accepted slice IDs.
“Supported” means existing contracts support the work; implementation still needs
its own authorized scope.

| Order / bounded work | Supported by existing contracts | Genuine decision or evidence prerequisite / stopping point |
|---|---|---|
| 1. Route-boundary contract draft and synthetic case matrix | DEC-009/020/021/060–064; ARCHITECTURE §10 and §40; existing Journey/Trip values | Specify proposed `RouteSearching` request/result/failure semantics, `RouteCandidate` and minimum `TrainCandidate` shape. Resolve candidate-to-Journey relation, explicit continuity/transfer evidence, unknown mappings, scheduled-context provenance, and safe canonical metadata. Identify rather than silently settle changes to accepted Domain invariants. Stop at a reviewable unaccepted design. |
| 2. Synthetic route boundary, normalization and failure handling | Canonical IDs, DTO isolation, existing traversal/leg invariants, deterministic time and privacy-safe diagnostics | After bounded contract acceptance and implementation authorization, use wholly invented data for direct/transfer/through-service and failure cases. No real-provider compatibility or phase-exit claim; no folders for unselected providers. |
| 3. Provider evidence comparison and selection, then one bounded integration | Existing audit §10 comparison and Phase 3 decision gate | Reuse recorded evidence first. Resolve actual payload/identity joins, mapping stability, through continuity, data quality, languages, pricing and license/commercial terms. Audit A2 calls for evaluation access to at least two candidates; acquisition/contact is separately authorized. Select through explicit decision before provider-specific client/DTO/adapter work. Cache only when its rights and lifecycle are established. |
| 4. P3-T1 semantic design, then synthetic contract/import work | DEC-074 accepts planning placement and invented-fixture design | Separately accept calendars/exceptions, service dates, extended-hour rollover, zones/ambiguous times, recurring Trip versus dated occurrence, revisions/cancellations, missing times/coverage, exact identity correspondence, Clock and version/compatibility semantics before implementation. This is a separate data contract, not route-client policy. Design can proceed independently of S9 and provider selection. |
| 5. Retained P2-S9 design/import and passenger-stop acceptance | DEC-060/061 invariants, S4 provenance, accepted local foundation | Keep the P2-S9 owner. Bound importer/identity-review semantics and authorized identified inputs; verify passenger stops per feed, line segments, coverage and provenance. Row presence, pickup/drop-off flags, identical patterns and existing topology observations are insufficient. Deliver no times. Complete before **any** consumption of these real canonical passenger-stop Trips, even if needed earlier by slice 3. |
| 6. P3-T1 real import and truthful consumer binding | Accepted placement and foundation; future accepted semantic contract | Requires completed S9, S4 identity/provenance, identified calendar/stop-time inputs and applicable local-use authorization. Validate versioned schedule output and deterministic boundaries before consumers rely on it. Missing correspondence holds data; no inferred Trip matching or identity minting. |
| 7. Phase 3 canonical-plan integration and exit audit | The unchanged tests, acceptance criteria, exit and provider suitability gate below | Demonstrate usable supported Tokyo plans through the selected provider with truthful scheduled context, canonical-only results, preserved continuity and recoverable failures. Reconcile evidence, architecture, rights and applicable delivery dependencies. Synthetic success alone does not satisfy real integration or production suitability. |

This is a dependency order, not a requirement to serialize independent design work.
P3-T1 design may run before provider selection; S9 must move earlier whenever a
consumer needs its real Trips. Provider-supplied scheduled context does not prove
P3-T1 import completion or authorize downstream reconstruction of timetable
semantics. Phase 5 owns scheduled progression; Phases 8/9 consume that same truth.
Active tracking, realtime progression, final route-results polish and Live Activity
remain excluded here. No in-house route engine or expansion programme is added.

### Deliverables held by retained gates

- **P2-S9:** holds real canonical passenger-stop Trip consumption and P3-T1 real
  import; does not hold independent provider evaluation or invented semantic cases.
- **P3-T1 semantic acceptance:** holds timetable implementation; accepted contract,
  data and consumer binding must precede imported-schedule consumption and Phase 5
  scheduled behavior. Placement alone resolves none of these semantics.
- **Provider decision/evidence:** holds selected-provider integration and production
  suitability claims. Pending access/contract/payload evidence is not a reason to
  acquire credentials or data during this session.
- **P2-S10 / Track A:** holds candidate capability/support claims until repeated
  authorized payload evidence and all DEC-058/059 eligibility requirements pass.
  Retain this owner and schedule before promotion; it is not a prerequisite to
  independent work on the accepted 15-line baseline and is not cancelled.
- **DEC-068 §F1:** holds production identity allocation/adoption and committed real
  identity records until registry location/backup/delivery and adoption/migration
  are decided. No provisional IDs are promoted.
- **P2-S8 delivery/composition:** holds reliance on a delivered real repository
  until separately scoped installation/selection, compatibility and recovery work
  and applicable identity/rights gates pass. No shipping phase is assigned here.
- **Q3 / DEC-065 §A:** holds affected Metro-derived public mappings pending the
  ODPT reply or a separately accepted publication decision.
- **Q4:** holds new Metro-derived translation authoring. Existing reviewed names
  do not authorize new translations or resolve route/headsign content coverage.
- **ODPT item 5 / applicable compliance:** holds shipped-app bundling pending
  written confirmation and applicable attribution/update/non-restorability duties.

### First bounded task and verification proposal

**Recommend order 1 next: a documentation-only route-boundary contract draft plus
synthetic acceptance matrix.** Use the existing Domain contracts and repository
audit evidence; list genuine unresolved policies and provider evidence needs. Do
not choose a provider, invent timetable semantics, amend accepted invariants or
write Swift. Keep the design explicitly proposed and separately reviewable.

Its completion check is that every proposed input/output/failure has an owner and
every case has an expected canonical result or held/recoverable outcome: direct,
one/multiple transfers, local/express, continuous through service, malformed data,
unknown mapping and outage (the accepted Phase 3 test list). Include repeated-stop
indices/partial coverage and scheduled-versus-observed distinctions where those
contracts apply, plus JP/EN/KO content boundaries without real authoring. Subsequent
implementation should run only affected Domain/Data tests and necessary explicit
iPhone Simulator checks; this planning session runs none. Phase 3 lists no new
physical-device test requirement, and historical evidence authorizes no device access.

The first task should end with a concrete design for review and a bounded synthetic
implementation proposal. It should not end with acceptance inferred from this
plan, an integrated provider claim or a weakened exit criterion.

**Historical route-boundary draft (2026-10-01, before acceptance).** Order 1 now has a reviewable
[DEC-076 proposal](DECISIONS.md#dec-076--route-search-returns-canonical-proposals-without-selecting-trains-or-creating-journey-state)
and 36 wholly invented specification case groups, with explicit R13a–c, R31a–c
and R32a–f variants. The focused review corrections validate qualified individual
ridden endpoints before pair omission, separate endpoint/interior/snapshot failures,
and distinguish pure constructor coverage from adapter/harness work. R33 preserves
snapshot contents without allowing incompatible Data revisions to be mixed.
At that point its request/result, candidate, evidence and scheduled-context semantics are
**Proposed, not accepted at that time**. It changes
no accepted Journey/Trip invariant or Phase 3 exit criterion. Owner review and
explicit acceptance precede the recommended pure routing-value implementation
slice; async synthetic normalization and real-provider integration remain separate.
No code, executable tests, builds, acquisition, private evidence access or device
work accompanied the draft. The earlier planning assessment remains a proposal.

### Accepted first implementation slice (2026-10-01)

The owner explicitly accepted revised DEC-076 and all five recommended policies.
ARCHITECTURE §10/11 now reflects that contract. This accepts neither the entire
historical sequence above nor Phase 3 exit readiness. All retained gates and the
Phase 3 criteria below are unchanged.

**Scope lock:** pure `Domain/Routing` values and local structural validation plus
focused invented constructor tests; no async protocol, adapter, networking,
provider selection, mapping/evidence admission, request-relative admission,
incomplete-time interpretation, cancellation/supersession, Journey binding, UI,
persistence, real data or timetable implementation. Reuse existing Domain types
without changing their behavior. No device access, commit, push or merge.

**Implementation record:** implemented, verified and independently approved;
this bounded pure-values slice is complete. The exact
coverage is DEC-076's first-slice table: R35 request constructors; R02/09/11/12,
R27 index validation, R28/29 and R33 snapshot-preservation constructor subcases;
R30 supplied pair, R31a nil representation, R32a/c complete-pair chronology and
R32d/e supplied-instant ordering; R20–22 result/omission construction only.
Additional direct structure checks do not claim provider/adapter compatibility.
The independent approval is recorded below. The next recommended bounded task is
the `RouteSearching` async boundary and controlled synthetic adapter/admission
tests; agree its exact scope before implementation.

**Implementation detail.** Six files in `TSUGINO/Domain/Routing` contain immutable,
nonisolated Sendable values. `UnresolvedRouteRailTravel` validates the unresolved
enum payload (including an already-collapsed nonempty line sequence);
`RouteSearchRejections` validates the all-omitted failure payload. Explicit
initializers suppress unchecked memberwise construction. Existing Trip, Journey,
WalkingTransfer and identifier implementations are unchanged. No async protocol
or application composition was added.

**Verification actually run (2026-10-01).** `RoutingValueTests` passed **16 test
functions / 26 executed cases**, zero failures, skips or runtime warnings, on the
explicit iPhone 17 / iOS 26.5 Simulator (arm64). The successful Debug test action
built the app, test target and embedded Live Activity extension. No full suite,
standalone build, Release build or physical-device run was required or repeated
for this isolated Phase 3 constructor slice; Phase 2's historical slice/full-phase
records are not presented as new verification. Unrelated existing actor-isolation
and AppIntents metadata warnings remain; none was attributed to the new routing
source/tests.

The first attempt exited 65 during test compilation: nested Swift Testing
`#require` macros in the new fixture helpers failed recursive expansion; no tests
executed. Splitting those fixture checks fixed compilation; no routing contract or
production-code correction was needed. The final run exited 0. Initial sandbox
restrictions on Git fetch and Simulator/result services were resolved using the
approved execution permission; no physical-device tool was used.

Exact final command (first attempt used the same options with `focused` instead
of `focused-r2` for the result/log paths):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/RoutingValueTests -resultBundlePath /private/tmp/tsugino-p3-routing-focused-r2.xcresult > /private/tmp/tsugino-p3-routing-focused-r2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-p3-routing-focused-r2.xcresult
git diff --check
```

**Preflight and final audit.** Started on `main` at
`e8a463d51f14b3cb1027960c63244b694579a71b`, tracking `origin/main`; fetched origin
`https://github.com/lunalism/TSUGINO.git` and verified 0 ahead / 0 behind. Only the
expected DECISIONS/ROADMAP changes existed. Verified AGENTS §28 and existing
`phase/<number>-<name>` branches; `phase/03-route-search` was absent and was created
without reset, carrying the documentation edits. HEAD is unchanged; the new local
branch has no upstream. All earlier accepted decisions, the original planning
assessment, existing Domain code, Phase 3 exit and retained gates remain unchanged.
Documentation/reference and `git diff --check` checks passed. At implementation
handoff, self-review found no known semantic gap or local invariant bypass;
independent review was still pending. Constructor success cannot certify Data admission.

**Independent approval (2026-10-01).** A reviewer with fresh context reviewed the
accepted contract, complete tracked diff, all six new routing files and the new
test file without relying on the implementer's self-review conclusions. Verdict:
**approve; no material code defects, test gaps or documentation findings**.
Saved verification confirmed **16 test functions / 26 executed cases passed**,
zero failures, skips or runtime warnings, on iPhone 17 / iOS 26.5 Simulator;
the Debug app and Live Activity extension build was confirmed. No mandatory
verification remains for this bounded slice. No tests or builds were rerun during
review; repository files remained byte-identical throughout that read-only review.
Approval covers **pure constructor semantics only**, not adapter evidence,
request-relative/discarded-input admission, real integration or Phase 3 exit.
DEC-076 acceptance, historical proposals, existing Domain invariants and every
retained gate remain intact. The owner subsequently authorized recording this
approval and committing/pushing only the approved ten-file inventory on
`phase/03-route-search`; no main merge or next-slice implementation is authorized.

### Synthetic async boundary and admission slice (2026-10-01)

**Authorization / scope lock.** The owner separately authorized this next slice
under Accepted DEC-076 after the pure-values commit `3972b6583a8c7a9582cd8fa83c34207470bf5017`.
Fetched origin and verified `phase/03-route-search` and its upstream at that commit,
0 ahead/behind, a clean tree, and `main` at `e8a463d51f14b3cb1027960c63244b694579a71b`.
This subsequent authorization does not change DEC-076 semantics or accept the
entire historical Phase 3 sequence. No real provider or acquisition is authorized.

**Ownership.** `Domain/Routing/RouteSearching.swift` adds only the Sendable async
throwing protocol. `Data/Routing/RouteScheduleAdmission.swift` checks qualified
absolute ridden endpoints before pair omission. Three Debug-only synthetic Data
files define the invented decoded schema/view, admission and search orchestration.
Test-only fixtures, fake clients and actor barriers live under `TSUGINOTests`.
They stipulate evidence rather than prove provider compatibility. No generic
provider framework, public proof token, production composition or Domain revision
field is introduced. Existing pure values and Trip/Journey behavior are unchanged.

**Implemented boundary.** Each call retains one identified immutable view; invalid
requested endpoints fail before client I/O. The normalizer preserves complete
rides, verifies required references and affirmative continuity/change/connection
assertions, uses reviewed original occurrence indices for matches and requires
independent complete-ride evidence for unresolved output. It never crops a route
or follows a retired successor. Known qualified ridden times satisfy the inclusive
request bound and itinerary order before incomplete pairs are omitted; unused Trip
endpoints are excluded. Complete pairs remain provider schedule context only.

Each delimited alternative produces one candidate or one ordered omission. The
synthetic implementation reports its first deterministic failed check (one canonical
reason); it does not claim an exhaustive diagnosis of every defect in an alternative.
Malformed shared envelopes, all-omitted responses, genuine no-results and typed
client failures remain distinct. Calls run off the main actor with local batches;
checks surround client/view suspension, each alternative, inner normalization
loops and final return. The test checkpoint controls normalization cancellation
without sleeps. There are no detached production tasks or child I/O to orphan.

**New verification ownership (synthetic adapter subcases, not prior constructor reruns):**

| Cases | Bounded coverage / limitation |
|---|---|
| R01–R05, R07/R09/R11/R12/R29 | Direct/transfer/multiple-transfer/directional-walk/through-service admission, repeated original occurrences, supplied limited-stop/partial snapshots and movement-only line projection. Explicit snapshot fields compared. No real continuity or passenger-stop evidence asserted. |
| R06/R08/R10/R26/R27/R28 | Missing transfer or continuity evidence, ambiguous run/occurrence fallback, positive train contradictions, invalid/duplicate selection structure and dataset membership/service-type rejection. No name/time/shape-based train join. |
| R13a–c, R14–R19 | Requested endpoint failures before I/O; unsupported ridden interiors; insufficient snapshot with independent route fallback versus actual missing/conflicting evidence; exact canonical identity and required mappings. No successor following. |
| R20–R23 | Ordered mixed/all-omitted/genuine-empty results and malformed shared versus individually delimited input; canonical diagnostics contain no raw references. |
| R24/R25/R35 | Controlled cancellation before work, during view/client suspension, normalization and final checkpoint, plus cancelling one concurrent call without affecting another; raw client errors contained; explicit unsupported-intent failure. No networking or provider horizon verification. |
| R30/R31a–c/R32a–f | Already-qualified finite instants; incomplete pairs; all known ridden endpoints obey bound/order across nil contexts; equality and midnight crossing; unused endpoints excluded. Real timestamp qualification, bare extended-hour parsing and timetable/service dates remain unimplemented. |
| R33/R34 | Coherent-view failures and independent concurrent calls retaining separate immutable same-ID snapshots, with controlled reverse completion. Application supersession is excluded. |
| R36 | Canonical-only output with distinct invented X/Y identities; no real names/translations or localization UI claim. |

**Verification / self-review:** final focused Debug execution passed **28 test
functions / 33 executed cases**, zero failures, skips or runtime warnings, on
**iPhone 17 / iOS 26.5 Simulator**. The test action built the app and Live Activity
extension. A separate Release app/extension build passed to check exclusion of the
new Debug-only synthetic path. Later corrections touched Debug-only admission/test
code; the Release-visible source did not change after that build. Existing
canonical-model isolation and AppIntents metadata build warnings remain; this is
not a claim of warning-free builds.

Exact final commands (repository root):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/RouteAdmissionTests -only-testing:TSUGINOTests/RouteSearchingTests -resultBundlePath /private/tmp/tsugino-p3-admission-r5.xcresult > /private/tmp/tsugino-p3-admission-r5.log 2>&1
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd > /private/tmp/tsugino-p3-admission-release.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-p3-admission-r5.xcresult
git diff --check
```

Earlier attempts used the same focused test command with result/log suffixes
`r1`, `r2`, `r3`: `r1` failed compilation at a test barrier continuation inference
(then fixed with an explicit continuation type); `r2` passed 26 functions / 31
cases; `r3` passed 28 functions / 33 cases. A subsequent `r4` attempt replaced both
suite selectors with
`-only-testing:TSUGINOTests/RouteAdmissionTests/positiveTrainContradictionsAreNeverDowngraded`:
it selected **zero tests** and is not verification evidence despite Xcode success.
The final `r5` reran both focused suites after self-review corrected out-of-range
occurrence diagnostics, rejection of a known duplicate run even with ambiguous
occurrence fallback, and a test-barrier cancellation registration race.

Documentation/reference and scope checks plus `git diff --check` passed. Accepted
DEC-076, existing Domain values/Trip/Journey, historical planning/review records
and Phase 3 exit criteria are unchanged. **Independent review remains pending.**
No full-suite, prior constructor-suite rerun, physical-device or real-provider
verification occurred. No full Phase 3 case or exit completion is claimed. The
earlier 16-function/26-case constructor evidence remains historical and is not
counted as a new execution here.

**Independent review correction (2026-10-01).** Review requested changes for one
P2 defect: a reviewed complete L1-only Trip could be asserted as an L2 ride and
silently downgraded to unresolved when either occurrence was unavailable. Before
attachment/fallback, admission now rejects any asserted ride line absent from the
reviewed snapshot when both service-coverage flags are true, as
`inconsistentTrainEvidence`. This necessary compatibility check is not whole-run
line equality, a proof of correspondence, or an inferred occurrence. Partial
snapshots cannot exclude lines in unseen extensions. Existing exact ridden-line
validation still applies when both occurrence indices resolve.

Two added admission tests exercise missing-alighting and missing-boarding
regressions, plus positive partial-extension and repeated-occurrence/subinterval
controls. Existing R13c and R10 checks remain. The affected admission suite passed
**20 test functions / 25 executed cases**, zero failures, skips or runtime warnings,
on iPhone 17 / iOS 26.5 Simulator. Both regression directions and positive controls
passed; the Debug test action built the app with its extension dependency.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/RouteAdmissionTests -resultBundlePath /private/tmp/tsugino-p3-admission-fix-r2.xcresult > /private/tmp/tsugino-p3-admission-fix-r2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-p3-admission-fix-r2.xcresult
git diff --check
```

The initial sandboxed attempt used the same command with `fix-r1` paths and failed
at Simulator destination access (CoreSimulator unavailable, exit 70); no tests
executed. The authorized Simulator-access retry above passed. Unchanged async
search/cancellation tests retain their prior `r5` evidence; the prior Release
app/extension build remains applicable because this correction changes only
Debug-guarded implementation/tests and ROADMAP. No full-suite or Release rerun,
networking, private data or physical-device access occurred. Final diff/scope review
and `git diff --check` passed; only these three files changed during the correction.
Independent re-review of this correction and unresolved fallback remains pending;
the slice is not approved. DEC-076 and production behavior are unchanged.

**Follow-up contradiction correction (2026-10-01).** Focused re-review found the
whole-run line-set check above insufficient: missing correspondence could still
hide an absent endpoint or movement available only on the wrong side of a known
occurrence. That check is now replaced by an existential traversal check before
unresolved fallback, under the same reviewed-evidence gate. Fully resolved index,
anchor, line and dataset validation remains unchanged.

For an unresolved endpoint, consider every exact station occurrence in the
snapshot plus an unknown region before/after it only where the corresponding
origin/destination coverage flag permits one. A resolved occurrence remains fixed.
Consider only forward intervals; both unresolved endpoints may lie wholly in the
same unseen region. Clip the represented interval by movement, excluding boundary
contact. Its line sequence must occur contiguously and in order in the asserted
ride sequence, anchored at either end whose endpoint is represented. Unknown
extensions may add leading/trailing lines (or continue the boundary line), but
cannot erase or reorder known movement. Non-adjacent repeated lines are preserved.
If no possibility is compatible, reject `inconsistentTrainEvidence`; otherwise
retain unresolved output, still requiring independent complete-ride evidence.
Even a single compatible possibility never supplies a correspondence or returned
index. No Trip is extended, no stop is inferred, and partial absence alone does
not prove impossibility. This is contradiction detection, not evidence approval.

Three added tests cover absent alighting/boarding endpoints, movement before known
boarding/after known alighting, reverse reachability, wrong traversal order, all
four independent coverage combinations, and valid/noncollapsed L1–L2–L1 traversal.
Prior repeated-occurrence, partial-extension and valid subinterval controls remain.
Focused Debug admission verification passed **23 test functions / 28 executed
cases**, zero failures, skips or runtime warnings, on iPhone 17 / iOS 26.5 Simulator.
All new regressions and retained positive controls passed. One test action was
executed in this follow-up; it built the Debug app with its extension dependency.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/RouteAdmissionTests -resultBundlePath /private/tmp/tsugino-p3-fallback2-r1.xcresult > /private/tmp/tsugino-p3-fallback2-r1.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-p3-fallback2-r1.xcresult
git diff --check
```

Unchanged async/cancellation and Release evidence is reused, not rerun: the
correction is limited to Debug-guarded admission/tests and this record. Final diff,
preservation and `git diff --check` checks passed. The ten-file uncommitted slice
remains on the same HEAD/upstream; only those three files changed in this follow-up.
No essential semantic gap was identified for this bounded contradiction check;
unknown extensions remain uncertainty, not authenticated evidence. No production
or contract change is introduced. Independent re-review remains pending and the
slice is not approved.

**Final independent approval / publication authorization (2026-10-01).** The
initial review found incomplete correspondence could conceal a complete-run line
contradiction. The first correction checked absent whole-run lines; focused
re-review then found absent endpoints and wrong-side movement still concealed.
The second correction replaced that check with the possible-forward-traversal
algorithm recorded above. A fresh independent re-review of that algorithm and its
fallback interactions returned **approve: no material findings and no mandatory
outstanding verification check**. Earlier pending-review statements are historical
checkpoints; this is the current review status.

Final affected admission evidence is **23 functions / 28 executed cases**, zero
failures, skips or runtime warnings (`tsugino-p3-fallback2-r1.xcresult`). The earlier
`r5` execution of both synthetic suites (28 functions / 33 cases) remains separate
historical evidence; its unaffected async/cancellation coverage is reused. Debug
app/extension test-action evidence and the separate successful Release app/extension
build are reused as recorded above. No combined post-correction suite count is
claimed. No tests or builds were rerun during final review or publication.

Approval covers only the async boundary and corrected synthetic admission slice.
It establishes neither evidence authenticity, real-provider compatibility,
Application supersession nor Phase 3 exit readiness. Accepted DEC-076 and all
retained gates remain unchanged. The owner authorizes this review-completion
record and one commit/normal push of the reviewed ten-file slice on
`phase/03-route-search`; no main merge or further implementation is authorized.

**Retained limitations / next step.** Review flags, occurrence maps, connection
sets and qualification in the synthetic schema are stipulated fixtures, not an
authentication mechanism or provider adapter. P2-S9 remains mandatory before real
Trip consumption and P3-T1 real import. P3-T1 semantics, provider selection/evidence,
production registry/delivery, Q3/Q4, expansion and applicable publication/bundling
gates remain intact. No networking, acquisition, private evidence, translations,
caching/persistence, UI, Application supersession or Journey binding is included.
Independent review is complete under the bounded approval above. Next recommended
step is an existing-evidence-only provider suitability/gap assessment against
DEC-076, with any later access, selection or implementation separately authorized.
The publication authorization above permits only this slice's commit/normal push;
no main merge or further implementation is authorized.

### Provider evidence-gap assessment (2026-10-01)

Documentation-only [comparison against DEC-076](PHASE_3_PROVIDER_EVIDENCE_GAPS.md)
records DS-11–13 evidence and missing proof separately for route-only admission,
verified train attachment and later guidance. It uses repository records only;
historical ODPT observations do not prove commercial-provider compatibility.
The proposed next task is separately authorized official public-document research
before evaluation access, requests or provider contact. No candidate is selected,
price/rights refreshed, access authorized or decision changed. P2-S9 moves before
any proposed real canonical passenger-stop Trip consumer; it does not block this
assessment. P3-T1 and all applicable retained gates remain unchanged.

Subsequent owner-authorized **official public-document research (2026-10-01)** is
recorded in the same matrix with dated product-specific sources, published costs,
rights restrictions and remaining payload gaps. Earlier repository-only findings
above remain historical. Conditional evaluation order: Ekispert Standard with
licensed timetable access, then NAVITIME direct with the timetable option; no
provider is selected. Next proposed task is owner review of a rights/access
clarification packet before separately authorized contact or evaluation. No account,
API request, contact, terms acceptance, implementation or test/build occurred.
P2-S9 still precedes real canonical Trip consumption; all retained gates are unchanged.

### ODPT-first internal-search assessment (2026-10-01)

The owner now prioritizes ODPT-sourced data and internal-computation assessment;
commercial evaluation/contact is **paused**, superseding the preceding next-task
recommendation without erasing its dated research. [Feasibility matrix](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md)
and **Proposed DEC-077** record historical input coverage, transfer/through/time
gaps and the necessary DEC-076 contract review. ODPT-only feasibility remains
unresolved. Next proposed task: documentation-only input/consumer contract outline
and invented cases; no algorithm or engine implementation is authorized. S9 and
T1 designs can proceed independently, but real canonical Trip consumption requires
S9 and imported-schedule search requires accepted T1 data/semantics. DEC-004 remains
Provisional; Accepted DEC-076, launch scope, Phase 3 exit and retained gates remain
unchanged. No decision acceptance, acquisition, private access or test/build occurred.

### Bounded DEC-077 acceptance and Proposed consumer outline (2026-10-01)

The owner accepted **only DEC-077's ODPT-first evaluation priority and commercial
pause**. The preceding Proposed record is historical; no engine, algorithm,
timetable semantics, ODPT-only feasibility, launch or exit amendment is accepted.
The [internal-routing input/consumer outline](PHASE_3_INTERNAL_ROUTING_CONTRACT_OUTLINE.md)
remains **Proposed**: input/gate boundaries, precise DEC-076 amendment options and
three wholly invented direct/walking-transfer/through-service cases. DEC-076 and
ARCHITECTURE remain unchanged. Next recommended task is a separately authorized,
documentation-only P3-T1 producer-output proposal with invented temporal cases;
real Trip/time consumers still wait for S9/T1 acceptance and all applicable gates.
No research, acquisition, private access, implementation or tests/builds occurred.

### Proposed P3-T1 producer output (2026-10-01)

[Timetable producer-output proposal](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md) and
**Proposed DEC-078** separate recurring Trip identity from dated scheduled facts,
source interpretation from validation, and producer validity from search policy.
Nine invented cases expose calendar exceptions, extended hours, repeated visits,
multiple dates, missing/estimated times, chronology and unverified continuity.
O1–O6 remain owner decisions; no new semantics, consumer amendment or engine is
accepted. Next task recommended: focused documentation review before acceptance
or separately authorized DEC-076 amendment drafting. P2-S9 precedes real Trip
consumption/real T1 import; T1 semantic acceptance and validated output precede
imported-time consumers. DEC-077 priority/commercial pause, existing proposals,
launch/exit and all applicable rights/delivery/expansion gates remain unchanged.

### Proposed producer refinement and consumer amendment (2026-10-01)

Independent review found no material blocker in the original DEC-078 proposal for
owner consideration only. DEC-078 remains **Proposed**. Its
[producer document](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md) now specifies bounded
index/event diagnostics, activation-first inactive/event precedence and T1-10/11
revision/precedence cases, preserving the original nine cases.
[Proposed DEC-079](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md) separately drafts
DEC-076 amendments: IR-E1 exact matched timetable contexts, generated accounting,
scoped results/completeness failures, connection allowances and movement evidence.
C1–C6 and DEC-078 O1–O6 require owner review; no accepted contract is amended.
Next task: focused documentation review of these refinements and I1–I7 before
acceptance preparation. Horizon/profile, algorithm and implementation remain deferred.
No tests/builds, research or acquisition occurred. S9 before real Trip consumption/
T1 import, separate T1 acceptance and all applicable retained gates remain unchanged.

### Owner acceptance preparation — DEC-078/079 still Proposed (2026-10-01)

Latest independent documentation review found no material blockers for owner
consideration only. Separate final packages now live in
[producer §8](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md) and
[consumer §8](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md); no new decision layer.
Consumer clarifications retain unscoped all-rejected failures (never no-route proof)
and define ordered preflight with observed cancellation precedence and no lower-fault
probing. Accepted DEC-076/077 and ARCHITECTURE remain unchanged.
Next owner action: separately consider DEC-078 O1–O6 and conditional DEC-079 C1–C6.
After acceptance and separate scope authorization, recommend producer pure values/
local validation with invented already-qualified facts. No calendar interpreter,
real import or engine is required for that slice. Engine horizon/profile,
enumeration/completeness, connection policies, ownership and real evidence remain
separate prerequisites. No tests/builds or acquisition occurred; all retained gates,
launch scope and Phase 3 exit are unchanged.


### Accepted DEC-078/079 and bounded producer values (2026-10-01 Asia/Seoul)

The owner accepted DEC-078 O1–O6 and DEC-079 C1–C6 as prepared, including unscoped
failures, scoped internal success and deterministic internal preflight. DEC-076 is
partially superseded for internal consumption; its historical text and external
semantics are preserved. DEC-078 semantics are accepted, but only the following
local value slice is implemented. DEC-079 has **no implementation** in this slice.
Earlier Proposed/preparation entries above are dated history, not current status.

**Scope lock and ownership:** five new `Domain/Timetable` files plus
`TSUGINOTests/TimetableValueTests.swift`; acceptance/current-truth docs only otherwise.
No existing Trip/Journey/routing source, project settings, dependencies or composition
changes. `TimetableOccurrenceAddress.swift` defines caller-supplied opaque UUID view
identity, preserved nonblank service-date label and view/Trip/date address. This is
not a registry, calendar validator or authentication of one-execution-per-date.
`TimetableOccurrenceBinding.swift` retains an existing exact Trip; its explicit
comparison includes ID, stops, lines, both coverage flags and service types.
`TimetableTime.swift` provides a finite wrapper so exact/estimated enum payloads
cannot bypass finite validation; missing remains distinct. Eligibility is tri-state.
`TimetableDiagnostic.swift` validates bounded reason/location shapes; location kind
may be absent for a whole-visit fault. `TimetableOccurrenceFacts.swift` requires one
original-index visit per represented stop, each with the same dated binding/snapshot,
and validates all exact arrivals/departures in order across missing/estimated gaps.
No memberwise, mutation, Codable or snapshot equality/hash path bypasses these checks.

**Verification:** final focused evidence recorded below. An initial sandboxed
Simulator inventory attempt failed CoreSimulator access; it was not test evidence.
The first focused build (`r1`) failed before execution on nested Swift Testing
`#require` macros in new fixtures; those were flattened. `r2` passed 16 functions /
21 executed cases, zero failures/skips/runtime warnings. Self-review strengthened
T1-10's constructor regression to exercise inserted-stop mismatch with both identical
and different view IDs, preventing the view check from masking snapshot checking.
The final `r3` run follows that test-only change; counts are not added across runs.

Final `r3`: **16 test functions / 21 executed cases passed**, zero failures, skips
or runtime warnings, iPhone 17 / iOS 26.5 Simulator (arm64), Xcode's iOS Simulator
27.0 SDK. Debug app/extension build succeeded through the test action. `r1`/`r2`
logs include compiler isolation warnings in unchanged canonical/test code; no new
timetable source warning was reported. Final incremental `r3` reports only the
AppIntents metadata-extraction warning (no AppIntents dependency). This is not a
warning-free broad-build claim. Result/log artifacts are local `/private/tmp` evidence,
not repository fixtures:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/TimetableValueTests -resultBundlePath /private/tmp/tsugino-p3-timetable-values-r3.xcresult > /private/tmp/tsugino-p3-timetable-values-r3.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-p3-timetable-values-r3.xcresult
```

| Specification subcases covered | Limit of coverage |
|---|---|
| T1-01, T1-05 | Ordinary/repeated original visits and explicit snapshot-content preservation; no activation or source occurrence proof |
| T1-06, T1-10 | Different dates/views, same-ID inserted stop, same-view stop/line/coverage/service-type changes rejected; no production revision registry |
| T1-07 | Missing and estimated values remain distinct, even estimates outside the exact envelope; no interpolation or estimate-consumer policy |
| T1-08 | Nonfinite payload rejection, within-visit ordering, equality and exact chronology across missing/estimated gaps; no source clock parsing |
| Eligibility/coverage/diagnostics | All eligibility states, all four structural coverage shapes, invalid/extreme indices, duplicate/missing/reordered slots, bounded diagnostic shape/order, Sendable task transfer |

T1-02/03/04/09/11 activation, conversion and through-evidence behavior is **not tested
or implemented**. No complete T1 case/feed compatibility claim follows from these
constructor subcases. `r2`/`r3` test actions compile Debug app and Live Activity
extension. No full suite, separate Release build or physical device work is claimed.
Unchanged routing/async evidence remains historical and was not rerun. There is no
Debug-only path or Release-excluded declaration in these new Domain values.

**Self-review:** verified immutable/failable construction, wrapper-only finite enum
payloads, index comparisons before access, binding-before-chronology precedence,
first descending exact-event diagnostics, and all snapshot fields explicitly checked.
No material local defect remains identified. Construction does not authenticate
view identity, calendar activation, correspondence, eligibility evidence or rights.
Snapshot comparison is bounded by supplied values; no performance claim or index is
introduced. Concrete future profiles must canonicalize operating-day labels. The
local facts deliberately contain no active/inactive producer outcome or profile
interpreter. Type shape/finite checks cannot satisfy accepted producer evidence.

**Independent review complete — approved (2026-10-01 Asia/Seoul).** The read-only
review found no material findings or mandatory outstanding checks. The reviewer had
no prior exposure to this implementation; creating a new reviewer context was not
possible because the thread limit was reached. The review assessed actual code,
tests and accepted contracts rather than treating the author's self-review as proof.
Optional segment-range-only revision and qualified-midnight tests remain nonblocking
observations; neither is added for publication.

The reviewer assessed the saved final `r3` evidence: 16 functions / 21 cases passed,
zero failures/skips/runtime warnings, with Debug app/Live Activity extension
dependencies built. The AppIntents metadata warning remains recorded above. No
tests/builds were rerun during review or publication. Approval covers pure values
and local validation only, not full producer operation, evidence authentication,
ODPT compatibility, DEC-079 implementation, engine readiness or Phase 3 exit.
The owner authorizes publication of the reviewed fourteen-file documentation/value
slice, including this approval record, on `phase/03-route-search`; no main merge
or next-slice work is authorized.

P2-S9 precedes real canonical Trip consumption and real T1 import. Feed-specific
interpretation, validated import and correspondence remain separate. Engine horizon,
enumeration/pruning/completeness, connection policies and component ownership remain
undecided. Registry, Q3/Q4, delivery, publication/bundling and expansion gates, launch
scope and Phase 3 exit are unchanged; no real artifact or provider acquisition occurred.


### Next DEC-079 slice assessment (2026-10-01 Asia/Seoul)

Assessment only; no implementation authorization or new semantic acceptance.
Verified clean starting branch `phase/03-route-search`, HEAD/fetched upstream
`7d0a045d033e6aee66326cda39b41df5e3cc4b88`; main remains
`e8a463d51f14b3cb1027960c63244b694579a71b`.

**Recommended smallest slice: timetable context plus local route-value integration.**
Accepted DEC-079 C1/C6 and [consumer amendment §2](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md)
provide sufficient semantics; no new owner policy choice is needed before this
slice, only separate implementation authorization. Use existing DEC-078 facts;
engine/profile decisions do not block this work.

- Add `Domain/Routing/TimetableRideContext.swift`: immutable nonisolated Sendable
  context constructed failably from `TrainCandidate` and `TimetableOccurrenceFacts`.
  Retain the exact occurrence binding/address and original ridden indices; derive
  departure only from boarding departure and arrival only from alighting arrival.
  Require exact states at both endpoints, full snapshot-content compatibility and
  inclusive finite ordering. Never accept independently supplied replacement dates,
  indices or timestamps, promote estimates, copy counterparts or crop a snapshot.
  Reuse `TimetableOccurrenceBinding.matches` via a binding for the supplied train;
  no Trip equality shortcut, persistent identity, Codable or snapshot equality/hash.
- Add `Domain/Routing/RouteScheduledContext.swift` with distinct provider/timetable
  branches and shared departure/arrival access for chronology. Preserve
  `ProviderScheduledContext` unchanged. Update `RouteRailProposal.swift` to use the
  union and failable association validation: timetable context requires matched
  travel with the exact retained snapshot and identical original ridden indices.
  The occurrence's date/view travels with the context, never inferred from TrainCandidate
  (which has neither). A single context cannot authenticate a coherent result view.
- Update `RouteCandidate.swift` chronology to compare retained pairs from either
  branch across nil contexts/walks; preserve all structural and duplicate-TripID
  rules, including different dates of one template. Mixed-branch constructor checks
  prove arithmetic only, not authorization for mixed-source search composition.
- Migrate provider construction explicitly to `.provider` and handle failable rail
  construction in `Data/Routing/SyntheticRouteAdmission.swift`; update affected
  `RoutingValueTests.swift` helpers/call sites. `RouteScheduleAdmission` continues
  producing provider contexts and checking incomplete provider inputs unchanged.
  Provider nil-context, unresolved-travel and failure behavior must remain intact;
  admission/async tests provide regression coverage, not new internal admission.

Proposed verification boundary for that future implementation: new
`TSUGINOTests/TimetableRideContextTests.swift`, affected routing-value tests and
focused provider-admission/async regressions for migrated call sites; reuse unchanged
producer evidence except where a shared binding change justifies focused reruns.
Synthetic constructor subcases cover ordinary/repeated original visits, every
snapshot field (including segment ranges/optional service types/coverage), inserted
same-ID stops, different dates/views retained without relabeling, wrong-train/index
reattachment, unresolved travel rejection, missing/estimated required endpoints,
valid missing unused counterparts, equality/qualified midnight and chronology across
nil/walking/context-origin boundaries. Verify duplicate TripIDs, extreme-index safety,
immutable/Sendable construction and provider-only behavior. None is full I1–I7,
producer activation, transfer feasibility or feed-compatibility coverage.

**Ready but separate:** DEC-079 §3/C2–C3 permits `searchIncomplete` and appending
`unverifiedEligibility`, `infeasibleConnection`, `insufficientScheduledEvidence`
in that order in `RouteSearchResult.swift`. Existing batch/rejection constructors
already enforce numeric accounting and unscoped all-rejected payloads. A later
small vocabulary slice can test reason ordering/uniqueness, old ordering stability,
source-position reconstruction and contiguous rejection indices without a generator.
Do not add unused vocabulary to the context slice or claim it implements preflight,
completion proof or one-handoff/one-outcome runtime behavior.

**Scoped success remains deferred:** §4/C4 defines required view/profile/bounds and
coverage-reference concepts, but not the caller-resolvable profile/constraint
representation, boundary subjects (boarding/arrival/both), inclusivity or linkage
between that definition and effective bounds. The next scope-design task must specify
that immutable typed definition or resolvable reference contract and local checks;
an opaque label alone cannot describe the supported search domain. This need not
choose a numeric default, algorithm or complete engine. `RouteSearchResult`/search
success remains external-shaped until that work; do not emit internal alternatives
through unscoped success as a substitute.

Local extraction/association is not Data admission. Data must still establish active
calendars, one-execution correspondence, qualified facts, coherent retained views,
allowed eligibility, supported coverage, continuity and directional connections with
justified total allowances. Request-relative checks, ordered preflight/cancellation,
generation/accounting evidence, scope/completeness and actual search stay excluded.
No calendars/conversion, import, persistence, Journey/Application/UI binding or
composition changes. Engine prerequisites remain finite profile/horizon, date
enumeration/pruning/order/completeness, connection policies and component ownership.
P2-S9 precedes real Trip consumption/real T1 import; feed-specific interpretation,
validated import and all registry/publication/translation/delivery/bundling/expansion
gates remain. Commercial evaluation stays paused; launch scope and Phase 3 exit are
unchanged. This assessment ran no tests/builds and acquired no data.


### DEC-079 context-only implementation (2026-10-01 Asia/Seoul)

Owner-authorized execution of the preceding plan; that assessment is preserved.
Baseline/fetched upstream remains `7d0a045d033e6aee66326cda39b41df5e3cc4b88` on
`phase/03-route-search`; only the preceding ROADMAP plan was modified at start.
No branch, decision acceptance, commit or publication is part of this slice.

**Implemented:** `Domain/Routing/TimetableRideContext.swift` retains an exact
TimetableOccurrenceBinding and original ridden indices, with exact departure/arrival
extracted from whole locally validated occurrence facts. Binding comparison precedes
indexing and includes every Trip field; no independent timestamp/address setter or
snapshot equality/hash/Codable is added. Required missing/estimated endpoints fail;
unused counterparts may remain missing. `RouteScheduledContext.swift` adds explicit
provider/timetable branches. RouteRailProposal is now failable and requires a matching
TrainCandidate for timetable context; original indices and full snapshot must match.
RouteCandidate uses the union's instant projections for its existing inclusive
chronology across nil contexts/walks, retaining duplicate-TripID and structural rules.
SyntheticRouteAdmission mechanically wraps provider context and handles construction
failure. ProviderScheduledContext, RouteScheduleAdmission, TrainCandidate, Trip and
the producer values remain byte-unchanged. Existing provider behavior is preserved.

A TrainCandidate carries no independent service date/view: the context preserves its
own binding, while Data must validate candidate/result-wide coherent view association
and authenticated producer output. Local construction does not claim activation,
eligibility, one-execution correspondence, source qualification, continuity or transfer
feasibility. Mixed-origin arithmetic tests are not mixed-source search authorization.
There is no internal search/result production, scope, new error vocabulary, preflight,
request admission, calendar conversion, connection allowance, graph/engine, persistence
or Application/Journey/UI/composition implementation.

**Focused verification:** first attempt `context-r1` failed at test compilation
because a new fixture used an optional service-type array; changed it to the existing
Trip contract's explicit array (`[]` for unknown). No tests executed in that attempt.
Corrected `context-r2` passed **59 functions / 78 executed cases**, zero failures,
skips or runtime warnings, iPhone 17 / iOS 26.5 Simulator (arm64). Counts by suite:

| Suite | Functions | Executed cases | Coverage boundary |
|---|---:|---:|---|
| TimetableRideContextTests | 10 | 14 | I1/I5/I6 local association/extraction subcases; repeated indices, exact snapshot fields including segment-range-only revisions, all four coverage shapes, date/view preservation, wrong index/unresolved attachment, missing/estimated rejection, missing counterparts, equality/qualified midnight, cross-origin/gap chronology and Sendable transfer |
| RoutingValueTests | 16 | 26 | Existing rail/walk structure, movement clipping/non-adjacent lines, invalid/extreme indices, duplicate TripIDs, provider pairs and accounting under migrated constructors |
| RouteAdmissionTests | 23 | 28 | Existing synthetic provider mapping/evidence, fallback contradictions, time admission and omissions preserved |
| RouteSearchingTests | 10 | 10 | Existing synthetic provider errors, independent concurrent calls and owned cancellation preserved |

Debug test action built app and Live Activity extension dependencies. The build
reported existing isolation warnings in unchanged railway models/capability and
station/line/service tests, and the AppIntents metadata-extraction warning (no
AppIntents dependency); no new context source/test warning was identified. This is
not a warning-free full-build claim. The result summary initially needed escalation
for xcresulttool's report cache; the successful read confirms the counts above.
Saved evidence (outside Git): `/private/tmp/tsugino-p3-context-r2.xcresult` and
`/private/tmp/tsugino-p3-context-r2.log` (failed compile log uses `r1`). Command:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/TimetableRideContextTests -only-testing:TSUGINOTests/RoutingValueTests -only-testing:TSUGINOTests/RouteAdmissionTests -only-testing:TSUGINOTests/RouteSearchingTests -resultBundlePath /private/tmp/tsugino-p3-context-r2.xcresult
```

No full suite, Release build, physical-device or producer-suite rerun. Prior DEC-078
producer evidence is reused for its unchanged constructors; these tests do not claim
full I1–I7, timetable activation, evidence authentication or feed compatibility.

**Self-review:** no material defect identified in immutable/failable construction,
exact binding before indexing, required endpoint extraction, matched-only reattachment,
chronology, original line/index preservation or provider migration. Existing snapshot
comparison is reused unchanged. Per-ride validation is not candidate-wide Data proof;
no additional view/profile policy was invented. Scope and documentation/diff checks
remain bounded to the nine-file inventory, including the preserved ROADMAP plan.
**Independent review complete — approve the bounded context-only slice.** A fresh
reviewer context was successfully created with no prior exposure to this implementation
and without inheriting author self-review conclusions. It inspected actual code and
accepted contracts. No material findings or mandatory outstanding checks remain.
Its optional current-status documentation observation is resolved for publication by
status-only updates to DECISIONS and the consumer amendment header; historical bodies
and accepted semantics are preserved. Saved `context-r2` evidence was independently
confirmed: 59 functions / 78 cases passed, zero failures/skips/runtime warnings, with
Debug app/extension dependencies built. Existing unrelated isolation and AppIntents
warnings remain recorded above. No tests/builds were rerun during review/publication.
Approval covers context construction, branch separation, exact rail attachment and
local chronology only, not Data authentication/admission, real provider/ODPT
compatibility, internal search readiness or Phase 3 exit. The owner authorizes only
the eleven-file slice/status publication on `phase/03-route-search`; no merge or
next-slice implementation is authorized.

P2-S9 before real canonical Trip consumption/import, feed-specific interpretation and
validated import, registry/publication/translation/delivery/bundling/expansion gates
remain. Scoped success/profile design, failure additions, engine/completeness and
connection policies stay deferred. Launch scope and Phase 3 exit are unchanged.


### Proposed internal-search profile/scope contract (2026-10-01)

Documentation-only **Proposed DEC-080** and [consumer amendment §9](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#9-internal-search-profile-and-effective-scope--proposed-dec-080)
separate embedded immutable profile definitions, request/view-bound effective scopes,
coverage evidence, completion, admission accounting and presentation. Recommend
inclusive request lower/final-arrival bounds, parameterized horizon/ride limits and
explicit canonical domain/policy resolution; no production numbers or algorithm.
Eight invented cases include midnight service dates, missing coverage with valid
routes, budget cutoff and display truncation. Parameterized local values can be
accepted independently of the separately Proposed enumeration objective/defaults.
Next task: focused documentation review, then owner consideration; no implementation
or acceptance occurs here. DEC-079 remains context-only implemented. P2-S9, interpreted
validated import and all applicable retained gates/launch/Phase 3 exit remain unchanged.
Verified clean starting branch `phase/03-route-search`, fetched HEAD/upstream
`10a0c372c22d1203c1eac7a4b41e653488d5f1cd`; main unchanged at
`e8a463d51f14b3cb1027960c63244b694579a71b`. No research/tests/builds or acquisition.


### DEC-080 bounded acceptance preparation (2026-10-02 Asia/Seoul)

Independent documentation review found no material findings; DEC-080 remains Proposed.
[Consumer §9.9](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#99-bounded-owner-acceptance-package--proposed-2026-10-02-asiaseoul)
selects exact V1–V7 paragraphs for P1–P4/P6 local value contracts and separates runtime
obligations. P5, production profiles/defaults, enumeration/completeness, connection
resolution/policies, algorithms and engine ownership remain deferred. S9/S10 clarify
non-advancing floating-point bounds and complete-negative versus unknown connectivity.
Next: owner consideration only; after acceptance and separate authorization, A is pure
profile/scope values and B is locally validated scoped success. No tests/builds, runtime
search, acceptance or code changes. P2-S9, interpreted/validated import and all retained
gates/launch/Phase 3 exit remain unchanged. Refs verified locally (no fetch required),
HEAD/upstream `10a0c372c22d1203c1eac7a4b41e653488d5f1cd`, 0 ahead/behind.


### DEC-080 bounded acceptance and slice A — 2026-10-02 Asia/Seoul

Owner accepted precisely consumer §9.9 V1–V7 (P1–P4/P6); DECISIONS records the
paragraph-level boundary. P5 and every explicit non-selected policy remain
Proposed/undecided. Only slice A was authorized. Prior proposal/preparation entries
above remain historical; they do not override this bounded acceptance.

Implemented in three Domain/Routing files: `InternalSearchProfileIdentity.swift`
(including versioned policy reference), `InternalSearchProfileDefinition.swift`,
and `InternalSearchScope.swift`. Full immutable canonical domain sets, positive
finite duration/ride cap, supplied semantic key/revision and policy references are
preserved. Scope retains original request, full profile and view; validates endpoint
membership and inclusive exact finite advancing L/U. Rounded/unrepresentable sums,
including positive-duration U==L, fail. Explicit full-definition comparison detects
conflicts only among supplied values, not global registry history. No persistent
identity, serialization, policy resolver or mutable shared state was introduced.

`InternalSearchScopeTests.swift`: **11 functions / 18 executed cases passed**, zero
failures/skips/runtime warnings on iPhone 17 / iOS 26.5 Simulator. Focused Debug
command selected only `TSUGINOTests/InternalSearchScopeTests`; app and Live Activity
extension dependencies built. Saved result:
`/private/tmp/tsugino-p3-scope-a-r3.xcresult`; log:
`/private/tmp/tsugino-p3-scope-a-r3.log`.
The sandboxed r1 attempt failed CoreSimulator access (no test evidence); r2 failed
new test macro compilation (nested require/missing inner try), corrected before r3.
Unrelated existing actor-isolation warnings and AppIntents metadata-skipped warning
were observed; no new scope-source/test warning. No full-suite or Release run.
Existing routing/timetable/context evidence is retained, not claimed rerun.

Constructor subcases cover full preservation, independently empty domain sets,
nonfinite/nonpositive duration, invalid/extreme ride caps, wrong request membership,
inclusive boundaries, overflow, no advance, rounded advance, exact cross-zero and
subnormal bounds, complete supplied-definition comparison, revision/key differences,
and transfer of independent values across tasks. These exercise local portions of
V1–V4 and S9, not full DEC-080 or producer/search compatibility. V5 scoped success
(slice B), failure additions, coverage/completion/accounting execution, policy
resolution, service-date enumeration, connections and engine remain unimplemented.
No constructor authenticates source correspondence, membership, calendar activation,
view coherence or required coverage. No production default/domain was selected.

Self-review found no remaining material issue in this bounded implementation;
**independent implementation review is pending**. Review should assess constructor
bypasses, exact arithmetic, immutable constraint/identity semantics and acceptance
bookkeeping, without extending to slice B or runtime policies. Documentation paths,
acceptance selectors and unchanged accepted history were checked; `git diff --check`
passed. Original three-document work is retained; ARCHITECTURE was minimally updated.
No branch creation, fetch (refs locally recorded), commit, push or merge. P2-S9 before
real Trip consumption/import, feed-specific interpretation/validated import and all
rights/registry/publication/translation/delivery/bundling/expansion gates, launch and
Phase 3 exit requirements remain unchanged.

### DEC-080 slice A independent approval — 2026-10-02 Asia/Seoul

A fresh reviewer context with no prior exposure inspected the actual contracts,
source, tests and acceptance records: **approve slice A; no material findings or
mandatory outstanding checks**. Approval covers local profile/scope values only.
V1–V7 / P1–P4/P6 acceptance is unchanged; P5 remains Proposed. Slice B is accepted
but unimplemented and is not authorized by this publication.

The reviewer confirmed rounded-sum rejection implements V3's exact/no-rounding
requirement. Optional policy-key variation and same-time/different-endpoint tests
are nonblocking observations; no optional changes were made. Independent inspection
confirmed r3's 11 functions / 18 executed cases, zero failures/skips/runtime warnings,
and Debug app/extension dependencies. Earlier r1 access and r2 compilation failures,
isolation/AppIntents build warnings and their evidence distinctions remain as recorded.
No tests/builds were rerun during review or publication. SHA-256 comparison against
the independent-review manifest confirmed unchanged source/test bytes before staging.

Publication checks include a fresh origin fetch, exact eight-file inventory,
documentation/reference consistency, staged-diff inspection and `git diff --check`.
No credentials, private source artifacts, real payload fixtures or generated build
files are included. Coverage/policy resolution, runtime scoped results, engine and
real-data/ODPT compatibility remain excluded; all P2-S9/import, rights/delivery and
Phase 3 exit gates remain unchanged.

### DEC-080 slice B local scoped success — 2026-10-02 Asia/Seoul

Owner authorized slice B under already accepted V5 / §9.9, without accepting P5 or
any runtime policy. Scope lock: one new Domain/Routing payload, one result enum case,
focused invented-fixture tests and current-truth documentation only. Verified clean
`phase/03-route-search`, HEAD/upstream `bf268e6ad8cd39bb945a6b48ff7002e91fe5cfb2`,
0 ahead/behind; refs locally recorded (rules require no fetch). Main unchanged at
`e8a463d51f14b3cb1027960c63244b694579a71b`. No unrelated work present.

`InternalSearchSuccess.swift` supplies an immutable, nonisolated Sendable payload
with full validated scope and noResults/alternatives outcome. Its sole failable
constructor validates all candidates before retaining the entire batch: requested
endpoints, rail cap, matched timetable snapshot/original-index association and view,
all ridden passenger stops, movement-bearing lines/TripIDs, and inclusive L/U endpoints.
Unused Trip portions stay intact without being forced into the scope. Existing
RouteCandidate/RouteSearchBatch enforce structure, chronology, duplicate TripIDs and
omission accounting; no filtering/reordering/truncation occurs. `RouteSearchResult`
adds only `internalSuccess(InternalSearchSuccess)`. No existing exhaustive switch
required migration; provider/admission/async code and failure vocabulary are unchanged.
No normal enum/memberwise/mutation path bypasses payload validation. Neither scoped
noResults nor a batch proves coverage, policy resolution or completed execution.

Focused Debug verification on iPhone 17 / iOS 26.5 Simulator:

| Suite | Functions | Executed cases | Result |
|---|---:|---:|---|
| InternalSearchSuccessTests | 13 | 15 | Passed |
| RoutingValueTests | 16 | 26 | Passed |
| TimetableRideContextTests | 10 | 14 | Passed |
| RouteAdmissionTests | 23 | 28 | Passed |
| RouteSearchingTests | 10 | 10 | Passed |
| Total | 72 | 93 | Zero failures/skips/runtime warnings |

Saved successful evidence: `/private/tmp/tsugino-p3-scope-b-r2.xcresult`,
`/private/tmp/tsugino-p3-scope-b-r2.log`; xcresult summary and per-suite results inspected.
The Debug test action built app and Live Activity extension dependencies. Existing
actor-isolation warnings in unrelated models/tests and AppIntents metadata-skipped
warning remain; no new payload/test warning was reported. r1 stopped at compilation
because the new fixture helper nested Swift Testing require macros; corrected before
r2. r1 is not passing test evidence. No full-suite or separate Release build; unaffected
profile/scope/timetable evidence is retained, not claimed rerun.

New tests cover scoped-empty structure, exact scope/accounting preservation, omission
positions and full candidate retention despite a smaller display subset, wrong
endpoints/interior station/line/Trip domain, wrong view, nil/provider/unresolved context,
snapshot/index attachment rejection, repeated-stop subinterval preservation, unused
snapshot/boundary-only line exclusions, through-service/nonadjacent repeated lines,
ride caps/walking transfer, mixed opaque date labels, inclusive/outside bounds,
chronology across nil gaps, duplicate TripIDs across dates and invalid batch accounting.
These are constructor subcases, not complete DEC-080 runtime specification coverage,
authenticated continuity or connection feasibility. No source calendar/date is inferred.

Self-review found no remaining material issue: custom initializer suppresses synthesized
payload construction; all stored values are immutable; slice A and existing canonical
validators are reused; indexing is restricted to validated original intervals. New
branch has no runtime producer or production composition. Documentation references
and `git diff --check` pass. **Independent slice B implementation review pending**:
review payload bypasses, scope association/ridden-domain boundaries, whole-batch
preservation, external regressions and implementation-status bookkeeping.

P5 stays Proposed. Runtime scoped-result emission, failure additions, coverage proof,
policy resolution, service-date enumeration, connection admission/allowances,
pruning/order/completeness, algorithms/ownership, calendars/conversion, adapters/import,
persistence and Journey/UI remain excluded. P2-S9 precedes real Trip consumption and
real P3-T1 import; feed-specific interpretation/validated import and all applicable
rights/registry/publication/translation/delivery/bundling/expansion gates remain.
No engine/ODPT/launch/Phase 3 exit readiness, commit, push or merge is claimed.

### DEC-080 slice B independent approval — 2026-10-02 Asia/Seoul

A fresh reviewer with no prior exposure assessed the actual code/contracts and
reported **approve local slice B; no material findings or mandatory outstanding
verification**. The preceding pending-review entry is historical. Approval covers
scope retention, validated candidate association, ridden-domain boundaries, preserved
whole-batch accounting and unchanged external behavior, not runtime authority.

Optional mixed valid/invalid batch and excluded interior-line regression cases are
nonblocking observations; no optional tests or implementation changes were added.
Independent inspection confirmed the saved r2 evidence: 72 functions / 93 executed
cases passed, zero failures/skips/runtime warnings, with Debug app/extension
dependencies. The initial r1 compilation failure and existing isolation/AppIntents
warnings remain separately recorded above. No tests/builds rerun for review or
publication. SHA-256 verification against the independent-review manifest confirmed
unchanged source/test bytes; only approval-status documentation changed afterward.

Publication checks: fresh origin fetch, expected seven-file inventory, documentation
references/status, exact staged inventory, credential/artifact exclusion and
`git diff --check`. P5 remains Proposed; constructors establish neither authoritative
coverage nor completed search. Runtime search, policy resolution, engine readiness,
ODPT compatibility, P2-S9/import and all retained rights/delivery/Phase 3 exit gates
remain separate. No further implementation or main merge is authorized.


### Next internal-routing dependency assessment — Proposed plan, 2026-10-02 Asia/Seoul

Scope lock: assessment and this ROADMAP entry only. Published DEC-080 A/B values
can validate a scoped answer but cannot generate routes or establish that a search
completed. The existing DEBUG SyntheticRouteSearcher admits supplied external-shaped
alternatives; it is not internal route generation. Reuse RouteSearching, canonical
Trip/TrainCandidate and dated facts, timetable context, profile/scope, candidate/batch/
omission and InternalSearchSuccess values. No accepted contract or implemented
behavior changes here. P5 is still Proposed.

Authority: [consumer §§2–5, §9.5 and exact §9.9 selection](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md),
DEC-076/078/079/080 in [DECISIONS](DECISIONS.md), [ARCHITECTURE §10](ARCHITECTURE.md#10-route-search-architecture)
and the retained [feasibility evidence matrix](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md#existing-evidence-matrix).
Historical dataset observations are not newly verified evidence.

| Dependency class | Existing support / remaining boundary |
|---|---|
| Accepted, implementable without a new semantic choice | DEC-079 appends unverifiedEligibility, infeasibleConnection, insufficientScheduledEvidence in that order; adds searchIncomplete. Typed bounded reasons, unscoped failures, cancellation precedence, ordered configuration → view → endpoints → intent → coverage preflight, one-handoff/one-outcome accounting and no partial success are accepted. Vocabulary/local accounting checks can be implemented independently; actual preflight needs the input/configuration representation below |
| Genuine design decisions before generated synthetic success | Required input inventory/coverage representation; exhaustive dated-occurrence availability; resolved connection/eligibility/continuity inputs; objective/distinctness/order/pruning/completion; and concrete synthetic component ownership/composition. Existing UUIDs, exact instants and constructors settle none of these |
| Evidence needed for real use, not invented-data design | P2-S9 passenger-stop order, coverage, original repeated occurrences and joins; feed-specific calendar/service-date/extended-hour interpretation and validated P3-T1 import; current activation, eligibility, through/change correspondence, directional connection inventory/allowances, revision compatibility and freshness |
| Retained integration/delivery gates | Production registry/ID adoption, source/publication/translation/derived-use rights, delivery/cache/bundling and expansion evidence remain applicable to their deliverables. Synthetic tests cannot discharge them or authorize launch composition; commercial evaluation/contact stays paused under DEC-077 |

**Smallest next deliverable:** draft one Proposed synthetic input-and-execution
contract in the existing consumer document, with a decision record only after
verifying its identifier then. Do not accept P5 by reference. Seek a bounded synthetic
execution contract; defer production defaults/domain, source interpretation, real
engine adoption and deployment. Resolve the following together, rather than producing
another isolated result wrapper:

1. **Finite authoritative fixture view (proposed).** Declare the required canonical
   domain and covered event window independently of routes found. Supply exact snapshot
   bindings, finite dated-occurrence inventory, explicit active/inactive/unavailable
   statuses and qualified occurrence facts. Define which source-independent facts are
   required for each represented boarding/alighting possibility. Missing required facts
   or incompatible revisions mean dataUnavailable, even alongside a good route; only
   evidenced out-of-domain or conclusively irrelevant facts may be excluded. Define
   finite directional connection inventory keys (alight/board occurrences or their
   explicitly resolved applicability) and complete-present/complete-absent/unknown
   meanings. An absent entry in a sparse map is unknown, not proof of no connection.
   A fixture's explicit closed world is a synthetic premise, not a production boolean
   or certificate that authenticates coverage.
2. **Dates and operational facts (proposed representation).** Fixtures list every
   dated execution that can contribute ridden events in [L,U], including explicitly
   identified previous-service-day occurrences. Use supplied absolute instants and
   opaque labels; no calendar parser, inferred lookback or conversion. Define how the
   inventory establishes that no omitted date can contribute. Preserve one execution
   per template/date and duplicate-TripID candidate restrictions. Require explicit
   boarding/alighting permissions, affirmative stay-aboard/train-change correspondence,
   directional connectivity and finite justified total allowances including all
   alight/interchange/board components once. Same-station changes need evidence too;
   line boundaries or equal times prove nothing. Recommend no fragment stitching:
   through rides use existing spanning snapshots with stipulated correspondence.
   Unknown required evidence fails coverage; known prohibited/infeasible choices may
   be excluded only by a justified pre-handoff rule. Faulty complete handoffs still
   receive the accepted rejection reason rather than disappearing.
3. **Finite execution contract (Proposed choice, not acceptance of P5).** Recommend
   comparing all distinct admissible itineraries only within the explicitly invented,
   finite fixture profile first. Draft distinctness from the ordered sequence of exact
   view-scoped dated occurrences plus original ride indices and directional connections;
   decide how duplicate connection records with identical semantics normalize, without
   treating repeated station visits as equivalent. Specify a stable total handoff order
   independent of input container iteration, and deduplication before frozen indexing.
   Finite occurrence/stop/connection sets plus finite ride cap constrain path length,
   including zero-duration cases, but require a demonstrated terminating enumeration.
   Permit only pruning proven not to remove an itinerary within the chosen objective;
   no dominance/top-K rule is implied. Production all-distinct adoption remains open.
   A bounded best-K alternative would require ranking, ties and proof no omitted route
   outranks the retained set; stopping after K discoveries is not such proof. It could
   reduce output/memory pressure but would change the declared completion contract.
   For a small fixture proof, recommend deferring that extra policy surface; all-distinct
   can become unavailable under resource limits and is no production scalability claim.
4. **Completion, handoff and ownership.** Retain accepted DEC-079 boundaries: incomplete
   nodes/pruned infeasible paths are not alternatives; each complete handoff freezes one
   index before admission. Shared defects → dataUnavailable; uncompleted work despite
   usable inputs → searchIncomplete; observed cancellation → CancellationError, never
   partial output. With coverage and accepted completed execution: zero handoffs →
   scoped noResults, positive all-rejected handoffs → unscoped noUsableAlternatives,
   otherwise preserve every admitted candidate/omission. Recommend a DEBUG-only,
   off-main isolated synthetic implementation behind RouteSearching, with immutable
   injected fixture view and per-call state; test-only composition, no production
   default or wiring. Data owns fixture/evidence interpretation; exact generator
   placement and completion responsibility need explicit agreement before code.
   Preserve owned-work cancellation/concurrent-call independence and Application's
   separate supersession duty. Algorithm choice is not selected by this assessment;
   the implementation plan must explain how it satisfies the accepted execution contract.

**Invented acceptance examples for that draft (not executed compatibility claims):**

| Invented evidence/scenario | Expected boundary to specify |
|---|---|
| T1 A→B→D on L1/L2, exact 10:00→10:20, affirmative through evidence | Generate one matched ride across the line boundary; preserve original indices and no fabricated transfer |
| T1 A→B arrives 10:10; T2 C→D departs 10:13; explicit B→C train-change/walk relation and total allowance 120 seconds; eligible endpoints | Generate two rides plus directional walk. Reverse C→B is not implied. A 10:11 departure is known infeasible despite chronological order; same-station change also needs its own relation/allowance |
| Complete required inventory proves no feasible B→C connection; no other itinerary exists | After separately accepted complete execution and zero handoffs, scoped noResults; unknown B→C coverage instead gives dataUnavailable even if another direct route is usable |
| Opaque prior-service label with supplied civil-midnight instants inside [L,U]; repeated A visits at indices 0 and 2 | Include by qualified event availability, not parsed label; distinguish boarding occurrences in enumeration without guessing one |
| One valid itinerary found, budget expires; or cancellation is observed at final checkpoint | searchIncomplete for uncompleted computation; CancellationError wins once observed; neither returns a partial batch |
| Controlled admission seam receives a complete proposal with wrong occurrence/index or inadequate known allowance against otherwise complete inputs | One omission at its frozen index with accepted reasons; positive handoffs all rejected yield noUsableAlternatives, not noResults. Seam exercises defensive admission, not fabricated production inputs |
| More admissible itineraries than a display subset | Retain the whole completed batch; presentation never controls generation or omission accounting |

**Ordered path after this assessment:** (a) draft the above contract and precise
invented matrix, (b) independent review and owner decisions on inventory semantics,
connection representation, synthetic objective/distinctness/order/completion and
component ownership, (c) separately authorize one synthetic vertical implementation:
accepted failure additions + fixture view/preflight + actual generation + admission
into existing scoped values, with direct/through/transfer/negative/cutoff/cancellation
fixtures and release-isolation verification. Input must be timetable/connectivity
facts, not prebuilt RouteCandidates or external alternatives. A direct-first coding
increment may lead to transfer/multi-transfer within that agreed slice; it is not a
reduced launch commitment. No extra standalone vocabulary slice is needed to reach
that demonstration, though its semantics are already accepted. Keep real evidence
work separate until authorized; P2-S9 must finish before the first real canonical
Trip consumer or real P3-T1 import, not before this invented-data contract.

Verified clean baseline `phase/03-route-search`, HEAD/upstream
`e57ce5bf83972e3d54ad78eb96666973a88b46e2`, 0 ahead/behind; origin is the expected
TSUGINO repository. Refs locally recorded; no fetch required by rules. Main unchanged
at `e8a463d51f14b3cb1027960c63244b694579a71b`. Only this ROADMAP plan changed;
reference/documentation checks and `git diff --check` passed. No code, decision
acceptance, tests/builds, research/acquisition, private access, devices or Git
publication. Launch requirements and Phase 3 exit criteria remain unchanged.

### Proposed synthetic input/execution contract — 2026-10-02 Asia/Seoul

[Proposed DEC-081](DECISIONS.md#dec-081--finite-synthetic-internal-routing-inputs-and-execution)
now makes the preceding assessment concrete: a finite invented occurrence/coverage
universe, directional occurrence-pair connections/allowances, exact itinerary identity,
deterministic ordering, bounded cycle enumeration and handoff/completion boundaries.
Fifteen invented cases cover direct/through/transfer, negative versus unknown coverage,
repeated/prior-date occurrences, conflicts, all-rejected generated-claim faults,
ordering, cycles, cutoff and cancellation. No prewritten route alternatives or real
compatibility claims. Six owner choices remain Proposed; production P5 is not selected.
Next: independent documentation review, owner acceptance, then separate authorization
for one DEBUG-only generated-route vertical slice. The existing A/B values and accepted
contracts remain unchanged. No tests/builds, acquisition or implementation performed.
Verified branch/HEAD/upstream `phase/03-route-search` / `e57ce5bf83972e3d54ad78eb96666973a88b46e2`,
0 ahead/behind using recorded refs (no fetch required). Existing ROADMAP assessment
preserved; only DECISIONS and ROADMAP changed. Reference checks and `git diff --check`
passed. All prior real-data, rights/delivery and launch/Phase 3 exit gates remain.


### DEC-081 accepted synthetic execution and implementation — 2026-10-02 Asia/Seoul

The owner accepted [DEC-081 S1–S6](DECISIONS.md#dec-081--finite-synthetic-internal-routing-inputs-and-execution)
for the finite invented universe only, with the reviewed clarifications: resource
cutoffs during normalization/coverage produce searchIncomplete absent an earlier
established failure, and cancellation checkpoints cover shared validation and final
deduplication/sorting. The preceding proposal/assessment entries remain history.
Production P5, production engine adoption/defaults and real integration remain unaccepted.

**Implemented, independent implementation review pending:** three DEBUG-only files in
Data/Routing (`SyntheticInternalRouteInput.swift`, `SyntheticInternalRouteEngine.swift`,
`SyntheticInternalRouteSearcher.swift`) provide immutable stipulated input/configuration,
exact duplicate normalization, ordered preflight, conservative complete input coverage,
qualified ride-token derivation, explicit directional connections, finite exhaustive
synthetic path generation and deterministic frozen handoffs. Snapshot/index binding,
movement lines, eligibility, continuity, exact connection allowances and scoped-result
constructors are reused/checked. Original service-date labels are never interpreted.
Normal generation takes occurrence/connectivity facts, not prewritten candidates.

All distinct permitted sequences under the supplied ride cap are considered, including
cycles with distinct TripIDs and zero-duration events. Destination arrival emits without
terminating possible later returns. Ordering is ride-count then exact tuple order;
connection keys/forms are unique functions of adjoining rides in a validated view.
Only known constraint exclusions prune. One rejection/candidate accounts for each
handoff; no display truncation. Shared faults fail the whole call. A separate failure-only
harness mutates an index on genuinely generated frozen claims, returns validated
rejection accounting only and fails the test on unexpected admission. It cannot produce
successful completeness evidence or enter ordinary search configuration.

`RouteSearchResult.swift` adds the already accepted searchIncomplete failure and appends
unverifiedEligibility, infeasibleConnection and insufficientScheduledEvidence reasons.
Provider behavior, supplied-alternative searcher, Domain snapshot/Journey contracts and
all existing accounting remain unchanged. Execution uses @concurrent async search,
request-local state, no detached work, and cancellation/resource checkpoints through
validation, normalization, coverage, generation, initial ordering, final deduplication,
final sorting, admission and return. Resource accounting bounds controlled work; this
is not a guarantee of recovery from process-level memory exhaustion.

**Synthetic specification coverage:**

| Groups | Executed assertions / limits |
|---|---|
| G1–G4 | Inclusive request bounds; spanning through Trip counts once; directional walking and same-station allowance equality/insufficiency; no inferred reverse link |
| G5–G6 | Complete negative versus unknown coverage even alongside a valid direct route; repeated indices and explicitly closed partial snapshot intervals; unused outside-profile continuation |
| G7–G8 | Opaque prior/mixed date labels with qualified instants; missing manifests; active/inactive/unavailable slots; prohibited/unknown eligibility; missing/estimated required endpoints and permissible missing counterparts. Inactive event bodies are unrepresentable in the input type; source parsing/conversion and malformed raw event interpretation are excluded |
| G9–G10 | Identical duplicates collapse; snapshot/time/permission/view/connection conflicts fail shared inputs; generated-claim failure harness validates all-rejected accounting and refuses unexpected admission |
| G11–G12 | Exact ordered alternatives under reordered/duplicated fixture inputs; distinct dated runs; finite zero-time cycles and ride-cap pruning |
| G13–G14 | Controlled cutoffs and deterministic cancellation barriers at all 12 stages, including final deduplication/sorting; pre-cancelled precedence and independent concurrent calls; numeric work-budget cutoff |
| G15 | Full canonical batch retained when a hypothetical display prefix is smaller |

Additional arithmetic checks cover overflow and rounded arrival-plus-allowance sums
without turning insufficient gaps into feasible transfers. No actual calendar/feed,
real provider, production performance, physical-device or full-phase claim follows.

**Verification (iPhone 17 / iOS 26.5 Simulator, explicit destination):**

- Initial focused Debug run: **63 functions / 90 executed cases passed**, zero failures,
  skips or runtime warnings. Synthetic internal 17/37; scoped success 13/15; existing
  provider admission 23/28; existing async search 10/10.
  `/private/tmp/tsugino-p3-internal-r1.xcresult` and corresponding `.log`.
- Self-review found initial ordering barriers did not separately exercise final handoff
  deduplication/sorting. Separate DEBUG stages were added; final affected-suite run:
  **17 functions / 41 executed cases passed**, zero failures, skips or runtime warnings.
  `/private/tmp/tsugino-p3-internal-r2.xcresult` and corresponding `.log`.
  Unaffected provider/async/scoped-value evidence is reused from r1; no combined
  post-correction suite count is claimed. Debug test actions built app/extension dependencies.
- Separate **Release Simulator app and Live Activity extension build passed**:
  `/private/tmp/tsugino-p3-internal-release-r1.log`. All new implementation/fixture/test
  files are enclosed in DEBUG; Release-visible code has no dependency on those types.
  Release app symbol inspection found no SyntheticInternal symbols. The subsequent
  checkpoint-only change was wholly inside DEBUG; the Release evidence remains applicable.
- Existing canonical/Journey/railway Codable/isBlank actor-isolation warnings, existing
  RailCapabilityTests isolation warnings in Debug, and skipped AppIntents metadata
  extraction were recorded, not suppressed. No new-file compiler warning was observed.
  No failed test/build attempt occurred in this task. No unrelated full-suite rerun.

Self-review checked immutable inputs, preflight/unknown-versus-negative distinctions,
index safety before admission indexing, exact snapshots, finite termination, deterministic
ordering, cancellation, failure-only mutation and Release exclusion. The checkpoint
coverage issue above was corrected. No remaining material issue identified by self-review;
this is not independent approval. Next: independent review of DEC-081 acceptance,
finite input authority/coverage, generation identity/completeness, connection arithmetic,
frozen handoffs/defensive seam and concurrency/Release isolation against these cases.

P2-S9 remains required before real canonical Trip consumption and real P3-T1 import.
Feed-specific interpretation/validated import, source authentication, registry, rights,
publication/translation, delivery/bundling and expansion gates remain. No production
composition, Journey/UI binding or launch/Phase 3 exit change.

Git: verified expected repository/origin, branch phase/03-route-search, HEAD/upstream
`e57ce5bf83972e3d54ad78eb96666973a88b46e2`, 0 ahead/behind using recorded refs;
no fetch required by rules. Local/recorded main remains
`e8a463d51f14b3cb1027960c63244b694579a71b`. Ten-file inventory: five modified
(RouteSearchResult and four documentation files) plus three new Data files and two new
test/support files. Existing documentation work preserved; no unrelated changes found.
Documentation/reference checks and git diff --check passed. No commit, push or merge.


### DEC-081 independent-review corrections — 2026-10-02 Asia/Seoul

Independent implementation review required two bounded corrections; approval has not
been recorded. **Focused independent re-review is pending.** Accepted S1–S6, synthetic
scope, production P5 deferral and all retained gates are unchanged.

1. The connection loop filtered same-Trip pairs before cancellation/work accounting.
   It now calls the coverage checkpoint before the distinct-Trip exclusion, charging
   every considered pair. Adjacent exclusion paths were audited: the passenger-stop
   loop now directly enumerates forward indices instead of scanning filtered reverse
   pairs; other interval/eligibility/time/connection/path exclusions already follow
   checkpoints. No pruning or coverage semantics changed.
2. G10 manufactured noUsableAlternatives in the test rather than exercising actual
   finalization. Normal search and the isolated failure-only harness now share the
   finalizer, including frozen-handoff count validation, genuine scoped noResults,
   all-rejected failure and scoped alternatives. The harness has a Never return type;
   it throws the shared unscoped failure, or a harness failure on unexpected admission.
   It cannot return a successful result and remains absent from normal configuration.

Two deterministic regressions use 32 eligible dated direct tokens of the same Trip
and cap 3. Successful traversal observes all 1,024 pair checkpoints. A fixed 1,024-work
budget (above this fixture's worst-case pre-pair work) cuts off within those comparisons
before generation. A controlled barrier at pair 17 proves cancellation before generation;
a generation fallback makes a missing checkpoint fail assertions rather than hang.
No sleeps or performance-duration assertions. G10 now tests both one and three genuine
frozen handoffs, exact contiguous omission positions and inconsistentTrainEvidence by
catching the actual thrown failure. It retains unexpected-admission and malformed-shared-
view controls. Existing suite cases protect genuine noResults and ordinary alternatives.

**Focused verification:** initial correction r1 and final-source r2 each passed
**19 functions / 44 executed cases**, zero failures, skips or runtime warnings, on
explicit iPhone 17 / iOS 26.5 Simulator. Saved bundles:
`/private/tmp/tsugino-p3-internal-correction-r1.xcresult` and
`/private/tmp/tsugino-p3-internal-correction-r2.xcresult` (matching `.log` files).
The second run verifies the deterministic budget-test refinement; do not sum these
overlapping runs. Debug app/extension dependencies succeeded (r1 built dependencies;
r2 reused incremental dependencies). Existing isolation warnings in r1 and skipped
AppIntents metadata extraction were recorded; no new-source warning observed.
No failed test/build attempt occurred. Documentation/reference checks and
`git diff --check` passed. Earlier runs remain separately identified history.
Provider/async/scoped-value evidence from tsugino-p3-internal-r1 and the separate Release
app/extension build/exclusion evidence are reused, not rerun: all implementation changes
this turn are inside the existing DEBUG guards; no shared Domain/provider or Release-
visible code changed. These results do not establish real-source compatibility or
production runtime readiness.

Self-review also removed a test dependence on dictionary-sensitive initial sort work:
the final budget assertion uses the fixed fixture bound above. The initial correction
run and final-source run are separate evidence, not cumulative unique coverage.
Only Engine, Searcher, SyntheticInternalRouteTests, ARCHITECTURE and this ROADMAP changed
this turn; the original ten-file inventory is preserved. DECISIONS, consumer amendment,
input types, fixture support and Domain result additions remain byte-identical to review.
No new acceptance, provider acquisition, device access, commit, push or merge.


### DEC-081 final independent approval and publication — 2026-10-02 Asia/Seoul

**Current status: the corrected bounded DEBUG synthetic slice is independently approved.**
The preceding implementation and correction entries retain the historical pending-review
state. A fresh reviewer context with no prior exposure to the corrections inspected
actual accepted contracts, code and tests. Final verdict: approve; no material findings,
no new optional observations and no mandatory outstanding verification.

The review confirmed pre-exclusion pair checkpoints and safe forward-index enumeration,
all 1,024 same-Trip comparisons and deterministic cutoff/cancellation regressions,
shared normal/harness outcome finalization, actual unscoped all-rejected failures for
one/three generated handoffs, and the Never-returning isolated failure harness.
Normal success, genuine scoped noResults, shared-input failure and cancellation
precedence remain intact. Approval is confined to the synthetic implementation;
constructors do not authenticate real coverage or correspondence.

Reused evidence: final affected suite
`/private/tmp/tsugino-p3-internal-correction-r2.xcresult` — **19 functions / 44 cases**
passed, zero failures/skips/runtime warnings, with Debug app/extension dependencies.
Earlier provider admission 23/28, async 10/10 and scoped-result 13/15 evidence remains
separately recorded in `tsugino-p3-internal-r1.xcresult`. Separate successful Release
app/extension build and exclusion evidence remain applicable: correction code stays
inside DEBUG and does not change Release-visible/provider behavior. Overlapping runs
are not summed. Existing isolation/AppIntents warnings remain recorded. No tests or
builds were rerun for independent re-review or publication.

Publication is authorized for exactly the existing ten-file inventory. Source/test
SHA-256 hashes match the final independently reviewed version; only approval/status
documentation changes follow review. Fetch verified the expected origin and aligned
phase HEAD/upstream at `e57ce5bf83972e3d54ad78eb96666973a88b46e2` before publication.
Local and fetched main remained `e8a463d51f14b3cb1027960c63244b694579a71b`.
Documentation/reference/status checks, complete staged inventory/content review and
`git diff --check` are publication checks, not additional execution evidence.

No new work is authorized by this record. Production P5, engine adoption/defaults,
ODPT compatibility, P2-S9 before real Trip consumption/P3-T1 import, feed interpretation
and validated import, registry/rights/publication/translation/delivery/bundling/expansion
gates, launch requirements and Phase 3 exit remain unchanged.


### Next ODPT-first dependency assessment — 2026-10-02 Asia/Seoul

**Recommendation, not acceptance/implementation:** prepare one bounded documentation-only
**P2-S9 input, identity-review and evidence/acceptance plan**, using recorded evidence
and invented examples. S9's owner, no-times output and Domain invariants are accepted;
its feed-specific mapping/import/review design and real passenger-stop acceptance are
not completed or accepted merely by its “implementation” roadmap classification.
No later accepted record or implemented importer was found that closes this gap.
DEC-081's published, independently approved DEBUG searcher demonstrates synthetic
execution only. Its stipulated artificial universe is not a real-feed coverage policy.

| Order / boundary | Accepted support and reusable work | Remaining design/evidence and exact real-use gate |
|---|---|---|
| 1. P2-S9 passenger-stop Trips, **without times** | DEC-060/061 define recurring-run identity, original indexed passenger stops, repeated visits, movement-bearing line segments, independent origin/destination coverage and optional service-class evidence. DEC-074/075 retain S9 before real consumers. Phase 2 S4 identity/provenance and S6/S7/S8 provisional canonical foundation, Domain Trip validators and synthetic indexed-ride tests are reusable | Specify reviewed feed-specific passenger-stop/pass-through/unknown classification, source-occurrence→canonical-index crosswalk, recurring-run correspondence and revision/retirement handling, line/coverage proof and hold/reject diagnostics. Identical structure is not Trip identity; flags/row presence/topology are not passenger-stop proof. S4's station/line bindings do not automatically bind recurring Trips. Accepted S9 design, separately authorized identified inputs and scoped real mapping acceptance must precede real Trip consumption and real T1 import |
| 2. Feed-specific P3-T1 production of occurrence facts | DEC-078 O1–O6 semantics are already accepted; implemented view/date/snapshot/index-bound facts, quality/eligibility states and chronology are reusable. DEC-079 timetable ride context and DEC-080 local scope/result checks are implemented | Do not redo the accepted generic producer design. Review each source's activation/exception rules, timezone/service-day/extended-hour conversion, qualified exact versus missing/estimated fields, revision binding and exact occurrence correspondence. One execution per template/date must be evidenced; unsupported multiplicity/ambiguous conversion is held, not guessed. S9 plus accepted feed interpretation and authorized validated import block real output/consumption. An invented conversion-profile design can proceed before S9 real completion |
| 3. Operational evidence and authoritative coverage | DEC-009/076/078/079 require affirmative continuous rides/train changes, eligibility, directional connections and justified total allowances; DEC-080 distinguishes scope validity from coverage/completion. Existing values/admission checks can validate local structure | Plan evidence alongside S9/T1, but independently establish real interval continuity, endpoint eligibility, same-station and inter-station directional connectivity, allowance applicability, exhaustive required input inventory, complete negatives versus unknowns, freshness and coherent revisions. Station identity/proximity, matching labels/times, adjacency or absent transfer files supply none of this. DEC-081's enumerated fixture assertions cannot certify a real feed. Missing required evidence blocks the applicable real search/admission even if one route is usable |
| 4. Production search semantics/composition | Replaceable RouteSearching, canonical candidate/context/scope/success values and tested synthetic accounting/cancellation are reusable. DEC-077 accepts ODPT-first evaluation priority only; commercial evaluation/contact remains paused | Separately accept production objective/distinctness (P5 still Proposed), finite profile/domain/horizon, required inventory/coverage policy, connection-policy resolution, enumeration/pruning/order/completion/resource behavior, component ownership and deployment/update composition. Explicit engine adoption must address provisional DEC-004 and unchanged Phase 3 requirements. Synthetic all-distinct execution is neither that acceptance nor a ready production engine |

**Recorded evidence, not current compatibility:** consult the existing
[feasibility matrix](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md#existing-evidence-matrix)
and [audit §6.8 / source registry §9](PROVIDER_FEASIBILITY_AUDIT.md).
DS-01 Toei and DS-03 Metro GTFS snapshots were observed in September 2026 across
the launch line set; Phase 2 accepted 258 stations/15 lines/two operators only as a
private provisional baseline foundation. The audit's B11 observation of 540 Toei /
4,151 Metro nonterminal restricted, blank-time rows is consistent with passed positions
in those archives, not an accepted classifier. Catalogued timetable JSON is still
payload-unverified in the repository. The twelve-station Toei Pathways snapshot does
not prove inter-station or cross-operator connectivity; Metro's inspected missing
transfer/pathway members prove neither absence of real transfers nor complete negatives.
Headsigns, sparse block IDs and one evening's Toei static/RT joins do not establish
recurring-run stability, full through correspondence or current schedules. Publisher,
distributor, source resource/revision and applicable licence remain separate facts.
No owner-only evidence was opened or external observation refreshed for this assessment.

**First bounded deliverable:** a proposed S9 contract/evidence plan that (a) names the
already-recorded DS-01/03 candidate input families and required revision/provenance
manifest without selecting/acquiring new sources; (b) defines the review packet and
source-row/occurrence-to-original-index association; (c) proposes recurring Trip
identity/revision review and passenger-stop/line/coverage admission rules with unknowns
held explicitly; and (d) supplies synthetic specification cases and a real-acceptance
checklist. Cover two identical patterns belonging to different runs, same-run revision
with an inserted stop, repeated station visits, verified skipped rows versus unknown
classification, one-sided/two-sided partial coverage, line transition evidence and
conflicting/unmapped/retired references. Preserve separate through-service evidence;
never invent a passenger stop merely to represent a line boundary. Any representation
conflict must be stated for review, not silently weaken DEC-060/061. S9 emits no times,
calendars or dated runs; source-field observations used as evidence do not authorize
conversion or timetable output. Its index crosswalk must support later T1 binding
without treating raw stop_sequence numbers as canonical array indices.

This is new detailed importer/evidence design under existing invariants, not a duplicate
Trip value contract. Genuine new rules (classification authority, recurring-run mapping,
revision/review artifact semantics and unresolved representation cases) remain Proposed
until reviewed/accepted. Routine tool layout/naming does not need another decision.
After that review and explicit authorization, the smallest implementation can be a
synthetic-only S9 mapping/review validator; actual private-evidence inspection and real
acceptance require separate scoped owner authorization. Current work authorizes neither.
A Toei-only proving fixture would be incremental evidence, not a reduction of launch.

**Applicable access/delivery gates:** source-specific rights/provenance and owner
permission govern any later use of retained private inputs or acquisition. Production
registry/ID promotion, shipping composition, applicable Metro Q3 derivative publication,
Q4 translations, offline bundling/deletion and Toei attribution duties remain separate
from local design/validation. S10/Track A and Challenge restrictions still gate expansion;
ODPT-first does not unlock unsupported through continuations. These delivery gates do
not prohibit this documentation/invented-data design, and design does not satisfy them.
Launch scope and Phase 3 usable-canonical-plan exit remain unchanged.

Verified expected repository/origin and clean starting branch phase/03-route-search,
HEAD/upstream `9dfda2a589d15988a3e7964bd77ad4c95c976dbb`, 0 ahead/behind against recorded
refs. No fetch is required by repository rules; no fresh remote/source verification
is claimed. Main remains recorded at `e8a463d51f14b3cb1027960c63244b694579a71b`.
Only this ROADMAP recommendation changed. Documentation/reference checks and
`git diff --check` passed. No implementation, acceptance, tests/builds, research,
acquisition/contact, private/device access, branch creation or Git publication.


### Proposed P2-S9 review/evidence contract — 2026-10-02 Asia/Seoul

[Proposed DEC-082](DECISIONS.md#dec-082--p2-s9-passenger-stop-input-review-recurring-identity-evidence-and-acceptance-plan)
turns the preceding assessment into one bounded input/classification, original-index
crosswalk, recurring identity/revision and real-acceptance plan, with 14 invented cases.
No semantics are accepted. It reuses DEC-060/061 and keeps S9 without times; source
classification is not timetable interpretation or eligibility. Unknown interior evidence
holds the entire proposed snapshot; partial intervals cannot hide failed full proposals.

The plan makes a newly identified prerequisite explicit: DEC-068 §A1 excludes TripID
minting and §C1 has no Trip provider-reference namespace. Real authoritative S9 output
needs an explicit accepted identity-registration extension; no synthetic assignment or
review packet silently creates a resolver, registry schema or production identity.
First proposed implementation after review/acceptance/authorization is an invented-data
review-candidate validator only, independent of that real registration/access gate.

Only DECISIONS and ROADMAP changed; the existing ODPT-first assessment is preserved.
Verified branch/HEAD/upstream phase/03-route-search / `9dfda2a589d15988a3e7964bd77ad4c95c976dbb`,
0 ahead/behind using recorded refs; no fetch required by rules or fresh remote verification
claimed. Documentation/reference and diff checks passed. No implementation, acceptance,
research/acquisition/contact, private/device access, tests/builds or Git publication.
All S9/T1 real-consumer, registry/rights/delivery and launch/Phase 3 exit gates remain.


### DEC-082 focused outcome correction — 2026-10-02 Asia/Seoul

Independent documentation review identified one inconsistency: §4.1/S9-09 called a
conclusively unrepresentable line boundary held while the outcome table required rejection.
The proposal now consistently specifies **Rejected proposal / representationConflict**
for that case. Missing/ambiguous classification or boundary evidence remains held;
no passenger stop, boundary relocation, cropping or Domain amendment is introduced.
All fourteen cases and representationConflict references were checked. A fresh independent
reviewer inspected the actual corrected text and approved this focused correction with
no blockers. Optional pre-existing wording clarification before validator implementation:
§2.2's conflicting-mapping hold versus S9-06's rejection for conclusive contradiction
should distinguish unresolved conflict from a conclusively impossible mapping. That text
is unchanged by this narrow correction. DEC-082 remains Proposed; review approval does
not accept the decision or authorize implementation. Reference/case and diff checks passed.

### DEC-082 bounded acceptance and invented validator — 2026-10-02 Asia/Seoul

Owner accepted exactly the six §7 policies: evidence-backed classification; exact
ordered occurrence crosswalk; recurring identity review without real allocation;
independent coverage/representation evidence; distinct outcomes with complete accounting;
and synthetic-versus-real separation. The reviewed wording is clarified consistently:
unresolved/ambiguous mapping evidence holds; conclusively impossible mappings reject.
A proven passed-position line boundary rejects `representationConflict`. Earlier Proposed
and documentation-review records above are history, not the current acceptance status.

**Implemented, independent review pending:** two DEBUG-only files in `Data/Review`
(`SyntheticTripReviewInput.swift`, `SyntheticTripReviewValidator.swift`) plus
`SyntheticTripReviewTests.swift`. No existing Domain/routing/provider code changed.
The pure synchronous validator consumes invented revision/evidence UUIDs, ordered source
positions, an explicitly reviewed interval, classification/mapping assertions, supplied
synthetic TripID correspondence, movement spans and independent boundary assertions.
No source field/time/name heuristic or registry allocation exists. Service types remain
unknown ([]). Evidence catalog resolution and reviewed assertions are stipulated input,
not authentication. The candidate initializer is fileprivate; values are immutable,
nonisolated/Sendable and have no persistence or snapshot equality/hash conformance.

Shared view/reference failures invalidate the packet before run diagnostics. Every unique
declared run otherwise receives one outcome in deterministic locator order. Duplicate/
missing order rejects; required unknown facts hold the whole interval. Known contradiction
wins over unrelated missing facts. Passed positions have explicit nil-index crosswalk
entries; passenger indices are consecutive original indices, including repeated stations.
Proven movement membership and adjacent line changes are checked even when another fact
is unknown. No stop invention, guessed boundary or fallback interval is permitted.
All Trip fields/crosswalk/evidence and both boundary assertions are compared against a
supplied predecessor; changed content under an unchanged view rejects, changed views
require revalidation. No runtime consumer is wired and no revision is authenticated.

**Specification coverage:** S9-01–06 exercise ordering, repeat/pass crosswalks, no-cropping
holds, duplicate/missing keys and both mapping outcomes; S9-07 exercises stipulated identity
ambiguity versus distinct supplied assignments; S9-08 exercises all four coverage flag
shapes and unknown outside versus inside the explicit interval; S9-09 proves valid line
transition, passed-boundary rejection and unknown-boundary hold; S9-10/11 compare inserted/
removed visits and independent line/coverage revisions, old snapshot bindings and unchanged
reruns; S9-12 holds unverified fragments without stitching; S9-13 rejects invalid compressed
structure; S9-14 rejects mixed views, unresolved evidence references, duplicate packet keys
and competing same-ID snapshots, and holds the registration-required sentinel. Extra
checks cover Int.min/Int.max ordering, invalid movement references, complete mixed accounting
and stable diagnostic order. Classification authenticity, real correspondence/registration,
source-format interpretation, automatic downstream invalidation and real acceptance remain
documentary prerequisites; these are constructor/validator subcases, not full real S9 proof.

**Self-review corrections before final verification:** source-order values are retained
alongside original indices. Positive membership and passed-boundary contradictions are
checked before unknown-fact fallback, including an unrelated unknown movement span;
unknown adjacent line evidence alone cannot fabricate a contradiction. Separate line and
coverage revision controls avoid testing only a combined change. No unresolved material
self-review finding is known; independent implementation review remains pending.

**Verification (iPhone 17 / iOS 26.5 Simulator):** initial r1 passed 16 functions / 22
executed cases. After self-review changes, final r2 passed **17 functions / 24 executed
cases**, zero failures/skips/runtime warnings. These overlapping runs are not summed.
Debug test action built app and Live Activity extension dependencies. A separate Release
app/extension build succeeded; both new implementation files are wholly DEBUG-guarded,
no production references were added, and `nm` of the Release app contained zero
`SyntheticTripReview` symbols. Existing isolation-conformance and AppIntents metadata
warnings remain (r1: 35+2, r2: 27+2, Release: 33+1 diagnostic lines); none originates in
the new files. No failed test/build attempt. Initial sandboxed xcresult summary extraction
failed on report-cache permission; the authorized tool retry succeeded. This tooling failure
is not test evidence. Unchanged provider/async/Domain evidence is reused, not claimed rerun;
no full suite or physical device was used.

Exact commands (r1 used the identical test command with r1 result/log names):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-review-r2.xcresult > /private/tmp/tsugino-s9-review-r2.log 2>&1
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd > /private/tmp/tsugino-s9-review-release-r1.log 2>&1
```

Saved results: `/private/tmp/tsugino-s9-review-r1.xcresult` and
`/private/tmp/tsugino-s9-review-r2.xcresult`; logs share those prefixes.
Acceptance/documentation references and `git diff --check` pass. Final inventory is three
modified documents (DECISIONS, ARCHITECTURE, ROADMAP), two new Data/Review sources and
one new test file. Branch/HEAD/upstream remain `phase/03-route-search` /
`9dfda2a589d15988a3e7964bd77ad4c95c976dbb`, 0 ahead/behind using locally recorded refs;
no fetch is required by repository rules and no fresh remote verification is claimed.
No commit/push/merge or unrelated change. Next: independent review of this bounded
validator, especially no-cropping, crosswalk/revision association, contradiction-versus-
uncertainty precedence, packet accounting and diagnostic privacy.

**Still incomplete:** real P2-S9 acceptance. DEC-068 Trip registration extension,
source authentication/parsing, P3-T1 feed interpretation/validated import, production
search/P5, registry/rights/publication/translation/delivery/bundling/expansion gates,
launch requirements and Phase 3 exit remain separate and unchanged.


### DEC-082 independent-review correction — 2026-10-02 Asia/Seoul

Independent implementation review found one material defect: the general hold return
preceded independently conclusive stop-structure and predecessor-identity checks.
Verified [A, passed B, A] plus unresolved identity could hide invalidStructure;
reviewed identity Y against prior X plus unknown classification could hide identityConflict.
The validator now checks those facts before hold finalization, retaining applicable
missing-evidence reasons in declaration order. Adjacency crosses only affirmative passed
positions; unknown classification or mapping resets it. Fully known insufficient stop
counts are rejected without constructing a placeholder TripID. The same early-return
audit found that a proven passed first/last interval boundary could be hidden by unknown
movement evidence; its representationConflict is now checked independently too. Unproved
boundaries remain held. Existing full Trip construction and snapshot checks are retained.
Other early returns already reject invalid ordering/intervals; no speculative crosswalk
is built from them. Optional duplicate-order participant diagnostics were not changed.

Combined regressions cover unresolved identity and missing interval/continuity/endpoint
proof with the invalid [A,A] sequence, a proven invalid subsequence beside an unrelated
unknown, and prior X versus reviewed Y beside unknown classification. Positive controls
hold unknown classifications, unknown mappings and unproved passed positions between
same-station visits, and do not infer identityConflict from an unreviewed Y label.
Passed interval endpoints with unknown movement reject; an unknown endpoint remains held.
No accepted semantics, Domain/input shape, real registration or integration changed.

Final focused correction r2: **21 functions / 31 executed cases passed**, zero failures,
skips or runtime warnings, iPhone 17 / iOS 26.5 Simulator. Debug app/Live Activity extension
dependencies built. Initial correction r1 passed 20 functions / 30 cases before the extra
interval-boundary regression; overlapping runs are not summed. Both runs emitted the
existing 27 isolation-conformance and two AppIntents metadata warning lines, none in the
changed source/test files. No failed test/build attempt. Sandboxed r1 xcresult extraction
hit report-cache permission; the authorized retry succeeded, separate from test evidence.
Exact final command (r1 used corresponding r1 bundle/log names):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-review-correction-r2.xcresult > /private/tmp/tsugino-s9-review-correction-r2.log 2>&1
```

Prior Release app/extension and symbol-exclusion evidence is reused: correction source
and tests remain entirely DEBUG-guarded, with no Release-visible/dependency change.
Unrelated suites were not rerun. Only SyntheticTripReviewValidator.swift,
SyntheticTripReviewTests.swift and ROADMAP changed this turn; total working inventory
remains the six DEC-082 files. Acceptance/input/architecture bytes are preserved.
Self-review, reference checks and git diff --check pass. Independent focused re-review
is pending; no approval or real S9 completion is claimed. HEAD/upstream remain
`9dfda2a589d15988a3e7964bd77ad4c95c976dbb` on `phase/03-route-search`, 0 ahead/behind
using locally recorded refs (no rule-required fetch). No commit/push/merge. All retained
real-data, Trip-registration, T1/import, production-search, rights/delivery and Phase 3
exit gates remain unchanged.


### DEC-082 same-view revision correction — 2026-10-02 Asia/Seoul

Focused independent re-review found another instance of hold masking: the same-view
predecessor affirmatively reaches a boundary, the proposal affirmatively continues
outside it, but unrelated unknown classification prevented revisionMismatch. The validator
now compares affirmative reached/continued facts before the general hold return, separately
for origin and terminus, requiring the same reviewed TripID, view and corresponding source
boundary locator. It preserves unknownClassification alongside revisionMismatch. Changed
views, unknown extent, missing proof or unreviewed identity do not establish that conflict.

The requested audit also identified independently known structural revisions hidden by
unrelated missing facts. Exact existing source locators now permit comparison of established
source order, passenger/passed classification and mapped station against the predecessor.
Explicit evidenced line claims with passenger anchors in the predecessor compare only the
prior snapshot's actual movement interval (positive overlap, not endpoint contact). These
are prior indices, never inferred current indices. Complete current stop/crosswalk facts
and, when complete, line segments also compare before holds. No compressed partial array
comparison, guessed Trip, placeholder TripID or identity allocation occurs. Unknown facts
are not promoted; final complete snapshot/evidence comparison remains unchanged. Ordering,
identity, membership, adjacency, interval and movement-representation contradictions already
reject before the hold; invalid-order/interval early returns already reject without guessing
subsequent associations. No accepted semantics, input schema or Domain invariant changed.

Regressions cover both boundaries and both affirmative conflict directions, exact ordered
reasons/locations, changed views, unknown/missing evidence, compatible boundary assertions,
unmatched boundary locators and unreviewed identity. Audit regressions cover exact-locator
station/order/classification conflicts, known line contradictions beside unknown classification,
compatible line transitions with endpoint-only contact, and complete stop/line revisions with
missing continuity proof. Changed-view, unproved-classification and compatible-structure
controls remain held. The existing adjacency/mapping/boundary regressions remain passing.

**Final verification:** revision r3 passed **25 functions / 36 executed cases**, zero
failures/skips/runtime warnings, iPhone 17 / iOS 26.5 Simulator. Debug app and Live Activity
extension dependencies built. Intermediate revision r1 passed 24/35; r2 passed 25/36 before
the final explicit-line comparison assertions. These overlapping runs and the previous
21/31 correction are separate evidence, never summed. Each revision run emitted 27 existing
isolation-conformance and two AppIntents metadata warning lines, none in the new files.
No failed test/build or result-extraction attempt this turn. Exact final command (r1/r2 used
the respective bundle/log suffix; saved bundles and logs remain in /private/tmp):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-revision-r3.xcresult > /private/tmp/tsugino-s9-revision-r3.log 2>&1
```

Release app/extension and symbol-exclusion evidence is reused: all correction code/tests
remain inside unchanged DEBUG guards, with no Release-visible dependency/composition change.
No unrelated suite, Release build or physical-device step was rerun. Only validator, tests
and ROADMAP changed this turn; total inventory remains the six DEC-082 files. DECISIONS,
ARCHITECTURE and input-source bytes are preserved. Reference checks, self-review and git
diff --check pass. HEAD/upstream remain `9dfda2a589d15988a3e7964bd77ad4c95c976dbb` on
`phase/03-route-search`, 0 ahead/behind using recorded refs; no fetch required by rules.
No commit/push/merge. Independent re-review is pending, not replaced by self-review;
the most recent reviewer-start attempts hit the agent thread limit. All real S9,
registration, interpretation/import, production-search, rights/delivery and Phase 3 exit
gates remain unchanged.


### DEC-082 split-movement correction — 2026-10-02 Asia/Seoul

Read-only review found that predecessor movement comparison used raw spans whose
endpoints required passenger indices. Splitting a known L2 interval at a passed source
position skipped both comparisons against an all-L1 predecessor, while the equivalent
unsplit claim rejected. Unrelated unknown classification then hid revisionMismatch.
Comparison now consumes the already-normalized, evidenced continuous spans. Exact source
anchors resolve in the reviewed same-view predecessor crosswalk; prior segment bounds
project to that crosswalk's source ordering. Strict positive overlap excludes mere boundary
contact. Passed anchors retain their known source order and nil passenger index; no index
is invented. This also avoids losing an established comparison when normalization produces
passed outer anchors around known passenger visits. Same reviewed identity/view guards and
all final snapshot checks are unchanged. Normalization still joins only contiguous,
affirmatively evidenced spans of the same line; unknown gaps and differing lines never join.

Focused controls compare split/unsplit rejected outcomes including ordered reasons and
locations, compatible-line holds and changed-view holds. Additional checks cover boundary-
only contact, unknown gaps over a different predecessor line, L1/L2/L1 preservation,
passed-position line-change rejection, and split/unsplit known spans with passed outer
anchors and uncertain surrounding movement. No inferred current classification, Trip,
identity or passenger index; no expanded real correspondence or accepted semantics.

**Verification:** one focused run, `/private/tmp/tsugino-s9-split-r1.xcresult`, passed
**29 functions / 41 executed cases**, zero failures/skips/runtime warnings, iPhone 17 /
iOS 26.5 Simulator. Debug app/Live Activity extension dependencies built. Existing 27
isolation-conformance and two AppIntents metadata warning lines remain; none originates
in the changed files. No failed or intermediate test/build attempt this turn. Prior runs
remain separate and are not summed. Exact command:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-split-r1.xcresult > /private/tmp/tsugino-s9-split-r1.log 2>&1
```

Prior Release app/extension and symbol-exclusion evidence is reused: implementation/tests
remain entirely DEBUG-guarded with no Release-visible dependency change. No unrelated
suite/build or device step was repeated. Self-review, reference checks and git diff --check
pass; independent re-review remains pending, not supplied by this author session.
Only validator, tests and ROADMAP changed this turn; the existing six-file inventory is
preserved. HEAD/upstream remain `9dfda2a589d15988a3e7964bd77ad4c95c976dbb` on
`phase/03-route-search`, 0 ahead/behind using recorded refs; no rule-required fetch.
No commit/push/merge or additional acceptance. Real S9, registration/import, production
integration, rights/delivery and Phase 3 exit gates remain unchanged.


### DEC-082 movement-evidence equivalence correction — 2026-10-02 Asia/Seoul

The final same-view revision check previously compared raw proof-reference arrays, so
subdividing one continuous L1/E span into two L1/E spans falsely created revisionMismatch
once all classifications were known. Candidate storage and proposal comparison now use
the same canonical movement-evidence representation: exact source interval anchors,
canonical line and proof reference. Only contiguous spans with identical line **and** proof
join. Raw references remain retained and checked against the packet catalog; non-movement
proof comparison stays separate and unchanged. No global set/deduplication, inferred
passenger indices, gap bridging or merging of differing lines/proofs is introduced.
Changed proof applicability, including swapped proofs or shifted interval boundaries with
the same global proof set, remains a same-view conflict; changed views retain the existing
revalidation obligation. Accepted semantics and all prior snapshot checks are unchanged.

Fully known regressions exercise unsplit→split and split→unsplit unchanged candidates,
changed proof under same/changed views, and swapped/shifted proof applicability. Existing
contradiction, unknown-gap, differing-line, passed-anchor and changed-view controls also
ran. Final focused evidence: **32 functions / 47 executed cases**, zero failures/skips/
runtime warnings, iPhone 17 / iOS 26.5 Simulator. Debug app/Live Activity extension
dependencies built. Existing 35 isolation-conformance and two AppIntents warning diagnostic
lines remain, none from the changed files. Runs are not summed.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-evidence-eq-r2.xcresult > /private/tmp/tsugino-s9-evidence-eq-r2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-s9-evidence-eq-r2.xcresult
```

The initial identical test command used `tsugino-s9-evidence-eq-r1` for both output paths;
it failed before test execution with CoreSimulator access/destination failure (exit 70).
The authorized Simulator-access retry above passed. The first summary read failed on
TestReport cache permission (exit 64); its authorized retry succeeded. Those tool/access
failures are separate from successful test/build evidence; there was no compilation failure.
Prior Release app/extension and symbol-exclusion evidence is reused: all changes remain
within existing DEBUG guards, with no Release-visible dependency/composition change.
No unrelated suite, Release build or physical-device step was repeated.

Self-review checked both canonicalization callers, interval/proof preservation, no set-based
comparison, safe array replacement, unchanged hold/rejection precedence and DEBUG isolation.
Reference checks and git diff --check pass. Only validator, tests and ROADMAP changed this
turn; input, DECISIONS and ARCHITECTURE bytes are preserved. Existing six-file inventory and
HEAD/upstream `9dfda2a589d15988a3e7964bd77ad4c95c976dbb` remain, 0 ahead/behind using recorded
refs; no rule-required fetch. **Independent re-review pending**, not supplied by this author
session. No acceptance/commit/push/merge. Real S9, registration/import, production integration,
rights/delivery and Phase 3 exit gates remain unchanged.


### DEC-082 evidence-revision precedence and hold-boundary audit — 2026-10-02 Asia/Seoul

Established movement-proof changes now compare before the general hold, within the existing
same-reviewed-TripID/view guard. Canonical spans retain exact source anchors, line and proof;
comparison uses corresponding predecessor source order and strictly positive movement overlap.
Missing intervals/proofs are not compared as negative facts. Split/unsplit equivalence stays
unchanged; no passenger index, identity or missing coverage is inferred. Raw catalog validation
and final complete snapshot comparison remain intact.

The whole hold-boundary audit also found that affirmative non-movement proof changes could
hide behind unrelated holds. Candidate storage now retains proofs by role and source locator,
and comparison uses those same roles (not a compressed array across missing entries). Only
proofs present on both sides at corresponding reviewed occurrences/boundaries compare; changed
views and missing proofs do not prove conflict. This extends the existing evidence-revision
rule to its independently established inputs, without new accepted semantics.

| Contradiction category | Required evidence / evaluation stage |
|---|---|
| Shared view, duplicate run, unresolved catalog references | Packet checks before per-run work; incompatible complete emitted snapshots also fail the packet. Malformed shared inputs stop speculative diagnostics. |
| Duplicate/missing/conflicting order; invalid selected interval | Validate declared source locators/order and interval before indexing. These rejection-only early returns prevent unsafe downstream interpretation. |
| Impossible mapping / reviewed identity conflict | Affirmative impossible assertion or reviewed target differing from predecessor; checked before holds. Unresolved identity/mapping only holds. |
| Passenger sequence and interval endpoints | Proven consecutive equal passenger stations across affirmative passes, proved passed outer endpoints, or a fully classified sequence with fewer than two passengers reject before holds. Unknown classification/mapping breaks adjacency inference. |
| Movement structure, membership and representation | Exact ordered positive spans, known passenger membership, and proved line transitions at passed positions are checked before holds. Unknown lines cannot prove a transition. Full segment projection requires complete classification/movement; service types remain explicitly unknown ([]). |
| Snapshot occurrence, coverage and line revisions | Same reviewed identity/view and exact source correspondence. Compare established order/classification/station facts, opposite affirmative coverage claims, and positive movement overlap before holds. Complete traversal/crosswalk/segment comparisons require their own complete facts, not unrelated review proofs. |
| Movement and other proof applicability revisions | Before holds: established overlapping canonical movement proofs; identity role; corresponding interval/continuity and endpoint roles; exact occurrence classification/mapping roles. Missing counterparts, unknown extent, absent correspondence and changed views cannot supply a contradiction. |
| Final candidate / revision obligation | After all prerequisites pass: unchanged Trip constructor, every-field snapshot/crosswalk/proof association comparison and unchanged/revalidation obligation. This stage does not salvage partial known subsets or authenticate supplied evidence. |

Diagnostics still retain all applicable uncertainty and rejection reasons in the accepted
order, with deterministic source locations. No general hold precedes the independently
established checks listed above. RegistrationRequired remains a hold and real allocation
remains excluded. Input enums cannot encode two simultaneous classifications for one locator;
duplicate locator/order declarations are rejected rather than merged.

New regressions combine changed/swapped movement proofs with unknown classification; controls
cover unchanged proofs, equivalent subdivision, changed views and missing movement evidence.
Seven role-specific proof-change cases also combine unrelated unknown classification and assert
exact ordered diagnostics. Prior structural, identity, boundary, gap and revision controls remain.

**Focused verification:** `/private/tmp/tsugino-s9-proof-precedence-r1.xcresult` passed
**34 functions / 60 executed cases**, zero failures/skips/runtime warnings on iPhone 17 /
iOS 26.5 Simulator. Debug app/Live Activity extension dependencies built. Existing 35
isolation-conformance and two AppIntents warning diagnostic lines remain, none from the
changed files. No failed/intermediate test/build or report attempt in this turn; earlier
runs/access failures remain separate and are not summed. Exact successful commands:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-proof-precedence-r1.xcresult > /private/tmp/tsugino-s9-proof-precedence-r1.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-s9-proof-precedence-r1.xcresult
```

Prior Release app/extension and symbol-exclusion evidence is reused: all implementation and
tests remain under unchanged DEBUG guards, with no Release-visible dependency/composition
change. No unrelated suite/build or physical-device step was run. Self-review, reference
checks and git diff --check pass. Branch `phase/03-route-search` and HEAD/upstream
`9dfda2a589d15988a3e7964bd77ad4c95c976dbb` remain, 0 ahead/behind using recorded refs;
no rule-required fetch. No commit/push/merge or additional acceptance.

Independent re-review remains pending. Only validator, tests and ROADMAP change in this turn;
accepted decisions, input and architecture are preserved. Real S9, registration/import,
production integration, rights/delivery and Phase 3 exit gates remain unchanged.

### DEC-082 classification/mapping independence correction — 2026-10-02 Asia/Seoul

Fresh independent review found that an evidenced passed→passenger contradiction at an
exact predecessor occurrence could be hidden by unavailable station mapping. The comparison
now checks affirmative disposition independently; only station-identity comparison requires
resolved, evidenced mapping. Same reviewed TripID/view and occurrence guards remain intact.
No station identity is inferred and no accepted semantics or proof-role rules change.

Two regression cases reject unavailable mapping and resolved mapping without its evidence,
retaining exactly `[mappingUnavailable, revisionMismatch]`. Ten control cases cover both
mapping forms with missing classification proof, changed view, absent occurrence correspondence,
unresolved identity and an unproved identity label. They assert held outcomes, exact reason
order and diagnostic locations. Existing classification/mapping/proof-role cases remain passing.

**Final focused verification:** r2 passed **36 functions / 72 executed cases**, zero
failures/skips/runtime warnings on iPhone 17 / iOS 26.5 Simulator; Debug app/Live Activity
extension dependencies built. Existing 27 isolation and two AppIntents warning diagnostic
lines remain, none from the changed source/test files. Commands:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-s9-disposition-r2.xcresult > /private/tmp/tsugino-s9-disposition-r2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-s9-disposition-r2.xcresult
```

**Separate failed tooling attempts:** the identical test command with r1 log/result names
failed before tests (exit 70): sandbox CoreSimulator connection refusal left the explicit
Simulator destination unavailable. The approved-access r2 retry passed. Sandboxed r2 summary
extraction failed on TestReport cache permission (exit 64); its approved-access retry succeeded.
These failures are not passing test evidence; logs/results retain their separate names.

Prior Release app/extension and symbol-exclusion evidence is reused as independently reviewed:
this correction remains entirely within existing DEBUG guards, with no Release-visible,
dependency or composition change. Unrelated suites and physical-device steps were not rerun.
Reference checks, git diff --check and focused scope/diff review pass. Only validator, tests
and ROADMAP changed this turn; input, accepted decisions and architecture remain byte-identical.
The six-file uncommitted inventory, branch `phase/03-route-search` and HEAD/upstream
`9dfda2a589d15988a3e7964bd77ad4c95c976dbb` remain (0 ahead/behind using recorded refs).
No fetch, private access, acquisition, additional acceptance, commit, push or merge.
Focused independent re-review is pending; this correction's self-review is not independent
approval. Real S9, registration/import, production integration and all retained gates remain unchanged.

### DEC-082 final independent approval and publication record — 2026-10-02 Asia/Seoul

**Bounded implementation independently approved; real P2-S9 remains incomplete.**
A fresh reviewer context with no correction-authoring history read the contract, validator,
tests and saved verification and reported no material findings. The authoring context
coordinated repository/evidence checks but did not provide independent approval. Earlier
pending-review entries above preserve their historical state; this entry is current status.

The review confirmed disposition comparison independent of mapping, resolved/evidenced
mapping for station identity, unchanged reviewed identity/view/occurrence guards, exact
uncertainty/rejection diagnostics and all 12 added regression cases. Existing classification
and mapping proof-role comparisons retain their accepted semantics. Saved r2 verification
is reused: **36 functions / 72 cases passed**, zero failures/skips/runtime warnings, Debug
app/extension dependencies built, 27 isolation and two AppIntents warnings. Simulator-access
and report-cache failures remain separate in the preceding record. Prior Release evidence
remains applicable: unchanged DEBUG isolation, no production references and zero
`SyntheticTripReview` symbols in the retained Release binary. No tests/builds were rerun
for approval recording/publication; source/test bytes match the independently reviewed version.

The owner authorized publication of exactly the two Data/Review sources, their test file
and DECISIONS/ARCHITECTURE/ROADMAP. Origin was verified as `lunalism/TSUGINO`; a publication
fetch confirmed `phase/03-route-search` and its upstream at
`9dfda2a589d15988a3e7964bd77ad4c95c976dbb` with no divergence, and main at
`e8a463d51f14b3cb1027960c63244b694579a71b`. Publication uses the existing phase upstream
without force-push or merge. Documentation status synchronization changes no accepted policy.

Approval and publication cover only the DEBUG offline synthetic review validator. They do
not complete real S9 or authorize registration, source authentication/parsing, timetable
import, routing integration or production delivery. All registry, rights/delivery and
Phase 3 exit gates remain unchanged; no next slice begins here.

**Trip registration follow-up (2026-10-02 Asia/Seoul, documentation only):**
[Accepted DEC-083](DECISIONS.md#dec-083--bounded-recurring-trip-registration-before-authoritative-p2-s9-output)
settles five registration choices: `trip`/`trp` with DEC-068 minting/history rules;
owner-approved requests applied offline at an identified checkpoint; conditionally scoped
Trip-only `gtfs.trip_id`; affirmative returning-reference continuity, permanent authority,
immutable history and atomic conflict rejection; initial registration, reviewed attachment
and snapshot revision only. This is semantic acceptance, not implementation or execution
authorization. Canonical transitions/reuse, actual S9 acceptance, P3-T1 import, production
registry adoption, rights/publication/delivery and Phase 3 exit remain separately gated.

**Schema contract accepted — 2026-10-02 Asia/Seoul.** [DEC-084](DECISIONS.md#dec-084--synthetic-trip-registry-schema-and-explicit-legacy-conversion-design)
accepts schema-4 candidate representations, a version-1 synthetic review/history envelope,
explicit conversion-only 2/3→4 checkpoints and 4→4 reviewed operations. It preserves exact
legacy bytes/history, rejects unsupported versions and makes incomplete-history inputs
unavailable for Trip registration without discarding them. Current readers and production
formats remain unchanged. The owner authorized only slice A implementation. Acceptance
includes approval/dependency/proof associations, first-selection representation, stipulated
seed rules, replay/conversion/unavailability and deterministic diagnostics. No real conversion,
mutation, registration, allocation or production adoption is authorized.

The eventual synthetic validator is offline and in-memory over invented data. Its scope
below is divided into the three separately authorized slices after the table:

| Part | Bounded slice |
|---|---|
| Inputs | Identified previous registry checkpoint/history, proposed new/attached Trip assignments using invented IDs, stipulated owner-review and source-profile evidence references, and complete S9 inputs/proof associations for first selection or exact old/new snapshots/crosswalks when revised. Proposed targets are supplied; no real allocation, evidence authentication or source parsing. |
| Validation | Check supported schema/checkpoint, explicit approval/applicability, Trip kind/format and all-history uniqueness for new targets, exact scoped keys, affirmative new-run/same-run/returning-reference correspondence, active existing target for attachment, permanent authority/history and every-field snapshot/index changes. Reject conflicting/stale/wrong-kind updates without partial success; hold unresolved evidence. Refuse canonical transitions and provider-key reuse. |
| Outputs | Deterministic proposed delta or held/rejected result, complete request accounting, bounded synthetic diagnostics and downstream revalidation obligations. Preserve the input checkpoint and old snapshots. No registry write, production resolver output or automatic consumer rebinding. Concrete encoding/outcome shape follows the reviewed plan. |
| Focused invented cases | TR83-01–08: one identity across dates, reviewed key churn, refused reuse, repeated visit indices, same-ID snapshot revision, blocked split/merge, atomic conflicting registration, absence versus retired return. Add missing approval/profile/continuity, wrong-kind/retired target, stale checkpoint, all-history collision, unchanged rerun and attempted history rewrite controls. |

This reduced validation slice cannot claim a completed allocator/registry applier. A later
explicitly authorized synthetic allocation/application slice would exercise the reused
minter's redraw/eight-collision failure behavior and persistence atomicity after schema
review; neither runs now. Real profiles, correspondence authenticity and private provisional
registration require separate evidence and authorization. DEC-082's approved synthetic
review validator is unchanged; real S9 and all consumer/delivery gates remain outstanding.

DEC-084's corrected proposal passed independent read-only re-review and was owner-accepted.
Its ordered implementation sequence is: **A**, strict codecs, deterministic digest
fixtures and dependency closure; **B**, baseline/history/checkpoint replay and conversion
validation; **C**, registration/attachment and DEC-082-backed initial snapshot selection/
revision. A is implemented and independently approved (2026-10-02 Asia/Seoul). B is now
separately authorized and locally implemented, with independent implementation review pending.
C remains unimplemented and unauthorized.
Each later slice requires separate authorization and review before progressing. TR84-01–16
exact-outcome, approval/dependency-mutation, proof-preservation and unchanged-input controls
supplement TR83-01–08; only their representation/closure controls belong to A. First-selection,
seed, approval and proof semantics are accepted but not admitted/replayed by A. No shared
production enum expansion, real registry migration, filesystem loader/writer, allocator or
source authentication is included. All real S9/import and delivery gates remain separate.

**DEC-084 slice A — implemented and independently approved, 2026-10-02 Asia/Seoul.** New DEBUG-only
code under `Data/Review/SyntheticTripRegistration*.swift` uses closed schemas and immutable
canonical byte documents, explicit typed approval payloads, SHA-256 and complete supplied
dependency inventories. It preserves S9 inputs and proof/view records, including per-run
predecessor references, without constructing candidates. Success means only
`completeRepresentation`. Evidence authenticity/applicability, history/checkpoint replay,
conversion validity and registration/selection admission remain excluded B/C work.

Golden payload/history bytes and SHA values were independently derived with Python `json.dumps(sort_keys=True,
separators=(',', ':'))` and `hashlib.sha256`, then fixed as literals in tests. Tests also
cover scalar spelling, all S9 input cases/roles, repeated visits, nested dependency closure,
missing/cyclic/conflicting records, approval mutations and existing-reader rejection of 4.

**Final focused verification (r6): 101 functions / 219 executed cases passed**, zero
failures, skips or runtime warnings. The new suite contributes 28 functions / 56 cases;
existing `SyntheticTripReviewTests` and `MappingRegistryTests` are the affected regressions.
Debug app and extension dependencies built. The log contains 27 existing primary isolation
warnings and two AppIntents metadata warnings (54 isolation lines if repeated diagnostic
renderings are counted); no new slice-A source warning was emitted.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -only-testing:TSUGINOTests/SyntheticTripReviewTests -only-testing:TSUGINOTests/MappingRegistryTests -resultBundlePath /private/tmp/tsugino-dec084-a-r6.xcresult > /private/tmp/tsugino-dec084-a-r6.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-a-r6.xcresult > /private/tmp/tsugino-dec084-a-r6-summary.json
```

Earlier attempts are separate, overlapping evidence, **not additive totals**. Each used
the identical test command above with only both `r6` output-path suffixes replaced by
the recorded run number. Summary commands likewise used that run's exact path/suffix.

| Run | Saved stem under `/private/tmp/` | Outcome / warning counts |
|---|---|---|
| r1 — failed environment attempt | `tsugino-dec084-a-r1.log` | Sandboxed CoreSimulator service access failed; specified Simulator destination unavailable. No test execution. Retried with required Simulator/cache access; no physical-device step. |
| r2 — intermediate | `tsugino-dec084-a-r2` (`.log`, `.xcresult`, `-summary.json`) | 89 functions / 195 cases passed; zero failures/skips/runtime warnings. 35 existing primary isolation + two AppIntents warnings. |
| r3 — expanded closure/input checks | `tsugino-dec084-a-r3` (same extensions) | 96 functions / 212 cases passed; zero failures/skips/runtime warnings. 27 primary isolation + two AppIntents warnings. |
| r4 — scalar/registry shape checks | `tsugino-dec084-a-r4` (same extensions) | 99 functions / 215 cases passed; zero failures/skips/runtime warnings. 27 primary isolation + two AppIntents warnings. |
| r5 — strict version/S9 duplicate guards | `tsugino-dec084-a-r5` (same extensions) | 101 functions / 219 cases passed; zero failures/skips/runtime warnings. 27 primary isolation + two AppIntents warnings. |
| r6 — final authority-label/conversion-record guards | `tsugino-dec084-a-r6` (same extensions) | Final result above; earlier overlapping runs are not summed. |

**Release verification:** Simulator Release app/extension build passed. Recorded 33 existing
primary isolation warnings and one AppIntents warning; zero build errors. Symbol inspection
of both Release executables found **zero** `SyntheticTripRegistration`, `SyntheticRegistration`
or `SyntheticTripReview` symbols. This is a new Release check for slice A, not reused evidence.

```sh
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd > /private/tmp/tsugino-dec084-a-release-r1.log 2>&1
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/TSUGINO > /private/tmp/tsugino-dec084-a-release-app-symbols.log
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/PlugIns/TSUGINOLiveActivity.appex/TSUGINOLiveActivity > /private/tmp/tsugino-dec084-a-release-extension-symbols.log
```

The inspected Release app SHA-256 is
`5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`;
extension SHA-256 is `659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`.
Self-review checked syntax-versus-admission separation, unknown/null/numeric handling,
scalar-exact bytes, independent golden fixtures, full dependency hashing, malformed-input
uncertainty precedence and DEBUG guards. Reference/historical-record checks and
`git diff --check` passed. Independent implementation approval is recorded below. No B/C
implementation, staging, commit, push, merge or real-data action occurred in this slice.

**Independent approval and publication follow-up — 2026-10-02 Asia/Seoul.** A fresh read-only
reviewer with no implementation authorship inspected actual contracts/code/tests and saved
evidence independently of author self-review. It approved bounded slice A with no material
findings or mandatory outstanding checks. All eight working files remained byte-identical
during review. The reviewer confirmed the final 101 functions / 219 cases (28 new / 56),
zero failures/skips/runtime warnings, independently recomputed golden digests, successful
Debug/Release builds, matching retained Release hashes and symbol exclusion. Publication
reuses these results; no tests/builds rerun and source/test hashes match the reviewed version.

Optional, nonblocking follow-ups: multi-run packets with distinct predecessor IDs and an
unselected run's missing predecessor; explicit coverage of raw wire duplicate-run preservation
versus adapter rejection to protect its predecessor dictionary. These remain unimplemented
follow-ups, not additional publication scope or permission for B/C. The owner separately
authorized committing/pushing exactly the eight approved files; no merge or next slice.
Representation completeness remains distinct from authentication, history/conversion validity
and registration admission. Real S9/import, registry operations, production adoption,
rights/delivery and Phase 3 exit remain separately gated.

### DEC-084 slice B local implementation — 2026-10-02 Asia/Seoul

Owner authorized B only after published slice A. Starting branch
`phase/03-route-search`, HEAD/upstream `7dd282a2162cef79e5918bbd20ff3edae88eaf40`,
clean tree; local/recorded main remains `e8a463d51f14b3cb1027960c63244b694579a71b`.
Origin is `lunalism/TSUGINO`; 0 ahead/behind using recorded refs. No rule-required fetch
or claim of fresh remote verification; no staging, commit, push or merge.

**Scope delivered:** DEBUG-only `SyntheticTripRegistrationHistory.swift` validates supplied
baseline approvals/inventories, exact bytes/digests, lineage and predecessor links, checked
revisions, retained identifiers, current-target unchanged replay versus stale/altered replay,
and conversion-only schema-2/3→4 comparison views. Original schema-2 retirement rules and
schema-3 retained sidecar rules remain distinct. Every legacy entity/reference field, optional
authority, scalar-exact name/key and exact original byte blob is preserved. It reuses slice-A
codecs/closure and the actual mapping readers. `SyntheticTripLegacyHistory.swift` is an
isolated read-only mirror of the original DEC-073 models/pure helpers/boundary validation;
source parity was checked byte-for-byte. No applier, authorization capability, IO or CLI.

`checked` reports mechanical integrity, with separate replay/conversion/seed indicators and
all retained/incoming non-conversion request IDs still needing C. It emits no candidate bytes
and does not establish complete business-history validity. Missing completeness/dependencies
hold; independently established conflicts reject with retained ordered uncertainty diagnostics.
Invented schema-4 absent/retired-reference seeds are stipulated premises, never external
history verification or real-lineage reset. Held/rejected inputs remain unchanged.

**Slice C obligations retained:** registration/attachment admission, affirmative returning-key
continuity, complete explanation of Trip deltas, proof/profile applicability, DEC-082-backed
initial snapshot selection/revision and downstream revalidation. No source authentication,
real S9/import, registry mutation/conversion/allocation or production adoption. Rights,
publication/delivery and Phase 3 exit gates are unchanged. Independent B implementation
review is pending; author self-review is not independent approval.

**Final verification:** 98 functions / 187 executed cases passed, comprising B 33/40,
A 28/56 and MappingRegistry 37/91. Zero failures, skips or runtime warnings. Debug app and
extension dependencies built. Final Debug log records 27 existing primary isolation warnings
(54 including repeated rendered diagnostic lines) and two AppIntents warnings; no new warning.
Saved `/private/tmp/tsugino-dec084-b-r5.{log,xcresult}` and `-r5-summary.json` are the final
evidence; overlapping runs below are not summed. No physical-device step.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -only-testing:TSUGINOTests/MappingRegistryTests -resultBundlePath /private/tmp/tsugino-dec084-b-r5.xcresult > /private/tmp/tsugino-dec084-b-r5.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-b-r5.xcresult --format json > /private/tmp/tsugino-dec084-b-r5-summary.json
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd > /private/tmp/tsugino-dec084-b-release-r1.log 2>&1
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/TSUGINO > /private/tmp/tsugino-dec084-b-release-app-symbols.log
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/PlugIns/TSUGINOLiveActivity.appex/TSUGINOLiveActivity > /private/tmp/tsugino-dec084-b-release-extension-symbols.log
```

Release app/extension build passed with 33 existing primary isolation warnings and one
AppIntents warning. Both symbol logs have zero matches for `SyntheticTripRegistration`,
`SyntheticRegistration`, `SyntheticTripLegacyHistory` or `SyntheticTripReview`. Release hashes
are unchanged from A: app `5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`,
extension `659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`.
Counts/hashes are saved in `/private/tmp/tsugino-dec084-b-verification.json`. Prior DEC-082
36/72 and unrelated evidence are reused, not rerun: their source/tests and shared production
readers/enums are unchanged. Release exclusion was checked anew for the added files.

**Earlier attempts, separately recorded.** r1–r4 used the exact final test command above
with `-only-testing:TSUGINOTests/MappingRegistryTests` omitted and the result/log suffix
changed from r5 to the respective run. Summary extraction used the corresponding bundle
and `-summary.json` paths.

| Attempt | Saved result and disposition |
|---|---|
| r1 | Compile failure: used `C.maxBytes` instead of the existing `C.maximumBytes`; fixed. No tests executed. Log/result bundle retained. |
| r2 | 41/43 functions and 72/74 cases passed; two assertion failures. Altered replay correctly returned two distinct conflict locators; expected list corrected. Malformed history was rejected by the strict encoder before invocation; test changed to feed raw malformed bytes directly. 35 existing primary isolation + two AppIntents warnings. |
| r3 | 46/52 functions and 77/84 cases passed. Six failing functions/seven cases used an invalid invented provenance fixture mixing GTFS member/table and ODPT recordIndex. Fixed fixture to original rules. One AppIntents warning, no primary isolation warning in incremental log. |
| r3 report attempt | Summary command ran before bundle finalization: missing Info.plist; the following JSON read also failed on empty output. No additional test run. Extraction succeeded after xcodebuild exited; saved final r3 summary replaces the empty report. |
| r4 | Intermediate expanded suite: 56 functions / 88 cases passed; zero failures/skips/runtime warnings. 27 existing primary isolation + two AppIntents warnings. Later compatibility/seed-chain controls are included in final r5. |

Self-review covered construction safety, retained-ID conflicts, scalar-exact conversion,
no retrospective legacy rule expansion, seed completeness versus contradictions, exact/stale
replay, overflow, immutable inputs and the B/C output boundary. Reference/case/historical-record
checks, source parity and `git diff --check` passed. Six intended files remain uncommitted:
the two new DEBUG sources, `SyntheticTripRegistrationHistoryTests.swift`, and DECISIONS,
ARCHITECTURE, ROADMAP. Independent implementation review is the next step; C is not started.

### DEC-084 slice B review corrections — 2026-10-02 Asia/Seoul

Independent review withheld approval for two mechanical-integrity defects: a legacy
`attachedBy` or retirement `status.review` ID could be reused by the new baseline approval,
and seed selections tested membership among all entities instead of requiring a held Trip.
The original r5 verification above remains historical evidence, not approval of those paths.

**Corrections:** `SyntheticTripRegistrationHistory.swift` now distinguishes full fresh ID
introductions from retained authority/allocation associations. Repeated quotations of an
existing authority remain legal; a new approval/record/allocation colliding with it rejects
regardless of discovery order. The immediately related audit includes inventory quotations,
seed authorities, legacy sidecar authorities and all known baseline reference authorities,
including incomplete inventory. A baseline inventory may quote an existing profile approval
only when its complete profile is digest-bound in that baseline; this does not allow a
profile approval to reuse a known legacy/seed authority. No evidence authentication is added.

Every seed selection now checks for an existing `trp` entity before artifact lookup. A known
wrong-kind or unheld target yields `historyConflict` even if its artifact is missing;
applicable `historyUnavailable`/`snapshotUnavailable` diagnostics are retained in accepted
order. Valid held-Trip targets with missing artifacts still hold. Artifact identity comparison
remains in place. This is baseline inventory consistency, not S9 candidate admission.

**Focused regressions:** six new functions / 20 cases (b34–b39) assert exact outcomes and
diagnostic codes/locators. They cover both legacy authority fields with/without completeness,
legal repeated reference/inventory quotations, later incoming approval collisions, retained
sidecar quotations versus fresh reuse, known seed authority with missing inventory, Station/
Line/unheld-Trip selections with present/missing artifacts, valid Trip/missing-artifact controls,
and retained profile approval quotation versus legacy authority reuse. The optional legacy
multi-transfer coverage observation was not implemented.

**Final correction verification:** history 39 functions / 60 executed cases and slice A
28/56, **67 functions / 116 cases total**, all passed. Zero failures/skips/runtime warnings.
Debug app/extension dependencies built; 27 existing primary isolation warnings (54 rendered
lines including repeats) and two AppIntents warnings, no new warning. This correction had
one test attempt and no failed attempts. Do not sum it with overlapping earlier runs.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -resultBundlePath /private/tmp/tsugino-dec084-b-correction-r1.xcresult > /private/tmp/tsugino-dec084-b-correction-r1.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-b-correction-r1.xcresult --format json > /private/tmp/tsugino-dec084-b-correction-r1-summary.json
```

Saved evidence uses that `.log`, `.xcresult` and `-summary.json`. Prior MappingRegistry
37/91, DEC-082 36/72 and unrelated verification are reused: their code/tests are unchanged.
Prior slice-B Release app/extension evidence and zero synthetic-symbol exclusion remain
applicable: every source correction is inside the existing `#if DEBUG`; shared readers,
legacy mirror, production composition/project settings and Release guards are unchanged.
The retained Release binaries still match their recorded hashes and have zero matching
synthetic symbols. No Release rebuild or physical-device step was needed.

Only the history validator, its tests and ROADMAP changed further in this correction; the
existing six-file working inventory remains intact. DECISIONS, ARCHITECTURE and the legacy
mirror are byte-identical to the reviewed versions. Accepted records, case/reference checks,
legacy-source parity and `git diff --check` pass. HEAD/upstream remains
`7dd282a2162cef79e5918bbd20ff3edae88eaf40`, 0 ahead/behind recorded refs; main is unchanged.
No rule-required fetch, staging, commit, push or merge. **Focused independent re-review is
pending.** No slice-C admission, real S9/import, conversion execution/registry mutation,
allocation, production adoption, rights/delivery or Phase 3 exit gate changes.

### DEC-084 slice B immutable-ID correction and path audit — 2026-10-02 Asia/Seoul

The focused independent re-review confirmed the preceding targeted fixes but withheld
approval for two remaining omissions: baseline payload `subjectID` was never reserved
against historical authorities, and inline evidence bypassed the reservation used by
catalog evidence. That review was performed by fresh non-author reviewers; its coordinator
authored the implementation. The earlier verification entries remain historical evidence.

**Corrections:** the baseline payload ID now enters the common fresh-introduction ledger
alongside its approval. Inline evidence joins the same collected-document path as catalog
and retained dependency bytes. The full path audit corrected the same omission for declared
attachment/status IDs with missing bytes, supplied seed documents outside the inventory,
explicit seed predecessor and selected-artifact IDs, and digest-bound dependencies already
retained by the baseline or a history boundary. Missing bytes do not free these historical
IDs. Matching supplied documents may be quoted only with the same record kind, and retained
dependency digests cannot change while bytes are missing. Catalog authority labels alone
do not establish historical membership. Repeated retained associations and identical
dependency references remain legal; established conflicts reject with ordered uncertainty.
Historical dependency traversal follows only exact digest-matched documents, with a visited
set: missing outer closure entries cannot hide their nested retained assertions. A nested
baseline-bound profile retains its approval association even when its outer entry is missing;
the missing entry still holds, without inventing a fresh-ID conflict.

**Collection-to-reservation audit (accepted DEC-084 §B/§D):**

| ID-bearing record / supported representation | Ledger path and distinction | Focused coverage |
|---|---|---|
| Baseline payload `subjectID`, `envelope.baseline.payload` | `run` → `reserve`, separate from the baseline approval | b40; b42 baseline |
| Approval `reviewID`, baseline / inline, catalog or retained profile / incoming request / retained boundary | `approve` → `reserve`; the existing digest-bound profile-inventory quotation exception includes exact nested baseline dependencies | b34–b37, b39; b42 approval/profileApproval, b50 |
| Profile `subjectID` / `profileID`, inline / catalog / retained bytes | Closure enforces matching wrapper/body ID; `collect` or catalog admission → one document reservation; its approval is checked separately | b39; b42 profile/profileApproval, including retained bytes |
| Evidence `evidenceID`, inline / catalog / both / retained bytes | One collected immutable document → `reserve`; equal duplicate transport is a reference, changed bytes still reject in A closure | b41's four transports, collision/completeness and valid controls; b42 evidence |
| S9 `artifactID`, inline / catalog / retained bytes | One collected immutable document → `reserve`; seed-selected artifact IDs retain historical identity even when bytes are missing. Packet UUIDs remain associations | b38; b42 artifact, including retained bytes; b45 and retained A closure tests |
| Request wrapper `subjectID` / `requestID`, incoming and every retained boundary | Closure enforces equality; `delta` → `reserve`. Exact current-target replay reuses the retained introduction; altered replay rejects before it can escape as success | b06–b07, b12–b13, b33; b42 request |
| Operation `recordID`, registration / attachment / initial-selection or revision records; `allocationRequestID` on registration | `delta` reserves every record and allocation before registry comparison, for incoming and retained requests; no business admission is inferred | b42 record/allocation, both incoming and retained |
| Seed attachment/status `recordID`, catalog / retained bytes; explicit inventory/predecessor token with or without bytes | All supplied seed documents → `reserve` once; inventory and explicit predecessor assertions → retained `.seedRecord` before lookup. Only quotation of its matching supplied seed document is exempt from a second introduction | b16–b18, b31; b42 all nine fresh introduction channels with missing bytes; b43 unlisted supplied document/control; b44 missing predecessor |
| Digest-bound historical dependencies, baseline and retained boundary inventories, including exact nested documents | `dependencies(historical:true)` retains kind/ID/digest, including unavailable records. Matching supplied records may be quoted; later digest/kind changes reject. Incoming declarations are compared to known retained digests but do not themselves establish history | b46 all four kinds, b47 retained-boundary missing dependencies, b48–b49 changed/unchanged digest and missing outer-entry controls, b50 retained profile |
| Historical review/allocation inventory tokens, listed seed `authorityID`, baseline `attachedBy` / retirement `status.review`, validated legacy transition/disposition IDs | `retain` records associations; repeats remain legal. Legacy sidecar returns retained authorities under its unchanged original rules | b20, b34–b37, b39–b43 |

History/boundary/checkpoint containers have no separate fresh record ID: lineage, digests,
predecessor links, dependency IDs and approval subject references associate the records
above. Canonical entity IDs retain their separate registry/body-history checks; source keys,
profile versions, evidence applicability labels and S9 UUIDs are not promoted into a new
global uniqueness policy. No additional demonstrable omission remained in this audit.
The read-only audit assistance is implementation verification, not independent approval.

**Regressions and final verification:** b40–b50 add **11 functions / 67 cases** with exact
outcomes and diagnostic codes/locators. They cover both legacy authority fields, repeated
associations, incomplete history, equivalent evidence transports and nonconflicting controls,
input preservation, missing inventory IDs across nine introduction channels and incoming/
retained requests, unlisted supplied seed IDs, missing explicit predecessors/selections and
retained dependency identities/digests and nested closure/profile controls.
Final focused run: history **50/127** plus slice A **28/56**, **78 functions / 183 executed
cases passed**, zero failures/skips/runtime warnings. Debug app/extension dependencies built.
The log contains 27 existing primary
isolation warnings (54 rendered lines including repeats) and two AppIntents warnings, with
no other warning. Overlapping earlier runs are not summed. No physical-device step.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -resultBundlePath /private/tmp/tsugino-dec084-b-ids-r4.xcresult > /private/tmp/tsugino-dec084-b-ids-r4.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-b-ids-r4.xcresult --format json > /private/tmp/tsugino-dec084-b-ids-r4-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-b-ids-r4.xcresult --format json > /private/tmp/tsugino-dec084-b-ids-r4-tests.json
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/TSUGINO > /private/tmp/tsugino-dec084-b-ids-release-app-symbols.log
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/PlugIns/TSUGINOLiveActivity.appex/TSUGINOLiveActivity > /private/tmp/tsugino-dec084-b-ids-release-extension-symbols.log
```

**Tooling failures, separate from test results:** the initial sandboxed test command was
identical except for `-ids-r1` result/log paths; it exited 70 because CoreSimulator was
inaccessible and the specified Simulator destination could not be resolved. No tests ran.
The authorized access retry r2 passed. Initial sandboxed summary and test-tree extraction
used the shown commands with r2 paths; each exited 64 because `xcresulttool` could not write
its TestReport cache. The same commands
with cache access then succeeded. No test rerun was needed for report extraction. The
intermediate successful r2 and r3 commands used the final command above with the respective
suffix: r2 passed 71 functions / 156 cases; r3 passed 76 / 178, each with zero failures/skips/
runtime warnings and the same 27 primary isolation / two AppIntents warnings. These preceded
additional audit corrections and are not the final result or summed with it. Their logs,
result bundles and summary JSON remain separate. Saved final
results are the final `.log`, `.xcresult`, `-summary.json`, `-tests.json` and
`/private/tmp/tsugino-dec084-b-ids-counts.json`.

**Reused evidence and preservation:** the prior Release build remains applicable because
all source corrections stay inside unchanged `#if DEBUG` guards; shared readers/enums,
production composition, project settings and the legacy mirror are unchanged. Recomputed
retained binary hashes remain app `5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`
and extension `659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`; both
symbol lists have zero matches for the previously recorded synthetic-symbol patterns.
Hashes/counts are retained in `/private/tmp/tsugino-dec084-b-ids-release-reuse.json`.
No Release rebuild; unchanged MappingRegistry, DEC-082 and unrelated evidence are reused.
Legacy models/helpers/boundary validation remain byte-identical to their authoritative
source. Accepted records, references and `git diff --check` pass.

Only `SyntheticTripRegistrationHistory.swift`, `SyntheticTripRegistrationHistoryTests.swift`
and ROADMAP changed further; the six-file working inventory is preserved. DECISIONS,
ARCHITECTURE and `SyntheticTripLegacyHistory.swift` remain byte-identical to the pre-task
versions. HEAD/upstream remains `7dd282a2162cef79e5918bbd20ff3edae88eaf40`, 0 ahead/behind
recorded refs; main remains `e8a463d51f14b3cb1027960c63244b694579a71b`. No rule-required fetch,
staging, commit, push or merge. **Independent re-review remains pending.** Mechanical success
still grants no slice-C registration/attachment/S9 admission, actual conversion/mutation/
allocation, real S9/import, production adoption, rights/delivery or Phase 3 exit clearance.


### DEC-084 slice B shared-authority and variant corrections — 2026-10-02 Asia/Seoul

The next independent re-review withheld approval for two remaining findings: a local seed
set rejected distinct attachments quoting one existing authority, and conflicting retained,
inline or catalog copies could overwrite one another and change the diagnostic set.
The owner authorized these corrections and the directly related collection/seed audit only.
Earlier verification remains historical evidence; no acceptance or publication is added.

**Corrections and bounded audit:** distinct seed records/keys may share historical
`authorityID`/`attachedBy`. Record IDs and fresh approvals still enter the common introduction
ledger; retained authority quotations remain repeatable associations. Collection retains
all distinct canonical byte variants, deduplicates equivalent copies across transports,
validates catalog identity/kind and preserves the original unique-catalog-key requirement.
Keys and variants are inspected in deterministic order. Every profile wrapper/approval pair
is checked, with identical approval bytes introduced once; all variants' fresh IDs remain
protected against historical authority reuse.

The related audit found the same single-copy omission in dependency traversal and seed
inspection. Historical traversal now records and visits exact `(kind, ID, digest)` bindings,
including distinct explicitly retained variants and nested unavailable IDs. Only those exact
bindings confer historical membership; an unrelated alternative catalog copy does not.
Exact predecessor SHA bindings also traverse supplied matching bytes when their inventory entry
is absent, retaining the missing-inventory diagnostic and known nested reservations.
Each parent's closure resolves its declared digests. For conflicting variants, B retains A's
strict syntax/approval checks and recomputes the affected integrity/availability diagnostics
in that context, avoiding both hidden missing evidence and false extra-dependency findings.
All declared/direct variant edges participate in deterministic ID-cycle checks; evidence
applicability labels are still associations, never reverse dependency edges.

Every digest-bound seed variant retains its authority/predecessor assertions and local
checks. A predecessor link selects the exact asserted digest among supplied retained copies;
missing records and present inconsistent bytes remain distinct. No conflicting copy becomes
an arbitrary lineage witness. Seed selections retain the existing Trip-kind-before-artifact
check and inspect every exact bound artifact. These are mechanical history/representation
checks, not slice-C correspondence, registration or S9 admission.

| Focused regression | Exact outcome/diagnostic coverage |
|---|---|
| b51 | Two distinct attachment records and keys share one authority; fresh reuse rejects; incomplete-only holds; conflict plus incomplete rejects with ordered uncertainty; record/catalog order permutations |
| b52 | Retained/inline/catalog/equivalent profile copies, either copy's approval colliding with historical authority, complete/incomplete history, catalog and object insertion orders, unchanged inputs |
| b53–b55 | Exact digest-bound seed authority versus an unbound conflicting copy; duplicate original catalog keys stay invalid; mismatched profile identity is malformed without invented secondary findings |
| b56 | A cycle in an alternative seed/artifact copy cannot disappear behind another copy, including exact history/snapshot conflict locators |
| b57 | Every explicitly retained variant reserves its nested missing IDs; legal retained profile approval quotations; fresh-ID conflict plus missing completeness; both catalog orders |
| b58 | Correct parent closure under its declared variant versus missing outer inventory; no false extra-dependency conflict; both orders |
| b59 | Local missing-predecessor uncertainty on conflicting bound seed copies; exact predecessor continuity conflict and legal continuity control; both orders |
| b60 | Exact predecessor bytes with a missing inventory entry still protect nested evidence and authority IDs; missing-only versus fresh-ID conflict, both orders |


**Final focused verification:** history **60 functions / 189 cases**, slice A **28/56**;
**88 functions / 245 executed cases passed**, including b51–b60's **10 new functions /
62 cases**. The additional order loops inside parameter cases are not counted as separate
executed cases. Zero failures, skips or runtime warnings. Debug app/extension dependencies
built on the explicit iPhone 17 Simulator (iOS 26.5); no physical-device step. Final log:
27 existing primary isolation warnings (54 rendered lines including repeats), two AppIntents
warnings, no other warning. Saved final evidence:
`/private/tmp/tsugino-dec084-b-variants-r5.{log,xcresult}`, `-r5-summary.json`,
`-r5-tests.json` and `/private/tmp/tsugino-dec084-b-variants-counts.json`.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -resultBundlePath /private/tmp/tsugino-dec084-b-variants-r5.xcresult > /private/tmp/tsugino-dec084-b-variants-r5.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-b-variants-r5.xcresult --format json > /private/tmp/tsugino-dec084-b-variants-r5-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-b-variants-r5.xcresult --format json > /private/tmp/tsugino-dec084-b-variants-r5-tests.json
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/TSUGINO > /private/tmp/tsugino-dec084-b-variants-release-app-symbols.log
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/PlugIns/TSUGINOLiveActivity.appex/TSUGINOLiveActivity > /private/tmp/tsugino-dec084-b-variants-release-extension-symbols.log
```

**Intermediate attempts, not summed:** the same test/summary commands used `-variants-r1`
through `-variants-r4` paths. r1 passed 83/217; r2 passed 84/221. r3 passed 85 of 86 functions
and 225 of 233 cases: all eight b57 cases failed because the invented baseline declared A/Z
without referencing them, correctly producing an extra `historyConflict(invented-lineage)`.
The fixture was corrected to reference those parents through the held seed; assertions were
not weakened. Failure details are retained in the r3 bundle/summary and
`-r3-b57.json`, extracted with:

```sh
xcrun xcresulttool get test-results test-details --path /private/tmp/tsugino-dec084-b-variants-r3.xcresult --test-id 'SyntheticTripRegistrationHistoryTests/b57EveryExplicitHistoricalVariantRetainsItsNestedIDs(_:_:)' > /private/tmp/tsugino-dec084-b-variants-r3-b57.json
```

r4 passed 87/239 before the final exact-predecessor missing-inventory regression. Every
intermediate run had zero skips/runtime warnings and the same 27 primary isolation / two
AppIntents warnings. These results remain separate from final r5. No Simulator-access or
report-cache failure occurred in this correction; authorized tool access reused the known
working environment. Prior access/cache failures remain recorded above; unavailable raw
stderr from earlier report-cache attempts was not inspected or reconstructed. One read-only
reference lookup initially used nonexistent `docs/RULES.md`; it was corrected to root
`RULES.md`. No file changes resulted from that lookup.

**Reused evidence and preservation:** retained Release app/extension hashes still match
`5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e` and
`659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`. Fresh symbol inspection
found zero matches for `SyntheticTripRegistration`, `SyntheticRegistration`,
`SyntheticTripLegacyHistory` or `SyntheticTripReview` in either binary. Saved hashes/counts:
`/private/tmp/tsugino-dec084-b-variants-release-reuse.json`. All corrections remain inside
unchanged DEBUG guards; A source, shared readers/enums, production composition and project
settings are unchanged. Prior Release build, MappingRegistry 37/91, DEC-082 36/72 and
unrelated evidence remain applicable; no Release rebuild or unrelated suite rerun.

Only `SyntheticTripRegistrationHistory.swift`, `SyntheticTripRegistrationHistoryTests.swift`
and ROADMAP changed further. The existing six-file working inventory is preserved;
DECISIONS, ARCHITECTURE and `SyntheticTripLegacyHistory.swift` are byte-identical to task start.
Accepted records, TR84 cases, references, regression identifiers, legacy-source parity and
`git diff --check` pass. HEAD/upstream remains `7dd282a2162cef79e5918bbd20ff3edae88eaf40`,
0 ahead/behind using recorded refs; local/recorded main remains
`e8a463d51f14b3cb1027960c63244b694579a71b`. No rule-required fetch, staged changes, commit,
push or merge; no fresh remote agreement is claimed.

**Implementation review remains pending.** Author self-review and read-only audit assistance
are not independent approval. No slice C, registry candidate, real conversion/mutation or
allocation is introduced. Real S9/import, production adoption, rights/publication/delivery
and Phase 3 exit gates remain unchanged.


### DEC-084 slice B predecessor-binding correction — 2026-10-02 Asia/Seoul

Independent re-review withheld approval for one remaining explicit-binding defect: a
baseline could bind unavailable predecessor P to H1 while a retained status named H2,
but the availability guard skipped the second digest assertion and returned only a hold.
The owner authorized this correction and a directly related binding-path audit, not C.
The preceding final 88/245 result remains historical evidence, not approval of that path.

**Correction:** manifests and paired seed predecessor ID/SHA assertions enter the common
binding comparison before byte resolution. Missing bytes still hold; equal assertions do
not fabricate a conflict. Available copies that cannot match an explicit digest reject
without being inspected as historical payloads. This preserves the missing-inventory hold
when a supplied predecessor's bytes disagree, and prevents its unbound authority/reference
contents from becoming historical assertions.

The adjacent audit found the same omission for an incoming request and supplied profile
that name different hashes for the same missing evidence. A separate `observedBindings`
ledger now compares all codec-valid supplied explicit declarations, including catalog,
inline and retained forms, before lookup. Only the existing historical traversal populates
`retainedBindings` and historical identity reservations. Observing a declaration neither
introduces an unavailable payload nor grants historical membership. ID-only references,
proof/view applicability labels and source-content hashes do not become dependency bindings.
Malformed catalog identities are excluded before this pass.

**Directly related audit:** baseline and retained-boundary manifests, incoming requests,
collected profile/evidence/artifact/seed manifests and paired seed predecessor assertions
all reach comparison before the availability guard. Nested payload traversal still requires
exact matching bytes and a `(kind, ID, digest)` visit guard. Checkpoint/boundary links retain
their separate exact-byte checks. Approval payload digests are checked against supplied
wrappers. No slice-C previous-reference/selection semantics or new identity policy is added.

**Focused regressions:** b61–b65 add five functions / 30 executed cases; internal order loops
are not counted as extra executed cases. b61 combines equal/different explicit predecessor
digests with absent/present bytes, declaration order, catalog order, decoded versus constructed
record forms and object insertion order. b62 compares two retained predecessor assertions
when bytes are missing, including incomplete history. b63 covers incoming/nested evidence
digests through inline/catalog/both representations with absent/present controls. b64 checks
unreferenced supplied profile assertions without promoting them to history. b65 covers
missing inventory with absent, matching or mismatching predecessor bytes and incomplete
history; exact assertions exclude invented authority/continuity findings from mismatching
bytes. Existing b31's resolved wrong-digest case now asserts both established conflict
locators, rather than losing the predecessor's conflicting binding. Earlier ID, authority,
selection, replay, conversion and variant regressions remain part of the focused suite.


**Final verification:** history **65 functions / 219 cases** and slice A **28/56**,
**93 functions / 275 executed cases passed**, including b61–b65's **5/30**. Zero failures,
skips or runtime warnings. Debug app/extension dependencies built on the explicit iPhone 17
Simulator (iOS 26.5); no physical-device step. Compiler/tool warnings remain separate:
27 existing primary isolation warnings (54 rendered lines including repeats), two AppIntents
warnings and no other warning. Saved final evidence:
`/private/tmp/tsugino-dec084-b-predecessor-r2.{log,xcresult}`, `-r2-summary.json`,
`-r2-tests.json` and `/private/tmp/tsugino-dec084-b-predecessor-counts.json`.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -resultBundlePath /private/tmp/tsugino-dec084-b-predecessor-r2.xcresult > /private/tmp/tsugino-dec084-b-predecessor-r2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-b-predecessor-r2.xcresult --format json > /private/tmp/tsugino-dec084-b-predecessor-r2-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-b-predecessor-r2.xcresult --format json > /private/tmp/tsugino-dec084-b-predecessor-r2-tests.json
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/TSUGINO > /private/tmp/tsugino-dec084-b-predecessor-release-app-symbols.log
xcrun nm -a /private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/TSUGINO.app/PlugIns/TSUGINOLiveActivity.appex/TSUGINOLiveActivity > /private/tmp/tsugino-dec084-b-predecessor-release-extension-symbols.log
```

The intermediate r1 used the same test/report commands with `-predecessor-r1` paths and
passed **92/269**, with zero failures/skips/runtime warnings and the same 27 primary
isolation/two AppIntents warnings. The audit then identified the missing-inventory/present-
mismatching-bytes edge, corrected before final r2 and covered by b65. These overlapping runs
are not summed. **No failed verification or tooling attempts occurred in this correction.**
Older failed attempts remain separately recorded above; no unavailable raw stderr was
inspected or reconstructed.

**Reused Release evidence:** all source changes remain inside unchanged whole-file DEBUG
guards. A sources, shared readers/enums, production composition/project settings and legacy
validation code are unchanged. Retained Release app/extension SHA-256 values remain
`5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e` and
`659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`; fresh symbol inspection
found zero `SyntheticTripRegistration`, `SyntheticRegistration`, `SyntheticTripLegacyHistory`
or `SyntheticTripReview` matches in either binary. Hashes/counts are saved in
`/private/tmp/tsugino-dec084-b-predecessor-release-reuse.json`. No Release rebuild; unchanged
MappingRegistry 37/91, DEC-082 36/72 and unrelated evidence are reused.

Only `SyntheticTripRegistrationHistory.swift`, `SyntheticTripRegistrationHistoryTests.swift`
and ROADMAP changed further. The six-file working inventory is preserved; DECISIONS,
ARCHITECTURE and `SyntheticTripLegacyHistory.swift` remain byte-identical to task start.
Self-review checked explicit assertions versus historical membership, unavailable versus
mismatching bytes, exact diagnostic order and the absence of slice-C admission. Read-only
audit assistance is not independent approval. References/case identifiers, accepted-record
preservation, affected legacy-source parity and `git diff --check` pass.

HEAD/upstream remains `7dd282a2162cef79e5918bbd20ff3edae88eaf40`, 0 ahead/behind recorded refs;
local/recorded main remains `e8a463d51f14b3cb1027960c63244b694579a71b`. No rule-required fetch,
staging, commit, push or merge; no fresh remote agreement is claimed. **Focused independent
re-review pending.** No real/private-data access, conversion execution, registry mutation or
allocation. Slice C, real S9/import, production adoption, rights/publication/delivery and
Phase 3 exit gates remain unchanged.

### DEC-084 slice B independent approval and publication follow-up — 2026-10-02 Asia/Seoul

Final read-only re-review approved the corrected bounded slice B with no remaining material
findings or mandatory verification gaps. Returning code and evidence reviewers authored none
of the implementation/corrections; their prior exposure was review/audit only. The author
coordinated preservation checks, which are not independent approval. All six working files
remained byte-identical during review. Earlier pending/withheld records above describe their
historical stages; this entry records the final outcome.

Review confirmed explicit predecessor/dependency conflicts before byte lookup, missing-only
uncertainty, ordered conflict-plus-unavailability diagnostics and exclusion of mismatching
payloads from historical inspection. b61–b65 cover equal/resolved controls and representation/
order permutations. Earlier shared-authority, immutable-ID, conflicting-variant and held-Trip
selection protections remain intact. Approval is limited to mechanical history/checkpoint
integrity and conversion-only validation; `checked` emits no candidate and retains all
non-conversion business-admission obligations for C.

The reviewers independently verified the final r2 evidence above: **93 functions / 275
passing cases** (B 65/219 plus A 28/56, including b61–b65's five/30), zero failures, skips or
runtime warnings, and successful Debug app/extension dependency builds. The **27 primary
isolation warnings** (54 rendered lines) and **two AppIntents warnings** remain separate.
Intermediate runs are not summed; earlier failures retain their own records. Retained Release
build evidence, matching app/extension hashes and zero synthetic-symbol matches remain
applicable because whole-file DEBUG isolation and production composition are unchanged.
No tests/builds are rerun for publication.

The owner authorized committing/pushing exactly the two slice-B sources, their history tests
and DECISIONS/ARCHITECTURE/ROADMAP. Pre-publication fetch confirmed the existing phase upstream
at `7dd282a2162cef79e5918bbd20ff3edae88eaf40`, 0 ahead/behind, and main at
`e8a463d51f14b3cb1027960c63244b694579a71b`. Source/test SHA-256 values match the independently
reviewed bytes:

| File | SHA-256 |
|---|---|
| `SyntheticTripRegistrationHistory.swift` | `4c367492a465c83fb6d18b0a54217d9a6f3a27a3999a98c06dbb3e6d201660a5` |
| `SyntheticTripLegacyHistory.swift` | `1227b015af3fdbf98317cccfd43711f9617bc62f26149a1bcd816ddca09e0616` |
| `SyntheticTripRegistrationHistoryTests.swift` | `52e395c0a85fa1dc39df4869b3ceae786a98c28425175e8aa05431e2f54843de` |

Publication changes approval/status documentation only beyond those reviewed bytes. No
optional follow-up or slice C is implemented. Accepted semantics and historical records are
preserved. No merge, main push, branch deletion or next slice is authorized. Registration/S9
admission, real conversion/registry operations, real-data/import, production adoption,
rights/publication/delivery and Phase 3 exit remain separately gated.

### DEC-084 slice C1 scope lock and contract-to-test plan — 2026-10-02 Asia/Seoul

The owner authorizes the first bounded part of C on the existing Phase 3 branch, starting
at `6a688b5d593ee5bb03ced3fca8711e48df635528` with a clean tree. C1 covers supplied invented
Trip IDs for identity-only registration, new-key attachment and returning-reference attachment,
applicable approved source/correspondence evidence, complete delta accounting and atomic
in-memory synthetic output. Reviewed A codecs/closure and B mechanical checks are reused.
Every retained and incoming non-conversion boundary needed by a result must receive business
admission; mechanical replay alone cannot bypass it. No new semantic decision is accepted.

C2 remains deferred: registration with `snapshotArtifactID`, initial snapshot selection,
snapshot revision, full DEC-082 predecessor/proof/view reconstruction and downstream snapshot
revalidation. The C1 entry point/result must expose this incomplete implementation boundary
without treating deferred functionality as a railway contradiction or emitting a complete
candidate. C1 cannot approve business history requiring C2.

| Accepted contract / C1 boundary | Planned focused invented controls |
|---|---|
| DEC-083 A; DEC-084 A/B: explicit approved distinct-run registration, active supplied `trp`, all-history body uniqueness | Identity-only registration; wrong kind/form; active/retired cross-kind body collision; duplicate entity/key claims; no allocation |
| DEC-083 B/C; DEC-084 B: active held target and previously unheld scoped key | Valid new-key attachment; missing/retired/changed target; historical key collision and rebinding |
| DEC-083 C; DEC-084 B/C: exact absent predecessor, affirmative continuity, permanent authority | Valid return; missing/contradictory continuity; wrong predecessor; retired return; unchanged attaching authority/first-seen hash; legal repeated authority associations |
| DEC-084 C: applicable approved profile/evidence, no heuristic correspondence | Exact source/input/key/Trip/record controls; unrelated support; missing versus contradictory scope/correspondence; conflict with unrelated missing evidence |
| DEC-084 E: complete accounting and atomicity | Unexplained differences; frozen non-Trip data; multi-record atomicity; record order; exact ordered diagnostics; byte-preserved inputs |
| DEC-084 B: current-target replay only after business admission | Valid replay; stale/altered reuse; retained invalid registration/attachment cannot pass through mechanical success |
| C1 authorization boundary, with C2 deferred | Incoming and retained snapshot-dependent operations cannot escape as complete C1 success |

Implementation remains subject to confirming that the accepted representation can express
these checks without new defaults. Expected work is isolated DEBUG admission code/tests and
current-truth documentation, with focused C1 and affected A/B regressions, Debug dependencies
and Release symbol-exclusion verification. No production enum/reader change, allocator,
filesystem loader/writer, CLI, source parsing/authentication or real/private inputs. No
staging, commit, push or merge. Real P2-S9/P3-T1 import, registry adoption, rights/delivery
and Phase 3 exit remain separate.

Contract inspection confirms that the approved operation and named evidence lists supply
assertion purpose: registration correspondence is the distinct-run claim, attachment
correspondence is the same-run claim, and profile lists identify uniqueness/meaning/continuity
support. C1 does not invent a closed vocabulary for the existing descriptive `evidence.role`
token. Evidence must explicitly cover the actual approved record's key/Trip/record and
profile/version/input applicability; empty arrays are not wildcards. C1 has no expected S9
view and does not manufacture one. Missing profile-wide coverage therefore remains held.
An outer C1 capability result can defer required snapshot admission without adding a railway
rejection rule. This resolves the representation check within the accepted contract.

### DEC-084 slice C1 local implementation and verification — 2026-10-02 Asia/Seoul

Implemented `SyntheticTripRegistrationAdmission.validateIdentityOnly` and invented
`SyntheticTripRegistrationAdmissionTests`, both entirely DEBUG-only. A/B sources and tests,
shared registry readers/enums, production composition and project configuration are unchanged.
The C1 result separates atomic identity-only candidate/unchanged replay, held/rejected
diagnostics and `outsideC1` capability limits. Candidate bytes preserve the retained history,
append the approved boundary and derive its checkpoint through the accepted acyclic encoding;
the candidate also identifies a stipulated seed premise. It grants no authenticated lineage,
real mutation, allocation or production adoption. C2 remains unimplemented.

Self-review and read-only implementation-audit assistance checked the complete C1 path;
neither is independent implementation approval. Scope/correspondence is admitted under one
applicable approved profile, using exact dependency-bound bytes and explicit applicability.
Negative assertions require the local approval for their purpose. Baseline owner authority
cannot be replaced by the envelope label. Missing approval cannot manufacture a contradiction;
independent key/target/history contradictions still reject with applicable uncertainty. Earlier
intermediate runs predate these final controls and are recorded separately below.

| Implemented contract coverage | Invented test IDs in `SyntheticTripRegistrationAdmissionTests` |
|---|---|
| Identity-only registration, held active targets, exact candidate and returning authority | c01–c09, c38–c43 |
| Applicable profile/purpose/input/key/Trip/record evidence, complete joint support, competing negatives and uncertainty | c10–c18, c32–c36, c40 |
| Frozen non-Trip data, explained deltas, atomic record order and duplicate claims | c19–c22, c37 |
| Retained business admission before unchanged replay; later-checkpoint freshness | c23–c27; affected B replay/altered-reuse controls remain passing |
| Explicit conversion/C2 capability limits, including retained snapshot operations | c28–c30 |
| Scalar-exact keys and inline/catalog equivalence | c31, c33 |
| Profile/request approval gates, independent conflicts and immutable baseline authority | c44–c47 |

**Final focused run (`r4`): 140 functions / 384 executed cases passed**, with zero failures,
skips or runtime warnings. Counts by suite are A codec **28/56**, B history **65/219**,
C1 admission **47/109**. This is one combined run; overlapping runs are not summed.
Debug app/extension dependencies succeeded. The final incremental test-only run emitted zero
compiler warnings and one AppIntents warning. The preceding `r3` compiled the identical final
admission source and emitted the existing 27 conformance-isolation warnings plus two AppIntents
warnings. No warning names either new C1 source/test file. Explicit destination was iPhone 17,
iOS 26.5 Simulator; no physical device step was taken.

Exact final test command (repository root):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationAdmissionTests -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -resultBundlePath /private/tmp/tsugino-dec084-c1-r4.xcresult > /private/tmp/tsugino-dec084-c1-r4.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-c1-r4.xcresult --format json > /private/tmp/tsugino-dec084-c1-r4-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-c1-r4.xcresult --format json > /private/tmp/tsugino-dec084-c1-r4-tests.json
```

The same test/export commands with suffixes `r1`, `r2`, `r3` retained the intermediate
results below. Every run passed with zero failures/skips/runtime warnings; they are not final
aggregate evidence. The final test-only addition parameterized c19 for a station delta as well
as a Trip delta; production source did not change after `r3` or Release verification.

| Run | Functions / cases | Diagnostic headers observed, excluding rendered duplicates |
|---|---|---|
| `r1` | 136 / 357 | 27 existing conformance warnings, one existing `RailCapabilityTests.init(declared:)` actor warning, seven existing test-macro actor warnings, two AppIntents warnings |
| `r2` | 139 / 375 | 27 existing conformance warnings, two AppIntents warnings |
| `r3` | 140 / 383 | 27 existing conformance warnings, two AppIntents warnings |

Fresh Release app/extension dependency build passed for the final source:

```sh
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd > /private/tmp/tsugino-dec084-c1-release-r2.log 2>&1
```

Release reported 27 existing conformance-isolation warnings, six existing canonical-ID
`isBlank` actor-call warnings and one AppIntents warning. `nm` exited 0 with empty stderr on
both retained binaries; the pattern
`SyntheticTripRegistration|SyntheticRegistration|SyntheticTripLegacyHistory|SyntheticTripReview`
matched zero symbols in each. Whole-file DEBUG guards and unchanged production readers are
also verified. Release binary hashes:

| Retained binary under `/private/tmp/tsugino-p3-routing-dd/Build/Products/Release-iphonesimulator/` | SHA-256 |
|---|---|
| `TSUGINO.app/TSUGINO` | `5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e` |
| `TSUGINO.app/PlugIns/TSUGINOLiveActivity.appex/TSUGINOLiveActivity` | `659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf` |

**Failed attempt, separate from successful evidence:** the first Release invocation used
`-derivedDataDataPath` instead of `-derivedDataPath`, with the otherwise identical command
and output `/private/tmp/tsugino-dec084-c1-release-r1.log`. It exited 64 before building
(`invalid option`); `release-r2` corrected only that option. No test failures or Simulator/
report-cache failures occurred in this task. Raw redirected stdout/stderr and result bundles
were inspected; earlier slice-B tooling failures remain their separate historical records.

Evidence indexes: `/private/tmp/tsugino-dec084-c1-verification.json` and
`/private/tmp/tsugino-dec084-c1-release-symbols.json`. Unaffected DEC-082, ordinary registry
and unrelated evidence is reused because those source/test bytes and production configuration
are unchanged. No broader suite or physical validation is claimed.

| Final C1 file | SHA-256 |
|---|---|
| `SyntheticTripRegistrationAdmission.swift` | `a32da197fa758023e42b74d165e3ed2daaf39ea02b986ee1420dea9a08666792` |
| `SyntheticTripRegistrationAdmissionTests.swift` | `0b7507fdecf1967c1e042f2244668d7980058fbf016f743707d1037564602036` |

Final scope/reference/whitespace checks preserve accepted DEC-083/084 semantics, historical
records and TR84 case identifiers. Only the two new C1 files and DECISIONS/ARCHITECTURE/ROADMAP
change. HEAD/upstream remain `6a688b5d593ee5bb03ced3fca8711e48df635528` (0/0 against the
existing tracking ref); main/origin-main remain `e8a463d51f14b3cb1027960c63244b694579a71b`.
No fetch was required for this local implementation; no live publication check is claimed.
No staged changes; no staging, commit, push or merge. **Independent C1 implementation
review is pending.** C2, real P2-S9/P3-T1 import, registry operations/adoption, production,
rights/publication/delivery and Phase 3 exit gates remain separate.

### DEC-084 C1 review corrections — 2026-10-03 Asia/Seoul

The independent read-only implementation review withheld C1 approval for the retained-
conversion C2 bypass and identified missing historically retired-body regression coverage.
This correction changes only `SyntheticTripRegistrationAdmission.swift`, its tests and this
ROADMAP entry within the existing five-file working inventory. DECISIONS and ARCHITECTURE
remain byte-identical to the reviewed version; no accepted semantics or historical record
is changed. The scope is the two reviewed findings, not C2 admission or a new rejection rule.

The required-S9 capability check now runs before the `convertLegacy` early return. A complete,
digest-bound S9 dependency in retained conversion history prevents both a later C1 candidate
and unchanged replay, even though A/B can validate its representation and mechanics. Plain
conversion retains its prior behavior. The related-return audit found no other bypass:
baseline seeds already check required S9 dependencies; register/attach/reviseSnapshot check
before their availability guard; exact replay visits retained requests before skipping the
identical incoming request. Complete inventories include transitive dependencies, while missing
closure prevents mechanical success. Merely supplied unrelated artifacts and identifier-only
applicability labels do not become required S9 work. No S9 proof/view admission is performed.

Regression evidence in `SyntheticTripRegistrationAdmissionTests`:

- **c38 corrected:** the original schema-2 baseline already contains a retired station with
  a nonempty successor list and its active successor. The original registry reader accepts it;
  A/B validate the lossless retained conversion before the collision proposal. The station
  remains unchanged in the target. A same-body Trip then requires exactly B's
  `identityConflict(Q)` and C1's additional `identityConflict(register-T)`. An observer that
  reserves only active historical bodies would miss the latter and fail this assertion.
  The prior target-only retirement workaround and inaccurate schema-2 comment were removed.
- **c48 added, two cases:** fully supplied required S9 bytes are retained in an approved
  conversion boundary. A reports complete representation and B reports checked mechanics;
  later registration and exact current-target replay both return only
  `outsideC1([conversion: snapshotAdmission], [])`, with no candidate/replay bytes.
- **c49 added, four cases:** plain conversion and an unrelated supplied complete S9 artifact,
  each followed by registration or replay, retain their exact successful C1 bytes. The same
  A/B controls ensure these distinctions do not depend on an invalid or incomplete fixture.

**Final focused correction run: 49 functions / 115 executed cases passed**, zero failures,
skips or runtime warnings. This includes two added functions / six added cases and the revised
c38 cases; it is not summed with earlier C1/A/B runs. Debug app/extension dependencies passed
on the explicit iPhone 17 iOS 26.5 Simulator. Raw redirected output contains 27 existing
conformance-isolation diagnostic headers and two AppIntents warnings, excluding rendered
duplicates; no other compiler warnings or warnings naming the new C1 files. No physical device
step, failed build/test attempt or Simulator/report-cache failure occurred in this correction.
Earlier intermediate runs and the corrected pre-build Release command typo remain separate
in the 2026-10-02 record above.

Exact commands from the repository root:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationAdmissionTests -resultBundlePath /private/tmp/tsugino-dec084-c1-correction-r1.xcresult > /private/tmp/tsugino-dec084-c1-correction-r1.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-c1-correction-r1.xcresult --format json > /private/tmp/tsugino-dec084-c1-correction-r1-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-c1-correction-r1.xcresult --format json > /private/tmp/tsugino-dec084-c1-correction-r1-tests.json
```

Saved index: `/private/tmp/tsugino-dec084-c1-correction-verification.json`. Unchanged A codec
28/56 and B history 65/219 results from the prior `r4` are reused separately; the new C1
controls also directly exercise their closure, conversion and replay paths. No A/B source/test,
legacy reader, project or production composition changed. The correction lies entirely inside
the unchanged whole-file DEBUG guard, so the retained Release build remains applicable without
a rebuild. Both retained binary hashes were checked again and still match the prior record;
`nm` again exited 0 with empty stderr and zero matches for the four recorded synthetic symbol
families. The app hash remains `5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`;
the extension hash remains `659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`.

| Corrected file | SHA-256 |
|---|---|
| `SyntheticTripRegistrationAdmission.swift` | `3839aed48f3d337d9cb173858130194b704ccfffac883bdc2a1ef2cadc4575fb` |
| `SyntheticTripRegistrationAdmissionTests.swift` | `8c1d037775d3edc029dca52b06e464d712d65a2b32ea8fd603fa8967827df838` |

Self-review, the related-path audit, references, accepted-history preservation and whitespace
checks are complete. Audit assistance is not independent approval. **Focused independent
re-review is pending.** Branch/HEAD/upstream remain `phase/03-route-search` /
`6a688b5d593ee5bb03ced3fca8711e48df635528`, 0/0 against the existing tracking ref; main and
origin/main remain `e8a463d51f14b3cb1027960c63244b694579a71b`. No fetch was required, no staged
changes and no commit/push/merge. All five pre-existing working paths remain; only the three
named paths changed during this correction. C2, real S9/import, registry operations/allocation,
production adoption, rights/publication/delivery and Phase 3 exit remain separately gated.

### DEC-084 C1 independent approval and publication — 2026-10-03 Asia/Seoul

Returning non-author reviewers independently re-reviewed corrected C1 against the actual
accepted contracts, implementation, regression assertions and saved evidence. Their prior
involvement was read-only review/audit assistance; neither authored the implementation or
corrections. No remaining material findings or mandatory verification gaps were found.
The implementation author coordinated preservation checks and does not supply independent
approval. All five files remained byte-identical throughout that review. This approval
supersedes the earlier pending-review status without erasing its historical records.

Approved scope is DEBUG-only synthetic identity registration and reference attachment,
applicable approved evidence, retained C1 business admission, complete atomic accounting
and explicit C2 deferral. Required S9 dependencies precede retained conversion returns;
registration/replay cannot emit bytes when that history requires C2. Plain conversions and
unrelated supplied artifacts remain valid controls. c38 now begins with a valid already-retired
historical station and preserves it through conversion; c48/c49 cover the required/incidental
S9 distinction for registration and current-target replay. No optional follow-up or C2 work
is included in publication.

Reuse final correction evidence only as recorded above: **49 functions / 115 passing cases**,
zero failures/skips/runtime warnings and successful Debug dependencies. The **27 existing
isolation warnings and two AppIntents warnings** remain separate. Unchanged A 28/56 and B
65/219 evidence is reused, not summed with this run. Retained Release hashes still match and
both binaries have zero synthetic-symbol matches. Earlier intermediate runs and the corrected
Release command typo remain separate historical evidence. No tests/builds are rerun here.

Reviewed source/test hashes are unchanged:

| Published file | SHA-256 |
|---|---|
| `SyntheticTripRegistrationAdmission.swift` | `3839aed48f3d337d9cb173858130194b704ccfffac883bdc2a1ef2cadc4575fb` |
| `SyntheticTripRegistrationAdmissionTests.swift` | `8c1d037775d3edc029dca52b06e464d712d65a2b32ea8fd603fa8967827df838` |

The owner authorizes committing and normally pushing exactly those two files plus DECISIONS,
ARCHITECTURE and ROADMAP to the existing `phase/03-route-search` upstream. Pre-publication
fetch confirms origin `lunalism/TSUGINO`, HEAD/upstream
`6a688b5d593ee5bb03ced3fca8711e48df635528` and local/remote main baseline
`e8a463d51f14b3cb1027960c63244b694579a71b`, with no divergence or unexpected work.
Only approval/status documentation changes beyond independently reviewed bytes. No force-push,
merge, main push, branch deletion or next-slice implementation. C2, authentication, real registry
operations/allocation, real S9/import, production adoption, rights/publication/delivery and
Phase 3 exit remain separate gates.

### DEC-084 C2 scope lock and contract-to-test matrix — 2026-10-03 Asia/Seoul

The owner separately authorizes DEBUG-only C2 on the existing Phase 3 branch, starting
from clean HEAD `fcb2b6526248a82725a15d201a2de5598f8135a0`. This implements accepted
DEC-082/083/084 semantics; it accepts no new decision or real evidence. Reuse A/B and
reviewed C1 through a full-admission entry point; preserve the identity-only entry point.
Only completed C2 checks may discharge required-S9 limits. No public-field reconstruction
or fabricated DEC-082 candidate is permitted.

Intended file boundary: new `SyntheticTripRegistrationReconstruction.swift` for complete
artifact graphs and proof/view admission; new `SyntheticTripRegistrationSnapshots.swift`
for selection history and downstream obligations; focused integration in
`SyntheticTripRegistrationAdmission.swift`; new `SyntheticTripRegistrationSnapshotTests.swift`;
current-truth DECISIONS/ARCHITECTURE/ROADMAP status updates. Existing codecs and DEC-082
validator remain the authority and should be reused without semantic changes. Additional
edits require a demonstrated necessity within this boundary.

| Accepted boundary | Focused invented checks |
|---|---|
| Full DAG reconstruction via DEC-082, all runs and private proof roles | A2→A1→A0; missing/cyclic/wrong/lookalike predecessor; conflicting/incomplete unselected run; repeated visits |
| Exact enclosing evidence/profile proof and four-component view applicability | Missing/wrong binding; unrelated support; competing negative; conflict with unrelated missing dependency; split/unsplit spans and changed applicability |
| Registration with optional snapshot; initial selection; exact revision predecessor | Identity-only/with-snapshot registration; first selection after identity registration; prior-selection conflict; missing history; target mismatch; same-ID and changed-view revisions |
| Whole retained business history before candidate/replay | C1 regressions; retained required-S9 conversions; exact current replay; stale/altered reuse; incidental catalog controls |
| Complete accounting, deterministic atomic outcomes and obligations | Multi-record failure; original record order; unchanged inputs; retained bytes; initial downstream validation and changed snapshot/view/crosswalk/evidence revalidation |

Verification will run focused C2 and affected C1/A/B/S9 suites, Debug dependencies and
Release exclusion for new declarations, keeping overlapping runs and failures separate.
No allocator, filesystem loader/writer, CLI, source parsing/authentication, actual conversion/
mutation, consumer rebinding, timetable import, private evidence or production composition.
No staging, commit, push or merge. Stop with independent implementation review pending.
Real P2-S9, P3-T1 import, registry adoption, rights/delivery and Phase 3 exit remain separate.

### DEC-084 C2 local implementation and verification — 2026-10-03 Asia/Seoul

C2 is locally implemented under the scope lock above; **independent implementation review
is pending**. This is author self-review, not independent approval. The seven-file boundary
is admission integration, new reconstruction/selection sources and snapshot tests, plus
DECISIONS/ARCHITECTURE/ROADMAP. No A/B codecs, legacy validators, DEC-082 validator, C1 tests,
shared production reader/enum, project composition or accepted semantic text changed.

The full `SyntheticTripRegistrationAdmission.validate` entry requires mechanical integrity,
C1 admission and C2 admission of all required retained/incoming operations before atomic
candidate or current-target replay. The original `validateIdentityOnly` gate remains intact.
Reconstruction uses complete packets and actual DEC-082-generated predecessors, never a
public-field candidate factory. All runs and proof roles participate. Approved closures bind
competing evidence; incidental catalog entries grant no authority. Same-run correspondence must cover the held reference’s actual input hash; an unrelated profile input cannot fill that gap. Known selected IDs remain
reserved even when their bytes cannot be reconstructed. Revision uses the exact selected
artifact; first selection requires complete no-prior history. Returned obligations name dated
T1 facts, original indices, ride contexts, continuity/eligibility and Data-view bindings;
no consumer is rebound. Stipulated seeds remain premises, not verified external history.

Focused coverage in `SyntheticTripRegistrationSnapshotTests.swift`:

| Contract | Cases |
|---|---|
| Registration without/with selection, repeated visits, immutable inputs | s01; s22 |
| First selection, exact replay, prior selection, incomplete history, missing selected bytes | s02–03, s08, s16, s21 |
| A2→A1→A0, exact/wrong/lookalike/missing/cyclic predecessor, unchanged private proof applicability | s04–06, s09–10, s17 |
| Every proof role, wrong/missing occurrence/view association, changed-view missing profile, competing bound versus incidental claims | s07, s12, s18–19, s25–26 |
| Complete unselected runs; conflicts retain actual mapping uncertainty without inventing it | s11, s24 |
| Required-S9 retained conversions/replay, atomic multi-record accounting, stale/altered replay, incidental catalog contents | s13–15, s20, s22 |
| Initial, changed snapshot/view/evidence and reference-binding downstream obligations | s01–02, s04, s06, s23 |

Final combined verification used the explicit iPhone 17 Simulator on iOS 26.5:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationSnapshotTests -only-testing:TSUGINOTests/SyntheticTripRegistrationAdmissionTests -only-testing:TSUGINOTests/SyntheticTripRegistrationHistoryTests -only-testing:TSUGINOTests/SyntheticTripRegistrationCodecTests -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-dec084-c2-final2.xcresult > /private/tmp/tsugino-dec084-c2-final2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-c2-final2.xcresult --format json > /private/tmp/tsugino-dec084-c2-final2-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-c2-final2.xcresult --format json > /private/tmp/tsugino-dec084-c2-final2-tests.json
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -resultBundlePath /private/tmp/tsugino-dec084-c2-release.xcresult > /private/tmp/tsugino-dec084-c2-release.log 2>&1
```

The final combined run passed **204 functions / 516 executed cases**, zero failures,
skips or runtime warnings. Its saved test tree independently separates C2 **26/54**, C1
**49/115**, B **65/219**, A **28/56**, and DEC-082 S9 **36/72**. These are disjoint suites
within this one final run; no intermediate/older run is added. Debug app/extension dependencies
built. Final Debug compilation recorded **27 existing conformance-isolation warnings** and
**two AppIntents metadata warnings**. Release app/extension build passed and recorded **33
existing isolation warnings** (27 conformance warnings plus six `isBlank` actor-call warnings
in unchanged canonical identifiers) and **one AppIntents warning**. No C2-source warning remains.

Fresh Release symbol inspection ran `nm` on both retained executables, piped its captured
stdout through `xcrun swift-demangle`, and searched `SyntheticTrip|SyntheticRegistration`.
Both tools exited 0, raw `nm` stderr was empty, and both outputs had zero matches. Saved
paths, SHA-256 values and results: `/private/tmp/tsugino-dec084-c2-release-symbols.json`.
The app hash is `5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`;
the embedded `TSUGINOLiveActivity.appex/TSUGINOLiveActivity` hash is
`659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`. These also match
retained C1 Release evidence. All new declarations remain enclosed by `#if DEBUG`. The later input-hash predicate correction and s26 tests change only DEBUG bodies/tests; they add no Release declarations or composition, so the fresh Release build/exclusion result remains applicable without another build.

**Intermediate/failed attempts, excluded from final counts:** focused commands used exactly
the final test command above with only `-only-testing:TSUGINOTests/SyntheticTripRegistrationSnapshotTests`,
and substituted `r1`/`r2`/`r3`/`r4`/`r5` for `final2` in the log/result paths. `r1` compiled
but the test process crashed (saved summary reports eight failed functions / 12 failed runs);
the copied fixture's forced key lookup did not support snapshot records. After correcting
that fixture, `r2` passed 8/13. `r3` failed compilation at two overlapping inout accesses in
new fixture closures; local copies fixed them. `r4` passed 16/31; expanded `r5` passed 23/48.
The first combined `final` run passed 203/514 before self-review added the held-reference input-hash check and s26 controls. It is not summed with the corrected `final2` result. No intermediate result substitutes for the final run. Their raw logs remain separate: `r1`
28 compiler warnings (27 conformance plus one existing RailCapabilityTests actor warning)
and two AppIntents; `r2` 27 + two; `r3` 27 + one; `r4`/`r5` zero compiler + one AppIntents
each. The first binary-inspection helper used an incorrect extension basename and reported
it missing; it made no extension-exclusion claim. The corrected inspection above used the
actual embedded executable and verified both binaries. No Simulator-access failure occurred
in this C2 task, and no physical device was accessed.

Self-review checked construction boundaries, no partial bytes, exact predecessor/target
associations, all required conversion dependencies before early returns, and deterministic
conflict precedence. Mapping diagnostics preserve uncertainty only at an actual missing
mapping/proof occurrence; an impossible mapping alone does not fabricate a hold. Reference,
accepted-history preservation and `git diff --check` checks passed. Fresh Release checking
was required for the new source files; unrelated phase/device evidence is not re-run or
claimed as C2 coverage. No independent approval, real S9 evidence acceptance, actual registry
execution/conversion/allocation, source parsing/authentication, P3-T1 import, production
registry adoption, rights/publication/delivery or Phase 3 exit is conferred.

### DEC-084 C2 independent-review corrections — 2026-10-03 Asia/Seoul

Two independently confirmed findings are corrected locally; **independent re-review is
pending**. Scope remains Phase 3's bounded DEBUG-only synthetic review. This turn changes
only `SyntheticTripRegistrationReconstruction.swift`, `SyntheticTripRegistrationSnapshots.swift`,
`SyntheticTripRegistrationSnapshotTests.swift` and ROADMAP within the existing seven-file
inventory. Admission integration, ARCHITECTURE and DECISIONS remain byte-identical to the
start of this correction; accepted semantics and all earlier records are preserved.

1. **Source-key/registry conflict:** selected-run affirmative source-key/Trip assertions
   now reconcile against exact retained and planned registry bindings. With J→T and K→U,
   artifact K→T rejects with `referenceConflict`; unrelated J/T correspondence cannot
   bypass it. Claims require an actual packet use, exact enclosing approved profile/evidence,
   and approved dependency bytes. Every selected proof role participates, so a coherent
   identity-role J claim cannot conceal another role's explicit K→T assertion. Unbound
   keys are not guessed, rejected or implicitly attached. Missing correspondence stays
   uncertainty, and a proven binding conflict retains that uncertainty. Baseline selections,
   registration, initial selection, revision and retained/current-target replay use the same
   checks. The directly related audit also found that later new-key attachments could
   contradict a retained selection without carrying a new snapshot; retained affirmative
   scopes are now checked against those planned bindings too.
2. **Missing bindings hiding contradictions:** authorized claims are checked against actual
   proof uses and packet view components before chosen-binding completeness branches.
   All eight proof roles and all four view components retain exact scope, profile approval,
   source/input/key/Trip and dependency guards. An applicable negative rejects with
   `snapshotConflict` while missing proof/view bindings retain `correspondenceUnavailable`
   / `scopeUnavailable`. Unrelated, unapproved and unresolved assertions supply no negative
   authority. Approved source-profile purpose assertions are also inspected independently
   where exact applicable scope is available; missing support never fabricates a conflict.

New exact-outcome regressions: s27 covers register/initial/revision × conflicting/coherent/
unbound keys; s28 retained replay; s29 missing correspondence with/without known conflict;
s30 all eight missing proof roles × four assertion controls; s31 all four missing view
components × those controls; s32 complete-binding approved/unapproved controls; s33 later
attachment versus retained selection; s34 coherent identity proof with conflicting keys in
other roles. s30–32 run both catalog orders within each executed case, without counting
those inner permutations as additional test cases. Source/profile/evidence names are invented.
Input/history preservation and no-partial-output assertions accompany the affected cases.

Final verification (explicit iPhone 17 Simulator, no physical-device access):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationSnapshotTests -only-testing:TSUGINOTests/SyntheticTripRegistrationAdmissionTests -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-dec084-c2-correction-final2.xcresult > /private/tmp/tsugino-dec084-c2-correction-final2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-c2-correction-final2.xcresult --format json > /private/tmp/tsugino-dec084-c2-correction-final2-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-c2-correction-final2.xcresult --format json > /private/tmp/tsugino-dec084-c2-correction-final2-tests.json
```

**119 functions / 331 executed cases passed:** C2 **34/144**, C1 **49/115**, DEC-082 **36/72**;
zero failures, skips or runtime warnings. C2 adds **eight functions / 90 cases** to the
previous suite. Debug app/extension dependencies built. Compiler diagnostics remain separate:
**27 existing isolation warnings and two AppIntents warnings**, no correction-source warning.
The first focused `correction-r1` command used only the C2 `-only-testing` selector and r1
log/result paths, passing 32/139. The intermediate `correction-final` used the exact final
three-suite command with final log/result paths, passing 118/328 before the all-role s34
audit control. Both recorded 27 isolation + two AppIntents warnings. These overlapping
runs are excluded from final counts. No failed build/test attempt or tooling failure occurred
in this correction turn; earlier implementation/review failures remain separately recorded.

A/B code, legacy validation, S9 codec/validator and their contracts are unchanged. Reuse A
28/56 and B 65/219 from the saved prior `tsugino-dec084-c2-final2` run separately, without
adding them to the final correction count. Release evidence remains applicable: corrections
and new helpers/tests stay wholly within existing `#if DEBUG` guards, with no production
reader/composition or Release declaration change. Both retained binaries were rehashed and
inspected with `nm` and `xcrun swift-demangle`: zero synthetic matches, both tools exit 0,
empty nm stderr. `/private/tmp/tsugino-dec084-c2-correction-release-reuse.json` retains results.
App SHA-256 remains `5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`;
embedded extension remains `659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`.
The prior Release 33 isolation + one AppIntents warning record is reused, not a new build.

Self-review covered missing-binding/profile early returns, all proof roles/components,
known-versus-unbound keys, selection history, original record accounting and sorted diagnostic
output. Reference/case checks, input/history preservation and `git diff --check` passed.
No independent approval is asserted. No staging, publication, real registry operation,
private-data access, import, consumer rebinding or production wiring occurred. Real S9/P3-T1,
registry adoption, rights/publication/delivery and Phase 3 exit gates remain unchanged.


### DEC-084 C2 retained-source-claim correction — 2026-10-03 Asia/Seoul

The focused non-author re-review found one remaining omission: replacing current selection
A0 with A1 discarded A0's still-applicable affirmative source claims. This is corrected
locally; **independent re-review remains required**. No approval is asserted by author
self-review. Phase 3 scope remains DEBUG-only synthetic C2, with no new accepted policy.

`SyntheticTripRegistrationReconstruction.swift` now carries each authorized selected-run
claim's exact scope and enclosing evidence input hashes into the snapshot audit.
`SyntheticTripRegistrationSnapshots.swift` retains these assertions separately from current
selection state. Both baseline selection loading and request selection/revision append to
that retained collection; neither current artifact replacement nor candidate reconstruction
can clear it. Later old/planned registry references are compared using exact sourceID,
namespace and scalar key plus a matching evidence input hash in the reference provenance
or immutable first-seen input. A different target establishes `referenceConflict`. An absent
binding, different source/input applicability, or missing affirmative evidence does not
establish this conflict. These are retained assertions, not implicit attachments, permanent
reservations of unbound keys, evidence authentication or permission for provider-key reuse.
Existing current-selection checks, exact predecessor checks, conflict ordering, no-partial
output and downstream revalidation remain intact. The bounded audit found no other selection
replacement path: baseline and operation selection are the two writers of current scopes;
selected IDs/candidates are separate derived state and do not own evidence retention.

`SyntheticTripRegistrationSnapshotTests.swift` s35 adds **one function / 14 cases**:
seven controls × incoming attachment/current-target replay, each with both catalog orders
inside the case. A0 asserts unregistered K→T; exact-predecessor A1 changes only mapping
revision and uses J. Assertions verify unchanged source/profile/review view components.
The subsequent same-input K→U attachment and retained replay reject atomically with exactly
`referenceConflict@attach`; K→T succeeds. Different source and different input controls
succeed without treating the historical claim as a permanent reservation. Missing attachment
correspondence retains `correspondenceUnavailable@attach-K`, together with an established
conflict when present. Missing A0 affirmative applicability alone holds exactly
`correspondenceUnavailable@A0`, without inventing a K→T assertion. Candidate/replay versus
held/rejected cases are distinguished explicitly; envelope/history bytes remain unchanged.
Existing s27–34 current-selection/all-role/missing-binding regressions remain passing.

Final verification, using only the explicitly identified iPhone 17 Simulator:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-p3-routing-dd -only-testing:TSUGINOTests/SyntheticTripRegistrationSnapshotTests -only-testing:TSUGINOTests/SyntheticTripRegistrationAdmissionTests -only-testing:TSUGINOTests/SyntheticTripReviewTests -resultBundlePath /private/tmp/tsugino-dec084-c2-historical-final2.xcresult > /private/tmp/tsugino-dec084-c2-historical-final2.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec084-c2-historical-final2.xcresult --format json > /private/tmp/tsugino-dec084-c2-historical-final2-summary.json
xcrun xcresulttool get test-results tests --path /private/tmp/tsugino-dec084-c2-historical-final2.xcresult --format json > /private/tmp/tsugino-dec084-c2-historical-final2-tests.json
```

**120 functions / 345 executed cases passed:** C2 **35/158**, C1 **49/115**, DEC-082 **36/72**.
Zero failures, skips or runtime warnings. Debug app/extension dependency graph succeeded.
The final incremental log has **zero located isolation warnings and one AppIntents warning**;
the successful preceding `historical-r1` rebuild recorded the existing **27 isolation and
two AppIntents warnings**, with no correction-source warning. The latter run used the same
three-suite command with `historical-r1` log/result paths and passed **120/343**, before the
two missing-historical-support cases were added. It is not summed with the final run.

Failed/tooling attempts are separate: the first same-command attempt with `historical-final`
paths exited **70** because sandboxed CoreSimulator access failed; it supplies no passing
case evidence. Retrying with authorized Simulator access succeeded. A sandboxed r1
`xcresulttool ... summary` extraction failed to create its local TestReport cache; parsing
that empty output then failed. Authorized extraction succeeded, and final summary/tree
extraction succeeded. An initial `docs/RULES.md` read used the wrong path and was corrected
to repository-root `RULES.md`. No test assertion or compilation failed in this correction.
Raw saved test logs and extracted results, not inferred stderr, support the counts above.

Unchanged A/B evidence remains separately reusable from `tsugino-dec084-c2-final2` (A 28/56,
B 65/219); A/B, the S9 codec/validator, production readers/composition and project settings
are unchanged. Release was not rebuilt: changed declarations remain entirely in existing
DEBUG guards. Both retained Release binaries were rehashed and checked with `nm` followed
by `xcrun swift-demangle`: both tools exit 0, empty stderr, zero `SyntheticTrip`/
`SyntheticRegistration` matches. Saved evidence is
`/private/tmp/tsugino-dec084-c2-historical-release-reuse.json`; app SHA-256 is
`5c696f6a3ca7fca1417f72f33f36d80ee7ea10b3c0b4e1063731f74d8fae7e1e`, extension SHA-256 is
`659150f0d40ca32cbb640afe69afc59037d231b40c449b78e3bc5032b68779cf`, matching the retained
Release record. Its 33 isolation + one AppIntents warnings are historical build evidence.

Only Reconstruction, Snapshots, SnapshotTests and ROADMAP changed in this correction,
within the existing seven-file inventory. Admission, ARCHITECTURE and DECISIONS preserve
their starting bytes. Reference/case checks, accepted-history preservation, self-review and
`git diff --check` passed. No staging, commit/push, private access, registry operations,
allocation, import or production enablement occurred. Real P2-S9/P3-T1, production registry
adoption/search, rights/publication/delivery and Phase 3 exit gates remain separate.


### DEC-084 C2 independent approval and publication — 2026-10-03 Asia/Seoul

Returning non-author reviewers independently approved corrected bounded C2. They reviewed
prior versions but authored none of the implementation/corrections. The author coordinated
repository/preservation checks and this publication; author self-review supplies no independent
approval. No material findings or mandatory outstanding verification remain. Optional
multi-revision, seeded-baseline and first-seen-only fixtures remain nonblocking follow-ups;
none is implemented here.

The review traced A0 K→T, exact-predecessor A1 using J, then matching-applicability K→U:
attachment and retained replay reject atomically. Coherent bindings, different applicability,
missing evidence, independent negatives across all proof/view roles, immutable inputs and
current/planned binding checks remain sound. Reviewed source/test SHA-256 values:

- `SyntheticTripRegistrationAdmission.swift`: `82255432573388a0c2bf268e78408434253e789193ab5dc1881ed904335b201e`
- `SyntheticTripRegistrationReconstruction.swift`: `f10e53fd56f5d99890a670e1e9a0678fa17dff6fd0f7f88717b6bf0f1078c24d`
- `SyntheticTripRegistrationSnapshots.swift`: `5ff573132e052d5204d22e63b855aacccb6e1c7e023004e48eac57d4b9e11d50`
- `SyntheticTripRegistrationSnapshotTests.swift`: `078c9f59bbc0ed5194aca541e61037f305c0c20965277f7b255946733bbfd4cc`

Reuse `historical-final2`: **120 functions / 345 cases**, including C2 **35/158**, zero
failures/skips/runtime warnings and successful Debug dependencies. Preceding rebuild warnings
remain **27 isolation + two AppIntents**, final incremental warnings **zero + one**; this is
not an overall warning-free build. Overlapping runs are not summed. Unchanged A/B and retained
Release evidence remain applicable: actual retained hashes matched and both binaries had
zero matching synthetic symbols under intact DEBUG isolation. No tests/builds are rerun.
The independent evidence review directly confirmed the Simulator connection/destination
failure; its numeric exit 70 and the earlier TestReport-cache failure remain documented
workflow records rather than facts recoverable from that test log/JSON alone. Final saved
summary/tree extraction succeeded. Earlier detailed commands and failure records are preserved.

Publication authorization covers exactly Admission, Reconstruction, Snapshots, SnapshotTests,
DECISIONS, ARCHITECTURE and ROADMAP. Fetch origin and inspect branch/upstream divergence,
verify reviewed bytes, stage these seven explicitly, inspect content/exclusions and publish
with a normal phase-branch push. No force-push, main update, branch deletion or next slice.
This record synchronizes approval/status only; accepted semantics and prior records remain.
Synthetic A/B/C1/C2 completion does not complete real P2-S9, P3-T1 import, production registry
adoption/search, rights/publication/delivery or Phase 3 exit, and authorizes no real registry
operations, private-data access or production enablement.


### Real P2-S9 readiness assessment — 2026-10-03 Asia/Seoul

[First real untimed Trip readiness](P2_S9_REAL_READINESS.md) records the repository-only
assessment after synthetic C2 publication at `3161791`: readiness matrix, missing real
interpretation/tooling, retained gates and a proposed owner-only access scope. Recommend one
owner-nominated run from the accepted Toei `dd575706…` snapshot, conditional on actual retained
availability and a private locator; repository aggregates cannot select or classify a run.
No private artifacts, new evidence, source implementation or acceptance were accessed/created.
The first next task is separately authorized evidence-gap review, not execution of DEBUG
synthetic validators on real data. P2-S9 remains incomplete; P3-T1 real import, launch coverage,
production adoption/search, rights/delivery and Phase 3 exit are unchanged.

### Trips-only nomination reader — 2026-10-03 Asia/Seoul

**Implemented with invented-fixture verification; independent implementation review pending.**
The owner authorized only the bounded standalone nomination reader, not execution on the
retained real archive. Phase 3 still retains real P2-S9 ownership. This fills only the
nomination-tool gap following the readiness assessment, not its later evidence-review,
classification, registration or real-use authorization gaps. The assessment's original
bytes and the pre-existing ROADMAP readiness section are preserved.

Scope: [Tools/TripNomination](../Tools/TripNomination/README.md), Python 3.9+ standard library,
no dependencies or app/production composition. New `nomination.py`, `test_nomination.py`
and README, plus this ROADMAP entry. No accepted decision, shared intake reader, registry,
Domain, app target or build setting changes. The in-memory API returns at most ten records
in source order, with private `N01`–`N10` labels, exact CSV values and hash-bound byte-span
locators. The command line prints only a count; it does not expose or persist the choices.
There is no private presentation UI, exporter or output-file option in this slice.

Safety and accounting: descriptor-relative no-symlink traversal, one opened unbuffered
regular-file descriptor, expected archive size/SHA-256 before any member decoding, bounded
ZIP directory inspection and unique safe root-level member names, only `trips.txt` payload
decoding, actual decompressed size/CRC/member hash, strict scalar-exact UTF-8 CSV, complete
bounded-table validation before delivery, final archive rehash/state/path checks. Nothing
sorts, deduplicates, skips a bad row or substitutes a later candidate. Record spans include
the complete LF/CRLF terminator (if present), quotes and embedded quoted newlines; the final
unterminated span ends at EOF. They exclude the previous terminator, and data ordinals exclude
the header. Offsets still count header/BOM bytes. Errors are fixed codes, never source values.
Unselected members are hashed as opaque archive bytes but never decoded or integrity-certified.

Fixed limits and supported ZIP/CSV profile, exact API/CLI invocation and the independent
review handoff are in the README. Major bounds: 16 MiB archive, 1 MiB directory/1,024 entries,
2 MiB trips payload, 64 KiB encoded field, 256 KiB record, 64 columns, 100,000 data records
checked, ten returned. Stored/deflate and checked ordinary data descriptors are supported;
ZIP64/multi-disk and unsupported selected-member compression/encryption are not. These are
tooling bounds, not a new feed interpretation or railway policy.

Final verification on Python **3.9.6** (2026-10-03 Asia/Seoul):

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_*.py' -v > /private/tmp/tsugino-trip-nomination-final4.log 2>&1
```

**35 test functions passed, zero failures/errors/skips and no unexpected Python warnings.**
Parameterized subtests are not reported as a separate case total. Expected duplicate-name
warnings are suppressed only while deliberately constructing those invented ZIP fixtures.
All fixtures are generated in temporary directories and cleaned up. No real archive or private
mapping/history artifact was accessed in this implementation task. No Xcode tests or builds
were required: only standalone Python tooling and documentation changed; no Release target
can reference the new directory through an app source group. No physical-device interaction.

Focused coverage references in `test_nomination.py`:

| Boundary | Assertions |
|---|---|
| Ordered first ten, fewer/zero/more, repeated IDs | `test_source_order_and_duplicates_are_preserved`, `test_zero_fewer_ten_and_more_records` |
| Exact spans, hashes, quotes/CRLF/EOF, Unicode/BOM | `test_exact_spans_with_quotes_newlines_crlf_and_no_final_terminator`, `test_lf_record_terminator_and_optional_empty_field`, `test_scalar_exact_unicode_whitespace_and_bom` |
| No skipping, malformed headers/CSV, bad eleventh row | `test_malformed_csv_never_skips_or_substitutes`, `test_header_validation`, `test_malformed_eleventh_record_rejects_whole_result` |
| Invalid members/ZIP, length/CRC, deflate and descriptors | `test_invalid_and_duplicate_member_names`, `test_missing_or_nested_trips_and_member_symlink`, `test_local_and_central_disagreement`, `test_crc_and_actual_size_are_checked_independently`, `test_truncated_deflate_and_trailing_compressed_bytes`, `test_descriptor_integrity` |
| Finite bounds, dishonest directory counts/expansion | `test_resource_limits`, `test_exact_field_and_record_limit`, `test_inflation_over_actual_limit_even_with_small_declared_size`, `test_central_count_understatement_and_truncated_directory` |
| Identity before decoding; mutation/symlink/descriptor safety | `test_identity_rejected_before_member_decoding`, `test_changed_bytes_during_read_reject`, `test_final_hash_detects_change_even_if_metadata_comparison_is_bypassed`, `test_same_bytes_replaced_path_reject`, the four `test_*symlink*` controls |
| Selected-only reads, no output files, private errors | `test_one_archive_descriptor_and_only_trips_payload_read`, `test_corrupt_unselected_content_is_never_decoded`, `test_inputs_and_permissions_unchanged_no_output_files`, `test_private_repr_cli_success_and_errors`, `test_cli_data_and_path_errors_are_redacted_and_atomic` |

Intermediate attempts are separate and **not summed**: `tsugino-trip-nomination-initial.log`
ran 30 tests with one failed NUL-name fixture assertion because Python's ZIP writer had already
truncated the supplied name. The fixture now mutates encoded metadata and reaches the intended
reader guard. `tsugino-trip-nomination-final.log` ran 34 tests with one failure: a new forced
mutation check exposed the buffered descriptor's cached final rehash. Unbuffered reads correct
that omission, independently covered even with the metadata comparison mocked out. `final2`
(34 passing) and `final3` (35 passing) are superseded intermediate evidence. Self-review then
added the descriptor-mode local CRC/size consistency check and its regression; `final4` above
is the final run. No compiler/tooling failure occurred in these runs; Python is not compiled
through the app build. Logs are synthetic-only local verification artifacts, not Git content.

Final review fingerprints (SHA-256): `nomination.py`
`9bccbf7999955433fd33f39d3ee1325452b088371bb83ca348572027b9403c10`;
`test_nomination.py` `b49b36c15522e8e4070b54bdf0ccbdac89cb39bfcf74be944079759b3b60776a`;
final log `c1dd327d5aee9511636826f9a866d737e3a5aa19b8b3830a975de8f16b569822`.

Author self-review and reference/diff/preservation checks are not independent approval.
Next: non-author review of the implementation, actual assertions, final saved log, strict
profile/limits and in-memory output boundary, using the README handoff. Only after review and
separate authorization may a real archive be read for owner nomination. No real nomination,
source authentication, passenger classification, recurring identity, real S9 acceptance,
P3-T1 import, ID allocation, registry mutation/adoption, production search, rights/delivery
or Phase 3 exit is established. No staging, commit, push or merge in this task.

### Private owner-nomination terminal workflow — 2026-10-03 Asia/Seoul

**Reader independently reviewed; inspect/select workflow implemented with synthetic
verification, focused independent review pending.** The subsequent non-author reader review
found no material defect in the bounded library but identified that its counts-only CLI did
not provide a usable private nomination interface. Thus the preceding record's nomination-tool
completion covers the reader, not the entire owner workflow. This entry records the separately
authorized correction; it does not grant real-input execution or make a real nomination.

Scope: new [session.py](../Tools/TripNomination/session.py) and
[test_session.py](../Tools/TripNomination/test_session.py), updated
[README](../Tools/TripNomination/README.md#private-inspectselect-workflow) and this ROADMAP
entry only. The reviewed reader and its 35 tests remain byte-identical. No new semantic
decision, intake/parser change, app UI/composition, dependency or registry behavior. The
readiness assessment and all prior ROADMAP records are preserved.

The local terminal wrapper qualifies all three standard streams as the same foreground
terminal before archive access, refuses redirection/noncanonical input/detected SSH, then
calls the unchanged reader once. Only complete validation permits display. Previews contain
the original ordered labels and only `trip_id`, `route_id`, `service_id`, using inert ASCII
JSON escaping. Original scalar values and locators remain unchanged in memory. Exact label
entry makes a choice pending; explicit `confirm` retains that original object and locator;
`inspect` shows the confirmed identifiers and seven locator fields. Invalid input clears a
pending choice without changing an existing confirmation. `cancel`, `exit`, EOF or interruption
ends retention; the session repeatedly states that selection is lost on exit. No export,
output file, logging, clipboard, network, server or browser storage. No other member contents
are read. Commands are bounded to 32 ASCII bytes including newline; truncated commands never
select. Input echo is disabled during the session and terminal state/descriptors are restored
on handled exit/failure. Private writes recheck terminal state and use a duplicate terminal
descriptor. The README explains terminal capture/scrollback and OS-memory limitations; the
tool cannot certify that a local terminal is unrecorded or defeat disguised remote capture.

Final verification on Python **3.9.6** (2026-10-03 Asia/Seoul):

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_*.py' -v > /private/tmp/tsugino-trip-nomination-session-final2.log 2>&1
```

**54 test functions passed: 35 unchanged reader and 19 workflow tests; zero failures,
errors or skips, no unexpected Python warnings.** Subtests are not reported as a separate
case total. Expected duplicate-ZIP fixture warnings remain narrowly suppressed by the
unchanged reader tests. The final run includes actual CLI execution with invented archives
and controlling pseudo-terminals, with output captured only in test memory. No real archive,
private mapping/history, physical device, Xcode test or build was used. Standalone standard-
library tooling remains outside all app/Release targets; no production verification changed.

Focused coverage in `test_session.py`:

| Boundary | Assertions |
|---|---|
| Exact source-order label/original-object/locator retention | `test_every_label_selects_original_candidate_and_exact_locator` checks all ten against independently computed record spans and hashes, including quoted CRLF; `test_listing_is_source_order_and_only_required_identifiers` |
| Confirmation, invalid selection, cancellation and no selection | `test_confirmation_and_inspection_require_explicit_choice`, `test_invalid_input_clears_pending_never_selects_or_replaces_confirmed`, `test_empty_batch_never_selects`, `test_cancel_exit_and_eof_discard_selection_without_returning_private_objects`, `test_interrupt_clears_live_selection` |
| Failure without exposure, exact escaped Unicode/control display | `test_validation_failure_never_displays_any_candidate`, `test_unicode_and_terminal_controls_are_escaped_without_changing_originals`, `test_redirected_cli_and_argument_errors_never_echo_private_inputs` |
| Terminal-only boundary and bounded commands | `test_redirection_and_background_terminal_reject_before_archive_access`, `test_different_terminal_and_ssh_are_rejected`, `test_bounded_input_never_interprets_a_partial_or_nonascii_command`, `test_terminal_rechecks_before_private_write` |
| Actual invocation, cleanup and no persistence | `test_actual_terminal_confirmation_inspection_and_no_files`, `test_actual_terminal_cancel_eof_and_validation_failure`, `test_terminal_restores_echo_and_closes_descriptors_on_exit_and_interrupt`, `test_noncanonical_terminal_rejects_before_reader_and_closes_duplicates`, `test_session_delegates_to_reader_once_no_files_logs_network_or_input_changes` |

Intermediate runs are separate and **not summed**: `tsugino-trip-nomination-session-initial.log`
passed 52 functions before two terminal-lifecycle controls were added. The subsequent
`tsugino-trip-nomination-session-final.log` ran 54 with one fixture assertion failure:
noncanonical `tcgetattr` represents `VMIN`/`VTIME` as integers, while the setter input retained
byte values. The control now compares the actual installed terminal state before/after;
no production behavior changed for that correction. `final2` above is the sole final evidence.
These runs are independent of the earlier reader implementation attempts. One repository
lookup also included nonexistent `docs/RULES.md`; the actual root `RULES.md` was read, and
this did not affect verification. Logs contain invented inputs only and are outside Git.
The extra untracked-file whitespace helper initially treated normal `git diff --no-index`
exit 1 (different files, no diagnostic) as failure. The corrected inspection found no whitespace
errors in tool files; it identified only the readiness document's two pre-existing Markdown
hard-break spaces, preserved byte-for-byte as requested. Tracked `git diff --check`, references,
test-coverage references and preservation fingerprints passed.

Review fingerprints (SHA-256): `session.py`
`283956b222450556e48335eea5a9bdb546b3f10fdfb5cb684220200f344811a0`;
`test_session.py` `cb5002503c07b03c91914af123e5ba7da813e44870751fecd32c0d54559b8c99`;
final log `8166ca855ff6a77c264569c99706b3173fe54d5db49efc0e12caa50255bbba11`.
Unchanged reader/test hashes match the preceding review fingerprints. Readiness SHA-256
remains `2857162f0e746875f8e32393305157561c169a89644fdd56d93cfd8bead72686`.

Author self-review is complete but is **not independent approval of the new workflow**.
Next: focused non-author review using the README handoff, actual assertions and final log;
verify the documented invocation, terminal/output boundary, unchanged reader and original
selection/locator retention. Separate authorization is still required before any real-input
execution. No real run nomination, passenger classification, recurring identity, S9 acceptance,
P3-T1 import, registry mutation/adoption, production search, rights/delivery or Phase 3 exit
is established. No staging, commit, push or merge.

### Nomination tooling independent approval and publication — 2026-10-03 Asia/Seoul

**Bounded reader and private terminal workflow independently approved for tooling readiness.**
A fresh non-author reviewer inspected actual `session.py`, `test_session.py`, README and
ROADMAP, the unchanged reader, regression assertions and saved final evidence. No material
findings or mandatory corrective checks remained. The coordinating agent authored the
workflow; its own preservation/evidence checks and earlier self-review are not the independent
approval. This completes the preceding pending review without rewriting its historical record.

Approval covers full validation before display, exact original candidate/byte-bound locator,
explicit confirmation and cancellation/EOF/interruption, memory-only lifetime, display-only
escaping, terminal-only private output and no file/log/network/persistence path. Documented
terminal-capture/locality and memory-erasure limitations remain. No real archive was accessed
and no run was nominated; real-input execution remains a separately authorized next task.

Reuse the independently inspected final **54 passing functions (35 reader + 19 workflow)**,
zero failures/errors/skips and no unexpected warnings, with the source/test/log fingerprints
above. No tests or app builds were rerun for publication; overlapping and failed intermediate
attempts remain separate. The four reviewed Python files are byte-identical. README status is
synchronized. Readiness wording is unchanged; only its two header hard-break markers changed
from trailing spaces to equivalent Markdown backslashes for staged whitespace validation.
Its earlier recorded fingerprint describes the original reviewed formatting.

Owner-authorized publication includes exactly the five `Tools/TripNomination` source/test/
README files plus `docs/P2_S9_REAL_READINESS.md` and `docs/ROADMAP.md`, on the existing phase
branch. Exclude real source data, private paths/keys/locators, saved test logs and generated
artifacts. Preserve accepted decisions and all prior records. This approval/publication does
not authorize real S9 evidence review or acceptance, P3-T1 import, allocation, registry
operations/adoption, production search, rights/delivery or Phase 3 exit; main stays unchanged.


### Bounded untimed occurrence extractor — 2026-10-03 Asia/Seoul

**Implemented with invented-fixture verification; non-author independent review pending.**
Owner authorization covers standalone tooling and synthetic verification only. Phase 3
retains real P2-S9 ownership; real execution is excluded from this task. No private artifacts,
source keys, nomination locators or evidence contents were used as fixtures or published.

Scope: new [occurrences.py](../Tools/TripNomination/occurrences.py) and
[test_occurrences.py](../Tools/TripNomination/test_occurrences.py), a small shared-helper
change in `nomination.py`, [README contract/invocation](../Tools/TripNomination/README.md#untimed-occurrence-extractor)
and this record. The directory selector now accepts an internal member name, and the original
inflation implementation is shared behind the unchanged trips-only wrapper. Public nomination
behavior/limits remain unchanged; reader tests and terminal workflow source/tests are
byte-identical. Readiness, accepted decisions and architecture are unchanged.

The extractor reconstructs the exact archive-bound nominated label, checks the complete trips
table for an ambiguous selected-key join, then validates all bounded occurrence rows using
one protected descriptor. Only trips/stop_times payloads are decoded. Results preserve every
matching row in transport order with repeated visits, original ordinals, exact terminator-
inclusive spans/hashes and complete member digests. Optional absent/empty fields are distinct;
time values never escape as result fields and are never interpreted. ASCII-decimal syntax and
selected numeric-key duplicates are checked; gaps and transport inversions are preserved, not
converted into railway-order claims. Zero matches is explicit, never an accepted empty Trip.
All integrity/parse/ambiguity/limit failures produce no partial successful result. Existing
archive/CSV limits remain; occurrence limits are 32 MiB, 500,000 total records, 4,096 matches.
No persistence, general importer, canonical IDs, registry operation or app composition.

Final verification, Python **3.9.6**:

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_*.py' -v > /private/tmp/tsugino-untimed-occurrences-final.log 2>&1
```

**84 functions passed: 30 extractor + 35 reader + 19 workflow; zero failures/errors/skips
and no unexpected Python warnings.** Subtests are not a separate case total. Deliberate
duplicate-ZIP fixture writer warnings are narrowly suppressed. No app builds, device steps
or real execution. Intermediate `tsugino-untimed-occurrences-initial.log` passed 81 functions
before three self-review coverage additions; it is not summed with final evidence. No failed
test/build attempts occurred. Logs contain invented inputs only and remain outside Git.

Coverage: `test_all_labels_bind_original_nomination_and_only_associations`,
`test_ambiguous_selected_key_anywhere_in_complete_trips`,
`test_interleaving_repeated_visits_and_original_ordinals`,
`test_exact_unicode_quotes_crlf_bom_spans_and_eof`,
`test_uninterpretable_time_text_only_becomes_presence` and the sequence/zero-match controls
check the output boundary. Complete-member malformed/corrupted suffixes, actual production
record/match caps and inflation limits establish no skipping/truncation. Descriptor tracing
bounds reads to precisely the two payloads; mutation/replacement/symlink checks, final rehash
independent of metadata, unchanged-input/no-persistence controls and the documented CLI
subprocess cover I/O and privacy. The full existing nomination/workflow suite passed unchanged.

Final fingerprints: `nomination.py` SHA-256
`5677ace84b74e4e1855ec559f59cf5f149147ef716937e5c6c3eb22af773902e`;
`occurrences.py` `87cc3294b8079644ef3bcdee6b1b5ae0563b4c33c174cf3987a4dace327f385d`;
`test_occurrences.py` `b8a4f32f4c628e8a42d0894bdf1ff8dc9f7f9bdc5a769484807622afb1c73f45`;
final log `6173fdd2d83245c22aa559d3ef50967ab22214a79a0f318009f18c3e639d7a22`.

Author self-review, preservation/reference checks and `git diff --check` completed; they are
not independent approval. Next: non-author review of the actual implementation, shared-helper
diff, assertions, limits, private output boundary and saved final evidence using the README
handoff. Real execution needs separate authorization after review. Extraction establishes
neither source authentication, passenger classification, recurring identity, movement/coverage
proof nor real S9 acceptance. P3-T1 import, registry adoption/operations, production search,
rights/delivery and Phase 3 exit remain separate. No staging, commit, push or merge.


### Untimed occurrence tooling independent approval and publication — 2026-10-03 Asia/Seoul

**Bounded extractor independently approved; real execution remains separately gated.**
A fresh non-author reviewer inspected the implementation, shared-helper diff, accepted
boundaries, actual regression assertions and saved verification. No material findings or
mandatory corrective checks remained. The coordinating agent authored the implementation;
its self-review and preservation checks are not the independent approval. This closes the
preceding pending review while preserving that historical implementation record.

Approval covers the standalone memory-only API/counts-only CLI: one protected descriptor,
only trips/stop_times payload decoding, complete-member integrity/CSV accounting, exact
nomination reconstruction and selected-key uniqueness, source-order occurrence preservation,
byte-bound locators, sequence checks without railway-order inference, presence-only time
fields, atomic failures, explicit zero matches and unchanged nomination/workflow behavior.
It grants no source authentication, classification, recurring identity or real S9 acceptance.

Reuse the independently inspected **84 passing functions (30 extractor + 54 existing)**,
zero failures/errors/skips and no unexpected warnings, with the preceding source/test/log
fingerprints. No tests or app builds rerun for publication; the earlier 81-function run is
not summed. All three reviewed source/test files remain byte-identical. Only README approval/
status text and this record were updated. Readiness, accepted decisions and older records
remain unchanged. The initial sandboxed fetch could not write FETCH_HEAD; the authorized
permission-enabled retry succeeded. This tooling-access attempt is not test evidence.

Owner-authorized publication contains exactly `occurrences.py`, `test_occurrences.py`,
`nomination.py`, the TripNomination README and this ROADMAP, on the existing phase branch.
No private inputs/identifiers/locators, generated artifacts or test logs are included.
No real extraction, additional private evidence inspection, ID allocation, registry operation,
merge or further implementation is authorized. Real execution, S9/P3-T1, production adoption/
search, rights/delivery and Phase 3 exit retain their separate gates; main is unchanged.

### Memory-only occurrence inspection and gap recording — 2026-10-03 Asia/Seoul

**Implemented, synthetically verified and independently approved for bounded tooling.** Scope lock: Phase 3
retains P2-S9; add only `Tools/TripNomination/review_session.py`, its synthetic tests and README,
and this record. No parser/extractor/nomination semantics, limits, accepted decisions, Domain,
app targets or dependencies change. Authorization covers development, synthetic verification
and independent review, not any real archive/evidence access or execution/publication.

**Prior owner-executed evidence, not a run by this implementation task:** the owner reports
explicitly confirming one candidate in the approved local nomination workflow, then executing
the counts-only extractor once with the previously authorized 779,699-byte `dd575706…` archive
identity. Reported output: `occurrences; matching records: 14; transport-order inversions: 0;
private values not printed`. This is owner-executed, screenshot-supported evidence as reported
by the owner, not agent-observed execution. Contract inspection established that this success
path performs expected size/SHA-256 and final archive identity checks. Fourteen matching source
records and zero numeric transport inversions establish neither fourteen passenger stops nor
authoritative railway order, recurring identity, registration readiness or S9 acceptance.
The prior real-extraction grant is consumed. No private path, label, key or locator is recorded.

The new owner-operated unrecorded terminal interface reuses `read_occurrences` once and the
existing terminal guard/escaping/32-byte command reader. Explicit archive identity, original
confirmed label and expected count/inversions are required. For the eventual pilot these are
14 and 0; mismatch/zero matches or reader failure prevents any occurrence display. No retry,
nomination, substitution, sorting, cropping or partial result. Source-order navigation preserves
all original immutable occurrences, repeated visits, sequence spelling and exact seven-field
locators. Only documented source associations, occurrence fields and presence-only time enums
are exposed. New `O` labels are session-local transport positions, never canonical indices.

Every classification remains unknown. Memory-only fixed gap annotations and occurrence links
to at most sixteen explicit `E01`–`E16`/SHA-256 references cannot remove gaps or classify a row.
References are owner assertions only: content is unopened, digest/applicability unverified.
No evidence file reader, source semantic parser, classifier, acceptance mechanism, persistence,
export, logs, clipboard or network path. The README documents exact invocation, fields, limits,
failure/cancellation behavior, evidence boundary and terminal/memory-capture limitations.
State is discarded at exit; this does not provide secure erasure or an immutable review packet.

Synthetic verification (Python 3.9.6; invented ZIPs and controlling PTYs only):

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_*.py' -v > /private/tmp/tsugino-occurrence-review-synthetic.log 2>&1
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_review_session.py' -v > /private/tmp/tsugino-occurrence-review-targeted-final.log 2>&1
```

The combined suite passed **97 functions (13 new + 84 unchanged)**. Two test-only controls
were subsequently added for no file writes/logging/network/subprocess and redacted terminal
write failure with state cleanup. The final targeted run passed **15 functions**, zero
failures/errors/skips or unexpected warnings. These overlapping runs are not summed into a
claimed full run of 99. Implementation bytes did not change between these runs. An earlier
13-function targeted run also passed; it is not additional coverage. No app build/device work
is needed for this standalone tool. No test failure occurred. Saved logs contain invented
inputs only and remain outside Git.

Review fingerprints: `review_session.py` SHA-256
`516aeedfdee636cb91de572279999fbc1577bc4a63ae1aa5b98526f738f5ec2a`;
`test_review_session.py` `19fd198a5b9c683223cc318fe20ddb01f44ed972ec48a3fba9bea6e90e41444a`;
combined log `f19792d2f8c369be6b9bda7c1bc9e3977758573480d147b407692c586aced6cd`;
final targeted log `b85241cf3a0d5210d55d07f87914c99217da1405b1b1f3189a796f659643c61e`.

A separate non-author reviewer inspected code, all fifteen final test functions, actual
assertions, both saved logs/fingerprints, README and this ROADMAP record. The reviewer approved
the bounded synthetic tooling and documentation with no material findings or mandatory
corrective tests. No tests were rerun by the reviewer; author self-review is not this approval.
Source/test bytes remained unchanged through review. Remaining real-use gates:
explicit same-candidate re-read authorization, privately retained original label and exact
path/identity, owner-operated unrecorded terminal, and a separately designed/authorized named
evidence-content review if needed. Loss of the original label is a prerequisite gap, never
permission to select another candidate. This interface cannot authenticate confirmation or
evidence. No new nomination, real re-read, private evidence opening, registry operation,
S9/P3-T1 acceptance, publication, commit, push or merge occurs in this task.

#### Owner-reported real inspection pilot — 2026-10-03 Asia/Seoul

Following separate explicit authorization for one same-candidate real re-read using the
published interface at `a5bbbc7de694407f9cac88521b2283f0ee84991f`, the owner reports using
the original confirmed candidate and authorized archive identity, successfully opening the
session, running summary, inspecting the first occurrence and navigating through records.
The fourteenth occurrence displayed successfully after resolving confusion between uppercase
letter O and digit zero. The invalid-command incident is resolved; no code defect is established.
The owner reports exiting and unsetting the local archive-path and confirmed-label variables.
This is **owner-reported execution**, not agent-observed private inspection, independent
railway-semantic validation or proof of secure memory/terminal erasure. The one-use re-read
grant has been exercised; it does not authorize another run or evidence-content access.

Reported summary: transport-order inversions **0**, railway order **unverified**;
classification gaps **14**, ordering gaps **14**; provenance, identity, mapping, movement
and endpoints gaps **0 each**. The latter counts mean no additional gaps were recorded,
not that those requirements were fulfilled. Classification remains unknown for all fourteen
source occurrences; no passenger-stop count or railway order is accepted. The memory-only
session does not retain an evidence packet. **P2-S9 remains incomplete.** No private archive
path, candidate label, source key, locator or occurrence content accompanies this record.

**Next proposed scope: source-document applicability review only; no new tool or archive run.**
Use [DEC-082 §§1–2 and §6](DECISIONS.md#dec-082--p2-s9-passenger-stop-input-review-recurring-identity-evidence-and-acceptance-plan)
and the [readiness access matrix](P2_S9_REAL_READINESS.md#exact-proposed-access-scope-for-the-next-task).
Already identified in tracked records: the accepted Toei DS-01 `dd575706…` snapshot
(779,699 bytes, feed version 20260921); its historical P2-S2 intake manifests and S4 acceptance;
the GTFS Schedule Reference dated 2026-04-27 cited by P2-S0/S1; and
[provider audit §6.8/B11](PROVIDER_FEASIBILITY_AUDIT.md#68-service-type-brand-supplemental-fare-and-seating-field-evidence--b11-offline-2026-09-23-dec-061).
These are references, not confirmation of currently available evidence files. B11 concerns
the older Toei `f10d03cd…` hash, not this revision; generic GTFS definitions and archive
integrity alone cannot establish source-specific applicability. No pilot evidence-reference
allowlist or content review was reported. Train-timetable JSON remains payload-unverified.

The minimum proposed private allowlist is (1) the exact existing acquisition/provenance record
and intake manifest for this snapshot, excluding credentials and payload members; (2) exact
existing Toei/ODPT publisher interpretation documentation or authoritative occurrence-review
records that explicitly cover this resource/revision's passenger-stop versus traversal rows
and ordering-key semantics; and (3) only any specification revision explicitly incorporated
by that source evidence. Item 2's actual artifact names/hashes and revision-applicability
proof are not identified in tracked records; retained paths/hashes for the allowlist must be
supplied privately by the owner before access. Do not invent files, search directories or
substitute an older/newer feed. If authoritative evidence is absent, report that gap and scope
any research/acquisition separately.

After a named read-only access grant, manually review only those documents in an owner-only,
unrecorded setting: verify identities/provenance, exact revision applicability, affirmative
stop/pass definitions, restrictions versus passing, numeric ordering meaning, supported
variants/exceptions and invalidation conditions. Report supported claims and missing evidence;
do not apply rules to the fourteen occurrences in this document-only step. No archive/member
re-read, candidate substitution, raw times, mapping/registry access, export or persistence is
included. Public reporting is a non-restorable evidence/gap summary only. Reference linking
in the published interface opens no content and supplies no authority. If an applicable profile
is supported, separately review it and authorize any later occurrence-level application and
crosswalk review; unknown interior positions remain held, never cropped. Identity, mappings,
movement/endpoints, actual registration and scoped S9 acceptance retain their own evidence gates.

#### Public interpretation research and tracked evidence trace — 2026-10-03 Asia/Seoul

Public-document research completed after publication of the owner-reported pilot record
(`d2e563da…`); this follow-up traces tracked records only. No private document, archive or
candidate was reopened. **Classification gaps remain 14; ordering gaps remain 14; P2-S9
remains incomplete.** Optional zero gap counts retain the limitations in the pilot record.

**Recorded chain and its limits.** P2-S1 records public Toei acquisition on September 25/26;
P2-S2 records successful intake of SHA-256
`dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`, 779,699 bytes,
feed version 20260921, with two byte-identical external manifests (9 selected members,
2 unselected fare members by name). DEC-066 §G and the committed `SourceList.toeiStaticGTFS`
bind DS-01/toei-static-gtfs to dataset `train-toei` and resource
`35b68908-4558-47ae-bfa5-867e58544a1a`. Manifest hashes/sizes are computed, source metadata
comes from that committed list, and `obtainedAt` is operator-declared: this is not remote
authentication or independent acquisition proof. S4's September 30 owner acceptance covers
reviewed station grouping/line bindings on this hash, not passenger classification/order.
The older B8/B11 `f10d03cd…` archive (779,674 bytes) and its retained sanitized manifest
cannot stand in for this revision. Matching aggregates do not establish row equivalence.

**Interpretation already recorded.** DEC-065 §D checked the reader against the GTFS Schedule
Reference revised April 27, 2026, including its canonical `google/transit` source
`gtfs/spec/en/reference.md`. It separates specification rules, observed shape and reader
policy. Zero invalid/unsupported rows establishes success under that bounded reader contract,
not complete GTFS conformance. It documents numeric `stop_sequence` trip order, nonconsecutive
keys, and a reader restriction to source rows already in that order; CSV row order is not
the GTFS ordering definition. No producer conversion contract or accepted source-specific
stop/pass profile for this revision is identified. DEC-082 permits applicable source/profile
evidence or authoritative occurrence-specific evidence; a literal adoption statement is not
the sole route. Documented conformance, incorporation or conversion evidence can contribute
only to the claims and revision scope it actually supports.

**Official public sources inspected in the completed research:**

- [ODPT dataset](https://ckan.odpt.org/dataset/train-toei) and
  [exact base resource](https://ckan.odpt.org/dataset/train-toei/resource/35b68908-4558-47ae-bfa5-867e58544a1a):
  current, undated catalog describes Toei rail coverage and GTFS/GTFS-JP format; the separate
  Pathways resource is not this input. No applicable specification revision or stop/pass,
  omission or conversion profile was located there.
- [GTFS Schedule Reference](https://gtfs.org/documentation/schedule/reference/), revised
  April 27, 2026: generic numeric trip ordering, pickup/drop-off permissions and timepoint
  precision. [ODPT-hosted translation](https://gtfs-llm-translation.odpt.org/documentation/schedule/reference/)
  supplies generic guidance, not evidence of this resource's revision-specific implementation.
- [Toei announcement](https://www.kotsu.metro.tokyo.jp/pickup_information/news/bus/2020/bus_p_202008179276_h.html),
  August 17, 2020: bus GTFS realtime/GTFS-JP statements and separate rail JSON information;
  it does not establish this rail archive's profile. The public
  [ODPT documentation page](https://developer.odpt.org/documents) exposed only a shell to the
  research reader; no authenticated fallback was used.

Numeric trip order is a plausible interpretation supported by the generic contract, not
independent physical railway-order validation. Passenger permissions, timing precision,
physical stopping/passing and completeness of represented positions remain distinct.
No inspected public source established the missing resource/revision-specific exceptions
or omission conventions. This is a bounded research result, not proof no such document exists.

**Identity-only references; investigation complete.** The recorded P2-S2 manifests and the
acquisition record underlying the declared date could address identity, source linkage,
declared custody and selected-member metadata, not the unresolved interpretation semantics.
Their roles are recorded, but exact local file identities and document hashes are not.
No further provenance tracing or private manifest inspection is the next semantic step.
B7 separately records retained catalog/terms captures and a source
matrix (audit §2.5/§3.1); those are historical provenance/rights evidence, not an identified
20260921 interpretation document, and need not be opened for classification.

**Next scope: public interpretation documentation, then an unsent inquiry if needed.**
The missing clarification is how this exact base resource/revision represents passenger
stops, restricted stops, passed or omitted positions, and numeric trip order, including any
conversion rules and exceptions. Seek an existing producer/distributor document through the
official resource/documentation references above, or separately scope obtaining that
clarification from Toei/ODPT if no document is identified. No document title, retained path
or hash is invented here. Review only its applicable clauses and any specification it
incorporates; report supported claims and limitations without applying them to the candidate.
This could support DEC-082 classification/order profiles; identity/custody review alone
cannot close those gaps. Actual occurrence correspondence, independent crosswalk review,
mapping/movement/endpoints, registration and S9 acceptance remain separate. No new acceptance
requirement, semantic decision, private access, provider contact or further real run is granted.

#### Proposed P3-T1 invented conversion/input slice — 2026-10-04 Asia/Seoul

Documentation-only scope: [producer proposal §9](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#9-proposed-bounded-invented-conversion-profile--dec-085)
and **Proposed DEC-085** specify one immutable invented occurrence packet, exact
view/revision/snapshot/index correspondence, complete calendar/exception rules,
civil-day extended-hour conversion through explicit finite offset rules, gap/fold
rejection, typed bounded outcomes and atomic failure. Existing DEC-078 values,
quality/eligibility semantics and chronology checks are reused, not redesigned.
The example matrix includes ordinary/added/removed service, inactive malformed events,
missing/estimated times, clock transitions, revisions, limits and contradictions.

C1–C4 (input envelope, civil-day/zone profile, concrete calendar/outcome contract and
bounds/DEBUG execution) require owner approval; no proposal is Accepted by this work.
The next implementation, only after approval and separate authorization, is a pure
DEBUG-only converter and invented boundary tests returning existing Domain facts.
No production code, tests/builds, real inputs, provenance tracing, provider contact,
engine adoption, app wiring or registry work occurs. No Toei/ODPT applicability is
claimed. P3-T1 remains partially complete; P2-S9 and all fourteen classification and
fourteen ordering gaps remain unresolved. The owner reports sending the interpretation
inquiry on October 3; no reply has been supplied, and this design does not depend on one.

Independent documentation review approved the revised proposal for owner consideration,
with no material findings remaining. Corrections bound nested snapshots/reference scopes
and text, require unique evidence references, validate zone rules before inactivity,
and preserve DEC-078 primary-diagnostic order separately from Data outcome severity.
Tracked contract/code/test inspection, link/scope/privacy review and `git diff --check`
are documentation checks only; no test/build execution evidence is claimed. DEC-085
remains Proposed and changes are left unstaged/uncommitted for owner review.

#### DEC-085 accepted synthetic conversion implementation — 2026-10-04 Asia/Seoul

The owner approved C1–C4 as independently reviewed and authorized this bounded
implementation. DEC-078 remains unchanged. Earlier Proposed and no-implementation
statements record their historical stage. Scope: three new DEBUG-only Data files,
one invented test file and the three pending design/status documents; no Domain,
project settings, routing, Application or provider changes.

`SyntheticTimetableInput.swift` supplies immutable typed packets, revision/evidence
and index associations, explicit calendar/zone/event inputs and bounded outcomes.
`SyntheticTimetableCivilTime.swift` uses strict Gregorian integer arithmetic and
civil-day rollover with explicit fixed/finite transition offsets; no device locale,
Calendar/TimeZone database or wall clock. `SyntheticTimetableConverter.swift` enforces
counts/text budgets before traversal, then coherent view/references and zone rules,
complete calendar activation, active-only occurrence correspondence/qualification,
and existing Domain chronology/atomic fact construction. Inactive skips event checks,
but never bypasses envelope bounds or unresolvable zone rules. Failure severity and
primary diagnostic ordering are separate, as accepted. It neither guesses clock
gaps/folds nor creates facts for missing correspondence, and records no persistent output.

Independent implementation review identified and the author corrected: omitted
interior/first visits must be insufficient rather than reordered/invalid; out-of-range
claimed indices must not acquire an invented diagnostic location; overlong-clock
diagnostics belong to time qualification. Added regressions cover these and allowed/
exceeded collection/text limits, including exactly 65,536 bytes versus one extra byte.
Both snapshot copies are bounded. Domain invariants permit at most 255 line/service
segments with 256 stops; tests cover that valid maximum and oversized manifest input.

**Final targeted evidence, r4:** 42 functions / 60 executed cases passed, zero failures,
skips or runtime warnings, iPhone 17 / iOS 26.5 Simulator (arm64). Includes all 26 new
converter functions and the 16 existing timetable-value functions. Debug app and
Live Activity extension dependencies built through the test action. This is not a
full-suite claim. Earlier r1/r2 stopped at compilation (fixture missing an existing
constructor argument, then a before-initialization closure capture); neither ran tests.
Those fixture issues are fixed. r3 passed 41 functions / 59 cases before the last
aggregate-boundary test was added; it is superseded by r4, never added to its counts.

Saved local evidence:

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-dec085-dd -only-testing:TSUGINOTests/SyntheticTimetableConversionTests -only-testing:TSUGINOTests/TimetableValueTests -resultBundlePath /private/tmp/tsugino-dec085-r4.xcresult > /private/tmp/tsugino-dec085-r4.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec085-r4.xcresult
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-dec085-release-dd > /private/tmp/tsugino-dec085-release.log 2>&1
```

**Release:** app/extension build succeeded. A separate no-DEBUG compiler probe using
all three new Data files failed as expected only with “cannot find type” for packet,
converter and civil-time declarations (`/private/tmp/tsugino-dec085-release-probe.log`).
Release executable symbol inspection found no `SyntheticTimetable` symbols. These
checks complement the complete `#if DEBUG` guards; no Release API or consumer is added.
Final incremental Debug log has the AppIntents metadata notice; clean Release reports
75 warning lines in existing isolation, AppIcon and AppIntents categories (historically
recorded elsewhere here). No new converter warning appears. No physical device used.
Initial sandboxed Simulator listing and result-summary cache access required permitted
escalation; neither was test evidence. Only explicit iPhone Simulator work followed.

**Independent review: approved.** A separate non-author reviewer inspected the accepted
contract, actual source/tests, corrections and completion documents, confirmed the saved
r4 summary (42 functions / 60 cases, no failures/skips/runtime warnings), and inspected
Release/probe evidence. No material findings remain. The reviewer reran no tests/builds;
author self-review is not this approval. Only approval/status wording changed afterward.

Final tested and independently verified source/test SHA-256 fingerprints:

| File under repository root | SHA-256 |
|---|---|
| `TSUGINO/Data/Timetable/SyntheticTimetableInput.swift` | `8fa1b15ba519c843f2e88f320df2c57917927634bc9b8978118b6e3757457b1a` |
| `TSUGINO/Data/Timetable/SyntheticTimetableCivilTime.swift` | `abc32b6e4e7e35076496f733a6f08dc0cfa82e8e4a1d13db45a7b02bbbd6a7e6` |
| `TSUGINO/Data/Timetable/SyntheticTimetableConverter.swift` | `10033aac2478fb7a8046802793b315fc384be280b731178e15b229ad6b36ddf7` |
| `TSUGINOTests/SyntheticTimetableConversionTests.swift` | `5596e4be3774a672f0d70b6069fc47ee076f2e76e5a583940e3aa16e05bae3da` |

Documentation/privacy/scope checks and `git diff --check` pass. Work remains unstaged
and uncommitted on `34bdea62dba1de0a61aaf7c2a5c19771cc1e07c7` for publication review.
No private artifact, source feed, archive, provider contact, import, engine adoption,
app wiring or S9 acceptance occurred. P3-T1 is still partial; source-specific profiles,
evidence and validated real import remain separate. P2-S9 retains fourteen classification
and fourteen ordering gaps. Next bounded step: final publication review of this slice,
not a real pilot or automatic broadening of the invented profile.

#### Synthetic timetable-to-routing integration — 2026-10-04 Asia/Seoul

Scope: test-only composition under accepted DEC-078/080/081/085, authorized by the
owner after publication of `853fb9ceccec9ae12deec0cb6244afbeb686a821`. One new
`TSUGINOTests/SyntheticTimetableRoutingIntegrationTests.swift` reuses the existing
invented packet fixture; no support file, application source, settings or new decision.
It invokes the actual converter and passes returned facts unchanged into the existing
active search input, then invokes `SyntheticInternalRouteSearcher` normally.

The artificial A@0 → B@1 world explicitly stipulates one dated execution slot,
complete interval [0,1], finite validity window, membership, permissions and continuity.
Inventory completeness is not inferred from successful conversion or route discovery.
The fixture associates R1 / invented-civil-day-v1 / Z1 / M1 with its immutable view and
policy references; Domain facts do not independently retain or authenticate those tokens.
No calendar scanning, manifest inference, source authentication or real applicability
is implemented. Success maps to active; inactive has no event facts; unsupported,
insufficient and invalid map to unavailable while tests retain conversion diagnostics.

Checks cover ordinary canonical output, exact midnight-crossing instants with the
original service date, inactive scoped noResults, missing/estimated required endpoints,
missing unused counterparts, every conversion failure category, revision conflicts,
consumer snapshot/view/inventory rejection, and legitimate prohibited/out-of-window
exclusions versus coverage failures. Assertions retain the full snapshot, original
indices/address, time tags and converted endpoints. No facts are manually reconstructed.
Existing eligibility, chronology, admission, errors and cancellation are unchanged.

**Validation:** one targeted Debug run passed **62 functions / 113 executed cases**,
zero failures/skips/runtime warnings, on iPhone 17 / iOS 26.5 Simulator (arm64).
This includes the new integration suite (7 functions / 16 cases), converter, synthetic
internal search and timetable ride-context suites; these counts overlap, do not sum.
Debug app/extension dependencies built through the test action. The only build-warning
line is the existing AppIntents metadata notice. No test/build failure occurred.
Initial sandboxed Simulator discovery was denied; permitted escalation enabled the run.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-dec085-dd -only-testing:TSUGINOTests/SyntheticTimetableRoutingIntegrationTests -only-testing:TSUGINOTests/SyntheticTimetableConversionTests -only-testing:TSUGINOTests/SyntheticInternalRouteTests -only-testing:TSUGINOTests/TimetableRideContextTests -resultBundlePath /private/tmp/tsugino-timetable-integration-r1.xcresult > /private/tmp/tsugino-timetable-integration-r1.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-timetable-integration-r1.xcresult
```

Saved summary: `/private/tmp/tsugino-timetable-integration-r1-summary.json`.
Test-file SHA-256: `c11671044f2e229dcf84dd564db9a578b899bbf6031fae0315294e93c6263784`.
The unchanged converter source/test fingerprints match the published DEC-085 evidence;
reuse its Release build, no-DEBUG declaration probe and Release symbol isolation checks.
No Release rebuild or physical-device interaction occurred. Scope/privacy/whitespace
checks pass; only this record and the new test file change. **Independent review approved:**
a separate non-author reviewer inspected the final test composition, documentation,
saved summary/log and matching fingerprint; no material findings remain. The reviewer
ran no tests/builds. Only this approval-status wording changed after that review.

P3-T1 remains partial. P2-S9 remains incomplete with fourteen classification and fourteen
ordering gaps. No private data, archive re-read, real import, provider contact, production
adoption, app wiring or milestone acceptance. Leave this slice unstaged/uncommitted for
publication review; the next bounded step is publication review, not real-data use.

#### Production route-search policy proposal — revised 2026-10-04 Asia/Seoul

Documentation-only after published synthetic integration `f85a3203eb359a0a24d40e694f3d1b5a5b5d23ed`.
The owner explicitly prefers earliest arrival, then fewer train changes at equal arrival;
evidenced through service is not a change. This does not approve the previous R1–R6
recommendations. The all-distinct-return and departure tie-break proposals are withdrawn.
[Consumer proposal §10](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#10-production-objective-and-execution-policy--proposed-dec-086)
and **Revised Proposed DEC-086** recommend all equally optimal distinct recommendations,
with deterministic identity order only, exploration separate from frozen optimal handoffs,
proved optimality/tie completeness, and truthful cutoff failures. Exact return/accounting/
pruning mechanics and ownership remain Proposed; current accepted behavior is unchanged.

Required unknown evidence still prevents success even with a verified direct route.
Best-known/degraded results would require a separate explicit contract amendment; none
is approved. Production limits, inventory/rights/source/performance evidence and engine
adoption remain unresolved. The earlier independent review concerned the superseded draft;
a separate non-author reviewer approved this revised documentation with no material
findings. Scope, local links, privacy and whitespace checks pass. Only this review-status
wording changed afterward. No code/tests/builds or repeated integration.
Next after mechanics approval and separate authorization: invented optimal-set/oracle and
handoff-policy tests only. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification
and fourteen ordering gaps. October 3 ODPT inquiry still awaits a supplied reply. No private
access, feed acquisition, contact, real import, app wiring or milestone acceptance.
Leave documentation unstaged/uncommitted for owner review.

#### DEC-086 scoped acceptance and synthetic selection — 2026-10-04 Asia/Seoul

The owner accepts earliest arrival then changes, evidenced through counting, all
identity-distinct equal optima, reproducibility-only key order, selection before frozen
handoff, preserved admitted candidates, optimum/tie completeness, no first-found/first-K,
searchIncomplete at cutoff, dataUnavailable for unknown required evidence, and defensive
mixed-winner rejection as searchIncomplete. Prior Proposed wording records its historical
review stage. Ownership/algorithm mechanics, production limits/deployment/adoption remain
unapproved; DEC-081 all-distinct behavior is unchanged.

Bounded scope: `SyntheticOptimalRouteSelection.swift`, its invented test file, and these
three pending documents. The synchronous DEBUG helper receives an explicitly stipulated
complete, admissible invented universe with a scope; missing required evidence or incomplete
enumeration has a separate typed input. An array/constructor cannot authenticate completeness,
eligibility, continuity, allowances or real optimality. Selection is conditional on the
fixture assertions, and returns neither RouteSearchResult nor a completeness certificate.
It reuses canonical scope validation, preserves candidates/snapshots/addresses/indices and
directional legs, rejects shared snapshot/event conflicts before ranking, deduplicates exact
keys and retains all minimum-arrival/minimum-change ties in deterministic byte-key order.
No earlier-departure preference, dominance pruning, network, persistence or clock read.

Fixture ceilings are 64 candidates, seven legs (up to four rides), 256 elements per
snapshot array and 128 UTF-8 bytes per identifier/date. They make this small comparison
oracle bounded, not production defaults. Exceeding them returns searchIncomplete without
partial selection. Snapshot copies and immutable canonical values are not mutated.

**Handoff gap, intentionally not implemented:** existing engine admission accepts
SyntheticInternalRide claims plus SyntheticInternalPrepared state, not arbitrary canonical
RouteCandidates. Reusing it for this selection would require an explicit adapter/admission
API and proof of association with prepared state, or broader engine coupling. No new
callback, claimed-admitted flag, substitution seam or competing validator is introduced.
The approved mixed-rejection rule remains an implementation obligation for that later
separately scoped boundary. This helper does not filter already-admitted search batches.

**Final verification (r3): 38 functions / 68 executed cases passed**, including the
new selector suite's 9 functions / 10 cases, plus synthetic internal-routing and timetable
ride-context suites. iPhone 17 / iOS 26.5 Simulator (arm64), zero failures/skips/runtime
warnings. Debug test action built app/extension dependencies. Earlier r1 passed 37/67
before boundary additions; r2 failed after an invalid oversized fixture used adjacent
repeated stops rejected by Trip, and its crash-recovery run was terminated. The fixture
now alternates A/B, remains 257 stops and reaches the intended bound. r3 supersedes
prior runs; do not sum overlapping counts. No source correction was required.

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-dec085-dd -only-testing:TSUGINOTests/SyntheticOptimalRouteSelectionTests -only-testing:TSUGINOTests/SyntheticInternalRouteTests -only-testing:TSUGINOTests/TimetableRideContextTests -resultBundlePath /private/tmp/tsugino-dec086-r3.xcresult > /private/tmp/tsugino-dec086-r3.log 2>&1
xcrun xcresulttool get test-results summary --path /private/tmp/tsugino-dec086-r3.xcresult
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=C9B563FC-6192-404C-8953-93152ED217E2' -derivedDataPath /private/tmp/tsugino-dec085-release-dd > /private/tmp/tsugino-dec086-release.log 2>&1
```

Saved final summary: `/private/tmp/tsugino-dec086-r3-summary.json`. Release app/extension
build succeeded. The no-DEBUG typecheck probe fails exactly for the two new missing
declarations (`/private/tmp/tsugino-dec086-release-probe.log`); Release executable symbol
inspection finds no SyntheticOptimalRoute symbols. Final Debug has one existing AppIntents
warning line; Release has 67 existing isolation/AppIntents warning lines, no new helper
warning. No physical device used. These are targeted results, not a full-suite claim.

Final SHA-256 fingerprints:

| File | SHA-256 |
|---|---|
| `TSUGINO/Data/Routing/SyntheticOptimalRouteSelection.swift` | `fef9f27eb2ba46988ede839507e2c0acc372bac77088b6ee47d430e49f839be6` |
| `TSUGINOTests/SyntheticOptimalRouteSelectionTests.swift` | `3bb8839880c488cc59edb4dd83ca3bd4d829baaa3fa9601f98b087e98824c95e` |

Independent review found the invalid boundary fixture; corrected as above and re-reviewed
without further source/test findings. **Final independent review approved:** a separate
non-author reviewer verified final fingerprints, r3 summary/log, Release build/probe and
absence of Release symbols, and the completion record; no material findings remain.
The reviewer reran no tests/builds. Only approval wording changed after final review.
Scope/privacy/whitespace checks pass. No application wiring or changes to the existing
synthetic engine. P3-T1/Phase 3 remain incomplete; P2-S9 retains
fourteen classification and fourteen ordering gaps; ODPT inquiry reply remains unsupplied.
No private data, real import, provider contact, production adoption or UI work. Leave the
slice unstaged/uncommitted for publication review.

#### DEC-086 prepared-path handoff design — 2026-10-04 Asia/Seoul

Documentation-only after published selector `b43b5eb10009e318c52207e0c5115bad9e455262`.
[Consumer proposal §11](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#11-prepared-path-optimal-handoff-integration--implementation-design)
traces prepare → path/claim → admission → canonical candidate, locating optimal selection
after exhaustive preparation and before frozen handoffs. Proposes opaque same-session
path descriptors, shared selector key/objective logic, original prepared-state resolution
and explicit winner-count finalization. No candidate-to-claim reverse mapping, admission-
then-filter loop, second validator or reduced prepared-state fabrication. Complete fixture
inventory and successful enumeration remain separate prerequisites; unknown coverage and
cutoffs keep accepted failures. Slower exploration is not rejection accounting.

This is API plumbing under accepted DEC-086, not a new preference/decision record. Existing
DEC-081 code/behavior is unchanged in this task. Next authorized implementation would add
one DEBUG adapter and minimal shared helper extractions with targeted synthetic/accounting/
cancellation tests and Release isolation. No implementation occurred here; defensive handoff
integration is still unimplemented. Scope, local links/section target, privacy and
whitespace checks pass. A separate non-author reviewer approved the design against the
actual prepare/claims/admit/finalize and selector APIs with no material findings. Only
this review-status wording changed after approval.
No tests/builds, private access, provider contact, real import, production budgets/adoption,
app wiring or milestone acceptance. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen
classification and fourteen ordering gaps. Leave docs unstaged/uncommitted for review.

#### DEC-086 bounded prepared optimal handoff implementation — 2026-10-04 Asia/Seoul

Owner-authorized implementation of the independently reviewed Consumer proposal §11.
DEBUG `SyntheticOptimalRouteSearcher` retains a private completed preparation session,
derives descriptors without canonical candidates, selects every distinct equal optimum,
and resolves original claims into existing admission. Shared incremental key/objective
selection and finalization helpers preserve the published selector and DEC-081 all-distinct
behavior. No engine enumeration or Domain semantic change. Slower paths are objective
exclusions; selected mixed rejection is `searchIncomplete`, all rejected preserves contiguous
selected-index omissions, complete empty remains scoped `noResults`. Missing evidence,
cutoffs and cancellation remain truthful and atomic. Completeness still requires a stipulated
complete invented inventory plus successful exhaustive preparation; no real optimality claim.

The first sandboxed Xcode attempt could not
reach Simulator services; the first service-enabled build identified test assertion syntax
requiring predicate matching for non-Equatable `RouteSearchFailure`. That test-only issue
was corrected before execution. No application crash or source defect was observed in that
build failure. The first executed run exposed a test-fixture assumption: randomized
three-key dictionary order can change preparation insertion-sort work, invalidating a
cross-run exact-budget assertion. The corrected two-ride fixture has a stable comparison
count and still exercises tied-key selection. Neither correction changes routing behavior.
Final evidence below supersedes those attempts; overlapping runs are not added.

- Final targeted run on explicit iPhone 17 Simulator, iOS 26.5: **47 functions / 81 executed
  cases passed**, zero failures. Included new handoff **9 / 13**, published selector **9 / 10**,
  existing internal engine/admission **19 / 44**, and timetable context **10 / 14**.
  Result bundle `/private/tmp/tsugino-optimal-handoff-r4.xcresult`; Debug test action built
  app and extension dependencies. Counts are one final run, not sums of reruns.
- Release app/extension build passed (`tsugino-optimal-handoff-release.log`). No-DEBUG
  compiler probe verified all eight probed new/changed/session declarations are absent;
  Release executable symbol scan found none. DEBUG `@testable` client compilation cannot
  name the private prepared session or its handle, ruling out foreign/forged handle input
  through that boundary. Initial diagnostic-count checker double-counted Swift's repeated
  error rendering; checking the two source diagnostics confirmed the expected rejection.
- Separate non-author final review **approved with no material findings remaining**.
  Reviewer checked source/tests/documentation, mapped admission predicates to preparation
  invariants, independently read the final xcresult counts, and verified the five fingerprints.
  Minor kernel-comment and originally-fileprivate wording corrections are resolved; approval
  covers those wording corrections and this verdict record. Exact eight-file scope, local
  decision/proposal links/section target, new-file whitespace, DEBUG guards, fingerprint,
  privacy/persistence/network and `git diff --check` checks pass. No unrelated changes.

Final verified source/test SHA-256 fingerprints (documentation review recorded separately):

| File | SHA-256 |
|---|---|
| `TSUGINO/Data/Routing/SyntheticOptimalRouteKernel.swift` | `027cc4e5f83cef6c35f00bdfafd2baeedd90edb9c639605c670f2c89d1ae8a87` |
| `TSUGINO/Data/Routing/SyntheticOptimalRouteSearcher.swift` | `f2461acf1d5e41ff707b1d42da0f71a0718c738249bc6d426344767819bfc4b7` |
| `TSUGINO/Data/Routing/SyntheticOptimalRouteSelection.swift` | `c50618f6418ddc4eba402af627cf054fa9f9413ae16cd8d0507e56679a140871` |
| `TSUGINO/Data/Routing/SyntheticInternalRouteSearcher.swift` | `b4f0cd2acafa723b30c7727b1cc049c60c03ad1a180605a4733531c26663acec` |
| `TSUGINOTests/SyntheticOptimalHandoffTests.swift` | `294a2f59a98883435f7387094f87879bc6bb136e1540b4e2d7ea1237bcf2e44c` |

No private access, provider contact, real import, production limits/adoption, app wiring or
milestone acceptance. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification
and fourteen ordering gaps. Leave all changes unstaged/uncommitted for publication review.

#### DEC-085 → DEC-086 test-only optimal-routing composition — 2026-10-04 Asia/Seoul

After published handoff `d92c854ecede7ce586941e0b32c6c22ddfc1027c`, the missing proof
was the complete converter → prepared optimal selection → admission → canonical result
composition. Existing timetable-routing integration proves converter-to-DEC-081 all-distinct
search; existing optimal-handoff tests start with authored timetable facts. Those remain
unchanged. No accepted API or application-source change is necessary.

`SyntheticTimetableOptimalRoutingIntegrationTests.swift` reuses the invented converter
packet fixture and passes each actual conversion success value unchanged into an active
inventory slot for `SyntheticOptimalRouteSearcher`. Test composition preserves inactive and
unavailable mappings; it adds no application adapter. The fixture explicitly stipulates
complete finite Trip/date/interval inventory within a one-hour window, active permissions,
affirmed continuity and every directional connection (absent except one evidenced same-
station connection with a 60-second allowance). These are invented test values, not new
production defaults. R1/profile/Z1/M1-to-view/policy correspondence is stipulated explicitly;
Domain facts do not authenticate revision tokens, and conversion does not prove completeness.

Four test functions / six scenario cases cover faster direct, faster transfer, equal-arrival
fewer changes, all distinct equal optima, a civil-midnight transfer using extended hours,
and missing timezone evidence alongside a usable direct route. Assertions check canonical
route keys, no rejection omissions for slower alternatives, converted exact/missing tags,
permissions, full dated snapshot/index association and literal UTC instant oracles. The
unavailable conversion retains its typed diagnostic and causes `dataUnavailable`, never a
direct-only fallback. No manually constructed timetable facts substitute for any route.
Calendar edge cases, other conversion failure categories, scope/revision mismatch mechanics,
through-service, defensive admission rejection and cancellation limits reuse existing suites.

Validation: combined targeted run `tsugino-timetable-optimal-integration-r1.xcresult`
passed **55 functions / 84 cases** on explicit iPhone 17 Simulator, iOS 26.5. Independent
review recommended distinct packet run keys per Trip (evidence IDs stay packet-local;
calendar service may be shared). This fixture-only clarification was applied. Final new
subset `tsugino-timetable-optimal-integration-r2.xcresult` passed **4 functions / 6 cases**,
zero failures. Retain unchanged regression evidence **51 functions / 78 cases**
from r1: converter 26/39, optimal handoff 9/13, selector 9/10, and prior timetable-routing
integration 7/16. The earlier new-subset 4/6 is replaced, never added to its final rerun.
Debug test actions build app/extension dependencies. Unchanged Release build,
declaration/symbol exclusion and private session/handle access evidence from the published
converter/handoff slices is reused: application source, configuration and target membership
are unchanged. No Release rebuild is needed for this test-only slice.

Independent source/documentation and final evidence review approved with no material
findings remaining. Exact two-file scope, empty index, whitespace, DEBUG guard, reviewed
handoff source fingerprints, absence of fact reconstruction/private data/network/persistence/app wiring and
`git diff --check` checks pass. Final test SHA-256:
`0b212efe26690bd197a93ba17721c8417d0ccfbf84fb9bb4ca24e161bf605451`.
No private access, real import, provider contact,
production adoption or app wiring. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen
classification and fourteen ordering gaps. Leave both files unstaged/uncommitted for review.

#### Phase 3 current progress map — 2026-10-04 Asia/Seoul

Audit baseline: published `fa3ee9d1865eb5854786c4b4c0946107943c6461` on
`phase/03-route-search`; initial working tree/index clean, cached upstream identical.
This is a current-state consolidation, not a new work breakdown or acceptance decision.
The earlier numbered planning sequence is historical **Proposed order**, not task IDs.
Rows below use the existing Phase 3 Included/Implementation Tasks/criteria titles and
accepted decision references; P2-S9 is a carried-over dependency. Earlier “next task” and
“unimplemented” entries describe their recorded dates; use this map with the subsequent
accepted overlays and published completion records, not those historical proposals alone.

Current position: pure route/timetable contracts, bounded DEBUG conversion, all-distinct
search, optimal selection/admission and their end-to-end invented composition are verified.
They establish neither production solver adoption nor real timetable/source readiness,
Application consumption or Phase 3 acceptance. DEC-086's accepted arrival/change objective,
all distinct equal optima, through-service treatment and truthful incomplete/unavailable
outcomes remain settled; its historical Proposed preference wording is not current truth.
No ODPT interpretation reply has been supplied. The owner reported sending that inquiry
on October 3; it is distinct from the retained publication/translation/bundling rights gates.

| Existing task / milestone reference | Accepted scope | Implemented / verified evidence | Remaining work | Dependencies | Can proceed without ODPT reply/private access? |
|---|---|---|---|---|---|
| **P2-S9** (carried over, DEC-075/082) | Untimed canonical passenger-stop Trip structures and reviewed correspondence | Bounded extraction/review/registration tooling; owner-reported pilot 14 occurrences, zero transport-order inversions | All 14 classification and 14 ordering gaps; applicable interpretation, occurrence evidence, review/registration and S9 acceptance | Source/revision interpretation, explicit real-access scope, S4 identity/provenance; zero optional recorded gaps are not satisfied requirements | No real closure from current evidence. Independent design remains possible; do not repeat provenance tracing or private reads |
| **P3-T1 — Timetable Contract and Static Schedule Import** (DEC-074/078/085) | Dated facts separate from recurring Trip; qualified activation/time/eligibility, immutable view/snapshot/index binding | Domain facts/context/chronology; DEBUG invented calendar/civil-time converter; converter-to-search composition published at `f85a320` and optimal composition at `fa3ee9d` | Source-specific profiles/applicability, complete execution/calendar/connection inputs, real normalization/import, version/update/consumer qualification and T1 acceptance | S9 before real Trip use; S4 and accepted local baseline, identified authorized inputs, applicable rights and revision evidence | Synthetic/contract work yes; real import/acceptance no. DEC-085 is not a Toei/ODPT profile |
| **integrate selected provider**; DEC-077, DEC-080 P5, DEC-086 R6 | Replaceable routing boundary; ODPT-first evaluation priority; accepted fastest objective/completion rules | DEBUG external adapter and finite internal engine; optimal wrapper/handoff published `d92c854`, not a production solver | Select/adopt production provider or internal strategy; algorithm/pruning proof, optimizer ownership/deployment, versioned objective-policy resolution (accepted objective unchanged), production horizon/ride/resource limits, measured suitability | Complete inventory, source/transfer/through evidence, licensing/operations and performance measurements; DEC-004 stays Provisional, R6 unresolved, commercial evaluation/contact paused | Ownership/algorithm/resource-policy design and invented performance methodology yes; actual budgets/adoption require evidence and explicit decisions |
| **map provider stations/lines to canonical IDs** | Reviewed canonical identities, exact mappings, no name/coordinate substitution | Accepted Phase 2 local provisional station/line baseline; DEBUG route mapping/coherent-view rejection | Qualify actual route/source joins and runtime mapping view; real Trip mapping remains S9; shipping identity/delivery | DEC-068 registry-of-record/adoption, P2-S8 delivery/composition, relevant rights gates; local acceptance is not production promotion | Synthetic interface design yes; actual joins/delivery need authorized evidence |
| **normalize route candidates**; Included `RouteCandidate` | Canonical proposals, no automatic train selection/Journey creation; evidence and omission accounting | Domain route values; DEBUG external admission and internal preparation/admission; context/identity/chronology tests | Real source qualification and selected production integration; no need to rebuild constructors/admission | Provider/source decision, mappings, real timetable where consumed | Existing bounded implementation complete; source-independent consumers can proceed |
| **route alternatives** (Included; DEC-086) | Earliest arrival, then fewer changes; all distinct equal optima; identity order only reproducibility | Shared DEBUG selector, private prepared session, winner-only admission; mixed rejection incomplete, total rejection accounted; `fa3ee9d` uses unchanged converter facts | Production optimum/tie completeness proof and bounded execution, not another synthetic comparison helper | Production strategy, complete inventory and justified limits; no first-K or fallback on unknown evidence | Design yes; no production completeness claim from synthetic arrays |
| **represent transfers** | Explicit directional connection evidence and qualified allowance; canonical stated walking links | Canonical structures; DEBUG same-station/walking validation and transfer/multi-transfer tests | Applicable real transfer relations, directional allowances and policy resolution | Source/profile/rights evidence; station equality alone is insufficient | Invented design yes; real feasibility closure no |
| **preserve through-service continuity** | One evidenced continuous train is not a change across line/operator boundaries | Indexed Trip segments and canonical admission; synthetic through/fewer-change tests | Source-backed continuous-train joins and coverage for supported real routes | S9/Trip correspondence and applicable continuity evidence | No new mechanism needed for tested synthetic case; real qualification remains gated |
| **expose scheduled train context** | Provider assertions and dated timetable-derived context remain distinct, not realtime | `ProviderScheduledContext`, `TimetableRideContext`, conversion-to-canonical exact instants/date/index proof, including midnight | Real qualified schedule production/consumption and source validity/update handling | P3-T1/source contract and applicable mappings/evidence | Consumer design yes; real scheduled readiness no |
| **handle provider errors**; **basic route-search diagnostics** (Included) | Typed recoverable failures, truthful empty/unavailable/incomplete, cancellation distinct from outage | `RouteSearchFailure`, omission vocabulary, DEBUG raw-error containment and cancellation/concurrency tests | Application recovery/publication workflow, localized presentation, actual provider failure qualification | Caller lifecycle contract; provider-specific evidence for real errors | Yes for Application contract/consumer work; do not reimplement tested Data cancellation/errors |
| **RouteSearching** (Included; DEC-076 §A, ARCHITECTURE §10) | Domain async Sendable port; Application owns task lifetime/superseded-response suppression; injected Clock resolves now once | Port and DEBUG implementations exist; Data calls retain independent coherent views | Provider-neutral Application request owner, injected port/Clock, current-request publication guard, disposal/cancel/recovery contract | Application observable-state design; production implementation selection only for later live composition | **Yes**, with fake port and clock. R6 optimizer ownership is not a blocker to accepted Application lifetime ownership |
| **feature code receives canonical RouteCandidate** (Acceptance Criteria) | App/feature consumption through provider-neutral boundary, DTO isolation | Canonical outputs verified in tests; `AppEnvironment` currently contains only configuration/clock/logging; no route coordinator or route-search feature binding | Actual composition/injection and route workflow, supported state/error consumption; candidate-to-Journey behavior stays in its later owner | Application contract, subsequently approved live implementation/data; no silent DEBUG-to-live promotion | Consumer design/fake-backed work yes; live app integration/acceptance requires later authority/evidence |
| **cache safe route-search responses where permitted** | Only permitted, coherent safe response caching | No route-response cache implemented; Phase 2 SQLite/repository caches are different deliverables | Rights-specific eligibility, key/revision/scope identity, freshness/invalidation/deletion and stale-response policy before implementation | Selected source/provider terms and runtime update model; no invented TTL or persistence default | Policy options/design yes; real caching cannot be approved from generic/local-storage support |
| **Japanese / English / Korean route content** (Included) | Canonical names and centralized language resolution; provider DTO/text cannot leak | Canonical localized railway name values and reviewed Phase 2 names; identity/leakage fixtures | Route-specific labels/failure/recovery content, actual route/headsign coverage and rendering validation | Source/name rights and Q4 for new Metro-derived translations; broader language/accessibility audit remains Phase 12 | Project-owned generic wording/consumer design yes; gated source translations and coverage no |
| **Tests / Acceptance Criteria / Exit Criteria / Decision Gate** (Phase 3) | Direct/one-/multi-transfer/local-express/through/malformed/unknown-mapping/outage; canonical-only feature results, continuity and recoverability; usable supported Tokyo plans; quality/pricing/licensing/Trip identity/mapping stability | Synthetic contract, admission, failure, conversion and optimal-handoff suites; latest new composition 4 functions/6 cases plus separate unchanged regressions 51/78 | Real supported-plan and feature-consumer evidence, production suitability, scope/architecture/docs audit and applicable delivery gates; no whole-phase acceptance | All relevant rows above; unchanged 15-line launch boundary, S9/T1, identity/rights/delivery; Track A/P2-S10 only for expansion claims | Audit/design and independent synthetic work yes; Phase 3 exit no. No additional physical-device task is specified by Phase 3 itself |

**Smallest useful next slice (recommendation, not implementation authority):** a bounded
**Application route-search lifecycle/consumer contract design**, under the existing
`RouteSearching`/recoverable-failure work, using a fake port and injected `AppClock` in its
examples. Produce a concrete request-owner state/transition and injection specification:
submit/replacement, one-time “now” capture, cancel/dispose, current-generation publication,
canonical result/failure preservation and explicit user retry. Include delayed old success
and delayed old failure after replacement, repeated identical requests and cancellation
that an underlying worker observes late. Do not add a solver, change candidate ordering,
cache responses, construct Journey state, wire AppEnvironment or implement UI in that slice.

Why it is missing: `RouteSearching.swift` and DEC-076 §A6–7 explicitly assign this responsibility
to Application; ARCHITECTURE §10 says supersession is unimplemented. `RouteSearchingTests`
verify separate Data calls and cancellation, explicitly “No UI supersession.” The new optimal
composition tests likewise invoke a searcher directly. They cannot prove caller publication
ownership. `AppEnvironment.swift` has no RouteSearching dependency. This is a real consumer
gap, not a reason for another converter/search integration test or cancellation rewrite.

**Settled versus new choice:** Application ownership, cancellation propagation, suppression
of obsolete results, no implicit retry and no automatic train/Journey selection are already
accepted. The observable treatment of a previous successful result during replacement,
explicit cancellation or failure is not specified. Recommend a minimal current-request-only
state: invalidate old published results on replacement and clear on explicit cancel, with
manual retry; any retained historical result must remain explicitly separate, never presented
as the replacement request's answer. This is a Proposed consumer-state choice for owner review,
not a newly accepted UI policy. Request-generation mechanics and constructor injection are
routine implementation choices after that contract is clear. Production Data optimizer R6,
numerical budgets, deployment/adoption and source evidence stay separate. After approval and
separate authorization, the resulting smallest code slice would implement that Application
owner with deterministic fake-port tests, without live AppEnvironment/UI wiring.

Audit checks: tracked docs/code and recorded completion evidence only; no tests/builds,
external research, private access or provider contact. Documentation scope/privacy/whitespace
checks pass. Separate non-author review found no material findings; it verified task references,
accepted overlays, code-grounded lifecycle gaps and the Proposed consumer-state boundary.
P3-T1 and Phase 3 remain
incomplete; P2-S9 retains fourteen classification and fourteen ordering gaps.

#### Application route-search lifecycle proposal — 2026-10-04 Asia/Seoul

Documentation-only follow-up to the preserved, independently reviewed progress map above.
[Consumer proposal §12](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#12-application-route-search-lifecycle--proposed-dec-087)
and Proposed DEC-087 specify intent-to-request Clock capture, opaque per-invocation identity,
serialized replacement/cancellation/disposal, a guard for every terminal completion,
unchanged canonical outcomes and fake-backed dependency injection. Existing Application
ownership and Data cancellation contracts are reused, not redesigned. There is no existing
Application implementation to adopt; AppEnvironment still has no RouteSearching dependency.

Owner choices remain **Proposed**: C1 current-request-only results/failures, cancellation
state and terminal disposal; C2 explicit retry of the matching failed attempt, fresh identity,
explicit-time preservation versus a new one-time Clock capture for now. Examples include
slow A→B then A→C, old success/failure after replacement, completion after cancel/dispose,
identical requests, stale actions and retry. No production route preference is reopened.
Next after approval and implementation authority: the minimal Application owner/state and
controlled fake-port/Clock tests, without live app wiring, caching or another solver test.

Documentation scope/reference/privacy/whitespace checks pass. Separate non-author review
approved with no material findings remaining. The review corrected one wording conflict:
accepted attempts schedule one worker with at most one port call (zero if cancellation is
observed before invocation); the future test scope includes that case. C1/C2 stay Proposed.
No code, tests/builds, private access, provider contact, production adoption, UI or app wiring.
P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering
gaps. No ODPT reply has been supplied. Leave all documents unstaged/uncommitted for review.

#### DEC-087 Application request-owner implementation — 2026-10-04 Asia/Seoul

Owner accepted C1 current-request-only route results and C2 matching-failure retry, with
fresh invocation identity, unchanged explicit departure and renewed one-time now capture.
This overlay supersedes the historical Proposed/next-implementation wording above; the
previous independently reviewed progress consolidation and Consumer §12 design are preserved.
Clearing route results **does not delete recent-station history**. Existing device-local
recent-station policy is unchanged; history storage, limits, deduplication and deletion UI
are neither implemented nor newly accepted by this slice.

`Application/Routing/RouteSearchCoordinator.swift` provides the main-actor request owner,
immutable intent/attempt identity and typed lifecycle states. It validates before mutation,
uses injected RouteSearching/AppClock, cancels obsolete work and guards every terminal
completion by live invocation identity and searching state. Invalid submissions preserve
existing state; cancellation is separate; disposal is terminal. Retry requires the current
failed identity and schedules a new worker with at most one port call. Pre-invocation
cancellation can produce zero calls. Canonical results/scopes/contexts/omissions and failure
payloads remain unchanged; no ranking/admission is duplicated. Worker capture is weak with
respect to the owner. State is provider-neutral and Release-capable; the read-only captured
worker completion barrier is DEBUG-only and has no mutation/cancel handle.

Controlled fake-port/Clock tests cover obsolete success/failure/cancellation/raw error,
replacement and identical requests, late completion after cancel/dispose, stale/foreign IDs,
matching retry timing, invalid-input nonreplacement, every canonical failure, scoped and
unscoped empty/alternatives with contexts and omissions, unexpected-error containment,
zero-call pre-invocation cancellation and owner release during suspended work. No sleeps,
actual provider, synthetic routing engine invocation or duplicated Data cancellation tests.

Initial compilation found two test-only Swift syntax/type-inference errors (await inside a
boolean autoclosure and a mixed-error ternary); corrected before test execution.

- Final focused run `/private/tmp/tsugino-lifecycle-r2.xcresult`: **35 functions / 56 cases
  passed**, zero failures, explicit iPhone 17 / iOS 26.5 Simulator. Includes owner **9/28**,
  RouteSearching **10/10**, AppClock **3/3**, InternalSearchSuccess **13/15**. These are one
  final run; no overlapping/superseded execution counts are added. Debug test action built
  app and extension dependencies.
- Release app/extension build passed (`/private/tmp/tsugino-lifecycle-release.log`). Release
  object symbols contain RouteSearchCoordinator and exclude completionCheckpointForTesting:
  the Application abstraction ships as code, while the read-only test barrier does not.
  This is compilation evidence, not live composition or production routing adoption.
- Independent source/test review found no material defect; it requested the narrow stale
  ARCHITECTURE supersession-status correction, which is applied. Final independent
  documentation/evidence review approved with no material findings remaining. No source
  change was needed after source review.

Final source/test SHA-256:

- `TSUGINO/Application/Routing/RouteSearchCoordinator.swift`: `a9e485cf291480e22bfa7197ba54b404e820c41602597eef86158b4bfd7829fc`.
- `TSUGINOTests/RouteSearchCoordinatorTests.swift`: `91826ad99a3f54eef4606c35fb0f5ee3bc2c835daf7c767222575bc8dba451f1`.

Debug/Release checks are scoped to this new Application source. ARCHITECTURE's formerly missing-supersession
statement is updated narrowly; live AppEnvironment and feature integration remain unimplemented.
No private access, provider contact, UI, cache, recent-history implementation, automatic
Journey/train selection or production routing adoption. P3-T1/Phase 3 remain incomplete;
P2-S9 retains fourteen classification and fourteen ordering gaps. No ODPT reply supplied.
Leave changes unstaged/uncommitted for publication review.

#### Application route-search composition design — 2026-10-04 Asia/Seoul

Published lifecycle baseline: `d35fc8426bda597dcc0cac3b2f2aac09affa9e83`; clean initial
checkout on phase/03-route-search, cached upstream identical. [Consumer proposal §13](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#13-application-composition-and-coordinator-provisioning-design)
addresses the next missing App-owned constructor/factory boundary, not another lifecycle
implementation. Recommend optional explicitly injected RouteSearching in immutable
AppEnvironment, plus a main-actor typed notConfigured/ready provisioning method. Each ready
result is a fresh coordinator using the existing environment Clock; construction does not
read time or invoke search. Consumer lifetime hosts retain/dispose their own owners.
Live/default assembly stays unconfigured; no fallback or DEBUG solver is installed.

No new semantic decision: DEC-087 C1/C2 and recent-station policy remain unchanged. Next
bounded implementation is AppEnvironment provisioning plus controlled fake composition tests
and documentation, without TSUGINOApp/AppShell/UI changes or production adoption. Tests should
prove exact dependency wiring, independent owners, host disposal, unchanged canonical handoff
and explicit unconfigured behavior; reuse existing lifecycle edge coverage. This entry and
§13 are design only, not evidence of implemented factory or feature consumption.

Documentation-only scope; no tests/builds, private access, provider contact or external
research. Scope, preservation, local-link, privacy and whitespace checks passed. Separate
non-author documentation review approved with no material findings. P3-T1/Phase 3 remain incomplete; P2-S9
retains fourteen classification and fourteen ordering gaps. No ODPT reply supplied.
Leave changes unstaged/uncommitted for review.

#### Application route-search composition implementation — 2026-10-04 Asia/Seoul

Owner authorized the independently reviewed Consumer §13 design. AppEnvironment now keeps
an optional explicitly injected RouteSearching, with nil default preserving old constructor
calls, and a MainActor factory returning typed notConfigured or a fresh coordinator using
the same injected Clock. No clock read/search occurs during composition. Each consumer
lifetime host owns/disposes its independent coordinator. Live/default assembly remains
explicitly unconfigured in Debug and Release; no fallback, DEBUG solver or false empty result.
The prior reviewed design/progress records are preserved with implementation overlays.

New controlled-fake composition tests cover inert construction, exact now/explicit dependency
wiring, independent environments and per-consumer owners, copied environments, host disposal
isolation/late completion, fresh idle owners, canonical scope/context/omission/failure handoff
and explicit nil, omitted port, live and SwiftUI defaults. No sleeps. Existing coordinator
suite supplies lifecycle edge coverage; coordinator and real app/feature roots are unchanged.

Validation (one final run, no overlapping counts added):

- `/private/tmp/tsugino-composition-r1.xcresult`: **20 functions / 44 cases passed**,
  zero failures, explicit iPhone 17 / iOS 26.5 Simulator. Includes composition **5/10**,
  coordinator **9/28**, AppEnvironment **3/3** and AppClock **3/3**. Debug test action
  built app and extension dependencies; no test corrections or reruns were required.
- Release app/extension build passed (`/private/tmp/tsugino-composition-release.log`).
  AppEnvironment uses the same unconditional nil live/default port in Debug and Release;
  no synthetic/fallback dependency reference. No changed-Swift-file compiler warnings;
  existing unrelated Domain isolation/AppIntents warnings are not represented as fixed.
- Independent source/test/documentation/evidence review approved with no material findings.
  Scope, reviewed-design preservation, privacy and whitespace checks passed.

No UI, caching, recent-history
implementation/deletion, Journey creation, private access, provider contact or production
adoption. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen
ordering gaps. No ODPT reply supplied. Leave changes unstaged/uncommitted for publication review.

#### Provider-neutral route-search presentation design — 2026-10-04 Asia/Seoul

Baseline `45818ecaf2ec3cbd5c6ecb5018df9bb781010a39`, clean phase/03-route-search checkout,
cached upstream identical. [Consumer proposal §14](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#14-provider-neutral-route-search-presentation-contract)
and DESIGN §13.4 define a documentation-only current-state/action projection and draft
project-owned JP/KO/EN copy. Canonical payload, scope, contexts and omissions remain internal;
no raw keys/diagnostics are user copy. Scoped noResults, rejected alternatives, missing evidence,
incomplete work, cancellation and unconfigured composition remain distinct. DEC-087 matching
retry/time capture, identity guards, independent owners and recent-station boundaries stay fixed.

Proposed local choices: P1 supplementary rejected-draft feedback and its clearing/stale-action
behavior; remaining P2 project-owned copy/grouping. The owner approved only the notConfigured
wording correction in §14: 現在、経路検索はご利用いただけません。 / 현재 경로 검색을 사용할 수 없습니다. /
Route search is currently unavailable. Internal capability/failure distinctions and actions
are unchanged; no automatic retry, temporary-outage assertion or restoration promise.
No lifecycle or objective decision is reopened.
After approval and implementation authority, the smallest next slice is a pure presentation
contract mapper and centralized route-status/action copy, with controlled values and language
policy tests. No actual FeatureModel/screen/observation bridge or live route invocation.
Phase 3 owns canonical consumption/recoverable failures and route content; Phase 8 owns the
complete foreground flow and Phase 11 language/accessibility hardening. No new task IDs.

Documentation scope/reference/privacy/whitespace checks passed. Separate non-author review
approved with no material findings on the original proposal and the focused wording revision.
P1 and remaining P2 stay Proposed for owner review.
No code, tests/builds, external research, private access, provider contact, caching/history
implementation or production adoption. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen
classification and fourteen ordering gaps. No ODPT reply supplied. Leave unstaged/uncommitted.

#### Provider-neutral route-search presentation implementation — 2026-10-04 Asia/Seoul

Owner accepted P1 supplementary rejected-draft feedback and P2 reviewed project-owned
JP/KO/EN copy/grouping, including the already approved notConfigured wording, and authorized
this bounded implementation. Historical Proposed/partial approval records above and in
Consumer §14 are preserved; P1/P2 are no longer awaiting approval. This does not accept UI,
production adoption or whole-milestone readiness.

Pure Features/RouteSearch values project explicit notConfigured/current lifecycle snapshots
into status/copy and guarded-operation action descriptors while retaining the full original
canonical source. Candidate order, scope, contexts, indices and omissions remain unchanged.
Separate draft-feedback tokens record only current-draft rejection and clear on edit/accepted
submission. No workflow/task/Clock read or persistence. Shared AppLanguage resolves caller-
supplied ja/ko/other tags centrally; no ambient preference read or app localization wiring.
Exact approved notConfigured strings remain in the copy table. DEC-087, AppEnvironment and
recent-station-history boundaries remain unchanged.

Final focused run `/private/tmp/tsugino-presentation-r1.xcresult`: **28 functions / 98 cases
passed**, zero failures on explicit iPhone 17 / iOS 26.5 Simulator. Includes presentation
**6/21**, exact copy/language **2/33**, coordinator **9/28**, composition **5/10**,
AppEnvironment **3/3**, AppClock **3/3**; one run, no overlapping counts added. Debug test
action built app/extension dependencies. No compile/test correction or rerun was required.
Release app/extension build passed (`/private/tmp/tsugino-presentation-release.log`).
No warnings in changed Swift files; unrelated existing warnings are not claimed fixed.
Independent source/test/documentation/evidence review approved with no material findings
remaining; clarified that action-array/table order is not visual priority.

No SwiftUI screens, navigation,
feature-flow wiring, caching/history storage, Journey/train actions, private access, provider
contact or production adoption. Full screens remain Phase 8; comprehensive localization/
accessibility hardening remains Phase 11. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen
classification and fourteen ordering gaps. No ODPT reply supplied. Leave unstaged/uncommitted.

#### Production-routing algorithm evaluation proposal — 2026-10-04 Asia/Seoul

Baseline `307edac9117d7d1496d88a700f06019d23777513`; clean phase branch, cached upstream
identical. Consumer proposal §15 compares current-graph strict incumbent pruning, expanded
state/priority labels and round-based scanning against DEC-086's lexicographic objective
and complete distinct equal-optimum requirement. Code audit records quadratic pair checking,
combinatorial copied-path discovery, insertion sorting and late selector limits; no production
performance claim. One primary RAPTOR paper informs the alternatives, not TSUGINO applicability.

Proposed smallest experiment: retain exhaustive oracle and canonical admission, separate the
existing internal qualified-graph boundary from discovery, then prune only prefixes with a
proved strictly worse objective lower bound. Validate all required evidence first; retain
all equal ties, original occurrence/date/Trip/connection identity and truthful failures.
Named invented case families, oracle comparisons, logical work/memory/time measurements and
explicit experiment-only bounds are specified. No benchmark or code executed. Production
horizon/ride/resource settings, solver ownership and adoption remain unresolved under R6.
Application coordinator/composition/presentation are untouched.

Documentation scope/reference/privacy/whitespace checks passed. Independent review approved
with no material findings remaining after clarifying oracle-domain prequalification: all
original paths/descriptor inputs, including pruned slower paths, must fit existing guards;
pruning cannot turn an out-of-domain oracle failure into success evidence.
P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering
gaps. No ODPT reply supplied. No private access, feeds or provider contact. Leave unstaged/uncommitted.

#### Authorized bounded pruning experiment — 2026-10-04 Asia/Seoul

Owner authorization is limited to Consumer §15's DEBUG-only invented-data experiment,
correctness tests and measurements. The two reviewed proposal documents are preserved;
no production algorithm, numerical product budget or adoption is accepted. Shared engine
qualification/discovery is separated without changing the ordinary exhaustive path. The
experimental adapter requires successful bounded exhaustive preparation/selection/admission
before the pruned pass, reuses original claims and canonical admission, and retains strictly
all equal optima. `AppEnvironment.live()` still supplies no routing port.

Consumer §15.7 defines exact abort-only input/graph/frontier/work bounds, the proof from
preparation invariants to admission, and every metric. Counters are structural counts, not
allocated bytes. A caller cannot raise the 200,000-step per-pass experimental ceiling.
No >64-path survivor-based success is permitted. Tested 65-path input fails before pruning.

**Final verification:** iPhone 17 Simulator, iOS 26.5, arm64, Xcode 27.0 (27A266a), macOS
26.6.2; Debug `-Onone`, Swift 5 language mode, `test` action: **74 functions / 126 executed cases passed**. Included experiment
subset: **10 functions / 25 cases**; other included suites are exhaustive internal search,
optimal selection/handoff, route admission and timetable-to-optimal integration. These are
overlapping subset/total counts, not additive. This run supersedes compile-only and fixture-
correction attempts (validity windows and deterministic incumbent traversal order); no source
crash was observed or used as evidence. Debug app/extension dependencies and Release
app/extension build passed. No-DEBUG declaration probes reject all eight new experiment/graph
types; Release binary symbol checks exclude experimental and shared synthetic engine types.
No physical device used. No real/private input or network/provider activity.

Correctness comparisons retain full dated binding/snapshot, original indices, exact endpoints,
connection leg correspondence, scope/policy and candidate order, and check hand-derived path/
winner counts. Focused adversaries cover equal-prefix bounds, different arrival prefixes
converging on one suffix, recurring-Trip history, through segments, repeated visits/dates,
midnight absolute times, unknown/missing evidence despite direct service, selected all/mixed
rejection indices, empty completed scope, input/descriptor bounds, cancellation/cutoffs before
and after an incumbent and during selection/admission/finalization. Existing suites retain
eligibility/chronology/allowance and cancellation coverage; no independent new route engine.

**Measurement method:** same final Debug run, serialized experiment suite, one warmup plus
five sequential repetitions for each of twelve named fixtures. Other affected suites may
share host scheduling; these are observational instrumented Simulator durations, not isolated
CPU or physical-device latency. Input construction and build/launch/printing/assertions are
excluded; checkpoint/instrumentation overhead and all per-pass preparation/selection/admission
are included. Whole experiment includes bounds and mandatory oracle plus pruned passes.
The grid's direct ID is sorted last and visited first by DFS. This favorable order is explicit.
Inventory/connection permutation correctness is checked separately. The fixture source SHA-256
is `2ae02db96de03afb134ac0c3531601c3cb6a3d4ab553d5f6b07215f10b01371a`. No timing threshold determines success.

In the tables **E → P** means instrumented exhaustive pass → pruned pass. `paths` is the
complete original path count; discovery is charged steps, including extra bound checks in P.
`frontier` / `retained` are peak path counts; ride-key-slot peaks are separately noted below.
Outputs are canonical optimal candidates, not explored paths. Pair qualification is identical
in domain: 16/49/100 checks and 2/8/18 valid edges for q=1/2/3. Qualification charged steps
were E/P=81/80, 184/184, 328/328; the one-step q=1 difference is dictionary-fed insertion
ordering, not evidence skipped by pruning.

| q / paths | Variant | Discovery E → P | Popped E → P | Pruned prefixes | Peak frontier E → P | Peak retained E → P | Outputs |
|---|---|---|---|---|---|---|---|
| 1 / 2 | fast direct | 20 → 24 | 4 → 4 | 1 | 2 → 2 | 2 → 1 | 1 |
| 1 / 2 | fast transfer / ties | 20 → 24 | 4 → 4 | 0 | 2 → 2 | 2 → 2 | 1 |
| 1 / 2 | equal arrival | 20 → 24 | 4 → 4 | 1 | 2 → 2 | 2 → 1 | 1 |
| 1 / 2 | slow branches | 20 → 18 | 4 → 3 | 1 | 2 → 2 | 2 → 1 | 1 |
| 2 / 9 | fast direct | 71 → 86 | 15 → 15 | 8 | 4 → 4 | 9 → 1 | 1 |
| 2 / 9 | fast transfer / ties | 71 → 86 | 15 → 15 | 0 | 4 → 4 | 9 → 9 | 8 |
| 2 / 9 | equal arrival | 71 → 86 | 15 → 15 | 8 | 4 → 4 | 9 → 1 | 1 |
| 2 / 9 | slow branches | 71 → 42 | 15 → 7 | 4 | 4 → 3 | 9 → 1 | 1 |
| 3 / 28 | fast direct | 180 → 220 | 40 → 40 | 27 | 7 → 7 | 28 → 1 | 1 |
| 3 / 28 | fast transfer / ties | 180 → 220 | 40 → 40 | 0 | 7 → 7 | 28 → 28 | 27 |
| 3 / 28 | equal arrival | 180 → 220 | 40 → 40 | 27 | 7 → 7 | 28 → 1 | 1 |
| 3 / 28 | slow branches | 180 → 76 | 40 → 13 | 9 | 7 → 5 | 28 → 1 | 1 |

Retained ride-key slots E=4/25/82 for q=1/2/3; P=1 for direct/equal/slow variants and
4/25/82 for transfer-tie variants. Frontier key slots E=3/9/15; P unchanged except slow
branches=2/5/8. Counts exclude popped current path, descriptor/key/output containers, shared
backing storage and allocator overhead. Memory is not reliably isolated in this shared
Simulator test host; no RSS/peak RAM numbers or byte estimates are reported.

Median milliseconds (five observations), E/P. Pass ranges show min–max, not confidence
intervals. Whole is the median total mandatory two-pass experiment, not a speedup claim.

| q / variant | Qualification E/P | Discovery E/P | Selection E/P | Admission E/P | Whole pass E/P | Pass range E/P | Whole experiment |
|---|---|---|---|---|---|---|---|
| 1 / fast direct | 0.160 / 0.154 | 0.021 / 0.021 | 0.040 / 0.011 | 0.087 / 0.099 | 0.320 / 0.295 | 0.296–0.706 / 0.257–0.558 | 0.683 |
| 1 / fast transfer / ties | 0.151 / 0.154 | 0.020 / 0.022 | 0.036 / 0.037 | 0.127 / 0.112 | 0.343 / 0.333 | 0.310–0.809 / 0.324–0.491 | 0.713 |
| 1 / equal arrival | 0.149 / 0.152 | 0.020 / 0.021 | 0.038 / 0.011 | 0.070 / 0.070 | 0.283 / 0.259 | 0.280–0.290 / 0.252–0.308 | 0.592 |
| 1 / slow branches | 0.156 / 0.151 | 0.020 / 0.016 | 0.038 / 0.011 | 0.076 / 0.076 | 0.299 / 0.256 | 0.290–0.342 / 0.251–0.285 | 0.630 |
| 2 / fast direct | 0.396 / 0.402 | 0.086 / 0.078 | 0.218 / 0.011 | 0.080 / 0.076 | 0.902 / 0.578 | 0.876–1.596 / 0.570–0.611 | 1.570 |
| 2 / fast transfer / ties | 0.414 / 0.417 | 0.086 / 0.092 | 0.932 / 0.919 | 0.737 / 0.794 | 2.431 / 2.658 | 2.190–2.717 / 2.250–3.172 | 5.060 |
| 2 / equal arrival | 0.409 / 0.409 | 0.085 / 0.079 | 0.221 / 0.014 | 0.091 / 0.092 | 1.573 / 0.618 | 0.882–1.647 / 0.570–1.201 | 2.331 |
| 2 / slow branches | 0.405 / 0.400 | 0.086 / 0.037 | 0.219 / 0.013 | 0.082 / 0.131 | 0.909 / 0.718 | 0.880–0.944 / 0.537–1.180 | 1.739 |
| 3 / fast direct | 0.759 / 0.760 | 0.283 / 0.217 | 0.701 / 0.013 | 0.087 / 0.090 | 2.933 / 1.094 | 2.904–3.017 / 1.057–1.723 | 4.218 |
| 3 / fast transfer / ties | 0.816 / 0.811 | 0.299 / 0.306 | 8.405 / 8.276 | 2.602 / 2.663 | 12.929 / 13.123 | 12.630–19.071 / 12.819–15.943 | 25.957 |
| 3 / equal arrival | 0.779 / 0.800 | 0.300 / 0.222 | 0.742 / 0.013 | 0.094 / 0.117 | 4.070 / 1.151 | 3.006–6.124 / 1.103–1.172 | 5.388 |
| 3 / slow branches | 0.757 / 0.753 | 0.282 / 0.068 | 0.767 / 0.013 | 0.102 / 0.084 | 3.317 / 0.930 | 2.863–5.387 / 0.889–1.511 | 5.021 |

**Observed interpretation:** only slow-branch fixtures reduced charged discovery and popped
prefixes (q=3: 180→76 steps, 40→13 prefixes). Fast-direct and equal-arrival fixtures prune
at terminal prefixes: they reduce retained paths and selection work, but discovery steps
increase (180→220). Fast-transfer fixtures retain all 27 equal winners at q=3, with no
pruned prefix; kernel advances remain 406 and post work 1,519 in both passes. Direct/equal/
slow q=3 post work drops 636→15 and kernel advances 29→2. These advances are bounded
comparison/move operations, not exact comparison or CPU counts. Full pair qualification
remains; noisy timing alone cannot support general performance claims. Median experiment
cost includes the oracle and exceeds either pass alone. No Tokyo-scale extrapolation.

Recommendation: retain this as a bounded correctness/measurement experiment. The next
useful design question is removing whole-oracle prequalification safely while retaining
whole-domain coverage/limit truth; do not adopt this two-pass adapter as production routing.
Qualification and unavoidable tie enumeration/storage also need workload evidence before
an algorithm or production setting can be chosen. Larger graphs and reliable isolated
memory/cancellation-latency measurements need a separately bounded plan; no unresolved
production proof obligation is waived by these small cases.

Independent non-author review approved source/tests, pruning proof, finite bounds, measurement
methodology and final documentation with no material findings remaining. Review requested and
verified added 65-path oracle-domain and equal-bound/converging-history coverage, checked the
final results/Release isolation, and independently recomputed all twelve timing medians from
120 saved measurement records. No tests/builds were repeated by the reviewer. Scope, privacy,
documentation consistency and whitespace checks passed. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering gaps. No ODPT reply
supplied. No App/UI wiring, cache/history, real import, provider contact or production adoption.
Leave all six changed files unstaged/uncommitted for publication review.



#### Standalone pruning qualification proposal — 2026-10-04 Asia/Seoul

Published baseline `023c1c206e1ed0cdabc0df41869455b9a1713ca6`; clean phase branch and
cached upstream identical at inspection. Consumer §15.8 proposes one bounded DEBUG follow-up,
not implementation: qualify the full invented evidence/graph once, certify whole-domain
complete-path and prefix counts using `(last dated ride, used recurring TripIDs)` scalar
memoization, then reuse strict-bound pruning and canonical admission. Count multiplicity
preserves distinct histories; it is not a license to merge discovery identities or drop ties.

The exact 64-complete-path predicate still includes slower paths. Existing M<=4 and nested
input bounds prove four-ride/descriptor ceilings for this experiment only; a LIFO frontier
bound proves <=125 pending paths under the existing 128 cap. A separate 4,097-saturating
prefix count preserves the original 4,096 guard. At most 4,160 memo states are proposed from
T<=10,R<=32,M<=4, with combinatorial generalization risk. Whole-state traversal can still be
exhaustive; no cheaper qualification, measured benefit or standalone implementation is claimed.

Accounting clarification: the certificate/session strategy is a technical experiment choice,
not a new product preference requiring owner selection. The earlier recommendation to combine
all work into one 200,000-unit counter is withdrawn and remains unapproved. Consumer §15.8.6
lists every existing charged call site and defines separate proposed observational event
counters; equal counts do not imply equal computational cost. The hand-derived two-direct
example has 51 exhaustive calls versus 47 inherited pruned calls plus a distinct certificate
event vector; these are not a new common unit or budget. Published counters reset per pass.

Recommend first implementing only certificate correctness and observational comparison in a
test harness, after work authorization, without altering published search/cutoff behavior.
Only a change to externally observable completion/cutoff or failure precedence requires a
policy decision: for example standalone success when the mandatory oracle would exhaust its
allowance. No such change is approved. Exact parity requires retaining or proving/emulating
the old charged trace, including work on slower branches, sorting and admission. Scalar path
counts alone cannot provide it. R6 adoption remains unresolved.

Correctness plan independently calls the unchanged exhaustive oracle from tests, compares
full canonical winners/failures, and includes 64/65 slower-branch limits, dead ends, converging
histories, repeated destination visits, all ties and unknown evidence. Report total standalone
cost including certificate storage/work; structural counts are not process-memory savings.
No tests/builds/benchmarks, code, private input, provider contact or external research in this
documentation task. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and
fourteen ordering gaps. No ODPT reply supplied. Live/default routing remains unconfigured.
The count/multiplicity and state/frontier proofs retain their prior independent approval.
Separate non-author review approved the accounting clarification with no material findings,
including all existing step sites and hand-derived 51/47 counts. Scope/reference/privacy and
whitespace checks passed. No implementation evidence is claimed. Leave unstaged/uncommitted.


### §15.8 certificate harness — scoped technical validation

The owner authorized the DEBUG certificate and independent observational comparison; the
preceding accounting clarification remains the policy boundary. Implemented a certificate
without an oracle call or RouteSearching result, reusing unchanged whole-domain qualification.
Two small observation seams expose existing qualification and the existing exhaustive pass
for tests. Published exhaustive/two-pass behavior and charged controls remain unchanged.
Consumer §15.8.7 records counting proofs, safeguards and methodology. No standalone solver,
new common work unit, budget, failure precedence or production setting is approved.

Final iPhone 17 Simulator run: **86 functions / 154 cases passed**, including certificate
**12 / 28**. Debug dependencies and Release app/extension builds passed. Seven no-DEBUG
declaration probes and Release symbol checks exclude the certificate and new seams.
Earlier executions are superseded and not added. No private data or provider access occurred.

Separate certificate observations (q variants have identical structural counts):

| Fixture | C / P (saturated) | Roots | Lookups / hits | Expansions = destination tests = writes | Successor checks / eligible edges | Child / root scalar additions | Memo / pending-frame peaks | Oracle outcome |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| q1, all four variants | 2 / 4 | 2 | 4 / 0 | 4 | 12 / 2 | 4 / 4 | 4 / 3 | 2 paths |
| q2, all four variants | 9 / 15 | 3 | 15 / 0 | 15 | 49 / 12 | 24 / 6 | 15 / 3 | 9 paths |
| q3, all four variants | 28 / 40 | 4 | 40 / 0 | 40 | 130 / 36 | 72 / 8 | 40 / 3 | 28 paths |
| 64 equal optima | 64 / 84 | 4 | 52 / 24 | 28 | 144 / 48 | 96 / 8 | 28 / 3 | 64 winners |
| 65 paths | 65 / 85 | 5 | 53 / 24 | 29 | 169 / 48 | 96 / 10 | 29 / 3 | searchIncomplete |
| 86,780 dead prefixes | 0 / 4097 | 20 | 13340 / 10740 | 2600 | 18400 / 13320 | 26640 / 40 | 2600 / 4 | searchIncomplete |

Combined memo-plus-pending peaks equal the memo peaks above; all are <=4,160. Successor
checks include unsuccessful edges/reuse checks. Memo hits reuse scalars with incoming-path
multiplicity, not complete-path identities. Oracle frontier/retained-path peaks are 2/2,
4/9, 7/28 and 10/64 respectively for q1/q2/q3/ties64. Failure reports expose no complete
oracle storage metrics. The <=125 frontier bound is independently derived and checked;
fixtures do not claim to saturate it. Structural counts are not measured process memory.

Median milliseconds, one warmup + five measured pairs per row; v0 fast direct, v1 fast
transfer, v2 equal arrival/fewer changes, v3 slower transfer branch. Ties64 has all 64
identity-distinct equal optima. See §15.8.7 for included costs and noise limitations.

| Fixture | Certificate qualification | Certification | Whole certificate | Oracle qualification / discovery / selection / admission | Whole oracle | Whole paired harness median [min–max] |
| --- | --- | --- | --- | --- | --- | --- |
| q1v0 | 0.168 | 0.038 | 0.252 | 0.169 / 0.026 / 0.050 / 0.080 | 0.478 | 0.729 [0.580–1.331] |
| q1v1 | 0.146 | 0.031 | 0.226 | 0.147 / 0.022 / 0.039 / 0.105 | 0.366 | 0.587 [0.582–0.603] |
| q1v2 | 0.161 | 0.032 | 0.246 | 0.153 / 0.023 / 0.043 / 0.071 | 0.343 | 0.595 [0.566–1.220] |
| q1v3 | 0.148 | 0.030 | 0.229 | 0.147 / 0.022 / 0.038 / 0.066 | 0.343 | 0.572 [0.539–0.596] |
| q2v0 | 0.389 | 0.095 | 0.567 | 0.396 / 0.085 / 0.225 / 0.066 | 0.980 | 1.568 [1.492–1.572] |
| q2v1 | 0.399 | 0.097 | 0.590 | 0.393 / 0.086 / 0.927 / 0.669 | 2.291 | 2.877 [2.860–3.521] |
| q2v2 | 0.391 | 0.097 | 0.577 | 0.396 / 0.086 / 0.222 / 0.077 | 1.007 | 1.574 [1.554–2.736] |
| q2v3 | 0.400 | 0.100 | 0.592 | 0.396 / 0.087 / 0.228 / 0.096 | 1.012 | 1.625 [1.555–3.631] |
| q3v0 | 0.769 | 0.243 | 1.152 | 0.832 / 0.317 / 0.726 / 0.083 | 3.183 | 4.332 [4.238–5.437] |
| q3v1 | 0.793 | 0.245 | 1.197 | 0.752 / 0.284 / 9.029 / 2.367 | 14.076 | 15.251 [14.125–17.786] |
| q3v2 | 0.830 | 0.244 | 1.225 | 1.021 / 0.563 / 0.753 / 0.098 | 5.461 | 6.644 [4.294–10.422] |
| q3v3 | 0.776 | 0.267 | 1.205 | 0.803 / 0.310 / 1.006 / 0.101 | 3.738 | 4.891 [4.668–10.336] |
| ties64 | 1.779 | 0.422 | 2.409 | 1.653 / 1.291 / 78.287 / 9.132 | 109.088 | 112.290 [91.308–167.876] |
| paths65 | 2.482 | 0.529 | 3.952 | unavailable (throw) | 4.245 | 8.243 [6.521–9.606] |
| dead86780 | 4.178 | 33.761 | 37.713 | unavailable (throw) | 59.138 | 105.999 [86.331–131.753] |

Medians are taken independently and need not sum. Qualification step observations can differ
between identical inputs because dictionary encounter order affects existing sorting work;
no accounting change normalizes those observations. Certificate counters and inherited
charged calls are never summed. Whole certificate time is not standalone search time:
it produces no winners, reconstruction or admission. All-tie oracle selection/admission
remains costly. The dead-end certificate still explores 2,600 memo states and 18,400
successor checks despite zero output. No speedup or process-memory saving is established.

Recommendation: retain this harness as evidence for the domain-count proof; resolve the
old charged-trace parity or a narrowly specified cutoff-policy amendment before building a
standalone solver. R6 adoption remains unresolved. Live/default routing stays unconfigured.
P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification and 14 ordering gaps.
No ODPT reply supplied. Separate non-author review approved code, counting proofs, tests,
instrumentation and final evidence with no material findings remaining. Review corrections
added distinct-used-set coverage, cancellation inside certificate traversal, construction-free
timing scopes and precise complete-path-sorting wording. Documentation/scope/privacy/whitespace
checks passed. Changes remain unstaged/uncommitted.


### Legacy-cutoff authority assessment — historical documentation proposal

At `c7fde9f9a60012e8d32b7b81f2be30cbcce51534`, Consumer §15.8.8 traces numeric safeguards
to their implementations and distinguishes them from DEC-080/081/086 scope, evidence and
truthful-completion obligations. Exact same-budget legacy trace parity is not a universal
accepted requirement for every separately identified DEBUG solver. It is required when
promising identical legacy outcomes or modifying the published entry under that promise.
Earlier parity-or-amendment wording did not accept a new universal accounting policy.

Recommend one separate full-pipeline experiment: qualification once → whole-domain certificate
→ strict-bound discovery → reconstruction/selection → canonical admission. Preserve original
C<=64/P<=4,096, input/descriptor/ride safeguards, all equal identities and failure accounting.
Keep the published exhaustive/two-pass entries unchanged and invoke the oracle independently
in correctness tests. No additional certificate-only test slice or legacy emulation is needed
merely to decide this technical direction.

**E1 was Proposed at this assessment:** permit complete outcomes under separately declared experimental
safeguards despite an oracle cutoff at an identical numeric allowance; abort/cancellation never
returns partial success. Reuse one uninterrupted 200,000-ceiling engine counter at existing
call sites, separate proven certificate state/depth guards and all existing structural guards;
no new summed work unit or production budget. Mapping a certificate safeguard abort to
searchIncomplete applies only to the proposed new entry. Existing harness behavior stays intact.
Preserve stage/semantic failure precedence, not identical failure discovery at equal counters.
Scope/execution authorization is still required; no new behavior is approved by this assessment.

Measure total standalone qualification/certification/discovery/reconstruction/admission cost,
not counts as speed. Exact emulation would need order/sorting/admission/checkpoint trace proof
or substantial shadow execution; scalar C/P cannot establish it. See §15.8.8 for precise source
references, options, safeguard definitions and comparison tests. No code, tests, builds,
benchmarks, external research or private access in this task. Separate non-author documentation
review approved the authority assessment and Proposed E1 with no material findings; an exact
source-line reference was corrected. Scope, privacy, reference and whitespace checks passed.
P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification and 14 ordering gaps.
No ODPT reply supplied; live/default routing remains unconfigured.


### E1 standalone experiment — scoped implementation and observed results

The owner accepted E1 and its reviewed safeguards (§15.8.8), authorizing only this separately
named DEBUG experiment. Same-numeric-allowance outcome/callback parity is not promised.
Published exhaustive/two-pass behavior remains unchanged. One engine qualifies the whole
invented domain once, certifies original C/P limits, prunes strictly worse bounds, reconstructs
all equal optima and uses existing canonical admission. Certificate work stays separate from
one uninterrupted inherited counter; no production budget or adoption is accepted.

Final explicit iPhone 17/iOS 26.5 Simulator run: **96 functions / 181 cases passed**, including
standalone **10 / 27**. Debug dependencies and Release app/extension builds passed. Three
no-DEBUG declaration probes and Release symbol checks exclude new experimental types/seams.
Earlier compile/focused executions are superseded, not summed. Canonical comparison and
rejection accounting passed. E1's two-direct fixture succeeds standalone at 47 inherited calls,
while the independent oracle cuts off at 47 (requires 51); standalone at 46 fails. Qualification
runs once (26 calls). This divergence is recorded separately from correctness agreement.

One warmup and five sequential measured pairs for each frozen fixture, Debug -Onone/Xcode 27.0.
v0=fast direct; v1=fast transfer; v2=equal arrival/fewer changes; v3=slow transfer branch.
q1/q2/q3 have2/9/28 full-domain paths. ties64 retains all 64 optima. Full-call medians/ranges
below include each implementation's complete pipeline; standalone time excludes oracle execution.
Comparison/assertions/formatting are outside timing. See §15.8.9 for stage boundaries and noise.

| Fixture | Standalone ms median [min–max] | Oracle ms median [min–max] | Paired median ms | Output | Standalone median lower? |
| --- | --- | --- | --- | --- | --- |
| q1v0 | 0.409 [0.393–0.469] | 0.393 [0.362–0.533] | 0.804 | 1 | no |
| q1v1 | 0.503 [0.475–0.677] | 0.469 [0.429–0.517] | 0.974 | 1 | no |
| q1v2 | 0.452 [0.413–0.488] | 0.408 [0.378–0.903] | 0.861 | 1 | no |
| q1v3 | 0.430 [0.372–0.542] | 0.390 [0.367–0.775] | 0.812 | 1 | no |
| q2v0 | 0.903 [0.811–1.325] | 1.187 [1.012–1.964] | 2.150 | 1 | yes |
| q2v1 | 2.920 [2.635–3.524] | 2.827 [2.756–3.680] | 6.027 | 8 | no |
| q2v2 | 0.883 [0.802–0.906] | 1.348 [1.094–2.514] | 2.228 | 1 | yes |
| q2v3 | 0.769 [0.750–0.883] | 1.060 [1.036–1.144] | 1.850 | 1 | yes |
| q3v0 | 1.831 [1.552–2.566] | 3.575 [3.365–6.453] | 6.141 | 1 | yes |
| q3v1 | 16.161 [13.306–18.274] | 16.098 [13.206–18.853] | 33.031 | 27 | no |
| q3v2 | 1.635 [1.462–2.362] | 3.348 [3.177–3.518] | 5.101 | 1 | yes |
| q3v3 | 1.340 [1.331–1.453] | 3.158 [3.125–3.206] | 4.514 | 1 | yes |
| ties64 | 58.245 [55.716–63.162] | 56.810 [55.850–61.303] | 116.754 | 64 | no |

Stage medians in milliseconds, qualification / certification / discovery / selection / admission.
Oracle has no certificate stage (dash). Selection includes descriptor/key reconstruction;
admission includes original claims. Whole-call totals also include bounds, complete-path
normalization/sorting, scheduling and cleanup. Independently computed medians need not sum.

| Fixture | Standalone stages Q / C / D / S / A | Oracle stages Q / C / D / S / A |
| --- | --- | --- |
| q1v0 | 0.171 / 0.035 / 0.024 / 0.012 / 0.088 | 0.179 / — / 0.026 / 0.046 / 0.079 |
| q1v1 | 0.173 / 0.036 / 0.025 / 0.047 / 0.123 | 0.177 / — / 0.026 / 0.049 / 0.115 |
| q1v2 | 0.166 / 0.035 / 0.026 / 0.015 / 0.124 | 0.184 / — / 0.026 / 0.047 / 0.079 |
| q1v3 | 0.173 / 0.034 / 0.016 / 0.014 / 0.103 | 0.171 / — / 0.023 / 0.043 / 0.078 |
| q2v0 | 0.428 / 0.100 / 0.077 / 0.017 / 0.111 | 0.448 / — / 0.096 / 0.259 / 0.079 |
| q2v1 | 0.452 / 0.113 / 0.102 / 1.004 / 0.784 | 0.475 / — / 0.101 / 1.069 / 0.762 |
| q2v2 | 0.454 / 0.113 / 0.087 / 0.015 / 0.075 | 0.528 / — / 0.115 / 0.269 / 0.086 |
| q2v3 | 0.423 / 0.108 / 0.037 / 0.013 / 0.074 | 0.418 / — / 0.096 / 0.261 / 0.077 |
| q3v0 | 0.867 / 0.279 / 0.236 / 0.017 / 0.080 | 0.901 / — / 0.343 / 0.838 / 0.099 |
| q3v1 | 0.863 / 0.282 / 0.315 / 10.569 / 2.644 | 0.928 / — / 0.326 / 9.961 / 2.609 |
| q3v2 | 0.807 / 0.280 / 0.235 / 0.016 / 0.075 | 0.818 / — / 0.309 / 0.762 / 0.084 |
| q3v3 | 0.754 / 0.252 / 0.068 / 0.017 / 0.077 | 0.766 / — / 0.299 / 0.736 / 0.082 |
| ties64 | 1.131 / 0.258 / 0.870 / 43.071 / 5.691 | 1.161 / — / 0.862 / 42.169 / 6.012 |

Separate structural/discovery observations (S=standalone, O=oracle; counts are not CPU or bytes):

| Fixture | Certificate states / hits / successor tests | Discovery prefixes S / O | Pruned prefixes S | Retained complete paths S / O | Frontier path peaks S / O | Complete-path key peaks S / O | Kernel advances S / O |
| --- | --- | --- | --- | --- | --- | --- | --- |
| q1v0 | 4 / 0 / 12 | 4 / 4 | 1 | 1 / 2 | 2 / 2 | 1 / 4 | 2 / 3 |
| q1v1 | 4 / 0 / 12 | 4 / 4 | 0 | 2 / 2 | 2 / 2 | 4 / 4 | 3 / 3 |
| q1v2 | 4 / 0 / 12 | 4 / 4 | 1 | 1 / 2 | 2 / 2 | 1 / 4 | 2 / 3 |
| q1v3 | 4 / 0 / 12 | 3 / 4 | 1 | 1 / 2 | 2 / 2 | 1 / 4 | 2 / 3 |
| q2v0 | 15 / 0 / 49 | 15 / 15 | 8 | 1 / 9 | 4 / 4 | 1 / 25 | 2 / 10 |
| q2v1 | 15 / 0 / 49 | 15 / 15 | 0 | 9 / 9 | 4 / 4 | 25 / 25 | 45 / 45 |
| q2v2 | 15 / 0 / 49 | 15 / 15 | 8 | 1 / 9 | 4 / 4 | 1 / 25 | 2 / 10 |
| q2v3 | 15 / 0 / 49 | 7 / 15 | 4 | 1 / 9 | 3 / 4 | 1 / 25 | 2 / 10 |
| q3v0 | 40 / 0 / 130 | 40 / 40 | 27 | 1 / 28 | 7 / 7 | 1 / 82 | 2 / 29 |
| q3v1 | 40 / 0 / 130 | 40 / 40 | 0 | 28 / 28 | 7 / 7 | 82 / 82 | 406 / 406 |
| q3v2 | 40 / 0 / 130 | 40 / 40 | 27 | 1 / 28 | 7 / 7 | 1 / 82 | 2 / 29 |
| q3v3 | 40 / 0 / 130 | 13 / 40 | 9 | 1 / 28 | 5 / 7 | 1 / 82 | 2 / 29 |
| ties64 | 28 / 24 / 144 | 84 / 84 | 0 | 64 / 64 | 10 / 10 | 192 / 192 | 2144 / 2144 |

Inherited engine charges remain their original unit, separated by stage; ranges below
show variation across five calls. They are not added to certificate observations.

| Fixture | Standalone qualification / discovery / post charges | Oracle qualification / discovery / post charges |
| --- | --- | --- |
| q1v0 | 80 / 24 / 15 | 80 / 20 / 25 |
| q1v1 | 80 / 24 / 37 | 80 / 20 / 37 |
| q1v2 | 80 / 24 / 15 | 80 / 20 / 25 |
| q1v3 | 80 / 18 / 15 | 80 / 20 / 25 |
| q2v0 | 180–183 / 86 / 15 | 183 / 71 / 123 |
| q2v1 | 178–183 / 86 / 303 | 180–183 / 71 / 303 |
| q2v2 | 178–184 / 86 / 15 | 181–184 / 71 / 123 |
| q2v3 | 180–181 / 42 / 15 | 180–181 / 71 / 123 |
| q3v0 | 327 / 220 / 15 | 327–328 / 180 / 636 |
| q3v1 | 321–327 / 220 / 1519 | 321–327 / 180 / 1519 |
| q3v2 | 310 / 220 / 15 | 310 / 180 / 636 |
| q3v3 | 310 / 76 / 15 | 310 / 180 / 636 |
| ties64 | 403 / 420 / 5890 | 403 / 336 / 5890 |

For q1/q2/q3/ties64 respectively, graph rides/edges are4/2,7/8,10/18,12/32; memo peaks
are4,15,40,28 and pending-depth peaks3. Certificate root/lookup counts are2/4,3/15,4/40,4/52;
state expansions equal destination tests/memo writes; eligible transitions2,12,36,48 imply
child scalar additions4,24,72,96, while root additions4,6,8,8 remain separate. These match
the certificate-only structural definitions; none is a new charged work unit. Memo storage
is released before discovery, so do not add memo and frontier peaks as simultaneous memory.
The failure fixtures retain the prior C=65 rejection and C=0/P=4,097 saturated rejection for
86,780 original dead-end prefixes; they are correctness cases, not successful timing rows.

Only slow-branch v3 reduces popped discovery prefixes. v0/v2 on larger grids gain primarily
by avoiding complete-path normalization/selection work for objective exclusions. All q1 medians
were higher, and transfer-winning/ties64 cases retain candidate/key/output costs and add
certification. ties64 standalone 58.245 ms versus oracle 56.810 ms does not support a general
speedup. Five shared-Simulator samples, fixed standalone-first order, differing dictionary
sorting charges and runtime noise limit causal/statistical conclusions. No reliable process
memory was measured and no production-scale extrapolation is made.

Recommendation: retain this as a correctness/reference experiment; do not adopt it as the
production solver from these results. All-tie key ordering/selection is the measured expensive
stage worth investigating in a separately scoped synthetic follow-up, preserving every identity.
Production ownership, algorithm choice and resource settings remain unresolved. No private
inputs, provider contact, live routing configuration or Application/presentation changes occurred.
Separate non-author review approved code, counting/pruning reasoning, safeguards, tests,
instrumentation and final documentation with no material findings remaining. Review suggestions
added reversed-input tie coverage and stronger scoped-empty comparisons. Final scope, privacy,
reference and whitespace checks passed. P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification
and 14 ordering gaps. No ODPT reply supplied. Leave changes unstaged/uncommitted.


### Equal-optimum profiling — no algorithm change

Consumer §15.8.10 records the owner-authorized optional DEBUG instrumentation. Both adapters
use the same existing algorithm, safeguards, charges and canonical admission. Profile mode
never feeds a failure/selection decision. No optimization was implemented. Separate non-author final review approved instrumentation,
methodology, numerical tables and conclusions with no material findings. Exact timing boundaries/
caveats and the next unimplemented experiment are there.

Final focused/affected validation: **42 functions / 83 cases**, including profiling **4 / 8**.
Debug dependencies built; previous E1 Release app/extension build evidence reused. Three new
no-DEBUG declaration probes plus optimized no-DEBUG object-symbol inspection passed. Selector,
handoff, standalone/pruning and instrumentation correctness passed; earlier focused counts are
not added. No broad test suite/build, private access or provider contact occurred.

One warmup per variant/mode, eight four-slot rotations per frozen fixture, each slot in each
run position twice. Xcode 27.0 Debug -Onone, iPhone 17 Simulator/iOS 26.5 arm64; shared-host noise
possible. S=standalone, O=exhaustive oracle. Medians [min–max] in ms; whole includes all pipeline
costs and excludes comparison/formatting. Admission remains separately timed.

| Fixture / variant | Whole off | Whole on | Selection off | Selection on | Admission on |
| --- | --- | --- | --- | --- | --- |
| tie1 / S | 0.400 [0.384–0.458] | 0.392 [0.362–1.603] | 0.037 [0.033–0.044] | 0.041 [0.037–0.043] | 0.116 [0.105–1.340] |
| tie1 / O | 0.350 [0.330–1.717] | 0.408 [0.320–1.463] | 0.035 [0.033–0.038] | 0.041 [0.033–0.090] | 0.125 [0.113–0.988] |
| direct8 / S | 1.654 [1.475–4.630] | 1.748 [1.513–4.213] | 0.432 [0.396–0.883] | 0.431 [0.423–0.761] | 0.580 [0.350–2.646] |
| direct8 / O | 1.687 [1.426–2.025] | 1.828 [1.466–2.550] | 0.421 [0.394–0.640] | 0.431 [0.421–0.933] | 0.430 [0.359–0.738] |
| tie8 / S | 3.104 [2.530–4.022] | 3.321 [2.481–4.747] | 1.159 [1.013–1.681] | 1.237 [1.003–1.761] | 0.926 [0.725–2.926] |
| tie8 / O | 2.730 [2.486–4.294] | 2.508 [2.244–6.960] | 1.158 [1.019–2.023] | 1.027 [0.963–2.091] | 0.772 [0.672–3.858] |
| tie27 / S | 13.188 [12.830–18.616] | 13.219 [12.972–21.274] | 8.253 [8.084–12.799] | 8.374 [8.238–10.052] | 2.298 [2.236–9.973] |
| tie27 / O | 13.126 [12.847–13.893] | 13.022 [12.677–13.384] | 8.280 [8.163–8.911] | 8.403 [8.272–8.625] | 2.356 [2.227–2.474] |
| tie64 / S | 55.874 [51.453–66.724] | 54.332 [51.627–63.347] | 41.788 [38.025–52.362] | 40.487 [38.594–47.107] | 5.750 [5.061–6.610] |
| tie64 / O | 54.261 [51.750–130.086] | 54.593 [52.604–74.023] | 40.141 [38.680–109.000] | 40.375 [39.199–48.537] | 5.594 [5.214–6.477] |

Profile-on 64-tie breakdown, ms medians. Kernel components are **inside** kernel elapsed;
path extension/dedup/order are outside the historical selection stage. Do not add nested
values or separately computed medians as if they formed a CPU/allocation partition.

| Operation | Standalone | Oracle |
| --- | --- | --- |
| Prepared claims | 0.1406 | 0.1458 |
| Descriptor bounds checks | 0.5056 | 0.5210 |
| Descriptor/key construction | 0.7049 | 0.7279 |
| Selection checkpoints | 0.3508 | 0.4352 |
| Kernel total | 37.9806 | 37.7814 |
| ↳ Objective/tie updates | 0.0076 | 0.0079 |
| ↳ Key equality | 2.7618 | 2.6938 |
| ↳ Lexicographic ordering | 34.5960 | 34.4806 |
| ↳ Winner insertions | 0.0320 | 0.0367 |
| Path extensions | 0.0363 | 0.0400 |
| Complete-path Set dedup | 0.0971 | 0.0956 |
| Complete-path ordering with checkpoints | 5.5273 | 5.9430 |

Structural counts agree between S/O with profiling enabled; no byte or equal-cost inference:

| Fixture | Winners / rides per winner | Key atoms | Objective calls | Equality / order checks | Atom comparator calls | Kernel advances | Claims elements | Path extensions / elements | Winner shifts |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tie1 | 1 / 3 | 37 | 0 | 0 / 0 | 0 | 2 | 3 | 2 / 5 | 0 |
| direct8 | 8 / 1 | 40 | 14 | 28 / 28 | 112 | 44 | 8 | 0 / 0 | 0 |
| tie8 | 8 / 3 | 296 | 14 | 28 / 28 | 456 | 44 | 24 | 12 / 32 | 0 |
| tie27 | 27 / 3 | 999 | 52 | 351 / 351 | 4212 | 405 | 81 | 36 / 99 | 0 |
| tie64 | 64 / 3 | 2368 | 126 | 2016 / 2016 | 21120 | 2144 | 192 | 80 / 224 | 0 |

Claims arrays/descriptors/Set insertions each equal winner count; bounds checks equal claim
slots for these fixtures. Zero winner shifts means insertion-at-end, not zero allocation.
Identity keys are not hashed by the selection kernel. Earlier path Set work includes hashing/
equality, but standard-library internals and exact bytes/allocations were not measured.

Enabled-overhead observations: paired per-repetition on−off whole-call differences, ms median
[min–max]. Negative values reflect run variation, not negative instrumentation cost.

| Fixture | Standalone paired delta | Oracle paired delta |
| --- | --- | --- |
| tie1 | -0.017 [-0.038–+1.203] | -0.001 [-1.251–+1.133] |
| direct8 | +0.075 [-2.286–+1.426] | +0.260 [-0.525–+0.525] |
| tie8 | +0.328 [-1.324–+1.663] | -0.185 [-1.687–+4.132] |
| tie27 | +0.319 [-5.482–+3.372] | -0.127 [-1.006–+0.352] |
| tie64 | +0.233 [-6.077–+2.125] | +0.149 [-69.912–+22.273] |

These deltas do not isolate pure instrumentation overhead; off shares added wrappers/branches/
state, on perturbs comparator execution, and other suites share the host. Instrumentation has
real clock/counter costs even where medians decrease. No reliable allocation/RSS measurement
was collected, so no process-memory saving or allocator-specific bottleneck is claimed.

The 64-tie ordering operation accounts for about 34.5ms of about 40.4ms profiled selection in
both variants. Descriptor construction is about 0.7ms, objective/tie updates about 0.008ms,
and checkpoint wall time about 0.35–0.44ms. This identifies repeated identity ordering as the
primary measured target in this fixture; it does not implicate pure hashing, allocation or
UUID conversion as a separately measured cause. Eight three-ride keys also cost more than
eight direct keys with the same 28 pair checks but 456 versus 112 comparator calls; graph/key/
common-prefix differences prevent attributing that solely to path length.

Recommend a separately authorized isolated append-fast-path experiment for already ordered
strictly greater equal-optimum keys, falling back to unchanged duplicate/order scanning otherwise.
Its proof and permutation/duplicate/cutoff obligations are in §15.8.10. No optimization, raised
limit, product decision, production adoption or live/default routing configuration is established.
P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification and 14 ordering gaps. No ODPT
reply supplied. Changes remain unstaged/uncommitted.


### Append-fast-path experiment — opt-in DEBUG only

Consumer §15.8.11 records the scoped owner-authorized experiment. The published selector kernel
and exhaustive engine remain byte-identical references. Standalone defaults to `.reference`;
`.appendFastPath` is explicit opt-in. Qualification/certification/pruning and canonical admission
are retained. No new budget, raised limit, live routing, provider access or product adoption.

Final explicit iPhone 17 Simulator run: **49 functions / 96 cases passed**, including append
experiment **7 / 13**. Selector, handoff, standalone, profiling and pruning suites passed in that
same run; do not add subsets or the superseded first focused execution. Debug app/extension
dependencies built. Prior E1 Release app/extension build evidence is reused (published baseline
fingerprints verified), not newly run: all changed/new Swift is DEBUG-guarded, no project/build
configuration changed. Two new no-DEBUG declaration probes and optimized no-DEBUG object-symbol
exclusion passed. Initial probe hit sandbox module-cache permissions; rerun with a writable
explicit temporary module cache verified the intended absence, not that permission failure.
Separate non-author independent review approved the final implementation, safeguards, tests,
measurement methodology, numerical tables and conclusions with no material findings.

Tests compare original winner ordinals, all ordered canonical payloads, snapshots/dates/indices,
scopes and contexts against unchanged references. Empty/singleton, 64 ties, permutations,
duplicates, long shared-prefix identifiers, mixed objectives, repeated visits/dates and evidenced
through service pass. Sorted uniqueness is checked after every experimental kernel advance.
Mixed/all selected rejection retains searchIncomplete / noUsableAlternatives with original
selected-index reasons. Existing whole-domain overflow/unknown evidence and certificate abort
remain failures; no incumbent result. The local charged kernel driver aborts at the fifth step
after a failed fast check, before fallback equality, for cutoff and cancellation.

**E1 example:** stable two-direct-tie fixture completes at 75 inherited charges with append;
reference requires 76 and fails at 75; append fails at 74. All stages share one uninterrupted
allowance. This intentional numeric-cutoff difference is not equal-cost accounting. Large-fixture
qualification charges may vary with dictionary encounter order; exact-budget assertions use the
stable two-key fixture. No change to published default/reference failure semantics is claimed.

Method: one warmup per variant/profiling mode, then eight balanced four-slot rotations, each
slot occupies each position twice. Same frozen inputs for both; Debug -Onone, Xcode 27.0,
iPhone 17/iOS 26.5 Simulator arm64, macOS 26.6.2. Other affected suites share the test host. No timing
threshold. Below are medians [min–max] in milliseconds from the final run only. Profile-on and
-off are distinct observations; negative on−off differences reflect noise, not free instrumentation.

**Whole standalone pipeline and containing selection/reconstruction stage.** These use normal
prepared-path ordering, not artificially reversed evidence. Timers include all standalone costs;
oracle comparison/fixture construction/assertions/printing excluded. Canonical admission is
separate: for 64/profile-off its median is 5.014ms reference and 4.867ms append; profile-on 5.035/4.919ms.
Do not sum separately computed medians or nested stage timers.

| Ties / profiling | Reference whole | Append whole | Reference selection | Append selection |
| --- | --- | --- | --- | --- |
| 1 / off | 0.324 [0.299–0.334] | 0.321 [0.304–0.328] | 0.032 [0.029–0.035] | 0.033 [0.030–0.036] |
| 1 / on | 0.311 [0.297–0.331] | 0.316 [0.309–0.374] | 0.033 [0.030–0.036] | 0.033 [0.031–0.073] |
| 8 / off | 2.166 [2.112–2.262] | 1.772 [1.747–1.879] | 0.892 [0.868–0.900] | 0.523 [0.511–0.533] |
| 8 / on | 2.164 [2.136–2.282] | 1.785 [1.749–1.888] | 0.908 [0.894–0.919] | 0.539 [0.529–0.552] |
| 27 / off | 11.643 [11.496–12.024] | 6.167 [6.057–6.332] | 7.410 [7.319–7.539] | 1.970 [1.932–2.051] |
| 27 / on | 11.748 [11.625–11.943] | 6.324 [6.103–6.460] | 7.548 [7.486–7.594] | 2.019 [1.984–2.070] |
| 64 / off | 51.057 [50.229–53.839] | 18.064 [17.726–18.710] | 37.928 [37.296–40.521] | 5.210 [5.101–5.388] |
| 64 / on | 51.723 [50.761–54.022] | 18.437 [17.857–23.433] | 38.701 [37.575–39.658] | 5.421 [5.186–5.532] |

**Kernel-only descriptor-order experiment.** Same canonical-derived three-ride descriptors, with
ascending, reversed and odd-index-then-even-index orders. No pipeline reorder seam exists;
these exclude descriptor construction, preparation and admission. They isolate unfavorable
fallback behavior and cannot themselves establish whole-search benefit.

| Ties / order | Reference off | Append off | Reference on | Append on |
| --- | --- | --- | --- | --- |
| 1 / ascending | 0.001 [0.001–0.002] | 0.001 [0.001–0.002] | 0.001 [0.001–0.003] | 0.001 [0.001–0.002] |
| 1 / descending | 0.001 [0.001–0.001] | 0.001 [0.001–0.001] | 0.001 [0.001–0.003] | 0.001 [0.001–0.002] |
| 1 / mixed | 0.001 [0.001–0.001] | 0.001 [0.001–0.001] | 0.001 [0.001–0.001] | 0.001 [0.001–0.002] |
| 8 / ascending | 0.682 [0.671–0.686] | 0.315 [0.307–0.324] | 0.690 [0.685–0.693] | 0.317 [0.313–0.323] |
| 8 / descending | 0.339 [0.338–0.344] | 0.500 [0.496–0.526] | 0.342 [0.332–0.351] | 0.502 [0.498–0.512] |
| 8 / mixed | 0.561 [0.553–0.579] | 0.643 [0.623–0.653] | 0.578 [0.560–0.586] | 0.642 [0.630–0.666] |
| 27 / ascending | 6.947 [6.761–7.060] | 1.316 [1.278–1.619] | 7.056 [6.795–7.586] | 1.348 [1.307–1.633] |
| 27 / descending | 1.399 [1.366–1.450] | 1.858 [1.824–1.969] | 1.415 [1.356–1.487] | 1.891 [1.881–1.966] |
| 27 / mixed | 5.652 [5.510–5.735] | 4.462 [4.415–4.610] | 5.689 [5.620–5.854] | 4.510 [4.398–4.601] |
| 64 / ascending | 35.314 [34.959–36.779] | 3.583 [3.573–3.672] | 35.667 [35.368–37.420] | 3.630 [3.589–4.707] |
| 64 / descending | 3.898 [3.829–3.932] | 4.981 [4.863–5.266] | 3.891 [3.825–4.193] | 4.980 [4.877–5.189] |
| 64 / mixed | 26.947 [26.745–27.855] | 20.789 [20.578–21.658] | 27.323 [27.145–28.168] | 21.061 [20.832–21.490] |

**Separate structural observations (profile on).** Each advance has one pre-advance checkpoint
in the pipeline. Fast checks are additional comparisons, not hidden in fallback-order counts.
Objective comparisons remain 126 for 64 ties in both kernels; they are not mixed into ordering
counts. No heterogeneous common work unit is formed.

| 64-tie order / variant | Equality | Fallback order | Fallback atom calls | Fast checks | Fast atom calls | Fast appends | Advances | Shifted winner slots |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ascending / reference | 2016 | 2016 | 21120 | 0 | 0 | 0 | 2144 | 0 |
| ascending / append | 0 | 0 | 0 | 63 | 2889 | 63 | 128 | 0 |
| descending / reference | 63 | 63 | 2889 | 0 | 0 | 0 | 128 | 2016 |
| descending / append | 63 | 63 | 2889 | 63 | 660 | 0 | 191 | 2016 |
| mixed / reference | 1520 | 1520 | 16256 | 0 | 0 | 0 | 1616 | 528 |
| mixed / append | 1024 | 1024 | 11424 | 63 | 1487 | 31 | 1152 | 528 |

| Ascending ties | Reference advances | Append advances | Reference fallback order | Append fast checks | Reference / append fallback atom calls | Append fast atom calls |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 2 | 2 | 0 | 0 | 0 / 0 | 0 |
| 8 | 44 | 16 | 28 | 7 | 456 / 0 | 257 |
| 27 | 405 | 54 | 351 | 26 | 4212 / 0 | 1086 |
| 64 | 2144 | 128 | 2016 | 63 | 21120 / 0 | 2889 |

For 64 ties, pipeline post charges are 5890 reference /3874 append (difference 2016, exactly the
removed advances). Qualification and discovery remain separate inherited counters; discovery 420,
qualification observed range reported below. Certificate observations remain separate. Both retain
64 output winners, peak 10 frontier paths, 192 retained complete-path keys, 80 logical path extensions/
224 element slots. Descriptor/tie/winner arrays retain existing <=64 limits. Shift counts and these
structural values do not measure allocator bytes, ARC costs or process-memory savings.

- Reference observed qualification charges across profiling on/off: 411–412.
- Append observed qualification charges across profiling on/off: 411–412.

**Interpretation and next step:** profile-off normalized 64 whole median fell 51.057→18.064ms;
selection fell 37.928→5.210ms. Ascending 8/27 also improved; singleton differences are tiny/noisy.
Kernel 64 descending regressed 3.898→4.981ms because all 63 fast checks fail and original work remains.
Mixed 8 also regressed 0.561→0.643ms; mixed 27/64 improved. A fast path is therefore not universally
faster. It helps this normalization/order pattern while adding bounded work on unfavorable input.
On 64 ascending it replaces 2016 fallback ordering checks with 63 strict-last checks, which have 2889
atom calls rather than 21120 fallback calls. Equal event counts would still not imply equal cost.

Recommend retaining this as an opt-in experiment, with the reference/default unchanged. The
next useful evaluation is an optimized build of this same bounded DEBUG experiment (explicit
DEBUG enabled in an isolated test configuration, never Release routing adoption) before considering any adoption; Debug generic/comparator overhead can differ
from optimized code. That follow-up needs separate authorization and must retain all-tie identity,
ordered-payload, fallback and E1 abort checks. No additional optimization, raised limits or default
replacement is justified by this run. No general scale/production feasibility, measured memory
saving or guaranteed speedup is established. Instrumentation has real clock/counter/closure costs;
paired rotations reduce order bias but do not isolate them exactly in a shared host.

P3-T1/Phase 3 remain incomplete. P2-S9 retains 14 classification and 14 ordering gaps. No ODPT reply
supplied. Changes remain unstaged/uncommitted for publication review.



### Compiler-optimized append evaluation — unchanged code, opt-in retained

Consumer §15.8.12 records this bounded measurement authorization, exact invocation and isolation.
Only the published append suite ran: **7 functions / 13 cases passed**, no failures/skips/runtime
warnings. Do not add historical 49 / 96 or included subsets. Actual Swift compiler commands for
app/routing module, tests and extension use **-O, -DDEBUG, -enable-testing, -g**, batch mode without
whole-module optimization. The only override is invocation-level `SWIFT_OPTIMIZATION_LEVEL=-O`
in a separate temporary DerivedData directory. No source, test, project, scheme, signing,
deployment, default selector, limits or E1 behavior changed. Debug-with-O dependencies built;
standard Release was not rebuilt. Existing Release build and no-DEBUG exclusion evidence is
reused with matching fingerprints/provenance; ordinary Release settings still omit DEBUG.
Separate non-author independent review approved configuration isolation, correctness evidence,
measurement tables and conclusions with no material findings.

One warmup per variant/profile mode; eight balanced four-slot rotations, each position twice.
Xcode 27.0, iPhone 17/iOS 26.5 Simulator arm64, macOS 26.6.2. Same frozen input per comparison;
canonical ordered outputs/identities checked outside timing. Only append tests selected, serialized;
host conditions not controlled. Whole pipeline includes all standalone stages, excludes fixture
construction/oracle comparison/assertions/printing. Tables report **milliseconds, median [min–max]**.
Timing is observational. Primary profile-disabled timings are not merged with enabled observations.

**Profile-disabled whole pipeline and selection/reconstruction:**

| Ties | Reference whole | Append whole | Reference selection | Append selection |
| --- | --- | --- | --- | --- |
| 1 | 0.1365 [0.1132–0.1461] | 0.1284 [0.1153–0.1547] | 0.0094 [0.0091–0.0116] | 0.0098 [0.0090–0.0115] |
| 8 | 0.6187 [0.5337–0.6671] | 0.6047 [0.5306–0.6481] | 0.0761 [0.0736–0.0859] | 0.0693 [0.0655–0.0776] |
| 27 | 1.9814 [1.8546–2.1852] | 1.7913 [1.7058–1.9558] | 0.3375 [0.3329–0.3515] | 0.2260 [0.2194–0.2398] |
| 64 | 5.2786 [5.2205–5.8537] | 4.5922 [4.4478–4.6660] | 1.1906 [1.1746–1.2293] | 0.5339 [0.5161–0.5617] |

Canonical admission is separate and unchanged. For 64/profile-disabled it was 1.9820ms reference
and 1.9809ms append at the median; selection medians were 1.1906/0.5339ms. Nested stage times or
separately computed medians must not be summed to fabricate a CPU/allocation partition.

**Profile-disabled kernel permutations:** normal whole pipelines still normalize prepared paths;
these separately permute canonical-derived descriptors and exclude other pipeline costs.

| Ties / order | Reference kernel | Append kernel |
| --- | --- | --- |
| 1 / ascending | 0.0003 [0.0002–0.0005] | 0.0003 [0.0002–0.0009] |
| 1 / descending | 0.0003 [0.0002–0.0004] | 0.0003 [0.0002–0.0007] |
| 1 / mixed | 0.0003 [0.0002–0.0005] | 0.0002 [0.0002–0.0004] |
| 8 / ascending | 0.0102 [0.0098–0.0108] | 0.0055 [0.0054–0.0070] |
| 8 / descending | 0.0056 [0.0053–0.0059] | 0.0091 [0.0087–0.0098] |
| 8 / mixed | 0.0085 [0.0085–0.0095] | 0.0116 [0.0112–0.0128] |
| 27 / ascending | 0.0895 [0.0893–0.0905] | 0.0204 [0.0203–0.0210] |
| 27 / descending | 0.0202 [0.0200–0.0257] | 0.0321 [0.0318–0.0327] |
| 27 / mixed | 0.0743 [0.0740–0.0746] | 0.0735 [0.0732–0.0736] |
| 64 / ascending | 0.4641 [0.4633–0.4653] | 0.0537 [0.0531–0.0547] |
| 64 / descending | 0.0556 [0.0553–0.0560] | 0.0833 [0.0829–0.1008] |
| 64 / mixed | 0.3592 [0.3580–0.3608] | 0.3406 [0.3396–0.3414] |

**Separate profiling-enabled observations:** these are not primary timing estimates. Enabled
counters/timers materially perturb optimized comparison work; profile-off retains existing
stage clocks and cutoff accounting. No precise overhead correction is inferred.

| Ties | Reference whole on | Append whole on | Reference selection on | Append selection on |
| --- | --- | --- | --- | --- |
| 1 | 0.1263 [0.1180–0.1533] | 0.1247 [0.1180–0.1518] | 0.0108 [0.0099–0.0118] | 0.0109 [0.0102–0.0118] |
| 8 | 0.6406 [0.5599–0.6760] | 0.6131 [0.5875–0.6593] | 0.0922 [0.0890–0.1094] | 0.0762 [0.0746–0.0800] |
| 27 | 2.0378 [1.9028–2.2480] | 1.8285 [1.7797–1.9405] | 0.4478 [0.4391–0.4583] | 0.2515 [0.2479–0.2536] |
| 64 | 5.8484 [5.7113–5.9637] | 4.7306 [4.5735–6.8610] | 1.7395 [1.7045–1.7646] | 0.6006 [0.5803–0.6242] |

| 64-tie order / variant | Equality | Fallback order | Fallback atom calls | Added fast checks | Fast atom calls | Advances | Shifted slots |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ascending / reference | 2016 | 2016 | 21120 | 0 | 0 | 2144 | 0 |
| ascending / append | 0 | 0 | 0 | 63 | 2889 | 128 | 0 |
| descending / reference | 63 | 63 | 2889 | 0 | 0 | 128 | 2016 |
| descending / append | 63 | 63 | 2889 | 63 | 660 | 191 | 2016 |
| mixed / reference | 1520 | 1520 | 16256 | 0 | 0 | 1616 | 528 |
| mixed / append | 1024 | 1024 | 11424 | 63 | 1487 | 1152 | 528 |

These structural kernel counts match the published unoptimized fixture counts. All 64 winners
remain present. Both pipeline variants retain peak 10 frontier paths, 192 complete-path key slots,
80 logical extensions/224 elements. No allocator bytes/RSS were measured or inferred. For 64 ties,
post charges remain 5890 reference / 3874 append; discovery 420; qualification observed 398 in both
variants in this run (dictionary encounter order is run-dependent, not a universal fixed cost).
Certificate observations are still separate. No heterogeneous counter sum is used as a cost unit.

**What persists and what remains inconclusive:**

| Case | Optimized observations | Assessment relative to published Debug direction |
| --- | --- | --- |
| Normalized 64 whole pipeline | Append lower in 8/8 paired observations; median 5.2786→4.5922ms, nonoverlapping ranges | Favorable direction persists in this fixture; no general speedup claim |
| Normalized 27 whole pipeline | Append lower in 8/8 pairs; median 1.9814→1.7913ms, overall ranges overlap | Favorable in this sample, smaller relative benefit than historical -Onone |
| Normalized 8 whole pipeline | Append lower in 7/8 pairs; median 0.6187→0.6047ms, broad overlap | Whole-call benefit inconclusive despite a lower selection median |
| Singleton pipeline/kernel | Four of eight whole-call pairs favor each variant; tiny kernel differences | Inconclusive |
| Descending 8/27/64 kernels | Append slower in every pair at each size; 64 median 0.0556→0.0833ms | Previously unfavorable direction persists |
| Mixed 8 kernel | Append slower in 8/8 pairs; 0.0085→0.0116ms | Published mixed-eight regression persists |
| Mixed 27 kernel | Append lower in 8/8 pairs, but paired median saving only 0.0008755ms | Tiny directional result; practical significance inconclusive here |
| Mixed 64 kernel | Append lower in 8/8 pairs; 0.3592→0.3406ms | Modest favorable direction in this kernel sample, not a reversed-pipeline claim |

The 64 selection advantage persists, but absolute times and its share of whole cost are far smaller
than the earlier -Onone run. Those runs differ in host load/test selection and generated run
identities; they do not isolate a causal compiler-only multiplier. Within this run both variants
share identical packets and all output checks pass. Eight repetitions, Simulator hardware and
retained Debug/testability settings cannot establish production feasibility or physical-iPhone
performance. Fine-grained sub-microsecond observations warrant restraint even with consistent signs.

**Recommendation:** keep append opt-in with reference as default; no further kernel optimization
or adoption is justified by these measurements alone. Favorable normalized ties coexist with
reversed/mixed regressions, and the whole-call advantage is inconclusive at 8 ties. Any later adoption
assessment needs representative workload/coverage and production resource-policy evidence rather
than inferring it from these small invented fixtures. No additional benchmark, data access or
policy change is authorized by this record. Compiler-optimized evaluation is now completed only
for this bounded Debug experiment; a production optimized solver is not established.

P3-T1/Phase 3 remain incomplete. P2-S9 retains 14 classification and 14 ordering gaps. Live/default
routing remains unconfigured; no ODPT reply supplied. Changes remain unstaged/uncommitted.


#### Supported inventory and representative-workload proposal — 2026-10-05

[Consumer proposal §16](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#16-supported-inventory-request-coverage-and-workload-evidence--proposed-evaluation-plan)
adds one proposed coverage/workload matrix under existing Phase 3 provider suitability and
P3-T1 work. It retains all 15 accepted launch lines/services, distinguishes journey realtime
capability from schedule-routing readiness, and maps required dated inventory, occurrences,
calendar/time quality, directional allowances, continuity, revisions and truthful outcomes to
existing named synthetic tests or explicit gaps. Passed-position review is not real local/express
routing validation. Earlier lifecycle/composition/presentation gaps are superseded by their
published completion entries; no repeat consumer implementation is proposed.

Invented functional/stress fixtures, source-derived structure and justified representative
workloads are separate evidence classes. Later volume/density/depth/repetition/tie/output and
update measurements must carry scope and provenance; no Tokyo-scale values or production budgets
are invented. The bounded algorithm investigation is complete for now; append remains opt-in
and reference defaults remain unchanged. No further kernel optimization or benchmark is proposed.

Recommended smallest follow-up is documentation-only design of a source-neutral request-
qualification evidence manifest, with invented complete/missing examples, exact scope/revision
bindings and invalidation conditions. It would make completeness evidence reviewable without
opening evidence references, implementing an importer or granting real access. Production
solver/ownership, horizon/resource policy and adoption remain Proposed/unresolved; no new product
decision is needed for matrix construction. Source qualification, applicable rights, delivery and
separately authorized real review remain gates. P3-T1/Phase 3 stay incomplete; P2-S9 retains 14
classification and 14 ordering gaps. No ODPT reply supplied; live/default routing unconfigured.

Documentation-only: no code, tests/builds, benchmarks, private access or provider contact.




#### Request-qualification evidence manifest design — 2026-10-05

[Consumer proposal §17](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#17-request-qualification-evidence-manifest--proposed-review-design)
proposes a source-neutral review index over existing profile/scope, inventory, timetable binding,
connection and admission obligations. It is not a new qualification authority, schema/parser,
source reader or runtime approved flag. Declarations, examined support, unresolved obligations
and rights/delivery permission are separate; populated references cannot prove domain closure.
Invented complete and unknown-transfer examples preserve usable-direct-plus-unknown evidence
as dataUnavailable. Evidence closure never proves exploration completion or canonical admission.
Dependency invalidation covers scope, calendar, occurrence order, quality, permissions, allowance,
continuity and revisions without mutating retained snapshots or inventing freshness periods.

No new product behavior is proposed; technical organization remains Proposed. Existing tests
already exercise the illustrative qualification outcomes; no duplicate helper is recommended.
The existing P3-T1 design and progress map record the owner reporting an inquiry sent on
October 3, 2026; that date is not a reply date or independently examined correspondence.
No reply has been supplied or examined in this record. The smallest follow-up is separately
scoped review of an applicable interpretation reply if supplied, for the named public
resource/revision, or a specifically identified applicable official profile. No links or
candidate are reopened here. All 15 launch lines/services,
accepted identity/objectives/lifecycle/copy and rights gates remain unchanged. P3-T1/Phase 3
remain incomplete; P2-S9 retains 14 classification and 14 ordering gaps. Append stays opt-in,
reference defaults and unconfigured live routing remain; no ODPT reply supplied.

Documentation only; no code, tests/builds/benchmarks, private access or provider contact.



#### Bounded timetable batch-assembly design — 2026-10-05

[Producer proposal §10](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#10-bounded-in-memory-batch-assembly--proposed-choices-b1b3)
proposes one caller-enumerated invented in-memory batch, reusing the implemented DEC-085
converter and exact occurrence bindings. No date expansion, source discovery or new qualification
authority. B1 recommends retaining unsupported/insufficient slots while rejecting invalid packets
and structural contradictions. B2 proposes duplicate rejection, deterministic atomic construction
and an eight-slot experimental envelope with unchanged per-packet bounds. B3 proposes fresh-view
replacement with immutable historical retention, without automatic fallback or publication.
All B1–B3 remain Proposed; this task establishes no owner approval or implementation. Packet preflight
failures retain original converter diagnostics, including invalid/resource combinations.
Association coherence does not certify cross-packet calendar/zone definition consistency;
known conflicts remain unresolved source/view qualification failures, not usable source truth.

Declared complete inventory is an artificial-world assertion, not proof of usable facts or
request coverage. Unknown required slots/connections still prevent direct-only success;
existing search/admission and cutoff semantics stay unchanged. Existing single-packet conversion,
calendar/time/identity behavior is not reopened. The proposed later slice is a DEBUG-only
assembler and focused tests after approval, not a file importer, persistence/cache service or
production bridge. All 15 launch services remain preserved; P3-T1/Phase 3 remain incomplete;
P2-S9 retains 14 classification and 14 ordering gaps. The owner reports no ODPT reply has
arrived; none is supplied here. Append stays
opt-in; reference defaults and live routing remain unconfigured.

Documentation-only design; no code, tests/builds/benchmarks, private access or provider contact.



#### Bounded timetable batch assembler implementation — 2026-10-05

The owner accepted Producer §10 B1/B3 and authorized B2 as the reviewed technical experiment;
its eight-slot ceiling is an experimental safeguard, not production coverage or resource policy.
Earlier Proposed design wording above is historical. A DEBUG-only assembler now retains immutable
original bindings/outcomes in declaration order, rejects duplicate or incoherent envelopes and
invalid packets atomically, and preserves complete/unknown declarations without asserting usable
coverage. A minimal converter helper reuses exact existing preflight diagnostics; no single-packet
semantics/limits changed. No parser, registry, persistence, source profile or production bridge.

Fresh-view replacement is caller-owned as designed: a test rejects a disclosed same-view change
before assembly and preserves the old immutable value after fresh-view construction. Independent
assembly calls cannot detect undisclosed view reuse; no global history or automatic publication is
claimed. Unknown-transfer boundary checks do not establish a new batch-to-search integration;
existing integration suites retain the actual unavailable/no-fallback evidence. Calendar/zone
semantic agreement across packets is not established by matching revision tokens.

Validation (one run; included subsets are not summed):

- `/private/tmp/tsugino-batch-r2.xcresult`: **76 functions / 122 cases passed**, zero failures
  or skips, explicit iPhone 17 / iOS 26.5 Simulator. Includes assembler **13/26**, converter
  **26/39**, timetable values **16/21**, ride context **10/14**, existing timetable-routing
  integration **7/16**, and optimal integration **4/6**. Counts cross-checked against the
  structured result tree; interleaved console output was not used to invent extra functions.
  This final run supersedes the earlier run after a short-date regression was added: envelope
  bounds reject only excessive date length, preserving underlength-date converter diagnostics.
  Earlier overlapping counts are not added.
- Debug test action built app/extension dependencies. Standard Release app/extension build
  passed (`/private/tmp/tsugino-batch-release-final.log`); eight no-DEBUG declaration probes and
  Release app/assembler/converter object-symbol checks passed. Builds are newly executed,
  not reused evidence. Existing unrelated asset-catalog/Domain isolation/AppIntents warnings
  remain outside this slice. No physical-device interaction or benchmark.

Separate non-author implementation review approved the corrected source, tests, validation
and documentation with no material findings remaining. Scope/privacy and whitespace checks
passed; the short-date correction and final counts supersede earlier review fingerprints.

All 15 launch services remain preserved. Append remains opt-in; reference defaults and live
routing remain unconfigured. P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification and
14 ordering gaps. The owner reports no ODPT reply; none was supplied or accessed. No real import,
private data, provider contact, cache/history, UI or production adoption. Leave the five-file
implementation/documentation slice unstaged and uncommitted for publication review.

#### Timetable batch-to-routing test composition — 2026-10-05

`SyntheticTimetableBatchRoutingIntegrationTests` now exercises Producer §10 outcomes through
existing reference optimal search using only test-local composition. The invented D A→C
08:05–08:30, X A→B 08:02–08:10 and Y B→C 08:15–08:20 domain independently stipulates dated
inventory, original [0,1] intervals, permissions, continuity, validity and every directional
connection/allowance. Batch construction/declarations do not prove that coverage. Successful
facts pass unchanged; required unsupported/insufficient slots remain unavailable, proven inactive
slots remain inactive, and failed assembly never invokes search. Qualified X→Y wins; held Y or
an unknown required X→Y relation prevents direct-only success; proven inactive Y permits D.

Consumer-boundary and canonical-context assertions preserve full snapshots, dated addresses,
original indices, time states, eligibility and exact instants. Independently coherent V1/V2
batches retain their own facts; V1 remains unchanged after V2 use, and V1 facts in V2's search
view fail unavailable without rebinding. Source-token/policy correspondence is stipulated only:
no raw calendar/zone agreement detector, generic global-unknown inventory mapping, adapter,
production bridge or new qualification authority is introduced.

Validation: `/private/tmp/tsugino-batch-routing-r2.xcresult` passed **56 functions / 94 cases**,
zero failures/skips, on explicit iPhone 17 / iOS 26.5 Simulator. New composition **6/7**, batch
**13/26**, converter **26/39**, existing converter-routing **7/16** and optimal integration
**4/6** are included subsets, not additional runs. Structured result summary confirms counts.
The Debug test action built required dependencies. Initial sandbox execution could not connect
to CoreSimulator; it supplied no test evidence. No additional Release build was needed for this
test-only change: application source/project settings are unchanged from published batch
validation above; the new test file is DEBUG-guarded. No benchmark or physical-device work.

Separate non-author review approved the final tests and documentation with no material findings.
Scope/privacy and whitespace checks passed. Only this status entry and the new test file change;
leave them unstaged/uncommitted for publication review. Existing converter/cutoff/admission
mechanics are reused, not reimplemented. All 15 launch services remain preserved; append stays
opt-in and reference defaults/live routing remain unconfigured. P3-T1/Phase 3 remain incomplete;
P2-S9 retains 14 classification and 14 ordering gaps. No ODPT reply has arrived. No real import,
private access, provider contact, persistence, caching, UI or production adoption is established.


#### On-device calculation direction and architecture proposal — 2026-10-05

The owner directs prioritizing route calculation on iPhone. DEC-086 records this scoped R6
preference; Consumer §18 and ARCHITECTURE separate local computation from static acquisition,
permitted storage/updates, realtime access and independent technical/rights gates. This does
not resolve the production algorithm, execution ownership/scheduling, resource safeguards,
delivery or adoption. No offline/network-independence, licensing or performance claim follows.
Real passenger-stop/order evidence may follow later before applicable real consumption and
acceptance; S9's 14 classification and 14 ordering gaps remain. No ODPT reply has arrived.

Recommended next source-neutral work is a narrow per-call execution/isolation design for a
future on-device port: immutable view capture/replacement, shared-port concurrent callers,
per-call workspace and cancellation obligations, using existing contracts without a new
qualification layer. It is not implementation, another kernel benchmark or a production solver
choice. All 15 services remain preserved; append stays opt-in/reference default, live routing
unconfigured, P3-T1/Phase 3 incomplete. Documentation only; no tests/builds, private access,
provider contact, storage, UI or adoption. Separate non-author review found no material findings;
scope/reference/privacy and whitespace checks passed. Unresolved details remain Proposed.


#### Per-call routing execution/isolation design — 2026-10-05

Historical design-only record; scoped E2 acceptance and test-only completion are recorded below.

Consumer §19 distinguishes existing `@concurrent`/Sendable per-call engines, provider-style
loadView capture and DEC-087 task/publication ownership from the missing replaceable-view
internal-search composition. Recommended mechanism: direct awaited off-main Data execution,
local mutable state and a tiny isolated immutable-view read, with no additional worker or global
serialization. The owner accepted E2 on 2026-10-05: one atomic capture retained throughout
the call, replacements affecting subsequent captures without switching/cancelling earlier calls.
This does not accept production invalidation/publication/adoption. Existing cancellation
precedence and truthful cutoffs remain. Bounded implementation evidence is recorded below.

Smallest next experiment is test-only: a cancellation-aware controlled supplier/barrier and
reference optimal-search delegation for overlapping callers, cancellation/failure isolation
and V1/V2 retention. No production preflight/capture API, update publisher, storage policy,
algorithm or resource budget is implemented or selected. Scope/Sendable limitations and later
compiler checks are explicit in §19; suspended-call tests cannot prove CPU fairness or latency.
All 15 services remain; append opt-in/reference default/live unconfigured. P3-T1/Phase 3 and
S9's 14 classification/14 ordering gaps remain incomplete. No ODPT reply, data access or tests/
builds/benchmarks in this documentation task. Separate non-author review approved the final
design with no material findings; scope/reference/privacy and whitespace checks passed.


#### E2 capture/isolation test composition — 2026-10-05

The owner accepted atomic per-call immutable-view capture and retention, with replacement
applying only to later captures; no automatic cancellation/rebinding/switch of older calls.
`SyntheticRouteCaptureIsolationTests` now verifies that boundary using a test-local actor,
explicit @concurrent port and direct awaited unchanged reference optimal searcher. Independent
calls retain exact dated snapshots/indices/contexts and charge accounting; one-call cancellation,
required-input failure and admission-checkpoint cutoff cannot corrupt another or return partial
success. Pre-cancelled entry reads no view; every controlled worker is cancelled/joined and
single-waiter gates are per invocation. No production supplier or execution policy is implemented.

Final `/private/tmp/tsugino-capture-r3.xcresult`: **48 functions / 103 cases passed**, zero failures/
skips, explicit iPhone 17 / iOS 26.5 Simulator. Included subsets: new capture **6/8**, internal
routing **19/44**, optimal handoff **9/13**, coordinator **9/28**, composition **5/10**. Debug
required dependencies built. No additional Release build: application source/project settings
are unchanged from published batch validation (513b96c); the new test file is DEBUG-only.
Initial build failed on a test actor-await assertion; the next run exposed an overstrong
callback-trace assertion. The final deterministic one-interval fixture checks charge counts
instead, without promising trace parity. Superseded run counts are not added. Existing handoff
suites retain numerical-cutoff coverage; the new abort test exercises the existing checkpoint
failure path. No benchmark, latency/fairness guarantee or physical-device evidence is claimed.

Independent non-author review approved corrected final test/docs with no material findings.
Scope/privacy/references and whitespace passed. Only the test file plus the three reviewed
architecture/proposal/roadmap documents change, unstaged/uncommitted for publication review.
Production preflight/capture integration, invalidation/rights and adoption remain separate.
All 15 services stay preserved; append opt-in, reference default, live routing unconfigured;
P3-T1/Phase 3 incomplete; S9 retains 14 classification/14 ordering gaps. No ODPT reply, real data,
provider contact, persistence/cache, UI or production adoption.


#### DEBUG preflight/capture integration — 2026-10-05

The owner authorized the assessed optional-view seam under DEC-081/E2. The optimal searcher's
opt-in nonthrowing Sendable async capture initializer now reaches capture inside existing engine
qualification, after entry cancellation, configuration/permission/allowance checks and the charged
configuration checkpoint. One read is followed immediately by cancellation observation, then
unchanged qualification/selection/canonical admission with the same engine and allowance. Fixed-
view entry behavior remains preserved; no outer duplicate validation, reset or new charged unit.

Focused tests prove zero reads for missing/disallowed configuration, negative allowance, zero
configuration-step budget and pre-capture cancellation; eligible calls read once. Nil/incoherent
views fail unavailable, with observed cancellation taking precedence. Exact dated bindings,
full snapshots, indices and canonical contexts survive capture/replacement. Every allowance
prefix through successful admission is compared against fixed-view execution on a one-interval
fixture; no partial success or budget reset occurs. Controlled tasks/gates are cancelled/joined.
Supplier read success is not coverage proof; E2 does not establish production invalidation.

Final `/private/tmp/tsugino-preflight-r1.xcresult`: **55 functions / 117 cases passed**, zero
failures/skips, explicit iPhone 17 / iOS 26.5 Simulator. Included subsets: new preflight **7/14**,
capture isolation **6/8**, internal routing **19/44**, optimal handoff **9/13**, coordinator **9/28**,
composition **5/10**. Counts come from the structured summary/tree, not summed overlapping runs.
Debug test action built app/extension dependencies. Standard Release app/extension build passed
(`/private/tmp/tsugino-preflight-release.log`); two no-DEBUG declaration probes and Release app plus
both changed-object symbol checks passed. These checks/builds are newly executed. Existing
unrelated AppIntents/asset/Domain warnings do not establish a new failure; no benchmark/device run.

Separate non-author review approved final implementation/tests/docs with no material findings.
Scope/privacy/reference and whitespace checks passed. Only two DEBUG source files, the focused
test file and existing Consumer/ROADMAP records change; leave unstaged/uncommitted for publication
review. No production supplier, throwing acquisition API, network/data access, update publisher,
invalidation/storage/cache, Application redesign or adoption. All 15 services remain preserved;
append opt-in, reference default, live unconfigured. P3-T1/Phase 3 remain incomplete; P2-S9 retains
14 classification and 14 ordering gaps. No ODPT reply has arrived.


#### Test-only Application/capture integration — 2026-10-05

`RouteSearchCaptureIntegrationTests` injects the actual DEBUG capture-enabled optimal searcher
through a test-local AppEnvironment factory. Two deterministic cases close the bounded test-only
Application/capture integration workstream under DEC-087/E2 and Consumer §19.7. The complete
invented A→D/T1 domain uses service date 2026-04-13, original interval [0,1], V1 times 100→150
and fresh V2 times 100→160; coverage, permissions, continuity and policy coherence are stipulated.
Explicit departure is 100; no real-source qualification follows from these fixtures.

A captures V1 atomically before suspension. Supplier replacement alone leaves A searching;
submitting B cancels A's supplier gate, B captures V2 once, and both workers are joined before
asserting B remains current with exact scope, dated binding, full snapshot, indices and canonical
context. Explicit matching cancellation separately leaves the joined worker's owner cancelled,
with only configuration checkpoint work and one capture. No cancelled V1 success is fabricated.
Existing cancellation-aware gates and coordinator completion barriers support disposal, release
and joins on both success/error exits; no sleeps, polling or latency claims. No missing-view or
presentation matrix is duplicated.

Final `/private/tmp/tsugino-app-capture-r1.xcresult`: **29 functions / 62 cases passed**, zero
failures/skips, explicit iPhone 17 / iOS 26.5 Simulator. Included subsets: new integration **2/2**,
coordinator **9/28**, composition **5/10**, preflight/capture **7/14**, capture isolation **6/8**.
Structured result summary/tree establish these counts; subsets are not additional runs.
Debug test action built app/extension dependencies. No additional Release build was required:
application source and build settings are unchanged. No benchmark or physical-device run.

Separate non-author review approved the final tests and documentation with no material findings.
Scope/privacy/reference and whitespace checks passed. Only the new test file and this status entry
change, unstaged/uncommitted for publication review. This closes no production
supplier/integration, responsiveness, real qualification or milestone gate. All 15 launch services
remain preserved; append opt-in, reference default, live routing unconfigured. P3-T1/Phase 3 remain
incomplete; P2-S9 retains 14 classification and 14 ordering gaps.

Correspondence status at publication: the owner reports receiving an ODPT interpretation reply
on 2026-10-05 and supplying its screenshot in the conversation. Repository applicability review
has not occurred; no correspondence content is examined in this publication task. Receipt alone
does not resolve classification/ordering gaps, feed-revision applicability or rights/delivery gates.
Earlier dated no-reply records remain historical.


#### ODPT reply applicability checkpoint — 2026-10-05

Historical reply-only assessment below; the subsequent inquiry/reply association checkpoint
updates its resource-association finding and next step, without changing the retained S9 gaps.

**Review history and current evidence:** the initial partial assessment had no accessible image
and correctly treated the owner's summary as unexamined correspondence; its independent review
approved that limited status. The owner subsequently attached a readable screenshot, now directly
examined for the four quoted questions, answers and specification link. It displays the ODPT
secretariat as sender and an October 3 quoted-message date; October 5 receipt remains owner-reported
(the reply header shows a time/relative age, not a full receipt date). This is examination of the
supplied image, not mail-header authentication or private mailbox access. No screenshot, contact
details, full correspondence, local attachment path or private occurrence content is committed.

Tracked inquiry context: the October 3 public research/trace above identifies Toei `train-toei`
resource `35b68908-4558-47ae-bfa5-867e58544a1a`, retained feed version `20260921`, and asks about
stop/pass/restricted-position, omission, ordering and conversion/exception conventions. Consumer
§17.5 records the owner-reported sending date. The visible questions match those topics and Q4
explicitly requests revision 20260921 applicability or the version/period/scope that can be confirmed.
The screenshot does not visibly identify the resource UUID; association to that exact resource
still rests on tracked inquiry context, not an explicit identifier in the displayed answer. Quoting
Q4 acknowledges the question, **not confirmation of the requested historical applicability**.

**Public reference reused:** the screenshot's answer to Q4 links exactly to
[official GTFS Schedule Reference](https://gtfs.org/documentation/schedule/reference/).
The earlier October 5 public review of its [stop_times.txt fields](https://gtfs.org/documentation/schedule/reference/#stop_timestxt)
is reused; the served document labels itself **Revised April 27, 2026**. `pickup_type` and
`drop_off_type` describe passenger access independently: 1 prohibits the respective operation;
0/empty denotes regular service; 2/3 require arrangements. `stop_sequence` is a nonnegative
integer trip ordering key, increasing but not necessarily consecutive. These generic meanings
do not prove physical passing or traversal completeness. Neither a current reference nor an
undated conformance answer identifies the exact historical profile implemented by this snapshot.
No further public retrieval was necessary.

| Existing obligation / quoted question | Explicit answer visible in the screenshot | Scoped contribution and unanswered questions |
|---|---|---|
| Classification, Q1: what row inclusion represents; whether non-passenger positions are included | Besides stopping stations, passing stations of Toei Shinjuku Line express trains are included in stop_times.txt. | Direct source-specific interpretation evidence that inclusion is not exclusively passenger stopping. It does not classify the candidate or establish that every physically traversed station/point is represented. |
| Classification, Q2: passenger stops, restricted stops, passing positions, omissions and exceptions | Passing stations have pickup_type=1 and drop_off_type=1. | Preserve passing ⇒ 1/1 only. The answer does not assert 1/1 ⇒ physical passing, exclude restricted physical stops with 1/1, or explain one-sided restrictions, omitted positions or all exceptions. Generic GTFS permission meanings remain separate. |
| Ordering, Q3: guaranteed order, conversion/adoption rules, exceptions, represented versus complete physical order | stop_sequence follows the station order of stopping and passing stations. | Supports ordering of represented stations in the answer's scope. It does not answer completeness of all traversed positions, conversion rules or exceptions. No independent physical traversal/crosswalk proof follows. |
| Resource/revision/specification, Q4: supporting profile and applicable version/period, specifically 20260921 or confirmable alternatives | The resource follows GTFS Schedule, with the official reference link above. | This is an explicit conformance statement, not merely inferred adoption. It supplies no explicit feed_version 20260921 confirmation, alternative applicability period, named specification revision or conversion profile. Resource association is contextual as noted above. |
| Rights/delivery | No permission statement appears in these answers. | Publication, translation, offline retention and bundling gates remain separate. No rights authorization follows from technical interpretation or reply receipt. |

**Inference, not accepted row classification:** this reply explains how some non-passenger
traversal rows can appear in the source and supports a represented-station ordering convention.
It is reasonable to regard it as a response to the tracked interpretation inquiry; exact resource
and retained-revision scope still need corroboration. It cannot identify which of the fourteen
pilot occurrences belong to any class. **Classification gaps remain 14; ordering gaps remain 14;
P2-S9 is incomplete.** No source profile, candidate classification or semantic change is accepted.
Identity, mappings, movement/endpoints, independent crosswalk, registration and acceptance retain
the existing DEC-082/readiness obligations. Zero transport-order inversions is not railway proof.

**Smallest next evidence task:** review only a supplied inquiry excerpt identifying the public
resource UUID, if available, and an applicable authoritative statement/document establishing
whether these conventions cover retained feed_version 20260921 (or precisely what scope can be
supported instead). The current screenshot need not be requested again. No private archive,
manifest or candidate access is needed to answer that association question. If clarification is
required, ask precisely whether the stated conventions apply to that resource/revision, whether
1/1 can also describe restricted physical stops, how one-sided restrictions are represented, and
what omissions/conversion exceptions limit the stated ordering. These are unanswered evidence
questions, not new product choices or authorization to contact the provider. Applicable existing
conformance/conversion or occurrence-specific evidence can contribute; a new literal adoption
statement is not the only permissible evidence route.

After the applicable interpretation boundary is supported, a separately authorized owner-only
review still needs the same candidate's complete 14-row set: exact locators, original sequence
spelling/numeric order, repeated visits and pickup/drop-off fields, with affirmative applicable
classification and independent scoped order/crosswalk evidence. Unknown interior positions remain
held; no raw times, candidate substitution, cropping or automatic classification by flags. Existing
review_session displays permitted fields but cannot classify, clear gaps or establish an acceptance
crosswalk. Its earlier one-use grants remain consumed; this document grants no new re-read or
private evidence access. No retained feed or source occurrence was examined in this task.

Separate non-author review directly examined the supplied screenshot and approved this revised
assessment with no material findings. Scope/privacy/reference and whitespace checks passed.
No code/tests/builds, provider contact or production adoption. P3-T1/Phase 3 remain incomplete; all 15 launch services
remain preserved, live/default routing unconfigured, reference default and append opt-in.


#### ODPT inquiry/reply association checkpoint — 2026-10-05

**Current evidence:** both supplied screenshots are readable and were directly examined: the
original inquiry and the reply including its four quoted questions and original-message reference.
The previously missing inquiry image is now available; earlier attachment/context-only assessments
remain review history. No screenshots, full correspondence, personal/contact details or local
attachment paths are committed. This is visual correspondence assessment, not mailbox/header
verification. No retained feed, source occurrence, private correspondence archive or manifest access.

| Observable comparison | Finding and limit |
|---|---|
| Original inquiry resource block | Explicitly identifies Tokyo Metropolitan Bureau of Transportation railway-related information, UUID `35b68908-4558-47ae-bfa5-867e58544a1a`, its [ODPT catalog resource URL](https://ckan.odpt.org/dataset/train-toei/resource/35b68908-4558-47ae-bfa5-867e58544a1a), and requested feed_version `20260921`. These agree with the tracked inquiry target. The catalog was not reopened. |
| Four questions | The reply quotes the same four questions, in the same order, covering row inclusion; passenger/restricted/passed positions and omissions; ordering/conversion exceptions versus full physical traversal; and specification/revision applicability. The visible wording agrees apart from layout/quotation formatting. |
| Message reference | The original inquiry header displays October 3, 2026, 22:09; the reply's original-message reference gives that same date/time. Visible author identification also agrees, without reproducing it here. No timezone conversion or transport timestamp is inferred. |
| Association conclusion | Matching questions, message date/time and visible author identification support associating this reply with the inquiry about the identified resource. Resource association now has direct screenshot-based support, rather than tracked context alone. Full email headers, Message-ID/In-Reply-To linkage, delivery logs and image authenticity are not verified; this is not cryptographic authentication. |
| Requested versus answered revision | The original resource block and quoted Q4 request 20260921 applicability (or the confirmable version/period/scope). The actual Q4 answer states GTFS Schedule conformance and links the official reference; it does not affirm that revision or identify another applicable period. Association resolves which question was asked, not the unanswered historical applicability. |

The reply's substantive contribution remains as previously examined: Shinjuku Line express
passing stations are included alongside stopping stations; passing stations have pickup/drop-off
1/1; stop_sequence follows represented stopping/passing station order. **Passing ⇒ 1/1 remains
one-way.** Generic GTFS passenger permissions do not prove physical passing. No answer establishes
complete representation of every traversed station/point, restricted physical-stop conventions,
one-sided permissions, omission/conversion exceptions or rights/delivery permission. The earlier
public-reference review (served revision April 27, 2026) is reused; no new public retrieval.

**Smallest next step:** obtain/review narrowly targeted authoritative clarification before applying
these conventions to the retained revision, unless already available applicable evidence supplies
the same answers. No further general resource-association inquiry is needed on the evidence now
examined. The precise open questions and their acceptance relevance are:

- Do these inclusion, passing-encoding and ordering conventions apply to this resource's
  feed_version 20260921? If not confirmable, what version/period/scope is supported? This bounds
  the interpretation profile before using it for the historical candidate.
- Can 1/1 also describe a physically stopping station with no passenger exchange, and how are
  one-sided boarding/alighting restrictions represented? This prevents unsupported classification
  of restricted stops as passes; permissions and physical stopping must remain distinct.
- Are any traversed stations/positions omitted, and what conversion/adoption rules or exceptions
  qualify the stated sequence order? This bounds represented-position coverage and the existing
  scoped ordering/crosswalk obligations without equating trip order to complete physical traversal.

These questions are not sent and introduce no new acceptance policy. Rights/retention/bundling
remain separate gates, not implied answers to a technical inquiry. After applicable interpretation
is supported, occurrence-specific application and independent crosswalk review still require a
separately authorized, complete same-candidate review; no previous one-use grant is renewed here.
**All 14 classification and 14 ordering gaps remain unresolved.** No source row was examined or
classified. P2-S9, P3-T1 and Phase 3 remain incomplete; live/default routing stays unconfigured,
reference selection default, append opt-in and all 15 launch services preserved.

Separate non-author review directly examined both screenshots and approved this association update
with no material findings. Scope/privacy/reference and whitespace checks passed. No code, tests,
builds, provider contact, data acquisition or production adoption; leave changes unstaged/uncommitted.


#### ODPT follow-up interpretation evidence checkpoint — 2026-10-08

**Scope and provenance:** bounded authoritative-evidence assessment of the owner's supplied
transcription of a new technical follow-up, distinct from the October 5 inquiry/reply
association checkpoint above. No image was directly inspected or authenticated here; attribution
and correspondence continuity rely on the owner-supplied account and the previously recorded
resource association. This is evidence assessment, not an authenticated source capture or profile
application. Only this ROADMAP checkpoint changes; no correspondence metadata or restorable
source data is recorded. The identified resource remains Toei `train-toei`, public UUID
`35b68908-4558-47ae-bfa5-867e58544a1a`, retained `feed_version 20260921`.

Authority: Accepted DEC-082 §§1.1–1.2/2/3/4/6 (coherent source/review scope, affirmative
classification, source order versus independent crosswalk, recurring correspondence, movement/
coverage and real acceptance); DEC-083 and DEC-084 preserve separate registration/real-use
boundaries. P2_S9_REAL_READINESS's readiness matrix and smallest ordered path retain separate
reviewed-profile, access, execution and acceptance actions. No Accepted decision is amended.

| New answer / previously open question | Supported interpretation and limit | Disposition |
|---|---|---|
| Q1: retained revision applicability | The provider says the previously explained passing representation and sequence rules apply to all feed versions, including the current one. This explicitly includes 20260921 for this resource; it does not establish another feed's semantics or authenticate retained bytes. | Revision-applicability interpretation blocker resolved on the supplied evidence. |
| Q2: stopping versus passing, restrictions | The encoding itself does not distinguish physical passing from a physical stop without passenger exchange. Separately, the provider states that in the applicable Toei timetable every actual stopping station, including origins/terminals, permits both boarding and alighting and is encoded 0/0; no boarding-only or alighting-only stops currently occur. Read with Q1 and the retained-revision question, this supports a resource/revision-specific station profile: 0/0 identifies passenger stopping; a represented 1/1 station is excluded from passenger stops and, within the stated all-actual-stops-are-0/0 timetable scope, is a passing station. This is stronger than the earlier passing ⇒ 1/1 fact alone. It is not the global GTFS implication 1/1 ⇒ physical passing. The current-operating-pattern assertion is not a guarantee for every past/future revision merely because Q1 gives all-version encoding/order applicability. | Classification interpretation supported for the stated retained scope, conditional on reviewed profile applicability and matching occurrence evidence. One-sided cases are not an evidenced variant of that applicable timetable; an actual contrary row must be held/reconciled, not forcibly classified. |
| Q3: represented stations / omissions | Passenger-service train records include stopping and passing stations; non-passenger movements such as deadhead/out-of-service trains are absent. Together with the earlier authoritative recorded-station sequence statement and Q1, this supports completeness of represented railway-station traversal for passenger-service runs in the stated resource/revision scope and their source station order. It does not assert representation of arbitrary infrastructure points, non-station locations, non-passenger movements or other feeds. | Station-level completeness and source-order interpretation blockers supported/resolved within that scope; no blanket certification of all transformations, physical locations or individual run contents. |

**DEC-082-compatible profile now supported, not applied/accepted here:** the combined evidence
can underpin a reviewed source/revision interpretation profile; further general clarification is
not a prerequisite merely to repeat the three answered questions. Define the profile with exact
resource/revision and evidence references, the explicit 0/0 and 1/1 variant rules above, passenger-
service station scope, exclusion of non-passenger movements, numeric `stop_sequence` ordering
(with nonconsecutive values permitted), and an invalidation rule. Missing/other field variants,
one-sided permissions, contradictions, out-of-scope records or changed operating-pattern/source
semantics require renewed applicable evidence and hold dependent classifications. No blank-time,
row-presence, topology or unsupported flag heuristic is authorized. Source ordering does not
establish canonical station identity, physical line traversal or the source-to-passenger-index
crosswalk. The provider's statement supplies station-level interpretation evidence, not proof
that the nominated extract is complete, coherent or free of duplicate/missing ordering keys.

**Owner boundary:** no new product/Domain policy or decision record is needed simply to record
this external evidence. Before application, separately review/accept the precise source/revision
profile and its applicability under DEC-082 §1.2 and the readiness ordered path; this task does not
supply that owner acceptance, a recurring-key interpretation profile or real execution authority.
In particular, preserve Q2's current-timetable scope rather than silently exporting the physical-
stopping assertion to unrelated operators or future revisions. A contradiction with the retained
scope reopens the affected interpretation rather than changing accepted policy to fit a row.

**Occurrence obligations and unchanged counts:** all **14 classification gaps and 14 ordering/
crosswalk gaps remain unresolved**. None of the retained occurrences was read or classified.
A separately authorized same-candidate review must establish the complete fixed interval and
exact retained source/member/hash/revision; inspect every occurrence's original sequence spelling/
numeric order, repeated visits and permitted classification fields; apply the reviewed profile
with explicit evidence/dispositions; resolve exact active canonical station/line mappings in one
compatible view; and independently verify the full source-to-passenger-index/passed-disposition
crosswalk. Numeric order and zero transport inversions alone do not discharge that review.
Recurring-run correspondence/competing matches, line movement and boundaries, independent endpoint
coverage, registration/checkpoint/owner approvals and immutable snapshot/evidence/reproduction
acceptance remain separate DEC-082/083/084 obligations. Do not infer identity, endpoints, service
type or timetable facts from this reply. A generic profile cannot close actual occurrence gaps.

**Smallest safe next step:** owner review/acceptance of the bounded interpretation profile and
its exact applicability, followed by a separately explicit read-only same-candidate occurrence/
crosswalk review grant with an identified artifact allowlist and permitted outputs. Prior one-use
access remains exhausted. No retained archive, replacement archive, private occurrence/candidate,
mailbox or additional correspondence was accessed; no real review session, packet, registration,
ID minting, provider contact, timetable import or routing enablement occurred. Rights/retention/
publication/bundling remain independent. P2-S9, P3-T1 and Phase 3 remain incomplete; all 15 launch
services remain preserved, live/default routing unconfigured, reference default and append opt-in.
App tests/builds are intentionally not run for this documentation-only assessment. Leave the
checkpoint uncommitted for owner review; verification and independent review are reported separately.


#### Owner acceptance overlay — retained Toei interpretation profile — 2026-10-08

**Current authority:** the owner explicitly accepts this bounded profile under Accepted
DEC-082. This overlay supersedes only the preceding evidence checkpoint's pending-profile-
acceptance boundary and its next-step requirement to obtain that acceptance. The external
evidence assessment above is preserved unchanged as history: owner-supplied technical
transcription, not direct image inspection/authentication. Profile acceptance is distinct
from external evidence and from occurrence-specific evidence, which is still unreviewed.
No new general GTFS policy, Domain semantics or DEC-082 amendment is introduced; no separate
DEC file change is required for this source-profile approval within its existing framework.

**Exact accepted scope:** Tokyo Metropolitan Bureau of Transportation / Toei static GTFS
resource `35b68908-4558-47ae-bfa5-867e58544a1a`, retained `feed_version 20260921`, passenger-
service train records and their represented station occurrences in the applicable stop-time
records. The provider's all-version encoding/order statement is evidence, but this owner
acceptance extends only to the retained 20260921 review scope. Other operators/resources,
different or future revisions, non-passenger/deadhead movements and arbitrary non-station
infrastructure points are excluded. A later scope needs its own applicability review even
when reusing the same authoritative statement. A candidate not established as belonging to
this passenger-service scope cannot use the profile.

| Accepted profile rule | Basis, limit and required disposition |
|---|---|
| Explicit `pickup_type=0`, `drop_off_type=0` | Classify the represented occurrence as **Passenger stop** under DEC-082. The applicable Toei timetable's actual stopping stations, including origins/terminals, permit both boarding and alighting and are encoded 0/0. This establishes no canonical StationID, recurring identity, time validity, movement, endpoint completeness or production usability. |
| Explicit `pickup_type=1`, `drop_off_type=1` | Classify the represented occurrence as **Passed position** only within this exact accepted profile. The encoding can in principle also describe physical stopping without passenger exchange; the provider's applicable-timetable statement excludes that actual stopping case because every actual stopping station is 0/0. This source-specific conclusion is not a generic GTFS physical-pass rule. Retain an explicit passed disposition without a canonical passenger index. |
| `0/1`, `1/0`, missing, malformed, contradictory or otherwise incompatible values | No normal classification rule is accepted. The provider states no one-sided stopping case occurs in the applicable timetable. An encountered outside-profile variant remains **Unknown / held**, reopening applicability review; do not invent semantics or silently broaden the profile. Preserve DEC-082's applicable proposal-wide contradiction/order rejection rules. |
| Represented station coverage | Passenger-service records include both stopping and passing stations. Non-passenger movements, including deadhead/out-of-service trains, are not represented. This supports the represented station sequence, not arbitrary track/infrastructure points, non-station locations or passenger-inaccessible trains, and does not prove the retained extract's completeness. |
| Source order | Use numeric `stop_sequence`, not CSV transport order or lexical sorting; nonconsecutive values are permitted unless another contract is violated. Duplicate, missing, contradictory or invalid occurrence/order evidence retains DEC-082 rejection/hold behavior. This establishes source order only, not canonical mappings, canonical original indices, crosswalk correctness, infrastructure order beyond represented stations or recurring correspondence. |

**Invalidation/reopening:** reopen dependent classification or ordering if authoritative
guidance changes or is contradicted; source/resource identity changes; a source revision
changes without separate applicability review; actual data contains an outside-profile variant;
the candidate is outside covered passenger service; or representation violates expected
station completeness/order. Hold/reject under the existing DEC-082 conditions and seek
applicable evidence/review rather than silently extending this approval.

**Effect and retained obligations:** the interpretation-profile approval blocker is now fully
cleared for a separately authorized same-candidate review within the scope above. No actual
occurrence is classified by this overlay: **14 classification gaps and 14 ordering/crosswalk
gaps remain open**. That review must account for the complete fixed same candidate, establish
each occurrence's profile membership, classification and numeric source order, exact active
canonical StationID mapping for passenger stops, explicit passed dispositions and the full
source-to-canonical crosswalk. Preserve repeated station visits and all proposal-wide hold/
reject conditions. Recurring-run correspondence, line/movement evidence, endpoint claims,
registration and final P2-S9 acceptance remain separately evidenced obligations; this approval
neither supplies nor declares them satisfied. P2-S9, P3-T1 and Phase 3 remain incomplete;
live/default routing remains unconfigured, reference default and append opt-in unchanged.

**Next safe action and access boundary:** obtain a separately explicit, read-only same-candidate
occurrence/crosswalk review authorization naming existing artifacts, permitted fields, dependency
scope and private outputs. The prior one-use real re-read grant remains exhausted; this profile
acceptance renews no access. No archive, occurrence, private candidate, mailbox or real review
tool was accessed; no real evidence packet, registration/minting, timetable import or routing
behavior change occurred. Only ROADMAP documentation changes, preserving the earlier checkpoint.
The complete accumulated diff requires exact-diff/reference/privacy/scope and whitespace checks
and separate non-author review. App tests/builds are unnecessary; leave the diff unstaged and
uncommitted. Rights, delivery and production gates remain independent.


#### Owner-reported same-candidate occurrence review — 2026-10-08

**Current-state overlay and provenance:** separately authorized **owner-reported private review
of the exact previously confirmed candidate**, operated in the required unrecorded local
foreground terminal. Codex did not observe that terminal or independently authenticate the raw
occurrence contents. The owner reports successful matching of the already tracked Toei DS-01
archive identity: 779,699 bytes, SHA-256
`dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`,
retained `feed_version 20260921`. All fourteen same-candidate occurrences were inspected and
accounted for; extractor transport-order inversions remained zero. The new one-use same-candidate
re-read grant was successfully exercised and **is now consumed**. No further private read is
permitted without new explicit owner authorization. No private source was reopened for this
sanitized documentation task.

This checkpoint follows the external-evidence assessment and bounded owner-profile approval
above under Accepted DEC-082 §§1.2/2/6, DEC-083/084 and the P2-S9 readiness contract. Earlier
statements of 14 classification and 14 ordering/crosswalk gaps remain historical records of
those stages, not the current split below. No new DEC, policy, Domain or tooling change is needed.

| Current bounded result | Owner-reported evidence and effect |
|---|---|
| Classification | All 14 occurrences were within the accepted Toei 20260921 profile and had explicit pickup/drop-off 0/0. **Passenger stop: 14; Passed position: 0; Unknown: 0; profile contradictions: 0.** No one-sided or unsupported value occurred. Under that accepted profile plus complete occurrence application, **classification gaps: 14 → 0 for this candidate only**. This is not a general GTFS rule or closure for any other candidate/resource/operator/revision. |
| Source order | All 14 represented occurrences were accounted for with valid numeric sequence keys, no duplicate key and no missing/contradictory occurrence-order evidence. One unambiguous numeric source order was reviewed. **Source-order ambiguity/ordering obligation is resolved for this reviewed candidate**; zero transport inversions supports extraction accounting but alone would not prove it. No canonical original indices or StationID correspondence follows. |
| Repeated visits | No repeated source station occurrence was observed in this candidate. DEC-082's general requirement to preserve repeated visits remains unchanged; other candidates may contain them. |
| Canonical mapping/crosswalk | **Verified: 0; held: 14.** No canonical mapping artifact was accessed, no exact active canonical StationID correspondence was independently verified, and no source-to-canonical crosswalk was constructed or accepted. These are now **14 canonical mapping/crosswalk gaps**, not fourteen unresolved source-order questions. |

**Remaining proposal-wide and downstream gates:** the candidate is still held for canonical
mapping/crosswalk and is not an accepted canonical Trip. Exact active mappings in an identified
compatible revision, complete source-to-canonical crosswalk and canonical passenger original-
index assignments remain outstanding. Recurring-run correspondence/Trip identity, line/movement
evidence, service origin/destination and endpoint claims, required provisional registration,
registry/checkpoint obligations and final immutable snapshot/evidence review/acceptance remain
separate; none is closed by stopping pattern or source order. P2-S9 remains incomplete; P3-T1
real timetable import remains incomplete; Phase 3 remains **In Progress**. Production routing
strategy/adoption and live/default routing remain unresolved/unconfigured; reference default and
append opt-in are unchanged. Rights/publication/bundling gates remain independent.

**Smallest next step:** identify the minimum already-approved provisional canonical mapping
artifact and exact read-only access path/dependency scope needed for the fourteen held items,
without accessing it in this task. No mapping path is invented and no discovery, parser/adapter,
registry or evidence-packet work is authorized here. Any future private access requires explicit
owner authorization. This documentation records allowed aggregate findings only, without raw
provider identifiers, sequence lists, itineraries, locators, member/row hashes, private paths or
terminal captures. Existing evidence/profile records are preserved unchanged. Only ROADMAP is
updated; no source/tool changes, private inspection rerun, Swift/Python tests or app builds.
Leave the complete accumulated diff unstaged and uncommitted for owner review; exact-diff,
reference/privacy/scope/whitespace checks and separate non-author review cover the whole chain.


#### Repository-only canonical mapping access assessment — 2026-10-08

**Verdict: NEEDS_BOUNDED_TOOLING.** Repository contracts/code identify the authoritative
provisional correspondence model and an accepted historical baseline, but no reviewed narrow
real-input occurrence-to-mapping inspection interface. This is neither a missing correspondence
model nor a new identity-policy decision. Artifact availability and exact dependency identities
still require owner inputs; no private artifact was accessed or discovered. Classification gaps
remain **0**, reviewed source order remains resolved, canonical mapping/crosswalk remains
**0 verified / 14 held**. The occurrence one-use grant remains consumed.

**Authority and roles:** DEC-068 §§B–E and ARCHITECTURE §39 own registry identity/reference
rules; P2-S5/DEC-069 supplies reviewed station assignments (directly required to explain station
bindings); DEC-070/071 supply network/name evidence, not another GTFS identity resolver;
DEC-072/073/074/075 govern storage, transitions, provisional acceptance and retained gates.
DEC-082 §§1.1–1.2/2/6 and DEC-083/084 preserve exact source/view/crosswalk, identity and
real-use boundaries. The P2-S9 readiness matrix and ordered path retain separate private access,
profile, tooling and final acceptance actions. No DEC amendment is needed.

- The binding is a `ProviderReference` in `MappingRegistry`: key = exact `sourceID`,
  `gtfs.stop_id` namespace and scalar-exact decoded value; target = canonical station-kind
  minted identifier. `ExactValue` forbids normalization/folding. Reference active/absent/retired
  status and entity active/retired status are distinct; only active references resolve, and
  registry validation forbids an active reference targeting a retired entity. No successor
  is followed. Source input/member digests and first/last sightings are provenance; the key
  itself does not include feed revision, so the chosen registry snapshot/revision and exact
  source applicability must be checked separately. `attachedBy` retains attaching review authority.
- `StationGrouping` reviews operator-level member groups. P2-S5 cross-operator station
  assignments identify the final held StationID and all member references; the station-registry
  tool attaches those members through reviewed assignment authority. `ReviewedRevision` governs
  attachment/retirement, not implicit rebinding. DEC-073 predecessor/history closure is required
  if relevant transitions exist. DEC-071 Railway-title bindings are editorial evidence only.
- SQLite is a derived runtime artifact, not the provider-reference resolver. Its seven tables
  hold canonical models, aliases/search, entity retirement/successors and metadata. Metadata
  pins registry revision, registry/name/network input hashes and build history, but embeds no
  provider references, binding statuses, attachment reviews or full editorial/provider history.
  Thus SQLite **alone cannot prove the crosswalk**. `station(id:)` requires an already known ID;
  name search cannot establish it. Canonical membership/active-state checks may reuse a separately
  authorized coherent runtime view after correspondence is established.

**Minimum artifact roles / known identities:** the DEC-074 acceptance record retains registry
revision 6, SHA-256 `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`,
and schema-1 runtime artifact SHA-256
`c0e38b0a4220a116cbaa9add736e66ce8fdfa58b48e550e2975de0e23fcbc151`,
data version `p2s8-local-provisional-20261001`. These are historical pins, not freshly checked
availability/currentness. Required: exact approved registry bytes; relevant P2-S4 grouping and
P2-S5 assignment/attachment review evidence with identified source/member and mapping revisions;
acceptance/provenance manifest and necessary immutable history/predecessor closure; and the exact
same-candidate occurrence/order/profile association supplied through separately authorized private
inputs. Review-dependency hashes are retained in the owner-only package, not fully enumerated
here; owner must supply explicit paths and expected identities/approvals without discovery.
The runtime artifact/metadata is a coherent membership/identity check when needed, not a substitute
for that evidence chain. DEC-070/071 records are needed only for relevant membership/dependency
proof, not to remap names. No individual file alone proves the complete occurrence crosswalk.

**Existing interface assessment:** `MappingRegistry.decoded`/`resolve` are reusable strict
in-memory primitives, not a reviewed private-file inspection workflow; decoding validates the
whole supplied registry. StaticDataIntake station-registry reconciles broad two-operator inputs
and writes outputs; station/review/name packets export provider evidence or validate broad
source dependencies. RailwayStorage builds/publishes artifacts/transitions; its read-only
repository validates the full canonical artifact at open and has no source-key resolver.
TripNomination review exposes occurrences only and opens no mapping evidence. None supplies
this narrowly scoped, read-only, evidence-bound real crosswalk interface. Prior baseline access
and code existence grant no new real mapping access.

**Smallest proposed tool contract — design/implementation not authorized here:**

- Inputs: explicit owner allowlist with expected hashes/schema/revision/checkpoint and approval
  references for the artifact roles above; exactly fourteen privately supplied ordered occurrence
  associations/source keys, bound to the reviewed same-candidate source/profile scope. Do not
  reconstruct keys from public aggregates; if none remain locally available, request a separately
  authorized source-input mechanism rather than reuse the consumed occurrence grant.
- Reuse scalar-exact registry validation/resolution; inspect selected reference fields, target
  kind/status, source/member/input identity and review links, plus only necessary assignment,
  history and membership dependency closure. Whole-registry validation necessarily reads unrelated
  records internally: explicit approval of that bounded validation is required, with no unrelated
  disclosure. Do not claim physical selective reading from a monolithic registry. If that scope
  is disallowed, stop and separately design a provenance-verifiable projection; an arbitrary
  extracted subset cannot certify registry uniqueness/history.
- Proposed fixed limits for later review: exactly 14 occurrence slots (no StationID deduplication),
  at most 32 allowlisted artifacts, 16 MiB each / 64 MiB total, 100,000 decoded records total and
  1,024 history steps; preserve stricter existing codec limits. Exceeding any bound fails closed,
  never auto-expands or truncates. These are proposed tooling limits, not accepted feed limits.
- Read-only descriptors, no symlinks/discovery/network/writes/export; check expected identity
  before decode and unchanged bytes/path identity after reads. Owner-operated unrecorded local
  foreground terminal, no agent-captured private output; memory-only results/associations and
  sanitized aggregate public counts. No provider/canonical pairs or itinerary enter Git/chat.
- Missing/ambiguous/inactive references, retired entities, wrong source/input/view, unknown schema,
  duplicates/conflicts, unavailable review/history/approval, incomplete dependency closure,
  mutation or outside-scope inputs hold/reject under existing contracts with fixed safe errors;
  no name matching, successor following, newer-revision substitution or partial accepted output.
  Only after all fourteen mappings are accepted may consecutive passenger indices 0...13 be
  assigned from resolved source order; preserve repeat occurrences in general.
- Before real use: separately authorized implementation, invented tests for exact Unicode keys,
  status/kind/revision/provenance/review conflicts, repeated occurrences, missing dependencies,
  limits, mutation/symlink failures and no writes/leaks; independent non-author code/contract
  review, then a separate explicit real-input execution grant. No tests or tool changes here.

**Next step:** owner review of this bounded tooling/access specification and explicit artifact-
role/identity inputs; no mapping access in this assessment. P2-S9/P3-T1 remain incomplete,
Phase 3 remains In Progress and live/default routing remains unconfigured. Identity, movement,
endpoints, registration, snapshot acceptance and production/rights/delivery gates remain separate.
Only this ROADMAP checkpoint is added, preserving the preceding evidence chain; no private data,
implementation, tests/builds or publication operations. Leave the accumulated diff unstaged.


#### Bounded canonical station crosswalk tooling — synthetic implementation checkpoint (2026-10-08)

The preceding `NEEDS_BOUNDED_TOOLING` assessment led to the offline
`StaticDataIntake trip-station-crosswalk-review` implementation. This checkpoint
covers invented synthetic inputs only. It adds no real mapping evidence and
grants no real execution authority.

The bounded interface requires explicit hash-pinned registry/review/key files,
registry revision, source/archive/member identities, namespace and expected count
(1–64). It reuses canonical exact-key and reviewed assignment types, checks selected
attachment/provenance closure, retains repetitions and reports aggregates only.
Schema-2 baselines are supported; transition-history schema-3 inputs fail closed.
The caller-approved immutable full review file is an acceptance premise, not an
approval inferred from a matching hash. No SQLite, GTFS, names, coordinates, times,
network, subprocess, mapping mutation, Trip creation or review output artifact is
part of the command. See `Tools/StaticDataIntake/README.md` for the exact contract.

No real/private mapping artifact was accessed. The historical registry revision 6
and its recorded hash, and DEC-074 package identities, are reference identities
only; actual availability and paths remain unestablished. The previous occurrence
one-use grant remains consumed. Real execution requires a separate explicit owner
grant and a supported, approved baseline/evidence closure.

Synthetic verification: `TEST_FILTER=crosswalk sh Tools/StaticDataIntake/test.sh`
passed **35 cases / 0 failures** (33 new crosswalk cases plus 2 existing matching
cases). The combined record budget includes nested review sides/members. Affected
existing minting (8), grouping (18), revision (21), provisional registry (16) and
station (15) cases all passed; their name-based filtered run included 3 additional
existing matches, **81 / 0 failures**. These overlapping runs are not summed.
`sh Tools/StaticDataIntake/build.sh` passed for the final optimized tool.
No skips or compiler warnings were reported; temporary fixture roots were removed.
No iOS build or device operation was required for this offline-only boundary.
Independent non-author review approved exact bindings, selected evidence closure,
privacy, I/O guards and scope, with no material findings remaining. Original
decision reason/alias/provenance approval remains the immutable-file premise,
not something this command reauthenticates. The accumulated 282-line preceding
ROADMAP evidence chain remains intact, and changes remain uncommitted/unstaged.

Classification remains **0 gaps**; source ordering remains **resolved** for the
reviewed candidate; canonical crosswalk remains **0 verified / 14 held**. P2-S9 and
P3-T1 remain incomplete, Phase 3 remains In Progress, and live/default routing
remains unconfigured. Synthetic tooling readiness must not be read as acceptance
of any of the fourteen real mappings.

#### Bounded crosswalk prerequisite recovery assessment — 2026-10-08

Repository preflight retained the expected phase branch/HEAD/upstream, 0/0 cached
upstream divergence, six intended unstaged files and the preceding evidence chain.
Only the explicitly authorized historical P2-S8 package was inspected: directory
entries, retained manifests/inventories and their coherence hashes. No external
reference was followed; no mapping records, source archive or SQLite payload was
opened, and no occurrence/crosswalk command was executed.

The package exists. Retained acceptance/metadata repeat the tracked registry
revision 6/hash, accepted source archive identity and runtime data version/hash;
checked inventory/configuration/acceptance files match their package-manifest
entries. This is internal manifest coherence, not fresh verification of referenced
artifact bytes or independent authentication of the package manifest.

| Required role | Bounded assessment |
|---|---|
| Authoritative registry | `ROLE_PRESENT_BUT_INSUFFICIENT_METADATA`: expected revision/hash recorded; authoritative path is an external reference, not an available verified file within this authorized package. |
| Approved station assignment/attachment records and review-file hash | `ROLE_PRESENT_BUT_INSUFFICIENT_METADATA`: inventory contains an external station-record reference with hash metadata; exact current CLI role/schema/approval and file bytes are unverified. |
| Accepted source/input provenance | `ROLE_PRESENT_BUT_INSUFFICIENT_METADATA`: accepted archive identity is inventoried externally; required member provenance is not established by inspected metadata. |
| Immutable history/dependencies | `ROLE_PRESENT_BUT_INSUFFICIENT_METADATA`: external history references are inventoried, not opened or certified as required closure. Current tool supports schema-2 baselines only; no additional history input may be invented. |
| Exact stops.txt member hash | `ROLE_NOT_PRESENT` in the inspected retained manifest metadata; no archive was opened to derive it. |

No substitute registry, adapter-test copy or SQLite resolver was used. External
reference availability remains unknown, not disproven. Overall immediate readiness
is **MISSING_REQUIRED_MAPPING_ARTIFACT** within this authorized root; re-identifying
references is not permission to access their targets.

Historical ordered-key verdict: **NO_HISTORICAL_ORDERED_KEY_ARTIFACT_BY_DESIGN**.
`Tools/TripNomination/README.md` specifies a memory-only review with no file,
worksheet, exported result or retained annotations. The owner-reported occurrence
checkpoint establishes aggregate findings, not a retained exact fourteen-key input.
No key-file search or reconstruction was attempted.

A later synthetic-only slice therefore also needs
**NEEDS_OCCURRENCE_TO_CROSSWALK_BRIDGE**. Prefer one process: reuse unchanged
`read_occurrences` once with explicit same-candidate confirmation, exact archive
identity, expected count 14 and inversions 0; recheck the accepted profile's explicit
0/0 fields and preserve every ordered stop_id scalar and repetition. Never print
source associations, keys, locators or canonical IDs. Do not infer Passenger status
from generic GTFS semantics or accept count/inversions as candidate authentication.

Smallest proposed cross-language boundary: an explicit, locally built in-process
Swift library entry point, loaded by the Python owner-terminal orchestrator, sharing
the existing crosswalk verifier and checked registry/review inputs. Pass bounded
versioned key JSON in memory through a narrow C ABI (no subprocess, pipe or temporary
key file); compute its hash from those same reader-produced bytes, with source/archive
identity tied to the validated reader result. Reuse exact-key decoding, closure and
final artifact checks; return only fixed errors/aggregate counts, with no private
pointers/results exposed. This changes key-input provenance from an independently
supplied file hash to the validated same-candidate reader, so requires explicit
synthetic implementation authorization and independent review before real use.

Synthetic scope: boundary/lifetime/length tests, exact Unicode/order/repeat tests,
identity/count/inversion/profile failures, all-or-nothing closure, no writes/leaks,
no subprocess/network and no retry after access. Preserve existing reader/verifier
regressions. Do not port the occurrence parser, weaken the current file-based CLI,
create persistent keys, add dependencies, infer mappings, emit Trips or expand
later-phase work. An ephemeral key artifact is deferred because in-process reuse
is feasible in principle; feasibility must be proven synthetically, not assumed
ready. No bridge implementation, tests/builds or real re-read occurred here.

The mapping grant remains **unconsumed**; the earlier occurrence grant remains
consumed. Classification stays **0 gaps**, source order **resolved**, crosswalk
**0 verified / 14 held**, P2-S9/P3-T1 incomplete, Phase 3 In Progress and live/default
routing unconfigured. Next: separately authorize exact external mapping-role access
and the bounded synthetic bridge slice, then review before a new explicitly scoped
same-candidate occurrence-plus-crosswalk execution. No current grant is broadened.

#### Exact manifest-referenced mapping dependency rebinding — 2026-10-08

A separately authorized read-only prerequisite assessment followed **five unique
external file references** already present in the retained historical package
inventory/configuration. No external directory was enumerated, alternative copy
sought, unrelated reference chain followed, archive member decompressed or real
occurrence/crosswalk command executed. The preceding 395 added ROADMAP lines and
six-file unstaged implementation/documentation scope remain intact.

| Required role | Current bounded result |
|---|---|
| Mapping registry | `AVAILABLE_IDENTITY_MATCHED`: regular, owner-only, non-symlink path; bytes match the already tracked revision-6 registry hash; schema 2/revision 6 header matches. |
| Cross-operator station review/assignment records | `AVAILABLE_IDENTITY_MATCHED`: regular, owner-only, non-symlink path; bytes match the retained inventory hash; schema 1 and expected review-file structure/input archive identity match. This is not fourteen-item closure verification. |
| Toei source archive identity | `AVAILABLE_IDENTITY_MATCHED`: exact inventoried archive bytes match the accepted archive hash; read only for identity, with no GTFS rows parsed. |
| stops.txt member identity | `INSUFFICIENT_ACCEPTED_METADATA` / **STOPS_MEMBER_IDENTITY_MISSING**: the exact referenced source-manifest file is a fingerprint inventory, not an accepted member-hash manifest; no required member hash was established. |

The five references comprise registry, cross-operator review records, archive,
source-manifest metadata and one initially selected metadata record. The latter
proved to be acquisition metadata rather than station-review evidence and was
rejected for that role; the separately inventoried cross-operator review reference
supplied the actual review-file identity. No substitute was inferred or created.
All five files matched their retained inventory identities. Current schema-2
verification requires no separate immutable history-file input; no history targets
were followed. Required assignment-member closure remains for the future verifier.

Readiness verdict: **MAPPING_DEPENDENCY_METADATA_GAP**. Mapping files are available
at their accepted references; the remaining mapping-side blocker is an accepted
stops.txt member identity, not missing ordered keys. No archive was decompressed
to manufacture that identity, and no registry provenance values were mined as a
substitute accepted manifest. Future authority must explicitly identify accepted
member metadata or authorize a bounded identity derivation; do not broaden this task.

JSON parsing for minimum schema/revision/role/input checks necessarily brought
mapping/review values into process memory, but no provider-reference pair,
assignment member, decision or canonical ID was selected, displayed or persisted.
No private paths, new private hashes or mapping contents enter this checkpoint.

Ordered-key status remains **NO_HISTORICAL_ORDERED_KEY_ARTIFACT_BY_DESIGN**.
The in-memory bridge remains separately scoped, unimplemented and not yet ready;
its architecture choice is deferred until the mapping-side prerequisite is closed.
The mapping one-use grant remains **unconsumed**; no occurrence grant was renewed.
Classification remains **0 gaps**, source order **resolved**, crosswalk
**0 verified / 14 held**, P2-S9/P3-T1 incomplete, Phase 3 In Progress and live/default
routing unconfigured. No code, build/test, publication or Git-index operation occurred.

#### Registry-contained member provenance correction — synthetic-only overlay (2026-10-08)

The preceding **MAPPING_DEPENDENCY_METADATA_GAP** was traced to redundant external
member-hash input in the new verifier, not absent provenance in the accepted model.
DEC-068 §C3 and `SourceReference` already bind GTFS archive/member identity, table,
field and exact provider key; DEC-069's typed assignment sides require consistent
member provenance. The earlier assessments remain historical evidence, not a new
requirement to derive a member hash from real source bytes.

The synthetic verifier now removes `--stops-sha256`. It first verifies the complete
registry hash, supported schema and expected revision, then uses contained reviewed
local provenance. Requested active station bindings must match the supplied archive,
GTFS form, `stops.txt`, valid member SHA-256, `stops` table, `stop_id` field and exact
key. All provenance-valid requested occurrences must share one member identity;
disagreement yields typed `inconsistentMemberIdentity` for every participating
occurrence, no private canonical results or prospective indices, and no ready proposal.
Missing/malformed provenance rejects in the existing decoder or holds with fixed
typed outcomes. Assignment/attachment/member closure and all input guards remain.
Member hashes are private/internal and do not enter aggregate CLI output. This is
accepted local mapping provenance, not independent publisher authentication.

No real registry, reviews, archive, member hash or mapping was accessed or derived
for this correction. Based on the preceding bounded rebinding evidence, the
external-member-metadata blocker is removed by the corrected contract; this does
not freshly reauthenticate artifacts or verify any of the fourteen mappings.
The remaining tooling prerequisite is the separately authorized synthetic
occurrence-to-crosswalk bridge, followed by its verification/independent review and
separately scoped real same-candidate execution. Ordered keys remain
**NO_HISTORICAL_ORDERED_KEY_ARTIFACT_BY_DESIGN**. No bridge is implemented here.

Final synthetic verification: `sh Tools/StaticDataIntake/build.sh` passed;
`TEST_FILTER=crosswalk sh Tools/StaticDataIntake/test.sh` passed **41 / 0 failures**
(39 focused crosswalk cases plus 2 existing matches). The unchanged name-prefix
selection for minting/grouping/revision/provisional-registry/station regressions
passed **82 / 0 failures**, including one overlapping crosswalk case; all 78
intended existing suite cases passed. Overlapping runs are not summed. No warnings
or skips were reported, and temporary fixture roots were removed. The final CLI
works without the removed flag and rejects that flag without echoing its value.
The initial run's two failures were a sorted-reference fixture indexing error and
an old CLI binary exercised before the optimized build finished; both were corrected
and the final stable run passed. Independent non-author review approved actual
code/tests/contracts/docs with no material findings; no app/iOS build was required.

The mapping grant remains **unconsumed**, classification **0 gaps**, source order
**resolved**, crosswalk **0 verified / 14 held**, P2-S9/P3-T1 incomplete, Phase 3
In Progress and live/default routing unconfigured. Preserve all 440 preceding
added ROADMAP lines and leave implementation/documentation unstaged and uncommitted.

#### In-memory occurrence-to-crosswalk bridge — synthetic implementation (2026-10-08)

The missing historical ordered-key artifact is intentional: the prior occurrence
review was memory-only. The authorized bridge therefore keeps keys in process
memory and introduces no key worksheet, temporary key file or persisted crosswalk.
The unchanged Python occurrence reader calls the shared Swift verifier through a
narrow version-1 C ABI loaded by standard-library ctypes. Existing standalone
file-based review remains supported as a thin adapter to that same verifier core.
No duplicate mapping semantics, new third-party dependency, Python embedding,
subprocess, shell/pipe/stdout IPC, network or real-data composition was introduced.

The explicit ignored dylib is hash-checked and loaded through its held descriptor;
ABI version/state mismatches reject. Bounded big-endian length-delimited UTF-8
framing preserves order, scalar distinctions and repeats; malformed lengths, UTF-8,
counts and trailing bytes reject. C inputs remain caller-owned valid buffers;
only fixed statuses and eight aggregate words cross back, never canonical IDs.
The owner wrapper reuses the terminal guard, reads the same supplied candidate
exactly once, enforces archive identity, 14 occurrences, zero inversions and the
explicit accepted-profile 0/0 fields before mapping. Core provenance and complete
review closure checks are shared; no private pair or prospective index is printed.
Cleanup discards references and clears owned mutable buffers, not secure OS-memory
erasure. No retry or alternate artifact discovery is available.

Synthetic verification: optimized standalone and ABI-library builds passed;
`TEST_FILTER=crosswalk,bridge sh Tools/StaticDataIntake/test.sh` passed **44 / 0**
(39 crosswalk, 3 new Swift framing, 2 existing matches), with final standalone CLI
rerun **1 / 0**. Python actual-FFI bridge tests passed **17 / 0**; unchanged occurrence
reader (30) and review-session (15) regressions passed **45 / 0**. The same bounded
mapping name-prefix selection passed **82 / 0**. These overlapping runs are not
summed; no skips or warnings were reported and fixture roots were removed. Initial
compile closure syntax and a NUL-containing archive fixture were corrected; the
reader's NUL rejection was preserved and explicitly tested. No iOS build was needed.

Independent non-author final review inspected actual code, framing, ABI loading,
tests/assertions, saved results and contracts, and approved with no material
findings. It confirmed in-memory-only keys, preserved order/repeats, bounded valid-
pointer FFI, no persistence/IPC, no canonical-ID output and separate real-use gates.
The bridge is ready for separately authorized real execution once local inputs
and required grants are established; this is not real mapping acceptance.

No real/private artifact or candidate was accessed. The existing mapping grant
remains **unconsumed**; the consumed occurrence grant is not renewed. Eventual real
execution requires a **new same-candidate occurrence-read authorization**, existing
mapping authorization or an explicitly consolidated replacement, and exact approved
private paths/label/identities supplied locally. Synthetic success grants no real
acceptance. Crosswalk remains **0 verified / 14 held**, classification **0 gaps**,
source order **resolved**, P2-S9/P3-T1 incomplete, Phase 3 In Progress and live/default
routing unconfigured. Preserve the preceding 488 added ROADMAP lines; all work
remains unstaged/uncommitted and no binary is tracked.

#### First atomic real bridge result and code-only post-mortem — 2026-10-08

Scope: owner-reported aggregates, repository contracts/current implementation and
invented synthetic reproduction only. No real private artifact was reopened for
this checkpoint and no real execution or retry occurred. The owner reports that
the consolidated atomic one-use occurrence-to-crosswalk grant was exercised and
is **consumed**. There is **no retry authorization** and no new grant.

The same retained 14-occurrence candidate was re-established: **14/14 Passenger
profile matches**, source order preserved, **0 repeated occurrences**, and registry
identity matched. Canonical crosswalk did **not** pass: **14 requested, 0 resolved,
14 held**, review evidence matched **false**, member identity consistent **false**,
and ready for private crosswalk **false**. No partial mappings are accepted.
Canonical crosswalk remains **0 verified / 14 held**; classification remains
**0 gaps**, P2-S9/P3-T1 incomplete, Phase 3 In Progress and live/default routing
unconfigured. Prior accumulated checkpoints are retained as historical records;
their unconsumed-grant statements precede this consumed execution.

Code-only causal finding: resolved counts only fully accepted per-occurrence
outcomes; held is requested minus resolved. Readiness requires every outcome to
resolve. The bridge sets both evidence-match and member-consistency booleans to
that same readiness value, rather than computing independent diagnostics. Thus
the false member-consistency flag does **not** prove conflicting member hashes,
and false evidence-match alone does **not** identify an evidence failure. Any held
outcome makes all three booleans false, even when other mappings resolve. A shared
missing assignment/dependency or requested member disagreement can hold all items.
Artifact hash/schema/revision failures instead produce a fixed fatal category.

**Primary verdict: VERIFIER_DEFECT_IDENTIFIED.** DEC-068 §C1 defines permanent
introducing attachment authority; DEC-069 §D1 accepts reviewed station formation;
DEC-082 §2 requires active exact canonical mapping. The accepted station producer
creates distinct per-reference introducing review IDs, while the new verifier
requires those IDs to equal a station-assignment review ID and every dependency
to share that ID. This is stronger than the accepted contract. An invented run
through the original station acceptance path produces active resolvable references
with complete assignments which the verifier then holds as missing evidence.
This proves a verifier compatibility defect, **not the root cause of the real run**.

Invented actual-FFI reproduction also produces the reported 14-requested/0-resolved/
14-held signature for distinct causes: producer-shaped authority IDs, missing
closure, review-ID mismatch, wrong target, missing assignment dependency, source
revision mismatch, inactive references and member disagreement. The same signature
therefore cannot distinguish those causes. A valid one-sided station assignment
needs no cross-operator `same`; two-sided assignments require the exact reviewed
`same`. Wrong-role artifacts rejected at decoding cannot explain a normal held
aggregate, though a structurally valid artifact lacking applicable assignments can.
No repository-only proof establishes that the rebound real artifact has the wrong
role or that the accepted baseline is intrinsically incompatible.

Smallest next step: separately authorize a synthetic-only verifier correction that
matches exact assignment membership/target/provenance without equating assignment
and introducing authority IDs, preserving permanent authority and all existing
identity, active-state, provenance, member and applicable `same` checks. Do not strip
ID suffixes or invent attachment authority for legacy references. Legacy optional
attachments need explicit compatibility coverage. No verifier correction is made
here. Any eventual real diagnostic/read requires separate owner authorization;
typed aggregate reason counts only would distinguish remaining causes without pairs.

Verification: focused Swift synthetic checks **4 passed / 0 failed**, including
the actual accepted-producer characterization, assignment dependencies, requested
member disagreement and applicable merged-station evidence. One focused Python
actual-FFI test passed all **8 causal subcases** plus its valid baseline. Initial
Swift compilation hit the sandbox's default module-cache write restriction; a
temporary module cache resolved it. No broad suite, iOS build or device step was
run. Independent non-author review approved the checkpoint, defect proof, invented
reproductions and verdict with **no material findings**. Only this checkpoint and
the two invented test additions changed in this task; implementation is unchanged.

#### Synthetic verifier compatibility correction and ABI 2 — 2026-10-08

The owner authorized only synthetic correction/verification after the preceding
proven compatibility defect. The unsupported equality between introducing attachment
review IDs and station-assignment IDs is removed, including the shared-ID dependency
requirement. Exact scalar source/member coverage selects the assignment; its target
must equal the reference target. All active-state, archive/member/table/field and
exact-key checks remain, with no names/codes/coordinates/topology fallback. One-sided
assignments need no cross-operator merge; two-sided assignments require exact reviewed
`same` and valid accepted typed decision fields. Original source-backed grouping and
candidate acceptance remain premises of the supplied approved artifact, not evidence
recomputed from source archives.

Introducing authority remains the approved registry/history's permanent optional
value. It is neither rewritten nor inferred from assignment IDs, and absent historical
authority never bypasses closure. The original accepted producer regression now
passes with distinct per-reference authority IDs. An unchanged producer replay also
preserves optional legacy absence and verifies successfully. Malformed authority is
schema-rejected and altered authority bytes fail the approved registry hash. A
well-formed opaque ID cannot be independently authenticated by the assignment file
alone; no new authority discovery, naming convention or history policy is introduced.

Evidence/member diagnostics now report independent `matched`, `mismatched` or
`notEvaluated` statuses. Evidence checks begin only after valid active requested
provenance; evaluated closure failure is a mismatch, while skipped checks remain
unevaluated. Any evaluated mismatch dominates; otherwise incomplete evaluation is
notEvaluated, and complete matching checks are matched. Member mismatch specifically
means usable requested member identities disagree; complete consistent coverage is
matched, otherwise notEvaluated. Review closure can match while requested member
identities disagree across separate assignments; member identity can match while
review closure fails. Readiness still requires every occurrence resolved, with no
partial accepted crosswalk.

ABI **2** changes both frame version and review symbol, retaining bounded synchronous
caller-owned buffers and eight POD output words. Independent diagnostic enums use
0 notEvaluated / 1 matched / 2 mismatched; registry/ready remain Booleans. Python
rejects ABI 1 libraries/frames and invalid enum/ready output, returning only aggregate
counts and status strings. No keys, canonical IDs, member hashes or pairs return
from Swift. The standalone adapter uses the same corrected core and status semantics.
Both tool READMEs document the new contract and authority-premise limits.

No real private artifact was reopened, no real mapping was resolved, and no real
retry occurred. The previous atomic one-use grant **remains consumed**; there is no
new grant. Synthetic acceptance does not rewrite the failed real run or prove its
cause. Canonical crosswalk remains **0 verified / 14 held**, classification **0 gaps**,
source order **resolved**, P2-S9/P3-T1 incomplete, Phase 3 In Progress and live/default
routing unconfigured. A new real atomic execution remains separately owner-gated,
with a freshly recomputed library hash and fresh bindings for the rebuilt ABI 2 tool.
All accumulated work remains unstaged/uncommitted; historical checkpoints are intact.

Verification: optimized standalone CLI and ABI 2 library builds passed. Focused
Swift crosswalk/framing/bridge tests passed **48 / 0** (43 crosswalk, 3 framing and
2 existing name matches), including accepted producer and legacy replay. Python
actual-FFI tests passed **20 / 0**, including the eight causal subcases, independent
status directions, old ABI rejection and invalid diagnostic-word rejection. The
previous exact mapping selection passed **82 / 0**, covering affected accepted
producer/assignment regressions. These overlapping runs are not summed. Fixture
roots were removed; no warnings/skips, broad suite, occurrence rerun, iOS build or
device work. An initial compile was invalidated by test edits during compilation;
a frozen-source rerun passed. An intermediate CLI assertion used the old output
binary; rebuilding the CLI resolved it and the final focused run passed.
Independent non-author final review approved contracts, exact closure, authority,
independent diagnostics/ABI, actual assertions, logs and documentation with **no
material findings**. Drift audit: only the verifier/bridge, their three test files,
two tool READMEs and this overlay changed in this task; no shared producer/model,
occurrence reader, dependency, feature or publication change. Corrected tooling is
synthetically ready for a newly authorized atomic execution; a new owner grant,
recomputed library hash and fresh local bindings are still required. No such
execution or binding preparation is performed here.

#### Corrected ABI 2 owner-operated real crosswalk success and remaining gates — 2026-10-08

Scope: sanitized evidence recording and repository-only remaining-gate audit. The
owner reports exactly one corrected ABI 2 execution in the separately authorized
private local environment. Codex did not observe that terminal, inspect private
pairs or independently authenticate them. No real artifact was reopened, bridge
rerun, registration performed or timetable imported for this documentation task.
The new independent atomic one-use grant **is consumed**; the earlier grant remains
consumed too. There is no retry or additional real-data authorization.

| Owner-reported aggregate | Result |
|---|---|
| Occurrences / accepted Passenger profile matches | **14 / 14** |
| Requested / resolved / held mappings | **14 / 14 / 0** |
| Registry identity matched | **true** |
| Review evidence status | **matched** |
| Member identity status | **matched** |
| Source order preserved / repeated occurrences | **true / 0** |
| Ready for private crosswalk | **true** |

Under the already accepted source/revision Passenger profile, complete occurrence
review and this owner-reported corrected verification, the exact retained candidate
now has **14 verified / 0 held** canonical mappings: **canonical mapping/crosswalk
gaps: 14 → 0**. Classification remains **0 gaps** (14 Passenger, 0 Passed, 0 Unknown);
source-order ambiguity remains **resolved** and is reconfirmed. This closes the
complete private source-to-canonical correspondence for this candidate only, not
other runs, feeds, revisions or current operation. No actual pair, ordered station
sequence, provider/canonical value, private path, member hash, locator or transcript
is recorded here.

The private crosswalk is deterministically **constructible** with prospective
passenger original indices **0...13** in the already reviewed source order. This
is not a persisted crosswalk, registered/persisted canonical Trip or accepted full
immutable Trip snapshot. Original indices identify visits even when other runs
repeat stations; zero repetitions is an observation, not a construction prerequisite.

The historical chain above remains intact: the first ABI 1 real run correctly held
all 14 mappings; the subsequent code-only post-mortem proved verifier overconstraint
and a compatibility defect; independent review approved the synthetic ABI 2 correction;
a new separately authorized owner-operated execution then resolved all 14. The
successful result does not retrospectively identify the first run's exact failure
path or rewrite it as successful. Earlier 0-verified/14-held statements are historical,
not the current bounded mapping status.

**Candidate-specific obligation audit.** Authority: Accepted DEC-082 §§1–4/6,
DEC-083 acceptance and §§A–D, DEC-084's later A/B/C1/C2 implementation/approval
overlays and §§B–D; ARCHITECTURE §§39–41; the dated P2_S9_REAL_READINESS matrix and
ordered path, read together with subsequent evidence checkpoints above. Earlier
unimplemented/synthetic-slice-pending text does not override later approvals.

| Obligation | Current disposition and exact remaining boundary |
|---|---|
| Fixed source identity and interpretation | Identified retained candidate/source revision and accepted resource-specific Passenger/order interpretation are already established review premises. No new authenticity, custody, currency, rights or feed-wide coverage claim is supplied by hash matching or this task. |
| Complete occurrence classification and source order | **Satisfied in the prior separately authorized owner-reported occurrence review**, now reconfirmed: 14 Passenger occurrences, 0 classification gaps, unambiguous reviewed order and no repeated occurrence observed. Do not reopen these resolved questions. |
| Exact canonical station correspondence | **Satisfied by this owner-operated private real review result:** all 14 active mappings, reviewed assignment closure and member consistency match in the identified station mapping baseline. Prospectively indexed private crosswalk is constructible; no persisted output or complete Trip view is implied. |
| Recurring-run correspondence / Trip identity | **Unresolved; blocked by missing candidate-specific real evidence/access.** No accepted same-run/distinct-run correspondence, competing-assignment disposition or proposed registered target is established by the recorded evidence. Equal stops, successful mapping or a source key alone cannot supply it. |
| Source-key authority and continuity | **Unresolved; blocked by missing applicable evidence/profile and access.** DEC-083 requires publisher/resource/feed scope, key uniqueness, recurring meaning and continuity limits. The accepted Passenger/order profile does not establish a recurring-key profile. Returning/renamed/fragment continuity requires affirmative evidence only where applicable; do not presume a returning operation. No new general identity-policy decision is shown missing. |
| Line membership, movement and boundaries | **Unresolved candidate evidence, not a missing segment contract.** Accepted station/line foundation and station crosswalk do not prove each movement interval's active LineID, membership, traversal/boundary or compatible full view. No route-key/topology fallback or fragment stitching. Any through join needs its own applicable same-run continuity evidence. |
| Service origin/destination and service type | **Unresolved independent boundary dispositions.** True requires affirmative endpoint evidence; false may retain explicitly unknown external extent without claiming continuation. No new decision or mandatory proof of both terminals is required merely to use that accepted lower claim. Interior completeness still holds; unsupported service type may remain empty, never inferred. |
| Provisional Trip registration | **Accepted contract and synthetic components already satisfied; real workflow/execution not authorized or established.** DEC-083 permits only separately owner-approved checkpoint-bound initial allocation/attachment or snapshot revision. DEC-084 A/B/C1/C2 are implemented/approved for invented inputs; no generic synthetic redo is needed. No real allocator/writer, conversion or mutation permission follows. Ordinary schema-2/2–3 readers still do not register Trips. |
| Registry/checkpoint compatibility | **Unresolved real checkpoint/history/approval evidence and real-use boundary.** Station revision matching alone proves no compatible Trip lineage, complete retained authorities/IDs, predecessor/selection or schema-4 conversion. Any required lossless conversion and registration tooling needs separate real-use design/authorization, followed by the exact owner-approved request; do not reset lineage or create a side registry. |
| Immutable snapshot/evidence and final S9 acceptance | **Unresolved downstream assembly/review/reproduction gates.** Require coherent source/mapping/profile/review bindings, actual registered target, all applicable identity/movement/boundary proof roles, immutable full untimed snapshot/crosswalk/predecessor evidence, independent review and owner acceptance for the declared scope. The bridge emits aggregates, not those persisted artifacts. Full-content reproduction is not established by the single aggregate success. |

**Next-step verdict: NEXT_TASK_BLOCKED.** The first unresolved gate is a
**candidate-specific recurring-run identity/source-key evidence review**, not another
crosswalk run, generic synthetic slice or real registration. Its exact missing
prerequisite is applicable authoritative evidence for scoped key uniqueness, recurring
meaning and continuity limits, plus candidate correspondence/competing-assignment
support and new explicit bounded access authority for the exact existing evidence.
The repository does not establish that this evidence is available. The completed
mapping grant cannot be reused to inspect it; do not discover files or infer identity.
After that prerequisite, the bounded review can accept an applicable profile and
owner-approved same/distinct-run correspondence or explicitly hold conflicts/gaps,
without minting, registration, timetable interpretation or publishing private values.
No extra generic policy decision or unblocked implementation task is manufactured.
This prompt does not perform that next review, acquire evidence or create access.

P2-S9 remains **incomplete**, not acceptance-ready; P3-T1 real import remains
**incomplete**, Phase 3 **In Progress**, and live/default routing **unconfigured**.
Production registry adoption, rights/publication/delivery, launch-wide coverage and
consumer revalidation remain separate. Only ROADMAP changes; historical evidence,
implementation/tests and all other accumulated work are preserved unstaged/uncommitted.
No app/synthetic tests or builds are run for this documentation-only task.

Verification: complete accumulated diff, headings/authority references, current-state
and privacy/non-restorability checks and `git diff --check` passed. All earlier
ROADMAP bytes and the other eleven intended files are unchanged by this task;
canonical literals in accumulated new files remain confined to invented tests.
Independent non-author documentation review approved the complete accumulated
ROADMAP/tool-README diff and next-gate verdict with **no material findings** after
owner-report attribution and first-run causal wording were tightened. No tests/builds.

#### Public GTFS recurring-key profile assessment — 2026-10-08

**Verdict: SOURCE_PROFILE_SUPPORTED_FOR_OWNER_APPROVAL. Proposed / awaiting owner
acceptance; not applied to the retained candidate.** Scope is public-document and
repository assessment only. No private artifact/key/calendar/registry was opened,
bridge executed, provider contacted or Trip allocated/registered. The previous
atomic grants remain consumed. No code, DEC, tests/builds or publication changes.

Authority reviewed: Accepted DEC-060 §A, DEC-082 §3, DEC-083 acceptance/§§A–D,
DEC-084's later approved A/B/C1/C2 overlays, ARCHITECTURE §§39–41 and the readiness
assessment together with subsequent checkpoints. No later accepted record establishes
this exact recurring-key profile; the accepted Passenger/order profile is separate.
Public authority: official [GTFS Schedule Reference](https://gtfs.org/documentation/schedule/reference/),
revised April 27, 2026: [field types](https://gtfs.org/documentation/schedule/reference/#field-types),
[dataset files](https://gtfs.org/documentation/schedule/reference/#dataset-files),
[trips](https://gtfs.org/documentation/schedule/reference/#tripstxt),
[calendar](https://gtfs.org/documentation/schedule/reference/#calendartxt),
[calendar exceptions](https://gtfs.org/documentation/schedule/reference/#calendar_datestxt),
[frequencies](https://gtfs.org/documentation/schedule/reference/#frequenciestxt) and
[stop times](https://gtfs.org/documentation/schedule/reference/#stop_timestxt).
Official [Schedule Best Practices](https://gtfs.org/documentation/schedule/schedule-best-practices/#dataset-publishing--general-practices)
was also checked for publishing/identifier recommendations; recommendations do not
establish a trip-key continuity guarantee.

**Evidence assessment:** `trips.trip_id` is the primary key and a Unique ID (unique
within its file), not a global or cross-revision identifier. GTFS defines a trip
as two or more stops during a specific time period. `trips.service_id` references
calendar/calendar_dates service-date sets, allowing the same trip definition on
multiple dates without a separate trip row per date; it does not guarantee that
any particular row operates on multiple dates. Calendar exceptions modify/add/remove
dates. `frequencies.txt` can encode multiple departures under one trip key, including
compressed scheduled service (`exact_times=1`); flexible/on-demand rows also need
separate interpretation. No same-key continuity or changed-key distinctness guarantee
across revisions was found. The following eligibility limits are therefore necessary,
not a finding about the unopened retained feed.

**Exact proposed owner profile:**

- Scope: Tokyo Metropolitan Bureau of Transportation / Toei, existing DS-01 resource
  `35b68908-4558-47ae-bfa5-867e58544a1a`, retained `feed_version 20260921`, archive
  SHA-256 `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`,
  member `trips.txt`, namespace `gtfs.trip_id`. These are retained repository source
  premises, not newly authenticated evidence; a hash pins bytes, not run identity.
- Keys are exact Unicode-scalar values under DEC-083; no trimming, normalization,
  suffix parsing or structural-key substitution. GTFS-conformant `trip_id` uniqueness
  identifies at most one trip record within this exact dataset revision only; actual
  conformity/uniqueness must be established before candidate application.
- One eligible row denotes one fixed-schedule GTFS trip definition associated by
  `service_id` with its service-date set. Only a separately evidenced ordinary scheduled,
  non-frequency, non-flexible/on-demand definition of one departure per service date is
  eligible. All `frequencies.txt` variants (including `exact_times=1`), multiple-departure
  templates and flexible/on-demand variants are excluded unless separately evidenced
  and separately approved. Unknown eligibility holds application; this task proves none.
- Within this revision only, an eligible exact key may supply source-semantic evidence
  for one DEC-060 recurring scheduled-run candidate, not a dated execution or merely
  a stopping pattern. No actual calendar dates or times are interpreted here.
- Continuity limit: **none across feed revisions without new affirmative evidence**.
  Same spelling across revisions does not prove the same canonical Trip; changed
  spelling does not prove a distinct Trip. Future attachment/reuse requires new
  affirmative correspondence/continuity evidence and review. Retain the existing
  sourceID/key/history; this revision limit authorizes no per-revision sourceID,
  namespace reset or bypass of held keys, returning-reference rules or reuse blocks.
- This profile establishes source semantics only. It approves no candidate correspondence,
  canonical target, allocation, registration, snapshot, real access or production use.

**Contract fit and remaining evidence:** these bounded semantics are sufficient to
propose an eligible within-revision recurring-run candidate under DEC-060, not to
assign its TripID. Separate published departures remain distinct even with identical
patterns; possible fragments/through continuity are not settled by one row. DEC-083
requires evidenced continuity *limits*, not a promise of continuity everywhere; a
none-across-revisions boundary is compatible, while returning attachments still require
affirmative continuity. No new DEC or relaxed invariant is needed for this proposal.
The original profile's recurring-run inference is supported only with the eligibility
qualification above; it is not valid for every generic GTFS trip row.

After exact owner profile acceptance, a separately authorized candidate review must
prove source/profile applicability and eligible single-departure meaning, retain exact
source/review/evidence versions, and establish affirmative same-run or distinct-new-run
reasoning against competing assignments and prior bindings in an identified previous
registry/checkpoint/hash. A first provisional allocation still needs an explicit
owner-approved distinct-new-run allocation request and exact approved correspondence
record (reviewer/authority, approval time/digest and relevant S9 references). No such
checks are performed here. If proving identity needs time interpretation, hold for
separate authorization; never infer identity from pattern, chronology or key spelling.
Real-use tooling/checkpoint compatibility, movement/coverage/full immutable snapshot,
independent reproduction and final S9 acceptance remain the separate gates above.

**Owner-decision boundary:** accept or decline precisely this source-profile proposal;
acceptance alone grants neither candidate application nor private access. Public semantics
advance the evidence blocker, but profile acceptance, candidate eligibility/correspondence
and new bounded access remain outstanding. Canonical crosswalk stays **14 verified /
0 held**, classification **0 gaps**, source order resolved. P2-S9 and P3-T1 remain
**incomplete**, Phase 3 **In Progress**, live/default routing **unconfigured**.

Verification: full accumulated tracked diff inspected; new checkpoint privacy/state and
reference checks plus `git diff --check` passed. All earlier ROADMAP bytes and the
other eleven files are preserved. No private source key was added. Independent
non-author public-source/DEC-060/083/profile review approved with no material
findings after a section-anchor correction; it does not authenticate candidate data.
No tests/builds or device operations; index remains empty and all work uncommitted.

#### Owner acceptance overlay — retained Toei recurring-key source profile — 2026-10-08

**Current authority: Accepted source profile under DEC-083.** The owner explicitly
accepts exactly the bounded profile in the preceding reviewed assessment. This overlay
supersedes only its Proposed/awaiting-owner-acceptance status and profile-acceptance
blocker; that assessment remains unchanged as historical public-evidence review.
Official GTFS semantics are the cited evidence; owner acceptance supplies profile
authority; candidate-specific application remains **pending and unperformed**.
This is a source-specific approval within DEC-083, matching the established ROADMAP
profile-overlay convention; no new DEC or amendment to DEC-060/083/084 is required.

**Exact accepted scope:** Tokyo Metropolitan Bureau of Transportation / Toei, existing
DS-01 resource `35b68908-4558-47ae-bfa5-867e58544a1a`, retained `feed_version 20260921`,
archive SHA-256 `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`,
GTFS member `trips.txt`, namespace `gtfs.trip_id`. The hash identifies retained bytes,
not recurring-run identity. Another provider/resource/revision requires separate
applicability review; no broader acceptance follows.

**Accepted semantics and eligibility:** keys remain exact Unicode-scalar values;
no trimming, normalization, case/width folding, suffix/substring interpretation or
structural-key substitution. The primary-key/Unique-ID contract supports uniqueness
only within the identified dataset revision. One trip row denotes one GTFS trip
definition; `service_id` associates it with its service-date set. Only a separately
evidenced ordinary fixed-schedule definition of **one departure per service date**
may provide source-semantic evidence for one DEC-060 recurring scheduled-run candidate,
not a dated execution or merely a stopping pattern. Actual conformity/uniqueness and
candidate eligibility are not established by this acceptance.

All frequency-based variants, including `frequencies.txt` with `exact_times=1`,
multiple-departure templates, flexible/on-demand service and other variants whose
recurring identity is not established under this bounded meaning remain excluded
unless separately evidenced and separately approved. Unknown applicability holds;
stop pattern, route, chronology, names and previous crosswalk success prove no eligibility.

**Accepted continuity limit: no continuity across feed revisions without new affirmative
evidence.** Same spelling proves no same canonical Trip; changed spelling proves no
distinct Trip. No automatic attachment/reuse/replacement follows. Future revisions
require new continuity/correspondence review. Existing sourceID/key/history, returning-
reference and provider-key reuse protections remain intact; no per-revision sourceID
or namespace may bypass held identity. Defining this unsupported boundary satisfies
the profile's continuity-limit requirement without promising continuity beyond evidence.

**Effect and remaining obligations:** the recurring source-profile acceptance blocker
is now **cleared for a separately authorized candidate-applicability/correspondence
review**. Only scope, within-revision uniqueness semantics, bounded recurring meaning,
eligibility exclusions and continuity limits are accepted. Actual candidate profile
membership/no-exception evidence, exact source-key conformity/uniqueness, calendar
interpretation, same-run/distinct-new-run reasoning, prior bindings/competing assignments
and exact owner-approved correspondence remain unproved. No canonical TripID, allocation
authority, registration, snapshot acceptance or production identity is established.
A first allocation still requires its explicit owner-approved allocation request;
later DEC-083/084 real workflow/checkpoint/registration/snapshot gates remain separate.

**Smallest next safe task:** separately scope and authorize a read-only review of
candidate applicability, eligible single-departure meaning, exact scoped key conformity/
uniqueness and recurring correspondence, with an explicit artifact/field/dependency
allowlist, identified previous registry/checkpoint and approved private/sanitized outputs.
Review prior bindings and competitors, retaining affirmative same/distinct-run reasoning
for subsequent exact owner approval. If time interpretation is necessary, hold for
separate authorization. No such review or allocation is authorized/performed here;
consumed grants remain consumed and no availability of private evidence is presumed.

#### Synthetic candidate-applicability verifier — 2026-10-08

The preceding attempt stopped at `PUBLIC_FIELD_SEMANTICS_REQUIRED` before editing or
accessing private material. The authoritative public GTFS field semantics supplied for this
continuation resolved that stop. The owner separately authorized implementation of a **synthetic-only** verifier for the
accepted profile above. It assesses an explicitly supplied nominated label against invented
archives only. `Tools/TripNomination/applicability.py` reads the candidate trip row, exact
same-revision key uniqueness, route/service associations, its 14 stop-time occurrences,
matching frequency rows, continuous pickup/drop-off route defaults and stop-time overrides,
pickup/drop-off modes, Flex windows/location references and applicable booking-rule
references. Results contain only counts, statuses and fixed typed reasons; outcomes are
`eligible`, `excluded` or `held`. No actual retained archive, source/member hash or private
identifier was opened or embedded in this implementation.

The independent review found and this continuation corrected header-position-dependent
trip-key counting, missing ordinary `stop_id` validation, and incomplete booking-rule
conditional checks. It also verified the route-wide scope of the continuous-default/window
restriction; that check now relates stop-time windows to the route of each trip without
opening service/calendar tables. The booking fields are exactly
`pickup_booking_rule_id` / `drop_off_booking_rule_id` referencing
`booking_rules.booking_rule_id`; `prior_notice_service_id` is allowed only with booking
type 2 and remains opaque. The structural interpretation follows the official [GTFS routes](https://gtfs.org/documentation/schedule/reference/#routestxt),
[stop_times](https://gtfs.org/documentation/schedule/reference/#stop_timestxt),
[booking_rules](https://gtfs.org/documentation/schedule/reference/#booking_rulestxt),
[location_groups](https://gtfs.org/documentation/schedule/reference/#location_groupstxt) and
[GeoJSON locations](https://gtfs.org/documentation/schedule/reference/#locationsgeojson)
reference: continuous-service enums/default inheritance and stop-time overrides; passenger
pickup/drop-off enums; mutually exclusive stop/Flex location references; paired pickup/drop-off
windows incompatible with arrival/departure times; route-level continuous-mode restriction
when windows are used; booking type structural requirements; and referenced Flex IDs. These
checks are deliberately limited to candidate applicability and relevant structures. They do
not interpret service calendars/dates or establish a general GTFS validity claim.

`Tools/TripNomination/test_applicability.py` generates invented ZIP/CSV/GeoJSON records and
checks ordinary eligibility, valid profile exclusions, malformed/unresolved holds, exact
scalar key behavior, candidate uniqueness and association, occurrence count/order, frequency
cases, stop-time overrides, terminal-interval handling, Flex/window combinations, booking
references, privacy-safe aggregates, archive identity, path safety and CLI terminal gating.
Focused verification passed **98/98** applicability tests with `python3 -B -W error`,
including execution of the invented-archive CLI in a controlling PTY; no warnings. The full
TripNomination suite passed **217/217** tests (98 new applicability, 119 pre-existing reader,
session, occurrence, review-session and bridge tests), zero failures/errors/skips and no
unexpected warnings. The independent non-author re-review verified the header-driven key count,
stop/Flex location requirements, booking-rule conditional fields, route-wide window restriction,
time syntax, privacy boundary and phase scope; it approved publication within the documented
bounded scope with no material remaining findings. This makes the tooling ready for a separately
authorized one-use real candidate applicability review only; it grants no real-input execution itself.
No real-data access, candidate-specific profile assertion,
calendar interpretation, correspondence review, canonical TripID, allocation, registration,
snapshot acceptance or S9 acceptance occurred. P2-S9/P3-T1 remain incomplete and Phase 3
remains In Progress. The changes are unstaged/uncommitted; no publication operation is part
of this task.

This implementation changes only the TripNomination verifier/tests, its README and this
ROADMAP overlay. No private artifact/key/registry/calendar, bridge, provider contact, Trip
allocation/registration, app build, device or publication operation is involved.
Canonical crosswalk remains **14 verified / 0 held**, classification **0 gaps**, source
order resolved; P2-S9 and P3-T1 remain **incomplete**, Phase 3 **In Progress**, live/default
routing **unconfigured**. All prior evidence and accumulated implementation are preserved
unstaged/uncommitted. Earlier first-run 0-verified/14-held statements in the bridge
README describe that historical stage; the corrected ABI 2 success checkpoint and
this overlay govern current status. Verification and separate non-author review follow.

Verification: accumulated tracked diff inspected, with byte-preservation checks for
all earlier ROADMAP content and the other eleven files. Heading/reference, privacy,
source-semantics/continuity/eligibility and current-state checks passed; no private
candidate key was added. `git diff --check` passed. Separate non-author review read
the complete accumulated ROADMAP and both tool-README diffs in bounded chunks and
approved the official-evidence/DEC-060/083/profile/acceptance boundary with no material
findings after the historical README-status clarification. No tests/builds were run.

#### Retained candidate real applicability checkpoint — 2026-10-08

The owner reports executing the reviewed applicability verifier **exactly once** under the
separately authorized atomic real-input grant. The real archive was accessed; that one-use
grant is **consumed**. This checkpoint records only the supplied sanitized aggregate result;
no further archive or private-artifact access is authorized or performed by this publication task.

| Applicability check | Owner-reported result |
|---|---|
| Candidate found | Yes |
| Exact source-key uniqueness | Established (`unique`) |
| Exact `trips.txt` row matches | 1 |
| Source occurrences | 14 |
| Route / service associations | Both present |
| Matching frequency rows | 0 |
| Frequency applicability | `matchedProfile` |
| Flex indicator count | 0 |
| Flexible applicability | `matchedProfile` |
| Hold/exclusion reasons | None (`[]`) |
| Final applicability | `eligible` |

**The retained candidate satisfies the Accepted Toei 20260921 `gtfs.trip_id` source-profile applicability requirements.**
The result establishes exact selection, one scoped trip-key row in the retained revision,
required route/service associations, no matching frequency-based definition, no applicable
excluded Flex/on-demand construct found by the reviewed verifier, and consistency of the
14-occurrence dependency. It makes the candidate eligible for recurring-identity correspondence
review under the Accepted source profile.

Current P2-S9 truth: classification **0 gaps**; source order **resolved**; station crosswalk
**14 verified / 0 held**; source profile **Accepted**; candidate applicability **eligible /
satisfied**. Recurring canonical Trip correspondence remains **unresolved**; Trip allocation
and registration were **not performed**. Movement, endpoints, snapshot and final S9 acceptance
remain **unresolved**. P2-S9 and P3-T1 remain **incomplete**, Phase 3 **In Progress**, and
live/default routing **unconfigured**.

This result proves no operating calendar dates, timetable times, cross-revision continuity,
same-canonical-Trip correspondence, distinct-new-run status, absence of competing assignments,
canonical TripID, allocation authority, registration, snapshot acceptance or production identity.
The next smallest gate is **candidate-specific recurring canonical correspondence /
competing-assignment review** under DEC-083, against an identified registry/checkpoint/history
baseline: determine any accepted binding and competitors, or the affirmative evidence for an
explicit distinct-new-run proposal, and the exact subsequent owner-approved correspondence /
allocation request required. That review is not performed here; timetable interpretation is
not the next gate, and no Trip is allocated or registered.

Preflight confirmed the previously approved implementation/test fingerprints unchanged;
the earlier **98/98** applicability and **217/217** combined evidence was initially reused.
The complete accumulated non-author publication review then withheld approval for three
bounded defects: duplicate frequency starts with differing ends were not held, inherited
continuous exclusions could omit their fixed reason, and malformed GeoJSON coordinates
could be treated as valid exclusion evidence. These were corrected with four regression
functions. The frequency primary key uses the selected trip plus exact start value, without
timeline interpretation. GeoJSON checks validate array nesting, finite numeric positions
and closed rings, not geometric topology or general GTFS validity. The prohibited candidate
label was removed from the preceding unpublished record and generated synthetically in tests.
The README now records the revised verification scope. Shared readers remain byte-identical.

The owner-reported real result above belongs to the previously reviewed verifier SHA-256
`769d2a6bf5500277c21f2152bd1917f627bc235eca0bd020135e785d8e3dfb5d`.
No revised-verifier real run occurred or is authorized; the grant remains consumed.
Fresh `python3 -B -W error` runs passed **102/102** applicability tests and **221/221** combined
TripNomination tests, including invented-archive CLI/PTY coverage, with zero failures/errors/
skips or unexpected warnings. The initial regression reproduction exposed the three defects;
an intermediate synthetic run also exposed a repeated-fixture setup error, corrected before
the final passing runs. No app build or device step was needed for this offline tool scope.

| Final publication file | SHA-256 |
|---|---|
| `applicability.py` | `c4cdd69fe475eff76d8ae9f469b68ae0e8be6db1b795fa777fab55bb3234054b` |
| `test_applicability.py` | `e1df523297a42a33747cc5593ac99cbb4caa310ad16e376348b6b14c68744986` |

The exact four-file publication scope remains the verifier, tests, README and ROADMAP.
Fresh independent non-author re-review **approved** the complete corrected four-file diff
with **no material remaining findings**. Complete diff/privacy review and `git diff --check`
passed; no private candidate values, paths or env contents were included. Preflight fetched
origin and verified the expected repository/branch, baseline HEAD/upstream at
`a38a785c9eeec602495c4588f65fb940269f0a34` (0/0), exactly four intended files, empty index
and unchanged main/origin-main at `e8a463d51f14b3cb1027960c63244b694579a71b`.
Exact staged-file verification remains required before the separately authorized commit
and normal Phase 3 branch push; no merge or force push is authorized.

#### Final published-verifier real revalidation — 2026-10-08

The owner reports **exactly one** authorized real revalidation using the final published
`applicability.py` bytes, SHA-256
`c4cdd69fe475eff76d8ae9f469b68ae0e8be6db1b795fa777fab55bb3234054b`.
The real archive was accessed; the atomic revalidation grant is **consumed**, with no retry
authorized or needed. This is owner-reported evidence, not a real execution by this audit.
The earlier pre-correction run above remains historical evidence.

All sanitized aggregate observations match that earlier result: candidate found; exact key
uniqueness `unique`; one exact trip-row match; 14 occurrences; route and service associations
present; zero matching frequency rows with `matchedProfile`; zero flexible indicators with
`matchedProfile`; reasons `[]`; applicability **`eligible`**. The final published-verifier
caveat is **closed**; candidate source-profile applicability is **satisfied under the current
published verifier**. No private label, source value, path or transcript is retained here.

Current candidate evidence: classification **0 gaps**; source order **resolved**; station
crosswalk **14 verified / 0 held**; `gtfs.trip_id` source profile **Accepted**; applicability
**satisfied**; final published-verifier real revalidation **eligible**. Recurring canonical
Trip correspondence remains **unresolved**; allocation and registration **not performed**;
movement, endpoint dispositions, immutable snapshot and final S9 acceptance **unresolved**.
P2-S9 and P3-T1 remain **incomplete**, Phase 3 **In Progress**, live/default routing
**unconfigured**. Applicability success does not approve identity or any remaining gate.

#### Repository-only real Trip correspondence-baseline audit — 2026-10-08

**Primary verdict: `FIRST_REAL_TRIP_ALLOCATION_PATH`.** The accepted project baseline/history
contains no real Trip-capable canonical checkpoint or prior accepted Trip correspondence.
This conclusion uses positive schema/acceptance records and implementation boundaries,
not the absence of private artifacts from Git. No private provider, registry, history,
evidence or environment artifact was opened; no correspondence, allocation, registration
or conversion was performed.

Authority reviewed: DEC-060/068/073/082/083/084, ARCHITECTURE §§39–41,
[P2-S9 real readiness](P2_S9_REAL_READINESS.md), and the retained acceptance/checkpoint records
in this ROADMAP. DEC-060 recurring-run identity remains unchanged; source-profile eligibility
and identical structure alone do not establish canonical identity. Full repository enumeration
found **352 files**, matching the tracked inventory. Searches across that complete inventory
covered `gtfs.trip_id`, `trp`, schema 4, Trip provider references and real registration,
allocation/correspondence, including implementation, tests and documentation.

| Apparent capability | Classification and actual boundary |
|---|---|
| `MintedIdentifier`, `ProviderReference`, `MappingRegistry`, `ReviewedRevision` | Shared real registry capability for station/line/operator only. Ordinary schema 2; explicit DEC-073 reader 2/3. No Trip kind or Trip namespace. |
| StaticDataIntake `IdentifierMinting`, `ProvisionalRegistry`, `StationRegistry`, `RevisionReconciliation` | Owner-only real offline tooling for those same kinds. Reviewed attachments, retained references and provisional minting do not extend to Trips. Ordinary absence reactivation is not the DEC-083 Trip continuity workflow. |
| RailwayStorage `IdentityTransition`, `RailwayArtifactBuilder`, derived runtime storage | Owner-only real offline tooling / shared storage for accepted non-Trip registry inputs. DEC-073 exact checkpoint/history and atomic publication do not admit Trip participants; SQLite is not a provider-reference or correspondence authority. |
| TripNomination applicability and StaticDataIntake station-crosswalk tools | Owner-only real offline evidence tooling, not canonical Trip registry capability; the crosswalk resolves StationIDs through the unchanged shared registry. |
| `SyntheticTripRegistrationCodec`, `Schema`, `S9Codec`, `Closure` | DEBUG/synthetic-only representation, deterministic digest and dependency/input adaptation (A), not real approval or registration. |
| `SyntheticTripRegistrationHistory`, `SyntheticTripLegacyHistory` | DEBUG/synthetic-only supplied-memory history/checkpoint and legacy comparison validation (B); no conversion application or real publisher. |
| `SyntheticTripRegistrationAdmission`, `Reconstruction`, `Snapshots` | DEBUG/synthetic-only C1/C2 admission/replay and atomic in-memory candidate bytes with supplied invented IDs and S9 packets; no real allocator, CLI, filesystem loader/writer or execution authority. |
| Domain `TripID`/Trip/`TimetableOccurrenceAddress`, mapping/registration test fixtures | Representation/test fixtures only for this identity-baseline question. Domain value validity and invented schema-4 seeds do not establish real registry ownership. |
| Accepted DEC-083/084 and corresponding architecture/roadmap/proposal text | Documentation/design authority for identity and schema semantics; no real implementation or executed registration is conferred by acceptance. |

**Accepted Phase-2 baseline:** the DEC-074 local provisional package records registry
**revision 6**, SHA-256
`9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`.
The preceding exact dependency-rebinding checkpoint positively records **schema 2 / revision 6**.
Its kinds are exactly station `stn`, line `lin`, operator `opr`. Its namespaces are exactly
`gtfs.agency_id`, `gtfs.route_id`, `gtfs.stop_id`, `gtfs.stop_code`, `odpt.operator`,
`odpt.railway.id`, `odpt.railway.sameAs`, `odpt.railway.lineCode`.
Closed enums and strict decoding exclude both `trp` and `gtfs.trip_id`; revision 6 cannot
structurally store any active, absent, retired or competing canonical Trip binding. DEC-073
schema 3/history retains these same kind/namespace restrictions. Legacy attaching-review
authority (`attachedBy`, optional in old records) and retained non-Trip history are not Trip
attachment authority. The accepted external name/network/review/runtime histories remain
recognized; none is an accepted Trip identity baseline. Revision 6 is an accepted historical
pin, not a fresh certification of private-file availability, currentness or complete closure.

**Schema 4:** Accepted representation semantics and implemented DEBUG synthetic A/B/C1/C2
exist. Real offline and production/shared Trip registry implementations do not. No accepted
real schema-2/3 → 4 conversion authorization/execution, emitted real schema-4 checkpoint,
Trip identity history or candidate correspondence is recorded. ARCHITECTURE §39 and DEC-084's
scope/compatibility and conversion boundaries explicitly preserve that distinction. No current
non-synthetic path combines Trip entities/references, permanent Trip attachment history,
identified prior real checkpoint consumption, real allocation/attachment and atomic next
registry/history emission. Existing non-Trip machinery supplies only some of those mechanics.

**Correspondence implications and ordering:** there is no existing accepted canonical Trip
target or competitor **in this accepted baseline/history**. That structural result proves
neither semantic distinctness from every other GTFS row nor absence of future correspondence
conflicts. Affirmative distinct-recurring-run reasoning and exact owner approval remain
required; ambiguous correspondence holds. No existing-target attachment is presently available
against the accepted project baseline.

[DEC-083 §B](DECISIONS.md#dec-083--bounded-recurring-trip-registration-before-authoritative-p2-s9-output)
explicitly permits a correspondence record retaining a **proposed TripID or explicit new-run
request**. Therefore a private distinct-new-run correspondence request can be prepared and
owner-approved before minting or implementing real registration tooling. That approval is
not a runnable registry delta or authorization to execute allocation/registration. DEC-084's
synthetic target-byte approval mechanics do not remove DEC-083's earlier request option.
The readiness document's ordering still requires separately authorized, verified real tooling
and any exact-baseline legacy conversion **before authorizing an actual allocation/registration
application**. Preserve the existing lineage, revalidate the exact current approved checkpoint
and complete retained history, and require later exact owner execution approval; no side registry,
invented real target, automatic mint or production promotion is allowed.

**Smallest next task: A — private correspondence-request tooling/workflow**, not real
registration tooling first. Its bounded owner-only record must retain the Accepted source
profile identity/version and exact scoped Unicode-scalar source key privately; applicability
evidence; S9 classification and crosswalk references; explicit distinct-new-run request with
affirmative reasoning; exact proposed prior lineage/schema/revision/hash and structural
binding/competitor result; evidence/mapping versions, hashes and locators; unique review ID,
owner reviewer/authority, approval timestamp and deterministic approved-content digest; and
unresolved movement, endpoint and snapshot prerequisites. Private access/currentness checks
require separately bounded authorization. Missing evidence holds the request; this audit
neither prepares nor approves actual correspondence and does not implement that next task.

Verification: complete ROADMAP diff/privacy review, heading/link checks, historical-content
byte-preservation and `git diff --check` passed. Separate non-author review **approved** the
overlay and baseline/ordering verdict with **no material findings**. Preflight matched expected
repository/branch, HEAD/upstream/live remote `6f7111a8ff2b5d0acd2dead6e82a84aaee7c7463`
(0/0), clean worktree/index and unchanged local/remote main. Only this ROADMAP is modified,
left **unstaged**. No private artifacts, tests/builds, staging, commit, push or next-task work.

#### Synthetic-only distinct-new-run correspondence-request workflow — 2026-10-08

Scope: implement DEC-083's explicit new-run correspondence-request representation and
validator before minting, using **invented data only**. Preflight matched repository/branch,
HEAD/upstream/live Phase 3 `d50e9c4af115c063c6d694019643467169ce3935` (0/0), clean worktree/
index/no untracked files and unchanged local/remote main. Only new
`Tools/TripNomination/correspondence_request.py`, its invented tests, tool README and this
ROADMAP change; no iOS/shared registry/Accepted-decision changes or publication.

The standalone Python standard-library workflow has explicit `prepare`, aggregate-only
`inspect`, deliberate `approve` and approval-required `verify` stages. Strict version-1
`tsugino.trip-correspondence-request` proposals retain exact scalar source/profile/input
scope, mapping version/hash, prior lineage/schema-2/revision-6/hash, unique review ID,
owner authority, affirmative reasoning and digest-bound evidence-role references. An
explicit separately supplied context pins expected scope/checkpoint/mapping/evidence;
it asserts accepted bindings, not evidence truth, authentication or fresh private-file
currentness. Required roles are source-profile acceptance, candidate applicability,
passenger classification, source order, station crosswalk and first-real-Trip baseline
audit; optional S9 review references preserve available review associations. No reference
is opened or raw evidence embedded.

First-allocation requests forbid a canonical target/TripID and existing-target mode.
Prior canonical binding and accepted competing Trip assignments are separately typed as
structurally impossible **in the exact identified baseline**; external/source semantic
competition remains **not globally disproved**. Baseline absence alone cannot supply the
reasoning basis. Movement, endpoints, immutable S9 snapshot acceptance, real registration
tooling/checkpoint, P3-T1 real import and production adoption remain explicitly unresolved.

Canonical UTF-8 JSON preserves scalar distinctions; object keys and defined sets have fixed
ordering. Duplicate/unknown keys, invalid Unicode, malformed timestamps, mixed scopes and
oversized input reject. Separate versioned proposal/approval digest domains bind all payload
fields and owner authority/time; the approved digest excludes only itself. Preparation
never approves. Approval requires an explicit action, exact reviewed proposal digest,
matching authority and timestamp; hashes establish integrity, not person authentication.
DEC-084 contributes concepts only; no DEBUG schema/seed/output becomes real authority.

Private I/O is bounded, explicit and outside the repository: owner-only 0700 parent/0600
regular files, descriptor-relative no-symlink traversal and identity/state rechecks,
repository inode-alias rejection, no-clobber atomic complete output and staging cleanup.
Normal CLI summaries/errors omit source keys and caller-controlled identities, private
paths and raw exception details. No network, subprocess or discovery is used by the tool.

Warnings-as-errors verification passed **43/43 focused test functions** and **264/264 full
TripNomination test functions**, the latter including those same 43 plus 221 existing
regressions; these counts are not added together. Actual CLI tests use invented owner-only
temporary files and cover proposal/approval separation, digest mutation, exact scalars,
scope/role closure, unresolved prerequisites, no TripID, permissions, links, path races,
atomic failure/no-clobber and redacted output. Initial tests exposed nested-object aliasing,
fixed by detached returned records with regression coverage. Independent review prompted
the repository inode-alias guard and its regression. Separate non-author review **approved**
the complete four-file scope with **no remaining material findings**, independently rerunning
43/43 focused functions. Complete diff/privacy/reference/heading and whitespace checks passed;
earlier ROADMAP/README content is byte-preserved. No tool implementation blocker remains for
a separately authorized one-use real proposal creation, once exact private draft/context
bindings, permitted input/output paths and owner access authority are supplied. That creation
is not authorized here; later deliberate owner approval remains a separate action.

No real owner correspondence approval has occurred; test approvals use invented fixtures.
No real/private railway artifact or exact real key was accessed; **no real correspondence
request exists yet**, no TripID was minted/registered and no registry changed. No movement,
endpoint or snapshot claim is made. `FIRST_REAL_TRIP_ALLOCATION_PATH` remains the selected
boundary; classification **0 gaps**, order resolved, crosswalk **14 verified / 0 held**,
source profile Accepted and final-verifier applicability satisfied/eligible. Correspondence,
movement/endpoints/snapshot/final S9 remain unresolved; P2-S9/P3-T1 incomplete, Phase 3
In Progress, live/default routing unconfigured. Real proposal creation and owner approval
require separate bounded authorization/inputs; real tooling/conversion/application remain
later separate steps. No tests on real data, app build, device, staging, commit or push.

#### Owner acceptance overlay — first Trip correspondence metadata bindings — 2026-10-08

Scope: Phase 3 / retained P2-S9 documentation and metadata authority only. Fetch/preflight
matched `lunalism/TSUGINO`, branch `phase/03-route-search`, HEAD/upstream/live remote
`c9d346400b040d0d29ccd32202611de85b545dd7` (0/0), clean worktree/index/no untracked files,
and local/remote main `e8a463d51f14b3cb1027960c63244b694579a71b`. The owner accepts the
exact bindings below for already Accepted evidence, following contract-compatibility
inspection. They assign stable metadata identifiers; no railway semantics, source scope,
Accepted DEC semantics, implementation or schema changes. Only this ROADMAP changes.

**Contract compatibility:** DEC-068 retains private reviewed mapping/registry authority;
DEC-082 keeps occurrence classification, mapping and snapshot acceptance distinct.
DEC-083 §B requires source/profile/mapping versions and identified evidence hashes/locators,
not publication of raw mapping pairs; §D keeps real references/reviews/provenance outside Git.
Correspondence v1's `mapping` is an exact version/hash binding with matching owner-asserted
context/evidence associations, not a raw mapping export or evidence-authentication reader.
Thus the sanitized immutable mapping-authority checkpoint below is compatible for this
pre-mint explicit new-run request. DEC-083 §D's existing provisional-lineage continuation
and DEC-084's separate lossless conversion/history requirements remain intact. No new DEC
is required; no real conversion, complete private-history verification or registration
capability is asserted by assigning these labels.

**Accepted source and profile metadata** (the exact real source key remains private and
is neither read nor recorded here):

| Correspondence field | Accepted exact value |
|---|---|
| `sourceID` | `DS-01/toei-static-gtfs` |
| `namespace` | `gtfs.trip_id` |
| `inputSHA256` | `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4` |
| `publisherID` | `Bureau of Transportation, Tokyo Metropolitan Government` |
| `resourceID` | `35b68908-4558-47ae-bfa5-867e58544a1a` |
| `feedRevision` | `20260921` |
| `profileID` | `toei-20260921-trip-id-applicability` |
| `profileVersion` | `00` |

The publisher value reuses the exact committed DS-01 `SourceList` provider representation
in `Tools/StaticDataIntake/Sources/IntakeModel.swift`; it is internal correspondence metadata,
not a new provider identity, endorsement or authentication. The accepted pair forms the
existing external/tool selector `toei-20260921-trip-id-applicability-00`; `00` is explicitly
the correspondence source-profile version token. Existing profile semantics remain exact
scalar `gtfs.trip_id`, this resource/feed revision, within-revision uniqueness only,
eligible ordinary fixed-schedule recurring definition, exclusion of frequency/Flex variants,
and no cross-revision continuity without affirmative evidence.

**Accepted provisional lineage and predecessor:** `lineageID =
"tsugino.provisional.identity-registry"` names the existing provisional identity registry
lineage containing the accepted Phase-2 **schema 2 / revision 6** baseline, registry SHA-256
`9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`.
The label remains stable for any future separately authorized schema-2 → schema-4 continuation
of that same identity history. It creates no schema-4 artifact, conversion, production
registry-of-record or production adoption; this historical pin proves no fresh availability
or currentness of a private checkpoint.

**Accepted mapping-authority binding:** `mapping.version =
"p2s9.toei-20260921.station-crosswalk.1"`, `mapping.sha256 =
"6260de45f29cf9ea6eeaee8be9884c8724c79f22218ec724fad6da44d0e065e1"`.
Its authority locator is
`git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#corrected-abi-2-owner-operated-real-crosswalk-success-and-remaining-gates--2026-10-08`.
This identifies the immutable sanitized Accepted authority record establishing the retained
candidate's **14/14 station crosswalk** under the exact identified source/mapping baseline.
The digest is the ordinary SHA-256 of the **entire committed ROADMAP file** at that commit,
not a section digest or the hash of raw pairs. This is neither the raw source→StationID pair
set nor a reconstructable mapping export, replacement for private reviewed registry/assignment
evidence, publisher authentication or persisted crosswalk/full snapshot. Raw pairs remain
unpublished and unnecessary for this correspondence document. Changed crosswalk authority
requires a new mapping version/hash; this identity cannot be reused for another source,
revision or candidate scope. Future S9/registration consumers retain their own full evidence
and exact-artifact requirements.

**Accepted immutable evidence inventory:** all six references identify exact committed
`docs/ROADMAP.md` bytes at `c9d346400b040d0d29ccd32202611de85b545dd7`, ordinary file SHA-256
`6260de45f29cf9ea6eeaee8be9884c8724c79f22218ec724fad6da44d0e065e1`.
Each role token is its unique `evidenceID`:

| Role / evidenceID | Exact immutable locator |
|---|---|
| `sourceProfileAcceptance` | `git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#owner-acceptance-overlay--retained-toei-recurring-key-source-profile--2026-10-08` |
| `candidateApplicability` | `git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#final-published-verifier-real-revalidation--2026-10-08` |
| `passengerClassification` | `git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#owner-reported-same-candidate-occurrence-review--2026-10-08` |
| `sourceOrder` | `git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#owner-reported-same-candidate-occurrence-review--2026-10-08` |
| `stationCrosswalk` | `git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#corrected-abi-2-owner-operated-real-crosswalk-success-and-remaining-gates--2026-10-08` |
| `firstRealTripBaselineAudit` | `git:c9d346400b040d0d29ccd32202611de85b545dd7:docs/ROADMAP.md#repository-only-real-trip-correspondence-baseline-audit--2026-10-08` |

Each reference is accepted as applicable to exactly the source/profile object above
(with its exact private key supplied only in a future authorized task), the identified
baseline object and mapping object. These sanitized authorities do not independently embed
every private field; association asserts accepted applicability, not raw evidence content.
No optional `s9Review` is accepted for this first proposal without a later distinct immutable
authority that materially adds required evidence. Old section wording remains historical;
subsequent accepted evidence controls current bounded status.

**Reserved workflow identifiers:** `ownerAuthority = "tsugino.owner"` and
`requestID = "p2s9.first-real-trip.20261008.001"`. These opaque owner-workflow tokens are not
cryptographic owner authentication. The owner asserts this requestID remains unused because
no real correspondence request exists. No request is created by reserving it.

**Accepted bounded reasoning for a future unapproved proposal**, with all six required
role/evidenceID tokens above as `basisEvidenceIDs`:

> The exact scoped recurring source identity is eligible under the Accepted Toei 20260921 source profile. Passenger classification, source order and the 14/14 canonical station crosswalk are established for the retained candidate. The identified accepted provisional schema-2 revision-6 baseline cannot contain canonical Trip identity state, so this request seeks the first canonical allocation for this recurring-run candidate. Accepted canonical Trip competitors are structurally impossible in that identified baseline, while external/source-level semantic competition is not globally disproved. Movement evidence, endpoint dispositions, immutable S9 snapshot acceptance and real registration remain unresolved; this request grants neither final S9 nor production identity.

This approves only the reasoning text for future preparation, not correspondence itself or
semantic uniqueness across all source rows. The future proposal retains exactly the six
unresolved prerequisites: `movementEvidence`, `endpointDispositions`,
`immutableS9SnapshotAcceptance`, `realTripRegistrationToolingCheckpoint`, `p3T1RealImport`,
`productionRegistryAdoption`. None is closed by this overlay.

The preceding metadata `*_BINDING_REQUIRED` gaps are cleared by these exact owner assignments
and evidence associations. No private archive, key, registry, assignment or environment
artifact was accessed; no binder, context/draft/proposal, real correspondence approval,
TripID, registry mutation or atomic access grant is created or consumed. Classification
remains **0 gaps**, source order resolved, crosswalk **14 verified / 0 held**, source profile
Accepted and final-verifier applicability satisfied/eligible. Correspondence approval,
movement/endpoints/immutable snapshot/final S9 remain unresolved; P2-S9/P3-T1 incomplete,
Phase 3 In Progress, live/default routing unconfigured.

**Next safe task:** a separately authorized fresh binding/binder-preparation audit against
this published metadata authority and the published correspondence implementation. It must
revalidate exact non-private bindings and private path/output safeguards before any later
one-use preparation grant; this overlay supplies no private access or proposal-execution
authority. Do not proceed to that task as part of this publication.

Verification: complete documentation diff/privacy review, immutable c9d file SHA-256 and
all six anchors, exact publisher/selector/baseline bindings, reference/heading checks,
historical-content byte preservation and `git diff --check` passed. Separate non-author
review **approved all nine metadata-compatibility criteria with no material findings**,
including the mapping-authority interpretation. No tests, builds or device work were run.
Publication is limited to this ROADMAP under the owner's exact one-file authorization.

#### Approved real correspondence checkpoint and provisional registration boundary audit — 2026-10-08

**Scope:** Phase 3 / retained P2-S9; sanitized owner-reported correspondence checkpoint and
repository-only registration design. Only this ROADMAP changes, unstaged. No implementation,
private artifact access, ID allocation, registry conversion/mutation, movement/endpoint review,
snapshot acceptance, tests, builds, device work or publication is authorized by this task.
Preflight verified origin `https://github.com/lunalism/TSUGINO.git`, branch
`phase/03-route-search`, HEAD/upstream/live branch
`693c4de3002c8ad9f8fdc68803551912953a8706`, divergence **0/0**, clean index/worktree/untracked
state, and local/tracked/live main `e8a463d51f14b3cb1027960c63244b694579a71b` before editing.

**Candidate recurring correspondence is now owner-approved as an explicit distinct-new-run request.**
The first real private proposal was created; the owner explicitly approved the exact proposal,
and its materialized approved representation was verified. Mode is `distinctNewRun`.
The following safe metadata is owner-supplied; this audit did not reopen its private payload:

| Approved correspondence metadata | Exact value |
|---|---|
| `approvedAt` | `2026-10-08T09:45:12Z` |
| Proposal SHA-256 | `a3e205a1a82d9db050cef86cea9ce661c25daf8786b5b641c6740741cb3c2094` |
| Approved-content SHA-256 | `538313c8e2608aba802562cf5dc5f73718a6add4052be463b49ba9ec5c0e6cdf` |
| Complete private approved-record SHA-256 | `6f15b2e634b132ca36d4490b8e64a50e9776317514c015c2f4fc16cbb8d6bc04` |
| Representation verification | `approvedRepresentationValid` |

This is accepted correspondence authority for the first-real-Trip allocation path. It is not
a canonical Trip, a registration record, an allocated ID, a converted checkpoint or an approval
of future target registry bytes. The preceding metadata-preparation overlay remains historical;
this overlay supersedes its pending-correspondence status only.

**Current truth:** classification **0 gaps**; source order resolved; crosswalk **14 verified /
0 held**; source profile Accepted; candidate applicability satisfied/eligible; recurring
correspondence owner-approved distinct-new-run request. Canonical TripID **not allocated**;
real Trip registration **not performed**. Movement, endpoint dispositions, immutable S9
snapshot acceptance, real registration tooling checkpoint, P3-T1 real import and production
registry adoption remain unresolved. P2-S9 remains incomplete; Phase 3 In Progress;
live/default routing unconfigured. No real TripID is created by this task; invented `trp`
fixture identifiers already in the repository are not evidence of real allocation.

**Authority and corrected operation sequence.** Re-read Accepted DEC-068, DEC-073, DEC-082,
DEC-083, DEC-084, ARCHITECTURE §§39–41, [P2-S9 real readiness](P2_S9_REAL_READINESS.md), current
ROADMAP and the real/synthetic implementation inventory. DEC-083 §C and DEC-084 §§A–B/D
require **two separately reviewed checkpoints**, not the proposed combined twelve-item
conversion/allocation operation:

1. **Conversion only:** validate the exact original predecessor and complete retained history;
   approve an exact conversion request; advance schema 2→4 and revision by one, preserving
   every entity/reference field and all original history. Publish one atomic conversion
   checkpoint. No mint, Trip entity, source attachment or snapshot selection occurs here.
2. **First registration only:** against that exact current converted checkpoint, validate the
   original approved distinct-new-run correspondence and complete dependency closure; prepare
   exactly one fresh Trip target and exact registration delta under separate authorization;
   obtain owner approval binding that request's `expectedPrevious` and `targetRegistryBytes`;
   atomically register one active Trip with one exact private source key, permanent introducing
   authority and immutable registration/history boundary. Verify/replay the result.

All twelve proposed obligations are needed across these two operations; item 4 belongs only
to conversion, and items 5–9 only to registration. Each preserves all existing non-Trip
identities/references and emits its own checkpoint. If the identified revision-6 predecessor
is still current with no intervening boundary, conversion would produce revision 7 and first
registration revision 8; these are conditional arithmetic, not newly verified private state.
The original correspondence's schema-2 baseline binding stays immutable: retain an explicit
validated conversion chain to the registration predecessor, never silently retarget its approval.
Future operation/request/review/record IDs must be separately bound and unused; the original
correspondence request ID cannot authorize a changed operation payload.

**Minting contract.** DEC-068/083 require kind `trip`, prefix `trp`, underscore, and a
16-character lowercase Crockford Base32 body encoding **80 random bits** (20 ASCII characters
total), using alphabet `0123456789abcdefghjkmnpqrstvwxyz`, most-significant five-bit group first.
Reject uppercase/substitute letters; no extra separators or check character. Use Swift
`SystemRandomNumberGenerator`, backed by the OS CSPRNG; never seed it.
Deterministic RNG injection is test-build-only, with no production injection entry point.
Compare the body against **all retained allocation history across every kind**, including
active and retired entities; a cross-kind equal body collides. Permit at most **eight draws**;
eight collisions fail without a target checkpoint. No provider-derived, timetable-derived,
deterministic hash-derived or sequential TripID. Draw only after eligibility/history checks
in a future authorized target-preparation step; retain the exact prepared target for review.
Apply, verification and unchanged replay never draw again. A prepared label becomes canonical
only through the accepted registry checkpoint; failed preparation must not trigger automatic
redraw on rerun. Current `IdentifierMinter` has the correct mechanics but a closed non-Trip
kind type, so it cannot be called unchanged for Trip allocation. Use an isolated bounded
Trip-capable implementation preserving these rules; do not broaden shared enums/intake.

**Conversion and private-history prerequisites.** The known schema-2 revision-6 registry
digest identifies exact predecessor bytes; it alone proves neither currentness nor history
completeness. Before real execution, separately bind exact retained original registry bytes,
lineage/schema/revision/hash/current-checkpoint authority, and the complete required historical
dependency inventory with bytes/digests: allocation and review IDs, attachment/status
authorities, prior registry boundaries and any known legacy sidecar. An explicitly approved
complete baseline/root must account for retained history; absence from Git is not evidence
of absence. Schema 2 does not inherently require DEC-073's schema-3 transition sidecar.
Bind its actual `none`/`present` state; do not fabricate an empty history or accept a known
inconsistent sidecar. Validate present history under its original contract. External retained
authority needed by that closure remains required; a derived SQLite artifact cannot replace it.

Validate original schema 2 through its original reader/rules, preserve its original bytes and
digests, then produce a schema-4 representation with only schema/revision changed. Preserve
IDs, status/successors, localized fields, exact scalar values, source provenance, first/last
sightings and optional legacy `attachedBy` including its absence. Never invent old approvals,
reinterpret identities, delete history, use a synthetic seed exception, create a side registry
or overwrite a predecessor. Generic conversion/history tooling and invented tests can be
specified now; these private bindings are mandatory before real execution, not a reason to
invent a new policy or open artifacts during this audit.

**Future private correspondence validation.** Require the three exact digests above, expected
owner authority and request ID from the accepted metadata binding, exact source/profile/input
identity and private key, and original predecessor lineage/schema/revision/hash. Hash complete
approved-record bytes, validate the published correspondence codec/digest domains and owner
approval, compare every bound field scalar-exactly, then validate the retained conversion chain
and current registration request approval. Missing or conflicting bindings cannot allocate.
Digest consistency verifies a local assertion; it does not cryptographically authenticate an
owner or publisher. Report only aggregate outcomes/digests; never log the source key/payload.
The correspondence v1 source object does not supply every GTFS `SourceReference` field:
registration also needs exact input hash, member name/hash, table, field and provider key from
separately bound retained provenance. GTFS provenance forbids ODPT's `recordIndex`.
Do not infer member hashes from profile/mapping digests or reopen the archive automatically.

Retain the complete original approved correspondence bytes/digests as a permanent dependency
of the introducing operation. The new reference's non-null `attachedBy` identifies the
introducing owner operation approval's `reviewID`, not the registration `recordID`; the
registration record links its allocation request and correspondence evidence. This preserves
both semantic correspondence authority and exact target-delta approval without conflating them.

**Owner-only output and atomicity design.** Each future operation emits an immutable external
bundle with `registry.json`, `history.json` and `checkpoint.json`, plus complete authority bytes
either retained in history or as digest-bound dependencies in that bundle. A conversion
boundary retains exact original predecessor/target bytes and approved conversion request;
registration appends its exact request, owner approval, record and correspondence dependency.
History preserves every preceding boundary byte-for-byte and validates the complete closure.
Checkpoint fields bind lineage/schema/revision/registry SHA/history SHA. Compute target history
SHA after appending the boundary, avoiding a self-referential approval hash cycle.

Registry plus validated retained authority/history is the identity authority; the verified
manifest pins/selects that complete committed checkpoint, rather than substituting for its
history. Receipts, counts, selected-state projections and runtime SQLite are derived; no SQLite
output is required for this identity tool. All real bytes remain outside Git, directories
owner-only `0700`, files `0600`, with strict version, size, path, ownership, non-symlink and
exact-byte hash checks. Real versioned offline wire tags/codecs must be explicit; accepted
synthetic tags/mode or invented seed admissions must never become real input by relabeling.

Validate before publication; stage the complete bundle on the same filesystem, read back and
verify all bytes, fsync files/directory, then publish by exclusive atomic directory rename or
equivalent. Never commit a registry/history pair through independent file replacements.
Collision exhaustion, stale predecessor, correspondence mismatch or incomplete history yields
no accepted target. Write failure leaves no accepted partial pair; staging is not a checkpoint.
Preserve predecessor bundles, reject concurrent/stale publication, and test failure boundaries
without claiming untested power-loss guarantees. DEC-073's atomic package principle is reusable.

Exact unchanged request/payload/approval/dependencies against the retained current target is
`unchangedReplay`: return the identical checkpoint, no new random draw, revision or history
append. Reusing an ID with changed bytes/authority rejects. Replay against a later current
checkpoint is stale, not permission to rebase or select a latest file. A prepared target and
its review plan must survive retries without minting again; no accepted checkpoint means no
accepted registration, regardless of stray staged bytes.

**Identity versus S9.** DEC-083 §D and DEC-084 §B explicitly allow identity-only registration
with no selected snapshot (`snapshotArtifactID` absent). Later `initialSelection` is a separate
approved `reviseSnapshot` request against the then-current checkpoint, with full S9 evidence.
Unresolved movement and origin/destination dispositions do not independently block identity
allocation/source-key registration once applicable correspondence and registration authority
are established. They continue to block final S9 acceptance. Preserve DEC-082's distinction
between proven boundaries and recorded unknown external extent/false coverage; never infer
continuation or claim completed endpoints from identity registration. Neither this audit nor
correspondence approval closes any of the six retained downstream prerequisites.

**Repository-wide implementation inventory:** all **354** tracked repository files matched
the complete hidden-file-aware working-tree inventory. Read the real components and all eight
`SyntheticTripRegistration*` modules plus their legacy-history helper. No real Trip allocator,
schema-4 offline publisher or real registration workflow was found.

| Component | Reuse classification and limit |
|---|---|
| `TSUGINO/Data/Mapping/MintedIdentifier.swift` | Conceptually reusable strict prefix/body validation; closed kinds reject Trip, so not unchanged for Trip. |
| `Tools/StaticDataIntake/Sources/IdentifierMinting.swift` | Conceptually reusable 80-bit CSPRNG/eight-draw/all-body mechanics; requires isolated Trip-capable type. `IdentifierAssigner`'s automatic existing-reference handling is incompatible with Trip continuity. |
| `TSUGINO/Data/Mapping/MappingRegistry.swift` | Reusable unchanged as the original schema-2 validator/legacy encoder; cannot read/write schema 4. Preserve original bytes separately. |
| `TSUGINO/Data/Mapping/ProviderReference.swift` | Exact key/provenance validation conceptually reusable; closed namespace/kind admission requires isolated Trip extension, preserving optional legacy authority. |
| `Tools/StaticDataIntake/Sources/RevisionReconciliation.swift` | Automatic absent-reference reactivation is incompatible with DEC-083 Trip continuity; do not route Trip through it. |
| `Tools/RailwayStorage/Sources/IdentityTransition.swift` | Conceptually reusable exact-boundary/history/atomic publication design; non-Trip schema-3 authorization/applier is incompatible unchanged. |
| `Tools/RailwayStorage/Sources/RailwayArtifactBuilder.swift` | Derived station/line/operator SQLite builder; incompatible as a Trip registry/history writer, unnecessary for this slice. |
| `TSUGINO/Data/Review/SyntheticTripRegistration*.swift` | DEBUG-only supplied-memory codecs/history/admission/reconstruction, no real minter/writer; synthetic-only, not directly reusable as real authority. Strict encoding/delta/replay and invented tests are design specimens. |

**Primary verdict: `REAL_TRIP_REGISTRATION_TOOLING_SLICE_READY` — design readiness only.**
Accepted contracts determine the sequence; no additional identity policy decision is needed.
The smallest next implementation is an isolated **Swift conversion/history-only offline tool**
under `Tools/TripRegistration/Sources/`, with invented tests under `Tools/TripRegistration/Tests/`.
Do not combine first conversion with minting or registration. Do not implement it in this task.

- **Inputs:** explicit owner-bound legacy baseline/currentness and complete history/dependency
  inventory; original schema-2 bytes; exact conversion request/owner approval with supplied IDs,
  time, expected predecessor and target bytes; explicit output bundle path. No discovery.
- **Outputs:** the verified conversion-only schema-4 registry/history/checkpoint bundle above,
  or bounded hold/reject with no accepted output; deterministic verify/replay summary.
- **Reuse:** unchanged original schema-2 validation and applicable exact-value/hash primitives;
  dedicated schema-4/history codec and closure checker; DEC-073 atomic package technique.
  Keep shared closed enums, app/runtime composition and DEBUG code unchanged.
- **Invented tests:** exact field/legacy-byte preservation, present/absent legacy authority,
  complete versus missing/conflicting history, strict malformed/unknown/duplicate/version/hash
  handling, changed/stale predecessor and request ID reuse, conversion-with-business-delta
  rejection, no RNG use, canonical round trips, unchanged replay, symlink/mode/path rejection,
  concurrent publication and injected failures before/at publication with no accepted partial
  bundle. These tests are planned, not run here.

A later independently authorized **first-registration-only** slice adds the private
correspondence/provenance adapter, isolated bounded Trip minter, one-entity/one-reference delta,
exact target request approval, permanent authority/history and the same atomic publisher/replay.
Its invented fixtures must exercise deterministic test-only RNG, cross-kind/retired collisions,
eight-draw exhaustion, exact correspondence/dependency/approval mismatches, duplicate-key and
no-selected-snapshot registration, and replay without redraw. No automatic attach/return,
transition, snapshot selection or runtime import belongs in either first slice. Neither slice
may access real registry/evidence or execute real conversion/allocation without a later explicit
grant and complete private binding; implementation must receive independent review first.

Verification: complete diff/privacy review, exact safe digest/time/status comparison against
the owner's supplied request, 354-file repository inventory, unique heading/public reference
checks, historical-byte preservation and `git diff --check` passed. Separate non-author review
**approved all eight requested criteria with no material findings**. Only ROADMAP is changed,
unstaged; no private payload was accessed or added, no real TripID was created and no registry
was accessed or mutated. No tests, builds, device work, staging, commit or push were performed.

#### First-real-Trip checkpoint 1 tooling implementation — 2026-10-08

The owner authorized implementation, invented-fixture verification and independent review
of the first conversion checkpoint only, from clean published
`1f3733a0c722c17b7e81280862871ce6fb98dff2`. Preflight matched repository, phase branch,
HEAD/upstream/live branch, zero divergence and clean tree/index/untracked state; local/tracked/
live main stayed `e8a463d51f14b3cb1027960c63244b694579a71b`. This overlay records implementation
progress; the preceding design checkpoint and its historical verification remain unchanged.

`Tools/TripRegistration/` now owns an isolated schema-4 codec, strict ordinary schema-2
predecessor admission, deterministic conversion request/approval, retained baseline/history,
checkpoint and manifest, exact replay and private atomic publisher. Shared Mapping enums,
ordinary readers, app/runtime targets and DEBUG synthetic tooling are unchanged. Selected
unchanged Mapping validators are compiled explicitly into the standalone tool. The only
conversion registry delta is schema `2 -> 4`, checked revision `N -> N+1`; all legacy entities,
references, statuses, successors, authority, provenance, original names and optional attachment
values are preserved. Original predecessor bytes remain retained unchanged. Schema 3 rejects.

The tool-owned schema-4 representation can validate future Trip syntax, but conversion rejects
every Trip entity and `gtfs.trip_id` reference. There is no minter, registration operation,
correspondence adapter, source-key attachment, snapshot selection, SQLite generation or runtime
import. The second first-Trip mint/registration checkpoint remains unimplemented.

A narrowly scoped `.gitignore` entry excludes this standalone tool's `.build/` binaries
and module caches from the review/publication inventory; no other build policy changes.

The owner-reviewed baseline binds original immutable authority bytes, exact active/retired
identity coverage, original allocation/review tokens and dependency digests. Inventory handles
do not replace original business IDs; old approvals are not translated or re-authored. Missing
required closure/approval holds; known malformed or conflicting supplied content rejects.
Completeness is an explicit owner assertion plus checked closure, not person authentication
or discovery of undisclosed history. No real baseline is fabricated by the CLI. Initial H0
and one immutable conversion boundary are supported; later history cannot be silently omitted.
Separate conversion approval binds the exact complete request and its predecessor/target.

The authoritative bundle has `registry.json`, `history.json`, `manifest.json`; the manifest
binds exact predecessor/target, full history, request, approval and boundary digests. Exact replay
retains the same revision/boundary/bytes and requires the existing output identity. Owner current
pins are explicit; no global current pointer or cross-output-path fork exclusion is claimed.
External owner-only paths, descriptor-relative no-symlink traversal, mode/ownership checks,
bounded reads, staged fsync/readback and exclusive same-parent atomic rename protect publication.
Same-path races have one winner. Pre-commit failures leave no accepted partial bundle; a
post-commit parent-fsync failure may leave the complete bundle with uncertain durability and
requires exact verification before recovery. Diagnostics contain only fixed statuses/categories
and digests. Explicit resource limits and the full wire/CLI contract are in the tool README.

Final standalone build and invented tests passed: **8 functions / 142 cases**, including
CLI end-to-end conversion/verification, exact replay, same-path concurrency and injected
publication failures. Counts describe one complete final run, not summed overlapping runs.
Separate non-author review independently rebuilt and passed the same **8 / 142** suite and
**approved all 12 requested criteria with no unresolved material findings**. Its six safety
answers confirm no successful identity mutation, no conversion-created Trip state, no accepted
incomplete history, no replay revision/boundary increment, no accepted partial publication and
no widened runtime reader. The post-commit durability caveat above remains explicit. Final
12-file scope/privacy/inventory audit, `.build` ignore checks, exact preservation of historical
ROADMAP bytes and `git diff --check` passed. No production/shared source changed, so no app,
extension, existing Mapping regression or device build/test was required or run. Checkpoint 1
tooling is ready for source publication; it closes no real execution gate.

At the implementation handoff this scope remained unstaged and uncommitted for owner inspection;
that implementation grant did not authorize staging, commit or push. No real/private registry,
history, GTFS, correspondence or provider artifact was accessed. No real conversion occurred;
no TripID was minted and no Trip registered.
Existing correspondence approval remains separate; no retained S9 blocker or production gate
is closed by these invented fixtures. After separately authorized source publication, the next
gate is exact private baseline/history/current-checkpoint binding and explicit conversion
request preparation, owner approval and real execution authorization under DEC-083/084.
Source publication alone grants none of those operations and does not authorize checkpoint 2.

The owner subsequently authorized the final accumulated audit, staging, a new commit and a
normal push of exactly these **12 files**: the five standalone implementation files, two
invented-fixture test files, two scripts, tool README, this ROADMAP overlay and the narrow
`.gitignore` entry. Fetched/live phase and main refs matched the expected baseline before
publication. Source/test/script fingerprints match the independently approved version, so
the standalone build and **8 functions / 142 cases** evidence are reused without another run.
Documentation clarifications do not alter tooling behavior or broaden authority. Complete
private schema-2 baseline/history/current-checkpoint binding remains required before any
real conversion-request preparation or execution. **P2-S9 remains incomplete; P3-T1 remains
incomplete; Phase 3 remains In Progress.** Checkpoint 2 remains unimplemented. This publication
grant does not authorize private binding, preparation, approval, conversion or registration;
the exact next gate is to bind the complete private schema-2 baseline/history/current
checkpoint for a separately authorized real conversion-request workflow.

#### Accepted revision-6 legacy transition-history binding — 2026-10-08

**Verdict: `LEGACY_HISTORY_NONE_SUPPORTED_FOR_OWNER_APPROVAL`.** The owner authorizes this
narrow Accepted metadata disposition when the repository chronology meets the stated proof
standard and independent review passes. The cumulative Accepted checkpoint records and the
actual DEC-073 publication contract support the following exact binding:

| Bound field | Accepted value |
|---|---|
| Lineage | `tsugino.provisional.identity-registry` |
| Registry schema / revision | `2` / `6` |
| Registry SHA-256 | `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b` |
| `legacyHistoryState` | `none` |

Here **none means no DEC-073 schema-3 identity-transition sidecar/applied boundary belongs
to this exact accepted schema-2 revision-6 predecessor**. Other retained attachment, review,
allocation, coordinate, editorial and derived build histories are separate and remain required
where applicable. This is a repository-authority chronology binding, not an inference from a
directory inventory, missing files or the registry hash alone.

**Positive dated chronology.** Dates below are the records' dates; commits identify their
immutable publication, not an invented timestamp for private artifact creation.

| Date | Accepted evidence and immutable commit | Consequence for this predecessor |
|---|---|---|
| 2026-09-30 | P2-S5 real acceptance, `cb537d69e10049259137173b63770b568a05f3ca` | Station mint/assignment and reconciliation produced the accepted revision 6; its repeat was byte-identical with no revision increase. The ordinary registry encoder at this commit writes schema 2 only. |
| 2026-09-30 | P2-S6 real acceptance, `ba0e717625130be7efa7320db638f81e70d6a560` | Records the full registry hash above, identical P2-S5 first/repeat registries and unchanged revision/hash throughout coordinate/network acceptance. No identity change. |
| 2026-09-30 | Final P2-S7 real acceptance, `31732d77910cd2d96cf4858a95a50f2b2ab3a922` | Same full registry hash; all 240 prior evidence files retained unchanged. Names/search/editorial-history work did not mutate the registry. |
| 2026-10-01 | DEC-073 Accepted design, implementation and verification publication, `30827769a4a934e85be184f22bcf51ee8a08f45d` | First publication of the schema-3 transition/history tooling follows revision 6. Decision authorizes bounded synthetic implementation only; verification explicitly says no real registry or transition was used, and implementation audit explicitly records no real transition. |
| 2026-10-01 | DEC-074 private provisional real acceptance, `69464c1fc0b1d34610ce355e3e2efc92d8456864` | After DEC-073, real acceptance retains the same full revision-6 hash, runtime schema 1, one initial derived build revision, three byte-identical outputs and all 279 prior files unchanged. No new binding/ID or alteration of prior real evidence. |
| 2026-10-01 | DEC-075 Phase-2 exit/preservation audit, `e8a463d51f14b3cb1027960c63244b694579a71b` | Rechecks 50 package entries and 279 preserved originals, runtime schema 1/revision 6, accepted approvals and earlier histories. Synthetic DEC-073 migration evidence remains distinct from real acceptance. |
| 2026-10-08 | Phase-3 predecessor records, `d50e9c4af115c063c6d694019643467169ce3935` and `693c4de3002c8ad9f8fdc68803551912953a8706` | Identify this exact schema-2 revision-6 lineage/hash as the retained accepted predecessor; explicitly distinguish historical identity from fresh private availability/currentness/closure. No accepted real schema-3 successor is introduced. |
| 2026-10-08 | Registration-boundary design `1f3733a0c722c17b7e81280862871ce6fb98dff2`; Checkpoint-1 source `063d4054c5ba9959a802ba802bd71c9474f10ba7` | Conversion and registration remain separately gated; tooling verification is invented-only, with no real conversion, registry mutation or Trip allocation. |

Revision 6 therefore predates DEC-073 transition capability, and accepted later real work
positively preserves the same predecessor after that capability was introduced. DEC-073's
executed verification was synthetic, explicitly not a real lineage transition. The subsequent
accepted checkpoint chain retains schema 2/runtime 1 and introduces no applied real DEC-073
boundary or schema-3 successor for this lineage. This establishes the scoped negative history
disposition from affirmative records; it does not authenticate arbitrary out-of-band activity
or freshly certify a private file's availability/currentness. Future private binding must
still match this exact owner-identified predecessor and the complete required authority.

**Sidecar semantics checked against actual implementation.**
[DEC-073 verification](../Tools/RailwayStorage/DEC073_VERIFICATION.md),
[`IdentityTransition.validate`/`publish`](../Tools/RailwayStorage/Sources/IdentityTransition.swift),
[`RailwayArtifactBuilder.build`](../Tools/RailwayStorage/Sources/RailwayArtifactBuilder.swift)
and [runtime metadata validation](../TSUGINO/Data/Storage/RailwayArtifact.swift) distinguish
transition history from ordinary build/editorial histories. An empty `History` container is
representable and may be decoded as provisional `previousHistory` input. It is never a
successful zero-transition output: validation must append/validate a nonempty operation
boundary targeting schema 3 at previous revision + 1 before returning publication authority.
Retained-history rebuild rejects an empty boundary list or transition history with schema 2;
runtime schema 1 rejects the identity-transition input role across every build revision.
Thus the accepted tooling neither produces nor retains a zero-transition sidecar for this
schema-2/runtime-1 checkpoint. Every published DEC-073 sidecar contains a validated applied
boundary. Invented test histories and measurement histories are not this real lineage's history.

**Limits and next gate.** This binding does not erase or replace any original authority bytes,
declare historical allocation IDs empty, prove complete review/attachment coverage, establish
`historyComplete = true`, assign `baselineID`/owner-workflow metadata, approve a Checkpoint-1
baseline payload or construct baseline/H0/current-checkpoint artifacts. It authorizes no
conversion request, conversion, minting, registration or Checkpoint-2 implementation. P2-S9
and P3-T1 remain incomplete; Phase 3 remains In Progress. The next safe task is a separately
authorized complete private allocation/review/attachment/dependency-closure and baseline-
metadata audit, consuming this narrow legacy-state binding while preserving all other history.
This chronology audit accesses repository authority only; no private/provider artifact,
test/build or implementation change is involved. Historical records above remain unchanged.

#### Checkpoint 1 real schema-4 conversion complete — 2026-10-09

**Checkpoint 1 real schema-4 conversion: complete.** The separately owner-approved real
conversion executed exactly once against the validated schema-2 revision-6 current context.
The accepted lineage now has a verified **private current schema-4 revision-7 successor**.
Complete retained history contains the approved baseline and exactly **one conversion boundary**.
This dated execution overlay establishes the new current status; earlier tooling, pending
binding and no-real-conversion statements retain their historical meaning when written.
No new decision or change to Accepted DEC-083/084 semantics is introduced.

The following integrity/status pins are supplied by the completed execution report. This
documentation task does not reopen private provider payloads or publish private artifact paths.

| Conversion binding | Exact recorded value |
|---|---|
| Lineage | `tsugino.provisional.identity-registry` |
| Predecessor schema / revision | `2` / `6` |
| Original predecessor registry SHA-256 | `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b` |
| Original H0 SHA-256 | `244d11925786d75eaa9b47c010d1961cb9fc4d7de9e483ab960de4a6c5c4d0fb` |
| Approved conversion request ID | `p2s9.checkpoint1.schema2to4.20261009.001` |
| Approved conversion request SHA-256 | `de0db752ace11907b503d155c912a3ec022887e42771d3271978fe81e991baff` |
| Conversion approval review ID | `p2s9.checkpoint1.schema2to4.approval.20261009.001` |
| Conversion approval `approvedAt` | `2026-10-09T04:18:00Z` |
| Conversion approval SHA-256 | `c7ce26c6240f8a2f34da6d773e8a250c3a5a0c608c42d124e88bb69cf375ad64` |
| Private current successor schema / revision | `4` / `7` |
| Successor registry SHA-256 | `cf66f75c68205ccab365452773d86b7143b97f1eca6f36659ba3f8bffd45562c` |
| Successor history SHA-256 | `ec63f5aa7a930c8d7941be8edc39a34ee81fd3b7b2f0e71de93bec293b0c8017` |
| Conversion manifest SHA-256 | `3d4b1a42dba1a6ee87448eb2fb18406285cd3385ca23a71fa63b5e66567dfe9b` |
| Conversion boundary SHA-256 | `29e050edc35ff72793d415f06c40b1cce12e9c8087135d00756869ca7d519cee` |

**Verified execution facts.** Published `apply` ran exactly **once** and returned `converted`.
Publication completed normally, with **no durability error and no retry**. Published
`verify-bundle` passed with the exact manifest digest above. Separate non-author independent
review passed **all 21 requested execution criteria**, with no unresolved material findings.
The original schema-2 registry, baseline, H0, checkpoint and request artifacts remained unchanged.

The resulting private registry contains **275 active / 0 retired identities** and
**716 active / 0 absent / 0 retired references**, including **0 Trip identities** and
**0 `gtfs.trip_id` references**. All existing identity/reference semantic fields were preserved;
the conversion delta is only schema **2 -> 4** and revision **6 -> 7**. This conversion supplies
no provider equivalence or new source evidence.

**Remaining gates.** Checkpoint 1 alone is complete. **P2-S9 and P3-T1 remain incomplete;
Phase 3 remains In Progress; live/default routing remains unconfigured.** Real Trip
allocation/registration, movement evidence, endpoint dispositions, immutable S9 snapshot
acceptance, P3-T1 real import and production registry adoption remain unresolved. App/runtime
schema-4 consumption was not introduced; SQLite and routing state were not changed.

The existing accepted, owner-approved **distinct-new-run correspondence** remains unchanged
and was **not consumed by Checkpoint 1**. It remains future Checkpoint-2 authority/input.
**Checkpoint 2 has not begun; its real Trip mint/registration tooling remains unimplemented.**
The next separate major task is to **design and separately authorize the first-real-Trip
Checkpoint-2 mint/registration workflow against the exact verified schema-4 revision-7 current
checkpoint**. This documentation publication neither designs nor authorizes that workflow.

#### Checkpoint-2 tooling implementation overlay — 2026-10-09

This overlay supersedes only the earlier **tooling-unimplemented** status above. The bounded
`Tools/TripRegistration` first-Trip tooling now implements the accepted refined Model B using
**invented fixtures only**: complete eligibility/history/dependency/resource validation, durable
exclusive preparation before OS CSPRNG, exact unapproved target/request retention, separate exact
owner approval, and RNG-free application/replay. The isolated tool adds strict registration
request/context v1, exact predecessor-preserving history v2 and a distinct registration bundle
manifest. No accepted DEC/product semantics or app/shared/runtime source was changed.

The original conversion implementation/history-v1 rules remain in force. Registration is limited
to exactly one active Trip and one exact `gtfs.trip_id` reference, permanent prebound approval
review-ID `attachedBy`, checked revision increment and preservation of every existing record.
Correspondence proposal/approved-content/original-record digest domains remain distinct; successful
history binds one business use while allowing exact historical replay. Explicit owner checkpoint
and workspace/output bindings do not provide universal cross-path fork exclusion.

Verification: final standalone build passed. The final complete invented suite passed
**18 functions / 359 cases, 0 failures, 0 skips, 0 warnings**, including the unchanged
**8 functions / 142 conversion cases** (subsets, not cumulative runs). Separate non-author
implementation review passed **all 20 requested criteria**, with no unresolved material findings.
The reviewer independently rebuilt the standalone production tool and reran the complete invented
suite: **18 functions / 359 cases, 0 failures, 0 skips, 0 warnings**, plus the published-Python
five-constant golden check. The two complete runs are reported separately, never added together.
The suite includes
independently Python-generated correspondence goldens, interrupted/exhausted preparation,
no-redraw replay, atomic publication/recovery, diagnostics privacy and a predecessor history
above 10 MiB within the 64 MiB v2 envelope.

**No real use occurred.** No real/private correspondence, source key, registry/history, archive,
mapping or provider artifact was accessed. No real TripID/request/approval was created,
correspondence was not consumed and no real registry mutation/revision 8 exists. The supplied
published Checkpoint-1 state remains schema 4 / revision 7, **275 active identities / 716 active
references / zero Trip identities / zero `gtfs.trip_id` references**; it was not reopened here.
P2-S9/P3-T1 remain incomplete, Phase 3 remains In Progress, and live/default routing remains
unconfigured. Movement, endpoints, immutable S9 snapshot acceptance, import and production
adoption remain separately gated.

Next safe action after successful independent implementation review: owner review of tooling and
publication scope. Source publication must be separately authorized, followed by a separately
authorized real private binding/preparation task. Tooling implementation/test/review grants no
real candidate preparation, approval or execution authority. No staging, commit or push is part
of this task.

#### First real canonical Trip registration complete — 2026-10-09

**First real canonical Trip registration: complete. P2-S9: incomplete.** The exact
owner-approved Checkpoint-2 request was applied once, advancing the authoritative private
lineage `tsugino.provisional.identity-registry` from **schema 4 / revision 7 to revision 8**.
This dated overlay establishes current status after the conversion and tooling records above;
their earlier unimplemented, pending-allocation and no-real-use statements remain historical.
No new product decision or change to Accepted DEC-083/084 semantics is made.

The following safe pins/counts are supplied by the completed execution report, classified
`CHECKPOINT2_FIRST_REAL_TRIP_REGISTRATION_COMPLETE`. This documentation publication does not
inspect private identifiers, source keys, correspondence payloads or bundle contents.

| Registration binding | Exact recorded value |
|---|---|
| Approved registration request ID | `p2s9.checkpoint2.first-trip.20261009.001` |
| Approved registration request SHA-256 | `77ba552eaa8584084b6cd7f6f5ae7137bdf545d90c683d874f7dcfe0ca887e10` |
| Owner approval `approvedAt` | `2026-10-09T06:49:05Z` |
| Registration approval review ID | `p2s9.checkpoint2.first-trip.approval.20261009.001` |
| Registration approval SHA-256 | `c7e4ef0ca6f051d5241b85bc708c69a57d95c2c52a191980fa2ce2ead58c5024` |
| Predecessor schema / revision | `4` / `7` |
| Predecessor registry SHA-256 | `cf66f75c68205ccab365452773d86b7143b97f1eca6f36659ba3f8bffd45562c` |
| Predecessor history-v1 SHA-256 | `ec63f5aa7a930c8d7941be8edc39a34ee81fd3b7b2f0e71de93bec293b0c8017` |
| Predecessor conversion manifest SHA-256 | `3d4b1a42dba1a6ee87448eb2fb18406285cd3385ca23a71fa63b5e66567dfe9b` |
| Authoritative private successor schema / revision | `4` / `8` |
| Successor registry bytes | `911172` |
| Successor registry SHA-256 | `f15d539697ab7dc8c8f0bfc7bd59b37bca0680948754d42124a9d2fec45bfb9a` |
| Successor history schema version | `2` |
| Successor history bytes | `25165726` |
| Successor history SHA-256 | `1a165a1166a77555afedb488e841487572335a2cbbb336dac5261e24ba83fc6f` |
| Registration boundary SHA-256 | `1c4fe71cff7f94e7d7fbe7b955464240442b978f40e050c5e6020d73af72837f` |
| Registration manifest SHA-256 | `4f1683ee6a1ee678eddff9fdebd8740a67272185f50adf957cfa70d0cd6c772b` |

The successor contains **276 active / 0 retired identities** and **717 active / 0 absent /
0 retired references**, including exactly **1 Trip identity** and **1 `gtfs.trip_id` reference**.

> All predecessor 275 identities and 716 references, including their existing authority fields,
> were preserved. The only accepted registry semantic delta is one active Trip and one active
> Trip-only `gtfs.trip_id` reference, with revision 7 -> 8.

**Execution and verification.** Published `apply-registration` executed exactly **once** and
returned `registered`, with **no durability uncertainty, no retry and no second apply**.
The output registry was byte-identical to the approved request target. The new reference's
permanent, non-null `attachedBy` equals `p2s9.checkpoint2.first-trip.approval.20261009.001`.
Published `verify-registration-bundle` returned `bundleValid` with the exact registration
manifest SHA above. Separate non-author execution review passed **24/24**, with no unresolved
material finding. No post-publication apply replay was executed.

**Immutable lineage and correspondence.** History v2 retains the exact predecessor history-v1
bytes, preserves its original conversion boundary and adds exactly one `registerFirstTrip`
boundary. There are exactly **two logical lineage boundaries**: schema-2 -> schema-4 conversion,
then first Trip registration. The original revision-7 bundle remains unchanged. The previously
owner-approved `distinctNewRun` correspondence was consumed exactly **once** as business
authority for this registration. Its proposal, approval and original artifact remain unchanged;
the exact association is retained immutably by the registration request/history. Exact historical
replay semantics remain separate from a new allocation.

**Current readiness.** For this first retained candidate, recurring identity/source-key
correspondence, canonical Trip allocation, the real schema-4 current checkpoint, checkpoint-bound
owner approval, first real Trip registration, permanent `gtfs.trip_id` attachment and immutable
registration/history boundary are resolved. Registration alone is not authoritative untimed
Trip snapshot acceptance. [The dated readiness overlay](P2_S9_REAL_READINESS.md#current-status-overlay--2026-10-09-asiaseoul)
separates these resolved gates from the preserved 2026-10-03 assessment.

Remaining P2-S9 gates are positive movement / line traversal evidence; through/fragments
continuity where applicable; independent origin and destination boundary dispositions;
service-type evidence where applicable; immutable real S9 packet/snapshot assembly; exact
selected predecessor/snapshot binding; independent real S9 snapshot review; and owner S9
acceptance. The current remaining question is whether the retained candidate has sufficient
positive movement, independent endpoint and immutable snapshot evidence to construct and accept
the first authoritative untimed Trip snapshot. This documentation task performs none of that
reassessment or evidence access.

**Downstream status unchanged:** P2-S9 **incomplete**; P3-T1 real import **incomplete**;
production registry/runtime adoption and production route-search adoption **incomplete**;
app/default routing **unconfigured**; SQLite/runtime **unchanged**; Phase 3 **In Progress**.
The private revision-8 registry is not production/runtime adoption. No S9 snapshot acceptance,
timetable import, runtime/app/routing change or private identifier/path publication occurs here.

#### Approved early route-search status/action view — 2026-10-05

The owner authorizes this narrow exception to Phase 3's contracts/copy boundary; broader Phase
7/8 screens and Phase 11 hardening are not started or completed. `RouteSearchStatusView` accepts
only the existing presentation, AppLanguage and action callback. It renders approved status and
supplementary feedback text, a searching spinner and exactly the supplied actions in order.
Buttons forward original descriptors unchanged; the host still owns lifecycle/guards. System
controls, multiline body text and vertical buttons accommodate large text without scaling it down.
Central language resolution remains Japanese/Korean/otherwise English; no language selector.

AppShell, AppEnvironment, coordinator, mapper/copy and routing defaults remain unchanged. No
route cards, endpoint entry, navigation, search call, history, caching or data delivery. DEBUG
previews and test attachments are explicitly named fixtures; no invented timetable is presented
as real service. The component needs a future host for actual feature-flow integration.

Validation on explicit iPhone 17 / iOS 26.5 Simulator: final view suite **4 functions / 4 cases
passed**. Separately, unchanged mapper/copy suites **8 functions / 54 cases passed** in the earlier
combined run; overlapping/superseded view executions are not added. Debug dependencies and a
standard Release app/extension build passed. Earlier render-helper captures had unsupported
spinner rendering and fitted-height/safe-area cropping; these were superseded by final UIKit-hosted
captures, not accepted as visual evidence. No application behavior changed to accommodate them.

Normal and largest Dynamic Type renders cover Japanese, Korean, English and French-tag English
fallback; fallback pixels match English for the tested unconfigured state. Final light-mode
393×1200 content-inspection captures show multiline status/feedback and system buttons; representative
Japanese searching/scoped-empty, Korean feedback/incomplete and English unavailable/cancelled
images were directly inspected. This canvas does not prove fit in an iPhone viewport: future hosts
must provide scrolling when needed. Native Text/Button labels and redundant-spinner accessibility
hiding were reviewed. Actual VoiceOver/Accessibility Inspector operation, touch hit-testing,
physical-device, dark-mode and narrower-width layout checks were not performed. Action tests invoke
the concrete button handler and verify unchanged descriptors/identities; they do not simulate taps.

Separate non-author independent review approved the final implementation, tests, representative
render captures and documentation with no material findings. Scope/privacy and whitespace checks
passed for only the new view, focused tests and DESIGN/ROADMAP. Pending ODPT follow-up remains unanswered per owner;
no correspondence/feed access. All 15 launch services remain preserved; live routing unconfigured,
reference default and append opt-in. P3-T1/Phase 3 remain incomplete; S9 retains 14 classification
and 14 ordering gaps. Leave changes unstaged/uncommitted for publication review.


## Goal

Integrate a replaceable route-search provider without leaking provider models into the product domain.

**Accepted planning placement (DEC-074): P3-T1 — Timetable Contract and Static
Schedule Import** owns the separate timetable contract/import work, prerequisite
to consumption of imported schedules here and scheduled runtime behavior in Phase 5.
This adds planning scope only; semantic design acceptance precedes implementation.
Real import requires S9 passenger-stop mapping, S4 identity/provenance, local-baseline
acceptance and identified authorized inputs. Independent provider evaluation and
synthetic adapter work are not blocked. See DEC-074 for the authoritative boundary.

## Included

- `RouteSearching`
- provider Client
- DTO
- Adapter
- Mapping
- `RouteCandidate`
- route alternatives
- Japanese / English / Korean route content
- basic route-search diagnostics

## Explicitly Excluded

- active journey tracking
- realtime trip progression
- final route-results visual polish
- Live Activity

## Implementation Tasks

- integrate selected provider
- map provider stations/lines to canonical IDs
- normalize route candidates
- represent transfers
- preserve through-service continuity
- expose scheduled train context
- handle provider errors
- cache safe route-search responses where permitted

## Tests

- direct route
- one transfer
- multi-transfer
- local/express
- through service
- malformed response
- unknown mapping
- provider outage

## Acceptance Criteria

- feature code receives canonical `RouteCandidate`
- provider DTOs never reach Domain/UI
- through service is not falsely converted to transfer
- route-search failure is recoverable

## Exit Criteria

TSUGINO can obtain a usable canonical journey plan for supported Tokyo routes.

## Decision Gate

Confirm whether the chosen provider remains suitable for production based on:

- data quality
- pricing
- licensing
- trip identity
- mapping stability

---

# Phase 4 — Realtime Provider Integration

## Goal

Normalize realtime railway data into provider-independent snapshots.

## Included

- ODPT / GTFS-RT integration
- Trip Updates
- Vehicle Position where available
- Alerts where available
- freshness tracking
- provider capability declarations
- realtime fixtures

## Explicitly Excluded

- automatic train detection
- journey UI
- notification logic
- continuous background location

## Implementation Tasks

- realtime clients
- DTO/protobuf decoding
- provider adapters — GTFS-RT adapter (Toei, Realtime Journey Tracking tier) and ODPT JSON status adapter (`odpt:TrainInformation` + Alert for the Tokyo Metro Scheduled Journey Guidance tier; DEC-047)
- canonical trip mapping
- snapshot generation
- freshness policy
- stale/unavailable states
- freshness and expiration enforcement for Basic-License dynamic data (Tokyo Metro status/Alert): surface `dc:date`, never display data outside `dct:valid`, refresh at `odpt:frequency` where supplied, never show superseded dynamic data (audit §3.6.2, §3.9)
- Toei freshness as an engineering safeguard from GTFS-RT header/entity timestamps (DEC-024/038) — documented as product integrity, not a license duty (audit §3.5.3)
- provider-cache deletion capability: every cached Basic-License payload (memory, disk, fixtures) can be purged on termination or license change (audit §3.6.2, RK-5)
- per-service capability declarations (service/feed scope, incl. the Toei Nippori-Toneri Liner: no TU/VP — DEC-046)
- Liner Alert/status payload verification (identifiers, semantics)
- promotion gate for a service whose TU/VP later becomes officially available (DEC-046 evidence gates)
- centralized refresh coordinator
- cancellation support

## Tests

- on-time trip
- delayed trip
- cancellation
- stale feed
- missing fields
- vehicle position absent
- trip updates absent for a service (per-service capability; no schedule-derived synthetic progress)
- service alert
- expired dynamic data (`dct:valid` passed) is not displayed
- provider-cache purge leaves no Basic-License payload
- malformed payload
- mapping mismatch

## Performance Tasks

Measure:

- decode time
- memory allocation
- refresh overhead
- duplicate parsing
- network request frequency

## Physical Device Test

- repeated realtime refresh
- foreground/background transitions
- network interruption/recovery

## Acceptance Criteria

- realtime data reaches Domain only as canonical snapshots
- stale feeds are detectable
- refresh ownership is centralized
- heavy decode work stays off main actor

## Exit Criteria

Realtime data is reliable enough to drive Journey progression.

---

# Phase 5 — Journey Engine

> Phase 1 defines the journey domain types and the `JourneyEngine` protocol boundary; **this phase owns the engine's runtime behaviour** (DEC-050).

**Accepted planning dependency (DEC-074):** schedule-derived runtime behavior
requires P3-T1's separately accepted timetable contract and validated data/consumer
binding. This does not block independent synthetic engine work, transfer ownership
of progression, or authorize timetable implementation.

## Goal

Implement the authoritative state machine for active railway journeys.

## Included

- Journey progression
- current station
- next station
- remaining stops
- transfer approach
- destination approach
- realtime reconciliation
- service pattern change
- through service
- journey events
- interruption detection

## Explicitly Excluded

- polished UI
- final Live Activity
- pixel animation
- advanced rerouting

## Implementation Tasks

- implement `JourneyEngine`
- define transition rules
- implement selected-trip binding
- support multi-leg progression
- calculate remaining stops from actual trip pattern
- reconcile delays
- process cancellation
- detect inconsistent movement
- generate recovery proposals

## Tests

Use recorded fixtures for:

- local ride
- express skipping stations
- one transfer
- multiple transfers
- through service
- delayed train
- cancelled train
- changed destination
- stale realtime
- long journey
- ambiguous progression

## Acceptance Criteria

- same inputs produce same transition outputs
- views do not mutate journey truth
- express/local stop counts are correct
- through service works without transfer hacks
- all important journey bugs can become fixtures

## Exit Criteria

Journey progression is domain-complete enough to power every presentation surface.

---

# Phase 6 — Persistence + Recovery

## Goal

Make active journeys resilient to app/process/network interruption.

## Included

- active Journey persistence
- Journey resume
- recent journeys
- missed train recovery
- wrong train recovery
- selected train replacement
- journey cancel/end
- schema versioning
- migration tests

## Explicitly Excluded

- automatic train detection
- cloud sync
- favorites unless scope permits

## Implementation Tasks

- implement `JourneyRepository`
- persist active journey
- implement resume reconciliation
- implement `JourneyRecoveryCoordinator`
- implement missed-train flow
- implement wrong-direction correction
- implement manual journey correction
- implement safe journey termination
- clean stale notifications/activities on end
- provide a provider-data deletion path for persisted caches (Basic License Art. 13(3); installed-cache behaviour pending audit §3.12 item 9)
- no raw or restorable export/share of Tokyo Metro (Basic-License) data in any persistence or sharing feature (audit §3.6.3)

## Tests

- save/reopen
- app termination simulation
- stale persisted data
- missed train
- changed train
- cancellation recovery
- corrupt persistence
- migration

## Physical Device Test

- start journey
- background app
- terminate/relaunch
- restore journey
- lose/recover network

## Acceptance Criteria

- active journey survives normal process loss
- invalid persisted state does not crash the app
- recovery preserves valid route context where possible

## Exit Criteria

Journey state is durable and recoverable.

---

# Phase 7 — Design System + Pixel Journey Scene Foundation

## Goal

Build TSUGINO's reusable visual identity without coupling animation to journey truth.

## Included

- design tokens
- dark-first palette
- railway line colors
- reusable components
- pixel asset system
- pixel train
- platform scene
- tunnel scene
- motion primitives
- reduced-motion behavior
- JourneySceneResolver

## Explicitly Excluded

- every planned pixel environment
- final illustration polish
- system-surface animation beyond state transitions

## Implementation Tasks

- implement tokens
- line badge system — safe interim v1 visual treatment (audit §3.7–§3.8, RK-15/16): no official operator logo; no official Tokyo Metro station-number/line-symbol marks; textual line codes; provider line-colour values as unmodified tokens with source provenance (DEC-018); neutral project-owned badges that do not imitate official mark geometry or typography
- design review check that project badges are not confusingly similar to official marks and that provider colours are never presented as "official" after adjustment
- typography hierarchy
- reusable journey components
- reusable pixel sprites
- scene composition
- train motion primitives
- stop/depart/ride/approach transitions
- Reduce Motion variants

## Performance Tasks

Measure:

- frame pacing
- CPU/GPU impact
- memory
- asset footprint
- idle animation cost

## Physical Device Test

- long-running animation
- background/foreground
- Reduce Motion
- dark environment readability

## Acceptance Criteria

- animation cannot mutate Journey state
- scene assets are reusable
- no critical information uses pixel fonts
- performance is stable on target device

## Exit Criteria

The app has a reusable visual language ready for feature screens.

---

# Phase 8 — Main App Journey Flow

## Goal

Implement the complete foreground user flow from route setup through active journey.

## Included

- Home
- nearby station suggestions
- recent journeys
- station search
- origin/destination selection
- route results
- train selection
- active journey screen
- dynamic station name
- main-app pixel movement
- journey cancel/end
- recovery entry points

## Explicitly Excluded

- final Live Activity
- full transfer car/door guidance
- nationwide support

## Implementation Tasks

- build feature presentation models
- connect route search
- connect realtime candidates
- explicit train selection
- start Journey
- render JourneyState
- update current/next station
- animate pixel environment
- surface freshness state
- degraded-mode UI states for services without trip-level realtime (scheduled / status-Alert / unavailable provenance — DEC-046)
- Scheduled Journey Guidance presentation for the nine Tokyo Metro lines and the Liner (DEC-047): scheduled timeline, clock-based scheduled progress labelled as scheduled, scheduled next stop, status/Alert notices that are never concealed by scheduled progression; no live badge or physical-train claim
- Legal/Data Sources screen (FEATURES §15): Toei CC BY 4.0 attribution fields (provider, content title, source link, license name + link, modification indication, supplied notices — audit §3.5.2) and the Tokyo Metro three-part source / accuracy-not-guaranteed / developer-contact notice (audit §3.6.2); machine-translation disclosure where used
- surface recovery actions — reselection-only proposals as "choose another train", never as a promise that another train exists; ending always available (DEC-064 F)
- explain every refused rider action from its `JourneyInputRejection` case with the specific cause and next step documented in DEC-064 E — localized, no raw enum names or developer diagnostics, and no generic fallback that hides a distinct cause; name the mismatched boarding and/or alighting station for `trainStationsDiffer` and never present replanning as an in-app action; background-input rejections (`timePassed`, `observed`) may be handled without a notification

## Tests

- JP/EN/KO layouts
- long station names
- no realtime
- delayed train
- missed train
- transfer journey
- through service
- mixed-tier journey (Toei realtime leg + Tokyo Metro scheduled leg): scheduled progress never renders as live (DEC-047)
- Dynamic Type

## Physical Device Test

Perform end-to-end simulated and real journeys.

## Acceptance Criteria

A user can:

1. search a route,
2. choose a train,
3. start tracking,
4. see station progression,
5. recover from a changed train,
6. end the journey.

## Exit Criteria

The main-app experience is coherent before system surfaces are connected.

---

# Phase 9 — Live Activity + Dynamic Island

## Goal

Make the journey useful when the main app is closed or locked.

## Included

- Live Activity state mapper
- lifecycle coordinator
- Lock Screen journey progress
- discrete pixel train progress
- Dynamic Island minimal/compact/expanded states
- stale handling
- clean termination

## Explicitly Excluded

- continuous Lock Screen animation
- duplicated journey business logic
- full pixel-scene rendering inside Dynamic Island

## Implementation Tasks

- define Activity attributes/state
- implement derived presentation mapper
- start/update/end lifecycle
- map journey phases
- origin→destination progress
- pixel train position
- current station
- remaining stops
- transfer state
- arrival resolution
- Live Activity behaviour for legs without trip-level realtime (schedule/status-only presentation if designed; otherwise do not start — DEC-046); Scheduled Journey Guidance presentation explicitly labelled timetable-based for Tokyo Metro legs (DEC-047)
- system surfaces use textual line codes and unmodified colour values only; no official provider marks in Live Activity, Dynamic Island, or widgets until the ODPT written confirmation (audit §3.7, §3.12 item 3)

## Tests

- every journey phase
- transfer
- arrival
- cancelled journey
- stale realtime
- leg without TU/VP capability (no synthetic progress; honest or no Live Activity)
- review/regression check: no official provider mark asset is referenced from the extension target
- English text expansion
- Korean text expansion
- no transfer guidance

## Physical Device Test

Required on Dynamic Island-capable iPhone.

Test:

- app foreground
- app background
- lock screen
- Always-On if available
- journey state changes
- app relaunch
- activity termination

## Acceptance Criteria

- system surfaces never own journey logic
- journey state remains consistent with main app
- pixel train progress does not imply unsupported precision
- stale Live Activities do not remain after journey end

## Exit Criteria

TSUGINO's defining out-of-app experience is production-capable.

---

# Phase 10 — Notifications + Transfer Guidance

## Goal

Provide timely next-action guidance without creating notification noise.

## Included

- departure approach
- transfer approach
- destination approach
- cancellation
- recommended car where supported
- recommended door where supported
- stairs/escalator/elevator where supported
- transfer walking time where supported
- destination-exit guidance where supported

## Explicitly Excluded

- fabricated guidance for unsupported stations
- guaranteed full Tokyo car/door coverage

## Implementation Tasks

- implement notification event consumption
- implement guidance provider abstraction
- normalize confidence/provenance
- capability-gate guidance
- render transfer state
- render destination exit guidance
- handle missing guidance gracefully

## Tests

- guidance available
- guidance unavailable
- low confidence
- provider failure
- notification permission denied
- duplicate notification suppression

## Physical Device Test

- transfer approach alert
- destination approach alert
- lock screen interaction
- notification cleanup after journey end

## Acceptance Criteria

- guidance appears only when reliable
- no unsupported precision is invented
- notifications are contextual and sparse

## Exit Criteria

Journey assistance includes practical transfer behavior.

---

# Phase 11 — Localization + Accessibility Hardening

## Goal

Make Japanese, English, and Korean first-class and ensure the app remains accessible.

## Included

- JP/EN/KO localization review
- language resolution: Japanese / Korean / otherwise English
- station-name policy
- short-form system copy
- VoiceOver
- Dynamic Type
- contrast
- Reduce Motion
- non-color-only status
- large touch targets

## Explicitly Excluded

- additional languages

## Implementation Tasks

- review all strings
- verify unsupported device languages fall back to English
- ingest and review provider-supplied Korean labels where they exist (audited Tokyo Metro `odpt:Railway` titles for 9/10 lines and station-order titles; none in the audited Toei or Tokyo Metro static GTFS, none for `MarunouchiBranch`, none in static headsigns, none in retained dynamic status text) — reviewed inputs, never automatically canonical
- fill uncovered canonical Korean route/station/headsign names, search aliases, reading aliases, romanization variants, line-code aliases, and cross-operator identity normalization as project-owned data; never treat partial provider localization as complete canonical coverage (DEC-041/042, DEC-046)
- dynamic status/incident text localization remains a separate unresolved item (retained Tokyo Metro TrainInformation text was Japanese-only); Korean translation of Tokyo Metro provider strings and incident text, and the required machine-translation disclosure, are gated on the ODPT written confirmation (audit §3.12 item 7) — Toei strings may be translated under CC BY with modification indicated
- review railway terminology
- review Korean naturalness
- review English clarity
- test truncation
- localize notifications
- localize Live Activity
- audit VoiceOver labels
- audit Dynamic Type

## Tests

- all three languages
- long English labels
- Korean line/transfer text
- large accessibility sizes
- VoiceOver navigation
- reduced motion

## Acceptance Criteria

- no core flow breaks in any launch language
- critical state is never color-only
- system surfaces remain legible

## Exit Criteria

Localization and accessibility are release-quality.

---

# Phase 12 — Performance, Battery, Reliability + Licensing Audit

## Goal

Harden the app before public beta/release.

## Included

- profiling
- memory optimization
- network optimization
- realtime cadence tuning
- energy impact
- crash/error paths
- diagnostic quality
- data license verification
- provider production-readiness audit

## Implementation Tasks

- Instruments profiling
- main-thread audit
- animation audit
- refresh cadence audit
- static-data load audit
- memory-pressure testing
- offline/degraded-mode testing
- data attribution verification (Toei CC BY fields; Tokyo Metro three-part notice)
- license-change monitoring: re-check the ODPT Basic License, Specific Terms, Center Use Rules, Developer Guideline, catalog license labels, and the Tokyo Metro image resource against the sources and hashes recorded in the audit (§2.5, §3.1); record changes in the audit
- regression check that no official provider mark or raw provider payload ships in any target or export path (audit RK-15, §3.6.3)
- provider rate-limit verification
- logging privacy audit

## Physical Device Test

Long-duration journey simulations and real railway tests.

Measure:

- battery impact
- thermal behavior
- memory
- frame pacing
- network usage
- Live Activity stability

## Acceptance Criteria

- no known critical performance regression
- provider limits respected
- production data usage legally documented
- major journey failures have diagnostic evidence
- no unresolved critical architecture violations

## Exit Criteria

The app is technically suitable for beta.

---

# Phase 13 — Simulation & Remote Validation

## Goal

Validate the complete journey experience from Korea without requiring continuous access to Japanese railway field conditions.

## Included

- Journey Simulator
- Replay Realtime Provider
- time acceleration
- recorded GTFS/GTFS-RT fixtures
- provider contract tests
- network failure simulation
- location simulation for nearby-station flows
- JP/EN/KO language validation
- unsupported-language → English fallback validation
- Dynamic Island
- Lock Screen Live Activity
- long-duration simulated journeys
- remote TestFlight validation with Japan-based testers where available

## Implementation Tasks

- create replay provider conforming to realtime protocols
- build deterministic scenario manifests
- allow controlled time acceleration
- build realtime recording tooling for reusable fixtures
- simulate delay, cancellation, missed train, through service, and stale feeds
- validate system surfaces using replayed journeys
- capture structured diagnostic snapshots

## Acceptance Criteria

- core journey flows can be reproduced deterministically from Korea
- realtime provider contract changes are detectable
- JP/EN/KO and English fallback behavior are verified
- Live Activity and Dynamic Island stay synchronized during replay
- long journeys can be accelerated without changing domain truth

## Exit Criteria

The majority of product behavior is reproducible before Tokyo field testing.

---

# Phase 14 — Tokyo Field Beta

## Goal

Validate TSUGINO on real Tokyo railway journeys.

## Included

- selected supported operators — the DEC-047 launch set: Toei Subway and Tokyo Sakura Tram (Realtime Journey Tracking), the nine Tokyo Metro lines and the Nippori-Toneri Liner (Scheduled Journey Guidance)
- real route searches
- real train selection
- realtime tracking
- Live Activity
- Dynamic Island
- transfers
- recovery
- three languages

## Test Matrix

Include:

- underground lines
- above-ground lines
- direct ride
- transfer
- long journey
- express/local
- through service
- Toei ↔ Tokyo Metro transfer (mixed capability tiers)
- delays where safely testable
- weak network
- unsupported guidance stations

## Bug Handling Rule

Every serious field bug should produce, where practical:

1. diagnostic snapshot
2. reproducible fixture
3. regression test
4. code fix
5. document update if product/architecture truth changed

## Acceptance Criteria

- core journeys complete reliably
- station progression is trustworthy
- Live Activity stays synchronized
- recovery works in realistic conditions
- major provider inconsistencies are understood

## Exit Criteria

Product is ready for release preparation.

---

# Phase 15 — Release Preparation

## Goal

Prepare the initial App Store release.

## Included

- App Store metadata
- screenshots
- privacy disclosures
- permission copy
- acknowledgements
- data-source attribution
- support/legal pages
- final release build
- release checklist
- launch-copy check: App Store text and screenshots must not claim realtime tracking for all 13 subway lines; tier wording per DEC-047
- pre-release ODPT written-confirmation gate: any official Tokyo Metro mark, App Store screenshot/preview containing Basic-License data, offline-bundled Basic-License static data, or other ambiguous surface ships only after the corresponding audit §3.12 question is answered in writing; otherwise the release uses the text/colour fallback and omits the surface

## Explicitly Excluded

- post-launch regional expansion
- new major features

## Tests

- release configuration
- production endpoints
- attribution/notice screens present and correct per provider (CC BY vs. Basic License)
- clean install
- upgrade path
- permissions
- notifications
- Live Activity
- localization
- degraded network

## Acceptance Criteria

- release build passes all critical tests
- production API credentials/configuration verified
- required legal/data attribution present
- documentation reflects release truth

## Exit Criteria

Ready for App Store submission.

---

# Post-Launch Expansion Tracks

These are not immediate sequential phases and may be scheduled after real usage data.

## Track A — Tokyo Urban Rail and Airport Rail Expansion Programme (DEC-058)

Direction: TSUGINO intends to support all production-eligible Tokyo urban railways through staged expansion. Every promotion passes the production-eligibility gate (verified production licence; repeatedly verified payloads; implemented compliance duties; service/feed-scoped `RailCapability` declaration; deterministic canonical mapping). Challenge-only access never passes it; catalog presence alone establishes nothing.

Tiers (classification, not delivery status):

- **Tier 0 — accepted baseline:** 15 lines/services (13 subway lines, Tokyo Sakura Tram, Nippori-Toneri Liner).
- **Tier 1 — next candidates (Phase 2 gated data work):** TWR Rinkai Line, Tsukuba Express, Tama Monorail, Yurikamome; expected to qualify for scheduled guidance only if payload verification and the full production-eligibility gate pass; no capability tier is declared yet.
- **Tier 2 — Airport Rail, P0 priority, gated:** Narita (Keisei Main Line / Narita Sky Access corridor with Hokuso and Shibayama partner segments; JR East access) and Haneda (Keikyu Airport Line corridor; Tokyo Monorail). P0 means "enable as early as legally and technically possible", not "currently supported". **Blocked as of 2026-09-21:** Keisei, Hokuso, Shibayama, and Tokyo Monorail have no audited production data source; Keikyu and JR East are Challenge-only. Toei Asakusa Line support grants no rights over partner through-service segments.
- **Tier 3 — broader Tokyo rail:** JR East urban lines; Tokyu, Keio, Odakyu, Seibu, Tobu, Sotetsu; through-service partners — under the same gate; Challenge-only operators stay production-blocked.

Actions (durable; none performed yet):

- **Rights outreach and verification** — obtain or verify production-use rights and production-capable data sources from Keisei, Keikyu, Tokyo Monorail, JR East, Hokuso, and Shibayama (audit A9). No contact has been made; this entry records the need.
- **Periodic re-check** — at least quarterly, re-check blocked Airport Rail providers against the public ODPT catalog and licence texts; record each re-check in the provider audit with its date.
- Add each promoted operator through: adapter, canonical mappings (multi-provider aliases with provenance), capability declaration, fixtures, tests. No JourneyEngine rewrite should be required.

Airport service brands (Narita Express, Skyliner, Access Express, named Keikyu airport services, Tokyo Monorail service labels) are Trip/service-family or display data, never `LineID`s; DEC-061 defines train brand as a separate future fact, never a `LineID`, operator, direction, or service type, and leaves its representation to a later decision. That deferral does not remove the requirement: airport service-brand guidance remains required for Airport Rail support and needs verified data and that later contract.

---

## Track B — Regional Japan Expansion

Potential expansion:

- Kansai
- Chubu
- other regions
- nationwide coverage

Expansion depends on data and licensing quality.

---

## Track C — Automatic Train Detection

Research:

- location
- motion
- realtime candidates
- station progression
- confidence scoring

Must remain optional until reliability is high.

---

## Track D — Apple Watch

Potential:

- next station
- remaining stops
- transfer haptic
- destination alert

---

## Track E — Favorites and Habitual Journeys

Potential:

- pinned journeys
- commute shortcuts
- recurring route suggestions

---

## Track F — Richer Station Guidance

Potential:

- station interior navigation
- exits
- accessibility paths
- richer platform guidance

---

# Parking Lot / Deferred

Deferred items recorded once, per `AGENTS.md` §5.1. An entry here is not permission to implement it.

- **Repository-wide Swift concurrency-isolation warnings.** Under the current Swift 5 language mode with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, the Domain `Codable` conformances and custom decoders (S1 identifiers, S2 `LocalizedRailName`, S3b `GeoCoordinate`, the S3c `StationAdjacency` and `RailwayLineTopology` values, the S4a `Trip` and `TripLineSegment`, the S4b `ServiceTypeID`, `ServiceType`, and `TripServiceTypeSegment`, the S5a `Journey`, `JourneyLeg`, `RailLeg`, `RailLegAnchors`, `SelectedRailTrip`, and `WalkingTransfer`, and any later canonical Domain value of the same shape) emit `ConformanceIsolation` / `ActorIsolatedCall` warnings that Swift 6 language mode would diagnose as errors. Address them **together**, as one repository-wide decision before any Swift 6 language-mode migration; do not fix individual values inconsistently. This does not block current Phase 1 slices and is not a defect of any single slice. Owner: a future concurrency-migration decision (`DECISIONS.md`); no phase currently claims it.

---

# Roadmap Governance

## Phase Audit

Before completing every phase, perform:

1. scope audit
2. architecture audit
3. test audit
4. documentation audit
5. working-tree audit
6. physical-device audit when relevant

## Phase Completion

A phase is not complete merely because code exists.

It is complete when:

- acceptance criteria pass
- tests pass
- relevant physical-device tests pass
- documentation matches current truth
- known blockers are resolved or explicitly deferred
- architectural debt introduced by the phase is documented

## Scope Change

If implementation requires moving a feature between phases:

1. explain why,
2. update this roadmap,
3. update related documents,
4. add/update a decision record when significant.

## North Star

> **Build the railway truth first, then the experience around it.**

TSUGINO should never gain visual polish faster than it gains trustworthiness.


**P2-S8 DEC-073 acceptance and bounded synthetic implementation** (2026-10-01). Starting branch `phase/02-static-data`, HEAD `31732d7`, zero ahead/behind tracked upstream. The owner accepted revised DEC-073 and both explicit DEC-068 amendments. The prior draft/implementation entries remain historical; DECISIONS contains the single authoritative contract. All existing measurement work is preserved byte-for-byte.

- **Implementation:** pure retirement 1→0, replacement 1→1, merge many→1 and split 1→many through exact approved snapshot pairs, full delta accounting and explicit per-reference dispositions. Old bindings/first sightings/original names/provenance/attachment authority remain immutable in retained snapshots. New versions name predecessors and their own authority; one current version per key/revision. Ordinary reconciliation cannot reassign keys and provider-value reuse remains outside scope.
- **Versions and publication:** legacy registry v2/runtime v1 keep their semantics. The explicit registry v2→v3 comparison/runtime v1→v2 rebuild supports empty-successor retirement while retaining prior history; malformed/unsupported and reverse conversions fail without mutation. Complete validation and staged reopen precede exclusive atomic publication of a new runtime/history/receipt package. Runtime exposes retirement and compact build history without following successors; editorial evidence stays external, pinned by manifest hash.
- **Verification:** final synthetic storage runner passed eight applied scenarios, a second linked transition, exact reference/authority checks, stale/conflicting/wrong-kind/circular/unaccounted-change rejection, resource bounds, no-overwrite/early/late failure atomicity and reopen. All three package files repeat byte-identically from original and carried-forward inputs; a separate process also produces an identical package. No duplicate history or flattened successor chains. Full tool suite **211/211**; full app suite **591/591**, zero failures/skips, with Debug app/extension build on iPhone 17 Simulator (iOS 26.5); Release app/extension build passed. A final actor annotation correction passed **40/40** affected app checks and an incremental Release build, recorded in the linked verification record; broad suites are not repeated. No physical device or real artifact was used.
- **Review:** one focused in-session adversarial review fixed an unintended reverse-conversion path and missing collision checks against legacy attachment/withdrawal authority, with regressions. Final build diagnostics exposed a new actor-isolation warning on the decoder configuration key; the annotation was corrected. No repeated clean-review round or unrelated warning cleanup occurred. [Detailed evidence, boundaries and audit](../Tools/RailwayStorage/DEC073_VERIFICATION.md); final source/test/log fingerprints in the adjacent verification JSON.
- **Accepted-criteria audit:** the listed synthetic P2-S8 checks now pass: measured storage choice, complete repository/search behavior, no ordinary full-dataset reparse, reopen, data-version history and newly applied identity-retirement migrations. No known failure remains in this bounded migration scope. The prototype does not measure this implementation’s validation-on-open cost; validated-repository startup/load/memory evidence and broader Phase 2 physical performance acceptance remain separate outstanding work. **P2-S8 and Phase 2 are not declared complete.** Registry-of-record/production IDs, actual real-data repository delivery, Q3 publication, Q4 new Metro-derived translations and item 5/bundling gates remain unchanged. No provisional IDs are promoted. All implementation/tests/docs remain uncommitted; no acquisition, minting, UI, real transition, bundling, publication, push or merge occurred.


**P2-S8 final validated-repository performance evidence** (2026-10-01). Branch `phase/02-static-data`, HEAD `31732d7`, zero ahead/behind tracked upstream; existing SQLite/transition implementation and the earlier measurement prototype were preserved. All 175 saved correctness fingerprints matched before this work. [Predeclared method](../Tools/RailwayStorage/Measurement/METHOD.md), [full report](../Tools/RailwayStorage/Measurement/RESULTS.md), [raw final samples](../Tools/RailwayStorage/Measurement/results.json) and [verification record](../Tools/RailwayStorage/Measurement/verification.json) identify the actual measured code.

- **Method/environment:** native macOS CLI, Apple M2/16 GiB, macOS 26.6.2, Swift 6.4 `-O`/language mode 5, SQLite 3.51.0. Five fresh-process repetitions for each of 258/15/2/6 and 25,800/1,500/200/600 invented station/line/operator/alias datasets, with baseline and one applied replacement-history case. Normal full open-time validation stays enabled. Setup/build is separate; OS caches and host activity are uncontrolled. All artifacts use the system temporary filesystem. Workspace preparation returned `unavailable`; its precise cause is unverified (minimal hard-link probes worked at both locations). This is not app-startup, Simulator timing or physical-iPhone evidence.
- **Final runtime medians, baseline/history respectively:** artifact size **184,320 / 184,320 bytes** at launch size and **15,974,400 / 15,974,400 bytes** at scale; validated open **23.86 / 23.74 ms** and **2,245.84 / 2,178.05 ms**; first query **0.116 / 0.097 ms** and **0.657 / 0.808 ms**; post-open full Domain load **3.50 / 3.52 ms** and **448.59 / 344.21 ms**; warm median exact query **0.036 / 0.036 ms** and **0.220 / 0.198 ms**; ordinary peak RSS **11.73 / 11.70 MiB** and **202.91 / 202.88 MiB**. The report retains min/max, p95, all memory checkpoints and close/reopen samples. Warm RSS growth was at most **0.078 MiB** across three passes; this includes harness/allocator effects and is not a leak proof.
- **Observed bounded issue/fix:** the membership check scanned all stations for each line (38.7 million probes at scale). It now accumulates declared members once, retaining exact two-way set validation. Original scale open medians **5,276.42 / 5,393.40 ms** fell to the final values above, with roughly **2.5 MiB** additional peak RSS. Original/final cohorts and all ranges are retained, not a claimed controlled speed ratio. Launch-sized ranges overlap. Scale startup still takes seconds and roughly 203 MiB on this Mac; no device-readiness claim follows. All four runtime artifact hashes are unchanged before/after and across repetitions.
- **Ordinary-use and history:** every process measured one validation invocation at open and zero additional validation/full station loads during ordinary queries; 3,589 matched station decodes include first/correctness/priming/timed queries. Source-derived oracle construction is once per validation, not a new measured counter; persisted index rebuilding is absent from the read-only path. Reopen revalidates normally. The applied history adds one retired ID and a second build revision; runtime metadata grows from 467 to 1,092 bytes, while full external history is 57,151 / 5,502,151 bytes. Overlapping timing ranges establish no measurable single-boundary history penalty, not a maximum-history guarantee.
- **Affected verification only:** optimized harness compilation; **40 total pre/post samples** with exact query, deterministic artifact and read-immutability checks; storage/transition runner passed; **25/25** filtered name-tool cases; **8/8** Simulator index/repository tests including shared and contradictory membership cases, zero failures/skips. No broad suite or repeated clean build ran. Earlier full-suite/Release evidence remains historical; unchanged paths retain their fingerprints. Original prototype files and existing real artifacts were not changed.
- **Criteria audit:** measured storage choice, actual validated-repository size/open/query/load/memory/reopen evidence, ordinary-use no repeated full parse, deterministic storage and existing version/retirement migration checks are satisfied for the synthetic scope. **At that measurement stage, paired app-startup attribution and P2-S11 physical evidence remained outstanding. The subsequent recovered Simulator attribution is recorded below; physical checks remain outstanding.** At that stage the app had no repository startup hook; the [minimal paired app/device procedure](../Tools/RailwayStorage/Measurement/DEVICE_PROCEDURE.md) identifies measurement-only instrumentation and explicit owner selection/authorization of a supported iPhone (never `LunaTestphone`). CLI timings do not substitute for those requirements. **P2-S8 and Phase 2 are not declared complete.** Production-registry/IDs, real-data delivery, Q3 publication, Q4 translation and item 5 bundling remain separate unchanged gates. No provider data, production IDs, acquisition, publication, UI feature, physical-device interaction, commit, push or merge occurred.


**P2-S8 recovered Simulator app-startup attribution** (2026-10-01). Original
`phase/02-static-data`, HEAD `31732d7`, zero ahead/behind tracked upstream. Recovery
verified all 229 pre-startup files: none missing, only the expected app-entry hook
changed; the three expected probe/method/runner files were added. Existing
implementation and prior measurements remain unchanged. Saved evidence hashes
and metric exports validate; originals, logs, runner and physical procedure are
preserved in durable owner-only evidence, outside Git.

- **Completed Simulator attribution:** [report](../Tools/RailwayStorage/Measurement/Startup/RESULTS.md),
  [method](../Tools/RailwayStorage/Measurement/Startup/METHOD.md) and
  [samples/hashes](../Tools/RailwayStorage/Measurement/Startup/results.json).
  Release optimized app; iPhone 17/iOS 26.5 Simulator on M2 macOS. Five alternating
  baseline/enabled pairs, **10/10** saved focused checks; no reruns during recovery.
  First-frame medians 841.142 / 818.334 ms; paired delta median **+3.170 ms**, range
  **−80.069…+22.108 ms**. **No demonstrated improvement or regression.**
- **Repository attribution:** open including normal validation median 37.832 ms,
  first query 0.120 ms, app-init-hook-relative ready 40.326 ms. Compile-flagged
  instrumentation schedules a detached task; repository open/validation stays
  off the main actor and initial rendering does not await it. One validation pass,
  zero explicit full loads, two distinct same-name results in each enabled probe.
  Synthetic artifact and installed executable hashes remain unchanged. No
  validator-only or process-launch-to-readiness timing is claimed.
- **Limits/gates:** caches uncontrolled; Simulator/automation overhead applies.
  Physical cold-launch, search, memory and offline checks remain outstanding and
  require authorization for a specific supported iPhone. The
  [physical procedure](../Tools/RailwayStorage/Measurement/DEVICE_PROCEDURE.md)
  separates that work. **P2-S8 and Phase 2 remain open.** Production registry/IDs,
  real-data delivery, Q3/Q4 and publication/bundling gates remain unchanged. No
  recovery code change, measurements/builds/tests rerun, real-artifact change,
  commit, push or merge.


**P2-S8/P2-S11 authorized physical-device evidence, partial** (2026-10-01). Only
the explicitly authorized paired iPhone 17 Pro Max was targeted: USB, iOS 27.0,
Developer Mode verified after owner setup. Temporary signing overrides only; no
existing TSUGINO installation was found, no uninstall or data reset performed.
[Physical report](../Tools/RailwayStorage/Measurement/Physical/RESULTS.md),
[method](../Tools/RailwayStorage/Measurement/Physical/METHOD.md) and
[workload samples](../Tools/RailwayStorage/Measurement/Physical/workload-results.json).

- **Completed:** five process repetitions each for invented launch-sized ordinary
  and applied-transition-history artifacts. Exact Unicode/explicit alias/miss,
  stable ordering, distinct same-name stations, reopen and full Domain checks
  passed in all ten. Owner confirmed Airplane Mode/Wi-Fi off; all before/after
  network checkpoints were unavailable, thermal nominal, battery 100%/charging.
  Ordinary access performed no additional full validation or full dataset load;
  artifact hashes remained unchanged.
- **Observed medians, ordinary/history:** validated open 24.164/19.711 ms; warm
  exact-query median 0.0129/0.0126 ms; ordinary peak RSS 31.875/31.875 MiB. Warm-pass
  RSS growth at most 0.047 MiB. All samples/ranges retained; not a leak proof or
  an invented performance pass threshold. Build/setup excluded, caches uncontrolled.
- **Historical interruption:** physical launch-to-first-frame and responsiveness
  pairs were blocked by an Instruments attachment timeout and a generic XCTest
  developer-trust rejection. The bounded diagnosis below supersedes the earlier
  assumption that a Settings Verify/Trust action was required; prior Simulator
  and correctness evidence remain valid and were not repeated.
- **Scope:** only compile-flagged measurement instrumentation was extended for the
  device workload; no runtime repository or production wiring change. **P2-S8 and
  Phase 2 remain open.** Production registry/IDs, real delivery, Q3/Q4 and bundling
  gates are unchanged. No real-artifact changes, publication, commit, push or merge.


**P2-S8 physical startup runner blocker resolved** (2026-10-01; bounded diagnosis,
not performance acceptance). The installed runner and working app share valid
signing/provisioning; filtered device-side Console evidence specifically reported
`Profile Needs Network Validation`. The generic developer-trust message did not
justify repeated requests for a Settings button. Owner-enabled temporary Wi-Fi
allowed the unchanged installed runner to launch; after the owner restored
Wi-Fi off/Airplane Mode on, it relaunched offline. No rebuild, re-sign, reinstall,
security bypass or app-data deletion was needed.

Documented `UseDestinationArtifacts` reused existing installed apps for only two
previously unrun baseline/enabled startup connection checks: **2/2 passed offline**.
Enabled repository validation/readiness passed and the artifact stayed byte-identical.
Original errors, the labeled Console extract and successful results remain owner-only.
[Corrected report](../Tools/RailwayStorage/Measurement/Physical/RESULTS.md) and
[procedure](../Tools/RailwayStorage/Measurement/DEVICE_PROCEDURE.md) distinguish
setup/recovery from performance samples. No already-passed workload, Simulator or
correctness checks were rerun; no app code changed. At that recovery checkpoint, the complete five-pair physical
first-frame/responsiveness cohorts remained outstanding (subsequently collected below); Instruments' separate
attachment timeout was not claimed fixed. **P2-S8 and Phase 2 remain open** with
production identity, real delivery, Q3/Q4 and publication/bundling gates unchanged.
No commit, push or merge.


**P2-S8 remaining physical startup evidence collected** (2026-10-01).
The same explicitly authorized iPhone 17 Pro Max ran the existing optimized app
and XCTest runner without building/installing: **40/40 passed**, five alternating
baseline/enabled pairs for each of first-frame and responsive metrics, separately
for ordinary and applied-transition-history synthetic artifacts. The earlier 2/2
recovery checks are excluded. [Report and criteria audit](../Tools/RailwayStorage/Measurement/Physical/RESULTS.md),
[predeclared method](../Tools/RailwayStorage/Measurement/Physical/METHOD.md),
[all samples and paired differences](../Tools/RailwayStorage/Measurement/Physical/startup-results.json).

- First-frame baseline/enabled medians: ordinary 135.314/135.486 ms; history
  134.998/135.203 ms. Responsive: ordinary 133.638/134.538 ms; history
  132.964/134.652 ms. Paired differences include both signs, with overlapping
  ranges; no improvement, regression, equivalence or invented pass threshold is claimed.
- Responsive means first frame displayed and main thread ready to accept input
  in the title-only shell, not search-UI readiness or touch latency. Repository
  validation runs off the main actor; readiness is separately app-init-hook-relative.
- Owner-confirmed Airplane Mode on/Wi-Fi off and verified USB connection; the
  startup probe does not resample network/thermal/battery. Prior workload snapshots
  remain separate. Process-cold with uncontrolled OS caches, not guaranteed disk-cold.
- All enabled probes: one validation, zero full loads, two distinct same-name
  matches. Both synthetic artifact hashes unchanged before/after; original probe
  files and every cohort retained separately. No source change or passed workload,
  correctness, Simulator or broad build rerun.
- **Technical audit:** accepted synthetic storage/repository/migration checks and
  bounded validated-repository/startup/search/memory/offline measurement evidence
  are now recorded. No additional mandatory synthetic technical measurement was
  identified; a future shipping composition needs its own relevant validation.
  **P2-S8 overall and Phase 2 remain open**: registry-of-record/production IDs,
  real delivery, Q3/Q4 and publication/app-bundling gates are unchanged. Phase 2
  exit and S9/S10 planning relevance are separate; these measurements do not
  authorize distribution, promote IDs or close the phase.

Git remains on `phase/02-static-data` at `31732d7`, synchronized with upstream.
Existing implementation and measurements are preserved uncommitted. This
continuation changes only measurement documentation/safe synthetic results; no
real artifacts, app-data deletion, commit, push or merge.


**P2-S8 final bounded technical review** (2026-10-01; no code/test/build/device
rerun). One focused review found no new material implementation defect; storage,
reviewed transitions and compile-flagged measurement isolation were inspected.
The saved final source/log hashes cover the current code through the recorded
transition, membership-optimization and startup stages. Earlier broad gates are
not described as rerun after later bounded changes. The stale current-open-decision
entry for storage format now points to Accepted DEC-072.

[Final review, accepted-criteria audit and deliverable-specific gate matrix](../Tools/RailwayStorage/FINAL_REVIEW.md)
and [exact proposed commit inventory](../Tools/RailwayStorage/final-review.json)
record the intended changes. **Synthetic P2-S8 implementation and technical
acceptance are complete; overall real delivery and Phase 2 exit are not declared
complete.** Production-registry choice blocks production identity and committed
real registry records; Q3 blocks affected Metro-derived publication; Q4 blocks new
Metro-derived translations; item 5 blocks applicable shipped-data bundling. None
blocks committing synthetic implementation or separately authorizing an owner-only
provisional repository rehearsal. That real SQLite integration remains unperformed;
it is an integration task, not an unresolved storage-format decision.

S9 depends on S4 and conditionally imports Trip stop sequences without times,
requiring passenger-stop verification (DEC-061 §F). S10 depends on S0 and covers
authorized Tier 1 evidence, not capability declaration (DEC-058 §4 / DEC-059).
Neither is an S8 prerequisite. The accepted roadmap explicitly leaves their Phase 2
exit relevance open; resolve inclusion/deferral before phase closure without adding
a timetable or promoting expansion candidates. This audit makes no such decision.

Git remains `phase/02-static-data` at `31732d7`, zero ahead/behind tracked upstream,
nothing staged. All implementation and owner-only evidence are preserved. Only
documentation and a safe review inventory changed; no commit, push, merge or real
data change.


**DEC-074 acceptance and private provisional SQLite integration** (2026-10-01).
Starting Git: `phase/02-static-data`, HEAD `3082776`, two commits ahead/zero behind
tracked upstream; the two proposed documentation edits were preserved. Owner
accepted the local-baseline boundary and P3-T1 planning placement only, and
separately authorized this private integration. Timetable semantics/implementation
remain unaccepted; S9/S10's overall Phase 2 exit disposition is still undecided.

- **Input verification:** all 59 final P2-S7 package entries, 21 identified source/
  registry/document inputs, four accepted P2-S6 artifacts plus their repeats, and
  approved network records matched recorded hashes. No new snapshot, selection,
  binding, ID, source acquisition or translation was introduced.
- **Bounded adapter:** a new owner-only driver reads the accepted named Domain
  export and six reviewed aliases, then calls the existing builder/repository.
  No repository, Domain, registry, search, app-composition or storage implementation
  changed. The driver compiled successfully against the unchanged source; three
  invented adapter checks passed (complete Unicode/alias/reopen/repeat round-trip,
  duplicate-edge rejection and unsupported export-version rejection). Negative
  cases published no SQLite artifact. This was a targeted adapter check, not a
  broad suite or app build. Existing correctness/performance evidence was reused.
- **Actual real acceptance:** 258 stations, 15 lines, two operators; 825 exact
  approved canonical values and six explicit aliases; 774 exact index keys / 780
  key-target pairs matched the accepted index. Both Shinjuku identities and their
  distinct operator/line contexts remained separate. All repository Domain payloads
  matched, including coordinates, topology and bidirectional membership. Both
  accepted shape checks passed. No held or omitted required entity/name/alias.
- **Coordinate comparison:** P2-S6 retains exact decimal source text; P2-S7 Domain
  stores Double coordinates. The initial adapter preflight compared unlike types;
  the existing text-to-Double conversion produced 258 exact accepted Domain-point
  matches. This was a check correction, not a provider/coordinate/source change,
  geographic accuracy claim or a runtime implementation defect.
- **Metadata and reopen:** runtime schema 1, data version
  `p2s8-local-provisional-20261001`, provisional registry revision 6. Names/network
  input descriptors pin the accepted artifact, review and history hashes; runtime
  metadata stores fingerprints, not provider/editorial evidence. Four validated
  opens (including close/reopen and repeats) passed complete Domain/search/metadata
  checks. Ordinary query checks added no validation/full-load pass.
- **Repeat/history:** initial output and two carried-forward-history repeats are
  byte-identical, each 217,088 bytes; one initial runtime build revision, zero
  duplicate history entries. This is a new derived storage history, not conversion
  or replacement of the external name/coordinate/binding review histories. All
  279 pre-existing evidence/input files inventoried remain byte-identical, retaining
  approvals, 186 title bindings, originals, sightings and previous choices. Registry
  SHA-256 remains `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b`.
  Runtime artifact SHA-256:
  `c0e38b0a4220a116cbaa9add736e66ce8fdfa58b48e550e2975de0e23fcbc151`.
- **Retention:** driver, exact input manifests, compiled executable/source hashes,
  targeted-check logs, real acceptance report, metadata, before/after preservation
  audit and all three SQLite files are in a durable owner-only package outside Git.
  File/directory modes are restricted to the owner. Only aggregates and hashes are
  recorded here; no real artifact or machine-specific path enters the repository.
- **Verdict:** **DEC-074 local provisional baseline milestone PASS**, based on the
  existing S1–S7 local acceptance, S8 synthetic/real integration and S11 evidence.
  **Overall P2-S8 and Phase 2 remain open.** No production ID promotion, registry-of-
  record decision, shipping composition, public delivery, publication/bundling or
  timetable implementation is implied. Q3/Q4 and item 5 gates remain specific to
  their deliverables. S9/S10 overall exit disposition and the final phase audit
  are outstanding. No repeated performance run, broad suite/build, commit, push,
  merge or alteration of prior real evidence occurred.
