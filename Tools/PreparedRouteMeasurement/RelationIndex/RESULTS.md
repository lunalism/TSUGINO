# Exploration relation index — matched validation results, 2026-10-18

**Evidence only.** These are invented stress shapes on the iPhone 17 Simulator, not physical
iPhone evidence. **V-O is an optimized DEBUG-condition test build, not Release.** No production
limit, policy or timeout follows from these figures. The frozen method is in [README.md](README.md),
the frozen predictions are in `predictions.json`, and every record is in `results.json`. The §31
and §33 files are unchanged.

## Run and accounting

| | |
|---|---|
| Run | `20261018T222536Z`. Four builds 22:25–22:33 UTC (before the experiment clock). Experiment 22:33:27–22:38:45 UTC: **318.1 s** of the 2 h budget |
| Calls | **1,056 of the 1,056 ceiling**: V-D discovery 16 + 16; V-O timing 4 × 128; V-O stage 4 × 128. Halt: none |
| Processes | 4 `build-for-testing` + 10 test hosts, every exit 0. No external kill, watchdog, memory-guard stop, setup failure or class U/H |
| Plan | Discovery: baseline, optimized. Round 1: timing B, O, then stage B, O. Round 2: timing O, B, then stage O, B |
| Provenance | Baseline = `git archive 9accdea` (solver `1aac67ba…f0cb`, the published merge-sort solver) plus identical harness bytes. Optimized = `git archive HEAD` plus the working changes (solver `748966e9…`). Harness files are identical in both trees. Full fingerprints and tree digests are in `results.json` |
| Separate harness validation | 4 calls on a dev build, on cases outside the matched set (W1-0001, W5-1). All class C. Not part of the 1,056 |
| Reviewer | No reviewer measurement calls; the envelope was used in full by the protocol |

**Environment.**

- **Host:** Apple M2 (Mac14,15), AC power, thermal `nominal` in every record.
- **Toolchain:** Xcode 27.1 (27A9275), iOS Simulator SDK 27.1.
- **Simulator:** iPhone 17, iOS 26.3 runtime.
- **Load:** the 1-minute load average rose from 6.1 to about 150–162 during the run, recorded per
  process. The cause was not measured.

## Correctness, credits and coverage (V-D discovery, one hooked call per case and tree)

