#!/bin/sh
# Builds the operator's static-data-intake tool (DEC-066) into the
# git-ignored .build directory. Compiles the tool's sources together with the
# app's unchanged P2-S1 reader sources; no Xcode target, no dependency.
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
xcrun swiftc -swift-version 5 -O -module-name StaticDataIntake \
    -o "$here/.build/static-data-intake" \
    "$here"/Sources/*.swift "$here"/Sources/Main/main.swift \
    "$repo"/TSUGINO/Data/GTFS/Static/*.swift \
    "$repo"/TSUGINO/Data/ODPT/Railway/*.swift \
    "$repo"/TSUGINO/Data/Mapping/*.swift
echo "built $here/.build/static-data-intake"
