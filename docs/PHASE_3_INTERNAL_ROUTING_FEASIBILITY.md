# Phase 3 — ODPT-first internal route-search feasibility

**Date:** 2026-10-01\
**Status:** Assessment and proposed sequence only; DEC-077 now accepts evaluation priority only\
**Baseline:** `phase/03-route-search`, HEAD/fetched upstream `f792af2a1c11f8c09d544f46acb764deb9896d88`; main/fetched main `e8a463d51f14b3cb1027960c63244b694579a71b`.

**Acceptance update (2026-10-01):** DEC-077 is accepted only for evaluation priority
and the commercial pause. The original assessment/sequence below remains historical
planning; its first drafting task is now recorded in the [Proposed input/consumer
outline](PHASE_3_INTERNAL_ROUTING_CONTRACT_OUTLINE.md). No feasibility, engine or
contract amendment has been accepted.

## Scope and conclusion

Owner direction prioritizes ODPT-sourced data where feasible and assessment of
internal computation before commercial APIs. Commercial evaluation/contact is
paused. This operational priority is not acceptance of an engine, algorithm,
contract amendment, rights interpretation or narrower launch. The existing
[commercial comparison](PHASE_3_PROVIDER_EVIDENCE_GAPS.md) remains dated evidence.

Historical scope lock: documentation only in this matrix, then-Proposed DEC-077 in
[DECISIONS](DECISIONS.md), a ROADMAP link and the commercial comparison's pause
notice. Verification is references, scope and diffs, not tests/builds. Only
repository records were used; no public research was needed to identify these
blockers. Source dates below are historical retrieval/analysis dates, **not current
external verification**. No private artifacts were opened or data acquired.

**Verdict: plausible direction, ODPT-only launch feasibility unresolved.** Historical
GTFS evidence spans the launch line set, but not accepted passenger-stop Trips,
a timetable consumer contract, complete transfer connectivity or through-run
correspondence. A graph over station topology cannot fill those gaps. Internal
computation moves responsibility for truthful departure intent and feasible
connections into TSUGINO; it does not remove that responsibility.

## Accepted target — unchanged

DEC-047/058 cover **15 canonical lines/services, two operators**:

| Publisher/operator | Accepted lines/services | Accepted guidance tier, not a new capability observation |
|---|---|---|
| Tokyo Metropolitan Bureau of Transportation (Toei) | Asakusa, Mita, Shinjuku, Oedo; Tokyo Sakura Tram | Realtime Journey Tracking under recorded limits |
| Toei | Nippori-Toneri Liner | Scheduled Journey Guidance (DEC-046); audited TU/VP scope excludes it |
| Tokyo Metro | Ginza, Marunouchi including branch, Hibiya, Tozai, Chiyoda, Yurakucho, Hanzomon, Namboku, Fukutoshin | Scheduled Journey Guidance; historical catalog lacks train-level realtime |

Phase 3 still requires canonical usable plans for supported Tokyo routes: exact
endpoints, departure intent, alternatives, genuine transfers, through continuity,
scheduled context, JP/EN/KO canonical content and recoverable failures. Its test
list includes direct, one/multiple transfers, local/express, through service,
malformed data, unknown mapping and outage. The acceptance criteria prohibit DTO
leakage and false transfers. Phase 3 exit is **“TSUGINO can obtain a usable canonical
journey plan for supported Tokyo routes.”** It has not become “find a topology path”
or “support only Toei direct rides.” Active Journey tracking/progression, Live
Activity and final route-results polish remain outside this phase.

DEC-076 further requires finite absolute depart-not-before; coherent identified
Data view; supported exact anchors/lines; affirmative continuous-ride/change and
interchange evidence; original Trip snapshots/occurrences when matched; typed
failures and honest omission accounting. Candidates are not user selection or
active Journeys. Unsupported ridden interiors cannot be cropped away. Other
operators remain deferred/unsupported under DEC-058/059; an unsupported continuation
outside the ridden portion may coexist with a valid partial Trip.

## Existing evidence matrix

**Vh** = verified historical observation within the cited snapshot limits;
**D** = recorded catalog/license statement only for the indicated fact;
**U** = missing evidence/design; **R** = applicable rights/delivery gate.
Vh never means currently available or accepted for routing. “Absent” below is an
observed property of inspected archives, not a provider-wide absence claim.
All audit locators refer to [PROVIDER_FEASIBILITY_AUDIT](PROVIDER_FEASIBILITY_AUDIT.md).
ODPT is the **distributor/platform**, not one uniform publisher, format or license.

