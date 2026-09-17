import Testing
@testable import TSUGINO

struct TSUGINOTests {
    /// Smoke test: the test target links against the app and the shared
    /// Live Activity attributes type compiles in the app module.
    @Test func sharedLiveActivityAttributesAreConstructible() {
        let attributes = TSUGINOLiveActivityAttributes(title: "TSUGINO")
        let state = TSUGINOLiveActivityAttributes.ContentState(syntheticValue: 3)
        #expect(attributes.title == "TSUGINO")
        #expect(state.syntheticValue == 3)
    }
}
