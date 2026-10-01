#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

/// DEC-076 synthetic adapter subcases; no real-provider qualification is claimed.
struct RouteAdmissionTests {
    private typealias F = RoutingFixture
    private func rejected(_ input: SyntheticRouteAlternative, _ reason: RouteAlternativeRejectionReason,
                          view: SyntheticRouteDataView = F.view(), request: RouteSearchRequest = F.request()) async throws {
        do {
            _ = try await F.searcher([input], view: view).search(request)
            Issue.record("Expected omission")
        } catch RouteSearchFailure.noUsableAlternatives(let payload) {
            #expect(payload.omissions.count == 1)
            #expect(payload.omissions[0].alternativeIndex == 0)
            #expect(payload.omissions[0].reasons == [reason])
        }
    }

    @Test func directAndExactSameNameIdentities() async throws {
        // R01/R14/R36: labels cannot participate in a reference-only join.
        let result = try await F.searcher([F.alternative([F.ride("A", "X")])]).search(F.request("A", "X"))
        let batch = try F.batch(result)
        #expect(batch.candidates[0].destination == F.station("X"))
        if case .unresolved(let ride) = try F.rail(batch.candidates[0]).travel {
            #expect(ride.reason == .notSupplied)
        } else { Issue.record("Expected route only") }
        try await rejected(F.alternative([F.ride("A", "Y")]), .endpointMismatch, request: F.request("A", "X"))
    }

    @Test(arguments: [SyntheticRouteStatus.unknown, .retired, .conflicting, .unsupported])
    func invalidRequestedEndpointsFailBeforeIO(_ status: SyntheticRouteStatus) async throws {
        // R13a/R15, both roles. The fake client must never be reached.
        for origin in [true, false] {
            let counter = RoutingCallCounter()
            let id = F.station(origin ? "A" : "D")
            let view = F.view(stationStatus: [id: status])
            let searcher = SyntheticRouteSearcher(loadView: { view }, fetch: { _, viewID in
                await counter.increment()
                return SyntheticRouteEnvelope(viewID: viewID, alternatives: [], explicitlyNoResults: true)
            })
            do { _ = try await searcher.search(F.request()); Issue.record("Expected invalid endpoint") }
            catch RouteSearchFailure.invalidEndpoint(let role, let reason) {
                #expect(role == (origin ? .origin : .destination))
                switch status {
                case .unknown: #expect(reason == .unknown)
                case .retired: #expect(reason == .retired)
                case .conflicting: #expect(reason == .conflicting)
                case .unsupported: #expect(reason == .unsupported)
                case .active: Issue.record("Invalid fixture")
                }
            }
            #expect(await counter.count == 0)
        }
    }

    @Test func missingOutboundMappingFailsBeforeIO() async throws {
        let counter = RoutingCallCounter()
        let view = F.view(stationMappings: ["D": .unknown])
        let searcher = SyntheticRouteSearcher(loadView: { view }, fetch: { _, id in
            await counter.increment()
            return SyntheticRouteEnvelope(viewID: id, alternatives: [], explicitlyNoResults: true)
        })
        do { _ = try await searcher.search(F.request()); Issue.record("Expected invalid endpoint") }
        catch RouteSearchFailure.invalidEndpoint(let role, let reason) {
            #expect(role == .destination && reason == .unknown)
        }
        #expect(await counter.count == 0)
    }

    @Test func unsupportedInteriorNeverCropsRoute() async throws {
        // R13b/R19: endpoints valid; only a required ridden line is unsupported.
        try await rejected(F.alternative(), .unsupportedPortion,
                           view: F.view(lineStatus: [F.line("L1"): .unsupported]))
    }

