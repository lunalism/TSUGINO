# P2-S8 synthetic storage measurements — 2026-09-30

Evidence only; DEC-072 is Proposed. P2-S8 is not complete. No app backend,
production IDs, real data, migration implementation or delivery is introduced.

## Method and environment

The [method](README.md) was written before measurements. The isolated executable
uses unchanged Domain types and ExactStationIndex as its correctness oracle.
Apple M2, 16 GiB RAM, arm64 macOS 26.6.2 (25G83), Swift 6.4, SDK 27.0,
Swift language mode 5, `-O`; system SQLite (CLI version 3.51.0). No third-party
dependency. Measurements are inside a native macOS CLI process, excluding process
spawn/runtime startup. They are **not physical-iPhone or app startup measurements**.
No Simulator or device was used. CPU contention, thermal state and filesystem
cache state were uncontrolled.

Five fresh-process samples per representation/size, alternating representation
order; preparation immediately precedes reader sampling, so file pages may be
warm. One priming pass and three timed passes of 1,024 fixed mixed queries per
reader. Memory is whole-process high-water RSS, not a storage-only delta. Data
contains connected synthetic chains, not realistic geography or workload
frequency; the scale case is 100× entities, not a forecast of launch usage.

## Observations

Each cell is **median [minimum–maximum] across five samples**. Warm p95 is the
median of five within-process p95 values, not a pooled p95. All samples, exact
fixture SHA-256 values, source fingerprints and binary SHA-256 are retained in
[results.json](results.json). Synthetic source/artifact files remain ignored in
`.build/run`; no real evidence was opened.

| Metric | Compact: 258 stations | SQLite: 258 stations | Compact: 25,800 stations | SQLite: 25,800 stations |
|---|---:|---:|---:|---:|
| Artifact (KiB) | 100.631 [100.631–100.631] | 136.000 [136.000–136.000] | 11212.398 [11212.398–11212.398] | 12448.000 [12448.000–12448.000] |
| Preparation (ms) | 12.705 [11.723–1241.323] | 11.697 [11.344–1236.744] | 13629.579 [7247.481–18614.812] | 9533.147 [8551.198–24499.115] |
| Open (ms) | 9.047 [8.922–11.095] | 3.025 [2.960–3.450] | 660.318 [649.159–736.009] | 95.861 [91.954–106.290] |
| First query after open (ms) | 0.077 [0.064–0.081] | 0.059 [0.057–0.067] | 0.124 [0.113–0.132] | 0.102 [0.097–0.987] |
| Open + first query (ms) | 9.121 [8.987–11.176] | 3.082 [3.021–3.509] | 660.443 [649.273–736.133] | 95.963 [92.051–107.138] |
| Warm median (µs/query) | 0.583 [0.583–0.667] | 5.458 [5.375–5.708] | 0.750 [0.750–0.750] | 6.541 [6.458–6.917] |
| Warm p95 (µs/query) | 2.125 [1.917–2.458] | 6.875 [6.250–7.250] | 8.875 [8.542–9.041] | 15.167 [14.791–18.209] |
| 3,072 ordinary queries (ms) | 3.192 [2.987–3.737] | 17.109 [17.074–18.085] | 11.205 [10.828–11.410] | 28.353 [28.099–30.085] |
| Close (ms) | 0.069 [0.067–0.079] | 0.059 [0.055–0.067] | 7.182 [7.062–8.013] | 1.889 [1.758–2.041] |
| Reopen + first query (ms) | 7.291 [6.815–7.920] | 1.192 [1.167–1.307] | 653.925 [647.764–674.880] | 91.683 [88.752–93.403] |
| Full station decode (ms) | 1.602 [1.547–1.724] | 1.584 [1.551–1.666] | 149.588 [145.433–156.916] | 159.988 [150.338–161.561] |
| Open + full load (ms) | 10.773 [10.355–11.403] | 5.112 [4.827–5.281] | 820.050 [785.297–820.837] | 254.465 [242.885–259.774] |
| Ordinary process peak RSS (MiB) | 8.656 [8.625–8.672] | 8.484 [8.453–8.484] | 56.562 [56.547–56.609] | 26.453 [26.438–26.469] |
| Full-load process peak RSS (MiB) | 8.406 [8.391–8.422] | 8.156 [8.094–8.188] | 59.250 [59.219–59.297] | 38.266 [38.250–38.297] |
| Preparation peak RSS (MiB) | 9.844 [9.828–9.875] | 9.641 [9.641–9.641] | 122.906 [122.875–122.906] | 107.250 [107.250–107.281] |
| Ordinary station record decodes | 98.000 [98.000–98.000] | 98.000 [98.000–98.000] | 1550.000 [1550.000–1550.000] | 1550.000 [1550.000–1550.000] |
| Ordinary directory/index decodes | 1.000 [1.000–1.000] | 0.000 [0.000–0.000] | 1.000 [1.000–1.000] | 0.000 [0.000–0.000] |
| Ordinary full-fixture parses | 0.000 [0.000–0.000] | 0.000 [0.000–0.000] | 0.000 [0.000–0.000] | 0.000 [0.000–0.000] |
| Cache occupancy | 98.000 [98.000–98.000] | 98.000 [98.000–98.000] | 256.000 [256.000–256.000] | 256.000 [256.000–256.000] |

