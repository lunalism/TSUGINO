# TSUGINO — ROADMAP.md

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

**Status: accepted with DEC-065 (2026-09-25; §D amended 2026-09-26); P2-S2 design accepted with DEC-066 (2026-09-26); P2-S3 design accepted with DEC-067 (2026-09-27); P2-S4 design accepted with DEC-068 (2026-09-28); P2-S5 design accepted with DEC-069 (2026-09-30); P2-S6 design accepted with DEC-070 (2026-09-30).** P2-S0, P2-S1, P2-S2, P2-S3, and P2-S4 are complete; P2-S3's real-feed validation passed on 2026-09-29 on newly identified Tokyo Metro inputs (recovery record below). P2-S4 is *implemented* and **complete** (2026-09-30): the criteria audit found every criterion met. Its provisional real-data runs passed for both operators, and the owner accepted the newer Toei snapshot and its recorded difference explanation on 2026-09-30 (P2-S4 real-data acceptance record, below). Production identifiers, the registry of record, Tokyo Metro publication, and app bundling remain gated. P2-S5 (DEC-069) is *implemented* and **complete** (2026-09-30): the criteria audit found every criterion met, on synthetic tests and a provisional real-data run that met every baseline. Production identifiers, the registry of record, publication, and app bundling remain gated. P2-S6 (DEC-070) is *implemented* and **complete** (2026-09-30): the criteria audit combines the accepted synthetic evidence with the real-data acceptance below, including 258 selected coordinates, 15 connected topologies, both shape checks, and a byte-identical repeat. P2-S7 has not started; production identifiers, the registry of record, publication, and app bundling remain gated. Each slice starts only when the decisions listed for it are accepted. Answering a later slice's questions is **not** a precondition for an earlier slice.

| Slice | Kind | Content | Depends on | Decisions needed before it starts |
|---|---|---|---|---|
| **P2-S0** | documentation | Documentation lock: the public-repository boundary, P2-S1 scope, synthetic fixtures with local validation, and this plan (DEC-065) | — | — |
| **P2-S1** | implementation | Toei-only static GTFS **table reader** → provider DTOs (DEC-065 §B, §C, §D) | S0 | **DEC-065 only** |
| **P2-S2** | implementation | Static source intake in an offline macOS developer tool: archive member policy, streaming of the named tables with the system `bsdtar`, input consistency, and a source manifest (DEC-066) | S1 | **DEC-066 only** (accepted) |
| P2-S3 | implementation | Tokyo Metro static GTFS through the unchanged P2-S1 reader, plus an `odpt:Railway` DTO reader; invented synthetic fixtures only, real inputs local (DEC-067) | S1, S2 | **DEC-067 only** (accepted) |
| P2-S4 | implementation | Operator-level identities (149 → 141 Toei, 185 → 144 Tokyo Metro) and line mapping to the 15 baseline `LineID`s, with the Marunouchi branch record as an alias (DEC-057 D6) | S2, S3 (including P2-S3's real-data validation, for completion) | **DEC-068** (accepted) for code and synthetic tests. Completion needs real-data acceptance on identified snapshots (DEC-068 §H). Minting production identifiers, or committing any real mapping record for either operator, needs the pending registry-of-record decision (DEC-068 §F1). Publishing any Tokyo Metro-derived mapping also needs the ODPT Q3 reply or a separate accepted publication decision (DEC-065 §A) |
| P2-S5 | implementation | Cross-operator station identity from name and alias candidates, compared with DEC-048 (DEC-065 §E as amended by DEC-069) | S4 | **DEC-069** (accepted), with DEC-068. Production identifiers, committed real records, and Tokyo Metro publication stay gated as for S4 (DEC-068 §F) |
| P2-S6 | implementation | Validated representative coordinates, undirected line topology, and membership artifacts (DEC-070). Complete `Station` and `RailwayLine` construction waits for P2-S7's required names (DEC-053) | S5 | **DEC-070** (accepted), with DEC-056, DEC-057, DEC-068, DEC-069. Production identifiers, committed real records, and Tokyo Metro publication stay gated (DEC-068 §F) |
| P2-S7 | implementation | Reviewed Japanese/English/Korean names, explicit aliases, scalar-exact index/lookup, complete named Domain construction | S6 | **DEC-071 is accepted (2026-09-30).** Synthetic implementation is present; verification and real-acceptance status are recorded below. Synthetic success does not complete P2-S7. Real name selection/authorship and Korean review are separate; Q4 still gates new Tokyo Metro-derived translations. Q3, production-registry and P2-S8 gates remain unchanged |
| P2-S8 | implementation | Storage measurement, `RailwayDataRepository`, data-version metadata, migration strategy | S6 | storage format, after measurement (DEC-029); bundling in the shipped binary stays with ODPT item 5 |
| P2-S9 | implementation | `Trip` structure import: stop sequences **without times**, with passenger-stop verification (DEC-061 F) | S4 | whether Phase 2 imports `Trip` records at all |
| P2-S10 | evidence | Tier 1 payload evidence (DEC-058 §4, DEC-059); no capability declaration | S0 | explicit authorization for Basic-License data access; whether it counts toward Phase 2 exit |
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

**Phase 2 exit relevance.** Slices S1–S8 serve the Phase 2 acceptance criteria. Whether S9 and S10 are needed for Phase 2 exit is an open decision. S11 is the Phase 2 physical-device test and needs authorization.

### Open Planning Issue — Timetable Ownership (not Phase 2 scope)

DEC-060 §F defers scheduled times to their own timetable contract: service days, calendar exceptions, times past 24:00, time zones, provider schedule mapping, and the Clock. **No phase currently owns that contract**, yet Scheduled Journey Guidance (DEC-046, DEC-047) — the delivered tier for the nine Tokyo Metro lines and the Nippori-Toneri Liner — depends on it. Phase 2 is **not** expanded to cover it: P2-S1 checks only the syntax of time values and gives them no timetable meaning, and P2-S9, if kept, imports stop sequences without times. Assigning ownership needs a separate planning decision that updates this roadmap (Scope Change).

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

---

# Phase 3 — Route Search Provider Integration

## Goal

Integrate a replaceable route-search provider without leaking provider models into the product domain.

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
