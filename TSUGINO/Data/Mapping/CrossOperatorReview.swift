import Foundation

// Reviewed cross-operator records (DEC-069 §C): the only way two operators'
// station identities become one canonical station, and the only place an
// ambiguous relationship is recorded.
//
// The importer only proposes candidates, from names and the two alias rules.
// A reviewer decides each one: `same`, `distinct`, or `ambiguous`. A record
// names both operator-level identities by their members' source references,
// the digest of the evidence the reviewer saw, the outcome, and a reason.
//
// `ambiguous` keeps two canonical stations. It is kept only in the reviewed
// record set, outside the repository: the registry gains no relationship,
// link, parent, or alias, and no transfer edge exists (DEC-069 §D3).
//
// Candidates, evidence, and applying records are tool-only
// (ARCHITECTURE.md §4.1). These types hold no provider dataset: records are
// written by a reviewer for real inputs, kept outside the repository until
// the registry-of-record decision (DEC-068 §F), and invented in tests.

nonisolated enum CrossOperatorOutcome: String, CaseIterable, Hashable, Sendable {
    /// One canonical station: needs converging structural evidence (Rule 53).
    case same
    /// Two canonical stations, on positive conflicting evidence.
    case distinct
    /// Two canonical stations: the evidence justifies neither `same` nor
    /// `distinct`. No relationship is recorded in the registry.
    case ambiguous
}

