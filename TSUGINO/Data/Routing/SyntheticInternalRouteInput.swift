#if DEBUG
import Foundation

// Entirely stipulated artificial-world inputs. None authenticates a real source.
nonisolated enum SyntheticInternalStationState: Hashable, Sendable {
    case active, unknown, retired, unsupported, conflicting
}
nonisolated struct SyntheticInternalInterval: Hashable, Sendable {
    let boarding: Int
    let alighting: Int
}
nonisolated enum SyntheticInternalEvidence: Equatable, Sendable {
    case affirmed, unknown, contradictory
}
nonisolated struct SyntheticInternalContinuity: Sendable {
    let interval: SyntheticInternalInterval
    let evidence: SyntheticInternalEvidence
}
nonisolated enum SyntheticInternalActivation: Sendable {
    case active(TimetableOccurrenceFacts, [SyntheticInternalContinuity])
    // Inactive has no event body: downstream code cannot accidentally interpret it.
    case inactive
    case unavailable
}
nonisolated struct SyntheticInternalSlot: Sendable {
    let address: TimetableOccurrenceAddress
    let activation: SyntheticInternalActivation
}
nonisolated struct SyntheticInternalInventory: Sendable {
    let trip: Trip
    // nil = unknown; [] = a complete negative artificial-world declaration.
    // Explicit interval inventory closes partial-snapshot in-profile coverage.
    let intervals: [SyntheticInternalInterval]?
    let slots: [SyntheticInternalSlot]?
}
nonisolated struct SyntheticInternalVisitKey: Hashable, Sendable {
    let address: TimetableOccurrenceAddress
    let index: Int
}
nonisolated struct SyntheticInternalConnectionKey: Hashable, Sendable {
    let alighting: SyntheticInternalVisitKey
    let boarding: SyntheticInternalVisitKey
}
nonisolated enum SyntheticInternalConnectionForm: Equatable, Sendable {
    case sameStation, walking
}
nonisolated struct SyntheticInternalAllowance: Equatable, Sendable {
    // Named components occur exactly once. total is an asserted qualified total,
    // checked against these stipulated components; no universal default exists.
    let alighting: Double
    let interchange: Double
    let boarding: Double
    let total: Double

    var isValid: Bool {
        let values = [alighting, interchange, boarding, total]
        guard values.allSatisfy({ $0.isFinite && $0 >= 0 }),
              let subtotal = SyntheticInternalArithmetic.exactSum(alighting, interchange),
              let sum = SyntheticInternalArithmetic.exactSum(subtotal, boarding) else { return false }
        return sum == total
    }
}
nonisolated enum SyntheticInternalConnectionState: Equatable, Sendable {
    case present(SyntheticInternalConnectionForm, SyntheticInternalAllowance, SyntheticInternalEvidence)
    case absent
    case unknown
}
nonisolated struct SyntheticInternalConnection: Sendable {
    let key: SyntheticInternalConnectionKey
    let state: SyntheticInternalConnectionState
}
nonisolated struct SyntheticInternalPolicies: Sendable {
    // Resolved semantics are fixed by this DEBUG type: a finite qualified manifest
    // and one directional relation with an all-component total allowance per key.
    let qualifiedManifest: InternalSearchPolicyReference
    let directionalTotalAllowance: InternalSearchPolicyReference
}
nonisolated struct SyntheticInternalView: Sendable {
    let id: TimetableViewID
    let validFrom: Date
    let validUntil: Date
    let stations: [StationID: Set<SyntheticInternalStationState>]
    let lines: Set<LineID>
    let policies: SyntheticInternalPolicies
    let inventories: [SyntheticInternalInventory]
    let connections: [SyntheticInternalConnection]
}
nonisolated struct SyntheticInternalConfiguration: Sendable {
    let profile: InternalSearchProfileDefinition
    let permitted: Bool
}
nonisolated enum SyntheticInternalStage: CaseIterable, Sendable {
    case configuration, validation, normalization, endpoints, intent, coverage
    case generation, ordering, deduplication, sorting, admission, finish
}

nonisolated enum SyntheticInternalArithmetic {
    // TwoSum residual: the exact mathematical sum is represented by sum + error.
    static func sum(_ a: Double, _ b: Double) -> (Double, Double) {
        let sum = a + b
        let bv = sum - a
        let av = sum - bv
        return (sum, (a - av) + (b - bv))
    }
    static func exactSum(_ a: Double, _ b: Double) -> Double? {
        let (value, error) = sum(a, b)
        return value.isFinite && error.isFinite && error == 0 ? value : nil
    }
    static func permits(arrival: Date, departure: Date, allowance: Double) -> Bool {
        let (ready, residual) = sum(arrival.timeIntervalSinceReferenceDate, allowance)
        // allowance is validated nonnegative, so an overflowing sum is beyond any
        // finite departure. Equality to a rounded-down sum must not grant permission.
        guard ready.isFinite else { return false }
        let next = departure.timeIntervalSinceReferenceDate
        if next < ready { return false }
        if next > ready { return true }
        return residual <= 0
    }
}
#endif
