import Foundation
import Testing
@testable import TSUGINO

/// DEC-068 §D3–D4 reviewed line-binding records, on invented values only:
/// sources are `SYN-…`, routes `syn-route-…`, Railway records
/// `syn:Railway.…`, identifiers repeat one digit, and digests repeat one
/// hexadecimal digit.
struct LineBindingRecordTests {

    private static let archive = String(repeating: "c", count: 64)
    private static let railwayInput = String(repeating: "b", count: 64)
    private static let member = String(repeating: "a", count: 64)
    private static let evidence = String(repeating: "f", count: 64)
    private static let lineQ = MintedIdentifier("lin_0000000000000001")!
    private static let lineR = MintedIdentifier("lin_0000000000000002")!

    private static func route(_ id: String, table: String = "routes", field: String = "route_id") throws -> LineBindingMember {
        try LineBindingMember(sourceID: "SYN-01/synthetic-gtfs", reference: SourceReference(
            inputSHA256: archive, member: .init(name: "routes.txt", sha256: member),
            table: table, recordIndex: nil, field: field, providerKey: ExactValue(id)!
        ))
    }

    private static func railway(_ id: String, index: Int, field: String = "@id") throws -> LineBindingMember {
        try LineBindingMember(sourceID: "SYN-03/synthetic-railway", reference: SourceReference(
            inputSHA256: railwayInput, member: nil, table: nil, recordIndex: index, field: field, providerKey: ExactValue(id)!
        ))
    }

    private static func binding(
        _ reviewID: String = "SYN-REVIEW-L1",
        line: MintedIdentifier = lineQ,
        members: [LineBindingMember]? = nil,
        acceptances: [LineBindingAcceptance] = []
    ) throws -> ReviewedLineBinding {
        try ReviewedLineBinding(
            reviewID: reviewID, lineID: line,
            members: try members ?? [try railway("syn:Railway.Qb", index: 1), try route("syn-route-q"), try railway("syn:Railway.Q", index: 0)],
            evidenceSHA256: evidence, acceptances: acceptances
        )
    }

    @Test func aMemberIsARouteRowOrARailwayRecord() throws {
        #expect(try Self.route("syn-route-q").kind == .staticRoute)
        #expect(try Self.railway("syn:Railway.Q", index: 0).kind == .railwayRecord)
        #expect(throws: LineBindingMember.Invalid.notARouteOrRailwayRecord) { try Self.route("syn-route-q", table: "stops") }
        #expect(throws: LineBindingMember.Invalid.notARouteOrRailwayRecord) { try Self.route("syn-route-q", field: "route_short_name") }
        #expect(throws: LineBindingMember.Invalid.notARouteOrRailwayRecord) { try Self.railway("syn:Railway.Q", index: 0, field: "odpt:lineCode") }
    }

    /// Routes come first, then the Railway records; a branch record is a
    /// member with its own reference, never a second line.
    @Test func membersAreOrderedRoutesFirst() throws {
        let record = try Self.binding()
        #expect(record.staticRoutes.map(\.reference.providerKey.text) == ["syn-route-q"])
        #expect(record.railwayRecords.map(\.reference.recordIndex) == [0, 1])
        #expect(record.lineID.kind == .line)
    }

    /// No accepted rule limits a line to one route (ARCHITECTURE.md §40):
    /// one record may bind several routes to its one `LineID`.
    @Test func aBindingMayHoldSeveralRoutesForOneLineID() throws {
        let record = try Self.binding(members: [try Self.route("syn-route-q2"), try Self.railway("syn:Railway.Q", index: 0), try Self.route("syn-route-q")])
        #expect(record.staticRoutes.map(\.reference.providerKey.text) == ["syn-route-q", "syn-route-q2"])
        #expect(record.members.map(\.reference.providerKey.text) == ["syn-route-q", "syn-route-q2", "syn:Railway.Q"])
        #expect(try ReviewedLineBindingSet([record]).records.map(\.lineID) == [Self.lineQ])
    }

