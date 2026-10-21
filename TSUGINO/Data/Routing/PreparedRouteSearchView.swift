import Foundation

/// Supplied endpoint truth retained inside one captured view (consumer §27.3 S4).
/// A station absent from the view's table is `unknown`; nothing is re-read after capture.
nonisolated enum PreparedRouteEndpointDisposition: Sendable {
    case active
    case invalid(RouteSearchEndpointFailureReason)
}

/// Supplied occurrence-domain member. Membership is supplied authority, never
/// derived from loaded activation, facts, permissions or times (consumer §28.3).
nonisolated struct PreparedRouteOccurrenceDomainEntry: Sendable {
    let binding: TimetableOccurrenceBinding
    let intervalAuthority: TimetableQualificationReference
    let intervals: [TimetableVerifiedRideInterval]
}
nonisolated struct PreparedRouteOccurrenceDomain: Sendable {
    let reference: TimetableQualificationReference
    let completeness: TimetableInventoryCompleteness
    let entries: [PreparedRouteOccurrenceDomainEntry]
}
nonisolated struct PreparedRouteRelationDomain: Sendable {
    let reference: TimetableQualificationReference
    let completeness: TimetableInventoryCompleteness
    let targets: [ConnectionRelationKey]
}
/// Unresolved external obligations under the reference. Only an empty list can
/// qualify today; for invented views that is a stipulation, not authentication.
nonisolated struct PreparedRouteDependencyDomain: Sendable {
    let reference: TimetableQualificationReference
    let unresolved: [TimetableQualificationReference]
}

/// Supplied positive examination. The instants are the exact values the evidence
/// was examined under; nil means none was supplied. They are never filled from the inventory.
nonisolated struct PreparedRoutePositiveConnectionEntry: Sendable {
    let form: ConnectionForm
    let alighting: Double
    let interchange: Double
    let boarding: Double
    let total: Double
    let fromArrival: TimetableInstant?
    let toDeparture: TimetableInstant?
    let relation: ConnectionEvidencePremise
    let genuineChange: ConnectionEvidencePremise
    let componentPartition: ConnectionEvidencePremise
    let endpointWideContext: ConnectionEvidencePremise
}
nonisolated enum PreparedRouteConnectionEntry: Sendable {
    case positive(PreparedRoutePositiveConnectionEntry)
    case absence(relation: ConnectionEvidencePremise, endpointWideContext: ConnectionEvidencePremise,
                 eventIndependent: ConnectionEvidencePremise)
    case unavailable(ConnectionUnavailableReason)
}
nonisolated struct PreparedRouteConnectionAuthority: Sendable {
    let review: TimetableQualificationReference
    let completeness: TimetableInventoryCompleteness
    let entries: [ConnectionRelationKey: PreparedRouteConnectionEntry]
}

/// One whole immutable captured view (accepted E2). One view has one inventory
/// qualification, hence one view ID and railway revision. Supplier-built; no IO,
/// refresh, TTL or invalidation policy. Contents are stipulated, not authenticated.
nonisolated struct PreparedRouteSearchView: Sendable {
    let validFrom: Date
    let validUntil: Date
    let connectionPolicy: InternalSearchPolicyReference
    let serviceDateInterpretation: InternalSearchPolicyReference
    let inventory: TimetableOccurrenceInventoryView
    let endpoints: [StationID: PreparedRouteEndpointDisposition]
    let occurrences: PreparedRouteOccurrenceDomain
    let relations: PreparedRouteRelationDomain
    let dependencies: PreparedRouteDependencyDomain
    let connections: PreparedRouteConnectionAuthority
    var id: TimetableViewID { inventory.qualification.viewID }
    var railway: RailwayArtifactRevision { inventory.qualification.railway }

    /// Shared-view validity (DEC-079 stage 2): a finite ordered validity interval and
    /// exact policy-reference correspondence. Policy contents are not resolved here.
    func supports(_ profile: InternalSearchProfileDefinition) -> Bool {
        validFrom.timeIntervalSinceReferenceDate.isFinite && validUntil.timeIntervalSinceReferenceDate.isFinite
            && validFrom < validUntil && connectionPolicy == profile.connectionPolicy
            && serviceDateInterpretation == profile.serviceDateInterpretation
    }
    /// Inclusive: the whole request window [L, U] lies inside the validity interval.
    func covers(_ scope: InternalSearchScope) -> Bool {
        validFrom <= scope.lowerBound && scope.upperBound <= validUntil
    }
    func disposition(of station: StationID) -> PreparedRouteEndpointDisposition {
        endpoints[station] ?? .invalid(.unknown)
    }
}

