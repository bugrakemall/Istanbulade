import SwiftUI

struct NewsCard: View {
    @State private var headline: IstanbulHeadline?
    @State private var loaded = false
    @State private var failed = false
    @State private var requestID = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Istanbul News", systemImage: "newspaper")
                .font(.subheadline.bold())

            if let headline {
                Link(destination: headline.url) {
                    Text(headline.title).font(.caption.bold()).lineLimit(3)
                }
                Text("Source: TRT Haber").font(.caption2)
            } else if failed {
                Text("News unavailable.").font(.caption)
                Button("Try again") { requestID += 1 }.font(.caption)
            } else if loaded {
                Text("No Istanbul headlines right now.").font(.caption)
            } else {
                ProgressView("Loading news…").font(.caption)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(Color(red: 0.96, green: 0.90, blue: 0.80), in: RoundedRectangle(cornerRadius: 10))
        .task(id: requestID) {
            failed = false
            loaded = false
            headline = nil
            do {
                let result = try await IstanbulHeadline.fetch()
                guard !Task.isCancelled else { return }
                headline = result
                loaded = true
            } catch {
                if !Task.isCancelled { failed = true }
            }
        }
    }
}
