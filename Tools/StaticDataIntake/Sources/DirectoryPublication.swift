import Foundation

// Atomic publication of several files as one new directory, never replacing
// anything — the provisional-registry command's output contract.
//
// A single-file rename cannot publish a pair atomically, so the pair is one
// directory. Built on `ManifestPublication`'s approach (DEC-066 §F):
// 1. the checked parent directory is pinned by a descriptor; its identity
//    must equal the checked path's, and it must lie outside the repository;
// 2. a temporary directory is created in it with `mkdirat` under a random
//    name, mode 0700, and pinned by its own descriptor;
// 3. each file is created in it with `openat(O_CREAT | O_EXCL)`, written,
//    `fsync`ed, and closed; then the temporary directory is `fsync`ed;
// 4. the parent is checked again to lie outside the repository;
// 5. `renameatx_np(RENAME_EXCL)` moves the temporary directory onto the
//    target name, which fails if anything of that name exists — so the
//    target either appears complete, with every file, or not at all;
// 6. the parent is `fsync`ed so the new entry is durable.
// On every failure before step 5, each file written and the temporary
// directory are removed through the pinned descriptors, and nothing is
// published. After step 5 the directory is complete; a failed parent `fsync`
// is reported, and the directory is left in place.

final class DirectoryPublication {
    let name: String
    private let parent: Int32
    private let repositoryRoot: FileIdentity

    #if INTAKE_TESTING
    /// Runs after the first file is written, before the rest; a throw
    /// simulates a failure part-way through publication.
    var afterFirstFile: (() throws -> Void)?
    /// Runs just before the rename.
    var beforeRename: (() -> Void)?
    #endif

    init(checkedDirectory: String, name: String, repositoryRoot: FileIdentity) throws(IntakeError) {
        let parent = open(checkedDirectory, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
        guard parent >= 0 else { throw .pathUnavailable(role: "output directory", errno: errno) }
        self.name = name
        self.parent = parent
        self.repositoryRoot = repositoryRoot
        guard let checked = FileIdentity(path: checkedDirectory),
              FileIdentity(descriptor: parent) == checked else {
            throw .outputDirectoryChanged
        }
        try requireOutsideRepository()
    }

    deinit {
        close(parent)
    }

    func requireOutsideRepository() throws(IntakeError) {
        guard let path = descriptorPath(parent) else { throw .outputDirectoryChanged }
        guard !isInsideRepository(path, repositoryRoot: repositoryRoot) else {
            throw .pathInsideRepository(role: "output")
        }
    }

    /// An early check for a clearer message only; never relied on for safety.
    func targetExists() -> Bool {
        var info = stat()
        return fstatat(parent, name, &info, AT_SYMLINK_NOFOLLOW) == 0
    }

    /// Publishes `files` (name → bytes; flat, distinct names) as the new
    /// directory `name`.
    func publish(_ files: [(name: String, data: Data)], ownerOnlyFiles: Bool = false) throws(IntakeError) {
        let temporaryName = ".static-data-intake-\(UUID().uuidString).tmp"
        guard mkdirat(parent, temporaryName, 0o700) == 0 else { throw .publicationFailed(errno: errno) }
        let directory = openat(parent, temporaryName, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
        guard directory >= 0 else {
            let error = errno
            unlinkat(parent, temporaryName, AT_REMOVEDIR)
            throw .publicationFailed(errno: error)
        }
        var written: [String] = []
        func discard() {
            for file in written { unlinkat(directory, file, 0) }
            close(directory)
            unlinkat(parent, temporaryName, AT_REMOVEDIR)
        }

        for (index, file) in files.enumerated() {
            let descriptor = openat(directory, file.name, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, ownerOnlyFiles ? 0o600 : 0o644)
            guard descriptor >= 0 else {
                let error = errno
                discard()
                throw .publicationFailed(errno: error)
            }
            written.append(file.name)
            var failure: Int32?
            let complete = file.data.withUnsafeBytes { buffer -> Bool in
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
            if complete, fsync(descriptor) != 0 { failure = errno }
            if close(descriptor) != 0, failure == nil { failure = errno }
            if let failure {
                discard()
                throw .publicationFailed(errno: failure)
            }
            #if INTAKE_TESTING
            if index == 0, let afterFirstFile {
                do {
                    try afterFirstFile()
                } catch {
                    discard()
                    throw .publicationFailed(errno: EIO)
                }
            }
            #else
            _ = index
            #endif
        }
        if fsync(directory) != 0 {
            let error = errno
            discard()
            throw .publicationFailed(errno: error)
        }

        do {
            try requireOutsideRepository()
        } catch {
            discard()
            throw error
        }
        #if INTAKE_TESTING
        beforeRename?()
        #endif

        guard renameatx_np(parent, temporaryName, parent, name, UInt32(RENAME_EXCL)) == 0 else {
            let error = errno
            discard()
            throw error == EEXIST ? .outputExists : .publicationFailed(errno: error)
        }
        close(directory)

        // The directory is complete and visible; make its entry durable, and
        // report — never delete — if that fails.
        if fsync(parent) != 0 {
            throw .publishedWithoutDurableDirectory(errno: errno)
        }
    }
}
