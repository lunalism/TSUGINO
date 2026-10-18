# Winner ordering — matched validation (consumer §32.6)

This method is frozen before any matched measurement call. The governing specification is
[consumer §32.6](../../../docs/PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#32-bounded-solver-optimization-audit--2026-10-17).
The §31 experiment and its files in the parent folder stay unchanged.

## Change under test

`SolverKernel.ordered(_:)` in `TSUGINO/Data/Routing/InternalRouteSolver.swift` replaces the
insertion sort with a bottom-up merge sort over an `Int` index permutation. The `less` comparator
is unchanged.

| Charge | Amount |
|---|---|
| Preflight before allocation | One charge for the index, scratch and output buffers: `slots 2n + 1`, `bytes 16n + 8n + 72`, work 1 |
| Comparison | `1`, plus the unchanged `less` charges |
| Element move | `1` (merge step or run tail) |
| Permuted output copy | Per winner, by value: `slots count + 1`, `bytes 8·count + 24`, work 1 |

## Builds and provenance

- **Baseline tree:** `git archive` of `3368eb13d102831ba473b84e13cb0f0329451cf6`, overlaid with the
  working harness files. These are `PreparedRouteMeasurementTests.swift`, the probe and the workloads.
- **Optimized tree:** `git archive HEAD`, overlaid with every modified or untracked working file.
- **Where:** both trees are exported under `/private/tmp/tsugino-ordering-<UTC>/`, and both are
  built there. The working checkout is never built from or modified.
- **Provenance checks:** the driver records the solver and harness SHA-256 for each tree, plus a
  whole-tree digest. It halts unless the harness bytes are identical and the baseline solver equals
  the base commit.
- **Variants:**
  - **V-D:** standard Debug.
  - **V-O:** Debug with `SWIFT_OPTIMIZATION_LEVEL=-O SWIFT_COMPILATION_MODE=wholemodule`. This is
    an *optimized DEBUG-condition test build*. **It is not Release.**
- **Destination:** the explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`. No device.

The harness gained two options that are off by default, so §31 behaviour is unchanged:

- `TSUGINO_PRS_ONLY` limits discovery to the listed case IDs.
- `TSUGINO_PRS_REPS` sets the timed-pass repetitions.

## Protocol

**Cases (10)** with their §31 discovery classes:

| Case | Class |
|---|---|
| W1-0064, W1-0128, W1-0256 | C |
| W1-0257 | I-solver (winner cap) |
| W2a-08, W2a-09 | C |
| W2a-10 | I-solver (admission) |
| W2b-5, W3-025, W5-4 | C |

**Order.** One fresh test-host process per row:

| # | Pass | Variant | Trees | Calls |
|---|---|---|---|---|
| 1–2 | Discovery (hooked) | V-D | baseline, optimized | 10 each, one per case |
| 3–6 | Round 1: timing, then stage | V-O | baseline, then optimized | 80 each, 1 warm-up + 7 per case |
| 7–10 | Round 2: timing, then stage | V-O | optimized, then baseline | 80 each |

Discovery uses composition and solver hooks; the stage pass uses composition hooks only.

**Envelope.**

- **Calls:** at most 660 search calls in total (20 + 640). Each process gets the remaining budget
  and the deadline, and checks them before every call.
- **Time:** 2 h of experiment wall clock after the builds; 20-minute cap per process.
- **Watchdog:** 60 s in V-O and 180 s in V-D.
- **Stops:** class U, class H, a memory guard (2 GiB), a discovery class differing from §31, or
  a provenance failure halts the run. There are no automatic retries and no broadening.

**Harness validation, separate.** Before the matched run, `run.py validate` makes 4 calls on an
existing dev build: W1-0001 and W5-1 in discovery, and W1-0001 in the timing pass at 1 + 1. These
cases are outside the matched set. The calls are recorded as validation, never as measurement.

## Predictions (frozen in `predictions.json` before any matched call)

The predictions come from the charge model validated in §32.1, which reproduces all 37 §31
observations exactly. Baseline predictions equal the §31 recorded values for all 10 cases.

| Case | Baseline work | Optimized work | Last observed stage |
|---|---:|---:|---|
| W1-0064 | 9,311,566 | 9,266,059 | terminal |
| W1-0128 | 27,116,002 | 26,927,021 | terminal |
| W1-0256 | 88,209,662 | 87,440,915 | terminal |
| W1-0257 | 5,118,353 | 5,118,353 | tieCollection (winner cap; ordering never reached) |
| W2a-08 | 54,840,071 | 54,794,600 | terminal |
| W2a-09 | 83,974,702 | 83,899,972 | terminal |
| W2a-10 | 99,915,309 | 99,799,666 | admission: the observation point moves; still inside the 82nd winner |
| W2b-5 | 37,305,816 | 37,294,441 | terminal |
| W3-025 | 44,473,398 | 44,472,852 | terminal |
| W5-4 | 35,171,876 | 35,171,878 | terminal (+2: storage preflight and one output copy) |

- **Matrix-wide:** across all 37 §31 cases, no class and no cutoff stage changes.
- **Moved observation points:** W2a-10 and W2b-6 change their last-observed credit, and W2a-11's
  cutoff moves from the 25th to the 26th winner.
- **Comparisons:** W1-0256 drops from 32,640 to 1,024 and W2a-09 from 3,240 to 242.

## Acceptance (§32.6)

1. **Correctness:**
   - every case has the same class, winner count and winner digest as §31;
   - the V-D solver work equals the prediction;
   - all tests pass.
2. **Runtime:** in **both** rounds, the optimized V-O stage-pass `solve` median is **≤ 0.5×** the
   baseline median for W1-0128 and W1-0256.
3. **Controls:** the other cases are reported without a claim.
4. **Failure:** if criterion 2 fails, the result is reported as negative or inconclusive. The
   experiment is not broadened.

## Artifacts

- `predictions.json`: frozen predictions.
- `run.py`: the driver.
- `test_run.py`: synthetic driver tests.
- `results.json`: every record. Host metadata is restricted to the power-source line; checkout and
  raw paths are redacted to `<repo>` and `<raw>`.
- `RESULTS.md`: the summary.
- Raw DerivedData, logs and JSONL stay under `/private/tmp/tsugino-ordering-<UTC>/` and are not
  committed.
