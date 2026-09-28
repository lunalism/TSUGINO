import Foundation

// review-packet — the read-only export a reviewer writes records from.
//
// Grouping records and line bindings name evidence digests that only the
// tool can compute, and a line binding's evidence depends on which
// operators its routes and records resolve to. This command reads the same
// identified inputs as provisional-registry, the provisional registry, and a
// records file whose operator records are already written (its groupings and
// line bindings may be empty). It computes:
//   - every grouping proposal and held-back candidate (Step 2), with its
//     evidence digest, findings, and members;
//   - every line proposal and unmatched Railway record (Step 3), with its
//     evidence digest and findings, the operators resolving as they will once
//     the operator records are applied;
//   - the operator keys in the inputs, and the registry's active operator and
//     line identifiers;
//   - optionally, for reviewer-selected member sets — several routes, or
//     routes and records other than a proposal's — the exact evidence and
//     digest a binding of exactly those members needs. It comes from the
//     same Step 3 evidence path `LineBinding.apply` checks, so a digest
//     exported here is accepted unchanged by provisional-registry.
// It writes nothing but one new packet file, outside the repository, never
// replacing a file. The packet holds provider values — identifiers, names,
// codes, and orders — so it stays with the inputs and is never committed.
// Standard output holds only counts and hashes.

struct ReviewPacketRequest {
    let gtfsSourceID: String
    let railwaySourceID: String?
    let inputs: ProvisionalRegistryRequest.Inputs
    let registryPath: String?
    /// Optional member selections (`LineSelectionFile`).
    var selectionPath: String? = nil
    /// A new file.
    let outputPath: String
}

/// Reviewer-selected member sets for line evidence, for one pair of inputs.
struct LineSelectionFile: Decodable {
    static let currentVersion = 1

    struct Selection: Decodable {
        /// Printable ASCII: the reviewer's own name for the selection.
        let label: String
        let routes: [String]
        let railwayRecords: [String]

        private enum CodingKeys: String, CodingKey, CaseIterable { case label, routes, railwayRecords }
        init(from decoder: any Decoder) throws {
            try MappingText.rejectUnknownKeys(decoder, CodingKeys.self)
            let c = try decoder.container(keyedBy: CodingKeys.self)
            label = try c.decode(String.self, forKey: .label)
            routes = try c.decodeIfPresent([String].self, forKey: .routes) ?? []
            railwayRecords = try c.decodeIfPresent([String].self, forKey: .railwayRecords) ?? []
        }
    }

    let gtfsSourceID: String
    let gtfsArchiveSHA256: String
    let railwaySourceID: String?
    let railwayInputSHA256: String?
    let selections: [Selection]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion, gtfsSourceID, gtfsArchiveSHA256, railwaySourceID, railwayInputSHA256, selections
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
        selections = try c.decode([Selection].self, forKey: .selections)
    }

    static func decoded(from data: Data) throws(ProvisionalRegistryError) -> LineSelectionFile {
        guard !RegistryJSON.repeatsKey([UInt8](data)) else { throw .selection(.repeatedKey) }
        do { return try JSONDecoder().decode(LineSelectionFile.self, from: data) } catch { throw .selection(.malformed) }
    }
}

/// The packet. It contains provider values: for the reviewer only.
struct ReviewPacket: Encodable, Equatable {
    static let currentVersion = 1

    struct Name: Encodable, Equatable {
        let language: String?
        let value: String
    }

    struct GroupingMember: Encodable, Equatable {
        let stopID: String
        let code: String?
        let names: [Name]
        let routes: [String]
    }

    struct GroupingFindingEntry: Encodable, Equatable {
        let check: String
        let stops: [String]
        let routes: [String]
    }

    struct GroupingCandidateEntry: Encodable, Equatable {
        let stops: [GroupingMember]
        let findings: [GroupingFindingEntry]
        let evidenceSHA256: String
    }

    struct Agency: Encodable, Equatable {
        let agencyID: String?
        let name: String
        let registryOperatorID: String?
    }

    struct OdptOperator: Encodable, Equatable {
        let value: String
        let registryOperatorID: String?
    }

    struct Route: Encodable, Equatable {
        let routeID: String
        let operatorID: String?
        let japaneseTitles: [String]
        let englishTitles: [String]
        let color: String?
        let codePrefixes: [String]
    }

    struct RailwayRecord: Encodable, Equatable {
        let index: Int
        let id: String
        let sameAs: String
        let lineCode: String?
        let operatorID: String?
        let japaneseTitles: [String]
        let englishTitles: [String]
        let color: String?
        let stationOrder: [String]
    }

