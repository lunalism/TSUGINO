import Foundation
import Testing
@testable import TSUGINO

/// Row, reference, sequence, and time cases of the P2-S1 static GTFS reader
/// (DEC-065 §D), plus unsupported shapes, determinism, and actor isolation.
/// Every input is synthetic (DEC-065 §C).
struct GTFSStaticTableReaderValidationTests {

    private static let stopTimesHeader =
        "trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type,timepoint"

    private static func stopTimes(_ rows: [String]) -> String {
        ([stopTimesHeader] + rows).joined(separator: "\n") + "\n"
    }

    // MARK: - Missing required columns and values (S)

    @Test(arguments: [
        (GTFSTableName.agency, "agency_id,agency_name,agency_url\nsyn-agency,Synthetic,https://example.invalid\n", "agency_timezone"),
        (.stops, "stop_code,stop_name,stop_lat,stop_lon\nSYN-01,Synthetic,35.0,139.0\n", "stop_id"),
        (.routes, "route_id,route_long_name\nsyn-r1,Synthetic Line\n", "route_type"),
        (.trips, "route_id,trip_id\nsyn-r1,syn-t1\n", "service_id"),
        (.stopTimes, "trip_id,arrival_time,departure_time,stop_id\nsyn-t1,05:00:00,05:00:00,syn-s1\n", "stop_sequence"),
        (.calendar, "service_id,monday,tuesday,wednesday,thursday,friday,saturday,start_date,end_date\nsyn-weekday,1,1,1,1,1,0,20990101,20991231\n", "sunday"),
        (.calendarDates, "service_id,date\nsyn-weekday,20990505\n", "exception_type"),
        (.feedInfo, "feed_publisher_name,feed_publisher_url\nSynthetic,https://example.invalid\n", "feed_lang"),
        (.translations, "table_name,field_name,language,field_value\nstops,stop_name,en,Synthetic One\n", "translation"),
    ])
    func missingRequiredColumnIsInvalid(table: GTFSTableName, text: String, column: String) async {
        await SyntheticGTFSFeed.replacing(table, with: text)
            .expectFailure(invalid(.missingRequiredColumn(column), table, line: 1))
    }

