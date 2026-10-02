#if DEBUG
import Foundation

/// Closed declarative wire schemas. Cross-checkpoint/business validation belongs to B/C.
nonisolated enum SyntheticRegistrationSchema {
    typealias V = SyntheticRegistrationValue
    indirect enum Rule {
        case text, token, uuid, digest, bytes, minted, integer, natural, timestamp, bool
        case choice([String]), version([Int]), fields([String: Rule], [String: Rule])
        case list(Rule, Order), tagged(String, [String: Rule])
    }
    enum Order {
        case sequence, text, fields([String]), proof, view, viewClaims, reference, id, originalName
    }
    static let roles = ["interval", "identity", "continuity", "origin", "destination", "classification", "mapping", "movement"]
    static let components = ["sourceRevision", "mappingRevision", "profileRevision", "reviewRevision"]
    static let kinds = ["evidence", "profile", "s9Artifact", "seedRecord"]
    static func object(_ fields: [String: Rule], _ optional: [String: Rule] = [:]) -> Rule { .fields(fields, optional) }
    static func strings(_ rule: Rule = .token) -> Rule { .list(rule, .text) }
    static var view: Rule { object(Dictionary(uniqueKeysWithValues: components.map { ($0, .uuid) })) }
    static var key: Rule { object(["sourceID": .token, "namespace": .choice(["gtfs.trip_id"]), "value": .text]) }
    static var keys: Rule { .list(key, .reference) }
    static var deps: Rule { .list(object(["kind": .choice(kinds), "id": .token, "sha256": .digest]), .fields(["kind", "id"])) }
    static var checkpoint: Rule { object(["lineageID": .token, "schemaVersion": .version([2,3,4]), "revision": .natural, "registrySHA256": .digest, "historySHA256": .digest]) }
    static var approval: Rule {
        object(["reviewID": .token, "author": .text, "reviewer": .text, "role": .choice(["owner"]),
                "approvedAt": .timestamp, "subjectKind": .choice(["profile","baseline","request"]),
                "subjectID": .token, "payloadSHA256": .digest, "approvalReference": .text])
    }
    static var scope: Rule {
        object(["tripID": .text, "profileID": .token, "profileVersion": .token, "sourceID": .token,
                "referenceKeys": keys, "view": view],
               ["occurrence": .uuid, "from": .uuid, "to": .uuid, "lineID": .text])
    }
    static var claim: Rule { object(["runReference": .uuid, "role": .choice(roles), "scope": scope]) }
    static var proof: Rule { object(["runReference": .uuid, "role": .choice(roles), "proofUUID": .uuid, "evidenceID": .token, "scope": scope]) }
    static var viewClaim: Rule {
        object(["component": .choice(components), "revisionUUID": .uuid, "profileID": .token,
                "profileVersion": .token, "inputSHA256s": strings(.digest)])
    }
    static var viewBinding: Rule {
        object(["component": .choice(components), "revisionUUID": .uuid, "evidenceID": .token,
                "profileID": .token, "profileVersion": .token])
    }
    static var evidence: Rule {
        object(["evidenceID": .token, "sha256": .digest, "locator": .text, "role": .token,
                "profileID": .token, "profileVersion": .token, "inputSHA256s": strings(.digest),
                "view": view, "referenceKeys": keys, "tripIDs": strings(.text), "recordIDs": strings(),
                "artifactIDs": strings(), "disposition": .choice(["supports","unresolved","contradicts"]),
                "applicability": .list(claim, .proof), "viewApplicability": .list(viewClaim, .viewClaims)])
    }
    static var profilePayload: Rule {
        object(["profileID": .token, "version": .token, "sourceID": .token, "publisherScope": .text,
                "resourceScope": .text, "feedScope": .text, "namespace": .choice(["gtfs.trip_id"]),
                "applicableInputSHA256s": strings(.digest), "uniquenessEvidenceIDs": strings(),
                "meaningEvidenceIDs": strings(), "continuityEvidenceIDs": strings(), "dependencyDigests": deps])
    }
    static var seedInventory: Rule {
        object(["attachmentRecordIDs": strings(), "statusRecordIDs": strings(), "allocationIDs": strings(),
                "reviewIDs": strings(), "selections": .list(object(["tripID": .text, "artifactID": .token]), .fields(["tripID"]))])
    }
    static var baselinePayload: Rule {
        object(["lineageID": .token, "ownerAuthority": .text, "registryBytes": .bytes, "registrySHA256": .digest,
                "legacyHistoryState": .choice(["none","present"]), "historyComplete": .bool,
                "seedInventory": seedInventory, "dependencyDigests": deps],
               ["legacyHistoryBytes": .bytes, "legacyHistorySHA256": .digest])
    }
    static var registration: Rule {
        object(["recordID": .token, "allocationRequestID": .token, "tripID": .text, "referenceKeys": keys,
                "correspondenceEvidenceIDs": strings()], ["snapshotArtifactID": .token])
    }
    static var attachment: Rule {
        .tagged("mode", [
            "newKey": object(["recordID": .token, "tripID": .text, "key": key, "mode": .choice(["newKey"]), "correspondenceEvidenceIDs": strings()]),
            "returning": object(["recordID": .token, "tripID": .text, "key": key, "mode": .choice(["returning"]), "previousRecordSHA256": .digest, "correspondenceEvidenceIDs": strings()])])
    }
    static var selection: Rule {
        let common: [String: Rule] = ["recordID": .token, "tripID": .text, "mode": .choice(["initialSelection","revision"]), "nextArtifactID": .token, "correspondenceEvidenceIDs": strings()]
        return .tagged("mode", ["initialSelection": object(common), "revision": object(common.merging(["previousArtifactID": .token]) { _, r in r })])
    }
    static var requestPayload: Rule {
        let base: [String: Rule] = ["requestID": .token, "lineageID": .token, "operation": .choice(["convertLegacy","register","attach","reviseSnapshot"]),
                                    "expectedPrevious": checkpoint, "targetRegistryBytes": .bytes,
                                    "profileIDs": strings(), "evidenceIDs": strings(), "s9ArtifactIDs": strings(), "dependencyDigests": deps]
        return .tagged("operation", Dictionary(uniqueKeysWithValues:
            [("convertLegacy", object([:])), ("register", registration), ("attach", attachment), ("reviseSnapshot", selection)].map {
                ($0.0, object(base.merging(["records": .list($0.1, .sequence)]) { _, r in r }))
            }))
    }
    static var payload: Rule {
        let base: [String: Rule] = ["format": .choice(["tsugino.synthetic-trip-payload"]), "schemaVersion": .version([1]),
                                    "subjectKind": .choice(["profile","baseline","request"]), "subjectID": .token]
        return .tagged("subjectKind", Dictionary(uniqueKeysWithValues:
            [("profile", profilePayload), ("baseline", baselinePayload), ("request", requestPayload)].map {
                ($0.0, object(base.merging(["payload": $0.1]) { _, r in r }))
            }))
    }
    // An absent approval is representable uncertainty, never null or an empty invented review.
    static var approved: Rule { object(["payload": payload], ["approval": approval]) }

    static var stationMapping: Rule {
        .tagged("tag", ["resolved": object(["tag": .choice(["resolved"]), "stationID": .text, "membership": strings(.text)], ["evidence": .uuid]),
                        "unavailable": object(["tag": .choice(["unavailable"])]), "impossible": object(["tag": .choice(["impossible"])])])
    }
    static var classification: Rule {
        .tagged("tag", ["passenger": object(["tag": .choice(["passenger"]), "mapping": stationMapping], ["evidence": .uuid]),
                        "passed": object(["tag": .choice(["passed"])], ["evidence": .uuid]), "unknown": object(["tag": .choice(["unknown"])])])
    }
    static var identity: Rule {
        .tagged("tag", ["reviewed": object(["tag": .choice(["reviewed"]), "tripID": .text], ["evidence": .uuid]),
                        "unresolved": object(["tag": .choice(["unresolved"])]), "impossible": object(["tag": .choice(["impossible"])]),
                        "awaitingRegistration": object(["tag": .choice(["awaitingRegistration"])])])
    }
    static var boundary: Rule {
        .tagged("tag", ["reached": object(["tag": .choice(["reached"])], ["evidence": .uuid]),
                        "continued": object(["tag": .choice(["continued"])], ["evidence": .uuid]), "unknownExtent": object(["tag": .choice(["unknownExtent"])])])
    }
    static var lineMapping: Rule {
        .tagged("tag", ["resolved": object(["tag": .choice(["resolved"]), "lineID": .text], ["evidence": .uuid]),
                        "unavailable": object(["tag": .choice(["unavailable"])]), "impossible": object(["tag": .choice(["impossible"])])])
    }
    static var packet: Rule {
        let run = object(["reference": .uuid, "view": view,
                          "positions": .list(object(["reference": .uuid, "classification": classification], ["order": .integer]), .sequence),
                          "first": .uuid, "last": .uuid, "identity": identity, "origin": boundary, "destination": boundary,
                          "movements": .list(object(["from": .uuid, "to": .uuid, "line": lineMapping]), .sequence)],
                         ["intervalEvidence": .uuid, "continuityEvidence": .uuid, "priorArtifactID": .token])
        return object(["schemaVersion": .version([1]), "view": view, "evidenceReferences": strings(.uuid), "runs": .list(run, .sequence)])
    }
    static var artifact: Rule {
        object(["schemaVersion": .version([1]), "artifactID": .token, "packetBytes": .bytes, "packetSHA256": .digest,
                "selectedRunReference": .uuid, "proofBindings": .list(proof, .proof), "viewBindings": .list(viewBinding, .view), "dependencyDigests": deps])
    }
    static var reference: Rule {
        // Legacy fields retained by shape, without admitting a binding or validating conversion.
        let source = object(["inputSHA256": .digest, "field": .token, "providerKey": .text],
                            ["member": object(["name": .token, "sha256": .digest]), "table": .token, "recordIndex": .natural])
        let name = object(["language": .text, "value": .text, "source": source])
        return object(["canonicalID": .minted, "sourceID": .token,
                       "namespace": .choice(ProviderNamespace.allCases.map(\.rawValue) + ["gtfs.trip_id"]), "value": .text,
                       "status": .tagged("state", ["active": object(["state": .choice(["active"])]), "absent": object(["state": .choice(["absent"])]),
                                                    "retired": object(["state": .choice(["retired"]), "review": .token])]),
                       "firstSeenInputSHA256": .digest, "provenance": source, "originalNames": .list(name, .originalName)], ["attachedBy": .token])
    }
    static var registry: Rule {
        let entity = .tagged("state", ["active": object(["id": .minted, "state": .choice(["active"])]),
                                      "retired": object(["id": .minted, "state": .choice(["retired"]), "successors": strings(.minted)])]) as Rule
        return object(["schemaVersion": .version([4]), "revision": .natural, "entities": .list(entity, .fields(["id"])), "references": .list(reference, .reference)])
    }
    static var seed: Rule {
        object(["recordID": .token, "kind": .choice(["attachment","status"]), "stipulated": .choice(["synthetic"]),
                "reference": reference, "authorityID": .token, "dependencyDigests": deps],
               ["predecessorRecordID": .token, "predecessorRecordSHA256": .digest])
    }
    static var retained: Rule { object(["kind": .choice(kinds), "id": .token, "bytes": .bytes]) }
    static var history: Rule {
        let b = object(["previousRegistryBytes": .bytes, "targetRegistryBytes": .bytes, "request": payload,
                        "approvals": .list(approval, .fields(["reviewID"])), "dependencies": .list(retained, .fields(["kind","id"]))],
                       ["previousBoundarySHA256": .digest])
        return object(["format": .choice(["tsugino.synthetic-trip-history"]), "schemaVersion": .version([1]),
                       "lineageID": .token, "baselineSHA256": .digest, "boundaries": .list(b, .sequence)])
    }
    static var envelope: Rule {
        object(["format": .choice(["tsugino.synthetic-trip-registration"]), "schemaVersion": .version([1]), "mode": .choice(["synthetic"]),
                "lineageID": .token, "ownerAuthority": .text, "baseline": approved, "history": history, "request": payload,
                "approvals": .list(approval, .fields(["reviewID"])), "profiles": .list(approved, .id),
                "evidence": .list(evidence, .fields(["evidenceID"])), "s9Artifacts": .list(artifact, .fields(["artifactID"]))])
    }

    static func check(_ format: SyntheticRegistrationFormat, _ value: V) throws -> V {
        let rule: Rule
        switch format {
        case .registry: rule = registry
        case .checkpoint: rule = checkpoint
        case .approval: rule = approval
        case .payload: rule = payload
        case .approved: rule = approved
        case .evidence: rule = evidence
        case .s9Packet: rule = packet
        case .s9Artifact: rule = artifact
        case .seedRecord: rule = seed
        case .history: rule = history
        case .envelope: rule = envelope
        }
        let checked = try apply(rule, value, depth: 0)
        if format == .envelope {
            guard checked["baseline"]?["payload"]?["subjectKind"]?.text == "baseline",
                  checked["request"]?["subjectKind"]?.text == "request",
                  checked["profiles"]!.items.allSatisfy({ $0["payload"]?["subjectKind"]?.text == "profile" }) else { throw SyntheticRegistrationIssue.malformedInput }
        }
        return checked
    }

    static func sortKey(_ v: V, _ order: Order) -> [String] {
        switch order {
        case .sequence: return []
        case .text: return [v.text ?? ""]
        case .fields(let names): return names.map { v[$0]?.text ?? "" }
        case .reference: return ["sourceID","namespace","value"].map { v[$0]?.text ?? "" }
        case .id: return [v["payload"]?["subjectID"]?.text ?? ""]
        case .originalName:
            let source = v["source"]!
            let index: String
            if case .integer(let n) = source["recordIndex"] { index = String(format: "%020lld", Int64(n)) } else { index = "" }
            return [v["language"]!.text!, v["value"]!.text!, source["inputSHA256"]!.text!,
                    source["member"]?["name"]?.text ?? "", source["member"]?["sha256"]?.text ?? "",
                    source["table"]?.text ?? "", index, source["field"]!.text!, source["providerKey"]!.text!]
        case .view: return [String(components.firstIndex(of: v["component"]?.text ?? "") ?? 99)]
        case .viewClaims: return [String(components.firstIndex(of: v["component"]?.text ?? "") ?? 99), canonicalTie(v)]
        case .proof:
            return [v["runReference"]?.text ?? "", String(roles.firstIndex(of: v["role"]?.text ?? "") ?? 99),
                    v["scope"]?["occurrence"]?.text ?? "", v["scope"]?["from"]?.text ?? "", v["scope"]?["to"]?.text ?? "", v["proofUUID"]?.text ?? "", canonicalTie(v)]
        }
    }
    // Equal prescribed prefixes are ordered by all remaining scalar-exact fields.
    // A single evidence record may cover the same role/occurrence in several views.
    private static func canonicalTie(_ value: V) -> String {
        String(decoding: (try? SyntheticTripRegistrationCodec.encoded(value)) ?? Data(), as: UTF8.self)
    }
    static func less(_ a: [String], _ b: [String]) -> Bool {
        for (l,r) in zip(a,b) where !l.utf8.elementsEqual(r.utf8) { return l.utf8.lexicographicallyPrecedes(r.utf8) }
        return a.count < b.count
    }
    static func apply(_ rule: Rule, _ value: V, depth: Int) throws -> V {
        guard depth < 100 else { throw SyntheticRegistrationIssue.malformedInput }
        func bad() throws -> V { throw SyntheticRegistrationIssue.malformedInput }
        switch rule {
        case .fields(let required, let optional):
            guard case .object(let fields) = value else { return try bad() }
            // Version first, even if another field is missing or malformed.
            if let version = required["schemaVersion"] {
                guard let supplied = fields["schemaVersion"] else { return try bad() }
                _ = try apply(version, supplied, depth: depth + 1)
            }
            guard Set(required.keys).isSubset(of: Set(fields.keys)), Set(fields.keys).isSubset(of: Set(required.keys).union(optional.keys)) else { return try bad() }
            var result: [String: V] = [:]
            for k in fields.keys.sorted() { result[k] = try apply(required[k] ?? optional[k]!, fields[k]!, depth: depth + 1) }
            if let role = result["role"]?.text, case .object(let scope) = result["scope"] {
                let extras: Set<String>
                switch role {
                case "classification", "mapping", "origin", "destination": extras = ["occurrence"]
                case "interval", "continuity": extras = ["from", "to"]
                case "movement": extras = ["from", "to", "lineID"]
                default: extras = []
                }
                guard Set(scope.keys).intersection(["occurrence","from","to","lineID"]) == extras else { return try bad() }
            }
            if let records = result["records"]?.items {
                let ids = records.compactMap { $0["recordID"]?.text }
                guard Set(ids).count == ids.count else { return try bad() }
                if result["operation"]?.text == "convertLegacy", !records.isEmpty { return try bad() }
            }
            if let request = result["request"] { guard request["subjectKind"]?.text == "request" else { return try bad() } }
            if result["inputSHA256"] != nil && result["providerKey"] != nil {
                let gtfs = result["member"] != nil && result["table"] != nil && result["recordIndex"] == nil
                let odpt = result["member"] == nil && result["table"] == nil && result["recordIndex"] != nil
                guard gtfs || odpt else { return try bad() }
            }
            return .object(result)
        case .tagged(let field, let variants):
            // Payload wrapper's version has precedence over its discriminant.
            if field == "subjectKind" { _ = try apply(.version([1]), value["schemaVersion"] ?? .bool(false), depth: depth + 1) }
            guard let tag = value[field]?.text, let variant = variants[tag] else { return try bad() }
            return try apply(variant, value, depth: depth + 1)
        case .list(let item, let order):
            guard case .array(let array) = value else { return try bad() }
            let result = try array.map { try apply(item, $0, depth: depth + 1) }
            if case .sequence = order { return .array(result) }
            let sorted = result.sorted { less(sortKey($0,order), sortKey($1,order)) }
            for pair in zip(sorted, sorted.dropFirst()) {
                if !less(sortKey(pair.0,order), sortKey(pair.1,order)) { return try bad() }
            }
            return .array(sorted)
        case .version(let versions):
            guard case .integer(let n) = value else { return try bad() }
            guard versions.contains(n) else { throw SyntheticRegistrationIssue.unsupportedVersion }
        case .integer: guard case .integer = value else { return try bad() }
        case .natural: guard case .integer(let n) = value, n >= 0 else { return try bad() }
        case .bool: guard case .bool = value else { return try bad() }
        default:
            guard let text = value.text else { return try bad() }
            let valid: Bool
            switch rule {
            case .text: valid = !text.allSatisfy(\.isWhitespace)
            case .token: valid = MappingText.isToken(text)
            case .uuid: valid = UUID(uuidString: text)?.uuidString.lowercased() == text
            case .digest: valid = MappingText.isSHA256(text)
            case .minted:
                let bytes = Array(text.utf8)
                valid = bytes.count == 20 && bytes[3] == 95 && ["stn","lin","opr","trp"].contains(String(text.prefix(3))) && bytes.dropFirst(4).allSatisfy(MintedIdentifier.alphabet.contains)
            case .bytes: valid = Data(base64Encoded: text)?.base64EncodedString() == text
            case .timestamp:
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: text) { valid = formatter.string(from: date) == text }
                else { valid = false }
            case .choice(let choices): valid = choices.contains(text)
            default: valid = false
            }
            guard valid else { return try bad() }
        }
        return value
    }
}
#endif
