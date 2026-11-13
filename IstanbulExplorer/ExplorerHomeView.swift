import SwiftUI

struct ExplorerHomeView: View {
    // Bu üç değer yalnızca ana ekranın görünümünü yönetir; diske yazılmaz.
    @State private var showSearch = false
    @State private var query = ""
    @State private var showAll = false

    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let navy = Color(red: 0.06, green: 0.15, blue: 0.25)

    // Hesaplanan özellik: sorgu veya gösterim durumu değişince güncel listeyi üretir.
    private var visiblePlaces: [ExplorerPlace] {
        // Baş ve sondaki boşlukları temizler; arama yalnızca kayıtlı yer isimlerinde yapılır.
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        // Arama yoksa ana ekranda önce iki popüler yer gösterilir.
        let matches = ExplorerPlace.all.filter { place in
            term.isEmpty || place.name.localizedStandardContains(term)
        }
        return showAll || !term.isEmpty ? matches : ExplorerPlace.popular
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 13) {
                header
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you want to explore?")
                        .font(.system(.headline, design: .serif))
                    ExplorerCategoryCards()
                }

                popularPlaces
            }
            .padding(14)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .foregroundStyle(navy)
        .background(cream.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Grid(alignment: .leading, horizontalSpacing: 6) {
                GridRow {
                    Text("Istanbul Explorer")
                        .font(.system(.title, design: .serif).bold())
                        .accessibilityAddTraits(.isHeader)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        showSearch.toggle()
                        // Aramayı kapatınca eski metin sonucu filtrelemeye devam etmesin.
                        if !showSearch { query = "" }
                    } label: {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(showSearch ? "Close search" : "Search places")
                }
            }
            if showSearch {
                // $query, yazılan metni State'e aktarır; sonuçlar ayrıca bir arama tuşu istemez.
                TextField("Search places", text: $query)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var hero: some View {
        ExplorerArtwork(photo: 0)
            .frame(height: 225)
            .overlay(alignment: .bottomLeading) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [.black.opacity(0.66), .clear], startPoint: .bottom, endPoint: .center)
                    Text("Explore\nDiscover\nExperience")
                        .font(.system(.title2, design: .serif).bold())
                        .foregroundStyle(.white)
                        .padding(16)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var popularPlaces: some View {
        VStack(alignment: .leading, spacing: 8) {
            Grid(alignment: .leading, horizontalSpacing: 6) {
                GridRow {
                    Text("Popular Places").font(.system(.headline, design: .serif))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if query.isEmpty {
                        Button(showAll ? "Show less" : "See all") { showAll.toggle() }
                            .font(.subheadline)
                    }
                }
            }
            if visiblePlaces.isEmpty {
                Text("No matching places.").foregroundStyle(.secondary)
            }
            // İki esnek sütun; kart, ExplorerPlace değerini NavigationStack'e gönderir.
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(visiblePlaces) { place in
                    NavigationLink(value: place) {
                        ExplorerArtwork(photo: place.photo)
                            .frame(height: 112)
                            .overlay(alignment: .bottomLeading) {
                                Text(place.name).font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(6)
                                    .background(.black.opacity(0.65), in: RoundedRectangle(cornerRadius: 5))
                                    .padding(6)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(place.name)
                }
            }
        }
    }

}
