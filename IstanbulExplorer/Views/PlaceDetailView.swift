import SwiftUI

struct PlaceDetailView: View {
    // Ana ekran, liste veya favoriler hangi yeri gönderirse o kaydın detayını gösterir.
    let place: ExplorerPlace
    // UserDefaults üzerindeki aynı anahtarı FavoritesView de kullanır.
    @AppStorage("favoritePlaceIDs") private var savedFavorites = ""

    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let navy = Color(red: 0.06, green: 0.15, blue: 0.25)

    // AppStorage, favorileri uygulama kapandıktan sonra da cihazda saklar.
    // Örnek kayıt: Hagia Sophia|Galata Tower. split ile kimlik dizisine dönüştürürüz.
    private var favorites: [String] { savedFavorites.split(separator: "|").map(String.init) }
    private var isFavorite: Bool { favorites.contains(place.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ExplorerArtwork(photo: place.photo)
                    .frame(height: 265)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text(place.name)
                        .font(.system(.largeTitle, design: .serif).bold())
                        .accessibilityAddTraits(.isHeader)
                    Label(place.location, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                }

                Text(place.guide).font(.system(.body, design: .serif))
                AudioGuideView()

                // Burada değer yerine doğrudan hedef View verilir; galeri tüm yerler için ortaktır.
                NavigationLink {
                    GalleryView()
                } label: {
                    Label("View Gallery", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                .buttonStyle(.borderedProminent)
                .tint(navy)
            }
            .padding(16)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(navy)
        .background(cream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
    }

    private func toggleFavorite() {
        var updated = favorites
        if isFavorite {
            updated.removeAll { $0 == place.id }
        } else {
            updated.append(place.id)
        }
        // Dizi tekrar tek metne çevrilir; AppStorage yeni değeri kalıcı olarak yazar.
        savedFavorites = updated.joined(separator: "|")
    }
}
