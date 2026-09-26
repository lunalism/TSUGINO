# TSUGINO — DECISIONS.md

## 1. Purpose

This document records significant product, design, data, and architecture decisions for TSUGINO.

Unlike the other project documents, which describe the **current intended state** of the product, this document preserves **why important choices were made** and how those choices evolve over time.

The goal is not to record every small implementation detail.

The goal is to preserve decisions that materially affect:

- product direction
- feature scope
- data strategy
- architecture
- system behavior
- maintainability
- performance
- rollout strategy
- testing
- user experience

---

## 2. Decision Record Format

Each decision should include:

- **ID**
- **Title**
- **Status**
- **Date**
- **Context**
- **Decision**
- **Rationale**
- **Consequences**
- **Revisit Triggers**

Possible statuses:

- `Accepted`
- `Provisional`
- `Superseded`
- `Rejected`
- `Deprecated`

A decision marked `Accepted` is authoritative until intentionally changed.

If a decision changes, do not erase the original reasoning.

Instead:

1. mark the old decision as `Superseded`,
2. add a new decision,
3. link the two decisions,
4. update the relevant living documents.

---

# DEC-001 — Tokyo First, Japan Expansion Later

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Japan has a large and fragmented railway ecosystem with many operators, differing realtime data coverage, differing licenses, and varying support for station-level guidance.

Attempting nationwide support from the first release would dramatically increase:

- data integration scope
- licensing work
- testing burden
- operator-specific edge cases
- realtime reliability risk

## Decision

TSUGINO will begin with the **Tokyo metropolitan railway area**.

The initial supported network should include as many Tokyo-area lines as can be supported reliably through legally usable official, open, or commercial data sources.

After Tokyo is stable, TSUGINO may expand progressively to other regions of Japan.

## Rationale

Tokyo offers:

- dense railway usage
- high value for realtime journey guidance
- strong transfer use cases
- suitable early data sources
- enough complexity to validate the product architecture

Starting in Tokyo provides meaningful product validation without requiring nationwide data completeness.

## Consequences

- nationwide coverage is not an MVP requirement
- provider capability must be represented explicitly
- architecture must support incremental operator addition
- roadmap phases should treat regional expansion separately

## Revisit Triggers

Revisit if:

- a nationwide provider becomes commercially and technically suitable
- regional expansion becomes substantially cheaper than expected
- early user demand strongly favors another region

---

# DEC-002 — Japanese and English Are First-Class Languages

**Status:** Superseded by DEC-041  
**Date:** 2026-09-16

## Context

TSUGINO targets both local Japanese railway users and international travelers.

Adding English later would risk layouts, Live Activities, Dynamic Island content, and station naming being designed only around Japanese text length.

## Decision

The initial product will support:

- Japanese
- English

Both languages must be considered during initial UI and architecture design.

## Rationale

Bilingual design from the beginning reduces later rework and expands the useful audience without requiring a separate product variant.

## Consequences

- all user-visible journey states require localization
- Dynamic Island copy must support short localized variants
- station/line naming must normalize both Japanese and English
- UI must tolerate longer English labels

## Revisit Triggers

Revisit if initial launch scope requires a temporary staged language rollout for technical or operational reasons.

---

# DEC-003 — TSUGINO Is a Journey Companion, Not a General Route Planner

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Existing Japanese transit products already specialize in route planning, timetable lookup, fares, and multimodal search.

Rebuilding a complete route-planning engine would distract from TSUGINO's differentiated value.

## Decision

TSUGINO's core product boundary is:

> Route planning gets the user onto the journey.  
> TSUGINO owns what happens during the journey.

TSUGINO will focus on:

- journey tracking
- selected-train tracking
- remaining stops
- current/next station
- transfer guidance
- Live Activities
- Dynamic Island
- destination approach
- recovery

## Rationale

This creates a clear product identity and limits unnecessary duplication of mature transit-planning systems.

## Consequences

- route search may be delegated to an external provider
- the Journey domain is more important than route-search internals
- in-trip reliability is a higher priority than route-search breadth

## Revisit Triggers

Revisit only if provider limitations make the product materially worse or prohibit required integration.

---

# DEC-004 — Prefer External Route Search Provider for MVP

**Status:** Provisional  
**Date:** 2026-09-16

## Context

Japanese rail routing includes:

- express/local service patterns
- through services
- transfer timing
- operator boundaries
- first/last trains
- timetable-dependent paths
- platform constraints
- service disruptions

Building a complete routing engine from GTFS alone would significantly increase scope.

## Decision

The MVP should prefer a replaceable specialized route-search provider such as:

- Jorudan
- NAVITIME
- Ekispert
- another suitable licensed provider

The architecture must isolate the provider behind `RouteSearching`.

## Rationale

This keeps TSUGINO focused on the in-trip experience while preserving the ability to replace providers later.

## Consequences

- provider cost/licensing must be evaluated
- provider IDs must be mapped to TSUGINO canonical IDs
- no feature screen may depend directly on provider response models

## Revisit Triggers

Revisit when:

- provider pricing is unsustainable
- required trip identity is unavailable
- data terms conflict with TSUGINO's product needs
- a reliable in-house routing engine becomes strategically valuable

---

# DEC-005 — Realtime Railway Data Is a Core Dependency

**Status:** Accepted  
**Date:** 2026-09-16

## Context

The core user experience requires knowledge of the selected train's actual journey state.

Schedule-only data cannot reliably represent:

- delays
- cancelled trains
- changed arrivals
- current progression
- disrupted transfers

## Decision

TSUGINO will use realtime railway data wherever supported.

Preferred sources include:

- ODPT
- GTFS Realtime
- operator realtime APIs
- licensed commercial realtime data

## Rationale

Realtime data is necessary for TSUGINO to be meaningfully more useful than a static timetable view.

## Consequences

- realtime freshness must be tracked
- schedule fallback must be explicit
- provider capability differences must be modeled
- stale realtime must never be presented as live

## Revisit Triggers

Not expected to be reversed.

Individual provider choices may change.

---

# DEC-006 — Vehicle Position Is Useful but Not Mandatory

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Not all operators provide accurate train coordinates or Vehicle Position feeds.

Trip Updates and stop progression may still be sufficient for reliable journey tracking.

## Decision

Vehicle Position data will be treated as an optional capability.

TSUGINO must remain functional when supported operators provide reliable:

- trip identity
- stop sequence
- realtime arrival/departure updates

without exact vehicle coordinates.

## Rationale

Making exact train GPS mandatory would unnecessarily reduce operator coverage.

## Consequences

- UI must not imply exact physical train coordinates without supporting data
- Lock Screen pixel-train progress is approximate journey progress
- capability checks are required

## Revisit Triggers

None required unless future product features demand exact vehicle location.

---

# DEC-007 — User Explicitly Selects the Train to Board

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Inferring the exact boarded train automatically from iPhone location can be unreliable, especially underground and in dense rail corridors.

The reference product flow demonstrated that explicit train selection can provide a reliable starting point.

## Decision

Before active journey tracking begins:

> **The user explicitly selects the train they intend to board.**

TSUGINO then binds the active Journey leg to that selected Trip.

## Rationale

Explicit selection:

- reduces ambiguity
- improves reliability
- reduces dependence on continuous GPS
- makes realtime tracking easier
- simplifies recovery

## Consequences

- train candidate selection is a core MVP feature
- selected-trip replacement must be supported
- automatic train detection is not required for MVP

## Revisit Triggers

Revisit if automatic detection reaches sufficiently high reliability without increasing battery or privacy costs.

---

# DEC-008 — Multi-Leg Journeys Bind Trips Per Rail Leg

**Status:** Accepted  
**Date:** 2026-09-16

## Context

A journey may contain multiple trains separated by transfers.

Binding only the first train would make later journey state ambiguous.

## Decision

Each rail leg may maintain its own selected Trip.

Subsequent trips may be:

- preselected when reliable
- confirmed near transfer time
- replaced independently when necessary

## Rationale

This allows each leg to be corrected without rebuilding the whole Journey.

## Consequences

- `JourneyLeg` owns selected-trip context
- transfer flows must handle trip confirmation
- recovery operates at leg level where possible

## Revisit Triggers

None expected.

---

# DEC-009 — Through Service Is Not a Transfer

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Japanese trains may continue across operators or line identities without requiring passengers to leave the train.

Treating every line or operator change as a transfer would produce incorrect guidance.

## Decision

TSUGINO must distinguish:

- physical train continuity
- line identity
- operator identity
- passenger transfer requirement

An operator or line change alone does not create a transfer.

## Rationale

This is necessary for correct Japanese railway behavior.

## Consequences

- through-service continuity belongs in Domain
- UI may show operator/line changes without transfer instructions
- route-provider adapters must preserve continuity information where possible

## Revisit Triggers

None expected.

---

# DEC-010 — Journey State Is the Single Source of Truth

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO renders the same journey across:

- main app
- Dynamic Island
- Lock Screen Live Activity
- notifications

If each surface independently interprets realtime data, states may diverge.

## Decision

The active Journey and its derived `JourneyState` are the authoritative product truth.

All UI surfaces consume derived state from the same Journey domain.

## Rationale

A single source of truth prevents inconsistent station names, stop counts, and transfer states.

## Consequences

- UI surfaces do not infer journey progress
- Live Activity does not contain separate journey logic
- notifications consume Journey events

## Revisit Triggers

None expected.

---

# DEC-011 — JourneyEngine Owns Journey Progression

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Journey progression includes complex rules:

- current station
- next station
- remaining stops
- transfers
- delays
- through services
- recovery

Putting these rules into views or ViewModels would spread business logic throughout the app.

## Decision

A dedicated `JourneyEngine` owns domain-level journey state transitions.

Conceptually:

```text
Journey + RealtimeSnapshot + Clock
                 ↓
             JourneyEngine
                 ↓
        New Journey + Events
```

## Rationale

Centralized transition logic is easier to test, debug, and optimize.

## Consequences

- views cannot mutate journey phase directly
- deterministic tests become possible
- provider adapters normalize data before JourneyEngine consumes it

## Revisit Triggers

The internal implementation may evolve, but ownership should remain centralized.

---

# DEC-012 — Journey State and Animation State Are Separate

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO's main app will use animated pixel-art train scenes.

Visual timing must not accidentally change railway truth.

## Decision

Journey state and animation state are separate systems.

Rule:

> **Animation may react to Journey State.  
> Animation must never drive Journey State.**

## Rationale

A train sprite arriving visually early must never advance the actual station.

## Consequences

- station names update only from trusted Journey progression
- animation offsets are transient presentation state
- animation state is not persisted as journey truth

## Revisit Triggers

None expected.

---

# DEC-013 — Main App May Use Continuous Pixel Motion

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Pixel art is a core visual identity for TSUGINO.

The main app can afford richer motion than system surfaces.

## Decision

The main app may use continuous or looping motion such as:

- tunnel lights
- moving tracks
- city scenery
- departure motion
- train vibration
- station approach transitions

## Rationale

This gives TSUGINO a distinct emotional identity without compromising system-surface legibility.

## Consequences

- motion must pause when appropriate
- Reduce Motion must be supported
- animation must not imply unsupported GPS precision

## Revisit Triggers

Revisit based on performance and energy measurements on physical devices.

---

# DEC-014 — Lock Screen Uses Discrete Pixel Progress, Not Continuous Motion

**Status:** Accepted  
**Date:** 2026-09-16

## Context

The Lock Screen should show journey progress while remaining battery-conscious and compatible with Live Activity behavior.

## Decision

Lock Screen Live Activity may show:

- origin
- destination
- pixel train
- current/last confirmed station
- remaining stops
- ETA

The pixel train moves **discretely when journey state updates**, not as a continuously animated simulation.

## Rationale

This preserves character while keeping the Lock Screen clear and efficient.

## Consequences

- progress is derived from journey state
- Always-On remains useful statically
- the pixel train must not claim exact physical train position

## Revisit Triggers

Revisit if future iOS capabilities materially change Live Activity animation constraints.

---

# DEC-015 — Dynamic Island Prioritizes Information Over Decoration

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Dynamic Island has limited space.

Overusing pixel art would reduce clarity.

## Decision

Dynamic Island should remain primarily functional.

Design balance:

- information first
- minimal decorative pixel accents
- no continuous decorative motion

## Rationale

The user needs immediate understanding, not visual spectacle.

## Consequences

- compact state shows only essential information
- expanded state may show richer journey detail
- pixel identity is secondary

## Revisit Triggers

None expected.

---

# DEC-016 — Pixel Art Is Environment, Critical Information Is Modern UI

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Pixel art gives TSUGINO brand identity but pixel fonts and dense retro UI can reduce readability.

## Decision

TSUGINO uses:

> **Pixel Art Environment + Modern iOS Information UI**

Pixel art is used for:

- backgrounds
- station scenes
- trains
- tunnels
- scenery
- decorative objects

Critical railway information uses clear system-native typography and modern layout.

## Rationale

This creates character without sacrificing usability.

## Consequences

- pixel fonts are not used for critical transit data
- design system separates visual atmosphere from information layer

## Revisit Triggers

None expected.

---

# DEC-017 — Dark-First Visual Design

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO frequently appears alongside Dynamic Island and may be used in dim transit environments.

## Decision

The initial design system is dark-first.

## Rationale

Dark-first design:

- integrates well with Dynamic Island
- supports vivid railway line colors
- suits nighttime/underground usage
- complements pixel-art environments

## Consequences

- dark mode receives first-class design validation
- light mode may be added later

## Revisit Triggers

Revisit after user testing or accessibility evaluation.

---

# DEC-018 — Real Railway Line Colors Override Brand Accent for Line Identity

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Railway line colors are strong navigational cues.

Replacing them with brand colors would reduce transit usability.

## Decision

When representing a railway line, the real or official line color takes priority over TSUGINO brand accent.

## Rationale

Recognition is more important than decorative consistency.

## Consequences

- design tokens must support operator line colors
- brand accent is used for interaction and product identity, not to overwrite line identity

## Revisit Triggers

None expected.

---

# DEC-019 — Recommended Car/Door Guidance Is Coverage-Aware

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Recommended car and door guidance can make transfers significantly easier, but data availability will vary.

## Decision

TSUGINO will support:

- recommended car
- recommended door
- nearest stairs/escalator/elevator
- transfer walking time
- destination-exit boarding position

only where sufficiently reliable data exists.

Unsupported guidance is omitted.

## Rationale

Incorrect precise guidance is worse than no guidance.

## Consequences

- guidance requires provenance/confidence
- capability checks are mandatory
- no UI placeholder should imply universal coverage

## Revisit Triggers

Revisit when broader licensed datasets become available.

---

# DEC-020 — External Provider Data Is Normalized Before Domain Use

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO may consume multiple route and realtime providers.

Provider-specific models would create widespread coupling if used directly.

## Decision

All external responses pass through:

```text
Client
→ DTO
→ Adapter/Mapper
→ TSUGINO canonical model
```

before entering Domain.

## Rationale

Provider changes should not force JourneyEngine or feature rewrites.

## Consequences

- Data layer owns provider normalization
- fixtures should test adapter behavior
- provider models never appear in UI

## Revisit Triggers

None expected.

---

# DEC-021 — TSUGINO Owns Canonical IDs

**Status:** Accepted  
**Date:** 2026-09-16\
**Amended by:** DEC-061 (2026-09-23) — adds `ServiceTypeID` to the canonical identifier list; the body below is unchanged

## Context

Different providers use different IDs for the same:

- station
- line
- operator
- trip

Provider IDs may also change.

## Decision

TSUGINO maintains canonical identifiers:

- `StationID`
- `LineID`
- `OperatorID`
- `TripID`
- `JourneyID`

Provider IDs are mapped aliases.

## Rationale

Canonical IDs reduce coupling and make provider replacement or multi-provider reconciliation possible.

## Consequences

- provider mapping tables are required
- mapping migrations must be tested
- provider IDs must not become product identity

## Revisit Triggers

None expected.

---

# DEC-022 — Capability Checks Replace Provider-Name Branching

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Hard-coded logic such as:

```text
if operator == TokyoMetro
```

does not scale as TSUGINO expands across Japan.

## Decision

Features must query declared capabilities such as:

- static schedule
- trip updates
- vehicle position
- alerts
- platform
- recommended car
- recommended door
- exit guidance

## Rationale

The product should depend on what a provider can do, not who the provider is.

## Consequences

- each provider/operator exposes a capability declaration
- unsupported features degrade gracefully

## Revisit Triggers

None expected.

---

# DEC-023 — Active Journey Must Persist and Resume

**Status:** Accepted  
**Date:** 2026-09-16

## Context

The active Journey may outlive the foreground app process.

A user should not lose journey tracking because the app leaves memory or is reopened.

## Decision

Active Journey state is persisted locally and reconciled with current realtime data on resume.

## Rationale

Persistence is essential for a product whose core experience continues outside the main app.

## Consequences

- active Journey schema requires versioning
- stale persisted state must be recoverable
- transient animation state is not part of durable Journey state

## Revisit Triggers

None expected.

---

# DEC-024 — Realtime Freshness Is Explicit State

**Status:** Accepted  
**Date:** 2026-09-16

## Context

A realtime feed can become stale without fully failing.

Presenting stale data as current would reduce trust.

## Decision

TSUGINO explicitly represents realtime freshness.

Possible conceptual states:

- live
- delayed update
- stale
- unavailable
- schedule fallback

## Rationale

Trustworthiness matters more than pretending that all data is realtime.

## Consequences

- snapshots record timestamps
- stale thresholds belong to provider policy
- UI may downgrade precision when freshness declines

## Revisit Triggers

Provider-specific thresholds may change.

---

# DEC-025 — Polling Has One Lifecycle Owner

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Independent timers in multiple screens can cause:

- duplicate network traffic
- race conditions
- excessive battery usage
- inconsistent data

## Decision

Realtime refresh cadence is centrally owned by a refresh coordinator/policy.

Views do not create provider polling timers.

## Rationale

Centralized ownership makes network behavior predictable and optimizable.

## Consequences

- polling responds to journey phase
- tasks must support cancellation
- refresh stops when journey-specific tracking ends

## Revisit Triggers

Implementation may later shift toward push-based updates where providers support them.

---

# DEC-026 — Location Is Optional for Core Journey Tracking

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO can track a selected Trip from realtime transit data without requiring continuous high-accuracy GPS.

## Decision

Location is primarily used for:

- nearby station suggestions
- optional consistency checks
- future automatic train detection

Core journey tracking must not depend exclusively on continuous location.

## Rationale

This reduces:

- battery cost
- privacy burden
- underground reliability problems

## Consequences

- location permission denial does not break core journey tracking
- continuous high-accuracy tracking requires explicit justification

## Revisit Triggers

Revisit if automatic train detection becomes a major product feature.

---

# DEC-027 — Realtime and Heavy Parsing Stay Off the Main Actor

**Status:** Accepted  
**Date:** 2026-09-16

## Context

GTFS, GTFS-RT, provider JSON, static rail data, and route reconciliation can be expensive.

## Decision

Heavy work must not run on the main actor.

Examples:

- GTFS parsing
- protobuf decoding
- provider normalization
- file IO
- large persistence operations

The main actor is reserved for UI publication and interaction.

## Rationale

This protects scrolling, animation, and input responsiveness.

## Consequences

- concurrency ownership must be explicit
- repositories/coordinators may use actors
- cancellation must be supported

## Revisit Triggers

None expected.

---

# DEC-028 — Optimize Boundaries Before Micro-Optimization

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Premature low-level optimization can make code harder to maintain without solving actual bottlenecks.

## Decision

Optimization order is:

1. correct ownership
2. correct algorithm
3. avoid unnecessary work
4. measure
5. optimize measured bottlenecks

## Rationale

Good architecture makes later optimization safer and more targeted.

## Consequences

- profiling is required before invasive optimization
- performance budgets are established after prototype measurement
- physical-device testing is important

## Revisit Triggers

None expected.

---

# DEC-029 — Static Railway Data Should Prefer Local Indexed Storage

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Static railway topology changes less frequently than realtime state.

Repeatedly downloading or decoding it wastes network and CPU resources.

## Decision

Static data should be bundled or cached locally when licensing permits.

Possible representations include:

- SQLite
- precompiled compact data
- indexed local files
- compact JSON where appropriate

Technology should be selected based on measurement rather than preference.

## Rationale

This improves launch, search, offline behavior, and cost.

## Consequences

- data versions and migrations are required
- SwiftData is not automatically the right choice for large static GTFS topology

## Revisit Triggers

Revisit after prototype profiling.

---

# DEC-030 — Live Activity Receives Derived Presentation State Only

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Sending the complete Journey model into the Live Activity extension would create coupling and schema complexity.

## Decision

A dedicated mapper converts Journey state into a compact `LiveActivityPresentationState`.

## Rationale

This keeps ActivityKit code small and independent from full domain internals.

## Consequences

- Live Activity cannot own business logic
- payload changes are easier to control
- system surface state is easier to test

## Revisit Triggers

None expected.

---

# DEC-031 — Recovery Is a First-Class Product Capability

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Real railway journeys frequently diverge from plans.

Examples:

- missed train
- wrong train
- wrong direction
- cancellation
- major delay
- changed destination
- feed outage

## Decision

TSUGINO must explicitly support Journey recovery rather than treating divergence as exceptional failure.

## Rationale

A journey companion that fails as soon as reality changes is not reliable.

## Consequences

- recovery has dedicated architecture
- valid journey context should be preserved where possible
- recovery paths require regression fixtures

## Revisit Triggers

None expected.

---

# DEC-032 — Recorded Journey Fixtures Are a Core Regression Tool

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Realtime railway bugs can be difficult to reproduce after the original feed state disappears.

## Decision

TSUGINO maintains reusable recorded/constructed journey fixtures for:

- local ride
- express service
- transfer
- multi-transfer
- through service
- delay
- cancellation
- missed train
- stale realtime
- long journey

## Rationale

Deterministic fixtures make future bug fixes safer.

## Consequences

- important production bugs should become regression fixtures where practical
- fixtures should avoid unnecessary personal data

## Revisit Triggers

None expected.

---

# DEC-033 — Structured Diagnostics Are Required

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Complex journey bugs require visibility into state transitions.

Without diagnostics, a report such as “the station changed incorrectly” is difficult to investigate.

## Decision

Debug/test builds should support structured journey diagnostic snapshots containing useful internal state.

## Rationale

Bug-fixability is an architectural requirement.

## Consequences

- journey transitions should be traceable
- logs use sanitized internal identifiers
- diagnostics must avoid unnecessary personal data

## Revisit Triggers

The exact diagnostic format may evolve.

---

# DEC-034 — Project Folder Structure Is an Architecture Contract

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Without folder and ownership rules, code tends to drift toward:

- oversized ViewModels
- provider code inside features
- business logic inside SwiftUI
- misc utility dumping grounds

## Decision

The project uses the canonical structure defined in `ARCHITECTURE.md`, centered around:

- App
- Domain
- Application
- Data
- Features
- DesignSystem
- LiveActivityExtension
- Shared
- Resources
- Tests

## Rationale

Folder boundaries reinforce ownership and make future changes easier.

## Consequences

- dependencies must follow the architecture direction
- folders may evolve only intentionally
- significant structural changes are documented

## Revisit Triggers

Revisit when implementation demonstrates a better ownership boundary.

---

# DEC-035 — Documents Are Living Specifications

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Implementation will reveal assumptions that are incomplete, incorrect, or too expensive.

Frozen documents would quickly become misleading.

## Decision

All project documents are living documents:

