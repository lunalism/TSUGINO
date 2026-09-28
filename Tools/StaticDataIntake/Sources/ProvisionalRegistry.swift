import Foundation

// provisional-registry — DEC-068 §G's command that writes a provisional
// registry and a report outside the repository. Offline tool only.
//
// Inputs, all outside the repository and read-only:
//   - one GTFS archive of a known source, read exactly as intake reads it;
//   - optionally one `odpt:Railway` JSON file, read as validate-railway reads it;
//   - optionally the current provisional registry (schema version 2);
//   - the reviewed records file for these inputs (`ReviewedRecordsFile`);
//   - once the registry holds references of a source, the previous inputs
//     and records the registry was last reconciled with.
// Stages, in the established order; any failure publishes nothing:
//   1. path checks for every input and the output; outputs must not exist;
//   2. read and identify every input; records must name the inputs' hashes;
//   3. station grouping (P2-S4 Step 2): applied and checked, reported only —
//      no StationID exists in P2-S4 (DEC-068 §D2), so nothing is written;
//   4. operators reconciled (Step 4), from reviewed operator records (§D1);
//   5. line binding (Step 3) against the operators just reconciled;
//   6. lines reconciled (Step 4), from the reviewed line bindings;
//   7. the registry and a report of aggregates, published together as one
//      new directory (`DirectoryPublication`).
// Reviewed operator records and line bindings are the reviewed records that
// attach new provider keys (DEC-068 §E3); each becomes one attach record per
// new key, with the review identifier `<reviewID>:<n>`. A key the registry
// already holds must resolve to the identity the record names: the command
// never rebinds a key. It mints nothing; `mint` does that, on request.

// MARK: - Reviewed records file

/// The reviewer's records for one pair of identified inputs.
struct ReviewedRecordsFile: Decodable {
    static let currentVersion = 1

    struct Operator: Decodable {
        let reviewID: String
        let operatorID: MintedIdentifier
        let gtfsAgencyID: String?
        let odptOperator: String?

        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, operatorID, gtfsAgencyID, odptOperator }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            operatorID = try c.decode(MintedIdentifier.self, forKey: .operatorID)
            gtfsAgencyID = try c.decodeIfPresent(String.self, forKey: .gtfsAgencyID)
            odptOperator = try c.decodeIfPresent(String.self, forKey: .odptOperator)
        }
    }

    struct Grouping: Decodable {
        struct Exception: Decodable {
            let reason: String
            let waivedChecks: [String]
            private enum CodingKeys: String, CodingKey, CaseIterable { case reason, waivedChecks }
            init(from decoder: any Decoder) throws {
                try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
                let c = try decoder.container(keyedBy: CodingKeys.self)
                reason = try c.decode(String.self, forKey: .reason)
                waivedChecks = try c.decode([String].self, forKey: .waivedChecks)
            }
        }
        let reviewID: String
        let stops: [String]
        let evidenceSHA256: String
        let decision: String
        let exception: Exception?

        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, stops, evidenceSHA256, decision, exception }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            stops = try c.decode([String].self, forKey: .stops)
            evidenceSHA256 = try c.decode(String.self, forKey: .evidenceSHA256)
            decision = try c.decode(String.self, forKey: .decision)
            exception = try c.decodeIfPresent(Exception.self, forKey: .exception)
        }
    }

    struct Line: Decodable {
        struct Acceptance: Decodable {
            let route: String?
            let railwayRecord: String?
            let reason: String
            let checks: [String]
            private enum CodingKeys: String, CodingKey, CaseIterable { case route, railwayRecord, reason, checks }
            init(from decoder: any Decoder) throws {
                try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
                let c = try decoder.container(keyedBy: CodingKeys.self)
                route = try c.decodeIfPresent(String.self, forKey: .route)
                railwayRecord = try c.decodeIfPresent(String.self, forKey: .railwayRecord)
                reason = try c.decode(String.self, forKey: .reason)
                checks = try c.decode([String].self, forKey: .checks)
            }
        }
        let reviewID: String
        let lineID: MintedIdentifier
        let routes: [String]
        let railwayRecords: [String]
        let evidenceSHA256: String
        let acceptances: [Acceptance]

        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, lineID, routes, railwayRecords, evidenceSHA256, acceptances }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            lineID = try c.decode(MintedIdentifier.self, forKey: .lineID)
            routes = try c.decode([String].self, forKey: .routes)
            railwayRecords = try c.decode([String].self, forKey: .railwayRecords)
            evidenceSHA256 = try c.decode(String.self, forKey: .evidenceSHA256)
            acceptances = try c.decodeIfPresent([Acceptance].self, forKey: .acceptances) ?? []
        }
    }

    struct Revision: Decodable {
        let reviewID: String
        /// `gtfs` or `railway`: which of the run's sources the key belongs to.
        let source: String
        let namespace: String
        let value: String
        /// `attach` or `retire`.
        let action: String
        let identity: MintedIdentifier?

        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, source, namespace, value, action, identity }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            source = try c.decode(String.self, forKey: .source)
            namespace = try c.decode(String.self, forKey: .namespace)
            value = try c.decode(String.self, forKey: .value)
            action = try c.decode(String.self, forKey: .action)
            identity = try c.decodeIfPresent(MintedIdentifier.self, forKey: .identity)
        }
    }

    /// The sources and input hashes the reviewer's records are for. A run
    /// refuses records for any other source or input.
    let gtfsSourceID: String
    let gtfsArchiveSHA256: String
    let railwaySourceID: String?
    let railwayInputSHA256: String?
    let operators: [Operator]
    let groupings: [Grouping]
    let lines: [Line]
    let revisions: [Revision]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion, gtfsSourceID, gtfsArchiveSHA256, railwaySourceID, railwayInputSHA256, operators, groupings, lines, revisions
    }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guard try c.decode(Int.self, forKey: .schemaVersion) == Self.currentVersion else {
            throw MappingText.corrupted("unsupportedSchemaVersion", c)
        }
        gtfsSourceID = try c.decode(String.self, forKey: .gtfsSourceID)
        gtfsArchiveSHA256 = try c.decode(String.self, forKey: .gtfsArchiveSHA256)
        railwaySourceID = try c.decodeIfPresent(String.self, forKey: .railwaySourceID)
        railwayInputSHA256 = try c.decodeIfPresent(String.self, forKey: .railwayInputSHA256)
        operators = try c.decodeIfPresent([Operator].self, forKey: .operators) ?? []
        groupings = try c.decodeIfPresent([Grouping].self, forKey: .groupings) ?? []
        lines = try c.decodeIfPresent([Line].self, forKey: .lines) ?? []
        revisions = try c.decodeIfPresent([Revision].self, forKey: .revisions) ?? []
    }

    /// A repeated JSON key is refused before decoding, as for the registry:
    /// the platform decoder would silently keep one value.
    static func decoded(from data: Data) throws(ProvisionalRegistryError) -> ReviewedRecordsFile {
        guard !RegistryJSON.repeatsKey([UInt8](data)) else { throw .records(.repeatedKey) }
        do {
            return try JSONDecoder().decode(ReviewedRecordsFile.self, from: data)
        } catch {
            throw .records(.malformed)
        }
    }
}

