#if DEBUG
import Foundation

nonisolated struct SyntheticTripCrosswalkEntry: Sendable {
    let sourceOccurrence: UUID
    let sourceOrder: Int
    /// nil is an affirmatively passed position, never an unknown/missing visit.
    let originalIndex: Int?
}
nonisolated enum SyntheticTripRevisionObligation: Sendable {
    case initial, unchanged, revalidationRequired
}
fileprivate nonisolated enum SyntheticTripEvidenceRole: Hashable, Sendable {
    case interval, identity, continuity, origin, destination
    case classification(UUID), mapping(UUID)
}
/// Evidence applicability over an exact source interval, independent of subdivision.
fileprivate nonisolated struct SyntheticTripMovementEvidence: Equatable, Sendable {
    let from: UUID
    let to: UUID
    let line: LineID
    let evidence: UUID
}
/// A locally consistent review candidate, never authenticated/registered/imported truth.
/// No Codable, identity-only equality or public memberwise construction.
nonisolated struct SyntheticTripReviewCandidate: Sendable {
    let trip: Trip
    let view: SyntheticTripReviewView
    let crosswalk: [SyntheticTripCrosswalkEntry]
    let originEvidence: SyntheticTripBoundary
    let destinationEvidence: SyntheticTripBoundary
    let evidenceReferences: [UUID]
    fileprivate let reviewEvidence: [SyntheticTripEvidenceRole: UUID]
    fileprivate let movementEvidence: [SyntheticTripMovementEvidence]
    let revisionObligation: SyntheticTripRevisionObligation

    fileprivate init(trip: Trip, run: SyntheticTripReviewRun,
                     crosswalk: [SyntheticTripCrosswalkEntry], revision: SyntheticTripRevisionObligation) {
        self.trip = trip; view = run.view; self.crosswalk = crosswalk
        originEvidence = run.origin; destinationEvidence = run.destination
        evidenceReferences = SyntheticTripReviewValidator.evidence(in: run)
        reviewEvidence = SyntheticTripReviewValidator.reviewEvidence(in: run)
        movementEvidence = SyntheticTripReviewValidator.movementEvidence(in: run)
        revisionObligation = revision
    }

    func matches(view: SyntheticTripReviewView, trip: Trip) -> Bool {
        self.view == view && SyntheticTripReviewValidator.sameSnapshot(self.trip, trip)
    }
}

