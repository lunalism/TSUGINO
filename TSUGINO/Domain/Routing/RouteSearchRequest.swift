import Foundation

/// Pure search intent (DEC-076 A). Existence, support and mappings belong to Data.
nonisolated struct RouteSearchRequest: Sendable {
    let origin: StationID
    let destination: StationID
    let departNotBefore: Date

    init?(origin: StationID, destination: StationID, departNotBefore: Date) {
        guard origin != destination, departNotBefore.timeIntervalSinceReferenceDate.isFinite else { return nil }
        self.origin = origin
        self.destination = destination
        self.departNotBefore = departNotBefore
    }
}
