import SwiftUI
import MapKit

enum DistrictCatalog {
    static let names = ["Adalar", "Arnavutköy", "Ataşehir", "Avcılar", "Bağcılar", "Bahçelievler", "Bakırköy", "Başakşehir", "Bayrampaşa", "Beşiktaş", "Beykoz", "Beylikdüzü", "Beyoğlu", "Büyükçekmece", "Çatalca", "Çekmeköy", "Esenler", "Esenyurt", "Eyüpsultan", "Fatih", "Gaziosmanpaşa", "Güngören", "Kadıköy", "Kağıthane", "Kartal", "Küçükçekmece", "Maltepe", "Pendik", "Sancaktepe", "Sarıyer", "Silivri", "Sultanbeyli", "Sultangazi", "Şile", "Şişli", "Tuzla", "Ümraniye", "Üsküdar", "Zeytinburnu"]
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @State private var selected = ""
    @State private var network: DistrictNetwork?
    @State private var error: String?
    @State private var camera: MapCameraPosition = .region(.init(center: .init(latitude: 41.025, longitude: 29.0), span: .init(latitudeDelta: 0.12, longitudeDelta: 0.16)))
    private var matches: [DistrictNetwork.District] { (network?.districts ?? []).filter { query.isEmpty || $0.name.localizedStandardContains(query) }.sorted { $0.name < $1.name } }
    private var choice: DistrictNetwork.District? { network?.districts.first { $0.name == selected } }
    private var unavailable: [String] { DistrictCatalog.names.filter { name in
        !(network?.districts.contains { $0.name == name } ?? false) && (query.isEmpty || name.localizedStandardContains(query))
    } }

