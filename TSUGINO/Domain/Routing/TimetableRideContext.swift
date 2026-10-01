import Foundation

/// Exact ridden endpoints from locally valid facts, not authenticated producer output.
/// Data still establishes activation, eligibility, correspondence and coherent views.
nonisolated struct TimetableRideContext: Sendable {
    let binding: TimetableOccurrenceBinding
    let boardingIndex: Int
    let alightingIndex: Int
    let departure: Date
    let arrival: Date

    init?(train: TrainCandidate, facts: TimetableOccurrenceFacts) {
        guard let supplied = TimetableOccurrenceBinding(address: facts.binding.address, trip: train.trip),
              facts.binding.matches(supplied) else { return nil }
        // Both inputs are immutable validated values; exact snapshot matching makes
        // TrainCandidate's original indices safe in the complete visit-slot array.
        guard case .exact(let departure) = facts.visits[train.boardingIndex].departure,
              case .exact(let arrival) = facts.visits[train.alightingIndex].arrival,
              departure.date <= arrival.date else { return nil }
        self.binding = facts.binding
        self.boardingIndex = train.boardingIndex
        self.alightingIndex = train.alightingIndex
        self.departure = departure.date
        self.arrival = arrival.date
    }

    /// Per-ride association only: a TrainCandidate has no independent date/view.
    /// The retained address cannot be relabeled here; Data validates result-wide coherence.
    func matches(_ train: TrainCandidate) -> Bool {
        guard boardingIndex == train.boardingIndex, alightingIndex == train.alightingIndex,
              let supplied = TimetableOccurrenceBinding(address: binding.address, trip: train.trip)
        else { return false }
        return binding.matches(supplied)
    }
}
