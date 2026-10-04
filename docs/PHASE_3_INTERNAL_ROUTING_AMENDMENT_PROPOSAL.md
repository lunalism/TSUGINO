# Phase 3 — Internal-routing consumer amendment proposal

**Status:** Accepted conditional amendment — DEC-079; context-only partial implementation independently approved\
**Date:** 2026-10-01

**Production policy update (2026-10-04):** §10 / DEC-086 records bounded owner
acceptance of route-selection/completion rules. Unresolved ownership, algorithm,
configuration and adoption choices remain Proposed; no production engine is adopted.

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
