import SwiftUI

struct CategoriesView: View {
    let onCategory: (ExplorerCategory) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 13) {
                Text("Categories")
                    .font(.system(.title2, design: .serif).bold())
                    .accessibilityAddTraits(.isHeader)
                    .padding(.vertical, 4)

                ForEach(ExplorerCategory.allCases) { category in
                    Button { onCategory(category) } label: {
                        ExplorerArtwork(photo: category.coverPhoto)
                            .frame(height: 166)
                            .overlay(alignment: .bottom) {
                                HStack {
                                    Text(category.rawValue)
                                        .font(.system(.title3, design: .serif).bold())
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.subheadline)
                                }
                                .foregroundStyle(.white)
                                .padding(14)
                                .background {
                                    LinearGradient(colors: [.clear, .black.opacity(0.75)],
                                                   startPoint: .top, endPoint: .bottom)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 14))
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