- `PRODUCT.md`
- `FEATURES.md`
- `DESIGN.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `ROADMAP.md`
- `RULES.md`
- `AGENTS.md`

They may and should change when implementation reality changes.

## Rationale

The useful specification is the one that describes the product being built now.

## Consequences

- material implementation changes update relevant documents
- known stale documents should not survive completed phases
- developers must not silently violate documents

## Revisit Triggers

None expected.

---

# DEC-036 — DECISIONS.md Preserves History; Other Documents Describe Current Truth

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Living documents must be editable, but removing old reasoning would make architectural changes hard to understand later.

## Decision

The documentation model is:

> **DECISIONS.md = why we chose and changed things**  
> **Other project documents = what is currently true**

## Rationale

This gives the project both adaptability and historical traceability.

## Consequences

- obsolete product rules may be rewritten in current documents
- significant old decisions remain in this file and are marked `Superseded`
- changes should link old and new decision IDs

## Revisit Triggers

None expected.

---

# DEC-037 — Data Licensing Is a Production Architecture Concern

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Japanese railway datasets can differ in:

- commercial-use rights
- redistribution rights
- caching terms
- attribution
- challenge-only availability
- expiration

A technically usable dataset may not be legally usable in production.

## Decision

Every production data source must have recorded:

- source
- provider/operator
- license
- allowed use
- attribution requirements
- caching restrictions
- redistribution restrictions
- commercial-use restrictions
- expiration/challenge restrictions

## Rationale

Licensing must not be discovered only at release time.

## Consequences

- experimental datasets cannot silently become production dependencies
- provider capability registry should include legal availability where relevant

## Revisit Triggers

Individual source terms may change.

---

# DEC-038 — Unsupported Precision Must Never Be Invented

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO may sometimes know journey progression without knowing exact physical train position.

## Decision

The product must not visually or textually imply unsupported precision.

Examples:

- approximate pixel progress is not GPS position
- schedule fallback is not realtime
- uncertain station progress is not presented as confirmed
- unsupported door guidance is omitted

## Rationale

Trust is more important than apparent sophistication.

## Consequences

- confidence/freshness states are required
- design and architecture both enforce degraded modes

## Revisit Triggers

None expected.

---

# DEC-039 — Recent Journeys Belong in MVP; Favorites May Follow

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Frequent users should not repeatedly enter the same origin and destination.

## Decision

MVP should support lightweight Recent Journeys.

Favorites/pinned journeys may be deferred.

## Rationale

Recent journeys provide meaningful convenience with relatively low complexity.

## Consequences

- recent journey persistence is required
- favorite-specific UX is not an MVP blocker

## Revisit Triggers

Revisit based on scope pressure or user testing.

---

# DEC-040 — Nearby Station Suggestions Are Separate from Automatic Train Detection

**Status:** Accepted  
**Date:** 2026-09-16

## Context

Location can improve route setup even when automatic train detection is not implemented.

## Decision

Nearby station suggestions may use location permission.

This does not imply that TSUGINO automatically knows which train the user is riding.

## Rationale

This provides useful convenience without overclaiming detection capability.

## Consequences

- nearby station UX may exist before automatic train detection
- permission messaging should reflect the actual purpose

## Revisit Triggers

Revisit if automatic train detection is later implemented.

---


# DEC-041 — Japanese, English, and Korean Are First-Class Languages

**Status:** Accepted (language-resolution details superseded by DEC-042)\
**Date:** 2026-09-16  
**Supersedes:** DEC-002\
**Partially superseded by:** DEC-042 — only the device-language resolution/fallback behavior. The three-language product decision itself remains in force.

## Context

TSUGINO is a Japan-focused railway journey companion, but a meaningful part of the target audience includes international travelers.

Korean users are especially likely to benefit from:

- remaining-stop guidance
- transfer guidance
- destination approach alerts
- Dynamic Island
- Lock Screen Live Activity
- recommended boarding-position information

Adding Korean only after the product ships would risk forcing Japanese/English assumptions into layout, localization, copy length, and system-surface presentation.

## Decision

The initial product will support three first-class languages:

- Japanese
- English
- Korean

All three languages must be considered from the beginning for:

- main app UI
- station/line naming
- route results
- train selection
- journey state
- transfer instructions
- notifications
- Dynamic Island
- Lock Screen Live Activity
- error and recovery states

Japanese remains the primary local-language experience, but English and Korean are not secondary afterthoughts.

## Rationale

Supporting Korean from the start:

- serves a relevant Japan-travel audience
- avoids later layout rework
- improves system-surface copy design
- encourages a cleaner localization architecture
- fits TSUGINO's role as a travel companion rather than a Japan-resident-only utility

## Consequences

- localization architecture must support three launch languages
- UI must avoid fixed-width assumptions
- Dynamic Island requires compact Japanese/English/Korean phrasing
- Korean railway wording must be natural rather than literal
- station-name display needs a consistent transliteration/localization policy
- testing fixtures must include long English and Korean UI cases

## Revisit Triggers

Revisit only if launch scope, App Store requirements, or localization quality make simultaneous three-language release impractical.

If rollout timing changes, Korean remains part of the intended first-class language model unless explicitly superseded by a new decision.



# DEC-042 — Device Language Resolution Uses Japanese, Korean, Otherwise English

**Status:** Accepted  
**Date:** 2026-09-16  
**Supersedes:** DEC-041 in language-resolution behavior

## Context

TSUGINO supports Japanese, English, and Korean.

A deterministic fallback rule is needed so the app does not depend on every possible device language having a dedicated localization.

Railway station names also need consistent language behavior even when external providers do not return Korean labels.

## Decision

TSUGINO resolves the effective display language as follows:

- Japanese (`ja-*`) → Japanese
- Korean (`ko-*`) → Korean
- every other language → English

English is the global fallback language.

This rule applies to:

- main app UI
- station names
- line names
- operator names
- route results
- journey states
- transfer guidance
- notifications
- Dynamic Island
- Lock Screen Live Activity
- error and recovery states

TSUGINO will maintain canonical localized railway names as needed so Japanese, English, and Korean display quality does not depend entirely on provider localization coverage.

## Rationale

This gives predictable behavior for all users while keeping the initial localization scope controlled.

It also ensures that users with unsupported device languages still receive a coherent English experience rather than mixed or partially localized UI.

## Consequences

- a centralized language resolver is required
- views must not perform their own ad-hoc locale fallback
- station/line/operator canonical localization must support Japanese, English, and Korean
- unsupported device languages fall back to English consistently
- station search aliases should map localized names to the same canonical IDs

## Revisit Triggers

Revisit if TSUGINO officially adds another first-class language.



# DEC-043 — User Identity and Persistent Movement History Are Not Collected; Recent Search Data Is Local-Only

**Status:** Accepted  
**Date:** 2026-09-16

## Context

TSUGINO handles railway journeys and may optionally use device location for nearby-station suggestions.

Collecting unnecessary identity or persistent movement data would increase privacy risk without being required for the core product.

At the same time, locally remembering recently searched stations and recent journeys meaningfully improves convenience for repeat travel.

## Decision

TSUGINO will not collect user identity or persistent movement history by default.

The MVP does not require:

- account creation
- name
- email
- phone number
- advertising identifier
- server-side long-term location history
- server-side complete travel history
- remote behavioral profiling

TSUGINO may store the following convenience data locally on-device:

- recent station searches
- recent journeys
- active Journey state
- settings
- future favorites/pinned journeys

Recent search and recent journey data:

- remain local-only by default
- are not tied to a cloud identity
- are not transmitted for behavioral profiling
- must be clearable by the user
- should be bounded rather than stored indefinitely

## Rationale

The privacy strategy is:

> **Privacy by non-collection.**

If TSUGINO does not need personal data to deliver the feature, it should not collect it.

Local recent-search history preserves useful convenience without creating a centralized movement profile.

## Consequences

- core journey tracking works without an account
- local persistence must support clearing recent data
- analytics/logging must avoid unnecessary identity and movement detail
- future cloud sync or account features require explicit privacy/product decisions
- location permission cannot become an excuse to retain long-term movement history

## Revisit Triggers

Revisit only if a future feature requires cloud identity, synchronization, or server-side personalization.

Any such change requires explicit product, architecture, and privacy review.



# DEC-044 — TSUGINO v1 Is iPhone-Only

**Status:** Accepted  
**Date:** 2026-09-17

## Context

TSUGINO's defining v1 experience centers on iPhone use during rail travel, including:

- Dynamic Island
- Lock Screen Live Activity
- one-handed journey setup
- compact in-transit interaction
- iPhone-specific field testing

Supporting iPad in v1 would expand implementation and QA scope into tablet layouts, multitasking, window sizing, and device-family review behavior without improving the core v1 product goal.

## Decision

TSUGINO v1 will support **iPhone only**.

iPad is explicitly excluded from:

- implementation scope
- design scope
- test scope
- release target
- App Store supported device family for v1

The team should not preserve iPad support merely because the underlying code could potentially run there.

iPad may be reconsidered for a future major version such as v2.

## Rationale

This keeps v1 focused on the product's primary use case and prevents tablet support from increasing complexity, QA burden, and review ambiguity.

## Consequences

- v1 layouts may optimize for iPhone
- iPad-specific navigation and multitasking are out of scope
- release configuration must exclude iPad support
- reviewers should receive an iPhone-only supported-device configuration
- future iPad support requires an explicit new decision and dedicated design/architecture work

## Revisit Triggers

Revisit only for a future major release or an explicit product decision to add iPad support.


# DEC-045 — TSUGINO v1 Minimum Deployment Target Is iOS 18.0

**Status:** Accepted\
**Date:** 2026-09-17\
**Related:** DEC-044 (iPhone-only v1)

## Context

Phase 0 bootstrap (`ROADMAP.md`) requires a deployment target before the Xcode project can be created, and `PROVIDER_FEASIBILITY_AUDIT.md` / `PHASE_0_SCOPE_LOCK.md` identified it as an undecided Decision Gate item.

The only hard platform constraint from the product is ActivityKit (Dynamic Island, Lock Screen Live Activity), which is available from iOS 16.1. Choosing the lowest technically possible version would maximize nominal device reach but would force the codebase to avoid or shim newer SwiftUI, Observation, Swift Testing, and concurrency capabilities for the entire v1 lifetime.

## Decision

TSUGINO v1 has a **minimum deployment target of iOS 18.0**.

- Platform: iPhone only (DEC-044).
- iPad is excluded from implementation, QA, the supported device family, and App Store release.
- The target is **not** lowered to iOS 16.1 merely because ActivityKit would permit it.
- Modern SwiftUI, Observation, and testing foundations and long-term maintainability take priority over nominal backward reach.
- Any future change to the minimum supported iOS version — up or down — is made **only through a new decision record** that supersedes this one.

## Rationale

- iOS 18 gives the app, the Live Activity extension, and the test targets a single modern baseline without availability branching.
- The Journey domain, concurrency ownership rules (ARCH §21–§22), and deterministic testing strategy benefit from current language and framework features rather than compatibility shims.
- The realistic v1 audience (iPhone users on Dynamic Island / Live Activity-capable devices) is served by iOS 18-capable hardware.
- A single, explicit floor is easier to audit in release configuration (Rule 52).

## Consequences

- `IPHONEOS_DEPLOYMENT_TARGET = 18.0` on the app target, the Live Activity extension target, and all test targets.
- No `@available` branching below iOS 18 is written in v1.
- `PRODUCT.md`, `ARCHITECTURE.md`, `ROADMAP.md`, and the Phase 0 documents state iOS 18.0 as current truth.
- Phase 0 acceptance includes verifying the deployment target on every target.

## Revisit Triggers

- A new major iOS release makes a higher floor clearly beneficial for v1 or v2.
- Verified user data shows a material iOS 18-incompatible audience that the product must serve.
- App Store or framework requirements change the constraint.

Any such revisit produces a new decision record; this record is then marked `Superseded`.

---

# DEC-046 — TSUGINO v1 Includes the Nippori-Toneri Liner in Honest Degraded Mode

**Status:** Accepted\
**Date:** 2026-09-18\
**Related:** DEC-004 (Provisional — unchanged), DEC-005, DEC-006, DEC-022, DEC-024, DEC-038, DEC-041, DEC-042, DEC-044, DEC-045

## Context

Phase 0 Track B produced the following verified evidence (`PROVIDER_FEASIBILITY_AUDIT.md` §6.1.3–§6.1.4):

- B4 identified sanitized static route R5 as the **Nippori-Toneri Liner** (日暮里・舎人ライナー), and showed from the static schedule that its absence from all seven observed Toei GTFS-RT snapshots was **not** caused by a lack of scheduled service (11 and 23 scheduled trips overlapped the observations) — `NOT SCHEDULE-EXPLAINED`.
- B5 found explicit official ODPT catalog evidence that the current Toei GTFS-RT **Trip Update** and **Vehicle Position** resources exclude the Liner — `EXPLICITLY EXCLUDED`.
- The current official catalog includes the Liner in **static GTFS**, the **timetable** dataset, **train-status** information, and **GTFS-RT Alerts**.
- Actual Liner Alert/status payload identifiers and semantics remain **pending verification** (all observed Alert payloads were empty).
- DEC-022 requires capability-based behaviour rather than provider-name branching; DEC-038 forbids inventing unsupported precision; DEC-024 makes freshness explicit.
- DEC-004 (route-search provider) remains **Provisional**.

The product owner decided that the Liner stays in v1 scope rather than being dropped because one capability is absent.

## Decision

1. The Nippori-Toneri Liner is **included in TSUGINO v1 product scope**.
2. Capability is evaluated **per service/feed**, not inferred from the operator name. Toei Subway, Tokyo Sakura Tram, and the Nippori-Toneri Liner each carry their own verified capability set even though they share an operator.
3. Under currently verified capabilities the Liner operates in **degraded mode**.
4. Permitted information for the Liner:
   - canonical route and station identity;
   - static stop sequence;
   - scheduled departure and arrival information;
   - service-status information when verified and available;
   - Alerts when verified and available.
5. Prohibited representation for the Liner (and for any service without verified trip-level realtime):
   - fabricated vehicle location;
   - fabricated current station;
   - fabricated delay;
   - fabricated live next-stop progression;
   - schedule-derived state presented as realtime;
   - stale or absent Trip Update / Vehicle Position data presented as an active live feed.
6. Missing Trip Update and Vehicle Position capability is a **service capability state**. It is not a device limitation, not a user-setting failure, and not, by itself, a transient provider error.
7. The UI must distinguish, by provenance: realtime vehicle/progress information; schedule-based information; status/Alert information; temporarily unavailable information.
8. When a capability is unavailable, hide or replace **only** the unsupported live affordance; preserve supported route, schedule, and status/Alert functionality; do not disable the entire service.
9. Live Activity and journey-progress surfaces may show the Liner only in a presentation whose provenance is truthful: scheduled times shown as scheduled; status/Alert information shown with its actual provenance; live current-stop or vehicle progression never shown without verified trip-level realtime. If no honest Live Activity presentation is defined for the available capabilities, the Live Activity **must not start** for that leg.
10. Korean canonical route/station/headsign names and Korean search aliases remain **TSUGINO-owned data** under DEC-041/DEC-042 (the audited Toei feed carries Japanese and English only).
11. A later official Trip Update / Vehicle Position capability may promote the Liner from degraded to trip-level realtime **only after** catalog/license verification, payload/schema verification, identity-join verification, freshness/coverage verification, and UI-state verification.
12. Such a promotion does not reopen whether the Liner belongs in product scope; it changes only the service's verified capability set.
13. This Decision does **not**: select the final provider; resolve DEC-004; claim verified Liner Alert/status payload semantics; claim SLA or uptime; authorize synthetic progress; alter the iPhone-only scope (DEC-044); or alter the Simulator-first development workflow (`AGENTS.md` §22).

Capability-state behaviour (documentation matrix, not code):

| Capability state | Route/schedule | Status/Alert | Live position/progress | Live Activity |
|---|---|---|---|---|
| TU/VP verified | available | when available | allowed | live presentation allowed |
| TU/VP absent, status/Alert available (Liner today) | available | allowed | prohibited | schedule/status-only if explicitly designed; otherwise do not start |
| Status/Alert temporarily unavailable | available | unavailable state | prohibited without TU/VP | never fabricate |
| All provider data unavailable | cached/static policy only | unavailable | prohibited | do not start, or end safely per lifecycle policy |

## Rationale

Dropping a legitimate Tokyo transit service because one feed is absent would narrow coverage for no user benefit, while showing invented progress would violate DEC-038 and erode trust. The capability model of DEC-022 already exists precisely so that features follow what a service can do; the Liner is its first concrete degraded case.

## Consequences

Benefits:

- preserves useful route coverage;
- avoids excluding a legitimate Tokyo transit service;
- communicates data provenance honestly;
- exercises the capability-based architecture required by DEC-022;
- supports future capability promotion without redesigning product scope.

Costs:

- requires explicit degraded-mode UI states (`DESIGN.md` §20);
- requires per-service capability metadata (`ARCHITECTURE.md` §51);
- requires tests preventing synthetic progress;
- may require different Live Activity behaviour by service capability (`FEATURES.md` §7.1, `ARCHITECTURE.md` §28);
- requires project-owned Korean localization;
- requires future Alert/status payload verification.

Relationship to earlier decisions: this Decision **uses** DEC-022's capability model and **confirms** DEC-041/DEC-042 localization ownership. DEC-005 ("realtime wherever supported") and DEC-006 (Vehicle Position optional) are **clarified, not superseded**: neither requires every in-scope service to have trip-level realtime; a service with schedule plus status/Alert information is a supported degraded case, with fallback made explicit as DEC-005 and DEC-024 already require. DEC-004 is neither superseded nor resolved.

## Revisit Triggers

- Official Toei/ODPT Trip Update or Vehicle Position coverage for the Liner appears (promotion via the evidence gates in point 11 — no new scope decision needed).
- Verified Liner Alert/status payloads prove unusable, making even the degraded presentation dishonest.
- A product decision changes v1 geographic or operator scope (DEC-001).

---

# DEC-047 — Initial Release Covers All 13 Tokyo Subway Lines with Capability-Aware Journey Guidance

**Status:** Accepted\
**Date:** 2026-09-19\
**Extended by:** DEC-058 (2026-09-21) — records that the accepted scope below is 15 canonical lines/services including Tokyo Sakura Tram and the Nippori-Toneri Liner, and adds the gated expansion programme; the body of this record is unchanged\
**Closes:** `PROVIDER_FEASIBILITY_AUDIT.md` RK-2 (launch-scope product decision)\
**Related:** DEC-001, DEC-004 (Provisional — unchanged), DEC-005, DEC-007, DEC-022, DEC-024, DEC-032, DEC-037, DEC-038, DEC-041, DEC-042, DEC-046

## Context

Phase 0 Track B established (`PROVIDER_FEASIBILITY_AUDIT.md` §3, §4.1, §6, §12 RK-2):

- Production-usable **trip-level realtime** (GTFS-RT Trip Update / Vehicle Position) exists in Tokyo core for **Toei Subway and Tokyo Sakura Tram only** (VERIFIED_PAYLOAD, seven snapshots of one evening).
- **Tokyo Metro** publishes static GTFS, `odpt:Railway`, line-level `odpt:TrainInformation`, and GTFS-RT Alert under the Basic License; **no Trip Update / Vehicle Position** exists in the audited catalog. Its schedule + status + Alert path is payload-supported — PASS WITH LIMITATIONS (audit §6.2).
- Both licenses expressly allow commercial use and mobile-app release under different compliance regimes (audit §3.5–§3.11); the core route/status path is not blocked by licensing evidence. An ODPT written inquiry on six boundary questions is **awaiting official response** (audit §3.12) — nothing is approved.
- JR East and the seven Challenge-licensed private railways are production-blocked (DEC-037); TWR, MIR, Tama Monorail, and Yurikamome are license-viable but **payload-unverified** (DS-08).
- DEC-046 already accepted an honest degraded-mode product model for a service without trip-level realtime (the Nippori-Toneri Liner) and DEC-022 requires per-service capability behaviour.

RK-2 asked whether a launch in which the largest subway operator runs without trip-level realtime is acceptable. The product owner decided it is, provided the capability difference is explicit and never deceptive.

## User journey-selection model

The interaction model (consistent with DEC-007 explicit train selection) is:

1. the user selects the **boarding station**;
2. the user selects the **intended departure time or scheduled train**;
3. the user selects the **destination or exit station**;
4. TSUGINO follows the selected journey using the **best verified capability available for that service**.

The model is the same for every service; only the capability tier applied in step 4 differs.

## Decision

1. TSUGINO's initial App Store release includes **all 13 Tokyo subway lines** operated by Toei Subway and Tokyo Metro.
2. Capability differs honestly by verified data: the four Toei Subway lines provide **Realtime Journey Tracking**; the nine Tokyo Metro lines provide **Scheduled Journey Guidance** — user-selected, timetable-based journey guidance supplemented by available service-status and Alert information.
3. Timetable-based guidance is **never** presented as actual train location or realtime train progress.
4. The two additional Toei services already evaluated keep their evidence-based classification: Tokyo Sakura Tram (Realtime Journey Tracking, verified) and the Nippori-Toneri Liner (DEC-046 degraded model, which is the Scheduled Journey Guidance tier). They are in scope but are **not** part of the "13 subway lines" statement.
5. All other operators are **Deferred / Unsupported** for initial journey guidance.

## Service-by-service launch matrix

| Service | Operator | Line code | Initial capability tier | Evidence |
|---|---|---|---|---|
| Asakusa Line | Toei Subway | A | **Realtime Journey Tracking** | TU/VP VERIFIED_PAYLOAD (audit §6.1) |
| Mita Line | Toei Subway | I | **Realtime Journey Tracking** | same |
| Shinjuku Line | Toei Subway | S | **Realtime Journey Tracking** | same |
| Oedo Line | Toei Subway | E | **Realtime Journey Tracking** | same |
| Ginza Line | Tokyo Metro | G | **Scheduled Journey Guidance** | static + TrainInformation + Alert (audit §6.2); no TU/VP in catalog |
| Marunouchi Line (incl. branch) | Tokyo Metro | M / Mb | **Scheduled Journey Guidance** | same; branch provenance retained (audit §6.2.4) |
| Hibiya Line | Tokyo Metro | H | **Scheduled Journey Guidance** | same |
| Tozai Line | Tokyo Metro | T | **Scheduled Journey Guidance** | same |
| Chiyoda Line | Tokyo Metro | C | **Scheduled Journey Guidance** | same |
| Yurakucho Line | Tokyo Metro | Y | **Scheduled Journey Guidance** | same |
| Hanzomon Line | Tokyo Metro | Z | **Scheduled Journey Guidance** | same |
| Namboku Line | Tokyo Metro | N | **Scheduled Journey Guidance** | same |
| Fukutoshin Line | Tokyo Metro | F | **Scheduled Journey Guidance** | same |
| *Additional Toei services (not subway lines)* | | | | |
| Tokyo Sakura Tram (Toden Arakawa Line) | Toei | — | **Realtime Journey Tracking** | TU/VP VERIFIED_PAYLOAD (audit §6.1.4) |
| Nippori-Toneri Liner | Toei | — | **Scheduled Journey Guidance** (DEC-046 model; TU/VP officially excluded) | audit §6.1.4; Liner Alert/status semantics still pending |
| *Deferred / Unsupported at initial release* | | | | |
| TWR Rinkai Line, MIR Tsukuba Express, Tama Monorail, Yurikamome | various | — | **Deferred** — license-viable, payload-unverified (DS-08) | promotable via Post-Launch Track A after audit §9.1 |
| JR East, Keio, Odakyu, Seibu, Tobu, Tokyu, Keikyu, Sotetsu | various | — | **Unsupported** — Challenge-only / production-blocked (DEC-037) | audit §3.3, §7 |
| Group B operators (Keisei, Tokyo Monorail, etc.) | various | — | **Unsupported** — not in the audited catalog | audit §4.2, A6 |

## Capability-tier definitions

| Tier | Backed by | May represent | Must not represent |
|---|---|---|---|
| **Realtime Journey Tracking** | verified, production-usable trip-level realtime (Trip Update; Vehicle Position where available) joined to the user-selected trip | actual journey progress within the freshness and precision limits of DEC-024, DEC-038, `ARCHITECTURE.md` §51 | precision beyond the feed (e.g., GPS-grade position from stop-sequence data) |
| **Scheduled Journey Guidance** | the user-selected boarding station, scheduled departure/train, and destination; verified timetable data; available service-status and Alert information | time remaining until scheduled departure; scheduled departure and arrival; scheduled next stop; scheduled journey timeline; clock-based scheduled progress; relevant disruption/status notices; a Live Activity explicitly labelled as timetable-based, if otherwise technically permitted | actual train location; actual station passage; actual departure or arrival; a delay amount derived only from elapsed clock time; onboard confirmation; realtime progress; Trip Update / Vehicle Position coverage that does not exist; that timetable-based animation represents the physical train |
| **Deferred / Unsupported** | — | that the service is not available for journey guidance, with the reason category (evidence, licensing, payload verification, or product support incomplete) | any journey guidance |

The generic word "supported" must not be used where it would hide the tier difference; use the tier label or equivalent wording. Provisional three-language labels (to be reviewed in Phase 11 under DEC-041/DEC-042; not final marketing copy): Realtime Journey Tracking — リアルタイム追跡 — 실시간 추적; Scheduled Journey Guidance — 時刻表ベース案内 — 시간표 기반 안내; Deferred / Unsupported — 未対応 — 미지원.

## Presentation and honesty rules

- Provenance is always explicit and visually distinct (`DESIGN.md` §20): live, scheduled, service status/Alert, unavailable.
- Scheduled progress is clock-derived from the selected schedule and is labelled as scheduled everywhere it appears (main app, Live Activity, Dynamic Island, notifications).
- No scheduled element may use the live badge, live styling, or copy implying observation.
- Delay is shown only when a provider states it; elapsed time alone never produces a delay figure.
- Launch and App Store copy must not claim that all 13 subway lines have realtime tracking.

## Live Activity and Dynamic Island implications

- Tier is a per-service capability state; the Live Activity mapper selects a tier-specific presentation (`FEATURES.md` §7.1, `ARCHITECTURE.md` §28).
- Realtime tier: live presentation as designed.
- Scheduled tier: a timetable-based presentation, explicitly labelled, showing scheduled times, scheduled next stop, and clock-based scheduled progress; no physical-train progression claim. If no honest presentation is defined for the available capabilities, the Live Activity does not start for that leg (DEC-046 point 9 applies).
- A multi-leg journey may mix tiers; each leg presents its own tier.

## Disruption handling

When a provider status or Alert indicates a disruption on a Scheduled-tier service, the scheduled progression must not override or conceal it: the status/Alert is surfaced with its provenance, scheduled times are shown as scheduled-but-possibly-affected, and the user is offered manual correction/recovery (`FEATURES.md` §3.5–§3.6, §16). Japanese-only provider text is presented as provider text, not as a TSUGINO translation, until translation policy is settled (audit §3.12 Q4).

## Consequences

- Phase 2 Tokyo baseline dataset = Toei + Tokyo Metro static data; **cross-operator canonical station identity is launch-relevant** (audit A4, RK-14).
- Phase 4 needs both the GTFS-RT adapter (Toei) and the ODPT JSON status adapter (Tokyo Metro `odpt:TrainInformation` + Alert).
- DEC-032 fixtures must include a Toei↔Tokyo Metro transfer and a mixed-tier journey; tests must prove scheduled progress never renders as live.
- Korean canonical data covers both operators (DEC-041/042); provider Korean in `odpt:Railway` is reviewable input only.
- Attribution/notice screen carries both regimes (CC BY; Basic License three-part notice).
- Basic-License obligations apply to every Tokyo Metro cache: freshness enforcement, deletion capability, no raw or restorable export.
- Marketing and screenshots are constrained by the pending ODPT answers.

## Deferred operators

TWR, MIR, Tama Monorail, and Yurikamome may be promoted through Post-Launch Track A once payload-verified and production-eligible (audit §9.1). JR East and the private railways stay excluded under DEC-037. Nothing in this Decision promotes a payload-unverified or Challenge-only source.

## Relationship to existing decisions

- **DEC-001** — applied, not changed: "as many Tokyo-area lines as can be supported reliably through legally usable data" resolves to the 13 subway lines plus the two evaluated Toei services.
- **DEC-004** — untouched and still **Provisional**; this Decision selects operators for journey guidance, not a route-search provider.
- **DEC-005 / DEC-006** — clarified as in DEC-046: realtime wherever supported; not every in-scope service has it.
- **DEC-007** — the journey-selection model is the explicit-selection rule extended to boarding station and destination.
- **DEC-022** — tiers are derived from declared service capability sets, never from operator names.
- **DEC-032** — fixture list gains cross-operator transfer and mixed-tier scenarios.
- **DEC-037** — Challenge-only data remains production-prohibited.
- **DEC-041 / DEC-042** — three-language rule applies to tier labels and all guidance copy.
- **DEC-046** — **reused, not superseded.** Its degraded-mode model is the Scheduled Journey Guidance tier; the Liner keeps its DEC-046 classification. DEC-046 point 5 forbids schedule-derived state *presented as realtime*; clock-based progress that is explicitly labelled scheduled is permitted by this Decision and does not conflict with it. No accepted decision is contradicted, so nothing is superseded.

## Remaining ODPT licensing gates (not resolved by this Decision)

The inquiry sent 2026-09-19 (audit §3.12) is unanswered. Still pending: App Store screenshots/previews containing Basic-License data; offline bundling of static GTFS in the binary; the non-restorable canonical-data interpretation; Korean translation of Tokyo Metro strings and incident text and its notices; official line colours as standalone tokens; installed-device cache deletion on termination. Official Tokyo Metro logos, station-number icons, and line symbols remain outside the v1 UI. Silence is not approval.

## Criteria for upgrading a service from Scheduled Journey Guidance to Realtime Journey Tracking

Promotion requires, in order (the DEC-046 point 11 gates): catalog/license verification of an official Trip Update (and optionally Vehicle Position) resource; payload/schema verification; identity-join verification against the static feed; freshness/coverage verification across repeated snapshots; UI-state verification. Promotion changes only the service's verified capability set; it does not reopen scope.

## Scope statement

This is a **product-scope decision**. It does not claim that any tier, adapter, screen, Live Activity, fixture, or localization is implemented, and it does not close Phase 0 (remaining A3/A4 work, Track A hardware validation, and DEC-004 stay open).

## Rationale

The Tokyo subway network is Toei and Tokyo Metro together; a launch without Tokyo Metro would make most realistic journeys unsupported and would retrofit cross-operator identity after release. Honest tiers preserve trust (DEC-038) while delivering the coverage users expect (DEC-001).

## Revisit Triggers

- Official Tokyo Metro Trip Update / Vehicle Position coverage appears (promotion via the gates above; no new scope decision).
- The ODPT reply restricts a Scheduled-tier presentation (e.g., screenshots or translation), requiring narrower presentation rules.
- A DS-08 operator becomes production-eligible (Post-Launch Track A, not a scope reopening).
- Verified Tokyo Metro status/Alert payloads prove unusable, making the Scheduled tier dishonest on those lines.

---

# DEC-048 — Cross-Operator Canonical Station Identity for the Toei and Tokyo Metro Launch Set

**Status:** Accepted\
**Date:** 2026-09-19\
**Closes:** `PROVIDER_FEASIBILITY_AUDIT.md` A4 cross-operator canonical station identity (the Toei + Tokyo Metro launch set only)\
**Related:** DEC-021, DEC-026, DEC-041, DEC-042, DEC-047; RK-9, RK-14, RK-17, RK-18

## Context

DEC-047 put **all 13 Tokyo subway lines** in the initial release, so a user journey routinely crosses the Toei ↔ Tokyo Metro boundary. Wrong interchange identity would corrupt route results, transfer guidance, and station search before any realtime feature is involved, which made cross-operator canonical station identity the highest remaining launch risk in Phase 0.

Audit action A4 was executed **offline** on 2026-09-19 against the two retained static snapshots only (`PROVIDER_FEASIBILITY_AUDIT.md` §6.5). Both feeds are flat — `location_type = 0` and empty `parent_station` on every stop row, and neither archive contains `transfers.txt` or `pathways.txt`. Neither operator publishes a shared cross-operator identifier, and `odpt:Railway` carries no connecting-railway field. A4 therefore had to resolve identity from converging structural evidence, with no provider-published transfer relation available anywhere in the launch set.

## Scope

- This Decision covers the initial launch set defined by **DEC-047** — Toei and Tokyo Metro cross-operator canonical station identity.
- It does **not** define the final production canonical ID string format. The analysis group keys were an analysis artifact and carry no implementation commitment.
- Provider station IDs and station codes remain **aliases / source mappings**, never TSUGINO-owned canonical identifiers (Rule 9, DEC-021, ARCHITECTURE §40).
- It does **not** define route-provider transfer edges.
- It does **not** implement any runtime behaviour, adapter, screen, or dataset.

## Accepted aggregate result

| Quantity | Value |
|---|---|
| Toei operator-level identities | 141 |
| Tokyo Metro operator-level identities | 144 |
| Total input identities | 285 |
| Analyzed cross-operator candidates | 54 |
| `resolved_same_station` | 27 |
| `resolved_distinct_station` | 26 |
| `explicitly_ambiguous` | 1 |
| Cross-operator merged groups | 27 |
| Toei-only groups | 114 |
| Tokyo-Metro-only groups | 117 |
| **Proposed canonical station groups** | **258** |
| Duplicate assignments | 0 |
| Unmapped identities | 0 |
| Unexplained collisions | 0 |
| Analysis status | **PASS WITH AMBIGUITIES** |

Reconciliation: 141 + 144 = 285; 27 + 26 + 1 = 54; 114 + 117 + 27 = 258.

## Accepted identity rules

1. **Names generate candidates but never establish identity alone.** Display-name equality is a candidate signal only.
2. **Coordinates corroborate but never establish identity alone.** Spatial proximity may support or contradict a candidate; it may not resolve one by itself.
3. **Structural evidence** means the converging use of: provider station identifiers, station codes and their code systems, line membership, station order, adjacent-station topology, multi-line occurrence structure, original names, and coordinates.
4. **A missing provider-published transfer relationship is an evidence limitation, not a licence to infer one.**
5. **Original provider strings are preserved** for every operator, in every form the provider publishes.
6. **Aliases must be explicit and reversible at the source-mapping layer** — never applied by silently rewriting a provider string.
7. **No parent hierarchy and no transfer relationship may be invented** from the flat feeds.

## Accepted named outcomes

### 市ヶ谷 / 市ケ谷 — one canonical station identity

- Toei publishes 市ヶ谷 (small ヶ, U+30F6); Tokyo Metro publishes 市ケ谷 (full-size ケ, U+30B1). **Both original strings are preserved.**
- ヶ / ケ equivalence is accepted **only as an explicit provider-orthography alias rule**, applied as a separate comparison key. The primary normalized key never collapses the two characters.
- Supporting evidence: both providers give English `Ichigaya`; the candidate is one-to-one with no competitor on either side; the station codes belong to disjoint, internally consistent systems; adjacency stays within each operator's own line; the separation is small relative to spans both operators already accept inside their own interchanges.
- The operator-level orthographic convention behind the alias rule (Toei uses ヶ throughout, Tokyo Metro uses ケ throughout, with no crossover in the retained snapshots) is **derived evidence from the analysis, not a provider statement**.

### 押上 / 押上〈スカイツリー前〉 — one canonical station identity

- Toei publishes 押上; Tokyo Metro publishes 押上〈スカイツリー前〉. **The Tokyo Metro subtitle form is preserved** as the provider's original string.
- Subtitle-aware matching is accepted: a bracketed 〈…〉 subtitle is treated as an explicit provider-presentation variant for candidate generation, again as a separate key that does not rewrite the original.
- This candidate is **not** visible to exact name matching and was missed by the earlier count of 27 exact JA+EN candidates; the recorded candidate total is corrected accordingly.

### 新宿 — remains two separate canonical groups

- Toei 新宿 and Tokyo Metro 新宿 **remain separate canonical station groups**.
- Their relationship is recorded as **`explicitly_ambiguous`**, not as an unresolved merge waiting to happen.
- **No inter-station transfer edge is inferred or recorded** for Shinjuku.
- The names match exactly, but the structural evidence contradicts a merge: the separation exceeds the span either operator accepts inside its own interchanges, and a **different, nearer Toei identity (新宿西口) competes** for the same Tokyo Metro identity. Name evidence and spatial evidence point at different Toei stations, and the retained evidence cannot say which is right.
- **The 258-group total reflects this separate treatment.** An authoritative future merge would reduce the total to **257** and would require a controlled identity migration (Rule 39, DEC-026), not an in-place edit.
- Shinjuku is not merged until authoritative evidence exists — see *Revisit Triggers*.
- **Reviewed evidence added 2026-09-20 (no change to this outcome):** the Toei GTFS-Pathways archive was acquired and analysed offline (audit §6.6). Toei models 新宿 (`stop_id` `428`, `E-27`) and 新宿西口 (`stop_id` `402`, `E-01`) as two separate `location_type = 1` station structures with no shared parent and **zero** pathway edges between them — but the feed contains **zero** edges between *any* two station structures, so this is a property of the dataset, not a finding about Shinjuku. No Tokyo Metro identifier, Marunouchi reference, `M08` code, cross-operator transfer, or shared cross-operator parent occurs anywhere in it. The evidence therefore supports keeping the existing conservative treatment and **changes none of this Decision's conclusions**.

## The 320 m analytical envelope

- 320 m was **derived** from the maximum observed intra-operator station-complex span in the retained snapshots (Tokyo Metro 大手町).
- It was used **only as corroborating evidence inside the A4 analysis**, never as the sole basis for any classification.
- It is **not** product policy.
- It is **not** a production canonicalization threshold.
- It is **not** a runtime invariant.
- It **must not** be implemented as a hard-coded merge rule, a distance-based auto-merge, or any runtime comparison constant.

## Licensing and non-restorability

- Only **aggregate results and the named exceptions above** are recorded in this repository.
- The 285-row mapping is **not** recorded. The full 54-row candidate table is **not** recorded.
- No raw provider data enters the repository, and no repository artifact makes the Tokyo Metro dataset restorable (S2 Art. 8(4); audit §3.6.3; DS-15).
- The retained static evidence stays **outside** the repository in owner-only research storage.

## Consequences

- Phase 2 static-data work inherits 258 proposed canonical station groups as a **planning input**, not as an accepted identifier set.
- The provider-mapping layer must carry, per canonical station: every provider station identifier and code, each provider's original name strings, and any alias rule applied — explicitly and reversibly.
- Search and routing must treat Toei 新宿 and Tokyo Metro 新宿 as two stations until this Decision is revisited.
- A future Shinjuku merge is a **migration event**, not a data correction.

## Scope statement

This is a **data-identity analysis decision**. It does not claim that any mapping table, importer, repository, search index, screen, or localization is implemented, and it does not close Phase 0 (DEC-004 and the remaining Track A/Track B items stay open).

## Rationale

Merging two stations that are not the same corrupts routing and transfer guidance in a way users experience directly and cannot diagnose; keeping two genuinely identical stations apart degrades results more visibly but far more honestly, and is trivially reversible once evidence arrives. With no provider-published transfer relation anywhere in the launch set, the conservative treatment of the one contradictory case is the choice that preserves trust (DEC-038, Rule 50) and keeps the error correctable.

## Revisit Triggers

Revisit the Shinjuku relationship — and only with one of the following in hand:

- A provider-published transfer relation.
- A station-complex or parent-station relation published by either operator.
- An official station-code cross-reference between the two operators.
- ~~Validated GTFS-Pathways evidence~~ — **path completed and exhausted for this question (2026-09-20).** The Toei GTFS-Pathways archive was acquired and inspected offline (`PROVIDER_FEASIBILITY_AUDIT.md` §6.6): it carries **no cross-operator identifier and no cross-structure topology edge**, and the feed models no inter-station connectivity at all, so it can establish neither sameness nor distinctness. It does **not** justify a merge and does **not** prove the stations distinct. The remaining paths below stay open.
- An authoritative operator or ODPT response.
- Equivalent authoritative route-provider evidence whose permitted use has been verified (Rule 40).

**No such evidence exists today** (re-confirmed 2026-09-20 after the GTFS-Pathways path was inspected and exhausted). Absence of a revisit trigger is not a reason to merge, and the absence of cross-operator evidence in a dataset that models no inter-station connectivity is not evidence that the stations are distinct.

Also revisit this Decision if either operator's static feed revision changes station names, codes, or counts, or if a further operator enters the launch set.

---

# DEC-049 — Operator Is Canonical Identity; Railway Capabilities Are Declared at Service/Feed Scope

**Status:** Accepted\
**Date:** 2026-09-20\
**Related:** DEC-021, DEC-022, DEC-041, DEC-042, DEC-046, DEC-047; `RULES.md` Rule 9, Rule 10, Rule 26; `ARCHITECTURE.md` §5.7, §51

## Context

`ROADMAP.md` Phase 1 lists `Operator` among the canonical railway models, but `ARCHITECTURE.md` §5 defined `Station`, `RailwayLine`, `Trip`, and the Journey types without ever defining `Operator`. At the same time §51 states that capability is scoped to the **service/feed**, not the operator, because one operator may publish trip-level realtime for some services and only alerts for others (DEC-046, DEC-047).

That gap left a real ambiguity: one implementer could reasonably give `Operator` a fixed capability set, another could model capabilities separately, and the two designs would be incompatible — DEC-047's capability tiers would then be derivable in one design and not the other.

## Decision

1. **`Operator` is a provider-neutral canonical identity model.** It owns its canonical identifier (`OperatorID`, DEC-021) and the canonical localized display names required by DEC-041 / DEC-042 / Rule 26 (Japanese, English, Korean).
2. **`Operator` must not own a fixed, operator-wide capability set.** Capability is not an attribute of the company.
3. **Railway capabilities are declared at the applicable service/feed scope**, consistent with `ARCHITECTURE.md` §51.
4. **The canonical capability type name is `RailCapability`**, already used in §51. It is the single capability abstraction; no parallel or overlapping capability type is introduced.
5. **Capability-dependent behaviour must be selected from the declared capability value** — never from operator names, line names, or hard-coded provider identity checks (DEC-022, Rule 10).
6. **Capability tiers are derived from declared service/feed capabilities**, including the Toei and Tokyo Metro distinctions already accepted in DEC-047. The tier is a consequence of the declared capability set, not of the operator's name.
7. **Actual provider capability data, canonical mapping tables, and network ingestion remain outside Phase 1** — they belong to Phase 2 and Phase 4.

## Consequences

- `ARCHITECTURE.md` gains an explicit `Operator` definition (§5.7) so the Phase 1 model set is complete.
- Phase 1 defines the shape of `RailCapability` and how a capability-bearing scope is expressed; it does not populate real capability data.
- A future operator can be added by declaring capabilities per service, without touching journey logic (`ARCHITECTURE.md` §50).
- Any code that branches on an operator name is a rule violation (Rule 10), not a style preference.

## Scope statement

This is an **architecture-ownership decision**. It does not claim that any model, adapter, screen, or dataset is implemented, and it does not change any accepted provider capability classification: Tokyo Metro remains Scheduled Journey Guidance and Toei Subway remains Realtime Journey Tracking exactly as DEC-047 records.

## Rationale

Binding capability to the company is the single most likely way to reintroduce provider-name branching by the back door. Declaring capability where the data actually varies — the service/feed — keeps DEC-022 enforceable and lets DEC-047's honest tiering fall out of evidence rather than out of a hard-coded table.

## Revisit Triggers

- A provider publishes capability metadata whose natural granularity is neither service nor feed.
- A future operator's capabilities genuinely cannot be expressed at service/feed scope.
- DEC-047's tier model changes.

---

# DEC-050 — Phase 1 Defines the JourneyEngine Boundary; Phase 5 Owns Its Behaviour

**Status:** Accepted\
**Date:** 2026-09-20\
**Related:** DEC-010, DEC-011, DEC-012, DEC-020, DEC-024, DEC-038; `ROADMAP.md` Phase 1 and Phase 5; `ARCHITECTURE.md` §4, §6, §7

## Context

`ARCHITECTURE.md` §4 places `JourneyEngine.swift` inside `Domain/Journey/` beside the journey models, and `ROADMAP.md` Phase 1 includes the task "define domain protocols". But Phase 1's *Included* list names only the journey **models** (`Journey`, `JourneyLeg`, `JourneyState`, `JourneyPhase`, `JourneyEvent`), while **Phase 5 — Journey Engine** owns progression, realtime reconciliation, through service, journey events, and interruption detection.

Read together, these could authorise either "Phase 1 writes the engine" or "Phase 1 must not touch it at all". Those are materially different plans.

## Decision

1. **Phase 1 may define** the provider-neutral journey domain types, events, commands or inputs, outputs, and the **`JourneyEngine` protocol boundary** required by the domain architecture.
2. **Phase 1 must not implement JourneyEngine runtime behaviour.**
3. **Phase 5 owns** state-transition logic, progression behaviour, realtime/scheduled observation handling, and operational engine behaviour — unchanged from `ROADMAP.md` Phase 5.
4. **Any Phase 1 protocol must remain provider-neutral** and must not import SwiftUI, ActivityKit, a provider SDK, or networking implementation details (`ROADMAP.md` Phase 1 Acceptance Criteria).
5. **Phase 1 tests may verify value semantics and protocol-facing domain contracts**, but must not prematurely implement Phase 5 behaviour.

## Consequences

- The Phase 1 deliverable is a *shape*: types plus a boundary that Phase 5 fills in.
- DEC-011 is unchanged — `JourneyEngine` still owns progression; this Decision only says when that behaviour is built.
- A Phase 1 slice that starts asserting transition outcomes has drifted into Phase 5 and should be stopped (`AGENTS.md` §5.1).

## Scope statement

This is a **phase-ownership clarification**. It does not implement, redesign, or weaken the journey state machine (`ARCHITECTURE.md` §6) and it does not change DEC-010 or DEC-011.

## Rationale

The engine is the highest-risk component in the product. Defining its boundary early makes the domain types answerable to a real consumer; implementing its behaviour early, before static data and realtime shapes exist, would bake in assumptions that Phases 2–4 have not yet earned.

## Revisit Triggers

- Phase 1 discovers that the domain types cannot be validated at all without some engine behaviour.
- `ROADMAP.md` Phase 5 scope changes.

---

# DEC-051 — Canonical Railway Identifiers Reject Blank Values and Preserve Valid Raw Values

**Status:** Accepted\
**Date:** 2026-09-20\
**Related:** DEC-020, DEC-021, DEC-049, DEC-050; `RULES.md` Rule 9, Rule 39; `ARCHITECTURE.md` §39, §40, §41

## Context

Phase 1 slice S1 introduced the five canonical identifiers (`StationID`, `LineID`, `OperatorID`, `TripID`, `JourneyID`) as lossless typed wrappers around a `String`. No accepted document specified a character set or a normalisation rule, so the implementation applied none — correctly.

An independent audit then found that the same reasoning had been extended one step too far: because no document *prohibited* an empty identifier either, construction accepted `""`. That conflates two separate questions. Losslessness is about whether a value may be **altered**; validity is about whether a value may **exist**. A blank identifier alters nothing and identifies nothing: every "unset" station would compare equal to every other, inside a type whose entire purpose is to make identity mistakes impossible.

The cost of deciding is also asymmetric. Making construction failable later is a source-breaking change at every call site. At the time of this Decision the domain has **zero** call sites, so the cost is zero; it rises from S3 onward, when the first model consumes an identifier.

## Decision

1. A canonical railway identifier **must contain at least one non-whitespace character**.
2. An **empty string is invalid**.
3. A string consisting only of whitespace — spaces, tabs, newlines, or any other Unicode whitespace — **is invalid**.
4. A **valid** identifier preserves its original raw value **exactly**.
5. Valid values are **not trimmed**.
6. Case is **not altered**.
7. **No Unicode normalisation** is performed.
8. Separators and provider-like syntax are **not rewritten**.
9. Leading or trailing whitespace **remains preserved** when the value also contains at least one non-whitespace character.
10. The rule is **identical** for `StationID`, `LineID`, `OperatorID`, `TripID`, and `JourneyID`.
11. Direct construction **exposes failure without trapping** — a failable initialiser, never `precondition`, `fatalError`, force-unwrapping, a silent fallback, or a sentinel value.
12. Decoding an invalid identifier **fails deterministically** with `DecodingError.dataCorrupted` rather than constructing an invalid value or crashing. Decoding applies exactly the same rule as direct construction.

Whitespace is evaluated with the Swift standard library's `Character.isWhitespace`, so the rule covers every Unicode whitespace scalar without a Foundation dependency.

## Consequences

- The construction contract of all canonical identifiers changes from infallible to failable; call sites must handle `nil`.
- The domain cannot hold an identifier that identifies nothing, so later slices need no defensive blank checks.
- Validity and losslessness remain separable: a future formatting rule would be a **new** decision, not an extension of this one.
- Persisted identifiers stay byte-identical to the values that produced them, so this Decision introduces no migration (Rule 39).

## Scope statement

This is a **domain identity invariant**. It does not define a provider syntax, a railway-wide identifier grammar, or any character-set rule. Provider-ID parsing and provider-to-canonical mapping remain outside this slice and stay with Phase 2 (`ARCHITECTURE.md` §40). It claims no model, adapter, screen, or dataset is implemented.

**Refusing blank values does not authorise normalisation.** Anything stricter than "at least one non-whitespace character" — a character allowlist, a length bound, a structural format — requires a future explicit decision.

## Rationale

A typed identifier exists to make a whole class of mistakes unrepresentable. Permitting a value that identifies nothing leaves the most common instance of that class — the accidental default — representable, which quietly forfeits much of the type's value while keeping all of its cost.

Blankness is also the one rule that can be stated without knowing anything about any provider's syntax, which is precisely why it can be accepted now while every formatting question stays open.

## Revisit Triggers

- An accepted provider mapping requires a canonical identifier that is legitimately blank.
- A character-set, length, or structural format rule is proposed for canonical identifiers.
- Persistence design (Phase 6) requires a different encoded representation.

---

# DEC-053 — Canonical Railway Models Share a Validated LocalizedRailName; Operator Identity Is OperatorID

**Status:** Accepted\
**Date:** 2026-09-20\
**Related:** DEC-020, DEC-021, DEC-026, DEC-041, DEC-042, DEC-049, DEC-051; `RULES.md` Rule 9, Rule 26; `ARCHITECTURE.md` §5.1, §5.2, §5.7, §39.1, §40

## Context

`ARCHITECTURE.md` §39.1 recommended a `LocalizedRailName` value with `japanese` / `english` / `korean`, while §5.1 `Station`, §5.2 `RailwayLine`, and §5.7 `Operator` each listed three flat `nameJapanese` / `nameEnglish` / `nameKorean` properties. Two representations of the same concept were therefore documented at once, and a contract audit before Phase 1 slice S2 found that two implementers could reasonably build incompatible models from them.

The three names are never meaningful individually — they always travel together, are governed by one language-resolution rule (§39.1), and appear identically in all three canonical models. DEC-051 has already established that a blank canonical **identifier** cannot exist; the same question for canonical **names** was open.

Separately, `Operator` had no stated identity semantics. Whether two `Operator` values with the same `OperatorID` but different display names were the same operator was undefined — a question that decides equality, hashing, deduplication, and every future mapping table.

## Decision

### `LocalizedRailName`

A shared, provider-neutral canonical name value used by `Operator` (S2) and by `Station` and `RailwayLine` (S3). Conceptual properties: `japanese`, `english`, `korean`.

1. **All three canonical names are required.**
2. Each name **must contain at least one non-whitespace character**.
3. **Empty and whitespace-only names are invalid.**
4. Valid names are **preserved exactly**.
5. **No trimming.**
6. **No case change.**
7. **No Unicode normalisation.**
8. Leading or trailing whitespace **remains preserved** when a non-whitespace character exists.
9. The Japanese, English, and Korean values **may be identical** — some operator and station names are written the same way in more than one language.
10. Provider-supplied names are **normalisation inputs**, not themselves the sole canonical source (§39.1, Rule 26).
11. Missing canonical Korean data is supplied by **TSUGINO's canonical dataset**, never represented as a blank string (DEC-041, DEC-042).
12. Language selection and device-language fallback **do not mutate stored canonical names** — resolution is a read-time concern (§39.1).
13. This Decision does **not** implement `LanguageResolver`, UI localization, provider mapping, or any canonical railway data.

This supersedes the flat three-property depiction in §5.1, §5.2, and §5.7, which are updated to reference `LocalizedRailName`. Only one representation remains.

### `Operator`

Stored domain identity: **`OperatorID`**. Stored canonical name: **`LocalizedRailName`**. Nothing else — **no** provider ID, **no** capability set, **no** provider metadata, **no** logo, colour, abbreviation, URL, or UI metadata, and **no** actual Tokyo Metro or Toei data.

1. **`OperatorID` is the sole identity source.**
2. **Equality is based only on `OperatorID`.**
3. **Hashing is based only on `OperatorID`.**
4. Canonical names **may change without changing Operator identity** — a renamed operator is the same operator.
5. Two `Operator` values with the same ID but different canonical names **represent the same Operator identity**.
6. The `Codable` representation may carry both ID and name, but **payload equality is not the definition of domain identity**.
7. Construction accepts an **already valid** `OperatorID` and `LocalizedRailName`.
8. `Operator` **does not repeat** the name validation already enforced by `LocalizedRailName`.

## Consequences

- One canonical name representation exists, so S3's `Station` and `RailwayLine` inherit a settled contract instead of reopening it.
- Blank canonical names are unrepresentable, matching DEC-051's treatment of identifiers; the two rules are deliberately consistent but remain separate decisions.
- ID-only equality means a set or dictionary of operators deduplicates by identity, not by display text — which is what every mapping table needs (§40).
- Because equality ignores names, a caller that genuinely needs to compare display text must compare the names explicitly. That is intentional.

## Scope statement

This is a **domain model contract**. It implements nothing, defines no provider syntax, and adds no data. Provider-to-canonical mapping stays in Phase 2 (§40); language resolution and UI localization stay in Phase 11 (§39.1, DEC-042). Validity and losslessness remain separate concerns: rejecting blank names does not authorise normalising the names that remain.

## Rationale

Keeping two representations of the same concept in the architecture is how two correct-looking implementations become incompatible. Choosing the shared value is not about reducing repetition — it is that the three names share one invariant, one resolution rule, and one lifetime across three models, so they are one concept.

ID-only identity follows from what an identifier is for. A name is display data that changes for editorial reasons; if it participated in equality, a renamed operator would silently become a different operator everywhere it had been stored.

## Revisit Triggers

- A canonical model needs a fourth language or a language-tagged name set beyond JP/EN/KO.
- An accepted provider mapping requires a legitimately blank canonical name.
- A canonical model needs identity that is not its canonical ID.

---

# DEC-054 — RailCapability Uses Nine Atomic Capabilities; Guidance Tier Is Derived from the Declared Set

**Status:** Accepted\
**Date:** 2026-09-20\
**Related:** DEC-022, DEC-024, DEC-038, DEC-046, DEC-047, DEC-049, DEC-050; `RULES.md` Rule 10, Rule 12; `ARCHITECTURE.md` §51, §5.7

## Context

DEC-022 and `ARCHITECTURE.md` §51 list eight atomic capabilities. But §51's own tier rule and DEC-047's Scheduled tier both treat **service status** as an input alongside `alerts`, and the provider evidence records them as distinct resources — Tokyo Metro publishes line-level `odpt:TrainInformation` **and** GTFS-RT Alert as separate things (DEC-047 context). Service status was being used as a capability while not being one.

§51 also still opened with "Each operator/provider should declare supported capabilities", which DEC-049 had already corrected: capability is declared at **service/feed scope** and is never a fixed `Operator` property. Two contradictory ownership statements sat in the same section.

Finally, DEC-047 describes the Realtime tier as backed by "**verified**" trip-level realtime, while DEC-049 says tiers are "derived from the declared capability set". Whether a second verification flag was required was undefined, and that decides the signature of the derivation.

## Decision

### Vocabulary

`RailCapability` is the **single canonical atomic capability type** (DEC-049) with **nine** cases:

`staticSchedule` · `tripUpdates` · `vehiclePosition` · `alerts` · `serviceStatus` · `platform` · `recommendedCar` · `recommendedDoor` · `exitGuidance`

**`serviceStatus` is separate from `alerts`.** Service-status information and alert resources are distinct data concepts, the scheduled-guidance rules already treat them separately, and conflating them would make a service's declared coverage unrepresentable. No provider name or provider resource identifier appears in the type contract.

### Capability set

The declared capability collection is conceptually `Set<RailCapability>`.

1. **Atomic capability and derived guidance tier are different concepts.**
2. **All combinations are representable** in Phase 1.
3. Phase 1 **does not reject** unusual or incomplete combinations.
4. **An empty capability set is representable.**
5. Capability presence must **never** be inferred from Operator identity, Operator name, line identity, line name, or provider identity (DEC-022, Rule 10).
6. Capabilities are declared **only after the applicable evidence gates have been satisfied** (DEC-046 point 11 gates).
7. **Presence in the declared set therefore means that capability has passed the required verification gate.**
8. Phase 1 defines **capability vocabulary and pure derivation only**.
9. Phase 1 **does not create a service/feed carrier**.
10. Phase 1 **does not attach** capabilities to `Operator`, `Station`, `RailwayLine`, `Trip`, or any invented `Service` type.
11. Actual service/feed-scoped declaration, ingestion, and attachment remain **Phase 4** concerns (`ROADMAP.md` Phase 4).
12. Do **not** introduce `ServiceID`, `FeedID`, `RailService`, `ServiceScope`, or another carrier merely to store the set.

### Derived guidance tier

A provider-neutral derived tier with three semantic cases — **Realtime Journey Tracking**, **Scheduled Journey Guidance**, **Deferred / Unsupported** (DEC-047). Swift case spelling follows the repository's lowerCamelCase convention: `realtimeJourneyTracking`, `scheduledJourneyGuidance`, `deferredOrUnsupported`.

Derivation from the declared set:

1. If the set contains **`tripUpdates`** → **Realtime Journey Tracking**.
2. `vehiclePosition` is **optional** for Realtime Journey Tracking.
3. `staticSchedule` is **not additionally required** when `tripUpdates` is declared.
4. Otherwise, if the set contains **`staticSchedule`** → **Scheduled Journey Guidance**.
5. `alerts` and `serviceStatus` are **optional supplements** to Scheduled Journey Guidance.
6. Otherwise → **Deferred / Unsupported**.
7. An **empty set** → Deferred / Unsupported.
8. **Alerts-only** → Deferred / Unsupported.
9. **Service-status-only** → Deferred / Unsupported.
10. **Vehicle-position-only** → Deferred / Unsupported.
11. **`staticSchedule` + `vehiclePosition` without `tripUpdates`** → Scheduled Journey Guidance.
12. Other extra capabilities **do not promote a tier** by themselves.
13. **Operator or provider identity never affects derivation.**
14. **Provenance is not an input** to this pure derivation.
15. **Realtime freshness is not an input** to this pure derivation.
16. Declared capability presence already means the evidence gate was passed; **no second verification Boolean is introduced**.
17. The tier **does not claim live data availability at a particular instant**.
18. Runtime freshness, observed state, degraded state, and presentation behaviour remain **later** concerns (DEC-024, Rule 12, Phase 4 / Phase 7 / Phase 9).

## Consequences

- The derivation is a pure function of `Set<RailCapability>`, so it needs no type from a later slice and can be tested exhaustively.
- A service declared with only `alerts` or only `serviceStatus` is honestly Deferred / Unsupported rather than quietly presented as guidance (DEC-038).
- Because unusual combinations stay representable, a provider that publishes something the vocabulary did not anticipate is recorded rather than rejected — and any rule about such a combination remains a future decision.
- `Operator` gains no capability member, so Rule 10's prohibition cannot be defeated by reaching through the operator.

## Scope statement

This is a **domain vocabulary and derivation contract**. It implements no adapter, dataset, carrier, or presentation, and it changes no accepted provider capability classification: Toei Subway and Tokyo Sakura Tram stay Realtime Journey Tracking and the nine Tokyo Metro lines and the Nippori-Toneri Liner stay Scheduled Journey Guidance exactly as DEC-046 and DEC-047 record. Adding `serviceStatus` to the vocabulary describes coverage those services already had; it promotes nothing.

## Rationale

Tiers must fall out of evidence, not out of a table of operator names, or the honesty rules in DEC-038 and DEC-047 become a matter of discipline rather than of structure. Making the derivation a pure function of the declared set is what makes that enforceable.

Treating declaration as the verification record — rather than adding a second "verified" flag — keeps one source of truth. A flag that could disagree with the declared set would eventually disagree.

## Revisit Triggers

- A provider publishes a capability the nine-case vocabulary cannot express.
- An accepted rule makes a currently representable combination invalid.
- DEC-047's tier model changes.
- Phase 4 finds that service/feed-scoped declaration needs a domain carrier defined earlier than planned.

---

# DEC-055 — Station and RailwayLine Identity, Relationships, and S3 Slice Boundaries

**Status:** Accepted\
**Date:** 2026-09-21\
**Related:** DEC-018, DEC-021, DEC-029, DEC-048, DEC-050, DEC-051, DEC-053, DEC-054; `RULES.md` Rule 8, Rule 9, Rule 26, Rule 39, Rule 45, Rule 53; `ARCHITECTURE.md` §5.1, §5.2, §5.3, §5.7, §9, §39, §39.1, §40, §41

## Context

`ROADMAP.md` Phase 1 lists `Station` and `RailwayLine` among the canonical railway models, and DEC-053 assigns both to Phase 1 slice S3. A read-only contract audit before S3 found that the models could not be implemented as `ARCHITECTURE.md` §5.1 and §5.2 then wrote them without either violating an accepted decision or inventing policy.

**The `Station.operatorID` contradiction.** §5.1 gave every `Station` exactly one `operatorID`. But DEC-048 accepts that a canonical station may be *one* identity served by *two* operators: of the 258 proposed canonical station groups, 27 are cross-operator merges (市ヶ谷 / 市ケ谷 and 押上 / 押上〈スカイツリー前〉 among them), and §40 requires each canonical station to carry *every* provider's identifiers. A single-valued operator on `Station` is unrepresentable for those 27 stations. A "primary operator" would be a new concept no document supports, and a stored set of operators would duplicate what the line relationships already say and could drift from it.

**Unspecified fields presented as settled.** §5.1 listed `latitude` and `longitude`, and §5.2 listed `color` and `stationSequence`, with no accepted representation, range, validity, optionality, or identity rule for any of them anywhere in the repository. Colour is additionally documented both as a Domain property (§5.2) and as a DesignSystem token (`DESIGN.md` §30), some provider records carry no colour value, and the use of official line colours as standalone tokens is an open ODPT licensing gate (DEC-047). Topology has documented cases — the Marunouchi main line and branch — where a linear station array's meaning is undecided, and no document addresses loops, minimum counts, or repeated stations.

**Identity semantics.** DEC-053 decided ID-only identity for `Operator` and named it as the default for canonical models, but no accepted text said so for `Station` or `RailwayLine`.

Two implementers reading the documents as they stood could reasonably have produced incompatible models. As with S2, the contract is locked before code is written.

## Decision

### D1 — `Station` does not own a single `OperatorID`

1. `Station` **must not** store `operatorID`.
2. Operator participation is **dataset-level relational information**, obtained by joining `Station.lineIDs` to the canonical `RailwayLine` records and reading each `RailwayLine.operatorID`.
3. Operator participation **does not participate in `Station` identity**.
4. `Station` must **not** introduce `primaryOperatorID`, `operatorIDs`, a `StationGroupID`, an `InterchangeID`, provider identifiers, station codes, or transfer or parent-station relationships. DEC-021's list of canonical identifiers is unchanged.
5. Cross-operator grouping continues to use the canonical `StationID` contract of DEC-048: a resolved cross-operator station is **one** `StationID`; an unresolved or ambiguous pair remains **two** `StationID`s with no inferred relationship. **DEC-048 is preserved in full**; this Decision removes the one field that could not honour it.

### D2 — Station–line membership is `lineIDs: Set<LineID>`

`Station` stores `lineIDs: Set<LineID>`. This is an architecture decision, not a local implementation choice.

1. Membership is **unordered**; no document assigns meaning to the order in which a station's lines are listed.
2. **Duplicate membership is not meaningful**, which the set type makes unrepresentable.
3. The set **may be empty**. Phase 1 value construction must not invent a dataset-completeness rule; whether a canonical station with no line is a data error is a Phase 2 import concern.
4. The set contains **canonical `LineID` values only** — never provider railway identifiers or station codes (Rule 9, DEC-020, DEC-021).
5. `lineIDs` is **descriptive metadata** and does not participate in `Station` identity (D3).
6. **Consistency between `Station.lineIDs` and canonical line topology** (S3c) is a **dataset/import validation responsibility**, not an invariant the isolated `Station` value can or should enforce.
7. `Set` `Codable` element ordering is **not a semantic contract**. The encoded field name and the meaning of its elements may be pinned by tests; byte-for-byte JSON element order must not be treated as canonical or asserted.

### D3 — `Station` and `RailwayLine` identity is the canonical ID alone

1. `Station` identity is determined **exclusively by `StationID`**. `RailwayLine` identity is determined **exclusively by `LineID`**.
2. For both, **equality and hashing use only the canonical identifier**.
3. Names, memberships, coordinates, operator relationships, colour, and topology are **descriptive data** and do not participate in identity.
4. Equality and hashing **must be implemented explicitly** when the models are implemented, following the `Operator` precedent (DEC-053), so that a future stored property cannot fold itself into identity.
5. Renaming or correcting descriptive metadata **does not create a new canonical entity**. A merge or split of canonical identities remains an identity migration (Rule 39, DEC-048), never an in-place edit.
6. `Codable` round-trip tests **must compare stored fields individually**, because ID-only equality cannot prove that descriptive fields survived encoding.

### D4 — S3 is subdivided into S3a, S3b, and S3c; completing S3a does not close S3

#### S3a — identity and relationship core (the immediate next implementation slice)

S3a may implement **only**:

```text
Station
- id        (StationID)
- name      (LocalizedRailName)
- lineIDs   (Set<LineID>)