    @Test(arguments: [
        (GTFSTableName.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,,35.0,139.0\n", "stop_name"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,Synthetic One,,139.0\n", "stop_lat"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\n,Synthetic One,35.0,139.0\n", "stop_id"),
        (.trips, "route_id,service_id,trip_id\nsyn-r1,syn-weekday,\n", "trip_id"),
        (.routes, "route_id,route_short_name,route_long_name,route_type\nsyn-r1,,,1\n", "route_long_name"),
        (.stopTimes, "trip_id,arrival_time,departure_time,stop_id,stop_sequence\nsyn-t1,05:00:00,05:00:00,,10\n", "stop_id"),
        (.translations, "table_name,field_name,language,translation,field_value\nstops,stop_name,en,Synthetic One (EN),\n", "field_value"),
    ])
    func missingRequiredValueIsInvalid(table: GTFSTableName, text: String, column: String) async {
        await SyntheticGTFSFeed.replacing(table, with: text)
            .expectFailure(invalid(.missingRequiredValue(column: column), table, line: 2))
    }

    @Test func routeWithOnlyAShortNameIsAccepted() async throws {
        let text = "route_id,route_short_name,route_long_name,route_type\nsyn-r1,SL,,1\n"

        let read = try await SyntheticGTFSFeed.replacing(.routes, with: text).read()

        #expect(read.routes[0].shortName == "SL")
        #expect(read.routes[0].longName == nil)
    }

    /// `feed_info` translations are keyed by neither `record_id` nor
    /// `field_value`.
    @Test func feedInfoTranslationNeedsNoFieldValue() async throws {
        let text = "table_name,field_name,language,translation,field_value\nfeed_info,feed_publisher_name,en,Synthetic Publisher (EN),\n"

        let read = try await SyntheticGTFSFeed.replacing(.translations, with: text).read()

        #expect(read.translations[0].fieldValue == nil)
    }

    // MARK: - Duplicate identifiers (S)

    @Test(arguments: [
        (GTFSTableName.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,35.0,139.0\nsyn-s2,B,35.1,139.1\nsyn-s1,C,35.2,139.2\n", "stop_id", "syn-s1"),
        (.routes, "route_id,route_long_name,route_type\nsyn-r1,A,1\nsyn-r2,B,1\nsyn-r1,C,1\n", "route_id", "syn-r1"),
        (.trips, "route_id,service_id,trip_id\nsyn-r1,syn-weekday,syn-t1\nsyn-r1,syn-weekday,syn-t2\nsyn-r1,syn-weekday,syn-t1\n", "trip_id", "syn-t1"),
    ])
    func duplicateIdentifierIsInvalid(table: GTFSTableName, text: String, column: String, value: String) async {
        await SyntheticGTFSFeed.replacing(table, with: text)
            .expectFailure(invalid(.duplicateIdentifier(column: column, value: value), table, line: 4))
    }

    // MARK: - References (S)

    @Test func tripRouteMustResolve() async {
        let text = "route_id,service_id,trip_id\nsyn-r9,syn-weekday,syn-t1\n"

        await SyntheticGTFSFeed.replacing(.trips, with: text)
            .expectFailure(invalid(.unresolvedReference(column: "route_id", value: "syn-r9"), .trips, line: 2))
    }

    @Test func tripServiceMustResolveInCalendarOrCalendarDates() async {
        let text = "route_id,service_id,trip_id\nsyn-r1,syn-holiday,syn-t1\n"

        await SyntheticGTFSFeed.replacing(.trips, with: text)
            .expectFailure(invalid(.unresolvedReference(column: "service_id", value: "syn-holiday"), .trips, line: 2))
    }

    @Test func serviceDefinedOnlyInCalendarDatesResolves() async throws {
        var feed = SyntheticGTFSFeed.valid
        feed.calendar = nil

        let read = try await feed.read()

        #expect(read.calendars.isEmpty)
        #expect(read.trips[0].serviceID == "syn-weekday")
    }

    @Test func serviceIsUnresolvedWhenBothCalendarTablesAreAbsent() async {
        var feed = SyntheticGTFSFeed.valid
        feed.calendar = nil
        feed.calendarDates = nil

        await feed.expectFailure(invalid(.unresolvedReference(column: "service_id", value: "syn-weekday"), .trips, line: 2))
    }

    @Test func stopTimeTripMustResolve() async {
        let text = Self.stopTimes(["syn-t9,05:00:00,05:00:00,syn-s1,10,0,0,1"])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.unresolvedReference(column: "trip_id", value: "syn-t9"), .stopTimes, line: 2))
    }

