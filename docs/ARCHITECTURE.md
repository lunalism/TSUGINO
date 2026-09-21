# TSUGINO — ARCHITECTURE.md

## 1. Purpose

This document defines the software architecture for TSUGINO.

The architecture must support three goals at the same time:

1. **Reliable realtime railway journey tracking**
2. **Efficient iOS execution with controlled battery, memory, network, and rendering cost**
3. **Long-term maintainability so features, providers, bug fixes, and regional expansion can be added without destabilizing the entire app**

The architectural north star is:

> **Optimize boundaries before optimizing code.**

TSUGINO should prefer clear ownership, predictable data flow, testable domain logic, and replaceable integrations over short-term convenience.

---

## 2. Architecture Principles

### 2.1 Domain First

Railway journey behavior must live in domain logic, not directly inside SwiftUI views, API clients, or Live Activity code.

Examples:

- remaining-stop calculation
- current-leg progression
- transfer state
- selected-trip replacement
- through-service handling
- journey recovery

These rules must be independently testable.

---

### 2.2 One Source of Truth

An active journey must have one authoritative state.

UI surfaces do not independently infer journey progress.

The following consume the same state:

- Main App
- Dynamic Island
- Lock Screen Live Activity
- Notifications

No surface should maintain a separate competing journey model.

---

### 2.3 Provider Independence

External route or realtime providers must not leak provider-specific response models into the domain layer.

For example:

`ODPTTrainResponse`

must not appear inside:

`Journey`,
`JourneyLeg`,
`Station`,
or SwiftUI views.

All external data must be normalized behind adapters.

---

### 2.4 Immutable Domain State Where Practical

Domain state should prefer value semantics and immutable transitions.

Instead of mutating many fields independently:

```text
Journey.currentStation = ...
Journey.remainingStops = ...
Journey.nextStation = ...
```

prefer:

```text
old JourneyState
      ↓
JourneyReducer / JourneyEngine
      ↓
new JourneyState
```

This reduces invalid intermediate states and makes bugs reproducible.

---

### 2.5 Explicit Ownership

Every responsibility should have exactly one primary owner.

Examples:

- route search → RouteSearchService
- realtime feed → RealtimeService
- journey progression → JourneyEngine
- persistence → JourneyRepository
- Live Activity → LiveActivityCoordinator
- notifications → NotificationCoordinator
- pixel scene selection → JourneySceneResolver

Avoid duplicated responsibility across ViewModels.

---

### 2.6 Dependency Inversion

High-level product logic depends on protocols.

Implementations depend on providers.

Example:

```text
JourneyEngine
    ↓
RealtimeTripProviding
    ↓
ODPTRealtimeAdapter
```

This makes providers replaceable and testable.

---

### 2.7 Performance by Design

Optimization should not be postponed until late development.

Architecture should prevent avoidable work by default:

- do not poll unnecessarily
- do not parse the same payload repeatedly
- do not reload static rail data on every screen
- do not rebuild large SwiftUI trees for small journey updates
- do not persist transient animation state
- do not perform provider decoding on the main actor
- do not keep high-frequency location tracking active without need

---

### 2.8 iPhone-Only v1 Architecture Boundary

TSUGINO v1 targets iPhone only, with a minimum deployment target of **iOS 18.0** (DEC-045). All targets — app, Live Activity extension, tests — share this floor, and v1 code does not carry `@available` branching below it.

Architecture must not add complexity solely to preserve hypothetical iPad support.

Therefore v1 does not require:

- tablet-specific navigation abstractions
- split-view architecture
- iPad windowing support
- iPad-specific layout coordinators
- tablet-only presentation state

Core Domain and Data code should remain platform-clean where natural, but Presentation architecture may optimize directly for iPhone.

iPad support, if approved for a future v2, should be introduced intentionally with a dedicated design and architecture review.

---

## 3. High-Level Architecture

```text
┌──────────────────────────────────────┐
│             Presentation             │
│                                      │
│  SwiftUI App                         │
│  Dynamic Island / Live Activity      │
│  Notifications                       │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│          Application Layer           │
│                                      │
│  JourneyCoordinator                  │
│  RouteSearchCoordinator              │
│  TrainSelectionCoordinator           │
│  RecoveryCoordinator                 │
│  LiveActivityCoordinator             │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│             Domain Layer             │
│                                      │
│  Journey                             │
│  JourneyLeg                          │
│  Trip                                │
│  Station                             │
│  JourneyState                        │
│  JourneyEngine                       │
│  TransferGuidance                    │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│             Data Layer               │
│                                      │
│  Route Provider Adapter              │
│  ODPT / GTFS-RT Adapter              │
│  Static GTFS Store                   │
│  Transfer Guidance Store             │
│  Journey Repository                  │
│  Cache                               │
└──────────────────────────────────────┘
```

Dependencies point inward.

The Domain layer must not import UI frameworks or provider SDKs.

---

## 4. Canonical Project Structure

The project structure is part of the architecture contract.

The exact filenames may evolve, but ownership boundaries and dependency direction should remain stable unless an intentional architecture decision changes them.

