import SwiftUI

// @main, iOS uygulamasının başlayacağı yapıyı belirtir.
@main
struct IstanbulExplorerApp: App {
    // Geçici ekran durumu: uygulama yeniden başlatılınca giriş tekrar görünür.
    @State private var isExploring = false

    var body: some Scene {
        // WindowGroup, uygulamanın ana ekran içeriğini oluşturur.
        WindowGroup {
            if isExploring {
                ExplorerMainView()
            } else {
                // Alt ekrana bir işlem (closure) veriyoruz; kaydırma tamamlanınca çalışır.
                WelcomeView { isExploring = true }
            }
        }
    }
}
