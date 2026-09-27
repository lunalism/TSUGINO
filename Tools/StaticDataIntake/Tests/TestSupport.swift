import Foundation

// Test harness, synthetic feed, and intake helpers for the static-data-intake
// test runner (DEC-066 §H). Every table value is invented: identifiers are
// `syn-…`, names are "Synthetic …", URLs use the reserved `.invalid` domain,
// and dates lie in 2099.

struct TestFailure: Error {
    let message: String
}

func check(_ condition: Bool, _ message: @autoclosure () -> String) throws {
    if !condition { throw TestFailure(message: message()) }
}

/// The synthetic tables of a valid feed, by member name.
enum SyntheticFeed {
    static let tables: [String: String] = [
        "agency.txt": """
            agency_id,agency_name,agency_url,agency_timezone
            syn-agency,Synthetic Transit,https://example.invalid,Asia/Tokyo

            """,
        "stops.txt": """
            stop_id,stop_name,stop_lat,stop_lon
            syn-s1,Synthetic One,35.0,139.0
            syn-s2,Synthetic Two,35.1,139.1

            """,
        "routes.txt": """
            route_id,route_long_name,route_type
            syn-r1,Synthetic Line,1

            """,
        "trips.txt": """
            route_id,service_id,trip_id
            syn-r1,syn-weekday,syn-t1

            """,
        "stop_times.txt": """
            trip_id,arrival_time,departure_time,stop_id,stop_sequence,timepoint
            syn-t1,05:00:00,05:00:00,syn-s1,1,1
            syn-t1,05:10:00,05:10:00,syn-s2,2,1

            """,
        "calendar.txt": """
            service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
            syn-weekday,1,1,1,1,1,0,0,20990101,20991231

            """,
        "feed_info.txt": """
            feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version
            Synthetic Publisher,https://example.invalid,ja,20990101,20991231,syn-1

            """,
    ]

    /// An extra member the intake must record by name only.
    static let extraName = "fare_rules.txt"
    static let extra = "fare_id,route_id\nsyn-fare,syn-r1\n"

    static func entries(replacing replacements: [String: String] = [:], removing: Set<String> = []) -> [ZipEntry] {
        var tables = tables.merging(replacements) { _, new in new }
        tables[extraName] = extra
        return tables.keys.sorted()
            .filter { !removing.contains($0) }
            .map { ZipEntry($0, Data(tables[$0]!.utf8)) }
    }
}

/// A test source: the committed Toei definition's shape with invented values.
let testSource = SourceDefinition(
    sourceID: "TEST/synthetic",
    provider: "Synthetic Provider",
    license: "Synthetic License",
    dataset: "syn-dataset",
    resource: "syn-resource",
    access: .publicURL,
    url: "https://example.invalid/synthetic.zip"
)

/// One test's scratch directories, under the run's temporary root.
struct Workspace {
    let root: URL
    var archives: URL { root.appendingPathComponent("archives") }
    var output: URL { root.appendingPathComponent("out") }

    init(root: URL) throws {
        self.root = root
        try FileManager.default.createDirectory(at: root.appendingPathComponent("archives"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("out"), withIntermediateDirectories: true)
    }

    func write(_ data: Data, named name: String = "feed.zip") throws -> URL {
        let url = archives.appendingPathComponent(name)
        try data.write(to: url)
        return url
    }

    /// Every entry in the output directory, hidden temporary files included.
    func outputEntries() throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: output.path).sorted()
    }
}

/// The repository that contains the test runner.
let testRepositoryRoot: FileIdentity = {
    let executable = resolvedPath(Bundle.main.executablePath!)!
    return try! repositoryRoot(containing: (executable as NSString).deletingLastPathComponent)
}()

let repositoryPath: String = {
    let executable = resolvedPath(Bundle.main.executablePath!)!
    var url = URL(fileURLWithPath: executable).deletingLastPathComponent()
    while FileIdentity(path: url.path) != testRepositoryRoot { url.deleteLastPathComponent() }
    return url.path
}()

func intake(
    archive: URL,
    output: URL,
    source: SourceDefinition = testSource,
    obtainedAt: String = "2099-01-02T03:04:05Z",
    limits: IntakeLimits = .standard,
    hooks: IntakeTestHooks = IntakeTestHooks(),
    repositoryRoot: FileIdentity = testRepositoryRoot
) async -> Result<IntakeResult, IntakeError> {
    let request = IntakeRequest(source: source, archivePath: archive.path, outputPath: output.path, obtainedAt: obtainedAt)
    do {
        return .success(try await StaticDataIntake.run(request, repositoryRoot: repositoryRoot, limits: limits, hooks: hooks))
    } catch {
        return .failure(error)
    }
}

/// Runs an intake that must fail with `expected` and leave the output
/// directory exactly as it was: no manifest and no temporary file.
func expectFailure(
    _ expected: IntakeError,
    in workspace: Workspace,
    archive: URL,
    output: URL? = nil,
    source: SourceDefinition = testSource,
    obtainedAt: String = "2099-01-02T03:04:05Z",
    limits: IntakeLimits = .standard,
    hooks: IntakeTestHooks = IntakeTestHooks()
) async throws {
    let before = try workspace.outputEntries()
    let target = output ?? workspace.output.appendingPathComponent("manifest.json")
    let result = await intake(archive: archive, output: target, source: source, obtainedAt: obtainedAt, limits: limits, hooks: hooks)
    switch result {
    case .success:
        throw TestFailure(message: "expected \(expected), but the intake succeeded")
    case .failure(let error):
        try check(error == expected, "expected \(expected), got \(error)")
    }
    try check(try workspace.outputEntries() == before, "the output directory changed after a failure")
}
