import SwiftUI
import MapKit

enum DistrictCatalog {
    static let names = ["Adalar", "Arnavutköy", "Ataşehir", "Avcılar", "Bağcılar", "Bahçelievler", "Bakırköy", "Başakşehir", "Bayrampaşa", "Beşiktaş", "Beykoz", "Beylikdüzü", "Beyoğlu", "Büyükçekmece", "Çatalca", "Çekmeköy", "Esenler", "Esenyurt", "Eyüpsultan", "Fatih", "Gaziosmanpaşa", "Güngören", "Kadıköy", "Kağıthane", "Kartal", "Küçükçekmece", "Maltepe", "Pendik", "Sancaktepe", "Sarıyer", "Silivri", "Sultanbeyli", "Sultangazi", "Şile", "Şişli", "Tuzla", "Ümraniye", "Üsküdar", "Zeytinburnu"]
    static func artwork(_ name: String) -> String {
        switch name { case "Beyoğlu": return "galata"; case "Fatih": return "sultanahmet"; default: return "ferry" }
    }
}

struct DistrictJourney: Identifiable {
    let id = UUID()
    let from: String
    let to: String
}

struct DistrictPickerView: View {
    let title: String
    let current: String
    let onSelect: (String) -> Void
    @State private var query = ""
    private var matches: [String] { DistrictCatalog.names.filter { query.isEmpty || $0.localizedStandardContains(query) } }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                Text("Istanbul districts").font(IstanbulStyle.title(23)).padding(.vertical, 8)
                ForEach(matches, id: \.self) { name in
                    Button { onSelect(name) } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "mappin.circle.fill").font(.title2).foregroundStyle(IstanbulStyle.teal)
                            Text(name).font(.system(.headline, design: .serif))
                            Spacer()
                            Image(systemName: current == name ? "largecircle.fill.circle" : "circle").foregroundStyle(IstanbulStyle.teal)
                        }.padding(16).foregroundStyle(IstanbulStyle.ink)
                            .background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 16))
                    }.buttonStyle(CityPressStyle())
                }
                if matches.isEmpty { ContentUnavailableView.search(text: query) }
            }.padding(16)
        }
        .searchable(text: $query, prompt: "Search a district")
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .modifier(IstanbulSurface())
    }
}

struct DistrictJourneyView: View {
    let journey: DistrictJourney
    @Environment(\.dismiss) private var dismiss
    @State private var opening = false
    @State private var error: String?
    private var pilotRequest: PilotRoutingRequest? {
        let forward = journey.from == "Beyoğlu" && journey.to == "Fatih"
        let reverse = journey.from == "Fatih" && journey.to == "Beyoğlu"
        guard forward || reverse,
              let start = PlaceCatalog.places.first(where: { $0.id == (forward ? "galata" : "sultanahmet") }),
              let end = PlaceCatalog.places.first(where: { $0.id == (forward ? "sultanahmet" : "galata") }) else { return nil }
        return PilotRoutingRequest(start: .landmark(start), destination: end)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your journey").font(IstanbulStyle.title(28))
                HStack(spacing: 16) {
                    LandmarkTile(placeID: DistrictCatalog.artwork(journey.from)).frame(width: 70, height: 90)
                    VStack(alignment: .leading, spacing: 12) {
                        Label(journey.from, systemImage: "circle.inset.filled").foregroundStyle(IstanbulStyle.teal)
                        Label(journey.to, systemImage: "mappin.circle.fill")
                    }.font(.system(.headline, design: .serif))
                }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
                    .background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 22))
                Text("District to district").font(IstanbulStyle.title(22))
                if let request = pilotRequest {
                    NavigationLink {
                        PilotRouteResultsView(request: request)
                    } label: {
                        Label("View Galata ↔ Sultanahmet pilot", systemImage: "tram.fill")
                            .font(.subheadline.bold()).padding(16).frame(maxWidth: .infinity)
                            .background(IstanbulStyle.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 15))
                    }
                    Text("This limited in-app route represents Beyoğlu by Galata and Fatih by Sultanahmet; it does not cover every neighbourhood.").font(.caption).foregroundStyle(.secondary)
                }
                Text("For now, directions use a reference location in each district. They do not start at your current location.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Button { Task { await openDirections() } } label: {
                    HStack {
                        if opening { ProgressView().tint(.white) }
                        Label(opening ? "Finding districts…" : "See transit directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    }.font(.subheadline.bold()).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(IstanbulStyle.coral, in: RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(CityPressStyle(kind: .primary)).disabled(opening)
                Text("Opens Apple Maps. Available transport options depend on its coverage. In-app district routes and fare comparison are not available yet.")
                    .font(.caption).foregroundStyle(.secondary)
                if let error { Text(error).font(.subheadline).foregroundStyle(.red) }
            }.padding(20)
        }
        .navigationTitle("Your route").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        .modifier(IstanbulSurface())
    }

    @MainActor private func openDirections() async {
        opening = true; error = nil
        defer { opening = false }
        do {
            let start = try await reference(journey.from)
            let end = try await reference(journey.to)
            let opened = MKMapItem.openMaps(with: [start, end], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit])
            if !opened { error = "Apple Maps could not be opened. Please try again." }
        } catch { self.error = "District locations could not be retrieved. Check your connection and try again." }
    }

    @MainActor private func reference(_ name: String) async throws -> MKMapItem {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(name), İstanbul, Türkiye"
        request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.01, longitude: 28.98), span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 2))
        let response = try await MKLocalSearch(request: request).start()
        guard let item = response.mapItems.first(where: {
            $0.placemark.isoCountryCode == "TR" &&
            [$0.name, $0.placemark.subAdministrativeArea, $0.placemark.locality].compactMap { $0 }.contains(where: { $0.localizedStandardContains(name) })
        }) else { throw PilotRoutingError.noOptions("District reference unavailable") }
        return item
    }
}
