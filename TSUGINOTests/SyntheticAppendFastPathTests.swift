#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@Suite(.serialized)
struct SyntheticAppendFastPathTests {
    private typealias F = InternalFixture
    private let fixtures = SyntheticDomainCertificateTests()
    private func packet(_ n: Int) -> SyntheticDomainCertificateTests.Packet {
        n == 64 ? fixtures.layered(2, dates: 2, direct: false) : fixtures.layered(n == 27 ? 3 : n == 8 ? 2 : 1, direct: false)
    }
    private func descriptor(_ name: String, arrival: Double = 150) throws -> SyntheticOptimalRouteDescriptor {
        let item = F.inventory(name, stops: ["A","D"], times: [100,arrival])
        guard case .active(let facts, _) = item.slots![0].activation,
              let train = TrainCandidate(trip: item.trip, boardingIndex: 0, alightingIndex: 1),
              let context = TimetableRideContext(train: train, facts: facts) else { throw F.FixtureError.expectedBatch }
        return .init(contexts: [context], forms: [])
    }
    private func ordered<T>(_ a: [T], _ order: Int) -> [T] {
        if order == 1 { return Array(a.reversed()) }
        if order == 2 { return a.enumerated().filter { $0.offset % 2 == 1 }.map(\.element) + a.enumerated().filter { $0.offset % 2 == 0 }.map(\.element) }
        return a
    }
    private func invariant(_ indices: [Int], _ d: [SyntheticOptimalRouteDescriptor]) {
        #expect(Set(indices.map { d[$0].key }).count == indices.count)
        for pair in zip(indices,indices.dropFirst()) {
            #expect(d[pair.0].key.lexicographicallyPrecedes(d[pair.1].key, by: SyntheticOptimalRouteAtom.less))
        }
    }
    @Test(arguments: [0,1,2]) func kernelBoundariesAndInvariant(_ order: Int) throws {
        let values = try (0..<64).map { try descriptor(String(repeating: "p", count: 120)+String(format: "%02d",$0)) }
        for input in [[], [values[0]], ordered(values,order), ordered([values[0],values[3],values[0],values[1],values[3]],order),
                      [try descriptor("slow",arrival: 180),values[3],values[1],try descriptor("worse",arrival: 200),values[0],values[1]],
                      [try descriptor("a"),try descriptor("aa"),try descriptor("aaa"),try descriptor("a")]] {
            for profiling in [false,true] {
                var baseline = SyntheticOptimalRouteKernel(input,profiling: profiling)
                var optimized = SyntheticAppendFastPathKernel(input,profiling: profiling)
                while !baseline.isComplete { baseline.advance() }
                var advances = 0
                while !optimized.isComplete {
                    optimized.advance(); advances += 1
                    invariant(optimized.winners,input)
                    #expect(advances <= 5000) // assertion only; reviewed <=64 descriptor bound
                }
                #expect(optimized.winners == baseline.winners)
                #expect(optimized.profile.objectives == baseline.profile.objectives)
                if profiling && input.count == 64 && order == 0 {
                    #expect(optimized.profile.fastChecks == 63 && optimized.profile.fastAppends == 63)
                    #expect(optimized.profile.equalities == 0 && optimized.profile.orders == 0)
                }
                if profiling && input.count == 64 && order == 1 {
                    #expect(optimized.profile.fastChecks == 63 && optimized.profile.fastAppends == 0)
                    #expect(optimized.profile.equalities == baseline.profile.equalities)
                }
            }
        }
    }
    @Test(arguments: [1,8,27,64]) func canonicalPipelineAgreement(_ n: Int) async throws {
        let p = packet(n), config = p.configuration, view = p.view, request = p.request
        let oracle = try await SyntheticPruningRouteExperiment(configuration: config,view: view).observeOracleForCertificateTests(request)
        for mode in [SyntheticSelectionVariant.reference,.appendFastPath] {
            let r = try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,profileSelection: true,selectionVariant: mode).observe(request)
            let b = try SyntheticPruningExperimentTests().parity(.init(oracle: oracle,pruned: .init(result: r.result,metrics: r.metrics,elapsed: r.elapsed),elapsed: .zero))
            #expect(b.candidates.count == n)
            #expect(r.certificate.completePaths == oracle.metrics.completePaths)
        }
    }
    @Test func emptyRepeatedDatesAndThroughService() async throws {
        let a = F.inventory("repeat",stops: ["A","B","A","D"],times: [100,110,120,150],label: "day1")
        let b = F.inventory("repeat",stops: ["A","B","A","D"],times: [100,110,120,150],label: "day2")
        let repeatTrip = SyntheticInternalInventory(trip: a.trip,intervals: a.intervals,slots: a.slots!+b.slots!)
        let through = F.inventory("through",stops: ["A","B","D"],times: [100,110,150],segments: [("L1",0,1),("L2",1,2)])
        let p = fixtures.packet([repeatTrip,through]), config = p.configuration, view = p.view, request = p.request
        let oracle = try await SyntheticPruningRouteExperiment(configuration: config,view: view).observeOracleForCertificateTests(request)
        let r = try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,selectionVariant: .appendFastPath).observe(request)
        let batch = try SyntheticPruningExperimentTests().parity(.init(oracle: oracle,pruned: .init(result: r.result,metrics: r.metrics,elapsed: r.elapsed),elapsed: .zero))
        #expect(batch.candidates.count == 5 && batch.candidates.allSatisfy { $0.transferCount == 0 })
        let empty = fixtures.deadEnds(trips: 3,cap: 3), ec = empty.configuration, ev = empty.view, er = empty.request
        let x = try await SyntheticStandaloneRouteExperiment(configuration: ec,view: ev,selectionVariant: .appendFastPath).observe(er)
        let y = try await SyntheticPruningRouteExperiment(configuration: ec,view: ev).observeOracleForCertificateTests(er)
        guard case .internalSuccess(let xs) = x.result, case .noResults = xs.outcome,
              case .internalSuccess(let ys) = y.result, case .noResults = ys.outcome else {
            Issue.record("Proven empty domain changed"); return
        }
        #expect(xs.scope.viewID == ys.scope.viewID && xs.scope.lowerBound == ys.scope.lowerBound && xs.scope.upperBound == ys.scope.upperBound)
        #expect(x.certificate.completePaths == 0)
    }
    @Test(arguments: [[0],[0,1]]) func selectedRejections(_ indices: [Int]) async throws {
        let p = fixtures.packet([F.inventory("a",stops: ["A","D"],times: [100,150]),F.inventory("b",stops: ["A","D"],times: [100,150])])
        let config = p.configuration, view = p.view, request = p.request
        for mode in [SyntheticSelectionVariant.reference,.appendFastPath] {
            do {
                try await SyntheticStandaloneFailureHarness.exercise(.init(configuration: config,view: view,selectionVariant: mode),request: request,rejecting: Set(indices))
            } catch RouteSearchFailure.searchIncomplete { #expect(indices.count == 1) }
            catch RouteSearchFailure.noUsableAlternatives(let rejected) {
                #expect(indices.count == 2 && rejected.omissions.map(\.alternativeIndex) == [0,1])
                #expect(rejected.omissions.allSatisfy { $0.reasons == [.inconsistentTrainEvidence] })
            }
        }
    }
    @Test func safeguardsCancellationAndE1() async throws {
        let p = fixtures.packet([F.inventory("a",stops: ["A","D"],times: [100,150]),F.inventory("b",stops: ["A","D"],times: [100,150])]), config = p.configuration, view = p.view, request = p.request
        let baseline = try await SyntheticStandaloneRouteExperiment(configuration: config,view: view).observe(request)
        let optimized = try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,selectionVariant: .appendFastPath).observe(request)
        let charged = optimized.metrics.qualificationWork+optimized.metrics.discoveryWork+optimized.metrics.postWork
        let oldCharged = baseline.metrics.qualificationWork+baseline.metrics.discoveryWork+baseline.metrics.postWork
        #expect(charged < oldCharged)
        _ = try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,workLimit: charged,selectionVariant: .appendFastPath).observe(request)
        for (mode,budget) in [(SyntheticSelectionVariant.reference,charged),(.appendFastPath,charged-1),(.appendFastPath,0)] {
            await #expect { try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,workLimit: budget,selectionVariant: mode).observe(request) } throws: {
                if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
            }
        }
        print("APPEND_E1 reference=\(oldCharged) optimized=\(charged)")
        let s = SyntheticStandaloneRouteExperiment(configuration: config,view: view,selectionVariant: .appendFastPath)
        await #expect { try await SyntheticStandaloneFailureHarness.exercise(s,request: request,memoLimit: 0) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
        for stage in [SyntheticInternalStage.sorting,.admission,.finish] {
            await #expect(throws: CancellationError.self) {
                try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,selectionVariant: .appendFastPath,checkpoint: {
                    if $0 == stage { throw CancellationError() }
                }).observe(request)
            }
        }
        for bad in [fixtures.layered(2,dates: 2),fixtures.deadEnds()] {
            await #expect { try await SyntheticStandaloneRouteExperiment(configuration: bad.configuration,view: bad.view,selectionVariant: .appendFastPath).observe(bad.request) } throws: {
                if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
            }
        }
        let good = F.inventory("good",stops: ["A","D"],times: [100,150])
        let raw = F.inventory("unknown",stops: ["B","C"],times: [200,300])
        let unknown = SyntheticInternalInventory(trip: raw.trip,intervals: nil,slots: nil)
        let bad = fixtures.packet([good,unknown])
        await #expect { try await SyntheticStandaloneRouteExperiment(configuration: bad.configuration,view: bad.view,selectionVariant: .appendFastPath).observe(bad.request) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
    }
    @Test func chargedFastCheckThenFallback() async throws {
        let input = try [descriptor("b"),descriptor("a")]
        for cancel in [false,true] {
            var kernel = SyntheticAppendFastPathKernel(input,profiling: true)
            let recorder = AppendCheckpointRecorder()
            var engine = SyntheticInternalRouteEngine(configuration: nil,view: nil,workLimit: cancel ? 10 : 4,checkpoint: { _ in
                if await recorder.record() == 5 && cancel { throw CancellationError() }
            })
            do {
                while !kernel.isComplete { try await engine.step(.sorting); kernel.advance() }
                Issue.record("Expected boundary abort")
            } catch is CancellationError { #expect(cancel) }
            catch RouteSearchFailure.searchIncomplete { #expect(!cancel) }
            // Objective2 + first insertion + failed fast check; fifth checkpoint
            // prevents fallback. This local driver returns no completed result.
            #expect(kernel.profile.fastChecks == 1 && kernel.profile.equalities == 0)
            #expect(!kernel.isComplete && kernel.winners == [0])
        }
    }
    @Test func balancedMeasurements() async throws {
        for n in [1,8,27,64] {
            let p = packet(n), config = p.configuration, view = p.view, request = p.request
            let oracle = try await SyntheticPruningRouteExperiment(configuration: config,view: view).observeOracleForCertificateTests(request)
            let batch = try F.batch(oracle.result)
            let descriptors = try batch.candidates.map { candidate -> SyntheticOptimalRouteDescriptor in
                let contexts = try candidate.legs.map { leg -> TimetableRideContext in
                    guard case .rail(let rail) = leg,case .timetable(let context) = rail.scheduledContext else { throw F.FixtureError.expectedBatch }
                    return context
                }
                return .init(contexts: contexts,forms: Array(repeating: 0,count: contexts.count-1))
            }
            for order in 0..<3 {
                let input = ordered(descriptors,order)
                for rep in -1..<8 { for position in 0..<4 {
                    let slot = (position+max(0,rep))%4, fast = slot%2 == 1, profile = slot/2 == 1
                    let start = ContinuousClock.now
                    let winners: [Int], metrics: SyntheticKernelProfile
                    var advances = 0
                    if fast {
                        var kernel = SyntheticAppendFastPathKernel(input,profiling: profile)
                        while !kernel.isComplete { kernel.advance(); advances += 1 }
                        winners = kernel.winners; metrics = kernel.profile
                    } else {
                        var kernel = SyntheticOptimalRouteKernel(input,profiling: profile)
                        while !kernel.isComplete { kernel.advance(); advances += 1 }
                        winners = kernel.winners; metrics = kernel.profile
                    }
                    let elapsed = start.duration(to: .now)
                    #expect(winners.map { input[$0].key } == descriptors.map(\.key))
                    if rep >= 0 { print("APPEND_KERNEL n=\(n) order=\(order) rep=\(rep) position=\(position) fast=\(fast) profile=\(profile) elapsed=\(elapsed) advances=\(advances) equality=\(metrics.equalities) orderChecks=\(metrics.orders) atoms=\(metrics.atomOrderCalls) fastChecks=\(metrics.fastChecks) fastAtoms=\(metrics.fastAtomCalls) appends=\(metrics.fastAppends) shifts=\(metrics.shiftedWinnerSlots) winners=\(winners.count)") }
                } }
            }
            // Normal pipeline ordering stays intact. No descriptor/path reorder hook.
            let runners = [false,true].flatMap { profile in [SyntheticSelectionVariant.reference,.appendFastPath].map {
                SyntheticStandaloneRouteExperiment(configuration: config,view: view,profileSelection: profile,selectionVariant: $0)
            } }
            for rep in -1..<8 { for position in 0..<4 {
                let slot = (position+max(0,rep))%4, start = ContinuousClock.now
                let r = try await runners[slot].observe(request)
                let elapsed = start.duration(to: .now), m = r.metrics, k = m.selectionProfile.kernel
                _ = try SyntheticPruningExperimentTests().parity(.init(oracle: oracle,pruned: .init(result: r.result,metrics: m,elapsed: elapsed),elapsed: .zero))
                if rep >= 0 { print("APPEND_PIPELINE n=\(n) rep=\(rep) position=\(position) fast=\(slot%2 == 1) profile=\(slot/2 == 1) elapsed=\(elapsed) selection=\(m.selectionTime) admission=\(m.admissionTime) qualification=\(m.qualificationTime) discovery=\(m.discoveryTime) advances=\(m.kernelAdvances) qualificationCharges=\(m.qualificationWork) discoveryCharges=\(m.discoveryWork) postCharges=\(m.postWork) equality=\(k.equalities) orderChecks=\(k.orders) atoms=\(k.atomOrderCalls) fastChecks=\(k.fastChecks) fastAtoms=\(k.fastAtomCalls) appends=\(k.fastAppends) shifts=\(k.shiftedWinnerSlots) frontier=\(m.peakFrontierPaths) retainedKeys=\(m.peakCompleteKeys) copies=\(m.selectionProfile.pathCopies) copyElements=\(m.selectionProfile.pathElements) output=\(batch.candidates.count)") }
            } }
        }
    }
}
private actor AppendCheckpointRecorder {
    private(set) var calls = 0
    func record() -> Int { calls += 1; return calls }
}
#endif
