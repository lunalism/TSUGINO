# P3-T1 — Timetable producer-output proposal

**Status:** Accepted semantic boundary — DEC-078; implementation is partial\
**Date:** 2026-10-01

## Current acceptance and implementation boundary — 2026-10-01 Asia/Seoul

Accepted DEC-078: Producer §§2–4 and O1–O6 are accepted; only pure values/local validation are implemented.
Owner acceptance includes the prepared recommended package, not engine adoption,
source compatibility or production delivery. See DECISIONS for the authoritative
acceptance and ROADMAP for exact slice evidence. No calendar interpretation,
conversion, real import or DEC-079 implementation is supplied by the value slice.
P2-S9 and all applicable retained gates remain in force.

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
