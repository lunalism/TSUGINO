import Foundation

// validate-railway — the read-only local check of an `odpt:Railway` JSON file
// (DEC-067 §E, §F). It is separate from intake: it takes no source, writes
// nothing to disk, and prints only counts, totals, and a hash. Failures name
// the error kind, record index, and field — never a provider value.

/// The DEC-067 §E aggregates for one input.
struct RailwayValidationSummary: Equatable {
    let inputSHA256: String
    let byteCount: Int64
    let recordCount: Int
    let distinctLineCodeCount: Int
    let stationOrderEntryCount: Int
    /// Language key → number of record titles that have it.
    let recordTitleLanguages: [String: Int]
    /// Language key → number of station-order titles that have it.
    let stationTitleLanguages: [String: Int]

    init(inputSHA256: String, byteCount: Int64, records: [ODPTRailway]) {
        self.inputSHA256 = inputSHA256
        self.byteCount = byteCount
        recordCount = records.count
        distinctLineCodeCount = Set(records.map(\.lineCode)).count
        stationOrderEntryCount = records.reduce(0) { $0 + $1.stationOrder.count }
        var recordTitles: [String: Int] = [:]
        var stationTitles: [String: Int] = [:]
        for record in records {
            for entry in record.title.entries { recordTitles[entry.language, default: 0] += 1 }
            for station in record.stationOrder {
                for entry in station.title?.entries ?? [] { stationTitles[entry.language, default: 0] += 1 }
            }
        }
        recordTitleLanguages = recordTitles
        stationTitleLanguages = stationTitles
    }

    /// The standard-output report: aggregates only, in a fixed order.
    func report() -> String {
        func languages(_ counts: [String: Int]) -> String {
            counts.isEmpty ? "none" : counts.keys.sorted().map { "\($0) \(counts[$0]!)" }.joined(separator: ", ")
        }
        return """
            input SHA-256: \(inputSHA256) (\(byteCount) bytes)
            reader: 0 invalid, 0 unsupported
            records: \(recordCount)
            distinct line codes: \(distinctLineCodeCount)
            station-order entries: \(stationOrderEntryCount)
            record title languages: \(languages(recordTitleLanguages))
            station title languages: \(languages(stationTitleLanguages))

            """
    }
}

enum RailwayValidationError: Error, Equatable, CustomStringConvertible {
    case pathInsideRepository
    case pathUnavailable(errno: Int32)
    case notRegularFile
    case tooLarge(byteCount: Int64)
    case readFailed(errno: Int32)
    case inputChanged
    case reader(ODPTRailwayReadError)

    /// Names only an error kind, a record index, and a field — never a value
    /// taken from the input.
    var description: String {
        switch self {
        case .pathInsideRepository:
            "The input path resolves inside the repository, which DEC-067 forbids."
        case .pathUnavailable(let errno):
            "The input path cannot be used: \(String(cString: strerror(errno)))."
        case .notRegularFile:
            "The input is not a regular file."
        case .tooLarge(let byteCount):
            "The input is \(byteCount) bytes, over the validate-railway limit."
        case .readFailed(let errno):
            "The input could not be read: \(String(cString: strerror(errno)))."
        case .inputChanged:
            "The input changed while it was being read."
        case .reader(.invalid(let reason)):
            "invalid: \(reason)"
        case .reader(.unsupported(let reason, let location)):
            "unsupported: \(reason)"
                + (location.recordIndex.map { ", record \($0)" } ?? "")
                + (location.field.map { ", field \($0)" } ?? "")
        }
    }
}

enum RailwayValidation {
    /// The DEC-067 §F input limit; the retained snapshot is about 50 KB.
    static let standardLimit: Int64 = 8 * 1024 * 1024

    /// The operator's entry point: the standard limit and no hook.
    static func run(inputPath: String, repositoryRoot: FileIdentity) async throws(RailwayValidationError) -> RailwayValidationSummary {
        try await validate(inputPath, repositoryRoot, standardLimit, nil)
    }

    #if INTAKE_TESTING
    /// The test runner's entry point, with a test limit and a hook that runs
    /// after the opened input passes its checks, before it is read.
    static func run(
        inputPath: String,
        repositoryRoot: FileIdentity,
        limit: Int64,
        afterOpen: (() -> Void)? = nil
    ) async throws(RailwayValidationError) -> RailwayValidationSummary {
        try await validate(inputPath, repositoryRoot, limit, afterOpen)
    }
    #endif

    private static func validate(
        _ inputPath: String,
        _ repositoryRoot: FileIdentity,
        _ limit: Int64,
        _ afterOpen: (() -> Void)?
    ) async throws(RailwayValidationError) -> RailwayValidationSummary {
        // DEC-066 repository-boundary checks: the resolved path, then the
        // opened file itself, compared by identity.
        guard let resolved = resolvedPath(inputPath) else { throw .pathUnavailable(errno: errno) }
        guard !isInsideRepository(resolved, repositoryRoot: repositoryRoot) else { throw .pathInsideRepository }
        guard let checked = FileIdentity(path: resolved) else { throw .pathUnavailable(errno: errno) }

        let input: ArchiveFile
        do {
            input = try ArchiveFile(resolvedPath: resolved, limit: limit)
        } catch {
            switch error {
            case .archiveNotRegularFile: throw .notRegularFile
            case .archiveTooLarge(let byteCount): throw .tooLarge(byteCount: byteCount)
            case .pathUnavailable(_, let code): throw .pathUnavailable(errno: code)
            case .archiveReadFailed(let code): throw .readFailed(errno: code)
            default: throw .readFailed(errno: EIO)
            }
        }
        guard let opened = descriptorPath(input.descriptor),
              !isInsideRepository(opened, repositoryRoot: repositoryRoot) else { throw .pathInsideRepository }
        guard FileIdentity(device: input.initialState.device, inode: input.initialState.inode) == checked else {
            throw .inputChanged
        }
        afterOpen?()

        // The read stops one byte past the size recorded at open, so growth
        // during the read is caught there and the limit holds throughout.
        let read: Data?
        do {
            read = try input.readAll(maximum: input.initialState.byteCount)
        } catch {
            if case .archiveReadFailed(let code) = error { throw .readFailed(errno: code) }
            throw .readFailed(errno: EIO)
        }
        guard let data = read else { throw .inputChanged }
        guard ArchiveFile.state(of: input.descriptor) == input.initialState else { throw .inputChanged }

        let records: [ODPTRailway]
        do {
            records = try await ODPTRailwayReader.read(data)
        } catch {
            throw .reader(error)
        }
        return RailwayValidationSummary(
            inputSHA256: sha256Hex(data),
            byteCount: Int64(data.count),
            records: records
        )
    }
}
