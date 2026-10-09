import Foundation
import Darwin

// Receipts exclude retries of one explicit operation; they are neither a registry
// nor a discovered currentness pointer. Paths never enter the authoritative request.
enum Preparation {
    struct Location {
        let workspace: String, output: String
        let operationID: String, workspaceID: String, outputID: String
    }
    static func claim(_ e: Registration.Eligible) throws -> Data {
        let i = e.input
        return try Codec.encode(.object(["format":.string("tsugino.trip-registry-preparation-claim"),"schemaVersion":.integer(1),
            "contextSHA256":.string(try Codec.digest(i.context)),"registrySHA256":.string(Codec.hash(i.registry)),"historySHA256":.string(Codec.hash(i.history)),
            "manifestSHA256":.string(Codec.hash(i.manifest)),"correspondenceSHA256":.string(Codec.hash(i.correspondence)),
            "dependenciesSHA256":.string(try Codec.digest(i.dependencies))]))
    }
    static func checkLocation(_ l: Location, context c: Wire) throws {
        let w = c["workflow"]
        guard l.operationID == w["operationID"].text, l.workspaceID == w["workspaceID"].text, l.outputID == w["outputID"].text,
              l.workspace != l.output else { throw ConversionFailure.preparationConflict }
    }
    // Operational inode/leaf binding only, kept outside authoritative request semantics.
    static func locationBinding(_ l: Location) throws -> Wire {
        let w = try PrivateIO.parent(l.workspace); defer { w.closeFD() }
        let o = try PrivateIO.parent(l.output); defer { o.closeFD() }
        var ws = stat(), os = stat()
        guard fstat(w.fd,&ws) == 0, fstat(o.fd,&os) == 0 else { throw ConversionFailure.unsafePath }
        return .object(["workspaceParentDevice":.string(String(ws.st_dev)),"workspaceParentInode":.string(String(ws.st_ino)),"workspaceLeaf":.string(w.leaf),
            "outputParentDevice":.string(String(os.st_dev)),"outputParentInode":.string(String(os.st_ino)),"outputLeaf":.string(o.leaf)])
    }
    static func prepare(_ i: Registration.Inputs, location l: Location) throws -> (Wire,Bool) {
        try prepareInternal(i,location:l,draw:{ try TripMinting.mint(heldBodies:$0) },failAt:nil)
    }
    #if TRIP_CONVERSION_TESTING
    static func prepareForTest(_ i: Registration.Inputs, location l: Location, draw: (Set<String>) throws -> TripMinting.Draw, failAt: String? = nil) throws -> (Wire,Bool) {
        try prepareInternal(i,location:l,draw:draw,failAt:failAt)
    }
    #endif
    private static func prepareInternal(_ i: Registration.Inputs, location l: Location, draw: (Set<String>) throws -> TripMinting.Draw, failAt: String?) throws -> (Wire,Bool) {
        try checkLocation(l,context:i.context)
        let e = try Registration.eligible(i); try Registration.preflight(e)
        let p = try PrivateIO.parent(l.workspace); defer { p.closeFD() }
        let out = try PrivateIO.parent(l.output); defer { out.closeFD() }
        var output = stat()
        let outputExists = fstatat(out.fd,out.leaf,&output,AT_SYMLINK_NOFOLLOW) == 0
        guard outputExists || errno == ENOENT else { throw ConversionFailure.unsafePath }
        var existingWorkspace = stat()
        if outputExists && fstatat(p.fd,p.leaf,&existingWorkspace,AT_SYMLINK_NOFOLLOW) != 0 { throw ConversionFailure.publicationConflict }
        let created = mkdirat(p.fd,p.leaf,0o700) == 0
        if !created && errno != EEXIST { throw ConversionFailure.publicationFailure }
        let dir = openat(p.fd,p.leaf,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { throw ConversionFailure.unsafePath }; defer { close(dir) }
        var info = stat()
        guard fstat(dir,&info) == 0, info.st_uid == getuid(), info.st_mode & 0o7777 == 0o700 else { throw ConversionFailure.unsafePath }
        let expected = try claim(e)
        let binding = try Codec.encode(locationBinding(l))
        if !created {
            let old: Data
            do { old = try PrivateIO.readAt(dir,"claim.json",limit:Limits.request) }
            catch ConversionFailure.historyUnavailable { throw ConversionFailure.preparationIncomplete }
            guard old == expected else { throw ConversionFailure.preparationConflict }
            let oldBinding: Data
            do { oldBinding = try PrivateIO.readAt(dir,"location.json",limit:Limits.request) }
            catch ConversionFailure.historyUnavailable { throw ConversionFailure.preparationIncomplete }
            guard oldBinding == binding else { throw ConversionFailure.preparationConflict }
            let bytes: Data
            do { bytes = try PrivateIO.readAt(dir,"request.json",limit:Limits.request) }
            catch ConversionFailure.historyUnavailable { throw ConversionFailure.preparationIncomplete }
            let q = try Registration.read(bytes,limit:Limits.request); try Registration.validate(q,input:i)
            if outputExists {
                let outputDirectory = openat(out.fd,out.leaf,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
                guard outputDirectory >= 0 else { throw ConversionFailure.unsafePath }; defer { close(outputDirectory) }
                let manifest = try PrivateIO.readAt(outputDirectory,"manifest.json",limit:Limits.request)
                let result = try PrivateIO.readBundleAt(out.fd,out.leaf,owner:i.context["ownerAuthority"].text,manifestSHA:Codec.hash(manifest),registration:true)
                let history = try Registration.read(result.history,limit:Limits.history)
                guard Codec.equal(history["boundaries"].list[0]["request"],q) else { throw ConversionFailure.preparationConflict }
            }
            return (q,true)
        }
        // Retain even an interrupted workspace: lack of a completed request always holds.
        guard fchmod(dir,0o700) == 0 else { throw ConversionFailure.publicationFailure }
        try PrivateIO.writeAt(dir,"claim.json",expected)
        try PrivateIO.writeAt(dir,"location.json",binding)
        guard fsync(dir) == 0, fsync(p.fd) == 0 else { throw ConversionFailure.publicationFailure }
        if failAt == "claim" { throw ConversionFailure.preparationIncomplete }
        let candidate = try draw(e.held)
        if failAt == "draw" { throw ConversionFailure.preparationIncomplete }
        let q = try Registration.request(e,draw:candidate), bytes = try Codec.encode(q)
        // Completion uses atomic no-clobber publication, never a partial final request.
        try PrivateIO.writeAt(dir,"request.stage",bytes)
        guard try PrivateIO.readAt(dir,"request.stage",limit:Limits.request) == bytes else { throw ConversionFailure.publicationFailure }
        guard renameatx_np(dir,"request.stage",dir,"request.json",UInt32(RENAME_EXCL)) == 0 else { throw ConversionFailure.publicationFailure }
        guard fsync(dir) == 0 else { throw ConversionFailure.durabilityUncertain }
        return (q,false)
    }
    static func verifyRetained(_ q: Wire, location l: Location) throws {
        try checkLocation(l,context:q["context"])
        let p = try PrivateIO.parent(l.workspace); defer { p.closeFD() }
        let dir = openat(p.fd,p.leaf,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC)
        guard dir >= 0 else { throw ConversionFailure.preparationIncomplete }; defer { close(dir) }
        var info = stat(); guard fstat(dir,&info) == 0, info.st_uid == getuid(), info.st_mode & 0o7777 == 0o700 else { throw ConversionFailure.unsafePath }
        let b = try PrivateIO.readAt(dir,"request.json",limit:Limits.request)
        guard b == (try Codec.encode(q)) else { throw ConversionFailure.preparationConflict }
        guard try PrivateIO.readAt(dir,"location.json",limit:Limits.request) == Codec.encode(locationBinding(l)) else { throw ConversionFailure.preparationConflict }
        let claim = try Registration.read(PrivateIO.readAt(dir,"claim.json",limit:Limits.request),limit:Limits.request)
        let expected: Wire = .object(["format":.string("tsugino.trip-registry-preparation-claim"),"schemaVersion":.integer(1),
            "contextSHA256":.string(try Codec.digest(q["context"])),"registrySHA256":q["expectedPrevious"]["registrySHA256"],"historySHA256":q["expectedPrevious"]["historySHA256"],
            "manifestSHA256":q["context"]["predecessorManifestSHA256"],"correspondenceSHA256":.string(Codec.hash(q["correspondenceBytes"].blob)),"dependenciesSHA256":.string(try Codec.digest(q["dependencies"]))])
        guard Codec.equal(claim,expected) else { throw ConversionFailure.preparationConflict }
    }
    static func publish(_ b: Conversion.Bundle, request q: Wire, location l: Location) throws {
        try verifyRetained(q,location:l)
        try PrivateIO.publishInternal(b,to:l.output,owner:q["ownerAuthority"].text,failAt:nil,registration:true)
    }
}
