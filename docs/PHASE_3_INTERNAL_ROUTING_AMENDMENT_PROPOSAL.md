# Phase 3 — Internal-routing consumer amendment proposal

**Status:** Accepted conditional amendment — DEC-079; context-only partial implementation independently approved\
**Date:** 2026-10-01

## Current acceptance and implementation boundary — 2026-10-01 Asia/Seoul

Accepted DEC-079: Consumer §§2–5 and C1–C6 are accepted conditional on DEC-078.
Timetable context construction, separate provider/timetable branches, exact matched
rail attachment and retained-context chronology are implemented and independently
approved as local values/validation only. Scoped internal results, failure/rejection
additions, internal preflight/admission, connection policy and engine obligations
remain deferred. Owner acceptance does not establish engine adoption, source
compatibility or production delivery. See DECISIONS for the authoritative acceptance
and ROADMAP for saved verification. Calendar interpretation/conversion and real
import remain unimplemented; P2-S9 and all applicable retained gates remain in force.

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
