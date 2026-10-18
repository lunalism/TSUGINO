# Winner ordering — matched validation results, 2026-10-17

**Evidence only.** These are invented stress shapes on the iPhone 17 Simulator, not physical
iPhone evidence. **V-O is an optimized DEBUG-condition test build, not Release.** No production
limit, policy, mapping or timeout follows from these figures. The frozen method is in
[README.md](README.md). Every record is in `results.json`, and the frozen predictions are in
`predictions.json`. The §31 files in the parent folder are unchanged.

## Run and accounting

| | |
|---|---|
| Run | `20261017T194225Z`. Four builds 19:42–19:50 UTC (before the experiment clock). Experiment 19:50:20–19:55:14 UTC: **293.7 s** of the 2 h budget |
| Calls | **660 of the 660 ceiling**: V-D discovery 10 + 10; V-O timing 4 × 80; V-O stage 4 × 80. Halt: none |
| Processes | 4 `build-for-testing` + 10 test hosts, every exit 0. No external kill, watchdog, memory-guard stop, setup failure or class U/H |
| Plan | Discovery: baseline, optimized. Round 1: timing B, O, then stage B, O. Round 2: timing O, B, then stage O, B |
| Provenance | Baseline tree = `git archive 3368eb1` plus the working harness bytes. Its solver SHA-256 `f8670cac…6627` equals the base commit and the §31 run-time solver. Optimized tree = `git archive HEAD` plus the working changes; solver `1aac67ba…f0cb`. Harness files are identical in both trees (`PreparedRouteMeasurementTests.swift` `79e91cd9…bc81`; probe and workloads unchanged since §31). Full fingerprints and tree digests are in `results.json` |
| Separate harness validation | 4 calls before the run, on a dev build, on cases outside the matched set (W1-0001 and W5-1 discovery; W1-0001 timing 1 + 1). All class C. Not part of the 660 |
| Reviewer | No reviewer measurement calls; the 660-call envelope was used in full by the protocol |

**Environment.**

- **Host:** Apple M2 (Mac14,15), 8 CPUs, AC power. Thermal state `nominal` in every record.
- **Toolchain:** Xcode 27.1 (27A9275), iOS Simulator SDK 27.1.
- **Simulator:** iPhone 17, iOS 26.3 runtime.
- **Host load, recorded per process:** the 1-minute load average rose from 5.3 at the start to
  about 212 at the end. The cause was not measured. Each pair of trees ran back to back, and the
  order was reversed in round 2, so neither tree always ran under the lighter load.

## Correctness, credits and observation points (V-D discovery, one hooked call per case and tree)

| Case | Tree | Class | Winners | Digest = §31 | Solver work (V-D) | Predicted | Last observed |
|---|---|---|---:|---|---:|---:|---|
| W1-0064 | baseline | C | 64 | yes | 9311566 | 9311566 (=) | terminal |
| W1-0064 | optimized | C | 64 | yes | 9266059 | 9266059 (=) | terminal |
| W1-0128 | baseline | C | 128 | yes | 27116002 | 27116002 (=) | terminal |
| W1-0128 | optimized | C | 128 | yes | 26927021 | 26927021 (=) | terminal |
| W1-0256 | baseline | C | 256 | yes | 88209662 | 88209662 (=) | terminal |
| W1-0256 | optimized | C | 256 | yes | 87440915 | 87440915 (=) | terminal |
| W1-0257 | baseline | I-solver | — | — | 5118353 | 5118353 (=) | tieCollection |
| W1-0257 | optimized | I-solver | — | — | 5118353 | 5118353 (=) | tieCollection |
| W2a-08 | baseline | C | 64 | yes | 54840071 | 54840071 (=) | terminal |
| W2a-08 | optimized | C | 64 | yes | 54794600 | 54794600 (=) | terminal |
| W2a-09 | baseline | C | 81 | yes | 83974702 | 83974702 (=) | terminal |
| W2a-09 | optimized | C | 81 | yes | 83899972 | 83899972 (=) | terminal |
| W2a-10 | baseline | I-solver | — | — | 99915309 | 99915309 (=) | admission |
| W2a-10 | optimized | I-solver | — | — | 99799666 | 99799666 (=) | admission |
| W2b-5 | baseline | C | 32 | yes | 37305816 | 37305816 (=) | terminal |
| W2b-5 | optimized | C | 32 | yes | 37294441 | 37294441 (=) | terminal |
| W3-025 | baseline | C | 9 | yes | 44473398 | 44473398 (=) | terminal |
| W3-025 | optimized | C | 9 | yes | 44472852 | 44472852 (=) | terminal |
| W5-4 | baseline | C | 1 | yes | 35171876 | 35171876 (=) | terminal |
| W5-4 | optimized | C | 1 | yes | 35171878 | 35171878 (=) | terminal |

