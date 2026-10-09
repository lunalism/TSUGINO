# Owner-only dated timetable import adapter

This isolated macOS tool implements `importDatedOccurrenceFacts`: one already
accepted S9 Trip, one explicit service date, normalized owner-reviewed facts.
It is not a GTFS reader, acquisition tool, runtime repository or routing engine.
The implementation and tests use invented fixtures only. No real approval,
normalized input, request, facts or bundle has been materialized by this task.

Build with `sh Tools/TimetableImport/build.sh`; run the complete invented suite with
`sh Tools/TimetableImport/test.sh`. `.build/` is ignored. Build inputs reuse unchanged
production Domain values, TripRegistration private I/O/codec and the published
TripS9Assembly verifier. No DEBUG source or synthetic types enter the production
binary. The tool-local conversion implementation follows DEC-078 and DEC-085;
its separate normalized wire boundary supplies verified authority rather than the
reference converter's invented-profile guard. No app/shared production source changes.

## Authority and external dependencies

Every command requires `--owner`. JSON authority files use canonical UTF-8 JSON:
sorted keys, no insignificant whitespace, no final newline, no duplicate keys,
integer numbers only. All formats below have `schemaVersion: 1` and a `format` tag.
Unknown/missing/null fields reject; explicit optional absent evidence is held at its
semantic stage. The review itself is opaque bounded evidence bytes: its exact digest
is approved, and the importer does not reinterpret arbitrary review prose.

`tsugino.p3t1-source-profile-approval` binds ownerAuthority, profileID, reviewID,
profileReviewSHA256, reviewer, approvedAt and approvalReference. This records an
owner assertion about exact evidence bytes, not cryptographic human authentication
and not shipping approval. It is distinct from an import-request approval.

S9 stays external. All preparation, inspection, approval, application and bundle
verification require the exact authoritative S9 bundle and its manifest SHA. The
unchanged production S9 verifier replays its complete authority, including identity
history, then the adapter decodes its actual Domain Trip and exact crosswalk.
Only manifest/Trip/crosswalk SHA pins enter timetable input, request and manifest.
No S9 history bytes or private filesystem path are nested as timetable authority.
The exact source-profile review and approval are likewise external; their SHA pins
and profile/review identities are mandatory. Input fields alone cannot manufacture
these dependencies. A later real-binding task must independently review normalized
rows against those approved bytes before seeking approval of an import request.

## Normalized input

`tsugino.p3t1-import-input` contains exactly:

- ownerAuthority, inputID; `s9` with manifestSHA256/tripSHA256/crosswalkSHA256;
  `profile` with profileID/reviewID/reviewSHA256/approvalSHA256;
- `source`: archiveSHA256, revision and exact `s9Source` copied from the verified
  crosswalk (sourceID/namespace/key/inputSHA256);
- `revisions`: source/profile/zone/mapping/review tokens; explicit lowercase canonical
  UUID viewID, exact registered tripID, serviceDate, private run/service;
- profileEvidence/executionEvidence reference IDs; evidence records and dependencies;
- calendar, zone and visits, detailed below.

The explicit view binds this whole immutable input plus the exact S9/profile pins.
No view ID is derived from hashes/names. `run` must be scalar-exact to the S9 source
key. Source/profile revisions agree with their explicit bindings. Every evidence row
carries identical revisions/run/service plus id, assertion, scope and an exact
`pin: {id,sha256}`. Assertions are profileApplicable, calendarComplete, singleExecution,
multipleExecutions, unknownMultiplicity, exact, estimated, allowed or prohibited.
Scope is `{kind:wholeRun}` or `{kind:indices,first,last,selector}`; selector is arrival,
departure, boarding or alighting. Applicability is validated independently per slot.

Dependency records are sorted unique `{id,sha256,bytes,dependencyDigests}`. `bytes`
is canonical base64 opaque evidence, and dependencyDigests is a sorted pin list.
The complete reachable digest closure is checked: missing/tampered records, cycles
and unused records reject. Every supplied evidence record supplies a direct root.
Evidence assertions and owner completeness are trusted human review statements,
not proof that a source is authentic or that omitted global history does not exist.

