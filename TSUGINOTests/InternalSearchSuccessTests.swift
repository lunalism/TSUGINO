import Foundation
import Testing
@testable import TSUGINO

/// Invented local constructor cases; none establishes coverage or completed search.
struct InternalSearchSuccessTests {
    private func view(_ n: UInt8 = 1) -> TimetableViewID {
        TimetableViewID(UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, n)))
    }
    private func station(_ s: String) throws -> StationID { try #require(StationID(s)) }
    private func scope(stations: [String] = ["A", "B", "C", "D"], lines: [String] = ["L1", "L2"],
                       trips: [String] = ["T1", "T2", "T3"], origin: String = "A", destination: String = "D",
                       cap: Int = 3) throws -> InternalSearchScope {
        let stationIDs = Set(try stations.map { try station($0) })
        let lineIDs = Set(try lines.map { try #require(LineID($0)) })
        let tripIDs = Set(try trips.map { try #require(TripID($0)) })
        let p = try #require(InternalSearchProfileDefinition(
            identity: .init(key: view().rawValue, revision: view(2).rawValue),
            stations: stationIDs, lines: lineIDs, trips: tripIDs,
            maximumElapsedDuration: 100, maximumRailRides: cap,
            connectionPolicy: .init(key: view(3).rawValue, revision: view(4).rawValue),
            serviceDateInterpretation: .init(key: view(5).rawValue, revision: view(6).rawValue)))
        let request = try #require(RouteSearchRequest(origin: try station(origin), destination: try station(destination),
            departNotBefore: Date(timeIntervalSinceReferenceDate: 100)))
        return try #require(InternalSearchScope(profile: p, request: request, viewID: view()))
    }
    private func train(id: String = "T1", stops: [String] = ["A", "B", "D"],
                       segments: [(String, Int, Int)] = [("L1", 0, 2)], b: Int = 0, a: Int = 2) throws -> TrainCandidate {
        let segments = try segments.map { name, start, end in
            let line = try #require(LineID(name))
            return try #require(TripLineSegment(lineID: line, startIndex: start, endIndex: end))
        }
        let tid = try #require(TripID(id))
        let trip = try #require(Trip(id: tid, stopSequence: try stops.map { try station($0) },
            lineSegments: segments, coverage: .init(includesServiceOrigin: false, includesServiceDestination: false),
            serviceTypeSegments: []))
        return try #require(TrainCandidate(trip: trip, boardingIndex: b, alightingIndex: a))
    }
    private func context(_ train: TrainCandidate, departure: Double = 100, arrival: Double = 200,
                         viewID: UInt8 = 1, day: String = "invented-date-one") throws -> TimetableRideContext {
        let label = try #require(TimetableServiceDate(day))
        let address = TimetableOccurrenceAddress(viewID: view(viewID), tripID: train.trip.id, serviceDate: label)
        let binding = try #require(TimetableOccurrenceBinding(address: address, trip: train.trip))
        let dep = try #require(TimetableInstant(Date(timeIntervalSinceReferenceDate: departure)))
        let arr = try #require(TimetableInstant(Date(timeIntervalSinceReferenceDate: arrival)))
        let visits = try train.trip.stopSequence.indices.map { i in
            try #require(TimetableVisitFacts(binding: binding, originalIndex: i,
                arrival: i == train.alightingIndex ? .exact(arr) : .missing,
                departure: i == train.boardingIndex ? .exact(dep) : .missing,
                boarding: .unknown, alighting: .unknown))
        }
        let facts = try #require(TimetableOccurrenceFacts(binding: binding, visits: visits))
        return try #require(TimetableRideContext(train: train, facts: facts))
    }
    private func leg(_ train: TrainCandidate, departure: Double = 100, arrival: Double = 200,
                     viewID: UInt8 = 1, day: String = "invented-date-one") throws -> RouteCandidateLeg {
        let c = try context(train, departure: departure, arrival: arrival, viewID: viewID, day: day)
        return .rail(try #require(RouteRailProposal(travel: .matched(train), scheduledContext: .timetable(c))))
    }
    private func candidate(_ legs: [RouteCandidateLeg]) throws -> RouteCandidate { try #require(RouteCandidate(legs: legs)) }
    private func success(_ candidate: RouteCandidate, scope: InternalSearchScope) throws -> InternalSearchSuccess? {
        let batch = try #require(RouteSearchBatch(candidates: [candidate], omissions: []))
        return InternalSearchSuccess(scope: scope, outcome: .alternatives(batch))
    }

    @Test func noResultsRetainsScopeWithoutCompletionClaim() throws {
        let s = try scope(), value = try #require(InternalSearchSuccess(scope: s, outcome: .noResults))
        #expect(value.scope.profile.hasSameDefinition(as: s.profile))
        #expect(value.scope.viewID == s.viewID && value.scope.request.origin == s.request.origin)
        #expect(value.scope.request.destination == s.request.destination && value.scope.request.departNotBefore == s.request.departNotBefore)
        #expect(value.scope.lowerBound == s.lowerBound && value.scope.upperBound == s.upperBound)
        if case .internalSuccess(let retained) = RouteSearchResult.internalSuccess(value), case .noResults = retained.outcome {} else {
            Issue.record("Expected scoped empty structure")
        }
    }
    @Test func batchPreservesEveryCandidateAndOmissionPosition() throws {
        let s = try scope()
        let candidates = try (0..<4).map { offset in
            try candidate([leg(train(), departure: 100 + Double(offset), arrival: 190 + Double(offset))])
        }
        let omissions = try [0, 3, 6].map { try #require(RouteAlternativeOmission(alternativeIndex: $0, reasons: [.unknownMapping, .invalidStructure])) }
        let batch = try #require(RouteSearchBatch(candidates: candidates, omissions: omissions))
        let value = try #require(InternalSearchSuccess(scope: s, outcome: .alternatives(batch)))
        guard case .alternatives(let retained) = value.outcome else { Issue.record("Expected batch"); return }
        #expect(retained.candidates.count == 4 && retained.omissions.map(\.alternativeIndex) == [0, 3, 6])
        #expect(retained.omissions.allSatisfy { $0.reasons == [.unknownMapping, .invalidStructure] })
        let displaySubset = retained.candidates.prefix(1)
        #expect(displaySubset.count == 1 && retained.candidates.count == 4)
        for (i, c) in retained.candidates.enumerated() {
            guard case .rail(let r) = c.legs[0], case .timetable(let t) = r.scheduledContext else { Issue.record("Lost context"); continue }
            #expect(t.departure == Date(timeIntervalSinceReferenceDate: 100 + Double(i)))
        }
    }
    @Test func wrongRequestEndpointsReject() throws {
        let c = try candidate([leg(train())])
        #expect(try success(c, scope: scope(origin: "B")) == nil)
        #expect(try success(c, scope: scope(destination: "C")) == nil)
    }
    @Test(arguments: [0, 1, 2]) func riddenDomainViolationsReject(_ field: Int) throws {
        let c = try candidate([leg(train())])
        let s = try scope(stations: field == 0 ? ["A", "D"] : ["A", "B", "D"],
                          lines: field == 1 ? ["L2"] : ["L1"], trips: field == 2 ? ["T2"] : ["T1"])
        #expect(try success(c, scope: s) == nil) // Interior B matters, not only anchors.
    }
    @Test func unusedSnapshotPortionsAndBoundaryOnlyLinesArePermitted() throws {
        let t = try train(stops: ["X", "A", "B", "A", "D", "Y"],
            segments: [("OUT", 0, 1), ("L1", 1, 4), ("OUT", 4, 5)], b: 3, a: 4)
        let c = try candidate([leg(t)])
        let value = try #require(try success(c, scope: scope(stations: ["A", "D"], lines: ["L1"], cap: 1)))
        guard case .alternatives(let batch) = value.outcome, case .rail(let r) = batch.candidates[0].legs[0],
              case .matched(let retained) = r.travel, case .timetable(let context) = r.scheduledContext else { Issue.record("Lost snapshot"); return }
        #expect(retained.trip.stopSequence == t.trip.stopSequence && retained.trip.lineSegments == t.trip.lineSegments)
        #expect(retained.trip.id == t.trip.id && retained.trip.coverage == t.trip.coverage && retained.trip.serviceTypeSegments == t.trip.serviceTypeSegments)
        #expect(retained.boardingIndex == 3 && retained.alightingIndex == 4 && retained.lineSequence == t.lineSequence)
        #expect(context.binding.address.tripID == t.trip.id && context.binding.address.serviceDate.label == "invented-date-one")
    }
    @Test func wrongViewRejectsWithoutAuthenticatingMatchingLabels() throws {
        #expect(try success(candidate([leg(train(), viewID: 2)]), scope: scope()) == nil)
    }
    @Test func nilProviderAndUnresolvedRidesCannotEnterInternalSuccess() throws {
        let t = try train(), s = try scope()
        let provider = try #require(ProviderScheduledContext(departure: s.lowerBound, arrival: s.upperBound))
        let unresolved = try #require(UnresolvedRouteRailTravel(anchors: t.anchors, lineSequence: t.lineSequence, reason: .noVerifiedMatch))
        for travel in [RouteRailTravel.matched(t), .unresolved(unresolved)] {
            for context in [RouteScheduledContext?.none, .provider(provider)] {
                let r = try #require(RouteRailProposal(travel: travel, scheduledContext: context))
                #expect(try success(candidate([.rail(r)]), scope: s) == nil)
            }
        }
        let tc = try context(t)
        #expect(RouteRailProposal(travel: .unresolved(unresolved), scheduledContext: .timetable(tc)) == nil)
    }
    @Test func changedSnapshotAndIndicesCannotBypassAttachment() throws {
        let original = try train(stops: ["A", "B", "A", "D"], segments: [("L1", 0, 3)], b: 2, a: 3)
        let tc = try context(original)
        let otherIndex = try #require(TrainCandidate(trip: original.trip, boardingIndex: 0, alightingIndex: 3))
        let changed = try train(stops: ["A", "C", "A", "D"], segments: [("L1", 0, 3)], b: 2, a: 3)
        for other in [otherIndex, changed] {
            #expect(RouteRailProposal(travel: .matched(other), scheduledContext: .timetable(tc)) == nil)
        }
    }
    @Test func throughServiceUsesOneRideDespiteRepeatedLines() throws {
        // Continuity is stipulated synthetic evidence, never proven by this value.
        let t = try train(stops: ["A", "B", "C", "D"], segments: [("L1", 0, 1), ("L2", 1, 2), ("L1", 2, 3)], a: 3)
        #expect(try success(candidate([leg(t)]), scope: scope(cap: 1)) != nil)
    }
    @Test func transferRideCapAndMixedOpaqueDates() throws {
        let first = try train(stops: ["A", "B"], segments: [("L1", 0, 1)], a: 1)
        let last = try train(id: "T2", stops: ["C", "D"], segments: [("L2", 0, 1)], a: 1)
        let walk = try #require(WalkingTransfer(fromStationID: try station("B"), toStationID: try station("C")))
        let c = try candidate([leg(first, arrival: 120, day: "prior-service-label"), .walkingTransfer(walk),
                               leg(last, departure: 130, day: "later-service-label")])
        #expect(try success(c, scope: scope(cap: 2)) != nil)
        #expect(try success(c, scope: scope(cap: 1)) == nil)
        #expect(try success(c, scope: scope(stations: ["A", "B", "D"])) == nil)
    }
    @Test func inclusiveBoundariesAndJustOutside() throws {
        let t = try train(), s = try scope()
        #expect(try success(candidate([leg(t)]), scope: s) != nil)
        #expect(try success(candidate([leg(t, departure: 99)]), scope: s) == nil)
        #expect(try success(candidate([leg(t, arrival: 201)]), scope: s) == nil)
    }
    @Test func chronologyAcrossNilGapAndDuplicateTripsRemainRejected() throws {
        let a = try train(stops: ["A", "B"], segments: [("L1", 0, 1)], a: 1)
        let b = try train(id: "T2", stops: ["B", "C"], segments: [("L1", 0, 1)], a: 1)
        let c = try train(id: "T3", stops: ["C", "D"], segments: [("L1", 0, 1)], a: 1)
        let nilRide = try #require(RouteRailProposal(travel: .matched(b), scheduledContext: nil))
        #expect(try RouteCandidate(legs: [leg(a, arrival: 150), .rail(nilRide), leg(c, departure: 140)]) == nil)
        let reused = try train(stops: ["B", "D"], segments: [("L1", 0, 1)], a: 1)
        #expect(try RouteCandidate(legs: [leg(a, arrival: 120), leg(reused, departure: 120, day: "another-date")]) == nil)
    }
    @Test func invalidAccountingCannotConstructBatchPayload() throws {
        let c = try candidate([leg(train())])
        let one = try #require(RouteAlternativeOmission(alternativeIndex: 1, reasons: [.unknownMapping]))
        let three = try #require(RouteAlternativeOmission(alternativeIndex: 3, reasons: [.unknownMapping]))
        #expect(RouteSearchBatch(candidates: [], omissions: []) == nil)
        #expect(RouteSearchBatch(candidates: [], omissions: [one]) == nil)
        #expect(RouteSearchBatch(candidates: [c], omissions: [one, one]) == nil)
        #expect(RouteSearchBatch(candidates: [c], omissions: [three]) == nil)
    }
}
