import Foundation

// Feed-revision reconciliation (DEC-068 §E) — in this offline tool only
// (ARCHITECTURE.md §4.1).
//
// Reconciles one validated registry with the provider references observed in
// one new identified input of one source. The observations arrive grouped
// into observed entities: the references the new input's own reviewed
// groupings and bindings put together. Every observed `stop_id` carries the
// routes that serve it. Turning a feed into observations, and writing any
// file, belong to the provisional-registry command, not here.
//
// The registry holds no route context, so route changes are found by
// comparing with the observations of the previous input: the one the
// registry was last reconciled with for this source, checked against the
// provenance of its active references. It is required once the registry
// holds an active reference of the source.
//
// Classification, per observed reference, in this order of precedence:
//   1. Identity is the exact key: source, namespace, and value, compared
//      scalar by scalar. Nothing else links an observation to the registry,
//      so a provider key spelled differently is a new value (and the old one
//      goes absent), never a change.
//   2. A key the registry holds as retired is a conflict (DEC-068 §E2).
//   3. A key it holds as active or absent is *unchanged* or *changed*: changed
//      when the names seen in this input differ from those seen in the input
//      it was last seen in, or when the routes serving it differ from those
//      in the previous input (reported; the registry stores no routes). Name history is append-only: every value keeps its
//      first-sighting source, and each later sighting is recorded beside it
//      with its own source. An absent key returns to active and is reported
//      as reactivated.
//   4. A key it does not hold is *new*:
//      - a provider key (`agency_id`, `route_id`, `stop_id`, `odpt:operator`,
//        Railway `@id` or `owl:sameAs`) stays unassigned unless a reviewed
//        record attaches it to an existing identity;
//      - a code (`stop_code`, Railway `lineCode`) on an entity anchored by a
//        held or attached provider key is a descriptive change of that
//        identity (DEC-068 §E3), attached without review and reported as
//        changed. Without an anchor it stays unassigned.
//   5. A held reference of this source, in a namespace the input covers, that
//      is not observed is *absent*: kept as history, never deleted.
//
// Conflicts (DEC-068 §E3) fail the run and produce no registry or report:
//   - a retired key reappears;
//   - an entity's references resolve to two identities (a merge), or one
//     identity's references appear in two entities (a split): both need an
//     identity migration (DEC-068 §E4), which this step does not perform;
//   - an entity resolves to a retired identity: identity changes only by
//     migration, so successors are never followed automatically;
//   - two stop rows already grouped — held on one identity — now share a
//     route, unless the previous input shows they already did (a grouping
//     accepted with a reviewed exception). Without that evidence the run
//     fails. Rows grouped for the first time are settled by their own review.
// An attached reference keeps its attaching review (`attachedBy`) for good.
// Reviewed records are idempotent: rerunning a run's own records against its
// output is a fixed point, verified against the stored review identifiers;
// a substitute record is refused.
// A transition DEC-068 does not settle stops behind `undecided`.
//
// Output is deterministic: the same registry, input, and records give the
// same registry bytes and summary bytes. The registry's revision advances
// only when something changes, so a repeat run is a fixed point. The summary
// holds only counts, the source, hashes, and revisions: it is the only part
// meant to leave the operator's machine as a report.

/// One provider value observed in the input, with where it was read.
struct ObservedReference: Hashable {
    let namespace: ProviderNamespace
    let value: ExactValue
    let provenance: SourceReference
    /// The names read with it, each with its source in this input.
    let originalNames: [OriginalName]
    /// For a `stop_id`, the routes that serve the row in this input (empty
    /// when none does); required. `nil` for every other namespace.
    var routes: [ExactValue]? = nil
}

/// References the new input puts together as one entity.
struct ObservedEntity: Hashable {
    let kind: CanonicalKind
    let references: [ObservedReference]
}

/// Whether a namespace holds a provider key, which identifies a record, or
/// a code, which describes one (DEC-068 §E3: "the provider key is unchanged
/// but its name, code, or route changed").
enum RevisionNamespaces {
    static func isCode(_ namespace: ProviderNamespace) -> Bool {
        namespace == .gtfsStopCode || namespace == .odptRailwayLineCode
    }
}

/// One identified input of one source, as observed entities.
struct RevisionInput {
    let sourceID: String
    let inputSHA256: String
    /// The namespaces this input reports in full. Only references in these
    /// namespaces can go absent.
    let coveredNamespaces: Set<ProviderNamespace>
    let entities: [ObservedEntity]

