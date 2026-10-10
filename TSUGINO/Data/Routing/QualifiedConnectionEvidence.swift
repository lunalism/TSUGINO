/// Generated invented study and accounting: consumer §21.11. Technical
/// safeguards only, not product horizon, heap guarantee or solver capacity.
nonisolated enum ConnectionEvidenceLimits {
    // Selected measured shape; the study also exercised 25% more relations.
    static let relations = 2_048
    private static let addressBytes = 48 + 2 * TimetableInventoryLimits.tokenBytes
    private static let keyBytes = 16 + 2 * addressBytes
    private static let referenceBytes = 16 + TimetableInventoryLimits.tokenBytes
    private static let bindingBytes = 48 + addressBytes + TimetableInventoryLimits.tokenBytes
        + TimetableInventoryLimits.stopsPerTrip * (16 + TimetableInventoryLimits.tokenBytes)
        + 2 * (TimetableInventoryLimits.stopsPerTrip - 1) * (32 + TimetableInventoryLimits.tokenBytes)
    private static let inventoryQualificationBytes = 16 + 5 * referenceBytes + 80
        + TimetableInventoryLimits.tokenBytes + 128
        + TimetableInventoryLimits.staticInputs * (32 + TimetableInventoryLimits.tokenBytes + 64)
    private static let scopeBytes = 160 + 2 * TimetableInventoryLimits.tokenBytes
        + (SearchInputClosureLimits.profileStations + SearchInputClosureLimits.profileLines
            + SearchInputClosureLimits.uniqueTrips) * (16 + TimetableInventoryLimits.tokenBytes)
    static let viewPayloadBytes = 64 + scopeBytes + inventoryQualificationBytes + 2 * referenceBytes + 32
        + relations * (2 * keyBytes + 2 * bindingBytes + 32 + 2 * referenceBytes + 64 + 4 * referenceBytes)
    private static let closureHoldSlots = 2 + SearchInputClosureLimits.occurrences
        + SearchInputClosureLimits.totalIntervals + SearchInputClosureLimits.connections + SearchInputClosureLimits.dependencies
    static let assessmentPayloadBytes = SearchInputClosureLimits.logicalPayloadBytes + viewPayloadBytes
        + 64 + relations * 64 + closureHoldSlots * 32
}

/// Local supplied-input consistency only. References do not authenticate source
/// review, policy contents, legal rights or completeness. No requiredness or search.
nonisolated enum ConnectionEvidenceFailure: Error, Equatable, Sendable {
    case resourceLimit, qualificationConflict, policyConflict, declarationConflict
    case targetConflict, snapshotConflict, formConflict, trainChangeConflict
    case allowanceConflict, applicabilityConflict, endpointConflict
}

nonisolated struct ConnectionRelationKey: Hashable, Sendable {
    let from: TimetableOccurrenceAddress
    let alightingIndex: Int
    let to: TimetableOccurrenceAddress
    let boardingIndex: Int

    init(from: TimetableOccurrenceAddress, alightingIndex: Int,
         to: TimetableOccurrenceAddress, boardingIndex: Int) {
        self.from = from; self.alightingIndex = alightingIndex
        self.to = to; self.boardingIndex = boardingIndex
    }
    init(_ target: SearchInputConnectionTarget) {
        self.init(from: target.from, alightingIndex: target.alightingIndex,
                  to: target.to, boardingIndex: target.boardingIndex)
    }
}
nonisolated enum ConnectionForm: Equatable, Sendable { case sameStation, walking }
nonisolated enum ConnectionUnavailableReason: Equatable, Sendable { case unsupported, insufficientEvidence }

/// Explicit examination input, never a verified Bool. Qualified means a supplied
/// stipulated premise with this exact association, not authentication by a token.
nonisolated enum ConnectionEvidencePremise: Sendable {
    case qualified(TimetableQualificationReference)
    case unsupported
    case insufficientEvidence
    case contradictory
}