- Every class, winner count and route digest is identical between trees and equal to §31.
- Solver work equals the frozen prediction in all 20 observations.
- **Observation point moved:** W2a-10 still cuts off in admission. The recorded last admission
  entry is now 99,799,666 credits instead of 99,915,309. That value equals the charge model's entry
  for the 82nd winner; the winner index is model-derived, and the records hold only the credit.
- **Unchanged:** W1-0257 stops at the winner cap before ordering, so nothing changes there.
- **No class or cutoff-stage change** in this subset. The charge model predicts none across the 37
  §31 cases either. That matrix-wide prediction was not measured here.

## V-D solver ordering segment (one hooked Debug call, discovery)

| Case | Tree | V-D ordering segment ms | V-D solve ms |
|---|---|---:|---:|
| W1-0064 | baseline | 154.60 | 167.62 |
| W1-0064 | optimized | 25.53 | 41.47 |
| W1-0128 | baseline | 596.75 | 630.81 |
| W1-0128 | optimized | 42.89 | 79.75 |
| W1-0256 | baseline | 2367.94 | 2478.48 |
| W1-0256 | optimized | 94.81 | 229.59 |
| W1-0257 | baseline | — | 0.00 |
| W1-0257 | optimized | — | 0.00 |
| W2a-08 | baseline | 136.07 | 185.69 |
| W2a-08 | optimized | 16.68 | 78.22 |
| W2a-09 | baseline | 219.38 | 293.69 |
| W2a-09 | optimized | 22.39 | 129.06 |
| W2a-10 | baseline | 331.07 | 0.00 |
| W2a-10 | optimized | 41.86 | 0.00 |
| W2b-5 | baseline | 36.32 | 68.69 |
| W2b-5 | optimized | 13.13 | 77.03 |
| W3-025 | baseline | 2.53 | 37.86 |
| W3-025 | optimized | 1.56 | 113.05 |
| W5-4 | baseline | 0.00 | 37.73 |
| W5-4 | optimized | 0.01 | 72.14 |

- **Ordering segment** (ordering entry to admission entry):
  - W1-0256: 2,367.9 → 94.8 ms;
  - W1-0128: 596.8 → 42.9 ms;
  - W2a-09: 219.4 → 22.4 ms.
- **Single-call noise:** these are one sample per tree. Unrelated segments vary 2–3× between the
  two calls; for example W3-025 and W5-4 solve times, which have almost no ordering work. "V-D
  solve ms" is 0 where the call cut off before the solve checkpoint.

## V-O matched timing (median [min–max] of 7 after one warm-up)