    enum Invalid: Error, Equatable {
        case malformedSourceID
        case malformedDigest
        case emptyEntity
        /// An entity with no provider key: a code alone cannot anchor an identity.
        case entityWithoutProviderKey
        /// A reference whose namespace identifies another kind of entity.
        case kindMismatch
        case uncoveredNamespace
        /// A value or name read from another input, or in the wrong form for
        /// its namespace (GTFS or `odpt:Railway`).
        case provenanceMismatch
        /// One key observed twice.
        case repeatedReference
        /// One name, in one language, listed twice for one reference.
        case repeatedName
        /// A `stop_id` without its routes.
        case missingRouteEvidence
        /// Routes on a reference that is not a `stop_id`.
        case unexpectedRouteEvidence
        case repeatedRoute
    }

    init(sourceID: String, inputSHA256: String, coveredNamespaces: Set<ProviderNamespace>, entities: [ObservedEntity]) throws(Invalid) {
        guard MappingText.isToken(sourceID) else { throw .malformedSourceID }
        guard MappingText.isSHA256(inputSHA256) else { throw .malformedDigest }
        var keys = Set<ProviderReferenceKey>()
        for entity in entities {
            guard !entity.references.isEmpty else { throw .emptyEntity }
            guard entity.references.contains(where: { !RevisionNamespaces.isCode($0.namespace) }) else { throw .entityWithoutProviderKey }
            for reference in entity.references {
                guard reference.namespace.kind == entity.kind else { throw .kindMismatch }
                guard coveredNamespaces.contains(reference.namespace) else { throw .uncoveredNamespace }
                let sources = [reference.provenance] + reference.originalNames.map(\.source)
                guard sources.allSatisfy({ $0.inputSHA256 == inputSHA256 && $0.isGTFSPosition == reference.namespace.isGTFS }) else {
                    throw .provenanceMismatch
                }
                if reference.namespace == .gtfsStopID {
                    guard let routes = reference.routes else { throw .missingRouteEvidence }
                    guard Set(routes).count == routes.count else { throw .repeatedRoute }
                } else {
                    guard reference.routes == nil else { throw .unexpectedRouteEvidence }
                }
                let names = reference.originalNames.map { [$0.language, $0.value] }
                guard Set(names).count == names.count else { throw .repeatedName }
                guard keys.insert(ProviderReferenceKey(sourceID: sourceID, namespace: reference.namespace, value: reference.value)).inserted else {
                    throw .repeatedReference
                }
            }
        }
        self.sourceID = sourceID
        self.inputSHA256 = inputSHA256
        self.coveredNamespaces = coveredNamespaces
        self.entities = entities
    }
}

/// The DEC-068 §E3 categories a successful run reports. A conflict is never
/// a category of a result: it fails the run.
enum RevisionCategory: String, Hashable {
    case unchanged
    case changed
    case absent
    case new
}

/// What the run did with one reference.
struct ReferenceRevision: Hashable {
    let key: ProviderReferenceKey
    let category: RevisionCategory
    /// The identity it resolves to after the run; `nil` for an unassigned
    /// new value. Absent references keep theirs, as history.
    let canonicalID: MintedIdentifier?
    /// An absent reference observed again.
    let reactivated: Bool
    /// A new provider key attached by this reviewed record.
    let attachedBy: String?
    /// Retired by this reviewed record in this run.
    let retiredBy: String?
    /// Its serving routes differ from the previous input's.
    var routeChanged = false
}

/// Aggregate counts only: no provider value, name, or identifier.
struct RevisionSummary: Codable, Equatable {
    let sourceID: String
    let inputSHA256: String
    let previousRevision: Int
    let revision: Int
    let unchanged: Int
    let changed: Int
    let reactivated: Int
    /// Changed references whose serving routes changed.
    let routeChanged: Int
    /// Newly absent in this run.
    let absent: Int
    /// Already absent, and still not observed.
    let stillAbsent: Int
    let newAttached: Int
    let newUnassigned: Int
    let retired: Int

    /// Deterministic JSON with sorted keys.
    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }
}

struct RevisionOutcome: Equatable {
    /// The reconciled registry. Its revision advances only if it changed.
    let registry: MappingRegistry
    let summary: RevisionSummary
    /// Every observed or affected reference, sorted by key. For the operator
    /// only: it names provider values.
    let references: [ReferenceRevision]
}

