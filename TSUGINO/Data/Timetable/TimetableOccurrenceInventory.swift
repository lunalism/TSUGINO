/// Technical construction safeguards, not network coverage or solver capacity.
/// Invented study and headroom: producer proposal §17 (2026-10-10).
nonisolated enum TimetableInventoryLimits {
    static let addresses = 2_880
    static let uniqueTrips = 480
    static let serviceDates = 6
    static let stopsPerTrip = 72
    static let intervalsPerOccurrence = 48
    static let totalIntervals = 92_160
    static let tokenBytes = 192
    // Existing RailwayArtifact revision-format bound, not an importer limit.
    static let staticInputs = 32
    static let logicalPayloadBytes = 120_000_000
}

/// Exact printable ASCII, without whitespace, normalization or source interpretation.
/// An opaque association reference; possession does not authenticate evidence.
nonisolated struct TimetableQualificationReference: Equatable, Sendable {
    let value: ExactValue

    init?(_ text: String) {
        guard text.utf8.prefix(TimetableInventoryLimits.tokenBytes + 1).count <= TimetableInventoryLimits.tokenBytes,
              !text.isEmpty, text.utf8.allSatisfy({ (33...126).contains($0) }),
              let value = ExactValue(text) else { return nil }
        self.value = value
    }
}

/// Supplied qualified compatibility, NOT authentication or runtime availability.
/// All slots must carry this exact value, including the unchanged static revision.
nonisolated struct TimetableInventoryQualification: Equatable, Sendable {
    let viewID: TimetableViewID
    let source: TimetableQualificationReference
    let profile: TimetableQualificationReference
    let zone: TimetableQualificationReference
    let mapping: TimetableQualificationReference
    let review: TimetableQualificationReference
    let railway: RailwayArtifactRevision

    init?(viewID: TimetableViewID, source: TimetableQualificationReference,
          profile: TimetableQualificationReference, zone: TimetableQualificationReference,
          mapping: TimetableQualificationReference, review: TimetableQualificationReference,
          railway: RailwayArtifactRevision) {
        guard railway.inputs.count <= TimetableInventoryLimits.staticInputs,
              Self.bounded(railway.dataVersion.text), railway.registryRevision >= 0,
              Self.hashSyntax(railway.contentSHA256),
              railway.previousSHA256.map(Self.hashSyntax) ?? true,
              railway.inputs.allSatisfy({
                  TimetableQualificationReference($0.role) != nil && Self.hashSyntax($0.sha256)
              }) else { return nil }
        self.viewID = viewID; self.source = source; self.profile = profile
        self.zone = zone; self.mapping = mapping; self.review = review; self.railway = railway
    }

    fileprivate static func bounded(_ text: String) -> Bool {
        text.utf8.prefix(TimetableInventoryLimits.tokenBytes + 1).count <= TimetableInventoryLimits.tokenBytes
    }

    private static func hashSyntax(_ text: String) -> Bool {
        text.utf8.prefix(65).count == 64
            && text.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) })
    }

    fileprivate var logicalBytes: Int {
        16 + [source, profile, zone, mapping, review].reduce(0) { $0 + 16 + $1.value.text.utf8.count }
            + 80 + railway.dataVersion.text.utf8.count + railway.contentSHA256.utf8.count
            + (railway.previousSHA256?.utf8.count ?? 0)
            + railway.inputs.reduce(0) { $0 + 32 + $1.role.utf8.count + $1.sha256.utf8.count }
    }
}

/// Applies only to the supplied finite declaration under its qualification scope.
/// Unknown still requires one slot per declared address. Neither case proves search completeness.
nonisolated enum TimetableInventoryCompleteness: Equatable, Sendable {
    case declaredComplete
    case unknown
}

/// Explicit supplied original-index declaration; validated only by the inventory constructor.
/// No intervals are inferred from Trip structure or scheduled endpoint usability.
nonisolated struct TimetableVerifiedRideInterval: Equatable, Hashable, Sendable {
    let boardingIndex: Int
    let alightingIndex: Int
}

/// Shared exact binding/authority for every interval, avoiding repeated snapshot ownership.
/// Complete empty means no positive interval declaration under this exact authority only.
/// Unknown empty supplies no negative ride or route conclusion.
nonisolated struct TimetableOccurrenceIntervals: Sendable {
    let binding: TimetableOccurrenceBinding
    let authority: TimetableQualificationReference
    let completeness: TimetableInventoryCompleteness
    let declared: [TimetableVerifiedRideInterval]
}

