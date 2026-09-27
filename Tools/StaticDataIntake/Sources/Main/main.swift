import Foundation

// static-data-intake — the operator's command line (DEC-066, DEC-067).
//
//   static-data-intake --source <id> --archive <path> --obtained-at <UTC> --output <file>
//   static-data-intake validate-railway --input <file>
//
// Inputs and the output file must lie outside the repository. The tool
// performs no network access and reads no credentials. validate-railway is
// read-only: it writes no file and prints only aggregates.

func usage() -> Never {
    let sources = SourceList.all.map(\.sourceID).joined(separator: ", ")
    FileHandle.standardError.write(Data("""
        usage: static-data-intake --source <id> --archive <path> --obtained-at <YYYY-MM-DDTHH:MM:SSZ> --output <file>
               static-data-intake validate-railway --input <file>
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
