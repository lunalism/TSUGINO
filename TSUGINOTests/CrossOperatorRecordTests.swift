import Foundation
import Testing
@testable import TSUGINO

/// DEC-069 §C–§D reviewed cross-operator records and station assignments, on
/// invented values only: sources `SYN-…`, stops `syn-…`, digests repeating one
/// hexadecimal digit.
struct CrossOperatorRecordTests {

    private static let inputA = String(repeating: "c", count: 64)
    private static let inputB = String(repeating: "e", count: 64)
    private static let member = String(repeating: "d", count: 64)
    private static let evidence = String(repeating: "f", count: 64)

    private static func stop(_ id: String, input: String) throws -> SourceReference {
        try SourceReference(inputSHA256: input, member: .init(name: "stops.txt", sha256: member), table: "stops",
                            recordIndex: nil, field: "stop_id", providerKey: ExactValue(id)!)
    }

    private static func side(_ source: String, _ stops: [String]) throws -> CrossOperatorSide {
        let input = source.hasPrefix("SYN-01") ? inputA : inputB
        return try CrossOperatorSide(sourceID: source, inputSHA256: input, members: try stops.map { try stop($0, input: input) })
    }

    private static func record(
        _ reviewID: String = "SYN-REVIEW-X1", a: [String] = ["syn-a1"], b: [String] = ["syn-b1"],
        outcome: CrossOperatorOutcome = .same, rules: [StationAliasRule] = [], provenance: [CrossOperatorEvidenceProvenance] = []
    ) throws -> ReviewedCrossOperatorRecord {
        try ReviewedCrossOperatorRecord(
            reviewID: reviewID, sides: [try side("SYN-02/b", b), try side("SYN-01/a", a)], evidenceSHA256: evidence,
            outcome: outcome, reason: "Synthetic reason", citedAliasRules: rules, evidenceProvenance: provenance
        )
    }

