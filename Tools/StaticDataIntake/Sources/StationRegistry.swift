import Foundation

// station-packet and station-registry — DEC-069's cross-operator station
// commands. Offline tool only; every input and output lies outside the
// repository.
//
// Both read the same inputs: two operators' identified GTFS archives (each
// with its optional Railway file) and their reviewed P2-S4 records files, the
// provisional registry, and — once written — the reviewer's cross-operator
// records. The two sides must resolve, through the registry, to two
// different reviewed operators.
//
//   - station-packet is read-only. It exports one new owner-only file: every
//     candidate with its evidence, discovery reasons, and digest, a record
//     template per candidate, and — once every candidate is decided — the
//     canonical station groups with an assignment template. It decides
//     nothing and mints nothing. Only counts are printed.
//   - station-registry needs every candidate decided and every group
//     assigned to a held, active, provisional StationID. It attaches each
//     group's `stop_id` references through the assignment's reviewed record,
//     with `stop_code` following as a descriptive code (DEC-068 §E3), using
//     the Step 4 reconciliation per source. It publishes the registry and a
//     report of aggregates together, or nothing.
//
// An `ambiguous` record keeps two stations and adds nothing to the registry.
// No distance is computed. Nothing here is a production identifier.

// MARK: - Cross-operator records file

/// The reviewer's cross-operator decisions and station assignments for one
/// pair of identified inputs.
struct CrossOperatorRecordsFile: Decodable {
    static let currentVersion = 1

    struct Input: Decodable {
        let gtfsSourceID: String
        let gtfsArchiveSHA256: String
        private enum CodingKeys: String, CodingKey, CaseIterable { case gtfsSourceID, gtfsArchiveSHA256 }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            gtfsSourceID = try c.decode(String.self, forKey: .gtfsSourceID)
            gtfsArchiveSHA256 = try c.decode(String.self, forKey: .gtfsArchiveSHA256)
        }
    }

    struct Side: Decodable {
        let gtfsSourceID: String
        let stops: [String]
        private enum CodingKeys: String, CodingKey, CaseIterable { case gtfsSourceID, stops }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            gtfsSourceID = try c.decode(String.self, forKey: .gtfsSourceID)
            stops = try c.decode([String].self, forKey: .stops)
        }
    }

    struct Decision: Decodable {
        let reviewID: String
        let sides: [Side]
        let evidenceSHA256: String
        let outcome: String
        let reason: String
        let citedAliasRules: [String]
        let evidenceProvenance: [String]
        private enum CodingKeys: String, CodingKey, CaseIterable {
            case reviewID, sides, evidenceSHA256, outcome, reason, citedAliasRules, evidenceProvenance
        }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            sides = try c.decode([Side].self, forKey: .sides)
            evidenceSHA256 = try c.decode(String.self, forKey: .evidenceSHA256)
            outcome = try c.decode(String.self, forKey: .outcome)
            reason = try c.decode(String.self, forKey: .reason)
            citedAliasRules = try c.decodeIfPresent([String].self, forKey: .citedAliasRules) ?? []
            evidenceProvenance = try c.decodeIfPresent([String].self, forKey: .evidenceProvenance) ?? []
        }
    }

    struct Station: Decodable {
        let reviewID: String
        let stationID: MintedIdentifier
        let sides: [Side]
        private enum CodingKeys: String, CodingKey, CaseIterable { case reviewID, stationID, sides }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            reviewID = try c.decode(String.self, forKey: .reviewID)
            stationID = try c.decode(MintedIdentifier.self, forKey: .stationID)
            sides = try c.decode([Side].self, forKey: .sides)
        }
    }

    let inputs: [Input]
    let decisions: [Decision]
    let stations: [Station]

    private enum CodingKeys: String, CodingKey, CaseIterable { case schemaVersion, inputs, decisions, stations }

    init(from decoder: any Decoder) throws {
        try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guard try c.decode(Int.self, forKey: .schemaVersion) == Self.currentVersion else {
            throw MappingText.corrupted("unsupportedSchemaVersion", c)
        }
        inputs = try c.decode([Input].self, forKey: .inputs)
        decisions = try c.decodeIfPresent([Decision].self, forKey: .decisions) ?? []
        stations = try c.decodeIfPresent([Station].self, forKey: .stations) ?? []
    }

    static func decoded(from data: Data) throws(ProvisionalRegistryError) -> CrossOperatorRecordsFile {
        guard !RegistryJSON.repeatsKey([UInt8](data)) else { throw .records(.repeatedKey) }
        do { return try JSONDecoder().decode(CrossOperatorRecordsFile.self, from: data) } catch { throw .records(.malformed) }
    }
}

