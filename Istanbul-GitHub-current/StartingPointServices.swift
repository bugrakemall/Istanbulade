import Foundation
import Combine
import CoreLocation
import MapKit

@MainActor
final class StartingPointSearch: ObservableObject {
    @Published private(set) var results: [MKMapItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    private var activeSearch: MKLocalSearch?
    private var revision = UUID()

    func lookup(_ text: String) async {
        let requestID = UUID()
        revision = requestID
        activeSearch?.cancel()
        activeSearch = nil
        results = []
        error = nil
        isLoading = false
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 2 else { return }
        do {
            // Debounce typing; .task(id:) cancels obsolete lookups.
            try await Task.sleep(for: .milliseconds(350))
            try Task.checkCancellation()
            guard revision == requestID else { return }
            isLoading = true
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = [.address, .pointOfInterest]
            // Bias to Istanbul; the map can still accept any valid coordinate.
            request.region = MKCoordinateRegion(center: .init(latitude: 41.02, longitude: 29.04),
                                                span: .init(latitudeDelta: 0.35, longitudeDelta: 0.6))
            let search = MKLocalSearch(request: request)
            activeSearch = search
            let response = try await search.start()
            try Task.checkCancellation()
            guard revision == requestID else { return }
            results = Array(response.mapItems.filter {
                CLLocationCoordinate2DIsValid($0.placemark.coordinate)
            }.prefix(10))
            isLoading = false
            activeSearch = nil
        } catch {
            guard revision == requestID else { return }
            isLoading = false
            activeSearch = nil
            if !Task.isCancelled && !(error is CancellationError) {
                self.error = "Address search is unavailable. Check your internet, or select a point on the map."
            }
        }
    }

    func cancel() {
        revision = UUID()
        activeSearch?.cancel()
        activeSearch = nil
        isLoading = false
    }
}

@MainActor
final class StartingPointLocator: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published private(set) var fix: StartingPoint?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var canOpenSettings = false
    private let manager = CLLocationManager()
    private var pending = false
    private var timeout: Task<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        cancel()
        fix = nil
        error = nil
        canOpenSettings = false
        // Missing privacy configuration must not crash the app.
        guard let purpose = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String,
              !purpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "Location setup is missing. Add Privacy – Location When In Use Usage Description in the Xcode target's Info tab. You can still use address search or the map."
            return
        }
        pending = true
        isLoading = true
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: requestFix()
        case .denied: fail("Location access is denied. Enable it in Settings, or choose an address or map point.", settings: true)
        case .restricted: fail("Location access is restricted on this device. Choose an address or map point instead.")
        @unknown default: fail("Location is unavailable. Choose an address or map point instead.")
        }
    }

    func cancel() {
        pending = false
        isLoading = false
        timeout?.cancel()
        timeout = nil
        manager.stopUpdatingLocation()
    }

    private func requestFix() {
        guard pending else { return }
        timeout?.cancel()
        manager.requestLocation()
        timeout = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(15)) } catch { return }
            guard let self, self.pending else { return }
            self.fail("Your position could not be found. Try again, or choose an address or map point.")
        }
    }

    private func fail(_ message: String, settings: Bool = false) {
        cancel()
        error = message
        canOpenSettings = settings
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard pending else { return } // Never request permission on screen launch.
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: requestFix()
        case .denied: fail("Location access is denied. Enable it in Settings, or choose another starting point.", settings: true)
        case .restricted: fail("Location access is restricted. Choose an address or map point.")
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard pending else { return }
        guard let location = locations.last(where: {
            $0.horizontalAccuracy >= 0 && abs($0.timestamp.timeIntervalSinceNow) < 120 && CLLocationCoordinate2DIsValid($0.coordinate)
        }) else {
            fail("A fresh position is unavailable. Try again or drop a pin.")
            return
        }
        let point = StartingPoint(name: "My location", subtitle: "Device location · ±\(Int(location.horizontalAccuracy.rounded())) m",
                                  latitude: location.coordinate.latitude, longitude: location.coordinate.longitude,
                                  source: .device, accuracyMeters: location.horizontalAccuracy)
        cancel()
        fix = point
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard pending else { return }
        if (error as? CLError)?.code == .denied {
            fail("Location is unavailable or disabled. Check Settings, or choose an address or map point.", settings: true)
        } else {
            fail("Could not find your location. Try again, or choose an address or map point.")
        }
    }
}
