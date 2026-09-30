# StaticDataIntake

Offline macOS developer tool for static source intake (DEC-066). It is not part of the app.

## Build and test

```sh
Tools/StaticDataIntake/build.sh   # builds .build/static-data-intake
Tools/StaticDataIntake/test.sh    # builds and runs the test runner
```

Both scripts compile with `xcrun swiftc`, together with the app's unchanged P2-S1 reader sources (`TSUGINO/Data/GTFS/Static`). Only build artifacts are written, under the git-ignored `.build/`. The test runner creates its synthetic archives in a temporary directory and removes it when the run ends.

## Run

```sh
Tools/StaticDataIntake/.build/static-data-intake \
    --source DS-01/toei-static-gtfs \
    --archive <archive outside the repository> \
    --obtained-at <YYYY-MM-DDTHH:MM:SSZ from the acquisition record> \
    --output <manifest file outside the repository>
```

To check an `odpt:Railway` JSON file read-only (DEC-067):

```sh
Tools/StaticDataIntake/.build/static-data-intake validate-railway --input <JSON file outside the repository>
```

It writes nothing and prints only counts, totals, and a hash; failures name an error kind, record index, and field, never a provider value.

### Provisional registry (DEC-068, P2-S4)

`mint` adds provisional operator or line entities to a registry on explicit request, and publishes the result as a new file. `review-packet` is read-only: from the same inputs, the registry, and a records file with its operator records written, it exports every grouping and line proposal with its evidence digest to one new file, for the reviewer to write records from. With `--select <file>`, it also exports the exact evidence and digest for reviewer-chosen member sets. Examples are several routes of one line, or records other than a proposal's. It uses the same evidence that `provisional-registry` checks, so the digest is accepted unchanged. It refuses unknown, repeated, or cross-input members, a member in two selections, and members of different or unbound operators. The packet contains provider values: keep it with the inputs, outside the repository, and never commit it. Only counts are printed. `provisional-registry` reads an identified GTFS archive, an optional `odpt:Railway` file, the current provisional registry, and the reviewer's records file. Once the registry holds references of a source, it also reads the previous inputs and records the registry was last reconciled with. It then runs grouping, operator reconciliation, line binding, and line reconciliation, and publishes `registry.json` and `report.json` together as one new directory.

```sh
Tools/StaticDataIntake/.build/static-data-intake mint --kind line --count <n> [--registry <file>] --output <new file>
Tools/StaticDataIntake/.build/static-data-intake review-packet --source <id> --archive <path> --records <file> \
    [--railway-source <id> --railway <file>] [--registry <file>] [--select <file>] --output <new file>
Tools/StaticDataIntake/.build/static-data-intake provisional-registry --source <id> --archive <path> --records <file> \
    [--railway-source <id> --railway <file>] [--registry <file>] \
    [--previous-archive <path> --previous-records <file> [--previous-railway <file>]] \
    [--launch-input <source-id>=<sha256>]... --output <new directory>
```

Every registry these commands write is provisional (DEC-068 §B6): it holds no production identity, stays outside the repository, and may be discarded. The report and the printed output hold only counts, hashes, revisions, and source identifiers. Errors name a stage and an error kind.

### Cross-operator stations (DEC-069, P2-S5)

Both commands read two operators' identified GTFS archives (each with its optional `odpt:Railway` file) and their reviewed P2-S4 records files, plus the provisional registry. The registry must already bind each side's agency to a different operator.

- **Candidates** come only from exact original Japanese names, exact original English names, and the two alias rules (ヶ / ケ, and a trailing 〈…〉 subtitle), used as comparison keys on Japanese values. A pair found by several keys is one candidate that keeps every reason.
  - Differently named stations that the two rules do not relate are not candidates: this is the stated coverage limit (DEC-069 §B4).
  - No distance is computed. Coordinates appear only as the decoded provider values.
- **`station-packet`** is read-only. It exports one new owner-only file:
  - every candidate, with its evidence, discovery reasons, digest, and an empty record template;
  - once every candidate is decided in `--cross-records`, the canonical station groups and an assignment template that proposes held, unused `StationID`s. Adopting the proposal means writing the station records; nothing is applied from the packet.

  Only counts are printed.
- **`station-registry`** needs every candidate decided (`same`, `distinct`, or `ambiguous`) and every group assigned to a held, active provisional `StationID`.
  - It attaches each group's `stop_id` references through its assignment's reviewed record, with `stop_code` following as a descriptive code, using the same reconciliation as `provisional-registry`.
  - An `ambiguous` pair stays two stations, with no relation in the registry.
  - Once the registry holds station references, the previous inputs and cross-operator records are required. A repeat run is byte-identical.
- **`mint --kind station`** adds provisional station entities on explicit request.

