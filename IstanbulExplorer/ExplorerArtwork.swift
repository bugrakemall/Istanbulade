import SwiftUI

struct ExplorerArtwork: View {
    let photo: Int

    var body: some View {
        GeometryReader { box in
            // Fotoğraf numarasından kullanılacak görsel grubunu ve kareyi buluyoruz.
            let asset = photo < 4 ? "ExplorerScenes" : photo < 6 ? "HistoricalScenes" : "GalleryScenes"
            let tile = photo < 4 ? photo : photo < 6 ? photo - 4 : photo - 6
            let rows: CGFloat = asset == "HistoricalScenes" ? 1 : 2
            let side = max(box.size.width, box.size.height)
            Image(asset)
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