| Case | Round | Baseline stage solve ms | Optimized stage solve ms | Ratio | Baseline whole ms | Optimized whole ms |
|---|---:|---:|---:|---:|---:|---:|
| W1-0064 | 1 | 3.186 [3.074–3.318] | 0.736 [0.711–1.366] | 0.231 | 6.220 [4.201–11.823] | 2.259 [1.255–18.497] |
| W1-0064 | 2 | 7.334 [6.348–8.940] | 1.851 [1.366–5.299] | 0.252 | 3.937 [3.653–4.140] | 1.274 [1.208–1.649] |
| W1-0128 | 1 | 12.590 [11.847–12.710] | 1.761 [1.715–2.777] | 0.140 | 19.798 [15.156–25.976] | 5.138 [3.254–6.438] |
| W1-0128 | 2 | 27.823 [23.865–116.177] | 3.946 [3.437–15.232] | 0.142 | 14.124 [13.550–14.703] | 2.966 [2.722–5.718] |
| W1-0256 | 1 | 48.760 [46.744–50.596] | 4.613 [4.530–9.491] | 0.095 | 73.749 [59.598–102.780] | 10.736 [7.779–16.834] |
| W1-0256 | 2 | 100.309 [93.156–128.963] | 10.698 [8.945–20.197] | 0.107 | 53.325 [51.289–56.324] | 6.818 [6.364–8.298] |
| W1-0257 | 1 | — | — | — | 5.221 [4.221–7.401] | 6.819 [5.735–13.925] |
| W1-0257 | 2 | — | — | — | 3.803 [3.610–3.962] | 4.017 [3.893–5.491] |
| W2a-08 | 1 | 4.159 [4.044–4.272] | 1.702 [1.667–4.854] | 0.409 | 7.459 [5.449–9.254] | 4.403 [2.602–5.883] |
| W2a-08 | 2 | 9.431 [8.207–10.342] | 3.866 [3.158–28.293] | 0.410 | 5.132 [4.774–5.307] | 2.445 [2.419–5.028] |
| W2a-09 | 1 | 6.379 [6.270–6.734] | 2.457 [2.356–5.032] | 0.385 | 11.078 [8.295–18.971] | 5.682 [3.519–7.495] |
| W2a-09 | 2 | 14.810 [12.715–19.522] | 4.874 [4.530–11.205] | 0.329 | 7.726 [7.449–8.084] | 3.396 [3.300–3.796] |
| W2a-10 | 1 | — | — | — | 17.972 [12.532–23.480] | 5.700 [4.022–10.857] |
| W2a-10 | 2 | — | — | — | 10.896 [10.143–10.960] | 4.119 [4.008–6.084] |
| W2b-5 | 1 | 1.817 [1.786–1.918] | 1.264 [1.257–2.307] | 0.696 | 3.917 [2.401–6.917] | 2.801 [1.632–3.420] |
| W2b-5 | 2 | 3.784 [3.482–5.044] | 2.664 [2.306–3.431] | 0.704 | 2.172 [2.023–2.204] | 1.575 [1.560–1.662] |
| W3-025 | 1 | 0.865 [0.816–0.904] | 0.890 [0.869–2.962] | 1.028 | 2.006 [1.790–3.878] | 2.959 [1.757–4.897] |
| W3-025 | 2 | 1.929 [1.646–2.419] | 1.758 [1.612–2.862] | 0.911 | 1.584 [1.481–1.658] | 1.757 [1.651–2.825] |
| W5-4 | 1 | 0.849 [0.808–0.856] | 0.932 [0.887–2.702] | 1.099 | 1.977 [1.257–8.491] | 2.224 [1.323–9.744] |
| W5-4 | 2 | 1.876 [1.608–2.347] | 2.326 [1.609–3.079] | 1.240 | 1.161 [1.085–1.243] | 1.255 [1.223–1.354] |

**Target (§32.6):** optimized V-O stage-pass solve median ≤ 0.5× baseline in both rounds.

- W1-0128: stage-solve median ratio ≤ 0.5 in both rounds: MET ([True, True])
- W1-0256: stage-solve median ratio ≤ 0.5 in both rounds: MET ([True, True])

**Observations.**

- **Targets:** stage-pass solve ratios were 0.140/0.142 for W1-0128 and 0.095/0.107 for W1-0256.
  Timing-pass whole-call medians moved in the same direction:
  - W1-0256: 73.7 → 10.7 ms in round 1 and 53.3 → 6.8 ms in round 2;
  - W1-0128: 19.8 → 5.1 and 14.1 → 3.0 ms.
- **Other tie-heavy cases:** W2a-08, W2a-09 and W2b-5 also fell, with stage ratios 0.33–0.70.
  W2a-10 cuts off before the solve checkpoint; its whole-call medians fell from 18.0 to 5.7 ms
  and from 10.9 to 4.1 ms. These are reported without a claim.
- **Controls without ordering work:** W3-025 and W5-4 gave stage ratios 0.91–1.24 (W5-4 above 1
  in both rounds), and W1-0257's whole calls were slightly slower. They are not interpreted.
- **Session drift:** absolute times differ about 2× between rounds for both trees. For example,
  stage-pass medians in round 2 are about twice round 1 while load climbed. Only the within-round
  paired ratios are interpreted.

## Limitations

- **Not representative:** invented shapes; the Simulator on a loaded Mac host.
- **Not Release, not iPhone:** V-O is not Release, and nothing measures a physical iPhone.
- **Small samples:** one host and one session; n = 7 per cell; V-D is one call per case and tree.
- **Variability:** about 2× between processes and rounds; host load rose throughout the run.
- **Correlation, not profiling:** the runtime gain is consistent with the reduced operation count.
  Which instructions dominate per operation was not profiled.
- **Relation-scan cutoffs remain.** Credit cutoffs in W2a ≥ 10, W2b ≥ 6, W3 ≥ 50% and W5-5 are
  unchanged; W2a-10 still needs about 123.7M credits. Candidate 3 in §32.5 remains the
  evidence-supported follow-up.
- **Gates still open:** real-workload (G1/G3), Release, device and deployment gates are unchanged.
