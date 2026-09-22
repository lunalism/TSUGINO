// One canonical line and the span of a Trip's traversal it applies to
// (DEC-060 C, ARCHITECTURE.md §5.3).
//
// The name is deliberately not "leg": a `JourneyLeg` is a passenger-facing
// portion of a planned journey that may involve a transfer, whereas a segment
// is a structural property of one continuous train run. A line boundary
// between two segments is never a transfer (DEC-009, Rule 16).
//
// A segment carries no operator, brand, direction, distance, duration, or
// provider identifier, and it imports nothing.

/// A closed span of a `Trip`'s traversal that runs on one canonical line.
///
/// `startIndex` and `endIndex` are positions in `Trip.stopSequence`, and the
/// span is **closed**: both endpoints are stops of this segment, which is what
/// lets consecutive segments meet at a single shared boundary station
/// (DEC-060 C).
///
/// Only the rules that need nothing but this value are enforced here — the
/// indices are non-negative and ordered, so every segment spans at least one
/// movement. Whether `endIndex` is in range for a particular traversal, and
/// whether segments join, cover, and alternate lines correctly, can only be
/// judged against the whole `Trip` and is enforced there.
///
/// Equality and hashing are complete-value; the segment has no identifier.
nonisolated struct TripLineSegment: Hashable, Codable, Sendable {
    let lineID: LineID
    let startIndex: Int
    let endIndex: Int

    /// Fails unless `0 <= startIndex < endIndex`. Never traps: the raw
    /// integers are compared directly, so an arbitrary decoded value — however
    /// large, small, or reversed — is rejected before anything indexes a
    /// collection or forms a range.
    init?(lineID: LineID, startIndex: Int, endIndex: Int) {
        guard startIndex >= 0, startIndex < endIndex else { return nil }

        self.lineID = lineID
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

extension TripLineSegment {
    private enum CodingKeys: String, CodingKey {
        case lineID, startIndex, endIndex
    }

    /// Decodes with exactly the same validity rule as direct construction, so
    /// a decoded segment can never be one `init` would have rejected. A
    /// missing key or a wrong type keeps its normal keyed-container error; a
    /// blank `lineID` fails through `LineID` itself (DEC-051).
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let segment = Self(
            lineID: try container.decode(LineID.self, forKey: .lineID),
            startIndex: try container.decode(Int.self, forKey: .startIndex),
            endIndex: try container.decode(Int.self, forKey: .endIndex)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A trip line segment must satisfy 0 <= startIndex < endIndex."
                )
            )
        }

        self = segment
    }
}
