/// Technical construction safeguards only. See consumer proposal §20.6 for the
/// generated invented study, accounting formula and actual implementation tests.
/// None selects a production horizon, solver capacity or launch profile.
nonisolated enum SearchInputClosureLimits {
    static let occurrences = TimetableInventoryLimits.addresses
    static let uniqueTrips = TimetableInventoryLimits.uniqueTrips
    static let serviceDates = TimetableInventoryLimits.serviceDates
    static let stopsPerTrip = TimetableInventoryLimits.stopsPerTrip
    static let intervalsPerOccurrence = TimetableInventoryLimits.intervalsPerOccurrence
    static let totalIntervals = TimetableInventoryLimits.totalIntervals
    static let tokenBytes = TimetableInventoryLimits.tokenBytes
    // Full profile sets are bounded independently of which members happened to load.
    static let profileStations = uniqueTrips * stopsPerTrip
    static let profileLines = uniqueTrips * (stopsPerTrip - 1)
    // Largest measured invented fanout: eight supplied directional targets/address.
    static let connections = 23_040
    // Measured invented ledger: three unresolved categories per recurring Trip.
    static let dependencies = 1_440

    private static let addressBytes = 48 + 2 * tokenBytes
    private static let referenceBytes = 16 + tokenBytes
    private static let bindingBytes = 48 + addressBytes + tokenBytes
        + stopsPerTrip * (16 + tokenBytes) + 2 * (stopsPerTrip - 1) * (32 + tokenBytes)
    private static let qualificationBytes = 16 + 5 * referenceBytes + 80 + tokenBytes + 128
        + TimetableInventoryLimits.staticInputs * (32 + tokenBytes + 64)
    private static let scopeBytes = 160 + 2 * tokenBytes
        + (profileStations + profileLines + uniqueTrips) * (16 + tokenBytes)
    // Conservative expanded logical bytes, not allocator/COW/heap measurement.
    // Includes separately retained scope and all three applicability copies.
    static let logicalPayloadBytes = TimetableInventoryLimits.logicalPayloadBytes + scopeBytes
        + 3 * (scopeBytes + qualificationBytes + referenceBytes)
        + occurrences * (bindingBytes + 2 * referenceBytes + 32)
        + totalIntervals * 16 + connections * (2 * addressBytes + referenceBytes + 32)
        + dependencies * referenceBytes
        + 64 + occurrences * 64 + totalIntervals * 40 + (connections + dependencies) * 32
}

nonisolated enum SearchInputClosureConstructionFailure: Error, Equatable, Sendable {
    case resourceLimit
    case scopeConflict
    case qualificationConflict
    case staticRevisionConflict
    case declarationConflict
    case snapshotConflict
    case intervalConflict
    case profileConflict
    case connectionTargetConflict
}

/// Exact independently stipulated declaration applicability. A printable token
/// identifies authority; possession of it does NOT authenticate source review,
/// legal rights, requiredness, completeness or any railway fact.
nonisolated struct SearchInputClosureApplicability: Sendable {
    let reference: TimetableQualificationReference
    let scope: InternalSearchScope
    let qualification: TimetableInventoryQualification
    let logicalPayloadBytes: Int

    init(reference: TimetableQualificationReference, scope: InternalSearchScope,
         qualification: TimetableInventoryQualification) throws(SearchInputClosureConstructionFailure) {
        let bytes = try ClosureAccounting.scopeBytes(scope)
        guard scope.viewID == qualification.viewID else { throw .qualificationConflict }
        self.reference = reference; self.scope = scope; self.qualification = qualification
        self.logicalPayloadBytes = bytes + ClosureAccounting.qualificationBytes(qualification)
            + 16 + reference.value.text.utf8.count
    }

    fileprivate func check(scope: InternalSearchScope, inventory: TimetableOccurrenceInventoryView)
        throws(SearchInputClosureConstructionFailure) {
        guard self.scope.profile.hasSameDefinition(as: scope.profile),
              self.scope.request.origin == scope.request.origin,
              self.scope.request.destination == scope.request.destination,
              self.scope.request.departNotBefore == scope.request.departNotBefore,
              self.scope.viewID == scope.viewID,
              self.scope.lowerBound == scope.lowerBound, self.scope.upperBound == scope.upperBound else {
            throw .scopeConflict
        }
        guard qualification == inventory.qualification else { throw .qualificationConflict }
    }
}

