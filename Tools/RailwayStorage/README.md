# P2-S8 synthetic SQLite repository

DEC-072 is Accepted for storage design. This bounded implementation does not
complete P2-S8 or authorize real data delivery. No data is wired into the app.
Only invented fixtures are used. The earlier StorageMeasurement prototype and
its measurements remain unchanged; they do not measure this validated repository.
The proposal status in that preserved report is historical; DEC-072 now records
the accepted design.

## Ownership and access

Domain owns the asynchronous `RailwayDataRepository` protocol. Data owns the
`SQLiteRailwayRepository` actor, storage DTOs, validation and SQLite connection.
`open` is explicitly `@concurrent`; all later IO runs on the repository actor.
The offline builder in this folder is not part of the app target. System SQLite
is imported through Apple's SDK module; no third-party dependency or custom
app module map is required. The synchronous `StationSearching`/in-memory index
retains its contract; its membership-validation scan was optimized with separately
recorded regression checks. The repository exposes equivalent async exact search.

The repository supports individual station/line/operator lookup, explicit full
collections, exact name/alias search with line/operator context, close/reopen,
metadata and identity/retirement inspection. Missing and retired IDs have no
current Domain payload; lookups return nil, never a successor. Retirement status
and the declared successor list remain separately inspectable. There is no
normalization, prefix search, ranking, implicit alias, identity creation or UI.

## Versioned runtime artifact

Seven SQLite tables contain:

- `stations`: exact ID, three canonical names, coordinate and sorted line IDs;
- `lines`: ID, operator ID, three names and canonically ordered undirected edges;
- `operators`: ID and three names;
- `aliases`: exact UTF-8 key and existing station ID;
- `search`: persisted exact canonical-name/alias key to every matching StationID;
- `entities`: all canonical identities supplied by the registry, including
  retirement state and complete declared successors;
- `metadata`: schema version and the append-only build-revision chain.

IDs and search keys use BLOBs, avoiding SQLite text collation. Payloads use
canonical sorted-key JSON with sorted collections, represented by Data-owned
DTOs. Domain Codable shapes do not change. Scalar-exact `ExactValue` and the
existing `ExactStationIndex` validator are reused. The identity subset is checked
with existing `MappingRegistry` invariants, including kind/successor/cycle checks.

Each revision records an opaque scalar-exact **data version**, the separate
integer **registry revision**, SHA-256 of the supplied registry/name/network
input bytes, the canonical content digest and the preceding revision digest.
The registry bytes are decoded with the existing strict registry reader and
must contain exactly the supplied entity states. Name/network bytes identify
caller-supplied upstream inputs: the builder does not independently re-run the
editorial or network review workflow and does not certify those inputs as
approved. Their validated canonical payload is checked for Domain integrity and
bound by its separate digest. This synthetic entry point is not a real-data
intake/approval workflow. Real adoption remains a separate authorized task.

Original provider fields, editorial selections, source captures, alternatives,
worksheets and choice/sighting histories stay outside the runtime artifact.
Existing source artifacts are retained separately, addressable by the recorded
input hashes; prior artifacts are never overwritten. The revision chain retains
input identities and old content digests, not full old Domain payloads. Hashes
establish byte identity/internal consistency, not publisher authentication or
proof of approval. A caller may pin the complete expected current revision on
open, including its link to earlier history.

## Validation, bounded resources and ordinary use

Open is read-only, rejects symlinks/non-regular files and journal/WAL sidecars,
holds a consistent SQLite read transaction, checks SQLite integrity and the exact
schema, and performs **one full canonical validation pass** before exposure.
This checks complete payloads, identity state, cross-references/membership,
aliases, content digest, revision chain and the entire persisted search index.
It prevents malformed artifacts from yielding partial apparently valid data.
It is more validation than the measurement prototype; no reuse of its startup
numbers as repository results is claimed.

Ordinary queries use indexed SQL and decode matched station records only. Line
and operator context is retained after open. No ordinary query reads an upstream
input, rebuilds the index or decodes all stations. `allStations` is an explicit
full-load operation, separately counted. There is no write API on the repository.
Diagnostics expose validation passes, query record decodes and explicit loads.

Bounds: 256 MiB artifact; 8 MiB individual encoded record/SQLite value; 100,000
rows per query and 100,000 combined canonical entities/models/aliases;
1,024 revision entries; 3–32 input fingerprints per revision. SQLite length and
SQL limits are applied. These bounds cover the launch dataset and the measured
100× entity case, while capping eager validation. They are operational limits,
not promises of iPhone memory/latency at the maximum. The existing registry
reader keeps its own stricter input rules. Exceeding a bound fails; history is
never trimmed. Errors report rules rather than raw SQL/input content.

## Compatibility, retirement and invalidation

