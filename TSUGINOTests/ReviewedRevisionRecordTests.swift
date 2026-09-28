import Foundation
import Testing
@testable import TSUGINO

/// DEC-068 §E reviewed revision records, on invented values only: sources
/// are `SYN-…`, stops `syn-…`, identifiers repeat one digit, and digests
/// repeat one hexadecimal digit.
struct ReviewedRevisionRecordTests {

    private static let input = String(repeating: "b", count: 64)
    private static let station = MintedIdentifier("stn_0000000000000001")!

    private static func key(_ value: String, _ namespace: ProviderNamespace = .gtfsStopID, source: String = "SYN-01/synthetic-gtfs") -> ProviderReferenceKey {
        ProviderReferenceKey(sourceID: source, namespace: namespace, value: ExactValue(value)!)
    }

    private static func record(
        _ reviewID: String = "SYN-REVIEW-A1",
        key: ProviderReferenceKey = key("syn-s1x"),
        input: String = input,
        action: ReviewedRevisionRecord.Action = .attach(to: station)
    ) throws -> ReviewedRevisionRecord {
        try ReviewedRevisionRecord(reviewID: reviewID, key: key, inputSHA256: input, action: action)
    }

    @Test func aRecordNamesOneReferenceInOneInput() throws {
        let record = try Self.record()
        #expect(record.action == .attach(to: Self.station))
        #expect(record.key.value.text == "syn-s1x")
        #expect(try Self.record(action: .retire).action == .retire)
    }

    /// An attachment names an identity of the kind its namespace identifies.
    @Test func anAttachmentMatchesTheNamespacesKind() throws {
        #expect(throws: ReviewedRevisionRecord.Invalid.kindMismatch) {
            try Self.record(action: .attach(to: MintedIdentifier("lin_0000000000000001")!))
        }
        #expect(throws: ReviewedRevisionRecord.Invalid.kindMismatch) {
            try Self.record(key: Self.key("syn-route", .gtfsRouteID))
        }
    }

    @Test func projectTextAndDigestsAreChecked() throws {
        #expect(throws: ReviewedRevisionRecord.Invalid.malformedReviewID) { try Self.record("SYN REVIEW") }
        #expect(throws: ReviewedRevisionRecord.Invalid.malformedSourceID) { try Self.record(key: Self.key("syn-s1x", source: "SYN 01")) }
        #expect(throws: ReviewedRevisionRecord.Invalid.malformedDigest) { try Self.record(input: "b") }
    }

    @Test func aSetHoldsEachReviewAndEachReferenceOnce() throws {
        let attach = try Self.record()
        let retire = try Self.record("SYN-REVIEW-R1", key: Self.key("syn-s2"), action: .retire)
        #expect(try ReviewedRevisionSet([retire, attach]).records.map(\.reviewID) == ["SYN-REVIEW-A1", "SYN-REVIEW-R1"])
        #expect(throws: ReviewedRevisionSet.Invalid.repeatedReviewID) {
            try ReviewedRevisionSet([attach, try Self.record(key: Self.key("syn-s2"), action: .retire)])
        }
        #expect(throws: ReviewedRevisionSet.Invalid.referenceInTwoRecords) {
            try ReviewedRevisionSet([attach, try Self.record("SYN-REVIEW-R2", action: .retire)])
        }
    }
}
