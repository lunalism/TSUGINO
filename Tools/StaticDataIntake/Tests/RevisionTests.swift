import Foundation

// DEC-068 §E cases for feed-revision reconciliation. Every registry, input,
// record, identifier, and digest is invented: stops are `syn-s…`, codes
// `Q0…`, names "Synthetic …" and 合成…, and identifiers repeat one digit.
// Nothing here is a production identifier or a real mapping.

enum SyntheticRevision {
    static let source = "SYN-01/synthetic-gtfs"
    static let otherSource = "SYN-03/synthetic-railway"
    static let inputA = String(repeating: "a", count: 64)
    static let inputB = String(repeating: "b", count: 64)
    static let inputC = String(repeating: "c", count: 64)
    static let stopsMember = String(repeating: "d", count: 64)
    static let covered: Set<ProviderNamespace> = [.gtfsStopID, .gtfsStopCode]

    static let station1 = MintedIdentifier("stn_0000000000000001")!
    static let station2 = MintedIdentifier("stn_0000000000000002")!
    static let station3 = MintedIdentifier("stn_0000000000000003")!
    static let retiredStation = MintedIdentifier("stn_0000000000000004")!
    static let line1 = MintedIdentifier("lin_0000000000000001")!

    static func row(_ stopID: String, _ field: String, _ input: String) -> SourceReference {
        try! SourceReference(
            inputSHA256: input, member: .init(name: "stops.txt", sha256: stopsMember),
            table: "stops", recordIndex: nil, field: field, providerKey: ExactValue(stopID)!
        )
    }

    static func names(_ stopID: String, _ values: [(String, String)], _ input: String) -> [OriginalName] {
        values.map { OriginalName(language: ExactValue($0.0)!, value: ExactValue($0.1)!, source: row(stopID, "stop_name", input)) }
    }

    static func key(_ value: String, _ namespace: ProviderNamespace = .gtfsStopID, source: String = source) -> ProviderReferenceKey {
        ProviderReferenceKey(sourceID: source, namespace: namespace, value: ExactValue(value)!)
    }

    static let names1: [(String, String)] = [("ja", "合成一"), ("en", "Synthetic One")]
    static let names2: [(String, String)] = [("ja", "合成二"), ("en", "Synthetic Two")]

    /// The registry after input A:
    /// - `syn-s1` (code `Q01`) and `syn-s2` (code `Q02`) are active;
    /// - `syn-s3` is absent, last seen in A;
    /// - `syn-s9` was retired by a reviewed record;
    /// - `syn-s8` is absent, on an identity retired into station 3;
    /// - one reference of another source.
    static let registry: MappingRegistry = {
        func stop(_ id: MintedIdentifier, _ value: String, _ status: ProviderReferenceStatus, _ names: [(String, String)] = []) -> ProviderReference {
            try! ProviderReference(
                canonicalID: id, sourceID: source, namespace: .gtfsStopID, value: ExactValue(value)!, status: status,
                firstSeenInputSHA256: inputA, provenance: row(value, "stop_id", inputA),
                originalNames: SyntheticRevision.names(value, names, inputA)
            )
        }
        func code(_ id: MintedIdentifier, _ value: String, _ stopID: String) -> ProviderReference {
            try! ProviderReference(
                canonicalID: id, sourceID: source, namespace: .gtfsStopCode, value: ExactValue(value)!, status: .active,
                firstSeenInputSHA256: inputA, provenance: row(stopID, "stop_code", inputA), originalNames: []
            )
        }
        let railway = try! ProviderReference(
            canonicalID: line1, sourceID: otherSource, namespace: .odptRailwayID, value: ExactValue("syn:Railway.Q")!, status: .active,
            firstSeenInputSHA256: inputA,
            provenance: SourceReference(inputSHA256: inputA, member: nil, table: nil, recordIndex: 0, field: "@id", providerKey: ExactValue("syn:Railway.Q")!),
            originalNames: []
        )
        return try! MappingRegistry(
            revision: 1,
            entities: [
                CanonicalEntity(id: station1, status: .active),
                CanonicalEntity(id: station2, status: .active),
                CanonicalEntity(id: station3, status: .active),
                CanonicalEntity(id: retiredStation, status: .retired(successors: [station3])),
                CanonicalEntity(id: line1, status: .active),
            ],
            references: [
                stop(station1, "syn-s1", .active, names1), code(station1, "Q01", "syn-s1"),
                stop(station2, "syn-s2", .active, names2), code(station2, "Q02", "syn-s2"),
                stop(station3, "syn-s3", .absent),
                stop(station3, "syn-s9", .retired(review: "SYN-REVIEW-R0")),
                stop(retiredStation, "syn-s8", .absent),
                railway,
            ]
        )
    }()

    /// An observed station: its stop row with its serving routes and,
    /// optionally, its code.
    static func station(_ stopID: String, code: String? = nil, names: [(String, String)] = [], routes: [String] = ["syn-route-q"], input: String = inputB) -> ObservedEntity {
        var references = [ObservedReference(
            namespace: .gtfsStopID, value: ExactValue(stopID)!, provenance: row(stopID, "stop_id", input),
            originalNames: SyntheticRevision.names(stopID, names, input), routes: routes.map { ExactValue($0)! }
        )]
        if let code {
            references.append(ObservedReference(namespace: .gtfsStopCode, value: ExactValue(code)!, provenance: row(stopID, "stop_code", input), originalNames: []))
        }
        return ObservedEntity(kind: .station, references: references)
    }

    /// Both active stations as they were, observed in `input`.
    static func baseline(_ input: String) -> [ObservedEntity] {
        [station("syn-s1", code: "Q01", names: names1, input: input), station("syn-s2", code: "Q02", names: names2, input: input)]
    }

