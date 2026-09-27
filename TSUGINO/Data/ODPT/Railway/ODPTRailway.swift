// Provider DTOs for ODPT `odpt:Railway` records (DEC-067 §D).
//
// These are provider records, not TSUGINO models: values are kept as the
// provider states them, in source order, with no canonical identifier, no
// Domain meaning, and no relation between records (Rule 8, Rule 9). A branch
// record, such as the one cited as `MarunouchiBranch`, is kept as its own
// record; relating it to its main line is a later mapping step (DEC-057 D6).

/// A language map (`{"ja": …, "en": …}`), kept as every language the
/// provider states, sorted by language key so the value is deterministic.
nonisolated struct ODPTLanguageMap: Hashable, Sendable {
    let entries: [Entry]

    struct Entry: Hashable, Sendable {
        let language: String
        let text: String
    }
}

nonisolated struct ODPTStationOrderEntry: Hashable, Sendable {
    let index: Int
    let station: String
    /// `nil` when the provider gives no station title.
    let title: ODPTLanguageMap?
}

/// One `odpt:Railway` record.
nonisolated struct ODPTRailway: Hashable, Sendable {
    /// `@id`.
    let id: String
    /// `owl:sameAs`.
    let sameAs: String
    /// `odpt:operator`.
    let operatorReference: String
    /// `odpt:lineCode`.
    let lineCode: String
    /// `odpt:railwayTitle`.
    let title: ODPTLanguageMap
    /// `odpt:color`, as uninterpreted provider text (DEC-055 D5).
    let color: String?
    /// `odpt:ascendingRailDirection`.
    let ascendingRailDirection: String?
    /// `odpt:descendingRailDirection`.
    let descendingRailDirection: String?
    /// `odpt:stationOrder`, in source order.
    let stationOrder: [ODPTStationOrderEntry]
}
