/// Approved project-owned copy only. No raw provider errors, IDs or diagnostics.
nonisolated enum RouteSearchCopy: CaseIterable, Sendable {
    case idle
    case searching
    case alternatives
    case noResults
    case noUsableAlternatives
    case dataUnavailable
    case searchIncomplete
    case cancelled
    case notConfigured
    case invalidRequest
    case invalidEndpoint
    case unsupportedRequest
    case providerUnavailable
    case rateLimited
    case configurationUnavailable
    case malformedResponse
    case contractViolation
    case search
    case edit
    case retry
    case cancel

    func text(in language: AppLanguage) -> String {
        let values: (String, String, String)
        switch self {
        case .idle: values = ("出発地・目的地・出発時刻を指定してください。", "출발지, 도착지, 출발 시간을 지정해 주세요.", "Enter an origin, destination and departure time.")
        case .searching: values = ("経路を検索中…", "경로 검색 중…", "Searching for routes…")
        case .alternatives: values = ("経路", "경로", "Routes")
        case .noResults: values = ("今回の検索では経路が見つかりませんでした。", "이번 검색에서 경로를 찾지 못했습니다.", "No route found for this search.")
        case .noUsableAlternatives: values = ("ご案内できる経路を確認できませんでした。", "안내할 수 있는 경로를 확인하지 못했습니다.", "Could not verify a usable route.")
        case .dataUnavailable: values = ("検索に必要な情報が不足しています。", "검색에 필요한 정보가 부족합니다.", "Information needed for this search is unavailable.")
        case .searchIncomplete: values = ("経路検索を完了できませんでした。", "경로 검색을 완료하지 못했습니다.", "The route search could not be completed.")
        case .cancelled: values = ("経路検索をキャンセルしました。", "경로 검색을 취소했습니다.", "Route search cancelled.")
        case .notConfigured: values = ("現在、経路検索はご利用いただけません。", "현재 경로 검색을 사용할 수 없습니다.", "Route search is currently unavailable.")
        case .invalidRequest: values = ("出発地・目的地・出発時刻を確認してください。", "출발지, 도착지, 출발 시간을 확인해 주세요.", "Check the origin, destination and departure time.")
        case .invalidEndpoint: values = ("指定した駅で検索できません。出発地・目的地を確認してください。", "지정한 역으로 검색할 수 없습니다. 출발지와 도착지를 확인해 주세요.", "Cannot search with the specified stations. Check the origin and destination.")
        case .unsupportedRequest: values = ("この条件では検索できません。", "이 조건으로는 검색할 수 없습니다.", "These search conditions are not supported.")
        case .providerUnavailable: values = ("経路検索を利用できません。", "경로 검색을 이용할 수 없습니다.", "Route search is unavailable.")
        case .rateLimited: values = ("検索の利用制限に達しました。", "검색 이용 한도에 도달했습니다.", "The search usage limit has been reached.")
        case .configurationUnavailable: values = ("現在の設定では検索を実行できません。", "현재 설정으로 검색을 실행할 수 없습니다.", "Cannot run the search with the current configuration.")
        case .malformedResponse: values = ("検索結果を読み取れませんでした。", "검색 결과를 읽을 수 없습니다.", "Could not read the search results.")
        case .contractViolation: values = ("経路検索を処理できませんでした。", "경로 검색을 처리하지 못했습니다.", "Could not process the route search.")
        case .search: values = ("経路を検索", "경로 검색", "Search routes")
        case .edit: values = ("検索条件を変更", "검색 조건 변경", "Edit search")
        case .retry: values = ("再試行", "다시 시도", "Retry")
        case .cancel: values = ("検索をキャンセル", "검색 취소", "Cancel search")
        }
        switch language {
        case .japanese: return values.0
        case .korean: return values.1
        case .english: return values.2
        }
    }
}
