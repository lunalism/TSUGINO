import Foundation
import Testing
@testable import TSUGINO

/// The scoped `odpt:Railway` reader contract (DEC-067 §G), on fully invented
/// records only (DEC-067 §B). Identifiers are `syn:…`, line codes `Q`, `Qb`,
/// and `R` are invented stand-ins, and titles are "Synthetic …". The shape —
/// a branch kept as its own record — follows the retained audit; no value
/// does.
struct ODPTRailwayReaderTests {

    private static func record(
        id: String = "syn:Railway.Q",
        sameAs: String? = nil,
        operatorReference: String = "syn:Operator.Synthetic",
        lineCode: String = "Q",
        stations: Int = 3,
        extra: String = ""
    ) -> String {
        let order = (1...max(stations, 1)).prefix(stations).map { index in
            #"{"odpt:index": \#(index), "odpt:station": "\#(id).S\#(index)", "odpt:stationTitle": {"ja": "合成\#(index)", "en": "Synthetic \#(index)"}}"#
        }.joined(separator: ", ")
        return """
            {"@type": "odpt:Railway", "@id": "\(id)", "owl:sameAs": "\(sameAs ?? id)", "odpt:operator": "\(operatorReference)", \
            "odpt:lineCode": "\(lineCode)", "odpt:railwayTitle": {"ja": "合成線", "en": "Synthetic Line", "ko": "합성선"}, \
            "odpt:color": "#123ABC", "odpt:ascendingRailDirection": "syn:Direction.Up", \
            "odpt:descendingRailDirection": "syn:Direction.Down", "odpt:stationOrder": [\(order)]\(extra)}
            """
    }

    private static func read(_ json: String) async throws(ODPTRailwayReadError) -> [ODPTRailway] {
        try await ODPTRailwayReader.read(Data(json.utf8))
    }

    private static func expectFailure(
        _ json: String,
        _ expected: ODPTRailwayReadError,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        await expectFailure(Data(json.utf8), expected, sourceLocation: sourceLocation)
    }

    private static func expectFailure(
        _ data: Data,
        _ expected: ODPTRailwayReadError,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        do {
            let records = try await ODPTRailwayReader.read(data)
            Issue.record("expected \(expected), but read \(records.count) records", sourceLocation: sourceLocation)
        } catch {
            #expect(error == expected, sourceLocation: sourceLocation)
        }
    }

    private static func unsupported(_ reason: ODPTRailwayUnsupportedInput, _ index: Int?, _ field: String?) -> ODPTRailwayReadError {
        .unsupported(reason, at: ODPTRailwayLocation(recordIndex: index, field: field))
    }

    // MARK: - Accepted

    @Test func recordsAreReadInSourceOrderWithValuesPreserved() async throws {
        let json = "[" + [
            Self.record(id: "syn:Railway.Q", lineCode: "Q", stations: 3),
            Self.record(id: "syn:Railway.QBranch", lineCode: "Qb", stations: 2),
            Self.record(id: "syn:Railway.R", lineCode: "R", stations: 1),
        ].joined(separator: ",") + "]"

        let records = try await Self.read(json)

        #expect(records.map(\.id) == ["syn:Railway.Q", "syn:Railway.QBranch", "syn:Railway.R"])
        #expect(records.map(\.lineCode) == ["Q", "Qb", "R"])
        let first = records[0]
        #expect(first.sameAs == "syn:Railway.Q")
        #expect(first.operatorReference == "syn:Operator.Synthetic")
        #expect(first.color == "#123ABC")
        #expect(first.ascendingRailDirection == "syn:Direction.Up")
        #expect(first.descendingRailDirection == "syn:Direction.Down")
        #expect(first.stationOrder.map(\.index) == [1, 2, 3])
        #expect(first.stationOrder.map(\.station) == ["syn:Railway.Q.S1", "syn:Railway.Q.S2", "syn:Railway.Q.S3"])
    }

