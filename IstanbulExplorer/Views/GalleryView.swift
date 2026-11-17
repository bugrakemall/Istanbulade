import SwiftUI

struct GalleryView: View {
    // nil: büyük resim kapalı; GalleryPhoto: o resmin sheet'i açık. ? işareti optional demektir.
    @State private var selected: GalleryPhoto?
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)

    var body: some View {
        ScrollView {
            // İki sütun, ekran genişliğine göre kendiliğinden boyutlanır.
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(GalleryPhoto.all) { photo in
                    Button { selected = photo } label: {
                        ExplorerArtwork(photo: photo.id)
                            .aspectRatio(1.55, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(photo.title)
                }
            }
            .padding(14)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background(cream.ignoresSafeArea())
        .navigationTitle("Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        // Seçilen Identifiable öğe varsa SwiftUI alt pencereyi açar; nil olunca kapatır.
        .sheet(item: $selected) { photo in
            ScrollView {
                VStack(alignment: .trailing, spacing: 12) {
                    Button("Done") { selected = nil }
                    ExplorerArtwork(photo: photo.id)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    Text(photo.title)
                        .font(.system(.title2, design: .serif).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(cream.ignoresSafeArea())
            .presentationDragIndicator(.visible)
        }
    }
}

// Yalnızca bu dosyada kullanılan küçük model; id, görsel koleksiyonundaki numaradır.
private struct GalleryPhoto: Identifiable {
    let id: Int
    let title: String

    static let all = [
        GalleryPhoto(id: 6, title: "Spice Bazaar"),
        GalleryPhoto(id: 2, title: "Bosphorus Bridge"),
        GalleryPhoto(id: 1, title: "Hagia Sophia"),
        GalleryPhoto(id: 3, title: "Topkapı Palace"),
        GalleryPhoto(id: 7, title: "Basilica Cistern"),
        GalleryPhoto(id: 4, title: "Blue Mosque"),
        GalleryPhoto(id: 0, title: "Galata Tower"),
        GalleryPhoto(id: 5, title: "Maiden’s Tower"),
        GalleryPhoto(id: 8, title: "Istanbul Modern"),
        GalleryPhoto(id: 9, title: "Breakfast by the Bosphorus")
    ]
}