    var body: some View {
        GeometryReader { size in
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search a district", text: $query).font(.subheadline).autocorrectionDisabled()
                    if !query.isEmpty { Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Clear search") }
                }.padding(12).background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(IstanbulStyle.ink.opacity(0.10)))
                    .padding(.horizontal, 14).padding(.bottom, 10)
                Map(position: $camera) {
                    ForEach(matches) { district in
                        Annotation(district.name, coordinate: district.point.coordinate, anchor: .bottom) {
                            Button { choose(district) } label: {
                                VStack(spacing: 2) {
                                    if selected == district.name { CoralMapPin() }
                                    else { LandmarkArtwork(placeID: district.artwork).frame(width: 38, height: 44) }
                                    Text(district.name).font(.system(size: 9, weight: .bold))
                                        .padding(4).background(IstanbulStyle.cream.opacity(0.96), in: Capsule())
                                }
                            }.buttonStyle(CityPressStyle()).accessibilityLabel("Select \(district.name)")
                        }
                    }
                }
                .annotationTitles(.hidden)
                .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
                .frame(height: max(160, min(320, size.size.height * 0.43)))
                .overlay(alignment: .bottomTrailing) {
                    Button { fitAll() } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right").padding(13)
                            .background(IstanbulStyle.paper, in: Circle())
                    }.padding(12).accessibilityLabel("Show district reference points")
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Districts").font(IstanbulStyle.title(20)).padding(.horizontal, 16).padding(.top, 14)
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if let error { Text(error).font(.caption).padding() }
                            ForEach(matches) { district in
                                Button { choose(district) } label: {
                                    HStack(spacing: 10) {
                                        CityArtwork(tile: district.name == "Beyoğlu" ? 2 : district.name == "Fatih" ? 1 : 3)
                                            .frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(district.name).font(.system(.subheadline, design: .serif).bold())
                                            Text(referenceName(district)).font(.caption2).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: selected == district.name ? "largecircle.fill.circle" : "circle").foregroundStyle(IstanbulStyle.teal)
                                    }.padding(.horizontal, 16).padding(.vertical, 9).contentShape(Rectangle())
                                }.buttonStyle(CityPressStyle())
                                Divider().padding(.leading, 70)
                            }
                            if !unavailable.isEmpty {
                                Text("More districts coming soon").font(.caption.bold()).frame(maxWidth: .infinity, alignment: .leading).padding(16)
                                ForEach(unavailable, id: \.self) { name in
                                    HStack { Text(name); Spacer(); Text("Not covered yet").foregroundStyle(.secondary) }.font(.caption).padding(.horizontal, 16).padding(.vertical, 9)
                                }
                            }
                            if matches.isEmpty && unavailable.isEmpty { ContentUnavailableView.search(text: query) }
                        }
                    }.scrollDismissesKeyboard(.interactively)
                    if let choice {
                        HStack(spacing: 10) {
                            CityArtwork(tile: choice.name == "Beyoğlu" ? 2 : choice.name == "Fatih" ? 1 : 3)
                                .frame(width: 52, height: 58).clipShape(RoundedRectangle(cornerRadius: 9))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(choice.name).font(.system(.subheadline, design: .serif).bold())
                                Text(referenceName(choice)).font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }.padding(.horizontal, 14).padding(.top, 8)
                        Button("Use this district") { onSelect(choice.name) }
                            .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(IstanbulStyle.coral, in: RoundedRectangle(cornerRadius: 10))
                            .buttonStyle(CityPressStyle(kind: .primary)).padding(12)
                    }
                }.background(IstanbulStyle.cream, in: UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                    .padding(.top, -12)
            }
        }
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar).modifier(IstanbulSurface())
        .onAppear {
            do {
                let loaded = try DistrictNetwork.load(); network = loaded
                if let first = loaded.districts.first(where: { $0.name == current }) ?? loaded.districts.first { choose(first) }
            } catch { self.error = error.localizedDescription }
        }
    }
    private func referenceName(_ district: DistrictNetwork.District) -> String {
        guard let id = district.stationIDs.first, let network else { return "District reference" }
        let parts = id.split(separator: ":")
        guard parts.count == 2, let index = Int(parts[1]), let line = network.lines.first(where: { $0.id == String(parts[0]) }), line.stops.indices.contains(index) else { return "District reference" }
        return line.stops[index] + " · reference station"
    }
    private func choose(_ district: DistrictNetwork.District) {
        selected = district.name
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            camera = .region(.init(center: district.point.coordinate, span: .init(latitudeDelta: 0.06, longitudeDelta: 0.08)))
        }
    }
    private func fitAll() {
        guard !matches.isEmpty else { return }
        let lat = matches.map(\.latitude), lon = matches.map(\.longitude)
        camera = .region(.init(center: .init(latitude: (lat.min()! + lat.max()!) / 2, longitude: (lon.min()! + lon.max()!) / 2), span: .init(latitudeDelta: max(0.06, (lat.max()! - lat.min()!) * 1.3), longitudeDelta: max(0.08, (lon.max()! - lon.min()!) * 1.3))))
    }
}

