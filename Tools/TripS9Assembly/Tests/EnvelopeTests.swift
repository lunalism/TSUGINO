import Foundation

extension Invented {
    // Valid retained opaque authority catalogs, not whitespace/unknown fields added to
    // identity JSON. Each observation has a distinct invented authority ID and ordinal.
    // The unchanged identity verifier validates all exact bytes and dependency pins.
    static func largeBaseline(_ baseline: Wire) throws -> Wire {
        var records = baseline["payload"]["records"].list
        for batch in 0..<4 {
            let observations: [Wire] = (0..<17_000).map { n in
                .object(["authorityRecordID":.string("invented.owner-observation.\(batch).\(n)"),
                         "inputOrdinal":.integer(n),"disposition":.string("retainedInventedEvidence"),
                         "scope":.string("INVENTED historical owner inventory; opaque to identity conversion; no real railway facts.")])
            }
            let bytes = try Codec.encode(.object(["format":.string("invented.owner-observation-catalog"),
                                                  "schemaVersion":.integer(1),"observations":.array(observations)]))
            try expect(bytes.count <= Limits.record)
            records.append(.object(["id":.string("invented.retained-catalog.\(batch)"),"kind":.string("evidence"),
                                   "sha256":.string(Codec.hash(bytes)),"bytes":Codec.blob(bytes),
                                   "heldIdentifiers":.array([]),"allocationIDs":.array([]),
                                   "reviewIDs":.array([]),"dependencyDigests":.array([])]))
        }
        records.sort { $0["id"].text < $1["id"].text }
        let payload = baseline["payload"].replacing("records",.array(records))
            .replacing("dependencyDigests",.array(records.map { .object(["id":$0["id"],"sha256":$0["sha256"]]) }))
        return try Fixtures.resign(payload)
    }
}

func largeEnvelope() throws {
    let s = try Invented.fixture(large:true), input = try S9.encode(s.input,S9Limits.input)
    let identity = s.input["registeredBundle"]
    let identityHistory = identity["historyBytes"].blob
    try test("checkpoint-scale exact invented history exceeds old enclosing limit") {
        try expect(identityHistory.count >= 25_165_726)
        try expect(input.count > 24 * 1024 * 1024 && input.count <= S9Limits.input)
        // Full unchanged registration verification; no digest-only or skipped authority.
        _ = try Registration.verify(identity["registryBytes"].blob,identityHistory,identity["manifestBytes"].blob,owner:Invented.owner)
        let h = try S9.read(identityHistory,Limits.history)
        let predecessor = try S9.read(h["predecessorHistoryBytes"].blob,Limits.history)
        let catalogs = predecessor["baseline"]["payload"]["records"].list.filter { $0["id"].text.hasPrefix("invented.retained-catalog.") }
        try expect(catalogs.count == 4)
        for c in catalogs {
            try expect(Codec.hash(c["bytes"].blob) == c["sha256"].text)
            let catalog = try S9.read(c["bytes"].blob,Limits.record)
            try expect(catalog["observations"].list.count == 17_000)
        }
    }
    try rejects("old 24 MiB gate rejects valid large assembly input",status:"resourceLimit") {
        _ = try S9.read(input,24 * 1024 * 1024)
    }
    let q = try s.request(), request = try S9.encode(q,S9Limits.request)
    let p = try S9.request(q,owner:Invented.owner)
    try test("large production-path prepare and inspect retain exact input and reconstruct targets") {
        try expect(q["inputBytes"].blob == input && request.count <= S9Limits.request)
        try expect(p.trip == q["tripBytes"].blob && p.crosswalk == q["crosswalkBytes"].blob)
    }
    let a = try s.approved(q), b = try S9.apply(q,approval:a,currentState:s.state,owner:Invented.owner)
    let history = b.files["history.json"]!, bundleSize = b.files.values.reduce(0) { $0 + $1.count }
    try test("large history and four-file bundle retain exact request approval and verify") {
        let h = try S9.read(history,S9Limits.history)
        try expect(history.count <= S9Limits.history && bundleSize <= S9Limits.bundle && b.files.count == 4)
        try expect(try Codec.encode(h["request"]) == request && Codec.equal(h["approval"],a))
        try expect(try S9.verify(b.files,owner:Invented.owner,manifestSHA:Codec.hash(b.manifest)).files == b.files)
    }
    let selected = try S9.selectedState(s.state,bundle:b), state = try S9.encode(selected,S9Limits.state)
    try test("large selected-state retains history manifest and exact unchanged replay") {
        let row = selected["selections"].list[0]
        try expect(state.count <= S9Limits.state && row["historyBytes"].blob == history && row["manifestBytes"].blob == b.manifest)
        let replay = try S9.apply(q,approval:a,currentState:selected,owner:Invented.owner)
        try expect(replay.replay && replay.files == b.files)
    }
    try rejects("large second initial selection still rejects",status:"selectionConflict") {
        let c = s.context.replacing("selectionStateSHA256",.string(try Codec.digest(selected)))
        _ = try S9.prepare(s.input,context:c,state:selected)
    }
    for key in ["inputBytes","registeredCheckpoint","requestID"] {
        try rejects("large changed request evidence checkpoint rejects " + key) {
            let value: Wire = key == "registeredCheckpoint" ? q[key].replacing("revision",.integer(9)) :
                key == "inputBytes" ? Codec.blob(Data("INVENTED CHANGED EVIDENCE".utf8)) : .string("invented.changed.request")
            _ = try S9.apply(q.replacing(key,value),approval:a,currentState:selected,owner:Invented.owner)
        }
    }
    print("PASS invented envelope sizes identityHistory=\(identityHistory.count) input=\(input.count) request=\(request.count) history=\(history.count) bundle=\(bundleSize) selectedState=\(state.count)")
}
