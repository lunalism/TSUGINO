# P2-S9 — First real untimed Trip readiness assessment

**Date:** 2026-10-03 Asia/Seoul\
**Status:** Assessment and proposed access scope only; P2-S9 remains incomplete.\
**Baseline:** `phase/03-route-search`, HEAD/upstream `31617914e5dfb8e7089af67e5279912ecedd149f`;
local/tracked main `e8a463d51f14b3cb1027960c63244b694579a71b`, clean starting tree, 0/0 divergence.
Origin is `lunalism/TSUGINO`. These are locally verified refs, not a new remote-currency claim.

## Scope and conclusion

Phase 3 retains P2-S9 ownership of passenger-stop Trip structure **without times**.
This assessment uses repository records only: no private files, credentials, acquisition,
external research, executable checks or new acceptance. Changes are this assessment and a
ROADMAP link. Accepted decisions and historical records remain unchanged.

**Ready for a separately authorized, owner-only evidence-gap review; not ready to accept a
real Trip.** DEC-082 and DEC-084 A/B/C1/C2 are implemented and independently approved for
invented inputs. DEC-083 accepts bounded registration semantics. The remaining work is not
another generic synthetic slice: it is source-specific evidence/interpretation, a deliberately
authorized real review/tool boundary, and eventually checkpoint-bound provisional registration
and snapshot acceptance. A DEBUG candidate cannot be relabelled as real acceptance.

