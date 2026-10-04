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

**Standalone follow-up remains Proposed; baseline `023c1c206e1ed0cdabc0df41869455b9a1713ca6`.**
§15.7 describes the published, approved two-pass experiment and remains unchanged. This
standalone follow-up has no implementation/execution authority; the separately authorized
certificate-only harness is recorded in §15.8.7. DEC-086 objective, all equal optima,
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
