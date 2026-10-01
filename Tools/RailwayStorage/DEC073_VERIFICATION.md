# DEC-073 synthetic transition verification — 2026-10-01

Starting branch `phase/02-static-data`, HEAD `31732d7`, zero ahead/behind tracked
upstream. All existing SQLite, measurement and documentation work was retained.
The owner accepted revised DEC-073 and its two explicit DEC-068 amendments.
No real registry, transition, evidence, data delivery or physical device was used.

## Implemented scope

The offline validator/applier executes pure retirement, replacement, merge and
split against exact reviewed previous/target snapshots. It checks complete entity
and reference deltas, same-kind/fresh successors, explicit dispositions, evidence
and approval digests, predecessor versions, unique current bindings and immutable
prior provenance/attachment authority. Ordinary reconciliation remains unable to
reassign a held key. Provider-value reuse is not implemented.

Registry v2/runtime v1 semantics remain unchanged. The explicit v2→v3 registry
comparison and runtime v1→v2 rebuild preserve earlier fields/build history;
invalid legacy empty-successor records cannot be converted into valid inputs.
Unknown versions and reverse conversion fail. A pure retired ID exposes an empty
successor set and has no active lookup; no operation follows successors.

The new package contains a read-only runtime artifact, external complete snapshot/
review/evidence history, and a deterministic receipt. Runtime metadata pins the
external manifest hash. History includes prior reference values, original names,
first sightings, provenance and attachment authority; repeats append nothing.
Full validation and a staged reopen precede exclusive atomic directory rename.
The failure hook exists only in the synthetic test build. Input/output artifacts
are never overwritten. Limits and caller-validation boundaries are in README.

## Actual verification

- Optimized synthetic storage runner passed: eight new-application scenarios
  (all four station operations, line/operator replacement, plus reference-free
  and already-withdrawn pure retirement), a second linked transition, reopened
  Domain/retirement/history inspection, immutable earlier direct successor lists,
  exact Unicode/reference checks and duplicate/stale/conflict rejection.
- All three package files compare byte-for-byte from original inputs and from
  carried-forward output. A separate process also builds an identical replacement
  package. Two-boundary history replays without duplicates. Both early validation
  failure and injected failure after staging publish nothing and leave no debris.
- The negative matrix covers wrong kind/cardinality, cycles, unaccounted snapshot
  changes even with freshly scoped review, missing/duplicate dispositions,
  duplicate current bindings (same and different targets), altered old authority,
  stale predecessor, modified evidence/unapproved payload, missing history,
  unsupported versions and bounded oversized input.
- Full static intake suite: **211 passed, zero failed**. Its existing ordinary
  reconciliation regression now also rejects a copied transition disposition ID
  attempting reassignment, preserving the old registry bytes.
- Full app suite: **591 passed, zero failed/skipped**, iPhone 17 Simulator,
  iOS 26.5; Debug app/extension build passed. Release app/extension build passed.
  A subsequently corrected decoder-key actor annotation required **40/40** focused
  registry/repository tests (zero failures/skips) and a successful incremental
  Release build. Final results are recorded in `dec073-verification.json`.
- Earlier schema-v1 fixture output remains 32,768 bytes and SHA-256
  `7b81c41b6e4ccb960c8011297332c91b36fff9e48f508887752febe1e4938bc0`.
  SQLite is 3.51.0; no cross-engine byte guarantee is claimed.
- The original measurement source/report files remain byte-identical. The
  earlier verification record remains historical; new hashes/log references
  are recorded separately. No unchanged prototype measurements were rerun.

## One focused adversarial review and corrections

This was one in-session review, not an independent external review. It covered
scope/delta completeness, reference identity/authority, history replay, schema
semantics, bounds, atomicity, and determinism. Two material gaps were corrected:

1. A descriptive rebuild after migration could request a legacy registry/runtime
   schema. It now rejects reverse conversion; legacy runtime metadata also
   rejects transition-history roles. A downgrade regression covers the builder.
2. New review/version IDs needed collision checks against legacy attachment and
   withdrawal authority, including ordinary checkpoint bridges. Those authorities
   now reserve their IDs; reusing an original attachment ID is rejected.

Final Release diagnostics additionally exposed the new decoder configuration key
as implicitly main-actor isolated. Explicit `nonisolated` fixes that annotation;
only affected app tests and the incremental Release build were repeated. Existing
unrelated Swift migration warnings are not silently represented as fixed.

## P2-S8 audit and limits

The listed **synthetic storage/repository/migration criteria are satisfied**:
measured storage choice, complete Domain round-trip, scalar-exact indexed search,
no ordinary full-dataset reparsing, reopen, data-version history, explicit schema
conversion and newly applied identifier-retirement migrations. This is bounded
synthetic acceptance, not real-data delivery or Phase 2 completion.

The measurement prototype supports DEC-072's storage choice. It is not a
measurement of this repository's full validation-on-open implementation. Actual
validated-repository startup/load/memory evidence remains distinct follow-up;
physical-iPhone startup/search/memory checks were not authorized or performed.
The broader Phase 2 performance/physical acceptance requirements remain open.
P2-S8 remains open pending applicable delivery/acceptance gates; its criteria
were not weakened or expanded to manufacture completion.

Registry-of-record/production-ID, real repository delivery, Q3 publication,
Q4 new Metro-derived translations and ODPT item 5/app bundling remain unchanged.
No registry promotion, minting, real transition, translation, acquisition, UI,
publication, commit, push or merge occurred.

## Subsequent validated-repository measurement — 2026-10-01

The independent macOS repository measurements are now recorded in
[Measurement/RESULTS.md](Measurement/RESULTS.md), with all pre/post samples and
separate verification fingerprints. A measured all-stations-per-line validation
scan was replaced by one exact membership map; no validation rule changed.
The affected storage/transition runner, 25 name-tool cases and eight Simulator
checks passed. Prior results above remain historical and unchanged in meaning.
The final repository measurements do not close actual-app startup attribution or
P2-S11 physical-device evidence; the linked minimal procedure retains those
requirements and all production/delivery/publication gates.


## Subsequent app and physical evidence — 2026-10-01

The historical outstanding measurement items above are now addressed for the
bounded synthetic configuration by the [Simulator startup report](Measurement/Startup/RESULTS.md)
and [physical report and accepted-criteria audit](Measurement/Physical/RESULTS.md).
The latter retains ten offline workload processes and 40 formal startup metric
observations; the 2/2 runner recovery checks are separate. No correctness suite
was rerun during startup collection. This closes those synthetic technical
evidence gaps, not production identity, real delivery, publication/bundling or
Phase 2 exit. P2-S8 overall remains open.
