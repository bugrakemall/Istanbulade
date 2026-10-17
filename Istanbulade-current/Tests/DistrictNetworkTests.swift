import XCTest
@testable import IstanbulHome

final class DistrictNetworkTests: XCTestCase {
    func testAllSupportedDistrictPairsHaveInternalConnections() throws {
        let network = try DistrictNetwork.load()
        XCTAssertEqual(network.districts.count, 13)
        for from in network.districts {
            for to in network.districts where from.name != to.name {
                let route = try XCTUnwrap(network.route(from: from.name, to: to.name), "\(from.name) → \(to.name)")
                XCTAssertFalse(route.rides.isEmpty)
                XCTAssertTrue(route.rides.allSatisfy { $0.stops.count >= 2 })
                XCTAssertEqual(route.from.name, from.name)
                XCTAssertEqual(route.to.name, to.name)
            }
        }
    }
    func testBeyogluToKadikoyUsesOnlyVerifiedTransfers() throws {
        let network = try DistrictNetwork.load()
        let route = try XCTUnwrap(network.route(from: "Beyoğlu", to: "Kadıköy"))
        XCTAssertEqual(route.rides.map(\.line), ["M2", "B1", "M4"])
        XCTAssertEqual(route.transfers, 2)
        XCTAssertEqual(route.rides[0].stops.first, "Taksim")
        XCTAssertEqual(route.rides[0].stops.last, "Yenikapı")
        XCTAssertEqual(route.rides[1].stops.last, "Ayrılık Çeşmesi")
        XCTAssertEqual(route.rides[2].stops.last, "Kadıköy")
        XCTAssertEqual(route.rides.map(\.direction), ["Yenikapı", "Gebze", "Kadıköy"])
    }
    func testReverseDirectionChangesLineOrderAndHeadsigns() throws {
        let network = try DistrictNetwork.load()
        let route = try XCTUnwrap(network.route(from: "Kadıköy", to: "Beyoğlu"))
        XCTAssertEqual(route.rides.map(\.line), ["M4", "B1", "M2"])
        XCTAssertEqual(route.rides.map(\.direction), ["Sabiha Gökçen Havalimanı", "Halkalı", "Hacıosman"])
    }
    func testDirectRouteDoesNotAddAnInterchange() throws {
        let route = try XCTUnwrap(try DistrictNetwork.load().route(from: "Üsküdar", to: "Pendik"))
        XCTAssertEqual(route.rides.map(\.line), ["B1"])
        XCTAssertEqual(route.transfers, 0)
        XCTAssertEqual(route.rides.first?.stops.first, "Üsküdar")
        XCTAssertEqual(route.rides.first?.stops.last, "Pendik")
    }
    func testUnsupportedAndIdenticalDistrictsReturnNoRoute() throws {
        let network = try DistrictNetwork.load()
        XCTAssertNil(network.route(from: "Beyoğlu", to: "Beyoğlu"))
        XCTAssertNil(network.route(from: "Beyoğlu", to: "Adalar"))
        XCTAssertNil(network.route(from: "Unknown", to: "Fatih"))
    }
}