```sh
Tools/StaticDataIntake/.build/static-data-intake mint --kind station --count <n> --registry <file> --output <new file>
Tools/StaticDataIntake/.build/static-data-intake station-packet \
    --a-source <id> --a-archive <path> --a-records <file> [--a-railway-source <id> --a-railway <file>] \
    --b-source <id> --b-archive <path> --b-records <file> [--b-railway-source <id> --b-railway <file>] \
    --registry <file> [--cross-records <file>] --output <new file>
Tools/StaticDataIntake/.build/static-data-intake station-registry <the same sides> --registry <file> --cross-records <file> \
    [--previous-a-… --previous-b-… --previous-cross-records <file>] --output <new directory>
```

The cross-operator records file has a `schemaVersion` of 1, and the two `inputs` by source and archive SHA-256. It also holds the reviewer's `decisions`, one per candidate, and `stations`, one per group. Keep it, the packet, and the registry outside the repository.

### Coordinates, topology, and membership (DEC-070, P2-S6)

Both commands read two operators' identified GTFS archives and the provisional registry left by P2-S5. Every stop row and route must hold an active reference last reconciled with those exact archives. The registry is read, never written. No distance is computed.

- **Coordinates.** Each station's member points are classified again on every run.
  - One row, or rows publishing exactly the same point: that exact published point, with every row as provenance.
  - Different points: a reviewed record names one member row, its input hash, its exact point, and a reason.
  - A changed or absent chosen row, or a record reviewed on another input (so each new snapshot is reviewed again), holds the station back. Another point is never substituted. An active station with no row is listed as held back.
  - `--previous-coordinates` carries earlier selections forward as append-only history.
- **Topology.** Each line's trips, in `stop_sequence` order and including pass-through rows, give undirected adjacency candidates: trip evidence, not proof.
  - The possible-shortcut heuristic flags a candidate when some observed alternative run between its stations has intermediates that no supporting trip visits.
  - Flagged candidates, triangles, and self-pairs are review triggers. Each decision lists the intermediates of every alternative run it addresses. Nothing is removed automatically, and an unreviewed case holds the line back.
  - Included adjacencies must form a connected topology whose membership equals the stations the line serves.
  - `--loop-tail-line` and `--branch-line` name lines for shape checks on the built graphs.
- **`network-packet`** exports the review cases, with every row's point, each candidate's evidence, and empty record templates. It prints only counts.
- **`network-build`** publishes `coordinates.json`, `topology.json`, `membership.json`, and `report.json` together, with the report holding aggregates only.

```sh
Tools/StaticDataIntake/.build/static-data-intake network-packet --a-source <id> --a-archive <path> --b-source <id> --b-archive <path> \
    --registry <file> [--network-records <file>] --output <new file>
Tools/StaticDataIntake/.build/static-data-intake network-build --a-source <id> --a-archive <path> --b-source <id> --b-archive <path> \
    --registry <file> [--network-records <file>] [--previous-coordinates <file>] \
    [--loop-tail-line <lineID>]... [--branch-line <lineID>]... --output <new directory>
```

Complete `Station` and `RailwayLine` values are not built here: they need P2-S7's canonical names.

The tool performs no network access and reads no credentials; the operator supplies the archive and its obtained-at time. It refuses archive and output paths inside the repository, never overwrites an existing file, and publishes nothing when any check fails. Only the nine GTFS table members are read and integrity-checked; other members are recorded by name only.

Never commit archives, extracted tables, or manifests (DEC-065 §A).

## P2-S7 reviewed names and exact lookup (DEC-071)

The name commands implement the accepted contract with **synthetic verification only**. They do not authorize real selection, translation, publication, production identifiers or bundling. DEC-071 is authoritative; this section documents command use. No acquisition, translation generation, identifier minting or registry writing occurs. The app contains the provider-neutral `StationSearching` boundary and `ExactStationIndex`, without a UI or runtime importer.

All paths below are owner-controlled external paths. Never put a real manifest, review, document, packet or output in the repository. The existing checked-input and atomic directory publisher are reused: outputs require a new external directory, mode `0700`, with files mode `0600`. Existing outputs are never replaced. Standard output is an aggregate report; malformed input failures do not print provider text.

```sh
static-data-intake name-packet --input /private/owner/name-inputs.json --output /private/owner/name-packet
static-data-intake name-packet --input /private/owner/name-inputs.json --records /private/owner/support.json --selections /private/owner/selection-drafts.json --output /private/owner/name-templates
static-data-intake name-build --input /private/owner/name-inputs.json --records /private/owner/reviewed-names.json --output /private/owner/name-build
static-data-intake name-build --input /private/owner/name-inputs.json --records /private/owner/reviewed-names.json --previous /private/owner/name-build/history.json --output /private/owner/name-repeat
```

`name-packet` exports offline JSON evidence and diagnostics without selecting defaults. `--selections` computes immutable record templates from explicit reviewer selections; a template is **not approval**. Review the exact evidence/value/reason/digests before putting it in the approved records file. `name-build` performs validation and construction; it returns a failing exit status when incomplete, while preserving diagnostics and history with no named Domain dataset or search entries. Incomplete packet export succeeds so it can be reviewed. The five build artifacts (`packet.json`, `report.json`, `history.json`, `names.json`, `index.json`) must be byte-identical on a repeat with the same inputs, records and previous history.

