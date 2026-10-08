#!/bin/sh
# Builds the same-process crosswalk ABI library into the
# git-ignored .build directory. Compiles the tool's sources together with the
# app's unchanged P2-S1 reader sources; no Xcode target, no dependency.
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
xcrun swiftc -swift-version 5 -O -module-name StaticDataIntake \
    -emit-library -o "$here/.build/libtsugino-crosswalk.dylib" \
    "$here"/Sources/*.swift \
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
echo "built crosswalk ABI library"