/// Supplied independently of loaded membership. Full snapshot is an expectation,
/// not a second inventory. Interval obligations apply only if this occurrence is active.
nonisolated struct SearchInputOccurrenceRequirement: Sendable {
    let binding: TimetableOccurrenceBinding
    let applicabilityReference: TimetableQualificationReference
    let intervalAuthority: TimetableQualificationReference
    let intervals: [TimetableVerifiedRideInterval]
}

nonisolated struct SearchInputOccurrenceDeclaration: Sendable {
    let applicability: SearchInputClosureApplicability
    let completeness: TimetableInventoryCompleteness
    let required: [SearchInputOccurrenceRequirement]
}

/// Directional relation target only. No allowance, connection form, geometry,
/// car/door or feasibility evidence. The indices retain their original visit roles.
nonisolated struct SearchInputConnectionTarget: Sendable {
    let from: TimetableOccurrenceAddress
    let alightingIndex: Int
    let to: TimetableOccurrenceAddress
    let boardingIndex: Int
    let applicabilityReference: TimetableQualificationReference
}

nonisolated struct SearchInputConnectionDeclaration: Sendable {
    let applicability: SearchInputClosureApplicability
    let completeness: TimetableInventoryCompleteness
    let required: [SearchInputConnectionTarget]
}

/// Explicit external obligations for this applicability, all unresolved in this
/// slice. There is no asserted resolved bit or invented authority dereference.
nonisolated struct SearchInputDependencyDeclaration: Sendable {
    let applicability: SearchInputClosureApplicability
    let unresolved: [TimetableQualificationReference]
}

/// Indices refer to retained declaration order, never raw diagnostic payloads.
nonisolated enum SearchInputClosureHold: Equatable, Sendable {
    case occurrenceDomainUnknown
    case connectionDomainUnknown
    case occurrenceNotLoaded(Int)
    case occurrenceUnsupported(Int)
    case occurrenceInsufficientEvidence(Int)
    case intervalUnknown(occurrence: Int, interval: Int)
    case connectionUnresolved(Int)
    case dependencyUnresolved(Int)
}

/// Locally accounted obligations retain positive versus qualified-negative reasons.
/// These are input statements, never ride feasibility or route/search results.
nonisolated enum SearchInputOccurrenceAccounting: Equatable, Sendable {
    case active([SearchInputIntervalAccounting])
    case inactive
    case held
}
nonisolated enum SearchInputIntervalAccounting: Equatable, Sendable {
    case present
    case absentUnderCompleteAuthority
    case unknown
}

