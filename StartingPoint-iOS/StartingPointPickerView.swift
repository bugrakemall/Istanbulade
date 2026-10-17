import SwiftUI
import MapKit
import UIKit

struct StartingPointPickerView: View {
    let current: StartingPoint
    let onConfirm: (StartingPoint) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var search = StartingPointSearch()
    @StateObject private var locator = StartingPointLocator()
    @State private var query = ""
    @FocusState private var searchFocused: Bool
    @State private var selected: StartingPoint?
    @State private var camera: MapCameraPosition = .region(.init(
        center: .init(latitude: 41.0256, longitude: 28.9744),
        span: .init(latitudeDelta: 0.025, longitudeDelta: 0.036)))
    @State private var visibleRegion = MKCoordinateRegion(
        center: .init(latitude: 41.0256, longitude: 28.9744),
        span: .init(latitudeDelta: 0.025, longitudeDelta: 0.036))
    private let coral = Color(red: 0.86, green: 0.43, blue: 0.34)
    private let ink = Color(red: 0.08, green: 0.18, blue: 0.23)
    private let cream = Color(red: 0.93, green: 0.91, blue: 0.87)

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search a street, hotel or address", text: $query)
                        .font(.subheadline).autocorrectionDisabled()
                        .focused($searchFocused)
                    if !query.isEmpty {
                        Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
                            .accessibilityLabel("Clear address search")
                    }
                }
                .padding(12).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                if !searchFocused {
                  Button {
                    locator.request()
                } label: {
                    HStack(spacing: 10) {
                        if locator.isLoading { ProgressView().tint(ink) }
                        else { Image(systemName: "location.fill") }
                        Text(locator.isLoading ? "Finding your location…" : "Use my location").font(.subheadline.bold())
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .padding(13).background(Color(red: 0.75, green: 0.86, blue: 0.85), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(CityPressStyle()).disabled(locator.isLoading)
                if let error = locator.error {
                    Text(error).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                    if locator.canOpenSettings, let url = URL(string: UIApplication.openSettingsURLString) {
                        Link("Open Settings", destination: url).font(.caption.bold())
                    }
                }
                }
            }.padding(.horizontal, 16).padding(.vertical, 10)

            MapReader { proxy in
                Map(position: $camera) {
                    if let selected {
                        Annotation(selected.name, coordinate: selected.coordinate, anchor: .bottom) {
                            CoralMapPin().accessibilityLabel("Selected starting point: \(selected.name)")
                        }
                    }
                }
                .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
                .onMapCameraChange(frequency: .onEnd) { visibleRegion = $0.region }
                .onTapGesture { point in
                    guard let coordinate = proxy.convert(point, from: .local) else { return }
                    pickMapPoint(coordinate)
                }
                .overlay(alignment: .topLeading) {
                    Text("Tap anywhere to drop a pin")
                        .font(.caption.weight(.medium)).padding(9)
                        .background(cream.opacity(0.95), in: Capsule()).padding(10)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .bottomTrailing) {
                    // Accessible alternative to tapping an exact point on the map.
                    Button { pickMapPoint(visibleRegion.center) } label: {
                        Label("Use map centre", systemImage: "scope")
                            .font(.caption.bold()).padding(10)
                            .background(cream, in: Capsule())
                    }
                    .buttonStyle(CityPressStyle()).padding(12)
                }
            }
            .frame(height: searchFocused ? 130 : 245)
            .accessibilityHint("Pan the map, then activate Use map centre to select a starting point.")

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 {
                        HStack {
                            Text("Address results").font(.headline)
                            Spacer()
                            if search.isLoading { ProgressView() }
                        }
                        if let error = search.error { Text(error).font(.caption).foregroundStyle(.secondary) }
                        else if search.results.isEmpty && !search.isLoading {
                            Text("No results yet. Try a more complete address or choose a point on the map.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        ForEach(Array(search.results.enumerated()), id: \.offset) { _, item in
                            Button {
                                let coordinate = item.placemark.coordinate
                                select(StartingPoint(name: item.name ?? "Selected address",
                                                     subtitle: item.placemark.title ?? "Apple Maps result",
                                                     latitude: coordinate.latitude, longitude: coordinate.longitude, source: .address))
                            } label: {
                                resultRow(title: item.name ?? "Selected address", subtitle: item.placemark.title ?? "", symbol: "mappin.and.ellipse")
                            }.buttonStyle(CityPressStyle())
                        }
                    } else {
                        Text("Or start from a landmark").font(.headline)
                        ForEach(PlaceCatalog.places.filter { RouteCatalog.origins.contains($0.name) }) { place in
                            Button { select(.landmark(place)) } label: {
                                resultRow(title: place.name, subtitle: place.area, symbol: place.symbol)
                            }.buttonStyle(CityPressStyle())
                        }
                    }
                }.padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            if let selected, !searchFocused {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: selected.source == .device ? "location.fill" : "mappin.circle.fill").foregroundStyle(coral)
                        Text(selected.name).font(.subheadline.bold()).lineLimit(2)
                    }
                    Text(selected.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    Text(selected.coordinateText).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    Button("Use this starting point") { onConfirm(selected) }
                        .font(.subheadline.bold()).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(coral, in: RoundedRectangle(cornerRadius: 13))
                        .buttonStyle(CityPressStyle(kind: .primary))
                }
                .padding(14).background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 12).padding(.bottom, 10)
            }
        }
        .background(cream).foregroundStyle(ink).tint(coral)
        .navigationTitle("Starting point").navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .task(id: query) { await search.lookup(query) }
        .onAppear { if selected == nil { select(current) } }
        .onChange(of: locator.fix) { _, fix in if let fix { select(fix) } }
        .onDisappear { search.cancel(); locator.cancel() }
    }

    private func select(_ point: StartingPoint) {
        guard point.isValid else { return }
        // A newer manual choice must win over a pending GPS response.
        locator.cancel()
        searchFocused = false
        selected = point
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.4)) {
            camera = .region(.init(center: point.coordinate, span: .init(latitudeDelta: 0.016, longitudeDelta: 0.024)))
        }
    }
    private func pickMapPoint(_ coordinate: CLLocationCoordinate2D) {
        select(StartingPoint(name: "Pinned location", subtitle: "Point selected on the map",
                             latitude: coordinate.latitude, longitude: coordinate.longitude, source: .mapPin))
    }
    private func resultRow(title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).foregroundStyle(coral).frame(width: 26)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold()).lineLimit(2)
                Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption)
        }
        .foregroundStyle(ink).padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.4), in: RoundedRectangle(cornerRadius: 14))
    }
}