/// Seconds, with all applicable access/walk requirements partitioned into
/// interchange exactly once. Numerical equality cannot prove that partition.
nonisolated struct ConnectionAllowance: Equatable, Sendable {
    let alighting: Double
    let interchange: Double
    let boarding: Double
    let total: Double

    init(alighting: Double, interchange: Double, boarding: Double, total: Double)
        throws(ConnectionEvidenceFailure) {
        guard [alighting, interchange, boarding, total].allSatisfy({ $0.isFinite && $0 >= 0 }),
              let subtotal = Self.exactSum(alighting, interchange),
              let sum = Self.exactSum(subtotal, boarding), sum == total else { throw .allowanceConflict }
        self.alighting = alighting == 0 ? 0 : alighting
        self.interchange = interchange == 0 ? 0 : interchange
        self.boarding = boarding == 0 ? 0 : boarding
        self.total = total == 0 ? 0 : total
    }
    private static func exactSum(_ a: Double, _ b: Double) -> Double? {
        let sum = a + b
        let bv = sum - a, av = sum - bv
        let ae = a - av, be = b - bv
        let residual = ae + be
        guard [sum, bv, av, ae, be, residual].allSatisfy(\.isFinite), residual == 0 else { return nil }
        return sum
    }
}

nonisolated struct ConnectionEvidenceQualification: Sendable {
    let applicability: SearchInputClosureApplicability
    let policy: InternalSearchPolicyReference
    let review: TimetableQualificationReference
    let logicalPayloadBytes: Int

    init(applicability: SearchInputClosureApplicability, policy: InternalSearchPolicyReference,
         review: TimetableQualificationReference) throws(ConnectionEvidenceFailure) {
        guard policy == applicability.scope.profile.connectionPolicy else { throw .policyConflict }
        self.applicability = applicability; self.policy = policy; self.review = review
        self.logicalPayloadBytes = applicability.logicalPayloadBytes + 32 + 16 + review.value.text.utf8.count
    }
}

/// Only State's checked factories can supply these qualified premises. The
/// endpoint-wide assertion covers every supported incident ridden interval under
/// the exact full snapshots/profile/policy. No adjacent-line inference is made.
nonisolated struct ConnectionPositiveEvidence: Sendable {
    let form: ConnectionForm
    let allowance: ConnectionAllowance
    let fromArrival: TimetableInstant
    let toDeparture: TimetableInstant
    let relation: TimetableQualificationReference
    let genuineChange: TimetableQualificationReference
    let componentPartition: TimetableQualificationReference
    let endpointWideContext: TimetableQualificationReference
    fileprivate init(form: ConnectionForm, allowance: ConnectionAllowance,
                     fromArrival: TimetableInstant, toDeparture: TimetableInstant,
                     references: [TimetableQualificationReference]) {
        self.form = form; self.allowance = allowance
        self.fromArrival = fromArrival; self.toDeparture = toDeparture
        relation = references[0]; genuineChange = references[1]
        componentPartition = references[2]; endpointWideContext = references[3]
    }
}
nonisolated struct ConnectionNegativeEvidence: Sendable {
    let relation: TimetableQualificationReference
    let endpointWideContext: TimetableQualificationReference
    /// Covers the entire exact dated endpoint pair independently of event values.
    let eventIndependent: TimetableQualificationReference
    fileprivate init(references: [TimetableQualificationReference]) {
        relation = references[0]; endpointWideContext = references[1]; eventIndependent = references[2]
    }
}
nonisolated enum ConnectionEvidenceState: Sendable {
    case present(ConnectionPositiveEvidence)
    case absent(ConnectionNegativeEvidence)
    case unavailable(ConnectionUnavailableReason)

    static func qualifyingPositive(form: ConnectionForm, allowance: ConnectionAllowance,
                                   fromArrival: TimetableInstant, toDeparture: TimetableInstant,
                                   relation: ConnectionEvidencePremise, genuineChange: ConnectionEvidencePremise,
                                   componentPartition: ConnectionEvidencePremise,
                                   endpointWideContext: ConnectionEvidencePremise)
        throws(ConnectionEvidenceFailure) -> Self {
        let premises: [(ConnectionEvidencePremise, ConnectionEvidenceFailure)] = [
            (relation, .qualificationConflict), (genuineChange, .trainChangeConflict),
            (componentPartition, .allowanceConflict), (endpointWideContext, .applicabilityConflict)]
        if let held = try unavailable(premises) { return .unavailable(held) }
        return .present(.init(form: form, allowance: allowance, fromArrival: fromArrival,
                              toDeparture: toDeparture, references: references(premises)))
    }
    static func qualifyingAbsence(relation: ConnectionEvidencePremise,
                                  endpointWideContext: ConnectionEvidencePremise,
                                  eventIndependent: ConnectionEvidencePremise)
        throws(ConnectionEvidenceFailure) -> Self {
        let premises: [(ConnectionEvidencePremise, ConnectionEvidenceFailure)] = [
            (relation, .qualificationConflict), (endpointWideContext, .applicabilityConflict),
            (eventIndependent, .applicabilityConflict)]
        if let held = try unavailable(premises) { return .unavailable(held) }
        return .absent(.init(references: references(premises)))
    }
    private static func unavailable(_ premises: [(ConnectionEvidencePremise, ConnectionEvidenceFailure)])
        throws(ConnectionEvidenceFailure) -> ConnectionUnavailableReason? {
        var reason: ConnectionUnavailableReason?
        for (premise, failure) in premises {
            switch premise {
            case .contradictory: throw failure
            case .unsupported: reason = .unsupported
            case .insufficientEvidence: if reason == nil { reason = .insufficientEvidence }
            case .qualified: break
            }
        }
        return reason
    }
    private static func references(_ premises: [(ConnectionEvidencePremise, ConnectionEvidenceFailure)])
        -> [TimetableQualificationReference] {
        premises.compactMap { if case let .qualified(reference) = $0.0 { reference } else { nil } }
    }
}

