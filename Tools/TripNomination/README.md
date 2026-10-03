# Trips-only nomination reader and private terminal session

Standalone offline Python 3.9+ standard-library tool for the bounded owner-nomination
step before real P2-S9 review. No app target, production composition, Swift reader change,
networking, allocation, registry operation, manifest writer or general importer.

**Independently approved for bounded tooling readiness — 2026-10-03 Asia/Seoul.**
The non-author reader review identified the missing private selection interface; a fresh
non-author review subsequently approved the terminal workflow with no material findings or
mandatory corrective checks. **A separate real-input execution grant remains required.**
Neither has been executed on the real archive. See
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
