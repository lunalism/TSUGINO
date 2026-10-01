# Phase 3 — Internal-routing input/consumer contract outline

**Status:** Historical proposal — selected consumer amendments accepted separately in DEC-079; no engine adoption\
**Date:** 2026-10-01\
**Authority:** DEC-077 accepts evaluation priority only. Accepted DEC-079 now partially supersedes DEC-076 for the internal consumer; the historical outline below is not independently adopted.

## Scope and reading boundary

Documentation-only outline using the [feasibility assessment](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md)
and [accepted decisions](DECISIONS.md), notably DEC-009/020/021/047/048/058/060–064/074–077.
No new source research, data, timetable interpretation, algorithm, ranking or code.
The accepted target remains 15 lines/services and usable canonical plans for
supported Tokyo routes. A direct example is not a reduced launch commitment.
Commercial research remains dated history; evaluation/contact remains paused.

**A** below means an already accepted constraint. **P** means a proposed internal
consumer requirement, not an accepted input type or policy. Names of evidence
bundles are explanatory labels, not Swift declarations or public proof tokens.
All examples stipulate invented upstream evidence; they do not authenticate real
inputs or claim that S9/T1 already supplies these contracts.

## 1. Required inputs and their owners

| Input boundary | Minimum evidence the consumer would need | Accepted constraint / proposed detail / prerequisite |
|---|---|---|
| Coherent canonical view | Active exact StationID/LineID/TripID resolution, supported scope, compatible source/mapping/Trip/schedule/connection revisions and validity bounds retained for one call | A: DEC-076 A2, DEC-068/073 identity transitions. P: a compatibility manifest binding these inputs; no Domain revision field chosen. Foundation is provisional, not production adoption |
| Passenger-stop occurrences | Existing immutable Trip snapshot, original ordered indices, line segments and independent origin/destination coverage flags; exact source occurrence correspondence | A: DEC-060/061/076 D. **P2-S9 acceptance before real consumption**. Topology, raw stop_times row presence and matching names/patterns cannot supply this |
| Calendar/date interpretation | Identified dated schedule occurrence bound to the recurring Trip, accepted activation result, effective range and relevant exceptions, source zone and interpretation provenance | A: P3-T1 owns design/import (DEC-074), not yet semantics. P: routing consumes a resolved activation result, never interprets raw calendars itself. Exception precedence, dated identity and ambiguous local time remain T1 decisions |
| Absolute scheduled instants | Qualified finite instants for exact ridden occurrences, with schedule revision and missing/estimated status distinguished | A: DEC-076 E temporal comparisons; P: timetable-derived input boundary needs accepted T1. No naive 24-hour wrapping, date inference, interpolation or system-zone conversion; missing-time policy remains unaccepted |
| Board/alight eligibility | Explicit eligible/ineligible/unknown interpretation for each requested occurrence and applicable dated service; passenger-stop membership alone is insufficient for asymmetric restrictions | P: exact representation/ownership must be settled between S9 feed interpretation and T1 dated restrictions. S9 cannot invent times, nor may routing reinterpret raw pickup/drop-off flags. Unknown cannot be treated as allowed |
| Continuous ride / through correspondence | Reviewed source semantics for one boarding experience, exact source-run and occurrence joins, represented movement and coverage, compatible dated schedule | A: DEC-009/076 D disallow inference from labels, line changes or equal times. P: replace external itinerary assertion with an auditable input-backed derivation. A matched ride still needs one existing spanning Trip; no consumer stitching |
| Transfers | Actual train-change relation; same-station line-pair interchange or exact directional pedestrian pair; scope/validity; evidence sufficient to establish a connection-time constraint | A: DEC-076 D spatial connection proof. P: routing-time feasibility input and responsibility beyond simple chronology require separate approval. Physical path/gate/accessibility presentation remains Phase 10, not pulled into this outline |
| Provenance and permitted use | Publisher/distributor/format/license, source and transform revisions, review authority, freshness/coverage, authorized storage/use | A: Rule 40, DEC-065/068/074/075. Internal proof has no exemption from Q3/Q4, production registry, delivery, publication/bundling or termination/deletion gates. No real inputs authorized here |

