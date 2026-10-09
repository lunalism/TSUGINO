# Trip registry conversion and first-registration tooling

This offline, macOS-only tool implements DEC-084 Checkpoint 1 conversion and the bounded
Checkpoint-2 identity-only first-Trip registration workflow. Checkpoint-2 implementation and
verification use **invented fixtures only**. No real/private registry, history, correspondence,
GTFS, source key, mapping or provider artifact was accessed during this implementation. No real
TripID, registration request, approval or revision 8 was created; correspondence was not consumed.

The published real Checkpoint-1 completion record remains the supplied current truth: schema 4,
revision 7, 275 active identities, 716 active references, zero Trip identities/references.
Checkpoint-2 tooling availability does not authorize real candidate preparation, approval,
execution or production/runtime adoption. Those steps require separate owner authorization and
exact private bindings. P2-S9 and P3-T1 remain incomplete; Phase 3 remains **In Progress**.
Building, testing, inspecting, preparing a request or publishing this source grants no real-use
authority. The original conversion contract below remains unchanged.

## Build and invented verification

From the repository root:

```sh
sh Tools/TripRegistration/build.sh
sh Tools/TripRegistration/test.sh
```

These compile standalone binaries in the ignored `Tools/TripRegistration/.build/` directory.
The build explicitly reuses only unchanged `MintedIdentifier.swift`, `ProviderReference.swift`
and `MappingRegistry.swift` validators. It compiles the isolated offline Trip minter, but no synthetic Trip code,
provider reader, SQLite builder or app target. Swift 5 mode, Foundation, CryptoKit and Darwin
are used; no third-party dependency is added. Module caches stay inside `.build/`.

Tests create and remove only their own fresh owner-private temporary directories. They cover
legacy field preservation, all eight non-Trip namespaces, strict codecs, complete/incomplete/
conflicting history, approval separation, deterministic bytes, stale/changed replay, bounds,
private path handling, concurrent same-path publication and injected write/rename failures.
The CLI end-to-end test prepares, inspects, explicitly approves, applies, verifies and replays
an invented conversion, checking safe visible output and predecessor immutability.

## Registry and conversion contract

The tool owns its schema-4 representation. Shared `CanonicalKind`, `MintedIdentifier`,
`ProviderNamespace`, schema-2 readers and all production consumers remain unchanged.
Schema 4 has exactly `schemaVersion`, `revision`, `entities`, `references`. It can represent
`stn`, `lin`, `opr`, `trp` identifiers and the eight accepted non-Trip namespaces plus
`gtfs.trip_id`. Identifiers are an accepted three-letter prefix, underscore and exactly
16 lowercase Crockford characters. Identity and provider-value comparisons preserve exact
UTF-8 scalars, including distinct composed/decomposed names; they do not normalize names.

Schema-4 entities and references use existing schema-2 field meanings. Entities are ordered
by ID; reference tuples by `(sourceID, namespace, value)` using exact UTF-8 ordering. Retired
non-Trip successor graphs must be valid and acyclic. A Trip reference requires attachment
authority in the schema-4 representation. This is representation validation only, not a
registration operation.

Conversion admits only an ordinary-reader-valid original schema-2 predecessor. Schema 3
is rejected; schema 4 is accepted only as the current checkpoint of exact replay. The
predecessor's original bytes and original hash remain retained even when legacy whitespace
differs from its canonical comparison view (DEC-084 legacy-byte preservation). New schema-4
registry bytes use the deterministic ordinary registry style: pretty JSON, sorted keys,
unescaped slashes, no trailing newline. All new request/history/approval/manifest/checkpoint
documents use compact JSON with sorted keys and unescaped slashes, no trailing newline.

The target is the canonical predecessor view with only schema `2 -> 4` and checked revision
`N -> N+1`. Full exact target-byte comparison enforces identical entities, references,
statuses, successors, provenance, original names and optional `attachedBy`. No allocation,
attachment, withdrawal, retirement, inference or authority rewrite occurs. Any Trip entity
or `gtfs.trip_id` in a conversion target is rejected. No random value determines registry,
history, request or approval bytes. Random temporary staging names have no authority role.