    struct LineFinding: Encodable, Equatable {
        let check: String
        /// A route identifier or a Railway `@id`.
        let member: String
        let kind: String
        let routes: [String]
    }

    struct LineProposal: Encodable, Equatable {
        let routes: [String]
        let railwayRecords: [String]
        let findings: [LineFinding]
        let evidenceSHA256: String
    }

    struct SelectedLineEvidence: Encodable, Equatable {
        let label: String
        let routes: [String]
        let railwayRecords: [String]
        let findings: [LineFinding]
        let evidenceSHA256: String
    }

    let packetVersion: Int
    let notice: String
    let gtfsSourceID: String
    let gtfsArchiveSHA256: String
    let railwaySourceID: String?
    let railwayInputSHA256: String?
    let registryRevision: Int
    let activeOperatorIDs: [String]
    let activeLineIDs: [String]
    let groupingProposals: [GroupingCandidateEntry]
    let groupingHeldBack: [GroupingCandidateEntry]
    let agencies: [Agency]
    let odptOperators: [OdptOperator]
    let routes: [Route]
    let railwayRecords: [RailwayRecord]
    let lineProposals: [LineProposal]
    let unmatchedRailwayRecords: [String]
    /// In the selection file's order.
    let selectedLineEvidence: [SelectedLineEvidence]

    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try! encoder.encode(self)
        data.append(0x0A)
        return data
    }
}

/// What the command prints: counts and hashes only.
struct ReviewPacketSummary: Equatable {
    let gtfsArchiveSHA256: String
    let railwayInputSHA256: String?
    let groupingProposals: Int
    let groupingHeldBack: Int
    let lineProposals: Int
    let unmatchedRailwayRecords: Int
    let selections: Int

    func report() -> String {
        """
        GTFS archive SHA-256: \(gtfsArchiveSHA256)
        Railway input SHA-256: \(railwayInputSHA256 ?? "-")
        grouping: \(groupingProposals) proposals, \(groupingHeldBack) held back
        lines: \(lineProposals) proposals, \(unmatchedRailwayRecords) unmatched Railway records, \(selections) selections

        """
    }
}

enum ReviewPacketCommand {
    static let notice = "Contains provider values. Keep outside the repository with its inputs; never commit or publish."

    static func run(_ request: ReviewPacketRequest, repositoryRoot root: FileIdentity) async throws(ProvisionalRegistryError) -> (ReviewPacket, ReviewPacketSummary) {
        guard MappingText.isToken(request.gtfsSourceID),
              (request.railwaySourceID == nil) == (request.inputs.railwayPath == nil),
              request.railwaySourceID.map(MappingText.isToken) ?? true,
              request.railwaySourceID != request.gtfsSourceID
        else { throw .arguments }

        func checked(_ path: String, _ role: String) throws(ProvisionalRegistryError) -> (resolved: String, identity: FileIdentity) {
            do { return try ArchiveReading.checkedPath(path, role: role, repositoryRoot: root) } catch { throw .input(error) }
        }
        let archive = try checked(request.inputs.archivePath, "archive")
        let records = try checked(request.inputs.recordsPath, "records")
        let selectionPath = try request.selectionPath.map { path throws(ProvisionalRegistryError) in try checked(path, "selection") }
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

        let registry = try request.registryPath.map { path throws(ProvisionalRegistryError) in
            try ProvisionalRegistryCommand.readRegistry(path, repositoryRoot: root)
        } ?? .empty
        let inputs = try await ProvisionalRegistryCommand.readInputs(
            request.inputs, archive, records, request.gtfsSourceID, request.railwaySourceID, root, .standard, previous: false
        )

        // Grouping proposals.
        let groupingInput: GroupingInput
        do {
            groupingInput = try GroupingInput(
                sourceID: request.gtfsSourceID, archiveSHA256: inputs.archive.sha256,
                stopsMemberSHA256: inputs.archive.memberSHA256("stops.txt")!, feed: inputs.archive.feed
            )
        } catch {
            throw .grouping(String(describing: error))
        }
        let grouping = StationGrouping.propose(groupingInput)

        // The registry as it will resolve operators once the operator records
        // apply: a held key must already be the record's identity.
        var references = registry.references
        for entity in try inputs.operatorEntities(registry) {
            for reference in entity.references {
                let sourceID = inputs.sourceID(reference.source)!
                let key = ProviderReferenceKey(sourceID: sourceID, namespace: reference.observed.namespace, value: reference.observed.value)
                if let held = registry.reference(for: key) {
                    guard held.canonicalID == entity.identity else { throw .records(.identityMismatch) }
                    continue
                }
                do {
                    references.append(try ProviderReference(
                        canonicalID: entity.identity, sourceID: sourceID, namespace: key.namespace, value: key.value, status: .active,
                        firstSeenInputSHA256: inputs.sha256(reference.source)!, provenance: reference.observed.provenance, originalNames: []
                    ))
                } catch {
                    throw .records(.invalidRecord)
                }
            }
        }
        let resolving: MappingRegistry
        do {
            resolving = try MappingRegistry(revision: registry.revision, entities: registry.entities, references: references)
        } catch {
            throw .reconciliation("attachToUnknownIdentity")
        }
        let lineInput: LineBindingInput
        do { lineInput = try inputs.lineBindingInput(resolving) } catch { throw .binding(String(describing: error)) }
        let lines = LineBinding.propose(lineInput)

        var selected: [ReviewPacket.SelectedLineEvidence] = []
        if let selectionPath {
            let file = try LineSelectionFile.decoded(from: ProvisionalRegistryCommand.readFile(selectionPath, "selection", root))
            guard file.gtfsSourceID == request.gtfsSourceID, file.gtfsArchiveSHA256 == inputs.archive.sha256,
                  file.railwaySourceID == inputs.railway?.sourceID, file.railwayInputSHA256 == inputs.railway?.sha256
            else { throw .selection(.forOtherInput) }
            selected = try evaluate(file.selections, inputs, lineInput, lines)
        }

        let packet = makePacket(request, inputs, registry, resolving, grouping, lines, selected)
        do { try publication.publish(packet.encoded()) } catch { throw .output(error) }
        return (packet, ReviewPacketSummary(
            gtfsArchiveSHA256: inputs.archive.sha256, railwayInputSHA256: inputs.railway?.sha256,
            groupingProposals: grouping.proposals.count, groupingHeldBack: grouping.heldBack.count,
            lineProposals: lines.proposals.count, unmatchedRailwayRecords: lines.unmatchedRecords.count,
            selections: selected.count
        ))
    }

