// Canonical railway line identity (DEC-021, DEC-053, DEC-055,
// ARCHITECTURE.md §5.2).
//
// `RailwayLine` is identity, its operator, and canonical names — nothing
// else. It carries no provider ID (Rule 9, DEC-021 — those are aliases
// resolved by the mapping layer, ARCHITECTURE.md §40), no capability set
// (capabilities are declared at service/feed scope, §51, DEC-054), no colour
// (deferred beyond Phase 1, DEC-055 D5), and no station topology (S3c-gated,
// DEC-055 D4). Direction and stop sequence belong to `Trip` (§5.3), not to
// the line.

/// A railway line, identified by its canonical `LineID`.
///
/// **Identity is the ID alone (DEC-055 D3).** Equality and hashing use only
/// `id`, so a renamed line, or one whose operator record is corrected, stays
/// the same line: descriptive data changes for editorial or data-quality
/// reasons and must not silently make a stored value denote something
/// different.
nonisolated struct RailwayLine: Codable, Sendable {
    let id: LineID

    /// The canonical operator of this line. A line belongs to one operator;
    /// through service across lines and operators is a `Trip` / Journey
    /// concern (ARCHITECTURE.md §13), never a line property.
    let operatorID: OperatorID

    let name: LocalizedRailName

    /// Every argument is already valid: `LineID` and `OperatorID` enforce
    /// their own rule (DEC-051) and `LocalizedRailName` enforces its own
    /// (DEC-053), so this initialiser repeats none of it.
    init(id: LineID, operatorID: OperatorID, name: LocalizedRailName) {
        self.id = id
        self.operatorID = operatorID
        self.name = name
    }
}

extension RailwayLine: Hashable {
    // Written out rather than synthesised: synthesis would fold every future
    // stored property into identity, which is precisely what DEC-055 rules out.

    static func == (lhs: RailwayLine, rhs: RailwayLine) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
