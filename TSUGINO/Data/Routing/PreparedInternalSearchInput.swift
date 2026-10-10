import Foundation

/// Obligations only, never executable ranking, identity or completion proof.
nonisolated enum InternalRouteObjectiveObligation: Equatable, Sendable {
    case earliestExactFinalArrival, fewerGenuineTrainChanges
    case noInternalThroughServiceChange, allDistinctEqualOptima, reproducibilityOnly
    case optimumAndAllTiesProvedBeforeSuccess, noFirstFound, noFirstK
    case cutoffMeansSearchIncomplete, unknownRequiredEvidenceMeansDataUnavailable
    case selectBeforeFrozenHandoffs, preserveEveryAdmittedWinner
    case mixedWinnerRejectionMeansSearchIncomplete, allRejectedMeansUnscopedNoUsableAlternatives
}

/// Closed supported definition, with exact immutable reference/version binding.
/// A future semantic change requires a new version. No mutable policy lookup or
/// caller-configurable preference; §10.2 identity/comparator remains deferred.
nonisolated struct InternalRouteObjectiveDefinition: Equatable, Sendable {
    enum Version: Equatable, Sendable { case acceptedDEC086V1 }
    let reference: InternalSearchPolicyReference
    let version: Version
    var obligations: [InternalRouteObjectiveObligation] {
        [.earliestExactFinalArrival, .fewerGenuineTrainChanges, .noInternalThroughServiceChange,
         .allDistinctEqualOptima, .reproducibilityOnly, .optimumAndAllTiesProvedBeforeSuccess,
         .noFirstFound, .noFirstK, .cutoffMeansSearchIncomplete, .unknownRequiredEvidenceMeansDataUnavailable,
         .selectBeforeFrozenHandoffs, .preserveEveryAdmittedWinner,
         .mixedWinnerRejectionMeansSearchIncomplete, .allRejectedMeansUnscopedNoUsableAlternatives]
    }
    init(reference: InternalSearchPolicyReference) {
        self.reference = reference; self.version = .acceptedDEC086V1
    }
    func hasSameDefinition(as other: Self) -> Bool {
        reference == other.reference && version == other.version && obligations == other.obligations
    }
}

nonisolated enum PreparedInputFailure: Error, Equatable, Sendable {
    case resourceLimit, assessmentNotQualified, accountingConflict, occurrenceConflict
    case permissionUnknown(occurrence: Int, interval: Int)
    case exactEventMissing(occurrence: Int, interval: Int)
    case canonicalRideConflict(occurrence: Int, interval: Int)
    case arithmeticConflict
}

/// Request-local address/index association, not a persistent or itinerary identity.
nonisolated struct PreparedTimetableRideKey: Hashable, Sendable {
    let address: TimetableOccurrenceAddress
    let boardingIndex: Int
    let alightingIndex: Int
}

nonisolated struct PreparedTimetableRide: Sendable {
    let key: PreparedTimetableRideKey
    let train: TrainCandidate
    let context: TimetableRideContext
    fileprivate init(key: PreparedTimetableRideKey, train: TrainCandidate, context: TimetableRideContext) {
        self.key = key; self.train = train; self.context = context
    }
}

nonisolated enum PreparedIntervalState: Equatable, Sendable {
    case usable(rideIndex: Int)
    case inactive, absentUnderCompleteAuthority, prohibitedEndpoint, outsideScope
}
nonisolated struct PreparedIntervalAccounting: Equatable, Sendable {
    let occurrenceIndex: Int
    let intervalIndex: Int
    let state: PreparedIntervalState
    fileprivate init(occurrenceIndex: Int, intervalIndex: Int, state: PreparedIntervalState) {
        self.occurrenceIndex = occurrenceIndex; self.intervalIndex = intervalIndex; self.state = state
    }
}
nonisolated enum PreparedConnectionState: Equatable, Sendable {
    case feasible, infeasible, absentUnderCompleteAuthority
}
nonisolated struct PreparedConnectionRelation: Sendable {
    let key: ConnectionRelationKey
    /// Exact record in the retained assessment's evidence view. The payload is
    /// retained there once, including form/allowance/events/context/review.
    let evidenceIndex: Int
    let state: PreparedConnectionState
    fileprivate init(key: ConnectionRelationKey, evidenceIndex: Int, state: PreparedConnectionState) {
        self.key = key; self.evidenceIndex = evidenceIndex; self.state = state
    }
}

