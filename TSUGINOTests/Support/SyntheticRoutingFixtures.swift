#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// Entirely invented evidence/client support. No real provider format or source.
nonisolated enum RoutingFixture {
    static func station(_ name: String) -> StationID { StationID(name)! }
    static func line(_ name: String) -> LineID { LineID(name)! }
    static func date(_ seconds: Double) -> Date { Date(timeIntervalSince1970: 1_893_542_400 + seconds) }
    static func request(_ from: String = "A", _ to: String = "D", bound: Double = 0) -> RouteSearchRequest {
        RouteSearchRequest(origin: station(from), destination: station(to), departNotBefore: date(bound))!
    }
    static func trip(stops: [String] = ["A", "B", "C", "B", "D"], partial: Bool = false,
                     id: String = "T1", split: Bool = false) -> Trip {
        let segments = split ? [TripLineSegment(lineID: line("L1"), startIndex: 0, endIndex: 1)!,
                                TripLineSegment(lineID: line("L2"), startIndex: 1, endIndex: stops.count - 1)!]
            : [TripLineSegment(lineID: line("L1"), startIndex: 0, endIndex: stops.count - 1)!]
        return Trip(id: TripID(id)!, stopSequence: stops.map(station), lineSegments: segments,
                    coverage: TripCoverage(includesServiceOrigin: !partial, includesServiceDestination: !partial),
                    serviceTypeSegments: [TripServiceTypeSegment(serviceTypeID: ServiceTypeID("S1")!, startIndex: 0, endIndex: 1)!])!
    }
    static func view(id: String = "view-one", usable: Bool = true,
                     stationStatus: [StationID: SyntheticRouteStatus] = [:],
                     lineStatus: [LineID: SyntheticRouteStatus] = [:],
                     stationMappings: [String: SyntheticRouteResolution<StationID>] = [:],
                     lineMappings: [String: SyntheticRouteResolution<LineID>] = [:],
                     trainMappings: [String: SyntheticRouteResolution<TripID>] = [:],
                     trip: Trip? = nil, reviewed: Bool = true, tripViewID: String? = nil,
                     occurrences: [String: Int]? = nil, connections: Bool = true,
                     validMembership: Bool = true, validServiceTypes: Bool = true) -> SyntheticRouteDataView {
        let names = ["A", "B", "C", "D", "E", "X", "Y"]
        let trip = trip ?? self.trip()
        var stations = Dictionary(uniqueKeysWithValues: names.map { (station($0), SyntheticRouteStatus.active) })
        stations.merge(stationStatus) { _, new in new }
        var lines = Dictionary(uniqueKeysWithValues: ["L1", "L2", "L3"].map { (line($0), SyntheticRouteStatus.active) })
        lines.merge(lineStatus) { _, new in new }
        var sm = Dictionary(uniqueKeysWithValues: names.map { ($0, SyntheticRouteResolution.active(station($0))) })
        sm.merge(stationMappings) { _, new in new }
        var lm = Dictionary(uniqueKeysWithValues: ["L1", "L2", "L3"].map { ($0, SyntheticRouteResolution.active(line($0))) })
        lm.merge(lineMappings) { _, new in new }
        var tm: [String: SyntheticRouteResolution<TripID>] = ["run": .active(trip.id)]
        tm.merge(trainMappings) { _, new in new }
        let evidence = SyntheticTripEvidence(viewID: tripViewID ?? id, trip: trip, reviewed: reviewed,
            occurrences: occurrences ?? Dictionary(uniqueKeysWithValues: trip.stopSequence.indices.map { ("visit-\($0)", $0) }))
        let interchanges: Set<SyntheticInterchange> = connections ? Set(names.flatMap { name in
            ["L1", "L2", "L3"].flatMap { from in ["L1", "L2", "L3"].map { to in
                SyntheticInterchange(station: station(name), fromLine: line(from), toLine: line(to))
            }}
        }) : []
        return SyntheticRouteDataView(id: id, usable: usable, stations: stations, lines: lines,
            stationMappings: sm, lineMappings: lm, trainMappings: tm, trips: [trip.id: evidence],
            memberships: validMembership ? Dictionary(uniqueKeysWithValues: names.map {
                (station($0), Set([line("L1"), line("L2"), line("L3")]))
            }) : [:], serviceTypes: validServiceTypes ? [ServiceTypeID("S1")!] : [], interchanges: interchanges,
            walks: connections ? [SyntheticWalkingConnection(from: station("X"), to: station("Y"), fromLine: line("L1"), toLine: line("L2"))] : [])
    }
    static func ride(_ from: String = "A", _ to: String = "D", line: String = "L1",
                     fragments: [SyntheticRailFragment]? = nil, continuous: Bool = true, independent: Bool = true,
                     reference: String? = nil, board: String? = nil, alight: String? = nil,
                     departure: Double? = 60, arrival: Double? = 600, unused: [Date] = []) -> SyntheticRouteLeg {
        .rail(SyntheticRailInput(fragments: fragments ?? [SyntheticRailFragment(from: from, to: to, line: line)],
            continuousRide: continuous, independentRouteEvidence: independent, trainReference: reference,
            boardingOccurrence: board, alightingOccurrence: alight,
            scheduled: RouteScheduledEndpoints(departure: departure.map(date), arrival: arrival.map(date)),
            unusedTripEndpoints: unused))
    }
    static func alternative(_ legs: [SyntheticRouteLeg]? = nil, changes: [Bool] = [],
                            intent: Bool = true, wellFormed: Bool = true) -> SyntheticRouteAlternative {
        SyntheticRouteAlternative(wellFormed: wellFormed, legs: legs ?? [ride()], trainChanges: changes,
                                  assertsDepartureIntent: intent)
    }
    static func searcher(_ alternatives: [SyntheticRouteAlternative], view: SyntheticRouteDataView = view()) -> SyntheticRouteSearcher {
        SyntheticRouteSearcher(loadView: { view }, fetch: { _, id in
            SyntheticRouteEnvelope(viewID: id, alternatives: alternatives, explicitlyNoResults: alternatives.isEmpty)
        })
    }
    static func batch(_ result: RouteSearchResult) throws -> RouteSearchBatch {
        guard case .alternatives(let batch) = result else { throw FixtureError.expectedBatch }
        return batch
    }
    static func rail(_ candidate: RouteCandidate, at index: Int = 0) throws -> RouteRailProposal {
        guard case .rail(let rail) = candidate.legs[index] else { throw FixtureError.expectedRail }
        return rail
    }
    enum FixtureError: Error { case expectedBatch, expectedRail, rawClientError }
}