| Case | Tree | Class (predicted) | Winners | Digest | Solver work (V-D) | Predicted | Last observed (predicted) | Retained slots |
|---|---|---|---:|---|---:|---:|---|---:|
| W1-0064 | baseline | C (C) | 64 | = §31 | 9266059 | 9266059 (=) | terminal (terminal) | 3401 |
| W1-0064 | optimized | C (C) | 64 | = §31 | 9266060 | 9266060 (=) | terminal (terminal) | 3529 |
| W1-0256 | baseline | C (C) | 256 | = §31 | 87440915 | 87440915 (=) | terminal (terminal) | 15881 |
| W1-0256 | optimized | C (C) | 256 | = §31 | 87440916 | 87440916 (=) | terminal (terminal) | 16393 |
| W1-0257 | baseline | I-solver (I-solver) | — | — | 5118353 | 5118353 (=) | tieCollection (tieCollection) | 2059 |
| W1-0257 | optimized | I-solver (I-solver) | — | — | 5118354 | 5118354 (=) | tieCollection (tieCollection) | 2573 |
| W2a-08 | baseline | C (C) | 64 | = §31 | 54794600 | 54794600 (=) | terminal (terminal) | 4137 |
| W2a-08 | optimized | C (C) | 64 | = §31 | 32742561 | 32742561 (=) | terminal (terminal) | 4297 |
| W2a-09 | baseline | C (C) | 81 | = §31 | 83899972 | 83899972 (=) | terminal (terminal) | 5211 |
| W2a-09 | optimized | C (C) | 81 | = §31 | 48032426 | 48032426 (=) | terminal (terminal) | 5409 |
| W2a-10 | baseline | I-solver (I-solver) | — | — | 99799666 | 99799666 (=) | admission (admission) | 5997 |
| W2a-10 | optimized | C (C) | 100 | new (analytic) | 68269399 | 68269399 (=) | terminal (terminal) | 6813 |
| W2a-11 | baseline | I-solver (I-solver) | — | — | 99961417 | 99961417 (=) | admission (admission) | 5647 |
| W2a-11 | optimized | C (C) | 121 | new (analytic) | 94461355 | 94461355 (=) | terminal (terminal) | 8455 |
| W2b-5 | baseline | C (C) | 32 | = §31 | 37294441 | 37294441 (=) | terminal (terminal) | 3499 |
| W2b-5 | optimized | C (C) | 32 | = §31 | 25408444 | 25408444 (=) | terminal (terminal) | 3551 |
| W2b-6 | baseline | I-solver (I-solver) | — | — | 90658229 | 90658229 (=) | finalization (finalization) | 8196 |
| W2b-6 | optimized | C (C) | 64 | new (analytic + exhaustive) | 69057387 | 69057387 (=) | terminal (terminal) | 8325 |
| W2b-7 | baseline | I-solver (I-solver) | — | — | 98118896 | 98118896 (=) | tieCollection (tieCollection) | 2256 |
| W2b-7 | optimized | I-solver (I-solver) | — | — | 99674503 | 99674503 (=) | admission (admission) | 15464 |
| W3-025 | baseline | C (C) | 9 | = §31 | 44472852 | 44472852 (=) | terminal (terminal) | 701 |
| W3-025 | optimized | C (C) | 9 | = §31 | 10595206 | 10595206 (=) | terminal (terminal) | 773 |
| W3-050 | baseline | I-solver (I-solver) | — | — | 98049919 | 98049919 (=) | tieCollection (tieCollection) | 532 |
| W3-050 | optimized | C (C) | 55 | new (analytic) | 54341063 | 54341063 (=) | terminal (terminal) | 4437 |
| W3-100 | baseline | I-solver (I-solver) | — | — | 99052152 | 99052152 (=) | tieCollection (tieCollection) | 954 |
| W3-100 | optimized | I-solver (I-solver) | — | — | 99550709 | 99550709 (=) | admission (admission) | 15363 |
| W5-4 | baseline | C (C) | 1 | = §31 | 35171878 | 35171878 (=) | terminal (terminal) | 973 |
| W5-4 | optimized | C (C) | 1 | = §31 | 6820829 | 6820829 (=) | terminal (terminal) | 1039 |
| W5-5 | baseline | I-solver (I-solver) | — | — | 99735472 | 99735472 (=) | tieCollection (tieCollection) | 1773 |
| W5-5 | optimized | C (C) | 1 | new (analytic + exhaustive) | 17202046 | 17202046 (=) | terminal (terminal) | 2605 |
| W8-004M | baseline | I-solver (I-solver) | — | — | 3968326 | 3968326 (=) | tieCollection (tieCollection) | 89 |
| W8-004M | optimized | I-solver (I-solver) | — | — | 1 | 1 (=) | indexing (indexing) | 0 |

- **Predictions:** all 32 solver-work values, classes and last-observed stages equal the frozen
  predictions.
- **Unchanged-result parity:** the 7 jointly completed cases (W1-0064, W1-0256, W2a-08, W2a-09,
  W2b-5, W3-025, W5-4) have identical winner counts and digests, equal to §31.
- **Expanded completion coverage:** W2a-10, W2a-11, W2b-6, W3-050 and W5-5 now complete within
  the unchanged 100M ceiling.
  - Each passed the harness's analytic identity check.
  - W2b-6 and W5-5 (P ≤ 16) also passed the exhaustive oracle.
  - They have no §31 winner set to compare with.
- **Observation-point changes:**
  - W2b-7 and W3-100 still cut off, now in admission rather than after the last tie-collection
    entry.
  - W8-004M (4M limit) now cuts off earlier. The last observed point is the indexing entry (work 1).
    That the cutoff falls inside index construction is inferred: validation costs less than in the
    baseline, which passed validation under the same limit.
  - The direct-route controls W1-0064, W1-0256 and W1-0257 rise by exactly +1 credit (the index
    preflight).
