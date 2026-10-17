import SwiftUI
import MapKit

/// Decorative map matches the design board; accurate coordinates remain in Apple Maps.
struct IllustratedDestinationMap: View {
    let selectedID: String
    let onSelect: (IstanbulPlace) -> Void
    private let anchors: [(String, CGFloat, CGFloat)] = [
        ("galata", 0.55, 0.10), ("eminonu", 0.33, 0.29),
        ("hagia", 0.60, 0.55), ("sultanahmet", 0.51, 0.64), ("blue", 0.47, 0.76)
    ]
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("DestinationMap").resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                ForEach(anchors, id: \.0) { anchor in
                    if let place = PlaceCatalog.places.first(where: { $0.id == anchor.0 }) {
                        Button { onSelect(place) } label: {
                            VStack(spacing: 1) {
                                if selectedID == place.id { CoralMapPin() }
                                else {
                                    Circle().fill(IstanbulStyle.paper).frame(width: 16, height: 16)
                                        .overlay(Circle().stroke(IstanbulStyle.teal, lineWidth: 3))
                                }
                                if selectedID == place.id {
                                    Text(place.name.uppercased()).font(.system(size: 9, weight: .bold))
                                        .padding(4).background(IstanbulStyle.paper.opacity(0.9), in: Capsule())
                                }
                            }.frame(minWidth: 44, minHeight: 44)
                        }
                        .position(x: geometry.size.width * anchor.1, y: geometry.size.height * anchor.2)
                        .accessibilityLabel("Select \(place.name)")
                    }
                }
            }.clipped()
        }
    }
}

struct ReferenceRouteOptionsView: View {
    let request: PilotRoutingRequest
    @Environment(\.dismiss) private var dismiss
    @State private var sort: Ranking = .cheapest
    @State private var detail: SampleOption?
    @State private var showingLive = false
    private enum Ranking: String, CaseIterable { case cheapest = "Cheapest", fastest = "Fastest", changes = "Fewer changes" }
    private struct SampleOption: Identifiable {
        let id: Int
        let title: String
        let fare: String
        let minutes: Int
        let changes: Int
        let symbol: String
        let line: String
    }
    private let samples = [
        SampleOption(id: 0, title: "Walk + Tram", fare: "₺X", minutes: 32, changes: 0, symbol: "figure.walk", line: "T1"),
        SampleOption(id: 1, title: "Metro + Tram", fare: "₺Y", minutes: 27, changes: 1, symbol: "m.circle.fill", line: "T1"),
        SampleOption(id: 2, title: "Taxi", fare: "₺Z", minutes: 20, changes: 0, symbol: "car.fill", line: "")
    ]
    private var ordered: [SampleOption] {
        samples.sorted {
            switch sort {
            case .cheapest: return $0.id < $1.id
            case .fastest: return $0.minutes < $1.minutes
            case .changes: return $0.changes == $1.changes ? $0.id < $1.id : $0.changes < $1.changes
            }
        }
    }
    private var isReferenceJourney: Bool {
        request.start.curatedName == "Galata Tower" && request.destination.id == "sultanahmet"
    }
    var body: some View {
        Group {
            if isReferenceJourney { comparison }
            else { PilotRouteResultsView(request: request) }
        }
    }
    private var comparison: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Label("Galata", systemImage: "circle.fill").font(.subheadline)
                    Spacer()
                    Image(systemName: "arrow.right").foregroundStyle(.secondary)
                    Spacer()
                    Label("Sultanahmet", systemImage: "mappin.circle.fill").font(.subheadline)
                }
                .padding(13).background(IstanbulStyle.ink.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
                Label("Sample estimates · design preview", systemImage: "info.circle")
                    .font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10).background(IstanbulStyle.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                HStack(spacing: 7) {
                    ForEach(Ranking.allCases, id: \.self) { ranking in
                        Button { sort = ranking } label: {
                            Text(ranking.rawValue).font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(sort == ranking ? IstanbulStyle.coral : IstanbulStyle.ink.opacity(0.055), in: Capsule())
                                .foregroundStyle(sort == ranking ? .white : IstanbulStyle.ink)
                        }.accessibilityAddTraits(sort == ranking ? [.isSelected] : [])
                    }
                }
                ForEach(ordered) { option in
                    Button { detail = option } label: { optionCard(option) }
                        .buttonStyle(CityPressStyle())
                }
                Label("Illustrative fares and times. Not live routes.", systemImage: "info.circle.fill")
                    .font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12).background(IstanbulStyle.teal.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                Button("Calculate available pilot routes") { showingLive = true }
                    .font(.subheadline.bold()).padding(.vertical, 12)
            }.padding(16)
        }
        .navigationTitle("Your options").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarLeading) {
            Button { dismiss() } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                .accessibilityLabel("Back")
        } }
        .modifier(IstanbulSurface())
        .navigationDestination(isPresented: $showingLive) { PilotRouteResultsView(request: request) }
        .sheet(item: $detail) { option in
            NavigationStack {
                VStack(alignment: .leading, spacing: 18) {
                    Text(option.title).font(IstanbulStyle.title(28))
                    Text("Design example only").font(.headline).foregroundStyle(IstanbulStyle.coral)
                    Text("The reference card uses placeholder fares and sample journey times. Metro + Tram and Taxi are visual examples, not computed routes. Use the pilot planner for available walking and rail connections.")
                    Button("Calculate available pilot routes") { detail = nil; showingLive = true }
                        .buttonStyle(.borderedProminent)
                    Spacer()
                }.padding(24).modifier(IstanbulSurface())
                    .toolbar { Button("Done") { detail = nil } }
            }.presentationDetents([.medium, .large])
        }
    }
    private func optionCard(_ option: SampleOption) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            if option.id == 0 {
                Text("LOWEST COST · SAMPLE").font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white).padding(.horizontal, 7).padding(.vertical, 4)
                    .background(Color(red: 0.29, green: 0.54, blue: 0.45), in: RoundedRectangle(cornerRadius: 4))
            }
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(option.title).font(.headline)
                    HStack(spacing: 8) {
                        Image(systemName: option.symbol).font(.title3)
                        if !option.line.isEmpty {
                            Text("·····").font(.headline)
                            Image(systemName: "tram.fill")
                            Text(option.line).font(.caption.bold()).padding(.horizontal, 5).padding(.vertical, 2)
                                .foregroundStyle(.white).background(Color.blue.opacity(0.7), in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                Spacer()
                Text(option.fare).font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(IstanbulStyle.coral).padding(.horizontal, 16).padding(.vertical, 7)
                    .background(IstanbulStyle.coral.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }
            HStack {
                Text(option.id == 2 ? "20–35 min · Traffic dependent" : "\(option.minutes) min · \(option.changes == 0 ? "1 ride" : "1 change")")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("View route ›").font(.caption.bold())
            }
        }
        .foregroundStyle(IstanbulStyle.ink).padding(14)
        .background(IstanbulStyle.paper, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(IstanbulStyle.ink.opacity(0.12)))
    }
}

