// Provider DTOs produced by the P2-S1 static GTFS reader (DEC-065 §B).
//
// These are provider records, not TSUGINO models: they carry GTFS values as
// the feed states them, in source order, with no canonical identifier, no
// Domain meaning, and no mapping (Rule 8, Rule 9). A blank optional field is
// `nil`, never the default GTFS reading of a blank — that interpretation
// belongs to later slices. Values are checked only for syntax (DEC-065 §D):
// no colour type (DEC-055 D5), passenger-stop inference (DEC-061 F), or
// timetable semantics (DEC-060 §F).

/// Every row the reader accepted, per table, in source order.
nonisolated struct GTFSStaticFeed: Hashable, Sendable {
    let agencies: [GTFSAgency]
    let stops: [GTFSStop]
    let routes: [GTFSRoute]
    let trips: [GTFSTrip]
    let stopTimes: [GTFSStopTime]
    let calendars: [GTFSCalendar]
    let calendarDates: [GTFSCalendarDate]
    let feedInfo: [GTFSFeedInfo]
    let translations: [GTFSTranslation]
}

nonisolated struct GTFSAgency: Hashable, Sendable {
    let agencyID: String?
    let name: String
    let url: String
    let timezone: String
    let language: String?
}

/// `location_type`. Only `stopOrPlatform` and `station` rows are supported
/// by this reader; the other types are reported as unsupported (DEC-065 §D).
nonisolated enum GTFSLocationType: Int, Hashable, Sendable {
    case stopOrPlatform = 0
    case station = 1
    case entranceOrExit = 2
    case genericNode = 3
    case boardingArea = 4
}

nonisolated struct GTFSStop: Hashable, Sendable {
    let stopID: String
    let stopCode: String?
    let name: String
    let latitude: Double
    let longitude: Double
    /// `nil` when the feed leaves `location_type` blank.
    let locationType: GTFSLocationType?
    let parentStation: String?
    let platformCode: String?
}

nonisolated struct GTFSRoute: Hashable, Sendable {
    let routeID: String
    let agencyID: String?
    let shortName: String?
    let longName: String?
    /// One of the `route_type` values the GTFS Schedule Reference lists.
    let routeType: Int
    /// Uninterpreted provider text; no colour type exists (DEC-055 D5).
    let color: String?
    let textColor: String?
}

nonisolated struct GTFSTrip: Hashable, Sendable {
    let tripID: String
    let routeID: String
    let serviceID: String
    let headsign: String?
    let shortName: String?
    /// `0` or `1` as the feed states it; no direction meaning is assigned.
    let directionID: Int?
    let blockID: String?
}

/// A GTFS time value: `H:MM:SS` or `HH:MM:SS`, where hours may exceed 23 for
/// service after midnight. It carries no service day, time zone, or clock
/// meaning (DEC-060 §F).
nonisolated struct GTFSTime: Hashable, Sendable {
    let hours: Int
    let minutes: Int
    let seconds: Int
}

/// `pickup_type` / `drop_off_type` as stated; a blank value is `nil`.
nonisolated enum GTFSPickupDropOffType: Int, Hashable, Sendable {
    case regular = 0
    case none = 1
    case phoneAgency = 2
    case coordinateWithDriver = 3
}

nonisolated enum GTFSTimepoint: Int, Hashable, Sendable {
    case approximate = 0
    case exact = 1
}

nonisolated struct GTFSStopTime: Hashable, Sendable {
    let tripID: String
    let stopID: String
    let stopSequence: Int
    let arrivalTime: GTFSTime?
    let departureTime: GTFSTime?
    let stopHeadsign: String?
    let pickupType: GTFSPickupDropOffType?
    let dropOffType: GTFSPickupDropOffType?
    let timepoint: GTFSTimepoint?
}

nonisolated struct GTFSCalendar: Hashable, Sendable {
    let serviceID: String
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    /// Provider text in `YYYYMMDD` form; not interpreted in this slice.
    let startDate: String
    let endDate: String
}

nonisolated enum GTFSExceptionType: Int, Hashable, Sendable {
    case added = 1
    case removed = 2
}

nonisolated struct GTFSCalendarDate: Hashable, Sendable {
    let serviceID: String
    /// Provider text in `YYYYMMDD` form; not interpreted in this slice.
    let date: String
    let exceptionType: GTFSExceptionType
}

nonisolated struct GTFSFeedInfo: Hashable, Sendable {
    let publisherName: String
    let publisherURL: String
    let language: String
    let startDate: String?
    let endDate: String?
    let version: String?
}

/// A `translations` row keyed by `field_value` — the only form this reader
/// supports (DEC-065 §D).
nonisolated struct GTFSTranslation: Hashable, Sendable {
    let tableName: String
    let fieldName: String
    let language: String
    let translation: String
    /// `nil` only for `feed_info` rows, which the specification keys by
    /// neither `record_id` nor `field_value`.
    let fieldValue: String?
}