/// Pure immutable request-relative input accounting under stipulated qualified
/// declarations. No reference authenticates external evidence. Even holds.isEmpty
/// proves neither enumeration, optimum/all ties, noResults nor solver adoption.
///
/// Expected keyed work O(I + R*S + Q*S + C + D + P), where I is the already-bounded
/// inventory address count, R requirements, S <=72 snapshot size, Q supplied interval
/// obligations, C targets, D dependencies, P profile members. No paths/all-pairs or
/// pairwise snapshot comparisons. All top-level counts precede nested work; actual
/// strings/counts/payload precede hashing/full equality. Output order is declaration
/// order: unknown domains, occurrences/intervals, connections, dependencies.
nonisolated struct RequestScopedSearchInputClosure: Sendable {
    let scope: InternalSearchScope
    let inventory: TimetableOccurrenceInventoryView
    let occurrences: SearchInputOccurrenceDeclaration
    let connections: SearchInputConnectionDeclaration
    let dependencies: SearchInputDependencyDeclaration
    let occurrenceAccounting: [SearchInputOccurrenceAccounting]
    let holds: [SearchInputClosureHold]
    let logicalPayloadBytes: Int
    var isTechnicallyQualified: Bool { holds.isEmpty }
    var railway: RailwayArtifactRevision { inventory.qualification.railway }

    init(scope: InternalSearchScope, inventory: TimetableOccurrenceInventoryView,
         railway: RailwayArtifactRevision, occurrences: SearchInputOccurrenceDeclaration,
         connections: SearchInputConnectionDeclaration, dependencies: SearchInputDependencyDeclaration)
        throws(SearchInputClosureConstructionFailure) {
        guard occurrences.required.count <= SearchInputClosureLimits.occurrences,
              connections.required.count <= SearchInputClosureLimits.connections,
              dependencies.unresolved.count <= SearchInputClosureLimits.dependencies else { throw .resourceLimit }
        var budget = SearchInputClosurePayloadBudget()
        try budget.include(ClosureAccounting.scopeBytes(scope))
        try budget.include(inventory.logicalPayloadBytes)
        for applicability in [occurrences.applicability, connections.applicability, dependencies.applicability] {
            try budget.include(applicability.logicalPayloadBytes)
        }
        // Supplied revision is not trusted bounded: preflight it before equality.
        try ClosureAccounting.checkRevision(railway)
        var totalIntervals = 0
        for requirement in occurrences.required {
            guard requirement.intervals.count <= SearchInputClosureLimits.intervalsPerOccurrence,
                  requirement.intervals.count <= SearchInputClosureLimits.totalIntervals - totalIntervals else {
                throw .resourceLimit
            }
            totalIntervals += requirement.intervals.count
            try budget.include(ClosureAccounting.bindingBytes(requirement.binding))
            try budget.include(32 + 16 + requirement.applicabilityReference.value.text.utf8.count
                + 16 + requirement.intervalAuthority.value.text.utf8.count + requirement.intervals.count * 16)
        }
        for target in connections.required {
            try budget.include(32 + ClosureAccounting.addressBytes(target.from) + ClosureAccounting.addressBytes(target.to)
                + 16 + target.applicabilityReference.value.text.utf8.count)
        }
        for reference in dependencies.unresolved { try budget.include(16 + reference.value.text.utf8.count) }
        // Conservative retained outcome/hold slots, including both domain holds.
        try budget.include(64 + occurrences.required.count * 64 + totalIntervals * 40
            + (connections.required.count + dependencies.unresolved.count) * 32)

        guard scope.viewID == inventory.qualification.viewID else { throw .qualificationConflict }
        guard railway == inventory.qualification.railway else { throw .staticRevisionConflict }
        for applicability in [occurrences.applicability, connections.applicability, dependencies.applicability] {
            try applicability.check(scope: scope, inventory: inventory)
        }
        var requiredByAddress: [TimetableOccurrenceAddress: SearchInputOccurrenceRequirement] = [:]
        var representatives: [TripID: Trip] = [:]
        // Inventory has already proved one coherent full snapshot per recurring Trip.
        // Compare even when the independently required date itself was not loaded.
        var loadedRepresentatives: [TripID: Trip] = [:]
        for slot in inventory.slots { loadedRepresentatives[slot.binding.trip.id] = slot.binding.trip }
        var dates = Set<TimetableServiceDate>()
        for requirement in occurrences.required {
            let binding = requirement.binding
            guard binding.address.viewID == scope.viewID,
                  requirement.applicabilityReference == occurrences.applicability.reference else { throw .qualificationConflict }
            guard requiredByAddress.updateValue(requirement, forKey: binding.address) == nil else { throw .declarationConflict }
            if let loadedTrip = loadedRepresentatives[binding.trip.id] {
                guard let comparison = TimetableOccurrenceBinding(address: binding.address, trip: loadedTrip),
                      binding.matches(comparison) else { throw .snapshotConflict }
            }
            dates.insert(binding.address.serviceDate)
            guard dates.count <= SearchInputClosureLimits.serviceDates else { throw .resourceLimit }
            if let trip = representatives[binding.trip.id] {
                guard let comparison = TimetableOccurrenceBinding(address: binding.address, trip: trip),
                      binding.matches(comparison) else { throw .snapshotConflict }
            } else {
                guard representatives.count < SearchInputClosureLimits.uniqueTrips else { throw .resourceLimit }
                representatives[binding.trip.id] = binding.trip
            }
            var intervals = Set<TimetableVerifiedRideInterval>()
            for interval in requirement.intervals {
                let b = interval.boardingIndex, a = interval.alightingIndex
                guard b >= 0, b < a, a < binding.trip.stopSequence.count,
                      binding.trip.stopSequence[b] != binding.trip.stopSequence[a],
                      intervals.insert(interval).inserted else { throw .intervalConflict }
            }
        }
        var seenTargets = Set<ClosureTargetKey>()
        for target in connections.required {
            guard target.applicabilityReference == connections.applicability.reference,
                  target.from.viewID == scope.viewID, target.to.viewID == scope.viewID,
                  let from = requiredByAddress[target.from], let to = requiredByAddress[target.to],
                  target.alightingIndex > 0, target.alightingIndex < from.binding.trip.stopSequence.count,
                  target.boardingIndex >= 0, target.boardingIndex < to.binding.trip.stopSequence.count - 1,
                  seenTargets.insert(ClosureTargetKey(target)).inserted else { throw .connectionTargetConflict }
        }
        var seenDependencies = Set<ExactValue>()
        for reference in dependencies.unresolved {
            guard seenDependencies.insert(reference.value).inserted else { throw .declarationConflict }
        }

        let loaded = Dictionary(uniqueKeysWithValues: inventory.slots.map { ($0.binding.address, $0) })
        var holds: [SearchInputClosureHold] = []
        if occurrences.completeness == .unknown { holds.append(.occurrenceDomainUnknown) }
        if connections.completeness == .unknown { holds.append(.connectionDomainUnknown) }
        var accounting: [SearchInputOccurrenceAccounting] = []
        for (index, requirement) in occurrences.required.enumerated() {
            guard let slot = loaded[requirement.binding.address] else {
                holds.append(.occurrenceNotLoaded(index)); accounting.append(.held); continue
            }
            guard slot.binding.matches(requirement.binding) else { throw .snapshotConflict }
            switch slot.state {
            case .inactive: accounting.append(.inactive)
            case .unavailable(.unsupported):
                holds.append(.occurrenceUnsupported(index)); accounting.append(.held)
            case .unavailable(.insufficientEvidence):
                holds.append(.occurrenceInsufficientEvidence(index)); accounting.append(.held)
            case let .active(_, intervals):
                // Inventory construction already proves exact facts/interval snapshot binding.
                guard requirement.intervalAuthority == intervals.authority else { throw .intervalConflict }
                guard scope.profile.trips.contains(slot.binding.trip.id) else { throw .profileConflict }
                let positive = Set(intervals.declared)
                var intervalAccounting: [SearchInputIntervalAccounting] = []
                for (intervalIndex, interval) in requirement.intervals.enumerated() {
                    let trip = slot.binding.trip, b = interval.boardingIndex, a = interval.alightingIndex
                    guard trip.stopSequence[b...a].allSatisfy(scope.profile.stations.contains),
                          trip.lineSegments.allSatisfy({ segment in
                              !(segment.startIndex < a && b < segment.endIndex)
                                  || scope.profile.lines.contains(segment.lineID)
                          }) else { throw .profileConflict }
                    if positive.contains(interval) { intervalAccounting.append(.present) }
                    else if intervals.completeness == .declaredComplete { intervalAccounting.append(.absentUnderCompleteAuthority) }
                    else {
                        intervalAccounting.append(.unknown)
                        holds.append(.intervalUnknown(occurrence: index, interval: intervalIndex))
                    }
                }
                accounting.append(.active(intervalAccounting))
            }
        }
        holds += connections.required.indices.map(SearchInputClosureHold.connectionUnresolved)
        holds += dependencies.unresolved.indices.map(SearchInputClosureHold.dependencyUnresolved)
        self.scope = scope; self.inventory = inventory; self.occurrences = occurrences
        self.connections = connections; self.dependencies = dependencies
        self.occurrenceAccounting = accounting; self.holds = holds; self.logicalPayloadBytes = budget.used
    }
}

