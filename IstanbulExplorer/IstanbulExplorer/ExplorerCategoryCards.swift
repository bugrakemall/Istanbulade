import SwiftUI

struct ExplorerCategoryCards: View {
    let onCategory: (ExplorerCategory) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ExplorerCategory.allCases) { category in
                Button {
                    onCategory(category)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: category.icon).font(.title2)
                        Text(category.rawValue)
                            .font(.system(.caption, design: .serif).weight(.semibold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity, minHeight: 82)
                    .background(category.color, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