```text
TSUGINO/
├── App/
│   ├── TsuginoApp.swift
│   ├── AppEnvironment.swift
│   ├── AppConfiguration.swift
│   └── AppRouter.swift
│
├── Domain/
│   ├── Railway/
│   │   ├── Station.swift
│   │   ├── RailwayLine.swift
│   │   ├── Operator.swift
│   │   └── ServiceType.swift
│   │
│   ├── Journey/
│   │   ├── Journey.swift
│   │   ├── JourneyLeg.swift
│   │   ├── JourneyState.swift
│   │   ├── JourneyPhase.swift
│   │   ├── JourneyEvent.swift
│   │   └── JourneyEngine.swift
│   │
│   ├── Routing/
│   │   ├── RouteCandidate.swift
│   │   ├── RouteSearching.swift
│   │   └── TrainCandidate.swift
│   │
│   ├── Realtime/
│   │   ├── RealtimeSnapshot.swift
│   │   ├── RealtimeFreshness.swift
│   │   └── RealtimeTripProviding.swift
│   │
│   └── Transfer/
│       ├── TransferGuidance.swift
│       └── TransferGuidanceProviding.swift
│
├── Application/
│   ├── Journey/
│   │   ├── JourneyCoordinator.swift
│   │   └── JourneyRecoveryCoordinator.swift
│   │
│   ├── Routing/
│   │   └── RouteSearchCoordinator.swift
│   │
│   ├── TrainSelection/
│   │   └── TrainSelectionCoordinator.swift
│   │
│   ├── LiveActivity/
│   │   └── LiveActivityCoordinator.swift
│   │
│   └── Notifications/
│       └── NotificationCoordinator.swift
│
├── Data/
│   ├── GTFS/
│   │   ├── Static/
│   │   ├── Realtime/
│   │   └── Mapping/
│   │
│   ├── ODPT/
│   │   ├── DTO/
│   │   ├── Adapter/
│   │   └── Client/
│   │
│   ├── RouteProviders/
│   │   └── <SelectedProvider>/   (candidates: Jorudan, NAVITIME, Ekispert — see note below)
│   │
│   ├── Persistence/
│   │   ├── JourneyRepository/
│   │   ├── RecentJourneyRepository/
│   │   └── Migrations/
│   │
│   ├── Cache/
│   └── TransferGuidance/
│
├── Features/
│   ├── Home/
│   ├── StationSearch/
│   ├── RouteResults/
│   ├── TrainSelection/
│   ├── ActiveJourney/
│   ├── RecentJourneys/
│   └── Settings/
│
├── DesignSystem/
│   ├── Tokens/
│   ├── Components/
│   ├── Railway/
│   ├── PixelAssets/
│   └── Motion/
│
├── LiveActivityExtension/
│   ├── Attributes/
│   ├── Mapper/
│   └── Views/
│
├── Shared/
│   ├── Networking/
│   ├── Logging/
│   ├── Time/
│   ├── Localization/
│   └── Utilities/
│
├── Resources/
│   ├── Localization/
│   ├── RailData/
│   ├── PixelArt/
│   └── Assets.xcassets
│
└── Tests/
    ├── DomainTests/
    ├── ApplicationTests/
    ├── DataTests/
    ├── FeatureTests/
    ├── LiveActivityTests/
    └── Fixtures/
```

**RouteProviders note:** the provider names listed above are *candidates/examples* only (DEC-004 is Provisional). A `Data/RouteProviders/<Provider>/` folder is created only for a provider that has actually been selected and is being integrated. Do not pre-create folders for unselected candidates (AGENTS §5.1).

### 4.1 Folder Ownership Rules

The folder structure is meaningful only if ownership remains strict.

#### App
Owns:
- application composition
- dependency wiring
- top-level routing
- environment/configuration

Must not own:
- railway business rules
- provider decoding
- journey progression logic

#### Domain
Owns:
- canonical product models
- journey rules
- railway abstractions
- state transitions
- protocols for required capabilities

May not import:
- SwiftUI
- ActivityKit
- provider SDKs
- concrete networking implementations

#### Application
Owns:
- orchestration
- feature workflows
- coordination between Domain and Data
- lifecycle control

Must not become:
- a second Domain layer
- a dumping ground for provider-specific logic

#### Data
Owns:
- provider clients
- DTOs
- adapters/mappers
- repository implementations
- caches
- persistence
- provider-ID mappings

Must not own:
- SwiftUI state
- user-facing screen decisions
- journey business rules

#### Features
Owns:
- feature-specific presentation models
- SwiftUI views
- user interaction
- lightweight presentation transformation

Must not:
- call ODPT/GTFS clients directly
- parse provider responses
- calculate journey truth
- start independent polling loops

#### DesignSystem
Owns:
- tokens
- reusable visual components
- railway style primitives
- pixel assets
- motion primitives

Must not depend on:
- route providers
- realtime networking
- repositories

#### LiveActivityExtension
Owns:
- widget/activity rendering
- compact presentation models
- ActivityKit-specific code

Must not contain:
- journey business logic
- provider decoding
- route search
- persistence ownership

#### Shared
Contains only genuinely cross-cutting infrastructure.

`Shared/Utilities` must not become a miscellaneous dumping ground.

Business logic belongs in Domain or Application.

#### Resources
Owns:
- localization files
- bundled rail data
- pixel art
- asset catalogs

Large generated rail datasets should be versioned and reproducible.

#### Tests
Should mirror production ownership.

Domain behavior belongs in DomainTests, provider mapping in DataTests, and Live Activity state mapping in LiveActivityTests.

---

### 4.2 Dependency Direction

Allowed high-level direction:

```text
Features
   ↓
Application
   ↓
Domain

Data ───────► Domain protocols
App ────────► composes all layers
LiveActivityExtension ◄── derived presentation state
DesignSystem ◄──────────── presentation only
```

Forbidden examples:

```text
Domain → SwiftUI
Domain → ODPT SDK
Feature → ODPT Client
LiveActivityExtension → JourneyRepository
DesignSystem → JourneyEngine
```

---

### 4.3 Data Folder Internal Pattern

Provider integrations should follow a repeatable shape:

```text
Provider/
├── Client/
├── DTO/
├── Adapter/
├── Mapping/
└── Fixtures/
```

Example:

```text
ODPT/
├── Client/
├── DTO/
├── Adapter/
├── Mapping/
└── Fixtures/
```

If an ODPT response format changes, ideally the fix remains inside:

- DTO
- Adapter
- Mapping

without changing `JourneyEngine`, feature screens, or Live Activity code.

---

### 4.4 Feature Folder Internal Pattern

A feature may use:

```text
FeatureName/
├── View/
├── Model/
├── Components/
└── Preview/
```

Use only the folders actually needed.