Calendar contains coverageStart/coverageEnd, baselines, exceptions and optional mode/
completenessEvidence. A baseline has start/end and seven explicit weekday booleans
Monday through Sunday. An exception has exact service/date and action add/remove.
An empty calendar object explicitly represents unavailable evidence. Complete weekly
mode requires exactly one coherent baseline; complete exceptionOnly requires none.
A unique exception overrides the baseline within evidenced dataset coverage, including
an addition outside baseline bounds. Duplicate dates (even identical duplicates),
conflicts, foreign services, invalid actions or exceptions outside coverage fail closed.
Outside coverage is insufficient evidence. A conclusive inactive date produces no
request/facts and skips visit/event interpretation. Envelope bounds and zone validity
still apply before activation; no malformed event can salvage ambiguous activation.

Zone is `{kind:fixed,offset}` or `{kind:transitions,intervals:[{start,end,offset}]}`.
Numbers are integral Unix seconds and offsets in seconds. Tables are finite ordered,
contiguous half-open UTC intervals; offsets lie within ±14 hours. Gregorian service
years are 2000–2099. Event clocks are strict ASCII HH:MM:SS with hours 00–71 and
minutes/seconds 00–59. Conversion uses an explicit civil-day coordinate: extended
hours advance the event civil date while preserving the service-date address.
No elapsed-midnight assumption, device date/locale/timezone, hidden IANA lookup,
rollover inference, modulo wrapping, interpolation, gap adjustment or fold selection.
The exact profile must establish applicability of this conversion rule; approving a
profile does not broaden the converter's semantic capability. Gap/fold/noncoverage
are insufficient evidence; malformed syntax, contradictory rules and arithmetic range
faults are invalid. Unsupported year/hour/zone/profile contracts remain unavailable.

Each visit has originalIndex, occurrence (exact S9 crosswalk locator), mappingRevision
and optional arrival/departure/boarding/alighting slots. Active imports require exactly
one visit per accepted original index in contiguous original order. Station names and
StationIDs are never used to reconstruct indices. Events are `{state:missing}`,
`{state:exact|estimated,clock,evidence?}`, or `{state:unqualified,clock}`. Missing is
explicit; absent is insufficient. Eligibility is `{value:allowed|prohibited|unknown,
evidence?}`. Allowed/prohibited need matching independent evidence; unknown needs
no affirmative assertion. No inference from Passenger classification.

Only reviewed single execution is admissible; multiple is unsupported and unknown
is insufficient. Actual Domain visit/facts constructors validate exact bindings and
chronology. Only exact events constrain nondecreasing arrival/departure order; equality
passes, missing/estimated remain distinct. Failure holds the whole occurrence.
Fixed outcomes are active, inactive, insufficientEvidence, unsupported and invalid;
unavailable never means route-search noResults. Accepted diagnostic category/index/
event ordering and aggregate severity are preserved by the converter.

## Deterministic output and history

`tsugino.p3t1-occurrence-facts` contains address (viewID/tripID/serviceDate), exact
S9/profile pins and ordered visits. Visit fields: originalIndex, arrival, departure,
boarding, alighting. Exact/estimated events encode integer `unixSeconds`; missing has
only its state. No raw clock string enters canonical facts. Instants are bounded to
[946425600, 4102704000). Output is round-tripped through actual Domain values.
This is tool-local immutable wire authority, not a Domain persistence schema.

`tsugino.p3t1-import-state` requires ownerAuthority, exact address, historyComplete:true
and imports (zero or one). This is the owner's complete bounded inventory for that
address; no discovery or global concurrent-history exclusion is claimed. Initially
imports is empty. After application its one row retains manifestSHA256, manifestBytes
and historyBytes (canonical base64). The API `importedState` derives that exact state;
the owner retains it separately. No mutable latest pointer or auto-replacement exists.

`tsugino.p3t1-import-request` retains exact input bytes/SHA, initial state, target facts
bytes/SHA, owner/operation/address, S9/profile pins, dependencyDigests, requestID,
approvalReviewID and outputID. All workflow IDs are explicit owner inputs. Inspection
reconstructs the target from retained input and supplied external authority.
`tsugino.p3t1-import-approval` separately binds requestFormat/requestID/requestSHA256,
ownerAuthority, reviewID, reviewer, approvedAt and approvalReference.

