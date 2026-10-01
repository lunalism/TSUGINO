# P2-S8 bounded technical review — 2026-10-01

**Ready for code review; no new material implementation defect identified in one
focused in-session review.** This is not an independent external audit, production
acceptance or Phase 2 completion. No code, tests, builds, performance runs or device
access were needed in this review. Only documentation/evidence inventory changed.

## Scope and Git

`phase/02-static-data`, HEAD `31732d77910cd2d96cf4858a95a50f2b2ab3a922`, tracks
`origin/phase/02-static-data`, zero ahead/behind the locally tracked upstream.
No fetch or push was performed, so this is not a fresh remote-server assertion.
Nothing is staged. All pre-existing implementation, prototype, measurement and
owner-only evidence is preserved. The exact proposed path list and SHA-256 values
are in [final-review.json](final-review.json); ignored build products/logs, runtime
SQLite files, raw device results and real provider artifacts are excluded.

## Focused findings and boundaries

- **Storage:** read-only actor-owned connection, consistent read transaction,
  exact schema/integrity/content/index validation before exposure; resource limits
  and unsupported schemas fail without mutation. Ordinary search uses BLOB UTF-8
  keys and matched-record decoding. Composed/decomposed names, explicit aliases,
  stable ordering and same-name distinct identities retain their accepted rules.
  Full validation occurs at open; explicit full loads are separately counted.
- **Identity transitions:** exact previous/target scope and complete delta checks;
  all four operations, fresh same-kind successors, no active reference on a pure
  retirement, explicit dispositions and immutable predecessor/attachment authority.
  History replay retains earlier snapshots/reviews and rejects missing history;
  v2/v3 registry and v1/v2 runtime semantics are distinct. Staged validation and
  exclusive directory publication precede exposure. No ordinary reconciliation
  reassignment, minting, provider-value reuse or automatic successor following.
- **Measurement isolation:** both probe files and the sole app call are inside
  `REPOSITORY_STARTUP_MEASUREMENT`. No checked-in build configuration defines it.
  `AppEnvironment.live()` has no repository/probe dependency. Offline builders,
  prototype and test fault hook are outside the app target; the fault hook also
  requires `RAILWAY_STORAGE_TESTING`. Heavy startup work is detached and repository
  opening is `@concurrent`; ordinary production composition cannot activate the
  probes with launch arguments alone. This is source/configuration verification,
  not a claim that a new shipping binary was built today.
- **Trust boundary:** the builder consumes caller-validated names/network inputs
  and records their hashes; it does not itself reapprove editorial selections or
  establish that arbitrary supplied bytes are published/approved data. The
  synthetic API is not an accepted real-data installer. Runtime hashes establish
  integrity/identified inputs, not publisher authenticity. Full editorial and
  provider-reference history remains external. Close/reopen/atomic output checks
  do not claim power-loss-safe installation or cross-SQLite-version byte identity.
- **Documentation corrections:** the current open-decision list incorrectly still
  presented storage format selection as open; it now points to Accepted DEC-072.
  README now distinguishes unchanged search semantics from the measured membership
  optimization. The roadmap audit below separates technical acceptance from each
  gated deliverable. Historical decision bodies and measurement reports remain.

No speculative optimization or additional review round was performed.

## Exact-code evidence reuse

- Of 175 final DEC-073 source/test fingerprints, 172 match directly. The only
  later changes are the app measurement hook, `ExactStationIndex.swift` and its
  tests. The two index files exactly match the later measurement verification;
  its 62 final source fingerprints all match. All eight saved DEC-073 logs and
  six affected-measurement logs match their hashes.
- The app hook and both probe files match the preserved physical-run source
  inventory; both probe copies also match the actual measured-source copies.
  The final physical archive retains the unchanged executable hash, 40 formal
  startup observations, ten prior workload processes and separate 2/2 recovery
  checks. No disconnected device is needed for this review.
- Reused gates: 211 tool tests; 591 app tests; final 40 affected registry/repository
  checks and incremental Release; Debug/Release app-and-extension evidence.
  The later membership optimization has 25 affected name-tool checks, eight app
  checks and the storage/transition runner. The broader suites predate those
  bounded changes; they are not misrepresented as freshly rerun final-source suites.
- The prototype is historical comparison evidence. Three shared dependencies
  subsequently changed under the separately verified transition/index work;
  prototype-owned sources remain unchanged. Its timings are not attributed to
  the final validated repository. macOS, Simulator and physical measurements are
  separately labeled; no unaccepted speed threshold or demonstrated improvement
  is inferred from overlapping ranges.

## Accepted-criteria audit

| Accepted requirement | Actual evidence / verdict |
|---|---|
| ROADMAP P2-S8: measured storage decision | DEC-072 plus compact/SQLite comparison; later full-validation measurements. Met for synthetic scope. |
| P2-S8 / Rule 15: ordinary use does not repeatedly parse full dataset | SQL/index design, matched-record and validation/full-load counters, regression and ordinary-access workloads. Met. |
| P2-S8: reopen, data-version and identifier-retirement migration | DEC-073 verification: new retire/replace/merge/split application, supported version handling, retained history, reopen, failures and deterministic reruns. Met synthetically. |
| Phase 2 performance tasks | Artifact size, validated open/load/search/memory; Simulator and physical startup attribution. Recorded, with cache and telemetry limitations. |
| Phase 2 physical checks / S11 | Specifically authorized iPhone: process-cold launch pairs, repository exact-search speed/correctness, memory and offline workloads. Recorded; title-only responsiveness is not search UI or touch latency. |
| Phase 2: baseline searchable, deterministic mappings | Existing S4–S7 local provisional real acceptance; 825 names, six aliases, two distinct Shinjuku results, complete named topology. Reused document evidence, not a new real-data run. Final SQLite integration with those real outputs has not been performed. |
| Phase 2 exit: topology stable enough for route/realtime integration | S6/S7 provide local provisional topology/name evidence. This review does not authorize production identity/delivery or resolve S9/S10 exit planning. Phase exit is not declared. |