Do not create empty architectural ceremony.

---

### 4.5 Folder Change Rule

The canonical structure is a baseline, not an immutable law.

Folders may be added, merged, renamed, or split when implementation evidence shows a better boundary.

Any material structural change must:

1. have a clear reason,
2. preserve or improve ownership clarity,
3. update `ARCHITECTURE.md`,
4. record the decision in `DECISIONS.md` when the change is architecturally significant,
5. migrate tests with the ownership change.

Structure exists to make changes easier, not to prevent change.
## 5. Core Domain Model

### 5.1 Station

Settled S3a contract (DEC-055):

```text
Station
- id              (StationID — §39, DEC-051)
- name            (LocalizedRailName — §39.1, DEC-053)
- lineIDs         (Set<LineID> — DEC-055 D2)
```

Canonical names are held as the shared `LocalizedRailName` value (§39.1, DEC-053), not as three flat properties: all three languages are required, blank names are rejected, and valid names are preserved exactly.

**Identity is the `StationID` alone (DEC-055 D3):** equality and hashing use only the ID, implemented explicitly as for `Operator` (§5.7). Names, line membership, coordinates, and operator relationships are descriptive data; correcting them does not create a new station, and a merge or split of canonical identities is an identity migration (§41, Rule 39), never an in-place edit.

**No single operator owner (DEC-055 D1).** `Station` stores no `operatorID`. A canonical station may be served by more than one operator (§40, DEC-048), so its operator participation is dataset-level relational information obtained by joining `lineIDs` to the canonical `RailwayLine` records and reading each line's `operatorID`. `Station` carries no `primaryOperatorID`, `operatorIDs`, station-group or interchange identifier, provider identifier, station code, or transfer/parent-station relationship.

**Line membership (DEC-055 D2).** `lineIDs` is an unordered set of canonical `LineID` values only. It may be empty — Phase 1 value construction does not invent dataset-completeness policy — and its agreement with canonical line topology is a Phase 2 import/dataset validation responsibility, not an invariant of the isolated value. The encoded field and element meaning may be pinned; encoded element order is not a contract.

**Coordinates — S3b-gated (DEC-055 D4).** No coordinate property is part of the S3a contract. Phase 1 slice S3b will lock and implement a provider-neutral coordinate value and its `Station` relationship (representation, required-vs-optional ownership, finite-value and range rules, `(0, 0)` and signed-zero handling, exact preservation, `Codable` rejection, one canonical coordinate per cross-operator group). Coordinates never participate in identity (DEC-048, Rule 53). `CLLocationCoordinate2D` and other framework types do not enter Domain.

Station identity must use a TSUGINO canonical ID rather than provider IDs directly.

Provider IDs are stored as mappings.

---

### 5.2 RailwayLine

Settled S3a contract (DEC-055):

```text
RailwayLine
- id              (LineID — §39, DEC-051)
- operatorID      (OperatorID — §5.7)
- name            (LocalizedRailName — §39.1, DEC-053)
```

Line names use the same shared `LocalizedRailName` value as `Station` and `Operator` (§39.1, DEC-042, DEC-053): Japanese, English, and Korean are held canonically; provider-supplied names are inputs, not the sole source of truth.

**Identity is the `LineID` alone (DEC-055 D3):** equality and hashing use only the ID, implemented explicitly as for `Operator` (§5.7). The operator relationship, names, topology, and any future colour are descriptive data and do not participate in identity. A line belongs to one operator; through service across lines and operators is a `Trip` / Journey concern (§5.3, §13), not a line property.

**Topology — S3c-gated (DEC-055 D4).** `stationSequence` is not part of the S3a contract. Phase 1 slice S3c will lock and implement canonical ordered line topology after a separate contract audit or decision settles its representation, minimum station count, duplicate-`StationID` policy, circular lines, branches (including the Marunouchi main line and branch and whether a branch is a separate `LineID`, a segment, or another structure), and dataset-level consistency with `Station.lineIDs`. Canonical line topology is distinct from a `Trip`'s stop sequence: **`Trip` owns `direction` and `stopSequence` (§5.3)**, and service-pattern behaviour never moves onto `RailwayLine`.

**Colour — deferred beyond Phase 1 (DEC-055 D5).** No colour property exists in the Phase 1 contract. Whether line colour is canonical Domain data or a DesignSystem token (`DESIGN.md` §30), and how it is represented, is decided later — most plausibly during Phase 2 data/design integration — once the ODPT licensing question on official line colours (DEC-047) is resolved. DEC-018 continues to govern presentation priority once a colour exists. SwiftUI, UIKit, and provider SDK colour types never enter Domain.

---

### 5.3 Trip

A Trip represents a concrete train service.

```text
Trip
- id
- providerReferences
- lineID
- serviceType
- direction
- destination
- stopSequence
- scheduledTimes
```

The Trip model must support:

- local
- rapid
- express
- limited-stop service
- through service
- changed destination
- cancelled service

without provider-specific branching in UI code.

---

### 5.4 Journey

```text
Journey
- id
- origin
- destination
- legs
- currentLegIndex
- state
- createdAt
- updatedAt
```

---

### 5.5 JourneyLeg

```text
JourneyLeg
- id
- kind
- boardingStation
- alightingStation
- plannedTrip
- selectedTrip
- realtimeState
- transferGuidance
```

Possible kinds:

- rail
- walkingTransfer
- optional future transport modes

---

### 5.6 JourneyState

Journey state is separate from persisted route definition.

```text
JourneyState
- phase
- currentLegIndex
- currentStation
- nextStation
- remainingStops
- progress
- realtimeFreshness
- interruptionReason
- lastConfirmedAt
```

The UI renders this state.

---

### 5.7 Operator

```text
Operator
- id              (OperatorID)
- name            (LocalizedRailName — §39.1, DEC-053)
```

