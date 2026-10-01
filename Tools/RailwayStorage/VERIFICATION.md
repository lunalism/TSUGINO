# Synthetic P2-S8 verification — 2026-09-30

Starting branch `phase/02-static-data`, HEAD `31732d7`; tracked and live upstream
matched. Existing uncommitted measurement code and its documentation were
preserved. DEC-072 was accepted by the owner for SQLite design only.

## Actual verification

- Focused optimized macOS storage runner passed, including complete Domain
  payload/context, scalar-exact names/aliases, stable same-name results, readonly
  reopen, metadata pinning, compatible data revisions, retirement preservation,
  identity-transition holds, no-overwrite behavior, cross-reference failures,
  malformed/unsupported/oversized artifacts, sidecar/symlink rejection, revision
  history integrity, and ordinary-access counters.
- Full app suite: **590 passed, zero failures/skips**, on iPhone 17 Simulator
  (iOS 26.5), including a Debug app/extension build. This preceded the final
  diagnostic-only validation-counter correction. Final focused storage checks
  and the **two repository app integration tests** passed after that correction;
  the broad suite was not repeated.
- **Clean Release app/extension build passed** for the same explicit Simulator
  destination. No physical device or UI workflow was exercised.
- Existing Swift 6 migration warnings in unrelated capability tests and
  AppIntents extraction notices remain. No diagnostic in the new storage paths
  was found. No unrelated warning cleanup was attempted.
- `git diff --check`, new-file whitespace/data-boundary checks and measurement
  source-fingerprint checks passed. No code, artifact or documentation was
  committed/pushed. Real evidence was not read or modified.

The fixed invented schema-v1 artifact is **32,768 bytes**, SHA-256
`7b81c41b6e4ccb960c8011297332c91b36fff9e48f508887752febe1e4938bc0`.
Full-file comparison passes with reordered input, a fresh process/Swift hash seed
and previous-history repeat. A two-revision artifact also repeats byte-identically
without adding history. These observations apply to system SQLite **3.51.0** and
the recorded toolchain; no cross-engine byte guarantee is assumed. No SQLite
nondeterminism was observed in these checks. Sorted collections/insertion order,
fixed settings and omission of runtime timestamps/paths address the known
nondeterministic inputs explicitly.

Final compiled source/test and executable fingerprints and log hashes are in
[verification.json](verification.json). Full logs and xcresult bundles are in the
ignored `.build/` directory. The earlier measurement prototype has not been
rebuilt or remeasured and all its saved source fingerprints remain unchanged.

## One focused adversarial review

The in-session review covered identity boundaries, canonical payload validation,
Unicode keys, schema/size handling, read-only ownership, history, input tracing,
and deterministic output. It was not an independent external review.

Findings fixed with focused coverage:

1. A current content digest alone did not detect alteration of older revision
   metadata. Added chained revision digests and an earlier-entry tampering test
   against a pinned current revision.
2. The reader needed the builder's same-registry-revision/same-registry-hash rule.
   Added reader validation and a contradictory-history regression.
3. The validation diagnostic reported a fixed pass count. Changed it to count
   actual connection validation calls; repeated-access checks now observe that
   counter, so another validation pass cannot be hidden by the diagnostic.

The initial tool compile also found and corrected a test-only async expression.
Sandbox restrictions on Simulator/report-cache access were resolved with the
appropriate authorized tool access; no product behavior was changed for them.
No further broad review round was run.

## Acceptance verdict

The bounded **synthetic repository implementation is verified**. P2-S8 remains
**incomplete**. Measurements/design choice, reopen, supported data-revision
carry-forward, exact search and ordinary-use parsing checks are evidenced.
Existing retirement state/history survives unchanged, but a new canonical
retirement/merge/split transition is rejected: DEC-068's reviewed identity-migration
record contract is not yet specified. Preservation tests are not relabeled as
execution of that missing migration. Schema v1 has no predecessor to convert;
unsupported schemas fail without mutation and require an explicitly separate
compatible build, preserving source and earlier artifacts.

The smallest outstanding design work is that bounded reviewed identity-transition
input contract, without automatic successor following. No real-data repository
acceptance or production installation is claimed. Registry-of-record/production
identity, Q3/publication, Q4/new Metro-derived translations and item 5/bundling
remain independent gates. No distribution authority follows from local tests.