nonisolated enum TimetableInventoryUnavailableReason: Equatable, CaseIterable, Sendable {
    case unsupported
    case insufficientEvidence
}

nonisolated enum TimetableInventoryOccurrenceState: Sendable {
    case active(TimetableOccurrenceFacts, TimetableOccurrenceIntervals)
    case inactive
    // Source-neutral qualification holds, distinct from diagnostic structural defects.
    case unavailable(TimetableInventoryUnavailableReason)
}

/// Supplied input value; association is established atomically by InventoryView, not this memberwise init.
nonisolated struct TimetableOccurrenceInventorySlot: Sendable {
    let qualification: TimetableInventoryQualification
    let binding: TimetableOccurrenceBinding
    let state: TimetableInventoryOccurrenceState
}

nonisolated enum TimetableInventoryConstructionFailure: Error, Equatable, Sendable {
    case resourceLimit
    case declarationConflict
    case slotAssociation
    case qualificationConflict
    case staticRevisionConflict
    case snapshotConflict
    case factsConflict
    case intervalConflict
}

/// Overflow-safe logical accounting, independent of allocator/COW behavior. Not measured heap usage.
nonisolated struct TimetableInventoryPayloadBudget {
    private(set) var used = 0

    mutating func include(_ bytes: Int) throws(TimetableInventoryConstructionFailure) {
        guard bytes >= 0, bytes <= TimetableInventoryLimits.logicalPayloadBytes - used else {
            throw .resourceLimit
        }
        used += bytes
    }
}