`Operator` is a **provider-neutral canonical identity model** (DEC-049). It owns its canonical `OperatorID` (DEC-021) and the canonical localized names required by DEC-041 / DEC-042 / Rule 26, held as the shared `LocalizedRailName` value (DEC-053); provider-supplied names are inputs, not the sole source of truth.

**Identity is the `OperatorID` alone (DEC-053):** equality and hashing use only the ID, so canonical names may change without changing which operator a value denotes. `Operator` carries no provider ID, no capability set, and no logo, colour, abbreviation, URL, or other UI metadata.

`Operator` **does not own a capability set.** Railway capabilities are declared at the applicable **service/feed scope** (§51), because one operator may publish trip-level realtime for some services and only alerts for others (DEC-046, DEC-047). Capability-dependent behaviour is selected from the declared `RailCapability` value, never from the operator's name (DEC-022, Rule 10).

---

## 6. Journey State Machine

Journey progression should be modeled explicitly.

```text
Planning
   ↓
WaitingForDeparture
   ↓
Boarding
   ↓
OnTrain
   ↓
ApproachingTransfer
   ↓
Transferring
   ↓
WaitingForNextTrain
   ↓
OnTrain
   ↓
ApproachingDestination
   ↓
Arrived
   ↓
Ended
```

Exceptional transition:

```text
Any active state
      ↓
Interrupted
      ↓
Recovered / Replanned / Ended
```

State transitions must be centralized inside `JourneyEngine`.

Views must never directly set journey phase.

---

## 7. Journey Engine

`JourneyEngine` is the most important domain component.

**Phase ownership (DEC-050):** **Phase 1** defines the provider-neutral journey domain types, events, commands/inputs, outputs, and the `JourneyEngine` **protocol boundary**; it does **not** implement runtime behaviour. **Phase 5** owns the state-transition logic, progression behaviour, realtime/scheduled observation handling, and operational engine behaviour described below. Any Phase 1 protocol stays provider-neutral and imports no SwiftUI, ActivityKit, provider SDK, or networking detail.

Responsibilities:

- apply realtime updates
- determine current/next station
- calculate remaining stops
- advance legs
- detect transfer approach
- handle through services
- reconcile selected trip
- detect stale or inconsistent progress
- produce new JourneyState
- create recovery suggestions

Conceptual input:

```text
Journey
+
RealtimeSnapshot
+
Current Time
+
Optional Device Context
```

Output:

```text
JourneyTransitionResult
- updatedJourney
- events
- warnings
- recoveryProposal
```

It should behave like a pure state transition engine wherever practical.

---

## 8. Realtime Data Architecture

### 8.1 Realtime Provider Protocol

```text
RealtimeTripProviding
- fetchTripUpdates(...)
- fetchVehiclePositions(...)
- fetchServiceAlerts(...)
```

Possible implementations:

- ODPTRealtimeProvider
- GTFSRealtimeProvider
- future commercial provider

---

### 8.2 RealtimeSnapshot

All provider data must normalize into one internal representation.

```text
RealtimeSnapshot
- generatedAt
- fetchedAt
- trips
- vehiclePositions
- alerts
- freshness
```

---

### 8.3 Provider Adapter Rule

Provider-specific decoding occurs only in Data adapters.

Example:

```text
ODPT JSON
   ↓
ODPT DTO
   ↓
ODPT Adapter
   ↓
RealtimeSnapshot
```

The JourneyEngine never parses ODPT or GTFS protobuf directly.

---

## 9. Static Railway Data

Static railway topology should be stored locally whenever licensing permits.

Examples:

- stations
- lines
- stop sequences
- service metadata
- operator metadata

Benefits:

- faster launch
- less network dependency
- lower server/API cost
- offline station lookup
- deterministic tests

Static data should be versioned.

Example:

```text
RailDataVersion
2026.09.1
```

Migration must be explicit when canonical IDs change.

---

## 10. Route Search Architecture

Define an abstraction:

```text
RouteSearching
- search(origin, destination, departureContext)
```

Provider implementations may include:

- Jorudan
- NAVITIME
- Ekispert
- future provider

All results normalize into:

```text
RouteCandidate
- legs
- departure
- arrival
- transfers
- fare
- providerMetadata
```

No feature screen should depend on a specific route provider.

---

## 11. Train Selection Architecture

Train selection is explicit.

```text
RouteCandidate
      ↓
TrainCandidateResolver
      ↓
TrainCandidate[]
      ↓
User selects
      ↓
SelectedTripBinding
```

The selected trip is stored separately from the provider route response.

This allows:

- replacing a missed train
- changing a delayed train
- re-binding after a transfer
- preserving the overall journey

---

## 12. Multi-Leg Journey Architecture

Each rail leg maintains its own selected trip.

```text
Journey
├── Leg 0
│   └── selectedTrip A
├── Transfer
├── Leg 1
│   └── selectedTrip B
└── Destination
```

Upcoming leg selection can be:

- prebound when data is reliable
- confirmed near transfer time
- replaced independently

The whole Journey must not be rebuilt merely because one Trip changes.

---

## 13. Through-Service Architecture

Through service must be represented independently from operator changes.

The domain should distinguish:

```text
PhysicalTrainContinuity
LineIdentity
OperatorIdentity
PassengerTransferRequired
```

Rule:

> Operator change != transfer.

A through-running train should remain one continuous boarding experience.

---

## 14. Transfer Guidance Architecture

Define:

```text
TransferGuidanceProviding
```

Normalized model:

```text
TransferGuidance
- station
- fromLine
- toLine
- recommendedCar
- recommendedDoor
- exitSide
- nearbyFacility
- walkingTime
- confidence
- source
```

Guidance must carry confidence and provenance.

Low-confidence data must not be promoted as precise guidance.

---

## 15. Persistence Architecture

Persistence should distinguish between:

### Durable Product Data
- recent journeys
- favorites later
- settings
- cached static railway version
- provider mappings

### Active Journey State
- current journey
- selected trips
- current phase
- last confirmed progress
- realtime freshness
- last reconciliation time

