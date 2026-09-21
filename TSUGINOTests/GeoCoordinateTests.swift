import Foundation
import Testing
@testable import TSUGINO

/// Contract tests for the validated geographic coordinate value (DEC-056,
/// ARCHITECTURE.md §5.1.1).
///
/// Every coordinate here is synthetic. Nothing asserts a regional bounding
/// box, a distance, JSON key order, numeric spelling, or that the sign of
/// zero survives encoding — none of those is a contract.
struct GeoCoordinateTests {

    private static func valid(latitude: Double = 35.5, longitude: Double = 139.5) throws -> GeoCoordinate {
        try #require(GeoCoordinate(latitude: latitude, longitude: longitude))
    }

    // MARK: - Construction and preservation

    @Test(arguments: [
        (35.5, 139.5),
        (-33.25, 151.125),
        (0.0, 0.0),
        (12.345678901234567, -98.765432109876543),
    ])
    func ordinaryValuesArePreservedExactly(sample: (Double, Double)) throws {
        let coordinate = try Self.valid(latitude: sample.0, longitude: sample.1)

        #expect(coordinate.latitude == sample.0)
        #expect(coordinate.longitude == sample.1)
    }

    @Test(arguments: [-90.0, 90.0])
    func latitudeBoundariesAreAccepted(latitude: Double) throws {
        let coordinate = try Self.valid(latitude: latitude, longitude: 0)

        #expect(coordinate.latitude == latitude)
    }

    @Test(arguments: [-180.0, 180.0])
    func longitudeBoundariesAreAccepted(longitude: Double) throws {
        let coordinate = try Self.valid(latitude: 0, longitude: longitude)

        #expect(coordinate.longitude == longitude)
    }

    /// `(0, 0)` is an ordinary valid coordinate; the type has no "absent"
    /// representation, so nothing can mistake it for one.
    @Test func originIsAnOrdinaryValidCoordinate() throws {
        let coordinate = try Self.valid(latitude: 0, longitude: 0)

        #expect(coordinate.latitude == 0)
        #expect(coordinate.longitude == 0)
    }

    @Test func subnormalValuesAreAcceptedAndPreserved() throws {
        let tiny = Double.leastNonzeroMagnitude
        let coordinate = try Self.valid(latitude: tiny, longitude: -tiny)

        #expect(tiny.isSubnormal, "the fixture really is subnormal")
        #expect(coordinate.latitude == tiny)
        #expect(coordinate.longitude == -tiny)
    }

    // MARK: - Rejection (never clamped, never trapped)

    @Test(arguments: [90.000000000001, -90.000000000001, 90.5, -91.0, 180.0, 1e300, -1e300])
    func outOfRangeLatitudeIsRejected(latitude: Double) {
        #expect(GeoCoordinate(latitude: latitude, longitude: 0) == nil)
    }

    @Test(arguments: [180.000000000001, -180.000000000001, 180.5, -181.0, 360.0, 1e300, -1e300])
    func outOfRangeLongitudeIsRejected(longitude: Double) {
        #expect(GeoCoordinate(latitude: 0, longitude: longitude) == nil)
    }

    @Test func nanIsRejectedInEitherField() {
        #expect(GeoCoordinate(latitude: .nan, longitude: 0) == nil)
        #expect(GeoCoordinate(latitude: 0, longitude: .nan) == nil)
        #expect(GeoCoordinate(latitude: .signalingNaN, longitude: 0) == nil)
    }

    @Test func infinityIsRejectedInEitherField() {
        #expect(GeoCoordinate(latitude: .infinity, longitude: 0) == nil)
        #expect(GeoCoordinate(latitude: -.infinity, longitude: 0) == nil)
        #expect(GeoCoordinate(latitude: 0, longitude: .infinity) == nil)
        #expect(GeoCoordinate(latitude: 0, longitude: -.infinity) == nil)
    }

    /// An out-of-range input yields `nil`, not a coordinate pinned to the
    /// nearest boundary.
    @Test func invalidValuesAreNotClamped() {
        #expect(GeoCoordinate(latitude: 95, longitude: 0)?.latitude != 90)
        #expect(GeoCoordinate(latitude: 0, longitude: -200)?.longitude != -180)
        #expect(GeoCoordinate(latitude: 95, longitude: 0) == nil)
    }

    // MARK: - Equality and hashing (complete value)

