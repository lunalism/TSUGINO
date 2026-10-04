import SwiftUI

/// The single application composition root (ARCHITECTURE.md §4.1 "App": composition,
/// dependency wiring, environment/configuration).
///
/// Immutable value; dependencies are injected at construction. It is not a service
/// locator: infrastructure and an explicitly supplied routing port live here.
/// Consumer scopes own the coordinators they obtain; live routing stays unconfigured.
nonisolated struct AppEnvironment: Sendable {
    let configuration: AppConfiguration
    let clock: any AppClock
    let logging: AppLogging
    private let routeSearching: (any RouteSearching)?

    /// Explicit construction path, used by tests and by `live()`.
    init(configuration: AppConfiguration, clock: any AppClock, logging: AppLogging,
         routeSearching: (any RouteSearching)? = nil) {
        self.configuration = configuration
        self.clock = clock
        self.logging = logging
        self.routeSearching = routeSearching
    }

    /// Creates one independent owner. The receiving consumer must retain it and
    /// explicitly dispose it when its lifetime ends. No search or time capture here.
    @MainActor
    func makeRouteSearchCoordinator() -> RouteSearchProvision {
        guard let routeSearching else { return .notConfigured }
        return .ready(RouteSearchCoordinator(searcher: routeSearching, clock: clock))
    }

    /// Production environment: compiled build mode, system clock, unified logging.
    static func live() -> AppEnvironment {
        let configuration = AppConfiguration.live()
        return AppEnvironment(
            configuration: configuration,
            clock: SystemAppClock(),
            logging: AppLogging.live(subsystem: configuration.loggingSubsystem),
            routeSearching: nil
        )
    }
}

/// Composition capability, not a Domain search result or a fallback searcher.
@MainActor
enum RouteSearchProvision {
    case notConfigured
    case ready(RouteSearchCoordinator)
}

extension EnvironmentValues {
    /// The injected `AppEnvironment`. `TSUGINOApp` injects the live value at the
    /// root; the default exists only to satisfy SwiftUI's requirement for one.
    @Entry var appEnvironment: AppEnvironment = .live()
}
