#if DEBUG
import Foundation
import CryptoKit

/// DEC-084 slice A only. Values are syntax, never registry or review authority.
/// Keeping the wire tree separate avoids widening any production enum/reader.
nonisolated indirect enum SyntheticRegistrationValue: Codable, Sendable {
    case object([String: Self]), array([Self]), string(String), integer(Int), bool(Bool), null
    // Parseable JSON, but no accepted field admits a non-Int number. Retaining this
    // until shape validation lets an unsupported version reject before its contents.
    case nonInteger(Double)

    init(from decoder: any Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Int.self) { self = .integer(v) }
        else if let v = try? c.decode(Double.self) { self = .nonInteger(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([Self].self) { self = .array(v) }
        else { self = .object(try c.decode([String: Self].self)) }
    }

    func encode(to encoder: any Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .object(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .integer(let v): try c.encode(v)
        case .bool(let v): try c.encode(v)
        case .null: try c.encodeNil()
        case .nonInteger(let v): try c.encode(v)
        }
    }

    subscript(_ key: String) -> Self? { if case .object(let v) = self { v[key] } else { nil } }
    var text: String? { if case .string(let v) = self { v } else { nil } }
    var items: [Self] { if case .array(let v) = self { v } else { [] } }
}

nonisolated enum SyntheticRegistrationIssue: Int, Error, CaseIterable, Sendable {
    case unsupportedVersion, malformedInput, historyConflict, staleCheckpoint, approvalConflict
    case identityConflict, referenceConflict, blockedOperation, snapshotConflict, approvalMissing
    case historyUnavailable, scopeUnavailable, correspondenceUnavailable, snapshotUnavailable
}

nonisolated enum SyntheticRegistrationFormat: Sendable {
    case registry, checkpoint, approval, payload, approved, evidence, s9Packet, s9Artifact
    case seedRecord, history, envelope
}

/// Exact immutable encoded representation. Construction only checks slice-A invariants.
nonisolated struct SyntheticRegistrationDocument: Sendable {
    let format: SyntheticRegistrationFormat
    let value: SyntheticRegistrationValue
    let bytes: Data
    var sha256: String { SyntheticTripRegistrationCodec.digest(bytes) }
    fileprivate init(_ format: SyntheticRegistrationFormat, _ value: SyntheticRegistrationValue, _ bytes: Data) {
        self.format = format; self.value = value; self.bytes = bytes
    }
}

nonisolated enum SyntheticTripRegistrationCodec {
    // Finite synthetic packets; no filesystem loader and no production persistence.
    static let maximumBytes = 16 * 1024 * 1024

    static func digest(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    static func encoded(_ value: SyntheticRegistrationValue, pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = pretty ? [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes] : [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    /// Producers get canonical set ordering; ordered source sequences are never reordered.
    static func make(_ format: SyntheticRegistrationFormat, _ value: SyntheticRegistrationValue) throws -> SyntheticRegistrationDocument {
        let canonical = try SyntheticRegistrationSchema.check(format, value)
        let bytes = try encoded(canonical, pretty: format == .registry)
        guard bytes.count <= maximumBytes else { throw SyntheticRegistrationIssue.malformedInput }
        return .init(format, canonical, bytes)
    }

    /// Byte identity rejects null optionals, unknown fields, noncanonical integers/escaping,
    /// noncanonical set order and other data that decoding/re-encoding would silently lose.
    static func read(_ format: SyntheticRegistrationFormat, _ bytes: Data) throws -> SyntheticRegistrationDocument {
        guard !bytes.isEmpty, bytes.count <= maximumBytes,
              !RegistryJSON.repeatsKey(Array(bytes)) else { throw SyntheticRegistrationIssue.malformedInput }
        do {
            let value = try JSONDecoder().decode(SyntheticRegistrationValue.self, from: bytes)
            let doc = try make(format, value)
            guard doc.bytes == bytes else { throw SyntheticRegistrationIssue.malformedInput }
            return doc
        } catch let issue as SyntheticRegistrationIssue { throw issue }
        catch { throw SyntheticRegistrationIssue.malformedInput }
    }
}
#endif