/// Synchronous, pure offline validation of supplied invented assertions. No app composition.
nonisolated enum SyntheticTripReviewValidator {
    static func validate(_ packet: SyntheticTripReviewPacket) -> SyntheticTripReviewResult {
        var references: Set<UUID> = []
        for run in packet.runs {
            guard run.view == packet.view, references.insert(run.reference).inserted,
                  evidence(in: run).allSatisfy({ packet.evidenceReferences.contains($0) }) else { return .invalidPacket }
        }
        let records = packet.runs.sorted { precedes($0.reference, $1.reference) }.map {
            SyntheticTripReviewRecord(reference: $0.reference, outcome: validateRun($0))
        }
        // A coherent view cannot supply competing snapshot definitions for the same Trip.
        var snapshots: [TripID: Trip] = [:]
        for record in records {
            if case .candidate(let candidate) = record.outcome {
                if let previous = snapshots[candidate.trip.id], !sameSnapshot(previous, candidate.trip) { return .invalidPacket }
                snapshots[candidate.trip.id] = candidate.trip
            }
        }
        return .reviewed(records)
    }

    private static func validateRun(_ run: SyntheticTripReviewRun) -> SyntheticTripReviewOutcome {
        var issues = Issues()
        var refs: Set<UUID> = [], orders: Set<Int> = []
        for position in run.positions {
            guard let order = position.order, refs.insert(position.reference).inserted, orders.insert(order).inserted else {
                issues.add(.orderConflict, position.reference, reject: true); continue
            }
        }
        // No speculative interval/index checks when order itself cannot be established.
        if !issues.isEmpty { return issues.outcome(order: run.positions.map(\.reference).sorted(by: precedes)) }
        let ordered = run.positions.sorted { $0.order! < $1.order! }
        guard let first = ordered.firstIndex(where: { $0.reference == run.first }),
              let last = ordered.firstIndex(where: { $0.reference == run.last }), first < last else {
            issues.add(.invalidStructure, reject: true); return issues.outcome(order: [])
        }
        let positions = Array(ordered[first...last])
        let locationOrder = positions.map(\.reference)
        if run.intervalEvidence == nil || run.continuityEvidence == nil { issues.add(.coverageEvidenceMissing) }
        var tripID: TripID?
        switch run.identity {
        case .reviewed(let id, let evidence):
            if evidence == nil { issues.add(.identityUnresolved) } else { tripID = id }
        case .unresolved: issues.add(.identityUnresolved)
        case .impossible: issues.add(.identityConflict, reject: true)
        case .awaitingRegistration: issues.add(.registrationRequired)
        }
        // A reviewed identity conflict is independent of classification/structure readiness.
        if let prior = run.prior, let tripID, prior.trip.id != tripID {
            issues.add(.identityConflict, reject: true)
        }
        let origin = boundary(run.origin, issues: &issues)
        let destination = boundary(run.destination, issues: &issues)
        var stations: [StationID] = []
        var indices: [UUID: Int] = [:], crosswalk: [SyntheticTripCrosswalkEntry] = []
        var classificationComplete = true
        var passed: Set<UUID> = []
        for position in positions {
            switch position.classification {
            case .unknown:
                issues.add(.unknownClassification, position.reference); classificationComplete = false
            case .passed(let evidence):
                if evidence == nil { issues.add(.unknownClassification, position.reference); classificationComplete = false }
                else { passed.insert(position.reference); crosswalk.append(.init(sourceOccurrence: position.reference, sourceOrder: position.order!, originalIndex: nil)) }
            case .passenger(let mapping, let evidence):
                if evidence == nil { issues.add(.unknownClassification, position.reference); classificationComplete = false }
                switch mapping {
                case .unavailable: issues.add(.mappingUnavailable, position.reference); classificationComplete = false
                case .impossible: issues.add(.mappingUnavailable, position.reference, reject: true); classificationComplete = false
                case .resolved(let station, _, let mappingEvidence):
                    if mappingEvidence == nil { issues.add(.mappingUnavailable, position.reference); classificationComplete = false }
                    if evidence != nil && mappingEvidence != nil {
                        indices[position.reference] = stations.count
                        crosswalk.append(.init(sourceOccurrence: position.reference, sourceOrder: position.order!, originalIndex: stations.count))
                        stations.append(station)
                    }
                }
            }
        }
        // Prove adjacency only through affirmative passed positions. Unknown classification
        // or mapping breaks the chain; never compare a compressed subset across that gap.
        var precedingPassenger: StationID?
        for position in positions {
            if passed.contains(position.reference) { continue }
            guard case .passenger(.resolved(let station, _, let mappingEvidence), let evidence) = position.classification,
                  evidence != nil, mappingEvidence != nil else {
                precedingPassenger = nil
                continue
            }
            if precedingPassenger == station {
                issues.add(.invalidStructure, position.reference, reject: true)
            }
            precedingPassenger = station
        }
        // The explicitly selected interval's boundaries must themselves be passenger
        // occurrences; an unknown movement line cannot rescue a proven passed boundary.
        for reference in [run.first, run.last] where passed.contains(reference) {
            issues.add(.representationConflict, reference, reject: true)
        }
        if classificationComplete && stations.count < 2 {
            issues.add(.invalidStructure, reject: true)
        }
        // Validate movement claims against their exact source positions even if classification is held.
        var previous = run.first
        let sourceIndex = Dictionary(uniqueKeysWithValues: positions.enumerated().map { ($0.element.reference, $0.offset) })
        var movementComplete = true
        var sourceSpans: [(UUID, UUID, LineID)] = []
        if run.movements.isEmpty { issues.add(.coverageEvidenceMissing); movementComplete = false }
        for movement in run.movements {
            guard let b = sourceIndex[movement.from], let a = sourceIndex[movement.to], b < a,
                  movement.from == previous else { issues.add(.invalidStructure, reject: true); movementComplete = false; continue }
            previous = movement.to
            switch movement.line {
            case .unavailable: issues.add(.mappingUnavailable, movement.from); movementComplete = false
            case .impossible: issues.add(.mappingUnavailable, movement.from, reject: true); movementComplete = false
            case .resolved(let line, let evidence):
                if evidence == nil { issues.add(.mappingUnavailable, movement.from); movementComplete = false }
                else { sourceSpans.append((movement.from, movement.to, line)) }
            }
        }
        if !run.movements.isEmpty && previous != run.last { issues.add(.invalidStructure, reject: true); movementComplete = false }
        // A conclusive membership contradiction does not disappear because another visit
        // is unknown. This check uses source intervals, not a compressed partial crosswalk.
        for span in sourceSpans {
            guard let b = sourceIndex[span.0], let a = sourceIndex[span.1] else { continue }
            for position in positions[b...a] {
                if case .passenger(.resolved(_, let membership, let mappingEvidence), let classificationEvidence) = position.classification,
                   mappingEvidence != nil, classificationEvidence != nil, !membership.contains(span.2) {
                    issues.add(.mappingUnavailable, position.reference, reject: true)
                }
            }
        }
        // Adjacent proven changes remain impossible at a passed position even when
        // an unrelated span has unknown mapping. Do not bridge an unknown span.
        for (left, right) in zip(sourceSpans, sourceSpans.dropFirst()) {
            if left.1 == right.0 && left.2 != right.2 && passed.contains(left.1) {
                issues.add(.representationConflict, left.1, reject: true)
            }
        }
        // Combine adjacent identical evidenced lines before projecting onto passenger indices.
        var normalized: [(UUID, UUID, LineID)] = []
        for span in sourceSpans {
            if let last = normalized.last, last.1 == span.0 && last.2 == span.2 {
                normalized[normalized.count - 1] = (last.0, span.1, span.2)
            } else { normalized.append(span) }
        }
        var segments: [TripLineSegment] = []
        if movementComplete {
            for span in normalized {
                if passed.contains(span.0) || passed.contains(span.1) {
                    issues.add(.representationConflict, passed.contains(span.0) ? span.0 : span.1, reject: true)
                }
            }
        }
        if classificationComplete && movementComplete {
            for span in normalized {
                guard let b = indices[span.0], let a = indices[span.1] else {
                    issues.add(.representationConflict, indices[span.0] == nil ? span.0 : span.1, reject: true); continue
                }
                guard let segment = TripLineSegment(lineID: span.2, startIndex: b, endIndex: a) else {
                    issues.add(.invalidStructure, reject: true); continue
                }
                segments.append(segment)
            }
        }
        if let prior = run.prior, prior.view == run.view, prior.trip.id == tripID {
            // Compare affirmative claims only at the same source occurrence boundary.
            // Unknown extent and missing evidence are not affirmative continuation.
            if prior.crosswalk.first?.sourceOccurrence == run.first,
               boundariesConflict(prior.originEvidence, run.origin) {
                issues.add(.revisionMismatch, reject: true)
            }
            if prior.crosswalk.last?.sourceOccurrence == run.last,
               boundariesConflict(prior.destinationEvidence, run.destination) {
                issues.add(.revisionMismatch, reject: true)
            }
            // A known fact at an exact existing source locator can contradict its
            // predecessor without assigning any index to the current incomplete run.
            let oldVisits = Dictionary(uniqueKeysWithValues: prior.crosswalk.map { ($0.sourceOccurrence, $0) })
            for position in positions {
                guard let old = oldVisits[position.reference] else { continue }
                if position.order != old.sourceOrder {
                    issues.add(.revisionMismatch, reject: true)
                }
                switch position.classification {
                case .passed(let evidence) where evidence != nil:
                    if old.originalIndex != nil { issues.add(.revisionMismatch, reject: true) }
                case .passenger(let mapping, let evidence) where evidence != nil:
                    // Disposition is proved independently of canonical station resolution.
                    if let index = old.originalIndex {
                        if case .resolved(let station, _, let mappingEvidence) = mapping,
                           mappingEvidence != nil, prior.trip.stopSequence[index] != station {
                            issues.add(.revisionMismatch, reject: true)
                        }
                    } else { issues.add(.revisionMismatch, reject: true) }
                default: break
                }
            }
            // Compare normalized, evidenced source intervals. Prior passed positions
            // have source order but no passenger index: retain that distinction rather
            // than skipping or inventing an index. Segment bounds come only from the
            // validated predecessor's exact crosswalk. Strict overlap excludes contact.
            let oldPassengerOrders = Dictionary(uniqueKeysWithValues: prior.crosswalk.compactMap { visit in
                visit.originalIndex.map { ($0, visit.sourceOrder) }
            })
            for span in normalized {
                guard let b = oldVisits[span.0]?.sourceOrder,
                      let a = oldVisits[span.1]?.sourceOrder, b < a else { continue }
                if prior.trip.lineSegments.contains(where: { segment in
                    guard let start = oldPassengerOrders[segment.startIndex],
                          let end = oldPassengerOrders[segment.endIndex] else { return false }
                    return start < a && end > b && segment.lineID != span.2
                }) {
                    issues.add(.revisionMismatch, reject: true)
                }
            }
            // Proof applicability is independent of passenger classification. Compare
            // only established, corresponding source intervals with positive overlap.
            for span in movementEvidence(in: run) {
                guard let b = oldVisits[span.from]?.sourceOrder,
                      let a = oldVisits[span.to]?.sourceOrder, b < a else { continue }
                for old in prior.movementEvidence {
                    guard let start = oldVisits[old.from]?.sourceOrder,
                          let end = oldVisits[old.to]?.sourceOrder else { continue }
                    if start < a && end > b && (old.line != span.line || old.evidence != span.evidence) {
                        issues.add(.revisionMismatch, reject: true)
                    }
                }
            }
            // Compare affirmative proofs by role and exact occurrence, not a compressed
            // array across missing entries. Missing evidence is never itself a conflict.
            for (role, proof) in reviewEvidence(in: run) {
                guard let oldProof = prior.reviewEvidence[role], oldProof != proof else { continue }
                let corresponds: Bool
                switch role {
                case .identity: corresponds = true // reviewed TripID/view guard above
                case .interval, .continuity:
                    corresponds = prior.crosswalk.first?.sourceOccurrence == run.first
                        && prior.crosswalk.last?.sourceOccurrence == run.last
                case .origin: corresponds = prior.crosswalk.first?.sourceOccurrence == run.first
                case .destination: corresponds = prior.crosswalk.last?.sourceOccurrence == run.last
                case .classification(let ref), .mapping(let ref):
                    corresponds = oldVisits[ref] != nil && sourceIndex[ref] != nil
                }
                if corresponds { issues.add(.revisionMismatch, reject: true) }
            }
            // Complete structural facts are independently comparable even when an
            // unrelated review/coverage prerequisite is missing. Never compare a
            // compressed subset across unknown classifications or mappings.
            if classificationComplete {
                if prior.trip.stopSequence != stations || !sameCrosswalk(prior.crosswalk, crosswalk) {
                    issues.add(.revisionMismatch, reject: true)
                }
                if movementComplete && prior.trip.lineSegments != segments {
                    issues.add(.revisionMismatch, reject: true)
                }
            }
        }
        // Do not construct a shortened snapshot from the known subset of unknown facts.
        if !issues.isEmpty { return issues.outcome(order: locationOrder) }
        guard let tripID, let trip = Trip(id: tripID, stopSequence: stations, lineSegments: segments,
            coverage: .init(includesServiceOrigin: origin, includesServiceDestination: destination), serviceTypeSegments: []) else {
            issues.add(.invalidStructure, reject: true); return issues.outcome(order: locationOrder)
        }
        var revision: SyntheticTripRevisionObligation = .initial
        if let prior = run.prior {
            let same = sameSnapshot(prior.trip, trip) && sameCrosswalk(prior.crosswalk, crosswalk)
                && prior.reviewEvidence == reviewEvidence(in: run)
                && prior.movementEvidence == movementEvidence(in: run)
                && sameBoundary(prior.originEvidence, run.origin) && sameBoundary(prior.destinationEvidence, run.destination)
            if prior.view == run.view && !same { issues.add(.revisionMismatch, reject: true); return issues.outcome(order: locationOrder) }
            revision = prior.view == run.view && same ? .unchanged : .revalidationRequired
        }
        return .candidate(.init(trip: trip, run: run, crosswalk: crosswalk, revision: revision))
    }

    private static func boundariesConflict(_ a: SyntheticTripBoundary, _ b: SyntheticTripBoundary) -> Bool {
        switch (a, b) {
        case (.reached(let x), .continued(let y)), (.continued(let x), .reached(let y)):
            return x != nil && y != nil
        default: return false
        }
    }

    private static func boundary(_ input: SyntheticTripBoundary, issues: inout Issues) -> Bool {
        switch input {
        case .unknownExtent: return false
        case .reached(let evidence):
            if evidence == nil { issues.add(.coverageEvidenceMissing) }; return evidence != nil
        case .continued(let evidence):
            if evidence == nil { issues.add(.coverageEvidenceMissing) }; return false
        }
    }
    fileprivate static func evidence(in run: SyntheticTripReviewRun) -> [UUID] {
        var values = [run.intervalEvidence, run.continuityEvidence]
        if case .reviewed(_, let e) = run.identity { values.append(e) }
        for boundary in [run.origin, run.destination] {
            switch boundary { case .reached(let e), .continued(let e): values.append(e); case .unknownExtent: break }
        }
        for position in run.positions.sorted(by: { precedes($0.reference, $1.reference) }) {
            switch position.classification {
            case .passenger(let mapping, let e):
                values.append(e)
                if case .resolved(_, _, let e) = mapping { values.append(e) }
            case .passed(let e): values.append(e)
            case .unknown: break
            }
        }
        for movement in run.movements { if case .resolved(_, let e) = movement.line { values.append(e) } }
        return values.compactMap { $0 }
    }
    fileprivate static func reviewEvidence(in run: SyntheticTripReviewRun) -> [SyntheticTripEvidenceRole: UUID] {
        var result: [SyntheticTripEvidenceRole: UUID] = [:]
        result[.interval] = run.intervalEvidence
        result[.continuity] = run.continuityEvidence
        if case .reviewed(_, let e) = run.identity { result[.identity] = e }
        for (role, boundary) in [(SyntheticTripEvidenceRole.origin, run.origin), (.destination, run.destination)] {
            switch boundary {
            case .reached(let e), .continued(let e): result[role] = e
            case .unknownExtent: break
            }
        }
        for position in run.positions {
            switch position.classification {
            case .passenger(let mapping, let e):
                result[.classification(position.reference)] = e
                if case .resolved(_, _, let e) = mapping { result[.mapping(position.reference)] = e }
            case .passed(let e): result[.classification(position.reference)] = e
            case .unknown: break
            }
        }
        return result
    }
    // Preserve source anchors in candidate storage and established pre-hold facts,
    // line and proof applicability; raw references remain available for catalog checks.
    // Never use a set: swapping proofs between intervals is a meaningful revision.
    fileprivate static func movementEvidence(in run: SyntheticTripReviewRun) -> [SyntheticTripMovementEvidence] {
        var result: [SyntheticTripMovementEvidence] = []
        var mayJoin = false
        for movement in run.movements {
            guard case .resolved(let line, let evidence?) = movement.line else {
                mayJoin = false
                continue
            }
            if mayJoin, let last = result.last, last.to == movement.from,
               last.line == line, last.evidence == evidence {
                result[result.count - 1] = .init(from: last.from, to: movement.to, line: line, evidence: evidence)
            } else {
                result.append(.init(from: movement.from, to: movement.to, line: line, evidence: evidence))
            }
            mayJoin = true
        }
        return result
    }
    fileprivate static func sameSnapshot(_ a: Trip, _ b: Trip) -> Bool {
        a.id == b.id && a.stopSequence == b.stopSequence && a.lineSegments == b.lineSegments
            && a.coverage == b.coverage && a.serviceTypeSegments == b.serviceTypeSegments
    }
    private static func sameCrosswalk(_ a: [SyntheticTripCrosswalkEntry], _ b: [SyntheticTripCrosswalkEntry]) -> Bool {
        a.count == b.count && zip(a, b).allSatisfy { $0.sourceOccurrence == $1.sourceOccurrence && $0.sourceOrder == $1.sourceOrder && $0.originalIndex == $1.originalIndex }
    }
    private static func sameBoundary(_ a: SyntheticTripBoundary, _ b: SyntheticTripBoundary) -> Bool {
        switch (a, b) {
        case (.reached(let x), .reached(let y)), (.continued(let x), .continued(let y)): return x == y
        case (.unknownExtent, .unknownExtent): return true
        default: return false
        }
    }
    private static func precedes(_ a: UUID, _ b: UUID) -> Bool { a.uuidString < b.uuidString }
    private struct Issues {
        var locations: [SyntheticTripReviewReason: Set<UUID>] = [:]
        var rejected = false
        var isEmpty: Bool { locations.isEmpty }
        mutating func add(_ reason: SyntheticTripReviewReason, _ location: UUID? = nil, reject: Bool = false) {
            if locations[reason] == nil { locations[reason] = [] }
            if let location { locations[reason, default: []].insert(location) }
            rejected = rejected || reject
        }
        func outcome(order: [UUID]) -> SyntheticTripReviewOutcome {
            let diagnostics = SyntheticTripReviewReason.allCases.compactMap { reason -> SyntheticTripReviewDiagnostic? in
                guard let locators = locations[reason] else { return nil }
                let ranks = Dictionary(order.enumerated().map { ($0.element, $0.offset) }, uniquingKeysWith: min)
                let sorted = locators.sorted {
                    let a = ranks[$0] ?? Int.max, b = ranks[$1] ?? Int.max
                    return a == b ? precedes($0, $1) : a < b
                }
                return .init(reason: reason, locations: sorted)
            }
            // A known contradiction is not erased by another missing fact.
            return rejected ? .rejected(diagnostics) : .held(diagnostics)
        }
    }
}
#endif
