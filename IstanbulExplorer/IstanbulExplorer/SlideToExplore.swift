import SwiftUI

struct SlideToExplore: View {
    let onExplore: () -> Void
    @GestureState private var drag: CGFloat = 0

    var body: some View {
        GeometryReader { track in
            // 44 pt ok ve iki kenardaki boşluk, hareket alanına dahil değil.
            let travel = max(0, track.size.width - 52)

            ZStack(alignment: .leading) {
                Capsule().fill(Color(red: 1, green: 0.70, blue: 0.28))
                Text("Explore Istanbul")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 48)
                    .frame(maxWidth: .infinity)
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.75), in: Circle())
                    .offset(x: 4 + min(max(0, drag), travel))
            }
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 8)
                    .updating($drag) { value, position, _ in
                        position = value.translation.width
                    }
                    .onEnded { value in
                        // Yeterince kaymazsa @GestureState oku başlangıca döndürür.
                        if travel > 0 && value.translation.width >= travel * 0.9 {
                            onExplore()
                        }
                    }
            )
        }
        .frame(height: 52)
        .foregroundStyle(.black)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Explore Istanbul")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onExplore() }
    }
}
