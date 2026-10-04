#if DEBUG
import Foundation
import Testing
@testable import TSUGINO

@MainActor
struct RouteSearchPresentationTests {
    private typealias F = InternalFixture
    private enum Failure: Error { case unexpected }

    /// Obtain a genuine opaque attempt ID without relaxing coordinator construction.
    private func attempt() async throws -> RouteSearchAttempt {
        let port = PresentationProbePort()
        let owner = RouteSearchCoordinator(searcher: port, clock: FixedAppClock(now: F.date(100)))
        owner.submit(.init(origin: F.station("A"), destination: F.station("D"), departure: .at(F.date(100))))
        let done = owner.completionCheckpointForTesting()
        guard case .searching(let value) = owner.state else { throw Failure.unexpected }
        owner.dispose(); await done()
        #expect(await port.calls == 0)
        return value
    }

    @Test(arguments: Array(0..<7)) func stateAndActions(_ mode: Int) async throws {
        let a = try await attempt()
        let inputs: [RouteSearchPresentationSource] = [.current(.idle), .current(.searching(a)),
            .current(.completed(a, .noResults)), .current(.cancelled(a)),
            .current(.contractViolation(a)), .current(.disposed), .notConfigured]
        let expected: [RouteSearchCopy?] = [.idle, .searching, .noResults, .cancelled, .contractViolation, nil, .notConfigured]
        let actions: [[RouteSearchPresentationAction]] = [[.search,.edit],[.cancel(a.id),.edit,.search],
            [.edit,.search],[.edit,.search],[.edit,.search],[],[]]
        var feedback = RouteSearchDraftFeedback()
        feedback.recordSubmission(.invalidRequest, for: feedback.draftID)
        let mapped = RouteSearchPresentation.map(inputs[mode], feedback: feedback)
        #expect(mapped.status == expected[mode] && mapped.actions == actions[mode])
        #expect(mapped.alternatives.isEmpty)
        #expect(mapped.feedback == (mode >= 5 ? nil : .invalidRequest))
    }

