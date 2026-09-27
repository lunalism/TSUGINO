import Foundation

// Provider-reference records (DEC-068 §C, §E1): the provider values that
// identify a canonical entity, with their provenance and status.
//
// Values are provider text and may be Tokyo Metro-derived, so no error in this
// file names a value; errors name only the broken rule.

/// A provider value exactly as the reader decoded it from UTF-8 (DEC-068 §C2):
/// the same Unicode scalars, with no normalization, trimming, or case or width
/// folding. Equality and hashing compare scalar by scalar, so a composed and a
/// decomposed spelling are different values — unlike `String`'s own `==`,
/// which treats canonically equivalent strings as equal. Source bytes are not
/// kept; `SourceReference` identifies them instead.
nonisolated struct ExactValue: Hashable, Comparable, Sendable, Codable {
    let text: String

    /// Fails for a blank value: empty or only whitespace (DEC-068 §B4).
    init?(_ text: String) {
        guard !text.allSatisfy(\.isWhitespace) else { return nil }
        self.text = text
    }

    static func == (lhs: ExactValue, rhs: ExactValue) -> Bool {
        lhs.text.unicodeScalars.elementsEqual(rhs.text.unicodeScalars)
    }

    func hash(into hasher: inout Hasher) {
        for scalar in text.unicodeScalars { hasher.combine(scalar.value) }
    }

    /// UTF-8 byte order, which is scalar order: never locale or collation.
    static func < (lhs: ExactValue, rhs: ExactValue) -> Bool {
        lhs.text.utf8.lexicographicallyPrecedes(rhs.text.utf8)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let value = ExactValue(try container.decode(String.self)) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "blankValue")
        }
        self = value
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(text)
    }
}

/// Where a provider value comes from (DEC-068 §C1), and the entity kind it can
/// identify.
nonisolated enum ProviderNamespace: String, CaseIterable, Hashable, Comparable, Sendable, Codable {
    case gtfsAgencyID = "gtfs.agency_id"
    case gtfsRouteID = "gtfs.route_id"
    case gtfsStopID = "gtfs.stop_id"
    case gtfsStopCode = "gtfs.stop_code"
    case odptOperator = "odpt.operator"
    case odptRailwayID = "odpt.railway.id"
    case odptRailwaySameAs = "odpt.railway.sameAs"
    case odptRailwayLineCode = "odpt.railway.lineCode"

    var kind: CanonicalKind {
        switch self {
        case .gtfsAgencyID, .odptOperator: .railwayOperator
        case .gtfsRouteID, .odptRailwayID, .odptRailwaySameAs, .odptRailwayLineCode: .line
        case .gtfsStopID, .gtfsStopCode: .station
        }
    }

    /// A GTFS namespace, as opposed to an ODPT one.
    var isGTFS: Bool {
        switch self {
        case .gtfsAgencyID, .gtfsRouteID, .gtfsStopID, .gtfsStopCode: true
        case .odptOperator, .odptRailwayID, .odptRailwaySameAs, .odptRailwayLineCode: false
        }
    }

    static func < (lhs: ProviderNamespace, rhs: ProviderNamespace) -> Bool {
        lhs.rawValue.utf8.lexicographicallyPrecedes(rhs.rawValue.utf8)
    }
}

