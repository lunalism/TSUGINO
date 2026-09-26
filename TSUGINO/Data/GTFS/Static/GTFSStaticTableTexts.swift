import Foundation

// The input to the P2-S1 static GTFS reader (DEC-065 §B).
//
// The caller supplies the raw bytes of each table's text. Obtaining those
// bytes — archive extraction, file access, networking — is outside the
// reader and outside this slice. Fare tables are not read.

/// The nine GTFS tables P2-S1 reads, named by their file base name.
nonisolated enum GTFSTableName: String, Hashable, Sendable, CaseIterable {
    case agency
    case stops
    case routes
    case trips
    case stopTimes = "stop_times"
    case calendar
    case calendarDates = "calendar_dates"
    case feedInfo = "feed_info"
    case translations
}

/// The text content of the GTFS tables, as supplied by the caller.
///
/// `agency`, `stops`, `routes`, `trips`, and `stopTimes` are required by
/// their type. The others may be absent; whether an absent `calendar` and
/// `calendarDates` leave a trip's `service_id` unresolved is decided by the
/// reader's reference checks, not here.
nonisolated struct GTFSStaticTableTexts: Sendable {
    var agency: Data
    var stops: Data
    var routes: Data
    var trips: Data
    var stopTimes: Data
    var calendar: Data?
    var calendarDates: Data?
    var feedInfo: Data?
    var translations: Data?

    init(
        agency: Data,
        stops: Data,
        routes: Data,
        trips: Data,
        stopTimes: Data,
        calendar: Data? = nil,
        calendarDates: Data? = nil,
        feedInfo: Data? = nil,
        translations: Data? = nil
    ) {
        self.agency = agency
        self.stops = stops
        self.routes = routes
        self.trips = trips
        self.stopTimes = stopTimes
        self.calendar = calendar
        self.calendarDates = calendarDates
        self.feedInfo = feedInfo
        self.translations = translations
    }
}