## Private wire formats, version 1

Unknown fields, duplicate decoded JSON keys, unsupported versions, invalid UTF-8, noncanonical
new documents and explicit null optional fields reject. Hashes are lowercase SHA-256 of exact
bytes; embedded byte fields are canonical base64. Tokens are bounded printable ASCII without
spaces. Times are explicit UTC `YYYY-MM-DDTHH:MM:SSZ`. No clock supplies authority timestamps.
Ordered token/inventory arrays must be strictly ascending and unique.

**Checkpoint** has `lineageID`, `schemaVersion` (2 or 4), `revision`, `registrySHA256`,
`historySHA256`. The owner supplies an exact current checkpoint and file hash. A converted
bundle manifest may supply its `target` checkpoint instead. There is no discovered current
pointer or global authority store: currentness depends on the owner's explicit pins. The
tool does not guarantee exclusion across separately chosen output paths or detect omitted
external history that an owner falsely declares complete.

**Baseline** is `{payload, approval?}`. Its payload has:

- `format: tsugino.trip-registry-baseline`, `schemaVersion: 1`, `baselineID`, `lineageID`,
  `ownerAuthority`, `registryBytes`, `registrySHA256`, `revision`;
- `legacyHistoryState: none`, `historyComplete` (Boolean), `heldIdentifiers`, `allocationIDs`,
  `reviewIDs`, `dependencyDigests`, `records`.

The root binds an owner-reviewed complete retained inventory to exact original registry bytes.
`heldIdentifiers` is exactly every active/retired canonical ID. `allocationIDs` contains original
historical allocation/request tokens; it may be explicitly empty if none originally existed.
`reviewIDs` includes all original attachment/withdrawal authority tokens and other retained
reviews. Do not fabricate replacement historical IDs or translate/re-author old approvals.
`legacyHistoryState: none` is an explicit owner-bound schema-2 premise; no schema-3 sidecar is
silently relabelled or fabricated. Existing authority records are still required.

Each record has `id`, `kind` (`allocation`, `review`, `evidence`), `sha256`, `heldIdentifiers`,
`allocationIDs`, `reviewIDs`, `dependencyDigests`, optional `bytes`. Its `id` is a distinct
retained-artifact inventory handle, **not a replacement for an original authority/request/
review ID**. Its base64 bytes retain the original opaque artifact unchanged. The owner-approved
root maps these bytes to coverage; it does not grant new historical business authority.
Allocation records cover held identities and original allocation tokens; review coverage may
be retained in allocation or review records. Evidence covers neither identities nor review
tokens. Each declared identity/token needs exactly one covering record; a token serving both
allocation and review roles must be covered by the same original record. Inventory handles,
baseline ID and approval review ID cannot collide with retained business IDs.

Each dependency row has exactly `id`, `sha256`. Root and per-record pins must agree; present
record bytes must match their digest. All dependencies must be supplied, the graph acyclic,
coverage complete and root approved. Missing bytes, coverage, dependencies or root approval,
or `historyComplete: false`, hold conversion. Known malformed/conflicting present content
rejects. Owner completeness assertions plus byte integrity are not cryptographic person
authentication or proof that undisclosed historical artifacts do not exist. A future real
binding must separately establish completeness and original authority under DEC-083/084.

**History** has `format: tsugino.trip-registry-history`, `schemaVersion: 1`, `lineageID`,
`baseline`, `baselineSHA256`, `boundaries`. Initial H0 has the approved baseline and zero
boundaries; its hash is explicit in the schema-2 checkpoint. This slice supports only H0 and
the single immutable conversion boundary, never dropping history to fit a limit. A boundary
has `operation: convertSchema2To4`, `previousRegistryBytes`, `targetRegistryBytes`,
`previousHistorySHA256`, full `request`, `requestSHA256`, full `approval`, `approvalSHA256`.
Full canonical request/approval objects remain embedded; their canonical bytes are recoverable
exactly. The previous registry retains original bytes. H0 is reconstructed from the exact
retained baseline and checked against the boundary pin. The manifest binds the complete
boundary digest externally, avoiding a self-referential history hash.

