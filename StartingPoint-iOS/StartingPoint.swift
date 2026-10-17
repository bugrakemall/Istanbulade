import Foundation
import CoreLocation

/// A genuine coordinate, independent of the curated route catalogue.
struct StartingPoint: Hashable {
    enum Source: String, Hashable { case landmark, address, mapPin, device }
    let name: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
    let source: Source
    var curatedName: String? = nil
    var accuracyMeters: Double? = nil

    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
    var isValid: Bool { latitude.isFinite && longitude.isFinite && CLLocationCoordinate2DIsValid(coordinate) }
    var coordinateText: String { String(format: "%.5f, %.5f", latitude, longitude) }

    func isSamePlace(as place: IstanbulPlace) -> Bool {
        guard isValid else { return false }
        return CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude)) < 25
    }

    static func landmark(_ place: IstanbulPlace) -> StartingPoint {
        StartingPoint(name: place.name, subtitle: place.area, latitude: place.latitude,
                      longitude: place.longitude, source: .landmark, curatedName: place.name)
    }
    static let initial = StartingPoint(name: "Galata Tower", subtitle: "Beyoğlu · Galata",
                                       latitude: 41.0256, longitude: 28.9744,
                                       source: .landmark, curatedName: "Galata Tower")
}