RailwayLine
- id          (LineID)
- operatorID  (OperatorID)
- name        (LocalizedRailName)
```

Both models are provider-neutral; `nonisolated`; `Hashable`, `Codable`, and `Sendable`; **non-failable** to construct from already-valid component values (each component enforces its own rule — DEC-051, DEC-053 — and the model repeats none of it); and **explicitly ID-only** for equality and hashing (D3).

S3a **must not** add coordinates, line colour, station topology, provider mappings, actual railway data, or any later-slice domain model.

#### S3b — coordinate contract (gated; remains Phase 1)

S3b decides and implements the provider-neutral coordinate value and its relationship to `Station`. It **remains part of Phase 1** and must be completed before S3 can be declared complete.

The S3b contract must be **locked before its code is written** and must address at least: the provider-neutral representation; **required versus optional** `Station` ownership — deliberately **not decided here**, because no accepted repository contract answers it unambiguously; the finite-value requirement; the latitude range; the longitude range; `(0, 0)` handling; signed zero; exact preservation versus normalisation or rounding; `Codable` rejection of invalid values; exclusion of coordinates from `Station` identity (already fixed by D3); and selection of one canonical coordinate for a cross-operator station group.

The expected technical direction is a **provider-neutral Domain value** rather than `CLLocationCoordinate2D` or any other framework type, because Domain imports no platform or provider framework. **No S3b contract or implementation exists yet**; this paragraph records the questions, not their answers.

#### S3c — railway topology contract (gated; remains Phase 1)

S3c decides and implements canonical ordered line topology. It **remains part of Phase 1** and must be disposed of before S3 can be declared complete.

Before topology code is written, a separate contract audit or decision must address at least: the representation of ordered station topology; minimum station count; duplicate `StationID` policy; circular lines; branches; the Marunouchi main line and branch relationship; whether a branch is a separate canonical `LineID`, a segment, or another provider-neutral structure; the distinction between **canonical line topology** and a **Trip's stop sequence**; and dataset-level consistency with `Station.lineIDs`.

`stationSequence` is **not** part of the S3a `RailwayLine` contract. **`Trip` retains ownership of `direction` and `stopSequence`** (`ARCHITECTURE.md` §5.3); nothing in S3 moves service-pattern behaviour onto `RailwayLine`.

#### Completion rule

Completing S3a **does not** close S3. S3 may be marked complete only after **all** of the following hold:

1. S3a is implemented and audited;
2. S3b is contract-locked and implemented, **or** an explicit accepted decision moves coordinates out of Phase 1;
3. S3c is contract-locked and implemented, **or** an explicit accepted decision moves canonical line topology out of Phase 1;
4. the resulting S3 scope passes its independent audit.

This Decision does **not** move coordinates or topology out of Phase 1. It only gates each behind its own contract.

### D5 — Railway line colour is deferred beyond Phase 1

Line colour is **excluded** from S3a, S3b, S3c, and the Phase 1 implementation contract.

Reasons: its representation is unspecified; repository documents conflict over whether it is canonical Domain data (`ARCHITECTURE.md` §5.2 as previously written) or a DesignSystem token (`DESIGN.md` §30); some provider records supply no colour value; the use of official line colours as standalone tokens remains subject to the unresolved ODPT licensing gate (DEC-047); and SwiftUI, UIKit, and provider SDK colour types must not enter Domain.

Colour requires a **later explicit ownership and representation decision** once the relevant licensing evidence is available — most plausibly during Phase 2 data/design integration. That decision is **not made here**: no colour type, hex or RGB contract, UI token, or placeholder field is created. DEC-018 (real line colours take presentation priority over brand accent) is unchanged; it governs how a colour is used once one exists, not where it is stored.

## Consequences

- `ARCHITECTURE.md` §5.1 and §5.2 are rewritten to show only the S3a properties as settled, with coordinates marked S3b-gated, topology S3c-gated, and colour deferred beyond Phase 1.
- `ROADMAP.md` Phase 1 gains the S3a / S3b / S3c subdivision and the S3 completion rule so that finishing S3a cannot be mistaken for finishing S3.
- The S3a models can be implemented from this record alone, with zero call sites to break when S3b later adds a coordinate property.
- Any operator-derived behaviour for a station must go through its lines; there is no shortcut that reintroduces a single operator per station.
- **Model invariants** (blank identifiers, blank names, and later coordinate validity) are enforced by the Domain value types. **Dataset validation** — empty `lineIDs`, `lineIDs` ⇄ topology agreement, coordinate completeness, one coordinate per cross-operator group — belongs to the Phase 2 importer and static-data tests, not to Phase 1 value construction.
- Colour, when decided, is added by a new decision rather than by extending this one.

## Scope statement

This is a **domain model contract and slice-boundary decision**. It claims that **no model, test, adapter, screen, mapping table, or dataset is implemented**, and that S3a implementation has **not** started. It defines no provider syntax, adds no data, and does not touch `Trip`, `ServiceType`, the Journey models, `JourneyEngine` (DEC-050), `RouteSearching`, persistence, or capability attachment (DEC-054). Provider-to-canonical mapping and the 258-group planning input stay in Phase 2 (DEC-048, §40).

## Rationale

Removing `Station.operatorID` is the smallest change that makes §5.1 and DEC-048 say the same thing: the line already carries the operator, and a station's operators are exactly the operators of its lines. Anything more would be a second source of truth for a fact the dataset already encodes.

Gating coordinates, topology, and colour behind their own contracts — instead of guessing — follows the pattern that DEC-051 and DEC-053 established: an undocumented invariant frozen into a Phase 1 value type becomes a persisted-data contract that is expensive to change, while adding a property to a model with no call sites is nearly free. Locking what is known and naming what is not keeps S3 honest about its own completeness.

## Revisit Triggers

- An accepted provider mapping or product rule genuinely requires a station-level operator concept that cannot be derived through its lines.
- S3b or S3c evidence shows that `Set<LineID>` cannot represent a needed membership relation (for example, ordered or directional membership).
- A later accepted decision moves coordinates or canonical topology out of Phase 1 (the completion rule already anticipates this).
- The ODPT licensing response or a design decision settles colour ownership, at which point a new colour decision is written.
- DEC-048's Shinjuku relationship is revisited, which is an identity migration and must not be handled by editing these models in place.

---

# DEC-056 — Canonical Station Coordinates Use a Validated WGS 84 Domain Value

**Status:** Accepted\
**Date:** 2026-09-21\
**Related:** DEC-021, DEC-026, DEC-040, DEC-048, DEC-051, DEC-053, DEC-055; `RULES.md` Rule 4, Rule 8, Rule 9, Rule 39, Rule 45, Rule 53; `ARCHITECTURE.md` §5.1, §5.1.1, §39, §40, §41; `ROADMAP.md` Phase 1 Slice S3, Phase 2

## Context

DEC-055 D4 gated station coordinates behind their own contract (slice S3b) and listed the questions that contract had to answer — provider-neutral representation, required versus optional `Station` ownership, finite-value and range rules, `(0, 0)` and signed-zero handling, exact preservation, `Codable` rejection, exclusion from identity, and one canonical coordinate per cross-operator group — while deliberately deciding none of them. S3a is implemented and independently approved; `Station` currently stores `id`, `name`, and `lineIDs` and no coordinate.

A read-only S3b audit found that no repository document states what a coordinate *means*: nothing names a reference system, an angular unit, or an axis order, and the only quality evidence is that provider points are "single points with no accuracy metadata and no statement of what they mark" (`PROVIDER_FEASIBILITY_AUDIT.md` §6.5). Numeric ranges alone would leave the value undefined.

The official GTFS Schedule reference (gtfs.org/documentation/schedule/reference, verified 2026-09-21) defines the `Latitude` field type as "WGS84 latitude in decimal degrees" within `-90.0...90.0` and `Longitude` as "WGS84 longitude in decimal degrees" within `-180.0...180.0`, and makes `stop_lat` / `stop_lon` **required** for `location_type` 0, 1, and 2. Every retained launch-set stop row is `location_type = 0` (audit §6.5), and the DEC-048 identity analysis used coordinates as structural corroboration for every resolved merge. No accepted product contract defines "coordinate unavailable" as a legitimate canonical Station state; DEC-053 already took the same position for canonical Korean names — the canonical dataset supplies the value, and the Domain has no representation for "absent".

The cost asymmetry is the one DEC-051 relied on: `Station` has no persisted instances and no production call sites, so adding a required field now is free, whereas tightening an optional field after Phase 2 data and Phase 6 persistence exist is a migration.

## Decision

This Decision **locks the S3b contract**. It claims **no** implementation: `GeoCoordinate` does not yet exist, `Station` does not yet carry a coordinate, and no canonical coordinate data has been populated or verified.

### 1. One provider-neutral coordinate value: `GeoCoordinate`

S3b introduces exactly one new Domain value type with this public shape:

```swift
nonisolated struct GeoCoordinate: Hashable, Codable, Sendable {
    let latitude: Double
    let longitude: Double

    init?(latitude: Double, longitude: Double)
}
```

1. It belongs to the provider-neutral Domain and **imports nothing** — no CoreLocation, MapKit, SwiftUI, UIKit, provider SDK, or networking framework. It does not wrap `CLLocationCoordinate2D`.
2. It carries **no** provider identity, provenance, altitude, accuracy, timestamp, source, projection, provider metadata, or location-permission state.
3. Equality and hashing are **complete-value** over `latitude` and `longitude` (synthesized). It is a value, not a canonical entity: it has no identifier and is not listed in DEC-021.
4. It performs **no** distance, averaging, comparison, or merge logic.

### 2. Coordinate meaning: WGS 84 latitude and longitude in decimal degrees

1. `latitude` is the **WGS 84 latitude in decimal degrees** — the north-positive angular position relative to the equator.
2. `longitude` is the **WGS 84 longitude in decimal degrees** — the east-positive angular position relative to the prime meridian.
3. The wording deliberately matches the GTFS field-type concept directly. No EPSG code, projection, or alternative reference system is part of the canonical contract.
4. Named properties and keyed `Codable` fields remove positional axis ambiguity. **No tuple, array, or unnamed positional representation** is used anywhere.

### 3. Every canonical `Station` stores exactly one required coordinate

```text
Station
- id          (StationID)
- name        (LocalizedRailName)
- coordinate  (GeoCoordinate)   ← required, never optional
- lineIDs     (Set<LineID>)
```

1. `Station.coordinate` is `GeoCoordinate`, **not** `GeoCoordinate?`. Source-level property and initialiser order may follow repository style; the stored fields and their semantics are fixed.
2. A canonical Station with an unknown or unselected coordinate **must not be emitted** as a valid Phase 1 Station value.
3. If Phase 2 cannot select a valid coordinate for a canonical record, the importer or mapping workflow **rejects or holds back** that record. It must not use `nil`, invent a coordinate, substitute `(0, 0)`, clamp an invalid value, or silently select a provider point without an explicit mapping policy.
4. This is intentional: the retained launch-set stop rows are all `location_type = 0`; official GTFS requires latitude and longitude for those rows; the DEC-048 audit used coordinates as structural corroboration; no accepted contract defines "coordinate unavailable" as a legitimate canonical state; Phase 2 owns incomplete-ingestion handling; and a required field now avoids spreading optional handling and avoids tightening an optional schema later (Rule 39).
5. Nothing here claims that actual canonical Station coordinates have been populated or verified.

### 4. Numeric validity

A `GeoCoordinate` is valid only when **both** values satisfy every applicable rule.

| Input | Outcome |
|---|---|
| `latitude` finite and in `-90...90` (inclusive) | accepted |
| `longitude` finite and in `-180...180` (inclusive) | accepted |
| exact boundary values `-90`, `90`, `-180`, `180` | accepted |
| `Double.nan` in either field | rejected |
| positive or negative infinity in either field | rejected |
| any value outside its range | rejected — **never clamped** |
| `(0, 0)` | **valid**; it never represents absence or failure |
| finite subnormal values | accepted |
| Tokyo or Japan bounding box | **not applied** — the value is provider- and region-neutral |
| rounding, precision reduction, geographic normalisation | **none** — a valid input is stored exactly |

The direct initialiser is **failable** and returns `nil` for any invalid coordinate. It **never traps** — no `precondition`, `fatalError`, force unwrap, silent fallback, or sentinel (DEC-051 rule 11).

### 5. Signed zero

1. `-0.0` and `0.0` are both valid.
2. They compare equal under Swift `Double` semantics and must hash consistently (the standard library already guarantees this).
3. S3b performs **no** explicit signed-zero normalisation.
4. **No contract promises that the sign of zero survives encoding and decoding.** Tests must not assert serialised signed-zero preservation or exact JSON spelling.
5. Loss of the sign of zero is not coordinate rounding and must not be described as such.

### 6. `Codable`

`GeoCoordinate` uses the keyed shape:

```text
{ "latitude": <Double>, "longitude": <Double> }
```

1. Encoding may be synthesized.
2. Decoding **must apply the same invariants as direct construction**; a custom `init(from:)` is required unless an equally narrow implementation demonstrably enforces the same invariant.
3. Decoded out-of-range or non-finite values fail with **`DecodingError.dataCorrupted`**.
4. Missing keys retain the container's normal `keyNotFound` behaviour; wrong types retain normal `typeMismatch` behaviour.
5. Valid finite values round-trip without application-level rounding or clamping.
6. JSON key order, whitespace, numeric spelling, and byte-for-byte output are **not** contracts.
7. `JSONEncoder`'s default rejection of non-finite values is only a backstop; it is not a substitute for construction and decode validation.

After S3b implementation, `Station`'s keyed shape deliberately becomes `{ "id", "name", "coordinate", "lineIDs" }` with `coordinate` nested. No persisted Station schema exists yet (persistence is Phase 6), so this change requires migration *thinking* (Rule 39) but no production migration implementation.

### 7. `Station` identity is unchanged

1. `StationID` remains the **sole** Station identity (DEC-055 D3).
2. The coordinate does **not** participate in `Station.==` or `Station.hash(into:)`.
3. A coordinate may be corrected without creating a new Station.
4. Because ID-only equality cannot prove coordinate preservation, `Codable` and actor-transfer tests must check the coordinate **explicitly**, field by field.
5. `Station` construction remains **non-failable** when it receives an already-valid `GeoCoordinate`; it repeats no validation.
6. The existing semantics of `name` and `lineIDs` (DEC-053, DEC-055 D2) are unchanged.

### 8. Cross-operator canonical stations: value shape in Phase 1, data policy in Phase 2

**Phase 1 (S3b) owns only the value shape:**

- one canonical Station has **exactly one** canonical coordinate;
- coordinates **never** establish or merge Station identity (DEC-048 rule 2, Rule 53);
- same-name or nearby points never trigger automatic grouping;
- **no distance threshold — including 320 metres — enters Domain** (DEC-048);
- `GeoCoordinate` performs no distance, averaging, comparison, or merge logic.

**Phase 2 owns the data policy:**

- selecting the representative coordinate for a canonical station group;
- choosing among multiple provider points;
- deciding whether an explicitly derived point is ever appropriate;
- recording selection rationale and provider provenance **in mapping data** (`ARCHITECTURE.md` §40);
- retaining original provider coordinates **outside** the canonical Station value when needed;
- rejecting or holding back a station when no valid representative coordinate can be selected;
- documenting what the selected point represents (platform, station centre, or another published provider point).

Averaging coordinates must **never** occur implicitly; if Phase 2 ever uses an averaged or otherwise derived point, that policy is explicitly documented and reviewable. Ambiguous identities such as the DEC-048 Shinjuku case remain **separate** Stations with separate coordinates. **No provenance type and no provider-coordinate collection** is introduced into the Phase 1 Domain.

### 9. Outside S3b

S3b does not own: user-location permission; CoreLocation acquisition; location-authorisation UI; distance calculation; nearby-station ranking; location-based search behaviour; geofencing; route search; map rendering; transfer topology; station identity resolution; provider ingestion; canonical mapping-table population; actual Tokyo station coordinates; S3c railway topology; line colour (DEC-055 D5); `Trip`, `ServiceType`, Journey, or `JourneyEngine`; persistence implementation; UI or Live Activities. Coordinates may later be consumed by nearby-station features (DEC-026, DEC-040); S3b provides only the validated value and its Station relationship.

## Consequences

- `ARCHITECTURE.md` §5.1 shows `coordinate: GeoCoordinate` as a settled required property, and a new §5.1.1 describes the value; §40 states that representative-coordinate selection and provenance are Phase 2 mapping responsibilities.
- `ROADMAP.md` Phase 1 Slice S3 records S3b as **contract-locked, implementation pending**; S3 remains incomplete until S3b and S3c are disposed of (DEC-055 completion rule).
- S3b implementation is two small commits with zero production call sites to break: the `GeoCoordinate` value with its tests, then `Station.coordinate` with the existing Station tests updated (every construction site, the round-trip and encoded-key tests, malformed nested-coordinate payloads, and the actor-transfer check).
- Phase 2's importer gains a hard requirement: a canonical station without a selectable coordinate is an import failure, not a canonical record.
- The Domain still has no representation for "unknown coordinate"; introducing one would be a new decision, not an extension of this one.

## Scope statement

This is a **domain value contract and slice-boundary decision**. It implements nothing, adds no data, defines no provider syntax, and does not implement `GeoCoordinate`, modify `Station`, add tests, or touch S3c, line colour, `Trip`, Journey types, persistence, or any presentation surface. It does not claim S3b or S3 is complete. Provider-to-canonical mapping, coordinate population, and representative-point selection stay in Phase 2 (DEC-048, §40).

## Rationale

A coordinate whose meaning is unstated is not a contract, so the reference system and unit are written down once, in the terms the anticipated providers already use. A dedicated value type is the only option that keeps the invariant in one place, keeps Domain framework-free, and gives `Hashable` and `Codable` a lawful, provider-neutral home; two raw doubles would make `Station` failable and spread the rule, and a platform type would import a framework and carry no invariant.

Making the coordinate required follows DEC-053's reasoning exactly: the canonical dataset guarantees the value, the Domain has no honest way to say "unknown", and a `nil` at runtime would be indistinguishable from a Phase 2 import defect. Deciding it now, while nothing is persisted and nothing calls `Station.init`, is the cheapest moment there will ever be.

## Revisit Triggers

- Launch provider data cannot supply a valid representative coordinate for every canonical Station.
- The product must represent a legitimate coordinate-unknown canonical Station.
- A future data source requires a different reference system.
- Altitude or horizontal accuracy becomes a real domain requirement.
- `Codable` or persistence migration requirements change after production data exists (Phase 6).
- A future use case requires distinguishing original and derived coordinates in Domain rather than in mapping data.

---

# DEC-057 — RailwayLine Topology Uses Undirected Canonical Station Adjacency

**Status:** Accepted\
**Date:** 2026-09-21\
**Related:** DEC-004, DEC-009, DEC-010, DEC-011, DEC-021, DEC-047, DEC-048, DEC-051, DEC-053, DEC-055, DEC-056; `RULES.md` Rule 8, Rule 9, Rule 16, Rule 39, Rule 45, Rule 53; `ARCHITECTURE.md` §5.2, §5.2.1, §5.3, §13, §40, §41

## Context

DEC-055 D4 gated railway-line topology behind its own contract (slice S3c) and asked it to settle "canonical **ordered** line topology": representation, minimum station count, duplicate-`StationID` policy, circular lines, branches, the Marunouchi main line and branch, the distinction from a `Trip`'s stop sequence, and consistency with `Station.lineIDs`. The wording inherited the original §5.2 `stationSequence` — a single `[StationID]` — which DEC-055 retired as unspecified but did not replace.

A read-only S3c audit then verified the launch network's actual shapes rather than assuming them. Current retained repository evidence and verified provider data identify the **Marunouchi** and **Oedo** lines as the launch-scope non-linear topology cases that require branch and loop-plus-tail support:

- **Oedo** (Toei static GTFS, analysed offline from the official credential-free public distribution): a connected loop-plus-tail graph in which the canonical junction station participates in **three** adjacencies and every other station in one or two; the dominant real service pattern traverses the junction **twice** in one trip. The provider publishes one route and one stop row for the junction.
- **Marunouchi** (`PROVIDER_FEASIBILITY_AUDIT.md` §6.2.4): a main path and a three-station branch sharing one junction. The static GTFS models it as **one** route whose branch trips run through to main-line termini; `odpt:Railway` models it as **two** records with no parent, branch, or connection field; DEC-047 treats it as **one** product service, "Marunouchi Line (incl. branch)". Providers therefore disagree with each other, and neither publishes adjacency, closure, or junction metadata.

Every other launch line is a simple path. A single global `[StationID]` cannot represent either non-linear case truthfully: it cannot hold a branch at all, and it can hold a loop only by repeating the junction — which turns array position into a de-facto direction and forces a duplicate-`StationID` rule the graph does not need. A representation built from ordered paths would have had to invent three policies (closure, orientation, path ordering) that no document supports. What the line actually owns, once direction and traversal are correctly left to `Trip` (DEC-055), is only **which stations are directly adjacent on it**.

## Decision

This Decision **locks the S3c contract**. It claims **no** implementation: `StationAdjacency` and `RailwayLineTopology` do not yet exist, `RailwayLine` does not yet carry a topology, and no canonical topology data has been populated.

### D1 — Canonical topology is undirected adjacency

DEC-055's unresolved phrase "canonical ordered line topology" is **narrowed** to **canonical undirected adjacent-station topology**. A `RailwayLine` topology describes which canonical stations are directly adjacent on that line — and nothing else. It does **not** define travel direction, ascending or descending order, display order, station numbering, provider `stationOrder`, one actual train traversal, express/local stopping behaviour, terminal presentation, or route-search results.

A single global `[StationID]` is **rejected**: it cannot truthfully represent both branches and loop-plus-tail structures without leaking direction or inventing repeat rules. **No parallel `stationSequence` property** is retained on `RailwayLine`.

### D2 — `StationAdjacency`

```swift
nonisolated struct StationAdjacency: Hashable, Codable, Sendable {
    let stationIDs: Set<StationID>

    init?(_ first: StationID, _ second: StationID)
}
```

1. One **unordered** adjacency between exactly **two distinct** canonical stations on the same line.
2. Input order has no meaning: `(a, b)` and `(b, a)` are equal and hash identically.
3. `stationIDs` contains exactly two distinct values; a self-adjacency `(a, a)` is **invalid**.
4. Construction is **failable** and never traps (DEC-051 rule 11 pattern).
5. The value has **no identity or identifier** of its own; equality and hashing use the complete value.
6. It stores **no** direction, distance, duration, track, platform, operator, line, provider, or transfer metadata.
7. The name is `StationAdjacency`, **not** `StationConnection`: "connection" could later be confused with a transfer or interchange relationship, whereas "adjacency" names the narrow same-line structural relationship.

Keyed `Codable` shape: `{ "stationIDs": [<StationID>, <StationID>] }`. Collection element order is not a contract. Decoding must enforce exactly two distinct identifiers: a zero-, one-, duplicate-, or more-than-two-element value fails with **`DecodingError.dataCorrupted`**. Missing keys and wrong types retain their normal `Codable` errors.

### D3 — `RailwayLineTopology`

```swift
nonisolated struct RailwayLineTopology: Hashable, Codable, Sendable {
    let adjacencies: Set<StationAdjacency>

    init?(adjacencies: Set<StationAdjacency>)

    var stationIDs: Set<StationID> { get }
}
```

1. The topology is an **undirected simple graph**.
2. `adjacencies` is the stored canonical state.
3. `stationIDs` is **derived** as the union of all adjacency station IDs; it is **not stored and not encoded**.
4. Adjacency insertion order and encoded `Set` element order are not contracts.
5. Equality and hashing use the complete adjacency set; the value has **no** canonical identifier.

Keyed `Codable` shape: `{ "adjacencies": [...] }`.

The type adds **no** paths, segments, branch identifiers, path identifiers, closure flags, direction, terminals, station order, transfer edges, weights, distance, duration, or display metadata.

### D4 — Topology invariants

A `RailwayLineTopology` is valid only when:

1. its adjacency set is **non-empty**;
2. every adjacency already contains exactly two distinct stations (D2);
3. the graph formed by all adjacencies is **connected**.

| Case | Outcome |
|---|---|
| empty adjacency set | invalid |
| single-station topology | invalid (no adjacency can express it) |
| disconnected components | invalid |
| orphan station | impossible — membership is derived from adjacency endpoints |
| self-adjacency | rejected by `StationAdjacency` |
| duplicate undirected adjacency | structurally collapsed by `Set` |
| cycle | **valid** |
| arbitrary station degree | **valid** |
| branch (degree ≥ 3 junction) | **valid** |
| loop plus tail | **valid** |
| more than one graph path between two stations | **valid** |
| degree limit, maximum size, planarity, Tokyo-specific shape, launch-line special case | **none exists** |

A valid topology therefore contains at least two unique stations. Construction is failable and never traps. **Decoding enforces the same non-empty and connectedness rules** as direct construction; an invalid decoded topology fails with `DecodingError.dataCorrupted`. A decoded list that repeats the same valid adjacency may collapse to one `Set` member — encoded ordering and duplicate input multiplicity are not semantic contracts — and the resulting unique graph must still satisfy every invariant. Connectedness validation is **internal**, not a public route-search API.

### D5 — `RailwayLine` owns required topology

```swift
nonisolated struct RailwayLine: Codable, Sendable {
    let id: LineID
    let operatorID: OperatorID
    let name: LocalizedRailName
    let topology: RailwayLineTopology

    init(id: LineID, operatorID: OperatorID, name: LocalizedRailName, topology: RailwayLineTopology)
}
```

1. `topology` is **required and never optional**.
2. `RailwayLine` construction remains **non-failable**: it receives an already-valid topology and repeats no validation.
3. **`LineID` remains the sole identity** (DEC-055 D3): topology participates in neither equality nor hashing; correcting a topology does not create a new line; `Codable` and actor-transfer tests must compare topology **explicitly**, because ID-only equality cannot prove topology preservation.
4. The keyed shape becomes exactly `{ id, operatorID, name, topology }`.
5. No actual topology data is added during Phase 1.

### D6 — Marunouchi identity

The Tokyo Metro Marunouchi main line and branch form **one canonical `RailwayLine`** with **one canonical `LineID`**. The branch is represented through the topology's degree-three adjacency structure at the canonical junction station.

Not created: a second canonical `LineID` solely because a provider publishes a separate `MarunouchiBranch` railway record; a branch ID; a segment ID; an `Mb` Domain identity; a transfer relation between main and branch (Rule 16); main-versus-branch metadata on `RailwayLineTopology`.

Phase 2 mapping may map **multiple provider railway identifiers** — including the provider's Marunouchi branch identifier — to the same canonical `LineID` while retaining provider provenance (§40). The mapping layer must preserve enough provenance for later provider-specific status or realtime scoping (Phase 4); that provenance **never enters** the Phase 1 `RailwayLine` value.

### D7 — Cycles, branches, and loop-plus-tail shapes

Topology represents structure through adjacency only.

- **Cycle:** closure exists because the final adjacency closes the graph; no station is repeated in any sequence; no first/last convention, closure flag, or self-edge exists.
- **Branch:** a junction naturally has degree three or greater; no explicit branch marker is required.
- **Loop plus tail:** the junction participates in both the loop and the tail adjacencies; it is stored no more than once per adjacency it belongs to.

The model supports these structures generically and contains **no special case** named Marunouchi, Oedo, M, Mb, or E.

### D8 — Evidence wording versus code strictness

Current retained repository evidence and verified provider data identify the Marunouchi and Oedo lines as the launch-scope non-linear topology cases that require branch and loop-plus-tail support. This is an evidence statement, **not** an invariant that exactly two non-linear lines can ever exist, and it does not weaken the code contract: the value remains strictly validated and generically supports any connected linear graph, any connected branch graph, any connected cycle, any connected loop-plus-tail graph, and any other connected undirected simple station-adjacency graph. No "known launch shapes" enumeration exists.

### D9 — `Station.lineIDs` relationship

DEC-055 D2 is preserved unchanged: `Station.lineIDs` remains unordered canonical line membership; `RailwayLineTopology.stationIDs` is derived from adjacency; the two intentionally provide inverse dataset relationships; an isolated `Station` or `RailwayLine` value cannot validate the other; agreement is checked by Phase 2 importer/dataset validation. No S3a API changes, and topology holds `StationID` values only — never `Station` references or values.

### D10 — `Trip` ownership

`Trip` owns direction, the actual ordered stop sequence, one service traversal, repeated station visits, express/local skip patterns, and provider direction mapping (DEC-055; `ARCHITECTURE.md` §5.3).

- `Trip.stopSequence` **must be capable of representing repeated `StationID`s**: verified Oedo service patterns visit the canonical junction more than once in one trip.
- Consecutive `Trip` stops are **not** required to be direct topology adjacencies: an express or limited-stop service skips intermediate topological stations.
- `RailwayLine` topology **never** calculates remaining stops; remaining-stop calculations use the selected Trip/Journey stop sequence (DEC-011, `FEATURES.md` §4.6).
- The existing tension between the singular `Trip.lineID` (§5.3) and through service across lines (DEC-009, §13) is **not** resolved here. It is recorded as a required **Trip-slice** decision, not as topology state.

### D11 — Route-search boundary

S3c implements no path search. Topology may be a future input to local routing, but Phase 3 owns route-search provider integration (DEC-004). Not added: pathfinding, neighbours lookup, shortest paths, weights, transfer edges, route candidates, route-search protocols, or any graph algorithm beyond internal connectedness validation.

### D12 — Derived APIs

The only derived API locked for S3c is `var stationIDs: Set<StationID> { get }`, justified by topology membership and Phase 2 dataset validation. No speculative API is added for neighbours, terminal detection, branch-point detection, cycle detection, path search, station count, `contains`, or display ordering; each may be added later when an actual consumer requires it.

## Consequences

- `ARCHITECTURE.md` §5.2 shows `topology: RailwayLineTopology` as a settled required property, a new §5.2.1 defines the two values, §5.3 notes the Trip repeat/skip facts and the open through-service ownership question, and §40 records the one-`LineID` Marunouchi mapping with provider-alias provenance.
- `ROADMAP.md` Phase 1 Slice S3 records S3c as **contract-locked, implementation pending**; S3 remains incomplete until S3c is implemented and independently audited.
- S3c implementation is two small commits with zero production call sites to break: the two values with their tests, then `RailwayLine.topology` with the existing line tests updated (every construction site, the round-trip and encoded-key tests, malformed nested topology, and the actor-transfer check).
- The Phase 2 importer gains a structural target: each canonical line's adjacency graph, built from provider stop sequences, must be non-empty and connected, and its derived membership must agree with every `Station.lineIDs`.
- The Trip slice inherits two recorded requirements: repeated stops in `Trip.stopSequence`, and a decision on line ownership under through service.
- The custom `Decodable` initialisers will each add an instance of the repository's existing `ConformanceIsolation` warning pattern; that concern is tracked once, repository-wide, in the `ROADMAP.md` Parking Lot, and is not an S3c matter.

## Scope statement

This is a **domain value contract and slice-boundary decision**. It implements nothing, adds no data, defines no provider syntax, introduces no canonical identifier (DEC-021's list is unchanged), and does not implement `StationAdjacency`, `RailwayLineTopology`, `RailwayLine.topology`, `Trip`, `ServiceType`, route search, transfer topology, line colour, persistence, or any presentation surface. It does not claim S3c or S3 is complete. Provider-to-canonical mapping, topology population, and the Marunouchi alias mapping stay in Phase 2 (DEC-048, §40).

## Rationale

The only structural fact a line owns independently of any train is adjacency. Direction, order, and repetition are properties of a traversal, and DEC-055 already gave those to `Trip`; leaving them there, and modelling the line as an undirected simple graph, is what lets one small value represent a path, a branch, a loop, and a loop with a tail without a single special case. Requiring connectedness and non-emptiness turns "a line" into a checkable statement rather than a convention, at a cost that is trivial at any realistic size.

One `LineID` for Marunouchi follows from Rule 9 and DEC-047: canonical identity is TSUGINO's product truth, not a provider's record split, and passengers on a branch train reach main-line termini without transferring (Rule 16). Keeping the branch as provider provenance in mapping data preserves everything Phase 4 needs for status scoping without letting a provider identifier become Domain structure.

## Revisit Triggers

- A launch or expansion line cannot be represented as one connected undirected simple station-adjacency graph.
- Direction becomes an intrinsic property of a canonical line rather than of a `Trip`.
- Disconnected components must legitimately share one `LineID`.
- Parallel station-to-station relationships require distinct Domain meaning.
- A consumer requires canonical display order.
- Branch or segment identity becomes a real product requirement.
- Persistence migration requirements arise after topology data is stored (Phase 6).
- The Trip slice resolves through-service ownership in a way that changes this boundary.

---

# DEC-058 — Tokyo Urban Rail Expansion Uses Production-Eligibility Gates and Prioritizes Airport Rail

**Status:** Accepted\
**Date:** 2026-09-21\
**Amended by:** DEC-059 (2026-09-21) — narrows the §5 Tier 1 "Present status" wording: no capability or tier is declared for Tier 1 candidates until every eligibility gate passes; the body below is unchanged\
**Amended by:** DEC-061 (2026-09-23) — the §7 and §9 brand-representation question assigned to the "Trip/ServiceType slice" is deferred from S4b to a later decision; airport service-brand guidance remains required for Airport Rail support and needs verified data and that later contract; the body below is unchanged\
**Extends:** DEC-047 (not superseded — its capability-aware guidance and launch matrix remain valid)\
**Related:** DEC-001, DEC-004, DEC-009, DEC-021, DEC-022, DEC-037, DEC-038, DEC-046, DEC-047, DEC-048, DEC-049, DEC-054, DEC-055, DEC-056, DEC-057; `RULES.md` Rule 9, Rule 10, Rule 16, Rule 40, Rule 48, Rule 50; `ARCHITECTURE.md` §5.2, §5.3, §10, §40, §50, §51; `ROADMAP.md` Phase 2, Phase 3, Phase 4, Post-Launch Track A; `PROVIDER_FEASIBILITY_AUDIT.md` §4, §6.7, §7, §9

## Context

DEC-047 fixed the initial release at "all 13 Tokyo subway lines" and, in the same record, placed Tokyo Sakura Tram and the Nippori-Toneri Liner in scope while noting they "are not part of the '13 subway lines' statement". Current-truth documents then repeated the "13 lines" phrase as if it were the whole accepted scope, which under-counts what DEC-047 actually accepted.

The product owner has since set a broader direction: TSUGINO should support every Tokyo urban railway that has sustainable production-use rights, sufficient trustworthy data, and a safe mapping into the canonical model; and Airport Rail — access to and from Narita and Haneda — is a tourist-critical P0 priority rather than an afterthought to subway commuting.

A read-only product/provider/licensing audit on 2026-09-21 (`PROVIDER_FEASIBILITY_AUDIT.md` §6.7) re-verified the public ODPT catalog and the official airport-access sources. Its findings constrain what can honestly be promised: every major private railway and JR East remain under the Challenge Limited License (production-blocked, DEC-037, audit §7); the four remaining Basic-License rail operators — TWR Rinkai Line, Metropolitan Intercity Railway (Tsukuba Express), Tama Monorail, Yurikamome — publish static schedule and at most GTFS-RT Alert; and **no** Narita or Haneda airport operator other than Toei's own Asakusa Line stations is production-eligible today: Keisei, Hokuso, Shibayama, and Tokyo Monorail are absent from the catalog, and Keikyu and JR East are Challenge-only. The audit also verified that every candidate network shape is representable by DEC-057's generic topology.

The decision therefore has to do three things at once: correct the baseline count, lock an ambition that is real, and refuse to let that ambition claim data it does not have.

## Decision

### 1. Present baseline — 15 canonical lines/services, not "13 lines"

1. The currently accepted scope already contains **all 13 Toei Subway and Tokyo Metro subway lines, Tokyo Sakura Tram, and the Nippori-Toneri Liner** (DEC-047 decisions 1, 2, 4).
2. The honest current canonical baseline is therefore **15 railway lines/services across Toei and Tokyo Metro**. "13 subway lines" remains correct as a count of subway lines and must not be used as the count of the whole accepted scope.
3. Tokyo Sakura Tram and the Nippori-Toneri Liner are **not new additions** made by this Decision; they were within DEC-047's accepted scope and were simply not counted in its "13 subway lines" statement.
4. Existing capability differences are unchanged: Tokyo Sakura Tram qualifies for realtime behaviour according to its verified feed capabilities; the Nippori-Toneri Liner provides scheduled guidance while trip-level realtime is not declared (DEC-046).
5. Product behaviour continues to derive from declared service/feed capabilities (DEC-022, DEC-054, Rule 10) — never from operator or line-name hardcoding.

Current-truth documents are corrected where "13 lines" was used as the entire scope; historical wording inside prior decision records is preserved.

### 2. Product direction

> **TSUGINO intends to support all production-eligible Tokyo urban railways through staged expansion.**

This is a product direction governed by the eligibility gate in §4. It is **not** a claim that any Tokyo operator beyond the baseline is currently licensed, mapped, implemented, or launch-ready, and it is **not** a Phase 1 implementation commitment (Rule 45, Rule 48).

### 3. Canonical geographic scope — complete lines, no clipping, no recursion

A railway line may enter the Tokyo urban-rail **candidate set** when either:

1. the complete canonical line contains at least one station located in Tokyo Metropolis; or
2. the line is part of the explicitly prioritized Narita or Haneda airport-access corridor.

Further:

- TSUGINO models **complete canonical railway lines**. A line is **never clipped** at the Tokyo prefectural boundary; a line extending into Kanagawa, Chiba, or Saitama remains one canonical `RailwayLine` (DEC-057), because clipping would manufacture a false terminus and a `LineID` no provider or passenger recognises.
- **Through-service participation does not recursively pull every connected line into scope.** A line enters the candidate set only on its own merits under rules 1–2; continuity across an unsupported partner segment is handled at the boundary (DEC-009, Rule 16).
- A route-search provider result (Phase 3, DEC-004) **may display an unsupported line or segment as untrackable presentation**; that display never makes it a supported canonical TSUGINO line.
- **Geographic inclusion alone never bypasses** the licensing and production-eligibility gate.

This Decision adds no line datasets, stations, mappings, or coordinates.

### 4. Production-eligibility gate

A candidate line becomes **supported** only when **all** applicable conditions hold:

1. a **production-use licence or operator authorisation** is verified from licence text or written authorisation (Rule 40, DEC-037);
2. the required provider payloads have been **repeatedly verified**, not inferred from catalog presence (audit §9.1);
3. attribution, update-notice, deletion, caching, and redistribution duties are **understood and implemented**;
4. `RailCapability` values are **declared at the correct service/feed scope** after the DEC-046 evidence gates (DEC-054);
5. **deterministic canonical mapping** to TSUGINO identifiers exists (Phase 2, DEC-048, §40).

Recorded consequences: **Challenge-only / Challenge Limited access does not satisfy condition 1**; catalog presence alone establishes nothing; missing, ambiguous, or non-production rights keep a candidate gated; and a failed gate never justifies invented, stale, or manually guessed operational data (DEC-038, Rule 50).

### 5. Expansion tiers (classification, not delivery status)

| Tier | Content | Present status |
|---|---|---|
| **Tier 0 — accepted current baseline** | 13 Toei/Tokyo Metro subway lines, Tokyo Sakura Tram, Nippori-Toneri Liner — **15 canonical lines/services** | accepted in scope (DEC-047); tiers per verified capability |
| **Tier 1 — next production-eligible expansion candidates** | TWR Rinkai Line; Metropolitan Intercity Railway Tsukuba Express; Tama Monorail; Yurikamome | **required candidates, not yet supported**: Basic License verified as catalog label; payloads unverified. Rinkai, Tsukuba Express, and Tama Monorail currently appear compatible with `staticSchedule` plus alert-class capabilities; Yurikamome with static scheduled guidance — all **subject to payload verification**. No realtime tracking is promised for any of them |
| **Tier 2 — Airport Rail, P0 product priority, gated** | Narita: Keisei Main Line and Narita Sky Access corridor (with Hokuso and Shibayama partner segments), JR East airport access. Haneda: Keikyu Airport Line corridor, Tokyo Monorail | **P0 priority; presently blocked by data rights** — see §6 |
| **Tier 3 — broader Tokyo rail expansion** | JR East urban lines; Tokyu, Keio, Odakyu, Seibu, Tobu, Sotetsu; through-service partners (Saitama Rapid, Toyo Rapid, Minatomirai) | future candidates under the same gate; Challenge-only operators remain production-blocked until valid production rights exist |

Promotion from any tier into supported scope happens **only** when the §4 gate passes and the data-source registry row reaches `production-eligible` (audit §9.1). Tier 1 candidates must not be described as implemented or as accepted production support.

### 6. Airport Rail — P0 priority, gated, not a current delivery promise

Airport Rail is a **P0 product priority**: overseas visitors need dependable, honest guidance to and from Narita and Haneda on their first and last journeys, on unfamiliar lines with brand-heavy service names, terminal choices, and reserved-seat products.

**P0 means "resolve and enable as early as legally and technically possible." It does not mean "currently production-supported" or "guaranteed for the first release."**

Current blockers (verified 2026-09-21, audit §6.7):

- **Narita:** Keisei, Hokuso, and Shibayama production data rights are not established by the audited catalog evidence (no organisation or dataset present); JR East is Challenge-only and therefore production-blocked.
- **Haneda:** Keikyu is Challenge-only and therefore production-blocked; Tokyo Monorail production data rights are not established by the audited catalog evidence.
- The **Toei Asakusa Line** is supported independently under Toei's CC BY 4.0 data, but that grants **no** support or rights for partner-operated through-service segments beyond Toei's own stations.

Airport Rail moves into supported scope **only** after operator-direct rights, or another verified production-authorised source, satisfy the §4 gate. Airport Rail is **neither cancelled, optional, nor low priority — and it is not currently deliverable.** Both halves of that sentence are binding.

### 7. Airport service taxonomy — brands are not lines

Modelling boundaries recorded now; types **not** introduced here:

- `RailwayLine` represents canonical infrastructure/service lines (DEC-057).
- **N'EX / Narita Express, Skyliner, Access Express, named Keikyu airport services, and Tokyo Monorail rapid/express/local labels are service families, service patterns, or display brands — not automatically distinct `LineID` values.** A brand is never forced into `RailwayLine` identity merely to satisfy the product priority (Rule 9, DEC-021).
- Candidate infrastructure lines — Keisei Main Line, Narita Sky Access, Keikyu Airport Line, Tokyo Monorail — **may** become canonical `RailwayLine` values if their later data and identity audits approve them, including the canonical-boundary question for multi-owner infrastructure.
- The exact representation of service family or brand, limited-express classification, reserved-seat requirements, multi-line through journeys, tourist-facing display labels, and unsupported route segments belongs to the **later Trip/ServiceType contract audit** (with the open singular `Trip.lineID` question recorded in DEC-057 D10).

### 8. Relationship to S3c and DEC-057

- **DEC-057 remains valid and unchanged.** Its generic connected undirected simple topology supports the current network and every plausible future Tokyo rail shape examined (paths, branches, the Yamanote cycle, loop-plus-tail, multi-branch private networks).
- The scope expansion **requires no operator-specific topology case** and gives no reason to weaken `StationAdjacency` or `RailwayLineTopology`.
- Airport express skip-stops, brands, and through services are Trip concerns, not topology.
- S3c implementation may proceed after this document lock and its independent review. **This Decision does not claim that S3c has been implemented.**

### 9. Phase ownership

- **Phase 1:** provider-neutral canonical domain contracts; generic topology values; capability vocabulary and derivation; **no real provider datasets**.
- **Phase 2:** actual operator/line/station data population; provider identifier mappings (including multi-provider aliases such as the Marunouchi branch record, DEC-057 D6); representative coordinate selection and provenance in mapping data (DEC-056); candidate-line payload validation and canonical mapping; **promotion of lines whose production gates pass**.
- **Phase 3 and later provider phases:** route-search integration with unsupported-segment presentation and brand/reservation fields (DEC-004); realtime/scheduled provider adapters (GTFS-RT Alert adapters for Tier 1 operators share the Tokyo Metro shape); operational behaviour selected from declared capabilities.
- **Later Trip/ServiceType slice:** resolves the airport-service and through-service representation questions in §7, including the singular `Trip.lineID` concern.

None of this implementation is pulled into the current task.

### 10. Rights and evidence follow-up

Durable actions are recorded in `ROADMAP.md` (Post-Launch Track A) and `PROVIDER_FEASIBILITY_AUDIT.md` (§13 A9): obtain or verify production-use rights and production-capable data sources from **Keisei, Keikyu, Tokyo Monorail, JR East, Hokuso, and Shibayama** (and any further Narita/Haneda partner discovered). Blocked Airport Rail providers are re-checked on a **periodic (at least quarterly) basis** against the public catalog and licence texts. **No outreach has occurred**; this Decision records the need, not a contact, application, or accepted licence.

## Consequences

- `PRODUCT.md` §6 and §19 state the 15-line baseline, the expansion direction, the eligibility gate, the tiers, and Airport Rail's P0-but-gated status; §23 no longer lists Tokyo private railways and JR East as vague "long-term" items but points to the tiered programme.
- `FEATURES.md` §10.3 states that capability availability extends to every future operator under the same gate and that route results may show untrackable unsupported segments.
- `ARCHITECTURE.md` §40 and §50 note multi-provider aliasing and that adding an operator also requires the §4 gate.
- `ROADMAP.md` Phase 2 lists the Tier 1 candidates as gated data work; Post-Launch Track A becomes the tiered expansion programme with the rights-outreach action and re-check cadence.
- `PROVIDER_FEASIBILITY_AUDIT.md` gains a dated §6.7 catalog/scope re-check, a Shibayama row in §4.2, and action A9; earlier evidence is untouched.
- Marketing, App Store, and in-app copy must not state or imply airport coverage until an airport line passes the gate (DEC-038, Rule 50).

## Scope statement

This is a **product-scope and eligibility-policy decision**. It adds no dataset, mapping, coordinate, topology record, provider adapter, Domain type, or canonical identifier; it does not implement S3c, `Trip`, `ServiceType`, route search, or any presentation surface; it contacts no operator and accepts no licence. It extends DEC-047 and leaves DEC-057 unchanged.

## Rationale

Ambition and honesty are reconciled by putting the gate in front of the map: the direction can be as broad as the owner wants precisely because nothing ships until rights, payloads, compliance, capabilities, and mapping are each verified. Counting the baseline correctly (15, not 13) removes a self-inflicted understatement. Declaring Airport Rail P0 while stating plainly that it is blocked keeps the priority visible to planning without letting product copy overreach — the failure DEC-038 and Rule 50 exist to prevent. Keeping brands out of `LineID` protects DEC-057's topology and DEC-021's identity rule from the most likely way the airport priority could distort the Domain.

## Revisit Triggers

- An airport operator (Keisei, Keikyu, Tokyo Monorail, JR East, Hokuso, Shibayama) publishes production-usable data or grants a production licence.
- The ODPT Challenge Limited License terms, scope, or end date change, or an operator moves to the Basic License / CC BY.
- The ODPT catalog gains Trip Update / Vehicle Position resources for a Basic-License operator.
- Tier 1 payload verification fails or reveals capabilities different from the catalog label.
- A candidate line cannot be represented as one connected undirected simple graph (DEC-057 revisit).
- The selected route-search provider cannot present airport brands, reservation requirements, or unsupported segments.
- The Trip/ServiceType slice resolves multi-line and brand representation in a way that changes these boundaries.

---

# DEC-059 — Tier 1 Rail Candidates Have No Declared Capabilities Until Eligibility Gates Pass

**Status:** Accepted\
**Date:** 2026-09-21\
**Amends:** DEC-058 §5, Tier 1 "Present status" language only — narrowly; DEC-058 is otherwise unchanged and remains Accepted\
**Related:** DEC-022, DEC-037, DEC-046, DEC-054, DEC-058; `RULES.md` Rule 10, Rule 40; `ARCHITECTURE.md` §51; `PROVIDER_FEASIBILITY_AUDIT.md` §6.7, §9.1

## Context

An independent adversarial review of the DEC-058 documentation lock found that payload-unverified Tier 1 candidates were described as already occupying a scheduled-guidance tier. The three derivative sentences in `PRODUCT.md`, `ROADMAP.md`, and `PROVIDER_FEASIBILITY_AUDIT.md` were corrected in commit `17bd32d`. The focused re-review then found the same pattern in the controlling record itself: DEC-058 §5's Tier 1 row says the first three candidates "currently appear compatible with `staticSchedule` plus alert-class capabilities" and Yurikamome "with static scheduled guidance". Naming atomic `RailCapability` cases for an operator whose payloads have never been verified translates catalog evidence into a capability declaration — and, for Yurikamome, into a derived tier — before the gate DEC-058 §4 itself requires.

DEC-054 makes the tier a pure function of the **declared** capability set, and declaration is permitted only after the DEC-046 evidence gates pass. DEC-058 §4 adds the production-eligibility gate in front of that. The sequence cannot be shortcut by a status column.

Accepted decision bodies are historical (DEC-036, Rule 44). The offending row is therefore preserved as written, and this record controls its interpretation.

## Decision

1. This Decision **narrowly amends** the Tier 1 "Present status" language of DEC-058 §5. Nothing else in DEC-058 is changed.
2. **Tier 1 still contains** TWR Rinkai Line, Metropolitan Intercity Railway Tsukuba Express, Tama Monorail, and Yurikamome.
3. They are **required expansion candidates**, not supported production lines. They are not demoted, removed, or made optional by this Decision.
4. **Catalog licence labels identify candidates; they do not declare operational capabilities.** A Basic License label establishes eligibility to *begin* verification, nothing more.
5. Their **payloads remain unverified** (`PENDING_PAYLOAD_VERIFICATION`, audit DS-08).
6. **No service/feed-scoped `RailCapability` is currently declared** for any Tier 1 candidate — not `staticSchedule`, not `alerts`, not `serviceStatus`, not any other case.
7. **No `RailCapabilityTier` is currently derived** for any Tier 1 candidate.
8. **Scheduled guidance may be considered only after** payload verification, every remaining DEC-058 §4 eligibility condition, and service/feed-scoped capability declaration have all passed.
9. **Alert-class capability** for Rinkai Line, Tsukuba Express, and Tama Monorail may likewise be considered only after verification and declaration; the catalog's Alert resource is evidence to verify, not a declaration.
10. **No realtime capability is promised** for any Tier 1 candidate.
11. The **mandatory sequence** is: candidate identification → complete eligibility gate → verified service/feed-scoped capability declaration → tier derivation from the declared set → capability-dependent product behaviour. It is not weakened, bypassed, or reordered.
12. **Where DEC-058 §5's historical wording appears to assign capabilities or scheduled guidance before those steps, DEC-059 controls current interpretation.**

## Consequences

- The corrected sentences in `PRODUCT.md` §6, `ROADMAP.md` Post-Launch Track A, and `PROVIDER_FEASIBILITY_AUDIT.md` §6.7 (commit `17bd32d`) are now consistent with the controlling decision text; they need no further change.
- The data-source registry (`PROVIDER_FEASIBILITY_AUDIT.md` §9) records a capability for a Tier 1 operator only when the DS-08 row carries dated, repeated payload evidence and a service/feed declaration.
- Any document, fixture, configuration, or test that names a Tier 1 capability before those steps is a contradiction to be corrected, not a forecast.

## Scope statement

This is an **interpretive amendment**. It changes no tier membership, priority, baseline count (15 canonical lines/services), Airport Rail status (P0, gated), phase boundary, or Domain contract (DEC-057 unchanged); it adds no dataset, mapping, capability declaration, or code; it contacts no operator; it does not implement S3c.

## Rationale

The tier vocabulary exists so that product behaviour falls out of verified evidence rather than out of a table of names (DEC-054 rationale). A status column that pre-names capabilities is a table of names by another route. Correcting the derivative sentences while leaving the controlling record untouched would have left the contradiction where it matters most; amending by a new record keeps history intact (Rule 44) and makes the current interpretation unambiguous.

## Revisit Triggers

- DS-08 payload verification completes for any Tier 1 candidate and a service/feed capability set is declared — at which point the tier is derived per DEC-054 and the registry row updated.
- DEC-058 §4 or §5 is superseded by a later scope decision.
- DEC-054's tier derivation changes.

---

# DEC-060 — Trip Uses Ordered Stop Traversal with Explicit Railway-Line Segments

**Status:** Accepted\
**Date:** 2026-09-22\
**Amended by:** DEC-061 (2026-09-23) — settles the §H S4b deferral: `Trip` gains `serviceTypeSegments` and `ServiceTypeID` is introduced; every §A–§G invariant and the body below are unchanged\
**Related:** DEC-009, DEC-010, DEC-011, DEC-021, DEC-038, DEC-046, DEC-047, DEC-048, DEC-050, DEC-051, DEC-053, DEC-055, DEC-056, DEC-057, DEC-058, DEC-059; `RULES.md` Rule 8, Rule 9, Rule 10, Rule 16, Rule 39, Rule 45; `ARCHITECTURE.md` §5.2.1, §5.3, §13, §39, §40; `ROADMAP.md` Phase 1 Slice S4

## Context

`ROADMAP.md` Slice S4 defines the next open Phase 1 work — the canonical structural representation of a `Trip` — and lists eight questions its contract must answer. `ARCHITECTURE.md` §5.3 has carried an unresolved sketch since Phase 0: `Trip { id, providerReferences, lineID, serviceType, direction, destination, stopSequence, scheduledTimes }`. Three of those entries are known problems rather than decisions: `providerReferences` would put provider identity inside a canonical Domain model (Rule 9, DEC-021); the **singular** `lineID` cannot describe a service that runs through onto another line, which DEC-009 and Rule 16 require to stay one continuous boarding experience rather than a transfer; and `scheduledTimes`, `direction`, `destination`, and `serviceType` were never given contracts at all. DEC-057 D10 recorded the `lineID` tension explicitly as a Trip-slice decision.

Two facts are already accepted and constrain any answer (DEC-057 D10, §5.3): a Trip's ordered traversal **must** admit repeated `StationID`s, because a real loop-plus-tail service visits its junction twice in one run; and consecutive Trip stops are **not** required to be adjacent in `RailwayLineTopology`, because express and limited-stop services skip intermediate topological stations. Topology adjacency and stop order are different concepts.

Phase 1 has no real railway data and will not get any (DEC-055, DEC-057, DEC-058): every invariant this Decision accepts must therefore be checkable from the value alone, with no `Station` or `RailwayLine` collection in hand.

## Decision gate — line association candidates

| Candidate | Locates the line change? | Through service as one Trip? | Unambiguous with repeated stations? | Duplicates stop data? | Locally validatable? | Works without Phase 2 data? | Verdict |
|---|---|---|---|---|---|---|---|
| **1. one `LineID`** | n/a | **no** — forces a fake transfer or a false line claim | yes | no | yes | yes | **Rejected** — known structural dead end (DEC-009, Rule 16) |
| **2. ordered `[LineID]`** | **no** — names the lines but not where each applies | partly | **no** — cannot say which visit belongs to which line | no | weak | yes | Rejected |
| **3. one ordered stop list + segments addressed by traversal position** | **yes** | **yes** | **yes** — positions are unique even when stations repeat | **no** — one canonical stop list | **yes** | **yes** | **Selected** |
| **4. segments each owning their own stop subsequence** | yes | yes | yes | **yes** — the boundary station is stored twice, or asymmetrically in one segment only; the whole traversal must be reconstructed by concatenation | yes | yes | Rejected — two sources of truth for the same stop |
| **5. no stored line, derived from datasets** | no | no | n/a | no | **no** | **no** — nothing derivable in Phase 1 | Rejected |
| **6. primary display line + segments** | yes | yes | yes | no | yes | yes | Rejected **for now** — adds a presentation choice with no Phase 1 consumer; may be added later without migration |

Candidate 3 is selected: it is the smallest representation that locates every line change, keeps one canonical stop list, and stays unambiguous in exactly the case that defeats station-keyed alternatives — a station visited more than once.

## Decision

This Decision **locks the S4 contract**. It claims **no** implementation: no `Trip`, `TripLineSegment`, or `ServiceType` exists, and no railway data is added.

### A. `Trip` identity and value semantics

1. `Trip` is a **domain entity** identified by `TripID` (DEC-021; `TripID` already exists).

   **What a Trip identifies.** A `Trip` identifies **one recurring canonical scheduled run definition** — not one dated physical train run, and not merely a structural stopping-pattern template. Implications:

   - two separately published departures are **different** Trips even when they share the same `stopSequence`, the same `lineSegments`, the same coverage, and the same future service class;
   - a Trip is therefore **never deduplicated by structural equality**;
   - a corrected stop sequence, segment description, or coverage for the **same logical scheduled run** keeps the **same `TripID`**; a provider refresh does not mint a new Trip merely because descriptive data changed;
   - deciding that two provider records denote the same logical run is **Phase 2 mapping and provenance** work; provider identifiers stay outside the canonical value, and **provider identity never defines canonical identity** — providers supply evidence, TSUGINO owns the `TripID` (Rule 9, DEC-021);
   - a **service calendar** determines the dates on which a recurring Trip operates; that calendar is **not** part of S4a;
   - a **particular dated execution** of a Trip is not this entity: date-specific operation, cancellation, delay, and live progress belong to the later schedule, realtime, and Journey contracts (DEC-011, DEC-050).

   No departure time, calendar, provider reference, or dated-run identifier is introduced by this Decision.
2. **Equality and hashing use `TripID` alone**, written explicitly as for `Operator`, `Station`, and `RailwayLine` (DEC-053, DEC-055 D3, DEC-057 D5) — valid precisely because the entity subject above is now defined. A corrected stop list, segment list, or coverage is the **same** Trip.
3. Every structural property — the stop traversal and the line segments — is **descriptive** and participates in neither equality nor hashing. `Codable` and actor-transfer tests must therefore compare them explicitly, because ID-only equality cannot prove they survived.
4. `Trip` is a `let`-only value type and is **immutable after successful construction**.
5. `Trip` carries **no provider references, no provider identifiers, and no provider codes** (Rule 9, DEC-021, DEC-020). The `providerReferences` entry in the §5.3 sketch is **rejected**; provider identity lives in the Phase 2 mapping layer (§40).

### B. Ordered stop traversal

1. `Trip` stores one ordered list of **passenger-visible stops**: `stopSequence: [StationID]`.
2. It contains **stops only**. A station the service passes without stopping is simply **absent**; that is how an express or limited-stop pattern is expressed, and it is why no topology adjacency is implied (§E).
3. **Minimum length is 2.** A service with fewer than two passenger stops carries no passenger anywhere.
4. **Adjacent duplicates are invalid**: `stopSequence[i] != stopSequence[i + 1]` for every `i`. The same station twice in a row describes no movement.
5. **Non-adjacent repeats are valid and required**: a station may appear any number of times at non-adjacent positions (DEC-057 D10). This is what makes a loop-plus-tail service representable.
6. An individual **visit is addressed by its index** in `stopSequence`, never by its `StationID`. Index is the only unambiguous address once a station repeats.
7. Traversal position is **derived from collection position**; no position identifier is stored, and no per-visit value type is introduced in this slice (nothing is attached to a visit yet — see §F).
8. Order **is** part of the stop list's value: two Trips with the same stations in different order have different traversal. Order is not part of *entity identity* (§A2).

### C. Explicit railway-line traversal

`Trip` stores `lineSegments: [TripLineSegment]`, where a segment is a provider-neutral value naming one canonical line and the contiguous span of the traversal it applies to:

```text
TripLineSegment
- lineID            (LineID)
- startIndex        (Int — index into Trip.stopSequence)
- endIndex          (Int — index into Trip.stopSequence)
```

The name is deliberately **not** "leg": a `JourneyLeg` is a passenger-facing portion of a planned journey that may involve a transfer, whereas a segment is a structural property of one continuous train run.

Invariants, all checkable from the `Trip` value alone:

1. `lineSegments` is **non-empty**.
2. Indices are **valid**: `0 <= startIndex < endIndex <= stopSequence.count - 1`. Ranges are **closed** — both endpoints are stops of that segment.
3. Every segment **spans at least one movement** (`endIndex > startIndex`); a zero-length segment names a line that carries the train nowhere.
4. Segments are stored **in traversal order**, and each one **joins the previous at a shared stop**: `segment[n].startIndex == segment[n - 1].endIndex`. The shared index is the **line-boundary station** — one stop, belonging to both segments as an endpoint.
5. **Full coverage, with exactly one shared endpoint per join.** `lineSegments.first.startIndex == 0` and `lineSegments.last.endIndex == stopSequence.count - 1`. **Consecutive closed segment ranges share exactly one endpoint. This shared boundary index is the only permitted overlap; all overlap beyond it and all gaps are invalid.** Overlap by two or more traversal indices, a gap between segments, a nested range, a duplicate range, and any order that does not progress through the traversal are each invalid — all of which rule 4 together with rules 2–3 already excludes, stated here explicitly so no implementation reads "no overlap" as forbidding the required boundary.
6. **Adjacent segments must not share a `lineID`.** Two consecutive segments on the same line are one segment; requiring the normalised form keeps a Trip's representation unique, so value comparison of the segment list is meaningful.
7. **Non-adjacent segments may repeat a `lineID`** — a service may leave a line and return to it.
8. A **one-line Trip** is exactly one segment covering `0...stopSequence.count - 1`. This is the ordinary case for the current 13-line launch scope and costs nothing.
9. A **multi-line through service** is two or more segments over **one** `stopSequence` — one `Trip`, no transfer, satisfying DEC-009 and Rule 16 structurally rather than by convention.

**Unsupported continuation.** Where a real service runs beyond the railway TSUGINO has modelled canonically, the represented traversal covers only the supported portion: **no `LineID` and no `StationID` is ever invented** for unmodelled infrastructure, and no segment is fabricated. Such a Trip is **not** silently presented as complete — the value states what it covers through `coverage` (§C2 below), so a partial representation is distinguishable from a service that genuinely ends there. Partial coverage is **not** a passenger transfer, and one physical through service is **never** split into several Trips merely to make each look complete.

### C2. `TripCoverage` — what the represented traversal actually covers

`Trip` stores `coverage: TripCoverage`, an immutable value stating independently whether the represented traversal reaches the real service's own endpoints:

```text
TripCoverage
- includesServiceOrigin       (Bool)
- includesServiceDestination  (Bool)
```

1. All **four** combinations are valid and meaningful:

   | `includesServiceOrigin` | `includesServiceDestination` | Meaning |
   |---|---|---|
   | true | true | the complete passenger service is represented |
   | true | false | representation starts at the real origin but ends before the real destination |
   | false | true | representation starts after the real origin but reaches the real destination |
   | false | false | only a supported middle portion of the service is represented |

2. `coverage` is **descriptive data**: it is excluded from `Trip` identity (§A2) exactly as the traversal and segments are.
3. `TripCoverage` is a value with **complete-value equality**, no identifier, and — having no invalid combination — **total construction**. `Trip` decoding must still validate the combined Trip invariants.
4. It records **only the minimum completeness claim actually known**. It identifies no missing line, station, operator, or brand, and **no count of unknown stops**: unknown data stays unknown, and this Decision defines no way to count it.
5. A different representation carrying exactly these two facts is acceptable; inventing missing stations, lines, or stop counts is not.

### D. Operator and service-brand separation

1. `RailwayLine.operatorID` identifies the operator relationship of the **canonical line** (DEC-055) and nothing more. It **must not** be treated as proof of which company physically operates a given Trip over that infrastructure.
2. `Trip` stores **no operator**, and no single operator identity may be inferred merely because its segments name several lines.
3. Service brands — N'EX, Skyliner, Access Express, named Keikyu airport services, Tokyo Monorail service labels — are **not** `LineID`s, **not** operators, and **not** a direction (DEC-057, DEC-058 §7).
4. Actual operator-of-service and service-family modelling remains **deferred**; nothing in current scope requires it now.
5. No claim is made that airport services in general traverse multiple `RailwayLine`s; whether any given service does is a per-service data question for Phase 2.

### E. `Trip` versus `RailwayLineTopology`

DEC-057 is preserved unchanged:

1. `RailwayLineTopology` describes **structural station adjacency**; `Trip.stopSequence` describes an **ordered passenger-visible traversal**. They are different concepts.
2. Consecutive Trip stops are **not required** to be adjacent in topology, because express and limited-stop services omit intermediate topological stations.
3. Non-adjacent repeated stations are permitted.
4. `Trip` construction performs **no** route search, pathfinding, or graph traversal of any kind.
5. Remaining-stop calculation comes from the selected Trip/Journey, **never** from a line's topology (DEC-011).
6. Checks that need populated collections — that every stop is a known `Station`, that each stop belongs to its segment's line, that a segment's `LineID` exists — are **dataset validation**, outside the isolated `Trip` initialiser (§G).

### F. Scheduled times — excluded from S4

1. Scheduled times are **not** part of the S4 Trip contract; the `scheduledTimes` entry of the §5.3 sketch is **not accepted** by this Decision.
2. Timetable semantics — service days, calendar exceptions, times past 24:00, time zones, provider schedule mapping, and interaction with the injected Clock (Rule 38) — require their own contract, which this slice does not attempt.
3. This is a **domain-contract deferral, not a product deferral**. Scheduled Journey Guidance (DEC-046, DEC-047) is unaffected; it is delivered once the timetable contract and its data exist.
4. Because nothing is yet attached to an individual stop, `[StationID]` suffices for the traversal (§B7). When scheduled times or per-stop data arrive, a typed per-stop value may replace the element type — a change to an unpersisted Phase 1 value with no production call sites (Rule 39).

### G. Direction, destination, and headsign

1. **No direction enum.** Inbound/outbound and ascending/descending do not survive the verified launch network: a loop-plus-tail line has no single terminal pair, and a branch line's "toward X" depends on the branch. Structural direction is given by **traversal order** — `stopSequence` runs from first stop to last.
2. **No stored destination, and no unconditional terminal claim.** `stopSequence.first` is the **first represented passenger stop** and `stopSequence.last` the **final represented passenger stop**. The first is the service's actual origin **only when** `coverage.includesServiceOrigin` is true; the last is the actual destination **only when** `coverage.includesServiceDestination` is true (§C2). A separate stored destination field would merely duplicate state that can drift and is not introduced. Consumers — including the later JourneyEngine and every presentation surface — **must consult coverage before** labelling a represented stop as the origin or terminal, or before claiming a remaining-stop count for the complete physical service (DEC-038, Rule 50). A **genuine short-turn** service that really ends where it is shown has `includesServiceDestination == true`; a **partial representation** ending at the same station has `includesServiceDestination == false`. The two states are therefore **not** identical, and nothing may treat them as such.
3. **Provider-native direction identifiers** (GTFS `direction_id`, ODPT ascending/descending) stay **Phase 2 mapping data** (Rule 9).
4. **Headsign is deferred.** A headsign is a passenger-facing, localized label that is *not* assumed to equal the final stop; its localization contract (DEC-041, DEC-042, DEC-053) and provider semantics are settled with the display work, not here.
5. Loop, loop-plus-tail, branch, and short-turn shapes are all covered by traversal order alone (§ shape proofs).

### H. `ServiceType` — deferred to its own decision; S4 subdivided

`ServiceType` is **not** defined or attached in this Decision, and `Trip` stores no service-type property yet.

Reasoning, against the criteria S4 requires:

- the **actual stopping pattern is already expressed** by `stopSequence`, so express and local Trips differ structurally without any label (`ROADMAP.md` Phase 1 tests "express/local differences");
- the v1 need is a **display and selection label** on a train candidate (`FEATURES.md` §3.1, `DESIGN.md` §14.2), which is presentation data with a localization contract, not a structural Trip invariant;
- provider coverage is incomplete and heterogeneous, and each operator names its own categories, so a **closed enum fixed today would be wrong at the first expansion** (DEC-058 Tier 1–3) while an **open provider string would import provider vocabulary into Domain** (Rule 9, Rule 10);
- brand, reserved-seat status, and airport-service identity must stay separate from stopping-pattern class (DEC-058 §7), and one enum cannot carry all four honestly.

Consequently **Slice S4 is subdivided**:

- **S4a — Trip structure:** everything in §A–§G. Implementable immediately; nothing in it depends on `ServiceType`.
- **S4b — service class:** a separate decision that settles whether a canonical service-class identity exists, its vocabulary shape, its relationship to brand and reserved-seat status, and whether `Trip` gains an optional reference to it. **Its decision identifier is not reserved here.**

S4 as a whole is **not** complete until S4b is disposed of — decided and implemented, or explicitly moved out of Phase 1 by an accepted decision. This mirrors the S3 completion rule (DEC-055 D4) and keeps the roadmap's "minimum relationship, if any, between Trip and ServiceType" honestly answered rather than silently dropped.

## Detailed invariants and their boundaries

| Invariant | Boundary |
|---|---|
| valid `TripID`, `StationID`, `LineID` | **already guaranteed** by the identifier types (DEC-051) |
| `stopSequence.count >= 2` | **S4a value construction** |
| no adjacent duplicate stop | **S4a value construction** |
| non-adjacent repeats permitted | **S4a** — a permission, not a check |
| `lineSegments` non-empty | **S4a value construction** |
| index bounds, `endIndex > startIndex` | **S4a value construction** |
| segments ordered and joined at a shared index | **S4a value construction** |
| full coverage; exactly one shared endpoint per join; no gap, no wider overlap, no nesting, no duplicate range | **S4a value construction** |
| adjacent segments differ in `lineID` (normalised form) | **S4a value construction** |
| `coverage` decodes through its own value contract; all four combinations valid | **S4a value construction** |
| coverage never relaxes a stop or segment rule — a partial Trip still needs ≥ 2 represented stops, valid segments, and no fabricated identifier | **S4a value construction** |
| every stop is a known canonical `Station` | **Phase 2 dataset validation** |
| every `lineID` names a known canonical `RailwayLine` | **Phase 2 dataset validation** |
| each stop belongs to its segment's line / topology membership | **Phase 2 dataset validation** |
| provider trip identity, direction codes, headsign text | **Phase 2 provider mapping** |
| schedule validity, service days, rollover | **later timetable contract** (§F) |
| current station, next station, remaining stops, progress | **Phase 5 JourneyEngine** (DEC-011, DEC-050) |

**Construction style** follows the established pattern and introduces **no new error architecture**: `TripLineSegment` and `Trip` use **failable initialisers that never trap** (DEC-051 rule 11), and decoding applies exactly the same rules, failing with `DecodingError.dataCorrupted` while missing keys and wrong types keep their natural `Codable` errors (DEC-053, DEC-056, DEC-057). `TripCoverage` has no invalid combination, so **its construction is total**; `Trip` decoding must nevertheless validate the combined Trip invariants, and no synthesized decoding path may bypass them. Arbitrary decoded integers — negative, out of bounds, or extreme — must be **validated before** being used as an index or range, so decoding is safe and non-trapping for any payload. All three values are `nonisolated`, `Hashable`, `Codable`, `Sendable`, and import-free; `TripLineSegment` and `TripCoverage` are values with **complete-value** equality and no identifier.

## Shape proofs

Generic examples only; `A…F` are synthetic stations and `L1`, `L2` synthetic lines. No real record appears.

| # | Shape | Representation | Status |
|---|---|---|---|
| 1 | simple linear local | stops `[A,B,C,D]`; segments `[(L1, 0, 3)]` | **fully representable** |
| 2 | express skipping stations | stops `[A,D]` (B, C simply absent); segments `[(L1, 0, 1)]` | **fully representable** — no topology adjacency required |
| 3 | circular service | stops `[A,B,C,A]`; segments `[(L1, 0, 3)]` | **fully representable** — closure by return to `A`, no self-edge, no flag |
| 4 | loop-plus-tail with a repeated station | stops `[J,A,B,J,T1,T2]`; segments `[(L1, 0, 5)]`; the two visits to `J` are indices 0 and 3 | **fully representable** — the case that decides index-based addressing |
| 5 | branch service | stops `[A,J,B1,B2]` on one `LineID` (a branch is a topology junction, DEC-057 D6) | **fully representable** |
| 6 | short-turn | stops `[A,B,C]` ending before the line's physical end | **fully representable** — a Trip asserts nothing about a line's extent |
| 7 | one-line Trip | one segment covering the whole traversal | **fully representable** |
| 8 | multi-line continuous through service | stops `[A,B,X,C,D]`; segments `[(L1, 0, 2), (L2, 2, 4)]` — one Trip, no transfer | **fully representable** |
| 9 | line-boundary station | index 2 (`X`) above: one stop, endpoint of both segments | **fully representable** |
| 10 | continuation beyond canonical coverage | real service `A→B→C`, only `A→B` modelled: stops `[A,B]`; segments `[(L1, 0, 1)]`; `coverage = (origin: true, destination: false)`. No `LineID` or `StationID` is fabricated for the `B→C` portion; `B` is **not** claimed as the actual destination, and no remaining-stop count for the full service is implied | **fully representable and honest** — distinguishable from shape 6, a genuine short-turn ending at `B` with `destination: true` |
| 11 | missing leading coverage | real service `A→B→C`, only `B→C` modelled: stops `[B,C]`; `coverage = (origin: false, destination: true)`; `B` is not claimed as the service origin | **fully representable and honest** |
| 12 | supported middle only | real service `A→B→C→D`, only `B→C` modelled: stops `[B,C]`; `coverage = (origin: false, destination: false)` | **fully representable and honest** |

Shapes 1–9 are complete-coverage cases (`origin: true, destination: true`); shapes 10–12 are the honest partial-coverage cases. All twelve are structurally representable now, and every one still awaits **Phase 2 data** before any real service can be constructed.

## Alternatives considered

Line association: the six candidates in the decision gate above; candidate 3 selected, 1/2/4/5 rejected for the recorded reasons, 6 deferred as a later additive choice. Stop element: a typed per-stop visit value was considered and deferred with `scheduledTimes` (§F4) — with nothing to attach, it would be a wrapper with no content. Segment boundaries keyed by `StationID` instead of index: rejected, because a repeated station makes the boundary ambiguous (shape 4). Half-open ranges: rejected, because the boundary station genuinely belongs to both segments, which closed ranges state directly. A `Trip`-level operator or brand: rejected (§D). A closed `ServiceType` enum: rejected now (§H).

## Consequences

- `ARCHITECTURE.md` §5.3 replaces the sketch with this contract: `providerReferences`, singular `lineID`, `scheduledTimes`, `direction`, `destination`, and `serviceType` leave the accepted shape, each with its disposition recorded, and `coverage` joins it.
- `ROADMAP.md` Slice S4 records the contract as accepted, keeps implementation unstarted, and records the S4a / S4b subdivision under the existing completion rule.
- S4a can be implemented from this record alone, with the same value-type pattern S1–S3 established and zero production call sites to break.
- Phase 2's importer gains explicit structural targets: stop lists that may repeat stations, and segment lists that must be joined, covering, and normalised.
- A later per-stop value, a display line, or a service class can each be added without invalidating what S4a stores.

## Phase ownership

**Phase 1 (S4a):** the `Trip` and `TripLineSegment` value contracts above. **S4b:** service class. **Phase 2:** real station, line, topology, service, and timetable datasets; provider identifiers, mappings, aliases, provenance; payload validation; every cross-model check needing populated collections. **Phase 3+:** route search, pathfinding, provider integration. **Phase 4:** realtime adapters, capability attachment. **Phase 5:** `JourneyEngine` behaviour, live progression, current/next station, remaining stops. **Later presentation work:** localized headsign and service-label rendering, UI, Live Activities.

## Explicit non-goals

This Decision adds no real Tokyo or Airport Rail record; no provider identifier, mapping, or alias; no schedule or timetable computation; no provider networking; no realtime behaviour; no route search or pathfinding; no persistence; no journey progression; no UI or Live Activity; no new canonical identifier (DEC-021's list is unchanged); and no `ServiceType`. It does not mark S4 or Phase 1 complete, and it implements nothing.

## Implementation sequence

1. `TripLineSegment` and `TripCoverage` with their invariants and tests.
2. `Trip` with `stopSequence`, `lineSegments`, and `coverage`, their cross-field invariants, and tests covering all twelve shapes above.
3. Independent review, then the S4a completion record.

S4a tests must cover, at minimum: the recurring-run `TripID` semantics at the domain-contract level; ID-only equality and hashing; all four coverage states; the genuine short-turn versus incomplete-destination distinction; every segment boundary invariant (including one shared endpoint, rejected wider overlap, gap, nesting, duplicate range, misordering, and adjacent same-line segments); repeated station visits; multi-line through service; and `Codable` rejection of every invalid structure.

S4b follows as its own decision and implementation.

## Revisit Triggers

- A verified service cannot be represented as one ordered stop list plus joined, covering line segments.
- Per-stop data (scheduled times, platform, per-stop headsign) is accepted, changing the traversal element type.
- A consumer genuinely needs a primary display line, a stored destination, or a direction value on `Trip`.
- S4b settles service class in a way that changes `Trip`'s shape.
- Through-service ownership changes in a way that affects segment semantics.
- Persistence design (Phase 6) requires a different encoded representation.

---

# DEC-061 — Service Type Is an Operator-Scoped Canonical Value Attached to Trip by Gap-Permitting Segments

**Status:** Accepted\
**Date:** 2026-09-23\
**Amends:** DEC-021 (identifier list), DEC-058 (§7/§9 brand ownership), DEC-060 (§H) — headers only; their bodies are unchanged\
**Related:** DEC-009, DEC-011, DEC-021, DEC-038, DEC-041, DEC-042, DEC-051, DEC-053, DEC-058, DEC-060; `RULES.md` Rule 9, Rule 10, Rule 11, Rule 16, Rule 26, Rule 39, Rule 45, Rule 50; `ARCHITECTURE.md` §5.3, §39, §40; `ROADMAP.md` Phase 1 Slice S4; `PROVIDER_FEASIBILITY_AUDIT.md` §6.8

## Context

DEC-060 §H deferred `ServiceType` to its own decision and subdivided S4: **S4b** must settle whether a canonical service-class identity exists, its vocabulary shape, its separation from brand and reserved-seat status, and whether `Trip` refers to it. S4 is not complete until S4b is decided and implemented, or explicitly moved out of Phase 1.

The product needs a service-type label on a train candidate and on the current leg (`FEATURES.md` §3.1, §4.3; `DESIGN.md` §14.2). DEC-058 §7 already requires service brands, limited-express classification, and reserved-seat requirements to stay separate from line identity and from each other.

Three facts shape the answer:

1. **Evidence (B11, `PROVIDER_FEASIBILITY_AUDIT.md` §6.8).** The two inspected feeds — the retained Toei and Tokyo Metro static GTFS archives — do **not** establish service type, train brand, supplemental fare, or seat-reservation policy: no populated field carries any of them. Skip patterns appear only as `stop_times` rows whose flags, in these two archives, are consistent with stations passed without stopping. This is a statement about those two feeds, not a claim that no authoritative source exists; the ODPT train-timetable JSON is catalogued for both operators and its payload is unverified.
2. **One run can change type.** DEC-060 makes a multi-line through service one `Trip`. A service's type can change along one run — at an operator or line boundary, or within a line — so a single Trip-wide service type can be false for part of the traversal.
3. **Fare and seating vary on more axes than a Trip has.** A supplement or reserved seating can apply to some sections only, on some operating dates only, on some trains of the same type only, or in some cars only. A `Trip` is one recurring scheduled run definition (DEC-060 A), so a single Trip-wide value is truthful only where the fact is uniform.

## Decision

### A. Four separate facts

| Fact | Meaning | Status |
|---|---|---|
| **Service type** | The operator's named stopping-pattern class for a portion of a run (for example local, rapid, express, limited express, in that operator's own vocabulary). It is a **label**; the actual stopping pattern stays in `stopSequence` (DEC-060 B). | Defined; implemented in Phase 1 slice S4b (§B–§E) |
| **Train brand** | A named service family or marketing name (DEC-058 §7). | Defined, not implemented (§G) |
| **Supplemental fare requirement** | Whether a rider must pay a charge beyond the base fare. | Defined, not implemented (§G) |
| **Seat reservation policy** | Whether and where seats are reserved. | Defined, not implemented (§G) |

1. **No fact is derived from another.** No API, mapping, or presentation rule may compute a supplemental fare or seating policy from a service type or a brand, or a service type from a brand, or the reverse.
2. **No fact is inferred from indirect evidence** — not from a stopping pattern, a headsign, a provider trip identifier or its tokens, a line, or an operator (Rule 9, Rule 10, Rule 11).
3. **Unknown is always representable, and absence of data is never a negative fact.** A missing service type is unknown, not "local"; a missing supplement fact is unknown, not "no supplement"; a missing seating fact is unknown, not "unreserved".

### B. `ServiceTypeID`

`ServiceTypeID` is a new TSUGINO-owned canonical identifier, extending the DEC-021 list (`StationID`, `LineID`, `OperatorID`, `TripID`, `JourneyID`) without changing DEC-021's body. It follows DEC-051 exactly: at least one non-whitespace character, failable construction that never traps, the same rule on decoding, and exact preservation of a valid value. Provider service-type codes are Phase 2 mapping aliases (§40, Rule 9), never canonical identity.

### C. `ServiceType`

```text
ServiceType
- id              (ServiceTypeID)
- operatorID      (OperatorID)
- name            (LocalizedRailName — DEC-053)
```

1. **Identity is the `ServiceTypeID` alone.** Equality and hashing use only `id`, written explicitly as for `Operator` and `RailwayLine`; `operatorID` and `name` are descriptive and must be compared explicitly in `Codable` and actor-transfer tests.
2. **Operator-scoped.** Each service type belongs to exactly one operator. The same label on two operators is two `ServiceType` values: operators assign different stopping patterns to the same word, and their classes are not comparable.
3. **Construction is non-failable**: every component is already a validated value and there is no cross-field rule. Keyed `Codable` shape `{ id, operatorID, name }`.
4. `ServiceType` carries **no** rank or ordinal, no cross-operator comparison, no fare, seating, or brand flag, no colour or abbreviation, and no provider code.
5. Names are canonical three-language names (Rule 26, DEC-041, DEC-042, DEC-053); a missing provider Korean name is supplied from TSUGINO's canonical dataset.

### D. `TripServiceTypeSegment`

```text
TripServiceTypeSegment
- serviceTypeID   (ServiceTypeID)
- startIndex      (Int — index into Trip.stopSequence)
- endIndex        (Int — index into Trip.stopSequence; endIndex > startIndex)
```

It uses the index conventions of `TripLineSegment` (DEC-060 C): a **closed** range of passenger-stop indices, so a boundary stop belongs to both neighbouring segments. Construction is failable and never traps, and fails unless `0 <= startIndex < endIndex`; decoding applies the same rule. Equality and hashing are complete-value; the segment has no identifier.

### E. `Trip.serviceTypeSegments`

`Trip` gains `serviceTypeSegments: [TripServiceTypeSegment]`. Invariants, all checkable from the `Trip` value alone:

1. **Empty is valid** and means the service type is unknown for the whole represented traversal.
2. **Bounds:** every `endIndex <= stopSequence.count - 1`.
3. **Order:** segments are stored in traversal order, each starting no earlier than the previous one ends: `segment[n].startIndex >= segment[n - 1].endIndex`.
4. **Joins:** where `segment[n].startIndex == segment[n - 1].endIndex`, the segments are joined at that shared stop — the train arrives under one type and departs under the next. **This shared boundary index is the only permitted overlap**; overlap by two or more indices, nested ranges, duplicate ranges, and any order that does not progress through the traversal are invalid.
5. **Gaps mean unknown.** Where `segment[n].startIndex > segment[n - 1].endIndex`, and before the first or after the last segment, the movements not covered have **no stated** service type. Full coverage is **not** required. This is the one deliberate difference from `lineSegments`, which must cover the whole traversal.
6. **Normalised joins:** two **joined** segments must not share a `serviceTypeID`. Two segments with the same `serviceTypeID` separated by a gap are valid — the gap says the type between them is not known.
7. **Change at a passed station.** Indices address passenger stops only. If a type changes at a station the train passes without stopping, no truthful single type exists for the movement containing that station; that movement is left as a gap (`[…, k]` then `[k + 1, …]`) and is never assigned to either type.
8. **Independent of line segments.** Service-type boundaries need not coincide with line boundaries, and a line boundary does not imply a type change.
9. **Descriptive.** `serviceTypeSegments` participates in neither equality nor hashing; `TripID` remains the whole identity (DEC-060 A). Tests must compare it explicitly.
10. **Represented traversal only.** Segments describe the represented stops (DEC-060 C2); they say nothing about any unrepresented continuation, and coverage never relaxes these rules.
11. **Explicit at construction.** The `Trip` initialiser requires a `serviceTypeSegments` argument with no default, so every construction states either known segments or `[]` for unknown. The `Codable` key `serviceTypeSegments` is **required**; `[]` is its unknown value. Decoding applies exactly the rules above, validating arbitrary decoded integers before any use as an index or range, and fails with `DecodingError.dataCorrupted`, while missing keys and wrong types keep their natural errors.
12. **Consistency with datasets is not a value invariant.** Whether a segment's service type belongs to the operator actually running that portion, and whether every `serviceTypeID` names a known `ServiceType`, are **Phase 2 dataset validation** — `RailwayLine.operatorID` is not proof of who runs a Trip (DEC-060 D).

Every DEC-060 invariant is unchanged: `stopSequence`, `lineSegments`, `coverage`, identity, and immutability keep their accepted rules; `Trip` construction and decoding additionally fail when `serviceTypeSegments` is invalid.

### F. Passed-stop mapping caution (Phase 2)

**Observed pattern, not a general GTFS rule.** In the two inspected archives (audit §6.8), `stop_times.txt` contains mid-trip rows with `pickup_type = 1` **and** `drop_off_type = 1`, `timepoint = 0`, and no arrival or departure time; in these archives that pattern is consistent with **stations a trip passes without stopping**. Pickup and drop-off flags alone do not universally mean "not a passenger stop" — elsewhere they can express other boarding or alighting restrictions — so this Decision does not turn them into a rule. Phase 2 mapping must **verify passenger-stop status** for each provider and feed before building `stopSequence` (DEC-060 B): a row's presence does not make it a passenger stop, and only verified passenger stops enter the traversal. A service-type segment boundary is never placed at a station verified as passed (§E7). A skip pattern visible in such rows shows *which* stations are passed; it does not name the service type.

### G. Train brand, supplemental fare, and seat reservation — defined, not implemented

1. **Train brand** is a canonical entity with a future TSUGINO-owned identifier and a canonical localized name. It has no single operator, because a brand can be run jointly. It is never a `LineID`, an operator, a direction, or a service type (DEC-057, DEC-058 §7). Whether it attaches to a whole Trip or to segments is **not** decided here. DEC-058 §7 and §9 assigned the airport-service brand question to the Trip/ServiceType slice; this Decision **defers** that question to the later decision in §G6 rather than resolving it, while the through-service and singular-`lineID` questions are resolved by DEC-060 and §E. Deferral does **not** remove the requirement: airport service-brand guidance remains required for Airport Rail support (DEC-058 §6–§7) and needs verified data and that later contract. DEC-058's body is unchanged.
2. **Supplemental fare requirement** and **seat reservation policy** are **ride-scoped facts**: their truth can depend on the section ridden (boarding and alighting stops), the operating date, the individual train, and the car. A Trip-wide value is truthful **only** when the fact is verified uniform across every section, operating date, and car of that run definition; any other case is non-uniform or unknown and must not be flattened into a Trip-wide value.
3. **No vocabulary is finalised.** The provisional names considered during the S4b audit — a single "conditional" state and a "some cars reserved" state — are **not accepted**: the first cannot tell a rider whether *their* ride needs the supplement, and the second merges reserved-and-charged, reserved-and-free, and charged-but-unreserved cars.
4. **Sources.** These facts may come only from a verified provider source, or from manually curated canonical data that has an authoritative source, recorded provenance, a licence review, and an update rule. Otherwise they remain unknown.
5. **Seat booking remains out of scope** (`PRODUCT.md`, `FEATURES.md` §19). Describing a seating policy is not booking.
6. **Implementation is moved out of Phase 1.** No type for brand, supplemental fare, or seating is introduced, and nothing is attached to `Trip`. These facts are implemented by a later decision once an authoritative source is available. This disposal is what lets S4b satisfy the S4 completion rule for these three facts.

### H. Presentation rule (for later presentation work)

A user-facing label may combine only **verified** facts — service type, brand, supplement, seating — each from its own source. Unknown facts are **omitted**; they are never rendered as "local", "no supplement", or "unreserved", and a service-type label never implies a fare or seating rule. Rendering, localization of combined labels, and any warning wording belong to later presentation work; Phase 1 implements none of it.

## Detailed invariants and their boundaries

| Invariant | Boundary |
|---|---|
| valid `ServiceTypeID` | **S4b value construction** (DEC-051) |
| `ServiceType` identity is `id` only | **S4b value construction** |
| segment `0 <= startIndex < endIndex` | **S4b value construction** |
| segment bounds within `stopSequence` | **S4b `Trip` construction and decoding** |
| ordered; shared boundary is the only overlap; no nesting or duplicates | **S4b `Trip` construction and decoding** |
| joined segments differ in `serviceTypeID` | **S4b `Trip` construction and decoding** |
| gaps permitted and meaning unknown; empty permitted | **S4b** — a permission, not a check |
| every `serviceTypeID` names a known `ServiceType` | **Phase 2 dataset validation** |
| segment service type belongs to the operator running that portion | **Phase 2 dataset validation** |
| passenger-stop status verified before building `stopSequence` | **Phase 2 provider mapping** (§F) |
| provider service-type codes | **Phase 2 provider mapping** (§40) |
| brand, supplement, seating values | **later decision** (§G) |
| rendering and localization of labels | **later presentation work** (§H) |

## Alternatives considered

- **One Trip-wide `serviceTypeID`:** rejected — false for part of a run that changes type (Context 2).
- **Segments that must cover the whole traversal:** rejected — forces a fabricated type wherever the source is silent or a change happens at a passed station.
- **Segments aligned to `lineSegments`:** rejected — a type can change within a line and need not change at a line boundary.
- **A type per stop:** rejected — a service type describes movement between stops, which stop indices alone cannot express at a change point.
- **Closed enum or raw provider string:** rejected by DEC-060 §H and reconfirmed.
- **A global `ServiceType` shared across operators:** rejected — same words, different stopping patterns, non-comparable classes.
- **Trip-wide fare and seating enums now:** rejected — untruthful for section-, date-, train-, and car-dependent services (Context 3).

## Consequences

- `ARCHITECTURE.md` §5.3 gains `serviceTypeSegments`, `TripServiceTypeSegment`, `ServiceType`, and the gap rule; §39 gains `ServiceTypeID`; §40 gains the passenger-stop verification caution.
- `ROADMAP.md` S4b records this contract; implementation follows.
- `PROVIDER_FEASIBILITY_AUDIT.md` §6.8 records the B11 aggregate evidence.
- Phase 2 gains explicit targets: operator-scoped service-type records with canonical names, provider code aliases, segment derivation from verified sources only, and verified passenger-stop status.

## Phase ownership

**Phase 1 (S4b):** `ServiceTypeID`, `ServiceType`, `TripServiceTypeSegment`, and `Trip.serviceTypeSegments`. **Separate evidence task:** verify the ODPT train-timetable JSON payload for Toei and Tokyo Metro before Phase 2 maps service types. **Phase 2:** service-type records, provider aliases, dataset validation, passenger-stop verification. **Later decision:** brand, supplemental fare, and seating representations, once an authoritative source exists. **Later presentation work:** labels, localization, and wording.

## Explicit non-goals

No real service-type, brand, fare, or seating data; no provider identifier, code, mapping, or alias; no brand, fare, or seating type; no fare amount or fare product; no seat booking; no timetable or calendar; no realtime; no route search; no persistence; no UI, label rendering, or Live Activity; no new `RailCapability`; no cross-operator ranking. Fast-transfer exit doors and recommended car/door positions, transfer walking time, and next-train wait time are **outside S4b** and stay with their existing feature and roadmap owners (`FEATURES.md` §5.3–§5.5). This Decision does not mark S4 or Phase 1 complete.

## Implementation sequence

1. `ServiceTypeID` with DEC-051 tests.
2. `ServiceType` and `TripServiceTypeSegment` with their value tests.
3. `Trip.serviceTypeSegments`: required initialiser argument, required `Codable` key, invariants §E, and updates to existing Trip tests.
4. Independent review, then the S4b and S4 completion records.

S4b tests must cover, at minimum: identifier validity; `ServiceType` ID-only equality and hashing with explicit descriptive comparison; segment construction bounds; empty, partial, gapped, and full service-type coverage; a join with a type change; a gap around a change at a passed station; rejected wider overlap, nesting, duplicates, misordering, and out-of-bounds indices; rejected joined same-type segments and accepted gap-separated same-type segments; a multi-line through service whose type changes at and away from a line boundary; unchanged DEC-060 behaviour; and `Codable` round-trips plus rejection of every invalid structure and of a missing `serviceTypeSegments` key.

## Revisit Triggers

- A verified source shows a service-type change that cannot be expressed at a passenger stop or as a gap.
- A verified source makes brand, supplement, or seating facts available (§G4).
- The ODPT train-timetable evidence task shows service-type semantics that are not operator-scoped.
- A consumer needs a ranking or comparison of service types.
- Persistence design (Phase 6) requires a different encoded representation.

---

# DEC-062 — Journey Structure Uses Position-Addressed Legs with Explicit Rail Selection and Station Continuity

**Status:** Accepted\
**Date:** 2026-09-23\
**Related:** DEC-003, DEC-007, DEC-008, DEC-009, DEC-010, DEC-011, DEC-021, DEC-023, DEC-031, DEC-043, DEC-047, DEC-048, DEC-050, DEC-051, DEC-060, DEC-061; `RULES.md` Rule 5, Rule 16, Rule 17, Rule 18, Rule 39, Rule 45, Rule 50; `ARCHITECTURE.md` §5.4, §5.5, §5.6, §6, §7, §12, §14; `ROADMAP.md` Phase 1 Slice S5

## Context

Phase 1 still owes the journey models (`ROADMAP.md` Phase 1 *Included*). `ARCHITECTURE.md` §5.4 and §5.5 have carried an unresolved Phase 0 sketch — `Journey { id, origin, destination, legs, currentLegIndex, state, createdAt, updatedAt }` and `JourneyLeg { id, kind, boardingStation, alightingStation, plannedTrip, selectedTrip, realtimeState, transferGuidance }` — with the same kind of problems DEC-060 resolved for `Trip`:

- `currentLegIndex`, `state`, and `realtimeState` put runtime state into the route definition, which §5.6 says must stay separate;
- `origin` and `destination` duplicate the first boarding and last alighting stations;
- `plannedTrip` is a route-search result (Phase 3), `transferGuidance` is Phase 10, and `createdAt`/`updatedAt` are persistence (Phase 6);
- a boarding or alighting **station** cannot address a visit once a Trip repeats a station (DEC-060 B).

Accepted facts constrain the answer: the user explicitly selects the train (DEC-007, Rule 18) through the boarding-station / departure / destination model (DEC-047); each rail leg binds its own Trip, which may be chosen later or replaced independently (DEC-008, Rule 17, §12); through service is not a transfer (DEC-009, Rule 16); Phase 1 defines shapes and Phase 5 owns progression and binding behaviour (DEC-011, DEC-050); cross-operator interchange stations share one `StationID` (DEC-048). Every invariant must be checkable from the value alone.

S5 is subdivided: **S5a — Journey structure** (this Decision) and **S5b — Journey runtime state** (phase, state, freshness, interruption, events, typed errors; a later decision). **S6** remains the protocol slice.

## Decision

### A. Types

```text
Journey                      — entity; equality and hashing by JourneyID only
- id        (JourneyID)
- legs      ([JourneyLeg] — addressed by position)