/// The single production gap-threshold policy. No time conversion or subtraction.
/// Nonzero residual is valid here, unlike the allowance-component exact-sum policy.
nonisolated enum PreparedConnectionGap {
    static func permits(arrival: Double, departure: Double, allowance: Double) throws(PreparedInputFailure) -> Bool {
        guard arrival.isFinite, departure.isFinite, allowance.isFinite, allowance >= 0 else { throw .arithmeticConflict }
        let rounded = arrival + allowance
        if rounded == .infinity { return false } // Positive overflow is known infeasible, before TwoSum residual work.
        guard let addition = ConnectionBinary64Addition.finiteSum(arrival, allowance) else { throw .arithmeticConflict }
        if departure < addition.sum { return false }
        if departure > addition.sum { return true }
        return addition.residual <= 0
    }
}

/// Pure immutable locally prepared input, NOT paths/results/optimum/noResults or
/// an execution-completion certificate. Only B's required declarations are visited.
/// Retains the entire original assessment unchanged. Upstream immutable constructors
/// already bounded/charged every retained text/snapshot before their hashing/equality;
/// new key/token copies are preflighted here before lookup/canonical construction.
///
/// Expected O(I + Q*S + C + P) work, O(I + C + R) temporary keyed storage, S<=72:
/// I inventory slots, Q required intervals, C required relations, R usable rides,
/// P inherited bounded logical payload. No pairwise snapshots, all-pairs, paths or
/// ride-pair Cartesian expansion. Scope/profile/policy interpretation is upstream;
/// real resolution/authentication and Application runtime adoption remain separate.
nonisolated struct PreparedInternalSearchInput: Sendable {
    let assessment: ResolvedSearchInputAssessment
    let objective: InternalRouteObjectiveDefinition
    let rides: [PreparedTimetableRide]
    let intervalAccounting: [PreparedIntervalAccounting]
    let connections: [PreparedConnectionRelation]
    let logicalPayloadBytes: Int
    var scope: InternalSearchScope { assessment.closure.scope }

    init(assessment: ResolvedSearchInputAssessment, objective: InternalRouteObjectiveDefinition)
        throws(PreparedInputFailure) {
        let closure = assessment.closure
        try PreparedInputLimits.checkCounts(occurrences: closure.occurrences.required.count,
            inventory: closure.inventory.slots.count, intervals: 0, relations: closure.connections.required.count, rides: 0)
        guard assessment.isTechnicallyQualified else { throw .assessmentNotQualified }
        guard closure.occurrenceAccounting.count == closure.occurrences.required.count,
              assessment.connectionAccounting.count == closure.connections.required.count else { throw .accountingConflict }
        var budget = PreparedInputPayloadBudget()
        try budget.include(64 + PreparedInputLimits.objectiveBytes)
        // This is the exact constructor-accounted whole assessment, not a caller
        // asserted size or just a reference. No new facts/visit arrays are retained.
        try budget.include(assessment.logicalPayloadBytes)
        var intervalCount = 0
        for req in closure.occurrences.required {
            guard req.intervals.count <= SearchInputClosureLimits.intervalsPerOccurrence,
                  req.intervals.count <= PreparedInputLimits.intervals - intervalCount else { throw .resourceLimit }
            intervalCount += req.intervals.count
        }
        try budget.include(intervalCount * PreparedInputLimits.intervalBytes)
        // Actual newly retained relation keys are charged before any new hashing.
        for target in closure.connections.required {
            try budget.include(48 + PreparedInputAccounting.addressBytes(target.from)
                + PreparedInputAccounting.addressBytes(target.to))
        }
        let loaded = Dictionary(uniqueKeysWithValues: closure.inventory.slots.map { ($0.binding.address, $0) })
        var rides: [PreparedTimetableRide] = []
        var intervals: [PreparedIntervalAccounting] = []
        var rideKeys = Set<PreparedTimetableRideKey>()
        for (oi, req) in closure.occurrences.required.enumerated() {
            let accounting = closure.occurrenceAccounting[oi]
            if case let .active(states) = accounting {
                guard states.count == req.intervals.count else { throw .accountingConflict }
            }
            // One full association check per occurrence, not a scan of all snapshots.
            guard let slot = loaded[req.binding.address], slot.binding.matches(req.binding) else { throw .occurrenceConflict }
            for (ii, interval) in req.intervals.enumerated() {
                let state: PreparedIntervalState
                switch accounting {
                case .held: throw .accountingConflict
                case .inactive:
                    guard case .inactive = slot.state else { throw .occurrenceConflict }
                    state = .inactive
                case let .active(states):
                    guard case let .active(facts, _) = slot.state else { throw .occurrenceConflict }
                    switch states[ii] {
                    case .unknown: throw .accountingConflict
                    case .absentUnderCompleteAuthority: state = .absentUnderCompleteAuthority
                    case .present:
                        let b = interval.boardingIndex, a = interval.alightingIndex
                        guard b >= 0, b < a, a < facts.visits.count else { throw .occurrenceConflict }
                        let board = facts.visits[b], alight = facts.visits[a]
                        if case .prohibited = board.boarding { state = .prohibitedEndpoint }
                        else if case .prohibited = alight.alighting { state = .prohibitedEndpoint }
                        else {
                            guard case .allowed = board.boarding, case .allowed = alight.alighting else {
                                throw .permissionUnknown(occurrence: oi, interval: ii)
                            }
                            guard case let .exact(departure) = board.departure, case let .exact(arrival) = alight.arrival else {
                                throw .exactEventMissing(occurrence: oi, interval: ii)
                            }
                            if !closure.scope.contains(departure.date) || !closure.scope.contains(arrival.date) {
                                state = .outsideScope
                            } else {
                                guard rides.count < PreparedInputLimits.rides else { throw .resourceLimit }
                                // Each actual retained snapshot and address spelling independently
                                // charged; no assumption that String equality or COW implies equal bytes.
                                try budget.include(112 + PreparedInputAccounting.addressBytes(req.binding.address)
                                    + PreparedInputAccounting.tripBytes(slot.binding.trip)
                                    + PreparedInputAccounting.addressBytes(facts.binding.address)
                                    + PreparedInputAccounting.tripBytes(facts.binding.trip))
                                guard let train = TrainCandidate(trip: slot.binding.trip, boardingIndex: b, alightingIndex: a),
                                      let context = TimetableRideContext(train: train, facts: facts) else {
                                    throw .canonicalRideConflict(occurrence: oi, interval: ii)
                                }
                                let key = PreparedTimetableRideKey(address: req.binding.address, boardingIndex: b, alightingIndex: a)
                                guard rideKeys.insert(key).inserted else { throw .accountingConflict }
                                state = .usable(rideIndex: rides.count)
                                rides.append(.init(key: key, train: train, context: context))
                            }
                        }
                    }
                }
                intervals.append(.init(occurrenceIndex: oi, intervalIndex: ii, state: state))
            }
        }
        let records = assessment.connections.records
        let recordIndices = Dictionary(uniqueKeysWithValues: records.indices.map { (records[$0].key, $0) })
        var relations: [PreparedConnectionRelation] = []
        for (i,target) in closure.connections.required.enumerated() {
            let key = ConnectionRelationKey(target)
            guard let index = recordIndices[key] else { throw .accountingConflict }
            let state: PreparedConnectionState
            switch (assessment.connectionAccounting[i], records[index].state) {
            case (.absentUnderCompleteAuthority, .absent): state = .absentUnderCompleteAuthority
            case let (.present, .present(positive)):
                state = try PreparedConnectionGap.permits(arrival: positive.fromArrival.date.timeIntervalSinceReferenceDate,
                    departure: positive.toDeparture.date.timeIntervalSinceReferenceDate, allowance: positive.allowance.total)
                    ? .feasible : .infeasible
            default: throw .accountingConflict
            }
            relations.append(.init(key: key, evidenceIndex: index, state: state))
        }
        self.assessment = assessment; self.objective = objective; self.rides = rides
        self.intervalAccounting = intervals; self.connections = relations; self.logicalPayloadBytes = budget.used
    }

    /// Positive form/allowance/context remains owned by the exact original record,
    /// including when the relation has no usable incident ride. No traversal pairs.
    func positiveEvidence(at connectionIndex: Int) -> ConnectionPositiveEvidence? {
        guard connections.indices.contains(connectionIndex),
              case let .present(positive) = assessment.connections.records[connections[connectionIndex].evidenceIndex].state
        else { return nil }
        return positive
    }
}

