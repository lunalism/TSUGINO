import Foundation
import Testing
@testable import TSUGINO

/// The DEC-068 registry, provider-reference, and identifier-form contracts, on
/// invented records only. Identifiers are hand-written in the §A form; sources
/// are `SYN-…`, provider values `syn-…`, and digests repeat one hexadecimal
/// digit. No identifier here is a production identifier, and nothing here
/// mints: minting is tool-only.
struct MappingRegistryTests {

    // MARK: - Fixtures

    private static let digestA = String(repeating: "a", count: 64)
    private static let digestB = String(repeating: "b", count: 64)
    private static let lineQ = MintedIdentifier("lin_0000000000000001")!
    private static let lineR = MintedIdentifier("lin_0000000000000002")!
    private static let station = MintedIdentifier("stn_0000000000000003")!
    private static let railwayOperator = MintedIdentifier("opr_0000000000000004")!

    private static func value(_ text: String) -> ExactValue { ExactValue(text)! }

    private static func gtfsSource(_ key: String) throws -> SourceReference {
        try SourceReference(
            inputSHA256: digestA,
            member: .init(name: "routes.txt", sha256: digestB),
            table: "routes",
            recordIndex: nil,
            field: "route_id",
            providerKey: value(key)
        )
    }

    private static func name(_ language: String, _ text: String) -> OriginalName {
        OriginalName(language: value(language), value: value(text), source: try! gtfsSource("syn-route-q"))
    }

    private static func reference(
        _ id: MintedIdentifier = lineQ,
        _ text: String = "syn-route-q",
        namespace: ProviderNamespace = .gtfsRouteID,
        status: ProviderReferenceStatus = .active,
        names: [OriginalName] = [],
        attachedBy: String? = nil
    ) throws -> ProviderReference {
        try ProviderReference(
            canonicalID: id,
            sourceID: "SYN-01/synthetic-gtfs",
            namespace: namespace,
            value: value(text),
            status: status,
            firstSeenInputSHA256: digestA,
            provenance: gtfsSource(text),
            originalNames: names,
            attachedBy: attachedBy
        )
    }

    private static func registry(
        entities: [CanonicalEntity] = [CanonicalEntity(id: lineQ, status: .active)],
        references: [ProviderReference]
    ) throws -> MappingRegistry {
        try MappingRegistry(revision: 1, entities: entities, references: references)
    }

    /// Decodes JSON text, expecting `dataCorrupted` whose description names
    /// `reason`.
    private static func expectCorrupted(_ json: String, _ reason: String, sourceLocation: SourceLocation = #_sourceLocation) {
        do {
            _ = try MappingRegistry.decoded(from: Data(json.utf8))
            Issue.record("decoded, expected \(reason)", sourceLocation: sourceLocation)
        } catch DecodingError.dataCorrupted(let context) {
            #expect(context.debugDescription == reason, sourceLocation: sourceLocation)
        } catch {
            Issue.record("expected dataCorrupted \(reason), got \(error)", sourceLocation: sourceLocation)
        }
    }

