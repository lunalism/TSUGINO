import Foundation

let crosswalkBridgeTests: [TestCase] = [
    ("bridge frame preserves scalar order delimiters and repeated positions", { _ in
        let values = ["é", "e\u{301}", "syn,|\n\0key", " white ", "é"]
        var bytes: [UInt8] = []
        func word(_ n: UInt32) { bytes += [UInt8((n >> 24) & 255), UInt8((n >> 16) & 255), UInt8((n >> 8) & 255), UInt8(n & 255)] }
        word(2); word(UInt32(values.count))
        for value in values { let raw = Array(value.utf8); word(UInt32(raw.count)); bytes += raw }
        let decoded = try CrosswalkBridge.keys(Data(bytes))
        try check(decoded == values.map { ExactValue($0)! }, "scalar/order/repetition changed")
        try check(decoded[0] != decoded[1] && decoded[0] == decoded[4], "normalized")
    }),
    ("bridge frame rejects truncation overflow invalid UTF8 and trailing bytes", { _ in
        for bytes: [UInt8] in [[], [0,0,0,2,0,0,0,1,255,255,255,255], [0,0,0,2,0,0,0,1,0,0,0,1,255], [0,0,0,2,0,0,0,1,0,0,0,1,65,0]] {
            do { _ = try CrosswalkBridge.keys(Data(bytes)); throw TestFailure(message:"frame accepted") }
            catch TripStationCrosswalk.Failure.invalidInput { }
        }
    }),
    ("bridge frame ABI version and empty count reject", { _ in
        for bytes: [UInt8] in [[0,0,0,1,0,0,0,1], [0,0,0,2,0,0,0,0], [0,0,0,2,0,0,0,65]] {
            do { _ = try CrosswalkBridge.keys(Data(bytes)); throw TestFailure(message:"ABI accepted") }
            catch TripStationCrosswalk.Failure.invalidInput { }
        }
    }),
]
