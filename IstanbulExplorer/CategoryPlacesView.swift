import SwiftUI

struct CategoryPlacesView: View {
    // Önceki ekrandan seçilen kategori gelir; bu ekranda değiştirilmez.
    let category: ExplorerCategory
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)

    var body: some View {
        // Yalnızca açılan kategoriye ait kayıtlı yerleri gösteriyoruz.
        // $0, filter içindeki sıradaki yerdir; kategoriyi içeriyorsa listede kalır.
        List(ExplorerPlace.all.filter { $0.categories.contains(category) }) { place in
            NavigationLink(value: place) {
                HStack(spacing: 12) {
                    ExplorerArtwork(photo: place.photo)
                        .frame(width: 114, height: 86)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(place.name).font(.system(.headline, design: .serif))
                        Text(place.summary).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14))
            .listRowBackground(cream)
        }
        .listStyle(.plain)
        // List'in varsayılan zeminini gizleyerek uygulamanın krem rengini gösteririz.
        .scrollContentBackground(.hidden)
        .background(cream.ignoresSafeArea())
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
    }
}