JourneyLeg                   — enum
- rail(RailLeg)
- walkingTransfer(WalkingTransfer)

RailLeg                      — enum: the leg's selection state
- unselected(RailLegAnchors)
- selected(SelectedRailTrip)

RailLegAnchors               — value; failable
- boardingStationID   (StationID)
- alightingStationID  (StationID)

SelectedRailTrip             — value; failable
- trip            (Trip — snapshot of the chosen Trip)
- boardingIndex   (Int — index into trip.stopSequence)
- alightingIndex  (Int — index into trip.stopSequence)
  derived: boardingStationID, alightingStationID, anchors

WalkingTransfer              — value; failable
- fromStationID  (StationID)
- toStationID    (StationID)
```

No new canonical identifier is introduced: legs are addressed by **position** in `legs`, and `JourneyID` already exists (DEC-021). All types are `nonisolated`, `Codable`, `Sendable`, and import-free; construction is failable and never traps (DEC-051 rule 11).

### B. Journey identity and equality

1. `Journey` equality and hashing use **`JourneyID` alone**, written explicitly; `legs` is descriptive and must be compared explicitly in `Codable` and actor-transfer tests.
2. **`JourneyLeg`, `RailLeg`, and `SelectedRailTrip` are not `Equatable`.** No S5a invariant, API, or consumer needs to compare legs: Journey identity is the ID, and the invariants below compare only `StationID`s, `TripID`s, and indices. Synthesised equality would also be **misleading**, because `Trip` equality is ID-only (DEC-060 A), so two different snapshots with the same `TripID` would compare equal. If a later consumer genuinely needs leg comparison — for example Phase 5 change detection or Phase 6 persistence diffing — it must define an explicit deep-snapshot rule in its own decision. `RailLegAnchors` and `WalkingTransfer` hold only identifiers and may use complete-value equality.

### C. Rail legs — unselected and selected

1. **Unselected (`RailLegAnchors`).** Records only the known boarding and alighting stations — the user's selection (DEC-047) or, later, a route-search result. It has **no** Trip, stop index, time, or route; those fields do not exist in this state, so none can be invented. Valid only when `boardingStationID != alightingStationID`.
2. **Selected (`SelectedRailTrip`).** Embeds the chosen `Trip` **snapshot** and addresses boarding and alighting by **index**, which stays unambiguous when the Trip visits a station more than once (DEC-060 B). Valid only when `0 <= boardingIndex < alightingIndex <= trip.stopSequence.count - 1` **and** the stations at those indices differ. Its anchors are **derived** from the snapshot, never stored a second time. A snapshot with partial `coverage` is valid; the indices can only address represented stops.
3. **Same station at both ends is rejected in both states.** A leg that ends where it began carries the rider nowhere, including a full lap of a loop.
4. **Selection preserves anchors.** Selecting a Trip for an unselected leg is valid only when the selection's derived anchors equal the unselected anchors; S5a provides this as a pure check, `RailLegAnchors.admits(_:) -> Bool`, beside the failable `SelectedRailTrip` constructor. A selection at different stations is a **replan**, not a selection. S5a provides **no** operation that binds, replaces, or mutates a leg inside a Journey: *when* and *how* a Trip is bound — at journey start, near transfer time, or on replacement — is Phase 5 selected-trip binding and recovery (DEC-011, DEC-050).
5. **Snapshot staleness** — a later correction to the same `TripID` in the dataset — is reconciliation, owned by Phase 5 and Phase 6, not a structural invariant. Inside one Journey the question cannot arise: `TripID`s are unique across selected legs (§E5), so a Journey never holds two snapshots of the same Trip.

### D. Walking transfer — recorded, not verified

1. `WalkingTransfer` records that the Journey changes station on foot between two **distinct** canonical stations (`fromStationID != toStationID`). A same-station transfer needs no walking leg.
2. Structural validity means only that the walk is **stated**. It does **not** claim that a pedestrian connection exists, whether it is inside or outside fare gates, its accessibility, its length, or its duration.
3. **Verification belongs elsewhere:** that two stations form a known transfer pair, from data with recorded provenance, is **Phase 2** dataset validation; walking time, route, exits, and accessibility guidance are **Phase 10** transfer guidance with confidence and provenance (`ARCHITECTURE.md` §14); producing walking legs from a search is **Phase 3**. No presentation may describe a structurally valid walk as a verified connection.

### E. Journey invariants

Each leg has a start and an end station, computed from local values only:

| Leg | Start | End |
|---|---|---|
| unselected rail | `anchors.boardingStationID` | `anchors.alightingStationID` |
| selected rail | `trip.stopSequence[boardingIndex]` | `trip.stopSequence[alightingIndex]` |
| walking transfer | `fromStationID` | `toStationID` |

1. `legs` is **non-empty**.
2. **Continuity:** `end(legs[n]) == start(legs[n + 1])` for every consecutive pair. Continuity compares canonical `StationID`s only; a cross-operator interchange at one canonical station (DEC-048) needs no walking leg, and whether a real transfer path exists there is still Phase 2 or Phase 10.
3. The **first and last legs are rail legs**: a Journey begins at a boarding station and ends at an alighting station (DEC-047).
4. **No two consecutive walking legs.** Phase 1 has no pathway model that could justify an intermediate station; a walk from A to C is one leg.
5. **Journey-wide `TripID` uniqueness.** No two **selected** rail legs in one Journey may carry the same `TripID`: a selected rail leg is rejected when any **earlier** selected rail leg in the Journey has the same `trip.id`, **regardless of what lies between them** — a walking leg, an unselected leg, or a selected leg on a different Trip. An **unselected** leg has no `TripID` and does not count. A **through service remains one selected rail leg** (DEC-009, Rule 16), so a ride that crosses line boundaries never needs a second occurrence of its `TripID`.

   This is a **conservative structural rule**, not a claim about real travel. A `TripID` is a recurring run definition (DEC-060 A), and S5a stores no service date or execution identity, so it cannot establish that two uses of one `TripID` refer to **different dated executions**. Rather than admit a second occurrence that could equally encode one ride cut into a fake transfer, backward travel through one run, or two incompatible snapshots of the same run, S5a rejects every second occurrence. It does **not** assert that riding the same recurring run twice in one journey is impossible — for example on different service days — and a **later decision** may permit reuse by introducing an explicit service-date or execution identity. Because every `TripID` occurs at most once, no Journey holds two snapshots of the same Trip, so no cross-leg snapshot comparison or cross-leg index comparison is needed; each selected leg keeps **its own** index validation (§C2). Pairs involving an unselected leg are not compared; because the rule is a `Journey` invariant, it applies as soon as a Journey is constructed with those legs selected.
6. **An all-unselected Journey is structurally valid.** Whether tracking may begin — for example, requiring a selected first leg (DEC-007) — is a readiness rule for S5b / Phase 5, not a structural invariant.

### F. Encoded shape

Both enums use **one stable keyed pattern**: a `kind` discriminator naming the case, and exactly one payload key with the **same name as that case**.

```json
{ "id": "J-1", "legs": [
  { "kind": "rail",
    "rail": { "kind": "selected",
              "selected": { "trip": { … Trip … }, "boardingIndex": 0, "alightingIndex": 2 } } },
  { "kind": "walkingTransfer",
    "walkingTransfer": { "fromStationID": "s-2", "toStationID": "s-3" } },
  { "kind": "rail",
    "rail": { "kind": "unselected",
              "unselected": { "boardingStationID": "s-3", "alightingStationID": "s-4" } } }
] }
```

`JourneyLeg.kind` ∈ { `rail`, `walkingTransfer` }; `RailLeg.kind` ∈ { `unselected`, `selected` }. Decoding **rejects**:

- a **missing** `kind` (`keyNotFound`, the natural keyed-container error);
- an **unknown** `kind` value (`dataCorrupted`);
- a **contradictory** payload — any payload key belonging to a **different** case, whether or not the named case's payload is also present (`dataCorrupted`); this check runs before the next one, so a wrong-case payload is always reported as contradictory;
- a **missing** payload for the named case when no contradictory key is present (`keyNotFound`);
- any **invalid nested value** — a blank identifier, an invalid `Trip`, out-of-range, reversed, or extreme indices, same-station ends — through the nested value's own rule (`dataCorrupted`), validating decoded integers before any use as an index;
- a `Journey` that violates §E (`dataCorrupted`).

No persisted Journey schema exists yet (Rule 39); Phase 6 owns persistence and any migration.

## Detailed invariants and their boundaries

| Invariant | Boundary |
|---|---|
| valid `JourneyID`, `StationID`, `TripID`; valid `Trip` snapshot | **already guaranteed** by their own types (DEC-051, DEC-060, DEC-061) |
| rail anchors distinct; walking endpoints distinct | **S5a value construction** |
| `0 <= boardingIndex < alightingIndex <= count − 1`; distinct stations at those indices | **S5a value construction** |
| selection preserves anchors (`admits`) | **S5a pure check**; performing the binding is **Phase 5** |
| non-empty legs; continuity; rail first and last; no consecutive walks; Journey-wide `TripID` uniqueness across selected legs | **S5a `Journey` construction and decoding** |
| encoded discriminator shape and rejection rules | **S5a decoding** |
| walking pair is a known pedestrian connection; interchange path exists | **Phase 2 dataset validation** |
| walking time, route, exits, accessibility | **Phase 10 transfer guidance** |
| reuse of a `TripID` within one Journey (service-date or execution identity) | **later decision** |
| operating date; readiness to track | **S5b / Phase 5** |
| binding, replacement, replanning, snapshot reconciliation | **Phase 5** (with Phase 6 for persisted snapshots) |
| current leg, phase, freshness, interruption, events | **S5b** (state vocabulary) and **Phase 5** (behaviour) |
| creation and update timestamps; persistence | **Phase 6** |

## Alternatives considered

- **Leg stores only `TripID` plus indices:** rejected — its invariants would need a dataset lookup (Phase 2), and it would not record what the user actually chose.
- **Anchors stored alongside the snapshot:** rejected — two sources of truth for the same stations.
- **Unselected leg as an optional Trip on a single struct:** rejected — makes "indices without a Trip" representable.
- **Strict same-station continuity with no walking leg:** rejected — blocks genuine transfers between distinct canonical stations.
- **Consecutive walking legs:** rejected for now — no pathway model justifies the intermediate station.
- **Checking only directly consecutive same-`TripID` legs** (structurally identical snapshots, then a higher boarding index): rejected — an intervening walking, unselected, or different-Trip leg would bypass it, so validity would depend on how the route is segmented; and without service-date or execution identity no index policy can tell a later execution from backward travel through one run.
- **Deferring same-`TripID` checks to Phase 5:** rejected — the value would admit fake splits and backward travel that nothing in it can distinguish from legitimate reuse, so structural validity could not be trusted before Phase 5.
- **Journey-wide `TripID` uniqueness:** selected — conservative, checkable from the value alone, and independent of segmentation; the cost, that legitimate reuse on another service day is not yet representable, is recorded for a later decision.
- **A new `JourneyLegID`:** rejected — position addressing suffices; no consumer needs stable leg identity yet.
- **Synthesised leg equality:** rejected — misleading under ID-only `Trip` equality (§B).
- **Stored `origin`/`destination`, `currentLegIndex`, `state`, timestamps, `plannedTrip`, `realtimeState`, `transferGuidance`:** removed from the Journey structure with the owners recorded in the table above.

## Consequences

- `ARCHITECTURE.md` §5.4 and §5.5 replace the sketch with this contract; §5.6 (`JourneyState`) is marked as the S5b contract, still unresolved.
- `ROADMAP.md` gains Phase 1 Slice S5 with the S5a / S5b subdivision; S6 stays the protocol slice.
- Phase 5 gains an explicit structural target: legs it can bind by anchor-preserving selection, in a Journey where each `TripID` occurs at most once; reusing a `TripID` needs a later decision introducing service-date or execution identity.
- **S5 completion.** S5 is complete only when S5a and S5b are each decided, implemented with focused tests, and independently reviewed. S5 may close with S5b deferred **only** if a new accepted decision names the phase that replaces S5b and revises the affected Phase 1 acceptance criteria (and any Included deliverable it removes from Phase 1); deferral alone is not completion.

## Phase ownership

**Phase 1 (S5a):** the types and invariants above. **S5b:** `JourneyState`, `JourneyPhase`, `JourneyEvent`, realtime freshness, interruption reasons, typed errors, and tracking readiness. **S6:** the `JourneyEngine` protocol boundary (DEC-050) and the `RouteSearching` disposition. **Phase 2:** pedestrian-connection and interchange validation. **Phase 3:** route search producing legs. **Phase 5:** binding, progression, reconciliation, recovery, and time-dependent checks. **Phase 6:** persistence, timestamps, snapshot migration. **Phase 10:** transfer guidance. **Later decision:** service-date or execution identity, if a later recurrence of the same `TripID` must be representable in one Journey.

## Explicit non-goals

No runtime state, phase, current leg, freshness, event, error, or readiness rule; no binding, replacement, or progression behaviour; no route search or planned trip; no realtime state; no transfer guidance, walking time, exit doors, or next-train wait; no pedestrian-connection verification; no provider identifier or mapping; no brand, fare, or seating (DEC-061 G); no persistence or timestamps; no UI or Live Activity; no new canonical identifier; no new dependency. This Decision does not mark S5 or Phase 1 complete.

## Implementation sequence

1. `RailLegAnchors`, `WalkingTransfer`, and `SelectedRailTrip` with their value tests and `admits`.
2. `RailLeg` and `JourneyLeg` with the §F encoded shape.
3. `Journey` with the §E invariants and ID-only identity.
4. Independent review, then the S5a completion record.

**Enforcement.** Every §E invariant, including §E5, is checked by the failable `Journey` initialiser, and `Journey` decoding calls the same validation, failing with `DecodingError.dataCorrupted` — so a decoded Journey can never be one construction would have rejected. §E5 tests must include, at minimum: a duplicate `TripID` separated by a **walking** leg, by an **unselected** leg, and by a selected leg on a **different** Trip — each with the second occurrence at a **lower** and at a **higher** boarding index than the first alights, and each with **identical** and with **incompatible** snapshots (for example a stop inserted or removed) — all rejected; directly consecutive duplicates at an equal, lower, and higher index, including repeated-station continuity on a loop-plus-tail snapshot, all rejected; unselected legs alongside a selected leg not counted as duplicates; a multi-line through service as one selected leg accepted; several selected legs with **different** `TripID`s accepted when every other Journey invariant holds; and each case again through decoding.

## Revisit Triggers

- A verified journey needs consecutive walking legs, a non-rail mode, or a leg that starts or ends with a walk.
- A consumer genuinely needs leg equality or stable leg identity.
- A verified journey needs a later recurrence of the same `TripID` within one Journey, requiring a service-date or execution identity.
- Phase 3 route-search results cannot be represented as anchors plus walking legs.
- Persistence design (Phase 6) requires a different encoded representation.

---

# DEC-063 — Journey Runtime State Uses Neutral Phases, Current-Leg Freshness, and Pair-Validated Consistency

**Status:** Accepted\
**Date:** 2026-09-24\
**Related:** DEC-007, DEC-008, DEC-010, DEC-011, DEC-012, DEC-022, DEC-023, DEC-024, DEC-026, DEC-027, DEC-030, DEC-031, DEC-033, DEC-038, DEC-043, DEC-046, DEC-047, DEC-050, DEC-051, DEC-062; `RULES.md` Rule 4, Rule 5, Rule 7, Rule 11, Rule 12, Rule 19, Rule 39, Rule 45; `ARCHITECTURE.md` §5.6, §6, §7, §25, §34, §35; `FEATURES.md` §4.12, §8, §10.3, §10.4, §16; `PRODUCT.md` §14; `ROADMAP.md` Phase 1 Slice S5

## Context

S5b owes the Phase 1 runtime-state vocabulary (`ROADMAP.md` Phase 1 *Included*: `JourneyState`, `JourneyPhase`, `JourneyEvent`, typed errors; *Implementation Tasks*: realtime freshness and interruption/recovery models). `ARCHITECTURE.md` §5.6 carries an unresolved sketch — `JourneyState { phase, currentLegIndex, currentStation, nextStation, remainingStops, progress, realtimeFreshness, interruptionReason, lastConfirmedAt }` — and §6 lists eleven phases (Planning, WaitingForDeparture, Boarding, OnTrain, ApproachingTransfer, Transferring, WaitingForNextTrain, ApproachingDestination, Arrived, Ended, Interrupted), repeated in `FEATURES.md` §8 and `PRODUCT.md` §14; §6 also draws Recovered / Replanned / Ended as exits from Interrupted.

Constraints:

- Phase 1 defines types and outputs; **Phase 5 owns every transition, progression, and detection** (DEC-011, DEC-050). A Phase 1 slice that asserts transition outcomes has drifted.
- Freshness is explicit (DEC-024); unsupported precision is never implied (DEC-038); the scheduled tier may show scheduled next stop and clock-based scheduled progress but must not represent actual train location, station passage, departure, arrival, or onboard confirmation (DEC-046, DEC-047, `FEATURES.md` §10.3).
- No value observes the **rider**: location is optional (Rule 4, DEC-026) and realtime observes only the train.
- Animation never drives state (DEC-012); Live Activities consume derived state (DEC-030).
- Already settled for S5b: recovery **proposals** are an engine output and belong to **S6**; freshness describes the **current leg** only; stale realtime alone is **not** an interruption; the event set is minimal.

## Decision

### A. Neutral phases, not rider claims

Several documented phase names assert facts no Phase 1 value can support: *Boarding* and *OnTrain* claim the rider got on; *Arrived* claims an actual arrival; and the pairs *WaitingForDeparture* / *WaitingForNextTrain* and *ApproachingTransfer* / *ApproachingDestination* differ only by derivable leg position. `JourneyPhase` therefore stores a smaller **neutral** vocabulary describing where the journey stands **in the selected plan**; how it was established comes from `freshness` and each basis, never from the phase name.

```text
JourneyPhase                  — enum
- planning
- awaitingDeparture(legIndex)
- riding(legIndex, position: JourneyPosition?)
- transferring(TransferPoint)
- plannedEndReached(PlannedEndBasis)
- interrupted(JourneyInterruptionReason, legIndex: Int?)
- ended(JourneyEndReason)