/// Exactly one async read of the whole current view per invocation, or nil when none
/// is usable. Replacement never mutates a value already returned.
nonisolated protocol PreparedRouteViewSupplying: Sendable {
    func currentView() async -> PreparedRouteSearchView?
}

nonisolated struct PreparedRouteDeclarations: Sendable {
    let occurrences: SearchInputOccurrenceDeclaration
    let connections: SearchInputConnectionDeclaration
    let dependencies: SearchInputDependencyDeclaration
}

/// Pure per-request declaration producer, INVENTED INTEGRATION ONLY (consumer §28.3 R1).
/// Every supplied domain member is required regardless of date; the only exclusion is
/// the Accepted DEC-080 profile projection: non-profile Trips, intervals touching a
/// non-profile station/line, and relations incident to an excluded occurrence. It uses
/// declared profile/domain data only and never reads loaded slots. Projected-in members,
/// including malformed ones, pass through unchanged so the published closure rejects them;
/// projected-out members are dropped without structural checks. A relation between kept
/// occurrences at a non-profile alighting/boarding station is dropped only under DEC-088 D4
/// (see `untraversableAtProfileBoundary`). Production requiredness (R1/R2/R3) remains an
/// open owner decision.
nonisolated enum PreparedRouteDeclarationProducer {
    static func declarations(view: PreparedRouteSearchView, scope: InternalSearchScope)
        throws(SearchInputClosureConstructionFailure) -> PreparedRouteDeclarations {
        // No producer-side limits: the closure's existing safeguards govern the projected
        // output. Producer work is linear in the supplied domain, whose size the supplier owns.
        let domain = view.occurrences, relations = view.relations
        let profile = scope.profile, qualification = view.inventory.qualification
        var required: [SearchInputOccurrenceRequirement] = []
        var excluded = Set<TimetableOccurrenceAddress>()
        for entry in domain.entries {
            let trip = entry.binding.trip
            guard profile.trips.contains(trip.id) else { excluded.insert(entry.binding.address); continue }
            required.append(.init(binding: entry.binding, applicabilityReference: domain.reference,
                intervalAuthority: entry.intervalAuthority,
                intervals: entry.intervals.filter { withinProfile($0, trip: trip, profile: profile) }))
        }
        // D4 is applied only where the closure would accept the relation: kept occurrence
        // addresses must be unique, and every copy of a duplicate key stays, so filtering never
        // hides a declarationConflict or a duplicate-target connectionTargetConflict.
        var kept: [TimetableOccurrenceAddress: Trip] = [:]
        var uniqueAddresses = true
        for requirement in required where kept.updateValue(requirement.binding.trip, forKey: requirement.binding.address) != nil {
            uniqueAddresses = false
        }
        var keyCounts: [ConnectionRelationKey: Int] = [:]
        for key in relations.targets where !excluded.contains(key.from) && !excluded.contains(key.to) {
            keyCounts[key, default: 0] += 1
        }
        let targets = relations.targets.compactMap { key -> SearchInputConnectionTarget? in
            if excluded.contains(key.from) || excluded.contains(key.to) { return nil }
            if uniqueAddresses, keyCounts[key] == 1, untraversableAtProfileBoundary(key, kept: kept, scope: scope) { return nil }
            return .init(from: key.from, alightingIndex: key.alightingIndex, to: key.to,
                         boardingIndex: key.boardingIndex, applicabilityReference: relations.reference)
        }
        return .init(
            occurrences: .init(applicability: try .init(reference: domain.reference, scope: scope, qualification: qualification),
                               completeness: domain.completeness, required: required),
            connections: .init(applicability: try .init(reference: relations.reference, scope: scope, qualification: qualification),
                               completeness: relations.completeness, required: targets),
            dependencies: .init(applicability: try .init(reference: view.dependencies.reference, scope: scope,
                                                         qualification: qualification),
                                unresolved: view.dependencies.unresolved))
    }

    /// DEC-088 D4. True only for a relation passing exactly the closure's target checks
    /// (view IDs, both addresses kept, `alightingIndex > 0` and in range, `boardingIndex >= 0`
    /// and below the last index) whose alighting or boarding station is outside the profile.
    /// Every prepared ride interval lies inside `profile.stations` (`withinProfile` and the
    /// closure's `profileConflict`), so no ride can end or start there. Never reads lines,
    /// permissions, times or loaded state.
    static func untraversableAtProfileBoundary(_ key: ConnectionRelationKey, kept: [TimetableOccurrenceAddress: Trip],
                                               scope: InternalSearchScope) -> Bool {
        guard key.from.viewID == scope.viewID, key.to.viewID == scope.viewID,
              let from = kept[key.from], let to = kept[key.to],
              key.alightingIndex > 0, key.alightingIndex < from.stopSequence.count,
              key.boardingIndex >= 0, key.boardingIndex < to.stopSequence.count - 1 else { return false }
        return !scope.profile.stations.contains(from.stopSequence[key.alightingIndex])
            || !scope.profile.stations.contains(to.stopSequence[key.boardingIndex])
    }

    /// Same membership predicate the closure enforces for active occurrences
    /// (`RequestScopedSearchInputClosure` `profileConflict`); keep the two identical.
    private static func withinProfile(_ interval: TimetableVerifiedRideInterval, trip: Trip,
                                      profile: InternalSearchProfileDefinition) -> Bool {
        let b = interval.boardingIndex, a = interval.alightingIndex
        guard b >= 0, b < a, a < trip.stopSequence.count else { return true }
        return trip.stopSequence[b...a].allSatisfy(profile.stations.contains)
            && trip.lineSegments.allSatisfy { !($0.startIndex < a && b < $0.endIndex) || profile.lines.contains($0.lineID) }
    }
}

