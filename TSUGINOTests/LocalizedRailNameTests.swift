import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the shared canonical name value (DEC-053,
/// ARCHITECTURE.md §39.1).
struct LocalizedRailNameTests {

    private static func valid(
        japanese: String = "東京都交通局",
        english: String = "Toei",
        korean: String = "도영"
    ) throws -> LocalizedRailName {
        try #require(LocalizedRailName(japanese: japanese, english: english, korean: korean))
    }

    // MARK: - Construction and preservation

    @Test func validThreeLanguageNameIsAccepted() throws {
        let name = try Self.valid()

        #expect(name.japanese == "東京都交通局")
        #expect(name.english == "Toei")
        #expect(name.korean == "도영")
    }

    @Test(arguments: [
        ("東京メトロ", "Tokyo Metro", "도쿄메트로"),
        ("  前後空白  ", "  padded  ", "  여백  "),
        ("\t탭\n", "\tTab\n", "\t탭\n"),
        ("駅-001", "Station/001#a", "역-001"),
        ("ＭＩＸ半角全角", "MiXeD CaSe", "MiXeD 한글"),
    ])
    func validValuesArePreservedExactly(sample: (String, String, String)) throws {
        let name = try Self.valid(japanese: sample.0, english: sample.1, korean: sample.2)

        #expect(name.japanese == sample.0)
        #expect(name.english == sample.1)
        #expect(name.korean == sample.2)
    }

    @Test func identicalTranslationsAreAllowed() throws {
        let name = try Self.valid(japanese: "TX", english: "TX", korean: "TX")

        #expect(name.japanese == name.english)
        #expect(name.english == name.korean)
    }

    // MARK: - Blank rejection, per field

    @Test(arguments: ["", " ", "\t", "\n", "\t \n", "\u{00A0}", "\u{3000}"])
    func blankJapaneseIsRejected(blank: String) {
        #expect(LocalizedRailName(japanese: blank, english: "Toei", korean: "도영") == nil)
    }

    @Test(arguments: ["", " ", "\t", "\n", "\t \n", "\u{00A0}", "\u{3000}"])
    func blankEnglishIsRejected(blank: String) {
        #expect(LocalizedRailName(japanese: "東京都交通局", english: blank, korean: "도영") == nil)
    }

    @Test(arguments: ["", " ", "\t", "\n", "\t \n", "\u{00A0}", "\u{3000}"])
    func blankKoreanIsRejected(blank: String) {
        #expect(LocalizedRailName(japanese: "東京都交通局", english: "Toei", korean: blank) == nil)
    }

    @Test func allThreeBlankIsRejected() {
        #expect(LocalizedRailName(japanese: "", english: " ", korean: "\n") == nil)
    }

    // MARK: - Equality and hashing

    @Test func equalityAndHashingUseAllThreeNames() throws {
        let a = try Self.valid()
        let sameAsA = try Self.valid()
        let differentKorean = try Self.valid(korean: "도에이")

        #expect(a == sameAsA)
        #expect(a != differentKorean)
        #expect(Set([a, sameAsA, differentKorean]).count == 2)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = try Self.valid(japanese: " 日本語 ", english: " English ", korean: " 한국어 ")
        let decoded = try JSONDecoder().decode(
            LocalizedRailName.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded.japanese == " 日本語 ")
        #expect(decoded.english == " English ")
        #expect(decoded.korean == " 한국어 ")
        #expect(decoded == original)
    }

    @Test(arguments: [
        #"{"japanese":"","english":"Toei","korean":"도영"}"#,
        #"{"japanese":"東京都交通局","english":"  ","korean":"도영"}"#,
        #"{"japanese":"東京都交通局","english":"Toei","korean":"\t\n"}"#,
    ])
    func blankPayloadsFailAsDataCorrupted(payload: String) throws {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(LocalizedRailName.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"japanese":"東京都交通局","english":"Toei"}"#,     // missing korean
        #"{"japanese":1,"english":"Toei","korean":"도영"}"#,  // wrong type
        #""just a string""#,
        "[]",
        "null",
    ])
    func malformedPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(LocalizedRailName.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func namesCrossActorBoundaries() async throws {
        let name = try Self.valid()
        let received = await Task.detached { name }.value

        #expect(received == name)
    }
}