// MARK: - Errors

/// Why a run failed. Every case names a stage and an error kind, never a
/// provider value, path, identifier, or review text.
enum ProvisionalRegistryError: Error, Equatable, CustomStringConvertible {
    enum RecordsProblem: String, Equatable {
        case repeatedKey, malformed
        /// The records name other sources or input hashes.
        case forOtherInput
        /// A record field breaks its type's rules (a malformed review ID,
        /// digest, check name, namespace, or action).
        case invalidRecord
        /// An operator record's key, a line record's railway record, or a
        /// revision record's source is not in these inputs.
        case unknownKey
        /// Two operator records name one key.
        case duplicateKey
        /// A key the registry holds resolves to another identity than the
        /// record names. The command never rebinds a key.
        case identityMismatch
        /// A revision record in a namespace this command does not reconcile.
        case namespaceNotInRun
    }

    case arguments
    case input(IntakeError)
    case railway(RailwayValidationError)
    case registryFile
    case records(RecordsProblem)
    /// A review-packet member selection that cannot be evaluated.
    enum SelectionProblem: String, Equatable {
        case repeatedKey, malformed
        /// The selection file names other sources or input hashes.
        case forOtherInput
        /// An empty selection, or a malformed label.
        case invalidSelection
        /// A route or Railway record not in these inputs, or a Railway record
        /// when the run has no Railway input.
        case unknownMember
        /// One member twice in a selection.
        case repeatedMember
        /// One member in two selections: at most one binding can hold it.
        case memberInTwoSelections
        /// A route whose agency the feed does not resolve.
        case agencyUnresolved
        /// A member with no operator, once the operator records apply.
        case operatorUnbound
        /// Members of different operators (DEC-068 §D5).
        case crossesOperatorBoundary
    }
    case selection(SelectionProblem)
    /// A Railway `@id`, `owl:sameAs`, or operator observed here is held under
    /// another source: the run's Railway source identifier does not match the
    /// source the registry recorded these values for.
    case sourceMismatch
    case previousRecords(RecordsProblem)
    case grouping(String)
    case binding(String)
    case reconciliation(String)
    /// Conflicts that fail the run, as counts by kind.
    case conflicts([String: Int])
    case undecided(String)
    case output(IntakeError)

    var description: String {
        switch self {
        case .arguments: "arguments: invalid combination"
        case .input(let error): "input: \(error)"
        case .railway(let error): "railway input: \(error)"
        case .registryFile: "registry: not a valid provisional registry (schema version \(MappingRegistry.schemaVersion))"
        case .records(let problem): "records: \(problem.rawValue)"
        case .selection(let problem): "selection: \(problem.rawValue)"
        case .sourceMismatch: "railway source: values are held under another source identifier"
        case .previousRecords(let problem): "previous records: \(problem.rawValue)"
        case .grouping(let kind): "grouping: \(kind)"
        case .binding(let kind): "line binding: \(kind)"
        case .reconciliation(let kind): "reconciliation: \(kind)"
        case .conflicts(let counts): "conflicts: " + counts.keys.sorted().map { "\($0) \(counts[$0]!)" }.joined(separator: ", ")
        case .undecided(let kind): "undecided transition: \(kind)"
        case .output(let error): "output: \(error)"
        }
    }
}

/// The error's case name without its payload: review identifiers and values
/// never leave the run.
private func kind(_ error: some Error) -> String {
    let text = String(describing: error)
    return String(text.prefix { $0 != "(" })
}

// MARK: - Request and report

struct ProvisionalRegistryRequest {
    struct Inputs {
        let archivePath: String
        let railwayPath: String?
        let recordsPath: String
    }

    let gtfsSourceID: String
    let railwaySourceID: String?
    let current: Inputs
    let previous: Inputs?
    let registryPath: String?
    /// A new directory: it receives `registry.json` and `report.json`.
    let outputPath: String
    /// Launch inputs for the line-binding rule (DEC-068 §D4), by source and hash.
    let launchInputs: LaunchInputs
}

