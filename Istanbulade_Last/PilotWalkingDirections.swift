import Foundation
import MapKit

struct WalkingPath {
    let distanceMeters: Double
    let expectedSeconds: Double
    let coordinates: [GeoPoint]
    let instructions: [String]
}

@MainActor
protocol PilotWalkingProviding: AnyObject {
    func route(from: GeoPoint, to: GeoPoint) async throws -> WalkingPath
    func cancel()
}

@MainActor
final class AppleWalkingDirections: PilotWalkingProviding {
    private var active: MKDirections?
    // Temporary, request-scoped reuse. Never persisted to disk or used on a non-Apple map.
    private var cache: [String: WalkingPath] = [:]
    private var failed = Set<String>()

    func route(from: GeoPoint, to: GeoPoint) async throws -> WalkingPath {
        try Task.checkCancellation()
        if from == to { return WalkingPath(distanceMeters: 0, expectedSeconds: 0, coordinates: [from], instructions: []) }
        let key = "\(from.latitude),\(from.longitude)>\(to.latitude),\(to.longitude)"
        if let cached = cache[key] { return cached }
        if failed.contains(key) { throw PilotRoutingError.noOptions("This walking connection could not be verified in this search.") }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to.coordinate))
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        active = directions
        let response: MKDirections.Response
        do { response = try await directions.calculate() }
        catch {
            active = nil
            if !Task.isCancelled { failed.insert(key) }
            throw error
        }
        try Task.checkCancellation()
        active = nil
        guard let route = response.routes.first, route.distance.isFinite,
              route.expectedTravelTime.isFinite, route.distance >= 0, route.expectedTravelTime >= 0 else {
            throw PilotRoutingError.noOptions("No pedestrian connection returned by Apple Maps.")
        }
        var points = [CLLocationCoordinate2D](repeating: .init(), count: route.polyline.pointCount)
        route.polyline.getCoordinates(&points, range: NSRange(location: 0, length: points.count))
        guard points.count >= 2, points.allSatisfy(CLLocationCoordinate2DIsValid) else {
            failed.insert(key)
            throw PilotRoutingError.noOptions("Apple Maps returned no usable walking geometry.")
        }
        let path = WalkingPath(distanceMeters: route.distance, expectedSeconds: route.expectedTravelTime,
                               coordinates: points.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) },
                               instructions: route.steps.map(\.instructions).filter { !$0.isEmpty })
        cache[key] = path
        return path
    }
    func cancel() { active?.cancel(); active = nil; cache.removeAll(); failed.removeAll() }
}
