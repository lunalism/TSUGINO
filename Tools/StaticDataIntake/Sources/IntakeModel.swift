import Foundation

// Static source intake (DEC-066): errors, limits, source definitions, and the
// manifest. Everything here is tool-only; none of it is in the app target.

/// Why an intake failed. Every failure publishes nothing.
enum IntakeError: Error, Equatable, CustomStringConvertible {
    case repositoryRootUnavailable
    case pathInsideRepository(role: String)
    case pathUnavailable(role: String, errno: Int32)
    case outputNameInvalid
    case outputExists
    case outputDirectoryChanged
    case archiveNotRegularFile
    case archiveTooLarge(byteCount: Int64)
    case archiveReadFailed(errno: Int32)
    case processFailed(tool: String, errno: Int32)
    case listingFailed(status: Int32)
    case listingTooLarge
    case unsafeMemberName(listedAs: String)
    case duplicateMember(name: String)
    case missingRequiredMember(name: String)
    case memberStreamFailed(name: String, status: Int32)
    case memberTooLarge(name: String)
    case selectedMembersTooLarge
    case readerInvalid(GTFSInvalidInput, at: GTFSSourceLocation)
    case readerUnsupported(GTFSUnsupportedInput, at: GTFSSourceLocation)
    case inputChanged(reason: String)
    case invalidObtainedAt
    case invalidSourceDefinition(reason: String)
    case publicationFailed(errno: Int32)
    case publishedWithoutDurableDirectory(errno: Int32)

    var description: String {
        switch self {
        case .repositoryRootUnavailable:
            "The repository root could not be determined from the tool's location."
        case .pathInsideRepository(let role):
            "The \(role) path resolves inside the repository, which DEC-066 forbids."
        case .pathUnavailable(let role, let errno):
            "The \(role) path cannot be used: \(String(cString: strerror(errno)))."
        case .outputNameInvalid:
            "The output path must name a file."
        case .outputExists:
            "The output file already exists; it is never overwritten."
        case .outputDirectoryChanged:
            "The output directory changed while it was being checked; nothing was published."
        case .archiveNotRegularFile:
            "The archive is not a regular file."
        case .archiveTooLarge(let byteCount):
            "The archive is \(byteCount) bytes, over the archive limit."
        case .archiveReadFailed(let errno):
            "The archive could not be read: \(String(cString: strerror(errno)))."
        case .processFailed(let tool, let errno):
            "\(tool) could not be run: \(String(cString: strerror(errno)))."
        case .listingFailed(let status):
            "bsdtar could not list the archive (exit status \(status))."
        case .listingTooLarge:
            "The archive listing exceeds its limit."
        case .unsafeMemberName(let listedAs):
            "The archive contains a member name outside the allowed character set: \(listedAs.debugDescription)."
        case .duplicateMember(let name):
            "The archive lists the member \(name) more than once."
        case .missingRequiredMember(let name):
            "The archive has no \(name)."
        case .memberStreamFailed(let name, let status):
            "bsdtar failed while streaming \(name) (exit status \(status)); its bytes were discarded."
        case .memberTooLarge(let name):
            "\(name) exceeds the per-member limit."
        case .selectedMembersTooLarge:
            "The selected members together exceed their combined limit."
        case .readerInvalid(let reason, let location):
            "The reader found invalid input in \(location.table.rawValue) at line \(location.line): \(reason)."
        case .readerUnsupported(let reason, let location):
            "The reader found input outside its supported shape in \(location.table.rawValue) at line \(location.line): \(reason)."
        case .inputChanged(let reason):
            "The archive changed during intake (\(reason)); nothing was published."
        case .invalidObtainedAt:
            "obtained-at must be a UTC time written as YYYY-MM-DDTHH:MM:SSZ."
        case .invalidSourceDefinition(let reason):
            "The source definition is invalid: \(reason)."
        case .publicationFailed(let errno):
            "The manifest could not be published: \(String(cString: strerror(errno)))."
        case .publishedWithoutDurableDirectory(let errno):
            "The manifest was published complete, but its directory entry could not be made durable: \(String(cString: strerror(errno))). Check or remove it by hand."
        }
    }
}

/// The DEC-066 §E size limits.
struct IntakeLimits: Equatable {
    var archiveBytes: Int64
    var memberBytes: Int
    var selectedTotalBytes: Int
    /// Not a DEC-066 data limit: a bound on the listing text itself.
    var listingBytes: Int

    static let standard = IntakeLimits(
        archiveBytes: 32 * 1024 * 1024,
        memberBytes: 64 * 1024 * 1024,
        selectedTotalBytes: 128 * 1024 * 1024,
        listingBytes: 1024 * 1024
    )
}

/// How a source can be referred to in a manifest (DEC-066 §G).
enum SourceAccess: String, Codable, Equatable {
    case publicURL
    case credentialed
}

/// One entry of the committed source list.
struct SourceDefinition: Equatable {
    let sourceID: String
    let provider: String
    let license: String
    let dataset: String
    let resource: String
    let access: SourceAccess
    /// Present only for `publicURL` sources: `https`, no user information,
    /// query, or fragment.
    let url: String?

