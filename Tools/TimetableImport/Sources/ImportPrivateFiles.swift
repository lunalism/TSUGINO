import Foundation
import Darwin

// Descriptor-relative atomic publication; unchanged PrivateIO primitives enforce private traversal.
// Fault hooks are compiled only into the invented test executable.
enum ImportIO {
    static let fileLimits = ["facts.json":ImportLimits.facts,"history.json":ImportLimits.history,"manifest.json":ImportLimits.manifest]
    static func read(_ path: String, sha: String, limit: Int) throws -> Data {
        try PrivateIO.read(path,sha256:sha,limit:limit)
    }
    static func write(_ path: String, bytes: Data, limit: Int) throws {
        _ = try S9.bounded(bytes,limit)
        let p = try PrivateIO.parent(path); defer { p.closeFD() }
        let temp = ".timetable-file-" + UUID().uuidString
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
            if name != "." && name != ".." {
                guard fileLimits[name] != nil, result.count < fileLimits.count,
                      result.insert(name).inserted else { throw ConversionFailure.unsafePath }
            }
        }
        return result
    }
    static func readBundleAt(_ parent: Int32, _ leaf: String, external: ImportAuthority.External, manifestSHA: String) throws -> ImportAuthority.Bundle {
        let dir = openat(parent,leaf,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { throw ConversionFailure.unsafePath }; defer { close(dir) }
        var info = stat()
        guard fstat(dir,&info) == 0, info.st_uid == getuid(), info.st_mode & 0o7777 == 0o700,
              try contents(dir) == Set(fileLimits.keys) else { throw ConversionFailure.unsafePath }
        var files: [String:Data] = [:]
        for (name,limit) in fileLimits { files[name] = try PrivateIO.readAt(dir,name,limit:limit) }
        return try ImportAuthority.verify(files,manifestSHA:manifestSHA,external:external)
    }
    static func readBundle(_ path: String, external: ImportAuthority.External, manifestSHA: String) throws -> ImportAuthority.Bundle {
        let p = try PrivateIO.parent(path); defer { p.closeFD() }
        return try readBundleAt(p.fd,p.leaf,external:external,manifestSHA:manifestSHA)
    }
    static func publish(_ b: ImportAuthority.Bundle, path: String, external: ImportAuthority.External) throws {
        #if TIMETABLE_IMPORT_TESTING
        try publishInternal(b,path:path,external:external,failAt:nil)
        #else
        try publishInternal(b,path:path,external:external)
        #endif
    }
    #if TIMETABLE_IMPORT_TESTING
    static func publishForTest(_ b: ImportAuthority.Bundle, path: String, external: ImportAuthority.External, failAt: String) throws {
        try publishInternal(b,path:path,external:external,failAt:failAt)
    }
    #endif
    #if TIMETABLE_IMPORT_TESTING
    private static var failurePoint: String?
    private static func publishInternal(_ b: ImportAuthority.Bundle, path: String, external: ImportAuthority.External, failAt: String?) throws {
        failurePoint = failAt; defer { failurePoint = nil }
        try publishInternal(b,path:path,external:external)
    }
    #endif
    private static func publishInternal(_ b: ImportAuthority.Bundle, path: String, external: ImportAuthority.External) throws {
        _ = try ImportAuthority.verify(b.files,manifestSHA:Codec.hash(b.manifest),external:external)
        let p = try PrivateIO.parent(path); defer { p.closeFD() }
        if b.replay {
            let old = try readBundleAt(p.fd,p.leaf,external:external,manifestSHA:Codec.hash(b.manifest))
            guard old.files == b.files else { throw ConversionFailure.publicationConflict }; return
        }
        var existing = stat()
        if fstatat(p.fd,p.leaf,&existing,AT_SYMLINK_NOFOLLOW) == 0 { throw ConversionFailure.publicationConflict }
        guard errno == ENOENT else { throw ConversionFailure.unsafePath }
        let temp = ".timetable-stage-" + UUID().uuidString
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
        #if TIMETABLE_IMPORT_TESTING
            if failurePoint == "write:" + name { throw ConversionFailure.publicationFailure }
        #endif
            try PrivateIO.writeAt(dir,name,b.files[name]!)
            guard try PrivateIO.readAt(dir,name,limit:fileLimits[name]!) == b.files[name]! else { throw ConversionFailure.publicationFailure }
        }
        guard fsync(dir) == 0 else { throw ConversionFailure.publicationFailure }
        #if TIMETABLE_IMPORT_TESTING
        if failurePoint == "rename" { throw ConversionFailure.publicationFailure }
        #endif
        guard renameatx_np(p.fd,temp,p.fd,p.leaf,UInt32(RENAME_EXCL)) == 0 else {
            throw errno == EEXIST ? ConversionFailure.publicationConflict : ConversionFailure.publicationFailure
        }
        committed = true
        #if TIMETABLE_IMPORT_TESTING
        if failurePoint == "parentFsync" { throw ConversionFailure.durabilityUncertain }
        #endif
        guard fsync(p.fd) == 0 else { throw ConversionFailure.durabilityUncertain }
        do {
            guard try readBundleAt(p.fd,p.leaf,external:external,manifestSHA:Codec.hash(b.manifest)).files == b.files else { throw ConversionFailure.durabilityUncertain }
        } catch { throw ConversionFailure.durabilityUncertain }
    }
}
