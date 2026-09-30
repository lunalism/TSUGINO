#!/bin/sh
# Builds and runs the static-data-intake test runner (DEC-066 §H). The
# runner is compiled with -D INTAKE_TESTING, which adds the test-only
# injection points; the operator's build never has them. Synthetic archives
# are created in a fresh temporary directory and removed when the run ends.
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
xcrun swiftc -swift-version 5 -Onone -D INTAKE_TESTING -module-name StaticDataIntakeTests \
    -o "$here/.build/static-data-intake-tests" \
    "$here"/Sources/*.swift "$here"/Tests/*.swift \
    "$repo"/TSUGINO/Data/GTFS/Static/*.swift \
    "$repo"/TSUGINO/Data/ODPT/Railway/*.swift \
    "$repo"/TSUGINO/Data/Mapping/*.swift \
    "$repo"/TSUGINO/Domain/Identifiers/CanonicalIdentifiers.swift \
    "$repo"/TSUGINO/Domain/Railway/GeoCoordinate.swift \
    "$repo"/TSUGINO/Domain/Railway/StationAdjacency.swift \
    "$repo"/TSUGINO/Domain/Railway/RailwayLineTopology.swift \
    "$repo"/TSUGINO/Domain/Railway/LocalizedRailName.swift \
    "$repo"/TSUGINO/Domain/Railway/Operator.swift \
    "$repo"/TSUGINO/Domain/Railway/Station.swift \
    "$repo"/TSUGINO/Domain/Railway/RailwayLine.swift \
    "$repo"/TSUGINO/Domain/Search/*.swift \
    "$repo"/TSUGINO/Data/Search/*.swift
exec "$here/.build/static-data-intake-tests"
