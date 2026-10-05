#if DEBUG
import Foundation

/// Opt-in experiment only. The published kernel remains the reference.
/// Callers retain the existing descriptor/domain limits and charge before each advance.
nonisolated enum SyntheticSelectionVariant: Sendable { case reference, appendFastPath }

nonisolated struct SyntheticAppendFastPathKernel {
    private let profiling: Bool
    private(set) var profile = SyntheticKernelProfile()
    private let descriptors: [SyntheticOptimalRouteDescriptor]
    private var scan = 0
    private var best: Int?
    private var ties: [Int] = []
    private var tie = 0
    private var insertion = 0
    private var checkedLast = false
    private(set) var winners: [Int] = []
    init(_ descriptors: [SyntheticOptimalRouteDescriptor], profiling: Bool = false) { self.descriptors = descriptors; self.profiling = profiling }
    var isComplete: Bool { scan == descriptors.count && tie == ties.count }
    mutating func advance() {
        if scan < descriptors.count {
            let index = scan; scan += 1
            if let best {
                let current = descriptors[index], previous = descriptors[best]
                let start = SyntheticProfileClock.start(profiling)
                if profiling { profile.objectives += 1 }
                if current.isBetter(than: previous) { self.best = index; ties = [index] }
                else {
                    if profiling { profile.objectives += 1 }
                    if !previous.isBetter(than: current) { ties.append(index) }
                }
                if let start { profile.objectiveTime += start.duration(to: .now) }
            } else { best = index; ties = [index] }
            return
        }
        guard tie < ties.count else { return }
        let index = ties[tie]
        // One separately charged advance, never bundled with the fallback scan.
        // Induction: winners starts empty; fallback maintains sorted uniqueness.
        // If last < key, every earlier winner < key, so no earlier duplicate exists.
        if !checkedLast, let last = winners.last {
            checkedLast = true
            let start = SyntheticProfileClock.start(profiling)
            let greater: Bool
            if profiling {
                profile.fastChecks += 1
                greater = descriptors[last].key.lexicographicallyPrecedes(descriptors[index].key) { a, b in
                    profile.fastAtomCalls += 1
                    return SyntheticOptimalRouteAtom.less(a, b)
                }
            } else {
                greater = descriptors[last].key.lexicographicallyPrecedes(descriptors[index].key, by: SyntheticOptimalRouteAtom.less)
            }
            if let start { profile.fastTime += start.duration(to: .now) }
            if greater {
                let insertionStart = SyntheticProfileClock.start(profiling)
                winners.append(index)
                if let insertionStart {
                    profile.fastAppends += 1; profile.inserts += 1
                    profile.insertionTime += insertionStart.duration(to: .now)
                }
                tie += 1; insertion = 0; checkedLast = false
            }
            return
        }
        if insertion < winners.count {
            let other = descriptors[winners[insertion]].key, key = descriptors[index].key
            let equalityStart = SyntheticProfileClock.start(profiling)
            let equal = key == other
            if let equalityStart { profile.equalities += 1; profile.equalityTime += equalityStart.duration(to: .now) }
            if equal { tie += 1; insertion = 0; checkedLast = false; return }
            let orderStart = SyntheticProfileClock.start(profiling)
            let precedes: Bool
            if profiling {
                precedes = key.lexicographicallyPrecedes(other) { a, b in
                    profile.atomOrderCalls += 1
                    return SyntheticOptimalRouteAtom.less(a, b)
                }
            } else { precedes = key.lexicographicallyPrecedes(other, by: SyntheticOptimalRouteAtom.less) }
            if let orderStart { profile.orders += 1; profile.orderTime += orderStart.duration(to: .now) }
            if !precedes {
                insertion += 1; return
            }
        }
        let insertionStart = SyntheticProfileClock.start(profiling)
        if profiling { profile.inserts += 1; profile.shiftedWinnerSlots += winners.count - insertion }
        winners.insert(index, at: insertion)
        if let insertionStart { profile.insertionTime += insertionStart.duration(to: .now) }
        tie += 1; insertion = 0; checkedLast = false
    }
}
#endif
