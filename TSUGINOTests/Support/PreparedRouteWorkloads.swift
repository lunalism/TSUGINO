import Foundation
import Testing
@testable import TSUGINO

/// Consumer §30.4 invented workload matrix. Pure deterministic generators over the
/// existing `SolverFixture` / `PreparedRouteFixture` constructors, plus view-level `Parts`
/// edits where §30.3 requires them. Stipulated invented values only; no production code.
struct PreparedRouteWorkload {
    /// Analytic expected outcome (§30.4 "Expected class per case"), built without search code.
    enum Expectation {
        /// Fixed C: the exact identity list in §24.4 order; empty means scoped `noResults`.
        case success([[String]])
        /// Credit-dependent: {C with these identities, I-solver}; discovery fixes the class.
        case successOrSolverCutoff([[String]])
        /// Fixed I-solver: preparation succeeds, the solver cuts off (`preparedInput` reached).
        case solverCutoff
        /// Fixed I-prep: provisional preparation `resourceLimit`; the last checkpoint reached.
        case preparationCutoff(PreparedRouteSearchStage)
    }

    let id: String
    /// Process group (§30.5 ladders run inside one group process).
    let group: String
    /// Escalation ladder for the family stop rule; nil for fixed cases.
    let ladder: String?
    /// Fixed boundary sizes that always run even after a ladder stop (W1 256/257).
    let alwaysRuns: Bool
    let size: Int
    let seed: UInt64?
    let expectation: Expectation
    /// Structural expectation for W6: required occurrences and targets after projection.
    let projected: (occurrences: Int, targets: Int)?
    let build: (PreparedRouteFixture) throws -> PreparedRouteFixture.Case
}

/// §30.4 W3 randomness only.
struct PRSSplitMix64 {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

enum PreparedRouteWorkloads {
    static let day = "invented-day"
    static let days = [day] + (1...5).map { "invented-day-\($0)" }

    static func pad(_ prefix: String, _ n: Int, _ width: Int) -> String {
        let digits = String(n)
        return prefix + String(repeating: "0", count: max(0, width - digits.count)) + digits
    }
    static func key(_ trip: String, _ day: String = day, _ b: Int = 0, _ a: Int = 1) -> String { "\(trip)/\(day)/\(b)-\(a)" }

    /// §24.4 order over invented keys: one view, so trip bytes, day bytes, b, a; strict prefix first.
    static func ordered(_ identities: [[String]]) -> [[String]] {
        func parts(_ k: String) -> ([UInt8], [UInt8], Int, Int) {
            let s = k.split(separator: "/", omittingEmptySubsequences: false)
            let ba = s[2].split(separator: "-")
            return (Array(s[0].utf8), Array(s[1].utf8), Int(ba[0])!, Int(ba[1])!)
        }
        func less(_ x: [String], _ y: [String]) -> Bool {
            for (l, r) in zip(x, y) where l != r {
                let (lt, ld, lb, la) = parts(l), (rt, rd, rb, ra) = parts(r)
                if lt != rt { return lt.lexicographicallyPrecedes(rt) }
                if ld != rd { return ld.lexicographicallyPrecedes(rd) }
                if lb != rb { return lb < rb }
                return la < ra
            }
            return x.count < y.count
        }
        return identities.sorted(by: less)
    }

    // MARK: Layered builder (W2a, W2b, W3, W4b, W4d, W8)