/// Supplied record; the view atomically validates association before anchors can
/// be indexed. Target applicability is separate from the four-field identity.
nonisolated struct ConnectionEvidenceRecord: Sendable {
    let key: ConnectionRelationKey
    let fromBinding: TimetableOccurrenceBinding
    let toBinding: TimetableOccurrenceBinding
    let targetApplicability: TimetableQualificationReference
    let review: TimetableQualificationReference
    let state: ConnectionEvidenceState
}

/// Finite independent evidence scope, not request-requiredness authority. One
/// explicit state per declared key, including unknown scopes. No omission negatives.
nonisolated struct QualifiedConnectionEvidenceView: Sendable {
    let qualification: ConnectionEvidenceQualification
    let declaredKeys: [ConnectionRelationKey]
    let completeness: TimetableInventoryCompleteness
    let records: [ConnectionEvidenceRecord]
    let logicalPayloadBytes: Int

    /// Expected O(N*S + P), S<=72, using full-snapshot representatives and keys.
    /// Actual copies/spellings charged before hashing; no pair/context expansion.
    init(qualification: ConnectionEvidenceQualification, declaredKeys: [ConnectionRelationKey],
         completeness: TimetableInventoryCompleteness, records: [ConnectionEvidenceRecord])
        throws(ConnectionEvidenceFailure) {
        guard declaredKeys.count <= ConnectionEvidenceLimits.relations,
              records.count <= ConnectionEvidenceLimits.relations else { throw .resourceLimit }
        var budget = ConnectionEvidencePayloadBudget(limit: ConnectionEvidenceLimits.viewPayloadBytes)
        try budget.include(64 + qualification.logicalPayloadBytes)
        for key in declaredKeys { try budget.include(ConnectionAccounting.keyBytes(key)) }
        for record in records {
            try budget.include(ConnectionAccounting.keyBytes(record.key))
            try budget.include(ConnectionAccounting.bindingBytes(record.fromBinding))
            try budget.include(ConnectionAccounting.bindingBytes(record.toBinding))
            try budget.include(32 + ConnectionAccounting.referenceBytes(record.targetApplicability)
                + ConnectionAccounting.referenceBytes(record.review) + ConnectionAccounting.stateBytes(record.state))
        }
        let viewID = qualification.applicability.scope.viewID
        var declared = Set<ConnectionRelationKey>()
        for key in declaredKeys {
            guard key.from.viewID == viewID, key.to.viewID == viewID,
                  declared.insert(key).inserted else { throw .declarationConflict }
        }
        var seen = Set<ConnectionRelationKey>()
        var representatives: [TripID: Trip] = [:]
        for record in records {
            let key = record.key
            guard declared.contains(key), seen.insert(key).inserted else { throw .declarationConflict }
            guard record.review == qualification.review,
                  record.targetApplicability == qualification.applicability.reference else { throw .qualificationConflict }
            guard record.fromBinding.address == key.from, record.toBinding.address == key.to,
                  key.alightingIndex > 0, key.alightingIndex < record.fromBinding.trip.stopSequence.count,
                  key.boardingIndex >= 0, key.boardingIndex < record.toBinding.trip.stopSequence.count - 1
            else { throw .targetConflict }
            for binding in [record.fromBinding, record.toBinding] {
                if let trip = representatives[binding.trip.id] {
                    guard let comparison = TimetableOccurrenceBinding(address: binding.address, trip: trip),
                          binding.matches(comparison) else { throw .snapshotConflict }
                } else { representatives[binding.trip.id] = binding.trip }
            }
            if case let .present(positive) = record.state {
                guard record.fromBinding.trip.id != record.toBinding.trip.id else { throw .trainChangeConflict }
                let equal = record.fromBinding.trip.stopSequence[key.alightingIndex]
                    == record.toBinding.trip.stopSequence[key.boardingIndex]
                guard (positive.form == .sameStation) == equal else { throw .formConflict }
            }
        }
        guard seen.count == declared.count else { throw .declarationConflict }
        self.qualification = qualification; self.declaredKeys = declaredKeys
        self.completeness = completeness; self.records = records; self.logicalPayloadBytes = budget.used
    }
}

