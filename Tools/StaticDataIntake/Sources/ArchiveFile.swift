import CryptoKit
import Foundation

// The archive is opened once and used only through that descriptor
// (DEC-066 §D). Hashing uses `pread`, which never moves the shared file
// offset; before each `bsdtar` run the offset is reset to 0, because the
// child shares this descriptor's open file description through `/dev/fd/3`.

/// Identity and state of the opened archive, as `fstat` reports them.
struct ArchiveState: Equatable {
    let device: dev_t
    let inode: ino_t
    let byteCount: Int64
    let modified: timespec
    let statusChanged: timespec

    static func == (lhs: ArchiveState, rhs: ArchiveState) -> Bool {
        lhs.device == rhs.device && lhs.inode == rhs.inode && lhs.byteCount == rhs.byteCount
            && lhs.modified.tv_sec == rhs.modified.tv_sec && lhs.modified.tv_nsec == rhs.modified.tv_nsec
            && lhs.statusChanged.tv_sec == rhs.statusChanged.tv_sec
            && lhs.statusChanged.tv_nsec == rhs.statusChanged.tv_nsec
    }
}

final class ArchiveFile {
    let descriptor: Int32
    let initialState: ArchiveState

    /// Opens `resolvedPath` read-only and refuses anything that is not a
    /// regular file or that exceeds `limit`.
    init(resolvedPath: String, limit: Int64) throws(IntakeError) {
        // O_NONBLOCK keeps a FIFO from blocking here before fstat rejects it;
        // it has no effect on reading a regular file.
        let descriptor = open(resolvedPath, O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK)
        guard descriptor >= 0 else { throw .pathUnavailable(role: "archive", errno: errno) }
        guard let state = Self.state(of: descriptor) else {
            let error = errno
            close(descriptor)
            throw .archiveReadFailed(errno: error)
        }
        var info = stat()
        fstat(descriptor, &info)
        guard (info.st_mode & S_IFMT) == S_IFREG else {
            close(descriptor)
            throw .archiveNotRegularFile
        }
        guard state.byteCount <= limit else {
            close(descriptor)
            throw .archiveTooLarge(byteCount: state.byteCount)
        }
        self.descriptor = descriptor
        self.initialState = state
    }

    deinit {
        close(descriptor)
    }

    static func state(of descriptor: Int32) -> ArchiveState? {
        var info = stat()
        guard fstat(descriptor, &info) == 0 else { return nil }
        return ArchiveState(
            device: info.st_dev,
            inode: info.st_ino,
            byteCount: info.st_size,
            modified: info.st_mtimespec,
            statusChanged: info.st_ctimespec
        )
    }

    /// SHA-256 of every byte from offset 0 to end of file, read with `pread`.
    func sha256() throws(IntakeError) -> (hex: String, byteCount: Int64) {
        var hasher = SHA256()
        var offset: off_t = 0
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 1024 * 1024, alignment: 1)
        defer { buffer.deallocate() }
        while true {
            let count = pread(descriptor, buffer.baseAddress, buffer.count, offset)
            if count < 0 {
                if errno == EINTR { continue }
                throw .archiveReadFailed(errno: errno)
            }
            if count == 0 { break }
            hasher.update(bufferPointer: UnsafeRawBufferPointer(rebasing: buffer[0..<count]))
            offset += off_t(count)
        }
        return (hexString(hasher.finalize()), Int64(offset))
    }

    /// Resets the shared offset before a child reads the descriptor.
    func rewind() throws(IntakeError) {
        guard lseek(descriptor, 0, SEEK_SET) == 0 else { throw .archiveReadFailed(errno: errno) }
    }
}

func hexString<D: Sequence>(_ digest: D) -> String where D.Element == UInt8 {
    digest.map { String(format: "%02x", $0) }.joined()
}

func sha256Hex(_ data: Data) -> String {
    hexString(SHA256.hash(data: data))
}

// MARK: - Repository boundary (DEC-066 §B)

/// A file-system identity: device and inode.
struct FileIdentity: Equatable {
    let device: dev_t
    let inode: ino_t

    init(device: dev_t, inode: ino_t) {
        self.device = device
        self.inode = inode
    }

    init?(path: String) {
        var info = stat()
        guard stat(path, &info) == 0 else { return nil }
        device = info.st_dev
        inode = info.st_ino
    }

    init?(descriptor: Int32) {
        var info = stat()
        guard fstat(descriptor, &info) == 0 else { return nil }
        device = info.st_dev
        inode = info.st_ino
    }
}

/// The current path of the file an open descriptor refers to (`F_GETPATH`).
/// Checking this path, rather than the path that was opened, leaves no gap
/// between a boundary check and the file actually used.
func descriptorPath(_ descriptor: Int32) -> String? {
    var buffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
    guard fcntl(descriptor, F_GETPATH, &buffer) == 0 else { return nil }
    return String(cString: buffer)
}

/// `path` with every symlink resolved, or `nil` when it does not exist.
func resolvedPath(_ path: String) -> String? {
    guard let pointer = realpath(path, nil) else { return nil }
    defer { free(pointer) }
    return String(cString: pointer)
}

/// True when `repositoryRoot` is `resolvedPath` itself or one of its
/// ancestors, compared by device and inode.
func isInsideRepository(_ resolvedPath: String, repositoryRoot: FileIdentity) -> Bool {
    var current = resolvedPath
    while true {
        if FileIdentity(path: current) == repositoryRoot { return true }
        if current == "/" || current.isEmpty { return false }
        let parent = (current as NSString).deletingLastPathComponent
        current = parent.isEmpty ? "/" : parent
    }
}

/// The repository that contains `directory`, as reported by
/// `git rev-parse --show-toplevel`.
func repositoryRoot(containing directory: String) throws(IntakeError) -> FileIdentity {
    var output = Data()
    let result = try ChildProcess.run(
        executable: "/usr/bin/git",
        arguments: ["-C", directory, "rev-parse", "--show-toplevel"],
        inheritedDescriptor: nil
    ) { bytes in
        output.append(contentsOf: bytes)
        return output.count > 64 * 1024 ? .stop : .proceed
    }
    guard result.exitStatus == 0,
          let text = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .newlines),
          !text.isEmpty,
          let resolved = resolvedPath(text),
          let identity = FileIdentity(path: resolved)
    else {
        throw .repositoryRootUnavailable
    }
    return identity
}