The launch fixture has 15 lines, two operators and six aliases; the scale fixture
has 1,500 lines, 200 operators and 600 aliases. Every sample uses identical saved
fixture bytes for its size. Each backend validates the same full logical dataset.
Preparation includes common fixture decoding, existing exact-index construction
and validation, encoding, and synchronous writes. Its wide observed range is
retained, without outlier deletion; the cause was not isolated. These measurements
do not establish a reliable preparation-speed ranking.

Both ordinary-access paths parse the full source fixture zero times. Compact
loads its entire directory and line/operator context once per open; SQLite loads
context once and traverses its persisted index per query. Both lazily decode
station records and use the same 256-record FIFO cache. Small-case working sets
fit; the scale workload evicts records. Explicit full-load samples decode every
station once in a separate process. Reopen works without re-importing the fixture.

## Correctness and focused verification

- Optimized standalone build passed. Initial compilation needed a writable local
  module-cache path and correction to existing unlabeled ID initializers; both
  were fixed before measurements. No app code changed.
- 20/20 prepared artifacts passed complete context and station-payload comparison,
  every canonical-name/alias query, negative queries, stable ordering and reopen.
  Total oracle comparisons: 787,920 (786 per small artifact; 78,006 per large).
- Independent assertions preserve composed/decomposed names as different keys,
  two same-name StationIDs as separate ordered results, and whitespace-sensitive
  explicit aliases without implicit normalization or prefix/case matching.
- Ordinary access counters and checksums agree across backend/repetition; zero
  full-fixture parses, bounded cache, and full-load decode count equals size.
- Eight focused unsupported-version/framing/size rejection cases passed. A
  supplementary check confirmed clean exit status 1 with an error report rather
  than a crash. Both schema and data-version rejection were exercised.
- Saved fingerprints match all compiled source inputs, benchmark code/method and
  executable. No broad suites, app/extension builds or physical-device work ran.

## Inference and recommendation

Propose system SQLite for the next backend slice. Observed open-to-first-result
medians were 3.08 ms versus 9.12 ms at launch size, and 95.96 ms versus 660.44 ms
at scale. Ordinary peak RSS was 26.45 MiB versus 56.56 MiB at scale. SQLite avoids
a custom offset/index file reader and has established transactional machinery;
that maintainability argument is reasoning, not a benchmark measurement.

The compact file is smaller (100.63 versus 136 KiB at launch) and its warm
queries are faster (0.58 versus 5.46 µs median). SQLite pays per-query statement
and index traversal overhead even when the station payload is cached. Full
station decode time at scale is similar; much of the total-load difference is
open/context/directory work. The comparison evaluates these two prototypes,
not every possible compact format or tuned SQLite design. A lazy binary directory
could change the trade-off, but is additional custom work not justified here.

No iPhone latency/memory target, cold-disk performance, energy behavior, crash-safe
installation, concurrent-reader behavior or production migration is proven.
Final SQL layout, bounded context loading and repository API remain implementation
work after decision acceptance. No successor-following policy is inferred.
