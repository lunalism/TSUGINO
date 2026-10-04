#if DEBUG
import Foundation

nonisolated struct SyntheticInternalRideKey: Hashable, Sendable {
    let address: TimetableOccurrenceAddress
    let boarding: Int
    let alighting: Int

    static func precedes(_ a: Self, _ b: Self) -> Bool {
        let fieldsA = [a.address.viewID.rawValue.uuidString, a.address.tripID.rawValue, a.address.serviceDate.label]
        let fieldsB = [b.address.viewID.rawValue.uuidString, b.address.tripID.rawValue, b.address.serviceDate.label]
        for (x, y) in zip(fieldsA, fieldsB) where Array(x.utf8) != Array(y.utf8) {
            // Fixed uppercase UUID hex ordering is equivalent to its 16-byte order.
            return x.utf8.lexicographicallyPrecedes(y.utf8)
        }
        if a.boarding != b.boarding { return a.boarding < b.boarding }
        return a.alighting < b.alighting
    }
}
nonisolated struct SyntheticInternalRide: Sendable {
    let key: SyntheticInternalRideKey
    let train: TrainCandidate
    let context: TimetableRideContext
}
nonisolated struct SyntheticInternalNormalizedSlot: Sendable {
    let slot: SyntheticInternalSlot
    let continuity: [SyntheticInternalInterval: SyntheticInternalEvidence]
}
nonisolated struct SyntheticInternalNormalizedInventory: Sendable {
    let trip: Trip
    let intervals: Set<SyntheticInternalInterval>?
    let slots: [TimetableOccurrenceAddress: SyntheticInternalNormalizedSlot]?
}
nonisolated struct SyntheticInternalPrepared: Sendable {
    let scope: InternalSearchScope
    let rides: [SyntheticInternalRideKey: SyntheticInternalRide]
    let slots: [TimetableOccurrenceAddress: SyntheticInternalNormalizedSlot]
    let connections: [SyntheticInternalConnectionKey: SyntheticInternalConnectionState]
    let paths: [[SyntheticInternalRideKey]]
}

nonisolated struct SyntheticInternalQualifiedGraph: Sendable {
    let scope: InternalSearchScope
    let rides: [SyntheticInternalRideKey: SyntheticInternalRide]
    let slots: [TimetableOccurrenceAddress: SyntheticInternalNormalizedSlot]
    let connections: [SyntheticInternalConnectionKey: SyntheticInternalConnectionState]
    let keys: [SyntheticInternalRideKey]
    let edges: [SyntheticInternalRideKey: Set<SyntheticInternalRideKey>]
}

