import Foundation

// Member selection and streaming with the system bsdtar (DEC-066 §C–§E).

enum MemberPolicy {
    /// The nine P2-S1 tables (DEC-065 §B), by archive member name.
    static let tableMembers: [String: GTFSTableName] = Dictionary(
        uniqueKeysWithValues: GTFSTableName.allCases.map { ($0.rawValue + ".txt", $0) }
    )

    static let requiredMembers = ["agency.txt", "stops.txt", "routes.txt", "trips.txt", "stop_times.txt"]

    /// `[A-Za-z0-9][A-Za-z0-9._-]*` — checked on the listing as printed, so
    /// escaped control characters, path separators, and non-ASCII bytes all
    /// fail it.
    static func isAllowedName(_ name: String) -> Bool {
        let bytes = Array(name.utf8)
        guard let first = bytes.first, isAlphanumeric(first) else { return false }
        return bytes.allSatisfy { isAlphanumeric($0) || $0 == 0x2E || $0 == 0x5F || $0 == 0x2D }
    }

    private static func isAlphanumeric(_ byte: UInt8) -> Bool {
        (0x30...0x39).contains(byte) || (0x41...0x5A).contains(byte) || (0x61...0x7A).contains(byte)
    }

    /// Applies the name policy, rejects duplicates, and splits the listing
    /// into selected and unselected members, both sorted by name.
    static func partition(_ names: [String]) throws(IntakeError) -> (selected: [String], unselected: [String]) {
        var seen = Set<String>()
        for name in names {
            guard isAllowedName(name) else { throw .unsafeMemberName(listedAs: name) }
            guard seen.insert(name).inserted else { throw .duplicateMember(name: name) }
        }
        for name in requiredMembers where !seen.contains(name) {
            throw .missingRequiredMember(name: name)
        }
        let selected = seen.filter { tableMembers[$0] != nil }.sorted()
        let unselected = seen.filter { tableMembers[$0] == nil }.sorted()
        return (selected, unselected)
    }
}

enum Bsdtar {
    static let executable = "/usr/bin/bsdtar"
    /// The archive descriptor as the child sees it.
    static let archiveArgument = "/dev/fd/3"

    /// Member names as `bsdtar -tf` prints them, one per line.
    static func list(_ archive: ArchiveFile, limits: IntakeLimits) throws(IntakeError) -> [String] {
        try archive.rewind()
        var output = Data()
        var tooLarge = false
        let result = try ChildProcess.run(
            executable: executable,
            arguments: ["-tf", archiveArgument],
            inheritedDescriptor: archive.descriptor
        ) { bytes in
            guard output.count + bytes.count <= limits.listingBytes else {
                tooLarge = true
                return .stop
            }
            output.append(contentsOf: bytes)
            return .proceed
        }
        if tooLarge { throw .listingTooLarge }
        guard result.exitStatus == 0 else { throw .listingFailed(status: result.exitStatus ?? -1) }
        // Decoding as ASCII turns any other byte into U+FFFD, which the
        // strict name policy then rejects.
        let text = String(decoding: output, as: Unicode.ASCII.self)
        var names = text.components(separatedBy: "\n")
        if names.last == "" { names.removeLast() }
        return names
    }

    /// The exact bytes of one member, accepted only when bsdtar exits with
    /// status 0. `remainingTotal` is what the combined limit still allows.
    static func stream(
        _ name: String,
        from archive: ArchiveFile,
        limits: IntakeLimits,
        remainingTotal: Int
    ) throws(IntakeError) -> Data {
        try archive.rewind()
        var bytes = Data()
        var overMember = false
        var overTotal = false
        let result = try ChildProcess.run(
            executable: executable,
            arguments: ["-xOf", archiveArgument, name],
            inheritedDescriptor: archive.descriptor
        ) { chunk in
            let next = bytes.count + chunk.count
            if next > limits.memberBytes {
                overMember = true
                return .stop
            }
            if next > remainingTotal {
                overTotal = true
                return .stop
            }
            bytes.append(contentsOf: chunk)
            return .proceed
        }
        if overMember { throw .memberTooLarge(name: name) }
        if overTotal { throw .selectedMembersTooLarge }
        guard result.exitStatus == 0 else {
            throw .memberStreamFailed(name: name, status: result.exitStatus ?? -1)
        }
        return bytes
    }
}