/// Checks shared by the record types in this folder.
nonisolated enum MappingText {
    /// Printable ASCII without spaces. Project and schema text — source
    /// identifiers, member, table, and field names, review identifiers — is
    /// held to this, so two such values can never differ only in Unicode
    /// spelling, and `==` always agrees with the encoded bytes.
    static func isToken(_ text: String) -> Bool {
        !text.isEmpty && text.utf8.allSatisfy { (0x21...0x7E).contains($0) }
    }

    /// Rejects any key the schema does not define, so decoding never drops a
    /// field that re-encoding would then silently lose (Rule 39).
    static func rejectUnknownKeys<Key: CodingKey & CaseIterable>(_ decoder: any Decoder, _ keys: Key.Type) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        let known = Set(Key.allCases.map(\.stringValue))
        guard container.allKeys.allSatisfy({ known.contains($0.stringValue) }) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "unknownKey"))
        }
    }

    /// A SHA-256 digest as 64 lowercase hexadecimal characters.
    static func isSHA256(_ text: String) -> Bool {
        let bytes = Array(text.utf8)
        return bytes.count == 64 && bytes.allSatisfy {
            (UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0) || (UInt8(ascii: "a")...UInt8(ascii: "f")).contains($0)
        }
    }

    static func corrupted<Key: CodingKey>(_ reason: String, _ container: KeyedDecodingContainer<Key>) -> DecodingError {
        DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: reason))
    }
}

/// Any key, for finding keys a schema does not define.
nonisolated struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

/// Identifies the source bytes a value came from, without containing them
/// (DEC-068 §C3). For GTFS: the archive SHA-256, the member name and SHA-256
/// from the intake manifest, and the table. For `odpt:Railway`: the input
/// SHA-256 and the record index. In both cases: the field and the row's
/// provider key.
nonisolated struct SourceReference: Hashable, Sendable, Codable {
    nonisolated struct Member: Hashable, Sendable, Codable {
        let name: String
        let sha256: String

        init(name: String, sha256: String) {
            self.name = name
            self.sha256 = sha256
        }

        private enum CodingKeys: String, CodingKey, CaseIterable { case name, sha256 }

        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.init(name: try container.decode(String.self, forKey: .name), sha256: try container.decode(String.self, forKey: .sha256))
        }
    }

    let inputSHA256: String
    let member: Member?
    let table: String?
    let recordIndex: Int?
    let field: String
    let providerKey: ExactValue

    enum Invalid: Error, Hashable, Sendable {
        case malformedDigest
        /// A member, table, or field name that is not printable ASCII.
        case malformedToken
        /// A GTFS reference names a member and a table; an `odpt:Railway`
        /// reference names a record index and neither of the others.
        case mixedPosition
        case negativeRecordIndex
    }

    /// Whether this is the GTFS form (member and table) rather than the
    /// `odpt:Railway` form (record index).
    var isGTFSPosition: Bool { member != nil }

    /// A total order over every field — text by UTF-8 bytes, the record
    /// index numerically, an absent part first — so records that hold several
    /// source references sort the same way every time.
    static func precedes(_ lhs: SourceReference, _ rhs: SourceReference) -> Bool {
        func order(_ l: String?, _ r: String?) -> Bool? {
            let left = Array((l ?? "").utf8), right = Array((r ?? "").utf8)
            return left == right ? nil : left.lexicographicallyPrecedes(right)
        }
        if let result = order(lhs.inputSHA256, rhs.inputSHA256) { return result }
        if let result = order(lhs.member?.name, rhs.member?.name) { return result }
        if let result = order(lhs.member?.sha256, rhs.member?.sha256) { return result }
        if let result = order(lhs.table, rhs.table) { return result }
        if lhs.recordIndex != rhs.recordIndex { return (lhs.recordIndex ?? -1) < (rhs.recordIndex ?? -1) }
        if let result = order(lhs.field, rhs.field) { return result }
        return lhs.providerKey < rhs.providerKey
    }

    init(
        inputSHA256: String,
        member: Member?,
        table: String?,
        recordIndex: Int?,
        field: String,
        providerKey: ExactValue
    ) throws(Invalid) {
        guard MappingText.isSHA256(inputSHA256) else { throw .malformedDigest }
        if let member {
            guard MappingText.isSHA256(member.sha256) else { throw .malformedDigest }
            guard MappingText.isToken(member.name) else { throw .malformedToken }
        }
        guard (member != nil && table != nil && recordIndex == nil) || (member == nil && table == nil && recordIndex != nil)
        else { throw .mixedPosition }
        if let table { guard MappingText.isToken(table) else { throw .malformedToken } }
        if let recordIndex { guard recordIndex >= 0 else { throw .negativeRecordIndex } }
        guard MappingText.isToken(field) else { throw .malformedToken }
        self.inputSHA256 = inputSHA256
        self.member = member
        self.table = table
        self.recordIndex = recordIndex
        self.field = field
        self.providerKey = providerKey
    }

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case inputSHA256, member, table, recordIndex, field, providerKey
    }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            try self.init(
                inputSHA256: container.decode(String.self, forKey: .inputSHA256),
                member: container.decodeIfPresent(Member.self, forKey: .member),
                table: container.decodeIfPresent(String.self, forKey: .table),
                recordIndex: container.decodeIfPresent(Int.self, forKey: .recordIndex),
                field: container.decode(String.self, forKey: .field),
                providerKey: container.decode(ExactValue.self, forKey: .providerKey)
            )
        } catch let invalid as Invalid {
            throw MappingText.corrupted("\(invalid)", container)
        }
    }
}