    @Test func aBindingNamesAMemberAndALineID() throws {
        #expect(throws: ReviewedLineBinding.Invalid.noMembers) { try Self.binding(members: []) }
        #expect(throws: ReviewedLineBinding.Invalid.notALineIdentifier) {
            try Self.binding(line: MintedIdentifier("opr_0000000000000001")!)
        }
        #expect(throws: ReviewedLineBinding.Invalid.repeatedMember) {
            try Self.binding(members: [try Self.route("syn-route-q"), try Self.railway("syn:Railway.Q", index: 0), try Self.railway("syn:Railway.Q", index: 0)])
        }
        #expect(throws: ReviewedLineBinding.Invalid.repeatedMember) {
            try Self.binding(members: [try Self.route("syn-route-q"), try Self.route("syn-route-q")])
        }
        #expect(throws: ReviewedLineBinding.Invalid.malformedReviewID) { try Self.binding("SYN REVIEW") }
    }

    @Test func anAcceptanceBelongsToOneRailwayMemberOfItsRecord() throws {
        let branch = try Self.railway("syn:Railway.Qb", index: 1)
        let accepted = try LineBindingAcceptance(member: branch, reason: "Synthetic review", acceptedChecks: [.englishTitle, .japaneseTitle])
        #expect(accepted.acceptedChecks == [.japaneseTitle, .englishTitle])
        #expect(try Self.binding(acceptances: [accepted]).acceptances == [accepted])

        // A route in a binding of several routes may need its own acceptance.
        let routeAcceptance = try LineBindingAcceptance(member: try Self.route("syn-route-q"), reason: "Synthetic review", acceptedChecks: [.color])
        #expect(try Self.binding(acceptances: [routeAcceptance]).acceptances == [routeAcceptance])
        #expect(throws: LineBindingAcceptance.Invalid.malformedReason) {
            try LineBindingAcceptance(member: branch, reason: "  ", acceptedChecks: [.color])
        }
        #expect(throws: LineBindingAcceptance.Invalid.invalidAcceptedChecks) {
            try LineBindingAcceptance(member: branch, reason: "Synthetic review", acceptedChecks: [])
        }
        #expect(throws: LineBindingAcceptance.Invalid.invalidAcceptedChecks) {
            try LineBindingAcceptance(member: branch, reason: "Synthetic review", acceptedChecks: [.color, .color])
        }

        let outsider = try LineBindingAcceptance(member: try Self.railway("syn:Railway.R", index: 2), reason: "Synthetic review", acceptedChecks: [.color])
        #expect(throws: ReviewedLineBinding.Invalid.invalidAcceptance) { try Self.binding(acceptances: [outsider]) }
        #expect(throws: ReviewedLineBinding.Invalid.invalidAcceptance) { try Self.binding(acceptances: [accepted, accepted]) }
    }

    @Test func aProviderRecordIsBoundOnceAndALineInOneRecord() throws {
        let q = try Self.binding()
        let r = try Self.binding("SYN-REVIEW-L2", line: Self.lineR, members: [try Self.route("syn-route-r"), try Self.railway("syn:Railway.R", index: 2)])
        #expect(try ReviewedLineBindingSet([r, q]).records.map(\.reviewID) == ["SYN-REVIEW-L1", "SYN-REVIEW-L2"])

        let rWithBranch = try Self.binding("SYN-REVIEW-L2", line: Self.lineR, members: [try Self.route("syn-route-r"), try Self.railway("syn:Railway.Qb", index: 1)])
        #expect(throws: ReviewedLineBindingSet.Invalid.conflictingBinding) { try ReviewedLineBindingSet([q, rWithBranch]) }
        #expect(throws: ReviewedLineBindingSet.Invalid.duplicateBinding) { try ReviewedLineBindingSet([q, try Self.binding("SYN-REVIEW-L3")]) }
        #expect(throws: ReviewedLineBindingSet.Invalid.repeatedReviewID) {
            try ReviewedLineBindingSet([q, try Self.binding(line: Self.lineR, members: [try Self.route("syn-route-r")])])
        }
        let secondRecordForQ = try Self.binding("SYN-REVIEW-L3", members: [try Self.route("syn-route-q2")])
        #expect(throws: ReviewedLineBindingSet.Invalid.lineInTwoRecords) { try ReviewedLineBindingSet([q, secondRecordForQ]) }
        // A route shared by two multi-route bindings still conflicts.
        let rWithQ = try Self.binding("SYN-REVIEW-L2", line: Self.lineR, members: [try Self.route("syn-route-r"), try Self.route("syn-route-q")])
        #expect(throws: ReviewedLineBindingSet.Invalid.conflictingBinding) { try ReviewedLineBindingSet([q, rWithQ]) }
    }
}
