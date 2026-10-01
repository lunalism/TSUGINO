/// Exact snapshot association, with no snapshot-containing equality or Codable.
/// Data supplies the coherent view and reviewed correspondence; this is local proof only.
nonisolated struct TimetableOccurrenceBinding: Sendable {
    let address: TimetableOccurrenceAddress
    let trip: Trip

    init?(address: TimetableOccurrenceAddress, trip: Trip) {
        guard address.tripID == trip.id else { return nil }
        self.address = address
        self.trip = trip
    }

    /// Trip's own equality is ID-only and must not be used for snapshot association.
    func matches(_ other: TimetableOccurrenceBinding) -> Bool {
        address == other.address && trip.id == other.trip.id
            && trip.stopSequence == other.trip.stopSequence
            && trip.lineSegments == other.trip.lineSegments
            && trip.coverage == other.trip.coverage
            && trip.serviceTypeSegments == other.trip.serviceTypeSegments
    }
}
