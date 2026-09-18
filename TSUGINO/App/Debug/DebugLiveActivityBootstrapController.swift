import Observation

/// Visibility policy for the Debug Live Activity bootstrap control.
///
/// Pure function of `AppConfiguration`: visible only in `.debug` build mode with the
/// `debugLiveActivityBootstrapControl` flag enabled. `AppConfiguration` already rejects
/// that flag in `.release`, so Release can never satisfy this predicate.
nonisolated enum DebugLiveActivityBootstrapPolicy {
    static func isControlVisible(configuration: AppConfiguration) -> Bool {
        configuration.buildMode == .debug
            && configuration.featureFlags.isEnabled(.debugLiveActivityBootstrapControl)
    }
}

/// Why a start request was rejected before reaching ActivityKit.
nonisolated enum BootstrapRejectionReason: String, Sendable, Equatable {
    case alreadyActive
    case activitiesDisabled
}

/// Why an update/end request was ignored.
nonisolated enum BootstrapIgnoreReason: String, Sendable, Equatable {
    case noActiveActivity
}

/// Debug-only, app-owned controller for the synthetic bootstrap Live Activity.
///
/// Engineering validation only (Phase 0, ROADMAP "start/end a minimal test Live
/// Activity"). It is not the product `LiveActivityCoordinator` (Phase 9) and is removed
/// with `FeatureFlag.debugLiveActivityBootstrapControl`. It retains at most one
/// activity handle, has no timers or background work, and logs only fixed events.
///
/// A new controller starts in `.reconciling` and must run `reconcile()` once before
/// its controls are usable, so an activity that outlived the previous process (or a
/// previous controller) is adopted instead of orphaned.
@MainActor
@Observable
final class DebugLiveActivityBootstrapController {
    /// Typed UI status. Never carries free-form text or error descriptions.
    enum Status: Equatable, Sendable {
        /// Initial state until `reconcile()` has checked for existing activities.
        case reconciling
        case idle
        case unavailable(BootstrapRejectionReason)
        case active(syntheticValue: Int)
        case ended
        /// `Activity.request` threw. The error itself is never surfaced.
        case requestFailed
    }

    static let bootstrapTitle = "TSUGINO bootstrap"
    static let initialSyntheticValue = 1

    private(set) var status: Status = .reconciling

    /// True while a bootstrap activity handle is retained.
    var hasActiveActivity: Bool { handle != nil }

    /// False until `reconcile()` has completed; the Debug UI disables its controls
    /// so Start/Update/End cannot race the existing-activity check.
    var areControlsAvailable: Bool { status != .reconciling }

    private var handle: (any BootstrapActivityHandle)?
    private var hasReconciled = false
    private var syntheticValue = DebugLiveActivityBootstrapController.initialSyntheticValue
    private let logging: AppLogging
    private let activities: any BootstrapActivityRequesting

    init(logging: AppLogging, activities: any BootstrapActivityRequesting) {
        self.logging = logging
        self.activities = activities
    }

    /// Reconciles in-memory state with the activities the system currently owns.
    /// Runs its policy once per controller; later calls are no-ops.
    ///
    /// - none: nothing retained, `.idle`.
    /// - exactly one: adopted as the retained handle, `.active(currentValue)`.
    /// - several: ambiguous for a single-handle bootstrap, so every one is ended
    ///   immediately and nothing is retained; `.ended` (same as after a manual End).
    func reconcile() async {
        if hasReconciled { return }
        hasReconciled = true
        logging.log(.liveActivityBootstrapReconcileStarted)

        let existing = activities.existingHandles()
        switch existing.count {
        case 0:
            status = .idle
            logging.log(.liveActivityBootstrapReconcileFoundNone)
        case 1:
            let adopted = existing[0]
            handle = adopted
            syntheticValue = adopted.syntheticValue
            status = .active(syntheticValue: syntheticValue)
            logging.log(.liveActivityBootstrapReconcileAdopted(syntheticValue: syntheticValue))
        default:
            for orphan in existing {
                await orphan.end()
            }
            status = .ended
            logging.log(.liveActivityBootstrapReconcileCleanedUp(count: existing.count))
        }
    }

    /// Starts one bootstrap activity. A second start while one is retained is rejected.
    func start() {
        logging.log(.liveActivityBootstrapStartRequested)

        if handle != nil {
            logging.log(.liveActivityBootstrapStartRejected(reason: .alreadyActive))
            return
        }
        guard activities.areActivitiesEnabled else {
            status = .unavailable(.activitiesDisabled)
            logging.log(.liveActivityBootstrapStartRejected(reason: .activitiesDisabled))
            return
        }

        do {
            syntheticValue = Self.initialSyntheticValue
            handle = try activities.request(title: Self.bootstrapTitle, syntheticValue: syntheticValue)
            status = .active(syntheticValue: syntheticValue)
            logging.log(.liveActivityBootstrapStartSucceeded)
        } catch {
            status = .requestFailed
            logging.log(.liveActivityBootstrapStartFailed)
        }
    }

    /// Increments the synthetic value on the retained activity. Ignored when none exists.
    func update() async {
        logging.log(.liveActivityBootstrapUpdateRequested)

        guard let handle else {
            logging.log(.liveActivityBootstrapUpdateIgnored(reason: .noActiveActivity))
            return
        }

        let nextValue = syntheticValue + 1
        await handle.update(syntheticValue: nextValue)
        syntheticValue = nextValue
        status = .active(syntheticValue: nextValue)
        logging.log(.liveActivityBootstrapUpdateSucceeded)
    }

    /// Ends the retained activity and clears the reference. Ignored when none exists.
    func end() async {
        logging.log(.liveActivityBootstrapEndRequested)

        guard let handle else {
            logging.log(.liveActivityBootstrapEndIgnored(reason: .noActiveActivity))
            return
        }

        await handle.end()
        self.handle = nil
        status = .ended
        logging.log(.liveActivityBootstrapEndSucceeded)
    }
}

extension DebugLiveActivityBootstrapController.Status {
    /// Fixed, engineering-facing label. Not localized; not product copy.
    var label: String {
        switch self {
        case .reconciling: "Reconciling…"
        case .idle: "Idle"
        case .unavailable(.activitiesDisabled): "Live Activities disabled in Settings"
        case .unavailable(.alreadyActive): "Already active"
        case .active(let value): "Active (value \(value))"
        case .ended: "Ended"
        case .requestFailed: "Start request failed"
        }
    }
}
