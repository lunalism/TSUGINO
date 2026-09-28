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

The tool performs no network access and reads no credentials; the operator supplies the archive and its obtained-at time. It refuses archive and output paths inside the repository, never overwrites an existing file, and publishes nothing when any check fails. Only the nine GTFS table members are read and integrity-checked; other members are recorded by name only.

Never commit archives, extracted tables, or manifests (DEC-065 §A).
