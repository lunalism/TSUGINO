import Foundation
import Testing
@testable import TSUGINO

/// DEC-069 §B alias rules as comparison keys, on invented values only.
struct StationAliasRuleTests {

    private static func name(_ value: String, stop: String) throws -> OriginalName {
        let source = try SourceReference(
            inputSHA256: String(repeating: "c", count: 64), member: .init(name: "stops.txt", sha256: String(repeating: "d", count: 64)),
            table: "stops", recordIndex: nil, field: "stop_name", providerKey: ExactValue(stop)!
        )
        return OriginalName(language: ExactValue("ja")!, value: ExactValue(value)!, source: source)
    }

    @Test func theOrthographicRuleFoldsOnlySmallAndFullSizeKe() {
        let rule = StationAliasRule.orthographicKe
        #expect(rule.relates(ExactValue("合成ヶ丘")!, ExactValue("合成ケ丘")!))
        // Not ヵ (U+30F5), not the half-width ｹ, and not an unrelated character.
        #expect(!rule.relates(ExactValue("合成ヵ丘")!, ExactValue("合成ケ丘")!))
        #expect(!rule.relates(ExactValue("合成ｹ丘")!, ExactValue("合成ケ丘")!))
        #expect(!rule.relates(ExactValue("合成コ丘")!, ExactValue("合成ケ丘")!))
        // Equal values need no alias.
        #expect(!rule.relates(ExactValue("合成ケ丘")!, ExactValue("合成ケ丘")!))
    }

    @Test func theSubtitleRuleDropsOnlyOneTrailingBracketedSubtitle() {
        let rule = StationAliasRule.subtitleBracket
        #expect(rule.relates(ExactValue("合成台")!, ExactValue("合成台〈合成前〉")!))
        #expect(rule.comparisonKey(ExactValue("合成台〈合成前〉")!).text == "合成台")
        // Not trailing, empty, nested, or the whole value.
        for value in ["合成〈合成前〉台", "合成台〈〉", "合成台〈合〈成〉〉", "〈合成前〉"] {
            #expect(rule.comparisonKey(ExactValue(value)!).text == value, "\(value)")
        }
        // Other brackets are not the subtitle bracket.
        #expect(!rule.relates(ExactValue("合成台")!, ExactValue("合成台(合成前)")!))
    }

    /// Keys compare scalar by scalar: a decomposed spelling is not its
    /// composed form, and no normalization happens.
    @Test func keysKeepExactScalars() {
        let composed = ExactValue("合成ガ")!, decomposed = ExactValue("合成カ\u{3099}")!
        for rule in StationAliasRule.allCases {
            #expect(!rule.relates(composed, decomposed), "\(rule)")
            #expect(rule.comparisonKey(decomposed).text.unicodeScalars.map(\.value).suffix(2) == [0x30AB, 0x3099])
        }
    }

    @Test func aMatchKeepsBothOriginalsWithTheirSources() throws {
        let small = try Self.name("合成ヶ丘", stop: "syn-a-ke"), full = try Self.name("合成ケ丘", stop: "syn-b-ke")
        let match = try StationAliasMatch(rule: .orthographicKe, full, small)
        #expect(match.originals.map(\.value.text) == ["合成ケ丘", "合成ヶ丘"].sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) })
        #expect(Set(match.originals.map(\.source.providerKey.text)) == ["syn-a-ke", "syn-b-ke"])
        #expect(match.comparisonKey.text == "合成ケ丘")
        // The same match whichever side comes first.
        #expect(try StationAliasMatch(rule: .orthographicKe, small, full) == match)
        #expect(throws: StationAliasMatch.Invalid.notRelated) { try StationAliasMatch(rule: .subtitleBracket, small, full) }
    }
}
