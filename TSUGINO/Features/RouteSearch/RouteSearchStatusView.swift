import SwiftUI

/// Early, reusable visual slice only. The host owns lifecycle, language resolution
/// and guarded action execution; this view never searches or selects a candidate.
struct RouteSearchStatusView: View {
    let presentation: RouteSearchPresentation
    let language: AppLanguage
    let onAction: (RouteSearchPresentationAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let status = presentation.status {
                HStack(alignment: .top, spacing: 12) {
                    if case .current(.searching) = presentation.source {
                        // The adjacent accessible text already names the operation.
                        ProgressView().accessibilityHidden(true)
                    }
                    Text(status.text(in: language))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("routeSearch.status")
                }
            }
            if let feedback = presentation.feedback {
                Text(feedback.text(in: language))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("routeSearch.feedback")
            }
            // Vertical buttons avoid truncation/reordering at accessibility sizes.
            ForEach(presentation.actions.indices, id: \.self) { index in
                RouteSearchStatusActionButton(action: presentation.actions[index],
                                              language: language, onAction: onAction)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A concrete button owns the exact supplied descriptor, including attempt identity.
struct RouteSearchStatusActionButton: View {
    let action: RouteSearchPresentationAction
    let language: AppLanguage
    let onAction: (RouteSearchPresentationAction) -> Void

    func performAction() { onAction(action) }

    var body: some View {
        Button(action: performAction) {
            Text(action.copy.text(in: language))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
    }
}

#if DEBUG
#Preview("Fixture · unconfigured · Japanese") {
    RouteSearchStatusView(presentation: .map(.notConfigured),
                          language: .resolve(effectiveLanguageTag: "ja-JP"), onAction: { _ in })
        .padding()
}
#Preview("Fixture · idle · Korean · large text") {
    ScrollView {
        RouteSearchStatusView(presentation: .map(.current(.idle)),
                              language: .resolve(effectiveLanguageTag: "ko-KR"), onAction: { _ in })
            .padding()
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}
#endif