TransferPoint                 — enum
- walking(legIndex)                    — on a walking leg
- atStation(afterRailLeg: n)           — a same-station change between rail legs n and n + 1

JourneyPosition               — value; failable (index >= 0)
- place: atStop(index) | betweenStops(after: index)   — into the current leg's trip.stopSequence
- basis: observed | scheduleEstimate

PlannedEndBasis               — enum
- schedule                    — the final leg's scheduled arrival time has passed
- trainObservedAtFinalStop    — realtime observed the selected train at the final alighting stop

JourneyInterruptionReason     — missedTrain, wrongTrain, wrongDirection, serviceCancelled,
                                destinationChanged, serviceSuspended, invalidPersistedJourney,
                                unsupportedServiceChange
JourneyEndReason              — trackingCompleted, cancelledByUser, endedEarlyByUser
```

| Stored phase | Documented names it covers | Asserts |
|---|---|---|
| `planning` | Planning | tracking has not started |
| `awaitingDeparture(i)` | WaitingForDeparture, WaitingForNextTrain | before the departure of rail leg `i` |
| `riding(i, position?)` | Boarding, OnTrain, ApproachingTransfer, ApproachingDestination | within leg `i`'s selected ride, on the stated basis |
| `transferring(point)` | Transferring | between two rail legs |
| `plannedEndReached(basis)` | Arrived (see §B) | the plan's final alighting point has been reached **by the stated basis** — never the rider's confirmed arrival |
| `interrupted(reason, i?)` | Interrupted | the plan has diverged |
| `ended(reason)` | Ended | tracking is over (terminal) |

**Recovered** and **Replanned** are **transitions, not phases**: recovery is reported by a `recovered` event (§F) and replanning produces a revised Journey (DEC-062 C4; Phase 5). The documented names remain **derived presentation labels**, computed by presentation mappers from the phase, the leg index, the position, and the Journey, under the provenance rules below — for example "boarding" from `riding(i, atStop(boardingIndex))`, "approaching destination" from a position just before the last leg's alighting stop, "waiting for next train" from `awaitingDeparture(i)` with `i > 0`.

**Honest presentation.** With `scheduledOnly` or `scheduleFallback` freshness, `awaitingDeparture` shows the scheduled departure, `riding` shows "your selected train, per timetable" with the scheduled next stop and clock-based progress, and `plannedEndReached(.schedule)` shows that the scheduled arrival time has passed; nothing says boarded, departed, passed, or arrived. With realtime freshness an `observed` position means the **train** was observed there; wording still never says the rider boarded.

### B. The planned endpoint is not arrival

`plannedEndReached` records that the plan's final alighting point has been reached by one of two bases, neither of which is the rider's arrival:

- **`schedule`** — clock time passed the final leg's scheduled arrival (the only basis available to scheduled guidance). Phase 5 may produce it **only** when it has a scheduled final-arrival time for the selected Trip to compare against the supplied clock; S5b stores the resulting phase and basis, never a fabricated timetable, and defines no comparison or transition logic. Without such a time, this basis is not used;
- **`trainObservedAtFinalStop`** — realtime observed the selected **train** at the final alighting stop. It concerns the train, never the rider: train location alone never establishes that the **rider** arrived.

**Confirmed rider arrival is outside S5b.** It would need rider-side evidence: an explicit user confirmation, or — only where the user has granted it — device location consistent with the final station, under the privacy limits of Rule 4, DEC-026, and DEC-043. No such input exists in Phase 1. A later decision may add a confirmed basis together with its evidence source; until then no surface may present `plannedEndReached` as "Arrived" for scheduled guidance, or as the rider's confirmed arrival for either basis. `JourneyEndReason.trackingCompleted` likewise means tracking ended after the planned endpoint, not that arrival was confirmed.

### C. Freshness of the current leg

```text
RealtimeFreshness             — enum
- live(updatedAt)
- delayedUpdate(lastUpdatedAt)
- stale(lastUpdatedAt)
- scheduleFallback(lastRealtimeAt: Date?)   — realtime expected but not usable; timetable guidance is still available
- scheduledOnly                             — the service has no verified trip-level realtime (DEC-046, DEC-047)
- unavailable                               — insufficient data for current guidance, realtime or timetable
```

It describes the **current leg's** service only (§A context). Classifying a feed into these cases from data age and provider thresholds is **Phase 4 / Phase 5** (DEC-024); S5b stores the classification. Stale or unavailable realtime is degraded freshness, **not** an interruption; only Phase 5 may decide that guidance cannot continue and move to `interrupted`.

### D. JourneyState — the value alone

```text
JourneyState                  — value; failable
- journeyID       (JourneyID — which Journey this state describes)
- phase           (JourneyPhase)
- freshness       (RealtimeFreshness)
- lastConfirmedAt (Date? — last realtime-confirmed progress)
- asOf            (Date — the instant this state describes)
```

Not stored: `currentStation`, `nextStation`, `remainingStops` (derived from position and the Journey — Phase 5, DEC-011); `progress` (an approximate presentation value, DEC-038; derived later, never stored as truth). Nothing is written into `Journey` (DEC-062). All times are **inputs**; Domain never reads a clock, which is how "deterministic time behavior" is met.

`JourneyState` construction fails (returns `nil`, DEC-051 style) unless, from the value alone:

1. `lastConfirmedAt`, when present, is `<= asOf`;
2. every timestamp in `freshness` is `<= asOf`;
3. an `observed` position requires realtime-derived freshness — `live`, `delayedUpdate`, or `stale`;
4. `plannedEndReached(.trainObservedAtFinalStop)` requires realtime-derived freshness on the same terms.

`JourneyPosition` construction fails for a negative index.

### E. ActiveJourney — pair validation and the Phase 1 typed error

```text
ActiveJourney                 — value; throwing construction
- journey  (Journey)
- state    (JourneyState)

