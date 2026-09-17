import Testing
@testable import TSUGINO

struct FeatureFlagsTests {
    @Test func releaseDefaultsEnableNothing() {
        let flags = FeatureFlags.defaults(for: .release)

        for flag in FeatureFlag.allCases {
            #expect(flags.isEnabled(flag) == false, "\(flag) must be off in Release")
        }
        #expect(flags == .allDisabled)
    }

    @Test func testDefaultsEnableNothing() {
        #expect(FeatureFlags.defaults(for: .test) == .allDisabled)
    }

    @Test func debugDefaultsEnableOnlyDebugOnlyFlags() {
        let flags = FeatureFlags.defaults(for: .debug)

        for flag in FeatureFlag.allCases {
            #expect(flags.isEnabled(flag) == flag.isDebugOnly)
        }
    }

    @Test func explicitOverrideEnablesAndDisablesOneFlag() {
        let enabled = FeatureFlags.allDisabled.enabling(.debugLiveActivityBootstrapControl)
        #expect(enabled.isEnabled(.debugLiveActivityBootstrapControl))

        let disabled = enabled.disabling(.debugLiveActivityBootstrapControl)
        #expect(disabled == .allDisabled)
    }

    @Test func flagsAreNeverEnabledUnlessExplicitlySet() {
        let flags = FeatureFlags(enabled: [])

        for flag in FeatureFlag.allCases {
            #expect(flags.isEnabled(flag) == false)
        }
    }

    @Test func everyFlagDeclaresOwnerPurposeAndRemovalCriteria() {
        for flag in FeatureFlag.allCases {
            #expect(!flag.owner.isEmpty, "\(flag) needs an owner (Rule 41)")
            #expect(!flag.purpose.isEmpty, "\(flag) needs a purpose (Rule 41)")
            #expect(!flag.removalCriteria.isEmpty, "\(flag) needs removal criteria (Rule 41)")
        }
    }
}
