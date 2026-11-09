import SwiftUI
import SlideButton

struct SlideToExplore: View {
    let onExplore: () -> Void

    var body: some View {
        // Kaydırma hareketini kütüphane yönetir. Biz görünümü ve giriş işlemini veriyoruz.
        SlideButton(styling: .init(
            indicatorSize: 52,
            indicatorSpacing: 4,
            indicatorColor: .white.opacity(0.75),
            backgroundColor: Color(red: 1, green: 0.70, blue: 0.28),
            textColor: .black,
            indicatorSystemName: "arrow.right",
            textAlignment: .globalCenter
        ), action: {
            await MainActor.run { onExplore() }
        }) {
            Text("Explore Istanbul")
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
