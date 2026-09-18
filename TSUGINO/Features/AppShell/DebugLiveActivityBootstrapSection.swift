import SwiftUI

/// Debug-only engineering control that drives the synthetic bootstrap Live Activity.
/// Not product UI. Shown by `AppShellView` only when
/// `DebugLiveActivityBootstrapPolicy.isControlVisible(configuration:)` is true.
struct DebugLiveActivityBootstrapSection: View {
    enum AccessibilityID {
        static let start = "debug.liveActivityBootstrap.start"
        static let update = "debug.liveActivityBootstrap.update"
        static let end = "debug.liveActivityBootstrap.end"
        static let status = "debug.liveActivityBootstrap.status"
    }

    @State private var controller: DebugLiveActivityBootstrapController

    init(logging: AppLogging) {
        _controller = State(
            initialValue: DebugLiveActivityBootstrapController(
                logging: logging,
                activities: ActivityKitBootstrapActivities()
            )
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("DEBUG · Live Activity bootstrap")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(controller.status.label)
                .font(.footnote)
                .monospacedDigit()
                .accessibilityIdentifier(AccessibilityID.status)

            HStack(spacing: 12) {
                Button("Start") { controller.start() }
                    .accessibilityIdentifier(AccessibilityID.start)
                Button("Update") { Task { await controller.update() } }
                    .accessibilityIdentifier(AccessibilityID.update)
                Button("End") { Task { await controller.end() } }
                    .accessibilityIdentifier(AccessibilityID.end)
            }
            .buttonStyle(.bordered)
            .disabled(!controller.areControlsAvailable)
        }
        .padding()
        // Runs once per view identity (not on ordinary body updates); a rebuilt
        // section gets a new controller and reconciles again. Idempotent anyway.
        .task { await controller.reconcile() }
    }
}