    @Test func sidesAreOrderedBySourceAndMustBeTwoOperators() throws {
        let record = try Self.record()
        #expect(record.sides.map(\.sourceID) == ["SYN-01/a", "SYN-02/b"])
        #expect(throws: ReviewedCrossOperatorRecord.Invalid.sidesFromOneSource) {
            try ReviewedCrossOperatorRecord(reviewID: "SYN-REVIEW-X1", sides: [try Self.side("SYN-01/a", ["syn-a1"]), try Self.side("SYN-01/a", ["syn-a2"])],
                                            evidenceSHA256: Self.evidence, outcome: .distinct, reason: "Synthetic")
        }
        #expect(throws: ReviewedCrossOperatorRecord.Invalid.notTwoSides) {
            try ReviewedCrossOperatorRecord(reviewID: "SYN-REVIEW-X1", sides: [try Self.side("SYN-01/a", ["syn-a1"])],
                                            evidenceSHA256: Self.evidence, outcome: .distinct, reason: "Synthetic")
        }
    }

    @Test func aSideHoldsOnlyStopRowsOfItsOwnInput() throws {
        #expect(throws: CrossOperatorSide.Invalid.memberOutsideInput) {
            try CrossOperatorSide(sourceID: "SYN-01/a", inputSHA256: Self.inputA, members: [try Self.stop("syn-a1", input: Self.inputB)])
        }
        #expect(throws: CrossOperatorSide.Invalid.repeatedMember) {
            try CrossOperatorSide(sourceID: "SYN-01/a", inputSHA256: Self.inputA, members: [try Self.stop("syn-a1", input: Self.inputA), try Self.stop("syn-a1", input: Self.inputA)])
        }
        #expect(throws: CrossOperatorSide.Invalid.noMembers) { try CrossOperatorSide(sourceID: "SYN-01/a", inputSHA256: Self.inputA, members: []) }
    }

    /// An alias rule can only support a merge; reasons are project text.
    @Test func aliasCitationsBelongToSameRecordsOnly() throws {
        #expect(try Self.record(rules: [.orthographicKe]).citedAliasRules == [.orthographicKe])
        for outcome in [CrossOperatorOutcome.distinct, .ambiguous] {
            #expect(throws: ReviewedCrossOperatorRecord.Invalid.aliasCitationWithoutSame) { try Self.record(outcome: outcome, rules: [.subtitleBracket]) }
        }
        #expect(throws: ReviewedCrossOperatorRecord.Invalid.repeatedAliasRule) { try Self.record(rules: [.orthographicKe, .orthographicKe]) }
        #expect(throws: ReviewedCrossOperatorRecord.Invalid.malformedReason) {
            try ReviewedCrossOperatorRecord(reviewID: "SYN-REVIEW-X1", sides: [try Self.side("SYN-01/a", ["syn-a1"]), try Self.side("SYN-02/b", ["syn-b1"])],
                                            evidenceSHA256: Self.evidence, outcome: .same, reason: "合成")
        }
    }

    @Test func evidenceProvenanceIsAnEvidenceItemOrAnExternalReference() {
        #expect(CrossOperatorEvidenceProvenance("evidence:stationCodes") == .evidence(.stationCodes))
        #expect(CrossOperatorEvidenceProvenance("external:SYN-SOURCE-1") == .external("SYN-SOURCE-1"))
        // No distance item exists; an external reference needs text without spaces.
        for text in ["evidence:distance", "external:", "external:with space", "stationCodes"] {
            #expect(CrossOperatorEvidenceProvenance(text) == nil, "\(text)")
        }
    }

    @Test func aSetRefusesRepeatedPairsOverlapsAndAnIdentityInTwoSameRecords() throws {
        #expect(throws: ReviewedCrossOperatorSet.Invalid.repeatedReviewID) {
            try ReviewedCrossOperatorSet([try Self.record(), try Self.record(b: ["syn-b2"])])
        }
        #expect(throws: ReviewedCrossOperatorSet.Invalid.repeatedPair) {
            try ReviewedCrossOperatorSet([try Self.record(), try Self.record("SYN-REVIEW-X2", outcome: .distinct)])
        }
        // A side naming part of another record's identity disagrees about it.
        #expect(throws: ReviewedCrossOperatorSet.Invalid.overlappingSides) {
            try ReviewedCrossOperatorSet([try Self.record(a: ["syn-a1", "syn-a2"]), try Self.record("SYN-REVIEW-X2", a: ["syn-a2"], b: ["syn-b2"], outcome: .distinct)])
        }
        #expect(throws: ReviewedCrossOperatorSet.Invalid.identityInTwoSame) {
            try ReviewedCrossOperatorSet([try Self.record(), try Self.record("SYN-REVIEW-X2", b: ["syn-b2"])])
        }
        // One identity may be `same` with one counterpart and `distinct` or
        // `ambiguous` with others.
        let set = try ReviewedCrossOperatorSet([
            try Self.record("SYN-REVIEW-X3"), try Self.record("SYN-REVIEW-X2", b: ["syn-b2"], outcome: .ambiguous),
        ])
        #expect(set.records.map(\.reviewID) == ["SYN-REVIEW-X2", "SYN-REVIEW-X3"])
    }

    @Test func stationAssignmentsNameOneOrTwoOperatorsAndEachStationOnce() throws {
        let station = MintedIdentifier("stn_0000000000000001")!, other = MintedIdentifier("stn_0000000000000002")!
        let joined = try ReviewedStationAssignment(reviewID: "SYN-REVIEW-S1", stationID: station,
                                                   sides: [try Self.side("SYN-02/b", ["syn-b1"]), try Self.side("SYN-01/a", ["syn-a1"])])
        #expect(joined.sides.map(\.sourceID) == ["SYN-01/a", "SYN-02/b"])
        #expect(throws: ReviewedStationAssignment.Invalid.notAStationIdentifier) {
            try ReviewedStationAssignment(reviewID: "SYN-REVIEW-S1", stationID: MintedIdentifier("lin_0000000000000001")!, sides: [try Self.side("SYN-01/a", ["syn-a1"])])
        }
        #expect(throws: ReviewedStationAssignment.Invalid.invalidSides) {
            try ReviewedStationAssignment(reviewID: "SYN-REVIEW-S1", stationID: station, sides: [try Self.side("SYN-01/a", ["syn-a1"]), try Self.side("SYN-01/a", ["syn-a2"])])
        }
        let alone = try ReviewedStationAssignment(reviewID: "SYN-REVIEW-S2", stationID: other, sides: [try Self.side("SYN-01/a", ["syn-a1"])])
        #expect(throws: ReviewedStationAssignmentSet.Invalid.memberInTwoAssignments) { try ReviewedStationAssignmentSet([joined, alone]) }
        let again = try ReviewedStationAssignment(reviewID: "SYN-REVIEW-S3", stationID: station, sides: [try Self.side("SYN-01/a", ["syn-a9"])])
        #expect(throws: ReviewedStationAssignmentSet.Invalid.stationInTwoAssignments) { try ReviewedStationAssignmentSet([joined, again]) }
    }
}
