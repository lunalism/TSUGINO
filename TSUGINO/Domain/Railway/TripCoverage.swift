// What a Trip's represented traversal actually covers (DEC-060 C2,
// ARCHITECTURE.md §5.3).
//
// A canonical Trip covers only railway TSUGINO has modelled. Where a real
// service runs beyond it, no `LineID` and no `StationID` is ever invented —
// the value simply states which of the service's own endpoints the
// representation reaches, so a partial representation can never be mistaken
// for a complete one (DEC-038, Rule 50).
//
// It names no missing line, station, operator, or brand, and no count of
// unknown stops: unknown data stays unknown.

/// Whether a `Trip`'s represented traversal reaches the real service's own
/// origin and destination.
///
/// All four combinations are meaningful: complete service; starts at the real
/// origin but ends before the real destination; starts after the real origin
/// but reaches the real destination; or only a supported middle portion.
/// Because no combination is invalid, construction is **total** — but a
/// decoded `Trip` must still satisfy every Trip invariant (DEC-060 C2).
///
/// Coverage is descriptive data: it never participates in `Trip` identity.
nonisolated struct TripCoverage: Hashable, Codable, Sendable {
    /// Whether `Trip.stopSequence.first` is the real service's origin.
    let includesServiceOrigin: Bool

    /// Whether `Trip.stopSequence.last` is the real service's destination.
    let includesServiceDestination: Bool

    init(includesServiceOrigin: Bool, includesServiceDestination: Bool) {
        self.includesServiceOrigin = includesServiceOrigin
        self.includesServiceDestination = includesServiceDestination
    }
}
