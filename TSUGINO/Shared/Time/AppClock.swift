import Foundation

/// Project-owned wall-clock abstraction (ARCHITECTURE.md §38, RULES.md Rule 38).
///
/// Named `AppClock` to avoid colliding with Swift's standard `Clock` protocol.
/// Application and domain logic read time through this protocol so tests can inject
/// a deterministic instant. It deliberately exposes no sleeping, timers, or
/// scheduling; Phase 0 has no such requirement.
nonisolated protocol AppClock: Sendable {
    /// The current wall-clock instant.
    var now: Date { get }
}

/// Production clock backed by system time.
nonisolated struct SystemAppClock: AppClock {
    init() {}

    var now: Date { Date() }
}

/// Deterministic clock for tests. Returns the same instant until a new value is
/// derived with `advanced(by:)`; it never observes system time.
nonisolated struct FixedAppClock: AppClock, Equatable {
    let now: Date

    init(now: Date) {
        self.now = now
    }

    /// A new fixed clock whose instant is offset from this one. Value semantics:
    /// the receiver is unchanged.
    func advanced(by interval: TimeInterval) -> FixedAppClock {
        FixedAppClock(now: now.addingTimeInterval(interval))
    }
}
