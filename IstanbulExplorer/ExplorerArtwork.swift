import SwiftUI

struct ExplorerArtwork: View {
    // Kabul edilen numaralar 0...9; gerçek yer koordinatı veya internet adresi değildir.
    let photo: Int

    var body: some View {
        // Üst ekranın verdiği genişlik/yüksekliği okuyarak doğru görsel parçasını sığdırırız.
        GeometryReader { box in
            // Fotoğraf numarasından kullanılacak görsel grubunu ve kareyi buluyoruz.
            let asset = photo < 4 ? "ExplorerScenes" : photo < 6 ? "HistoricalScenes" : "GalleryScenes"
            let tile = photo < 4 ? photo : photo < 6 ? photo - 4 : photo - 6
            // İlk ve son koleksiyon 2x2, HistoricalScenes 2x1 kareden oluşur.
            let rows: CGFloat = asset == "HistoricalScenes" ? 1 : 2
            let side = max(box.size.width, box.size.height)
            Image(asset)
                .resizable()
                .frame(width: side * 2, height: side * rows)
                // tile % 2 sütunu, tile / 2 satırı bulur (tamsayı bölmesi).
                // Koleksiyonu kaydırıp yalnızca seçilen kareyi görünür alanda bırakırız.
                .offset(
                    x: (box.size.width - side) / 2 - CGFloat(tile % 2) * side,
                    y: (box.size.height - side) / 2 - CGFloat(tile / 2) * side
                )
                .frame(width: box.size.width, height: box.size.height, alignment: .topLeading)
                // Dışarı taşan diğer kareleri keser; kaynak dosyaya müdahale etmez.
                .clipped()
        }
        .accessibilityHidden(true)
    }
}