Runtime schema 1 and registry schema 2 retain their original nonempty-successor
semantics. Runtime schema 2 and registry schema 3 implement accepted DEC-073;
unknown versions fail without mutation. The ordinary intake reader still reads
only registry v2. The explicit transition reader accepts v2/v3, validating each
under its own rules. Invalid old inputs are never legalized by conversion.
Data versions remain opaque exact labels, independent of registry revisions.

Ordinary descriptive rebuilds preserve every entity state and attachment;
identity changes require the dedicated reviewed transition path. A descriptive
rebuild after migration must supply the verified `retainedHistory`; omitting it
or requesting a reverse schema conversion fails. Previous runtime revisions
remain intact, and identical repeats append no history.

### Offline reviewed transitions

`IdentityTransition.publish` accepts exact previous/target registry bytes,
canonical encoded approved records, optional prior history, the pinned previous
runtime artifact, validated target Domain/name/network inputs, a data version
and an exclusively new output directory. It never generates a target registry
or chooses an identifier, name, reference target or successor. It supports pure
retirement (no affected active reference), replacement, merge and split, using
DEC-073's fresh-successor and explicit-disposition rules. Missing review, unknown
fields/versions, duplicate current bindings, altered predecessors/authority,
stale scope, incomplete delta and lost history fail before publication.

A record retains exact scope, before/after entities and references, predecessor
record/version identifiers, the new attachment authority, rationale/dependencies,
review identity/role/time/reference and the reviewed payload digest. Evidence
retains its capture kind, source, bytes/hash, locator, exact quoted byte range,
member scope and stated non-name support. Raw bytes, extracts and invented
fixtures remain distinguishable. Validation proves byte/scope consistency and
recorded authority, not the truth of a reviewer's structural judgment or the
publisher's identity. Names/network hashes pin caller-validated inputs; this
synthetic API does not independently perform their editorial review.

The output package contains `railway.sqlite`, `history.json` and `receipt.json`.
History retains exact registry snapshot bytes and complete approved records,
including captures and original attachment authority. Each boundary links to
the previous boundary digest. Runtime metadata stores only the complete manifest
hash under `identity-transitions`, not provider references or editorial evidence.
The receipt separately records registry schema conversion and hashes of both
registries, records, history and artifact. A v2→v3 conversion preserves all old
fields in the comparison view; only the approved delta changes the target.
Subsequent transitions use v3→v3. Replaying the exact applied boundary from its
output revalidates it without another registry/build/history increment.

The tool stages all three files in an owner-only sibling directory, reopens the
SQLite artifact and checks retained files, then publishes with macOS exclusive
atomic directory rename. Any failure cleans staging and preserves prior output.
A test-only pre-publication fault hook is excluded unless
`RAILWAY_STORAGE_TESTING` is defined. No installer or power-loss guarantee is
implied. Output files are mode 0600; package/staging directories are mode 0700.

Additional limits: 16 MiB per review/snapshot/history input and encoded history,
128 transition boundaries, 1,024 records per boundary, 1,024 evidence objects
and 32 dependencies per record, plus existing runtime limits. Retained evidence
is deliberately bounded and may fail the batch rather than truncate history;
this is not a general storage or delivery system. No runtime importer, successor
following, saved-reference reassignment or provider-value-reuse mechanism exists.

## Determinism and checks

`sh Tools/RailwayStorage/test.sh` compiles/runs the focused synthetic runner.
Its `--emit OUTPUT` mode only builds the fixed invented fixture into a new file.
The builder uses sorted insertion, fixed SQLite settings, a fresh database,
no persisted timestamp/path/random field, and deterministic payload encodings.
A private scratch file is validated before exclusive publication to a previously
absent output path. Prior files are never overwritten. SQLite commits use FULL
synchronous; the tests establish close/reopen durability, not power-loss-safe
artifact installation or parent-directory durability.

Tests compare complete file bytes across reordered inputs, fresh processes
(randomized Swift hashing), identical repeats and multi-revision repeats.
Byte equality is measured for the recorded SQLite/toolchain, not promised across
unmeasured SQLite releases/platforms. The canonical logical digest remains
explicit so a future engine change can be assessed without treating it as an
identity migration.

Q3/publication, Q4/new Metro-derived translation, registry-of-record/production
identity and ODPT item 5/bundling gates remain unchanged. No production minter,
provider data, physical-device interaction or app delivery is introduced.

## Measured validated repository

[Final macOS measurements](Measurement/RESULTS.md) include normal open-time
validation, both dataset sizes and an applied transition-history case. They
retain the original samples and the measured membership-validation optimization.
This evidence is separate from the earlier prototype, actual app startup and
physical-device acceptance; see the report for remaining gates and procedure.

The [final technical review](FINAL_REVIEW.md) reconciles the later Simulator and
physical evidence, exact-source coverage, commit inventory and deliverable-specific
gates. Earlier verification reports retain their historical status statements.
