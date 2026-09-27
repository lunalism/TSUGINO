import Foundation

// Atomic publication that never replaces a file (DEC-066 §F).
//
// The checked output directory is pinned by a descriptor as soon as it has
// been checked, and every later step works relative to that descriptor, so
// replacing a path component with a symlink cannot redirect the manifest:
// 1. open the directory once; its identity must equal the checked path's, and
//    the descriptor's own current path must lie outside the repository;
// 2. create a temporary file in it with openat(O_CREAT | O_EXCL) under a
//    random name, write the manifest, fsync, close;
// 3. check again that the directory lies outside the repository;
// 4. renameatx_np(RENAME_EXCL) onto the target name, which fails with EEXIST
//    if any file of that name exists at that moment — no ordinary-rename
//    fallback exists;
// 5. fsync the directory so the new entry is durable.
// On every failure before step 4 the temporary file is removed and nothing is
// published. After step 4 the manifest is complete (its bytes were fsynced
// in step 2); a failed directory fsync is reported, and the file is left in
// place, because no name-based removal could be sure to remove only it.

final class ManifestPublication {
    let name: String
    private let directory: Int32
    private let repositoryRoot: FileIdentity

    init(checkedDirectory: String, name: String, repositoryRoot: FileIdentity) throws(IntakeError) {
        let directory = open(checkedDirectory, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
        guard directory >= 0 else { throw .pathUnavailable(role: "output directory", errno: errno) }
        self.name = name
        self.directory = directory
        self.repositoryRoot = repositoryRoot
        guard let checked = FileIdentity(path: checkedDirectory),
              FileIdentity(descriptor: directory) == checked else {
            throw .outputDirectoryChanged
        }
        try requireOutsideRepository()
    }

    deinit {
        close(directory)
    }

    /// Fails unless the pinned directory, as it is named now, lies outside
    /// the repository.
    func requireOutsideRepository() throws(IntakeError) {
        guard let path = descriptorPath(directory) else { throw .outputDirectoryChanged }
        guard !isInsideRepository(path, repositoryRoot: repositoryRoot) else {
            throw .pathInsideRepository(role: "output")
        }
    }

    /// An early check for a clearer message only; never relied on for safety.
    func targetExists() -> Bool {
        var info = stat()
        return fstatat(directory, name, &info, AT_SYMLINK_NOFOLLOW) == 0
    }

    func publish(_ data: Data) throws(IntakeError) {
        let temporaryName = ".static-data-intake-\(UUID().uuidString).tmp"
        let descriptor = openat(directory, temporaryName, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0o644)
        guard descriptor >= 0 else { throw .publicationFailed(errno: errno) }

        var failure: Int32?
        let written = data.withUnsafeBytes { buffer -> Bool in
            var offset = 0
            while offset < buffer.count {
                let count = write(descriptor, buffer.baseAddress! + offset, buffer.count - offset)
                if count < 0 {
                    if errno == EINTR { continue }
                    failure = errno
                    return false
                }
                offset += count
            }
            return true
        }
        if written, fsync(descriptor) != 0 { failure = errno }
        if close(descriptor) != 0, failure == nil { failure = errno }
        if let failure {
            unlinkat(directory, temporaryName, 0)
            throw .publicationFailed(errno: failure)
        }

        do {
            try requireOutsideRepository()
        } catch {
            unlinkat(directory, temporaryName, 0)
            throw error
        }

        guard renameatx_np(directory, temporaryName, directory, name, UInt32(RENAME_EXCL)) == 0 else {
            let error = errno
            unlinkat(directory, temporaryName, 0)
            throw error == EEXIST ? .outputExists : .publicationFailed(errno: error)
        }

        // The rename is visible and the manifest complete; make the directory
        // entry durable, and report — never delete — if that fails.
        if fsync(directory) != 0 {
            throw .publishedWithoutDurableDirectory(errno: errno)
        }
    }
}
