import Foundation

// Dedicated invented authority; the ordinary short-locator fixture stays unchanged.
enum LongOccurrenceFixture {
    static func locator(_ index: Int, bytes: Int) -> String {
        let prefix = "INVENTED.occurrence.\(index)."
        return prefix + String(repeating:"x",count:bytes-prefix.utf8.count)
    }
    static func input(_ scenario: ImportS9Fixture.Scenario, bytes: Int) -> Wire {
        let occurrences = scenario.input["occurrences"].list.enumerated().map { n, row in
            row.replacing("locator",.string(locator(n,bytes:bytes)))
        }
        let movements = scenario.input["movements"].list.enumerated().map { n, row in
            row.replacing("from",occurrences[n]["locator"]).replacing("to",occurrences[n+1]["locator"])
        }
        return scenario.input.replacing("occurrences",.array(occurrences)).replacing("movements",.array(movements))
    }
    static func external(_ scenario: ImportS9Fixture.Scenario, bytes: Int) throws -> ImportAuthority.External {
        let bundle = try scenario.changed(input(scenario,bytes:bytes)).bundle()
        return try .init(owner:Fixtures.owner,s9Files:bundle.files,manifestSHA:Codec.hash(bundle.manifest),
                         review:ImportFixtures.review,approval:ImportFixtures.approval())
    }
}

