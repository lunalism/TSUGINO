import Foundation
import Testing
@testable import TSUGINO

/// The unchanged P2-S1 reader on fully invented input shaped like Tokyo
/// Metro's static GTFS, as the audit recorded it (DEC-067 §B, §D). No value
/// comes from a provider file: line codes `Q` and `Qb` are invented stand-ins,
/// identifiers are `syn-…`, and names are "Synthetic …".
struct GTFSStaticTableReaderTokyoMetroShapeTests {

    private static let byteOrderMark = Data([0xEF, 0xBB, 0xBF])

    private static func table(_ text: String) -> Data {
        byteOrderMark + Data(text.utf8)
    }

    /// Every table carries a byte-order mark.
    private static var metroShapedFeed: GTFSStaticTableTexts {
        GTFSStaticTableTexts(
            agency: table("""
                agency_id,agency_name,agency_url,agency_timezone,agency_lang
                syn-operator,Synthetic Operator,https://example.invalid,Asia/Tokyo,ja

                """),
            // Flat stops: location_type 0 and no parent stations; stop_code is
            // a line-letter prefix plus a number, with a two-letter branch code.
            stops: table("""
                stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,parent_station
                syn-q01,Q01,Synthetic Alpha,35.0,139.0,0,
                syn-q02,Q02,Synthetic Beta,35.1,139.1,0,
                syn-q03,Q03,Synthetic Gamma,35.2,139.2,0,
                syn-qb03,Qb03,Synthetic Delta,35.3,139.3,0,

                """),
            routes: table("""
                route_id,agency_id,route_short_name,route_long_name,route_type,route_color
                syn-route-q,syn-operator,,Synthetic Line,1,A1B2C3

                """),
            trips: table("""
                route_id,service_id,trip_id,trip_headsign
                syn-route-q,syn-weekday,syn-trip-1,Synthetic Gamma
                syn-route-q,syn-weekday,syn-trip-2,Synthetic Delta

                """),
            // First rows with pickup_type 1, last rows with drop_off_type 1,
            // and intermediate blank-time rows with both flags 1 and timepoint 0.
            stopTimes: table("""
                trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type,timepoint
                syn-trip-1,05:00:00,05:00:00,syn-q01,1,1,0,1
                syn-trip-1,,,syn-q02,2,1,1,0
                syn-trip-1,05:08:00,05:08:00,syn-q03,3,0,1,1
                syn-trip-2,06:00:00,06:00:00,syn-q02,1,1,0,1
                syn-trip-2,06:05:00,06:05:00,syn-qb03,2,0,1,1

                """),
            calendar: table("""
                service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
                syn-weekday,1,1,1,1,1,0,0,20990101,20991231

                """),
            calendarDates: table("""
                service_id,date,exception_type
                syn-weekday,20990101,2

                """),
            feedInfo: table("""
                feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version
                Synthetic Publisher,https://example.invalid,ja,20990101,20991231,syn-1

                """),
            translations: table("""
                table_name,field_name,language,translation,field_value
                stops,stop_name,ja,Synthetic Alpha,Synthetic Alpha
                stops,stop_name,en,Synthetic Alpha (EN),Synthetic Alpha
                routes,route_long_name,en,Synthetic Line (EN),Synthetic Line

                """)
        )
    }

    @Test func metroShapedFeedIsReadWithoutRuleChanges() async throws {
        let feed = try await GTFSStaticTableReader.read(Self.metroShapedFeed)

        #expect(feed.agencies.map(\.agencyID) == ["syn-operator"], "the BOM never reaches the first field name")
        #expect(feed.stops.map(\.stopCode) == ["Q01", "Q02", "Q03", "Qb03"])
        #expect(feed.stops.allSatisfy { $0.locationType == .stopOrPlatform && $0.parentStation == nil })
        #expect(feed.routes.map(\.routeType) == [1])
        #expect(feed.routes.map(\.color) == ["A1B2C3"])
        #expect(feed.trips.count == 2)
        #expect(feed.stopTimes.count == 5)
        #expect(feed.translations.count == 3)
        #expect(feed.translations.allSatisfy { $0.fieldValue != nil })
    }

    @Test func boardingAndAlightingFlagsAreKeptAsStated() async throws {
        let stopTimes = try await GTFSStaticTableReader.read(Self.metroShapedFeed).stopTimes

        #expect(stopTimes[0].pickupType == GTFSPickupDropOffType.none, "first row: no pickup")
        #expect(stopTimes[2].dropOffType == GTFSPickupDropOffType.none, "last row: no drop-off")
        let intermediate = stopTimes[1]
        #expect(intermediate.arrivalTime == nil && intermediate.departureTime == nil)
        #expect(intermediate.pickupType == GTFSPickupDropOffType.none && intermediate.dropOffType == GTFSPickupDropOffType.none)
        #expect(intermediate.timepoint == .approximate)
    }

    @Test func branchCodedStopIsAnOrdinaryFlatStop() async throws {
        let stops = try await GTFSStaticTableReader.read(Self.metroShapedFeed).stops
        let branch = try #require(stops.first { $0.stopCode == "Qb03" })

        #expect(branch.locationType == .stopOrPlatform)
        #expect(branch.parentStation == nil)
    }
}