    /// Fails unless the definition satisfies DEC-066 §G.
    func validate() throws(IntakeError) {
        switch access {
        case .credentialed:
            guard url == nil else {
                throw .invalidSourceDefinition(reason: "a credentialed source records no URL")
            }
        case .publicURL:
            guard let url, let components = URLComponents(string: url) else {
                throw .invalidSourceDefinition(reason: "a public source needs a URL")
            }
            guard components.scheme == "https", let host = components.host, !host.isEmpty else {
                throw .invalidSourceDefinition(reason: "the URL must be https with a host")
            }
            guard components.user == nil, components.password == nil else {
                throw .invalidSourceDefinition(reason: "the URL must not contain user information")
            }
            guard components.query == nil, components.fragment == nil else {
                throw .invalidSourceDefinition(reason: "the URL must not contain a query or fragment")
            }
        }
    }
}

/// The committed source list. The tool fetches nothing: every archive is
/// supplied by the operator (DEC-066, DEC-067).
enum SourceList {
    /// Registry row DS-01: Toei static GTFS, CC BY 4.0 (audit §2.3 B8, §3.5).
    static let toeiStaticGTFS = SourceDefinition(
        sourceID: "DS-01/toei-static-gtfs",
        provider: "Bureau of Transportation, Tokyo Metropolitan Government",
        license: "CC BY 4.0",
        dataset: "train-toei",
        resource: "35b68908-4558-47ae-bfa5-867e58544a1a",
        access: .publicURL,
        url: "https://api-public.odpt.org/api/v4/files/Toei/data/Toei-Train-GTFS.zip"
    )

    /// Registry row DS-03: Tokyo Metro static GTFS, Basic License. Metadata
    /// verified 2026-09-27 from the public catalog pages of dataset
    /// `train-tokyometro` (DEC-067 Context). The file URL requires an account
    /// token, so the source is credentialed and no URL is recorded.
    static let tokyoMetroStaticGTFS = SourceDefinition(
        sourceID: "DS-03/tokyometro-static-gtfs",
        provider: "Tokyo Metro",
        license: "Public Transportation Open Data Basic License",
        dataset: "train-tokyometro",
        resource: "d4f11962-1c5a-4316-9a16-7fb229c227ea",
        access: .credentialed,
        url: nil
    )

    /// GTFS archive sources: the ones intake may read.
    static let all: [SourceDefinition] = [toeiStaticGTFS, tokyoMetroStaticGTFS]

    static func source(id: String) -> SourceDefinition? {
        all.first { $0.sourceID == id }
    }

    /// Registry row DS-03 (route dataset): Tokyo Metro `odpt:Railway`, Basic
    /// License. Metadata verified 2026-09-28 from the public catalog pages of
    /// dataset `r_route-tokyometro`. The endpoint requires an account token,
    /// so the source is credentialed and no URL is recorded.
    static let tokyoMetroRailway = SourceDefinition(
        sourceID: "DS-03/tokyometro-railway",
        provider: "Tokyo Metro",
        license: "Public Transportation Open Data Basic License",
        dataset: "r_route-tokyometro",
        resource: "81d953eb-65f8-4dfd-ba99-cd43d41e8b9b",
        access: .credentialed,
        url: nil
    )

    /// `odpt:Railway` sources, kept apart from `all`: intake reads GTFS
    /// archives only, and these identify the Railway input of
    /// review-packet and provisional-registry.
    static let railway: [SourceDefinition] = [tokyoMetroRailway]

    static func railwaySource(id: String) -> SourceDefinition? {
        railway.first { $0.sourceID == id }
    }
}

/// The source manifest (DEC-066 §G). It holds only provenance, hashes, and
/// sizes: never provider rows or local paths.
struct SourceManifest: Codable, Equatable {
    struct SelectedMember: Codable, Equatable {
        let name: String
        let byteCount: Int
        let sha256: String
    }

    let manifestVersion: Int
    let sourceID: String
    let provider: String
    let license: String
    let dataset: String
    let resource: String
    let sourceAccess: SourceAccess
    let sourceURL: String?
    let archiveSHA256: String
    let archiveByteCount: Int64
    let obtainedAt: String
    let obtainedAtBasis: String
    let feedVersion: String?
    let feedStartDate: String?
    let feedEndDate: String?
    let selectedMembers: [SelectedMember]
    let unselectedMembers: [String]

    static let currentVersion = 1

    /// Deterministic JSON: sorted keys, fixed formatting, absent optionals
    /// omitted, and a final newline.
    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        // Encoding plain strings and integers cannot fail.
        var data = try! encoder.encode(self)
        data.append(0x0A)
        return data
    }
}

/// `obtainedAt` must be a real UTC instant written exactly as
/// `YYYY-MM-DDTHH:MM:SSZ`. Only the format is checked; no clock is read.
func isValidObtainedAt(_ text: String) -> Bool {
    let pattern = #"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"#
    guard text.range(of: pattern, options: .regularExpression) != nil else { return false }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone(identifier: "UTC")
    guard let date = formatter.date(from: text) else { return false }
    return formatter.string(from: date) == text
}
