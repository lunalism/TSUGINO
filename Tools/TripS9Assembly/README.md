# Owner-only untimed Trip snapshot assembly

Standalone macOS tooling for exactly `selectInitialUntimedTripSnapshot`: one already
registered Trip, explicit reviewed occurrences and movements, an unapproved request,
a separate exact owner approval, and an immutable four-file S9 bundle. This is Data
preparation tooling outside the app. It neither discovers nor parses GTFS, interprets
timetables, allocates identities, mutates the registry, nor configures runtime routing.
Known service types, revisions, replacements, withdrawal, merge/split and multiple-Trip
requests are outside this bounded adapter. Service type must explicitly be `unknown`.

Implementation validation uses invented fixtures only. Real input binding, source access,
request preparation, digest review, approval and application each remain separately gated.
Successful tool tests do not accept any real S9 snapshot or start P3-T1.

## Build and test

From the repository root:

```sh
sh Tools/TripS9Assembly/build.sh
sh Tools/TripS9Assembly/test.sh
```

Production compiles unchanged Domain identifier, Trip, line-segment, coverage and service
segment sources. It compiles unchanged TripRegistration sources and Mapping support to
verify the entire supplied schema-4 registered checkpoint, including the accepted
conversion/registration history and its approvals. Its entry point dispatches only S9
commands. Identity-mutating commands and allocators are never invoked by S9. Generic
`Codec` and descriptor-relative `PrivateIO` primitives are reused unchanged. DEBUG
synthetic sources are not compiled into this binary. Test-only publication fault hooks
are absent from production. Existing invented registration fixture builders are compiled
only into the test executable.

## Wire conventions

Every S9 document is UTF-8 canonical JSON with `format` and integer `schemaVersion: 1`.
Keys are sorted; slashes are not escaped; no pretty printing, trailing newline, BOM or
extra whitespace. Duplicate decoded keys, unknown/missing/null fields, unsupported
versions and noncanonical bytes reject. Optional fields, when present, cannot be null.
Opaque byte fields use canonical nonempty base64. Tokens are printable ASCII without
spaces, at most 256 UTF-8 bytes. SHA-256 is lowercase hexadecimal. Source keys retain
exact Unicode scalars (nonempty, at most 256 bytes); no normalization is performed.
Canonical registered IDs use the accepted schema-4 kind/prefix/body rules. Digest checks
establish byte integrity, not publisher authenticity or human authentication.

A **pin** is `{id, sha256}`. Lists of pins and dependency records sort strictly by ID
UTF-8 bytes. A **checkpoint** has `lineageID, schemaVersion, revision, registrySHA256,
historySHA256, manifestSHA256`. Here checkpoint schema is 4; revision is a nonnegative
integer. The exact checkpoint bytes must pass unchanged `Registration.verify`.

## Normalized input and crosswalk

`tsugino.p2s9-assembly-input` contains exactly:

| Field | Meaning |
|---|---|
| `ownerAuthority`, `inputID` | Explicit owner and assembly input tokens |
| `registeredCheckpoint`, `registeredTripID` | Exact already registered active Trip |
| `registeredBundle` | `registryBytes, historyBytes, manifestBytes`, each exact base64 |
| `source` | `sourceID, namespace, key, inputSHA256`; namespace exactly `gtfs.trip_id` |
| `views` | Pins `sourceRevision, profileRevision, mappingRevision, reviewRevision` |
| `movementReview`, `intervalEvidence` | Exact retained evidence pins |
| `occurrences`, `movements` | Explicit reviewed facts, described below |
| `continuity` | `disposition` (`notApplicable` or `proved`) and `evidence` pin |
| `origin`, `destination` | Independent endpoint dispositions |
| `serviceType` | Exactly `unknown` |
| `dependencies` | Complete retained record closure |

The Trip must exist, be active and have kind Trip in this exact registry. The source
tuple must match its active reference, including the exact scalar key and input digest.
Source/profile/mapping/review revisions are owner-bound evidence views, not inferred
from station lists or a source hash.

An occurrence requires `locator, order, disposition, classificationEvidence`.
Order is a nonnegative integer; all orders and locators must be unique. Transport array
order is irrelevant: reconstruction sorts by explicit source order. Passenger occurrences
add exactly `stationID, originalIndex, mappingEvidence, membership`. Passenger indices
must be contiguous 0…N−1 and agree with source order. A membership row has `lineID,
evidence`; membership rows sort strictly by LineID. Passenger StationIDs and membership
LineIDs must be active in the registered registry. Every movement's passenger occurrences
must have positive membership for that LineID. Passed rows have disposition `passed` and
none of those four passenger-only fields. Unknown classification holds. Nonadjacent
repeated StationIDs survive at separate indices; adjacent repeats fail Domain construction.

