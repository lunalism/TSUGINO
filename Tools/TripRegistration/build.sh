#!/bin/sh
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
xcrun swiftc -swift-version 5 -O -module-cache-path "$here/.build/ModuleCache" -module-name TripRegistryConversion \
  "$here"/Sources/*.swift "$here"/Sources/Main/main.swift \
  "$repo"/TSUGINO/Data/Mapping/MintedIdentifier.swift \
  "$repo"/TSUGINO/Data/Mapping/ProviderReference.swift \
  "$repo"/TSUGINO/Data/Mapping/MappingRegistry.swift \
  -o "$here/.build/trip-registry-conversion"
echo "built trip-registry-conversion"
