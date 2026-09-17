@testable import TSUGINO

/// Test-only stand-in for ActivityKit behind `BootstrapActivityRequesting`.
/// Records calls and lets tests script authorization and failures deterministically.
@MainActor
final class FakeBootstrapActivities: BootstrapActivityRequesting {
    struct RequestError: Error {}

    var areActivitiesEnabled = true
    var failNextRequest = false
    private(set) var requests: [(title: String, syntheticValue: Int)] = []
    private(set) var handles: [FakeBootstrapActivityHandle] = []

    func request(title: String, syntheticValue: Int) throws -> any BootstrapActivityHandle {
        requests.append((title, syntheticValue))
        if failNextRequest {
            failNextRequest = false
            throw RequestError()
        }
        let handle = FakeBootstrapActivityHandle()
        handles.append(handle)
        return handle
    }
}

/// Like ActivityKit, `update`/`end` cannot fail; the fake only records calls.
@MainActor
final class FakeBootstrapActivityHandle: BootstrapActivityHandle {
    private(set) var updates: [Int] = []
    private(set) var endCount = 0

    func update(syntheticValue: Int) async {
        updates.append(syntheticValue)
    }

    func end() async {
        endCount += 1
    }
}
