import Foundation

// The P2-S1 static GTFS table reader (DEC-065 §B–§D).
//
// Reads the caller-supplied text of nine GTFS tables into provider DTOs.
// It performs no archive extraction, file access, or networking; creates no
// canonical identifier, mapping, or Domain value; and reads no fare table.
//
// Work order is fixed, so the first problem reported for a given input is
// always the same: each table is parsed and its rows decoded in the order
// agency, stops, routes, trips, stop_times, calendar, calendar_dates,
// feed_info, translations; then cross-table and per-trip checks run in the
// order documented on `validate`.
//
// The CSV layer and the row decoder below are `fileprivate` and live in this
// file so that no other code can run them synchronously: the `@concurrent`
// `read(_:)` is the only way into parsing and validation.

nonisolated enum GTFSStaticTableReader {
    /// Reads and validates the tables off the caller's actor.
    ///
    /// `@concurrent` runs this on the global concurrent executor even when
    /// the caller is the main actor (Rule 14, DEC-027). It is the only entry
    /// point, so parsing and validation cannot run on the main actor.
    @concurrent
    static func read(_ tables: GTFSStaticTableTexts) async throws(GTFSStaticReadError) -> GTFSStaticFeed {
        try readTables(tables)
    }

    private static func readTables(_ tables: GTFSStaticTableTexts) throws(GTFSStaticReadError) -> GTFSStaticFeed {
        let agencies = try decodeAgencies(tables.agency)
        let stops = try decodeStops(tables.stops)
        let routes = try decodeRoutes(tables.routes)
        let trips = try decodeTrips(tables.trips)
        let stopTimes = try decodeStopTimes(tables.stopTimes)
        let calendars = try tables.calendar.map { data throws(GTFSStaticReadError) in try decodeCalendars(data) } ?? []
        let calendarDates = try tables.calendarDates.map { data throws(GTFSStaticReadError) in try decodeCalendarDates(data) } ?? []
        let feedInfo = try tables.feedInfo.map { data throws(GTFSStaticReadError) in try decodeFeedInfo(data) } ?? []
        let translations = try tables.translations.map { data throws(GTFSStaticReadError) in try decodeTranslations(data) } ?? []

        try validate(
            stops: stops,
            routes: routes,
            trips: trips,
            stopTimes: stopTimes,
            serviceIDs: Set(calendars.map(\.value.serviceID) + calendarDates.map(\.value.serviceID))
        )

        return GTFSStaticFeed(
            agencies: agencies.map(\.value),
            stops: stops.map(\.value),
            routes: routes.map(\.value),
            trips: trips.map(\.value),
            stopTimes: stopTimes.map(\.value),
            calendars: calendars.map(\.value),
            calendarDates: calendarDates.map(\.value),
            feedInfo: feedInfo.map(\.value),
            translations: translations.map(\.value)
        )
    }

    /// A decoded row with the location it came from, kept only for errors.
    private struct Located<Value> {
        let value: Value
        let location: GTFSSourceLocation
    }

    // MARK: - Tables

    private static func decodeAgencies(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSAgency>] {
        let csv = try GTFSCSVTable.parse(data, table: .agency)
        let row = try GTFSRowDecoder(csv, table: .agency, required: ["agency_name", "agency_url", "agency_timezone"])
        var result: [Located<GTFSAgency>] = []
        for record in csv.records {
            let agency = GTFSAgency(
                agencyID: row.optional("agency_id", in: record),
                name: try row.required("agency_name", in: record),
                url: try row.required("agency_url", in: record),
                timezone: try row.required("agency_timezone", in: record),
                language: row.optional("agency_lang", in: record)
            )
            result.append(Located(value: agency, location: row.location(record)))
        }
        return result
    }

    private static func decodeStops(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSStop>] {
        let csv = try GTFSCSVTable.parse(data, table: .stops)
        let row = try GTFSRowDecoder(csv, table: .stops, required: ["stop_id"])
        var result: [Located<GTFSStop>] = []
        var stopIDs = Set<String>()
        for record in csv.records {
            let stopID = try row.required("stop_id", in: record)
            let locationType = try row.enumeration("location_type", in: record, as: GTFSLocationType.self)
            switch locationType {
            case .entranceOrExit, .genericNode, .boardingArea:
                throw .unsupported(.locationType(locationType!), at: row.location(record))
            case nil, .stopOrPlatform, .station:
                break
            }
            guard stopIDs.insert(stopID).inserted else {
                throw .invalid(.duplicateIdentifier(column: "stop_id", value: stopID), at: row.location(record))
            }
            // stop_name, stop_lat, and stop_lon are required for stops and
            // stations, the only location types this reader supports.
            let stop = GTFSStop(
                stopID: stopID,
                stopCode: row.optional("stop_code", in: record),
                name: try row.required("stop_name", in: record),
                latitude: try row.coordinate("stop_lat", in: record, range: -90...90),
                longitude: try row.coordinate("stop_lon", in: record, range: -180...180),
                locationType: locationType,
                parentStation: row.optional("parent_station", in: record),
                platformCode: row.optional("platform_code", in: record)
            )
            result.append(Located(value: stop, location: row.location(record)))
        }
        return result
    }

    /// The `route_type` values the GTFS Schedule Reference lists. Extended
    /// route types (100 and above) are a separate convention the reference
    /// does not include, so they are invalid here like any unlisted value.
    private static let routeTypes: Set<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 11, 12]

    private static func decodeRoutes(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSRoute>] {
        let csv = try GTFSCSVTable.parse(data, table: .routes)
        let row = try GTFSRowDecoder(csv, table: .routes, required: ["route_id", "route_type"])
        var result: [Located<GTFSRoute>] = []
        var routeIDs = Set<String>()
        for record in csv.records {
            let routeID = try row.required("route_id", in: record)
            guard routeIDs.insert(routeID).inserted else {
                throw .invalid(.duplicateIdentifier(column: "route_id", value: routeID), at: row.location(record))
            }
            let typeText = try row.required("route_type", in: record)
            guard let routeType = Int(typeText), String(routeType) == typeText, routeTypes.contains(routeType) else {
                throw row.malformed("route_type", typeText, in: record)
            }
            let shortName = row.optional("route_short_name", in: record)
            let longName = row.optional("route_long_name", in: record)
            // Each name is conditionally required when the other is blank.
            guard shortName != nil || longName != nil else {
                throw .invalid(.missingRequiredValue(column: "route_long_name"), at: row.location(record))
            }
            let route = GTFSRoute(
                routeID: routeID,
                agencyID: row.optional("agency_id", in: record),
                shortName: shortName,
                longName: longName,
                routeType: routeType,
                color: row.optional("route_color", in: record),
                textColor: row.optional("route_text_color", in: record)
            )
            result.append(Located(value: route, location: row.location(record)))
        }
        return result
    }

    private enum DirectionID: Int {
        case zero = 0
        case one = 1
    }

    private static func decodeTrips(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSTrip>] {
        let csv = try GTFSCSVTable.parse(data, table: .trips)
        let row = try GTFSRowDecoder(csv, table: .trips, required: ["route_id", "service_id", "trip_id"])
        var result: [Located<GTFSTrip>] = []
        var tripIDs = Set<String>()
        for record in csv.records {
            let tripID = try row.required("trip_id", in: record)
            guard tripIDs.insert(tripID).inserted else {
                throw .invalid(.duplicateIdentifier(column: "trip_id", value: tripID), at: row.location(record))
            }
            let trip = GTFSTrip(
                tripID: tripID,
                routeID: try row.required("route_id", in: record),
                serviceID: try row.required("service_id", in: record),
                headsign: row.optional("trip_headsign", in: record),
                shortName: row.optional("trip_short_name", in: record),
                directionID: try row.enumeration("direction_id", in: record, as: DirectionID.self)?.rawValue,
                blockID: row.optional("block_id", in: record)
            )
            result.append(Located(value: trip, location: row.location(record)))
        }
        return result
    }

    private static let flexibleStopTimeColumns = [
        "location_group_id", "location_id", "start_pickup_drop_off_window", "end_pickup_drop_off_window",
    ]

    private static func decodeStopTimes(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSStopTime>] {
        let csv = try GTFSCSVTable.parse(data, table: .stopTimes)
        let row = try GTFSRowDecoder(csv, table: .stopTimes, required: ["trip_id", "stop_sequence"])
        var result: [Located<GTFSStopTime>] = []
        for record in csv.records {
            if flexibleStopTimeColumns.contains(where: { row.optional($0, in: record) != nil }) {
                throw .unsupported(.flexibleStopTime, at: row.location(record))
            }
            let sequenceText = try row.required("stop_sequence", in: record)
            let stopTime = GTFSStopTime(
                tripID: try row.required("trip_id", in: record),
                stopID: try row.required("stop_id", in: record),
                stopSequence: try row.nonNegativeInteger("stop_sequence", sequenceText, in: record),
                arrivalTime: try row.time("arrival_time", in: record),
                departureTime: try row.time("departure_time", in: record),
                stopHeadsign: row.optional("stop_headsign", in: record),
                pickupType: try row.enumeration("pickup_type", in: record, as: GTFSPickupDropOffType.self),
                dropOffType: try row.enumeration("drop_off_type", in: record, as: GTFSPickupDropOffType.self),
                timepoint: try row.enumeration("timepoint", in: record, as: GTFSTimepoint.self)
            )
            result.append(Located(value: stopTime, location: row.location(record)))
        }
        return result
    }

    private enum ServiceDay: Int {
        case notAvailable = 0
        case available = 1
    }

    private static let weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

    private static func decodeCalendars(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSCalendar>] {
        let csv = try GTFSCSVTable.parse(data, table: .calendar)
        let row = try GTFSRowDecoder(csv, table: .calendar, required: ["service_id"] + weekdays + ["start_date", "end_date"])
        var result: [Located<GTFSCalendar>] = []
        for record in csv.records {
            var days: [Bool] = []
            for day in weekdays {
                days.append(try row.requiredEnumeration(day, in: record, as: ServiceDay.self) == .available)
            }
            let calendar = GTFSCalendar(
                serviceID: try row.required("service_id", in: record),
                monday: days[0],
                tuesday: days[1],
                wednesday: days[2],
                thursday: days[3],
                friday: days[4],
                saturday: days[5],
                sunday: days[6],
                startDate: try row.required("start_date", in: record),
                endDate: try row.required("end_date", in: record)
            )
            result.append(Located(value: calendar, location: row.location(record)))
        }
        return result
    }

    private static func decodeCalendarDates(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSCalendarDate>] {
        let csv = try GTFSCSVTable.parse(data, table: .calendarDates)
        let row = try GTFSRowDecoder(csv, table: .calendarDates, required: ["service_id", "date", "exception_type"])
        var result: [Located<GTFSCalendarDate>] = []
        for record in csv.records {
            let calendarDate = GTFSCalendarDate(
                serviceID: try row.required("service_id", in: record),
                date: try row.required("date", in: record),
                exceptionType: try row.requiredEnumeration("exception_type", in: record, as: GTFSExceptionType.self)
            )
            result.append(Located(value: calendarDate, location: row.location(record)))
        }
        return result
    }

    private static func decodeFeedInfo(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSFeedInfo>] {
        let csv = try GTFSCSVTable.parse(data, table: .feedInfo)
        let row = try GTFSRowDecoder(
            csv,
            table: .feedInfo,
            required: ["feed_publisher_name", "feed_publisher_url", "feed_lang"]
        )
        var result: [Located<GTFSFeedInfo>] = []
        for record in csv.records {
            let info = GTFSFeedInfo(
                publisherName: try row.required("feed_publisher_name", in: record),
                publisherURL: try row.required("feed_publisher_url", in: record),
                language: try row.required("feed_lang", in: record),
                startDate: row.optional("feed_start_date", in: record),
                endDate: row.optional("feed_end_date", in: record),
                version: row.optional("feed_version", in: record)
            )
            result.append(Located(value: info, location: row.location(record)))
        }
        return result
    }

    /// The `translations.table_name` values the GTFS Schedule Reference
    /// (revised 2026-04-27) allows. An unlisted value is invalid.
    private static let translatableTables: Set<String> = [
        "agency", "stops", "routes", "trips", "stop_times", "pathways", "levels", "feed_info", "attributions",
    ]

    private static func decodeTranslations(_ data: Data) throws(GTFSStaticReadError) -> [Located<GTFSTranslation>] {
        let csv = try GTFSCSVTable.parse(data, table: .translations)
        let row = try GTFSRowDecoder(
            csv,
            table: .translations,
            required: ["table_name", "field_name", "language", "translation"]
        )
        var result: [Located<GTFSTranslation>] = []
        for record in csv.records {
            if row.optional("record_id", in: record) != nil {
                throw .unsupported(.translationByRecordID, at: row.location(record))
            }
            let tableName = try row.required("table_name", in: record)
            guard translatableTables.contains(tableName) else {
                throw row.malformed("table_name", tableName, in: record)
            }
            let fieldValue = row.optional("field_value", in: record)
            let hasSubID = row.optional("record_sub_id", in: record) != nil
            // With no `record_id`: `feed_info` rows carry neither
            // `field_value` nor `record_sub_id`; every other row needs
            // `field_value`, which forbids `record_sub_id`.
            if tableName == "feed_info" {
                if fieldValue != nil {
                    throw .invalid(.forbiddenValue(column: "field_value"), at: row.location(record))
                }
                if hasSubID {
                    throw .invalid(.forbiddenValue(column: "record_sub_id"), at: row.location(record))
                }
            } else {
                if fieldValue == nil {
                    throw .invalid(.missingRequiredValue(column: "field_value"), at: row.location(record))
                }
                if hasSubID {
                    throw .invalid(.forbiddenValue(column: "record_sub_id"), at: row.location(record))
                }
            }
            let translation = GTFSTranslation(
                tableName: tableName,
                fieldName: try row.required("field_name", in: record),
                language: try row.required("language", in: record),
                translation: try row.required("translation", in: record),
                fieldValue: fieldValue
            )
            result.append(Located(value: translation, location: row.location(record)))
        }
        return result
    }

    // MARK: - Cross-table and per-trip checks

    /// Runs, in order:
    /// 1. `stops.parent_station`: absent on stations; on a stop or platform it
    ///    must name a station;
    /// 2. `trips.route_id` → `routes`, then `trips.service_id` →
    ///    `calendar` ∪ `calendar_dates`, row by row;
    /// 3. `stop_times.trip_id` → `trips`, then `stop_times.stop_id` → a stop
    ///    or platform, row by row;
    /// 4. across all rows: a `stop_sequence` repeated within a trip is
    ///    invalid; then, per trip in source order, a decrease is unsupported
    ///    — so a repeat is always reported as invalid, wherever it lies;
    /// 5. per row, in source order: time presence rules, where an invalid
    ///    blank is reported before an unsupported one.
    private static func validate(
        stops: [Located<GTFSStop>],
        routes: [Located<GTFSRoute>],
        trips: [Located<GTFSTrip>],
        stopTimes: [Located<GTFSStopTime>],
        serviceIDs: Set<String>
    ) throws(GTFSStaticReadError) {
        var stopsByID: [String: GTFSStop] = [:]
        for stop in stops {
            stopsByID[stop.value.stopID] = stop.value
        }

        for stop in stops {
            guard let parent = stop.value.parentStation else { continue }
            if stop.value.locationType == .station {
                throw .invalid(.parentStationOnStation, at: stop.location)
            }
            guard let parentStop = stopsByID[parent] else {
                throw .invalid(.unresolvedReference(column: "parent_station", value: parent), at: stop.location)
            }
            guard parentStop.locationType == .station else {
                throw .invalid(.parentStationIsNotAStation(parentStation: parent), at: stop.location)
            }
        }

        let routeIDs = Set(routes.map(\.value.routeID))
        for trip in trips {
            guard routeIDs.contains(trip.value.routeID) else {
                throw .invalid(.unresolvedReference(column: "route_id", value: trip.value.routeID), at: trip.location)
            }
            guard serviceIDs.contains(trip.value.serviceID) else {
                throw .invalid(.unresolvedReference(column: "service_id", value: trip.value.serviceID), at: trip.location)
            }
        }

        let tripIDs = Set(trips.map(\.value.tripID))
        for stopTime in stopTimes {
            guard tripIDs.contains(stopTime.value.tripID) else {
                throw .invalid(.unresolvedReference(column: "trip_id", value: stopTime.value.tripID), at: stopTime.location)
            }
            guard let stop = stopsByID[stopTime.value.stopID] else {
                throw .invalid(.unresolvedReference(column: "stop_id", value: stopTime.value.stopID), at: stopTime.location)
            }
            guard stop.locationType != .station else {
                throw .invalid(.referencedLocationIsNotAStop(stopID: stop.stopID), at: stopTime.location)
            }
        }

        // With source order confirmed increasing per trip, a trip's first and
        // last rows in the file are its first and last stops.
        var seenSequences: [String: Set<Int>] = [:]
        for stopTime in stopTimes {
            let tripID = stopTime.value.tripID
            let sequence = stopTime.value.stopSequence
            guard seenSequences[tripID, default: []].insert(sequence).inserted else {
                throw .invalid(.repeatedStopSequence(tripID: tripID, stopSequence: sequence), at: stopTime.location)
            }
        }

        var lastSequence: [String: Int] = [:]
        var lastRowIndex: [String: Int] = [:]
        for (index, stopTime) in stopTimes.enumerated() {
            let tripID = stopTime.value.tripID
            let sequence = stopTime.value.stopSequence
            if let previous = lastSequence[tripID], sequence < previous {
                throw .unsupported(.stopSequenceNotInSourceOrder(tripID: tripID), at: stopTime.location)
            }
            lastSequence[tripID] = sequence
            lastRowIndex[tripID] = index
        }

        var startedTrips = Set<String>()
        for (index, stopTime) in stopTimes.enumerated() {
            let value = stopTime.value
            let isFirst = startedTrips.insert(value.tripID).inserted
            let isLast = lastRowIndex[value.tripID] == index
            if value.arrivalTime == nil, isFirst || isLast {
                throw .invalid(.missingArrivalTimeAtTripEnd(tripID: value.tripID), at: stopTime.location)
            }
            switch value.timepoint {
            case .exact:
                if value.arrivalTime == nil {
                    throw .invalid(.missingTimeAtTimepoint(column: "arrival_time"), at: stopTime.location)
                }
                if value.departureTime == nil {
                    throw .invalid(.missingTimeAtTimepoint(column: "departure_time"), at: stopTime.location)
                }
            case nil:
                if value.arrivalTime == nil || value.departureTime == nil {
                    throw .unsupported(.blankTimeWithoutTimepoint, at: stopTime.location)
                }
            case .approximate:
                break
            }
        }
    }
}

