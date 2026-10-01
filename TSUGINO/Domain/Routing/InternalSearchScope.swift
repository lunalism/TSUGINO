import Foundation

/// Local scope structure only: no policy resolution, coverage, service-date
/// enumeration or execution-completion proof. No scoped result is produced here.
nonisolated struct InternalSearchScope: Sendable {
    let profile: InternalSearchProfileDefinition
    let request: RouteSearchRequest
    let viewID: TimetableViewID
    let lowerBound: Date
    let upperBound: Date

    init?(profile: InternalSearchProfileDefinition, request: RouteSearchRequest,
          viewID: TimetableViewID) {
        guard profile.stations.contains(request.origin), profile.stations.contains(request.destination)
        else { return nil }
        let lower = request.departNotBefore.timeIntervalSinceReferenceDate
        let duration = profile.maximumElapsedDuration
        let upper = lower + duration
        guard upper.isFinite, upper > lower else { return nil }

        // Error-free TwoSum residual checks that the represented Double sum is exact.
        // Positive duration and finite operands alone do not prevent horizon rounding.
        let durationPart = upper - lower
        let lowerPart = upper - durationPart
        let durationError = duration - durationPart
        let lowerError = lower - lowerPart
        guard durationPart.isFinite, lowerPart.isFinite,
              durationError.isFinite, lowerError.isFinite,
              durationError + lowerError == 0 else { return nil }
        self.profile = profile
        self.request = request
        self.viewID = viewID
        self.lowerBound = request.departNotBefore
        self.upperBound = Date(timeIntervalSinceReferenceDate: upper)
    }

    /// Inclusive ridden-event membership, not route feasibility or request admission.
    func contains(_ instant: Date) -> Bool {
        instant.timeIntervalSinceReferenceDate.isFinite
            && lowerBound <= instant && instant <= upperBound
    }
}