struct DistrictJourneyView: View {
    let journey: DistrictJourney
    @Environment(\.dismiss) private var dismiss
    @State private var network: DistrictNetwork?
    @State private var route: DistrictNetwork.Route?
    @State private var error: String?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(spacing: 8) {
                    endpoint("From", journey.from, color: IstanbulStyle.teal)
                    endpoint("To", journey.to, color: IstanbulStyle.coral)
                }
                if let route {
                    Map {
                        ForEach(route.rides) { ride in
                            if ride.mapPoints.count >= 2 {
                                MapPolyline(coordinates: ride.mapPoints.map(\.coordinate))
                                    .stroke(ride.line == "B1" ? IstanbulStyle.teal : IstanbulStyle.coral, style: StrokeStyle(lineWidth: 4, dash: [6, 5]))
                            }
                        }
                        Marker(route.from.name, coordinate: route.from.point.coordinate).tint(IstanbulStyle.teal)
                        Marker(route.to.name, coordinate: route.to.point.coordinate).tint(IstanbulStyle.coral)
                    }.mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
                        .frame(height: 240).clipShape(RoundedRectangle(cornerRadius: 18))
                    Text("Dashed lines are schematic connections between reference points, not actual tracks or walking paths. Train stops are listed below.").font(.caption2).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            ForEach(route.rides) { ride in badge(ride.line) }
                            Spacer()
                            Text(route.transfers == 0 ? "Direct" : "\(route.transfers) transfer(s)").font(.caption)
                        }
                        Text("\(journey.from) → \(journey.to)").font(IstanbulStyle.title(20))
                        Text("\(route.stopCount) station hops · fare and journey time unavailable").font(.caption).foregroundStyle(.secondary)
                    }.padding(16).background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 18))
                    Text("Your journey").font(IstanbulStyle.title(23))
                    ForEach(Array(route.rides.enumerated()), id: \.offset) { index, ride in
                        VStack(alignment: .leading, spacing: 9) {
                            HStack { badge(ride.line); Text("Toward \(ride.direction)").font(.subheadline.bold()) }
                            Text("\(ride.stops.first ?? "") → \(ride.stops.last ?? "")").font(.system(.headline, design: .serif))
                            Text("\(ride.stops.count - 1) station hops").font(.caption).foregroundStyle(.secondary)
                            DisclosureGroup("All stops") {
                                ForEach(Array(ride.stops.enumerated()), id: \.offset) { _, stop in
                                    HStack { Circle().fill(IstanbulStyle.coral).frame(width: 7, height: 7); Text(stop).font(.caption); Spacer() }.padding(.vertical, 4)
                                }
                            }.font(.caption)
                            if index < route.rides.count - 1 {
                                Label("Change at \(ride.stops.last ?? "") to \(route.rides[index + 1].line). Follow station interchange signs.", systemImage: "arrow.triangle.swap")
                                    .font(.caption).foregroundStyle(IstanbulStyle.teal)
                            }
                        }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
                            .background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 16))
                    }
                    Label("Uses reference stations, not your current location. Station access and interchange walking are not measured.", systemImage: "info.circle").font(.caption).foregroundStyle(.secondary)
                    Text("Static rail connections: fewer transfers first, then fewer stops within this network. Timetables, service disruptions, fares and cheapest-route ranking are not included.").font(.caption).foregroundStyle(.secondary)
                    if let network {
                        DisclosureGroup("Data sources · checked \(network.checkedOn)") {
                            ForEach(network.sources, id: \.self) { source in
                                if let url = URL(string: source) { Link(url.host ?? "Source", destination: url).font(.caption).padding(.vertical, 4) }
                            }
                        }.font(.caption)
                    }
                } else if let error {
                    ContentUnavailableView("Route unavailable", systemImage: "tram", description: Text(error))
                } else { ProgressView("Finding connections…") }
            }.padding(14)
        }
        .navigationTitle("Your route").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        .modifier(IstanbulSurface())
        .task {
            do {
                let loaded = try DistrictNetwork.load(); network = loaded
                route = loaded.route(from: journey.from, to: journey.to)
                if route == nil { error = "This district pair is not covered by the bundled rail network yet. Choose another district. No external navigation will open." }
            } catch { self.error = error.localizedDescription }
        }
    }
    private func badge(_ line: String) -> some View {
        Text(line == "B1" ? "Marmaray" : line).font(.caption.bold()).foregroundStyle(.white)
            .padding(.horizontal, 9).padding(.vertical, 5).background(line == "B1" ? IstanbulStyle.teal : IstanbulStyle.coral, in: RoundedRectangle(cornerRadius: 6))
    }
    private func endpoint(_ label: String, _ name: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.circle.fill").font(.title3).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) { Text(label).font(.caption2).foregroundStyle(.secondary); Text(name).font(.system(.subheadline, design: .serif).bold()) }
            Spacer()
        }.padding(11).background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 12))
    }
}
