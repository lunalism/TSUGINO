#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@Suite(.serialized)
struct SyntheticStandaloneRoutingTests {
    private typealias F = InternalFixture
    private let fixtures = SyntheticDomainCertificateTests()
    private func compare(_ p: SyntheticDomainCertificateTests.Packet) async throws -> SyntheticStandaloneRouteReport {
        let configuration = p.configuration, view = p.view, request = p.request
        let oracle = try await SyntheticPruningRouteExperiment(configuration: configuration,view: view).observeOracleForCertificateTests(request)
        let standalone = try await SyntheticStandaloneRouteExperiment(configuration: configuration,view: view).observe(request)
        if case .internalSuccess(let a) = oracle.result, case .internalSuccess(let b) = standalone.result,
           case .noResults = a.outcome, case .noResults = b.outcome {
            #expect(a.scope.viewID == b.scope.viewID && a.scope.profile.identity == b.scope.profile.identity)
            #expect(a.scope.lowerBound == b.scope.lowerBound && a.scope.upperBound == b.scope.upperBound)
            #expect(a.scope.request.origin == b.scope.request.origin && a.scope.request.destination == b.scope.request.destination)
            #expect(a.scope.request.departNotBefore == b.scope.request.departNotBefore)
        } else {
            _ = try SyntheticPruningExperimentTests().parity(.init(oracle: oracle,
                pruned: .init(result: standalone.result,metrics: standalone.metrics,elapsed: standalone.elapsed),elapsed: .zero))
        }
        #expect(standalone.certificate.completePaths == oracle.metrics.completePaths)
        #expect(standalone.certificate.prefixes == oracle.metrics.prefixes)
        #expect(standalone.metrics.peakFrontierPaths <= 125)
        #expect(standalone.certificate.observations.peakMemoAndPending <= 4160)
        return standalone
    }
    @Test(arguments: [1,2,3],[0,1,2,3]) func layeredWholePipeline(_ q: Int,_ variant: Int) async throws {
        let r = try await compare(fixtures.layered(q,variant: variant))
        #expect(try F.batch(r.result).candidates.count == (variant == 1 ? q*q*q : 1))
        if variant == 3 { #expect(r.metrics.prunedPrefixes > 0) }
    }
    @Test func inputOrderIndependence() async throws {
        let p = fixtures.layered(2,variant: 1)
        let a = try await compare(p)
        let reversed = SyntheticDomainCertificateTests.Packet(items: Array(p.items.reversed()),connections: Array(p.connections.reversed()),cap: p.cap)
        let b = try await compare(reversed)
        #expect(F.keys(try F.batch(a.result)) == F.keys(try F.batch(b.result)))
    }
    @Test func wholeDomainBoundariesAndEmpty() async throws {
        let ties = try await compare(fixtures.layered(2,dates: 2,direct: false))
        let tieCount = try F.batch(ties.result).candidates.count
        #expect(ties.certificate.completePaths == 64 && tieCount == 64)
        for p in [fixtures.layered(2,dates: 2),fixtures.deadEnds()] {
            let s = SyntheticStandaloneRouteExperiment(configuration: p.configuration,view: p.view)
            await #expect { try await s.observe(p.request) } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
            await #expect { try await p.experiment.observeOracleForCertificateTests(p.request) } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
        }
        let empty = try await compare(fixtures.deadEnds(trips: 3,cap: 3))
        #expect(empty.certificate.completePaths == 0 && empty.certificate.prefixes == 78)
    }
    @Test func datesMultiplicityThroughAndRepeatedVisits() async throws {
        let a = F.inventory("first",stops: ["A","B"],times: [100,110])
        let a2 = F.inventory("first",stops: ["A","B"],times: [100,110],label: "second-date")
        let first = SyntheticInternalInventory(trip: a.trip,intervals: a.intervals,slots: a.slots!+a2.slots!)
        let last = F.inventory("last",stops: ["B","D"],times: [120,150])
        let r = try await compare(fixtures.packet([first,last],overrides: [F.present(F.key(a,1,last,0),10),F.present(F.key(a2,1,last,0),10)]))
        let convergedCount = try F.batch(r.result).candidates.count
        #expect(r.certificate.observations.memoHits == 1 && convergedCount == 2)
        let repeated = F.inventory("repeat",stops: ["A","B","A","D"],times: [100,110,120,150],segments: [("L1",0,1),("L2",1,3)])
        let b = try F.batch(await compare(fixtures.packet([repeated])).result)
        #expect(F.keys(b) == [["repeat/d-a/0-3"],["repeat/d-a/2-3"]])
        #expect(b.candidates.allSatisfy { $0.transferCount == 0 })
        let t1 = F.inventory("T",stops: ["A","B","D"],times: [100,110,120],label: "day1")
        let t2 = F.inventory("T",stops: ["A","B","D"],times: [140,150,160],label: "day2")
        let t = SyntheticInternalInventory(trip: t1.trip,intervals: t1.intervals,slots: t1.slots!+t2.slots!)
        let other = F.inventory("other",stops: ["A","B"],times: [100,110])
        let middle = F.inventory("middle",stops: ["B","C"],times: [120,130])
        let u = try await compare(fixtures.packet([t,other,middle],overrides: [F.present(F.key(t1,1,middle,0),10),F.present(F.key(other,1,middle,0),10),F.present(F.key(middle,1,t2,1),20,walking: true)]))
        #expect(u.certificate.completePaths == 3 && u.certificate.prefixes == 8)
    }
    @Test(arguments: [true,false]) func directionalEvidence(_ forward: Bool) async throws {
        let a = F.inventory("a",stops: ["A","B"],times: [100,110])
        let b = F.inventory("b",stops: ["C","D"],times: [120,150])
        let edge = forward ? F.present(F.key(a,1,b,0),10,walking: true) : F.present(F.key(b,0,a,1),10,walking: true)
        let r = try await compare(fixtures.packet([a,b],overrides: [edge]))
        #expect(r.certificate.completePaths == (forward ? 1 : 0))
    }
    @Test(arguments: [0,1,2,3,4]) func unknownSlowerEvidence(_ kind: Int) async throws {
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
        let p = fixtures.packet([good,bad],overrides: kind == 3 ? [.init(key: F.key(good,1,bad,0),state: .unknown)] : [])
        let s = SyntheticStandaloneRouteExperiment(configuration: p.configuration,view: p.view)
        await #expect { try await s.observe(p.request) } throws: { if case RouteSearchFailure.dataUnavailable = $0 { true } else { false } }
        await #expect { try await p.experiment.observeOracleForCertificateTests(p.request) } throws: { if case RouteSearchFailure.dataUnavailable = $0 { true } else { false } }
    }
    @Test func uninterruptedBudgetAndE1() async throws {
        let items = [F.inventory("A-slow",stops: ["A","D"],times: [100,180]),F.inventory("Z-fast",stops: ["A","D"],times: [100,150])]
        let config = F.configuration(trips: ["A-slow","Z-fast"],cap: 1,duration: 200,stations: ["A","D"],lines: ["L1"])
        let view = F.view(items), request = F.request(at: 0), recorder = StandaloneStages()
        let s = SyntheticStandaloneRouteExperiment(configuration: config,view: view,workLimit: 47,checkpoint: { await recorder.record($0) })
        let r = try await s.observe(request)
        #expect(r.metrics.qualificationWork+r.metrics.discoveryWork+r.metrics.postWork == 47)
        let configurations = await recorder.configurations, calls = await recorder.calls
        #expect(configurations == 1 && calls == 47)
        #expect(r.certificate.qualification.qualificationWork == 26)
        #expect(F.keys(try F.batch(r.result)) == [["Z-fast/d-a/0-1"]])
        await #expect { try await SyntheticPruningRouteExperiment(configuration: config,view: view,workLimit: 47).observeOracleForCertificateTests(request) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
        for budget in [0,26,46] {
            await #expect { try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,workLimit: budget).observe(request) } throws: {
                if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
            }
        }
    }
    @Test func guardAndCancellationAborts() async throws {
        let p = fixtures.layered(2,variant: 1), s = SyntheticStandaloneRouteExperiment(configuration: p.configuration,view: p.view)
        for budget in [-1,200001] {
            await #expect { try await SyntheticStandaloneRouteExperiment(configuration: p.configuration,view: p.view,workLimit: budget).observe(p.request) } throws: {
                if case RouteSearchFailure.configurationUnavailable = $0 { true } else { false }
            }
        }
        for entries in [0,1,4161] {
            await #expect { try await SyntheticStandaloneFailureHarness.exercise(s,request: p.request,memoLimit: entries) } throws: {
                if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
            }
        }
        for point in [SyntheticCertificateProbePoint.expansion,.successor] {
            let task = Task { try await SyntheticStandaloneFailureHarness.exercise(s,request: p.request,cancelAt: point) }
            await #expect(throws: CancellationError.self) { try await task.value }
        }
        for stage in [SyntheticInternalStage.coverage,.generation,.deduplication,.sorting,.admission,.finish] {
            for cancel in [true,false] {
                let v = SyntheticStandaloneRouteExperiment(configuration: p.configuration,view: p.view,checkpoint: { current in
                    if current == stage { if cancel { throw CancellationError() }; throw F.FixtureError.cutoff }
                })
                await #expect { try await v.observe(p.request) } throws: { error in
                    if cancel { return error is CancellationError }
                    if case RouteSearchFailure.searchIncomplete = error { return true }; return false
                }
            }
        }
        let tooMany = fixtures.packet((0..<11).map { F.inventory("t\($0)",stops: ["A","D"],times: [100,150]) })
        await #expect { try await SyntheticStandaloneRouteExperiment(configuration: tooMany.configuration,view: tooMany.view).observe(tooMany.request) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
    }
    @Test(arguments: [[0],[0,1]]) func selectedRejections(_ indices: [Int]) async throws {
        let p = fixtures.packet([F.inventory("a",stops: ["A","D"],times: [100,150]),F.inventory("b",stops: ["A","D"],times: [100,150])])
        for standalone in [true,false] {
            do {
                if standalone { try await SyntheticStandaloneFailureHarness.exercise(.init(configuration: p.configuration,view: p.view),request: p.request,rejecting: Set(indices)) }
                else { try await SyntheticPruningRejectionHarness.reject(p.experiment,request: p.request,indices: Set(indices)) }
            } catch RouteSearchFailure.searchIncomplete { #expect(indices.count == 1) }
            catch RouteSearchFailure.noUsableAlternatives(let rejected) {
                #expect(indices.count == 2 && rejected.omissions.map(\.alternativeIndex) == [0,1])
                #expect(rejected.omissions.allSatisfy { $0.reasons == [.inconsistentTrainEvidence] })
            }
        }
    }
    @Test func wholePipelineMeasurements() async throws {
        var packets: [(String,SyntheticDomainCertificateTests.Packet)] = []
        for q in [1,2,3] { for v in [0,1,2,3] { packets.append(("q\(q)v\(v)",fixtures.layered(q,variant: v))) } }
        packets.append(("ties64",fixtures.layered(2,dates: 2,direct: false)))
        for (name,p) in packets {
            let config = p.configuration, view = p.view, request = p.request
            let s = SyntheticStandaloneRouteExperiment(configuration: config,view: view)
            let o = SyntheticPruningRouteExperiment(configuration: config,view: view)
            _ = try await s.observe(request); _ = try await o.observeOracleForCertificateTests(request)
            for repetition in 0..<5 {
                let begin = ContinuousClock.now
                let a = try await s.observe(request)
                let sw = begin.duration(to: .now), ob = ContinuousClock.now
                let b = try await o.observeOracleForCertificateTests(request)
                let ow = ob.duration(to: .now), total = begin.duration(to: .now)
                let batch = try SyntheticPruningExperimentTests().parity(.init(oracle: b,pruned: .init(result: a.result,metrics: a.metrics,elapsed: a.elapsed),elapsed: total))
                let m = a.metrics, n = b.metrics, c = a.certificate.observations
                print("STAND name=\(name) rep=\(repetition) output=\(batch.candidates.count) C=\(a.certificate.completePaths) P=\(a.certificate.prefixes) roots=\(c.rootRequests) lookup=\(c.memoLookups) hits=\(c.memoHits) expand=\(c.stateExpansions) destination=\(c.destinationTests) successors=\(c.successorTests) edges=\(c.eligibleTransitions) childAdds=\(c.childScalarAdditions) rootAdds=\(c.rootScalarAdditions) writes=\(c.memoWrites) memo=\(c.peakMemoEntries) depth=\(c.peakPendingFrames) R=\(m.qualifiedRides) E=\(m.qualifiedEdges) Squal=\(m.qualificationWork) Sdiscovery=\(m.discoveryWork) Spost=\(m.postWork) Sprefix=\(m.prefixes) Spruned=\(m.prunedPrefixes) Sfrontier=\(m.peakFrontierPaths) Spaths=\(m.peakCompletePaths) SfrontierKeys=\(m.peakFrontierKeys) SpathKeys=\(m.peakCompleteKeys) Skernel=\(m.kernelAdvances) Oqual=\(n.qualificationWork) Odiscovery=\(n.discoveryWork) Opost=\(n.postWork) Oprefix=\(n.prefixes) Ofrontier=\(n.peakFrontierPaths) Opaths=\(n.peakCompletePaths) OfrontierKeys=\(n.peakFrontierKeys) OpathKeys=\(n.peakCompleteKeys) Okernel=\(n.kernelAdvances) Sqtime=\(m.qualificationTime) Sctime=\(a.certificate.certificationTime) Sdtime=\(m.discoveryTime) Sstime=\(m.selectionTime) Satime=\(m.admissionTime) Oqtime=\(n.qualificationTime) Odtime=\(n.discoveryTime) Ostime=\(n.selectionTime) Oatime=\(n.admissionTime) Swhole=\(sw) Owhole=\(ow) paired=\(total)")
            }
        }
    }
}
private actor StandaloneStages {
    var configurations = 0
    var calls = 0
    func record(_ stage: SyntheticInternalStage) { calls += 1; if stage == .configuration { configurations += 1 } }
}
#endif