/// A contradiction that fails the run (DEC-068 §E3).
struct RevisionConflict: Hashable {
    enum Kind: String, Hashable {
        /// A retired key appears in the input.
        case retiredValueReappeared
        /// One observed entity resolves to several identities: a merge,
        /// which needs an identity migration.
        case competingIdentities
        /// One identity's references appear in several observed entities: a
        /// split, which needs an identity migration.
        case splitIdentity
        /// An observed entity resolves to a retired identity. Successors are
        /// followed only by migration, never automatically.
        case retiredIdentity
        /// Two stop rows of one entity share a route, and the previous input
        /// does not show that they already did.
        case groupedRowsShareRoute
    }

    let kind: Kind
    /// Sorted. Provider values: for the operator only.
    let keys: [ProviderReferenceKey]
    /// Sorted.
    let identities: [MintedIdentifier]
}

/// A transition DEC-068 does not settle. The run stops; a decision is needed.
enum UndecidedTransition: String, Hashable {
    /// A reviewed retirement of a value that is present in this input — the
    /// "provider reuses a value for something else" case of DEC-068 §E1.
    /// Retiring it would make its presence a conflict at once, and the
    /// registry holds one reference per key, so the value's new meaning
    /// cannot be recorded. DEC-068 does not say how such a reuse is resolved.
    case retireObservedValue
}

enum RevisionError: Error, Equatable {
    /// A reviewed record that does not fit this run. Names the record only.
    enum RecordProblem: String, Hashable {
        /// Another source or input.
        case recordForOtherInput
        /// An attachment of a key the registry already holds, other than this
        /// record's own earlier application: that would rebind a reference.
        case attachToHeldReference
        /// An attachment of a key not observed in this input.
        case attachNotObserved
        /// An attachment of a code: codes follow their provider key.
        case attachCode
        /// An attachment to an identity the registry does not hold.
        case attachToUnknownIdentity
        /// A retirement of a key the registry does not hold.
        case retireUnknownReference
        /// A retirement of a reference another review retired.
        case retireRetiredReference
    }

    case record(RecordProblem, reviewID: String)
    /// Every conflict found, sorted. Nothing is produced.
    case conflicts([RevisionConflict])
    case undecided(UndecidedTransition, reviewID: String)
    /// The previous input does not fit this run.
    enum PreviousInputProblem: String, Hashable {
        /// The registry holds active references of the source, so route
        /// changes cannot be found without the previous input.
        case required
        case otherSource
        /// An active reference of the source was last seen in another input:
        /// this is not the input the registry was last reconciled with.
        case notLastReconciled
        /// The previous input does not cover a namespace of an active
        /// reference this run covers, or does not contain the reference.
        /// Without it, route changes and conflicts could go unseen.
        case incomplete
    }
    case previousInput(PreviousInputProblem)
    /// The reconciled registry broke a registry rule. A defect, not input.
    case registryInvariant(MappingRegistryError)

    /// Counts by conflict kind: the only form safe to print or report.
    var conflictCounts: [String: Int] {
        guard case .conflicts(let conflicts) = self else { return [:] }
        return Dictionary(grouping: conflicts, by: \.kind.rawValue).mapValues(\.count)
    }
}

