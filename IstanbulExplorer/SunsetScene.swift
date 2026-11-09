import SwiftUI

struct SunsetScene: View {
    let isPlaying: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { screen in
            let animate = isPlaying && !reduceMotion && scenePhase == .active
            TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !animate)) { frame in
                // Yakınlaşma ve yana kayma 12 saniyede yumuşakça tekrar eder.
                let seconds = frame.date.timeIntervalSinceReferenceDate
                let angle = seconds.truncatingRemainder(dividingBy: 12) * 2 * Double.pi / 12
                let scale = reduceMotion ? 1 : 1.045 + 0.018 * cos(angle)
                let drift = reduceMotion ? 0 : 3 * sin(angle)

                Image("BosphorusSunset")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screen.size.width, height: screen.size.height)
                    .scaleEffect(CGFloat(scale))
                    .offset(x: CGFloat(drift))
                    .clipped()
            }
        }
        .accessibilityHidden(true)
    }
}
