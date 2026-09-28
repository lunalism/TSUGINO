import Foundation

// Reading one identified GTFS archive (DEC-066 §C–§E): intake stages 3–7,
// shared by the intake and the provisional-registry command so both read an
// archive exactly the same way.
// 3. open the archive once; check the opened file itself against the
//    repository boundary and the checked path; check its limit; hash it;
// 4. list it; name policy and duplicates; required tables;
// 5. stream each selected member under the limits;
// 6. run the unchanged P2-S1 reader;
// 7. recheck descriptor state, archive bytes, and path identity.

struct IdentifiedArchive {
    let sha256: String
    let byteCount: Int64
    /// Sorted by name, with each member's size and SHA-256.
    let selectedMembers: [SourceManifest.SelectedMember]
    let unselectedMembers: [String]
    let feed: GTFSStaticFeed

    func memberSHA256(_ name: String) -> String? {
        selectedMembers.first { $0.name == name }?.sha256
    }
}

enum ArchiveReading {
    /// Resolves an input path and checks it against the repository boundary
    /// (DEC-066 §B), before anything is opened.
    static func checkedPath(_ path: String, role: String, repositoryRoot: FileIdentity) throws(IntakeError) -> (resolved: String, identity: FileIdentity) {
        guard let resolved = resolvedPath(path) else { throw .pathUnavailable(role: role, errno: errno) }
        guard !isInsideRepository(resolved, repositoryRoot: repositoryRoot) else { throw .pathInsideRepository(role: role) }
        guard let identity = FileIdentity(path: resolved) else { throw .pathUnavailable(role: role, errno: errno) }
        return (resolved, identity)
    }

    static func read(
        requestedPath: String,
        resolvedPath archivePath: String,
        checked checkedArchive: FileIdentity,
        repositoryRoot: FileIdentity,
        limits: IntakeLimits,
        didStreamMember: ((String) -> Void)? = nil,
        afterStreaming: (() -> Void)? = nil
    ) async throws(IntakeError) -> IdentifiedArchive {
        // 3. One descriptor for the whole read. The file actually opened is
        // checked, so a path component swapped after the path check cannot
        // bring a repository file (or any other file) into the read.
        let archive = try ArchiveFile(resolvedPath: archivePath, limit: limits.archiveBytes)
        guard let openedPath = descriptorPath(archive.descriptor),
              !isInsideRepository(openedPath, repositoryRoot: repositoryRoot) else {
            throw .pathInsideRepository(role: "archive")
        }
        guard FileIdentity(device: archive.initialState.device, inode: archive.initialState.inode) == checkedArchive else {
            throw .inputChanged(reason: "the path no longer names the same file")
        }
        let (archiveSHA256, archiveByteCount) = try archive.sha256()

        // 4. Listing and name policy, before anything is streamed.
        let names = try Bsdtar.list(archive, limits: limits)
        let (selected, unselected) = try MemberPolicy.partition(names)

        // 5. Selected members only, under the limits.
        var memberBytes: [String: Data] = [:]
        var selectedMembers: [SourceManifest.SelectedMember] = []
        var total = 0
        for name in selected {
            let bytes = try Bsdtar.stream(
                name,
                from: archive,
                limits: limits,
                remainingTotal: limits.selectedTotalBytes - total
            )
            didStreamMember?(name)
            total += bytes.count
            memberBytes[name] = bytes
            selectedMembers.append(.init(name: name, byteCount: bytes.count, sha256: sha256Hex(bytes)))
        }
        afterStreaming?()

        // 6. The unchanged P2-S1 reader.
        let texts = GTFSStaticTableTexts(
            agency: memberBytes["agency.txt"]!,
            stops: memberBytes["stops.txt"]!,
            routes: memberBytes["routes.txt"]!,
            trips: memberBytes["trips.txt"]!,
            stopTimes: memberBytes["stop_times.txt"]!,
            calendar: memberBytes["calendar.txt"],
            calendarDates: memberBytes["calendar_dates.txt"],
            feedInfo: memberBytes["feed_info.txt"],
            translations: memberBytes["translations.txt"]
        )
        let feed: GTFSStaticFeed
        do {
            feed = try await GTFSStaticTableReader.read(texts)
        } catch {
            switch error {
            case .invalid(let reason, let location): throw .readerInvalid(reason, at: location)
            case .unsupported(let reason, let location): throw .readerUnsupported(reason, at: location)
            }
        }

        // 7. The bytes hashed are the bytes processed.
        guard let finalState = ArchiveFile.state(of: archive.descriptor), finalState == archive.initialState else {
            throw .inputChanged(reason: "the file's size or times changed")
        }
        guard try archive.sha256().hex == archiveSHA256 else {
            throw .inputChanged(reason: "the file's bytes changed")
        }
        guard let currentPath = resolvedPath(requestedPath),
              let currentIdentity = FileIdentity(path: currentPath),
              currentIdentity == FileIdentity(device: archive.initialState.device, inode: archive.initialState.inode)
        else {
            throw .inputChanged(reason: "the path no longer names the same file")
        }
        // The same file may have been moved into the repository during the
        // read; the boundary is checked again, by path and by descriptor.
        guard !isInsideRepository(currentPath, repositoryRoot: repositoryRoot),
              let openedNow = descriptorPath(archive.descriptor),
              !isInsideRepository(openedNow, repositoryRoot: repositoryRoot) else {
            throw .pathInsideRepository(role: "archive")
        }

        return IdentifiedArchive(
            sha256: archiveSHA256, byteCount: archiveByteCount,
            selectedMembers: selectedMembers, unselectedMembers: unselected, feed: feed
        )
    }
}