    /// Each selection's evidence, from the same Step 3 evidence path that
    /// `LineBinding.apply` checks. The operator boundary is checked as apply
    /// checks it, so a selection apply would refuse is refused here.
    private static func evaluate(
        _ selections: [LineSelectionFile.Selection],
        _ inputs: RunInputs,
        _ input: LineBindingInput,
        _ report: LineBindingReport
    ) throws(ProvisionalRegistryError) -> [ReviewPacket.SelectedLineEvidence] {
        var used = Set<LineBindingMember.Identity>()
        var results: [ReviewPacket.SelectedLineEvidence] = []
        for selection in selections {
            guard MappingText.isToken(selection.label), !(selection.routes.isEmpty && selection.railwayRecords.isEmpty) else {
                throw .selection(.invalidSelection)
            }
            var members: [LineBindingMember] = []
            for routeID in selection.routes {
                guard let value = ExactValue(routeID), report.routes.contains(where: { $0.routeID == value }) else {
                    throw .selection(.unknownMember)
                }
                members.append(input.routeMember(value))
            }
            for id in selection.railwayRecords {
                guard let index = inputs.railway?.records.firstIndex(where: { $0.id == id }) else { throw .selection(.unknownMember) }
                members.append(input.railwayMember(index))
            }
            guard Set(members.map(\.identity)).count == members.count else { throw .selection(.repeatedMember) }
            for member in members {
                guard used.insert(member.identity).inserted else { throw .selection(.memberInTwoSelections) }
            }

            let routes = report.routes.filter { route in members.contains(route.member) }
            let records = report.railwayRecords.filter { record in members.contains(record.member) }
            guard routes.allSatisfy({ $0.agency != .unresolved }) else { throw .selection(.agencyUnresolved) }
            let operators = routes.map(\.operatorID) + records.map(\.operatorID)
            guard let first = operators.first ?? nil, operators.allSatisfy({ $0 != nil }) else { throw .selection(.operatorUnbound) }
            guard operators.allSatisfy({ $0 == first }) else { throw .selection(.crossesOperatorBoundary) }

            guard let evidence = LineBinding.evidence(for: members, in: input) else { throw .selection(.unknownMember) }
            results.append(.init(
                label: selection.label,
                routes: evidence.members.filter { $0.kind == .staticRoute }.map(\.reference.providerKey.text),
                railwayRecords: evidence.members.filter { $0.kind == .railwayRecord }.map(\.reference.providerKey.text),
                findings: evidence.findings.map {
                    .init(check: $0.check.rawValue, member: $0.member.reference.providerKey.text, kind: $0.kind.rawValue, routes: $0.routes.map(\.text))
                },
                evidenceSHA256: evidence.evidenceSHA256
            ))
        }
        return results
    }

