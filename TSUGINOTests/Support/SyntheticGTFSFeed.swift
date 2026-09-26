import Foundation
import Testing
@testable import TSUGINO

/// A small, valid, entirely invented GTFS feed for the P2-S1 reader tests
/// (DEC-065 §C). No value is taken from any provider: identifiers are
/// `syn-…`, names are "Synthetic …", URLs use the reserved `.invalid` domain,
/// and dates lie in 2099.
///
/// Tests start from `valid` and replace one table to exercise one case.
struct SyntheticGTFSFeed {
    var agency: Data
    var stops: Data
    var routes: Data
    var trips: Data
    var stopTimes: Data
    var calendar: Data?
    var calendarDates: Data?
    var feedInfo: Data?
    var translations: Data?

    static let validAgency = """
        agency_id,agency_name,agency_url,agency_timezone
        syn-agency,Synthetic Transit,https://example.invalid,Asia/Tokyo

        """

    static let validStops = """
        stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,parent_station
        syn-s1,SYN-01,Synthetic One,35.0,139.0,0,
        syn-s2,SYN-02,Synthetic Two,35.1,139.1,,
        syn-s3,SYN-03,Synthetic Three,-35.2,-139.2,0,

        """

    static let validRoutes = """
        route_id,agency_id,route_short_name,route_long_name,route_type,route_color
        syn-r1,syn-agency,,Synthetic Line,1,123ABC

        """

    static let validTrips = """
        route_id,service_id,trip_id,trip_headsign,direction_id
        syn-r1,syn-weekday,syn-t1,Synthetic Terminus,0

        """

    /// Gaps in `stop_sequence` (10, 20, 30) are valid GTFS; the middle row is
    /// the observed Toei passed-station shape with blank times.
    static let validStopTimes = """
        trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type,timepoint
        syn-t1,05:00:00,05:00:30,syn-s1,10,0,0,1
        syn-t1,,,syn-s2,20,1,1,0
        syn-t1,25:10:00,25:10:00,syn-s3,30,0,0,1

        """

    static let validCalendar = """
        service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
        syn-weekday,1,1,1,1,1,0,0,20990101,20991231

        """

    static let validCalendarDates = """
        service_id,date,exception_type
        syn-weekday,20990505,2

        """

    static let validFeedInfo = """
        feed_publisher_name,feed_publisher_url,feed_lang,feed_version
        Synthetic Publisher,https://example.invalid,ja,syn-1

        """

    static let validTranslations = """
        table_name,field_name,language,translation,field_value
        stops,stop_name,en,Synthetic One (EN),Synthetic One

        """

    static var valid: SyntheticGTFSFeed {
        SyntheticGTFSFeed(
            agency: Data(validAgency.utf8),
            stops: Data(validStops.utf8),
            routes: Data(validRoutes.utf8),
            trips: Data(validTrips.utf8),
            stopTimes: Data(validStopTimes.utf8),
            calendar: Data(validCalendar.utf8),
            calendarDates: Data(validCalendarDates.utf8),
            feedInfo: Data(validFeedInfo.utf8),
            translations: Data(validTranslations.utf8)
        )
    }

    /// The valid feed with one table's text replaced.
    static func replacing(_ table: GTFSTableName, with text: String) -> SyntheticGTFSFeed {
        replacing(table, withData: Data(text.utf8))
    }

    static func replacing(_ table: GTFSTableName, withData data: Data?) -> SyntheticGTFSFeed {
        var feed = valid
        switch table {
        case .agency: feed.agency = data ?? Data()
        case .stops: feed.stops = data ?? Data()
        case .routes: feed.routes = data ?? Data()
        case .trips: feed.trips = data ?? Data()
        case .stopTimes: feed.stopTimes = data ?? Data()
        case .calendar: feed.calendar = data
        case .calendarDates: feed.calendarDates = data
        case .feedInfo: feed.feedInfo = data
        case .translations: feed.translations = data
        }
        return feed
    }

    var texts: GTFSStaticTableTexts {
        GTFSStaticTableTexts(
            agency: agency,
            stops: stops,
            routes: routes,
            trips: trips,
            stopTimes: stopTimes,
            calendar: calendar,
            calendarDates: calendarDates,
            feedInfo: feedInfo,
            translations: translations
        )
    }

    func read() async throws(GTFSStaticReadError) -> GTFSStaticFeed {
        try await GTFSStaticTableReader.read(texts)
    }

    /// Records a test issue unless reading fails with exactly `expected`.
    func expectFailure(
        _ expected: GTFSStaticReadError,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        do {
            let feed = try await read()
            Issue.record("expected \(expected), but the feed was read: \(feed)", sourceLocation: sourceLocation)
        } catch {
            #expect(error == expected, sourceLocation: sourceLocation)
        }
    }
}

/// Shorthands for building expected errors.
func invalid(_ reason: GTFSInvalidInput, _ table: GTFSTableName, line: Int) -> GTFSStaticReadError {
    .invalid(reason, at: GTFSSourceLocation(table: table, line: line))
}

func unsupported(_ reason: GTFSUnsupportedInput, _ table: GTFSTableName, line: Int) -> GTFSStaticReadError {
    .unsupported(reason, at: GTFSSourceLocation(table: table, line: line))
}
