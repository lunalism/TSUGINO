#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

nonisolated enum InternalFixture {
    static let viewID = TimetableViewID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    static func station(_ s: String) -> StationID { StationID(s)! }
    static func line(_ s: String) -> LineID { LineID(s)! }
    static func date(_ n: Double) -> Date { Date(timeIntervalSinceReferenceDate: n) }
    static func request(_ origin: String = "A", _ destination: String = "D", at: Double = 100) -> RouteSearchRequest {
        RouteSearchRequest(origin: station(origin), destination: station(destination), departNotBefore: date(at))!
    }
    static let connectionPolicy = InternalSearchPolicyReference(key: viewID.rawValue, revision: viewID.rawValue)
    static let interpretation = InternalSearchPolicyReference(key: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, revision: viewID.rawValue)
    static func configuration(trips: [String] = ["T1"], cap: Int = 3, duration: Double = 100,
                              stations: [String] = ["A", "B", "C", "D", "E"], lines: [String] = ["L1", "L2"]) -> SyntheticInternalConfiguration {
        .init(profile: InternalSearchProfileDefinition(identity: .init(key: viewID.rawValue, revision: viewID.rawValue),
            stations: Set(stations.map(station)), lines: Set(lines.map(line)), trips: Set(trips.map { TripID($0)! }),
            maximumElapsedDuration: duration, maximumRailRides: cap, connectionPolicy: connectionPolicy,
            serviceDateInterpretation: interpretation)!, permitted: true)
    }
    static func inventory(_ id: String = "T1", stops: [String] = ["A", "B", "D"], times: [Double] = [100, 120, 200],
                          segments: [(String, Int, Int)]? = nil, label: String = "d-a", partial: Bool = false,
                          boarding: [TimetableEligibility]? = nil, alighting: [TimetableEligibility]? = nil,
                          arrivals: [TimetableTime]? = nil, departures: [TimetableTime]? = nil) -> SyntheticInternalInventory {
        let trip = Trip(id: TripID(id)!, stopSequence: stops.map(station),
            lineSegments: (segments ?? [("L1", 0, stops.count - 1)]).map { TripLineSegment(lineID: line($0.0), startIndex: $0.1, endIndex: $0.2)! },
            coverage: .init(includesServiceOrigin: !partial, includesServiceDestination: !partial), serviceTypeSegments: [])!
        let address = TimetableOccurrenceAddress(viewID: viewID, tripID: trip.id, serviceDate: TimetableServiceDate(label)!)
        let binding = TimetableOccurrenceBinding(address: address, trip: trip)!
        let visits = stops.indices.map { i in
            TimetableVisitFacts(binding: binding, originalIndex: i,
                arrival: arrivals?[i] ?? .exact(TimetableInstant(date(times[i]))!),
                departure: departures?[i] ?? .exact(TimetableInstant(date(times[i]))!),
                boarding: boarding?[i] ?? .allowed, alighting: alighting?[i] ?? .allowed)!
        }
        var intervals: [SyntheticInternalInterval] = []
        for b in stops.indices { for a in stops.indices where a > b && stops[b] != stops[a] { intervals.append(.init(boarding: b, alighting: a)) } }
        let facts = TimetableOccurrenceFacts(binding: binding, visits: visits)!
        return .init(trip: trip, intervals: intervals, slots: [.init(address: address,
            activation: .active(facts, intervals.map { .init(interval: $0, evidence: .affirmed) }))])
    }
    static func key(_ a: SyntheticInternalInventory, _ ai: Int, _ b: SyntheticInternalInventory, _ bi: Int) -> SyntheticInternalConnectionKey {
        .init(alighting: .init(address: a.slots![0].address, index: ai), boarding: .init(address: b.slots![0].address, index: bi))
    }
    static func allowance(_ total: Double) -> SyntheticInternalAllowance { .init(alighting: 0, interchange: total, boarding: 0, total: total) }
    static func present(_ key: SyntheticInternalConnectionKey, _ total: Double, walking: Bool = false) -> SyntheticInternalConnection {
        .init(key: key, state: .present(walking ? .walking : .sameStation, allowance(total), .affirmed))
    }
    // Covers potential token pairs, not discovered complete routes. Missing overrides
    // default to explicitly negative records in this invented world's declared universe.
    static func connections(_ inventories: [SyntheticInternalInventory], overrides: [SyntheticInternalConnection] = []) -> [SyntheticInternalConnection] {
        var records: [SyntheticInternalConnectionKey: SyntheticInternalConnectionState] = [:]
        for a in inventories { for b in inventories where a.trip.id != b.trip.id {
            for sa in a.slots ?? [] { for sb in b.slots ?? [] {
                for ia in a.intervals ?? [] { for ib in b.intervals ?? [] {
                    records[.init(alighting: .init(address: sa.address, index: ia.alighting),
                                  boarding: .init(address: sb.address, index: ib.boarding))] = .absent
                } }
            } }
        } }
        for item in overrides { records[item.key] = item.state }
        return records.map { .init(key: $0.key, state: $0.value) }
    }
    static func view(_ inventories: [SyntheticInternalInventory], connections: [SyntheticInternalConnection] = [],
                     id: TimetableViewID = viewID, from: Double = 0, until: Double = 1000,
                     states: [StationID: Set<SyntheticInternalStationState>]? = nil) -> SyntheticInternalView {
        .init(id: id, validFrom: date(from), validUntil: date(until),
              stations: states ?? Dictionary(uniqueKeysWithValues: ["A", "B", "C", "D", "E", "X", "Y"].map { (station($0), [.active]) }),
              lines: [line("L1"), line("L2"), line("OUT")],
              policies: .init(qualifiedManifest: interpretation, directionalTotalAllowance: connectionPolicy),
              inventories: inventories, connections: connections)
    }
    static func batch(_ result: RouteSearchResult) throws -> RouteSearchBatch {
        guard case .internalSuccess(let success) = result, case .alternatives(let batch) = success.outcome else { throw FixtureError.expectedBatch }
        return batch
    }
    static func keys(_ batch: RouteSearchBatch) -> [[String]] {
        batch.candidates.map { candidate in candidate.legs.compactMap { leg in
            guard case .rail(let r) = leg, case .timetable(let c) = r.scheduledContext else { return nil }
            return "\(c.binding.address.tripID.rawValue)/\(c.binding.address.serviceDate.label)/\(c.boardingIndex)-\(c.alightingIndex)"
        } }
    }
    enum FixtureError: Error { case expectedBatch, cutoff }
}
actor InternalFirstCheckpoint {
    private var claimed = false
    func claim() -> Bool { if claimed { return false }; claimed = true; return true }
}
#endif