// MARK: - Request and report

struct StationRunRequest {
    struct Side {
        let gtfsSourceID: String
        let archivePath: String
        let recordsPath: String
        let railwaySourceID: String?
        let railwayPath: String?
    }

    struct Previous {
        let sides: [Side]
        let crossRecordsPath: String
    }

    /// Exactly two, of different sources.
    let sides: [Side]
    let registryPath: String
    /// Required by station-registry; optional for station-packet.
    let crossRecordsPath: String?
    /// The inputs and records the registry's station references were last
    /// reconciled with, once it holds any (station-registry only).
    let previous: Previous?
    let outputPath: String
}

/// Aggregates only: counts, hashes, revisions, and source identifiers.
struct StationRegistryReport: Encodable, Equatable {
    struct Side: Encodable, Equatable {
        let sourceID: String
        let archiveSHA256: String
        let stopRows: Int
        let operatorLevelIdentities: Int
        let singletonStations: Int
    }

    struct Candidates: Encodable, Equatable {
        let total: Int
        /// Candidates carrying each key, by key name.
        let byKey: [String: Int]
        let same: Int
        let distinct: Int
        let ambiguous: Int
    }

    struct Stations: Encodable, Equatable {
        let total: Int
        let merged: Int
        let duplicateAssignments: Int
        let unmappedIdentities: Int
        let unassignedStationEntities: Int
    }

    struct Registry: Encodable, Equatable {
        let previousRevision: Int
        let revision: Int
        let stationEntities: Int
        let activeStationReferences: Int
        let activeReferences: Int
    }

    let reportVersion: Int
    let sides: [Side]
    let candidates: Candidates
    let stations: Stations
    let registry: Registry
    let reconciliation: [RevisionSummary]

    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try! encoder.encode(self)
        data.append(0x0A)
        return data
    }
}

struct StationRegistryResult: Equatable {
    let registry: MappingRegistry
    let report: StationRegistryReport
}

/// What station-packet prints: counts only.
struct StationPacketSummary: Equatable {
    let candidates: Int
    let reviewed: Int
    let unreviewed: Int
    let groups: Int?

    func report() -> String {
        """
        candidates: \(candidates) (\(reviewed) reviewed, \(unreviewed) unreviewed)
        canonical station groups: \(groups.map(String.init) ?? "- (every candidate must be decided first)")

        """
    }
}

// MARK: - Shared pipeline

enum StationCommand {
    struct Loaded {
        let registry: MappingRegistry
        let runs: [RunInputs]
        let sides: [StationSideInput]
        let formation: StationFormation
        let records: CrossOperatorRecordsFile?
    }

    static func checkedPath(_ path: String, _ role: String, _ root: FileIdentity) throws(ProvisionalRegistryError) -> (resolved: String, identity: FileIdentity) {
        do { return try ArchiveReading.checkedPath(path, role: role, repositoryRoot: root) } catch { throw .input(error) }
    }

