import Foundation
import CryptoKit

// Offline-only wire tree. No app target, synthetic wire tags, allocator or provider reader.
indirect enum Wire: Codable {
    case object([String: Wire]), array([Wire]), string(String), integer(Int), bool(Bool), null
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Int.self) { self = .integer(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([Wire].self) { self = .array(v) }
        else { self = .object(try c.decode([String: Wire].self)) }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .object(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .integer(let v): try c.encode(v)
        case .bool(let v): try c.encode(v)
        case .null: try c.encodeNil()
        }
    }
    subscript(_ name: String) -> Wire { get { if case .object(let o) = self { return o[name] ?? .null }; return .null } }
    var text: String { if case .string(let s) = self { return s }; return "" }
    var list: [Wire] { if case .array(let a) = self { return a }; return [] }
    var int: Int { if case .integer(let i) = self { return i }; return -1 }
    var flag: Bool { if case .bool(let b) = self { return b }; return false }
    func has(_ name: String) -> Bool { if case .object(let o) = self { return o[name] != nil }; return false }
    var blob: Data { Data(base64Encoded: text) ?? Data() }
    func replacing(_ name: String, _ value: Wire?) -> Wire {
        guard case .object(var o) = self else { return self }; o[name] = value; return .object(o)
    }
}

enum ConversionFailure: String, Error {
    case malformedInput, unsupportedVersion, resourceLimit, identityConflict, historyConflict
    case staleCheckpoint, approvalConflict, approvalMissing, historyUnavailable, unsafePath
    case publicationConflict, publicationFailure
    case scopeConflict, correspondenceConflict, correspondenceUnavailable, referenceConflict
    case continuityUnavailable, preparationIncomplete, preparationConflict, collisionExhausted, durabilityUncertain
    var held: Bool { [.approvalMissing,.historyUnavailable,.correspondenceUnavailable,.continuityUnavailable,.preparationIncomplete,.durabilityUncertain].contains(self) }
}

enum Limits {
    static let registry = 16 * 1024 * 1024
    static let history = 64 * 1024 * 1024
    static let request = 24 * 1024 * 1024
    static let approval = 16 * 1024
    static let record = 4 * 1024 * 1024
    static let bundle = 96 * 1024 * 1024
    static let entities = 100_000, references = 200_000, records = 4096, boundaries = 1
    static let depth = 64
}

enum Codec {
    static func hash(_ bytes: Data) -> String { SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined() }
    static func encode(_ v: Wire, pretty: Bool = false) throws -> Data {
        let e = JSONEncoder(); e.outputFormatting = pretty ? [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes] : [.sortedKeys, .withoutEscapingSlashes]
        return try e.encode(v)
    }
    static func digest(_ v: Wire) throws -> String { hash(try encode(v)) }
    static func equal(_ a: Wire, _ b: Wire) -> Bool { (try? encode(a)) == (try? encode(b)) }
    static func read(_ bytes: Data, limit: Int, pretty: Bool = false, canonical: Bool = true) throws -> Wire {
        guard !bytes.isEmpty, bytes.count <= limit else { throw ConversionFailure.resourceLimit }
        guard String(data: bytes, encoding: .utf8) != nil else { throw ConversionFailure.malformedInput }
        // Bound recursion before Foundation decoding or repeated-key scanning.
        var depth = 0, quoted = false, escape = false
        for c in bytes {
            if quoted { if escape { escape = false } else if c == 92 { escape = true } else if c == 34 { quoted = false } }
            else if c == 34 { quoted = true }
            else if c == 123 || c == 91 { depth += 1; guard depth <= Limits.depth else { throw ConversionFailure.resourceLimit } }
            else if c == 125 || c == 93 { depth -= 1; guard depth >= 0 else { throw ConversionFailure.malformedInput } }
        }
        guard !RegistryJSON.repeatsKey(Array(bytes)) else { throw ConversionFailure.malformedInput }
        do {
            let v = try JSONDecoder().decode(Wire.self, from: bytes)
            if canonical { guard try encode(v, pretty: pretty) == bytes else { throw ConversionFailure.malformedInput } }
            return v
        } catch let f as ConversionFailure { throw f }
        catch { throw ConversionFailure.malformedInput }
    }
    static func fields(_ v: Wire, _ required: [String], _ optional: [String] = []) throws {
        guard case .object(let o) = v, Set(required).isSubset(of: Set(o.keys)), Set(o.keys).isSubset(of: Set(required + optional)) else { throw ConversionFailure.malformedInput }
        for name in optional where o[name] != nil { if case .null = o[name]! { throw ConversionFailure.malformedInput } }
    }
    static func version(_ v: Wire, _ allowed: [Int]) throws {
        guard case .integer(let n) = v["schemaVersion"] else { throw ConversionFailure.malformedInput }
        guard allowed.contains(n) else { throw ConversionFailure.unsupportedVersion }
    }
    static func tagged(_ v: Wire, _ format: String) throws { try version(v, [1]); guard v["format"].text == format else { throw ConversionFailure.malformedInput } }
    static func token(_ v: Wire) throws { guard MappingText.isToken(v.text), v.text.utf8.count <= 256 else { throw ConversionFailure.malformedInput } }
    static func sha(_ v: Wire) throws { guard MappingText.isSHA256(v.text) else { throw ConversionFailure.malformedInput } }
    static func bytes(_ v: Wire, limit: Int) throws {
        guard case .string = v, v.blob.base64EncodedString() == v.text else { throw ConversionFailure.malformedInput }
        guard !v.blob.isEmpty, v.blob.count <= limit else { throw ConversionFailure.resourceLimit }
    }
    static func array(_ v: Wire, max: Int) throws {
        guard case .array = v else { throw ConversionFailure.malformedInput }
        guard v.list.count <= max else { throw ConversionFailure.resourceLimit }
    }
    static func tokens(_ v: Wire, max: Int = Limits.records) throws {
        try array(v, max: max)
        for t in v.list { try token(t) }
        try ordered(v.list.map { Data($0.text.utf8) })
    }
    static func ordered(_ bytes: [Data]) throws {
        for (a,b) in zip(bytes, bytes.dropFirst()) { guard a.lexicographicallyPrecedes(b) else { throw ConversionFailure.malformedInput } }
    }
    static func timestamp(_ v: Wire) throws {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; f.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = f.date(from: v.text), f.string(from: date) == v.text else { throw ConversionFailure.malformedInput }
    }
    static func blob(_ bytes: Data) -> Wire { .string(bytes.base64EncodedString()) }
}
