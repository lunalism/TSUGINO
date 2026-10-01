/// Actual parameterized constraints (DEC-080 V1–V4), never inferred from loaded routes.
/// Sets express declared support, not verified membership or complete input coverage.
/// Supported forms remain matched rail rides and inter-ride directional transfers;
/// through service counts once and candidate duplicate-TripID rules remain unchanged.
nonisolated struct InternalSearchProfileDefinition: Sendable {
    let identity: InternalSearchProfileIdentity
    let stations: Set<StationID>
    let lines: Set<LineID>
    let trips: Set<TripID>
    let maximumElapsedDuration: Double
    let maximumRailRides: Int
    let connectionPolicy: InternalSearchPolicyReference
    let serviceDateInterpretation: InternalSearchPolicyReference

    init?(identity: InternalSearchProfileIdentity, stations: Set<StationID>,
          lines: Set<LineID>, trips: Set<TripID>, maximumElapsedDuration: Double,
          maximumRailRides: Int, connectionPolicy: InternalSearchPolicyReference,
          serviceDateInterpretation: InternalSearchPolicyReference) {
        guard !stations.isEmpty, !lines.isEmpty, !trips.isEmpty,
              maximumElapsedDuration.isFinite, maximumElapsedDuration > 0,
              maximumRailRides > 0 else { return nil }
        self.identity = identity
        self.stations = stations
        self.lines = lines
        self.trips = trips
        self.maximumElapsedDuration = maximumElapsedDuration
        self.maximumRailRides = maximumRailRides
        self.connectionPolicy = connectionPolicy
        self.serviceDateInterpretation = serviceDateInterpretation
    }

    /// Compare supplied definitions explicitly; identity equality alone is insufficient.
    /// This cannot detect conflicting definitions absent from the caller's inputs.
    func hasSameDefinition(as other: InternalSearchProfileDefinition) -> Bool {
        identity == other.identity && stations == other.stations && lines == other.lines
            && trips == other.trips && maximumElapsedDuration == other.maximumElapsedDuration
            && maximumRailRides == other.maximumRailRides
            && connectionPolicy == other.connectionPolicy
            && serviceDateInterpretation == other.serviceDateInterpretation
    }
}