    /// Reads and checks every input, applies the P2-S4 groupings, proposes the
    /// candidates, and applies any cross-operator decisions.
    static func load(
        _ sides: [StationRunRequest.Side], crossRecords: String?, registry: MappingRegistry,
        _ root: FileIdentity, previous: Bool
    ) async throws(ProvisionalRegistryError) -> Loaded {
        guard sides.count == 2, sides[0].gtfsSourceID != sides[1].gtfsSourceID,
              sides.allSatisfy({ ($0.railwaySourceID == nil) == ($0.railwayPath == nil) && MappingText.isToken($0.gtfsSourceID) })
        else { throw .arguments }
        var runs: [RunInputs] = []
        for side in sides {
            let archive = try checkedPath(side.archivePath, previous ? "previous archive" : "archive", root)
            let records = try checkedPath(side.recordsPath, previous ? "previous records" : "records", root)
            runs.append(try await ProvisionalRegistryCommand.readInputs(
                .init(archivePath: side.archivePath, railwayPath: side.railwayPath, recordsPath: side.recordsPath),
                archive, records, side.gtfsSourceID, side.railwaySourceID, root, .standard, previous: previous
            ))
        }
        // Each side is one reviewed operator, and the two differ.
        var operators: [MintedIdentifier] = []
        for run in runs {
            let resolved = Set(run.archive.feed.agencies.map { agency -> MintedIdentifier? in
                guard let value = agency.agencyID.flatMap(ExactValue.init) else { return nil }
                return registry.resolve(ProviderReferenceKey(sourceID: run.gtfsSourceID, namespace: .gtfsAgencyID, value: value))
            })
            guard resolved.count == 1, let only = resolved.first, let identity = only else { throw .stations("sideOperatorUnresolved") }
            operators.append(identity)
        }
        guard operators[0] != operators[1] else { throw .stations("sidesShareOperator") }

        var stationSides: [StationSideInput] = []
        for run in runs {
            let (grouping, outcome) = try ProvisionalRegistryCommand.appliedGrouping(run)
            stationSides.append(StationSideInput(
                grouping: grouping, translationsMemberSHA256: run.archive.memberSHA256("translations.txt"), identities: outcome.identities
            ))
        }

        var file: CrossOperatorRecordsFile?
        var set = ReviewedCrossOperatorSet.empty
        if let crossRecords {
            let checked = try checkedPath(crossRecords, previous ? "previous cross-operator records" : "cross-operator records", root)
            let data = try ProvisionalRegistryCommand.readFile(checked, "cross-operator records", root)
            let decoded: CrossOperatorRecordsFile
            do { decoded = try CrossOperatorRecordsFile.decoded(from: data) } catch {
                if previous, case .records(let problem) = error { throw .previousRecords(problem) }
                throw error
            }
            let expected = Set(stationSides.map { [$0.sourceID, $0.archiveSHA256] })
            guard decoded.inputs.count == 2, Set(decoded.inputs.map { [$0.gtfsSourceID, $0.gtfsArchiveSHA256] }) == expected else {
                throw previous ? .previousRecords(.forOtherInput) : .records(.forOtherInput)
            }
            set = try decisions(decoded, stationSides)
            file = decoded
        }
        let formation: StationFormation
        do { formation = try CrossOperatorStations.apply(set, to: stationSides) } catch { throw .stations(kind(error)) }
        return Loaded(registry: registry, runs: runs, sides: stationSides, formation: formation, records: file)
    }

    static func side(_ entry: CrossOperatorRecordsFile.Side, _ sides: [StationSideInput]) throws(ProvisionalRegistryError) -> CrossOperatorSide {
        guard let input = sides.first(where: { $0.sourceID == entry.gtfsSourceID }) else { throw .records(.forOtherInput) }
        var members: [SourceReference] = []
        for stop in entry.stops {
            guard let value = ExactValue(stop) else { throw .records(.invalidRecord) }
            members.append(input.grouping.stopReference(value))
        }
        do { return try CrossOperatorSide(sourceID: input.sourceID, inputSHA256: input.archiveSHA256, members: members) } catch {
            throw .records(.invalidRecord)
        }
    }

    static func decisions(_ file: CrossOperatorRecordsFile, _ sides: [StationSideInput]) throws(ProvisionalRegistryError) -> ReviewedCrossOperatorSet {
        var records: [ReviewedCrossOperatorRecord] = []
        for decision in file.decisions {
            guard let outcome = CrossOperatorOutcome(rawValue: decision.outcome) else { throw .records(.invalidRecord) }
            let rules = decision.citedAliasRules.compactMap(StationAliasRule.init(rawValue:))
            let provenance = decision.evidenceProvenance.compactMap(CrossOperatorEvidenceProvenance.init)
            guard rules.count == decision.citedAliasRules.count, provenance.count == decision.evidenceProvenance.count else {
                throw .records(.invalidRecord)
            }
            var recordSides: [CrossOperatorSide] = []
            for entry in decision.sides { recordSides.append(try side(entry, sides)) }
            do {
                records.append(try ReviewedCrossOperatorRecord(
                    reviewID: decision.reviewID, sides: recordSides, evidenceSHA256: decision.evidenceSHA256, outcome: outcome,
                    reason: decision.reason, citedAliasRules: rules, evidenceProvenance: provenance
                ))
            } catch {
                throw .records(.invalidRecord)
            }
        }
        do { return try ReviewedCrossOperatorSet(records) } catch { throw .stations(kind(error)) }
    }