Persisted progress carries its provenance; persistence must never convert a schedule-derived estimate into an observed realtime fact (DEC-024, DEC-046).

### Transient UI State
- animation frame
- scroll position
- temporary sheet state

Transient UI state should not be persisted unless there is a strong reason.

---

## 16. Repository Pattern

Core persistence must be behind protocols.

Examples:

```text
JourneyRepository
RecentJourneyRepository
RailwayDataRepository
TransferGuidanceRepository
```

This enables:

- in-memory tests
- local persistence
- future schema migration
- predictable recovery

---

## 17. Persistence Technology

SwiftData may be used for application-owned structured persistence when appropriate.

However:

- large static GTFS datasets should not automatically be modeled as thousands of SwiftData objects if a lighter indexed representation is faster
- static rail topology may be better served by SQLite, precompiled binary data, or compact JSON depending on measured performance
- the active Journey should remain small and easy to restore

Technology must follow profiling, not preference.

---

## 18. Cache Architecture

TSUGINO should use layered caching.

```text
Memory Cache
    ↓
Local Disk Cache
    ↓
Remote Provider
```

Suggested cache categories:

- station search
- static route topology
- route search response
- realtime snapshot
- transfer guidance

Each cache type must have its own expiration policy.

Do not use one universal TTL.

---

## 19. Network Efficiency

Realtime network activity must be journey-aware.

Do not continuously fetch every operator.

When a Journey is active:

- request only relevant operator feeds where possible
- prioritize the active and next leg
- reduce frequency when waiting far before departure
- increase freshness near boarding, transfer, or destination when provider policy permits
- stop journey-specific polling after the Journey ends

Provider rate limits and licenses must be respected.

---

## 20. Polling Strategy

Polling cadence must be centrally controlled.

Do not let individual screens create timers.

Define:

```text
RealtimeRefreshPolicy
```

Possible inputs:

- journey phase
- provider capability
- last update age
- app foreground/background state
- upcoming departure/transfer
- system constraints

The refresh coordinator owns timers and cancellation.

---

## 21. Swift Concurrency Strategy

Use Swift Concurrency with explicit isolation.

Recommended approach:

- UI state → `@MainActor`
- network decoding → non-main tasks
- repositories → actors where concurrent mutation exists
- realtime coordinator → actor
- cache mutation → actor or equivalent synchronization

Avoid detached tasks unless ownership is clear.

Every long-running task must have:

- cancellation
- lifecycle ownership
- failure handling

---

## 22. Main-Actor Budget

The main actor should perform:

- UI state publication
- lightweight view model transformation
- user interaction handling

The main actor should not perform:

- large GTFS parsing
- protobuf decoding
- JSON normalization
- heavy route reconciliation
- file IO
- large persistence fetches
- pixel asset preprocessing

---

## 23. Presentation Architecture

Feature screens should use a predictable structure.

Example:

```text
View
  ↓
FeatureModel / ViewModel
  ↓
Application Coordinator
  ↓
Domain / Repository
```

Views should not:

- call ODPT directly
- decode provider models
- calculate remaining stops
- write active Journey persistence directly
- start polling timers

---

## 24. Observation Strategy

Publish the smallest state needed by each surface.

Avoid exposing a massive global observable object that causes unrelated screens to rerender.

Example:

```text
ActiveJourneyPresentationState
- headline
- currentStation
- nextStation
- remainingStops
- eta
- transferCue
```

Pixel animation state should be separate from realtime domain state.

---

## 25. Journey State vs Animation State

This separation is mandatory.

### Journey State

Authoritative product truth:

- current station
- next station
- progress
- phase
- remaining stops

### Animation State

Presentation-only:

- train sprite offset
- tunnel scroll position
- transition phase
- background scene state

Rule:

> Animation may react to Journey State.  
> Animation must never drive Journey State.

This prevents visual timing bugs from corrupting journey progression.

---

## 26. Pixel Scene Architecture

Define:

```text
JourneySceneResolver
```

Input:

- journey phase
- line context
- underground/above-ground metadata if available
- destination proximity

Output:

```text
PixelScene
- environment
- train sprite
- motion style
- decoration set
```

Pixel art composition should be reusable and data-driven.

Avoid giant per-station bespoke SwiftUI view trees.

---

## 27. Rendering Performance

Pixel scenes should avoid unnecessary rendering cost.

Guidelines:

- reuse sprites
- prefer lightweight transforms over rebuilding image hierarchies
- pause nonessential animation when app is inactive
- respect Reduce Motion
- avoid high-frequency state publication
- profile frame pacing on target physical devices

Animation frame state must never trigger persistence writes.

---

## 28. Live Activity Architecture

Live Activity receives a compact derived state.

Define:

```text
LiveActivityPresentationState
- phase
- line
- origin
- destination
- currentStation
- nextStation
- remainingStops
- progress
- eta
- transferCue
```

The Activity should not receive the complete Journey model.

Benefits:

- smaller payload
- lower coupling
- safer schema evolution
- simpler Widget Extension code

---

## 29. Activity State Mapper

Create a dedicated mapper:

```text
Journey
      ↓
LiveActivityStateMapper
      ↓
LiveActivityPresentationState
```

This prevents Live Activity formatting logic from leaking into JourneyEngine.

---

## 30. Live Activity Lifecycle Ownership

`LiveActivityCoordinator` owns:

- start
- update
- stale handling
- end
- cancellation
- reconciliation after app resume

No feature View should call ActivityKit directly.

---

## 31. Lock Screen Pixel Progress

Lock Screen pixel-train position is derived from normalized journey progress.

Example:

```text
progress =
completedRelevantStops /
totalRelevantStops
```

The value must be clamped and monotonic within a stable leg unless a journey recovery explicitly resets it.

The pixel train position is visual approximation only.

---

## 32. Notification Architecture

`NotificationCoordinator` consumes domain events.

Example events:

```text
JourneyEvent.departureApproaching
JourneyEvent.transferApproaching
JourneyEvent.destinationApproaching
JourneyEvent.tripCancelled
```

The JourneyEngine produces events.

The notification layer decides whether and how they are delivered.

---

## 33. Location Architecture

Location should be optional for core journey tracking.

Primary uses:

- nearby station suggestions
- optional consistency checks
- future automatic train detection

Location must not become the only source of journey truth.

High-accuracy continuous location should not run unless clearly justified by a feature.

---

## 34. Error Model

Use typed errors.

Examples:

```text
RouteSearchError
RealtimeError
JourneyRecoveryError
PersistenceError
TransferGuidanceError
```

Avoid passing raw provider errors directly to UI.

Each error should support:

- developer context
- user-safe message mapping
- recoverability
- retry policy

---

## 35. Recovery Architecture

Recovery is a first-class subsystem.

Define:

```text
JourneyRecoveryCoordinator
```

Handles:

- missed train
- wrong train
- cancelled train
- changed destination
- stale realtime
- provider outage
- invalid persisted journey
- unsupported service change

Recovery should preserve valid context whenever possible.

---

## 36. Logging

Structured logging is required from the beginning.

Log categories:

- routing
- realtime
- journey
- persistence
- activity
- notification
- recovery
- performance

Logs must avoid storing unnecessary personal data.

Useful identifiers should be internal opaque IDs.

---

## 37. Diagnostics

For difficult journey bugs, the app should support a diagnostic snapshot in debug builds.

Possible content:

- Journey ID
- route
- selected trips
- current phase
- current station
- latest realtime timestamp
- provider
- recovery state
- last transitions

This makes field bugs reproducible.

---

## 38. Deterministic Time

Domain logic must not call `Date()` directly everywhere.

Introduce a project-owned clock abstraction:

```text
AppClock
- now
```

The `App` prefix avoids collision and confusion with Swift's standard-library `Clock` protocol; the concept is unchanged.

Production uses system time (`SystemAppClock`).

Tests use deterministic time (`FixedAppClock`).

This is essential for:

- departure countdown tests
- delay handling
- stale realtime tests
- Live Activity state tests

---

## 39. Stable Identifiers

TSUGINO must own canonical IDs.

Examples:

```text
StationID
LineID
TripID
JourneyID
OperatorID
```

Provider IDs are aliases, not canonical product identity.

This reduces migration pain when providers change.

**Validity invariant (DEC-051):** a canonical identifier must contain at least one non-whitespace character; empty and whitespace-only values are rejected. Construction is failable and never traps, and decoding applies the same rule, failing with `DecodingError.dataCorrupted`. A value that passes is preserved **exactly** — no trimming, case folding, Unicode normalisation, or separator rewriting. Validity and losslessness are separate concerns: rejecting blanks does not authorise normalising what remains, and any stricter format rule requires a new decision.

---

## 39.1 Language Resolution Architecture

Language resolution is centralized.

Define:

```text
LanguageResolver

ja-* → Japanese
ko-* → Korean
otherwise → English
```

The resolver should use the effective app/device language rather than scattered locale checks in individual views.

Railway display names must use canonical localized data.

Provider-localized strings are inputs, not the sole source of truth.

Canonical internal model (DEC-053) — the single representation used by `Station` (§5.1), `RailwayLine` (§5.2), and `Operator` (§5.7):

```text
LocalizedRailName
- japanese
- english
- korean
```

All three names are required and each must contain at least one non-whitespace character; empty and whitespace-only names are invalid. A valid name is preserved exactly — no trimming, case change, or Unicode normalisation — and leading or trailing whitespace survives when a non-whitespace character exists. The three values may be identical. Missing canonical Korean data is supplied from TSUGINO's canonical dataset rather than stored as a blank string, and language selection never mutates the stored canonical names.

Rules:

- Japanese UI uses canonical Japanese
- Korean UI uses canonical Korean
- unsupported languages use canonical English
- missing provider Korean names are supplemented by TSUGINO localization data
- canonical IDs remain language-independent

Station search aliases should map all supported localized names back to the same canonical `StationID`.

---

## 40. Provider Mapping

Maintain mapping tables:

```text
Canonical StationID
├── ODPT ID
├── GTFS stop_id
├── Jorudan ID
└── NAVITIME ID
```

Provider mapping belongs in Data infrastructure.

Do not spread mapping logic across features.

For cross-operator stations, each canonical station carries **every** provider station identifier and station code, **each provider's original name strings unmodified**, and any orthographic or presentation alias as an **explicit, reversible** mapping entry — never by rewriting a provider string (DEC-048). Station identity must not be established from display names or coordinates alone, and no parent-station or transfer relationship may be synthesized where the provider feed publishes none. Stations whose identity is unresolved stay **separate** until authoritative evidence supports a merge; such a merge is a schema/identity migration (§41, Rule 39), not an in-place edit.

Because a canonical station may span operators, the Domain `Station` value stores no single `operatorID` (§5.1, DEC-055 D1); a station's operators are those of its lines, resolved at the dataset level. The 258-group result of DEC-048 is a Phase 2 planning input for this mapping layer, not Phase 1 model data.

---

## 41. Schema Versioning

Persisted structures must be versioned.

Examples:

- rail static data version
- active journey persistence version
- transfer guidance version
- provider mapping version

Migrations must be explicit and tested.

Never silently reinterpret old persisted data.

---

## 42. Feature Flags

Risky or incomplete capabilities should use feature flags.

Examples:

- automatic train detection
- destination exit guidance
- provider-specific realtime
- experimental pixel scenes

Feature flags must not become permanent dead code.

Each flag should have:

- owner
- purpose
- removal criteria

---

## 43. Configuration

Secrets, API keys, endpoints, and environment differences must not be hard-coded into views or domain objects.

Use:

```text
AppConfiguration
- environment
- route provider
- realtime provider
- feature flags
- endpoints
```

