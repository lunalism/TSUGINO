# P2-S8 synthetic measurement prototype

Scope lock: isolated macOS CLI and invented fixtures only. No final repository,
app wiring, real inputs, production IDs, migration engine or delivery. Compiles
unchanged Domain and exact-index code; system SQLite C API adds no package.

## Method (specified before measurements)

Build Swift `-O`, Swift language mode 5. Generate one JSON fixture per size:
258 stations/15 lines/2 operators and 25,800/1,500/200; six explicit aliases per
258 stations. All values are invented, including fixed test identifiers (not
minted registry IDs). Connected chain topologies and three-language labels;
two same-name stations, composed/decomposed keys, and explicit whitespace alias
are included. Both backends consume exactly the same saved fixture bytes.

Compare a single indexed compact file (binary-plist directory and context,
concatenated per-station JSON payloads, offsets, UTF-8 sorted keys, binary search)
with SQLite (same JSON station payloads, BLOB exact-key index, primary keys,
context metadata). Both eagerly load line/operator context, lazily decode station
records and use the same 256-record bounded cache. SQLite uses system defaults,
DELETE journal, FULL synchronous import transaction and a reusable search
statement; compact preparation fsyncs the completed file. No claim of equivalent
crash-safe publication: neither is a production installer.

Five repetitions per size, alternating backend order. Each preparation, read,
and full-load sample is a fresh process. Preparation includes fixture decoding,
existing ExactStationIndex validation/construction, serialization and durable
write; fixture generation and compilation are excluded. Artifact bytes exclude
the common input fixture and executable. Cold means process-cold, not disk-cold:
OS caches are uncontrolled and not purged. Open and first usable search are
reported separately and as a sum. Initial search includes station decoding;
context is loaded during open. No app or physical-iPhone startup is measured.

Warm workload: 1,024 deterministic mixed queries (canonical names, aliases,
misses, Unicode cases), one untimed priming pass then three timed passes; report
per-query median and p95 per process. Ordinary access includes open, first query,
priming and timed passes. Report full-fixture parses, index decodes, station
record decodes and bounded-cache occupancy. Close/reopen is timed in-process and
checks the first query again. Explicit full load runs separately, includes open
and decoding all station records, and retains the returned array until memory
sampling. Peak memory is process high-water RSS from getrusage (Darwin bytes),
including runtime/context/cache; not incremental allocation or device footprint.

Correctness runs outside timings against the existing ExactStationIndex oracle:
all names/aliases, negative/scalar-distinct queries, complete station payloads,
line/operator context, stable result order and reopen. Counts must show zero
full-fixture parses during ordinary queries. Distinct spellings and the
same-name two-result case also have independent assertions. Tests reject an
unsupported compact schema and SQLite user_version. Bounds are prototype-only:
256 MiB artifacts, 64 MiB compact directory; this is not a general untrusted
input reader. Failures stop the run. No migration or successor lookup is added.

Run `sh Tools/StorageMeasurement/build.sh`, then
`python3 Tools/StorageMeasurement/run.py`. Generated synthetic data/artifacts
stay in ignored `.build/`; aggregate results and source/input fingerprints are
written to `results.json`. Inspect results before making any storage decision.
Report ranges across five samples, not statistical confidence intervals.
