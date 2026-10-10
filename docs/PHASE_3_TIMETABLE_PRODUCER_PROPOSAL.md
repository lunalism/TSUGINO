# P3-T1 — Timetable producer-output proposal

**Status:** Accepted semantic boundary — DEC-078; implementation is partial\
**Date:** 2026-10-01

## Governing request-closure implementation status — 2026-10-10

The owner separately authorized and implemented the invented-only production Data request-
closure values: **`P3_REQUEST_SCOPED_SEARCH_INPUT_CLOSURE_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`**.
Author **116/240** tests and Release passed; independent **24/24** review, **31/90** focused
rerun and fresh Release passed. No unresolved findings; publication pending, all six files
unstaged/uncommitted at unchanged published HEAD `f520d5ffe771820fa4e6d8d2b63c58bfe55fd60b`.
[Consumer §20.6](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#206-invented-only-request-closure-implementation--2026-10-10)
records exact independent occurrence/interval requirements, known-negative/unknown handling,
full applicability and measured finite safeguards. Every required connection remains unresolved;
Boundary A payloads, solver, runtime adoption and real/private access are excluded. Earlier
next-task/design-only request-closure wording below is historical. Broader P3-T1/Phase 3
status, unresolved production horizon/resource/adoption policy and live/default routing remain
unchanged. Publication and a separate invented-only connection-evidence assessment are next.

## Governing real inventory and next-boundary status — 2026-10-10

The separately authorized first real production Candidate-B inventory pilot completed:
**`FIRST_REAL_P3_T1_OCCURRENCE_INVENTORY_PILOT_COMPLETE`**, independent review **27/27 PASS**,
no unresolved findings. [§18](#18-first-real-production-occurrence-inventory-pilot--2026-10-10)
records supplied safe execution facts without private artifact access. The values were
published at `0c9b06741b8f1ce8ebce428e943b9c55d78d9a50` before the pilot; earlier
unstaged/publication-pending and next-Candidate-B/pilot statements below are historical.
Broader status remains **`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**;
Phase 3 **In Progress**. No search-input closure, solver or runtime adoption follows.

Next-task classification: **`P3_REQUEST_SCOPED_SEARCH_INPUT_CLOSURE_NEXT`**; B then A.
The [consumer §20 audit](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#20-post-inventory-pre-solver-boundary-audit--2026-10-10)
recommends invented-only request-relative Data closure values with unresolved connection
requirements before a separate qualified connection payload boundary. This is a technical
recommendation under Accepted truth, not implementation or a production horizon/adoption choice.

## Governing Candidate-B implementation status — 2026-10-10

The separately authorized invented-only production Data values and focused tests are
implemented and independently approved:
**`P3_T1_OCCURRENCE_INVENTORY_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`**.
[§17](#17-candidate-b-invented-only-production-values--2026-10-10) records invented
limits, verification and separate review. Owner publication remains pending; all five
implementation/test/documentation files are unstaged/uncommitted.
Earlier Candidate-B next-action/design-only text below is historical for the published
boundary audit. No real inventory construction/access, solver or runtime adoption is
part of this implementation; Accepted producer/consumer semantics remain unchanged.

## Governing bridge/inventory status — 2026-10-10

**`FIRST_REAL_P3_T1_DIRECT_ROUTE_ADMISSION_BRIDGE_COMPLETE`** records one successful
private production-constructor composition for the explicitly authorized interval,
not route search or runtime adoption. Broader P3-T1 remains
`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`. [§15](#15-first-real-direct-route-admission-bridge--2026-10-10)
records supplied safe evidence; [§16](#16-minimum-production-occurrence-inventory-boundary--2026-10-10)
assesses Candidate B without implementation/private access. Earlier dated Candidate-A
next-step and unverified-interval statements are preserved as history for that stage.
The selected next task is `P3_T1_REAL_OCCURRENCE_INVENTORY_ADAPTER_NEXT`; no additional
ordinary real direct-ride repetition is required first. Accepted semantics remain unchanged.

## Governing implementation/import status — 2026-10-10

The first real dated occurrence import is complete for **one Trip / one service date /
one approved profile**: `FIRST_REAL_P3_T1_DATED_OCCURRENCE_IMPORT_COMPLETE`.
Broader P3-T1 remains `P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`;
launch-wide coverage and runtime/search adoption are not established. [§13](#13-first-real-dated-occurrence-import--2026-10-10)
records supplied safe execution evidence; [§14](#14-repository-only-routing-handoff-assessment--2026-10-10)
assesses the next bounded handoff using repository contracts only. Older dated
pending-import/publication and implementation-stage statements below are preserved
as history, not current status for this pilot. Accepted semantic boundaries remain
in force. No private artifacts were accessed for this update.

## Current acceptance and implementation boundary — 2026-10-01 Asia/Seoul

Accepted DEC-078: Producer §§2–4 and O1–O6 are accepted; only pure values/local validation are implemented.
Owner acceptance includes the prepared recommended package, not engine adoption,
source compatibility or production delivery. See DECISIONS for the authoritative
acceptance and ROADMAP for exact slice evidence. No calendar interpretation,
conversion, real import or DEC-079 implementation is supplied by the value slice.
P2-S9 and all applicable retained gates remain in force.

Next conversion/input slice: §9 and **Accepted DEC-085** (2026-10-04). The owner
approved C1–C4 and authorized bounded synthetic implementation; completion is tracked
separately. This does not change the accepted DEC-078 value boundary.

The §9 DEBUG-only inputs/converter are now implemented and targeted/Release checks
passed; independent completion review approved the bounded slice. ROADMAP records exact evidence.
No calendar/feed adapter or real import is supplied by that invented implementation.

The body below preserves the historical proposal and acceptance-preparation wording
(including its original “Proposed” labels and undecided implementation choices).
Read semantic recommendations selected by the accepted package as accepted contracts;
read unselected alternatives, engine/profile choices and future tasks as deferred.

## 1. Scope, authority and recommendation

Scope lock: propose the smallest source-independent timetable output for a future
internal routing consumer, with invented cases; changes limited to this document,
a Proposed decision and a ROADMAP link. No implementation, acquisition or semantic
acceptance. [DEC-074](DECISIONS.md) accepts T1 ownership/placement only; DEC-077
accepts ODPT-first evaluation priority only. The [consumer outline](PHASE_3_INTERNAL_ROUTING_CONTRACT_OUTLINE.md)
and its DEC-076 amendments remain Proposed. Commercial evaluation/contact is paused.
All policy recommendations below are **Proposed**, not amendments to accepted text.

**Recommended boundary:** source adapters interpret explicitly identified formats;
T1 validates a dated scheduled occurrence tied to one exact, already accepted Trip
snapshot and original passenger-stop indices. It emits immutable occurrence facts
and explicit missing/estimated states, or a bounded inactive/unavailable outcome.
It does not search, infer transfers, create Trips or certify actual operation.

Basis: DEC-060 A–F, DEC-061 passenger-stop evidence, DEC-062/064, DEC-074/075,
DEC-076 C–E, ARCHITECTURE §§5.3/10/40, and the [feasibility matrix](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md).
Historical audit §§6.1/6.2/6.8 records calendars, stop_times and blank/non-timepoint
values, not a completed T1 interpretation. No raw/private inputs were reopened.
No example below establishes GTFS/ODPT compatibility or interprets a current feed.

## 2. Three distinct responsibilities

| Layer of responsibility | Establishes | Does not establish |
|---|---|---|
| Source interpretation, behind Data boundary | Format/profile version, service-date/calendar meaning, time encoding/zone rules, exact versus estimated classification, explicit row-to-S9 occurrence mapping, eligibility provenance | A raw row is a passenger stop; clock text is an instant; equal patterns are the same run |
| T1 validated facts | Activation under identified rules; uniquely qualified absolute events; compatible snapshot/indices; chronology, coverage and evidence states | Search suitability, route optimality, actual train operation, transfer feasibility or user selection |
| Future routing consumer | Request-relative lower bound on ridden endpoints, supported ridden coverage, connection feasibility, enumeration/completeness and result admission under a future accepted contract | New dates, stops, occurrences, times, inferred continuity or timetable import truth |

P2-S9 owns ordered passenger stops, original indices, line traversal, recurring-run
identity and both service-endpoint coverage flags. T1 never filters/reorders S9's
list, inserts passing stations, collapses repeated visits, crops/reindexes a Trip,
or stitches fragments. Non-passenger source positions may be classified by the
source adapter only with reviewed S9 correspondence; their absence from canonical
stops is not a T1 decision. Missing/ambiguous correspondence holds the occurrence.
A date-specific traversal change needs the appropriate reviewed canonical-data
handling, not a T1 override of the referenced snapshot.

## 3. Proposed minimum representation

Conceptual records only, not Swift types, persistence schemas or accepted public APIs.

| Record | Proposed minimum content and invariant |
|---|---|
| Timetable view | Immutable identity binding canonical dataset/mapping/Trip snapshot revisions, timetable source revisions and interpretation-profile version; permitted-use/validity and coverage manifest. One coherent view per operation; never join incompatible revisions |
| Evidence in Data | Publisher, distributor, source locator/hash/version, obtained time, effective range, source zone and conversion-rule version, transformation/validation authority. No raw provider key/DTO in canonical output; opaque view-scoped references resolve to this evidence |
| Occurrence address | `(view identity, TripID, service date)` **only where** the reviewed source mapping establishes one execution of that recurring run per service date. This is a revision-scoped address, not a durable physical-train ID. Multiple separately published departures must not be squeezed into one Trip; ambiguous/multiple execution correspondence is unsupported pending separate design |
| Trip binding | Exact existing immutable Trip snapshot or a view-bound reference resolving uniquely to it; full contents/coverage preserved. TripID equality alone cannot establish snapshot compatibility |
| Occurrence facts | Service date, resolved active status, source zone/profile reference, exact Trip binding, one visit record for each original index. Structural Trip coverage and schedule completeness remain separate |
| Visit facts | Original index; arrival and departure each `exact(absolute instant)`, `missing`, or `estimated(qualified estimate)`. Boarding and alighting separately `allowed`, `prohibited` or `unknown`, with evidence in Data. Stations derive from Trip index, not a second name-keyed list |
| Outcome | `active(facts)`; `inactive(reason/evidence)` for a conclusively inactive service date; `unavailable(reason/evidence)` for unknown, malformed, conflicting or unsupported interpretation. No routing noResults or RouteSearchFailure emitted by the producer |

Recommend view-bound immutable snapshots/facts without new persistent identities,
Codable or snapshot equality/hash guarantees in this initial contract. Type placement
and encoding remain a later bounded design. Alternative: attach schedule fields to
Trip; **not recommended**, because calendars/dates would blur DEC-060's recurring-run
identity and require a broader compatibility change. A separate repository lookup
instead of embedding a snapshot is viable only while retaining the exact immutable
view; a mutable “latest Trip by ID” lookup is not equivalent.

The coverage manifest must distinguish represented Trip extent, per-visit time
completeness, supported service-date range and source input completeness. An active
record with missing facts is not an entirely routable schedule. No view advertises
complete network coverage merely because its known records validate. Expiry or
unreviewed source revisions make current consumption unavailable; historical values
may remain identifiable under applicable retention rights. No TTL or update cadence
is invented here. A later selection revalidates its own view; no production delivery
or update mechanism is selected.

## 4. Recommended minimum semantic policies — Proposed

### Activation and date interpretation

- Interpret a service date as a source-defined operating-day label, distinct from
  an event's local civil date and from an absolute instant. Resolve it under an
  identified calendar/zone/profile, never the device locale or a hidden wall clock.
- Where a reviewed source profile explicitly defines a weekly baseline plus date
  exceptions, evaluate the baseline on the service date within its declared range;
  a unique explicit addition/removal overrides that baseline. An addition may
  activate outside the baseline range **within declared dataset coverage**. Outside
  dataset coverage is unavailable, not inactive. Exception-only calendars require
  an explicit completeness rule; absence cannot be presumed to mean inactive.
- Reject duplicate exception entries, including identical duplicates, and conflicting
  add/remove entries for the same service/date in the minimum profile. This is a
  conservative normalization policy, not a claim about actual source legality.
  Alternative: coalesce identical entries with provenance; defer until evidenced.
- Return inactive only with a complete, interpretable rule proving inactivity.
  Unknown calendar keys, unresolvable zone or incomplete calendar coverage produce
  unavailable. Inactive is scheduled non-operation, not observed cancellation.

### Outcome precedence and bounded diagnostics

Proposed deterministic evaluation order: first validate the shared view and the
calendar identity/profile/coverage and all relevant exceptions. Any ambiguity,
conflict or malformed activation input yields unavailable; it cannot be masked by
an apparent removal or inactive baseline. Only a conclusive activation result may
reach the next step. For a conclusively inactive date, return inactive with the
calendar reason and **skip event qualification/chronology validation for that date**.
Thus inactive plus raw `08:75` returns inactive, never active facts and never a claim
that its times validated. An independently discovered source defect may remain in
Data diagnostics but does not override this date's inactive outcome. For an active
date, validate every represented event under the rules below; any invalid event
holds the whole occurrence. A failure to establish the shared view precedes both.
This policy avoids interpreting irrelevant inactive schedules; a source-wide audit
of inactive rows is a separate task, not implied producer validation.

Canonical diagnostics contain bounded reason codes and, where applicable, the
original visit index plus arrival/departure event kind. A chronology conflict may
identify both conflicting indexed events; an unbound source row has no invented
canonical index. Calendar/view-level diagnostics have no visit index. Reasons are
conceptual categories (view, activation, occurrence binding, time qualification,
chronology), not raw messages. Retain one primary diagnostic: use that category
order, then ascending original index and arrival before departure, then canonical
reason-code lexical order for ties; unbound binding
failures precede indexed binding failures. For chronology use the first descending
pair in the exact-event subsequence. Coalesce identical diagnostics; secondary raw
source details/locators stay in Data under retention/privacy rules. No raw source
key, URL, time string or payload is copied into canonical diagnostics. This is not
an amendment to RouteSearchFailure or a logging mandate.

### Time qualification, missing data and order

- An adapter must have a reviewed conversion profile for its source's service-day
  encoding. Recommend initially supporting only unambiguous exact instants and
  profiles that uniquely map the service-date/extended-time/zone tuple. A zone label
  plus a bare clock is not itself proof. DST gaps/overlaps or unspecified anchor
  rules are unavailable unless the source supplies an authoritative disambiguation;
  never choose an offset, add a day because a clock decreased, or modulo-wrap hours.
- For a profile explicitly defining day-offset local clocks, `24:10` means next civil
  day 00:10 in the declared zone. A profile defining elapsed time from another anchor
  must use that anchor instead. These are not interchangeable around offset changes.
  This proposal accepts no blanket GTFS conversion rule. Enforce declared numeric
  bounds, minute/second ranges, overflow safety and finite absolute conversion;
  no arbitrary extended-hour maximum or “now”-based date selection is chosen.
- Exact means source-qualified scheduled precision, **not guaranteed actual time**.
  Missing stays missing; an origin arrival or destination departure is not filled
  from its counterpart. Estimated/non-timepoint values remain explicitly estimated;
  no interpolation, extrapolation or promotion to exact. If an estimate cannot be
  interpreted/qualified under its profile, the occurrence is unavailable, not
  silently missing. Unknown exactness is unsupported interpretation.
- Validate **all exact represented events**, ordered arrival then departure at index
  0, then index 1, etc. Their known-event subsequence must be nondecreasing, including
  across missing/estimated fields. Equality is allowed. Estimates do not constrain
  or override exact chronology and cannot be used to claim an exact connection.
  An estimate outside the exact-event envelope is retained as an estimate, not
  evidence of an exact-order contradiction; it remains excluded from minimum exact
  consumers. A future estimate-support policy would require its own validation.
- For a calendar-active date, a malformed event, conflicting values for one event,
  unqualified numeric value or exact chronological contradiction makes the **whole dated occurrence unavailable**
  in the minimum policy. Do not salvage a convenient subinterval or hide an error as
  missing. This trades availability for a small, auditable validity boundary.
  Legitimate missing values alone yield active facts with incomplete time coverage.
- Producer order is independent of a route request: an earlier unused stop may precede
  departNotBefore without making its occurrence invalid. Consumer admission examines
  the ridden departure/arrival endpoints, compares them against the request and across
  rides, and separately checks feasibility. The producer takes no RouteSearchRequest.

### Eligibility and continuity

Recommend requiring explicit allowed boarding/alighting at the respective ridden
occurrences for the first consumer. Producer output preserves prohibited/unknown;
unknown is not false source evidence or permission. S9 establishes passenger-stop
membership; the adapter interprets source eligibility, with T1 associating any dated
restrictions to exact indices. If both permissions are prohibited at a purported
passenger stop and conflict with reviewed S9 classification, hold it for S9 review;
do not delete the stop. Do not treat the same pattern as universally pass-through.

T1 can validate schedule association along an already reviewed continuous Trip,
including line changes. It cannot prove physical continuity by time agreement or
manufacture a spanning Trip. Cross-fragment same-run/occurrence correspondence needs
separate affirmative evidence and a compatible existing spanning snapshot before a
merged occurrence can be emitted. Independently valid fragment facts may remain,
with continuity unresolved, but must not be returned as one proven ride or a proven
train change. Transfer direction and connection allowances remain outside T1.

## 5. Worked cases — entirely invented, source-shaped notation only

All identifiers, stations, calendar rules, dates, times and the conversion profile
below are **synthetic**, not ODPT/GTFS payload examples. View **V1** binds immutable
Trip **TA = [A@0,B@1,C@2]**, line **LA**, both coverage flags true, and an invented
calendar **K** covering 2032-04-01 through 2032-04-30. The illustrative profile uses
fixed offset **+09:00**, day-offset local clocks and minute precision; baseline active
on every covered date unless stated otherwise. S9 correspondence is stipulated.
Known events are exact unless marked. Endpoint eligibility is allowed unless stated.
`D hh:mm` denotes a fully qualified ISO instant `DThh:mm:00+09:00` in output. No example
relies on current time, real weekday lookup or actual source rights.

| Case | Source-shaped synthetic input | Proposed output / held result | Responsibility boundary |
|---|---|---|---|
| T1-01 Normal day | TA/K, service date 2032-04-12; baseline active; A departure 08:00, B arrival 08:05/departure 08:06, C arrival 08:12; A arrival/C departure absent | Active `(V1,TA,04-12)`, exact events on civil 04-12 at those times; missing endpoint counterparts retained. Original indices 0/1/2 unchanged | Calendar qualification is T1; a request bound 08:01 would reject boarding at A in routing, not invalidate producer facts |
| T1-02 Exception addition | Baseline inactive on 04-13; one K/04-13 add; same event list | Active `(V1,TA,04-13)` with civil 04-13 events | Unique exception overrides known baseline only under this proposed profile; not route ranking |
| T1-03 Exception removal/conflict | Baseline active 04-14; one remove. Variant: both add and remove for K/04-14 | Removal: inactive, no occurrence facts. Conflict: unavailable(calendarConflict), not inactive | No last-record-wins or cancellation observation. Missing/unknown calendar would also be unavailable |
| T1-04 Midnight | Service date 04-12; A dep 23:58, B arr 24:10/dep 24:11, C arr 24:20 | Same occurrence `(V1,TA,04-12)`; A = 04-12 23:58, B = **04-13 00:10/00:11**, C = 04-13 00:20 | Service date remains 04-12. Conversion authorized by the invented profile, not inferred rollover; unknown source anchor would hold the occurrence |
| T1-05 Repeated station | Existing TB=[A@0,B@1,A@2,C@3]; A@0 dep 10:00, B@1 arr/dep 10:05/10:06, A@2 arr/dep 10:10/10:11, C@3 arr 10:20; explicit source-index correspondence | Four original visit slots; two A visits stay separate with distinct times. Boarding A@2 uses 10:11, not 10:00 | Station-only correspondence cannot choose a visit; unavailable(occurrenceMapping) if indices cannot be proved. Producer never picks first A |
| T1-06 Same recurring Trip, two dates | TA active on 04-12 and 04-13 with same 08:00 departure profile | Two addresses `(V1,TA,04-12)` and `(V1,TA,04-13)`, same exact recurring snapshot, different absolute instants | TripID alone is not dated identity. These may be separate alternatives; putting both in one candidate still violates accepted duplicate-TripID rule, discussed below |
| T1-07 Missing/estimated | TA active; A dep **missing**, B arr **estimated 08:05**, B dep exact 08:06, C arr exact 08:12 | Active incomplete facts; A departure missing, B arrival estimated, no fabricated values. A→C is unavailable to the proposed exact-endpoint consumer; a different subinterval requires its own exact endpoints/eligibility | Missing is not zero; estimate is not exact. Valid facts do not guarantee a usable route. Symmetric missing arrival at C likewise prevents A→C admission |
| T1-08 Chronology | TA active; A dep exact 08:10, B times missing, C arr exact 08:09 | Entire occurrence unavailable(chronologyConflict); no salvage by omitting A or ignoring B gap | Producer compares all exact represented events across gaps; no request required. Malformed 08:75 likewise yields unavailable(malformedTime) rather than missing |
| T1-09 Through fragments | Source fragment F dep A 11:00 → Q arr 11:10 on LA; fragment G dep Q 11:10 → C arr 11:20 on LB; same label but no reviewed continuity join | No combined occurrence/through claim. Separately validated fragment facts may exist only with their own existing Trip bindings; missing bindings hold them too | Equality, line change or labels prove neither stay-aboard nor transfer. If separately evidenced as one spanning Trip later, T1 may bind its schedule without stitching new stops |
| T1-10 Revision mismatch | V1 binds TA=[A@0,B@1,C@2]. V2 binds the same TripID TA=[A@0,X@1,B@2,C@3]. A V1 arrival for C@2 is presented against V2 | Unavailable(occurrence binding); V1 index 2 must not attach to V2 B@2 or be shifted automatically to C@3 | TripID equality does not establish compatible snapshots. A separately reviewed V2 correspondence is required; preserve V1 unchanged |
| T1-11 Inactive and malformed | K/04-14 has a unique valid removal and raw departure `08:75`. Variant: both add and remove | First input: inactive; event validation skipped, no occurrence facts or time-validity claim. Variant: unavailable(activation conflict) before any inactivity shortcut | Calendar certainty precedes event qualification. Active-date `08:75` still holds the whole occurrence under T1-08 |

Names of unavailable reasons are conceptual producer diagnostics, not additions to
RouteSearchFailure. For repeated visits/partial Trips, coverage flags and original
indices survive unchanged. Time completeness never upgrades partial structural
coverage to complete service, even when both represented endpoints have exact times.

## 6. Consumer compatibility and representation alternatives

Recommend separate occurrence facts, then a **future explicit timetable-context
branch** (consumer outline IR-E1) for route results. ProviderScheduledContext keeps
its accepted provider-supplied-assertion meaning. Alternative IR-E2 uses a separate
result envelope/positional association with its own compatibility and drift costs.
Neither option is accepted here. Existing RouteScheduleAdmission returns provider
contexts, so only its arithmetic checks can inform a future shared validator; calling
it with a generic internal intent flag is not proof of activation or provenance.

DEC-076 C5 and DEC-062 prohibit duplicate matched TripIDs within one candidate/Journey
structure. Two dated executions of the same recurring Trip do **not** evade that rule.
Recommend preserving it for now: producer may represent both, separate alternatives
may reference each, but a consumer cannot put both in one accepted candidate or
hide one as unresolved. If real use cases require multi-date reuse within one journey,
explicitly review occurrence-aware uniqueness, selection, persistence and recovery
across DEC-062/076 and downstream consumers. Do not mint a different TripID per day.
Frequency-style multiple executions without reviewed recurring-run identity are out
of the minimum producer profile, not evidence of a reduced launch commitment.

No algorithm, enumeration/ranking, search horizon, pruning/completeness policy,
directional transfer graph, connection allowances, realtime prediction, Journey
binding, deployment/update composition or provider selection is supplied. An explicit
service-date query/finite production batch is an input to this producer; deciding
which dates to search and whether all relevant dates have been considered is routing
policy. Producer inactive/unavailable outcomes never authorize routing noResults.

## 7. Owner choices, evidence gates and next task

| Owner decision still required | Recommended minimum / tradeoff |
|---|---|
| O1 Separate immutable facts and view-scoped dated address | Adopt separate facts bound to exact snapshots; no Trip mutation or persistent run ID. Review one-run-per-service-date evidence requirement; avoids false uniqueness at cost of holding unsupported execution forms |
| O2 Calendar precedence and conflicts | Validate activation first; conclusively inactive dates skip event validation, ambiguous activation never skips. Reviewed baseline + unique exception override; duplicate/conflicting entries unavailable; unknown coverage not inactive. Conservative versus permissive duplicate coalescing |
| O3 Conversion profiles and supported zones/extended hours | Require unique source-authorized conversion; reject ambiguity, never guess. Fixed-offset examples do not establish a source profile; broader transition handling needs evidence |
| O4 Missing/estimated/malformed policy | Keep missing/estimated distinct, no interpolation; minimum consumers use exact ridden endpoints; whole occurrence held on malformed/exact contradictions. Fewer usable results versus easier-to-audit truth |
| O5 Eligibility/through association | Tri-state eligibility at original indices; separate affirmative correspondence. No inferred boarding permission or fragment stitching |
| O6 Consumer context and duplicate-Trip limits | Prefer later IR-E1 review; preserve accepted duplicate-Trip rule now. This proposal does not accept any DEC-076 amendment or guarantee all dated itineraries fit current candidates |

Semantic decisions O1–O6 are not payload evidence. Real work additionally needs
accepted S9 and identified authorized source inputs; reviewed calendar, time-zone,
exactness, eligibility and run/occurrence mapping semantics per feed; compatible
revisions and current coverage/rights. Historical calendar/stop-time presence is
insufficient. Transfer/through evidence and public delivery permissions remain
separate; a valid private output is not a shipping dataset.

**Review progression:** the latest independent review found no material blockers in
DEC-078 refinements and DEC-079 for owner consideration only. DEC-078 remains Proposed;
its eleven cases and O1–O6 are ready for separate owner choice. DEC-079's optional
failure-scope/preflight clarifications are resolved in its own proposal. Neither
acceptance package accepts the other or authorizes implementation.

Synthetic design does not wait for S9 real completion. Any real Trip consumption or
real T1 import does. Implementation requires explicit semantic acceptance and a
separately bounded scope, not this draft.

Registry adoption, Q3 publication, Q4 translations, delivery/composition, applicable
bundling/deletion and S10/Track A expansion gates remain intact. Accepted 15-line
launch, capability tiers and Phase 3 exit are unchanged; ODPT-only feasibility is
still unresolved. No tests/builds, new research, private access or acquisition occurred.

## 8. Separately approvable owner package — DEC-078 remains Proposed

**Recommended acceptance boundary:** accept §§2–4 and O1–O6 as the minimum timetable
producer-output semantics. Facts bind to an exact existing Trip snapshot, coherent
view, service date and original indices; the dated address is supported only with
reviewed one-execution-per-template/date correspondence. Source interpretation stays
in Data; P2-S9 remains owner of canonical order/coverage. Accept activation-first
precedence, explicit unique conversion, separate exact/missing/estimated fields,
all-exact-event chronology for active occurrences, whole-occurrence invalidity,
tri-state eligibility, bounded indexed diagnostics and affirmative through evidence.
O6 preserves duplicate-Trip rules and recommends IR-E1 for separate consumer review;
it does **not** accept DEC-079 or change DEC-076.

The six recommended choices and consequences are the O1–O6 table above. In particular,
O2's inactive shortcut emits no facts and makes no assertion about skipped event
validity; O4's whole-occurrence rejection applies when activation is active. Estimated
values remain qualified and tagged, never exact inputs for the minimum consumer.

**Undecided:** concrete feed-specific calendar/time/zone/extended-hour interpretation
profiles and evidence; additional execution identities; estimate-consuming behavior;
concrete type placement/encoding, persistence/update composition. No source profile
is accepted by the invented examples. Search profiles, connection allowances,
ranking and routing algorithms are outside this producer boundary.

**Current code gap:** canonical Trip supplies recurring passenger-stop structure,
not a dated timetable producer. There are no accepted-output occurrence/visit facts,
calendar/exception evaluator or service-day converter implementing this proposal.
ProviderScheduledContext and RouteScheduleAdmission describe provider assertions
and already-qualified endpoint checks; they are not a timetable import or activation
pipeline. Existing snapshot/index constraints are reusable without changing Trip.

**Acceptance would not authorize:** any implementation or import, real-data access,
engine adoption, DEC-079 adoption, provider compatibility claims, Journey binding,
production registry/rights/delivery, launch reduction or Phase 3 exit. Feed-specific
interpretation and validated real import remain separate from semantic acceptance.

### Smallest first implementation slice after acceptance — recommendation only

Prerequisites: explicit DEC-078 acceptance, then separate authorization for a pure
producer-values/local-validation slice. Agree concrete type placement and failable
constructor signatures within that bounded task; no new policy or feed assumptions.
DEC-079 acceptance, a numeric search horizon and a routing algorithm are not required.

Include immutable Sendable view-scoped dated addresses, snapshot-bound visit facts,
exact/missing/estimated and eligibility states, bounded diagnostic values, and local
construction checks using entirely invented snapshots and already-qualified instants.
Check index-slot correspondence, full snapshot preservation (explicit content checks,
not Trip equality), finite qualified values and known-exact chronology across gaps;
reject invalid structure without traps. Preserve estimates as distinct values.
Synthetic fixtures cover repeated visits, revision mismatch, missing endpoints,
non-finite values and chronology contradictions. A supplied activation/identity
assertion is a fixture premise, not evidence authentication.

Exclude calendar activation/exception evaluation, source clock parsing/conversion,
feed adapters, real data, persistence, networking, search/request admission, routing
context/result changes, connection feasibility, engine/completeness and Journey/UI
binding. Constructed values cannot prove activation, permitted use, source identity
or current coverage. Tests/builds belong to that future authorized implementation,
not this documentation task. P2-S9 is mandatory before real Trip consumption and
real P3-T1 import; it does not block this entirely synthetic value slice.

## 9. Proposed bounded invented conversion profile — DEC-085

**2026-10-04; C1–C4 accepted; bounded synthetic implementation authorized.** The
owner accepted the independently reviewed proposal. Implementation/review completion
is tracked separately in ROADMAP. The proposal wording below preserves its rationale;
the earlier first-value-slice recommendation is historical.
DEC-078 remains accepted and its five Domain value files remain unchanged. This
profile has **no Toei, ODPT or GTFS applicability claim**. All inputs are invented
in-memory values, never a file format, importer, evidence reader or source validator.

### 9.1 Accepted requirements versus new choices

Reuse DEC-078: coherent view and exact Trip snapshot/original indices; one execution
per recurring Trip/date; activation before event validation; unique exception override;
no inactive-as-invalid-time confusion; exact/missing/estimated separation; tri-state
eligibility; all-exact-event chronology; whole-occurrence failure and no routing policy.
Reuse `TimetableOccurrenceBinding.matches`, `TimetableVisitFacts`,
`TimetableOccurrenceFacts.validationDiagnostic` and their constructors. Do not change
Trip equality, Domain date-label permissiveness, consumer context or diagnostic enums.

New owner choices are the invented input envelope and completeness declarations,
concrete Gregorian/date/clock/zone profile, finite limits, and Data outcome taxonomy
and deterministic failure order below. These specialize an invented source only;
they neither establish a production profile nor add real S9 acceptance requirements.

### 9.2 Input envelope and correspondence

Proposed pure Data operation: `convert(one invented packet) -> one conversion outcome`.
A packet contains exactly one existing binding, one requested service date, one
invented run/service key, and one immutable view manifest. No request horizon, clock,
network, file path, resolver, registry allocation or lookup of a mutable latest view.

The manifest names the exact view UUID, source revision, profile ID/version
`invented-civil-day-v1`, zone-table revision, mapping/correspondence revision, and the
full existing Trip snapshot. References are opaque invented ASCII tokens, not URLs
or paths. A finite in-memory reference table stipulates profile applicability,
calendar coverage/completeness, one-execution-per-date correspondence, event quality
and eligibility evidence, each bound to the same revisions/run and relevant index/
event. References are recorded/resolved only within this table; nothing opens their
contents elsewhere. They are fixture assertions, not authenticated provenance.

The reference table has unique IDs: duplicate IDs (even identical records) or
conflicting declarations for one ID are invalid, never first-match resolution.
Each entry has one typed assertion kind and a revision tuple. Applicability is
either whole-run or one inclusive original-index range with an explicit event-kind
or eligibility-kind selector; no nested lists, free text, wildcard revisions or
external references. Each event/permission slot carries at most one reference ID.
Absent resolution is insufficient; a resolved incompatible assertion is invalid.
Envelope validation checks bounded table shape, uniqueness and revision tuples;
requirements for event-quality/eligibility references and their applicability are
checked only for active dates. Inactive output does not claim those were reviewed.

Binding and manifest must agree on view, TripID and every snapshot field (stops,
line segments, coverage and service types). Requested date must equal the binding's
canonical service-date label. Equal IDs alone do not establish correspondence.
Missing required identity/applicability evidence is insufficient; explicit disagreement
is invalid. Known multiple executions per run/date are unsupported; uncertain
multiplicity is insufficient. No automatic candidate selection or revision repair.

For an active date, require exactly one input visit per original index, with distinct
invented occurrence tokens and explicit one-to-one mapping to those indices. Input
visits must already be in original-index order; reject duplicates, out-of-range or
reordered indices and contradictory mappings. A missing mapping/visit is insufficient,
not an inferred missing time. Repeated stations remain distinct. Arrival and departure
are separate tagged fields: explicit missing, exact(clock, evidence reference), or
estimated(clock, evidence reference). An absent field is insufficient, not missing.
An explicit unqualified(clock) input represents unknown source quality and is
insufficient; it has no Domain time equivalent and is never coerced to estimated.
Each boarding/alighting field is separately allowed, prohibited or unknown; absent
support for an affirmative allowed/prohibited claim is insufficient. Explicit unknown
requires no affirmative permission claim. Conflicting support is invalid. No raw
pickup/drop-off/timepoint flags or automatic stop/pass classification enter this API.

### 9.3 Dates and activation

Date syntax is exactly ASCII `YYYY-MM-DD`, using the proleptic Gregorian calendar,
valid years 2000–2099 and actual month/leap-day validity. No whitespace normalization,
locale parsing, device calendar or implicit date. Impossible/malformed dates are
invalid; otherwise valid dates outside the supported year range are unsupported.
A canonical date outside the packet's inclusive declared service-date coverage is
insufficient evidence, never inactive. Weekdays use Monday through Sunday explicitly.

Exactly one activation mode is required:

- **Weekly baseline:** one inclusive start/end range (start <= end, within coverage),
  seven explicit booleans, and a declared complete exception list for that service
  and coverage. Baseline is active iff in range and that weekday is true; outside
  the baseline range but inside coverage it is inactive unless uniquely added.
- **Exception-only:** no baseline; an explicit assertion that the exception list is
  exhaustive over coverage. Unlisted dates are inactive only under this assertion.

A unique date-specific add/remove overrides baseline status; add can activate outside
baseline range within coverage. Remove is scheduled inactivity, not observed realtime
cancellation. Reject duplicate records even when identical, conflicting add/remove,
reversed ranges, foreign service keys, invalid dates/actions and exceptions outside
coverage. Validate the entire bounded calendar list before selecting the date; do not
let a removal mask a conflicting calendar. Missing baseline/mode or exception-list
completeness is insufficient; multiple baselines are invalid, never unioned. Unknown
mode/version is unsupported. Absent calendar information cannot prove inactivity.

### 9.4 Explicit civil-day anchor and zone conversion

The invented profile **defines** clocks as a civil-day offset, not elapsed seconds
from an absolute midnight/noon anchor. The day anchor is the Gregorian service-date
label at civil 00:00:00, which is a coordinate origin, not an assumed existent instant.
For `HH:MM:SS`, advance the civil date by floor(HH/24), then use HH mod 24 with MM/SS.
Resolve that resulting local tuple separately. Do not add HH*3600 to a resolved local
midnight, advance because a prior clock decreased, or wrap away the civil-day offset.
This deliberately chooses one of DEC-078's possible source profiles; elapsed-anchor
profiles are unsupported, not silently treated as equivalent.

Clock syntax: exactly two ASCII digits per component, `00:00:00` through `71:59:59`;
MM/SS 00–59, no fractions, signs, whitespace or leap seconds. `25:10` is explanatory
shorthand only; input must be `25:10:00`. Malformed components are invalid; well-formed
hours 72–99 are unsupported by this slice. More than two hour digits are invalid
profile syntax. No truncation or overflow-prone conversion of unbounded strings.

Zone input is either an explicit fixed offset in integral seconds within ±50,400,
or at most eight contiguous, nonoverlapping, half-open UTC intervals `[start,end)`
with integral-second offsets in that range. The fixture supplies UTC bounds as
checked Int64 POSIX seconds (no leap-second model); each table has a revision.
No OS/IANA timezone database, named-zone inference or device-default zone is used.
A named-zone-only input or an alternative rule kind is unsupported. Missing zone
rules/coverage is insufficient; reversed/overlapping intervals are invalid. Adjacent
boundaries must meet exactly; a coverage hole is insufficient. A fixed offset is
constant over the entire supported conversion range.

Let L be the local tuple encoded as Gregorian seconds on a zero-offset coordinate
axis. Require the transition table to cover **all** potential instants from
L−50,400 through L+50,400 inclusive (the final half-open bound must exceed the latter).
Otherwise return insufficient coverage before diagnosing a gap/fold. For every
interval with offset o, candidate U = L−o is valid iff U lies in that interval and
round-trips to exactly the requested local tuple. One candidate yields an instant;
zero means nonexistent local time, more than one means ambiguous local time. Both
return insufficient evidence with distinct fixed reasons, never choose first/last,
shift a gap forward or use an estimate to disambiguate. An authoritative fold selector
would require a separately reviewed future profile; this invented slice has none.

Compute dates, day offsets, L and U using checked integer arithmetic; validate bounds
before multiplication/addition/subtraction or conversion to Foundation Date. Permit
instants only within `[1999-12-29T00:00:00Z, 2100-01-04T00:00:00Z)` to include offset
and extended-hour spillover around the supported service years. Table endpoints must
also lie within these bounds (the exclusive upper endpoint may equal the upper bound).
All externally supplied numeric fields use checked Int64 values before narrowing;
offsets and indices receive their specific range checks. Overflow/nonfinite
or out-of-envelope conversion is invalid and emits no facts. The finite existing
`TimetableInstant` constructor is the final representation check, not the converter.

### 9.5 Qualification, outcomes, ordering and bounds

Convert exact and estimated values by the same unique-instant rule, retaining their
tags and evidence associations. Unknown quality is insufficient; contradictory quality
claims are invalid. No interpolation, estimate promotion, counterpart copying or
mandatory endpoint time invention. Explicit missing remains missing at any index.
Only exact events constrain chronology: arrival then departure at each original index,
nondecreasing across missing/estimated gaps. Equal instants pass. Estimates outside
that envelope remain estimates. Reuse existing validation for the first descending
exact pair; do not sort, crop or repair the occurrence. Producer success does not
promise usable boarding/alighting endpoints or through/transfer evidence.

Conceptual Data-only outcomes (not new Domain or routing errors):

| Outcome | Meaning / examples | Projection onto DEC-078 |
|---|---|---|
| `success(facts)` | Active, complete correspondence and uniquely qualified events; explicit missing/unknown values permitted | `active(facts)` |
| `inactive(reason)` | Baseline-off, outside-baseline or explicit removal within complete coverage | `inactive` |
| `unsupported(reason)` | Recognized but out-of-profile mode, zone kind, year/hour, multiplicity or resource limit | `unavailable` |
| `insufficientEvidence(reason)` | Missing view/calendar/correspondence/quality support; unknown activation; incomplete zone coverage; gap/fold | `unavailable` |
| `invalid(reason)` | Contradictory revisions/mappings, malformed dates/clocks, duplicate rules, arithmetic fault or chronology conflict | `unavailable` |

No caller may map unavailable to inactive or routing noResults. Return one primary
fixed reason plus an existing bounded diagnostic category and optional canonical
index/event location where valid; never raw tokens, clock text, keys or exception
messages. Binding faults without established indices have no invented location.
Project envelope/view/profile/revision/resource faults to `viewUnavailable`;
calendar/date/zone-rule faults to `activationUnavailable`; snapshot/visit correspondence
faults to `occurrenceBinding`; event quality/clock/inverse-conversion faults to
`timeQualification`; exact-order faults to `chronologyConflict`. Shared applicability
faults belong to view, event-specific applicability faults to qualification. A data
reason code refines that category without changing the existing diagnostic shape.

Ordered validation: (1) input size/safe shape and view/profile/revision/date envelope,
including zone kind/revision, offset ranges and interval structure/contiguity;
(2) complete calendar rules, requested coverage and activation; (3) active-only visit
correspondence; (4) active-only candidate-window coverage and event qualification in
index order, arrival before departure; (5) existing chronology validation and atomic
construction. Unresolvable zone rules fail before inactive; a nonexistent/ambiguous
event tuple is checked only when active. Collect findings within each safely inspectable
bounded stage: any invalid finding makes the Data outcome invalid, otherwise unsupported
precedes insufficient. This aggregate severity does **not** reorder the accepted primary
diagnostic: retain DEC-078 category order (view, activation, binding, qualification,
chronology), then unbound before indexed binding faults, lowest index/arrival first,
then fixed reason code lexically. Thus missing qualification at index 0 and malformed
clock at index 1 yield an invalid Data outcome with index 0 as the primary diagnostic;
severity reports that a defect exists, not that the primary location caused that severity.
Unsafe structures are not traversed to discover more faults. Stop before lower stages.
Inactive skips stages 3–5;
malformed inactive clocks do not change inactivity, but size/envelope limits still apply.
Chronology uses the existing first-descending-pair rule, not lexical reason ordering.

Limits are proposed fixture limits, not feed limits: one occurrence/date per call;
at most 256 visits, 256 exceptions, 64 evidence references, eight zone intervals,
64 bytes per ASCII token, 10 per date and eight per clock string. Each supplied Trip
snapshot (binding and manifest) is limited to 256 stops, 256 line segments and 256
service-type segments (each existing segment carries one line or service-type ID).
Evidence entries have the single applicability shape in §9.2,
and each visit has at most four reference slots (arrival, departure, boarding, alighting).
All identifier text, including copied snapshot IDs, revisions and reference slots,
counts toward the total UTF-8 text payload limit of 64 KiB; repeated text is counted
each time. Snapshot IDs use their existing Domain spelling, with a 128-byte per-ID
ceiling; the 64-byte ASCII rule applies to invented Data tokens only. Reject top-level
and nested counts before traversing their elements, then check bounded text lengths
and total size before semantic work, also on inactive dates. Finite typed record
shapes contain no arbitrary nesting or extra blobs. Date and clock syntax length faults
are invalid; other size/count overruns are unsupported(resourceLimit). One overflow
check cannot be bypassed by narrowing a larger value. All loops are bounded; no date
range expansion, retries, partial success stream, logs, exports or persistence.

This is a synchronous pure operation on immutable invented values. Temporary facts
stay local until all checks pass; any failure returns zero facts and discards temporary
results. No cache, file access, wall-clock access or background task. Cancellation/
async ownership and production batch-import semantics are outside this small slice.

### 9.6 Invented implementation-ready cases

Common fixture: two original visits [A@0,B@1], coherent V1/R1/profile-v1 mapping;
service date 2026-04-13 (Monday), coverage April 1–30, weekly April 1–30 Monday–Friday,
complete exceptions empty, fixed +09:00; exact dep@0 08:00:00, arr@1 08:30:00;
other times explicitly missing, eligibility explicitly unknown. All evidence is invented.

| Case / change from common fixture | Expected outcome |
|---|---|
| Ordinary Monday | success: dep 2026-04-12T23:00:00Z, arr 23:30:00Z; missing counterparts retained |
| Saturday April 18, no exception | inactive(baselineOff) |
| April 18 add; baseline ends April 17 | success on April 18; coverage still through April 30 |
| April 13 remove; clock contains 08:75:00 | inactive(explicitRemoval); clock not validated |
| April 13 duplicate removes, or add plus remove | invalid(duplicateException), before inactive shortcut |
| Exception-only complete empty list | inactive(unlistedDate); same list without completeness -> insufficient(calendarCompleteness) |
| Missing calendar; May 1 outside coverage | insufficient(activationUnavailable); insufficient(calendarCoverage), respectively |
| dep 23:50:00, arr 24:10:00 | success: April 13 14:50Z then 15:10Z; no modulo-only wrap |
| dep 25:10:00, arr 25:30:00 | success: April 13 16:10Z then 16:30Z (local April 14) |
| Missing dep@0; estimated arr@1 07:00:00 | success, missing/estimated preserved; no fabricated exact endpoint |
| dep@0 exact 08:30:00, arr@1 exact 08:00:00 | invalid(chronologyConflict); whole occurrence fails |
| Repeated [A@0,B@1,A@2] with complete indexed input | preserve all three; station-only ambiguous A correspondence -> insufficient(occurrenceBinding) |
| Same TripID but changed snapshot, or event mapping R2 against R1 | invalid(revisionConflict/occurrenceBinding); no latest lookup |
| View evidence absent | insufficient(viewUnavailable), before calendar/event checks |
| 2026-02-30; 25:10; 72:00:00 | invalid(serviceDate); invalid(clockSyntax); unsupported(hourRange) |
| Unknown quality, or exact value with missing support | insufficient(timeQualification); never promote or drop it |
| UTC transition at April 13 02:00Z: offset 0 before, +3600 after; local 02:30 | insufficient(nonexistentLocalTime); no instant matches |
| Same transition with +3600 before, 0 after; local 02:30 | insufficient(ambiguousLocalTime); 01:30Z and 02:30Z both match |
| Either table lacks the full ±14-hour candidate window | insufficient(zoneCoverage), not a claimed gap/fold |
| Named-zone-only input; overlapping UTC intervals | unsupported(zoneKind); invalid(zoneIntervals), respectively |
| Zone changes 0 to +3600 at April 14 00:00Z; local April 14 00:10 encoded 24:10:00 | insufficient(nonexistentLocalTime); elapsed seconds from April 13 midnight would incorrectly succeed |
| Inactive date plus 257 visits | unsupported(resourceLimit) at envelope stage; no partial output |
| Inactive date plus missing zone or overlapping zone intervals | insufficient(zoneUnavailable) or invalid(zoneIntervals) before activation; no inactive shortcut |
| Active missing quality support at index 0 and malformed clock at index 1 | invalid outcome; primary qualification diagnostic at index 0, preserving accepted location order |
| Active input with out-of-range integer UTC bound or checked arithmetic overflow | invalid(arithmeticRange); never trap or return nonfinite Date |

Transition fixtures cover the full candidate window unless the row states otherwise;
UTC interval endpoints/offsets are supplied literally, never looked up in a real zone.
Implementation verification must also exercise exact interval endpoints, leap day,
2099 year-end spillover, all numeric/count boundaries, missing visits, contradictory
eligibility, same-stage reason precedence and inactive event-skipping. Existing value
regressions remain authoritative and should be reused, not duplicated mechanically.

### 9.7 Owner choices and smallest next slice

Recommend approval of DEC-085 choices C1–C4 as one bounded synthetic package:

| Choice | Recommended option and rationale | Alternative deferred |
|---|---|---|
| C1 Input ownership/correspondence | One typed, immutable invented packet and explicit evidence/revision/index associations; no IO or new Domain fields | File codecs, actual source adapters, multi-date batches and evidence authentication |
| C2 Civil-day profile/zone rules | Strict Gregorian dates, civil-day rollover, explicit fixed/table offsets and rejection of gaps/folds; deterministic without device or tzdb dependence | Elapsed-anchor or IANA-based profiles, fold selection and gap adjustment |
| C3 Calendar completeness/outcomes | Explicit weekly or exception-only completeness; typed Data refinements of unavailable with deterministic precedence | Sparse-calendar guessing, duplicate coalescing or routing failure reuse |
| C4 Bounds/execution | Limits in §9.5 and one atomic synchronous DEBUG-only converter with invented tests | Production scale, async importer, persistence or consumer/app integration |

After owner acceptance **and separate implementation authorization**, implement only a
DEBUG-only Data converter, its immutable invented inputs/outcomes and targeted tests
for §9.6, returning existing Domain facts. No changes to completed Domain values,
searchers or app wiring are expected. Review the exact input/output and boundary tests
independently before calling that slice complete. Real profiles/import remain separate;
P3-T1 stays partially complete and P2-S9 retains all fourteen classification/order gaps.

## 10. Bounded in-memory batch assembly — Proposed choices B1–B3

**Scoped acceptance — 2026-10-05:** the owner approves B1 and B3 and authorizes B2 as
reviewed technical experimentation, including its eight-slot safeguard, duplicate rejection,
ordering and exact preflight diagnostics. This is not a production coverage/resource policy.
Bounded DEBUG implementation is authorized; completion evidence is recorded separately below
and in ROADMAP. Historical Proposed wording records the reviewed design, not pending B1/B3
approval. No provider profile, publication service or real import is approved.

2026-10-05. Documentation only. DEC-085's single-packet implementation is complete;
this section proposes the next, separately approvable invented-only composition boundary.
It does not amend calendar/time/identity semantics or authorize implementation. DEC-078,
DEC-080 coverage/admission and DEC-086 outcomes remain authoritative. Consumer §§16–17
remain an evidence review index, not a new source of qualification authority.

### 10.1 Smallest input/output and identity

Propose one synchronous DEBUG-only operation `assemble(envelope, packets)` returning
an immutable constructed batch or a fixed batch-level failure. Names here describe the
contract, not new Domain types or a serialized format. No date expansion, source discovery,
file access, parser, clock, async worker, persistence, publication service or search call.

| Input / output | Proposed contract |
| --- | --- |
| Envelope | One existing `TimetableViewID`, one `SyntheticTimetableRevision` tuple, and a caller-ordered list of expected `TimetableOccurrenceAddress` values. These are the exact enumerated slots of this batch, not a search horizon or all supported product services |
| Inventory declaration | Explicit `stipulatedComplete` or `unknown` coverage of the caller-enumerated dated inventory, associated with the envelope's view/revision. This is an invented-world assertion, not evidence authentication. No claim of complete occurrence intervals, connections or request coverage follows; those remain separate existing search inputs |
| Packets | Exactly one existing `SyntheticTimetablePacket` for every declared address; no extra packets. Each retains its supplied exact binding, manifest, evidence and outcome semantics. Dates are supplied labels, not generated. Reject missing declared packets rather than manufacturing inactive/unavailable values |
| Constructed batch | Envelope plus immutable ordered slot records, each preserving its original packet binding and exact converter outcome; no manually rebuilt facts. Retain original expected-address order, independent of packet input order. No automatic filtering, sorting by time or winner selection |
| Batch-level failure | Fixed reason and optional tagged location (declaration index or packet input index); no partially constructed batch, route result, raw token/path or thrown source diagnostic. For an invalid converter outcome retain that existing typed failure internally with its slot association; expose no successful slot payloads |

Slot identity is the existing `(viewID, TripID, serviceDate)` address. Full snapshot matching
uses `TimetableOccurrenceBinding.matches`, not Trip's ID-only equality. Within a batch,
all dates of one Trip must reference the same full snapshot; date changes alone do not
permit snapshot variation. A comparison-only binding using the current address and the
representative Trip permits reuse of `matches` across dates; it must never replace a stored
binding or relabel facts. No snapshot equality/Hashable/Codable is added.

The immutable envelope identifies a batch's scope and provenance association. Do not add
a durable batch ID or compare batches by view ID alone. Two constructions with identical
inputs are separate immutable values, with no registry or global uniqueness claim. Exact
address and envelope coherence is local proof only; revision tokens cannot authenticate a
source. Explicit unknown inventory may be represented but cannot close search coverage.
Here “revision coherence” means only the listed envelope association and full-snapshot checks,
not cross-packet equality of calendar/zone interpretations. Per-service calendars may legitimately
differ; the assembler adds no shared-definition resolver or calendar-equivalence algorithm.
Known conflicting interpretations must remain explicit unresolved source/view qualification
failures, never hidden by batch construction or advertised as a coherent usable source generation.
A constructed batch does not discharge that obligation. Detecting such conflicts automatically
would need a separately specified shared-definition/key contract; it is outside this minimal slice.

### 10.2 Acceptance options and recommended B1

| Option | Behavior | Consequence |
| --- | --- | --- |
| Reject any unavailable required slot | After envelope validation, unsupported/insufficientEvidence/invalid abort the whole batch | Simple all-or-nothing usable-input gate, but discards a coherent collection's explicit unavailable-slot distinctions. Even success is not proof of usable endpoints, interval coverage or connections |
| **Retain explicit unavailable slots (recommended)** | Preserve success, inactive, unsupported and insufficientEvidence outcomes. Reject structural envelope contradictions and every converter invalid outcome; do not omit or coerce the other slots | Allows a truthful immutable inventory including holds. Search remains unavailable when a required slot is unavailable. Batch construction is not routing readiness or permission to publish |

This is a conservative form of option 2: **B1 Proposed** accepts representable holds but
not known invalid packets. Existing converter outcomes are authoritative; do not reparse
calendars, clocks, evidence tables or chronology in the assembler, nor classify invalidity
by its primary diagnostic reason (aggregate kind and primary reason need not coincide).
A malformed date/clock, duplicate exception or conflicting packet evidence yielding `.invalid`
therefore aborts construction. A source/profile outside the invented converter's support or
missing evidence yielding `.unsupported`/`.insufficientEvidence` may remain an unavailable
slot, preserving the entire original outcome. This does not broaden the converter profile.

Cross-packet envelope mismatches are different: conflicting revision tuple, wrong view,
undeclared/missing address, duplicate declarations/packets or inconsistent full snapshots
prevent construction before slot conversion. No assertion of unknown service repairs an
address contradiction. Missing calendar evidence inside a correctly associated supplied
packet instead follows the unchanged converter outcome. `.inactive` is retained only when
the converter proves it; absence of a packet or empty calendar is never inferred inactive.
Successful facts may still contain missing/estimated endpoints and unknown eligibility;
representation of success does not imply every interval is usable.

An empty declared address list and empty packet list construct an empty batch, retaining
`stipulatedComplete` versus `unknown`. Neither creates search `noResults`; the searcher
still requires its separate profile, per-Trip interval/slot inventory and complete required
domain. An unknown empty batch is not a complete-negative declaration. No omitted Trip or
date becomes known absent merely because it does not occur in the input array.

### 10.3 Bounded construction, duplicates and deterministic failures — Proposed B2

Recommend rejecting **all duplicate addresses**, including identical packets/declarations.
This avoids a second packet-equivalence/deduplication implementation and silent last-wins.
A duplicate address with a different binding is also rejected, never merged. The existing
searcher's allowance for identical duplicate normalized inventory is unchanged; this stricter
rule applies only to this new opt-in invented assembler input.

Proposed experimental envelope bound: **eight expected addresses and eight packets**, enough
for the three-slot direct/transfer example, repeated dates and a surplus conflicting packet
within small tests. This is not a production batch size, ride limit or new search budget.
Each packet remains subject to every existing DEC-085 bound, including nested snapshots,
256 visits/exceptions, 64 references, eight zone intervals and 64 KiB counted text. Thus at
most eight accepted per-packet envelopes are processed; no limits are multiplied inside a
packet. Expected addresses and the envelope revision use the same relevant token/date/ID
bounds as DEC-085, with shared bound helpers reused if implementation needs them, not a
second semantic validator. No unbounded strings or free-text diagnostics are introduced.
Count guards precede traversal; reuse the converter’s existing structural-bound preflight
for every packet before snapshot/evidence traversal or duplicate/coherence comparisons. A failed
per-packet preflight aborts this batch carrying its unchanged typed converter failure and
packet input index, not a fabricated resource reason. The existing `bounded` helper also
detects invalid token/date/clock shapes and baseline conflicts: it is not resource-only, and
aggregate severity may differ from its primary reason. Preserve both exactly. Envelope-only
count/length overruns use the batch resource reason. No oversized/failed-preflight slot is
retained; standalone converter outcomes stay unchanged. No date-range expansion or allocation proportional to a numeric date range.

Recommended order for this new assembly API (not a change to converter/search precedence):

1. Check top-level counts, bounded envelope/association headers and the reused per-packet
   preflight before semantic comparison. Envelope-only overruns use a fixed resource-bound
   failure. For packets, stop at the first failed preflight in packet input order and retain
   its exact failure, including any mixed invalid/resource findings under existing ordering.
   Do not truncate input. Snapshot comparisons only inspect bounded structures.
2. Validate declaration uniqueness and view association, then packet address uniqueness,
   exact declared/received address-set correspondence, envelope revision/view agreement,
   and same-Trip snapshot correspondence. Reject the whole envelope on disagreement.
3. In declaration order, call the unchanged converter once per packet, with all existing
   nested bounds and diagnostic ordering. On the first `.invalid`, return batch failure
   carrying that slot's unchanged failure; no later conversion is required. Otherwise retain
   every outcome. Temporary results stay private until all slots have been processed.

For multiple envelope defects, the numbered categories above have fixed precedence; within
a category use first declaration index, or first packet input index for undeclared/duplicate
packets. Unexpected packet order affects only those malformed-input locations, not valid output
ordering. No severity aggregation across slots and no retry/substitution. Failed packet preflights are batch failures with their original converter diagnostics;
unsupported semantic profiles/hours after successful preflight remain unchanged holds under B1.
No partly usable batch is returned on an assembly failure. A successfully constructed batch with
explicit holds is an atomic complete representation of supplied slots, not partial conversion
success advertised as usable routing data. Caller input values and earlier batches never mutate.

Downstream composition is **not implemented by this slice**: retain existing success→active,
inactive→inactive, unsupported/insufficient→unavailable mapping, with diagnostics internal.
No invalid-containing batch exists under B1. Continuity, original interval inventory, directional
relations and allowances remain separately supplied and qualified by existing APIs. Unknown
required slots/relations produce `dataUnavailable`, not omission or direct-only fallback.
Execution cutoffs remain `searchIncomplete`, never a successful incumbent; existing cancellation,
configuration, unsupported-request and admission failure precedence are unchanged. The assembler
returns no `RouteSearchResult` and chooses no execution policy.

### 10.4 Replacement and retained views — Proposed B3

Recommend replacement by constructing a **new immutable batch for a fresh caller-supplied view
identity** when the declared scope, content or revision association changes. Reusing a view ID
for changed contents is not permitted by this proposed caller contract. No hidden global registry
can enforce it: assembly validates only supplied input, and independent calls cannot detect
undisclosed prior use. No automatic UUID allocation, freshness period or persistent lineage.

The caller may switch its own reference only after successful construction and any separately
required qualification. Assembly success alone is not an authorized production publication.
On construction failure, the old value remains available as an unchanged historical value;
this is not permission to serve it as a current answer. Older consumers retain their original
view/snapshot/context; no in-place patch, index rebinding or merging old/new revision packets.
A later search must satisfy its own scope, view validity and coverage. Rights/retention gates
remain independent; no stale-serving policy or repository update service is designed here.

### 10.5 Invented examples and deterministic acceptance cases

All labels below are invented. Use one date, V1/R1, and exact two-stop intervals [0,1]:
D A→C 08:05–08:30, X A→B 08:02–08:10, Y B→C 08:15–08:20. Calendar/profile/eligibility
and full snapshots are stipulated coherent under DEC-085; the example does not interpret any
real feed. Search examples additionally stipulate complete required interval/connection evidence,
including X→Y's directional four-minute allowance and known absence of other required relations.
The assembler does not produce or verify those separate connection inputs.

| Case | Proposed assembly result | Existing downstream behavior / acceptance assertion |
| --- | --- | --- |
| D/X/Y success, complete declaration | Three unchanged outcomes/bindings in declaration order, even with permuted packet input | After independent complete qualification/search/admission, X→Y beats D; compare original facts/indices/date/context, not just arrival |
| Same batch, X→Y relation unknown | Batch unchanged: connection evidence is outside assembly | `dataUnavailable` despite usable D; never remove X/Y or claim D fastest |
| Y has missing calendar evidence | Constructed Y insufficientEvidence slot, with D/X unchanged | Required Y remains unavailable; no D-only complete result |
| Y converter-proven inactive | Constructed inactive reason, no event facts for Y | In a separately stipulated complete search domain, D may win; inactive is distinct from the previous unknown case |
| Empty complete versus empty unknown declaration | Empty batch preserving the declaration distinction | Neither alone establishes search noResults; no implicit slot creation |
| Identical duplicate address; conflicting snapshot at duplicate address | Batch failure for duplicates in both cases | No deduplication, last-wins or output survivor |
| Same Trip on two explicitly listed dates | Construct if full snapshots agree; reject conflicting snapshot with distinct date address | Preserve dated identity; no same-recurring-Trip reuse within a route is newly allowed |
| Wrong view/revision; extra/missing packet | Envelope failure before conversion | No relabeling or partial batch; caller input unchanged |
| Unsupported profile/hour versus invalid clock/chronology | Retain unsupported outcome; invalid aborts whole batch | Preserve converter distinctions and diagnostic precedence, no newly exact facts |
| New R2/V2 batch while V1 retained | Construct independently with coherent R2 packets; failed replacement returns no new batch | V1 facts/bindings stay byte-for-byte semantically unchanged; no claim of current validity from retention |
| Bounds and multiple defects | Eight valid slots allowed, nine rejected; nested per-packet limits unchanged; post-preflight first invalid in declaration order wins; failed preflights use packet input order | Verify atomicity, mixed invalid/resource preflight diagnostic preservation, exact slot association and fixed failure ordering without re-testing every calendar/clock rule |

### 10.6 Owner choices and smallest later implementation

| Proposed choice | Recommendation / reason | Not accepted by this document |
| --- | --- | --- |
| B1 Batch acceptance | Retain explicit unsupported/insufficient holds and inactive outcomes; abort on invalid or structural contradiction. Preserve uncertainty without advertising usable coverage | Whole-batch rejection on every hold is the alternative; no approval yet |
| B2 Duplicate/failure policy | Reject even identical duplicates; deterministic preflight-first, envelope checks, then declaration-order conversion, atomic output; eight-slot experimental bound and structural-bound preflight abort | No production batching policy or modification of existing search normalization |
| B3 Replacement | Fresh supplied view for changed batch; immutable retained old views, no automatic fallback/publication | No persistence, delivery, cache or stale-answer authorization |

After explicit approval and implementation authorization, the smallest slice is one DEBUG-only
Data/Timetable assembler with immutable local envelope/slot/result types and focused invented
tests for §10.5. Reuse the converter, binding matcher and bounded header helpers as necessary;
no new Domain semantics or second calendar/time parser. Only minimal helper extraction from
existing bound checks is justified, with unchanged single-packet outcomes/limits verified.
Test downstream mapping in test composition using existing search APIs, not a production bridge.
Required future verification is targeted assembler plus affected converter/consumer tests and
DEBUG/Release exclusion checks; none is run for this design task. No implementation is approved
by this proposal. The synchronous eight-slot work is not permission for heavy main-actor use.

All 15 launch lines/services remain preserved. P3-T1/Phase 3 remain incomplete; P2-S9 retains
14 classification and 14 ordering gaps. The owner reports no ODPT reply has arrived; none has been supplied here. Append stays opt-in,
reference remains default and live/default routing remains unconfigured. No real import,
source access, rights waiver, production budget or adoption is established.

### 10.7 Scoped implementation and verification — 2026-10-05

The owner accepted B1/B3 and authorized B2's reviewed technical experiment. The DEBUG-only
`SyntheticTimetableBatchAssembler` now implements the local envelope/declaration/slot/result
values, eight-slot ceiling, bounded-before-comparison ordering, duplicate/set/association and
same-Trip snapshot checks, followed by unchanged converter calls in declaration order. Success,
inactive and non-invalid converter holds are retained unchanged. Invalid conversion or envelope
failure returns only a typed failure with a tagged declaration/packet location, no partial batch.

The only converter change exposes `preflightFailure` around its existing private `bounded`
validation and findings; standalone conversion and its ordering/limits are unchanged. Preflight
failures retain aggregate kind, primary reason and diagnostic location exactly, including mixed
invalid/resource cases. Envelope headers receive bounded length checks; empty-batch construction
does not certify profile/token semantics or source validity. Calendar/zone agreement across
packets remains a separate qualification obligation, not inferred from matching revision tokens.

B3 remains a caller contract: a controlled replacement test rejects a disclosed same-view change
before assembly, then constructs a fresh-view value and verifies retained older facts unchanged.
There is no cross-call view registry or assembler claim to detect undisclosed reuse. Neither
batch construction nor retention authorizes current serving, publication or production use.
The unknown-transfer test records the separate unresolved connection boundary only; actual
`dataUnavailable` evidence is supplied by the existing converter/search integration suites.
No batch-to-search bridge or new search/qualification mechanism was introduced.

One final iPhone 17 / iOS 26.5 Simulator run passed **76 functions / 122 executed cases**,
zero failures/skips; assembler **13 / 26** is an included subset, not an additional run.
Affected converter, timetable values/context and both existing timetable-routing integration
suites ran together. Debug app/extension dependencies built; standard Release app/extension
build passed. Eight no-DEBUG declaration probes and Release app plus changed-object symbol
checks confirmed exclusion, including the converter helper. Existing unrelated asset-catalog,
Domain isolation and AppIntents warnings are not claimed fixed. No physical device was used.
Detailed run paths and review status are recorded in ROADMAP; no benchmark or real input ran.


## 11. Owner profile acceptance and bounded import-adapter implementation — 2026-10-09

The current owner acceptance in [ROADMAP](ROADMAP.md#owner-accepted-first-toei-calendartime-evidence-profile--2026-10-09)
binds profile `p3t1.toei-20260921.calendar-time-profile.1`, review
`p3t1.toei-20260921.calendar-time-review.20261009.001`, exact review SHA-256
`c45370a1e69d6c08d1ed4c7bfd601af728a7fb804ca121eb1a8234798a5e29c9`
and owner timestamp `2026-10-09T14:03:35Z`. This is evidence acceptance for the
exact retained source/candidate, not real import execution or runtime adoption.
Historical proposals and narrower synthetic acceptance records above are preserved.

The separately authorized `Tools/TimetableImport` implementation uses invented
fixtures only. It implements normalized reviewed input, exact external S9/profile
verification, one explicit date, actual Domain facts, deterministic private encoding,
separate preparation/profile approval/import approval/application, complete bounded
import state/history and immutable exclusive publication/replay. No accepted product
semantics or app/shared source is changed. Source parsing is a later separately
authorized binding step; the adapter cannot open a GTFS archive. The real source-profile
review file and real railway artifacts are not accessed in this implementation task.
No real approval/input/request/facts/bundle is created. See
[tool contract](../Tools/TimetableImport/README.md) and ROADMAP verification status.

Final standalone production build and complete invented suite passed **186 cases**.
Separate non-author review approved **29/29** criteria with zero unresolved findings,
independently rebuilt production and reran the same **186 cases PASS**. Unchanged
Domain/converter/batch/routing semantic regressions passed **82 tests in seven suites**;
unchanged S9 regressions passed **185 cases**. Counts are separate verification groups;
independent repetitions are not added. Privacy/whitespace/isolation audits passed.
The bounded adapter is independently approved and left unstaged for publication review;
P3-T1 real import, real profile-approval materialization and runtime adoption remain
unperformed and separately authorized. No new product decision is required.

## 12. Occurrence-locator bound correction — 2026-10-10

The adapter in §11 was subsequently published at
`d2b052cd2a49f2ab044cc7db9112747e555ab718`. Per owner-supplied execution context,
first real normalized binding succeeded, but preparation stopped before creating
a request/facts/bundle because generic 64-byte converter token validation also
checked S9 occurrence locators. S9 permits 256 bytes; the accepted real locator
lengths are reported only as the safe 172–176-byte aggregate. P3-T1 imposed an
unintended downstream resource restriction on an already accepted S9 authority value.

The correction distinguishes the exact opaque occurrence-locator limit (256 bytes)
from generic converter tokens (64 bytes), retaining printable ASCII syntax, exact
crosswalk byte association, all other bounds and the 64 KiB counted-text ceiling.
It changes no DEC-078/085 timetable or source/profile/import authority semantics.
Dedicated invented S9 fixtures and boundary/binding/aggregate tests supplement the
unchanged ordinary fixture. See [tool correction](../Tools/TimetableImport/README.md#occurrence-locator-bound-correction--2026-10-10)
and the current ROADMAP overlay for verification and review status.

This task opens no real/private railway artifact and performs no real preparation.
The prior attempt retained profile approval, normalized input and initial state;
its one-use source archive grant was consumed. Real preparation remains stopped
pending correction publication. A separately authorized next task must revalidate
and independently review those exact retained artifacts for reuse, without reopening
the archive. No real request, facts or bundle exists from the blocked attempt or this
correction. Historical §11 status remains a record of its implementation stage.

Author production build and complete **206-case invented suite PASS**; independent
non-author review approves **15/15 criteria** with no material findings and separately
rebuilds production/reruns the complete **206 cases PASS**. Counts are not summed.
Unchanged timetable regressions pass **82 tests / seven suites** on the explicit
iPhone 17 / iOS 26.5 Simulator, with zero failures/skips. The complete unchanged S9
suite passes **185 cases**, including its large invented retained-history envelope.
Privacy/isolation/whitespace audits pass; seven scoped files remain unstaged/uncommitted
for owner publication review. Real preparation stays stopped and Phase 3 stays In Progress.

## 13. First real dated occurrence import — 2026-10-10

**`FIRST_REAL_P3_T1_DATED_OCCURRENCE_IMPORT_COMPLETE`.** This records the owner's
supplied execution results; it is not a new private-artifact verification or import.
The correction in §12 was published at `6bbb99bf963769e4ebc5d8563d562962f461944f`.
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
Facts contain **14 visits at original indices `0...13`; 28 exact events;
0 estimated / 0 missing; boarding allowed at 14 visits; alighting allowed at
14 visits; 0 chronology contradictions**. Actual Domain `TimetableOccurrenceFacts`
construction and deterministic round-trip passed.

`approve-import` was invoked exactly once and `apply-import` executed exactly once:
`occurrenceImported`, ordinary success, no durability uncertainty, no retry, no second
apply. The published bundle contains exactly `facts.json`, `history.json`,
`manifest.json`. The published verifier returned `bundleValid unchangedReplay`;
verification was read-only and did not apply again. Independent execution review:
**25/25 approved**, no unresolved material finding. S9 and source-profile authority
remained unchanged; the GTFS archive was not reopened during approval/apply.

This accepts one dated occurrence under one approved profile, not all P3-T1 scope.
Accepted authority does not identify this pilot as the full required P3-T1 delivery:
**`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**. The implemented import
capability, this successful import, launch-wide timetable coverage and runtime adoption
are separate statuses. No new numerical pilot quota or full-feed requirement follows.
No actual routing candidate/search/Journey/runtime adoption has occurred. Phase 3
remains In Progress. Only hashes, sizes, counts, workflow IDs and status are recorded;
private railway IDs, locators, timetable clocks, Unix seconds and itineraries are absent.

## 14. Repository-only routing handoff assessment — 2026-10-10

Scope: assess the smallest bridge from the exact §13 facts into existing production
values. No private timetable artifact, archive, extracted source or prior private
execution record is accessed; no import tool/bundle is run; no real candidate is
constructed. This is not implementation or permission to perform the next task.

### 14.1 Existing production constructor path

`TimetableOccurrenceFacts → TrainCandidate → TimetableRideContext →
RouteScheduledContext.timetable → RouteRailProposal → RouteCandidate`

This is composition, not conversion of facts into a new Trip: the verified accepted
Trip snapshot is supplied to `TrainCandidate`, and facts and train meet at the context.

| Existing production value | Enforced invariant and boundary |
|---|---|
| [`TimetableOccurrenceFacts`](../TSUGINO/Domain/Timetable/TimetableOccurrenceFacts.swift) | Exactly one ordered visit per snapshot stop, matching binding and original index; exact-event subsequence is chronological, including across estimated/missing gaps. Retains event quality and eligibility; does not authenticate source/activation. |
| [`TrainCandidate`](../TSUGINO/Domain/Routing/TrainCandidate.swift) | `0 <= boardingIndex < alightingIndex < stopCount`; distinct endpoint StationIDs. Retains the full Trip and original indices; derives anchors and only the ridden movement-bearing line projection. Local structure, not dated-operation or evidence proof. |
| [`TimetableRideContext`](../TSUGINO/Domain/Routing/TimetableRideContext.swift) | Exact facts/train snapshot association; exact departure at boarding, exact arrival at alighting, departure <= arrival. Retains the dated occurrence binding, original indices and endpoints; `matches(train)` requires those same indices and full snapshot. |
| [`RouteScheduledContext`](../TSUGINO/Domain/Routing/RouteScheduledContext.swift) | `.timetable(context)` retains timetable origin/binding with shared Date projections; it does not relabel facts as provider context or grant mixed-source search permission. |
| [`RouteRailProposal`](../TSUGINO/Domain/Routing/RouteRailProposal.swift) | A timetable context requires `.matched(train)` and `context.matches(train)`; unresolved travel cannot carry it. Does not authenticate producer output. |
| [`RouteCandidate`](../TSUGINO/Domain/Routing/RouteCandidate.swift) | Nonempty rail-first/last legs; adjacent endpoint continuity; no adjacent walks; no repeated matched TripID, even on different dates. Scheduled contexts remain chronological across retained rail contexts, without resetting across walks or absent contexts. Local structure, not search completeness or connection evidence. |

[`TimetableOccurrenceBinding.matches`](../TSUGINO/Domain/Timetable/TimetableOccurrenceBinding.swift)
compares the exact address and TripID, ordered stops, line segments, coverage and
service-type segments. Trip equality alone compares identity and is insufficient.
`TrainCandidate` has no independent date/view: context matching retains its address,
but does not independently authenticate date/view coherence, activation or eligibility.
In particular, `TimetableRideContext` does **not** enforce allowed boarding/alighting.
Those remain Data/private-harness admission obligations under verified authorities.

The supplied complete exact/allowed visits fit the constructor's data shape in
principle. **`REAL_TIMETABLE_FACTS_CAN_REPRESENT_ONE_CANONICAL_DIRECT_RIDE`** is
representational readiness using existing Domain types, not a completed private
composition, certification of indices `0`/`13`, or a route-search proof.

### 14.2 RouteScheduleAdmission ownership

[`RouteScheduleAdmission`](../TSUGINO/Data/Routing/RouteScheduleAdmission.swift)
validates already-qualified generic/provider Date endpoints and creates
`ProviderScheduledContext` values. It checks finite instants, request lower bounds
and chronology across all known endpoints before handling missing endpoint pairs;
missing pairs are accepted only with the explicit departure-intent assertion.
It also checks cancellation. It neither interprets calendars nor authenticates sources.

Its Date checks are partially analogous; this helper is **not part of the facts →
TimetableRideContext path**. Do not force timetable facts through its provider-context
API or add a competing chronology validator. Candidate A needs no search request or
search-result wrapper. If a separately scoped variant accepts a request, request-relative
lower-bound admission remains an explicit consumer obligation; current context/candidate
constructors alone do not enforce it.

### 14.3 DEBUG solver ownership and test reuse

[`SyntheticInternalRouteSearcher`](../TSUGINO/Data/Routing/SyntheticInternalRouteSearcher.swift),
[`SyntheticInternalRouteEngine`](../TSUGINO/Data/Routing/SyntheticInternalRouteEngine.swift)
and [`SyntheticInternalRouteInput`](../TSUGINO/Data/Routing/SyntheticInternalRouteInput.swift)
are `#if DEBUG`. Their qualification, discovery, enumeration, admission orchestration
and finalization are not a real production solver owner. Admission calls into production
`TrainCandidate`, `TimetableRideContext`, `RouteRailProposal` and `RouteCandidate` are
reusable contracts; promoting the whole DEBUG admission/engine is not required for A.

| Repository regression evidence | Reusable contract | Synthetic premises that cannot authenticate real data |
|---|---|---|
| [`TimetableRideContextTests`](../TSUGINOTests/TimetableRideContextTests.swift) | Full snapshot association despite ID-only Trip equality, original/repeated indices, dated address, exact endpoint quality, partial coverage preservation, matched attachment, chronology and duplicate-Trip rejection. Explicit unknown/prohibited permission cases show context construction alone is not eligibility admission. | Invented facts do not establish real activation, source authority or allowed endpoints. |
| [`SyntheticTimetableRoutingIntegrationTests`](../TSUGINOTests/SyntheticTimetableRoutingIntegrationTests.swift) | Converted facts preserved unchanged; snapshot/date/indices, qualified exact endpoints, timetable context origin and request chronology where applicable; explicit inactive/unavailable outcomes. | Stipulated complete dated universe/interval inventory, active stations/lines, policy references and affirmed continuity. |
| [`SyntheticTimetableOptimalRoutingIntegrationTests`](../TSUGINOTests/SyntheticTimetableOptimalRoutingIntegrationTests.swift) | Exact facts/bindings and endpoints preserved through candidate composition; eligibility/quality and held input prevent unsupported success; fixture optimal/tie behavior. | Complete alternatives, invented directional connectivity, transfer allowances, finite horizon and exhaustive enumeration. |
| [`SyntheticTimetableBatchRoutingIntegrationTests`](../TSUGINOTests/SyntheticTimetableBatchRoutingIntegrationTests.swift) | Batch slots retain exact facts; coherent view/binding association and failure/inactive/unknown-connection distinctions remain explicit. | Stipulated batch/interval completeness, station/line states, policy references, continuity and total connection allowances. |

The prior successful synthetic tests establish these contracts, not a newly run test
result or real inventory assertion. Complete universe, active station declarations,
invented connectivity/policy references and synthetic allowances must not cross into A
as asserted real evidence. No production real occurrence-inventory supplier or internal
enumerating solver owner is established by this audit.

### 14.4 Smallest justified next slice

| Candidate | Scope and assessment |
|---|---|
| A — owner-only private direct-ride admission harness | Verify exact pinned S9/import bundles and retained approved profile/provenance; reconstruct the actual accepted Trip/facts; take explicit owner-supplied original indices; compose existing production values and verify exact preservation for one single-leg candidate. Smallest useful slice; no new inventory type required first. |
| B — production imported-facts inventory adapter | Own coherent view, occurrence availability and exact facts associations for a future consumer. Useful broader reusable Data boundary, but not needed to compose one verified occurrence and explicit interval. No solver by itself. |
| C — production internal route solver | Requires real inventory/evidence, production ownership and complete search policy implementation; one occurrence does not supply these prerequisites. Not justified as the next slice. |

Selected primary next task: **`P3_T1_REAL_FACTS_TO_DIRECT_ROUTE_ADMISSION_BRIDGE_NEXT`**.
**`NO_NEW_PRODUCT_DECISION_REQUIRED`**: bounded A merely composes already Accepted
DEC-078/079 values and implemented routing contracts, without choosing search/solver
policy. Tool/file placement alone needs no new product decision. Implementation and
private access still require separate owner authorization; this assessment grants neither.

### 14.5 Explicit interval and fail-closed admission

An owner-supplied boarding index `0` and alighting index `13` would span the entire
represented 14-visit range without slicing/reindexing the Trip. Accepted S9 coverage
is false/false: unknown service origin/destination remain unknown, even for this full
represented traversal. The imported facts supply exact departure/arrival and allowed
boarding/alighting at these indices in principle.

`TrainCandidate` also requires distinct endpoint StationIDs. Nonadjacent repeated
stations are permitted in Trip, so the safe aggregate cannot certify that `0` and `13`
differ. A future authorized harness must verify this and every existing constructor;
failure must produce no candidate and must not automatically choose a replacement
interval. A different interval would require explicit owner supply. No additional
interval-selection algorithm is needed for a valid explicit interval.

Before composition, A must privately revalidate exact authorities and snapshot/binding
association, dated active occurrence/provenance, selected allowed endpoints and relevant
affirmative S9 movement/continuity evidence. Constructors supply local chronology and
association checks, not those external facts. Output must retain full Trip, dated
binding, original indices, exact endpoints and timetable origin; no synthetic evidence
may fill a missing authority. No graph/search/ranking/completeness claim is needed.

### 14.6 Claim boundary and remaining solver prerequisites

If separately authorized and successful, A would prove one accepted Trip snapshot,
one dated active occurrence, exact ridden endpoints/context, one canonical matched
proposal and one structurally valid direct `RouteCandidate`. It would not prove fastest
arrival, all alternatives, transfer feasibility, equal-optimum completeness, network-wide
coverage, search-horizon completeness, production solver resource behavior or launch-wide
routing. It must not emit `RouteSearchResult`/`InternalSearchSuccess` or claim `noResults`.
DEC-086's earliest-arrival then fewer-train-changes objective, all distinct equal optima
and evidenced through-service treatment remain Accepted, but are not exercised by A.

A real solver still needs a complete dated occurrence inventory for its search scope,
station/line availability, explicit interval inventory, continuity and directional
connection/transfer evidence with allowances, coherent source/view/profile authority,
a finite supported horizon, complete enumeration/optimality/all-ties proof, and justified
production resource/cancellation policy with a production owner. These scope-wide
requirements block a full solver, not composition of one explicitly evidenced direct
ride. A still fails closed if its own exact authority, activation, eligibility,
snapshot, continuity, interval or time requirements cannot be verified.

### 14.7 Exact next safe action — not begun

Obtain separate owner authorization for the bounded private Candidate-A harness,
bound to the exact pinned S9/import authorities and an explicit owner-supplied
original-index interval. Then verify those authorities, reconstruct the accepted
Trip/facts, compose one single-leg candidate through the existing production constructors
and verify exact preservation, failing closed on any mismatch. Keep private IDs/times
out of repository output. No archive reopening, general inventory adapter, solver,
search result, AppEnvironment/UI/Journey/runtime wiring is part of that bounded proposal.
This task performs only the documentation/audit and does not begin that action.

## 15. First real direct-route admission bridge — 2026-10-10

**`FIRST_REAL_P3_T1_DIRECT_ROUTE_ADMISSION_BRIDGE_COMPLETE`.** Supplied owner
execution/review evidence at repository commit `6a76f0f8d6e025887bb60ad689e44ef87edb2fcb`:
one accepted real S9 Trip and one accepted dated occurrence composed through existing
production constructors for service date **`2026-03-16`**, original indices **`0...13`**.
This update does not reopen any private authority, harness, receipt or review artifact.

| Supplied private evidence | Bytes | SHA-256 |
|---|---:|---|
| Execution receipt | 2159 | `04911e66091966abcb37fad81fe71418f717a7c8e3a19338c791df6113a3901a` |
| Independent review | 2743 | `89844972cbb0b6a182270060ac418fcf466d3c9fe06cd52b2c04ef18912c7b1e` |

Both published S9 and full timetable import verifiers passed `bundleValid unchangedReplay`
read-only. Exact Trip/facts binding passed; endpoints were distinct; Trip coverage stayed
false/false, with no claim of known service endpoints or complete external service extent.
Index 0 boarding was allowed with exact departure; index 13 alighting was allowed with
exact arrival. Actual `TrainCandidate` construction passed with line-sequence count 1;
`TimetableRideContext` passed with exact retained dated binding/original indices/endpoints,
context matching train and departure <= arrival. Actual matched `RouteRailProposal`
and single-leg `RouteCandidate` construction passed. Full snapshot/anchors/context were
preserved: **one rail leg / zero walking legs / zero transfers / matched travel /
timetable scheduled context**.

Author and separate reviewer independently compiled exact repository production/tool
sources without DEBUG flags and ran the same bounded composition. Independent review:
**25/25 PASS**, no unresolved findings. Provider context and RouteScheduleAdmission
were not used; no searcher/solver, fastest/completeness claim, canonical candidate
serialization or repository/runtime mutation occurred. The candidate remained in memory.

This proves real canonical Trip/facts compatibility, qualified exact endpoints and
preservation through one canonical matched direct candidate. It proves neither route
enumeration/search, fastest/all-alternative or optimal/tie completeness, transfer
feasibility, complete dated inventory, production solver readiness, launch-wide coverage
nor runtime adoption. **`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**
is unchanged. The next assessment below consumes repository/supplied evidence only.

## 16. Minimum production occurrence-inventory boundary — 2026-10-10

### 16.1 Need and authority

Primary next task: **`P3_T1_REAL_OCCURRENCE_INVENTORY_ADAPTER_NEXT`**.
Candidate A has exercised the production composition; the remaining production gap
is an explicitly qualified immutable collection of dated occurrence availability,
not another ordinary constructor demonstration or a solver. Recommend the working
name **`TimetableOccurrenceInventoryView`** under **Data/Timetable**, consistent with
existing TimetableOccurrence/TimetableView naming. It is a technical design recommendation,
not a new implemented type, persistent schema or accepted search policy.

**`NO_ADDITIONAL_DIRECT_RIDE_CASE_REQUIRED_BEFORE_INVENTORY_BOUNDARY`**. Repository
evidence includes [RoutingValueTests](../TSUGINOTests/RoutingValueTests.swift)
(`originalSnapshotAndRepeatedVisitArePreserved`, `throughServiceAndLimitedStopStructure`,
full-lap rejection) and [TimetableRideContextTests](../TSUGINOTests/TimetableRideContextTests.swift)
(repeated subinterval binding, changed-snapshot rejection, all coverage combinations,
missing/estimated endpoint rejection). Timetable routing integration tests also retain
unknown/prohibited eligibility, legitimate prohibited exclusions and held quality states.
These are distinct contract checks, not proof that every real source supports those forms.
No currently identified unsupported constructor/evidence shape blocks Candidate B.
Another ordinary interval of this one-Line Trip or same-profile all-exact date would
repeat the existing proof. Revisit only if a newly identified repeated/multi-Line/source
form lacks the required contract/evidence; do not manufacture a multiple-example quota.

Basis: Accepted DEC-078 producer separation, DEC-079 coherent admission/coverage,
DEC-080 scoped inputs, DEC-085 bounded conversion/batch authority and DEC-086 objective
and honest cutoff requirements. [ARCHITECTURE §§4/10/16](ARCHITECTURE.md) retains
Data qualification and unchanged Domain values. The [original outline](PHASE_3_INTERNAL_ROUTING_CONTRACT_OUTLINE.md)
and unselected consumer details remain Proposed/historical where not separately accepted.
This assessment grants no implementation or real-access authorization.

### 16.2 Existing synthetic concepts and ownership split

[`SyntheticInternalRouteInput`](../TSUGINO/Data/Routing/SyntheticInternalRouteInput.swift),
[`SyntheticInternalRouteEngine`](../TSUGINO/Data/Routing/SyntheticInternalRouteEngine.swift)
and [`SyntheticTimetableBatchAssembler`](../TSUGINO/Data/Timetable/SyntheticTimetableBatchAssembler.swift)
are DEBUG-only. The engine requires declared intervals/slots independently of discovered
paths, coherent views, active stations/lines, continuity and directional allowances.
The batch checks an exact declared/received address set and same-Trip snapshot coherence;
it explicitly does not authenticate source or close search coverage. Its eight-slot
safeguard is experimental, not a production inventory capacity.

| Concept | Production owner recommended by this audit |
|---|---|
| View identity, qualified source/profile/mapping/zone generation, dated slots, exact snapshots, occurrence availability, original-index interval evidence and finite inventory declaration | A — Candidate B, Data/Timetable, with traceable external qualification dependencies |
| Station/line canonical membership, retirement and supported static data | Existing accepted static railway authority; Candidate B retains exact compatibility references, not a second state inventory |
| Same-station train changes, directional walking links, connection inventory/validity and all-component allowances/policy | C — separately qualified connection/transfer boundary; neither timetable facts nor topology proves these |
| Request intent, date/horizon expansion, applicable inventory closure, interval/relation requirements, enumeration, pruning, optimum/ties and cutoff/accounting | B — future solver/search-scope responsibility, separate from Candidate B's finite declaration |

The A/B/C labels in this ownership table classify facts, not the earlier Candidate-A/B/C
task alternatives. Existing [ordinary](../TSUGINOTests/SyntheticTimetableRoutingIntegrationTests.swift),
[optimal](../TSUGINOTests/SyntheticTimetableOptimalRoutingIntegrationTests.swift) and
[batch](../TSUGINOTests/SyntheticTimetableBatchRoutingIntegrationTests.swift) integrations
preserve exact facts/bindings and explicit holds, but stipulate complete universes,
station/line states, policies, connectivity and allowances. None is real inventory authority.

### 16.3 Minimum immutable Data contract

| Element | Minimum technical contract and Accepted basis |
|---|---|
| Coherent generation | One existing `TimetableViewID`; immutable resolved source/profile/mapping/zone authority references, interpretation applicability and exact dependency/version pins. DEC-078/079 view association; UUID/token equality is not authentication. |
| Declared scope | A finite explicit ordered set of `TimetableOccurrenceAddress` values supplied independently of loaded entries, with traceable declaration authority. No request/date expansion or network-wide default; DEC-078 request independence and §10's bounded declared inventory. |
| Slot binding | Exactly one supplied slot per declared address, no undeclared/duplicate/missing slot; each retains `TimetableOccurrenceBinding` and the entire exact Trip, including original indices/coverage. DEC-060/078 and §10 snapshot association. |
| Occurrence state | `active(facts)`, conclusively `inactive` with no events, or `unavailable` with bounded category/reason and no fabricated facts. Retain unsupported/insufficient-evidence distinctions from qualified producer outcomes. DEC-078/085. |
| Interval availability | Per-active-occurrence finite independently declared original-index interval scope, coverage declaration, and evidence-bound records; affirmative records form `verifiedIntervals`. Unknown/held interval evidence remains explicit; see §16.6. DEC-079 evidenced movement/continuity. |
| Completeness | Complete only for the exact finite declared scope with qualification reference, or unknown/incomplete; distinct occurrence-slot and interval-coverage declarations. §10 and DEC-079/080 required-coverage obligations, not solver completeness. |
| Static compatibility | Exact compatible static revision/schema and S9/mapping association references; membership/retirement authority remains external. DEC-073/076/079 coherent canonical view. |

Reuse unchanged `TimetableOccurrenceAddress`, `TimetableOccurrenceBinding`,
`TimetableOccurrenceFacts`, `Trip` and `TimetableViewID`. New internal immutable,
Sendable Data values can carry these technical evidence/declaration associations;
no new Domain model, provider branch or snapshot equality/Codable is needed.
Full dependency closure must be resolvable by the qualifying Data/offline stage, not
an untraceable `verified=true` flag. Initial local value construction checks supplied
associations; it does not authenticate a source, owner statement or legal permission.
Do not link owner-only macOS tool IO into app Data or add a raw-source parser here.

### 16.4 Completeness: finite declarations, not search success

Recommend completeness **per immutable view's explicitly declared finite address scope**,
with separate per-active-occurrence interval coverage. Do not use bare per-view UUID,
per-Trip identity or future query parameters as the completeness proof. A declaration
must identify required membership independently of whatever entries happened to load,
retain its exact qualified authority/dependency reference and match received membership.
Dates are explicit supplied labels; no calendar-range enumeration is performed by B.

`completeForDeclaredScope` means every declared address has an explicit qualified state;
it says nothing about any undeclared Trip/date/address, network or future request horizon.
Unknown/incomplete preserves lack of that coverage authority even when local entries are
well formed. Missing a declared slot is a construction error, not inferred inactive or
an automatically invented unavailable slot. A caller may explicitly supply a qualified
unavailable outcome for a declared address, retaining why it is held.

Completeness of enumeration and usability are independent: a complete declared set
containing an unavailable slot is not a complete usable routing input. Such holds must
not disappear during projection. Complete empty scope plus empty entries is distinct
from unknown empty inventory; the former closes only that explicitly empty declared
scope. For a nonempty declared Trip/date set, conclusive inactivity requires explicit
inactive slots, not absence. No omitted address becomes known absent or inactive.
Neither empty form nor `no occurrence found` produces route-search `noResults`.
A future consumer must independently establish that its whole applicable search scope
is covered, every required hold resolved and enumeration completed.

### 16.5 Availability and snapshot/view coherence

Active retains the exact already qualified facts unchanged; incomplete time fields or
unknown eligibility may legitimately remain in those facts. Inactive has no event body.
Unavailable retains bounded unsupported/insufficient-evidence category and applicable
existing diagnostic/index association, never invented event facts. Known invalid producer
input or structural contradictions reject construction; they are not downgraded into an
apparently usable view. Current published TimetableImport bundles represent successful
active facts only: this design does not claim they serialize inactive/held outcomes.
Those states need explicitly qualified producer inputs; a missing bundle is never inactive.

All addresses/facts/interval records must match one declared view and qualified generation.
For the same TripID across dates, compare full snapshots using production
`TimetableOccurrenceBinding.matches` with a comparison binding at the current address;
Trip equality alone is insufficient. Preserve each original dated binding. Changed
snapshot or incompatible revision requires a newly qualified coherent view or an explicit
future revision workflow, never `latest by ID`, silent rebinding or in-place mutation.

Pin exact S9/import/profile dependencies and source/mapping/zone interpretation authority;
reject mixed/incompatible generation or dangling associations. Legitimate per-service
calendars may differ within a qualified generation. Matching tokens/digests establish
association/integrity, not semantic compatibility: known conflicting shared definitions
remain held/rejected by qualification, never hidden by the value constructor. No new
source interpretation, global view-ID registry or automatic revision resolver is proposed.

### 16.6 Evidenced intervals versus endpoint usability

Require explicit finite interval records for each active occurrence, addressed by its
exact binding and original boarding/alighting indices, with movement/continuity and
applicable service-restriction authority references. Validate range/order/distinct anchors
using existing production structure. Do not derive all `i < j` pairs from stop count,
interpolate between evidenced spans, crop/reindex the Trip or infer a continuous ride
from graph reachability. The real `0...13` bridge had separately supplied verification
authority; neither its success nor authorization certifies other intervals.

Separate **structurally/evidentially verified interval** from **schedulably usable exact
ride**. Retain a verified interval even when facts contain prohibited/unknown permissions
or missing/estimated required endpoints; preserve the actual facts instead of filtering
the interval away. A verified record proves supported continuous span, not permission
to board, exact-time usability or actual train operation. Unknown continuity remains a
held interval record, not part of the affirmative `verifiedIntervals` subset.

An exact routing consumer must additionally require allowed boarding at start, allowed
alighting at end, exact start departure and exact end arrival, then use the existing
TrainCandidate/TimetableRideContext path. Prohibited permission is an explicit negative;
unknown permission or missing/estimated required event is held for exact routing, not
a legitimate omission/noResults proof. No provider-context detour or second chronology
validator is introduced. Inventory stores evidence and facts; future solver determines
which evidenced intervals and usable endpoints are required for its declared scope.
An empty verified list never proves every other interval absent; unknown interval
coverage and known complete-for-declared-interval-scope must remain distinguishable.

### 16.7 Static network, connection and search boundaries

Do not copy the synthetic five-way station-state map or line set into B as another
canonical authority. Reuse [RailwayDataRepository](../TSUGINO/Domain/Repositories/RailwayDataRepository.swift)
and accepted prepared static data behind Data. A compatibility reference should identify
[RailwayArtifactMetadata](../TSUGINO/Data/Storage/RailwayArtifact.swift)'s schema and
exact current `RailwayArtifactRevision` (dataVersion, registryRevision, input hashes,
content hash and chain association), plus compatible S9/mapping dependencies.
[SQLiteRailwayRepository](../TSUGINO/Data/Storage/SQLiteRailwayRepository.swift) exposes
metadata/identities and checks an expected revision at open; the Domain protocol does not
expose revision or a ready-made synthetic station-state inventory. No new protocol or
real static/timetable compatibility is claimed here. Qualification must establish that
relationship separately; opaque ID agreement or non-nil station lookup is insufficient.

Same-station interchange, directional walking connections, train-change semantics,
applicability and total alight/interchange/board allowances belong to a separately
qualified connection/transfer view. Station identity or chronological order cannot
create them. B contains no connection policy, adjacency graph or default allowance.

Depart-not-before, service-date/horizon selection/expansion, every relevant occurrence
and interval/relation requirement, route enumeration, optimum/equal ties, pruning,
cutoff and handoff accounting stay with future search scope/solver ownership. B's
finite address declaration can support that proof but cannot substitute for it.
DEC-086's earliest arrival then fewer changes/all distinct equal optima remains
Accepted and unexercised by this inventory assessment.

### 16.8 Resources, persistence and authority

Before implementation, define finite construction budgets for occurrence/address count,
dates, unique snapshots, intervals per occurrence and total, retained facts/dependency
bytes and whole-view bytes. Reject overflow without truncation, partial success or
silently weakened completeness. Account for shared snapshot storage and bound all loops;
do not inherit the DEBUG eight-slot cap or owner-only importer limits as runtime capacity.
**`NUMERIC_PRODUCTION_LIMITS_REQUIRE_SEPARATE_IMPLEMENTATION_EVIDENCE`**: select and
justify technical construction limits with representation/workload measurements and
boundary tests during the authorized implementation. No production numbers or solver
resource/cancellation policy are selected by this audit; numeric bounds are not a product
decision. Failure to justify finite bounds prevents implementation completion.

Start with a **pure immutable production Data value plus invented tests**, no IO,
owner-only artifact format, SQLite schema, cache or persistence. It can be independently
verified without data installation, update publication or serialization commitments.
Production compilation, a separately authorized real pilot, app runtime adoption and
shipping data rights are four distinct gates. Existing license/registry/publication/
delivery/bundling requirements remain; no technical value grants permission to ship data.

### 16.9 Layering and smallest invented-only implementation

Data qualification/offline authority stages verify applicable imported bundle/profile/S9
evidence and static compatibility; the internal Data/Timetable inventory retains exact
qualified references, states, declared scope/coverage and interval evidence. The initial
pure-value slice implements local association/consistency only, using invented supplied
qualified inputs; real IO/authority qualification remains separately gated. Domain's facts,
TrainCandidate, TimetableRideContext and RouteCandidate remain unchanged. A future solver
captures one coherent inventory with compatible static/connection views, enumerates and
proves the accepted objective. Application retains request lifecycle/cancellation and
publication ownership; AppEnvironment composition remains unconfigured. This does not
select detailed solver scheduling/supplier mechanics beyond existing accepted boundaries.

Completion criteria for a separately authorized Candidate-B implementation:

1. Production-compiled immutable internal Data values, reusing existing Domain bindings;
   no DEBUG-only dependency, new source interpreter or Domain semantic change.
2. Explicit finite address/interval declarations and qualification references; exact
   one-to-one slots, deterministic duplicate/missing/extra rejection, complete/unknown
   empty distinctions and visible holds, with no inference from absence.
3. Fail-closed mixed view/revision/full-snapshot/dependency association checks, including
   same Trip across dates, retained old/new views and incompatible static references.
4. Distinct active/inactive/unsupported/insufficient-evidence cases; invalid input rejects;
   facts/coverage/original indices remain unchanged. Structural interval evidence remains
   separate from prohibited/unknown eligibility and exact/missing/estimated endpoints.
5. Focused invented tests for those cases, repeated/multi-Line intervals, unknown interval
   coverage, no inferred spans, and justified construction-bound exact/overflow cases.
   Verify that no inventory outcome is a route result or completeness/optimality token.
6. Justified finite numeric limits, smallest relevant verification and independent review;
   document exact implemented scope and unresolved real qualification/adoption gates.

No private/real access, networking, persistence, solver, candidate search, AppEnvironment,
Journey or UI wiring belongs to that slice. **`NO_NEW_PRODUCT_DECISION_REQUIRED`**:
this is a technical evidence/inventory boundary under Accepted semantics, not a new
activation, uncertain-time, transfer, completeness or search policy. File placement and
numeric limits do not require a product decision. A genuinely new semantic requirement
discovered later must be surfaced separately instead of silently broadening this design.

Next safe action, **not begun**: obtain separate owner authorization to implement only
these production immutable Data values and focused invented tests, with evidence-backed
construction bounds and independent review. No implementation follows from this audit.


## 17. Candidate-B invented-only production values — 2026-10-10

### 17.1 Implemented boundary

Production source: `TSUGINO/Data/Timetable/TimetableOccurrenceInventory.swift`.
Invented tests: `TSUGINOTests/TimetableOccurrenceInventoryTests.swift`. Domain, DEBUG
synthetic semantics, tools/CLI, AppEnvironment and storage remain unchanged.

`TimetableOccurrenceInventoryView` atomically throws a finite
`TimetableInventoryConstructionFailure` or returns one immutable Sendable Data view.
`TimetableInventoryQualification` binds view UUID, exact source/profile/zone/mapping/
review references and the existing unchanged `RailwayArtifactRevision`. Printable
non-whitespace ASCII references are 1–192 UTF-8 bytes; `ExactValue` is retained without
normalization. Static revision members receive local bounded-text/hash-shape checks,
not history authentication. Qualification equality includes the exact full static value;
station lookup and ID existence are never compatibility proofs. Equal references
represent supplied qualified compatibility, not evidence authentication. Future Data
qualification remains responsible for actual source meaning, revision non-reuse and
compatibility with the actual static repository.

The ordered address declaration is supplied independently from slots. Duplicate
addresses, wrong view, duplicate/extra/missing slots, mixed qualification/static revision,
conflicting same-Trip snapshots, facts/interval binding conflicts and invalid intervals
reject the whole construction. Supplied slot order is mapped into declaration order;
interval order is retained exactly. One representative per Trip is compared with
`TimetableOccurrenceBinding.matches` under each current address, so identical snapshots
on multiple dates succeed and changed stops/lines/coverage/service segments fail despite
Trip's ID-only equality. Inputs remain unchanged after failure.

`TimetableInventoryCompleteness.declaredComplete` and `.unknown` apply only to the
finite declaration under its supplied producer qualification scope. Both require exactly
one supplied slot per declared address. Complete-empty and unknown-empty remain distinct;
neither proves network/date/horizon/search completeness or route `noResults`.

`TimetableInventoryOccurrenceState.active` retains exact occurrence facts and a
`TimetableOccurrenceIntervals` declaration. Inactive contains no facts or intervals.
Unavailable contains only finite source-neutral `.unsupported`/`.insufficientEvidence`
qualification-hold reasons, never fabricated facts or silent omission. Existing
`TimetableDiagnostic` categories describe local validation/time faults; these two Data
qualification-hold cases avoid mislabeling valid-but-held input as structurally invalid.
Tool-local import reasons/raw source strings are absent.

### 17.2 Explicit interval ownership and completeness

`TimetableVerifiedRideInterval` is a supplied immutable original-index declaration;
"verified" describes the supplied authority, not authentication by its memberwise
initializer. Local validity is established only within a successfully constructed view.
Each active `TimetableOccurrenceIntervals` shares one exact occurrence binding,
bounded authority reference and scoped completeness for all its explicit intervals.
This avoids duplicating a snapshot/authority per interval while preventing reuse on a
changed address or full snapshot. The constructor requires 0 <= boarding < alighting <
stopCount, distinct endpoint stations and unique index pairs. Existing valid Trip line
segments already cover all movements; no topology lookup, TrainCandidate construction,
all-pairs enumeration or implicit interval creation occurs.

Complete-empty interval coverage states only that no positive ride interval is declared
under this exact interval authority. Unknown-empty supplies no negative ride conclusion.
Inactive/unavailable have no active interval declaration. No state supplies a route result.
Explicit structural intervals are retained even with prohibited/unknown boarding or
alighting and missing/estimated required events. A future admission/solver layer must
separately evaluate eligibility and exact endpoint times; this constructor neither filters
scheduled usability nor duplicates Domain chronology validation.

Static station/line/topology state is referenced, never copied. Transfers, same-station or
walking connections, allowances, route requests, date expansion/horizons, enumeration,
ranking/optimality/ties, search completeness and execution cutoffs remain separate future
qualified boundaries. No IO, networking, serialization/persistence, actor/global mutable
state, runtime wiring, UI or Journey behavior is added.

### 17.3 NUMERIC_PRODUCTION_LIMITS_IMPLEMENTATION_EVIDENCE

A generated invented Swift representation/local-validation study ran **before production
constants were fixed**. It compiled the current production Domain identifier, Trip,
segment, coverage, address, binding, facts, diagnostic and time sources with Swift 6.4
`swiftc -O` on arm64 macOS. It generated recurring Trips with `invented-*` identifiers,
opaque invented day labels, missing event values and distinct stop indices. Active facts
were built through actual Domain constructors. Explicit interval prefixes were supplied
by the study generator, not inferred by the inventory. Nine validation runs per workload
measured keyed full-snapshot association comparisons and per-supplied-interval checks.
Generation includes actual Domain fact validation; measured validation excludes generation.

The pre-implementation model charged expanded binding content, not allocator or COW
sharing: measured strides were binding 96, visit 136 and two-index span 16 bytes.
`bindingBytes = 96 + tripID/date UTF8 + sum(16 + stopID UTF8) +
sum(32 + lineID UTF8) + sum(32 + serviceTypeID UTF8)`.
Per active modeled slot: `3*bindingBytes + visits*(136+bindingBytes) + 16*intervals
+ 7*96`. This is conservative logical/encoded-equivalent content, **not measured heap**,
wire format, serialization commitment or physical-iPhone performance. The final constructor
also charges declaration addresses and exact qualification/static metadata; actual stress
results are recorded separately below.

| Trips × dates | Addresses | Stops / Trip | Intervals / slot | Total intervals | Expanded logical bytes | Full comparisons | Interval checks | Generation ms | Validation median ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 36 × 2 | 72 | 12 | 6 | 432 | 761,100 | 180 | 432 | 0.571 | 0.101 |
| 120 × 3 | 360 | 24 | 12 | 4,320 | 10,516,770 | 960 | 4,320 | 17.353 | 0.804 |
| 240 × 4 | 960 | 36 | 24 | 23,040 | 54,892,920 | 2,640 | 23,040 | 13.620 | 3.482 |
| 480 × 6 | 2,880 | 72 | 48 | 138,240 | 564,954,660 | 8,160 | 138,240 | 71.754 | 18.029 |

A separate non-author reran the same generated study: byte/work counts matched exactly;
validation medians were 0.106 / 0.774 / 3.339 / 17.823 ms. Token scans at 48/96/192
ASCII bytes × 10,000 checks scanned 480,000/960,000/1,920,000 bytes and took
0.732/1.452/2.769 ms in the author run. Study source/results remain in the new invented-only
verification workspace `/private/tmp/tsugino-candidate-b-invented-20261010/main.swift`
and `study.txt`; no prior private workspace or railway authority was opened.

These are hypothetical bounded Phase-3 input workloads, not assertions about real operator
coverage: several hundred recurring runs over a few explicitly supplied dates and tens of
passenger stops/positive spans. A large expansion demonstrates why separate axes need a
combined safeguard. The selected limits provide headroom above the 240 × 4 study:

| Production safeguard | Limit | Evidence/rationale |
|---|---:|---|
| Declared addresses and supplied slots | 2,880 each | 3× 960 studied; largest modeled declaration count |
| Unique Trip snapshots | 480 | 2× 240 studied |
| Distinct opaque service-date labels | 6 | 1.5× 4 studied; no calendar/horizon semantics |
| Stops per supplied snapshot | 72 | 2× 36 studied; segment counts additionally <=71, already implied by valid Trip structure |
| Intervals per active occurrence | 48 | 2× 24 studied |
| Total intervals | 92,160 | 4× 23,040 studied; below the 138,240 Cartesian expansion |
| Qualification references and each retained ID/date/version/role text | 192 UTF-8 bytes | 2× studied 96-byte reference; bounded-prefix rejection before hashing/equality |
| Static revision input records | 32 | Reuses the existing RailwayArtifact revision format maximum, not importer or DEBUG capacity |
| Expanded logical payload | 120,000,000 bytes | ~2.18× the 54.9 MB study; rejects the modeled 565 MB expansion |

These independent maxima are **not a promise that every Cartesian combination fits**.
The actual maximum-count test uses 480 Trips × 6 dates × 12 stops × 32 spans to hit
2,880 addresses and 92,160 total intervals within the payload cap. A 72-stop variant
with individually valid counts must fail the payload guard atomically. No truncation,
partial view or weaker completeness is returned. Payload is a fixed logical charge:
48-byte address header and an additional 48-byte binding header, plus independently
retained address/Trip ID spellings,
136-byte visit header plus its actual expanded full binding,
16-byte intervals, bounded actual UTF-8 field bytes and explicit qualification/static
headers. Canonically equal Unicode in Domain can have different UTF-8 lengths: every
actual retained visit binding is individually bounded/charged, without changing Domain
equality. Both address and snapshot Trip ID spellings are independently bounded. Caller allocations/Domain value construction precede this API; the safeguards
bound this API's retained content and work, not upstream allocation. Checked budget
subtraction precedes addition; exact-budget/+1/Int.max tests prove no integer wrap.

After implementation and the review-driven Unicode accounting corrections, a second
invented host study compiled the **actual final production constructor without DEBUG**,
the same actual Domain sources and source-extracted existing ExactValue/static-revision
definitions. Nine constructor runs excluded generation; missing facts, two line segments
and one shared exact interval authority were used. This confirms the final preflight work
cost, separately from the preceding pre-constant model:

| Addresses / stops / intervals | Actual logical bytes | Actual constructor median ms | Outcome |
|---|---:|---:|---|
| 72 / 12 / 432 | 864,205 | 0.452 | constructed |
| 360 / 24 / 4,320 | 11,399,211 | 4.670 | constructed |
| 960 / 36 / 23,040 | 58,242,721 | 23.644 | constructed |
| 2,880 / 12 / 92,160 | 35,833,341 | 23.458 | constructed |
| 2,880 / 72 / 92,160 | no view returned | 44.668 | resourceLimit during payload preflight |

These remain descriptive arm64 macOS timings, not iPhone measurements or runtime adoption.
Reproduction source/results are `Actual.swift` / `actual-study.txt` in the same new
invented verification workspace. The repository test generator independently exercises
the constructor's count maximum, total-interval +1 and payload-overflow cases on Simulator.

### 17.4 Complexity and verification

Top-level counts are checked before traversal. All strings/snapshot arrays, total
interval counts and expanded logical payload are preflighted before association hashing
or full snapshot comparisons. Domain facts already guarantee exact visit association and
chronology; neither is redundantly revalidated for every interval. With A addresses,
U unique Trips, D dates, S stops, K static input records, B bounded text bytes and I
supplied intervals, expected association work is `O(A*(S+K)*B + I*B)` using keyed
representatives and one interval-binding comparison per active slot, rather than pairwise
snapshot comparison or interval enumeration. Actual retained visit-binding payload
preflight additionally costs `O(A*S*S*B)`: each of at most S visits retains a full
snapshot whose actual text must be bounded, including canonically equivalent Unicode
spellings. Total expected construction is `O(A*(S*S+K)*B + I*B)`; no pairwise
comparison across A slots is introduced. All dimensions are independently finite
and additionally payload-bounded. Auxiliary storage is `O(A+U+D+intervalsPerOccurrence)`;
retained arrays preserve supplied order. Hash-table collision worst cases can increase
lookup cost up to bounded quadratic in A; they do not change full snapshot semantics or
permit unbounded input. No search complexity claim follows.

Focused tests cover state/declaration/completeness/association, cross-date full snapshot
conflicts, facts and interval ownership, invalid/extreme/duplicate indices, repeated stops,
multi-Line structure, endpoint quality/permissions, exact/+1 bounds, generated stress,
unchanged inputs and Sendable transfer. Source/dependency audit checks pure production
compilation and exclusion of DEBUG, IO, transfer/search/runtime concerns.

Author final-source verification passed on explicit iPhone 17 / iOS 26.3.1 Simulator
`84E47945-9D2E-446F-8C40-B835A9D15880`: **90 test functions / 164 expanded cases**,
zero failures/skips, including **18 new inventory functions / 48 expanded cases**.
The seven unchanged suites passed: TimetableValueTests 16/21, TimetableRideContextTests
10/14, SyntheticTimetableBatchTests 13/26, SyntheticTimetableRoutingIntegrationTests
7/16, SyntheticTimetableBatchRoutingIntegrationTests 6/7,
SyntheticTimetableOptimalRoutingIntegrationTests 4/6 and RoutingValueTests 16/26
(functions/expanded cases). Standard Release app/extension build passed for the same
explicit Simulator. No warning identifies the new inventory source/tests; existing
unmodified Domain concurrency-conformance, AppIntents metadata and AppIcon asset-catalog
warnings remain (the fresh independent build also exposes the existing asset warnings).
No physical-device interaction or validation was needed for these pure values.
Release module symbolgraph extraction at internal access confirms inventory, qualification,
interval, state, limit and failure declarations are present; zero `Synthetic*` declarations
are present. Unused unwired internal values may be eliminated from the linked executable
by Release optimization, which does not imply runtime adoption or a DEBUG dependency.

Author result bundle/logs: `verified-tests.xcresult`, `verified-tests.log` and
`verified-release.log` in the new invented verification workspace. Two independent
review findings about canonically equivalent Unicode spellings were fixed: independently
bound/charge the snapshot Trip ID and each actual visit binding. Both have regression
coverage; Domain equality/association/chronology remain unchanged.

Independent non-author review **24/24 PASS**, with no unresolved findings. The reviewer
independently reproduced the pre-constant invented study, inspected the actual final
constructor study and author unchanged-regression results, then reran **18 focused
inventory functions / 48 expanded cases** on the same explicit iPhone 17 / iOS 26.3.1
Simulator: zero failures/skips/runtime warnings. A separate fresh standard Release
app/extension build passed; Release module declarations were independently inspected
with zero Synthetic declarations. Source/test SHA-256 pins matched before/after the
independent executions. An initial sandbox-only Simulator destination-resolution failure
occurred before compilation/tests; the authorized rerun with CoreSimulator access passed.
Independent outputs are in the new invented-only directory
`/private/tmp/tsugino-candidate-b-independent-20261010-0d1syrkd`.

**`P3_T1_OCCURRENCE_INVENTORY_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`**.
Final scope/privacy audit: only one production Data source, one invented test source and
ROADMAP/producer/ARCHITECTURE documentation changed. No Domain, DEBUG semantics, tools,
project configuration or unrelated files changed; no real/private railway/profile/bridge
artifact was accessed. Whitespace checks include both new untracked files. Work remains
unstaged/uncommitted, index empty; published branch/upstream remain
`1d7bef9a332269578fc5c024f43dd6f92627ffb3` (0/0), main remains
`e8a463d51f14b3cb1027960c63244b694579a71b`. No staging, commit or push occurred.

This is **not** real inventory acceptance, real solver implementation, P3-T1 completion,
production route-search readiness, runtime adoption or data delivery authorization.
Exact next safe action, not begun: **Owner review and publication of the independently
approved Candidate-B production inventory values. After publication, separately assess
and authorize one bounded real inventory pilot using the already accepted S9/timetable
authorities, without search or solver execution. Do not begin real inventory construction
in the implementation/publication task.**

## 18. First real production occurrence inventory pilot — 2026-10-10

This records the supplied owner execution and independent-review result; no private S9,
timetable, profile, static, harness or receipt artifact is opened by this documentation task.
Execution used repository commit **`0c9b06741b8f1ce8ebce428e943b9c55d78d9a50`**,
service date **`2026-03-16`**, view UUID **`3e8a2c14-1f90-4d85-9af1-0f5e7c22a641`**
and exactly authorized original-index interval **`0...13`**.

| Supplied execution evidence | Result |
|---|---|
| Execution verdict | `FIRST_REAL_P3_T1_OCCURRENCE_INVENTORY_PILOT_COMPLETE` |
| Execution receipt | **1959 bytes**, SHA-256 `be25f8f4ff1097ff373d4d7a2c3f00451814971098e4eb3acd053a4f83779c3c` |
| Independent non-author review | **27/27 PASS**, no unresolved findings |
| Published S9 / timetable verifiers | Both **`bundleValid unchangedReplay`**, read-only; accepted pins matched |
| Accepted DEC-074 provisional static artifact | **217088 bytes**, SHA-256 `c0e38b0a4220a116cbaa9add736e66ce8fdfa58b48e550e2975de0e23fcbc151` |
| Accepted static metadata | Schema **1**, data version **`p2s8-local-provisional-20261001`**, registry revision **6** |
| Static compatibility | **14 stations / 1 active represented line** checked; applicable station/line membership PASS |
| Exact dated facts / S9 binding | PASS; **14 visits**, indices **`0...13`**, **28 exact / 0 estimated / 0 missing**, boarding allowed **14**, alighting allowed **14**, chronology contradictions **0** |
| Actual production inventory initializer | PASS; **1 declared address / 1 slot / 1 unique Trip snapshot / 1 service date** |
| Slot states | **1 active / 0 inactive / 0 unavailable** |
| Explicit interval | Exactly **1 interval `0...13`**, positively authorized and verified |
| Occurrence / interval completeness | **`declaredComplete` / `unknown`**, respectively |
| Logical payload | **15466 bytes**, below the construction bound; production logical accounting, **not measured heap usage** |

Occurrence `declaredComplete` means only **the owner-authorized one-address pilot declaration
was supplied exactly and completely**. It does not establish all occurrences for the Trip,
all dates, all timetable records, search-relevant occurrences, alternatives, network or route-search
completeness. Interval coverage remained `unknown` because only `0...13` was positively authorized
and verified; no other subinterval was inferred absent. A valid interval declaration does not
itself establish exhaustive usable interval coverage for any future request.

The milestone establishes that **one accepted real static revision, one accepted real S9 Trip
and one accepted real dated timetable occurrence can be associated losslessly through the
published production `TimetableOccurrenceInventoryView` together with one explicitly verified
ride interval**. It demonstrates compatibility of `RailwayArtifactRevision`,
`TimetableOccurrenceBinding`, `TimetableOccurrenceFacts` and the inventory boundary. Static
authority remains the accepted local provisional baseline, not production data delivery.

This documentation task accesses no private railway artifact or GTFS/source rows and constructs
no inventory, candidate, search result, searcher/solver or transfer model. It implements no
runtime/Journey/UI or app persistence action. Private identifiers, source keys, locators, clocks,
Unix seconds, qualification tokens and private artifact paths are excluded from this record;
the receipt identity and results above are supplied facts, not a fresh receipt inspection.

It establishes **no search-input closure, connection inventory, transfer feasibility, completed
solver/optimum/all-tie proof, production route-search adoption or runtime delivery**.
**`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`** remains current; Phase 3 remains
**In Progress**. Next: the separately authorized invented-only request-closure slice in consumer
§20.5, not another real pilot or implementation within this documentation task.