| Source / original publisher / format / license | Stations and lines | Passenger-stop Trips, calendars and times | Through service / transfer connectivity | Missing proof and blocked consumer |
|---|---|---|---|---|
| DS-01 Toei via ODPT; base GTFS Static; CC BY 4.0. Audit §§2.3, 6.1.1, 6.1.3; 2026-09-18 observation, 09-19 identical recovery | Vh: six routes cover the six named Toei services; 149 stop rows; IDs/references checked. Phase 2 later accepted provisional canonical topology/membership, not operational routing | Vh: 5,600 trips, 122,798 stop_times, calendar 4, calendar_dates 39. These are source rows, not 5,600 accepted canonical passenger-stop Trips. U: S9 stop classification, occurrences/coverage; T1 activation, dates/zones, missing times and revision binding | U: reviewed continuity beyond represented runs and line-pair transfers. Headsigns cannot establish a join | S9 then accepted T1 and authorized real acceptance before timetable search. Static coverage does not prove every required itinerary or current validity |
| DS-03 Tokyo Metro via ODPT; GTFS Static plus `odpt:Railway` JSON; Basic License. Audit §§2.4, 6.2.2–6.2.5; 2026-09-18 | Vh: nine GTFS routes, 185 stop rows; ten Railway records with Mb branch scope; nine line mappings derived from concordant official fields. No automatic global cross-ID join | Vh: 9,544 trips, 172,168 stop_times, calendar 2, calendar_dates 26; 4,151 non-timepoint rows with blank times. Recorded feed range 2026-03-14–12-31 and version 20260528 do not certify today's completeness | Vh: inspected GTFS lacks transfers/pathways/levels; Railway contains no connection relation. U: operational through joins and transfer feasibility | S9/T1, exact source-revision correspondence and missing-time semantics; R: public derivatives/bundling/deletion. No inference of nonexistent real-world transfers |
| DS-01 Toei via ODPT; GTFS-Pathways archive; CC BY 4.0. Audit §§3.5.4, 6.6; 2026-09-20 | Vh: twelve Oedo station structures only, with platform child IDs; not drop-in replacement for base identifiers | Vh: same trip/stop-time row counts but 10,120 rows reference 26 child stops. U: approved source/identity migration and stop correspondence | Vh: internal pathways, zero inter-station-structure edges; no cross-operator proof; transfers.txt absent. D: publication labelled contest-period-limited, end date unrecorded | Cannot supply general launch transfer graph. Source availability/migration needs review before use; internal path existence alone is not itinerary train-change evidence |
| Toei / Tokyo Metro via ODPT; train timetable JSON (Metro station timetable JSON also catalogued); respective CC BY / Basic License. Audit §4.1, §§6.1–6.2, 6.8; DS-01/03 | D: catalog entries | U: payload, completeness, calendar/time semantics, run/occurrence joins, compatibility with GTFS | U: any useful explicit predecessor/successor/through correspondence in actual input | Potential targeted evidence source, not an implemented fallback. New acquisition requires separate authorization; no claim based solely on a schema or dataset title |
| Toei DS-02 GTFS-RT; Metro DS-04 Alert / TrainInformation; same respective licenses. Audit §§6.1.1–6.1.4, 6.2.2; 2026-09-18 | Vh: bounded static/RT references and line-level status mappings | Vh: Toei trip IDs joined over seven snapshots of one evening; Metro retained Alert header-only and line-status snapshot. No complete timetable or ongoing accuracy proof | U: through continuity, incident diversity and current coverage | Phase 4 realtime work remains separate. Realtime observations cannot fill an unaccepted static calendar or substitute for passenger-stop evidence |
| TSUGINO provisional canonical foundation; upstream Toei/Metro provenance retained; DEC-048/068/073–075 | Accepted local evidence: 258 stations, 15 lines, two operators, reviewed JA/EN/KO names, aliases, mappings/topology and SQLite/version/history | No S9 Trips or T1 schedules supplied by Phase 2 exit | Station identity merges do not certify transfers; existing WalkingTransfer value proves no path | Reusable identity/localization foundation only. R: production registry adoption, delivery/composition and applicable derivative publication gates |

Audit §6.8 (B11, 2026-09-23) is particularly consequential: nonterminal rows with
both pickup/drop-off prohibited, blank times and non-timepoint flags occurred in
both archives (540 Toei rows / 4,151 Metro rows). The recorded pattern is consistent
with pass-through positions, but is not a general passenger-stop rule. Both feeds
lack train numbers in `trip_short_name`; headsigns extending outside the feed and
`block_id` (zero Toei / eight Metro trips populated) do not establish through-run
linkage. Service labels, fare supplements and seating policy are unproven. A
limited-stop path may eventually be supported through verified traversal without
inventing a local/express label (DEC-061).

