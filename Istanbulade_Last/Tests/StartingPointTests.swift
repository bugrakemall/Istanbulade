import XCTest
@testable import IstanbulHome

final class StartingPointTests: XCTestCase {
    func testMapAndGPSPointsNeverPretendToBeCuratedRoutes() {
        let pin = StartingPoint(name: "Galata Tower", subtitle: "Map selection",
                                latitude: 41.0256, longitude: 28.9744, source: .mapPin)
        XCTAssertTrue(pin.isValid)
        XCTAssertNil(pin.curatedName)
        let gps = StartingPoint(name: "My location", subtitle: "Device",
                                latitude: 41.03, longitude: 28.98, source: .device)
        XCTAssertNil(gps.curatedName)
    }

    func testRejectsInvalidCoordinatesButAllowsAnyValidLocation() {
        for latitude in [Double.nan, Double.infinity, 91, -91] {
            XCTAssertFalse(StartingPoint(name: "Pin", subtitle: "", latitude: latitude,
                                         longitude: 29, source: .mapPin).isValid)
        }
        XCTAssertFalse(StartingPoint(name: "Pin", subtitle: "", latitude: 41,
                                     longitude: 181, source: .mapPin).isValid)
        XCTAssertTrue(StartingPoint(name: "Pin", subtitle: "", latitude: 52.23,
                                    longitude: 21.01, source: .mapPin).isValid)
    }

    func testSamePlaceUsesCoordinatesRatherThanDisplayName() throws {
        let galata = try XCTUnwrap(PlaceCatalog.places.first { $0.id == "galata" })
        let sameCoordinate = StartingPoint(name: "Pinned location", subtitle: "",
                                          latitude: galata.latitude, longitude: galata.longitude, source: .mapPin)
        XCTAssertTrue(sameCoordinate.isSamePlace(as: galata))
        let otherCoordinate = StartingPoint(name: "Galata Tower", subtitle: "",
                                           latitude: 41.04, longitude: 29.00, source: .address)
        XCTAssertFalse(otherCoordinate.isSamePlace(as: galata))
    }
}