nonisolated enum ConnectionAssessmentHold: Equatable, Sendable {
    case unsupported, insufficientEvidence, negativeScopeUnknown
    case endpointNotLoaded, endpointInactive, endpointUnsupported, endpointInsufficientEvidence
    case exactEventMissing, permissionUnknown
}
nonisolated enum ConnectionAssessmentAccounting: Equatable, Sendable {
    case present, absentUnderCompleteAuthority, held(ConnectionAssessmentHold)
    fileprivate var resolved: Bool {
        switch self { case .present, .absentUnderCompleteAuthority: true; case .held: false }
    }
}

/// Retains the original B closure unchanged. Only specifically resolved target
/// holds are removed from this assessment. Technical readiness is NOT search,
/// train-gap feasibility, optimum/all ties, noResults or runtime adoption.
nonisolated struct ResolvedSearchInputAssessment: Sendable {
    let closure: RequestScopedSearchInputClosure
    let connections: QualifiedConnectionEvidenceView
    let connectionAccounting: [ConnectionAssessmentAccounting]
    let remainingHolds: [SearchInputClosureHold]
    let logicalPayloadBytes: Int
    var isTechnicallyQualified: Bool { remainingHolds.isEmpty }

    /// Expected O(I + R + N*S + P + H), keyed, no pairwise snapshots/paths.
    init(closure: RequestScopedSearchInputClosure, connections: QualifiedConnectionEvidenceView)
        throws(ConnectionEvidenceFailure) {
        guard closure.connections.required.count <= ConnectionEvidenceLimits.relations else { throw .resourceLimit }
        var budget = ConnectionEvidencePayloadBudget(limit: ConnectionEvidenceLimits.assessmentPayloadBytes)
        try budget.include(closure.logicalPayloadBytes)
        try budget.include(connections.logicalPayloadBytes)
        try budget.include(64 + closure.connections.required.count * 64 + closure.holds.count * 32)
        let a = connections.qualification.applicability, b = closure.connections.applicability
        guard a.reference == b.reference, a.scope.profile.hasSameDefinition(as: closure.scope.profile),
              a.scope.request.origin == closure.scope.request.origin,
              a.scope.request.destination == closure.scope.request.destination,
              a.scope.request.departNotBefore == closure.scope.request.departNotBefore,
              a.scope.lowerBound == closure.scope.lowerBound, a.scope.upperBound == closure.scope.upperBound,
              a.scope.viewID == closure.scope.viewID, a.qualification == closure.inventory.qualification
        else { throw .qualificationConflict }
        guard connections.qualification.policy == closure.scope.profile.connectionPolicy else { throw .policyConflict }
        let expected = Dictionary(uniqueKeysWithValues: closure.occurrences.required.map { ($0.binding.address, $0.binding) })
        let records = Dictionary(uniqueKeysWithValues: connections.records.map { ($0.key, $0) })
        guard records.count == closure.connections.required.count else { throw .targetConflict }
        let loaded = Dictionary(uniqueKeysWithValues: closure.inventory.slots.map { ($0.binding.address, $0) })
        var accounting: [ConnectionAssessmentAccounting] = []
        for target in closure.connections.required {
            guard let record = records[ConnectionRelationKey(target)],
                  record.targetApplicability == target.applicabilityReference else { throw .targetConflict }
            guard let from = expected[target.from], let to = expected[target.to],
                  record.fromBinding.matches(from), record.toBinding.matches(to) else { throw .snapshotConflict }
            switch record.state {
            case .unavailable(.unsupported): accounting.append(.held(.unsupported))
            case .unavailable(.insufficientEvidence): accounting.append(.held(.insufficientEvidence))
            case .absent:
                accounting.append(connections.completeness == .declaredComplete
                    ? .absentUnderCompleteAuthority : .held(.negativeScopeUnknown))
            case let .present(positive):
                accounting.append(try Self.positive(positive, target: target, loaded: loaded))
            }
        }
        let holds = closure.holds.filter { hold in
            if case let .connectionUnresolved(index) = hold { return !accounting[index].resolved }
            return true
        }
        self.closure = closure; self.connections = connections; self.connectionAccounting = accounting
        self.remainingHolds = holds; self.logicalPayloadBytes = budget.used
    }

    private static func positive(_ positive: ConnectionPositiveEvidence, target: SearchInputConnectionTarget,
                                 loaded: [TimetableOccurrenceAddress: TimetableOccurrenceInventorySlot])
        throws(ConnectionEvidenceFailure) -> ConnectionAssessmentAccounting {
        // Check both endpoints for known contradictions even when the other is held.
        var hold: ConnectionAssessmentHold?
        for (address, index, arrival, instant) in [
            (target.from, target.alightingIndex, true, positive.fromArrival),
            (target.to, target.boardingIndex, false, positive.toDeparture)] {
            var local: ConnectionAssessmentHold?
            if let slot = loaded[address] {
                switch slot.state {
                case .inactive: local = .endpointInactive
                case .unavailable(.unsupported): local = .endpointUnsupported
                case .unavailable(.insufficientEvidence): local = .endpointInsufficientEvidence
                case let .active(facts, _):
                    let visit = facts.visits[index]
                    let permission = arrival ? visit.alighting : visit.boarding
                    switch permission {
                    case .prohibited: throw .endpointConflict
                    case .unknown: local = .permissionUnknown
                    case .allowed: break
                    }
                    let time = arrival ? visit.arrival : visit.departure
                    if case let .exact(actual) = time {
                        guard actual == instant else { throw .applicabilityConflict }
                    } else if local == nil { local = .exactEventMissing }
                }
            } else { local = .endpointNotLoaded }
            if hold == nil { hold = local }
        }
        return hold.map { .held($0) } ?? .present
    }
}

