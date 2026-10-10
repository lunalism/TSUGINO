import Foundation

/// Invocation safeguards, never semantic preferences or a deployment promise.
nonisolated struct InternalSolverExecutionConfiguration: Sendable {
    let objective: InternalRouteObjectiveDefinition
    let maximumWork: Int
    let maximumRetainedSlots: Int
    let maximumWinners: Int
    let maximumIdentityKeys: Int
    let maximumLogicalBytes: Int

    init(objective: InternalRouteObjectiveDefinition, maximumWork: Int,
         maximumRetainedSlots: Int, maximumWinners: Int,
         maximumIdentityKeys: Int, maximumLogicalBytes: Int) {
        self.objective = objective; self.maximumWork = maximumWork
        self.maximumRetainedSlots = maximumRetainedSlots; self.maximumWinners = maximumWinners
        self.maximumIdentityKeys = maximumIdentityKeys; self.maximumLogicalBytes = maximumLogicalBytes
    }
    /// Invented evaluation envelope; see consumer §25 for measured boundaries.
    static func inventedEvaluation(objective: InternalRouteObjectiveDefinition) -> Self {
        .init(objective: objective, maximumWork: 100_000_000, maximumRetainedSlots: 1_000_000,
              maximumWinners: 256, maximumIdentityKeys: 16_384, maximumLogicalBytes: 256 * 1_024 * 1_024)
    }
}

nonisolated enum InternalSolverStage: CaseIterable, Hashable, Sendable {
    case indexing, exploration, tieCollection, ordering, admission, finalization, terminal
}
nonisolated struct InternalSolverUsage: Sendable {
    var work = 0, retainedSlots = 0, identityKeys = 0, logicalBytes = 0
}

/// All meters are cumulative, including abandoned incumbents and temporary copies.
/// Credits conservatively bound logical storage/work, not allocator bytes or CPU time.
nonisolated struct InternalSolverMeter {
    let configuration: InternalSolverExecutionConfiguration
    private(set) var usage = InternalSolverUsage()
    init(_ configuration: InternalSolverExecutionConfiguration) throws {
        try Task.checkCancellation()
        guard [configuration.maximumWork, configuration.maximumRetainedSlots,
               configuration.maximumWinners, configuration.maximumIdentityKeys,
               configuration.maximumLogicalBytes].allSatisfy({ $0 > 0 }),
              configuration.maximumWork <= 100_000_000, configuration.maximumRetainedSlots <= 1_000_000,
              configuration.maximumWinners <= 256, configuration.maximumIdentityKeys <= 16_384,
              configuration.maximumLogicalBytes <= 256 * 1_024 * 1_024 else {
            throw RouteSearchFailure.configurationUnavailable
        }
        self.configuration = configuration
    }
    static func product(_ a: Int, _ b: Int) throws -> Int {
        try Task.checkCancellation()
        let (n, overflow) = a.multipliedReportingOverflow(by: b)
        guard a >= 0, b >= 0, !overflow else { throw RouteSearchFailure.searchIncomplete }
        return n
    }
    mutating func charge(work: Int = 1, slots: Int = 0, keys: Int = 0, bytes: Int = 0) throws {
        try Task.checkCancellation()
        // Atomic preflight: no counter changes and no allocations before all guards pass.
        let amounts = [work, slots, keys, bytes]
        let used = [usage.work, usage.retainedSlots, usage.identityKeys, usage.logicalBytes]
        let limits = [configuration.maximumWork, configuration.maximumRetainedSlots,
                      configuration.maximumIdentityKeys, configuration.maximumLogicalBytes]
        guard zip(zip(amounts, used), limits).allSatisfy({ pair, limit in
            let (amount, current) = pair
            return amount >= 0 && current <= limit && amount <= limit - current
        }) else { throw RouteSearchFailure.searchIncomplete }
        usage.work += work; usage.retainedSlots += slots
        usage.identityKeys += keys; usage.logicalBytes += bytes
    }
}

