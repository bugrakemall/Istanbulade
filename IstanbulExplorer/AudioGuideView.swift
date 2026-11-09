import SwiftUI

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
        .disabled(true)
    }
}
