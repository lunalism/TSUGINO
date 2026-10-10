import Foundation
@testable import TSUGINO

/// Test target only. Recursive full scanning, materialize ALL feasible complete paths,
/// then independently select the objective and sort. No production kernel/helper use.
struct ExhaustivePreparedSolverOracle {
    func winners(_ p: PreparedInternalSearchInput) -> [[PreparedTimetableRideKey]] {
        precondition(p.rides.count <= 16) // Deliberately small oracle, never runtime.
        var complete: [[Int]] = []
        func visit(_ prefix: [Int], _ used: Set<TripID>) {
            if let last = prefix.last, p.rides[last].train.anchors.alightingStationID == p.scope.request.destination {
                complete.append(prefix)
            }
            if prefix.count == p.scope.profile.maximumRailRides { return }
            for i in p.rides.indices {
                let r = p.rides[i]
                if used.contains(r.train.trip.id) { continue }
                if let last = prefix.last {
                    let from = p.rides[last]
                    let match = p.connections.contains { edge in
                        edge.state == .feasible && edge.key.from == from.key.address
                            && edge.key.alightingIndex == from.key.alightingIndex
                            && edge.key.to == r.key.address && edge.key.boardingIndex == r.key.boardingIndex
                    }
                    if !match { continue }
                } else if r.train.anchors.boardingStationID != p.scope.request.origin { continue }
                visit(prefix + [i], used.union([r.train.trip.id]))
            }
        }
        visit([], [])
        guard let arrival = complete.map({ p.rides[$0.last!].context.arrival }).min() else { return [] }
        let fastest = complete.filter { p.rides[$0.last!].context.arrival == arrival }
        let length = fastest.map(\.count).min()!
        let keys = fastest.filter { $0.count == length }.map { $0.map { p.rides[$0].key } }
        var unique: [[PreparedTimetableRideKey]] = []
        for key in keys where !unique.contains(key) { unique.append(key) }
        return unique.sorted(by: ordered)
    }
    func ordered(_ a: [PreparedTimetableRideKey], _ b: [PreparedTimetableRideKey]) -> Bool {
        for (x,y) in zip(a,b) {
            if x == y { continue }
            // Fixed-width uppercase hexadecimal UUID ordering independently matches unsigned bytes.
            if x.address.viewID != y.address.viewID { return x.address.viewID.rawValue.uuidString < y.address.viewID.rawValue.uuidString }
            let xt = Array(x.address.tripID.rawValue.utf8), yt = Array(y.address.tripID.rawValue.utf8)
            if xt != yt { return xt.lexicographicallyPrecedes(yt) }
            let xd = Array(x.address.serviceDate.label.utf8), yd = Array(y.address.serviceDate.label.utf8)
            if xd != yd { return xd.lexicographicallyPrecedes(yd) }
            if x.boardingIndex != y.boardingIndex { return x.boardingIndex < y.boardingIndex }
            if x.alightingIndex != y.alightingIndex { return x.alightingIndex < y.alightingIndex }
        }
        return a.count < b.count
    }
}