- **Storage (retained slots):**
  - Jointly completed cases rise by `2P + E`; for example W1-0256 rises by 512, which is 2P with
    E = 0.
  - Cases that progress further before a cutoff retain more; for example W2b-7 goes from 2,256 to
    15,464.

## V-O matched timing (median [min–max] of 7 after one warm-up)

| Case | Round | Baseline stage solve ms | Optimized stage solve ms | Ratio | Baseline whole ms | Optimized whole ms |
|---|---:|---:|---:|---:|---:|---:|
| W1-0064 | 1 | 1.347 [1.306–1.646] | 1.000 [0.991–1.580] | 0.742 | 1.813 [1.471–2.266] | 2.372 [2.198–7.287] |
| W1-0064 | 2 | 1.125 [0.835–1.710] | 0.916 [0.899–0.982] | 0.815 | 1.764 [1.547–2.466] | 1.496 [1.375–3.061] |
| W1-0256 | 1 | 10.199 [9.075–11.925] | 7.011 [6.204–10.455] | 0.688 | 9.720 [7.950–10.641] | 12.602 [9.896–19.602] |
| W1-0256 | 2 | 6.135 [5.270–8.906] | 5.781 [5.678–6.203] | 0.942 | 9.502 [8.394–11.711] | 8.725 [7.598–13.156] |
| W1-0257 | 1 | — | — | — | 6.691 [4.460–13.452] | 7.322 [6.449–8.580] |
| W1-0257 | 2 | — | — | — | 5.637 [4.945–6.656] | 4.816 [4.602–8.046] |
| W2a-08 | 1 | 3.797 [3.102–5.543] | 1.900 [1.743–2.593] | 0.501 | 3.970 [2.741–9.562] | 3.661 [3.062–4.865] |
| W2a-08 | 2 | 1.962 [1.931–2.570] | 1.742 [1.722–1.887] | 0.888 | 3.536 [3.096–4.027] | 2.609 [2.505–6.243] |
| W2a-09 | 1 | 5.344 [4.322–6.948] | 2.563 [2.424–3.581] | 0.480 | 6.235 [4.723–12.068] | 4.927 [4.816–6.202] |
| W2a-09 | 2 | 4.196 [2.768–4.572] | 2.390 [2.359–2.566] | 0.570 | 4.818 [4.239–5.368] | 3.526 [3.299–5.881] |
| W2a-10 | 1 | — | 3.787 [3.531–4.794] | — | 5.106 [4.582–21.458] | 6.832 [6.289–7.254] |
| W2a-10 | 2 | — | 3.236 [3.197–3.682] | — | 5.863 [5.149–6.063] | 5.296 [4.373–11.956] |
| W2a-11 | 1 | — | 4.681 [4.638–6.085] | — | 8.179 [4.980–11.116] | 9.438 [8.294–13.038] |
| W2a-11 | 2 | — | 4.317 [4.236–4.598] | — | 6.168 [5.460–6.214] | 6.000 [5.704–13.225] |
| W2b-5 | 1 | 3.063 [2.314–3.585] | 1.669 [1.488–2.477] | 0.545 | 3.123 [1.854–6.033] | 2.457 [2.039–3.736] |
| W2b-5 | 2 | 1.478 [1.439–2.388] | 1.369 [1.357–1.483] | 0.927 | 2.246 [1.993–2.277] | 1.728 [1.651–3.513] |
| W2b-6 | 1 | — | 4.386 [3.833–5.086] | — | 5.282 [4.188–8.267] | 5.753 [4.651–6.145] |
| W2b-6 | 2 | — | 3.447 [3.431–3.793] | — | 5.153 [4.562–5.206] | 4.238 [3.761–5.466] |
| W2b-7 | 1 | — | — | — | 4.154 [3.597–7.391] | 10.776 [8.855–17.932] |
| W2b-7 | 2 | — | — | — | 4.486 [3.984–4.531] | 7.052 [6.729–12.864] |
| W3-025 | 1 | 1.690 [1.549–3.928] | 0.531 [0.482–1.170] | 0.314 | 2.258 [1.880–3.449] | 1.937 [1.671–2.659] |
| W3-025 | 2 | 1.034 [0.983–1.593] | 0.456 [0.438–0.483] | 0.441 | 2.389 [2.077–2.710] | 1.388 [1.258–1.748] |
| W3-050 | 1 | — | 3.132 [2.537–3.268] | — | 3.988 [3.292–7.410] | 4.614 [3.837–9.489] |
| W3-050 | 2 | — | 2.285 [2.270–2.511] | — | 3.919 [3.471–3.991] | 3.223 [3.167–4.687] |
| W3-100 | 1 | — | — | — | 4.512 [3.423–8.553] | 13.646 [10.476–19.092] |
| W3-100 | 2 | — | — | — | 4.388 [3.863–4.432] | 9.361 [8.144–11.328] |
| W5-4 | 1 | 1.866 [1.579–2.628] | 0.670 [0.658–1.005] | 0.359 | 1.539 [1.383–2.178] | 1.722 [1.176–5.029] |
| W5-4 | 2 | 1.095 [1.033–1.618] | 0.604 [0.597–0.660] | 0.551 | 1.785 [1.574–1.817] | 0.979 [0.917–1.005] |
| W5-5 | 1 | — | 2.010 [1.737–2.910] | — | 3.359 [3.088–5.819] | 3.093 [2.564–7.231] |
| W5-5 | 2 | — | 1.591 [1.583–1.735] | — | 3.973 [3.525–4.197] | 2.124 [1.981–3.225] |
| W8-004M | 1 | — | — | — | 1.337 [0.865–3.491] | 1.371 [1.109–2.006] |
| W8-004M | 2 | — | — | — | 1.039 [0.884–1.101] | 1.106 [0.843–1.449] |

