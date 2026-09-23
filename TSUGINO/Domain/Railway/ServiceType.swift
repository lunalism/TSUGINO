// Canonical operator-scoped service type (DEC-061 C, ARCHITECTURE.md §5.3).
//
// A service type is the operator's named stopping-pattern class for a portion
// of a run — a label. The stopping pattern itself stays in
// `Trip.stopSequence` (DEC-060 B), so nothing here describes which stations a
// service calls at.
//
// `ServiceType` is identity, its operator, and canonical names — nothing
// else. It carries no rank or ordinal and no cross-operator comparison (the
// same word means different patterns on different operators), no fare,
// seating, or brand flag (those are separate facts, DEC-061 A, G), no colour
// or abbreviation, and no provider code (Rule 9 — codes are mapping-layer
// aliases, §40).

/// An operator's named service class, identified by its canonical
/// `ServiceTypeID`.
///
/// **Identity is the ID alone (DEC-061 C).** Equality and hashing use only
/// `id`; the operator and names are descriptive, so a corrected name stays the
/// same service type. `Codable` and actor-transfer tests must therefore
/// compare them explicitly.
nonisolated struct ServiceType: Codable, Sendable {
    let id: ServiceTypeID

    /// The one operator this service type belongs to. The same label used by
    /// two operators is two service types.
    let operatorID: OperatorID

    let name: LocalizedRailName

    /// Every argument is already valid — `ServiceTypeID` and `OperatorID`
    /// enforce their own rule (DEC-051) and `LocalizedRailName` enforces its
    /// own (DEC-053) — and there is no cross-field rule, so this initialiser
    /// repeats none of them.
    init(id: ServiceTypeID, operatorID: OperatorID, name: LocalizedRailName) {
        self.id = id
        self.operatorID = operatorID
        self.name = name
    }
}

extension ServiceType: Hashable {
    // Written out rather than synthesised: synthesis would fold the operator
    // and names into identity, which is precisely what DEC-061 C rules out.

    static func == (lhs: ServiceType, rhs: ServiceType) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
