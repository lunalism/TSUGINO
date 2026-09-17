import os
import Testing
@testable import TSUGINO

struct AppLoggingTests {
    @Test func loggingRoutesEventsToInjectedSinkWithSubsystem() {
        let sink = RecordingLogSink()
        let logging = AppLogging(subsystem: "com.example.test", sink: sink)

        logging.log(.environmentComposed(buildMode: .test))

        #expect(sink.recorded.count == 1)
        #expect(sink.recorded.first?.event == .environmentComposed(buildMode: .test))
        #expect(sink.recorded.first?.subsystem == "com.example.test")
    }

    @Test func everyEventHasACategoryAndFixedMessage() {
        let samples: [LogEvent] = [
            .environmentComposed(buildMode: .debug),
            .configurationValidated(buildMode: .release, enabledFlagCount: 0),
        ]

        for event in samples {
            #expect(LogCategory.allCases.contains(event.category))
            #expect(!event.message.isEmpty)
        }
    }

    @Test func eventsMapToExpectedCategories() {
        #expect(LogEvent.environmentComposed(buildMode: .debug).category == .app)
        #expect(LogEvent.configurationValidated(buildMode: .debug, enabledFlagCount: 1).category == .configuration)
    }

    @Test func messagesContainOnlyClosedVocabulary() {
        // Messages are composed from enum raw values and integers only; there is no
        // API for interpolating arbitrary strings.
        let message = LogEvent.configurationValidated(buildMode: .test, enabledFlagCount: 2).message

        #expect(message == "configuration validated (buildMode=test, enabledFlags=2)")
    }

    @Test func liveActivityBootstrapEventsUseTheLiveActivityCategoryAndFixedMessages() {
        let events: [(LogEvent, String)] = [
            (.liveActivityBootstrapStartRequested, "live activity bootstrap start requested"),
            (.liveActivityBootstrapStartSucceeded, "live activity bootstrap start succeeded"),
            (.liveActivityBootstrapStartRejected(reason: .alreadyActive), "live activity bootstrap start rejected (reason=alreadyActive)"),
            (.liveActivityBootstrapStartRejected(reason: .activitiesDisabled), "live activity bootstrap start rejected (reason=activitiesDisabled)"),
            (.liveActivityBootstrapStartFailed, "live activity bootstrap start failed"),
            (.liveActivityBootstrapUpdateRequested, "live activity bootstrap update requested"),
            (.liveActivityBootstrapUpdateSucceeded, "live activity bootstrap update succeeded"),
            (.liveActivityBootstrapUpdateIgnored(reason: .noActiveActivity), "live activity bootstrap update ignored (reason=noActiveActivity)"),
            (.liveActivityBootstrapEndRequested, "live activity bootstrap end requested"),
            (.liveActivityBootstrapEndSucceeded, "live activity bootstrap end succeeded"),
            (.liveActivityBootstrapEndIgnored(reason: .noActiveActivity), "live activity bootstrap end ignored (reason=noActiveActivity)"),
        ]

        for (event, message) in events {
            #expect(event.category == .liveActivity)
            #expect(event.message == message)
        }
    }

    @Test func liveActivityBootstrapStartFailureLogsAtErrorLevelWithoutDetail() {
        // The only failable ActivityKit operation is `request`; its failure event
        // carries no associated value, so nothing about the error can leak.
        #expect(LogEvent.liveActivityBootstrapStartFailed.level == .error)
        #expect(LogEvent.liveActivityBootstrapStartFailed.category == .liveActivity)
    }

    @Test func categoriesAreStableIdentifiers() {
        #expect(LogCategory.app.rawValue == "app")
        #expect(LogCategory.configuration.rawValue == "configuration")
        #expect(LogCategory.liveActivity.rawValue == "liveActivity")
    }
}