/// Pure immutable Data input: no source interpretation, IO, activation, solver, connection or runtime owner.
/// Preserves declaration order; all defects fail atomically. Trip equality is never snapshot equality.
nonisolated struct TimetableOccurrenceInventoryView: Sendable {
    let qualification: TimetableInventoryQualification
    let declaredAddresses: [TimetableOccurrenceAddress]
    let completeness: TimetableInventoryCompleteness
    let slots: [TimetableOccurrenceInventorySlot]
    let logicalPayloadBytes: Int

    init(qualification: TimetableInventoryQualification,
         declaredAddresses: [TimetableOccurrenceAddress], completeness: TimetableInventoryCompleteness,
         suppliedSlots: [TimetableOccurrenceInventorySlot]) throws(TimetableInventoryConstructionFailure) {
        // O(1) top-level guards precede all hashing, allocation and nested traversal.
        guard declaredAddresses.count <= TimetableInventoryLimits.addresses,
              suppliedSlots.count <= TimetableInventoryLimits.addresses else { throw .resourceLimit }
        var budget = TimetableInventoryPayloadBudget()
        try budget.include(qualification.logicalBytes)
        // Bounded text/count/payload preflight BEFORE association hashing/full snapshot comparisons.
        for address in declaredAddresses { try budget.include(Self.addressBytes(address)) }
        var intervalCount = 0
        for slot in suppliedSlots {
            try budget.include(slot.qualification.logicalBytes)
            try budget.include(Self.bindingBytes(slot.binding))
            if case let .active(facts, intervals) = slot.state {
                guard facts.visits.count <= TimetableInventoryLimits.stopsPerTrip,
                      intervals.declared.count <= TimetableInventoryLimits.intervalsPerOccurrence,
                      intervals.declared.count <= TimetableInventoryLimits.totalIntervals - intervalCount else {
                    throw .resourceLimit
                }
                intervalCount += intervals.declared.count
                let factsBytes = try Self.bindingBytes(facts.binding)
                try budget.include(factsBytes)
                // Domain equality admits canonically equivalent Unicode with different UTF-8 spellings.
                // Account/bound each actual retained visit binding, without revalidating association
                // or chronology (already established by Domain facts construction).
                for visit in facts.visits {
                    try budget.include(136 + Self.bindingBytes(visit.binding))
                }
                try budget.include(Self.bindingBytes(intervals.binding))
                try budget.include(32 + intervals.authority.value.text.utf8.count + intervals.declared.count * 16)
            }
        }

        var declared = Set<TimetableOccurrenceAddress>()
        var dates = Set<TimetableServiceDate>()
        for address in declaredAddresses {
            guard address.viewID == qualification.viewID else { throw .qualificationConflict }
            guard declared.insert(address).inserted else { throw .declarationConflict }
            dates.insert(address.serviceDate)
            guard dates.count <= TimetableInventoryLimits.serviceDates else { throw .resourceLimit }
        }
        var byAddress: [TimetableOccurrenceAddress: TimetableOccurrenceInventorySlot] = [:]
        var representatives: [TripID: Trip] = [:]
        for slot in suppliedSlots {
            let binding = slot.binding
            guard slot.qualification.railway == qualification.railway else { throw .staticRevisionConflict }
            guard slot.qualification == qualification, binding.address.viewID == qualification.viewID else {
                throw .qualificationConflict
            }
            guard declared.contains(binding.address), byAddress.updateValue(slot, forKey: binding.address) == nil else {
                throw .slotAssociation
            }
            if let representative = representatives[binding.trip.id] {
                guard let comparison = TimetableOccurrenceBinding(address: binding.address, trip: representative),
                      binding.matches(comparison) else { throw .snapshotConflict }
            } else {
                guard representatives.count < TimetableInventoryLimits.uniqueTrips else { throw .resourceLimit }
                representatives[binding.trip.id] = binding.trip
            }
            if case let .active(facts, intervals) = slot.state {
                guard binding.matches(facts.binding) else { throw .factsConflict }
                guard binding.matches(intervals.binding) else { throw .intervalConflict }
                var seen = Set<TimetableVerifiedRideInterval>()
                for interval in intervals.declared {
                    let b = interval.boardingIndex, a = interval.alightingIndex
                    // Trip already guarantees continuous movement-bearing line coverage. Do not enumerate
                    // pairs or construct candidates; validate ONLY the positively supplied indices.
                    guard b >= 0, b < a, a < binding.trip.stopSequence.count,
                          binding.trip.stopSequence[b] != binding.trip.stopSequence[a],
                          seen.insert(interval).inserted else { throw .intervalConflict }
                }
            }
        }
        guard byAddress.count == declaredAddresses.count else { throw .slotAssociation }
        self.qualification = qualification; self.declaredAddresses = declaredAddresses
        self.completeness = completeness
        // Count equality plus exact membership proves total lookup; no partial or last-wins output.
        self.slots = declaredAddresses.compactMap { byAddress[$0] }
        self.logicalPayloadBytes = budget.used
    }

    private static func addressBytes(_ address: TimetableOccurrenceAddress) throws(TimetableInventoryConstructionFailure) -> Int {
        guard TimetableInventoryQualification.bounded(address.tripID.rawValue),
              TimetableInventoryQualification.bounded(address.serviceDate.label) else { throw .resourceLimit }
        return 48 + address.tripID.rawValue.utf8.count + address.serviceDate.label.utf8.count
    }

    private static func bindingBytes(_ binding: TimetableOccurrenceBinding) throws(TimetableInventoryConstructionFailure) -> Int {
        let trip = binding.trip
        guard TimetableInventoryQualification.bounded(trip.id.rawValue),
              trip.stopSequence.count <= TimetableInventoryLimits.stopsPerTrip,
              trip.lineSegments.count <= TimetableInventoryLimits.stopsPerTrip - 1,
              trip.serviceTypeSegments.count <= TimetableInventoryLimits.stopsPerTrip - 1 else { throw .resourceLimit }
        // Canonically equivalent Domain IDs may retain different UTF-8 spellings.
        // Bound/charge the Trip ID independently from the address ID.
        var bytes = 48 + (try addressBytes(binding.address)) + trip.id.rawValue.utf8.count
        // All arrays and each scanned string are bounded before full equality or hashing.
        for stop in trip.stopSequence {
            guard TimetableInventoryQualification.bounded(stop.rawValue) else { throw .resourceLimit }
            bytes += 16 + stop.rawValue.utf8.count
        }
        for segment in trip.lineSegments {
            guard TimetableInventoryQualification.bounded(segment.lineID.rawValue) else { throw .resourceLimit }
            bytes += 32 + segment.lineID.rawValue.utf8.count
        }
        for segment in trip.serviceTypeSegments {
            guard TimetableInventoryQualification.bounded(segment.serviceTypeID.rawValue) else { throw .resourceLimit }
            bytes += 32 + segment.serviceTypeID.rawValue.utf8.count
        }
        return bytes
    }
}