    @Test func requiredMappingsRejectUnknownRetiredAndConflictingReferences() async throws {
        // R16–18; required interior station and line references.
        let fragmented = F.alternative([F.ride(fragments: [
            SyntheticRailFragment(from: "A", to: "B", line: "L1"),
            SyntheticRailFragment(from: "B", to: "D", line: "L2")])])
        for (state, reason) in [(SyntheticRouteResolution<LineID>.unknown, RouteAlternativeRejectionReason.unknownMapping),
                               (.retired, .retiredMapping), (.conflicting, .conflictingMapping), (.unsupported, .unsupportedPortion)] {
            try await rejected(fragmented, reason, view: F.view(lineMappings: ["L2": state]))
        }
        try await rejected(fragmented, .unknownMapping, view: F.view(stationMappings: ["B": .unknown]))
        try await rejected(fragmented, .retiredMapping, view: F.view(stationMappings: ["B": .retired]))
        try await rejected(fragmented, .conflictingMapping, view: F.view(stationMappings: ["B": .conflicting]))
    }

    @Test func throughServiceMergesOnlyExplicitContinuousFragments() async throws {
        // R07/R08/R29: one matched ride across lines, original indices/snapshot.
        let trip = F.trip(stops: ["A", "B", "D"], split: true)
        let fragments = [SyntheticRailFragment(from: "A", to: "B", line: "L1"),
                         SyntheticRailFragment(from: "B", to: "D", line: "L2")]
        let input = F.alternative([F.ride(fragments: fragments, reference: "run", board: "visit-0", alight: "visit-2")])
        let batch = try F.batch(await F.searcher([input], view: F.view(trip: trip)).search(F.request()))
        #expect(batch.candidates[0].transferCount == 0)
        #expect(batch.candidates[0].legs.count == 1)
        if case .matched(let train) = try F.rail(batch.candidates[0]).travel {
            #expect(train.trip.stopSequence == trip.stopSequence)
            #expect(train.trip.lineSegments == trip.lineSegments)
            #expect(train.trip.coverage == trip.coverage)
            #expect(train.trip.serviceTypeSegments == trip.serviceTypeSegments)
            #expect(train.boardingIndex == 0 && train.alightingIndex == 2)
        } else { Issue.record("Expected match") }
        try await rejected(F.alternative([F.ride(fragments: fragments, continuous: false)]), .insufficientContinuity)
        let clipped = F.alternative([F.ride("B", "D", line: "L2", reference: "run", board: "visit-1", alight: "visit-2")])
        let clipping = try F.batch(await F.searcher([clipped], view: F.view(trip: trip)).search(F.request("B", "D")))
        #expect(try F.rail(clipping.candidates[0]).travel.lineSequence == [F.line("L2")])
    }

    @Test func genuineTransfersNeedChangeAssertionAndDatasetEvidence() async throws {
        // R03–R06/R08: both same-station and distinct-station transfer paths.
        let same = F.alternative([F.ride("A", "B", arrival: 100), F.ride("B", "D", line: "L2", departure: 100)], changes: [true])
        let walk = F.alternative([F.ride("A", "X", arrival: 100), .walk(from: "X", to: "Y"),
                                  F.ride("Y", "D", line: "L2", departure: 100)], changes: [true])
        for input in [same, walk] {
            let batch = try F.batch(await F.searcher([input]).search(F.request()))
            #expect(batch.candidates[0].transferCount == 1)
            try await rejected(input, .unverifiedTransfer, view: F.view(connections: false))
        }
        let noChange = F.alternative(same.legs, changes: [false])
        try await rejected(noChange, .insufficientContinuity)
        let reverse = F.alternative([F.ride("A", "Y", arrival: 100), .walk(from: "Y", to: "X"),
                                    F.ride("X", "D", line: "L2", departure: 100)], changes: [true])
        try await rejected(reverse, .unverifiedTransfer) // direction is not inferred
        let three = F.alternative([F.ride("A", "B", arrival: 100), F.ride("B", "C", departure: 100, arrival: 200),
                                  F.ride("C", "D", departure: 200)], changes: [true, true])
        #expect(try F.batch(await F.searcher([three]).search(F.request())).candidates[0].transferCount == 2)
    }