nonisolated struct ConnectionEvidencePayloadBudget {
    let limit: Int
    private(set) var used = 0
    mutating func include(_ bytes: Int) throws(ConnectionEvidenceFailure) {
        guard bytes >= 0, used <= limit, bytes <= limit - used else { throw .resourceLimit }
        used += bytes
    }
}

private nonisolated enum ConnectionAccounting {
    static func textBytes(_ text: String) throws(ConnectionEvidenceFailure) -> Int {
        let bytes = text.utf8.prefix(TimetableInventoryLimits.tokenBytes + 1).count
        guard bytes <= TimetableInventoryLimits.tokenBytes else { throw .resourceLimit }
        return bytes
    }
    static func referenceBytes(_ ref: TimetableQualificationReference) -> Int { 16 + ref.value.text.utf8.count }
    static func addressBytes(_ address: TimetableOccurrenceAddress) throws(ConnectionEvidenceFailure) -> Int {
        try 48 + textBytes(address.tripID.rawValue) + textBytes(address.serviceDate.label)
    }
    static func keyBytes(_ key: ConnectionRelationKey) throws(ConnectionEvidenceFailure) -> Int {
        try 16 + addressBytes(key.from) + addressBytes(key.to)
    }
    static func bindingBytes(_ binding: TimetableOccurrenceBinding) throws(ConnectionEvidenceFailure) -> Int {
        let trip = binding.trip
        guard trip.stopSequence.count <= TimetableInventoryLimits.stopsPerTrip,
              trip.lineSegments.count < TimetableInventoryLimits.stopsPerTrip,
              trip.serviceTypeSegments.count < TimetableInventoryLimits.stopsPerTrip else { throw .resourceLimit }
        var bytes = try 48 + addressBytes(binding.address) + textBytes(trip.id.rawValue)
        for stop in trip.stopSequence { bytes += try 16 + textBytes(stop.rawValue) }
        for segment in trip.lineSegments { bytes += try 32 + textBytes(segment.lineID.rawValue) }
        for segment in trip.serviceTypeSegments { bytes += try 32 + textBytes(segment.serviceTypeID.rawValue) }
        return bytes
    }
    static func stateBytes(_ state: ConnectionEvidenceState) -> Int {
        switch state {
        case let .present(p):
            64 + [p.relation, p.genuineChange, p.componentPartition, p.endpointWideContext].reduce(0) { $0 + referenceBytes($1) }
        case let .absent(n):
            16 + [n.relation, n.endpointWideContext, n.eventIndependent].reduce(0) { $0 + referenceBytes($1) }
        case .unavailable: 16
        }
    }
}
