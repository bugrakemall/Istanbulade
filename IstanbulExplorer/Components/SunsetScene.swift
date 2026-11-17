import SwiftUI

struct SunsetScene: View {
    let isPlaying: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Uygulama arka plandayken gereksiz ekran güncellemesini durdurmak için kullanılır.
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { screen in
            let animate = isPlaying && !reduceMotion && scenePhase == .active
            // Video oynatmıyoruz: zaman değiştikçe aynı görselin ölçek ve konumunu hesaplıyoruz.
            // 1/24, güncellemeler arasındaki minimum süredir; sabit FPS garantisi değildir.
            TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !animate)) { frame in
                // Yakınlaşma ve yana kayma 12 saniyede yumuşakça tekrar eder.
                let seconds = frame.date.timeIntervalSinceReferenceDate
                // 12 saniyeyi 0...2π açı aralığına çeviririz; sin/cos keskin dönüşleri önler.
                let angle = seconds.truncatingRemainder(dividingBy: 12) * 2 * Double.pi / 12
                let scale = reduceMotion ? 1 : 1.045 + 0.018 * cos(angle)
                let drift = reduceMotion ? 0 : 3 * sin(angle)

                Image("BosphorusSunset")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screen.size.width, height: screen.size.height)
                    // Görsel biraz büyütülür; yana kayarken kenarda boşluk oluşması azaltılır.
                    .scaleEffect(CGFloat(scale))
                    .offset(x: CGFloat(drift))
                    .clipped()
            }
        }
        .accessibilityHidden(true)
    }
}
