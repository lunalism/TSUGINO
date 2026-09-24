// What the engine is asked to process (DEC-064 B, D).
//
// `Observation` is the realtime evidence type. Phase 4 supplies it and the
// Phase 5 engine binds it; this file defines no realtime payload. The pure
// structural checks here are shared: callers may use them to pre-check a
// rider's action, and a conforming engine must apply them first. Rules that
// depend on the current phase belong to Phase 5.

import Foundation

/// One input to a `JourneyEngine`.
nonisolated enum JourneyEngineInput<Observation: Sendable>: Sendable {
    /// Realtime evidence, of the type a later phase supplies.
    case observed(Observation)

    /// No new evidence; re-evaluate at the supplied instant.
    case timePassed

    /// Choose a train for an unselected rail leg.
    case selectTrip(legIndex: Int, SelectedRailTrip)

    /// Change the train of a selected rail leg.
    case replaceTrip(legIndex: Int, SelectedRailTrip)

    /// The rider ends the Journey.
    case end(UserEndReason)

    /// The first structural reason this input cannot be applied to `current`
    /// at `now`, or `nil` if the structural checks pass (DEC-064 D). Checked
    /// in this order:
    ///
    /// 1. `now` earlier than the state's `asOf` — every input;
    /// 2. an ended Journey — every input;
    /// 3. a leg index outside the Journey — train selection and replacement;
    /// 4. a walking leg;
    /// 5. selecting for a selected leg, or replacing on an unselected one;
    /// 6. a train whose stations differ from the leg's;
    /// 7. a `TripID` already selected on another leg — a replacement's own
    ///    leg is excluded, so re-selecting its current Trip passes.
    ///
    /// Passing these checks does not make an input applicable: Phase 5 may
    /// still refuse it for the current phase.
    func structuralRejection(against current: ActiveJourney, at now: Date) -> JourneyInputRejection? {
        let state = current.state

        if now < state.asOf {
            return .clockBehindJourney(stateAsOf: state.asOf, requestedAt: now)
        }
        if case .ended = state.phase {
            return .journeyEnded
        }

        switch self {
        case .observed, .timePassed, .end:
            return nil
        case .selectTrip(let legIndex, let selection):
            return Self.trainRejection(legIndex: legIndex, selection: selection, isReplacement: false, in: current.journey.legs)
        case .replaceTrip(let legIndex, let selection):
            return Self.trainRejection(legIndex: legIndex, selection: selection, isReplacement: true, in: current.journey.legs)
        }
    }

    /// Checks 3–7 for choosing or changing the train of one leg.
    private static func trainRejection(
        legIndex: Int,
        selection: SelectedRailTrip,
        isReplacement: Bool,
        in legs: [JourneyLeg]
    ) -> JourneyInputRejection? {
        guard legIndex >= 0, legIndex < legs.count else { return .legNotFound(legIndex: legIndex) }
        guard case .rail(let rail) = legs[legIndex] else { return .walkingLegHasNoTrain(legIndex: legIndex) }

        let legStations: RailLegAnchors
        switch (rail, isReplacement) {
        case (.selected, false):
            return .trainAlreadySelected(legIndex: legIndex)
        case (.unselected, true):
            return .noTrainToReplace(legIndex: legIndex)
        case (.unselected(let anchors), false):
            legStations = anchors
        case (.selected(let current), true):
            legStations = current.anchors
        }

        guard legStations.admits(selection) else {
            return .trainStationsDiffer(legIndex: legIndex, legStations: legStations, trainStations: selection.anchors)
        }

        for (otherLegIndex, leg) in legs.enumerated() where otherLegIndex != legIndex {
            if case .rail(.selected(let other)) = leg, other.trip.id == selection.trip.id {
                return .trainAlreadyInJourney(legIndex: legIndex, otherLegIndex: otherLegIndex)
            }
        }

        return nil
    }
}
