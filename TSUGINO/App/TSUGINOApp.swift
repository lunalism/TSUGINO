import SwiftUI

@main
struct TSUGINOApp: App {
    /// Composition root: the live environment is built exactly once here and
    /// injected into the view hierarchy.
    private let environment: AppEnvironment

    init() {
        let environment = AppEnvironment.live()
        environment.logging.log(.environmentComposed(buildMode: environment.configuration.buildMode))
        self.environment = environment
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environment(\.appEnvironment, environment)
        }
    }
}
