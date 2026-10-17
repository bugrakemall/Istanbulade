import SwiftUI
import MapKit

struct DestinationPickerView: View {
    let selectingOrigin: Bool
    let currentName: String
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var rowHeight = 62
    @State private var query = ""
    @State private var accurateMap = false
    @State private var selectedID = "sultanahmet"
    @FocusState private var searchFocused: Bool
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: .init(latitude: 41.016, longitude: 28.981),
        span: .init(latitudeDelta: 0.035, longitudeDelta: 0.045)))

    private var places: [IstanbulPlace] {
        PlaceCatalog.places.filter { !selectingOrigin || RouteCatalog.origins.contains($0.name) }
    }
    private var filtered: [IstanbulPlace] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return places.filter { term.isEmpty || "\($0.name) \($0.area)".localizedStandardContains(term) }
    }
    private var selected: IstanbulPlace? { filtered.first { $0.id == selectedID } }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                searchBar
                Group {
                    if accurateMap { destinationMap }
                    else {
                        IllustratedDestinationMap(selectedID: selectedID) { select($0) }
                            .overlay(alignment: .topTrailing) {
                                Button("Apple Maps") { accurateMap = true }
                                    .font(.caption.bold()).padding(10)
                                    .background(IstanbulStyle.paper, in: Capsule()).padding(10)
                            }
                            .overlay(alignment: .bottomLeading) {
                                Text("Illustrated overview · approximate positions")
                                    .font(.system(size: 9)).padding(5)
                                    .background(IstanbulStyle.paper.opacity(0.9)).padding(.bottom, 20)
                            }
                    }
                }
                    .frame(height: max(170, min(geometry.size.height * 0.38, 310)))
                placesPanel
                    .padding(.top, -18)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let selected { confirmationCard(selected) }
        }
        .background(IstanbulStyle.cream)
        .modifier(IstanbulSurface())
        .navigationTitle(selectingOrigin ? "Starting point" : "Choose destination")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .foregroundStyle(IstanbulStyle.ink)
                .accessibilityLabel("Back")
            }
        }
        .onAppear {
            let initial = places.first { $0.name == currentName }
                ?? places.first { $0.id == "sultanahmet" } ?? places.first
            if let initial { select(initial) }
        }
        .onChange(of: query) { _, _ in
            if !filtered.contains(where: { $0.id == selectedID }) {
                selectedID = filtered.first?.id ?? ""
            }
            fitVisiblePlaces()
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search a place or neighbourhood", text: $query)
                .font(.subheadline)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($searchFocused)
                .onSubmit { searchFocused = false; fitVisiblePlaces() }
                .accessibilityLabel("Search destinations")
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, query.isEmpty ? 14 : 0)
        .frame(minHeight: 48)
        .background(IstanbulStyle.ink.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    private var destinationMap: some View {
        Map(position: $camera) {
            ForEach(places) { place in
                Annotation("", coordinate: place.coordinate, anchor: .bottom) {
                    Button { select(place) } label: {
                        VStack(spacing: 3) {
                            if selectedID == place.id {
                                CoralMapPin()
                                Text(place.name.uppercased())
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6).padding(.vertical, 3)
                                    .background(IstanbulStyle.paper, in: Capsule())
                            } else {
                                LandmarkArtwork(placeID: place.id)
                                    .frame(width: 40, height: 45)
                            }
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .foregroundStyle(IstanbulStyle.ink)
                    }
                    .buttonStyle(CityPressStyle())
                    .accessibilityLabel("Select \(place.name)")
                    .accessibilityAddTraits(selectedID == place.id ? [.isSelected] : [])
                }
            }
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
        .overlay(alignment: .topTrailing) {
            Button { searchFocused = false; fitVisiblePlaces() } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(IstanbulStyle.paper, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
            }
            .padding(12)
            .accessibilityLabel("Show all matching places")
        }
        .overlay(alignment: .bottomTrailing) {
            Button("Illustrated map") { accurateMap = false }
                .font(.caption.bold()).padding(10)
                .background(IstanbulStyle.paper, in: Capsule()).padding(.bottom, 22).padding(.trailing, 10)
        }
        .accessibilityLabel("Istanbul destination map")
    }

    private var placesPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Places")
                .font(.headline)
                .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 6)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filtered) { place in
                        Button { select(place) } label: {
                            HStack(spacing: 14) {
                                Image(systemName: place.id == "sultanahmet" ? "mappin.circle.fill" : place.symbol)
                                    .font(.title3)
                                    .foregroundStyle(IstanbulStyle.ink.opacity(0.65))
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(place.name).font(.subheadline.weight(.semibold))
                                    Text("Istanbul").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .frame(minHeight: rowHeight)
                            .contentShape(Rectangle())
                            .background(selectedID == place.id ? IstanbulStyle.ink.opacity(0.045) : .clear)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedID == place.id ? [.isSelected] : [])
                        Divider().padding(.leading, 60)
                    }
                }
                .padding(.horizontal, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
        }
        .background(IstanbulStyle.paper, in: UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
    }

    private func confirmationCard(_ place: IstanbulPlace) -> some View {
        HStack(alignment: .center, spacing: 14) {
            LandmarkTile(placeID: place.id)
                .frame(width: 88, height: 100)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(place.name).font(.subheadline.weight(.bold)).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)

                }
                Text("Istanbul").font(.caption).foregroundStyle(.secondary)
                Button {
                    searchFocused = false
                    onConfirm(place.name)
                } label: {
                    Text("Use this place")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .foregroundStyle(.white)
                        .background(IstanbulStyle.coral, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(CityPressStyle(kind: .primary))
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(IstanbulStyle.paper)
        .overlay(alignment: .top) { Divider().opacity(0.4) }
    }

    private func select(_ place: IstanbulPlace) {
        searchFocused = false
        selectedID = place.id
        if !["galata", "eminonu", "hagia", "sultanahmet", "blue"].contains(place.id) { accurateMap = true }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            camera = .region(.init(center: .init(latitude: place.latitude + 0.003, longitude: place.longitude),
                                  span: .init(latitudeDelta: 0.023, longitudeDelta: 0.032)))
        }
    }

    private func fitVisiblePlaces() {
        guard let first = filtered.first else { return }
        let latitude = filtered.map(\.latitude), longitude = filtered.map(\.longitude)
        let south = latitude.min() ?? first.latitude, north = latitude.max() ?? first.latitude
        let west = longitude.min() ?? first.longitude, east = longitude.max() ?? first.longitude
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            camera = .region(.init(center: .init(latitude: (south + north) / 2, longitude: (west + east) / 2),
                                  span: .init(latitudeDelta: max((north - south) * 1.35, 0.018),
                                              longitudeDelta: max((east - west) * 1.35, 0.025))))
        }
    }
}