    enum LinkState { case feasible, infeasible, absent }
    struct Layered {
        var specs: [SolverFixture.Spec] = []
        var links: [SolverFixture.Link] = []
        var layers: [[String]] = []
        var states: [LinkState] = []
        var linkEnds: [(String, String)] = []
    }
    /// Layer j has `width` 2-stop Trips stations[j]→stations[j+1], 1000+20j → 1010+20j.
    /// Links between consecutive layers in generator order (from-major), sameStation.
    /// Specs are stored in reverse name order (§30.4 tie families).
    static func layered(_ f: SolverFixture, prefixes: [String], width: Int, stations: [String],
                        state: (Int) -> LinkState = { _ in .feasible }) -> Layered {
        var out = Layered()
        out.layers = prefixes.map { p in (0..<width).map { pad("\(p)-", $0, 3) } }
        var byName: [String: SolverFixture.Spec] = [:]
        for (j, names) in out.layers.enumerated() {
            for name in names {
                byName[name] = f.ride(name, stations[j], stations[j + 1], arrival: Double(1010 + 20 * j),
                                      departure: Double(1000 + 20 * j))
            }
        }
        let order = byName.keys.sorted().reversed()
        out.specs = order.map { byName[$0]! }
        let index = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        var n = 0
        for j in 0..<(out.layers.count - 1) {
            for from in out.layers[j] {
                for to in out.layers[j + 1] {
                    let s = state(n); n += 1
                    out.states.append(s); out.linkEnds.append((from, to))
                    switch s {
                    case .feasible: out.links.append(f.link(index[from]!, index[to]!))
                    case .infeasible: out.links.append(f.link(index[from]!, index[to]!, allowance: 15))
                    case .absent: out.links.append(f.link(index[from]!, index[to]!, kind: 1))
                    }
                }
            }
        }
        return out
    }
    /// Analytic oracle: every layer-product path whose consecutive links are feasible.
    static func surviving(_ l: Layered) -> [[String]] {
        var feasible = Set<String>()
        for (i, s) in l.states.enumerated() where s == .feasible { feasible.insert(l.linkEnds[i].0 + ">" + l.linkEnds[i].1) }
        var paths: [[String]] = l.layers[0].map { [$0] }
        for layer in l.layers.dropFirst() {
            paths = paths.flatMap { p in layer.compactMap { feasible.contains(p.last! + ">" + $0) ? p + [$0] : nil } }
        }
        return ordered(paths.map { $0.map { key($0) } })
    }

    static func profileNarrowed(_ c: PreparedRouteFixture.Case, stations: [String], trips: [String], f: SolverFixture) throws -> PreparedRouteFixture.Case {
        var c = c
        let base = c.profile
        c.profile = try f.need(InternalSearchProfileDefinition(identity: base.identity,
            stations: Set(try stations.map { try f.need(StationID($0)) }), lines: base.lines,
            trips: Set(try trips.map { try f.need(TripID($0)) }), maximumElapsedDuration: base.maximumElapsedDuration,
            maximumRailRides: base.maximumRailRides, connectionPolicy: base.connectionPolicy,
            serviceDateInterpretation: base.serviceDateInterpretation))
        return c
    }

    // MARK: Families

    static func w1(_ k: Int) -> PreparedRouteWorkload {
        let names = (0..<k).map { pad("d-", $0, 4) }
        return .init(id: pad("W1-", k, 4), group: "W1", ladder: "W1", alwaysRuns: k >= 256, size: k, seed: nil,
            expectation: k <= 256 ? .success(names.map { [key($0)] }) : .solverCutoff, projected: nil,
            build: { p in try p.make(names.reversed().map { p.f.ride($0) }) })
    }

    static func w2a(_ w: Int, maximumWork: Int? = nil) -> PreparedRouteWorkload {
        let expected = ordered((0..<w).flatMap { a in (0..<w).map { b in [key(pad("A-", a, 3)), key(pad("B-", b, 3))] } })
        let id = maximumWork.map { "W8-" + pad("", $0 / 1_000_000, 3) + "M" } ?? pad("W2a-", w, 2)
        return .init(id: id, group: maximumWork == nil ? "W2a" : "W8", ladder: maximumWork == nil ? "W2a" : nil,
            alwaysRuns: false, size: maximumWork ?? w, seed: nil, expectation: .successOrSolverCutoff(expected), projected: nil,
            build: { p in
                let l = layered(p.f, prefixes: ["A", "B"], width: w, stations: ["O", "H", "D"])
                var c = try p.make(l.specs, links: l.links)
                if let maximumWork {
                    let e = c.configuration
                    c.configuration = .init(objective: e.objective, maximumWork: maximumWork, maximumRetainedSlots: e.maximumRetainedSlots,
                        maximumWinners: e.maximumWinners, maximumIdentityKeys: e.maximumIdentityKeys, maximumLogicalBytes: e.maximumLogicalBytes)
                }
                return c
            })
    }