The explicit **bounded synthetic P2-S8 technical checklist is met**. No additional
mandatory synthetic test or measurement was identified. P2-S8's overall delivery
status and Phase 2 exit remain open; that is not an assertion that every external
permission blocks every development activity. This audit adds no new acceptance
criterion and does not require a production bundle merely to commit the code.

## Gates mapped to deliverables

| Gate or task | What it actually blocks | What it does not block |
|---|---|---|
| DEC-068 §F1 registry of record | Production ID allocation/adoption; committing real mapping/reference/grouping/binding records for either operator. Owner must decide location, backup and delivery, with explicit identity adoption/migration. | Synthetic code commits, existing local provisional acceptance, or separately authorized owner-only provisional integration. No automatic promotion. |
| Real-data repository integration | A claim that this SQLite builder/runtime has consumed the accepted real S6/S7 outputs end-to-end. Requires a bounded authorized adapter/build/validation workflow; this is implementation/acceptance work, not a new storage-format choice. | Synthetic technical acceptance. An owner-only provisional rehearsal does not inherently need production IDs or public distribution permission. |
| Q3 / DEC-065 §A / DEC-068 §F3 | Publishing Tokyo Metro-derived mapping records, absent ODPT reply or a separately accepted publication decision. Other derived output still needs its applicable rights assessment. | Synthetic code, safe aggregates/hashes, retained private evidence and authorized local review. No reply is assumed. |
| ODPT item 5 / applicable licence duties | Bundling normalized Basic-License static data in a shipped app; needs written confirmation and applicable attribution/update/non-restorability compliance. | A synthetic-only build or private provisional evaluation. Registry location alone grants no bundling permission. |
| Q4 | New Metro-derived translation authoring. | Reusing already approved exact published names in an authorized private validation; no new translations are required merely to review/commit this implementation. |
| Final app delivery/composition | Selecting/installing an identified real artifact and wiring shipping repository dependencies with compatibility/recovery handling. Needs its delivery scope and applicable identity/licence gates. | Offline synthetic repository implementation; measurement hook is not delivery wiring. |

## S9/S10: accepted scope, not invented prerequisites

ROADMAP's accepted slice table assigns **S9 → S4**: `Trip` structure import,
stop sequences **without times**, only if Phase 2 is to import Trip records.
DEC-061 §F requires provider/feed-specific passenger-stop verification before
constructing a `stopSequence`; pass-through GTFS rows cannot be assumed passenger
stops. DEC-060 §F / DEC-065 §F leave timetable ownership unresolved and outside
Phase 2. S8 stores Station/Line/Operator data and does not depend on S9. No accepted
text here makes new Trip/timetable implementation a prerequisite to this commit.

The table assigns **S10 → S0**: Tier 1 payload evidence under DEC-058 §4 / DEC-059,
with explicit Basic-License access authorization and **no capability declaration**.
Tier 1 remains required expansion candidates, not supported baseline lines or
optional forever. Evidence is needed before eventual promotion, but the roadmap
explicitly leaves whether S10 counts toward Phase 2 exit open. It is not an S8
storage dependency and no additional acquisition is authorized by this review.

The smallest phase-exit planning decision is whether S9 and/or S10 belong to this
baseline exit. Recommended for review: do not add either as an S8 prerequisite;
retain their accepted future obligations and explicitly settle inclusion/deferral
before declaring Phase 2 complete. A deferral must record ownership/next gate;
this report neither accepts that decision nor invents a later phase assignment.

## Concrete commit plan (not executed)

Use the exact path allowlist in `final-review.json`, recheck hashes/staged diff,
whitespace and public-data boundary immediately before an authorized commit.
Do not stage whole directories indiscriminately or ignored build/evidence files.

1. `Record synthetic compact-file and SQLite storage comparison` — the nine
   `Tools/StorageMeasurement/` source, script, module, ignore and report files.
   This preserves the experiment's historical proposal wording, not a second
   current contract; accepted DEC-072 is in the next coherent implementation commit.
2. `Implement validated SQLite storage and reviewed identity transitions` — all
   remaining allowlisted Domain/Data/App code, synthetic tests, storage tools,
   safe measurement reports, DEC-072/073 acceptance/amendments, ARCHITECTURE and
   ROADMAP, plus this final review/inventory. Measurement instrumentation remains
   compile-flagged and unwired in normal composition.

No real IDs/records, SQLite payload files, credentials, device identifiers,
provisioning profiles, raw logs/xcresults or owner evidence enter either commit.
Approval to commit these synthetic changes is separate from all data gates above.
The next production decision, when production adoption is desired, is DEC-068 §F1;
ODPT questions should only block the affected translation/publication/bundling
activity, not be prerequisites to this technical code review.


## Authorized commit preflight correction — 2026-10-01

The staged check exposed one extra blank line at EOF in
`Measurement/build.sh`, previously untracked and therefore outside the earlier
tracked-only whitespace check. Removed that blank line only; shell syntax passed.
Recorded source fingerprints remain historical: this script now differs only by
that whitespace correction, without changing build arguments or executable code.
No test/build/measurement rerun is warranted. The exact commit inventory includes
the corrected script and this note; all other reviewed implementation bytes match.
