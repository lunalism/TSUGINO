import ActivityKit

/// The smallest boundary around ActivityKit needed to test the Debug bootstrap
/// lifecycle deterministically. This is not a general Live Activity framework; the
/// product lifecycle owner is the Phase 9 `LiveActivityCoordinator` (ARCHITECTURE.md §30).
///
/// `ActivityKitBootstrapActivities` below is the only ActivityKit call site in the app.
@MainActor
protocol BootstrapActivityRequesting {
    /// `ActivityAuthorizationInfo().areActivitiesEnabled` in production.
    var areActivitiesEnabled: Bool { get }

    /// Requests a synthetic bootstrap activity. `pushType` is always `nil`.
    func request(title: String, syntheticValue: Int) throws -> any BootstrapActivityHandle

    /// Handles for every TSUGINO activity the system currently owns, in system order.
    /// Lets a freshly created controller reconcile after process or view recreation.
    func existingHandles() -> [any BootstrapActivityHandle]
}

/// A handle to one live bootstrap activity. Production wraps `Activity`; tests use a fake.
/// Mirrors ActivityKit's real semantics: only `request` can throw; `update(_:)` and
/// `end(_:dismissalPolicy:)` are async and non-throwing.
@MainActor
protocol BootstrapActivityHandle: AnyObject {
    /// The synthetic value the system currently presents for this activity.
    var syntheticValue: Int { get }

    func update(syntheticValue: Int) async
    func end() async
}

/// Production adapter. Retains exactly one `Activity` per handle; never reads push
/// tokens, never persists identifiers.
@MainActor
struct ActivityKitBootstrapActivities: BootstrapActivityRequesting {
    init() {}

    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func request(title: String, syntheticValue: Int) throws -> any BootstrapActivityHandle {
        let activity = try Activity.request(
            attributes: TSUGINOLiveActivityAttributes(title: title),
            content: ActivityContent(
                state: TSUGINOLiveActivityAttributes.ContentState(syntheticValue: syntheticValue),
                staleDate: nil
            ),
            pushType: nil
        )
        return ActivityKitBootstrapHandle(activity: activity)
    }

    func existingHandles() -> [any BootstrapActivityHandle] {
        Activity<TSUGINOLiveActivityAttributes>.activities.map(ActivityKitBootstrapHandle.init(activity:))
    }
}

@MainActor
private final class ActivityKitBootstrapHandle: BootstrapActivityHandle {
    private let activity: Activity<TSUGINOLiveActivityAttributes>

    init(activity: Activity<TSUGINOLiveActivityAttributes>) {
        self.activity = activity
    }

    var syntheticValue: Int {
        activity.content.state.syntheticValue
    }

    func update(syntheticValue: Int) async {
        await activity.update(
            ActivityContent(
                state: TSUGINOLiveActivityAttributes.ContentState(syntheticValue: syntheticValue),
                staleDate: nil
            )
        )
    }

    func end() async {
        await activity.end(nil, dismissalPolicy: .immediate)
    }
}
