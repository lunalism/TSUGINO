import Foundation
import Testing
@testable import TSUGINO

struct AppEnvironmentTests {
    @Test func explicitInitUsesInjectedDependencies() throws {
        let instant = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedAppClock(now: instant)
        let sink = RecordingLogSink()
        let configuration = try AppConfiguration.forTesting()
        let environment = AppEnvironment(
            configuration: configuration,
            clock: clock,
            logging: AppLogging(subsystem: configuration.loggingSubsystem, sink: sink)
        )

        #expect(environment.clock.now == instant, "environment must use the injected clock, not system time")
        #expect(environment.configuration == configuration)

        environment.logging.log(.configurationValidated(buildMode: .test, enabledFlagCount: 0))
        #expect(sink.recorded.map(\.event) == [.configurationValidated(buildMode: .test, enabledFlagCount: 0)])
    }

    @Test func injectedClockIsReadThroughNotCopied() throws {
        // Two environments with different fixed clocks report different instants.
        let a = AppEnvironment(
            configuration: try .forTesting(),
            clock: FixedAppClock(now: Date(timeIntervalSince1970: 1)),
            logging: AppLogging(subsystem: "t", sink: RecordingLogSink())
        )
        let b = AppEnvironment(
            configuration: try .forTesting(),
            clock: FixedAppClock(now: Date(timeIntervalSince1970: 2)),
            logging: AppLogging(subsystem: "t", sink: RecordingLogSink())
        )

        #expect(a.clock.now != b.clock.now)
    }

    @Test func liveEnvironmentIsComposedFromLiveConfiguration() {
        let environment = AppEnvironment.live()

        #expect(environment.configuration == AppConfiguration.live())
        #expect(environment.logging.subsystem == environment.configuration.loggingSubsystem)
        #expect(environment.clock is SystemAppClock)
    }
}