ActiveJourneyInconsistency    — Error
- journeyMismatch
- legIndexOutOfRange(Int)
- legKindMismatch(legIndex: Int)
- legNotSelected(legIndex: Int)
- positionOutOfRange(legIndex: Int)
```

`ActiveJourney(journey:state:)` is the only place a state's consistency with its Journey is checked, and it **throws** `ActiveJourneyInconsistency` so a caller learns which rule failed. Checks run in this order and produce exactly these errors:

| Check | Error |
|---|---|
| `state.journeyID != journey.id` | `journeyMismatch` |
| any leg index in the phase — `awaitingDeparture(i)`, `riding(i, …)`, `walking(i)`, both `n` and `n + 1` of `atStation(afterRailLeg: n)`, `interrupted(_, i)` — is `< 0` or `>= legs.count` | `legIndexOutOfRange(index)` |
| `awaitingDeparture(i)` or `riding(i, …)` on a walking leg; `walking(i)` on a rail leg; `atStation(n)` where leg `n` or `n + 1` is not rail | `legKindMismatch(legIndex:)` |
| `riding(i, …)` on an unselected rail leg; `awaitingDeparture(0)` on an unselected rail leg (**first-leg readiness**, DEC-007) | `legNotSelected(legIndex:)` |
| `atStop(k)` outside `boardingIndex...alightingIndex`, or `betweenStops(after: k)` outside `boardingIndex..<alightingIndex`, of leg `i`'s selection | `positionOutOfRange(legIndex:)` |

Nothing else is checked. `planning`, `plannedEndReached`, and `ended` pair with **any** Journey, including an all-unselected one; `awaitingDeparture(i)` with `i > 0` may point at an unselected leg (DEC-008 — the next train may be chosen near transfer time); `transferring(atStation)` accepts either selection state. The pair imposes **no ordering**: which phase may follow which, that legs advance monotonically, that `plannedEndReached` follows the last leg, and how any phase is reached are **Phase 5 transition rules**. A Journey whose leg was replaced keeps its `JourneyID` and is simply re-paired and re-checked.

**Typed throws.** The construction is declared with typed throws, `throws(ActiveJourneyInconsistency)`, where the project's language mode supports it; implementation must verify that support. If the language mode prevents it, the construction uses ordinary `throws`, documented and tested to throw **only** `ActiveJourneyInconsistency`. Either form satisfies this contract.

**Typed-error scope.** `ActiveJourneyInconsistency` is the Phase 1 typed-error deliverable. Its consumers are the Phase 6 recovery path for a persisted Journey that no longer pairs with its state (`invalidPersistedJourney`, DEC-031) and structured diagnostics (DEC-033). It deliberately invents **no** provider, route-search, realtime, persistence, transfer-guidance, or transition error: those remain examples for their owning phases (`ARCHITECTURE.md` §34), and the Phase 1 acceptance criteria are unchanged. This throwing construction is a **narrow exception** to the failable, non-throwing construction pattern (DEC-051 and later value decisions), limited to `ActiveJourney`, because only this pairing has a consumer that needs the reason.

### F. Events

```text
JourneyEvent                  — value; failable
- occurredAt  (Date)
- kind        (JourneyEventKind)

