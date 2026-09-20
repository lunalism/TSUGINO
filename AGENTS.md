# TSUGINO — AGENTS.md

## 1. Purpose

This document defines how coding agents work inside the TSUGINO project.

The primary supported coding agents are:

- **OpenAI Codex**
- **Claude Code**

Both agents must follow the same project rules, architecture boundaries, phase scope, testing standards, and documentation requirements.

The tool may change.  
The project contract must not.

---

## 2. Core Principle

Every coding agent must optimize for:

1. correctness,
2. maintainability,
3. testability,
4. architectural clarity,
5. reproducibility,
6. safe incremental progress.

The objective is not to produce the most code quickly.

The objective is to move the current roadmap phase forward without weakening future phases.

---

## 3. Required Reading Order

Before substantial implementation work, the agent must read the current project documents in this order:

1. `PRODUCT.md`
2. `FEATURES.md`
3. `DESIGN.md`
4. `ARCHITECTURE.md`
5. `DECISIONS.md`
6. `ROADMAP.md`
7. `RULES.md`
8. `AGENTS.md`

Why this order:

- `PRODUCT.md` explains what TSUGINO is.
- `FEATURES.md` defines what it should do.
- `DESIGN.md` defines how it should behave and feel.
- `ARCHITECTURE.md` defines how it should be built.
- `DECISIONS.md` explains why important choices exist.
- `ROADMAP.md` defines what should be built now.
- `RULES.md` defines what must never be violated.
- `AGENTS.md` defines how the coding agent should execute the work.

The agent must not rely on stale assumptions from an earlier chat or session when current repository documents are available.

---

## 4. Current Phase Is the Scope Boundary

Before writing code, identify the active roadmap phase.

The agent must clearly understand:

- phase goal
- included work
- explicitly excluded work
- acceptance criteria
- exit criteria
- required tests
- required physical-device validation

Do not silently implement later-phase features.

If a later-phase change appears necessary:

1. explain why,
2. inspect whether the roadmap should change,
3. update the relevant documents if approved,
4. then implement.

---


## 5.1 Anti-Drift Protocol

TSUGINO must actively prevent coding agents from drifting into unrelated work.

Before substantial work begins, the agent must perform a **Scope Lock**.

The Scope Lock must identify:

- current roadmap phase
- exact task goal
- files or subsystems expected to change
- explicit non-goals
- relevant acceptance criteria
- relevant tests
- whether documentation updates are expected

Example:

```text
Phase: 4 — Realtime Provider Integration
Goal: normalize GTFS-RT Trip Updates
In scope:
- GTFS-RT DTO
- adapter
- canonical realtime snapshot
- fixture tests

Out of scope:
- UI polish
- automatic train detection
- transfer guidance
- unrelated refactors
```

The agent should not begin implementation until the current scope is clear.

### Drift Check

During implementation, the agent must pause and re-check scope before doing any of the following:

- adding a new feature
- adding a new third-party dependency
- creating a new provider integration
- changing architecture boundaries
- performing a broad refactor
- modifying unrelated screens
- changing persistence schema beyond the task need
- changing product behavior not required by the current phase

The default question is:

> **Is this required to satisfy the current task or phase acceptance criteria?**

If the answer is no, do not implement it without explicit approval.

### No "Improve While Here"

Do not expand a focused change merely because nearby code could also be improved.

Examples of prohibited behavior:

- fixing one Journey bug and redesigning the entire state machine
- touching one screen and restyling unrelated screens
- adding a provider abstraction for a provider not yet needed
- changing all repositories while fixing one persistence defect
- adding optional analytics while working on logging

A small local cleanup directly required for the change is allowed.

Unrelated improvement is not.

### Opportunistic Feature Ban

A good idea discovered during implementation is not automatically current work.

If it is not required now:

1. do not implement it,
2. record it as deferred work,
3. continue the current task.

### Parking Lot

Deferred ideas should be recorded in one controlled place rather than implemented immediately.

Preferred location:

- a `Parking Lot / Deferred` section in `ROADMAP.md`

If a dedicated `PARKING_LOT.md` is later introduced, that change should be reflected in project documentation.

A parking-lot item should include:

- short title
- why it may be useful
- which future phase may own it
- whether it requires a decision record

The parking lot is not permission to implement the idea.

### Phase Expansion Requires Approval

If the agent believes the current phase must expand to succeed:

1. stop implementation at the boundary,
2. explain why the phase is insufficient,
3. identify affected documents,
4. propose the smallest scope change,
5. wait for explicit approval before expanding the phase.

Do not silently reinterpret the roadmap.

### Drift Audit Before Completion

Before declaring a substantial task or phase complete, the agent must perform a drift audit:

- Did we implement anything not required by the task?
- Did we touch unrelated files?
- Did we introduce architecture changes without documenting them?
- Did we add a dependency that was not necessary?
- Did we move a future-phase feature into the current phase?
- Did any cleanup become a hidden refactor?
- Does the final diff still match the original Scope Lock?

If drift occurred unintentionally, remove or isolate it before completion unless explicitly approved.

### Anti-Drift Completion Rule

A task is not considered cleanly complete if it satisfies the feature request but also introduces unrelated scope.

The preferred result is:

> **the smallest coherent change that fully satisfies the current phase.**


## 5.2 Platform Scope Lock

For TSUGINO v1, the platform boundary is:

> **iPhone only.**

Coding agents must not:

- add iPad support
- introduce iPad-specific layouts
- add split-view tablet behavior
- broaden supported device families
- preserve tablet compatibility as hidden extra scope

If an implementation change would add iPad support, stop and request explicit approval.

iPad is a future-major-version consideration, not a v1 compatibility target.

---

## 5. No Silent Scope Expansion

Examples of prohibited scope expansion:

- adding automatic train detection during a static-data phase
- adding cloud sync because persistence code is already being touched
- adding a new provider because the adapter folder already exists
- redesigning unrelated screens while fixing one journey-state bug
- introducing an account system for convenience
- adding new analytics without explicit approval

Small refactors directly necessary for the current task are allowed.

Feature expansion is not.

---

## 6. Architecture Must Be Followed

The canonical project structure and dependency direction are defined in `ARCHITECTURE.md`.

The agent must preserve:

- Domain ownership
- Application orchestration
- Data/provider isolation
- Feature presentation boundaries
- DesignSystem independence
- LiveActivity separation
- Shared-folder discipline

Do not introduce shortcuts that violate architectural ownership merely to make one task easier.

---

## 7. Domain Is Protected

The Domain layer must remain independent from:

- SwiftUI
- ActivityKit
- concrete provider SDKs
- concrete network clients
- feature-specific UI state

The agent must not place provider-specific branching inside Domain unless the branch represents a true domain capability rather than a provider identity.

Bad:

```swift
if operatorID == .tokyoMetro {
    ...
}
```

Better:

```swift
if capabilities.supportsVehiclePosition {
    ...
}
```

---

## 8. One Source of Journey Truth

The agent must preserve the rule that active Journey state is authoritative.

Do not create separate competing journey logic in:

- SwiftUI views
- Dynamic Island
- Live Activity
- notifications
- pixel animation code

All surfaces must derive from the same Journey truth.

---

## 9. Animation Must Never Mutate Journey Truth

This is a hard rule.

Animation may respond to:

- current station
- next station
- journey phase
- progress

Animation must never decide:

- station arrival
- stop count
- transfer state
- journey completion
- selected Trip

If visual timing and realtime state disagree, realtime/domain state wins.

---

## 10. Provider Boundary Rule

Every provider integration should follow the pattern:

```text
Client
→ DTO
→ Adapter / Mapper
→ Canonical TSUGINO Model
```

Provider response models must not leak into:

- Domain
- feature views
- Live Activity
- notification logic

If provider payloads change, prefer containing changes inside Data.

---

## 11. Canonical ID Rule

Use TSUGINO-owned canonical IDs for product identity.

Examples:

- `StationID`
- `LineID`
- `OperatorID`
- `TripID`
- `JourneyID`

Provider IDs are aliases/mappings only.

Do not make a provider's raw ID the permanent identity of a core entity.

---

## 12. Privacy Is Non-Negotiable

The agent must follow Privacy by Non-Collection.

Do not add collection or remote storage of:

- name
- email
- phone number
- advertising identifier
- long-term location history
- server-side travel history
- behavioral movement profile

without an explicit new decision and document update.

Allowed local-only convenience data includes:

- recent station searches
- recent journeys
- active Journey
- settings
- future favorites

Do not silently upload this local convenience data.

---

## 13. Local Recent Search Behavior

Recent station search history is intentionally allowed.

Implementation requirements:

