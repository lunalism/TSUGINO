import Foundation

// Reviewed grouping records (DEC-068 §D2): the only way stop rows of one
// operator become one operator-level identity.
//
// The importer only proposes. A grouping takes effect when a reviewed record
// names every member's source reference, the evidence reviewed (as the
// SHA-256 digest of the proposal's evidence), and the reviewer's decision.
// Accepting a grouping whose evidence failed a check needs an exception, and
// an exception belongs to its one record: it waives exactly the named checks
// for exactly these members, and never becomes a general rule.
//
// Proposals, evidence, and applying records are tool-only
// (ARCHITECTURE.md §4.1). These types hold no provider dataset: records are
// written by a reviewer for a real input, kept outside the repository until
// the registry-of-record decision (DEC-068 §F), and invented in tests.

/// The structural checks a grouping proposal must pass (DEC-068 §D2). Equal
/// names are listed with the evidence as a hint; they are never a check that
/// can pass.
nonisolated enum GroupingCheck: String, CaseIterable, Hashable, Comparable, Sendable {
    /// Every member is served by at least one route, and only by routes of
    /// one operator. This is a boundary, not evidence: rows of different
    /// operators, or rows whose operator is not established, are never
    /// grouped (DEC-068 §D5), so no exception can waive it.
    case oneOperator
    /// No two members share a route.
    case noSharedRoute
    /// Each member has a code, and the code fits every route that serves it.
    case codeConsistency
    /// Each member appears in a stop sequence of every route that serves it,
    /// with at least one neighbouring stop.
    case neighborContext
    /// Each member's original Japanese and English values are present, to be
    /// listed side by side — as hints, never as proof.
    case nameEvidence
    /// The candidate was found through uniform name signals: no member is
    /// linked to it only by some of its name values.
    case noCompetingCandidate

    /// Whether a reviewed exception may waive this check: every evidence
    /// check may be, the operator boundary may not.
    var isWaivable: Bool { self != .oneOperator }

    static func < (lhs: GroupingCheck, rhs: GroupingCheck) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

/// A reviewed exception for one grouping: the checks it waives and why.
nonisolated struct GroupingException: Hashable, Sendable {
    /// Printable ASCII, spaces allowed, not blank. Project text.
    let reason: String
    /// Sorted, non-empty, no repeats.
    let waivedChecks: [GroupingCheck]

    enum Invalid: Error, Hashable, Sendable {
        case malformedReason
        case invalidWaivedChecks
        /// The operator boundary can never be waived.
        case nonWaivableCheck
    }

    init(reason: String, waivedChecks: [GroupingCheck]) throws(Invalid) {
        let bytes = Array(reason.utf8)
        guard bytes.contains(where: { $0 != 0x20 }), bytes.allSatisfy({ (0x20...0x7E).contains($0) }) else {
            throw .malformedReason
        }
        guard !waivedChecks.isEmpty, Set(waivedChecks).count == waivedChecks.count else { throw .invalidWaivedChecks }
        guard waivedChecks.allSatisfy(\.isWaivable) else { throw .nonWaivableCheck }
        self.reason = reason
        self.waivedChecks = waivedChecks.sorted()
    }
}

nonisolated enum GroupingDecision: Hashable, Sendable {
    /// The members become one operator-level identity. `exception` is present
    /// exactly when the evidence failed a check.
    case accepted(exception: GroupingException?)
    /// The members stay separate identities.
    case rejected
}

/// A reviewer's record for one candidate grouping (DEC-068 §D2).
nonisolated struct ReviewedGroupingRecord: Hashable, Sendable {
    /// Printable ASCII: the reviewed record's own identifier.
    let reviewID: String
    let sourceID: String
    /// The identified input (the archive) the record applies to.
    let inputSHA256: String
    /// The members' `stops` rows, sorted by stop identifier.
    let members: [SourceReference]
    /// The digest of the proposal evidence the reviewer saw. If the evidence
    /// changes, the record no longer applies.
    let evidenceSHA256: String
    let decision: GroupingDecision

    enum Invalid: Error, Hashable, Sendable {
        case malformedReviewID
        case malformedSourceID
        case malformedDigest
        case tooFewMembers
        case repeatedMember
        /// A member that is not a `stops.stop_id` row of the one GTFS member
        /// of this record's input.
        case memberOutsideInput
    }

    init(
        reviewID: String,
        sourceID: String,
        inputSHA256: String,
        members: [SourceReference],
        evidenceSHA256: String,
        decision: GroupingDecision
    ) throws(Invalid) {
        guard MappingText.isToken(reviewID) else { throw .malformedReviewID }
        guard MappingText.isToken(sourceID) else { throw .malformedSourceID }
        guard MappingText.isSHA256(inputSHA256), MappingText.isSHA256(evidenceSHA256) else { throw .malformedDigest }
        guard members.count >= 2 else { throw .tooFewMembers }
        guard Set(members.map(\.providerKey)).count == members.count else { throw .repeatedMember }
        let member = members[0].member
        for reference in members {
            guard reference.inputSHA256 == inputSHA256,
                  reference.member != nil, reference.member == member,
                  reference.table == "stops", reference.field == "stop_id"
            else { throw .memberOutsideInput }
        }
        self.reviewID = reviewID
        self.sourceID = sourceID
        self.inputSHA256 = inputSHA256
        self.members = members.sorted { $0.providerKey < $1.providerKey }
        self.evidenceSHA256 = evidenceSHA256
        self.decision = decision
    }
}

/// The reviewed records for one run: each review identifier once, and no
/// stop row in two records.
nonisolated struct ReviewedGroupingSet: Hashable, Sendable {
    /// Sorted by review identifier.
    let records: [ReviewedGroupingRecord]

    enum Invalid: Error, Hashable, Sendable {
        case repeatedReviewID
        case memberInTwoRecords
    }

    init(_ records: [ReviewedGroupingRecord]) throws(Invalid) {
        struct Row: Hashable {
            let sourceID: String
            let inputSHA256: String
            let stopID: ExactValue
        }
        guard Set(records.map(\.reviewID)).count == records.count else { throw .repeatedReviewID }
        var seen = Set<Row>()
        for record in records {
            for member in record.members {
                let row = Row(sourceID: record.sourceID, inputSHA256: record.inputSHA256, stopID: member.providerKey)
                guard seen.insert(row).inserted else { throw .memberInTwoRecords }
            }
        }
        self.records = records.sorted { $0.reviewID.utf8.lexicographicallyPrecedes($1.reviewID.utf8) }
    }

    static let empty = try! ReviewedGroupingSet([])
}
