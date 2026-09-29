import Foundation

// static-data-intake — the operator's command line (DEC-066, DEC-067).
//
//   static-data-intake --source <id> --archive <path> --obtained-at <UTC> --output <file>
//   static-data-intake validate-railway --input <file>
//   static-data-intake mint --kind operator|line --count <n> [--registry <file>] --output <file>
//   static-data-intake review-packet --source <id> --archive <path> --records <file>
//       [--railway-source <id> --railway <file>] [--registry <file>] [--select <file>] --output <new file>
//   static-data-intake provisional-registry --source <id> --archive <path> --records <file>
//       [--railway-source <id> --railway <file>] [--registry <file>]
//       [--previous-archive <path> --previous-records <file> [--previous-railway <file>]]
//       [--launch-input <source-id>=<sha256>]... --output <new directory>
//
// Inputs and outputs must lie outside the repository. The tool performs no
// network access and reads no credentials. validate-railway is read-only:
// it writes no file and prints only aggregates. mint and provisional-registry
// write provisional registries only (DEC-068 §B6): never production identity.

func usage() -> Never {
    let sources = SourceList.all.map(\.sourceID).joined(separator: ", ")
    FileHandle.standardError.write(Data("""
        usage: static-data-intake --source <id> --archive <path> --obtained-at <YYYY-MM-DDTHH:MM:SSZ> --output <file>
               static-data-intake validate-railway --input <file>
               static-data-intake mint --kind operator|line --count <n> [--registry <file>] --output <file>
               static-data-intake review-packet --source <id> --archive <path> --records <file>
                   [--railway-source <id> --railway <file>] [--registry <file>] [--select <file>] --output <new file>
               static-data-intake provisional-registry --source <id> --archive <path> --records <file>
                   [--railway-source <id> --railway <file>] [--registry <file>]
                   [--previous-archive <path> --previous-records <file> [--previous-railway <file>]]
                   [--launch-input <source-id>=<sha256>]... --output <new directory>
        sources: \(sources)

        """.utf8))
    exit(64)
}

func toolRepositoryRoot() throws(IntakeError) -> FileIdentity {
    guard let executable = Bundle.main.executablePath, let resolved = resolvedPath(executable) else {
        throw IntakeError.repositoryRootUnavailable
    }
    return try repositoryRoot(containing: (resolved as NSString).deletingLastPathComponent)
}

if CommandLine.arguments.dropFirst().first == "validate-railway" {
    let rest = Array(CommandLine.arguments.dropFirst(2))
    guard rest.count == 2, rest[0] == "--input" else { usage() }
    do {
        let root = try toolRepositoryRoot()
        let summary = try await RailwayValidation.run(inputPath: rest[1], repositoryRoot: root)
        print(summary.report(), terminator: "")
        exit(0)
    } catch let error as IntakeError {
        FileHandle.standardError.write(Data("validate-railway failed: \(error)\n".utf8))
        exit(1)
    } catch let error as RailwayValidationError {
        FileHandle.standardError.write(Data("validate-railway failed: \(error)\n".utf8))
        exit(1)
    } catch {
        FileHandle.standardError.write(Data("validate-railway failed.\n".utf8))
        exit(1)
    }
}

/// Flags of a subcommand, each once, except those listed as repeatable.
func parseFlags(_ allowed: Set<String>, repeatable: Set<String> = []) -> (single: [String: String], repeated: [String: [String]]) {
    var single: [String: String] = [:]
    var repeated: [String: [String]] = [:]
    var rest = CommandLine.arguments.dropFirst(2)
    while let flag = rest.popFirst() {
        guard allowed.contains(flag) || repeatable.contains(flag), let value = rest.popFirst() else { usage() }
        if repeatable.contains(flag) {
            repeated[flag, default: []].append(value)
        } else {
            guard single[flag] == nil else { usage() }
            single[flag] = value
        }
    }
    return (single, repeated)
}

if CommandLine.arguments.dropFirst().first == "mint" {
    let (flags, _) = parseFlags(["--kind", "--count", "--registry", "--output"])
    guard let kindName = flags["--kind"], let countText = flags["--count"], let count = Int(countText),
          let output = flags["--output"] else { usage() }
    let kinds: [String: CanonicalKind] = ["operator": .railwayOperator, "line": .line]
    guard let kind = kinds[kindName] else { usage() }
    do {
        let root = try toolRepositoryRoot()
        let registry = try ProvisionalMint.run(kind: kind, count: count, registryPath: flags["--registry"], outputPath: output, repositoryRoot: root)
        print("""
            published provisional registry: \(output)
            minted: \(count) \(kindName) identities (provisional, not production)
            registry revision: \(registry.revision); entities: \(registry.entities.count); references: \(registry.references.count)
            """)
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("mint failed: \(error)\n".utf8))
        exit(1)
    }
}

