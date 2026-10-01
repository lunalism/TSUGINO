import Foundation
import Testing
@testable import TSUGINO

/// Invented constructor subcases only. No activation, admission or source proof.
struct TimetableRideContextTests {
    private func trip(id: String = "T1", stops: [String] = ["A", "B", "A", "C"],
                      boundary: Int = 1, origin: Bool = true, destination: Bool = true,
                      serviceEnd: Int? = 1) throws -> Trip {
        let tid = try #require(TripID(id))
        let stations = try stops.map { try #require(StationID($0)) }
        let l1 = try #require(LineID("L1")), l2 = try #require(LineID("L2"))
        let first = try #require(TripLineSegment(lineID: l1, startIndex: 0, endIndex: boundary))
        let last = try #require(TripLineSegment(lineID: l2, startIndex: boundary, endIndex: stops.count - 1))
        let sid = try #require(ServiceTypeID("S1"))
        var services: [TripServiceTypeSegment] = []
        if let serviceEnd {
            services = [try #require(TripServiceTypeSegment(serviceTypeID: sid, startIndex: 0, endIndex: serviceEnd))]
        }
        return try #require(Trip(id: tid, stopSequence: stations, lineSegments: [first, last],
            coverage: TripCoverage(includesServiceOrigin: origin, includesServiceDestination: destination),
            serviceTypeSegments: services))
    }
    private func time(_ n: Double) throws -> TimetableTime {
        .exact(try #require(TimetableInstant(Date(timeIntervalSince1970: n))))
    }
    private func facts(_ trip: Trip, view: Int = 1, day: String = "2032-04-12",
                       times: [(TimetableTime, TimetableTime)]? = nil) throws -> TimetableOccurrenceFacts {
        let uuid = try #require(UUID(uuidString: "00000000-0000-0000-0000-00000000000\(view)"))
        let date = try #require(TimetableServiceDate(day))
        let address = TimetableOccurrenceAddress(viewID: TimetableViewID(uuid), tripID: trip.id, serviceDate: date)
        let binding = try #require(TimetableOccurrenceBinding(address: address, trip: trip))
        let visits = try trip.stopSequence.indices.map { i in
            let arrival = try times?[i].0 ?? time(Double(i * 10))
            let departure = try times?[i].1 ?? time(Double(i * 10 + 1))
            return try #require(TimetableVisitFacts(binding: binding, originalIndex: i,
                arrival: arrival, departure: departure, boarding: .unknown, alighting: .prohibited))
        }
        return try #require(TimetableOccurrenceFacts(binding: binding, visits: visits))
    }
    private func train(_ trip: Trip, _ b: Int = 0, _ a: Int = 3) throws -> TrainCandidate {
        try #require(TrainCandidate(trip: trip, boardingIndex: b, alightingIndex: a))
    }
    private func rail(_ train: TrainCandidate, _ context: RouteScheduledContext? = nil) throws -> RouteCandidateLeg {
        .rail(try #require(RouteRailProposal(travel: .matched(train), scheduledContext: context)))
    }
    private func provider(_ d: Double, _ a: Double) throws -> RouteScheduledContext {
        .provider(try #require(ProviderScheduledContext(departure: Date(timeIntervalSince1970: d), arrival: Date(timeIntervalSince1970: a))))
    }
    private func assertSnapshot(_ a: Trip, _ b: Trip) {
        #expect(a.id == b.id)
        #expect(a.stopSequence == b.stopSequence)
        #expect(a.lineSegments == b.lineSegments)
        #expect(a.coverage == b.coverage)
        #expect(a.serviceTypeSegments == b.serviceTypeSegments)
    }

    @Test func exactExtractionPreservesDatedBindingAndRepeatedSubinterval() throws {
        let t = try trip(), selected = try train(t, 2, 3)
        for view in [1, 2] {
            for day in ["2032-04-12", "2032-04-13"] {
                let f = try facts(t, view: view, day: day)
                let c = try #require(TimetableRideContext(train: selected, facts: f))
                #expect(c.binding.address == f.binding.address)
                assertSnapshot(c.binding.trip, t)
                #expect(c.boardingIndex == 2 && c.alightingIndex == 3)
                #expect(c.departure == Date(timeIntervalSince1970: 21))
                #expect(c.arrival == Date(timeIntervalSince1970: 30))
                #expect(selected.lineSequence == [t.lineSegments[1].lineID])
                #expect(c.matches(selected))
                // Unknown/prohibited eligibility is preserved upstream, not authenticated here.
                #expect(f.visits[2].boarding == .unknown)
                #expect(try rail(selected, .timetable(c)).startStationID == t.stopSequence[2])
            }
        }
    }

    @Test func everySnapshotDifferenceRejectsDespiteSameTripID() throws {
        let t = try trip(), f = try facts(t)
        let revisions = try [trip(stops: ["A", "X", "A", "C"]),
            trip(stops: ["A", "X", "B", "A", "C"]), trip(boundary: 2),
            trip(origin: false), trip(destination: false), trip(serviceEnd: nil), trip(serviceEnd: 2)]
        let c = try #require(TimetableRideContext(train: train(t), facts: f))
        for revision in revisions {
            #expect(t == revision) // ID equality alone must not suffice.
            let changed = try train(revision, 0, revision.stopSequence.count - 1)
            #expect(TimetableRideContext(train: changed, facts: f) == nil)
            #expect(RouteRailProposal(travel: .matched(changed), scheduledContext: .timetable(c)) == nil)
        }
        let other = try train(trip(id: "OTHER"))
        #expect(TimetableRideContext(train: other, facts: f) == nil)
    }

    @Test func wrongRepeatedIndexAndUnresolvedAttachmentReject() throws {
        let t = try trip(), f = try facts(t), later = try train(t, 2, 3), earlier = try train(t)
        let c = try #require(TimetableRideContext(train: later, facts: f))
        #expect(earlier.anchors == later.anchors)
        #expect(RouteRailProposal(travel: .matched(earlier), scheduledContext: .timetable(c)) == nil)
        let unresolved = try #require(UnresolvedRouteRailTravel(anchors: later.anchors,
            lineSequence: later.lineSequence, reason: .noVerifiedMatch))
        #expect(RouteRailProposal(travel: .unresolved(unresolved), scheduledContext: .timetable(c)) == nil)
        #expect(RouteRailProposal(travel: .unresolved(unresolved), scheduledContext: nil) != nil)
        #expect(RouteRailProposal(travel: .unresolved(unresolved), scheduledContext: try provider(1, 30)) != nil)
    }

    @Test(arguments: [false, true])
    func missingOrEstimatedRequiredEndpointRejects(boarding: Bool) throws {
        let t = try trip(), selected = try train(t)
        let estimate = TimetableTime.estimated(try #require(TimetableInstant(Date(timeIntervalSince1970: 15))))
        for bad in [TimetableTime.missing, estimate] {
            var times: [(TimetableTime, TimetableTime)] = try [(.missing, time(1)), (.missing, .missing), (.missing, .missing), (time(30), .missing)]
            if boarding { times[0].1 = bad } else { times[3].0 = bad }
            let f = try facts(t, times: times)
            #expect(TimetableRideContext(train: selected, facts: f) == nil)
            #expect(boarding ? f.visits[0].departure == bad : f.visits[3].arrival == bad)
        }
    }

    @Test func missingCounterpartsEqualityAndQualifiedMidnight() throws {
        let t = try trip(), selected = try train(t)
        let formatter = ISO8601DateFormatter()
        let d = try #require(formatter.date(from: "2032-04-12T23:59:00+09:00"))
        let a = try #require(formatter.date(from: "2032-04-13T00:01:00+09:00"))
        for (departure, arrival) in [(d, d), (d, a)] {
            let di = try #require(TimetableInstant(departure)), ai = try #require(TimetableInstant(arrival))
            let f = try facts(t, times: [(.missing, .exact(di)), (.missing, .missing), (.missing, .missing), (.exact(ai), .missing)])
            let c = try #require(TimetableRideContext(train: selected, facts: f))
            #expect(c.departure == departure && c.arrival == arrival)
            #expect(c.binding.address.serviceDate.label == "2032-04-12")
        }
    }

    @Test func chronologyAcrossOriginsAndMissingContext() throws {
        let t = try trip(), selected = try train(t)
        let c = try #require(TimetableRideContext(train: selected, facts: facts(t)))
        let middle = try train(trip(id: "M", stops: ["C", "X", "Y", "D"]))
        let last = try train(trip(id: "LAST", stops: ["D", "E", "F", "G"]))
        let firstLeg = try rail(selected, .timetable(c))
        #expect(RouteCandidate(legs: try [firstLeg, rail(middle), rail(last, provider(29, 50))]) == nil)
        #expect(RouteCandidate(legs: try [firstLeg, rail(middle), rail(last, provider(30, 50))]) != nil)
        let prior = try train(trip(id: "P", stops: ["X", "Y", "Z", "A"]))
        #expect(RouteCandidate(legs: try [rail(prior, provider(-10, 2)), firstLeg]) == nil)
        #expect(RouteCandidate(legs: try [rail(prior, provider(-10, 1)), firstLeg]) != nil)
        let walk = try #require(WalkingTransfer(fromStationID: t.stopSequence[3], toStationID: last.anchors.boardingStationID))
        #expect(RouteCandidate(legs: try [firstLeg, .walkingTransfer(walk), rail(last, provider(29, 50))]) == nil)
    }

    @Test func duplicateTemplateOnDifferentDatesStillRejects() throws {
        let t = try trip(), first = try train(t, 0, 1), second = try train(t, 1, 3)
        let c1 = try #require(TimetableRideContext(train: first, facts: facts(t)))
        let c2 = try #require(TimetableRideContext(train: second, facts: facts(t, day: "2032-04-13")))
        #expect(c1.binding.address != c2.binding.address)
        #expect(RouteCandidate(legs: try [rail(first, .timetable(c1)), rail(second, .timetable(c2))]) == nil)
        #expect(RouteCandidate(legs: try [rail(first, .timetable(c1))]) != nil)
        #expect(RouteCandidate(legs: try [rail(second, .timetable(c2))]) != nil)
    }

    @Test func partialCoverageDoesNotChangeBindingOrIndices() throws {
        for origin in [false, true] {
            for destination in [false, true] {
                let t = try trip(origin: origin, destination: destination), selected = try train(t, 2, 3)
                let c = try #require(TimetableRideContext(train: selected, facts: facts(t)))
                assertSnapshot(c.binding.trip, t)
                #expect(c.boardingIndex == 2 && c.alightingIndex == 3)
            }
        }
    }

    @Test(arguments: [(Int.min, 3), (0, Int.max), (3, 2), (1, 1)])
    func invalidIndicesCannotSupplyAContext(_ indices: (Int, Int)) throws {
        #expect(TrainCandidate(trip: try trip(), boardingIndex: indices.0, alightingIndex: indices.1) == nil)
    }

    @Test func contextCrossesTaskBoundaryWithoutLosingOrigin() async throws {
        let t = try trip(), selected = try train(t)
        let c = try #require(TimetableRideContext(train: selected, facts: facts(t)))
        let result = await Task.detached { RouteScheduledContext.timetable(c) }.value
        guard case .timetable(let received) = result else { Issue.record("Lost timetable origin"); return }
        assertSnapshot(received.binding.trip, t)
        #expect(received.binding.address == c.binding.address)
        #expect(received.matches(selected))
    }
}
