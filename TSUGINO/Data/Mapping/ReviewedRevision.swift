import Foundation

// Reviewed revision records (DEC-068 §E): the transitions reconciliation may
// not make on its own.
//
// Reconciling a new input makes the automatic transitions itself: active to
// absent, absent back to active, and descriptive changes. Two transitions
// need a reviewer's record:
//   - attaching a provider key the registry has never held to an existing
//     identity (DEC-068 §E3 "New": a grouping or binding needs its reviewed
//     record);
//   - retiring an active or absent reference (DEC-068 §E1, §E2).
// A record belongs to one reference in one identified input. It never
// rebinds a held reference, never reactivates a retired one, and never merges
// or splits identities: those need an identity migration (DEC-068 §E4),
// which is not part of these records.
//
// Reconciliation is tool-only (ARCHITECTURE.md §4.1). These types hold no
// provider dataset: records are written by a reviewer for a real input, kept
// outside the repository until the registry-of-record decision (DEC-068 §F),
// and invented in tests.

nonisolated struct ReviewedRevisionRecord: Hashable, Sendable {
    nonisolated enum Action: Hashable, Sendable {
        /// A provider key the registry has never held belongs to this
        /// existing identity.
        case attach(to: MintedIdentifier)
        /// The reference is withdrawn: kept as history, never resolved again.
        case retire
    }

    /// Printable ASCII: the reviewed record's own identifier.
    let reviewID: String
    let key: ProviderReferenceKey
    /// The identified input the reviewer saw.
    let inputSHA256: String
    let action: Action

    enum Invalid: Error, Hashable, Sendable {
        case malformedReviewID
        case malformedSourceID
        case malformedDigest
        /// The identity is of another kind than the namespace identifies.
        case kindMismatch
    }

    init(reviewID: String, key: ProviderReferenceKey, inputSHA256: String, action: Action) throws(Invalid) {
        guard MappingText.isToken(reviewID) else { throw .malformedReviewID }
        guard MappingText.isToken(key.sourceID) else { throw .malformedSourceID }
        guard MappingText.isSHA256(inputSHA256) else { throw .malformedDigest }
        if case .attach(let identity) = action {
            guard identity.kind == key.namespace.kind else { throw .kindMismatch }
        }
        self.reviewID = reviewID
        self.key = key
        self.inputSHA256 = inputSHA256
        self.action = action
    }
}

/// The reviewed revision records for one run: each review identifier once,
/// and each reference in one record.
nonisolated struct ReviewedRevisionSet: Hashable, Sendable {
    /// Sorted by review identifier.
    let records: [ReviewedRevisionRecord]

    enum Invalid: Error, Hashable, Sendable {
        case repeatedReviewID
        case referenceInTwoRecords
    }

    init(_ records: [ReviewedRevisionRecord]) throws(Invalid) {
        guard Set(records.map(\.reviewID)).count == records.count else { throw .repeatedReviewID }
        guard Set(records.map(\.key)).count == records.count else { throw .referenceInTwoRecords }
        self.records = records.sorted { $0.reviewID.utf8.lexicographicallyPrecedes($1.reviewID.utf8) }
    }

    static let empty = try! ReviewedRevisionSet([])
}
