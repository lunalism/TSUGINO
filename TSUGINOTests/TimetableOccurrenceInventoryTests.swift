import Foundation
import Testing
@testable import TSUGINO

/// Entirely invented local values. No source/profile/bundle/clock/IO fixture dependency.
struct TimetableOccurrenceInventoryTests {
    private func required<T>(_ value: T?) throws -> T { try #require(value) }

    private let view = TimetableViewID(UUID(uuidString: "00000000-0000-0000-0000-000000000123")!)

    private func reference(_ text: String = "invented-authority") throws -> TimetableQualificationReference {
        try required(TimetableQualificationReference(text))
    }
    private func railway(version: String = "invented-static", inputs: Int = 3) throws -> RailwayArtifactRevision {
        .init(dataVersion: try required(ExactValue(version)), registryRevision: 1,
              inputs: (0..<inputs).map { .init(role: "invented-input-\($0)", sha256: String(repeating: "a", count: 64)) },
              contentSHA256: String(repeating: "b", count: 64), previousSHA256: nil)
    }
    private func qualification(review: String = "invented-review", staticVersion: String = "invented-static",
                               otherView: Bool = false) throws -> TimetableInventoryQualification {
        try required(TimetableInventoryQualification(viewID: otherView ? TimetableViewID(UUID()) : view,
            source: reference("invented-source"), profile: reference("invented-profile"), zone: reference("invented-zone"),
            mapping: reference("invented-mapping"), review: reference(review), railway: railway(version: staticVersion)))
    }
    private func trip(_ id: String = "invented-trip", count: Int = 4, stops: [String]? = nil,
                      boundary: Int = 1, origin: Bool = false, service: Bool = false,
                      line: String = "invented-line-a") throws -> Trip {
        let names = stops ?? (0..<count).map { "invented-stop-\($0)" }
        let segments = try [required(TripLineSegment(lineID: required(LineID(line)), startIndex: 0, endIndex: boundary)),
            required(TripLineSegment(lineID: required(LineID("invented-line-b")), startIndex: boundary, endIndex: names.count-1))]
        let types = try service ? [required(TripServiceTypeSegment(serviceTypeID: required(ServiceTypeID("invented-service")), startIndex: 0, endIndex: 1))] : []
        return try required(Trip(id: required(TripID(id)), stopSequence: names.map { try required(StationID($0)) },
            lineSegments: segments, coverage: .init(includesServiceOrigin: origin, includesServiceDestination: false),
            serviceTypeSegments: types))
    }
    private func binding(_ trip: Trip, day: String = "invented-day-a", otherView: Bool = false) throws -> TimetableOccurrenceBinding {
        try required(TimetableOccurrenceBinding(address: .init(viewID: otherView ? TimetableViewID(UUID()) : view,
            tripID: trip.id, serviceDate: required(TimetableServiceDate(day))), trip: trip))
    }
    private func facts(_ binding: TimetableOccurrenceBinding, boarding: TimetableEligibility = .allowed,
                       alighting: TimetableEligibility = .allowed, departure: TimetableTime? = nil,
                       arrival: TimetableTime? = nil) throws -> TimetableOccurrenceFacts {
        let visits = try binding.trip.stopSequence.indices.map { index in
            try required(TimetableVisitFacts(binding: binding, originalIndex: index,
                arrival: arrival ?? .exact(required(TimetableInstant(Date(timeIntervalSince1970: Double(index * 10))))),
                departure: departure ?? .exact(required(TimetableInstant(Date(timeIntervalSince1970: Double(index * 10 + 1))))),
                boarding: boarding, alighting: alighting))
        }
        return try required(TimetableOccurrenceFacts(binding: binding, visits: visits))
    }
    private func intervals(_ binding: TimetableOccurrenceBinding, pairs: [TimetableVerifiedRideInterval] = [.init(boardingIndex: 0, alightingIndex: 3)],
                           completeness: TimetableInventoryCompleteness = .declaredComplete) throws -> TimetableOccurrenceIntervals {
        .init(binding: binding, authority: try reference(), completeness: completeness, declared: pairs)
    }
    private func slot(_ binding: TimetableOccurrenceBinding, qualification: TimetableInventoryQualification? = nil,
                      state: TimetableInventoryOccurrenceState = .inactive) throws -> TimetableOccurrenceInventorySlot {
        .init(qualification: try qualification ?? self.qualification(), binding: binding, state: state)
    }
    private func inventory(_ slots: [TimetableOccurrenceInventorySlot], addresses: [TimetableOccurrenceAddress]? = nil,
                           completeness: TimetableInventoryCompleteness = .declaredComplete) throws -> TimetableOccurrenceInventoryView {
        try .init(qualification: qualification(), declaredAddresses: addresses ?? slots.map(\.binding.address),
                  completeness: completeness, suppliedSlots: slots)
    }
    private func rejects(_ failure: TimetableInventoryConstructionFailure, _ operation: () throws -> TimetableOccurrenceInventoryView) {
        do { _ = try operation(); Issue.record("Expected bounded construction failure") }
        catch { #expect(error as? TimetableInventoryConstructionFailure == failure) }
    }

    @Test(arguments: [TimetableInventoryCompleteness.declaredComplete, .unknown])
    func coherentStatesAndDeterministicAssociation(_ completeness: TimetableInventoryCompleteness) throws {
        let a = try binding(trip()), b = try binding(trip("invented-other")), later = try binding(trip(), day: "invented-day-b")
        let held = try binding(trip("invented-held"))
        let good = try facts(a), bad = try facts(b, boarding: .prohibited, alighting: .unknown, departure: .missing, arrival: .missing)
        let input = try [slot(a, state: .active(good, intervals(a))), slot(b, state: .active(bad, intervals(b))),
                         slot(later), slot(held, state: .unavailable(.insufficientEvidence))]
        let addresses = input.map(\.binding.address)
        let result = try inventory(input.reversed(), addresses: addresses, completeness: completeness)
        #expect(result.declaredAddresses == addresses && result.slots.map(\.binding.address) == addresses)
        #expect(result.completeness == completeness)
        #expect(result.qualification.railway == (try railway()))
        guard case let .active(retained, spans) = result.slots[0].state else { Issue.record("lost active"); return }
        #expect(retained.binding.matches(good.binding) && retained.visits.count == 4)
        #expect(spans.declared == [.init(boardingIndex: 0, alightingIndex: 3)])
        guard case .inactive = result.slots[2].state,
              case .unavailable(.insufficientEvidence) = result.slots[3].state else { Issue.record("lost hold/inactive"); return }
        #expect(result.slots[0].binding.trip.lineSegments == a.trip.lineSegments)
    }
    @Test func emptyScopeAndEmptyIntervalsRemainDistinct() throws {
        let complete = try inventory([]), unknown = try inventory([], completeness: .unknown)
        #expect(complete.completeness != unknown.completeness && complete.slots.isEmpty && unknown.slots.isEmpty)
        let b = try binding(trip()), f = try facts(b)
        for completeness in [TimetableInventoryCompleteness.declaredComplete, .unknown] {
            let result = try inventory([slot(b, state: .active(f, intervals(b, pairs: [], completeness: completeness)))])
            guard case let .active(_, spans) = result.slots[0].state else { Issue.record("lost active"); continue }
            #expect(spans.declared.isEmpty && spans.completeness == completeness) // No inferred 0...3 or all-pairs.
        }
    }
    @Test(arguments: ["duplicateDeclaration", "duplicateSlot", "extra", "missing", "view", "revision", "static"])
    func associationDefects(_ defect: String) throws {
        let b = try binding(trip()), other = try binding(trip("invented-other")), s = try slot(b)
        switch defect {
        case "duplicateDeclaration": rejects(.declarationConflict) { try inventory([s], addresses: [b.address,b.address]) }
        case "duplicateSlot": rejects(.slotAssociation) { try inventory([s,s], addresses: [b.address]) }
        case "extra": rejects(.slotAssociation) { try inventory([s,slot(other)], addresses: [b.address]) }
        case "missing": rejects(.slotAssociation) { try inventory([], addresses: [b.address]) }
        case "view": rejects(.qualificationConflict) { try inventory([slot(binding(trip(), otherView: true))]) }
        case "revision": rejects(.qualificationConflict) { try inventory([slot(b, qualification: qualification(review: "invented-new"))]) }
        default: rejects(.staticRevisionConflict) { try inventory([slot(b, qualification: qualification(staticVersion: "invented-new-static"))]) }
        }
    }
    @Test(arguments: ["stops", "lines", "coverage", "service"])
    func sameIDSnapshotConflictAcrossDates(_ changed: String) throws {
        let original = try trip()
        let revision: Trip
        switch changed {
        case "stops": revision = try trip(stops: ["invented-stop-0","invented-changed","invented-stop-2","invented-stop-3"])
        case "lines": revision = try trip(boundary: 2)
        case "coverage": revision = try trip(origin: true)
        default: revision = try trip(service: true)
        }
        #expect(original == revision) // Domain identity deliberately equals; association must still reject.
        rejects(.snapshotConflict) { try inventory([slot(binding(original)), slot(binding(revision, day: "invented-day-b"))]) }
    }
    @Test(arguments: [false,true])
    func exactFactsAssociation(otherSnapshot: Bool) throws {
        let b = try binding(trip())
        let changed = try binding(otherSnapshot ? trip(origin: true) : trip(), day: otherSnapshot ? "invented-day-a" : "invented-day-b")
        rejects(.factsConflict) { try inventory([slot(b, state: .active(facts(changed), intervals(b)))]) }
    }
    @Test func finiteUnavailableReasonsCarryNoFacts() throws {
        #expect(TimetableInventoryUnavailableReason.allCases.count == 2)
        for reason in TimetableInventoryUnavailableReason.allCases {
            let result = try inventory([slot(binding(trip()), state: .unavailable(reason))])
            guard case let .unavailable(retained) = result.slots[0].state else { Issue.record("lost hold"); continue }
            #expect(retained == reason)
        }
        // Enum cases .inactive/.unavailable have no facts/interval payload to fabricate or omit.
    }
    @Test(arguments: [TimetableVerifiedRideInterval(boardingIndex: 1, alightingIndex: 1),
        .init(boardingIndex: 3, alightingIndex: 1), .init(boardingIndex: -1, alightingIndex: 1),
        .init(boardingIndex: 0, alightingIndex: 4), .init(boardingIndex: Int.min, alightingIndex: Int.max)])
    func invalidIntervalIndices(_ interval: TimetableVerifiedRideInterval) throws {
        let b = try binding(trip())
        rejects(.intervalConflict) { try inventory([slot(b, state: .active(facts(b), intervals(b, pairs: [interval])))]) }
    }
    @Test func repeatedStationsDuplicateIntervalsAndSnapshotOwnership() throws {
        let b = try binding(trip(stops: ["invented-a","invented-b","invented-a","invented-c"]))
        let positive = TimetableVerifiedRideInterval(boardingIndex: 2, alightingIndex: 3)
        let result = try inventory([slot(b, state: .active(facts(b), intervals(b, pairs: [positive,.init(boardingIndex: 0, alightingIndex: 1)])))])
        guard case let .active(_, spans) = result.slots[0].state else { Issue.record("lost intervals"); return }
        #expect(spans.declared.first == positive && spans.binding.matches(b))
        #expect(spans.binding.trip.lineSegments == b.trip.lineSegments) // Multi-Line snapshot retained, no connectivity invented.
        rejects(.intervalConflict) { try inventory([slot(b, state: .active(facts(b), intervals(b, pairs: [.init(boardingIndex: 0, alightingIndex: 2)])))]) }
        rejects(.intervalConflict) { try inventory([slot(b, state: .active(facts(b), intervals(b, pairs: [positive,positive])))]) }
        let changed = try binding(trip(stops: ["invented-a","invented-b","invented-a","invented-c"], origin: true))
        rejects(.intervalConflict) { try inventory([slot(b, state: .active(facts(b), intervals(changed, pairs: [positive])))]) }
        let otherDay = try binding(b.trip, day: "invented-day-b")
        rejects(.intervalConflict) { try inventory([slot(b, state: .active(facts(b), intervals(otherDay, pairs: [positive])))]) }
    }
    @Test(arguments: ["boarding", "alighting", "unknownBoarding", "unknownAlighting", "missingDeparture", "estimatedDeparture", "missingArrival", "estimatedArrival"])
    func structuralIntervalsSurviveEndpointUsability(_ condition: String) throws {
        let b = try binding(trip()), estimate = TimetableTime.estimated(try required(TimetableInstant(Date(timeIntervalSince1970: 7))))
        let f = try facts(b, boarding: condition == "boarding" ? .prohibited : (condition == "unknownBoarding" ? .unknown : .allowed),
            alighting: condition == "alighting" ? .prohibited : (condition == "unknownAlighting" ? .unknown : .allowed),
            departure: condition == "missingDeparture" ? .missing : (condition == "estimatedDeparture" ? estimate : nil),
            arrival: condition == "missingArrival" ? .missing : (condition == "estimatedArrival" ? estimate : nil))
        let result = try inventory([slot(b, state: .active(f, intervals(b)))])
        guard case let .active(retained, spans) = result.slots[0].state else { Issue.record("lost active"); return }
        #expect(spans.declared.count == 1 && retained.visits[0].departure == f.visits[0].departure)
        #expect(retained.visits[3].arrival == f.visits[3].arrival)
        #expect(retained.visits[0].boarding == f.visits[0].boarding && retained.visits[3].alighting == f.visits[3].alighting)
    }
    @Test func failureDoesNotMutateInputs() throws {
        let b = try binding(trip()), s = try slot(b), addresses = [b.address,b.address], slots = [s]
        rejects(.declarationConflict) { try inventory(slots, addresses: addresses) }
        #expect(addresses == [b.address,b.address] && slots.count == 1 && slots[0].binding.matches(b))
    }

    private func generated(trips: Int, dates: Int, stops: Int = 12, intervals: Int = 0) throws -> [TimetableOccurrenceInventorySlot] {
        var result: [TimetableOccurrenceInventorySlot] = []
        let q = try qualification()
        for t in 0..<trips {
            let snapshot = try trip("invented-generated-\(t)", count: stops)
            for d in 0..<dates {
                let b = try binding(snapshot, day: "invented-generated-day-\(d)")
                if intervals == 0 { result.append(try slot(b, qualification: q)); continue }
                var pairs: [TimetableVerifiedRideInterval] = []
                outer: for i in 0..<stops { for j in (i+1)..<stops {
                    pairs.append(.init(boardingIndex: i, alightingIndex: j)); if pairs.count == intervals { break outer }
                }}
                result.append(try slot(b, qualification: q, state: .active(facts(b), self.intervals(b, pairs: pairs))))
            }
        }
        return result
    }
    @Test func independentCountBoundsAndPlusOne() throws {
        let limits = TimetableInventoryLimits.self
        let maximum = try generated(trips: limits.uniqueTrips, dates: limits.serviceDates)
        #expect(maximum.count == limits.addresses)
        #expect(try inventory(maximum).slots.count == limits.addresses)
        rejects(.resourceLimit) { try inventory(maximum + [maximum[0]]) } // Top-level overflow before duplicate checks.
        rejects(.resourceLimit) { try inventory([], addresses: maximum.map(\.binding.address) + [maximum[0].binding.address]) }
        #expect(try inventory(generated(trips: limits.uniqueTrips, dates: 1)).slots.count == limits.uniqueTrips)
        rejects(.resourceLimit) { try inventory(generated(trips: limits.uniqueTrips + 1, dates: 1)) }
        #expect(try inventory(generated(trips: 1, dates: limits.serviceDates)).slots.count == limits.serviceDates)
        rejects(.resourceLimit) { try inventory(generated(trips: 1, dates: limits.serviceDates + 1)) }
        #expect(try inventory(generated(trips: 1, dates: 1, stops: limits.stopsPerTrip)).slots.count == 1)
        rejects(.resourceLimit) { try inventory(generated(trips: 1, dates: 1, stops: limits.stopsPerTrip + 1)) }
        #expect(try inventory(generated(trips: 1, dates: 1, intervals: limits.intervalsPerOccurrence)).slots.count == 1)
        rejects(.resourceLimit) { try inventory(generated(trips: 1, dates: 1, intervals: limits.intervalsPerOccurrence + 1)) }
    }
    @Test func generatedMaximumCombinedWorkAndTotalOverflow() throws {
        // All address/Trip/date axes at maximum; 32 intervals per slot reaches the independent total cap.
        let input = try generated(trips: 480, dates: 6, intervals: 32)
        let start = Date()
        let result = try inventory(input)
        print("INVENTED_INVENTORY_STRESS addresses=\(result.slots.count) intervals=92160 logicalBytes=\(result.logicalPayloadBytes) constructionMS=\(Date().timeIntervalSince(start)*1000)")
        #expect(result.slots.count == TimetableInventoryLimits.addresses)
        #expect(result.logicalPayloadBytes <= TimetableInventoryLimits.logicalPayloadBytes)
        let first = input[0]
        guard case let .active(f, spans) = first.state else { Issue.record("fixture"); return }
        let extra = TimetableVerifiedRideInterval(boardingIndex: 5, alightingIndex: 11)
        let changed = try slot(first.binding, state: .active(f, intervals(first.binding, pairs: spans.declared + [extra])))
        rejects(.resourceLimit) { try inventory([changed] + Array(input.dropFirst())) }
    }
    @Test func payloadBoundExactOverflowAndOversizedCombinedFixture() throws {
        var budget = TimetableInventoryPayloadBudget()
        try budget.include(TimetableInventoryLimits.logicalPayloadBytes)
        #expect(budget.used == TimetableInventoryLimits.logicalPayloadBytes)
        do { try budget.include(1); Issue.record("payload +1 accepted") }
        catch { #expect(error == .resourceLimit) }
        do { try budget.include(Int.max); Issue.record("overflow accepted") }
        catch { #expect(error == .resourceLimit) }
        #expect(budget.used == TimetableInventoryLimits.logicalPayloadBytes)
        // Individual axes fit, expanded repeated binding payload does not: atomic resource rejection.
        rejects(.resourceLimit) { try inventory(generated(trips: 480, dates: 6, stops: 72, intervals: 32)) }
    }
    @Test func qualificationAndNestedStaticBounds() throws {
        let limit = TimetableInventoryLimits.tokenBytes
        #expect(TimetableQualificationReference(String(repeating: "x", count: limit)) != nil)
        #expect(TimetableQualificationReference(String(repeating: "x", count: limit+1)) == nil)
        for bad in ["", "a b", "a\nb", "é", "a\u{7f}"] { #expect(TimetableQualificationReference(bad) == nil) }
        let r = try reference()
        func q(_ railway: RailwayArtifactRevision) -> TimetableInventoryQualification? {
            .init(viewID: view, source: r, profile: r, zone: r, mapping: r, review: r, railway: railway)
        }
        #expect(q(try railway(inputs: TimetableInventoryLimits.staticInputs)) != nil)
        #expect(q(try railway(inputs: TimetableInventoryLimits.staticInputs + 1)) == nil)
        #expect(q(try railway(version: String(repeating: "x", count: limit))) != nil)
        #expect(q(try railway(version: String(repeating: "x", count: limit+1))) == nil)
        let base = try railway()
        for n in [limit,limit+1] {
            let changed = RailwayArtifactRevision(dataVersion: base.dataVersion, registryRevision: 1,
                inputs: [.init(role: String(repeating: "x", count: n), sha256: String(repeating: "a", count: 64))],
                contentSHA256: base.contentSHA256, previousSHA256: nil)
            #expect((q(changed) != nil) == (n == limit))
        }
        #expect(q(.init(dataVersion: base.dataVersion, registryRevision: 1, inputs: base.inputs,
                        contentSHA256: String(repeating: "b", count: 65), previousSHA256: nil)) == nil)
    }
    @Test(arguments: ["trip", "station", "line", "date", "service"])
    func nestedTextExactAndPlusOne(_ kind: String) throws {
        for n in [TimetableInventoryLimits.tokenBytes, TimetableInventoryLimits.tokenBytes + 1] {
            let text = String(repeating: "x", count: n)
            var t = try trip(kind == "trip" ? text : "invented-trip",
                stops: kind == "station" ? [text,"invented-b","invented-c","invented-d"] : nil,
                line: kind == "line" ? text : "invented-line-a")
            if kind == "service" {
                t = try required(Trip(id: t.id, stopSequence: t.stopSequence, lineSegments: t.lineSegments, coverage: t.coverage,
                    serviceTypeSegments: [required(TripServiceTypeSegment(serviceTypeID: required(ServiceTypeID(text)), startIndex: 0, endIndex: 1))]))
            }
            let input = try [slot(binding(t, day: kind == "date" ? text : "invented-day-a"))]
            if n == TimetableInventoryLimits.tokenBytes { #expect(try inventory(input).slots.count == 1) }
            else { rejects(.resourceLimit) { try inventory(input) } }
        }
    }
    @Test func productionSendableTransfer() async throws {
        let value = try inventory([slot(binding(trip()))])
        func requireSendable<T: Sendable>(_ value: T) -> T { value }
        let transferred = await Task.detached { requireSendable(value).declaredAddresses.count }.value
        #expect(transferred == 1)
    }

    @Test func canonicallyEqualTripIDCannotBypassByteBound() throws {
        let shortID = String(repeating: "é", count: 96)
        let longID = String(repeating: "e\u{301}", count: 96)
        #expect(shortID == longID && shortID.utf8.count == 192 && longID.utf8.count == 288)
        let snapshot = try trip(longID)
        let address = TimetableOccurrenceAddress(viewID: view, tripID: try required(TripID(shortID)),
            serviceDate: try required(TimetableServiceDate("invented-day-a")))
        let b = try required(TimetableOccurrenceBinding(address: address, trip: snapshot))
        rejects(.resourceLimit) { try inventory([slot(b)]) }
    }

    @Test(arguments: ["trip", "date", "station", "line", "service"])
    func canonicallyEqualVisitBindingsCannotBypassRetainedBounds(_ field: String) throws {
        let short = String(repeating: "é", count: 96), long = String(repeating: "e\u{301}", count: 96)
        func snapshot(_ spelling: String) throws -> Trip {
            let t = try trip(field == "trip" ? spelling : "invented-trip",
                stops: field == "station" ? [spelling,"invented-b","invented-c","invented-d"] : nil,
                line: field == "line" ? spelling : "invented-line-a")
            if field != "service" { return t }
            return try required(Trip(id: t.id, stopSequence: t.stopSequence, lineSegments: t.lineSegments,
                coverage: t.coverage, serviceTypeSegments: [required(TripServiceTypeSegment(
                    serviceTypeID: required(ServiceTypeID(spelling)), startIndex: 0, endIndex: 1))]))
        }
        let b = try binding(snapshot(short), day: field == "date" ? short : "invented-day-a")
        let changed = try binding(snapshot(long), day: field == "date" ? long : "invented-day-a")
        #expect(b.matches(changed)) // Locally valid Domain association, unequal retained byte lengths.
        let visits = try changed.trip.stopSequence.indices.map { index in
            try required(TimetableVisitFacts(binding: changed, originalIndex: index, arrival: .missing,
                departure: .missing, boarding: .unknown, alighting: .unknown))
        }
        let f = try required(TimetableOccurrenceFacts(binding: b, visits: visits))
        rejects(.resourceLimit) { try inventory([slot(b, state: .active(f, intervals(b)))]) }
    }
}
