/// How the app was built or is being exercised. `test` is an `AppConfiguration`
/// mode used by tests; it is not a third Xcode build configuration.
nonisolated enum BuildMode: String, CaseIterable, Sendable, Codable {
    case debug
    case release
    case test
}

/// Typed configuration errors. Invalid configuration fails explicitly; production
/// values are never silently invented.
nonisolated enum AppConfigurationError: Error, Equatable, Sendable {
    case emptyLoggingSubsystem
    case debugOnlyFlagEnabledInRelease(FeatureFlag)
}

/// Typed application configuration (ARCHITECTURE.md §43).
///
/// Phase 0 carries only what exists: build mode, feature flags, and the stable
/// logging subsystem. There are no API keys, provider URLs, secrets, or persisted
/// values; those are later-phase concerns handled through secure configuration.
/// Compiler build-condition resolution happens in exactly one place: `live()`.
nonisolated struct AppConfiguration: Sendable, Equatable {
    /// Stable subsystem identifier used for unified logging.
    static let defaultLoggingSubsystem = "com.lunalism.TSUGINO"

    let buildMode: BuildMode
    let featureFlags: FeatureFlags
    let loggingSubsystem: String

    /// Explicit, validated construction. Used by tests and by `live()`.
    init(
        buildMode: BuildMode,
        featureFlags: FeatureFlags,
        loggingSubsystem: String = AppConfiguration.defaultLoggingSubsystem
    ) throws(AppConfigurationError) {
        if loggingSubsystem.isEmpty {
            throw .emptyLoggingSubsystem
        }
        if buildMode == .release,
           let offending = featureFlags.enabledFlags.filter(\.isDebugOnly).sorted(by: { $0.rawValue < $1.rawValue }).first {
            throw .debugOnlyFlagEnabledInRelease(offending)
        }
        self.buildMode = buildMode
        self.featureFlags = featureFlags
        self.loggingSubsystem = loggingSubsystem
    }

    /// The build mode the running binary was compiled for. This is the single
    /// place in the app where `#if DEBUG` decides configuration.
    static var compiledBuildMode: BuildMode {
        #if DEBUG
        .debug
        #else
        .release
        #endif
    }

    /// Production configuration derived centrally from the build environment.
    ///
    /// Defaults are valid by construction (`FeatureFlags.defaults(for:)` never enables
    /// a debug-only flag in Release), so a validation failure here is a programming
    /// error and stops the app explicitly rather than continuing with invented values.
    static func live() -> AppConfiguration {
        let mode = compiledBuildMode
        do {
            return try AppConfiguration(
                buildMode: mode,
                featureFlags: FeatureFlags.defaults(for: mode)
            )
        } catch {
            preconditionFailure("Live AppConfiguration is invalid: \(error)")
        }
    }

    /// Convenience for tests: `test` mode with explicit flags (all disabled by default).
    static func forTesting(featureFlags: FeatureFlags = .allDisabled) throws(AppConfigurationError) -> AppConfiguration {
        try AppConfiguration(buildMode: .test, featureFlags: featureFlags)
    }
}
