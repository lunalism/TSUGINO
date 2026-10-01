import Foundation
import Testing
@testable import TSUGINO

/// DEC-078 constructor subcases only: invented labels, IDs, snapshots and qualified
/// instants. No calendar, feed, source correspondence or activation is validated.
struct TimetableValueTests {
    private func trip(stops: [String] = ["A", "B", "A", "C"], line: String = "L1",
                      origin: Bool = true, destination: Bool = true,
                      service: Bool = true) throws -> Trip {
        let lineID = try #require(LineID(line))
        let serviceID = try #require(ServiceTypeID("S1"))
        let tripID = try #require(TripID("T1"))
        let stationIDs = try stops.map { try #require(StationID($0)) }
        let segment = try #require(TripLineSegment(lineID: lineID,
                                                  startIndex: 0, endIndex: stops.count - 1))
        let types = service ? [try #require(TripServiceTypeSegment(
            serviceTypeID: serviceID, startIndex: 0, endIndex: 1))] : []
        return try #require(Trip(id: tripID,
            stopSequence: stationIDs, lineSegments: [segment],
            coverage: TripCoverage(includesServiceOrigin: origin, includesServiceDestination: destination),
            serviceTypeSegments: types))
    }
    private func binding(_ trip: Trip? = nil, view: Int = 1,
                         day: String = "2032-04-12") throws -> TimetableOccurrenceBinding {
        let uuid = try #require(UUID(uuidString: "00000000-0000-0000-0000-00000000000\(view)"))
        let snapshot = try trip ?? self.trip()
        let address = TimetableOccurrenceAddress(viewID: TimetableViewID(uuid), tripID: snapshot.id,
                                                 serviceDate: try #require(TimetableServiceDate(day)))
        return try #require(TimetableOccurrenceBinding(address: address, trip: snapshot))
    }
    private func exact(_ seconds: Double) throws -> TimetableTime {
        .exact(try #require(TimetableInstant(Date(timeIntervalSince1970: seconds))))
    }
    private func estimated(_ seconds: Double) throws -> TimetableTime {
        .estimated(try #require(TimetableInstant(Date(timeIntervalSince1970: seconds))))
    }
    private func visit(_ b: TimetableOccurrenceBinding, _ i: Int,
                       arrival: TimetableTime = .missing, departure: TimetableTime = .missing,
                       boarding: TimetableEligibility = .allowed,
                       alighting: TimetableEligibility = .allowed) throws -> TimetableVisitFacts {
        try #require(TimetableVisitFacts(binding: b, originalIndex: i, arrival: arrival,
                                        departure: departure, boarding: boarding, alighting: alighting))
    }
    private func visits(_ b: TimetableOccurrenceBinding) throws -> [TimetableVisitFacts] {
        try b.trip.stopSequence.indices.map { try visit(b, $0, departure: exact(Double($0) * 60)) }
    }
    private func assertSnapshot(_ a: Trip, _ b: Trip) {
        #expect(a.id == b.id)
        #expect(a.stopSequence == b.stopSequence)
        #expect(a.lineSegments == b.lineSegments)
        #expect(a.coverage == b.coverage)
        #expect(a.serviceTypeSegments == b.serviceTypeSegments)
    }

    @Test func ordinaryAndRepeatedVisitsPreserveOriginalSnapshot() throws {
        for stops in [["A", "B", "C"], ["A", "B", "A", "C"]] {
            let b = try binding(trip(stops: stops))
            let facts = try #require(TimetableOccurrenceFacts(binding: b, visits: visits(b)))
            assertSnapshot(facts.binding.trip, b.trip)
            #expect(facts.visits.map(\.originalIndex) == Array(stops.indices))
            for v in facts.visits { assertSnapshot(v.binding.trip, b.trip) }
            #expect(facts.visits.last?.departure == (try exact(Double(stops.count - 1) * 60)))
        }
    }

    @Test func dateAndViewAreSeparateFromTripIdentity() throws {
        let first = try binding(), nextDay = try binding(day: "2032-04-13"), nextView = try binding(view: 2)
        #expect(first.address != nextDay.address)
        #expect(first.address != nextView.address)
        #expect(first.trip == nextDay.trip) // Intentionally ID-only; contents checked separately.
        assertSnapshot(first.trip, nextDay.trip)
        #expect(TimetableOccurrenceFacts(binding: nextDay, visits: try visits(first)) == nil)
        #expect(TimetableOccurrenceFacts(binding: nextView, visits: try visits(first)) == nil)
        #expect(TimetableOccurrenceFacts(binding: nextDay, visits: try visits(nextDay)) != nil)
    }

    @Test func opaqueServiceDatePreservesLabelAndRejectsBlank() throws {
        #expect(TimetableServiceDate("") == nil)
        #expect(TimetableServiceDate(" \n\t") == nil)
        #expect(try #require(TimetableServiceDate("synthetic-day-label")).label == "synthetic-day-label")
    }

    @Test func bindingRejectsWrongTripID() throws {
        let b = try binding()
        let wrong = TimetableOccurrenceAddress(viewID: b.address.viewID,
            tripID: try #require(TripID("OTHER")), serviceDate: b.address.serviceDate)
        #expect(TimetableOccurrenceBinding(address: wrong, trip: b.trip) == nil)
    }

    @Test func insertedStopCannotReuseSameIDVisits() throws {
        let old = try binding(trip(stops: ["A", "B", "C"]))
        for view in [1, 2] {
            let new = try binding(trip(stops: ["A", "X", "B", "C"]), view: view)
            #expect(old.trip == new.trip)
            var supplied = try visits(new)
            supplied[2] = try visit(old, 2, arrival: exact(120))
            #expect(TimetableOccurrenceFacts(binding: new, visits: supplied) == nil)
            #expect(TimetableOccurrenceFacts.validationDiagnostic(binding: new, visits: supplied)?.reason == .occurrenceBinding)
        }
    }

    @Test func sameViewSameIDChangedContentsStillReject() throws {
        let b = try binding()
        let revisions = try [binding(trip(stops: ["A", "D", "A", "C"])),
                             binding(trip(line: "L2")), binding(trip(origin: false)),
                             binding(trip(destination: false)), binding(trip(service: false))]
        for revision in revisions {
            #expect(revision.address == b.address)
            #expect(TimetableOccurrenceFacts(binding: b, visits: try visits(revision)) == nil)
        }
    }

    @Test(arguments: [Int.min, -1, 4, Int.max])
    func invalidIndicesNeverTrap(_ index: Int) throws {
        let b = try binding()
        #expect(TimetableVisitFacts(binding: b, originalIndex: index, arrival: .missing,
            departure: .missing, boarding: .unknown, alighting: .unknown) == nil)
        #expect(TimetableEventLocation(originalIndex: index, kind: .arrival, stopCount: 4) == nil)
    }

    @Test func missingDuplicateAndReorderedVisitSlotsReject() throws {
        let b = try binding(), original = try visits(b)
        #expect(TimetableOccurrenceFacts(binding: b, visits: []) == nil)
        #expect(TimetableOccurrenceFacts(binding: b, visits: Array(original.dropLast())) == nil)
        var duplicate = original
        duplicate[2] = original[0] // Same repeated station, wrong original occurrence.
        #expect(TimetableOccurrenceFacts(binding: b, visits: duplicate) == nil)
        let diagnostic = try #require(TimetableOccurrenceFacts.validationDiagnostic(binding: b, visits: duplicate))
        #expect(diagnostic.event?.originalIndex == 2)
        #expect(diagnostic.event?.kind == nil)
        #expect(TimetableOccurrenceFacts(binding: b, visits: original.reversed()) == nil)
    }

    @Test func missingAndEstimatesRemainDistinctAndDoNotConstrainExactOrder() throws {
        let b = try binding()
        let v = try [visit(b, 0, departure: exact(100)),
                     visit(b, 1, arrival: estimated(9999)), visit(b, 2),
                     visit(b, 3, arrival: exact(200))]
        let facts = try #require(TimetableOccurrenceFacts(binding: b, visits: v))
        #expect(facts.visits[0].arrival == .missing)
        #expect(facts.visits[1].arrival == (try estimated(9999)))
        #expect(facts.visits[1].departure == .missing)
        #expect(facts.visits[2].arrival == .missing)
    }

    @Test(arguments: [Double.nan, Double.infinity, -Double.infinity])
    func nonfinitePayloadCannotEnterEitherTimeCase(_ value: Double) {
        #expect(TimetableInstant(Date(timeIntervalSinceReferenceDate: value)) == nil)
    }

    @Test func exactContradictionAcrossMissingAndEstimatedRejectsWholeValue() throws {
        let b = try binding()
        let v = try [visit(b, 0, departure: exact(100)), visit(b, 1),
                     visit(b, 2, departure: estimated(50)), visit(b, 3, arrival: exact(99))]
        #expect(TimetableOccurrenceFacts(binding: b, visits: v) == nil)
        let d = try #require(TimetableOccurrenceFacts.validationDiagnostic(binding: b, visits: v))
        #expect(d.reason == .chronologyConflict)
        #expect(d.event?.originalIndex == 0)
        #expect(d.event?.kind == .departure)
        #expect(d.laterEvent?.originalIndex == 3)
        #expect(d.laterEvent?.kind == .arrival)
    }

    @Test func withinVisitOrderAndEquality() throws {
        let b = try binding()
        var v = try visits(b)
        v[0] = try visit(b, 0, arrival: exact(1), departure: exact(0))
        #expect(TimetableOccurrenceFacts(binding: b, visits: v) == nil)
        v = try b.trip.stopSequence.indices.map { try visit(b, $0, arrival: exact(42), departure: exact(42)) }
        #expect(TimetableOccurrenceFacts(binding: b, visits: v) != nil)
    }

    @Test func eligibilityAndPartialCoveragePreserved() throws {
        for origin in [false, true] {
            for destination in [false, true] {
                let b = try binding(trip(origin: origin, destination: destination))
                var v = try visits(b)
                v[1] = try visit(b, 1, boarding: .prohibited, alighting: .unknown)
                let facts = try #require(TimetableOccurrenceFacts(binding: b, visits: v))
                #expect(facts.visits[0].boarding == .allowed)
                #expect(facts.visits[1].boarding == .prohibited)
                #expect(facts.visits[1].alighting == .unknown)
                assertSnapshot(facts.binding.trip, b.trip)
            }
        }
    }

    @Test func diagnosticsEnforceShapeAndLocationSafety() throws {
        let a = try #require(TimetableEventLocation(originalIndex: 0, kind: .arrival, stopCount: 2))
        let d = try #require(TimetableEventLocation(originalIndex: 0, kind: .departure, stopCount: 2))
        let visitOnly = try #require(TimetableEventLocation(originalIndex: 0, stopCount: 2))
        #expect(TimetableEventLocation(originalIndex: 0, stopCount: 0) == nil)
        #expect(TimetableDiagnostic(reason: .viewUnavailable, event: a) == nil)
        #expect(TimetableDiagnostic(reason: .activationUnavailable, event: a) == nil)
        #expect(TimetableDiagnostic(reason: .occurrenceBinding, laterEvent: d) == nil)
        #expect(TimetableDiagnostic(reason: .timeQualification, event: a) != nil)
        #expect(TimetableDiagnostic(reason: .chronologyConflict) == nil)
        #expect(TimetableDiagnostic(reason: .chronologyConflict, event: d, laterEvent: a) == nil)
        #expect(TimetableDiagnostic(reason: .chronologyConflict, event: a, laterEvent: a) == nil)
        #expect(TimetableDiagnostic(reason: .chronologyConflict, event: visitOnly, laterEvent: d) == nil)
        #expect(TimetableDiagnostic(reason: .chronologyConflict, event: a, laterEvent: d) != nil)
    }

    @Test func bindingDiagnosticPrecedesEarlierChronologyFault() throws {
        let b = try binding()
        var v = try visits(b)
        v[0] = try visit(b, 0, arrival: exact(10), departure: exact(0))
        v[3] = try visit(binding(view: 2), 3)
        #expect(TimetableOccurrenceFacts.validationDiagnostic(binding: b, visits: v)?.reason == .occurrenceBinding)
    }

    @Test func immutableValuesCrossTaskBoundary() async throws {
        let b = try binding()
        let facts = try #require(TimetableOccurrenceFacts(binding: b, visits: visits(b)))
        let received = await Task.detached { facts }.value
        assertSnapshot(received.binding.trip, b.trip)
        #expect(received.visits.map(\.originalIndex) == [0, 1, 2, 3])
    }
}
