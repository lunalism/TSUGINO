// Where the rider's selected ride stands within its rail leg (DEC-063 A,
// ARCHITECTURE.md §5.6).
//
// A position addresses the current leg's `trip.stopSequence` by index — the
// only unambiguous address once a Trip repeats a station (DEC-060 B) — and
// records how it was established. An `observed` position means realtime
// observed the **train** there; it never says where the rider is. Whether the
// index lies inside the leg's boarding and alighting stops can only be judged
// against the Journey, and is checked by `ActiveJourney`.

/// A place within the current rail leg, with the basis it was established on.
nonisolated struct JourneyPosition: Equatable, Sendable {
    /// A stop, or the movement after a stop, addressed by index into the
    /// current leg's `trip.stopSequence`.
    nonisolated enum Place: Equatable, Sendable {
        case atStop(Int)
        case betweenStops(after: Int)
    }

    /// How the position was established.
    nonisolated enum Basis: Equatable, Sendable {
        /// Realtime observed the train at this place.
        case observed
        /// Estimated from the timetable and the supplied clock; never an
        /// observation (DEC-047).
        case scheduleEstimate
    }

    let place: Place
    let basis: Basis

    /// Fails for a negative index. Never traps.
    init?(place: Place, basis: Basis) {
        switch place {
        case .atStop(let index), .betweenStops(after: let index):
            guard index >= 0 else { return nil }
        }

        self.place = place
        self.basis = basis
    }
}
