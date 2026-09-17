import SwiftUI

/// The single application composition root (ARCHITECTURE.md §4.1 "App": composition,
/// dependency wiring, environment/configuration).
///
/// Immutable value; dependencies are injected at construction. It is not a service
/// locator: only Phase 0 infrastructure lives here. Provider, repository, Journey,
/// and Live Activity lifecycle dependencies are added in their own phases.
nonisolated struct AppEnvironment: Sendable {
    let configuration: AppConfiguration
    let clock: any AppClock
    let logging: AppLogging

    /// Explicit construction path, used by tests and by `live()`.
    init(configuration: AppConfiguration, clock: any AppClock, logging: AppLogging) {
        self.configuration = configuration
        self.clock = clock
        self.logging = logging
    }

    /// Production environment: compiled build mode, system clock, unified logging.
    static func live() -> AppEnvironment {
        let configuration = AppConfiguration.live()
        return AppEnvironment(
            configuration: configuration,
            clock: SystemAppClock(),
            logging: AppLogging.live(subsystem: configuration.loggingSubsystem)
        )
    }
}

extension EnvironmentValues {
    /// The injected `AppEnvironment`. `TSUGINOApp` injects the live value at the
    /// root; the default exists only to satisfy SwiftUI's requirement for one.
    @Entry var appEnvironment: AppEnvironment = .live()
}