    /// The reviewed station assignments, checked against the formed groups:
    /// each group assigned once, to a held, active StationID.
    static func assignments(_ loaded: Loaded) throws(ProvisionalRegistryError) -> ReviewedStationAssignmentSet {
        guard loaded.formation.unreviewed.isEmpty else { throw .stations("unreviewedCandidates") }
        var records: [ReviewedStationAssignment] = []
        for station in loaded.records?.stations ?? [] {
            var stationSides: [CrossOperatorSide] = []
            for entry in station.sides { stationSides.append(try side(entry, loaded.sides)) }
            do {
                records.append(try ReviewedStationAssignment(reviewID: station.reviewID, stationID: station.stationID, sides: stationSides))
            } catch {
                throw .records(.invalidRecord)
            }
        }
        let set: ReviewedStationAssignmentSet
        do { set = try ReviewedStationAssignmentSet(records) } catch { throw .stations(kind(error)) }
        let groups = Set(loaded.formation.groups.map(\.sides))
        for record in set.records {
            guard groups.contains(record.sides) else { throw .stations("assignmentNotAGroup") }
            guard let entity = loaded.registry.entity(record.stationID) else { throw .stations("unknownStation") }
            guard entity.status == .active else { throw .stations("retiredStation") }
            // A station holding references of a source outside this group
            // would join them to it without a reviewed `same` (DEC-069 §C3).
            let sources = Set(record.sides.map(\.sourceID))
            guard loaded.registry.references.allSatisfy({ $0.canonicalID != record.stationID || sources.contains($0.sourceID) }) else {
                throw .stations("stationHeldElsewhere")
            }
        }
        guard set.records.count == groups.count else { throw .stations("unassignedGroup") }
        return set
    }

    /// Each assigned group's references in one side's input: its `stop_id`
    /// rows, with names and serving routes, and their `stop_code` values.
    static func entities(_ loaded: Loaded, _ set: ReviewedStationAssignmentSet, side index: Int) throws(ProvisionalRegistryError) -> [RunInputs.Entity] {
        let input = loaded.sides[index]
        // A code identifies no row by itself: one code value per station, and
        // a code shared by two stations of one source cannot follow either.
        var codeStation: [ExactValue: MintedIdentifier] = [:]
        let evidence = Dictionary(uniqueKeysWithValues: CrossOperatorStations.memberEvidence(input).map { ($0.stopID, $0) })
        let stopsMember = SourceReference.Member(name: "stops.txt", sha256: input.grouping.stopsMemberSHA256)
        var entities: [RunInputs.Entity] = []
        for record in set.records {
            guard let side = record.sides.first(where: { $0.sourceID == input.sourceID }) else { continue }
            var references: [RunInputs.Reference] = []
            for member in side.members {
                let row = evidence[member.providerKey]!
                references.append(RunInputs.Reference(source: .gtfs, observed: ObservedReference(
                    namespace: .gtfsStopID, value: member.providerKey, provenance: member, originalNames: row.names,
                    routes: row.base.routes.map(\.routeID)
                )))
                if let code = row.base.code {
                    if let held = codeStation[code] {
                        guard held == record.stationID else { throw .stations("stopCodeInTwoStations") }
                        continue
                    }
                    codeStation[code] = record.stationID
                    let provenance = try! SourceReference(
                        inputSHA256: input.archiveSHA256, member: stopsMember, table: "stops", recordIndex: nil,
                        field: "stop_code", providerKey: member.providerKey
                    )
                    references.append(RunInputs.Reference(source: .gtfs, observed: ObservedReference(
                        namespace: .gtfsStopCode, value: code, provenance: provenance, originalNames: []
                    )))
                }
            }
            entities.append(RunInputs.Entity(reviewID: record.reviewID, identity: record.stationID, references: references))
        }
        return entities
    }
}