// MARK: - CSV layer

// CSV layer of the P2-S1 static GTFS reader (DEC-065 §D).
//
// Specification rules applied here (GTFS Schedule Reference, published
// 2026-04-27): a byte-order mark is acceptable; lines end in CRLF or LF;
// a field containing a comma or quotation mark is quoted, with embedded
// quotation marks doubled; no field contains a tab, carriage return, or
// line feed; the first line names the fields. Reader policies: UTF-8 only; a
// final line without a terminator is accepted; a duplicated header name is
// rejected; every record must have exactly the header's field count; a blank
// line after the header — which the specification does not address — is
// reported as unsupported. Values are preserved exactly — nothing is trimmed
// or normalised.

/// One parsed table: its header and its data records in source order.
fileprivate nonisolated struct GTFSCSVTable: Sendable {
    let header: [String]
    let records: [Record]

    struct Record: Sendable {
        /// The 1-based line on which the record starts.
        let line: Int
        let fields: [String]
        /// True when the line holds no bytes at all before its terminator.
        let isBlank: Bool
    }

    private static let comma = UInt8(ascii: ",")
    private static let quote = UInt8(ascii: "\"")
    private static let carriageReturn = UInt8(ascii: "\r")
    private static let lineFeed = UInt8(ascii: "\n")
    private static let tab = UInt8(ascii: "\t")
    private static let byteOrderMark: [UInt8] = [0xEF, 0xBB, 0xBF]

    /// Parses `data` as the text of `table`.
    ///
    /// Checking the whole input as UTF-8 first makes byte-level scanning
    /// safe: the ASCII delimiters never occur inside a multi-byte sequence.
    static func parse(_ data: Data, table: GTFSTableName) throws(GTFSStaticReadError) -> GTFSCSVTable {
        var bytes = [UInt8](data)
        if let offset = firstInvalidUTF8Offset(in: bytes) {
            let line = 1 + bytes[..<offset].reduce(0) { $1 == lineFeed ? $0 + 1 : $0 }
            throw .invalid(.invalidUTF8, at: GTFSSourceLocation(table: table, line: line))
        }
        if bytes.starts(with: byteOrderMark) {
            bytes.removeFirst(byteOrderMark.count)
        }

        let rows = try splitRecords(bytes, table: table)
        guard let headerRow = rows.first, !headerRow.isBlank else {
            throw .invalid(.missingHeader, at: GTFSSourceLocation(table: table, line: 1))
        }

        var seen = Set<String>()
        for name in headerRow.fields {
            // Every header field must name a field (specification).
            guard !name.isEmpty else {
                throw .invalid(.emptyColumnName, at: GTFSSourceLocation(table: table, line: headerRow.line))
            }
            guard seen.insert(name).inserted else {
                throw .invalid(.duplicateColumn(name), at: GTFSSourceLocation(table: table, line: headerRow.line))
            }
        }

        let records = Array(rows.dropFirst())
        for record in records {
            if record.isBlank {
                throw .unsupported(.blankLine, at: GTFSSourceLocation(table: table, line: record.line))
            }
            if record.fields.count != headerRow.fields.count {
                throw .invalid(
                    .fieldCountMismatch(expected: headerRow.fields.count, found: record.fields.count),
                    at: GTFSSourceLocation(table: table, line: record.line)
                )
            }
        }
        return GTFSCSVTable(header: headerRow.fields, records: records)
    }

    private enum State {
        case fieldStart
        case unquoted
        case quoted
        case afterClosingQuote
    }

    /// Splits validated UTF-8 bytes into records of fields.
    private static func splitRecords(_ bytes: [UInt8], table: GTFSTableName) throws(GTFSStaticReadError) -> [Record] {
        var records: [Record] = []
        var fields: [String] = []
        var field: [UInt8] = []
        var state = State.fieldStart
        var recordHasBytes = false
        var line = 1
        var recordLine = 1
        var index = 0

        func location() -> GTFSSourceLocation {
            GTFSSourceLocation(table: table, line: line)
        }

        func endField() {
            fields.append(String(decoding: field, as: UTF8.self))
            field.removeAll(keepingCapacity: true)
        }

        func endRecord() {
            endField()
            records.append(Record(line: recordLine, fields: fields, isBlank: !recordHasBytes))
            fields.removeAll(keepingCapacity: true)
            state = .fieldStart
            recordHasBytes = false
        }

        while index < bytes.count {
            let byte = bytes[index]
            if byte != lineFeed, byte != carriageReturn {
                recordHasBytes = true
            }

            if state == .quoted {
                if byte == quote {
                    if index + 1 < bytes.count, bytes[index + 1] == quote {
                        field.append(quote)
                        index += 2
                        continue
                    }
                    state = .afterClosingQuote
                } else if byte == carriageReturn || byte == lineFeed || byte == tab {
                    throw .invalid(.forbiddenCharacterInField, at: location())
                } else {
                    field.append(byte)
                }
                index += 1
                continue
            }

            switch byte {
            case comma:
                endField()
                state = .fieldStart
            case lineFeed:
                endRecord()
                line += 1
                recordLine = line
            case carriageReturn:
                // Only CRLF ends a line; a lone carriage return is a forbidden
                // character inside the field.
                guard index + 1 < bytes.count, bytes[index + 1] == lineFeed else {
                    throw .invalid(.forbiddenCharacterInField, at: location())
                }
                endRecord()
                line += 1
                recordLine = line
                index += 1
            case quote:
                guard state == .fieldStart else {
                    throw .invalid(.malformedQuoting, at: location())
                }
                state = .quoted
            case tab:
                throw .invalid(.forbiddenCharacterInField, at: location())
            default:
                guard state != .afterClosingQuote else {
                    throw .invalid(.malformedQuoting, at: location())
                }
                field.append(byte)
                state = .unquoted
            }
            index += 1
        }

        if state == .quoted {
            throw .invalid(.unterminatedQuotedField, at: GTFSSourceLocation(table: table, line: recordLine))
        }
        // A final line without a terminator is accepted (reader policy). Input
        // that ends with a terminator leaves nothing pending here.
        if state != .fieldStart || !fields.isEmpty {
            endRecord()
        }
        return records
    }

    /// The byte offset of the first invalid UTF-8 sequence, or `nil`.
    private static func firstInvalidUTF8Offset(in bytes: [UInt8]) -> Int? {
        var iterator = bytes.makeIterator()
        var parser = Unicode.UTF8.ForwardParser()
        var offset = 0
        while true {
            switch parser.parseScalar(from: &iterator) {
            case .valid(let scalar):
                offset += scalar.count
            case .emptyInput:
                return nil
            case .error:
                return offset
            }
        }
    }
}

