import XCTest
@testable import IstanbulHome

final class PilotRoutingTests: XCTestCase {
    private func network() throws -> PilotNetwork { try PilotNetwork.load() }
    private func destination() throws -> IstanbulPlace {
        try XCTUnwrap(PlaceCatalog.places.first { $0.id == "sultanahmet" })
    }
    private func date(_ hour: Int, _ minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 17, hour: hour, minute: minute))!
    }
    private func start(_ point: GeoPoint) -> StartingPoint {
        StartingPoint(name: "Pinned location", subtitle: "Test fixture", latitude: point.latitude,
                      longitude: point.longitude, source: .mapPin)
    }

    func testNetworkDataAndDirections() throws {
        let net = try network()
        try net.validate()
        XCTAssertEqual(net.lines.count, 2)
        XCTAssertEqual(net.lines.flatMap(\.stops).count, 12)
        let line = try XCTUnwrap(net.lines.first { $0.id == "T1" })
        let south = try XCTUnwrap(PilotPathFinder.ride(line, from: "T1-19093", to: "T1-19098"))
        XCTAssertEqual(south.direction, "Bağcılar")
        XCTAssertEqual(south.stops.map(\.name), ["Karaköy", "Eminönü", "Sirkeci", "Gülhane", "Sultanahmet"])
        let north = try XCTUnwrap(PilotPathFinder.ride(line, from: "T1-19098", to: "T1-19093"))
        XCTAssertEqual(north.direction, "Kabataş")
        XCTAssertEqual(north.stops.map(\.id), Array(south.stops.map(\.id).reversed()))
        XCTAssertNil(PilotPathFinder.ride(line, from: "T1-19098", to: "T1-19098"))
    }

    func testConservativeWindowUsesIstanbulTime() throws {
        let line = try XCTUnwrap(try network().lines.first)
        let zone = TimeZone(identifier: "Europe/Istanbul")!
        XCTAssertFalse(line.permitsEarliestBoarding(date(5, 59), timeZone: zone))
        XCTAssertTrue(line.permitsEarliestBoarding(date(6), timeZone: zone))
        XCTAssertTrue(line.permitsEarliestBoarding(date(23, 29), timeZone: zone))
        XCTAssertFalse(line.permitsEarliestBoarding(date(23, 30), timeZone: zone))
        XCTAssertFalse(line.permitsEarliestBoarding(date(0), timeZone: zone))
    }

    @MainActor func testDifferentCoordinatesChangeBoardingStop() async throws {
        let net = try network(), target = try destination()
        let kara = try XCTUnwrap(net.lines.first?.stops.first { $0.name == "Karaköy" })
        let top = try XCTUnwrap(net.lines.first?.stops.first { $0.name == "Tophane" })
        for station in [kara, top] {
            let plan = try await PilotRoutePlanner(network: net, walking: FixtureWalking())
                .plan(start: start(station.coordinate), destination: target, departure: date(12), walkingLimit: 1200)
            let transit = try XCTUnwrap(plan.options.first { !$0.rides.isEmpty })
            XCTAssertEqual(transit.rides.first?.board.id, station.id)
            XCTAssertEqual(transit.legs.first?.coordinates.first, station.coordinate)
        }
    }

    @MainActor func testExplicitKabatasTransferIsIncluded() async throws {
        let net = try network()
        let taksim = try XCTUnwrap(net.lines.first { $0.id == "F1" }?.stops.first { $0.name == "Taksim" })
        let plan = try await PilotRoutePlanner(network: net, walking: FixtureWalking())
            .plan(start: start(taksim.coordinate), destination: destination(), departure: date(12), walkingLimit: 1200)
        let transfer = try XCTUnwrap(plan.options.first { $0.rides.map(\.line.id) == ["F1", "T1"] })
        XCTAssertEqual(transfer.rides[0].alight.id, "F1-18954")
        XCTAssertEqual(transfer.rides[1].board.id, "T1-19069")
        XCTAssertEqual(transfer.legs.filter(\.isWalking).count, 3)
    }

    @MainActor func testNoStraightLineFallbackWhenWalkingFails() async throws {
        let provider = FixtureWalking(); provider.fail = true
        do {
            _ = try await PilotRoutePlanner(network: network(), walking: provider)
                .plan(start: .initial, destination: destination(), departure: date(12), walkingLimit: 1200)
            XCTFail("A failed walking service must not create a fake route")
        } catch is PilotRoutingError { XCTAssertGreaterThan(provider.calls, 0) }
    }

    @MainActor func testActualPedestrianDistanceMustMeetLimit() async throws {
        let provider = FixtureWalking(); provider.fixedDistance = 5000
        do {
            _ = try await PilotRoutePlanner(network: network(), walking: provider)
                .plan(start: .initial, destination: destination(), departure: date(12), walkingLimit: 600)
            XCTFail("Geodesic proximity must not override actual walking distance")
        } catch is PilotRoutingError { }
    }

    @MainActor func testOutsidePilotRejectedBeforeNetworkCall() async throws {
        let provider = FixtureWalking()
        do {
            _ = try await PilotRoutePlanner(network: network(), walking: provider)
                .plan(start: start(GeoPoint(latitude: 52.23, longitude: 21.01)), destination: destination(),
                      departure: date(12), walkingLimit: 1200)
            XCTFail("Outside coverage")
        } catch PilotRoutingError.outsidePilot { XCTAssertEqual(provider.calls, 0) }
    }

    @MainActor func testClosedWindowDoesNotReturnTransit() async throws {
        let provider = FixtureWalking()
        do {
            _ = try await PilotRoutePlanner(network: network(), walking: provider)
                .plan(start: .initial, destination: destination(), departure: date(3), walkingLimit: 600)
            XCTFail("Night transit should be excluded")
        } catch is PilotRoutingError { XCTAssertGreaterThan(provider.calls, 0) }
    }

    @MainActor func testLongAccessWalkCanMissServiceEnvelope() async throws {
        let provider = FixtureWalking(); provider.fixedSeconds = 2400
        do {
            _ = try await PilotRoutePlanner(network: network(), walking: provider)
                .plan(start: .initial, destination: destination(), departure: date(23, 20), walkingLimit: 600)
            XCTFail("Boarding must be checked after the access walk")
        } catch is PilotRoutingError { }
    }
}

/// Synthetic paths for unit tests ONLY. Production always uses AppleWalkingDirections.
@MainActor private final class FixtureWalking: PilotWalkingProviding {
    var fail = false
    var fixedDistance: Double?
    var fixedSeconds: Double?
    var calls = 0
    func route(from: GeoPoint, to: GeoPoint) async throws -> WalkingPath {
        calls += 1
        if fail { throw PilotRoutingError.noOptions("Fixture walking failure") }
        let distance = fixedDistance ?? from.distance(to: to) * 1.1
        return WalkingPath(distanceMeters: distance, expectedSeconds: fixedSeconds ?? distance / 1.2,
                           coordinates: [from, to], instructions: ["Fixture instruction"])
    }
    func cancel() { }
}
