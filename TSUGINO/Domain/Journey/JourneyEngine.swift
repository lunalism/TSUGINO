// The Phase 1 boundary of the journey engine (DEC-064 B, DEC-050).
//
// Phase 1 defines only the shape. The Phase 5 engine binds `Observation` to
// the realtime type Phase 4 supplies and implements every transition; this
// file contains no behaviour. A scheduled-only test double may bind
// `Observation = Never`, which makes `observed` impossible to send it.

import Foundation

/// A pure, synchronous state-transition engine for active Journeys.
///
/// A conforming engine never reads a clock — `now` is an input — performs no
/// I/O, and never throws. It must apply
/// `JourneyEngineInput.structuralRejection(against:at:)` first and return
/// `.rejected` with its result; it returns `.applied` only with a result
/// built through `JourneyTransitionResult`'s constructor whose next state's
/// `asOf` equals `now`.
nonisolated protocol JourneyEngine<Observation>: Sendable {
    associatedtype Observation: Sendable

    func transition(
        from current: ActiveJourney,
        input: JourneyEngineInput<Observation>,
        at now: Date
    ) -> JourneyTransitionOutcome
}
