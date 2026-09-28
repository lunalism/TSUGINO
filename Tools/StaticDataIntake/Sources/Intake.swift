import Foundation

// Orchestrates one intake (DEC-066). Stages run in a fixed order and any
// failure publishes nothing:
// 1. source definition and obtained-at checks;
// 2. repository-boundary checks for the archive and the output location;
//    the output directory is pinned by a descriptor as it is checked;
// 3. open the archive once; check the opened file itself against the
//    repository boundary and the checked path; check its limit; hash it;
// 4. list it; name policy and duplicates; required tables;
// 5. stream each selected member under the limits;
// 6. run the unchanged P2-S1 reader;
// 7. recheck descriptor state, archive bytes, and path identity;
// 8. publish the manifest without ever replacing a file.

struct IntakeRequest {
    let source: SourceDefinition
    let archivePath: String
    let outputPath: String
    let obtainedAt: String
}

struct IntakeResult {
    let manifest: SourceManifest
    let feed: GTFSStaticFeed
}

#if INTAKE_TESTING
/// Injection points between stages. They exist only in the test runner's
/// build; the operator's tool has none (DEC-066 §H).
struct IntakeTestHooks {
    var afterPathChecks: (() -> Void)?
    var didStreamMember: ((String) -> Void)?
    var afterStreaming: (() -> Void)?
    var beforePublication: (() -> Void)?
}
#endif

enum StaticDataIntake {
    /// The operator's entry point: the standard limits and no hooks. This is
    /// the only entry point in the operator's build.
    static func run(_ request: IntakeRequest, repositoryRoot: FileIdentity) async throws(IntakeError) -> IntakeResult {
        try await body(request, repositoryRoot, .standard, nil, nil, nil, nil)
    }

    #if INTAKE_TESTING
    /// The test runner's entry point, with test limits and hooks.
    static func run(
        _ request: IntakeRequest,
        repositoryRoot: FileIdentity,
        limits: IntakeLimits,
        hooks: IntakeTestHooks
    ) async throws(IntakeError) -> IntakeResult {
        try await body(
            request, repositoryRoot, limits,
            hooks.afterPathChecks, hooks.didStreamMember, hooks.afterStreaming, hooks.beforePublication
        )
    }
    #endif

    private static func body(
        _ request: IntakeRequest,
        _ repositoryRoot: FileIdentity,
        _ limits: IntakeLimits,
        _ afterPathChecks: (() -> Void)?,
        _ didStreamMember: ((String) -> Void)?,
        _ afterStreaming: (() -> Void)?,
        _ beforePublication: (() -> Void)?
    ) async throws(IntakeError) -> IntakeResult {
        // 1. Inputs that need no file system.
        try request.source.validate()
        guard isValidObtainedAt(request.obtainedAt) else { throw .invalidObtainedAt }

        // 2. Repository boundary, after resolving symlinks.
        guard let archivePath = resolvedPath(request.archivePath) else {
            throw .pathUnavailable(role: "archive", errno: errno)
        }
        guard !isInsideRepository(archivePath, repositoryRoot: repositoryRoot) else {
            throw .pathInsideRepository(role: "archive")
        }
        guard let checkedArchive = FileIdentity(path: archivePath) else {
            throw .pathUnavailable(role: "archive", errno: errno)
        }
        let outputName = (request.outputPath as NSString).lastPathComponent
        guard !outputName.isEmpty, outputName != ".", outputName != "..", !request.outputPath.hasSuffix("/") else {
            throw .outputNameInvalid
        }
        let requestedDirectory = (request.outputPath as NSString).deletingLastPathComponent
        guard let outputDirectory = resolvedPath(requestedDirectory.isEmpty ? "." : requestedDirectory) else {
            throw .pathUnavailable(role: "output directory", errno: errno)
        }
        guard !isInsideRepository(outputDirectory, repositoryRoot: repositoryRoot) else {
            throw .pathInsideRepository(role: "output")
        }
        let publication = try ManifestPublication(
            checkedDirectory: outputDirectory, name: outputName, repositoryRoot: repositoryRoot)
        // An early message only; publication itself never replaces a file.
        guard !publication.targetExists() else { throw .outputExists }
        afterPathChecks?()

        // 3–7. Open, hash, list, stream, read, and recheck the archive.
        let read = try await ArchiveReading.read(
            requestedPath: request.archivePath, resolvedPath: archivePath, checked: checkedArchive,
            repositoryRoot: repositoryRoot, limits: limits,
            didStreamMember: didStreamMember, afterStreaming: afterStreaming
        )
        let feed = read.feed

        // 8. Publication.
        let info = feed.feedInfo.first
        let manifest = SourceManifest(
            manifestVersion: SourceManifest.currentVersion,
            sourceID: request.source.sourceID,
            provider: request.source.provider,
            license: request.source.license,
            dataset: request.source.dataset,
            resource: request.source.resource,
            sourceAccess: request.source.access,
            sourceURL: request.source.access == .publicURL ? request.source.url : nil,
            archiveSHA256: read.sha256,
            archiveByteCount: read.byteCount,
            obtainedAt: request.obtainedAt,
            obtainedAtBasis: "declared",
            feedVersion: info?.version,
            feedStartDate: info?.startDate,
            feedEndDate: info?.endDate,
            selectedMembers: read.selectedMembers,
            unselectedMembers: read.unselectedMembers
        )
        beforePublication?()
        try publication.publish(manifest.encoded())
        return IntakeResult(manifest: manifest, feed: feed)
    }
}
