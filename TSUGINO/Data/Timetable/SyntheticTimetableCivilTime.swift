#if DEBUG
import Foundation

/// Integral proleptic Gregorian arithmetic, independent of Calendar/TimeZone/locale.
nonisolated enum SyntheticTimetableCivilTime {
    static let minimum: Int64 = 946_425_600 // 1999-12-29T00:00:00Z
    static let maximum: Int64 = 4_102_704_000 // 2100-01-04T00:00:00Z, exclusive
    static let offsetLimit: Int64 = 50_400

    enum Parse<Value> { case value(Value), invalid, unsupported }

    static func date(_ text: String) -> Parse<Int64> {
        let b = Array(text.utf8.prefix(11))
        guard b.count == 10, b[4] == 45, b[7] == 45,
              [0,1,2,3,5,6,8,9].allSatisfy({ (48...57).contains(b[$0]) }) else { return .invalid }
        let y = Int(b[0]-48)*1000 + Int(b[1]-48)*100 + Int(b[2]-48)*10 + Int(b[3]-48)
        let m = Int(b[5]-48)*10 + Int(b[6]-48), d = Int(b[8]-48)*10 + Int(b[9]-48)
        let leap = y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)
        let lengths = [31, leap ? 29 : 28, 31,30,31,30,31,31,30,31,30,31]
        guard y > 0, (1...12).contains(m), d >= 1, d <= lengths[m-1] else { return .invalid }
        guard (2000...2099).contains(y) else { return .unsupported }
        // All intermediates have small bounds established above. Days since 1970-01-01.
        let adjusted = y - (m <= 2 ? 1 : 0)
        let era = adjusted / 400, yo = adjusted - era * 400
        let mp = m + (m > 2 ? -3 : 9)
        let doy = (153 * mp + 2) / 5 + d - 1
        let days = era * 146097 + yo * 365 + yo / 4 - yo / 100 + doy - 719468
        return .value(Int64(days))
    }

    static func clock(_ text: String) -> Parse<Int64> {
        let b = Array(text.utf8.prefix(9))
        guard b.count == 8, b[2] == 58, b[5] == 58,
              [0,1,3,4,6,7].allSatisfy({ (48...57).contains(b[$0]) }) else { return .invalid }
        let h = Int64(b[0]-48)*10 + Int64(b[1]-48)
        let m = Int64(b[3]-48)*10 + Int64(b[4]-48), s = Int64(b[6]-48)*10 + Int64(b[7]-48)
        guard m < 60, s < 60 else { return .invalid }
        guard h < 72 else { return .unsupported }
        return .value(h * 3600 + m * 60 + s)
    }

    static func add(_ a: Int64, _ b: Int64) -> Int64? {
        let (value, overflow) = a.addingReportingOverflow(b)
        return overflow ? nil : value
    }
    static func localCoordinate(day: Int64, seconds: Int64) -> Int64? {
        let (base, overflow) = day.multipliedReportingOverflow(by: 86400)
        guard !overflow else { return nil }
        // This is a zero-offset civil coordinate, NOT elapsed time from zoned midnight.
        return add(base, seconds)
    }

    static func resolve(local: Int64, zone: SyntheticTimetableZone) -> Result<TimetableInstant, ResolutionFailure> {
        func instant(_ offset: Int64) -> TimetableInstant? {
            guard (-offsetLimit...offsetLimit).contains(offset),
                  let u = add(local, -offset), (minimum..<maximum).contains(u),
                  add(u, offset) == local else { return nil }
            return TimetableInstant(Date(timeIntervalSince1970: Double(u)))
        }
        switch zone {
        case .fixed(let offset):
            guard let value = instant(offset) else { return .failure(.arithmeticRange) }
            return .success(value)
        case .transitions(let intervals):
            guard let low = add(local, -offsetLimit), let high = add(local, offsetLimit),
                  let first = intervals.first, let last = intervals.last,
                  first.start <= low, last.end > high else { return .failure(.zoneCoverage) }
            var found: TimetableInstant?
            for interval in intervals {
                guard (-offsetLimit...offsetLimit).contains(interval.offset),
                      let u = add(local, -interval.offset) else { return .failure(.arithmeticRange) }
                if u >= interval.start && u < interval.end {
                    guard let value = instant(interval.offset) else { return .failure(.arithmeticRange) }
                    if found != nil { return .failure(.ambiguousLocalTime) }
                    found = value
                }
            }
            guard let found else { return .failure(.nonexistentLocalTime) }
            return .success(found)
        case .unsupported: return .failure(.zoneCoverage) // Rejected in the envelope stage.
        }
    }
    enum ResolutionFailure: Error { case arithmeticRange, zoneCoverage, nonexistentLocalTime, ambiguousLocalTime }
}
#endif
