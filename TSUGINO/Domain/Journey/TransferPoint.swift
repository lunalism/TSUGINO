// Where a transfer between rail legs is taking place (DEC-063 A).
//
// Either the rider is on a stated walking leg, or the change happens at one
// station between two consecutive rail legs, which needs no walking leg
// (DEC-062 D). Whether the indices name legs of the right kind is checked by
// `ActiveJourney`.

/// The point of a transfer within a Journey.
nonisolated enum TransferPoint: Equatable, Sendable {
    /// On the walking leg at `legIndex`.
    case walking(legIndex: Int)

    /// A same-station change between rail legs `afterRailLeg` and
    /// `afterRailLeg + 1`.
    case atStation(afterRailLeg: Int)
}