/// One of the provider's original name values, in one language, with the
/// source it was read from (DEC-068 §C3, §C4). A provider input, never a
/// canonical name. A reference may hold several values for one language: when
/// a provider changes a name, the new value is recorded beside the old
/// (DEC-068 §E3), each with its own source.
nonisolated struct OriginalName: Hashable, Sendable, Codable {
    let language: ExactValue
    let value: ExactValue
    let source: SourceReference

    init(language: ExactValue, value: ExactValue, source: SourceReference) {
        self.language = language
        self.value = value
        self.source = source
    }

    /// Language, then value, then source: a total order, so the encoded
    /// history is always in the same order.
    static func precedes(_ lhs: OriginalName, _ rhs: OriginalName) -> Bool {
        if lhs.language != rhs.language { return lhs.language < rhs.language }
        if lhs.value != rhs.value { return lhs.value < rhs.value }
        return SourceReference.precedes(lhs.source, rhs.source)
    }

    private enum CodingKeys: String, CodingKey, CaseIterable { case language, value, source }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            language: try container.decode(ExactValue.self, forKey: .language),
            value: try container.decode(ExactValue.self, forKey: .value),
            source: try container.decode(SourceReference.self, forKey: .source)
        )
    }
}

/// The DEC-068 §E1 status of a provider reference. Only an active reference
/// resolves. An absent one is history, not current. A retired one was
/// withdrawn by a reviewed record, which it names, and never resolves again.
nonisolated enum ProviderReferenceStatus: Hashable, Sendable, Codable {
    case active
    case absent
    case retired(review: String)

    private enum CodingKeys: String, CodingKey, CaseIterable { case state, review }

    /// A review identifier must be printable ASCII. `ProviderReference`
    /// enforces this at construction too, so no status that cannot be decoded
    /// is ever encoded.
    var isWellFormed: Bool {
        if case .retired(let review) = self { return MappingText.isToken(review) }
        return true
    }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(String.self, forKey: .state)
        let review = try container.decodeIfPresent(String.self, forKey: .review)
        switch (state, review) {
        case ("active", nil): self = .active
        case ("absent", nil): self = .absent
        case ("retired", let review?) where MappingText.isToken(review): self = .retired(review: review)
        default: throw MappingText.corrupted("invalidStatus", container)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .active: try container.encode("active", forKey: .state)
        case .absent: try container.encode("absent", forKey: .state)
        case .retired(let review):
            try container.encode("retired", forKey: .state)
            try container.encode(review, forKey: .review)
        }
    }
}