func occurrenceLocatorTests() throws {
    let scenario = try ImportS9Fixture.fixture()
    func success(_ input: Wire, _ external: ImportAuthority.External) throws -> TimetableOccurrenceFacts {
        guard case .success(let facts) = try ImportAuthority.convert(input,external:external).outcome else { throw TestFailure.assertion }
        try expect(facts.visits.count == 14 && ImportAuthority.summary(facts) == "visits=14 exact=28 estimated=0 missing=0")
        return facts
    }
    for length in [64,65,176,255,256] {
        try test("S9 exact occurrence \(length) bytes full production conversion to Domain facts") {
            let external = try LongOccurrenceFixture.external(scenario,bytes:length)
            let input = try ImportFixtures.input(external)
            try expect(input["visits"].list.allSatisfy { $0["occurrence"].text.utf8.count == length })
            let facts = try success(input,external)
            let encoded = try ImportAuthority.facts(facts,input:input)
            let replay = try ImportAuthority.reconstructFacts(encoded,external:external)
            try expect(replay.binding.matches(facts.binding) && replay.visits.count == 14)
        }
    }
    try rejects("unchanged S9 producer rejects 257-byte occurrence locator") {
        _ = try scenario.changed(LongOccurrenceFixture.input(scenario,bytes:257))
    }
    let external = try LongOccurrenceFixture.external(scenario,bytes:176)
    let input = try ImportFixtures.input(external), facts = try success(input,external)
    try test("257-byte normalized occurrence fails closed as resource limit before facts") {
        let changed = row(input,"visits",0,"occurrence",.string(LongOccurrenceFixture.locator(0,bytes:257)))
        do { _ = try ImportAuthority.convert(changed,external:external); throw TestFailure.assertion }
        catch let failure as ConversionFailure { try expect(failure == .resourceLimit) }
    }
    try test("long occurrence one-byte same-length mutation fails exact binding without facts") {
        let original = input["visits"].list[0]["occurrence"].text
        let changed = String(original.dropLast()) + "y"
        try expect(changed.utf8.count == original.utf8.count && zip(changed.utf8,original.utf8).filter { $0 != $1 }.count == 1)
        guard case .invalid(let failure) = try ImportAuthority.convert(row(input,"visits",0,"occurrence",.string(changed)),external:external).outcome else { throw TestFailure.assertion }
        try expect(failure.reason == .occurrenceBinding)
    }
    for field in ["evidence","mappingRevision"] {
        for length in [64,65] {
            try test("generic \(field) token \(length) bytes remains bounded independently") {
                let token = String(repeating:"i",count:length)
                var changed = input
                if field == "evidence" {
                    changed = rows(changed,"evidence") { $0.map { $0["id"].text == "invented.exact" ? $0.replacing("id",.string(token)) : $0 } }
                    changed = rows(changed,"visits") { $0.map { visit in
                        visit.replacing("arrival",visit["arrival"].replacing("evidence",.string(token)))
                            .replacing("departure",visit["departure"].replacing("evidence",.string(token)))
                    } }
                } else {
                    let revisions = changed["revisions"].replacing("mapping",.string(token))
                    changed = changed.replacing("revisions",revisions)
                    changed = rows(changed,"evidence") { $0.map { $0.replacing("revisions",revisions) } }
                    changed = rows(changed,"visits") { $0.map { $0.replacing("mappingRevision",.string(token)) } }
                }
                if length == 64 { _ = try success(changed,external) }
                else {
                    guard case .unsupported(let failure) = try ImportAuthority.convert(changed,external:external).outcome else { throw TestFailure.assertion }
                    try expect(failure.reason == .resourceLimit)
                }
            }
        }
    }
    // Isolate bounded preflight from semantic visit coverage: 256 copied locators fit
    // the count bound. No Domain facts are claimed for this resource-only packet.
    func packet(_ locators: [String]) -> ImportPacket {
        .init(binding:facts.binding,serviceDate:ImportFixtures.date,run:"r",service:"s",
              revision:.init(source:"s",profile:"p",zone:"z",mapping:"m"),manifest:nil,evidence:[],calendar:nil,zone:nil,
              visits:locators.enumerated().map { n, locator in
                  .init(index:Int64(n),occurrence:locator,mappingRevision:"m",expectedOccurrence:nil,
                        arrival:nil,departure:nil,boarding:nil,alighting:nil)
              })
    }
    try test("converter occurrence 257-byte preflight returns typed resource limit") {
        let failure = ImportConverter.preflightFailure(packet([LongOccurrenceFixture.locator(0,bytes:257)]))
        try expect(failure?.kind == .unsupported && failure?.reason == .resourceLimit)
    }
    for bad in ["","INVENTED space","INVENTED\ncontrol","INVENTED\u{7f}","INVENTED.é"] {
        try test("occurrence printable ASCII syntax rejected \(Array(bad.utf8))") {
            let failure = ImportConverter.preflightFailure(packet([bad]))
            try expect(failure?.kind == .invalid && failure?.reason == .tokenSyntax)
            do { _ = try ImportAuthority.convert(row(input,"visits",0,"occurrence",.string(bad)),external:external); throw TestFailure.assertion }
            catch let failure as ConversionFailure { try expect(failure == .malformedInput) }
        }
    }
    // Explicit independent byte accounting for this minimal packet, including IDs,
    // repeated address/date fields, revisions and each visit's mapping token.
    let trip = facts.binding.trip
    let snapshotBytes = trip.id.rawValue.utf8.count + trip.stopSequence.reduce(0) { $0 + $1.rawValue.utf8.count }
        + trip.lineSegments.reduce(0) { $0 + $1.lineID.rawValue.utf8.count }
        + trip.serviceTypeSegments.reduce(0) { $0 + $1.serviceTypeID.rawValue.utf8.count }
    let fixedBytes = snapshotBytes + facts.binding.address.tripID.rawValue.utf8.count
        + facts.binding.address.serviceDate.label.utf8.count + ImportFixtures.date.utf8.count + 2 + 4 + 256
    let locatorBudget = 65_536-fixedBytes
    let width = locatorBudget/256, remainder = locatorBudget%256
    let locators = (0..<256).map { LongOccurrenceFixture.locator($0,bytes:width + ($0 < remainder ? 1 : 0)) }
    try test("multiple long locators counted at exact 64 KiB preflight ceiling") {
        try expect(locators.allSatisfy { $0.utf8.count > 64 && $0.utf8.count <= 256 })
        try expect(fixedBytes + locators.reduce(0) { $0 + $1.utf8.count } == 65_536)
        try expect(ImportConverter.preflightFailure(packet(locators)) == nil)
    }
    try test("multiple valid long locators one byte over 64 KiB reject resource limit") {
        var over = locators; over[255] += "x"
        try expect(over.allSatisfy { $0.utf8.count <= 256 })
        let failure = ImportConverter.preflightFailure(packet(over))
        try expect(failure?.kind == .unsupported && failure?.reason == .resourceLimit)
    }
}