Secrets must be handled through appropriate secure configuration.

---

## 44. Testing Strategy

### 44.1 Domain Unit Tests

Highest priority.

Test:

- journey transitions
- remaining stops
- transfer approach
- through service
- delayed trip
- cancellation
- missed train recovery
- wrong direction recovery
- destination approach
- stale realtime

---

### 44.2 Provider Adapter Tests

Use recorded fixtures.

Test:

- ODPT normalization
- GTFS-RT decoding
- route provider mapping
- malformed payloads
- missing fields
- delayed feeds

---

### 44.3 Repository Tests

Test:

- save
- update
- reopen
- migration
- corrupted data recovery

---

### 44.4 Presentation Tests

Test:

- Japanese
- English
- long station names
- Dynamic Type
- no realtime data
- transfer guidance missing

---

### 44.5 Live Activity Tests

Test every Journey phase mapping.

The Live Activity must not contain independent business logic.

---

## 45. Recorded Journey Fixtures

TSUGINO should maintain reusable journey fixtures.

Examples:

- simple local ride
- express skipping stations
- one transfer
- multiple transfers
- through service
- delayed train
- missed train
- cancelled train
- stale realtime
- long 20+ stop trip

These fixtures become regression tests.

This is one of the most important tools for future bug fixing.

---

## 46. Performance Testing

Measure on physical target devices.

Track:

- cold launch
- station search latency
- route result latency
- realtime decode time
- JourneyEngine reconciliation time
- memory usage
- animation frame pacing
- energy impact
- Live Activity update behavior

Optimization decisions should use measurement.

---

## 47. Performance Budgets

Initial engineering targets should be defined before implementation.

Examples of categories:

- main-thread reconciliation budget
- static station search response budget
- realtime payload decode budget
- memory budget for static data
- maximum unnecessary refresh count
- animation frame stability

Exact numeric targets should be set after prototype measurements on physical devices.

---

## 48. Avoid Premature Micro-Optimization

Do not sacrifice architecture for tiny early speed improvements.

Preferred order:

1. correct ownership
2. correct algorithm
3. avoid unnecessary work
4. measure
5. optimize measured bottlenecks

Do not optimize speculative bottlenecks.

---

## 49. Bug-Fixability Rule

Every difficult bug should be traceable to one subsystem.

Bad:

> “Something somewhere changed the current station.”

Good:

> “Realtime adapter produced snapshot X, JourneyEngine transitioned state A → B, Activity mapper rendered B.”

This traceability is a primary architectural requirement.

---

## 50. Updateability Rule

Adding a new operator should ideally require:

1. provider adapter
2. canonical mappings
3. capability declaration
4. fixtures
5. tests

It should **not** require rewriting journey logic.

Adding a new route-search provider should not require rewriting feature screens.

Adding a new pixel environment should not modify JourneyEngine.

---

## 51. Capability Model

Capabilities are declared at the applicable **service/feed scope** — never as a fixed property of an operator or provider (DEC-049, DEC-054).

`RailCapability` is the single canonical atomic capability type, with **nine** cases (DEC-054):

```text
RailCapability
- staticSchedule
- tripUpdates
- vehiclePosition
- alerts
- serviceStatus
- platform
- recommendedCar
- recommendedDoor
- exitGuidance
```

`serviceStatus` is **separate from** `alerts`: service-status information and alert resources are distinct data concepts, and the scheduled-guidance rules below already treat them separately. No provider name or provider resource identifier belongs in this vocabulary.

The declared collection is conceptually `Set<RailCapability>`. All combinations remain representable in Phase 1 — including an empty set — and Phase 1 rejects none of them; any rule making a combination invalid is a future decision (DEC-054).

Features check capabilities rather than provider names.

Bad:

```text
if operator == TokyoMetro
```

Good:

```text
if capabilities.supportsRecommendedCar
```

This is critical for expanding beyond Tokyo.

Capability is scoped to the **service/feed**, not the operator: provider identity alone cannot determine UI behaviour, because one operator may publish trip-level realtime for some services and not others (verified case: Toei Subway and Tokyo Sakura Tram have Trip Update / Vehicle Position; the Nippori-Toneri Liner has static, status, and Alert coverage only — DEC-046). Adapters expose capability and **provenance** (realtime / scheduled / status / unavailable) rather than synthesized state; Application and UI layers select behaviour from the capability set; no layer synthesizes progress from a schedule. A service is promoted to a richer capability set only through the evidence gates in DEC-046 (catalog/license, payload/schema, identity join, freshness/coverage, UI state).

**Ownership (DEC-049):** `RailCapability` is the **single canonical capability type**; no parallel capability abstraction is introduced. It is declared at **service/feed scope** and is **never** a fixed attribute of `Operator` (§5.7). Actual provider capability data, canonical mapping tables, and ingestion are Phase 2 / Phase 4 concerns, not Phase 1.

**Carrier boundary (DEC-054):** Phase 1 defines the capability vocabulary and the pure tier derivation **only**. It does **not** create a service/feed carrier and does **not** attach capabilities to `Operator`, `Station`, `RailwayLine`, `Trip`, or any invented `Service` type; no `ServiceID`, `FeedID`, `RailService`, or `ServiceScope` is introduced merely to hold the set. Actual service/feed-scoped declaration, ingestion, and attachment are **Phase 4** concerns. Capabilities are declared only after the applicable evidence gates are satisfied (DEC-046), so **presence in the declared set already means that capability passed its verification gate** — no second verification flag exists.

Capability **tiers** (DEC-047) are derived from the declared capability set, never from the operator or provider name. The derivation is a pure function of `Set<RailCapability>` (DEC-054); Swift case spelling is `realtimeJourneyTracking`, `scheduledJourneyGuidance`, `deferredOrUnsupported`:

| Declared set contains | Derived tier |
|---|---|
| `tripUpdates` — `vehiclePosition` optional, `staticSchedule` not additionally required | **Realtime Journey Tracking** |
| otherwise `staticSchedule` — `alerts` and `serviceStatus` optional supplements | **Scheduled Journey Guidance** |
| otherwise — including the empty set, alerts-only, service-status-only, and vehicle-position-only | **Deferred / Unsupported** |

`staticSchedule` with `vehiclePosition` but no `tripUpdates` derives Scheduled Journey Guidance; other extra capabilities never promote a tier by themselves. **Provenance and realtime freshness are not inputs** to this derivation, and the tier makes no claim about live data availability at a particular instant — runtime freshness, observed state, degraded state, and presentation behaviour are later concerns (DEC-024, Rule 12). The tier is a property of the journey leg's service and is carried with provenance into `JourneyState`, the Live Activity mapper, and notifications. In the scheduled tier, progress is computed from the user-selected schedule and the clock and is typed as *scheduled*; no layer may convert it into observed progress, a delay figure, or a vehicle position.

---

## 52. Offline and Degraded Mode

TSUGINO should degrade gracefully.

Possible modes:

- full realtime
- partial realtime
- schedule fallback
- static-only station search
- temporarily unavailable route search

The architecture must represent degradation explicitly.

---

## 53. Security and Privacy

Collect the minimum data required.

Principles:

- journey data stays local unless remote processing is required
- precise location is optional for core tracking
- diagnostics avoid personal identifiers
- provider API credentials are protected
- logs are sanitized

---

## 54. Dependency Policy

Prefer Apple frameworks and small, well-justified dependencies.

Every third-party dependency should have a reason.

Avoid dependencies for functionality that can be implemented simply and safely in-house.

Especially avoid deeply coupling core domain models to third-party SDKs.

---

## 55. Code Quality Rules

Architecture should encourage:

- small focused types
- explicit protocols
- value semantics
- exhaustive enums
- typed IDs
- typed errors
- deterministic state transitions
- minimal global state

Avoid:

- god objects
- singleton-heavy architecture
- view-owned networking
- giant ViewModels
- provider models in UI
- duplicated realtime parsing
- implicit state mutation

---

## 56. Living Documentation

All project documents are **living documents**.

This includes:

- `PRODUCT.md`
- `FEATURES.md`
- `DESIGN.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `ROADMAP.md`
- `RULES.md`
- `AGENTS.md`

None of these documents should be treated as permanently frozen.

Implementation, physical-device testing, provider limitations, App Store constraints, user feedback, performance measurements, or newly discovered bugs may require the documents to change.

The correct rule is:

> **The code and the documents must converge on the current product truth.**

Documentation is not a historical snapshot of the first plan.

It is the maintained specification of the current plan.

### 56.1 Change Triggers

A document should be updated when implementation reveals:

- an invalid assumption
- a better architecture boundary
- a provider limitation
- a licensing constraint
- a new performance requirement
- a design change
- a feature addition/removal
- a roadmap change
- a new non-negotiable rule
- a changed agent workflow

### 56.2 Same-Change Principle

When implementation materially changes an agreed product or architecture rule, the relevant document should be updated in the same development phase, and preferably the same commit.

Examples:

```text
Architecture changed
→ ARCHITECTURE.md updated
→ DECISIONS.md updated if significant
```

```text
Feature scope changed
→ FEATURES.md updated
→ PRODUCT.md updated if product boundary changed
→ ROADMAP.md updated if phase scope changed
```

```text
UI behavior changed
→ DESIGN.md updated
```

### 56.3 Documents Are Authoritative but Revisable

A document is authoritative for the current implementation until intentionally revised.

Developers and coding agents should not silently violate a document because implementation is inconvenient.

If reality conflicts with the document:

1. identify the conflict,
2. determine whether code or document is wrong,
3. update the appropriate side intentionally,
4. record significant decisions.

### 56.4 No Stale-Document Tolerance

Known stale documentation should not be left behind after a completed phase.

A phase is not fully complete if its implementation materially disagrees with the project documents.

### 56.5 Decision History

`DECISIONS.md` preserves important architectural and product decision history.

Other documents describe **current truth**.

Therefore:

- current docs may be rewritten as the product evolves,
- `DECISIONS.md` should preserve why significant changes were made.

This distinction keeps documentation useful without losing historical context.
## 57. Architecture Acceptance Criteria

The architecture is acceptable only if:

1. UI does not own railway business logic.
2. Provider-specific models do not leak into Domain.
3. Active Journey has one authoritative source of truth.
4. Journey State and Animation State are separated.
5. Realtime polling has one lifecycle owner.
6. Active Journey can persist and resume safely.
7. Through service does not require UI hacks.
8. Missed or changed trains can be recovered without rebuilding everything.
9. Live Activity consumes derived presentation state only.
10. New providers can be added through adapters and capability declarations.
11. Heavy parsing and IO stay off the main actor.
12. Static railway data is not repeatedly loaded or decoded unnecessarily.
13. Realtime data has explicit freshness semantics.
14. Domain logic is deterministic and fixture-testable.
15. Difficult journey bugs can be reconstructed from structured diagnostics.
16. Schema and canonical IDs can survive provider changes.
17. Pixel animation cannot mutate Journey truth.
18. Performance is measured on physical devices before optimization decisions.
19. Feature growth does not require widening a global state object.
20. Unsupported capabilities degrade gracefully.
21. Folder ownership remains explicit and dependency direction is enforceable.
22. Provider-format changes can usually be contained within Data adapters/mappings.
23. Material implementation changes are reflected back into the living project documents.

---

## 58. Architecture North Star

TSUGINO should be built so that:

> **Realtime railway data can change.  
> Providers can change.  
> UI can evolve.  
> Pixel art can expand.  
> But the Journey domain remains stable.**

That stability is what makes future optimization, updates, debugging, and expansion manageable.

The architecture and documentation are allowed to evolve when implementation teaches us something new; changes should be deliberate, traceable, and reflected in the maintained project truth.
