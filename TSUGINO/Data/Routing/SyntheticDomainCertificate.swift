#if DEBUG
import Foundation

/// Harness errors are not RouteSearching completion outcomes. No partial report escapes.
nonisolated enum SyntheticCertificateHarnessError: Error { case invalidCount, boundViolation, expectedFailure }
nonisolated enum SyntheticCertificateProbePoint: Sendable { case expansion, successor }
nonisolated enum SyntheticCertificateSaturation {
    static func add(_ lhs: Int, _ rhs: Int, limit: Int) throws -> Int {
        guard lhs >= 0, rhs >= 0, limit > 0 else { throw SyntheticCertificateHarnessError.invalidCount }
        let a = min(lhs, limit), b = min(rhs, limit)
        // Subtract before adding; even Int.max inputs cannot overflow.
        return a >= limit - b ? limit : a + b
    }
}
nonisolated struct SyntheticCertificateObservations: Sendable {
    var rootRequests = 0, memoLookups = 0, memoHits = 0, stateExpansions = 0
    var destinationTests = 0, successorTests = 0, eligibleTransitions = 0
    var childScalarAdditions = 0, rootScalarAdditions = 0, memoWrites = 0
    var peakMemoEntries = 0, peakPendingFrames = 0, peakMemoAndPending = 0
}
nonisolated struct SyntheticDomainCertificateReport: Sendable {
    let completePaths: Int // saturation 65; exact <=64
    let prefixes: Int // saturation 4097; exact <=4096
    var withinCompletePathLimit: Bool { completePaths <= 64 }
    var withinPrefixLimit: Bool { prefixes <= 4096 }
    let observations: SyntheticCertificateObservations
    let qualifiedRides: Int
    let maximumRailRides: Int
    let qualification: SyntheticPruningMetrics
    let qualificationTime: Duration
    let certificationTime: Duration
    let elapsed: Duration
    fileprivate init(_ summary: CertificateSummary, observations: SyntheticCertificateObservations,
                     graph: SyntheticInternalQualifiedGraph, qualification: SyntheticPruningMetrics,
                     qualificationTime: Duration, certificationTime: Duration, elapsed: Duration) {
        completePaths = summary.complete; prefixes = summary.prefixes
        self.observations = observations; qualifiedRides = graph.keys.count
        maximumRailRides = graph.scope.profile.maximumRailRides
        self.qualification = qualification; self.qualificationTime = qualificationTime
        self.certificationTime = certificationTime; self.elapsed = elapsed
    }
}

/// No RouteSearching conformance, solver call, admission, or caller-authored graph/certificate.
nonisolated enum SyntheticDomainCertificateHarness {
    @concurrent
    static func observe(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?,
                        request: RouteSearchRequest,
                        checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void = { _ in }) async throws -> SyntheticDomainCertificateReport {
        try await run(configuration: configuration, view: view, request: request, checkpoint: checkpoint, memoLimit: 4160)
    }
    fileprivate static func run(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?,
                                request: RouteSearchRequest,
                                checkpoint: @escaping @Sendable (SyntheticInternalStage) async throws -> Void,
                                memoLimit: Int,
                                probe: @escaping @Sendable (SyntheticCertificateProbePoint) -> Void = { _ in }) async throws -> SyntheticDomainCertificateReport {
        let start = ContinuousClock.now
        try Task.checkCancellation()
        try SyntheticPruningBounds.validate(configuration, view, request)
        var engine = SyntheticInternalRouteEngine(configuration: configuration, view: view,
            workLimit: SyntheticPruningBounds.workLimit, checkpoint: checkpoint, experiment: .exhaustive)
        let qualificationStart = ContinuousClock.now
        let graph = try await engine.qualifyForCertificate(request)
        let qualificationTime = qualificationStart.duration(to: .now)
        return try certify(graph, qualification: engine.metrics, qualificationTime: qualificationTime,
                           start: start, memoLimit: memoLimit, probe: probe)
    }
    fileprivate static func certify(_ graph: SyntheticInternalQualifiedGraph, qualification: SyntheticPruningMetrics,
                                    qualificationTime: Duration, start: ContinuousClock.Instant, memoLimit: Int,
                                    probe: @escaping @Sendable (SyntheticCertificateProbePoint) -> Void) throws -> SyntheticDomainCertificateReport {
        let certificateStart = ContinuousClock.now
        var observations = SyntheticCertificateObservations()
        // This scope includes kernel setup and release in certificate elapsed time.
        let summary: CertificateSummary = try {
            var kernel = try CertificateKernel(graph: graph, memoLimit: memoLimit, probe: probe)
            let result = try kernel.evaluate()
            observations = kernel.observations
            return result
        }()
        let certificationTime = certificateStart.duration(to: .now)
        try Task.checkCancellation()
        return .init(summary, observations: observations, graph: graph, qualification: qualification,
                     qualificationTime: qualificationTime, certificationTime: certificationTime,
                     elapsed: start.duration(to: .now))
    }
}