/// One value per invocation. No shared mutable state, unowned tasks or network work.
nonisolated struct SyntheticInternalRouteEngine: Sendable {
    let configuration: SyntheticInternalConfiguration?
    let view: SyntheticInternalView?
    let workLimit: Int?
    let checkpoint: @Sendable (SyntheticInternalStage) async throws -> Void
    private var work = 0
    let experiment: SyntheticPruningMode?
    private(set) var metrics = SyntheticPruningMetrics()
    private var measuringDiscovery = false
    private var measuringPost = false

    init(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?, workLimit: Int?,
         checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void,
         experiment: SyntheticPruningMode? = nil) {
        self.configuration = configuration; self.view = view
        self.workLimit = workLimit; self.checkpoint = checkpoint; self.experiment = experiment
    }

    mutating func step(_ stage: SyntheticInternalStage) async throws {
        try Task.checkCancellation()
        let (next, overflow) = work.addingReportingOverflow(1)
        guard !overflow, workLimit.map({ next <= $0 }) ?? true else { throw RouteSearchFailure.searchIncomplete }
        work = next
        if experiment != nil {
            if measuringDiscovery { metrics.discoveryWork += 1 }
            else if measuringPost { metrics.postWork += 1 }
            else { metrics.qualificationWork += 1 }
        }
        do { try await checkpoint(stage) }
        catch { try Task.checkCancellation(); if error is CancellationError { throw error }; throw RouteSearchFailure.searchIncomplete }
        try Task.checkCancellation()
    }

    mutating func recordSelection(_ elapsed: Duration, advances: Int) {
        if experiment != nil { metrics.selectionTime = elapsed; metrics.kernelAdvances = advances }
    }
    mutating func recordAdmission(_ elapsed: Duration) {
        if experiment != nil { metrics.admissionTime = elapsed }
    }

    mutating func prepare(_ request: RouteSearchRequest) async throws -> SyntheticInternalPrepared {
        let start = experiment == nil ? nil : ContinuousClock.now
        let graph = try await qualify(request)
        if let start { metrics.qualificationTime = start.duration(to: .now) }
        return try await discover(graph)
    }

    /// DEBUG certificate harness seam. Same complete qualification and step calls;
    /// no discovery, admission or caller-supplied completion assertion.
    mutating func qualifyForCertificate(_ request: RouteSearchRequest) async throws -> SyntheticInternalQualifiedGraph {
        try await qualify(request)
    }

    private mutating func qualify(_ request: RouteSearchRequest) async throws -> SyntheticInternalQualifiedGraph {
        try Task.checkCancellation()
        guard let configuration, configuration.permitted, workLimit.map({ $0 >= 0 }) ?? true else {
            throw RouteSearchFailure.configurationUnavailable
        }
        try await step(.configuration)
        guard let view, view.validFrom.timeIntervalSinceReferenceDate.isFinite,
              view.validUntil.timeIntervalSinceReferenceDate.isFinite, view.validFrom < view.validUntil,
              view.policies.qualifiedManifest == configuration.profile.serviceDateInterpretation,
              view.policies.directionalTotalAllowance == configuration.profile.connectionPolicy else {
            throw RouteSearchFailure.dataUnavailable
        }
        try await step(.validation)
        let inventories = try await normalize(view)
        try await step(.endpoints)
        try Self.endpoint(request.origin, .origin, view)
        try Self.endpoint(request.destination, .destination, view)
        try await step(.intent)
        guard let scope = InternalSearchScope(profile: configuration.profile, request: request, viewID: view.id),
              view.validFrom <= scope.lowerBound, scope.upperBound <= view.validUntil else {
            throw RouteSearchFailure.unsupportedRequest
        }
        try await step(.coverage)
        for station in scope.profile.stations {
            try await step(.coverage)
            guard view.stations[station] == [.active] else { throw RouteSearchFailure.dataUnavailable }
        }
        guard scope.profile.lines.isSubset(of: view.lines), scope.profile.trips.isSubset(of: Set(inventories.keys)) else {
            throw RouteSearchFailure.dataUnavailable
        }
        var rides: [SyntheticInternalRideKey: SyntheticInternalRide] = [:]
        var slots: [TimetableOccurrenceAddress: SyntheticInternalNormalizedSlot] = [:]
        for id in scope.profile.trips {
            try await step(.coverage)
            guard let inventory = inventories[id], let declared = inventory.intervals, let manifest = inventory.slots else {
                throw RouteSearchFailure.dataUnavailable
            }
            // Check every in-profile interval, independent of dates, permissions or discovered routes.
            var required: [SyntheticInternalInterval] = []
            for b in inventory.trip.stopSequence.indices {
                for a in (b + 1)..<inventory.trip.stopSequence.count {
                    try await step(.coverage)
                    guard let train = TrainCandidate(trip: inventory.trip, boardingIndex: b, alightingIndex: a) else { continue }
                    if train.trip.stopSequence[b...a].allSatisfy({ scope.profile.stations.contains($0) }) &&
                        train.lineSequence.allSatisfy({ scope.profile.lines.contains($0) }) {
                        let interval = SyntheticInternalInterval(boarding: b, alighting: a)
                        guard declared.contains(interval) else { throw RouteSearchFailure.dataUnavailable }
                        required.append(interval)
                    }
                }
            }
            for (address, slot) in manifest {
                try await step(.coverage)
                slots[address] = slot
                switch slot.slot.activation {
                case .inactive: continue
                case .unavailable: throw RouteSearchFailure.dataUnavailable
                case .active(let facts, _):
                    for interval in required {
                        try await step(.coverage)
                        let b = interval.boarding, a = interval.alighting
                        let boarding = facts.visits[b].boarding, alighting = facts.visits[a].alighting
                        if boarding == .prohibited || alighting == .prohibited { continue }
                        guard boarding == .allowed, alighting == .allowed,
                              case .exact(let departure) = facts.visits[b].departure,
                              case .exact(let arrival) = facts.visits[a].arrival else { throw RouteSearchFailure.dataUnavailable }
                        guard scope.contains(departure.date), scope.contains(arrival.date) else { continue }
                        guard slot.continuity[interval] == .affirmed,
                              let train = TrainCandidate(trip: inventory.trip, boardingIndex: b, alightingIndex: a),
                              let context = TimetableRideContext(train: train, facts: facts) else { throw RouteSearchFailure.dataUnavailable }
                        let key = SyntheticInternalRideKey(address: address, boarding: b, alighting: a)
                        if experiment != nil && rides[key] == nil && rides.count >= 32 { throw RouteSearchFailure.searchIncomplete }
                        rides[key] = SyntheticInternalRide(key: key, train: train, context: context)
                    }
                }
            }
        }
        let connections = try await normalizeConnections(view, inventories: inventories)
        let keys = try await ordered(Array(rides.keys), by: SyntheticInternalRideKey.precedes)
        var edges: [SyntheticInternalRideKey: Set<SyntheticInternalRideKey>] = [:]
        if scope.profile.maximumRailRides > 1 {
            for first in keys {
                for next in keys {
                    try await step(.coverage)
                    if experiment != nil { metrics.pairChecks += 1 }
                    guard first.address.tripID != next.address.tripID else { continue }
                    guard let a = rides[first], let b = rides[next],
                          let relation = connections[Self.connectionKey(first, next)] else { throw RouteSearchFailure.dataUnavailable }
                    switch relation {
                    case .unknown: throw RouteSearchFailure.dataUnavailable
                    case .absent: continue
                    case .present(_, let allowance, let evidence):
                        guard evidence == .affirmed else { throw RouteSearchFailure.dataUnavailable }
                        if SyntheticInternalArithmetic.permits(arrival: a.context.arrival, departure: b.context.departure, allowance: allowance.total) {
                            edges[first, default: []].insert(next)
                        }
                    }
                }
            }
        }
        if experiment != nil {
            metrics.qualifiedRides = rides.count
            metrics.qualifiedEdges = edges.values.reduce(0) { $0 + $1.count }
        }
        return .init(scope: scope, rides: rides, slots: slots, connections: connections, keys: keys, edges: edges)
    }

    private mutating func discover(_ graph: SyntheticInternalQualifiedGraph) async throws -> SyntheticInternalPrepared {
        let scope = graph.scope, request = scope.request, rides = graph.rides, slots = graph.slots
        let connections = graph.connections, keys = graph.keys, edges = graph.edges
        let start = experiment == nil ? nil : ContinuousClock.now
        measuringDiscovery = experiment != nil
        var incumbent: (Date, Int)?
        var stack: [[SyntheticInternalRideKey]] = []
        for key in keys {
            try await step(.generation)
            if rides[key]?.train.anchors.boardingStationID == request.origin {
                if experiment != nil && stack.count >= 128 { throw RouteSearchFailure.searchIncomplete }
                stack.append([key])
            }
        }
        var complete: [[SyntheticInternalRideKey]] = []
        if experiment != nil { metrics.observe(stack: stack, complete: complete) }
        while let path = stack.popLast() {
            try await step(.generation)
            guard let last = path.last, let ride = rides[last] else { throw RouteSearchFailure.dataUnavailable }
            if experiment != nil {
                guard metrics.prefixes < 4096 else { throw RouteSearchFailure.searchIncomplete }
                metrics.prefixes += 1
            }
            if experiment == .pruned {
                // Charge the bound check; equal objectives are never pruned.
                try await step(.generation)
                if let best = incumbent,
                   ride.context.arrival > best.0 || (ride.context.arrival == best.0 && path.count - 1 > best.1) {
                    metrics.prunedPrefixes += 1
                    continue
                }
            }
            if ride.train.anchors.alightingStationID == request.destination {
                if experiment != nil && complete.count >= 64 { throw RouteSearchFailure.searchIncomplete }
                complete.append(path)
                if experiment == .pruned {
                    let value = (ride.context.arrival, path.count - 1)
                    if incumbent == nil || value.0 < incumbent!.0 || (value.0 == incumbent!.0 && value.1 < incumbent!.1) {
                        incumbent = value
                    }
                }
            }
            if experiment != nil { metrics.observe(stack: stack, complete: complete) }
            if path.count >= scope.profile.maximumRailRides { continue }
            for next in keys {
                try await step(.generation)
                guard edges[last]?.contains(next) == true,
                      !path.contains(where: { $0.address.tripID == next.address.tripID }) else { continue }
                if experiment != nil && stack.count >= 128 { throw RouteSearchFailure.searchIncomplete }
                stack.append(path + [next])
                if experiment != nil { metrics.observe(stack: stack, complete: complete) }
            }
        }
        if let start { metrics.discoveryTime = start.duration(to: .now) }
        measuringDiscovery = false; measuringPost = experiment != nil
        if experiment != nil { metrics.completePaths = complete.count }
        var unique: Set<[SyntheticInternalRideKey]> = []
        var normalized: [[SyntheticInternalRideKey]] = []
        for path in complete {
            try await step(.deduplication)
            if unique.insert(path).inserted { normalized.append(path) }
        }
        let paths = try await ordered(normalized, stage: .sorting) { a, b in
            if a.count != b.count { return a.count < b.count }
            // The sole connection for two rides is determined by their address/indices.
            // Thus this is the same lexicographic order as interleaved ride/connection keys.
            for (x, y) in zip(a, b) where x != y { return SyntheticInternalRideKey.precedes(x, y) }
            return false
        }
        return SyntheticInternalPrepared(scope: scope, rides: rides, slots: slots, connections: connections, paths: paths)
    }

    private static func endpoint(_ id: StationID, _ role: RouteSearchEndpointRole, _ view: SyntheticInternalView) throws {
        let states = view.stations[id] ?? [.unknown]
        for (state, reason) in [(SyntheticInternalStationState.conflicting, RouteSearchEndpointFailureReason.conflicting),
                                (.retired, .retired), (.unknown, .unknown), (.unsupported, .unsupported)] {
            if states.contains(state) { throw RouteSearchFailure.invalidEndpoint(role, reason) }
        }
        guard states.contains(.active) else { throw RouteSearchFailure.invalidEndpoint(role, .unknown) }
    }

    static func connectionKey(_ a: SyntheticInternalRideKey, _ b: SyntheticInternalRideKey) -> SyntheticInternalConnectionKey {
        .init(alighting: .init(address: a.address, index: a.alighting), boarding: .init(address: b.address, index: b.boarding))
    }

    // Checkpointed stable insertion sort: deliberately simple finite synthetic work.
    // Work limits bound comparisons/moves; no uninterruptible global sorting call.
    private mutating func ordered<T: Sendable>(_ input: [T], stage: SyntheticInternalStage = .ordering, by less: (T, T) -> Bool) async throws -> [T] {
        var result: [T] = []
        for value in input {
            try await step(stage)
            var i = result.count
            result.append(value)
            while i > 0 {
                try await step(stage)
                guard less(value, result[i - 1]) else { break }
                result[i] = result[i - 1]; i -= 1
            }
            result[i] = value
        }
        return result
    }

    private mutating func normalize(_ view: SyntheticInternalView) async throws -> [TripID: SyntheticInternalNormalizedInventory] {
        var result: [TripID: SyntheticInternalNormalizedInventory] = [:]
        for inventory in view.inventories {
            try await step(.normalization)
            if let intervals = inventory.intervals {
                for interval in intervals {
                    try await step(.validation)
                    guard TrainCandidate(trip: inventory.trip, boardingIndex: interval.boarding, alightingIndex: interval.alighting) != nil else {
                        throw RouteSearchFailure.dataUnavailable
                    }
                }
            }
            var slots: [TimetableOccurrenceAddress: SyntheticInternalNormalizedSlot]? = inventory.slots == nil ? nil : [:]
            for slot in inventory.slots ?? [] {
                try await step(.validation)
                guard slot.address.viewID == view.id, slot.address.tripID == inventory.trip.id else { throw RouteSearchFailure.dataUnavailable }
                var continuity: [SyntheticInternalInterval: SyntheticInternalEvidence] = [:]
                if case .active(let facts, let supplied) = slot.activation {
                    guard let expected = TimetableOccurrenceBinding(address: slot.address, trip: inventory.trip),
                          Self.sameAddress(facts.binding.address, slot.address), facts.binding.matches(expected) else { throw RouteSearchFailure.dataUnavailable }
                    for item in supplied {
                        try await step(.validation)
                        guard TrainCandidate(trip: inventory.trip, boardingIndex: item.interval.boarding, alightingIndex: item.interval.alighting) != nil,
                              item.evidence != .contradictory else { throw RouteSearchFailure.dataUnavailable }
                        if let old = continuity[item.interval], old != item.evidence { throw RouteSearchFailure.dataUnavailable }
                        continuity[item.interval] = item.evidence
                    }
                }
                let normalized = SyntheticInternalNormalizedSlot(slot: slot, continuity: continuity)
                if let old = slots?[slot.address], !Self.sameSlot(old, normalized) { throw RouteSearchFailure.dataUnavailable }
                slots?[slot.address] = normalized
            }
            let value = SyntheticInternalNormalizedInventory(trip: inventory.trip, intervals: inventory.intervals.map(Set.init), slots: slots)
            if let old = result[inventory.trip.id] {
                guard Self.sameTrip(old.trip, value.trip), old.intervals == value.intervals,
                      (old.slots == nil) == (value.slots == nil), old.slots?.count == value.slots?.count else { throw RouteSearchFailure.dataUnavailable }
                for (address, slot) in value.slots ?? [:] {
                    try await step(.normalization)
                    guard let previous = old.slots?[address], Self.sameSlot(previous, slot) else { throw RouteSearchFailure.dataUnavailable }
                }
            }
            result[inventory.trip.id] = value
        }
        return result
    }

    private mutating func normalizeConnections(_ view: SyntheticInternalView,
        inventories: [TripID: SyntheticInternalNormalizedInventory]) async throws -> [SyntheticInternalConnectionKey: SyntheticInternalConnectionState] {
        var result: [SyntheticInternalConnectionKey: SyntheticInternalConnectionState] = [:]
        for connection in view.connections {
            try await step(.validation)
            let key = connection.key
            guard key.alighting.address.viewID == view.id, key.boarding.address.viewID == view.id,
                  let a = inventories[key.alighting.address.tripID], let b = inventories[key.boarding.address.tripID],
                  let slotA = a.slots?[key.alighting.address], let slotB = b.slots?[key.boarding.address],
                  Self.sameAddress(slotA.slot.address, key.alighting.address), Self.sameAddress(slotB.slot.address, key.boarding.address),
                  a.trip.stopSequence.indices.contains(key.alighting.index), b.trip.stopSequence.indices.contains(key.boarding.index) else {
                throw RouteSearchFailure.dataUnavailable
            }
            if case .present(let form, let allowance, let evidence) = connection.state {
                let sameStation = a.trip.stopSequence[key.alighting.index] == b.trip.stopSequence[key.boarding.index]
                guard allowance.isValid, evidence != .contradictory,
                      (form == .sameStation) == sameStation else { throw RouteSearchFailure.dataUnavailable }
            }
            if let old = result[key], old != connection.state { throw RouteSearchFailure.dataUnavailable }
            result[key] = connection.state
        }
        return result
    }

    static func sameAddress(_ a: TimetableOccurrenceAddress, _ b: TimetableOccurrenceAddress) -> Bool {
        a == b && Array(a.serviceDate.label.utf8) == Array(b.serviceDate.label.utf8)
            && Array(a.tripID.rawValue.utf8) == Array(b.tripID.rawValue.utf8)
    }
    private static func sameTrip(_ a: Trip, _ b: Trip) -> Bool {
        a.id == b.id && a.stopSequence == b.stopSequence && a.lineSegments == b.lineSegments
            && a.coverage == b.coverage && a.serviceTypeSegments == b.serviceTypeSegments
    }
    private static func sameSlot(_ a: SyntheticInternalNormalizedSlot, _ b: SyntheticInternalNormalizedSlot) -> Bool {
        guard sameAddress(a.slot.address, b.slot.address), a.continuity == b.continuity else { return false }
        switch (a.slot.activation, b.slot.activation) {
        case (.inactive, .inactive), (.unavailable, .unavailable): return true
        case (.active(let x, _), .active(let y, _)):
            guard x.binding.matches(y.binding), x.visits.count == y.visits.count else { return false }
            return zip(x.visits, y.visits).allSatisfy { a, b in
                a.originalIndex == b.originalIndex && a.arrival == b.arrival && a.departure == b.departure
                    && a.boarding == b.boarding && a.alighting == b.alighting
            }
        default: return false
        }
    }
}
#endif