    /// Input B, observing both active stations as they were.
    static let baseline = baseline(inputB)

    static func input(_ entities: [ObservedEntity] = baseline, input: String = inputB, covered: Set<ProviderNamespace> = covered) throws -> RevisionInput {
        try RevisionInput(sourceID: source, inputSHA256: input, coveredNamespaces: covered, entities: entities)
    }

    /// Input A as the registry last saw it: the previous input of a run on it.
    static var previousA: RevisionInput { try! input(baseline(inputA), input: inputA) }

    static func reconcile(
        _ entities: [ObservedEntity] = baseline,
        records: [ReviewedRevisionRecord] = [],
        registry: MappingRegistry = registry,
        previous: RevisionInput? = previousA
    ) throws -> Result<RevisionOutcome, RevisionError> {
        do {
            return .success(try RevisionReconciliation.reconcile(registry, with: try input(entities), previous: previous, records: try ReviewedRevisionSet(records)))
        } catch let error as RevisionError {
            return .failure(error)
        }
    }

    static func record(_ reviewID: String, _ key: ProviderReferenceKey, _ action: ReviewedRevisionRecord.Action, input: String = inputB) throws -> ReviewedRevisionRecord {
        try ReviewedRevisionRecord(reviewID: reviewID, key: key, inputSHA256: input, action: action)
    }

    static func category(_ outcome: RevisionOutcome, _ key: ProviderReferenceKey) -> RevisionCategory? {
        outcome.references.first { $0.key == key }?.category
    }
}

func outcomeOf(_ result: Result<RevisionOutcome, RevisionError>) throws -> RevisionOutcome {
    switch result {
    case .success(let outcome): return outcome
    case .failure(let error): throw TestFailure(message: "reconciliation failed: \(error)")
    }
}

