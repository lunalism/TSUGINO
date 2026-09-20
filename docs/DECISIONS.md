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
**Date:** 2026-09-16

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

**`RouteSearching` protocol disposition (2026-09-20, bounded and non-blocking):** whether the provider-neutral `RouteSearching` protocol (`ARCHITECTURE.md` §4, §10) is defined during Phase 1 is **not decided here**. It is **non-blocking for Phase 1 slices S1–S5** and must not delay branch creation or the canonical-identifier work. The inclusion-or-deferral decision is to be made **before S6**, when Phase 1 addresses domain protocols. **Live route-search integration remains Phase 3 regardless of that later decision**, and DEC-004 stays Provisional until a provider is selected.

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
