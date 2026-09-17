import Foundation
import Testing
@testable import TSUGINO

struct AppClockTests {
    @Test func fixedClockReturnsInjectedInstantDeterministically() {
        let instant = Date(timeIntervalSince1970: 1_800_000_000)
        let clock = FixedAppClock(now: instant)

        #expect(clock.now == instant)
        #expect(clock.now == instant, "repeated reads must not drift")
    }

    @Test func fixedClockAdvancedProducesNewValueAndLeavesOriginalUnchanged() {
        let base = FixedAppClock(now: Date(timeIntervalSince1970: 0))
        let later = base.advanced(by: 90)

        #expect(base.now == Date(timeIntervalSince1970: 0))
        #expect(later.now == Date(timeIntervalSince1970: 90))
    }

    @Test func fixedClockIsUsableThroughTheProtocol() {
        let instant = Date(timeIntervalSince1970: 42)
        let clock: any AppClock = FixedAppClock(now: instant)

        #expect(clock.now == instant)
    }
}
