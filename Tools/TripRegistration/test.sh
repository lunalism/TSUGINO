#!/bin/sh
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
sh "$here/build.sh"
xcrun swiftc -swift-version 5 -Onone -module-cache-path "$here/.build/ModuleCache" -D TRIP_CONVERSION_TESTING -module-name TripRegistryConversionTests \
  "$here"/Sources/*.swift "$here"/Tests/*.swift \
  "$repo"/TSUGINO/Data/Mapping/MintedIdentifier.swift \
  "$repo"/TSUGINO/Data/Mapping/ProviderReference.swift \
  "$repo"/TSUGINO/Data/Mapping/MappingRegistry.swift \
  -o "$here/.build/trip-registry-conversion-tests"
"$here/.build/trip-registry-conversion-tests"
