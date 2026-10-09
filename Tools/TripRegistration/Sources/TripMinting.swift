import Foundation
import Darwin

enum TripMinting {
    struct Draw { let id: String, attempts: Int }
    static func mint(heldBodies: Set<String>) throws -> Draw {
        try draw(heldBodies) {
            // Request exactly ten bytes from the OS CSPRNG for each 80-bit candidate.
            var bytes = [UInt8](repeating:0,count:10)
            bytes.withUnsafeMutableBytes { arc4random_buf($0.baseAddress!,10) }
            return bytes
        }
    }
    #if TRIP_CONVERSION_TESTING
    static func mintForTest<G: RandomNumberGenerator>(heldBodies: Set<String>, using rng: inout G) throws -> Draw {
        try draw(heldBodies) {
            let high = rng.next(), low = rng.next()
            return (0..<8).map { UInt8(truncatingIfNeeded:high >> (56 - 8 * $0)) }
                + [UInt8(truncatingIfNeeded:low >> 56),UInt8(truncatingIfNeeded:low >> 48)]
        }
    }
    #endif
    private static func draw(_ held: Set<String>, bytes: () -> [UInt8]) throws -> Draw {
        for attempt in 1...8 {
            let bits = bytes()
            var body = [UInt8](), buffer: UInt32 = 0, count = 0
            for byte in bits {
                buffer = (buffer << 8) | UInt32(byte); count += 8
                while count >= 5 { count -= 5; body.append(MintedIdentifier.alphabet[Int((buffer >> UInt32(count)) & 31)]) }
            }
            let label = String(decoding:body,as:UTF8.self)
            if !held.contains(label) { return .init(id:"trp_" + label,attempts:attempt) }
        }
        throw ConversionFailure.collisionExhausted
    }
}
