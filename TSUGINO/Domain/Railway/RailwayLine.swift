// Canonical railway line identity and topology (DEC-021, DEC-053, DEC-055,
// DEC-057, ARCHITECTURE.md §5.2).
//
// `RailwayLine` is identity, its operator, canonical names, and the line's
// undirected adjacent-station topology — nothing else. It carries no
// provider ID (Rule 9, DEC-021 — those are aliases resolved by the mapping
// layer, ARCHITECTURE.md §40), no capability set (capabilities are declared
// at service/feed scope, §51, DEC-054), and no colour (deferred beyond
// Phase 1, DEC-055 D5). Direction and stop sequence belong to `Trip` (§5.3),
// not to the line.

/// A railway line, identified by its canonical `LineID`.
///
/// **Identity is the ID alone (DEC-055 D3, DEC-057 D5).** Equality and
/// hashing use only `id`, so a renamed line, or one whose operator record or
/// topology is corrected, stays the same line: descriptive data changes for
/// editorial or data-quality reasons and must not silently make a stored
/// value denote something different.
nonisolated struct RailwayLine: Codable, Sendable {
    let id: LineID

    /// The canonical operator of this line. A line belongs to one operator;
    /// through service across lines and operators is a `Trip` / Journey
    /// concern (ARCHITECTURE.md §13), never a line property.
    let operatorID: OperatorID

    let name: LocalizedRailName

    /// The line's canonical undirected adjacent-station topology (DEC-057 D5,
    /// §5.2.1).
    ///
    /// Required, never optional: a canonical line without a valid topology is
    /// not a `RailwayLine` value, and populating it is Phase 2 data work. It
    /// describes only which stations are directly adjacent — no direction,
    /// order, traversal, or stopping pattern, all of which belong to `Trip`
    /// (§5.3) — and it never participates in identity.
    let topology: RailwayLineTopology

    /// Every argument is already valid: `LineID` and `OperatorID` enforce
    /// their own rule (DEC-051), `LocalizedRailName` enforces its own
    /// (DEC-053), and `RailwayLineTopology` enforces its own (DEC-057), so
    /// this initialiser repeats none of it.
    init(id: LineID, operatorID: OperatorID, name: LocalizedRailName, topology: RailwayLineTopology) {
        self.id = id
        self.operatorID = operatorID
        self.name = name
        self.topology = topology
    }
}

extension RailwayLine: Hashable {
    // Written out rather than synthesised: synthesis would fold every stored
    // property — including the topology — into identity, which is precisely
    // what DEC-055 and DEC-057 rule out.

    static func == (lhs: RailwayLine, rhs: RailwayLine) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
