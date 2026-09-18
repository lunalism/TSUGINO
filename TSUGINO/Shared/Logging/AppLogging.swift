import os

/// Typed log categories. Limited to Phase 0 needs; later phases add the
/// categories listed in ARCHITECTURE.md §36 (routing, realtime, journey, …).
nonisolated enum LogCategory: String, CaseIterable, Sendable {
    case app
    case configuration
    case liveActivity
}

/// Fixed, privacy-safe log events (RULES.md Rule 33).
///
/// Every event's message is built only from this enum and other closed enums, so a
/// call site cannot interpolate user identity, coordinates, tokens, provider payloads,
/// or movement history into a log line. Adding an event means adding a case here.
nonisolated enum LogEvent: Sendable, Equatable {
    /// The composition root finished building the live `AppEnvironment`.
    case environmentComposed(buildMode: BuildMode)
    /// A configuration passed validation.
    case configurationValidated(buildMode: BuildMode, enabledFlagCount: Int)

    // Debug Live Activity bootstrap (Phase 0 Step A3). Reasons are closed enums; no
    // activity identifiers, tokens, or error descriptions are ever carried.
    case liveActivityBootstrapStartRequested
    case liveActivityBootstrapStartSucceeded
    case liveActivityBootstrapStartRejected(reason: BootstrapRejectionReason)
    case liveActivityBootstrapStartFailed
    case liveActivityBootstrapUpdateRequested
    case liveActivityBootstrapUpdateSucceeded
    case liveActivityBootstrapUpdateIgnored(reason: BootstrapIgnoreReason)
    case liveActivityBootstrapEndRequested
    case liveActivityBootstrapEndSucceeded
    case liveActivityBootstrapEndIgnored(reason: BootstrapIgnoreReason)
    // Reconciliation with system-owned activities. Carries only counts/values.
    case liveActivityBootstrapReconcileStarted
    case liveActivityBootstrapReconcileFoundNone
    case liveActivityBootstrapReconcileAdopted(syntheticValue: Int)
    case liveActivityBootstrapReconcileCleanedUp(count: Int)

    var category: LogCategory {
        switch self {
        case .environmentComposed:
            .app
        case .configurationValidated:
            .configuration
        case .liveActivityBootstrapStartRequested, .liveActivityBootstrapStartSucceeded,
             .liveActivityBootstrapStartRejected, .liveActivityBootstrapStartFailed,
             .liveActivityBootstrapUpdateRequested, .liveActivityBootstrapUpdateSucceeded,
             .liveActivityBootstrapUpdateIgnored,
             .liveActivityBootstrapEndRequested, .liveActivityBootstrapEndSucceeded,
             .liveActivityBootstrapEndIgnored,
             .liveActivityBootstrapReconcileStarted, .liveActivityBootstrapReconcileFoundNone,
             .liveActivityBootstrapReconcileAdopted, .liveActivityBootstrapReconcileCleanedUp:
            .liveActivity
        }
    }

    var level: OSLogType {
        switch self {
        case .liveActivityBootstrapStartFailed:
            .error
        case .liveActivityBootstrapStartRequested, .liveActivityBootstrapUpdateRequested, .liveActivityBootstrapEndRequested,
             .liveActivityBootstrapReconcileStarted:
            .debug
        default:
            .info
        }
    }

    /// Fixed message text. Contains no user-supplied or provider-supplied data.
    var message: String {
        switch self {
        case .environmentComposed(let buildMode):
            "environment composed (buildMode=\(buildMode.rawValue))"
        case .configurationValidated(let buildMode, let enabledFlagCount):
            "configuration validated (buildMode=\(buildMode.rawValue), enabledFlags=\(enabledFlagCount))"
        case .liveActivityBootstrapStartRequested:
            "live activity bootstrap start requested"
        case .liveActivityBootstrapStartSucceeded:
            "live activity bootstrap start succeeded"
        case .liveActivityBootstrapStartRejected(let reason):
            "live activity bootstrap start rejected (reason=\(reason.rawValue))"
        case .liveActivityBootstrapStartFailed:
            "live activity bootstrap start failed"
        case .liveActivityBootstrapUpdateRequested:
            "live activity bootstrap update requested"
        case .liveActivityBootstrapUpdateSucceeded:
            "live activity bootstrap update succeeded"
        case .liveActivityBootstrapUpdateIgnored(let reason):
            "live activity bootstrap update ignored (reason=\(reason.rawValue))"
        case .liveActivityBootstrapEndRequested:
            "live activity bootstrap end requested"
        case .liveActivityBootstrapEndSucceeded:
            "live activity bootstrap end succeeded"
        case .liveActivityBootstrapEndIgnored(let reason):
            "live activity bootstrap end ignored (reason=\(reason.rawValue))"
        case .liveActivityBootstrapReconcileStarted:
            "live activity bootstrap reconcile started"
        case .liveActivityBootstrapReconcileFoundNone:
            "live activity bootstrap reconcile found none"
        case .liveActivityBootstrapReconcileAdopted(let syntheticValue):
            "live activity bootstrap reconcile adopted (syntheticValue=\(syntheticValue))"
        case .liveActivityBootstrapReconcileCleanedUp(let count):
            "live activity bootstrap reconcile cleaned up (count=\(count))"
        }
    }
}

/// Destination for `LogEvent`s. Production uses `UnifiedLogSink`; tests inject a
/// recording sink so no test asserts on Apple unified-log output.
nonisolated protocol AppLogSink: Sendable {
    func emit(_ event: LogEvent, subsystem: String)
}

/// `os.Logger`-backed sink. One logger per category under the app subsystem.
nonisolated struct UnifiedLogSink: AppLogSink {
    init() {}

    func emit(_ event: LogEvent, subsystem: String) {
        let logger = Logger(subsystem: subsystem, category: event.category.rawValue)
        // The message is a fixed vocabulary string (see `LogEvent`), so `.public` is safe.
        logger.log(level: event.level, "\(event.message, privacy: .public)")
    }
}

/// The app's logging facade. It exposes only `log(_ event:)`; there is no free-form
/// string entry point, which is what keeps unsafe logging out of production source.
nonisolated struct AppLogging: Sendable {
    let subsystem: String
    let sink: any AppLogSink

    init(subsystem: String, sink: any AppLogSink) {
        self.subsystem = subsystem
        self.sink = sink
    }

    /// Production logging for the given subsystem.
    static func live(subsystem: String) -> AppLogging {
        AppLogging(subsystem: subsystem, sink: UnifiedLogSink())
    }

    func log(_ event: LogEvent) {
        sink.emit(event, subsystem: subsystem)
    }
}
