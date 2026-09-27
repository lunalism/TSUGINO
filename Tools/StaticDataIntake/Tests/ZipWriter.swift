import Foundation

// A test-only ZIP writer (DEC-066 §H): stored (uncompressed) entries with
// computed CRC-32s. Unlike the system `zip`, it can write duplicate names,
// unsafe names, damaged CRCs, and folder entries. Archives are created in the
// test run's temporary directory and never committed.

struct ZipEntry {
    var name: [UInt8]
    var data: [UInt8]
    /// When set, the recorded CRC-32 that deliberately mismatches the data.
    var recordedCRC: UInt32?
    var isFolder = false

    init(_ name: String, _ data: Data, recordedCRC: UInt32? = nil) {
        self.name = Array(name.utf8)
        self.data = Array(data)
        self.recordedCRC = recordedCRC
    }

    static func folder(_ name: String) -> ZipEntry {
        var entry = ZipEntry(name, Data())
        entry.isFolder = true
        return entry
    }
}

enum ZipWriter {
    static func archive(_ entries: [ZipEntry]) -> Data {
        var output: [UInt8] = []
        var central: [UInt8] = []
        for entry in entries {
            let offset = UInt32(output.count)
            let crc = entry.recordedCRC ?? crc32(entry.data)
            let size = UInt32(entry.data.count)
            let isASCII = entry.name.allSatisfy { $0 < 0x80 }
            let flags: UInt16 = isASCII ? 0 : 0x0800
            let date: UInt16 = 0x21  // 1980-01-01

            output += le32(0x0403_4B50) + le16(20) + le16(flags) + le16(0) + le16(0) + le16(date)
            output += le32(crc) + le32(size) + le32(size) + le16(UInt16(entry.name.count)) + le16(0)
            output += entry.name + entry.data

            let mode: UInt32 = entry.isFolder ? 0o040755 : 0o100644
            central += le32(0x0201_4B50) + le16(0x0314) + le16(20) + le16(flags) + le16(0) + le16(0) + le16(date)
            central += le32(crc) + le32(size) + le32(size) + le16(UInt16(entry.name.count))
            central += le16(0) + le16(0) + le16(0) + le16(0) + le32(mode << 16) + le32(offset)
            central += entry.name
        }
        let centralOffset = UInt32(output.count)
        output += central
        output += le32(0x0605_4B50) + le16(0) + le16(0)
        output += le16(UInt16(entries.count)) + le16(UInt16(entries.count))
        output += le32(UInt32(central.count)) + le32(centralOffset) + le16(0)
        return Data(output)
    }

    private static func le16(_ value: UInt16) -> [UInt8] {
        [UInt8(value & 0xFF), UInt8(value >> 8)]
    }

    private static func le32(_ value: UInt32) -> [UInt8] {
        (0..<4).map { UInt8((value >> ($0 * 8)) & 0xFF) }
    }

    private static let table: [UInt32] = (0..<256).map { index in
        var value = UInt32(index)
        for _ in 0..<8 {
            value = (value & 1) != 0 ? 0xEDB8_8320 ^ (value >> 1) : value >> 1
        }
        return value
    }

    static func crc32(_ bytes: [UInt8]) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in bytes {
            crc = table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
        }
        return crc ^ 0xFFFF_FFFF
    }
}
