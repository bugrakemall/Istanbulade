import SwiftUI

enum ExplorerCategory: String, CaseIterable, Identifiable {
    case historical = "Historical Places"
    case nature = "Nature & Views"
    case museums = "Museums"

    var id: Self { self }

    var coverPhoto: Int {
        switch self {
        case .historical: return 1
        case .nature: return 2
        case .museums: return 3
        }
    }

    var icon: String {
        switch self {
        case .historical, .museums: return "building.columns.fill"
        case .nature: return "tree.fill"
        }
    }

    var color: Color {
        switch self {
        case .historical: return Color(red: 1, green: 0.80, blue: 0.46)
        case .nature: return Color(red: 0.65, green: 0.90, blue: 0.78)
        case .museums: return Color(red: 0.65, green: 0.84, blue: 0.95)
        }
    }
}

struct ExplorerPlace: Identifiable {
    let name: String
    let summary: String
    let categories: [ExplorerCategory]
    let photo: Int

    var id: String { name }

    private static let hagiaSophia = ExplorerPlace(
        name: "Hagia Sophia", summary: "A historic landmark in Sultanahmet.",
        categories: [.historical], photo: 1
    )
    private static let galataTower = ExplorerPlace(
        name: "Galata Tower", summary: "An iconic tower with views across the city.",
        categories: [.historical], photo: 0
    )

    static let popular = [hagiaSophia, galataTower]

    // Bazı yerler iki kategoriye de girer; aynı kaydı tekrar yazmıyoruz.
    static let all = [
        hagiaSophia,
        ExplorerPlace(name: "Topkapı Palace", summary: "The former home of Ottoman sultans.",
                      categories: [.historical, .museums], photo: 3),
        ExplorerPlace(name: "Blue Mosque", summary: "A landmark of Ottoman architecture.",
                      categories: [.historical], photo: 4),
        galataTower,
        ExplorerPlace(name: "Maiden’s Tower", summary: "A small island landmark in the Bosphorus.",
                      categories: [.historical, .nature], photo: 5),
        ExplorerPlace(name: "Bosphorus Bridge", summary: "A view across the strait.",
                      categories: [.nature], photo: 2)
    ]
}