nonisolated struct SolverTransitionClaim: Sendable {
    var key: ConnectionRelationKey
    var form: ConnectionForm
}
/// Private pipeline representation: claims are resolved back to unique retained tokens.
/// Tests may corrupt these copies, never forge P or a completion certificate.
nonisolated struct SolverAdmissionClaim: Sendable {
    var tokens: [Int]
    var keys: [PreparedTimetableRideKey]
    var trains: [TrainCandidate]
    var contexts: [TimetableRideContext]
    var departures: [Date]
    var arrivals: [Date]
    var eligibilityTokens: [Int]
    var transitions: [SolverTransitionClaim]
}

#if DEBUG
nonisolated struct InternalSolverTestHooks: Sendable {
    var checkpoint: (@Sendable (InternalSolverStage, InternalSolverUsage) async throws -> Void)?
    var claim: (@Sendable (Int, SolverAdmissionClaim) -> SolverAdmissionClaim)?
    var brokenSharedRelationIndex: Int?
}
#endif

/// Data-owned consumer only. It does not conform to/adopt the live RouteSearching port.
nonisolated struct InternalRouteSolver: Sendable {
    @concurrent func solve(_ input: PreparedInternalSearchInput,
                           configuration: InternalSolverExecutionConfiguration) async throws -> RouteSearchResult {
        do {
            var kernel = try SolverKernel(input: input, configuration: configuration)
            return try await kernel.run()
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let failure = error as? RouteSearchFailure { throw failure }
            throw RouteSearchFailure.dataUnavailable
        }
    }
    #if DEBUG
    func orderedForTesting(_ input: PreparedInternalSearchInput, lhs: [PreparedTimetableRideKey],
                           rhs: [PreparedTimetableRideKey]) throws -> Bool {
        var kernel = try SolverKernel(input: input, configuration: .inventedEvaluation(objective: input.objective))
        var retained: [PreparedTimetableRideKey] = []
        func resolve(_ keys: [PreparedTimetableRideKey]) -> [Int] {
            keys.map { key in
                if let i = retained.firstIndex(of: key) { return i }
                retained.append(key); return retained.count - 1
            }
        }
        let l = resolve(lhs), r = resolve(rhs)
        kernel.orderKeys = retained.map(SolverOrderKey.init)
        return try kernel.less(l,r)
    }
    @concurrent func solveForTesting(_ input: PreparedInternalSearchInput,
        configuration: InternalSolverExecutionConfiguration, hooks: InternalSolverTestHooks) async throws -> RouteSearchResult {
        do {
            var kernel = try SolverKernel(input: input, configuration: configuration)
            kernel.hooks = hooks
            return try await kernel.run()
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let failure = error as? RouteSearchFailure { throw failure }
            throw RouteSearchFailure.dataUnavailable
        }
    }
    #endif
}

