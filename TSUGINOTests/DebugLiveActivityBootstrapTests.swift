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
            .reconciling, .idle, .unavailable(.activitiesDisabled), .unavailable(.alreadyActive),
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
    /// A controller that has already reconciled against `activities` (default: none
    /// existing), i.e. the state a Debug section reaches before its controls enable.
    private func makeController(
        activities: FakeBootstrapActivities? = nil
    ) async -> (DebugLiveActivityBootstrapController, FakeBootstrapActivities, RecordingLogSink) {
        let (controller, activities, sink) = makeUnreconciledController(activities: activities)
        await controller.reconcile()
        sink.clear()
        return (controller, activities, sink)
    }

    private func makeUnreconciledController(
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

    @Test func startCreatesOneActivityWithInitialValueAndBootstrapTitle() async {
        let (controller, fake, sink) = await makeController()

        controller.start()

        #expect(controller.status == .active(syntheticValue: DebugLiveActivityBootstrapController.initialSyntheticValue))
        #expect(controller.hasActiveActivity)
        #expect(fake.requests.count == 1)
        #expect(fake.requests.first?.title == DebugLiveActivityBootstrapController.bootstrapTitle)
        #expect(fake.requests.first?.syntheticValue == 1)
        #expect(sink.recorded.map(\.event) == [.liveActivityBootstrapStartRequested, .liveActivityBootstrapStartSucceeded])
    }

    @Test func duplicateStartIsRejectedAndDoesNotRequestAgain() async {
        let (controller, fake, sink) = await makeController()

        controller.start()
        controller.start()

        #expect(fake.requests.count == 1)
        #expect(controller.status == .active(syntheticValue: 1), "status must not change on a rejected start")
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartRejected(reason: .alreadyActive))
    }

    @Test func startIsRejectedWhenActivitiesAreDisabled() async {
        let fake = FakeBootstrapActivities()
        fake.areActivitiesEnabled = false
        let (controller, _, sink) = await makeController(activities: fake)

        controller.start()

        #expect(controller.status == .unavailable(.activitiesDisabled))
        #expect(!controller.hasActiveActivity)
        #expect(fake.requests.isEmpty)
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartRejected(reason: .activitiesDisabled))
    }

    @Test func startFailureIsTypedAndRetainsNothing() async {
        let fake = FakeBootstrapActivities()
        fake.failNextRequest = true
        let (controller, _, sink) = await makeController(activities: fake)

        controller.start()

        #expect(controller.status == .requestFailed)
        #expect(!controller.hasActiveActivity)
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartFailed)
    }

    @Test func updateWithoutActivityIsIgnored() async {
        let (controller, _, sink) = await makeController()

        await controller.update()

        #expect(controller.status == .idle)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapUpdateRequested,
            .liveActivityBootstrapUpdateIgnored(reason: .noActiveActivity),
        ])
    }

    @Test func updateIncrementsSyntheticValueDeterministically() async {
        let (controller, fake, sink) = await makeController()
        controller.start()

        await controller.update()
        await controller.update()

        #expect(controller.status == .active(syntheticValue: 3))
        #expect(fake.handles.first?.updates == [2, 3])
        #expect(sink.recorded.last?.event == .liveActivityBootstrapUpdateSucceeded)
    }

    @Test func endWithoutActivityIsIgnored() async {
        let (controller, _, sink) = await makeController()

        await controller.end()

        #expect(controller.status == .idle)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapEndRequested,
            .liveActivityBootstrapEndIgnored(reason: .noActiveActivity),
        ])
    }

    @Test func endClearsTheRetainedActivityAndAllowsRestart() async {
        let (controller, fake, sink) = await makeController()
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

// MARK: - Reconciliation with system-owned activities

@MainActor
struct DebugLiveActivityBootstrapReconciliationTests {
    private func makeController(
        existing: [FakeBootstrapActivityHandle]
    ) -> (DebugLiveActivityBootstrapController, FakeBootstrapActivities, RecordingLogSink) {
        let fake = FakeBootstrapActivities()
        fake.existing = existing
        let sink = RecordingLogSink()
        let controller = DebugLiveActivityBootstrapController(
            logging: AppLogging(subsystem: "test", sink: sink),
            activities: fake
        )
        return (controller, fake, sink)
    }

    @Test func controlsAreUnavailableUntilReconciled() async {
        let (controller, _, _) = makeController(existing: [])

        #expect(controller.status == .reconciling)
        #expect(!controller.areControlsAvailable)
        #expect(!controller.hasActiveActivity)

        await controller.reconcile()

        #expect(controller.areControlsAvailable)
    }

    @Test func noExistingActivityReconcilesToIdle() async {
        let (controller, fake, sink) = makeController(existing: [])

        await controller.reconcile()

        #expect(controller.status == .idle)
        #expect(!controller.hasActiveActivity)
        #expect(fake.requests.isEmpty)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapReconcileStarted,
            .liveActivityBootstrapReconcileFoundNone,
        ])
    }

    @Test func oneExistingActivityIsAdoptedWithItsCurrentValue() async {
        let orphan = FakeBootstrapActivityHandle(syntheticValue: 3)
        let (controller, fake, sink) = makeController(existing: [orphan])

        await controller.reconcile()

        #expect(controller.status == .active(syntheticValue: 3))
        #expect(controller.hasActiveActivity)
        #expect(fake.requests.isEmpty, "adoption never requests a new activity")
        #expect(orphan.endCount == 0)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapReconcileStarted,
            .liveActivityBootstrapReconcileAdopted(syntheticValue: 3),
        ])
    }

    @Test func duplicateStartAfterAdoptionIsRejected() async {
        let (controller, fake, sink) = makeController(existing: [FakeBootstrapActivityHandle(syntheticValue: 3)])
        await controller.reconcile()

        controller.start()

        #expect(fake.requests.isEmpty)
        #expect(controller.status == .active(syntheticValue: 3))
        #expect(sink.recorded.last?.event == .liveActivityBootstrapStartRejected(reason: .alreadyActive))
    }

    @Test func updateAfterAdoptionRoutesToTheAdoptedHandle() async {
        let orphan = FakeBootstrapActivityHandle(syntheticValue: 3)
        let (controller, _, sink) = makeController(existing: [orphan])
        await controller.reconcile()

        await controller.update()

        #expect(orphan.updates == [4])
        #expect(controller.status == .active(syntheticValue: 4))
        #expect(sink.recorded.last?.event == .liveActivityBootstrapUpdateSucceeded)
    }

    @Test func endAfterAdoptionRoutesToTheAdoptedHandleAndClearsIt() async {
        let orphan = FakeBootstrapActivityHandle(syntheticValue: 3)
        let (controller, fake, sink) = makeController(existing: [orphan])
        await controller.reconcile()

        await controller.end()

        #expect(orphan.endCount == 1)
        #expect(controller.status == .ended)
        #expect(!controller.hasActiveActivity)
        #expect(sink.recorded.last?.event == .liveActivityBootstrapEndSucceeded)

        controller.start()
        #expect(fake.requests.count == 1)
        #expect(controller.status == .active(syntheticValue: 1))
    }

    @Test func multipleExistingActivitiesAreAllEndedAndNoneRetained() async {
        let orphans = [
            FakeBootstrapActivityHandle(syntheticValue: 2),
            FakeBootstrapActivityHandle(syntheticValue: 5),
            FakeBootstrapActivityHandle(syntheticValue: 9),
        ]
        let (controller, fake, sink) = makeController(existing: orphans)

        await controller.reconcile()

        #expect(orphans.map(\.endCount) == [1, 1, 1])
        #expect(controller.status == .ended)
        #expect(!controller.hasActiveActivity)
        #expect(controller.areControlsAvailable)
        #expect(fake.requests.isEmpty)
        #expect(sink.recorded.map(\.event) == [
            .liveActivityBootstrapReconcileStarted,
            .liveActivityBootstrapReconcileCleanedUp(count: 3),
        ])
    }

    @Test func startAfterMultipleActivityCleanupCreatesAFreshActivity() async {
        let orphans = [FakeBootstrapActivityHandle(syntheticValue: 2), FakeBootstrapActivityHandle(syntheticValue: 5)]
        let (controller, fake, _) = makeController(existing: orphans)
        await controller.reconcile()

        controller.start()

        #expect(fake.requests.count == 1)
        #expect(fake.requests.first?.syntheticValue == 1)
        #expect(controller.status == .active(syntheticValue: 1))
        #expect(controller.hasActiveActivity)
    }

    @Test func reconcileIsIdempotentForTheSameController() async {
        let orphan = FakeBootstrapActivityHandle(syntheticValue: 3)
        let (controller, fake, sink) = makeController(existing: [orphan])

        await controller.reconcile()
        await controller.update()
        await controller.reconcile()
        await controller.reconcile()

        #expect(fake.existingHandlesCallCount == 1)
        #expect(controller.status == .active(syntheticValue: 4), "a repeated reconcile must not rewind adopted state")
        #expect(controller.hasActiveActivity)
        #expect(sink.recorded.filter { $0.event == .liveActivityBootstrapReconcileStarted }.count == 1)
    }
}