## Rights, provenance and accuracy boundaries

Use audit §§3.5–3.6, 3.9–3.12 and DS-01–04/15 as **dated license evidence**:

- Toei CC BY permits commercial use/adaptation/redistribution with attribution,
  source/license links, notices and modification indication; trademark permission
  is separate. Basic-License freshness duties must not be imposed on Toei by
  implication. Currency/staleness remains a TSUGINO engineering safeguard.
- Metro Basic License expressly allows commercial mobile deliverables, internal
  normalization and combination under obligations. General commercial use is not
  an open question. Raw/restorable reusable redistribution is blocked without
  approval; public canonical derivatives (Q3), new translations (Q4), offline
  bundling and installed-cache termination/deletion remain applicable open gates.
  Recorded obtained-date/update-notice and dynamic validity/provenance obligations
  differ from Toei. No new legal conclusion or permission is made here.
- ODPT access/token rules are separate from source licenses. The recorded public
  Toei recovery does not authorize future requests. Challenge sources remain
  excluded from production/evaluation/fixtures under DEC-037; ODPT-first does not
  unlock private-railway/JR through continuations. S10/Track A still gates expansion.

An internal plan would need traceable source publisher/resource, license, content
hash/version, obtained time, coverage/effective range, mapping and schedule revisions,
validation authority and transformation history in Data. A feed version is not a
freshness guarantee. Query execution needs a coherent compatible view and a defined
update/invalidation boundary; a mapping refresh cannot rewrite an in-flight result
or follow a retired successor automatically. A later selection must revalidate its
own evidence. Stale/expired/incomplete schedules must not imply operational certainty,
observed train position, boarding or arrival. Current dataset freshness and incident
handling are **unknown here**, not newly tested. No Domain provenance fields are
added by this assessment.

## Reuse and required contract review

| Boundary | Reuse without semantic weakening | Future amendment/design required before adoption |
|---|---|---|
| DEC-004 (Provisional), Phase 3 provider work | Replaceability, canonical results and suitability gate | Explicitly revisit external-provider preference and client/DTO integration tasks for an internal provider. An engine is additional work, not already accepted by that provisional preference or by this assessment |
| DEC-076 §A | Request shape, finite absolute bound, Sendable async-throws, isolation, cancellation and coherent view | Define internal data/configuration/horizon failures and source-to-canonical validation ownership; no fabricated external I/O required. Application supersession remains separate |
| DEC-076 §B | Typed outcomes, privacy-safe diagnostics, deterministic accounting | “Decoded response”, “source order” and one-to-one alternatives assume an external enumerator. Define internal enumeration/termination, stable order, duplicate policy and completeness before mapping generated alternatives to these values. No-results must not mean search budget exhausted or missing network data |
| DEC-076 §C3 and §D | Exact canonical endpoints, movement-based lines, no topology-to-passenger-stop conversion, affirmative continuity/transfer evidence | §C3 explicitly says unresolved line sequences are **not generated by graph routing between endpoints**. Internal computed routes need an explicit accepted replacement/evidence rule. §D expects provider run/itinerary assertions: define reviewed input-run-to-canonical correspondence and computed feasibility evidence, not synthetic review flags or self-certification |
| DEC-076 §E, §C2 and ARCHITECTURE §10 | Finite paired times, inclusive bound and chronology before pair omission; candidate remains separate from Journey | ProviderScheduledContext **means provider-supplied scheduled assertion**. Imported timetable-derived instants cannot silently use that meaning. Settle provenance/type/projection and missing-context intent proof after T1 design; do not merely rename an internal engine “provider”. Candidate currently has no freshness state: decide Data/Application validity presentation without pretending one exists |
| DEC-060–064 | Existing recurring Trip snapshots, original indices, partial coverage, non-adjacent line repeats; distinct rail endpoints/no duplicate matched Trip IDs; explicit user selection | P3-T1 must keep dated schedules separate from recurring Trip identity. Do not stitch/mint Trips to satisfy an engine, weaken repeated-occurrence rules, or bind Journey during route search |

Affected future review surface: DEC-004, DEC-076 (new amendment with history),
ARCHITECTURE §§4/10/21/40 and Phase 3 Included/Tasks/tests/decision gate; potentially
P3-T1 data contracts. Existing `Domain/Routing`, `RouteScheduleAdmission`,
RoutingValueTests, RouteAdmissionTests and RouteSearchingTests need a compatibility
review if their contract changes. No current source/test change is authorized.
Accepted launch scope/exit, Domain/Journey invariants and timetable ownership remain.
Commercial synthetic admission tests remain useful counterexamples, not proof of an
internal solver, real evidence authentication or production completeness.

