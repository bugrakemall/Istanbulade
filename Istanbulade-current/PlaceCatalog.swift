import Foundation
import CoreLocation

struct IstanbulPlace: Identifiable, Hashable {
    let id: String
    let name: String
    let area: String
    let symbol: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

enum PlaceCatalog {
    // Landmark centres / district reference points, not precise accessible entrances.
    static let places: [IstanbulPlace] = [
        .init(id: "sultanahmet", name: "Sultanahmet Square", area: "Historic peninsula · Fatih", symbol: "building.columns.fill", latitude: 41.0065, longitude: 28.9756),
        .init(id: "hagia", name: "Hagia Sophia", area: "Sultanahmet · Fatih", symbol: "building.columns.fill", latitude: 41.0086, longitude: 28.9802),
        .init(id: "blue", name: "Blue Mosque", area: "Sultanahmet · Fatih", symbol: "building.columns.fill", latitude: 41.0054, longitude: 28.9768),
        .init(id: "galata", name: "Galata Tower", area: "Beyoğlu · Galata", symbol: "building.2.fill", latitude: 41.0256, longitude: 28.9744),
        .init(id: "taksim", name: "Taksim Square", area: "Beyoğlu · Taksim", symbol: "mappin.and.ellipse", latitude: 41.0369, longitude: 28.9850),
        .init(id: "bazaar", name: "Grand Bazaar", area: "Beyazıt · Fatih", symbol: "bag.fill", latitude: 41.0107, longitude: 28.9680),
        .init(id: "eminonu", name: "Eminönü", area: "Golden Horn · Fatih", symbol: "ferry.fill", latitude: 41.0184, longitude: 28.9709),
        .init(id: "kadikoy", name: "Kadıköy", area: "Asian side · Waterfront", symbol: "ferry.fill", latitude: 40.9915, longitude: 29.0236),
        .init(id: "uskudar", name: "Üsküdar", area: "Asian side · Waterfront", symbol: "ferry.fill", latitude: 41.0269, longitude: 29.0153),
        .init(id: "airport", name: "Sabiha Gökçen Airport", area: "Pendik · Airport", symbol: "airplane", latitude: 40.9055, longitude: 29.3092)
    ]
}
