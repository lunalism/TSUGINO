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

The tool performs no network access and reads no credentials; the operator supplies the archive and its obtained-at time. It refuses archive and output paths inside the repository, never overwrites an existing file, and publishes nothing when any check fails. Only the nine GTFS table members are read and integrity-checked; other members are recorded by name only.

Never commit archives, extracted tables, or manifests (DEC-065 §A).