    @Test func stopTimeStopMustResolve() async {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
            "syn-t1,05:10:00,05:10:00,syn-s9,20,0,0,1",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.unresolvedReference(column: "stop_id", value: "syn-s9"), .stopTimes, line: 3))
    }

    /// (S) "Referenced locations must be stops/platforms."
    @Test func stopTimeMustNotReferenceAStation() async {
        var feed = SyntheticGTFSFeed.valid
        feed.stops = Data("""
            stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station
            syn-station,Synthetic Station,35.0,139.0,1,
            syn-s1,Synthetic One,35.0,139.0,0,syn-station
            syn-s2,Synthetic Two,35.1,139.1,0,
            syn-s3,Synthetic Three,35.2,139.2,0,

            """.utf8)
        feed.stopTimes = Data(Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-station,10,0,0,1",
            "syn-t1,05:10:00,05:10:00,syn-s3,20,0,0,1",
        ]).utf8)

        await feed.expectFailure(invalid(.referencedLocationIsNotAStop(stopID: "syn-station"), .stopTimes, line: 2))
    }

    @Test func stopWithAStationParentIsAccepted() async throws {
        let text = """
            stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station
            syn-station,Synthetic Station,35.0,139.0,1,
            syn-s1,Synthetic One,35.0,139.0,0,syn-station
            syn-s2,Synthetic Two,35.1,139.1,,
            syn-s3,Synthetic Three,35.2,139.2,,

            """

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops[0].locationType == .station)
        #expect(read.stops[1].parentStation == "syn-station")
    }

    /// (S) A station's `parent_station` must be empty.
    @Test func parentStationOnAStationIsInvalid() async {
        let text = """
            stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station
            syn-station-a,Synthetic A,35.0,139.0,1,
            syn-station-b,Synthetic B,35.0,139.0,1,syn-station-a
            syn-s1,Synthetic One,35.0,139.0,0,
            syn-s2,Synthetic Two,35.1,139.1,0,
            syn-s3,Synthetic Three,35.2,139.2,0,

            """

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.parentStationOnStation, .stops, line: 3))
    }

    /// (S) A stop or platform's `parent_station` names a station.
    @Test func parentStationThatIsNotAStationIsInvalid() async {
        let text = """
            stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station
            syn-s1,Synthetic One,35.0,139.0,0,
            syn-s2,Synthetic Two,35.1,139.1,0,syn-s1
            syn-s3,Synthetic Three,35.2,139.2,0,

            """

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.parentStationIsNotAStation(parentStation: "syn-s1"), .stops, line: 3))
    }

    @Test func parentStationMustResolve() async {
        let text = """
            stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station
            syn-s1,Synthetic One,35.0,139.0,0,syn-missing
            syn-s2,Synthetic Two,35.1,139.1,0,
            syn-s3,Synthetic Three,35.2,139.2,0,

            """

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.unresolvedReference(column: "parent_station", value: "syn-missing"), .stops, line: 2))
    }

    // MARK: - stop_sequence (S)

    /// (S) "The values must increase along the trip but do not need to be
    /// consecutive."
    @Test func stopSequenceGapsAreValid() async throws {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,0,0,0,1",
            "syn-t1,05:10:00,05:10:00,syn-s2,7,0,0,1",
            "syn-t1,05:20:00,05:20:00,syn-s3,1000,0,0,1",
        ])

        let read = try await SyntheticGTFSFeed.replacing(.stopTimes, with: text).read()

        #expect(read.stopTimes.map(\.stopSequence) == [0, 7, 1000])
    }

    @Test func repeatedStopSequenceWithinATripIsInvalid() async {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
            "syn-t1,05:10:00,05:10:00,syn-s2,10,0,0,1",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.repeatedStopSequence(tripID: "syn-t1", stopSequence: 10), .stopTimes, line: 3))
    }

    /// Trips may interleave in the file; each trip is checked on its own rows.
    @Test func interleavedTripsAreAcceptedInSourceOrder() async throws {
        var feed = SyntheticGTFSFeed.valid
        feed.trips = Data("route_id,service_id,trip_id\nsyn-r1,syn-weekday,syn-t1\nsyn-r1,syn-weekday,syn-t2\n".utf8)
        feed.stopTimes = Data(Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,1,0,0,1",
            "syn-t2,06:00:00,06:00:00,syn-s3,1,0,0,1",
            "syn-t1,05:10:00,05:10:00,syn-s2,2,0,0,1",
            "syn-t2,06:10:00,06:10:00,syn-s2,2,0,0,1",
        ]).utf8)

        let read = try await feed.read()

        #expect(read.stopTimes.map(\.tripID) == ["syn-t1", "syn-t2", "syn-t1", "syn-t2"])
    }

    /// A trip's rows out of `stop_sequence` order in the file are valid GTFS
    /// but outside this reader's supported shape.
    @Test func stopSequenceDecreasingInSourceOrderIsUnsupported() async {
        let text = Self.stopTimes([
            "syn-t1,05:10:00,05:10:00,syn-s2,20,0,0,1",
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(unsupported(.stopSequenceNotInSourceOrder(tripID: "syn-t1"), .stopTimes, line: 3))
    }

    /// A repeat is invalid wherever it lies, so it is reported even when an
    /// earlier row is out of source order.
    @Test func repeatedStopSequenceOutranksAnEarlierSourceOrderDecrease() async {
        let text = Self.stopTimes([
            "syn-t1,05:10:00,05:10:00,syn-s2,20,0,0,1",
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
            "syn-t1,05:20:00,05:20:00,syn-s3,20,0,0,1",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.repeatedStopSequence(tripID: "syn-t1", stopSequence: 20), .stopTimes, line: 4))
    }

    /// The specification sets no upper bound, so an integer too large for the
    /// reader is a limitation, not an invalid value.
    @Test func integerTooLargeForTheReaderIsUnsupported() async {
        let huge = "99999999999999999999"
        let text = "trip_id,arrival_time,departure_time,stop_id,stop_sequence\nsyn-t1,05:00:00,05:00:00,syn-s1,\(huge)\n"

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(unsupported(.numberForm(column: "stop_sequence", value: huge), .stopTimes, line: 2))
    }

    // MARK: - Times (S)

    @Test(arguments: [
        ("5:00:00", GTFSTime(hours: 5, minutes: 0, seconds: 0)),
        ("05:00:00", GTFSTime(hours: 5, minutes: 0, seconds: 0)),
        ("23:59:59", GTFSTime(hours: 23, minutes: 59, seconds: 59)),
        ("24:00:00", GTFSTime(hours: 24, minutes: 0, seconds: 0)),
        ("25:35:00", GTFSTime(hours: 25, minutes: 35, seconds: 0)),
    ])
    func validTimeFormsAreAccepted(text: String, expected: GTFSTime) async throws {
        let rows = Self.stopTimes([
            "syn-t1,\(text),\(text),syn-s1,10,0,0,1",
            "syn-t1,26:00:00,26:00:00,syn-s3,20,0,0,1",
        ])

        let read = try await SyntheticGTFSFeed.replacing(.stopTimes, with: rows).read()

        #expect(read.stopTimes[0].arrivalTime == expected)
        #expect(read.stopTimes[0].departureTime == expected)
    }

    /// (S) `departure_time` is required only on `timepoint = 1` rows, so a
    /// blank departure on the first or last stop is valid.
    @Test func blankDepartureAtTripEndsIsValidWhenNotATimepoint() async throws {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,,syn-s1,10,0,0,0",
            "syn-t1,05:20:00,,syn-s3,20,0,0,0",
        ])

        let read = try await SyntheticGTFSFeed.replacing(.stopTimes, with: text).read()

        #expect(read.stopTimes.allSatisfy { $0.departureTime == nil })
    }

    /// (S) Blank intermediate times are optional on non-timepoint rows. The
    /// valid feed's middle row also matches the observed Toei passed-station
    /// shape (O), which is kept as stated.
    @Test func blankIntermediateTimesOnApproximateRowsAreKeptAsStated() async throws {
        let read = try await SyntheticGTFSFeed.valid.read()
        let middle = read.stopTimes[1]

        #expect(middle.arrivalTime == nil)
        #expect(middle.departureTime == nil)
        #expect(middle.pickupType == GTFSPickupDropOffType.none)
        #expect(middle.dropOffType == GTFSPickupDropOffType.none)
        #expect(middle.timepoint == .approximate)
    }

    @Test(arguments: [
        "syn-t1,,05:00:00,syn-s1,10,0,0,0",
        "syn-t1,,05:00:00,syn-s1,10,0,0,",
    ])
    func blankArrivalAtFirstStopIsInvalid(firstRow: String) async {
        let text = Self.stopTimes([firstRow, "syn-t1,05:20:00,05:20:00,syn-s3,20,0,0,1"])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.missingArrivalTimeAtTripEnd(tripID: "syn-t1"), .stopTimes, line: 2))
    }

    @Test func blankArrivalAtLastStopIsInvalid() async {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
            "syn-t1,,05:20:00,syn-s3,20,0,0,0",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.missingArrivalTimeAtTripEnd(tripID: "syn-t1"), .stopTimes, line: 3))
    }

    @Test(arguments: [
        ("syn-t1,,05:10:00,syn-s2,20,0,0,1", "arrival_time"),
        ("syn-t1,05:10:00,,syn-s2,20,0,0,1", "departure_time"),
    ])
    func blankTimeOnAnExactTimepointIsInvalid(middleRow: String, column: String) async {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
            middleRow,
            "syn-t1,05:20:00,05:20:00,syn-s3,30,0,0,1",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(invalid(.missingTimeAtTimepoint(column: column), .stopTimes, line: 3))
    }

    // MARK: - Malformed values (S)

    @Test(arguments: [
        (GTFSTableName.stopTimes, "arrival_time", "5:0:00"),
        (.stopTimes, "arrival_time", "05:60:00"),
        (.stopTimes, "arrival_time", "05:00:60"),
        (.stopTimes, "arrival_time", "05:00"),
        (.stopTimes, "arrival_time", "105:00:00"),
        (.stopTimes, "arrival_time", "0a:00:00"),
        (.stopTimes, "stop_sequence", "-1"),
        (.stopTimes, "stop_sequence", "1.5"),
        (.stopTimes, "pickup_type", "4"),
        (.stopTimes, "pickup_type", "01"),
        (.stopTimes, "drop_off_type", "x"),
        (.stopTimes, "timepoint", "2"),
    ])
    func malformedStopTimeValueIsInvalid(table: GTFSTableName, column: String, value: String) async {
        var fields = [
            "trip_id": "syn-t1", "arrival_time": "05:00:00", "departure_time": "05:00:00", "stop_id": "syn-s1",
            "stop_sequence": "10", "pickup_type": "0", "drop_off_type": "0", "timepoint": "1",
        ]
        fields[column] = value
        let columns = Self.stopTimesHeader.split(separator: ",").map(String.init)
        let row = columns.map { fields[$0]! }.joined(separator: ",")

        await SyntheticGTFSFeed.replacing(table, with: Self.stopTimes([row]))
            .expectFailure(invalid(.malformedValue(column: column, value: value), table, line: 2))
    }

    @Test(arguments: [
        (GTFSTableName.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,abc,139.0\n", "stop_lat", "abc"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,90.5,139.0\n", "stop_lat", "90.5"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,35.0,-180.1\n", "stop_lon", "-180.1"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,nan,139.0\n", "stop_lat", "nan"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,.,139.0\n", "stop_lat", "."),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon,location_type\nsyn-s1,A,35.0,139.0,5\n", "location_type", "5"),
        (.routes, "route_id,route_long_name,route_type\nsyn-r1,A,8\n", "route_type", "8"),
        (.routes, "route_id,route_long_name,route_type\nsyn-r1,A,100\n", "route_type", "100"),
        (.routes, "route_id,route_long_name,route_type\nsyn-r1,A,01\n", "route_type", "01"),
        (.routes, "route_id,route_long_name,route_type\nsyn-r1,A,+1\n", "route_type", "+1"),
        (.trips, "route_id,service_id,trip_id,direction_id\nsyn-r1,syn-weekday,syn-t1,2\n", "direction_id", "2"),
        (.calendar, "service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date\nsyn-weekday,1,1,1,1,1,0,2,20990101,20991231\n", "sunday", "2"),
        (.calendarDates, "service_id,date,exception_type\nsyn-weekday,20990505,3\n", "exception_type", "3"),
        (.translations, "table_name,field_name,language,translation,field_value\nfares,fare_name,en,Synthetic,Synthetic\n", "table_name", "fares"),
    ])
    func malformedValueIsInvalid(table: GTFSTableName, text: String, column: String, value: String) async {
        await SyntheticGTFSFeed.replacing(table, with: text)
            .expectFailure(invalid(.malformedValue(column: column, value: value), table, line: 2))
    }

    @Test func boundaryCoordinatesAndSignedDecimalsAreAccepted() async throws {
        let text = """
            stop_id,stop_name,stop_lat,stop_lon
            syn-s1,Synthetic One,90,180
            syn-s2,Synthetic Two,-90.0,-180.0
            syn-s3,Synthetic Three,+.5,0.

            """

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops.map(\.latitude) == [90, -90, 0.5])
        #expect(read.stops.map(\.longitude) == [180, -180, 0])
    }

    // MARK: - Unsupported shapes

    @Test(arguments: [GTFSLocationType.entranceOrExit, .genericNode, .boardingArea])
    func unsupportedLocationTypesAreReported(type: GTFSLocationType) async {
        let text = """
            stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station
            syn-station,Synthetic Station,35.0,139.0,1,
            syn-node,Synthetic Node,35.0,139.0,\(type.rawValue),syn-station

            """

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(unsupported(.locationType(type), .stops, line: 3))
    }

    @Test(arguments: ["location_group_id", "location_id", "start_pickup_drop_off_window", "end_pickup_drop_off_window"])
    func flexibleStopTimesAreUnsupported(column: String) async {
        let text = """
            trip_id,arrival_time,departure_time,stop_id,stop_sequence,\(column)
            syn-t1,05:00:00,05:00:00,syn-s1,10,
            syn-t1,,,,20,syn-flex

            """

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(unsupported(.flexibleStopTime, .stopTimes, line: 3))
    }

    /// Where the specification does not fix a number's notation, a form the
    /// reader does not read is unsupported.
    @Test(arguments: [
        (GTFSTableName.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,3e1,139.0\n", "stop_lat", "3e1"),
        (.stops, "stop_id,stop_name,stop_lat,stop_lon\nsyn-s1,A,35.0,1.39E+2\n", "stop_lon", "1.39E+2"),
        (.stopTimes, "trip_id,arrival_time,departure_time,stop_id,stop_sequence\nsyn-t1,05:00:00,05:00:00,syn-s1,+1\n", "stop_sequence", "+1"),
    ])
    func unreadNumberFormsAreUnsupported(table: GTFSTableName, text: String, column: String, value: String) async {
        await SyntheticGTFSFeed.replacing(table, with: text)
            .expectFailure(unsupported(.numberForm(column: column, value: value), table, line: 2))
    }

    /// (S) Without `record_id`: `field_value` and `record_sub_id` are
    /// forbidden for `feed_info`, and `record_sub_id` is forbidden when
    /// `field_value` is defined.
    @Test(arguments: [
        ("feed_info,feed_publisher_name,en,Synthetic (EN),Synthetic Publisher,", "field_value"),
        ("feed_info,feed_publisher_name,en,Synthetic (EN),,syn-sub", "record_sub_id"),
        ("stops,stop_name,en,Synthetic One (EN),Synthetic One,syn-sub", "record_sub_id"),
    ])
    func forbiddenTranslationKeysAreInvalid(row: String, column: String) async {
        let text = "table_name,field_name,language,translation,field_value,record_sub_id\n" + row + "\n"

        await SyntheticGTFSFeed.replacing(.translations, with: text)
            .expectFailure(invalid(.forbiddenValue(column: column), .translations, line: 2))
    }

    @Test func translationByRecordIDIsUnsupported() async {
        let text = """
            table_name,field_name,language,translation,record_id,field_value
            stops,stop_name,en,Synthetic One (EN),syn-s1,

            """

        await SyntheticGTFSFeed.replacing(.translations, with: text)
            .expectFailure(unsupported(.translationByRecordID, .translations, line: 2))
    }

    /// (P) A blank time with no `timepoint` value is not interpreted.
    @Test func blankTimeWithoutTimepointIsUnsupported() async {
        let text = Self.stopTimes([
            "syn-t1,05:00:00,05:00:00,syn-s1,10,0,0,1",
            "syn-t1,,,syn-s2,20,1,1,",
            "syn-t1,05:20:00,05:20:00,syn-s3,30,0,0,1",
        ])

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(unsupported(.blankTimeWithoutTimepoint, .stopTimes, line: 3))
    }

    @Test func blankTimeWithoutATimepointColumnIsUnsupported() async {
        let text = """
            trip_id,arrival_time,departure_time,stop_id,stop_sequence
            syn-t1,05:00:00,05:00:00,syn-s1,10
            syn-t1,,,syn-s2,20
            syn-t1,05:20:00,05:20:00,syn-s3,30

            """

        await SyntheticGTFSFeed.replacing(.stopTimes, with: text)
            .expectFailure(unsupported(.blankTimeWithoutTimepoint, .stopTimes, line: 3))
    }

    @Test func fullyTimedRowsWithoutATimepointColumnAreAccepted() async throws {
        let text = """
            trip_id,arrival_time,departure_time,stop_id,stop_sequence
            syn-t1,05:00:00,05:00:00,syn-s1,10
            syn-t1,05:20:00,05:20:00,syn-s3,30

            """

        let read = try await SyntheticGTFSFeed.replacing(.stopTimes, with: text).read()

        #expect(read.stopTimes.allSatisfy { $0.timepoint == nil })
    }

    // MARK: - Determinism and isolation

    @Test func readingTheSameInputTwiceGivesEqualFeeds() async throws {
        let first = try await SyntheticGTFSFeed.valid.read()
        let second = try await SyntheticGTFSFeed.valid.read()

        #expect(first == second)
    }

    /// With several problems, the same first problem is always reported: the
    /// agency error precedes the stop_times error in the fixed work order.
    @Test func theFirstReportedProblemIsStable() async {
        var feed = SyntheticGTFSFeed.valid
        feed.agency = Data("agency_name\nSynthetic\n".utf8)
        feed.stopTimes = Data("trip_id\nsyn-t1\n".utf8)

        for _ in 0..<3 {
            await feed.expectFailure(invalid(.missingRequiredColumn("agency_url"), .agency, line: 1))
        }
    }

    /// The only entry point is `@concurrent`, so a main-actor caller hands the
    /// work to the concurrent executor and receives the same result.
    @MainActor
    @Test func mainActorCallerReceivesTheSameFeed() async throws {
        let fromMainActor = try await GTFSStaticTableReader.read(SyntheticGTFSFeed.valid.texts)
        let fromDetachedTask = try await Task.detached {
            try await GTFSStaticTableReader.read(SyntheticGTFSFeed.valid.texts)
        }.value

        #expect(fromMainActor == fromDetachedTask)
    }

    @Test func feedCrossesActorBoundaries() async throws {
        let feed = try await SyntheticGTFSFeed.valid.read()

        let received = await Task.detached { feed }.value

        #expect(received == feed)
    }
}
