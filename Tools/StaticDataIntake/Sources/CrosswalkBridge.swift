import Foundation

/// ABI 2: all integer framing is unsigned big endian. No Swift objects cross ABI.
enum CrosswalkBridge {
    static let maxKeyBytes = 4096
    static let maxFrameBytes = 8 + 64 * (4 + maxKeyBytes)
    static func keys(_ data: Data) throws -> [ExactValue] {
        let bytes = Array(data)
        var offset = 0
        func word() throws -> Int {
            guard offset <= bytes.count - 4 else { throw TripStationCrosswalk.Failure.invalidInput }
            let result = bytes[offset..<offset+4].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
            offset += 4; return Int(result)
        }
        guard bytes.count <= maxFrameBytes, try word() == 2 else { throw TripStationCrosswalk.Failure.invalidInput }
        let count = try word()
        guard (1...64).contains(count) else { throw TripStationCrosswalk.Failure.invalidInput }
        var result: [ExactValue] = []
        for _ in 0..<count {
            let length = try word()
            guard (1...maxKeyBytes).contains(length), length <= bytes.count - offset,
                  let text = String(bytes: bytes[offset..<offset+length], encoding: .utf8),
                  let value = ExactValue(text) else { throw TripStationCrosswalk.Failure.invalidInput }
            result.append(value); offset += length
        }
        guard offset == bytes.count else { throw TripStationCrosswalk.Failure.invalidInput }
        return result
    }
    struct Configuration: Decodable {
        let registryPath: String, reviewsPath: String, registrySHA256: String, reviewsSHA256: String
        let registryRevision: Int
        let sourceID: String, inputSHA256: String, namespace: String
        let expectedCount: Int
        enum CodingKeys: String, CodingKey, CaseIterable {
            case registryPath, reviewsPath, registrySHA256, reviewsSHA256, registryRevision, sourceID, inputSHA256, namespace, expectedCount
        }
        init(from decoder: Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            registryPath = try c.decode(String.self, forKey: .registryPath)
            reviewsPath = try c.decode(String.self, forKey: .reviewsPath)
            registrySHA256 = try c.decode(String.self, forKey: .registrySHA256)
            reviewsSHA256 = try c.decode(String.self, forKey: .reviewsSHA256)
            registryRevision = try c.decode(Int.self, forKey: .registryRevision)
            sourceID = try c.decode(String.self, forKey: .sourceID)
            inputSHA256 = try c.decode(String.self, forKey: .inputSHA256)
            namespace = try c.decode(String.self, forKey: .namespace)
            expectedCount = try c.decode(Int.self, forKey: .expectedCount)
        }
    }
    static func run(configuration: Data, frame: Data) throws -> TripStationCrosswalk.Result {
        guard !RegistryJSON.repeatsKey(Array(configuration)) else { throw TripStationCrosswalk.Failure.invalidInput }
        let c = try JSONDecoder().decode(Configuration.self, from: configuration)
        let values = try keys(frame)
        guard values.count == c.expectedCount, c.namespace == "gtfs.stop_id" else { throw TripStationCrosswalk.Failure.invalidInput }
        let expected = TripStationCrosswalk.Expectations(registrySHA256: c.registrySHA256, registryRevision: c.registryRevision,
            reviewsSHA256: c.reviewsSHA256, sourceID: c.sourceID, inputSHA256: c.inputSHA256, count: c.expectedCount)
        try expected.validate()
        // Compile-time checkout identity, never a caller-selected exclusion boundary.
        let rootPath = (0..<4).reduce(#filePath) { path, _ in (path as NSString).deletingLastPathComponent }
        guard FileManager.default.fileExists(atPath: rootPath + "/.git"), let root = FileIdentity(path: rootPath) else { throw TripStationCrosswalk.Failure.unsafePath }
        let registry = try TripStationCrosswalk.Input(path: c.registryPath, root: root)
        let reviews = try TripStationCrosswalk.Input(path: c.reviewsPath, root: root)
        let result = try TripStationCrosswalk.verify(registryBytes: registry.bytes, reviewsBytes: reviews.bytes,
            keys: .init(sourceID: c.sourceID, namespace: c.namespace, values: values), expected: expected)
        try registry.verify(); try reviews.verify()
        return result
    }
}

@_cdecl("tsugino_crosswalk_abi_version")
public func tsuginoCrosswalkABIVersion() -> UInt32 { 2 }

/// Caller must provide valid readable buffers of the declared lengths and a writable,
/// aligned 8-word result buffer. No pointers are retained; output is zeroed on failure.
/// Return 0=complete, 1=held, 2=invalid input, 3=artifact identity/revision,
/// 4=registry/reviews, 5=path/mutation/I/O. Fixed categories never carry private values.
@_cdecl("tsugino_crosswalk_review_v2")
public func tsuginoCrosswalkReview(_ config: UnsafePointer<UInt8>?, _ configLength: UInt64,
                                  _ frame: UnsafePointer<UInt8>?, _ frameLength: UInt64,
                                  _ output: UnsafeMutablePointer<UInt64>?, _ outputCount: UInt64) -> Int32 {
    guard let output, outputCount == 8 else { return 2 }
    for i in 0..<8 { output[i] = 0 }
    guard let config, let frame, (1...65536).contains(configLength),
          (8...UInt64(CrosswalkBridge.maxFrameBytes)).contains(frameLength) else { return 2 }
    do {
        let result = try CrosswalkBridge.run(configuration: Data(bytes: config, count: Int(configLength)),
                                            frame: Data(bytes: frame, count: Int(frameLength)))
        let resolved = result.outcomes.filter { $0 == .resolved }.count
        let words: [UInt64] = [UInt64(result.outcomes.count), UInt64(resolved), UInt64(result.outcomes.count-resolved), UInt64(result.repeated),
                               1, result.reviewEvidence.rawValue, result.memberIdentity.rawValue, result.ready ? 1 : 0]
        for i in 0..<8 { output[i] = words[i] }
        return result.ready ? 0 : 1
    } catch let failure as TripStationCrosswalk.Failure {
        switch failure {
        case .identityMismatch, .revisionMismatch: return 3
        case .invalidRegistry, .invalidReviews: return 4
        case .unsafePath, .changedInput: return 5
        default: return 2
        }
    } catch { return 2 }
}
