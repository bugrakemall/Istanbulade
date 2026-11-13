import SwiftUI

struct SlideToExplore: View {
    // () -> Void: parametre almayan, değer döndürmeyen bir işlem.
    let onExplore: () -> Void
    // Slider konumu 0 (sol) ile 1 (sağ) arasında değişir; kalıcı kaydedilmez.
    @State private var position = 0.0

    var body: some View {
        VStack(spacing: 2) {
            Text("Explore Istanbul")
                .font(.subheadline.bold())
                .accessibilityHidden(true)

            // $position çift yönlü bağlantıdır: Slider hem değeri okur hem değiştirir.
            // onEditingChanged, sürükleme başlarken true, biterken false verir.
            Slider(value: $position, in: 0...1, onEditingChanged: finishSlide)
                .tint(.black.opacity(0.75))
                .environment(\.colorScheme, .light)
                .accessibilityLabel("Explore Istanbul")
                .accessibilityHint("Slide right to enter")
                .accessibilityAction { onExplore() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .foregroundStyle(.black)
        .background(Color(red: 1, green: 0.70, blue: 0.28), in: Capsule())
        .environment(\.layoutDirection, .leftToRight)
    }

    private func finishSlide(_ isEditing: Bool) {
        // Parmağı bırakınca kontrol et: kısa kaydırma başa döner.
        // Sürükleme devam ediyorsa erken çık; yalnızca bırakılınca aşağıya geç.
        guard !isEditing else { return }
        // Yolun en az %90'ı tamamlandıysa üst ekranın verdiği işlemi çağır.
        if position >= 0.9 {
            onExplore()
        } else {
            position = 0
        }
    }
}
