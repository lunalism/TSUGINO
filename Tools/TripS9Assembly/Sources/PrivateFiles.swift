import Foundation
import Darwin

// Reuse unchanged descriptor traversal/read/write primitives; S9 owns publication semantics.
enum S9IO {
    static let fileLimits = ["trip.json":S9Limits.trip,"crosswalk.json":S9Limits.crosswalk,"history.json":S9Limits.history,"manifest.json":S9Limits.manifest]
    static func read(_ path: String, sha: String, limit: Int) throws -> Data {
        try PrivateIO.read(path,sha256:sha,limit:limit)
    }
    static func write(_ path: String, bytes: Data, limit: Int) throws {
        _ = try S9.bounded(bytes,limit)
        let p = try PrivateIO.parent(path); defer { p.closeFD() }
        let temp = ".s9-file-" + UUID().uuidString
        defer { unlinkat(p.fd,temp,0) }
        try PrivateIO.writeAt(p.fd,temp,bytes)
        guard try PrivateIO.readAt(p.fd,temp,limit:limit) == bytes else { throw ConversionFailure.publicationFailure }
        guard renameatx_np(p.fd,temp,p.fd,p.leaf,UInt32(RENAME_EXCL)) == 0 else {
            throw errno == EEXIST ? ConversionFailure.publicationConflict : ConversionFailure.publicationFailure
        }
        guard fsync(p.fd) == 0 else { throw ConversionFailure.durabilityUncertain }
    }
    static func contents(_ dir: Int32) throws -> Set<String> {
        let copy = dup(dir); guard copy >= 0 else { throw ConversionFailure.unsafePath }
        guard let stream = fdopendir(copy) else { close(copy); throw ConversionFailure.unsafePath }
        defer { closedir(stream) }
        var result = Set<String>()
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw ConversionFailure.unsafePath }; break
            }
            let name = withUnsafePointer(to:&entry.pointee.d_name) {
                $0.withMemoryRebound(to:CChar.self,capacity:Int(entry.pointee.d_namlen) + 1) { String(cString:$0) }
            }
            if name != "." && name != ".." { result.insert(name) }
        }
        return result
    }
    static func readBundleAt(_ parent: Int32, _ leaf: String, owner: String, manifestSHA: String) throws -> S9.Bundle {
        let dir = openat(parent,leaf,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { throw ConversionFailure.unsafePath }; defer { close(dir) }
        var info = stat()
        guard fstat(dir,&info) == 0, info.st_uid == getuid(), info.st_mode & 0o7777 == 0o700,
              try contents(dir) == Set(fileLimits.keys) else { throw ConversionFailure.unsafePath }
        var files: [String:Data] = [:]
        for (name,limit) in fileLimits { files[name] = try PrivateIO.readAt(dir,name,limit:limit) }
        return try S9.verify(files,owner:owner,manifestSHA:manifestSHA)
    }
    static func readBundle(_ path: String, owner: String, manifestSHA: String) throws -> S9.Bundle {
        let p = try PrivateIO.parent(path); defer { p.closeFD() }
        return try readBundleAt(p.fd,p.leaf,owner:owner,manifestSHA:manifestSHA)
    }
    static func publish(_ b: S9.Bundle, path: String, owner: String) throws {
        try publishInternal(b,path:path,owner:owner,failAt:nil)
    }
    #if S9_TESTING
    static func publishForTest(_ b: S9.Bundle, path: String, owner: String, failAt: String) throws {
        try publishInternal(b,path:path,owner:owner,failAt:failAt)
    }
    #endif
    private static func publishInternal(_ b: S9.Bundle, path: String, owner: String, failAt: String?) throws {
        _ = try S9.verify(b.files,owner:owner,manifestSHA:Codec.hash(b.manifest))
        let p = try PrivateIO.parent(path); defer { p.closeFD() }
        if b.replay {
            let old = try readBundleAt(p.fd,p.leaf,owner:owner,manifestSHA:Codec.hash(b.manifest))
            guard old.files == b.files else { throw ConversionFailure.publicationConflict }; return
        }
        var existing = stat()
        if fstatat(p.fd,p.leaf,&existing,AT_SYMLINK_NOFOLLOW) == 0 { throw ConversionFailure.publicationConflict }
        guard errno == ENOENT else { throw ConversionFailure.unsafePath }
        let temp = ".s9-stage-" + UUID().uuidString
        guard mkdirat(p.fd,temp,0o700) == 0 else { throw ConversionFailure.publicationFailure }
        let dir = openat(p.fd,temp,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { unlinkat(p.fd,temp,AT_REMOVEDIR); throw ConversionFailure.publicationFailure }
        var committed = false
        defer {
            if !committed { for name in fileLimits.keys { unlinkat(dir,name,0) }; unlinkat(p.fd,temp,AT_REMOVEDIR) }
            close(dir)
        }
        guard fchmod(dir,0o700) == 0 else { throw ConversionFailure.publicationFailure }
        for name in fileLimits.keys.sorted() {
            if failAt == "write:" + name { throw ConversionFailure.publicationFailure }
            try PrivateIO.writeAt(dir,name,b.files[name]!)
            guard try PrivateIO.readAt(dir,name,limit:fileLimits[name]!) == b.files[name]! else { throw ConversionFailure.publicationFailure }
        }
        guard fsync(dir) == 0 else { throw ConversionFailure.publicationFailure }
        if failAt == "rename" { throw ConversionFailure.publicationFailure }
        guard renameatx_np(p.fd,temp,p.fd,p.leaf,UInt32(RENAME_EXCL)) == 0 else {
            throw errno == EEXIST ? ConversionFailure.publicationConflict : ConversionFailure.publicationFailure
        }
        committed = true
        if failAt == "parentFsync" { throw ConversionFailure.durabilityUncertain }
        guard fsync(p.fd) == 0 else { throw ConversionFailure.durabilityUncertain }
        do {
            guard try readBundleAt(p.fd,p.leaf,owner:owner,manifestSHA:Codec.hash(b.manifest)).files == b.files else { throw ConversionFailure.durabilityUncertain }
        } catch { throw ConversionFailure.durabilityUncertain }
    }
}
