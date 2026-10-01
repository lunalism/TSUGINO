import Foundation
import Testing
@testable import TSUGINO

/// DEC-076's first-slice constructor subcases only. All identities/instants are
/// invented; no mapping, provider interpretation/admission or async case is run.
struct RoutingValueTests {
    private func station(_ name: String) throws -> StationID { try #require(StationID(name)) }
    private func line(_ name: String) throws -> LineID { try #require(LineID(name)) }
    private func date(_ seconds: Double) -> Date { Date(timeIntervalSince1970: seconds) }
    private func pair(_ departure: Double, _ arrival: Double) throws -> ProviderScheduledContext {
        try #require(ProviderScheduledContext(departure: date(departure), arrival: date(arrival)))
    }
    private func anchors(_ from: String, _ to: String) throws -> RailLegAnchors {
        try #require(RailLegAnchors(boardingStationID: station(from), alightingStationID: station(to)))
    }
    private func rail(_ from: String, _ to: String, context: ProviderScheduledContext? = nil) throws -> RouteCandidateLeg {
        let unresolved = try #require(UnresolvedRouteRailTravel(
            anchors: anchors(from, to), lineSequence: [line("L1")], reason: .notSupplied))
        return .rail(try #require(RouteRailProposal(travel: .unresolved(unresolved), scheduledContext: context.map(RouteScheduledContext.provider))))
    }
    private func walk(_ from: String, _ to: String) throws -> RouteCandidateLeg {
        .walkingTransfer(try #require(WalkingTransfer(fromStationID: station(from), toStationID: station(to))))
    }
    private func trip(id: String = "T1", stops: [String] = ["A", "B", "C", "B", "D"],
                      partial: Bool = false, splitLines: Bool = false) throws -> Trip {
        let segments: [TripLineSegment]
        if splitLines {
            segments = try [
                #require(TripLineSegment(lineID: line("L1"), startIndex: 0, endIndex: 1)),
                #require(TripLineSegment(lineID: line("L2"), startIndex: 1, endIndex: 3)),
                #require(TripLineSegment(lineID: line("L1"), startIndex: 3, endIndex: 4))
            ]
        } else {
            segments = try [#require(TripLineSegment(lineID: line("L1"), startIndex: 0, endIndex: stops.count - 1))]
        }
        let serviceID = try #require(ServiceTypeID("S1"))
        let tripID = try #require(TripID(id))
        let service = try #require(TripServiceTypeSegment(
            serviceTypeID: serviceID, startIndex: 0, endIndex: 1))
        return try #require(Trip(id: tripID, stopSequence: stops.map { try station($0) },
                                 lineSegments: segments,
                                 coverage: TripCoverage(includesServiceOrigin: !partial, includesServiceDestination: !partial),
                                 serviceTypeSegments: [service]))
    }
    private func matched(_ trip: Trip, _ board: Int, _ alight: Int) throws -> RouteCandidateLeg {
        let train = try #require(TrainCandidate(trip: trip, boardingIndex: board, alightingIndex: alight))
        return .rail(try #require(RouteRailProposal(travel: .matched(train), scheduledContext: nil)))
    }
    private func candidate(_ from: String = "A", _ to: String = "D") throws -> RouteCandidate {
        try #require(RouteCandidate(legs: [rail(from, to)]))
    }
    private func omission(_ index: Int, _ reasons: [RouteAlternativeRejectionReason] = [.unknownMapping]) throws -> RouteAlternativeOmission {
        try #require(RouteAlternativeOmission(alternativeIndex: index, reasons: reasons))
    }

    @Test func requestPreservesExactIdentityAndInstant() throws {
        // R35 valid companion; distinct same-name identities need no labels here.
        let value = try #require(RouteSearchRequest(origin: station("X"), destination: station("Y"), departNotBefore: date(42)))
        #expect(value.origin == (try station("X")))
        #expect(value.destination == (try station("Y")))
        #expect(value.departNotBefore == date(42))
        #expect(RouteSearchRequest(origin: try station("X"), destination: try station("X"), departNotBefore: date(42)) == nil)
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func requestRejectsNonfiniteTime(_ time: Double) throws {
        #expect(RouteSearchRequest(origin: try station("A"), destination: try station("B"), departNotBefore: date(time)) == nil)
    }

    @Test func unresolvedLinesMustAlreadyBeCollapsed() throws {
        let endpoints = try anchors("A", "D")
        #expect(UnresolvedRouteRailTravel(anchors: endpoints, lineSequence: [], reason: .notSupplied) == nil)
        #expect(UnresolvedRouteRailTravel(anchors: endpoints, lineSequence: try [line("L1"), line("L1")], reason: .notSupplied) == nil)
        let lines = try [line("L1"), line("L2"), line("L1")]
        for reason in [RouteUnresolvedReason.notSupplied, .noVerifiedMatch] {
            let value = try #require(UnresolvedRouteRailTravel(anchors: endpoints, lineSequence: lines, reason: reason))
            #expect(value.anchors == endpoints)
            #expect(value.lineSequence == lines)
            #expect(value.reason == reason)
        }
        #expect(RailLegAnchors(boardingStationID: try station("A"), alightingStationID: try station("A")) == nil)
    }

    @Test func originalSnapshotAndRepeatedVisitArePreserved() throws {
        // R02/R09/R12: inspect every snapshot field, not Trip's ID-only equality.
        let original = try trip(partial: true, splitLines: true)
        let value = try #require(TrainCandidate(trip: original, boardingIndex: 3, alightingIndex: 4))
        #expect(value.boardingIndex == 3)
        #expect(value.alightingIndex == 4)
        #expect(value.anchors == (try anchors("B", "D")))
        #expect(value.trip.id == original.id)
        #expect(value.trip.stopSequence == original.stopSequence)
        #expect(value.trip.lineSegments == original.lineSegments)
        #expect(value.trip.coverage == original.coverage)
        #expect(value.trip.serviceTypeSegments == original.serviceTypeSegments)
        #expect(value.trip.stopSequence.count == 5)
        #expect(!value.trip.coverage.includesServiceOrigin)
        #expect(!value.trip.coverage.includesServiceDestination)
    }

    @Test func throughServiceAndLimitedStopStructure() throws {
        let original = try trip(stops: ["A", "B", "C", "E", "D"], splitLines: true)
        let middle = try #require(TrainCandidate(trip: original, boardingIndex: 1, alightingIndex: 3))
        #expect(middle.lineSequence == (try [line("L2")]))
        let full = try #require(TrainCandidate(trip: original, boardingIndex: 0, alightingIndex: 4))
        #expect(full.lineSequence == (try [line("L1"), line("L2"), line("L1")]))
        let route = try #require(RouteCandidate(legs: [matched(original, 0, 4)]))
        #expect(route.transferCount == 0)
        let limited = try trip(stops: ["A", "D"])
        let train = try #require(TrainCandidate(trip: limited, boardingIndex: 0, alightingIndex: 1))
        #expect(train.trip.stopSequence == (try [station("A"), station("D")])) // R11: no inserted stops
    }

    @Test(arguments: [(Int.min, 2), (-1, 2), (1, 1), (3, 1), (0, 5), (0, Int.max), (Int.max, Int.min)])
    func invalidIndicesNeverAddressTheSnapshot(_ indices: (Int, Int)) throws {
        #expect(TrainCandidate(trip: try trip(), boardingIndex: indices.0, alightingIndex: indices.1) == nil)
    }

    @Test func fullLapAndDuplicateTripAreRejected() throws {
        let original = try trip()
        #expect(TrainCandidate(trip: original, boardingIndex: 1, alightingIndex: 3) == nil)
        #expect(RouteCandidate(legs: try [matched(original, 0, 1), matched(original, 1, 4)]) == nil)
        #expect(RouteCandidate(legs: try [matched(original, 0, 1), walk("B", "C"), matched(original, 2, 4)]) == nil)
        // Different snapshot, same ID cannot evade the within-candidate rule.
        let corrected = try trip(stops: ["B", "E", "D"])
        #expect(RouteCandidate(legs: try [matched(original, 0, 1), matched(corrected, 0, 2)]) == nil)
    }

    @Test func localRailAndWalkStructure() throws {
        #expect(RouteCandidate(legs: []) == nil)
        let direct = try candidate()
        #expect(direct.origin == (try station("A")))
        #expect(direct.destination == (try station("D")))
        #expect(direct.transferCount == 0)
        let transfer = try #require(RouteCandidate(legs: [rail("A", "B"), rail("B", "D")]))
        #expect(transfer.transferCount == 1)
        let walking = try #require(RouteCandidate(legs: [rail("A", "X"), walk("X", "Y"), rail("Y", "D")]))
        #expect(walking.transferCount == 1)
        #expect(RouteCandidate(legs: try [rail("A", "X"), rail("Y", "D")]) == nil)
        #expect(RouteCandidate(legs: try [walk("A", "B"), rail("B", "D")]) == nil)
        #expect(RouteCandidate(legs: try [rail("A", "B"), walk("B", "D")]) == nil)
        #expect(RouteCandidate(legs: try [walk("A", "D")]) == nil)
        #expect(RouteCandidate(legs: try [rail("A", "B"), walk("B", "X"), walk("X", "Y"), rail("Y", "D")]) == nil)
        #expect(RouteCandidate(legs: try [rail("A", "B"), walk("X", "Y"), rail("Y", "D")]) == nil)
        #expect(RouteCandidate(legs: try [rail("A", "B"), walk("B", "X"), rail("Y", "D")]) == nil)
        #expect(WalkingTransfer(fromStationID: try station("X"), toStationID: try station("X")) == nil)
    }

    @Test func distinctMatchedTrainsCanTransfer() throws {
        let first = try trip(stops: ["A", "B"])
        let second = try trip(id: "T2", stops: ["B", "D"])
        let value = try #require(RouteCandidate(legs: [matched(first, 0, 1), matched(second, 0, 1)]))
        #expect(value.transferCount == 1) // Structural only; no interchange evidence claim.
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func pairRejectsNonfiniteEndpoints(_ value: Double) {
        #expect(ProviderScheduledContext(departure: date(value), arrival: date(100)) == nil)
        #expect(ProviderScheduledContext(departure: date(0), arrival: date(value)) == nil)
    }

    @Test func suppliedPairsPreserveInstantsAndAllowEqualityAndMidnight() throws {
        #expect(ProviderScheduledContext(departure: date(2), arrival: date(1)) == nil)
        let equal = try pair(42, 42)
        #expect(equal.departure == date(42))
        #expect(equal.arrival == date(42))
        // R32e: already-qualified absolute instants; no parser/rollover interpretation.
        let departure = try #require(ISO8601DateFormatter().date(from: "2030-01-02T23:55:00Z"))
        let arrival = try #require(ISO8601DateFormatter().date(from: "2030-01-03T00:10:00Z"))
        let midnight = try #require(ProviderScheduledContext(departure: departure, arrival: arrival))
        #expect(midnight.departure == departure)
        #expect(midnight.arrival == arrival)
        #expect(RouteCandidate(legs: try [rail("A", "B", context: equal), rail("B", "D", context: pair(42, 600))]) != nil)
    }

    @Test func chronologyCrossesMissingContextsAndWalkingLegs() throws {
        // R30/31a/32a/32c: retained complete pairs only.
        let first = try rail("A", "B", context: pair(60, 1200))
        let middle = try rail("B", "C")
        let early = try rail("C", "D", context: pair(600, 1800))
        #expect(RouteCandidate(legs: [first, middle, early]) == nil)
        #expect(RouteCandidate(legs: try [first, walk("B", "C"), early]) == nil)
        #expect(RouteCandidate(legs: try [first, rail("B", "D", context: pair(600, 1800))]) == nil)
        #expect(RouteCandidate(legs: try [first, middle, rail("C", "D", context: pair(1200, 1800))]) != nil)
        #expect(RouteCandidate(legs: try [rail("A", "B"), rail("B", "C", context: pair(-1800, -900)), rail("C", "D")]) != nil)
        // Last value intentionally valid locally: no request-relative admission is claimed.
    }

    @Test func omissionReasonsRejectEmptyDuplicatesAndDisorder() throws {
        #expect(RouteAlternativeOmission(alternativeIndex: -1, reasons: [.unknownMapping]) == nil)
        #expect(RouteAlternativeOmission(alternativeIndex: Int.min, reasons: [.unknownMapping]) == nil)
        #expect(RouteAlternativeOmission(alternativeIndex: 0, reasons: []) == nil)
        #expect(RouteAlternativeOmission(alternativeIndex: 0, reasons: [.unknownMapping, .unknownMapping]) == nil)
        #expect(RouteAlternativeOmission(alternativeIndex: 0, reasons: [.invalidStructure, .unknownMapping]) == nil)
        let all = RouteAlternativeRejectionReason.allCases
        #expect(try omission(0, all).reasons == all)
        #expect(RouteAlternativeOmission(alternativeIndex: 0, reasons: Array(all.reversed())) == nil)
    }

    @Test func batchValidatesAccountingWithoutDeduplication() throws {
        let first = try candidate("A", "D")
        let second = try candidate("A", "E")
        let value = try #require(RouteSearchBatch(candidates: [first, second], omissions: [omission(1)]))
        #expect(value.candidates.map(\.destination) == (try [station("D"), station("E")]))
        #expect(value.omissions.map(\.alternativeIndex) == [1])
        #expect(RouteSearchBatch(candidates: [], omissions: []) == nil)
        #expect(RouteSearchBatch(candidates: [], omissions: try [omission(0)]) == nil)
        #expect(RouteSearchBatch(candidates: [first], omissions: try [omission(0), omission(0)]) == nil)
        #expect(RouteSearchBatch(candidates: [first], omissions: try [omission(1), omission(0)]) == nil)
        #expect(RouteSearchBatch(candidates: [first], omissions: try [omission(2)]) == nil)
        #expect(RouteSearchBatch(candidates: [first], omissions: try [omission(Int.max)]) == nil)
        #expect(RouteSearchBatch(candidates: [first], omissions: try [omission(0), omission(2)]) != nil)
        #expect(RouteSearchBatch(candidates: [first, first], omissions: []) != nil)
        if case .alternatives(let batch) = RouteSearchResult.alternatives(value) {
            #expect(batch.candidates.count == 2)
        } else { Issue.record("Expected alternatives") }
        if case .noResults = RouteSearchResult.noResults {} else { Issue.record("Expected noResults") }
    }

    @Test func allRejectedFailureCannotCarryInvalidAccounting() throws {
        #expect(RouteSearchRejections(omissions: []) == nil)
        #expect(RouteSearchRejections(omissions: try [omission(1)]) == nil)
        #expect(RouteSearchRejections(omissions: try [omission(0), omission(2)]) == nil)
        #expect(RouteSearchRejections(omissions: try [omission(1), omission(0)]) == nil)
        #expect(RouteSearchRejections(omissions: try [omission(0), omission(0)]) == nil)
        let payload = try #require(RouteSearchRejections(omissions: [omission(0), omission(1, [.unsupportedPortion])]))
        let failure = RouteSearchFailure.noUsableAlternatives(payload)
        if case .noUsableAlternatives(let rejected) = failure {
            #expect(rejected.omissions.map(\.alternativeIndex) == [0, 1])
            #expect(rejected.omissions[1].reasons == [.unsupportedPortion])
        } else { Issue.record("Expected all-rejected failure") }
    }

    @Test func sameIDAlternativeSnapshotsRemainDistinctValues() throws {
        // R33 value-only: no permission to admit incompatible dataset revisions.
        let first = try trip(stops: ["A", "B", "D"])
        let second = try trip(stops: ["A", "E", "D"], partial: true)
        let firstCandidate = try #require(RouteCandidate(legs: [matched(first, 0, 2)]))
        let secondCandidate = try #require(RouteCandidate(legs: [matched(second, 0, 2)]))
        let batch = try #require(RouteSearchBatch(candidates: [firstCandidate, secondCandidate], omissions: []))
        for (index, original) in [first, second].enumerated() {
            guard case .rail(let ride) = batch.candidates[index].legs[0],
                  case .matched(let train) = ride.travel else { Issue.record("Lost matched snapshot"); return }
            #expect(train.trip.id == original.id)
            #expect(train.trip.stopSequence == original.stopSequence)
            #expect(train.trip.lineSegments == original.lineSegments)
            #expect(train.trip.coverage == original.coverage)
            #expect(train.trip.serviceTypeSegments == original.serviceTypeSegments)
            #expect(train.boardingIndex == 0)
            #expect(train.alightingIndex == 2)
        }
    }
}
