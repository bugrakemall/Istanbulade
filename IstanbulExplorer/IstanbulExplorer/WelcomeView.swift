import SwiftUI

struct WelcomeView: View {
    let onExplore: () -> Void
    @State private var isPlaying = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            SunsetScene(isPlaying: isPlaying).ignoresSafeArea()
            LinearGradient(
                colors: [.black.opacity(0.38), .clear, .black.opacity(0.28)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Text("Istanbul\nExplorer")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 26)

                Spacer()
                if !reduceMotion {
                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                            .frame(width: 66, height: 66)
                            .background(.black.opacity(0.28), in: Circle())
                            .overlay { Circle().strokeBorder(.white, lineWidth: 1.5) }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isPlaying ? "Pause scenery animation" : "Play scenery animation")
                }
                Spacer()

                SlideToExplore(onExplore: onExplore)
                    .frame(maxWidth: 320)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
            }
            .foregroundStyle(.white)
        }
        .preferredColorScheme(.dark)
    }
}
