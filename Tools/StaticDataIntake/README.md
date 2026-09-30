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
