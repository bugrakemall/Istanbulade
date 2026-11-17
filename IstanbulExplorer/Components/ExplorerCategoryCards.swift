import SwiftUI

struct ExplorerCategoryCards: View {
    // Aynı genişlikte üç sütun: ana ekrandaki küçük kategori kısayolları.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            // Enum'daki tüm kategorileri dolaşır; yeni bir kategori elle kart kopyalamayı gerektirmez.
            ForEach(ExplorerCategory.allCases) { category in
                NavigationLink(value: category) {
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
