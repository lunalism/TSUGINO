# Phase 3 — Internal-routing consumer amendment proposal

**Status:** Accepted conditional amendment — DEC-079; context-only partial implementation independently approved\
**Date:** 2026-10-01

**Governing post-publication final-input audit (2026-10-10):** qualified connection
evidence and immutable assessment were published at
`6f826fe175ce9ec4d0f5fa5c8293c17223e96667`. Earlier publication-pending statements
record their implementation stage. [§22](#22-final-immutable-pre-solver-input-boundary-audit--2026-10-10)
recommends one invented-only `PreparedInternalSearchInput` slice for ride materialization,
exact connection feasibility and Accepted objective binding. Classification:
`P3_PRE_SOLVER_EXECUTABLE_INPUT_VALUES_NEXT`; `NO_NEW_PRODUCT_DECISION_REQUIRED`.
This is documentation/design only; no prepared value, gap helper, solver or real qualification
is implemented. Detailed runtime ownership/adoption and §10.2's Proposed comparator are not accepted.

**Governing Boundary-A implementation update (2026-10-10):** the separately authorized
invented-only production values and immutable assessment are implemented in
`Data/Routing/QualifiedConnectionEvidence.swift`, with focused invented tests in
`QualifiedConnectionEvidenceTests.swift`. [§21.11](#2111-invented-only-boundary-a-implementation--2026-10-10)
records exact scope, measured safeguards and verification status. Earlier A-next/audit-only
wording describes the published design stage; no real qualification, train-gap feasibility,
search/solver or runtime adoption follows. Implementation remains unstaged/uncommitted.

**Governing post-publication Boundary-A audit (2026-10-10):** request-closure values
were published at `3359f1ca197a07e0e18b8d40751450a8a1608390` with the exact reviewed
six-file bytes. [§21](#21-qualified-connectiontransfer-evidence-boundary-audit--2026-10-10)
selects **`P3_QUALIFIED_CONNECTION_TRANSFER_EVIDENCE_VALUES_NEXT`** as the next
separately authorized invented-only implementation slice. This audit defines Data-local
evidence values and an immutable assessment seam only; neither is implemented here.
Earlier publication-pending and B-next statements are historical. Accepted decision
semantics, broader incomplete P3-T1/Phase 3 status and unconfigured live routing remain.

**Production policy update (2026-10-04):** §10 / DEC-086 records bounded owner
acceptance of route-selection/completion rules. Unresolved ownership, algorithm,
configuration and adoption choices remain Proposed; no production engine is adopted.

**Governing post-inventory audit (2026-10-10):** the separately authorized first real
production Candidate-B inventory pilot completed with **27/27 PASS** independent review.
[Producer §18](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#18-first-real-production-occurrence-inventory-pilot--2026-10-10)
records supplied safe evidence. [§20](#20-post-inventory-pre-solver-boundary-audit--2026-10-10)
selects **`P3_REQUEST_SCOPED_SEARCH_INPUT_CLOSURE_NEXT`**, B before qualified connection
payloads A. This is documentation/audit only, with no private access or implementation.
Earlier unresolved-S9/import and next-evidence-review wording describes its historical stage;
bounded real acceptance does not imply launch-wide coverage. Broader P3-T1 remains
**`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**, Phase 3 **In Progress**.

**DEC-080 is accepted only for §9.9 V1–V7 (P1–P4/P6), dated 2026-10-02 Asia/Seoul. P5 and all non-selected policies remain Proposed. Slice A is implemented and approved; slice B local scoped-success values are implemented and independently approved. Production runtime obligations remain unimplemented; the DEC-081 update below records the separate synthetic path.**

**DEC-081 update (2026-10-02 Asia/Seoul):** S1–S6 now accept a finite synthetic-only
execution contract, not production P5. Accepted failure additions and DEBUG internal
preflight/generation/admission are implemented and independently approved for the
corrected bounded synthetic slice.
Historical deferrals below remain applicable to real/production execution. The fixture
universe does not authenticate real coverage, calendars, correspondence or rights.

## Current acceptance and implementation boundary — 2026-10-01 Asia/Seoul

Accepted DEC-079: Consumer §§2–5 and C1–C6 are accepted conditional on DEC-078.
Timetable context construction, separate provider/timetable branches, exact matched
rail attachment and retained-context chronology are implemented and independently
approved as local values/validation only. DEC-080 supplies local scope and scoped-success
structure; slice B independent review approved local values only. DEC-081 supplies
accepted failure additions and synthetic internal preflight/generation/admission, with
independent approval of the corrected bounded synthetic slice. Production connection policy and engine
obligations remain deferred. Owner acceptance does not establish engine adoption, source
compatibility or production delivery. See DECISIONS for the authoritative acceptance
and ROADMAP for saved verification.

**Current update — 2026-10-04:** DEC-085 invented calendar/time conversion and the
test-only timetable-to-search integration are implemented, independently approved and
published. Real source interpretation/conversion/import remain unimplemented; P2-S9
and all applicable retained gates remain in force. This does not resolve production P5.

The body below preserves the historical proposal and acceptance-preparation wording
(including its original “Proposed” labels and undecided implementation choices).
Read semantic recommendations selected by the accepted package as accepted contracts;
read unselected alternatives, engine/profile choices and future tasks as deferred.

## 1. Scope and authority

Scope lock: documentation only. Refine the [consumer outline](PHASE_3_INTERNAL_ROUTING_CONTRACT_OUTLINE.md)
into proposed additions to Accepted DEC-076, using [Proposed DEC-078 producer facts](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md).
DEC-077 accepts evaluation priority and commercial pause only. Neither producer
semantics, internal-engine adoption nor these consumer semantics are accepted.
Accepted DEC-076 and ARCHITECTURE remain unchanged. All clauses below are Proposed.

Recommend IR-E1: a distinct timetable-derived context in the rail context union,
not a positional sidecar and never ProviderScheduledContext with a new meaning.
The minimum internal consumer admits only matched rides with exact dated endpoints.
This is a bounded development profile, not a reduction of the accepted launch scope.
External-provider behavior remains as defined by DEC-076. No algorithm, ranking,
numeric horizon, connection default, persistence schema or implementation is chosen.

## 2. Proposed additions to DEC-076 A/C/E — context and admission

Proposed contract notation (not Swift declarations):

```text
RouteRailProposal.scheduledContext: RouteScheduledContext?
RouteScheduledContext:
  provider(ProviderScheduledContext)             // existing meaning unchanged
  timetable(TimetableRideContext)                // new, distinct origin
TimetableRideContext:
  occurrence: (timetableView, TripID, serviceDate)
  boardingIndex, alightingIndex: original indices
  departure, arrival: exact finite absolute instants
```

The address has DEC-078's one-execution-per-template/date prerequisite. It is not a
new persistent train ID. The timetable view reference is an opaque canonical
reference, not a raw source identifier; Data retains provenance, qualification and
rights evidence. This explicitly proposes adding a view/dated reference to the new
context, not a revision field on Trip or a change to Trip equality.

The context must accompany `matched(TrainCandidate)` only. Its TripID and indices
must equal that TrainCandidate's, and its occurrence must resolve in the retained
view to the **exact same immutable snapshot contents and coverage**, not just an
equal TripID. The two instants must equal that active occurrence's exact boarding
departure and alighting arrival. No context may be moved to another ride, date or
revision. Duplicated indices serve a checked association invariant, not independent
anchors. Snapshot authentication is Data admission, not proof supplied by a value
constructor. No canonical snapshot lookup through mutable “latest by ID” is allowed.

Keep upstream missing/estimated values distinct. The internal minimum admits no
ride whose required endpoint is missing, estimated, unqualified or whose activation
is unresolved. It does not interpolate, copy counterpart times, choose a repeated
visit or fall back to provider/nil context. Missing unused counterparts remain in
the producer facts and do not by themselves invalidate a ride. Producer invalidity
cannot be bypassed by extracting an apparently usable pair from an unavailable run.

Admission validates active canonical endpoints and one coherent view before search.
Retirement never follows a successor automatically. Every qualified ridden endpoint
must be finite, >= departNotBefore, and nondecreasing in itinerary order: ride
departure <= arrival and all earlier-ride events <= later-ride events. Unused Trip
events are excluded from the request bound; they still obey producer validity.
Equality permits ordering only. No generic intent assertion substitutes for these
checks. Internal minimum output requires all timetable pairs; optional provider
contexts and pre-omission checks remain unchanged for external results. Generic
candidate chronology must compare retained pairs across either context origin and
across nil contexts. Mixed provider/timetable result composition is outside this
minimum; the union does not authorize a mixed-source search.

No selection, active Journey, realtime precision or observed operation follows.
Keep immutable/nonisolated/Sendable values, failable construction, no new Codable,
persistent identity or snapshot-containing equality/hash. DEC-076 A5–7 concurrency,
cancellation and Application supersession ownership continue to apply, including
owned computation cancellation and no partial return after observed cancellation.

## 3. Proposed additions to DEC-076 B — generated accounting and outcomes

For an internal implementation, an alternative is a **complete origin-to-destination
itinerary proposal handed to admission**, with a frozen zero-based request-local
position assigned before validation. Search nodes, incomplete paths and legitimate
pre-handoff feasibility pruning are not alternatives. A contradictory complete
proposal already handed off must be omitted, not removed from the sequence.
A generator may not relabel discovered input contradictions as ordinary pruning
or inactivity to manufacture completeness. Shared input defects use request failure.

The internal profile must define deterministic generation/duplicate/pruning rules
before engine enumeration: identical view/request/profile yields the same indexed
sequence; admission neither re-ranks nor deduplicates it. Algorithm and ranking
remain undecided. Legitimate pruning must preserve the profile's claimed search
completeness; a budget cutoff is not pruning proof. These requirements do not assert
that such a generator or completeness proof currently exists.

Each handed-off proposal yields exactly one candidate or omission. Preserve
N=candidate count+omission count, unique increasing omission indices in 0..<N,
complement reconstruction and contiguous 0..<N all-rejected omissions. External
indices still refer to decoded provider alternatives; internal indices refer only
to this generated sequence. Counts prove accounting, not exhaustive route discovery.
No persistent alternative IDs or counts of all mathematically possible paths arise.

Propose appending canonical rejection reasons after DEC-076's existing order:
`unverifiedEligibility`, `infeasibleConnection`, `insufficientScheduledEvidence`.
Use unverifiedEligibility for unknown/prohibited required permission,
unverifiedTransfer for absent directional relation or justified total allowance,
infeasibleConnection for a known gap below that allowance,
insufficientScheduledEvidence for missing/estimated required endpoints,
invalidScheduledContext for finite/order/request-bound violations, and
inconsistentTrainEvidence for occurrence/snapshot/index contradictions. Unknown
activation in required inputs is dataUnavailable, not a route-level no-service claim.
Shared-view contradictions fail the call; a local contradictory generated claim
against otherwise valid inputs omits that proposal. Reasons are unique and ordered
by the extended declaration order; no raw labels, source keys or payloads escape.

Propose a `searchIncomplete` recoverable failure for interrupted enumeration or
resource limits that prevent the required completion proof (cancellation still
throws CancellationError). Do not misreport a computation cutoff as provider outage.
Retain RouteSearchFailure as the only non-cancellation error family.

| Internal condition | Proposed outcome and exact boundary |
|---|---|
| Invalid canonical endpoint | Existing invalidEndpoint before search |
| No accepted/configured search profile, permission or required configuration | configurationUnavailable; do not choose hidden defaults |
| Request outside the explicitly supported profile/intent/horizon | unsupportedRequest |
| Required input view absent, expired, contradictory or insufficiently covered | dataUnavailable, including when some otherwise valid routes are known; minimum returns no partial batch |
| Cancellation observed | CancellationError; no partial result |
| Enumeration interrupted or completion unproved despite usable input | searchIncomplete; no partial result |
| Completed search, complete relevant inputs, no complete proposals handed off | noResults **within the explicitly declared supported domain**, never network-wide impossibility |
| Completed search, at least one handed-off proposal, all rejected | noUsableAlternatives with contiguous omissions; not noResults |
| Completed search with admitted proposals | alternatives with all candidates/omissions, in generated order |

**Deterministic preflight (internal path only):** check cancellation before work and
before returning or throwing a pending non-cancellation outcome. Once observed,
CancellationError takes precedence. Otherwise execute these stages in order and
stop at the first failing stage:

1. Validate locally available configuration, accepted profile selection and permission:
   configurationUnavailable. Missing configuration plus unavailable data therefore
   returns configurationUnavailable; do not load data merely to confirm the latter.
2. Retain and validate the identity/compatibility/validity of the required shared view:
   dataUnavailable if it cannot support endpoint validation. This is not yet the
   request-specific coverage proof.
3. Validate canonical endpoints against that view, origin before destination:
   invalidEndpoint. Conflicting resolution precedes retirement, then unknown identity,
   then unsupported identity within a role; do not follow successors. This explicit
   internal tie-break does not change external-provider behavior or reason vocabulary.
4. Validate intent and temporal bounds against the selected profile: unsupportedRequest.
5. Establish required request-specific schedule/connection/input coverage:
   dataUnavailable. Only then start enumeration/admission.

Within stages mapping to a single failure case, return that case; detailed source
faults stay in Data. No I/O or extra computation is required solely to discover
lower-priority faults. An unavailable higher-stage prerequisite is not bypassed to
classify a dependent lower-stage fault. These rules apply to preflight; a shared
input defect discovered during enumeration still fails the call before any success
or all-rejected outcome. After enumeration, unproved completion yields searchIncomplete
before choosing alternatives/noResults/noUsableAlternatives. Cancellation checks and
owned-work cancellation remain required throughout; no attempt to retroactively
replace an already returned outcome is implied.

Incomplete work prevents
successful output even if admission has accumulated candidates or omissions. Once
observed, cancellation wins over a pending result. Local omissions do not by
themselves imply missing input coverage: a faulty generated claim can be rejected
against otherwise complete inputs. Conversely known missing required source facts
cannot be concealed in an omission to claim complete search. No providerUnavailable,
rateLimited or malformedResponse is invented for pure computation; those remain
available for their accepted external meanings.

## 4. Completeness and horizon obligations — Proposed, still requiring profile design

Every successful internal result, including noResults, must expose a typed **internal search
scope** at the result level. This is a proposed addition to RouteSearchResult's
internal branch, not provider metadata: coherent view reference, search-profile
version and effective absolute bounds, with a reference to the supported canonical
coverage/constraint definition. Candidate and batch accounting values may be reused
inside that branch. External results retain their existing semantics. Exact Swift
spelling remains deferred; the semantic obligation to preserve scope is not optional.

**Failure scope policy:** `noUsableAlternatives(RouteSearchRejections)` remains an
**unscoped canonical failure**, for both external and internal paths. Its omissions
identify only positions within that failed invocation, not a supported network or
horizon. Scope does not accompany this error across RouteSearching. If a coherent
scope was already resolved, Data may retain a request-local diagnostic association
to its opaque view/profile references and effective bounds under existing privacy
and retention rules; do not acquire or reconstruct scope to enrich an error. This
association is not a success value, completeness certificate or no-route assertion,
and is not added to the canonical error payload or persisted by default. Consumers
must never convert this or any failure into scoped noResults. The internal algorithm
still must satisfy §3's completion prerequisites before choosing all-rejected.

Required failure-contract amendment: broaden DEC-076 B's noUsableAlternatives
meaning to include complete generated handoffs rejected by admission, **without
changing its payload**; add searchIncomplete and the three proposed rejection reasons.
The successful result contract separately gains the scope-bearing internal branch.
Choosing unscoped failures sacrifices caller-visible failure scope in exchange for
minimal error-value changes; the caller can still provide generic unavailable-route
recovery and Data can diagnose an already resolved context. No failure attests that
a completed search found no routes.

Before production of any internal result, an accepted profile must define:

- finite temporal boundaries, inclusivity, and whether they bound boarding,
  arrival or both; how applicable service dates are enumerated across midnight;
- supported canonical network/coverage and admissible itinerary restrictions
  (including existing distinct endpoints and duplicate-Trip rules);
- completeness of active/inactive calendars, required exact schedule facts,
  eligibility, continuity and directional connections for that search domain;
- completeness-preserving enumeration/pruning/duplicate rules and stable order;
- resource limits and the point at which interrupted work fails searchIncomplete;
- how that supported profile and effective bounds are made explicit to callers.

No numeric horizon or default has been selected. A network-wide claim cannot follow
from a finite profile. Missing times/connections in the declared domain do not
become proof of no route by silently shrinking that domain after seeing the data.
A partial Trip may support its evidenced ridden interval, but does not prove global
coverage. Unknown source facts needed to establish search completeness fail
dataUnavailable; a profile deliberately restricted before the call must disclose
that restriction and still cannot reduce launch commitments without separate approval.

## 5. Proposed additions to DEC-076 C3/D — movement and connections

Exact exception to C3's graph prohibition: **an adopted internal implementation may
compute its itinerary from edges bound to existing reviewed Trip occurrences and
original movement intervals; matched ridden line sequences continue to derive only
from the original snapshot interval**. Include movement-sharing segments, exclude
boundary-only contact, collapse adjacent duplicates and preserve non-adjacent
repeats. Graph topology never supplies passenger stops or a canonical Trip. The
minimum grants **no exception for graph-generated unresolved rail rides**. The earlier
outline IR-C unresolved option is deferred, not adopted by this narrower proposal.

For each rail ride, affirmative source-run/occurrence correspondence and continuity
must cover its entire ridden interval in one existing spanning Trip. Computation
may compose evidenced movements within that ride, not stitch distinct Trip fragments
into a train. A line/operator boundary, matching identifiers/labels, graph adjacency
or equal times proves neither through service nor a change of train. Separately
prove any genuine train change; two fragments of a possible through run must not
be reclassified as a transfer just because a connection is feasible.

Each train change needs applicable, reviewed directional connection evidence and
a **total minimum connection allowance** for the exact alighting/boarding pair,
line/service context and time of use. For distinct stations require the exact
pedestrian direction; for one station require the relevant interchange relation.
The allowance must include all alight, walk/interchange, access and boarding
requirements, once each, under an identified interpretation/policy. A lone walking
duration, proximity or schedule gap is insufficient. Admission requires
nextDeparture - previousArrival >= totalAllowance, with finite nonnegative allowance
and safe arithmetic. Equality satisfies a justified allowance, not proof of a path.
Unknown allowance is not zero. Evidence of a directional edge does not grant the
reverse edge. Numeric defaults, safety margins and accessibility claims remain
unaccepted; a profile without a justified applicable allowance cannot admit that
connection. This proposes routing feasibility, not Phase 10 path/gate presentation.

Keep DEC-062/076 duplicate matched TripIDs within a candidate unchanged, even for
different dated executions. Do not mint per-date TripIDs or hide one as unresolved.
Separate alternatives can use different dates of the same template. Distinct ride
endpoints, rail first/last, no consecutive walks and canonical continuity remain.

## 6. Invented specification cases — no executed compatibility evidence

All IDs, dates, times, profiles and evidence here are synthetic. Times mean
2032-04-12THH:MM:00+09:00 unless another date is explicit. View V1 stipulates compatible
reviewed snapshots, active dated occurrences, allowed ridden eligibility and rights.
For successful/no-results examples only, a hypothetical complete profile H is
stipulated for the stated request; this does not select a real horizon or algorithm.
TC means the proposed timetable branch, never ProviderScheduledContext.

| Case | Invented input/evidence | Proposed result / invariant |
|---|---|---|
| I1 Direct | Request A→C bound 08:00; T1=[A@0,B@1,C@2], L1, both coverage flags true; V1/T1/04-12 dep@0 08:02 arr@2 08:12, exact continuity | Matched(T1,0,2), TC(V1/T1/04-12,0,2,08:02,08:12), derived [L1]; scoped batch one candidate/no omissions. No selection or Journey |
| I2 Directional connection | A→D bound 09:00; T2 A→X 09:02–09:10 and distinct T3 Y→D 09:18–09:30; affirmative train change, X→Y pedestrian relation; total allowance six minutes includes all connection components | Two matched rides with WalkingTransfer(X,Y), TC for each; eight >= six admits. Variant 09:13 departure: three < six, omission infeasibleConnection despite ordered times. Reverse-only evidence Y→X cannot establish X→Y; missing required input prevents a complete-result claim |
| I3 Contradictory generated alternative | Valid V1 contains T4 A→C departure 07:59; request bound 08:00. Generator mistakenly hands off this full proposal at index 0 and no others | Omit index 0 invalidScheduledContext; if completed with no other proposals, noUsableAlternatives. Never erase its time or treat the handoff as zero alternatives. Legitimate pre-handoff exclusion under a defined profile is not an omission |
| I4 Incomplete input coverage | A→D bound 09:00, no proposal found; required service-date calendar or X→Y connection inventory is unknown | dataUnavailable, not noResults. With complete inputs but an enumeration cutoff instead: searchIncomplete. Only completed H with complete required inputs and zero proposals permits scoped noResults |
| I5 Snapshot mismatch | TC(V1/T1/04-12,0,2) belongs to [A,B,C]; generator pairs it with V2 same TripID [A,X,B,C] | Local proposal omission inconsistentTrainEvidence; never use V1 index 2 as V2 B or shift it to 3. If shared view itself mixes revisions, whole call dataUnavailable |
| I6 Same template, two dates | T1 has active 04-12 and 04-13 occurrences, distinct TC addresses and absolute instants | Separate alternatives may reference each. One candidate containing two T1 rides rejects invalidStructure even with a structurally connecting distinct Trip between them; dated identity does not repeal duplicate-TripID rule |
| I7 Through movement | T5=[P@0,Q@1,R@2], L4 movements 0–1, L5 movements 1–2; one active dated occurrence, affirmative stay-aboard continuity, exact endpoints 10:03–10:20 | One matched ride 0→2, derived [L4,L5], no transfer. Board Q@1: [L5] only. Remove affirmative correspondence: no topology/equal-time repair; affected claim rejects insufficientContinuity, and missing required shared evidence prevents completeness |

I2's six minutes is stipulated evidence, not a default. All omissions are subject to
§3's whole-call precedence. T1 producer cases additionally cover missing/estimated
facts, calendar uncertainty, original repeated visits and revision binding.

## 7. Owner choices, affected surfaces and next task

| Choice requiring acceptance | Recommended minimum and tradeoff |
|---|---|
| C1 Context/association | IR-E1 union; matched-only exact paired timetable context bound to view/date/snapshot/indices. Strong association; excludes unsupported or estimated rides |
| C2 Generated accounting | Frozen handoff sequence, one candidate/omission each, stable profile-defined order; cannot hide rejected proposals. Generator completeness remains a separate proof |
| C3 Outcomes/completeness | Scoped successful internal results; unscoped noUsableAlternatives, ordered preflight with observed cancellation first; fail whole call for missing required coverage or interrupted enumeration, with searchIncomplete distinct from dataUnavailable. Simpler truthful boundary at cost of partial-result availability |
| C4 Horizon/profile | Require separately accepted explicit finite bounds and supported domain before internal results. No numeric recommendation without design/evidence; this blocks engine execution, not independent pure-value work or proposal review |
| C5 Connections/continuity | Affirmative joins and directional relations, justified total allowance, explicit infeasibleConnection/unverifiedEligibility/insufficientScheduledEvidence reasons. Fewer admitted routes; no fabricated feasibility |
| C6 Lines/identity | Only matched movement-bound computation exception; preserve original indices and duplicate-TripID prohibition. Defer unresolved graph rides and occurrence-aware uniqueness |

DEC-078 O1–O6 remain separately pending, including the clarified inactive-data policy.
If accepted later, affected surfaces are DEC-076 A/B/C/D/E history and ARCHITECTURE
§§4/10/21/40, RouteRailProposal/context, RouteCandidate chronology, RouteSearchResult,
RouteSearchFailure/reasons, and focused value/admission/async tests. TrainCandidate,
Trip equality/identity and Journey selection invariants are preserved. No source or
test file changes are authorized now. Adoption must record the explicit supersession
scope under repository history rules; this draft does not change accepted status.

**Review/acceptance preparation:** the latest independent review found no material
blockers for owner consideration, not semantic acceptance. Its two optional points
are now resolved by §3's ordered preflight and §4's unscoped failure policy. No full
review is repeated and no new decision layer is introduced. Owner choices remain
pending; acceptance must be explicit and separate from implementation authorization.

P2-S9 precedes real canonical Trip consumption and real P3-T1 import; separately
accepted T1 semantics and validated output precede imported-time consumers. Registry,
Q3 publication, Q4 translations, delivery, bundling/deletion and expansion gates
remain. Commercial evaluation/contact stays paused. No internal-engine adoption,
ODPT-only feasibility, launch change or Phase 3 exit approval occurs.

## 8. Separately approvable owner package — DEC-079 remains Proposed

**Recommended acceptance boundary:** accept §§2–5 and C1–C6 as a conditional amendment
to DEC-076 for a future internal consumer, using separately accepted DEC-078 producer
semantics. DEC-079 alone cannot authorize timetable facts or treat Proposed DEC-078
as accepted. External semantics remain intact; the new union preserves the provider
branch's meaning. Keep exact matched-only context, original-index/snapshot binding,
duplicate-Trip restrictions, generated handoff accounting, scope-bearing success,
unscoped failures and ordered preflight. C4 accepts the obligation to define a profile,
not a numerical profile, engine or algorithm.

**Undecided:** finite horizon/end inclusivity and date enumeration; supported domain,
pruning/duplicate/order/completeness rules; concrete connection policy/defaults;
algorithm and component ownership, result type spelling, persistence/composition.
These block engine execution, not independent local value work under an accepted
bounded contract. No source compatibility or real-data completeness is established.

**Current code gap:** RouteRailProposal has only ProviderScheduledContext?;
RouteSearchResult has unscoped noResults/alternatives; RouteSearchFailure lacks
searchIncomplete and the three added reasons. Existing TrainCandidate/local
chronology/accounting can inform the new values, but no timetable context/scope,
internal generator, coverage proof, total-allowance admission or internal preflight
exists. Debug SyntheticRouteSearcher is external-shaped synthetic admission, not
this engine. RouteSearching's async shape may remain, but its result vocabulary
and documented failure semantics must change explicitly; unchanged code cannot
satisfy this proposal.

**Acceptance would not authorize:** implementation, production engine adoption,
source interpretation/import, acquisition, provider selection/contact, real Trip
consumption, Journey binding, shipping or any change to launch/Phase 3 exit. Record
only the precise DEC-076 amendment/supersession scope at a later authorized acceptance;
never mark the whole external contract obsolete without preserving its still-current
requirements. Accepted ARCHITECTURE is not synchronized in this preparation task.

| Contract-change inventory | Proposed change / preserved boundary |
|---|---|
| Timetable context | New distinct union branch with exact pair; ProviderScheduledContext meaning unchanged |
| Occurrence/snapshot association | View/date/TripID and original indices must match the exact retained snapshot and producer facts; no ID-only proof |
| Result scope | New internal success branch exposes view/profile/bounds/coverage reference; current result type is insufficient |
| Failure behavior | Unscoped all-rejected payload retained with generated meaning; add searchIncomplete and three reasons; ordered internal preflight; never empty-success conversion |
| Generated accounting | Count frozen complete handoffs only, one candidate/omission each; pre-handoff pruning needs separate completeness proof |

**First implementation recommendation:** start with the producer pure-value slice in
[DEC-078 package §8](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md), after its acceptance and
separate implementation authorization. Consumer association/context values can be a
subsequent independently bounded slice after both contracts are accepted; neither
requires a complete engine. Scoped result constructors cannot certify completeness.

Engine prerequisites remain separate: accepted finite search profile/horizon;
enumeration/pruning/order/completeness design; applicable justified connection
policies; algorithm/component ownership; and, for real consumers, S9 plus feed-specific
interpretation, validated T1 import, continuity/connection evidence and applicable
rights. None is supplied by accepting this package.

## 9. Internal-search profile and effective scope — Proposed DEC-080

**Originally proposed separately from DEC-079; bounded DEC-080 acceptance is
recorded in §9.10. Only §9.9 V1–V7 is accepted; all other recommendations remain
Proposed.** This section refines §4's scope obligation; §§1–8 retain their
historical/accepted boundaries above. No algorithm, production profile, launch
restriction or permission is selected. Slice A implements local profile/scope
values only; conceptual success/runtime notation is not implemented API.

### 9.1 Separate responsibilities and proposed values

| Concept | Proposed content / meaning | Never proves |
|---|---|---|
| Stable `InternalSearchProfileDefinition` | Immutable profile key + revision and actual constraints: nonempty canonical station, line and recurring TripID sets; finite positive maximum elapsed search duration; positive maximum rail-ride count; supported forms below; versioned connection-policy and service-date-enumeration interpretation references | Available inputs, reviewed source correspondence or operational coverage |
| Request-specific `InternalSearchScope` | Full definition value, original RouteSearchRequest, one TimetableViewID for the coherent canonical/schedule/connection view, effective lower and final-arrival upper instants | Successful computation or complete data merely because construction succeeds |
| Input coverage assessment (Data) | Evidence that the entire required domain/date window, calendars, schedules, occurrence joins, eligibility and connections are complete, valid and compatible with that view; known exclusions and unknown gaps kept distinct | Search completion or no route |
| Execution completion (search component) | Proof/record that the accepted enumeration contract was satisfied in this scope, with all required input checks and no unhandled cutoff | Authenticity of stipulated input or ranking optimality |
| Admission accounting | Frozen complete handoffs, one admitted candidate or omission per position, existing N/count/index rules | Coverage or completeness of pre-handoff search work |
| Presentation limit | A separately named display subset of an already complete canonical batch | Permission to truncate the batch or call unfinished work complete |

Proposed definition is an explicit allow-list domain, not a list reverse-engineered
from loaded data. TripID here denotes a recurring service, **not ServiceTypeID**, a
brand, operator or dated instance. The station set describes represented passenger
stops/transfer endpoints; the line set describes allowed ridden movements. Names,
coordinates and guessed service labels play no role. Exact Trip snapshots still
come from the coherent view. A partial snapshot may serve a represented subinterval;
unused continuation outside the supported domain is not required to become supported.
Any ridden movement outside the profile's station/line/service constraints is excluded;
missing data about an included service is not an exclusion. Domain membership must be
checked for represented passenger stops inside each ridden interval, not merely its
anchors. Passing infrastructure absent from the accepted passenger-stop model is not
invented as an additional stop requirement.

A future launch profile must demonstrate the accepted 15-line/service scope and
required itinerary behavior. A smaller synthetic/development profile is visibly named
and cannot discharge launch or Phase 3 exit. Changes to source availability never
silently edit the definition, drop a service or shrink the horizon. Supported domain
outside a request is a disclosed profile restriction; absent required facts within
it cause dataUnavailable even when one good route is already known. Active canonical
endpoint validation retains DEC-079 precedence; an active endpoint excluded by this
profile is unsupported. No automatic retired-ID successor handling.

### 9.2 Identity, resolution and local construction

Recommend **embedding the entire immutable definition in each scope**, rather than
returning an opaque profile label alone. A key/revision identifies the definition;
its typed fields carry the constraints. Profile sets must be nonempty and contain
canonical IDs; max rides > 0; maximum duration must be finite and > 0. No numeric
production values are selected. All values immutable, nonisolated and Sendable;
failable constructors without Codable, persistent registry or snapshot equality/hash.
Exact Swift naming and storage collection choices are routine implementation choices.

References to connection/time-interpretation policies are versioned, immutable
contracts whose actual definitions must resolve in the retained view **before use**.
Data retains the definitions, evidence and source details, and the future Application
consumer must be able to obtain the relevant constraint descriptions through a typed
resolver. A bare key or mutable “latest policy” lookup is insufficient. Resolution
lifetime covers search and consumption/revalidation; stale/unresolvable prerequisites
fail under DEC-079 preflight, not a silent fallback. These references do not embed raw
provider metadata in Domain. This draft does not design a policy store or persistence.

Within one configuration, the same profile key/revision may identify only one exact
constraint definition. Changing any domain member, bound policy, ride limit or policy
reference requires a new revision and explicit selection. A display label is not
identity. A value constructor cannot detect registry history; configuration/admission
must reject a reused identity with conflicting contents (configurationUnavailable
at profile resolution; incompatible shared-view resolution is dataUnavailable).
No comparison by profile label alone may authorize association.

A scope captures its request, so two endpoint pairs at the same instant are distinct
searches. Construction checks origin/destination inclusion, exact lower=request
.departNotBefore, finite ordered bounds and the derivation below. All timetable
contexts in an internal batch must use this scope's view. Equal view labels alone
cannot authenticate compatible revisions; Data checks actual snapshot bindings.
Dates may differ between rides; view coherence does not require a single service date.

### 9.3 Temporal formulation and service dates

| Formulation | Tradeoff |
|---|---|
| Bound only first boarding in [L,U] | Finite departure window does not bound arbitrarily late final arrival; misleading as an arrival horizon |
| Independent departure window and arrival deadline | Flexible but adds a second policy/parameter without a present accepted request need |
| **Recommend: depart-not-before L plus final-arrival horizon U** | One finite whole-itinerary window; clear limit on arrival, possibly excludes useful later journeys; must be disclosed |

Proposed minimum: `L = request.departNotBefore`, `U = L + profile.maximumElapsedDuration`
in absolute elapsed seconds with checked finite arithmetic, no rounding. `L < U`;
both boundaries **inclusive**. Every ridden departure/arrival must satisfy
`L <= event <= U`, with existing itinerary chronology. Equivalently, with complete
ordered pairs, first departure >= L and final arrival <= U imply these inequalities;
validate each pair explicitly for clear local invariants. This does not constrain
unused Trip events or require its service origin to depart after L. Equality is
ordering only, never proof of a connection. No request-time profile override or
adaptive shortening is added. Overflow/unrepresentable effective bounds fail intent
admission as unsupportedRequest; value construction returns failure.

Service-date labels remain opaque. The Data producer/interpretation layer must supply
a finite, evidenced enumeration of all dated occurrences whose **possible ridden
events** intersect [L,U], including earlier service dates with extended-hour events.
Never select just the civil dates containing L/U, subtract one date by convention,
parse TimetableServiceDate.label, or enumerate only runs departing their service origin
inside the window. A prior-day run can have a usable later boarding occurrence.
Reviewed conversion profiles and source bounds/index coverage must prove no omitted
service date can contribute; no fixed lookback is assumed. Missing extended-hour or
calendar coverage yields dataUnavailable. Failure to finish enumeration with usable
inputs yields searchIncomplete. Actual feed conversion and date enumeration remain
unimplemented and require source-specific evidence; this is not a GTFS/ODPT rule.

### 9.4 Itinerary forms and connection policy

Recommend parameterized `maximumRailRides = M`, positive finite integer, with no
production default. At most M rail rides implies at most M−1 genuine transfers;
no redundant independent transfer cap. Through service on one existing spanning
Trip is **one ride**, however many line/operator boundaries it crosses. It still
needs affirmative correspondence. Retain distinct rail endpoints, rail first/last,
no consecutive walks, canonical continuity and no duplicate matched TripID within
one candidate, even across service dates. No unresolved graph rides, access/egress
walks or fabricated fragment joins. Optional inter-ride walking is only the existing
exact directional transfer; same-station interchange also needs evidence.

Connection-policy references resolve to justified total allowances for the exact
alight/board pair, direction, line/service context and time applicability. Every
component (alight, interchange/walk/access, boarding) is included once. Finite
nonnegative allowance and safe comparison are required; no universal guessed time,
no implicit zero for same-station change, and no reverse-edge inference. A justified
zero is representable but must be evidenced, not defaulted. A failed known allowance
rejects a handed-off proposal as infeasibleConnection; missing required connection
inventory/policy prevents whole-call success. This proposal selects no numeric
allowance, margin or accessibility policy.

### 9.5 Scoped success and completeness boundary

Proposed shape, extending RouteSearchResult while preserving external cases:

```text
RouteSearchResult:
  noResults                              // existing external meaning
  alternatives(RouteSearchBatch)          // existing external meaning
  internalSuccess(InternalSearchSuccess)  // new validated payload
InternalSearchSuccess:
  scope: InternalSearchScope
  outcome: noResults | alternatives(RouteSearchBatch)
```

The payload constructor checks each candidate: exact request endpoints; all rail
rides matched with timetable contexts; same scope view; snapshot/index attachment;
profile domain and ride-count constraints; all ridden endpoints within [L,U]; existing
structure/duplicate-Trip/chronology invariants. It reuses batch/omission validation.
No provider/nil context enters internal success; external results remain unchanged.
Construction with noResults checks the scope's structure only. An exposed enum case
must not bypass the validated payload. These checks prove **local consistency only**;
no boolean `isComplete` or arbitrary token can authenticate coverage/computation.

Before producing internal success, the implementation must separately establish:
1. complete relevant inputs for the fixed scope, including activation and required
   schedule/connection facts (unknown is not inactive/unreachable);
2. completion of an accepted enumeration/pruning/duplicate/order contract;
3. exact one-to-one accounting of every complete proposal handed to admission.

Genuine scoped noResults requires zero complete handoffs after valid completed
search, not zero admitted candidates. Positive handoffs all rejected produce the
existing **unscoped** noUsableAlternatives failure with contiguous omissions. Shared
input defects yield dataUnavailable even with valid candidates. Unproved completion
or budget exhaustion yields searchIncomplete, no partial batch. Observed cancellation
wins as CancellationError before result/failure; owned work cancels. Preserve the
accepted configuration → shared view → endpoints → intent → required coverage order;
no lower-priority fault probing. Other canonical failures retain their meanings.

Recommend the first completion contract seek all distinct admissible itineraries
within the declared domain/window/ride cap, with identity based on ordered dated
Trip occurrences, original ridden intervals and directional walking connections.
Different implementations may choose different algorithms but must prove equivalent
coverage under the later accepted enumeration contract. Exact duplicate elimination
may be designed before handoff; a distinct admissible itinerary must not disappear
under “ranking.” Do not adopt dominance pruning, tie rules or a generation order by
implication: their precise proof and deterministic ordering remain engine prerequisites.
Infeasibility pruning must be justified; input contradictions cannot be relabeled as
pruning to manufacture completion. Finite source occurrences and a finite ride cap
bound the intended space, but are not themselves a termination/completeness proof.

All admitted handoffs remain in the canonical batch, preserving generated order.
A top-N UI selection is a consumer view over that batch, not new omission records.
If memory/runtime limits prevent producing the complete batch, return searchIncomplete;
do not stop at N and call it completed. Ranking and presentation remain separate,
unselected policies. A later bounded-optimal/top-K search guarantee would need an
explicit contract amendment, not a hidden replacement for this recommendation.

### 9.6 Ownership and independently acceptable boundary

Proposed ownership: Domain owns immutable profile/scope/success values and structural
validation; Data owns coherent input views, source interpretation, policy resolution
and coverage evidence. A future isolated internal-search component consumes those
inputs and owns computation completion/admission accounting behind RouteSearching.
Application chooses an accepted configured profile, manages task lifetime and
presentation, and receives the complete definition/effective scope. No route logic
in UI. The component's precise Domain/Application/Data placement and algorithm remain
an explicit engine-design task; values need neither decision to be useful.

RouteSearching may retain its current async signature: a configured implementation
uses one fixed accepted profile and returns scope. The new result branch makes scope
observable without changing RouteSearchRequest. Runtime profile selection/configuration
and typed policy resolver APIs require a separate bounded design. Current code only
has context support and external-shaped results; none of §9 is implemented.

**Independently approvable package:** §9.1–9.3 parameterized definition/scope structure,
§9.4 structural ride constraints, and §9.5 locally checked success payload/unchanged
failure distinctions. Accepting these would not approve any production domain, numeric
horizon/ride cap, policy resolution implementation, completeness algorithm or engine.
§9.5's all-distinct-itinerary objective is a separate Proposed engine policy choice;
pure values can be accepted without it. Definitions can be constructed from entirely
invented constraints; that does not make them accepted runtime profiles.

Smallest later implementation after explicit acceptance/authorization: pure definition
and scope values, followed by validated internal-success payload and result branch,
using invented candidates. Test finite/overflow boundaries, explicit membership,
request association, same-view timetable-only batches, ride caps and existing
accounting; include invalid enum payload construction. A noResults constructor test
is not a proof of engine completeness. Updating exhaustive result switches is mechanical;
no real search implementation may emit these until coverage/completion obligations
are satisfied. No persistent identity, source registry or provider-context changes.

### 9.7 Worked examples — wholly invented specification cases

All IDs, labels, dates and values below are synthetic. Hypothetical profile P/r1
contains stations A/B/C/D/X/Y, lines L1/L2 and recurring services T1/T2/T3, allows at
most **3 rail rides** and a **2-hour elapsed horizon**, and references invented policies
K1/C1. These numbers illustrate parameters, **not recommended production defaults**.
View V supplies stipulated compatible facts only where explicitly stated. Request
A→D has L = `2034-06-02T00:00:00+09:00`, U = `2034-06-02T02:00:00+09:00`.

| Case | Synthetic input | Proposed outcome and responsibility |
|---|---|---|
| S1 Inclusive departure | T1 departs A exactly L, arrives D 00:20; all other evidence stipulated | Locally valid scoped candidate; runtime success still needs coverage/completion. L−1 second rejects bound validation |
| S2 Arrival horizon | Same ride arrives exactly U; variant U+1 second | Equality allowed. Later arrival outside fixed domain; legitimate pre-handoff exclusion or invalidScheduledContext omission if handed off. Does not justify changing U or claiming no network route |
| S3 Earlier service date | Producer-qualified T2 service label `synthetic-prior-day`, authoritative mapping to 2034-06-01 operation, extended time 24:10 maps to civil June 2 00:10; arrival 00:30 | Include the dated occurrence despite previous service day. No label parsing/rollover here. Missing interpretation/enumeration proof yields dataUnavailable, not noResults |
| S4 Good route plus gap | T1 route is valid; required included T3 calendar or X→Y inventory is unknown | Whole-call dataUnavailable, no partial successful batch; do not remove T3/X→Y from P/r1 |
| S5 Resource cutoff | Required inputs valid, one candidate found, enumeration stops at an execution budget | searchIncomplete; no partial success or noResults. Observed cancellation instead yields CancellationError |
| S6 Through boundary | T1 A→B→D traverses L1 then L2 with affirmative stay-aboard evidence and one spanning snapshot | One ride, zero transfers. Two line names do not consume two ride slots. Without continuity, no invented same-station change; no successful completeness claim with missing required evidence |
| S7 Display limit | Completed search hands off 7 distinct valid itineraries, presentation wants 3 | Canonical batch retains all 7 in generated order; presentation may display a clearly limited subset. Stopping search at 3 is not equivalent; no fabricated omissions for the other 4 |
| S8 Identity reuse | P/r1 originally uses a 2-hour duration; configuration reuses P/r1 for 1 hour or removes T3 | Reject conflicting profile resolution; require a new revision/explicit selection. Scope embeds original constraints, so an old result cannot silently inherit changed limits |
| S9 Positive duration with no representable advance | Invented binary64 absolute-second coordinate L = 2^53; positive duration 0.25 seconds. Ordinary floating-point addition returns U == L | Scope construction fails: finite positive duration alone is insufficient; L < U and representable checked bounds are required. Never substitute nextUp, round to a minute or silently enlarge the horizon. This is a numeric specification example, not a calendar/source conversion or executed test |
| S10 Known absent directional connection | Authoritative complete inventory proves no feasible X→Y connection in the fixed scope. Stipulate all other required inputs complete and no other feasible itinerary; separately accepted execution completes with zero handoffs | Scoped noResults is permitted only on those runtime premises. Unknown required X→Y coverage instead yields dataUnavailable; an execution cutoff yields searchIncomplete. If complete proposals were handed off and all rejected, use noUsableAlternatives. Values alone establish none of these evidence/completion facts |

### 9.8 Owner choices and exact remaining gates

| Choice | Recommended selection / tradeoff |
|---|---|
| P1 Definition transport | Embed full immutable typed constraints, with resolvable immutable policy references; larger values, fewer opaque-label ambiguities. No production registry |
| P2 Temporal bounds | Inclusive request lower bound and inclusive final-arrival U=L+positive finite parameter. One window; longer journeys excluded explicitly. No numerical default |
| P3 Itinerary cap | Positive parameter M rail rides; through counts once, transfer maximum derived M−1; preserve duplicate-TripID prohibition. Choose production M only after launch behavior assessment |
| P4 Coverage/completion | Fail whole call for missing required evidence or incomplete computation; accept local values separately from authenticating those obligations |
| P5 Enumeration objective | Propose all distinct admissible scoped itineraries; potentially expensive. Separately review deduplication/order/pruning proof before engine execution; do not silently replace with top-K |
| P6 Result/presentation separation | Scope-bearing internal success, full admitted batch, unscoped failures; display limits outside accounting. No partial-success fallback |

No numeric production horizon/ride cap is recommended without workload and launch
behavior evidence. Small parameterized values do not depend on those defaults.
The next bounded task is focused independent documentation review of DEC-080/§9,
then separate owner consideration of the value package versus engine objective.
Before engine execution: accepted configured domain/defaults, authoritative service-date
enumeration and coverage assessment, resolvable connection policies/allowances,
deterministic enumeration/pruning/order/completion rules, and component ownership.
Before real use: P2-S9, feed-specific interpretation/validated T1 import, source and
through/transfer correspondence, freshness/rights and all applicable registry,
publication/translation/delivery/bundling/expansion gates. ODPT-only compatibility,
commercial resumption, launch reduction and Phase 3 exit are not approved.


### 9.9 Bounded owner-acceptance package — Proposed, 2026-10-02 Asia/Seoul

Independent review found no material contract findings and readiness for owner
consideration only. A fresh context could not be created because of the thread
limit; the assigned reviewer confirmed no prior exposure to DEC-080. This package
records no acceptance and authorizes no implementation. S9/S10 clarify the existing
rules without selecting an arithmetic implementation or runtime search policy.

**Recommended single approval:** accept the value-contract selections V1–V7 below,
mapped to P1–P4 and P6, with runtime obligations distinguished from local checks.
Do not accept §9 wholesale. Paragraphs are identified by their exact opening words;
tables/code blocks are explicitly named to avoid accidental paragraph-count drift.
This table is the precise selection if it is later approved, not a new decision layer.

| Selection / owner choice | Exact proposed text selected | What acceptance would establish / limit |
|---|---|---|
| V1 — P1, P4, P6 | §9.1 entire concept table and paragraphs beginning “Proposed definition is an explicit allow-list domain” and “A future launch profile must demonstrate” | Full immutable definition, scope/evidence/completion/accounting/presentation distinction and explicit domain semantics. Membership/shape are local; authoritative membership, coverage and launch sufficiency remain runtime/evidence obligations |
| V2 — P1 | §9.2 all four paragraphs beginning “Recommend”, “References to connection/time-interpretation policies”, “Within one configuration” and “A scope captures its request” | Embed actual definition; key/revision denotes fixed contents; preserve original request/view. Local checks do not enforce identity history or authenticate a view. Before runtime use, referenced policy definitions must resolve immutably; no resolver API/store/implementation is accepted |
| V3 — P2 | §9.3 paragraph beginning “Proposed minimum” (the preceding alternatives table is rationale only) | Exact L=request bound, U=L+positive finite duration; inclusive events, finite representable checked bounds and L<U; no adaptive horizon or inferred dates. Overflow, unrepresentable/no-advance results fail construction; runtime intent failure remains unsupportedRequest |
| V4 — P3 | §9.4 paragraph beginning “Recommend parameterized” | Positive M, at most M rail rides/M−1 transfers, through service counted once, existing matched-ride/duplicate-TripID/structural restrictions. No production M, continuity inference or launch reduction |
| V5 — P4, P6 | §9.5 introductory “Proposed shape” and its complete code block; paragraph beginning “The payload constructor checks each candidate” | New internal success payload containing scope plus noResults or batch; immutable/failable payload validation prevents enum bypass. Exact request/domain/view/ride/context/time association and existing batch invariants are local. Neither a noResults value nor a valid batch authenticates coverage or execution |
| V6 — P4, P6 | §9.5 “Before producing internal success” and its three numbered obligations; paragraph beginning “Genuine scoped noResults requires” | Preserve whole-call input/completion/cancellation failures and one-handoff/one-outcome accounting. Runtime success requires a separately accepted completed execution contract. NoResults requires zero handoffs, not all-rejected; failures remain unscoped. No proof mechanism or enumeration policy is accepted |
| V7 — P6 | §9.5 paragraph beginning “All admitted handoffs remain”, **only its first three sentences**, ending “do not stop at N and call it completed.” | Preserve every admitted handoff and its order in the canonical batch; display limits do not create omissions or truncate computation. “Complete batch” means all admitted handoffs from execution satisfying its separately accepted contract; it does not yet mean all mathematically possible routes |

These selections recommend P1–P4/P6 only. §9.7 S1–S10 are illustrative specification
cases for the selected boundaries, not new defaults, authenticated inputs or test
results. In particular S7's complete seven-item batch presupposes a separately
accepted execution contract; it is not acceptance of P5's search objective.

**Explicit deferrals and non-selected text:**

- P5 and the entire §9.5 paragraph beginning “Recommend the first completion
  contract seek all distinct admissible itineraries” remain Proposed. Also defer
  the final two sentences of “All admitted handoffs remain” (beginning “Ranking
  and presentation remain separate” and “A later bounded-optimal/top-K search
  guarantee…”). No all-distinct/top-K/dominance objective or ranking/order policy
  is selected by this package. Existing accounting cannot be weakened regardless
  of which execution contract is later accepted.
- §9.3 paragraph “Service-date labels remain opaque” is retained as evidence/design
  guidance consistent with DEC-078/079, not acceptance of a concrete enumeration
  policy. Its prohibitions on label parsing, guessed lookback and hiding missing
  coverage continue as accepted upstream obligations; enumeration, calendar/source
  interpretation and compatibility must be separately designed/evidenced.
- §9.4 paragraph “Connection-policy references resolve” restates retained DEC-079
  evidence obligations; accepting V2's resolution obligation accepts no concrete
  allowance policy, resolution API, data store, default margin or connection admission.
- §9.6's ownership, configured implementation and implementation recommendations
  are planning guidance, not an engine/component-placement decision. §§9.8/9.9
  distinguish the selection; they do not accept every earlier recommendation by
  reference. Production domain sets, horizon/ride numbers, profile selection,
  enumeration/pruning/duplicate/order/completeness policies, algorithms, ranking,
  policy resolution implementation and runtime component ownership remain undecided.

**Remaining choice:** owner approval or rejection of V1–V7 as one bounded package.
No further semantic choice blocks the parameterized local values once that package
is accepted. Exact type/file names, typed key/revision wrappers and collection layout
are routine representation choices; they must not introduce persistent IDs or permit
label-only substitution. Concrete policy-reference resolution and runtime evidence
remain blockers to actual internal search, not to synthetic value construction.

**Smallest implementation sequence, each requiring explicit acceptance and separate
authorization:**

A. Pure profile/scope values: full immutable constraints, typed versioned references,
request/view association, domain inclusion, positive parameters and checked inclusive
absolute bounds. Test invalid/empty domains, wrong request membership, nonfinite or
nonpositive duration, overflow/no advance, boundary equality and preservation of full
constraints. S9 is a negative numeric constructor case. Do not implement a profile
registry, policy resolver, coverage or calendar/date enumeration.

B. Locally validated scoped-success payload plus internal RouteSearchResult branch,
after A: the V5 shape/invariants are sufficiently specified. Reuse current candidate,
timetable context and batch values; validate endpoints, every represented ridden
stop/line/Trip membership, same view, exact matched contexts, ride cap and [L,U].
Reject provider/nil contexts and invalid payload construction; mechanically adapt
exhaustive result switches. Preserve external cases and unscoped failures. Test
noResults structure without claiming an execution occurred. No new failure vocabulary,
preflight, real producer/search or completeness-proof implementation is needed for B.

Neither slice authenticates occurrence snapshots from a real source, active calendars,
eligibility, policy resolution, coverage, execution completion or connection feasibility.
Runtime search/admission, calendars/conversion, real data/import, persistence,
Journey/UI and engine work remain excluded. No internal implementation may emit
successful results until the separate runtime obligations are satisfied.
P2-S9 before real Trip consumption/import, feed-specific interpretation/validated
import, rights/registry/publication/translation/delivery/bundling/expansion gates,
launch requirements and Phase 3 exit remain unchanged.

### 9.10 Bounded acceptance and slice A implementation — 2026-10-02 Asia/Seoul

The owner accepted precisely §9.9 V1–V7, not all of §9. Historical Proposed
headings and preparation wording above preserve the original recommendations.
P5 and §9.9's explicit deferrals remain Proposed/undecided. Slice B has no
implementation authorization in this turn; scoped result construction and runtime
success obligations remain unimplemented.

Slice A uses `InternalSearchProfileIdentity` and `InternalSearchPolicyReference`
(key/revision pairs), `InternalSearchProfileDefinition` (nonempty canonical domain
sets, finite positive elapsed duration, positive ride cap and versioned references),
and `InternalSearchScope` (full definition, original request, view, checked [L,U]).
Both endpoints must belong to the declared station set. Exact representable addition
rejects overflow, no advance and an advancing but rounded sum. Bounds are inclusive.
These are local constraints, not production defaults.

Explicit comparison of supplied definitions includes every field; equal key/revision
alone does not establish equal contents. Constructors neither enforce global identity
history nor resolve policy references. They cannot authenticate membership, view,
source correspondence, calendars, input coverage, service-date enumeration or completed
execution. Domain relationships absent from the inputs are not guessed. No opaque
service-date interpretation, result/failure changes or runtime search is implemented.
Independent implementation review approved slice A only; ROADMAP records focused evidence and review scope.

### 9.11 Slice B local implementation — 2026-10-02 Asia/Seoul

The owner separately authorized slice B under accepted V5. `InternalSearchSuccess`
is an immutable validated payload with full scope and noResults/alternatives outcome;
the result enum wraps that payload only. Alternatives reuse RouteSearchBatch intact.
Each candidate must have requested endpoints, a permitted ride count, matched timetable
contexts attached to the exact ride and scope view, allowed ridden stations/lines/TripIDs,
and inclusive scheduled endpoints in [L,U]. All represented passenger stops in the
original ridden interval count; unused snapshot stops and boundary-only line contact
do not. Existing snapshot/address/index, chronology and duplicate-Trip restrictions
remain. No occurrence-date labels are interpreted. Constructor failure rejects the
payload, not silently filters candidates or invents omission records.

NoResults construction establishes scope structure only. Runtime required input
coverage, zero-handoff/completion facts, generated accounting authenticity, activation,
eligibility, directional connectivity and allowance/policy resolution are unimplemented.
The full candidate/omission order is retained; a display subset cannot mutate the batch.
External result behavior and unscoped failures remain unchanged. There is no producer
or production composition for this branch. P5 remains Proposed; independent slice B
implementation review approved local values only. All retained gates and launch/Phase 3 exit remain.

## 10. Production objective and execution policy — Proposed DEC-086

**R6 direction update — 2026-10-05:** DEC-086 now records the owner's preference for
on-device route calculation. §18 governs this narrow direction and its Proposed execution
boundary; historical unresolved-R6 wording below does not reopen computation location.
No algorithm, detailed ownership, resource settings, data rights or live adoption are accepted.

**Scoped acceptance — 2026-10-04:** the owner accepts arrival then changes, evidenced
through counting, all distinct equal optima, identity ordering solely for reproducibility,
selection before frozen handoff, admitted-candidate preservation, optimum/tie proof,
no first-found/first-K, searchIncomplete at cutoff, dataUnavailable for unknown required
evidence and searchIncomplete for defensive mixed rejection. This does not accept
production adoption, numerical limits, deployment, ownership or algorithm mechanics.
R6 and unresolved implementation/configuration choices remain Proposed. Historical
Proposed labels below preserve the reviewed rationale; this overlay governs the
specified selection/completion rules only. Implementation status is in ROADMAP.

**Status: Revised Proposed, 2026-10-04 Asia/Seoul.** The owner explicitly directs
fastest-route recommendations: earliest arrival first, fewer train changes at equal
arrival, and evidenced through service is not a train change. This records product
direction, **not approval of the earlier R1–R6 package**. Winner multiplicity, identity,
accounting, pruning, ownership and production configuration remain Proposed.
The earlier all-distinct-return and first-departure tie-break recommendations are
withdrawn. Historical §9 P5 text remains a proposal, not accepted production policy.
Published converter/search integration is complete and is not repeated here.

### 10.1 Objective and choices still requiring approval

For a fixed request, accepted scope and coherent view, compare feasible itineraries
by the lexicographic objective **(exact final arrival instant, number of train changes)**.
Depart-not-before remains a hard constraint. Train changes equal rail rides minus one;
a line/operator change inside one evidenced continuous Trip adds zero. This is earliest
arrival from the request bound, not shortest on-train duration or earliest departure.
No preference for fare, walking distance, departure time, comfort or reliability is added.

| Choice | Owner direction / proposed recommendation | Rationale and unresolved prerequisite |
|---|---|---|
| R1 Objective | Owner explicitly prefers earliest arrival, then fewer changes. Recommend returning only objective-optimal recommendations | A slower direct route loses to a faster transfer; slower transfer routes need not be recommended. Precise execution/proof contract still needs approval |
| R2 Equal optima and identity | **Propose all distinct equally optimal candidates**, in deterministic key order with no preference implied | Avoids inventing a third user preference or hiding a train choice. One deterministic winner is the alternative: needs explicit approval of an arbitrary reproducibility selector or an additional product tie-break. No first-departure preference is proposed |
| R3 Exploration, handoff and accounting | Propose a separately specified production optimizer that selects the proved optimal set before frozen admission handoffs; keep every admitted handoff | Internal explored paths are not returned recommendations or omissions. Requires the production execution clarification in §10.3; no filtering of today's admitted batch |
| R4 Incomplete evidence and scope | Retain current whole-call coverage failure; no verified-direct fallback under current success shape. Keep explicit finite scope and resolved policies | A direct route may be feasible without being provably fastest. Best-known/degraded output would require a separate explicit amendment, not approved here |
| R5 Completion and pruning | Prove no better feasible itinerary exists and, for R2, find every equal optimum; only then succeed | First-found/first-K is insufficient. Optimistic bounds and dominance need proof including equal optima and exact state compatibility; resource cutoff remains searchIncomplete |
| R6 Ownership/adoption | Propose Data-owned replaceable optimizer behind RouteSearching, retaining Domain values and Application lifetime ownership | Prior ownership recommendation remains unapproved. Algorithm, deployment, rights, inventory, numerical defaults and adoption require separate evidence/decisions |

R2 returns multiple candidates only when both objective values are equal. This is not
all-distinct itinerary return and not arbitrary top-K. Equal-optimum volume can still
be large; no hidden cap is selected. If it cannot be fully established/materialized
within resources, fail truthfully or obtain approval for a different multiplicity
contract. Deterministic ordering alone is not a claim that the first tied item is better.
No recommendation automatically selects a train or creates Journey state.

### 10.2 Identity and equal-optimum ordering (Proposed)

Retain exact dated ride identity: (view UUID, recurring TripID, service-date label,
original boarding index, original alighting index). An itinerary key is its ordered
ride keys interleaved with directional connection keys and form, including both dated
endpoint indices and canonical from/to stations. A connection key has one compatible
qualified relation/form/allowance; contradictory definitions are shared-view faults.
Physical footpaths sharing one canonical relation are not distinct alternatives under
current representations. Different trains or repeated boarding indices may be equal
optima; equal station lists or equal times do not merge them. Exact duplicates collapse
before handoff. Conflicting same-key facts are not deduplication opportunities.

For reproducibility only, order equal optima by the full key: UUID fixed bytes,
canonical ID/date text unsigned UTF-8 bytes, indices numerically, connection form
same-station before walking, and shorter sequences before strict extensions. Connection
fields compare endpoint ride addresses/indices, then canonical from/to station IDs,
then form. No locale, date-label interpretation, departure-time preference or new score.
This deterministic tie ordering is **Proposed**, not owner-approved. Preserve every
full snapshot, occurrence index and dated address; duplicate TripID within one candidate
remains prohibited even across dates. Current facts do not authenticate source revisions.

### 10.3 Exact contract interaction and recommended execution clarification

- **DEC-076:** external decoded alternatives and their original ordering/accounting
  remain unchanged. Do not drop a valid decoded route or relabel a slower route as an
  admission error. This proposal applies only to a separately accepted internal optimizer.
- **DEC-080 P5:** production objective was explicitly deferred; replacing the earlier
  all-distinct recommendation does not supersede an Accepted all-distinct production
  rule. V6/V7 still require complete execution, one handoff/one outcome and preservation
  of every admitted handoff. Filtering admitted candidates down to winners would violate
  those accepted rules; returning a first-K prefix would not prove completion.
- **DEC-081:** all-distinct exploration and ride-count/key handoff order are accepted for
  the DEBUG synthetic engine. They cannot be silently changed to fastest-only. Keep it
  unchanged as a small-world oracle; use a separately authorized production-target path.
- **Recommended production execution clarification (Proposed):** exploration states and
  complete feasible paths considered by the optimizer are not yet admission handoffs.
  Establish the optimal set over **all admissible feasible itineraries** within scope,
  using the same canonical eligibility/continuity/time/structure constraints, before
  freezing that set in R2 order. Assign contiguous alternative indices only then.
  Slower or equal-arrival/more-change feasible paths are objective exclusions, not errors,
  omissions or missing evidence. Every frozen handoff still receives exactly one outcome;
  admission retains every admitted winner and its original index/order.

This clarification must explicitly define the production generator/admission boundary
under DEC-079/080; it is not a loophole permitting today's handoffs to be renamed or
silently discarded. No new public payload is necessarily needed for complete optimal
recommendations: existing scoped success can carry the selected handoffs under an
accepted versioned objective. But profile/policy resolution must identify the objective,
multiplicity and proof contract explicitly; today's profile type does not encode them.
This representation and compatibility check remain future design/implementation work.

An optimizer must not choose an apparently fastest but inadmissible route and stop.
Its optimality proof must include the canonical admission predicates, not just times.
Reuse their semantics rather than create a competing eligibility or continuity engine.
Shared defects remain dataUnavailable. If a frozen winner unexpectedly fails admission,
existing one-outcome accounting is preserved: all rejected remains noUsableAlternatives.
For a mixture of accepted and rejected winners, **propose searchIncomplete**, with no
success, because the promised complete admissible optimal set has not been established.
No fallback to a slower route, substitution, retry or partial tied set is implied. This
mixed-rejection completion rule also requires owner approval; it leaves the existing
synthetic/external batch behavior unchanged. A normal successful proof should yield
no admission omissions, but defensive rejection accounting must not be removed.

### 10.4 Optimality proof, safe pruning and cutoffs

Success must establish that a nonempty recommendation set is feasible, that no feasible
path in the declared scope has a smaller objective pair, and (for R2) that all distinct
paths with that same pair are returned. A feasible incumbent is only an upper bound,
not proof of fastest arrival. An exhaustive finite reference enumeration can prove this
on small invented inputs; a production algorithm needs its own correctness argument and
comparison against that oracle. Finite scope does not prove practical runtime.

A branch may be pruned if proven infeasible or if a sound optimistic lower bound on
its achievable objective is **strictly worse** than the incumbent. Equality cannot prune
under the all-equal-optima recommendation. Bounds cannot depend on guessed transfer
times or treating unknown links as absent. Dominance is allowed only after proving
future-state equivalence/simulation with exact dated occurrence, eligibility, continuity,
connection policy, remaining ride budget and used-TripID constraints. It must preserve
all equal-optimum distinct prefixes/outputs, not just the best numerical score. Earlier
arrival at the same station alone is not that proof. No first-found, first-K, beam-width,
station-pattern dedup or destination-reached stopping by implication. Revisited stations,
zero-time edges and permitted cycles remain in the oracle unless a proved exclusion
applies. Numerical bounds and tie comparisons must be exact, not rounded display times.

Completion may use exhausted exploration or a proved frontier bound plus complete tie
accounting; it need not materialize every slower path. Verification must cover cases
where the best path is discovered last, equal optima, transfer/through distinctions,
cycles/repeated visits, pruning equivalence and cutoff before/after each stage.
Operational work/time/memory cutoff before proof or result completion -> searchIncomplete,
never partial success. Observed cancellation retains precedence. Budget accounting
covers input validation, coverage, optimization, tie collection, admission and finalization;
bound allocation before exhaustion. No numerical budgets are invented here.

### 10.5 Missing evidence, production scope and remaining gates

**Current answer: a verified direct route cannot be returned as successful internal
search when required potentially faster paths have unknown evidence.** Current required
coverage preflight fails dataUnavailable even if that direct route is feasible. Unknown
is neither slower nor absent; no optimality proof follows from known-route comparison.
This remains the recommended behavior for this proposal. Accepted preflight ordering,
scoped results and unscoped failures are unchanged. noResults requires completed search
with zero handoffs, never merely no proved optimum or all handoffs rejected.

A possible future degraded mode could say only “verified available route; fastest route
not established,” with explicit incomplete-coverage status and limitations. It cannot
claim fastest, no faster alternatives or no service. “Best among verified routes” would
itself need a completed defined verified-subset search. Such a mode requires a separately
approved result/claim contract, requiredness change, caller behavior and acceptance tests;
it must not reuse current complete internalSuccess or fabricate omission records for
unknown paths. This task proposes no fallback payload and authorizes no such amendment.
Even pruning a missing-evidence path using other bounds would need a separately reviewed
requiredness proof; optimization is not permission to bypass current coverage preflight.

Retain explicit membership/complete dated execution inventory, immutable source/mapping/
view correspondence, qualified time interpretation, affirmative continuity, permissions
and directional connection evidence. Include earlier-service-date extended-hour events;
do not infer completeness from loaded packets, paths, topology or absent transfer files.
Known prohibition/absence may exclude; unknown required evidence fails. Interpretation
and connection references must resolve to compatible immutable definitions, including
all-component directional allowances and applicability; no universal transfer buffer.
Preserve inclusive [L,L+D] and positive M rides. “Fastest” always means within that
identified scope, not a global claim beyond supported domain/window/ride cap.

No actual production D/M, freshness threshold, allowance or resource limit is selected.
Their rationale needs launch-use-case coverage, authorized representative inventory,
source interpretation, applicable rights, update/revocation handling and measured CPU,
peak memory, result/tie volume, cancellation responsiveness and cutoff incidence. No
launch reduction follows from a direct-only fixture. P2-S9 and real T1 import, registry,
publication/translation/delivery/bundling and expansion gates remain. DEC-077 still
accepts evaluation priority only; commercial resumption and production adoption are
separate owner decisions, including provisional DEC-004 history and deployment review.

### 10.6 Invented examples (not execution evidence)

Each row is a separate complete artificial world unless explicitly marked unknown.
A→D departs no earlier than 08:00; shown times are exact within one compatible scope.
Transfer examples stipulate affirmative directional connections and adequate allowances;
no numerical allowance or continuity is inferred merely from the times.

| Case | Inputs | Fastest-route recommendation / claim |
|---|---|---|
| Faster direct | Direct arrives 08:20; transfer arrives 08:30 | Recommend direct only; slower transfer need not be returned |
| Faster transfer | Direct arrives 08:35; feasible transfer arrives 08:25 | Recommend transfer only; fewer changes cannot outweigh earlier arrival |
| Equal arrival | Direct and transfer both arrive 08:25 | Recommend direct (zero changes); transfer has one change |
| Evidenced through | One continuous Trip spans two lines and arrives 08:25; a train-change route also arrives 08:25 | Through route wins on zero changes; line change is not a transfer |
| Equal objective | Distinct direct T1 departs 08:02, T2 departs 08:04; both arrive 08:25 | Proposed R2 returns both, ordered only by deterministic identity key; no preference for either departure. One-winner mechanics remain an alternative requiring approval |
| Unknown potentially faster route | Verified direct arrives 08:30; a transfer path might arrive 08:20 but its required connection/permission is unknown | Current dataUnavailable. Direct feasibility is known; fastest route is not proved. No best-known fallback is authorized |
| Cutoff with incumbent | Verified direct 08:30 found; search cutoff occurs before another branch is settled | searchIncomplete, no recommendation batch, even if direct is valid |
| Objective versus omission | Complete proof finds direct 08:20 and transfer 08:30 | Slower path is excluded before production handoff under proposed R3; never given a false rejection reason or removed from an already admitted batch |

### 10.7 Next bounded slice

After owner approval of the unresolved mechanics and separate implementation authority,
implement only an invented objective/optimal-set specification helper with exhaustive
small-world oracle tests: earliest-arrival/change comparison, all equal optima, exact-key
dedup, deterministic tie order and proposed handoff/defensive-failure accounting. Reuse
canonical contexts and leave DEC-081 and published converter/search integration unchanged.
No new production defaults, real inputs or engine wiring. Production algorithm, proof,
performance/rights evidence, configuration representation, deployment and adoption remain
separate. P3-T1 and Phase 3 remain incomplete; P2-S9 retains fourteen classification and
fourteen ordering gaps; no ODPT inquiry reply has been supplied.

## 11. Prepared-path optimal handoff integration — implementation design

**Owner-authorized bounded implementation design, 2026-10-04.** DEC-086 selection/completion preferences
are already accepted and are not reopened. This section specifies the missing DEBUG-only
association and orchestration, not production ownership or a new engine.
No new decision identifier is needed for this API plumbing. The owner subsequently
authorized this exact DEBUG slice; implementation and verification are recorded in §11.6.
Names in the design below remain notation unless mapped to declarations in §11.6.

### 11.1 Actual flow and non-circular insertion point

`SyntheticInternalRouteSearcher.search` creates one per-call engine and awaits
`prepare(request)`. Preparation performs ordered preflight, normalization, full required
coverage, qualified ride-token construction and directional connection feasibility;
then exhaustively enumerates paths, deduplicates and deterministically orders them.
`SyntheticInternalPrepared` holds scope, ride/slot/connection dictionaries and paths.
For each path, `claims` (originally fileprivate, now shared internally) resolves keys to
`SyntheticInternalRide` values.
`engine.admit` checks those claims against that prepared state and creates the canonical
`RouteCandidate` only at the end. `finalize` checks accounting against **all** prepared
paths and permits mixed candidate/omission success under DEC-081.

The correct insertion point is **after successful full prepare, before any admission
handoff**. Objective is the final ride context's exact arrival plus path.count−1 changes.
Identity comes from ordered dated ride keys and resolved directional connection keys,
forms and canonical endpoints in that same prepared state. Through line changes within
one ride contribute no change. There is no need for a RouteCandidate to compute either.
Do not admit all paths and subsequently filter, build temporary canonical candidates to
feed the published selector, or run another discovery/eligibility/chronology algorithm.

The published `SyntheticOptimalRouteSelection` takes canonical candidates, so it cannot
be used directly at this point. Recommend extracting only its pure objective/key comparison,
exact-key deduplication and equal-optimum selection into a shared DEBUG utility returning
opaque input handles. Keep its existing candidate-input adapter and all validation behavior
intact. A new prepared-path adapter supplies descriptors from the existing prepared state;
it does not copy candidate validation into a second implementation. Cross-adapter tests
prove equivalent keys/order for equivalent routes. DEC-081 keeps its all-distinct path
order and search behavior; it does not call the new optimum selector.

### 11.2 Smallest typed association and provenance boundary

Recommend one immutable, opaque `PreparedOptimalSession`, constructed only by a factory
that calls the existing engine's full `prepare` for a single invocation. Retain the whole
original `SyntheticInternalPrepared` privately; never overwrite `paths` with winners to
make old accounting appear to pass. Internal memberwise construction of a prepared struct
is not a completion proof: do not offer an entry point accepting arbitrary prepared values,
arrays of candidates, a boolean `complete`, or caller-supplied objectives/keys.

Within that owner, each `ExploredAlternative` contains:

- a private ordinal into the original complete prepared.paths (association only, not
  user preference or omission index);
- the exact ordered ride-key path, or a reference to it through that ordinal;
- a derived `Objective(arrival, changes)` and full DEC-086 itinerary key.

The owner controls construction and resolution. A handle cannot be constructed publicly
or used with another session; no independent `(handle, prepared)` consumer API. If handles
must cross a file boundary, keep their constructors inaccessible and check a per-invocation
owner token on resolution; a view UUID alone is insufficient. Tokens are ephemeral and
never new registry IDs or persisted provenance. The simplest implementation keeps handles
and resolution private to the orchestrator and exposes only its eventual canonical result.

Derive ride data by dictionary lookup, not TripID-only matching: view/date/TripID, exact
snapshot, original boarding/alighting indices, and unmodified context. Derive each connection
from `connectionKey(previous,next)` and the resolved present/form/allowance/evidence entry;
retain the prepared state containing that definition rather than embed a caller-authored
copy. Derive canonical directional station endpoints from the corresponding snapshots.
A missing key or incompatible association is dataUnavailable, never omitted as a slow path.
Resolve selected handles back to the same prepared rides for the existing `admit` method;
no time, date, index, snapshot, connection or Trip replacement is permitted. Shared snapshots
and state remain pinned throughout selection and admission.

### 11.3 What establishes completeness and admissibility

Two different prerequisites remain explicit: fixture authors stipulate a complete, qualified
artificial input universe; the existing prepare operation proves that its **implemented
finite enumeration** finished over that universe. Successful array construction or admission
proves neither. The factory returns its session only after all prepare stages finish without
coverage error, cancellation or resource cutoff, including deduplication/order. No public
constructor lets a caller promote a prefix into completed exploration. This is synthetic
completion only; it authenticates no real inventory or production algorithm.

Preparation already checks all required permissions/times/continuity and connection relations
before discovery, including disconnected required unknowns. Paths already have requested
endpoints, finite ride cap, distinct recurring TripIDs, qualified ridden scope and feasible
connections. The implementation review must map each admission predicate to those preparation
invariants and retained canonical constructors; admission remains the defensive authority.
Do not assume that prepared paths are admissible merely because a struct exists, and do not
add a second validator to repair gaps. A discovered missing invariant is a concrete separate
correction scope, not permission to silently skip that path or admit it early.

The adapter scans every complete prepared path, derives bounded descriptors and retains every
minimum objective tie in DEC-086 identity order. No pruning or new enumeration is introduced.
A nonempty explored set must yield a nonempty selected set; otherwise fail searchIncomplete.
The optimum claim is relative to the stipulated finite universe and accepted scope, not real
network optimality. Coverage remains conservative even when a verified direct ride exists.

### 11.4 Freeze, admission and truthful finalization

Freeze selected handles in deterministic identity order, then assign **new contiguous
handoff indices 0...winnerCount−1**. Original explored ordinals remain private associations.
Slower explored paths have no handoff index and no rejection omission. Call existing
`admit` exactly once per selected handle with the original prepared state. Process ordinary
rejections through all selected handoffs to retain full accounting; a thrown shared-input,
cancellation or resource failure aborts atomically under existing precedence.

| State | Outcome using existing canonical types |
|---|---|
| Completed empty exploration, zero selected/handoffs | scoped internalSuccess(.noResults) |
| Nonempty selection, every selected handoff admitted | scoped internalSuccess(.alternatives(batch)), all winners in frozen order, no omissions |
| Every selected handoff rejected | unscoped noUsableAlternatives with contiguous selected-index RouteSearchRejections |
| Some admitted, some rejected | searchIncomplete; no survivors returned as optimal success |
| Unknown required evidence or inconsistent prepared association | dataUnavailable, never direct-only fallback |
| Incomplete exploration, selection, accounting or finalization / resource cutoff | searchIncomplete, no partial batch |
| Observed cancellation | CancellationError takes precedence, including before terminal result/failure |

Use existing `RouteAlternativeOmission` reasons/order and one-handoff/one-outcome accounting.
Mixed failures may retain bounded omissions locally for assertion while assembling the
outcome, but `searchIncomplete` has no diagnostic payload: do not add logs, exports or a new
public result merely to expose them. No slower substitution, retry, selected-winner removal
or fallback search. All rejected is not an empty universe and cannot produce noResults.

Do not call the present `finalize` unmodified for this flow: its count is original path
count, and its mixed-success behavior differs. Recommend factoring the small count/outcome
assembly into a shared DEBUG finalization helper with **explicit expected handoff count and
completion policy**. Existing DEC-081 entry supplies prepared.paths.count and all-distinct
policy, preserving behavior; the new orchestrator supplies frozen winner count and accepted
optimal policy. Both use the same finish checkpoint/cancellation and canonical constructors.
Policy is fixed by the entry point, not a caller option to weaken optimal completion. This
is outcome plumbing, not another engine. No fabricated reduced prepared state is allowed.

### 11.5 Bounded synthetic implementation and verification scope

One separate DEBUG-only optimal orchestrator over the existing engine; no change to the
normal DEC-081 search entry's selection, ordering, admitted-batch or failure semantics.
Share the minimal claim resolver instead of reconstructing claims independently (originally
fileprivate on the searcher; now shared internally). Keep engine preparation, predicates and enumeration unchanged.
Extract the selector's pure key/objective kernel and the shared accounting assembly only
where needed; no Domain changes, policy registry, production composition or UI.

Require an explicitly supplied finite synthetic work limit using the engine's existing
counter/checkpoints through preparation, descriptor traversal/comparison, selection,
admission and finalization. No reset/new counter after prepare. Charge sorting/dedup scans
as well as path/connection resolution; cancellation remains observable at those boundaries.
Reuse the selector's fixture ceilings (64 complete alternatives, up to four rides/seven legs,
256 entries per snapshot array, 128-byte identifiers/dates). Check shape/length before
materializing descriptor keys; over-limit is searchIncomplete, not first-64 selection.
Preparation's existing work budget bounds its earlier enumeration; no production budgets
or algorithm-performance guarantee are chosen here. Oversized/unrepresentable counters fail
without partial output. No public success-capable mutation hook or arbitrary admission callback.

Targeted invented tests:

- Known exhaustive direct/transfer/through universe: later-discovered optimum wins; all
  equal optima and distinct dates/repeated original visits preserved; input permutation
  leaves recommendation and frozen handoff order unchanged.
- Prepared descriptor versus existing canonical-candidate adapter parity, including same-
  station/walking connection form and direction; no synthetic departure preference.
- Selected handle resolves original snapshot/context and connection definition; foreign
  session/forged handles cannot be supplied through the API. Test exact association checks
  at the internal seam without permitting production-style caller substitution.
- Unknown required evidence with a usable direct route fails before selection; every
  prepare/selection/sort/admission/finalize cutoff and cancellation produces no partial
  success. Complete empty enumeration is distinct from missing inventory and all rejected.
- Failure-only harness, modeled on the current synthetic failure harness, corrupts selected
  claims only inside tests and invokes the real admission predicates: one rejected winner
  among ties -> searchIncomplete; all rejected -> contiguous selected-index omissions.
  It can never return success or act as a normal configurable searcher. Verify the slower
  explored ordinal is absent from omission indices; do not fabricate rejection outcomes.
- Original DEC-081 regression suite unchanged; existing selector tests and DEBUG/Release
  isolation checks. No repeat of real data or completed converter-to-search work.

The owner authorized this narrow adapter/extraction/test scope,
including mechanical edits to shared DEBUG helpers. No new route preference, failure type,
coverage relaxation or semantic decision is proposed. If predicate factoring or identity
representation reveals a semantic gap, report it before expanding the implementation.
The bounded defensive handoff implementation is recorded separately in §11.6.
P3-T1/Phase 3 remain incomplete; P2-S9 keeps fourteen classification and fourteen ordering gaps.


### 11.6 Bounded implementation and verification — 2026-10-04 Asia/Seoul

`SyntheticOptimalRouteSearcher` is a separate DEBUG `RouteSearching` adapter over the
unchanged `SyntheticInternalRouteEngine.prepare`/`admit`. It requires an explicit finite
`Int` work limit; its private `PreparedOptimalSession.open` alone can construct a session,
after successful exhaustive preparation. Both the prepared state and selected ordinal
handles are private; there is no `(handle, prepared)` API, exported completion flag,
externally supplied descriptor, or cross-session handle operation. Fixture authors still
stipulate qualified complete inventory. No runtime wrapper authenticates real coverage.

`SyntheticOptimalRouteDescriptor` shares exact dated ride/directional connection keys,
objective and snapshot/text ceilings with the published canonical-candidate selector.
`SyntheticOptimalRouteKernel` scans all bounded descriptors, retains objective ties,
deduplicates exact keys and insertion-orders them. Its incremental advances are charged
and cancellation-checked by the original engine counter; the synchronous selector exhausts
the same machine. Descriptor/path/connection resolution and final selected-claim lookup
also use that counter. Each advance has bounded comparisons and an at-most-64-element
move; key construction is bounded by four rides/seven legs, 256 entries per snapshot array
and 128 UTF-8 bytes per identifier/date. More than 64 complete paths fails atomically.
No new discovery, eligibility, chronology, source interpretation or pruning algorithm exists.

Selected claims are looked up in the original prepared dictionaries through the shared
resolver, without evidence reconstruction. Existing admission alone constructs candidates.
The shared finalizer's private policy is fixed by its two entry methods: DEC-081 still
uses all explored paths and permits mixed success; `finalizeOptimal` uses the frozen
selected count, returns all winners only on full admission, throws `searchIncomplete` on
mixed rejection, and preserves contiguous selected-index `noUsableAlternatives` on total
rejection. Slower paths never receive handoff indices or rejection omissions. Thrown
coverage/cutoff/cancellation failures retain the existing precedence and atomic behavior.

`SyntheticOptimalHandoffFailureHarness` is a failure-only `Never` seam, not a searcher or
normal configuration option. It corrupts a selected claim's alighting key to −1, then
invokes real admission and shared finalization. It never provides substitute prepared
state, fake rejection outcomes or a success-capable external callback.

Admission invariant audit (admission remains the defensive authority):

| Admission obligation | Existing preparation/canonical authority |
|---|---|
| Nonempty route, requested endpoints, ride cap, distinct TripIDs | Exhaustive path generation from qualified rides |
| Exact view/date/address, full snapshot, original indices/context | Normalization plus original `TrainCandidate`/`TimetableRideContext` construction and retained dictionary lookup |
| In-profile ridden stations/lines, scope times, exact allowed endpoints | Full interval/slot coverage and qualified token construction |
| Affirmed continuous ride | Required interval continuity checked before token creation |
| Chronology and connection allowance | Exact ride context and feasible directional edge construction |
| Direction, same-station/walking form, valid allowance | `normalizeConnections` and original resolved relation |
| Canonical rail/route structure and scoped result | Existing admission constructors and `InternalSearchSuccess`; no replacement validator |

Targeted tests compare prepared selection with the published candidate selector, check
original dated snapshots/repeated indices, direct/transfer/through objectives, equal ties,
permutation order and directional walking/same-station relations. Failure tests exercise
selected-index accounting with an earlier slower explored path, missing inventory despite
a good direct route, scoped complete empty, the complete-alternative ceiling, and every
post-preparation work-budget prefix/cancellation checkpoint through finalization.
Final test/build/isolation and independent-review evidence is recorded in ROADMAP's
corresponding implementation entry. No production limits, ownership/algorithm mechanics,
adoption, app wiring, deployment or real inventory evidence is supplied. P3-T1 and Phase 3
remain incomplete; P2-S9 retains fourteen classification and fourteen ordering gaps.

## 12. Application route-search lifecycle — Proposed DEC-087

**Current acceptance overlay, 2026-10-04 Asia/Seoul:** the owner accepts DEC-087 C1/C2
and authorizes the bounded Application implementation/tests described here. Proposed labels
below preserve the independently reviewed design history; they are not outstanding approval
requests for C1/C2. Implementation/verification is separately recorded in ROADMAP. Clearing
route results never deletes recent-station history. Existing local recent-station policy is
unchanged; history storage/limits/deduplication/deletion UI are outside this slice.

**Status: Proposed, 2026-10-04 Asia/Seoul.** Documentation only. DEC-087 C1–C2 below
need owner approval; this section authorizes no implementation, UI or production routing.
It reuses DEC-076 §A3/6/7 and ARCHITECTURE §§4/10/21–24. Application lifetime ownership,
obsolete-response suppression, injected-clock resolution, canonical results and no implicit
retry are already accepted. DEC-086's objective, all equal optima, exact identity ordering
and incomplete/unavailable rules are unchanged. Application does not rank or admit routes.

### 12.1 Existing boundaries and proposed minimal owner

`RouteSearching.search(RouteSearchRequest)` is a Sendable async-throwing Domain port;
Data implementations own validation, off-main heavy work, errors and cancellation checkpoints.
`AppClock.now` returns a Date and supplies no timers or scheduler. `AppEnvironment` is the
immutable App composition root, currently configuration/clock/logging only. Architecture's
`Application/Routing/RouteSearchCoordinator.swift` is a planned location, not existing code;
no Application coordinator implementation currently provides a pattern to copy.

Recommend a provider-neutral, main-actor-isolated reference owner in that planned location,
constructed with `any RouteSearching` and `any AppClock`. It owns one current attempt/state
and its task handle. Main-actor operations are lightweight serialization/publication only;
await the port without moving conversion, sorting or mapping into the owner. An async port
alone is not an off-main-work guarantee; implementations retain their accepted Data duties.
Use no SwiftUI, provider type switch, singleton or service locator. Initial fake-backed work
should not edit `AppEnvironment.live()` or inject a DEBUG searcher into the shipping app.
These are recommended mechanics, not a choice of production optimizer ownership under R6.

### 12.2 Intent, admission and time capture

Design notation (not declarations or persistent identifiers):

- **Intent:** canonical origin/destination plus departure `.now` or `.at(Date)`.
- **Attempt:** fresh opaque invocation identity, original intent and the exact resolved
  `RouteSearchRequest`. State and completion retain this association.
- **Submission outcome:** accepted attempt identity, invalid request, or disposed owner.
  Invalid input is an Application admission outcome, not a Data search failure/noResults.

Serialize submission on the owner. Reject a disposed owner and equal endpoints before any
clock read. For `.at`, use the exact supplied finite instant; never read the clock, round,
clamp past times to now, reinterpret a timezone or derive a service date. For `.now`, read
injected `AppClock.now` **once, during submission before the first suspension**, after the
endpoint/disposal preflight. Construct the existing failable `RouteSearchRequest`; a
nonfinite instant rejects submission. No clock reads occur on worker start, completion,
publication, cancellation or disposal. If validation fails, do not replace/cancel existing
work, allocate an accepted attempt or change state. A failed now capture may have read the
clock once but launches no work. Syntactic validation does not preflight current station
support/mapping; those remain Data responsibilities.

For valid submission, allocate a new identity even if endpoints/time equal the previous
request. In one non-suspending owner operation: invalidate the old publication authority,
request cancellation of its task, discard its owner-held result/failure, install the new
attempt as `searching`, then schedule one worker with the resolved request. It invokes the
port at most once, and zero times if cancellation is observed before invocation.
No debounce, deduplication, coalescing, cache lookup or implicit fallback is introduced.

### 12.3 Proposed C1: current-request-only observable state

Recommend a small typed state with exactly one of the following payloads. Names are design
notation; canonical payloads are retained unchanged, not mirrored into another routing model.

| State | Payload / meaning |
|---|---|
| idle | No submitted request/result |
| searching | Current attempt; no previous result or failure |
| completed | Current attempt and entire `RouteSearchResult`, preserving scope, candidates and omissions |
| failed | Current attempt and exact `RouteSearchFailure`; explicit retry available, not a promise retry will fix evidence/configuration |
| cancelled | Attempt whose work was cancelled; no result/failure; resubmit explicitly if wanted |
| contractViolation | Current attempt; unexpected noncanonical thrown error, no raw details/result; developer integration defect, not evidence of no service |
| disposed | Terminal owner state, no retained attempt/result; submissions and retries rejected |

C1 requires owner approval because retaining old results versus clearing them affects the
consumer's visible truth. Recommend clearing on every accepted replacement. Explicit cancel
of current `searching` work invalidates publication, requests cancellation, clears the task
handle and moves to `cancelled`. Cancel takes an expected attempt identity: a stale cancel
cannot cancel a replacement. Cancel outside `searching` is an explicit no-op; clearing a
completed screen is not invented as a second action in this slice. New valid submission is
allowed from any nondisposed state. Invalid submission leaves existing state unchanged.
A current worker's `CancellationError` likewise produces `cancelled`, never an outage.

`dispose` is idempotent: invalidate publication first, cancel/release current work, clear
state to disposed and release owner-held payloads; never suspend waiting for the worker.
Its lifetime owner must call it when the consumer scope ends. A deallocation cancellation
safeguard is desirable but not a replacement for explicit disposal. Already copied results
cannot be retracted: later consumers must obey current owner state/identity, not re-publish
old snapshots as answers. Retaining historical results or background caches is excluded.

### 12.4 Invocation identity, task ownership and publication guard

Identity denotes one invocation within one owner, not request equality, Trip/candidate ID,
wall-clock time, view ID or a persisted registry key. Recommend an opaque per-owner token
with private construction, nonreuse for that owner's lifetime and equality by invocation.
Representation is implementation plumbing; prefer a fresh private reference identity rather
than a wrapping counter or a clock-derived key. Nonreuse must be structural. Two owners cannot accept each
other's completion authority. Caller cancellation/retry commands must carry the relevant ID.

Only a private owner completion method may publish. On the owner actor, atomically check:
owner not disposed, state still searching, and completion token identical to its live token.
Check **every** terminal path (success, canonical failure, cancellation, unexpected error).
No await occurs between this guard and clearing publication authority/task handle and
assigning terminal state. Obsolete completions are discarded without changing newer state,
clearing its task, adding an omission or surfacing an old failure. Guarding only successful
responses or comparing origin/destination/time is insufficient.

The owner stores the current task handle, cancels it on replacement/cancel/dispose and
releases it at terminal completion. Worker capture should retain only its immutable request,
port and token across the await, and a weak route back to the owner; do not retain the owner
through the whole suspended operation. Never create detached tasks or an unbounded history
of handles/results. Check cancellation before invoking the port, then forward its terminal
outcome through the guarded owner path. Data remains responsible for its owned child work.

Cancellation is cooperative: issuing cancel does not prove an ignoring worker has stopped.
After cancellation the old task may finish independently; the publication guard still
prevents effects. Do not await that task before accepting a replacement, claim forced
termination, or add a timeout/retry policy to solve a contract-violating worker. Normal Data
implementations already observe cancellation; deliberately ignoring fakes test the caller
boundary, not a redesign of Data mechanics. One current owner handle does not promise a
bound on resource use of arbitrarily many noncooperative workers.

### 12.5 Canonical outcome preservation

| Port outcome for the current live attempt | Application transition |
|---|---|
| alternatives(batch) or internalSuccess(.alternatives(batch)) | completed with the original result, exact candidate order/contexts, scope and omissions; no re-ranking, truncation, reselection or Journey creation |
| noResults or internalSuccess(.noResults) | completed with that original empty result; preserve scoped versus unscoped meaning; never imply a global no-service claim |
| noUsableAlternatives(rejections) | failed with the exact rejection payload/indices/reasons; not empty success |
| dataUnavailable | failed; no older/direct-result fallback, no guessed evidence repair |
| searchIncomplete | failed; no partial winners or retained previous answer |
| Other RouteSearchFailure | failed preserving its exact case/payload, including endpoint role/reason; future localized recovery can distinguish cases |
| CancellationError | cancelled, never providerUnavailable/noResults |
| Other thrown error (port-contract violation) | contractViolation, fixed Application-local category; never expose raw text or invent a canonical no-route/evidence claim |
| Any obsolete/disposed completion | discard entirely regardless of outcome |

This is presentation-neutral state, not localized copy, a recovery engine or new Domain
failure vocabulary. No automatic retry occurs. An unexpected-error containment state needs
no new provider semantics; its implementation and negative fake test stay Application-local.

### 12.6 Proposed C2: explicit retry preserves intent, not invocation identity

Recommend `retry(expectedFailedAttemptID)` only while `failed` for that exact identity.
A stale retry or retry in another state is rejected/no-op without cancellation, clock read,
new invocation or state change. Duplicate retry gestures cannot start two requests: the
first accepted retry changes state to searching before the next command can be admitted.
Retry unavailable/invalid configuration is allowed as an explicit attempt, without promising
success or contacting anything automatically. `contractViolation` requires integration
correction; cancellation/empty success may be followed by explicit submit, not hidden retry.

Every accepted retry is a fresh attempt scheduling one worker, with at most one port call
(zero if cancelled before invocation). Retain endpoints and original
departure intent. For `.at(t)`, retry exactly t, no clock read. For `.now`, capture clock once
again at retry admission and construct a fresh request, reflecting the user's current
“leave now” intent. Failure of that construction leaves the failed attempt/state intact.
This is the additional genuine owner choice: replaying the old captured now instant is
possible, but should be a distinct explicit-time submission rather than silently changing
what retry-now means. C2 is Proposed; no accepted contract currently settles this distinction.

### 12.7 Concrete invented transition examples

| Event sequence | Proposed observable effect |
|---|---|
| Submit slow A→B now at 08:00 (id α); submit A→C now at 08:01 (id β) | Two separate clock reads, one per accepted intent; clear A→B state, cancel α, publish searching β only |
| β succeeds; α returns success later despite cancel | Keep β's complete canonical result; α cannot replace it or add omissions |
| β succeeds; α throws dataUnavailable later | Keep β; obsolete failure cannot overwrite or clear it |
| Submit α then cancel(α); α subsequently succeeds | Remain cancelled α; no candidate is published |
| Cancel(α) after β replaced it | No effect on β or its work |
| Current now attempt α fails at 08:02; retry(α) at 08:03 | Fresh β, clear old failure, one clock capture at 08:03; same endpoints, new exact depart-not-before |
| Explicit 09:00 attempt α fails; retry(α) at 08:03 | Fresh β still uses 09:00; zero clock reads for both submissions |
| Submit identical intent twice, then old completion arrives | Distinct IDs; only the second invocation may publish even if its resolved Date equals the first |
| Dispose while α waits; α later returns/fails; then submit/retry | Disposed remains terminal; no publication and no new work |

### 12.8 Owner choices and next bounded implementation

| Choice | Recommendation | Why approval is needed |
|---|---|---|
| DEC-087 C1 — current-request-only state | Clear prior results/failures on accepted replacement; explicit current cancel yields cancelled; preserve current canonical failure and explicit retry; disposed is terminal | Defines observable prior-result/cancellation behavior not established by Data contracts; retaining historical content would need separately labeled state |
| DEC-087 C2 — retry departure intent | Fresh identity always; explicit time unchanged; now captures once anew; retry only the matching current failed attempt | Chooses now-retry intent versus exact replay and prevents stale gestures from replacing newer requests |

No new approval is needed to restate accepted Application ownership, obsolete-response
suppression, injected-clock use, no implicit retry, canonical preservation or DEC-086
preferences. Actor/token/constructor mechanics are proposed implementation details, not
production algorithm/adoption decisions. Do not mark C1/C2 Accepted on the owner's behalf.

After C1/C2 approval and separate implementation authority, the smallest slice is one
Application/Routing owner and minimal Application-local intent/attempt/state values, plus
focused fake-port/clock tests and a ROADMAP completion record. Use an ordinary provider-
neutral Application component (no real dependency or DEBUG provider adoption); fake workers
remain test-only. Retain Release support for the Application abstraction, while existing
synthetic converters/searchers remain DEBUG-only. No Domain result redesign, engine changes,
AppEnvironment.live wiring, feature/UI, cache, persistence or automatic Journey/train action.

Tests must exercise controlled completion ordering rather than sleeps: A→B replaced by A→C,
old success AND failure after newer success, cancellation-ignoring completion, cancellation
before worker invocation (zero port calls), disposal,
stale cancel/retry IDs, identical-request replacement, failed retry-now versus explicit-time
clock counts, invalid-input nonreplacement, every canonical outcome including scoped empty
and rejection accounting, unexpected error containment, and release of owner-owned references.
Reuse existing Data cancellation/admission/conversion suites; do not rebuild their internals
or call the synthetic solver just to test caller identity. Appropriate targeted tests and
explicit iPhone Simulator app/extension builds belong to that future implementation, not
this documentation task. No new production limits, provider, scheduler or cache policy.
P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering
gaps. No ODPT reply, real/private input access or source applicability is established here.


### 12.9 Bounded implementation status — 2026-10-04 Asia/Seoul

C1/C2 are owner-approved. `Application/Routing/RouteSearchCoordinator.swift` implements the
provider-neutral main-actor owner and Application-local intent, invocation identity, attempt,
submission and state values. A private immutable reference token supplies nonreused identity;
no counter, persistent ID or wall clock forms identity. Validation precedes replacement.
All completions enter the same private searching/identity guard. Canonical values are stored
unchanged. Matching retry reuses original intent, not the prior invocation ID. Disposal is
terminal; deinit additionally requests current cancellation. The worker retains the port and
immutable attempt with a weak owner across suspension, so late ignored-cancellation work
cannot retain the owner or publish obsolete results.

The owner remains available in Release, without any concrete provider or DEBUG-routing
reference. Only `completionCheckpointForTesting` is DEBUG: it returns a read-only async
barrier for the captured worker, including superseded workers, enabling deterministic tests.
It exposes no task cancellation handle, replacement evidence or state-mutation callback.
No observer/UI integration, recent-history storage/limits/dedup/deletion, cache, live
AppEnvironment wiring, source interpretation, Journey/train mutation or routing adoption.
The lifetime consumer still must explicitly dispose; cooperative cancellation cannot force
arbitrary nonconforming workers to terminate. Final tests/builds/review are recorded in
ROADMAP; implementation completion does not complete P3-T1 or Phase 3.


## 13. Application composition and coordinator provisioning design

**Implementation overlay, 2026-10-04 Asia/Seoul:** owner authorized this bounded composition
implementation. The design text below is preserved; its future/not-implemented wording is
historical. Actual source and verification status are recorded in §13.5 and ROADMAP.

**Status: design recommendation, 2026-10-04 Asia/Seoul; not implemented.** Baseline
`d35fc8426bda597dcc0cac3b2f2aac09affa9e83` publishes the DEC-087 owner. This section
connects its existing constructor to App-owned dependency assembly; it does not change
C1/C2, select a provider or authorize production routing. No new decision record is needed
for this constructor/factory plumbing under ARCHITECTURE §§4.1/10/21/23–24.

### 13.1 Existing code and smallest composition boundary

`TSUGINOApp.init` creates `AppEnvironment.live()` once and injects the immutable Sendable
value into the hierarchy. Its dependencies are configuration, `any AppClock` and logging.
The SwiftUI EnvironmentValues default also calls `live()`; neither path may activate routing
implicitly. `AppShellView` is a placeholder, not a route consumer. The DEBUG Live Activity
section demonstrates explicitly supplied dependencies and per-consumer ownership, but is
not a routing lifetime or production dependency template. No route feature/model exists.

Recommend the following small addition to `App/Environment/AppEnvironment.swift` (design
notation, not new declarations in this task):

- Private immutable `routeSearching: (any RouteSearching)?`, supplied through the explicit
  environment initializer; default `nil` preserves existing infrastructure-only callers.
  `nil` means no implementation has been configured, never that there is no service.
- `@MainActor makeRouteSearchCoordinator() -> RouteSearchProvision`, where the App-local
  typed result is `.notConfigured` or `.ready(RouteSearchCoordinator)`. It is a local
  main-actor handoff, not a Domain search result, error thrown by the port or persistent state.
- The factory branches only on dependency presence. Configured: construct the existing
  coordinator with that exact injected port and the environment's exact `clock` dependency.
  Unconfigured: return `.notConfigured`, without creating a coordinator or search task.
  No clock read, port call, discovery, provider selection or network action occurs at either
  environment construction or factory invocation. Time capture stays in DEC-087 submission.
- Keep the environment immutable/nonisolated/Sendable; isolate the construction method
  (and provisioning handoff as needed) to MainActor because the existing owner requires it.
  Store neither a coordinator singleton nor a registry/lookup closure. No factory protocol,
  service locator, second clock, provider wrapper or fallback RouteSearching is needed.

App assembly supplies an explicitly chosen port only when a caller is authorized to do so.
For the next bounded slice, that caller is a test constructing AppEnvironment with a
controlled fake and test clock. A future App assembly boundary calls the factory once at
consumer creation, branches on its result and constructor-injects the ready coordinator
into an Application workflow owner or feature model. The Application consumer must not
import SwiftUI/AppEnvironment or look up dependencies itself. It receives the coordinator,
not the whole environment. Neither SwiftUI body evaluation nor request submission calls
the factory. Implementing that future feature/lifetime host remains outside this slice.

### 13.2 Lifetime, independent consumers and disposal

Each successful factory invocation returns a fresh idle owner, even when the environment
or injected port is shared. Separate consumer scopes receive distinct coordinators and
request identities; copying AppEnvironment does not copy or retain route results. Sharing
one Sendable port/clock does not merge coordinator state. Concurrent-call isolation remains
the existing RouteSearching implementation responsibility; no per-consumer provider cloning
or new global cancellation API is introduced.

The receiving consumer's lifetime host strongly retains exactly its coordinator for that
scope and explicitly calls `dispose()` on MainActor when the scope ends or is replaced,
then releases it. AppEnvironment and TSUGINOApp do not retain created owners or dispose
unrelated scopes. A later consumer gets a new owner; a disposed owner is never reset/reused.
Transient view reconstruction is not by itself the end of an Application consumer scope;
actual navigation/UI lifecycle hooks must be designed with the eventual host, not guessed
as an `onDisappear` policy now. Deinit cancellation remains a safeguard, not the primary
lifetime contract. Provisioning imposes no new tasks, observation system or teardown await.

DEC-087 submission/replacement/cancellation/publication/retry rules remain unchanged.
Cancelling or disposing consumer A cannot revoke B's publication authority. Clearing route
answers never deletes recent-station history; storage, limits, deduplication and deletion UI
remain outside this design and implementation. No automatic Journey/train selection.

### 13.3 No approved live port: explicit absence, not a search outcome

`AppEnvironment.live()` explicitly supplies no routing implementation in both Debug and
Release, as does the SwiftUI default through that same live construction. The current shell
remains unchanged and creates no route owner. The factory therefore reports `.notConfigured`
if asked. This is a composition capability result, not `.noResults`, `.dataUnavailable` or
an invented port that throws `.configurationUnavailable`. No successful search is claimed.
There is no request to resolve or retry until an actual configured owner exists.

If an explicitly injected port later throws an existing canonical failure, the coordinator
preserves it normally; absence at composition does not rewrite that vocabulary. A future
consumer must branch on `.notConfigured` and not offer a working search capability; exact
localized UI/recovery presentation is outside this task. Never fill absence with a DEBUG
synthetic searcher, automatic provider discovery or a system-clock fallback. Providing a
production port in live assembly requires separate approval/evidence; this design does not
settle DEC-086 ownership/algorithm/limits or provider suitability.

### 13.4 Smallest implementation and meaningful verification

After implementation authority, change `AppEnvironment.swift` only for the immutable optional
port, explicit unconfigured live path, App-local typed provisioning result and main-actor
factory. Add one `RouteSearchCompositionTests.swift` using a small controlled fake consumer
host/port and counting clock; update the relevant documentation status. Do not change the
published coordinator, Domain/Data engines, TSUGINOApp, AppShellView or app configuration flags.
The existing initializer and infrastructure tests remain valid through the default nil value.

| Composition proof | Controlled assertion |
|---|---|
| Explicit dependency assembly | Environment/factory creation reads Clock zero times and calls port zero times; first now submission uses injected time and supplied port exactly once; explicit-time submission makes no clock read |
| Fresh owners from one environment | Two factory calls produce separate idle owners; one shared controlled fake receives their exact requests; replacing/cancelling/disposing A leaves B's state and completion authority intact |
| Consumer ownership | Fake lifetime host receives and retains ready owner; ending it disposes that owner before release; captured late completion cannot publish; a fresh host gets a fresh owner, not disposed state |
| Canonical handoff | One configured fake completion is retained unchanged, including scoped result/context/omissions; one canonical failure remains failure. Reuse existing fixtures; do not rebuild the full lifecycle outcome matrix |
| Unconfigured construction | Explicit nil, omitted optional argument and `live()` all provision `.notConfigured`; no synthetic/fallback instance or worker; current shell remains unmodified |
| No ambient dependency leakage | Separate environments with different fake ports/clocks deliver requests to their own injected dependencies; shared environment does not cache owner state |

Use continuations and the existing DEBUG-only worker completion barrier, never sleeps.
Reuse DEC-087 lifecycle tests for exhaustive stale completion, invalid submission, retry and
cancellation edge cases; these tests prove factory wiring and lifetime-host composition only.
Future verification: focused composition plus AppEnvironment/coordinator/Clock suites on an
explicit iPhone Simulator, appropriate Debug/Release app/extension build checks, and review
that live/default assembly references no synthetic/fallback port. No test/build run belongs
to this documentation task. Ordinary Application provisioning must work in Release; test
fakes stay in tests and the existing worker barrier remains DEBUG-only.

**Owner choices:** no new product-semantic approval is requested. Fresh per-consumer owners,
App-owned assembly, explicit dependency absence and unchanged DEC-087 disposal follow existing
boundaries and the current no-live-provider constraint. API spelling is a recommended routine
implementation detail. Actual production injection, future UI lifetime hooks/presentation,
cache/history behavior and provider/optimizer adoption remain outside scope, not implicitly
accepted. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen
ordering gaps. No ODPT reply has been supplied.


### 13.5 Bounded implementation status — 2026-10-04 Asia/Seoul

`AppEnvironment.swift` implements the optional private immutable port, backwards-compatible
initializer default, main-actor factory and App-local `RouteSearchProvision` enum. Ready
creates the existing coordinator with the exact injected port/Clock, without reading time
or starting work; notConfigured creates no owner. The live path explicitly passes nil and
the SwiftUI default still delegates to that live path in both configurations. No fallback,
DEBUG engine, closure registry or global coordinator was added. No production provider was
selected. Coordinator, TSUGINOApp, AppShell, Domain and Data source are unchanged.

`RouteSearchCompositionTests` uses controlled continuations, a counting mutable test Clock,
a fake lifetime host receiving only its coordinator, and existing canonical fixture values.
It checks inert construction, now/explicit wiring, separate environment dependencies,
independent owners from one/copied environment, scoped host disposal with late completion,
fresh owners after disposal, unchanged scoped canonical context/omissions and canonical
failure, and explicit-nil/omitted/live/SwiftUI-default notConfigured provisioning.
Existing DEC-087 tests continue to own exhaustive lifecycle/retry coverage. The host is
only a test fixture; actual feature host/lifetime hooks and UI remain unimplemented.

Final tests/builds and independent review are recorded in ROADMAP. No cache/history storage,
recent-station deletion, Journey creation, real/private input, provider contact, production
routing or new product decision. P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen
classification and fourteen ordering gaps. No ODPT reply supplied.


## 14. Provider-neutral route-search presentation contract

**Current scoped acceptance:** the owner accepts P1 rejected-draft feedback and P2 reviewed
project-owned JP/KO/EN copy/grouping, including the exact notConfigured strings below, and
authorizes the bounded pure mapper/copy implementation. Historical Proposed labels in this
section record the reviewed design and earlier partial approval; they are no longer pending
P1/P2 choices. This accepts neither screens/feature flow nor production routing. See §14.5
and ROADMAP for implementation evidence; Phase 11 linguistic/layout hardening remains separate.

**Status: Proposed presentation/copy design, 2026-10-04 Asia/Seoul.** Baseline
`45818ecaf2ec3cbd5c6ecb5018df9bb781010a39` publishes Application composition. This is
not a complete search UI or implementation authority. DEC-087 C1/C2 and §13 composition
are accepted inputs; no ranking, lifecycle, retry, source or production decision is reopened.

**Scoped owner approval — notConfigured wording only:** the owner explicitly approved
「現在、経路検索はご利用いただけません。」 / “현재 경로 검색을 사용할 수 없습니다.” /
“Route search is currently unavailable.” This correction is accepted; P1 rejected-draft
feedback and all remaining P2 copy/grouping stay Proposed. The internal notConfigured
capability remains distinct from dataUnavailable and every invoked-search failure. Its
no-search/retry/cancel action rules are unchanged. “Currently” describes present capability;
it asserts neither a temporary outage nor restoration, and authorizes no automatic retry.

### 14.1 Boundary and retained truth

Recommend a pure, presentation-neutral projection of `RouteSearchProvision` and, when ready,
`RouteSearchLifecycleState`, plus optional local submission feedback. The eventual lifetime
host owns the coordinator; a projection neither creates it nor submits, cancels, retries,
reads Clock or observes/polls work. It must be refreshed from current owner state by the
future host; this document does not imply an implemented observation bridge or feature model.

Retain the exact attempt identity/intent/request and canonical result/failure as the source
of truth. Keep scope, all candidates in supplied order, dated timetable contexts, snapshots,
indices and omission/rejection evidence internally, unchanged. A display descriptor contains
only project-owned status/action identifiers and references to the retained current payload;
it is not a reduced replacement routing model. Never render raw IDs, omission counts/reasons,
provider diagnostics or contract-violation error text. Do not derive a user message by enum
stringification. Existing accepted engine outcomes govern completeness, not presentation.

Success displays every returned canonical alternative without re-ranking, dropping equal
optima or changing through-service treatment. Use canonical names and supported scheduled
context when later rendering details; absent optional times/fare/platforms stay absent.
Provider-asserted schedule and timetable context retain their provenance; neither becomes
realtime or a guaranteed arrival. No generic “fastest in Tokyo” or complete-network claim:
this projection cannot authenticate optimum/coverage. Route-card layout, time formatting,
station-name lookup and train/Journey actions are not designed or implemented here.

### 14.2 State/action/status-copy table (draft)

The text is TSUGINO-owned, not a translation of provider content. Action tokens S/E/R/C are
specified below. “For this search” limits the empty statement to this request and any retained
scope; it never asserts that no service exists. Do not print opaque scope/profile keys.

| Input / presentation | Available actions | Japanese | Korean | English |
|---|---|---|---|---|
| ready + idle | S, E | 出発地・目的地・出発時刻を指定してください。 | 출발지, 도착지, 출발 시간을 지정해 주세요. | Enter an origin, destination and departure time. |
| searching | C, E then S for explicit replacement | 経路を検索中… | 경로 검색 중… | Searching for routes… |
| completed alternatives (scoped or unscoped) | E, S; inspect presented alternatives only | 経路 | 경로 | Routes |
| completed internalSuccess(.noResults) | E, S; no failed-attempt retry | 今回の検索では経路が見つかりませんでした。 | 이번 검색에서 경로를 찾지 못했습니다. | No route found for this search. |
| completed unscoped noResults | E, S; same cautious request-level copy, do not fabricate scope | 今回の検索では経路が見つかりませんでした。 | 이번 검색에서 경로를 찾지 못했습니다. | No route found for this search. |
| failed noUsableAlternatives | R, E, S | ご案内できる経路を確認できませんでした。 | 안내할 수 있는 경로를 확인하지 못했습니다. | Could not verify a usable route. |
| failed dataUnavailable | R, E, S | 検索に必要な情報が不足しています。 | 검색에 필요한 정보가 부족합니다. | Information needed for this search is unavailable. |
| failed searchIncomplete | R, E, S | 経路検索を完了できませんでした。 | 경로 검색을 완료하지 못했습니다. | The route search could not be completed. |
| cancelled (explicit or current port cancellation) | E, S; no failed-attempt retry | 経路検索をキャンセルしました。 | 경로 검색을 취소했습니다. | Route search cancelled. |
| provision notConfigured | No search/retry/cancel; future host may retain editable draft, without implying capability | 現在、経路検索はご利用いただけません。 | 현재 경로 검색을 사용할 수 없습니다. | Route search is currently unavailable. |
| rejected invalidRequest, supplementary feedback only | E; corrected S; preserve current state's own actions | 出発地・目的地・出発時刻を確認してください。 | 출발지, 도착지, 출발 시간을 확인해 주세요. | Check the origin, destination and departure time. |

Accepted replacement shows searching with no obsolete route answer/failure. Failure,
cancellation or notConfigured must not borrow an earlier successful route as a fallback.
Canonical noResults is success, not a failure requiring R. Failed noUsableAlternatives is
not a successful empty result. Scope remains attached to internalSuccess even when the
short empty copy matches unscoped noResults. Detailed human-readable coverage explanation
requires an actual approved scope/name presentation contract; none is invented here.

The remaining actual canonical failure cases must not fall through to “no route found.”
Recommend these additional project-owned messages while preserving exact cases internally:

| Input | Actions | Japanese | Korean | English |
|---|---|---|---|---|
| invalidEndpoint (retain role/reason internally) | E, S, R | 指定した駅で検索できません。出発地・目的地を確認してください。 | 지정한 역으로 검색할 수 없습니다. 출발지와 도착지를 확인해 주세요. | Cannot search with the specified stations. Check the origin and destination. |
| unsupportedRequest | E, S, R | この条件では検索できません。 | 이 조건으로는 검색할 수 없습니다. | These search conditions are not supported. |
| providerUnavailable | R, E, S | 経路検索を利用できません。 | 경로 검색을 이용할 수 없습니다. | Route search is unavailable. |
| rateLimited | R, E, S | 検索の利用制限に達しました。 | 검색 이용 한도에 도달했습니다. | The search usage limit has been reached. |
| configurationUnavailable | R, E, S | 現在の設定では検索を実行できません。 | 현재 설정으로 검색을 실행할 수 없습니다. | Cannot run the search with the current configuration. |
| malformedResponse | R, E, S | 検索結果を読み取れませんでした。 | 검색 결과를 읽을 수 없습니다. | Could not read the search results. |
| contractViolation | E, S only; no R | 経路検索を処理できませんでした。 | 경로 검색을 처리하지 못했습니다. | Could not process the route search. |
| disposed | No status surface or actions; lifetime host has ended | — | — | — |

configurationUnavailable is a failure of an invoked configured port, not factory absence.
contractViolation never fabricates a canonical failure. R is an explicit attempt, not a
promise it resolves missing evidence, configuration or rate limits; no countdown or automatic
retry is invented. Exact failure types remain available for future approved recovery detail.

### 14.3 Actions, stale commands and rejected submission

| Token / operation | Japanese action | Korean action | English action |
|---|---|---|---|
| S: explicit `submit(intent)` | 経路を検索 | 경로 검색 | Search routes |
| E: edit draft conditions; no coordinator mutation until S succeeds | 検索条件を変更 | 검색 조건 변경 | Edit search |
| R: `retry(expectedFailedAttemptID)` for the displayed current failed attempt | 再試行 | 다시 시도 | Retry |
| C: `cancel(expectedAttemptID)` for the displayed searching attempt | 検索をキャンセル | 검색 취소 | Cancel search |

S validation happens before replacing valid work; editing a draft alone neither clears
route answers nor cancels work. Accepted S starts a fresh identity. R never submits a stale
captured request: it delegates to DEC-087 matching failure retry, retaining explicit time
exactly or recapturing original now intent once. Duplicate/stale R cannot replace new work.
S after success/empty/cancellation is a new invocation, not retry; no automatic action occurs.
C may prevent publication even if the port ignores cancellation. Labels are not new APIs.

**Proposed feedback choice P1:** invalidRequest gives supplementary draft-level feedback,
leaving current searching/results/failure and identity-bound actions intact. Associate the
notice with the attempted draft, not the active request; clear it on the next draft edit or
accepted submission, with no timer, toast/modal or persistence mandated. A stale noMatchingFailure
or unsuccessful stale cancel only refreshes the current projection; it must not show an old
error over a new result. Disposed rejects submission/retry and has no surviving consumer UI.
This local feedback choice needs owner approval; the underlying rejection semantics are
already accepted. No new history operation follows rejection, replacement, cancellation or
retry. Clearing route results does not delete device-local recent-station history; storage,
limits, deduplication and deletion UI remain outside this slice.

### 14.4 Localization, phase placement and next slice

Apply existing DESIGN §26 and ARCHITECTURE §39.1 centrally: effective app/device ja-* →
Japanese, ko-* → Korean, otherwise English. Do not add locale branching in each state/view.
The repository specifies a LanguageResolver architecture but has no implemented general UI
resolver/string catalog in the inspected source; `LocalizedRailName` is a separate canonical
name value, not a status-copy catalog. Do not claim resolver/UI localization is already wired.
**Proposed copy choice P2 (remaining scope):** except for the owner-approved notConfigured
wording above, adopt the concise status/action wording and failure grouping
for the bounded projection. These are draft project-owned strings, not final linguistic,
layout or accessibility acceptance; no provider name/coverage/arrival promise is introduced.
No new DEC record is necessary for these local presentation proposals; record approval here
before implementing the proposed feedback/copy behavior.

Phase 3 owns the canonical result/recoverable-error boundary, JP/EN/KO route content and
basic diagnostics; it explicitly excludes final route-results visual polish. The smallest
next implementation after P1/P2 approval and authority is a pure, fake-backed presentation
contract mapper and centralized route-status/action copy table with an explicitly supplied
resolved-language value. If no shared language value exists, define only the minimal shared
language resolution seam under the existing ja/ko/English policy; no app/feature wiring.
Test every existing state/failure distinction, scope/payload retention, identity-bound action
availability and local rejected-draft feedback using invented values. Exercise the three
languages and unsupported-language fallback without duplicating DEC-087 async lifecycle
or Data routing tests. Mapping must not read Clock or call a port. No observation bridge,
actual view model, SwiftUI screen, polling, navigation or production port belongs to that slice.

Phase 8 owns feature presentation models, route setup/results, actual connect-route-search
flow, train selection and Journey start. Phase 5 owns Journey runtime/binding, Phase 6
persistence/recovery, Phase 7 visual foundations; this proposal adds none of them. Phase 11
owns comprehensive copy review, Korean naturalness, English clarity, truncation, VoiceOver,
Dynamic Type and language hardening (basic accessible truth must not be postponed). Phase 12
owns later reliability/performance/licensing audit. Status meaning and action safety can be
verified now without promoting Phase 3 tooling into production or accepting any milestone.

P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering
gaps. No ODPT reply supplied. No code, UI, tests/builds, external research, private access,
provider contact, caching/history implementation or production adoption in this task.


### 14.5 Bounded implementation status

P1/P2 are owner-approved. `Features/RouteSearch/RouteSearchPresentation.swift` is a pure
lightweight presentation transformation, not a FeatureModel or search workflow. Its input
is explicitly notConfigured or a current lifecycle snapshot; its source retains the entire
canonical snapshot. Alternatives are exposed in original order without sorting/selection;
internal scope/context/omission/failure values are unchanged. Status, feedback and action
copy identifiers resolve only through the approved project-owned copy table. Retry/cancel
descriptors carry the snapshot's attempt identity; table/action-array order specifies no
visual priority or default button. Available operations alone are this contract. The future
host must call DEC-087 guarded
operations and refresh from current state after every action. No descriptor executes itself.
The mapper never obtains a coordinator from AppEnvironment or subscribes/polls for updates.

`RouteSearchDraftFeedback` is separate value bookkeeping: a private reference token identifies
the current draft, rejected submission can attach only to that draft, and edit/accepted
submission clear its notice. It stores no draft content/history or tasks. The future host
reports synchronous submission outcomes with that draft token; delayed feedback for a different
draft is ignored. Stale retry adds no notice; stale cancel needs no feedback mutation and only
current-state remapping. No async workflow, timer, retry engine or lifecycle state is added.
Disposed/notConfigured projections suppress supplementary feedback and expose no actions.

`RouteSearchCopy.swift` centralizes the exact accepted three-language strings, including
「現在、経路検索はご利用いただけません。」 / “현재 경로 검색을 사용할 수 없습니다.” /
“Route search is currently unavailable.” Internal capability absence remains distinct from
invoked-search failure, with no retry/outage/restoration promise. `Shared/Localization/AppLanguage`
resolves an explicitly supplied effective language tag: Japanese/Korean primary subtags,
English otherwise (including missing/unsupported input), with case and hyphen/underscore
locale spelling handled centrally. It never reads device preferences; app-level effective
language injection, string-resource integration and Phase 11 hardening remain unimplemented.

Deterministic tests cover each state/failure/action distinction, original payload/context/
index/order/omission preservation, scoped empty, draft feedback boundaries, stale actions,
exact accepted copy and language fallback. Genuine opaque attempt IDs come from a cancelled-
before-invocation coordinator fixture, not a relaxed initializer. Existing Application suites
retain async lifecycle/composition coverage. Final counts/builds/review are in ROADMAP.
No coordinator or AppEnvironment redesign, UI/feature-flow wiring, cache/history, Journey/
train action, real/private input, provider contact or production routing adoption.


## 15. Production algorithm evaluation — bounded experiment authorized; adoption Proposed

**Original reviewed proposal, 2026-10-04 Asia/Seoul; scoped experiment authorized by owner.** Baseline
`307edac9117d7d1496d88a700f06019d23777513`. DEC-076/077, DEC-080 accepted portions,
DEC-081 and DEC-086 remain authoritative. DEC-086 R6 algorithm/ownership/adoption and
production resource settings remain unresolved; this section proposes an experiment, not
production selection. DEC-087 and published composition/presentation are unchanged.

### 15.1 Published pre-experiment baseline and scaling limits

Code basis: `SyntheticInternalRouteEngine.prepare`, `ordered`, `step`;
`SyntheticOptimalRouteSearcher`'s private `PreparedOptimalSession.open/admit`;
`SyntheticOptimalRouteKernel`; `SyntheticInternalRouteSearcher.admit/finalizeOptimal`.
All these solver declarations are DEBUG-only. Let n be one Trip's occurrence count, d its
dated slots, R qualified ride intervals, M the profile ride cap, P complete generated paths,
and T equal winners. These are analysis variables, not chosen production parameters.

- Preparation normalizes the view and requires complete in-profile interval/slot declarations.
  It visits every b<a occurrence pair, constructs/checks candidates and ridden station/line
  scope, then visits required intervals per active dated slot. Pair count is quadratic in n;
  per-pair interval/snapshot work means the entire stage is not simply O(n²). R can grow
  with the sum of d×n². Inactive slots do not erase required structural declarations.
- If M>1, every ordered pair of ride keys is checked before discovery (R² iterations,
  including same-TripID pairs subsequently skipped). Missing/unknown required relations
  fail even when disconnected from a discovered route. Only explicit absent/prohibited/
  inactive/out-of-scope cases allowed by the contract are legitimate exclusions.
- DFS uses a stack of copied full ride-key paths; each popped prefix scans all R keys.
  It forbids recurring TripID reuse, including across service dates. Branching can grow
  combinatorially with M (a loose R^M path-count envelope, not a measured complexity bound).
  Reaching the destination records a path but does not stop extension before the ride cap.
- Complete arrays, dedup set, normalized paths and insertion-sort outputs coexist. Sorting
  R keys and P paths has quadratic worst-case comparison/move counts; comparisons also
  traverse identity bytes/path elements. The optimal kernel scans P descriptors, then
  insertion-orders/deduplicates T ties, with quadratic tie work possible.
- `PreparedOptimalSession.open` checks **64 prepared paths** and **4 rides/path only after
  prepare finishes**. Descriptor checks allow at most 256 entries in each snapshot array
  and 128 UTF-8 bytes per relevant identity/date string. The separate canonical-candidate
  selector has a 7-leg ceiling. These are existing synthetic guardrails, not production
  settings or an early global input/heap bound. In particular, 64 paths does not cap the
  preceding DFS allocations. The engine has no overall byte-budget allocator.
- `step` counts logical work, checks cancellation/overflow and throws searchIncomplete at
  exhaustion. Units are not milliseconds or bytes; one unit can surround variable-length
  scans/copies. Preparation, selection, admission and finalization share that work allowance.
  Passing tests proves bounded fixture behavior, not production throughput or memory safety.

### 15.2 Three candidate approaches and exact adaptation obligations

The comparison below is an engineering assessment, not a benchmark result. Every approach
must consume one pinned qualified view, preserve occurrence addresses (view, Trip, service
date), exact original indices/snapshot association, directional connection keys/form and
qualified component-total allowance arithmetic. Never collapse repeated station visits to
StationID, convert a recurring Trip to a dated execution by guesswork, or infer a transfer
from a line/operator change. Current through service is one evidenced ride/Trip spanning
segments, with zero changes inside it. Cross-Trip through joins are not introduced. Every
algorithm retains the existing no-recurring-TripID-reuse restriction, even across dates.

| Proposed approach | Contract fit and representations | Main feasibility/proof risks |
|---|---|---|
| A. Existing ride-graph DFS with strict incumbent lower-bound pruning | Keep current fully qualified ride graph, path identity/used TripIDs and original prepared state; prune only prefixes proved strictly worse than an incumbent. Directional edges retain exact allowances; through remains one ride. Enumerate all equal winners, then existing key order/admission | Smallest change/proof surface; still quadratic pair qualification and potentially exponential tied paths. No promise of production suitability; input/graph construction can dominate |
| B. Event/ride-state priority-label search | Order a frontier by a proved lower bound; labels must include last dated ride/occurrence, ride count and used recurring TripIDs, plus all identity-distinct predecessor alternatives. Connect only qualified directional events, retaining exact source indices and through continuity | A station/time-only label is insufficient. State/label expansion and all-equal predecessor storage may approach enumeration. Must settle all frontier labels capable of equal objective, not stop at first destination; zero-duration edges require finite ride-count/history treatment, not an assumed strictly-time-ordered DAG |
| C. Round-based route scanning (RAPTOR-inspired) | Rounds can represent genuine train changes; route patterns must distinguish occurrence positions and compatible dated executions. Keep original onboard ride identity across evidenced through segments; apply occurrence-specific directional relations/allowances, not blanket station transfer times | Requires a new qualified pattern/index representation and proof that scanning/label dominance retains all identity-distinct equal winners. Repeated visits, forbidden recurring-Trip reuse, connection-specific evidence and ties can break simple one-label-per-stop assumptions. Greater initial adaptation surface than A |

For B/C, any shared state compression requires equality of future feasible continuations,
not just arrival time. Earlier arrival can wait for the same departure and yield the same
final arrival/change pair: discarding the later identity loses an equal optimum. Even
strictly earlier partial arrival is not sufficient to delete a path's reconstruction.
Two histories at the same station/time with different used TripIDs may permit different
suffixes. Preserve all tied provenance paths (or a lossless predecessor representation),
then materialize every distinct full key. Enumerating T outputs inherently costs at least
output size; compact predecessor storage cannot make an arbitrarily large tie set cheap.

### 15.3 Primary references and applicability limits

- Delling, Pajor, Werneck, **Round-Based Public Transit Routing**, ALENEX, January 2012:
  https://www.microsoft.com/en-us/research/publication/round-based-public-transit-routing/
  and official paper https://www.microsoft.com/en-us/research/wp-content/uploads/2012/01/raptor_alenex.pdf
  (§2 definitions/graph approaches; §3 round-based algorithm). The paper describes
  arrival/transfer Pareto routing and route scans by rounds. Its model uses route patterns
  and footpaths; that is not a TSUGINO source-evidence or complete-identity contract.
  We use it to motivate B/C, not to claim its pruning directly preserves DEC-086 ties.

TSUGINO selects lexicographically earliest arrival then changes, not the whole arrival/
transfer Pareto frontier. Preserving objective values is also different from preserving
all identity-distinct ties. All adaptation/proof obligations and scaling concerns above
are our code/contract analysis, not performance claims copied from the paper. No published
network timings transfer to this iPhone implementation, resource profile or inventory.
A search surfaced a KIT CSA paper link, but direct retrieval failed; it is not used as
support for this proposal. No feed, private evidence or provider contact was involved.

### 15.4 Approved bounded first experiment: A

Propose one DEBUG-only variant of existing discovery, not another route engine or live
RouteSearching implementation. Keep the published exhaustive mode as the oracle. The actual
API obstacle is that `prepare` currently includes graph qualification AND full enumeration;
feeding its completed paths to a new selector cannot measure enumeration savings. The
smallest future correction scope is an internal split at the existing validated graph /
stack-generation boundary, preserving the exact validation order, original state and
admission authority. Both modes use that same preparation; no caller-created completion
flag or public success-capable prepared-state constructor. Review this seam before execution.
The experimental mode remains behind a DEBUG RouteSearching adapter; no Application changes.

Use the same deterministic key traversal order first (no priority queue, heuristic estimate,
station dominance or route-pattern preprocessing). For a nonempty prefix with r rides,
use lower bound L=(last arrival, r−1). Feasible chronology/nonnegative qualified allowances
and genuine-change edges prove final arrival >= last arrival and final changes >= r−1.
Maintain incumbent objective B only from a completed prepared path satisfying the same
preparation invariants required for ordinary admission. If L is **strictly lexicographically
worse** than B, prune that prefix. If L equals B, preserve it: equal objective is not a
prune condition. If there is no incumbent, do not prune. Earlier arrival with more changes
cannot be discarded merely because the changes exceed B while arrival is still earlier.
Do not use rounded arithmetic or alter qualified allowance comparisons.

Incumbent validity is a proof obligation: map each existing admission predicate to unchanged
preparation invariants. A missing invariant must block this experiment's claim, not be
patched by admitting early or skipping a rejected winner. Existing defensive finalization
remains: every selected winner admitted → all winners; mixed rejection → searchIncomplete
with no survivors; all rejected → noUsableAlternatives with contiguous selected-index
accounting. Slower/objectively pruned paths are objective exclusions, not rejection omissions.

Required evidence is validated before pruning, including disconnected unknowns. Preserve
current failure order rather than promising to diagnose evidence not reached after cutoff.
Unknown reached required evidence → dataUnavailable, never a direct-only answer; incomplete
preparation/discovery/tie reconstruction/selection/admission/accounting → searchIncomplete;
observed cancellation → CancellationError; only proven empty completed exploration → scoped
noResults. Returning an incumbent after any cutoff is forbidden. Freeze all winners in
existing deterministic key order before canonical admission. First-found/first-K is insufficient.

### 15.5 Invented workloads, measurements and experiment bounds

The original proposal executed no benchmarks; the authorized execution record is §15.7. Use fixed, named synthetic cases and explicit
finite manifests of dates, intervals, eligibility, continuity and positive/negative directional
connections. Stipulate complete inventory separately from generated arrays. Reuse existing
fixture and converter semantics; do not infer physical railway coverage from these inputs.

| Invented family | Required adversarial variation / comparison |
|---|---|
| Small direct/transfer | Fast direct, fast transfer, same arrival fewer changes, one through ride across line segments; exact objective and full key set equal oracle |
| Tied branching | Distinct trains with same endpoint times; prefixes with different arrivals that catch the same suffix; many equal optima and duplicate identity input normalization |
| Occurrence/date identity | A→B→A→D with distinct A indices; adjacent service dates and civil-midnight times; retain addresses/snapshots; same recurring TripID cannot be reused on another date |
| Direction/history | Asymmetric/absent connections, unequal qualified allowances, equal-time/zero allowance; two histories with different used TripIDs must not merge |
| Slower dense branches | Early valid incumbent with many strictly later continuations; measure saved discovery work separately from unchanged R² qualification |
| Coverage/admission/cutoff | Unknown disconnected relation/activation, missing/estimated required time despite valid direct route, incomplete manifest; selected rejection all/mixed; cancellation and work-limit exhaustion before/after incumbent and during tie/admission stages |

Concrete first benchmark grid (invented, not a production profile): use stations A/X/Y/D,
three sequential layers A→X, X→Y, Y→D, with q distinct two-occurrence Trips per layer,
q in {1, 2, 3}, plus one direct A→D Trip. Each Trip has one dated slot, original interval
[0,1], exact times, allowed endpoint permissions and affirmed continuity. Layer times are
08:01→08:05, 08:06→08:10, 08:11→08:20. Explicit inter-layer relations are directional,
affirmed and carry a stipulated total 60-second allowance (components 0+60+0); all other
required cross-Trip relations are explicitly absent. Same-station interchange at X/Y is
stated evidence, not inferred. One invented date label/view/policy set, exact compatible
snapshots, depart-not-before 08:00, scope ending 08:40 and M=3 define only these fixtures.
There are 3q+1 ride nodes and q³+1 complete paths (2, 9, 28), before objective selection.
Run separate direct-arrival variants 08:15 (strictly faster), 08:25 (all q³ transfer ties
win) and 08:20 (direct wins on changes); direct departure is 08:02. The generator must
assert these hand-derived counts. A separate slow-branch variant keeps direct arrival 08:15,
changes layer two arrival to 08:30 and layer three to 08:31→08:35, retaining the same
allowance and path count; a bound can then prune before exploring the final layer. Add
the targeted identity/unknown/cutoff cases above
as separately named small fixtures, not implicit perturbations of a claimed complete grid.

**Experimental bounds only:** begin with the existing oracle domain (no more than 64 complete
prepared paths, four rides/path, descriptor array/string ceilings above), tiny explicitly
listed views and horizons sized just to contain each invented case. Do not change those
ceilings for a favorable result. Count generated prefix/ride/edge/input entries as well as
complete paths: the existing limits are late and not a substitute for bounding fixture size.
Before any success comparison, prequalify that fixture through its manifest and successful
exhaustive oracle run: **every complete path**, including slower paths that would be pruned,
must fit the 64-path/four-ride domain, and every relevant descriptor input must satisfy the
existing array/string ceilings. A pruned survivor set is not this prequalification. Otherwise
pruning could hide a too-long/oversized slower path or excess total paths and turn the
published oracle's searchIncomplete into success. Out-of-domain variants remain failure-only
tests; they cannot support an optimized-success claim. Any future production/generalized
bound placement requires explicit design rather than measuring bounds only on survivors.
A future experiment manifest must list exact finite input sizes and an abort-only work/heap
safety ceiling before execution, justified by those fixture sizes and host capacity; this
proposal chooses no production horizon, cap, latency target or memory budget. Oracle-limit
violations stay failure cases, not speedup successes. Larger scale experiments require a
separately reviewed oracle strategy/limits, not an automatic expansion of this slice.

Compare canonical outcomes and complete deterministic winner keys, exact contexts/scope and
selected-index omissions with exhaustive mode. Also use hand-calculated small cases so shared
preparation defects cannot be hidden by oracle agreement. Permute inventory/connection input
order and repeat; verify the same canonical result. A common work limit can make exhaustive
fail while the variant completes; record that as differential resource behavior, not a
correctness equivalence result. Correctness comparisons require enough work for both modes;
separate cutoff tests assert each mode's truthful atomic outcome at its own checkpoints.

Record per-stage logical work and graph pair checks; prefixes expanded/pruned; complete paths,
tie/key comparisons, selected/materialized outputs; peak live frontier/predecessor/path entries; actual process peak/resident-memory
measurements only if reliably attributable, with harness baseline separated (structural counts are not bytes); elapsed monotonic duration for preparation,
discovery, selection and admission plus total. Report instrumentation overhead and warm/cold
conditions, repetitions/distribution, device/Simulator, compiler/configuration and fixture
hashes. Simulator timing is not a physical iPhone performance claim. Use measurements, not
a preset speedup threshold: correctness first, then whether saved discovery exceeds overhead
and whether qualification/tie output dominates. No AppClock or user departure semantics are
changed by harness timing. Retain only invented benchmark data/aggregates, no route history.

### 15.6 Owner choices and unresolved production evidence

| Proposed choice | Recommendation / why still a choice |
|---|---|
| First experimental algorithm | Owner authorizes A: bounded DEBUG-only strict incumbent pruning on the existing graph, correctness comparison and measurements. No production endorsement |
| B/C investigation | Defer implementation until A identifies the dominant costs; retain as alternatives if indexing/qualification/frontier size defeats A |
| Production ownership, limits and adoption (DEC-086 R6) | Remain Proposed/unresolved. Do not choose from synthetic correctness alone |

Before production settings: measure qualified target workload sizes (dated events, intervals,
directional relations, branching, tie multiplicity), input/update/invalidation costs, memory
and timing distributions on authorized target hardware, cancellation latency and maximum
uncharged work/allocations, plus source completeness, rights and applicability. Establish
supported scope and horizon/ride-cap product behavior explicitly; separately justify resource
cutoffs and deployment/ownership. No algorithm removes S9/T1 evidence or licensing gates.
The owner has separately authorized bounded implementation and execution of A. No new semantic decision or new DEC identifier is
needed merely to prototype A; production algorithm/adoption remains a separate decision.
P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering
gaps. No ODPT reply supplied. The current authorized experiment includes synthetic code/tests/builds and measurements only; no UI, caching/history,
private access, feed acquisition, provider contact or production adoption.


### 15.7 Bounded implementation and measurement contract

The experiment uses the existing `RouteSearching` boundary, shared qualification/discovery,
private prepared optimal session, key/selection kernel, and unchanged canonical admission.
The ordinary engines pass no experiment mode: original checkpoint sequence, validation,
exhaustive paths and outcomes remain unchanged. No live/default environment is configured.
`SyntheticPruningRouteExperiment.compare` first validates finite input bounds, then requires
successful **complete exhaustive** preparation, every descriptor check, selection and admission
on the original immutable inventory. Only then may it execute the instrumented pruned pass.
A failed oracle never starts pruning. The wrapper's total cost includes both passes; the
pruned-pass timing alone is NOT a replacement solver's end-to-end improvement. Preparation
is deliberately repeated, not cached. The caller still stipulates completeness of invented
inventory; no array or success establishes real coverage.

Incumbent proof mapped to existing admission predicates:

- Normalization fixes exact dated bindings/snapshots, validates original intervals and every
  directional form/allowance. Context construction supplies exact chronological endpoints.
- Coverage checks declared profile membership, activation, allowed required endpoints,
  in-window exact times and affirmed continuity before graph discovery. Unknown disconnected
  required evidence is still fatal. Connections are globally checked before pruning.
- Graph edges require affirmative direction/form and exact nonnegative allowance feasibility;
  thus next departure >= previous arrival, and next arrival >= departure. Through service
  stays one ride even across line segments. Every cross-Trip edge adds one change.
- DFS starts at the requested origin, records only requested-destination paths, enforces M
  and the original recurring-TripID no-reuse rule. Claims resolve those original ride keys;
  no facts, addresses, indices or connections are reconstructed. These invariants cover
  ordinary admission's structure, endpoints, scope, chronology, eligibility, continuity and
  connection predicates. Defensive rejection injection does not license returning survivors.
- Therefore `(last arrival, rides−1)` is an admissible lexicographic lower bound. Only a
  strictly worse bound prunes; equality, earlier arrival with more changes, and all possible
  identity-distinct optima remain explored. Existing kernel freezes deterministic winners,
  then shared admission/finalization supplies all/mixed/none outcomes unchanged. Cutoff or
  cancellation throws; no incumbent result escapes. Objective exclusions are not omissions.

**Experiment-only manifest ceilings (abort, never truncate):** at most 10 inventory entries,
10 profile Trip IDs, 16 station keys, 8 line keys, 4 occurrences/line segments/service-type
segments per snapshot, 2 slots per inventory, 6 interval/continuity records per slot/input,
4 visit facts, 128 UTF-8 bytes per text. Bound nested fact/visit snapshots and connection
addresses too. At most 1,024 supplied connection records, 32 qualified rides (hence at most
1,024 pair checks/edges), 128 frontier paths, 4,096 popped prefixes, 64 complete paths, four
rides/path, and 200,000 charged steps per pass. Limits cannot be raised through the adapter;
a smaller step limit is abort-only. Caller allocation before invocation is outside these
bounds. These ceilings accommodate the 10-Trip/10-ride/90-record largest ordinary grid and
small two-date/repeated-visit adversaries, while bounding all internal array/key materialization.
The >64-path adversary fails before the pruned pass. Original published selector ceilings
remain unchanged. This is finite structural allocation control, not an empirical RAM budget
or a proposed production size/horizon/latency target.

Metrics are bounded scalar counters, not per-path logs. Qualification work counts existing
charged steps through graph construction; discovery work counts initial frontier generation,
popped prefixes/successor scans and, in pruned mode, an extra charged bound check per prefix.
Post work counts deduplication/order, descriptor/kernel and admission/finalization steps.
Pair checks include same-Trip pairs skipped after the check. Prefix count includes pruned
prefixes; complete paths counts retained destination paths before deduplication. Kernel
advances measure bounded comparison/move operations, not CPU instructions. Qualified ride/
edge counts and peak frontier/complete-path counts (also total ride-key slots in each
container) are structural counts: exclude the popped current path, descriptors, canonical
outputs, shared backing allocations and allocator overhead. They are NOT process memory.
No reliable isolated process-memory measurement is available in the shared Simulator test
host; no bytes/RSS/peak-memory improvement is claimed.

Monotonic qualification/discovery/selection/admission and whole-pass durations include
checkpoints and instrumentation. Selection begins after discovery's dedup/order; the remaining
post-discovery normalization is included in whole-pass time but not those two latter timers.
Whole experiment additionally includes bounds and both passes; input construction, result
assertions, formatting/printing, build and Simulator launch are outside timed intervals.
The explicit sorted-key DFS visits `Z-direct` first by last-in/first-out frontier choice;
this favorable incumbent order is stipulated, not an optimized production traversal.
One warmup and five sequential measured repetitions per q/variant use the same immutable
fixture; collection is bounded to scalar output records. Report distributions, not a timing
pass threshold. Fixture inputs are the §15.5 grid with seconds relative to an invented
08:00 anchor; service label `d-a`, one exact view/policy set, scope [0,2400] and view validity
[0,2501]. None claims civil-time/source applicability. Compilation/run evidence and observed
results are recorded in ROADMAP; synthetic declaration/Release isolation is required.

### 15.8 Proposed follow-up: whole-domain certificate before standalone pruning

**Historical follow-up proposal; baseline `023c1c206e1ed0cdabc0df41869455b9a1713ca6`.**
§15.7 describes the published, approved two-pass experiment and remains unchanged. This
standalone follow-up originally had no implementation/execution authority; the separately authorized
certificate-only harness is recorded in §15.8.7. Subsequent bounded E1 acceptance and implementation
are recorded in §15.8.8–9; production adoption remains unapproved. DEC-086 objective, all equal optima,
identity order and admission outcomes remain accepted. No production algorithm is selected.

Recommend one additional DEBUG adapter using the existing qualified graph and strict-bound
DFS, preceded by a bounded memoized **domain count certificate**, not a call to the oracle.
The certificate checks all original feasible paths, including paths an incumbent would
exclude. It stores scalar summaries of continuation states rather than complete path arrays.
The unchanged exhaustive searcher remains an independently invoked test oracle. This removes
mandatory complete-path materialization and duplicate qualification; it does not remove
whole-domain reasoning or guarantee lower time/storage. No new provider/route engine, queue,
station-label dominance or Application/presentation change belongs here.

#### 15.8.1 Boundaries and costs

Use precisely §15.7's input domain: T<=10 recurring TripIDs, R<=32 qualified rides, M<=4,
all nested input/string bounds unchanged. N denotes bounded supplied input size, E<=R²
qualified edges, S reached certificate states. Counts below concern logical operations;
Swift hashing, snapshot comparisons and bounded string work are not free.

| Stage | Work and retained state | Whole-domain responsibility |
|---|---|---|
| Input bounds / existing qualification | Bounded input scan; existing interval/date/eligibility/continuity checks and normalization. Retain original snapshots, slots and ride dictionary. Existing per-Trip interval enumeration is quadratic in occurrences before interval/snapshot costs | Preserve current validation order and all required evidence, including disconnected unknowns and slower paths. Do not check only routes useful to the request |
| Qualified graph | Existing R² pair loop, exact directional forms/allowances and deterministic ride-key order; O(R+E) graph entries | No evidence pruning. Keep absent/prohibited/inactive exclusions exactly as accepted |
| Domain certificate | Memoized states `(last full ride key, used recurring TripID set)`; at most S states, O(S×R) successor tests using existing key order/edge predicate, O(S) summaries plus depth<=M evaluation stack | Count every original destination-ending path and every original popped prefix, independent of incumbent. Verify original 64-path and experimental 4,096-prefix guards before pruning |
| Pruned discovery | Existing original-key path stack and used-Trip rule, strict lower bound only; O(R×visited prefixes), not a promised reduction; original path storage caps remain | Materialize all possible equal optima; no merging of histories or identity reconstruction from certificate states |
| Selection / admission | Existing descriptor/kernel and private prepared-state claim handoff; bounded winner/key sorting and original admission/finalization | No early admission, no relabeling, no survivor-only success after mixed rejection |

Reuse qualification **once** within an invocation. The graph, certificate and discovered
paths belong to one private opaque session pinned to the exact scope/view/snapshots and
original connections. No public caller-supplied count/completion flag, certificate constructor
or interchangeable handle. Refactor only the minimum internal seams: current `qualify` is
private and `PreparedOptimalSession.open` invokes `prepare` itself, so merely handing an array
to that API would repeat discovery. A future internal factory must own qualification,
certification, pruned preparation and the existing descriptor/claim/admission operations.
Published exhaustive and two-pass entry points remain unchanged. Canonical candidates still
come only from admission. Tests compare both outcomes, not certificate creation alone.

#### 15.8.2 Exact counting proof, including slower paths

A ride key contains the exact dated occurrence address and original boarding/alighting
indices. Give each of at most T recurring TripIDs a deterministic local bit position; this
is temporary indexing of canonical IDs, never a replacement ID. For state `(v,U)`, v's
TripID is in U and depth d=|U|. Successors are precisely the existing qualified edges from v
to w whose recurring TripID is not in U, only when d<M. Each successor adds its TripID.
Therefore the **state graph** is acyclic by increasing |U|, even with zero-time connections;
no assumption that railway/time graphs are acyclic is needed.

For each state compute, using checked saturating addition:

- `C(v,U) = [v ends at requested destination] + sum C(w,U∪{TripID(w)})`, saturated at 65.
- `P(v,U) = 1 + sum P(w,U∪{TripID(w)})`, saturated at 4,097.
- At depth M the sums are zero. Sum each summary over every distinct origin-boardable root
  `(v,{TripID(v)})`, with the same saturation. Destination arrival is **not terminal** for
  this recurrence: count its current path and any later destination-ending extensions,
  exactly as the existing DFS does. Roots and successors use normalized unique ride keys.

C<=64 is an exact predicate for the original number of complete paths, not an explored-path,
selected-winner, or incumbent-survivor limit. Saturation retains the exact pass/fail predicate,
not an exact above-limit count. P<=4,096 likewise checks every original DFS prefix, including
branches without a destination. There is no duplicate-path overcount: original normalized
roots/adjacency have one entry per key and each distinct sequence is generated once; the
existing dedup consequently cannot collapse two different generated key sequences. Repeated
input records normalize before this stage. A future multigraph/identity amendment would
invalidate that argument and must not silently reuse the recurrence.

Two different prefixes may reach the same `(v,U)`. Their feasible suffix sets are identical
**only under the current code**: scope is fixed, departure/arrival is fixed in v, each edge
already includes occurrence-specific direction/allowance, and the only extra history rule
is recurring-TripID exclusion. Different earlier date/order histories with the same U have
no further effect on suffix feasibility. Reuse a scalar suffix count at each incoming prefix;
do not count the shared state only once in root totals. This preserves path multiplicity.
Most importantly, discovery does NOT reuse that state to delete prefix identities. All equal
optima still need their own original paths and canonical outputs.

A loose state ceiling is `R × sum(k=0...M−1) choose(T−1,k)` (v's TripID is already used).
At T=10,R=32,M=4 this is 4,160 states, plus a virtual root if represented. This is an
experiment-derived cap, not production policy or a promise all those states are reached.
Propose allocating at most 4,160 memo summaries (no virtual-root entry needed), checking the
cap before insertion and observing each successor test/summary operation separately. These
observations do not select a new cutoff charge; §15.8.6 separates the two. This bound grows
combinatorially if T/M are enlarged. Memoization may save nothing on unshared histories;
then it is exhaustive prefix-state traversal in different form. Moving the check is not
making it cheap. No complete route list is built by certification.

#### 15.8.3 Which limits are independently provable, and which are not

- **Four rides per complete path:** existing experiment already rejects input M>4 and DFS
  cannot exceed M. That is sufficient here, with unchanged input rejection. Do not generalize
  this to the broader exhaustive searcher: for M>4, its later four-ride guard fails only if
  a generated complete path exceeds four, not because a dead-end prefix does. Widening the
  domain would require a destination-reaching length predicate or equivalent traversal.
- **64 complete paths:** C certifies the exact whole-domain predicate without materializing
  paths; evidence on pruned slower branches remains included. Ordinary reachability or a
  shortest-path count is insufficient. General counting still needs all relevant state
  transitions or an equivalent proof; no general polynomial-complexity claim is made.
- **Descriptor arrays/text:** §15.7 already bounds every input snapshot to four entries and
  text to 128 UTF-8 bytes, including nested bindings. These stronger *existing experiment*
  bounds imply the selector's 256-entry/128-byte checks for every possible path. Keep the
  actual selected-path checks too. Do not move a new descriptor rejection onto disconnected
  rides in the wider oracle domain; without these existing bounds, one must establish which
  rides lie on a complete admissible path before reproducing its path-specific failure.
- **32 rides / 1,024 connection records / nested input bounds:** preserve existing checks
  before graph/certificate work. They already bound allocations before DFS; 64 paths does not.
- **128 frontier paths:** with at most R roots, depth<=M and at most R children per expansion,
  the unchanged LIFO full-path DFS peak is <= `R+(M−1)(R−1)` =125 here. Each expansion pops
  one pending prefix then pushes children; at most M−1 ancestor levels have pending siblings.
  This proves the existing 128 limit cannot be exceeded anywhere in this input domain,
  including slower branches. Keep its runtime check; change of traversal invalidates proof.
- **4,096 popped prefixes:** P preserves the original whole-domain guard even if pruning
  would visit fewer. Both C and P are required; many dead ends can overflow P with C=0.
- **Logical work/cancellation:** a numeric step allowance bounds an execution, not the set
  of mathematically valid routes. Certification introduces work and removes other work.
  Reproducing the old oracle's exact checkpoint-by-checkpoint cutoff requires simulating or
  proving its qualification, DFS, sorting, descriptor/kernel and admission charges; C alone
  does not do that. No such equivalence is claimed. See the explicit Proposed choice below.

The new path-domain proofs do not validate arbitrary claims: §15.7's preparation-to-admission
invariant mapping remains required for every incumbent. Unknown reached evidence returns
`dataUnavailable`; incomplete certificate, discovery, tie enumeration, selection/admission
or accounting returns `searchIncomplete`, never a partial incumbent. Cancellation stays
CancellationError. Completed empty C=0 still needs successful full certificate/qualification
before scoped noResults. All selected admitted → all winners; mixed rejection →
searchIncomplete; all rejected → noUsableAlternatives with frozen contiguous selected indices.
Slower objective exclusions create no rejection omissions. If future admission adds a
history-sensitive predicate, revise the certificate state/proof before running this variant.

#### 15.8.4 Technical experiment and genuine behavior boundary

The memoized certificate, private session seam and existing strict-bound DFS are a recommended
**technical experiment strategy**, not a new product preference for the owner to select.
Implementation still requires a subsequent work authorization; this documentation task supplies
none. DEC-086 objectives/ties/admission and R6's unresolved production adoption are unchanged.

The previous draft unnecessarily coupled measurement counters to a proposed single 200,000-unit
cutoff. **That recommendation is withdrawn, not accepted.** Keep observational event counters
separate from execution controls. No new event weights, composite work unit, budget, or automatic
charging of certificate observations to `step` is approved. The published adapter still uses
its existing independent per-pass controls and mandatory oracle prerequisite.

Only a change to observable execution behavior needs an owner policy decision: may a future
standalone entry return a complete result where the published adapter would exhaust its oracle
allowance, provided all whole-domain guards and the standalone completion proof pass? If so,
the actual standalone safety/cutoff accounting must be specified and reviewed before exposing
that entry. The owner has not accepted this change. If exact old outcome/diagnostic precedence
at the same allowance is required, preserve or prove/emulate that accounting; certificate counts
alone cannot provide it. Do not silently broaden either policy while implementing metrics.

Recommend the smallest next authorized implementation be the bounded certificate and named
observational counters in a test-only comparison harness, leaving all published search entry
points and `step`/workLimit semantics untouched. Check certificate truth against the unchanged
oracle independently; measure its real cost. No replacement RouteSearching success contract
is needed for that first slice. Existing finite input/state bounds and explicit cancellation
checks bound/interrupt this helper; their derivations remain in §15.8.2–3. A harness timeout
invalidates a measurement, never produces a complete search result or silently becomes a new
user-facing cutoff. Any added reachable resource-abort rule must be described explicitly.

After that evidence, review the precise standalone cutoff contract or an equivalent old-
accounting proof. Do not advertise standalone speed from a certificate-only or pruned-pass-only
measurement: qualification, certification, discovery, reconstruction/selection, admission and
all retained state are part of total cost. Additional structural ceilings remain experimental
safeguards, not production budgets; do not raise old limits for a favorable comparison.

#### 15.8.5 Correctness and measurement plan — standalone solver not executed

Tests call the unchanged `SyntheticOptimalRouteSearcher` independently, on the same pinned
invented input and with sufficient work for a correctness comparison. Also compare the
published two-pass adapter's domain rejections where its stronger input bounds apply.
The standalone implementation must have no oracle invocation. A call-count/private seam
check verifies one qualification and no oracle call, without accepting caller-created state.
Compare full ordered optimal identity sets/objectives, canonical bindings/snapshots/indices,
contexts/scope and selected-index omissions; hand-derived expectations supplement the shared
oracle. Match canonical failures before cutoff; compare exhausted runs as resource outcomes,
not equivalence successes. Existing lower-bound proof (strictly worse only) is unchanged.

Reuse q=1/2/3 grids (2/9/28 paths), slow branches and all-tie variants. Add minimal cases for:

- Exactly 64 versus 65 original complete paths with an early fast direct incumbent: 65 fails
  before pruning; 64 succeeds only if all other proofs finish. Use three layers with two
  distinct Trips/layer and two explicitly inventoried dated slots/Trip: four choices/layer,
  4³=64 equal transfer paths. Six inventories/twelve rides fit existing bounds. Adding one
  fast direct Trip gives 65 original paths; without it retain all 64 equal outputs.
- Multiple histories converging on `(v,U)` and histories differing in U; count multiplicity
  against a tiny hand enumeration, while discovery retains all distinct equal identities.
- Destination reached then left/reached again, zero-duration edges and repeated station visits;
  count every destination-ending prefix, keep M and recurring-Trip reuse rules across dates.
- Unknown disconnected relation/slot and missing/estimated required time on slower paths;
  an oversized slower input is rejected by the existing experiment gate, not hidden by pruning.
- Dead ends with C=0 but P over 4,096: ten distinct A→B Trips, two dated slots each,
  twenty rides with equal exact departure/arrival instants, requested destination D, M=4.
  Explicit affirmed zero-allowance walking relations B→A connect every pair of different
  recurring TripIDs (360 records). Whole-domain prefixes =20+360+5,760+80,640=86,780;
  P saturates to 4,097 and fails before pruning, despite no complete path. All input sizes
  remain inside the old bounds. Invented equal-instant dates authenticate no real service.
- Abort/cancel during qualification, count saturation/memo insertion, pruned discovery,
  tie processing and admission; no result after any incomplete stage. Same selected rejection
  harness, original indices and deterministic output order; permute input order.

Measure comparable stages in both independently run variants: input/qualification and graph
pair checks, certificate states/hits/successor tests and C/P totals (zero certificate work for
oracle), discovery popped/pruned/expanded prefixes and successor checks, key/kernel work,
admitted output count, and existing step-call totals separately from each new observational
counter. Do not sum unlike events into a newly invented charged-work total. Report qualification, certificate, discovery,
selection/admission and **whole standalone invocation** monotonic times. Include bounds,
certificate allocation/clearing and cancellation checks; exclude separately reported fixture
construction/build/launch/assertion/output formatting. Do not compare oracle+variant total
against variant-only time as a speedup. Keep warmup/repetition/configuration reporting and
avoid timing thresholds; isolate measurement runs where feasible and disclose scheduling noise.

Report graph, certificate memo, evaluation stack, frontier, retained path/key and output
structural peaks separately; their simultaneous lifetime matters. Only report process memory
if reliably measured with a stated baseline; never convert counts into claimed RAM savings.
Certificate state exploration and all-tie reconstruction/output may dominate, so a slower
standalone measurement is a valid result. The scoped certificate-only measurements in §15.8.7 do not execute this standalone plan. Synthetic
proof/measurement cannot establish Tokyo-scale performance, production limits or adoption.
P3-T1/Phase 3 remain incomplete; P2-S9 retains fourteen classification and fourteen ordering
gaps. No ODPT reply supplied. Live/default routing remains unconfigured.


#### 15.8.6 Work-accounting clarification — documentation only

**Existing meaning.** `SyntheticInternalRouteEngine.step(stage)` checks cancellation, computes
work+1 with overflow checking, and checks `next <= workLimit` when a limit is supplied. Only
then does it assign work and increment the corresponding experiment qualification/discovery/
post metric. It invokes the checkpoint and checks cancellation again. A failed budget attempt
is not incremented; a throwing checkpoint has already consumed its unit. Checkpoint failure
is normalized as implemented, not retried. Stage labels are classifications, not weights.
The ordinary internal engine can have no supplied limit; optimal/published experiment callers
supply one. The published comparison resets the counter in **each** pass (up to 200,000 each),
not one shared 200,000 budget across both. `SyntheticPruningBounds.validate` runs outside those
counters. Timers, storage peaks, pair/prefix/pruned counts and kernel-advance metrics are separate
observations, though the stage work metrics mirror successful `step` increments.

Every charged call site on normal exhaustive/optimal search is covered below. One means one
`step` call before the named work, subject to earlier guards/returns; conditions matter.
Failure-only harness corruption adds no different unit definition.

| Existing charged event | Count / increment position | Costs not individually charged |
|---|---|---|
| Stage boundaries | One each before view validation (`configuration`), normalization (`validation`), endpoint validation (`endpoints`), scope construction (`intent`), global coverage (`coverage`): five on successful preparation | Configuration preguard, both endpoint scans, scope arithmetic, line/Trip subset construction |
| Inventory normalization | One per supplied inventory; one per declared interval; one per supplied slot; one per active continuity record | Train/binding construction, visit/snapshot equality, set/dictionary construction and hashing |
| Duplicate inventory reconciliation | One per normalized slot of a duplicate inventory after outer equality guards pass | Outer trip/interval/count comparisons, entire slot equality scan |
| Profile coverage | One per profile station, per profile Trip, per b<a occurrence pair, per normalized dated slot, and per required interval in an active slot | Ridden station/line scans, permission/time guards, context/candidate creation, insertion into ride/slot maps |
| Connection normalization | One per supplied connection record | Address/slot/index lookup, form validation, component arithmetic, duplicate comparison |
| Pair qualification | One per ordered ride pair when M>1, including same-Trip pairs later skipped | Relation lookup, exact allowance arithmetic, edge insertion |
| Stable insertion sort (ride keys and complete paths) | One per inserted value; one per `while i>0` comparison attempt, including the attempt that breaks | String/path comparison length, append, shift/assignment/COW allocation; no extra unit per moved element |
| DFS root scan | One per qualified ride key before testing origin | Singleton path creation and initial stack append |
| DFS popped prefix | One after each pop, before ride lookup | Pop, lookup and destination test; original-path storage checks |
| DFS successor scan | One per ride key for each expanded non-pruned prefix with depth<M, before edge/used-Trip checks | Scan of used path TripIDs, `path+[next]` copying/allocation, stack append |
| Strict-bound check (published pruned mode only) | One additional call per popped prefix before incumbent comparison, even without an incumbent | Actual comparison; pruned-prefix metric update. Exhaustive mode has zero of these calls |
| Deduplication | One per retained complete path before set insertion | Hashing full path and normalized array append |
| Optimal descriptors | One after prepare; one per complete path; one per ride; one per inter-ride connection | Claims lookup, descriptor bounds, full identity-key materialization and copying |
| Optimal kernel | One per `advance()` until complete | An advance can scan an objective, compare a whole tie key, move/reset an insertion cursor or insert into the winners array; not one primitive comparison |
| Selected handoff | One per selected winner, plus one per ride before resolving its claims | Handle lookup, claims-array materialization, rejection injection in failure-only tests |
| Shared admission | Five calls per ride that reaches all loops: association; scope/chronology; eligibility; continuity; leg construction | Endpoint/ride-cap guards, membership/snapshot scans, qualified connection validation, walking/rail construction, final RouteCandidate validation |
| Finalization | One before accounting, then uncharged final cancellation check | Omission/rejection or batch/success construction, payload validation |

The DEC-081 all-distinct adapter has one outer admission call per generated path but no
optimal descriptor/kernel or selected-handoff per-ride precharge. Its shared admission and
finalization use the same calls above. Thus even the two existing adapters have different
step totals for the same inventory. Do not describe either as a universal operation count.
Uncharged input-bound scans, instrumentation, async scheduling, ARC/allocations and constructor
work still affect total elapsed time. No test runner or clock duration is a work unit.

**Proposed observations, not proposed charges.** Use one increment in each named counter per
event below; do not add the columns together. These definitions make measurements reproducible
without attaching a threshold or inserting new `step` calls. They are technical measurement
choices, not accepted cutoff policy. If the implementation changes the event boundary, update
the metric definition before comparing results.

| Proposed counter | One event / increment site | Exhaustive counterpart / comparability |
|---|---|---|
| Certificate root request | Before requesting summary for each origin-boardable key | Origin matches, not all R root-scan tests |
| Memo lookup / hit | Before each root/successor summary lookup; additionally increment hit when a completed memo entry is found | No memo in oracle; do not equate a hit with a DFS pop or a skipped route |
| State expansion | Once on memo miss before initializing/evaluating `(v,U)` | Oracle can visit many path prefixes with this state; distinct metric |
| Destination test | Once per expanded state | DFS performs it per surviving prefix; neither is a complete-path count |
| Certificate successor test | Before each of R key tests for a state with depth<M, using original edge/used-Trip predicate | Same predicate category as DFS successor test, but different state multiplicity and used-set representation |
| Eligible certificate transition | When an edge passes both checks, before requesting child summary | Successful DFS extension; certificate does not copy a full path |
| Summary additions | One per scalar saturating addition of C or P after a child return, and one per scalar C/P addition into root totals | No direct old unit. Vector update means **two** scalar additions; repeated hits still contribute multiplicity |
| Memo write | Once when a completed state summary is stored | Not a path append; key hashing/allocation and initialization are not additional events |
| Discovery root/pop/successor/bound/pruned | Separate observations at the existing corresponding sites | Direct event-count comparison is possible with the same definition, not CPU-cost equivalence |
| Discovery extension / copied key slots | One per `path+[next]`, plus the resulting path length in a separate structural-volume counter; singleton roots separately counted | Measures intended key slots, not physical copies/bytes (COW/ARC can differ); oracle same sites |
| Complete-path retention / descriptor materialization / kernel advance | One per append, per descriptor, per advance respectively | Same event kinds; keep them separate from how many `step` calls surround them |
| Admission attempt / output construction | One per selected handoff, per constructed canonical rail/walking leg, and per candidate constructor invocation, separately | Existing admission units are not these events. No predecessor-tree reconstruction exists in current DFS: resolving original paths, keys and claims is the reconstruction cost |

No new single “certificate work unit” has been defined. Observational counters need bounded
storage/overflow-safe handling and timing includes their overhead; they must not select a
search outcome. Existing active cutoff controls remain active where reused. Additional
cancellation polls need not call `step` or consume a new budget unit; they still add real cost.

**Hand-derived example, not a run or a new budget.** Two distinct one-ride Trips A→D,
`A-slow` and `Z-fast`, one dated slot and one interval/affirmed-continuity record each, two
profile stations, one line, coherent view and exact eligible times. Departures both 100,
arrivals 180 and 150. M=1, scope contains all times, no connection records. Sorted roots are
pushed slow then fast; LIFO visits fast first. Both fit all existing bounds. Dictionary order
cannot change the two-key insertion-sort count. The proposed certificate expands the two
terminal states: C=2, P=2, no successor scan.

| Event group | Existing exhaustive optimal pass | Pruned pipeline after proposed certificate |
|---|---:|---:|
| Qualification charged calls | 26 = 5 boundaries + 8 normalization + 2 station coverage + 8 Trip/interval/slot coverage + 3 key-sort | Same 26 |
| Root scan / popped prefix / successor tests | 2 / 2 / 0 = 4 charged calls | 2 / 2 / 0, plus 2 bound calls = 6 |
| Singleton paths / extension copies | 2 / 0 | 2 / 0; certificate constructs no paths |
| Complete retained paths / pruned prefixes | 2 / 0 | 1 / 1 |
| Dedup / complete-path sort | 2 / 3 charged calls | 1 / 1 |
| Descriptor construction calls / kernel advances | 5 / 3 charged calls | 3 / 2 |
| Admission / finalization | 7 / 1 charged calls; one rail leg and one candidate constructor | Same 7 / 1 |
| Total inherited `step` calls | **51** | **47**, excluding all certificate observations; NOT an approved standalone cutoff total |
| Certificate root requests / memo lookups / hits | 0 / 0 / 0 | 2 / 2 / 0 |
| State expansions / destination tests / memo writes | 0 / 0 / 0 | 2 / 2 / 2 |
| Certificate successor tests / eligible transitions | 0 / 0 | 0 / 0 |
| Child C/P scalar additions / root C/P scalar additions | 0 / 0 | 0 / 4 |

There is no valid “47 + certificate work = common cost” equation. Initialization, key lookup,
checks, copying and output construction have different costs, and several receive no separate
charge. The published wrapper executes **51 then 47** with counters reset; its aggregate 98
successful calls is an observation, not a shared cutoff. As an illustration of existing API
behavior, a supplied allowance of 50 fails in its oracle although the pruned pipeline has only
47 inherited calls. Making certificate observations uncharged would not preserve that outcome:
it would merely hide the policy change. 50 is an illustrative existing caller value, not a
recommended limit. A shared certificate state hit would avoid suffix evaluation but would
still incur lookup and both summary additions; the two-direct example deliberately has no hits.

**Four separate concepts:**

1. Measurement: named event vectors, structural peaks and monotonic whole-invocation time;
   never determines success/failure. No common weighted unit is invented.
2. Execution safeguards: existing `step` controls, cancellation, bounded experiment allocations
   and any future explicitly specified abort control. These can stop computation and must
   report incomplete/cancelled, never return an incumbent. Not latency or memory guarantees.
3. Domain limits: the whole-domain 64-complete-path/four-ride predicate and original evidence
   rules remain unchanged. The certificate also preserves experiment-wide 4,096-prefix and
   nested guards; these are synthetic domain/safety constraints, not production policies.
4. Observable behavior: allowing success where the old oracle budget failed, changing which
   earlier failure wins, or introducing a different reachable cutoff is not just measurement.
   No such change is approved by this clarification.

Exact preservation has a real cost. Retaining the published wrapper trivially keeps its old
controls but still enumerates/materializes the oracle paths. A shadow/emulated counter must
reproduce charged qualification order, original DFS prefix/successor activity, dedup and
insertion-sort work, original descriptor/kernel processing and selected admission/finalization,
including early failures/cancellation/checkpoint ordering if that is the promised parity.
C/P aggregates alone do not capture sorted key comparisons, path ordering, tie processing or
checkpoint-dependent failures. Charging each certificate state once is particularly incorrect
when several original prefixes share it. A conservative bound may be a useful safeguard but
can reject runs the old engine completes, so it is not exact equivalence. Exact emulation or
a code-specific equivalent proof may retain much of the supposedly removed exhaustive cost.
Retaining only old calls on surviving pruned paths also does not preserve old accounting.

Therefore separate the technical proof/measurement slice from any cutoff-policy amendment.
Keep the published behavior while evaluating certificate correctness/cost independently; only
then specify the genuine behavioral difference, if needed. A future faster-search comparison
must include qualification, certificate, all required path/key/claim reconstruction, selection,
admission, instrumentation and safety-check costs. Neither fewer `step` calls nor lower
pruned-pass time establishes a faster standalone solver.


#### 15.8.7 Scoped certificate validation — implemented, not a standalone solver

The owner authorized the certificate-correctness and observational test harness only. No
new charged-work unit, budget, cutoff outcome or failure precedence was accepted. The
published exhaustive and two-pass searches retain their behavior. This DEBUG-only harness
has no RouteSearching conformance and never invokes the oracle, discovery or admission.
Tests invoke the existing exhaustive pass separately through an observation-only seam;
ordinary optimal-search results are also checked. Full evidence qualification reuses the
existing engine and existing 200,000-step experiment control without changing any step site.
Certificate events are separate observations, never charged to a new allowance.

The opaque count report is not a route result or authority for inventory completeness.
Its C/P fields saturate at 65/4,097, preserving exactly the <=64 and <=4,096 predicates.
Each root adds its suffix summary; each incoming edge adds the memoized summary again.
State identity is the exact dated ride key plus used recurring TripIDs. Different dates of
one Trip cannot bypass reuse restrictions. A destination contributes C=1 but **does not
terminate expansion**; P includes every visited prefix, including dead ends. Traversal
continues after saturation. Addition clamps before subtraction/addition, including Int.max
boundary tests. No canonical evidence or discovery identity is merged by memoization.

Under the existing R<=32, T<=10, M<=4 input bounds, a fixed last ride admits at most
sum(C(9,k), k=0...3)=130 used-Trip sets, hence <=4,160 states. Used-set size strictly
increases, so pending recursion is <=4. Tests independently enumerate masks and check
observed memo-plus-pending states against this bound. The existing DFS frontier proof is
R+(M-1)*(R-1)<=125, below the unchanged 128 guard; observed oracle frontiers are checked
against their fixture-specific bound. These are analytical bounds supported by tests,
not claims that fixtures attain every maximum. The largest observed memo was 2,600.

A separate fixed memo-plus-pending safeguard rejects overflow with a harness error, never
a complete comparison or canonical route outcome. Failure-only probes lower that guard
or cancel isolated child tasks at expansion/successor checkpoints; they cannot return a
certificate. No new route-search cutoff policy is introduced. Event counters are bounded
by at most 4,160 expansions, 32 successor checks per expansion and the finite roots/edges;
they are not summed into a common cost. Root requests, lookups/hits, expansions, destination
tests, successor checks, eligible transitions, scalar additions and memo writes remain
separate. A hand-counted fixture verifies 26 qualification callbacks and no discovery,
complete-path sorting or admission in the certificate; published exhaustive/pruned passes still charge
51/47 calls respectively. Equal charged counts do not imply equal CPU cost.

Validation covers q=1/2/3 layered variants; 64/65 paths; dead ends with exactly 86,780
hand-derived prefixes (reported saturated P=4,097,C=0); a smaller exact 78-prefix dead-end
oracle agreement; convergent multiplicity; different used sets; destination revisits;
repeated occurrences/dates; directional walking and evidenced through service; unavailable
slots, unknown disconnected relations and missing/estimated required times despite a usable
route. Successful oracle observations retain canonical outputs; existing admission and
pruning regression suites supply full-payload/rejection coverage. A certificate cannot
supply or reconstruct canonical winners. Domain-predicate failures agree with oracle
searchIncomplete; qualification failures agree with dataUnavailable. Failure cases are not
reported as successful route comparisons.

Measurement methodology: Xcode 27.0, Debug -Onone, arm64 iPhone 17 Simulator / iOS 26.5,
macOS 26.6.2. Each of 15 fixtures uses one warmup and five measured sequential certificate /
oracle pairs. Input/configuration/view construction is outside timers. Qualification,
certificate setup/traversal/release, oracle discovery, selection/reconstruction and admission
are timed separately where available. Whole certificate/oracle calls include bounds and
async dispatch; paired totals include both calls, excluding assertions and formatting.
Failed oracle calls expose total elapsed time only, not invented per-stage measurements.
Output/report lifetime after the call is not measured. Repetitions ran with affected suites,
so scheduling/Simulator noise is possible; times are observations, never pass thresholds.
Certificate-only totals exclude discovery/admission because that work is **not performed**,
not because it is free. Selection timings include existing key/objective reconstruction;
oracle whole-call time includes remaining preparation/reconstruction. The published
instrumentation does not isolate every allocation or reconstruction operation as a counter.
No reliable process-memory measurement was obtained. Memo/frontier/path counts are structural,
exclude graph/input/allocator costs, and establish no byte savings or standalone speedup.

Final validation: 86 functions / 154 executed cases passed (certificate 12 / 28 included),
with Debug app/extension dependencies built. Release app/extension build passed; all seven
new declaration probes and Release certificate/seam symbol exclusions passed. Earlier runs
are superseded, not added. Measurements and event tables are recorded in ROADMAP. Independent
review status is recorded there after final review. Future standalone integration still
requires a precise approved cutoff contract or proof/emulation of old charged traces,
including slower branches, sorting, admission and checkpoint-dependent failures. This scalar
certificate does not provide that proof. No production adoption or resource settings follow.


#### 15.8.8 Limit authority and next experiment — scoped E1 acceptance

**Subsequent owner approval:** E1 and its reviewed safeguards below are accepted for the
separately named DEBUG standalone experiment only. It may complete when its own safeguards
pass despite an unchanged exhaustive-oracle cutoff at an identical numeric allowance. Exact
legacy charged/callback traces are not promised. Published searches remain unchanged;
observed cancellation, truthful incomplete outcomes and no partial success remain mandatory.
No production resource settings or adoption are approved. The owner separately authorized
implementation, synthetic correctness tests and whole-pipeline measurements. The original
authority assessment/options below retain their rationale; §15.8.9 records actual completion.

Authority assessment at `c7fde9f9a60012e8d32b7b81f2be30cbcce51534`: exact legacy charged-trace
parity is **not a general accepted requirement for every separately identified DEBUG solver**.
DEC-080 accepts parameterized scope and truthful coverage/completion; DEC-081 accepts its
synthetic execution/outcome contract; DEC-086 accepts optimality/ties and honest failures,
expressly not numerical production limits or an algorithm. None defines a common work unit
across implementations. The existing all-distinct and optimal adapters already charge different
calls (§15.8.6). Exact parity is required if a change promises identical legacy-budget outcomes,
or replaces a published entry while preserving its observable cutoff behavior. The §15.8.4/.6/.7
parity-or-amendment recommendation was a boundary against silently changing that behavior,
not a newly accepted universal execution-trace requirement. The published entries remain frozen.

| Limit / behavior | Exact source and status | Purpose and implication for a separate experiment |
| --- | --- | --- |
| Charged `step` allowance | `SyntheticInternalRouteEngine.step` (lines 70–83): cancellation, checked increment, supplied limit, checkpoint, cancellation. `SyntheticInternalRouteSearcher` / `SyntheticOptimalRouteSearcher` supply their controls. §15.7 and `SyntheticPruningBounds.workLimit` fix the published comparison ceiling at 200,000 **per pass**; §15.8.6 lists charges. Approved bounded synthetic implementation safeguard; its current observable behavior is preserved. No accepted production number or universal unit | Limits that implementation's charged events, not CPU, bytes or mathematical route scope. Overflow/cutoff gives searchIncomplete; invalid configuration is separate. Matching numbers across solvers imply neither matching work nor matching outcomes |
| Complete paths <=64 | `PreparedOptimalSession.open` checks all prepared paths before selection; §11/§15.7 and the selector's bounded implementation. Experimental DFS also checks before adding path 65. Approved synthetic materialization/selection safeguard, **not a DEC-086 product alternative cap** | §15.8 deliberately retains this as a whole-domain admission predicate for the follow-up, including slower paths. C<=64 must pass before pruning; do not reinterpret as 64 winners |
| Popped prefixes <=4,096; frontier <=128 | Experimental branches only in `SyntheticInternalRouteEngine.discover`; §15.7. Not generic DEC-081 profile semantics or production policy | Proposed follow-up preserves P<=4,096 over original full exploration and runtime frontier guard; proof <=125 depends on existing LIFO traversal, R<=32 and M<=4. Dead ends count; destination does not terminate expansion |
| Profile ride cap M versus implementation four-ride cap | DEC-080 accepted V2 parameterizes positive M; DEC-081 §3 enumerates within M and excludes reused recurring TripIDs. `PreparedOptimalSession.open` separately rejects a complete path longer than four; §15.7 input gate restricts M<=4 | M defines semantic scope for that invocation, without choosing a production value. Four is a bounded implementation ceiling. Preserve both here; do not claim broader oracle M>4 rejects every long dead-end prefix |
| Descriptor and input bounds | `SyntheticOptimalRouteDescriptor.checkBounds`: 256 entries per snapshot array, 128 UTF-8 bytes per text; selector additionally limits candidates to64 and legs to7. `SyntheticPruningBounds.validate` and §15.7: 10 inventories/Trips, 16 stations, 8 lines, four snapshot entries, two dated slots, six interval/continuity records, four visits, 1,024 supplied connections; qualification caps rides at32 | Approved synthetic allocation safeguards, not source coverage or production budgets. Keep exact nested checks and order. The stronger experiment input domain proves descriptor ceilings for all paths, including pruned paths; selected-path checks remain |
| Certificate 4,160 memo-plus-pending states / depth 4 | §15.8.2/.7 and `SyntheticDomainCertificate.swift`; combinatorial R/T/M proof, tested observations; failure-only probes cannot return a report | Technical harness safeguard, not a route-search limit accepted in DEC-086. Preserve bounded state and checked saturation; a new integration must explicitly map abort and never treat missing certificate as success |
| Cancellation and failure precedence | DEC-081 accepted S1–S6, §4/G14; DEC-086 scoped acceptance; §11 handoff. Observed cancellation wins; preflight precedes coverage/exploration; resource exhaustion before an established failure yields searchIncomplete without lower-priority probing | Accepted externally observable **synthetic contract**, not an optional metric. Preserve stage/category precedence and no partial result; exact callback counts, wall-clock cancellation timing and identical failure reached at identical step allowance are different, implementation-dependent properties |
| Production horizons, budgets and adoption | DEC-080 acceptance deferrals; DEC-086 R6 / scoped acceptance; ROADMAP Phase 3 | Unresolved. No production number, solver or deployment is selected by this experiment |

Four distinct obligations remain: (1) whole-domain evidence, even on slower/disconnected
branches; (2) semantic scope and the explicitly retained original C/P domain predicates;
(3) finite resource safeguards and truthful aborts; (4) optional exact legacy trace equivalence.
Passing (1)–(3) does not prove (4), and dropping (4) does not permit weakening (1)–(3).
An unavailable required fact found during qualification remains dataUnavailable even with a
usable direct ride. A resource abort before qualification establishes it stays searchIncomplete;
no speculative lower-priority validation is required. Equal-optimum identity completeness,
original dated occurrences/connections and canonical admission remain mandatory.

**Options.**

| Option | Cost and value | Recommendation |
| --- | --- | --- |
| Exact legacy trace emulation/proof | Must reproduce qualification/sorting encounter order, original DFS prefixes/successors, complete-path order/dedup, descriptor/kernel advances, admission and checkpoint-dependent failure behavior. C/P summaries cannot determine these. An exact shadow traversal may retain much of exhaustive work, plus certificate and pruned work. Useful for a promised drop-in regression contract, not a fair common cost metric | Do not implement without a concrete need for identical-budget compatibility |
| Separate bounded experiment with declared safeguards | Qualify once, certify, prune, reconstruct/select and admit in one private invocation; oracle runs separately in tests. Measure all costs. Published wrappers/controls untouched. Identical numeric legacy budgets can yield different outcomes; explicitly approve that narrow experimental difference before execution | Smallest useful next full-pipeline experiment, subject to E1 below and implementation authorization |
| Keep published two-pass comparison / certificate-only harness | Already approved, supplies separate correctness/observations without any new completion contract, but still pays exhaustive prerequisite or produces no routes | Valid fallback if E1 is not approved; repeating these measurements is not the missing standalone proof |

**E1 — accepted bounded experimental behavior only (original proposal).** Allow a separately named DEBUG
comparison entry to complete when its own specified safeguards and full completion proof pass,
even if the unchanged oracle fails at the same numeric charged allowance. No published entry
changes. A standalone safeguard abort returns searchIncomplete, observed cancellation returns
CancellationError, and neither supplies an incumbent, partial winners or successful comparison.
This also acknowledges that the first discovered failure may differ when one implementation
exhausts before the other reaches a later validation; retain established stage/semantic precedence,
not identical legacy trace position. No ignoring already established evidence failures is allowed.
This is one scoped execution-contract choice, not approval of production limits or adoption.
The original documentation assessment did not authorize execution; the scoped owner approval
above now supplies that authorization.

Recommended initial safeguard specification for E1 (all numbers reused, no new composite unit):

- Retain the exact §15.7 input/graph gates and C<=64 / P<=4,096 over the whole original domain,
  before discovery. Violations return searchIncomplete; never truncate or narrow scope.
- Carry one existing engine counter through qualification, pruned discovery, normalization,
  descriptor/selection and admission, with the existing experiment ceiling 200,000 and existing
  call-site definitions (§15.8.6), including the pruned-mode bound check. Do not reset between
  stages. Retain supported smaller abort-only test allowances. This ceiling is borrowed solely
  as a bounded experimental safeguard, **not asserted equivalent to the oracle allowance**.
- Certificate observations remain uncharged. Bound certificate work independently by the proven
  4,160 memo-plus-pending states, depth 4, R<=32 successor scans/state and existing bounded roots;
  keep arithmetic checks/cancellation polls. Violating this safeguard yields searchIncomplete
  in the new entry, not a successful count or route result. This mapping is part of scoped accepted E1;
  the published certificate harness keeps its existing harness-error behavior unchanged.
- Retain actual runtime frontier<=128, path/descriptor bounds and canonical admission checks.
  Keep metrics bounded scalars with checked increments; instrumentation/runner abort invalidates
  the comparison and supplies no successful report. No stopwatch-based route cutoff is proposed.
  Allocation/Swift runtime failures are not claimed to be fully recoverable by these guards.

Implementation mechanics are recommendations, not further product votes: one opaque private
session retains the exact qualified graph, certificate and original prepared-state association;
reuse existing strict-bound DFS and admission rather than a second engine. Do not call the
public certificate helper and then requalify; expose only the minimal internal certificate/kernel
seam to qualify once. Prune only strictly worse admissible bounds and retain all distinct equal
optima. All admitted winners return; mixed rejection is searchIncomplete; all rejected is
noUsableAlternatives with selected-index omissions. A fully proven empty domain yields scoped
noResults. Slower objective exclusions are not rejection omissions. Preserve published APIs.

Tests independently invoke the unchanged exhaustive oracle with sufficient existing allowance
for equivalence cases. Compare full ordered identity sets, objective values, scope, contexts,
original snapshots/indices/connections, canonical payloads and omissions. Include layered slow
branches, all ties, 64/65 paths, dead-end prefix failure, disconnected/slower unknowns and
certificate/discovery/selection/admission aborts. Same-numeric-budget divergence cases are
classified as resource outcomes under E1, not correctness disagreements or equivalence successes;
no complete comparison claim when the reference itself is incomplete. No allowance is raised
just to get a favorable result.

Record qualification, certificate, discovery, reconstruction/selection, admission and whole
standalone elapsed time, with bounds, instrumentation, cancellation and session allocation/
release included as far as measurable. Report oracle and paired totals separately; fixture
construction/build/launch outside timers. Distinguish inherited stage charges, certificate event
vectors, path/key materialization observations, output size and simultaneous structural storage
peaks. Do not sum them into a common cost. Use prior warmup/repetition method; no timing pass
threshold, no fabricated process-memory bytes. If reconstruction cannot be isolated, report its
containing stage and whole-call cost explicitly. Improvement requires observed whole-invocation
cost, not fewer charged calls or certificate-only time. This experiment cannot establish Tokyo
performance, approved resource settings, live wiring or production ownership/adoption.


#### 15.8.9 E1 standalone DEBUG implementation and measurement boundary

`SyntheticStandaloneRouteExperiment` implements the scoped E1 pipeline; it is not the live
RouteSearching default. One private invocation creates one engine in pruned mode, validates
the unchanged input gates, qualifies once, invokes the same private certificate kernel, checks
both whole-domain predicates, continues existing discovery, then uses the original private
prepared-session selection/claims/admission. No exhaustive entry or oracle is called. The
qualification-only harness retains its previous error behavior. The shared original `open`
now calls an extracted private selection body with identical charges/order; published exhaustive
and two-pass wrappers still follow their original paths. Internal preparation seams are not
public graph/certificate parameters on the experimental port; its caller cannot supply prepared
state, winning handles or a completion assertion. Certificate memo is released before discovery;
original graph bindings/keys remain with preparation. No evidence is reconstructed or relabeled.

The engine counter is uninterrupted through qualification, discovery, normalization, descriptor/
key selection, admission and finalization, with ceiling 200,000 and supported smaller abort-only
allowances. Certificate observations are uncharged and independently bounded exactly as §15.8.7.
Normal entry always uses 4,160 memo-plus-pending states/depth 4. C>64 or P>4,096 is rejected before
pruning even on slower/dead branches. Input/ride/frontier/descriptor checks remain in place.
Certificate guard errors map to searchIncomplete only in this new entry. Failure-only probes
can lower/exceed the memo guard or cancel at expansion/successor, but return Never; no probe
returns a successful report. No new raised limit or common unit was introduced.

Deterministic E1 example: two direct Trips (slow180, fast150, departure100), M=1, explicitly
complete two-station inventory. Qualification uses 26 inherited calls exactly once; the full
standalone uses 47 inherited calls and succeeds at allowance 47. The independent exhaustive
pass requires 51 and returns searchIncomplete at 47. Standalone fails at 46, showing stages do
not reset the counter. Its certificate adds two summaries but no inherited calls. This is an
intentional resource-outcome difference, not a correctness comparison success or proof of
universal trace equivalence. No owner approval of production settings follows.

Tests reuse existing invented layered/dates/dead-end fixtures and the full canonical comparison
helper rather than duplicating it. They compare ordered identities, objectives via final exact
arrivals/train changes, canonical leg kinds, bindings, snapshots, indices, contexts, directional
walking and scope/policy references. They cover q=1/2/3 and four fast/slow/tie variants, 64
identity-distinct equal winners, 65-path/dead-prefix rejection, empty scope, shared suffix
multiplicity, different used-Trip histories across dates, repeated visits/through continuity,
directional allowances, reversed input order, five missing/unknown/estimated qualification
cases and partial/all selected rejection accounting. Cancellation/guard tests cover certificate
traversal and inherited stages through finalization, plus oversized input and invalid allowances.
The <=125 frontier proof and existing runtime 128 check remain; no reachable 129-frontier case
is fabricated inside a domain whose proof precludes it. Existing certificate arithmetic/bound
and affected admission/pruning suites were rerun. All claims concern invented inputs only.

Final iPhone 17/iOS 26.5 Simulator run: **96 functions / 181 cases**, including standalone
**10 / 27**. Debug dependencies and Release app/extension builds passed. Three no-DEBUG type
probes and Release symbol inspection exclude the experiment/report/failure harness and new
preparation seams/shared DEBUG code. An initial test-macro compile failure was corrected with
local throwing-value bindings before execution; subsequent focused evidence is superseded,
not added to these final counts. Independent final-review status is recorded in ROADMAP.

Measurement method: Xcode 27.0, Debug -Onone, arm64 iPhone 17 Simulator/iOS 26.5, macOS 26.6.2.
Thirteen fixtures, one warmup per implementation then five sequential standalone/oracle pairs
per fixture; both inputs and configuration/view/request values frozen outside timing. No timing
pass threshold. The standalone outer-call timer includes bounds, qualification, certificate
setup/traversal/release, discovery, complete-path normalization, descriptor/key reconstruction,
selection, claim reconstruction, admission, return and invocation-local cleanup. Oracle has its
own full-call timer; paired time is reported separately. Comparison/assertions/printing and
fixture construction/build/launch are outside timers. Returned result lifetime after the call
is not measured. Stage timers separately cover qualification, certificate, discovery, selection
(including descriptors/keys) and admission (including claims); complete-path normalization and
remaining dispatch/cleanup fall in whole-call time, not an invented zero-cost stage. Medians
need not sum. Suites ran together, so shared-host scheduling/thermal/allocator noise is possible;
fixed standalone-first order is a limitation, not randomized statistical evidence.

Event vectors retain roots/lookups/hits/expansions/destination tests/successor tests/eligible
transitions/scalar additions/writes separately from inherited stage charges. Metrics retain
qualified graph rides/edges, frontier/complete-path and ride-key storage, kernel advances and
output count. Different dictionary encounter order can change existing qualification sorting
charges even with equal source inputs. Certificate observations are not summed with charges.
Memo/pending stack exists with graph during certification; it is released before path discovery.
Separate peak values are not assumed simultaneous. Retained descriptors/outputs and allocator
backing stores are not fully represented by these structural metrics. No reliable process-memory
measurement was available, so no byte/RSS savings are reported.

ROADMAP records measured whole/stage costs and structural observations. Only q2/q3 direct-winner,
equal-arrival/fewer-change and slow-branch variants had lower standalone whole-call medians in
this run. q1 variants, transfer-winning variants and ties64 did not. This supports keeping the
experiment as a bounded comparison rather than adopting it: certification and all-tie output/
selection costs remain. No Tokyo-scale latency/memory conclusion, production solver choice,
production budget, live routing configuration, Application change or phase acceptance follows.


#### 15.8.10 Equal-optimum selection profiling — observations only

Owner-authorized DEBUG instrumentation profiles the existing algorithm, not an optimization.
`profileSelection` defaults false on the two experimental adapters and engine. The private
selection session wraps each existing selection step with a timer while invoking exactly one
original `step`; no charge, guard, objective, comparison order, winner or admission rule changes.
The kernel optionally records its existing objective/equality/lexicographic/insertion branches;
profiling-disabled order comparison still uses the original comparator directly. All new types
and changes are inside DEBUG. No profiler observation controls search or introduces a work unit.

| Observation | Actual timed/count boundary and limits |
| --- | --- |
| Claims | Existing prepared-path claims lookup/array construction once per descriptor; element counts are logical records, not allocated bytes |
| Bounds validation | `checkBounds` per ride; excludes charged checkpoints, connection lookup/form validation and surrounding guards |
| Descriptor/key construction | Existing `rides.map(context)` plus descriptor initializer and append: UTF-8 atom arrays, contextual key concatenation and arrival/change assignment. Atom totals count retained key positions. Allocation/ARC and key-building suboperations are not separately attributable |
| Objective kernel scan | Existing isBetter calls plus best/tie-array updates; objectiveTime is not pure Date-comparison CPU time |
| Identity equality/order | One whole-array equality and, when unequal, the existing lexicographic comparison. Optional atom comparator-call count includes repeated calls made by lexicographic iteration. Standard-library equality element scans and byte scans are not counted |
| Winner insertion | Existing Array.insert and structural shifted-slot count (`count−insertion`). Not allocation/copy bytes; sorted fixtures append with zero shifted slots |
| Kernel advances | Whole `advance` time; contains objective/equality/order/insertion timers and their overhead. Do not sum nested timers with this total |
| Selection checkpoints | Wall duration around original async step, including cancellation/charge/checkpoint/scheduling. It is not isolated instrumentation cost; no baseline checkpoint is removed |
| Path extension | `path+[next]` plus frontier append; count one logical construction and path-length elements. Root arrays, COW sharing, stack/result appends and all ARC/allocator operations are not exhaustively counted |
| Complete-path dedup/order | Set insertion plus conditional normalized append, and existing checkpointed complete-path ordering respectively. Set hashing/equality internals are not isolated. These stages occur before the historical selection timer; path-order timing includes its checkpoints |

Descriptor identity keys are not hashed in this private selection kernel; it uses equality and
lexicographic scanning. Complete-path Set hashing is a different, earlier operation. Canonical
admission has its existing separate timer. Whole-pipeline times retain qualification, certificate
for standalone, discovery, normalization, reconstruction/selection, admission and cleanup.
No allocation profiler/isolated process-memory series was collected in this shared test host.
Structural operations cannot establish bytes/RSS or prove allocator-specific causes.

Method: same immutable invented packets for both variants; three-ride equal ties 1/8/27/64,
plus eight one-ride ties. Existing bounds are unchanged (64 uses two dates on each of two
Trips/layer). The one-ride comparison also changes graph/key/common-prefix shapes, so it is
not a pure path-length intervention. One warmup per variant/profiling mode, then eight rotations
of four slots (standalone/off, oracle/off, standalone/on, oracle/on): each slot occupies each
position twice. Inputs/configuration are outside timers; assertions/printing follow timing.
Xcode 27.0, Debug -Onone, arm64 iPhone 17 Simulator/iOS 26.5, macOS 26.6.2. Focused suites shared
the test host; ranges are observations, no elapsed pass threshold. No measurement from an
incomplete run is presented as a successful comparison.

Profile-on/off comparison estimates enabled instrumentation perturbation only. Off still has
new wrappers, branches and profiling storage in this build; it is not the unmodified historical
binary. On adds clock calls, Duration arithmetic and a comparator closure/counter. Nested timers
and comparison instrumentation affect measured work. Some on medians are lower than off due
to variation; this is not negative instrumentation cost or evidence instrumentation is free.
Report ranges and paired differences, not a falsely precise overhead correction. Historical
~43ms and current samples are separate runs, not an optimization before/after result.

Final focused/affected run: 42 functions / 83 cases passed, including profiling 4 / 8. Tests preserve
full canonical payload/order and post charges/advance counts with profiling on/off for all five
packets; mixed better/worse objectives, duplicates and shifted insertions also match. E1's 47/46
standalone boundary and oracle 47 cutoff persist; profiling-enabled cancellation through finalization
returns no result. Affected selector, handoff, standalone and pruning suites passed. Debug app/
extension dependencies built. Existing unmodified Release app/extension evidence from the published
E1 slice is reused; new no-DEBUG declaration probes and an optimized no-DEBUG object verify all
three profiling types are excluded. No broad suite or Release app rebuild was needed. Prior focused
run is superseded, not added. Independent final review is recorded in ROADMAP.

**Supported finding:** in the 64-tie sample, existing lexicographic scans dominate selection,
not objective evaluation, descriptor creation, insertion shifts or selection checkpoints.
There are 2,016 equality checks and 2,016 lexicographic checks, 21,120 atom comparator invocations,
and 2,144 kernel advances. All 64 winners are retained and insert at the end, yet insertion starts
its scan at zero for each tie. That exact count is N(N−1)/2 on this already ordered fixture.
Array/UTF-8 common-prefix traversal is within the measured ordering operation, but these probes
do not partition generic iteration, ARC, allocations and byte comparisons into independent costs.
No general network/production bottleneck is inferred. ROADMAP contains timings and counts.

**Recommended next optimization experiment — not implemented or authorized here:** test one
isolated DEBUG append fast path for an equal-optimum key strictly greater than the current last
winner. Sorted unique winners imply it exceeds every earlier key and cannot duplicate one;
otherwise fall back to the original scan, including equality suppression. Keep objective scanning,
identity spelling, canonical ordering/admission and all equal optima unchanged. Leave the published
kernel as reference. Require complete winner-index/payload comparisons across sorted, reversed,
permuted, duplicate, prefix-heavy and mixed-objective inputs; equality/smaller cases must take the
fallback. Keep a bounded incremental transition and the existing pre-advance charge/cancellation
hook; explicitly report experimental advance/cutoff differences under scoped E1 rather than
silently changing the published kernel. Do not add a new cutoff unit or raise limits. Balance
on/off measurement as appropriate and judge full pipeline cost, including fallback overhead.
This is a technical experiment recommendation requiring separate implementation authorization,
not a new product preference, approved speedup or production algorithm adoption.

#### 15.8.11 Opt-in append-fast-path experiment

Owner-authorized bounded technical experiment, 2026-10-05. This does not adopt an algorithm,
change production settings or enable live routing. `SyntheticStandaloneRouteExperiment` accepts
`selectionVariant: .appendFastPath`; omission keeps `.reference`. The published
`SyntheticOptimalRouteKernel` and exhaustive engine remain byte-identical references. The
exhaustive adapter still uses the reference selection path. No discovery/prepared-path reorder
hook was added. Both variants retain original prepared ordinals and use existing canonical
admission; complete evidence qualification and certificate checks precede either selection.

The separate DEBUG `SyntheticAppendFastPathKernel` retains the same descriptor, objective and
atom comparator. Objective scanning finishes before ordering; a later better objective resets
the tie list exactly as before. During ordering, winners start empty. The first winner is inserted
by the original rule. For each later tie, one new advance asks whether `last.key < incoming.key`
using the exact existing lexicographic comparator. If strictly true, append. Otherwise return
from that advance and begin the original equality/order scan at index zero on the next advance.
Equality is never interpreted as strict ordering. Duplicate suppression retains the original
first representative. No key, snapshot, service date, index, connection or evidence is rewritten.

**Invariant/proof:** empty/singleton winners are sorted and unique. Original insertion/dedup
maintains that property. Given sorted unique winners and `last < incoming`, every earlier key is
strictly smaller than incoming by transitivity, so no earlier key can be a duplicate. Appending
preserves the invariant. Tests check sorted uniqueness after every experimental advance across
ascending, descending, mixed, duplicate, long shared-prefix and mixed-objective inputs; fixture
arrival order is not the premise. The descriptor limit remains 64, with unchanged input/key bounds.

**Charges and aborts:** one existing `.sorting` engine step precedes every kernel advance. A
successful fast check and bounded append occupy one advance; a failed fast check occupies one
advance and performs no fallback equality. The next advance is separately charged before fallback.
The first insertion needs no fast check. Objective and original fallback advances remain as before.
The same uninterrupted allowance spans qualification through admission; no reset, new common
unit or increased ceiling. E1 permits experimental numeric-budget outcomes to differ, not ignored
charges or partial success. Cancellation/failed checkpoint prevents the next advance; resource
abort remains searchIncomplete. Existing observed-cancellation and established-failure precedence
are retained, without claiming identical callback traces or numeric-budget parity. Selected-winner
rejections retain mixed→searchIncomplete / all→noUsableAlternatives selected-index omissions.

Observations retain original objective/equality/order/shift/advance counters. Added fastChecks,
fastAtomCalls, fastAppends and fastTime are separate: baseline order checks do not include fast
checks. Do not sum heterogeneous counters into a cost unit. Successful append counts as an insert
with zero shifted slots. Structural path copies, retained keys/frontier and winner count are not
allocated bytes. No process-memory/allocator-byte measurement is available.

**Measurement design:** fixed invented three-ride tie packets of 1/8/27/64 alternatives. All
configuration/view/request values are frozen outside timed invocations. Kernel-only runs derive
real descriptors from oracle canonical contexts, then use ascending/reverse/odd-even permutations;
this separates unfavorable fallback behavior without changing evidence or pipeline ordering. Whole
standalone runs retain normal prepared-path normalization and compare reference/append variants on
the identical packet. They do not claim descending/mixed descriptor order reaches production-style
admission: normalized pipeline order is unchanged. Full ordered payload parity is checked outside
timing against the separately invoked unchanged exhaustive oracle. Kernel-only times exclude
qualification, reconstruction and admission and cannot establish whole-search improvement.

One warmup for each variant/profiling mode, then eight four-slot rotations (reference/off,
append/off, reference/on, append/on), each slot in each position twice. Timers include kernel
construction/advances/output extraction at kernel level and the full standalone call at pipeline
level; preparation, qualification, certification, discovery, descriptor construction, selection,
reconstruction, admission and return costs remain included in the latter. Fixture construction,
assertions, oracle comparison and printing are outside timers. Debug -Onone, Xcode 27.0,
iPhone 17 Simulator/iOS 26.5 arm64, macOS 26.6.2; other affected suites share the host. Timing is
observational with ranges, no pass threshold. Profile-on adds per-comparison counters/timers;
off still includes optional instrumentation branches. No precise overhead correction or
production feasibility claim follows. Final measurements/validation/review are recorded below
in ROADMAP; any earlier execution is superseded rather than added.


#### 15.8.12 Compiler-optimized evaluation of the unchanged append experiment

Owner authorized bounded measurements only (2026-10-05). No algorithm/source/test/helper,
project, scheme, signing or deployment setting was edited. The published §15.8.11 fixture and
benchmark code is unchanged. Only these proposal/ROADMAP records change. Standard Debug and
Release remain as configured; default selection remains reference and Release has no experiment.

**Isolation and effective mode:** existing Debug scheme, separate temporary DerivedData
`/private/tmp/tsugino-append-optimized-dd`, and the sole build-setting override
`SWIFT_OPTIMIZATION_LEVEL=-O`. Effective app settings report -O, DEBUG, testability YES,
automatic signing and iOS deployment 18.0. Actual emitted SwiftDriver compile commands for
TSUGINO (the app module containing the routing library), TSUGINOTests and TSUGINOLiveActivity
all contain -O and -DDEBUG, with -enable-testing and -g. No conflicting -Onone/-Osize/-Ounchecked
flag appears. Batch compilation is retained; whole-module optimization was not enabled. This is
an optimized Debug experiment, not a claim of Release-equivalent performance. No optimization,
compilation-condition or signing override was persisted. Only Swift optimization was overridden;
other Debug settings/instrumentation were retained.

Reproduction form using the named destination (execution used its resolved Simulator identifier):

```sh
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -derivedDataPath /private/tmp/tsugino-append-optimized-dd \
  SWIFT_OPTIMIZATION_LEVEL=-O \
  -resultBundlePath /private/tmp/tsugino-append-optimized.xcresult \
  -only-testing:TSUGINOTests/SyntheticAppendFastPathTests test
```

Use a fresh result-bundle path for a separately authorized repeat. No temporary xcconfig or
committed benchmark helper was necessary. Ordinary Release settings were inspected without
building: no DEBUG compilation condition, testability NO, wholemodule, deployment 18.0 and
automatic signing. Prior E1 Release app/extension build evidence has verified source/review
provenance; the published append no-DEBUG two-declaration/object-symbol evidence matches the
unchanged source fingerprints. These checks remain applicable because no source/project/scheme
changed. They are reused evidence, not newly executed Release builds or exclusion probes.

**Method and interpretation:** same §15.8.11 four tie counts and descriptor permutations, one
warmup per variant/profile mode, eight balanced four-slot rotations. Each slot occupies each
position twice. Frozen inputs are identical between reference/append in this run. Full ordered
canonical payload/identity comparison against the unchanged exhaustive oracle occurs outside
timing. Kernel permutations verify the ordered identity keys outside timing; no pipeline evidence
reorder hook is introduced. Whole pipeline retains qualification, certification, discovery,
reconstruction/selection and canonical admission. Kernel-only samples omit those other costs.
Profile-disabled runs are primary; profiling-enabled runs explain event counts separately.
Existing stage timers/charged counters still run when profileSelection is false; this is not
zero instrumentation. No heterogeneous work totals or timing pass threshold are introduced.

Xcode 27.0, arm64 iPhone 17 Simulator/iOS 26.5, macOS 26.6.2; only the append suite was selected,
with serialized test execution. Host scheduling and thermal state were not controlled. Prior
-Onone runs included other suites and are historical context, not a contemporaneous causal
compiler-only comparison. Compare reference versus append within each run. Small effects without
a stable paired advantage remain inconclusive; no physical-device, production-scale, Release or memory claim.

Focused optimized validation passed 7 functions / 13 cases, zero failures/skips/runtime warnings.
Debug-with-O app/extension dependencies built as part of that test action. It verifies sorted
uniqueness, all 64 ties, duplicate/permutation/prefix/mixed objectives, canonical snapshots/dates/
indices/continuity, selected rejection accounting, whole-domain failure guards, cancellation and
E1 numeric-budget differences. The unchanged two-direct case remains reference 76 / append 75;
append 74 and reference 75 abort without a partial result. No new limit or accounting policy.
Historical 49 / 96 is separate unchanged unoptimized evidence, not added to this run.

ROADMAP records full primary timing ranges, separate enabled observations, limitations and
independent review. The normalized 64 whole-pipeline advantage persists under -O, but much less
of total cost lies in selection. Reversed kernels and mixed 8 still regress. Keep the experiment
opt-in/reference default: this order-sensitive result does not justify further optimization or
adoption. Before a future adoption decision, representative workload/coverage and production
resource-policy evidence would be needed; no new acquisition or benchmark is authorized here.

## 16. Supported inventory, request coverage and workload evidence — Proposed evaluation plan

2026-10-05. Documentation-only technical matrix under Phase 3's existing selected-provider,
P3-T1 and suitability gates; not a new product decision or implementation authorization.
DEC-076/078/080/081/085/086/087 remain authoritative. The bounded §15 investigation is
complete for now: append stays opt-in, reference stays default. No further kernel work is
proposed. Historical progress-map consumer gaps are superseded by §§12–14 implementation.

### 16.1 Product boundary and one coverage/workload matrix

[PRODUCT initial coverage](PRODUCT.md#initial-release-coverage-dec-047-dec-058) retains all
15 canonical lines/services: Toei Asakusa, Mita, Shinjuku, Oedo; Tokyo Metro Ginza,
Marunouchi including its branch, Hibiya, Tozai, Chiyoda, Yurakucho, Hanzomon, Namboku,
Fukutoshin; Tokyo Sakura Tram and Nippori-Toneri Liner. DEC-047/058 capability tiers
classify journey guidance, **not schedule-routing readiness**. Verified realtime capability
does not qualify calendars, passenger stops or transfer inventory; scheduled-tier status
does not prove those inputs either. Complete canonical lines are not clipped at Tokyo's
boundary. Through service does not recursively admit outside operators. Expansion gates
and permitted unsupported-segment presentation are unchanged. A finite evaluation scope
is not permission to narrow launch coverage or claim the untested remainder ready.

In the matrix, test names refer to current source in `TSUGINOTests`; they record invented
functional evidence, not new executions, source conformance or production completeness.
A qualified request needs a pinned view, request departure bound, declared finite scope,
and affirmative coverage of every required inventory member under resolved policies.
A packet or a successful route does not establish that coverage.

| Accepted obligation / case | Required request evidence | Existing bounded synthetic evidence | Missing production evidence / later measurement |
| --- | --- | --- | --- |
| Launch inventory; direct and transfer routing | Canonical station/line/Trip bindings and complete required dated-slot and eligible-interval declarations for the scope; explicit known absence distinct from missing inventory | `SyntheticInternalRouteTests.g1DirectInclusiveAndOutsideBounds`; `SyntheticTimetableOptimalRoutingIntegrationTests.convertedDirectVersusTransfer` exercises faster direct, faster transfer and fewer-change tie | Per-baseline-service inventory coverage and cross-service joins, source revision applicability; dated ride/interval volume and OD/time strata. No supplied baseline-wide qualified inventory |
| Calendar and service-day coverage | Applicable ranges/weekdays, unique additions/removals and precedence; supported execution-per-date correspondence; all service dates capable of contributing within resolved request bounds, including prior-date extended-hour service | `SyntheticTimetableConversionTests` calendar cases; `SyntheticInternalRouteTests.g7OpaquePriorDateAndMixedDates`, `g8InactiveUnavailableQualityAndPermissions` | Applicable source calendar/execution profile and completeness. Proven inactivity is not unknown service; production date/horizon resolution remains unresolved |
| Passenger occurrences, repetition, skipped stops and eligibility | S9-reviewed passenger-stop sequence and movement/ordering; exact original indices, repeated visits and dated snapshots; affirmative boarding/alighting eligibility for required endpoints. Passed positions are not fabricated passenger stops | `SyntheticInternalRouteTests.g6RepeatedVisitsAndPartialSnapshotClosure`, `g8InactiveUnavailableQualityAndPermissions`; `SyntheticStandaloneRoutingTests.datesMultiplicityThroughAndRepeatedVisits`; `SyntheticTripReviewTests` passed-position review cases | All 14 classification and 14 ordering gaps remain. Passed-position review tests are not a source-to-routing local/express acceptance test; source-specific skipped-stop correspondence and its end-to-end evidence remain a gap. Measure repetition and eligible intervals separately from raw rows |
| Timezone, midnight and time quality | Source-authorized civil-day anchor, zone rules, extended hours and unique instant conversion; exact/missing/estimated distinctions and chronology, no interpolation; arrival/departure roles remain separate | `SyntheticTimetableConversionTests.gapAndFoldRejectWithoutGuessing`, `civilRolloverDoesNotAddElapsedSecondsFromMidnight`, `missingEstimatedUnknownAndChronologyAreSeparate`; optimal integration `convertedMidnightTransferKeepsOriginalServiceDateAndInstants` | DEC-085 invented profile has no Toei/ODPT applicability. Need actual calendar/zone/quality profile and revision binding; measure service-day overlap and relevant temporal strata |
| Explicit directional transfers and qualified allowances | Each required directional relation has present/absent/unknown evidence; known eligibility prohibitions remain distinct from unknown, and usable relations require an applicable directional allowance/policy; station equality or geographic proximity is insufficient | `SyntheticInternalRouteTests.g3DirectionalWalkAndInclusiveAllowance`, `g4SameStationNeedsItsOwnAllowance`; standalone `directionalEvidence` | Real transfer relations, directions, applicability/validity and policy resolution. Measure required relation pairs as well as usable edge density, fan-out and disconnected components |
| Through-service continuity | Affirmative same-train continuity and compatible line segments at original indices; no change counted for evidenced through service | `SyntheticInternalRouteTests.g2ThroughServiceAndMissingContinuity`; standalone `datesMultiplicityThroughAndRepeatedVisits` | Source-backed continuous-run correspondence, including supported operator boundaries; measure through depth separately from train-change depth. Never infer continuity from names or adjacency |
| Equal optima and canonical output | Earliest arrival then changes; every identity-distinct equal optimum retained; original dated snapshot/index/connection payloads, deterministic identity order only | Optimal integration `distinctConvertedEqualOptimaAllSurviveAdmission`; `SyntheticAppendFastPathTests` 64 ties, duplicate/permutation/shared-prefix cases | Actual tie multiplicity, identity lengths, output/context volume and end-to-end admission cost. Invented 64 ties is a guardrail case, not a production output cap |
| Disconnected inventory and missing evidence | Whole required domain qualified, including slower/disconnected branches; known negative is different from unknown. Scoped noResults requires completed, qualified empty exploration | `SyntheticInternalRouteTests.g5CompleteNegativeVersusUnknownWithAnotherGoodRoute`; optimal integration `unavailableConversionPreventsUsableDirectFallback`; standalone `unknownSlowerEvidence` | Actual completeness evidence and qualification failure distribution. Unknown required evidence remains dataUnavailable even with a usable direct route; no silent exclusion |
| Coherent revisions and updates | Source/profile/mapping/calendar/connection revisions and validity windows correspond to one immutable view; no snapshot/index relabeling or mixed-generation joins. Updates require requalification of affected claims | Conversion `exactSnapshotRevisionAndDateMustMatch`, `indexMappingFailuresAreAtomic`; internal `g9ConflictingInputsAndIdenticalDuplicates`; timetable-routing integration mismatch cases | Source update cadence, atomic publication/invalidation and consumer transition evidence. Measure rebuild/requalification size and costs; preserve existing immutable contexts, no caching policy implied |
| Completion and resource safeguards | Proof of no better route and all equal optima before success; canonical admission and omission accounting; cancellation and any cutoff yield no partial complete result | Internal `g13CutoffsAtEveryStage`, `g14CancellationAtEveryStage`; standalone `guardAndCancellationAborts`, `selectedRejections`, `uninterruptedBudgetAndE1` | Production safeguards, optimum/tie proof and total feasibility. Mixed selected rejection stays searchIncomplete; all rejected stays noUsableAlternatives with selected omissions. E1 is experimental, not a production budget or legacy-trace equivalence |

### 16.2 Evidence classes and later measurement plan

Keep four evidence classes separate in every future report:

- **Invented functional fixtures:** explicit complete small universes proving a contract case;
  coverage is the named assertion, not prevalence or complete product behavior.
- **Invented stress cases:** adversarial bounds, ties, repetition, dense/disconnected graphs
  and failure branches. They expose growth and failure handling, not Tokyo distributions.
- **Source-derived structural evidence:** authorized aggregates bound to identified source,
  revision, profile, declared service/date coverage and extraction method. Raw source row
  counts alone do not equal qualified rides, usable edges or passenger occurrences. Rights
  and privacy review precede acquisition, derivation, retention or publication as applicable.
- **Representative workload evidence:** a justified sampling/coverage frame across the accepted
  baseline, relevant service/date/time and origin/destination strata, ordinary and adverse
  cases, with omissions, uncertainty, provenance and update sensitivity declared. Source-derived
  samples alone are insufficient without this argument. No such workload is established here;
  use of real user search histories is neither required nor authorized.

Later measure dated slots and activation states; qualified b<a ride intervals per Trip/date;
occurrence counts/repetition and eligible endpoint proportions; required connection-pair count,
usable directional density and degree distribution; branching, reachable/dead-end prefix and
complete-path counts, ride depth versus through depth and recurring-Trip restrictions;
service-date overlap; equal-optimum multiplicity, key lengths, canonical output/context size;
and update/requalification volume. Report distributions and extreme cases by declared strata,
not one average or invented Tokyo-scale values. Establish what is countable before attempting
potentially unbounded complete-path enumeration; any bounded/censored observation must say so.

A later authorized evaluation should include qualification, certification where used, discovery,
reconstruction, selection and canonical admission in total elapsed cost; report stage costs,
separate event counts, peak structural storage and reliable measured memory only if available.
Include cold/update work where applicable, cancellation and abort behavior, build/compiler mode,
hardware, warmup, balanced repetitions and ranges. Do not sum heterogeneous counters or overlapping
stage timers. Existing Simulator measurements and structural copy counts do not prove device
latency, memory savings, deployment suitability or general speedup. No benchmark is authorized here.

### 16.3 Decisions, dependencies and smallest follow-up

Before selecting a production solver, demonstrate full identity/tie correctness and whole-domain
failure behavior on the qualified scope, then representative total cost and usable output size.
Before deployment/ownership adoption (DEC-086 R6), compare measured resource/operational needs,
licensing/delivery constraints and maintainability behind RouteSearching. Before choosing horizon,
ride limits or safeguards, state which requests/inventory they cover, how omitted service dates
or paths are ruled out, and what truthful failure occurs when limits are reached. Numerical
production settings remain unresolved; synthetic bounds cannot be promoted implicitly.

**Genuine owner choices remain Proposed:** production provider/solver and R6 deployment/ownership;
production horizon/resource policy and adoption. Any change to accepted launch coverage or failure
semantics would require its own explicit decision; none is recommended here. Constructing this
matrix, selecting measurement strata and identifying existing assertions are technical planning,
not new product preferences. Objectives, identity, lifecycle and presentation are not reopened.

Without an ODPT reply, tracked-contract audits and a source-neutral qualification evidence schema
can proceed. Real stop/pass/order closure, source calendar/time/connection applicability and
representative structural extraction require relevant authoritative evidence and separately scoped
access; the reply is one possible evidence source, not the only possible conformance evidence.
The October 3 interpretation inquiry has no supplied reply. It is distinct from Q3 publication,
Q4 translation, item-5 bundling/deletion and registry/delivery gates; rights are source-specific.
No private reread, acquisition, provider contact or permission inference follows from this proposal.

**Smallest follow-up recommendation:** design one source-neutral request-qualification evidence
manifest, using an invented filled example and a missing-evidence example, bound to existing
view/snapshot/interval and policy references. Specify for each matrix obligation the evidence
reference, scope/revision, affirmative/negative/unknown state and invalidation condition; references
must not open files or assert authenticity. Reuse existing types/contracts; no parser, new solver,
benchmark, storage or numerical budget. Completion is an independently reviewed contract showing
how completeness would be substantiated (not just asserted by a flag), what is still external,
and how each unresolved obligation prevents the corresponding readiness claim. This advances the
inventory prerequisite without requiring private data; later real qualification remains gated.

P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification and 14 ordering gaps.
Live/default routing remains unconfigured. No new semantic decision record is necessary.

## 17. Request-qualification evidence manifest — Proposed review design

2026-10-05. Documentation-only follow-up to §16. This is a source-neutral **review index
of existing obligations**, not a new Domain model, validator, source profile, file format,
registry or authority. No loader, evidence reader, production configuration or runtime
`qualified` flag is proposed. DEC-076/078/080/081/085/086 govern the facts and outcomes;
DEC-087 and §14 continue to govern lifecycle and user-facing presentation.

### 17.1 Existing authority and minimal record structure

Reuse `InternalSearchProfileDefinition` and `InternalSearchScope` for declared supported
sets, exact request/departure bound, policy references and finite lower/upper bounds. Their
constructors establish local structure, not policy resolution or completeness. Reuse the
existing timetable view, `TimetableOccurrenceAddress`, occurrence binding and exact Trip
snapshot/original indices for correspondence. Do not mint replacement identities, equate
IDs with full snapshot equality, or merge dates by recurring TripID.

`SyntheticInternalInventory` currently distinguishes unknown (`nil`) from stipulated complete
negative (`[]`) interval/slot inventory; `SyntheticInternalActivation` distinguishes active,
inactive and unavailable. `SyntheticInternalConnectionKey` is directional, with present,
absent or unknown state; present allowances retain their component/total semantics. These
are mappings for the review, not permission to treat artificial assertions as real evidence.
DEC-085's reference table already binds assertion kinds to source/profile revisions, run,
original index range and event/eligibility roles. Reference resolution there is in-memory
fixture consistency, not authenticated provenance. The proposed manifest cites these existing
records rather than replacing their facts or implementing a second qualification algorithm.

| Review section | Minimal recorded content | Existing authority / meaning |
| --- | --- | --- |
| Request-domain binding | Exact request and scope definition; view identity and validity; full profile definition plus service-date and connection policy references; source/profile/mapping revisions supporting that view | `InternalSearchScope`/profile and pinned view; matching a policy token alone does not resolve it. No production duration, ride cap or freshness default is selected here |
| Required-domain derivation | Reference to the reviewed inventory enumeration and its scope; included Trip snapshots, required original b<a intervals, service-date slots, and the applicable calendar/extended-hour rule that closes date enumeration; explicit known negatives and dependencies | DEC-080 coverage and existing engine qualification. Account for required intervals before date/eligibility exclusions; no inventory inferred from discovered winners. Record why no required Trip/date/interval is omitted, not just a count or “complete” flag |
| Obligation ledger | One unambiguous obligation identity within this review, its target reference and kind, required applicability, semantic assertion, supporting evidence references, examination record, dependency references and unresolved reason | Kinds are existing §16 obligations: inventory/calendar, S9 order/classification/mapping, event time/quality/eligibility, continuity, directional relation/allowance and revision coherence. Local row identifiers are not canonical product IDs |
| Examination record | Which referenced revision and assertion was actually examined, by which accountable review role/record, method and applicable scope, finding and limitations; distinguish fixture stipulation from source examination | No claim of examination from presence of an identifier. A reference may be recorded but unopened; actual future examination needs separate access authorization. Review time is historical context, not an invented expiry period |
| Separate rights/delivery ledger | References to applicable permission decisions, permitted purpose/audience/delivery, unresolved gates and changes requiring rights review | Technical evidence does not grant acquisition, publication, translations, bundling or production use. An unresolved rights gate cannot be converted to “no service” |

Use opaque references in this design and public reports, never private paths, provider keys,
occurrence contents or credentials. A reference identifies an assertion-bearing artifact/review
and its exact revision and applicability; identifiers/hashes alone establish neither authenticity
nor meaning. Do not dereference anything as part of manifest construction. Real content, if later
authorized, belongs in its approved private boundary; no new persistence/export is authorized.
Duplicate or contradictory references cannot be resolved by first match. Use the existing
contract's uniqueness/correspondence checks where available; otherwise record an unresolved
review issue rather than inventing a new runtime diagnostic or failure precedence.

### 17.2 Semantic assertion is separate from examination status

The ledger keeps two axes, using descriptive review terms, **not new runtime enums**:

- Assertion: existing active/inactive/unavailable, exact/missing/estimated, allowed/prohibited/
  unknown, affirmed/unknown/contradictory continuity, or present/absent/unknown connection.
  An examined statement of uncertainty is still unknown required evidence. An evidenced absence
  is a known negative, not missing evidence. Missing unused counterparts remain permitted where
  the accepted timetable contract permits them; not every optional field must become exact.
- Examination: reference only/unexamined; examined and supports this scoped assertion; examined
  but insufficient or conflicting; previously supported but invalidated. Record actual method
  and dependency scope, not a self-certified status toggle. For invented examples label all
  supporting evidence as fixture stipulation, never source-verified.

A review conclusion of **required technical evidence accounted for** needs both a substantiated
required-domain enumeration and examined support for each required assertion, including known
negatives, with no unresolved required dependencies. Every field being populated, every listed
row being reviewed, matching hashes, or a nonempty route does not prove that unlisted obligations
are absent. Coverage derivation must explain closure against the applicable source inventory and
policies; if that cannot be shown, the ledger remains incomplete. A review index does not itself
perform that proof or validate facts. Production review/authentication tooling remains undesigned.

After evidence review, existing Data qualification still checks normalized inventory, matching
snapshots/revisions, activation, interval closure, endpoint eligibility/time quality, continuity
and all required directional relations under resolved policies, including slower/disconnected
branches. Genuine inapplicability/exclusions need their existing justification; no new requirement
to parse inactive event bodies is introduced. Canonical preparation/claims/admission remain the
only route to canonical candidates. Evidence closure is not exploration completeness, optimum
proof, admission success or product acceptance.

Unknown required evidence retains `dataUnavailable`; inability to complete execution or a resource
cutoff retains `searchIncomplete` with no partial success. Proven empty qualified exploration can
produce scoped `noResults`; it is not implied by an empty manifest. Selected mixed rejection stays
`searchIncomplete`, total selected rejection stays `noUsableAlternatives` with existing accounting.
Cancellation, configuration/unsupported-request checks and failure precedence remain unchanged;
this ledger does not override those earlier checks or map rights failures to a new search error.
No internal review references, omissions or raw findings become user-facing copy. Preserve canonical
payloads internally and use the existing coordinator/presentation mapping unchanged.

### 17.3 Invented complete and missing-evidence examples

All tokens, times and evidence below are invented; no artifact is opened or source verified.
This is a paper example compatible with existing concepts, not an implemented fixture/profile.
Use request A→C, depart-not-before 2030-04-12 08:00 UTC, invented scope through 09:00 UTC,
at most two rides, stations {A,B,C}, line {L}, Trips {D,X,Y}, pinned view V1. These numerical
bounds describe only this example, not proposed production settings. A stipulated fixed-UTC
calendar/time profile covers the entire example window, with one execution per Trip/date;
its examined-in-example inventory states exactly these three services can contribute and no
prior/next-date extended-hour execution overlaps. Calendar range includes this date, its weekday
is enabled, and the complete exception list is empty. That stipulation is the date-closure
premise, not an inference from three packets.

| Existing target | Invented facts and supporting review premise |
| --- | --- |
| D/date, snapshot D1, interval [0,1] | A@0 dep 08:05 → C@1 arr 08:30; exact times and allowed ridden endpoints |
| X/date, snapshot X1, interval [0,1] | A@0 dep 08:02 → B@1 arr 08:10; exact times and allowed ridden endpoints |
| Y/date, snapshot Y1, interval [0,1] | B@0 dep 08:15 → C@1 arr 08:20; exact times and allowed ridden endpoints |
| All three inventories | Only these two-stop snapshots/slots/intervals in this invented domain; S9-style passenger/order/movement correspondence and same-run interval continuity stipulated; endpoint counterparts explicitly missing where unused; coherent V1/source S1/profile P1/mapping M1 and validity covering the request |
| X/date@1 → Y/date@0 | Present same-station directional relation, affirmative evidence; component allowance alighting 1 minute + interchange 2 + boarding 1 = 4 minutes; reverse relation not inferred |
| Remaining required directional pairs | The existing qualification relation domain is fully enumerated; every other required distinct-Trip ride pair is explicitly absent in this invented world, with a negative assertion for each. No same-Trip reuse exception is introduced |

**Complete technical example:** opaque references E-inventory, E-calendar, E-positions,
E-times, E-permissions, E-continuity and E-connections name scoped invented assertions with
matching dependencies. Examination entries explicitly say “stipulated invented example,” and
close all required-domain rows, including the negative relation rows. On successful complete
search and admission, X→Y arrives 08:20 and beats D's 08:30 despite one train change. This
conditional outcome follows accepted semantics; the manifest does not execute it. Production
rights/delivery status is separately **not established**; it cannot authorize real use.

**Missing required connection example:** keep D fully usable, but E-connections for X@1→Y@0
is only a reference to unexamined content (or examination concludes its applicability unknown).
Its runtime relation remains unknown; no allowance is guessed. Other populated fields cannot
close that obligation. Required coverage fails as `dataUnavailable`, not D-only success,
`noResults` or an omission of X→Y. If X→Y were instead evidenced absent, that would be a
known negative, with D eligible to win after complete search/admission. If all evidence is
accounted for but execution aborts, the outcome is `searchIncomplete`, never an incumbent result.

### 17.4 Dependency invalidation and separation of gates

| Change | Qualification claim that must be reconsidered |
| --- | --- |
| Request/scope, departure bound, service dates or policy definition | Re-derive required inventory/date/interval/relation closure; a narrowed sample cannot establish launch readiness. Prior findings may remain evidence only for their original applicability |
| Calendar range, weekday/exception rules or execution correspondence | Recheck activation and overlapping service dates; inactive and absent claims may no longer hold |
| Snapshot/order/classification/mapping or original-index correspondence | Invalidate dependent occurrence bindings, eligibility, continuity, connections and contexts; never relabel old indices or silently replace retained snapshots |
| Zone/day anchor, event values/quality, permissions or chronology | Recheck affected facts, required endpoints, feasible intervals and connections, then search result proof; estimated/missing cannot inherit exact qualification |
| Directional relation, allowance components/total or through continuity | Recheck dependent feasibility/train-change claims and all affected optimum/tie proof; no symmetric or same-train assumption survives without support |
| Source/profile/mapping/view revision, validity, evidence correction/retraction | Reconcile explicit dependency correspondence before reuse. Same identifier or unchanged count is insufficient; a revision difference is not automatically semantic equality |
| Rights, purpose/audience or delivery terms | Reassess authorization independently. Technical facts may remain true while use/delivery is blocked; if the source/evidence itself is withdrawn or corrected, reopen technical dependencies too |

Invalidation withdraws reuse of the affected qualification claim; it does not mutate historical
Journey/Trip snapshots or erase past review evidence. Unaffected evidence may be reused only with
an explicit unchanged-applicability check; no automatic incremental-revalidation system is designed
here. No TTL, cache, retention period, update daemon or permission waiver is proposed.

### 17.5 Follow-up and decision boundary

No new behavioral choice is needed for this review-index design. Its organization and descriptive
review statuses remain Proposed technical design; accepted scope, identity, objective, lifecycle,
copy and failure rules are unchanged. Production solver/ownership, resolved horizon/resource policy,
rights/delivery and adoption remain separately unresolved. All 15 launch lines/services remain intact.

**Smallest useful follow-up is evidence review, not another synthetic helper.** Existing
qualification tests already distinguish complete inventory, unknown transfers and revision
mismatch; this documentation creates no new runtime behavior needing duplicate integration tests.
The tracked ROADMAP records the owner's report of sending the interpretation inquiry on
October 3, 2026 (P3-T1 invented conversion/input slice and Phase 3 progress map). This dates
the reported inquiry, not a reply; it is not independently examined correspondence. No reply
is supplied or examined in this record. If an applicable reply is later supplied, propose
review of that reply concerning
resource `35b68908-4558-47ae-bfa5-867e58544a1a`, recorded feed version `20260921`, plus only
the expressly identified applicable specification/profile sections needed to interpret it.
Purpose: establish which stop_times inclusion, stop/pass/permission and stop_sequence ordering
assertions it supports, for which revision, with exceptions and unresolved applicability recorded
in this review index. This is a proposed named-document scope, not authorization to open a reply,
follow its links, contact anyone or reread the archive/candidate. If no reply is available, an
explicitly identified official conformance/conversion document with the same applicability role
could be proposed instead; none is invented here. No ODPT reply has been supplied. Actual per-
occurrence corroboration and any later S9 acceptance remain separately scoped after interpretation
review. Implementation of real qualification must wait for concrete source requirements; no
parser, authentication mechanism or production budget can be justified by this index alone.

P3-T1/Phase 3 remain incomplete. P2-S9 retains 14 classification and 14 ordering gaps. Append
remains opt-in, reference stays default, live routing unconfigured. No private data was inspected.


## 18. On-device route calculation — preferred direction, Proposed execution boundary

2026-10-05. DEC-086 records the owner's durable direction to prioritize route calculation
on the iPhone. This section proposes the smallest architecture around existing contracts,
not a new solver, qualification system or enablement decision. Server routing is not an
equal-priority alternative; reconsideration needs concrete evidence and separate approval.
Synthetic experiments remain bounded evidence only, including the opt-in append variant.
DEC-077's ODPT-first evaluation priority and paused commercial evaluation remain in force;
DEC-004 and PRODUCT §9 external-provider preference are historical/provisional strategy,
not authority to override the owner's current direction. RULES 1–2 privacy-by-non-collection
and local-only convenience boundaries still apply: acquisition does not authorize unnecessary
identity, request/history or movement-data collection/upload. No new telemetry or history store.

### 18.1 Separate responsibilities and gates

| Concern | Recommended boundary | What remains unestablished |
| --- | --- | --- |
| Route computation | Data-owned on-device implementation behind existing `RouteSearching`; consume one qualified immutable view for the request, perform accepted earliest-arrival/fewer-changes selection with all distinct equal optima, then existing canonical admission | Production algorithm, resource safeguards, scheduling and feasibility. An invented complete view is not a real qualified inventory |
| Static/timetable acquisition | Data client/DTO/normalization boundaries supply canonical snapshots and dated timetable facts under accepted producer contracts; qualify the complete required domain before it is used | Authorized source, delivery mechanism, permitted on-device retention/bundling and updates. No network client, parser, storage or publisher is selected |
| Realtime acquisition | Keep provider capabilities, acquisition/refresh ownership and freshness separate from schedule search; use the existing centralized realtime architecture and applicable later-phase scope | On-device schedule calculation does not supply realtime evidence or guarantee offline operation. No new polling or routing/realtime integration is approved |
| Technical qualification | Existing view/snapshot/date/index, inventory, calendar/time-quality, permissions, directional allowance and through-continuity obligations remain authoritative; §17 is only their evidence review index | A populated index, identifier match or constructed batch does not establish evidence closure, completed search or optimality |
| Rights/delivery authorization | Review source/purpose/audience/acquisition/retention/translation/bundling/update/deletion permissions independently of correctness | ODPT Q3/Q4 and item-5 bundling/deletion gates remain unresolved where recorded. Computation location grants no permission and does not authorize private access |

This preserves all 15 accepted launch services. Realtime capability tiers are not evidence
of schedule-routing readiness. Missing required evidence remains `dataUnavailable`, including
when a usable direct route exists; incomplete work remains `searchIncomplete`, without partial
success. Rights restrictions are enablement gates, not evidence of no service. Canonical
admission, rejection accounting and accepted scoped results remain unchanged.

### 18.2 Composition, lifetime and replacement

Recommend supplying the on-device solver with a qualified immutable request view, rather
than allowing Features or the solver to fetch/interpret arbitrary sources. Data owns source
normalization and view qualification; App is the composition root, Application owns request
lifetime. This assigns responsibilities, not a new `QualifiedView` approval flag or runtime
API. Production representation and the point at which a caller captures the view still
need a narrow execution design; reuse existing references instead of duplicating authority.

After applicable qualification, rights and adoption gates are satisfied, explicitly inject
the adopted port into AppEnvironment. Its existing factory supplies independent coordinators
using the environment Clock. Preserve DEC-087 validation, now/explicit-time capture, identity
guards, replacement, cancellation, disposal and matching retry. Canonical results feed the
existing pure presentation unchanged. No Journey or train selection occurs automatically;
clearing route answers never clears recent-station history. Live/default remains nil in both
Debug and Release until separately authorized enablement; no fallback or successful-empty
substitute is introduced.

A replacement must be separately constructed and qualified under a fresh coherent view when
contents/scope/revision change, subject independently to applicable rights. In-flight consumers
retain their exact immutable old view/bindings: never patch or relabel it, or combine revisions.
Retention alone is not permission to serve old data as current. Each search must satisfy its
own validity/scope and qualification; a failed replacement does not authorize stale fallback.
The supplier's atomic handoff/current-view API, invalidation handling and update trigger remain
Proposed, with no persistence, publication service, freshness period or background-refresh policy
selected. Existing old/new batch tests prove only invented correspondence and rejection.

### 18.3 Unresolved choices and evidence

| Remaining detail (Proposed) | Evidence/design needed before implementation or adoption |
| --- | --- |
| Production algorithm and safeguards | Accepted identity/tie/completion proof plus §16 representative whole-pipeline workload evidence; no synthetic limit is a production budget |
| Execution ownership/isolation | Specify per-call mutable workspace versus shared immutable data, view capture, concurrent callers, task inheritance and cancellation checkpoints; heavy work stays off MainActor, with responsiveness measured later rather than promised |
| Delivery, permitted storage and updates | Applicable rights and source-specific revision/calendar/time/occurrence contracts; identify permitted delivery, retention/bundling, invalidation and update mechanism without inferring terms from silence |
| Resource and device feasibility | Representative dated-ride volume, branching, ties/output size and total time/memory, followed by explicitly authorized physical-iPhone resource/cancellation evaluation; Simulator microbenchmarks do not close this gate |
| Production enablement | Explicit reviewed algorithm/configuration and lawful qualified input adoption, resolved horizon/resource policy, required acceptance evidence and authorized App injection. This task enables nothing |

Passenger-stop/order interpretation can be resolved later before applicable real consumption
and acceptance; it need not block source-neutral execution design. No ODPT reply has arrived.
P2-S9 still has 14 classification and 14 ordering gaps, and P3-T1/Phase 3 remain incomplete.
No numerical targets, offline promise, licensing conclusion or launch/performance guarantee.

### 18.4 Smallest next source-neutral task

Recommend a **documentation-only per-call execution/isolation contract** for the future local
`RouteSearching` implementation, limited to the seam between an immutable view supplier and
the existing port. AppEnvironment can share one injected port among independent coordinators;
DEC-087 guards publication, but does not specify production solver workspace sharing, capture
of a replaceable view or cancellation responsiveness. The internal/optimal synthetic searchers originally retained only
fixed supplied views; §19.7 now adds bounded DEBUG optimal capture after preflight.
Neither that seam nor the earlier test-only composition settles production update/concurrency.
The earlier provider-style SyntheticRouteSearcher already has a per-call loadView seam;
§19 reuses that pattern rather than proposing another loading framework.

Define a single capture point and exact retained view identity, per-invocation mutable search
state, treatment of concurrent calls and view replacement during a call, inherited cancellation
and bounded checkpoint obligations without choosing numerical budgets or an executor yet.
Use invented A/B concurrent calls and V1→V2 replacement to specify deterministic later fake-backed
checks: no mixed bindings, cancelling A cannot cancel B, no detached orphan work, and no result
after an observed abort. Reuse existing coordinator guards and canonical admission; do not
implement another solver, store or qualification layer. Completion is a small reviewed contract
and identification of any actual scheduling/observable behavior choice needing approval, not
another microbenchmark. No implementation is authorized by this recommendation.


## 19. Per-call execution and isolation — Proposed bounded design

**Scoped E2 acceptance — 2026-10-05:** the owner approves one atomic immutable-view capture
per call, exact retention through execution, and replacements affecting subsequent captures
without automatically cancelling, relabelling or switching existing calls. This authorizes the
reviewed test-only composition, not production invalidation, update publication or adoption.
Historical Proposed E2 wording and unexecuted-validation statements in §§19.1–19.5 below
record the design stage; unresolved production choices remain Proposed. Current implementation/
verification is recorded in §§19.6–19.7 and ROADMAP.

2026-10-05. DEC-086's preferred on-device location is accepted; this section does not adopt
an engine or production scheduling/resource policy. It narrows §18.4 using current code.
No change to RouteSearching, DEC-087 or canonical admission is proposed.

### 19.1 Verified current guarantees and remaining gap

| Current code/contract | Established boundary | Not established |
| --- | --- | --- |
| Domain `RouteSearching` | `nonisolated protocol …: Sendable`, async throwing request/result; only canonical failures or CancellationError cross the port | `async`/Sendable alone is not an off-main execution guarantee or proof of cancellation responsiveness |
| `RouteSearchCoordinator` | MainActor owner creates one retained `Task` per accepted invocation; explicit cancellation/disposal, weak owner across port await and identity/state publication guard; AppEnvironment can share one port among independent coordinators | This is an explicitly owned unstructured Task, not an automatically lifetime-scoped child. It does not choose a Data executor or wait for arbitrary ignored cancellation to finish |
| Internal/optimal synthetic searchers | Nonisolated Sendable conformers, explicit `@concurrent search`, immutable supplied configuration/view, locally created engine, preparation/session, selection, claims and accounting; no detached worker | Fixed-view behavior remains the default; §19.7 adds opt-in DEBUG optimal capture. No production supplier, scheduling or resource feasibility is established |
| Earlier `SyntheticRouteSearcher` | `@concurrent search` awaits one `@Sendable loadView`, retains that value, validates it and checks cancellation around awaits; working output is local | Its provider-style view/envelope types are not the internal timetable view; do not interchange them or create duplicate admission |
| Internal engine `step`, catch/finalize | Cancellation checks before charges, around checkpoint suspension, before pending failure and final return; cutoffs discard partial result; per-call work/metrics | Charges count existing work, not latency. Checkpoints do not force a suspension, guarantee fairness, or interrupt arbitrary synchronous work |

Inspected project settings enable approachable concurrency and default MainActor isolation for
the app target, with `SWIFT_VERSION = 5.0`. Explicit nonisolated value types and `@concurrent`
entry points matter; neither a bare async function nor a Task created in a MainActor owner
justifies off-main CPU work. This is code/settings inspection, not a new runtime/build proof.
Internal view, configuration and prepared graph values are Sendable; facts/bindings are immutable.
PreparedOptimalSession/handles remain private and call-bound. Sendable closures may still access
shared actors: Sendable is not a claim that their effects or cancellation state are independent.

### 19.2 Recommended capture and per-call ownership

**Proposed capture rule (E2):** after entry cancellation and applicable configuration/profile
preflight, await one read of the supplied current immutable internal view. The capture point
is the supplier's non-suspending read of its current reference, not request submission, worker
creation or the start of an await. A read linearized before replacement obtains V1; one after
replacement obtains V2. No stronger ordering by caller start time is promised. Check cancellation
again on resumption before qualification/discovery. Never poll/reload the current view during
this call or relabel its bindings. A later retry is a fresh invocation and captures afresh.

The supplied view must satisfy existing qualification, validity and policy correspondence for
this request; capture is not approval. Keep the configured profile/policies immutable for the
port lifetime in the smallest experiment. A supplier read returns one whole view, not separately
read inventory/calendar/connection pieces. A changed compatible view has a fresh identity;
incompatible policies/revisions fail existing qualification, without automatic substitution.
Changing port configuration is outside this slice. Missing/unusable required view is unavailable,
not an empty inventory; invalid configuration keeps its earlier accepted precedence.

**Proposed replacement rule (part of E2):** replacement changes what later captures obtain;
it does not mutate or automatically cancel an earlier captured call. The earlier call can
complete against V1 if its existing qualification and validity obligations remain satisfied.
It does not claim V1 is still the supplier's current view. DEC-087 still rejects superseded or
cancelled publication. This is not permission to serve known-invalid/revoked data: mandatory
invalidation/rights-revocation handling needs its own evidenced policy before real deployment.
No stale fallback, TTL, publication service or automatic refresh is designed here.

Each invocation exclusively owns its mutable discovery frontier, used-Trip state, selected set,
prepared-state associations, admission/omission accumulators, diagnostics and work counters.
Share only immutable input/configuration values; do not share mutable kernels or a cancellation
handle across calls. Preserve one uninterrupted applicable allowance per invocation; neither
capture nor suspension resets charges. Do not promote E1/synthetic ceilings to production budgets.
A supplier actor may serialize the tiny reference read; it must not host the whole search loop.
No global search lock, actor-wide solver serialization or concurrency cap is selected.

### 19.3 Minimal execution mechanism and cancellation

| Mechanism | Task/lifetime tradeoff | Recommendation |
| --- | --- | --- |
| Direct awaited `@concurrent` Data entry with local state | Uses the caller's task/cancellation context; no second worker handle; may await a supplier actor briefly, then execute non-MainActor compute | Reuse the current internal-search pattern. No dedicated thread, queue capacity or fairness guarantee follows |
| Put all search work on one actor | Protects shared mutable state but unnecessarily serializes synchronous search stretches; reentrancy still needs per-call state | No requirement for shared mutable solver state has been shown; do not introduce global serialization |
| Spawn Task/Task.detached inside the port | Adds another lifetime, cancellation forwarding, joining and error/publication boundary; detached work does not supply automatic caller cancellation ownership | Unnecessary for this experiment; no orphan/background search task |

Application continues to own its existing worker Task. A direct port caller owns its own task.
Cancelling A marks only A; Data observes it cooperatively, discards its pending result and exits
without cancelling B or the supplier. Disposing a coordinator does not dispose a shared port or
other owners. Captured values release when the invocation unwinds; ignored cancellation can
retain them longer, so publication guards are necessary but not proof of resource reclamation.
No callback-trace parity or numeric latency is promised.

Reuse checks before work, around view acquisition and all suspension points, at bounded
qualification/normalization/discovery/selection/reconstruction/admission work boundaries, and
before return or throwing a pending non-cancellation failure. Observed cancellation wins there;
a cancellation arriving after the final check has no guaranteed observation, and the coordinator
still guards publication. Preserve accepted configuration→view→endpoints→intent→coverage order;
cutoff is searchIncomplete absent an earlier established failure, with no lower-priority probing
or partial success. Whole-domain evidence, all equal optima and selected rejection accounting
are unchanged. Do not wrap arbitrary provider errors into new public failure categories.

Any injected test acquisition/checkpoint suspension must be cancellation-aware and resume its
continuation exactly once on release or cancellation, including cancellation-before-registration.
No sleeps or timeout-dependent correctness oracle. Checkpoint work must be bounded; where future
algorithms call long synchronous/non-cancellable libraries, explicit bounded partitioning or a
separately reviewed cancellation mechanism is needed before responsiveness can be claimed.

### 19.4 Smallest implementation experiment and acceptance

Recommend a **test-only controlled capture composition**, not a production view publisher:
a test-local nonisolated Sendable RouteSearching conformer with an explicit `@concurrent` entry,
a cancellation-aware actor fixture holding one existing SyntheticInternalView, and direct
awaited delegation to a fresh unchanged SyntheticOptimalRouteSearcher per call. Reuse existing
finite invented fixtures, canonical result checks and stage barriers, with reference selection.
The actor's replacement method is a test control only, not an app update API. Reuse
`RoutingTestGate` with a separate instance per suspended invocation (it has one waiting
continuation); do not share that gate between A and B. Its short cancellation-handler Task
only hops to the gate actor to resume a waiter, not to run or own search. Reuse the
`RoutingViewStore` pattern with the internal view type, not its provider-view payload.
Always use valid
fixed configuration in this experiment; do not duplicate the engine's private preflight validator.
A production capture seam preserving configuration-before-view failure precedence remains a
separate integration requirement; this test shim is not an adopted port implementation.

| Deterministic scenario | Required assertion |
| --- | --- |
| A and B overlap on one port | Suspend A after capture; B reaches its own barrier/completes without A's release. Counters, prepared handles and canonical contexts are call-local; no sleep-based timing assertion |
| Cancel A while suspended | Cancellation-aware barrier releases A with CancellationError and no candidate payload; B completes unchanged. Cancellation before capture invokes no supplier read; after capture performs no discovery once observed |
| Replace V1 with V2 while A is suspended after capture | A retains V1; B started after confirmed replacement captures V2; neither contains mixed addresses/snapshots/indices. Reverse capture order obeys capture linearization, not submission order |
| Failure isolation | A encounters an existing unavailable-input failure or cutoff; B remains successful. Cancel A before releasing a pending-failure barrier: observed cancellation wins; no survivor/partial result after abort |
| Retention and supplier read counts | Exactly one read for each non-pre-cancelled invocation reaching acquisition; no reload after update. Retained V1 facts remain unchanged after both calls; existing qualification rejects a mismatched view |
| Execution boundary | Review compiled annotations and Sendable diagnostics in the later test build; deterministic main-actor coordination remains usable while A is suspended. Do not mistake a suspended-call test for proof of CPU fairness or physical-device responsiveness |

Reuse existing coordinator cancellation/publication/retry tests rather than redesigning that
owner. Existing converter/batch and engine coverage/chronology/limits tests remain authoritative;
this experiment tests capture/isolation composition only. No real source or resource measurement.
Compiler validation must confirm all transferred view/config/result values and closure captures
are Sendable under the repository's actual default isolation. Keep fixture state actor-isolated;
no unchecked Sendable, main-actor-bound payload or mutable pointer may cross to computation.
No current value-type blocker was found, but no production view representation/executor has
been compiled or verified by this documentation task.

### 19.5 Decision and scope boundary

E2's precise capture/retained-call replacement rule is **Proposed**, recommended for owner
approval before the experiment; the preferred device location and existing immutable-value
rules do not alone settle when replacement affects an invocation. No DEC identifier is added
for technical task/executor plumbing. Local per-call state, direct await and actor test barriers
are technical recommendations reusing accepted contracts, not additional product votes.
Production concurrency policy, any mandatory revocation behavior, algorithm/adoption and
resource settings are not selected. Acquisition/update publication, storage/cache policy and
rights remain separate. All 15 services stay preserved; append opt-in, reference default and
live routing unconfigured. P3-T1/Phase 3 remain incomplete; P2-S9 retains 14 classification and
14 ordering gaps. No ODPT reply has arrived.


### 19.6 E2 test-only implementation and verification — 2026-10-05

`SyntheticRouteCaptureIsolationTests` implements only the authorized composition. A test-local
actor atomically reads/replaces one immutable internal view; a nonisolated Sendable port's
explicit @concurrent entry captures once and directly awaits a fresh reference optimal searcher.
The supplier never executes the search. Valid fixed configuration is stipulated; production
configuration-before-capture integration and mandatory invalidation/revocation remain unresolved.
No production supplier, publication API, global lock, detached search worker or new work unit.

Controlled gates prove that V1 survives replacement, the next capture gets V2, and exact dated
bindings/full snapshots/original indices and canonical timetable contexts remain associated.
B completes while A is paused after selection; a one-interval fixture gives each call its own
existing allowance equal to the baseline charge count, without callback-trace equality claims.
Pre-entry cancellation reads nothing; cancelling A after capture prevents discovery and leaves
suspended B unaffected. Required-input failure and admission-checkpoint abort are isolated;
observed cancellation wins, with no partial payload. The new cutoff case is a checkpoint-induced
searchIncomplete; existing handoff tests supply numerical-budget cutoff coverage. Every owned
worker is cancelled/joined on completion/error exits; each suspended invocation uses its own
single-waiter cancellation-aware gate. No sleeps, timing thresholds or physical-device claims.

Final explicit iPhone 17 / iOS 26.5 Simulator run: **48 functions / 103 executed cases passed**,
zero failures/skips, including capture **6/8**, internal engine **19/44**, optimal handoff
**9/13**, coordinator **9/28** and composition **5/10**. Subsets are not additional runs.
Debug test action built required dependencies; @concurrent/Sendable code compiled under existing
settings. No Release rebuild was needed: app source/build settings are unchanged from published
batch validation at 513b96c, and all new code is in one DEBUG-guarded test file. This is not a
new Release build or responsiveness/resource proof. The initial build's test-only actor-await
assertion was corrected; the next run exposed an overstrong callback-order assertion. The final
single-interval/count-only correction supersedes both attempts; earlier counts are not added.

Separate non-author review approved final test/document fingerprints with no material findings;
scope/privacy/reference and whitespace checks passed. Source behavior, E1 safeguards, reference
selection and nil live/default routing remain unchanged. No new real qualification, data access,
rights, production supplier/adoption or milestone acceptance follows. All 15 services remain;
P3-T1/Phase 3 and S9's 14 classification/14 ordering gaps remain incomplete. No ODPT reply.


### 19.7 Bounded DEBUG preflight/capture integration — 2026-10-05

The owner separately authorized this source-neutral integration under DEC-081 and accepted E2.
`SyntheticOptimalRouteSearcher.init(configuration:workLimit:captureView:checkpoint:)` is an
opt-in DEBUG entry taking an in-memory `@Sendable () async -> SyntheticInternalView?`.
It performs no read at construction and exposes no throwing acquisition/network error API.
Fixed-view initializers remain unchanged in behavior, and reference selection stays default.

The existing engine performs entry cancellation, configuration/permission/nonnegative-allowance
validation and its charged configuration checkpoint **before** invoking capture. It then reads
once, checks cancellation immediately after the await, retains the captured value locally, and
continues the same qualification/discovery/selection/admission path with the same engine and
uninterrupted allowance. No duplicate outer preflight, extra charged unit, reset, empty-view
fallback, snapshot relabeling or second qualification authority. Fixed inputs take the original
view branch without capture or added charged checkpoints. Capture closure storage does not make
arbitrary work bounded: callers in this experiment supply only the controlled in-memory read;
production acquisition and responsiveness remain unestablished.

Outcomes reuse accepted precedence: missing/disallowed configuration or negative allowance is
configurationUnavailable with zero reads; exhaustion at configuration is searchIncomplete with
zero reads; missing or incoherent captured view is dataUnavailable after one read. Observed
cancellation wins before pending failures, including nil/invalid captured inputs. All qualification
and completion obligations still apply after a successful read. E2 retains older captured views
and affects only later captures on replacement, not currentness, revocation or publication policy.

`SyntheticRoutePreflightCaptureTests` checks all those boundaries, construction without reading,
pre-cancelled invalid configuration, cancellation at configuration and immediately after capture,
exact dated snapshot/indices/canonical context and fixed/captured output agreement. A one-interval
invented fixture sweeps every allowance from zero through the complete fixed-run charge count:
all smaller allowances fail incomplete on both paths, the final allowance succeeds on both, and
capture reads are zero at zero and one thereafter. This scoped accounting parity is not a general
callback-trace or computational-cost claim. A gated overlapping replacement test proves A retains
V1 and B uses V2; tasks are cancelled/joined on every exit with existing cancellation-aware gates.

Final validation and Release exclusion evidence are recorded in ROADMAP. No Application changes,
production supplier, update publisher, acquisition/error mapping, invalidation/storage/cache or
adoption. All 15 services stay preserved; append opt-in/reference default/live unconfigured;
P3-T1/Phase 3 remain incomplete; S9 retains 14 classification/14 ordering gaps. No ODPT reply.

## 20. Post-inventory pre-solver boundary audit — 2026-10-10

Documentation-only assessment using current repository contracts and the owner's supplied
first real Candidate-B pilot report. No private railway artifact, harness or receipt was
accessed; no pilot, candidate/search/solver or connection implementation is run or added.
[Producer §18](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#18-first-real-production-occurrence-inventory-pilot--2026-10-10)
records **`FIRST_REAL_P3_T1_OCCURRENCE_INVENTORY_PILOT_COMPLETE`** at published commit
`0c9b06741b8f1ce8ebce428e943b9c55d78d9a50`: one accepted static revision/Trip/dated
occurrence and only interval `0...13`, lossless association, **27/27 PASS**, no unresolved
findings. Receipt **1959 bytes**, SHA-256
`be25f8f4ff1097ff373d4d7a2c3f00451814971098e4eb3acd053a4f83779c3c`.
Occurrence `declaredComplete` covers only the exact one-address pilot declaration;
interval completeness remains `unknown`. Neither is sufficient request coverage.

### 20.1 Current Accepted authority versus historical proposals

| Authority | Current applicable contract / limit |
|---|---|
| DEC-076 | Accepted canonical request/proposals, one coherent Data view, identity/evidence duties and Application lifetime separation. DEC-079 partially supersedes only the internal timetable consumer; external meanings and Trip/Journey invariants remain |
| DEC-078 | Accepted producer semantics, exact dated binding/full snapshot/original indices, activation/time quality/eligibility distinctions. Producer validity is request-independent; a valid occurrence does not certify request closure |
| DEC-079 | Accepted consumer §§2–5/C1–C6, conditional on DEC-078: exact timetable context, evidenced movements/connections, request-specific coverage before enumeration, scoped success and honest unscoped failures. Local values and synthetic execution do not discharge real production evidence obligations |
| DEC-080 | Only §9.9 V1–V7 for P1–P4/P6 accepted: local full profile/scope and scoped-success values, separate coverage/completion duties. P5, non-selected policies and production parameters/resolvers remain deferred; §9 is not accepted wholesale |
| DEC-081 | S1–S6 accepted for synthetic-only use. Invented complete universes, all-potential-pair requiredness and all-distinct execution are not production closure policy or authentication |
| DEC-085 | C1–C4 accepted for bounded invented conversion. Its revision/assertion concepts inform technical association; synthetic source interpretation is not real applicability authority |
| DEC-086 | Scoped acceptance selects earliest arrival, then fewer train changes, all identity-distinct equal optima, identity ordering only for reproducibility, complete optimum/tie proof and honest failures. On-iPhone computation is preferred; detailed solver/ownership/resource/adoption choices remain unresolved |
| DEC-087 | Accepted current-request lifecycle/retry rules remain Application-owned; request qualification neither publishes results nor adds automatic retries, caching or Journey state |

The contract outline is explicitly **historical proposal**, not independently adopted authority.
This document's §17 is a **Proposed documentation-only review index**, not an accepted production
manifest/type/format. Older pending-acceptance, unresolved-S9/import and all-distinct-production
wording must be read through current acceptance overlays and the bounded real milestone records.
This audit accepts no unselected historical proposal and amends no decision.

### 20.2 Missing proof and A-versus-B responsibilities

Every production internal success, including scoped `noResults`, needs **sufficient relevant
input coverage for the exact supported request scope**, followed by completed computation and
canonical admission. DEC-086 additionally requires proof that no better feasible itinerary exists
and every distinct equal optimum survives. Evidence closure is a prerequisite, not completed
exploration, pruning correctness, optimum/tie proof or successful admission. Unknown required
evidence remains `dataUnavailable`; interrupted computation/resource cutoff remains
`searchIncomplete`, with no partial success. Observed cancellation and existing preflight
precedence remain unchanged; all rejected remains unscoped `noUsableAlternatives`.

| Boundary | Owns | Cannot establish by itself |
|---|---|---|
| **A — Qualified connection/transfer evidence** | Independently qualified directional train-change relations: same-station applicability or distinct-station walking form; exact anchors and from/to line or ride applicability; present/absent/unknown; justified alight/interchange/walk/board components and exact nonnegative total; compatible view/static revision, evidence references and invalidation | Which relations a particular request requires; occurrence/date/interval closure; complete search input or optimum. Station equality, topology, proximity or an ordered time gap cannot create a connection/zero allowance; direction is never inferred in reverse |
| **B — Request-scoped inventory closure/search-input qualification** | Bind exact `RouteSearchRequest`, supplied supported finite scope/horizon, static authority and actual occurrence inventory to independently substantiated required Trip/date/address/interval membership, connection requirements/references, unresolved holds and compatibility/completeness/invalidation state | Connection payload/allowance truth, source authenticity from a token, route enumeration, result production or execution/optimality proof |

Candidate B proves **what occurrence data is present**. The next boundary must establish whether
that data set is sufficient for a **specific supported search request** under supplied qualified
closure authority. Connection evidence is one independently qualified dependency of that closure,
not a substitute for closure itself. Neither occurrence nor connection inventories identify all
required service dates, Trips, intervals and relations merely by listing their loaded members.
In particular, matching revisions/counts and a populated or empty ledger cannot prove that
unlisted obligations are absent. Required-domain derivation must be independent of discovered
routes/winners and explain date overlap, exclusions and unseen in-scope coverage.

Retain **evidenced absence**, **conclusive inactivity**, **unavailable/unknown**, **unsupported**,
**not loaded** and **outside the explicitly supported scope** as different facts/holds. A missing
loaded record is not an absent relation or inactive service; an out-of-scope claim needs the
declared supported scope rather than post-hoc cropping. Unknown required intervals remain holds
even when one supplied interval is usable. Known negatives contribute closure only with exact
qualified applicability. No required source defect may be hidden as an ordinary omitted route.

**Direct requests are no escape hatch:** a direct candidate's existence is not direct-route
optimality. A future solver may return it as optimum only after accounting for every possibly
better or equally optimal alternative within the supported scope, including valid transfers.
The one-address pilot supplies no such scope/closure proof and justifies no reduced launch profile.

### 20.3 Ordering and the connection dependency seam

Select **`P3_REQUEST_SCOPED_SEARCH_INPUT_CLOSURE_NEXT`**: **B then A**, then separately reviewed
complete solver-input composition/execution. B can meaningfully retain exact required connection
obligations as **unresolved**, blocking qualification, without knowing walking or allowance
payload semantics. A subsequently supplies independently qualified compatible relation evidence.
This makes missing evidence visible before supplying one evidence category and minimizes invented
connection semantics. A first would leave requiredness unstated; wholly independent implementation
would still need B's request-relative obligations to establish readiness. No new product decision
or semantic blocker prevents this bounded B-first slice.

B retains an exact relation target/applicability reference, compatible authority/view reference,
requirement and resolution/hold status; **A alone owns connection form, components and total**.
Do not copy connection payloads into B. An opaque reference or asserted `resolved` bit cannot
discharge a requirement: later resolution must be checked against compatible qualified connection
authority. Until that boundary exists, the initial B-only slice keeps required connection evidence
unresolved. It cannot convert missing A into evidenced absence or zero required connections.
Any empty required-relation set needs independently justified finite-scope closure; it never follows
from one direct occurrence, an empty loaded map or an arbitrary caller completeness flag.

### 20.4 Reuse of §17 and unresolved policy

Reuse §17's request/view/full-snapshot binding, independently derived required-domain ledger,
semantic assertion versus examination status, known-negative versus unknown distinction,
exact dependency applicability and invalidation. Keep its human/source examination and rights/
delivery ledger separate. New pure production values should be a **narrow typed technical
projection** over the actual `TimetableOccurrenceInventoryView`, not a second occurrence
inventory or a wholesale implementation of the documentation manifest. Replace synthetic
inventory references at this seam with the existing production inventory; retain full snapshot
and original-index association and the separate address/interval completeness distinctions.
The review index remains useful for substantiating external closure authority; local constructors
cannot authenticate that authority, dereference files or turn examined-but-unknown into qualified.

The old §17 next-source-review and fourteen-gap statements describe that dated stage; later
bounded S9/import/pilot records govern those exact milestones. They do not close broader source,
connection, launch or delivery evidence. The minimum technical value does not implement source
review/authentication tooling or promote DEC-081 fixture enumeration into production requiredness.

A finite supported horizon is necessary as **explicit supplied scope**, but selecting its numeric
production duration is **not necessary for this type design**. Reuse existing accepted local
`InternalSearchProfileDefinition`/`InternalSearchScope` structure, including the full profile,
exact request/view and finite inclusive bounds, plus exact compatible scope/horizon/policy
references. A bare opaque horizon label cannot replace that structure or resolve its policy.
Invented fixtures supply their own explicit parameters; this audit chooses no minute/hour/day
duration, ride cap, production network reduction, resource number or adoption default.
Production horizon/resource/adoption policy and detailed solver ownership remain unresolved under
DEC-080 deferrals/DEC-086 R6. Technical construction safeguards need separate implementation
evidence; they are not solver capacity or product search policy.

### 20.5 Smallest next invented-only production slice — not implemented

Recommend one pure immutable **Data/Routing** request-closure value and finite subordinate
declaration/requirement/hold values, consuming existing Domain request/profile/scope and Data
inventory/static revision types. Exact Swift names, file split and construction limits are
implementation choices, not product decisions. The separately authorized slice should:

1. Retain the exact existing `RouteSearchRequest`, supplied finite supported scope/full profile,
   matching view/policy references, exact `RailwayArtifactRevision` and actual
   `TimetableOccurrenceInventoryView`; reject mixed views/revisions/full snapshots or request bounds.
2. Retain independently supplied, substantiated finite required-domain/date/address/original-index
   interval declarations with exact closure/dependency applicability references. Check actual
   inventory membership, matching binding/facts and required coverage; do not derive requiredness
   by scanning loaded slots, parsing opaque service dates, enumerating paths or selecting winners.
3. Represent bounded technical **qualified / incomplete / unavailable** outcomes or equivalent
   typed holds. Structural contradictions fail atomically. Missing/unknown required occurrences,
   interval coverage or dependencies block qualification; inactive/absent exclusions require their
   own qualified support. No caller-set success flag, empty declaration or local validity alone
   authenticates completeness. Even qualified technical input is not search completion/adoption.
4. Retain exact **required/unresolved connection** targets and compatible authority requirements
   without connection payloads. The initial slice fails closed for every unresolved required
   connection. Later compatible A authority may resolve it under a separately reviewed seam;
   no fabricated resolved reference, allowance or unimplemented connection view is accepted now.
5. Preserve exact dependencies and invalidation applicability for request/scope/profile, static
   revision, inventory/full snapshots, source/time/eligibility/interval authority and future
   connections. Changed applicability prevents reuse; retained immutable values are not mutated.
   No cache/TTL/update publisher, loader, registry or persistent format is introduced.
6. Use invented tests for positive stipulated closure, request/view/static/snapshot conflicts,
   missing/extra/duplicate membership, date/interval unknown versus qualified negatives, explicit
   unresolved connection holds even with usable direct data, no empty-list shortcut, invalidation,
   overflow/finite construction safeguards and preservation. A positive invented closure premise
   is not real-source authentication; any connection-free premise must independently close its
   required relation domain and cannot select a new production direct-only search policy.

No source interpreter, real access/pilot, connection payload, numeric production horizon choice,
candidate/path generation, search result, searcher/solver, ranking, persistence, AppEnvironment,
Application lifecycle, Journey or UI implementation belongs to that slice. No new Domain failure
or product behavior is needed. **`NO_NEW_PRODUCT_DECISION_REQUIRED`** for these source-neutral
technical values enforcing already Accepted truth. A newly required requiredness/exclusion rule,
launch reduction, degraded-success mode or production policy choice must be surfaced separately.

Broader status remains **`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`**, Phase 3
**In Progress**, live/default routing unconfigured. Exact next safe action, **not begun**:
separately authorize the smallest invented-only production Data request-scoped search-input
closure values and focused tests above, with explicit unresolved connection-evidence obligations
and fail-closed qualification; no connection payloads, solver, real access or runtime wiring.

### 20.6 Invented-only request-closure implementation — 2026-10-10

The owner separately authorized §20.5's bounded production Data slice at baseline
`f520d5ffe771820fa4e6d8d2b63c58bfe55fd60b`. The §20.5 design recommendation and its
not-begun next action above are historical. Implementation is in
`Data/Routing/RequestScopedSearchInputClosure.swift`; invented tests are in
`RequestScopedSearchInputClosureTests.swift`. Publication is not part of this task.

`RequestScopedSearchInputClosure` retains the exact existing `InternalSearchScope` and
actual `TimetableOccurrenceInventoryView`. The supplied `RailwayArtifactRevision` must
exactly equal inventory qualification's revision; it is exposed from that retained truth.
Three separate immutable `SearchInputClosureApplicability` values bind occurrence,
connection and external dependency declarations to full scope/request/profile/policies/view
and every inventory qualification component. Their bounded printable references identify
stipulated authority; constructors cannot authenticate review, legal rights or completeness.
Full profile definitions and request fields are compared, not identities alone.

The independently supplied ordered occurrence domain has its own complete/unknown declaration.
Each record retains a full expected dated binding, applicability reference, expected interval
authority and explicit original-index interval obligations. Requiredness never follows loaded
slots, winners, date parsing or all-pairs generation. Keyed full-snapshot representatives
also reject known recurring-Trip contradictions across different dates, including a missing
required date. For active records, positive intervals are locally accounted for; absent
intervals under exact declared-complete interval authority are qualified negatives; absent
intervals under unknown coverage remain held. Inactive records are qualified negatives without
active event/interval-authority checks. Unsupported, insufficient evidence and not-loaded remain
distinct holds. Profile support is checked on required active intervals' inclusive stations
and movement-bearing line overlaps, with no whole-Trip support policy or candidate creation.

Connection declarations independently retain complete/unknown domain authority and directional
from/alighting/to/boarding targets. Targets must reference required occurrences and valid
original endpoint roles; their exact required snapshots are known even if slots are missing.
Every nonempty target remains unresolved. External dependency references are also explicitly
unresolved; no asserted resolved bit exists. Complete-empty domains require their own exact
applicability and stipulated completeness; unknown-empty domains hold. These invented premises
select no direct-only or no-service production policy. `holds` and occurrence/interval accounting
retain deterministic declaration order; technical qualification is derived solely from an empty
hold collection after structural checks. Structural contradictions throw bounded typed errors
atomically. No aggregate unavailable/incomplete precedence or Domain failure is introduced.

#### Finite safeguards and invented evidence

A generated optimized Swift representation-model study preceded limit selection. It used
480 invented recurring Trips × six opaque dates = 2,880 requirement records, 32 intervals
per record = 92,160 explicit obligations, keyed address/target duplicate checks, and 1,440
unique dependency tokens (three invented ledger categories per Trip). Directional target
fanout swept 1/2/4/8 supplied targets per address: 2,880 / 5,760 / 11,520 / 23,040 targets.
Five iterations per shape on the development Mac measured fastest construction/checking
0.865 / 1.361 / 2.381 / 4.328 ms. The model counted 13,227,840 through 13,248,000 bounded
projection work units; this is a cost model, not actual production projection or iPhone timing.
Eight is an exercised invented shape, never a generated production relation policy. The
largest exercised shape bounds this initial target slice; 1,440 bounds the exercised unique
external ledger. Actual production construction at all selected collection maxima is covered
by the generated focused test, including full association, snapshot and interval checks.

| Bound | Technical value / rationale |
|---|---|
| Required occurrence records | 2,880; at most one per independent address, inherited Candidate-B address ceiling |
| Unique recurring Trips / opaque service dates | 480 / 6, inherited Candidate B |
| Stops / intervals per occurrence / total intervals | 72 / 48 / 92,160, inherited Candidate B |
| Full profile stations / lines / Trips | 34,560 / 34,080 / 480; 480 × 72 stops and 480 × 71 movement segments bound separately supplied sets; no membership is inferred |
| Connection targets | 23,040, largest generated new-dimension study shape |
| External unresolved references | 1,440, generated new-dimension ledger |
| Every newly retained textual spelling | 192 UTF-8 bytes; bounded prefix check before hashing/comparison, including canonically equivalent Unicode IDs and request endpoint copies |
| Supplied static input entries | 32, existing revision boundary, before comparing caller-supplied revision |
| Expanded logical payload | 347,370,560 bytes, conservative algebraic envelope below; not measured heap, wire format or allocator capacity |

Logical accounting uses an address envelope 432 bytes, reference 208, full required binding
47,456, qualification 10,672 and full scope 14,377,504. The cap sums the inherited inventory
120,000,000 envelope, separately retained scope, three applicability scope/qualification/reference
copies, requirement bindings/references, explicit interval arrays, target addresses/references,
dependency references, and conservative retained outcome/hold slots (64 fixed, 64 per occurrence,
40 per interval and 32 per connection/dependency). No COW sharing is assumed. Each actual
retained spelling is charged separately. Overflow-safe subtraction guards prevent budget wrap.
All top-level counts are checked before nested traversal; bounded strings and subordinate
counts precede hashing/full equality. Exact-limit/+1 and hostile top-level preflight tests
exercise these safeguards, including the logical-budget primitive.

Expected constructor work is O(I + R×S + Q×S + C + D + P): inventory address lookup I,
requirement records R, snapshot size S≤72, supplied interval obligations Q, targets C,
dependencies D and full profile members P. Set/hash lookup is expected complexity; bounded
counts/text also impose finite worst work. There is no pairwise full-snapshot comparison,
Cartesian interval/connection expansion or path generation. The maximum active fixture uses
12-stop snapshots, 2,880 slots, 92,160 supplied intervals, 23,040 targets and 1,440 dependencies;
a separate fixture checks the 72-stop bound. This avoids claiming that every independent
Candidate-B maximum can coexist within its existing expanded-payload safeguard.

Author verification passed on explicit **iPhone 17 / iOS 26.3.1 Simulator**
(`84E47945-9D2E-446F-8C40-B835A9D15880`): **116 functions / 240 expanded cases**,
zero failures/skips. New focused suite: **31 / 90**. Unchanged required regressions:

| Suite | Functions / expanded cases |
|---|---:|
| InternalSearchScopeTests | 11 / 18 |
| InternalSearchSuccessTests | 13 / 15 |
| TimetableOccurrenceInventoryTests | 18 / 48 |
| TimetableRideContextTests | 10 / 14 |
| RoutingValueTests | 16 / 26 |
| SyntheticTimetableRoutingIntegrationTests | 7 / 16 |
| SyntheticTimetableBatchRoutingIntegrationTests | 6 / 7 |
| SyntheticTimetableOptimalRoutingIntegrationTests | 4 / 6 |
| Regression total | 85 / 150 |

The maximum generated actual production test passed in **2.416 seconds**, including fixture
creation and exact/+1 checks; this is whole Debug Simulator test time, not isolated constructor
or physical-iPhone timing. Standard **Release app and Live Activity extension build passed**
on that explicit Simulator destination; the new declaration is production-compiled with no
DEBUG dependency or attributable new warning. Existing unrelated Domain Codable isolation
warnings remain outside this slice. `git diff --check`, including both new files, passed.
Independent non-author review: **24/24 PASS**, no unresolved findings. A material
cross-date snapshot issue was corrected: a missing required date must still reject a
contradictory loaded snapshot for the same recurring TripID. Its focused regression passed
independently. Fresh independent rerun: **31 functions / 90 expanded cases**, zero failures,
skips or runtime warnings; fresh standard **Release app/extension build passed**, with no
warning attributable to the new files. The independent maximum generated whole test took
**2.182 seconds**, including fixture/+1 checks, not an isolated constructor benchmark.
Both runs used the same explicit iPhone Simulator. No physical-device step was required or run.

**`P3_REQUEST_SCOPED_SEARCH_INPUT_CLOSURE_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`**.
All six implementation/test/documentation files remain unstaged/uncommitted; published HEAD
and upstream remain `f520d5ffe771820fa4e6d8d2b63c58bfe55fd60b` (0/0), main unchanged.
No staging, commit or push was performed. Drift audit matches the bounded §20.5 scope.
Exact next safe action, **not begun**:

> Owner review and publication of the independently approved request-scoped search-input closure values. After publication, separately assess and authorize the smallest invented-only qualified connection/transfer evidence boundary that can resolve the retained connection requirements without changing request-closure semantics or invoking a solver.

Domain,
existing synthetic behavior and runtime composition are unchanged. No real/private artifact,
CLI, IO/network, serialization, persistence/cache, connection payload, candidate, search result,
searcher/solver, AppEnvironment, Journey or UI is included. Production horizon/resource/adoption
policy remains unresolved; this is local coherence under stipulated invented declarations, not
real search qualification, enumeration, fastest/all-tied proof, noResults or P3-T1/Phase 3 exit.

## 21. Qualified connection/transfer evidence boundary audit — 2026-10-10

### 21.1 Scope, publication and Accepted authority

Documentation/architecture audit only, after publication of the exact reviewed request-
closure implementation at `3359f1ca197a07e0e18b8d40751450a8a1608390`
(`feat: add request-scoped search input closure`). §20.6's unstaged/publication-pending statements
record the earlier implementation task. This audit changes no source/test/Domain value,
accesses no real/private artifact or receipt, and runs no search, solver, build or test.

The current acceptance selectors in §20.1 still govern: DEC-076 remains Accepted except
for DEC-079's bounded internal amendment; DEC-078 §§2–4/O1–O6 and DEC-079 consumer
§§2–5/C1–C6 are Accepted. In particular, §5 requires affirmative genuine train change,
directional connectivity, exact original alighting/boarding association, justified total
allowance including every applicable component once, line/service and time applicability,
finite nonnegative values and safe arithmetic. Missing required evidence blocks successful
coverage, even with a usable direct ride. Same station implies neither existence nor zero;
no reverse relation is inferred. DEC-080 selects only §9.9 V1–V7 (P1–P4/P6); DEC-081's
S1–S6 are synthetic-only and do not select production all-pairs requiredness or numbers.
DEC-086's scoped objective/completion/on-iPhone direction and DEC-087's Application
lifetime/retry ownership remain unchanged. Unselected historical proposals stay Proposed.

**`NO_NEW_PRODUCT_DECISION_REQUIRED`**: this recommendation encodes already Accepted
truth without a universal margin, default same-station allowance, accessibility policy,
route preference, degraded success or launch reduction. Type/association choices below
are a technical recommendation for separate implementation authorization, not a new Accepted
product record, a selected real policy or permission to consume real evidence.

### 21.2 Purpose, ownership and the unchanged B seam

Boundary A's only purpose is to represent independently qualified directional passenger
connection evidence for exact occurrence endpoints, allowing separately checked immutable
composition to account for B's existing `SearchInputConnectionTarget` obligations.
Recommend `TSUGINO/Data/Routing/`, beside the production closure; no Domain extension is
needed. Use immutable `nonisolated` Sendable production values without DEBUG dependencies.

The existing target stores from address, original alighting index, to address, original
boarding index and exact applicability reference. The closure constructor checks these targets: both
addresses in the independently required occurrence domain, valid endpoint roles and no
duplicate four-field key. It does not require distinct Trips, prove active usable endpoints,
or authenticate any train-change relation. Every supplied target currently yields
`connectionUnresolved`; every unknown declaration and external dependency remains held.
This audit changes none of that behavior or `isTechnicallyQualified`.

B remains the request-relative requiredness authority under independently supplied qualified
declarations. A cannot derive requiredness from loaded records, routes, winners, calendars,
proximity or pair enumeration. A supplies neither search completeness nor authenticated
source review. No caller-set resolved bit or printable reference is a proof of external truth.

### 21.3 Exact directional identity, anchors and train change

Recommend one relation key with exactly four fields:

`(from TimetableOccurrenceAddress, original alightingIndex, to TimetableOccurrenceAddress, original boardingIndex)`.

This losslessly matches the closure's structural key. Repeated station visits have distinct
indices; direction is significant. The target's applicability reference remains a separately
checked authority association, not an extra physical identity component. Different authority,
policy or generation must fail compatibility rather than create a second version under the
same key in one view. Reject identical duplicates as well as contradictory records; no first
or last wins. No names, provider IDs, station-pair identity or route similarity participate.

Retain exact expected from/to `TimetableOccurrenceBinding` values. Compare full snapshots
with `matches`, including ordered stops, line/service-type segments and coverage; Trip's
ID-only equality is insufficient. Derive canonical station anchors by indexing these checked
snapshots. Do not retain independently relabelable StationIDs; any future redundant projection
must be exactly validated. Endpoint role checks precede indexing.

Positive records explicitly retain `sameStation` or `walking`: the former requires equal
derived anchors and independently qualified interchange evidence; the latter requires distinct
anchors and evidence for that exact pedestrian direction. Neither equality, topology, proximity,
a `WalkingTransfer` constructor nor chronological times establishes either relation.

A positive record requires separately qualified affirmative genuine inter-ride passenger
change for these dated endpoints, with no contradiction to separately established spanning
Trip/through-run continuity. Distinct recurring TripIDs are necessary in this first positive
slice, never sufficient evidence of train change. A proposed positive splitting one Trip is
rejected; an unresolved same-Trip target may instead remain explicitly unsupported. Do not
mint a new ID or infer absence to bypass it. A line/operator change inside one spanning Trip
is one continuous ride when evidenced, never a passenger change. A must not stitch fragments
or reinterpret uncertain continuity as transfer; known contradictory evidence fails closed.

### 21.4 Qualification, policy and applicability

Recommend a finite `QualifiedConnectionEvidenceView` with a supplied immutable qualification
envelope retaining full `SearchInputClosureApplicability` (exact scope/request/full profile,
inclusive bounds, inventory qualification and static revision), a distinct connection review/
evidence reference, and the exact `InternalSearchPolicyReference` selected by the profile.
Each declared key/record carries the exact target applicability reference and its own qualified
evidence association. Preserve separate occurrence-inventory and connection-review authority.

Compare every inventory qualification component, view ID, complete `RailwayArtifactRevision`,
mapping/profile generation, full expected Trip snapshots, policy key/revision, full profile
definition, request fields and bounds. Same IDs/revisions alone do not authenticate contents.
The resolved qualified association must expressly state that this independently reviewed
evidence implements the exact profile connection policy with the allowance/applicability
semantics below. Retaining that assertion/reference is local association, not verifying the
review itself. Conflicting supplied content under identical references is a shared typed
construction/compatibility failure. Changed applicability prevents reuse; no latest lookup,
mutable registry, TTL, universal fallback or hidden policy resolution is introduced.

Select **occurrence-specific applicability**, not a reusable station-pair/time-window policy.
All states bind the exact dated key, full snapshots and qualified declared context scope.
For a positive record additionally retain the exact from-arrival and to-departure instants;
composition requires the same active inventory facts, original indices, exact event quality
and allowed alighting/boarding permissions. Changed scheduled endpoint values prevent reuse.
Missing/estimated events or unknown permissions remain held, never zero or infeasible. A known
prohibition prevents positive use. No device clock, locale/timezone, civil-date inference or
service-label parsing is needed. The positive time association does not compare the train gap.

A qualified absence instead needs explicit negative applicability for the exact dated relation
under the same policy/context, covering all admitted forms, not merely one unavailable path.
It may cover conclusively inactive or missing-event endpoints without fabricating active event
instants only when the negative is expressly qualified for the entire exact occurrence-endpoint
pair independently of event values. A time-dependent negative instead needs a separately reviewed
applicability representation and remains held in this first slice. Its authority must qualify
that negative independently; missing times, inactivity,
missing positive allowance or a sparse-map miss alone never establishes connection absence.
Unavailable records identify the exact held target/generation without claiming time validity.

**Line/service context is endpoint-wide only when independently qualified.** A key does not
contain complete inbound/outbound ridden intervals. The first slice therefore requires an
express reviewed assertion that its one relation and allowance (or negative) apply to every
supported incoming/outgoing ridden interval incident on these original endpoints in these
exact full snapshots under this full profile. This is supplied applicability, never an inference
from TripID, adjacent line segments or station equality. Full line and service-type segments
remain bound; endpoint-adjacent projections can describe context but cannot prove the allowance
is independent of earlier boarding/later alighting or other service restrictions.

If that uniform applicability cannot be established, retain `unsupported` for a context model
outside this narrow representation, or `insufficientEvidence` for an unproved assertion. Do not
choose a worst/fastest/default allowance, broaden one line pair to every service, or introduce
extra ridden intervals/required targets. Supporting context-dependent alternatives later needs
a separately reviewed representation; it is not a new route preference or implicit policy now.

### 21.5 Allowance: components and asserted total

Select **component values plus asserted total**, rather than total only. Total only is smaller
but hides whether alighting/access/boarding were included. Retain precisely three named duration
components: `alighting`, `interchange` (all applicable walk/access/interchange requirements),
`boarding`, plus the independently asserted `total`. The qualification expressly accounts for
each applicable requirement once and partitions access into interchange, avoiding a fourth
ambiguous overlapping component. No default duration is selected. A non-applicable component
still needs qualified zero; absence of a supplied component is insufficient evidence.

All four Double durations must be finite and nonnegative. Reject NaN, either infinity, negative
values, overflow and a non-exact represented component sum. Canonicalize any supplied signed
zero to positive zero before retained equality/accounting; negative zero creates no separate
permission. In fixed order compute exact `alighting + interchange`, then exact `subtotal +
boarding`; require the resulting represented value to equal asserted total exactly, with no
tolerance, rounding, saturation or implicit unit conversion. Use seconds explicitly.

Recommend a small production-local checked-addition rule using error-free TwoSum residuals:
require finite operands, sum, intermediate terms and residual, and residual exactly zero for
each addition. `SyntheticInternalArithmetic.exactSum` and `InternalSearchScope` provide existing
arithmetic references, not production dependencies on DEBUG types. Independently implement/test
only the required exact-addition primitive; do not refactor the synthetic engine in this slice.
Finite nonnegative operands alone do not prove exactness. Reject unrepresentable sums atomically.

Exact arithmetic detects inconsistent totals; it cannot prove semantic component inclusion or
that a source did not double-count. Independent qualification must justify that partition as
well. A numerically matching but known double-counted allowance is contradictory evidence and
must not be admitted as qualified. **Zero total is representable only with affirmative qualified
zero for the complete exact relation and all components.** Same station, identical times,
missing walk duration or missing allowance never supplies zero.

### 21.6 States and independent evidence completeness

Recommend `present(qualified relation/form/allowance/applicability)`, explicit qualified
`absent`, and `unavailable(unsupported | insufficientEvidence)`. A present state retains
affirmative genuine-change and directional-relation evidence associations. An absent state
retains affirmative scoped negative authority, without invented positive form/allowance.
Unavailable retains the reason and target but no asserted resolved relation. No separate
unknown record is needed: unknown declaration completeness and unrepresented keys preserve
unknown/not-loaded; insufficient evidence preserves an examined but unresolved record.

Declare an independent finite ordered key scope, qualification and `declaredComplete | unknown`,
with exactly one explicit state per declared key. Reject undeclared records, missing declared
slots and duplicate/conflicting keys as structural defects. Complete means only this explicitly
declared directional evidence scope under exact qualified authority, never Tokyo, every request,
or search completeness. Matching B's target set cannot manufacture independent evidence scope
or its completeness proof. An unrepresented key remains not loaded even when another scope is
complete. **No absence by omission** is selected. Explicit absence closes a target only under
compatible qualified declared-complete negative scope; an absence assertion under unknown
completeness remains held as insufficient negative coverage. Positively qualified records may
resolve their exact obligations under an otherwise unknown scope; no missing obligations close.
Complete-empty and unknown-empty remain distinct values; neither invents B's required domain.

### 21.7 Immutable composition and accounting

Select **Pattern 2**, an immutable derived `ResolvedSearchInputAssessment` wrapper retaining
the original closure, exact connection view, declaration-order per-target accounting and
derived remaining holds. It supplies only a pure local assessment, not a runtime resolver.
The original closure, its holds and `isTechnicallyQualified` remain unchanged. No initializer
extension or in-place mutation is required. This wrapper alone never authorizes route search.

For the first slice require exact four-field target-set association between the view's declared
keys and the closure's supplied connection targets, and exact applicability references. Reject
extra or missing keys instead of silently filtering. This is a checked composition requirement,
not A determining requiredness: a standalone A view may represent its own finite scope, but
cannot change B's requirements. A missing exact view must remain unresolved; it is never negative.
Record order may differ; keyed comparison and output in B's declaration order avoid pair scans.

| Evidence for a retained target | Derived accounting / qualification effect |
|---|---|
| Compatible qualified positive, usable exact endpoint facts/permissions | `present`; remove only that target's connection hold; relation/allowance evidence resolved, no train-gap verdict |
| Compatible explicit qualified absence in complete exact negative scope | `absentUnderCompleteAuthority`; remove only that target's connection hold; relation unusable by a future route |
| Unsupported / insufficient evidence; positive missing exact event or permission; absence under unknown scope | Distinct held accounting/reason; retain the matching connection hold |
| No represented key / wrong exact target set | Typed association failure, or absence of composition leaving the original unresolved closure; never inferred absence |
| Incompatible view/static/policy/snapshot/context or contradictory evidence | Atomic typed compatibility/construction failure; no partial assessment |

Preserve every occurrence/interval hold, `occurrenceDomainUnknown`, `connectionDomainUnknown`
and external dependency hold. Resolving all supplied target records cannot remove unknown
required-domain authority. Derive any wrapper technical-qualification predicate from remaining
holds after exact compatibility, never from a caller success flag or presence of one direct
ride. Preserve known negatives separately from held/unknown and deterministic reason ordering.
No new aggregate failure precedence or Domain error/result is introduced.

### 21.8 Feasibility and product exclusions

Positive evidence resolves relation existence and applicable allowance only. Actual comparison
`nextDeparture - previousArrival >= totalAllowance` belongs to later separately authorized
schedule admission/solver consumption with exact safe arithmetic. Do not implement a gap helper
in the first evidence/assessment slice. A known short gap later means `infeasibleConnection`;
qualified relation absence is a known negative; unknown relation/allowance is missing required
evidence; incompatible shared input is a data failure. Do not collapse those into infeasible.
DEC-079 chronology/admission and existing failure/cancellation precedence remain unchanged.

Topology, canonical station equality, proximity or a chronological gap supplies no transfer
capability. Routing total allowance is not user-facing walking time: it includes alighting,
all applicable interchange/walk/access and boarding. Exclude all Phase-10 car/door/exit-side,
path geometry, gates, facilities, accessibility guidance and presentation-confidence fields.
No RouteCandidate, RouteSearchResult/Failure, route enumeration, ranking, optimum/all-tie proof,
noResults, search invocation, Application/AppEnvironment/Journey/UI wiring or runtime adoption.

### 21.9 Finite safeguards and exact next implementation slice

**`NUMERIC_CONNECTION_EVIDENCE_LIMITS_REQUIRE_IMPLEMENTATION_EVIDENCE`** for new dimensions:
declared relation/record count, qualification/evidence references, bound full snapshots,
line/service applicability associations, dated applicability/event records, separately retained
scope/profile copies, component/total payload, assessment slots and expanded logical bytes.
Preflight top-level counts before traversal, bounded actual text/nested content before hashing
or full comparisons, and overflow-safe logical accounting will be required. Use keyed lookups
and avoid context-pair expansion or pairwise full-snapshot scans. Existing B bounds constrain
B only; neither its target ceiling nor synthetic fixture caps automatically sizes A's heavier
payload. Generate invented representation/construction evidence before selecting new numeric
limits, including exact-limit/+1 tests. No new numbers are selected in this audit; no product
horizon, memory guarantee, solver capacity or launch quota follows.

Primary classification: **`P3_QUALIFIED_CONNECTION_TRANSFER_EVIDENCE_VALUES_NEXT`**.
The smallest separately authorized implementation is pure production Data values: exact key/
qualification/bindings, explicit form, qualified components/total, occurrence-specific endpoint-
wide applicability, explicit states/completeness, finite checked construction, and the immutable
assessment wrapper above. Use invented focused tests only. No IO, file access, source parser,
network, database, persistence/serialization/cache, runtime resolver or real qualification.
No source/test change is made by this audit. Real connection review and all rights/delivery/
adoption gates remain separately authorized prerequisites. Broader status remains
`P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`, Phase 3 **In Progress**, live/default
routing unconfigured; production horizon/resource policy and solver/adoption ownership unresolved.

### 21.10 Invented future verification matrix — not executed

| Group | Required invented cases |
|---|---|
| Direction/forms | Positive directional walking; reverse absent/not inferred; same-station needs affirmative evidence and never implies zero; wrong derived anchor/form rejects |
| Train change | Distinct TripIDs without change authority hold; same-Trip splitting rejects; line/operator changes do not imply transfer; known through-continuity contradiction fails |
| Allowance | Qualified all-component zero accepted; negative/NaN/infinities reject; signed zero canonicalized; exact component sum accepted; mismatch/rounded/overflow sum rejects; missing or known double-counted qualification cannot pass even with matching numbers |
| Compatibility | Wrong view, full static revision, policy revision, full profile, request/bounds, inventory qualification, target address/original index, full snapshot, authority reference or evidence generation rejects |
| Applicability | Changed endpoint instants reject; missing/estimated event and unknown permission hold; prohibited role rejects positive use; wrong line/service scope or unproved endpoint-wide uniformity holds; negative dated scope without active events is explicit, never inferred |
| States/scope | Qualified absence distinct from unknown/unloaded/unavailable; unsupported distinct from insufficient evidence; complete-empty versus unknown-empty; absence under unknown scope holds; duplicates and contradictory same key reject; omitted declared slot rejects; complete scope does not infer omitted keys absent |
| Composition | One unresolved B target becomes positive or qualified negative only with matching evidence; unavailable retains hold; direct usable ride cannot bypass unresolved relation; extra evidence cannot invent requiredness; missing key fails; unknown domain/occurrence/interval/external holds survive; original closure unchanged |
| Boundaries/resources | No guidance/search/candidate/result/gap helper/DEBUG dependency; no IO/runtime integration; evidence-backed exact-bound/+1 and logical overflow/preflight tests; production compilation and nonisolated Sendable use |

Tests/builds are intentionally not run in this documentation-only task. Independent non-author
review: **18/18 PASS, zero unresolved material findings**. It covered the unchanged closure seam,
requiredness/direction/forms, allowance inclusion/zero, exact target/context/time/policy association,
negative/unknown distinctions, immutable composition, separate feasibility, Phase-10/search/privacy
exclusions and the bounded next slice. Review also confirmed the genuine-change/through-service
boundary. A minor wording clarification attributes target validation to the closure constructor,
not the target's memberwise initializer. Historical text is preserved; the new diff introduces
no real railway identifiers, private paths, artifact hashes, occurrence times or view UUIDs.

Exact next safe action, **not begun**:

> Separately authorize the smallest invented-only production Data qualified connection/transfer evidence values and immutable request-closure assessment defined in §21, with focused tests and evidence-backed finite construction safeguards. Preserve the original closure's requiredness, exact compatibility, known-negative/unknown distinctions and fail-closed holds. Do not access real/private data, evaluate train-gap feasibility, invoke a solver/search or wire runtime behavior in that task.

### 21.11 Invented-only Boundary-A implementation — 2026-10-10

The owner separately authorized §21's bounded Data slice at published baseline
`2ee3bdfdf4da7a221bcf637114d62dadeaf8426b`. §21.9's classification and not-begun next
action above describe the preceding audit. Production source:
`TSUGINO/Data/Routing/QualifiedConnectionEvidence.swift`; focused invented tests:
`TSUGINOTests/QualifiedConnectionEvidenceTests.swift`. Domain, the existing B source/tests,
synthetic behavior, AppEnvironment and all runtime code remain unchanged.

#### Values, qualification and local assessment

`ConnectionRelationKey` contains exactly the from/to dated occurrence addresses and original
alighting/boarding indices, with directional Hashable equality compatible with B. Each supplied
record retains both full expected bindings, target applicability and exact connection-review
association. The view validates original endpoint roles before indexing, derives stations from
snapshots, and checks explicit same-station/walking form. Every record, including unavailable
and absent, participates in keyed recurring-Trip full-snapshot consistency across dates.
Distinct recurring Trips are necessary for positives, never sufficient train-change evidence.

The qualification envelope retains full `SearchInputClosureApplicability`, exact profile policy
and separate connection review. Its existing applicability constructor bounds all profile/request/
inventory/static copies. Positive payloads retain relation, genuine-change, components-once and
endpoint-wide context references, exact from-arrival/to-departure instants, form and allowance.
Private payload construction through checked factories requires every supplied affirmative premise.
`ConnectionEvidencePremise` distinguishes qualified reference, unsupported, insufficient evidence
and contradiction without a verified Bool. Any known contradiction throws a finite typed error,
even if another premise is missing. Otherwise unsupported dominates insufficient evidence in this
local premise summary; it is not Domain/global failure precedence. Unknown/unsupported context
creates an explicit unavailable state, never guessed line-pair allowances or transfer truth.
The references express stipulated qualification only; local construction authenticates no review.

Positive genuine-change qualification cannot be replaced by line/operator metadata or distinct
IDs. Known through-continuity contradiction throws `trainChangeConflict`; same-Trip positives
reject in the view. Known omitted/double-counted component qualification throws `allowanceConflict`
even when numerical totals match. Missing premises produce unavailable evidence rather than a
qualified positive. No stitching, through-Trip splitting or automatic relation inference exists.

`ConnectionAllowance` retains alighting/interchange/boarding plus asserted total in seconds;
interchange's qualified partition includes all applicable walk/access requirements once.
Construction rejects nonfinite/negative fields, nonzero TwoSum residual at either fixed-order
addition, overflow and total mismatch. All signed zero fields retain positive zero. Affirmative
component/relation qualification remains mandatory for zero. Arithmetic validates numbers only,
not semantic partition or source authenticity; no implicit component or default allowance exists.

Explicit qualified negative payloads retain endpoint-wide context and event-independent negative
authority for the entire exact dated pair. Time-dependent negatives are unsupported in this slice.
Present/absent/unavailable remain distinct. The view retains independent ordered declared keys,
complete/unknown authority, one record per key and expanded logical accounting. Missing/extra/
duplicate/contradictory membership rejects atomically, without deduplication or absence by omission.
Complete-empty and unknown-empty stay distinct; neither determines B's required domain.

`ResolvedSearchInputAssessment` retains the original B closure and A view unchanged. Full scope,
request, profile, policy, view, inventory/static qualification and target authority must match;
exact four-field key sets must be equal, regardless of record order. Every A binding compares
deeply with B's independently expected binding, even when the required date is unloaded or the
record is absent/unavailable. No TripID-only shortcut or silent extra evidence filtering exists.

Per-target accounting follows B order. Positives require two loaded active endpoints, allowed
roles, exact events and equal retained instants. Missing/estimated events, unknown permission,
unloaded/inactive/unavailable slots retain explicit distinct held reasons. Known prohibited
permission throws `endpointConflict`; changed exact event throws `applicabilityConflict`. Both
endpoints are checked so one held endpoint cannot hide a known contradiction at the other.
Explicit absence resolves negatively only under compatible complete negative authority; unknown
scope keeps a negative-coverage hold. Resolution removes only that indexed connection hold.
All other connection, occurrence/interval, unknown-domain and external dependency holds survive
in original order. The wrapper's predicate is derived from remaining holds, never caller-set.
This is local input accounting only, not completed search, route feasibility or adoption.

#### Generated invented limits and accounting

Before fixing A-specific constants, an optimized standalone Swift representation study generated
256 / 512 / 1,024 / 2,048 / 2,560 unique directional keys. Each relation retained two independently
generated 72-stop/71-line/71-service-segment snapshot representations, six long reference strings,
allowance/event values and keyed reverse-order assessment lookup. It checked full representative
array equality and charged expanded text/payload. Five iterations per size measured fastest
586.266 / 743.843 / 1,274.633 / 3,077.254 / 3,327.090 milliseconds, including fixture creation.
Model logical bytes were 23,065,600 / 46,131,200 / 92,262,400 / 184,524,800 / 230,656,000.
This is a representation/construction study, not the actual production constructor, solver,
heap profile or iPhone measurement. Only invented strings and values were used.

Select 2,048 relations as the initial measured construction shape; the 2,560 stress shape is
25% larger and supplies measured headroom without authorizing that larger production count.
The actual production maximum fixture exercises both 72-stop full snapshots with 71 line and
71 service segments, actual 192-byte spellings, all 2,048 positive records and assessment.
This independently sizes A's heavier records rather than inheriting B's 23,040 target limit.

| Safeguard | Bound / ownership |
|---|---:|
| Declared keys / records / assessment targets | 2,048 each; count preflight before nested work |
| Retained full binding copies | At most 4,096; exactly two per record |
| Record association reference copies | At most 12,288; at most six per positive record |
| Endpoint-wide associations / positive event records | At most 2,048 / 4,096, fixed state fields |
| Stops / line segments / service segments per snapshot | 72 / 71 / 71, inherited Candidate-B bound |
| Actual retained textual spelling / static input entries | 192 UTF-8 bytes / 32, existing bounds unchanged |
| View expanded logical payload | 215,125,456 bytes |
| Assessment expanded logical payload | 566,451,856 bytes, includes retained B and A |

The envelope charges each declared and record key separately (880 bytes each), two full bindings
(47,456 each), two common references (208 each), positive state (64 plus four references),
32 record overhead and qualification/application scope copies. A record's maximum is 98,016.
View cap = 64 + qualification envelope 14,388,624 + 2,048 × 98,016. Qualification uses the existing
full profile maximum (34,560 stations / 34,080 lines / 480 Trips), complete inventory/static
qualification and separate applicability/review references, without implicit shared storage.
Assessment adds B's 347,370,560 envelope, A, 64 fixed, 64 per target and 32 per possible retained
original hold (conservative 119,522 slots from existing B dimensions). This is expanded logical
accounting, not measured heap/COW allocation or a promised iPhone budget.

Actual raw spellings of keys and both binding copies are bounded and charged before hashing or
full snapshot equality, including canonically equivalent Unicode spellings. Existing constructed
applicability/reference types already enforce their own bounds. Overflow-safe subtraction guards
prevent budget wrap. Exact/+1 tests cover keys, records, assessment targets, stops/text and logical
budget primitives; hostile excessive top-level count rejects before nested invalid snapshots.
No truncation, partial result, new production horizon or solver-capacity policy is introduced.

Expected keyed work is O(N×S + P) for view/qualification construction and
O(I + R + N×S + P + H) for assessment: N relations, S≤72 snapshot size, P full profile members,
I loaded inventory slots, R independently required occurrences and H existing holds. No pairwise
record comparison, context-pair Cartesian expansion, path/route generation or weakened equality.

#### Verification and handoff

Author verification passed on explicit iPhone 17 Simulator (iOS 26.3.1): the new suite has
**42 functions / 122 expanded cases**; the nine required unchanged regression suites have
**116 functions / 240 expanded cases**. The combined run is **158 functions / 362 cases**,
zero failures/skips/runtime warnings. Regression breakdown (functions/cases): closure 31/90,
inventory 18/48, scope 11/18, success 13/15, ride context 10/14, routing values 16/26,
synthetic routing 7/16, batch 6/7 and optimal 4/6. The maximum generated actual view/assessment
test, including fixture generation and +1 checks, took 0.986 seconds on the host Simulator;
this is no physical-device performance claim. Standard **Release app and Live Activity extension
build passed**, including production source compilation without a DEBUG dependency. No warning
is attributable to the new files; existing Domain Codable isolation, AppIcon asset and
AppIntents metadata-extraction warnings remain outside this task. `git diff --check` and explicit
new-file whitespace checks passed.

Independent non-author review: **30/30 PASS, zero unresolved material findings**. The reviewer
checked requiredness ownership, directional full bindings/derived anchors, form/genuine-change/
through-service rules, qualification and every evidence/completeness state, exact arithmetic/zero/
semantic partition, dated events/endpoint-wide context, immutable exact-set assessment and indexed
hold preservation, resource evidence/boundaries/complexity and all privacy/runtime exclusions.
Fresh independent focused Debug verification passed **42 functions / 122 expanded cases**, zero
failures/skips/runtime warnings. Fresh standard **Release app/Live Activity extension build passed**,
including extension embedding/validation, with no new-file diagnostic. The reviewer independently
read the author combined result and confirmed the separate **116/240** unchanged regressions.
The independent maximum generated whole test took 0.905 seconds on the same explicit iPhone 17
Simulator; reruns are not added to coverage totals. Reviewed source/test bytes were unchanged.

Task verdict:
`P3_QUALIFIED_CONNECTION_TRANSFER_EVIDENCE_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`.
This verdict covers this invented-only value/assessment slice; it accepts no real connection
evidence, resolves no real request and establishes no production search readiness.

This implementation is invented-only: no real/private
artifact, source parser, IO/network, serialization/persistence/cache, Phase-10 guidance, candidate/
result/search/solver, train-gap helper or runtime integration was accessed, added or invoked.
An explicit regression uses short and long invented schedules with the same qualified allowance;
both resolve evidence, proving that no schedule-gap feasibility comparison is owned here.

All implementation/test/docs files remain unstaged/uncommitted for owner publication review;
published HEAD/upstream remain `2ee3bdfdf4da7a221bcf637114d62dadeaf8426b` (0/0), main unchanged.
Broader `P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`, Phase 3 **In Progress**,
unconfigured live/default routing and unresolved horizon/resource/solver-adoption ownership remain.

Exact next safe action after independent approval, **not begun**:

> Owner review and publication of the independently approved qualified connection/transfer evidence values and immutable assessment. After publication, separately assess the smallest complete pre-solver input-composition step that combines a technically qualified request closure with compatible qualified connection evidence, while still excluding route enumeration and train-gap feasibility until those execution responsibilities are separately authorized.

## 22. Final immutable pre-solver input boundary audit — 2026-10-10

### 22.1 Published truth, authority and remaining gap

Publication `6f826fe175ce9ec4d0f5fa5c8293c17223e96667` contains the exact independently
approved six-file evidence/assessment implementation. Current production values are:

`TimetableOccurrenceInventoryView` → `RequestScopedSearchInputClosure` (B) plus
independent `QualifiedConnectionEvidenceView` (A) → `ResolvedSearchInputAssessment`.
Neither A's declaration nor loaded inventory membership defines B's required targets.
The source's actual allowance type is `ConnectionAllowance`; a qualified allowance name in
planning notation does not identify another production declaration.

Current Accepted selectors remain §20.1: DEC-076 except DEC-079's bounded internal
supersession; DEC-078 §§2–4/O1–O6; DEC-079 §§2–5/C1–C6; DEC-080 §9.9 V1–V7 for
P1–P4/P6 only; DEC-081 S1–S6 synthetic-only; DEC-086's scoped objective/completion and
on-iPhone preference; DEC-087's Application lifecycle/retry. Historical production
all-distinct P5 and unselected R6 details are not adopted. This audit recommends technical
composition under those constraints; it does not amend an Accepted decision or implement it.

`assessment.isTechnicallyQualified == true` means no original B hold remains after exact
A/B accounting: required occurrences/intervals and directional connections are locally
accounted for, including qualified negatives, and implemented compatibility checks passed.
It authenticates neither supplied review nor real requiredness/completeness. B's active
interval `.present` records qualified interval membership; it does **not** validate that
ride's endpoint eligibility, exact time quality or inclusive scope bounds. A's positive
endpoint checks cover connection endpoints only, not every required ride endpoint.

| Remaining responsibility | Proposed owner / truth still required |
|---|---|
| Evidence/input closure | Retained B/A assessment, under independently qualified declarations; never derived from routes |
| Operational ride projection | Final pure preparation validates required positive active interval usability and constructs existing ride values |
| Connection temporal feasibility | Same preparation evaluates every required positive relation once with exact events and allowance |
| Objective/completion binding | Immutable fixed Accepted DEC-086 definition/version attached to prepared input |
| Execution configuration | Later solver invocation supplies explicit work/memory/cutoff/checkpoint policy; Application selects runtime profile/configuration |
| Enumeration/completion | Future solver proves optimum and all equal optima, reconstructs/admit winners and finalizes results |

Current values also contain no canonical endpoint status/network entity view or adopted runtime
configuration. DEC-076 current-existence/retirement/support checks, DEC-079 preflight and
DEC-080 immutable policy resolution still need the authorized coherent runtime environment.
Pure invented preparation can be implemented under stipulated qualified premises without
claiming those real runtime gates discharged. Technical input readiness is not authorization
to enumerate real data or adoption of a production solver.

### 22.2 Ride materialization and explicit exclusions

Recommend one immutable `PreparedTimetableRide` per **positively usable B-required active
interval**, identified by exact occurrence address and original boarding/alighting indices.
Traverse B's declarations/accounting in retained order; no all-index-pairs enumeration or
additional intervals inferred from Trip shape. Use indexed inventory lookup and full binding
association. Require affirmative qualified whole-interval correspondence/continuity from the
retained positive interval authority; the reference alone authenticates no real review.

Reuse `TrainCandidate(trip:boardingIndex:alightingIndex:)` and
`TimetableRideContext(train:facts:)`. The token retains those actual immutable values;
context already retains full binding/address/snapshot and original indices. Derive anchors,
movement-bearing line sequence and exact departure/arrival through them rather than retain
independently relabelable copies. Retain exact scope/assessment association in the enclosing
input, with an exact ride key for lookups. `TimetableRideContext` checks full snapshot/time
association and chronology, but does not check eligibility or scope; preparation must do so.

| Required interval state/use | Preparation treatment |
|---|---|
| Inactive occurrence | No token; retain original known-negative provenance |
| Interval absent under complete authority | No token; retain exact negative interval accounting |
| Positive active interval, known prohibited boarding/alighting | Known endpoint-use exclusion, no token; not missing evidence |
| Positive active interval, allowed endpoints and exact events outside supplied [L,U] | Known scoped exclusion, no token; no adaptive horizon |
| Remaining potentially usable positive interval, unknown permission or missing/estimated required event | Refuse whole preparation, no partial usable subset; required evidence is unavailable |
| Positive active interval, allowed/exact in-scope endpoints and compatible canonical constructors | Retain one exact token |
| Inconsistent association, contradictory chronology/continuity or constructor failure | Refuse preparation as a typed local consistency failure; never silently drop a defect |

Known prohibited boarding **or** alighting conclusively excludes that interval before requiring
unused event values or another unknown permission. For remaining potentially usable intervals,
require both permissions allowed, then both exact constructible events, then inclusive scope
membership. Unknown permission or missing/estimated event at that stage refuses preparation;
one known out-of-scope timestamp cannot hide another unknown endpoint. This local projection
sequencing follows the existing eligibility reference, not new global failure precedence.
No excluded interval becomes an extra negative source assertion. Retain original assessment
plus finite per-required-interval preparation accounting so absence from token arrays is never
interpreted as unknown or newly inferred interval absence. The existing B/A values are unchanged.

One evidenced spanning Trip produces one ride token for each supplied usable interval, including
multi-Line/through service. A line/operator boundary within the ride adds zero train changes.
A complete itinerary later counts genuine transitions across distinct rides, rail rides minus
one; existing duplicate recurring TripID restrictions still apply even across dates. Do not
merge fragments, deduplicate tokens by stations/times or select a train/Journey.

### 22.3 Single connection feasibility owner and arithmetic

Select **Option A: final pure pre-solver preparation owns feasibility projection**. Option B
would repeat the predicate in each expansion/algorithm; Option C adds a separate public value
boundary without independent truth needed here. Keep a small production-local pure arithmetic
helper, not another stage, and evaluate each exact B-required positive relation once.
This is a future separately authorized responsibility; published A/assessment remains evidence-only.

The relation key has endpoint addresses/indices, not whole incoming/outgoing ride intervals.
Retain one ordered/keyed prepared relation per B target, with `.feasible` or `.infeasible` for
qualified positives and `.absentUnderCompleteAuthority` for qualified negatives. Positive
payload retains the original form/allowance/events/context association through the assessment;
store checked associations rather than caller-authored replacements. Endpoint-wide qualification
permits reuse across supported incident intervals; it never manufactures those intervals.
Optional endpoint-to-ride incidence indexes may group existing tokens, but do not materialize
a Cartesian product of ride pairs or adopt synthetic all-potential-pair requiredness.

The solver may traverse only a feasible relation between two existing incident ride tokens with
matching exact endpoint keys, plus its normal path constraints. Known absence and known
infeasibility supply no usable edge. A required relation may have no usable incident token;
retain its accounting without inventing a ride or dropping the target. Unavailable/held
assessment cannot enter this stage. Positive-but-too-short is **infeasible**, never absent,
unsupported or insufficient evidence. `infeasibleConnection` remains a later candidate-admission
rejection if an unexpected contradictory handed-off proposal reaches that boundary, not a public
preparation failure or a search result.

Normative feasibility: exact finite represented arrival `a`, departure `d`, and finite
nonnegative qualified total `t`; permit iff **d ≥ the exact mathematical sum a+t**. Equality
is permitted. No time conversion, display rounding, epsilon, saturation or subtract-and-round
alternative. Use absolute elapsed seconds from existing exact instants; never parse day labels.

Future arithmetic design: one production-local TwoSum primitive may serve two separately named
policies. Allowance component addition requires zero residual and exact asserted total, as today.
Feasibility must **not** reject a nonzero residual as missing/invalid evidence: retain rounded
sum `s` and exact residual `e` representing a+t. For finite `s`, d<s is infeasible, d>s feasible,
and d==s feasible iff e≤0. Thus equality with a rounded-down threshold fails, while equality
with a rounded-up threshold passes. Positive overflow is known infeasible for every finite d;
handle it before residual operations. Unexpected nonfinite residual/intermediate under otherwise
valid finite inputs is a typed arithmetic consistency failure, never guessed feasibility.
This corrects representation error rather than rounding the decision. Reuse no DEBUG helper;
any minimal future extraction must preserve existing allowance behavior/tests exactly.

### 22.4 Final immutable input and objective binding

Recommend one production Data/Routing `PreparedInternalSearchInput`, immutable/nonisolated/
Sendable, constructed atomically only from a technically qualified assessment and the fixed
supported objective definition. No caller-set readiness/completion Bool or partial/degraded
preparation. Retain the **whole original assessment**, exact supplied scope (prefer a derived
projection), ordered/keyed usable ride tokens, per-required-interval preparation accounting,
all required prepared relation accounting and immutable objective definition/version.
The assessment retains all negative/requiredness/static/view/profile/policy provenance; do not
copy selected fields into a second closure or optimize it away based on COW assumptions.
Its size and any additional actual retained copies must be measured/accounted before implementation.

`InternalRouteObjectiveDefinition` is conceptual notation for a closed supported version/shape:
exact final arrival then genuine train changes, all identity-distinct equal optima, deterministic
identity ordering solely for reproducibility, optimum/all-tie proof before success, no first-found/
first-K, cutoff before proof/completion → searchIncomplete, unknown required evidence →
dataUnavailable, select before frozen handoffs and preserve every admitted winner. Defensive
mixed-winner rejection remains searchIncomplete; all rejected remains the existing unscoped
noUsableAlternatives accounting. Binding specifies obligations, not an execution certificate.
Validate full definition plus version/reference; identity-only equality or mutable latest lookup
must not authorize reuse. A changed definition/reference prevents prepared-input reuse. No fare,
departure, comfort, walking-distance or other preference is introduced.

**`NO_NEW_PRODUCT_DECISION_REQUIRED`** for this representation of already Accepted DEC-086.
The exact itinerary-key representation and UUID/unsigned-UTF8/index/form/shorter-prefix comparator
in **§10.2 remain explicitly Proposed**, including its detailed dedup/order mechanics. Existing
DEBUG implementations are reference oracles, not production acceptance of that comparator.
Bind the Accepted requirement `reproducibilityOnly`, not an unapproved concrete comparator.
Input preparation creates no itinerary keys or compares winners, so this does not block its
invented value slice. Later solver design must explicitly settle/review exact identity/equality/
dedup/order mechanics before execution, preserving every distinct equal optimum. A change to
which optima survive or any extra user preference would require owner decision; none is selected.

The input contains no paths, frontier, discovered candidates, winners, results, result accounting,
execution certificate, cache or mutable runtime state. It is independent of Dijkstra/A*/DFS or
another algorithm. Refer to successful construction as **prepared input qualification**, and
future completed optimum/tie proof as **execution completion**; never a bare pre-solver `complete`.

### 22.5 Materialized policies, execution configuration and admission

| Policy/reference | Consumption recommendation and remaining obligation |
|---|---|
| Connection policy | Exact relation/form/components/total and endpoint-wide applicability are materialized in A under this reference; preparation uses them, solver need not reinterpret raw policy definitions |
| Service-date interpretation | Producer/inventory already supply exact absolute events and dated membership; preparation/solver do not reconvert clocks or enumerate/parse day labels |
| Objective policy | Current profile lacks it; final input newly binds the fixed Accepted operational definition/version above |

This avoids duplicate policy interpretation, **not** DEC-080 V2 resolution. Before actual runtime
use, definitions must still resolve immutably in the retained view, with Data retaining evidence
and the relevant typed constraint descriptions available to the future Application consumer for
search/consumption/revalidation. Pure values and opaque references authenticate none of that.
Qualified immutable upstream materialization supplies the stipulated operational semantics here;
real resolution/authentication/lifetime configuration remains an adoption gate. Objective is the
only newly represented operational policy needed by this slice, not the only remaining runtime gate.

Require `assessment.isTechnicallyQualified` including zero dependency holds; no degraded fallback.
Reuse supplied full `InternalSearchScope` unchanged, inclusive [L,U], maximumElapsedDuration and
maximumRailRides. Select no production default, narrower launch domain or adjusted horizon.
Launch profile/default selection can remain unresolved without blocking pure invented values.

Keep work/memory/cutoff/checkpoint configuration **outside evidence/prepared input**, explicitly
supplied per future solver invocation through immutable execution configuration. Application
selects the runtime profile/configuration and owns task lifetime, cancellation/publication guards
and retry intent under DEC-087. The Data solver observes cancellation/checkpoints and owns one
request's work accounting across preparation, optimization, tie collection, admission/finalization;
no reset hides preparation cost. This audit selects no numbers, scheduling actor or concrete solver.

Proposed layering: Data qualifies inputs/prepares rides and exact relation feasibility; a future
production component behind `RouteSearching` performs request-local enumeration/optimization,
sound pruning, cutoff accounting and canonical reconstruction/admission/finalization. Domain keeps
canonical invariants; Application keeps lifecycle; UI has no route computation. These are bounded
architecture recommendations, not acceptance of all DEC-086 R6 or live AppEnvironment wiring.

Prefer **not** constructing `RouteRailProposal` per token. Once a complete itinerary has been
proved selected, reconstruct matched proposals with retained `TrainCandidate`+`TimetableRideContext`,
directional `WalkingTransfer` only for walking form, then `RouteCandidate` and scoped success
through existing production constructors/admission. Same-station change needs no walking leg.
No Phase-10 path/gate/car/door guidance or user-facing walking-time claim follows from allowance.
Exploration may use compact derived associations but cannot bypass the canonical final validators
for full bindings/indices, chronology, candidate structure, scope and duplicate TripIDs. Connection
feasibility has the single preparation predicate; final admission checks/reuses that qualified
association, not a competing gap formula.

Prepared input readiness is independent of algorithm choice. Later solver correctness must prove
all relevant feasible paths considered or soundly bounded, no better route left, every equal optimum
retained, safe pruning/dedup, cycles/repeated stations, used-Trip constraints and honest cutoff.
Zero usable rides or zero feasible connections is valid prepared state, **never noResults**.
Only completed scoped execution with complete qualified inputs and zero handoffs may emit noResults.
A prepared direct ride establishes no optimality; all supported feasible transfer alternatives
remain part of future proof. No constructor or readiness predicate certifies execution completion.

### 22.6 Safeguards, real pilot and selected next slice

Structurally, prepared tokens cannot exceed B's required intervals (existing total ceiling
92,160), relation accounting cannot exceed A/assessment targets (2,048), and occurrence/interval
ledgers and incidence entries derive from their existing bounded declarations. These are upper
envelopes, **not** selected practical preparation capacity or solver work limits. Fixed objective
shape/version and inherited bounded references need finite accounting; retaining the whole
assessment plus train/context snapshot copies/projections requires new expanded logical accounting.
Top-level counts, actual text and nested payload must be bounded before hashing/deep work;
overflow/limit failure must be atomic without truncation or partial preparation.

**`NUMERIC_PRE_SOLVER_INPUT_LIMITS_REQUIRE_IMPLEMENTATION_EVIDENCE`**. Measure generated invented
ride/relation/ledger/objective/provenance workloads before choosing new numeric payload/count caps;
derive bounds only where structural reasoning is sufficient. Do not copy synthetic work limits,
assume shared snapshots are free or treat B/A maxima as an iPhone memory promise. Resource safeguards
are technical implementation choices, not new product decisions or production horizon defaults.

Prior real milestones establish one real Trip, dated facts, direct canonical admission and
occurrence inventory only. B/A closure/evidence/assessment has invented-only production values;
there is no real request-scoped resolved assessment. Prefer invented prepared-input implementation
first, then a separately authorized bounded real direct/no-connection pilot with independently
complete-empty connection authority, or a separately evidenced connection pilot as applicable.
Neither pilot nor source discovery is authorized here. Runtime rights/delivery/configuration and
real coverage remain separate; this audit reopens no artifact or private receipt.

Primary next-task classification: **`P3_PRE_SOLVER_EXECUTABLE_INPUT_VALUES_NEXT`**.
Alternative separate gap/objective slices are unnecessary because one pure composition owns both
projections without another independent evidence boundary. Production solver design is later;
no new product semantic decision blocks this invented input-only slice. Type names/file layout
are routine technical choices. No prepared-input implementation is included in this audit.

### 22.7 Future invented verification matrix — not executed

| Area | Required future verification |
|---|---|
| Readiness/provenance | Technically qualified assessment required; any hold rejects; original assessment/scope/full compatibility retained; dependency hold cannot bypass preparation |
| Ride positives/negatives | Active exact allowed interval → token; inactive/complete-absent → no token with provenance; prohibited endpoint excludes before unused unknown events/permission; remaining unknown permission/missing/estimated required events reject; exact outside-scope pair is a known exclusion |
| Canonical reuse | Exact TrainCandidate and TimetableRideContext preserved; full snapshot/address association; repeated original indices; through multi-Line interval remains one ride; no fragment stitching |
| Connections | Same-station/walking preserved; exact positive allowance/context retained; qualified absence has no usable edge; known infeasible differs from absent/unavailable; no reverse inference or ride-pair Cartesian expansion |
| Arithmetic | Gap equal/greater/smaller than allowance; positive overflow; rounded-down/up equality residual signs, nonzero residual and zero allowance; exact represented decisions without tolerance or time conversion; production helper only |
| Objective | Exact Accepted DEC-086 version/full definition, changed definition/reference rejects reuse; no Proposed §10.2 comparator silently adopted or extra preference |
| Result exclusions | Zero tokens/edges creates no noResults; direct token creates no optimum/result; no paths, enumeration, RouteSearchResult or winners; no route-level constructors during preparation, only selected ride-level constructors |
| Resources/isolation | Generated maximum work and exact/+1 chosen bounds, hostile count/text/payload/overflow preflight, copy-by-copy logical accounting; production compilation/nonisolated Sendable; no runtime/IO/persistence/DEBUG dependency/Phase-10 guidance |

### 22.8 Audit verification and handoff

Documentation only: source/tests unchanged, no tests/builds/device work required or run. No private
GTFS/S9/timetable/static/profile/inventory/connection artifact or receipt was accessed or quoted;
new text contains no real railway IDs, times, private paths or new artifact identities.
Independent non-author review: **20/20 PASS, zero unresolved material findings**. It verified
the current chain/technical-qualified boundary, ride materialization and negative/unknown handling,
singular exact feasibility owner/arithmetic, Accepted objective versus Proposed identity mechanics,
through counting, immutable policy-resolution caveats, supplied scope, separate operational budget,
input versus execution completion, solver-only noResults/optimality, algorithm neutrality and
canonical final admission. A local sequencing clarification now excludes known prohibited rides
before requiring unused unknown endpoint data; it establishes no new global failure precedence.
Privacy/scope audit and working `git diff --check` passed. Final reviewed-byte and cached scope/
whitespace checks are required before the authorized publication. Only this consumer proposal,
ARCHITECTURE, ROADMAP and the producer proposal's current-handoff overlay change.
Publication authorization covers only reviewed docs, one normal phase-branch commit; no main merge.
Broader `P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`, Phase 3 **In Progress**,
live/default routing unconfigured and production evidence/resource/adoption gates remain unchanged.

Exact next safe action, **not begun**:

> Separately authorize the smallest invented-only production Data `PreparedInternalSearchInput` slice defined in §22: require a technically qualified `ResolvedSearchInputAssessment`, materialize exact usable required ride tokens through existing `TrainCandidate` and `TimetableRideContext`, retain known-negative/excluded accounting and full assessment provenance, project each required positive connection's exact gap feasibility once, bind only Accepted DEC-086 objective/completion semantics, and establish evidence-backed finite construction safeguards with invented tests. Exclude route enumeration, solver/results, runtime adoption, real/private data and Phase-10 guidance; leave detailed itinerary identity/comparator mechanics to later solver design.
