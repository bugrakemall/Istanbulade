import SwiftUI

struct ExplorerArtwork: View {
    let photo: Int

    var body: some View {
        GeometryReader { box in
            // İlk dört fotoğraf 2 × 2, sonraki ikisi yan yana durur.
            let historical = photo >= 4
            let tile = historical ? photo - 4 : photo
            let rows: CGFloat = historical ? 1 : 2
            let side = max(box.size.width, box.size.height)
            Image(historical ? "HistoricalScenes" : "ExplorerScenes")
                .resizable()
                .frame(width: side * 2, height: side * rows)
                .offset(
                    x: (box.size.width - side) / 2 - CGFloat(tile % 2) * side,
                    y: (box.size.height - side) / 2 - CGFloat(tile / 2) * side
                )
                .frame(width: box.size.width, height: box.size.height, alignment: .topLeading)
                .clipped()
        }
        .accessibilityHidden(true)
    }
}
