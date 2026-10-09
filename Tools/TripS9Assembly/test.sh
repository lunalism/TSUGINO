#!/bin/sh
set -eu
here=$(cd "$(dirname "$0")" && pwd -P)
repo=$(cd "$here/../.." && pwd -P)
sh "$here/build.sh"
xcrun swiftc -swift-version 5 -Onone -whole-module-optimization -D S9_TESTING -module-name TripS9AssemblyTests \
  "$repo"/Tools/TripRegistration/Sources/*.swift \
  "$repo"/Tools/TripRegistration/Tests/Fixtures.swift \
  "$repo"/Tools/TripRegistration/Tests/RegistrationFixtures.swift \
  "$repo"/TSUGINO/Data/Mapping/MintedIdentifier.swift \
  "$repo"/TSUGINO/Data/Mapping/ProviderReference.swift \
  "$repo"/TSUGINO/Data/Mapping/MappingRegistry.swift \
  "$repo"/TSUGINO/Domain/Identifiers/CanonicalIdentifiers.swift \
  "$repo"/TSUGINO/Domain/Railway/Trip*.swift \
  "$here"/Sources/*.swift "$here"/Tests/*.swift \
  -o "$here/.build/trip-s9-assembly-tests"
"$here/.build/trip-s9-assembly-tests" "$here/.build/trip-s9-assembly"
