#if DEBUG
import Foundation

/// Producer §10: finite invented inputs only. No source authentication or search coverage proof.
nonisolated enum SyntheticTimetableInventoryDeclaration: Sendable {
    case stipulatedComplete, unknown
}
nonisolated struct SyntheticTimetableBatchEnvelope: Sendable {
    let viewID: TimetableViewID
    let revision: SyntheticTimetableRevision
    let expected: [TimetableOccurrenceAddress]
    let inventory: SyntheticTimetableInventoryDeclaration
}
nonisolated enum SyntheticTimetableBatchLocation: Equatable, Sendable {
    case declaration(Int), packet(Int)
}
nonisolated enum SyntheticTimetableBatchReason: Equatable, Sendable {
    case resourceLimit, packetPreflight, duplicateDeclaration, declarationView
    case duplicatePacket, unexpectedPacket, missingPacket, packetAssociation, snapshotConflict
    case invalidPacket
}
nonisolated struct SyntheticTimetableBatchFailure: Sendable {
    let reason: SyntheticTimetableBatchReason
    let location: SyntheticTimetableBatchLocation?
    let converterFailure: SyntheticTimetableFailure?
}
nonisolated struct SyntheticTimetableBatch: Sendable {
    nonisolated struct Slot: Sendable {
        let binding: TimetableOccurrenceBinding
        let outcome: SyntheticTimetableOutcome
        fileprivate init(binding: TimetableOccurrenceBinding, outcome: SyntheticTimetableOutcome) {
            self.binding = binding
            self.outcome = outcome
        }
    }
    let envelope: SyntheticTimetableBatchEnvelope
    let slots: [Slot]
    fileprivate init(envelope: SyntheticTimetableBatchEnvelope, slots: [Slot]) {
        self.envelope = envelope
        self.slots = slots
    }
}
nonisolated enum SyntheticTimetableBatchResult: Sendable {
    case constructed(SyntheticTimetableBatch)
    case failure(SyntheticTimetableBatchFailure)
}

/// No retained state. Fresh-view replacement is a caller obligation: independent calls cannot
/// detect undisclosed prior view reuse. A constructed batch is not a qualified routing view.
nonisolated enum SyntheticTimetableBatchAssembler {
    static func assemble(_ envelope: SyntheticTimetableBatchEnvelope,
                         packets: [SyntheticTimetablePacket]) -> SyntheticTimetableBatchResult {
        func fail(_ reason: SyntheticTimetableBatchReason,
                  _ location: SyntheticTimetableBatchLocation? = nil,
                  _ converter: SyntheticTimetableFailure? = nil) -> SyntheticTimetableBatchResult {
            .failure(.init(reason: reason, location: location, converterFailure: converter))
        }
        guard envelope.expected.count <= 8, packets.count <= 8 else { return fail(.resourceLimit) }
        // Envelope-only length guards; packet syntax and every nested bound stay with DEC-085.
        let revision = envelope.revision
        guard [revision.source, revision.profile, revision.zone, revision.mapping]
            .allSatisfy({ $0.utf8.prefix(65).count <= 64 }) else { return fail(.resourceLimit) }
        for (i, address) in envelope.expected.enumerated() {
            guard address.tripID.rawValue.utf8.prefix(129).count <= 128,
                  address.serviceDate.label.utf8.prefix(11).count <= 10 else {
                return fail(.resourceLimit, .declaration(i))
            }
        }
        for (i, packet) in packets.enumerated() {
            if let failure = SyntheticTimetableConverter.preflightFailure(packet) {
                return fail(.packetPreflight, .packet(i), failure)
            }
        }
        var declarations = Set<TimetableOccurrenceAddress>()
        for (i, address) in envelope.expected.enumerated() {
            guard declarations.insert(address).inserted else { return fail(.duplicateDeclaration, .declaration(i)) }
        }
        for (i, address) in envelope.expected.enumerated() {
            guard address.viewID == envelope.viewID else { return fail(.declarationView, .declaration(i)) }
        }
        var byAddress: [TimetableOccurrenceAddress: Int] = [:]
        for (i, packet) in packets.enumerated() {
            guard byAddress.updateValue(i, forKey: packet.binding.address) == nil else {
                return fail(.duplicatePacket, .packet(i))
            }
        }
        for (i, packet) in packets.enumerated() {
            guard declarations.contains(packet.binding.address) else { return fail(.unexpectedPacket, .packet(i)) }
        }
        for (i, address) in envelope.expected.enumerated() {
            guard byAddress[address] != nil else { return fail(.missingPacket, .declaration(i)) }
        }
        // The address set is exact. All subsequent locations use declaration order.
        let ordered = envelope.expected.map { packets[byAddress[$0]!] }
        for (i, packet) in ordered.enumerated() {
            guard packet.binding.address.viewID == envelope.viewID, packet.revision == revision else {
                return fail(.packetAssociation, .declaration(i))
            }
        }
        var representatives: [TripID: Trip] = [:]
        for (i, packet) in ordered.enumerated() {
            let binding = packet.binding
            if let trip = representatives[binding.trip.id] {
                guard let comparison = TimetableOccurrenceBinding(address: binding.address, trip: trip),
                      binding.matches(comparison) else { return fail(.snapshotConflict, .declaration(i)) }
            } else { representatives[binding.trip.id] = binding.trip }
        }
        var slots: [SyntheticTimetableBatch.Slot] = []
        for (i, packet) in ordered.enumerated() {
            let outcome = SyntheticTimetableConverter.convert(packet)
            if case .invalid(let failure) = outcome { return fail(.invalidPacket, .declaration(i), failure) }
            slots.append(.init(binding: packet.binding, outcome: outcome))
        }
        return .constructed(.init(envelope: envelope, slots: slots))
    }
}
#endif
