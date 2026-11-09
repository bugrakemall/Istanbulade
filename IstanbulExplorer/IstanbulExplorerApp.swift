import SwiftUI

@main
struct IstanbulExplorerApp: App {
    @State private var isExploring = false

    var body: some Scene {
        WindowGroup {
            if isExploring {
                ExplorerMainView()
            } else {
                WelcomeView { isExploring = true }
            }
        }
    }
}