/// Aggregates only: counts, hashes, revisions, and source identifiers.
struct ProvisionalRegistryReport: Encodable, Equatable {
    static let currentVersion = 1

    struct Input: Encodable, Equatable {
        let sourceID: String
        let sha256: String
        let byteCount: Int64
    }

    struct Grouping: Encodable, Equatable {
        let stopRows: Int
        let operatorLevelIdentities: Int
        let proposals: Int
        let heldBack: Int
        let accepted: Int
        let rejected: Int
    }

    struct Lines: Encodable, Equatable {
        let lines: Int
        let routes: Int
        let railwayRecords: Int
        let acceptedChecks: Int
    }

    struct Registry: Encodable, Equatable {
        let previousRevision: Int
        let revision: Int
        let operatorEntities: Int
        let lineEntities: Int
        let activeReferences: Int
        let absentReferences: Int
        let retiredReferences: Int
    }

    let reportVersion: Int
    let gtfs: Input
    let railway: Input?
    let previousGTFSArchiveSHA256: String?
    let previousRailwayInputSHA256: String?
    let grouping: Grouping
    let lines: Lines
    let registry: Registry
    /// Per source and phase, in run order.
    let reconciliation: [RevisionSummary]

    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try! encoder.encode(self)
        data.append(0x0A)
        return data
    }
}

struct ProvisionalRegistryResult: Equatable {
    let registry: MappingRegistry
    let report: ProvisionalRegistryReport
}

// MARK: - Command

enum ProvisionalRegistryCommand {
    static let fileLimit: Int64 = 16 * 1024 * 1024

    #if INTAKE_TESTING
    struct TestHooks {
        var beforePublication: (() -> Void)?
        var afterFirstFile: (() throws -> Void)?
    }
    #endif

    static func run(_ request: ProvisionalRegistryRequest, repositoryRoot: FileIdentity) async throws(ProvisionalRegistryError) -> ProvisionalRegistryResult {
        try await body(request, repositoryRoot, .standard, nil, nil)
    }

    #if INTAKE_TESTING
    static func run(
        _ request: ProvisionalRegistryRequest,
        repositoryRoot: FileIdentity,
        hooks: TestHooks
    ) async throws(ProvisionalRegistryError) -> ProvisionalRegistryResult {
        try await body(request, repositoryRoot, .standard, hooks.beforePublication, hooks.afterFirstFile)
    }
    #endif

