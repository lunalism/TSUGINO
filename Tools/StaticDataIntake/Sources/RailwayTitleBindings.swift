import Foundation

struct TitleBindingResult {
    let evidence: [TitleEvidence]
    let accepted: [EditorialStationKey: TitleBindingReview]
    let held: [EditorialStationKey: NameHold]
    let history: TitleHistory
    struct Status: Codable { let source: EditorialStationKey; let heldBack: NameHold? }
    var statuses: [Status] {
        Set(evidence.map(\.source) + Array(held.keys)).sorted { a,b in
            a.sourceID == b.sourceID ? a.stationReference < b.stationReference : a.sourceID < b.sourceID
        }.map { .init(source:$0,heldBack:held[$0]) }
    }
}
enum RailwayTitleBindings {
    static func evidence(_ catalog: RailNameCatalog, crosswalks: [TitleCrosswalk]) throws -> [TitleEvidence] {
        for crosswalk in crosswalks {
            guard catalog.input.documents[crosswalk.documentID] == crosswalk.documentSHA256 else { throw NameReviewError.malformed }
        }
        return catalog.occurrences.keys.sorted { a,b in a.sourceID == b.sourceID ? a.stationReference < b.stationReference : a.sourceID < b.sourceID }.map { key in
            let occurrences = catalog.occurrences[key]!
            let lines = Set(occurrences.map(\.lineID))
            let candidates = catalog.entityIDs.filter { id in
                id.kind == .station && lines.allSatisfy { line in
                    (catalog.members[id] ?? []).contains { $0.namespace == .gtfsStopID && $0.lineIDs.contains(line) }
                }
            }.map { id in
                let scopes = catalog.input.network.lines.filter { line in
                    lines.contains(line.lineID) && line.topology != nil && catalog.input.network.shapes.filter { $0.lineID == line.lineID }.allSatisfy(\.passed)
                }.sorted { $0.lineID < $1.lineID }.map { line in
                    TitleTarget.Scope(lineID:line.lineID,neighbours:Set(line.candidates.filter {
                        $0.included == true && ($0.pair.first == id || $0.pair.second == id)
                    }.map { $0.pair.first == id ? $0.pair.second : $0.pair.first }).sorted())
                }
                return TitleTarget(stationID:id,members:catalog.members[id] ?? [],neighbours:Set(scopes.flatMap(\.neighbours)).sorted(),lineScopes:scopes)
            }
            return TitleEvidence(source:key,occurrences:occurrences,candidates:candidates,
                crosswalks:crosswalks.filter { $0.source == key }.sorted { $0.id < $1.id },
                inputSHA256:catalog.inputHashes,registrySHA256:catalog.input.registrySHA256,
                memberProvenance:(candidates.flatMap { catalog.provenance[$0.stationID] ?? [] } + lines.sorted().flatMap { catalog.provenance[$0] ?? [] }).sorted(by:NameSighting.precedes),
                networkEvidenceSHA256:catalog.input.network.lines.filter { lines.contains($0.lineID) }.map(\.evidenceSHA256).sorted())
        }
    }
    static func basicHold(_ review: TitleBindingReview, _ evidence: TitleEvidence) -> NameHold? {
        guard evidence.source == review.evidence.source, evidence.candidates.contains(where: { $0.stationID == review.stationID }) else { return .unknownEntity }
        var seen = Set<String>()
        for occurrence in evidence.occurrences {
            // Same source twice in an enclosing record is not silently folded.
            let recordKey = NameDigest.of([occurrence.source.sourceID, occurrence.railwayID])
            if !seen.insert(recordKey).inserted { return .bindingUnresolved }
        }
        guard !evidence.occurrences.isEmpty else { return .selectedMissing }
        guard review.semanticDigest(evidence) == review.selectionEvidenceSHA256 else { return .relevantEvidenceChanged }
        return nil
    }
    static func directTarget(_ evidence: TitleEvidence) -> MintedIdentifier? {
        var targets = Set<MintedIdentifier>()
        for crosswalk in evidence.crosswalks {
            let matches = evidence.candidates.filter { candidate in candidate.members.contains { member in
                member.namespace == .gtfsStopID && member.sourceID == crosswalk.gtfsSourceID && member.value == crosswalk.stopID
            } }
            // Unresolvable or conflicting authoritative assertions cannot be
            // dropped just because another assertion supports the selection.
            guard matches.count == 1 else { return nil }
            targets.insert(matches[0].stationID)
        }
        return targets.count == 1 ? targets.first : nil
    }
    static func anchoredHold(_ review: TitleBindingReview, _ evidence: TitleEvidence,
                             direct: [EditorialStationKey: TitleBindingReview], all: [TitleEvidence]) -> NameHold? {
        guard review.anchors.count == 2,
              review.anchors.allSatisfy({ direct[$0] != nil }),
              Set(review.anchors.compactMap { direct[$0]?.stationID }).count == 2,
              review.anchorReviewDigests.sorted() == review.anchors.map({ direct[$0]!.selectionEvidenceSHA256 }).sorted() else { return .rationaleUnverifiable }
        let neighbours = Set(review.anchors.map { direct[$0]!.stationID })
        let possible = evidence.candidates.filter { target in
            Set(evidence.occurrences.map(\.lineID)).allSatisfy { lineID in
                guard let scope = target.lineScopes.first(where: { $0.lineID == lineID }) else { return false }
                return neighbours.isSubset(of:Set(scope.neighbours))
            }
        }
        guard possible.count == 1, possible[0].stationID == review.stationID else { return .bindingUnresolved }
        for occurrence in evidence.occurrences {
            let anchorPositions = review.anchors.compactMap { key in
                all.first { $0.source == key }?.occurrences.first { $0.railwayID == occurrence.railwayID && $0.source.sourceID == occurrence.source.sourceID }?.logicalIndex
            }.sorted()
            guard anchorPositions.count == 2, occurrence.logicalIndex > 0, occurrence.logicalIndex < Int.max,
                  anchorPositions == [occurrence.logicalIndex-1,occurrence.logicalIndex+1] else { return .bindingUnresolved }
        }
        // A positive crosswalk disagreeing with independently anchored order
        // cannot be ignored by choosing the other basis.
        if !evidence.crosswalks.isEmpty && directTarget(evidence) != review.stationID { return .bindingUnresolved }
        return nil
    }
    static func retain(_ review: TitleBindingReview, in choices: inout [TitleBindingReview]) throws {
        guard !choices.contains(where: { $0.supersedes == review.reviewID }) else { throw NameReviewError.invalidHistory }
        if let old = choices.first(where: { $0.reviewID == review.reviewID }) {
            guard old == review else { throw NameReviewError.invalidHistory };return
        }
        let replaced = Set(choices.compactMap(\.supersedes))
        let leaves = choices.filter { $0.evidence.source == review.evidence.source && !replaced.contains($0.reviewID) }
        if let p = review.supersedes {
            guard leaves.contains(where: { $0.reviewID == p }) else { throw NameReviewError.invalidHistory }
        } else if !leaves.isEmpty { throw NameReviewError.invalidHistory }
        choices.append(review)
    }
    static func build(_ catalog: RailNameCatalog, records: RailNameRecords, previous: TitleHistory) throws -> TitleBindingResult {
        guard previous.schemaVersion == 1,
              Set(previous.choices.map(\.reviewID)).count == previous.choices.count,
              Set(previous.validations.map(\.identity)).count == previous.validations.count,
              Set(previous.observations.map { NameDigest.of($0) }).count == previous.observations.count else { throw NameReviewError.invalidHistory }
        var prefix: [TitleBindingReview] = []
        for old in previous.choices { try old.validateRecord(); try retain(old,in:&prefix) }
        var prior: [ExactValue:String] = [:]
        for validation in previous.validations {
            guard validation.evidenceSHA256 == NameDigest.of(validation.evidence), validation.previousValidationSHA256 == prior[validation.reviewID],
                  validation.validatorVersion == 1, let review = previous.choices.first(where: { $0.reviewID == validation.reviewID }),
                  basicHold(review,validation.evidence) == nil else { throw NameReviewError.invalidHistory }
            if review.basis == .authoritativeCrosswalk {
                guard directTarget(validation.evidence) == review.stationID, validation.anchorEvidence.isEmpty else { throw NameReviewError.invalidHistory }
            } else {
                var direct: [EditorialStationKey:TitleBindingReview] = [:]
                var anchorEvidence: [TitleEvidence] = []
                for digest in validation.anchorEvidence {
                    guard let anchor = previous.choices.first(where: { $0.selectionEvidenceSHA256 == digest && $0.basis == .authoritativeCrosswalk }),
                          let sighting = previous.validations.first(where: { $0.reviewID == anchor.reviewID && $0.evidence.inputSHA256 == validation.evidence.inputSHA256 && $0.evidence.registrySHA256 == validation.evidence.registrySHA256 }),
                          basicHold(anchor,sighting.evidence) == nil, directTarget(sighting.evidence) == anchor.stationID else { throw NameReviewError.invalidHistory }
                    direct[anchor.evidence.source] = anchor; anchorEvidence.append(sighting.evidence)
                }
                guard validation.anchorEvidence.sorted() == review.anchorReviewDigests.sorted(),
                      anchoredHold(review,validation.evidence,direct:direct,all:anchorEvidence) == nil else { throw NameReviewError.invalidHistory }
            }
            prior[validation.reviewID] = validation.identity
        }
        let all = try evidence(catalog,crosswalks:records.crosswalks)
        var accepted: [EditorialStationKey:TitleBindingReview] = [:]
        var held: [EditorialStationKey:NameHold] = [:]
        var history = previous
        for e in all where !history.observations.contains(where: { NameDigest.of($0) == NameDigest.of(e) }) { history.observations.append(e) }
        for review in records.titles.sorted(by: { $0.reviewID < $1.reviewID }) {
            try retain(review,in:&history.choices)
        }
        for e in all {
            guard let review = records.titles.first(where: { $0.evidence.source == e.source }) else { held[e.source] = .reviewRequired;continue }
            if let h = basicHold(review,e) { held[e.source] = h;continue }
            if review.basis == .authoritativeCrosswalk {
                guard review.anchors.isEmpty, review.anchorReviewDigests.isEmpty, directTarget(e) == review.stationID else { held[e.source] = .bindingUnresolved;continue }
                accepted[e.source] = review
            }
        }
        for review in history.choices where !history.choices.contains(where: { $0.supersedes == review.reviewID }) && !all.contains(where: { $0.source == review.evidence.source }) {
            held[review.evidence.source] = .selectedMissing
        }
        let direct = accepted
        for e in all {
            guard let review = records.titles.first(where: { $0.evidence.source == e.source }), review.basis == .anchoredNeighbours,
                  held[e.source] == nil else { continue }
            if let h = anchoredHold(review,e,direct:direct,all:all) { held[e.source] = h }
            else { accepted[e.source] = review }
        }
        for e in all {
            guard let review = accepted[e.source] else { continue }
            let v = TitleValidation(reviewID:review.reviewID,evidence:e,anchorEvidence:review.anchorReviewDigests.sorted(),validatorVersion:1,
                evidenceSHA256:NameDigest.of(e),previousValidationSHA256:history.validations.last { $0.reviewID == review.reviewID }?.identity)
            if !history.validations.contains(where: { $0.identity == v.identity }) { history.validations.append(v) }
        }
        return .init(evidence:all,accepted:accepted,held:held,history:history)
    }
}