    @Test(arguments: Array(0..<9)) func canonicalFailuresRemainDistinct(_ mode: Int) async throws {
        let a = try await attempt()
        let rejection = try #require(RouteAlternativeOmission(alternativeIndex: 0, reasons: [.unknownMapping]))
        let failures: [RouteSearchFailure] = [.invalidEndpoint(.destination,.retired), .unsupportedRequest,
            .dataUnavailable, .providerUnavailable, .rateLimited, .configurationUnavailable, .malformedResponse,
            .noUsableAlternatives(try #require(RouteSearchRejections(omissions: [rejection]))), .searchIncomplete]
        let statuses: [RouteSearchCopy] = [.invalidEndpoint,.unsupportedRequest,.dataUnavailable,.providerUnavailable,
            .rateLimited,.configurationUnavailable,.malformedResponse,.noUsableAlternatives,.searchIncomplete]
        let mapped = RouteSearchPresentation.map(.current(.failed(a, failures[mode])))
        #expect(mapped.status == statuses[mode] && mapped.status != .noResults && mapped.status != .notConfigured)
        #expect(mapped.actions == [.retry(a.id),.edit,.search] && mapped.alternatives.isEmpty)
        guard case .current(.failed(let retained, let failure)) = mapped.source else { throw Failure.unexpected }
        #expect(retained.id == a.id && retained.request.departNotBefore == a.request.departNotBefore)
        switch (mode,failure) {
        case (0,.invalidEndpoint(.destination,.retired)), (1,.unsupportedRequest), (2,.dataUnavailable),
             (3,.providerUnavailable), (4,.rateLimited), (5,.configurationUnavailable), (6,.malformedResponse),
             (8,.searchIncomplete): break
        case (7,.noUsableAlternatives(let payload)):
            #expect(payload.omissions.count == 1 && payload.omissions[0].alternativeIndex == 0)
            #expect(payload.omissions[0].reasons == [.unknownMapping])
        default: throw Failure.unexpected
        }
    }

    @Test func scopedEmptyPreservesScopeWithoutInventingGlobalAbsence() async throws {
        let a = try await attempt()
        let scope = try #require(InternalSearchScope(profile: F.configuration().profile, request: a.request, viewID: F.viewID))
        let success = try #require(InternalSearchSuccess(scope: scope, outcome: .noResults))
        let mapped = RouteSearchPresentation.map(.current(.completed(a, .internalSuccess(success))))
        #expect(mapped.status == .noResults && mapped.actions == [.edit,.search])
        guard case .current(.completed(_, .internalSuccess(let kept))) = mapped.source,
              case .noResults = kept.outcome else { throw Failure.unexpected }
        #expect(kept.scope.viewID == scope.viewID && kept.scope.profile.identity == scope.profile.identity)
        #expect(kept.scope.lowerBound == scope.lowerBound && kept.scope.upperBound == scope.upperBound)
    }

    @Test(arguments: [false,true]) func allAlternativesKeepOrderAndEvidence(_ scoped: Bool) async throws {
        let a = try await attempt(), inventory = F.inventory()
        let slot = try #require(inventory.slots?.first)
        guard case .active(let facts, _) = slot.activation else { throw Failure.unexpected }
        func candidate(_ boarding: Int, _ alighting: Int) throws -> RouteCandidate {
            let train = try #require(TrainCandidate(trip: inventory.trip, boardingIndex: boarding, alightingIndex: alighting))
            let context = try #require(TimetableRideContext(train: train, facts: facts))
            let rail = try #require(RouteRailProposal(travel: .matched(train), scheduledContext: .timetable(context)))
            return try #require(RouteCandidate(legs: [.rail(rail)]))
        }
        // Two distinct candidates in deliberate order; duplicate is also retained, never deduplicated by presentation.
        let first = try candidate(0,2), second = try candidate(0,1)
        let candidates = scoped ? [first,first] : [first,second,first]
        let omission = try #require(RouteAlternativeOmission(alternativeIndex: candidates.count, reasons: [.unknownMapping]))
        let batch = try #require(RouteSearchBatch(candidates: candidates, omissions: [omission]))
        let scope = try #require(InternalSearchScope(profile: F.configuration().profile, request: a.request, viewID: F.viewID))
        let result: RouteSearchResult = scoped
            ? .internalSuccess(try #require(InternalSearchSuccess(scope: scope, outcome: .alternatives(batch))))
            : .alternatives(batch)
        let mapped = RouteSearchPresentation.map(.current(.completed(a,result)))
        #expect(mapped.status == .alternatives && mapped.alternatives.count == candidates.count)
        for (index,value) in mapped.alternatives.enumerated() {
            guard case .rail(let r) = value.legs[0], case .matched(let train) = r.travel,
                  case .timetable(let context) = r.scheduledContext else { throw Failure.unexpected }
            let end = !scoped && index == 1 ? 1 : 2
            #expect(train.boardingIndex == 0 && train.alightingIndex == end)
            #expect(train.trip.id == inventory.trip.id && train.trip.stopSequence == inventory.trip.stopSequence)
            #expect(context.binding.matches(facts.binding) && context.matches(train))
            guard case .rail(let original) = candidates[index].legs[0],
                  case .timetable(let originalContext) = original.scheduledContext else { throw Failure.unexpected }
            #expect(context.departure == originalContext.departure && context.arrival == originalContext.arrival)
        }
        guard case .current(.completed(let keptAttempt,let kept)) = mapped.source else { throw Failure.unexpected }
        #expect(keptAttempt.id == a.id)
        let keptBatch: RouteSearchBatch
        switch kept {
        case .alternatives(let b): keptBatch = b
        case .internalSuccess(let s):
            #expect(s.scope.viewID == scope.viewID)
            guard case .alternatives(let b) = s.outcome else { throw Failure.unexpected }; keptBatch = b
        default: throw Failure.unexpected
        }
        #expect(keptBatch.omissions.count == 1 && keptBatch.omissions[0].alternativeIndex == candidates.count)
        #expect(keptBatch.omissions[0].reasons == [.unknownMapping])
    }

    @Test func rejectedDraftFeedbackIsSupplementaryAndClearsAtApprovedBoundaries() async throws {
        let a = try await attempt()
        var feedback = RouteSearchDraftFeedback()
        let original = feedback.draftID
        feedback.recordSubmission(.invalidRequest, for: original)
        let searching = RouteSearchPresentation.map(.current(.searching(a)), feedback: feedback)
        #expect(searching.status == .searching && searching.feedback == .invalidRequest)
        #expect(searching.actions == [.cancel(a.id),.edit,.search])
        feedback.draftEdited()
        #expect(feedback.draftID != original && !feedback.hasRejection)
        feedback.recordSubmission(.invalidRequest, for: original) // obsolete draft cannot reattach a notice
        #expect(!feedback.hasRejection)
        feedback.recordSubmission(.invalidRequest, for: feedback.draftID)
        feedback.recordSubmission(.accepted(a.id), for: feedback.draftID)
        #expect(!feedback.hasRejection)
        let completed = RouteSearchPresentation.map(.current(.completed(a,.noResults)), feedback: feedback)
        #expect(completed.status == .noResults && completed.feedback == nil)
    }

    @Test func staleActionsOnlyRefreshCurrentProjection() async throws {
        let old = try await attempt(), current = try await attempt()
        let oldView = RouteSearchPresentation.map(.current(.failed(old,.searchIncomplete)))
        #expect(oldView.actions.first == .retry(old.id))
        var feedback = RouteSearchDraftFeedback()
        feedback.recordSubmission(.noMatchingFailure, for: feedback.draftID)
        let refreshed = RouteSearchPresentation.map(.current(.searching(current)), feedback: feedback)
        #expect(refreshed.status == .searching && refreshed.feedback == nil)
        #expect(refreshed.actions == [.cancel(current.id),.edit,.search])
        // A false stale cancel needs no feedback event; remapping uses only the current state.
        let completed = RouteSearchPresentation.map(.current(.completed(current,.noResults)), feedback: feedback)
        #expect(completed.status == .noResults && completed.feedback == nil)
        #expect(!completed.actions.contains(.retry(old.id)) && !completed.actions.contains(.cancel(old.id)))
    }
}
private actor PresentationProbePort: RouteSearching {
    private(set) var calls = 0
    func search(_ request: RouteSearchRequest) async throws -> RouteSearchResult {
        calls += 1
        throw RouteSearchFailure.configurationUnavailable
    }
}
#endif
