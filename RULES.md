# TSUGINO — RULES.md

## 1. Purpose

This document defines non-negotiable project rules for TSUGINO.

`RULES.md` is a living document. Rules may evolve when implementation reveals new constraints, but they must not be silently ignored.

If implementation conflicts with a rule:

1. identify the conflict,
2. determine whether the implementation or rule should change,
3. update the relevant living documents,
4. record a significant decision in `DECISIONS.md` when appropriate.

---

# Rule 1 — Privacy by Non-Collection

TSUGINO must not collect user identity or persistent movement history unless a future feature absolutely requires it and a new explicit product/architecture decision approves it.

The default privacy strategy is:

> **Do not collect what the product does not need.**

TSUGINO should prefer non-collection over collecting and later protecting unnecessary data.

### Prohibited by Default

Do not collect or centrally store:

- name
- email address
- phone number
- advertising identifier
- persistent device-level user identifier for profiling
- continuous location history
- long-term movement history
- complete travel history tied to a user identity
- behavioral profile built from travel patterns
- personally identifiable analytics

### External Provider Rule

TSUGINO must not send unnecessary user identity or personal data to:

- route providers
- realtime providers
- analytics providers
- crash providers
- other third parties

Only the minimum data required for the requested functionality may be sent.

### Privacy Review Trigger

Any future feature that proposes:

- account creation
- cloud sync
- server-side travel history
- persistent user identifiers
- personalized remote analytics
- location-history storage

requires:

1. explicit product review,
2. explicit privacy review,
3. a new `DECISIONS.md` entry,
4. updated `PRODUCT.md`, `FEATURES.md`, `ARCHITECTURE.md`, and `RULES.md` where relevant.

---

# Rule 2 — Local-Only Convenience Data Is Allowed

TSUGINO may store limited convenience data locally on the user's device.

Allowed local-only data includes:

- recent station searches
- recent journeys
- active Journey state
- app settings
- localization preference derived from system settings
- future favorites/pinned journeys

This data must not automatically become server-side analytics or profiling data.

### Recent Station Searches

Recent station searches are intentionally allowed because they improve convenience and may reflect stations the user frequently searches for.

Rules:

- stored on-device only
- not tied to a cloud account
- not sent to TSUGINO servers
- not combined with precise location history for profiling
- bounded in size
- user can clear the history
- deletion must remove the local records

### Recent Journeys

Recent journeys may be stored locally to speed up repeated route setup.

Rules:

- local-only by default
- no server synchronization in MVP
- no remote behavioral profile
- user can clear the records

---

# Rule 3 — Core Journey Tracking Must Not Require an Account

The MVP must be usable without:

- sign-up
- login
- email
- phone number
- social authentication

An account system may only be introduced later through an explicit decision.

---

# Rule 4 — Location Is Optional for Core Journey Tracking

Core journey tracking must not depend on continuous high-accuracy device location.

Location may be used for:

- nearby station suggestions
- optional consistency checks
- future automatic train detection research

If location permission is denied, the main route/train-selection/journey-tracking experience must remain usable where transit data permits.

Do not keep high-accuracy continuous location active without a clearly justified feature.

---

# Rule 5 — One Authoritative Journey State

The active Journey and derived `JourneyState` are the single source of truth.

The following may consume this state:

- main app
- Dynamic Island
- Lock Screen Live Activity
- notifications

They must not independently infer or mutate journey truth.

---

# Rule 6 — Views Must Not Own Railway Business Logic

SwiftUI views must not:

- calculate remaining stops
- determine current station from provider data
- infer transfers
- decide through-service continuity
- mutate Journey phase directly
- decode provider payloads
- perform route reconciliation

Business rules belong in Domain/Application components.

---

# Rule 7 — Animation Must Never Drive Journey Truth

Pixel animation may respond to Journey state.

Pixel animation must never:

- advance the current station
- change remaining stop count
- trigger a transfer state
- mark arrival
- alter selected Trip

Rule:

> **Animation follows Journey State. Journey State never follows animation timing.**

---

