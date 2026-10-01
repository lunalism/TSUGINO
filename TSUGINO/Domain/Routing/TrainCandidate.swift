/// An unchosen Trip snapshot and original visit indices (DEC-076 C/D).
/// Construction proves local structure only, not the adapter's correspondence
/// evidence, dataset compatibility, dated operation, or explicit user selection.
/// No snapshot equality: Trip equality is ID-only.
nonisolated struct TrainCandidate: Sendable {
    let trip: Trip
    let boardingIndex: Int
    let alightingIndex: Int

    init?(trip: Trip, boardingIndex: Int, alightingIndex: Int) {
        guard boardingIndex >= 0, boardingIndex < alightingIndex,
              alightingIndex < trip.stopSequence.count,
              trip.stopSequence[boardingIndex] != trip.stopSequence[alightingIndex]
        else { return nil }
        self.trip = trip
        self.boardingIndex = boardingIndex
        self.alightingIndex = alightingIndex
    }

    var anchors: RailLegAnchors {
        // Safe by this type's sole initializer and immutable, valid Trip snapshot.
        RailLegAnchors(boardingStationID: trip.stopSequence[boardingIndex],
                       alightingStationID: trip.stopSequence[alightingIndex])!
    }

    /// A boundary-only intersection carries no movement. Keep the full snapshot
    /// and its original indices; clip only this derived line projection.
    var lineSequence: [LineID] {
        trip.lineSegments.filter {
            $0.startIndex < alightingIndex && $0.endIndex > boardingIndex
        }.map(\.lineID)
    }
}
