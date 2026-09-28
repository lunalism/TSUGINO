import Foundation

// Reviewed line-binding records (DEC-068 §D3, §D4): the only way a static
// route and `odpt:Railway` records are bound to a canonical `LineID`.
//
// The official-field checks only propose. A binding takes effect when a
// reviewed record names its `LineID`, the source reference of every provider
// record it binds, the digest of the evidence reviewed, and an acceptance for
// every disagreement that evidence reports. An acceptance belongs to one
// member of one record and never becomes a general rule.
//
// A record binds any number of static routes and Railway records to one
// `LineID`: the mapping layer maps several provider identifiers to one
// canonical line (ARCHITECTURE.md §40), and no accepted rule limits a line to
// one route. A branch record, such as the invented `Qb`, is bound beside its
// main-line record with its own source reference: no second `LineID` and no
// branch identity exist (DEC-057 D6). For inputs identified as launch inputs,
// the tool also refuses to split a line code's family across `LineID`s, and
// no acceptance can waive that (DEC-068 §D4). Whether a launch input's
// bindings match its baseline line count is checked at real-data acceptance
// (DEC-068 §H), not here.
//
// Proposals, evidence, and applying records are tool-only
// (ARCHITECTURE.md §4.1). These types hold no provider dataset: records are
// written by a reviewer for a real input, kept outside the repository until
// the registry-of-record decision (DEC-068 §F), and invented in tests.

