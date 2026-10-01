#!/bin/sh
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
xcrun swiftc -swift-version 5 -D RAILWAY_STORAGE_TESTING -O -parse-as-library -module-cache-path "$here/.build/module-cache" \
  -o "$here/.build/storage-tests" "$here"/Sources/*.swift "$here"/Tests/*.swift \
  "$repo"/TSUGINO/Data/Storage/*.swift "$repo"/TSUGINO/Data/Mapping/*.swift \
  "$repo"/TSUGINO/Domain/Identifiers/CanonicalIdentifiers.swift \
  "$repo"/TSUGINO/Domain/Railway/GeoCoordinate.swift \
  "$repo"/TSUGINO/Domain/Railway/StationAdjacency.swift \
  "$repo"/TSUGINO/Domain/Railway/RailwayLineTopology.swift \
  "$repo"/TSUGINO/Domain/Railway/LocalizedRailName.swift \
  "$repo"/TSUGINO/Domain/Railway/Operator.swift \
  "$repo"/TSUGINO/Domain/Railway/Station.swift \
  "$repo"/TSUGINO/Domain/Railway/RailwayLine.swift \
  "$repo"/TSUGINO/Domain/Repositories/*.swift \
  "$repo"/TSUGINO/Domain/Search/*.swift "$repo"/TSUGINO/Data/Search/*.swift
exec "$here/.build/storage-tests" "$@"
