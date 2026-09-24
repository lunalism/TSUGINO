// The result of asking the engine to process one input (DEC-064 C).

/// Either a valid applied result or a typed refusal.
nonisolated enum JourneyTransitionOutcome: Sendable {
    /// A valid result whose next state describes the supplied instant. It may
    /// leave the Journey and phase unchanged; `asOf` still advances.
    case applied(JourneyTransitionResult)

    /// The input could not be applied.
    case rejected(JourneyInputRejection)
}
