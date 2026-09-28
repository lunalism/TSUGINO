import Foundation

// The static-data-intake test runner (DEC-066 §H). Each case gets a fresh
// workspace under one temporary root, which is removed when the run ends,
// whether it passes or fails. Exits non-zero on any failure.

let temporaryRoot = FileManager.default.temporaryDirectory
    .appendingPathComponent("static-data-intake-tests-\(UUID().uuidString)")
try FileManager.default.createDirectory(at: temporaryRoot, withIntermediateDirectories: true)

var passed = 0
var failed: [String] = []
for (index, test) in (unitTests + integrationTests + railwayTests + mintingTests + groupingTests + lineBindingTests + revisionTests).enumerated() {
    do {
        let workspace = try Workspace(root: temporaryRoot.appendingPathComponent("case-\(index)"))
        try await test.body(workspace)
        passed += 1
        print("PASS  \(test.name)")
    } catch let failure as TestFailure {
        failed.append(test.name)
        print("FAIL  \(test.name): \(failure.message)")
    } catch {
        failed.append(test.name)
        print("FAIL  \(test.name): \(error)")
    }
}

try? FileManager.default.removeItem(at: temporaryRoot)
let leftover = FileManager.default.fileExists(atPath: temporaryRoot.path)
print("\n\(passed) passed, \(failed.count) failed (\(unitTests.count) unit, \(integrationTests.count) intake integration, \(railwayTests.count) DS-03 and validate-railway, \(mintingTests.count) minting, \(groupingTests.count) grouping, \(lineBindingTests.count) line binding, \(revisionTests.count) revision); temporary root removed: \(!leftover)")
exit(failed.isEmpty && !leftover ? 0 : 1)
