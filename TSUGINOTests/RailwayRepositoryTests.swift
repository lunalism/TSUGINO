import Foundation
import SQLite3
import Testing
@testable import TSUGINO

struct RailwayRepositoryTests {
    @Test func missingArtifactDoesNotCreateAFile() async throws {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            _ = try await SQLiteRailwayRepository.open(path)
            Issue.record("Missing input was accepted")
        } catch { #expect(error as? RailwayRepositoryError == .unavailable) }
        #expect(!FileManager.default.fileExists(atPath:path.path))
    }
    @Test func unsupportedSQLiteVersionIsRejectedWithoutMutation() async throws {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at:path) }
        var db: OpaquePointer?
        #expect(sqlite3_open(path.path, &db) == SQLITE_OK)
        #expect(sqlite3_exec(db, "PRAGMA user_version=999", nil, nil, nil) == SQLITE_OK)
        #expect(sqlite3_close(db) == SQLITE_OK)
        let before = try Data(contentsOf:path)
        do {
            _ = try await SQLiteRailwayRepository.open(path)
            Issue.record("Unsupported schema was accepted")
        } catch { #expect(error as? RailwayRepositoryError == .unsupportedSchema) }
        #expect(try Data(contentsOf:path) == before)
        #expect(!FileManager.default.fileExists(atPath:path.path+"-journal"))
    }
    @Test func pureRetirementRequiresExplicitNewRegistrySchema() throws {
        let retired = CanonicalEntity(id: MintedIdentifier("stn_0000000000000009")!, status: .retired(successors: []))
        #expect(throws: MappingRegistryError.invalidSuccessors) { try MappingRegistry(revision: 1, entities: [retired], references: []) }
        let modern = try MappingRegistry(revision: 1, entities: [retired], references: [], formatVersion: 3)
        let bytes = try modern.encoded()
        #expect(throws: (any Error).self) { try MappingRegistry.decoded(from: bytes) }
        #expect(try MappingRegistry.decodedForIdentityTransition(from: bytes) == modern)
        // Merely changing the version tag must not legalize a legacy pure retirement.
        let legacy = Data(String(decoding: bytes, as: UTF8.self).replacingOccurrences(of: "\"schemaVersion\" : 3", with: "\"schemaVersion\" : 2").utf8)
        #expect(throws: (any Error).self) { try MappingRegistry.decodedForIdentityTransition(from: legacy) }
    }

}
