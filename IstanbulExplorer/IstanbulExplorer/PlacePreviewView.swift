import SwiftUI

struct PlacePreviewView: View {
    let place: ExplorerPlace

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ExplorerArtwork(photo: place.photo)
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Text(place.name).font(.system(.title, design: .serif).bold())
                Text(place.summary).foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