JourneyEventKind
- phaseChanged(from: JourneyPhase, to: JourneyPhase)     — from != to
- legStarted(legIndex)                                    — >= 0
- tripSelected(legIndex)                                  — >= 0
- tripReplaced(legIndex)                                  — >= 0
- freshnessChanged(from: RealtimeFreshness, to: RealtimeFreshness)   — from != to
- recovered
```

There is **no separate `interrupted` or `ended` event**: `phaseChanged(to: .interrupted(reason, legIndex))` already carries the interruption reason and leg, and `phaseChanged(to: .ended(reason))` already carries the end reason, so a second event would duplicate either. Events are outputs Phase 5 produces and notifications consume (DEC-010, Phase 10); S5b defines only their shape and the local rules noted. Detecting any event is Phase 5. There are no per-stop events; Live Activities read state (DEC-030).

### G. Conformances

| Type | Conformance | Consumer |
|---|---|---|
| every S5b type | `Sendable` | state and events cross from off-main-actor production to the UI (DEC-027) |
| `JourneyPhase`, `TransferPoint`, `JourneyPosition`, `PlannedEndBasis`, `RealtimeFreshness`, the reason enums | `Equatable` | the event rules `phaseChanged(from != to)` and `freshnessChanged(from != to)` |
| `ActiveJourneyInconsistency` | `Error` | the typed-error contract (§E) |
| `JourneyState`, `ActiveJourney`, `JourneyEvent` | none beyond `Sendable` | no Phase 1 consumer compares, hashes, or stores them |
| any S5b type | **no** `Hashable`, **no** `Codable` | no key use; the persisted format and migration are **Phase 6** (Rule 39, DEC-023) |

No encoding rule is specified now. When Phase 6 persists an active Journey it should reuse the DEC-062 §F `kind` + payload pattern and route decoding through the §E pair validation. `Journey` stays `Codable` under DEC-062.

## Detailed invariants and their boundaries

| Invariant | Boundary |
|---|---|
| position index `>= 0` | **S5b `JourneyPosition` construction** |
| timestamps `<= asOf`; observed position and observed endpoint require realtime-derived freshness | **S5b `JourneyState` construction** |
| journey match; leg index range; leg kind; selection and first-leg readiness; position within the selection | **S5b `ActiveJourney` construction** (typed error) |
| event `from != to`; event leg index `>= 0` | **S5b `JourneyEvent` construction** |
| which phase may follow which; monotonic legs; how phases are reached | **Phase 5** |
| classifying freshness from age and thresholds | **Phase 4 / Phase 5** |
| detecting interruptions and events; recovery proposals | **Phase 5** / **S6** |
| current and next station, remaining stops, progress | **Phase 5** (derived) |
| presentation labels ("Boarding", "Arrived", …) | **presentation mappers (Phases 8–9)** under §A / §B |
| confirmed rider arrival | **later decision** with rider-side evidence |
| persistence, encoding, migration | **Phase 6** |

## Alternatives considered

- **Keep the eleven documented phase names as stored values:** rejected — *Boarding*, *OnTrain*, and *Arrived* assert rider facts nothing observes, and four names duplicate derivable leg position.
- **A stored "arrived" phase with a basis flag:** rejected — the word itself reads as confirmed arrival on every surface.
- **Requiring a selected rail leg for every phase after planning:** rejected — would reject valid transfers, waiting for a train chosen near transfer time, interruptions, and ended journeys.
- **Validating state only inside the engine:** rejected — a persisted state would never be checked against its Journey.
- **Deferring all typed errors and revising the Phase 1 criteria:** rejected — the pairing error has a real consumer and satisfies the deliverable without inventing unowned errors.
- **Codable now:** rejected — no Phase 1 consumer; Phase 6 owns the format.
- **Storing current station, next station, remaining stops, or progress:** rejected — derived values that could drift; Phase 5 owns the derivation.

## Consequences

- `ARCHITECTURE.md` §5.6 replaces the sketch with this contract; §6 marks its diagram as documented presentation labels mapped to stored phases, with transitions in Phase 5; §34 records the Phase 1 typed error.
- `FEATURES.md` §8 and `PRODUCT.md` §14 mark their phase lists as presentation labels derived from the stored phases, with "Arrived" never shown for schedule-based completion; `FEATURES.md` §9.4 describes a planned-endpoint notification rather than arrival confirmation; `DESIGN.md` notes that the Arrived scene never presents schedule passage or observed train location as confirmed rider arrival.
- `ROADMAP.md` S5b records this contract; S6 gains recovery proposals beside the engine boundary.

## Phase ownership

**Phase 1 (S5b):** the types and construction rules above. **S6:** the `JourneyEngine` protocol boundary and recovery-proposal shape. **Phase 4 / 5:** freshness classification. **Phase 5:** transitions, progression, detection, derived stations and counts. **Phase 6:** persistence and encoding. **Phases 8–9:** presentation labels. **Phase 10:** notifications consuming events. **Later decision:** confirmed rider arrival.

## Explicit non-goals

No transition graph, ordering rule, or state machine behaviour; no detection of any event, interruption, or arrival; no freshness thresholds or classification; no realtime snapshot or provider data; no capability attachment; no recovery proposal; no `JourneyEngine` protocol; no persistence or encoding; no notification, Live Activity, UI, or animation state; no change to `Journey`; no brand, fare, seating, or transfer guidance; no new canonical identifier; no new dependency. This Decision does not mark S5 or Phase 1 complete.

## Implementation sequence

1. `JourneyPosition`, `TransferPoint`, `PlannedEndBasis`, the reason enums, and `RealtimeFreshness`.
2. `JourneyPhase` and `JourneyState` with §D.
3. `ActiveJourney` and `ActiveJourneyInconsistency` with §E.
4. `JourneyEvent` with §F.
5. Independent review, then the S5b and S5 completion records.

## Revisit Triggers

- A rider-side arrival or boarding signal becomes available and is accepted.
- Phase 5 needs a stored phase the neutral vocabulary cannot express.
- Freshness must be tracked per leg rather than for the current leg.
- A Phase 1 consumer needs equality, hashing, or encoding of state or events.
- Phase 6 persistence requires a different representation.

---

# DEC-064 — JourneyEngine Boundary Uses a Deferred Observation Type, Typed Input Rejections, and Reselection-Only Recovery Proposals

**Status:** Accepted\
**Date:** 2026-09-24\
**Related:** DEC-004, DEC-007, DEC-008, DEC-010, DEC-011, DEC-021, DEC-024, DEC-027, DEC-031, DEC-038, DEC-050, DEC-062, DEC-063; `RULES.md` Rule 4, Rule 11, Rule 38, Rule 45; `ARCHITECTURE.md` §4, §7, §10, §34, §35; `FEATURES.md` §4.12, §16; `ROADMAP.md` Phase 1, Phase 3, Phase 4, Phase 5, Phase 6, Phase 8

## Context

S6 is the Phase 1 protocol slice. DEC-050 lets Phase 1 define the `JourneyEngine` **boundary** — types, inputs, outputs — while Phase 5 owns its behaviour; DEC-063 assigned the recovery-proposal **shape** to S6. `ARCHITECTURE.md` §7 sketches the engine as `Journey + RealtimeSnapshot + Current Time + Optional Device Context → JourneyTransitionResult { updatedJourney, events, warnings, recoveryProposal }`. `DECISIONS.md` §4 left open whether `RouteSearching` is defined in Phase 1, to be settled before S6.

Constraints: `RealtimeSnapshot` does not exist and is Phase 4; location is optional (Rule 4); the engine must be deterministic and never read a clock (Rule 38, DEC-063 D); a result must never fabricate candidates or precision (DEC-038); and a rider whose action is refused must learn the specific reason, not a generic failure.

## Decision

### A. Route search is Phase 3

`RouteSearching`, `RouteCandidate`, and `TrainCandidate` are **not** defined in Phase 1. `ROADMAP.md` Phase 3 already includes `RouteSearching` and `RouteCandidate`; no Phase 1 consumer exists, the §10 candidate shape carries provider-dependent fields, and DEC-004 remains Provisional. The Phase 1 *Included* list and acceptance criteria never named them, so no acceptance criterion changes. This resolves the `DECISIONS.md` §4 disposition. `RealtimeTripProviding` (Phase 4), `TransferGuidanceProviding` (Phase 10), and `JourneyRepository` (Phase 6) likewise stay with their phases.

### B. The engine protocol

```text
protocol JourneyEngine<Observation>: Sendable
- associatedtype Observation: Sendable
- transition(from: ActiveJourney,
             input: JourneyEngineInput<Observation>,
             at now: Date) -> JourneyTransitionOutcome

JourneyEngineInput<Observation>          — enum
- observed(Observation)                  — realtime evidence; its type is supplied later
- timePassed                             — no new evidence; re-evaluate at `now`
- selectTrip(legIndex: Int, SelectedRailTrip)
- replaceTrip(legIndex: Int, SelectedRailTrip)
- end(UserEndReason)

UserEndReason                            — cancelledByUser | endedEarlyByUser
                                           (maps to the matching JourneyEndReason)
```

1. **Stable signature, deferred payload.** `Observation` is an associated type. **Phase 4** defines the concrete realtime observation (`RealtimeSnapshot` or a journey-scoped projection of it); **Phase 5** binds `typealias Observation = …` in its engine and implements `transition`. The protocol itself does not change. A scheduled-only test double may bind `Observation = Never`, which makes `observed` unrepresentable for it. `timePassed` is the only input available to scheduled guidance; it is not presented as the complete production input.
2. **Synchronous, pure, non-throwing.** The method never reads a clock — `now` is an input — never performs I/O, and is `Sendable` so callers run it off the main actor (DEC-027). All outcomes, including refusals, are values.
3. **No device context.** Location is optional (Rule 4) and has no contract; it is not an input.
4. **Ending is always a user command.** `end` takes a `UserEndReason`, so the engine-produced `trackingCompleted` cannot be requested.

### C. Outcomes and results

```text
JourneyTransitionOutcome                 — enum
- applied(JourneyTransitionResult)       — a valid result; next.state.asOf == now; may leave the Journey and phase unchanged
- rejected(JourneyInputRejection)

