import SwiftUI
import MapKit

struct DestinationPickerView: View {
    let selectingOrigin: Bool
    let currentName: String
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @State private var selectedID = "sultanahmet"
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: .init(latitude: 41.016, longitude: 28.991),
        span: .init(latitudeDelta: 0.055, longitudeDelta: 0.075)))
    private let coral = Color(red: 0.86, green: 0.43, blue: 0.34)
    private let cream = Color(red: 0.93, green: 0.91, blue: 0.87)
    private var places: [IstanbulPlace] {
        PlaceCatalog.places.filter { !selectingOrigin || RouteCatalog.origins.contains($0.name) }
    }
    private var filtered: [IstanbulPlace] {
        places.filter { query.isEmpty || "\($0.name) \($0.area)".localizedCaseInsensitiveContains(query) }
    }
    private var selected: IstanbulPlace? { places.first { $0.id == selectedID } }
    private var mapPlaces: [IstanbulPlace] {
        // Declutter only the closest markers; all results remain selectable in the list.
        guard let selected else { return filtered }
        return filtered.filter {
            $0.id == selectedID || hypot($0.latitude - selected.latitude, ($0.longitude - selected.longitude) * 0.75) > 0.002
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search a place or neighbourhood", text: $query)
                    .font(.subheadline).autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
                        .accessibilityLabel("Clear search")
                }
            }
            .padding(12).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16).padding(.vertical, 10)
            Map(position: $camera) {
                ForEach(mapPlaces) { place in
                    Annotation(place.name, coordinate: place.coordinate, anchor: .bottom) {
                        Button { select(place) } label: {
                            ZStack(alignment: .bottom) {
                                if selectedID == place.id {
                                    CoralMapPin()
                                } else {
                                    LandmarkArtwork(placeID: place.id)
                                        .frame(width: 54, height: 62)
                                        .shadow(color: .black.opacity(0.12), radius: 1, y: 2)
                                }
                            }
                            .frame(width: 58, height: 66, alignment: .bottom)
                            .overlay(alignment: .bottom) {
                                if selectedID == place.id {
                                    Text(place.name.uppercased())
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.38))
                                        .fixedSize()
                                        .padding(.horizontal, 4).padding(.vertical, 2)
                                        .background(cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 3))
                                        .offset(y: 19)
                                }
                            }
                        }
                        .buttonStyle(CityPressStyle())
                        .accessibilityLabel("Select \(place.name)")
                    }
                }
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: 41.012, longitude: 29.000)) {
                    LandmarkArtwork(placeID: "ferry").frame(width: 58, height: 44)
                        .allowsHitTesting(false).accessibilityHidden(true)
                }
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: 41.028, longitude: 28.961)) {
                    LandmarkArtwork(placeID: "ferry").frame(width: 48, height: 38)
                        .allowsHitTesting(false).accessibilityHidden(true)
                }
            }
            .annotationTitles(.hidden)
            .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
            .frame(height: 270)
            .overlay(alignment: .topTrailing) {
                Button { fitVisiblePlaces() } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .padding(12).background(cream, in: Circle())
                }
                .padding(12).accessibilityLabel("Show all matching places")
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Places").font(.system(size: 18, weight: .bold)).padding(.horizontal, 16).padding(.top, 16)
                List(filtered) { place in
                    Button { select(place) } label: {
                        HStack(spacing: 12) {
                            Image(systemName: place.symbol).foregroundStyle(coral).frame(width: 25)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.name).font(.subheadline.bold())
                                Text(place.area).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: selectedID == place.id ? "checkmark.circle.fill" : "chevron.right")
                                .foregroundStyle(selectedID == place.id ? coral : .gray)
                        }
                        .foregroundStyle(Color(red: 0.08, green: 0.18, blue: 0.23))
                    }
                    .listRowBackground(selectedID == place.id ? coral.opacity(0.09) : .clear)
                }
                .listStyle(.plain).scrollContentBackground(.hidden)
                .overlay { if filtered.isEmpty { ContentUnavailableView.search(text: query) } }
            }
            if let selected {
                HStack(spacing: 12) {
                    LandmarkArtwork(placeID: selected.id)
                        .frame(width: 80, height: 92)
                        .background(Color(red: 0.70, green: 0.83, blue: 0.82), in: RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(selected.name).font(.subheadline.bold())
                        Text(selected.area).font(.caption).foregroundStyle(.secondary)
                        Button("Use this place") { onConfirm(selected.name) }
                            .font(.subheadline.bold()).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(coral, in: RoundedRectangle(cornerRadius: 12))
                            .buttonStyle(CityPressStyle(kind: .primary))
                    }
                }
                .padding(14).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 12)
            }
            Text("Approximate landmark centres · map requires internet")
                .font(.system(size: 10)).foregroundStyle(.secondary).padding(8)
        }
        .background(cream)
        .navigationTitle(selectingOrigin ? "Starting point" : "Choose destination")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            if let place = places.first(where: { $0.name == currentName }) ?? places.first {
                select(place)
            }
        }
        .onChange(of: query) { _, _ in
            if !filtered.contains(where: { $0.id == selectedID }) { selectedID = filtered.first?.id ?? "" }
            fitVisiblePlaces()
        }
    }

    private func select(_ place: IstanbulPlace) {
        selectedID = place.id
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.4)) {
            camera = .region(.init(center: .init(latitude: place.latitude + 0.002, longitude: place.longitude + 0.004),
                                  span: .init(latitudeDelta: 0.025, longitudeDelta: 0.036)))
        }
    }
    private func fitVisiblePlaces() {
        guard !filtered.isEmpty else { return }
        let latitudes = filtered.map(\.latitude), longitudes = filtered.map(\.longitude)
        let lowLat = latitudes.min()!, highLat = latitudes.max()!, lowLon = longitudes.min()!, highLon = longitudes.max()!
        camera = .region(.init(center: .init(latitude: (lowLat + highLat) / 2, longitude: (lowLon + highLon) / 2),
                              span: .init(latitudeDelta: max((highLat - lowLat) * 1.3, 0.012), longitudeDelta: max((highLon - lowLon) * 1.3, 0.02))))
    }
}
