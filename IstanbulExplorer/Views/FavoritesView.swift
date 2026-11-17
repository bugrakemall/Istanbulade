import SwiftUI

struct FavoritesView: View {
    // Detaydaki kalple aynı anahtar: iki ekran da aynı kayıtları okur.
    @AppStorage("favoritePlaceIDs") private var savedFavorites = ""
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)

    // Kayıtta yalnızca isimler vardır; tam yer bilgilerini ana veri dizisinden buluruz.
    private var favorites: [ExplorerPlace] {
        let ids = savedFavorites.split(separator: "|").map(String.init)
        return ExplorerPlace.all.filter { ids.contains($0.id) }
    }

    var body: some View {
        List {
            ForEach(favorites) { place in
                NavigationLink(value: place) {
                    HStack(spacing: 12) {
                        ExplorerArtwork(photo: place.photo)
                            .frame(width: 78, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(place.name).font(.system(.headline, design: .serif))
                            Text(place.location).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "heart.fill").foregroundStyle(.red)
                    }
                    .padding(.vertical, 5)
                }
                .listRowBackground(cream)
            }
            // List satırını sola kaydırıp silme işlemini SwiftUI sağlar.
            .onDelete(perform: removeFavorites)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(cream.ignoresSafeArea())
        // Kayıt yoksa boş bir liste yerine kullanıcıya ne yapacağını söyleyen görünüm gösterilir.
        .overlay {
            if favorites.isEmpty {
                ContentUnavailableView("Your Istanbul collection", systemImage: "heart",
                    description: Text("Tap the heart on a place to save it here."))
            }
        }
        .navigationTitle("My Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
    }

    private func removeFavorites(at offsets: IndexSet) {
        // Kaydırarak silerken yalnızca seçilen yerlerin kimliklerini çıkarırız.
        // IndexSet, ekrandaki favori listesinin satır numaralarıdır; ana veri dizisinin değil.
        let removed = offsets.map { favorites[$0].id }
        savedFavorites = savedFavorites.split(separator: "|").map(String.init)
            .filter { !removed.contains($0) }.joined(separator: "|")
    }
}