JourneyTransitionResult                  — value; failable
- previous          (ActiveJourney)
- next              (ActiveJourney)
- events            ([JourneyEvent])
- recoveryProposal  (JourneyRecoveryProposal?)
```

`JourneyTransitionResult(previous:next:events:recoveryProposal:)` fails unless:

1. `next.journey.id == previous.journey.id` — the engine cannot swap journeys;
2. `next.state.asOf >= previous.state.asOf` — time never runs backwards;
3. every event's `occurredAt` lies within `previous.state.asOf ... next.state.asOf`;
4. a recovery proposal is present **only** when `next.state.phase` is `interrupted` with the **same reason**; an interruption without a proposal is valid;
5. every leg index in the proposal is within `next.journey.legs` and names a **rail** leg.

Because the pair is an `ActiveJourney`, `next` is already consistent with its Journey (DEC-063 E). A conforming engine returns `.applied` only with a result built through this constructor and with **`next.state.asOf == now`**, the supplied instant. An applied result may be a **no-change** result: the Journey and the phase are unchanged — for example `timePassed` when nothing has changed — but `asOf` still advances to `now` whenever `now` is later. It is distinguishable from a refusal because a refusal is `.rejected`. If an engine cannot build a valid result for an input it did not reject, that is a Phase 5 defect for its tests, never a silent no-change and never a rejection.

### D. Input rejections

```text
JourneyInputRejection                    — enum
- clockBehindJourney(stateAsOf: Date, requestedAt: Date)
- journeyEnded
- legNotFound(legIndex: Int)
- walkingLegHasNoTrain(legIndex: Int)
- trainAlreadySelected(legIndex: Int)
- noTrainToReplace(legIndex: Int)
- trainStationsDiffer(legIndex: Int, legStations: RailLegAnchors, trainStations: RailLegAnchors)
- trainAlreadyInJourney(legIndex: Int, otherLegIndex: Int)
- notAllowedInCurrentPhase(currentPhase: JourneyPhase)
```

**Validation boundary.** S6 defines a pure function, `JourneyEngineInput.structuralRejection(against: ActiveJourney, at now: Date) -> JourneyInputRejection?`, that callers may use to pre-check a rider's action and that a conforming engine must apply first, returning `.rejected` with its result. It checks, in order:

| # | Check | Applies to | Rejection |
|---|---|---|---|
| 1 | `now < current.state.asOf` | **every** input, including `timePassed` and `observed` — never clamped, never an unchanged success | `clockBehindJourney` |
| 2 | the current phase is `ended` | **every** input, including `timePassed` and `observed` | `journeyEnded` |
| 3 | `legIndex` outside the legs | `selectTrip`, `replaceTrip` | `legNotFound` |
| 4 | the leg is a walking transfer | `selectTrip`, `replaceTrip` | `walkingLegHasNoTrain` |
| 5 | `selectTrip` on a selected leg / `replaceTrip` on an unselected leg | respectively | `trainAlreadySelected` / `noTrainToReplace` |
| 6 | the train's derived stations differ from the leg's (`RailLegAnchors.admits` is false) | `selectTrip`, `replaceTrip` | `trainStationsDiffer` |
| 7 | the Trip's `TripID` is already selected on **another** leg (DEC-062 E5); for `replaceTrip` the target leg's own current `TripID` is excluded, so re-selecting it (for example an updated snapshot) passes | `selectTrip`, `replaceTrip` | `trainAlreadyInJourney` |

After these, **Phase 5** decides every rule that depends on the current phase — for example replacing the train of a leg already completed — and reports it as `notAllowedInCurrentPhase(currentPhase:)`. If a phase-dependent refusal cannot be explained honestly from the phase alone, Phase 5 must add a specific case under §E rather than reuse it. `observed` and `timePassed` are never rejected except by checks 1 and 2; an observation that cannot be used degrades freshness instead (DEC-024, DEC-063 C). An ended Journey accepts no further input of any kind. **Provider-specific observation validation** — schema, identity join, feed age — belongs to Phase 4 / 5; if it ever needs a rejection, that case is added with its own mapping. `replaceTrip` with the leg's own current `TripID` (for example an updated snapshot) is not rejected by check 7; a `TripID` selected on any other leg is.

### E. User-facing rejection reasons

Every rejection case carries enough detail for Phase 8 to explain **the specific reason** the action failed and, where applicable, what the rider can do next. Phase 8 owns localized wording and presentation; the meanings below are binding, the phrasing is not. Riders never see enum names, dates in developer form, or diagnostics, and distinct causes are never collapsed into a generic "cannot select a train".

| Rejection | What the rider is told (meaning) | What the rider can do next |
|---|---|---|
| `clockBehindJourney` | The phone's time appears to be earlier than the journey's last update, so the journey cannot be updated reliably right now. | Check that the phone's date and time are set automatically, then try again. |
| `journeyEnded` | This journey has ended, so it can no longer be changed or updated. | Start a new journey. When the refused input was not a rider action (`timePassed`, `observed`), the rejection may be handled internally without any notification or message. |
| `legNotFound` | That part of the journey no longer exists, usually because the journey changed. | Reopen the journey and try again. |
| `walkingLegHasNoTrain` | This part of the journey is travelled on foot between stations, so no train can be chosen for it. | Choose a train for one of the rail parts instead. |
| `trainAlreadySelected` | A train is already chosen for this part of the journey. | Change the train instead of choosing a new one. |
| `noTrainToReplace` | No train has been chosen for this part yet, so there is nothing to change. | Choose a train for it. |
| `trainStationsDiffer` | This train does not run between the stations chosen for this part of the journey — Phase 8 names the mismatched **boarding** and/or **alighting** station, from `legStations` and `trainStations`. | Choose a train that boards and alights at the selected stations. Replanning is **not** presented as an in-app action under this contract; if no fitting train can be found, suggest only actions the app supports, such as ending the journey. |
| `trainAlreadyInJourney` | This train is already used for another part of this journey. | Choose a different train for this part. |
| `notAllowedInCurrentPhase` | This change is not possible at the journey's current stage (Phase 8 explains using the stage — for example that the train is already in progress). | Follow the options offered for the current stage, or end the journey. |

Every rejection case added later — by Phase 4 or Phase 5 — must be added together with its row in this mapping.

### F. Recovery proposals

```text
JourneyRecoveryProposal                  — value; failable
- reason                  (JourneyInterruptionReason)
- reselectableLegIndices  ([Int] — non-empty, ascending, unique, each >= 0)
```

A proposal identifies only **rail legs whose train selection can be reopened** for their unchanged stations. It promises that reopening selection is an **available action** — never that another train exists, can be caught, or fits. Presentation says "choose another train", never "another train is available". Ending the journey is **always** separately available (`FEATURES.md` §4.12) and is not listed. **Replanning is not offered** in Phase 1: it depends on route search (Phase 3) and on knowing where the rider is. If nothing is reselectable, there is no proposal, so an empty proposal cannot be represented. Whether an interruption deserves a proposal, and which legs it names, are Phase 5 decisions; acting on it is the Phase 6 `JourneyRecoveryCoordinator` and Phase 8 presentation.

### G. Conformances

All S6 types are `Sendable`. `UserEndReason` is `Equatable` (it has no payload). `JourneyInputRejection`, `JourneyTransitionOutcome`, `JourneyTransitionResult`, `JourneyEngineInput`, and `JourneyRecoveryProposal` add no `Equatable`, `Hashable`, `Codable`, or `Error` conformance: consumers pattern-match; nothing is compared, stored, encoded, or thrown. Persistence of any of them is Phase 6.

## Detailed invariants and their boundaries

| Invariant | Boundary |
|---|---|
| proposal legs non-empty, ascending, unique, `>= 0` | **S6 `JourneyRecoveryProposal` construction** |
| same `JourneyID`; `asOf` not backwards; events inside the window; proposal only with a matching interruption; proposal legs in range and rail | **S6 `JourneyTransitionResult` construction** |
| clock not behind; ended journey; leg exists; leg kind; selection state; stations preserved; `TripID` unique | **S6 `structuralRejection`**, applied by callers and required of the engine |
| `next.state.asOf == now` for applied results | **engine contract** (S6), implemented and tested in **Phase 5** |
| phase-dependent input rules | **Phase 5** |
| transitions, progression, detection, which legs to propose | **Phase 5** |
| realtime observation type and provider validation | **Phase 4 / 5** |
| rejection wording and localization | **Phase 8** |
| acting on proposals | **Phase 6** coordinator, **Phase 8** presentation |
| route search, replanning | **Phase 3** and later |

## Alternatives considered

- **Define `RouteSearching` now:** rejected — no Phase 1 consumer; Phase 3 already owns it.
- **A placeholder observation payload, or an `evaluate`-only input documented as complete:** rejected — invents a Phase 4 schema or misstates the production input.
- **Throwing on inapplicable input:** rejected — refusals are ordinary rider outcomes, and non-command inputs never throw.
- **Caller preconditions only:** rejected — cannot express phase-dependent refusals without trapping or silently ignoring the input.
- **Clamping a backward `now`:** rejected — would fabricate a time and hide a real device-clock problem.
- **A generic rejection ("cannot select a train"):** rejected — hides distinct, actionable causes.
- **Recovery options `replan` and `endJourney`:** rejected for Phase 1 — `replan` has no implementation before Phase 3; `endJourney` is always true and carries no information.
- **Keeping `warnings` and device context from the §7 sketch:** rejected — no vocabulary or consumer.

## Consequences

- `ARCHITECTURE.md` §7 replaces the conceptual sketch with this boundary; §10 notes that route search is Phase 3; §34 records `JourneyInputRejection` as a typed rejection value alongside `ActiveJourneyInconsistency`; §35 notes that the coordinator consumes reselection-only proposals.
- `DECISIONS.md` §4 records the `RouteSearching` disposition as resolved.
- `ROADMAP.md` gains Phase 1 Slice S6 and records the resolved task; a Phase 1 closure audit follows S6.

## Phase ownership

**Phase 1 (S6):** the protocol, inputs, outcomes, results, rejections with their user-facing mapping, structural checks, and proposals above. **Phase 3:** route search and replanning. **Phase 4:** the concrete observation and provider validation. **Phase 5:** the conforming engine, phase-dependent rules, transitions, and proposal content. **Phase 6:** the recovery coordinator and persistence. **Phase 8:** rejection and proposal wording and presentation.

## Explicit non-goals

No engine implementation or transition logic; no realtime schema or provider validation; no route search, candidate, or replanning; no device context; no persistence or encoding; no localized wording; no UI; no new canonical identifier; no new dependency. A test-only engine double is permitted; no production engine behaviour is added. This Decision does not mark S6 or Phase 1 complete.

## Implementation sequence

1. `UserEndReason`, `JourneyEngineInput`, and `JourneyInputRejection`.
2. `structuralRejection(against:at:)` with §D.
3. `JourneyRecoveryProposal` and `JourneyTransitionResult` with §C and §F.
4. `JourneyTransitionOutcome` and the `JourneyEngine` protocol, with a test-only double.
5. Independent review, then the S6 completion record and the Phase 1 closure audit.

S6 tests must cover, at minimum: every §D check producing exactly its rejection with the documented payload, in order (a backward `now` rejected for `timePassed`, `observed`, and every command; an ended journey rejecting every input, including `timePassed` and `observed`, with `journeyEnded`); valid inputs returning no rejection, including `replaceTrip` with the leg's own current `TripID`, while `selectTrip` or `replaceTrip` with a `TripID` selected on another leg is rejected with `trainAlreadyInJourney`; every §C constructor rule accepted and rejected; `JourneyRecoveryProposal` rejecting empty, unsorted, duplicate, and negative indices; a test-only engine with `Observation = Never` conforming, returning `.applied` for `timePassed` with the Journey and phase unchanged and `next.state.asOf == now` advanced, and `.rejected` for a structural failure, and crossing actor boundaries; and a check that every `JourneyInputRejection` case appears in the §E mapping (a switch-exhaustiveness test in Phase 1; wording is Phase 8).

## Revisit Triggers

- Phase 4 needs an observation rejection, or Phase 5 a phase-dependent case the stage cannot explain.
- Route search (Phase 3) makes replanning available as a recovery action.
- A consumer needs to compare, store, or encode outcomes or proposals.
- A rider-side signal (location or confirmation) is accepted as an engine input.

---

# DEC-065 — Phase 2 Uses a Category-Based Public-Repository Data Boundary and Starts with a Toei-Only Static GTFS Reader

**Status:** Accepted — after product and technical review, including the four P2-S1 reader policies in §D\
**Date:** 2026-09-25\
**Amended:** 2026-09-26 — §D narrowed after the P2-S1 implementation review: a repeated `stop_sequence` is invalid, while rows out of `stop_sequence` order in the file are unsupported; blank lines after the header and unread number notations are unsupported; and the additional rules found during implementation are recorded with their source (S, O, or P). The accepted reader policies are unchanged.\
**Related:** DEC-021, DEC-027, DEC-029, DEC-037, DEC-047, DEC-048, DEC-055 D5, DEC-059, DEC-060 §F, DEC-061 F; `RULES.md` Rule 9, Rule 14, Rule 34, Rule 40, Rule 42, Rule 53; `ARCHITECTURE.md` §4, §40; `ROADMAP.md` Phase 2; `PROVIDER_FEASIBILITY_AUDIT.md` §2.3, §3.5, §3.6.3, §3.11, §3.12, §6.1.3, §6.5, §6.8, §9 (DS-01, DS-03, DS-15)

## Context

Phase 2 (Static Railway Data + Canonical Mapping) begins after the Phase 1 closure (`ROADMAP.md` Phase 1 Completion Record). A read-only kickoff audit on 2026-09-25 found three things that must be settled before any Phase 2 code:

1. **The GitHub repository is public** (visibility `PUBLIC`, checked through the GitHub API on 2026-09-25). Every committed file is therefore released in a form any third party can reuse.
2. **The two launch providers publish under different regimes.** Toei data is CC BY 4.0: reproduction, adaptation, and redistribution are expressly allowed with attribution and a modification indication (audit §3.5.1–§3.5.2). Tokyo Metro data is under the ODPT Basic License, whose Art. 8(4)(1) prohibits releasing the data, duplicates of it, or derivatives from which all or most of it can be restored, in a third-party-reusable form, without prior written approval (audit §3.6.3). Whether non-restorable canonical data falls outside that prohibition was asked in the ODPT inquiry of 2026-09-19 (Q3) and is **unanswered** (audit §3.12).
3. **No rule yet classifies repository content by data category.** Existing practice is recorded in two places: DEC-048 records only aggregate results and named exceptions, does not record the 285-row mapping, and states that no raw provider data enters the repository; the audit (§2.3) states that the repository contains no provider payload. This Decision keeps both unchanged.

Offline **bundling** of normalized Basic-License static data in the shipped binary is a different question from committing data to the repository. It stays gated on the ODPT written confirmation (audit §3.11, §3.12 item 5; `ROADMAP.md` Phase 2 Implementation Tasks) and is **not** decided here.

## Decision

### A. Public-repository boundary by data category

| Category | Toei (CC BY 4.0) | Tokyo Metro (Basic License) | Status |
|---|---|---|---|
| **Source archives** (provider ZIPs or complete provider files) | Not committed. This follows project practice (audit §2.3), not a licence prohibition | Not committed (S2 Art. 8(4)(1)) | Decided |
| **Raw rows** copied from provider files | Not committed; P2-S1 fixtures are synthetic (§C). This keeps DEC-048's statement and audit §2.3 unchanged | Not committed | Decided |
| **Provider identifiers and names, individually** | May be cited in documentation | Values already cited as named exceptions in accepted documents (for example the line codes, 市ケ谷, 押上〈スカイツリー前〉, `MarunouchiBranch`) may continue to be cited that way | Decided for these uses |
| **Provider identifiers and names, in bulk** (lists or tables covering a line, a feed, or most of a feed) | Not committed by P2-S1. CC BY 4.0 would permit them with attribution; a later decision may allow specific artifacts | **Unresolved** — could approach a restorable duplicate; assessed per artifact and against the ODPT reply to Q3 | Toei: later decision. Tokyo Metro: unresolved |
| **Mapping records** (canonical identifier ↔ provider identifiers, codes, and names) | Decided with the canonical identifier format (a later decision) | **Unresolved** — neither automatically allowed nor automatically prohibited. Whether a given record set is a restorable derivative (Art. 8(4)(1)) depends on its content and coverage, and on the ODPT reply to Q3. Until an accepted decision resolves it, no Tokyo Metro-involving mapping record is committed, and none is placed on the Phase 2 branch | Unresolved |
| **Aggregate counts, hashes, field-presence facts** | Allowed | Allowed | Decided — existing practice (DEC-048, audit §2.3) |
| **Synthetic fixtures** (invented values in a provider's file shape) | Allowed; marked synthetic | Allowed only when the values are invented, never transcribed from Tokyo Metro rows; marked synthetic | Decided |
| **Project-owned code, documentation, and schemas** | Allowed. Must contain no credential, token, signed URL, local evidence path, or embedded provider dataset (Rule 42; audit §2.3) | Same | Decided |
| **Project-owned canonical data** (canonical identifiers, Korean names, search aliases) | Decided in a later slice | Decided in a later slice. Korean translation of Tokyo Metro strings stays pending the ODPT reply to Q4 | Unresolved — later |
| **Generated datasets** (importer output, build products) | Not committed; a later decision may classify specific artifacts | Not committed | Decided until a later decision |

Committing and bundling are separate: this table governs the repository only. Whether normalized Tokyo Metro static data may be bundled in the shipped binary remains the pending ODPT question (audit §3.12 item 5).

### B. P2-S1 scope — a Toei-only static GTFS reader

1. P2-S1 reads the **text content of individual GTFS tables** supplied by its caller — `agency`, `routes`, `trips`, `stops`, `stop_times`, `calendar`, `calendar_dates`, `feed_info`, and `translations` — into provider DTOs under `Data/GTFS/Static` (`ARCHITECTURE.md` §4, §4.3).
2. It creates **no** canonical identifier, mapping record, Domain value, search index, persistence, or `RailwayDataRepository`. Fare files are not read.
3. It performs **no** ZIP extraction, network access, or discovery of the owner-only evidence storage. Archive handling may need a dependency or a tooling choice (Rule 34), and where the Phase 2 pipeline runs is undecided; both are settled before P2-S2.
4. **Toei is the only provider.** No Tokyo Metro file, row, bulk identifier list, fixture, or mapping enters the branch while §A leaves its publication boundary unresolved.
5. Parsing and validation run off the main actor (Rule 14, DEC-027).
6. Provider fields such as `route_color`, `direction_id`, `pickup_type`, `drop_off_type`, and the time fields are carried as **DTO values checked only for syntax** (§D). No colour type or token (DEC-055 D5), passenger-stop inference (DEC-061 F), or timetable semantics (DEC-060 §F) is added.

### C. Fixtures and local validation

1. **All P2-S1 fixtures are synthetic:** invented values in GTFS file shape, marked synthetic. No real Toei row, and no bulk list of real Toei identifiers or names, is committed.
2. **Local validation against the real Toei archive is kept, and nothing from it is committed.** The reader may be run locally against the pinned Toei archive (SHA-256 `f10d03cd951565379e5c397cf9043d0db58b5030b670c29f7c56ac43fe3efbe2`) kept outside the repository, or against the Toei static archive read from its public, credential-free source (audit §2.3, B8). Only aggregate results are recorded: counts, hashes, and pass/fail. No archive, extracted file, row, or local path enters the repository.

### D. P2-S1 format contract

Checked against the GTFS Schedule Reference, revised 2026-04-27: first on gtfs.org (2026-09-25), then, for the P2-S1 rule audit (2026-09-26), against the reference's canonical source text (`google/transit`, `gtfs/spec/en/reference.md`, same revision). Three kinds of statement are kept apart:

- **Specification (S):** a GTFS requirement.
- **Observed Toei shape (O):** what the audit recorded for the pinned Toei archive (audit §6.1.3, §6.5, §6.8). This is evidence about one feed, not a GTFS rule.
- **Reader policy (P):** a TSUGINO choice for P2-S1.

Input that is valid GTFS but outside the observed Toei shape is reported as **unsupported** — a scoped limitation of this reader — and never as invalid GTFS. Where the specification fixes a value's text (an enumeration's constants, the time format), anything else is invalid. Where it does not fix the notation (an integer's sign, exponent notation in a decimal), a form the reader does not read is unsupported. A row in an unsupported shape is reported as soon as the shape is recognised, and the row's remaining fields are not checked. A repeated `stop_sequence` is checked across the whole table before row order, so it is always reported as invalid.

**Accepted:**

- (S) A byte-order mark: "Files that include the Unicode byte-order mark (BOM) character are acceptable." (P) The BOM never becomes part of the first field name.
- (S) CRLF or LF line endings: "Each line must end with a CRLF or LF linebreak character." (P) A final line without a terminator is also accepted.
- (S) Quoted fields: "Field values that contain quotation marks or commas must be enclosed within quotation marks. In addition, each quotation mark in the field value must be preceded with a quotation mark."
- (S) A first line naming the fields, with case-sensitive names. (P) Column order is taken from the header, columns the reader does not use are ignored, and values are kept exactly as written, without trimming.
- (S) `stop_sequence` values that increase along a trip without being consecutive: "The values must increase along the trip but do not need to be consecutive." A gap is valid.
- (S) Times as `HH:MM:SS` or `H:MM:SS`, including values past `24:00:00` for service after midnight.
- (S) Blank times where the specification makes them optional. `arrival_time` is required on a trip's first and last stop and on `timepoint = 1` rows; `departure_time` is required on `timepoint = 1` rows only. Both are optional otherwise.
- (O) Intermediate rows with `pickup_type = 1`, `drop_off_type = 1`, `timepoint = 0`, and blank times (540 rows in 73 trips; audit §6.8). They are parsed as given; what they mean is decided in a later slice (DEC-061 F).
- (S) A `translations` row for `feed_info` with neither `record_id` nor `field_value`.

**Rejected as invalid, with a typed error carrying table and line context:**

- (S) a table with no first line naming its fields — empty text, or a blank first line ("The first line of each file must contain field names") — or a header with an empty field name, such as a trailing comma;
- (S) a field value containing a tab, carriage return, or line feed ("Field values must not contain tabs, carriage returns or new lines");
- (S) a quotation mark in an unquoted value, or text after a closing quotation mark (the quoting rule above);
- (S) a missing required column;
- (S) a blank required value, including the conditionally required values of the shape read here: `stop_name`, `stop_lat`, and `stop_lon` for stops and stations; `route_long_name` when `route_short_name` is blank (and the reverse); `stop_id` in a `stop_times` row with no `location_group_id` or `location_id`; and `field_value` in a `translations` row that is not for `feed_info` and has no `record_id`;
- (S) a value the specification forbids: in a `translations` row without `record_id`, `field_value` or `record_sub_id` for `feed_info`, or `record_sub_id` together with `field_value`;
- (S) a duplicate `stop_id`, `route_id`, or `trip_id`;
- (S) an unresolved reference: `stop_times.trip_id` → `trips`; `trips.route_id` → `routes`; `trips.service_id` → `calendar` or `calendar_dates`; `stops.parent_station` → `stops`; `stop_times.stop_id` → a `stops` row whose `location_type` is 0 or empty ("Referenced locations must be stops/platforms");
- (S) a `parent_station` on a station row (`location_type = 1`), or a stop/platform `parent_station` that does not name a station;
- (S) a `stop_sequence` value repeated within one trip;
- (S) a blank `arrival_time` on a trip's first or last stop, or a blank `arrival_time` or `departure_time` on a `timepoint = 1` row;
- (S) a malformed time; an enumeration whose text is not one of the specification's constants — including `01` for `1`, a `route_type` outside `0`–`7`, `11`, and `12`, and a `translations.table_name` outside the reference's list; a negative or fractional value where a non-negative integer is required; or a latitude or longitude that is not a decimal number within its range. The reference defines no extended route types; codes such as `100` belong to a separate convention and are therefore invalid under this contract;
- (P) malformed CSV structure: an unterminated quoted field, a row whose field count differs from the header's, or a duplicated header name;
- (P) text that is not valid UTF-8. The specification says files *should* be UTF-8; this reader accepts only UTF-8, which is what the audit recorded for the Toei archive (O: 11 UTF-8 text members; audit §2.3, B8).

**Reported as unsupported (may be valid GTFS; outside this reader's scope):**

- (O) `stops` rows with `location_type` 2, 3, or 4, which a Pathways-style feed contains (audit §6.6) but the base Toei archive does not (149 rows, all `location_type` 0, no `parent_station`);
- (O) `stop_times` rows that use `location_group_id`, `location_id`, or pickup/drop-off windows instead of `stop_id`;
- (O) `translations` rows keyed by `record_id` (the Toei archive keys every row by `field_value`);
- (P) a trip whose `stop_times` rows appear out of `stop_sequence` order in the file. A trip's order is defined by `stop_sequence`, not by the position of its rows, and the specification does not require rows to be sorted, so such a feed may be valid. Reading rows in source order is a limitation of this reader;
- (P) a blank line after the header. The specification does not address blank lines;
- (P) a number in a form the specification does not fix and this reader does not read: a `+`-signed integer, an integer too large for the reader (the specification sets no upper bound), or a decimal in exponent notation;
- (P) a row with a blank time and no `timepoint` value. The specification says that when no timepoint values are provided, all times are considered exact; the Toei shape always marks blank-time rows `timepoint = 0` (O), so the reader does not guess.

Not checked by this reader, and not claimed: date and colour syntax (kept as provider text), `agency_id` requirements and references, uniqueness of `calendar.service_id`, when `feed_info` must be present, HTML or escape sequences in values, and the specification's recommendations (such as removing extra spaces). The reader reports the first problem it finds, in a fixed order.

### E. DEC-048 reconciliation target is preserved

The later cross-operator slice must **reproduce** DEC-048 from pinned inputs, never import it as seed data. The targets are: 141 + 144 = 285 input identities; 54 candidates, of which 27 are the same station, 26 distinct, and 1 explicitly ambiguous; 27 merged + 114 Toei-only + 117 Tokyo Metro-only = **258 proposed groups**; 0 duplicate assignments; 0 unmapped identities. The explicit exceptions stay as accepted:

- 市ヶ谷 / 市ケ谷 is one station, joined through an explicit, reversible orthographic alias, with both original strings preserved.
- 押上 / 押上〈スカイツリー前〉 is one station, joined through an explicit subtitle alias, with the provider string preserved.
- **Toei 新宿 and Tokyo Metro 新宿 remain two stations**: the relationship is `explicitly_ambiguous`, and no transfer edge is recorded.

No distance threshold enters the pipeline — the 320 m figure is analytical corroboration only. The analysis group keys are **not** production identifiers.

### F. Boundaries this Decision does not move

- **DEC-048** is unchanged, including its statement that no raw provider data enters the repository.
- **Timetable ownership.** DEC-060 §F defers scheduled times to a timetable contract that no phase currently owns, while Scheduled Journey Guidance (DEC-046, DEC-047) depends on it. This is recorded as an **open planning issue** in `ROADMAP.md` Phase 2. Phase 2 is **not** expanded to include it.
- **Line colour** stays governed by DEC-055 D5 and the pending ODPT Q5.
- **Tier 1 promotion** stays governed by DEC-058 §4 and DEC-059. No Tier 1 data is fetched and no capability is declared without separate authorization.
- **Physical-device measurement** stays under `AGENTS.md` §22: it needs explicit authorization, and `LunaTestphone` is never used.
- **Station search UI** stays in Phase 8 (`ROADMAP.md` Phase 8 Included). Phase 2 owns the local search index and API.

## Rationale

The public repository turns every commit into a release, so the licence boundary must be explicit before any data-shaped file exists. Classifying by category keeps the clear cases decided — archives and raw rows out, aggregates and synthetic fixtures in — while leaving Tokyo Metro mappings honestly unresolved, rather than forcing a guess in either direction before the ODPT reply. Synthetic-only fixtures let the reader be tested without committing provider data, while local runs against the real Toei archive still check it against reality. Separating specification rules from the observed Toei shape keeps a deliberately narrow reader from being mistaken for a GTFS validator.

## Consequences

- `ROADMAP.md` Phase 2 gains a slice plan with dependencies and completion criteria, and the timetable ownership gap as an open planning issue.
- P2-S1 can start; nothing else must be decided first.
- Tokyo Metro-involving mapping records stay off the branch until a later accepted decision resolves §A.
- `ARCHITECTURE.md` changes only when the decisions that shape architecture (pipeline location, storage, identifier format) are accepted.
- `PROVIDER_FEASIBILITY_AUDIT.md` is unchanged.

## Revisit Triggers

- The ODPT secretariat replies to Q2, Q3, or Q4.
- The repository's visibility changes.
- A provider's licence label or terms change.
- A later slice needs a data category that §A does not classify, or a feed shape that §D reports as unsupported.

---

## 3. Decision Maintenance Rules

### 3.1 Do Not Delete Important Old Decisions

If a significant decision changes:

- preserve it
- mark it `Superseded`
- reference the replacing decision

Example:

```text
DEC-004
Status: Superseded by DEC-052
```

---

### 3.2 Do Not Use DECISIONS.md for Tiny Implementation Details

Do not record decisions such as:

- variable naming
- local spacing adjustments
- one-off refactors
- obvious framework syntax

Record decisions that would matter to someone asking:

> “Why is the project built this way?”

---

### 3.3 Keep Current Documents Synchronized

A new accepted decision may require updates to:

- PRODUCT
- FEATURES
- DESIGN
- ARCHITECTURE
- ROADMAP
- RULES
- AGENTS

The decision record alone does not update project truth.

---

### 3.4 Rejected Decisions Can Be Valuable

When a meaningful alternative is considered and deliberately rejected, it may be recorded with `Rejected` status.

This prevents the same discarded idea from being repeatedly reconsidered without new evidence.

---

### 3.5 Decisions May Start Provisional

Some choices cannot be finalized until:

- API evaluation
- pricing
- physical-device tests
- provider contracts
- App Store behavior
- performance measurements

Use `Provisional` honestly rather than pretending certainty.

---

## 4. Current Open Decision Areas

The following areas are intentionally not fully locked yet.

### Route Search Provider

Candidates still require technical, licensing, and pricing evaluation.

**`RouteSearching` protocol disposition (2026-09-20, bounded and non-blocking):** whether the provider-neutral `RouteSearching` protocol (`ARCHITECTURE.md` §4, §10) is defined during Phase 1 is **not decided here**. It is **non-blocking for Phase 1 slices S1–S5** and must not delay branch creation or the canonical-identifier work. The inclusion-or-deferral decision is to be made **before S6**, when Phase 1 addresses domain protocols. **Live route-search integration remains Phase 3 regardless of that later decision**, and DEC-004 stays Provisional until a provider is selected. **Resolved by DEC-064:** `RouteSearching`, `RouteCandidate`, and `TrainCandidate` are **not** defined in Phase 1 and belong to Phase 3; DEC-004 is unchanged.

Related:
- DEC-004

### Static Rail Storage Format

Potential options include:

- SQLite
- compact binary
- generated indexed files
- compact JSON

Selection should follow prototype measurement.

Related:
- DEC-029

### Exact Realtime Refresh Cadence

Must depend on:

- provider rate limits
- journey phase
- background constraints
- measured battery impact

Related:
- DEC-025

### Light Mode

Dark-first is accepted, but whether light mode ships in the initial release remains open.

Related:
- DEC-017

### Automatic Train Detection

Not required for MVP.

It remains a future research area.

Related:
- DEC-007
- DEC-026
- DEC-040

### Exact Transfer Guidance Dataset

Car/door/exit guidance depends on future data-source evaluation.

Related:
- DEC-019
- DEC-037

### Nippori-Toneri Liner Capability Promotion

The Liner is in v1 scope in degraded mode (DEC-046). Promotion to trip-level realtime depends on future official Trip Update / Vehicle Position coverage and the evidence gates in DEC-046; Liner Alert/status payload semantics are still unverified.

Related:
- DEC-046
- DEC-022

### Tokyo Metro Capability Promotion

The nine Tokyo Metro lines launch in the Scheduled Journey Guidance tier (DEC-047). Promotion to Realtime Journey Tracking depends on an official Trip Update / Vehicle Position resource passing the DEC-046/DEC-047 evidence gates. The ODPT written inquiry on presentation boundaries is awaiting response.

Related:
- DEC-047
- DEC-046

### Device Location Assistance (research candidate — not accepted)

Candidate for later evaluation only: device location might assist boarding-station proximity, journey-start assistance, direction sanity checking, and destination-area arrival assistance. Constraints if ever evaluated: GPS/device location must not substitute for train realtime data or claim underground train position; underground accuracy is not assumed; journey guidance must continue to work when location permission is denied; no "Always" location authorization requirement is accepted; location permission, background behaviour, battery impact, privacy disclosure, and App Store implications require a separate technical/product decision. No implementation is authorized.

Related:
- DEC-026
- DEC-040
- DEC-047

---

## 5. Decision Quality Standard

A good TSUGINO decision should:

1. solve a real product or engineering problem,
2. name the tradeoff,
3. make ownership clearer,
4. preserve future changeability where reasonable,
5. reduce hidden coupling,
6. be testable when possible,
7. avoid claiming certainty where evidence is incomplete,
8. explain when the decision should be revisited.

The purpose of this document is not rigidity.

It is to make change **deliberate instead of accidental**.