    static func depthStations(_ d: Int, last: String = "D") -> [String] {
        ["O"] + (1..<d).map { pad("H", $0, 2) } + [last]
    }
    static func w2b(_ d: Int) -> PreparedRouteWorkload {
        let prefixes = (0..<d).map { pad("L", $0, 2) }
        var paths: [[String]] = [[]]
        for p in prefixes { paths = paths.flatMap { x in (0..<2).map { x + [key(pad("\(p)-", $0, 3))] } } }
        return .init(id: "W2b-\(d)", group: "W2b", ladder: "W2b", alwaysRuns: false, size: d, seed: nil,
            expectation: .successOrSolverCutoff(ordered(paths)), projected: nil,
            build: { p in
                let l = layered(p.f, prefixes: prefixes, width: 2, stations: depthStations(d))
                return try p.make(l.specs, links: l.links, maximumRides: 8)
            })
    }

    static func w3Mask(percent: Int) -> (seed: UInt64, feasible: Set<Int>) {
        let seed = 0x5453_5547_494E_4F00 + UInt64(percent)
        var rng = PRSSplitMix64(state: seed)
        var indices = Array(0..<72)
        for i in stride(from: indices.count - 1, to: 0, by: -1) {
            indices.swapAt(i, Int(rng.next() % UInt64(i + 1)))
        }
        let count = Int((Double(percent) / 100 * 72).rounded(.toNearestOrAwayFromZero))
        return (seed, Set(indices.prefix(count)))
    }
    static func w3(percent: Int, absent: Bool = false) -> PreparedRouteWorkload {
        let mask = w3Mask(percent: percent)
        let other: LinkState = absent ? .absent : .infeasible
        let shape = layered(SolverFixture(), prefixes: ["A", "B", "C"], width: 6, stations: ["O", "H1", "H2", "D"],
                            state: { mask.feasible.contains($0) ? .feasible : other })
        let expected = surviving(shape)
        let id = absent ? pad("W3a-", percent, 3) : pad("W3-", percent, 3)
        return .init(id: id, group: "W3", ladder: absent ? nil : "W3", alwaysRuns: false, size: percent, seed: mask.seed,
            expectation: expected.isEmpty ? .success([]) : .successOrSolverCutoff(expected), projected: nil,
            build: { p in
                let l = layered(p.f, prefixes: ["A", "B", "C"], width: 6, stations: ["O", "H1", "H2", "D"],
                                state: { mask.feasible.contains($0) ? .feasible : other })
                return try p.make(l.specs, links: l.links)
            })
    }

    static func w4() -> [PreparedRouteWorkload] {
        [
            .init(id: "W4a", group: "W4", ladder: nil, alwaysRuns: false, size: 65, seed: nil, expectation: .success([]), projected: nil,
                  build: { p in try p.make((0..<64).map { p.f.ride(pad("X-", $0, 3), "X", "D") } + [p.f.ride("back", "D", "O")]) }),
            .init(id: "W4b", group: "W4", ladder: nil, alwaysRuns: false, size: 13, seed: nil, expectation: .success([]), projected: nil,
                  build: { p in
                      let l = layered(p.f, prefixes: ["A", "B", "C"], width: 4, stations: ["O", "H1", "H2", "Z"])
                      return try p.make(l.specs + [p.f.ride("Y-000", "D", "Y")], links: l.links)
                  }),
            .init(id: "W4c", group: "W4", ladder: nil, alwaysRuns: false, size: 64, seed: nil, expectation: .success([]), projected: nil,
                  build: { p in try p.make((0..<64).map { p.f.ride(pad("late-", $0, 3), arrival: 3010, departure: 3000) }) }),
            .init(id: "W4d", group: "W4", ladder: nil, alwaysRuns: false, size: 8, seed: nil, expectation: .success([]), projected: nil,
                  build: { p in
                      let l = layered(p.f, prefixes: (0..<4).map { pad("L", $0, 2) }, width: 2, stations: depthStations(4))
                      return try p.make(l.specs, links: l.links, maximumRides: 3)
                  }),
        ]
    }

