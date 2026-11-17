import SwiftUI

// enum sabit seçenekleri tutar. CaseIterable -> allCases; Identifiable -> ForEach kimliği;
// Hashable -> NavigationLink(value:) için karşılaştırılabilir/özetlenebilir değer.
enum ExplorerCategory: String, CaseIterable, Identifiable, Hashable {
    case historical = "Historical Places"
    case nature = "Nature & Views"
    case museums = "Museums"

    var id: Self { self }

    // Görsel numarası ExplorerArtwork içindeki koleksiyon sırasına karşılık gelir.
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

// Veri modeli: ekran çizmez, bir yerin bilgilerini taşır. Sınıf yerine basit bir struct kullanılır.
struct ExplorerPlace: Identifiable, Hashable {
    let name: String
    let summary: String
    let location: String
    let guide: String
    let categories: [ExplorerCategory]
    let photo: Int

    // Bu küçük örnekte benzersiz isim kimliktir. İsim değişirse eski favori eşleşmesi kaybolur.
    var id: String { name }

    private static let hagiaSophia = ExplorerPlace(
        name: "Hagia Sophia", summary: "A historic landmark in Sultanahmet.",
        location: "Sultanahmet, Istanbul",
        guide: "Completed in 537 during the reign of Justinian, Hagia Sophia is one of Istanbul's most remarkable landmarks. Look for the vast central dome and the surviving mosaics. Its architecture reflects different eras of the city's Byzantine and Ottoman history.",
        categories: [.historical], photo: 1
    )
    private static let galataTower = ExplorerPlace(
        name: "Galata Tower", summary: "An iconic tower with views across the city.",
        location: "Beyoğlu, Istanbul",
        guide: "Galata Tower rises above the streets of Beyoglu. From the upper levels, look across the Golden Horn toward the historic peninsula. The winding streets around the tower are another way to explore this part of the city.",
        categories: [.historical], photo: 0
    )

    // static: her ekran için yeni veri oluşturmak yerine türün üzerinden erişilir.
    static let popular = [hagiaSophia, galataTower]

    // Bazı yerler iki kategoriye de girer; aynı kaydı tekrar yazmıyoruz.
    // Sunucudan veri çekilmez; altı yer uygulamanın içine sabit olarak yazılmıştır.
    static let all = [
        hagiaSophia,
        ExplorerPlace(name: "Topkapı Palace", summary: "The former home of Ottoman sultans.",
                      location: "Fatih, Istanbul",
                      guide: "Topkapi Palace was a residence of the Ottoman sultans. As you pass from one courtyard to another, notice how the gates and pavilions shape the experience of entering the palace. The complex also looks out over the waters around the historic peninsula.",
                      categories: [.historical, .museums], photo: 3),
        ExplorerPlace(name: "Blue Mosque", summary: "A landmark of Ottoman architecture.",
                      location: "Sultanahmet, Istanbul",
                      guide: "The Blue Mosque stands across the square from Hagia Sophia. Its six minarets frame a series of domes, and blue Iznik tiles give the mosque its familiar nickname. The courtyard offers a place to pause and take in the whole building.",
                      categories: [.historical], photo: 4),
        galataTower,
        ExplorerPlace(name: "Maiden’s Tower", summary: "A small island landmark in the Bosphorus.",
                      location: "Üsküdar, Istanbul",
                      guide: "Maiden's Tower stands on a small island off the Uskudar shore. It has served different purposes over time, including watching over traffic on the strait. From the waterfront, watch how its silhouette changes as boats pass between the tower and the shore.",
                      categories: [.historical, .nature], photo: 5),
        ExplorerPlace(name: "Bosphorus Bridge", summary: "A view across the strait.",
                      location: "Bosphorus, Istanbul",
                      guide: "The Bosphorus Bridge spans the water between the European and Asian sides of Istanbul. The Ortakoy waterfront is a good place to see the bridge, the mosque, and the strait in a single view. Watch the changing light on the water toward sunset.",
                      categories: [.nature], photo: 2)
    ]
}
