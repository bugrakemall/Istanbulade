import SwiftUI

struct SlideToExplore: View {
    let onExplore: () -> Void
    @State private var position = 0.0

    var body: some View {
        VStack(spacing: 2) {
            Text("Explore Istanbul")
                .font(.subheadline.bold())
                .accessibilityHidden(true)

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
        guard !isEditing else { return }
        if position >= 0.9 {
            onExplore()
        } else {
            position = 0
        }
    }
}