enum RevisionReconciliation {
    static func reconcile(
        _ registry: MappingRegistry,
        with input: RevisionInput,
        previous: RevisionInput?,
        records: ReviewedRevisionSet = .empty
    ) throws(RevisionError) -> RevisionOutcome {
        func key(_ observed: ObservedReference) -> ProviderReferenceKey {
            ProviderReferenceKey(sourceID: input.sourceID, namespace: observed.namespace, value: observed.value)
        }

        // 0. The previous input is the one the registry was last reconciled
        //    with for this source.
        let activeOfSource = registry.references.filter { $0.sourceID == input.sourceID && $0.status == .active }
        var previousRoutes: [ProviderReferenceKey: Set<ExactValue>] = [:]
        var previousEntity: [ProviderReferenceKey: Int] = [:]
        if let previous {
            guard previous.sourceID == input.sourceID else { throw .previousInput(.otherSource) }
            for (index, entity) in previous.entities.enumerated() {
                for reference in entity.references {
                    previousEntity[key(reference)] = index
                    if let routes = reference.routes { previousRoutes[key(reference)] = Set(routes) }
                }
            }
            // Every active reference this run covers must have been observed
            // in the previous input, and last seen there.
            for reference in activeOfSource where input.coveredNamespaces.contains(reference.namespace) {
                guard previous.coveredNamespaces.contains(reference.namespace) else { throw .previousInput(.incomplete) }
                guard reference.provenance.inputSHA256 == previous.inputSHA256 else { throw .previousInput(.notLastReconciled) }
                guard previousEntity[reference.key] != nil else { throw .previousInput(.incomplete) }
            }
        } else {
            guard activeOfSource.isEmpty else { throw .previousInput(.required) }
        }
        var observedEntity: [ProviderReferenceKey: Int] = [:]
        for (index, entity) in input.entities.enumerated() {
            for reference in entity.references { observedEntity[key(reference)] = index }
        }

        // 1. Reviewed records must fit this run.
        var attachments: [ProviderReferenceKey: (identity: MintedIdentifier, reviewID: String)] = [:]
        var retirements: [ProviderReferenceKey: String] = [:]
        for record in records.records {
            guard record.key.sourceID == input.sourceID, record.inputSHA256 == input.inputSHA256 else {
                throw .record(.recordForOtherInput, reviewID: record.reviewID)
            }
            let held = registry.reference(for: record.key)
            switch record.action {
            case .attach(let identity):
                if let held {
                    // Already applied by this very record: the reference
                    // names it as its attaching review, on this identity,
                    // first seen in the reviewed input. A rerun leaves it
                    // alone. Any other record — even one with the same key and
                    // identity — would rebind or replace review provenance.
                    guard held.attachedBy == record.reviewID, held.canonicalID == identity,
                          held.firstSeenInputSHA256 == record.inputSHA256 else {
                        throw .record(.attachToHeldReference, reviewID: record.reviewID)
                    }
                    continue
                }
                guard observedEntity[record.key] != nil else { throw .record(.attachNotObserved, reviewID: record.reviewID) }
                guard !RevisionNamespaces.isCode(record.key.namespace) else { throw .record(.attachCode, reviewID: record.reviewID) }
                guard registry.entity(identity) != nil else { throw .record(.attachToUnknownIdentity, reviewID: record.reviewID) }
                attachments[record.key] = (identity, record.reviewID)
            case .retire:
                guard let held else { throw .record(.retireUnknownReference, reviewID: record.reviewID) }
                if case .retired(let review) = held.status {
                    // Already retired by this record: a rerun leaves it alone.
                    guard review == record.reviewID else { throw .record(.retireRetiredReference, reviewID: record.reviewID) }
                    guard observedEntity[record.key] == nil else { throw .undecided(.retireObservedValue, reviewID: record.reviewID) }
                    continue
                }
                guard observedEntity[record.key] == nil else { throw .undecided(.retireObservedValue, reviewID: record.reviewID) }
                retirements[record.key] = record.reviewID
            }
        }

        // 2. Resolve each observed entity to at most one identity, and
        //    collect every conflict.
        var conflicts: [RevisionConflict] = []
        var identityOf: [Int: MintedIdentifier] = [:]
        var anchored = Set<Int>()
        var entitiesOfIdentity: [MintedIdentifier: Set<Int>] = [:]
        for (index, entity) in input.entities.enumerated() {
            var identities = Set<MintedIdentifier>()
            for observed in entity.references {
                let observedKey = key(observed)
                if let held = registry.reference(for: observedKey) {
                    if case .retired = held.status {
                        conflicts.append(RevisionConflict(kind: .retiredValueReappeared, keys: [observedKey], identities: [held.canonicalID]))
                        continue
                    }
                    identities.insert(held.canonicalID)
                    entitiesOfIdentity[held.canonicalID, default: []].insert(index)
                    if !RevisionNamespaces.isCode(observed.namespace) { anchored.insert(index) }
                } else if let attachment = attachments[observedKey] {
                    identities.insert(attachment.identity)
                    entitiesOfIdentity[attachment.identity, default: []].insert(index)
                    anchored.insert(index)
                }
            }
            let keys = entity.references.map(key).sorted()
            if identities.count > 1 {
                conflicts.append(RevisionConflict(kind: .competingIdentities, keys: keys, identities: identities.sorted()))
            } else if let identity = identities.first {
                if registry.entity(identity)?.status != .active {
                    conflicts.append(RevisionConflict(kind: .retiredIdentity, keys: keys, identities: [identity]))
                }
                identityOf[index] = identity
            }
        }
        for entity in input.entities {
            let stops = entity.references.filter { $0.namespace == .gtfsStopID }
            for i in stops.indices {
                for j in stops.indices where j > i {
                    let (a, b) = (key(stops[i]), key(stops[j]))
                    guard !Set(stops[i].routes ?? []).isDisjoint(with: stops[j].routes ?? []) else { continue }
                    // Only rows already grouped — held on one identity — can
                    // contradict an accepted grouping. A new grouping is
                    // settled by its own review.
                    guard let heldA = registry.reference(for: a), let heldB = registry.reference(for: b),
                          heldA.canonicalID == heldB.canonicalID else { continue }
                    // Allowed only if the previous input grouped them and
                    // they already shared a route there.
                    if let groupA = previousEntity[a], groupA == previousEntity[b],
                       let before = previousRoutes[a], let other = previousRoutes[b], !before.isDisjoint(with: other) {
                        continue
                    }
                    conflicts.append(RevisionConflict(kind: .groupedRowsShareRoute, keys: [a, b].sorted(), identities: []))
                }
            }
        }
        for (identity, entities) in entitiesOfIdentity where entities.count > 1 {
            let keys = entities.flatMap { input.entities[$0].references.map(key) }.sorted()
            conflicts.append(RevisionConflict(kind: .splitIdentity, keys: keys, identities: [identity]))
        }
        guard conflicts.isEmpty else {
            throw .conflicts(conflicts.sorted { lhs, rhs in
                if lhs.kind != rhs.kind { return lhs.kind.rawValue < rhs.kind.rawValue }
                if lhs.keys != rhs.keys { return lhs.keys.lexicographicallyPrecedes(rhs.keys) }
                return lhs.identities.lexicographicallyPrecedes(rhs.identities)
            })
        }

        // 3. Observed references: unchanged, changed, reactivated, attached,
        //    or unassigned.
        var updated: [ProviderReferenceKey: ProviderReference] = [:]
        for reference in registry.references { updated[reference.key] = reference }
        var results: [ReferenceRevision] = []
        var counts = (unchanged: 0, changed: 0, reactivated: 0, routeChanged: 0, absent: 0, stillAbsent: 0, attached: 0, unassigned: 0, retired: 0)

        for (index, entity) in input.entities.enumerated() {
            for observed in entity.references {
                let observedKey = key(observed)
                if let held = registry.reference(for: observedKey) {
                    let (names, namesChanged) = mergeNames(held, observed)
                    let reactivated = held.status == .absent
                    // Compared only when both inputs observed the row.
                    let routeChanged = observed.routes.map { now in previousRoutes[observedKey].map { $0 != Set(now) } ?? false } ?? false
                    let changed = namesChanged || routeChanged
                    updated[observedKey] = try make(
                        held.canonicalID, input, observed, .active, firstSeen: held.firstSeenInputSHA256, names: names, attachedBy: held.attachedBy
                    )
                    results.append(ReferenceRevision(
                        key: observedKey, category: changed ? .changed : .unchanged, canonicalID: held.canonicalID,
                        reactivated: reactivated, attachedBy: nil, retiredBy: nil, routeChanged: routeChanged
                    ))
                    if changed { counts.changed += 1 } else { counts.unchanged += 1 }
                    if reactivated { counts.reactivated += 1 }
                    if routeChanged { counts.routeChanged += 1 }
                    continue
                }
                let identity = identityOf[index]
                if let attachment = attachments[observedKey], let identity {
                    updated[observedKey] = try make(
                        identity, input, observed, .active, firstSeen: input.inputSHA256, names: observed.originalNames, attachedBy: attachment.reviewID
                    )
                    results.append(ReferenceRevision(
                        key: observedKey, category: .new, canonicalID: identity, reactivated: false,
                        attachedBy: attachment.reviewID, retiredBy: nil
                    ))
                    counts.attached += 1
                } else if RevisionNamespaces.isCode(observed.namespace), let identity, anchored.contains(index) {
                    // A new code of an anchored identity: a descriptive change.
                    updated[observedKey] = try make(identity, input, observed, .active, firstSeen: input.inputSHA256, names: observed.originalNames)
                    results.append(ReferenceRevision(
                        key: observedKey, category: .changed, canonicalID: identity, reactivated: false, attachedBy: nil, retiredBy: nil
                    ))
                    counts.changed += 1
                } else {
                    results.append(ReferenceRevision(
                        key: observedKey, category: .new, canonicalID: nil, reactivated: false, attachedBy: nil, retiredBy: nil
                    ))
                    counts.unassigned += 1
                }
            }
        }

        // 4. Held references of this source and covered namespaces that were
        //    not observed: absent, or retired by a reviewed record.
        for reference in registry.references
        where reference.sourceID == input.sourceID && observedEntity[reference.key] == nil {
            if let reviewID = retirements[reference.key] {
                updated[reference.key] = try restatus(reference, .retired(review: reviewID))
                results.append(ReferenceRevision(
                    key: reference.key, category: .absent, canonicalID: reference.canonicalID,
                    reactivated: false, attachedBy: nil, retiredBy: reviewID
                ))
                counts.retired += 1
                continue
            }
            guard input.coveredNamespaces.contains(reference.namespace) else { continue }
            switch reference.status {
            case .active:
                updated[reference.key] = try restatus(reference, .absent)
                counts.absent += 1
            case .absent:
                counts.stillAbsent += 1
            case .retired:
                continue
            }
            results.append(ReferenceRevision(
                key: reference.key, category: .absent, canonicalID: reference.canonicalID,
                reactivated: false, attachedBy: nil, retiredBy: nil
            ))
        }

        // 5. The reconciled registry. Entities are never changed here.
        let references = Array(updated.values)
        let changed = references.sorted { $0.key < $1.key } != registry.references
        let reconciled: MappingRegistry
        do {
            reconciled = try MappingRegistry(
                revision: changed ? registry.revision + 1 : registry.revision,
                entities: registry.entities,
                references: references
            )
        } catch {
            throw .registryInvariant(error)
        }

        return RevisionOutcome(
            registry: reconciled,
            summary: RevisionSummary(
                sourceID: input.sourceID, inputSHA256: input.inputSHA256,
                previousRevision: registry.revision, revision: reconciled.revision,
                unchanged: counts.unchanged, changed: counts.changed, reactivated: counts.reactivated, routeChanged: counts.routeChanged,
                absent: counts.absent, stillAbsent: counts.stillAbsent,
                newAttached: counts.attached, newUnassigned: counts.unassigned, retired: counts.retired
            ),
            references: results.sorted { $0.key < $1.key }
        )
    }