/// Cancellation-aware single-use barrier. Tests wait for entry before cancelling
/// or releasing; no wall-clock sleeps or scheduler-order assumptions.
actor RoutingTestGate {
    private var entered = false
    private var open = false
    private var waiting: CheckedContinuation<Void, any Error>?
    private var observers: [CheckedContinuation<Void, Never>] = []
    private(set) var cancellationObserved = false

    func wait() async throws {
        entered = true
        observers.forEach { $0.resume() }
        observers.removeAll()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                if Task.isCancelled {
                    cancellationObserved = true
                    continuation.resume(throwing: CancellationError())
                }
                else if open { continuation.resume() }
                else { waiting = continuation }
            }
        } onCancel: {
            Task { await self.cancel() }
        }
    }
    func waitUntilEntered() async {
        if entered { return }
        await withCheckedContinuation { observers.append($0) }
    }
    func release() {
        open = true
        waiting?.resume()
        waiting = nil
    }
    private func cancel() {
        cancellationObserved = true
        waiting?.resume(throwing: CancellationError())
        waiting = nil
    }
}

actor RoutingViewStore {
    private var value: SyntheticRouteDataView
    init(_ value: SyntheticRouteDataView) { self.value = value }
    func set(_ value: SyntheticRouteDataView) { self.value = value }
    func get() -> SyntheticRouteDataView { value }
}

actor RoutingCallCounter {
    private(set) var count = 0
    func increment() { count += 1 }
}

#endif
