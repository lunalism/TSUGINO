// Canonical station identity, coordinate, and line membership (DEC-021,
// DEC-048, DEC-053, DEC-055, DEC-056, ARCHITECTURE.md §5.1, §40).
//
// `Station` is identity, canonical names, one coordinate, and line membership
// — nothing else. It carries no provider ID or station code (Rule 9, DEC-021
// — those are aliases resolved by the mapping layer, ARCHITECTURE.md §40), no
// provider coordinates or coordinate provenance (those stay in mapping data,
// DEC-056), and no transfer, interchange, or parent-station relationship
// (DEC-048, Rule 53).
//
// It deliberately has no `operatorID` (DEC-055 D1). A canonical station may be
// served by more than one operator, so a single operator cannot describe it
// truthfully; a station's operators are those of its lines, resolved at the
// dataset level by joining `lineIDs` to the canonical `RailwayLine` records.

/// A railway station, identified by its canonical `StationID`.
///
/// **Identity is the ID alone (DEC-055 D3, DEC-056).** Equality and hashing
/// use only `id`, so a renamed station, or one whose coordinate or line
/// membership is corrected, stays the same station: descriptive data changes
/// for editorial or data-quality reasons and must not silently make a stored
/// value denote something different. A merge or split of canonical identities
/// is an identity migration (Rule 39), never an in-place edit.
nonisolated struct Station: Codable, Sendable {
    let id: StationID
    let name: LocalizedRailName

    /// The station's one canonical coordinate (DEC-056).
    ///
    /// Required, never optional: the Domain has no representation for an
    /// unknown coordinate. Which published point represents a station — and
    /// what to do when none can be selected — is a Phase 2 mapping decision;
    /// a canonical station without a selectable coordinate is an import
    /// failure, not a `Station` value. The coordinate never participates in
    /// identity and never merges stations (DEC-048, Rule 53).
    let coordinate: GeoCoordinate

    /// The canonical lines this station belongs to (DEC-055 D2).
    ///
    /// Membership is unordered and duplicate-free, which `Set` makes structural
    /// rather than validated. The set may be empty: a Phase 1 value does not
    /// decide whether a station with no line is a data error — that is a
    /// Phase 2 import concern, as is agreement between this set and canonical
    /// line topology. The encoded element order carries no meaning.
    let lineIDs: Set<LineID>

    /// Every argument is already valid: `StationID` and each `LineID` enforce
    /// their own rule (DEC-051), `LocalizedRailName` enforces its own
    /// (DEC-053), and `GeoCoordinate` enforces its own (DEC-056), so this
    /// initialiser repeats none of it.
    init(id: StationID, name: LocalizedRailName, coordinate: GeoCoordinate, lineIDs: Set<LineID>) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.lineIDs = lineIDs
    }
}

extension Station: Hashable {
    // Written out rather than synthesised: synthesis would fold every stored
    // property — including the coordinate — into identity, which is precisely
    // what DEC-055 and DEC-056 rule out.

    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