    @Test func repeatedOccurrenceAndPartialLimitedStopSnapshots() async throws {
        // R02/R09/R11/R12: exact occurrence joins; no topology insertion/cropping.
        for (trip, start, board, end) in [(F.trip(partial: true), "B", "visit-3", "visit-4"),
                                         (F.trip(stops: ["A", "D"]), "A", "visit-0", "visit-1")] {
            let input = F.alternative([F.ride(start, "D", reference: "run", board: board, alight: end)])
            let batch = try F.batch(await F.searcher([input], view: F.view(trip: trip)).search(F.request(start, "D")))
            guard case .matched(let train) = try F.rail(batch.candidates[0]).travel else { Issue.record("Missing match"); continue }
            #expect(train.trip.id == trip.id)
            #expect(train.trip.stopSequence == trip.stopSequence)
            #expect(train.trip.lineSegments == trip.lineSegments)
            #expect(train.trip.coverage == trip.coverage)
            #expect(train.trip.serviceTypeSegments == trip.serviceTypeSegments)
            #expect(train.boardingIndex == (start == "B" ? 3 : 0))
        }
    }

    @Test func ambiguousCorrespondenceRequiresIndependentCompleteRide() async throws {
        // R10/R26: absent occurrence and unknown reference are not guessed joins.
        for reference in ["run", "unknown-run"] {
            let input = F.alternative([F.ride("B", "D", reference: reference, board: "ambiguous-B", alight: "visit-4")])
            let batch = try F.batch(await F.searcher([input]).search(F.request("B", "D")))
            guard case .unresolved(let ride) = try F.rail(batch.candidates[0]).travel else { Issue.record("Invented match"); continue }
            #expect(ride.reason == .noVerifiedMatch)
            try await rejected(F.alternative([F.ride("B", "D", independent: false, reference: reference)]),
                               .insufficientContinuity, request: F.request("B", "D"))
        }
        let unreviewed = F.alternative([F.ride(reference: "run", board: "visit-0", alight: "visit-4")])
        let result = try F.batch(await F.searcher([unreviewed], view: F.view(reviewed: false)).search(F.request()))
        if case .unresolved = try F.rail(result.candidates[0]).travel {} else { Issue.record("Unreviewed attachment") }
    }