    /// Name history is append-only. Every entry keeps the source it was
    /// recorded with, so a value's first sighting is never overwritten or
    /// removed. Each sighting in a new input is recorded as its own entry,
    /// with that input's source — including a value seen before, or restored
    /// after a change. An identical entry is not added twice, so a repeat run
    /// changes nothing. The entries from the input the reference was last seen
    /// in are its current names; the reference has changed when the
    /// observation's names differ from them by language and value, compared
    /// scalar by scalar.
    private static func mergeNames(_ held: ProviderReference, _ observed: ObservedReference) -> ([OriginalName], Bool) {
        struct Name: Hashable {
            let language: ExactValue
            let value: ExactValue
        }
        let current = Set(held.originalNames.filter { $0.source.inputSHA256 == held.provenance.inputSHA256 }.map { Name(language: $0.language, value: $0.value) })
        let seen = Set(observed.originalNames.map { Name(language: $0.language, value: $0.value) })
        let recorded = Set(held.originalNames)
        let names = held.originalNames + observed.originalNames.filter { !recorded.contains($0) }
        return (names, current != seen)
    }

    private static func make(
        _ identity: MintedIdentifier,
        _ input: RevisionInput,
        _ observed: ObservedReference,
        _ status: ProviderReferenceStatus,
        firstSeen: String,
        names: [OriginalName],
        attachedBy: String? = nil
    ) throws(RevisionError) -> ProviderReference {
        do {
            return try ProviderReference(
                canonicalID: identity, sourceID: input.sourceID, namespace: observed.namespace, value: observed.value,
                status: status, firstSeenInputSHA256: firstSeen, provenance: observed.provenance, originalNames: names,
                attachedBy: attachedBy
            )
        } catch {
            // `RevisionInput` checks provenance form, and names are merged
            // without repeats, so this is a defect.
            preconditionFailure("reconciled reference broke a reference rule: \(error)")
        }
    }

    private static func restatus(_ reference: ProviderReference, _ status: ProviderReferenceStatus) throws(RevisionError) -> ProviderReference {
        do {
            return try ProviderReference(
                canonicalID: reference.canonicalID, sourceID: reference.sourceID, namespace: reference.namespace,
                value: reference.value, status: status, firstSeenInputSHA256: reference.firstSeenInputSHA256,
                provenance: reference.provenance, originalNames: reference.originalNames, attachedBy: reference.attachedBy
            )
        } catch {
            preconditionFailure("a status change broke a reference rule: \(error)")
        }
    }
}