    private static func body(
        _ request: ProvisionalRegistryRequest,
        _ root: FileIdentity,
        _ limits: IntakeLimits,
        _ beforePublication: (() -> Void)?,
        _ afterFirstFile: (() throws -> Void)?
    ) async throws(ProvisionalRegistryError) -> ProvisionalRegistryResult {
        // Arguments that need no file system.
        guard MappingText.isToken(request.gtfsSourceID),
              (request.railwaySourceID == nil) == (request.current.railwayPath == nil),
              request.railwaySourceID.map(MappingText.isToken) ?? true,
              request.railwaySourceID != request.gtfsSourceID,
              request.previous.map({ ($0.railwayPath == nil) == (request.railwaySourceID == nil) }) ?? true
        else { throw .arguments }

        // 1. Path checks for every input, then the output.
        func checked(_ path: String, _ role: String) throws(ProvisionalRegistryError) -> (resolved: String, identity: FileIdentity) {
            do { return try ArchiveReading.checkedPath(path, role: role, repositoryRoot: root) } catch { throw .input(error) }
        }
        let archive = try checked(request.current.archivePath, "archive")
        let records = try checked(request.current.recordsPath, "records")
        let registryPath = try request.registryPath.map { path throws(ProvisionalRegistryError) in try checked(path, "registry") }
        let previousArchive = try request.previous.map { p throws(ProvisionalRegistryError) in try checked(p.archivePath, "previous archive") }
        let previousRecords = try request.previous.map { p throws(ProvisionalRegistryError) in try checked(p.recordsPath, "previous records") }
        let publication: DirectoryPublication
        do {
            let outputName = (request.outputPath as NSString).lastPathComponent
            guard !outputName.isEmpty, outputName != ".", outputName != "..", !request.outputPath.hasSuffix("/") else {
                throw IntakeError.outputNameInvalid
            }
            let requested = (request.outputPath as NSString).deletingLastPathComponent
            guard let parent = resolvedPath(requested.isEmpty ? "." : requested) else {
                throw IntakeError.pathUnavailable(role: "output directory", errno: errno)
            }
            guard !isInsideRepository(parent, repositoryRoot: root) else { throw IntakeError.pathInsideRepository(role: "output") }
            publication = try DirectoryPublication(checkedDirectory: parent, name: outputName, repositoryRoot: root)
            guard !publication.targetExists() else { throw IntakeError.outputExists }
        } catch let error as IntakeError {
            throw .output(error)
        } catch {
            throw .output(.publicationFailed(errno: EIO))
        }

        // 2. Read and identify every input.
        let registry: MappingRegistry
        if let registryPath {
            let data = try readFile(registryPath, "registry", root)
            do { registry = try MappingRegistry.decoded(from: data) } catch { throw .registryFile }
        } else {
            registry = .empty
        }
        let current = try await readInputs(
            request.current, archive, records, request.gtfsSourceID, request.railwaySourceID, root, limits, previous: false
        )
        let previous: RunInputs?
        if let inputs = request.previous, let previousArchive, let previousRecords {
            previous = try await readInputs(
                inputs, previousArchive, previousRecords, request.gtfsSourceID, request.railwaySourceID, root, limits, previous: true
            )
        } else {
            previous = nil
        }

        // 3. Station grouping: checked and reported, never written.
        let grouping = try groupingOutcome(current)

        // Railway values are global identifiers: one held under another
        // source means the supplied Railway source identifier substitutes a
        // different source for the one the registry recorded.
        if let railway = current.railway {
            struct Value: Hashable {
                let namespace: ProviderNamespace
                let value: ExactValue
            }
            var observed = Set<Value>()
            for record in railway.records {
                for (namespace, text) in [(ProviderNamespace.odptRailwayID, record.id), (.odptRailwaySameAs, record.sameAs), (.odptOperator, record.operatorReference)] {
                    if let value = ExactValue(text) { observed.insert(Value(namespace: namespace, value: value)) }
                }
            }
            guard !registry.references.contains(where: {
                $0.sourceID != railway.sourceID && observed.contains(Value(namespace: $0.namespace, value: $0.value))
            }) else { throw .sourceMismatch }
        }

        // 4. Operators.
        let operatorEntities = try current.operatorEntities(registry)
        let previousOperators = try previous?.operatorEntities(nil)
        var summaries: [RevisionSummary] = []
        var working = registry
        for source in current.sources {
            let outcome = try reconcile(
                working, source: source, phase: .operators, observed: operatorEntities, previous: previous, previousObserved: previousOperators,
                inputs: current
            )
            working = outcome.registry
            summaries.append(outcome.summary)
        }

        // 5. Line binding, against the operators just reconciled.
        let lines = try bindLines(current, working, request.launchInputs)

        // 6. Lines.
        let lineEntities = try current.lineEntities(working, bound: lines)
        let previousLines = try previous?.lineEntities(nil, bound: nil)
        for source in current.sources {
            let outcome = try reconcile(
                working, source: source, phase: .lines, observed: lineEntities, previous: previous, previousObserved: previousLines,
                inputs: current
            )
            working = outcome.registry
            summaries.append(outcome.summary)
        }

        // The run's registry: one revision step when anything changed.
        let final: MappingRegistry
        do {
            final = try MappingRegistry(
                revision: working.references == registry.references ? registry.revision : registry.revision + 1,
                entities: registry.entities,
                references: working.references
            )
        } catch {
            throw .reconciliation("registryInvariant")
        }
        let report = ProvisionalRegistryReport(
            reportVersion: ProvisionalRegistryReport.currentVersion,
            gtfs: .init(sourceID: request.gtfsSourceID, sha256: current.archive.sha256, byteCount: current.archive.byteCount),
            railway: current.railway.map { .init(sourceID: $0.sourceID, sha256: $0.sha256, byteCount: $0.byteCount) },
            previousGTFSArchiveSHA256: previous?.archive.sha256,
            previousRailwayInputSHA256: previous?.railway?.sha256,
            grouping: grouping,
            lines: .init(
                lines: lines.lines.count,
                routes: lines.lines.reduce(0) { $0 + $1.routes.count },
                railwayRecords: lines.lines.reduce(0) { $0 + $1.railwayRecords.count },
                acceptedChecks: lines.lines.reduce(0) { $0 + ($1.routes + $1.railwayRecords).reduce(0) { $0 + $1.acceptedChecks.count } }
            ),
            registry: .init(
                previousRevision: registry.revision,
                revision: final.revision,
                operatorEntities: final.entities.filter { $0.id.kind == .railwayOperator }.count,
                lineEntities: final.entities.filter { $0.id.kind == .line }.count,
                activeReferences: final.references.filter { $0.status == .active }.count,
                absentReferences: final.references.filter { $0.status == .absent }.count,
                retiredReferences: final.references.filter { if case .retired = $0.status { true } else { false } }.count
            ),
            reconciliation: summaries
        )

        // 7. Publication of the pair, only now that everything has passed.
        let registryBytes: Data
        do { registryBytes = try final.encoded() } catch { throw .reconciliation("encoding") }
        #if INTAKE_TESTING
        publication.afterFirstFile = afterFirstFile
        #endif
        beforePublication?()
        do {
            try publication.publish([("registry.json", registryBytes), ("report.json", report.encoded())])
        } catch {
            throw .output(error)
        }
        return ProvisionalRegistryResult(registry: final, report: report)
    }

    // MARK: Reading

    static func readFile(
        _ checked: (resolved: String, identity: FileIdentity), _ role: String, _ root: FileIdentity
    ) throws(ProvisionalRegistryError) -> Data {
        do {
            let file = try ArchiveFile(resolvedPath: checked.resolved, limit: fileLimit)
            guard let opened = descriptorPath(file.descriptor), !isInsideRepository(opened, repositoryRoot: root) else {
                throw IntakeError.pathInsideRepository(role: role)
            }
            guard FileIdentity(device: file.initialState.device, inode: file.initialState.inode) == checked.identity else {
                throw IntakeError.inputChanged(reason: "the path no longer names the same file")
            }
            guard let data = try file.readAll(maximum: file.initialState.byteCount),
                  ArchiveFile.state(of: file.descriptor) == file.initialState else {
                throw IntakeError.inputChanged(reason: "the file changed while it was read")
            }
            return data
        } catch let error as IntakeError {
            throw .input(error)
        } catch {
            throw .input(.archiveReadFailed(errno: EIO))
        }
    }

