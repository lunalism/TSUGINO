/// Provider-neutral search boundary (DEC-076). Implementations contain raw errors
/// and throw only RouteSearchFailure or CancellationError. Application owns task
/// lifetime and superseded-result suppression. No Journey is created or selected.
nonisolated protocol RouteSearching: Sendable {
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult
}
