# Trip nomination and untimed occurrence tooling

The [memory-only occurrence inspection interface](#memory-only-occurrence-inspection)
adds synthetic-tested private inspection and gap annotations. Its independent review status
is recorded below; no real review execution is authorized by tooling approval.

The separately authorized [untimed occurrence extractor](#untimed-occurrence-extractor)
is independently approved for bounded tooling readiness — 2026-10-03 Asia/Seoul.
See the [extractor approval record](../../docs/ROADMAP.md#untimed-occurrence-tooling-independent-approval-and-publication--2026-10-03-asiaseoul).
The earlier approval below covers the nomination reader/workflow separately.

Standalone offline Python 3.9+ standard-library tooling for the bounded owner-nomination
step before real P2-S9 review. No app target, production composition, Swift reader change,
networking, allocation, registry operation, manifest writer or general importer.

**Independently approved for bounded tooling readiness — 2026-10-03 Asia/Seoul.**
The non-author reader review identified the missing private selection interface; a fresh
non-author review subsequently approved the terminal workflow with no material findings or
mandatory corrective checks. **A separate real-input execution grant remains required.**
At that review, neither had been executed on the real archive. See
[readiness](../../docs/P2_S9_REAL_READINESS.md), the
[reader record](../../docs/ROADMAP.md#trips-only-nomination-reader--2026-10-03-asiaseoul) and
[workflow record](../../docs/ROADMAP.md#private-owner-nomination-terminal-workflow--2026-10-03-asiaseoul) and
[approval record](../../docs/ROADMAP.md#nomination-tooling-independent-approval-and-publication--2026-10-03-asiaseoul).
Nomination is neither recurring-Trip identity nor passenger classification/S9 acceptance.

## Private inspect/select workflow

From the repository root, using an explicitly authorized absolute archive path and its
independently supplied byte count and lowercase SHA-256:

```sh
python3 -B Tools/TripNomination/session.py \
  --archive "$ARCHIVE_PATH" \
  --expected-size "$ARCHIVE_BYTES" \
  --expected-sha256 "$ARCHIVE_SHA256"
```

These variables are placeholders, not discovery instructions. No default archive, directory
search or automatic symlink resolution is provided. Every path component must be explicit,
non-symlink, and free of empty/`.`/`..` components. On macOS `/tmp` is commonly a symlink;
the owner must supply an actual non-symlink path instead. Do not paste private paths or
identifiers into public documentation. Do not run this example on real data yet.

Use an **unrecorded local interactive terminal**. Standard input, output and error must all
refer to the same foreground character terminal; pipes, redirection, background execution,
noncanonical terminal input and detected SSH sessions are refused **before archive access**.
Do not use `tee`, `script`, remote/screen-recorded terminals or terminal session logging.
The tool checks terminal descriptors/foreground state and common SSH indicators; it cannot
detect arbitrary terminal capture or prove locality against a disguised remote terminal.

After the unchanged reader has validated the complete input, the session displays the first
zero to ten choices in source order. Each preview shows only its `N01`–`N10` label and the
exact source `trip_id`, `route_id`, `service_id`, using **ASCII JSON escaping**. Quotes,
backslashes, Unicode scalars (including Japanese/Korean), controls, bidi characters and
terminal escapes are rendered as inert escaped text. Nothing is normalized or replaced in
memory. Other columns, including names/headsigns, are not displayed. The ordinal labels
distinguish duplicate source records too; no duplicate is removed or substituted.

Commands are exact, case-sensitive, one per line. Input echo is disabled while the session
is active, and terminal settings are restored on normal exit or handled failure/interruption.

| Command | Effect |
|---|---|
| `N01` through the last available label | Show the candidate identifiers and make that original candidate pending. No automatic confirmation. |
| `confirm` | Retain the pending original candidate and exact locator in the live session; show both. Without a pending label, select nothing. |
| `inspect` | Show the confirmed candidate's identifiers and all seven exact locator fields. Without confirmation, show no selection. |
| `list` | Redisplay the original ordered previews; leave selection unchanged. |
| `cancel`, `exit`, EOF (Ctrl-D on an empty line), or Ctrl-C | End the session, retaining nothing outside the process. |

An invalid command/label clears a pending choice and leaves any already confirmed choice
unchanged; a subsequent `confirm` cannot silently select the old pending label. Choosing
another valid label leaves the existing confirmed choice intact until a new `confirm`.
Commands are bounded to 32 ASCII bytes including newline; overlong, incomplete or non-ASCII
input is invalid, never interpreted as a truncated label. A header-only input has no choices.
Any validation failure displays no candidates, only a fixed error code.

**Selection is lost when the session ends.** Keep the session open to inspect/confirm the
chosen locator. There is no export, file, log, clipboard, server, network or persistence
feature; no private object is returned after exit. The terminal wrapper rechecks its terminal
boundary before private writes and uses a duplicate terminal descriptor rather than a
redirectable stdout stream. This is not secure-memory erasure or protection against terminal
scrollback/capture, OS swap or process inspection. `-B` prevents Python bytecode cache files.
The workflow does not interpret stops, times, calendars, mappings, identity or classification.

## Reader API and counts-only check

The original `nomination.py` command accepts the same arguments as above. It is a counts-only
integrity/readability check, **not an inspect/select interface**:

The CLI returns 0 and prints **only** `nomination records available: <count>; private values
not printed`, or returns 1 with one fixed error code on stderr. It does not display or
save labels, source fields, locators or hashes. There is no output-path/JSON/export option.
It therefore checks readiness but does not by itself present a private choice worksheet.

An authorized local caller can obtain the private immutable result in memory:

```python
from nomination import read_nominations

batch = read_nominations(archive_path, expected_size, expected_sha256)
# batch.columns: exact decoded header fields
# batch.nominations: zero to ten Nomination values, in source order
# each item: label, values (tuple aligned with columns), locator
# Keep these objects local and in memory. Do not print, log or serialize them.
```

For importing, put `Tools/TripNomination` on the caller's Python module path and use `-B`
(or `PYTHONDONTWRITEBYTECODE=1`). Representations of result objects hide their fields;
direct access is intentionally available to a separately authorized private caller.
The reader itself writes no input, extracted data, manifest, nomination output or logs.
Test logs contain invented
inputs only. The terminal session is the sole presentation path; there is no browser or server.

## Exact selection and locator contract

- One opened regular-file descriptor is used for initial hash, ZIP metadata and selected
  member reads, and final hash. Traversal is descriptor-relative with `O_NOFOLLOW`, including
  ancestors. Before returning, the reader checks the file's state and its current pathname
  identity again. Unbuffered reads ensure the final hash does not reuse cached bytes.
- Expected size/hash must match **before** ZIP member content is decoded. Whole-archive
  hashing necessarily reads opaque compressed bytes of every member; it does not open or
  interpret other member contents. ZIP directory/header reads are metadata only.
- The central directory must have unique safe root-level names and exactly one `trips.txt`.
  Names follow the existing intake pattern `[A-Za-z0-9][A-Za-z0-9._-]*`, at most 255 ASCII
  bytes. Directories, links, traversal, NUL names and nested members fail. No case folding.
- Only `trips.txt` is decompressed. Its local/central metadata must agree. Supported selected
  methods are stored and deflate, unencrypted, ordinary ZIP version at most 2.0, with or
  without a checked 32-bit data descriptor. ZIP64, multi-disk envelopes and other selected
  compression/encryption extensions are unsupported. CRC and actual decompressed length
  are checked independently of the declared length, including excess/truncated deflate
  data. Integrity of unselected payloads is deliberately not checked or claimed.
- CSV is strict UTF-8, with an optional single initial BOM. Record terminators are LF or
  CRLF; bare CR outside quotes, malformed UTF-8, NUL, unescaped quotes and text following
  a closing quote fail. Quoted commas, doubled quotes, CR/LF within quotes, and a final
  record without a terminator are supported. No Unicode normalization or trimming.
- The header has unique nonempty fields and includes exact `trip_id`, `route_id`, `service_id`.
  Every data record has the same field count and nonempty values for those three columns.
  Other columns are preserved as uninterpreted text. No service/calendar or route lookup,
  time interpretation, source-key uniqueness inference or recurring identity claim occurs.
- Validate the entire bounded `trips.txt`; even a malformed record after the first ten
  fails the operation. Blank/problematic records are never skipped. Header-only input gives
  zero choices. Preserve duplicate rows/identifiers. Return only the first ten records as
  `N01`–`N10`, without sorting, deduplication, ranking, filtering or replacement.
- Each private locator contains archive SHA-256, `trips.txt`, complete uncompressed member
  SHA-256, zero-based **data-record** ordinal, `byte_start`, `byte_end`, and record SHA-256.
  The half-open span `[byte_start, byte_end)` indexes the original uncompressed member bytes.
  It includes quotes, escaped quotes, commas, embedded newlines and **all bytes of its LF or
  CRLF terminator**, if present. It excludes the previous record's terminator. The final
  unterminated record ends at EOF. Header and optional BOM precede ordinal zero; offsets
  still count their bytes. No physical-line number substitutes for the CSV record ordinal.
- Hashes establish byte identity, not authenticity, currency, continuity, current operation
  or S9 acceptance. Labels are local to one identified result, never canonical Trip IDs.
  Any failure returns no batch and no partial CLI output.

## Fixed limits

| Resource | Limit |
|---|---:|
| Archive | 16 MiB |
| Central directory | 1 MiB, 1,024 entries (checked before ZipInfo allocation) |
| ZIP end-record scan | 65,557 bytes |
| ZIP name | 255 ASCII bytes |
| Selected local extra metadata | At most 65,535 bytes (ZIP length field); structurally checked |
| Decompressed `trips.txt` | 2 MiB, checked while inflating |
| Raw encoded CSV field | 64 KiB, including quotes/escapes, excluding delimiter |
| Raw CSV record | 256 KiB, including terminator, excluding initial BOM |
| Columns | 64 |
| Data records checked | 100,000 |
| Returned records | 10 |
| Hash/compressed read chunk | 64 KiB |

These are tooling bounds, not feed semantics. There are no command-line overrides or
automatic retries with larger limits. Unsupported input requires a separately reviewed
scope change. Operations are bounded by byte/count limits, not a wall-clock deadline for
an unavailable or stalled local volume. Nothing is authenticated by passing the reader.

## Synthetic verification and independent handoff

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_*.py' -v
```

Fixtures are generated in a temporary directory and removed after each test. No real
artifact is a fixture. Tests cover exact source order/spans, CSV quoting/Unicode, boundaries,
duplicate/unsafe members, corrupt streams/CRC/descriptors, incomplete directory metadata,
resource limits, pre-read identity failure, mutation/replacement/symlink races, private errors,
unchanged input bytes/modes and absence of output files. Instrumentation verifies the same
archive descriptor and selected-only payload reads; a deliberately corrupt unselected member
must remain unread. `-W error` fails on unexpected warnings; duplicate-ZIP fixture construction
locally suppresses only the expected writer warning.

The combined final run has **54 test functions (35 unchanged reader + 19 workflow)**, zero
failures/errors/skips and no unexpected Python warnings. Workflow assertions check exact
original-object/locator correspondence (independent byte-span/hash expectations), confirmation,
invalid labels, cancellation/EOF/interruption, zero choices, validation failure without exposure,
scalar-preserving safe display, terminal/redirection/SSH guards, terminal setting restoration
and descriptor cleanup, and no files/logging/networking.
Actual CLI execution uses invented archives in controlling pseudo-terminals; tests capture
only invented output in memory. No real run is nominated. See ROADMAP for the saved command/log.

**Completed independent-review scope (retained for future changes):** review `session.py`, `test_session.py`, this README
and the workflow ROADMAP record. Verify the original `nomination.py` and `test_nomination.py`
hashes still match the reader review. Trace terminal qualification before archive access,
validation before any private display, exact label-to-original-object retention, pending versus
confirmed state, invalid/cancel/EOF paths, escaped identifiers/locators, terminal restoration
and no writes/logs/network. Inspect actual PTY and negative assertions, not just test names.
Confirm the documented invocation genuinely supports private inspection/selection and retains
the chosen locator only while the session is open. Reuse saved evidence unless a concrete gap
requires focused synthetic verification; do not execute on real input. This implementation's
self-review is not independent approval. Real P2-S9/P3-T1 import, registry adoption/search,
rights/delivery and Phase 3 exit remain separate.

## Untimed occurrence extractor

**Independently approved for bounded tooling readiness — 2026-10-03 Asia/Seoul.** Real execution
requires a separate explicit grant; do not run these examples on real artifacts yet.
`occurrences.py` is an offline memory-only API and counts-only CLI. It has no selection UI,
export, filesystem writer, logger, network, app composition or registry operation. It does
not call synthetic S9 validators or emit a canonical Trip.

From the repository root, using the explicitly nominated label and identified archive:

```sh
python3 -B Tools/TripNomination/occurrences.py \
  --archive "$ARCHIVE_PATH" \
  --expected-size "$ARCHIVE_BYTES" \
  --expected-sha256 "$ARCHIVE_SHA256" \
  --label "$CONFIRMED_LABEL"
```

All variables are explicit caller inputs; there is no default path, discovery or candidate
substitution. Labels are exact `N01`–`N10`. The tool cannot authenticate owner confirmation.
Archive SHA-256 plus label determines the exact original nomination. It reconstructs that
record using the nomination parser; a missing label fails. A second complete `trips.txt`
scan requires exactly one scalar-exact match for its `trip_id`, including beyond the first
ten choices. Even an identical duplicate makes this selected-key join ambiguous. Unrelated
trip-key duplicates do not create ambiguity in this join and are not silently deduplicated.

The CLI exits 0 only with a complete extraction result, printing the outcome (`occurrences`
or `zeroMatches`), matching-record count and transport-order inversion count. Zero matches
is explicit absence of matching evidence, never an empty accepted Trip. Failure exits 1,
prints only a fixed diagnostic on stderr and produces no successful/partial output. CLI
argument errors do not echo private arguments. There is no JSON or output-file option.

For a separately authorized private caller, import with `Tools/TripNomination` on the module
path and Python `-B`:

```python
from occurrences import read_occurrences

result = read_occurrences(archive_path, expected_size, expected_sha256, confirmed_label)
# Keep result and every nested field private, in memory. Do not print/log/serialize.
```

The immutable result contains:

- `source`: label, scalar-exact `trip_id`, `route_id`, `service_id`, and the reconstructed
  original nomination locator. It omits headsigns and other trips columns.
- `occurrences`: every matching record in original CSV source order; each has `stop_id`,
  original `stop_sequence`, `pickup_type`, `drop_off_type`, `timepoint`, arrival/departure
  presence and its exact locator. Each record's trip association is the enclosing `source`.
- `outcome`, complete `stop_times_sha256`, total scanned data-record count and number of
  adjacent selected sequence decreases in transport order. Nothing sorts the output.

Optional scalar fields use `None` for an absent column and `""` for an explicitly empty
value. Time fields expose only `Presence.ABSENT_COLUMN`, `EMPTY` or `PRESENT`. Any nonempty
text, including whitespace or uninterpretable text, means PRESENT; no trimming, clock parsing,
validity claim or time value is returned. Unknown columns are CSV-validated but not exposed.
Object representations conceal fields, as with nomination; callers can still explicitly
access them and are responsible for keeping them private. This is not secure memory erasure
or protection against OS swap, debuggers, tracebacks captured with local variables, or a
caller deliberately logging private objects.

Both complete members must pass the existing strict CSV profile. Occurrence headers require
unique nonempty columns including `trip_id`, `stop_id`, `stop_sequence`; these three values
must be nonempty in every row. Every sequence must use nonempty ASCII decimal digits only.
The selected run must not repeat a numeric sequence key (`1` and `001` collide); original
spelling remains untouched. Gaps, zero and leading zeroes are preserved. Decimal comparison
uses bounded strings, avoiding integer overflow or interpreter digit caps. Duplicate keys
are checked within the selected run only, not as a whole-feed semantic audit. A transport
inversion is reported, not rejected: transport order is not asserted to be railway order.
Source-specific ordering meaning and any later reordering still require reviewed evidence.

Locators use the existing seven-field contract, with `member_name = "stop_times.txt"` for
occurrences. Ordinals count **all data records**, including unmatched records, excluding the
header. `[byte_start, byte_end)` includes quotes, embedded newlines and the full LF/CRLF
terminator; an unterminated final record ends at EOF. Offsets include preceding header/BOM
bytes. Each locator binds archive digest, complete uncompressed member digest and exact
original record bytes/hash. Repeated station visits retain distinct records and locators;
no source ordering key becomes a canonical passenger index.

### Occurrence integrity and limits

One protected, unbuffered archive descriptor is used from initial expected size/SHA-256
verification through both payload reads and final rehash/state/path checks. The existing
no-symlink ancestor traversal and replacement checks apply. Only `trips.txt` and
`stop_times.txt` payloads are decoded; whole-archive hashing necessarily reads other members'
opaque compressed bytes. The shared directory helper validates all member names/metadata,
then selects each required root-level member. The shared inflation routine checks selected
local/central metadata, supported stored/deflate methods, encryption, actual size, CRC and
ordinary data descriptors. Both complete uncompressed member digests are computed.

All existing archive/CSV limits above remain unchanged. Additional fixed limits:

| Resource | Limit |
|---|---:|
| Decompressed `stop_times.txt` | 32 MiB |
| Total occurrence data records, matched or not | 500,000 |
| Matching occurrences | 4,096 |

The complete bounded occurrence member is validated, including records after the final match.
Any malformed record, ambiguous selected join, duplicate selected sequence, integrity failure,
substitution or limit excess prevents delivery of the entire result. No skipping, cropping,
truncation, auto-increase or partial iterator is available. Limits are tooling bounds, not
feed completeness or railway semantics. No wall-clock guarantee is made for stalled storage.

The nomination public API, its limits, labels and trips-only behavior are preserved.
`nomination.py` changes only to parameterize internal member selection and share the existing
bounded inflation routine; `_read_trips` remains its trips-only wrapper. Reader tests and
terminal workflow source/tests are unchanged. New error codes are `nominationUnavailable`,
`ambiguousSelectedKey`, `malformedSequence`, `duplicateSequence`; existing reader codes cover
CSV, ZIP, resource, path and identity failures. This is representation extraction, not source
authentication, passenger classification, recurring identity, coverage proof or S9 acceptance.

### Occurrence verification and independent-review handoff

Run only invented fixtures:

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_*.py' -v
```

The [ROADMAP record](../../docs/ROADMAP.md#bounded-untimed-occurrence-extractor--2026-10-03-asiaseoul)
identifies the saved final run and separate intermediate evidence. `test_occurrences.py`
checks exact original nomination/occurrence locators, joins beyond ten choices, repeated and
interleaved visits, zero matches, decimal duplicates/gaps/inversions, Unicode/quoted-newline/
CRLF/EOF spans, time presence without interpretation, malformed and corrupted suffixes,
limits, no persistence and the actual counts-only CLI. Descriptor instrumentation asserts
one archive open and payload reads bounded to precisely the two allowed members; corrupted
unselected content remains undecoded. Mutation/symlink tests cover pre-open and post-read
substitution and final rehash independent of metadata checks. Shared nomination/workflow
regressions run in the same suite; overlapping results must not be summed.

**Completed independent-review scope (retained for future changes):** a fresh non-author
reviewer inspected `occurrences.py`, `test_occurrences.py`,
the small shared-helper diff in `nomination.py`, this contract and saved evidence. No material
findings or mandatory corrective checks remained. Future changes should recheck
same-descriptor integrity, exact selected-key closure, complete member accounting, omission
of time values/extra source fields, fixed limits, atomic private errors and preserved reader
behavior. The coordinating agent authored the extractor; approval came from a separate
non-author context. Author self-review is not independent approval. Real execution, authoritative
interpretation, real S9/P3-T1 import, registration/adoption, production search, rights/delivery
and Phase 3 exit remain separate. No new accepted decision is introduced.

## Memory-only occurrence inspection

`review_session.py` reuses the unchanged `read_occurrences` API and the nomination session's
terminal guard, bounded command input and ASCII JSON escaping. A separate non-author reviewer
approved this bounded synthetic tooling slice on 2026-10-03 Asia/Seoul with no material findings
or mandatory corrective checks. This approval grants no real re-read or evidence-content access.
It is an owner-operated, unrecorded local terminal interface, not an agent-captured PTY,
browser, exporter, evidence parser or S9 validator. Python 3.9+, standard library only.

**Future real pilot only after separate same-candidate re-read authorization:** from the
repository root, with the original confirmed label and exact private non-symlink archive path
supplied locally (never in chat), the supported invocation is:

```sh
python3 -B Tools/TripNomination/review_session.py \
  --archive "$ARCHIVE_PATH" \
  --expected-size 779699 \
  --expected-sha256 dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4 \
  --label "$CONFIRMED_LABEL" \
  --expected-count 14 \
  --expected-inversions 0
```

These are assertions for the reported pilot, not limits to truncate output. Synthetic callers
supply their invented archive's own identity/counts. Count must be 1–4,096 and inversions
0–(count−1); both flags are required, with no defaults. No candidate selection is provided.
Missing original confirmation/label is a prerequisite gap, not permission to nominate again.
The tool cannot authenticate owner confirmation; the owner must supply that same label.

Terminal qualification happens before archive access. The reader is called exactly once,
with its complete-member validation, all existing limits and final identity checks unchanged.
Count or inversion mismatch (including zero matches) exits with `unexpectedResult`, before
any occurrence or review display. Invalid expectations/references fail before archive access.
No retry, substitution, cropping, sorting, stitching or partial review is available.

After successful validation, all original immutable occurrences remain in memory; the first
is displayed. `O0001` through `O4096` are session-local transport positions, not canonical
indices, railway-order assertions or persistent visit IDs. Navigation never removes a row.

| Command | Effect |
|---|---|
| `inspect O0001` | Show that original occurrence, seven locator fields and annotations. |
| `next`, `prev` | Navigate source transport order; remain at the end/beginning boundary. |
| `source` | Show the original label, trip/route/service associations and nomination locator. |
| `summary` | Count all retained unknown occurrences and recorded gaps; never claim readiness. |
| `refs` | Show the explicit reference allowlist as unopened, unverified assertions. |
| `gap O0001 mapping` | Add a fixed reason in memory, without resolving any other gap. |
| `link O0001 E01` | Attach an allowlisted reference to one original occurrence; resolve nothing. |
| `cancel`, `exit`, EOF or Ctrl-C | End the session; return no private objects and discard annotations. |

Commands are exact, case-sensitive, at most 32 ASCII bytes including newline, using single
spaces as shown. Invalid commands are not echoed and leave review state unchanged. No free-text
notes, classification setter, gap-clearing, acceptance or candidate-change command exists.
Gap reasons are `classification`, `ordering`, `provenance`, `identity`, `mapping`, `movement`,
`endpoints`. Each occurrence starts with classification and ordering gaps. Other zero counts
mean no gap annotation was entered, not that a prerequisite passed. Every classification stays
`unknown`, even after a reference is linked. Unknown interior positions remain visible.

Inspection exposes only `stop_id`, original `stop_sequence`, `pickup_type`, `drop_off_type`,
`timepoint`, arrival/departure presence enums and the exact locator. Optional absent columns
remain JSON `null`, explicit empty values remain `""`. No raw time values, headsigns or unknown
columns are exposed. Repeated visits, sequence spelling, ordinals, byte spans and digests remain
untouched. ASCII JSON escaping is display-only; no stop/pass or railway-order inference occurs.

### Evidence reference boundary

Optionally repeat `--evidence-ref "$EVIDENCE_REFERENCE"`, at most 16 times. Each value is exactly
`E01:<64 lowercase SHA-256 hex characters>` through `E16:<digest>`; labels must be unique.
The owner supplies these privately from an explicitly identified future evidence inventory.
There is no default evidence list. Digests are **owner-asserted references**, not validated hashes:
the interface neither opens nor authenticates any referenced content, resolves a filename/URL,
nor checks provenance, applicability, semantic truth or authority. Recording/linking a reference
does not authorize access, classify a row or resolve a gap. Empty allowlists are supported.

A future substantive evidence review still needs an exact artifact allowlist, named access
authorization, source/revision applicability, provenance/rights and interpretation evidence.
Safe evidence-content presentation/application is not implemented in this slice; it needs
separate design and verification before use. No arbitrary evidence-file reader, new parser,
real mapping/registry reader or synthetic-validator shortcut has been added.

### Failure, confidentiality and verification

CLI success exits 0 after normal session end; cancellation by Ctrl-C exits 130. Reader failures
exit 1 with their fixed code; wrapper failures use `invalidArguments`, `invalidExpectations`,
`invalidEvidenceReferences`, `unexpectedResult`, existing terminal codes, `terminalUnavailable`
or `internalError`. No failure echoes private arguments or raw exception details. Once an
inspection session has begun, a later terminal failure ends it; already displayed terminal
text cannot be recalled. Terminal settings/descriptors use the existing cleanup path.

Input/output/error must share the local foreground canonical terminal. No pipes, redirection,
SSH, recording, `tee`, `script` or terminal logging. Terminal checks cannot detect arbitrary
capture, guarantee locality against disguised SSH, erase scrollback or secure OS memory.
Owners remain responsible for the unrecorded setting. No file, worksheet, log, clipboard,
network, exported result or private Git artifact is created. `-B` prevents bytecode caches.
Clearing session references is not secure memory erasure. All annotations disappear at exit;
this interface cannot create an immutable acceptance packet or establish reproducibility of
an evidence review. Only separately authorized aggregate findings may be reported publicly.

Synthetic checks (invented archives only):

```sh
python3 -B -W error -m unittest discover -s Tools/TripNomination -p 'test_review_session.py' -v
```

Coverage includes original object/locator preservation, repeated visits, gaps/leading zeroes/
inversions, permitted fields and safe escaping, fixed-candidate and mismatch rejection,
unknown-only annotations, unopened allowlists, full validation before display, redacted errors,
cancel/EOF/interruption cleanup, and actual terminal CLI sessions/no output files. The existing
nomination/extractor/workflow suite supplies unchanged parser and shared-terminal coverage.
Independent review must inspect these assertions and the actual boundary, not infer approval
from test counts. Real same-candidate re-read, named evidence access, classification/profile
acceptance, registration, S9 acceptance and P3-T1 consumption remain separate.