/// Overflow-safe logical payload accounting, not heap measurement or solver budget.
nonisolated struct PreparedInputPayloadBudget {
    let limit: Int
    private(set) var used = 0
    init(limit: Int = PreparedInputLimits.logicalPayloadBytes) { self.limit = limit }
    mutating func include(_ bytes: Int) throws(PreparedInputFailure) {
        guard bytes >= 0, used <= limit, bytes <= limit - used else { throw .resourceLimit }
        used += bytes
    }
}

private nonisolated enum PreparedInputAccounting {
    static func textBytes(_ text: String) throws(PreparedInputFailure) -> Int {
        let n = text.utf8.prefix(TimetableInventoryLimits.tokenBytes + 1).count
        guard n <= TimetableInventoryLimits.tokenBytes else { throw .resourceLimit }
        return n
    }
    static func addressBytes(_ a: TimetableOccurrenceAddress) throws(PreparedInputFailure) -> Int {
        try 48 + textBytes(a.tripID.rawValue) + textBytes(a.serviceDate.label)
    }
    static func tripBytes(_ trip: Trip) throws(PreparedInputFailure) -> Int {
        guard trip.stopSequence.count <= TimetableInventoryLimits.stopsPerTrip,
              trip.lineSegments.count < TimetableInventoryLimits.stopsPerTrip,
              trip.serviceTypeSegments.count < TimetableInventoryLimits.stopsPerTrip else { throw .resourceLimit }
        var n = try 48 + textBytes(trip.id.rawValue)
        for stop in trip.stopSequence { n += try 16 + textBytes(stop.rawValue) }
        for line in trip.lineSegments { n += try 32 + textBytes(line.lineID.rawValue) }
        for service in trip.serviceTypeSegments { n += try 32 + textBytes(service.serviceTypeID.rawValue) }
        return n
    }
}

/// Generated invented pre-selection study and rationale: consumer §23. Structural
/// ledger/relation bounds are inherited; new snapshot multiplicity gets a practical
/// ride cap and an independent expanded-payload cap. Not heap or solver capacity.
nonisolated enum PreparedInputLimits {
    static let rides = 4_096
    static let intervals = SearchInputClosureLimits.totalIntervals
    static let relations = ConnectionEvidenceLimits.relations
    static let logicalPayloadBytes = 96_000_000
    static let objectiveBytes = 256 // Closed 14-obligation definition/version + UUID pair, conservative.
    static let intervalBytes = 32   // Two declaration indices + state/tag/optional ride index.

    static func checkCounts(occurrences: Int, inventory: Int, intervals: Int, relations: Int, rides: Int)
        throws(PreparedInputFailure) {
        guard occurrences >= 0, occurrences <= SearchInputClosureLimits.occurrences,
              inventory >= 0, inventory <= TimetableInventoryLimits.addresses,
              intervals >= 0, intervals <= Self.intervals,
              relations >= 0, relations <= Self.relations,
              rides >= 0, rides <= Self.rides else { throw .resourceLimit }
    }
}
