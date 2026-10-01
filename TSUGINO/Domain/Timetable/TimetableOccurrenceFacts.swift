/// One original visit associated with a dated snapshot. No station-name lookup.
nonisolated struct TimetableVisitFacts: Sendable {
    let binding: TimetableOccurrenceBinding
    let originalIndex: Int
    let arrival: TimetableTime
    let departure: TimetableTime
    let boarding: TimetableEligibility
    let alighting: TimetableEligibility

    init?(binding: TimetableOccurrenceBinding, originalIndex: Int,
          arrival: TimetableTime, departure: TimetableTime,
          boarding: TimetableEligibility, alighting: TimetableEligibility) {
        guard originalIndex >= 0, originalIndex < binding.trip.stopSequence.count else { return nil }
        self.binding = binding
        self.originalIndex = originalIndex
        self.arrival = arrival
        self.departure = departure
        self.boarding = boarding
        self.alighting = alighting
    }
}

/// Locally valid qualified facts, NOT proof of service activation, correspondence,
/// rights or complete input coverage. Those prerequisites remain with the producer.
/// No calendar, source-time conversion, routing or active/inactive outcome is implemented.
nonisolated struct TimetableOccurrenceFacts: Sendable {
    let binding: TimetableOccurrenceBinding
    let visits: [TimetableVisitFacts]

    init?(binding: TimetableOccurrenceBinding, visits: [TimetableVisitFacts]) {
        guard Self.validationDiagnostic(binding: binding, visits: visits) == nil else { return nil }
        self.binding = binding
        self.visits = visits
    }

    /// Binding errors precede chronology. No indexing or arithmetic on unchecked input.
    static func validationDiagnostic(binding: TimetableOccurrenceBinding,
                                     visits: [TimetableVisitFacts]) -> TimetableDiagnostic? {
        guard visits.count == binding.trip.stopSequence.count else {
            return TimetableDiagnostic(reason: .occurrenceBinding)
        }
        for (index, visit) in visits.enumerated() {
            guard visit.originalIndex == index, binding.matches(visit.binding) else {
                // Association faults concern the visit as a whole, not an invented event.
                return TimetableDiagnostic(reason: .occurrenceBinding,
                    event: TimetableEventLocation(originalIndex: index,
                        stopCount: binding.trip.stopSequence.count))
            }
        }
        var previous: (TimetableInstant, TimetableEventLocation)?
        for visit in visits {
            for (kind, time) in [(TimetableEventKind.arrival, visit.arrival), (.departure, visit.departure)] {
                guard case let .exact(instant) = time else { continue }
                // Safe: the sole visit initializer and the checks above establish range.
                guard let location = TimetableEventLocation(originalIndex: visit.originalIndex,
                    kind: kind, stopCount: binding.trip.stopSequence.count) else {
                    return TimetableDiagnostic(reason: .occurrenceBinding)
                }
                if let previous, previous.0.date > instant.date {
                    return TimetableDiagnostic(reason: .chronologyConflict,
                                               event: previous.1, laterEvent: location)
                }
                previous = (instant, location)
            }
        }
        return nil
    }
}
