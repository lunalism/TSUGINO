#!/bin/sh
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
mkdir -p "$here/.build"
xcrun swiftc -swift-version 5 -O -whole-module-optimization -module-cache-path "$here/.build/ModuleCache" -module-name TimetableImport \
  "$repo"/Tools/TripRegistration/Sources/*.swift \
  "$repo"/Tools/TripS9Assembly/Sources/*.swift \
  "$repo"/TSUGINO/Data/Mapping/MintedIdentifier.swift \
  "$repo"/TSUGINO/Data/Mapping/ProviderReference.swift \
  "$repo"/TSUGINO/Data/Mapping/MappingRegistry.swift \
  "$repo"/TSUGINO/Domain/Identifiers/CanonicalIdentifiers.swift \
  "$repo"/TSUGINO/Domain/Railway/Trip*.swift \
  "$repo"/TSUGINO/Domain/Timetable/*.swift \
  "$here"/Sources/*.swift "$here"/Sources/Main/main.swift \
  -o "$here/.build/timetable-import"
echo 'built timetable-import'