The version-1 input manifest (`RailNameRun`) contains:

| Field | Contents |
|---|---|
| `schemaVersion` | `1` |
| `archives` | Exactly two current static inputs: `sourceID`, absolute `path`, exact archive `sha256` |
| `railways` | All active Railway sources: `sourceID`, absolute `path`, exact file `sha256`; an empty array only when the registry has none |
| `historicalArchives` | Explicit historical static inputs in the same archive format, only when needed to verify retained historical aliases |
| `registryPath`, `registrySHA256` | Current reconciled registry, checked before extraction and again before publication |
| `networkRecordsPath` | Optional DEC-070 coordinate/topology records; omitted only if no network review is required |
| `shapes` | Explicit existing `lineID` and `kind` (`loopPlusTail` or `branch`); later baseline real acceptance must supply both reviewed line IDs |
| `documents` | Authoritative supporting documents: exact `id`, absolute `path`, exact `sha256`; the owner records the reviewed assertion and citation separately |

Archives and member hashes are freshly identified, Railway bytes are checked and parsed, all active registry sources/references are checked, and P2-S6 network validation is rerun from the identified inputs and fixed records. This preserves DEC-070's stricter coordinate-input rules; name carry-forward does not bypass them. This slice expects Japanese base static-feed labels, explicit agency IDs, and the reader's accepted `field_value` translation profile. It refuses unsupported dependencies rather than guessing. No saved name packet is treated as current input truth.

The version-1 records file (`RailNameRecords`) contains `schemaVersion`, `names`, `titles`, `authored`, and `crosswalks`; use empty arrays where appropriate. Exact field structures are the Codable record types in `RailNameReview.swift` and `RailwayTitleReview.swift`. The packet lists the current complete candidate/member scope, language-specific source keys, original registry-name history, source sightings, scoped binding alternatives and held-back reasons. Review IDs are unique, source keys are exact, and every current record must be used and valid for a complete build.

The version-1 selection-draft file (`RailNameSelections`) contains `schemaVersion`, `names`, and `titles`:

- A name draft supplies `reviewID`, `reviewer`, `date`, optional `supersedes`, existing `entityID`, `language` (`ja`, `en`, `ko`), `purpose` (`name`, `alias`), exact `selected` candidate key, exact `value`, `reason`, `basis`, optional `preferredSource`, and optional `aliasRule`. Names, aliases and queries are scalar-exact; no implicit trimming, normalization, prefix/fuzzy match or automatic alias expansion occurs.
- Supported name bases are `publishedMember`, `preferredSource`, `authoredApproval` and `historicalAlias`. These are finite checks on source, author/lineage or verified history. Free-text reason alone is never proof. An explicit alias rule is `orthographicKe` or `subtitleBracket`, retaining its original source and exact additional key; the subtitle rule only removes the published trailing subtitle.
- A title draft supplies `reviewID`, `reviewer`, `date`, optional `supersedes`, exact `source` (`sourceID`, full `stationReference`), existing `stationID`, `reason`, `basis` (`authoritativeCrosswalk`, `anchoredNeighbours`) and `anchors`. The tool supplies full evidence and both digests. Resolve direct bindings first; anchored drafts can cite only already validated direct bindings supplied through `--records`.
- Crosswalks are explicit reviewed assertions with `id`, exact `source`, `gtfsSourceID`, `stopID`, `documentID`, `documentSHA256`, `citation`, `reviewer`, and `reason`. Document bytes are verified; the tool does not infer whether a document is authoritative or interpret its prose. That assertion belongs to its reviewer.
- Anchored support requires two distinct direct anchors, matching logical positions in every enclosing Railway record, and unique neighbour support on **each** scoped validated line. Unioning neighbours from different lines cannot prove a binding. Circular chains, unresolved scopes, competing targets and conflicting crosswalks hold the binding back.
- Authored records explicitly name `id`, existing `entityID`, `language`, `value`, `author`, `reviewer`, `approvalID`, `method` (`human` or `machineAssisted`), `reason`, `authorizationReferences`, and `lineage` source keys. The code authors nothing and checks lineage against published/bound source candidates, not chains of authored assertions. Authorization references record an owner's separate decision; they do not establish legal permission automatically.

Choice evidence is immutable. History retains all choices, original and failed/current observations, full evidence digests, passing dependency checks and validation predecessor links. Unchanged semantic evidence can add a new identified sighting without adding an owner choice. Changed candidates, source-to-entity bindings, relevant members, language values or rationale dependencies hold the selection back. Historical aliases need their retained exact original and an available hash-checked historical archive. An explicit new review must link to the previous leaf. Superseded reviews cannot be reactivated, previous aliases cannot disappear silently, and no current incomplete selection gets a placeholder.

Complete construction requires three reviewed names for every active operator/station/line, all network coordinates/topologies/memberships/shapes valid, and zero unresolved bindings/aliases or unused records. The exact index returns all matching station IDs once, sorted, with validated line/operator context; a shared name never merges identities. The JSON outputs are review artifacts, not a selected shipping persistence format. P2-S8 remains separate.
