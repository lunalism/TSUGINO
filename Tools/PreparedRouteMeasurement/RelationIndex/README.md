# Exploration relation index — matched validation (consumer §34.8)

This method is frozen before any matched measurement call. The governing specification is
[consumer §34](../../../docs/PHASE_3_INTERNAL_ROUTING_AMENDMENT_PROPOSAL.md#34-per-ride-feasible-relation-lists-design-and-cost-audit--2026-10-18).
The §31 and §33 experiment files stay unchanged.

## Change under test

`InternalRouteSolver` builds per-ride ascending feasible-relation lists `O(z)` and `In(z)` after the
validation loops, and accepts exploration transitions by sorted intersection (§34.4).

| Charge | Amount |
|---|---|
| Preflight | `slots 2P`, `bytes 48P`, work 1 |
| Per relation | State check 1 |
| Per (feasible relation, ride) pair | 4,096 |
| Per entry | `slots 1`, `bytes 8`, work 1, charged before the append |
| Per lookup | 1, plus 1 per merge step |

`makeClaim` and `admit` keep their linear scans over the original P.

## Builds and provenance

- **Baseline tree:** `git archive 9accdeae9e3e6070647a546746aa3ee2cff0132c`, which is the published
  merge-sort solver, overlaid with the working harness files.
- **Optimized tree:** `git archive HEAD`, overlaid with every modified or untracked working file.
- **Where:** both are exported and built under `/private/tmp/tsugino-relindex-<UTC>/`. The working
  checkout is not built from.
- **Provenance checks:** the driver records the solver and harness SHA-256 for each tree and a
  tree digest. It halts unless the harness bytes are identical and the baseline solver equals the
  base commit.
- **Variants:**
  - **V-D:** standard Debug.
  - **V-O:** Debug with `SWIFT_OPTIMIZATION_LEVEL=-O SWIFT_COMPILATION_MODE=wholemodule`. This is
    an optimized DEBUG-condition test build. **It is not Release.**
- **Destination:** the explicit iPhone 17 Simulator `84E47945-9D2E-446F-8C40-B835A9D15880`. No device.

## Protocol

**Cases (16), with frozen predictions from `ChargeModel/charge_model.py`** (merge model for the
baseline, index model for the optimized tree). The model reproduces all 47 recorded credit
observations.

| Case | §31 class | Baseline: class @ last observed, credits | Optimized: class @ last observed, credits |
|---|---|---|---|
| W1-0064 | C | C @ terminal, 9,266,059 | C @ terminal, 9,266,060 |
| W1-0256 | C | C @ terminal, 87,440,915 | C @ terminal, 87,440,916 |
| W1-0257 | I-solver | I-solver @ tieCollection, 5,118,353 | I-solver @ tieCollection, 5,118,354 |
| W2a-08 | C | C @ terminal, 54,794,600 | C @ terminal, 32,742,561 |
| W2a-09 | C | C @ terminal, 83,899,972 | C @ terminal, 48,032,426 |
| W2a-10 | I-solver | I-solver @ admission, 99,799,666 | C @ terminal, 68,269,399 |
| W2a-11 | I-solver | I-solver @ admission, 99,961,417 | C @ terminal, 94,461,355 |
| W2b-5 | C | C @ terminal, 37,294,441 | C @ terminal, 25,408,444 |
| W2b-6 | I-solver | I-solver @ finalization, 90,658,229 | C @ terminal, 69,057,387 |
| W2b-7 | I-solver | I-solver @ tieCollection, 98,118,896 | I-solver @ admission, 99,674,503 |
| W3-025 | C | C @ terminal, 44,472,852 | C @ terminal, 10,595,206 |
| W3-050 | I-solver | I-solver @ tieCollection, 98,049,919 | C @ terminal, 54,341,063 |
| W3-100 | I-solver | I-solver @ tieCollection, 99,052,152 | I-solver @ admission, 99,550,709 |
| W5-4 | C | C @ terminal, 35,171,878 | C @ terminal, 6,820,829 |
| W5-5 | I-solver | I-solver @ tieCollection, 99,735,472 | C @ terminal, 17,202,046 |
| W8-004M | I-solver | I-solver @ tieCollection, 3,968,326 | I-solver @ indexing, 1 |

Each tree's discovery classes must equal its own predicted classes, otherwise the run halts.

**Order.** One fresh test-host process per row:

| # | Pass | Variant | Trees | Calls |
|---|---|---|---|---|
| 1–2 | Discovery (hooked) | V-D | baseline, optimized | 16 each |
| 3–6 | Round 1: timing, then stage | V-O | baseline, then optimized | 128 each, 1 warm-up + 7 per case |
| 7–10 | Round 2: timing, then stage | V-O | optimized, then baseline | 128 each |

**Envelope.**

- **Calls:** at most 1,056 search calls (32 + 1,024). No reviewer measurement calls are allowed
  beyond these.
- **Time:** 2 h of experiment wall clock after the builds; 20-minute cap per process.
- **Watchdog:** 60 s in V-O and 180 s in V-D.
- **Stops:** class U or H, the memory guard, a predicted-class mismatch or a provenance failure halts
  the run. There are no retries and no broadening.

**Harness validation, separate.** Before the run, `run.py validate` makes 4 calls on a dev build,
using cases outside the matched set. They are recorded as validation only.

## Acceptance (§34.8)

1. **Correctness:**
   - every completed case has the analytic class, winner set and digest, plus the §31 digest where
     §31 completed;
   - new completions are checked against the analytic oracle, and also the exhaustive oracle when
     P ≤ 16;
   - solver work and the last observed stage equal the predictions exactly;
   - all tests pass.
2. **Runtime:** in both rounds, the optimized V-O stage-solve median is **≤ 0.5×** baseline for
   W3-025 and **≤ 0.75×** for W5-4.
3. **Formerly incomplete cases** are reported honestly. Any deviation from a prediction is
   investigated and reported. Limits are never changed.

## Artifacts

- `predictions.json`: frozen predictions.
- `run.py`: the driver.
- `test_run.py`: synthetic driver tests.
- `results.json`: sanitized records; power-source line only; `<repo>` and `<raw>` placeholders in
  commands.
- `RESULTS.md`: the summary.
- Raw DerivedData and logs stay under `/private/tmp/tsugino-relindex-<UTC>/` and are not committed.
