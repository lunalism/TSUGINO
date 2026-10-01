#if DEBUG
import Foundation

/// Synthetic schema-specific interpretation. Review flags and connection sets
/// are stipulated input, not authentication. Reusable time checks live separately.
nonisolated enum SyntheticRouteAdmission {
    static func candidate(_ input: SyntheticRouteAlternative, request: RouteSearchRequest,
                          view: SyntheticRouteDataView) throws -> RouteCandidate {
        guard input.wellFormed else { throw RouteAdmissionRejection(.malformedAlternative) }
        let rides = input.legs.compactMap { leg -> SyntheticRailInput? in
            if case .rail(let ride) = leg { ride } else { nil }
        }
        guard !rides.isEmpty else { throw RouteAdmissionRejection(.invalidStructure) }
        let contexts = try RouteScheduleAdmission.contexts(for: rides.map(\.scheduled), request: request,
                                                           assertsDepartureIntent: input.assertsDepartureIntent)
        var legs: [RouteCandidateLeg] = []
        var railIndex = 0
        var knownTrips: Set<TripID> = []
        for leg in input.legs {
            try Task.checkCancellation()
            switch leg {
            case .rail(let ride):
                // A reviewed run join is already positive identity evidence even
                // when a visit is ambiguous. Do not hide a known duplicate by
                // downgrading that ride to unresolved (DEC-076 C5).
                if let reference = ride.trainReference,
                   case .active(let id)? = view.trainMappings[reference],
                   view.trips[id]?.reviewed == true,
                   !knownTrips.insert(id).inserted {
                    throw RouteAdmissionRejection(.invalidStructure)
                }
                legs.append(.rail(try rail(ride, context: contexts[railIndex], view: view)))
                railIndex += 1
            case .walk(let from, let to):
                let start = try station(from, view)
                let end = try station(to, view)
                guard let walk = WalkingTransfer(fromStationID: start, toStationID: end)
                else { throw RouteAdmissionRejection(.invalidStructure) }
                legs.append(.walkingTransfer(walk))
            }
        }
        guard let candidate = RouteCandidate(legs: legs) else { throw RouteAdmissionRejection(.invalidStructure) }
        guard candidate.origin == request.origin, candidate.destination == request.destination
        else { throw RouteAdmissionRejection(.endpointMismatch) }
        guard input.trainChanges.count == rides.count - 1, input.trainChanges.allSatisfy({ $0 })
        else { throw RouteAdmissionRejection(.insufficientContinuity) }
        try transfers(legs, view)
        return candidate
    }

    private static func rail(_ input: SyntheticRailInput, context: ProviderScheduledContext?,
                             view: SyntheticRouteDataView) throws -> RouteRailProposal {
        guard !input.fragments.isEmpty else { throw RouteAdmissionRejection(.invalidStructure) }
        var starts: [StationID] = []
        var ends: [StationID] = []
        var lines: [LineID] = []
        for fragment in input.fragments {
            try Task.checkCancellation()
            let from = try station(fragment.from, view)
            let to = try station(fragment.to, view)
            let lineID = try resolve(view.lineMappings[fragment.line])
            try active(view.lines[lineID])
            guard from != to else { throw RouteAdmissionRejection(.invalidStructure) }
            if let end = ends.last, end != from { throw RouteAdmissionRejection(.invalidStructure) }
            starts.append(from)
            ends.append(to)
            if lines.last != lineID { lines.append(lineID) }
        }
        guard let from = starts.first, let to = ends.last,
              let anchors = RailLegAnchors(boardingStationID: from, alightingStationID: to)
        else { throw RouteAdmissionRejection(.invalidStructure) }
        guard input.continuousRide else { throw RouteAdmissionRejection(.insufficientContinuity) }

        var matched: TrainCandidate?
        if let reference = input.trainReference {
            switch view.trainMappings[reference] ?? .unknown {
            case .unknown: break // Missing or nonunique correspondence; independent route may survive.
            case .retired: throw RouteAdmissionRejection(.retiredMapping)
            case .conflicting: throw RouteAdmissionRejection(.conflictingMapping)
            case .unsupported: throw RouteAdmissionRejection(.unsupportedPortion)
            case .active(let id):
                guard let evidence = view.trips[id] else { throw RouteAdmissionRejection(.inconsistentTrainEvidence) }
                if evidence.reviewed {
                    // Each KNOWN occurrence must agree even if its counterpart is
                    // unknown. Missing correspondence cannot hide a contradiction.
                    let board = input.boardingOccurrence.flatMap { evidence.occurrences[$0] }
                    let alight = input.alightingOccurrence.flatMap { evidence.occurrences[$0] }
                    for (index, expected) in [(board, from), (alight, to)] {
                        if let index {
                            guard evidence.trip.stopSequence.indices.contains(index)
                            else { throw RouteAdmissionRejection(.invalidStructure) }
                            guard evidence.trip.stopSequence[index] == expected
                            else { throw RouteAdmissionRejection(.inconsistentTrainEvidence) }
                        }
                    }
                    if let board, let alight {
                        guard let train = TrainCandidate(trip: evidence.trip, boardingIndex: board, alightingIndex: alight)
                        else { throw RouteAdmissionRejection(.invalidStructure) }
                        guard train.anchors == anchors, train.lineSequence == lines
                        else { throw RouteAdmissionRejection(.inconsistentTrainEvidence) }
                        try validateRiddenSnapshot(train, view)
                        matched = train
                    } else if try !hasPossibleTraversal(trip: evidence.trip, from: from, to: to,
                                                       board: board, alight: alight, lines: lines) {
                        throw RouteAdmissionRejection(.inconsistentTrainEvidence)
                    }
                }
            }
        }
        let travel: RouteRailTravel
        if let matched { travel = .matched(matched) }
        else {
            guard input.independentRouteEvidence else { throw RouteAdmissionRejection(.insufficientContinuity) }
            guard let unresolved = UnresolvedRouteRailTravel(anchors: anchors, lineSequence: lines,
                reason: input.trainReference == nil ? .notSupplied : .noVerifiedMatch)
            else { throw RouteAdmissionRejection(.invalidStructure) }
            travel = .unresolved(unresolved)
        }
        guard let proposal = RouteRailProposal(travel: travel, scheduledContext: context.map(RouteScheduledContext.provider))
        else { throw RouteAdmissionRejection(.invalidStructure) }
        return proposal
    }

    /// Existential contradiction check only: no possible index is selected or
    /// returned as correspondence. Open coverage permits unknown occurrences on
    /// that side, even for a station also represented inside the snapshot.
    private static func hasPossibleTraversal(trip: Trip, from: StationID, to: StationID,
                                             board: Int?, alight: Int?, lines: [LineID]) throws -> Bool {
        let count = trip.stopSequence.count
        func possibilities(_ station: StationID, fixed: Int?) -> [Int] {
            if let fixed { return [fixed] }
            var values = trip.stopSequence.indices.filter { trip.stopSequence[$0] == station }
            // Sentinels denote unknown regions, not fabricated stop indices.
            if !trip.coverage.includesServiceOrigin { values.append(-1) }
            if !trip.coverage.includesServiceDestination { values.append(count) }
            return values
        }
        for start in possibilities(from, fixed: board) {
            for end in possibilities(to, fixed: alight) {
                try Task.checkCancellation()
                // Both unresolved endpoints could lie wholly in one unseen region.
                if start == end && (start == -1 || start == count) { return true }
                guard start < end else { continue }
                let lower = max(0, start)
                let upper = min(count - 1, end)
                let knownLines = lower < upper ? trip.lineSegments.filter {
                    $0.startIndex < upper && $0.endIndex > lower
                }.map(\.lineID) : []
                // Only boundary contact (or an entirely unseen ride) proves no
                // movement line. Unknown extensions must not invent a line.
                if knownLines.isEmpty { return true }
                guard knownLines.count <= lines.count else { continue }
                // Represented movement is contiguous and ordered. Unknown leading
                // or trailing movement can extend this sequence, including merging
                // an adjacent same-line boundary; it cannot erase/reorder it.
                for offset in 0...(lines.count - knownLines.count) {
                    try Task.checkCancellation()
                    if start >= 0 && offset != 0 { continue }
                    if end < count && offset + knownLines.count != lines.count { continue }
                    if Array(lines[offset..<(offset + knownLines.count)]) == knownLines { return true }
                }
            }
        }
        return false
    }

    private static func validateRiddenSnapshot(_ train: TrainCandidate, _ view: SyntheticRouteDataView) throws {
        // Trip itself already validates coverage/segment/index structure. Dataset
        // membership and passenger-stop review are distinct stipulated evidence.
        for index in train.boardingIndex...train.alightingIndex {
            try Task.checkCancellation()
            try active(view.stations[train.trip.stopSequence[index]])
        }
        for segment in train.trip.lineSegments where segment.startIndex < train.alightingIndex && segment.endIndex > train.boardingIndex {
            try active(view.lines[segment.lineID])
            let start = max(segment.startIndex, train.boardingIndex)
            let end = min(segment.endIndex, train.alightingIndex)
            for index in start...end {
                try Task.checkCancellation()
                guard view.memberships[train.trip.stopSequence[index]]?.contains(segment.lineID) == true
                else { throw RouteAdmissionRejection(.inconsistentTrainEvidence) }
            }
        }
        for segment in train.trip.serviceTypeSegments {
            try Task.checkCancellation()
            guard view.serviceTypes.contains(segment.serviceTypeID)
            else { throw RouteAdmissionRejection(.inconsistentTrainEvidence) }
        }
    }

    private static func transfers(_ legs: [RouteCandidateLeg], _ view: SyntheticRouteDataView) throws {
        var previous: RouteRailProposal?
        var walk: WalkingTransfer?
        for leg in legs {
            try Task.checkCancellation()
            switch leg {
            case .walkingTransfer(let value): walk = value
            case .rail(let next):
                if let previous {
                    guard let fromLine = previous.travel.lineSequence.last,
                          let toLine = next.travel.lineSequence.first else { throw RouteAdmissionRejection(.invalidStructure) }
                    if let walk {
                        guard view.walks.contains(SyntheticWalkingConnection(from: walk.fromStationID,
                            to: walk.toStationID, fromLine: fromLine, toLine: toLine))
                        else { throw RouteAdmissionRejection(.unverifiedTransfer) }
                    } else {
                        guard view.interchanges.contains(SyntheticInterchange(station: next.travel.anchors.boardingStationID,
                            fromLine: fromLine, toLine: toLine)) else { throw RouteAdmissionRejection(.unverifiedTransfer) }
                    }
                }
                previous = next
                walk = nil
            }
        }
    }

    private static func station(_ reference: String, _ view: SyntheticRouteDataView) throws -> StationID {
        let id = try resolve(view.stationMappings[reference])
        try active(view.stations[id])
        return id
    }

    private static func resolve<T>(_ resolution: SyntheticRouteResolution<T>?) throws -> T {
        switch resolution ?? .unknown {
        case .active(let value): return value
        case .unknown: throw RouteAdmissionRejection(.unknownMapping)
        case .retired: throw RouteAdmissionRejection(.retiredMapping)
        case .conflicting: throw RouteAdmissionRejection(.conflictingMapping)
        case .unsupported: throw RouteAdmissionRejection(.unsupportedPortion)
        }
    }

    private static func active(_ status: SyntheticRouteStatus?) throws {
        switch status ?? .unknown {
        case .active: return
        case .unknown: throw RouteAdmissionRejection(.unknownMapping)
        case .retired: throw RouteAdmissionRejection(.retiredMapping)
        case .conflicting: throw RouteAdmissionRejection(.conflictingMapping)
        case .unsupported: throw RouteAdmissionRejection(.unsupportedPortion)
        }
    }
}
#endif
