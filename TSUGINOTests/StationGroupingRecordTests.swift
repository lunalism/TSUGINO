import Foundation
import Testing
@testable import TSUGINO

/// DEC-068 §D2 reviewed grouping and exception records, on invented values
/// only: sources are `SYN-…`, stops `syn-…`, and digests repeat one
/// hexadecimal digit.
struct StationGroupingRecordTests {

    private static let input = String(repeating: "c", count: 64)
    private static let otherInput = String(repeating: "e", count: 64)
    private static let member = String(repeating: "d", count: 64)
    private static let evidence = String(repeating: "f", count: 64)

    private static func stop(_ id: String, input: String = input, member: String = member, table: String = "stops", field: String = "stop_id") throws -> SourceReference {
        try SourceReference(
            inputSHA256: input, member: .init(name: "stops.txt", sha256: member),
            table: table, recordIndex: nil, field: field, providerKey: ExactValue(id)!
        )
    }

    private static func record(
        _ reviewID: String = "SYN-REVIEW-G1",
        members: [SourceReference]? = nil,
        decision: GroupingDecision = .accepted(exception: nil)
    ) throws -> ReviewedGroupingRecord {
        try ReviewedGroupingRecord(
            reviewID: reviewID, sourceID: "SYN-01/synthetic-gtfs", inputSHA256: input,
            members: try members ?? [try stop("syn-r2"), try stop("syn-q2")],
            evidenceSHA256: evidence, decision: decision
        )
    }

    @Test func membersAreSortedAndTheRecordKeepsItsDecision() throws {
        let record = try Self.record()
        #expect(record.members.map(\.providerKey.text) == ["syn-q2", "syn-r2"])
        #expect(record.decision == .accepted(exception: nil))
    }

    @Test func aRecordNeedsTwoDistinctMembers() throws {
        #expect(throws: ReviewedGroupingRecord.Invalid.tooFewMembers) { try Self.record(members: [try Self.stop("syn-q2")]) }
        #expect(throws: ReviewedGroupingRecord.Invalid.repeatedMember) {
            try Self.record(members: [try Self.stop("syn-q2"), try Self.stop("syn-q2")])
        }
    }

    /// Every member is a `stops.stop_id` row of the record's one input and
    /// one `stops.txt` member.
    @Test func membersMustComeFromTheRecordsInput() throws {
        let railway = try SourceReference(inputSHA256: Self.input, member: nil, table: nil, recordIndex: 0, field: "@id", providerKey: ExactValue("syn:R")!)
        let outside: [SourceReference] = [
            try Self.stop("syn-r2", input: Self.otherInput),
            try Self.stop("syn-r2", member: Self.otherInput),
            try Self.stop("syn-r2", table: "routes"),
            try Self.stop("syn-r2", field: "stop_code"),
            railway,
        ]
        for member in outside {
            #expect(throws: ReviewedGroupingRecord.Invalid.memberOutsideInput) {
                try Self.record(members: [try Self.stop("syn-q2"), member])
            }
        }
    }

    @Test func identifiersAndDigestsAreChecked() {
        #expect(throws: ReviewedGroupingRecord.Invalid.malformedReviewID) { try Self.record("SYN REVIEW") }
        #expect(throws: ReviewedGroupingRecord.Invalid.malformedReviewID) { try Self.record("") }
        #expect(throws: ReviewedGroupingRecord.Invalid.malformedSourceID) {
            try ReviewedGroupingRecord(
                reviewID: "SYN-REVIEW-G1", sourceID: "SYN 01", inputSHA256: Self.input,
                members: [try Self.stop("syn-q2"), try Self.stop("syn-r2")], evidenceSHA256: Self.evidence, decision: .rejected
            )
        }
        #expect(throws: ReviewedGroupingRecord.Invalid.malformedDigest) {
            try ReviewedGroupingRecord(
                reviewID: "SYN-REVIEW-G1", sourceID: "SYN-01/synthetic-gtfs", inputSHA256: Self.input,
                members: [try Self.stop("syn-q2"), try Self.stop("syn-r2")], evidenceSHA256: "syn-evidence", decision: .rejected
            )
        }
    }

    @Test func anExceptionNamesTheChecksItWaivesAndWhy() throws {
        let exception = try GroupingException(reason: "Synthetic reviewed exception", waivedChecks: [.neighborContext, .codeConsistency])
        #expect(exception.waivedChecks == [.codeConsistency, .neighborContext])
        #expect(throws: GroupingException.Invalid.invalidWaivedChecks) { try GroupingException(reason: "Synthetic", waivedChecks: []) }
        #expect(throws: GroupingException.Invalid.invalidWaivedChecks) {
            try GroupingException(reason: "Synthetic", waivedChecks: [.codeConsistency, .codeConsistency])
        }
        for reason in ["", "   ", "合成", "Synthetic\nreason"] {
            #expect(throws: GroupingException.Invalid.malformedReason) {
                try GroupingException(reason: reason, waivedChecks: [.codeConsistency])
            }
        }
    }

    /// Rows of different operators are never grouped (DEC-068 §D5), so the
    /// operator check is a boundary no exception can waive.
    @Test func theOperatorBoundaryIsNotWaivable() {
        #expect(GroupingCheck.allCases.filter { !$0.isWaivable } == [.oneOperator])
        #expect(throws: GroupingException.Invalid.nonWaivableCheck) {
            try GroupingException(reason: "Synthetic", waivedChecks: [.oneOperator])
        }
        #expect(throws: GroupingException.Invalid.nonWaivableCheck) {
            try GroupingException(reason: "Synthetic", waivedChecks: [.codeConsistency, .oneOperator])
        }
    }

    @Test func aSetHoldsEachReviewOnceAndEachRowInOneRecord() throws {
        let first = try Self.record("SYN-REVIEW-G2")
        let second = try Self.record("SYN-REVIEW-G1", members: [try Self.stop("syn-q5"), try Self.stop("syn-r5")])
        #expect(try ReviewedGroupingSet([first, second]).records.map(\.reviewID) == ["SYN-REVIEW-G1", "SYN-REVIEW-G2"])
        #expect(throws: ReviewedGroupingSet.Invalid.repeatedReviewID) { try ReviewedGroupingSet([first, first]) }
        let overlapping = try Self.record("SYN-REVIEW-G3", members: [try Self.stop("syn-q2"), try Self.stop("syn-x9")])
        #expect(throws: ReviewedGroupingSet.Invalid.memberInTwoRecords) { try ReviewedGroupingSet([first, overlapping]) }
    }

    @Test func checksHaveAFixedOrder() {
        #expect(GroupingCheck.allCases.sorted() == [.oneOperator, .noSharedRoute, .codeConsistency, .neighborContext, .nameEvidence, .noCompetingCandidate])
    }
}
