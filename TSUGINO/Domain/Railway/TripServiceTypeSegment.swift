// One service type and the span of a Trip's traversal it applies to
// (DEC-061 D, ARCHITECTURE.md §5.3).
//
// It follows the `TripLineSegment` index conventions (DEC-060 C): a closed
// range of passenger-stop indices, so a stop where the type changes belongs to
// both neighbouring segments — the train arrives under one type and departs
// under the next. Unlike line segments, service-type segments need not cover
// the traversal: an uncovered movement has no stated type (DEC-061 E).
//
// A segment carries no brand, fare, seating, operator, or provider code, and
// it imports nothing.

/// A closed span of a `Trip`'s traversal that runs under one service type.
///
/// `startIndex` and `endIndex` are positions in `Trip.stopSequence`, and the
/// span is **closed**: both endpoints are stops of this segment (DEC-061 D).
///
/// Only the rules that need nothing but this value are enforced here — the
/// indices are non-negative and ordered, so every segment spans at least one
/// movement. Whether `endIndex` is in range for a particular traversal, and
/// whether segments are ordered, joined, or gapped correctly, can only be
/// judged against the whole `Trip` and is enforced there.
///
/// Equality and hashing are complete-value; the segment has no identifier.
nonisolated struct TripServiceTypeSegment: Hashable, Codable, Sendable {
    let serviceTypeID: ServiceTypeID
    let startIndex: Int
    let endIndex: Int

    /// Fails unless `0 <= startIndex < endIndex`. Never traps: the raw
    /// integers are compared directly, so an arbitrary decoded value — however
    /// large, small, or reversed — is rejected before anything indexes a
    /// collection or forms a range.
    init?(serviceTypeID: ServiceTypeID, startIndex: Int, endIndex: Int) {
        guard startIndex >= 0, startIndex < endIndex else { return nil }

        self.serviceTypeID = serviceTypeID
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

extension TripServiceTypeSegment {
    private enum CodingKeys: String, CodingKey {
        case serviceTypeID, startIndex, endIndex
    }

    /// Decodes with exactly the same validity rule as direct construction, so
    /// a decoded segment can never be one `init` would have rejected. A
    /// missing key or a wrong type keeps its normal keyed-container error; a
    /// blank `serviceTypeID` fails through `ServiceTypeID` itself (DEC-051).
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let segment = Self(
            serviceTypeID: try container.decode(ServiceTypeID.self, forKey: .serviceTypeID),
            startIndex: try container.decode(Int.self, forKey: .startIndex),
            endIndex: try container.decode(Int.self, forKey: .endIndex)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A trip service-type segment must satisfy 0 <= startIndex < endIndex."
                )
            )
        }

        self = segment
    }
}