/// What makes two references the same reference: the source, the namespace,
/// and the exact value.
nonisolated struct ProviderReferenceKey: Hashable, Comparable, Sendable {
    let sourceID: String
    let namespace: ProviderNamespace
    let value: ExactValue

    static func < (lhs: ProviderReferenceKey, rhs: ProviderReferenceKey) -> Bool {
        if !lhs.sourceID.utf8.elementsEqual(rhs.sourceID.utf8) {
            return lhs.sourceID.utf8.lexicographicallyPrecedes(rhs.sourceID.utf8)
        }
        if lhs.namespace != rhs.namespace { return lhs.namespace < rhs.namespace }
        return lhs.value < rhs.value
    }
}

/// A provider-reference record (DEC-068 §C1).
nonisolated struct ProviderReference: Hashable, Sendable, Codable {
    let canonicalID: MintedIdentifier
    /// The DEC-066 source identifier, such as `DS-01/…`: printable ASCII.
    let sourceID: String
    let namespace: ProviderNamespace
    let value: ExactValue
    let status: ProviderReferenceStatus
    /// The input the value was first seen in.
    let firstSeenInputSHA256: String
    /// Where the value was last seen: `provenance.inputSHA256` is that input.
    let provenance: SourceReference
    /// Every original name value seen, with its source, sorted by language,
    /// value, and source. Several values may share a language: that is the
    /// name history. Only an exact repeat is rejected.
    let originalNames: [OriginalName]

    enum Invalid: Error, Hashable, Sendable {
        case malformedSourceID
        case malformedDigest
        case repeatedOriginalName
        /// A retired status whose review identifier is not printable ASCII.
        case malformedReview
        /// A GTFS namespace needs GTFS provenance (member and table); an ODPT
        /// namespace needs `odpt:Railway` provenance (record index). This holds
        /// for the reference's own provenance and for every original name's
        /// source.
        case provenanceMismatch
    }

    init(
        canonicalID: MintedIdentifier,
        sourceID: String,
        namespace: ProviderNamespace,
        value: ExactValue,
        status: ProviderReferenceStatus,
        firstSeenInputSHA256: String,
        provenance: SourceReference,
        originalNames: [OriginalName]
    ) throws(Invalid) {
        guard MappingText.isToken(sourceID) else { throw .malformedSourceID }
        guard MappingText.isSHA256(firstSeenInputSHA256) else { throw .malformedDigest }
        guard status.isWellFormed else { throw .malformedReview }
        guard namespace.isGTFS == provenance.isGTFSPosition,
              originalNames.allSatisfy({ namespace.isGTFS == $0.source.isGTFSPosition })
        else { throw .provenanceMismatch }
        let sorted = originalNames.sorted(by: OriginalName.precedes)
        guard Set(sorted).count == sorted.count else { throw .repeatedOriginalName }
        self.canonicalID = canonicalID
        self.sourceID = sourceID
        self.namespace = namespace
        self.value = value
        self.status = status
        self.firstSeenInputSHA256 = firstSeenInputSHA256
        self.provenance = provenance
        self.originalNames = sorted
    }

    var key: ProviderReferenceKey {
        ProviderReferenceKey(sourceID: sourceID, namespace: namespace, value: value)
    }

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case canonicalID, sourceID, namespace, value, status, firstSeenInputSHA256, provenance, originalNames
    }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            try self.init(
                canonicalID: container.decode(MintedIdentifier.self, forKey: .canonicalID),
                sourceID: container.decode(String.self, forKey: .sourceID),
                namespace: container.decode(ProviderNamespace.self, forKey: .namespace),
                value: container.decode(ExactValue.self, forKey: .value),
                status: container.decode(ProviderReferenceStatus.self, forKey: .status),
                firstSeenInputSHA256: container.decode(String.self, forKey: .firstSeenInputSHA256),
                provenance: container.decode(SourceReference.self, forKey: .provenance),
                originalNames: container.decode([OriginalName].self, forKey: .originalNames)
            )
        } catch let invalid as Invalid {
            throw MappingText.corrupted("\(invalid)", container)
        }
    }
}