# Rule 8 — Provider Models Must Not Leak Into Domain or UI

External provider DTOs must remain inside Data integrations.

Required flow:

```text
Provider Response
→ DTO
→ Adapter / Mapper
→ TSUGINO Canonical Model
```

Do not pass:

- ODPT DTOs
- GTFS protobuf models
- Jorudan/NAVITIME/Ekispert raw models

into Domain or feature views.

---

# Rule 9 — Provider IDs Are Not Canonical Product IDs

Use TSUGINO-owned IDs for:

- Station
- Line
- Operator
- Trip
- Journey

Provider identifiers are mappings only.

Do not build product identity around one provider's ID scheme.

---

# Rule 10 — Capability Checks, Not Provider-Name Branching

Do not write feature logic like:

```text
if operator == TokyoMetro
```

when the real requirement is:

```text
if capabilities.supportsVehiclePosition
```

or:

```text
if capabilities.supportsRecommendedCar
```

Features should depend on capabilities, not provider names.

---

# Rule 11 — Unsupported Precision Must Never Be Invented

TSUGINO must not display certainty that the data does not support.

Examples:

- stale data must not be labeled live
- schedule fallback must not look realtime
- approximate pixel progress must not look like exact GPS position
- uncertain current station must not be shown as confirmed
- missing door/car guidance must not be guessed

When confidence is insufficient, omit or downgrade the information.

---

# Rule 12 — Realtime Freshness Must Be Explicit

Every realtime source must support freshness evaluation.

Track where possible:

- generated timestamp
- fetched timestamp
- last successful update
- stale threshold
- provider failure state

Do not keep displaying old realtime data as current.

---

# Rule 13 — Polling Has One Lifecycle Owner

Individual screens must not create their own realtime polling timers.

Polling/refresh cadence must be owned centrally.

Requirements:

- cancellable tasks
- no duplicate requests
- provider rate limits respected
- polling stops when no longer needed
- journey phase can influence cadence

---

# Rule 14 — Heavy Work Stays Off the Main Actor

Do not perform the following on the main actor:

- large GTFS parsing
- GTFS-RT protobuf decoding
- large JSON normalization
- heavy route reconciliation
- file IO
- large persistence fetches
- static rail-data preprocessing

Main actor is for:

- UI state publication
- lightweight presentation transforms
- user interaction

---

# Rule 15 — Static Railway Data Must Not Be Reprocessed Repeatedly

Where licensing permits:

- preprocess
- index
- cache
- version

static railway data.

Do not repeatedly decode the full railway dataset during normal screen navigation.

---

# Rule 16 — Through Service Is Not Automatically a Transfer

A change in:

- line name
- operator
- route identifier

does not necessarily mean the passenger transfers.

Through-running services must preserve physical train continuity.

---

# Rule 17 — Every Rail Leg Can Own Its Selected Trip

For multi-leg journeys:

- each rail leg may have its own selected Trip
- later Trips may be confirmed near transfer time
- changing one Trip should not rebuild the whole Journey unnecessarily

---

# Rule 18 — Explicit Train Selection Is Core MVP Behavior

Before active tracking of a rail leg begins, the user explicitly selects/accepts the train they intend to board.

Automatic train detection is not required for MVP reliability.

---

# Rule 19 — Recovery Is Part of the Product, Not an Edge Case

The architecture and UI must support recovery for:

- missed train
- wrong train
- wrong direction
- cancelled train
- changed destination
- large delay
- stale realtime
- provider outage
- corrupted persisted Journey

Do not design the happy path as the only supported path.

---

# Rule 20 — Active Journey Must Be Persistable and Recoverable

The active Journey must survive normal app lifecycle interruption where technically possible.

Persistence must support:

- reopen
- reconciliation
- schema versioning
- safe invalid-state handling

Transient animation state must not be persisted as Journey truth.

---

# Rule 21 — Live Activity Does Not Own Business Logic

Live Activity receives a compact derived presentation state.

It must not:

- decode realtime feeds
- calculate remaining stops
- reconcile Trips
- own persistence
- run independent journey logic

---