    static func readInputs(
        _ inputs: ProvisionalRegistryRequest.Inputs,
        _ archive: (resolved: String, identity: FileIdentity),
        _ records: (resolved: String, identity: FileIdentity),
        _ gtfsSourceID: String,
        _ railwaySourceID: String?,
        _ root: FileIdentity,
        _ limits: IntakeLimits,
        previous: Bool
    ) async throws(ProvisionalRegistryError) -> RunInputs {
        let read: IdentifiedArchive
        do {
            read = try await ArchiveReading.read(
                requestedPath: inputs.archivePath, resolvedPath: archive.resolved, checked: archive.identity,
                repositoryRoot: root, limits: limits
            )
        } catch {
            throw .input(error)
        }
        var railway: RunInputs.Railway?
        if let path = inputs.railwayPath, let sourceID = railwaySourceID {
            do {
                let (data, records) = try await RailwayValidation.readChecked(path, root)
                railway = .init(sourceID: sourceID, sha256: sha256Hex(data), byteCount: Int64(data.count), records: records)
            } catch {
                throw .railway(error)
            }
        }
        let recordsData = try readFile(records, previous ? "previous records" : "records", root)
        let file: ReviewedRecordsFile
        do {
            file = try ReviewedRecordsFile.decoded(from: recordsData)
        } catch {
            if case .records(let problem) = error { throw previous ? .previousRecords(problem) : .records(problem) }
            throw error
        }
        guard file.gtfsSourceID == gtfsSourceID, file.railwaySourceID == railway?.sourceID,
              file.gtfsArchiveSHA256 == read.sha256, file.railwayInputSHA256 == railway?.sha256 else {
            throw previous ? .previousRecords(.forOtherInput) : .records(.forOtherInput)
        }
        return RunInputs(gtfsSourceID: gtfsSourceID, archive: read, railway: railway, records: file, isPrevious: previous)
    }

    // MARK: Grouping

    private static func groupingOutcome(_ inputs: RunInputs) throws(ProvisionalRegistryError) -> ProvisionalRegistryReport.Grouping {
        let input: GroupingInput
        do {
            input = try GroupingInput(
                sourceID: inputs.gtfsSourceID, archiveSHA256: inputs.archive.sha256,
                stopsMemberSHA256: inputs.archive.memberSHA256("stops.txt")!, feed: inputs.archive.feed
            )
        } catch {
            throw .grouping(kind(error))
        }
        var records: [ReviewedGroupingRecord] = []
        for record in inputs.records.groupings {
            let decision: GroupingDecision
            switch (record.decision, record.exception) {
            case ("rejected", nil):
                decision = .rejected
            case ("accepted", let exception):
                var groupingException: GroupingException?
                if let exception {
                    let checks = exception.waivedChecks.compactMap(GroupingCheck.init(rawValue:))
                    guard checks.count == exception.waivedChecks.count else { throw .records(.invalidRecord) }
                    do { groupingException = try GroupingException(reason: exception.reason, waivedChecks: checks) } catch { throw .records(.invalidRecord) }
                }
                decision = .accepted(exception: groupingException)
            default:
                throw .records(.invalidRecord)
            }
            guard record.stops.allSatisfy({ ExactValue($0) != nil }) else { throw .records(.invalidRecord) }
            do {
                records.append(try ReviewedGroupingRecord(
                    reviewID: record.reviewID, sourceID: inputs.gtfsSourceID, inputSHA256: inputs.archive.sha256,
                    members: record.stops.map { input.stopReference(ExactValue($0)!) },
                    evidenceSHA256: record.evidenceSHA256, decision: decision
                ))
            } catch {
                throw .records(.invalidRecord)
            }
        }
        let outcome: GroupingOutcome
        do {
            let set: ReviewedGroupingSet
            do { set = try ReviewedGroupingSet(records) } catch { throw ProvisionalRegistryError.grouping(kind(error)) }
            outcome = try StationGrouping.apply(set, to: input)
        } catch let error as ProvisionalRegistryError {
            throw error
        } catch {
            throw .grouping(kind(error))
        }
        return .init(
            stopRows: inputs.archive.feed.stops.count,
            operatorLevelIdentities: outcome.identities.count,
            proposals: outcome.report.proposals.count,
            heldBack: outcome.report.heldBack.count,
            accepted: outcome.acceptedReviews.count,
            rejected: outcome.rejectedReviews.count
        )
    }

    // MARK: Line binding

    private static func bindLines(_ inputs: RunInputs, _ registry: MappingRegistry, _ launch: LaunchInputs) throws(ProvisionalRegistryError) -> LineBindingOutcome {
        let input: LineBindingInput
        do {
            input = try inputs.lineBindingInput(registry)
        } catch {
            throw .binding(kind(error))
        }
        var bindings: [ReviewedLineBinding] = []
        for line in inputs.records.lines {
            var members: [LineBindingMember] = []
            for route in line.routes {
                guard let value = ExactValue(route) else { throw .records(.invalidRecord) }
                members.append(input.routeMember(value))
            }
            for id in line.railwayRecords {
                guard let index = inputs.railway?.records.firstIndex(where: { $0.id == id }) else { throw .records(.unknownKey) }
                members.append(input.railwayMember(index))
            }
            var acceptances: [LineBindingAcceptance] = []
            for acceptance in line.acceptances {
                let checks = acceptance.checks.compactMap(LineBindingCheck.init(rawValue:))
                guard checks.count == acceptance.checks.count else { throw .records(.invalidRecord) }
                let member: LineBindingMember
                switch (acceptance.route, acceptance.railwayRecord) {
                case (let route?, nil):
                    guard let value = ExactValue(route) else { throw .records(.invalidRecord) }
                    member = input.routeMember(value)
                case (nil, let id?):
                    guard let index = inputs.railway?.records.firstIndex(where: { $0.id == id }) else { throw .records(.unknownKey) }
                    member = input.railwayMember(index)
                default:
                    throw .records(.invalidRecord)
                }
                do { acceptances.append(try LineBindingAcceptance(member: member, reason: acceptance.reason, acceptedChecks: checks)) } catch { throw .records(.invalidRecord) }
            }
            do {
                bindings.append(try ReviewedLineBinding(
                    reviewID: line.reviewID, lineID: line.lineID, members: members,
                    evidenceSHA256: line.evidenceSHA256, acceptances: acceptances
                ))
            } catch {
                throw .records(.invalidRecord)
            }
        }
        let set: ReviewedLineBindingSet
        do { set = try ReviewedLineBindingSet(bindings) } catch { throw .binding(kind(error)) }
        do {
            return try LineBinding.apply(set, to: input, launchInputs: launch)
        } catch {
            throw .binding(kind(error))
        }
    }

