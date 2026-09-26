import Foundation
import Testing
@testable import TSUGINO

/// CSV and file-format cases of the P2-S1 static GTFS reader (DEC-065 §D).
/// Every input is synthetic (DEC-065 §C). (S) marks a GTFS specification
/// requirement, (P) an accepted reader policy.
struct GTFSStaticTableReaderFormatTests {

    private static let stopsHeader = "stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,parent_station"
    private static let stopRow1 = "syn-s1,SYN-01,Synthetic One,35.0,139.0,0,"
    private static let stopRow2 = "syn-s2,SYN-02,Synthetic Two,35.1,139.1,,"
    private static let stopRow3 = "syn-s3,SYN-03,Synthetic Three,-35.2,-139.2,0,"

    private static func stops(_ lines: [String], terminator: String = "\n") -> String {
        lines.joined(separator: terminator) + terminator
    }

    // MARK: - Accepted

    @Test func validFeedIsReadInSourceOrderWithValuesPreserved() async throws {
        let feed = try await SyntheticGTFSFeed.valid.read()

        #expect(feed.agencies == [
            GTFSAgency(
                agencyID: "syn-agency",
                name: "Synthetic Transit",
                url: "https://example.invalid",
                timezone: "Asia/Tokyo",
                language: nil
            ),
        ])
        #expect(feed.stops.map(\.stopID) == ["syn-s1", "syn-s2", "syn-s3"])
        #expect(feed.stops[0].locationType == .stopOrPlatform)
        #expect(feed.stops[1].locationType == nil, "a blank location_type stays blank")
        #expect(feed.stops[2].latitude == -35.2)
        #expect(feed.stops[2].longitude == -139.2)
        #expect(feed.routes == [
            GTFSRoute(
                routeID: "syn-r1",
                agencyID: "syn-agency",
                shortName: nil,
                longName: "Synthetic Line",
                routeType: 1,
                color: "123ABC",
                textColor: nil
            ),
        ])
        #expect(feed.trips == [
            GTFSTrip(
                tripID: "syn-t1",
                routeID: "syn-r1",
                serviceID: "syn-weekday",
                headsign: "Synthetic Terminus",
                shortName: nil,
                directionID: 0,
                blockID: nil
            ),
        ])
        #expect(feed.stopTimes.map(\.stopSequence) == [10, 20, 30])
        #expect(feed.stopTimes[2].arrivalTime == GTFSTime(hours: 25, minutes: 10, seconds: 0))
        #expect(feed.calendars.count == 1)
        #expect(feed.calendars[0].saturday == false)
        #expect(feed.calendars[0].startDate == "20990101")
        #expect(feed.calendarDates == [GTFSCalendarDate(serviceID: "syn-weekday", date: "20990505", exceptionType: .removed)])
        #expect(feed.feedInfo.map(\.version) == ["syn-1"])
        #expect(feed.translations == [
            GTFSTranslation(
                tableName: "stops",
                fieldName: "stop_name",
                language: "en",
                translation: "Synthetic One (EN)",
                fieldValue: "Synthetic One"
            ),
        ])
    }

    @Test func optionalTablesMayBeAbsentWhenServiceIsStillResolved() async throws {
        var feed = SyntheticGTFSFeed.valid
        feed.calendarDates = nil
        feed.feedInfo = nil
        feed.translations = nil

        let read = try await feed.read()

        #expect(read.calendarDates.isEmpty)
        #expect(read.feedInfo.isEmpty)
        #expect(read.translations.isEmpty)
    }

    /// (S) "Files that include the Unicode byte-order mark (BOM) character
    /// are acceptable." (P) The BOM is not part of the first field name.
    @Test func byteOrderMarkIsAcceptedAndNotPartOfTheFirstFieldName() async throws {
        let text = Self.stops([Self.stopsHeader, Self.stopRow1, Self.stopRow2, Self.stopRow3])
        let feed = SyntheticGTFSFeed.replacing(.stops, withData: Data([0xEF, 0xBB, 0xBF]) + Data(text.utf8))

        let read = try await feed.read()

        #expect(read.stops.map(\.stopID) == ["syn-s1", "syn-s2", "syn-s3"])
    }

    /// (S) Each line ends with CRLF or LF.
    @Test func crlfLineEndingsAreAccepted() async throws {
        let text = Self.stops([Self.stopsHeader, Self.stopRow1, Self.stopRow2, Self.stopRow3], terminator: "\r\n")

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops.map(\.stopID) == ["syn-s1", "syn-s2", "syn-s3"])
        #expect(read.stops[2].parentStation == nil, "the CR of CRLF never reaches the last field")
    }

    @Test func mixedCRLFAndLFLineEndingsAreAccepted() async throws {
        let text = Self.stopsHeader + "\r\n" + Self.stopRow1 + "\n" + Self.stopRow2 + "\r\n" + Self.stopRow3 + "\n"

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops.count == 3)
    }

    /// (P) A final line without a line terminator is accepted.
    @Test(arguments: ["\n", "\r\n"])
    func finalLineWithoutTerminatorIsAccepted(terminator: String) async throws {
        let text = [Self.stopsHeader, Self.stopRow1, Self.stopRow2, Self.stopRow3].joined(separator: terminator)

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops.map(\.stopID) == ["syn-s1", "syn-s2", "syn-s3"])
    }

    /// A final line without a terminator whose last field is empty keeps
    /// that empty field.
    @Test func finalLineEndingInAnEmptyFieldKeepsTheField() async throws {
        let text = [Self.stopsHeader, Self.stopRow1, Self.stopRow2, Self.stopRow3].joined(separator: "\n")
        #expect(text.hasSuffix(","))

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops[2].parentStation == nil)
    }

    /// (S) Values containing commas or quotation marks are quoted, with each
    /// embedded quotation mark doubled.
    @Test func quotedFieldsWithCommasAndDoubledQuotesAreDecoded() async throws {
        let text = Self.stops([
            Self.stopsHeader,
            #"syn-s1,"SYN-01","Synthetic, ""Quoted"" One",35.0,139.0,0,"#,
            Self.stopRow2,
            Self.stopRow3,
        ])

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops[0].name == #"Synthetic, "Quoted" One"#)
        #expect(read.stops[0].stopCode == "SYN-01")
    }

    @Test func quotedEmptyFieldIsBlank() async throws {
        let text = Self.stops([Self.stopsHeader, #"syn-s1,"",Synthetic One,35.0,139.0,"","""#, Self.stopRow2, Self.stopRow3])

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops[0].stopCode == nil)
        #expect(read.stops[0].locationType == nil)
        #expect(read.stops[0].parentStation == nil)
    }

    /// (P) Column order comes from the header; unused columns are ignored.
    @Test func columnOrderComesFromTheHeaderAndUnusedColumnsAreIgnored() async throws {
        let text = """
            syn_extension,stop_lon,stop_name,wheelchair_boarding,stop_id,stop_lat
            ignored,139.0,Synthetic One,1,syn-s1,35.0
            ignored,139.1,Synthetic Two,,syn-s2,35.1
            ignored,-139.2,Synthetic Three,2,syn-s3,-35.2

            """

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops.map(\.stopID) == ["syn-s1", "syn-s2", "syn-s3"])
        #expect(read.stops[0].longitude == 139.0)
        #expect(read.stops[0].stopCode == nil)
    }

    /// Values are preserved exactly: nothing is trimmed or normalised.
    @Test func valuesArePreservedWithoutTrimming() async throws {
        let text = Self.stops([Self.stopsHeader, "syn-s1,SYN-01, Synthetic One ,35.0,139.0,0,", Self.stopRow2, Self.stopRow3])

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops[0].name == " Synthetic One ")
    }

    /// (S) Field names are case-sensitive.
    @Test func fieldNamesAreCaseSensitive() async {
        let text = Self.stops(["Stop_ID,stop_name,stop_lat,stop_lon", "syn-s1,Synthetic One,35.0,139.0"])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.missingRequiredColumn("stop_id"), .stops, line: 1))
    }

    /// A header-only table is valid and yields no rows.
    @Test func headerOnlyTableYieldsNoRows() async throws {
        var feed = SyntheticGTFSFeed.valid
        feed.translations = Data("table_name,field_name,language,translation,field_value\n".utf8)

        #expect(try await feed.read().translations.isEmpty)
    }

    // MARK: - Invalid (S)

    /// (S) "Field values must not contain tabs, carriage returns or new lines."
    @Test(arguments: [
        ("syn-s1,SYN-01,Synthetic\tOne,35.0,139.0,0,", 2),
        ("syn-s1,SYN-01,\"Synthetic\tOne\",35.0,139.0,0,", 2),
        ("syn-s1,SYN-01,Synthetic\rOne,35.0,139.0,0,", 2),
        ("syn-s1,SYN-01,\"Synthetic\rOne\",35.0,139.0,0,", 2),
        ("syn-s1,SYN-01,\"Synthetic\nOne\",35.0,139.0,0,", 2),
    ])
    func forbiddenCharactersInFieldsAreInvalid(row: String, line: Int) async {
        let text = Self.stops([Self.stopsHeader, row, Self.stopRow2, Self.stopRow3])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.forbiddenCharacterInField, .stops, line: line))
    }

    @Test func forbiddenCharacterReportsItsOwnLine() async {
        let text = Self.stops([Self.stopsHeader, Self.stopRow1, Self.stopRow2, "syn-s3,SYN-03,Synthetic\tThree,35.2,139.2,0,"])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.forbiddenCharacterInField, .stops, line: 4))
    }

    /// (S) A quotation mark in a value requires the value to be quoted.
    @Test(arguments: [
        #"syn-s1,SYN-01,Synthetic "One",35.0,139.0,0,"#,
        #"syn-s1,SYN-01,"Synthetic" One,35.0,139.0,0,"#,
    ])
    func malformedQuotingIsInvalid(row: String) async {
        let text = Self.stops([Self.stopsHeader, row, Self.stopRow2, Self.stopRow3])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.malformedQuoting, .stops, line: 2))
    }

    // MARK: - Invalid (P)

    /// (P) UTF-8 only; the error names the line holding the first bad byte.
    @Test func invalidUTF8IsRejectedWithItsLine() async {
        var data = Data((Self.stopsHeader + "\n" + Self.stopRow1 + "\n").utf8)
        data.append(contentsOf: Array("syn-s2,SYN-02,Synthetic ".utf8) + [0xFF] + Array("Two,35.1,139.1,,\n".utf8))

        await SyntheticGTFSFeed.replacing(.stops, withData: data)
            .expectFailure(invalid(.invalidUTF8, .stops, line: 3))
    }

    @Test func truncatedMultibyteSequenceIsInvalidUTF8() async {
        let data = Data((Self.stopsHeader + "\n").utf8) + Data([0xE6, 0x96])

        await SyntheticGTFSFeed.replacing(.stops, withData: data)
            .expectFailure(invalid(.invalidUTF8, .stops, line: 2))
    }

    @Test func multibyteUTF8IsPreserved() async throws {
        let text = Self.stops([Self.stopsHeader, "syn-s1,SYN-01,合成駅〈サンプル〉,35.0,139.0,0,", Self.stopRow2, Self.stopRow3])

        let read = try await SyntheticGTFSFeed.replacing(.stops, with: text).read()

        #expect(read.stops[0].name == "合成駅〈サンプル〉")
    }

    /// (P) A quoted field still open at the end of the text.
    @Test func unterminatedQuotedFieldIsInvalid() async {
        let text = Self.stopsHeader + "\n" + Self.stopRow1 + "\n" + #"syn-s2,SYN-02,"Synthetic Two"#

        await SyntheticGTFSFeed.replacing(.stops, withData: Data(text.utf8))
            .expectFailure(invalid(.unterminatedQuotedField, .stops, line: 3))
    }

    /// (P) Every record has exactly the header's field count.
    @Test(arguments: [
        ("syn-s1,SYN-01,Synthetic One,35.0,139.0,0", 6),
        ("syn-s1,SYN-01,Synthetic One,35.0,139.0,0,,", 8),
    ])
    func fieldCountMismatchIsInvalid(row: String, found: Int) async {
        let text = Self.stops([Self.stopsHeader, row, Self.stopRow2, Self.stopRow3])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.fieldCountMismatch(expected: 7, found: found), .stops, line: 2))
    }

    /// The specification does not address blank lines, so one after the
    /// header is outside the reader's shape, not invalid.
    @Test(arguments: ["\n", "\r\n"])
    func blankLineAfterTheHeaderIsUnsupported(terminator: String) async {
        let text = Self.stops([Self.stopsHeader, Self.stopRow1, "", Self.stopRow2, Self.stopRow3], terminator: terminator)

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(unsupported(.blankLine, .stops, line: 3))
    }

    @Test func trailingBlankLineIsUnsupported() async {
        let text = Self.stops([Self.stopsHeader, Self.stopRow1, Self.stopRow2, Self.stopRow3]) + "\n"

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(unsupported(.blankLine, .stops, line: 5))
    }

    /// A blank line is reported in line order with other record problems.
    @Test func earlierFieldCountMismatchIsReportedBeforeALaterBlankLine() async {
        let text = Self.stops([Self.stopsHeader, "syn-s1,SYN-01", "", Self.stopRow2, Self.stopRow3])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.fieldCountMismatch(expected: 7, found: 2), .stops, line: 2))
    }

    /// (S) "The first line of each file must contain field names."
    @Test func blankFirstLineIsAMissingHeader() async {
        let text = "\n" + Self.stops([Self.stopsHeader, Self.stopRow1, Self.stopRow2, Self.stopRow3])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.missingHeader, .stops, line: 1))
    }

    /// (P) A header naming the same column twice.
    @Test func duplicatedHeaderNameIsInvalid() async {
        let text = Self.stops(["stop_id,stop_name,stop_lat,stop_lon,stop_name", "syn-s1,A,35.0,139.0,B"])

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.duplicateColumn("stop_name"), .stops, line: 1))
    }

    /// (S) Every header field names a field, so an empty one — for example
    /// from a trailing comma — is invalid rather than an ignored column.
    @Test(arguments: [
        "stop_id,stop_name,stop_lat,stop_lon,\nsyn-s1,A,35.0,139.0,\n",
        "stop_id,,stop_name,stop_lat,stop_lon\nsyn-s1,,A,35.0,139.0\n",
    ])
    func emptyHeaderFieldNameIsInvalid(text: String) async {
        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.emptyColumnName, .stops, line: 1))
    }

    @Test(arguments: [Data(), Data([0xEF, 0xBB, 0xBF])])
    func emptyTableHasNoHeader(data: Data) async {
        await SyntheticGTFSFeed.replacing(.agency, withData: data)
            .expectFailure(invalid(.missingHeader, .agency, line: 1))
    }

    // MARK: - Line numbers

    @Test func lineNumbersCountCRLFLinesFromTheHeader() async {
        let text = Self.stops([Self.stopsHeader, Self.stopRow1, Self.stopRow2, "syn-s1,SYN-09,Synthetic Dup,35.3,139.3,0,"], terminator: "\r\n")

        await SyntheticGTFSFeed.replacing(.stops, with: text)
            .expectFailure(invalid(.duplicateIdentifier(column: "stop_id", value: "syn-s1"), .stops, line: 4))
    }
}
