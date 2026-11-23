import SwiftUI

struct CategoriesView: View {
    let onSelect: (ExplorerCategory) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 13) {
                Text("Categories")
                    .font(.system(.title2, design: .serif).bold())
                    .accessibilityAddTraits(.isHeader)
                    .padding(.vertical, 4)

                // Ana ekrandaki küçük kartlarla aynı kategori verisini, büyük kartlarla gösterir.
                ForEach(ExplorerCategory.allCases) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        HStack {
                            Text(category.rawValue)
                                .font(.system(.title3, design: .serif).bold())
                            Spacer()
                            Image(systemName: "chevron.right").font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 166, alignment: .bottomLeading)
                        .background {
                            // Görsel arka planda kalır ve dokunmayı düğme alır.
                            ExplorerArtwork(photo: category.coverPhoto)
                                .overlay {
                                    LinearGradient(colors: [.clear, .black.opacity(0.75)],
                                                   startPoint: .center, endPoint: .bottom)
                                }
                                .allowsHitTesting(false)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(category.rawValue)
                }
            }
            .padding(16)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.91).ignoresSafeArea())
    }
}
