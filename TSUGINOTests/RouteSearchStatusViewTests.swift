#if DEBUG
import SwiftUI
import XCTest
@testable import TSUGINO

@MainActor
final class RouteSearchStatusViewTests: XCTestCase {
    private typealias F = InternalFixture
    private enum Failure: Error { case expectedAttempt }

    private func attempt() async throws -> RouteSearchAttempt {
        let owner = RouteSearchCoordinator(searcher: StatusViewUnusedPort(), clock: FixedAppClock(now: F.date(100)))
        owner.submit(.init(origin: F.station("A"), destination: F.station("D"), departure: .at(F.date(100))))
        let done = owner.completionCheckpointForTesting()
        guard case .searching(let value) = owner.state else {
            owner.dispose(); await done(); throw Failure.expectedAttempt
        }
        owner.dispose(); await done()
        return value
    }

    func testButtonsForwardExactDescriptorsWithoutInvokingOnConstruction() async throws {
        let a = try await attempt(), b = try await attempt()
        let actions: [RouteSearchPresentationAction] = [.cancel(a.id), .retry(b.id), .edit, .search]
        var received: [RouteSearchPresentationAction] = []
        for action in actions {
            let button = RouteSearchStatusActionButton(action: action, language: .english) { received.append($0) }
            let previous = received
            _ = button.body
            XCTAssertEqual(received, previous)
            button.performAction()
        }
        XCTAssertEqual(received, actions)
        XCTAssertNotEqual(a.id, b.id)
    }

    func testUnconfiguredHasNoActionButtonsAndNoConstructionSideEffects() throws {
        var calls = 0
        let view = RouteSearchStatusView(presentation: .map(.notConfigured), language: .english) { _ in calls += 1 }
        XCTAssertTrue(view.presentation.actions.isEmpty)
        _ = view.body
        let image = try render(view, size: .large)
        XCTAssertGreaterThan(image.size.height, 0)
        XCTAssertEqual(calls, 0)
    }

    func testLocalizedMultilineRenderingAtNormalAndLargestDynamicType() async throws {
        let a = try await attempt()
        let scope = try XCTUnwrap(InternalSearchScope(profile: F.configuration().profile, request: a.request, viewID: F.viewID))
        let empty = try XCTUnwrap(InternalSearchSuccess(scope: scope, outcome: .noResults))
        let sources: [(String, RouteSearchPresentationSource)] = [
            ("idle", .current(.idle)), ("searching", .current(.searching(a))),
            ("unavailable", .current(.failed(a, .dataUnavailable))),
            ("incomplete", .current(.failed(a, .searchIncomplete))),
            ("scoped-empty", .current(.completed(a, .internalSuccess(empty)))),
            ("cancelled", .current(.cancelled(a))), ("unconfigured", .notConfigured)
        ]
        var feedback = RouteSearchDraftFeedback()
        feedback.recordSubmission(.invalidRequest, for: feedback.draftID)
        for tag in ["ja-JP", "ko-KR", "en-US", "fr-FR"] {
            let language = AppLanguage.resolve(effectiveLanguageTag: tag)
            for (name, source) in sources {
                let presentation = RouteSearchPresentation.map(source, feedback: name == "idle" ? feedback : nil)
                let view = RouteSearchStatusView(presentation: presentation, language: language) { _ in XCTFail("Rendering invoked an action") }
                let normal = try render(view, size: .large)
                let large = try render(view, size: .accessibility5)
                XCTAssertNotEqual(large.pngData(), normal.pngData(), "\(tag) \(name)")
                XCTAssertEqual(large.size.width, 393)
                let attachment = XCTAttachment(image: large)
                attachment.name = "fixture-\(tag)-\(name)-AX5"
                attachment.lifetime = .keepAlways
                add(attachment)
            }
        }
    }

    func testFallbackRendersIdenticallyToEnglish() throws {
        let presentation = RouteSearchPresentation.map(.notConfigured)
        let english = try render(RouteSearchStatusView(presentation: presentation, language: .english, onAction: { _ in }), size: .accessibility5)
        let fallback = try render(RouteSearchStatusView(presentation: presentation,
            language: .resolve(effectiveLanguageTag: "fr-FR"), onAction: { _ in }), size: .accessibility5)
        XCTAssertEqual(english.pngData(), fallback.pngData())
    }

    private func render(_ view: RouteSearchStatusView, size: DynamicTypeSize) throws -> UIImage {
        let content = view.padding(20).frame(width: 393)
            .frame(height: 1200, alignment: .top)
            .background(Color(uiColor: .systemBackground))
            .environment(\.colorScheme, .light).environment(\.dynamicTypeSize, size)
        let host = UIHostingController(rootView: content)
        host.safeAreaRegions = [] // Fixture bounds already include padding; no app chrome.
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = host
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 1200)
        window.isHidden = false
        defer { window.isHidden = true; window.rootViewController = nil }
        // A fixed roomy fixture canvas avoids UIHostingController fitting caches
        // cropping asynchronously resolved system controls. No app viewport claim.
        let fit = CGSize(width: 393, height: 1200)
        host.view.frame = CGRect(origin: .zero, size: fit)
        host.view.setNeedsLayout(); host.view.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: fit, format: format)
        return renderer.image { _ in
            XCTAssertTrue(host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true))
        }
    }
}
private struct StatusViewUnusedPort: RouteSearching {
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        XCTFail("Fixture attempt must cancel before port invocation")
        throw CancellationError()
    }
}
#endif
