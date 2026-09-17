import Testing
@testable import TSUGINO

struct AppConfigurationTests {
    @Test func explicitDebugConfiguration() throws {
        let configuration = try AppConfiguration(
            buildMode: .debug,
            featureFlags: .defaults(for: .debug)
        )

        #expect(configuration.buildMode == .debug)
        #expect(configuration.featureFlags == .defaults(for: .debug))
        #expect(configuration.loggingSubsystem == AppConfiguration.defaultLoggingSubsystem)
    }

    @Test func explicitReleaseConfiguration() throws {
        let configuration = try AppConfiguration(
            buildMode: .release,
            featureFlags: .defaults(for: .release)
        )

        #expect(configuration.buildMode == .release)
        #expect(configuration.featureFlags == .allDisabled)
    }

    @Test func explicitTestConfiguration() throws {
        let configuration = try AppConfiguration.forTesting()

        #expect(configuration.buildMode == .test)
        #expect(configuration.featureFlags == .allDisabled)
    }

    @Test func testConfigurationAcceptsExplicitFlagOverride() throws {
        let configuration = try AppConfiguration.forTesting(
            featureFlags: .allDisabled.enabling(.debugLiveActivityBootstrapControl)
        )

        #expect(configuration.featureFlags.isEnabled(.debugLiveActivityBootstrapControl))
    }

    @Test func releaseRejectsDebugOnlyFlag() {
        #expect(throws: AppConfigurationError.debugOnlyFlagEnabledInRelease(.debugLiveActivityBootstrapControl)) {
            try AppConfiguration(
                buildMode: .release,
                featureFlags: .allDisabled.enabling(.debugLiveActivityBootstrapControl)
            )
        }
    }

    @Test func emptyLoggingSubsystemIsRejected() {
        #expect(throws: AppConfigurationError.emptyLoggingSubsystem) {
            try AppConfiguration(buildMode: .test, featureFlags: .allDisabled, loggingSubsystem: "")
        }
    }

    @Test func liveConfigurationUsesCompiledBuildModeAndCentralDefaults() {
        let live = AppConfiguration.live()

        #expect(live.buildMode == AppConfiguration.compiledBuildMode)
        #expect(live.buildMode != .test, "live() must never report test mode")
        #expect(live.featureFlags == .defaults(for: live.buildMode))
        #expect(live.loggingSubsystem == AppConfiguration.defaultLoggingSubsystem)
    }

    @Test func liveDefaultsAreValidForEveryNonTestBuildMode() throws {
        // Guards the precondition inside `live()`: central defaults must validate.
        for mode in [BuildMode.debug, .release] {
            _ = try AppConfiguration(buildMode: mode, featureFlags: .defaults(for: mode))
        }
    }
}
