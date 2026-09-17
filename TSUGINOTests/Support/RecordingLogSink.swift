import Synchronization
@testable import TSUGINO

/// Test-only `AppLogSink` that records emitted events in memory, so tests assert on
/// the project-owned event model and never on Apple unified-log output.
/// Lives in the test target only; production uses `UnifiedLogSink`.
final class RecordingLogSink: AppLogSink {
    private let storage = Mutex<[(event: LogEvent, subsystem: String)]>([])

    var recorded: [(event: LogEvent, subsystem: String)] {
        storage.withLock { $0 }
    }

    func emit(_ event: LogEvent, subsystem: String) {
        storage.withLock { $0.append((event, subsystem)) }
    }
}