nonisolated struct SearchInputClosurePayloadBudget {
    private(set) var used = 0
    mutating func include(_ bytes: Int) throws(SearchInputClosureConstructionFailure) {
        guard bytes >= 0, bytes <= SearchInputClosureLimits.logicalPayloadBytes - used else { throw .resourceLimit }
        used += bytes
    }
}

private nonisolated struct ClosureTargetKey: Hashable {
    let from: TimetableOccurrenceAddress
    let alight: Int
    let to: TimetableOccurrenceAddress
    let board: Int
    init(_ target: SearchInputConnectionTarget) {
        from = target.from; alight = target.alightingIndex; to = target.to; board = target.boardingIndex
    }
}

private nonisolated enum ClosureAccounting {
    static func textBytes(_ text: String) throws(SearchInputClosureConstructionFailure) -> Int {
        let bytes = text.utf8.prefix(SearchInputClosureLimits.tokenBytes + 1).count
        guard bytes <= SearchInputClosureLimits.tokenBytes else { throw .resourceLimit }
        return bytes
    }
    static func scopeBytes(_ scope: InternalSearchScope) throws(SearchInputClosureConstructionFailure) -> Int {
        let profile = scope.profile
        guard profile.stations.count <= SearchInputClosureLimits.profileStations,
              profile.lines.count <= SearchInputClosureLimits.profileLines,
              profile.trips.count <= SearchInputClosureLimits.uniqueTrips else { throw .resourceLimit }
        var bytes = try 160 + textBytes(scope.request.origin.rawValue) + textBytes(scope.request.destination.rawValue)
        for id in profile.stations { bytes += try 16 + textBytes(id.rawValue) }
        for id in profile.lines { bytes += try 16 + textBytes(id.rawValue) }
        for id in profile.trips { bytes += try 16 + textBytes(id.rawValue) }
        return bytes
    }
    static func addressBytes(_ address: TimetableOccurrenceAddress) throws(SearchInputClosureConstructionFailure) -> Int {
        try 48 + textBytes(address.tripID.rawValue) + textBytes(address.serviceDate.label)
    }
    static func bindingBytes(_ binding: TimetableOccurrenceBinding) throws(SearchInputClosureConstructionFailure) -> Int {
        let trip = binding.trip
        guard trip.stopSequence.count <= SearchInputClosureLimits.stopsPerTrip,
              trip.lineSegments.count < SearchInputClosureLimits.stopsPerTrip,
              trip.serviceTypeSegments.count < SearchInputClosureLimits.stopsPerTrip else { throw .resourceLimit }
        var bytes = try 48 + addressBytes(binding.address) + textBytes(trip.id.rawValue)
        for stop in trip.stopSequence { bytes += try 16 + textBytes(stop.rawValue) }
        for segment in trip.lineSegments { bytes += try 32 + textBytes(segment.lineID.rawValue) }
        for segment in trip.serviceTypeSegments { bytes += try 32 + textBytes(segment.serviceTypeID.rawValue) }
        return bytes
    }
    static func checkRevision(_ railway: RailwayArtifactRevision) throws(SearchInputClosureConstructionFailure) {
        guard railway.inputs.count <= TimetableInventoryLimits.staticInputs else { throw .resourceLimit }
        _ = try textBytes(railway.dataVersion.text)
        _ = try textBytes(railway.contentSHA256)
        if let previous = railway.previousSHA256 { _ = try textBytes(previous) }
        for input in railway.inputs { _ = try textBytes(input.role); _ = try textBytes(input.sha256) }
    }
    static func qualificationBytes(_ q: TimetableInventoryQualification) -> Int {
        16 + [q.source, q.profile, q.zone, q.mapping, q.review].reduce(0) { $0 + 16 + $1.value.text.utf8.count }
            + 80 + q.railway.dataVersion.text.utf8.count + q.railway.contentSHA256.utf8.count
            + (q.railway.previousSHA256?.utf8.count ?? 0)
            + q.railway.inputs.reduce(0) { $0 + 32 + $1.role.utf8.count + $1.sha256.utf8.count }
    }
}