A bundle has exactly facts.json/history.json/manifest.json. History format
`tsugino.p3t1-import-history` retains operation, owner, request and import approval;
the request retains input and complete dependency closure. Manifest format
`tsugino.p3t1-import-bundle` binds operation/outputID/address, S9/profile pins, facts/
history/request/approval SHA and dependencyRootSHA256. Full verification reconstructs
all files and requires the external S9/profile dependencies again. No SQLite output.

A duplicate initial import rejects. Exact request replay against the exact imported
state reconstructs identical bytes, adds no history/occurrence and needs no fresh
approval (the retained original approval is used). Changed input, approval, date,
source, calendar, time, eligibility, zone, profile or snapshot rejects. Replay requires
the existing identical output path/bundle; it cannot fork to an absent output.
Revision/replacement is intentionally outside this workflow.

## CLI

The following describes flags; it does not authorize any real execution.
All paths must be explicit absolute paths, each source file paired with its exact SHA.
Caller-created private parent directories must already exist.

- `approve-profile-review`: --profile-review, --profile-review-sha256, --profile-id,
  --review-id, --reviewer, --approved-at, --approval-reference, --output.
- All remaining commands require external flags: --s9-bundle, --s9-manifest-sha256,
  --profile-review, --profile-review-sha256, --profile-approval, --profile-approval-sha256.
- `prepare-import`: additionally --input/--input-sha256, --state/--state-sha256,
  --request-id, --approval-review-id, --output-id, --output. Only active writes a request.
- `inspect-import`: additionally --request/--request-sha256. Prints validity,
  approved=false and visit/event aggregate counts only.
- `approve-import`: request flags plus --reviewer, --approved-at,
  --approval-reference, --output.
- `apply-import`: request flags plus --state/--state-sha256, --output and initial
  --approval/--approval-sha256. Replay may omit approval flags to use retained approval.
- `verify-import-bundle`: additionally --bundle, --manifest-sha256.

UTC approval timestamps must be canonical ISO 8601 seconds with Z. Output/error
messages use fixed codes, digests or aggregates; never keys, clocks, private paths,
source strings, station sequences or raw errors. No command discovers/opens archives.

## Private publication and bounds

Unchanged descriptor-relative PrivateIO traversal enforces current-user ownership,
0700 parents, 0600 regular single-link files, no symlink traversal (including ancestors),
no repository aliases, stable bounded pinned reads. Bundle directory enumeration rejects
unknown or repeated entries immediately and visits at most its three expected files
plus one rejecting entry. Output uses exclusive staging,
fsync/readback, exclusive atomic rename and parent fsync, never overwrite.
Precommit failure cleans staging; postcommit uncertainty retains the complete output,
reports durabilityUncertain and must not trigger a silent retry. The owner must inspect
exact retained bytes separately before any further action. Test faults are conditional
and absent from production. Same-path races have one exclusive winner.

| Resource | Maximum |
|---|---:|
| Normalized input | 4 MiB |
| Opaque profile review | 2 MiB |
| Each approval / manifest | 16 KiB |
| Facts | 256 KiB |
| Request | 6 MiB |
| State | 12 MiB |
| History | 8 MiB |
| Whole bundle | 9 MiB |
| Dependencies / individual bytes / total decoded | 64 / 32 KiB / 1 MiB |
| Visits / exceptions / evidence / zone intervals | 256 / 256 / 64 / 8 |
| Tool JSON nesting | 32 |
| Wire token or scalar-exact source key / converter ASCII token / Domain ID | 256 / 64 / 128 UTF-8 bytes |
| Converter counted text | 64 KiB |

These conservative single-Trip limits permit explicit evidence and base64 expansion
while keeping all loops finite. External S9 uses its unchanged published bounds;
its history is verified, never copied into timetable authority. Bounds are selected
from public contract/representation needs, not private real payload measurements.
No truncation, retries, date enumeration, batches, source parsing, networking,
runtime installation, routing, Journey or realtime integration is implemented.
