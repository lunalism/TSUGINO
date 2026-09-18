@testable import TSUGINO

/// Test-only stand-in for ActivityKit behind `BootstrapActivityRequesting`.
/// Records calls and lets tests script authorization and failures deterministically.
@MainActor
final class FakeBootstrapActivities: BootstrapActivityRequesting {
    struct RequestError: Error {}

    var areActivitiesEnabled = true
    var failNextRequest = false
    /// Handles reported as already owned by the system (scripted per test).
    var existing: [FakeBootstrapActivityHandle] = []
    private(set) var existingHandlesCallCount = 0
    private(set) var requests: [(title: String, syntheticValue: Int)] = []
    /// Handles created through `request`; `existing` ones are tracked separately.
    private(set) var handles: [FakeBootstrapActivityHandle] = []

    func request(title: String, syntheticValue: Int) throws -> any BootstrapActivityHandle {
        requests.append((title, syntheticValue))
        if failNextRequest {
            failNextRequest = false
            throw RequestError()
        }
        let handle = FakeBootstrapActivityHandle(syntheticValue: syntheticValue)
        handles.append(handle)
        return handle
    }

    func existingHandles() -> [any BootstrapActivityHandle] {
        existingHandlesCallCount += 1
        return existing
    }
}

/// Like ActivityKit, `update`/`end` cannot fail; the fake only records calls.
@MainActor
final class FakeBootstrapActivityHandle: BootstrapActivityHandle {
    private(set) var syntheticValue: Int
    private(set) var updates: [Int] = []
    private(set) var endCount = 0

    init(syntheticValue: Int = 1) {
        self.syntheticValue = syntheticValue
    }

    func update(syntheticValue: Int) async {
        updates.append(syntheticValue)
        self.syntheticValue = syntheticValue
    }

    func end() async {
        endCount += 1
    }
}
