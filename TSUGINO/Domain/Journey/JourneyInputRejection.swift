// Why the engine refused an input (DEC-064 D, E).
//
// A returned value, not a thrown error. Every case carries enough detail for
// Phase 8 to explain the specific cause and, where applicable, what the rider
// can do next (DEC-064 E); wording and localization are Phase 8, and riders
// never see these case names. A case added later must come with its row in
// that mapping.

import Foundation

/// A typed refusal of a `JourneyEngineInput`.
nonisolated enum JourneyInputRejection: Sendable {
    /// The supplied instant is earlier than the state's `asOf`. The time is
    /// never clamped.
    case clockBehindJourney(stateAsOf: Date, requestedAt: Date)

    /// The Journey has ended; it accepts no further input of any kind.
    case journeyEnded

    /// No leg exists at this index.
    case legNotFound(legIndex: Int)

    /// The leg is travelled on foot, so no train can be chosen for it.
    case walkingLegHasNoTrain(legIndex: Int)

    /// A train is already chosen for this leg; it must be replaced instead.
    case trainAlreadySelected(legIndex: Int)

    /// No train is chosen for this leg yet, so there is nothing to replace.
    case noTrainToReplace(legIndex: Int)

    /// The train does not board and alight at the leg's stations. Both
    /// station pairs are kept so presentation can name the mismatched
    /// boarding and/or alighting station.
    case trainStationsDiffer(legIndex: Int, legStations: RailLegAnchors, trainStations: RailLegAnchors)

    /// The train is already selected for another leg of this Journey
    /// (DEC-062 E5).
    case trainAlreadyInJourney(legIndex: Int, otherLegIndex: Int)

    /// A rule depending on the current phase refuses the input. Which phases
    /// permit which inputs is decided by Phase 5.
    case notAllowedInCurrentPhase(currentPhase: JourneyPhase)
}
