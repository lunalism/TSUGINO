import Foundation
import Darwin

enum PrivateIO {
    static let names = ["history.json","manifest.json","registry.json"]
    struct Parent {
        let fd: Int32, leaf: String
        func closeFD() { close(fd) }
    }
    // All traversal and mutation is descriptor-relative. Never follow a symlink, including ancestors.
    static func parent(_ path: String) throws -> Parent {
        guard path.hasPrefix("/"), !path.hasSuffix("/"), !path.contains("\0") else { throw ConversionFailure.unsafePath }
        let parts = path.split(separator:"/",omittingEmptySubsequences:false).dropFirst().map(String.init)
        guard !parts.isEmpty, parts.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." && $0 != ".git" && $0.utf8.count <= 255 }) else { throw ConversionFailure.unsafePath }
        let repo = URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().path
        guard path != repo, !path.hasPrefix(repo + "/") else { throw ConversionFailure.unsafePath }
        var repository = stat()
        guard stat(repo,&repository) == 0 else { throw ConversionFailure.unsafePath }
        var fd = open("/",O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard fd >= 0 else { throw ConversionFailure.unsafePath }
        for part in parts.dropLast() {
            let next = openat(fd,part,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
            close(fd); fd = next
            guard fd >= 0 else { throw ConversionFailure.unsafePath }
            var ancestor = stat()
            guard fstat(fd,&ancestor) == 0 else { close(fd); throw ConversionFailure.unsafePath }
            guard (ancestor.st_uid == 0 || ancestor.st_uid == getuid()),
                  ancestor.st_mode & 0o022 == 0 || (ancestor.st_uid == 0 && ancestor.st_mode & S_ISVTX != 0) else { close(fd); throw ConversionFailure.unsafePath }
            if ancestor.st_dev == repository.st_dev && ancestor.st_ino == repository.st_ino { close(fd); throw ConversionFailure.unsafePath }
        }
        var s = stat()
        guard fstat(fd,&s) == 0, s.st_uid == getuid(), s.st_mode & 0o7777 == 0o700 else { close(fd); throw ConversionFailure.unsafePath }
        return .init(fd:fd,leaf:parts.last!)
    }
    static func readAt(_ dir: Int32, _ name: String, limit: Int) throws -> Data {
        let fd = openat(dir,name,O_RDONLY|O_NOFOLLOW|O_NONBLOCK|O_CLOEXEC)
        guard fd >= 0 else { throw errno == ENOENT ? ConversionFailure.historyUnavailable : ConversionFailure.unsafePath }; defer { close(fd) }
        var s = stat()
        guard fstat(fd,&s) == 0, s.st_mode & S_IFMT == S_IFREG, s.st_uid == getuid(), s.st_mode & 0o7777 == 0o600,
              s.st_nlink == 1 else { throw ConversionFailure.unsafePath }
        guard s.st_size > 0, s.st_size <= limit else { throw ConversionFailure.resourceLimit }
        var result = Data(), buffer = [UInt8](repeating:0,count:65536)
        while true {
            let count = Darwin.read(fd,&buffer,buffer.count)
            if count < 0 { if errno == EINTR { continue }; throw ConversionFailure.publicationFailure }
            if count == 0 { break }
            guard result.count <= limit - count else { throw ConversionFailure.resourceLimit }
            result.append(contentsOf:buffer.prefix(count))
        }
        var after = stat()
        guard fstat(fd,&after) == 0, after.st_size == s.st_size, result.count == Int(s.st_size), after.st_mtimespec.tv_sec == s.st_mtimespec.tv_sec,
              after.st_mtimespec.tv_nsec == s.st_mtimespec.tv_nsec else { throw ConversionFailure.publicationFailure }
        return result
    }
    static func read(_ path: String, sha256: String, limit: Int) throws -> Data {
        guard MappingText.isSHA256(sha256) else { throw ConversionFailure.malformedInput }
        let p = try parent(path); defer { p.closeFD() }
        let b = try readAt(p.fd,p.leaf,limit:limit)
        guard Codec.hash(b) == sha256 else { throw ConversionFailure.historyConflict }; return b
    }
    static func writeAt(_ dir: Int32, _ name: String, _ bytes: Data) throws {
        let fd = openat(dir,name,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW|O_CLOEXEC,0o600)
        guard fd >= 0 else { throw ConversionFailure.publicationFailure }; defer { close(fd) }
        guard fchmod(fd,0o600) == 0 else { throw ConversionFailure.publicationFailure }
        try bytes.withUnsafeBytes { raw in
            var done = 0
            while done < bytes.count {
                let n = Darwin.write(fd,raw.baseAddress!.advanced(by:done),bytes.count-done)
                if n < 0 && errno == EINTR { continue }
                guard n > 0 else { throw ConversionFailure.publicationFailure }; done += n
            }
        }
        guard fsync(fd) == 0 else { throw ConversionFailure.publicationFailure }
    }
    static func write(_ path: String, bytes: Data) throws {
        guard bytes.count <= Limits.history else { throw ConversionFailure.resourceLimit }
        let p = try parent(path); defer { p.closeFD() }
        let temp = ".conversion-file-" + UUID().uuidString
        defer { unlinkat(p.fd,temp,0) }
        try writeAt(p.fd,temp,bytes)
        guard try readAt(p.fd,temp,limit:Limits.history) == bytes else { throw ConversionFailure.publicationFailure }
        guard linkat(p.fd,temp,p.fd,p.leaf,0) == 0 else { throw errno == EEXIST ? ConversionFailure.publicationConflict : ConversionFailure.publicationFailure }
        unlinkat(p.fd,temp,0)
        // Publication is committed at link/rename. A post-commit sync error cannot mean partial bytes.
        guard fsync(p.fd) == 0 else { throw ConversionFailure.publicationFailure }
    }
    static func readBundle(_ path: String, owner: String, manifestSHA: String) throws -> Conversion.Bundle {
        let p = try parent(path); defer { p.closeFD() }
        return try readBundleAt(p.fd,p.leaf,owner:owner,manifestSHA:manifestSHA)
    }
    static func readBundleAt(_ parent: Int32, _ name: String, owner: String, manifestSHA: String, registration: Bool = false) throws -> Conversion.Bundle {
        let dir = openat(parent,name,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { throw ConversionFailure.unsafePath }; defer { close(dir) }
        var s = stat()
        guard fstat(dir,&s) == 0, s.st_uid == getuid(), s.st_mode & 0o7777 == 0o700 else { throw ConversionFailure.unsafePath }
        let r = try readAt(dir,"registry.json",limit:Limits.registry), h = try readAt(dir,"history.json",limit:Limits.history), m = try readAt(dir,"manifest.json",limit:Limits.request)
        guard Codec.hash(m) == manifestSHA else { throw ConversionFailure.historyConflict }
        return try registration ? Registration.verify(r,h,m,owner:owner) : Conversion.verify(r,h,m,owner:owner)
    }
    static func publish(_ bundle: Conversion.Bundle, to path: String, owner: String) throws {
        try publishInternal(bundle,to:path,owner:owner,failAt:nil)
    }
    #if TRIP_CONVERSION_TESTING
    static func publishForTest(_ bundle: Conversion.Bundle, to path: String, owner: String, failAt: String) throws {
        try publishInternal(bundle,to:path,owner:owner,failAt:failAt)
    }
    #endif
    static func publishInternal(_ bundle: Conversion.Bundle, to path: String, owner: String, failAt: String?, registration: Bool = false) throws {
        if registration { _ = try Registration.verify(bundle.registry,bundle.history,bundle.manifest,owner:owner) }
        else { _ = try Conversion.verify(bundle.registry,bundle.history,bundle.manifest,owner:owner) }
        let p = try parent(path); defer { p.closeFD() }
        if bundle.replay {
            let old = try readBundleAt(p.fd,p.leaf,owner:owner,manifestSHA:Codec.hash(bundle.manifest),registration:registration)
            guard old.files == bundle.files else { throw ConversionFailure.publicationConflict }; return
        }
        var existing = stat()
        if fstatat(p.fd,p.leaf,&existing,AT_SYMLINK_NOFOLLOW) == 0 { throw ConversionFailure.publicationConflict }
        guard errno == ENOENT else { throw ConversionFailure.unsafePath }
        let staging = ".conversion-stage-" + UUID().uuidString
        guard mkdirat(p.fd,staging,0o700) == 0 else { throw ConversionFailure.publicationFailure }
        let dir = openat(p.fd,staging,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { unlinkat(p.fd,staging,AT_REMOVEDIR); throw ConversionFailure.publicationFailure }
        var committed = false
        defer {
            if !committed { for name in names { unlinkat(dir,name,0) }; unlinkat(p.fd,staging,AT_REMOVEDIR) }
            close(dir)
        }
        guard fchmod(dir,0o700) == 0 else { throw ConversionFailure.publicationFailure }
        for name in names {
            if failAt == "write:" + name { throw ConversionFailure.publicationFailure }
            try writeAt(dir,name,bundle.files[name]!)
            guard try readAt(dir,name,limit:Limits.history) == bundle.files[name]! else { throw ConversionFailure.publicationFailure }
        }
        guard fsync(dir) == 0 else { throw ConversionFailure.publicationFailure }
        if failAt == "rename" { throw ConversionFailure.publicationFailure }
        guard renameatx_np(p.fd,staging,p.fd,p.leaf,UInt32(RENAME_EXCL)) == 0 else {
            throw errno == EEXIST ? ConversionFailure.publicationConflict : ConversionFailure.publicationFailure
        }
        committed = true
        if registration && failAt == "parentFsync" { throw ConversionFailure.durabilityUncertain }
        guard fsync(p.fd) == 0 else { throw registration ? ConversionFailure.durabilityUncertain : ConversionFailure.publicationFailure }
    }
}
