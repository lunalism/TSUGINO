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

    @Test func categoriesAreStableIdentifiers() {
        #expect(LogCategory.app.rawValue == "app")
        #expect(LogCategory.configuration.rawValue == "configuration")
        #expect(LogCategory.liveActivity.rawValue == "liveActivity")
    }
}
