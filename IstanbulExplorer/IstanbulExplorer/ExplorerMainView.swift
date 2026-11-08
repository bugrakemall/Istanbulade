import SwiftUI

struct ExplorerMainView: View {
    @State private var showingCategories = false
    @State private var path: [ExplorerCategory] = []

    private let cream = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let navy = Color(red: 0.06, green: 0.15, blue: 0.25)

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $path) {
                Group {
                    if showingCategories {
                        CategoriesView(onCategory: openCategory)
                    } else {
                        ExplorerHomeView(onCategory: openCategory)
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: ExplorerCategory.self) { category in
                    CategoryPlacesView(category: category)
                }
            }

            Divider()
            HStack {
                Button { openTab(categories: false) } label: { tab("Home", "house.fill") }
                    .accessibilityAddTraits(showingCategories ? [] : .isSelected)
                    .foregroundStyle(showingCategories ? Color.secondary : navy)
                Button { openTab(categories: true) } label: { tab("Categories", "square.grid.2x2.fill") }
                    .accessibilityAddTraits(showingCategories ? .isSelected : [])
                    .foregroundStyle(showingCategories ? navy : Color.secondary)
                tab("Favorites", "heart").foregroundStyle(.secondary)
                tab("About", "person").foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
            .background(cream)
        }
        .background(cream.ignoresSafeArea())
        .tint(navy)
        .preferredColorScheme(.light)
    }

    private func openTab(categories: Bool) {
        // Sekme değişince varsa açık yer listesini kapatıyoruz.
        path.removeAll()
        showingCategories = categories
    }

    private func openCategory(_ category: ExplorerCategory) {
        // Geri tuşu, listenin hangi sekmeden açıldığına göre oraya döner.
        path.append(category)
    }

    private func tab(_ title: String, _ icon: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 18))
            Text(title).font(.caption2)
        }
        .frame(maxWidth: .infinity, minHeight: 48)
        .contentShape(Rectangle())
    }
}
