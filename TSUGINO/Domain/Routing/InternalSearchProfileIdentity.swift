import Foundation

/// Semantic definition identity, not a persistent registry or uniqueness proof.
/// A changed definition requires a new revision; configuration enforces history.
nonisolated struct InternalSearchProfileIdentity: Hashable, Sendable {
    let key: UUID
    let revision: UUID
}

/// Must resolve to immutable policy contents before runtime use. This value does
/// not resolve, authorize or authenticate the referenced policy.
nonisolated struct InternalSearchPolicyReference: Hashable, Sendable {
    let key: UUID
    let revision: UUID
}