// MARK: - station-registry

enum StationRegistryCommand {
    static let covered: Set<ProviderNamespace> = [.gtfsStopID, .gtfsStopCode]

    static func run(_ request: StationRunRequest, repositoryRoot root: FileIdentity) async throws(ProvisionalRegistryError) -> StationRegistryResult {
        guard let crossRecords = request.crossRecordsPath else { throw .arguments }
        let registryPath = try StationCommand.checkedPath(request.registryPath, "registry", root)
        let publication = try outputDirectory(request.outputPath, root)
        let registryData = try ProvisionalRegistryCommand.readFile(registryPath, "registry", root)
        let registry: MappingRegistry
        do { registry = try MappingRegistry.decoded(from: registryData) } catch { throw .registryFile }
        let current = try await StationCommand.load(request.sides, crossRecords: crossRecords, registry: registry, root, previous: false)
        let assignments = try StationCommand.assignments(current)

        var previousLoaded: (StationCommand.Loaded, ReviewedStationAssignmentSet)?
        if let previous = request.previous {
            let loaded = try await StationCommand.load(previous.sides, crossRecords: previous.crossRecordsPath, registry: registry, root, previous: true)
            guard Set(loaded.sides.map(\.sourceID)) == Set(current.sides.map(\.sourceID)) else { throw .arguments }
            previousLoaded = (loaded, try StationCommand.assignments(loaded))
        }

        var working = registry
        var summaries: [RevisionSummary] = []
        for index in current.sides.indices {
            let sourceID = current.sides[index].sourceID
            let observed = try StationCommand.entities(current, assignments, side: index)
            let previousInput: RevisionInput
            if let (loaded, set) = previousLoaded, let previousIndex = loaded.sides.firstIndex(where: { $0.sourceID == sourceID }) {
                previousInput = try revisionInput(try StationCommand.entities(loaded, set, side: previousIndex), sourceID, loaded.sides[previousIndex].archiveSHA256)
            } else {
                // Once the registry holds station references of this source,
                // the inputs it was last reconciled with are required.
                guard !working.references.contains(where: { $0.sourceID == sourceID && $0.status == .active && covered.contains($0.namespace) }) else {
                    throw .reconciliation("previousInput.required")
                }
                previousInput = try revisionInput([], sourceID, current.sides[index].archiveSHA256)
            }
            let input = try revisionInput(observed, sourceID, current.sides[index].archiveSHA256)
            var records: [ReviewedRevisionRecord] = []
            for entity in observed {
                for (position, reference) in entity.references.enumerated() {
                    let key = ProviderReferenceKey(sourceID: sourceID, namespace: reference.observed.namespace, value: reference.observed.value)
                    if let held = working.reference(for: key) {
                        guard held.canonicalID == entity.identity else { throw .records(.identityMismatch) }
                        continue
                    }
                    if RevisionNamespaces.isCode(reference.observed.namespace) { continue }
                    do {
                        records.append(try ReviewedRevisionRecord(
                            reviewID: "\(entity.reviewID):\(position)", key: key, inputSHA256: current.sides[index].archiveSHA256,
                            action: .attach(to: entity.identity)
                        ))
                    } catch {
                        throw .records(.invalidRecord)
                    }
                }
            }
            let set: ReviewedRevisionSet
            do { set = try ReviewedRevisionSet(records) } catch { throw .records(.duplicateKey) }
            do {
                let outcome = try RevisionReconciliation.reconcile(working, with: input, previous: previousInput, records: set)
                working = outcome.registry
                summaries.append(outcome.summary)
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

        let final: MappingRegistry
        do {
            final = try MappingRegistry(
                revision: working.references == registry.references ? registry.revision : registry.revision + 1,
                entities: registry.entities, references: working.references
            )
        } catch {
            throw .reconciliation("registryInvariant")
        }
        let report = makeReport(current, assignments, previous: registry, final: final, summaries: summaries)
        let registryBytes: Data
        do { registryBytes = try final.encoded() } catch { throw .reconciliation("encoding") }
        do { try publication.publish([("registry.json", registryBytes), ("report.json", report.encoded())]) } catch { throw .output(error) }
        return StationRegistryResult(registry: final, report: report)
    }

    private static func revisionInput(_ entities: [RunInputs.Entity], _ sourceID: String, _ sha: String) throws(ProvisionalRegistryError) -> RevisionInput {
        do {
            return try RevisionInput(
                sourceID: sourceID, inputSHA256: sha, coveredNamespaces: covered,
                entities: entities.map { ObservedEntity(kind: .station, references: $0.references.map(\.observed)) }
            )
        } catch {
            throw .reconciliation(kind(error))
        }
    }

    static func outputDirectory(_ path: String, _ root: FileIdentity) throws(ProvisionalRegistryError) -> DirectoryPublication {
        do {
            let name = (path as NSString).lastPathComponent
            guard !name.isEmpty, name != ".", name != "..", !path.hasSuffix("/") else { throw IntakeError.outputNameInvalid }
            let requested = (path as NSString).deletingLastPathComponent
            guard let parent = resolvedPath(requested.isEmpty ? "." : requested) else {
                throw IntakeError.pathUnavailable(role: "output directory", errno: errno)
            }
            guard !isInsideRepository(parent, repositoryRoot: root) else { throw IntakeError.pathInsideRepository(role: "output") }
            let publication = try DirectoryPublication(checkedDirectory: parent, name: name, repositoryRoot: root)
            guard !publication.targetExists() else { throw IntakeError.outputExists }
            return publication
        } catch let error as IntakeError {
            throw .output(error)
        } catch {
            throw .output(.publicationFailed(errno: EIO))
        }
    }

    private static func makeReport(
        _ loaded: StationCommand.Loaded, _ assignments: ReviewedStationAssignmentSet,
        previous: MappingRegistry, final: MappingRegistry, summaries: [RevisionSummary]
    ) -> StationRegistryReport {
        let formation = loaded.formation
        let groups = formation.groups
        var byKey: [String: Int] = [:]
        for key in StationCandidateKey.all { byKey[key.name] = formation.report.candidates.filter { $0.keys.contains(key) }.count }
        // Every identity must be in exactly one group.
        var seen: [CrossOperatorSide: Int] = [:]
        for group in groups { for side in group.sides { seen[side, default: 0] += 1 } }
        let identities = loaded.sides.flatMap { input in input.identities.map { input.side($0) } }
        let assigned = Set(assignments.records.map(\.stationID))
        let stationEntities = final.entities.filter { $0.id.kind == .station }
        return StationRegistryReport(
            reportVersion: 1,
            sides: loaded.sides.map { input in
                .init(
                    sourceID: input.sourceID, archiveSHA256: input.archiveSHA256, stopRows: input.grouping.feed.stops.count,
                    operatorLevelIdentities: input.identities.count,
                    singletonStations: groups.filter { $0.sides.count == 1 && $0.sides[0].sourceID == input.sourceID }.count
                )
            },
            candidates: .init(
                total: formation.report.candidates.count, byKey: byKey,
                same: formation.same, distinct: formation.distinct, ambiguous: formation.ambiguous
            ),
            stations: .init(
                total: groups.count, merged: groups.filter { $0.sides.count == 2 }.count,
                duplicateAssignments: seen.values.filter { $0 > 1 }.count,
                unmappedIdentities: identities.filter { seen[$0] == nil }.count,
                unassignedStationEntities: stationEntities.filter { $0.status == .active && !assigned.contains($0.id) }.count
            ),
            registry: .init(
                previousRevision: previous.revision, revision: final.revision, stationEntities: stationEntities.count,
                activeStationReferences: final.references.filter { $0.canonicalID.kind == .station && $0.status == .active }.count,
                activeReferences: final.references.filter { $0.status == .active }.count
            ),
            reconciliation: summaries
        )
    }
}

// MARK: - station-packet

/// The owner-only review export. It holds provider values: names, stop
/// identifiers, codes, coordinates. It stays with the inputs, never committed.
struct StationPacket: Encodable {
    static let notice = "Contains provider values. Keep outside the repository with its inputs; never commit or publish. Candidates come from names and the two alias rules only: differently named stations they do not relate are not listed (DEC-069 B4)."

    struct Name: Encodable {
        let language: String
        let value: String
        let field: String
    }

    struct Route: Encodable {
        let routeID: String
        let longName: String?
        let codeFitsRoute: Bool
        let neighbors: [String]
        /// Station-order positions: every `stop_sequence` value on this route.
        let positions: [Int]
    }

    struct Member: Encodable {
        let stopID: String
        let code: String?
        let names: [Name]
        let routes: [Route]
        /// The decoded provider values: never compared or measured.
        let latitude: String
        let longitude: String
    }

    struct Side: Encodable {
        let gtfsSourceID: String
        let stops: [String]
        let members: [Member]
        let lineMembership: [String]
        let multiLineOccurrence: Int
    }

    struct Match: Encodable {
        let first: String
        let firstLanguage: String
        let second: String
        let secondLanguage: String
        /// For an alias key: the shared comparison key. The originals above
        /// are never rewritten.
        let comparisonKey: String?
    }

    struct Reason: Encodable {
        let key: String
        let matches: [Match]
    }

    struct RecordTemplate: Encodable {
        let reviewID: String
        let sides: [SideRef]
        let evidenceSHA256: String
        let outcome: String
        let reason: String
        let citedAliasRules: [String]
        let evidenceProvenance: [String]
    }

    struct SideRef: Encodable {
        let gtfsSourceID: String
        let stops: [String]
    }

    struct Candidate: Encodable {
        let index: Int
        let sides: [Side]
        let reasons: [Reason]
        /// The candidate has no exact Japanese match: a `same` needs a cited
        /// alias rule (one listed in `reasons`) or evidence provenance.
        let sameNeedsCitationOrProvenance: Bool
        let otherCandidates: [[SideRef]]
        let evidenceSHA256: String
        let decided: Bool
        let recordTemplate: RecordTemplate
    }

    struct AssignmentTemplate: Encodable {
        let reviewID: String
        /// A proposal from the held, unassigned StationIDs, in order: adopt it
        /// explicitly by writing the station record. Never applied from here.
        let stationID: String
        let sides: [SideRef]
    }

    struct Input: Encodable {
        let gtfsSourceID: String
        let gtfsArchiveSHA256: String
    }

    let packetVersion: Int
    let notice: String
    let inputs: [Input]
    let aliasRules: [String]
    let evidenceProvenanceVocabulary: [String]
    let candidates: [Candidate]
    let groups: [[SideRef]]?
    let availableStationIDs: [String]?
    let assignmentTemplate: [AssignmentTemplate]?

    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try! encoder.encode(self)
        data.append(0x0A)
        return data
    }
}

enum StationPacketCommand {
    static func run(_ request: StationRunRequest, repositoryRoot root: FileIdentity) async throws(ProvisionalRegistryError) -> (StationPacket, StationPacketSummary) {
        guard request.previous == nil else { throw .arguments }
        let registryPath = try StationCommand.checkedPath(request.registryPath, "registry", root)
        let publication: ManifestPublication
        do {
            let name = (request.outputPath as NSString).lastPathComponent
            guard !name.isEmpty, name != ".", name != "..", !request.outputPath.hasSuffix("/") else { throw IntakeError.outputNameInvalid }
            let requested = (request.outputPath as NSString).deletingLastPathComponent
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
        let registryData = try ProvisionalRegistryCommand.readFile(registryPath, "registry", root)
        let registry: MappingRegistry
        do { registry = try MappingRegistry.decoded(from: registryData) } catch { throw .registryFile }
        let loaded = try await StationCommand.load(request.sides, crossRecords: request.crossRecordsPath, registry: registry, root, previous: false)
        let packet = make(loaded)
        do { try publication.publish(packet.encoded()) } catch { throw .output(error) }
        let formation = loaded.formation
        let summary = StationPacketSummary(
            candidates: formation.report.candidates.count,
            reviewed: formation.report.candidates.count - formation.unreviewed.count,
            unreviewed: formation.unreviewed.count,
            groups: formation.unreviewed.isEmpty ? formation.groups.count : nil
        )
        return (packet, summary)
    }

    static func make(_ loaded: StationCommand.Loaded) -> StationPacket {
        let formation = loaded.formation
        func ref(_ side: CrossOperatorSide) -> StationPacket.SideRef {
            .init(gtfsSourceID: side.sourceID, stops: side.members.map(\.providerKey.text))
        }
        let undecided = Set(formation.unreviewed.map(\.evidenceSHA256))
        let candidates = formation.report.candidates.enumerated().map { index, candidate -> StationPacket.Candidate in
            let sides = candidate.sides.map { side in
                StationPacket.Side(
                    gtfsSourceID: side.side.sourceID, stops: side.side.members.map(\.providerKey.text),
                    members: side.members.map { member in
                        let titles = Dictionary(side.routes.map { ($0.routeID, $0.longName) }, uniquingKeysWith: { a, _ in a })
                        return StationPacket.Member(
                            stopID: member.stopID.text, code: member.base.code?.text,
                            names: member.names.map { .init(language: $0.language.text, value: $0.value.text, field: $0.source.field) },
                            routes: member.base.routes.map { route in
                                .init(routeID: route.routeID.text, longName: (titles[route.routeID] ?? nil)?.text, codeFitsRoute: route.codeFitsRoute,
                                      neighbors: route.neighbors.map(\.text),
                                      positions: member.positions.first { $0.routeID == route.routeID }?.positions ?? [])
                            },
                            latitude: member.latitude, longitude: member.longitude
                        )
                    },
                    lineMembership: side.routes.map { $0.longName?.text ?? $0.routeID.text },
                    multiLineOccurrence: side.routeCount
                )
            }
            let reasons = candidate.reasons.map { reason in
                StationPacket.Reason(key: reason.key.name, matches: reason.matches.map { match in
                    var key: String?
                    if case .alias(let rule) = reason.key { key = rule.comparisonKey(match.first.value).text }
                    return .init(first: match.first.value.text, firstLanguage: match.first.language.text,
                                 second: match.second.value.text, secondLanguage: match.second.language.text, comparisonKey: key)
                })
            }
            return StationPacket.Candidate(
                index: index + 1, sides: sides, reasons: reasons,
                sameNeedsCitationOrProvenance: !candidate.keys.contains(.exactJapanese),
                otherCandidates: candidate.otherCandidates.map { $0.map(ref) },
                evidenceSHA256: candidate.evidenceSHA256,
                decided: !undecided.contains(candidate.evidenceSHA256),
                recordTemplate: .init(
                    reviewID: "", sides: candidate.pair.map(ref), evidenceSHA256: candidate.evidenceSHA256,
                    outcome: "", reason: "", citedAliasRules: [], evidenceProvenance: []
                )
            )
        }
        var groups: [[StationPacket.SideRef]]?
        var available: [String]?
        var template: [StationPacket.AssignmentTemplate]?
        if formation.unreviewed.isEmpty {
            groups = formation.groups.map { $0.sides.map(ref) }
            // Held, active StationIDs that no station reference or assignment uses yet.
            let used = Set(loaded.registry.references.map(\.canonicalID)).union((loaded.records?.stations ?? []).map(\.stationID))
            let free = loaded.registry.entities.filter { $0.id.kind == .station && $0.status == .active && !used.contains($0.id) }.map(\.id.rawValue)
            available = free
            // Compared as the registry run compares them: sorted sides and stops.
            let assignedGroups = Set((loaded.records?.stations ?? []).compactMap { station -> [CrossOperatorSide]? in
                let sides = station.sides.compactMap { try? StationCommand.side($0, loaded.sides) }
                return sides.count == station.sides.count ? sides.sorted(by: CrossOperatorSide.precedes) : nil
            })
            let open = formation.groups.filter { !assignedGroups.contains($0.sides) }
            template = zip(open, free).map { group, id in .init(reviewID: "", stationID: id, sides: group.sides.map(ref)) }
        }
        return StationPacket(
            packetVersion: 1, notice: StationPacket.notice,
            inputs: loaded.sides.map { .init(gtfsSourceID: $0.sourceID, gtfsArchiveSHA256: $0.archiveSHA256) },
            aliasRules: StationAliasRule.allCases.map(\.rawValue),
            evidenceProvenanceVocabulary: CrossOperatorEvidenceItem.allCases.map { "evidence:\($0.rawValue)" } + ["external:<reference>"],
            candidates: candidates, groups: groups, availableStationIDs: available, assignmentTemplate: template
        )
    }
}