**Targets (§34.8):**

- W3-025: stage-solve median ratio ≤ 0.5 in both rounds: MET ([True, True])
- W5-4: stage-solve median ratio ≤ 0.75 in both rounds: MET ([True, True])

**Observations.**

- **Target ratios:** W3-025 0.314 / 0.441 and W5-4 0.359 / 0.551.
- **Other jointly completed relation-scan shapes** (no claim):
  - W2a-08 0.501 / 0.888;
  - W2a-09 0.480 / 0.570;
  - W2b-5 0.545 / 0.927.
- **Direct-route controls:** W1-0064 and W1-0256 do no relation work, yet their stage ratios were
  0.742 / 0.815 and 0.688 / 0.942, below 1 in both rounds even though round 2 reversed the tree
  order. This is unexplained, and a systematic tree or session bias of up to about 30% cannot be
  excluded.
  - W3-025's margin is robust to such a bias.
  - W5-4's round-2 margin (0.551, against controls of 0.815 / 0.942) is narrower than the raw ratio
    suggests.
  - The predeclared criteria are met as written; no cause is claimed.
- **Newly completing cases** have no baseline solve to compare. Their whole-call time to completion
  is similar to the baseline's time to cutoff (for example W5-5 3.1/2.1 ms against 3.4/4.0 ms).
- **Cases that still cut off do more work before the ceiling,** so they take longer: W2b-7 10.8/7.1
  against 4.2/4.5 ms, and W3-100 13.6/9.4 against 4.5/4.4 ms.
- **Variability:** absolute times vary up to about 2× between rounds for the same tree while load
  climbed. Only within-round paired ratios are interpreted.

## Limitations

- **Not representative:** invented shapes only.
- **Not Release, not iPhone:** Simulator on a loaded Mac host; V-O is not Release.
- **Small samples:** one session; n = 7 per cell; V-D is one call per case and tree.
- **Correlation, not profiling:** the runtime gain is consistent with fewer and cheaper operations
  but is not attributed by profiling.
- **Admission:** its linear relation scans now dominate the remaining cutoffs (W2b-7, W3-100) and
  were not changed.
- **Construction cost:** it is paid up front and can move low-budget cutoffs earlier (W8-004M).
- **Gates still open:** real-workload (G1/G3), Release, device and deployment gates are unchanged.
