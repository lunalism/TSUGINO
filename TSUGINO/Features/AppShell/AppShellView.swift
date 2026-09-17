import SwiftUI

/// Phase 0 placeholder root screen. Intentionally contains no product UI.
///
/// The Debug Live Activity bootstrap section below is an engineering validation
/// control; its visibility is decided by `AppConfiguration` alone (never by `#if`).
struct AppShellView: View {
    @Environment(\.appEnvironment) private var environment

    var body: some View {
        VStack(spacing: 32) {
            Text("TSUGINO")
                .font(.largeTitle)
                .fontWeight(.semibold)

            if DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: environment.configuration) {
                DebugLiveActivityBootstrapSection(logging: environment.logging)
            }
        }
    }
}
