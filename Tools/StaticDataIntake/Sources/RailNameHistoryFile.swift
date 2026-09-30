import Foundation

/// Provisional offline review envelope only, not an app persistence format.
/// Logical records/evidence remain version 1. Version 2 interns whole immutable
/// evidence objects; ordered choices, validations and sightings are never folded.
enum RailNameHistoryFile {
    static let storedLimit = 16 * 1024 * 1024
    static let expandedLimit = 64 * 1024 * 1024
    static let legacyLimit = expandedLimit
    static let referenceLimit = 100_000
    static let depthLimit = 64
    private static let encoding = "sorted-json-sha256-v1"
    private typealias Object = [String: Any]

    static func read(_ path: String, root: FileIdentity) throws -> RailNameHistoryArtifact {
        let checked = try StationCommand.checkedPath(path,"name history",root)
        let bytes = try ProvisionalRegistryCommand.readFile(checked,"name history",root,limit:Int64(legacyLimit))
        return try decode(bytes)
    }

    private static func encoded(_ value: RailNameHistoryArtifact) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys,.withoutEscapingSlashes]
        return try encoder.encode(value)
    }
    private static func json(_ value: Any) throws -> Data {
        try JSONSerialization.data(withJSONObject:value,options:[.sortedKeys,.withoutEscapingSlashes])
    }
    private static func object(_ data: Data) throws -> Object {
        guard data.count <= legacyLimit else { throw NameReviewError.invalidHistory }
        // Bound nesting before either JSON parser; braces inside strings do not count.
        var depth = 0, quoted = false, escaped = false
        for byte in data {
            if quoted {
                if escaped { escaped = false }
                else if byte == 92 { escaped = true }
                else if byte == 34 { quoted = false }
            } else if byte == 34 { quoted = true }
            else if byte == 123 || byte == 91 {
                depth += 1
                guard depth <= depthLimit else { throw NameReviewError.invalidHistory }
            } else if byte == 125 || byte == 93 { depth -= 1 }
        }
        guard !RegistryJSON.repeatsKey(Array(data)),
              let value = try JSONSerialization.jsonObject(with:data) as? Object else { throw NameReviewError.malformed }
        return value
    }
    /// Fail closed on fields a typed round trip would discard. This also checks
    /// scalar-exact text preservation (byte equality, never String equality).
    private static func logical(_ value: Object) throws -> RailNameHistoryArtifact {
        let bytes = try json(value)
        guard bytes.count <= expandedLimit else { throw NameReviewError.invalidHistory }
        let history = try JSONDecoder().decode(RailNameHistoryArtifact.self,from:bytes)
        guard history.schemaVersion == 1, history.names.schemaVersion == 1, history.titles.schemaVersion == 1,
              try json(JSONSerialization.jsonObject(with:encoded(history))) == bytes else {
            throw NameReviewError.invalidHistory
        }
        return history
    }
    /// Touch only the documented evidence positions. All other fields, arrays,
    /// exact source strings and provenance remain in place, including originals.
    private static func mapEvidence(_ value: inout Object, _ transform: (Any) throws -> Any) throws {
        var references = 0
        func mapped(_ item: Any) throws -> Any {
            references += 1
            guard references <= referenceLimit else { throw NameReviewError.invalidHistory }
            return try transform(item)
        }
        for kind in ["names","titles"] {
            guard var history = value[kind] as? Object else { throw NameReviewError.malformed }
            for field in ["choices","validations"] {
                guard let rows = history[field] as? [Object] else { throw NameReviewError.malformed }
                history[field] = try rows.map { row -> Object in
                    var next = row
                    guard let evidence = row["evidence"] else { throw NameReviewError.malformed }
                    next["evidence"] = try mapped(evidence)
                    return next
                }
            }
            guard let observations = history["observations"] as? [Any] else { throw NameReviewError.malformed }
            history["observations"] = try observations.map(mapped)
            value[kind] = history
        }
    }
    static func encode(_ history: RailNameHistoryArtifact) throws -> Data {
        var value = try object(encoded(history))
        _ = try logical(value)
        var pool: Object = [:]
        var poolBytes: [String:Data] = [:]
        var referencedBytes = 0
        try mapEvidence(&value) { evidence in
            guard evidence is Object else { throw NameReviewError.malformed }
            let bytes = try json(evidence), digest = sha256Hex(bytes)
            if let old = poolBytes[digest], old != bytes { throw NameReviewError.invalidHistory }
            pool[digest] = evidence; poolBytes[digest] = bytes
            referencedBytes += bytes.count
            guard referencedBytes <= expandedLimit else { throw NameReviewError.invalidHistory }
            return digest
        }
        value["schemaVersion"] = 2
        value["evidenceEncoding"] = encoding
        value["evidence"] = pool
        var bytes = try json(value); bytes.append(10)
        // Same conservative expansion budget as the reader: envelope plus every
        // referenced payload. Fail before publication, never emit unreadable output.
        guard bytes.count <= storedLimit, referencedBytes <= expandedLimit - bytes.count else {
            throw NameReviewError.invalidHistory
        }
        return bytes
    }
    static func decode(_ data: Data) throws -> RailNameHistoryArtifact {
        var value = try object(data)
        struct Header: Decodable { let schemaVersion: Int }
        let version = try JSONDecoder().decode(Header.self,from:data).schemaVersion
        if version == 1 { return try logical(value) }
        guard version == 2 else { throw NameReviewError.schema }
        guard data.count <= storedLimit,
              Set(value.keys) == Set(["schemaVersion","names","titles","evidenceEncoding","evidence"]),
              value["evidenceEncoding"] as? String == encoding,
              let pool = value["evidence"] as? Object else { throw NameReviewError.invalidHistory }
        var sizes: [String:Int] = [:]
        for (digest,evidence) in pool {
            guard MappingText.isSHA256(digest), evidence is Object else { throw NameReviewError.invalidHistory }
            let bytes = try json(evidence)
            guard sha256Hex(bytes) == digest else { throw NameReviewError.invalidHistory }
            sizes[digest] = bytes.count
        }
        var used = Set<String>(), expanded = data.count
        try mapEvidence(&value) { reference in
            guard let digest = reference as? String, let evidence = pool[digest], let size = sizes[digest],
                  size <= expandedLimit - expanded else { throw NameReviewError.invalidHistory }
            expanded += size; used.insert(digest)
            return evidence
        }
        guard used == Set(pool.keys) else { throw NameReviewError.invalidHistory }
        value["schemaVersion"] = 1
        value.removeValue(forKey:"evidenceEncoding"); value.removeValue(forKey:"evidence")
        return try logical(value)
    }
}