No boolean such as “reviewed=true” is sufficient real evidence. Data must be able
to trace each assertion to identified inputs and accepted interpretation rules.
Source provenance stays out of canonical route values unless separately designed.
S9 and T1 **designs** may proceed independently with invented cases. Real T1 import
requires S9, and an internal search consuming imported times requires accepted T1
semantics and validated output. Connections/continuity have their own evidence gaps;
finishing S9/T1 does not automatically close them.

## 2. Consumer duties and unavailable states — Proposed internal application

| Situation | Required behavior / proposal; not a new implemented error contract |
|---|---|
| Request admission | Reuse finite absolute bound and distinct exact endpoints. Check current existence/retirement/conflict/support before expensive search; existing invalidEndpoint reasons apply. No successor following or name substitution |
| Unusable shared view | Reuse dataUnavailable for unavailable/incompatible required inputs; configurationUnavailable for missing permission/configuration. Retain one view or fail; never assemble mixed revisions |
| Intent or horizon cannot be supported | Proposed reuse of unsupportedRequest; define a declared finite search horizon separately. The request has no new window field here; a hidden cutoff cannot become noResults |
| Ridden interior unsupported | Reject that complete alternative as unsupportedPortion; do not crop it. An unsupported continuation outside a valid ridden partial snapshot does not itself reject the ride |
| Eligible occurrence / continuous ride missing | Do not guess an occurrence or board/alight permission. Reject/hold the affected proposal. Proposed reason for missing eligibility is unresolved (new reason versus invalidStructure); do not conflate it with unknownMapping. Missing continuity uses insufficientContinuity; a positive contradictory Trip claim uses inconsistentTrainEvidence |
| Repeated visits or partial coverage | Preserve original indices. Ambiguous correspondence remains unresolved only with independent complete-ride evidence; otherwise unavailable. One feasible graph interval is not correspondence evidence. Coverage flags constrain unseen extensions independently |
| Transfer unknown or impossible | Missing exact directional/line-pair evidence uses unverifiedTransfer. Proposed connection-time infeasibility needs an explicit reason/policy, not invalidScheduledContext when chronology is valid. No minimum time inferred from distance, station equality or an itinerary gap |
| Scheduled chronology | Reuse checks on every qualified ridden endpoint before omission: finite, >= departNotBefore, nondecreasing in itinerary order across missing endpoints/contexts. Equality is permitted ordering only. Unused Trip endpoints are excluded. Contradictions reject invalidScheduledContext and cannot be hidden by nil |
| Missing scheduled evidence | Proposed first internal consumer admits only complete ridden endpoint pairs and resolved service activation; otherwise hold the proposal. This restriction is an incremental proof boundary, not a new universal missing-time policy or launch reduction. No internal substitute for a provider intent assertion is accepted yet |
| Cancellation / overlap | Reuse non-main-actor Sendable async-throws, independent request state, cancellation before work/through owned work/before return and no partial batch after observed cancellation. Owned child work must cancel. Application supersession stays outside pure values |
| Exhausted budget / incomplete network / no route | Never report noResults from missing connections, unexamined service dates, stale input or a cutoff. A completeness/termination policy is still needed. If a limit prevents that proof, fail explicitly; exact existing-versus-new failure code is a future decision |

A complete-input, active-service candidate can still be only a scheduled proposal:
no observed operation, user boarding, realtime position or Journey readiness follows.
Known inactive services are not eligible paths; unknown activation is missing input,
not proof that no train runs. Do not hide source defects as ordinary search pruning.

## 3. Precise amendment options for DEC-076 — all Proposed

