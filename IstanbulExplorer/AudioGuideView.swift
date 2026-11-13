import SwiftUI

// Tasarımdaki yerini koruyan pasif kontrol: oynatıcı ve ses dosyası bu sürümde yoktur.
struct AudioGuideView: View {
    var body: some View {
        // Sesli rehber geri gelene kadar düğme sadece görünür.
        Button {} label: {
            Label("Play Audio Guide", systemImage: "play.circle.fill")
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 10)
                .background(.gray.opacity(0.16), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        // Boş action yanlışlıkla çalışan bir rehber sanılmasın; etkileşim kapalıdır.
        .disabled(true)
    }
}
