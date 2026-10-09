#!/bin/sh
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
sh "$here/build.sh"
xcrun swiftc -swift-version 5 -Onone -whole-module-optimization -module-cache-path "$here/.build/ModuleCache" -D TIMETABLE_IMPORT_TESTING -module-name TimetableImportTests \
  "$repo"/Tools/TripRegistration/Sources/*.swift \
  "$repo"/Tools/TripRegistration/Tests/Fixtures.swift \
  "$repo"/Tools/TripRegistration/Tests/RegistrationFixtures.swift \
  "$repo"/Tools/TripS9Assembly/Sources/*.swift \
  "$repo"/TSUGINO/Data/Mapping/MintedIdentifier.swift \
  "$repo"/TSUGINO/Data/Mapping/ProviderReference.swift \
  "$repo"/TSUGINO/Data/Mapping/MappingRegistry.swift \
  "$repo"/TSUGINO/Domain/Identifiers/CanonicalIdentifiers.swift \
  "$repo"/TSUGINO/Domain/Railway/Trip*.swift \
  "$repo"/TSUGINO/Domain/Timetable/*.swift \
  "$here"/Sources/*.swift "$here"/Tests/*.swift \
  -o "$here/.build/timetable-import-tests"
"$here/.build/timetable-import-tests" "$here/.build/timetable-import"
