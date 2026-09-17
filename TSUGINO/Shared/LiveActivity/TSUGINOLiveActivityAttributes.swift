import ActivityKit

/// Phase 0 bootstrap attributes shared by the app and the Live Activity extension.
///
/// This type exists only to prove that the Widget Extension target builds and can
/// present a Live Activity. It carries a synthetic value and no Journey semantics.
/// The production `LiveActivityPresentationState` is a Phase 9 concern (ARCHITECTURE.md §28).
struct TSUGINOLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Synthetic presentation value; has no product meaning.
        var syntheticValue: Int
    }

    /// Fixed label shown while the bootstrap activity is presented.
    var title: String
}
