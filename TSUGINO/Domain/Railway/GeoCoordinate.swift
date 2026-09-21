// Validated geographic coordinate (DEC-056, ARCHITECTURE.md §5.1.1).
//
// A provider-neutral Domain value, not a canonical entity: it has no
// identifier, no provider identity or provenance, and no altitude, accuracy,
// timestamp, or projection. It imports nothing — no CoreLocation, MapKit, or
// provider SDK — and performs no distance, averaging, comparison, or merge
// logic; coordinates corroborate station identity candidates in Phase 2
// mapping and never establish identity in Domain (DEC-048, Rule 53).
//
// Validity and losslessness are separate concerns, as for identifiers and
// names (DEC-051, DEC-053). A value must be finite and within the geographic
// ranges to mean anything, so anything else is rejected. A value that passes
// is stored exactly: no rounding, no precision reduction, no geographic
// normalisation, and no regional bounding box.

/// A WGS 84 latitude and longitude in decimal degrees.
///
/// `latitude` is the north-positive angle from the equator and `longitude` the
/// east-positive angle from the prime meridian — the same concept the GTFS
/// `Latitude` / `Longitude` field types define. Named properties and keyed
/// `Codable` fields remove positional ambiguity; there is no tuple form.
///
/// Equality and hashing are complete-value over both fields. `-0.0` and `0.0`
/// are both valid and compare equal under Swift `Double` semantics; nothing
/// here normalises the sign of zero, and no contract promises that it survives
/// encoding. `(0, 0)` is an ordinary valid coordinate, never a sentinel: this
/// type has no representation for "absent".
nonisolated struct GeoCoordinate: Hashable, Codable, Sendable {
    let latitude: Double
    let longitude: Double

    /// Fails unless both values are finite and within range — latitude in
    /// `-90...90`, longitude in `-180...180`, boundaries inclusive. `NaN` and
    /// the infinities are rejected, and out-of-range values are rejected
    /// rather than clamped. A valid pair is preserved exactly.
    init?(latitude: Double, longitude: Double) {
        guard
            Self.latitudeRange.contains(latitude),
            Self.longitudeRange.contains(longitude)
        else { return nil }

        self.latitude = latitude
        self.longitude = longitude
    }

    // `ClosedRange.contains` is false for `NaN` and for either infinity, so the
    // finiteness rule falls out of the range check without a separate test.
    private static let latitudeRange: ClosedRange<Double> = -90...90
    private static let longitudeRange: ClosedRange<Double> = -180...180
}

extension GeoCoordinate {
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }

    /// Decodes with exactly the same validity rule as direct construction, so
    /// a decoded value can never be one `init` would have rejected. A missing
    /// key or a wrong type keeps its normal keyed-container error; only a
    /// value that decodes as a `Double` and then fails validation is reported
    /// as `dataCorrupted`. The encoder's own refusal of non-finite values is a
    /// backstop, not the rule.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let coordinate = Self(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        ) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "A coordinate must be finite, with latitude in -90...90 and longitude in -180...180."
                )
            )
        }

        self = coordinate
    }
}
