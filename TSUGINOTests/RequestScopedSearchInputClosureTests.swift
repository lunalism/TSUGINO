import Foundation
import Testing
@testable import TSUGINO

/// Invented premises only: opaque labels/UUIDs/static digests, no file/clock/provider fixtures.
struct RequestScopedSearchInputClosureTests {
    private func required<T>(_ value: T?) throws -> T { try #require(value) }
    private func uuid(_ n: UInt8) -> UUID { UUID(uuid: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,n)) }
    private var view: TimetableViewID { TimetableViewID(uuid(201)) }
    private func ref(_ text: String = "invented-interval-authority") throws -> TimetableQualificationReference {
        try required(TimetableQualificationReference(text))
    }
    private func railway(_ version: String = "invented-closure-static", inputs: Int = 0) throws -> RailwayArtifactRevision {
        .init(dataVersion: try required(ExactValue(version)), registryRevision: 0,
              inputs: (0..<inputs).map { .init(role: "invented-input-\($0)", sha256: String(repeating: "d", count: 64)) },
              contentSHA256: String(repeating: "e", count: 64), previousSHA256: nil)
    }
    private func qualification(_ review: String = "invented-review", view: TimetableViewID? = nil,
                               railway: RailwayArtifactRevision? = nil) throws -> TimetableInventoryQualification {
        try required(TimetableInventoryQualification(viewID: view ?? self.view,
            source: ref("invented-source"), profile: ref("invented-source-profile"), zone: ref("invented-zone"),
            mapping: ref("invented-mapping"), review: ref(review), railway: railway ?? self.railway()))
    }
    private func trip(_ id: String = "invented-trip", count: Int = 4, stops: [String]? = nil,
                      line: String = "invented-line-a", coverage: Bool = false, service: Bool = false) throws -> Trip {
        let names = stops ?? (0..<count).map { "invented-stop-\($0)" }
        return try required(Trip(id: required(TripID(id)), stopSequence: names.map { try required(StationID($0)) },
            lineSegments: [required(TripLineSegment(lineID: required(LineID(line)), startIndex: 0, endIndex: 1)),
                           required(TripLineSegment(lineID: required(LineID("invented-line-b")), startIndex: 1, endIndex: names.count - 1))],
            coverage: .init(includesServiceOrigin: coverage, includesServiceDestination: false),
            serviceTypeSegments: service ? [required(TripServiceTypeSegment(serviceTypeID: required(ServiceTypeID("invented-type")), startIndex: 0, endIndex: 1))] : []))
    }
    private func binding(_ trip: Trip? = nil, day: String = "invented-opaque-day", view: TimetableViewID? = nil)
        throws -> TimetableOccurrenceBinding {
        let t = try trip ?? self.trip()
        return try required(TimetableOccurrenceBinding(address: .init(viewID: view ?? self.view, tripID: t.id,
            serviceDate: required(TimetableServiceDate(day))), trip: t))
    }
    private func scope(stations: [String]? = nil, lines: [String]? = nil, trips: [String]? = nil,
                       lower: Double = 100, origin: String = "invented-stop-0", destination: String = "invented-stop-3",
                       duration: Double = 1000, rides: Int = 3, revision: UInt8 = 202,
                       connection: UInt8 = 203, interpretation: UInt8 = 204, view: TimetableViewID? = nil) throws -> InternalSearchScope {
        let p = try required(InternalSearchProfileDefinition(identity: .init(key: uuid(200), revision: uuid(revision)),
            stations: Set((stations ?? (0..<4).map { "invented-stop-\($0)" }).map { try required(StationID($0)) }),
            lines: Set((lines ?? ["invented-line-a", "invented-line-b"]).map { try required(LineID($0)) }),
            trips: Set((trips ?? ["invented-trip"]).map { try required(TripID($0)) }),
            maximumElapsedDuration: duration, maximumRailRides: rides,
            connectionPolicy: .init(key: uuid(205), revision: uuid(connection)),
            serviceDateInterpretation: .init(key: uuid(206), revision: uuid(interpretation))))
        return try required(InternalSearchScope(profile: p,
            request: required(RouteSearchRequest(origin: required(StationID(origin)), destination: required(StationID(destination)),
                departNotBefore: Date(timeIntervalSinceReferenceDate: lower))), viewID: view ?? self.view))
    }
    private func applicability(_ name: String = "invented-occurrence-domain", scope: InternalSearchScope? = nil,
                               qualification: TimetableInventoryQualification? = nil) throws -> SearchInputClosureApplicability {
        try .init(reference: ref(name), scope: scope ?? self.scope(), qualification: qualification ?? self.qualification())
    }
    private func requirement(_ binding: TimetableOccurrenceBinding? = nil,
                             intervals: [TimetableVerifiedRideInterval] = [.init(boardingIndex: 0, alightingIndex: 3)],
                             reference: String = "invented-occurrence-domain", intervalAuthority: String = "invented-interval-authority") throws -> SearchInputOccurrenceRequirement {
        .init(binding: try binding ?? self.binding(), applicabilityReference: try ref(reference),
              intervalAuthority: try ref(intervalAuthority), intervals: intervals)
    }
    private func slot(_ binding: TimetableOccurrenceBinding? = nil, kind: Int = 0,
                      positive: [TimetableVerifiedRideInterval] = [.init(boardingIndex: 0, alightingIndex: 3)],
                      completeness: TimetableInventoryCompleteness = .declaredComplete,
                      intervalAuthority: String = "invented-interval-authority",
                      qualification: TimetableInventoryQualification? = nil) throws -> TimetableOccurrenceInventorySlot {
        let b = try binding ?? self.binding()
        let state: TimetableInventoryOccurrenceState
        switch kind {
        case 1: state = .inactive
        case 2: state = .unavailable(.unsupported)
        case 3: state = .unavailable(.insufficientEvidence)
        default:
            let visits = try b.trip.stopSequence.indices.map { index in
                try required(TimetableVisitFacts(binding: b, originalIndex: index,
                    arrival: .exact(required(TimetableInstant(Date(timeIntervalSinceReferenceDate: 100 + Double(index * 10))))),
                    departure: .exact(required(TimetableInstant(Date(timeIntervalSinceReferenceDate: 101 + Double(index * 10))))),
                    boarding: .allowed, alighting: .allowed))
            }
            state = try .active(required(TimetableOccurrenceFacts(binding: b, visits: visits)),
                .init(binding: b, authority: ref(intervalAuthority), completeness: completeness, declared: positive))
        }
        return try .init(qualification: qualification ?? self.qualification(), binding: b, state: state)
    }
    private func inventory(_ slots: [TimetableOccurrenceInventorySlot], qualification: TimetableInventoryQualification? = nil,
                           completeness: TimetableInventoryCompleteness = .declaredComplete) throws -> TimetableOccurrenceInventoryView {
        try .init(qualification: qualification ?? self.qualification(), declaredAddresses: slots.map(\.binding.address),
                  completeness: completeness, suppliedSlots: slots)
    }
    private func target(_ from: TimetableOccurrenceAddress? = nil, _ to: TimetableOccurrenceAddress? = nil,
                        alight: Int = 3, board: Int = 0, reference: String = "invented-connection-domain") throws -> SearchInputConnectionTarget {
        try .init(from: from ?? binding().address, alightingIndex: alight, to: to ?? binding().address,
                  boardingIndex: board, applicabilityReference: ref(reference))
    }
    private func make(scope: InternalSearchScope? = nil, inventory: TimetableOccurrenceInventoryView? = nil,
                      railway: RailwayArtifactRevision? = nil, required: [SearchInputOccurrenceRequirement]? = nil,
                      targets: [SearchInputConnectionTarget] = [], dependencies: [TimetableQualificationReference] = [],
                      occurrenceCompleteness: TimetableInventoryCompleteness = .declaredComplete,
                      connectionCompleteness: TimetableInventoryCompleteness = .declaredComplete,
                      occurrenceApplicability: SearchInputClosureApplicability? = nil,
                      connectionApplicability: SearchInputClosureApplicability? = nil,
                      dependencyApplicability: SearchInputClosureApplicability? = nil) throws -> RequestScopedSearchInputClosure {
        try .init(scope: scope ?? self.scope(), inventory: inventory ?? self.inventory([slot()]), railway: railway ?? self.railway(),
            occurrences: .init(applicability: occurrenceApplicability ?? applicability(), completeness: occurrenceCompleteness,
                               required: required ?? [requirement()]),
            connections: .init(applicability: connectionApplicability ?? applicability("invented-connection-domain"),
                               completeness: connectionCompleteness, required: targets),
            dependencies: .init(applicability: dependencyApplicability ?? applicability("invented-dependency-domain"), unresolved: dependencies))
    }
    private func rejects(_ reason: SearchInputClosureConstructionFailure, _ operation: () throws -> RequestScopedSearchInputClosure) {
        do { _ = try operation(); Issue.record("Expected atomic construction rejection") }
        catch { #expect(error as? SearchInputClosureConstructionFailure == reason) }
    }

    @Test func positiveLocalAccountingPreservesExactScopeWithoutSearch() throws {
        let s = try scope(), c = try make(scope: s)
        #expect(c.isTechnicallyQualified && c.holds.isEmpty)
        #expect(c.occurrenceAccounting == [.active([.present])])
        #expect(c.scope.profile.hasSameDefinition(as: s.profile))
        #expect(c.scope.request.origin == s.request.origin && c.scope.request.destination == s.request.destination)
        #expect(c.scope.request.departNotBefore == s.request.departNotBefore)
        #expect(c.scope.lowerBound == s.lowerBound && c.scope.upperBound == s.upperBound && c.scope.viewID == s.viewID)
        #expect(c.railway == (try railway()))
        #expect(c.inventory.slots[0].binding.matches(try binding()))
        #expect(c.occurrences.applicability.reference != c.connections.applicability.reference)
        #expect(c.occurrences.required[0].intervalAuthority == (try ref()))
        // This is input accounting, never a RouteSearchResult/Failure, candidate, path or optimum.
        func transferable<T: Sendable>(_: T) {}
        transferable(c); transferable(c.holds); transferable(c.connections); transferable(c.occurrenceAccounting)
    }
    @Test(arguments: [TimetableInventoryCompleteness.declaredComplete, .unknown])
    func emptyOccurrenceDomainNeedsExplicitExactAuthority(_ completeness: TimetableInventoryCompleteness) throws {
        let c = try make(inventory: inventory([]), required: [], occurrenceCompleteness: completeness)
        #expect(c.isTechnicallyQualified == (completeness == .declaredComplete))
        #expect(c.holds == (completeness == .unknown ? [.occurrenceDomainUnknown] : []))
        // Complete-empty is a stipulated invented request premise, not no-service/noResults.
    }
    @Test(arguments: [TimetableInventoryCompleteness.declaredComplete, .unknown])
    func emptyConnectionDomainNeedsItsOwnExactAuthority(_ completeness: TimetableInventoryCompleteness) throws {
        let c = try make(connectionCompleteness: completeness)
        #expect(c.isTechnicallyQualified == (completeness == .declaredComplete))
        #expect(c.holds == (completeness == .unknown ? [.connectionDomainUnknown] : []))
    }
    @Test(arguments: ["present", "absentComplete", "absentUnknown", "inactive", "unsupported", "insufficient", "notLoaded"])
    func negativeAndUnknownHaveDifferentAccounting(_ kind: String) throws {
        let slots: [TimetableOccurrenceInventorySlot]
        switch kind {
        case "notLoaded": slots = []
        case "inactive": slots = try [slot(kind: 1)]
        case "unsupported": slots = try [slot(kind: 2)]
        case "insufficient": slots = try [slot(kind: 3)]
        case "absentComplete": slots = try [slot(positive: [])]
        case "absentUnknown": slots = try [slot(positive: [], completeness: .unknown)]
        default: slots = try [slot(completeness: .unknown)]
        }
        let c = try make(inventory: inventory(slots))
        switch kind {
        case "present": #expect(c.occurrenceAccounting == [.active([.present])] && c.isTechnicallyQualified)
        case "absentComplete": #expect(c.occurrenceAccounting == [.active([.absentUnderCompleteAuthority])] && c.isTechnicallyQualified)
        case "inactive": #expect(c.occurrenceAccounting == [.inactive] && c.isTechnicallyQualified)
        case "absentUnknown": #expect(c.holds == [.intervalUnknown(occurrence: 0, interval: 0)] && !c.isTechnicallyQualified)
        case "unsupported": #expect(c.holds == [.occurrenceUnsupported(0)] && !c.isTechnicallyQualified)
        case "insufficient": #expect(c.holds == [.occurrenceInsufficientEvidence(0)] && !c.isTechnicallyQualified)
        default: #expect(c.holds == [.occurrenceNotLoaded(0)] && !c.isTechnicallyQualified)
        }
    }
    @Test func usableDirectInputCannotDischargeConnectionOrExternalDependencies() throws {
        let c = try make(targets: [target()], dependencies: [ref("invented-unresolved")])
        #expect(c.occurrenceAccounting == [.active([.present])])
        #expect(c.holds == [.connectionUnresolved(0), .dependencyUnresolved(0)] && !c.isTechnicallyQualified)
        #expect(c.connections.required.count == 1 && c.dependencies.unresolved.count == 1)
    }
    @Test func requirednessDoesNotFollowLoadedMembershipOrInventoryCompleteness() throws {
        let extra = try binding(trip("invented-extra"))
        let c = try make(inventory: inventory([slot(extra, kind: 2)], completeness: .declaredComplete))
        #expect(c.holds == [.occurrenceNotLoaded(0)])
        let positive = try make(inventory: inventory([slot(), slot(extra, kind: 2)], completeness: .unknown))
        #expect(positive.isTechnicallyQualified && positive.occurrences.required.count == 1)
    }
    @Test func opaqueDateAndExplicitIntervalOrderSurviveWithoutEnumeration() throws {
        let b = try binding(day: "invented NOT a calendar; earlier-service-label")
        let pairs: [TimetableVerifiedRideInterval] = [.init(boardingIndex: 1, alightingIndex: 3), .init(boardingIndex: 0, alightingIndex: 2)]
        let c = try make(inventory: inventory([slot(b, positive: pairs)]), required: [requirement(b, intervals: pairs)])
        #expect(c.isTechnicallyQualified && c.occurrences.required[0].binding.address.serviceDate == b.address.serviceDate)
        #expect(c.occurrences.required[0].intervals == pairs && c.occurrenceAccounting == [.active([.present, .present])])
    }
    @Test(arguments: ["definition", "stations", "lines", "trips", "identity", "connection", "interpretation", "rides", "departure", "origin", "destination"])
    func staleFullScopeApplicabilityRejects(_ change: String) throws {
        let s: InternalSearchScope
        switch change {
        case "definition": s = try scope(duration: 999)
        case "stations": s = try scope(stations: (0..<5).map { "invented-stop-\($0)" })
        case "lines": s = try scope(lines: ["invented-line-a", "invented-line-b", "invented-new"])
        case "trips": s = try scope(trips: ["invented-trip", "invented-new"])
        case "identity": s = try scope(revision: 207)
        case "connection": s = try scope(connection: 207)
        case "interpretation": s = try scope(interpretation: 207)
        case "rides": s = try scope(rides: 2)
        case "departure": s = try scope(lower: 101)
        case "origin": s = try scope(origin: "invented-stop-1")
        default: s = try scope(destination: "invented-stop-2")
        }
        rejects(.scopeConflict) { try make(scope: s) }
    }
    @Test(arguments: ["scopeView", "static", "qualification", "requirementView", "requirementReference", "intervalAuthority", "connectionAuthority", "dependencyAuthority"])
    func mixedAuthoritiesReject(_ change: String) throws {
        switch change {
        case "scopeView": rejects(.qualificationConflict) { try make(scope: scope(view: TimetableViewID(uuid(207)))) }
        case "static": rejects(.staticRevisionConflict) { try make(railway: railway("invented-other-static")) }
        case "qualification":
            let q = try qualification("invented-revised-review")
            rejects(.qualificationConflict) { try make(inventory: inventory([slot(qualification: q)], qualification: q)) }
        case "requirementView": rejects(.qualificationConflict) { try make(required: [requirement(binding(view: TimetableViewID(uuid(207))))]) }
        case "requirementReference": rejects(.qualificationConflict) { try make(required: [requirement(reference: "invented-other")]) }
        case "intervalAuthority": rejects(.intervalConflict) { try make(inventory: inventory([slot(intervalAuthority: "invented-new-intervals")])) }
        case "connectionAuthority": rejects(.scopeConflict) { try make(connectionApplicability: applicability("invented-connection-domain", scope: scope(lower: 101))) }
        default: rejects(.scopeConflict) { try make(dependencyApplicability: applicability("invented-dependency-domain", scope: scope(lower: 101))) }
        }
    }
    @Test(arguments: ["stops", "line", "coverage", "service", "missingCrossDate"])
    func sameTripIDIsNotSnapshotCompatibility(_ change: String) throws {
        let altered: Trip
        switch change {
        case "stops": altered = try trip(stops: ["invented-stop-0", "invented-changed", "invented-stop-2", "invented-stop-3"])
        case "line": altered = try trip(line: "invented-changed")
        case "coverage": altered = try trip(coverage: true)
        case "service": altered = try trip(service: true)
        default: altered = try trip(coverage: true)
        }
        #expect(altered == (try trip())) // Identity alone intentionally equal.
        if change == "missingCrossDate" {
            rejects(.snapshotConflict) { try make(inventory: inventory([]), required: [requirement(), requirement(binding(altered, day: "invented-day-two"))]) }
        } else {
            rejects(.snapshotConflict) { try make(required: [requirement(binding(altered))]) }
        }
    }
    @Test(arguments: ["trip", "station", "line"])
    func activeRequiredIntervalMustBeProfileSupported(_ defect: String) throws {
        let s = try scope(stations: defect == "station" ? ["invented-stop-0", "invented-stop-3"] : nil,
                          lines: defect == "line" ? ["invented-line-a"] : nil,
                          trips: defect == "trip" ? ["invented-other"] : nil)
        rejects(.profileConflict) { try make(scope: s,
            occurrenceApplicability: applicability(scope: s), connectionApplicability: applicability("invented-connection-domain", scope: s),
            dependencyApplicability: applicability("invented-dependency-domain", scope: s)) }
    }
    @Test func offIntervalStationsAndBoundaryOnlyLinesNeedNotBeSupported() throws {
        let s = try scope(stations: ["invented-stop-1", "invented-stop-2", "invented-stop-3"], lines: ["invented-line-b"], origin: "invented-stop-1")
        let pair = TimetableVerifiedRideInterval(boardingIndex: 1, alightingIndex: 3)
        let c = try make(scope: s, inventory: inventory([slot(positive: [pair])]), required: [requirement(intervals: [pair])],
            occurrenceApplicability: applicability(scope: s), connectionApplicability: applicability("invented-connection-domain", scope: s),
            dependencyApplicability: applicability("invented-dependency-domain", scope: s))
        #expect(c.isTechnicallyQualified) // Line-a merely touches boarding boundary; stop-0 not ridden.
    }
    @Test func missingDateStillRejectsKnownLoadedRecurringSnapshotConflict() throws {
        let later = try binding(trip(coverage: true), day: "invented-later-date")
        rejects(.snapshotConflict) { try make(required: [requirement(later)]) }
        let compatible = try binding(day: "invented-later-date")
        #expect(try make(required: [requirement(compatible)]).holds == [.occurrenceNotLoaded(0)])
    }
    @Test(arguments: ["occurrence", "interval", "dependency", "connection"])
    func duplicateDeclarationsRejectInsteadOfLastWins(_ duplicate: String) throws {
        switch duplicate {
        case "occurrence": rejects(.declarationConflict) { try make(required: [requirement(), requirement()]) }
        case "dependency": rejects(.declarationConflict) { try make(dependencies: [ref("invented-dependency"), ref("invented-dependency")]) }
        case "connection": rejects(.connectionTargetConflict) { try make(targets: [target(), target()]) }
        default: rejects(.intervalConflict) { try make(required: [requirement(intervals: [.init(boardingIndex: 0, alightingIndex: 3), .init(boardingIndex: 0, alightingIndex: 3)])]) }
        }
    }
    @Test(arguments: ["view", "address", "alightNegative", "alightZero", "alightRange", "boardNegative", "boardLast", "boardRange", "reference"])
    func connectionLocalStructureOnly(_ defect: String) throws {
        let b = try binding(), other = try binding(trip("invented-undeclared")), wrong = try binding(view: TimetableViewID(uuid(207)))
        let t = try target(defect == "view" ? wrong.address : b.address,
                           defect == "address" ? other.address : b.address,
                           alight: defect == "alightNegative" ? Int.min : defect == "alightZero" ? 0 : defect == "alightRange" ? Int.max : 3,
                           board: defect == "boardNegative" ? Int.min : defect == "boardLast" ? 3 : defect == "boardRange" ? Int.max : 0,
                           reference: defect == "reference" ? "invented-wrong" : "invented-connection-domain")
        rejects(.connectionTargetConflict) { try make(inventory: inventory([]), targets: [t]) }
    }
    @Test func directionalReverseIsDistinctAndAlwaysHeldWithoutConnectionPayload() throws {
        let a = try binding(), b = try binding(trip("invented-second"))
        let targets = try [target(a.address, b.address, alight: 2, board: 1), target(b.address, a.address, alight: 1, board: 2)]
        let s = try scope(trips: ["invented-trip", "invented-second"])
        let c = try custom(s, qualification(), requirements: [requirement(a), requirement(b)],
                           inventory: inventory([slot(a), slot(b)]), targets: targets)
        #expect(c.holds == [.connectionUnresolved(0), .connectionUnresolved(1)])
        // This target's five stored fields contain no duration/form/allowance/payload.
        #expect(Mirror(reflecting: targets[0]).children.compactMap(\.label) == ["from", "alightingIndex", "to", "boardingIndex", "applicabilityReference"])
    }
    @Test(arguments: [TimetableVerifiedRideInterval(boardingIndex: -1, alightingIndex: 2), .init(boardingIndex: 2, alightingIndex: 2),
                      .init(boardingIndex: 3, alightingIndex: 1), .init(boardingIndex: 0, alightingIndex: Int.max)])
    func malformedObligationRejectsEvenWhenNotLoaded(_ interval: TimetableVerifiedRideInterval) throws {
        rejects(.intervalConflict) { try make(inventory: inventory([]), required: [requirement(intervals: [interval])]) }
    }
    @Test func deterministicHoldsRetainAllIndependentUnknowns() throws {
        let c = try make(inventory: inventory([]), targets: [target()], dependencies: [ref("invented-d")],
                         occurrenceCompleteness: .unknown, connectionCompleteness: .unknown)
        #expect(c.holds == [.occurrenceDomainUnknown, .connectionDomainUnknown, .occurrenceNotLoaded(0), .connectionUnresolved(0), .dependencyUnresolved(0)])
    }
    @Test func referencesAreBoundedPrintableAndDoNotAuthenticateEmptyPremises() throws {
        #expect(TimetableQualificationReference("") == nil && TimetableQualificationReference("invented\n") == nil)
        #expect(TimetableQualificationReference(String(repeating: "x", count: 192)) != nil)
        #expect(TimetableQualificationReference(String(repeating: "x", count: 193)) == nil)
        let c = try make(required: [], occurrenceCompleteness: .unknown, connectionCompleteness: .unknown)
        #expect(!c.isTechnicallyQualified) // Authority tokens exist, but do not make unknown complete.
    }
    private func generatedRequirements(trips: Int = 480, dates: Int = 6, stops: Int = 12,
                                       intervalTotal: Int = 0) throws -> [SearchInputOccurrenceRequirement] {
        let pairs = (0..<stops).flatMap { b in ((b + 1)..<stops).map { TimetableVerifiedRideInterval(boardingIndex: b, alightingIndex: $0) } }
        var result: [SearchInputOccurrenceRequirement] = []
        var remaining = intervalTotal
        for t in 0..<trips {
            let trip = try self.trip("invented-trip-\(t)", count: stops)
            for day in 0..<dates {
                let count = min(48, remaining)
                result.append(try requirement(binding(trip, day: "invented-day-\(day)"), intervals: Array(pairs.prefix(count))))
                remaining -= count
            }
        }
        #expect(remaining == 0)
        return result
    }
    private func generatedTargets(_ requirements: [SearchInputOccurrenceRequirement], fanout: Int = 8) throws -> [SearchInputConnectionTarget] {
        try requirements.indices.flatMap { i in
            try (0..<fanout).map { n in
                try target(requirements[i].binding.address, requirements[(i + (n + 1) * 6) % requirements.count].binding.address,
                           alight: n + 1, board: n)
            }
        }
    }
    private func custom(_ s: InternalSearchScope, _ q: TimetableInventoryQualification,
                        requirements: [SearchInputOccurrenceRequirement] = [], inventory: TimetableOccurrenceInventoryView? = nil,
                        targets: [SearchInputConnectionTarget] = [], dependencies: [TimetableQualificationReference] = []) throws -> RequestScopedSearchInputClosure {
        try make(scope: s, inventory: inventory ?? self.inventory([], qualification: q), railway: q.railway, required: requirements,
            targets: targets, dependencies: dependencies,
            occurrenceApplicability: applicability(scope: s, qualification: q),
            connectionApplicability: applicability("invented-connection-domain", scope: s, qualification: q),
            dependencyApplicability: applicability("invented-dependency-domain", scope: s, qualification: q))
    }
    @Test func generatedMaximumActiveWorkAndNewDimensionExactLimits() throws {
        let requirements = try generatedRequirements(intervalTotal: SearchInputClosureLimits.totalIntervals)
        let targets = try generatedTargets(requirements)
        let dependencies = try (0..<SearchInputClosureLimits.dependencies).map { try ref("invented-dependency-\($0)") }
        let s = try scope(stations: (0..<12).map { "invented-stop-\($0)" }, trips: (0..<480).map { "invented-trip-\($0)" })
        let q = try qualification()
        let slots = try requirements.map { try slot($0.binding, positive: $0.intervals) }
        let inventory = try self.inventory(slots)
        let start = ContinuousClock.now
        let c = try custom(s, q, requirements: requirements, inventory: inventory, targets: targets, dependencies: dependencies)
        let elapsed = start.duration(to: .now)
        print("Invented actual closure maximum: requirements=\(requirements.count), intervals=\(requirements.reduce(0) { $0 + $1.intervals.count }), targets=\(targets.count), dependencies=\(dependencies.count), logicalBytes=\(c.logicalPayloadBytes), duration=\(elapsed)")
        #expect(requirements.count == SearchInputClosureLimits.occurrences && targets.count == SearchInputClosureLimits.connections)
        #expect(c.occurrenceAccounting.count == 2880 && c.occurrenceAccounting.allSatisfy { if case .active = $0 { true } else { false } })
        #expect(c.holds.count == SearchInputClosureLimits.connections + SearchInputClosureLimits.dependencies)
        #expect(c.holds.first == .connectionUnresolved(0) && c.holds.last == .dependencyUnresolved(1439))
        #expect(c.logicalPayloadBytes <= SearchInputClosureLimits.logicalPayloadBytes && !c.isTechnicallyQualified)
        rejects(.resourceLimit) { try custom(s, q, requirements: requirements + [requirements[0]], inventory: inventory) }
        rejects(.resourceLimit) { try custom(s, q, requirements: requirements, inventory: inventory, targets: targets + [targets[0]]) }
        rejects(.resourceLimit) { try custom(s, q, requirements: requirements, inventory: inventory, dependencies: dependencies + [dependencies[0]]) }
        // One additional interval, still within the per-occurrence limit, exceeds the aggregate bound.
        var excess = requirements
        excess[1920] = try requirement(requirements[1920].binding, intervals: [.init(boardingIndex: 0, alightingIndex: 1)])
        rejects(.resourceLimit) { try custom(s, q, requirements: excess, inventory: inventory) }
    }
    @Test func maximumSnapshotAndIntervalPerOccurrenceExactAndPlusOne() throws {
        let b = try binding(trip(count: SearchInputClosureLimits.stopsPerTrip))
        let pairs = (1...SearchInputClosureLimits.intervalsPerOccurrence).map { TimetableVerifiedRideInterval(boardingIndex: 0, alightingIndex: $0) }
        let c = try make(inventory: inventory([]), required: [requirement(b, intervals: pairs)])
        #expect(c.holds == [.occurrenceNotLoaded(0)])
        rejects(.resourceLimit) { try make(inventory: inventory([]), required: [requirement(binding(trip(count: 73)), intervals: [])]) }
        rejects(.resourceLimit) { try make(inventory: inventory([]), required: [requirement(b, intervals: pairs + [.init(boardingIndex: 0, alightingIndex: 49)])]) }
    }
    @Test(arguments: ["dates", "trips"])
    func requirementDomainsHaveExactAndPlusOneBounds(_ dimension: String) throws {
        let good = try generatedRequirements(trips: dimension == "dates" ? 1 : 480, dates: dimension == "dates" ? 6 : 1)
        let c = try make(inventory: inventory([]), required: good)
        #expect(c.holds.count == good.count)
        let extra = try requirement(binding(trip(dimension == "dates" ? "invented-trip-0" : "invented-trip-extra", count: 12),
            day: dimension == "dates" ? "invented-extra-day" : "invented-day-0"), intervals: [])
        rejects(.resourceLimit) { try make(inventory: inventory([]), required: good + [extra]) }
    }
    @Test(arguments: ["stations", "lines", "trips"])
    func fullProfileSetBoundsExactAndPlusOne(_ dimension: String) throws {
        let count = dimension == "stations" ? SearchInputClosureLimits.profileStations : dimension == "lines" ? SearchInputClosureLimits.profileLines : SearchInputClosureLimits.uniqueTrips
        func supported(_ count: Int) throws -> InternalSearchScope {
            try scope(stations: dimension == "stations" ? (0..<count).map { "invented-stop-\($0)" } : nil,
                      lines: dimension == "lines" ? (0..<count).map { "invented-line-\($0)" } : nil,
                      trips: dimension == "trips" ? (0..<count).map { "invented-trip-\($0)" } : nil)
        }
        let c = try custom(supported(count), qualification())
        #expect(c.isTechnicallyQualified)
        rejects(.resourceLimit) { try make(scope: supported(count + 1), required: []) }
    }
    @Test(arguments: ["addressTrip", "day", "stop", "line", "service"])
    func retainedTextExactAndPlusOneBound(_ field: String) throws {
        func obligation(_ size: Int) throws -> SearchInputOccurrenceRequirement {
            let text = String(repeating: "x", count: size)
            let base = try trip(field == "addressTrip" ? text : "invented-trip",
                stops: field == "stop" ? ["invented-stop-0", text, "invented-stop-2", "invented-stop-3"] : nil,
                line: field == "line" ? text : "invented-line-a")
            let t: Trip
            if field == "service" {
                t = try required(Trip(id: base.id, stopSequence: base.stopSequence, lineSegments: base.lineSegments, coverage: base.coverage,
                    serviceTypeSegments: [required(TripServiceTypeSegment(serviceTypeID: required(ServiceTypeID(text)), startIndex: 0, endIndex: 1))]))
            } else { t = base }
            return try requirement(binding(t, day: field == "day" ? text : "invented-day"), intervals: [])
        }
        #expect(try make(inventory: inventory([]), required: [obligation(192)]).holds == [.occurrenceNotLoaded(0)])
        rejects(.resourceLimit) { try make(inventory: inventory([]), required: [obligation(193)]) }
    }
    @Test func actualUnicodeSpellingsAndRedundantRequestIDsAreBounded() throws {
        let composed = String(repeating: "é", count: 96), expanded = String(repeating: "e\u{301}", count: 96)
        #expect(composed == expanded && composed.utf8.count == 192 && expanded.utf8.count == 288)
        let good = try scope(stations: [composed, "invented-stop-3"], origin: composed)
        #expect(try custom(good, qualification()).isTechnicallyQualified)
        let bad = try scope(stations: [composed, "invented-stop-3"], origin: expanded)
        rejects(.resourceLimit) { try make(scope: bad, required: []) }
        rejects(.resourceLimit) { try make(inventory: inventory([]), required: [requirement(binding(trip(stops: ["invented-stop-0", expanded, "invented-stop-2", "invented-stop-3"])), intervals: [])]) }
    }
    @Test(arguments: ["station", "line", "trip"])
    func retainedProfileTextExactAndPlusOne(_ dimension: String) throws {
        func supported(_ size: Int) throws -> InternalSearchScope {
            let text = String(repeating: "x", count: size)
            return try scope(stations: dimension == "station" ? ["invented-stop-0", "invented-stop-3", text] : nil,
                             lines: dimension == "line" ? [text] : nil, trips: dimension == "trip" ? [text] : nil)
        }
        #expect(try custom(supported(192), qualification()).isTechnicallyQualified)
        rejects(.resourceLimit) { try make(scope: supported(193), required: []) }
    }
    @Test(arguments: ["source", "profile", "zone", "mapping", "review", "static"])
    func allInventoryQualificationComponentsPreventReuse(_ field: String) throws {
        let old = try qualification(), different = try ref("invented-changed-authority")
        let changed = try required(TimetableInventoryQualification(viewID: view,
            source: field == "source" ? different : old.source, profile: field == "profile" ? different : old.profile,
            zone: field == "zone" ? different : old.zone, mapping: field == "mapping" ? different : old.mapping,
            review: field == "review" ? different : old.review,
            railway: field == "static" ? railway("invented-new-static") : old.railway))
        rejects(.qualificationConflict) { try make(inventory: inventory([], qualification: changed), railway: changed.railway, required: []) }
    }
    @Test func inactiveSkipsActiveIntervalAuthorityAndProfileChecks() throws {
        let s = try scope(lines: ["invented-unrelated"], trips: ["invented-other"])
        let c = try custom(s, qualification(), requirements: [requirement(intervalAuthority: "invented-unused-interval-authority")],
                           inventory: inventory([slot(kind: 1)]))
        #expect(c.isTechnicallyQualified && c.occurrenceAccounting == [.inactive])
    }
    @Test func suppliedStaticInputCountExactAndPlusOne() throws {
        let revision = try railway(inputs: 32), q = try qualification(railway: revision)
        #expect(try custom(scope(), q).isTechnicallyQualified)
        rejects(.resourceLimit) { try make(railway: railway(inputs: 33)) }
    }
    @Test func logicalBudgetExactPlusOneAndOverflowFailClosed() throws {
        var budget = SearchInputClosurePayloadBudget()
        try budget.include(SearchInputClosureLimits.logicalPayloadBytes)
        #expect(budget.used == SearchInputClosureLimits.logicalPayloadBytes)
        do { try budget.include(1); Issue.record("Expected budget exhaustion") }
        catch { #expect(error == .resourceLimit && budget.used == SearchInputClosureLimits.logicalPayloadBytes) }
        var empty = SearchInputClosurePayloadBudget()
        for bytes in [-1, Int.max] {
            do { try empty.include(bytes); Issue.record("Expected bounded budget rejection") }
            catch { #expect(error == .resourceLimit && empty.used == 0) }
        }
    }
    @Test func oversizedTopLevelCountsPrecedeNestedDefectsAtomically() throws {
        let poison = try requirement(binding(trip(String(repeating: "x", count: 193))), intervals: [.init(boardingIndex: Int.min, alightingIndex: Int.max)])
        rejects(.resourceLimit) { try make(required: Array(repeating: poison, count: SearchInputClosureLimits.occurrences + 1)) }
        rejects(.resourceLimit) { try make(required: [poison], targets: Array(repeating: target(board: Int.max), count: SearchInputClosureLimits.connections + 1)) }
        rejects(.resourceLimit) { try make(required: [poison], dependencies: Array(repeating: ref(), count: SearchInputClosureLimits.dependencies + 1)) }
    }
}
