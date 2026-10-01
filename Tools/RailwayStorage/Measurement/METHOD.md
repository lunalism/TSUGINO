# Validated repository measurement method — 2026-10-01

Defined before running measurements. Scope: isolated invented-data macOS harness
compiled with Swift `-O`, language mode 5, against the unchanged final repository,
SQLite connection, validation, Domain/index and deterministic offline builder.
No validation bypass, app wiring, real artifacts, or new dependency. Existing
prototype measurements and correctness records remain unchanged.

## Criteria boundary

ROADMAP P2-S8's slice-specific checks require a measured storage decision,
ordinary-use no-reparse proof, reopen, data-version and retirement migrations.
DEC-072/073 do not equate macOS or Simulator timing with iPhone startup. The
Phase 2 Performance Tasks additionally require app startup impact; its Physical
Device Test/P2-S11 requires physical cold launch/search/memory/offline evidence
and separate explicit device authorization (never LunaTestphone). This harness
closes independent repository measurements, not those app/device requirements.
A paired startup/device procedure is supplied separately; no arbitrary pass
threshold is invented.

## Datasets and samples

Wholly invented canonical names/coordinates/IDs, connected chain lines and exact
aliases. Launch: 258 stations, 15 lines, 2 operators, 6 aliases. Scale: 25,800,
1,500, 200, 600. Each size has a baseline runtime-v1 case and a runtime-v2 case
with one actually applied reviewed replacement, a retained retired ID and two
build revisions. Active counts stay constant. Full transition evidence remains
external; runtime retains its hash. This tests representative compact history
cost, not maximum-depth history or runtime decoding of external reviews.

Five repetitions per size/case, serial execution and alternating baseline/history
order. Each preparation and runtime mode uses a fresh process. Never purge OS
caches: “cold” means process-cold only. Record all raw samples and min/median/max;
no confidence interval or physical-device inference. Compilation and fixture
creation are outside runtime timing. Record fixture-generation and artifact
preparation/transition build costs separately; preparation includes the builder's
normal validation and staged reopen.

## Runtime measurements

- Artifact bytes; external history bytes reported separately.
- `open`: await normal repository open, including SQLite integrity/schema checks,
  complete content and identity validation, hash/index comparison and context load.
- First exact query after open, and open-plus-first query, timed separately.
- Warm exact search: 1,024 fixed mixed canonical/alias/Unicode/miss queries; one
  untimed priming pass then three timed passes. Record median/p95 per query.
  Consume result counts. Same-name stations remain separate, composed/decomposed
  spellings distinct; independently assert those cases and whitespace alias.
- Current resident memory via Mach task_info and process peak RSS via getrusage
  (Darwin bytes), before/after open, after priming and after each warm pass.
  Include repeated-access memory deltas; snapshots/high-water are not allocation
  counts, leak proofs or device footprint. No result cache is added.
- Close and reopen separately, plus first query after reopen. Each reopen performs
  normal validation. Peak RSS is sampled before reopen too, isolating ordinary use.
- A separate fresh process measures open then full Domain load (all stations,
  lines, operators); keep returned collections alive through memory sampling.
  Timings exclude JSON printing and output-file hashing.
- Existing diagnostics measure validation passes, full-load calls and station
  record decodes before/after ordinary queries. The current implementation builds
  an in-memory exact-index oracle once per validation; it never writes/rebuilds
  the persisted SQL index in read-only access. Report this distinction explicitly:
  validation-pass deltas bound full-content validation/oracle reconstruction;
  source inspection establishes no separate ordinary index-build path. No invented
  index-rebuild counter is claimed.

Output artifacts are checked for identical bytes across preparation repetitions,
unchanged bytes after runtime reads, correct active/retired counts and repository
results. Existing correctness suites/builds are reused only after matching their
saved source hashes. Only harness compilation and measurement correctness checks
run unless a concrete defect demands an affected fix.

## Comparison limits

Prototype and repository share host, optimization style and dataset cardinalities,
but not exact fixture bytes, validation work, caching or query mix. Size and timing
are contextual comparisons, not controlled ratios or regressions. In particular,
the prototype does not perform this reader's complete validation on open. Report
that work honestly; do not disable it for favorable numbers.

Pre-run environment correction: preparation at the workspace location returned
`unavailable`; an identical invented fixture succeeded in the system temporary
directory. A later minimal hard-link probe succeeded at both locations, so the
precise failing preparation operation is unverified; do not attribute it to
unsupported hard links. All measured artifacts therefore
use that temporary filesystem, not the workspace volume. The initial failed
preparation and diagnostic smoke run are excluded from the five samples. The
builder/validation is unchanged; cross-filesystem performance is not assumed.

Evidence-backed follow-up, after the complete original 20-sample run: source
inspection found one all-stations scan per line during exact membership
validation (38,700,000 probes at scale). Replace only that scan with a membership
map accumulated once from declared memberships. Preserve both-direction exact
set equality, all other validation and encoded artifacts. Run targeted correctness
checks, then repeat the identical five-sample method. Keep the original samples
in `before-membership-fix.json`; compare bytes as well as runtime results. This
is a bounded validation-cost fix, not a relaxed check or a new backend.

All samples completed before sandbox restrictions blocked hardware metadata
collection. Environment metadata was subsequently read with authorized access;
`--summarize-only` finalized retained samples without rerunning them.