/// The official-field checks (DEC-068 §D3). A Railway record is compared
/// with every static route it is bound with, and, in a binding of several
/// routes, each route with every other. A check fails for a member when any
/// of those comparisons disagrees or has nothing to compare. A disagreement
/// is reported and binds nothing by itself.
nonisolated enum LineBindingCheck: String, CaseIterable, Hashable, Comparable, Sendable {
    /// The record's line code is the letter prefix of a stop code on the
    /// route; two routes share a stop-code prefix.
    case lineCode
    /// A Japanese display title is shared. A script-specific reading such as
    /// `ja-Hrkt` is not a display title.
    case japaneseTitle
    /// An English display title is shared.
    case englishTitle
    /// The colours are equal.
    case color
    /// No route outside the binding is also a candidate for the record.
    /// Railway records only.
    case uniqueCounterpart

    static func < (lhs: LineBindingCheck, rhs: LineBindingCheck) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

/// One provider record a binding names: a `routes.route_id` row of a GTFS
/// input, or the `@id` of an `odpt:Railway` record.
nonisolated struct LineBindingMember: Hashable, Sendable {
    nonisolated enum Kind: Hashable, Sendable {
        case staticRoute
        case railwayRecord
    }

    /// The DEC-066 source identifier: printable ASCII.
    let sourceID: String
    let reference: SourceReference

    enum Invalid: Error, Hashable, Sendable {
        case malformedSourceID
        /// Neither a `routes.route_id` reference nor an `odpt:Railway` `@id`
        /// reference.
        case notARouteOrRailwayRecord
    }

    init(sourceID: String, reference: SourceReference) throws(Invalid) {
        guard MappingText.isToken(sourceID) else { throw .malformedSourceID }
        let isRoute = reference.isGTFSPosition && reference.table == "routes" && reference.field == "route_id"
        let isRailway = !reference.isGTFSPosition && reference.field == "@id"
        guard isRoute || isRailway else { throw .notARouteOrRailwayRecord }
        self.sourceID = sourceID
        self.reference = reference
    }

    var kind: Kind { reference.isGTFSPosition ? .staticRoute : .railwayRecord }

    /// Static routes first, then by source and reference: a total order.
    static func precedes(_ lhs: LineBindingMember, _ rhs: LineBindingMember) -> Bool {
        if lhs.kind != rhs.kind { return lhs.kind == .staticRoute }
        if !lhs.sourceID.utf8.elementsEqual(rhs.sourceID.utf8) {
            return lhs.sourceID.utf8.lexicographicallyPrecedes(rhs.sourceID.utf8)
        }
        return SourceReference.precedes(lhs.reference, rhs.reference)
    }

    /// What makes two members the same provider record, wherever it is named.
    var identity: Identity {
        Identity(sourceID: sourceID, inputSHA256: reference.inputSHA256, kind: kind, providerKey: reference.providerKey)
    }

    nonisolated struct Identity: Hashable, Sendable {
        let sourceID: String
        let inputSHA256: String
        let kind: Kind
        let providerKey: ExactValue
    }
}

/// A reviewed acceptance of one member's disagreements: the checks it
/// accepts and why. It must name exactly the checks that disagree.
nonisolated struct LineBindingAcceptance: Hashable, Sendable {
    let member: LineBindingMember
    /// Printable ASCII, spaces allowed, not blank. Project text.
    let reason: String
    /// Sorted, non-empty, no repeats.
    let acceptedChecks: [LineBindingCheck]

    enum Invalid: Error, Hashable, Sendable {
        case malformedReason
        case invalidAcceptedChecks
    }

    init(member: LineBindingMember, reason: String, acceptedChecks: [LineBindingCheck]) throws(Invalid) {
        let bytes = Array(reason.utf8)
        guard bytes.contains(where: { $0 != 0x20 }), bytes.allSatisfy({ (0x20...0x7E).contains($0) }) else {
            throw .malformedReason
        }
        guard !acceptedChecks.isEmpty, Set(acceptedChecks).count == acceptedChecks.count else { throw .invalidAcceptedChecks }
        self.member = member
        self.reason = reason
        self.acceptedChecks = acceptedChecks.sorted()
    }
}

/// A reviewer's record binding static routes and Railway records to one
/// `LineID` (DEC-068 §D3).
nonisolated struct ReviewedLineBinding: Hashable, Sendable {
    /// Printable ASCII: the reviewed record's own identifier.
    let reviewID: String
    let lineID: MintedIdentifier
    /// The static routes first, then the Railway records.
    let members: [LineBindingMember]
    /// The digest of the evidence the reviewer saw. If the evidence changes,
    /// the record no longer applies.
    let evidenceSHA256: String
    /// Sorted by member; at most one per member.
    let acceptances: [LineBindingAcceptance]

    enum Invalid: Error, Hashable, Sendable {
        case malformedReviewID
        case malformedDigest
        /// The identifier is not a `LineID` (`lin_…`).
        case notALineIdentifier
        /// A binding names at least one provider record.
        case noMembers
        case repeatedMember
        /// An acceptance for a record this binding does not name, or two for
        /// one record.
        case invalidAcceptance
    }

    init(
        reviewID: String,
        lineID: MintedIdentifier,
        members: [LineBindingMember],
        evidenceSHA256: String,
        acceptances: [LineBindingAcceptance] = []
    ) throws(Invalid) {
        guard MappingText.isToken(reviewID) else { throw .malformedReviewID }
        guard MappingText.isSHA256(evidenceSHA256) else { throw .malformedDigest }
        guard lineID.kind == .line else { throw .notALineIdentifier }
        guard !members.isEmpty else { throw .noMembers }
        guard Set(members.map(\.identity)).count == members.count else { throw .repeatedMember }
        let named = Set(members)
        let accepted = acceptances.map(\.member)
        guard Set(accepted).count == accepted.count, accepted.allSatisfy(named.contains) else { throw .invalidAcceptance }
        self.reviewID = reviewID
        self.lineID = lineID
        self.members = members.sorted(by: LineBindingMember.precedes)
        self.evidenceSHA256 = evidenceSHA256
        self.acceptances = acceptances.sorted { LineBindingMember.precedes($0.member, $1.member) }
    }

    var staticRoutes: [LineBindingMember] { members.filter { $0.kind == .staticRoute } }
    var railwayRecords: [LineBindingMember] { members.filter { $0.kind == .railwayRecord } }
}

/// The reviewed bindings for one run: each review identifier once, each
/// `LineID` in one record, and each provider record bound once.
nonisolated struct ReviewedLineBindingSet: Hashable, Sendable {
    /// Sorted by review identifier.
    let records: [ReviewedLineBinding]

    enum Invalid: Error, Hashable, Sendable {
        case repeatedReviewID
        /// One provider record bound twice to the same `LineID`.
        case duplicateBinding
        /// One provider record bound to two `LineID`s.
        case conflictingBinding
        /// Two records for one `LineID`: a line is reviewed as a whole.
        case lineInTwoRecords
    }

    init(_ records: [ReviewedLineBinding]) throws(Invalid) {
        guard Set(records.map(\.reviewID)).count == records.count else { throw .repeatedReviewID }
        var boundTo: [LineBindingMember.Identity: MintedIdentifier] = [:]
        for record in records {
            for member in record.members {
                if let earlier = boundTo.updateValue(record.lineID, forKey: member.identity) {
                    throw earlier == record.lineID ? .duplicateBinding : .conflictingBinding
                }
            }
        }
        guard Set(records.map(\.lineID)).count == records.count else { throw .lineInTwoRecords }
        self.records = records.sorted { $0.reviewID.utf8.lexicographicallyPrecedes($1.reviewID.utf8) }
    }

    static let empty = try! ReviewedLineBindingSet([])
}
