#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@Suite(.serialized)
struct SyntheticPruningExperimentTests {
    private typealias F = InternalFixture
    private struct Grid {
        let items: [SyntheticInternalInventory]
        let overrides: [SyntheticInternalConnection]
        let q: Int
        let variant: Int
        var experiment: SyntheticPruningRouteExperiment { make(items, overrides) }
    }
    private static func make(_ items: [SyntheticInternalInventory], _ overrides: [SyntheticInternalConnection] = [],
                             checkpoint: @escaping @Sendable (SyntheticPruningMode, SyntheticInternalStage) async throws -> Void = { _,_ in }) -> SyntheticPruningRouteExperiment {
        .init(configuration: F.configuration(trips: Array(Set(items.map { $0.trip.id.rawValue })), cap: 3, duration: 2400,
              stations: ["A","B","C","D","X","Y"]),
              view: F.view(items, connections: F.connections(items, overrides: overrides), until: 2501), checkpoint: checkpoint)
    }
    private func grid(_ q: Int, _ variant: Int) -> Grid {
        let a = (0..<q).map { F.inventory("L1-\($0)", stops: ["A","X"], times: [60,300]) }
        let b = (0..<q).map { F.inventory("L2-\($0)", stops: ["X","Y"], times: [360,variant == 3 ? 1800 : 600]) }
        let c = (0..<q).map { F.inventory("L3-\($0)", stops: ["Y","D"], times: [variant == 3 ? 1860 : 660,variant == 3 ? 2100 : 1200]) }
        let d = F.inventory("Z-direct", stops: ["A","D"], times: [120,[900,1500,1200,900][variant]])
        var connections: [SyntheticInternalConnection] = []
        for first in a { for second in b { connections.append(F.present(F.key(first,1,second,0),60)) } }
        for first in b { for second in c { connections.append(F.present(F.key(first,1,second,0),60)) } }
        return .init(items: a+b+c+[d], overrides: connections, q: q, variant: variant)
    }
    /// Compare original snapshots, addresses, indices, time tags, contexts, walking
    /// connections and scoped policy identity, not merely arrivals or abbreviated IDs.
    private func parity(_ comparison: SyntheticPruningComparison) throws -> RouteSearchBatch {
        guard case .internalSuccess(let oracle) = comparison.oracle.result,
              case .internalSuccess(let pruned) = comparison.pruned.result else { throw F.FixtureError.expectedBatch }
        #expect(oracle.scope.viewID == pruned.scope.viewID)
        #expect(oracle.scope.lowerBound == pruned.scope.lowerBound && oracle.scope.upperBound == pruned.scope.upperBound)
        #expect(oracle.scope.profile.identity == pruned.scope.profile.identity)
        #expect(oracle.scope.profile.connectionPolicy == pruned.scope.profile.connectionPolicy)
        #expect(oracle.scope.profile.serviceDateInterpretation == pruned.scope.profile.serviceDateInterpretation)
        #expect(oracle.scope.request.origin == pruned.scope.request.origin && oracle.scope.request.destination == pruned.scope.request.destination)
        #expect(oracle.scope.request.departNotBefore == pruned.scope.request.departNotBefore)
        let a = try F.batch(comparison.oracle.result), b = try F.batch(comparison.pruned.result)
        #expect(F.keys(a) == F.keys(b)); #expect(a.omissions.isEmpty && b.omissions.isEmpty)
        #expect(a.candidates.count == b.candidates.count)
        for (x,y) in zip(a.candidates,b.candidates) {
            #expect(x.transferCount == y.transferCount && x.legs.count == y.legs.count)
            for (l,r) in zip(x.legs,y.legs) {
                switch (l,r) {
                case (.rail(let u), .rail(let v)):
                    guard case .timetable(let uc) = u.scheduledContext, case .timetable(let vc) = v.scheduledContext else { throw F.FixtureError.expectedBatch }
                    #expect(uc.binding.matches(vc.binding))
                    #expect(uc.boardingIndex == vc.boardingIndex && uc.alightingIndex == vc.alightingIndex)
                    #expect(uc.departure == vc.departure && uc.arrival == vc.arrival)
                    #expect(uc.binding.trip.stopSequence == vc.binding.trip.stopSequence)
                    #expect(uc.binding.trip.lineSegments == vc.binding.trip.lineSegments)
                    #expect(uc.binding.trip.serviceTypeSegments == vc.binding.trip.serviceTypeSegments)
                    guard case .matched(let ut) = u.travel, case .matched(let vt) = v.travel else { throw F.FixtureError.expectedBatch }
                    #expect(uc.matches(ut) && vc.matches(vt))
                case (.walkingTransfer(let u), .walkingTransfer(let v)):
                    #expect(u.fromStationID == v.fromStationID && u.toStationID == v.toStationID)
                default: Issue.record("Canonical leg kind changed")
                }
            }
        }
        return b
    }
    @Test(arguments: [1,2,3], [0,1,2,3]) func layeredOracleEquivalence(_ q: Int, _ variant: Int) async throws {
        let g = grid(q,variant), s = g.experiment
        let result = try await s.compare(F.request(at: 0))
        let batch = try parity(result)
        #expect(result.oracle.metrics.completePaths == q*q*q+1)
        #expect(result.oracle.metrics.pairChecks == (3*q+1)*(3*q+1))
        #expect(batch.candidates.count == (variant == 1 ? q*q*q : 1))
        #expect(batch.candidates.allSatisfy { $0.transferCount == (variant == 1 ? 2 : 0) })
        for candidate in batch.candidates {
            guard case .rail(let rail) = candidate.legs.last, case .timetable(let context) = rail.scheduledContext else { throw F.FixtureError.expectedBatch }
            #expect(context.arrival == F.date(variant == 1 || variant == 2 ? 1200 : 900))
        }
        if variant != 1 { #expect(F.keys(batch) == [["Z-direct/d-a/0-1"]]) }
        // Published, uninstrumented oracle and reversed input order also agree.
        let old = SyntheticOptimalRouteSearcher(configuration: s.configuration, view: s.view, workLimit: 200_000)
        #expect(F.keys(try F.batch(await old.search(F.request(at: 0)))) == F.keys(batch))
        let reversed = try await Self.make(Array(g.items.reversed()), Array(g.overrides.reversed())).compare(F.request(at: 0))
        #expect(F.keys(try parity(reversed)) == F.keys(batch))
    }
    @Test func repeatedDatesThroughAndMidnight() async throws {
        let r = F.inventory("repeat", stops: ["A","B","A","D"], times: [100,110,120,150], label: "day-1")
        let r2 = F.inventory("repeat", stops: ["A","B","A","D"], times: [100,110,120,150], label: "day-2")
        let combined = SyntheticInternalInventory(trip: r.trip, intervals: r.intervals, slots: r.slots!+r2.slots!)
        let through = F.inventory("Z-through", stops: ["A","B","D"], times: [100,110,150], segments: [("L1",0,1),("L2",1,2)])
        let b = try parity(await Self.make([combined,through]).compare(F.request(at: 0)))
        #expect(b.candidates.count == 5 && b.candidates.allSatisfy { $0.transferCount == 0 })
        #expect(F.keys(b).contains(["repeat/day-2/2-3"]))
        let midnight = F.inventory("midnight", stops: ["A","D"], times: [85800,87000],label: "original-day")
        let s = SyntheticPruningRouteExperiment(configuration: F.configuration(trips: ["midnight"],duration: 2400),
            view: F.view([midnight],from: 85000,until: 88300))
        let m = try parity(await s.compare(F.request(at: 85800)))
        #expect(F.keys(m) == [["midnight/original-day/0-1"]])
    }
    @Test(arguments: [0,1,2,3]) func requiredUnknownCannotHideBehindDirect(_ kind: Int) async throws {
        let good = F.inventory("Z-good",stops: ["A","D"],times: [100,150])
        let raw = F.inventory("slow",stops: ["B","C"],times: [200,300])
        let bad: SyntheticInternalInventory
        switch kind {
        case 0: bad = .init(trip: raw.trip,intervals: nil,slots: nil)
        case 1: bad = .init(trip: raw.trip,intervals: raw.intervals,slots: [.init(address: raw.slots![0].address,activation: .unavailable)])
        case 2: bad = F.inventory("slow",stops: ["B","C"],times: [200,300],departures: [.missing,.missing])
        default: bad = raw
        }
        let overrides: [SyntheticInternalConnection] = kind == 3 ? [.init(key: F.key(good,1,bad,0),state: .unknown)] : []
        let gate = PruningCounter()
        await #expect { try await Self.make([good,bad],overrides,checkpoint: { mode,_ in if mode == .pruned { await gate.tick() } }).search(F.request()) } throws: {
            if case RouteSearchFailure.dataUnavailable = $0 { true } else { false }
        }
        #expect(await gate.value == 0)
    }
    @Test(arguments: [[0], [0,1]]) func selectedRejectionAccounting(_ indices: [Int]) async throws {
        let items = [F.inventory("a",stops: ["A","D"],times: [100,150]),F.inventory("b",stops: ["A","D"],times: [100,150])]
        do { try await SyntheticPruningRejectionHarness.reject(Self.make(items),request: F.request(),indices: Set(indices)) }
        catch RouteSearchFailure.searchIncomplete { #expect(indices.count == 1) }
        catch RouteSearchFailure.noUsableAlternatives(let rejected) {
            #expect(indices.count == 2)
            #expect(rejected.omissions.map(\.alternativeIndex) == [0,1])
            #expect(rejected.omissions.allSatisfy { $0.reasons == [.inconsistentTrainEvidence] })
        }
    }
    @Test func cutoffsAndCancellationNeverPublishIncumbent() async throws {
        let g = grid(2,1)
        for stage in [SyntheticInternalStage.generation,.sorting,.admission,.finish] {
            for cancel in [false,true] {
                await #expect { try await Self.make(g.items,g.overrides,checkpoint: { mode,current in
                    if mode == .pruned && current == stage {
                        if cancel { throw CancellationError() }
                        throw F.FixtureError.cutoff
                    }
                }).search(F.request(at: 0)) } throws: { error in
                    if cancel { return error is CancellationError }
                    if case RouteSearchFailure.searchIncomplete = error { return true }; return false
                }
            }
        }
        // Cut after the first completed direct path: strict worse branches remain.
        let counter = PruningCounter()
        let slow = grid(2,3)
        await #expect {
            try await Self.make(slow.items,slow.overrides,checkpoint: { mode,stage in
                if mode == .pruned && stage == .generation {
                    let count = await counter.tick()
                    if count == 20 { throw F.FixtureError.cutoff }
                }
            }).search(F.request(at: 0))
        } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
    }
    @Test func boundsAndProvenEmpty() async throws {
        let many = (0..<11).map { F.inventory("t\($0)",stops: ["A","D"],times: [100,150]) }
        await #expect { try await Self.make(many).search(F.request()) } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
        let long = F.inventory(String(repeating: "x",count: 129),stops: ["A","D"],times: [100,190])
        await #expect { try await Self.make([long]).search(F.request()) } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
        let raw = F.inventory("empty",stops: ["A","D"],times: [100,150])
        let empty = SyntheticInternalInventory(trip: raw.trip,intervals: raw.intervals,slots: [])
        let result = try await Self.make([empty]).compare(F.request())
        for r in [result.oracle.result,result.pruned.result] {
            guard case .internalSuccess(let success) = r, case .noResults = success.outcome else { throw F.FixtureError.expectedBatch }
            #expect(success.scope.viewID == F.viewID)
        }
    }
    @Test func equalPrefixBoundAndConvergingTies() async throws {
        // Equal arrival + equal change count at prefix MUST remain explorable:
        // direct winner at 150, first ride arrives 150, zero-time onward ride
        // produces a worse (one-change) route; the prefix itself is not pruned.
        let d = F.inventory("z-direct",stops: ["A","D"],times: [100,150])
        let a = F.inventory("a",stops: ["A","B"],times: [100,150])
        let b = F.inventory("b",stops: ["B","D"],times: [150,150])
        let r = try await Self.make([d,a,b],[F.present(F.key(a,1,b,0),0)]).compare(F.request())
        _ = try parity(r)
        #expect(r.pruned.metrics.prefixes == 3)
        #expect(r.pruned.metrics.prunedPrefixes == 1) // completion, not equal prefix
        // Earlier prefixes catch exactly the same suffix: preserve both identities.
        let a1 = F.inventory("a1",stops: ["A","B"],times: [100,110])
        let a2 = F.inventory("a2",stops: ["A","B"],times: [100,120])
        let suffix = F.inventory("suffix",stops: ["B","D"],times: [130,150])
        let tied = try parity(await Self.make([a1,a2,suffix], [F.present(F.key(a1,1,suffix,0),20),F.present(F.key(a2,1,suffix,0),10)]).compare(F.request()))
        #expect(F.keys(tied) == [["a1/d-a/0-1","suffix/d-a/0-1"],["a2/d-a/0-1","suffix/d-a/0-1"]])
    }
    @Test func differentUsedTripHistoriesAndDirectionalAllowance() async throws {
        // recurring T has two dated slots. T(day1)->middle->T(day2) is
        // forbidden; other->middle->T(day2) remains valid. Do not merge history.
        let t1 = F.inventory("T",stops: ["A","B","D"],times: [100,110,120],label: "day1")
        let t2 = F.inventory("T",stops: ["A","B","D"],times: [140,150,160],label: "day2")
        let t = SyntheticInternalInventory(trip: t1.trip,intervals: t1.intervals,slots: t1.slots!+t2.slots!)
        let other = F.inventory("other",stops: ["A","B"],times: [100,110])
        let middle = F.inventory("middle",stops: ["B","C"],times: [120,130])
        // Direct T intervals are valid and faster; oracle comparison still traverses
        // both histories and verifies the forbidden recurring-Trip extension.
        let overrides = [F.present(F.key(t1,1,middle,0),10),F.present(F.key(other,1,middle,0),10),
                         F.present(F.key(middle,1,t2,1),20,walking: true)]
        let result = try await Self.make([t,other,middle],overrides).compare(F.request())
        _ = try parity(result)
        #expect(result.oracle.metrics.completePaths == 3) // two direct dates + other/middle/T(day2)
    }
    @Test func entireOraclePathLimitPrecedesPruning() async throws {
        let g = grid(2,0)
        var items: [SyntheticInternalInventory] = []
        for item in g.items {
            if item.trip.id.rawValue == "Z-direct" { items.append(item); continue }
            let times: [Double]
            let stops = item.trip.stopSequence.map(\.rawValue)
            if stops[0] == "A" { times = [60,300] }
            else if stops[0] == "X" { times = [360,600] }
            else { times = [660,1200] }
            let second = F.inventory(item.trip.id.rawValue,stops: stops,times: times,label: "second-date")
            items.append(.init(trip: item.trip,intervals: item.intervals,slots: item.slots!+second.slots!))
        }
        var overrides: [SyntheticInternalConnection] = []
        for a in items { for b in items {
            guard a.trip.stopSequence[1] == b.trip.stopSequence[0] else { continue }
            for sa in a.slots! { for sb in b.slots! {
                overrides.append(.init(key: .init(alighting: .init(address: sa.address,index: 1),boarding: .init(address: sb.address,index: 0)),state: .present(.sameStation,F.allowance(60),.affirmed)))
            } }
        } }
        let gate = PruningCounter()
        await #expect {
            try await Self.make(items,overrides,checkpoint: { mode,_ in if mode == .pruned { await gate.tick() } }).search(F.request(at: 0))
        } throws: { if case RouteSearchFailure.searchIncomplete = $0 { true } else { false } }
        #expect(await gate.value == 0) // 4³+1=65; fast direct must not mask it.
    }
    @Test func measurements() async throws {
        // One warmup + five sequential observed passes per fixture; no time threshold.
        // Fixtures constructed before timing. No process-memory estimate is made.
        for q in [1,2,3] { for variant in [0,1,2,3] {
            let s = grid(q,variant).experiment
            _ = try await s.compare(F.request(at: 0))
            for repetition in 0..<5 {
                let report = try await s.compare(F.request(at: 0))
                for (name,pass) in [("oracle",report.oracle),("pruned",report.pruned)] {
                    let m = pass.metrics, output = try F.batch(pass.result).candidates.count
                    print("PRUNING q=\(q) v=\(variant) r=\(repetition) mode=\(name) qual=\(m.qualificationWork) discovery=\(m.discoveryWork) post=\(m.postWork) kernel=\(m.kernelAdvances) rides=\(m.qualifiedRides) edges=\(m.qualifiedEdges) pairs=\(m.pairChecks) prefixes=\(m.prefixes) pruned=\(m.prunedPrefixes) complete=\(m.completePaths) frontier=\(m.peakFrontierPaths)/\(m.peakFrontierKeys) retained=\(m.peakCompletePaths)/\(m.peakCompleteKeys) output=\(output) qualTime=\(m.qualificationTime) discoveryTime=\(m.discoveryTime) selectionTime=\(m.selectionTime) admissionTime=\(m.admissionTime) total=\(pass.elapsed) experiment=\(report.elapsed)")
                }
            }
        } }
    }
}
private actor PruningCounter {
    private(set) var value = 0
    @discardableResult func tick() -> Int { value += 1; return value }
}
#endif
