#if DEBUG
import Foundation

/// Observations only. Never charged, used for pruning, or consulted by a failure guard.
nonisolated struct SyntheticKernelProfile: Sendable {
    var objectives = 0, equalities = 0, orders = 0, atomOrderCalls = 0
    var inserts = 0, shiftedWinnerSlots = 0
    var objectiveTime: Duration = .zero, equalityTime: Duration = .zero
    var orderTime: Duration = .zero, insertionTime: Duration = .zero
}
nonisolated struct SyntheticSelectionProfile: Sendable {
    var claims = 0, claimElements = 0, validations = 0, descriptors = 0, keyAtoms = 0
    var pathCopies = 0, pathElements = 0, dedupInserts = 0
    var claimsTime: Duration = .zero, validationTime: Duration = .zero, descriptorTime: Duration = .zero
    var checkpointTime: Duration = .zero, kernelTime: Duration = .zero
    var pathCopyTime: Duration = .zero, pathDedupTime: Duration = .zero, pathOrderTime: Duration = .zero
    var kernel = SyntheticKernelProfile()
}
nonisolated enum SyntheticProfileClock {
    static func start(_ enabled: Bool) -> ContinuousClock.Instant? { enabled ? .now : nil }
}
#endif
