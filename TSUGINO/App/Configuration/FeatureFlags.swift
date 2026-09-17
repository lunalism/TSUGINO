/// Typed feature-flag foundation (ARCHITECTURE.md §42, RULES.md Rule 41).
///
/// Flags are an exhaustive enum, so feature code can never ask about an unknown
/// flag and an unknown flag can never be "on". Every flag carries the owner, purpose,
/// and removal criteria that Rule 41 requires. Values are resolved centrally through
/// `FeatureFlags`; there are no remote flags, persistence, or analytics.
nonisolated enum FeatureFlag: String, CaseIterable, Sendable, Codable {
    /// Placeholder gate for the Debug-only manual Live Activity bootstrap trigger
    /// (Phase 0 Track A, Step A3). No UI or ActivityKit behavior exists behind it yet.
    case debugLiveActivityBootstrapControl

    /// True when the flag may only ever be enabled in non-Release builds.
    var isDebugOnly: Bool {
        switch self {
        case .debugLiveActivityBootstrapControl: true
        }
    }

    /// Who is accountable for the flag's lifecycle.
    var owner: String {
        switch self {
        case .debugLiveActivityBootstrapControl: "Phase 0 — Track A"
        }
    }

    /// Why the flag exists.
    var purpose: String {
        switch self {
        case .debugLiveActivityBootstrapControl:
            "Gate the Debug-only manual trigger used to verify the Live Activity extension on device."
        }
    }

    /// The condition under which the flag is removed (Rule 41: no permanent flags).
    var removalCriteria: String {
        switch self {
        case .debugLiveActivityBootstrapControl:
            "Remove when Phase 9 introduces LiveActivityCoordinator and the product Live Activity lifecycle."
        }
    }

    /// Central default per build mode. Release defaults are always safe:
    /// nothing is enabled in Release. Test defaults are all-disabled so tests
    /// state what they need explicitly.
    func defaultValue(for mode: BuildMode) -> Bool {
        switch mode {
        case .release, .test:
            false
        case .debug:
            isDebugOnly
        }
    }
}

/// An immutable, typed set of enabled flags.
nonisolated struct FeatureFlags: Sendable, Equatable {
    private let enabled: Set<FeatureFlag>

    /// Explicit construction (tests, or central defaults).
    init(enabled: Set<FeatureFlag>) {
        self.enabled = enabled
    }

    /// Every flag disabled.
    static let allDisabled = FeatureFlags(enabled: [])

    /// Central defaults for a build mode, derived from each flag's `defaultValue(for:)`.
    static func defaults(for mode: BuildMode) -> FeatureFlags {
        FeatureFlags(enabled: Set(FeatureFlag.allCases.filter { $0.defaultValue(for: mode) }))
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        enabled.contains(flag)
    }

    /// Flags that are enabled, for validation and diagnostics.
    var enabledFlags: Set<FeatureFlag> { enabled }

    /// A copy with `flag` enabled (test override).
    func enabling(_ flag: FeatureFlag) -> FeatureFlags {
        FeatureFlags(enabled: enabled.union([flag]))
    }

    /// A copy with `flag` disabled (test override).
    func disabling(_ flag: FeatureFlag) -> FeatureFlags {
        FeatureFlags(enabled: enabled.subtracting([flag]))
    }
}