**Request** has `format: tsugino.trip-registry-conversion-request`, `schemaVersion: 1`,
`requestID`, `lineageID`, `ownerAuthority`, `operation: convertSchema2To4`, `expectedPrevious`
(full checkpoint), `targetRegistryBytes`, `targetRegistrySHA256`, `dependencyDigests`
(exact retained root inventory pins). Its SHA-256 is the digest of the whole canonical
domain-tagged request. It binds schema/revision and exact predecessor registry/history,
exact expected target bytes, lineage and dependencies. It cannot contain a registration
record, correspondence source key, TripID or snapshot choice.

**Approval** has `format: tsugino.trip-registry-approval`, `schemaVersion: 1`, `reviewID`,
`author`, `reviewer`, `role: owner`, `approvedAt`, `subjectFormat`, `subjectID`, `payloadSHA256`,
`approvalReference`. Baseline approval and conversion approval are separate. Approval binds
the complete canonical subject digest (therefore both predecessor and expected target of a
conversion request) and explicit owner authority/time. It is an integrity representation,
not a signature or person authentication. A well-formed request is never implicitly approved.

## CLI interface

The binary is `Tools/TripRegistration/.build/trip-registry-conversion`. Every flag below
is required exactly once; unknown/repeated flags reject. There are no real defaults or
filesystem discovery. All subcommands require `--owner OWNER_TOKEN`.

| Subcommand | Additional required flags | Result |
| --- | --- | --- |
| `prepare-conversion` | Context flags, `--request-id`, `--output` | Unapproved request file |
| `inspect` | `--request`, `--request-sha256` | Representation check; explicitly `approved=false` |
| `approve` | `--request`, `--request-sha256`, `--review-id`, `--author`, `--approved-at`, `--approval-reference`, `--output` | Explicit owner-action approval representation |
| `apply` | Context flags, `--request`, `--request-sha256`, `--approval`, `--approval-sha256`, `--output` | Converted private bundle or unchanged replay |
| `verify-bundle` | `--bundle`, `--manifest-sha256` | Full retained history/registry/manifest verification |

Context flags are `--registry`, `--registry-sha256`, `--history`, `--history-sha256`,
`--checkpoint`, `--checkpoint-sha256`. Paths are absolute explicit file/bundle paths; all
SHA flags pin exact bytes. `--output` names an absent request/approval file or conversion
bundle directory. Replay must name the exact existing output bundle. `approve` validates
request representation and owner binding; it does not establish complete history eligibility.
`apply` independently revalidates the complete current context, request, approval and delta.
There is no baseline fabrication/approval subcommand; the separately reviewed baseline/H0/
checkpoint must be explicitly supplied. This interface description is not a real run grant.

Successful output contains only a fixed status and digest. Failures contain fixed categories:
`malformedInput`, `unsupportedVersion`, `resourceLimit`, `identityConflict`, `historyConflict`,
`staleCheckpoint`, `approvalConflict`, `approvalMissing`, `historyUnavailable`, `unsafePath`,
`publicationConflict`, `publicationFailure`. Registration additionally uses `scopeConflict`,
`correspondenceConflict`, `correspondenceUnavailable`, `referenceConflict`,
`continuityUnavailable`, `preparationIncomplete`, `preparationConflict`, `collisionExhausted`,
`durabilityUncertain`. Exit 0 means success, 3 means held (`approvalMissing`, `historyUnavailable`,
`correspondenceUnavailable`, `continuityUnavailable`, `preparationIncomplete`,
`durabilityUncertain`), 2 means rejection. No raw IDs, names, provider keys,
paths, input JSON or stack traces are printed.

## Bundle, replay and private I/O

