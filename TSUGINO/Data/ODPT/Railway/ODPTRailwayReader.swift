import Foundation

// The `odpt:Railway` reader (DEC-067 §D, §G).
//
// Decodes caller-supplied JSON bytes into DTOs in source order. It performs
// no networking and file access, mints no canonical identifier, and relates
// no record to another or to any GTFS route.
//
// Checks run in a fixed order, so the first problem reported for an input is
// always the same: UTF-8, then the RFC 8259 grammar (below), then repeated
// keys, then the platform parser, then the top-level array, then each record
// in source order — its own fields in the order below, then its operator and
// uniqueness against the records before it.

nonisolated enum ODPTRailwayReader {
    /// Reads the records off the caller's actor. `@concurrent` runs this on
    /// the global concurrent executor even when the caller is the main actor
    /// (Rule 14, DEC-027); it is the only entry point.
    @concurrent
    static func read(_ data: Data) async throws(ODPTRailwayReadError) -> [ODPTRailway] {
        try decode(data)
    }

    private static func decode(_ data: Data) throws(ODPTRailwayReadError) -> [ODPTRailway] {
        guard String(data: data, encoding: .utf8) != nil else { throw .invalid(.invalidUTF8) }
        // The RFC 8259 grammar is checked here, not by the platform parser,
        // which both tolerates trailing commas and refuses some well-formed
        // input (depth, number range, lone surrogates).
        switch StrictJSONGrammar.check([UInt8](data)) {
        case .malformed:
            throw .invalid(.malformedJSON)
        case .duplicateKey(let recordIndex, let key, let inTitleMap):
            throw .unsupported(.duplicateKey, at: ODPTRailwayLocation(recordIndex: recordIndex, field: safeFieldName(key, inTitleMap: inTitleMap)))
        case nil:
            break
        }
        let json: Any
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        } catch {
            throw .unsupported(.platformParserLimit, at: ODPTRailwayLocation(recordIndex: nil, field: nil))
        }
        guard let array = json as? [Any] else {
            throw .unsupported(.topLevelNotArray, at: ODPTRailwayLocation(recordIndex: nil, field: nil))
        }

        var records: [ODPTRailway] = []
        var ids = Set<String>()
        var sameAs = Set<String>()
        var lineCodes = Set<String>()
        for (index, element) in array.enumerated() {
            let record = try decodeRecord(element, at: index)
            if let first = records.first, first.operatorReference != record.operatorReference {
                throw unsupported(.mixedOperators, index, "odpt:operator")
            }
            guard ids.insert(record.id).inserted else { throw unsupported(.duplicateValue, index, "@id") }
            guard sameAs.insert(record.sameAs).inserted else { throw unsupported(.duplicateValue, index, "owl:sameAs") }
            guard lineCodes.insert(record.lineCode).inserted else {
                throw unsupported(.duplicateValue, index, "odpt:lineCode")
            }
            records.append(record)
        }
        return records
    }

    private static func unsupported(_ reason: ODPTRailwayUnsupportedInput, _ index: Int?, _ field: String?) -> ODPTRailwayReadError {
        .unsupported(reason, at: ODPTRailwayLocation(recordIndex: index, field: field))
    }

    private static func decodeRecord(_ element: Any, at index: Int) throws(ODPTRailwayReadError) -> ODPTRailway {
        guard let object = element as? [String: Any] else { throw unsupported(.recordNotObject, index, nil) }

        guard let type = object["@type"] else { throw unsupported(.missingField, index, "@type") }
        guard let typeText = type as? String else { throw unsupported(.wrongFieldType, index, "@type") }
        guard typeText == "odpt:Railway" else { throw unsupported(.unexpectedType, index, "@type") }

        let id = try requiredString(object, "@id", index)
        let sameAs = try requiredString(object, "owl:sameAs", index)
        let railwayOperator = try requiredString(object, "odpt:operator", index)
        let lineCode = try requiredString(object, "odpt:lineCode", index)
        guard let titleValue = object["odpt:railwayTitle"] else {
            throw unsupported(.missingField, index, "odpt:railwayTitle")
        }
        let title = try languageMap(titleValue, index, "odpt:railwayTitle")
        guard let orderValue = object["odpt:stationOrder"] else {
            throw unsupported(.missingField, index, "odpt:stationOrder")
        }
        guard let order = orderValue as? [Any] else {
            throw unsupported(.wrongFieldType, index, "odpt:stationOrder")
        }

        let color = try optionalString(object, "odpt:color", index)
        let ascending = try optionalString(object, "odpt:ascendingRailDirection", index)
        let descending = try optionalString(object, "odpt:descendingRailDirection", index)

        var entries: [ODPTStationOrderEntry] = []
        for (position, entryValue) in order.enumerated() {
            let prefix = "odpt:stationOrder[\(position)]"
            guard let entry = entryValue as? [String: Any] else {
                throw unsupported(.wrongFieldType, index, prefix)
            }
            guard let indexValue = entry["odpt:index"] else {
                throw unsupported(.missingField, index, prefix + ".odpt:index")
            }
            guard let stationIndex = integer(indexValue) else {
                throw unsupported(.wrongFieldType, index, prefix + ".odpt:index")
            }
            guard let stationValue = entry["odpt:station"] else {
                throw unsupported(.missingField, index, prefix + ".odpt:station")
            }
            guard let station = stationValue as? String else {
                throw unsupported(.wrongFieldType, index, prefix + ".odpt:station")
            }
            let stationTitle = try entry["odpt:stationTitle"].map { value throws(ODPTRailwayReadError) in
                try languageMap(value, index, prefix + ".odpt:stationTitle")
            }
            guard stationIndex == position + 1 else {
                throw unsupported(.stationOrderIndicesNotContiguous, index, prefix + ".odpt:index")
            }
            entries.append(ODPTStationOrderEntry(index: stationIndex, station: station, title: stationTitle))
        }

        return ODPTRailway(
            id: id,
            sameAs: sameAs,
            operatorReference: railwayOperator,
            lineCode: lineCode,
            title: title,
            color: color,
            ascendingRailDirection: ascending,
            descendingRailDirection: descending,
            stationOrder: entries
        )
    }

    private static func requiredString(_ object: [String: Any], _ key: String, _ index: Int) throws(ODPTRailwayReadError) -> String {
        guard let value = object[key] else { throw unsupported(.missingField, index, key) }
        guard let text = value as? String else { throw unsupported(.wrongFieldType, index, key) }
        return text
    }

    /// Absent is accepted; present must be a string.
    private static func optionalString(_ object: [String: Any], _ key: String, _ index: Int) throws(ODPTRailwayReadError) -> String? {
        guard let value = object[key] else { return nil }
        guard let text = value as? String else { throw unsupported(.wrongFieldType, index, key) }
        return text
    }

    private static func languageMap(_ value: Any, _ index: Int, _ field: String) throws(ODPTRailwayReadError) -> ODPTLanguageMap {
        guard let map = value as? [String: Any] else { throw unsupported(.wrongFieldType, index, field) }
        var entries: [ODPTLanguageMap.Entry] = []
        for language in map.keys.sorted() {
            guard let text = map[language] as? String else {
                throw unsupported(.titleValueNotString, index, field)
            }
            entries.append(.init(language: language, text: text))
        }
        return ODPTLanguageMap(entries: entries)
    }

    /// A JSON integer: an `NSNumber` that is neither a Boolean nor a
    /// floating-point value, and fits in `Int`.
    private static func integer(_ value: Any) -> Int? {
        guard let number = value as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID(),
              !CFNumberIsFloatType(number)
        else { return nil }
        return number.intValue
    }
}

