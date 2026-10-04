#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

struct SyntheticOptimalRouteSelectionTests {
    private typealias F = InternalFixture
    private typealias S = SyntheticOptimalRouteSelection
    // This fixture declares these candidate sets exhaustive and all required
    // eligibility/continuity/connections verified in its artificial world. Neither
    // the canonical constructors nor the selector authenticate those assertions.
    private func rail(_ inventory: SyntheticInternalInventory, _ b: Int = 0, _ a: Int? = nil) throws -> RouteCandidateLeg {
        guard case .active(let facts, _) = inventory.slots![0].activation else { throw Failure.fixture }
        let train = try #require(TrainCandidate(trip: inventory.trip, boardingIndex: b, alightingIndex: a ?? inventory.trip.stopSequence.count - 1))
        let context = try #require(TimetableRideContext(train: train, facts: facts))
        return .rail(try #require(RouteRailProposal(travel: .matched(train), scheduledContext: .timetable(context))))
    }
    private enum Failure: Error { case fixture }
    private func direct(_ id: String = "D1", arrival: Double = 150, departure: Double = 100, label: String = "day-1") throws -> RouteCandidate {
        try #require(RouteCandidate(legs: [rail(F.inventory(id, stops: ["A", "D"], times: [departure, arrival], label: label))]))
    }
    private func transfer(arrival: Double = 160, walking: Bool = false) throws -> RouteCandidate {
        var legs = [try rail(F.inventory("T1", stops: ["A", "B"], times: [100, 110]))]
        if walking { legs.append(.walkingTransfer(try #require(WalkingTransfer(fromStationID: F.station("B"), toStationID: F.station("C"))))) }
        legs.append(try rail(F.inventory("T2", stops: [walking ? "C" : "B", "D"], times: [120, arrival])))
        return try #require(RouteCandidate(legs: legs))
    }
    private func scope(_ candidates: [RouteCandidate]) throws -> InternalSearchScope {
        let ids = Set(candidates.flatMap { c in c.legs.compactMap { leg -> String? in
            guard case .rail(let r) = leg, case .matched(let t) = r.travel else { return nil }; return t.trip.id.rawValue
        } })
        let configuration = F.configuration(trips: ids.isEmpty ? ["D1"] : Array(ids), cap: 4, duration: 200)
        return try #require(InternalSearchScope(profile: configuration.profile, request: F.request(), viewID: F.viewID))
    }
    private func select(_ candidates: [RouteCandidate]) throws -> S {
        try S.select(.completeInventedUniverse(scope: scope(candidates), candidates: candidates))
    }
    private func keys(_ selected: S) -> [[String]] {
        guard !selected.candidates.isEmpty else { return [] }
        return F.keys(RouteSearchBatch(candidates: selected.candidates, omissions: [])!)
    }
    @Test(arguments: [false, true]) func fastestBeatsChangeCount(_ transferFaster: Bool) throws {
        let d = try direct(arrival: transferFaster ? 170 : 150)
        let t = try transfer(arrival: 160)
        let selection = try select([d, t])
        #expect(selection.candidates.count == 1)
        #expect(selection.candidates[0].transferCount == (transferFaster ? 1 : 0))
    }
    @Test func equalArrivalPrefersFewerChangesAndThroughIsOneRide() throws {
        let t = try transfer(arrival: 150)
        let through = F.inventory("TH", stops: ["A", "B", "D"], times: [100,110,150], segments: [("L1",0,1),("L2",1,2)])
        let candidate = try #require(RouteCandidate(legs: [rail(through)]))
        let s = try select([t, candidate])
        #expect(keys(s) == [["TH/d-a/0-2"]])
        guard case .rail(let r) = s.candidates[0].legs[0], case .matched(let train) = r.travel else { throw Failure.fixture }
        #expect(train.lineSequence == [F.line("L1"),F.line("L2")])
        #expect(train.trip.lineSegments == through.trip.lineSegments)
        #expect(s.candidates[0].transferCount == 0)
    }
    @Test func allEqualOptimaDedupAndPermutationIndependence() throws {
        let a = try direct("A-train", departure: 110), z = try direct("Z-train", departure: 100)
        let slow = try direct("slow", arrival: 180)
        let expected = [["A-train/day-1/0-1"], ["Z-train/day-1/0-1"]]
        for input in [[z,a,slow,a], [a,slow,z,a], [slow,a,a,z], [a,z,a,slow]] {
            let s = try select(input)
            #expect(keys(s) == expected) // No earlier-departure preference.
            guard case .rail(let r) = s.candidates[0].legs[0], case .timetable(let c) = r.scheduledContext else { throw Failure.fixture }
            #expect(c.departure == F.date(110) && c.arrival == F.date(150))
            #expect(c.binding.address.viewID == F.viewID)
            #expect(c.binding.address.serviceDate.label == "day-1")
        }
    }
    @Test func repeatedOriginalOccurrencesAndDatesRemainDistinct() throws {
        let inventory = F.inventory("LOOP", stops: ["A","B","A","D"], times: [100,110,120,150])
        let first = try #require(RouteCandidate(legs: [rail(inventory,0,3)]))
        let second = try #require(RouteCandidate(legs: [rail(inventory,2,3)]))
        let s = try select([second,first])
        #expect(keys(s) == [["LOOP/d-a/0-3"],["LOOP/d-a/2-3"]])
        for c in s.candidates {
            guard case .rail(let r) = c.legs[0], case .timetable(let context) = r.scheduledContext else { throw Failure.fixture }
            #expect(context.binding.trip.stopSequence == inventory.trip.stopSequence)
            #expect(context.binding.trip.coverage == inventory.trip.coverage)
        }
        #expect(try keys(select([direct(label: "day-2"), direct(label: "day-1")])) == [["D1/day-1/0-1"],["D1/day-2/0-1"]])
    }
    @Test func directionalWalkingConnectionAndTimetableContextsArePreserved() throws {
        let c = try transfer(walking: true), s = try select([c])
        #expect(s.candidates.count == 1 && s.candidates[0].legs.count == 3)
        guard case .walkingTransfer(let w) = s.candidates[0].legs[1] else { throw Failure.fixture }
        #expect(w.fromStationID == F.station("B") && w.toStationID == F.station("C"))
        #expect(keys(s) == [["T1/d-a/0-1", "T2/d-a/0-1"]])
    }
    @Test func missingEvidenceAndIncompleteEnumerationNeverReturnIncumbent() throws {
        do { _ = try S.select(.unknownRequiredEvidence); Issue.record("Expected dataUnavailable") }
        catch RouteSearchFailure.dataUnavailable {}
        do { _ = try S.select(.incompleteEnumeration); Issue.record("Expected searchIncomplete") }
        catch RouteSearchFailure.searchIncomplete {}
        #expect(try select([]).candidates.isEmpty) // Conditional empty selection, not RouteSearchResult.noResults.
    }
    @Test func sharedConflictsFailEvenWhenSlower() throws {
        let a = try direct()
        let conflicting = try direct(arrival: 180)
        do { _ = try select([a,conflicting]); Issue.record("Expected contradictory event failure") }
        catch RouteSearchFailure.dataUnavailable {}
        let changed = F.inventory("D1", stops: ["A","B","D"], times: [100,110,180], label: "day-1")
        let b = try #require(RouteCandidate(legs: [rail(changed)]))
        do { _ = try select([a,b]); Issue.record("Expected snapshot failure") }
        catch RouteSearchFailure.dataUnavailable {}
    }
    @Test func numericIndicesAndNestedFixtureLimits() throws {
        let inventory = F.inventory("LOOP", stops: (0..<11).map { $0 % 2 == 0 ? "A" : "B" } + ["D"],
                                    times: Array(repeating: 100, count: 11) + [150])
        let at2 = try #require(RouteCandidate(legs: [rail(inventory, 2, 11)]))
        let at10 = try #require(RouteCandidate(legs: [rail(inventory, 10, 11)]))
        #expect(try keys(select([at10, at2])) == [["LOOP/d-a/2-11"], ["LOOP/d-a/10-11"]])
        for idLength in [128, 129] {
            let candidate = try direct(String(repeating: "x", count: idLength))
            if idLength == 128 { #expect(try select([candidate]).candidates.count == 1) }
            else {
                do { _ = try select([candidate]); Issue.record("Expected identifier cutoff") }
                catch RouteSearchFailure.searchIncomplete {}
            }
        }
        let oversized = F.inventory("BIG", stops: (0..<256).map { $0 % 2 == 0 ? "A" : "B" } + ["D"],
                                    times: Array(repeating: 100, count: 256) + [150])
        let candidate = try #require(RouteCandidate(legs: [rail(oversized)]))
        do { _ = try select([candidate]); Issue.record("Expected nested snapshot cutoff") }
        catch RouteSearchFailure.searchIncomplete {}
    }
    @Test func wrongScopeAndFixtureCutoffFailAtomically() throws {
        let a = try direct()
        let good = try scope([a])
        let wrong = try #require(InternalSearchScope(profile: good.profile, request: good.request,
            viewID: TimetableViewID(UUID(uuidString: "00000000-0000-0000-0000-000000000099")!)))
        do { _ = try S.select(.completeInventedUniverse(scope: wrong,candidates: [a])); Issue.record("Expected view mismatch") }
        catch RouteSearchFailure.dataUnavailable {}
        #expect(try select(Array(repeating:a,count:64)).candidates.count == 1)
        do { _ = try select(Array(repeating:a,count:65)); Issue.record("Expected finite fixture cutoff") }
        catch RouteSearchFailure.searchIncomplete {}
    }
}
#endif