private nonisolated struct SolverOrderKey {
    let uuid: [UInt8], trip: [UInt8], day: [UInt8]
    let board: Int, alight: Int
    init(_ key: PreparedTimetableRideKey) {
        let address = key.address, u = address.viewID.rawValue.uuid
        uuid = [u.0,u.1,u.2,u.3,u.4,u.5,u.6,u.7,u.8,u.9,u.10,u.11,u.12,u.13,u.14,u.15]
        trip = Array(address.tripID.rawValue.utf8); day = Array(address.serviceDate.label.utf8)
        board = key.boardingIndex; alight = key.alightingIndex
    }
}
private nonisolated struct SolverKernel {
    let input: PreparedInternalSearchInput
    var meter: InternalSolverMeter
    var orderKeys: [SolverOrderKey] = []
    var outgoing: [Bool] = []
    #if DEBUG
    var hooks: InternalSolverTestHooks?
    #endif
    init(input: PreparedInternalSearchInput, configuration: InternalSolverExecutionConfiguration) throws {
        self.input = input; meter = try .init(configuration)
    }
    mutating func enter(_ stage: InternalSolverStage) async throws {
        try meter.charge()
        #if DEBUG
        try await hooks?.checkpoint?(stage, meter.usage)
        #endif
        try Task.checkCancellation()
    }
    /// Bounded native snapshot/string/profile operations receive bulk conservative credits.
    /// P bounds strings to 192 UTF-8 bytes and trip snapshots to 72 stops.
    func snapshotCost(_ ride: PreparedTimetableRide) throws -> Int {
        try InternalSolverMeter.product(4_096, ride.train.trip.stopSequence.count + 1)
    }
    mutating func relation(_ key: ConnectionRelationKey) throws -> Int? {
        // Linear retained-key projection: no hidden hash-table collision cost or Cartesian edges.
        for i in input.connections.indices {
            try meter.charge(work: 4_096)
            if input.connections[i].key == key { return i }
        }
        return nil
    }
    func transition(_ a: Int, _ b: Int) -> ConnectionRelationKey {
        let x = input.rides[a].key, y = input.rides[b].key
        return .init(from: x.address, alightingIndex: x.alightingIndex,
                     to: y.address, boardingIndex: y.boardingIndex)
    }
    mutating func validateAndIndex() async throws {
        try await enter(.indexing)
        try meter.charge(work: input.logicalPayloadBytes, slots: 1, bytes: input.logicalPayloadBytes)
        guard input.assessment.isTechnicallyQualified,
              input.objective.hasSameDefinition(as: meter.configuration.objective),
              input.scope.viewID == input.assessment.closure.inventory.qualification.viewID,
              input.assessment.connections.qualification.policy == input.scope.profile.connectionPolicy else {
            throw RouteSearchFailure.dataUnavailable
        }
        try meter.charge(slots: input.rides.count + 1, bytes: input.rides.count + 24)
        for ride in input.rides {
            try meter.charge(work: snapshotCost(ride))
            guard ride.key.address == ride.context.binding.address,
                  ride.key.boardingIndex == ride.train.boardingIndex,
                  ride.key.alightingIndex == ride.train.alightingIndex,
                  ride.context.matches(ride.train), ride.key.address.viewID == input.scope.viewID,
                  input.scope.contains(ride.context.departure), input.scope.contains(ride.context.arrival) else {
                throw RouteSearchFailure.dataUnavailable
            }
            var canExtend = false
            for connection in input.connections {
                try meter.charge(work: 4_096)
                if connection.state == .feasible && connection.key.from == ride.key.address
                    && connection.key.alightingIndex == ride.key.alightingIndex { canExtend = true; break }
            }
            outgoing.append(canExtend)
            let address = ride.key.address
            // Bounded lengths are inherited from P, charged before allocating comparator bytes.
            let n = 16 + address.tripID.rawValue.utf8.count + address.serviceDate.label.utf8.count
            try meter.charge(work: n, slots: 4, bytes: n + 80)
            orderKeys.append(.init(ride.key))
        }
        for i in input.connections.indices {
            try meter.charge(work: 4_096)
            let connection = input.connections[i]
            var recordIndex = connection.evidenceIndex
            #if DEBUG
            if hooks?.brokenSharedRelationIndex == i { recordIndex = -1 }
            #endif
            guard input.assessment.connections.records.indices.contains(recordIndex) else {
                throw RouteSearchFailure.dataUnavailable
            }
            let record = input.assessment.connections.records[recordIndex]
            guard record.key == connection.key else { throw RouteSearchFailure.dataUnavailable }
            switch (connection.state, record.state) {
            case (.feasible, .present), (.infeasible, .present), (.absentUnderCompleteAuthority, .absent): break
            default: throw RouteSearchFailure.dataUnavailable
            }
        }
    }
    mutating func run() async throws -> RouteSearchResult {
        try await validateAndIndex()
        try await enter(.exploration)
        // One ordinal per unique retained key; P rejects equal keys, including Swift String equivalence.
        let bound = min(input.scope.profile.maximumRailRides, input.rides.count)
        var path: [Int] = [], next: [Int] = [0], winners: [[Int]] = []
        try meter.charge(slots: 3, bytes: 96)
        var bestArrival: Date?, bestCount = 0
        while !next.isEmpty {
            try meter.charge()
            if next[next.count - 1] == input.rides.count {
                next.removeLast()
                if !path.isEmpty { path.removeLast() }
                continue
            }
            let candidate = next[next.count - 1]
            next[next.count - 1] += 1
            let ride = input.rides[candidate]
            try meter.charge(work: 4_096)
            if path.isEmpty {
                if ride.train.anchors.boardingStationID != input.scope.request.origin { continue }
            } else {
                var repeated = false
                for previous in path {
                    try meter.charge(work: 1_024)
                    if input.rides[previous].train.trip.id == ride.train.trip.id { repeated = true; break }
                }
                if repeated { continue }
                guard let edge = try relation(transition(path[path.count - 1], candidate)),
                      input.connections[edge].state == .feasible else { continue }
            }
            if path.count >= bound { continue }
            try meter.charge(work: path.count + 1, slots: path.count + 1, bytes: InternalSolverMeter.product(path.count + 1, 8))
            path.append(candidate)
            if ride.train.anchors.alightingStationID == input.scope.request.destination {
                try await enter(.tieCollection)
                let arrival = ride.context.arrival
                if bestArrival == nil || arrival < bestArrival! || (arrival == bestArrival! && path.count < bestCount) {
                    bestArrival = arrival; bestCount = path.count; winners.removeAll(keepingCapacity: false)
                }
                if arrival == bestArrival && path.count == bestCount {
                    var duplicate = false
                    for winner in winners {
                        try meter.charge(work: winner.count + 1)
                        if winner == path { duplicate = true; break }
                    }
                    if !duplicate {
                        guard winners.count < meter.configuration.maximumWinners else {
                            throw RouteSearchFailure.searchIncomplete
                        }
                        try meter.charge(work: path.count, slots: path.count + 1, keys: path.count,
                            bytes: InternalSolverMeter.product(path.count, 8) + 24)
                        winners.append(path)
                    }
                }
            }
            if path.count < bound && outgoing[candidate] {
                try meter.charge(slots: 1, bytes: 8); next.append(0)
            } else { path.removeLast() }
        }
        // Complete exhaustive proof. Subsequent stages still use the same meter.
        try await enter(.ordering)
        // In-place insertion sort; every comparison/shift checked, no opaque stdlib sort.
        for i in winners.indices.dropFirst() {
            var j = i
            while j > 0 {
                try meter.charge()
                if try !less(winners[j], winners[j - 1]) { break }
                try meter.charge(); winners.swapAt(j, j - 1); j -= 1
            }
        }
        try await enter(.admission)
        var admitted: [RouteCandidate] = [], omissions: [RouteAlternativeOmission] = []
        try meter.charge(slots: 2, bytes: 48)
        for (index, winner) in winners.enumerated() {
            try await enter(.admission)
            var claim = try makeClaim(winner)
            #if DEBUG
            claim = hooks?.claim?(index, claim) ?? claim
            #endif
            let result = try admit(claim)
            try meter.charge(slots: 1, bytes: 64)
            switch result {
            case .success(let candidate): admitted.append(candidate)
            case .failure(let reason):
                guard let omission = RouteAlternativeOmission(alternativeIndex: index, reasons: [reason]) else {
                    throw RouteSearchFailure.dataUnavailable
                }
                omissions.append(omission)
            }
        }
        try await enter(.finalization)
        // Charge whole final validation and retained output copy before canonical constructors.
        for winner in winners {
            for token in winner {
                let ride = input.rides[token], profile = input.scope.profile
                let stations = try InternalSolverMeter.product(profile.stations.count, ride.train.trip.stopSequence.count)
                let lines = try InternalSolverMeter.product(profile.lines.count, ride.train.trip.lineSegments.count)
                let membership = try InternalSolverMeter.product(stations + lines + profile.trips.count, 1_024)
                try meter.charge(work: snapshotCost(ride) + membership, bytes: snapshotCost(ride))
            }
        }
        // A second whole-input credit overestimates the final retained scope/profile copy.
        try meter.charge(bytes: input.logicalPayloadBytes)
        try meter.charge(work: winners.count + 1, slots: winners.count + 1,
                         bytes: InternalSolverMeter.product(winners.count, 64) + 64)
        let output: RouteSearchResult
        if winners.isEmpty {
            guard let success = InternalSearchSuccess(scope: input.scope, outcome: .noResults) else {
                throw RouteSearchFailure.dataUnavailable
            }
            output = .internalSuccess(success)
        } else if admitted.isEmpty {
            guard let rejections = RouteSearchRejections(omissions: omissions) else {
                throw RouteSearchFailure.dataUnavailable
            }
            try await enter(.terminal)
            throw RouteSearchFailure.noUsableAlternatives(rejections)
        } else if !omissions.isEmpty {
            try await enter(.terminal)
            throw RouteSearchFailure.searchIncomplete
        } else {
            guard let batch = RouteSearchBatch(candidates: admitted, omissions: []),
                  let success = InternalSearchSuccess(scope: input.scope, outcome: .alternatives(batch)) else {
                throw RouteSearchFailure.dataUnavailable
            }
            output = .internalSuccess(success)
        }
        try await enter(.terminal)
        return output
    }
    mutating func less(_ lhs: [Int], _ rhs: [Int]) throws -> Bool {
        for (a, b) in zip(lhs, rhs) {
            try meter.charge()
            if a == b { continue }
            // Guard before copying key values or allocating tuple scratch.
            let byteCount = orderKeys[a].uuid.count + orderKeys[a].trip.count + orderKeys[a].day.count
                + orderKeys[b].uuid.count + orderKeys[b].trip.count + orderKeys[b].day.count
            try meter.charge(slots: 9, bytes: 320 + 3 * byteCount)
            let x = orderKeys[a], y = orderKeys[b]
            for (l, r) in [(x.uuid,y.uuid), (x.trip,y.trip), (x.day,y.day)] {
                for (lb, rb) in zip(l,r) {
                    try meter.charge()
                    if lb != rb { return lb < rb }
                }
                if l.count != r.count { return l.count < r.count }
            }
            if x.board != y.board { return x.board < y.board }
            if x.alight != y.alight { return x.alight < y.alight }
        }
        return lhs.count < rhs.count
    }
    mutating func makeClaim(_ winner: [Int]) throws -> SolverAdmissionClaim {
        try meter.charge(work: winner.count, slots: InternalSolverMeter.product(winner.count, 9),
            bytes: InternalSolverMeter.product(winner.count, 1_024) + 192)
        // Canonical snapshots are conservatively charged by value, independent of COW sharing.
        for token in winner {
            try meter.charge(work: snapshotCost(input.rides[token]), bytes: snapshotCost(input.rides[token]))
        }
        var transitions: [SolverTransitionClaim] = []
        for pair in zip(winner, winner.dropFirst()) {
            let key = transition(pair.0, pair.1)
            guard let edge = try relation(key), let evidence = input.positiveEvidence(at: edge) else {
                throw RouteSearchFailure.dataUnavailable
            }
            transitions.append(.init(key: key, form: evidence.form))
        }
        return .init(tokens: winner, keys: winner.map { input.rides[$0].key },
            trains: winner.map { input.rides[$0].train }, contexts: winner.map { input.rides[$0].context },
            departures: winner.map { input.rides[$0].context.departure }, arrivals: winner.map { input.rides[$0].context.arrival },
            eligibilityTokens: winner, transitions: transitions)
    }
    enum Admission { case success(RouteCandidate), failure(RouteAlternativeRejectionReason) }
    mutating func admit(_ claim: SolverAdmissionClaim) throws -> Admission {
        let n = claim.tokens.count
        try meter.charge(work: InternalSolverMeter.product(max(1,n), 4_096))
        // Priority is canonical declaration order, not discovery order.
        if let first = claim.trains.first, let last = claim.trains.last,
           first.anchors.boardingStationID != input.scope.request.origin || last.anchors.alightingStationID != input.scope.request.destination {
            return .failure(.endpointMismatch)
        }
        var edges: [Int] = []
        try meter.charge(slots: n, bytes: InternalSolverMeter.product(n,8))
        if claim.transitions.count != max(0,n - 1) { return .failure(.unverifiedTransfer) }
        for i in claim.transitions.indices {
            let chosen = claim.transitions[i]
            guard claim.keys.indices.contains(i+1), let edge = try relation(chosen.key),
                  let positive = input.positiveEvidence(at: edge), chosen.form == positive.form,
                  chosen.key == ConnectionRelationKey(from: claim.keys[i].address, alightingIndex: claim.keys[i].alightingIndex,
                    to: claim.keys[i+1].address, boardingIndex: claim.keys[i+1].boardingIndex),
                  claim.trains.indices.contains(i+1) else { return .failure(.unverifiedTransfer) }
            let same = claim.trains[i].anchors.alightingStationID == claim.trains[i+1].anchors.boardingStationID
            if same != (chosen.form == .sameStation) { return .failure(.unverifiedTransfer) }
            edges.append(edge)
        }
        guard n > 0, n <= input.scope.profile.maximumRailRides, claim.trains.count == n else { return .failure(.invalidStructure) }
        for i in claim.trains.indices {
            for j in 0..<i {
                try meter.charge(work: 1_024)
                if claim.trains[i].trip.id == claim.trains[j].trip.id { return .failure(.invalidStructure) }
            }
        }
        guard claim.keys.count == n, claim.contexts.count == n else { return .failure(.inconsistentTrainEvidence) }
        for i in claim.tokens.indices {
            guard input.rides.indices.contains(claim.tokens[i]) else { return .failure(.inconsistentTrainEvidence) }
            let retained = input.rides[claim.tokens[i]]
            try meter.charge(work: snapshotCost(retained))
            guard claim.keys[i] == retained.key, claim.contexts[i].matches(claim.trains[i]),
                  claim.trains[i].boardingIndex == retained.train.boardingIndex,
                  claim.trains[i].alightingIndex == retained.train.alightingIndex,
                  retained.context.binding.matches(claim.contexts[i].binding),
                  TimetableOccurrenceBinding(address: retained.key.address, trip: claim.trains[i].trip).map({ retained.context.binding.matches($0) }) == true else {
                return .failure(.inconsistentTrainEvidence)
            }
        }
        guard claim.departures.count == n, claim.arrivals.count == n else { return .failure(.invalidScheduledContext) }
        for i in claim.tokens.indices {
            try meter.charge()
            let retained = input.rides[claim.tokens[i]].context
            if claim.departures[i] != retained.departure || claim.arrivals[i] != retained.arrival
                || claim.contexts[i].departure != retained.departure || claim.contexts[i].arrival != retained.arrival
                || (i > 0 && claim.arrivals[i-1] > claim.departures[i]) { return .failure(.invalidScheduledContext) }
        }
        if claim.eligibilityTokens != claim.tokens { return .failure(.unverifiedEligibility) }
        for edge in edges {
            try meter.charge()
            if input.connections[edge].state != .feasible { return .failure(.infeasibleConnection) }
        }
        var legs: [RouteCandidateLeg] = []
        try meter.charge(slots: InternalSolverMeter.product(n,2), bytes: InternalSolverMeter.product(n,1_024))
        for i in claim.tokens.indices {
            let retained = input.rides[claim.tokens[i]]
            try meter.charge(work: snapshotCost(retained), bytes: snapshotCost(retained))
            if i > 0, claim.transitions[i-1].form == .walking {
                guard let walk = WalkingTransfer(fromStationID: claim.trains[i-1].anchors.alightingStationID,
                                                 toStationID: claim.trains[i].anchors.boardingStationID) else {
                    return .failure(.unverifiedTransfer)
                }
                legs.append(.walkingTransfer(walk))
            }
            guard let rail = RouteRailProposal(travel: .matched(claim.trains[i]), scheduledContext: .timetable(claim.contexts[i])) else {
                return .failure(.inconsistentTrainEvidence)
            }
            legs.append(.rail(rail))
        }
        let pairs = try InternalSolverMeter.product(n,n)
        try meter.charge(work: InternalSolverMeter.product(pairs,1_024))
        guard let candidate = RouteCandidate(legs: legs) else { return .failure(.invalidStructure) }
        return .success(candidate)
    }
}