- local-only by default
- bounded storage
- clearable by the user
- no account binding
- no hidden server sync
- no behavioral profiling

The agent should preserve this distinction when implementing persistence.

---

## 14. Language Resolution Rule

The effective display language must follow:

- Japanese device/app language → Japanese
- Korean device/app language → Korean
- every other language → English

Do not implement ad-hoc locale fallback inside individual views.

Use the centralized language/localization architecture.

Station/line/operator localized names should resolve through canonical localization data.

---

## 15. Realtime Honesty Rule

Never present unsupported precision.

The agent must preserve states such as:

- live
- stale
- schedule fallback
- unavailable

Do not:

- label stale data as live
- show approximate train position as exact GPS position
- guess missing recommended car/door data
- invent current station certainty

When data is uncertain, the UI should say less.

---

## 16. Centralized Realtime Refresh

Views must not own provider polling loops.

Realtime refresh must remain centrally controlled.

All long-running realtime tasks require:

- lifecycle ownership
- cancellation
- error handling
- freshness semantics
- rate-limit awareness

---

## 17. Main-Actor Discipline

The agent must keep heavy work off the main actor.

Do not perform large:

- GTFS parsing
- GTFS-RT decoding
- JSON normalization
- file IO
- static-data indexing
- route reconciliation

on the main actor.

The main actor should remain focused on:

- UI updates
- lightweight presentation state
- user interactions

---

## 18. Performance Rule

Do not prematurely micro-optimize.

Preferred order:

1. correct ownership
2. correct algorithm
3. avoid unnecessary work
4. profile
5. optimize measured bottlenecks

When performance work is requested, gather evidence first where practical.

---

## 19. Testing Is Part of Implementation

A task is not complete simply because code compiles.

For behavior changes, the agent should add or update tests in the same task.

Prioritize:

- Domain unit tests
- provider adapter fixture tests
- persistence tests
- recovery tests
- Live Activity state-mapping tests
- localization layout tests where appropriate

---

## 20. Journey Bugs Require Regression Coverage

When fixing a serious Journey bug:

1. reproduce the issue if possible,
2. create or update a fixture,
3. add a regression test,
4. fix the issue,
5. run the relevant suite,
6. update docs if product truth changed.

Avoid one-off fixes that cannot be reproduced later.

---

## 21. Replay and Simulation Are First-Class Tools

Do not design TSUGINO so Japanese field testing is the only validation method.

Use:

- deterministic Clock
- Replay Realtime Provider
- recorded GTFS/GTFS-RT fixtures
- accelerated simulation
- network failure simulation
- location simulation
- structured diagnostics

The same domain path should be exercised by both live and replay data where possible.

---

## 22. Physical Device Validation

For phases involving device-sensitive features, the agent must test on a real supported iPhone when the environment permits.

Required areas include:

- Dynamic Island
- Live Activity
- background behavior
- notifications
- animation performance
- location
- battery/thermal behavior

Simulator success alone is insufficient for these features.

### Simulator-First Development Workflow (operational rule)

- Routine TSUGINO development, builds, tests, installs, launches, and runtime validation use an iPhone Simulator by default, selected with an explicit Simulator destination (never a generic device destination).
- Do not discover, select, build for, install to, launch on, inspect, or otherwise interact with a connected physical iPhone or iPad unless the user explicitly authorizes a specific physical-device step.
- The physical device `LunaTestphone` is reserved for another app project and must not be touched by TSUGINO work.
- This is a development workflow rule, not an app capability restriction: do not add runtime hardware detection and do not remove iPhone device support, signing, entitlements, or supported platforms because of it.
- The historical physical iPhone 12 validation record remains valid (Dynamic Island was N/A on that hardware, never a failure). **Physical Dynamic Island validation is complete** — validated on a Dynamic Island-capable iPhone on 2026-09-20 (`PHASE_0_SCOPE_LOCK.md` §6.5); AC5 is **PASS**. The simulator-first default and the explicit-authorization requirement for any further physical-device step both stay in force.

---

## 23. Build and Test Discipline

Before declaring a task complete, run the smallest relevant verification set.

Depending on task:

- targeted unit tests
- relevant module tests
- full test suite
- app build
- extension build
- physical-device build/install

Do not repeatedly run expensive global checks when targeted checks are sufficient during iteration.

Before phase completion, run the full required phase audit.

---

## 24. Phase Audit

Before closing a phase, the agent must perform or report:

1. scope audit
2. architecture audit
3. tests
4. build status
5. documentation audit
6. working tree status
7. physical-device validation if required
8. known findings
9. phase exit criteria

Do not report a phase as complete while known blockers remain unresolved unless the roadmap explicitly permits deferral.

---

## 25. Documentation Is Part of the Change

All project documents are living documents.

When implementation materially changes current truth, update the relevant document.

Examples:

Architecture changed:
- update `ARCHITECTURE.md`
- update `DECISIONS.md` if significant

Feature changed:
- update `FEATURES.md`
- update `PRODUCT.md` if product boundary changed
- update `ROADMAP.md` if phase scope changed

Design changed:
- update `DESIGN.md`

New hard rule:
- update `RULES.md`

Agent workflow changed:
- update `AGENTS.md`

Do not leave known stale documentation after completing a phase.

---

## 26. DECISIONS.md Is Historical

Do not erase important old decisions.

If an accepted decision changes:

1. mark the old record `Superseded`,
2. create a new decision,
3. explain why,
4. update current-truth documents.

This preserves historical reasoning while allowing the project to evolve.

---

## 27. Git Discipline

Before editing:

- inspect current branch
- inspect working tree
- understand uncommitted changes

Do not overwrite unrelated user work.

Do not discard changes unless explicitly instructed.

Before commit:

- review diff
- verify intended files only
- run required tests
- ensure documentation is current

Commit messages should be descriptive and phase-relevant.

---

## 28. Branch Discipline

When the project uses phase branches, prefer:

```text
phase/<number>-<name>
```

Example:

```text
phase/04-realtime
```

Do not create unnecessary nested branch strategies unless the project explicitly changes workflow.

Merge method should follow the current project convention.

---

## 29. Small, Reviewable Changes

Prefer focused commits and coherent change sets.

Avoid mixing:

- provider integration
- unrelated design refactor
- localization changes
- persistence migration

in one change unless they are inseparable.

This improves debugging and rollback.

---

## 30. Refactoring Rule

Refactoring is allowed when it:

- reduces coupling
- improves ownership
- removes duplication
- improves testability
- enables the current phase

Large unrelated refactors should be deferred.

Do not refactor only because a different style is preferred.

---

## 31. New Dependencies Require Justification

Before adding a third-party package, evaluate:

- necessity
- maintenance quality
- license
- binary size
- privacy impact
- replacement cost
- platform-native alternative

Do not add dependencies casually.

---

## 32. Data Licensing Rule

Do not integrate a dataset into production code without understanding its license status.

Record:

- provider
- license
- commercial-use constraints
- attribution
- caching
- redistribution
- expiration/challenge restrictions

Experimental data must remain clearly experimental.

---

## 33. Provider Capability Declaration

When adding an operator/provider, declare supported capabilities.

Examples:

- static schedule
- Trip Updates
- Vehicle Position
- alerts
- platform
- recommended car
- recommended door
- exit guidance

Do not scatter provider-specific feature assumptions throughout the codebase.

---

## 34. Graceful Degradation

The agent must implement explicit degraded modes where relevant.

Possible states:

- full realtime
- partial realtime
- schedule fallback
- no car guidance
- no door guidance
- route provider temporarily unavailable

Do not crash or invent data because one optional provider capability is missing.

---

## 35. Error Handling

Use typed errors and explicit recovery paths.

Do not surface raw provider errors directly to users.

Separate:

- developer diagnostics
- recoverability
- user-safe messaging

Unexpected conditions should be logged with useful context.

---

## 36. Structured Logging

Use structured logging categories such as:

- routing
- realtime
- journey
- persistence
- recovery
- Live Activity
- notification
- performance

Logs must remain privacy-safe.

Avoid logging unnecessary location history or user-identifying data.

---

## 37. Debug Diagnostics

For difficult journey bugs, debug/test builds should be able to expose a diagnostic snapshot.

Possible contents:

- Journey ID
- current phase
- current leg
- selected Trip
- current/next station
- realtime freshness
- provider
- last transition
- recovery state

Do not include unnecessary personal data.

---

## 38. No Fake Production Behavior

Debug helpers are allowed.

Examples:

- Journey Simulator
- Replay Provider
- accelerated Clock
- mock location
- fake delay scenarios

They must remain clearly isolated from production behavior and must not accidentally activate in release builds.

---

## 39. UI Testing Rule

Do not encode railway business correctness only in UI tests.

