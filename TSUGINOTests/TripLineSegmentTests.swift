import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for one line's span of a Trip traversal (DEC-060 C,
/// ARCHITECTURE.md §5.3). All identifiers are synthetic.
struct TripLineSegmentTests {

    private static func line(_ raw: String) throws -> LineID {
        try #require(LineID(raw))
    }

    private static func segment(_ raw: String, _ start: Int, _ end: Int) throws -> TripLineSegment {
        try #require(TripLineSegment(lineID: try Self.line(raw), startIndex: start, endIndex: end))
    }

    // MARK: - Construction

    @Test func constructionPreservesEveryField() throws {
        let lineID = try Self.line("ln-1")
        let subject = try #require(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: 3))

        #expect(subject.lineID == lineID)
        #expect(subject.startIndex == 0)
        #expect(subject.endIndex == 3)
    }

    /// The smallest valid span is one movement between two stops.
    @Test func minimalSpanOfOneMovementIsValid() throws {
        let subject = try Self.segment("ln-1", 0, 1)

        #expect(subject.endIndex == subject.startIndex + 1)
    }

    // MARK: - Rejection (never trapped)

    @Test(arguments: [-1, -2, Int.min])
    func negativeStartIndexIsRejected(start: Int) throws {
        #expect(TripLineSegment(lineID: try Self.line("ln-1"), startIndex: start, endIndex: 3) == nil)
    }

    @Test(arguments: [0, 3, Int.max])
    func equalBoundsAreRejected(index: Int) throws {
        #expect(TripLineSegment(lineID: try Self.line("ln-1"), startIndex: index, endIndex: index) == nil)
    }

    @Test(arguments: [(3, 0), (1, 0), (Int.max, Int.min), (0, -1)])
    func reversedBoundsAreRejected(sample: (Int, Int)) throws {
        #expect(
            TripLineSegment(lineID: try Self.line("ln-1"), startIndex: sample.0, endIndex: sample.1) == nil
        )
    }

    /// Extreme decoded integers are compared directly, so nothing overflows or
    /// forms an invalid range on the way to rejection.
    @Test func extremeBoundsAreHandledWithoutTrapping() throws {
        let lineID = try Self.line("ln-1")

        #expect(TripLineSegment(lineID: lineID, startIndex: Int.min, endIndex: Int.max) == nil)
        #expect(TripLineSegment(lineID: lineID, startIndex: 0, endIndex: Int.max) != nil)
    }

    // MARK: - Equality and hashing (complete value)

    @Test func equalityAndHashingUseEveryField() throws {
        let a = try Self.segment("ln-1", 0, 3)
        let sameAsA = try Self.segment("ln-1", 0, 3)
        let otherLine = try Self.segment("ln-2", 0, 3)
        let otherStart = try Self.segment("ln-1", 1, 3)
        let otherEnd = try Self.segment("ln-1", 0, 4)

        #expect(a == sameAsA)
        #expect(a.hashValue == sameAsA.hashValue)
        #expect(a != otherLine)
        #expect(a != otherStart)
        #expect(a != otherEnd)
        #expect(Set([a, sameAsA, otherLine, otherStart, otherEnd]).count == 4)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesEveryField() throws {
        let original = try Self.segment("ln-1", 2, 5)
        let decoded = try JSONDecoder().decode(
            TripLineSegment.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded.lineID == original.lineID)
        #expect(decoded.startIndex == original.startIndex)
        #expect(decoded.endIndex == original.endIndex)
        #expect(decoded == original)
    }

    @Test func encodedFormUsesExactlyTheThreeSegmentKeys() throws {
        let encoded = try JSONEncoder().encode(try Self.segment("ln-1", 0, 2))
        let object = try #require(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )

        #expect(Set(object.keys) == ["lineID", "startIndex", "endIndex"])
        #expect(object["lineID"] as? String == "ln-1")
        #expect(object["startIndex"] as? Int == 0)
        #expect(object["endIndex"] as? Int == 2)
    }

    @Test(arguments: [
        #"{"startIndex":0,"endIndex":2}"#,
        #"{"lineID":"ln-1","endIndex":2}"#,
        #"{"lineID":"ln-1","startIndex":0}"#,
    ])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TripLineSegment.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"lineID":1,"startIndex":0,"endIndex":2}"#,
        #"{"lineID":"ln-1","startIndex":"0","endIndex":2}"#,
        #"{"lineID":"ln-1","startIndex":0,"endIndex":[2]}"#,
    ])
    func wrongTypesFailAsTypeMismatch(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TripLineSegment.self, from: Data(payload.utf8))
        }

        guard case .typeMismatch? = error else {
            Issue.record("expected .typeMismatch, got \(String(describing: error))")
            return
        }
    }

    /// An invalid span, or a blank `LineID` (DEC-051), is `dataCorrupted`.
    @Test(arguments: [
        #"{"lineID":"ln-1","startIndex":-1,"endIndex":2}"#,
        #"{"lineID":"ln-1","startIndex":2,"endIndex":2}"#,
        #"{"lineID":"ln-1","startIndex":5,"endIndex":2}"#,
        #"{"lineID":"","startIndex":0,"endIndex":2}"#,
        #"{"lineID":" ","startIndex":0,"endIndex":2}"#,
    ])
    func invalidPayloadsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TripLineSegment.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [#""ln-1""#, "[]", "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TripLineSegment.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func segmentsCrossActorBoundaries() async throws {
        let subject = try Self.segment("ln-1", 1, 4)
        let received = await Task.detached { subject }.value

        #expect(received == subject)
        #expect(received.lineID == subject.lineID)
        #expect(received.startIndex == 1)
        #expect(received.endIndex == 4)
    }
}