if CommandLine.arguments.dropFirst().first == "review-packet" {
    let (flags, _) = parseFlags(["--source", "--archive", "--records", "--railway-source", "--railway", "--registry", "--select", "--output"])
    guard let sourceID = flags["--source"], SourceList.source(id: sourceID) != nil,
          flags["--railway-source"].map({ SourceList.railwaySource(id: $0) != nil }) ?? true,
          let archive = flags["--archive"], let records = flags["--records"], let output = flags["--output"] else { usage() }
    let request = ReviewPacketRequest(
        gtfsSourceID: sourceID, railwaySourceID: flags["--railway-source"],
        inputs: .init(archivePath: archive, railwayPath: flags["--railway"], recordsPath: records),
        registryPath: flags["--registry"], selectionPath: flags["--select"], outputPath: output
    )
    do {
        let root = try toolRepositoryRoot()
        let (_, summary) = try await ReviewPacketCommand.run(request, repositoryRoot: root)
        // The packet holds provider values; only its counts are printed.
        print("published review packet (provider values; keep outside the repository): \(output)")
        print(summary.report(), terminator: "")
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("review-packet failed: \(error)\n".utf8))
        exit(1)
    }
}

if CommandLine.arguments.dropFirst().first == "provisional-registry" {
    let (flags, repeated) = parseFlags(
        ["--source", "--archive", "--records", "--railway-source", "--railway", "--registry",
         "--previous-archive", "--previous-records", "--previous-railway", "--output"],
        repeatable: ["--launch-input"]
    )
    guard let sourceID = flags["--source"], SourceList.source(id: sourceID) != nil,
          flags["--railway-source"].map({ SourceList.railwaySource(id: $0) != nil }) ?? true,
          let archive = flags["--archive"], let records = flags["--records"], let output = flags["--output"] else { usage() }
    let hasPrevious = flags["--previous-archive"] != nil || flags["--previous-records"] != nil || flags["--previous-railway"] != nil
    guard !hasPrevious || (flags["--previous-archive"] != nil && flags["--previous-records"] != nil) else { usage() }
    var launch = Set<LaunchInputs.Identity>()
    for entry in repeated["--launch-input", default: []] {
        let parts = entry.split(separator: "=", maxSplits: 1).map(String.init)
        guard parts.count == 2, MappingText.isToken(parts[0]), MappingText.isSHA256(parts[1]) else { usage() }
        launch.insert(.init(sourceID: parts[0], inputSHA256: parts[1]))
    }
    let request = ProvisionalRegistryRequest(
        gtfsSourceID: sourceID,
        railwaySourceID: flags["--railway-source"],
        current: .init(archivePath: archive, railwayPath: flags["--railway"], recordsPath: records),
        previous: hasPrevious ? .init(
            archivePath: flags["--previous-archive"]!, railwayPath: flags["--previous-railway"], recordsPath: flags["--previous-records"]!
        ) : nil,
        registryPath: flags["--registry"],
        outputPath: output,
        launchInputs: LaunchInputs(identities: launch)
    )
    do {
        let root = try toolRepositoryRoot()
        let result = try await ProvisionalRegistryCommand.run(request, repositoryRoot: root)
        print("published provisional registry and report: \(output)")
        print(String(decoding: result.report.encoded(), as: UTF8.self), terminator: "")
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("provisional-registry failed: \(error)\n".utf8))
        exit(1)
    }
}

var options: [String: String] = [:]
var arguments = CommandLine.arguments.dropFirst()
while let flag = arguments.popFirst() {
    guard ["--source", "--archive", "--obtained-at", "--output"].contains(flag),
          let value = arguments.popFirst(), options[flag] == nil else { usage() }
    options[flag] = value
}
guard let sourceID = options["--source"], let archive = options["--archive"],
      let obtainedAt = options["--obtained-at"], let output = options["--output"] else { usage() }
guard let source = SourceList.source(id: sourceID) else { usage() }

do {
    let root = try toolRepositoryRoot()
    let request = IntakeRequest(source: source, archivePath: archive, outputPath: output, obtainedAt: obtainedAt)
    let result = try await StaticDataIntake.run(request, repositoryRoot: root)

    let feed = result.feed
    print("""
        published manifest: \(output)
        archive SHA-256: \(result.manifest.archiveSHA256) (\(result.manifest.archiveByteCount) bytes)
        feed_version: \(result.manifest.feedVersion ?? "-")
        selected members: \(result.manifest.selectedMembers.count); unselected members: \(result.manifest.unselectedMembers.count)
        reader: 0 invalid, 0 unsupported
        rows: agency \(feed.agencies.count), stops \(feed.stops.count), routes \(feed.routes.count), \
        trips \(feed.trips.count), stop_times \(feed.stopTimes.count), calendar \(feed.calendars.count), \
        calendar_dates \(feed.calendarDates.count), feed_info \(feed.feedInfo.count), translations \(feed.translations.count)
        """)
} catch {
    FileHandle.standardError.write(Data("intake failed: \(error)\n".utf8))
    exit(1)
}