let revisionTests: [TestCase] = [
    ("unchanged references keep their identity and first sighting, and move their provenance to the new input", { _ in
        let outcome = try outcomeOf(try SyntheticRevision.reconcile())
        let summary = outcome.summary
        try check(summary.unchanged == 4 && summary.changed == 0 && summary.absent == 0 && summary.stillAbsent == 2
            && summary.newAttached == 0 && summary.newUnassigned == 0 && summary.retired == 0 && summary.reactivated == 0, "\(summary)")
        try check(summary.previousRevision == 1 && summary.revision == 2, "revision advances when provenance moves")
        for reference in SyntheticRevision.registry.references {
            let after = outcome.registry.reference(for: reference.key)
            try check(after?.canonicalID == reference.canonicalID && after?.firstSeenInputSHA256 == reference.firstSeenInputSHA256, "identity or first sighting changed")
        }
        let s1 = outcome.registry.reference(for: SyntheticRevision.key("syn-s1"))!
        try check(s1.provenance.inputSHA256 == SyntheticRevision.inputB && s1.status == .active, "provenance")
        try check(outcome.registry.entities == SyntheticRevision.registry.entities, "entities are never changed")
        let other = SyntheticRevision.key("syn:Railway.Q", .odptRailwayID, source: SyntheticRevision.otherSource)
        try check(outcome.registry.reference(for: other) == SyntheticRevision.registry.reference(for: other), "another source is untouched")
        try check(outcome.registry.reference(for: SyntheticRevision.key("syn-s9"))?.status == .retired(review: "SYN-REVIEW-R0"), "retired stays retired")
    }),
    ("a repeat run is a fixed point, and output is byte-identical whatever the observation order", { _ in
        let first = try outcomeOf(try SyntheticRevision.reconcile())
        let again = try outcomeOf(try SyntheticRevision.reconcile())
        let sameRegistry = try first.registry.encoded() == again.registry.encoded()
        let sameSummary = try first.summary.encoded() == again.summary.encoded()
        try check(sameRegistry && sameSummary, "same inputs, same bytes")

        let shuffled = SyntheticRevision.baseline.reversed().map { ObservedEntity(kind: $0.kind, references: $0.references.reversed()) }
        let reordered = try outcomeOf(try SyntheticRevision.reconcile(shuffled))
        let reorderedBytes = try reordered.registry.encoded()
        try check(try reorderedBytes == first.registry.encoded() && reordered.references == first.references, "order does not matter")

        let repeated = try outcomeOf(try SyntheticRevision.reconcile(registry: first.registry, previous: try SyntheticRevision.input()))
        try check(try repeated.registry.encoded() == first.registry.encoded(), "a repeat run changes nothing")
        try check(repeated.summary.revision == first.summary.revision && repeated.summary.unchanged == 4, "the revision does not advance")
    }),
    ("a changed name is a descriptive change: identity kept, new value recorded beside the old", { _ in
        let renamed = [SyntheticRevision.station("syn-s1", code: "Q01", names: [("ja", "合成一"), ("en", "Synthetic First")]), SyntheticRevision.baseline[1]]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(renamed))
        try check(SyntheticRevision.category(outcome, SyntheticRevision.key("syn-s1")) == .changed && outcome.summary.changed == 1, "\(outcome.summary)")
        let s1 = outcome.registry.reference(for: SyntheticRevision.key("syn-s1"))!
        try check(s1.canonicalID == SyntheticRevision.station1, "identity kept")
        let values = s1.originalNames.map { "\($0.language.text) \($0.value.text) \($0.source.inputSHA256.prefix(1))" }
        try check(values == ["en Synthetic First b", "en Synthetic One a", "ja 合成一 a", "ja 合成一 b"], "\(values)")

        // A dropped name is a change too; the old value stays as history.
        let dropped = [SyntheticRevision.station("syn-s1", code: "Q01", names: [("ja", "合成一")]), SyntheticRevision.baseline[1]]
        let droppedOutcome = try outcomeOf(try SyntheticRevision.reconcile(dropped))
        try check(SyntheticRevision.category(droppedOutcome, SyntheticRevision.key("syn-s1")) == .changed, "dropped name")
        let droppedNames = droppedOutcome.registry.reference(for: SyntheticRevision.key("syn-s1"))!.originalNames
        try check(droppedNames.count == 3 && droppedNames.contains(SyntheticRevision.registry.reference(for: SyntheticRevision.key("syn-s1"))!.originalNames[0]), "history kept")
    }),
    ("name history is append-only: A's value and source survive a change in B and a restore in C, and a repeat of C is a fixed point", { _ in
        let s1 = SyntheticRevision.key("syn-s1")
        let original = SyntheticRevision.registry.reference(for: s1)!.originalNames
        var last = SyntheticRevision.previousA
        func run(_ registry: MappingRegistry, _ names: [(String, String)], _ input: String) throws -> RevisionOutcome {
            let entities = [
                SyntheticRevision.station("syn-s1", code: "Q01", names: names, input: input),
                SyntheticRevision.station("syn-s2", code: "Q02", names: SyntheticRevision.names2, input: input),
            ]
            let observed = try SyntheticRevision.input(entities, input: input)
            defer { last = observed }
            return try RevisionReconciliation.reconcile(registry, with: observed, previous: last)
        }
        func entries(_ outcome: RevisionOutcome) -> [OriginalName] { outcome.registry.reference(for: s1)!.originalNames }

        // B changes the English name.
        let b = try run(SyntheticRevision.registry, [("ja", "合成一"), ("en", "Synthetic First")], SyntheticRevision.inputB)
        try check(b.references.first { $0.key == s1 }?.category == .changed, "B is a change")
        try check(original.allSatisfy(entries(b).contains), "A's values and sources survive B")
        let bFirst = entries(b).filter { $0.value.text == "Synthetic First" }
        try check(bFirst.count == 1 && bFirst[0].source.inputSHA256 == SyntheticRevision.inputB, "B's value has B's source")

        // C restores the original English name.
        let c = try run(b.registry, SyntheticRevision.names1, SyntheticRevision.inputC)
        try check(c.references.first { $0.key == s1 }?.category == .changed, "C is a change back")
        try check(original.allSatisfy(entries(c).contains) && bFirst.allSatisfy(entries(c).contains), "A's and B's entries survive C")
        let restored = entries(c).filter { $0.value.text == "Synthetic One" }.map(\.source.inputSHA256)
        try check(restored == [SyntheticRevision.inputA, SyntheticRevision.inputC], "the restored value keeps A and adds C: \(restored)")
        try check(entries(c).count == 6, "\(entries(c).count) entries")

        // Each real change is a new encoded registry and a new revision.
        let bytes = try [SyntheticRevision.registry, b.registry, c.registry].map { try $0.encoded() }
        try check(bytes[0] != bytes[1] && bytes[1] != bytes[2], "encoded registries differ")
        try check([b.summary.previousRevision, b.summary.revision, c.summary.revision] == [1, 2, 3], "\(b.summary) \(c.summary)")

        // A repeat of C changes nothing.
        let repeated = try run(c.registry, SyntheticRevision.names1, SyntheticRevision.inputC)
        let repeatedBytes = try repeated.registry.encoded()
        try check(try repeatedBytes == c.registry.encoded() && repeated.summary.revision == 3 && repeated.summary.changed == 0, "\(repeated.summary)")
    }),
    ("name values keep their exact spelling: composed and decomposed forms are separate history entries", { _ in
        let s1 = SyntheticRevision.key("syn-s1")
        let composed = "合成\u{30AC}", decomposed = "合成\u{30AB}\u{3099}"
        var last = SyntheticRevision.previousA
        func run(_ registry: MappingRegistry, _ japanese: String, _ input: String) throws -> RevisionOutcome {
            let entities = [
                SyntheticRevision.station("syn-s1", code: "Q01", names: [("ja", japanese), ("en", "Synthetic One")], input: input),
                SyntheticRevision.station("syn-s2", code: "Q02", names: SyntheticRevision.names2, input: input),
            ]
            let observed = try SyntheticRevision.input(entities, input: input)
            defer { last = observed }
            return try RevisionReconciliation.reconcile(registry, with: observed, previous: last)
        }
        let a = try run(SyntheticRevision.registry, composed, SyntheticRevision.inputA)
        let b = try run(a.registry, decomposed, SyntheticRevision.inputB)
        try check(b.references.first { $0.key == s1 }?.category == .changed, "a respelling is a change")
        let c = try run(b.registry, composed, SyntheticRevision.inputC)
        let japanese = c.registry.reference(for: s1)!.originalNames.filter { $0.language.text == "ja" && $0.value.text.hasPrefix("合成") && $0.value.text != "合成一" }
        let spelled = japanese.map { ($0.value.text.unicodeScalars.map(\.value), $0.source.inputSHA256) }
        try check(spelled.count == 3, "\(spelled.count) entries")
        try check(spelled.filter { $0.0 == Array(composed.unicodeScalars.map(\.value)) }.map(\.1).sorted() == [SyntheticRevision.inputA, SyntheticRevision.inputC], "composed kept with A and C")
        try check(spelled.filter { $0.0 == Array(decomposed.unicodeScalars.map(\.value)) }.map(\.1) == [SyntheticRevision.inputB], "decomposed kept with B")
    }),
    ("reviewed records are idempotent: rerunning them against their own output changes nothing, and conflicting reuse is still refused", { _ in
        let respelled = [SyntheticRevision.station("syn-s1x", code: "Q11", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let records = [
            try SyntheticRevision.record("SYN-REVIEW-A1", SyntheticRevision.key("syn-s1x"), .attach(to: SyntheticRevision.station1)),
            try SyntheticRevision.record("SYN-REVIEW-R1", SyntheticRevision.key("syn-s3"), .retire),
        ]
        let first = try outcomeOf(try SyntheticRevision.reconcile(respelled, records: records))
        try check(first.summary.newAttached == 1 && first.summary.retired == 1, "\(first.summary)")
        let rerun = try outcomeOf(try SyntheticRevision.reconcile(respelled, records: records, registry: first.registry, previous: try SyntheticRevision.input(respelled)))
        let rerunBytes = try rerun.registry.encoded()
        try check(try rerunBytes == first.registry.encoded() && rerun.summary.revision == first.summary.revision, "rerun is a fixed point: \(rerun.summary)")
        try check(rerun.summary.newAttached == 0 && rerun.summary.retired == 0, "nothing applied twice")

        try check(first.registry.reference(for: SyntheticRevision.key("syn-s1x"))?.attachedBy == "SYN-REVIEW-A1", "the attaching review is stored")
        try check(first.registry.reference(for: SyntheticRevision.key("syn-s2"))?.attachedBy == nil, "only attached references name a review")

        // A substitute record with the same key, identity, and input is refused.
        let substitute = try SyntheticRevision.record("SYN-REVIEW-A9", SyntheticRevision.key("syn-s1x"), .attach(to: SyntheticRevision.station1))
        let substituted = try SyntheticRevision.reconcile(respelled, records: [substitute], registry: first.registry, previous: try SyntheticRevision.input(respelled))
        try check(substituted == .failure(.record(.attachToHeldReference, reviewID: "SYN-REVIEW-A9")), "\(substituted)")

        // The attaching review survives later runs, including going absent.
        let later = try RevisionReconciliation.reconcile(first.registry, with: try SyntheticRevision.input(
            [SyntheticRevision.baseline(SyntheticRevision.inputC)[1]], input: SyntheticRevision.inputC), previous: try SyntheticRevision.input(respelled))
        let absent = later.registry.reference(for: SyntheticRevision.key("syn-s1x"))
        try check(absent?.status == .absent && absent?.attachedBy == "SYN-REVIEW-A1", "kept through absence")

        // A different identity, or a key first seen in another input, is a rebind.
        let rebind = try SyntheticRevision.record("SYN-REVIEW-A2", SyntheticRevision.key("syn-s1x"), .attach(to: SyntheticRevision.station2))
        let rebound = try SyntheticRevision.reconcile(respelled, records: [rebind], registry: first.registry, previous: try SyntheticRevision.input(respelled))
        try check(rebound == .failure(.record(.attachToHeldReference, reviewID: "SYN-REVIEW-A2")), "\(rebound)")
        let sameIdentity = try SyntheticRevision.record("SYN-REVIEW-A3", SyntheticRevision.key("syn-s2"), .attach(to: SyntheticRevision.station2))
        try check(try SyntheticRevision.reconcile(records: [sameIdentity]) == .failure(.record(.attachToHeldReference, reviewID: "SYN-REVIEW-A3")), "first seen elsewhere")
        // Retired by another review.
        let other = try SyntheticRevision.record("SYN-REVIEW-R9", SyntheticRevision.key("syn-s3"), .retire)
        let retiredElsewhere = try SyntheticRevision.reconcile(respelled, records: [other], registry: first.registry, previous: try SyntheticRevision.input(respelled))
        try check(retiredElsewhere == .failure(.record(.retireRetiredReference, reviewID: "SYN-REVIEW-R9")), "\(retiredElsewhere)")
    }),
    ("rows grouped for the first time by review may share a route; only already-grouped rows conflict", { _ in
        let s4 = SyntheticRevision.station("syn-s4", routes: ["syn-route-q"]).references
        let s5 = SyntheticRevision.station("syn-s5", routes: ["syn-route-q"]).references
        let entities = SyntheticRevision.baseline + [ObservedEntity(kind: .station, references: s4 + s5)]
        let records = [
            try SyntheticRevision.record("SYN-REVIEW-A4", SyntheticRevision.key("syn-s4"), .attach(to: SyntheticRevision.station3)),
            try SyntheticRevision.record("SYN-REVIEW-A5", SyntheticRevision.key("syn-s5"), .attach(to: SyntheticRevision.station3)),
        ]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(entities, records: records))
        try check(outcome.summary.newAttached == 2, "\(outcome.summary)")
        try check(outcome.registry.resolve(SyntheticRevision.key("syn-s4")) == SyntheticRevision.station3
            && outcome.registry.resolve(SyntheticRevision.key("syn-s5")) == SyntheticRevision.station3, "one reviewed grouping")
    }),
    ("a route change is reported as a change, compared with the previous input", { _ in
        let rerouted = [SyntheticRevision.station("syn-s1", code: "Q01", names: SyntheticRevision.names1, routes: ["syn-route-q", "syn-route-r"]), SyntheticRevision.baseline[1]]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(rerouted))
        let s1 = outcome.references.first { $0.key == SyntheticRevision.key("syn-s1") }
        try check(s1?.category == .changed && s1?.routeChanged == true && s1?.canonicalID == SyntheticRevision.station1, "\(String(describing: s1))")
        try check(outcome.summary.routeChanged == 1 && outcome.summary.changed == 1 && outcome.summary.unchanged == 3, "\(outcome.summary)")
        let unchanged = try outcomeOf(try SyntheticRevision.reconcile())
        try check(unchanged.summary.routeChanged == 0, "same routes are unchanged")
    }),
    ("grouped stop rows that now share a route fail the run, unless the previous input shows they already did", { _ in
        // Station 1 is two grouped rows, syn-s1 and syn-s6.
        let grouped = try MappingRegistry(revision: 1, entities: SyntheticRevision.registry.entities, references: SyntheticRevision.registry.references + [
            ProviderReference(canonicalID: SyntheticRevision.station1, sourceID: SyntheticRevision.source, namespace: .gtfsStopID, value: ExactValue("syn-s6")!,
                              status: .active, firstSeenInputSHA256: SyntheticRevision.inputA, provenance: SyntheticRevision.row("syn-s6", "stop_id", SyntheticRevision.inputA), originalNames: []),
        ])
        func entities(_ s6Routes: [String], _ input: String) -> [ObservedEntity] {
            let s1 = SyntheticRevision.station("syn-s1", code: "Q01", names: SyntheticRevision.names1, input: input)
            let s6 = SyntheticRevision.station("syn-s6", routes: s6Routes, input: input)
            return [ObservedEntity(kind: .station, references: s1.references + s6.references), SyntheticRevision.baseline(input)[1]]
        }
        let previous = try SyntheticRevision.input(entities(["syn-route-r"], SyntheticRevision.inputA), input: SyntheticRevision.inputA)
        let shared = try SyntheticRevision.reconcile(entities(["syn-route-q"], SyntheticRevision.inputB), registry: grouped, previous: previous)
        guard case .failure(let error) = shared else { throw TestFailure(message: "\(shared)") }
        try check(error.conflictCounts == ["groupedRowsShareRoute": 1], "\(error)")

        // Already sharing in the previous input: a reviewed exception, not a change.
        let alreadyShared = try SyntheticRevision.input(entities(["syn-route-q"], SyntheticRevision.inputA), input: SyntheticRevision.inputA)
        let accepted = try outcomeOf(try SyntheticRevision.reconcile(entities(["syn-route-q"], SyntheticRevision.inputB), registry: grouped, previous: alreadyShared))
        try check(accepted.summary.routeChanged == 0, "\(accepted.summary)")

        // No previous evidence for the pair — syn-s6 was absent, so the
        // previous input did not observe it — fails closed when it returns
        // sharing a route.
        let absentRow = try MappingRegistry(revision: 1, entities: SyntheticRevision.registry.entities, references: SyntheticRevision.registry.references + [
            ProviderReference(canonicalID: SyntheticRevision.station1, sourceID: SyntheticRevision.source, namespace: .gtfsStopID, value: ExactValue("syn-s6")!,
                              status: .absent, firstSeenInputSHA256: SyntheticRevision.inputA, provenance: SyntheticRevision.row("syn-s6", "stop_id", SyntheticRevision.inputA), originalNames: []),
        ])
        let unproven = try SyntheticRevision.reconcile(entities(["syn-route-q"], SyntheticRevision.inputB), registry: absentRow, previous: SyntheticRevision.previousA)
        guard case .failure(let unprovenError) = unproven else { throw TestFailure(message: "\(unproven)") }
        try check(unprovenError.conflictCounts == ["groupedRowsShareRoute": 1], "\(unprovenError)")
    }),
    ("the previous input must be the one the registry was last reconciled with, and is required once it holds references", { _ in
        try check(try SyntheticRevision.reconcile(previous: nil) == .failure(.previousInput(.required)), "required")
        let wrongInput = try SyntheticRevision.input(SyntheticRevision.baseline(SyntheticRevision.inputC), input: SyntheticRevision.inputC)
        try check(try SyntheticRevision.reconcile(previous: wrongInput) == .failure(.previousInput(.notLastReconciled)), "not last reconciled")
        let otherSource = try RevisionInput(sourceID: SyntheticRevision.otherSource, inputSHA256: SyntheticRevision.inputA, coveredNamespaces: SyntheticRevision.covered, entities: [])
        try check(try SyntheticRevision.reconcile(previous: otherSource) == .failure(.previousInput(.otherSource)), "other source")

        // A previous input that covers nothing, or omits an active reference,
        // cannot stand in for the one the registry saw.
        let coversNothing = try RevisionInput(sourceID: SyntheticRevision.source, inputSHA256: SyntheticRevision.inputA, coveredNamespaces: [], entities: [])
        try check(try SyntheticRevision.reconcile(previous: coversNothing) == .failure(.previousInput(.incomplete)), "covers nothing")
        let empty = try RevisionInput(sourceID: SyntheticRevision.source, inputSHA256: SyntheticRevision.inputA, coveredNamespaces: SyntheticRevision.covered, entities: [])
        try check(try SyntheticRevision.reconcile(previous: empty) == .failure(.previousInput(.incomplete)), "empty")
        let missingRow = try SyntheticRevision.input([SyntheticRevision.baseline(SyntheticRevision.inputA)[0]], input: SyntheticRevision.inputA)
        try check(try SyntheticRevision.reconcile(previous: missingRow) == .failure(.previousInput(.incomplete)), "omits syn-s2")
        let codesUncovered = try SyntheticRevision.input(
            SyntheticRevision.baseline(SyntheticRevision.inputA).map { ObservedEntity(kind: $0.kind, references: [$0.references[0]]) },
            input: SyntheticRevision.inputA, covered: [.gtfsStopID])
        try check(try SyntheticRevision.reconcile(previous: codesUncovered) == .failure(.previousInput(.incomplete)), "codes not covered")
        // A first reconciliation, with nothing active of the source, needs none.
        let first = try outcomeOf(try SyntheticRevision.reconcile(registry: .empty, previous: nil))
        try check(first.summary.newUnassigned == 4 && first.summary.revision == 0, "\(first.summary)")
    }),
    ("route evidence is required on every stop row and only there", { _ in
        func refused(_ references: [ObservedReference]) throws -> RevisionInput.Invalid? {
            do { _ = try SyntheticRevision.input([ObservedEntity(kind: .station, references: references)]); return nil }
            catch let error as RevisionInput.Invalid { return error }
        }
        let row = SyntheticRevision.station("syn-s1", code: "Q01").references
        let noRoutes = ObservedReference(namespace: .gtfsStopID, value: row[0].value, provenance: row[0].provenance, originalNames: [])
        try check(try refused([noRoutes]) == .missingRouteEvidence, "missing")
        var codeWithRoutes = row[1]
        codeWithRoutes.routes = [ExactValue("syn-route-q")!]
        try check(try refused([row[0], codeWithRoutes]) == .unexpectedRouteEvidence, "unexpected")
        let repeated = SyntheticRevision.station("syn-s1", routes: ["syn-route-q", "syn-route-q"]).references
        try check(try refused(repeated) == .repeatedRoute, "repeated")
        try check(try refused([SyntheticRevision.station("syn-s1", routes: []).references[0]]) == nil, "an unserved row has no routes")
    }),
    ("a new code on a held stop row is a descriptive change, and the old code goes absent", { _ in
        let recoded = [SyntheticRevision.station("syn-s1", code: "Q11", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(recoded))
        try check(SyntheticRevision.category(outcome, SyntheticRevision.key("Q11", .gtfsStopCode)) == .changed, "new code")
        try check(outcome.registry.resolve(SyntheticRevision.key("Q11", .gtfsStopCode)) == SyntheticRevision.station1, "attached to the stop's identity")
        let old = outcome.registry.reference(for: SyntheticRevision.key("Q01", .gtfsStopCode))
        try check(old?.status == .absent && old?.canonicalID == SyntheticRevision.station1, "old code kept as absent history")
        try check(outcome.registry.resolve(SyntheticRevision.key("Q01", .gtfsStopCode)) == nil, "absent does not resolve")
        try check(outcome.summary.changed == 1 && outcome.summary.absent == 1, "\(outcome.summary)")
    }),
    ("an omitted reference goes absent, stays absent, and returns to its identity when it reappears", { _ in
        let first = try outcomeOf(try SyntheticRevision.reconcile([SyntheticRevision.baseline[0]]))
        try check(first.summary.absent == 2 && first.summary.stillAbsent == 2, "\(first.summary)")
        let s2 = first.registry.reference(for: SyntheticRevision.key("syn-s2"))
        try check(s2?.status == .absent && s2?.canonicalID == SyntheticRevision.station2 && s2?.provenance.inputSHA256 == SyntheticRevision.inputA, "kept with last sighting")
        try check(first.registry.resolve(SyntheticRevision.key("syn-s2")) == nil, "absent does not resolve")

        let returned = try RevisionReconciliation.reconcile(
            first.registry, with: try SyntheticRevision.input(SyntheticRevision.baseline(SyntheticRevision.inputC), input: SyntheticRevision.inputC),
            previous: try SyntheticRevision.input([SyntheticRevision.baseline[0]])
        )
        try check(returned.summary.reactivated == 2 && returned.registry.resolve(SyntheticRevision.key("syn-s2")) == SyntheticRevision.station2, "\(returned.summary)")
        try check(returned.references.first { $0.key == SyntheticRevision.key("syn-s2") }?.reactivated == true, "reported as reactivated")

        // An older absent reference returns too.
        let s3 = try outcomeOf(try SyntheticRevision.reconcile(SyntheticRevision.baseline + [SyntheticRevision.station("syn-s3")]))
        try check(s3.registry.resolve(SyntheticRevision.key("syn-s3")) == SyntheticRevision.station3 && s3.summary.reactivated == 1, "syn-s3 returns")
    }),
    ("a respelled provider key is new, never a change: the old key goes absent and the new one stays unassigned", { _ in
        // Same code, new stop row: the code stays with its identity, and
        // without a review the new row is not attached to it.
        let respelled = [SyntheticRevision.station("syn-s1x", code: "Q01", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(respelled))
        try check(SyntheticRevision.category(outcome, SyntheticRevision.key("syn-s1x")) == .new && outcome.registry.reference(for: SyntheticRevision.key("syn-s1x")) == nil, "unassigned")
        try check(SyntheticRevision.category(outcome, SyntheticRevision.key("syn-s1")) == .absent, "old key absent")
        try check(SyntheticRevision.category(outcome, SyntheticRevision.key("Q01", .gtfsStopCode)) == .unchanged, "code stays")
        try check(outcome.summary.newUnassigned == 1 && outcome.summary.absent == 1, "\(outcome.summary)")

        // Composed and decomposed spellings are different keys.
        let composed = "syn-\u{30AC}", decomposed = "syn-\u{30AB}\u{3099}"
        let registry = try MappingRegistry(revision: 1, entities: SyntheticRevision.registry.entities, references: SyntheticRevision.registry.references + [
            ProviderReference(canonicalID: SyntheticRevision.station3, sourceID: SyntheticRevision.source, namespace: .gtfsStopID, value: ExactValue(composed)!,
                              status: .active, firstSeenInputSHA256: SyntheticRevision.inputA, provenance: SyntheticRevision.row(composed, "stop_id", SyntheticRevision.inputA), originalNames: []),
        ])
        let previous = try SyntheticRevision.input(
            SyntheticRevision.baseline(SyntheticRevision.inputA) + [SyntheticRevision.station(composed, input: SyntheticRevision.inputA)], input: SyntheticRevision.inputA)
        let spelled = try outcomeOf(try SyntheticRevision.reconcile(SyntheticRevision.baseline + [SyntheticRevision.station(decomposed)], registry: registry, previous: previous))
        try check(SyntheticRevision.category(spelled, SyntheticRevision.key(decomposed)) == .new && SyntheticRevision.category(spelled, SyntheticRevision.key(composed)) == .absent, "exact scalars")
    }),
    ("a reviewed record attaches a new provider key to an existing identity; codes follow it", { _ in
        let respelled = [SyntheticRevision.station("syn-s1x", code: "Q11", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let attach = try SyntheticRevision.record("SYN-REVIEW-A1", SyntheticRevision.key("syn-s1x"), .attach(to: SyntheticRevision.station1))
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(respelled, records: [attach]))
        let attached = outcome.references.first { $0.key == SyntheticRevision.key("syn-s1x") }
        try check(attached?.category == .new && attached?.attachedBy == "SYN-REVIEW-A1" && attached?.canonicalID == SyntheticRevision.station1, "\(String(describing: attached))")
        try check(outcome.registry.reference(for: SyntheticRevision.key("syn-s1x"))?.firstSeenInputSHA256 == SyntheticRevision.inputB, "first seen in this input")
        try check(outcome.registry.resolve(SyntheticRevision.key("Q11", .gtfsStopCode)) == SyntheticRevision.station1, "the new code follows the attached key")
        try check(outcome.summary.newAttached == 1 && outcome.summary.changed == 1 && outcome.summary.absent == 2, "\(outcome.summary)")

        // Without the record, a new code on an unanchored entity stays unassigned.
        let unreviewed = try outcomeOf(try SyntheticRevision.reconcile(respelled))
        try check(unreviewed.summary.newUnassigned == 2 && unreviewed.registry.reference(for: SyntheticRevision.key("Q11", .gtfsStopCode)) == nil, "\(unreviewed.summary)")
    }),
    ("every conflict fails the run together, and nothing is produced", { _ in
        let entities = [
            SyntheticRevision.station("syn-s1", code: "Q02", names: SyntheticRevision.names1),   // competing: stations 1 and 2
            SyntheticRevision.station("syn-s7", code: "Q01"),                                    // split: station 1 in two entities
            SyntheticRevision.station("syn-s9"),                                                 // retired key reappears
            SyntheticRevision.station("syn-s8"),                                                 // retired identity
        ]
        let result = try SyntheticRevision.reconcile(entities)
        guard case .failure(let error) = result, case .conflicts(let conflicts) = error else { throw TestFailure(message: "\(result)") }
        try check(conflicts.map(\.kind) == [.competingIdentities, .retiredIdentity, .retiredValueReappeared, .splitIdentity], "\(conflicts.map(\.kind))")
        try check(error.conflictCounts == ["competingIdentities": 1, "retiredIdentity": 1, "retiredValueReappeared": 1, "splitIdentity": 1], "\(error.conflictCounts)")
        try check(conflicts[3].identities == [SyntheticRevision.station1] && conflicts[3].keys.map(\.value.text) == ["Q01", "Q02", "syn-s1", "syn-s7"], "split: \(conflicts[3].keys.map(\.value.text))")
        try check(conflicts[0].identities == [SyntheticRevision.station1, SyntheticRevision.station2], "merge names both identities")

        // Each alone also fails.
        for entity in entities {
            let single = try SyntheticRevision.reconcile([entity] + (entity == entities[1] ? [SyntheticRevision.station("syn-s1")] : []))
            guard case .failure(.conflicts) = single else { throw TestFailure(message: "not a conflict: \(single)") }
        }
    }),
    ("a reviewed record retires an active or absent reference; other retirements stop with a typed error", { _ in
        let records = [
            try SyntheticRevision.record("SYN-REVIEW-R1", SyntheticRevision.key("syn-s2"), .retire),
            try SyntheticRevision.record("SYN-REVIEW-R2", SyntheticRevision.key("syn-s3"), .retire),
        ]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile([SyntheticRevision.baseline[0]], records: records))
        try check(outcome.registry.reference(for: SyntheticRevision.key("syn-s2"))?.status == .retired(review: "SYN-REVIEW-R1"), "active to retired")
        try check(outcome.registry.reference(for: SyntheticRevision.key("syn-s3"))?.status == .retired(review: "SYN-REVIEW-R2"), "absent to retired")
        try check(outcome.registry.reference(for: SyntheticRevision.key("syn-s2"))?.canonicalID == SyntheticRevision.station2, "kept as history")
        try check(outcome.summary.retired == 2 && outcome.summary.absent == 1 && outcome.summary.stillAbsent == 1, "\(outcome.summary)")

        // The retired value reappearing later is a conflict.
        do {
            _ = try RevisionReconciliation.reconcile(outcome.registry, with: try SyntheticRevision.input(
                SyntheticRevision.baseline(SyntheticRevision.inputC), input: SyntheticRevision.inputC),
                previous: try SyntheticRevision.input([SyntheticRevision.baseline[0]]))
            throw TestFailure(message: "a retired value reappeared without conflict")
        } catch let error as RevisionError {
            try check(error.conflictCounts == ["retiredValueReappeared": 1], "\(error)")
        }

        // Retiring a value present in the input is the reuse case DEC-068
        // leaves open.
        let observed = try SyntheticRevision.record("SYN-REVIEW-R3", SyntheticRevision.key("syn-s1"), .retire)
        try check(try SyntheticRevision.reconcile(records: [observed]) == .failure(.undecided(.retireObservedValue, reviewID: "SYN-REVIEW-R3")), "undecided")
    }),
    ("reviewed records that do not fit the run are refused by review identifier", { _ in
        let respelled = [SyntheticRevision.station("syn-s1x", code: "Q01", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let cases: [(ReviewedRevisionRecord, RevisionError.RecordProblem)] = [
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s1x"), .attach(to: SyntheticRevision.station1), input: SyntheticRevision.inputC), .recordForOtherInput),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s1x", source: SyntheticRevision.otherSource), .attach(to: SyntheticRevision.station1)), .recordForOtherInput),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s2"), .attach(to: SyntheticRevision.station1)), .attachToHeldReference),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s6"), .attach(to: SyntheticRevision.station1)), .attachNotObserved),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("Q01", .gtfsStopCode), .attach(to: SyntheticRevision.station1)), .attachToHeldReference),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s1x"), .attach(to: MintedIdentifier("stn_zzzzzzzzzzzzzzzz")!)), .attachToUnknownIdentity),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s5"), .retire), .retireUnknownReference),
            (try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("syn-s9"), .retire), .retireRetiredReference),
        ]
        for (record, problem) in cases {
            let result = try SyntheticRevision.reconcile(respelled, records: [record])
            try check(result == .failure(.record(problem, reviewID: "SYN-REVIEW-X1")), "\(problem): \(result)")
        }
        let newCode = [SyntheticRevision.station("syn-s1", code: "Q11", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let code = try SyntheticRevision.record("SYN-REVIEW-X1", SyntheticRevision.key("Q11", .gtfsStopCode), .attach(to: SyntheticRevision.station1))
        try check(try SyntheticRevision.reconcile(newCode, records: [code]) == .failure(.record(.attachCode, reviewID: "SYN-REVIEW-X1")), "codes are not attached by record")

        // An attachment that contradicts the entity's held identity is a merge.
        let contradicting = try SyntheticRevision.record("SYN-REVIEW-X2", SyntheticRevision.key("syn-s1x"), .attach(to: SyntheticRevision.station2))
        let merged = try SyntheticRevision.reconcile(respelled, records: [contradicting])
        guard case .failure(let error) = merged else { throw TestFailure(message: "\(merged)") }
        try check(error.conflictCounts["competingIdentities"] == 1, "\(error)")
    }),
    ("observations must come from the identified input, in covered namespaces, once each", { _ in
        func refused(_ entities: [ObservedEntity], covered: Set<ProviderNamespace> = SyntheticRevision.covered) throws -> RevisionInput.Invalid? {
            do { _ = try SyntheticRevision.input(entities, covered: covered); return nil } catch let error as RevisionInput.Invalid { return error }
        }
        let otherInput = SyntheticRevision.station("syn-s1", input: SyntheticRevision.inputC)
        try check(try refused([otherInput]) == .provenanceMismatch, "provenance from another input")
        var mixed = SyntheticRevision.station("syn-s1", names: SyntheticRevision.names1)
        mixed = ObservedEntity(kind: .station, references: [ObservedReference(
            namespace: .gtfsStopID, value: ExactValue("syn-s1")!, provenance: mixed.references[0].provenance,
            originalNames: SyntheticRevision.names("syn-s1", SyntheticRevision.names1, SyntheticRevision.inputA)
        )])
        try check(try refused([mixed]) == .provenanceMismatch, "a name from another input")
        try check(try refused([SyntheticRevision.station("syn-s1"), SyntheticRevision.station("syn-s1")]) == .repeatedReference, "repeated key")
        let codeOnly = ObservedEntity(kind: .station, references: [SyntheticRevision.station("syn-s1", code: "Q01").references[1]])
        try check(try refused([codeOnly]) == .entityWithoutProviderKey, "code alone")
        try check(try refused([ObservedEntity(kind: .line, references: SyntheticRevision.station("syn-s1").references)]) == .kindMismatch, "kind")
        try check(try refused([SyntheticRevision.station("syn-s1", code: "Q01")], covered: [.gtfsStopID]) == .uncoveredNamespace, "uncovered")
        try check(try refused([SyntheticRevision.station("syn-s1", names: [("en", "Synthetic One"), ("en", "Synthetic One")])]) == .repeatedName, "repeated name")
        try check(try refused([ObservedEntity(kind: .station, references: [])]) == .emptyEntity, "empty")
    }),
    ("only covered namespaces of the input's own source can go absent", { _ in
        let stopsOnly = SyntheticRevision.baseline.map { ObservedEntity(kind: $0.kind, references: [$0.references[0]]) }
        let input = try SyntheticRevision.input(stopsOnly, covered: [.gtfsStopID])
        let outcome = try RevisionReconciliation.reconcile(SyntheticRevision.registry, with: input, previous: SyntheticRevision.previousA)
        try check(outcome.registry.reference(for: SyntheticRevision.key("Q01", .gtfsStopCode))?.status == .active, "codes not covered stay as they were")
        try check(outcome.summary.absent == 0 && outcome.summary.unchanged == 2, "\(outcome.summary)")
    }),
    ("the summary holds only counts, the source, hashes, and revisions", { _ in
        let respelled = [SyntheticRevision.station("syn-s1x", code: "Q11", names: SyntheticRevision.names1), SyntheticRevision.baseline[1]]
        let outcome = try outcomeOf(try SyntheticRevision.reconcile(respelled))
        let text = String(decoding: try outcome.summary.encoded(), as: UTF8.self)
        for leaked in ["syn-", "Q0", "Q1", "stn_", "Synthetic One", "合成"] {
            try check(!text.contains(leaked), "summary contains \(leaked)")
        }
        let keys = (try JSONSerialization.jsonObject(with: try outcome.summary.encoded()) as? [String: Any])?.keys.sorted()
        try check(keys == ["absent", "changed", "inputSHA256", "newAttached", "newUnassigned", "previousRevision", "reactivated", "retired", "revision", "routeChanged", "sourceID", "stillAbsent", "unchanged"], "\(String(describing: keys))")
    }),
]
