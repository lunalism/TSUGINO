import Testing
@testable import TSUGINO

// MARK: - Visibility policy

struct DebugLiveActivityBootstrapPolicyTests {
    @Test func visibleForDebugWithFlagEnabled() throws {
        let configuration = try AppConfiguration(
            buildMode: .debug,
            featureFlags: .allDisabled.enabling(.debugLiveActivityBootstrapControl)
        )
        #expect(DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: configuration))
    }

    @Test func debugDefaultsMakeControlVisible() throws {
        let configuration = try AppConfiguration(buildMode: .debug, featureFlags: .defaults(for: .debug))
        #expect(DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: configuration))
    }

    @Test func hiddenForDebugWithFlagDisabled() throws {
        let configuration = try AppConfiguration(buildMode: .debug, featureFlags: .allDisabled)
        #expect(!DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: configuration))
    }

    @Test func hiddenForReleaseWithDefaults() throws {
        let configuration = try AppConfiguration(buildMode: .release, featureFlags: .defaults(for: .release))
        #expect(!DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: configuration))
    }

    @Test func releaseCannotEvenBeConfiguredWithTheFlag() {
        // Release can never display the control: the configuration itself is rejected.
        #expect(throws: AppConfigurationError.debugOnlyFlagEnabledInRelease(.debugLiveActivityBootstrapControl)) {
            try AppConfiguration(
                buildMode: .release,
                featureFlags: .allDisabled.enabling(.debugLiveActivityBootstrapControl)
            )
        }
    }

    @Test func hiddenForTestModeRegardlessOfFlag() throws {
        let disabled = try AppConfiguration.forTesting()
        let enabled = try AppConfiguration.forTesting(
            featureFlags: .allDisabled.enabling(.debugLiveActivityBootstrapControl)
        )
        #expect(!DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: disabled))
        #expect(!DebugLiveActivityBootstrapPolicy.isControlVisible(configuration: enabled))
    }
}

// MARK: - Status presentation

struct DebugLiveActivityBootstrapStatusTests {
    typealias Status = DebugLiveActivityBootstrapController.Status

    @Test func everyStatusHasAFixedNonEmptyLabel() {
        let all: [Status] = [
            .idle, .unavailable(.activitiesDisabled), .unavailable(.alreadyActive),
            .active(syntheticValue: 7), .ended, .requestFailed,
        ]
        for status in all {
            #expect(!status.label.isEmpty)
        }
    }

    @Test func activeLabelCarriesOnlyTheSyntheticValue() {
        #expect(Status.active(syntheticValue: 3).label == "Active (value 3)")
        #expect(Status.unavailable(.activitiesDisabled).label == "Live Activities disabled in Settings")
        #expect(Status.requestFailed.label == "Start request failed")
    }
}

// MARK: - Lifecycle transition policy

@MainActor
struct DebugLiveActivityBootstrapControllerTests {
    private func makeController(
        activities: FakeBootstrapActivities? = nil
    ) -> (DebugLiveActivityBootstrapController, FakeBootstrapActivities, RecordingLogSink) {
        let activities = activities ?? FakeBootstrapActivities()
        let sink = RecordingLogSink()
        let controller = DebugLiveActivityBootstrapController(
            logging: AppLogging(subsystem: "test", sink: sink),
            activities: activities
        )
        return (controller, activities, sink)
    }

    @Test func startCreatesOneActivityWithInitialValueAndBootstrapTitle() {
        let (controller, fake, sink) = makeController()

        controller.start()

        #expect(controller.status == .active(syntheticValue: DebugLiveActivityBootstrapController.initialSyntheticValue))
        #expect(controller.hasActiveActivity)
        #expect(fake.requests.count == 1)
        #expect(fake.requests.first?.title == DebugLiveActivityBootstrapController.bootstrapTitle)
        #expect(fake.requests.first?.syntheticValue == 1)
        #expect(sink.recorded.map(\.event) == [.liveActivityBootstrapStartRequested, .liveActivityBootstrapStartSucceeded])
    }

    @Test func duplicateStartIsRejectedAndDoesNotRequestAgain() {
        let (controller, fake, sink) = makeController()

        controller.start()
        controller.start()

        #expect(fake.requests.count == 1)
        #expect(controller.status == .active(syntheticValue: 1), "status must not change on a rejected start")
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartRejected(reason: .alreadyActive))
    }

    @Test func startIsRejectedWhenActivitiesAreDisabled() {
        let fake = FakeBootstrapActivities()
        fake.areActivitiesEnabled = false
        let (controller, _, sink) = makeController(activities: fake)

        controller.start()

        #expect(controller.status == .unavailable(.activitiesDisabled))
        #expect(!controller.hasActiveActivity)
        #expect(fake.requests.isEmpty)
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartRejected(reason: .activitiesDisabled))
    }

    @Test func startFailureIsTypedAndRetainsNothing() {
        let fake = FakeBootstrapActivities()
        fake.failNextRequest = true
        let (controller, _, sink) = makeController(activities: fake)

        controller.start()

        #expect(controller.status == .requestFailed)
        #expect(!controller.hasActiveActivity)
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartFailed)
    }

    @Test func updateWithoutActivityIsIgnored() async {
        let (controller, _, sink) = makeController()

        await controller.update()

        #expect(controller.status == .idle)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapUpdateRequested,
            .liveActivityBootstrapUpdateIgnored(reason: .noActiveActivity),
        ])
    }

    @Test func updateIncrementsSyntheticValueDeterministically() async {
        let (controller, fake, sink) = makeController()
        controller.start()

        await controller.update()
        await controller.update()

        #expect(controller.status == .active(syntheticValue: 3))
        #expect(fake.handles.first?.updates == [2, 3])
        #expect(sink.recorded.last?.event == .liveActivityBootstrapUpdateSucceeded)
    }

    @Test func endWithoutActivityIsIgnored() async {
        let (controller, _, sink) = makeController()

        await controller.end()

        #expect(controller.status == .idle)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapEndRequested,
            .liveActivityBootstrapEndIgnored(reason: .noActiveActivity),
        ])
    }

    @Test func endClearsTheRetainedActivityAndAllowsRestart() async {
        let (controller, fake, sink) = makeController()
        controller.start()

        await controller.end()

        #expect(controller.status == .ended)
        #expect(!controller.hasActiveActivity)
        #expect(fake.handles.first?.endCount == 1)
        #expect(sink.recorded.last?.event == .liveActivityBootstrapEndSucceeded)

        controller.start()
        #expect(fake.requests.count == 2)
        #expect(controller.status == .active(syntheticValue: 1), "restart resets the synthetic value")
    }
}
