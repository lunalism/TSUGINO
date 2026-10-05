#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@Suite(.serialized)
struct SyntheticSelectionProfilingTests {
    private typealias F = InternalFixture
    private func packet(_ name: String) -> SyntheticDomainCertificateTests.Packet {
        let f = SyntheticDomainCertificateTests()
        switch name {
        case "tie1": return f.layered(1,direct: false)
        case "tie8": return f.layered(2,direct: false)
        case "tie27": return f.layered(3,direct: false)
        case "tie64": return f.layered(2,dates: 2,direct: false)
        default: return f.packet((0..<8).map { F.inventory("direct-\($0)",stops: ["A","D"],times: [100,150]) },cap: 1)
        }
    }
    @Test(arguments: ["tie1","tie8","tie27","tie64","direct8"])
    func instrumentationPreservesCanonicalResultsAndCharges(_ name: String) async throws {
        let p = packet(name), config = p.configuration, view = p.view, request = p.request
        let baseline = try await SyntheticPruningRouteExperiment(configuration: config,view: view).observeOracleForCertificateTests(request)
        for enabled in [false,true] {
            let o = try await SyntheticPruningRouteExperiment(configuration: config,view: view,profileSelection: enabled).observeOracleForCertificateTests(request)
            let s = try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,profileSelection: enabled).observe(request)
            for result in [o,SyntheticPruningPass(result: s.result,metrics: s.metrics,elapsed: s.elapsed)] {
                let b = try SyntheticPruningExperimentTests().parity(.init(oracle: baseline,pruned: result,elapsed: .zero))
                let n = b.candidates.count, profile = result.metrics.selectionProfile
                #expect(result.metrics.postWork == baseline.metrics.postWork)
                #expect(result.metrics.kernelAdvances == baseline.metrics.kernelAdvances)
                if enabled {
                    #expect(profile.descriptors == n && profile.claims == n)
                    #expect(profile.kernel.equalities == n*(n-1)/2 && profile.kernel.orders == n*(n-1)/2)
                    #expect(profile.kernel.inserts == n && profile.kernel.shiftedWinnerSlots == 0)
                    #expect(profile.kernel.objectives == max(0,2*(n-1)))
                } else { #expect(profile.descriptors == 0 && profile.kernel.equalities == 0) }
            }
        }
    }
    @Test func kernelDuplicateAndObjectiveBranchesRemainUnchanged() {
        let p = packet("direct8")
        let contexts = (p.items + [F.inventory("slow",stops: ["A","D"],times: [100,180])]).map { item -> TimetableRideContext in
            guard case .active(let facts,_) = item.slots![0].activation else { preconditionFailure() }
            return TimetableRideContext(train: TrainCandidate(trip: item.trip,boardingIndex: 0,alightingIndex: 1)!,facts: facts)!
        }
        let d = contexts.map { SyntheticOptimalRouteDescriptor(contexts: [$0],forms: []) }
        let input = [d[8],d[2],d[0],d[8],d[2],d[1]]
        var a = SyntheticOptimalRouteKernel(input), b = SyntheticOptimalRouteKernel(input,profiling: true)
        while !a.isComplete { a.advance() }
        while !b.isComplete { b.advance() }
        #expect(a.winners == b.winners && b.winners.count == 3)
        #expect(b.profile.equalities > b.profile.orders && b.profile.shiftedWinnerSlots > 0)
        #expect(b.profile.objectives == 9)
    }
    @Test func profileDoesNotChangeBudgetOrCancellation() async throws {
        let items = [F.inventory("A-slow",stops: ["A","D"],times: [100,180]),F.inventory("Z-fast",stops: ["A","D"],times: [100,150])]
        let config = F.configuration(trips: ["A-slow","Z-fast"],cap: 1,duration: 200,stations: ["A","D"],lines: ["L1"])
        let view = F.view(items), request = F.request(at: 0)
        let s = SyntheticStandaloneRouteExperiment(configuration: config,view: view,workLimit: 47,profileSelection: true)
        let r = try await s.observe(request)
        #expect(r.metrics.qualificationWork+r.metrics.discoveryWork+r.metrics.postWork == 47)
        await #expect { try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,workLimit: 46,profileSelection: true).observe(request) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
        await #expect { try await SyntheticPruningRouteExperiment(configuration: config,view: view,workLimit: 47,profileSelection: true).observeOracleForCertificateTests(request) } throws: {
            if case RouteSearchFailure.searchIncomplete = $0 { true } else { false }
        }
        for stage in [SyntheticInternalStage.sorting,.admission,.finish] {
            await #expect(throws: CancellationError.self) {
                try await SyntheticStandaloneRouteExperiment(configuration: config,view: view,profileSelection: true,checkpoint: {
                    if $0 == stage { throw CancellationError() }
                }).observe(request)
            }
        }
    }
    @Test func balancedMeasurements() async throws {
        // One warmup per variant/mode. Eight measured repetitions form two complete
        // rotations of the four runs: standalone/oracle x profiling on/off.
        // Inputs and runner configuration are created outside each timed invocation.
        for name in ["tie1","direct8","tie8","tie27","tie64"] {
            let p = packet(name), config = p.configuration, view = p.view, request = p.request
            let standalone = [false,true].map { SyntheticStandaloneRouteExperiment(configuration: config,view: view,profileSelection: $0) }
            let oracle = [false,true].map { SyntheticPruningRouteExperiment(configuration: config,view: view,profileSelection: $0) }
            for warmup in [true,false] {
                for repetition in 0..<(warmup ? 1 : 8) {
                    for position in 0..<4 {
                        let slot = (position+repetition)%4, enabled = slot/2 == 1, isStandalone = slot%2 == 0
                        let begin = ContinuousClock.now
                        let m: SyntheticPruningMetrics, result: RouteSearchResult
                        if isStandalone {
                            let r = try await standalone[slot/2].observe(request); m = r.metrics; result = r.result
                        } else {
                            let r = try await oracle[slot/2].observeOracleForCertificateTests(request); m = r.metrics; result = r.result
                        }
                        let whole = begin.duration(to: .now)
                        if warmup { continue }
                        let b = try F.batch(result), z = m.selectionProfile, k = z.kernel
                        print("SELECT_PROFILE name=\(name) rep=\(repetition) position=\(position) variant=\(isStandalone ? "S" : "O") enabled=\(enabled) output=\(b.candidates.count) whole=\(whole) selection=\(m.selectionTime) admission=\(m.admissionTime) claims=\(z.claimsTime) validate=\(z.validationTime) descriptor=\(z.descriptorTime) checkpoints=\(z.checkpointTime) kernel=\(z.kernelTime) objective=\(k.objectiveTime) equality=\(k.equalityTime) order=\(k.orderTime) insert=\(k.insertionTime) copy=\(z.pathCopyTime) dedup=\(z.pathDedupTime) pathOrder=\(z.pathOrderTime) claimArrays=\(z.claims) claimElements=\(z.claimElements) validations=\(z.validations) descriptors=\(z.descriptors) atoms=\(z.keyAtoms) objectives=\(k.objectives) equalities=\(k.equalities) orders=\(k.orders) atomCalls=\(k.atomOrderCalls) inserts=\(k.inserts) shifts=\(k.shiftedWinnerSlots) copies=\(z.pathCopies) copyElements=\(z.pathElements) dedupInserts=\(z.dedupInserts) advances=\(m.kernelAdvances) qualCharges=\(m.qualificationWork) discoveryCharges=\(m.discoveryWork) postCharges=\(m.postWork)")
                    }
                }
            }
        }
    }
}
#endif