    /// A valid encoded registry as a mutable JSON object.
    private static func jsonObject(_ registry: MappingRegistry) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: registry.encoded()) as! [String: Any]
    }

    private static func text(_ object: Any) throws -> String {
        String(decoding: try JSONSerialization.data(withJSONObject: object), as: UTF8.self)
    }

    // MARK: - Identifier form

    @Test(arguments: ["stn_0123456789abcdef", "lin_ghjkmnpqrstvwxyz", "opr_zzzzzzzzzzzzzzzz"])
    func identifierInTheExactFormIsAccepted(raw: String) throws {
        let id = try #require(MintedIdentifier(raw))
        #expect(id.rawValue == raw)
        #expect(id.body.utf8.count == 16)
    }

    @Test(arguments: [
        "", "lin_", "lin_000000000000000", "lin_00000000000000000", // lengths
        "LIN_0000000000000000", "lin_000000000000000A",            // uppercase
        "lin_000000000000000i", "lin_000000000000000l", "lin_000000000000000o", "lin_000000000000000u",
        "lin-0000000000000000", "lin00000000000000000", "trp_0000000000000000", // separator, prefix
        "lin_00000000 0000000", "lin_000000000000000０", "lin_00000000000000\u{0301}0", // space, full width, combining
    ])
    func identifierOutsideTheFormIsRejected(raw: String) {
        #expect(MintedIdentifier(raw) == nil)
    }

    /// DEC-051 is unchanged: every minted form is also a valid Domain
    /// identifier, and the Domain types still accept values outside the form.
    @Test func mintedFormsAreValidDomainIdentifiersAndDomainValidityIsUnchanged() {
        #expect(StationID(Self.station.rawValue)?.rawValue == Self.station.rawValue)
        #expect(LineID(Self.lineQ.rawValue)?.rawValue == Self.lineQ.rawValue)
        #expect(OperatorID(Self.railwayOperator.rawValue)?.rawValue == Self.railwayOperator.rawValue)
        #expect(StationID("Any Non-Blank Value")?.rawValue == "Any Non-Blank Value")
        #expect(MintedIdentifier("Any Non-Blank Value") == nil)
    }

    // MARK: - Exact values

    /// A composed and a decomposed spelling are distinct values, although
    /// `String` itself calls them equal; each survives a round trip scalar
    /// for scalar.
    @Test func exactValuesCompareScalarByScalar() throws {
        let composed = "syn-\u{304C}"          // が
        let decomposed = "syn-\u{304B}\u{3099}" // か + combining voiced mark
        #expect(composed == decomposed, "String equality is canonical equivalence")
        #expect(Self.value(composed) != Self.value(decomposed))
        #expect(Set([Self.value(composed), Self.value(decomposed)]).count == 2)
        #expect(Self.value("syn-ヶ") != Self.value("syn-ケ"))

        let registry = try Self.registry(
            entities: [CanonicalEntity(id: Self.lineQ, status: .active), CanonicalEntity(id: Self.lineR, status: .active)],
            references: [try Self.reference(Self.lineQ, composed), try Self.reference(Self.lineR, decomposed)]
        )
        let decoded = try MappingRegistry.decoded(from: registry.encoded())
        let values = decoded.references.map { Array($0.value.text.unicodeScalars) }
        #expect(values.contains(Array(composed.unicodeScalars)))
        #expect(values.contains(Array(decomposed.unicodeScalars)))
        #expect(decoded.resolve(ProviderReferenceKey(sourceID: "SYN-01/synthetic-gtfs", namespace: .gtfsRouteID, value: Self.value(decomposed))) == Self.lineR)
    }

    @Test(arguments: ["", " ", "\t\n", "\u{3000}"])
    func blankValuesAreRejected(text: String) {
        #expect(ExactValue(text) == nil)
    }

    @Test func valuesAreKeptAsWrittenWithoutTrimming() {
        #expect(ExactValue(" syn-q ")?.text == " syn-q ")
    }

    // MARK: - Status

    @Test(arguments: [
        ProviderReferenceStatus.active, .absent, .retired(review: "SYN-REVIEW-1"),
    ])
    func everyStatusRoundTrips(status: ProviderReferenceStatus) throws {
        let entities: [CanonicalEntity] = status == .active
            ? [CanonicalEntity(id: Self.lineQ, status: .active)]
            : [CanonicalEntity(id: Self.lineQ, status: .retired(successors: [Self.lineR])), CanonicalEntity(id: Self.lineR, status: .active)]
        let registry = try Self.registry(entities: entities, references: [try Self.reference(status: status)])

        let decoded = try MappingRegistry.decoded(from: registry.encoded())

        #expect(decoded.references.map(\.status) == [status])
        #expect(decoded.entities == registry.entities)
    }

    @Test func onlyAnActiveReferenceResolves() throws {
        let registry = try Self.registry(
            entities: [CanonicalEntity(id: Self.lineQ, status: .active), CanonicalEntity(id: Self.lineR, status: .active)],
            references: [
                try Self.reference(Self.lineQ, "syn-route-q"),
                try Self.reference(Self.lineR, "syn-route-r", status: .absent),
            ]
        )
        let active = ProviderReferenceKey(sourceID: "SYN-01/synthetic-gtfs", namespace: .gtfsRouteID, value: Self.value("syn-route-q"))
        let absent = ProviderReferenceKey(sourceID: "SYN-01/synthetic-gtfs", namespace: .gtfsRouteID, value: Self.value("syn-route-r"))

        #expect(registry.resolve(active) == Self.lineQ)
        #expect(registry.resolve(absent) == nil, "an absent reference is history, not current")
        #expect(registry.reference(for: absent)?.canonicalID == Self.lineR, "history is kept")
    }

    @Test(arguments: [
        #"{"state": "retired"}"#, #"{"state": "retired", "review": " "}"#,
        #"{"state": "active", "review": "SYN-REVIEW-1"}"#, #"{"state": "current"}"#,
    ])
    func malformedStatusIsRejected(status: String) throws {
        var object = try Self.jsonObject(Self.registry(references: [try Self.reference()]))
        var references = object["references"] as! [[String: Any]]
        references[0]["status"] = try JSONSerialization.jsonObject(with: Data(status.utf8))
        object["references"] = references

        Self.expectCorrupted(try Self.text(object), "invalidStatus")
    }

    // MARK: - Registry invariants

    /// Version 1 is rejected too: it predates `attachedBy`, and provisional
    /// registries are regenerated, not migrated.
    @Test(arguments: [0, 1, 3, -1])
    func unknownSchemaVersionIsRejected(version: Int) throws {
        var object = try Self.jsonObject(Self.registry(references: []))
        object["schemaVersion"] = version

        Self.expectCorrupted(try Self.text(object), "unsupportedSchemaVersion")
    }

    @Test func missingSchemaVersionIsRejected() throws {
        var object = try Self.jsonObject(Self.registry(references: []))
        object.removeValue(forKey: "schemaVersion")

        #expect(throws: DecodingError.self) { try MappingRegistry.decoded(from: Data(try Self.text(object).utf8)) }
    }

    @Test(arguments: ["LIN_0000000000000001", "lin_000000000000000l", "syn-line"])
    func malformedIdentifierIsRejected(raw: String) throws {
        var object = try Self.jsonObject(Self.registry(references: []))
        object["entities"] = [["id": raw, "state": "active"]]

        Self.expectCorrupted(try Self.text(object), "malformedIdentifier")
    }

    @Test func repeatedIdentifierIsRejected() {
        #expect(throws: MappingRegistryError.repeatedIdentifier) {
            try MappingRegistry(revision: 1, entities: [
                CanonicalEntity(id: Self.lineQ, status: .active), CanonicalEntity(id: Self.lineQ, status: .active),
            ], references: [])
        }
    }

    @Test func referenceBoundToTwoIdentifiersIsRejected() throws {
        let entities = [CanonicalEntity(id: Self.lineQ, status: .active), CanonicalEntity(id: Self.lineR, status: .active)]
        #expect(throws: MappingRegistryError.referenceBoundToTwoIdentifiers) {
            try MappingRegistry(revision: 1, entities: entities, references: [
                try Self.reference(Self.lineQ, "syn-route-q"), try Self.reference(Self.lineR, "syn-route-q"),
            ])
        }
        #expect(throws: MappingRegistryError.repeatedReference) {
            try MappingRegistry(revision: 1, entities: entities, references: [
                try Self.reference(Self.lineQ, "syn-route-q"), try Self.reference(Self.lineQ, "syn-route-q"),
            ])
        }
    }

    @Test func registryRulesAreEnforcedOnDecodingToo() throws {
        let valid = try Self.registry(
            entities: [CanonicalEntity(id: Self.lineQ, status: .active), CanonicalEntity(id: Self.lineR, status: .active)],
            references: [try Self.reference(Self.lineQ, "syn-route-q")]
        )
        var object = try Self.jsonObject(valid)
        var references = object["references"] as! [[String: Any]]
        var second = references[0]
        second["canonicalID"] = Self.lineR.rawValue
        references.append(second)
        object["references"] = references

        Self.expectCorrupted(try Self.text(object), "referenceBoundToTwoIdentifiers")
    }

    @Test func referenceRulesAreEnforced() throws {
        #expect(throws: MappingRegistryError.referenceToUnknownIdentifier) {
            try Self.registry(entities: [], references: [try Self.reference()])
        }
        #expect(throws: MappingRegistryError.referenceKindMismatch) {
            try Self.registry(references: [try Self.reference(namespace: .gtfsStopID)])
        }
        #expect(throws: MappingRegistryError.activeReferenceToRetiredIdentifier) {
            try Self.registry(
                entities: [CanonicalEntity(id: Self.lineQ, status: .retired(successors: [Self.lineR])), CanonicalEntity(id: Self.lineR, status: .active)],
                references: [try Self.reference()]
            )
        }
        #expect(throws: MappingRegistryError.negativeRevision) {
            try MappingRegistry(revision: -1, entities: [], references: [])
        }
    }

    @Test(arguments: [
        [MintedIdentifier](), [lineQ], [station], [MintedIdentifier("lin_0000000000000009")!], [lineR, lineR],
    ])
    func invalidSuccessorsAreRejected(successors: [MintedIdentifier]) {
        #expect(throws: MappingRegistryError.invalidSuccessors) {
            try MappingRegistry(revision: 1, entities: [
                CanonicalEntity(id: Self.lineQ, status: .retired(successors: successors)),
                CanonicalEntity(id: Self.lineR, status: .active),
                CanonicalEntity(id: Self.station, status: .active),
            ], references: [])
        }
    }

    @Test func blankOriginalValuesAreRejectedOnDecoding() throws {
        var object = try Self.jsonObject(Self.registry(references: [try Self.reference()]))
        var references = object["references"] as! [[String: Any]]
        references[0]["value"] = " "
        object["references"] = references

        Self.expectCorrupted(try Self.text(object), "blankValue")

        var named = try Self.jsonObject(Self.registry(references: [
            try Self.reference(names: [Self.name("ja", "合成線")]),
        ]))
        var namedReferences = named["references"] as! [[String: Any]]
        namedReferences[0]["originalNames"] = [["language": "ja", "value": ""]]
        named["references"] = namedReferences

        Self.expectCorrupted(try Self.text(named), "blankValue")
    }

    /// When a provider changes a name, the new value is recorded beside the
    /// old, each with its own source (DEC-068 §C3, §E3). Only an exact repeat
    /// is rejected.
    @Test func originalNamesKeepHistoryWithPerValueSources() throws {
        let older = try SourceReference(
            inputSHA256: Self.digestA, member: .init(name: "translations.txt", sha256: Self.digestB),
            table: "translations", recordIndex: nil, field: "translation", providerKey: Self.value("syn-q")
        )
        let newer = try SourceReference(
            inputSHA256: Self.digestB, member: .init(name: "translations.txt", sha256: Self.digestA),
            table: "translations", recordIndex: nil, field: "translation", providerKey: Self.value("syn-q")
        )
        let names = [
            OriginalName(language: Self.value("ja"), value: Self.value("合成線"), source: older),
            OriginalName(language: Self.value("en"), value: Self.value("Synthetic Line (renamed)"), source: newer),
            OriginalName(language: Self.value("en"), value: Self.value("Synthetic Line"), source: older),
        ]
        let reference = try Self.reference(names: names)

        #expect(reference.originalNames.map(\.language.text) == ["en", "en", "ja"])
        #expect(reference.originalNames.map(\.value.text) == ["Synthetic Line", "Synthetic Line (renamed)", "合成線"])
        #expect(reference.originalNames.map(\.source.inputSHA256) == [Self.digestA, Self.digestB, Self.digestA])
        #expect(try Self.reference(names: names.reversed()).originalNames == reference.originalNames)

        let registry = try Self.registry(references: [reference])
        #expect(try MappingRegistry.decoded(from: registry.encoded()) == registry)

        #expect(throws: ProviderReference.Invalid.repeatedOriginalName) {
            try Self.reference(names: names + [names[0]])
        }
    }

    @Test func provenanceRulesAreEnforced() throws {
        #expect(throws: SourceReference.Invalid.malformedDigest) {
            try SourceReference(inputSHA256: String(repeating: "A", count: 64), member: nil, table: nil, recordIndex: 0, field: "@id", providerKey: Self.value("syn:R"))
        }
        #expect(throws: SourceReference.Invalid.mixedPosition) {
            try SourceReference(inputSHA256: Self.digestA, member: nil, table: "routes", recordIndex: nil, field: "route_id", providerKey: Self.value("syn-q"))
        }
        #expect(throws: SourceReference.Invalid.negativeRecordIndex) {
            try SourceReference(inputSHA256: Self.digestA, member: nil, table: nil, recordIndex: -1, field: "@id", providerKey: Self.value("syn:R"))
        }
        let railway = try SourceReference(inputSHA256: Self.digestA, member: nil, table: nil, recordIndex: 2, field: "@id", providerKey: Self.value("syn:R"))
        #expect(railway.recordIndex == 2 && railway.member == nil)
    }

    @Test(arguments: ["", " ", "SYN 01/gtfs", "SYN-01/ｇｔｆｓ", "SYN-01/gtfs\u{0301}"])
    func sourceIdentifierMustBePrintableASCII(sourceID: String) {
        #expect(throws: ProviderReference.Invalid.malformedSourceID) {
            try ProviderReference(
                canonicalID: Self.lineQ, sourceID: sourceID, namespace: .gtfsRouteID, value: Self.value("syn-q"),
                status: .active, firstSeenInputSHA256: Self.digestA, provenance: try Self.gtfsSource("syn-q"), originalNames: []
            )
        }
    }

    @Test func unknownNamespaceIsRejected() throws {
        var object = try Self.jsonObject(Self.registry(references: [try Self.reference()]))
        var references = object["references"] as! [[String: Any]]
        references[0]["namespace"] = "gtfs.trip_id"
        object["references"] = references

        #expect(throws: DecodingError.self) { try MappingRegistry.decoded(from: Data(try Self.text(object).utf8)) }
    }

    // MARK: - Review fixes

    private static let railwaySource: SourceReference = try! SourceReference(
        inputSHA256: digestA, member: nil, table: nil, recordIndex: 0, field: "@id", providerKey: ExactValue("syn:R")!
    )

    private static func encodedText(_ registry: MappingRegistry) throws -> String {
        String(decoding: try registry.encoded(), as: UTF8.self)
    }

    /// A key the schema does not define is rejected at every level, so
    /// re-encoding can never silently drop it.
    @Test(arguments: [
        #""revision" : 1"#, #""id" : "lin_0000000000000001""#, #""canonicalID" : "lin_0000000000000001""#,
        #""inputSHA256" : ""#, #""sha256" : ""#, #""language" : "ja""#, #""state" : "active""#,
    ])
    func unknownKeyIsRejectedAtEveryLevel(anchor: String) throws {
        let registry = try Self.registry(references: [
            try Self.reference(names: [Self.name("ja", "合成線")]),
        ])
        let text = try Self.encodedText(registry)
        let range = try #require(text.range(of: anchor))
        let mutated = text.replacingCharacters(in: range.lowerBound..<range.lowerBound, with: #""syn-extra" : 1, "#)

        Self.expectCorrupted(mutated, "unknownKey")
    }

    /// The platform decoder would keep one value of a repeated key; the
    /// registry decoder rejects the file instead, including an escaped
    /// spelling of the same key.
    @Test(arguments: [
        #""canonicalID" : "lin_0000000000000002", "canonicalID""#,
        #""canonicalID" : "lin_0000000000000002", "canonicalID""#,
        #""revision" : 7, "revision""#,
    ])
    func repeatedKeyIsRejected(replacement: String) throws {
        let registry = try Self.registry(
            entities: [CanonicalEntity(id: Self.lineQ, status: .active), CanonicalEntity(id: Self.lineR, status: .active)],
            references: [try Self.reference()]
        )
        let text = try Self.encodedText(registry)
        let target = replacement.contains("revision") ? #""revision""# : #""canonicalID""#
        let range = try #require(text.range(of: target))
        let mutated = text.replacingCharacters(in: range, with: replacement)

        Self.expectCorrupted(mutated, "repeatedKey")
    }

    /// There is no way around the repeated-key check: the registry is not
    /// `Decodable`, so only `decoded(from:)` can read one.
    @Test func registryCanOnlyBeReadThroughItsCheckedDecoder() {
        #expect(!((MappingRegistry.self as Any.Type) is any Decodable.Type))
        #expect((MappingRegistry.self as Any.Type) is any Encodable.Type)
    }

    @Test(arguments: ["", " ", "SYN REVIEW", "SYN-レビュー"])
    func retirementReviewMustBeWellFormedWhenConstructed(review: String) {
        #expect(throws: ProviderReference.Invalid.malformedReview) {
            try Self.reference(status: .retired(review: review))
        }
    }

    /// Schema v2: a reference attached by a reviewed record names that review
    /// for good; it round-trips, and a reference without one encodes no key.
    @Test func attachingReviewRoundTrips() throws {
        let attached = try Self.registry(references: [try Self.reference(attachedBy: "SYN-REVIEW-A1")])
        let bytes = try attached.encoded()
        #expect(try MappingRegistry.decoded(from: bytes).references[0].attachedBy == "SYN-REVIEW-A1")
        #expect(String(decoding: bytes, as: UTF8.self).contains(#""attachedBy" : "SYN-REVIEW-A1""#))
        let plain = try Self.registry(references: [try Self.reference()])
        #expect(!String(decoding: try plain.encoded(), as: UTF8.self).contains("attachedBy"))
        #expect(try MappingRegistry.decoded(from: try plain.encoded()).references[0].attachedBy == nil)
    }

    @Test(arguments: ["", " ", "SYN REVIEW", "SYN-レビュー"])
    func attachingReviewMustBeWellFormed(review: String) throws {
        #expect(throws: ProviderReference.Invalid.malformedReview) { try Self.reference(attachedBy: review) }
        var object = try Self.jsonObject(Self.registry(references: [try Self.reference(attachedBy: "SYN-REVIEW-A1")]))
        var references = object["references"] as! [[String: Any]]
        references[0]["attachedBy"] = review
        object["references"] = references
        Self.expectCorrupted(try Self.text(object), "malformedReview")
    }

    /// Nothing that can be constructed fails to decode.
    @Test func everyConstructibleRegistryRoundTrips() throws {
        let registry = try Self.registry(
            entities: [CanonicalEntity(id: Self.lineQ, status: .retired(successors: [Self.lineR])), CanonicalEntity(id: Self.lineR, status: .active)],
            references: [try Self.reference(status: .retired(review: "SYN-REVIEW-1"))]
        )
        #expect(try MappingRegistry.decoded(from: registry.encoded()) == registry)
    }

    @Test func provenanceMustMatchTheNamespace() throws {
        #expect(throws: ProviderReference.Invalid.provenanceMismatch) {
            try ProviderReference(
                canonicalID: Self.lineQ, sourceID: "SYN-01/g", namespace: .gtfsRouteID, value: Self.value("syn-q"),
                status: .active, firstSeenInputSHA256: Self.digestA, provenance: Self.railwaySource, originalNames: []
            )
        }
        #expect(throws: ProviderReference.Invalid.provenanceMismatch) {
            try ProviderReference(
                canonicalID: Self.lineQ, sourceID: "SYN-03/r", namespace: .odptRailwayID, value: Self.value("syn:R"),
                status: .active, firstSeenInputSHA256: Self.digestA, provenance: try Self.gtfsSource("syn:R"), originalNames: []
            )
        }
        let railway = try ProviderReference(
            canonicalID: Self.lineQ, sourceID: "SYN-03/r", namespace: .odptRailwayID, value: Self.value("syn:R"),
            status: .active, firstSeenInputSHA256: Self.digestA, provenance: Self.railwaySource, originalNames: []
        )
        #expect(railway.provenance.recordIndex == 0)
    }

    /// Every original name's source must match the namespace too.
    @Test func originalNameSourceMustMatchTheNamespace() throws {
        let railwayName = OriginalName(language: Self.value("en"), value: Self.value("Synthetic"), source: Self.railwaySource)
        #expect(throws: ProviderReference.Invalid.provenanceMismatch) {
            try Self.reference(names: [railwayName])
        }

        var object = try Self.jsonObject(Self.registry(references: [try Self.reference(names: [Self.name("en", "Synthetic")])]))
        var references = object["references"] as! [[String: Any]]
        var names = references[0]["originalNames"] as! [[String: Any]]
        names[0]["source"] = ["inputSHA256": Self.digestA, "recordIndex": 0, "field": "@id", "providerKey": "syn:R"]
        references[0]["originalNames"] = names
        object["references"] = references

        Self.expectCorrupted(try Self.text(object), "provenanceMismatch")
    }

    @Test func provenanceMismatchIsRejectedOnDecoding() throws {
        var object = try Self.jsonObject(Self.registry(references: [try Self.reference()]))
        var references = object["references"] as! [[String: Any]]
        references[0]["provenance"] = ["inputSHA256": Self.digestA, "recordIndex": 0, "field": "@id", "providerKey": "syn:R"]
        object["references"] = references

        Self.expectCorrupted(try Self.text(object), "provenanceMismatch")
    }

    @Test func successorCyclesAreRejectedAndChainsAccepted() throws {
        let lineS = MintedIdentifier("lin_0000000000000005")!
        #expect(throws: MappingRegistryError.successorCycle) {
            try MappingRegistry(revision: 1, entities: [
                CanonicalEntity(id: Self.lineQ, status: .retired(successors: [Self.lineR])),
                CanonicalEntity(id: Self.lineR, status: .retired(successors: [Self.lineQ])),
            ], references: [])
        }
        #expect(throws: MappingRegistryError.successorCycle) {
            try MappingRegistry(revision: 1, entities: [
                CanonicalEntity(id: Self.lineQ, status: .retired(successors: [Self.lineR])),
                CanonicalEntity(id: Self.lineR, status: .retired(successors: [lineS])),
                CanonicalEntity(id: lineS, status: .retired(successors: [Self.lineQ])),
            ], references: [])
        }
        let chain = try MappingRegistry(revision: 1, entities: [
            CanonicalEntity(id: Self.lineQ, status: .retired(successors: [Self.lineR])),
            CanonicalEntity(id: Self.lineR, status: .retired(successors: [lineS])),
            CanonicalEntity(id: lineS, status: .active),
        ], references: [])
        #expect(chain.entities.count == 3)
    }

    @Test(arguments: [("routes", "route id"), ("ルート", "route_id"), ("routes", "")])
    func schemaNamesMustBePrintableASCII(table: String, field: String) {
        #expect(throws: SourceReference.Invalid.malformedToken) {
            try SourceReference(
                inputSHA256: Self.digestA, member: .init(name: "routes.txt", sha256: Self.digestB),
                table: table, recordIndex: nil, field: field, providerKey: Self.value("syn-q")
            )
        }
    }

    // MARK: - Deterministic encoding

    @Test func encodingIsDeterministicWhateverTheInputOrder() throws {
        let entities = [
            CanonicalEntity(id: Self.lineR, status: .active), CanonicalEntity(id: Self.station, status: .active),
            CanonicalEntity(id: Self.lineQ, status: .active),
        ]
        let references = [
            try Self.reference(Self.lineR, "syn-route-r"), try Self.reference(Self.lineQ, "syn-route-q"),
            try Self.reference(Self.station, "syn-stop-1", namespace: .gtfsStopID),
        ]
        let forward = try MappingRegistry(revision: 4, entities: entities, references: references)
        let backward = try MappingRegistry(revision: 4, entities: entities.reversed(), references: references.reversed())

        let bytes = try forward.encoded()
        #expect(bytes == (try backward.encoded()))
        #expect(bytes == (try MappingRegistry.decoded(from: bytes).encoded()))
        #expect(forward.entities.map(\.id) == [Self.lineQ, Self.lineR, Self.station])
        #expect(try MappingRegistry.decoded(from: bytes) == forward)
    }

    @Test func encodedRegistryCarriesItsSchemaVersion() throws {
        let object = try Self.jsonObject(MappingRegistry.empty)
        #expect(object["schemaVersion"] as? Int == MappingRegistry.schemaVersion)
        #expect(object["revision"] as? Int == 0)
    }

    /// Registry values are provider text: an error names only the broken rule.
    @Test func errorsNameRulesNotValues() throws {
        var object = try Self.jsonObject(Self.registry(references: [try Self.reference(Self.lineQ, "syn-secret-value")]))
        var references = object["references"] as! [[String: Any]]
        var second = references[0]
        second["canonicalID"] = Self.lineR.rawValue
        references.append(second)
        object["references"] = references
        object["entities"] = [["id": Self.lineQ.rawValue, "state": "active"], ["id": Self.lineR.rawValue, "state": "active"]]

        do {
            _ = try MappingRegistry.decoded(from: Data(try Self.text(object).utf8))
            Issue.record("decoded")
        } catch {
            #expect(!String(describing: error).contains("syn-secret-value"))
        }
    }
}