    // MARK: Reconciliation

    enum Phase {
        case operators, lines

        func namespaces(_ source: RunInputs.Source) -> Set<ProviderNamespace> {
            switch (self, source) {
            case (.operators, .gtfs): [.gtfsAgencyID]
            case (.operators, .railway): [.odptOperator]
            case (.lines, .gtfs): [.gtfsRouteID]
            case (.lines, .railway): [.odptRailwayID, .odptRailwaySameAs, .odptRailwayLineCode]
            }
        }
    }

    private static func reconcile(
        _ registry: MappingRegistry,
        source: RunInputs.Source,
        phase: Phase,
        observed: [RunInputs.Entity],
        previous: RunInputs?,
        previousObserved: [RunInputs.Entity]?,
        inputs: RunInputs
    ) throws(ProvisionalRegistryError) -> RevisionOutcome {
        let covered = phase.namespaces(source)
        let sourceID = inputs.sourceID(source)!
        let inputSHA = inputs.sha256(source)!

        func revisionInput(_ entities: [RunInputs.Entity], _ run: RunInputs) throws(ProvisionalRegistryError) -> RevisionInput {
            let mine = entities.compactMap { entity -> ObservedEntity? in
                let references = entity.references.filter { $0.source == source }.map(\.observed)
                return references.isEmpty ? nil : ObservedEntity(kind: entity.identity.kind, references: references)
            }
            do {
                return try RevisionInput(sourceID: sourceID, inputSHA256: run.sha256(source)!, coveredNamespaces: covered, entities: mine)
            } catch {
                throw .reconciliation(kind(error))
            }
        }

        // Attach records: one per key the registry does not hold, from the
        // reviewed record that put the key in its entity. A held key must
        // already resolve to the identity the record names.
        var records: [ReviewedRevisionRecord] = []
        for entity in observed {
            for (index, reference) in entity.references.enumerated() where reference.source == source {
                let key = ProviderReferenceKey(sourceID: sourceID, namespace: reference.observed.namespace, value: reference.observed.value)
                if let held = registry.reference(for: key) {
                    // Held already: it resolves by itself, and no record is
                    // presented for it. It must be the record's identity.
                    guard held.canonicalID == entity.identity else { throw .records(.identityMismatch) }
                    continue
                }
                // A code follows its anchoring key as a descriptive change.
                if RevisionNamespaces.isCode(reference.observed.namespace) { continue }
                do {
                    records.append(try ReviewedRevisionRecord(
                        reviewID: "\(entity.reviewID):\(index)", key: key, inputSHA256: inputSHA, action: .attach(to: entity.identity)
                    ))
                } catch {
                    throw .records(.invalidRecord)
                }
            }
        }
        // The reviewer's own revision records for this source and phase.
        for revision in inputs.records.revisions {
            guard let revisionSource = RunInputs.Source(rawValue: revision.source), inputs.sourceID(revisionSource) != nil,
                  let namespace = ProviderNamespace(rawValue: revision.namespace), let value = ExactValue(revision.value)
            else { throw .records(.unknownKey) }
            guard [Phase.operators, .lines].contains(where: { $0.namespaces(revisionSource).contains(namespace) }) else {
                throw .records(.namespaceNotInRun)
            }
            guard revisionSource == source, covered.contains(namespace) else { continue }
            let action: ReviewedRevisionRecord.Action
            switch (revision.action, revision.identity) {
            case ("retire", nil): action = .retire
            case ("attach", let identity?): action = .attach(to: identity)
            default: throw .records(.invalidRecord)
            }
            do {
                records.append(try ReviewedRevisionRecord(
                    reviewID: revision.reviewID, key: ProviderReferenceKey(sourceID: sourceID, namespace: namespace, value: value),
                    inputSHA256: inputSHA, action: action
                ))
            } catch {
                throw .records(.invalidRecord)
            }
        }

        let input = try revisionInput(observed, inputs)
        // With no previous run, the previous observations are empty. Step 4
        // still refuses them if the registry holds an active reference in
        // these namespaces: it would be neither last seen there nor contained.
        let previousInput: RevisionInput
        if let previous, let previousObserved, previous.sourceID(source) != nil {
            previousInput = try revisionInput(previousObserved, previous)
        } else {
            do {
                previousInput = try RevisionInput(sourceID: sourceID, inputSHA256: inputSHA, coveredNamespaces: covered, entities: [])
            } catch {
                throw .reconciliation(kind(error))
            }
        }
        let set: ReviewedRevisionSet
        do { set = try ReviewedRevisionSet(records) } catch { throw .records(.duplicateKey) }
        do {
            return try RevisionReconciliation.reconcile(registry, with: input, previous: previousInput, records: set)
        } catch {
            switch error {
            case .conflicts: throw .conflicts(error.conflictCounts)
            case .undecided(let transition, _): throw .undecided(transition.rawValue)
            case .record(let problem, _): throw .reconciliation(problem.rawValue)
            case .previousInput(let problem): throw .reconciliation("previousInput." + problem.rawValue)
            case .registryInvariant: throw .reconciliation("registryInvariant")
            }
        }
    }
}

