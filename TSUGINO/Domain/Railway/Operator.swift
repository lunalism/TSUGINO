// Canonical operator identity (DEC-049, DEC-053, ARCHITECTURE.md §5.7).
//
// `Operator` is identity plus canonical names and nothing else. It carries no
// provider ID (Rule 9, DEC-021 — those are aliases resolved by the mapping
// layer, ARCHITECTURE.md §40), no capability set (capabilities are declared at
// service/feed scope, §51, DEC-054), and no logo, colour, abbreviation, URL, or
// other presentation metadata.

/// A railway operator, identified by its canonical `OperatorID`.
///
/// **Identity is the ID alone (DEC-053).** Equality and hashing use only `id`,
/// so a renamed operator stays the same operator: a display name changes for
/// editorial reasons and must not silently make a stored value denote something
/// different.
nonisolated struct Operator: Codable, Sendable {
    let id: OperatorID
    let name: LocalizedRailName

    /// Both arguments are already valid: `OperatorID` enforces its own rule
    /// (DEC-051) and `LocalizedRailName` enforces its own (DEC-053), so this
    /// initialiser repeats neither.
    init(id: OperatorID, name: LocalizedRailName) {
        self.id = id
        self.name = name
    }
}

extension Operator: Hashable {
    // Written out rather than synthesised: synthesis would fold every future
    // stored property into identity, which is precisely what DEC-053 rules out.

    static func == (lhs: Operator, rhs: Operator) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