A movement has `from, to, lineID, evidence`. Endpoints name real occurrence locators.
Ordered spans must fully cover the represented source interval without gaps or overlaps
beyond a shared endpoint. A span can cover multiple consecutive passenger pairs. Adjacent
same-Line spans normalize, including joins through a passed occurrence. A Line change at
a passed occurrence rejects with fixed `representationConflict`; the adapter never moves
the boundary, invents a stop, crops coverage, or picks one Line. Multiline traversal
requires affirmative `proved` continuity. `notApplicable` is an explicit owner-reviewed
single-line disposition and still requires retained continuity evidence.

Endpoints have `disposition` and optional `evidence`. `reached` requires evidence and maps
to true; `continued` requires evidence and maps to false; `unknownExtent` maps to false.
Their private distinction remains in the retained input. Service `unknown` constructs
`serviceTypeSegments = []`; known service is rejected, never silently discarded.

`trip.json` uses actual Domain constructors and Codable with sorted keys/no slash escaping.
The tool decodes and re-encodes it identically. All comparisons use complete bytes rather
than Trip's ID-only equality. `tsugino.p2s9-crosswalk` binds `registeredCheckpoint, tripID,
snapshotArtifactID, source, views, occurrences`. It retains all sorted occurrence fields,
including mapping/classification/membership evidence, and preserves passed rows without
passenger indices. Crosswalk and Trip bytes are deterministic across transport order.

## Dependency closure

Each dependency record contains exactly `id, sha256, bytes, dependencyDigests`. Every root
used by views, movement review, interval, continuity, classification, station mapping,
membership, movements and endpoints must resolve to matching retained bytes. All child
pins must resolve; cycles and unused records reject. The full transitive sorted pin list
is retained in context/request/history. Equal byte digests count once against the unique
decoded-byte bound. Opaque evidence bytes are never interpreted as railway facts.

## Context, request and approval

`tsugino.p2s9-assembly-context` contains exactly `ownerAuthority, operation,
registeredCheckpoint, inputSHA256, movementReviewSHA256, snapshotArtifactID, requestID,
approvalReviewID, outputID, dependencyDigests, selectionStateSHA256, initialSelection,
noPreviousSnapshot`. Operation is the one supported operation and both flags must be true.
The four workflow IDs are explicit, pairwise distinct, and cannot reuse registered/retained
identity authority, input/evidence IDs or supplied retained S9 authority IDs. Artifact ID
is distinct from TripID and is never derived from the Trip digest.

`tsugino.p2s9-snapshot-request` contains exactly `requestID, ownerAuthority, operation,
context, inputBytes, inputSHA256, selectionState, tripBytes, tripSHA256, crosswalkBytes,
crosswalkSHA256, snapshotArtifactID, registeredTripID, registeredCheckpoint,
dependencyDigests, initialSelection, noPreviousSnapshot`. It retains the complete input
including registry and dependency bytes. Preparation and inspection reconstruct the full
Trip and crosswalk and compare exact bytes; both report `approved=false`.

`tsugino.p2s9-snapshot-approval` is separate from identity approval. Fields are exactly
`requestFormat, requestID, requestSHA256, ownerAuthority, reviewID, reviewer, approvedAt,
approvalReference`. `reviewID` must equal the context's approval-review token. Approval
binds the complete canonical request digest, with an explicit reviewer, reference and UTC
timestamp in `YYYY-MM-DDTHH:MM:SSZ` form. Approval is an owner-mediated action; a string
matching `ownerAuthority` is not cryptographic authentication.

## Initial selection, retained history and replay

`tsugino.p2s9-selection-state` is the owner's explicit complete S9 history inventory for
this one Trip. Fields: `ownerAuthority, tripID, historyComplete, retainedAuthorityIDs,
selections`. `historyComplete` must be true; retained authority IDs are strictly sorted
unique tokens. A fresh initial selection requires an empty selections array. This tool
cannot discover external omitted history: the owner must supply the complete inventory
and preserve it with the bundle. It does not maintain a hidden currentness pointer.

A selected state has one row with `tripID, snapshotArtifactID, manifestSHA256,
historyBytes, manifestBytes`. These retain full S9 history, not dangling digest labels.
The exact selected row is deterministically obtained from the published bundle plus the
original state's retained authority inventory; see `S9.selectedState`. It is supplied
explicitly for apply replay, never auto-discovered or silently rewritten. Preparing a
second initial selection rejects. Applying with selected state accepts only an exact
request/approval/history/manifest/inventory replay and publishes no new bytes/history.
The simplest replay is `verify-snapshot-bundle`, requiring no separate fresh approval.
Changed input, views, evidence, checkpoint, request or approval cannot silently rebind a
selected state. Revisions require a future explicit workflow.

`tsugino.p2s9-snapshot-history` contains exactly `operation, ownerAuthority,
registeredCheckpoint, tripID, snapshotArtifactID, tripSHA256, crosswalkSHA256, request,
requestSHA256, approval, approvalSHA256, dependencyDigests, initialSelection,
noPreviousSnapshot, downstreamRevalidation`. It retains the entire exact request and
approval; their input retains the full closure. No predecessor snapshot is fabricated.
It remains separate from the identity-registry history, which is retained unchanged.

The four authoritative bundle files are `trip.json, crosswalk.json, history.json,
manifest.json`. No additional input file is necessary because history retains request
and its complete input bytes. Manifest format `tsugino.p2s9-snapshot-bundle` contains
exactly `operation, registeredCheckpoint, tripID, snapshotArtifactID, tripSHA256,
crosswalkSHA256, historySHA256, requestSHA256, approvalSHA256, dependencyRootSHA256`.
Verification independently reconstructs Trip/crosswalk from retained input, verifies
registered history/approval/closure, and compares every bundle file exactly. Extra files
reject. Downstream obligations explicitly retain `datedTimetableFacts,
originalIndexAssociations, rideContexts, continuityEligibility, dataViewBindings` for
future consumers to revalidate; they do not implement timetable/runtime behavior.

## CLI and private files

Every command requires `--owner TOKEN`. Every input document requires both `--NAME
/absolute/path` and `--NAME-sha256 DIGEST`. No command opens an archive or evidence path
embedded in a payload; all authority bytes are supplied in normalized input.

| Command | Additional exact options |
|---|---|
| `prepare-snapshot` | `--input`, `--context`, `--state`, their SHA options, `--output` |
| `inspect-snapshot` | `--request` and SHA option |
| `approve-snapshot` | `--request` and SHA option, `--reviewer`, `--approved-at`, `--approval-reference`, `--output` |
| `apply-snapshot` | `--request`, `--approval`, `--state`, their SHA options, `--output` (bundle directory) |
| `verify-snapshot-bundle` | `--bundle`, `--manifest-sha256` |

Caller-created private parent directories must have mode 0700; files must be regular,
owner-owned mode 0600 with one hard link. Traversal uses directory descriptors and
no-follow flags for every ancestor/leaf. Repository paths and aliases traversing its
inode reject; symlinks, relative paths, dot components and writable unsafe ancestors
reject. Reads are bounded, descriptor-stable and SHA-pinned. Outputs are exclusively
created, fsynced and read back, then atomically renamed with no replacement on the same
parent volume. Complete bundle publication occurs only after all four files are durable.
Existing destinations reject. A failure after rename is `durabilityUncertain`; preserve
the destination and independently verify its exact manifest digest before any further
action. Never silently retry uncertain publication. Replay verifies the existing bundle.

CLI output is fixed status plus SHA digests and safe aggregate counts only. Failures
never print IDs, locators, source keys, private paths, raw payloads or exception messages.

## Resource limits

Bounds reject; none truncate. Encoded limits include base64 expansion and retained
identity history; the smaller enclosing bound also applies.

| Resource | Maximum |
|---|---:|
| Normalized input | 24 MiB |
| Individual decoded dependency | 2 MiB |
| Unique decoded dependency bytes | 16 MiB |
| Trip / crosswalk | 512 KiB / 4 MiB |
| Context / request | 1 MiB / 40 MiB |
| Approval / manifest | 16 KiB each |
| Selection state / S9 history | 48 MiB each |
| Whole bundle | 56 MiB |
| Occurrences / movements | 2048 / 4096 |
| Dependency records, child pins, per-stop memberships | 256 each |
| JSON nesting / token or source-key bytes | 64 / 256 |
| Selected snapshots for this Trip | 1 |
| Retained authority tokens | 4096 |

The unchanged identity verifier additionally enforces its existing registry/history,
record, inventory and nesting limits. This adapter's enclosing input bound can hold a
smaller checkpoint than those maxima. Increasing any bound is a separately reviewed
implementation change, not an automatic fallback for a rejected real input.
