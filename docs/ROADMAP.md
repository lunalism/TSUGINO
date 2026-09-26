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

**Status: accepted with DEC-065 (2026-09-25; §D amended 2026-09-26).** P2-S0 and P2-S1 are complete; P2-S2 is next. Each slice starts only when the decisions listed for it are accepted. Answering a later slice's questions is **not** a precondition for an earlier slice.

| Slice | Kind | Content | Depends on | Decisions needed before it starts |
|---|---|---|---|---|
| **P2-S0** | documentation | Documentation lock: the public-repository boundary, P2-S1 scope, synthetic fixtures with local validation, and this plan (DEC-065) | — | — |
| **P2-S1** | implementation | Toei-only static GTFS **table reader** → provider DTOs (DEC-065 §B, §C, §D) | S0 | **DEC-065 only** |
| P2-S2 | implementation | Static source intake: source manifest (provider, dataset, resource, `feed_version`, SHA-256, obtained-at) and archive handling | S1 | where the Phase 2 pipeline runs (build-time tool or on device); any archive-handling dependency (Rule 34) |
| P2-S3 | implementation | Tokyo Metro static and `odpt:Railway` reader, tested with synthetic fixtures only | S1 | where local Tokyo Metro development data may live, and token handling (Rule 42) |
| P2-S4 | implementation | Operator-level identities (149 → 141 Toei, 185 → 144 Tokyo Metro) and line mapping to the 15 baseline `LineID`s, with the Marunouchi branch record as an alias (DEC-057 D6) | S2, S3 | canonical identifier format; for committed Tokyo Metro-involving records, resolution of DEC-065 §A |
| P2-S5 | implementation | Cross-operator station identity, reconciled to DEC-048 (DEC-065 §E) | S4 | as S4 |
| P2-S6 | implementation | Representative coordinates and line topology → valid `Station` and `RailwayLine` values | S5 | coordinate-selection policy, including the 27 merged stations; topology evidence source |
| P2-S7 | implementation | Japanese/English/Korean names, search aliases, search index, local search API | S6 | Korean authorship and review; Tokyo Metro Korean inputs (ODPT Q4) |
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
- **P2-S2:** a manifest entry for every input records provider, dataset, resource, `feed_version`, SHA-256, and obtained-at; archive handling is covered by tests; no archive is committed.
- **P2-S3:** the reader handles the shapes the audit recorded (flat `stops` rows, `stop_code` line-letter prefixes including `Mb`, ten `odpt:Railway` records), tested only with synthetic fixtures. Real-data runs are local, and only aggregates are recorded (185 `stops` rows, 9 routes, 9,544 trips, 494 `translations` rows).
- **P2-S4 / P2-S5:** a deterministic importer (same pinned inputs give byte-identical output) reproduces DEC-048's aggregates (DEC-065 §E). Tests assert that Toei 新宿 and Tokyo Metro 新宿 stay separate with no transfer edge, that both alias rules are explicit and reversible with original strings preserved, and that no distance constant exists. Production identifiers are minted independently of the analysis group keys.
- **P2-S6:** every canonical station has exactly one `GeoCoordinate` with recorded provenance, or is held back; every topology is connected, and its derived membership equals every `Station.lineIDs` (DEC-057 D9); the Oedo loop-plus-tail shape and the Marunouchi branch validate.
- **P2-S7:** through the local search API, every baseline station is found by its Japanese, English, and Korean names and by its recorded aliases, including 市ヶ谷 / 市ケ谷 and 押上〈スカイツリー前〉; both 新宿 stations are returned and can be told apart by operator and lines. Station search UI is Phase 8.
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
