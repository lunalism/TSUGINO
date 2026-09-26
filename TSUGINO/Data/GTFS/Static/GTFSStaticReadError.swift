// Typed errors of the P2-S1 static GTFS reader (DEC-065 §D).
//
// `invalid` means the input breaks the GTFS Schedule Reference or a reader
// policy DEC-065 accepted. `unsupported` means the input may be valid GTFS
// but lies outside the observed Toei shape this reader supports — a scoped
// limitation, never a claim that the feed is wrong. A row in an unsupported
// shape is reported as soon as the shape is recognised, and the row's
// remaining fields are not checked.

/// Where a problem was found: the table and the 1-based line. The header is
/// line 1; a data record's line is the line on which it starts.
nonisolated struct GTFSSourceLocation: Hashable, Sendable {
    let table: GTFSTableName
    let line: Int
}

nonisolated enum GTFSStaticReadError: Error, Hashable, Sendable {
    case invalid(GTFSInvalidInput, at: GTFSSourceLocation)
    case unsupported(GTFSUnsupportedInput, at: GTFSSourceLocation)
}

nonisolated enum GTFSInvalidInput: Hashable, Sendable {
    // Specification requirements.

    /// A field contains a tab, carriage return, or line feed.
    case forbiddenCharacterInField
    /// A quotation mark outside a quoted field, or text after a closing quote.
    case malformedQuoting
    case missingRequiredColumn(String)
    /// A required — or, for the shape read here, conditionally required —
    /// field is blank.
    case missingRequiredValue(column: String)
    /// A time, enumeration, or number value that does not parse, or an
    /// enumeration or coordinate outside the values the reference allows.
    case malformedValue(column: String, value: String)
    /// A value in a field the specification forbids for this row.
    case forbiddenValue(column: String)
    case duplicateIdentifier(column: String, value: String)
    case unresolvedReference(column: String, value: String)
    /// `stop_times.stop_id` names a location that is not a stop or platform.
    case referencedLocationIsNotAStop(stopID: String)
    /// A station row (`location_type = 1`) has a `parent_station`.
    case parentStationOnStation
    /// A stop or platform's `parent_station` names a location that is not a
    /// station.
    case parentStationIsNotAStation(parentStation: String)
    case repeatedStopSequence(tripID: String, stopSequence: Int)
    /// A trip's first or last stop has a blank `arrival_time`.
    case missingArrivalTimeAtTripEnd(tripID: String)
    /// A `timepoint = 1` row has a blank `arrival_time` or `departure_time`.
    case missingTimeAtTimepoint(column: String)

    /// The table has no first line naming its fields: the text is empty or
    /// its first line is blank.
    case missingHeader
    /// A header field is empty, so it names no field.
    case emptyColumnName

    // Reader policies (DEC-065 §D).

    case invalidUTF8
    case duplicateColumn(String)
    case fieldCountMismatch(expected: Int, found: Int)
    case unterminatedQuotedField
}

nonisolated enum GTFSUnsupportedInput: Hashable, Sendable {
    /// A `stops` row with `location_type` 2, 3, or 4.
    case locationType(GTFSLocationType)
    /// A `stop_times` row using `location_group_id`, `location_id`, or a
    /// pickup/drop-off window instead of `stop_id`.
    case flexibleStopTime
    /// A `translations` row keyed by `record_id`.
    case translationByRecordID
    /// A `stop_times` row with a blank time and no `timepoint` value.
    case blankTimeWithoutTimepoint
    /// A trip's `stop_times` rows are not in increasing `stop_sequence` order
    /// in the file. A trip's order is defined by `stop_sequence`; GTFS does
    /// not require the file's rows to follow it, so this is a limitation of
    /// the reader's source-order policy, not an invalid feed.
    case stopSequenceNotInSourceOrder(tripID: String)
    /// An empty line after the header. The specification does not address
    /// blank lines.
    case blankLine
    /// A number in a form the specification does not fix and this reader
    /// does not read: a signed integer such as `+1`, an integer too large for
    /// the reader, or a decimal in exponent notation such as `3.5e1`.
    case numberForm(column: String, value: String)
}
