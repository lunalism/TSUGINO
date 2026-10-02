#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticInternalRouteTests {
    private typealias F = InternalFixture
    private func search(_ inventories: [SyntheticInternalInventory], config: SyntheticInternalConfiguration = F.configuration(),
                        connections: [SyntheticInternalConnection] = [], request: RouteSearchRequest = F.request()) async throws -> RouteSearchResult {
        try await SyntheticInternalRouteSearcher(configuration: config, view: F.view(inventories, connections: connections)).search(request)
    }
    private func empty(_ result: RouteSearchResult) {
        guard case .internalSuccess(let value) = result, case .noResults = value.outcome else { Issue.record("Expected scoped noResults"); return }
        #expect(value.scope.request.origin == F.station("A"))
    }
    private func unavailable(_ inventories: [SyntheticInternalInventory], config: SyntheticInternalConfiguration = F.configuration(),
                             connections: [SyntheticInternalConnection] = []) async throws {
        do { _ = try await search(inventories, config: config, connections: connections); Issue.record("Expected dataUnavailable") }
        catch RouteSearchFailure.dataUnavailable {}
    }

    @Test func g1DirectInclusiveAndOutsideBounds() async throws {
        let inventory = F.inventory()
        let batch = try F.batch(await search([inventory]))
        #expect(F.keys(batch) == [["T1/d-a/0-2"]])
        #expect(batch.omissions.isEmpty)
        guard case .rail(let r) = batch.candidates[0].legs[0], case .timetable(let c) = r.scheduledContext else { Issue.record("Context missing"); return }
        #expect(c.departure == F.date(100) && c.arrival == F.date(200))
        #expect(c.binding.trip.stopSequence == inventory.trip.stopSequence && c.binding.trip.lineSegments == inventory.trip.lineSegments)
        #expect(c.binding.trip.coverage == inventory.trip.coverage && c.binding.trip.serviceTypeSegments == inventory.trip.serviceTypeSegments)
        empty(try await search([F.inventory(times: [100, 120, 201])]))
        empty(try await search([F.inventory(times: [99, 120, 200])]))
    }
    @Test func g2ThroughServiceAndMissingContinuity() async throws {
        let t = F.inventory(segments: [("L1", 0, 1), ("L2", 1, 2)])
        let batch = try F.batch(await search([t], config: F.configuration(cap: 1)))
        #expect(batch.candidates[0].legs.count == 1 && batch.candidates[0].transferCount == 0)
        guard case .rail(let r) = batch.candidates[0].legs[0] else { Issue.record("Missing rail"); return }
        #expect(r.travel.lineSequence == [F.line("L1"), F.line("L2")])
        guard let slot = t.slots?.first, case .active(let facts, _) = slot.activation else { Issue.record("Bad fixture"); return }
        let unknown = SyntheticInternalSlot(address: slot.address, activation: .active(facts, []))
        try await unavailable([.init(trip: t.trip, intervals: t.intervals, slots: [unknown])])
    }
    @Test(arguments: [2.0, 3.0, 1.0]) func g3DirectionalWalkAndInclusiveAllowance(_ gap: Double) async throws {
        let a = F.inventory(stops: ["A", "B"], times: [100, 110])
        let b = F.inventory("T2", stops: ["C", "D"], times: [110 + gap, 150])
        let records = F.connections([a, b], overrides: [F.present(F.key(a, 1, b, 0), 2, walking: true)])
        let result = try await search([a, b], config: F.configuration(trips: ["T1", "T2"]), connections: records)
        if gap < 2 { empty(result) } else {
            let batch = try F.batch(result)
            #expect(F.keys(batch) == [["T1/d-a/0-1", "T2/d-a/0-1"]])
            #expect(batch.candidates[0].legs.count == 3)
            guard case .walkingTransfer(let walk) = batch.candidates[0].legs[1] else { Issue.record("Missing walk"); return }
            #expect(walk.fromStationID == F.station("B") && walk.toStationID == F.station("C"))
        }
        // A reverse relation alone never supplies the required forward one.
        let reverse = F.connections([a, b], overrides: [F.present(F.key(b, 1, a, 0), 0, walking: true)])
        empty(try await search([a, b], config: F.configuration(trips: ["T1", "T2"]), connections: reverse))
    }
    @Test func g4SameStationNeedsItsOwnAllowance() async throws {
        let a = F.inventory(stops: ["A", "B"], times: [100, 110])
        let b = F.inventory("T2", stops: ["B", "D"], times: [112, 150])
        let key = F.key(a, 1, b, 0)
        let config = F.configuration(trips: ["T1", "T2"])
        let records = F.connections([a, b], overrides: [F.present(key, 2)])
        let batch = try F.batch(await search([a, b], config: config, connections: records))
        #expect(batch.candidates[0].legs.count == 2)
        try await unavailable([a, b], config: config, connections: records.filter { $0.key != key })
    }
    @Test func g5CompleteNegativeVersusUnknownWithAnotherGoodRoute() async throws {
        let a = F.inventory(stops: ["A", "B"], times: [100, 110])
        let b = F.inventory("T2", stops: ["C", "D"], times: [120, 150])
        let cfg = F.configuration(trips: ["T1", "T2"])
        empty(try await search([a, b], config: cfg, connections: F.connections([a, b])))
        let direct = F.inventory("T3")
        let records = F.connections([a, b, direct], overrides: [.init(key: F.key(a, 1, b, 0), state: .unknown)])
        try await unavailable([a, b, direct], config: F.configuration(trips: ["T1", "T2", "T3"]), connections: records)
    }
    @Test func g6RepeatedVisitsAndPartialSnapshotClosure() async throws {
        let t = F.inventory(stops: ["A", "B", "A", "D"], times: [100, 110, 120, 150])
        #expect(try F.keys(F.batch(await search([t]))) == [["T1/d-a/0-3"], ["T1/d-a/2-3"]])
        let p = F.inventory(stops: ["X", "A", "D", "Y"], times: [90, 100, 150, 250],
                            segments: [("OUT", 0, 1), ("L1", 1, 2), ("OUT", 2, 3)], partial: true)
        let config = F.configuration(stations: ["A", "D"], lines: ["L1"])
        let batch = try F.batch(await search([p], config: config))
        #expect(F.keys(batch) == [["T1/d-a/1-2"]])
        try await unavailable([.init(trip: p.trip, intervals: [], slots: p.slots)], config: config)
    }
    @Test func g7OpaquePriorDateAndMixedDates() async throws {
        let a = F.inventory(stops: ["A", "B"], times: [100, 110], label: "prior-duty-24h")
        let b = F.inventory("T2", stops: ["B", "D"], times: [120, 150], label: "current-duty")
        let batch = try F.batch(await search([a, b], config: F.configuration(trips: ["T1", "T2"]),
            connections: F.connections([a, b], overrides: [F.present(F.key(a, 1, b, 0), 10)])))
        #expect(F.keys(batch) == [["T1/prior-duty-24h/0-1", "T2/current-duty/0-1"]])
        try await unavailable([.init(trip: a.trip, intervals: a.intervals, slots: nil)])
    }
    @Test func g8InactiveUnavailableQualityAndPermissions() async throws {
        let t = F.inventory(), address = t.slots![0].address
        let inactive = SyntheticInternalInventory(trip: t.trip, intervals: t.intervals, slots: [.init(address: address, activation: .inactive)])
        empty(try await search([inactive])) // No event body exists to parse downstream.
        empty(try await search([.init(trip: t.trip, intervals: t.intervals, slots: [])]))
        try await unavailable([.init(trip: t.trip, intervals: t.intervals, slots: [.init(address: address, activation: .unavailable)])])
        let missing: [TimetableTime] = [.missing, .exact(TimetableInstant(F.date(120))!), .exact(TimetableInstant(F.date(200))!)]
        try await unavailable([F.inventory(departures: missing)])
        let estimated: [TimetableTime] = [.estimated(TimetableInstant(F.date(100))!), .exact(TimetableInstant(F.date(120))!), .exact(TimetableInstant(F.date(200))!)]
        try await unavailable([F.inventory(departures: estimated)])
        try await unavailable([F.inventory(boarding: [.unknown, .allowed, .allowed])])
        empty(try await search([F.inventory(boarding: [.prohibited, .allowed, .allowed])]))
        let only = F.inventory(stops: ["A", "D"], times: [100, 150],
            arrivals: [.missing, .exact(TimetableInstant(F.date(150))!)],
            departures: [.exact(TimetableInstant(F.date(100))!), .missing])
        #expect(try F.batch(await search([only])).candidates.count == 1)
    }
    @Test func g9ConflictingInputsAndIdenticalDuplicates() async throws {
        let t = F.inventory()
        #expect(try F.batch(await search([t, t])).candidates.count == 1)
        try await unavailable([t, F.inventory(times: [100, 121, 200])])
        try await unavailable([t, F.inventory(stops: ["A", "C", "B", "D"], times: [100, 110, 120, 200])])
        try await unavailable([t, F.inventory(boarding: [.prohibited, .allowed, .allowed])])
        let wrongView = TimetableViewID(UUID())
        do { _ = try await SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([t], id: wrongView)).search(F.request()); Issue.record("Expected view rejection") }
        catch RouteSearchFailure.dataUnavailable {}
        let a = F.inventory(stops: ["A", "B"], times: [100, 110]), b = F.inventory("T2", stops: ["B", "D"], times: [120, 150])
        let key = F.key(a, 1, b, 0)
        let records = F.connections([a, b], overrides: [F.present(key, 2)]) + [F.present(key, 3)]
        try await unavailable([a, b], config: F.configuration(trips: ["T1", "T2"]), connections: records)
    }
    @Test(arguments: [1, 3]) func g10GeneratedFaultHarnessNeverReturnsSuccess(_ count: Int) async throws {
        let searcher = SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([sameTripInventory(count)]))
        do {
            try await SyntheticInternalFailureHarness.rejectGeneratedAlightingClaims(searcher: searcher, request: F.request(), replacementIndex: Int.max)
        } catch RouteSearchFailure.noUsableAlternatives(let rejected) {
            #expect(rejected.omissions.map(\.alternativeIndex) == Array(0..<count))
            #expect(rejected.omissions.allSatisfy { $0.reasons == [.inconsistentTrainEvidence] })
        }
        do { try await SyntheticInternalFailureHarness.rejectGeneratedAlightingClaims(searcher: searcher, request: F.request(), replacementIndex: 1) }
        catch SyntheticInternalFailureHarness.Failure.unexpectedAdmission {}
        let t = F.inventory()
        let broken = SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([t, F.inventory(times: [100, 121, 200])]))
        do { try await SyntheticInternalFailureHarness.rejectGeneratedAlightingClaims(searcher: broken, request: F.request(), replacementIndex: -1) }
        catch RouteSearchFailure.dataUnavailable {}
    }

    private func sameTripInventory(_ count: Int) -> SyntheticInternalInventory {
        let inputs = (0..<count).map { F.inventory(stops: ["A", "D"], times: [100, 200], label: "dated-\($0)") }
        return .init(trip: inputs[0].trip, intervals: inputs[0].intervals, slots: inputs.flatMap { $0.slots! })
    }

    // Initial token ordering marks the boundary before connection coverage. A generation
    // fallback makes a missed pair barrier fail an assertion instead of hanging the test.
    private actor PairCoverageProbe {
        var ordered = false
        var pairs = 0
        var generated = false
        func observe(_ stage: SyntheticInternalStage) -> Bool {
            if stage == .ordering { ordered = true }
            if ordered && stage == .coverage {
                pairs += 1
            }
            if stage == .generation { generated = true }
            return (ordered && stage == .coverage && pairs == 17) || stage == .generation
        }
    }

    @Test func sameTripFilteredPairsChargeResourceBudget() async throws {
        let count = 32, inventory = sameTripInventory(32), baseline = PairCoverageProbe()
        let view = F.view([inventory]), config = F.configuration(cap: 3)
        let result = try await SyntheticInternalRouteSearcher(configuration: config, view: view, checkpoint: { stage in
            _ = await baseline.observe(stage)
        }).search(F.request())
        #expect(try F.batch(result).candidates.count == count)
        #expect(await baseline.pairs == count * count)
        let limited = PairCoverageProbe()
        do {
            _ = try await SyntheticInternalRouteSearcher(configuration: config, view: view, workLimit: count * count, checkpoint: { stage in
                _ = await limited.observe(stage)
            }).search(F.request())
            Issue.record("Filtered comparisons escaped the resource cutoff")
        } catch RouteSearchFailure.searchIncomplete {}
        // Pre-pair validation/sorting is bounded below this budget for 32 two-stop
        // slots, even at insertion sort's worst order. K² pairs alone exhaust it.
        #expect(await limited.pairs > 0)
        #expect(await limited.pairs < count * count)
        #expect(await limited.generated == false)
    }

    @Test func sameTripFilteredPairsObserveCancellation() async throws {
        let probe = PairCoverageProbe(), gate = RoutingTestGate()
        let searcher = SyntheticInternalRouteSearcher(configuration: F.configuration(cap: 3), view: F.view([sameTripInventory(32)]), checkpoint: { stage in
            if await probe.observe(stage) { try await gate.wait() }
        })
        let task = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        #expect(await probe.pairs == 17)
        #expect(await probe.generated == false)
        task.cancel()
        do { _ = try await task.value; Issue.record("Filtered comparisons escaped cancellation") }
        catch is CancellationError {}
        #expect(await gate.cancellationObserved)
        #expect(await probe.generated == false)
    }
    @Test func g11OrderingAndG15DisplaySubset() async throws {
        let a = F.inventory(stops: ["A", "D"], times: [100, 120], label: "d-a")
        let b = F.inventory(stops: ["A", "D"], times: [105, 125], label: "d-b")
        let combined = SyntheticInternalInventory(trip: a.trip, intervals: a.intervals, slots: a.slots! + b.slots!)
        let t2 = F.inventory("T2", stops: ["A", "D"], times: [110, 130], label: "d-c")
        let config = F.configuration(trips: ["T1", "T2"], cap: 1)
        let expected = [["T1/d-a/0-1"], ["T1/d-b/0-1"], ["T2/d-c/0-1"]]
        let permuted = SyntheticInternalInventory(trip: a.trip, intervals: a.intervals?.reversed().map { $0 }, slots: b.slots! + a.slots! + a.slots!)
        for input in [[combined, t2], [t2, permuted, combined]] {
            let batch = try F.batch(await search(input, config: config))
            #expect(F.keys(batch) == expected)
            #expect(batch.candidates.prefix(1).count == 1 && batch.candidates.count == 3 && batch.omissions.isEmpty)
        }
    }
    @Test func g12FiniteZeroDurationCyclesAndCap() async throws {
        let a = F.inventory(stops: ["A", "B"], times: [100, 100])
        let b = F.inventory("T2", stops: ["B", "A"], times: [100, 100])
        let c = F.inventory("T3", stops: ["A", "D"], times: [100, 100])
        let records = F.connections([a, b, c], overrides: [F.present(F.key(a, 1, b, 0), 0), F.present(F.key(b, 1, c, 0), 0)])
        let full = try F.batch(await search([a, b, c], config: F.configuration(trips: ["T1", "T2", "T3"]), connections: records))
        #expect(F.keys(full) == [["T3/d-a/0-1"], ["T1/d-a/0-1", "T2/d-a/0-1", "T3/d-a/0-1"]])
        let capped = try F.batch(await search([a, b, c], config: F.configuration(trips: ["T1", "T2", "T3"], cap: 2), connections: records))
        #expect(F.keys(capped) == [["T3/d-a/0-1"]])
    }
    @Test(arguments: SyntheticInternalStage.allCases) func g13CutoffsAtEveryStage(_ stage: SyntheticInternalStage) async throws {
        let searcher = SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([F.inventory()]), checkpoint: { current in
            if current == stage { throw F.FixtureError.cutoff }
        })
        do { _ = try await searcher.search(F.request()); Issue.record("Cutoff yielded a result") }
        catch RouteSearchFailure.searchIncomplete {}
    }
    @Test(arguments: SyntheticInternalStage.allCases) func g14CancellationAtEveryStage(_ stage: SyntheticInternalStage) async throws {
        let gate = RoutingTestGate()
        let searcher = SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([F.inventory()]), checkpoint: { current in
            if current == stage { try await gate.wait() }
        })
        let task = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        task.cancel()
        do { _ = try await task.value; Issue.record("Cancelled search returned") }
        catch is CancellationError {}
        #expect(await gate.cancellationObserved)
    }
    @Test func g14ConcurrentCallsAndPreCancelledPrecedence() async throws {
        let gate = RoutingTestGate(), first = InternalFirstCheckpoint()
        let searcher = SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([F.inventory()]), checkpoint: { stage in
            if stage == .validation, await first.claim() { try await gate.wait() }
        })
        let blocked = Task { try await searcher.search(F.request()) }
        await gate.waitUntilEntered()
        let result = try await searcher.search(F.request())
        #expect(try F.batch(result).candidates.count == 1)
        blocked.cancel()
        do { _ = try await blocked.value; Issue.record("Expected cancellation") } catch is CancellationError {}
        let cancelled = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await SyntheticInternalRouteSearcher(configuration: nil, view: nil).search(F.request())
        }
        do { _ = try await cancelled.value; Issue.record("Cancellation lost precedence") } catch is CancellationError {}
    }
    @Test func preflightPrecedenceAndBudget() async throws {
        do { _ = try await SyntheticInternalRouteSearcher(configuration: nil, view: nil).search(F.request()); Issue.record("Expected config failure") }
        catch RouteSearchFailure.configurationUnavailable {}
        do { _ = try await SyntheticInternalRouteSearcher(configuration: F.configuration(), view: nil).search(F.request()); Issue.record("Expected view failure") }
        catch RouteSearchFailure.dataUnavailable {}
        let t = F.inventory()
        let states: [StationID: Set<SyntheticInternalStationState>] = [F.station("A"): [.unknown, .retired, .conflicting], F.station("D"): [.unknown]]
        do { _ = try await SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([t], states: states)).search(F.request()); Issue.record("Expected endpoint failure") }
        catch RouteSearchFailure.invalidEndpoint(.origin, .conflicting) {}
        do { _ = try await SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([t])).search(F.request(at: 950)); Issue.record("Expected unsupported window") }
        catch RouteSearchFailure.unsupportedRequest {}
        do { _ = try await SyntheticInternalRouteSearcher(configuration: F.configuration(), view: F.view([t]), workLimit: 1).search(F.request()); Issue.record("Expected budget cutoff") }
        catch RouteSearchFailure.searchIncomplete {}
    }
    @Test func allowanceArithmeticDoesNotRoundShortGapsUpToFeasible() {
        let large = 9_007_199_254_740_992.0
        #expect(!SyntheticInternalArithmetic.permits(arrival: F.date(large), departure: F.date(large), allowance: 0.25))
        #expect(!SyntheticInternalArithmetic.permits(arrival: F.date(large), departure: F.date(large + 2), allowance: 3))
        #expect(SyntheticInternalArithmetic.permits(arrival: F.date(large), departure: F.date(large + 4), allowance: 3))
        #expect(SyntheticInternalArithmetic.permits(arrival: F.date(-100), departure: F.date(0), allowance: 100))
        #expect(!SyntheticInternalArithmetic.permits(arrival: F.date(.greatestFiniteMagnitude), departure: F.date(.greatestFiniteMagnitude), allowance: .greatestFiniteMagnitude))
        #expect(!F.allowance(.nan).isValid)
    }
}
#endif