# Rule 22 — Dynamic Island Prioritizes Information

Dynamic Island should prioritize:

- next station
- remaining stops
- transfer
- destination
- departure/arrival timing

Decorative pixel elements are secondary.

Do not add continuous decorative animation.

---

# Rule 23 — Lock Screen Progress Is Approximate Journey Progress

A pixel train on Lock Screen may represent progress between origin and destination.

It must be driven by trusted Journey progression and must not imply exact physical train location.

---

# Rule 24 — Main App May Animate Continuously, System Surfaces Should Not Depend on It

Main app may use:

- scrolling tunnel lights
- moving skyline
- track motion
- station transitions

Lock Screen and Dynamic Island must remain useful in static form.

---

# Rule 25 — Localization Resolution Is Centralized

Effective UI language:

- Japanese (`ja-*`) → Japanese
- Korean (`ko-*`) → Korean
- all other languages → English

Views must not implement ad-hoc fallback logic.

Use one centralized language resolver.

---

# Rule 26 — Canonical Railway Names Must Support JP / EN / KO

Station, line, and operator names should have canonical localized representations where needed.

Provider localization is an input, not the sole source of truth.

Equivalent names must resolve to the same canonical entity.

Example:

```text
新宿
Shinjuku
신주쿠
→ same StationID
```

---

# Rule 27 — No Critical Information Through Color Alone

Critical states must not depend only on color.

This includes:

- delay
- cancellation
- next station
- selected train
- transfer
- error state

Use text, icons, shapes, or labels as well.

---

# Rule 28 — Pixel Fonts Are Not for Critical Transit Information

Pixel fonts may appear in:

- decorative signs
- environmental art
- non-critical visual details

Do not use pixel fonts for:

- station names
- ETA
- transfer guidance
- errors
- remaining stops

---

# Rule 29 — Performance Must Be Measured Before Invasive Optimization

Optimization order:

1. correct ownership
2. correct algorithm
3. avoid unnecessary work
4. profile
5. optimize measured bottlenecks

Do not distort architecture for speculative micro-optimizations.

---

# Rule 30 — Physical Device Validation Is Mandatory for Device-Sensitive Features

The following require real-device validation:

- Dynamic Island
- Live Activity
- background behavior
- notifications
- animation performance
- battery/thermal impact
- location behavior

Simulator-only success is not sufficient.

---

# Rule 31 — Japan Field Testing Must Not Be the Only Test Strategy

Core behavior must be reproducible from Korea using:

- deterministic unit tests
- recorded journey fixtures
- Replay Realtime Provider
- accelerated Clock
- network failure simulation
- location simulation where relevant
- remote TestFlight feedback

Tokyo field testing is final real-world validation, not the only way to reproduce bugs.

---

# Rule 32 — Serious Journey Bugs Should Become Regression Fixtures

When practical, a serious production/field bug should produce:

1. diagnostic evidence
2. reproducible fixture
3. regression test
4. fix

Do not rely only on manual verification.

---

# Rule 33 — Logs Must Be Structured and Privacy-Safe

Logs may contain:

- internal opaque IDs
- Journey state transitions
- provider status
- freshness
- errors
- performance metrics

Logs must not unnecessarily contain:

- personal identity
- precise long-term location history
- full user movement history

---

# Rule 34 — Third-Party Dependencies Must Be Justified

Prefer:

- Apple frameworks
- small, focused dependencies
- replaceable provider integrations

Avoid deeply coupling Domain to third-party SDKs.

Each significant dependency must have a clear reason.

---

# Rule 35 — Shared/Utilities Must Not Become a Dumping Ground

If code contains product/business meaning, it probably does not belong in `Shared/Utilities`.

Place code according to ownership:

- Domain
- Application
- Data
- Feature
- DesignSystem

---

# Rule 36 — Folder Ownership Must Be Preserved

Respect the canonical project structure in `ARCHITECTURE.md`.

Do not move code across layers merely for convenience.

If a new boundary is better, intentionally update the architecture and documents.

---

# Rule 37 — Tests Follow Ownership

Examples:

- JourneyEngine → DomainTests
- provider adapters → DataTests
- Live Activity mapper → LiveActivityTests
- feature presentation → FeatureTests

Do not hide domain behavior inside UI tests.

---

# Rule 38 — Deterministic Time Is Required in Domain Logic

Domain code must use the injected Clock abstraction.

Do not scatter direct system-time calls through journey logic.

This is required for:

- departure tests
- delay tests
- stale-feed tests
- accelerated replay
- deterministic fixtures

---

# Rule 39 — Schema Changes Require Migration Thinking

Persisted:

- Active Journey
- recent journeys
- rail data versions
- provider mappings

must not be silently reinterpreted after schema changes.

Use explicit versioning/migration or safe invalidation.

---

# Rule 40 — Data Licensing Must Be Verified Before Production Use

Every production dataset/provider must have recorded:

- owner
- license
- commercial-use rules
- caching rules
- redistribution rules
- attribution
- expiration
- challenge-only limitations

Experimental access must not silently become a release dependency.

---

# Rule 41 — Feature Flags Need an Exit Plan

Feature flags may be used for risky or incomplete features.

Each flag should have:

- purpose
- owner
- expected removal/decision condition

Do not accumulate permanent abandoned flags.

---

# Rule 42 — Secrets and Provider Keys Must Not Be Hard-Coded

API keys, secrets, and environment endpoints must not be embedded in:

- SwiftUI views
- Domain models
- committed source literals where unsafe

Use appropriate configuration and secure handling.

---

# Rule 43 — No Silent Documentation Drift

The following are living documents:

- `PRODUCT.md`
- `FEATURES.md`
- `DESIGN.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `ROADMAP.md`
- `RULES.md`
- `AGENTS.md`

A completed phase must not knowingly leave material implementation/document disagreement.

---

# Rule 44 — Significant Changes Must Preserve Decision History

If a major decision changes:

- do not erase the old decision
- mark it `Superseded`
- add a new decision
- update current-truth documents

`DECISIONS.md` preserves why the project changed.

---

# Rule 45 — Do Not Expand Phase Scope Silently

If work belongs to a later phase, do not implement it casually in the current phase.

If moving it earlier is genuinely necessary:

- explain why
- update ROADMAP
- update related documents
- record a significant decision where needed

---

# Rule 46 — A Phase Is Not Complete Because It Builds

Phase completion requires:

- scope satisfied
- tests passing
- relevant physical-device tests passing
- documentation current
- architecture audit passed
- known blockers resolved or intentionally deferred

---

# Rule 47 — Correctness Beats Visual Polish

When forced to choose between:

- accurate journey state
- prettier animation

choose accurate journey state.

When forced to choose between:

- honest degraded state
- impressive but unsupported precision

choose the honest degraded state.

---

# Rule 48 — Reliability Beats Feature Count

Do not add more operators, regions, or guidance types faster than they can be supported reliably.

A smaller trustworthy Tokyo scope is better than broad unreliable coverage.

---

# Rule 49 — User Convenience Must Not Become Hidden Profiling

Features such as:

- recent stations
- recent journeys
- future favorites

may improve convenience locally.

They must not silently evolve into remote behavioral profiling.

Any such change requires explicit review and documentation.

---

# Rule 50 — Product Trust Is the Final Constraint

Every technical and design decision should preserve this user expectation:

> **TSUGINO shows what it actually knows, clearly and calmly.**

If the app does not know, it should say less rather than pretend to know more.


# Rule 51 — v1 Is iPhone-Only

TSUGINO v1 must support iPhone only.

Do not add:

- iPad target support
- iPad-specific layouts
- iPad multitasking behavior
- split-view tablet navigation
- tablet-only QA requirements

Do not keep iPad enabled in release configuration merely because the app can technically launch on iPad.

Future iPad support requires an explicit new product decision.

---

# Rule 52 — Release Configuration Must Match Product Scope

Before release, verify that supported device families match the current product decision.

For v1:

> **Supported: iPhone**  
> **Not supported: iPad**

A release must not accidentally advertise support for an untested device family.