/// The field names this reader knows; a repeated key is named in an error
/// only when it is one of these, or a language tag (BCP 47 shape) inside a
/// title map, because any other key is provider text.
private nonisolated let knownFieldNames: Set<String> = [
    "@type", "@id", "owl:sameAs", "odpt:operator", "odpt:lineCode", "odpt:railwayTitle", "odpt:stationOrder",
    "odpt:color", "odpt:ascendingRailDirection", "odpt:descendingRailDirection",
    "odpt:index", "odpt:station", "odpt:stationTitle",
]

private nonisolated let titleMapFieldNames: Set<String> = ["odpt:railwayTitle", "odpt:stationTitle"]

private nonisolated func safeFieldName(_ key: String, inTitleMap: Bool) -> String? {
    if knownFieldNames.contains(key) { return key }
    guard inTitleMap else { return nil }
    let isLanguageTag = key.range(of: "^[A-Za-z]{2,3}(-[A-Za-z0-9]{1,8})*$", options: .regularExpression) != nil
    return isLanguageTag ? key : nil
}

/// An iterative recognizer for the RFC 8259 JSON grammar. It builds no values
/// and keeps an explicit stack, so it has no depth limit of its own. A leading
/// UTF-8 byte-order mark is accepted, as RFC 8259 §8.1 allows. The first
/// repeated object key is remembered, but reported only if the whole input is
/// well-formed, so it never masks a syntax error. Keys are compared by their
/// decoded value, so an escaped spelling of the same key is a repeat.
private nonisolated enum StrictJSONGrammar {
    enum Finding {
        case malformed
        /// `recordIndex` is the element of the top-level array the key is in,
        /// or `nil` when the key is not inside such an element. `inTitleMap`
        /// says the object is the value of a title field.
        case duplicateKey(recordIndex: Int?, key: String, inTitleMap: Bool)
    }

    private enum Container {
        case array
        /// `lastKey` is the key whose value is being read; `isTitleMap` says
        /// this object is the value of a title field.
        case object(keys: Set<String>, lastKey: String?, isTitleMap: Bool)
    }

    private enum Expect {
        case value, arrayValueOrEnd, arrayCommaOrEnd, objectKeyOrEnd, objectKey, colon, objectCommaOrEnd, done
    }

    static func check(_ bytes: [UInt8]) -> Finding? {
        var index = bytes.starts(with: [0xEF, 0xBB, 0xBF]) ? 3 : 0
        var stack: [Container] = []
        var expect = Expect.value
        var rootIsArray = false
        var rootElement = 0
        var duplicate: Finding?

        func afterValue() {
            switch stack.last {
            case nil: expect = .done
            case .array?: expect = .arrayCommaOrEnd
            case .object?: expect = .objectCommaOrEnd
            }
        }

        while true {
            while index < bytes.count, [0x20, 0x09, 0x0A, 0x0D].contains(bytes[index]) { index += 1 }
            guard index < bytes.count else {
                return expect == .done ? duplicate : .malformed
            }
            let byte = bytes[index]
            switch expect {
            case .value, .arrayValueOrEnd:
                if expect == .arrayValueOrEnd, byte == UInt8(ascii: "]") {
                    stack.removeLast()
                    index += 1
                    afterValue()
                    continue
                }
                switch byte {
                case UInt8(ascii: "{"):
                    var isTitleMap = false
                    if case .object(_, let parentKey?, _)? = stack.last { isTitleMap = titleMapFieldNames.contains(parentKey) }
                    stack.append(.object(keys: [], lastKey: nil, isTitleMap: isTitleMap))
                    expect = .objectKeyOrEnd
                    index += 1
                case UInt8(ascii: "["):
                    if stack.isEmpty { rootIsArray = true }
                    stack.append(.array)
                    expect = .arrayValueOrEnd
                    index += 1
                case UInt8(ascii: "\""):
                    guard let end = stringEnd(bytes, from: index) else { return .malformed }
                    index = end
                    afterValue()
                case UInt8(ascii: "-"), UInt8(ascii: "0")...UInt8(ascii: "9"):
                    guard let end = numberEnd(bytes, from: index) else { return .malformed }
                    index = end
                    afterValue()
                case UInt8(ascii: "t"), UInt8(ascii: "f"), UInt8(ascii: "n"):
                    guard let end = literalEnd(bytes, from: index) else { return .malformed }
                    index = end
                    afterValue()
                default:
                    return .malformed
                }
            case .objectKeyOrEnd, .objectKey:
                if expect == .objectKeyOrEnd, byte == UInt8(ascii: "}") {
                    stack.removeLast()
                    index += 1
                    afterValue()
                    continue
                }
                guard byte == UInt8(ascii: "\""), let end = stringEnd(bytes, from: index) else { return .malformed }
                let literal = Data(bytes[index..<end])
                let key = (try? JSONSerialization.jsonObject(with: literal, options: [.fragmentsAllowed])) as? String
                    ?? String(decoding: literal, as: UTF8.self)
                if case .object(var keys, _, let isTitleMap)? = stack.last {
                    if !keys.insert(key).inserted, duplicate == nil {
                        duplicate = .duplicateKey(
                            recordIndex: rootIsArray && stack.count >= 2 ? rootElement : nil, key: key, inTitleMap: isTitleMap
                        )
                    }
                    stack[stack.count - 1] = .object(keys: keys, lastKey: key, isTitleMap: isTitleMap)
                }
                index = end
                expect = .colon
            case .colon:
                guard byte == UInt8(ascii: ":") else { return .malformed }
                index += 1
                expect = .value
            case .arrayCommaOrEnd:
                if byte == UInt8(ascii: ",") {
                    if rootIsArray, stack.count == 1 { rootElement += 1 }
                    index += 1
                    expect = .value
                } else if byte == UInt8(ascii: "]") {
                    stack.removeLast()
                    index += 1
                    afterValue()
                } else {
                    return .malformed
                }
            case .objectCommaOrEnd:
                if byte == UInt8(ascii: ",") {
                    index += 1
                    expect = .objectKey
                } else if byte == UInt8(ascii: "}") {
                    stack.removeLast()
                    index += 1
                    afterValue()
                } else {
                    return .malformed
                }
            case .done:
                return .malformed
            }
        }
    }

    /// The index just past a string starting at `start` (a quotation mark),
    /// or `nil` when it breaks the grammar: an unescaped control character,
    /// an unknown escape, a short `\u` escape, or no closing quotation mark.
    private static func stringEnd(_ bytes: [UInt8], from start: Int) -> Int? {
        var index = start + 1
        while index < bytes.count {
            let byte = bytes[index]
            if byte == UInt8(ascii: "\"") { return index + 1 }
            if byte < 0x20 { return nil }
            if byte == UInt8(ascii: "\\") {
                guard index + 1 < bytes.count else { return nil }
                switch bytes[index + 1] {
                case UInt8(ascii: "\""), UInt8(ascii: "\\"), UInt8(ascii: "/"), UInt8(ascii: "b"), UInt8(ascii: "f"),
                     UInt8(ascii: "n"), UInt8(ascii: "r"), UInt8(ascii: "t"):
                    index += 2
                case UInt8(ascii: "u"):
                    guard index + 5 < bytes.count,
                          bytes[(index + 2)...(index + 5)].allSatisfy(isHexDigit) else { return nil }
                    index += 6
                default:
                    return nil
                }
                continue
            }
            index += 1
        }
        return nil
    }

    /// `-? (0 | [1-9][0-9]*) (\.[0-9]+)? ([eE][+-]?[0-9]+)?`
    private static func numberEnd(_ bytes: [UInt8], from start: Int) -> Int? {
        var index = start
        func digits() -> Int {
            let first = index
            while index < bytes.count, isDigit(bytes[index]) { index += 1 }
            return index - first
        }
        if bytes[index] == UInt8(ascii: "-") { index += 1 }
        guard index < bytes.count else { return nil }
        if bytes[index] == UInt8(ascii: "0") {
            index += 1
        } else {
            guard digits() > 0 else { return nil }
        }
        if index < bytes.count, bytes[index] == UInt8(ascii: ".") {
            index += 1
            guard digits() > 0 else { return nil }
        }
        if index < bytes.count, bytes[index] == UInt8(ascii: "e") || bytes[index] == UInt8(ascii: "E") {
            index += 1
            if index < bytes.count, bytes[index] == UInt8(ascii: "+") || bytes[index] == UInt8(ascii: "-") { index += 1 }
            guard digits() > 0 else { return nil }
        }
        return index
    }

    private static func literalEnd(_ bytes: [UInt8], from start: Int) -> Int? {
        for literal in ["true", "false", "null"] {
            let pattern = Array(literal.utf8)
            if bytes.count - start >= pattern.count, Array(bytes[start..<(start + pattern.count)]) == pattern {
                return start + pattern.count
            }
        }
        return nil
    }

    private static func isDigit(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
    }

    private static func isHexDigit(_ byte: UInt8) -> Bool {
        isDigit(byte) || (UInt8(ascii: "a")...UInt8(ascii: "f")).contains(byte)
            || (UInt8(ascii: "A")...UInt8(ascii: "F")).contains(byte)
    }
}
