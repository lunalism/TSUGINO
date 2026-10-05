#if DEBUG
import Foundation

/// Shared representation only; neither descriptors nor arrays certify completeness.
nonisolated enum SyntheticOptimalRouteAtom: Hashable, Sendable {
    case text([UInt8]), number(Int)
    static func symbol(_ value: String) -> Self { .text(Array(value.utf8)) }
    static func less(_ a: Self, _ b: Self) -> Bool {
        switch (a, b) {
        case (.text(let x), .text(let y)): return x.lexicographicallyPrecedes(y)
        case (.number(let x), .number(let y)): return x < y
        case (.number, .text): return true
        case (.text, .number): return false
        }
    }
}

nonisolated struct SyntheticOptimalRouteDescriptor: Sendable {
    let key: [SyntheticOptimalRouteAtom]
    let arrival: Date
    let changes: Int
    func isBetter(than other: Self) -> Bool {
        arrival != other.arrival ? arrival < other.arrival : changes < other.changes
    }
    static func address(_ context: TimetableRideContext) -> [SyntheticOptimalRouteAtom] {
        let a = context.binding.address
        return [.symbol(a.viewID.rawValue.uuidString), .symbol(a.tripID.rawValue), .symbol(a.serviceDate.label)]
    }
    static func checkBounds(_ context: TimetableRideContext) throws {
        let trip = context.binding.trip
        guard trip.stopSequence.count <= 256, trip.lineSegments.count <= 256,
              trip.serviceTypeSegments.count <= 256 else { throw RouteSearchFailure.searchIncomplete }
        let texts = [trip.id.rawValue, context.binding.address.serviceDate.label]
            + trip.stopSequence.map(\.rawValue) + trip.lineSegments.map { $0.lineID.rawValue }
            + trip.serviceTypeSegments.map { $0.serviceTypeID.rawValue }
        guard texts.allSatisfy({ $0.utf8.prefix(129).count <= 128 }) else { throw RouteSearchFailure.searchIncomplete }
    }
    /// Callers bound/check contexts and resolve forms before constructing keys.
    init(contexts: [TimetableRideContext], forms: [Int]) {
        var key: [SyntheticOptimalRouteAtom] = []
        for (i, c) in contexts.enumerated() {
            if i > 0 {
                let previous = contexts[i - 1]
                key += Self.address(previous) + [.number(previous.alightingIndex)]
                key += Self.address(c) + [.number(c.boardingIndex)]
                key += [.symbol(previous.binding.trip.stopSequence[previous.alightingIndex].rawValue),
                        .symbol(c.binding.trip.stopSequence[c.boardingIndex].rawValue), .number(forms[i - 1])]
            }
            key += Self.address(c) + [.number(c.boardingIndex), .number(c.alightingIndex)]
        }
        self.key = key
        arrival = contexts[contexts.count - 1].arrival
        changes = contexts.count - 1
    }
}

/// Incremental shared minimum/dedup/insertion-order kernel. Each advance performs
/// bounded objective comparisons or key equality/order checks and one bounded move.
/// The asynchronous adapter charges/checks cancellation before EVERY advance;
/// the existing synchronous candidate adapter exhausts the same finite machine.
nonisolated struct SyntheticOptimalRouteKernel {
    private let profiling: Bool
    private(set) var profile = SyntheticKernelProfile()
    private let descriptors: [SyntheticOptimalRouteDescriptor]
    private var scan = 0
    private var best: Int?
    private var ties: [Int] = []
    private var tie = 0
    private var insertion = 0
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
        if insertion < winners.count {
            let other = descriptors[winners[insertion]].key, key = descriptors[index].key
            let equalityStart = SyntheticProfileClock.start(profiling)
            let equal = key == other
            if let equalityStart { profile.equalities += 1; profile.equalityTime += equalityStart.duration(to: .now) }
            if equal { tie += 1; insertion = 0; return }
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
        tie += 1; insertion = 0
    }
}
#endif