    static func w5(_ m: Int) -> PreparedRouteWorkload {
        .init(id: "W5-\(m)", group: "W5", ladder: "W5", alwaysRuns: false, size: m, seed: nil,
            expectation: .successOrSolverCutoff([[key("direct")]]), projected: nil,
            build: { p in
                let f = p.f
                var specs: [SolverFixture.Spec] = []
                for i in 0..<m {
                    specs.append(f.ride(pad("out-", i, 2), "O", pad("A", i, 2), arrival: 1000, departure: 1000))
                    specs.append(f.ride(pad("back-", i, 2), pad("A", i, 2), "O", arrival: 1000, departure: 1000))
                }
                specs.append(f.ride("direct", "O", "D", arrival: 1000, departure: 1000))
                let direct = specs.count - 1
                var links: [SolverFixture.Link] = []
                for i in 0..<m {
                    links.append(f.link(2 * i, 2 * i + 1))
                    for j in 0..<m { links.append(f.link(2 * i + 1, 2 * j)) }
                    links.append(f.link(2 * i + 1, direct))
                }
                return try p.make(specs, links: links, maximumRides: 7)
            })
    }
    static func w5t() -> PreparedRouteWorkload {
        .init(id: "W5t", group: "W5", ladder: nil, alwaysRuns: false, size: 4, seed: nil,
            expectation: .success(ordered([[key("a1"), key("a2")], [key("b1"), key("b2")]])), projected: nil,
            build: { p in
                let f = p.f
                let specs = [f.ride("a1", "O", "A", arrival: 1000, departure: 1000), f.ride("a2", "A", "D", arrival: 1000, departure: 1000),
                             f.ride("b1", "O", "B", arrival: 1000, departure: 1000), f.ride("b2", "B", "D", arrival: 1000, departure: 1000)]
                return try p.make(specs, links: [f.link(0, 1), f.link(2, 3)])
            })
    }

    static func w6(_ n: Int, extendedCore: Bool = false) -> PreparedRouteWorkload {
        let core = ordered((0..<3).flatMap { a in (0..<3).map { b in [key(pad("A-", a, 3)), key(pad("B-", b, 3))] } })
        return .init(id: extendedCore ? "W6p-0384" : pad("W6-", n, 4), group: "W6", ladder: extendedCore ? nil : "W6",
            alwaysRuns: false, size: n, seed: nil, expectation: .success(core), projected: (6, 9),
            build: { p in
                let f = p.f
                var specs: [SolverFixture.Spec]
                var links: [SolverFixture.Link] = []
                if extendedCore {
                    func spec(_ name: String, _ stops: [String], _ base: Double) -> SolverFixture.Spec {
                        var s = SolverFixture.Spec(); s.name = name; s.stops = stops; s.base = base; s.step = 10
                        s.required = [.init(boardingIndex: 0, alightingIndex: 1), .init(boardingIndex: 0, alightingIndex: 2),
                                      .init(boardingIndex: 1, alightingIndex: 2)]
                        return s
                    }
                    specs = (0..<3).map { spec(pad("A-", $0, 3), ["O", "H", "Q"], 1000) }
                        + (0..<3).map { spec(pad("B-", $0, 3), ["H", "D", "Y"], 1020) }
                    for a in 0..<3 { for b in 0..<3 { links.append(f.link(a, 3 + b)) } }
                } else {
                    let l = layered(f, prefixes: ["A", "B"], width: 3, stations: ["O", "H", "D"])
                    specs = l.specs; links = l.links
                }
                let coreTrips = specs.map(\.name)
                let first = specs.count
                for i in 0..<n {
                    var s = SolverFixture.Spec()
                    s.name = pad("F-", i / 6, 3); s.day = days[i % 6]; s.stops = ["F-a", "F-b", "F-c"]
                    s.required = [.init(boardingIndex: 0, alightingIndex: 1), .init(boardingIndex: 0, alightingIndex: 2),
                                  .init(boardingIndex: 1, alightingIndex: 2)]
                    specs.append(s)
                }
                for i in 0..<min(max(n - 1, 0), 1_536) {
                    var l = f.link(first + i, first + i + 1, kind: 1); l.alight = 2; l.board = 0
                    links.append(l)
                }
                let c = try p.make(specs, links: links)
                return try profileNarrowed(c, stations: ["O", "H", "D"], trips: coreTrips, f: f)
            })
    }

