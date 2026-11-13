import SwiftUI

struct AboutView: View {
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ExplorerArtwork(photo: 0)
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("Istanbul Explorer helps you discover the history, culture and beauty of Istanbul. Explore landmarks, browse the gallery and keep your favorite places in your own collection.")
                    .font(.system(.body, design: .serif))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    feature("Photo gallery", icon: "camera.fill")
                    feature("Saved places", icon: "heart.fill")
                    feature("Easy to use", icon: "iphone")
                }

                Divider()
                Text("Our Team").font(.system(.title2, design: .serif).bold())
                Label("Created by a team of three students", systemImage: "person.3.fill")
                Text("An iOS course project, built with SwiftUI.")
                    .font(.subheadline).foregroundStyle(.secondary)

                Divider()
                Text("About the content").font(.headline)
                Text("The scenery images are AI-generated illustrations. They are for inspiration and may differ from the real places. The audio guide button is reserved for a future update.")
                    .font(.footnote).foregroundStyle(.secondary)
                Text("Istanbul Explorer · 1.0").font(.caption).foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background(cream.ignoresSafeArea())
        .navigationTitle("About Istanbul Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
    }

    private func feature(_ title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2)
            Text(title).font(.caption).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
