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