    static let elevenStops = ["O"] + (1...9).map { pad("S", $0, 2) } + ["D"]
    static let pairs: [TimetableVerifiedRideInterval] = (0..<11).flatMap { b in ((b + 1)..<11).map { a in
        TimetableVerifiedRideInterval(boardingIndex: b, alightingIndex: a) } }
    static func w7r(_ total: Int) -> PreparedRouteWorkload {
        .init(id: "W7r-\(total)", group: "W7", ladder: nil, alwaysRuns: true, size: total, seed: nil,
            expectation: total <= PreparedInputLimits.rides ? .solverCutoff : .preparationCutoff(.assessment), projected: nil,
            build: { p in
                let specs = (0..<86).map { i -> SolverFixture.Spec in
                    var s = SolverFixture.Spec(); s.name = pad("R-", i, 3); s.stops = elevenStops; s.base = 1000; s.step = 10
                    s.required = Array(pairs.prefix(i < 85 ? 48 : total - 85 * 48)); return s
                }
                return try p.make(specs)
            })
    }

    static let longStops = ["O"] + (1...70).map { pad("E", $0, 2) } + ["D"]
    static func longSpec(_ name: String) -> SolverFixture.Spec {
        var s = SolverFixture.Spec(); s.name = name; s.stops = longStops; s.required = []; return s
    }
    static func w7e(_ total: Int) -> PreparedRouteWorkload {
        .init(id: "W7e-\(total)", group: "W7", ladder: nil, alwaysRuns: true, size: total, seed: nil,
            expectation: total <= ConnectionEvidenceLimits.relations ? .success([]) : .preparationCutoff(.closure), projected: nil,
            build: { p in
                let all = (1...71).flatMap { a in (0...70).map { b in (a, b) } }
                let links = all.prefix(min(total, ConnectionEvidenceLimits.relations)).map { a, b -> SolverFixture.Link in
                    var l = p.f.link(0, 1, kind: 1); l.alight = a; l.board = b; return l
                }
                var c = try p.make([longSpec("E-a"), longSpec("E-b")], links: Array(links))
                if total > ConnectionEvidenceLimits.relations {
                    let (from, to) = (c.world.bindings[0].address, c.world.bindings[1].address)
                    let existing = c.parts.connections.entries[c.parts.relations.targets[0]]
                    for (a, b) in all[ConnectionEvidenceLimits.relations..<total] {
                        let k = ConnectionRelationKey(from: from, alightingIndex: a, to: to, boardingIndex: b)
                        c.parts.relations = .init(reference: c.parts.relations.reference, completeness: c.parts.relations.completeness,
                                                  targets: c.parts.relations.targets + [k])
                        c.parts.setEntry(k, existing)
                    }
                }
                return c
            })
    }