The authoritative bundle contains `registry.json`, `history.json`, `manifest.json`.
Manifest fields are `format: tsugino.trip-registry-conversion-bundle`, `schemaVersion: 1`,
`lineageID`, `predecessor`, `target` (full checkpoints), `requestSHA256`, `approvalSHA256`,
`boundarySHA256`. The target binds the full resulting history digest and registry digest.
All three files must verify together; SQLite is absent. Extra directory files have no authority.

Exact unchanged replay against the exact current converted checkpoint recognizes the same
request, approval, boundary, registry/history/manifest bytes and revision. It appends nothing,
does not increment again and cannot publish a new output identity. Changed/stale predecessor,
history, request, approval or target rejects. Retained IDs cannot be reused for new authority.

All inputs/outputs must be outside the repository, including inode-identical path aliases.
Descriptor-relative traversal refuses symlinks in every component, relative/dot/escape paths,
nonregular files, foreign ownership, hardlinks and wrong private modes. Immediate parents and
bundle directories must be current-user-owned mode `0700`; files must be mode `0600`.
Input byte pins and stable bounded reads are checked; inputs are never rewritten.

Publication writes an exclusive staging directory under the chosen output parent, fsyncs
files, reads back exact bytes, fsyncs the directory, then uses same-filesystem exclusive atomic
rename. An existing output is never overwritten. Same chosen-path concurrent publication has
one winner. Pre-rename failures remove staging and leave no accepted output; predecessor bytes
remain unchanged. Random staging names are not business identifiers. A parent-fsync failure
after the atomic commit reports `publicationFailure` with a complete bundle potentially already
present and durability uncertain; it cannot mean partial authoritative bytes. Verify the exact
bundle before any later replay/recovery. The tool never deletes a committed bundle on failure.

## Explicit bounds

| Resource | Maximum |
| --- | --- |
| Registry bytes | 16 MiB |
| History bytes | 64 MiB |
| Request/checkpoint/manifest bytes | 24 MiB each |
| Approval bytes | 16 KiB |
| Original retained record bytes | 4 MiB each |
| Output bundle bytes | 96 MiB total |
| Entities / references | 100,000 / 200,000 |
| Inventory records / dependency rows / authority token arrays | 4,096 each |
| Conversion boundaries | 1 |
| JSON nesting depth / ASCII token bytes | 64 / 256 |

Identifier coverage arrays may contain up to the entity limit; original-name arrays are bounded
at 4,096 per reference. Overflow fails closed. These conservative slice limits do not establish
production scalability. No app build, runtime import or physical-device validation is implied.

## Checkpoint-2 exact-target registration contract

This slice admits exactly one `registerFirstTrip` after the validated Checkpoint-1 conversion.
It checks the complete supplied approved baseline, unchanged v1 conversion history and exact
conversion manifest. The correspondence's original schema-2 revision-6 baseline is checked
through that chain; its approval is never retargeted to revision 7. The independently supplied
registration context asserts accepted scoped authority and completeness. These inputs provide
integrity and owner assertions, not provider authentication, person authentication or proof
that omitted external history does not exist. Opaque retained evidence bytes are hashed and
retained; the tool does not reinterpret their contents as identifiers or new approvals.

Preparation validates eligibility, complete dependency closure, profile/applicability, history,
source-key conflicts, all fresh authority tokens and worst-case sizes **before** claiming a
workspace and before drawing randomness. It then exclusively creates an owner-private durable
workspace, writes/fsyncs the claim and operational location receipt, fsyncs the workspace and
its parent, draws, builds exact target bytes, and atomically retains the unapproved request.
Preparation changes no registry. The candidate is an unallocated proposed label until an exact
later registration approval is applied and the resulting bundle is published.

A completed workspace returns the exact retained request/candidate without redraw. An
interrupted, failed or exhausted workspace holds for deliberate recovery/new business
authorization outside this slice; it is never automatically replaced. `claim.json`,
`location.json` and `request.json` are owner-only receipt/request files; incomplete writes may
leave `request.stage`. Do not delete/reuse a failed workspace as an automatic retry strategy.
After uncertain completion/publication, verify the exact retained request/bundle before recovery.