// MARK: - One run's inputs as observations

struct RunInputs {
    enum Source: String, Hashable {
        case gtfs, railway
    }

    struct Railway {
        let sourceID: String
        let sha256: String
        let byteCount: Int64
        let records: [ODPTRailway]
    }

    struct Reference {
        let source: Source
        let observed: ObservedReference
    }

    /// One reviewed operator or line, as the references this input shows.
    struct Entity {
        let reviewID: String
        let identity: MintedIdentifier
        let references: [Reference]
    }

    let gtfsSourceID: String
    let archive: IdentifiedArchive
    let railway: Railway?
    let records: ReviewedRecordsFile
    let isPrevious: Bool

    var sources: [Source] { railway == nil ? [.gtfs] : [.gtfs, .railway] }

    func sourceID(_ source: Source) -> String? {
        source == .gtfs ? gtfsSourceID : railway?.sourceID
    }

    func sha256(_ source: Source) -> String? {
        source == .gtfs ? archive.sha256 : railway?.sha256
    }

    private func problem(_ problem: ProvisionalRegistryError.RecordsProblem) -> ProvisionalRegistryError {
        isPrevious ? .previousRecords(problem) : .records(problem)
    }

    private var feedLanguage: String? {
        let feed = archive.feed
        return feed.feedInfo.first.map(\.language) ?? (feed.agencies.count == 1 ? feed.agencies[0].language : nil)
    }

    private func gtfsReference(_ member: String, _ table: String, _ field: String, _ key: ExactValue) -> SourceReference {
        try! SourceReference(
            inputSHA256: archive.sha256, member: .init(name: member, sha256: archive.memberSHA256(member)!),
            table: table, recordIndex: nil, field: field, providerKey: key
        )
    }

    private func railwayReference(_ index: Int, _ field: String) -> SourceReference {
        try! SourceReference(
            inputSHA256: railway!.sha256, member: nil, table: nil, recordIndex: index, field: field,
            providerKey: ExactValue(railway!.records[index].id)!
        )
    }

    /// Distinct by language and value, first kept.
    private func names(_ entries: [(String, String, SourceReference)]) -> [OriginalName] {
        var seen = Set<[String]>()
        return entries.compactMap { language, value, source in
            guard let language = ExactValue(language), let value = ExactValue(value),
                  seen.insert([language.text, value.text]).inserted else { return nil }
            return OriginalName(language: language, value: value, source: source)
        }
    }

    /// Reviewed operators (DEC-068 §D1): the agency and `odpt:operator` keys
    /// each record names, as this input shows them.
    func operatorEntities(_ registry: MappingRegistry?) throws(ProvisionalRegistryError) -> [Entity] {
        var used = Set<[String]>()
        var entities: [Entity] = []
        for record in records.operators {
            guard record.operatorID.kind == .railwayOperator, MappingText.isToken(record.reviewID) else { throw problem(.invalidRecord) }
            var references: [Reference] = []
            if let agencyID = record.gtfsAgencyID {
                guard let value = ExactValue(agencyID), let agency = archive.feed.agencies.first(where: { $0.agencyID == agencyID }) else {
                    throw problem(.unknownKey)
                }
                guard used.insert(["gtfs", agencyID]).inserted else { throw problem(.duplicateKey) }
                let source = gtfsReference("agency.txt", "agency", "agency_id", value)
                let language = agency.language ?? feedLanguage
                references.append(Reference(source: .gtfs, observed: ObservedReference(
                    namespace: .gtfsAgencyID, value: value, provenance: source,
                    originalNames: names(language.map { [($0, agency.name, gtfsReference("agency.txt", "agency", "agency_name", value))] } ?? [])
                )))
            }
            if let odptOperator = record.odptOperator {
                guard let railway, let value = ExactValue(odptOperator),
                      let index = railway.records.firstIndex(where: { $0.operatorReference == odptOperator }) else {
                    throw problem(.unknownKey)
                }
                guard used.insert(["railway", odptOperator]).inserted else { throw problem(.duplicateKey) }
                references.append(Reference(source: .railway, observed: ObservedReference(
                    namespace: .odptOperator, value: value, provenance: railwayReference(index, "odpt:operator"), originalNames: []
                )))
            }
            guard !references.isEmpty else { throw problem(.invalidRecord) }
            entities.append(Entity(reviewID: record.reviewID, identity: record.operatorID, references: references))
        }
        return entities
    }

    func lineBindingInput(_ registry: MappingRegistry) throws -> LineBindingInput {
        try LineBindingInput(
            gtfs: .init(
                sourceID: gtfsSourceID, archiveSHA256: archive.sha256,
                routesMemberSHA256: archive.memberSHA256("routes.txt")!, stopsMemberSHA256: archive.memberSHA256("stops.txt")!,
                feed: archive.feed
            ),
            railway: railway.map { .init(sourceID: $0.sourceID, inputSHA256: $0.sha256, records: $0.records) },
            registry: registry
        )
    }