    static func w7o(_ total: Int) -> PreparedRouteWorkload {
        let winners = ordered((0..<4).flatMap { t in days.map { [key(pad("o-", t, 3), $0)] } })
        return .init(id: "W7o-\(total)", group: "W7", ladder: nil, alwaysRuns: true, size: total, seed: nil,
            expectation: total <= SearchInputClosureLimits.occurrences ? .successOrSolverCutoff(winners) : .preparationCutoff(.declarations),
            projected: nil,
            build: { p in
                var specs: [SolverFixture.Spec] = []
                for t in 0..<480 {
                    for d in days {
                        specs.append(t < 4 ? p.f.ride(pad("o-", t, 3), "O", "D", day: d) : p.f.ride(pad("x-", t, 3), "X", "Y", day: d))
                    }
                }
                var c = try p.make(specs)
                if total > SearchInputClosureLimits.occurrences {
                    let e = c.parts.occurrences
                    c.parts.occurrences = .init(reference: e.reference, completeness: e.completeness, entries: e.entries + [e.entries[0]])
                }
                return c
            })
    }

    static func w7c(_ total: Int) -> PreparedRouteWorkload {
        .init(id: "W7c-\(total)", group: "W7", ladder: nil, alwaysRuns: true, size: total, seed: nil,
            expectation: .preparationCutoff(total <= SearchInputClosureLimits.connections ? .closure : .declarations), projected: nil,
            build: { p in
                var c = try p.make((0..<10).map { longSpec(pad("c-", $0, 2)) })
                let addresses = c.world.bindings.map(\.address)
                var keys: [ConnectionRelationKey] = []
                keys.reserveCapacity(total)
                outer: for i in 0..<10 { for j in 0..<10 where i != j { for a in 1...71 { for b in 0...70 {
                    if keys.count == total { break outer }
                    keys.append(ConnectionRelationKey(from: addresses[i], alightingIndex: a, to: addresses[j], boardingIndex: b))
                } } } }
                c.parts.relations = .init(reference: c.parts.relations.reference, completeness: c.parts.relations.completeness, targets: keys)
                return c
            })
    }

    // MARK: W7p conditional payload pair (§30.3)

    static let token = String(repeating: "t", count: 160)
    static func payloadSpec(_ i: Int) -> SolverFixture.Spec {
        var s = SolverFixture.Spec()
        s.name = pad("p-", i, 3) + "-" + token + String(repeating: "n", count: 192 - 166)
        s.day = day + "-" + String(repeating: "d", count: 192 - day.count - 1)
        s.stops = ["O"] + (1...70).map { pad("P", $0, 2) + "-" + token + String(repeating: "s", count: 192 - 164) } + ["D"]
        s.required = []
        return s
    }
    static func w7p(_ slots: Int, over: Bool) -> PreparedRouteWorkload {
        .init(id: "W7p-\(slots)", group: "W7", ladder: nil, alwaysRuns: true, size: slots, seed: nil,
            expectation: over ? .preparationCutoff(.assessment) : .successOrSolverCutoff([]), projected: nil,
            build: { p in try p.make((0..<slots).map(payloadSpec)) })
    }

    // MARK: Matrix (§30.4 order: ascending within each ladder)

    static var matrix: [PreparedRouteWorkload] {
        [1, 2, 8, 32, 64, 128, 256, 257].map { w1($0) }
            + [2, 3, 4, 6, 8, 9, 10, 11, 12].map { w2a($0) }
            + (2...8).map { w2b($0) }
            + [0, 10, 25, 50, 100].map { w3(percent: $0) } + [w3(percent: 10, absent: true)]
            + w4()
            + (1...5).map { w5($0) } + [w5t()]
            + [0, 96, 384, 1_536, 2_844].map { w6($0) } + [w6(384, extendedCore: true)]
            + [w7r(4_096), w7r(4_097), w7e(2_048), w7e(2_049), w7o(2_880), w7o(2_881), w7c(23_040), w7c(23_041)]
            + [1_000_000, 4_000_000, 16_000_000, 64_000_000].map { w2a(8, maximumWork: $0) }
    }
}
