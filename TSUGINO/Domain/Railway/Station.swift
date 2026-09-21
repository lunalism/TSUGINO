// Canonical station identity and line membership (DEC-021, DEC-048, DEC-053,
// DEC-055, ARCHITECTURE.md §5.1, §40).
//
// `Station` is identity, canonical names, and line membership — nothing else.
// It carries no provider ID or station code (Rule 9, DEC-021 — those are
// aliases resolved by the mapping layer, ARCHITECTURE.md §40), no coordinate
// (S3b-gated, DEC-055 D4), and no transfer, interchange, or parent-station
// relationship (DEC-048, Rule 53).
//
// It deliberately has no `operatorID` (DEC-055 D1). A canonical station may be
// served by more than one operator, so a single operator cannot describe it
// truthfully; a station's operators are those of its lines, resolved at the
// dataset level by joining `lineIDs` to the canonical `RailwayLine` records.

/// A railway station, identified by its canonical `StationID`.
///
/// **Identity is the ID alone (DEC-055 D3).** Equality and hashing use only
/// `id`, so a renamed station, or one whose line membership is corrected, stays
/// the same station: descriptive data changes for editorial or data-quality
/// reasons and must not silently make a stored value denote something
/// different. A merge or split of canonical identities is an identity
/// migration (Rule 39), never an in-place edit.
nonisolated struct Station: Codable, Sendable {
    let id: StationID
    let name: LocalizedRailName

    /// The canonical lines this station belongs to (DEC-055 D2).
    ///
    /// Membership is unordered and duplicate-free, which `Set` makes structural
    /// rather than validated. The set may be empty: a Phase 1 value does not
    /// decide whether a station with no line is a data error — that is a
    /// Phase 2 import concern, as is agreement between this set and canonical
    /// line topology. The encoded element order carries no meaning.
    let lineIDs: Set<LineID>

    /// Every argument is already valid: `StationID` and each `LineID` enforce
    /// their own rule (DEC-051) and `LocalizedRailName` enforces its own
    /// (DEC-053), so this initialiser repeats none of it.
    init(id: StationID, name: LocalizedRailName, lineIDs: Set<LineID>) {
        self.id = id
        self.name = name
        self.lineIDs = lineIDs
    }
}

extension Station: Hashable {
    // Written out rather than synthesised: synthesis would fold every future
    // stored property into identity, which is precisely what DEC-055 rules out.

    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
