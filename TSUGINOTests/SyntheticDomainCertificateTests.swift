#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@Suite(.serialized)
struct SyntheticDomainCertificateTests {
    private typealias F = InternalFixture
    private struct Packet {
        let items: [SyntheticInternalInventory]
        let connections: [SyntheticInternalConnection]
        var cap = 3
        var configuration: SyntheticInternalConfiguration {
            F.configuration(trips: Array(Set(items.map { $0.trip.id.rawValue })),cap: cap,duration: 2400,
                            stations: ["A","B","C","D","X","Y"])
        }
        var view: SyntheticInternalView { F.view(items,connections: connections,until: 2501) }
        var request: RouteSearchRequest { F.request(at: 0) }
        var experiment: SyntheticPruningRouteExperiment { .init(configuration: configuration,view: view) }
        func certificate() async throws -> SyntheticDomainCertificateReport {
            try await SyntheticDomainCertificateHarness.observe(configuration: configuration,view: view,request: request)
        }
    }
    private func packet(_ items: [SyntheticInternalInventory], overrides: [SyntheticInternalConnection] = [], cap: Int = 3) -> Packet {
        .init(items: items,connections: F.connections(items,overrides: overrides),cap: cap)
    }
    private func layered(_ q: Int, variant: Int = 0, dates: Int = 1, direct: Bool = true) -> Packet {
        let stationPairs = [["A","X"],["X","Y"],["Y","D"]]
        let times: [[Double]] = [[60,300],[360,variant == 3 ? 1800 : 600], [variant == 3 ? 1860 : 660,variant == 3 ? 2100 : 1200]]
        var layers: [[SyntheticInternalInventory]] = []
        for layer in 0..<3 {
            layers.append((0..<q).map { index in
                let a = F.inventory("L\(layer)-\(index)",stops: stationPairs[layer],times: times[layer])
                if dates == 1 { return a }
                let b = F.inventory(a.trip.id.rawValue,stops: stationPairs[layer],times: times[layer],label: "second-date")
                return .init(trip: a.trip,intervals: a.intervals,slots: a.slots!+b.slots!)
            })
        }
        var items = layers.flatMap { $0 }, overrides: [SyntheticInternalConnection] = []
        for layer in 0..<2 { for a in layers[layer] { for b in layers[layer+1] {
            for sa in a.slots! { for sb in b.slots! {
                overrides.append(.init(key: .init(alighting: .init(address: sa.address,index: 1),boarding: .init(address: sb.address,index: 0)),
                                       state: .present(.sameStation,F.allowance(60),.affirmed)))
            } }
        } } }
        if direct { items.append(F.inventory("Z-direct",stops: ["A","D"],times: [120,[900,1500,1200,900][variant]])) }
        return packet(items,overrides: overrides)
    }
    private func assertBounds(_ report: SyntheticDomainCertificateReport, oracle: SyntheticPruningPass? = nil) {
        let o = report.observations
        #expect(o.memoWrites == o.stateExpansions && o.peakMemoEntries == o.memoWrites)
        #expect(o.memoLookups == o.stateExpansions + o.memoHits)
        #expect(o.childScalarAdditions == 2*o.eligibleTransitions)
        #expect(o.peakMemoAndPending <= 4160 && o.peakPendingFrames <= 4)
        if let oracle {
            let r = report.qualifiedRides, m = report.maximumRailRides
            let bound = r == 0 ? 0 : r+(m-1)*(r-1)
            #expect(oracle.metrics.peakFrontierPaths <= bound && bound <= 125)
            #expect(report.completePaths == oracle.metrics.completePaths)
            #expect(report.prefixes == oracle.metrics.prefixes)
        }
    }
    @Test(arguments: [1,2,3], [0,1,2,3]) func layeredCountsAndOptimalOutputs(_ q: Int, _ variant: Int) async throws {
        let p = layered(q,variant: variant)
        let c = try await p.certificate()
        let o = try await p.experiment.observeOracleForCertificateTests(p.request)
        assertBounds(c,oracle: o)
        #expect(c.completePaths == q*q*q+1 && c.prefixes == 1+q+q*q+q*q*q)
        #expect(c.withinCompletePathLimit && c.withinPrefixLimit)
        let batch = try F.batch(o.result)
        #expect(batch.candidates.count == (variant == 1 ? q*q*q : 1))
        // Normal published oracle separately; certificate never calls either path.
        let unchanged = SyntheticOptimalRouteSearcher(configuration: p.configuration,view: p.view,workLimit: 200_000)
        #expect(F.keys(try F.batch(await unchanged.search(p.request))) == F.keys(batch))
    }
    @Test(arguments: [false,true]) func exact64And65(_ direct: Bool) async throws {
        let p = layered(2,dates: 2,direct: direct)
        let c = try await p.certificate()
        #expect(c.completePaths == (direct ? 65 : 64) && c.prefixes == (direct ? 85 : 84))
        #expect(c.withinCompletePathLimit == !direct && c.withinPrefixLimit)
        if direct {
            await #expect { try await p.experiment.observeOracleForCertificateTests(p.request) } throws: {
                if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
            }
            let old = SyntheticOptimalRouteSearcher(configuration: p.configuration,view: p.view,workLimit: 200_000)
            await #expect { try await old.search(p.request) } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
        } else {
            let o = try await p.experiment.observeOracleForCertificateTests(p.request)
            assertBounds(c,oracle: o)
            #expect(try F.batch(o.result).candidates.count == 64)
        }
    }
    private func deadEnds(trips: Int = 10, cap: Int = 4) -> Packet {
        let items = (0..<trips).map { index -> SyntheticInternalInventory in
            let a = F.inventory("t\(index)",stops: ["A","B"],times: [100,100])
            let b = F.inventory("t\(index)",stops: ["A","B"],times: [100,100],label: "second-date")
            return .init(trip: a.trip,intervals: a.intervals,slots: a.slots!+b.slots!)
        }
        let connections = F.connections(items).map { SyntheticInternalConnection(key: $0.key,state: .present(.walking,F.allowance(0),.affirmed)) }
        return .init(items: items,connections: connections,cap: cap)
    }
    @Test func deadEndPrefixPredicateAndMultiplicity() async throws {
        let p = deadEnds(), c = try await p.certificate()
        #expect(p.connections.count == 360)
        let expectedPrefixes: Int = 20 + 360 + 5760 + 80640
        #expect(expectedPrefixes == 86780)
        #expect(c.completePaths == 0 && c.prefixes == 4097)
        #expect(c.withinCompletePathLimit && !c.withinPrefixLimit)
        #expect(c.observations.memoHits > 0)
        assertBounds(c)
        let small = deadEnds(trips: 3,cap: 3)
        let sc = try await small.certificate(), so = try await small.experiment.observeOracleForCertificateTests(small.request)
        assertBounds(sc,oracle: so)
        #expect(sc.prefixes == 6+24+48 && sc.completePaths == 0 && sc.observations.memoHits > 0)
        // Existing experimental exhaustive path aborts at its unchanged 4096 guard.
        await #expect { try await p.experiment.observeOracleForCertificateTests(p.request) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
    }
    @Test func convergingHistoriesDoNotLoseIncomingMultiplicity() async throws {
        // Two dates of the same recurring first Trip converge on one suffix state.
        let a = F.inventory("first",stops: ["A","B"],times: [100,110])
        let a2 = F.inventory("first",stops: ["A","B"],times: [100,110],label: "second-date")
        let first = SyntheticInternalInventory(trip: a.trip,intervals: a.intervals,slots: a.slots!+a2.slots!)
        let last = F.inventory("last",stops: ["B","D"],times: [120,150])
        let p = packet([first,last],overrides: [F.present(F.key(a,1,last,0),10),F.present(F.key(a2,1,last,0),10)])
        let c = try await p.certificate(), o = try await p.experiment.observeOracleForCertificateTests(p.request)
        assertBounds(c,oracle: o)
        #expect(c.completePaths == 2 && c.prefixes == 4)
        #expect(c.observations.stateExpansions == 3 && c.observations.memoHits == 1)
        #expect(c.observations.memoLookups == 4 && c.observations.childScalarAdditions == 4)
        #expect(try F.batch(o.result).candidates.count == 2)
    }
    @Test func usedTripSetSeparatesDifferentFuturePermissions() async throws {
        let t1 = F.inventory("T",stops: ["A","B","D"],times: [100,110,120],label: "day1")
        let t2 = F.inventory("T",stops: ["A","B","D"],times: [140,150,160],label: "day2")
        let t = SyntheticInternalInventory(trip: t1.trip,intervals: t1.intervals,slots: t1.slots!+t2.slots!)
        let other = F.inventory("other",stops: ["A","B"],times: [100,110])
        let middle = F.inventory("middle",stops: ["B","C"],times: [120,130])
        let p = packet([t,other,middle],overrides: [F.present(F.key(t1,1,middle,0),10),F.present(F.key(other,1,middle,0),10),F.present(F.key(middle,1,t2,1),20,walking: true)])
        let c = try await p.certificate(), o = try await p.experiment.observeOracleForCertificateTests(p.request)
        assertBounds(c,oracle: o)
        #expect(c.completePaths == 3 && c.prefixes == 8)
        // T(day1)->middle cannot reuse T(day2); other->middle->T(day2) can.
    }
    @Test func destinationIsCountedButDoesNotTerminate() async throws {
        let a = F.inventory("a",stops: ["A","D"],times: [100,110])
        let b = F.inventory("b",stops: ["D","B"],times: [110,120])
        let c = F.inventory("c",stops: ["B","D"],times: [120,130])
        let p = packet([a,b,c],overrides: [F.present(F.key(a,1,b,0),0),F.present(F.key(b,1,c,0),0)])
        let result = try await p.certificate(), o = try await p.experiment.observeOracleForCertificateTests(p.request)
        assertBounds(result,oracle: o)
        #expect(result.completePaths == 2 && result.prefixes == 3)
    }
    @Test func repeatedOccurrencesThroughAndDirection() async throws {
        let repeated = F.inventory("repeat",stops: ["A","B","A","D"],times: [100,110,120,150],segments: [("L1",0,1),("L2",1,3)])
        let p = packet([repeated])
        let c = try await p.certificate(), o = try await p.experiment.observeOracleForCertificateTests(p.request)
        assertBounds(c,oracle: o)
        #expect(c.completePaths == 2 && c.prefixes == 3) // A@0->B, A@0->D, A@2->D
        #expect(F.keys(try F.batch(o.result)) == [["repeat/d-a/0-3"],["repeat/d-a/2-3"]])
        #expect(try F.batch(o.result).candidates.allSatisfy { $0.transferCount == 0 })
        let a = F.inventory("a",stops: ["A","B"],times: [100,110])
        let b = F.inventory("b",stops: ["C","D"],times: [120,150])
        for forward in [true,false] {
            let relation = forward ? F.present(F.key(a,1,b,0),10,walking: true) : F.present(F.key(b,0,a,1),10,walking: true)
            let p = packet([a,b],overrides: [relation]), r = try await p.certificate()
            let o = try await p.experiment.observeOracleForCertificateTests(p.request)
            assertBounds(r,oracle: o)
            #expect(r.completePaths == (forward ? 1 : 0))
        }
    }
    @Test(arguments: [0,1,2,3,4]) func qualificationFailuresAreNotPruned(_ kind: Int) async throws {
        let good = F.inventory("Z-good",stops: ["A","D"],times: [100,150])
        let raw = F.inventory("bad",stops: ["B","C"],times: [200,300])
        let bad: SyntheticInternalInventory
        switch kind {
        case 0: bad = .init(trip: raw.trip,intervals: nil,slots: nil)
        case 1: bad = .init(trip: raw.trip,intervals: raw.intervals,slots: [.init(address: raw.slots![0].address,activation: .unavailable)])
        case 2: bad = F.inventory("bad",stops: ["B","C"],times: [200,300],departures: [.missing,.missing])
        case 4: bad = F.inventory("bad",stops: ["B","C"],times: [200,300],departures: [.estimated(TimetableInstant(F.date(200))!),.missing])
        default: bad = raw
        }
        let p = packet([good,bad],overrides: kind == 3 ? [.init(key: F.key(good,1,bad,0),state: .unknown)] : [])
        await #expect { try await p.certificate() } throws: { if case RouteSearchFailure.dataUnavailable = $0 { true } else { false } }
        await #expect { try await p.experiment.observeOracleForCertificateTests(p.request) } throws: { if case RouteSearchFailure.dataUnavailable = $0 { true } else { false } }
    }
    @Test func saturationAndMemoGuardCannotManufactureSuccess() async throws {
        for cap in [65,4097,Int.max] {
            #expect(try SyntheticCertificateSaturation.add(cap-1,0,limit: cap) == cap-1)
            #expect(try SyntheticCertificateSaturation.add(cap-1,1,limit: cap) == cap)
            #expect(try SyntheticCertificateSaturation.add(Int.max,Int.max,limit: cap) == cap)
        }
        #expect(throws: SyntheticCertificateHarnessError.self) { try SyntheticCertificateSaturation.add(-1,1,limit: 65) }
        #expect(throws: SyntheticCertificateHarnessError.self) { try SyntheticCertificateSaturation.add(0,0,limit: 0) }
        let p = layered(1)
        for cap in [0,1,4161] {
            await #expect { try await SyntheticCertificateBoundFailureHarness.exhaustMemo(configuration: p.configuration,view: p.view,request: p.request,entries: cap) } throws: {
                if case SyntheticCertificateHarnessError.boundViolation = $0 { true } else { false }
            }
        }
        for point in [SyntheticCertificateProbePoint.expansion,.successor] {
            let task = Task {
                try await SyntheticCertificateBoundFailureHarness.cancelDuring(configuration: p.configuration,view: p.view,request: p.request,point: point)
            }
            await #expect(throws: CancellationError.self) { try await task.value }
        }
        await #expect(throws: CancellationError.self) {
            try await SyntheticDomainCertificateHarness.observe(configuration: p.configuration,view: p.view,request: p.request,checkpoint: { _ in throw CancellationError() })
        }
    }
    @Test func handCountedUnitsRemainSeparateAndNoDiscoveryOccurs() async throws {
        let items = [F.inventory("A-slow",stops: ["A","D"],times: [100,180]),F.inventory("Z-fast",stops: ["A","D"],times: [100,150])]
        let config = F.configuration(trips: ["A-slow","Z-fast"],cap: 1,duration: 200,stations: ["A","D"],lines: ["L1"])
        let view = F.view(items), request = F.request(at: 0), recorder = CertificateStageRecorder()
        let c = try await SyntheticDomainCertificateHarness.observe(configuration: config,view: view,request: request,checkpoint: { await recorder.record($0) })
        #expect(c.qualification.qualificationWork == 26)
        let calls = await recorder.calls, forbidden = await recorder.forbidden
        #expect(calls == 26 && !forbidden)
        let x = c.observations
        #expect(x.rootRequests == 2 && x.memoLookups == 2 && x.memoHits == 0)
        #expect(x.stateExpansions == 2 && x.destinationTests == 2 && x.memoWrites == 2)
        #expect(x.successorTests == 0 && x.childScalarAdditions == 0 && x.rootScalarAdditions == 4)
        let s = SyntheticPruningRouteExperiment(configuration: config,view: view)
        let result = try await s.compare(request)
        let e = result.oracle.metrics, p = result.pruned.metrics
        #expect(e.qualificationWork+e.discoveryWork+e.postWork == 51)
        #expect(p.qualificationWork+p.discoveryWork+p.postWork == 47)
        #expect(c.completePaths == 2 && c.prefixes == 2)
        let reversed = try await SyntheticDomainCertificateHarness.observe(configuration: config,view: F.view(Array(items.reversed())),request: request)
        #expect(reversed.completePaths == c.completePaths && reversed.prefixes == c.prefixes)
    }
    @Test func memoAndFrontierBoundDerivations() {
        // Independent enumeration of all permitted (last ride,used Trip set) shapes.
        let containingLast = (0..<1024).filter { $0 & 1 != 0 && $0.nonzeroBitCount <= 4 }.count
        #expect(containingLast == 130 && 32*containingLast == 4160)
        // LIFO frontier consists of unpopped roots plus sibling lists on <=M-1 levels.
        for roots in 0...32 { for depth in 1...4 {
            let pending = roots + (depth-1)*31
            #expect(pending <= 125)
        } }
        #expect(32 + 3*31 == 125)
    }
    @Test func observationsAndTiming() async throws {
        // One warmup, five measured repetitions, no elapsed-time pass threshold.
        // Fixture construction outside timing. Certificate has no oracle reference.
        var packets: [(String,Packet)] = []
        for q in [1,2,3] { for v in [0,1,2,3] { packets.append(("q\(q)v\(v)",layered(q,variant: v))) } }
        packets.append(("ties64",layered(2,dates: 2,direct: false)))
        for (name,p) in packets {
            let configuration = p.configuration, view = p.view, request = p.request
            let experiment = SyntheticPruningRouteExperiment(configuration: configuration,view: view)
            _ = try await SyntheticDomainCertificateHarness.observe(configuration: configuration,view: view,request: request)
            _ = try await experiment.observeOracleForCertificateTests(request)
            for repetition in 0..<5 {
                let start = ContinuousClock.now
                let c = try await SyntheticDomainCertificateHarness.observe(configuration: configuration,view: view,request: request)
                let certificateWhole = start.duration(to: .now)
                let oracleStart = ContinuousClock.now
                let o = try await experiment.observeOracleForCertificateTests(request)
                let oracleWhole = oracleStart.duration(to: .now)
                let whole = start.duration(to: .now)
                assertBounds(c,oracle: o)
                let x = c.observations
                print("CERT name=\(name) rep=\(repetition) C=\(c.completePaths) P=\(c.prefixes) roots=\(x.rootRequests) lookup=\(x.memoLookups) hits=\(x.memoHits) expand=\(x.stateExpansions) destination=\(x.destinationTests) successor=\(x.successorTests) edges=\(x.eligibleTransitions) childAdds=\(x.childScalarAdditions) rootAdds=\(x.rootScalarAdditions) writes=\(x.memoWrites) memoPeak=\(x.peakMemoEntries) pendingPeak=\(x.peakPendingFrames) combinedPeak=\(x.peakMemoAndPending) qualSteps=\(c.qualification.qualificationWork) oracleQual=\(o.metrics.qualificationWork) oracleDiscovery=\(o.metrics.discoveryWork) oraclePost=\(o.metrics.postWork) frontier=\(o.metrics.peakFrontierPaths) retained=\(o.metrics.peakCompletePaths) output=\(try F.batch(o.result).candidates.count) qualTime=\(c.qualificationTime) certTime=\(c.certificationTime) certWhole=\(certificateWhole) oracleQualTime=\(o.metrics.qualificationTime) oracleDiscoveryTime=\(o.metrics.discoveryTime) oracleSelectionTime=\(o.metrics.selectionTime) oracleAdmissionTime=\(o.metrics.admissionTime) oracleWhole=\(oracleWhole) whole=\(whole)")
            }
        }
        for (name,p) in [("paths65",layered(2,dates: 2)),("dead86780",deadEnds())] {
            let configuration = p.configuration, view = p.view, request = p.request
            let experiment = SyntheticPruningRouteExperiment(configuration: configuration,view: view)
            _ = try await SyntheticDomainCertificateHarness.observe(configuration: configuration,view: view,request: request)
            do { _ = try await experiment.observeOracleForCertificateTests(request); Issue.record("Expected oracle domain guard") }
            catch RouteSearchFailure.searchIncomplete {}
            for repetition in 0..<5 {
                let start = ContinuousClock.now
                let c = try await SyntheticDomainCertificateHarness.observe(configuration: configuration,view: view,request: request)
                let certificateWhole = start.duration(to: .now)
                let oracleStart = ContinuousClock.now
                do { _ = try await experiment.observeOracleForCertificateTests(request); Issue.record("Expected oracle domain guard") }
                catch RouteSearchFailure.searchIncomplete {}
                let oracleWhole = oracleStart.duration(to: .now), whole = start.duration(to: .now)
                #expect(!c.withinCompletePathLimit || !c.withinPrefixLimit)
                let x = c.observations
                print("CERT_FAILURE name=\(name) rep=\(repetition) C=\(c.completePaths) P=\(c.prefixes) roots=\(x.rootRequests) lookup=\(x.memoLookups) hits=\(x.memoHits) expand=\(x.stateExpansions) destination=\(x.destinationTests) successor=\(x.successorTests) edges=\(x.eligibleTransitions) childAdds=\(x.childScalarAdditions) rootAdds=\(x.rootScalarAdditions) writes=\(x.memoWrites) memoPeak=\(x.peakMemoEntries) pendingPeak=\(x.peakPendingFrames) combinedPeak=\(x.peakMemoAndPending) qualSteps=\(c.qualification.qualificationWork) qualTime=\(c.qualificationTime) certTime=\(c.certificationTime) certWhole=\(certificateWhole) oracleWhole=\(oracleWhole) whole=\(whole) outcome=searchIncomplete")
            }
        }

    }
}
private actor CertificateStageRecorder {
    private(set) var calls = 0
    private(set) var forbidden = false
    func record(_ stage: SyntheticInternalStage) {
        calls += 1
        if stage == .generation || stage == .admission || stage == .finish || stage == .deduplication || stage == .sorting { forbidden = true }
    }
}
#endif
