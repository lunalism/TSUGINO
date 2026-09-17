import ActivityKit
import SwiftUI
import WidgetKit

/// Phase 0 bootstrap Live Activity. Renders only the synthetic value from
/// `TSUGINOLiveActivityAttributes`; contains no journey logic (RULES.md Rule 21).
struct TSUGINOLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TSUGINOLiveActivityAttributes.self) { context in
            // Lock Screen / banner presentation
            VStack(spacing: 4) {
                Text(context.attributes.title)
                    .font(.headline)
                Text("\(context.state.syntheticValue)")
                    .font(.title2)
                    .monospacedDigit()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.title)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.syntheticValue)")
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Phase 0 bootstrap")
                        .font(.caption)
                }
            } compactLeading: {
                Text("T")
            } compactTrailing: {
                Text("\(context.state.syntheticValue)")
                    .monospacedDigit()
            } minimal: {
                Text("\(context.state.syntheticValue)")
                    .monospacedDigit()
            }
        }
    }
}