/// Pure per-request connection-evidence producer (consumer §28.4). Exactly one record
/// per required closure target, in closure order. Computes only the key and the two
/// bindings copied from the closure; every other field passes through from the view.
/// A missing entry or examined instant is insufficient evidence, never an absence.
nonisolated enum PreparedRouteConnectionEvidenceProducer {
    static func evidence(view: PreparedRouteSearchView, closure: RequestScopedSearchInputClosure)
        throws(ConnectionEvidenceFailure) -> QualifiedConnectionEvidenceView {
        let targets = closure.connections.required, authority = view.connections
        guard targets.count <= ConnectionEvidenceLimits.relations else { throw .resourceLimit }
        let qualification = try ConnectionEvidenceQualification(applicability: closure.connections.applicability,
            policy: view.connectionPolicy, review: authority.review)
        // The closure has already proved one requirement per address; never trap if not.
        var bindings: [TimetableOccurrenceAddress: TimetableOccurrenceBinding] = [:]
        for requirement in closure.occurrences.required {
            guard bindings.updateValue(requirement.binding, forKey: requirement.binding.address) == nil else {
                throw .targetConflict
            }
        }
        var records: [ConnectionEvidenceRecord] = []
        records.reserveCapacity(targets.count)
        for target in targets {
            let key = ConnectionRelationKey(target)
            guard let from = bindings[target.from], let to = bindings[target.to] else { throw .targetConflict }
            records.append(.init(key: key, fromBinding: from, toBinding: to,
                targetApplicability: target.applicabilityReference, review: authority.review,
                state: try state(authority.entries[key])))
        }
        return try QualifiedConnectionEvidenceView(qualification: qualification, declaredKeys: records.map(\.key),
            completeness: authority.completeness, records: records)
    }

    private static func state(_ entry: PreparedRouteConnectionEntry?) throws(ConnectionEvidenceFailure)
        -> ConnectionEvidenceState {
        switch entry {
        case nil: return .unavailable(.insufficientEvidence)
        case let .unavailable(reason): return .unavailable(reason)
        case let .absence(relation, endpointWideContext, eventIndependent):
            return try .qualifyingAbsence(relation: relation, endpointWideContext: endpointWideContext,
                                          eventIndependent: eventIndependent)
        case let .positive(positive):
            guard let fromArrival = positive.fromArrival, let toDeparture = positive.toDeparture else {
                return .unavailable(.insufficientEvidence)
            }
            let allowance = try ConnectionAllowance(alighting: positive.alighting, interchange: positive.interchange,
                                                    boarding: positive.boarding, total: positive.total)
            return try .qualifyingPositive(form: positive.form, allowance: allowance,
                fromArrival: fromArrival, toDeparture: toDeparture, relation: positive.relation,
                genuineChange: positive.genuineChange, componentPartition: positive.componentPartition,
                endpointWideContext: positive.endpointWideContext)
        }
    }
}