/// The evidence items a reviewer may name as the basis of a decision. They are
/// the parts of the digested evidence bundle (DEC-048 rule 3).
nonisolated enum CrossOperatorEvidenceItem: String, CaseIterable, Hashable, Comparable, Sendable {
    case providerIdentifiers
    case stationCodes
    case lineMembership
    case adjacentStations
    case multiLineOccurrence
    case originalNames
    case coordinates
    case otherCandidates

    static func < (lhs: Self, rhs: Self) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

/// Where a decision's evidence comes from: an item of the digested bundle,
/// or an external authoritative source named by a reference.
nonisolated enum CrossOperatorEvidenceProvenance: Hashable, Comparable, Sendable {
    case evidence(CrossOperatorEvidenceItem)
    /// Printable ASCII without spaces: a citation the reviewer can follow.
    case external(String)

    /// `evidence:<item>` or `external:<reference>`.
    init?(_ text: String) {
        if text.hasPrefix("evidence:"), let item = CrossOperatorEvidenceItem(rawValue: String(text.dropFirst(9))) {
            self = .evidence(item)
        } else if text.hasPrefix("external:"), text.count > 9, MappingText.isToken(text) {
            self = .external(String(text.dropFirst(9)))
        } else {
            return nil
        }
    }

    var text: String {
        switch self {
        case .evidence(let item): "evidence:\(item.rawValue)"
        case .external(let reference): "external:\(reference)"
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.text.utf8.lexicographicallyPrecedes(rhs.text.utf8) }
}

/// One operator-level identity, as a reviewed record names it: its source,
/// its identified input, and its `stops.stop_id` rows.
nonisolated struct CrossOperatorSide: Hashable, Sendable {
    let sourceID: String
    let inputSHA256: String
    /// Sorted by stop identifier; one `stops.txt` member of this input.
    let members: [SourceReference]

    enum Invalid: Error, Hashable, Sendable {
        case malformedSourceID
        case malformedDigest
        case noMembers
        case repeatedMember
        /// A member that is not a `stops.stop_id` row of this side's input.
        case memberOutsideInput
    }

    init(sourceID: String, inputSHA256: String, members: [SourceReference]) throws(Invalid) {
        guard MappingText.isToken(sourceID) else { throw .malformedSourceID }
        guard MappingText.isSHA256(inputSHA256) else { throw .malformedDigest }
        guard !members.isEmpty else { throw .noMembers }
        guard Set(members.map(\.providerKey)).count == members.count else { throw .repeatedMember }
        let member = members[0].member
        for reference in members {
            guard reference.inputSHA256 == inputSHA256, reference.member != nil, reference.member == member,
                  reference.table == "stops", reference.field == "stop_id"
            else { throw .memberOutsideInput }
        }
        self.sourceID = sourceID
        self.inputSHA256 = inputSHA256
        self.members = members.sorted { $0.providerKey < $1.providerKey }
    }

    /// Orders sides by source, then input, then members.
    static func precedes(_ lhs: CrossOperatorSide, _ rhs: CrossOperatorSide) -> Bool {
        if lhs.sourceID != rhs.sourceID { return lhs.sourceID.utf8.lexicographicallyPrecedes(rhs.sourceID.utf8) }
        if lhs.inputSHA256 != rhs.inputSHA256 { return lhs.inputSHA256 < rhs.inputSHA256 }
        return lhs.members.map(\.providerKey).lexicographicallyPrecedes(rhs.members.map(\.providerKey))
    }
}

/// A reviewer's record for one cross-operator candidate (DEC-069 §C2).
nonisolated struct ReviewedCrossOperatorRecord: Hashable, Sendable {
    /// Printable ASCII: the reviewed record's own identifier.
    let reviewID: String
    /// Exactly two, of different sources, ordered by source.
    let sides: [CrossOperatorSide]
    /// The digest of the candidate evidence the reviewer saw. If the evidence
    /// changes, the record no longer applies.
    let evidenceSHA256: String
    let outcome: CrossOperatorOutcome
    /// Printable ASCII, spaces allowed, not blank. Project text.
    let reason: String
    /// The alias rules the reviewer relied on. Only a `same` record cites
    /// rules, and only rules that actually related this candidate's names.
    let citedAliasRules: [StationAliasRule]
    /// The evidence the decision relies on, by provenance. Sorted, no repeats.
    let evidenceProvenance: [CrossOperatorEvidenceProvenance]

    enum Invalid: Error, Hashable, Sendable {
        case malformedReviewID
        case malformedDigest
        case malformedReason
        case notTwoSides
        /// Both sides come from one source: a cross-operator record relates
        /// two operators.
        case sidesFromOneSource
        case repeatedAliasRule
        /// Alias rules cited by a `distinct` or `ambiguous` record: a rule can
        /// only support a merge.
        case aliasCitationWithoutSame
        case repeatedProvenance
    }

    init(
        reviewID: String,
        sides: [CrossOperatorSide],
        evidenceSHA256: String,
        outcome: CrossOperatorOutcome,
        reason: String,
        citedAliasRules: [StationAliasRule] = [],
        evidenceProvenance: [CrossOperatorEvidenceProvenance] = []
    ) throws(Invalid) {
        guard MappingText.isToken(reviewID) else { throw .malformedReviewID }
        guard MappingText.isSHA256(evidenceSHA256) else { throw .malformedDigest }
        let bytes = Array(reason.utf8)
        guard bytes.contains(where: { $0 != 0x20 }), bytes.allSatisfy({ (0x20...0x7E).contains($0) }) else {
            throw .malformedReason
        }
        guard sides.count == 2 else { throw .notTwoSides }
        guard sides[0].sourceID != sides[1].sourceID else { throw .sidesFromOneSource }
        guard Set(citedAliasRules).count == citedAliasRules.count else { throw .repeatedAliasRule }
        guard citedAliasRules.isEmpty || outcome == .same else { throw .aliasCitationWithoutSame }
        guard Set(evidenceProvenance).count == evidenceProvenance.count else { throw .repeatedProvenance }
        self.reviewID = reviewID
        self.sides = sides.sorted(by: CrossOperatorSide.precedes)
        self.evidenceSHA256 = evidenceSHA256
        self.outcome = outcome
        self.reason = reason
        self.citedAliasRules = citedAliasRules.sorted()
        self.evidenceProvenance = evidenceProvenance.sorted()
    }
}

/// The reviewed cross-operator records for one run (DEC-069 §C3).
nonisolated struct ReviewedCrossOperatorSet: Hashable, Sendable {
    /// Sorted by review identifier.
    let records: [ReviewedCrossOperatorRecord]

    enum Invalid: Error, Hashable, Sendable {
        case repeatedReviewID
        /// Two records for one pair of identities.
        case repeatedPair
        /// Two records name overlapping but different member sets for one
        /// source: they disagree about an operator-level identity.
        case overlappingSides
        /// One identity joined by two `same` records: a canonical station
        /// holds at most one identity per operator.
        case identityInTwoSame
    }

    init(_ records: [ReviewedCrossOperatorRecord]) throws(Invalid) {
        struct Row: Hashable {
            let sourceID: String
            let inputSHA256: String
            let stopID: ExactValue
        }
        guard Set(records.map(\.reviewID)).count == records.count else { throw .repeatedReviewID }
        guard Set(records.map(\.sides)).count == records.count else { throw .repeatedPair }
        var sideOfRow: [Row: CrossOperatorSide] = [:]
        var joined = Set<CrossOperatorSide>()
        for record in records {
            for side in record.sides {
                for member in side.members {
                    let row = Row(sourceID: side.sourceID, inputSHA256: side.inputSHA256, stopID: member.providerKey)
                    if let earlier = sideOfRow.updateValue(side, forKey: row), earlier != side { throw .overlappingSides }
                }
                if record.outcome == .same {
                    guard joined.insert(side).inserted else { throw .identityInTwoSame }
                }
            }
        }
        self.records = records.sorted { $0.reviewID.utf8.lexicographicallyPrecedes($1.reviewID.utf8) }
    }

    static let empty = try! ReviewedCrossOperatorSet([])
}

/// A reviewer's assignment of one provisional `StationID` to one canonical
/// station group (DEC-069 §D1): the reviewed record that attaches the group's
/// provider keys to that station.
nonisolated struct ReviewedStationAssignment: Hashable, Sendable {
    let reviewID: String
    let stationID: MintedIdentifier
    /// One side per operator in the group: one, or two joined by `same`.
    /// Ordered by source.
    let sides: [CrossOperatorSide]

    enum Invalid: Error, Hashable, Sendable {
        case malformedReviewID
        case notAStationIdentifier
        case invalidSides
    }

    init(reviewID: String, stationID: MintedIdentifier, sides: [CrossOperatorSide]) throws(Invalid) {
        guard MappingText.isToken(reviewID) else { throw .malformedReviewID }
        guard stationID.kind == .station else { throw .notAStationIdentifier }
        guard (1...2).contains(sides.count), Set(sides.map(\.sourceID)).count == sides.count else { throw .invalidSides }
        self.reviewID = reviewID
        self.stationID = stationID
        self.sides = sides.sorted(by: CrossOperatorSide.precedes)
    }
}

/// The station assignments for one run: each review once, each station once,
/// and each stop row in one assignment.
nonisolated struct ReviewedStationAssignmentSet: Hashable, Sendable {
    let records: [ReviewedStationAssignment]

    enum Invalid: Error, Hashable, Sendable {
        case repeatedReviewID
        case stationInTwoAssignments
        case memberInTwoAssignments
    }

    init(_ records: [ReviewedStationAssignment]) throws(Invalid) {
        struct Row: Hashable {
            let sourceID: String
            let stopID: ExactValue
        }
        guard Set(records.map(\.reviewID)).count == records.count else { throw .repeatedReviewID }
        guard Set(records.map(\.stationID)).count == records.count else { throw .stationInTwoAssignments }
        var seen = Set<Row>()
        for record in records {
            for side in record.sides {
                for member in side.members {
                    guard seen.insert(Row(sourceID: side.sourceID, stopID: member.providerKey)).inserted else { throw .memberInTwoAssignments }
                }
            }
        }
        self.records = records.sorted { $0.reviewID.utf8.lexicographicallyPrecedes($1.reviewID.utf8) }
    }

    static let empty = try! ReviewedStationAssignmentSet([])
}
