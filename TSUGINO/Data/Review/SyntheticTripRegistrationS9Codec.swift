#if DEBUG
import Foundation

/// Lossless input bridge only. Deferred predecessors are IDs, never fabricated candidates.
nonisolated enum SyntheticTripRegistrationS9Codec {
    typealias V = SyntheticRegistrationValue
    struct DeferredPacket: Sendable {
        let packet: SyntheticTripReviewPacket
        let predecessors: [UUID: String]
    }

    static func encode(_ input: SyntheticTripReviewPacket, predecessors: [UUID: String] = [:]) throws -> SyntheticRegistrationDocument {
        guard Set(input.runs.map(\.reference)).count == input.runs.count,
              Set(predecessors.keys).isSubset(of: Set(input.runs.map(\.reference))),
              input.runs.allSatisfy({ $0.prior == nil }) else { throw SyntheticRegistrationIssue.malformedInput }
        return try SyntheticTripRegistrationCodec.make(.s9Packet, .object([
            "schemaVersion": .integer(1), "view": view(input.view),
            "evidenceReferences": .array(input.evidenceReferences.map(uuid)),
            "runs": .array(input.runs.map { run in
                var r: [String: V] = ["reference": uuid(run.reference), "view": view(run.view), "first": uuid(run.first), "last": uuid(run.last),
                                      "identity": identity(run.identity), "origin": boundary(run.origin), "destination": boundary(run.destination),
                                      "positions": .array(run.positions.map { p in
                                          var o: [String: V] = ["reference": uuid(p.reference), "classification": classification(p.classification)]
                                          if let order = p.order { o["order"] = .integer(order) }; return .object(o)
                                      }), "movements": .array(run.movements.map { .object(["from": uuid($0.from), "to": uuid($0.to), "line": line($0.line)]) })]
                if let e = run.intervalEvidence { r["intervalEvidence"] = uuid(e) }
                if let e = run.continuityEvidence { r["continuityEvidence"] = uuid(e) }
                if let p = predecessors[run.reference] { r["priorArtifactID"] = .string(p) }
                return .object(r)
            })]))
    }

    static func decode(_ bytes: Data) throws -> DeferredPacket {
        let root = try SyntheticTripRegistrationCodec.read(.s9Packet, bytes).value
        var predecessors: [UUID: String] = [:]
        var seen = Set<UUID>()
        let runs = try root["runs"]!.items.map { r -> SyntheticTripReviewRun in
            let reference = u(r["reference"]!)
            // A dictionary must not silently drop a second per-run predecessor.
            guard seen.insert(reference).inserted else { throw SyntheticRegistrationIssue.malformedInput }
            if let prior = r["priorArtifactID"]?.text { predecessors[reference] = prior }
            return .init(reference: reference, view: readView(r["view"]!), positions: r["positions"]!.items.map { p in
                var order: Int?
                if case .integer(let n) = p["order"] { order = n }
                return .init(reference: u(p["reference"]!), order: order, classification: readClassification(p["classification"]!))
            }, first: u(r["first"]!), last: u(r["last"]!), intervalEvidence: r["intervalEvidence"].map(u),
                         identity: readIdentity(r["identity"]!), continuityEvidence: r["continuityEvidence"].map(u),
                         origin: readBoundary(r["origin"]!), destination: readBoundary(r["destination"]!),
                         movements: r["movements"]!.items.map { .init(from: u($0["from"]!), to: u($0["to"]!), line: readLine($0["line"]!)) }, prior: nil)
        }
        let packet = SyntheticTripReviewPacket(view: readView(root["view"]!), evidenceReferences: Set(root["evidenceReferences"]!.items.map(u)), runs: runs)
        // Swift Domain String equality may coalesce canonically equivalent membership IDs.
        // Never silently lose a scalar-distinct wire entry when bridging into that Set.
        guard try encode(packet, predecessors: predecessors).bytes == bytes else { throw SyntheticRegistrationIssue.malformedInput }
        return .init(packet: packet, predecessors: predecessors)
    }

    private static func uuid(_ v: UUID) -> V { .string(v.uuidString.lowercased()) }
    private static func u(_ v: V) -> UUID { UUID(uuidString: v.text!)! }
    private static func view(_ v: SyntheticTripReviewView) -> V {
        .object(["sourceRevision": uuid(v.sourceRevision), "mappingRevision": uuid(v.mappingRevision), "profileRevision": uuid(v.profileRevision), "reviewRevision": uuid(v.reviewRevision)])
    }
    private static func readView(_ v: V) -> SyntheticTripReviewView {
        .init(sourceRevision: u(v["sourceRevision"]!), mappingRevision: u(v["mappingRevision"]!), profileRevision: u(v["profileRevision"]!), reviewRevision: u(v["reviewRevision"]!))
    }
    private static func tagged(_ tag: String, _ evidence: UUID? = nil, _ fields: [String: V] = [:]) -> V {
        var v = fields; v["tag"] = .string(tag); if let evidence { v["evidence"] = uuid(evidence) }; return .object(v)
    }
    private static func station(_ m: SyntheticTripStationMapping) -> V {
        switch m {
        case .resolved(let id, let membership, let e): tagged("resolved",e,["stationID": .string(id.rawValue), "membership": .array(membership.map { .string($0.rawValue) })])
        case .unavailable: tagged("unavailable")
        case .impossible: tagged("impossible")
        }
    }
    private static func classification(_ c: SyntheticTripClassification) -> V {
        switch c {
        case .passenger(let mapping, let e): tagged("passenger",e,["mapping": station(mapping)])
        case .passed(let e): tagged("passed",e)
        case .unknown: tagged("unknown")
        }
    }
    private static func identity(_ i: SyntheticTripIdentity) -> V {
        switch i {
        case .reviewed(let id, let e): tagged("reviewed",e,["tripID": .string(id.rawValue)])
        case .unresolved: tagged("unresolved")
        case .impossible: tagged("impossible")
        case .awaitingRegistration: tagged("awaitingRegistration")
        }
    }
    private static func boundary(_ b: SyntheticTripBoundary) -> V {
        switch b {
        case .reached(let e): tagged("reached",e)
        case .continued(let e): tagged("continued",e)
        case .unknownExtent: tagged("unknownExtent")
        }
    }
    private static func line(_ l: SyntheticTripLineMapping) -> V {
        switch l {
        case .resolved(let id, let e): tagged("resolved",e,["lineID": .string(id.rawValue)])
        case .unavailable: tagged("unavailable")
        case .impossible: tagged("impossible")
        }
    }
    private static func readStation(_ v: V) -> SyntheticTripStationMapping {
        switch v["tag"]!.text! {
        case "resolved": .resolved(StationID(v["stationID"]!.text!)!, membership: Set(v["membership"]!.items.map { LineID($0.text!)! }), evidence: v["evidence"].map(u))
        case "unavailable": .unavailable
        default: .impossible
        }
    }
    private static func readClassification(_ v: V) -> SyntheticTripClassification {
        switch v["tag"]!.text! {
        case "passenger": .passenger(readStation(v["mapping"]!), evidence: v["evidence"].map(u))
        case "passed": .passed(evidence: v["evidence"].map(u))
        default: .unknown
        }
    }
    private static func readIdentity(_ v: V) -> SyntheticTripIdentity {
        switch v["tag"]!.text! {
        case "reviewed": .reviewed(TripID(v["tripID"]!.text!)!, evidence: v["evidence"].map(u))
        case "unresolved": .unresolved
        case "impossible": .impossible
        default: .awaitingRegistration
        }
    }
    private static func readBoundary(_ v: V) -> SyntheticTripBoundary {
        switch v["tag"]!.text! {
        case "reached": .reached(evidence: v["evidence"].map(u))
        case "continued": .continued(evidence: v["evidence"].map(u))
        default: .unknownExtent
        }
    }
    private static func readLine(_ v: V) -> SyntheticTripLineMapping {
        switch v["tag"]!.text! {
        case "resolved": .resolved(LineID(v["lineID"]!.text!)!, evidence: v["evidence"].map(u))
        case "unavailable": .unavailable
        default: .impossible
        }
    }
}
#endif