    private static func makePacket(
        _ request: ReviewPacketRequest, _ inputs: RunInputs, _ registry: MappingRegistry, _ resolving: MappingRegistry,
        _ grouping: GroupingReport, _ lines: LineBindingReport, _ selected: [ReviewPacket.SelectedLineEvidence]
    ) -> ReviewPacket {
        func candidate(_ candidate: GroupingCandidate) -> ReviewPacket.GroupingCandidateEntry {
            .init(
                stops: candidate.members.map { member in
                    .init(stopID: member.stopID.text, code: member.code?.text,
                          names: member.names.map { .init(language: $0.language?.text, value: $0.value.text) },
                          routes: member.routes.map(\.routeID.text))
                },
                findings: candidate.findings.map { .init(check: $0.check.rawValue, stops: $0.stops.map(\.text), routes: $0.routes.map(\.text)) },
                evidenceSHA256: candidate.evidenceSHA256
            )
        }
        let feed = inputs.archive.feed
        let odptValues = Set(inputs.railway?.records.map(\.operatorReference) ?? []).sorted()
        return ReviewPacket(
            packetVersion: ReviewPacket.currentVersion,
            notice: notice,
            gtfsSourceID: request.gtfsSourceID,
            gtfsArchiveSHA256: inputs.archive.sha256,
            railwaySourceID: inputs.railway?.sourceID,
            railwayInputSHA256: inputs.railway?.sha256,
            registryRevision: registry.revision,
            activeOperatorIDs: registry.entities.filter { $0.id.kind == .railwayOperator && $0.status == .active }.map(\.id.rawValue),
            activeLineIDs: registry.entities.filter { $0.id.kind == .line && $0.status == .active }.map(\.id.rawValue),
            groupingProposals: grouping.proposals.map(candidate),
            groupingHeldBack: grouping.heldBack.map(candidate),
            agencies: feed.agencies.map { agency in
                .init(agencyID: agency.agencyID, name: agency.name, registryOperatorID: agency.agencyID.flatMap(ExactValue.init).flatMap {
                    resolving.resolve(ProviderReferenceKey(sourceID: request.gtfsSourceID, namespace: .gtfsAgencyID, value: $0))?.rawValue
                })
            },
            odptOperators: odptValues.map { value in
                .init(value: value, registryOperatorID: ExactValue(value).flatMap { value in
                    inputs.railway.flatMap { resolving.resolve(ProviderReferenceKey(sourceID: $0.sourceID, namespace: .odptOperator, value: value))?.rawValue }
                })
            },
            routes: lines.routes.map { route in
                .init(routeID: route.routeID.text, operatorID: route.operatorID?.rawValue,
                      japaneseTitles: route.japaneseTitles.map(\.text), englishTitles: route.englishTitles.map(\.text),
                      color: route.color?.text, codePrefixes: route.codeGroups.map(\.prefix))
            },
            railwayRecords: lines.railwayRecords.enumerated().map { index, record in
                let dto = inputs.railway!.records[index]
                return .init(index: index, id: dto.id, sameAs: dto.sameAs, lineCode: record.lineCode?.text, operatorID: record.operatorID?.rawValue,
                             japaneseTitles: record.japaneseTitles.map(\.text), englishTitles: record.englishTitles.map(\.text),
                             color: record.color?.text, stationOrder: record.stationOrder.map(\.station.providerKey.text))
            },
            lineProposals: lines.proposals.map { proposal in
                .init(
                    routes: proposal.members.filter { $0.kind == .staticRoute }.map(\.reference.providerKey.text),
                    railwayRecords: proposal.members.filter { $0.kind == .railwayRecord }.map(\.reference.providerKey.text),
                    findings: proposal.findings.map {
                        .init(check: $0.check.rawValue, member: $0.member.reference.providerKey.text, kind: $0.kind.rawValue, routes: $0.routes.map(\.text))
                    },
                    evidenceSHA256: proposal.evidenceSHA256
                )
            },
            unmatchedRailwayRecords: lines.unmatchedRecords.map(\.reference.providerKey.text),
            selectedLineEvidence: selected
        )
    }
}