    @Test func equalityAndHashingUseBothFields() throws {
        let a = try Self.valid()
        let sameAsA = try Self.valid()
        let differentLatitude = try Self.valid(latitude: 35.6)
        let differentLongitude = try Self.valid(longitude: 139.6)

        #expect(a == sameAsA)
        #expect(a != differentLatitude)
        #expect(a != differentLongitude)
        #expect(Set([a, sameAsA, differentLatitude, differentLongitude]).count == 3)
    }

    /// Both zeros are valid and equal under `Double` semantics; nothing here
    /// normalises the sign, and nothing asserts what an encoder does with it.
    @Test func signedZeroIsValidAndComparesEqual() throws {
        let positive = try Self.valid(latitude: 0.0, longitude: 0.0)
        let negative = try Self.valid(latitude: -0.0, longitude: -0.0)

        #expect(negative.latitude.sign == .minus, "the negative fixture really is -0.0")
        #expect(positive == negative)
        #expect(positive.hashValue == negative.hashValue)
        #expect(Set([positive, negative]).count == 1)
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesBothFields() throws {
        let original = try Self.valid(latitude: -89.999999, longitude: 179.999999)
        let decoded = try JSONDecoder().decode(
            GeoCoordinate.self,
            from: try JSONEncoder().encode(original)
        )

        #expect(decoded.latitude == original.latitude)
        #expect(decoded.longitude == original.longitude)
        #expect(decoded == original)
    }

    /// Pins the wire shape a later migration would have to reason about
    /// (ARCHITECTURE.md §41). Keys are compared as a set and values looked
    /// up by key, so nothing about ordering or numeric formatting is asserted.
    @Test func encodedFormUsesExactlyLatitudeAndLongitude() throws {
        let encoded = try JSONEncoder().encode(try Self.valid(latitude: 10, longitude: 20))
        let object = try #require(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )

        #expect(Set(object.keys) == ["latitude", "longitude"])
        #expect(object["latitude"] as? Double == 10)
        #expect(object["longitude"] as? Double == 20)
    }

    @Test(arguments: [
        #"{"longitude":139.5}"#,
        #"{"latitude":35.5}"#,
        "{}",
    ])
    func missingKeysFailAsKeyNotFound(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GeoCoordinate.self, from: Data(payload.utf8))
        }

        guard case .keyNotFound? = error else {
            Issue.record("expected .keyNotFound, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"latitude":"35.5","longitude":139.5}"#,
        #"{"latitude":35.5,"longitude":[139.5]}"#,
        #"{"latitude":true,"longitude":139.5}"#,
    ])
    func wrongTypesFailAsTypeMismatch(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GeoCoordinate.self, from: Data(payload.utf8))
        }

        guard case .typeMismatch? = error else {
            Issue.record("expected .typeMismatch, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        #"{"latitude":90.000001,"longitude":0}"#,
        #"{"latitude":-91,"longitude":0}"#,
        #"{"latitude":0,"longitude":180.000001}"#,
        #"{"latitude":0,"longitude":-181}"#,
        #"{"latitude":1e300,"longitude":0}"#,
    ])
    func outOfRangePayloadsFailAsDataCorrupted(payload: String) {
        let error = #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GeoCoordinate.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    /// Plain JSON cannot spell `NaN` or infinity, so a decoder configured to
    /// convert them from strings is used to prove that decode-side validation
    /// rejects them itself rather than relying on the format to make them
    /// unrepresentable.
    @Test(arguments: [
        #"{"latitude":"nan","longitude":0}"#,
        #"{"latitude":0,"longitude":"nan"}"#,
        #"{"latitude":"inf","longitude":0}"#,
        #"{"latitude":0,"longitude":"-inf"}"#,
    ])
    func nonFinitePayloadsFailAsDataCorrupted(payload: String) {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )

        let error = #expect(throws: DecodingError.self) {
            try decoder.decode(GeoCoordinate.self, from: Data(payload.utf8))
        }

        guard case .dataCorrupted? = error else {
            Issue.record("expected .dataCorrupted, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [#""35.5,139.5""#, "[35.5, 139.5]", "null", "42"])
    func nonObjectPayloadsFailToDecode(payload: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GeoCoordinate.self, from: Data(payload.utf8))
        }
    }

    // MARK: - Concurrency

    @Test func coordinatesCrossActorBoundaries() async throws {
        let coordinate = try Self.valid(latitude: -12.5, longitude: 45.25)
        let received = await Task.detached { coordinate }.value

        #expect(received.latitude == -12.5)
        #expect(received.longitude == 45.25)
    }
}
