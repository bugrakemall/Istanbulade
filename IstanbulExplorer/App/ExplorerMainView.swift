import SwiftUI

struct ExplorerMainView: View {
    var body: some View {
        // Sekmeleri TabView, her sekmenin geri dönüşünü kendi NavigationStack'i yönetir.
        TabView {
            NavigationStack {
                ExplorerHomeView()
                    .toolbar(.hidden, for: .navigationBar)
                    .toolbarBackground(.hidden, for: .tabBar)
                    // NavigationLink bir kategori değeri gönderirse bu ekran açılır.
                    .navigationDestination(for: ExplorerCategory.self) { category in
                        CategoryPlacesView(category: category)
                    }
                    // Yer değeri gönderildiğinde detay ekranına aynı kayıt aktarılır.
                    .navigationDestination(for: ExplorerPlace.self) { place in
                        PlaceDetailView(place: place)
                    }
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                CategoriesView()
                    .toolbar(.hidden, for: .navigationBar)
                    .toolbarBackground(.hidden, for: .tabBar)
                    .navigationDestination(for: ExplorerCategory.self) { category in
                        CategoryPlacesView(category: category)
                    }
                    .navigationDestination(for: ExplorerPlace.self) { place in
                        PlaceDetailView(place: place)
                    }
            }
            .tabItem { Label("Categories", systemImage: "square.grid.2x2") }

            // Her sekmenin ayrı NavigationStack'i vardır; geri dönüş yolları birbirine karışmaz.
            NavigationStack {
                FavoritesView()
                    .navigationDestination(for: ExplorerPlace.self) { place in
                        PlaceDetailView(place: place)
                    }
            }
            .tabItem { Label("Favorites", systemImage: "heart") }

            NavigationStack { AboutView() }
                .tabItem { Label("About", systemImage: "person") }
        }
        // tint, bağlantı ve seçili sekme rengini belirler; tabBar arka planı ekranlarda gizlenir.
        .tint(Color(red: 0.06, green: 0.15, blue: 0.25))
        .preferredColorScheme(.light)
    }
}