Authoritative workflow-location semantics contain opaque operation/workspace/output tokens, never private
path strings. A separate operational receipt binds parent device/inode and leaf names. Reusing
the retained workspace with another actual destination or changed tokens rejects. Apply also
checks this receipt and the exact retained request. There is no filesystem-wide operation
registry: choosing a new workspace with falsely reused tokens, supplying omitted history or
forking independent owner pins cannot be globally excluded. Currentness and workflow-location
binding remain explicit owner responsibilities; there is no discovery or automatic latest pointer.

The isolated production minter calls macOS `arc4random_buf` for exactly ten bytes per draw.
Those 80 bits encode as sixteen five-bit groups, most significant first, using
`0123456789abcdefghjkmnpqrstvwxyz`, with prefix `trp_`. Source keys, hashes, timestamps,
station sequences and timetable data are never minter inputs. The collision inventory is the
union of all active/retired kinds in the validated baseline and retained previous/target
registries. Bodies collide across kinds; at most eight draws are permitted. Exhaustion retains
an incomplete workspace and accepts nothing. Deterministic injection entry points exist only
under `TRIP_CONVERSION_TESTING`; there is no production CLI seed, injection or failure flag.

The exact source key is compared as scoped source ID/namespace/value UTF-8 scalars, without
normalization or trimming. A bound active key rejects another allocation; wrong-kind or retired
bindings reject; unsupported absent/returning continuity holds. No returning-reference workflow
is implemented. Only one active Trip entity and one active `gtfs.trip_id` reference are added;
schema stays 4, revision increases by exactly one. All existing canonical record encodings
remain identical. The reference has exact GTFS input/member SHA-256 provenance for `trips.txt`,
table `trips`, field `trip_id`, exact provider key, no ODPT index and empty `originalNames`.
Its permanent non-null `attachedBy` is the request's prebound future approval review ID.

There is no retirement, successor, withdrawal, rebind, second key, timetable, snapshot acceptance,
S9 completion or runtime import. The six original downstream prerequisites remain unresolved.

## Registration wire formats

All new registration formats are strict canonical compact JSON; registry bytes use the existing
pretty style. Unknown/missing fields, duplicate decoded keys, null optionals, noninteger numeric
syntax, unsupported versions and malformed values reject. Embedded original correspondence and
predecessor-v1 bytes preserve their exact original representation and SHA-256.

**Registration context**, format `tsugino.trip-registry-registration-context`, schema 1:

- `ownerAuthority`, full `expectedPrevious` checkpoint, `predecessorManifestSHA256`;
- `workflow`: seven distinct fresh tokens `requestID`, `recordID`, `allocationID`,
  `approvalReviewID`, `operationID`, `workspaceID`, `outputID`;
- `correspondenceContext`: exact published Python v1 context (owner, source/profile/input,
  original baseline, mapping/version/digest, six required evidence roles and optional `s9Review`);
- `correspondence`: `requestID`, `proposalSHA256`, `approvedContentSHA256`, `recordSHA256`;
- `profileAcceptance`: `profileID`, `version`, `disposition: accepted`;
- `applicability`: `evidenceID`, `sha256`, `disposition: eligible`;
- exact `provenance` (`inputSHA256`, `member: {name, sha256}`, `table`, `field`, `providerKey`),
  `provenanceEvidenceID`, ordered `dependencyDigests`, `scope: identityOnlyOneTripOneReference`.

**Dependencies** are an ordered array of `{id, sha256, dependencyDigests, bytes?}`. Context pins
must cover exactly the reachable evidence/mapping/provenance closure. Every byte record must
exist, match its digest, stay bounded and form an acyclic graph. Missing records/bytes hold;
known mismatches reject. Quoted retained historical handles must retain the same bytes/digest
and dependency pins. Fresh evidence/dependency handles cannot repurpose historical business,
review, allocation, baseline or canonical IDs. Existing correspondence business identity may be
quoted only through its exact original retained record handle or explicit allocation/review
coverage and identical full correspondence bytes/digest. A correspondence/dependency ID alias
also requires identical complete bytes/digest. Opaque records are never mined for identity.
Workflow tokens cannot reuse complete historical authority or supplied evidence/dependency IDs.