## Smallest useful search and responsibilities still to design

A **proposed incremental proof**, after contracts and data acceptance, is a scheduled
single continuous ride between distinct supported stations within one reviewed run
and represented interval, with complete qualified boarding/alighting times and
proven departure intent. It could truthfully return a usable direct proposal and
unresolved train attachment only where independently evidenced, not pretend to
support transfers or the entire launch network. A topology-only path with nil times
cannot evade departure intent. This narrow proof is a development slice, **not a
launch-scope change, Phase 3 exit or approved implementation**.

| Responsibility | Required design/evidence; no policy selected here |
|---|---|
| Time-dependent feasibility | T1 active service dates/exceptions, extended hours/zones, eligible board/alight stops, horizon and missing times. Finite inclusive ordering alone is not operational feasibility |
| Alternatives / determinism | Objectives, dominance/equivalence, stable ties/order, bounded exploration and how limits differ from genuine no-results. No algorithm, ranking or cap chosen |
| Transfers | Reviewed line-pair/directional connectivity plus minimum connection/walk feasibility semantics. Search must settle necessary connection timing explicitly; cannot borrow Phase 10 presentation/path promises or treat equal times as feasible |
| Through service | Affirmative same-vehicle/continuous boarding evidence across source fragments, exact occurrences and coverage; never line/name/time adjacency. Outside supported ridden coverage rejects the alternative |
| Incomplete data | Distinguish unavailable/coherently incomplete input, unsupported horizon/portion, rejected alternative and exhaustive no-route evidence. Missing edges or schedules do not prove no physical route |
| Execution / updates | Heavy work off main actor, independent calls, bounded snapshot-driven work, cancellation checkpoints/owned child cancellation, no partial result after cancellation; consistent query view, revision invalidation and retry policy |
| Accuracy / validation | Invented cases first; separately authorized source-backed comparisons, coverage by service/date/boundary, independent expected outcomes and update regressions. No prior synthetic pass certifies an engine |

Cost moves from per-search API fees toward importer/solver design, independent
validation, update monitoring, correction/release work, storage/index size, battery
and support. On-device computation might reduce query disclosure and network calls,
but delivery rights, updates, revocation and key security may require a different
architecture. A server might distribute permitted versioned artifacts or perform
search, at operational/privacy cost; it is neither required nor selected here.
No current ODPT price/SLA claim, zero-cost promise, offline grant, backend choice or
traffic estimate is made. The owner's low-cost/free-app preference is a constraint
for a later measured comparison, not a reason to lower evidence standards.

## Ordered next tasks and exact stopping points

1. **Smallest next task: documentation-only internal-search input/consumer contract
   outline and invented case matrix.** Enumerate the evidence needed for the direct
   proof above; map S9 outputs to T1 outputs and draft exact DEC-076 amendment options
   for §B/§C3/§D/§E. Include missing-time, calendar/midnight, partial coverage,
   repeated visits, through/transfer, incomplete network/no-results and cancellation
   counterexamples. No algorithm, production fields or final semantics accepted.
   Existing records suffice; no private access is needed. Owner must separately
   authorize that scope; DEC-077 remains reviewable rather than self-accepted.
2. **S9 and T1 design can proceed independently with invented data.** S9 owns
   passenger-stop classification/identity/coverage without times; T1 owns calendars,
   schedule/occurrence correspondence, zones/extended hours and missing-time policy.
   Both require their own review/acceptance before implementation. T1 design does
   not wait for S9 completion, but real T1 import does.
3. **Separately scoped evidence closure:** authorize access to identified retained
   inputs before inspecting them; acquire nothing by default. Verify S9 per-feed
   rules and exact coverage. Transfer/through gaps require authoritative input, not
   further topology inference. If existing records cannot close them, propose exact
   public documentation or later source access separately. Commercial contact stays
   paused; missing ODPT proof is not permission to resume it.
4. **Real dependencies:** finish accepted S9 before any real canonical passenger-stop
   Trip consumer, then accepted T1 import/validation before internal search consumes
   imported schedules. Local provisional evidence does not promote registry IDs or
   satisfy public delivery gates. Real internal search is blocked until these plus
   adopted engine/DEC-076 boundary semantics and necessary rights are resolved.
5. **Only after explicit adoption and implementation scope approval:** synthetic
   direct-search proof, then separately authorized real direct evaluation, then
   through/transfers/alternatives and full accepted launch coverage. A direct proof
   cannot close Phase 3. Any genuine launch/exit revision needs a separate owner
   decision; unresolved ODPT-only feasibility must be reported rather than hidden.
