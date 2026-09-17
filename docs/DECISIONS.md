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