    /// A branch is its own record: nothing merges, renames, or relates it.
    @Test func branchRecordIsKeptAsADistinctRecord() async throws {
        let json = "[" + Self.record(id: "syn:Railway.Q", lineCode: "Q") + "," +
            Self.record(id: "syn:Railway.QBranch", lineCode: "Qb", stations: 2) + "]"

        let records = try await Self.read(json)

        #expect(records.count == 2)
        let branch = records[1]
        #expect(branch.id == "syn:Railway.QBranch" && branch.lineCode == "Qb")
        #expect(branch.stationOrder.count == 2)
    }

    @Test func languageMapsKeepEveryLanguageSortedAndRequireNone() async throws {
        let onlyTwo = Self.record().replacingOccurrences(
            of: #""odpt:railwayTitle": {"ja": "合成線", "en": "Synthetic Line", "ko": "합성선"}"#,
            with: #""odpt:railwayTitle": {"zh-Hant": "合成線", "ja-Hrkt": "ごうせいせん"}"#)
        let empty = Self.record(id: "syn:Railway.E", lineCode: "E").replacingOccurrences(
            of: #""odpt:railwayTitle": {"ja": "合成線", "en": "Synthetic Line", "ko": "합성선"}"#,
            with: #""odpt:railwayTitle": {}"#)

        let records = try await Self.read("[\(onlyTwo),\(empty)]")

        #expect(records[0].title.entries.map(\.language) == ["ja-Hrkt", "zh-Hant"])
        #expect(records[0].title.entries.map(\.text) == ["ごうせいせん", "合成線"])
        #expect(records[1].title.entries.isEmpty)
        let full = try await Self.read("[\(Self.record())]")
        #expect(full[0].title.entries.map(\.language) == ["en", "ja", "ko"])
        #expect(full[0].stationOrder[0].title?.entries.map(\.language) == ["en", "ja"])
    }

    @Test func optionalFieldsMayBeAbsentAndUnknownKeysAreIgnored() async throws {
        let json = """
            [{"@type": "odpt:Railway", "@id": "syn:Railway.Q", "owl:sameAs": "syn:Railway.Q", \
            "odpt:operator": "syn:Operator.Synthetic", "odpt:lineCode": "Q", "odpt:railwayTitle": {"en": "Synthetic"}, \
            "odpt:stationOrder": [{"odpt:index": 1, "odpt:station": "syn:Station.A", "syn:extension": [1, 2]}], \
            "@context": "https://example.invalid/context", "dc:date": "2099-01-01T00:00:00+09:00", "syn:unknown": {"a": 1}}]
            """

        let records = try await Self.read(json)

        #expect(records[0].color == nil)
        #expect(records[0].ascendingRailDirection == nil && records[0].descendingRailDirection == nil)
        #expect(records[0].stationOrder[0].title == nil)
    }

    @Test func emptyArrayYieldsNoRecords() async throws {
        #expect(try await Self.read("[]").isEmpty)
    }

    @Test func readingTheSameInputTwiceGivesEqualRecords() async throws {
        let json = "[" + Self.record() + "," + Self.record(id: "syn:Railway.R", lineCode: "R") + "]"
        let first = try await Self.read(json)
        let second = try await Self.read(json)

        #expect(first == second)
    }

    /// The only entry point is `@concurrent`, so a main-actor caller hands the
    /// work to the concurrent executor and receives the same result.
    @MainActor
    @Test func mainActorCallerReceivesTheSameRecords() async throws {
        let data = Data("[\(Self.record())]".utf8)
        let fromMainActor = try await ODPTRailwayReader.read(data)
        let fromDetachedTask = try await Task.detached { try await ODPTRailwayReader.read(data) }.value

        #expect(fromMainActor == fromDetachedTask)
    }

    // MARK: - Invalid

    @Test func invalidUTF8IsInvalid() async {
        await Self.expectFailure(Data("[\"".utf8) + Data([0xFF]) + Data("\"]".utf8), .invalid(.invalidUTF8))
    }

    @Test(arguments: ["[", "[{]", "{\"a\": }", "", "[1,]", "NaN"])
    func malformedJSONIsInvalid(json: String) async {
        await Self.expectFailure(json, .invalid(.malformedJSON))
    }

    /// Each breaks the RFC 8259 grammar: a leading zero, a bare fraction
    /// point, an empty exponent, a plus sign, a capitalized literal, a raw
    /// control character, an unknown escape, a short `\u` escape, an
    /// unquoted key, a doubled comma, and text after the value.
    @Test(arguments: ["[01]", "[1.]", "[1e]", "[+1]", "[TRUE]", "[\"a\tb\"]", "[\"\\x\"]", "[\"\\u12\"]", "{a: 1}", "[1,,2]", "[] []"])
    func grammarViolationsAreInvalid(json: String) async {
        await Self.expectFailure(json, .invalid(.malformedJSON))
    }

    /// The grammar is checked before repeated keys, so a syntax error later in
    /// the input is still reported as invalid.
    @Test func grammarViolationAfterARepeatedKeyIsInvalid() async {
        let repeated = Self.record(extra: #", "odpt:lineCode": "Q2""#)
        await Self.expectFailure("[\(repeated),]", .invalid(.malformedJSON))
    }

    /// RFC 8259 forbids a trailing comma; Foundation's parser tolerates one,
    /// so the reader's grammar check rejects it.
    @Test func trailingCommasAreInvalidEverywhere() async {
        let record = Self.record()
        // After the last array element.
        await Self.expectFailure("[\(record),]", .invalid(.malformedJSON))
        // After a record's last member.
        await Self.expectFailure("[" + String(record.dropLast()) + ",}]", .invalid(.malformedJSON))
        // Inside a nested title map.
        let nested = record.replacingOccurrences(of: #""ko": "합성선"}"#, with: #""ko": "합성선",}"#)
        await Self.expectFailure("[\(nested)]", .invalid(.malformedJSON))
    }

    /// A trailing comma inside a string is text, not syntax.
    @Test func commaBeforeABracketInsideAStringIsAccepted() async throws {
        let json = "[" + Self.record().replacingOccurrences(of: #""en": "Synthetic Line""#, with: #""en": "Synthetic, ]Line\",}""#) + "]"

        let records = try await Self.read(json)

        #expect(records[0].title.entries.first { $0.language == "en" }?.text == #"Synthetic, ]Line",}"#)
    }

    @Test func leadingByteOrderMarkIsAccepted() async throws {
        let records = try await ODPTRailwayReader.read(Data([0xEF, 0xBB, 0xBF]) + Data("[\(Self.record())]".utf8))

        #expect(records.count == 1)
    }

    // MARK: - Unsupported

    /// RFC 8259 permits repeated keys but leaves them undefined; the parser
    /// would keep one value, so the reader cannot preserve the provider's.
    @Test func repeatedObjectKeyIsUnsupportedWithItsRecordAndKey() async {
        let second = Self.record(id: "syn:Railway.R", lineCode: "R")
            .replacingOccurrences(of: #""odpt:lineCode": "R","#, with: #""odpt:lineCode": "R", "odpt:lineCode": "R2","#)
        await Self.expectFailure("[\(Self.record()),\(second)]", Self.unsupported(.duplicateKey, 1, "odpt:lineCode"))

        let nested = Self.record().replacingOccurrences(of: #""ko": "합성선""#, with: #""ko": "합성선", "ka": "x", "ko": "y""#)
        await Self.expectFailure("[\(nested)]", Self.unsupported(.duplicateKey, 0, "ko"))
    }

    /// A repeated key that is neither a reader field nor a language tag in a
    /// title map is provider text, so the error does not name it — even when
    /// it is shaped like a language tag.
    @Test(arguments: [
        #", "syn:extension": {"syn:Private Key": 1, "syn:Private Key": 2}"#,
        #", "syn:extension": {"abc": 1, "abc": 2}"#,
        #", "abc": 1, "abc": 2"#,
    ])
    func repeatedUnknownKeyIsUnsupportedWithoutNamingIt(extra: String) async {
        await Self.expectFailure("[\(Self.record(extra: extra))]", Self.unsupported(.duplicateKey, 0, nil))
    }

    @Test func repeatedLanguageKeyInAStationTitleIsNamed() async {
        let station = Self.record().replacingOccurrences(of: #""en": "Synthetic 2"}"#, with: #""en": "Synthetic 2", "en": "x"}"#)
        await Self.expectFailure("[\(station)]", Self.unsupported(.duplicateKey, 0, "en"))
    }

    /// Well-formed JSON the platform parser refuses — deep nesting, a number
    /// beyond its range, a lone-surrogate escape — is within RFC 8259's
    /// implementation limits (§8.2, §9), so it is unsupported, not invalid.
    @Test(arguments: [
        #", "syn:nested": "# + String(repeating: "[", count: 600) + String(repeating: "]", count: 600),
        #", "syn:number": 1e400"#,
        #", "syn:text": "\ud800""#,
    ])
    func wellFormedJSONBeyondThePlatformParserIsUnsupported(extra: String) async {
        await Self.expectFailure("[\(Self.record(extra: extra))]", Self.unsupported(.platformParserLimit, nil, nil))
    }

    @Test(arguments: ["{}", "\"text\"", "42", "null", "true"])
    func topLevelThatIsNotAnArrayIsUnsupported(json: String) async {
        await Self.expectFailure(json, Self.unsupported(.topLevelNotArray, nil, nil))
    }

    @Test(arguments: ["1", "\"record\"", "null", "[]"])
    func elementThatIsNotAnObjectIsUnsupported(element: String) async {
        await Self.expectFailure("[\(Self.record()),\(element)]", Self.unsupported(.recordNotObject, 1, nil))
    }

    @Test func otherTypeIsUnsupported() async {
        let json = "[" + Self.record().replacingOccurrences(of: #""@type": "odpt:Railway""#, with: #""@type": "odpt:Station""#) + "]"

        await Self.expectFailure(json, Self.unsupported(.unexpectedType, 0, "@type"))
    }

    @Test(arguments: ["@type", "@id", "owl:sameAs", "odpt:operator", "odpt:lineCode", "odpt:railwayTitle", "odpt:stationOrder"])
    func missingRequiredFieldIsUnsupported(field: String) async throws {
        let object = try JSONSerialization.jsonObject(with: Data(Self.record().utf8)) as! [String: Any]
        var trimmed = object
        trimmed.removeValue(forKey: field)
        let data = try JSONSerialization.data(withJSONObject: [trimmed])

        await Self.expectFailure(data, Self.unsupported(.missingField, 0, field))
    }

    @Test(arguments: [
        ("@type", "1"), ("@id", "1"), ("owl:sameAs", "true"), ("odpt:operator", "[]"), ("odpt:lineCode", "{}"),
        ("odpt:railwayTitle", "\"Synthetic\""), ("odpt:stationOrder", "{}"),
        ("odpt:color", "7"), ("odpt:ascendingRailDirection", "null"), ("odpt:descendingRailDirection", "[]"),
    ])
    func wronglyTypedFieldIsUnsupported(field: String, replacement: String) async throws {
        var object = try JSONSerialization.jsonObject(with: Data(Self.record().utf8)) as! [String: Any]
        object[field] = try JSONSerialization.jsonObject(with: Data(replacement.utf8), options: [.fragmentsAllowed])
        let data = try JSONSerialization.data(withJSONObject: [object])

        await Self.expectFailure(data, Self.unsupported(.wrongFieldType, 0, field))
    }

    @Test func titleValueThatIsNotAStringIsUnsupported() async {
        let json = "[" + Self.record().replacingOccurrences(of: #""en": "Synthetic Line""#, with: #""en": 5"#) + "]"

        await Self.expectFailure(json, Self.unsupported(.titleValueNotString, 0, "odpt:railwayTitle"))
    }

    @Test func stationTitleValueThatIsNotAStringIsUnsupported() async {
        let json = "[" + Self.record().replacingOccurrences(of: #""en": "Synthetic 2""#, with: #""en": null"#) + "]"

        await Self.expectFailure(json, Self.unsupported(.titleValueNotString, 0, "odpt:stationOrder[1].odpt:stationTitle"))
    }

    @Test(arguments: [
        (#"{"odpt:station": "syn:S"}"#, ODPTRailwayUnsupportedInput.missingField, "odpt:stationOrder[0].odpt:index"),
        (#"{"odpt:index": "1", "odpt:station": "syn:S"}"#, .wrongFieldType, "odpt:stationOrder[0].odpt:index"),
        (#"{"odpt:index": 1.0, "odpt:station": "syn:S"}"#, .wrongFieldType, "odpt:stationOrder[0].odpt:index"),
        (#"{"odpt:index": true, "odpt:station": "syn:S"}"#, .wrongFieldType, "odpt:stationOrder[0].odpt:index"),
        (#"{"odpt:index": 1}"#, .missingField, "odpt:stationOrder[0].odpt:station"),
        (#"{"odpt:index": 1, "odpt:station": 9}"#, .wrongFieldType, "odpt:stationOrder[0].odpt:station"),
        (#"{"odpt:index": 1, "odpt:station": "syn:S", "odpt:stationTitle": "x"}"#, .wrongFieldType, "odpt:stationOrder[0].odpt:stationTitle"),
        (#""syn:S""#, .wrongFieldType, "odpt:stationOrder[0]"),
    ])
    func malformedStationOrderEntryIsUnsupported(entry: String, reason: ODPTRailwayUnsupportedInput, field: String) async {
        // The entry text is spliced in as written, so `1.0` stays a float.
        let json = "[" + Self.record(stations: 0)
            .replacingOccurrences(of: #""odpt:stationOrder": []"#, with: #""odpt:stationOrder": ["# + entry + "]") + "]"

        await Self.expectFailure(json, Self.unsupported(reason, 0, field))
    }

    /// Indices, in source order, must be exactly 1, 2, …, n.
    @Test(arguments: [([2], 0), ([0], 0), ([1, 3], 1), ([1, 1], 1), ([2, 1], 0)])
    func stationOrderIndicesNotContiguousFromOneAreUnsupported(indices: [Int], failingPosition: Int) async throws {
        var object = try JSONSerialization.jsonObject(with: Data(Self.record().utf8)) as! [String: Any]
        object["odpt:stationOrder"] = indices.enumerated().map { ["odpt:index": $0.element, "odpt:station": "syn:S\($0.offset)"] }
        let data = try JSONSerialization.data(withJSONObject: [object])

        await Self.expectFailure(
            data, Self.unsupported(.stationOrderIndicesNotContiguous, 0, "odpt:stationOrder[\(failingPosition)].odpt:index"))
    }

    @Test(arguments: [
        (#"{"id": "syn:Railway.Q", "lineCode": "R"}"#, "@id"),
        (#"{"id": "syn:Railway.R", "sameAs": "syn:Railway.Q", "lineCode": "R"}"#, "owl:sameAs"),
        (#"{"id": "syn:Railway.R", "lineCode": "Q"}"#, "odpt:lineCode"),
    ])
    func duplicateValueAcrossRecordsIsUnsupported(second: String, field: String) async throws {
        let values = try JSONSerialization.jsonObject(with: Data(second.utf8)) as! [String: String]
        let json = "[" + Self.record(id: "syn:Railway.Q", lineCode: "Q") + "," +
            Self.record(id: values["id"]!, sameAs: values["sameAs"], lineCode: values["lineCode"]!) + "]"

        await Self.expectFailure(json, Self.unsupported(.duplicateValue, 1, field))
    }

    @Test func mixedOperatorsAreUnsupported() async {
        let json = "[" + Self.record() + "," +
            Self.record(id: "syn:Railway.R", operatorReference: "syn:Operator.Other", lineCode: "R") + "]"

        await Self.expectFailure(json, Self.unsupported(.mixedOperators, 1, "odpt:operator"))
    }

    /// The first problem is reported, in record order, and no error carries a
    /// provider value.
    @Test func errorsCarryOnlyAnIndexAndAFieldName() async {
        let json = "[" + Self.record() + "," + Self.record(id: "syn:Railway.Q", lineCode: "R") + "]"
        do {
            _ = try await Self.read(json)
            Issue.record("the duplicate was accepted")
        } catch {
            #expect(error == Self.unsupported(.duplicateValue, 1, "@id"))
            #expect(!String(describing: error).contains("syn:"), "an error carried a provider value")
        }
    }
}