The first acceptance can concern one explicitly identified historical snapshot. It cannot
certify today's operation, feed-wide completeness, launch coverage or production readiness.
[DEC-075](DECISIONS.md#dec-075--phase-2-baseline-foundation-exit-defers-trip-import-expansion-evidence-and-production-delivery-without-removing-their-gates)
retains S9 before real Trip consumption and P3-T1 real import. The accepted 15-line/two-operator
launch and Phase 3 exit in the [feasibility assessment](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md#accepted-target--unchanged)
are not reduced by this pilot.

## Readiness matrix

Legend: **contract/component** is accepted reusable work; **gap** is unproved real evidence
or missing real tooling; **private** requires separate inspection authority; **gate** blocks
the named deliverable, not all independent assessment.

| Requirement | Contract/component already available | Gap, private evidence and stopping condition |
|---|---|---|
| Identified artifacts | DEC-065–067 source intake/DTO readers and manifests; source/hash/view discipline in DEC-082/084 | Private acquisition/provenance and member manifests must identify exact bytes, obtained date, publisher/distributor/resource and applicability. Hash equality proves retained integrity, not authentication or current availability. No silent replacement with a newer feed. |
| Passenger versus passed positions | DEC-082's positive stop/pass evidence, unknown holds and contradiction rejection; implemented synthetic validator | No accepted Toei/Metro classification profile is recorded. Need authoritative feed/revision semantics or occurrence-specific evidence, exceptions and invalidation. Row presence, blank times, pickup/drop-off or timepoint flags alone are insufficient. Unknown interior positions hold the whole proposal. |
| Order, repeated visits, crosswalk | DEC-060/082 preserve distinct source occurrences and zero-based passenger indices; synthetic lossless codecs | Need a complete scoped position inventory, evidenced ordering-key meaning, exact row locators and independent crosswalk review. Preserve nonconsecutive sequence keys and repeated stations; never sort lexically, deduplicate by station or crop a failed run. |
| Recurring identity and source keys | DEC-083 defines recurring Trip versus dated execution; conditional Trip-only `gtfs.trip_id`; C1/C2 check invented correspondence | Private source profile must establish sourceID publisher/resource/feed scope, uniqueness, recurring meaning and continuity limits. A single static/RT join or identical stop pattern proves neither cross-date identity nor cross-revision continuity. Retain competing assignments and all applicable source claims; unresolved identity holds. |
| Canonical station/line mappings and coherent view | Accepted private provisional S4–S8 foundation; 258 stations, 15 lines, two operators; active mapping/version mechanisms | Inspect only relevant bindings plus their dependency/history closure against the nominated source hash. Verify exact canonical targets, active status, membership and compatible source/mapping/profile/review versions. Names/topology alone are not correspondence; unavailable/ambiguous mappings hold. |
| Movement and through correspondence | DEC-060 line segments and DEC-082 interval/continuity proof roles; split/unsplit normalization in synthetic validator | Need positive line traversal per interval, no interior gap bridging, and same-run evidence for any fragments/through joins. `route_id`, adjacency, headsign or `block_id` alone cannot prove these. Do not invent a passenger stop to represent a passed line-change boundary. |
| Independent boundaries and service types | DEC-060 coverage and DEC-061 optional known service-type segments | Review origin/destination separately. True needs affirmative endpoint evidence; false may mean unknown external extent, recorded as unknown rather than proved continuation. Interior completeness remains mandatory. Unknown service type stays `[]`, not inferred local/express. |
| Approval, allocation and checkpoint | DEC-083 offline owner approval; DEC-084 deterministic approvals/dependencies/history and synthetic replay | Real checkpoint bytes/hash/revision/lineage, complete retained IDs/authorities and owner correspondence/allocation request must be verified. No real Trip allocator, writer or executed conversion is authorized by synthetic code. Existing registry readers remain schema 2 or 2/3, not a real schema-4 Trip registry. Synthetic seed exceptions cannot reset real lineage. |
| Snapshot acceptance and reuse | C2 reconstructs every packet run/transitive predecessor via DEC-082 and validates selection/revision; atomic synthetic output | Need approved real evidence associations, exact registered target and selected predecessor, full immutable packet/crosswalk/history and independent real review. Registration alone is not S9 acceptance. New source/profile/mapping/evidence/view or snapshot changes reopen dependent claims. |
| Downstream use | DEC-078 timetable separation and C2 revalidation obligations | Revalidate dated T1 facts, original-index associations, ride contexts, continuity/eligibility and data-view bindings before new use. No index reuse by TripID/StationID alone; no mutation of old Journey snapshots. T1 feed interpretation/import and production search remain separate. |
| Delivery and rights | DEC-068/074/075 provisional-versus-production boundaries; dated DS-01/03/15 records | Real outputs stay owner-only/provisional. Registry-of-record/adoption, real artifact delivery/composition, attribution and applicable Q3/item-5/Q4 gates remain. Synthetic approval and private acceptance grant no public mappings, bundling or production consumers. |

Authorities: [DEC-082 §§1–6](DECISIONS.md#dec-082--p2-s9-passenger-stop-input-review-recurring-identity-evidence-and-acceptance-plan),
[DEC-083](DECISIONS.md#dec-083--bounded-recurring-trip-registration-before-authoritative-p2-s9-output),
[DEC-084](DECISIONS.md#dec-084--synthetic-trip-registry-schema-and-explicit-legacy-conversion-design),
[ARCHITECTURE](ARCHITECTURE.md) §§5.3/39–41 and [ROADMAP](ROADMAP.md) P2-S4 recovery/acceptance,
DEC-074 local baseline, DEC-075 retained gates and C2 approval records. Earlier Proposed/
unimplemented wording inside preserved decisions is historical; subsequent acceptance/status
overlays govern. The real-use boundary remains unimplemented despite synthetic completion.

## One proposed first evidence-review target

**One owner-nominated recurring-run candidate in the accepted Toei DS-01 static snapshot**, SHA-256
`dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4`, 779,699 bytes,
`feed_version` 20260921. ROADMAP records successful intake and owner acceptance for S4 on
2026-09-30: six routes, 5,600 trips and 122,798 source positions, with reviewed provisional
station/line mappings. This gives the shortest recorded chain to the existing local foundation.
It is evidence of prior availability, not confirmation that the owner still holds the files.

Do **not** select a particular line, run key, stopping pattern or through-service claim from
those aggregate counts. The repository provides no exact run nomination or authoritative
passenger-classification evidence for this hash. The next task needs an owner-supplied opaque
candidate locator and authorized manifest before row inspection. Freeze the entire source-run
record/represented interval before classification, account for every position, and keep a
held candidate rather than replacing it with an easier one. A justified bounded interval is
permitted by DEC-082; shortening after failure is not. No fragment stitching is proposed.

The [provider audit](PROVIDER_FEASIBILITY_AUDIT.md) §6.8 B11 studied **different** historical
hashes: Toei `f10d03cd…` and Metro `9a077f8f…`. Its suspicious-row observations are questions
for review, not a rule for `dd575706…`. ROADMAP explicitly substitutes the latter for the
unavailable pinned Toei archive. The accepted Metro intake is separately `76f04623…`, also
not the B11 archive. Train-timetable JSON remains payload-unverified in repository records;
GTFS-Pathways has different stop correspondence and is not a substitute. No acquisition of
any of these alternatives is proposed. If the nominated source or semantic evidence is
unavailable, the result is an inventory/evidence-gap report, not a fabricated run choice.

## Exact proposed access scope for the next task

**Proposed only; this assessment grants no access.** The next request should authorize one
read-only owner-only review of an explicit allowlist of existing files, with exact hashes
and the nominated run locator supplied privately. No directory discovery or unrelated scan.

| Artifact role | Minimum fields/content to inspect | Review purpose and output boundary |
|---|---|---|
| Source identity and custody | Acquisition record without secrets; resource/source identity, obtained date, archive size/hash, selected member names/hashes, feed version; applicable stored rights/provenance record | Check identity, custody and scope; state unresolved authentication/currency. No URLs containing credentials, headers, account records or tokens are needed. |
| Nominated run/position extract | Scalar-exact `trip_id`, `route_id`, opaque `service_id` only as a source association, stable row locators; every matching `stop_times` `stop_id`, `stop_sequence`, pickup/drop-off/timepoint fields, and **presence/absence only** of arrival/departure fields | Enumerate/order occurrences and questions for classification. No parsing or exporting time values, calendar activation, zones, rollover, dated occurrence or eligibility inference. Names/headsigns are not required identity proof. |
| Existing authoritative interpretation evidence | Identified stored publisher/source documentation or occurrence reviews, exact applicable source/member/revision, supported variants/exceptions, stop/pass, order, recurring-key meaning and continuity assertions | Determine whether a defensible profile can be proposed. No such complete profile is assumed available. Missing documents are reported; no browsing/contact/acquisition or unexplained owner assertion substitutes for evidence. |
| Canonical mapping evidence | Relevant source `stop_id`/route keys and active canonical station/line bindings, membership, approved mapping records, their provenance/view revisions and necessary immutable history | Establish exact correspondence in one view. Shared registry may include Metro-derived records: authorize only needed dependency closure, retain it privately and do not publish raw/restorable mappings. |
| Run extent/movement evidence | Existing identified evidence for selected interval, line traversal, same-run continuity and independent service-origin/destination claims | Distinguish verified movement/endpoints from unknown external extent; expose unsupported through joins and representational conflicts. Do not infer from topology or inspect new sources automatically. |
| Registry/approval baseline | Read-only nominated checkpoint metadata and relevant records/history inventory; existing attachment authority and prior Trip selection if any; owner review identity privately | Assess what a later real workflow would need. No mint, registration, conversion, signing of approval, adoption or checkpoint update. Do not assume the recorded S8 revision 6 is still current or schema-4 compatible. |

Prefer an owner-prepared minimal extract with a manifest binding it to unchanged source bytes;
that extract still needs provenance verification and completeness review. No existing command
is assumed to generate this S9 packet. If deriving it requires new parsing/extraction code,
stop at a tooling specification and obtain separate implementation/verification authorization.
[StaticDataIntake](../Tools/StaticDataIntake/README.md) can supply existing intake evidence and
DTO parsing within its accepted scope; its grouping/topology tools do not classify S9 stops
or establish recurring Trip identity. Running any reader against private inputs still requires
the named access/task authorization. Do not pass real rows into DEBUG synthetic codecs,
validators, test fixtures or app composition as a shortcut.

If authorized later, keep source files read-only; use local memory or a new explicitly approved
owner-only external directory (0700, files 0600, no sync/upload/Git), preserving hashes and
originals. No raw rows, keys, actual canonical IDs, private paths, exact itineraries or detailed
provider diagnostics in chat/public documents. Private output may hold the exact occurrence
worksheet, evidence references and proposed profile/gaps; public output is authorized aggregate
counts by readiness/hold/reject reason and a non-restorable next-step summary. This first task
must return **evidence reviewed / gaps**, not an accepted real Trip or runnable registry delta.

## Smallest ordered path and owner choices

1. Owner supplies the named local artifact allowlist, candidate locator and narrow inspection
   authorization above. Verify existence/integrity only then; document missing semantics and
   evidence, with no real acceptance. No need to decide production registry location first.
2. If the evidence supports the candidate, separately review/accept its feed-specific order,
   classification and recurring-key profile and exact applicability. If it does not, hold;
   separately scope any authoritative evidence acquisition or further interpretation needed.
3. Specify and authorize the smallest real offline review adapter/workflow: lossless occurrence
   extraction, provenance/authentication review, approved-profile application, private diagnostics,
   immutable records, safe I/O and reproducible independent verification. Reuse established
   Domain invariants and reviewed algorithms where justified, with invented regressions first;
   synthetic code reuse requires explicit real-use design/authorization, not just a DEBUG flag.
4. Separately authorize and verify real provisional Trip registration tooling and any legacy
   conversion needed by the identified checkpoint, including all-history uniqueness, owner
   approval and atomicity. Then authorize an actual allocation/registration request. Do not
   create a side registry or supply an invented TripID to bypass this step.
5. Perform independent evidence/snapshot/crosswalk review and owner acceptance for the fixed
   scope against that registry checkpoint; retain all holds/rejections and reproduction evidence.
   A first accepted pilot is not whole-S9 completion. Complete the declared required real scope
   before its consumers, and keep downstream revalidation explicit. P3-T1 real import follows
   S9; production adoption/search and the other retained gates follow their own decisions.

**Evidence gaps are not new policy decisions.** Source-key semantics, stop/pass classification,
line traversal, continuity and provenance must be demonstrated, not chosen by preference.
The inspection grant, candidate nomination, reviewed source profile and later tool/execution
approval are separate owner actions within accepted policy. No new Trip invariant or railway
semantic decision is presently justified by repository evidence. A source that proves an
unrepresentable boundary or needs provider-key reuse/canonical transitions requires a separate
Proposed decision rather than an improvised exception.

**Genuine retained owner policy decisions:** production registry-of-record location, backup,
delivery and identity adoption/migration, plus separately scoped production search policy/
provider adoption. They are not resolved here and do not block this private evidence review.
Applicable Q3, item-5 and Q4 permissions are separate rights/evidence gates; an owner workflow
approval cannot waive them. DEC-078's generic timetable contract is already accepted;
feed-specific timetable interpretation and real P3-T1 import remain separate, not a reason
to import times into S9.
