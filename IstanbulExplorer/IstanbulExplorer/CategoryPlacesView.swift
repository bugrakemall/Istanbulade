import SwiftUI

struct CategoryPlacesView: View {
    let category: ExplorerCategory
    @State private var selectedPlace: ExplorerPlace?
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)

    var body: some View {
        // Yalnızca açılan kategoriye ait kayıtlı yerleri gösteriyoruz.
        List(ExplorerPlace.all.filter { $0.categories.contains(category) }) { place in
            Button {
                selectedPlace = place
            } label: {
                HStack(spacing: 12) {
                    ExplorerArtwork(photo: place.photo)
                        .frame(width: 114, height: 86)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(place.name).font(.system(.headline, design: .serif))
                        Text(place.summary).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption).foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14))
            .listRowBackground(cream)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(cream.ignoresSafeArea())
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $selectedPlace) { place in
            PlacePreviewView(place: place)
        }
    }
}