// MARK: - Row decoder

// Row-level access and value syntax for the P2-S1 static GTFS reader
// (DEC-065 §D). Every check here is syntax only; no value gains Domain
// meaning. Where the specification fixes a value's text — an enumeration's
// constants, the time format — anything else is invalid. Where it does not
// fix the notation — the sign of an integer, exponent notation in a decimal —
// a form this reader does not read is unsupported, not invalid.

/// Reads the fields of one table's records by column name.
fileprivate nonisolated struct GTFSRowDecoder {
    let table: GTFSTableName
    private let columns: [String: Int]

    /// Fails when any `required` column is absent from the header.
    init(_ csv: GTFSCSVTable, table: GTFSTableName, required: [String]) throws(GTFSStaticReadError) {
        self.table = table
        var columns: [String: Int] = [:]
        for (index, name) in csv.header.enumerated() {
            columns[name] = index
        }
        for name in required where columns[name] == nil {
            throw .invalid(.missingRequiredColumn(name), at: GTFSSourceLocation(table: table, line: 1))
        }
        self.columns = columns
    }

    func location(_ record: GTFSCSVTable.Record) -> GTFSSourceLocation {
        GTFSSourceLocation(table: table, line: record.line)
    }

    /// The field's text, or `nil` when the column is absent or the field is
    /// empty. Values are returned exactly as written.
    func optional(_ column: String, in record: GTFSCSVTable.Record) -> String? {
        guard let index = columns[column] else { return nil }
        let value = record.fields[index]
        return value.isEmpty ? nil : value
    }

    func required(_ column: String, in record: GTFSCSVTable.Record) throws(GTFSStaticReadError) -> String {
        guard let value = optional(column, in: record) else {
            throw .invalid(.missingRequiredValue(column: column), at: location(record))
        }
        return value
    }

    func malformed(_ column: String, _ value: String, in record: GTFSCSVTable.Record) -> GTFSStaticReadError {
        .invalid(.malformedValue(column: column, value: value), at: location(record))
    }

    /// A non-negative integer written with ASCII digits only. A `+`-signed
    /// integer, or one too large for `Int` (the specification sets no upper
    /// bound), is unsupported; anything else that is not such an integer,
    /// including a negative or fractional value, is invalid.
    func nonNegativeInteger(_ column: String, _ value: String, in record: GTFSCSVTable.Record) throws(GTFSStaticReadError) -> Int {
        if Self.isDigits(value) {
            guard let number = Int(value) else {
                throw .unsupported(.numberForm(column: column, value: value), at: location(record))
            }
            return number
        }
        if value.hasPrefix("+"), Self.isDigits(String(value.dropFirst())) {
            throw .unsupported(.numberForm(column: column, value: value), at: location(record))
        }
        throw malformed(column, value, in: record)
    }

    private static func isDigits(_ text: String) -> Bool {
        !text.isEmpty && text.utf8.allSatisfy { (0x30...0x39).contains($0) }
    }

    /// An optional enumeration value; `nil` when blank. The text must be one
    /// of the specification's constants exactly, so `01` is not `1`.
    func enumeration<Value: RawRepresentable>(
        _ column: String,
        in record: GTFSCSVTable.Record,
        as type: Value.Type
    ) throws(GTFSStaticReadError) -> Value? where Value.RawValue == Int {
        guard let text = optional(column, in: record) else { return nil }
        guard let raw = Int(text), String(raw) == text, let value = Value(rawValue: raw) else {
            throw malformed(column, text, in: record)
        }
        return value
    }

    func requiredEnumeration<Value: RawRepresentable>(
        _ column: String,
        in record: GTFSCSVTable.Record,
        as type: Value.Type
    ) throws(GTFSStaticReadError) -> Value where Value.RawValue == Int {
        guard let value = try enumeration(column, in: record, as: type) else {
            throw .invalid(.missingRequiredValue(column: column), at: location(record))
        }
        return value
    }

    /// A time as `H:MM:SS` or `HH:MM:SS`; hours may exceed 23. `nil` when blank.
    func time(_ column: String, in record: GTFSCSVTable.Record) throws(GTFSStaticReadError) -> GTFSTime? {
        guard let text = optional(column, in: record) else { return nil }
        let parts = text.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 3,
              (1...2).contains(parts[0].count), parts[1].count == 2, parts[2].count == 2,
              parts.allSatisfy({ $0.utf8.allSatisfy { (0x30...0x39).contains($0) } }),
              let hours = Int(parts[0]), let minutes = Int(parts[1]), let seconds = Int(parts[2]),
              minutes < 60, seconds < 60
        else {
            throw malformed(column, text, in: record)
        }
        return GTFSTime(hours: hours, minutes: minutes, seconds: seconds)
    }

    /// A WGS 84 decimal-degree coordinate within `range`. Exponent notation is
    /// unsupported; any other non-decimal text, or a value outside `range`,
    /// is invalid.
    func coordinate(_ column: String, in record: GTFSCSVTable.Record, range: ClosedRange<Double>) throws(GTFSStaticReadError) -> Double {
        let text = try required(column, in: record)
        guard Self.isDecimal(text) else {
            if Self.isExponentDecimal(text) {
                throw .unsupported(.numberForm(column: column, value: text), at: location(record))
            }
            throw malformed(column, text, in: record)
        }
        guard let value = Double(text), range.contains(value) else {
            throw malformed(column, text, in: record)
        }
        return value
    }

    /// A decimal mantissa followed by `e` or `E`, an optional sign, and digits.
    private static func isExponentDecimal(_ text: String) -> Bool {
        guard let marker = text.firstIndex(where: { $0 == "e" || $0 == "E" }) else { return false }
        var exponent = text[text.index(after: marker)...]
        if exponent.first == "-" || exponent.first == "+" { exponent = exponent.dropFirst() }
        return isDecimal(String(text[..<marker]))
            && !exponent.isEmpty
            && exponent.utf8.allSatisfy { (0x30...0x39).contains($0) }
    }

    /// An optional sign, ASCII digits, and at most one decimal point with
    /// digits on at least one side. Excludes exponents, `inf`, and `nan`,
    /// which `Double(_:)` would otherwise accept.
    private static func isDecimal(_ text: String) -> Bool {
        var body = Substring(text)
        if body.first == "-" || body.first == "+" { body = body.dropFirst() }
        let pieces = body.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...2).contains(pieces.count), pieces.contains(where: { !$0.isEmpty }) else { return false }
        return pieces.allSatisfy { $0.utf8.allSatisfy { (0x30...0x39).contains($0) } }
    }
}