// One engine owns qualification and subsequent discovery; no certificate/graph is accepted
// from the experiment's caller, and inherited work is never reset between these stages.
extension SyntheticInternalRouteEngine {
    mutating func prepareCertified(_ request: RouteSearchRequest, memoLimit: Int,
                                   probe: @escaping @Sendable (SyntheticCertificateProbePoint) -> Void) async throws -> (SyntheticInternalPrepared, SyntheticDomainCertificateReport) {
        let start = ContinuousClock.now
        let graph = try await qualifyForCertificate(request)
        let elapsed = start.duration(to: .now)
        recordCertificateQualification(elapsed)
        let report = try SyntheticDomainCertificateHarness.certify(graph, qualification: metrics,
            qualificationTime: elapsed, start: start, memoLimit: memoLimit, probe: probe)
        guard report.withinCompletePathLimit && report.withinPrefixLimit else {
            throw RouteSearchFailure.searchIncomplete
        }
        return (try await discoverCertifiedGraph(graph), report)
    }
}

private nonisolated struct CertificateSummary {
    var complete: Int
    var prefixes: Int
}
private nonisolated struct CertificateState: Hashable {
    let last: Int // exact graph.keys index, including date and original occurrence indices
    let used: UInt16 // recurring TripIDs, not dates
}
private nonisolated struct CertificateKernel {
    let graph: SyntheticInternalQualifiedGraph
    let tripBits: [UInt16]
    let memoLimit: Int
    let probe: @Sendable (SyntheticCertificateProbePoint) -> Void
    var memo: [CertificateState: CertificateSummary] = [:]
    var pending = 0
    var observations = SyntheticCertificateObservations()

    init(graph: SyntheticInternalQualifiedGraph, memoLimit: Int,
         probe: @escaping @Sendable (SyntheticCertificateProbePoint) -> Void) throws {
        guard graph.keys.count <= 32, (1...4).contains(graph.scope.profile.maximumRailRides),
              (0...4160).contains(memoLimit) else { throw SyntheticCertificateHarnessError.boundViolation }
        self.graph = graph; self.memoLimit = memoLimit; self.probe = probe
        var ids: [TripID] = [], bits: [UInt16] = []
        for key in graph.keys {
            try Task.checkCancellation()
            let index: Int
            if let found = ids.firstIndex(of: key.address.tripID) { index = found }
            else {
                guard ids.count < 10 else { throw SyntheticCertificateHarnessError.boundViolation }
                index = ids.count; ids.append(key.address.tripID)
            }
            bits.append(UInt16(1) << index)
        }
        tripBits = bits
    }
    mutating func evaluate() throws -> CertificateSummary {
        var result = CertificateSummary(complete: 0, prefixes: 0)
        for (index, key) in graph.keys.enumerated() {
            try Task.checkCancellation()
            guard graph.rides[key]?.train.anchors.boardingStationID == graph.scope.request.origin else { continue }
            observations.rootRequests += 1
            let value = try summary(.init(last: index, used: tripBits[index]))
            observations.rootScalarAdditions += 2
            result.complete = try SyntheticCertificateSaturation.add(result.complete, value.complete, limit: 65)
            result.prefixes = try SyntheticCertificateSaturation.add(result.prefixes, value.prefixes, limit: 4097)
        }
        return result
    }
    mutating func summary(_ state: CertificateState) throws -> CertificateSummary {
        try Task.checkCancellation()
        observations.memoLookups += 1
        if let old = memo[state] { observations.memoHits += 1; return old }
        guard memo.count + pending < memoLimit, pending < 4,
              graph.keys.indices.contains(state.last), state.used & tripBits[state.last] != 0,
              state.used.nonzeroBitCount <= graph.scope.profile.maximumRailRides else {
            throw SyntheticCertificateHarnessError.boundViolation
        }
        probe(.expansion)
        try Task.checkCancellation()
        pending += 1
        defer { pending -= 1 }
        observations.stateExpansions += 1
        observations.peakPendingFrames = max(observations.peakPendingFrames, pending)
        observations.peakMemoAndPending = max(observations.peakMemoAndPending, memo.count + pending)
        let key = graph.keys[state.last]
        guard let ride = graph.rides[key] else { throw SyntheticCertificateHarnessError.boundViolation }
        observations.destinationTests += 1
        var value = CertificateSummary(complete: ride.train.anchors.alightingStationID == graph.scope.request.destination ? 1 : 0, prefixes: 1)
        // Reaching destination contributes one path; it does NOT terminate expansion.
        if state.used.nonzeroBitCount < graph.scope.profile.maximumRailRides {
            for (index, next) in graph.keys.enumerated() {
                probe(.successor)
                try Task.checkCancellation()
                observations.successorTests += 1
                guard graph.edges[key]?.contains(next) == true, state.used & tripBits[index] == 0 else { continue }
                observations.eligibleTransitions += 1
                let child = try summary(.init(last: index, used: state.used | tripBits[index]))
                observations.childScalarAdditions += 2
                value.complete = try SyntheticCertificateSaturation.add(value.complete, child.complete, limit: 65)
                value.prefixes = try SyntheticCertificateSaturation.add(value.prefixes, child.prefixes, limit: 4097)
            }
        }
        memo[state] = value
        observations.memoWrites += 1
        observations.peakMemoEntries = max(observations.peakMemoEntries, memo.count)
        // Current pending frame is now represented in memo; avoid counting it twice.
        observations.peakMemoAndPending = max(observations.peakMemoAndPending, memo.count + pending - 1)
        return value
    }
}

/// Failure-only guard probe; cannot return a certificate or search result.
nonisolated enum SyntheticCertificateBoundFailureHarness {
    @concurrent
    static func cancelDuring(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?,
                             request: RouteSearchRequest, point: SyntheticCertificateProbePoint) async throws -> Never {
        _ = try await SyntheticDomainCertificateHarness.run(configuration: configuration, view: view,
            request: request, checkpoint: { _ in }, memoLimit: 4160, probe: { current in
                if current == point { withUnsafeCurrentTask { $0?.cancel() } }
            })
        throw SyntheticCertificateHarnessError.expectedFailure
    }
    @concurrent
    static func exhaustMemo(configuration: SyntheticInternalConfiguration?, view: SyntheticInternalView?,
                            request: RouteSearchRequest, entries: Int) async throws -> Never {
        _ = try await SyntheticDomainCertificateHarness.run(configuration: configuration, view: view,
            request: request, checkpoint: { _ in }, memoLimit: entries)
        throw SyntheticCertificateHarnessError.expectedFailure
    }
}
#endif