UI tests are appropriate for:

- critical flows
- navigation
- language presentation
- Live Activity integration where feasible

Domain correctness belongs in deterministic lower-level tests.

---

## 40. Localization Testing

For user-facing changes, consider:

- Japanese
- Korean
- English fallback

Test long labels and constrained surfaces.

Do not assume English is always shorter than Japanese/Korean.

---

## 41. Accessibility Rule

Do not break:

- Dynamic Type
- VoiceOver
- Reduce Motion
- non-color-only status
- adequate touch targets

When adding custom pixel visuals, preserve semantic accessibility for the actual information.

---

## 42. Pixel Asset Rule

Pixel assets should be reusable and modular.

Avoid:

- one giant bespoke scene per station
- embedding business logic in asset selection
- critical information baked into images

Critical text remains live UI text.

---

## 43. Live Activity Rule

No feature View should call ActivityKit directly.

`LiveActivityCoordinator` owns lifecycle.

Live Activity receives only derived presentation state.

Do not duplicate full Journey models into the extension.

---

## 44. Notification Rule

Notifications must consume domain events.

Do not scatter notification scheduling logic through feature views.

Notifications should be sparse and contextually useful.

---

## 45. Persistence Rule

Persist:

- active Journey
- recent station searches
- recent journeys
- settings
- required versions/mappings

Do not persist:

- animation frame offsets
- transient sheet state
- provider DTOs as product truth

---

## 46. Migration Rule

Any persisted schema change requires explicit thinking about:

- migration
- invalidation
- backward compatibility
- recovery

Do not silently reinterpret old data.

---

## 47. Search History Rule

Recent station search history must:

- remain bounded
- be locally stored
- be clearable
- avoid server profiling

If implementation introduces ranking based on search frequency, keep it local by default.

---

## 48. Codex Execution Guidance

When using Codex, it may handle:

- repository inspection
- code editing
- Xcode build/test
- fixture generation
- Git operations
- physical-device build/install when available
- refactoring
- audit reporting

Codex must still follow every project document and current phase scope.

A new Codex session must re-read the project documents rather than relying on a previous session's memory.

---

## 49. Claude Code Execution Guidance

When using Claude Code, it may handle:

- repository inspection
- code editing
- tests
- architecture analysis
- large refactors
- fixture generation
- documentation updates
- Git operations
- build/test workflows supported by its environment

Claude Code must follow the same project contract as Codex.

A new Claude Code session must re-read the project documents rather than relying on previous conversational state.

---

## 50. Agent Handoff Rule

The project must remain understandable when work moves between:

- Codex
- Claude Code
- a human developer
- another future coding agent

Therefore important state must live in:

- source code
- tests
- project documents
- Git history

not only in one agent's chat history.

---

## 51. No Agent-Specific Architecture

Do not shape the codebase around one coding agent's preferences.

The architecture should remain valid independently of whether the next change is made by:

- Codex
- Claude Code
- Xcode manually
- another competent developer

---

## 52. Change Summary Requirement

After substantial work, the agent should provide a concise summary covering:

- what changed
- files changed
- tests run
- build status
- device status if relevant
- documentation updated
- unresolved findings
- next recommended step

This summary should describe verified results, not guesses.

---

## 53. Failure Reporting

If a build/test/tool step fails:

- report the exact failing stage
- identify known cause if verified
- do not claim success for unrun steps
- preserve useful logs
- propose the smallest next corrective action

Avoid vague statements such as “probably fine.”

---

## 54. Uncertainty Rule

If a provider behavior, iOS behavior, license, or railway rule is not confirmed:

- do not invent an answer
- record the uncertainty
- research or test it
- keep the relevant decision provisional if necessary

---

## 55. Completion Standard

A coding-agent task is complete only when:

- requested scope is implemented,
- architecture rules remain intact,
- required tests pass,
- required builds pass,
- relevant docs are updated,
- no known critical regression is left hidden.

A phase is complete only when its roadmap exit criteria also pass.

---

## 56. Agent North Star

Every agent working on TSUGINO should be able to answer:

> What is the current product truth?  
> What phase are we in?  
> Which layer owns this behavior?  
> How will we prove this change works?  
> What happens if the provider or implementation changes later?

If those answers are unclear, inspect the documents before writing more code.

TSUGINO should remain:

> **easy to understand, safe to change, easy to test, and difficult to accidentally break.**
