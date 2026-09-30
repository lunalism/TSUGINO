import Foundation

// Reviewer-selected values used ONLY to prepare record templates. This is
// deliberately separate from validated/approved records: packet export never
// approves or applies these selections. The reviewer approves the exact result.
struct RailNameSelections: Codable {
    struct Name: Codable {
        let reviewID: ExactValue
        let reviewer: ExactValue
        let date: ExactValue
        let supersedes: ExactValue?
        let entityID: MintedIdentifier
        let language: RailNameLanguage
        let purpose: NameChoice.Purpose
        let selected: NameSourceKey
        let value: ExactValue
        let reason: ExactValue
        let basis: NameChoice.Basis
        let preferredSource: ExactValue?
        let aliasRule: StationAliasRule?
        func template(_ e: NameEvidence) -> NameChoice {
            func make(_ digest: String) -> NameChoice {
                .init(reviewID:reviewID,reviewer:reviewer,date:date,supersedes:supersedes,purpose:purpose,selected:selected,value:value,
                    reason:reason,basis:basis,preferredSource:preferredSource,aliasRule:aliasRule,evidence:e,
                    selectionEvidenceSHA256:digest,reviewEvidenceSHA256:NameDigest.of(e))
            }
            return make(make("").semanticDigest(e))
        }
    }
    struct Title: Codable {
        let reviewID: ExactValue
        let reviewer: ExactValue
        let date: ExactValue
        let supersedes: ExactValue?
        let source: EditorialStationKey
        let stationID: MintedIdentifier
        let reason: ExactValue
        let basis: TitleBindingReview.Basis
        let anchors: [EditorialStationKey]
        func template(_ e: TitleEvidence, accepted: [EditorialStationKey:TitleBindingReview]) throws -> TitleBindingReview {
            let deps = try anchors.map { key -> String in
                guard let review = accepted[key], review.basis == .authoritativeCrosswalk else { throw NameReviewError.malformed }
                return review.selectionEvidenceSHA256
            }.sorted()
            func make(_ digest:String) -> TitleBindingReview {
                .init(reviewID:reviewID,reviewer:reviewer,date:date,supersedes:supersedes,stationID:stationID,reason:reason,basis:basis,
                    anchors:anchors,anchorReviewDigests:deps,evidence:e,selectionEvidenceSHA256:digest,reviewEvidenceSHA256:NameDigest.of(e))
            }
            return make(make("").semanticDigest(e))
        }
    }
    let schemaVersion: Int
    let names: [Name]
    let titles: [Title]
    func templates(_ outcome: RailNameOutcome, records: RailNameRecords) throws -> RailNameRecords {
        guard schemaVersion == 1 else { throw NameReviewError.schema }
        let names = try names.map { selection -> NameChoice in
            guard let e = outcome.evidence.first(where: { $0.entityID == selection.entityID && $0.language == selection.language }) else { throw NameReviewError.unknownEntity }
            let c = selection.template(e)
            try c.validateRecord()
            guard c.hold(in:e) == nil else { throw NameReviewError.malformed }
            return c
        }
        let titles = try titles.map { selection -> TitleBindingReview in
            guard let e = outcome.titleBindings.evidence.first(where: { $0.source == selection.source }) else { throw NameReviewError.unknownEntity }
            let t = try selection.template(e,accepted:outcome.titleBindings.accepted);try t.validateRecord();return t
        }
        let result = RailNameRecords(names:names,titles:titles,authored:records.authored,crosswalks:records.crosswalks)
        try result.validate();return result
    }
}
