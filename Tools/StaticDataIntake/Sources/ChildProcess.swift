import Foundation

// Runs a child process with an explicit descriptor table (DEC-066 §D).
//
// `posix_spawn` with `POSIX_SPAWN_CLOEXEC_DEFAULT` gives the child exactly:
// fd 0 = /dev/null, fd 1 and fd 2 = pipes to this process, and, when given,
// fd 3 = the inherited archive descriptor. No other descriptor leaks in.
// Standard output is delivered to a callback as it arrives, so a caller can
// enforce a byte limit on streamed bytes; standard error is drained at the
// same time (and capped), so a full pipe can never stall the child.

enum ChildOutputDecision {
    case proceed
    /// Stop reading; the child is killed and reaped.
    case stop
}

struct ChildResult {
    /// The exit status, or `nil` when the child was stopped (by the caller,
    /// or after a pipe read error) or killed by a signal. Only a status of 0
    /// counts as success.
    let exitStatus: Int32?
    let stoppedByCaller: Bool
    let standardError: Data
}

enum ChildProcess {
    static let standardErrorCap = 8 * 1024

    /// Runs `executable` with `arguments`, handing `inheritedDescriptor` to
    /// the child as fd 3 when it is not `nil`. The child is always reaped
    /// before this returns, and every pipe descriptor is closed.
    static func run(
        executable: String,
        arguments: [String],
        inheritedDescriptor: Int32?,
        onStandardOutput: (UnsafeRawBufferPointer) -> ChildOutputDecision
    ) throws(IntakeError) -> ChildResult {
        var outputPipe: [Int32] = [-1, -1]
        var errorPipe: [Int32] = [-1, -1]
        guard pipe(&outputPipe) == 0 else { throw .processFailed(tool: executable, errno: errno) }
        guard pipe(&errorPipe) == 0 else {
            let error = errno
            close(outputPipe[0]); close(outputPipe[1])
            throw .processFailed(tool: executable, errno: error)
        }
        defer {
            close(outputPipe[0])
            close(errorPipe[0])
        }

        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        posix_spawn_file_actions_init(&actions)
        posix_spawnattr_init(&attributes)
        defer {
            posix_spawn_file_actions_destroy(&actions)
            posix_spawnattr_destroy(&attributes)
        }
        posix_spawn_file_actions_addopen(&actions, 0, "/dev/null", O_RDONLY, 0)
        posix_spawn_file_actions_adddup2(&actions, outputPipe[1], 1)
        posix_spawn_file_actions_adddup2(&actions, errorPipe[1], 2)
        // The inherited descriptor is first duplicated to a number of 10 or
        // above, so that the child's dup2 onto fd 3 is always a real copy:
        // when the source already is fd 3, dup2 would be a no-op that keeps
        // close-on-exec, and POSIX_SPAWN_CLOEXEC_DEFAULT would close it.
        var spawnSource: Int32 = -1
        if let inheritedDescriptor {
            spawnSource = fcntl(inheritedDescriptor, F_DUPFD_CLOEXEC, 10)
            guard spawnSource >= 0 else {
                let error = errno
                close(outputPipe[1]); close(errorPipe[1])
                throw .processFailed(tool: executable, errno: error)
            }
            posix_spawn_file_actions_adddup2(&actions, spawnSource, 3)
        }
        defer { if spawnSource >= 0 { close(spawnSource) } }
        posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_CLOEXEC_DEFAULT))

        let argv: [UnsafeMutablePointer<CChar>?] = ([executable] + arguments).map { strdup($0) } + [nil]
        let environmentStrings: [String] = ["PATH=/usr/bin:/bin", "LC_ALL=C"]
        let environment: [UnsafeMutablePointer<CChar>?] = environmentStrings.map { strdup($0) } + [nil]
        defer {
            argv.forEach { free($0) }
            environment.forEach { free($0) }
        }

        var pid: pid_t = 0
        let spawnStatus = posix_spawn(&pid, executable, &actions, &attributes, argv, environment)
        close(outputPipe[1])
        close(errorPipe[1])
        guard spawnStatus == 0 else { throw .processFailed(tool: executable, errno: spawnStatus) }

        var standardError = Data()
        var stopped = false
        var outputOpen = true
        var errorOpen = true
        let chunk = UnsafeMutableRawBufferPointer.allocate(byteCount: 64 * 1024, alignment: 1)
        defer { chunk.deallocate() }

        while outputOpen || errorOpen {
            var descriptors: [pollfd] = []
            if outputOpen { descriptors.append(pollfd(fd: outputPipe[0], events: Int16(POLLIN), revents: 0)) }
            if errorOpen { descriptors.append(pollfd(fd: errorPipe[0], events: Int16(POLLIN), revents: 0)) }
            let ready = poll(&descriptors, nfds_t(descriptors.count), -1)
            if ready < 0 {
                if errno == EINTR { continue }
                stopped = true
                break
            }
            for descriptor in descriptors where descriptor.revents != 0 {
                let count = read(descriptor.fd, chunk.baseAddress, chunk.count)
                if count < 0 {
                    if errno == EINTR { continue }
                    // A read error is never taken as end of output: the child
                    // is stopped, so the result cannot count as success.
                    stopped = true
                    break
                }
                if descriptor.fd == outputPipe[0] {
                    if count <= 0 {
                        outputOpen = false
                    } else if onStandardOutput(UnsafeRawBufferPointer(rebasing: chunk[0..<count])) == .stop {
                        stopped = true
                    }
                } else {
                    if count <= 0 {
                        errorOpen = false
                    } else if standardError.count < standardErrorCap {
                        let room = standardErrorCap - standardError.count
                        standardError.append(contentsOf: chunk[0..<min(count, room)])
                    }
                }
            }
            if stopped { break }
        }

        if stopped {
            kill(pid, SIGKILL)
        }
        var status: Int32 = 0
        while waitpid(pid, &status, 0) < 0, errno == EINTR {}

        // WIFEXITED / WEXITSTATUS, which Swift does not import as functions.
        let exited = (status & 0x7F) == 0
        let exitStatus: Int32? = (!stopped && exited) ? (status >> 8) & 0xFF : nil
        return ChildResult(exitStatus: exitStatus, stoppedByCaller: stopped, standardError: standardError)
    }
}
