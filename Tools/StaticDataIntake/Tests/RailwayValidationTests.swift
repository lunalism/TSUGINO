import Foundation

// DEC-067 cases for the DS-03 source entry and the read-only validate-railway
// command. Every input is invented: identifiers are `syn:…`, line codes `Q`,
// `Qb`, and `R` are stand-ins, and titles are "Synthetic …".

enum SyntheticRailway {
    static func record(_ id: String, lineCode: String, stations: Int, titleLanguages: [String] = ["en", "ja"]) -> String {
        let title = titleLanguages.map { #""\#($0)": "Synthetic \#(lineCode) (\#($0))""# }.joined(separator: ", ")
        let order = (0..<stations).map { offset in
            #"{"odpt:index": \#(offset + 1), "odpt:station": "\#(id).S\#(offset + 1)", "odpt:stationTitle": {"ja": "合成", "en": "Synthetic"}}"#
        }.joined(separator: ", ")
        return """
            {"@type": "odpt:Railway", "@id": "\(id)", "owl:sameAs": "\(id)", "odpt:operator": "syn:Operator", \
            "odpt:lineCode": "\(lineCode)", "odpt:railwayTitle": {\(title)}, "odpt:stationOrder": [\(order)]}
            """
    }

    /// Three records: a line, its branch as a separate record, and another
    /// line; 6 station-order entries in total.
    static let valid = "[" + [
        record("syn:Railway.Q", lineCode: "Q", stations: 3, titleLanguages: ["en", "ja", "ko"]),
        record("syn:Railway.QBranch", lineCode: "Qb", stations: 2),
        record("syn:Railway.R", lineCode: "R", stations: 1),
    ].joined(separator: ",") + "]"
}

/// Every file and directory under `root`, relative and sorted.
func workspaceTree(_ root: URL) -> [String] {
    let enumerator = FileManager.default.enumerator(atPath: root.path)
    var paths: [String] = []
    while let path = enumerator?.nextObject() as? String { paths.append(path) }
    return paths.sorted()
}

func validateRailway(
    _ input: URL,
    limit: Int64 = RailwayValidation.standardLimit,
    afterOpen: (() -> Void)? = nil
) async -> Result<RailwayValidationSummary, RailwayValidationError> {
    do {
        return .success(try await RailwayValidation.run(inputPath: input.path, repositoryRoot: testRepositoryRoot, limit: limit, afterOpen: afterOpen))
    } catch {
        return .failure(error)
    }
}

/// Runs validate-railway expecting `expected`, and checks that nothing was
/// written anywhere in the workspace.
func expectRailwayFailure(
    _ expected: RailwayValidationError,
    _ input: URL,
    in workspace: Workspace,
    limit: Int64 = RailwayValidation.standardLimit,
    afterOpen: (() -> Void)? = nil
) async throws {
    let before = workspaceTree(workspace.root)
    let result = await validateRailway(input, limit: limit, afterOpen: afterOpen)
    guard case .failure(let error) = result else { throw TestFailure(message: "expected \(expected), got \(result)") }
    try check(error == expected, "expected \(expected), got \(error)")
    try check(workspaceTree(workspace.root) == before, "validate-railway changed the workspace")
}

let railwayTests: [TestCase] = [
    ("the DS-03 source entry carries only verified catalog metadata and no URL", { _ in
        let source = SourceList.tokyoMetroStaticGTFS
        try check(source.sourceID == "DS-03/tokyometro-static-gtfs", "sourceID")
        try check(source.provider == "Tokyo Metro", "provider")
        try check(source.license == "Public Transportation Open Data Basic License", "license")
        try check(source.dataset == "train-tokyometro", "dataset")
        try check(source.resource == "d4f11962-1c5a-4316-9a16-7fb229c227ea", "resource")
        try check(source.access == .credentialed && source.url == nil, "access")
        try source.validate()
        try check(SourceList.source(id: "DS-03/tokyometro-static-gtfs") == source, "lookup")
    }),
    ("an intake under the DS-03 entry publishes a manifest with no URL", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        let output = workspace.output.appendingPathComponent("metro.json")
        guard case .success(let result) = await intake(archive: archive, output: output, source: SourceList.tokyoMetroStaticGTFS) else {
            throw TestFailure(message: "the intake failed")
        }
        try check(result.manifest.sourceAccess == .credentialed && result.manifest.sourceURL == nil, "manifest source")
        try check(result.manifest.resource == "d4f11962-1c5a-4316-9a16-7fb229c227ea", "manifest resource")
        let json = String(decoding: try Data(contentsOf: output), as: UTF8.self)
        try check(!json.contains("sourceURL") && !json.contains("://"), "a URL was recorded")
    }),
    ("validate-railway prints exactly the aggregates for a valid input", { workspace in
        let input = try workspace.write(Data(SyntheticRailway.valid.utf8), named: "railway.json")
        let before = workspaceTree(workspace.root)
        guard case .success(let summary) = await validateRailway(input) else { throw TestFailure(message: "validation failed") }
        try check(summary.inputSHA256 == sha256Hex(Data(SyntheticRailway.valid.utf8)), "hash")
        try check(summary.byteCount == Int64(SyntheticRailway.valid.utf8.count), "byte count")
        try check(summary.recordCount == 3 && summary.distinctLineCodeCount == 3, "counts")
        try check(summary.stationOrderEntryCount == 6, "station-order entries")
        try check(summary.recordTitleLanguages == ["en": 3, "ja": 3, "ko": 1], "record title languages")
        try check(summary.stationTitleLanguages == ["en": 6, "ja": 6], "station title languages")
        let expectedReport = """
            input SHA-256: \(summary.inputSHA256) (\(summary.byteCount) bytes)
            reader: 0 invalid, 0 unsupported
            records: 3
            distinct line codes: 3
            station-order entries: 6
            record title languages: en 3, ja 3, ko 1
            station title languages: en 6, ja 6

            """
        try check(summary.report() == expectedReport, "report:\n\(summary.report())")
        try check(!summary.report().contains("syn:") && !summary.report().contains("Synthetic"), "the report carried a value")
        try check(workspaceTree(workspace.root) == before, "validate-railway changed the workspace")
    }),
    ("validate-railway refuses repository paths, including through a symlink", { workspace in
        let repositoryFile = URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs/ROADMAP.md")
        try await expectRailwayFailure(.pathInsideRepository, repositoryFile, in: workspace)
        let link = workspace.archives.appendingPathComponent("railway-link.json")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: repositoryFile)
        try await expectRailwayFailure(.pathInsideRepository, link, in: workspace)
    }),
    ("validate-railway refuses a non-regular file and an input over its limit", { workspace in
        try await expectRailwayFailure(.notRegularFile, workspace.archives, in: workspace)
        let fifo = workspace.archives.appendingPathComponent("railway.fifo")
        try check(mkfifo(fifo.path, 0o600) == 0, "mkfifo failed")
        try await expectRailwayFailure(.notRegularFile, fifo, in: workspace)
        let data = Data(SyntheticRailway.valid.utf8)
        let input = try workspace.write(data, named: "railway.json")
        try await expectRailwayFailure(.tooLarge(byteCount: Int64(data.count)), input, in: workspace, limit: Int64(data.count - 1))
        try check(RailwayValidation.standardLimit == 8 * 1024 * 1024, "standard limit")
    }),
    ("validate-railway reads no more than the size recorded at open", { workspace in
        let data = Data(SyntheticRailway.valid.utf8)
        let input = try workspace.write(data, named: "railway.json")
        let file = try ArchiveFile(resolvedPath: input.path, limit: RailwayValidation.standardLimit)
        try check(try file.readAll(maximum: Int64(data.count)) == data, "the whole file at its recorded size")
        let handle = try FileHandle(forWritingTo: input)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data(repeating: 0x20, count: 3 * 1024 * 1024))
        try handle.close()
        try check(try file.readAll(maximum: Int64(data.count)) == nil, "a grown file was read in full")
    }),
    ("validate-railway rejects an input that grows after it is opened, even past its limit", { workspace in
        let data = Data(SyntheticRailway.valid.utf8)
        let input = try workspace.write(data, named: "railway.json")
        let limit = Int64(data.count + 16)
        let grow = {
            guard let handle = try? FileHandle(forWritingTo: input) else { return }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: Data(repeating: 0x20, count: Int(limit) * 4))
            try? handle.close()
        }
        let before = workspaceTree(workspace.root)
        let result = await validateRailway(input, limit: limit, afterOpen: grow)
        guard case .failure(.inputChanged) = result else { throw TestFailure(message: "expected inputChanged, got \(result)") }
        try check(workspaceTree(workspace.root) == before, "validate-railway changed the workspace")
    }),
    ("validate-railway reports well-formed JSON the platform parser cannot read as unsupported", { workspace in
        let deep = String(repeating: "[", count: 600) + String(repeating: "]", count: 600)
        let input = try workspace.write(Data(deep.utf8), named: "deep.json")
        let expected = RailwayValidationError.reader(.unsupported(.platformParserLimit, at: ODPTRailwayLocation(recordIndex: nil, field: nil)))
        try await expectRailwayFailure(expected, input, in: workspace)
        try check(expected.description == "unsupported: platformParserLimit", "message: \(expected.description)")
    }),
    ("validate-railway reports reader failures without any provider value", { workspace in
        let malformed = try workspace.write(Data("[\(SyntheticRailway.record("syn:Railway.Q", lineCode: "Q", stations: 1)),]".utf8), named: "a.json")
        try await expectRailwayFailure(.reader(.invalid(.malformedJSON)), malformed, in: workspace)

        let duplicate = "[" + SyntheticRailway.record("syn:Railway.Q", lineCode: "Q", stations: 1) + "," +
            SyntheticRailway.record("syn:Railway.Q", lineCode: "R", stations: 1) + "]"
        let input = try workspace.write(Data(duplicate.utf8), named: "b.json")
        let expected = RailwayValidationError.reader(.unsupported(.duplicateValue, at: ODPTRailwayLocation(recordIndex: 1, field: "@id")))
        try await expectRailwayFailure(expected, input, in: workspace)
        let message = expected.description
        try check(message == "unsupported: duplicateValue, record 1, field @id", "message: \(message)")
        try check(!message.contains("syn:") && !message.contains("Synthetic"), "the message carried a value")
        try check(!RailwayValidationError.pathInsideRepository.description.contains("/"), "a path was printed")
    }),
]