    /// Reviewed lines: each bound route's `route_id`, and each bound Railway
    /// record's `@id` and line code. For the current run, `bound` is the
    /// checked outcome of line binding; for the previous input, the records
    /// alone say which keys belonged together.
    func lineEntities(_ registry: MappingRegistry?, bound: LineBindingOutcome?) throws(ProvisionalRegistryError) -> [Entity] {
        let translations = archive.feed.translations.filter { $0.tableName == "routes" && $0.fieldName == "route_long_name" }
        var entities: [Entity] = []
        for line in records.lines {
            if let bound { guard bound.lines.contains(where: { $0.reviewID == line.reviewID }) else { throw problem(.unknownKey) } }
            var references: [Reference] = []
            for routeID in line.routes {
                guard let value = ExactValue(routeID), let route = archive.feed.routes.first(where: { $0.routeID == routeID }) else {
                    throw problem(.unknownKey)
                }
                var entries: [(String, String, SourceReference)] = []
                if let longName = route.longName {
                    if let feedLanguage { entries.append((feedLanguage, longName, gtfsReference("routes.txt", "routes", "route_long_name", value))) }
                    for row in translations where row.fieldValue == longName {
                        entries.append((row.language, row.translation, gtfsReference("translations.txt", "translations", "translation", value)))
                    }
                }
                references.append(Reference(source: .gtfs, observed: ObservedReference(
                    namespace: .gtfsRouteID, value: value, provenance: gtfsReference("routes.txt", "routes", "route_id", value),
                    originalNames: names(entries)
                )))
            }
            for id in line.railwayRecords {
                guard let railway, let index = railway.records.firstIndex(where: { $0.id == id }), let value = ExactValue(id) else {
                    throw problem(.unknownKey)
                }
                let record = railway.records[index]
                let titles = record.title.entries.map { ($0.language, $0.text, railwayReference(index, "odpt:railwayTitle")) }
                references.append(Reference(source: .railway, observed: ObservedReference(
                    namespace: .odptRailwayID, value: value, provenance: railwayReference(index, "@id"), originalNames: names(titles)
                )))
                // `owl:sameAs` identifies the record too (DEC-068 §C1): its
                // own reference, with its own provenance.
                if let sameAs = ExactValue(record.sameAs) {
                    references.append(Reference(source: .railway, observed: ObservedReference(
                        namespace: .odptRailwaySameAs, value: sameAs, provenance: railwayReference(index, "owl:sameAs"), originalNames: []
                    )))
                }
                if let code = ExactValue(record.lineCode) {
                    references.append(Reference(source: .railway, observed: ObservedReference(
                        namespace: .odptRailwayLineCode, value: code, provenance: railwayReference(index, "odpt:lineCode"), originalNames: []
                    )))
                }
            }
            guard line.lineID.kind == .line, MappingText.isToken(line.reviewID) else { throw problem(.invalidRecord) }
            entities.append(Entity(reviewID: line.reviewID, identity: line.lineID, references: references))
        }
        return entities
    }
}

extension ProvisionalRegistryCommand {
    /// Reads and decodes a provisional registry file under the input checks.
    static func readRegistry(_ path: String, repositoryRoot root: FileIdentity) throws(ProvisionalRegistryError) -> MappingRegistry {
        let checked: (resolved: String, identity: FileIdentity)
        do { checked = try ArchiveReading.checkedPath(path, role: "registry", repositoryRoot: root) } catch { throw .input(error) }
        let data = try readFile(checked, "registry", root)
        do { return try MappingRegistry.decoded(from: data) } catch { throw .registryFile }
    }
}

// MARK: - mint

/// DEC-068 §B2: an identifier is minted only on explicit request. Adds
/// `count` provisional entities of one kind to a registry; nothing else.
/// No identifier minted here is a production identifier (§B6).
enum ProvisionalMint {
    enum Refused: Error { case stationKind }

    static func mint(_ kind: CanonicalKind, count: Int, into registry: MappingRegistry) throws -> MappingRegistry {
        guard kind != .station else { throw Refused.stationKind }
        var working = registry
        for _ in 0..<count {
            let id = try IdentifierMinter.mint(kind, for: working)
            working = try MappingRegistry(
                revision: working.revision, entities: working.entities + [CanonicalEntity(id: id, status: .active)],
                references: working.references
            )
        }
        return try MappingRegistry(revision: registry.revision + 1, entities: working.entities, references: working.references)
    }
}

extension ProvisionalMint {
    /// The `mint` command: reads the registry (or starts empty), mints, and
    /// publishes the new registry as one new file that replaces nothing.
    static func run(
        kind: CanonicalKind, count: Int, registryPath: String?, outputPath: String, repositoryRoot root: FileIdentity
    ) throws(ProvisionalRegistryError) -> MappingRegistry {
        // Operators and lines only: no StationID is minted in P2-S4 (DEC-068 §D2).
        guard (1...1000).contains(count), kind != .station else { throw .arguments }
        let publication: ManifestPublication
        do {
            let name = (outputPath as NSString).lastPathComponent
            guard !name.isEmpty, name != ".", name != "..", !outputPath.hasSuffix("/") else { throw IntakeError.outputNameInvalid }
            let requested = (outputPath as NSString).deletingLastPathComponent
            guard let parent = resolvedPath(requested.isEmpty ? "." : requested) else {
                throw IntakeError.pathUnavailable(role: "output directory", errno: errno)
            }
            guard !isInsideRepository(parent, repositoryRoot: root) else { throw IntakeError.pathInsideRepository(role: "output") }
            publication = try ManifestPublication(checkedDirectory: parent, name: name, repositoryRoot: root)
            guard !publication.targetExists() else { throw IntakeError.outputExists }
        } catch let error as IntakeError {
            throw .output(error)
        } catch {
            throw .output(.publicationFailed(errno: EIO))
        }
        let registry = try registryPath.map { path throws(ProvisionalRegistryError) in
            try ProvisionalRegistryCommand.readRegistry(path, repositoryRoot: root)
        } ?? .empty
        let minted: MappingRegistry
        let bytes: Data
        do {
            minted = try mint(kind, count: count, into: registry)
            bytes = try minted.encoded()
        } catch {
            throw .reconciliation("minting")
        }
        do { try publication.publish(bytes) } catch { throw .output(error) }
        return minted
    }
}
