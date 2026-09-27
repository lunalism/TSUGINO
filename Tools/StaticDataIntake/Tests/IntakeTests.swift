import Foundation

// DEC-066 / ROADMAP P2-S2 cases for the static-data-intake tool.

typealias TestCase = (name: String, body: (Workspace) async throws -> Void)

let unitTests: [TestCase] = [
    ("name policy accepts flat ASCII names", { _ in
        for name in ["agency.txt", "stop_times.txt", "fare-rules.txt", "A1.b_c-d"] {
            try check(MemberPolicy.isAllowedName(name), "\(name) should be allowed")
        }
    }),
    ("name policy rejects every unsafe class", { _ in
        for name in ["dir/agency.txt", "../evil.txt", "/abs.txt", "folder/", ".hidden", "ctl\\001.txt",
                     "ctl\u{01}.txt", "日本.txt", "back\\slash.txt", "", "-lead.txt", "_lead.txt", "sp ace.txt"] {
            try check(!MemberPolicy.isAllowedName(name), "\(name.debugDescription) should be rejected")
        }
    }),
    ("partition sorts, records unselected by name, and needs every required table", { _ in
        let (selected, unselected) = try MemberPolicy.partition(
            ["trips.txt", "zeta.txt", "agency.txt", "stops.txt", "routes.txt", "stop_times.txt", "alpha.txt"]
        )
        try check(selected == ["agency.txt", "routes.txt", "stop_times.txt", "stops.txt", "trips.txt"], "\(selected)")
        try check(unselected == ["alpha.txt", "zeta.txt"], "\(unselected)")
        do {
            _ = try MemberPolicy.partition(["agency.txt", "stops.txt", "routes.txt", "trips.txt"])
            throw TestFailure(message: "a missing stop_times.txt was accepted")
        } catch let error as IntakeError {
            try check(error == .missingRequiredMember(name: "stop_times.txt"), "\(error)")
        }
    }),
    ("standard limits are 32, 64, and 128 MiB", { _ in
        try check(IntakeLimits.standard.archiveBytes == 33_554_432, "archive")
        try check(IntakeLimits.standard.memberBytes == 67_108_864, "member")
        try check(IntakeLimits.standard.selectedTotalBytes == 134_217_728, "total")
    }),
    ("SHA-256 known-answer vectors", { _ in
        try check(sha256Hex(Data()) == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "empty")
        try check(sha256Hex(Data("abc".utf8)) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", "abc")
    }),
    ("obtained-at must be a real UTC time in the exact form", { _ in
        try check(isValidObtainedAt("2026-09-26T00:00:00Z"), "valid")
        try check(isValidObtainedAt("2024-02-29T23:59:59Z"), "leap day")
        for text in ["2026-09-26T00:00:00+09:00", "2026-09-26T00:00:00", "2026-09-26 00:00:00Z",
                     "2026-02-30T00:00:00Z", "2026-09-26T24:00:00Z", "2026-9-26T00:00:00Z",
                     "2026-09-26T00:00:00.000Z", ""] {
            try check(!isValidObtainedAt(text), "\(text) should be rejected")
        }
    }),
    ("source definitions: public URLs must be clean https; credentialed sources carry none", { _ in
        func definition(_ access: SourceAccess, _ url: String?) -> SourceDefinition {
            SourceDefinition(sourceID: "x", provider: "x", license: "x", dataset: "x", resource: "x", access: access, url: url)
        }
        try definition(.publicURL, "https://example.invalid/a.zip").validate()
        try definition(.credentialed, nil).validate()
        for url in ["http://example.invalid/a.zip", "https://user:pw@example.invalid/a.zip",
                    "https://user@example.invalid/a.zip", "https://example.invalid/a.zip?sig=x",
                    "https://example.invalid/a.zip#part", "https:///a.zip"] {
            do {
                try definition(.publicURL, url).validate()
                throw TestFailure(message: "\(url) was accepted")
            } catch is IntakeError {}
        }
        for bad in [definition(.publicURL, nil), definition(.credentialed, "https://example.invalid/a.zip")] {
            do {
                try bad.validate()
                throw TestFailure(message: "an invalid definition was accepted")
            } catch is IntakeError {}
        }
        for source in SourceList.all { try source.validate() }
    }),
    ("manifest encoding is deterministic and holds only the approved fields", { _ in
        let manifest = SourceManifest(
            manifestVersion: 1, sourceID: "s", provider: "p", license: "l", dataset: "d", resource: "r",
            sourceAccess: .credentialed, sourceURL: nil, archiveSHA256: "00", archiveByteCount: 1,
            obtainedAt: "2099-01-02T03:04:05Z", obtainedAtBasis: "declared", feedVersion: nil,
            feedStartDate: nil, feedEndDate: nil,
            selectedMembers: [.init(name: "agency.txt", byteCount: 1, sha256: "00")], unselectedMembers: []
        )
        try check(manifest.encoded() == manifest.encoded(), "encoding differs between calls")
        let keys = Set((try JSONSerialization.jsonObject(with: manifest.encoded()) as! [String: Any]).keys)
        try check(keys == ["manifestVersion", "sourceID", "provider", "license", "dataset", "resource", "sourceAccess",
                           "archiveSHA256", "archiveByteCount", "obtainedAt", "obtainedAtBasis",
                           "selectedMembers", "unselectedMembers"], "\(keys.sorted())")
    }),
]

let integrationTests: [TestCase] = [
    ("a valid archive publishes the expected manifest", { workspace in
        let entries = SyntheticFeed.entries()
        let archiveData = ZipWriter.archive(entries)
        let archive = try workspace.write(archiveData)
        let output = workspace.output.appendingPathComponent("manifest.json")
        guard case .success(let result) = await intake(archive: archive, output: output) else {
            throw TestFailure(message: "the intake failed")
        }
        let manifest = result.manifest
        try check(manifest.archiveSHA256 == sha256Hex(archiveData), "archive hash")
        try check(manifest.archiveByteCount == Int64(archiveData.count), "archive size")
        try check(manifest.obtainedAt == "2099-01-02T03:04:05Z" && manifest.obtainedAtBasis == "declared", "obtained-at")
        try check(manifest.sourceURL == testSource.url && manifest.sourceAccess == .publicURL, "source URL")
        try check(manifest.feedVersion == "syn-1" && manifest.feedStartDate == "20990101", "feed info")
        let expected = SyntheticFeed.tables.keys.sorted().map { name in
            SourceManifest.SelectedMember(
                name: name,
                byteCount: SyntheticFeed.tables[name]!.utf8.count,
                sha256: sha256Hex(Data(SyntheticFeed.tables[name]!.utf8))
            )
        }
        try check(manifest.selectedMembers == expected, "selected members: \(manifest.selectedMembers)")
        try check(manifest.unselectedMembers == [SyntheticFeed.extraName], "unselected: \(manifest.unselectedMembers)")
        try check(result.feed.stops.count == 2 && result.feed.stopTimes.count == 2, "reader result")
        try check(try Data(contentsOf: output) == manifest.encoded(), "published bytes")
        try check(try workspace.outputEntries() == ["manifest.json"], "no temporary file remains")
    }),
    ("two runs on the same input publish byte-identical manifests", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        let first = workspace.output.appendingPathComponent("first.json")
        let second = workspace.output.appendingPathComponent("second.json")
        guard case .success = await intake(archive: archive, output: first),
              case .success = await intake(archive: archive, output: second) else {
            throw TestFailure(message: "an intake failed")
        }
        try check(try Data(contentsOf: first) == (try Data(contentsOf: second)), "manifests differ")
    }),
    ("each unsafe name rejects the archive before anything is streamed", { workspace in
        for (index, name) in ["dir/x.txt", "../evil.txt", "/abs.txt", ".hidden", "ctl\u{01}.txt",
                              "日本.txt", "back\\slash.txt"].enumerated() {
            let archive = try workspace.write(
                ZipWriter.archive(SyntheticFeed.entries() + [ZipEntry(name, Data("x".utf8))]), named: "unsafe\(index).zip")
            var streamed = 0
            var hooks = IntakeTestHooks()
            hooks.didStreamMember = { _ in streamed += 1 }
            let result = await intake(archive: archive, output: workspace.output.appendingPathComponent("m.json"), hooks: hooks)
            guard case .failure(let error) = result, case .unsafeMemberName = error else {
                throw TestFailure(message: "\(name.debugDescription) was not rejected as unsafe: \(result)")
            }
            try check(streamed == 0, "\(name.debugDescription): a member was streamed")
        }
        let folder = try workspace.write(ZipWriter.archive(SyntheticFeed.entries() + [.folder("folder/")]), named: "folder.zip")
        let result = await intake(archive: folder, output: workspace.output.appendingPathComponent("m.json"))
        guard case .failure(.unsafeMemberName) = result else { throw TestFailure(message: "folder entry: \(result)") }
        try check(try workspace.outputEntries().isEmpty, "output after rejection")
    }),
    ("a duplicated name rejects the archive before anything is streamed", { workspace in
        let entries = SyntheticFeed.entries() + [ZipEntry("agency.txt", Data("agency_name\nOther\n".utf8))]
        let archive = try workspace.write(ZipWriter.archive(entries))
        var streamed = 0
        var hooks = IntakeTestHooks()
        hooks.didStreamMember = { _ in streamed += 1 }
        try await expectFailure(.duplicateMember(name: "agency.txt"), in: workspace, archive: archive, hooks: hooks)
        try check(streamed == 0, "a member was streamed")
    }),
    ("a missing required table rejects the archive", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries(removing: ["trips.txt"])))
        try await expectFailure(.missingRequiredMember(name: "trips.txt"), in: workspace, archive: archive)
    }),
    ("a CRC error in a selected member rejects the archive", { workspace in
        var entries = SyntheticFeed.entries()
        let index = entries.firstIndex { $0.name == Array("stops.txt".utf8) }!
        entries[index].recordedCRC = ZipWriter.crc32(entries[index].data) ^ 0x1
        let archive = try workspace.write(ZipWriter.archive(entries))
        try await expectFailure(.memberStreamFailed(name: "stops.txt", status: 1), in: workspace, archive: archive)
    }),
    ("an archive truncated inside a selected member is rejected", { workspace in
        let full = ZipWriter.archive(SyntheticFeed.entries())
        // trips.txt is the last entry; cut the archive inside its data, which
        // also removes the central directory.
        let marker = Data("syn-r1,syn-weekday,syn-t1".utf8)
        let cut = full.range(of: marker)!.lowerBound + 10
        let archive = try workspace.write(full.prefix(upTo: cut))
        let result = await intake(archive: archive, output: workspace.output.appendingPathComponent("m.json"))
        switch result {
        case .failure(.listingFailed), .failure(.memberStreamFailed): break
        default: throw TestFailure(message: "truncation was not rejected: \(result)")
        }
        try check(try workspace.outputEntries().isEmpty, "output after truncation")
    }),
    ("a damaged unselected member is accepted and recorded by name only", { workspace in
        var entries = SyntheticFeed.entries()
        let index = entries.firstIndex { $0.name == Array(SyntheticFeed.extraName.utf8) }!
        entries[index].recordedCRC = ZipWriter.crc32(entries[index].data) ^ 0x1
        let archive = try workspace.write(ZipWriter.archive(entries))
        guard case .success(let result) = await intake(archive: archive, output: workspace.output.appendingPathComponent("m.json")) else {
            throw TestFailure(message: "the intake failed")
        }
        try check(result.manifest.unselectedMembers == [SyntheticFeed.extraName], "unselected")
        try check(!result.manifest.selectedMembers.contains { $0.name == SyntheticFeed.extraName }, "it was read")
    }),
    ("an archive over its limit fails", { workspace in
        let data = ZipWriter.archive(SyntheticFeed.entries())
        let archive = try workspace.write(data)
        var limits = IntakeLimits.standard
        limits.archiveBytes = Int64(data.count - 1)
        try await expectFailure(.archiveTooLarge(byteCount: Int64(data.count)), in: workspace, archive: archive, limits: limits)
    }),
    ("a selected member over its limit fails", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        // Members stream in name order; the limit sits one byte under the
        // largest, which is therefore the member that exceeds it.
        let largest = SyntheticFeed.tables.max { $0.value.utf8.count < $1.value.utf8.count }!
        var limits = IntakeLimits.standard
        limits.memberBytes = largest.value.utf8.count - 1
        try await expectFailure(.memberTooLarge(name: largest.key), in: workspace, archive: archive, limits: limits)
    }),
    ("selected members together over their limit fail", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        var limits = IntakeLimits.standard
        limits.selectedTotalBytes = SyntheticFeed.tables.values.reduce(0) { $0 + $1.utf8.count } - 1
        try await expectFailure(.selectedMembersTooLarge, in: workspace, archive: archive, limits: limits)
    }),
    ("a reader rejection fails the intake, keeping invalid and unsupported apart", { workspace in
        let invalid = try workspace.write(ZipWriter.archive(SyntheticFeed.entries(replacing: [
            "trips.txt": "route_id,service_id,trip_id\nsyn-r9,syn-weekday,syn-t1\n",
        ])), named: "invalid.zip")
        try await expectFailure(
            .readerInvalid(.unresolvedReference(column: "route_id", value: "syn-r9"), at: GTFSSourceLocation(table: .trips, line: 2)),
            in: workspace, archive: invalid)
        let unsupported = try workspace.write(ZipWriter.archive(SyntheticFeed.entries(replacing: [
            "routes.txt": "route_id,route_long_name,route_type\nsyn-r1,Synthetic Line,1\n\n",
        ])), named: "unsupported.zip")
        try await expectFailure(
            .readerUnsupported(.blankLine, at: GTFSSourceLocation(table: .routes, line: 3)),
            in: workspace, archive: unsupported)
    }),
    ("an existing output file is never overwritten", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        let target = workspace.output.appendingPathComponent("manifest.json")
        try Data("keep".utf8).write(to: target)
        try await expectFailure(.outputExists, in: workspace, archive: archive, output: target)
        try check(try Data(contentsOf: target) == Data("keep".utf8), "the existing file changed")
    }),
    ("a file created after the preliminary check wins the publication race", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        let target = workspace.output.appendingPathComponent("manifest.json")
        var hooks = IntakeTestHooks()
        hooks.beforePublication = { try? Data("other".utf8).write(to: target) }
        let result = await intake(archive: archive, output: target, hooks: hooks)
        guard case .failure(.outputExists) = result else { throw TestFailure(message: "race: \(result)") }
        try check(try Data(contentsOf: target) == Data("other".utf8), "the racing file was replaced")
        try check(try workspace.outputEntries() == ["manifest.json"], "a temporary file remains")
    }),
    ("an archive modified in place during intake fails", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        var hooks = IntakeTestHooks()
        hooks.afterStreaming = {
            let handle = try! FileHandle(forWritingTo: archive)
            try! handle.seekToEnd()
            try! handle.write(contentsOf: Data([0x00]))
            try! handle.close()
        }
        try await expectFailure(.inputChanged(reason: "the file's size or times changed"), in: workspace, archive: archive, hooks: hooks)
    }),
    ("an archive rewritten in place with the same size fails", { workspace in
        let data = ZipWriter.archive(SyntheticFeed.entries())
        let archive = try workspace.write(data)
        var hooks = IntakeTestHooks()
        hooks.afterStreaming = {
            let handle = try! FileHandle(forWritingTo: archive)
            try! handle.seek(toOffset: UInt64(data.count - 1))
            try! handle.write(contentsOf: Data([data.last! ^ 0xFF]))
            try! handle.close()
        }
        try await expectFailure(.inputChanged(reason: "the file's size or times changed"), in: workspace, archive: archive, hooks: hooks)
    }),
    ("an archive path replaced by another file during intake fails", { workspace in
        // Renaming a copy over the path also unlinks the original, which
        // changes its status-change time; either check may report it.
        let data = ZipWriter.archive(SyntheticFeed.entries())
        let archive = try workspace.write(data)
        var hooks = IntakeTestHooks()
        hooks.afterStreaming = {
            let replacement = workspace.archives.appendingPathComponent("replacement.zip")
            try! data.write(to: replacement)
            _ = rename(replacement.path, archive.path)
        }
        let result = await intake(archive: archive, output: workspace.output.appendingPathComponent("m.json"), hooks: hooks)
        guard case .failure(.inputChanged) = result else { throw TestFailure(message: "replacement: \(result)") }
        try check(try workspace.outputEntries().isEmpty, "output after a replaced archive")
    }),
    ("a symlinked archive path retargeted during intake fails the path-identity check", { workspace in
        // The original file is left untouched, so only the path check can
        // notice that the path now names a different file.
        let data = ZipWriter.archive(SyntheticFeed.entries())
        let original = try workspace.write(data, named: "original.zip")
        let copy = try workspace.write(data, named: "copy.zip")
        let link = workspace.archives.appendingPathComponent("current.zip")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: original)
        var hooks = IntakeTestHooks()
        hooks.afterStreaming = {
            let staged = workspace.archives.appendingPathComponent("staged-link.zip")
            try! FileManager.default.createSymbolicLink(at: staged, withDestinationURL: copy)
            _ = rename(staged.path, link.path)
        }
        try await expectFailure(.inputChanged(reason: "the path no longer names the same file"), in: workspace, archive: link, hooks: hooks)
    }),
    ("archive and output paths inside the repository are refused, including through symlinks", { workspace in
        let repositoryFile = URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs/ROADMAP.md")
        try await expectFailure(.pathInsideRepository(role: "archive"), in: workspace, archive: repositoryFile)
        let archiveLink = workspace.archives.appendingPathComponent("link.zip")
        try FileManager.default.createSymbolicLink(at: archiveLink, withDestinationURL: repositoryFile)
        try await expectFailure(.pathInsideRepository(role: "archive"), in: workspace, archive: archiveLink)

        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        let insideOutput = URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs/intake-test-never-written.json")
        try await expectFailure(.pathInsideRepository(role: "output"), in: workspace, archive: archive, output: insideOutput)
        let directoryLink = workspace.root.appendingPathComponent("docs-link")
        try FileManager.default.createSymbolicLink(
            at: directoryLink, withDestinationURL: URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs"))
        try await expectFailure(.pathInsideRepository(role: "output"), in: workspace, archive: archive,
                                output: directoryLink.appendingPathComponent("intake-test-never-written.json"))
        try check(!FileManager.default.fileExists(atPath: insideOutput.path), "a file was written into the repository")
    }),
    ("an output directory swapped for a repository symlink after its check cannot redirect the manifest", { workspace in
        // The checked directory is pinned by a descriptor, so the manifest is
        // written into it (now renamed) and never through the symlink.
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        let checked = workspace.root.appendingPathComponent("out-checked")
        let moved = workspace.root.appendingPathComponent("out-moved")
        try FileManager.default.createDirectory(at: checked, withIntermediateDirectories: false)
        let repositoryTarget = URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs/intake-race-never-written.json")
        var hooks = IntakeTestHooks()
        hooks.afterPathChecks = {
            _ = rename(checked.path, moved.path)
            try! FileManager.default.createSymbolicLink(
                at: checked, withDestinationURL: URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs"))
        }
        let result = await intake(archive: archive, output: checked.appendingPathComponent("intake-race-never-written.json"), hooks: hooks)
        let leaked = FileManager.default.fileExists(atPath: repositoryTarget.path)
        if leaked { try? FileManager.default.removeItem(at: repositoryTarget) }
        try check(!leaked, "the manifest was written into the repository")
        guard case .success = result else { throw TestFailure(message: "publication failed: \(result)") }
        try check(FileManager.default.fileExists(atPath: moved.appendingPathComponent("intake-race-never-written.json").path),
                  "the manifest is not in the pinned directory")
    }),
    ("an archive directory swapped for a repository symlink after its check is refused", { workspace in
        // The opened file itself is checked, so a repository file reached
        // through the swapped component is refused before it is read.
        let checked = workspace.root.appendingPathComponent("archive-checked")
        let moved = workspace.root.appendingPathComponent("archive-moved")
        try FileManager.default.createDirectory(at: checked, withIntermediateDirectories: false)
        let archive = checked.appendingPathComponent("ROADMAP.md")
        try ZipWriter.archive(SyntheticFeed.entries()).write(to: archive)
        var hooks = IntakeTestHooks()
        hooks.afterPathChecks = {
            _ = rename(checked.path, moved.path)
            try! FileManager.default.createSymbolicLink(
                at: checked, withDestinationURL: URL(fileURLWithPath: repositoryPath).appendingPathComponent("docs"))
        }
        try await expectFailure(.pathInsideRepository(role: "archive"), in: workspace, archive: archive, hooks: hooks)
    }),
    ("an archive replaced by another file between its check and its opening is refused", { workspace in
        let data = ZipWriter.archive(SyntheticFeed.entries())
        let archive = try workspace.write(data)
        var hooks = IntakeTestHooks()
        hooks.afterPathChecks = {
            let replacement = workspace.archives.appendingPathComponent("replacement.zip")
            try! data.write(to: replacement)
            _ = rename(replacement.path, archive.path)
        }
        try await expectFailure(.inputChanged(reason: "the path no longer names the same file"), in: workspace, archive: archive, hooks: hooks)
    }),
    ("an archive moved into the repository during intake is refused, even with its identity unchanged", { workspace in
        // A stand-in repository root inside the workspace, so nothing is ever
        // moved into the real repository.
        let standInRepository = workspace.root.appendingPathComponent("stand-in-repository")
        try FileManager.default.createDirectory(at: standInRepository, withIntermediateDirectories: false)
        let parent = workspace.root.appendingPathComponent("archive-parent")
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: false)
        let archive = parent.appendingPathComponent("feed.zip")
        try ZipWriter.archive(SyntheticFeed.entries()).write(to: archive)
        var hooks = IntakeTestHooks()
        hooks.afterStreaming = {
            let inside = standInRepository.appendingPathComponent("archive-parent")
            _ = rename(parent.path, inside.path)
            try! FileManager.default.createSymbolicLink(at: parent, withDestinationURL: inside)
        }
        let before = try workspace.outputEntries()
        let result = await intake(
            archive: archive, output: workspace.output.appendingPathComponent("m.json"),
            hooks: hooks, repositoryRoot: FileIdentity(path: standInRepository.path)!)
        guard case .failure(.pathInsideRepository(role: "archive")) = result else {
            throw TestFailure(message: "the moved archive was accepted: \(result)")
        }
        try check(try workspace.outputEntries() == before, "output after refusal")
    }),
    ("an archive that is not a regular file is refused, including a FIFO without blocking", { workspace in
        try await expectFailure(.archiveNotRegularFile, in: workspace, archive: workspace.archives)
        let fifo = workspace.archives.appendingPathComponent("feed.fifo")
        try check(mkfifo(fifo.path, 0o600) == 0, "mkfifo failed")
        try await expectFailure(.archiveNotRegularFile, in: workspace, archive: fifo)
    }),
    ("an invalid source URL is rejected and a credentialed source is recorded without one", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        for url in ["https://user@example.invalid/a.zip", "https://example.invalid/a.zip?sig=x", "https://example.invalid/a.zip#f"] {
            let source = SourceDefinition(sourceID: "x", provider: "x", license: "x", dataset: "x", resource: "x", access: .publicURL, url: url)
            let result = await intake(archive: archive, output: workspace.output.appendingPathComponent("m.json"), source: source)
            guard case .failure(.invalidSourceDefinition) = result else { throw TestFailure(message: "\(url): \(result)") }
        }
        try check(try workspace.outputEntries().isEmpty, "output after rejection")
        let credentialed = SourceDefinition(sourceID: "c", provider: "p", license: "l", dataset: "d", resource: "r", access: .credentialed, url: nil)
        let output = workspace.output.appendingPathComponent("credentialed.json")
        guard case .success(let result) = await intake(archive: archive, output: output, source: credentialed) else {
            throw TestFailure(message: "the credentialed intake failed")
        }
        try check(result.manifest.sourceURL == nil && result.manifest.sourceAccess == .credentialed, "credentialed manifest")
        let json = String(decoding: try Data(contentsOf: output), as: UTF8.self)
        try check(!json.contains("sourceURL") && !json.contains("https://"), "a URL was recorded")
    }),
    ("an invalid obtained-at is rejected", { workspace in
        let archive = try workspace.write(ZipWriter.archive(SyntheticFeed.entries()))
        try await expectFailure(.invalidObtainedAt, in: workspace, archive: archive, obtainedAt: "2099-01-02T03:04:05+09:00")
    }),
]
