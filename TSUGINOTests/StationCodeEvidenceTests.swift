import Foundation
import Testing
@testable import TSUGINO

struct StationCodeEvidenceTests {
    private func value(_ s:String) -> ExactValue { ExactValue(s)! }
    private func row(_ code:String, index:Int = 0, date:String = "2099-01-01") -> StationCodeEvidence.Row {
        .init(id:value("urn:invented:record"),sameAs:value("urn:invented:station"),operatorReference:value("invented:operator"),
              railway:value("invented:railway"),code:value(code),recordIndex:index,date:value(date))
    }
    @Test func scalarExactCodesAndReferencesSurviveEncoding() throws {
        let a = row("é"), b = row("e\u{301}")
        #expect(a != b)
        #expect(Set([a,b]).count == 2)
        #expect(try JSONDecoder().decode([StationCodeEvidence.Row].self,from:JSONEncoder().encode([a,b])) == [a,b])
    }
    @Test func sightingsDoNotChangeSemanticProof() {
        let a = row("SYN-01"), b = row("SYN-01",index:8,date:"2099-02-01")
        #expect(a != b)
        #expect(a.semantic == b.semantic)
        #expect(a.semantic != row("SYN-02").semantic)
    }
    @Test func legacyEvidenceOmitsNewProof() throws {
        let source = EditorialStationKey(sourceID:value("invented:source"),stationReference:value("invented:station"))
        let old = TitleEvidence(source:source,occurrences:[],candidates:[],crosswalks:[],inputSHA256:[],registrySHA256:String(repeating:"a",count:64))
        let data = try JSONEncoder().encode(old)
        #expect(try JSONSerialization.jsonObject(with:data) as? [String:Any] != nil)
        #expect(!(String(decoding:data,as:UTF8.self).contains("stationCodes")))
        #expect(try JSONDecoder().decode(TitleEvidence.self,from:data) == old)
    }
}