    @Test func insufficientSnapshotIsNotUnsupportedOrUnknownMapping() async throws {
        // R13c, complete B->E independently evidenced, Trip only B/C/D.
        let view = F.view(trip: F.trip(stops: ["B", "C", "D"], partial: true))
        let input = F.alternative([F.ride("B", "E", reference: "run", board: "visit-0", alight: "missing-E")])
        let batch = try F.batch(await F.searcher([input], view: view).search(F.request("B", "E")))
        if case .unresolved(let value) = try F.rail(batch.candidates[0]).travel { #expect(value.reason == .noVerifiedMatch) }
        else { Issue.record("Invented coverage") }
        try await rejected(F.alternative([F.ride("B", "E", independent: false, reference: "run")]),
                           .insufficientContinuity, view: view, request: F.request("B", "E"))
        try await rejected(F.alternative([F.ride("B", "E", reference: "run", board: "visit-0", alight: "visit-2")]),
                           .inconsistentTrainEvidence, view: view, request: F.request("B", "E"))
        try await rejected(F.alternative([F.ride("B", "E", line: "missing", reference: "run")]),
                           .unknownMapping, view: view, request: F.request("B", "E"))
    }

    @Test func positiveTrainContradictionsAreNeverDowngraded() async throws {
        // R17/18/27/28: known one-sided contradictions also cannot hide as unresolved.
        let input = F.alternative([F.ride(reference: "run", board: "visit-0", alight: "visit-4")])
        try await rejected(input, .retiredMapping, view: F.view(trainMappings: ["run": .retired]))
        try await rejected(input, .conflictingMapping, view: F.view(trainMappings: ["run": .conflicting]))
        try await rejected(input, .invalidStructure, view: F.view(occurrences: ["visit-0": Int.max, "visit-4": 4]))
        try await rejected(F.alternative([F.ride(reference: "run", board: "visit-1", alight: "absent")]), .inconsistentTrainEvidence)
        try await rejected(F.alternative([F.ride(line: "L2", reference: "run", board: "visit-0", alight: "visit-4")]), .inconsistentTrainEvidence)
        try await rejected(input, .inconsistentTrainEvidence, view: F.view(validMembership: false))
        try await rejected(input, .inconsistentTrainEvidence, view: F.view(validServiceTypes: false))
        let duplicate = F.alternative([F.ride("A", "B", reference: "run", board: "visit-0", alight: "visit-1", arrival: 100),
                                       F.ride("B", "D", reference: "run", board: "visit-3", alight: "visit-4", departure: 100)], changes: [true])
        try await rejected(duplicate, .invalidStructure)
        let ambiguousDuplicate = F.alternative([
            F.ride("A", "B", reference: "run", board: "visit-0", alight: "visit-1", arrival: 100),
            F.ride("B", "D", reference: "run", board: "ambiguous-B", alight: "visit-4", departure: 100)
        ], changes: [true])
        try await rejected(ambiguousDuplicate, .invalidStructure)
    }

    @Test func incompleteCorrespondenceCannotHideAnImpossibleRunLine() async throws {
        // R27: missing either occurrence does not erase complete-run evidence.
        let view = F.view(trip: F.trip(stops: ["A", "B", "D"]))
        for (board, alight) in [("visit-0", "absent"), ("absent", "visit-2")] {
            try await rejected(F.alternative([F.ride(line: "L2", reference: "run",
                board: board, alight: alight)]), .inconsistentTrainEvidence, view: view)
        }
    }

    @Test func incompleteCorrespondencePreservesUncontradictedFallback() async throws {
        // R13c: a partial L1 snapshot cannot exclude L2 in an unseen extension.
        let partial = F.view(trip: F.trip(stops: ["B", "C", "D"], partial: true))
        let extensionRide = F.alternative([F.ride("B", "E", fragments: [
            SyntheticRailFragment(from: "B", to: "D", line: "L1"),
            SyntheticRailFragment(from: "D", to: "E", line: "L2")],
            reference: "run", board: "visit-0", alight: "missing-E")])
        // R10: a subinterval need not traverse every line in the complete run;
        // repeated B remains ambiguous even when the L2 claim is possible.
        let repeated = F.view(trip: F.trip(split: true))
        let ambiguous = F.alternative([F.ride("B", "D", line: "L2", reference: "run",
                                              board: "ambiguous-B", alight: "visit-4")])
        for (input, view, request) in [(extensionRide, partial, F.request("B", "E")),
                                       (ambiguous, repeated, F.request("B", "D"))] {
            let batch = try F.batch(await F.searcher([input], view: view).search(request))
            guard case .unresolved(let ride) = try F.rail(batch.candidates[0]).travel
            else { Issue.record("Missing occurrence must not be guessed"); continue }
            #expect(ride.reason == .noVerifiedMatch)
            #expect(batch.candidates[0].destination == request.destination)
        }
    }

    @Test func fallbackRejectsImpossibleEndpointsMovementAndOrder() async throws {
        let complete = F.view(trip: F.trip(stops: ["A", "B", "D"], split: true))
        let cases: [(SyntheticRouteLeg, RouteSearchRequest)] = [
            (F.ride("A", "E", reference: "run", board: "visit-0", alight: "absent"), F.request("A", "E")),
            (F.ride("E", "D", reference: "run", board: "absent", alight: "visit-2"), F.request("E", "D")),
            (F.ride("B", "D", reference: "run", board: "visit-1", alight: "absent"), F.request("B", "D")),
            (F.ride("A", "B", line: "L2", reference: "run", board: "absent", alight: "visit-1"), F.request("A", "B")),
            (F.ride("D", "A", reference: "run", board: "visit-2", alight: "absent"), F.request("D", "A")),
            (F.ride(fragments: [SyntheticRailFragment(from: "A", to: "B", line: "L2"),
                                SyntheticRailFragment(from: "B", to: "D", line: "L1")],
                    reference: "run", board: "visit-0", alight: "absent"), F.request())
        ]
        for (ride, request) in cases {
            try await rejected(F.alternative([ride]), .inconsistentTrainEvidence, view: complete, request: request)
        }
    }

    @Test func fallbackRespectsEachCoverageBoundaryIndependently() async throws {
        let original = F.trip(stops: ["B", "C", "D"])
        for leadingOpen in [false, true] {
            for trailingOpen in [false, true] {
                let trip = try #require(Trip(id: original.id, stopSequence: original.stopSequence,
                    lineSegments: original.lineSegments,
                    coverage: TripCoverage(includesServiceOrigin: !leadingOpen, includesServiceDestination: !trailingOpen),
                    serviceTypeSegments: original.serviceTypeSegments))
                let view = F.view(trip: trip)
                let leading = F.alternative([F.ride("A", "B", line: "L2", reference: "run",
                                                    board: "absent", alight: "visit-0")])
                let trailing = F.alternative([F.ride("D", "E", line: "L2", reference: "run",
                                                     board: "visit-2", alight: "absent")])
                for (input, request, permitted) in [(leading, F.request("A", "B"), leadingOpen),
                                                    (trailing, F.request("D", "E"), trailingOpen)] {
                    if permitted {
                        let batch = try F.batch(await F.searcher([input], view: view).search(request))
                        if case .unresolved = try F.rail(batch.candidates[0]).travel {} else { Issue.record("Guessed occurrence") }
                    } else {
                        try await rejected(input, .inconsistentTrainEvidence, view: view, request: request)
                    }
                }
            }
        }
    }

    @Test func fallbackPreservesOrderedNonAdjacentRepeatedLines() async throws {
        let trip = try #require(Trip(id: TripID("T1")!, stopSequence: ["A", "B", "C", "D"].map(F.station),
            lineSegments: [TripLineSegment(lineID: F.line("L1"), startIndex: 0, endIndex: 1)!,
                           TripLineSegment(lineID: F.line("L2"), startIndex: 1, endIndex: 2)!,
                           TripLineSegment(lineID: F.line("L1"), startIndex: 2, endIndex: 3)!],
            coverage: TripCoverage(includesServiceOrigin: true, includesServiceDestination: true), serviceTypeSegments: []))
        let good = F.alternative([F.ride(fragments: [
            SyntheticRailFragment(from: "A", to: "B", line: "L1"),
            SyntheticRailFragment(from: "B", to: "C", line: "L2"),
            SyntheticRailFragment(from: "C", to: "D", line: "L1")], reference: "run", board: "absent", alight: "absent")])
        let batch = try F.batch(await F.searcher([good], view: F.view(trip: trip)).search(F.request()))
        guard case .unresolved(let ride) = try F.rail(batch.candidates[0]).travel else { Issue.record("Guessed correspondence"); return }
        #expect(ride.lineSequence == [F.line("L1"), F.line("L2"), F.line("L1")])
        try await rejected(F.alternative([F.ride(reference: "run", board: "absent", alight: "absent")]),
                           .inconsistentTrainEvidence, view: F.view(trip: trip))
    }

    @Test func mixedAlternativesKeepSourceOrderAndOmissionPositions() async throws {
        // R20/23: malformed but delimited alternative cannot poison good options.
        let one = F.alternative([F.ride(departure: 10, arrival: 20)])
        let bad = F.alternative([F.ride(line: "absent")])
        let two = F.alternative([F.ride(departure: 30, arrival: 40)])
        let batch = try F.batch(await F.searcher([one, bad, two, F.alternative(wellFormed: false)]).search(F.request()))
        #expect(batch.candidates.count == 2)
        #expect(batch.omissions.map(\.alternativeIndex) == [1, 3])
        #expect(batch.omissions.map(\.reasons) == [[.unknownMapping], [.malformedAlternative]])
        #expect(try F.rail(batch.candidates[0]).scheduledContext?.departure == F.date(10))
        #expect(try F.rail(batch.candidates[1]).scheduledContext?.departure == F.date(30))
    }

    @Test func allOmittedAndGenuineEmptyRemainDistinct() async throws {
        // R21/22: exact contiguous accounting; no false empty search.
        do {
            _ = try await F.searcher([F.alternative(wellFormed: false), F.alternative([F.ride(line: "missing")])]).search(F.request())
            Issue.record("Expected all-omitted failure")
        } catch RouteSearchFailure.noUsableAlternatives(let payload) {
            #expect(payload.omissions.map(\.alternativeIndex) == [0, 1])
            #expect(payload.omissions.map(\.reasons) == [[.malformedAlternative], [.unknownMapping]])
        }
        if case .noResults = try await F.searcher([]).search(F.request()) {} else { Issue.record("Expected empty") }
    }

    @Test func malformedSharedEnvelopesAreNeverSalvaged() async throws {
        for (alternatives, emptyAssertion) in [(nil as [SyntheticRouteAlternative]?, false), ([], false), ([F.alternative()], true)] {
            let searcher = SyntheticRouteSearcher(loadView: { F.view() }, fetch: { _, id in
                SyntheticRouteEnvelope(viewID: id, alternatives: alternatives, explicitlyNoResults: emptyAssertion)
            })
            do { _ = try await searcher.search(F.request()); Issue.record("Expected malformed response") }
            catch RouteSearchFailure.malformedResponse {}
        }
    }

    @Test func timeContradictionsSurviveOmissionAndMissingContexts() async throws {
        // R31b,c/R32a,b,c; generic intent=true in every contradictory example.
        let examples = [
            F.alternative([F.ride(departure: -60, arrival: nil)]),
            F.alternative([F.ride("A", "B", departure: nil, arrival: 1200), F.ride("B", "D", departure: 600, arrival: nil)], changes: [true]),
            F.alternative([F.ride("A", "B", departure: nil, arrival: nil), F.ride("B", "D", departure: -1800, arrival: -900)], changes: [true]),
            F.alternative([F.ride("A", "B", departure: nil, arrival: 1200), F.ride("B", "C", departure: nil, arrival: nil),
                           F.ride("C", "D", departure: 600, arrival: nil)], changes: [true, true]),
            F.alternative([F.ride("A", "B", departure: 60, arrival: 1200), F.ride("B", "C", departure: nil, arrival: nil),
                           F.ride("C", "D", departure: 600, arrival: 1800)], changes: [true, true]),
            F.alternative([F.ride(departure: 100, arrival: 99)])
        ]
        for input in examples { try await rejected(input, .invalidScheduledContext) }
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func everyKnownTimeMustBeFinite(_ value: Double) async throws {
        try await rejected(F.alternative([F.ride(departure: value, arrival: nil)]), .invalidScheduledContext)
        try await rejected(F.alternative([F.ride(departure: nil, arrival: value)]), .invalidScheduledContext)
    }

    @Test func missingTimeNeedsIntentAssertionAndNeverInventsCounterpart() async throws {
        // R31a: nil includes upstream-uninterpretable inputs; parsing remains deferred.
        for (departure, arrival) in [(nil as Double?, nil as Double?), (60, nil), (nil, 600)] {
            let legs = [F.ride(departure: departure, arrival: arrival)]
            let batch = try F.batch(await F.searcher([F.alternative(legs)]).search(F.request()))
            #expect(try F.rail(batch.candidates[0]).scheduledContext == nil)
            try await rejected(F.alternative(legs, intent: false), .invalidScheduledContext)
        }
    }

    @Test func equalityMidnightAndUnusedTripEndpoints() async throws {
        // R30/R32d/e/f. Absolute instants only; no parsing or rollover rule.
        let equal = F.alternative([F.ride("A", "B", departure: 0, arrival: 0), F.ride("B", "D", departure: 0, arrival: 600)], changes: [true])
        #expect(try F.batch(await F.searcher([equal]).search(F.request())).candidates.count == 1)
        let midnight = F.alternative([F.ride(departure: 86100, arrival: 87000, unused: [F.date(-3600), F.date(.nan)])], intent: false)
        let batch = try F.batch(await F.searcher([midnight]).search(F.request(bound: 85800)))
        #expect(try F.rail(batch.candidates[0]).scheduledContext?.departure == F.date(86100))
        #expect(try F.rail(batch.candidates[0]).scheduledContext?.arrival == F.date(87000))
        // Equality did not replace transfer evidence.
        try await rejected(equal, .unverifiedTransfer, view: F.view(connections: false))
    }
}

#endif
