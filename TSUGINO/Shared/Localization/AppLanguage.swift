import Foundation

/// Central language policy. Caller supplies the effective app/device language tag;
/// this value never reads system preferences or chooses from a preference list.
nonisolated enum AppLanguage: CaseIterable, Sendable {
    case japanese, korean, english

    static func resolve(effectiveLanguageTag: String?) -> Self {
        let primary = effectiveLanguageTag?.replacingOccurrences(of: "_", with: "-")
            .lowercased().split(separator: "-", omittingEmptySubsequences: false).first
        switch primary {
        case "ja": return .japanese
        case "ko": return .korean
        default: return .english
        }
    }
}