These additions would apply **only to a separately adopted internal implementation**.
External-provider semantics stay as accepted. This original option table remains
proposal history. [Proposed DEC-079's detailed amendment](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md)
now refines IR-E1, accounting and outcomes; it permits only matched internal rides
and defers this table's broader IR-C unresolved option. No accepted text is amended.

| Ref / affected section | Proposed amendment text or explicit alternatives |
|---|---|
| IR-A / §A2, A6 | “An internal implementation validates one coherent canonical, schedule and connection input view. Source interpretation and correspondence remain Data responsibilities; computation does not certify its own inputs. Request/result lifecycle requirements apply without requiring fictional network I/O.” Algorithm component ownership still requires design |
| IR-B / §B | “For an internal implementation, the source alternatives are a finite request-local sequence of complete generated itinerary proposals handed to admission. Each has a stable zero-based position before admission; each contributes exactly one candidate or omission. Partial search states and legitimately pruned paths are not alternatives.” Preserve N=candidates+omissions, increasing unique omissions in 0..<N, complement reconstruction and contiguous all-rejected indices. No persistent IDs |
| IR-B continued / §B | “noResults requires completed search within an explicitly supported intent/horizon and sufficient input coverage; all generated proposals rejected means noUsableAlternatives; shared-view failure or interrupted enumeration is neither.” Deterministic generation order, search completeness, horizon, pruning/dominance, duplicate handling and limits require a later decision; adapter admission must not re-rank or silently discard indexed proposals. Suggested fail-closed behavior before those decisions: no internal result production |
| IR-C / §C3 | Replace the blanket graph prohibition only for an accepted internal provider: “A graph path over station topology is insufficient. An internal unresolved ride may carry a computed line sequence only when every movement belongs to one affirmatively evidenced continuous passenger ride with exact canonical anchors. Adjacent duplicate lines collapse; non-adjacent repeats remain. Graph reachability alone supplies neither stops nor continuity.” Matched lines still derive from original Trip interval; boundary-only contact excluded |
| IR-D / §D | “An internal candidate needs reviewed input semantics and an auditable derivation establishing ride continuity or actual train change. Exact source run/occurrence-to-existing-Trip correspondence may replace a commercial run-reference join; identity is never inferred from route similarity. Transfer connection evidence and connection feasibility are independent obligations.” Single spanning snapshots remain necessary for matched through rides; no new Trip minted at the boundary |
| IR-E1 / §C, E — option 1 | Retain ProviderScheduledContext unchanged and introduce a distinct proposed timetable-search context branch alongside it in a future route-context sum type. The new branch would carry finite paired absolute endpoints; exact minimal provenance/occurrence representation needs T1 review. Data retains source evidence. Candidate validators must compare endpoints across both branches, including nil gaps. This changes RouteRailProposal's context contract explicitly |
| IR-E2 / §C, E — option 2 | Retain the existing provider context field unchanged; add a separate typed internal-search result envelope associating timetable context with candidate/ride positions. Existing candidate context remains nil, so DEC-076's nil/provider-intent admission rule must also be explicitly amended for this path. Association, cross-context validation and a truthful consumer boundary become new obligations; the current RouteSearching return type cannot expose that envelope without review |
| IR-E / common guard | Neither option redefines ProviderScheduledContext, attaches times to recurring Trip, or licenses progression. T1 establishes active dated schedule/absolute instants; internal admission proves request intent from that accepted evidence, not a generic assertsDepartureIntent flag. Retain all pre-omission contradiction checks. No fallback to nil to bypass absent service activation or known contradictions |

**Recommendation for later review:** explore IR-E1 first because one route result
can preserve explicit context origin without positional sidecar drift. This is
not type approval. IR-E2 remains a concrete alternative with larger association
and consumer costs. Neither can be implemented under unchanged DEC-076.

Future change surface: DEC-076 history/amendment record; ARCHITECTURE §§4/10/21/40;
Phase 3 tasks/tests; RouteRailProposal/context, RouteCandidate chronology and
possibly RouteSearching result boundary; route/admission/async tests. DEC-004
remains Provisional, not automatically superseded by DEC-077. No accepted Trip,
Journey, canonical-ID, equality, selection or launch invariant is weakened.

## 4. Three worked examples — wholly synthetic specification, not executed tests

Every station, line, service, evidence reference and time below is invented.
All abbreviated times mean **2032-04-12THH:MM:00+09:00**, explicit absolute instants;
they are not raw timetable strings, a real operating date or a date-conversion rule.
View **V-syn-1** stipulates mutually compatible canonical/mapping/Trip/schedule/
connection inputs, active supported identities and permitted synthetic use. Each
service's dated activation and times are stipulated hypothetical T1 outputs, not
an accepted calendar policy. All indices are original zero-based passenger visits.
“TC” denotes a proposed timetable-derived context under IR-E1, **not an existing
ProviderScheduledContext**. Results describe potential canonical structure after
required amendments; current production output is not authorized.

### X1 — Scheduled direct ride

| Item | Invented request/evidence/result |
|---|---|
| Request | Station A → C; departNotBefore 08:00 |
| Existing snapshot | Trip T1, visits [A@0, B@1, C@2], line L1 movements 0–2; service-origin and service-destination coverage true |
| Minimal evidence | V-syn-1; active dated service S1 exactly corresponds to T1/visits; board allowed at A@0 and alight allowed at C@2; authoritative continuous ride; departure 08:02, arrival 08:12; every ridden line supported |
| Proposed canonical result | One RouteCandidate: rail matched(T1 unchanged, boardingIndex 0, alightingIndex 2), derived line sequence [L1], TC(08:02,08:12). No selection/Journey. If this is proposal index 0 and admitted, batch has one candidate and no omissions |
| Contradictory variant | Qualified departure is 07:59, arrival still 08:12. Reject this proposal as invalidScheduledContext; do not omit departure or claim intent is satisfied. If the only generated complete proposal, noUsableAlternatives with omission index 0, not noResults |

### X2 — Two rides with directional walking transfer

| Item | Invented request/evidence/result |
|---|---|
| Request | Station A → D; departNotBefore 09:00 |
| Existing snapshots | T2 visits [A@0, X@1] on L2; T3 visits [Y@0, D@1] on L3; both coverage flags true for each; T2 and T3 have distinct IDs |
| Minimal evidence | V-syn-1; active S2/S3 bound exactly to T2/T3; board/alight permissions at all four ridden endpoints; each ride continuous; documented change of train; reviewed directed connection X→Y (distinct IDs), valid for this line pair and time. Separately stipulated connection constraint: minimum 6 minutes **including all alight/walk/board allowances**, applicable here; this is invented evidence, not a default duration |
| Schedule | T2 departs 09:02, arrives X 09:10; T3 departs Y 09:18, arrives D 09:30. Eight minutes satisfies the stipulated six-minute constraint |
| Proposed canonical result | rail matched(T2,0,1), WalkingTransfer(X→Y), rail matched(T3,0,1); TC pairs (09:02,09:10) and (09:18,09:30). No invented reverse edge; no path geometry/duration added to WalkingTransfer |
| Missing-evidence variant | Only Y→X is evidenced, not X→Y. Reject as unverifiedTransfer despite the eight-minute gap |
| Chronology counterexample | With X→Y evidence restored, move the second departure to 09:13. All instants remain ordered and >= bound, but three minutes fails the six-minute constraint. Reject as infeasible connection under a future explicit reason policy; do not mislabel as temporal-order failure or accept solely on chronology |

Equality (e.g., arrival 09:10 and next departure 09:10) also passes DEC-076 ordering,
but proves no ability to walk/board. A missing connection-time rule is not zero.
For same-station changes, canonical station equality similarly does not replace
line-pair interchange evidence and a justified connection-time constraint.

### X3 — Through service crossing a line boundary

| Item | Invented request/evidence/result |
|---|---|
| Request | Station P → R; departNotBefore 10:00 |
| Existing snapshot | T4 visits [P@0, Q@1, R@2]; L4 movements 0–1 and L5 movements 1–2; both service coverage flags true |
| Minimal evidence | V-syn-1; active S4 exact correspondence to T4 and both visits; boarding P@0/alighting R@2 allowed; reviewed same-vehicle stay-aboard correspondence across Q and both line fragments; one existing spanning snapshot; departure 10:03, arrival 10:20; L4/L5 supported |
| Proposed canonical result | One rail matched(T4 unchanged,0,2), derived [L4,L5], TC(10:03,10:20). Zero transfers, no artificial split at Q. If boarding instead at Q@1, only [L5] contributes movement; L4 boundary contact is excluded |
| Missing-evidence variant | Remove affirmative continuity evidence; retain only two adjacent line fragments with equal boundary times and matching labels. Hold/reject as insufficientContinuity, not two invented rides with a transfer. If evidence positively contradicts the asserted T4 correspondence, reject inconsistentTrainEvidence rather than unresolved fallback |

The cases stipulate complete snapshots for clarity, not a complete-only Trip policy.
Partial snapshots remain usable within evidenced coverage under DEC-076; neither
unseen extensions nor repeated-stop occurrences may be invented. No case proves
coverage of the accepted 15-line launch set or ODPT data compatibility.

## 5. Reuse, open decisions and first next task

| Existing component | Reuse limit |
|---|---|
| RouteSearchRequest / RouteSearching | Shape, finite validation, Sendable async/cancellation/error boundary reusable; internal intent/horizon/admission still needs accepted design |
| TrainCandidate / RouteRailTravel / RouteCandidate | Original snapshot/index and movement clipping, line-sequence/local continuity invariants, rail-first/last, no consecutive walks or duplicate matched Trip IDs reusable. Constructors do not validate evidence, eligibility or operational connections |
| RouteSearchBatch / omission values | Structural accounting reusable after IR-B defines the generated sequence; does not prove enumeration complete |
| ProviderScheduledContext | Reuse **only** for its accepted provider assertion meaning. Arithmetic invariants can inform a distinct type, not authorize repurposing |
| RouteScheduleAdmission | Finite/request-bound/pre-omission chronology logic is reusable in principle. Its current contexts function returns ProviderScheduledContext and accepts an intent assertion, so it cannot be plugged into internal timetable output unchanged. Qualification and activation are upstream obligations |
| SyntheticRouteSearcher / SyntheticRouteAdmission | Debug-only counterexamples and harness patterns; stipulated evidence is not production authentication or an engine implementation |

Open decisions: generated itinerary ordering/completeness/horizon and failure on
limits; pruning/duplicate treatment; internal continuity proof and component
ownership; connection-time input and infeasibility/unknown-eligibility reasons;
IR-E1 versus IR-E2 and T1 occurrence/provenance binding. Algorithm/ranking and all
T1 calendar, time-zone, extended-hour and missing-time policies remain unaccepted.
An engine adoption decision and implementation scope would still be required.

**Current next bounded task:** focused review of the
[producer refinements](PHASE_3_TIMETABLE_PRODUCER_PROPOSAL.md) and
[precise Proposed DEC-079 amendment](PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md).
The earlier recommendation to draft P3-T1 is fulfilled as documentation only;
DEC-078 remains Proposed after independent readiness review. The detailed amendment
now proposes IR-E1 association, rejection reasons, scoped accounting and outcome
precedence. Neither proposal accepts the other or authorizes engine implementation.

Before any real canonical Trip consumer: P2-S9 acceptance. Before real imported-time
consumption: separately accepted T1 semantics and validated import, with authorized
inputs. Production registry, public mappings/Q3, translations/Q4, delivery,
publication/bundling and expansion gates remain deliverable-specific and unchanged.
