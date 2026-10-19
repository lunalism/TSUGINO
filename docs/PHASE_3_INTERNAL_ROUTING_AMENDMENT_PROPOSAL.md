# Phase 3 — Internal-routing consumer amendment proposal

**Status:** Accepted conditional amendment — DEC-079; context-only partial implementation independently approved\
**Date:** 2026-10-01


**Governing relation-index implementation (2026-10-19):** §34 is published at
`8e5aae10ddd1b39559a7273a72bf8fbdba7bd216`; its not-yet-implemented wording is historical.
[§35](#35-exploration-relation-index-implementation-and-matched-validation--2026-10-19)
implements the §34 exploration-only relation lists and records the tests and matched validation.
That is 1,056 of 1,056 calls, with every credit, class and stage equal to the frozen predictions,
five new completions validated, and both runtime targets met. Simulator only, not Release, not
representative. P3-T1 stays incomplete, Phase 3 In Progress, live/default routing unconfigured.

**Governing relation-index design audit (2026-10-18):** the §33 metered merge-sort ordering, its
tests and matched evidence are published at `9accdeae9e3e6070647a546746aa3ee2cff0132c`; its
unpublished-state wording is historical.
[§34](#34-per-ride-feasible-relation-lists-design-and-cost-audit--2026-10-18) designs per-ride
feasible-relation lists for exploration (§32.5 candidate 3) and hands off one implementation slice.
Analysis only: no source, test or harness change and nothing executed except the arithmetic charge
model delivered with this change. P3-T1 stays incomplete, Phase 3 In Progress, live/default routing
unconfigured.

**Governing winner-ordering implementation (2026-10-17):** §32 is published at
`3368eb13d102831ba473b84e13cb0f0329451cf6`; its not-yet-implemented wording is historical.
[§33](#33-metered-merge-sort-winner-ordering-implementation-and-matched-validation--2026-10-17)
implements the §32.6 metered merge-sort ordering and records its tests and the matched validation:
660 of 660 calls, identical classes, digests and predicted credits, and both runtime targets met.
Simulator only, not Release, not representative. P3-T1 stays incomplete, Phase 3 In Progress,
live/default routing unconfigured.

**Governing solver optimization audit (2026-10-17):** the §31 harness, results and sanitized
evidence are published at `4dfb8e50920368358c9e1b304d7a23749cc10807`; its unpublished-state
wording is historical. [§32](#32-bounded-solver-optimization-audit--2026-10-17) audits solver work
from committed evidence only and hands off one bounded optimization slice (metered merge-sort
ordering). Analysis only: no source, test or harness change and nothing executed. P3-T1 stays
incomplete, Phase 3 In Progress, live/default routing unconfigured.

**Governing measurement execution (2026-10-16):** §30 is published at
`c2917e3f511ef33d5b471dc620adc8448723fa88`. [§31](#31-invented-measurement-harness-and-experiment-results--2026-10-16)
records the test-target/Tools harness and the bounded invented experiment: 1,460 of 1,506 calls
in 54.5 min, with no harness stops. Simulator only, not Release, not representative; no production change.
P3-T1 stays incomplete, Phase 3 In Progress, live/default routing unconfigured.

**Governing measurement design (2026-10-16):** §29 is published at
`7886c20ab7a2b4dda8fc1cb23a57ad9132ad6d26`; its pre-publication wording is historical.
[§30](#30-bounded-invented-workload-and-measurement-experiment-design--2026-10-16) designs the
bounded invented workload and measurement experiment and its harness handoff (documentation
only; nothing run). P3-T1 stays incomplete, Phase 3 In Progress, live/default routing
unconfigured.

**Governing invented-only composition implementation (2026-10-15):** the §28 audit is published at
`e3da19dbc2f40e8265d649836bacc85e7fde6635`; its not-begun wording for the §28.6 slice is historical.
[§29](#29-invented-only-end-to-end-routing-composition--2026-10-15) records that slice implemented
for invented data only, with two provisional mappings pending owner confirmation, and its
verification. Not registered in AppEnvironment. P3-T1 stays incomplete, Phase 3 In Progress,
live/default routing unconfigured.

**Governing producer/dependency audit (2026-10-14):** the §27 contract is published at
`b0438eda9082104cb99949b21b7c7669bd5ab909`; its unpublished-state wording is historical.
[§28](#28-declaration-connection-evidence-and-dependency-producer-audit--2026-10-14) audits the declaration,
connection-evidence and dependency seams and hands off an invented-only integration slice (not begun).
No implementation, test or measurement. P3-T1 stays incomplete, Phase 3 In Progress,
live/default routing unconfigured.

**Governing composition contract (2026-10-14):** the §26 audit is published at
`df031dc05fe7fb4881b0441f824baea09b3e0b83`. [§27](#27-requestpreparationsolver-composition-contract--2026-10-14)
records the documentation-only request→preparation→solver contract, its missing seams, open
decisions and the next recommended audit (not begun). No implementation, test or measurement.
P3-T1 stays incomplete, Phase 3 In Progress, live/default routing unconfigured.

**Governing published solver and post-publication readiness audit (2026-10-14):** the §25
eight-file change set is published at `4df37d5cfcb9ab81106257b21855169450f72c46`
(`feat: add bounded prepared internal route solver`, parent `05ea2cf`). Earlier unstaged/
uncommitted/publication-pending wording for it is historical. [§26](#26-post-publication-readiness-audit--2026-10-14)
records the documentation-only readiness matrix and one recommended next task (not begun).
No tests/builds/solver runs were performed for this audit. P3-T1 stays incomplete, Phase 3
In Progress, live/default routing unconfigured.

**Governing invented-only production solver implementation (2026-10-10):** the owner
separately authorized the consumer §24 implementation from published contract checkpoint
`05ea2cf463e3b88f14e81a7fc5055cff5c06e678`. [§25](#25-invented-only-production-prepared-input-solver-implementation)
records the iterative exhaustive DFS proof, invocation safeguards, independent test-only
oracle and verification. Earlier algorithm/limits-awaiting and solver-next statements are
historical. No Accepted objective, upstream truth or DEBUG synthetic contract changes.
It was uncommitted when recorded; it is now published (see 2026-10-14 overlay above).
Real input, runtime adoption and deployment suitability remain separate gates.
P3-T1 stays incomplete, Phase 3 In Progress.

**Governing production execution-contract audit (2026-10-10):** the exact independently
approved prepared-input bytes were published at `17b97ed86a2a20e950dded1a7fb95f8766257000`
(`feat: add prepared internal search input`). Earlier unstaged/publication-pending and
input-next statements are historical. [§24](#24-production-solver-execution-contract--2026-10-10)
defines the next invented-only solver contract, including the minimal input-local identity,
reproducibility-only ordering, completion/resource boundary and canonical winner admission.
It governs the previously deferred production mechanics in §10.2 and clarifies §10.4/§22.5
work accounting; no Accepted objective, Domain identity or synthetic contract changes.
Classification: `P3_PRODUCTION_SOLVER_IMPLEMENTATION_NEXT`; `NO_NEW_PRODUCT_DECISION_REQUIRED`.
Numeric solver limits await implementation evidence. Review/publication status is in §24.11.
No solver/source/test/runtime or real/private work is performed by this documentation audit.
P3-T1 remains scope-incomplete, Phase 3 In Progress, live/default routing unconfigured.

**Governing prepared-input implementation (2026-10-10):** the owner separately authorized
only the invented production Data slice from published §22 audit
`7d0b37e0162ada88e720cd368a88dd9f656edb7f`. [§23](#23-invented-only-prepared-input-implementation--2026-10-10)
records its immutable values, generated technical-limit evidence and completed verification/review.
Verdict: `P3_PRE_SOLVER_EXECUTABLE_INPUT_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`.
Earlier input-next/audit-only statements are historical. No solver, result, real prepared input
or runtime adoption follows; §10.2 comparator remains Proposed. Publication is not authorized
in this implementation task: changes remain unstaged/uncommitted.


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

**Current resolution:** §24.3–§24.4 now specifies production input-local ride-sequence
identity and reproducibility ordering under the owner's execution-contract audit authorization.
The redundant interleaved connection fields below are historical Proposed mechanics, not the
selected identity. Existing DEBUG byte-key semantics remain unchanged.

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

**Current work-accounting clarification:** §24.6 governs the new solver entry boundary:
preparation's fixed safeguards remain separate, while one uninterrupted solver invocation meter
starts at accepted immutable input and includes compatibility/indexing through finalization.
The cross-preparation-counter recommendation below is historical, not an Accepted requirement
to mutate the published input or change DEC-081 synthetic accounting.

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

## 23. Invented-only prepared-input implementation — 2026-10-10

### 23.1 Scope, values and accounting

The independently reviewed §22 audit was published at
`7d0b37e0162ada88e720cd368a88dd9f656edb7f`. This separately authorized implementation adds
production `Data/Routing/PreparedInternalSearchInput.swift` and invented
`PreparedInternalSearchInputTests.swift`. Domain, B closure, inventory and DEBUG synthetic
semantics remain unchanged. The only other production edit mechanically extracts the existing
allowance TwoSum operations into `ConnectionBinary64Addition` in QualifiedConnectionEvidence.

`PreparedInternalSearchInput` is immutable/nonisolated Sendable, with the entire original
`ResolvedSearchInputAssessment`, derived exact scope, fixed objective, ordered usable rides,
ordered per-required-interval accounting, ordered prepared connections and logical payload bytes.
Its sole throwing initializer requires technical qualification; any remaining hold refuses
atomically. It creates no second closure, bare completion Bool, paths, candidates, winners,
results, runtime configuration, persistence/cache or source/IO owner. References still do not
resolve/authenticate real evidence, rights or DEC-080 runtime policy contents.

Only B's occurrence/interval declarations are traversed, in their retained order. Each interval
has occurrence/interval indices and exactly one state: usable with ride-array index, inactive,
absentUnderCompleteAuthority, prohibitedEndpoint or outsideScope. Missing usable tokens have an
explicit explanation; no negative is reclassified as unavailable or a search rejection.

For active/present intervals, indexed inventory lookup and full binding association precede
endpoint use. Either prohibited boarding/alighting excludes before unknown counterpart permission
or unused events. Otherwise both permissions must be allowed, both required events exact, then
both events must fall within inclusive supplied [L,U]. Needed unknown permission/missing/estimated
event refuses the entire preparation; one out-of-scope timestamp cannot hide the other missing
required endpoint. Exact outside-scope endpoints give a local exclusion without changing horizon.

Each usable `PreparedTimetableRide` retains a request-local key (exact dated occurrence address,
original boarding/alighting indices), actual `TrainCandidate` and actual `TimetableRideContext`.
Anchors, lines and exact times derive from those canonical values. Full snapshots/coverage/service
segments are preserved; no additional snapshot field or parallel validator exists. Unexpected
canonical construction failures are typed consistency errors, never silently omitted. Repeated
visits/dates stay distinct by key. A spanning multi-Line Trip remains one token, no line/operator
boundary fragments or artificial train change. Future genuine change counting remains between
rides, subject to existing duplicate recurring Trip constraints.

### 23.2 Connection projection and exact arithmetic

Exactly one `PreparedConnectionRelation` per B-required target retains its directional key,
exact original evidence-array index and feasible/infeasible/absentUnderCompleteAuthority state.
Output is B order independently of A storage order. The whole assessment retains original
positive form/allowance/events/context/review; `positiveEvidence(at:)` derives that exact payload
without retaining a second copy. Negative and infeasible states supply no traversal edge. A
relation with no usable incident ride remains accounted for. No reverse inference, endpoint-pair
Cartesian expansion, additional requiredness or incidence array is introduced.

Preparation is the single production owner of exact train-gap projection. Finite arrival a,
departure d and nonnegative qualified allowance t permit iff d >= exact mathematical a+t.
`PreparedConnectionGap` uses the shared production-local error-free addition primitive: finite
represented sum s with residual e permits d<s false, d>s true, d==s iff e<=0. Rounded-down equality
therefore fails and rounded-up equality passes. Nonzero residual is legitimate. Positive overflow
is normal known infeasibility before residual arithmetic; unexplained nonfinite intermediates
produce typed arithmeticConflict. Zero allowance applies normally. No subtraction alternative,
epsilon, time-zone conversion, saturation or synthetic helper is used.

`ConnectionAllowance` retains precisely its old component validation, ordered TwoSum operations,
finite intermediate checks, zero-residual requirement, asserted-total equality and signed-zero
canonicalization. Only the primitive extraction changes its implementation. Feasibility states
are not preparation errors or public search failures; infeasibleConnection remains a defensive
later handed-off-candidate rejection.

### 23.3 Accepted objective and future ownership

`InternalRouteObjectiveDefinition` has a closed supported Accepted DEC-086 V1, immutable exact
`InternalSearchPolicyReference` and 14 fixed obligations: earliest exact final arrival, fewer
genuine train changes, no internal through-service changes, all distinct equal optima,
reproducibilityOnly, optimum/all-tie proof before success, no first-found/first-K, cutoff as
searchIncomplete, unknown required evidence as dataUnavailable, selection before frozen handoffs,
preserve all admitted winners, mixed rejection as searchIncomplete and all rejected as existing
unscoped noUsableAlternatives. `hasSameDefinition` compares full obligations/version/reference;
changed reference prevents compatibility. No caller-configurable ranking or mutable latest lookup.

This binds obligations, not execution proof. §10.2 itinerary-key/UUID/UTF8/form/prefix comparator
and concrete identity/dedup mechanics remain Proposed and are absent. No new preference or product
decision is introduced. Connection/time interpretation remains materialized upstream; DEC-080
immutable definition resolution, real authentication and runtime preflight/adoption remain gates.
Exact supplied scope/horizon/ride cap is derived unchanged, with no production default.

Work/memory/cutoff/checkpoint configuration stays outside the input and belongs to future explicit
invocations. Application retains runtime selection/lifetime/cancellation/publication/retry ownership;
the future solver owns request execution accounting. This slice selects no algorithm or pruning.
Later complete selected itineraries must reconstruct retained rides through RouteRailProposal,
WalkingTransfer only for walking form, RouteCandidate and existing scoped admission constructors.
Same-station changes add no walk. None of these route-level values is constructed here.

Prepared qualification is not execution completion. Empty usable arrays are valid input, never
noResults. A direct ride with feasible transfer possibilities establishes no winner or optimum.
Later solver design must settle identity/dedup/reproducibility mechanics and prove optimum/all ties,
sound bounds/pruning/cycles/used-Trip constraints and cutoff truth before any result. No real
prepared input exists: invented production values precede any separately authorized bounded pilot.

### 23.4 Generated finite-limit evidence and complexity

Before selecting new constants, the invented workload model exercised actual TrainCandidate plus
TimetableRideContext, full original assessment, interval ledger, relation records and conservative
fixed objective payload. Snapshots/references were charged copy-by-copy, independent
of COW. The printed model total did not separately charge its constructed interval array; the
ledger-inclusive column below adds the measured 24-byte record stride analytically. 72-stop through Trips, up to 48 supplied intervals/occurrence, 32-byte stop identifiers and
both positive/negative connection records were used. Simulator observations (not performance gates):

| Rides | Relations | Assessment logical bytes | Printed model bytes | Ledger-inclusive model bytes | Ride projection time |
|---|---:|---:|---:|---:|---:|
| 256 | 0 | 1,811,129 | 3,758,009 | 3,764,153 | 0.0101 s |
| 1,024 | 0 | 6,593,409 | 14,382,337 | 14,406,913 | 0.2053 s |
| 4,096 | 2,048 | 43,127,224 | 74,717,529 | 74,815,833 | 0.1687 s |
| 5,120 | 2,048 | 49,408,784 | 88,791,307 | 88,914,187 | 0.1737 s |

Pre-selection model strides were ride 256, interval 24, relation 128 bytes. These in-memory struct
strides and noisy Simulator timings do not measure expanded heap usage or establish iPhone capacity.
The final accounting independently charges every interval record at 32 bytes (rather than
omitting the array as the printed model did) and charges explicit
objective/header plus every newly retained key and each actual train/context snapshot spelling.

Selected technical safeguards: at most **4,096 usable rides**, **96,000,000 expanded logical bytes**,
**92,160 interval accounting entries** (inherited B total), **2,048 prepared relations** (inherited A),
existing **2,880 required/loaded occurrences**, **48 intervals/occurrence**, **72 stops/Trip** and
**192 UTF-8 bytes/token**. Fixed objective accounting is 256 bytes; there is no variable objective
payload or incidence multiplicity. The practical ride cap matches the measured mixed maximum;
the 25%-larger model demonstrates construction stress beyond it, not authority to raise it. The
96 MB logical cap provides headroom above that measured shape while rejecting longer/larger retained
payloads independently of the ride cap. These are finite technical safeguards, not solver work
budgets, production horizon choices, network coverage or heap/performance guarantees.

Top-level counts precede nested traversal; inherited immutable constructors already bounded each
actual text/nested snapshot before original hashing/equality. Preparation charges the exact whole
constructor-accounted assessment, then new ledger/keys and each actual train/context snapshot copy
before new lookup/canonical work. New text uses bounded prefix scans, nested counts precede scans,
and an overflow-safe subtract-before-add budget fails atomically without truncation. No trusted
caller size assertion exists. Required interval counts use remaining-capacity arithmetic.

Expected O(I + Q*S + C + P) work with S<=72; keyed loaded/evidence/ride associations, declaration-order
output, finite O(I+C+R) temporary indices. P is the inherited bounded payload, Q required intervals,
C required relations and R usable rides. Full canonical snapshot semantics remain authoritative;
no pairwise snapshot scan, all-index-pairs generation, paths or Cartesian ride connections.

### 23.5 Verification and handoff

Author required Debug verification passed on an explicit iPhone 17 Simulator: all **188 functions /
426 cases**, comprising the new **30/64** suite and **158/362** relevant regression functions/cases.
Regressions include QualifiedConnectionEvidence **42/122**, RequestScopedSearchInputClosure **31/90**,
TimetableOccurrenceInventory **18/48**, TimetableRideContext **10/14**, InternalSearchScope **11/18**,
InternalSearchSuccess **13/15**, RoutingValue **16/26**, and synthetic timetable direct **7/16**, batch
**6/7**, optimal **4/6**. No regression test or synthetic behavior was changed.

Actual production construction accepted **4,096 rides + 2,048 relations at 74,848,665 logical bytes**;
**92,160 inactive ledger entries at 19,055,929 logical bytes**. Exact ride cap, +1 and 25% over-cap
shapes, count preflight exact/+1/Int.max/negative cases, independent logical-budget exact/+1/overflow
atomicity and longer-text payload rejection passed. Longer retained snapshot spellings are charged
copy-by-copy. These observations establish bounded technical construction, not physical performance.

The suite also covers all required holds, immutable assessment/scope provenance, unknown/estimated
endpoint sequencing, inclusive bounds, canonical full snapshots/original repeated indices/dates,
through multi-Line rides, positive same-station/walking/absent/infeasible directional projections,
reordered A evidence with B-order output, no Cartesian pairs, relations with no usable incident ride,
exact residual signs/equality/overflow/zero allowance, fixed objective/reference compatibility,
empty input/direct-plus-transfer input without result/optimum, fixed API shape and detached Sendable
construction. An initial fixture compilation omission and a same-station fixture's adjacent duplicate
station were corrected; the full required regression run passed thereafter. Final focused reruns
also include the strengthened direct-plus-incident-transfer assertions.

Author standard Release app + dependent Live Activity extension build passed on explicit iPhone
Simulator. The independent fresh Release app/extension build also passed; new production values
compile without DEBUG dependencies. Neither changed production source adds a warning; existing
icon-resource, Domain actor/Codable and skipped AppIntents metadata warnings remain unrelated.
No physical-device work is required or performed. Final author and independent focused reruns
each passed **30 functions / 64 cases**, including the strengthened direct-plus-incident-transfer
assertions, with **0 failed, 0 skipped and 0 runtime warnings**. The independent nonauthor review
approved **all 31 criteria**, including before/after allowance semantics and bounded construction,
with **no unresolved material findings**. Independent fresh Release and focused reruns used an
explicit iPhone 17 Pro Max Simulator; author verification used an explicit iPhone 17 Simulator.

Bounded implementation verdict:
`P3_PRE_SOLVER_EXECUTABLE_INPUT_VALUES_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`.
This approves invented input values only, not real input, solver execution or phase completion.

Scope/privacy/isolation and working git diff --check pass. No real/private GTFS/S9/timetable/static/
profile/inventory/connection artifact or prior receipt/review was accessed. No paths/search/solver,
route-level constructor/result, runtime budget/adoption, networking/IO/persistence/cache or Phase-10
guidance is added. Exact change set: new production source/test, mechanical arithmetic extraction,
consumer/ARCHITECTURE/ROADMAP plus producer current-handoff overlay. No stage, commit or push is
authorized in this task.
Broader `P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE`, Phase 3 **In Progress**,
live/default routing unconfigured and real coverage/resource/adoption gates remain unchanged.

Exact next safe action, **not begun**:

> Owner review and publication of the independently approved `PreparedInternalSearchInput` production values. After publication, separately assess the production solver execution contract: exact itinerary identity/dedup/reproducibility ordering, algorithm-neutral enumeration/optimality proof obligations, invocation resource/cutoff configuration and canonical winner admission. Do not begin solver implementation or real/private routing execution in the publication task.

## 24. Production solver execution contract — 2026-10-10

### 24.1 Authority, publication and exact start boundary

This owner-authorized documentation/architecture audit follows publication of the exact
independently approved §23 values at `17b97ed86a2a20e950dded1a7fb95f8766257000`
(`feat: add prepared internal search input`). Repository/branch/upstream/live match that clean
checkpoint, divergence 0/0; local/tracked/live main remains
`e8a463d51f14b3cb1027960c63244b694579a71b`. No source/tests change or execution is authorized here.

Authority is Accepted DEC-076 as amended only for internal consumption by DEC-079, dated
producer semantics DEC-078, DEC-080's selected V1–V7, DEC-086's arrival/change/all-equal-optima/
completion rules and DEC-087's Application lifecycle. DEC-081 all-distinct return, synthetic
algorithms/limits and experiment certificates remain DEBUG-only. Historical production P5
all-distinct-return, §10.2's redundant identity fields and cross-preparation-meter recommendations
do not override this contract. This resolves technical mechanics of existing Accepted obligations,
not a new preference or wholesale acceptance of DEC-086 R6/deployment.

One immutable `PreparedInternalSearchInput` is the solver's exact start boundary. It retains the
whole technically qualified assessment, exact request/scope/profile/view, ordered usable rides,
ordered negative/excluded interval ledger, required connection projections and fixed Accepted
DEC-086 objective/version/reference. Construction qualification is not execution completion.
Compatibility must preserve this entire input/objective association; matching a label alone or
substituting another assessment is insufficient. Unsupported/incompatible objective/input truth
fails dataUnavailable, not a fallback ranking. Existing upstream preflight order remains intact.

The solver consumes prepared truth. It does not reinterpret service dates, source clocks,
eligibility, Trip continuity, connection evidence, allowances or gap feasibility. Known inactive,
absent, prohibited and outside-scope ledger entries supply no ride. Prepared relation states
supply the sole temporal-feasibility decision. No new requiredness, input narrowing, raw policy
parser, current-view reload or clock/calendar conversion is part of solving.

### 24.2 Feasible itinerary and finite universe

For this exact input P, a feasible itinerary is a **nonempty ordered sequence of retained prepared
ride tokens** satisfying every condition below, with canonical admission predicates preserved:

1. First boarding station equals P.scope.request.origin; last alighting station equals destination.
2. Every token is from P.rides, with its exact key, TrainCandidate, dated TimetableRideContext and
   full snapshot association. No synthetic ride, fragment stitching or unresolved travel.
3. Ride count is at most scope.profile.maximumRailRides. No recurring TripID occurs twice, even
   on different dates, preserving RouteCandidate/DEC-078 restrictions.
4. Each adjacent pair derives exactly the directional ConnectionRelationKey from previous
   address/alighting original index and next address/boarding original index. P must contain
   that required relation in state feasible. Infeasible/qualified-absent/missing relations cannot
   be traversed; neither reverse edges nor implicit same-station/zero-allowance edges exist.
5. Exact retained chronology holds within every ride and across transitions, within the inclusive
   supplied scope. Prepared feasibility already establishes the allowed inter-ride gap; do not
   implement a second formula. Profile station/line/Trip membership and scope association remain
   the canonical scoped-admission constraints, not new search heuristics.
6. A through multi-Line/operator Trip stays one ride. Each transition between distinct rides is
   a qualified genuine train change. Walking occurs only for the exact walking form; sameStation
   adds no walking leg. No access/egress walking or Phase-10 detail is invented.

Do not require acyclic station visitation. Repeated stations, permitted cycles and zero-duration
rides/connections remain possible where existing canonical structure and all conditions hold.
A destination-reaching prefix is a feasible complete itinerary, not permission to terminate the
whole search; any exclusion of its extensions requires the same sound objective proof as below.

Let R be finite usable rides and T their finite distinct recurring TripIDs. Sequence length is
at most min(maximumRailRides, T), and each position has at most R choices; the mathematical sum
of R^k over that finite range bounds the universe. Required relations are also finite. This is
a finiteness argument, not an implementation allocation/count computation or practical runtime
claim. No station-visited policy, algorithm or new product limit is needed to make it finite.

### 24.3 Exact identity and duplicate semantics

**Selected identity:** the ordered sequence of `PreparedTimetableRideKey` values, local to one
exact P. Equality is sequence length plus pairwise existing key equality. A key retains view,
TripID, opaque service-date identity and both original indices. It is not persistent identity,
a Journey ID or permission to reuse a path under another input/objective.

**Sufficiency proof:** P's constructor permits only one retained usable token per equal ride key.
Each adjacent key pair uniquely derives the full directional connection key. B declares each
required key once; A and the assessment require one compatible evidence record/projection per
key, preserving exactly one form/allowance and endpoint snapshot association. Canonical station
anchors/times derive from those retained rides. Thus the ordered ride keys determine every
connection key/form, station and time within P. Adding these derived fields to identity is
redundant; multiple physical footpaths under one qualified walking relation are not separately
represented alternatives. A future multi-form/parallel-relation input model would require a new
review of this proof before reuse, not silent expansion of this identity.

Two feasible itineraries are duplicates **only** when their entire identity is equal. Exact
duplicates may collapse before winner handoff and are neither omissions nor rejections. Do not
deduplicate by station list, times, lines, objective pair, displayed route or recurring pattern.
Different dated occurrences, original repeated-visit indices or Trip identities remain distinct
where existing keys differ; different directional transitions follow from different sequences.
Conflicting same-key input truth is dataUnavailable, never a deduplication opportunity.

**Existing equality versus spelling:** Canonical IDs and TimetableServiceDate preserve supplied
spelling, but their current synthesized Swift String equality includes canonical Unicode
equivalence. Do not change that equality, normalize IDs or invent byte-distinct identities.
Equal-key duplicate tokens cannot coexist in P. Resolve every internal key claim to its unique
retained token before dedup/order; use that retained key's spelling, never an arbitrary redundant
binding/context spelling. Other non-equal keys may contain canonically equivalent text spellings;
this does not authorize changing them. Input permutation means reordering the same retained
tokens/records, not replacing their strings or snapshots with alternate representations.

### 24.4 Reproducibility-only total ordering

After the full identity-distinct equal-optimal set is established, order it structurally:

| Ride-key field, in order | Comparison |
|---|---|
| Occurrence view UUID | Its fixed 16 bytes in UUID tuple/canonical textual byte-pair order, unsigned; never host-endian memory layout |
| Recurring TripID | Retained rawValue unsigned UTF-8 bytes, lexicographic; shorter byte prefix first |
| Service-date label | Retained unsigned UTF-8 bytes, lexicographic; shorter byte prefix first; no date parsing |
| Boarding original index | Numeric ascending |
| Alighting original index | Numeric ascending |

Compare itinerary sequences lexicographically by those retained ride keys. Equal identities
compare equal; a strict sequence prefix precedes its extension. Equal objective normally forces
equal ride counts, but this prefix rule safely makes the comparator total on all retained
identity sequences. Do not order by array offsets, hash iteration, localized collation, formatted
dates or departure time. Within fixed P, unique retained representatives make equality/dedup and
the total byte/numeric order consistent; reordered storage cannot alter the tied output order.

Ordering cannot alter the objective or remove a tied identity. **The first equal-optimal candidate
after reproducibility ordering is not considered better than the others.** The solver preserves
all of them. Showing only one in future UI requires a separate presentation/product rule.
No fare, walking distance, comfort, reliability, early-departure or other preference is introduced.
Identity/dedup/order operationalize Accepted distinctness/reproducibility:
**`NO_NEW_PRODUCT_DECISION_REQUIRED`**. This resolves the previously deferred technical mechanics
without retroactively changing §10.2 history or the existing DEBUG algorithms.

### 24.5 Objective, exploration, pruning and completion proof

The sole objective pair is **(exact retained final arrival instant, ride count minus one)**,
lexicographically minimized. Every ride transition is one genuine change; internal through-line/
operator boundaries and a walking leg add no extra change. Use exact absolute instants and integer
counts, never display rounding or a third score. Every identity-distinct feasible itinerary at
the minimum pair must survive. No historical all-feasible-path production return rule is revived.

No Dijkstra, A*, DFS, BFS or other production algorithm is selected. Any implementation must prove
that every feasible itinerary able to beat or tie the incumbent was explored or soundly ruled out,
that no better itinerary remains, and that every distinct equal optimum is retained. Discovery
order is private. First destination/direct/fastest-so-far/tied route establishes an incumbent only.

Pruning may exclude a proved infeasible state, an already-accounted exact duplicate, or a state
proved unable to yield a better pair **or another equal-optimal identity**. An optimistic objective
lower bound prunes against the incumbent only when strictly worse. Equality alone cannot prune
unaccounted ties. Unknown evidence, guessed transfer time, earlier arrival alone, same station/
time/objective, visited station, first destination or first-K are not pruning proofs.

Generic dominance is **deferred**. A later rule must prove continuation equivalence/simulation
for exact ride/date, remaining TripID availability, remaining ride-count capacity, prepared
connections, objective bounds and identity-distinct tied prefixes. Matching station/time/score
alone loses these facts. Correctness precedes optimization; no simple dominance rule is adopted.

Execution completion has exactly two valid proof forms:

- **Exhaustive:** every feasible itinerary in the fixed universe has been accounted for.
- **Frontier/bound:** any unexplored state is soundly excluded from producing a better objective
  or any additional equal-optimal identity; all established equal-optimal identities are accounted
  for. Proof must cover all remaining roots/states, not just the currently convenient frontier.

Either form may avoid materializing slower paths. Neither is an externally supplied completion
Boolean/certificate or practical capacity claim. Complete optimum/tie proof is necessary but
terminal success also requires completed ordering, canonical admission and finalization.
Zero rides, zero feasible relations, no direct route or a dead end alone is not noResults proof.
The solver can prove an empty universe by bounded root/constraint accounting; it must still
complete that execution and its cancellation/resource/finalization duties.

### 24.6 Invocation resources, uninterrupted work and cancellation

Recommend immutable, validated per-invocation `InternalSolverExecutionConfiguration`, separate
from P and its evidence. Dimensions to evaluate are deterministic work-unit allowance, all retained
search-state/frontier/memo capacity, and complete equal-optimal identity/key retention capacity.
Include indexing/auxiliary storage and admission/finalization work in the same safeguards; a
separate reserve may be justified later but cannot reset or evade the total meter. Exact names,
charge units/checkpoint partition and any additional bounded payload dimension require the later
algorithm/cost audit. Use overflow-safe count/payload preflight before allocating/retaining work.
Horizon and maximumRailRides remain semantic scope/profile constraints, never execution knobs.
Invalid invocation configuration follows configurationUnavailable preflight; it is not noResults.

**`NUMERIC_PRODUCTION_SOLVER_LIMITS_REQUIRE_IMPLEMENTATION_EVIDENCE`**. No numerical work/state/
winner/checkpoint limit or timeout duration is selected. Future values require invented stress,
independent exhaustive-oracle comparison and representative workload evidence before production
adoption. Fixed preparation caps are not solver capacity; DEBUG constants/certificates/legacy
trace budgets do not become production defaults. Resource configuration affects only whether
completion can be proved, never identity/objective/preference or an implicit first-N recommendation.

**Work owner:** preparation has already finished under its own fixed construction safeguards.
One solver invocation meter starts at acceptance of immutable P and includes entry compatibility,
indexing/normalization, exploration/bounds, exact dedup/tie collection, order, reconstruction,
admission and finalization. No reset at a stage boundary, suspension, incumbent replacement or
post-proof admission; repeated work is charged. Preparation does not become mutable/instrumented
to inherit this counter. Route-search orchestration may separately measure preparation + solve
end-to-end cost for deployment evidence; this does not erase earlier work or promise a common unit.

This explicitly clarifies the broader Proposed budget wording in §10.4 and supersedes the
cross-preparation-meter architecture recommendation in §22.5. No Accepted production rule requires
one meter spanning an already constructed P; Accepted cutoff/completion duties remain unchanged.
DEC-081/§19's existing synthetic one-meter behavior remains unchanged. Any future end-to-end hard
budget needs a separately reviewed composition; it cannot be claimed by summing incompatible units.

Any operational cutoff **before full terminal completion**, including after optimum proof during
dedup/order/admission/finalization or winner-set retention, yields `RouteSearchFailure.searchIncomplete`.
No partial/best-so-far candidate, tied subset, noResults or omission-based tie truncation escapes.
If the complete equal-optimal set exceeds a safeguard, fail searchIncomplete, never keep first N.
Elapsed time is not a correctness/completion oracle. A future watchdog may abort as a separately
specified cancellation/cutoff source, with no partial success; no timer policy is adopted here.

Observed cancellation throws `CancellationError`, no partial output. Check before execution,
at bounded entry/indexing/exploration work checkpoints, during dedup/selection/order, before and
during reconstruction/admission/finalization, across suspension boundaries and before every
terminal result or pending non-cancellation failure. At an observed checkpoint it wins over the
pending outcome, including cutoff. No lower-priority shared-fault probing is required. Cancellation
after the final check may not be observed before return; Application still suppresses superseded
responses under DEC-087. No latency/fairness or physical-device responsiveness is claimed.

### 24.7 Data ownership, entry point and independent reference oracle

Recommend a request-local Data solver behind a future RouteSearching composition, conceptually
`solve(preparedInput, executionConfiguration) async throws -> RouteSearchResult`. Exact internal
Swift names are implementation details. P/configuration are immutable; mutable state and counters
belong exclusively to one call. No hidden global mutable kernels, automatic retry, detached orphan
work, one-call mutation/cancellation of another or MainActor-heavy computation. Entry scheduling
must explicitly satisfy off-main execution under current project isolation settings; async/Sendable
alone does not prove it. Only RouteSearchFailure or CancellationError may escape; raw internal
errors are contained without reclassifying a known operational cutoff as bad input.
Application retains task lifetime, runtime profile/configuration selection,
retry intent and publication guards. No port/AppEnvironment/UI/Journey wiring is authorized here.

Require an **independent test-only exhaustive oracle directly over small invented P**: enumerate
every feasible sequence under §24.2; exact-identity dedup; objective minimum; retain all tied
identities; canonical reproducibility order. It must not share an optimized exploration/pruning
implementation whose defect it is meant to detect. It may reuse immutable production inputs and
canonical constructors. Keep oracle enumeration out of Release; never treat it as real evidence
authentication. Existing DEBUG all-distinct engine/certificates are references, not an automatic
production algorithm, identity implementation, budget or proof of parity with this new boundary.

### 24.8 Winner freeze, reconstruction and defensive admission

Only after complete optimum/tie proof, freeze the full identity-distinct optimal set, order it
under §24.4 and assign contiguous handoff indices `0..<winnerCount`. Internal exploration ordinals
never become omission indices. Slower or equal-arrival/more-change paths are objective exclusions;
pruned states and exact duplicates are not omissions and get no handoff index.

For each frozen winner, reuse every retained TrainCandidate and TimetableRideContext to construct
matched RouteRailProposal with timetable context. Resolve each exact prepared transition:
sameStation appends no walk and the adjacent canonical station must match; walking constructs one
directional WalkingTransfer from previous alighting to next boarding station. Never invent access/
egress walking or Phase-10 guidance. Construct RouteCandidate through its existing initializer;
retain exact request/profile/view/scope association through InternalSearchSuccess. Do not bypass
canonical constructors or duplicate upstream eligibility/gap interpretation.

Each frozen winner receives exactly one admitted candidate or RouteAlternativeOmission. A correct
solver over intact P should admit every winner. Defensive checks distinguish a local reconstruction/
traversal defect from unusable **shared immutable input truth**:

| Defect in a frozen winner over otherwise usable P | Existing primary rejection reason |
|---|---|
| Reconstructed origin/destination differs from request | endpointMismatch |
| Chosen transition is absent/missing from required relations, or local form/target/walking direction is incompatible with its retained relation | unverifiedTransfer |
| Duplicate recurring TripID, rail/walk composition or canonical structural adjacency defect | invalidStructure |
| Copied Train/context snapshot, original index or key-to-token attachment contradicts its retained token | inconsistentTrainEvidence |
| Local copied timetable endpoints/chronology contradict retained exact contexts | invalidScheduledContext |
| Local endpoint use contradicts retained conclusive permission/accounting | unverifiedEligibility |
| Winner incorrectly traverses a valid prepared infeasible relation | infeasibleConnection |

Use one primary reason per rejected winner, testing applicable local categories in the existing
RouteAlternativeRejectionReason declaration order above. Use winner order for omission indices.
Do not probe unrelated/lower-priority shared faults to accumulate diagnostics. Missing exact data
in P, incompatible objective/scope/view, contradictory shared snapshot or broken relation/evidence
association/projection invalidates the call as **dataUnavailable**, rather than many local omissions.
A path choosing no valid relation from intact P is local unverifiedTransfer; P's promised record
itself being missing/corrupt is shared dataUnavailable. An unknown/nonexistent token claim from
the solver is local inconsistentTrainEvidence; a corrupted retained token is shared dataUnavailable.
These checks reuse retained truth; they do not recalculate allowances or reinterpret permission.

After every frozen winner receives its outcome, finish existing canonical batch/rejection/scoped
constructors and final cancellation/resource checks:

| Completed outcome | Exact terminal semantics |
|---|---|
| Zero winners, proved zero feasible complete identities | `.internalSuccess(InternalSearchSuccess(scope: P.scope, outcome: .noResults))` |
| All frozen winners admitted | Scoped InternalSearchSuccess alternatives, all candidates in frozen order, normal omissions empty |
| All frozen winners rejected | Throw existing **unscoped** noUsableAlternatives(RouteSearchRejections), omissions contiguous from zero |
| Both admitted and rejected frozen winners | Throw searchIncomplete; no partial success |

Notation names the existing failable constructors; it does not bypass validation. No new optimal
payload or change to RouteSearchBatch is required. Unexpected batch/scope/accounting assembly
contradiction that prevents forming the canonical terminal value fails dataUnavailable; an actual
operational exhaustion still means searchIncomplete. No fallback to slower paths, replacement,
automatic retry or silent winner disappearance follows from defensive rejection.

noResults requires qualified P, completed zero-feasible-itinerary proof, complete finalization,
no cutoff/cancellation and no unknown required evidence. It is not the all-rejected outcome.
dataUnavailable denotes missing, incompatible, contradictory or unusable input truth (including
any known invalidation under the applicable future runtime policy, not a new freshness clock).
searchIncomplete denotes usable input but unproved computation/completion due cutoff or mixed
admission. Discovery timing never swaps these meanings. No bare external .noResults is emitted
by this internal solver contract. A direct ride remains only an incumbent until no better transfer
or additional tied identity remains; no direct-success fast path without proof.

### 24.9 Future invented-only verification matrix

All cases below are **required future tests**, not executed evidence from this documentation task.
Compare production output identities/objectives/order and terminal semantics against the independent
exhaustive oracle on small bounded invented universes, including adversarial input permutations.

| Area | Required cases |
|---|---|
| Identity/dedup | Exact duplicate collapse; same stations/times but different dated Trip; repeated original index; different Trip; directional transition distinction; canonical-equivalent String equality with retained representative ordering; no conflict salvage |
| Objective | Direct slower than transfer loses; direct faster wins; equal arrival fewer changes; through boundaries add zero; all distinct equal optima; first discovery not winner; best discovered last; no departure preference |
| Order | Deterministic tied order under ride/evidence storage permutations; fixed UUID bytes/unsigned UTF-8/numeric indices; strict-prefix totality; no locale/hash/source-order dependence; no lost ties |
| Feasibility | Canonical exact chronology; valid zero-duration rides/connections; repeated stations/cycles; finite ride budget; recurring TripID prohibited twice even across dates; no inferred/reversed/infeasible/absent edge |
| Proof/pruning | Exhaustive parity; valid frontier proof; equality bound cannot hide ties; competing prefixes with different used Trips/budget; first destination/direct route not completion; no unsupported dominance |
| Resources | Evidence-backed exact/+1 work/state/memo/winner/key/payload bounds; overflow preflight before allocation; partial discovery cutoff; cap on complete tied set; cutoffs in indexing, tie collection, ordering, admission and finalization; no reset or truncation |
| Cancellation/isolation | Before entry, every bounded stage/suspension, pending cutoff/failure and terminal return; no partial output; overlapping calls independent; no detached task/MainActor work; deterministic barriers, not timeout correctness |
| Canonical admission | Existing Train/context/RouteRailProposal/WalkingTransfer/RouteCandidate/scoped constructors; sameStation no walk; exact directional walking; each local reason mapping; shared input corruption distinct from local defect |
| Outcomes/accounting | Completed zero universe scoped noResults; all admitted complete order/empty omissions; all rejected contiguous unscoped noUsableAlternatives; mixed searchIncomplete; slower/duplicate paths never omissions; no replacement winner |
| Isolation/build | Invented-only fixtures; independent oracle excluded from Release; relevant regressions and standard Release app/extension on explicit iPhone Simulator; no real/private data or runtime adoption |

### 24.10 Readiness, product-decision audit and next bounded task

Primary classification: **`P3_PRODUCTION_SOLVER_IMPLEMENTATION_NEXT`**.
Identity sufficiency, exact dedup, non-preferential order, feasibility/objective/completion,
invocation resources and canonical admission/results are sufficiently specified for a separately
authorized bounded invented-only implementation. No owner identity/policy choice or semantic
blocker remains. **`NO_NEW_PRODUCT_DECISION_REQUIRED`** for these technical mechanics; all existing
equal-optimal alternatives survive and operational limits can only fail truthfully.

Recommend one next task: explicit algorithm/cost audit and justified selection; production Data
core consuming P; immutable invocation safeguards with invented evidence-backed bounds; independent
test-only exhaustive prepared-input oracle; exact identity/dedup/order; complete winner freeze and
canonical admission; invented matrix/regressions and Release compilation; independent review.
Algorithm selection occurs inside that later task or a necessary preceding cost audit, never here.
Keep real/private data, real prepared pilot, AppEnvironment/live routing adoption and Phase-10 out.
Representative whole-pipeline workload, real policy/rights/authentication, delivery and adoption
remain later gates. P3-T1 scope incomplete / Phase 3 In Progress remains unchanged.

Exact next safe action, **not begun**:

> Separately authorize one bounded invented-only production solver implementation consuming `PreparedInternalSearchInput`: first perform an explicit algorithm/cost audit, select a justified algorithm, establish evidence-backed immutable invocation safeguards, implement exact ride-sequence identity/dedup/reproducibility ordering, optimum/all-tie completion and canonical winner freeze/admission, and prove parity with an independent test-only exhaustive prepared-input oracle using the §24.9 matrix and Release compilation. Exclude real/private data, real prepared-input pilots, AppEnvironment/live routing adoption, Journey/UI wiring and Phase-10 guidance.

### 24.11 Independent review, verification and publication

Documentation-only scope: consumer contract plus ARCHITECTURE/ROADMAP and producer current-handoff
overlay. No source/tests, algorithm implementation, route enumeration, solver invocation, runtime,
network/IO/persistence/cache code, private artifact access or device work. No tests/builds are
required or run because executable bytes are unchanged. Independent nonauthor 29-criterion review
approved **29/29 PASS**, with **zero unresolved material findings**, after independently reading
Accepted authority, exact production values, DEBUG references and the complete four-document diff.
Review explicitly checked retained-key equality/spelling, unique-connection identity sufficiency,
separate preparation/solver meters, pre-terminal cutoffs and local-versus-shared rejection mapping.
Scope/architecture/privacy drift audit and working `git diff --check` pass: exactly these four docs,
no unrelated or executable changes. The primary classification is
`P3_PRODUCTION_SOLVER_IMPLEMENTATION_NEXT`, not implemented solver or phase completion.
Final reviewed-byte/cached whitespace and exact docs-only staged scope, plus parent/ref/clean/main
checks remain publication gates. Authorized commit: `docs: define production solver execution contract`;
exactly one commit, normal push to origin/phase/03-route-search, no force or main merge.

## 25. Invented-only production prepared-input solver implementation

### 25.1 Scope lock and algorithm/cost audit (recorded before implementation)

Phase 3 remains In Progress; P3-T1 remains incomplete. This slice adds only a
request-local Data consumer of immutable P, independent invented test oracle and
verification. No runtime adoption, private input, acquisition, Journey/UI, physical
device, DEBUG synthetic contract, staging or publication is authorized here.

Selected algorithm: iterative depth-first exhaustive enumeration. A frame holds
its next ride ordinal; the current path holds unique retained ride ordinals. Each
extension scans P.rides, starts at the requested origin, uses only exact feasible
prepared directional relations, and excludes recurring TripID repetition and
length above min(profile.maximumRailRides, P.rides.count). Destination prefixes
are evaluated but remain extendable. There is no objective/dominance/station-visit
pruning, no first-destination/direct/K shortcut, no memo or Cartesian edge graph.
The universe is finite: for R rides and length bound L, at most sum(R^k, k=1...L)
sequences (this bound is never computed or allocated). Induction on frames proves
each feasible sequence is visited. Exhausting every root/frame proves zero or the
exact minimum final Date and then changes; all distinct complete tied identities
are retained. Unique retained ride ordinals implement existing key equality only
because P's constructor rejects duplicate keys; no cross-input identity reuse.

Operational cost is intentionally conservative. Work is bounded at every scan,
key lookup/equality, tie copy/dedup, comparison, reconstruction and canonical
validation. Foundation hashing/string equality and bounded snapshot constructors
receive conservative bulk charges, not claims of CPU-instruction or heap counts.
Use linear exact connection-key scans and one feasible-outgoing-endpoint flag per ride; no hash cost is hidden. A false flag soundly proves no extension exists. The DFS frontier is linear in L. Winner storage
can be exponential, so separate winner/key/retained-slot/logical-payload guards
refuse before growth. Logical allocation credits are cumulative for the entire
invocation, including obsolete incumbents, sorting scratch, legs and terminal
copies; releasing memory never refunds the meter. P's inherited logical payload
is charged once as retained input; generated copies are charged conservatively.
Variable-count products use overflow-reporting preflight; counter additions use subtraction guards. Small header/key and inherited-shape sums are bounded below Int overflow before use. A bounded
checkpoint precedes each loop operation/bulk canonical operation, checks task
cancellation, and checks again before pending failures and every terminal return.
A cutoff at any stage is searchIncomplete with no prefix output.

Ordering uses a metered insertion sort (bounded by configured winner/work caps),
retained UUID tuple bytes, unsigned UTF-8 trip/date spelling, numeric original
indices and strict sequence-prefix order. This avoids an uninterruptible opaque
sort callback. Frozen winners are then reconstructed and admitted via existing
canonical constructors. The same meter survives all stages. Explicit @concurrent
entry provides generic-executor execution under actual MainActor-default Swift
settings; state is invocation-local, with no detached tasks. Test-only fault and
checkpoint seams must be excluded from Release and cannot replace production
selection/proof. Numeric safeguards and executed evidence are recorded below
after invented boundary/stress/oracle verification; they are not deployment caps.

### 25.2 Implementation and accounting schema

Production file: `TSUGINO/Data/Routing/InternalRouteSolver.swift`. Public-to-module
entry is `InternalRouteSolver.solve(_:configuration:) async throws`, explicitly
`@concurrent`, not a RouteSearching conformance or live registration. Invalid
configuration returns configurationUnavailable; observed incompatible objective or broken
retained relation-record association returns dataUnavailable. No upstream clock,
permission, gap, allowance or requiredness is recomputed. The configuration binds
the exact closed objective definition/reference supplied with P.

The frontier is two ordinal arrays (current path and next-child frames). Unique
retained ordinals preserve Swift key equality. Each node is a unique ordinal
sequence by induction: one root scan and each next-child ordinal is visited once;
thus duplicate complete identities cannot be generated from intact P. A metered
full-array equality check additionally guards winner collection; duplicates never
become omissions. False outgoing flags exclude only prefixes with no feasible
relation from their exact endpoint. No objective pruning or generic dominance.

For R rides, C relations, L path bound, E explored prefixes, W live optimal ties,
B key bytes and S snapshot/profile validation work, worst abstract costs include
R*C outgoing scans; E*R*(C+L) expansion scans; complete-tie comparisons/copies up
to E*W*L; W²*L*B insertion ordering; and W*(L*S+L²) reconstruction/admission.
These are bounds, not expected timetable size or performance promises. No R*C
edge structure is materialized. Retained structures include P, R comparator keys
and outgoing flags, linear frontier, current/abandoned winner credits, claim and
edge scratch, legs, candidates/omissions and final result scope/batch copies.

Logical schema charges arrays by their declared elements/value payload, including
nested snapshot copies regardless of COW sharing; dynamic allocator capacity,
Foundation internal scratch and the meter's fixed four-counter/check arrays are
not measured heap bytes. Nonrefundable credits can exceed peak logical retention.
Comparator scratch charges actual key byte values three times plus headers before
copying; each complete identity charges keys and ordinals; snapshotCost reserves
4,096 credits per stop+1 for bounded native string/snapshot operations and value
copies. Profile membership receives a conservative worst collection-scan charge;
canonical duplicate-Trip validation receives L² credit. A second whole-P byte
credit overestimates final retained scope/profile copies; output snapshot copies
are charged again. No assumption of free COW or a reset after exhaustive proof.

Configuration ceilings for the **invented evaluation envelope**, allowing only
positive lower per-call limits, are 100,000,000 work credits, 1,000,000 cumulative
retained slots, 256 simultaneously retained winner identities, 16,384 cumulative
winner-key credits and 268,435,456 logical bytes. They are independent operational
safeguards, not a new product horizon/ride preference. Refusal occurs before any
counter update/growth if a charge exceeds the remaining allowance; products use
overflow-reporting multiplication. Negative/zero/above-ceiling configurations fail
configurationUnavailable. An overflowed internal charge fails searchIncomplete.
There is no memo allocation; no unguarded memo dimension is implied.

Checkpoints precede every search scan, relation equality, tie comparison/copy,
ordering byte/shift, admission loop and finalization charge. Native canonical
constructors are bounded bulk operations bracketed by cancellation checks, not
per-instruction cancellable calls; the terminal scoped constructor spans at most
the validated winner/key/payload envelope. No wall-time cancellation-latency bound
is claimed. All failures cross a final Task.checkCancellation guard; observed
cancellation wins over configuration/data/cutoff/rejection and before return.
No detached task, shared mutable state or wall-time proof exists.

DEBUG-only checkpoints/copy-claim mutation/shared-record-index corruption and
comparator adapter exercise otherwise unreachable defensive failures. They do
not provide production callers with completion/winner claims, and are absent
from Release. Corruption changes actual copied token/key/context/chronology/
transition/accounting fields, rather than asking the solver to return a chosen
reason. The classifier reuses P, applies canonical priority, then uses existing
RouteRailProposal, WalkingTransfer, RouteCandidate and scoped result constructors.

### 25.3 Invented verification and safeguard evidence

Final author and independent verification passed. The independent oracle is
only in the test target, recursively scans all rides/relations, materializes all
complete paths and only then separately selects minimum arrival/change and orders
identities. It shares neither DFS frames, incumbents, pruning nor winner selection
with production. Its limit is 16 invented rides; it is not a deployment fallback.


Generated shapes use artificial IDs, opaque invented day labels, elapsed instants
and zero-pattern UUIDs only. Observed final invocation credits (not heap/RSS):

| Invented complete shape | Winners | Work | Cumulative slots | Winner keys | Logical bytes |
|---|---:|---:|---:|---:|---:|
| Two direct ties / exact whole-call boundary | 2 | 165,952 | 61 | 2 | 99,902 |
| 32 direct ties, reverse discovery order | 32 | 3,603,771 | 5,176 | 32 | 1,765,220 |
| 128 direct ties, reverse discovery order | 128 | 27,193,434 | 75,976 | 128 | 10,516,484 |
| 256 direct ties, reverse discovery order | 256 | 88,479,312 | 299,400 | 256 | 30,299,012 |
| Two layers, width three, oracle parity | 9 | 2,446,195 | 395 | 18 | 789,608 |
| Three layers, width three, oracle parity | 27 | 17,180,614 | 1,535 | 81 | 3,312,125 |
| Four layers, width three, oracle parity | 81 | 95,791,173 | 6,185 | 324 | 12,908,616 |

All four-layer winners completed; no cutoff is inferred from its near-ceiling work.
The 100M ceiling admits the observed 95.79M branching shape with finite headroom;
256 winner ceiling admits the complete measured direct tied set, while actual 257
same-objective identities refuse with searchIncomplete before ordering. Slot/key/
payload ceilings are deliberately conservative independent secondary guards above
the observed 299,400 slots/324 keys/30,299,012 bytes. They were validated at exact
ceiling and +1 using the real meter, not actual whole-invocation maximum shapes.
The slot ceiling is about 3.34× the observed direct-tie slots; 16,384 key
credits deliberately permit substantially more identity elements than the observed
324 while independently bounding growth. 256 MiB allows roughly twice the
inherited 96,000,000-byte P ceiling plus generated-copy headroom; it does not
assert that a maximum P can pass the independent 100M work guard. They do not
establish support for every combination of those ceilings. The small
whole-call observation was rerun with each exact used limit, then one less credit
(actual demand = limit+1); exact succeeds and each +1 demand refuses atomically.
Negative/zero/Int.max configuration dimensions and multiplication overflow refuse.
Real work ceilings set from deterministic stage snapshots force refusal during
indexing, exploration, tie collection, ordering, admission, finalization and terminal
entry; DEBUG injected cutoffs separately verify containment. Cancellation barriers
cover every stage, before invalid configuration, pending cutoff and final return;
overlapping calls retain independent state and actual hooks execute off-main.
No elapsed-time threshold determines correctness or completion.

Final 26-function / 55-case solver matrix includes minimum arrival then genuine
changes, direct/transfer alternatives, best-last, all tied branches, no departure
preference, dated recurring ID prohibition, zero-duration station revisit/cap,
no inferred/reversed/absent/infeasible edge, directional walk/sameStation canonical
legs, original repeated-visit numeric indices and through service, retained
Unicode-equivalent ID/date distinctions, storage/evidence permutations, UUID/
unsigned-UTF8/numeric/prefix comparator branches, all seven local rejection reasons
and priority, shared objective/projection failures, all-rejected contiguous
omissions, mixed incomplete/no slower replacement, raw-error containment,
exact/+1/overflow meters and independent exhaustive parity. Equality-bound loss is
excluded by exhaustive traversal with no objective bound; duplicate identities are
structurally impossible in unique-ordinal DFS and independently checked by oracle
identity dedup/parity plus defensive full-array winner equality. Equal keys cannot
coexist in P; the DEBUG comparator adapter explicitly resolves equal key claims to
one retained representative rather than inventing byte-distinct identity.

Exact author commands (cwd `/Volumes/Data/dev/TSUGINO`; no physical destination):

```sh
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-solver-dd build-for-testing
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-solver-dd -resultBundlePath /private/tmp/tsugino-solver-first.xcresult -only-testing:TSUGINOTests/InternalRouteSolverTests test
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-solver-dd -resultBundlePath /private/tmp/tsugino-solver-regression.xcresult -only-testing:TSUGINOTests/InternalRouteSolverTests -only-testing:TSUGINOTests/PreparedInternalSearchInputTests -only-testing:TSUGINOTests/InternalSearchScopeTests -only-testing:TSUGINOTests/InternalSearchSuccessTests -only-testing:TSUGINOTests/RouteAdmissionTests -only-testing:TSUGINOTests/RoutingValueTests -only-testing:TSUGINOTests/TimetableRideContextTests -only-testing:TSUGINOTests/QualifiedConnectionEvidenceTests -only-testing:TSUGINOTests/RequestScopedSearchInputClosureTests -only-testing:TSUGINOTests/TimetableOccurrenceInventoryTests test
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-solver-dd -resultBundlePath /private/tmp/tsugino-solver-final-focused.xcresult -only-testing:TSUGINOTests/InternalRouteSolverTests test
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-solver-author-release-dd build
```

The initial build-for-testing failed at Swift compilation because a method returned
a nested private Admission type; corrected its visibility before the first passing
test run. The first focused iteration passed **18 functions / 43 cases**. Combined regressions passed **218
functions / 478 cases**, including an intermediate solver test binary of 24/53;
nine unchanged regression suites account for **194/425**. The final frozen source/
tests were separately rerun: author **26/55 PASS**, independent **26/55 PASS**, zero
failures/skips/runtime warnings. Do not describe the intermediate combined run as
having executed the final two added test functions. Final standard Release app and
embedded TSUGINOLiveActivity extension compilation passed for both authorship and
independent builds. Existing unrelated asset/Codable isolation diagnostics remain;
no new solver-source/test diagnostic is present in final runs. Release source and
symbol inspection confirms DEBUG hooks/comparator adapter and test-only oracle
are absent from the production executable.

Author logs: `/private/tmp/tsugino-solver-compile.log`, `...-first.log`,
`...-regression.log`, `...-final-focused.log`,
`/private/tmp/tsugino-solver-author-release.log`; corresponding xcresults above.
Final extracted stdout is under `/private/tmp/tsugino-solver-final-diagnostics`.
The optional xcresult console-log view was unavailable; diagnostic export supplied
resource observations successfully. Temporary logs/results are local evidence,
not durable committed artifacts; the table/commands/review here persist the result.

### 25.4 Independent review, drift audit and handoff

Independent non-author Codex agent `production_solver_independent_review` read the
owner request/current authority and final implementation. It did not author/edit
source, tests or documents; it used a separate simulator and DerivedData for fresh
verification. This is a separate agent in the same Codex environment, not a blinded
external/vendor review. Source SHA-256:
`f8670cac25baf9a98238fdcbcf2900668ddc10907efe3818e1cdfa0c565c6627`;
test SHA-256:
`b51cb430b152e4832bc67e5e757eaeb9831728ada04a2c1395252e6bc98317b4`.

Review covered algorithm/finite universe/full-root and destination-extension proof,
all ties/key equality/retained order, feasibility/cap/recurring identity, metered
native/scratch/output copies and config bounds, cancellation and actual isolation,
canonical admission priorities/shared faults/all outcomes, independent oracle and
matrix evidence, Release exclusion and scope/Git discipline. Material incremental
findings on comparator scratch value copies, final scope/output copies, membership/
canonical duplicate checks and bounded terminal cancellation were resolved in the
final bytes. No unresolved material implementation finding remains. Final independent verdict:
**36/36 criteria PASS**, including final eight-file documentation/Git drift audit.
The reviewer independently parsed author result bundles and observed identical
final resource figures. Exact independent commands (same repository cwd):

```sh
xcodebuild test -project TSUGINO.xcodeproj -scheme TSUGINO -destination 'platform=iOS Simulator,id=BACE309E-6EE1-44B4-9826-4FFA91368F9B' -derivedDataPath /private/tmp/tsugino-solver-independent-dd -only-testing:TSUGINOTests/InternalRouteSolverTests -resultBundlePath /private/tmp/tsugino-solver-independent-focused.xcresult
xcodebuild build -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=BACE309E-6EE1-44B4-9826-4FFA91368F9B' -derivedDataPath /private/tmp/tsugino-solver-independent-release-dd
```

Independent logs: `/private/tmp/tsugino-solver-independent-focused.log` and
`/private/tmp/tsugino-solver-independent-release.log`; diagnostics:
`/private/tmp/tsugino-solver-independent-diagnostics`. Fresh final focused 26/55
and standard Release app/extension both passed. The review's 36 gates span
scope/authority (1–4), finite search/identity/objective/proof/order (5–17),
configuration/meter/overflow/evidence/cancellation/isolation (18–27), frozen
canonical admission/classification/outcomes (28–32), independent oracle/matrix/
fresh verification (33–35) and final docs/Git drift (36).

A final precedence audit confirmed that compatibility itself is metered. If a
charge is exhausted before a shared incompatibility can be observed, the call
returns searchIncomplete without certifying compatibility. An observed shared
fault is dataUnavailable; no unmetered fault-probing stage or fault-over-cutoff
precedence is invented. Observed cancellation remains the explicit overriding
precedence in §24.6.

Primary classification:
**`P3_INVENTED_PRODUCTION_PREPARED_SOLVER_IMPLEMENTED_AND_INDEPENDENTLY_APPROVED`**.
No new product decision was required. The eight-file diff adds only one Data solver,
three invented test/support files and consumer/producer/architecture/roadmap truth.
Domain/upstream/preparation/DEBUG synthetic contracts, dependencies, persistence,
UI/Journey and runtime wiring are untouched. *Historical publication state at review
time (superseded by §26.1: published at `4df37d5cfcb9ab81106257b21855169450f72c46`):*
worktree changes were unstaged and uncommitted; HEAD/upstream remained `05ea2cf463e3b88f14e81a7fc5055cff5c06e678`,
main/origin-main `e8a463d51f14b3cb1027960c63244b694579a71b`, divergence 0/0.
No commit/push/merge, private input, provider acquisition or physical-device work.

Remaining gates: real prepared-input qualification/pilot authority, source/legal/
coverage completeness, versioned runtime policy resolution, measured end-to-end
preparation+solve/cancellation/heap/performance suitability, Application lifecycle
and RouteSearching/runtime adoption. Exhaustive enumeration is exponential and
bounded refusal is expected outside this invented evaluation envelope. No automatic
retry or slower replacement is supplied. P3-T1 stays scope-incomplete; Phase 3 stays
In Progress, live/default routing unconfigured. Next safe action (historical; completed
by publication at `4df37d5`) was review of this uncommitted diff and a separately
authorized publication slice; no real pilot or runtime wiring is implied by this
implementation verdict. Current readiness and next task: §26.

## 26. Post-publication readiness audit — 2026-10-14

Documentation-only, owner-authorized. No source/tests change, solver execution, performance
experiment, test/build rerun, private-artifact access, provider acquisition, physical-device
interaction or runtime/AppEnvironment/Journey/UI/Phase-10 work. P3-T1 remains scope-incomplete;
Phase 3 remains **In Progress**; live/default routing remains unconfigured.

Evidence labels: **[V]** directly verified in this checkout on 2026-10-14 by repository/Git
inspection; **[H]** historical recorded evidence (supplied or reported earlier, not re-executed
here); **[U]** unknown or not checked. Invented work credits and logical bytes are not elapsed
time, measured heap/RSS or representative deployment evidence. Exhaustive DFS correctness
(§25) does not establish acceptable performance at real timetable scale.

### 26.1 Checkout and publication reconciliation

- **[V]** Audit checkout `/Users/byungjin/TSUGINO` (an internal copy; the earlier external-drive
  checkout was not accessed). `.git` is a self-contained directory: no `gitdir` indirection,
  no object alternates, one worktree, and local config contains no external-drive path.
  Connectivity check reported no missing objects (dangling objects only). Origin is
  `https://github.com/lunalism/TSUGINO.git`.
- **[V]** Branch `phase/03-route-search`; HEAD = upstream = live remote branch =
  `4df37d5cfcb9ab81106257b21855169450f72c46`; local/tracked/live main =
  `e8a463d51f14b3cb1027960c63244b694579a71b`; divergence 0/0; clean worktree/index; no
  non-ignored untracked files before this audit's documentation edits.
- **[V]** Commit `4df37d5` message `feat: add bounded prepared internal route solver`, parent
  `05ea2cf463e3b88f14e81a7fc5055cff5c06e678`, exactly eight files and 1,405 insertions/0
  deletions: `TSUGINO/Data/Routing/InternalRouteSolver.swift`,
  `TSUGINOTests/InternalRouteSolverTests.swift`,
  `TSUGINOTests/Support/ExhaustivePreparedSolverOracle.swift`,
  `TSUGINOTests/Support/InternalSolverFixtures.swift`, `docs/ARCHITECTURE.md`, this proposal,
  `docs/PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md` and `docs/ROADMAP.md`. The committed solver
  source and test file SHA-256 values equal the reviewed values recorded in §25.4.
- **[H]** §25.3–§25.4 author/independent verification (final 26/55 focused, Release app/
  extension) was executed on 2026-10-10 from the earlier checkout path; its `/private/tmp`
  logs/result bundles were not reopened. **No test or build was run on this checkout.**

### 26.2 Readiness matrix

| Gate | Status | Evidence and references | Missing evidence / unresolved dependency | Smallest next action | Authorization class |
|---|---|---|---|---|---|
| G1 Real-data/source qualification, rights, coverage | **Not ready.** Partial real evidence; recorded rights holds | [H] one real static revision / S9 Trip / dated occurrence / interval `0...13` only ([producer §18](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md#18-first-real-production-occurrence-inventory-pilot--2026-10-10)); [H] P2-S9 remains incomplete beyond the pilot: for that one reviewed Trip only, classification gaps went 14 → 0 and source order was resolved (ROADMAP "Owner-reported same-candidate occurrence review — 2026-10-08"), followed by station crosswalk, canonical Trip registration and S9 snapshot selection (ROADMAP 2026-10-08/2026-10-09 checkpoints). Recurring-run identity, movement/endpoint, registration and final-acceptance gates remain for every other candidate and for launch coverage, and the pilot's origin/destination stay `unknownExtent`. Earlier consumer §16.1/§18.3 "14 + 14 gaps" text is historical. [H] ODPT: the October 3 Toei interpretation inquiry was answered (reply 2026-10-05; follow-up answers 2026-10-08; owner-accepted retained Toei interpretation profile, ROADMAP 2026-10-05/2026-10-08 checkpoints). Those replies grant no publication, translation, retention or bundling rights. The 2026-09-19 rights inquiry (Q2 caching/offline use, Q3 non-restorable canonical data/publication, Q4 translation, Q6 termination deletion; PROVIDER_FEASIBILITY_AUDIT §3.12) has no recorded reply ("unanswered" in DECISIONS DEC-068 context, 2026-09-28; no later reply found in the repository; consumer §16.3/§18.1 holds). Permanent binary bundling (audit §3.12 item 5) was not asked and remains unresolved; [V] no production code constructs a real closure/evidence/assessment or P (only value types and tests reference them) | Launch-scope (15-service) inventory/calendar/interval coverage; real directional connection relations and allowance applicability (consumer §16.1 transfers row) — source availability **[U]**, not a verified blocker; rights for retention/bundling/delivery (recorded hold) | After G2 design: a separately authorized bounded real direct/complete-empty-connection prepared-input pilot (consumer §22.6), or source identification for connection evidence | Private-data authorization; source/rights review; written ODPT confirmation covering retention/offline use and permanent binary bundling (audit §3.12 item 5, not yet asked) before bundling. Technical qualification itself needs no new product decision |
| G2 Prepared-input producer and policy readiness | **Values ready (invented); producer absent** | [V] `PreparedInternalSearchInput`, `ResolvedSearchInputAssessment`, `RequestScopedSearchInputClosure`, `QualifiedConnectionEvidence`, `TimetableOccurrenceInventoryView` exist only as Data values; no Data/App/Application caller derives them from a `RouteSearchRequest`; [H] the E2 one-atomic-capture-per-call rule is owner-accepted (consumer §19; ROADMAP 2026-10-05), while the production capture API, current-view supplier and versioned immutable policy resolution remain Proposed (consumer §18.2, §22.1–§22.5); DEC-080 P5 and production horizon/ride cap deferred | Request→scope derivation, single view capture, inventory/connection supplier, policy resolution owner and contents, stage failure mapping | **Recommended §26.4:** documentation-only production preparation→solve composition contract | Docs design: none beyond this kind of authorization. Implementation: implementation authorization. Production horizon/ride-cap values: owner product decision |
| G3 Representative workload shape; preparation + solve measurement | **Not started; shape unknown** | [H] §25.3 invented shapes only; §16.2 defines evidence classes and measurement plan; [H] §25.2 worst costs are exponential bounds (sum of R^k), not expected timetable size | Source-derived structural aggregates (dated rides per scope, connection density/fan-out, branching, tie multiplicity, key/output size); justified sampling frame; end-to-end preparation+solve harness | Workload-frame/measurement protocol design after G2's stage boundaries are fixed | Frame design: none. Structural extraction: private-data authorization. Harness: implementation authorization |
| G4 Actual runtime, heap/memory, cancellation responsiveness | **Unmeasured** | [V] meter comment states credits bound logical storage/work, not allocator bytes or CPU time (`InternalRouteSolver.swift`, `InternalSolverMeter`); [H] no wall-time cancellation-latency bound claimed (§25.2); no elapsed/heap/RSS figure exists for preparation or solver | Elapsed time, peak memory, cancellation latency for preparation+solve, Simulator then physical iPhone | Follows G2/G3; no measurement now | Simulator measurement and harness design: experiment/implementation authorization only. Physical-iPhone measurement additionally requires explicit physical-device authorization (AGENTS §22) |
| G5 Runtime configuration and policy resolution | **Invented envelope only; production values unselected** | [V] `InternalSolverExecutionConfiguration.inventedEvaluation` and meter validation hard-cap at 100,000,000 work / 1,000,000 slots / 256 winners / 16,384 keys / 256 MiB; larger configurations fail `configurationUnavailable`; no App/Application code selects a solver configuration; [H] the invented four-layer shape used 95.79M of 100M credits and §25.4 expects bounded refusal outside the envelope; `NUMERIC_PRODUCTION_SOLVER_LIMITS_REQUIRE_IMPLEMENTATION_EVIDENCE` (§24.6) | Production profile/horizon/ride cap; budget values from G3/G4 evidence; selection owner (Application per §24.7) | Depends on G2 contract, then G3/G4 evidence | Horizon/ride cap: product decision. Numeric safeguards: technical, evidence-backed, implementation authorization |
| G6 Application lifecycle and future RouteSearching composition | **Lifecycle implemented; composition absent** | [V] `RouteSearchCoordinator` and `RouteSearchCoordinatorTests` exist; `AppEnvironment.live()` passes `routeSearching: nil` → `.notConfigured`; `InternalRouteSolver` is documented as not conforming to `RouteSearching` and takes P, while `RouteSearching.search` takes `RouteSearchRequest`; [H] DEC-087 implementation approved (§12.9); E2 capture is test-only/DEBUG (§19.6–§19.7) | Data `RouteSearching` conformer composing capture → preparation → solve; cancellation and failure precedence across both; view replacement mid-call | Same G2 composition contract | Docs: none. Conformer: implementation authorization. AppEnvironment injection/enablement: separate explicit authorization |
| G7 Deployment suitability; remaining Phase 3 exit | **Not met** | [H] Phase 3 exit "usable canonical journey plan for supported Tokyo routes" and decision gate (data quality, pricing, licensing, trip identity, mapping stability) in ROADMAP Phase 3; DEC-086 R6 deployment/ownership Proposed; `P3_T1_FIRST_REAL_IMPORT_ACCEPTED_BUT_SCOPE_INCOMPLETE` | G1–G6; real coverage; device evidence; rights | None directly; phase audit only after gates close | Owner product decisions (R6, suitability); rights; device authorization |

**Verified blockers** (directly verified or explicitly recorded holds): no production preparation/
composition code; solver configuration hard-capped at the invented envelope; live routing nil;
recorded ODPT/S9/P3-T1 holds; Phase 3 exit unmet. **Unknown, not verified blockers:** availability
of qualified real connection evidence; real workload shape; whether exhaustive DFS completes within
any acceptable budget at real scale; device elapsed/memory/cancellation behavior.

### 26.3 Selection rationale

Real-data pilots need private authorization and, per §22.6, a defined preparation path; invented
performance measurement would not be representative; algorithm optimization before workload
evidence violates AGENTS §18. The missing request→prepared-input→solver composition blocks G2,
G5 (who selects configuration and policy), G6 and the stage boundaries a G3/G4 measurement must
instrument, and it can proceed without private data or product choices.

### 26.4 Recommended next bounded task — not begun

**Production route-search preparation→solve composition contract (documentation only).**

- **Scope:** define the future Data `RouteSearching` conformer seam: entry cancellation and
  configuration/profile preflight; single immutable view capture (reusing accepted E2, §19);
  request→`InternalSearchScope` derivation from an injected immutable policy (horizon, ride cap,
  objective) without choosing values; inventory → B closure → A evidence → assessment → P → solver
  sequencing with owners; separate preparation safeguards and solver meter (§24.6); failure
  precedence (`configurationUnavailable`/`dataUnavailable`/`searchIncomplete`/cancellation) across
  stages; concurrent calls and view replacement; stage boundaries for future end-to-end
  measurement; where Application selects runtime configuration. Preserve unchanged DEC-087
  Application task lifetime, retry intent and publication/superseded-response guards; §24.6–§24.8
  escape rules (only `RouteSearchFailure` or `CancellationError`), no partial/best-so-far output,
  and canonical admission.
- **Prerequisites:** published `4df37d5` checkpoint; Accepted DEC-076/078/079/087, the Accepted parts of DEC-080/DEC-086, and accepted §19 E2;
  no private data.
- **Completion:** reviewed contract section with invented filled/missing-evidence examples,
  explicit list of owner decisions it exposes (production horizon/ride cap, R6) without making
  them, future invented test matrix, independent non-author review, `git diff --check`, docs-only scope.
- **Exclusions:** source/tests, conformer implementation, AppEnvironment injection, real/private
  data or pilots, measurements, numeric limits, Journey/UI, physical device, Phase-10.

Secondary candidate after that contract: the G3 workload-frame/measurement protocol design.

*Status update (2026-10-14):* this recommended contract is now drafted in
[§27](#27-requestpreparationsolver-composition-contract--2026-10-14); the "not begun" heading above
records the state when §26 was published.

## 27. Request→preparation→solver composition contract — 2026-10-14

### 27.1 Status, authority and boundary

Documentation-only, owner-authorized from published checkpoint
`df031dc05fe7fb4881b0441f824baea09b3e0b83` (§26.4). It specifies a **future** Data-owned
`RouteSearching` conformer from `RouteSearchRequest` to canonical `RouteSearchResult`. Nothing here
implements a producer, conformer, supplier or test; enables live routing; selects numeric limits;
or establishes runtime, memory, cancellation-latency or deployment suitability. No tests, builds,
solver runs, measurements, private artifacts or devices were used. P3-T1 remains scope-incomplete;
Phase 3 remains **In Progress**; live/default routing remains unconfigured.

Three classes are kept distinct throughout:

- **[A] Accepted requirement.** DEC-076 port/failure vocabulary; DEC-079 owner-accepted preflight
  order configuration → shared-view validity → endpoints → profile intent/bounds → required
  coverage, with observed cancellation first and no lower-priority probing (DECISIONS DEC-079
  "Owner acceptance", accepting consumer §§2–5; failure table and preflight list in consumer
  §3); Accepted parts of DEC-080 (V1–V7: full profile, inclusive `L`/`U = L + duration`,
  scoped success); Accepted parts of DEC-086 (objective, all equal optima, truthful cutoff →
  `searchIncomplete`, unknown required evidence → `dataUnavailable`); DEC-087 Application
  lifecycle; owner-accepted E2 capture/replacement (§19 scoped acceptance, ROADMAP 2026-10-05).
- **[I] Published implemented technical contract.** §24 solver execution contract as implemented
  in §25 (reviewed and published; `NO_NEW_PRODUCT_DECISION_REQUIRED`, not owner product acceptance),
  including the separate solver meter and §24.8 terminal mapping.
- **[P] Proposed technical composition.** This section's stage design, ownership placement and
  typed-failure mapping. It needs review and separate implementation authorization.
- **[O] Open choice.** Listed in §27.9, split into product semantics and implementation choices.

### 27.2 Existing interfaces verified read-only (2026-10-14)

| Stage input/output | Existing type and constructor | Failure surface | Cancellation inside |
|---|---|---|---|
| Port | `RouteSearching.search(_: RouteSearchRequest) async throws -> RouteSearchResult` (Domain) | `RouteSearchFailure` or `CancellationError` only | Caller task |
| Request | `RouteSearchRequest.init?(origin:destination:departNotBefore:)` — distinct endpoints, finite instant | Constructed by caller; invalid requests never reach the port | — |
| Profile/policy | `InternalSearchProfileDefinition.init?(identity:stations:lines:trips:maximumElapsedDuration:maximumRailRides:connectionPolicy:serviceDateInterpretation:)`; `InternalSearchPolicyReference` is a key/revision pair that "does not resolve, authorize or authenticate" policy | `nil` | — |
| Scope | `InternalSearchScope.init?(profile:request:viewID:)` — endpoints in profile stations, exact finite `L+duration` | `nil` | — |
| Static revision / endpoints | `RailwayArtifactRevision`; Domain `RailwayDataRepository.station(id:) async throws -> Station?` (actor `SQLiteRailwayRepository`) | `RailwayRepositoryError`; existence only | Suspends (actor) |
| Occurrence inventory | `TimetableOccurrenceInventoryView.init(qualification:declaredAddresses:completeness:suppliedSlots:) throws(TimetableInventoryConstructionFailure)` | `resourceLimit`, conflicts | **None** (synchronous) |
| Request closure (B) | `SearchInputClosureApplicability.init(reference:scope:qualification:)`; `RequestScopedSearchInputClosure.init(scope:inventory:railway:occurrences:connections:dependencies:) throws(SearchInputClosureConstructionFailure)`; `holds`, `isTechnicallyQualified` | `resourceLimit`, conflicts; holds are values, not throws | **None** |
| Connection evidence (A) | `ConnectionEvidenceQualification.init(applicability:policy:review:)` (policy must equal profile `connectionPolicy`); `ConnectionEvidenceState.qualifyingPositive/qualifyingAbsence`; `QualifiedConnectionEvidenceView.init(qualification:declaredKeys:completeness:records:)` | `ConnectionEvidenceFailure` | **None** |
| Assessment | `ResolvedSearchInputAssessment.init(closure:connections:) throws(ConnectionEvidenceFailure)`; `remainingHolds`, `isTechnicallyQualified` | as above; holds are values | **None** |
| Prepared input | `InternalRouteObjectiveDefinition.init(reference:)` (version `acceptedDEC086V1`); `PreparedInternalSearchInput.init(assessment:objective:) throws(PreparedInputFailure)` | `resourceLimit`, `assessmentNotQualified`, `permissionUnknown`, `exactEventMissing`, conflicts | **None** |
| Solver | `InternalRouteSolver.solve(_:configuration:) async throws` (`@concurrent`; does **not** conform to `RouteSearching`); `InternalSolverExecutionConfiguration` (validation ceilings = invented envelope) | `RouteSearchFailure`/`CancellationError` only; incompatible objective → `dataUnavailable`; invalid configuration → `configurationUnavailable` | Metered checkpoints at every stage (§25.2) |
| Lifecycle | `RouteSearchCoordinator` (MainActor owner, DEC-087); `AppEnvironment.makeRouteSearchCoordinator()` → `.notConfigured` while `live()` passes `routeSearching: nil` | — | Owns Task |

DEBUG precedent only (not production API): `SyntheticOptimalRouteSearcher` takes immutable
configuration at construction plus an optional `captureView` closure and runs
cancellation → configuration → capture → view validity/policy match → endpoints → scope
(`unsupportedRequest`) → coverage, mapping unknown errors to `dataUnavailable` after a final
cancellation check. The production conformer may reuse this **pattern**, not these types.

### 27.3 Proposed stage sequence [P]

One invocation of a future `nonisolated` conformer with an explicitly `@concurrent search`
(required because the app target defaults to MainActor isolation, §19.1). Every arrow is a
cancellation checkpoint; each stage stops the call at its first failure (§27.5).

| # | Stage [A]-ordering slot | Inputs | Output | Missing seam (does not exist today) |
|---|---|---|---|---|
| S0 | Entry | request, conformer's immutable bindings | — | Conformer type |
| S1 | Configuration (DEC-079 1) | immutable profile definition, objective reference, `InternalSolverExecutionConfiguration`, supplier present | validated bindings | **Resolved immutable policy contents** behind each `InternalSearchPolicyReference`; a production configuration source; a pre-load validator equivalent to the `InternalSolverMeter` ceilings plus a check that `configuration.objective` has the same definition as the bound objective (→ `configurationUnavailable`), so the S9 objective-mismatch `dataUnavailable` is unreachable for a valid configuration |
| S2 | Capture (E2) | supplier | one whole immutable captured view `V` | **Current-view supplier** with a non-suspending linearized read returning one whole value; the production view type |
| S3 | Shared-view validity (DEC-079 2) | `V`, S1 bindings | `V` accepted for this call | View validity interval/invalidation fields; correspondence of `V`'s policies with profile `connectionPolicy`/`serviceDateInterpretation` |
| S4 | Endpoints (DEC-079 3) | request, captured `V` | origin then destination resolved | **Endpoint dispositions inside `V`.** DEC-079 validates endpoints "against that view" and E2 forbids separately read pieces or reloads, so dispositions must come from `V` itself (or a revision-pinned identity component retained as part of `V` for the call's lifetime), never a post-capture read of a shared mutable source. Today the Domain port's `station(id:)` reports existence only; the concrete actor's full-load `identities()` exposes retired status but no keyed conflicting/unsupported disposition, and neither is on a captured value |
| S5 | Intent/bounds (DEC-079 4) | profile, request, `V.viewID`, validity interval | `InternalSearchScope` | None for construction; window-within-validity check needs S3's seam |
| S6 | Closure (B) | scope, `V.inventory`, `V`'s railway revision, **request-relative declarations** | `RequestScopedSearchInputClosure` | **Request-relative required-domain declaration producer** (occurrences, intervals, connection targets, dependencies) bound by `SearchInputClosureApplicability` to this exact scope; **dependency-resolution authority**: the closure records `dependencyUnresolved` for every declared dependency and the assessment clears only `connectionUnresolved`, so today only an empty dependency declaration can qualify |
| S7 | Connection evidence + assessment (A) | closure's connection targets, `V`'s connection authority, profile `connectionPolicy` | `QualifiedConnectionEvidenceView`, `ResolvedSearchInputAssessment` | **Request-scoped connection-evidence producer** that builds records via the checked state factories from `V`, without deriving requiredness |
| S8 | Prepared input | assessment, objective definition | `PreparedInternalSearchInput` | None (exists) |
| S9 | Solve | P, execution configuration | `RouteSearchResult` | None (exists) |
| S10 | Return | result | final cancellation check, return | — |

Coverage (DEC-079 5) is S6–S8 jointly: technical qualification of B, A and P is the coverage
proof (with any nonempty dependency declaration necessarily unqualified until a resolution
authority exists); only then does solving start. `V.inventory` is part of the captured shared view, built and
validated by the supplier before publication, not per request; a supplier that cannot build a
valid inventory publishes no usable view (capture outcome → `dataUnavailable` at S3).

The conformer only sequences and maps. It does not reinterpret service dates, eligibility,
continuity, allowances, gaps or requiredness; those remain owned by the existing constructors and
by the producers named above. The solver keeps consuming only P (§24.1).

### 27.4 Ownership, bindings and safeguards

| Concern | Owner [P] unless marked | Basis |
|---|---|---|
| Current immutable view and its replacement | Data supplier; App composition root injects it into the conformer | §18.2, E2 [A] |
| Profile definition, policy references, objective reference, execution configuration | Bound immutably to the conformer at construction for the port's lifetime; values chosen by an owner-approved configuration, injected by App | [P]. Reconciles §24.7 ("Application retains … runtime profile/configuration selection") by treating Application/App selection as choosing which configured conformer is composed. §19.2's port-lifetime immutability was scoped to the smallest experiment, so production port-lifetime binding is Proposed here. The existing port has no per-request profile parameter; per-request selection would need a port change [O] |
| Request-relative declarations, connection evidence | Data producers reading only the captured `V` | §20 B authority, §21 A authority [A] |
| Task lifetime, retry intent, superseded-response suppression, publication | Application `RouteSearchCoordinator` | DEC-087 [A] |
| Canonical admission, terminal outcomes | Solver (§24.8), unchanged | [A] canonical admission (DEC-076/079); §24.8 terminal mapping [I] |

**Safeguards.** Preparation retains its existing construction safeguards (inventory, closure,
connection and prepared-input limits, all logical-payload accounting) and the solver keeps its
own uninterrupted invocation meter starting at acceptance of P (§24.6 [I]; Accepted DEC-079/086
cutoff duties [A]). They are not merged,
summed or reset into a common unit, and no end-to-end hard budget exists or is proposed here.
Execution configuration affects only whether completion can be proved, never semantics.

**Measurement boundaries (future, not established).** A later authorized harness may timestamp
S0, S1/S2 end, S3–S5 end, S6, S7, S8 and S9 end, and S10, reporting stage elapsed time, logical
payload per stage, solver meter usage and peak memory if reliably measurable — separately, never
summed into one budget (§16.2). Capture latency and supplier-side view construction are separate
measurements. No hardware, numeric target or Simulator-to-device equivalence is implied.

### 27.5 Failure mapping and cancellation precedence

Cancellation: check at S0, after S2 resumption, after S4 if it suspends, between
S5/S6/S7/S8, inside S9 (solver's own checkpoints) and at S10, and before throwing any pending
non-cancellation failure. Once observed, `CancellationError` wins [A]. S6–S8 are **synchronous,
non-cancellable bounded constructors** (verified: no cancellation checks in those files); a
cancellation arriving during one is observed only at the next checkpoint. No latency is claimed;
if later measurement shows unacceptable stretches, bounded partitioning needs separate review
(§19.3).

| Stage / observation | Outcome | Class |
|---|---|---|
| S1 missing/invalid profile, unresolved policy contents, missing supplier, invalid execution configuration | `configurationUnavailable`; no data is loaded to confirm lower faults | [A] order; [P] detection |
| S2/S3 no view, invalid validity, policy/revision mismatch, inconsistent whole view | `dataUnavailable` | [A] |
| S4 origin, then destination: conflicting → retired → unknown → unsupported, from dispositions in `V` | `invalidEndpoint(role, reason)`; a `V` unable to support endpoint validation fails earlier at S3 as `dataUnavailable` | [A] |
| S5 `InternalSearchScope` init `nil` (endpoint outside profile, horizon not exactly representable) | `unsupportedRequest` | [A] (consumer §3 table) |
| S5 scope window outside captured-view validity | `unsupportedRequest` proposed (DEC-081 synthetic precedent); `dataUnavailable` alternative (§3 "expired/insufficiently covered") | [P]; user-visible category is an [O] product choice (§27.9) |
| S6–S8 conflicts (`scopeConflict`, `qualificationConflict`, `staticRevisionConflict`, `declarationConflict`, `snapshotConflict`, `intervalConflict`, `profileConflict`, `connectionTargetConflict`, `policyConflict`, `targetConflict`, `formConflict`, `trainChangeConflict`, `allowanceConflict`, `applicabilityConflict`, `endpointConflict`, `accountingConflict`, `occurrenceConflict`, `canonicalRideConflict`, `arithmeticConflict`) | `dataUnavailable` | [P], from [A] "contradictory input" |
| Assessment `remainingHolds` non-empty; `assessmentNotQualified`; `permissionUnknown`; `exactEventMissing` | `dataUnavailable`, even if a usable direct ride exists | [A] (DEC-086 unknown required evidence) |
| S6–S8 `resourceLimit` over otherwise consistent input | `searchIncomplete` | [P] from [A] truthful cutoff; any other category needs owner confirmation (§27.9) |
| S9 | Unchanged §24.8 terminal outcomes [I] with Accepted cutoff/evidence duties [A]: scoped `noResults` only after proved empty universe; scoped alternatives; unscoped `noUsableAlternatives`; mixed → `searchIncomplete`; cutoff → `searchIncomplete` | [I] mapping; [A] duties |
| Any other internal error | final cancellation check, then `dataUnavailable` | [P], matches §24.7 |

Typed preparation failures are mapped **explicitly before** the generic catch, so a
`resourceLimit` is never silently reported as `dataUnavailable`. Only `RouteSearchFailure` or
`CancellationError` escapes; no partial, best-so-far or direct-only output exists at any stage.
Preflight never emits `noResults`; empty declarations, zero rides or a missing direct route are not
proof (§24.5).

### 27.6 Replacement, overlap and retry

- **Replacement (E2 [A]).** A call that captured V1 completes against V1 even if V2 is published
  meanwhile; it is not cancelled, relabelled or mixed with V2. It does not claim V1 is current.
  Mandatory invalidation/rights revocation of an in-flight V1 needs its own evidenced policy
  before real deployment [O]; no stale fallback, TTL or refresh is designed.
- **Overlap [A]/[P].** Each call owns its scope, closure, evidence, assessment, P and solver state;
  only immutable `V`, bindings and configuration are shared. No global lock, actor-wide
  serialization or concurrency cap; the supplier may serialize only its reference read.
  Cancelling call A never cancels B or the supplier. No detached or orphan tasks.
- **Retry [A].** Data never retries. DEC-087 C2: Application retries only the identified current
  failed attempt with a fresh invocation identity, preserved explicit time or renewed now-capture.
  A retry is a new call that captures afresh and may see V2.
- **Publication [A].** Application alone publishes, suppresses superseded/cancelled responses and
  keeps current-request-only state. The conformer returns or throws; it publishes nothing.

### 27.7 Invented explanatory examples (not executed tests)

All identifiers, times and sizes are invented placeholders; no real railway data.

1. **Success.** Profile `P-x` covers stations `A,B,B',C`; request `A→C`, `L = t0`. S1–S5 pass; the
   declaration producer declares two occurrences and one walking target `B→B'` under complete
   authority; evidence marks it present with a qualifying allowance; assessment has no holds; P has
   three rides. The solver proves two equal-arrival, equal-change itineraries and returns scoped
   `.internalSuccess(... .alternatives(batch))` with both, in §24.4 order.
2. **Unavailable input.** Same request; the declared connection target's evidence record is
   `.unavailable(.insufficientEvidence)` → assessment keeps `connectionUnresolved` (a missing
   record is instead a construction conflict → `dataUnavailable`). A direct `A→C` ride exists in `V`. Result:
   `dataUnavailable`; the direct ride is not returned.
3. **Incomplete computation.** Input qualifies, but the complete equal-optimal set exceeds the
   configured winner safeguard → solver `searchIncomplete`, no subset. Alternatively the prepared
   ride count exceeds `PreparedInputLimits.rides` → [P] `searchIncomplete` at S8.
4. **Cancellation.** The user replaces the request while S7 runs. S7 finishes its synchronous
   constructor; the S7→S8 checkpoint observes cancellation → `CancellationError`; no result.
   Application had already suppressed publication for the superseded invocation.
5. **Captured-view replacement.** Call 1 captures V1; V2 is published during S6; call 2 starts
   and captures V2. Call 1 completes against V1 only; call 2 uses V2 only. Application publishes
   only the current request's outcome.

### 27.8 Future verification matrix (required, not executed)

| Area | Cases |
|---|---|
| Preflight order | Each stage failing alone and with every lower stage also failing; no lower probing (e.g. missing configuration plus missing view → `configurationUnavailable`); endpoint role/reason order |
| Capture | One supplier read per call; V1/V2 linearization; no reload; retry captures afresh |
| Scope | Endpoint outside profile; inexact horizon → `unsupportedRequest`; window outside validity → whichever category §27.9 settles |
| Endpoints | Dispositions read from captured `V` only; replacement during a call cannot change them; no shared-source read after capture |
| Composition | Every typed preparation failure mapped as §27.5; `resourceLimit` distinct from conflicts; holds → `dataUnavailable` with usable direct ride; objective/policy mismatch at S9 → `dataUnavailable` (direct solver only; composed path → S1 `configurationUnavailable`) |
| Solver parity | Composed outcomes equal direct `solve` on the same invented P, including all §24.8 outcomes |
| Cancellation | Before entry, after capture, between each stage, after S4 if it suspends, inside solver, before pending failure and return; no partial output |
| Isolation | Off-main execution under actual MainActor-default settings; overlapping calls independent; no detached tasks |
| Lifecycle | Unchanged `RouteSearchCoordinator` tests with a fake conformer; superseded responses suppressed |
| Build hygiene | Invented fixtures only; test seams absent from Release; standard Release app/extension on an explicit iPhone Simulator |

### 27.9 Open decisions [O]

**Product semantics (owner decisions):**

- Production profile contents: station/line/Trip domain, elapsed horizon and ride cap (DEC-080
  production parameters; no default).
- Any production **requiredness/exclusion rule** used by the declaration producer, if one beyond
  independently substantiated declarations is needed (§20.5: such a rule "must be surfaced
  separately").
- Invalidation/rights-revocation treatment of in-flight captured views before real deployment.
- User-visible category when the scope window exceeds captured-view validity (`unsupportedRequest`
  versus `dataUnavailable`, §27.5).
- DEC-086 R6 deployment/ownership and eventual live adoption.

**Implementation choices (technical, need review and authorization, not product decisions):**

- Supplier API and production view type (validity interval, policy correspondence, revision).
- Declaration producer and connection-evidence producer design and their safeguards.
- Production source from which the supplier embeds endpoint dispositions into `V`.
- Preparation `resourceLimit` mapping: `searchIncomplete` proposed, consistent with Accepted §3
  ("do not misreport a computation cutoff") and DEC-086 truthful cutoff. Any other category would
  change user-visible semantics and needs owner confirmation; none is recommended.
- Form of endpoint dispositions inside `V` (embedded table versus revision-pinned identity component).
- Dependency-resolution authority for declared external dependencies.
- Whether per-request profile selection is ever needed (would change the Domain port; not proposed).
- Measurement instrumentation placement and evidence-backed numeric safeguards (§26.2 G3–G5).

### 27.10 Prerequisites by future step

| Step | Prerequisites |
|---|---|
| Producer implementation (S6/S7 producers) | Reviewed producer design incl. requiredness authority; any surfaced requiredness rule decided; implementation authorization |
| Invented integration (conformer over invented supplier) | This contract reviewed; producer interfaces fixed or stubbed as stipulated invented declarations; implementation authorization |
| Measurement | Integrated invented path; §26.2 G3 workload frame; experiment authorization; physical-iPhone portion additionally needs explicit device authorization |
| Runtime adoption | Real qualified views and rights (§26.2 G1), production profile/configuration decisions, measured suitability, separate AppEnvironment enablement authorization |

### 27.11 Recommended next bounded task — not begun

*Status update (2026-10-14):* §27 was published at `b0438ed`; this audit is now drafted as
[§28](#28-declaration-connection-evidence-and-dependency-producer-audit--2026-10-14). The heading records the state at §27 publication.

**Documentation-only request-relative declaration and connection-evidence producer audit.**
S6/S7 are the first stages with no producer, and the B authority rule (§20.5, §21) forbids
deriving requiredness from loaded slots, paths or pair enumeration. Before any conformer API is
fixed, the audit should specify what authority produces exact per-request occurrence/interval/
connection/dependency declarations and evidence records from one captured view, how declared
dependencies are resolved (none can be cleared today), whether that
needs a new requiredness rule (surfaced for owner decision, not chosen), its safeguards, and
invented examples. Prerequisites: this contract; no private data. Completion: reviewed section,
explicit owner-decision list, independent non-author review. Exclusions: source/tests, real data,
measurements, numeric limits, AppEnvironment/Journey/UI, devices, Phase-10.
An invented-only conformer implementation (§27.10 row 2) is the subsequent candidate.

## 28. Declaration, connection-evidence and dependency producer audit — 2026-10-14

### 28.1 Status, labels and boundary

Documentation-only audit authorized after publication of the §27 contract at
`b0438eda9082104cb99949b21b7c7669bd5ab909`. Labels as in §27.1: **[A]** Accepted decision;
**[I]** published implemented code/contract (read-only inspection on 2026-10-14); **[P]** Proposed
here; **[O]** open. No source/tests, test/build/solver runs, measurements, private artifacts,
devices or runtime wiring. No transfer source, allowance or numeric production limit is chosen.
§27's preflight order, E2 capture, captured-view-only endpoint truth, DEC-087 ownership, §24 solver
semantics, separate safeguards/meter, escape rules and no-retry/no-partial rules are unchanged.
P3-T1 remains scope-incomplete; Phase 3 **In Progress**; live/default routing unconfigured.

### 28.2 What the implemented constructors already enforce [I]

| Constructor | Enforced (so a producer must satisfy it, not re-check it) | Holds produced (values, not throws) |
|---|---|---|
| `SearchInputClosureApplicability(reference:scope:qualification:)` | `scope.viewID == qualification.viewID`; later full scope/profile/request/bounds equality and inventory-qualification equality per declaration | — |
| `RequestScopedSearchInputClosure` | Railway revision equals inventory's; every requirement and target carries its declaration's applicability reference; one requirement per address; full snapshot agreement with loaded and other same-Trip bindings; interval index validity (`b < a`, distinct stations); targets' endpoints must be required addresses with `alightingIndex > 0`, `boardingIndex < count-1`, unique; dependency references unique; active required Trip ∈ profile Trips and each interval's stations/lines ∈ profile, else `profileConflict` | `occurrenceDomainUnknown`, `connectionDomainUnknown`, `occurrenceNotLoaded`, `occurrenceUnsupported`, `occurrenceInsufficientEvidence`, `intervalUnknown`, **every** `connectionUnresolved`, **every** `dependencyUnresolved` |
| `ConnectionEvidenceState.qualifyingPositive/qualifyingAbsence` | Any `contradictory` premise throws; `unsupported`/`insufficientEvidence` premises yield `.unavailable` | — |
| `QualifiedConnectionEvidenceView` | Records' keys equal declared keys exactly (no missing/extra/duplicate); record review and target applicability equal the qualification's; binding/address/index agreement; positive requires distinct TripIDs and `form == .sameStation` iff the two indexed stations are equal; its `ConnectionEvidenceQualification` requires policy equal to the profile's `connectionPolicy` | — |
| `ResolvedSearchInputAssessment` | Same applicability reference, profile definition, request, bounds, view and inventory qualification as the closure; one record per required target; deep binding agreement; positive endpoints: prohibited role throws `endpointConflict`, changed exact instant throws `applicabilityConflict` | Positive: `endpointNotLoaded/Inactive/Unsupported/InsufficientEvidence`, `permissionUnknown`, `exactEventMissing`; absent under unknown authority: `negativeScopeUnknown`; unavailable: `unsupported`/`insufficientEvidence`. Clears **only** resolved `connectionUnresolved` |
| `PreparedInternalSearchInput` | Requires zero remaining holds; per interval: inactive, absent-under-complete, prohibited endpoint, outside scope or usable ride; unknown permission / missing exact event throw | — |

The invented test helper `SolverFixture.world` (`TSUGINOTests/Support/InternalSolverFixtures.swift`)
already composes this whole chain from stipulated invented values: one view ID, invented railway
revision and qualification, profile derived from the fixture Trips, scope, applicabilities named
`invented-occurrence-domain` / `invented-connection-domain` / `invented-dependencies`, records built
with the checked factories, and the assessment. `prepare(...)` then builds P from that world.
It is the reference shape for the producers below, not a production producer.

### 28.3 Seam 1 — per-request required-domain declarations [P]

**Inputs.** The captured view `V` (§27.3 S2) and the S5 `InternalSearchScope`. `V` must carry,
as supplied authority: an occurrence-domain reference; occurrence-domain completeness; a finite list of
`(TimetableOccurrenceBinding, intervalAuthority, [TimetableVerifiedRideInterval])` entries; a
relation-domain reference, completeness and finite list of directional targets
`(from address, alightingIndex, to address, boardingIndex)`; and a dependency reference with its
unresolved list. None of these view-level members exists today.

**Output.** `SearchInputOccurrenceDeclaration`, `SearchInputConnectionDeclaration` and
`SearchInputDependencyDeclaration`, each holding a `SearchInputClosureApplicability` built from
the corresponding occurrence, relation or dependency reference in `V`, **this** scope and `V.inventory.qualification`.

**Association.** The only per-request computation is re-binding the view-level authority to the
exact scope through `SearchInputClosureApplicability` (scope carries request, profile, view ID and
bounds). The closure then rejects any mismatch. One view ⇒ one inventory qualification ⇒ one
railway revision. Nothing is cached across calls.

**Supplied vs computed.** Supplied: membership of occurrences, intervals, relations and
dependencies, and both completeness values. Computed: only applicability binding and the
projection below. The producer never reads slot activation, facts, permissions or times to decide
membership (§20.5: "do not derive requiredness by scanning loaded slots").

**Projection through the profile [P].** The closure rejects a required active occurrence whose Trip
is outside the profile, and any interval touching a non-profile station/line (`profileConflict`).
Under Accepted DEC-080, profile sets are the declared search domain and scoped success can carry
only profile members (`InternalSearchSuccess.matches`). The producer therefore declares only domain
entries whose Trip is in `profile.trips` and intervals whose stations/lines are in the profile,
and only relations whose endpoints both survive. This projection uses declared profile and domain
data only, never loaded state. This exclusion follows directly from Accepted DEC-080 V1 (§9.1 "explicit
allow-list domain": movements outside the profile are excluded) and V5 / the implemented
`InternalSearchSuccess.matches`, so it is not a new §27.9 requiredness rule. The §28.6
producer is for invented integration only; production use of R1 or this projection still requires
the §27.9/§27.10 requiredness decision.

**Requiredness rule — decision analysis [O].** Which declared view-domain entries are required for
a given request window changes which evidence must be supplied, so it is not silently chosen:

| Option | Rule | Soundness | Evidence burden / availability | Decision class |
|---|---|---|---|---|
| R1 Whole projected domain | Every profile-projected entry of `V` is required regardless of date | Sound superset: out-of-window intervals become `outsideScope` in P; no route can be omitted | Every date in `V` must be fully qualified; any unknown anywhere fails every request (`dataUnavailable`); P grows with view span, and closure/evidence/prepared limits (e.g. 2,048 relations in `ConnectionEvidenceLimits.relations`) apply to the whole span, giving preparation `resourceLimit` on every request when exceeded | Technical; availability impact. **Adequate for invented integration** |
| R2 Supplied per-window authority | `V` carries declarations already scoped to service-date windows; producer selects the window covering `[L, U]` | Sound only if the supplied window authority includes prior-day/extended-hour dates | Burden moves to the supplier's reviewed authority | Technical, but the window rule itself must be reviewed |
| R3 Computed date relevance | Producer derives contributing service dates from `serviceDateInterpretation` | Requires resolved interpretation policy contents (DEC-080 V3: from reviewed qualified source rules, never opaque labels) | Smallest P | Needs resolved policy contents; may need owner decision |

Recommendation: R1 for the invented integration only; production selection stays [O].

**Fact handling (existing authority, unchanged) [I].** Inactive → qualified negative (`.inactive`,
no ride); not loaded → hold; unsupported/insufficient → hold; interval positive → present; not
declared under complete interval authority → `absentUnderCompleteAuthority`; under unknown →
hold; prohibited endpoint → excluded ride in P; unknown permission or missing exact event on a
present interval → `dataUnavailable` at P. Unknown domains hold. Identity stays the dated
address `(viewID, TripID, serviceDate)` plus original indices; repeated visits keep their own
indices; no date parsing.

### 28.4 Seam 2 — per-request connection evidence [P]

**Inputs.** The closure's required targets (B order) and `V`'s connection authority: review
reference, completeness, and for each relation key the supplied form, `ConnectionAllowance`
components and the four positive premises, or the three absence premises, or an unavailable reason.

**Output.** One `ConnectionEvidenceRecord` per required target, exactly, in a
`QualifiedConnectionEvidenceView` whose qualification uses the **same applicability reference and
scope** as the closure's connection declaration and the profile's `connectionPolicy`, so the
assessment's equality checks pass.

**Supplied vs computed.** Supplied: form, allowance components and total, all premises,
completeness, review, and for a positive entry the exact `fromArrival`/`toDeparture` instants it
was examined under (§21.4: "Changed scheduled endpoint values prevent reuse"). Computed: only the
record key from the target and the two bindings copied from B's required bindings. The producer
passes the supplied instants through unchanged and never copies them from the inventory, so the
assessment's exact-instant comparison still detects evidence examined against changed times. If
`V`'s positive entry lacks either examined instant, emit `.unavailable(.insufficientEvidence)`;
otherwise pass the entry through and let the published assessment classify endpoint state
(including `exactEventMissing`, `endpointInactive` and prohibited-role conflicts at both ends). Form is never inferred from
station equality, which only checks consistency; the producer never computes allowances or gaps,
since gap feasibility stays in P. No station-pair or TripID-only reuse: a supplied entry applies
only where its endpoint-wide premise qualifies those exact dated endpoints (§21).

**Missing/unknown/contradictory.** No entry for a required key → emit
`.unavailable(.insufficientEvidence)`, never omit (omission throws `declarationConflict` in the view, or `targetConflict` in the
assessment if the key is also left out of the declared keys);
contradictory premise → construction throws → `dataUnavailable`; absence under unknown authority
→ `negativeScopeUnknown` hold. No absence is inferred from missing data.

**Evidence burden at qualified-negative endpoints [I]/[O].** Positive evidence on a target whose
endpoint occurrence is **inactive** stays held (`endpointInactive`); positive evidence at a **known
prohibited** endpoint role throws `endpointConflict`. Published §21.4 already provides the
resolving path: a supplied qualified absence "may cover conclusively inactive or missing-event
endpoints without fabricating active event instants only when the negative is expressly qualified
for the entire exact occurrence-endpoint pair independently of event values". Under declared-complete
evidence authority such a record resolves as `absentUnderCompleteAuthority` (the absence branch does
not inspect endpoints). §21.4 also states that "missing times, inactivity … alone never establishes
connection absence". The open question is therefore evidence burden, not a code gap: a date-spanning
R1 relation domain may include such targets, and each needs either exclusion from the supplier's
declared relation domain or a supplied dated-pair absence, else it blocks the request as
`dataUnavailable`.

| Option | Effect | Evidence obligation change | Class |
|---|---|---|---|
| G1 Keep current semantics | Supplier omits such relations from its declared domain or supplies a qualified event-independent dated-pair absence (§21.4) | Burden on supplied authority | No code change |
| G2 Derive resolution from a qualified inactive occurrence or known-prohibited role, with no edge in P | Consumes existing qualified negatives; can never create a success or ride | Removes the need for supplied dated-pair absence | Amends §21.4's rule that inactivity alone never establishes absence; owner decision, plus review of published §21/§22 code |

Smallest owner question, **not blocking the invented integration**: *"May resolution of a required
connection target be derived from a qualified inactive endpoint occurrence or a known-prohibited
endpoint role, without a supplied dated-pair absence?"*

### 28.5 Seam 3 — dependency resolution [I]/[O]

`SearchInputDependencyDeclaration` carries only `unresolved` references; the closure adds one
`dependencyUnresolved` hold per entry, and nothing clears it. **An empty list is sufficient for a
bounded invented integration**: the invented `V`'s dependency authority stipulates that no external
obligation applies under its reference. This is exactly what `SolverFixture.world` does by default,
and it is a stipulation, not authentication. A nonempty list cannot qualify today. Resolving one
would need a new resolution value bound to the same applicability reference and scope, carrying
a qualified premise per dependency, plus an assessment change that clears only matching
`dependencyUnresolved` holds. That is a source change with its own review. Which real dependencies
exist (calendar authority, connection policy contents, rights) belongs to real qualification [O].

### 28.6 Invented-integration handoff — smallest end-to-end slice [P]

**Product decisions required before this slice: none.** The injected profile is an invented
fixture (invented stations, lines, Trips, horizon and ride cap). It is test data passed to the
conformer, not a production default, so no production horizon, ride cap or launch coverage is
chosen. The two §27.9 user-visible mappings (window outside validity; preparation
`resourceLimit`) are implemented once, at a single named mapping point, using the §27 Proposed
categories. Each is pinned by a test and listed as pending owner confirmation. Live routing stays
unconfigured, so nothing user-visible ships.

Policy contents behind the profile's and objective's `InternalSearchPolicyReference` values (§27.3 S1)
are stipulated for the invented fixtures; only reference correspondence is checked, and no real
policy is resolved.

**Interfaces to implement (new production Data code, not registered anywhere):**

1. Captured view value (one immutable `Sendable` struct) containing: view ID; railway revision; validity interval;
   connection-policy and service-date-interpretation references; `TimetableOccurrenceInventoryView`;
   endpoint dispositions keyed by `StationID` (active, or an existing
   `RouteSearchEndpointFailureReason`); occurrence/relation/dependency domain authority (§28.3);
   connection authority (§28.4).
2. Supplier abstraction with one `async` read returning the whole current view or none (E2), plus
   an invented test supplier actor with `replace(_:)`.
3. Declaration producer: pure throwing function `(view, scope) → three declarations`, R1 plus
   profile projection.
4. Connection-evidence producer: pure throwing function `(view, closure) → QualifiedConnectionEvidenceView`.
5. Conformer: `nonisolated` type conforming to `RouteSearching` with `@concurrent search`. Its
   initializer takes the supplier, an immutable profile, an objective reference and an
   `InternalSolverExecutionConfiguration`. It runs §27.3 S0–S10.
   - At S1 it validates the configuration through the existing `InternalSolverMeter` initializer
     and checks that `configuration.objective` has the same definition as the bound objective
     (`configurationUnavailable` otherwise).
   - It maps typed failures explicitly as in §27.5, then applies the final cancellation check and
     the generic `dataUnavailable` fallback.

**Flow.**
1. Check cancellation, then validate the configuration.
2. Capture once, then check cancellation.
3. Check view validity and policy correspondence.
4. Validate origin, then destination, against `V`'s dispositions.
5. Build `InternalSearchScope`.
6. Run the declaration producer, then the closure.
7. Run the evidence producer, then the assessment, and require `remainingHolds` to be empty.
8. Build `PreparedInternalSearchInput`, then call `InternalRouteSolver.solve`.
9. Run the final cancellation check and return.

There is a cancellation checkpoint between every stage.

**Technical choices resolvable inside implementation:** type and file names; whether the view
retains the inventory or the slot inputs; how the test supplier serializes replacement; the
test-only checkpoint seam (excluded from Release, like `InternalSolverTestHooks`); invented
fixture sizes. Any change to published B/A/P/solver code is **out of scope**; G2 and dependency
resolution stay separate.

**Required verification (invented only):**

| Area | Cases |
|---|---|
| Success | Direct and one-transfer itineraries equal direct `InternalRouteSolver.solve` on the same P built by `SolverFixture`; all equal optima retained in §24.4 order |
| Preflight | Invalid configuration (including ceiling and objective mismatch) → `configurationUnavailable` without capture; no view → `dataUnavailable`; each endpoint reason and role order; origin outside profile → `unsupportedRequest` |
| Projection | Non-profile Trip, station or line entries and their relations are dropped, never reported as `profileConflict`; an R1 out-of-window interval becomes `outsideScope` |
| Coverage | Unknown occurrence/relation domain, unloaded/unavailable occurrence, unknown interval, unavailable or missing-instant evidence, nonempty dependency → `dataUnavailable` even with a usable direct ride; contradictory premise → `dataUnavailable` |
| Incomplete | Solver winner/work cutoff → `searchIncomplete`; preparation `resourceLimit` → pinned Proposed mapping |
| Cancellation | Before entry, after capture, at every stage boundary, inside solver, before pending failure and return → `CancellationError`, no result |
| Replacement | Call 1 captures V1, V2 published mid-call: call 1 result derives only from V1; call 2 only from V2; one supplier read per call |
| Concurrency | Overlapping calls on one conformer are independent; cancelling one does not affect the other; off-main execution under MainActor-default settings; no detached tasks |
| Lifecycle | Existing `RouteSearchCoordinator` behaviour unchanged when driven by the conformer in tests |
| Build | Focused new tests plus affected suites (`InternalRouteSolverTests`, `PreparedInternalSearchInputTests`, `QualifiedConnectionEvidenceTests`, `RequestScopedSearchInputClosureTests`, `RouteSearchCoordinatorTests`); standard Release app/extension on an explicit iPhone Simulator; test seams absent from Release |

**Completion criteria.**
- The tests above pass, with exact commands recorded.
- The Release build passes.
- An independent non-author review is approved.
- Documentation records which mappings are provisional.
- There are no changes to Domain, published B/A/P/solver code, AppEnvironment, Journey or UI.

**Exclusions.**
- Real or private data, and real pilots.
- G2 and dependency-resolution changes.
- Production requiredness (R2/R3), production policy values and numeric limits.
- Measurements.
- AppEnvironment injection and live enablement.
- Journey/UI work, physical devices and Phase-10 work.

### 28.7 Classification and next action

`NO_NEW_PRODUCT_DECISION_REQUIRED` for the invented integration slice in §28.6. Open for later,
not blocking it: production requiredness rule (R1/R2/R3), the G2 qualified-negative-endpoint
question, dependency resolution, the two §27.9 user-visible mappings, and all §26.2 real-data,
measurement and adoption gates. Exact next action, **not begun**: separately authorize the
§28.6 invented-only end-to-end implementation slice.

*Status update (2026-10-15):* §28 was published at `e3da19dbc2f40e8265d649836bacc85e7fde6635`;
the §28.6 slice is now implemented, invented-only, as
[§29](#29-invented-only-end-to-end-routing-composition--2026-10-15). The text above records the
state at §28 publication.

## 29. Invented-only end-to-end routing composition — 2026-10-15

### 29.1 Scope lock and authority

Owner-authorized implementation of the published §28.6 slice from checkpoint
`e3da19dbc2f40e8265d649836bacc85e7fde6635`. In scope: new Data code (captured view, supplier seam,
two pure producers, a `RouteSearching` conformer), invented tests, relevant regressions, Simulator
builds and these documents. Out of scope and unchanged: Domain; the published inventory, closure
(B), evidence/assessment (A), prepared-input (P) and solver code; AppEnvironment/live routing;
Journey/UI; real/private data; R2/R3; dependency resolution; G2; production values or limits;
measurements; devices; Phase 10. P3-T1 stays scope-incomplete, Phase 3 **In Progress**,
live/default routing unconfigured: the conformer is not registered anywhere.

### 29.2 Implemented request→result flow [I, invented only]

`PreparedRouteSearcher` (`TSUGINO/Data/Routing/PreparedRouteSearcher.swift`) is a `nonisolated`
struct with `@concurrent search`. Its immutable bindings are a `PreparedRouteViewSupplying`
supplier, an `InternalSearchProfileDefinition`, an objective reference (bound as
`InternalRouteObjectiveDefinition`) and an `InternalSolverExecutionConfiguration`. All per-call
values are locals. Each named stage below ends in a checkpoint (`PreparedRouteSearchStage`)
followed by `Task.checkCancellation()`:

| Stage | Work | Failure |
|---|---|---|
| `entry` | — | `CancellationError` |
| `configuration` (S1) | `InternalSolverMeter(configuration)` validation; `configuration.objective.hasSameDefinition(as:)` the bound objective | `configurationUnavailable`, no capture |
| `capture` (S2) | exactly one `await supplier.currentView()` | — |
| `viewValidity` (S3) | view present; finite `validFrom < validUntil`; view connection-policy and service-date references equal the profile's | `dataUnavailable` |
| `endpoints` (S4) | origin then destination from the captured `endpoints` table; absent station → `unknown` | `invalidEndpoint(role, reason)` |
| `scope` (S5) | `InternalSearchScope(profile:request:viewID:)`; then inclusive `[L, U]` within validity | `unsupportedRequest`; window outside validity → **provisional** mapping |
| `declarations`, `closure` (S6) | declaration producer, then `RequestScopedSearchInputClosure` | typed mapping (§29.4) |
| `evidence`, `assessment` (S7) | evidence producer, then `ResolvedSearchInputAssessment`; `isTechnicallyQualified` required | typed mapping; remaining holds → `dataUnavailable` |
| `preparedInput` (S8) | `PreparedInternalSearchInput` | typed mapping |
| `solve` (S9/S10) | unchanged `InternalRouteSolver.solve` (own meter, §24.8 outcomes), then final checkpoint and return | solver outcomes unchanged |

The outer `search` catch performs a cancellation check before any pending failure, rethrows
`CancellationError` or `RouteSearchFailure`, and maps anything else to `dataUnavailable`.
No retry, partial, best-so-far or direct-only output; no publication (DEC-087 stays in
Application). The view's `id` and `railway` are derived from its inventory qualification
(one view ⇒ one qualification ⇒ one view ID and revision, §28.3), so they cannot disagree with it.

S6–S8 are synchronous and run inside existing constructors, which have no cancellation checks;
a cancellation arriving during one is observed at the next checkpoint. No interruption inside a
constructor and no wall-time responsiveness is claimed.

### 29.3 Captured view and producers [I, invented only]

`TSUGINO/Data/Routing/PreparedRouteSearchView.swift`:

- **`PreparedRouteSearchView`** — validity interval, the two policy references, the
  `TimetableOccurrenceInventoryView`, endpoint dispositions (`active` or an existing
  `RouteSearchEndpointFailureReason`), occurrence/relation/dependency domain authority (§28.3) and
  connection authority (§28.4: review, completeness, entries keyed by `ConnectionRelationKey`).
- **`PreparedRouteViewSupplying`** — one `async` read returning the whole view or `nil` (E2).
  Supplier obligation: an endpoint table that cannot support endpoint validation must not be
  published (return `nil` → S3 `dataUnavailable`); a station absent from a published table is
  treated as `unknown`.
  The replaceable test supplier actor (`InventedPreparedRouteViewSupplier`, `replace(_:label:)`)
  lives in `TSUGINOTests/Support/PreparedRouteSearchFixtures.swift`; there is no production supplier.
- **`PreparedRouteDeclarationProducer`** — R1 for invented integration only: every supplied
  domain member is required regardless of date. The only exclusion is the DEC-080 V1 profile
  projection: non-profile Trips, intervals touching a non-profile station or line (a copy of the
  closure's own `profileConflict` predicate, cross-referenced in source), and relations incident to
  an excluded occurrence. It reads no loaded slot. Projected-in members, including malformed ones
  (bad indices, duplicates, relations to undeclared addresses), pass through unchanged so the
  closure rejects them; projected-out members are dropped without structural checks. The producer
  applies no limits of its own: the closure's existing safeguards govern the projected output
  (`closureLimitsApplyToProjectedDomainOnly`), and producer work is linear in the supplied domain,
  whose size the supplier owns.
- **Interpretation recorded for owner review:** a relation between two kept occurrences stays
  required even when it alights or boards at a non-profile station (§28.3 "relations whose
  endpoints both survive" read at occurrence level). Without supplied evidence for it, every
  request fails `dataUnavailable`. The alternative reading of DEC-080 V1 (exclude such transfers)
  is not implemented; see §29.6.
- **`PreparedRouteConnectionEvidenceProducer`** — one record per required closure target, in closure
  order. It computes only the key and the two bindings copied from the closure; form, allowance
  components (through the checked `ConnectionAllowance` init), premises, review, completeness and
  examined instants pass through. It throws `targetConflict` rather than trapping if the closure's
  one-requirement-per-address invariant were ever violated. A missing entry or examined instant →
  `.unavailable(.insufficientEvidence)`; absence is never inferred. Supplied absences go through
  `qualifyingAbsence`, the §21.4 path G1 relies on. It pre-checks the target count against
  `ConnectionEvidenceLimits.relations` before building records.

Dependencies: the invented fixtures declare an empty list as an explicit stipulation (§28.5). A
nonempty list is passed through and stays unresolved (`dataUnavailable`); nothing resolves it.

### 29.4 Failure mapping and provisional mappings

Typed preparation failures are mapped in `PreparedRouteSearchFailureMapping` before the generic
fallback: `resourceLimit` → the provisional preparation mapping; every other
closure/evidence/prepared-input failure → `dataUnavailable`.

**Provisional, pending owner confirmation for production** — one named point,
`PreparedRouteSearchProvisionalMapping`, pinned by `provisionalMappingsArePinnedAtOnePoint` and
end-to-end tests:

| Mapping | Implemented category | Basis |
|---|---|---|
| `windowOutsideViewValidity` | `unsupportedRequest` | §27.5 Proposed (DEC-081 synthetic precedent); `dataUnavailable` is the §27.9 alternative |
| `preparationResourceLimit` | `searchIncomplete` | §27.5/§27.9 Proposed; DEC-086 truthful cutoff |

This implementation authorization is not production acceptance of either mapping.

### 29.5 Invented verification (2026-10-15)

Destination: iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880` (explicit). No physical
device was discovered, selected or used.

```text
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-composition-dd -resultBundlePath /private/tmp/tsugino-composition-first.xcresult -only-testing:TSUGINOTests/PreparedRouteSearchCompositionTests test
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-composition-dd -resultBundlePath /private/tmp/tsugino-composition-regression.xcresult -only-testing:TSUGINOTests/PreparedRouteSearchCompositionTests -only-testing:TSUGINOTests/InternalRouteSolverTests -only-testing:TSUGINOTests/PreparedInternalSearchInputTests -only-testing:TSUGINOTests/QualifiedConnectionEvidenceTests -only-testing:TSUGINOTests/RequestScopedSearchInputClosureTests -only-testing:TSUGINOTests/RouteSearchCoordinatorTests -only-testing:TSUGINOTests/TimetableOccurrenceInventoryTests -only-testing:TSUGINOTests/InternalSearchScopeTests -only-testing:TSUGINOTests/InternalSearchSuccessTests -only-testing:TSUGINOTests/RouteSearchingTests -only-testing:TSUGINOTests/RouteSearchCaptureIntegrationTests -only-testing:TSUGINOTests/AppEnvironmentTests test
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-composition-release-dd build
```

Current state: the post-review figures below (213 tests; composition suite 18 functions / 57
cases) supersede the earlier runs, which are kept as history.

- **First focused run:** compiled; one assertion failed (the test wrongly expected an empty
  closure-hold list; `connectionUnresolved` holds always remain until the assessment). The
  assertion was corrected; no source change.
- **First regression run:** `TEST SUCCEEDED`, 212 tests passed.
- **Post-review run** (same command, result bundle `/private/tmp/tsugino-composition-corrected.xcresult`,
  after the §29.7 corrections): `TEST SUCCEEDED`, 213 tests passed, 0 failed, 0 skipped. The new
  `PreparedRouteSearchCompositionTests` contributes 18 test functions (57 argument cases); the rest
  are the unchanged affected suites listed above. The post-review Release build also succeeded.
- **Release:** `BUILD SUCCEEDED` for the app with the embedded `TSUGINOLiveActivity.appex`. No
  warnings from the new files. Test seams (`PreparedRouteSearchTestHooks`, the hooks initializer and
  the solver-hook branch) are `#if DEBUG`; Release compiling without them is the evidence. A symbol
  scan of the Release binary is inconclusive because the unregistered conformer is dead-stripped too.

| Area (§28.6) | Covered by |
|---|---|
| Success parity | `composedEqualsDirectSolver` ×7: direct, same-station and walking transfers, fewer-changes tie, two equal optima in §24.4 order, `noResults` (twice). Composed outcome equals direct `solve` on the same SolverFixture P, and the oracle agrees |
| Preflight | `preflightOrderAndPrecedence`, `endpointDispositionsFromCapturedViewOnly` ×4, `configurationValidatedBeforeCaptureIncludingObjective` (zero/over-ceiling/objective mismatch → `configurationUnavailable` with no capture; the direct solver reports the same mismatch as `dataUnavailable`) |
| Projection | `profileProjectionDropsNonProfileMembers` ×3 (Trip, station, line); `requiredWholeSuppliedDomainKeepsOutOfWindowDatesOutsideScope` (R1 requires both dates; the later one is `outsideScope`) |
| Coverage | `unknownOrContradictoryInputIsDataUnavailableDespiteDirectRide` ×18: unknown domains, unloaded/unavailable occurrence, unknown interval, unavailable/missing/instant-less evidence, nonempty dependency, contradictory premise, absence under unknown authority, allowance contradiction, examined-time mismatch, positive evidence at an inactive endpoint, unknown permission, missing event, relation to an undeclared address, duplicate declaration |
| Evidence pass-through | `suppliedExaminedInstantsPassThroughUnchanged`; `suppliedDatedPairAbsenceResolvesInactiveEndpoint` (G1 path) |
| Incomplete | `preparationSafeguardsAndSolverCutoffAreSearchIncomplete`: closure dependency and occurrence limits, evidence relation limit, solver winner cap and work cutoff; `closureLimitsApplyToProjectedDomainOnly`; `provisionalMappingsArePinnedAtOnePoint` |
| Cancellation | `cancellationAtEveryStageBoundary` ×12; `cancellationBeforeEntryInsideSolverAndBeforePendingFailure` (before entry with no capture; inside the solver; cancellation beats a pending non-canonical error and a pending `RouteSearchFailure`; otherwise a canonical failure is rethrown unchanged and a non-canonical error falls back to `dataUnavailable`) |
| Replacement | `inFlightCallKeepsV1AfterReplacementAndLaterCallCapturesV2` (captures `[V1, V2]`) |
| Concurrency | `overlappingCallsAreIndependentAndEachCapturesOnce` (both calls in flight; cancelling one leaves the other to succeed); `mainActorCallerRunsEveryStageOffMain` (every stage recorded off the main thread, in order) |
| Lifecycle | `coordinatorPublishesCompletedFailedAndCancelledAttempts` through the unchanged `RouteSearchCoordinator`, plus the unchanged `RouteSearchCoordinatorTests` |

PreparedInputFailure `resourceLimit` (more than 4,096 rides) is covered by the mapping unit test
only, not by an end-to-end input. Isolation evidence is the app target's actual settings
(`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, approachable concurrency, Swift 5 mode) plus the
off-main test; it is not a performance or responsiveness measurement.

### 29.6 Remaining gates

- **Real data:** no qualified real view, supplier, endpoint-disposition source, or rights (§26.2 G1).
- **Policy:** policy contents behind every reference are stipulated; production profile, horizon,
  ride cap and coverage are unchosen; the two §29.4 mappings await owner confirmation.
- **Requiredness:** R1 is invented-only; production R1/R2/R3 stays open (§28.3), as does the
  §29.3 non-profile-transfer-station interpretation.
- **View size:** producer work is bounded only by the supplied view; a real supplier needs its own
  reviewed bound on published domain size.
- **Evidence burden:** G1 is implemented as published; the G2 owner question stays open (§28.4).
- **Dependencies:** nonempty dependency resolution is unimplemented (§28.5).
- **Measurement:** no runtime, memory or cancellation-latency evidence (§26.2 G3–G5).
- **Runtime adoption:** no AppEnvironment injection, live enablement, in-flight invalidation policy
  or DEC-086 R6 ownership decision.

### 29.7 Independent review and handoff

A fresh non-author agent with no author context reviewed the final source, tests and documents.
Like the author, it is the same model in the same environment, so this is not a blinded
external review. One reviewer performed every round. Independence is distinct from the verdict.

- **Round 1 — REQUEST CHANGES.**
  - F1 (M): the declaration producer applied closure limits to the unprojected supplied domain.
    That was not authorized by §28.2/§28.3, was an effectively new limit, and was untested.
  - Minor findings:
    - F2: the pass-through wording was overstated.
    - F3: the non-profile transfer-station interpretation was unstated.
    - F4: cancellation over a pending failure was shown only with a non-canonical error.
    - F5: overlap cancellation was not tested with both calls in flight.
  - Nits:
    - F6: the endpoint-table supplier obligation was not recorded.
    - F7: a trapping dictionary init.
    - F8: the predicate copy had no cross-reference.
  - The reviewer's own Simulator tests, Release build and mutation runs confirmed F1 was untested
    and that the off-main test fails without `@concurrent`.
- **Corrections:**
  - F1: the preflight was removed and `closureLimitsApplyToProjectedDomainOnly` added.
  - F2/F3/F6: wording and an owner-open item in §29.3/§29.6.
  - F4/F5: strengthened tests.
  - F7: throws `targetConflict` instead of trapping.
  - F8: added a source cross-reference.
  - The author re-ran the §29.5 regression set (213 passed) and the Release build (succeeded).
- **Round 2 — APPROVE.**
  - The reviewer re-ran the same regression set (213 passed, 0 failures) and the Release build
    (succeeded).
  - Mutation runs: restoring the preflight fails `closureLimitsApplyToProjectedDomainOnly`;
    removing the outer cancellation check fails
    `cancellationBeforeEntryInsideSolverAndBeforePendingFailure`.
  - Two documentation nits (this record; current-state labelling in §29.5) were addressed afterwards.

Unresolved: none from review. Owner-open items are listed in §29.4 and §29.6. Next safe action:
the owner's publication review of the §29 change set (2 source files, 2 test files, 4 documents).
Any real-data, policy, measurement or adoption step needs its own authorization.

*Status update (2026-10-16):* the §29 change set is published at
`7886c20ab7a2b4dda8fc1cb23a57ad9132ad6d26` (`feat: add invented prepared route search composition`,
parent `e3da19dbc2f40e8265d649836bacc85e7fde6635`, 8 files). The "next safe action" above records
the state before publication. The bounded measurement experiment design is
[§30](#30-bounded-invented-workload-and-measurement-experiment-design--2026-10-16).

## 30. Bounded invented workload and measurement experiment design — 2026-10-16

### 30.1 Scope lock, checkpoint and authority

This is a documentation-only design, authorized by the owner. It covers the invented stress
workload, the measurements, execution containment and the implementation handoff for the §29
composition. Nothing here implements a harness, runs a test, build, workload or measurement,
opens real or private data, or touches a device. It does not change production code, numeric
limits, requiredness, G2, dependency semantics, AppEnvironment, Journey/UI or Phase 10. P3-T1
stays scope-incomplete; Phase 3 stays **In Progress**; live/default routing stays unconfigured.

- **[V] Checkout (2026-10-16).** Internal checkout `/Users/byungjin/TSUGINO`; origin
  `https://github.com/lunalism/TSUGINO.git`; branch `phase/03-route-search`. HEAD, upstream and
  the live remote branch are all `7886c20ab7a2b4dda8fc1cb23a57ad9132ad6d26`. Local, tracked and
  live main are all `e8a463d51f14b3cb1027960c63244b694579a71b`. Divergence 0/0. Worktree and
  index were clean, with no non-ignored untracked files, before these edits.
- **Authority.**
  - §24.6: no numeric production solver limit without implementation evidence
    (`NUMERIC_PRODUCTION_SOLVER_LIMITS_REQUIRE_IMPLEMENTATION_EVIDENCE`); orchestration may
    measure preparation + solve separately, with no common budget unit.
  - §16.2: the four evidence classes. Everything here is **invented stress evidence**, never
    representative workload evidence.
  - §26.2 G3/G4 and §29.6 "Measurement": the gates this experiment starts to address.
  - §27.4: measurement boundaries; stage figures are never summed into one budget.
  - AGENTS §18/§22/§23 and RULES 29/30: evidence before optimization; Simulator-first; no
    physical device without explicit authorization.
- **Labels.** **[V]** verified read-only in this checkout on 2026-10-16; **[P]** proposed
  experiment design; **[O]** open. Figures marked *predicted* come from the §25.2 cost model and
  the §25.3 observations. They guide ladder placement only, are never asserted, and are never
  results.

### 30.2 Instrumentation visibility [V]

| Observable | Existing mechanism | Builds where it exists | Consequence for the design |
|---|---|---|---|
| Whole-call elapsed time | Harness clock around `PreparedRouteSearcher.search` | Any | Primary timing; needs no hook |
| Composition stage boundaries | `PreparedRouteSearchTestHooks.checkpoint`, called at each of the 12 `PreparedRouteSearchStage` checkpoints just before `Task.checkCancellation()`. `entry` fires at the start; every other checkpoint fires at the end of its stage | `#if DEBUG` | Stage timing and cancellation observation. With `solver: nil`, the searcher still calls the production `InternalRouteSolver.solve` path |
| Solver stage entries and `InternalSolverUsage` | `InternalSolverTestHooks.checkpoint` via `solveForTesting` | `#if DEBUG` | Diagnostic only. `.tieCollection` is entered at **every** destination-reaching prefix, so an awaited hook there adds per-path overhead |
| Solver usage at a cutoff | Not exposed. Only the usage at the last entered stage is visible | — | Report "last observed usage ≤ limit". No source change is proposed |
| Preparation counters | Each constructed value exposes `logicalPayloadBytes` (closure, assessment, P) and P exposes `rides`/`connections`/`intervalAccounting`. They are locals of the composed call | Any (values) | Read them in a separate structural pass with `PreparedRouteFixture.prepareThroughProducers`, outside timed calls |
| Cancellation inside the solver | `InternalSolverMeter.charge` and `product` call `Task.checkCancellation()` at every charge | Any | Not visible to composition hooks; only the caller-visible throw time is |
| Release configuration | `ENABLE_TESTABILITY = YES` is set only for Debug. Test support uses DEBUG-only hooks without guards (`PreparedRouteFixture.searcher(hooks:)`) | — | The test target cannot be measured in Release without structural change. See §30.6 build variants |

New files under `TSUGINOTests/` join the test target automatically (file-system synchronized
root group); `Tools/` belongs to no target. The scheme marks tests `parallelizable = "YES"`.

### 30.3 Constructibility of boundaries [V]

Every boundary uses the real constructors through `SolverFixture.world` →
`PreparedRouteFixture.make`. Where the fixture world itself would exceed a cap, a valid
view-level `Parts` edit is used, as the existing composition limit tests already do (§29.5). No
constructor is bypassed and no invalid value is forged. Payload estimates are computed from the
accounting code; a structural pre-check must confirm the actual value before any timing (§30.9).

| Boundary (source constant) | End-to-end through the composition? | Finding |
|---|---|---|
| Inventory caps (`TimetableInventoryLimits`: 2,880 addresses, 480 Trips, 6 dates, 92,160 intervals, 120,000,000 logical bytes) | **No.** The supplier enforces them while building `TimetableOccurrenceInventoryView`, before any view exists | Exceeding one is a setup failure (class S), not a route outcome. The composition analogue (supplier returns `nil` → `dataUnavailable`) is already tested. Lower-level owner: `TimetableOccurrenceInventoryTests` |
| Closure occurrences 2,880 | **Yes** | Exact: 480 Trips × 6 dates. +1: one extra view-level domain entry, because the count guard precedes every hold. Last checkpoint reached: `declarations` |
| Closure connections 23,040 | **Yes** | The closure runs before the evidence producer. From 2,049 to 23,040 targets, the closure succeeds and the evidence pre-check throws (last checkpoint `closure`). At 23,041 the closure's own count guard throws (last checkpoint `declarations`). Both end as provisional `searchIncomplete`; the last checkpoint tells them apart. Constructible with view-level `Parts` target edits over ten 72-stop occurrences (71 × 71 valid keys per ordered pair); see W7c |
| Closure dependencies 1,440 | Yes | Already covered end to end (§29.5); not timed |
| Closure total intervals 92,160 | Yes (required intervals may exceed loaded positives) | Not timed. `PreparedInputLimits.intervals` is the **same constant**, so the P interval cap is shadowed by the closure and unreachable at P; lower-level only (`PreparedInternalSearchInputTests` count checks) |
| Evidence relations 2,048 | **Yes** | Exact: one 72-stop occurrence pair with 2,048 distinct (alighting, boarding) targets out of 71 × 71, all qualified absences, no rides. +1: a `Parts` edit, because the fixture world builds its own evidence view and would fail at 2,049. Last checkpoint: `closure`. `PreparedInputLimits.relations` is the same constant, so it is shadowed |
| P occurrence/inventory counts | No | Shadowed by the closure and inventory caps |
| **P rides 4,096** (§29.5 gap) | **Yes, constructible** | 11-stop Trip of distinct stations (`O`, nine intermediates, `D`); 48 declared and required intervals per occurrence, namely the first 48 of the 55 (b, a) pairs in lexicographic order, all inside the window. **Exact:** 85 occurrences × 48 + one occurrence × 16 = 4,096. **+1:** 85 × 48 + 17 = 4,097. Upstream totals: 86 occurrences, 86 recurring Trips, one date label, 4,096/4,097 intervals, 0 relations. All are far below their caps. *Estimated* P payload ≈ 4–5 MB against 96,000,000. P throws `resourceLimit` on the 4,097th usable ride (`rides.count < PreparedInputLimits.rides`) → provisional `searchIncomplete`, last checkpoint `assessment`. At 4,096, `preparedInput` is reached and the solver **always** cuts off during indexing: `snapshotCost` alone charges 4,096 rides × 49,152 = 201,326,592 credits, which is more than the 100M ceiling, whatever the P payload |
| P logical payload 96,000,000 | **Conditional** | Uses near-maximal snapshots: 72-stop Trips and 192-byte tokens. `SolverFixture.Spec` can express at most two line segments and one service segment. Through it, an active slot carries ≈ 1.24 MB of inventory logical bytes (`TimetableOccurrenceInventoryView.bindingBytes`). About 77 slots stay under 96 MB and about 78 go over, while staying under the 120 MB inventory cap. A generator beyond `Spec` with 71 segments of each kind would carry ≈ 3.57 MB per slot (about 26 below, 27 over). Because `prepareThroughProducers` throws at P, the pre-check builds the stages one at a time and reads `assessment.logicalPayloadBytes`. Include the pair only if that confirms 96,000,000 < `assessment.logicalPayloadBytes` with every upstream constructor succeeding. Slot counts are an upper bound, because the assessment also retains closure binding and scope copies; the pre-check fixes the actual pair. Under the cap, the expected outcome is a solver result after `preparedInput`; over it, provisional `searchIncomplete` at `assessment`. Otherwise record it as unreachable; the budget unit test in `PreparedInternalSearchInputTests` stays the coverage |
| Solver winner 256 / work 100,000,000 (configuration ceilings) | Yes | 257 direct ties → `searchIncomplete` before ordering (§25.3). Work cutoffs follow from the shape. Lower positive per-call limits are legal configurations and do not raise any ceiling |

**Discriminator finding.** A preparation `resourceLimit` (provisional mapping) and a solver
cutoff both surface as `searchIncomplete`. The outcome alone cannot tell them apart. The
composition stage trace can: if `preparedInput` was reached, the solver cut off; otherwise the
failing stage is the one after the last checkpoint.

**Legality of repeated-station and zero-duration shapes.**

- `Trip` forbids only *adjacent* duplicate stops.
- `TimetableRideContext` requires departure ≤ arrival.
- `PreparedConnectionGap.permits` accepts departure ≥ arrival + allowance.
- The inventory and closure reject an interval whose two endpoint stations are equal.

So station revisits across Trips, zero-duration rides and zero-gap/zero-allowance connections are
constructor-legal, and §24.2 permits them. A within-Trip repeated station must be non-adjacent;
`InternalRouteSolverTests` already covers repeated original indices.

### 30.4 Workload matrix [P]

**Common rules.**

- **Generation.** Every case is generated by pure deterministic code into
  `[SolverFixture.Spec]` + `[SolverFixture.Link]`, plus `Parts` edits where §30.3 says so. One view
  ID (`uuid(91)`); request `O → D`; `L = 900`; horizon 2,000 s (window ends at 2,900); exact
  invented elapsed instants; invented configuration unless stated.
- **Names and order.** Trip names are zero-padded, so UTF-8 order equals numeric order. Tie
  families store specs in **reverse** name order, matching §25.3's worst-case discovery order.
- **Randomness.** Only W3 uses any: SplitMix64 with seed `0x5453_5547_494E_4F00 + p`, where `p`
  is the feasible percentage. It drives a Fisher–Yates selection over relation indices in
  generator order.
- **Oracles.**
  - The generator emits an **analytic expected identity list** in §24.4 order, built without
    production search code. Examples: a layered Cartesian product, or enumeration of W3's 216
    combinations.
  - When P has ≤ 16 rides, `ExhaustivePreparedSolverOracle` must also agree.
  - Each case also records its expected composition outcome and expected last checkpoint.

| ID | Shape | Sizes | Rides R / relations C | Expected outcome | Why |
|---|---|---|---|---|---|
| W1 | `k` direct Trips `d-NNNN` O→D, dep 1000, arr 1010 | k ∈ {1, 2, 8, 32, 64, 128, 256, 257} | k / 0 | k ≤ 256: success with exactly k one-ride winners in name order. 257: solver `searchIncomplete` (winner cap; `preparedInput` reached) | Equal-optimum identity growth; insertion-order cost; known boundary (256 used 88,479,312 credits in §25.3) |
| W2a | Two layers, width w: `A-NNN` O→H (1000→1010), `B-NNN` H→D (1020→1030); every A→B link `sameStation`, allowance 0 | w ∈ {2, 3, 4, 6, 8, 9, 10, 11, 12} | 2w / w² | Success with the w² two-ride Cartesian winners, or solver `searchIncomplete` (work). *Predicted* boundary w ≈ 9–10 | Branching with rising tie count; per-frame R × C relation scan |
| W2b | Width 2, depth d: stations H0 = O … Hd = D; layer j is 1000 + 20j → 1010 + 20j; all adjacent links; `maximumRides: 8` | d ∈ {2, 3, 4, 5, 6, 7, 8} | 2d / 4(d−1) | Success with 2^d d-ride winners, or solver `searchIncomplete`. *Predicted* boundary d ≈ 6–7 | Depth growth; frame count 2^d − 2 |
| W3 | Layered pattern (as W2a/W2b) with d = 3, w = 6. Exactly `Int((f × 72).rounded(.toNearestOrAwayFromZero))` of the 72 relations are feasible (7 at f = 0.10); the rest are infeasible positives (allowance 15 s > gap 10 s) | f ∈ {1.0, 0.5, 0.25, 0.10, 0.0}; plus W3a: f = 0.10 with the rest as qualified absences | 18 / 72 | Analytic surviving set, possibly empty → scoped `noResults` (always at f = 0), or solver `searchIncomplete`. *Predicted:* cutoff at f ≥ 0.5, completion at f ≤ 0.10 | Mostly infeasible/absent connections. Fewer frames, but every frame still scans all C |
| W4a | 64 rides X→D plus one D→O ride (keeps O in the profile) | — | 65 / 0 | Scoped `noResults` | Completed zero-route: no ride boards at O |
| W4b | Layered pattern with d = 3, w = 4, final layer ending at Z ≠ D, plus one D→Y ride | — | 13 / 32 | Scoped `noResults` after exploring every dead-end prefix | Cost of proving emptiness |
| W4c | 64 O→D rides departing 3000 (> U) | — | P rides 0; 64 `outsideScope` intervals | Scoped `noResults` | R1 out-of-window ledger with an empty universe |
| W4d | W2b with d = 4 and `maximumRides: 3` | — | 8 / 12 | Scoped `noResults` | Ride bound prevents completion |
| W5 | m zero-duration loops at t = 1000: `out-i` O→Aᵢ, `back-i` Aᵢ→O, plus `direct` O→D. Zero-allowance `sameStation` links: out-i→back-i, back-i→out-j for all j, back-i→direct; `maximumRides: 7` | m ∈ {1, 2, 3, 4, 5} | 2m+1 / m² + 2m | Success with exactly one winner, `[direct]`: cycles tie on arrival but have more changes. Or solver `searchIncomplete` at large m | Legal repeated stations and zero-duration rides/connections; exploration with no new ties |
| W5t | Zero-duration O→A→D and O→B→D at t; no direct ride | — | 4 / 2 | Two winners | Ties through zero-duration transfers |
| W6 | Core = W2a with w = 3, plus n filler occurrences of `F-NNN` over the non-profile stations `F-a`, `F-b`, `F-c` with intervals (0,1), (0,2), (1,2), spread over ≤ 6 date labels, one of which must be the core's label (the default `invented-day`); a seventh label makes the inventory throw `resourceLimit` (class S). Maximum: 474 Trips × 6. Filler relations: qualified absences between consecutive filler occurrences (alighting index 2 → boarding index 0), at most min(n − 1, 1,536), so the fixture world stays under 2,048. The searcher profile is **narrowed** to core stations, lines and Trips (same identity and policy references) | n ∈ {0, 96, 384, 1,536, 2,844} | P: 6 / 9 | Success, with identities equal to the n = 0 run. Structural pass shows exactly 6 required occurrences and 9 targets | Supplied-domain growth with substantial out-of-profile filtering (producer cost is linear in the supplied domain) |
| W6p | W6 with n = 384, core Trips extended by a trailing non-profile stop | — | as W6 | As W6; only in-profile intervals remain | Interval filtering inside kept Trips |
| W7r | §30.3 ride boundary | 4,096 / 4,097 | 4,096 / 0 | 4,096: solver `searchIncomplete` during indexing, last checkpoint `preparedInput` (deterministic, §30.3). 4,097: provisional `searchIncomplete`, last checkpoint `assessment` | The missing end-to-end P ride-cap case |
| W7e | §30.3 relation boundary | 2,048 / 2,049 | 0 / 2,048 | 2,048: scoped `noResults`. 2,049: provisional `searchIncomplete`, last checkpoint `closure` | Evidence cap with trivial solving |
| W7o | 480 Trips × 6 dates of 2-stop Trips (the only exact fill under 480 Trips and 6 dates): 4 Trips O→D, so 24 identity-distinct tied direct rides; all others in-profile X→Y | 2,880 / 2,881 | 2,880 / 0 | 2,880: success with 24 winners, or solver `searchIncomplete`. 2,881: provisional `searchIncomplete`, last checkpoint `declarations` | Maximum preparation occurrence volume; prep-heavy cancellation carrier |
| W7c | Ten 72-stop occurrences, no intervals; view-level targets added in lexicographic (from, to, a, b) order over ordered pairs | 23,040 / 23,041 | 0 / 23,040 | Both: provisional `searchIncomplete`. 23,040: last checkpoint `closure` (evidence pre-check). 23,041: last checkpoint `declarations` (closure guard) | Closure connection cap, told apart from the evidence cap |
| W7p | Conditional §30.3 payload pair (≈ 77/78 `Spec` slots) | Set by pre-check | — | Over the cap: provisional `searchIncomplete`, last checkpoint `assessment` | Only if constructible |
| W8 | W2a with w = 8, `maximumWork` ∈ {1,000,000; 4,000,000; 16,000,000; 64,000,000}; other dimensions at the invented ceilings. 64M is the intended completing control | 4 | 16 / 64 | `searchIncomplete` when the limit is below the carrier's completed usage (from the W2a diagnostic), otherwise success | Time-to-cutoff and elapsed time per credit, without raising any ceiling |
| W9 | Cancellation carriers: W7o-2,880 (preparation), W2a w = 8 (exploration), W1 k = 256 (ordering/admission), W2a w = 3 (boundary reference) | §30.6 M8 | — | `CancellationError`, or a completed result when the cancellation arrives after the final checkpoint | Integrated preparation/solve cancellation |

There are 58 unconditional cases plus the conditional W7p pair.

W3's f = 0 case doubles as a completed zero-route case.

**Expected class per case.** The generator emits one fixed expected class wherever the source
fixes it: W1, W4, W5t, W6, both sides of W7r, W7e and W7c, and W7o-2,881. Some cases depend on
how many credits the solver spends: W2, W3, W5, W7o-2,880 and W8. For those the admissible set is
{C with the analytic identities, I-solver}. W7o-2,880 is estimated at about 70M credits, so it
most likely completes with 24 winners. The V-D discovery pass fixes the observed class, and
every later sample of the case must match it.

### 30.5 Escalation ladder, termination and envelope [P]

- **Ladder.** Within a family, sizes run in ascending order. A discovery pass runs each size once:
  structural pre-check, correctness check and one diagnostic call. That pass fixes the admitted
  set for the timed passes.
- **Family stop.** After the first size ending in solver `searchIncomplete` by work, at most one
  more size runs, then the family stops. Larger sizes would only re-measure time-to-cutoff under
  the same ceiling. Fixed boundary pairs (W1 256/257, W7) always run.
- **Per-call watchdog.** 60 s in V-O, 180 s in V-D. The harness cancels its own task (class W)
  and stops the family's escalation.
- **Per-process timeout.** The driver kills an `xcodebuild` invocation after 20 min (class H). No
  automatic retry; the affected family stops. Before the next invocation, the driver terminates
  the test host on that Simulator UDID (`xcrun simctl terminate <UDID> <bundle id>`, or shuts
  the Simulator down) and records that no host process remains, so a later fresh-process memory
  sample is not contaminated.
- **Memory guard.** If `phys_footprint` exceeds 2 GiB between calls, or in the sampler where it
  is used, the harness cancels and stops the family (harness stop, not a route outcome).
- **Correctness failure (class U)** stops the whole experiment. Nothing is timed after a wrong
  result.
- **Setup failure (class S).** If it is a §30.3 documented-unreachable boundary, record it and
  continue. Otherwise stop the family and report it.
- **Envelope.**
  - At most 60 cases (58 unconditional plus the W7p pair).
  - Discovery: 1 call per case.
  - Whole-call timing: V-O 1 warm-up + 7 measured calls per case; the V-D reference is 1 + 3.
  - Stage timing: 1 + 5 per case.
  - Memory: one fresh process per case, 1 + 3 calls.
  - Cancellation: 126 samples (4 preparation targets × 3 δ × 5, 2 solver targets × 3 δ × 5,
    12 boundary checkpoints × 3).
  - Total: 60 + 480 (V-O M1) + 240 (V-D M1) + 360 (M2) + 240 (M7) + 126 (M8) = 1,506. That is
    at most about 1,500 search calls, each bounded by the watchdog.
  - Total wall-clock budget: 4 h. If it is exhausted, the experiment stops and is reported as
    incomplete. That is a harness fact, never a route outcome.
- **These are technical experiment parameters.** They are not production policy, profile,
  horizon, ride cap, timeout or solver ceiling.

### 30.6 Measurements [P]

**Build variants.** Use the explicit iPhone 17 Simulator
`84E47945-9D2E-446F-8C40-B835A9D15880`, or another explicitly selected iPhone Simulator, recorded.
No physical device is used.

- **V-D:** the standard Debug configuration (`-Onone`, `DEBUG`, testability), as in §29.5. Used
  for the correctness gate, the structural pass and instrumented diagnostics.
- **V-O:** the Debug configuration with only these command-line overrides:
  `SWIFT_OPTIMIZATION_LEVEL=-O SWIFT_COMPILATION_MODE=wholemodule`. These are Release's effective
  Swift optimization settings: the `-O` default, and `wholemodule` from the project's Release
  configuration. The `DEBUG` condition and testability remain. Hooks are compiled in but unset in
  minimal timing runs. Its label is **"optimized DEBUG-condition test build" — never "Release"**.
  If V-O fails to build or run, it is dropped and reported; V-D timings remain labelled `-Onone`.
- **Release:** not measurable in-tree (§30.2). This is a recorded limitation, not a blocker.
  Possible later paths need separate authorization: a `Tools/` macOS CLI in the
  `Tools/StorageMeasurement` style, or a Release-compilable measurement host.

| # | Metric | Method | Runs |
|---|---|---|---|
| M0 | Setup cost | `ContinuousClock` around generator + `make` + view + searcher construction | Reported apart from the search |
| M1 | Whole-call elapsed | `ContinuousClock.now` immediately before `try await searcher.search(request)` and immediately after it returns or throws, in a harness-owned `Task` started from a nonisolated test context. Covers the `@concurrent` hop, every stage, terminal construction and unwinding | V-O minimal (no hooks); V-D reference with 1 + 3 calls |
| M2 | Stage elapsed | The composition hook appends `(stage, ContinuousClock.now, Task.isCancelled)` to a preallocated buffer under a `Synchronization.Mutex` (deployment target 18.0); no actor hop or suspension. hop = t(entry) − t_call; S1 = t(configuration) − t(entry); each later stage = t(k) − t(k−1); preparation = t(preparedInput) − t(scope); solve = t(solve) − t(preparedInput) | A separate V-O sample set with composition hooks only (`solver: nil`). Never mixed with M1 samples |
| M3 | Solver internal stages | Solver-hook entry time and `InternalSolverUsage` per stage | V-D diagnostics only; no timing claims |
| M4 | CPU time | `getrusage(RUSAGE_SELF)` user + system delta around the call. Process-wide, not per thread. CPU/elapsed ratio reported | With M1 |
| M5 | Outcome | Class (§30.8), `RouteSearchFailure` case, candidate (winner) count, omission count, `noResults`, scope equality, last checkpoint (hooked runs), SHA-256 of the ordered winner-key summary (`trip/day/b-a`), never the routes themselves | Every call |
| M6 | Logical counters | Structural pass: inventory slots, required occurrences/intervals/targets, P rides, relation states, closure/assessment/P `logicalPayloadBytes`. Diagnostics: solver usage at `.terminal`, or at the last observed stage | V-D |
| M7 | Process memory | `task_info(TASK_VM_INFO)` `phys_footprint` (instantaneous), plus `ledger_phys_footprint_peak` (lifetime peak) when the returned count covers that field; `getrusage` `ru_maxrss` (bytes on Darwin) as secondary. One **fresh test-host process per case**: the driver passes the case via a `TEST_RUNNER_`-prefixed environment variable to `xcodebuild test-without-building -only-testing:`. Samples: F0 at test start; F1 after setup; per call, before, after return (result retained) and after release; peak after each call | V-O, minimal |
| M8 | Cancellation | See below | V-O with composition hooks only; V-D diagnostics |

**Memory derived values.**

- F1 − F0 is setup growth.
- Peak − F1 is approximate call-induced peak growth. It includes allocator retention and the test
  runtime, and it is not per-call allocation.
- The residual after release is also reported.
- If the peak field is unavailable, a 1 ms background sampler approximates the peak. It may miss
  spikes, and the method is recorded.
- Simulator figures are host macOS accounting for the simulated process, not iPhone jetsam
  footprint.

**M8 cancellation.**

- **Request.** The harness reads t_req immediately before `task.cancel()`.
- **Placement.** The hook at the checkpoint preceding the target stage releases a canceller task.
  The canceller sleeps δ × that stage's M2 median, then cancels. δ ∈ {0.1, 0.5, 0.9}.
  Preparation targets: inside `closure`, `evidence`, `assessment`, `preparedInput`. Solver
  targets: W2a w = 8 and W1 k = 256, with δ relative to the median of the whole `solve` stage.
  Solver samples are labelled **"within solve (substage unverified)"**. Their solver substage
  is not observable in V-O. A V-D cross-check with solver hooks reports only the last entered
  solver stage for the same δ values. Exploration and admission are not claimed separately.
- **Classification.** Landing is classified afterwards: the stage whose interval contains t_req.
  The observing checkpoint is the first hook record with `Task.isCancelled == true`; the
  `checkCancellation()` that follows it throws.
- **Preparation latency** = t_obs − t_req. It is bounded by the containing synchronous stage,
  because S6–S8 constructors have no internal checks.
- **Solver observation** happens at the next meter charge, which composition hooks cannot see.
  For every sample, the caller-visible latency t_throw − t_req is recorded. Solver diagnostics
  show only the last entered solver stage.
- **Boundary reference.** The hook cancels its own task at checkpoint k
  (`withUnsafeCurrentTask { $0?.cancel() }`); observation is expected at the same checkpoint.
- **Late cancellation.** A cancellation that arrives after the final checkpoint can return a
  completed result. It is recorded as "completed before observation", is checked like any
  success, and is not a latency sample.

**Warm-up, repetition, order and statistics.**

- **Setup and warm-up.** Each process builds its fixtures before any timing. Then it makes one
  warm-up call per case; that call is recorded with `warmup: true` and excluded from summaries.
- **Rotation.** Repetition r runs the family's admitted cases starting at offset r mod n.
- **Isolation between calls.** Results are released between calls; there are no sleeps.
- **Summaries.**
  - Per case and variant: n, median and [min–max], following the `Tools/StorageMeasurement`
    convention. All samples are retained. No confidence intervals, no pooled percentiles and no
    outlier deletion.
  - Derived: median solve elapsed ÷ solver work credits (ns per credit), per completed or
    cut-off case. This is invented-shape calibration only.

**Metadata recorded per run.**

- **Toolchain:** `xcodebuild -version`, `swift --version`, the SDK and every
  configuration/override.
- **Simulator:** device type, runtime version and UDID.
- **Host:** `sw_vers`, `hw.model`, `machdep.cpu.brand_string`, `hw.ncpu`, `hw.memsize`, power
  source (`pmset -g batt`), load average, and `ProcessInfo.thermalState` at start and end of each
  process.
- **Repository:** HEAD and clean status; SHA-256 of the production routing sources
  (`PreparedRouteSearcher.swift`, `PreparedRouteSearchView.swift`, `InternalRouteSolver.swift`,
  `PreparedInternalSearchInput.swift`, `QualifiedConnectionEvidence.swift`,
  `RequestScopedSearchInputClosure.swift`, `TimetableOccurrenceInventory.swift`) and of every
  harness file.
- **Run:** UTC start and end.

### 30.7 Interpretation boundaries

- **Elapsed is not CPU.** Elapsed includes scheduling and executor hops; CPU is process-wide.
- **Logical is not measured.** Logical credits and bytes are conservative accounting units.
  They are neither heap bytes, allocator retention nor CPU time. Credit-to-time ratios hold only
  for the shapes measured.
- **Process is not per-call.** Process footprint and RSS include the host app, test runtime and
  allocator retention. Call-attributable allocation is not measured.
- **Simulator is not iPhone.** Simulator processes run on the Mac host CPU and memory system.
  Physical-iPhone timing, memory, thermal and jetsam behaviour needs explicit device
  authorization (AGENTS §22).
- **Invented is not representative.** These shapes expose growth and failure handling. They say
  nothing about Tokyo timetable distributions (§16.2); G1/G3 stay open.
- **No variant here is Release.** V-D is `-Onone`. V-O is an optimized DEBUG-condition build.
  Hooked runs are diagnostic.
- **Completion is proved only by the solver's terminal outcome checked against the oracle.**
  Elapsed time, a missing timeout or watchdog silence never certifies completion, and a
  watchdog/harness stop is never `searchIncomplete`.
- **How results are used.**
  - **Optimization candidates:** for example, the linear relation scan repeated per DFS frame,
    `snapshotCost`, or quadratic ordering.
  - **Safeguard sizing evidence:** for example, elapsed time per 100M credits, preparation
    cost per occurrence, and cancellation latency per synchronous stage.
  - **No automatic changes.** No ceiling, mapping, profile, horizon, ride cap, timeout or
    requiredness changes automatically. Any change needs its own decision and authorization
    (§24.6, RULES 29).

### 30.8 Execution containment and outcome classes [P]

- **Concurrency.**
  - Strictly serial: one search in flight, one Simulator, one `xcodebuild` at a time.
  - Run with `-parallel-testing-enabled NO` and a Swift Testing `.serialized` suite.
  - The only concurrent helpers are the canceller, the watchdog and the optional sampler.
  - Overlapping-call correctness is already tested (§29.5); it is not measured here.
- **Output volume.**
  - One `PRS_MEASURE {json}` line per sample, ≤ 2 KB, following the `SELECT_PROFILE` precedent;
    ≤ about 1,600 lines in total.
  - No candidate legs are printed and no partial set is ever printed.
- **Artifacts.**
  - `Tools/PreparedRouteMeasurement/` holds:
    - `README.md`: the method, frozen before any run.
    - `run.py`: the driver.
    - `results.json`: all samples, metadata and fingerprints.
    - `RESULTS.md`: the summary.
  - Raw logs, `.xcresult` bundles and the V-D/V-O DerivedData directories go under
    `/private/tmp/tsugino-prs-measure-<UTC>/`. They are local evidence and are not committed.
    They are kept until the independent review ends, then deleted, and the deletion is recorded.
  - The driver refuses to overwrite an existing run, as `Tools/StorageMeasurement/run.py` does.

| Class | Meaning | Route output |
|---|---|---|
| C | Completed `internalSuccess`: alternatives or scoped `noResults`, checked against the oracle | Counts and digest only |
| R | Expected canonical failure (`dataUnavailable`, `unsupportedRequest`, …) | None |
| I-prep | `searchIncomplete` with no `preparedInput` checkpoint (provisional mapping) | None |
| I-solver | `searchIncomplete` after `preparedInput`: solver cutoff or winner cap | None |
| X | `CancellationError` from an experimental cancel | None |
| W | `CancellationError` (or a stop) caused by the harness watchdog or memory guard | None; a harness event |
| H | External timeout or forced termination of the process; the driver writes the record | None; a harness event |
| S | Setup failure or invalid fixture: a generator or constructor threw, or a structural pre-check failed | None; not a routing result |
| U | Unexpected outcome or identity mismatch | None; stops the experiment |

Unhooked samples (M1, M7) cannot see the last checkpoint. They inherit I-prep or I-solver from
the case's hooked discovery and correctness pass. A mismatch in outcome class against that pass
is class U.

No class other than C carries winners. A partial route set is never output, logged or
summarized. The in-process watchdog **cannot interrupt** the synchronous S6–S8 constructors or
bulk canonical constructors. Only the external per-process timeout ends a stuck synchronous
stage. A C result returned after the watchdog fired is still C, flagged `watchdogFired`, and is
oracle-checked.

### 30.9 Implementation handoff [P]

**Next task scope: test target and `Tools/` only.**

| File (target) | Content |
|---|---|
| `TSUGINOTests/Support/PreparedRouteWorkloads.swift` (TSUGINOTests) | Deterministic W1–W9 generators; profile narrowing; `Parts` edits for the +1 boundaries; analytic expected identities; SplitMix64; expected class and last checkpoint per case |
| `TSUGINOTests/Support/PreparedRouteMeasurementProbe.swift` (TSUGINOTests, `#if DEBUG`) | Mutex clock buffer, `getrusage`/`task_info` probe, canceller, watchdog, optional sampler, JSON-line emitter |
| `TSUGINOTests/PreparedRouteWorkloadTests.swift` (TSUGINOTests) | **Always-run** correctness tests on small sizes: generator determinism, analytic oracle = `ExhaustivePreparedSolverOracle` = composed result (P ≤ 16 rides), W6 filter invariance, W5 legality. Plus the end-to-end boundary pairs W7r (4,096/4,097, closing the §29.5 gap), W7e, W7c and W7o, each asserting outcome and last checkpoint |
| `TSUGINOTests/PreparedRouteMeasurementTests.swift` (TSUGINOTests, `#if DEBUG`, `.serialized`, `.enabled(if:)` on `TSUGINO_PRS_MEASURE == "1"`) | Structural, diagnostic, timing, memory and cancellation passes, selected by `TSUGINO_PRS_PASS` / `TSUGINO_PRS_CASE` |
| `Tools/PreparedRouteMeasurement/` (no target) | README, driver, results and summary (§30.8) |

**Exclusions.**

- Any change under `TSUGINO/` (production code).
- New production APIs.
- `project.pbxproj` or scheme changes; overrides are command-line only.
- Dependencies.
- Changes to ceilings, limits or mappings.
- AppEnvironment, Journey/UI, real or private data, physical devices and Phase 10.

If the always-run boundary tests make the normal suite too slow, gate them like the measurement
suite and record that. They must not be dropped.

**Result schema (one JSON object per sample).** `schema: 1`, `runID`, `utc`, `variant`
(`V-D`/`V-O`), `pass`, `caseID`, `family`, `size`, `seed?`, `repetition`, `warmup`, `class`,
`failure?`, `lastCheckpoint?`, `winners?`, `omissions?`, `noResults?`, `winnerDigest?`,
`wholeNs`, `cpuUserNs`, `cpuSystemNs`, `stageNs{…}?`, `solverUsage{work, slots, keys, bytes,
observedAt}?`, `structural{slots, occurrences, intervals, targets, rides, relationsByState,
closureBytes, assessmentBytes, preparedBytes}?`, `memory{f0, f1, before, after, released, peak,
peakMethod, maxrss}?`, `cancel{target, delta, tReqNs, landingStage, observedAt, latencyNs,
throwLatencyNs}?`, `watchdogFired`, `thermalState`. `results.json` wraps the samples with run
metadata (§30.6) and fingerprints.

**Correctness before timing.**

1. The existing affected suites pass in V-D: the §29.5 regression list plus
   `PreparedRouteWorkloadTests`.
2. Every case's structural pre-check and expected class, identity list and last checkpoint
   pass in the same variant that will be timed.
3. Any mismatch is class U, and the experiment stops.

**Required verification for the implementation.**

- Focused `PreparedRouteWorkloadTests`.
- The §29.5 regression set.
- V-O `build-for-testing`.
- An empty `git diff -- TSUGINO/ TSUGINO.xcodeproj/`, which is the proof that production, the
  project and the scheme are unchanged.
- A Release app build, which shows that Release still compiles.
- All on the explicit Simulator, with the exact commands recorded.

Execution of the experiment itself (§30.5 envelope) belongs to that same authorized task, after
the README method is frozen.

**Independent review.** A non-author reviewer checks:

- Generator constructibility and the expected outcomes.
- Oracle independence: no production search code in the analytic oracle.
- Labels (V-D/V-O, never Release) and the containment classes.
- That the frozen README predates `results.json`.
- That 3–5 reported cases reproduce in a fresh V-O run. Agreement is on class, identity digest
  and order of magnitude, not on exact timings.
- The documentation and Git scope.

**Completion criteria.**

- Tests and builds pass.
- The experiment ran within the envelope, or its stop is reported.
- Every sample is classified.
- `RESULTS.md` and consumer documentation record the figures with §30.7 labels and limitations.
- The review is approved.
- No production diff.

**Blockers: none.** Release-configuration and physical-iPhone measurement, and representative
workloads (G1/G3), are recorded limitations with their own future authorizations. They are not
prerequisites for this invented experiment, and no production policy value is needed to run it.

### 30.10 Independent review and handoff

**Reviewer.** A fresh non-author agent (Claude Code `general-purpose` subagent) reviewed the
design. It started without the author's context and read the current source, fixtures, tests,
project/scheme settings and §24–§29 itself. It worked read-only and ran no builds, tests or
measurements. It is the same model in the same environment as the author, so this is not a
blinded external review. One reviewer performed every round.

- **Round 1 — REQUEST CHANGES.**
  - Material:
    - F1: the closure connection cap was wrongly called shadowed. The closure runs before the
      evidence producer, so it is reachable end to end.
  - Minor:
    - F2: the W7r 4,096 indexing cutoff is deterministic.
    - F3: the W7p slot estimate assumed segment counts that `Spec` cannot express.
    - F4: solver substages are not observable for cancellation landing.
    - F5: the envelope left out the V-D reference runs.
    - F6: unhooked samples cannot classify I-prep vs I-solver.
    - F7: a Release build is not proof that production is unchanged.
    - F8: no cleanup after a forced kill.
    - F9: the W6 date-label constraint was missing.
  - Nits:
    - F10: equal-endpoint interval rejection was missing from the legality note.
    - F11: W3 rounding was unspecified.
    - F12: W8 had no completing control.
    - F13: artifact cleanup was incomplete.
    - F14: this placeholder.
- **Corrections.**
  - F1: new W7c case (23,040/23,041, `closure` vs `declarations`).
  - F2: deterministic W7r expectation.
  - F3: slot estimate through `Spec` (≈ 77/78), stage-by-stage pre-check.
  - F4: "within solve (substage unverified)" label and a V-D cross-check.
  - F5: envelope recomputed to 1,506 calls.
  - F6: class inheritance; a mismatch is U.
  - F7: empty `git diff -- TSUGINO/ TSUGINO.xcodeproj/` as the proof.
  - F8: `simctl terminate` cleanup after class H.
  - F9–F13: applied as described.
  - F14: this record.
- **Round 2 — APPROVE.** The reviewer re-verified F1–F13 against the source, including the W7c,
  W7r and W7p arithmetic, the 58 + 2 case count and the 1,506-call total. It noted three
  non-blocking items:
  - The expected-class paragraph contradicted itself on W7o. Now W7o-2,881 is fixed and only
    W7o-2,880 depends on credits.
  - The W7p slot count is an upper bound. That is now stated.
  - Some lines were long. They are rewrapped.
  All three were applied afterwards.

**Final state.** Documentation only: this section, its governing header, the §29 publication
note and identical overlays in ROADMAP, ARCHITECTURE and the producer proposal. Insertions only;
no historical text was removed. `git diff --check` is clean. A file cannot contain its own
digest, so the SHA-256 values of the four final approved documents are recorded in the author's
hand-off report and in the publication commit's review record, not here.

**Unresolved:** none from review. Open limitations are Release-configuration and physical-iPhone
measurement, and representative workloads (G1/G3). Each needs its own authorization.

**Next safe action:**

1. The owner's publication review of this four-document change.
2. Separately authorize the §30.9 harness implementation and the bounded experiment within the
   §30.5 envelope.

*Status update (2026-10-16):* §30 was published at `c2917e3f511ef33d5b471dc620adc8448723fa88`.
Its harness is implemented and the bounded experiment executed in
[§31](#31-invented-measurement-harness-and-experiment-results--2026-10-16). The "next safe action"
above records the state at §30 publication.

## 31. Invented measurement harness and experiment results — 2026-10-16

### 31.1 Scope and checkpoint

This step was authorized by the owner. It implemented the §30.9 harness and ran the §30 experiment
from checkpoint `c2917e3f511ef33d5b471dc620adc8448723fa88`. At that point HEAD, upstream and the live
branch matched, main was `e8a463d51f14b3cb1027960c63244b694579a71b`, divergence was 0/0 and the
worktree was clean.

- **Changed:** test-target code, `Tools/PreparedRouteMeasurement/` and these documents.
- **Unchanged:** production source, the project and the schemes.
- **Not done:** Release-configuration or device measurement, real or private data, any policy,
  limit or mapping change, and any runtime wiring.

P3-T1 stays scope-incomplete; Phase 3 stays **In Progress**; live/default routing stays unconfigured.

### 31.2 Implemented harness

| File | Role |
|---|---|
| `TSUGINOTests/Support/PreparedRouteWorkloads.swift` | §30.4 generators (58 cases plus the W7p pre-check pair) over `SolverFixture` / `PreparedRouteFixture` and §30.3 `Parts` edits; analytic identity lists in §24.4 order; expected class and last checkpoint |
| `TSUGINOTests/Support/PreparedRouteMeasurementProbe.swift` (`#if DEBUG`) | `Mutex` stage trace; `task_info(TASK_VM_INFO)` and `getrusage` probe; harness-owned call with an elapsed-time watchdog that only cancels; structural pass; class checks |
| `TSUGINOTests/PreparedRouteWorkloadTests.swift` (`#if DEBUG`, always run) | Determinism; analytic = exhaustive oracle = composed result (P ≤ 16 rides); W6 out-of-profile invariance; end-to-end exact/+1 boundaries W7r, W7e, W7o and W7c, including the **4,096-ride case (P built, solver indexing cutoff) versus the 4,097-ride preparation refusal** |
| `TSUGINOTests/PreparedRouteMeasurementTests.swift` (`#if DEBUG`) | The discovery, reference, timing, stage, memory and cancel passes. **Disabled unless `TSUGINO_PRS_MEASURE=1`** |
| `Tools/PreparedRouteMeasurement/{README.md, run.py, results.json, RESULTS.md}` | Method frozen before the run; driver; every sample with metadata and fingerprints (a sanitized derivative of the raw record, §31.7); summary |
| `TSUGINOTests/PreparedRouteHarnessFaultTests.swift` (`#if DEBUG`, always run; added 2026-10-17, after the run) | Deterministic fault injection into the real memory and cancel passes (§31.7) |
| `Tools/PreparedRouteMeasurement/test_run.py` (added 2026-10-17, after the run) | Driver tests with synthetic test-host processes (§31.7) |

Three of these files were corrected after the official run (§31.7). The run's own harness
fingerprints are preserved in `results.json`; the final files did not execute the experiment.

The diff under `TSUGINO/`, `TSUGINOLiveActivity/` and `TSUGINO.xcodeproj/` is empty. There is no
new production API and no dependency. Build overrides are command-line only.

### 31.3 Correctness gate and builds

All runs used the explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880` (iOS 26.3
runtime), Xcode 27.1, Swift 6.4 in language mode 5. No physical device was used.

```text
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Debug -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-prs-gate/dd -resultBundlePath /private/tmp/tsugino-prs-gate/regression.xcresult -parallel-testing-enabled NO -only-testing:TSUGINOTests/PreparedRouteWorkloadTests -only-testing:TSUGINOTests/PreparedRouteMeasurementTests -only-testing:TSUGINOTests/PreparedRouteSearchCompositionTests -only-testing:TSUGINOTests/InternalRouteSolverTests -only-testing:TSUGINOTests/PreparedInternalSearchInputTests -only-testing:TSUGINOTests/QualifiedConnectionEvidenceTests -only-testing:TSUGINOTests/RequestScopedSearchInputClosureTests -only-testing:TSUGINOTests/RouteSearchCoordinatorTests -only-testing:TSUGINOTests/TimetableOccurrenceInventoryTests -only-testing:TSUGINOTests/InternalSearchScopeTests -only-testing:TSUGINOTests/InternalSearchSuccessTests -only-testing:TSUGINOTests/RouteSearchingTests -only-testing:TSUGINOTests/RouteSearchCaptureIntegrationTests -only-testing:TSUGINOTests/AppEnvironmentTests test
xcodebuild -project TSUGINO.xcodeproj -scheme TSUGINO -configuration Release -destination 'platform=iOS Simulator,id=84E47945-9D2E-446F-8C40-B835A9D15880' -derivedDataPath /private/tmp/tsugino-prs-gate/release-dd build
python3 Tools/PreparedRouteMeasurement/run.py run
```

- **Gate:** `TEST SUCCEEDED`, **220 tests passed, 0 failed**. The 6 new workload test functions
  (31 cases) passed in 2.4 s. `PreparedRouteMeasurementTests` was **skipped** by default.
- **Release:** `BUILD SUCCEEDED` with the embedded `TSUGINOLiveActivity.appex`.
- **Variant builds:** the driver's V-D and V-O (`SWIFT_OPTIMIZATION_LEVEL=-O
  SWIFT_COMPILATION_MODE=wholemodule`) `build-for-testing` both succeeded.
- **Harness validation:** before the official run, 14 calls on dev builds exercised each pass
  type. They are excluded from results.

### 31.4 Execution and accounting

| | |
|---|---|
| Duration | Experiment 19:13:13–20:07:42 UTC on 2026-10-16: **3,269 s of the 4 h budget**. Builds came before the experiment clock |
| Calls | **1,460 of the 1,506 ceiling**: discovery 58, V-D reference 232, V-O timing 464, V-O stage 348, memory 232, cancel 126 |
| Processes | 95 test hosts plus 2 builds, all exit 0. There were no external kills, watchdog stops, memory-guard stops, setup failures or class U samples |
| Coverage | All 58 unconditional cases were considered. W2a-12 and W2b-8 were skipped by the §30.5 family stop. The W7p pair was **included at 81/82 slots**, set from actual constructor values: assessment logical bytes 95,596,884 (P built) versus 96,776,154 (P `resourceLimit`). That replaces the §30.3 ≈ 77/78 estimate. 60 cases were admitted |
| Classes | Discovery: 40 C, 12 I-solver, 6 I-prep. Every later sample matched its discovery class. Cancel: 109 X, plus 17 C whose cancellation request came after completion |

**Interpretation applied, as recorded in the frozen README.** W8 is a configuration ladder over
one fixed workload, so the §30.5 family stop was not applied to it and all four limits ran.

### 31.5 Measurements

[`RESULTS.md`](../Tools/PreparedRouteMeasurement/RESULTS.md) holds the tables and
`results.json` holds every sample. Figures are medians [min–max] on the Simulator in V-O, the
optimized DEBUG-condition test build (not Release). **Whole-call** figures come from the unhooked
timing pass. **Stage** figures come from the separately run, hooked stage pass; they are not
additive with whole-call figures.

**Elapsed time.**

- Whole call: the slowest completed call was W1-0256 at 93.1 ms [65.9–117.2].
- Whole call: every 100M-credit solver cutoff returned in ≤ 20 ms median (max 47.6 ms).
- V-D was about 3–107× slower than V-O (ratio of whole-call medians from separate passes, carrying
  the ≈ 2× variation).
- Stage pass: preparation dominates the large-domain shapes:
  - W7o-2880: closure 15.6 ms, preparedInput 11.6 ms, solve 3.8 ms.
  - W6-2844: preparation 17.1 ms, solve 0.35 ms.
- Stage pass: solve dominates the tie-heavy shape, with W1-0256 solve at 72.7 ms.

**Cutoff points under the invented envelope.**

- W2a: from width 10 (20 rides, 100 relations).
- W2b: from depth 6.
- W3: from 50% feasible.
- W5: from 5 loops.
- W1: at 257 ties (winner cap).

**Logical versus measured.**

- Stage-pass solve time per completed credit ranged from about 0.02 to 0.8 ns. W7p-81 (≈ 0.0002) is excluded:
  its credits are almost all the inherited-payload charge.
- Out-of-profile filler raised solver credits (2.44M → 9.67M), because P's inherited payload is
  charged as work, while solve time stayed at about 0.35 ms.
- Memory figures are **process-level observations** from one fresh process per case:
  - Baseline F1 is `phys_footprint` after the workload and searcher were built, before the
    warm-up call.
  - `peak` is the process-lifetime `ledger_phys_footprint_peak`, read after each of the 4 calls.
    It was available in every process, so no sampling was used.
  - The largest peak − F1 was 8.2 MiB (W7c-23040).
  - The lifetime peak also covers setup, the test runner and every thread, and footprint does not
    grow when a call reuses allocator-held pages. The figure is therefore neither per-call
    allocation nor an upper bound on call-attributable peak memory.
- W7p's ≈ 96 MB of logical bytes came with ≤ 2.9 MiB F1 − F0 process growth.
- Process-wide CPU / whole-call elapsed was ≈ 0.8–1.3.

**Cancellation.**

- Boundary self-cancel was observed at the same checkpoint in 36/36 samples.
- Preparation observations always came at the next checkpoint. Their latency never exceeded the
  containing synchronous stage (0/50 exceptions); the maximum was 11.6 ms (closure, W7o-2880).
- The caller-visible solver throw latency had a median of about 0.2 ms and a maximum of 6.1 ms;
  the substage was not verified.
- δ targeting drifted to later stages, so evidence-stage coverage is 2 samples.

**Variability and load.**

- Absolute milliseconds vary by about 2× between processes and runs. Examples:
  - Hooked stage-pass medians reach about 2× the unhooked timing pass in 21 cases.
  - Two identical 54.8M-credit solves took 8.7 ms and 4.7 ms.
  - The reviewer's 18-call rerun measured about half the official stage figures, with identical
    classes and digests.
- Stage figures are within-process splits. They are not comparable with whole-call medians.
- Host load was recorded only once, before the builds: 115.71 / 69.16 / 36.27. That deviates from
  §30.6's per-process requirement; the driver now records load per process.

### 31.6 Interpretation and limits

These figures are invented stress evidence for later decisions. They are not deployment
suitability.

- **Optimization candidates** (owner-gated, RULES 29):
  - The exhaustive DFS cuts off on small branching shapes (20 rides).
  - Solve cost grows with tie count. Per-frame linear relation scans and tie ordering are the
    suspected cause; this has not been profiled.
  - Preparation constructors dominate the large-domain shapes.
- **Safeguard evidence:**
  - Credit ceilings bound elapsed time only shape by shape.
  - Logical-byte accounting is far larger than the observed process footprint.
  - Cancellation responsiveness inside preparation is bounded by single synchronous stages.
    These were of order 10 ms here (max 11.6 ms observed). That is subject to the ≈ 2×
    run-to-run variation, and it is not a latency bound.

None of this changes a ceiling, mapping, profile, horizon, ride cap, timeout or requiredness.

**Limitations.**

- V-D and V-O are not Release.
- The Simulator is not an iPhone.
- The shapes are invented, not representative workloads (§26.2 G1/G3 remain).
- Memory is process footprint relative to a post-setup baseline: not per-call allocation and not
  a bound on call-attributable memory.
- Solver usage at a cutoff is a lower bound.
- The cancellation solver substage is unverified.
- One host and one run; absolute ms vary by about 2×; load was not recorded per process.

§26.2 G4 now has invented Simulator evidence only. G3, G5 and the physical-device part of G4
remain open.

### 31.7 Independent review and handoff

**Reviewer.** A fresh non-author agent (Claude Code `general-purpose` subagent) reviewed the
work with no author context. It is the same model in the same environment, so this is not a
blinded external review. One reviewer performed every round.

**Reviewer's own runs** (explicit Simulator, its own DerivedData under
`/private/tmp/tsugino-prs-review-20261016/`, no repository change):

- V-D `PreparedRouteWorkloadTests` passed, and the measurement suite was skipped.
- The V-O `build-for-testing` succeeded.
- One bounded V-O stage-pass rerun of W1-0256, W7o-2880 and W6-2844 used **18 search calls**,
  separate from the 1,460 official calls. Classes, winner counts, digests and last checkpoints
  were identical. Absolute times were about half the official ones.

**Round 1 — REQUEST CHANGES.**

- **Material — F1:** run-to-run variation (≈ 2×) and the load deviation were not disclosed, and
  stage figures were set beside whole-call medians.
- **Minor:**
  - F2: the process count was wrong (95, not 97).
  - F3: the V-D/V-O ratio was wrong (3–107×, not 10–70×).
  - F4: in the memory pass, a watchdog event would have become class U; the cancel pass did not
    reconcile unexpected outcomes. Neither occurred in this run.
- **Nits (F5):** suite time 2.4 s; "no harness stops"; the W7p-81 exclusion from the ns/credit
  range; `#require` before the oracle precondition; W6p specs not in reverse name order.

**Corrections.**

- F1–F3 and the F5 text items: RESULTS.md and §31.4–§31.6 were corrected.
- F4 and the `#require` nit: harness code was changed in `PreparedRouteMeasurementTests.swift` and
  `PreparedRouteWorkloadTests.swift`.
- The driver now records `vm.loadavg` at the start and end of each process.
- The W6p order nit was left unchanged; W6p specs stay in generator order. It does not affect
  correctness, and the measured case must match its recorded definition.
- **These code changes came after the run.** The run's harness fingerprints in `results.json` are
  the pre-correction ones, and the corrected memory/cancel/driver paths have not run an
  experiment.
- After the corrections, the author re-ran `PreparedRouteWorkloadTests`, the measurement suite
  (skipped) and `PreparedRouteSearchCompositionTests`: **24 tests passed and 1 was skipped** (Swift Testing reported 25). The V-O
  `build-for-testing` and Release-unaffected checks also passed: the diff under `TSUGINO/`,
  `TSUGINOLiveActivity/` and `TSUGINO.xcodeproj/` stays empty.

**Round 2.** The reviewer approved the corrected files on 2026-10-16.

**Gap closure (2026-10-17).** No existing check had exercised the three post-run fixes:

- The post-correction run skipped the measurement suite.
- The reviewer's rerun came before the corrections.
- A compilation pass alone does not exercise them.

Deterministic, bounded checks were therefore added and run:

- **Swift fault injection** (`PreparedRouteHarnessFaultTests`): the real memory and cancel passes
  and the real emitter. Only the searcher is replaced, through a test-target factory in
  `PRSRunner`; no production seam was added.
  - A watchdog stop in the memory pass becomes class W and ends that case.
  - R, I and wrong-identity C outcomes in the cancel pass become class U and stop the pass.
  - X, W and oracle-checked C outcomes are admitted.
  - Result: 8 functions (9 cases) passed. Restoring the exact run-time code made 4 of 8
    functions (5 of 9 cases) fail.
- **Driver tests** (`test_run.py`): synthetic child processes.
  - Covered: per-process `loadStart`/`loadEnd`, the class U halt, the H paths, the memory guard,
    the envelope and the `results.json` schema.
  - Result: 8 passed (9 after the sanitization test was added, below). Removing the load fields
    made 2 fail.

**Retrospective check.** The recorded data shows the fixes would change no classification:

- No call fired the watchdog.
- The cancel pass recorded only X and C, and all 17 C digests equal their discovery
  digests, which were checked analytically (W2a-08 also by the exhaustive oracle).

No rerun was made, and the recorded results were not rewritten. The full evidence, call
accounting and remaining unverified behaviour are in RESULTS.md, "Post-run harness changes and
their verification".

**Publication sanitization (2026-10-17).** The committed `results.json` is a sanitized derivative
of the raw run record, not a byte-identical copy.

- **Raw record:** SHA-256 `5ae1014a15cf4fba3f12f4dd42ee66c604debcef30e5bbd4a9e2e29132420664`, preserved outside version control in the run's raw-evidence
  directory as `results.raw.json`.
- **What changed:** only metadata.
  - The battery identifier in `metadata.host.power` became `(id=<removed>)`.
  - The absolute checkout path in the 2 recorded build commands became `<repo>`.
  - A `sanitization` object records the raw SHA-256, the transformed fields, the placeholders and
    the reason.
- **Structural comparison:** exactly these 4 differences. Records, sample values, timestamps,
  outcomes, route digests, counts, ordering and run-time fingerprints are identical.
- **Driver:** the final `run.py` now records only the power-source line and writes `<repo>` in
  recorded build commands. A synthetic regression test was added to `test_run.py`, and the driver
  tests pass (9 of 9).
- **Not changed:** the Swift tests, the experiment and the frozen README.

The final verdict and the approved SHA-256 values are recorded in the author's hand-off report.
A file cannot contain its own digest.

**Raw evidence.** `/private/tmp/tsugino-prs-measure-20261016T190846Z`, `/private/tmp/tsugino-prs-gate`,
`/private/tmp/tsugino-prs-dev` and the reviewer's directory are local only. They are to be deleted
after the owner's publication review, and the deletion recorded. Before that deletion, the owner
decides where to keep the raw `results.raw.json`, which is the only byte-exact run record.

**Next safe action.**

1. The owner's publication review of this change set. It has 5 test files, 5 Tools files and 4
   documents, and no production change.
2. Then, separately and owner-gated:
   - Choose whether to investigate the measured optimization candidates (§31.6) or to gather
     real-workload evidence (G1/G3).
   - Physical-iPhone or Release measurement each need their own authorization.

## 32. Bounded solver optimization audit — 2026-10-17

### 32.1 Scope, authority and evidence

The owner authorized a read-only, evidence-led audit of `InternalRouteSolver` and the selection
of one small optimization slice. It started from `4dfb8e50920368358c9e1b304d7a23749cc10807`, which
publishes §31. HEAD, upstream and the live branch matched, main was
`e8a463d51f14b3cb1027960c63244b694579a71b`, divergence was 0/0 and the worktree was clean.

- **Evidence used:** the committed solver and composition source, the §30.4 generators,
  `Tools/PreparedRouteMeasurement/README.md`, `RESULTS.md` and the sanitized `results.json`.
- **Not used:** private evidence folders, the archived raw record, external-drive files and
  temporary logs.
- **Nothing executed:** no source, test or harness change; no build, test, workload or profiler run.
- **Authority unchanged:** §24.3–§24.8, DEC-086 and Rule 29 still govern. There is no new product
  decision.

**Method.**

- **Charge model.** The author wrote an arithmetic replica of every `SolverKernel` charge formula
  in `TSUGINO/Data/Routing/InternalRouteSolver.swift`, including the default `work: 1` of every
  `charge(slots:/bytes:)` call. It ran over the generator structure for W1, W2a, W2b, W3, W3a, W5
  and W8. This is a calculation over committed definitions; it executes no TSUGINO code.
  `preparedBytes` from `results.json` supplied P's inherited payload.
- **Validation.** For all **37 of 37** recorded discovery observations in those families, the
  model reproduces exactly:
  - the recorded `solverUsage.work` at the recorded `observedAt` stage entry (terminal for
    completions, the last observed entry for cutoffs);
  - the recorded class;
  - the stage reached.

  The model is a scratch derivation, not a committed artifact. Reviewers re-derive it.

Three quantities are kept apart below:

- **Logical credits:** deterministic meter units. They bound work and storage; they are not time.
- **Operation counts:** loop iterations, relation inspections, comparisons and `meter.charge`
  calls, derived from code and workload structure.
- **Measured time:** only what `results.json` records. That is the V-O whole-call and stage-pass
  medians, plus the V-D discovery `solverStageEntryNs`: one hooked Debug call per case, which
  gives solver-stage boundaries.

### 32.2 Charge structure (source)

Principal charges only. Small unit charges are omitted: per-winner `enter`, `1` per token and
per edge, slot-only charges and the per-ride order-key `n`.

| Site (`InternalRouteSolver.swift`) | Charge |
|---|---|
| `validateAndIndex` | P's whole logical payload as work once; per ride `4096 × (stops + 1)` snapshot; per ride an outgoing scan of `4096` per inspected relation until the first feasible match (all R if none); per relation `4096` evidence check |
| `relation(_:)` | Linear scan of `input.connections`, `4096` per inspected relation, stopping at the first equal key; a miss inspects all R |
| DFS loop (`run`) | `1` per loop step; `4096` per candidate ride; `1024` per prior path ride in the trip-repeat check; `relation` for every non-root candidate that passes the trip check |
| Tie collection | `winner.count + 1` per existing winner in the exact-duplicate scan; `path.count` plus storage per appended winner |
| Ordering | Insertion sort: `1` per comparison attempt and `1` per swap; `less` charges `1` per token pair, `1` (plus storage) per differing pair, and `1` per compared UUID/trip/day byte |
| Admission (per winner) | `makeClaim`: snapshots and one `relation` per transition; `admit`: `4096 × n`, a second `relation` per transition, `1024` per trip pair, two more snapshot sets, `1024 × n²` |
| Finalization (per winner token) | `snapshot + 1024 × (profile stations × stops + profile lines × line segments + profile trips)` |

Every `charge` call also runs `Task.checkCancellation()`. It builds three four-element arrays and
a `zip` before its guard, whatever the amount charged.

### 32.3 Where credits go (derived, model-validated)

**W2a: width 9 completes, width 10 cuts off.**

- Rides P = 2w; relations R = w², all feasible; w² tied winners.
- DFS relation inspections are exactly `w³(w − 1) + w²(w² + 1)/2`:
  - each `A_i` node tries w − 1 other `A` rides, each a full-R miss;
  - it tries w `B` rides, each found at from-major position `i·w + j + 1`.
- Admission inspects another `2 · w²(w² + 1)/2`: the claim and the admit for each winner's single
  transition.
- Every inspection costs 4,096 credits.

| w | DFS inspections | Admission inspections | Credits to complete | Recorded |
|---:|---:|---:|---:|---|
| 8 | 5,664 | 4,160 | 54.84M | C (54,840,071) |
| 9 | 9,153 | 6,642 | 83.97M | C (83,974,702) |
| 10 | 14,050 | 10,100 | 123.72M | I-solver |
| 11 | 20,691 | 14,762 | 176.45M | I-solver |

- **W2a-10:** exploration (58.67M) and ordering finish.
  - **Recorded evidence:** the last observed stage entry is admission (99,915,309), and
    finalization was never entered.
  - **Model-derived:** the meter runs out inside the 82nd of 100 winners. The model's usage at
    that winner's admission entry equals the recorded 99,915,309 exactly.
- **W2a-11:** cuts off inside its 25th admission.
- **Share:** relation scans (DFS, claim, admit and the indexing outgoing scan) are about 79–95% of
  the credits consumed for w = 8–11 (up to the cutoff where one occurs).

**W2b: depth.**

- Width 2 and depth d give 2d rides, R = 4(d − 1), and 2^d tied winners of d rides each.
- Credits needed grow about 2.7–2.9× per level: 37.31M at d = 5, then 106.04M, 285.48M, and
  ≈ 738M at d = 8. The d = 8 figure excludes the unrecorded inherited payload of about 0.1M.
- Exploration and admission split almost evenly. Relation scans are 58–66% of W2b-5/6 credits;
  most of the rest is per-winner snapshot and finalization accounting for the 2^d winners.
- **W2b-6:** cuts off in finalization, matching the recorded last stage.
- **W2b-7:** cuts off in the DFS after its last observed `tieCollection` entry, before `ordering`.

**W3: usable-connection density.**

- R is fixed at 72, but infeasible relations are still scanned and found, so density acts through
  the number of expanded nodes.

| Feasible | Nodes | DFS inspections | Winners | Credits to complete | Recorded |
|---:|---:|---:|---:|---:|---|
| 0 | 6 | 0 | 0 | 6.08M (87% indexing outgoing scan) | C |
| 7 | 10 | 2,943 | 2 | 19.60M | C |
| 18 | 21 | 7,656 | 9 | 44.47M | C |
| 36 | 79 | 24,408 | 55 | 155.20M | I-solver (DFS) |
| 72 | 258 | 43,110 | 216 | 370.21M | I-solver (DFS) |

**W5: loops.** One winner, but every loop rotation is a full DFS branch. Credits to complete:
35.17M at m = 4 and 141.88M at m = 5; m = 5 cuts off in the DFS. Relation scans are 83–89% of
the credits consumed.

**W1: 256 tied direct routes.**

- There are no relations. 81% of W1-0256's 88.21M credits is finalization membership accounting:
  `(2·2 + 1 + 256) × 1024 + 12,288` = 279,552 per winner, × 256 = 71,565,312. It is proportional
  to profile trips × winners.
- **W1-0257:** this is the 257th distinct tie hitting the 256-winner cap, a structural limit. Only
  5.12M credits were used.

**W6/W7: preparation-dominated shapes.**

- **W6:** solver credit growth is exactly the inherited-payload charge: 9,672,541 − 2,444,041 =
  7,228,500, which is P's growth. Time is outside the solver: V-O preparation 17.1 ms against
  solve 0.35 ms.
- **W7o-2880:** V-O closure 15.6 ms, preparedInput 11.6 ms, solve 3.8 ms.
- These costs belong to the preparation constructors, outside `InternalRouteSolver`, and would
  need constructor profiling. Not addressed here.

### 32.4 Credits are not time; operation count tracks time

**Ordering dominates measured V-D solve time.** In the V-D discovery stage entries, ordering is
the largest solver segment for every tie-heavy shape:

| Case | Ordering (V-D, one call) | Solve (V-D) | Ordering credits |
|---|---:|---:|---:|
| W1-0256 | 5,350.6 ms | 5,691 ms (94%) | 0.80M (0.9% of credits) |
| W1-0128 | 1,532.2 ms | 1,626 ms | — |
| W2a-09 | 514.1 ms | 691 ms (74%) | 0.08M |
| W2b-5 | 110.6 ms | 207 ms | — |

**Calls, not credits, track V-D time.**

- Selection: 8 cases (W1-0064, W1-0128, W1-0256, W2a-08, W2a-09, W2b-5, W3-025, W5-4). Their
  exploration and tie-collection segments are merged into one, and only segments with more than
  1,000 modeled `charge` calls count: 22 segments.
- Over those 22, segment time is 6.3–12.7 µs per call (median 8.4). The Pearson correlation between calls and
  segment milliseconds is r = 0.9993.
- Credits do not track time. W1-0256 finalization is 71.6M credits and took 5.9 ms.

**V-O agrees, with less certainty.**

- Over 25 completed cases, V-O stage-pass solve medians correlate with modeled total calls at
  r = 0.997, and with credits at only r = 0.674. The cases are the W1, W2a, W2b, W3 and W5
  completions plus W8-064M. W3a-010 was not included; with it the values are 0.997 and 0.673.
- **Caveats:**
  - W1-0256 dominates the fit.
  - V-O records no solver-internal split.
  - The ≈ 2× run-to-run variation (§31.5) applies.
  - Correlation is not attribution.

**What this means.**

- **Cutoffs** are credit exhaustion, dominated by the 4,096-credit linear relation inspections.
- **Elapsed time** in these shapes tracks the number of fine-grained operations.
- For tie-heavy shapes, the largest single source of operations is the O(W²) insertion sort's
  byte-wise comparisons: 795,941 of W1-0256's 833,457 modeled calls and 81,325 of W2a-09's 103,882.
- The winner input arrives in descending §24.4 order in W1 and W2a, so they hit the insertion
  sort's worst case.
- Which instructions in V-O dominate per call (allocation, cancellation check, byte loop) is
  **suspected, not measured**. That needs profiling.

### 32.5 Candidates

| # | Candidate | Concrete change | Effect (derived) | Proof obligations and risks | Cancellation | Evidence still needed | Scope |
|---|---|---|---|---|---|---|---|
| 1 | **Metered merge-sort ordering** | Replace the insertion sort with a bottom-up merge over an `Int` index permutation, using the unchanged `less`; materialize the permuted winners once | Comparisons ≤ W⌈log₂W⌉ (≤ 2,048 at the 256-winner cap) instead of up to W(W − 1)/2 (32,640). W1-0256: 32,640 → 1,024 comparisons, ordering calls 795,941 → 26,939, total calls 833,457 → 64,455, credits −0.77M. W2a-09: 3,240 → 242 comparisons. Classes, cutoff stages and winner order unchanged in every modeled case | `less` must be a strict total order on the distinct winner set (§32.6), so the sorted sequence is unique and algorithm-independent. Scratch index and permuted-copy storage must be charged before allocation. Every comparison and move is charged | Same per-charge cancellation check; stage entry unchanged | Matched V-O and V-D runtime (§32.6) | One function in one file, plus tests |
| 2 | Comparator: skip the UUID byte loop | All ride keys share `input.scope.viewID` (guarded in `validateAndIndex`), so 16 equal UUID bytes are compared on every differing pair | About 16 of ~24 calls per differing comparison | Relies on the single-view guard; §24.4's field order is kept by construction. Small risk, but it touches the identity comparator | Unchanged | Same as #1 | Small. **Deferred** as a possible follow-up once #1 is measured |
| 3 | Per-ride outgoing relation lists | During indexing, record every relation whose from-key equals the ride's (address, alighting index). The DFS and `makeClaim` scan only that list | Large credit reductions in W2a, W2b, W3 and W5. Would likely move some recorded cutoffs (for example W2a-10) to completion | Construction must scan all R per ride (no early exit): more indexing credits, and entries are metered storage up to P·R in the worst case. `admit` must not trust claimed tokens, so it keeps an independent full-relation lookup or an equivalent proof. Equality of the full key is still required | Same checks; larger indexing segment | Credit and runtime measurement; design review of `admit` independence | Moderate. **Not selected:** larger proof surface; it changes recorded outcomes, not measured time first |
| 4 | Drop the tie-collection duplicate scan | The DFS enumerates each token sequence once, so duplicates cannot occur | W1-0256: about 32,640 fewer calls (≈ 4%) | A tree-enumeration invariant replaces a defensive exact check (§24.3 dedup duty) | Unchanged | — | **Rejected for now:** small gain against removing a defensive check |
| 5 | Accounting changes (finalization membership 1024 × profile size; inherited payload as work) | — | Credits only; no measured time effect | The existing charges are conservative but not shown to be unjustified | — | — | **Rejected:** fails the "demonstrably unjustified" test |
| 6 | Preparation constructors (W6/W7) | — | V-O 10–40 ms whole call | Outside the solver | — | Constructor profiling | **Deferred** to a separate task |

None of the candidates raises safeguards, truncates ties, prunes on equality, adopts dominance or
station-visited pruning, or changes identity, objective, permissions, requiredness, connection
semantics or admission.

### 32.6 Selected next slice: metered merge-sort ordering

**Components.**

- `SolverKernel.run()`, ordering stage only (`InternalRouteSolver.swift`).
- `less` and every other stage stay unchanged.
- §25's "metered insertion sort" description is updated by that task.

**Algorithm justification.**

- **The order is unique.** Within one P, ride keys are unique: P rejects equal keys, including
  Swift String canonical equivalence. Distinct keys are therefore distinguished by §24.4's fields:
  unequal Strings have unequal UTF-8 bytes. Winners are distinct token sequences, and the prefix
  rule makes `less` total. So `less` is a strict total order on any winner set, and the sorted
  sequence is unique. Merge sort and insertion sort must produce byte-identical output.
- **Modeled check.** The model confirmed this for every case above, and for reverse, sorted and
  seeded-random discovery orders at W ∈ {0, 1, 2, 3, 7, 8, 9, 255, 256}.
- **Deterministic tie rule.** The merge takes the left element unless `less(right, left)`.

**Accounting and resources.**

- **Storage first.** Before allocating, charge the index and scratch buffers (2W slots,
  16W + header bytes) and the materialized permuted winner array (W slots plus the existing
  per-winner byte basis).
- **Per-step charges.** Charge `1` per comparison attempt (as now) and `1` per element move.
- **No opaque sort.** No stdlib sort and no uncharged callback (§24.6, §25). Credits stay
  cumulative and are never refunded.
- **Cutoffs.** A cutoff inside ordering stays `searchIncomplete` with no output.

**Cancellation.** Every comparison and move goes through `charge`, which checks cancellation. The
stage entry and hooks are unchanged, so `cancellationAtEveryStageWinsPendingFailure` still applies.

**Regression and oracle cases** for the later task:

- the existing `InternalRouteSolverTests` ordering tests (`orderedForTesting`), cancellation and
  cutoff tests;
- the existing `PreparedRouteWorkloadTests` (analytic, exhaustive oracle and composed result);
- new adversarial discovery orders (descending, ascending, seeded permutation) at
  W ∈ {0, 1, 2, 3, 7, 8, 9, 255, 256};
- a cutoff landing inside ordering (a configuration chosen from the charge model): it must be
  `searchIncomplete`;
- cancellation inside ordering via the existing stage hook;
- a work assertion that ordering comparisons stay at or below W⌈log₂W⌉.

**Matched before/after subset (10 cases).**

- W1-0064, W1-0128, W1-0256;
- W2a-08, W2a-09;
- W2b-5;
- W1-0257, which must keep its winner-cap cutoff;
- W2a-10, which must stay I-solver in admission;
- controls with almost no ordering: W3-025 and W5-4.

**Metrics.**

- Class, winner count and winner digest must be identical to `results.json` for every case.
- Exact solver credits must equal the charge-model prediction:
  - W1-0256: about 87.44M under this audit's modeled scratch charges. The implementation task
    re-derives the exact figure from its final charge formulas before running;
  - W5-4: +2, from the two storage preflights that also run for a single winner. The
    implementation task re-derives this figure too.
- V-D hooked solver stage entries (ordering segment), one call per case per build.
- V-O timing-pass `wholeNs` and stage-pass `solve`, n = 7 plus warm-up, before and after builds
  alternated in the same session, on the explicit Simulator.

**Acceptance.**

- **Correctness:** all correctness metrics are identical, and all existing and new tests pass.
- **Comparisons:** the comparison bound holds.
- **Runtime:** in both of two alternated rounds, the after-build V-O stage-pass solve median for
  W1-0128 and W1-0256 is ≤ 0.5× the before-build median. That threshold equals the ≈ 2×
  between-process variation, so it is meaningful only when before and after are paired and
  alternated in one session.
- **Reporting:** the controls are reported without a claim.
- **If the runtime criterion fails,** report it as a negative result, not an improvement.

**Execution envelope for that later validation.**

- **Calls:** at most 660 search calls in total:
  - V-O timing pass: 10 cases × 8 calls × 2 builds × 2 rounds = 320;
  - V-O stage pass: the same, 320;
  - V-D hooked: 10 × 2 builds = 20.
- **Time and processes:** 2 h wall clock; 20-minute per-process cap; watchdog 60 s for V-O and
  180 s for V-D. §31 ran 1,460 calls over a heavier matrix in 54.5 min.
- **Execution:** strictly serial; invented data only; explicit Simulator only; no device.

**Exclusions.**

- Candidates 2–6.
- Any safeguard or limit change, and any comparator, identity or accounting change outside the
  ordering stage.
- Release or device claims; production adoption.
- Preparation constructors.

### 32.7 Remaining uncertainty

- V-O per-stage time is not recorded. Ordering's V-O share is inferred from the call correlation,
  not measured.
- Why a V-O `charge` call costs about 70–190 ns on average (aggregate ≈ 96 ns), and whether it is
  array construction, the cancellation check or loop overhead, is a suspicion that needs
  profiling. The slice does not depend on it,
  because it reduces the operation count itself.
- The charge model covers the solver only, and only the seven families validated above.
- The derived counts are not measurements.
- The selected slice changes no recorded cutoff:
  - W2a-10 still needs about 123.7M credits;
  - W2b-6 still needs about 106.0M.
  Those are relation-scan bound; candidate 3 is the evidence-supported follow-up for them.

P3-T1 stays scope-incomplete; Phase 3 stays **In Progress**; live/default routing stays unconfigured.

## 33. Metered merge-sort winner ordering: implementation and matched validation — 2026-10-17

### 33.1 Scope and checkpoint

The owner authorized implementing §32.6 and running its matched validation. It started from
`3368eb13d102831ba473b84e13cb0f0329451cf6`, which publishes §32. HEAD, upstream and the live branch
matched, main was `e8a463d51f14b3cb1027960c63244b694579a71b`, divergence was 0/0 and the worktree
was clean.

**Changed:**

| File | Change |
|---|---|
| `TSUGINO/Data/Routing/InternalRouteSolver.swift` | The ordering stage only |
| `TSUGINOTests/InternalSolverWinnerOrderingTests.swift` | New tests |
| `TSUGINOTests/PreparedRouteMeasurementTests.swift` | Two harness options, off by default |
| `Tools/PreparedRouteMeasurement/WinnerOrdering/` | New experiment folder |
| These documents | This record |

**Unchanged:**

- the relation lookup, the `less` comparator fields, identity, dedup and the objective;
- the winner cap and every other safeguard ceiling;
- admission, finalization, preparation and composition;
- policy, requiredness, G2 and dependencies;
- the project and the schemes.

No selectable legacy algorithm remains in production. The §31 files are unchanged. §25's
"metered insertion sort" description is historical for the ordering stage.

### 33.2 Algorithm, proof and accounting

**Algorithm.** `SolverKernel.ordered(_:)` is a bottom-up merge sort over an `Int` index
permutation, using `less` unchanged. It takes the left element unless `less(right, left)`. After
sorting, the winners are materialized once in permuted order.

**Correctness.** Ride keys in P are unique, including Swift String equivalence, and distinct keys
differ in §24.4's byte or numeric fields. So `less` is a strict total order on distinct winners
(§32.6). The sorted sequence is unique and equals the previous insertion-sort output. Every tied
winner is preserved, and the handoff to admission is unchanged.

**Accounting**, all on the one uninterrupted invocation meter:

| Item | Charge |
|---|---|
| Preflight before allocation | One charge for the index, scratch and output buffers: `slots 2n + 1`, `bytes 16n + 8n + 72`, work 1 |
| Comparison | `1`, plus the unchanged `less` charges (including its per-differing-pair scratch) |
| Element move | `1` |
| Retained output copy | Per winner, by value: `slots count + 1`, `bytes 8·count + 24`, work 1 |
| Run width | Doubled with the overflow-reporting `InternalSolverMeter.product` |

- At most n⌈log₂n⌉ comparisons.
- **Cancellation:** every charge checks it, so it is observed at the next comparison, move, copy
  or stage checkpoint.
- **Cutoff:** any cutoff is `searchIncomplete` with no output.

### 33.3 Tests and builds

All runs used the explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`. No device
was used.

**New `InternalSolverWinnerOrderingTests`: 5 functions, 34 cases.**

- **Canonical order and exact accounting:** W ∈ {0, 1, 2, 3, 7, 8, 9, 255, 256} × ascending,
  descending and seeded-permuted discovery orders.
  - Each case is checked against an independent test-side order, and against the exhaustive oracle
    when P ≤ 16.
  - The ordering-stage work, slots and bytes are checked exactly. Their expected values come from a
    test-side replay of the merge, using an independent replica of the comparator's charges.
  - Comparisons stay at or below n⌈log₂n⌉, and descending W = 256 makes exactly 1,024.
- **Multi-ride and identity-edge ties:** equal prefix tokens, decomposed versus precomposed
  spellings with distinct dates, numeric original indices, and both spec orders. All match the
  oracle.
- **Resource boundaries:** exact final usage completes, and one unit less in any meter dimension
  refuses, at W = 9 and W = 256.
- **Cutoffs:** work and slot limits that land on the preflight, the first comparison, mid-merge,
  the last copy, the admission entry and the finalization entry are all `searchIncomplete` with
  no output.
- **Cancellation:** cancellation requested at the ordering, admission and finalization checkpoints
  wins with `CancellationError`.
  - A mid-sort cancellation is observed by the same `charge` check that the mid-sort cutoff tests
    exercise. There is no deterministic in-sort cancellation seam, and none was added.

**Mutation check.** The new suite was run against the baseline insertion sort, in a scratch copy:

- the order, oracle, boundary, cutoff and cancellation assertions pass, because the output is
  identical;
- only the exact ordering-accounting assertions fail (54 issues across 27 cases), as intended.

**Results.**

- **Targeted regression:** `TEST SUCCEEDED`. Swift Testing reported 233 tests in 16 suites: 232
  passed and `measure()` was skipped. The suites were:
  - the new suite, `InternalRouteSolverTests`, `PreparedRouteWorkloadTests` and
    `PreparedRouteHarnessFaultTests`;
  - the measurement suite (skipped);
  - the §31 gate's composition, preparation, scope, success, coordinator and AppEnvironment
    suites.
- **Release:** app plus `TSUGINOLiveActivity.appex`, `BUILD SUCCEEDED`.
- **Driver tests:** `WinnerOrdering/test_run.py`, 4 synthetic tests OK. They cover plan order and
  exact envelope use, the class-drift halt, the call-ceiling halt and path redaction.

### 33.4 Matched experiment

**Method:** [`WinnerOrdering/README.md`](../Tools/PreparedRouteMeasurement/WinnerOrdering/README.md),
frozen before any matched call.

**Build provenance.**

- **Baseline:** `git archive 3368eb1` plus identical harness bytes. Its solver is `f8670cac…`,
  which equals the base commit and the §31 run-time solver.
- **Optimized:** `git archive HEAD` plus the working changes; solver `1aac67ba…`.
- Both trees were exported to `/private/tmp`. The working checkout was not built from.

**Envelope use.**

- **Run:** `20261017T194225Z`: 660 of 660 calls in 293.7 s of the 2 h budget.
- **Processes:** 10 test hosts and 4 builds, all exit 0.
- **No harness events:** no watchdog, H, U, S or memory-guard events.
- **Harness validation, separate:** 4 calls on cases outside the matched set, before the run.
- **Reviewer:** no reviewer measurement calls fit within the envelope.

**Correctness.**

- All 10 cases keep their §31 class, winner count and route digest in both trees.
- V-D solver work equals the frozen predictions in all 20 observations, for example:
  - W1-0256: 88,209,662 → 87,440,915;
  - W5-4: +2. §32.6 attributed this to two storage preflights. The implementation charges one
    buffer preflight plus one per-winner output copy, which gives the same +2.

**Observation points.**

- **W2a-10:** still cuts off in admission. The recorded last admission entry moves from
  99,915,309 to 99,799,666, and that value equals the model's entry for the 82nd winner. The
  winner index is model-derived; the records hold only the credit.
- **Predicted but not in this subset:** the charge model predicts no class or cutoff-stage change
  across the 37 §31 cases. It also predicts moved observation points for W2b-6, and a cutoff moving
  from the 25th to the 26th admitted winner for W2a-11. These were not measured here.

**Runtime.**

- **V-D ordering segment, one call each:** W1-0256 2,367.9 → 94.8 ms; W1-0128 596.8 → 42.9 ms.
- **V-O stage-pass solve median ratios** (optimized / baseline, rounds 1/2):
  - W1-0128: **0.140 / 0.142**;
  - W1-0256: **0.095 / 0.107**.
- **Both §32.6 targets (≤ 0.5× in both rounds) are met.**
- **Whole-call timing pass:** W1-0256 73.7 → 10.7 ms and 53.3 → 6.8 ms.
- **Controls:** the cases without ordering work gave ratios 0.91–1.24 (W5-4 above 1 in both
  rounds). They are not interpreted.
- **Variability:** absolute times differ about 2× between rounds, and host load rose from 5 to
  about 212 during the run (recorded per process). Only within-round paired ratios are interpreted.

### 33.5 Limits and next gates

- **Scope of the evidence:**
  - Simulator only; V-O is not Release; no physical iPhone.
  - Invented shapes; one host and one session.
  - The runtime gain is consistent with the reduced operation count, but it is not attributed by
    profiling.
- **Relation-scan cutoffs are unchanged:** W2a ≥ 10, W2b ≥ 6, W3 ≥ 50% and W5-5. §32.5 candidate 3
  remains the evidence-supported, owner-gated follow-up.
- **Open gates:** real-workload (G1/G3), Release, device and deployment gates remain open.
- **Production adoption:** none. P3-T1 stays scope-incomplete; Phase 3 stays **In Progress**;
  live/default routing stays unconfigured.

**Review.** The final verdict and the approved SHA-256 values are recorded in the author's hand-off
report. A file cannot contain its own digest.

## 34. Per-ride feasible-relation lists: design and cost audit — 2026-10-18

### 34.1 Scope, authority and evidence

The owner authorized a read-only design and cost audit of §32.5 candidate 3. It started from
`9accdeae9e3e6070647a546746aa3ee2cff0132c`, which publishes §33. HEAD, upstream and the live branch
matched, main was `e8a463d51f14b3cb1027960c63244b694579a71b`, divergence was 0/0 and the worktree
was clean.

- **Evidence:** committed source and sanitized results only.
- **Not used:** private, archived or temporary evidence.
- **Nothing executed:** no source, test or harness change; no build, test, workload or profiler run.
- **Authority unchanged:** §24.3–§24.8, DEC-086 and Rule 29 still govern. There is no new product
  decision.

**Analysis tooling.** The charge model delivered with this change is
`Tools/PreparedRouteMeasurement/ChargeModel/charge_model.py`.

- It is an arithmetic replica of the `InternalRouteSolver` meter over the §30.4 generators. It is
  not TSUGINO execution, profiling or measurement.
- `validate` reproduces exactly:
  - all 37 §31 discovery observations with the pre-9accdea insertion ordering;
  - all 10 §33 optimized-tree observations with the published merge ordering.
- `index` adds this section's design. Its figures are **derived predictions, not measurements**.

### 34.2 What the current exploration does (source facts)

- **Candidate loop.** For path end `x`, the DFS tries every ride `y` in P order. Each `y` is
  charged 4,096, plus the trip-repeat check (1,024 per path ride). Then `relation(_:)` scans
  `input.connections` linearly at 4,096 per inspected relation, and accepts only if the found
  relation is `feasible`.
- **Outgoing flags.** `validateAndIndex` sets `outgoing[x]` by scanning for the first feasible
  relation whose from-endpoint equals `(x.address, x.alightingIndex)`. The scan stops at the first
  match and inspects all R if there is none.
- **Keys are unique.** `RequestScopedSearchInputClosure` rejects duplicate
  `(from, alightingIndex, to, boardingIndex)` targets (`connectionTargetConflict`), and P maps
  targets 1:1 to relations. So in any valid P a transition key matches **at most one** relation,
  and `relation(_:)`'s first match is the unique match.
- **Endpoint sharing.** A relation does **not** identify one ride:
  - every ride with out-endpoint `(address, alightingIndex)` equal to the relation's from-endpoint
    is a source, whatever its boarding index;
  - every ride with in-endpoint `(address, boardingIndex)` equal to its to-endpoint is a target.
  - Occurrence addresses are unique (`declarationConflict`), and one occurrence declares at most
    48 intervals (`SearchInputClosureLimits.intervalsPerOccurrence`). So at most 48 rides share an
    endpoint.
- **Admission is independent.** `makeClaim` and `admit` re-derive every transition edge by their
  own linear `relation(_:)` scans over the original P.
- **No useful depth bound.** `maximumRailRides` has no upper bound beyond `> 0`, so the depth bound
  can reach P.

### 34.3 Representations compared

| # | Representation | Construction | Storage | Per-candidate test | Verdict |
|---|---|---|---|---|---|
| 1 | Current linear key scan | — (`outgoing` scan stops at first feasible match) | — | Up to R key comparisons × 4,096 | Baseline |
| 2 | Hash map keyed by `ConnectionRelationKey` | R string hashes | R entries plus table | Expected O(1); collisions and String hashing are unbounded and opaque | **Rejected**: breaks the solver's "no hidden hash-table collision cost" rule |
| 3 | Per-ride out-relation list only | P × F endpoint comparisons | Σ\|O\| | \|O(x)\| key comparisons × 4,096 | Viable but weak: still key comparisons |
| 4 | Materialized ride-successor pairs | P × F | Σ_r \|src(r)\| × \|tgt(r)\|, up to 48² per relation (≈ 4.7M worst case, over the 1M slot ceiling) | O(1) | **Rejected**: pair blow-up can turn completing inputs into cutoffs |
| 5 | Per-depth successor marker arrays | P × F, plus a fill per frame | depth × P Ints; depth is bounded only by P (≤ 4,096), so storage reaches 4,096² Ints | O(1) | **Rejected**: storage is not bounded by policy |
| 6 | **Per-ride ascending out- and in-relation lists; test by sorted intersection** | One pass: R state checks plus P × F pair comparisons | 2P list headers + E entries, E ≤ 2 · 48 · F ≤ 196,608 | 1 + at most \|O(x)\| + \|In(y)\| integer merge steps | **Selected** |

### 34.4 Selected design

**Definitions.** Let F be the feasible relations of P. For each ride z:

- `O(z)` = indices r of feasible relations with `from(r) == z.address` and
  `alightingIndex(r) == z.alightingIndex`, ascending.
- `In(z)` = indices r of feasible relations with `to(r) == z.address` and
  `boardingIndex(r) == z.boardingIndex`, ascending.

Entries are **relation indices**, not successor rides. Rides sharing an endpoint each list the same
relations, so every matching retained ride is represented. Infeasible and qualified-absent
relations are never listed, because exploration can never accept them.

**Construction**, inside `validateAndIndex`. The early-exit `outgoing` scan leaves the ride loop,
and the pass runs **after** the ride-validation loop and the evidence-record check loop, as the
charge model does. So every validation now runs before the pass. For malformed but large P, a
`dataUnavailable` can now precede a construction cutoff; that is a benign precedence change.
Steps:

1. Preflight 2P empty list headers: `slots 2P`, `bytes 48P`, work 1.
2. For each relation `r` in P order: charge `1` for the state check, and skip it unless feasible.
3. For each ride `z` in P order, charge **4,096** for one key-equivalent comparison of both
   endpoints, using the same `TimetableOccurrenceAddress ==` and `Int` equality as
   `ConnectionRelationKey ==`.
4. On a from-match append `r` to `O(z)`, and on a to-match append `r` to `In(z)`. Each append is
   charged before it happens: `slots 1`, `bytes 8`, work 1.
5. The relation-major order makes every list ascending without sorting. Then
   `outgoing[z] = !O(z).isEmpty`, which is exactly the current definition.

**Exploration.** The candidate loop, its order, its 4,096 candidate charge, the trip-repeat check
and its position, the depth-bound check and frame pushes are all unchanged. Only
`relation(transition(x, y))` plus the feasibility check is replaced by `accepted(x, y)`:

- charge `1` for the lookup;
- walk `O(x)` and `In(y)` as an ascending merge, charging `1` per step;
- accept on the first common index.

`makeClaim`, `admit`, the evidence-record check loop, ordering, finalization and every safeguard
ceiling are unchanged.

**Cancellation and resources.**

- Every pair comparison, entry, lookup and merge step goes through `charge`, which checks
  cancellation.
  - Between two checks there is O(1) native work, with amortized list growth covered by the
    per-append charge.
  - The exceptions are the 2P header allocation after its preflight, and deriving `outgoing` from
    `O`. Each is bounded O(P) ≤ 8,192 native steps.
- Sizes are bounded below Int overflow: P ≤ 4,096, R ≤ 2,048, E ≤ 196,608. Products use
  `InternalSolverMeter.product`.

### 34.5 Exploration equivalence (proof)

**Claim.** For every valid P, the indexed solver performs exactly the same sequence of DFS state
transitions as the current solver: path pushes and pops, tie-collection updates, winner-cap checks
and winners. Only meter charges differ. The sequences agree up to the earlier of the two variants'
cutoffs, or completely under a meter that never cuts off.

**Proof.**

1. **Same acceptance test.** Fix path end x and candidate y that passed the unchanged trip-repeat
   check.
   - The current code accepts iff some relation has key `k = (x.address, x.alightingIndex,
     y.address, y.boardingIndex)` and the first such relation is feasible. By key uniqueness, that
     means: the unique relation with key k exists and is feasible.
   - The index accepts iff some r is in both `O(x)` and `In(y)`. That holds iff r is feasible,
     `from(r) = (x.address, x.alightingIndex)` and `to(r) = (y.address, y.boardingIndex)`, that is,
     iff r is feasible with key k. With unique keys, the two are equivalent.
   - Construction enumerates every (r, z) pair with the same equality, so the lists contain
     exactly these relations: none missing and none extra.
2. **Same outgoing flags.** `outgoing[z]` is unchanged, as defined above.
3. **Same DFS states, by induction.** Candidate order, the trip-repeat check, the bound check and
   frame pushes are unchanged, and acceptance is identical. So by induction over loop iterations
   the DFS state after every iteration is identical.
4. **Same results.** In particular the discovery order of incumbents and ties is identical, so the
   order-sensitive 256-winner cap behaves identically too.

**Preserved behaviour.** It follows that the solver still keeps:

- every feasible identity-distinct sequence and every equal optimum;
- exact directional connection semantics, with no inferred absence;
- no repeated recurring TripID across dates;
- permitted station revisits and zero-duration rides;
- the comparator, merge-sort ordering, objective, admission and terminal mapping;
- no new dominance, pruning or first-K behaviour.

**Operational effects (not semantic).**

- With lower exploration charges, some inputs that previously hit the work ceiling now complete
  within the same unchanged ceiling. Their results are the full, correct optimum set.
- Cutoff and cancellation observation points move.
- The up-front construction pass can move a cutoff earlier, as for W8-004M below.

### 34.6 Admission independence

- **The index is never consulted after exploration.** `makeClaim` derives each transition key
  from retained tokens and re-finds the edge by linear scan. `admit` independently re-derives it
  from the claimed keys and checks form, chronology, feasibility and canonical construction
  against the original immutable P. So the index cannot authenticate its own claims.
- **A phantom acceptance fails closed.** That would be an index entry with no feasible relation
  behind it, which only an index defect could produce.
  - If no relation has the key, `makeClaim` throws `dataUnavailable`.
  - If the relation is in `absentUnderCompleteAuthority` state, `positiveEvidence` is nil, so
    `makeClaim` also throws `dataUnavailable`.
  - If the relation is infeasible, its positive evidence is present, so `makeClaim` succeeds and
    `admit` rejects with `infeasibleConnection`.
    Precedence, `noUsableAlternatives` and the mixed→`searchIncomplete` mapping are unchanged.
  - No wrong success can escape.
  - **Residual:** such a defect would surface as `dataUnavailable` from `makeClaim`, which reads
    as an input fault. That branch is unreachable for a correct index; the tests in §34.8 guard it.
- **A missing entry would silently omit routes.** Admission cannot detect a missing winner, so
  omission safety rests on the §34.5 construction proof and on independent exhaustive-oracle and
  brute-force index-equivalence tests. This is stated as a residual risk; the index does not hide
  shared-input truth, because it is derived from P alone.
- **Smallest change.** Admission keeps its linear scans. Their residual cost is
  `2 × Σ (scan position) × 4,096` per winner transition. This is the dominant remaining cost:
  for example 41.4M of W2a-10's 68.3M derived credits.

### 34.7 Derived costs (charge model; predictions, not measurements)

**General formulas.**

| Cost | Formula |
|---|---|
| Construction | `1 + R + 4,096 · P · F + E` credits |
| Lookup | `1 + steps`, where steps ≤ \|O(x)\| + \|In(y)\| ≤ 2F; the current worst case is R × 4,096 per candidate |
| Retained storage | `2P + E` slots and `48P + 8E` bytes |

- **Unfavorable cases:**
  - Construction is paid up front for every ride, including rides that are never expanded, and it
    has no early exit.
  - Large P · F with a cheap DFS costs more than the current early-exit outgoing scan.
  - High fan-out raises merge steps per candidate, but each step is an integer comparison, not a
    key comparison.

**Matrix cases, with the merge ordering as baseline:**

| Case | §31 class | Credits to complete (merge → index) | Outcome under the unchanged 100M ceiling |
|---|---|---:|---|
| W1-0064 / W1-0256 | C | 9.27M / 87.44M, **+1** (index preflight) | unchanged |
| W1-0257 | I-solver | — | unchanged (winner cap, same discovery order) |
| W2a-08 / W2a-09 | C | 54.79M → 32.74M / 83.90M → 48.03M | C |
| W2a-10 | I-solver | 123.60M → 68.27M | **completes** (derived) |
| W2a-11 | I-solver | 176.28M → 94.46M | **completes** (derived; 5.5% headroom) |
| W2b-5 | C | 37.29M → 25.41M | C |
| W2b-6 | I-solver | 105.99M → 69.06M | **completes** (derived) |
| W2b-7 | I-solver | 285.27M → 180.85M | still I-solver; cutoff moves from exploration to admission |
| W3-000 / W3-025 | C | 6.08M → 0.77M / 44.47M → 10.60M | C |
| W3-050 | I-solver | 155.16M → 54.34M | **completes** (derived) |
| W3-100 | I-solver | 369.65M → 194.94M | still I-solver; cutoff moves to admission |
| W5-4 | C | 35.17M → 6.82M | C |
| W5-5 | I-solver | 141.88M → 17.20M | **completes** (derived) |
| W8-004M | I-solver | — | still I-solver; cutoff moves **earlier**, from exploration to indexing (construction 4,194,497 against a 4M limit) |
| W8-016M | I-solver | — | still I-solver; the last observation moves from tieCollection (15,863,703) to admission (15,743,878) |

**Other families** (not modeled in the tool; derived from structure):

- **W6:** after profile narrowing P = 6 and R = F = 9, the same relation shape as W2a-03.
- **W7e:** gains +2,049 credits (one preflight plus 2,048 state checks; no feasible relation and
  no ride).
- **W7o, W7p and W7r:** +1 each (no relations).
- **W7p-81:** about 95.6M, still completes.

**W2a closed forms**, for width w:

| Quantity | Formula | At w = 10 |
|---|---|---:|
| Pairs | P · F = 2w³ | 2,000 |
| Entries | 2w² | 200 |
| Lookups | w(2w − 1) | 190 |
| Merge steps | w³ | 1,000 |
| Exploration credits | — | 58.67M → 1.12M |

**Runtime proxy.** Modeled `charge` calls track recorded solve time (§32.4). The `index` command
prints them, both under the 100M ceiling and run to completion.

- **Cases that complete in both variants:**
  - W3-025: 0.298;
  - W5-4: 0.528;
  - W2a-08, W2a-09 and W2b-5: 0.74–0.80.
- **Formerly incomplete cases that now complete,** measured against the merge calls up to its
  cutoff:
  - W2a-10 0.788;
  - W2b-6 0.767;
  - W3-050 0.724;
  - W5-5 0.566;
  - W2a-11 0.952.

  Measured against the merge variant run to completion, the ratios are 0.715, 0.763, 0.456, 0.398
  and 0.695.
- **Cases that still cut off** do more work before the ceiling: W2b-7 1.529×, W3-100 2.324× and
  W8-016M 2.655× calls.
- Integer merge steps are natively cheaper than key comparisons, so the proxy is coarse. Runtime is
  unmeasured.
- **Storage:** W2a-10 adds 240 slots; the worst case is about 205k of the 1M ceiling.

### 34.8 Implementation-ready handoff

**Components.** `InternalRouteSolver.swift` only:

- the `validateAndIndex` outgoing scan becomes the §34.4 construction;
- the exploration `relation(transition(...))` call becomes `accepted(x, y)`;
- one DEBUG-only test accessor returns `(outgoing, O, In)`, following the `orderedForTesting`
  precedent;
- one DEBUG-only `InternalSolverTestHooks` field corrupts the built lists, following the
  `brokenSharedRelationIndex` precedent.

**Excluded:**

- `makeClaim` and `admit` (their linear scans are kept);
- ordering, the comparator, preparation and composition;
- every safeguard ceiling;
- policy and requiredness;
- the root candidate loop and finalization accounting;
- any other §32.5 candidate.

**Tests.**

- **Brute-force index equivalence.** For adversarial P, compare every (x, y) pair against the
  linear key scan. The inputs cover:
  - several rides sharing out- and in-endpoints, with different boarding and alighting indices;
  - recurring TripIDs on different dates;
  - feasible, infeasible and qualified-absent relations;
  - relations to endpoints with no usable ride;
  - walking and same-station forms, zero duration and station revisits.
- **Exhaustive-oracle parity** (P ≤ 16) over the existing adversarial masks and new shared-endpoint
  shapes; existing `PreparedRouteWorkloadTests` parity.
- **Trace parity.** The sequence of tieCollection hook entries must equal a test-side replay of
  the current scan-based DFS order, built with linear key scans.
- **Order-sensitive winner-cap preservation.** Over 256 two-ride equal ties precede a strictly
  earlier direct ride in P order. The result must stay `searchIncomplete`, exactly as the scan
  solver gives.
- **Corruption.**
  - A phantom entry pointing at an infeasible relation must give `infeasibleConnection` rejection
    semantics, with no success.
  - A phantom entry for a key that no relation has, and one pointing at an
    `absentUnderCompleteAuthority` relation, must each give `dataUnavailable`, with no success.
  - The existing claim-corruption tests stay unchanged.
- **Exact and one-below resources:** the final work, slots, keys and bytes complete, and one less
  in any dimension refuses.
- **Cutoffs** at the construction preflight, mid-pair pass, last entry and mid-lookup must be
  `searchIncomplete` with no output.
- **Cancellation** at the indexing and exploration checkpoints must give `CancellationError`.
  The checkpoint hooks fire only at stage entry, so cancellation mid-construction or mid-lookup is
  not reachable through them. It is observed by the same `charge` check that the mid-pass cutoff
  tests exercise.

**Matched validation (later task).** Same method as §33, with baseline `9accdea` and the
optimized working tree.

- **Cases (16):** W1-0064, W1-0256, W1-0257, W2a-08, W2a-09, W2a-10, W2a-11, W2b-5, W2b-6, W2b-7,
  W3-025, W3-050, W3-100, W5-4, W5-5, W8-004M.
- **Passes per tree:** V-D hooked discovery once; V-O timing and stage passes at 1 + 7 per case;
  two alternated rounds.
- **Discovery classes:** each tree is compared with its own frozen predicted classes, not the §31
  classes.

**Metrics.**

| Metric | Requirement |
|---|---|
| Correctness | Every completed case's class, winner set and order, and route digest equal the analytic values, and the §31 values where §31 completed |
| Credits | Solver work and last observation stage equal frozen model predictions (re-derived from the final charge formulas before running) |
| Completion coverage | The listed completions and moved cutoffs |
| Runtime | V-O stage `solve` for cases completing in both trees; whole-call time for the rest, reported without a ratio claim |
| Storage | Retained-slot delta from the V-D usage |

**Predeclared acceptance.**

1. All correctness and credit metrics are exact, and all tests pass.
2. In both rounds, the optimized V-O stage-solve median is ≤ 0.5× the baseline for W3-025 and
   ≤ 0.75× for W5-4.
3. Formerly incomplete cases are reported honestly, whatever their outcome. A deviation from the
   predicted completion is a model error that fails criterion 1; it is never repaired by changing
   limits.

**Envelope.**

- **Calls:** at most 1,056 search calls in total:
  - V-D discovery: 16 × 2 = 32;
  - V-O timing: 16 × 8 × 2 × 2 = 512;
  - V-O stage: 512.
- **Time:** 2 h wall clock after the builds; 20-minute per-process cap.
- **Watchdog:** 60 s for V-O and 180 s for V-D.
- **Execution:** strictly serial; explicit Simulator only; no device; no reviewer measurement calls
  beyond the envelope.

### 34.9 Remaining uncertainty

- **Not measured:** runtime, real-workload relation density and the native cost of list
  construction.
- **Model scope:** predictions cover W1, W2a, W2b, W3, W5 and W8 only. W6 and W7 relations are not
  modeled.
- **Admission becomes the bottleneck:** its linear scans dominate the remaining cutoffs (W2b-7,
  W3-100). Reusing indexed edges in `makeClaim` while `admit` stays independent would be a separate,
  later candidate.
- **No production adoption.** P3-T1 stays scope-incomplete; Phase 3 stays **In Progress**;
  live/default routing stays unconfigured.

## 35. Exploration relation index: implementation and matched validation — 2026-10-19

### 35.1 Scope and checkpoint

The owner authorized implementing §34 and running its matched validation. It started from
`8e5aae10ddd1b39559a7273a72bf8fbdba7bd216`, which publishes §34. HEAD, upstream and the live branch
matched, main was `e8a463d51f14b3cb1027960c63244b694579a71b`, divergence was 0/0 and the worktree
was clean.

**Changed:**

| File | Change |
|---|---|
| `TSUGINO/Data/Routing/InternalRouteSolver.swift` | The index construction and exploration lookup, plus one DEBUG accessor and one DEBUG hook field |
| `TSUGINOTests/InternalSolverRelationIndexTests.swift` | New tests |
| `Tools/PreparedRouteMeasurement/RelationIndex/` | New experiment folder |
| These documents | This record |

**Unchanged:**

- `makeClaim` and `admit`, including their linear scans over the original P;
- the comparator, merge sort, identity, dedup and the objective;
- preparation and composition;
- every safeguard ceiling and the root candidate loop;
- the measurement harness, the project and the schemes;
- the §31 and §33 artifacts.

### 35.2 Implementation

**Construction.** `SolverKernel.buildRelationLists()` runs at the end of `validateAndIndex`, after
the ride-validation and evidence-record loops.

| Step | Charge |
|---|---|
| Preflight | `slots 2P`, `bytes 48P`, work 1 |
| Per relation | State check 1; non-feasible relations are skipped |
| Per (relation, ride) pair | 4,096 |
| Per from-match or to-match | `slots 1`, `bytes 8`, work 1, charged before appending r to `O(z)` / `In(z)` |

- Relation order makes the lists ascending without sorting.
- Entries are original relation indices. Every ride sharing an endpoint is listed.
- `outgoing` is derived as `!O(z).isEmpty`.
- The DEBUG `corruptRelationIndex` hook runs before `outgoing` is derived.

**Exploration.** `accepted(x, y)` charges 1 per lookup and 1 per merge step, and returns on the
first common relation index. It replaces only the exploration `relation(transition(...))` call and
its feasibility check. Candidate order, the trip-repeat check, the bound and frame pushes are
unchanged.

**DEBUG-only additions.**

- `InternalRouteSolver.relationIndexForTesting(_:)`, following the `orderedForTesting` precedent.
- `InternalSolverTestHooks.corruptRelationIndex`.
- Neither appears in the Release binary: no matching strings in the Release product.

**Cancellation and overflow.** Every pair, entry, lookup and merge step goes through `charge`,
which checks cancellation. Products use `InternalSolverMeter.product`.

### 35.3 Tests and builds

All runs used the explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`. No device
was used.

**New `InternalSolverRelationIndexTests`: 13 functions, 22 cases.**

- **Every-ride-pair equivalence.**
  - Built `O`, `In` and `outgoing` equal independent brute-force definitions.
  - The intersection decision equals the original first-match-feasible scan for every (x, y).
  - The adversarial shapes cover:
    - several intervals per occurrence sharing endpoints;
    - walking and same-station forms;
    - feasible, infeasible and qualified-absent relations;
    - a relation to an endpoint with no ride;
    - a recurring TripID on two dates;
    - zero and non-zero step times.
  - Workload inputs: W2a-04, W2b-4, W3-025, W3a-010, W5-3, W4b and W6p-0384 (composed path), plus a
    recurring-trip shape.
- **Missing-entry protection.** A dropped entry is reported by the every-pair check, which admission
  cannot do.
- **Exhaustive-oracle parity** on the adversarial shapes and the 32 adversarial masks.
- **Trace parity.** The number of tieCollection entries equals a test-side replay of the scan-based
  DFS for every input. A hook entry carries only its stage and usage, and usage differs by design,
  so the entry count is the observable form of §34.8's "sequence".
- **Winner-cap discovery order.** 17 × 16 ties ahead of an earlier direct ride stay
  `searchIncomplete`. With the direct ride first, the same search completes.
- **Phantom corruption, against independent admission:**
  - a phantom pointing at an infeasible relation gives `noUsableAlternatives` with
    `infeasibleConnection`;
  - a phantom for a key no relation has, and one pointing at a qualified-absent relation, each give
    `dataUnavailable`;
  - none of them returns a success.
- **Exact construction accounting.** The indexing-stage work and slot deltas equal the approved
  formula on every input:
  - payload + 1 + per-ride snapshot and order key + 4,096·R;
  - plus 1 + R + 4,096·P·F + E;
  - plus the next stage entry.
- **Resource boundaries:** exact final usage completes, and one less in any dimension refuses.
- **Cutoffs:**
  - work limits at the construction preflight, first state check, first pair, first entry, last
    entry and exploration entry;
  - a slot limit at the second entry;
  - **every** work limit from the exploration entry to the first tie-collection entry, which covers
    lookups and merge steps.
  - All of them are `searchIncomplete` with no output.
- **Cancellation** at the indexing and exploration checkpoints gives `CancellationError`. Stage
  hooks fire only at entry, so mid-construction and mid-lookup cancellation are observed by the
  same `charge` check that the dense cutoff tests exercise.

**Mutation check.** A scratch copy dropped the `In` entries of the last ride. 4 functions failed:
workload every-pair equivalence, trace parity, exact construction accounting and the cutoff test.
The adversarial shapes and the oracle checks did not catch this particular mutant, because their
last ride has no incoming relation.

**Results.**

- **Targeted regression:** `TEST SUCCEEDED`. Swift Testing reported 246 tests in 17 suites: 245
  passed and `measure()` was skipped. The suites were the new suite, the §33 ordering suite,
  `InternalRouteSolverTests`, `PreparedRouteWorkloadTests`, the harness fault tests and the §31
  gate suites.
- **Release:** app plus `TSUGINOLiveActivity.appex`, `BUILD SUCCEEDED`.
- **Driver tests:** `RelationIndex/test_run.py`, 5 synthetic tests OK.

### 35.4 Matched experiment

**Method:** [`RelationIndex/README.md`](../Tools/PreparedRouteMeasurement/RelationIndex/README.md),
frozen with `predictions.json` before any matched call.

**Run.**

- **Run:** `20261018T222536Z`: 1,056 of 1,056 calls in 318.1 s.
- **Processes:** 10 test hosts and 4 builds, all exit 0, with no halts.
- **Builds:** baseline `9accdea` (solver `1aac67ba…`) and optimized (solver `748966e9…`), with
  identical harness bytes. Both were exported to `/private/tmp`.
- **Harness validation, separate:** 4 calls on cases outside the matched set.
- **Reviewer:** no reviewer measurement calls.

**Exact reconciliation.** All 32 V-D solver-work values, classes and last-observed stages equal the
frozen charge-model predictions. **There were no prediction deviations.**

**Unchanged-result parity.** The 7 jointly completed cases have identical winners and digests,
equal to §31.

**Expanded completion coverage.**

- W2a-10 (100 winners), W2a-11 (121), W2b-6 (64), W3-050 (55) and W5-5 (1) now complete within the
  unchanged 100M ceiling.
- They passed the analytic identity check; W2b-6 and W5-5 also passed the exhaustive oracle.

**Observation points.**

- W2b-7 and W3-100 now cut off in admission.
- W8-004M now cuts off earlier. The last observed point is the indexing entry; that the cutoff
  falls in index construction is inferred.
- The direct-route controls rise by +1.

**Runtime.**

- **V-O stage-solve median ratios** (rounds 1/2):
  - W3-025: **0.314 / 0.441**, against ≤ 0.5;
  - W5-4: **0.359 / 0.551**, against ≤ 0.75.
- **Both §34.8 targets are met.**
- Cases that still cut off take longer to reach the ceiling, because they progress further.
- **Controls:** the direct-route controls (no relation work) also ran faster in the optimized tree
  in both rounds (0.69–0.94). That is unexplained, so a systematic bias of up to about 30% cannot
  be excluded. W3-025's margin is robust to it; W5-4's round-2 margin is narrower.

**Storage.** Retained slots rise by `2P + E` for jointly completed cases. The case that progressed
furthest, W2b-7, reached 15,464 slots, far below the 1M ceiling.

**Variability.** Absolute times differ up to about 2× between rounds, and load rose from about 6 to
about 160.

### 35.5 Limits and next gates

- **Scope of the evidence:**
  - Simulator only; V-O is not Release; invented shapes; one session.
  - The runtime gain is not attributed by profiling.
- **Admission is now the dominant cost** of the remaining cutoffs (W2b-7, W3-100). Its linear scans
  are unchanged; reusing indexed edges in `makeClaim` while `admit` stays independent would be a
  separate, owner-gated candidate.
- **Construction is paid up front** and can move low-budget cutoffs earlier.
- **Open gates:** real-workload (G1/G3), Release, device and deployment gates remain open.
- **Production adoption:** none. P3-T1 stays scope-incomplete; Phase 3 stays **In Progress**;
  live/default routing stays unconfigured.

**Review.** The final verdict and the approved SHA-256 values are recorded in the author's hand-off
report. A file cannot contain its own digest.
