import Foundation

/// Caller-supplied opaque identity of one coherent immutable Data view, not a
/// production registry ID. Equality is no evidence that the view was reviewed.
nonisolated struct TimetableViewID: Hashable, Sendable {
    let rawValue: UUID
    init(_ rawValue: UUID) { self.rawValue = rawValue }
}

/// Source-interpreted operating-day label, not an instant or calendar converter.
/// Preserve spelling exactly; Data must supply a canonical label under its profile.
nonisolated struct TimetableServiceDate: Hashable, Sendable {
    let label: String
    init?(_ label: String) {
        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        self.label = label
    }
}

/// Valid only under reviewed one-execution-per-Trip/date correspondence (DEC-078).
/// Construction expresses an address; it cannot authenticate that prerequisite.
nonisolated struct TimetableOccurrenceAddress: Hashable, Sendable {
    let viewID: TimetableViewID
    let tripID: TripID
    let serviceDate: TimetableServiceDate

    init(viewID: TimetableViewID, tripID: TripID, serviceDate: TimetableServiceDate) {
        self.viewID = viewID
        self.tripID = tripID
        self.serviceDate = serviceDate
    }
}
