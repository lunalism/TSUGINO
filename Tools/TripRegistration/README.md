# Trip registry conversion tooling

This offline, macOS-only tool implements the first DEC-084 checkpoint: strict schema-2
to schema-4 conversion, retained authority/history validation, explicit request/approval,
atomic private bundle publication and unchanged replay. Its verification uses invented
fixtures only. No real/private registry, history, GTFS, correspondence or provider artifact
was accessed during implementation. No real conversion occurred; no TripID was minted and
no Trip was registered.

The second checkpoint (first Trip mint/registration) remains unimplemented. Correspondence
approval is separate authority and is not consumed here. Private baseline/history binding,
owner review and explicit execution authorization remain required before any future real
conversion. Complete private schema-2 baseline/history/current-checkpoint binding remains
required before any real conversion-request preparation or execution. P2-S9 and P3-T1 remain
incomplete; Phase 3 remains **In Progress**. Building, testing, inspecting or preparing a
request grants no real execution authority. Publishing this source does not authorize private
conversion or registration.

## Build and invented verification

From the repository root:

```sh
sh Tools/TripRegistration/build.sh
sh Tools/TripRegistration/test.sh
```

These compile standalone binaries in the ignored `Tools/TripRegistration/.build/` directory.
The build explicitly reuses only unchanged `MintedIdentifier.swift`, `ProviderReference.swift`
and `MappingRegistry.swift` validators. It does not compile a minter, synthetic Trip code,
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
`publicationConflict`, `publicationFailure`. Exit 0 means success, 3 means held
(`approvalMissing`/`historyUnavailable`), 2 means rejection. No raw IDs, names, provider keys,
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
