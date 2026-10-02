# Phase 3 — Internal-routing consumer amendment proposal

**Status:** Accepted conditional amendment — DEC-079; context-only partial implementation independently approved\
**Date:** 2026-10-01

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