**Registration request**, format `tsugino.trip-registry-registration-request`, schema 1,
contains exactly `operation: registerFirstTrip`, `requestID`, `lineageID`, `ownerAuthority`,
`expectedPrevious`, full `context`, `proposedTripID`, `targetRegistryBytes`,
`targetRegistrySHA256`, the one exact `reference`, complete original `correspondenceBytes`,
`dependencies`, and `preparation`. Preparation accounting has
`algorithm: osCSPRNG80Crockford-v1`, `drawCount` (1–8), `heldBodyInventorySHA256`.
Accounting binds the inventory/attempt count but is not cryptographic proof of random generation.
Application reconstructs the permitted target from the exact predecessor and compares full bytes.

**Correspondence adapter** consumes only the published approved
`tsugino.trip-correspondence-request` v1 `distinctNewRun` contract. It reproduces Python canonical
Unicode/escaping/order and distinct proposal/approved-content digest domains. Complete original
record SHA-256 is a third separate pin. Original prior-binding/competitor dispositions, reasoning,
profile/evidence and unresolved prerequisites are preserved. Correspondence approval authorizes
no registry mutation. `Tests/generate_golden.py` independently checks five committed invented
Swift constants against the unchanged published Python codec, including scalar-distinct Unicode,
controls, slash, supplementary-plane and separator characters; tests do not regenerate constants.

**Registration approval** reuses `tsugino.trip-registry-approval` schema 1 with exact request
format/ID/canonical digest, author, owner reviewer/role, explicit UTC time and approval reference.
Its review ID must equal the prebound intended review ID. Correspondence approval, allocation ID,
request ID and registration-record ID cannot substitute for permanent attachment authority.
Approval CLI validates representation; apply independently validates complete eligibility/history.

**History v2** retains the history format `tsugino.trip-registry-history` with `schemaVersion: 2`,
`lineageID`, entire exact `predecessorHistoryBytes`, `predecessorHistorySHA256`, and exactly one
new `boundaries` element. The predecessor is validated by the unchanged history-v1 logic and
must contain exactly one conversion whose latest registry is the registration predecessor.
Nested v2, arbitrary schema-4 seeds, rewritten/dropped history and second registration boundaries
reject. There are exactly two logical boundaries: retained conversion plus first registration.

The registration boundary has exactly `operation: registerFirstTrip`, `previousRegistryBytes`,
`targetRegistryBytes`, `previousHistorySHA256`, full `request`, `requestSHA256`, full `approval`,
`approvalSHA256`. Proposed identity, permanent authority, source key and preparation accounting
are derived from the validated retained request/target, not duplicated authority fields.

**Registration manifest**, format `tsugino.trip-registry-registration-bundle`, schema 1,
contains `operation`, `lineageID`, full `predecessor` and `target` checkpoints,
`predecessorManifestSHA256`, `requestSHA256`, `approvalSHA256`, `boundarySHA256`.
The target history digest is computed after encoding v2. Authoritative file names remain
`registry.json`, `history.json`, `manifest.json`; there is no SQLite output.

## Registration commands and replay

The existing binary name and all conversion commands above remain supported. Each flag is
required exactly once. Registration commands require `--owner` and explicit pinned private
files; there are no real defaults. This interface is a tooling description, not a run grant.

Registration **context flags** are `--registry`, `--history`, `--checkpoint`, `--context`,
`--correspondence`, `--dependencies`, each with its matching `--NAME-sha256` flag. Here
`--checkpoint` is the complete exact predecessor conversion manifest, or resulting registration
manifest for exact apply replay. `--context` is the independent registration context.
**Location flags** are `--workspace`, `--operation-id`, `--workspace-id`, `--output-id`, `--output`.
`--workspace`/`--output` are explicit owner-private absolute directory paths; the three ID flags
must match context tokens. `--output` is the intended bundle destination, including during prepare.
**Request flags** are `--request`, `--request-sha256`.

| Command | Required flags beyond `--owner` | Behavior |
| --- | --- | --- |
| `prepare-registration` | Context + location flags | Durable preparation or exact completed-preparation replay; `approved=false`, safe request digest |
| `inspect-registration` | Context + request flags | Complete predecessor/request eligibility check; `approved=false`; no RNG |
| `approve-registration` | Request flags + `--review-id`, `--author`, `--approved-at`, `--approval-reference`, `--output` | Exact separate approval file; no RNG |
| `apply-registration` | Context + location + request flags + `--approval`, `--approval-sha256` | RNG-free checked first application/atomic bundle or exact existing replay |
| `verify-registration-bundle` | `--bundle`, `--manifest-sha256` | Complete registry/v2/manifest verification; no RNG |

The prepare result is retained at the supplied workspace's `request.json`. Later approval uses
that exact pinned file; apply requires the unchanged durable workspace/location receipts too.
Inspect is a predecessor eligibility check, not an approval or a current-registration replay
command. For apply replay, supply the resulting registry/history/manifest plus the original
context, request, dependencies, correspondence, approval and exact locations. Verification of
that complete closure returns identical bytes/revision/history with no RNG, append, increment,
new identity or alternate output copy. Altered request/approval/dependencies and later checkpoints
reject. A fresh allocation attempt reusing consumed correspondence identity **or** approved-content
digest rejects through validated v2 history. Exact historical replay is allowed and does not
edit/delete correspondence.

Registration uses the same descriptor-relative no-symlink private I/O and exclusive atomic
publication as conversion. Ancestors must be root/current-user-owned and not group/other writable,
except root-owned sticky shared ancestors; immediate parents/workspaces/bundles are owner `0700`,
regular single-link files `0600`. Repository paths/aliases and `.git` traversal reject. Complete
staging is fsynced/read back before exclusive rename. Precommit failure accepts nothing;
post-rename parent-fsync failure holds `durabilityUncertain` with a possibly complete bundle.
Verify that exact bundle and use exact retained replay for recovery; never automatically redraw.
Conversion retains its original failure behavior. Diagnostics contain fixed statuses and safe
SHA-256 only; caller-controlled secrets/paths/exceptions never print.

Registration additionally bounds correspondence/context at **256 KiB** (Python correspondence
depth **32**, integer lexemes **16** characters), unique decoded retained dependency bytes at
**64 MiB**, and mint draws at **8**. Other table limits above apply unchanged. Worst-case request,
v2 history and bundle sizes include base64 expansion and maximum approval overhead before RNG;
actual encodings are checked again. No valid history is truncated to satisfy limits.

The complete invented suite covers all 22 requested base cases, strict malformed inputs, Unicode,
exact byte preservation, closure, replay, interrupted/exhausted preparation, operational destination
conflicts, no-RNG gates, production-hook exclusion, publication races/failures and uncertain-durability
verification. An invented predecessor above **10 MiB** validates within the v2 64 MiB envelope.
Historical inventory testing includes a reduced current projection missing a retired historical
ID; that projection is explicitly not an admitted checkpoint, and a separate eligibility test
rejects deleting historical IDs. This preserves conversion's exact-record contract while testing
that mint collision protection uses history rather than a reduced projection alone.

Implementation verification (2026-10-09): standalone build passed; one final complete run passed
**18 functions / 359 cases, zero failures/skips/warnings**, including unchanged Checkpoint-1
**8 functions / 142 cases**. Python golden checks passed separately within that same script.
Separate non-author implementation review passed all **20 requested criteria**, with no
unresolved material findings. The reviewer independently rebuilt the standalone production tool
and reran the complete suite: **18 functions / 359 cases, zero failures/skips/warnings**,
plus the published-Python five-constant golden check. These are separate complete runs, not
cumulative totals. The final implementation remains unstaged/uncommitted for owner review;
source publication and every real/private preparation/approval/execution step remain separately gated.
