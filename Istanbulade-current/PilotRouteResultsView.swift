import SwiftUI
import MapKit

struct PilotRouteResultsView: View {
    let request: PilotRoutingRequest
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = PilotRoutingModel()
    @State private var departure = Date()
    @State private var walkingLimit = 1200
    @State private var retry = UUID()
    @State private var selectedID: String?
    private let coral = IstanbulStyle.coral
    private let teal = IstanbulStyle.teal
    private let cream = IstanbulStyle.cream
    private let ink = IstanbulStyle.ink
    private var selected: PilotOption? { model.plan?.options.first(where: { $0.id == selectedID }) ?? model.plan?.options.first }
    private struct Query: Hashable { let departure: Date; let walkingLimit: Int; let retry: UUID }
    private var query: Query { Query(departure: departure, walkingLimit: walkingLimit, retry: retry) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Label(request.start.name, systemImage: "circle.inset.filled").font(.system(.headline, design: .serif)).foregroundStyle(teal)
                    Divider().padding(.vertical, 4)
                    Label(request.destination.name, systemImage: "mappin.circle.fill").font(.system(.headline, design: .serif)).foregroundStyle(ink)
                    Text(request.start.coordinateText).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
                    .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 10) {
                    DatePicker("Departure · Istanbul time", selection: $departure, displayedComponents: [.date, .hourAndMinute])
                        .font(.caption)
                }
                if model.isLoading {
                    HStack(spacing: 12) {
                        ProgressView().tint(teal)
                        Text("Checking nearby stops and walking connections…").font(.subheadline)
                    }.padding(20).frame(maxWidth: .infinity)
                } else if let error = model.error {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("No verified option", systemImage: "info.circle").font(.headline)
                        Text(error).font(.subheadline)
                        Button("Try again") { retry = UUID() }.buttonStyle(.borderedProminent)
                    }.padding(18).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 18))
                }
                if let plan = model.plan, let selected {
                    routeMap(selected)
                    HStack(spacing: 16) {
                        Label("Walking", systemImage: "figure.walk").foregroundStyle(teal)
                        Text("- - Rail alignment").foregroundStyle(coral)
                    }.font(.caption)
                    Text("Choose your way").font(IstanbulStyle.title(24))
                    Text("Fewer boardings first, then less walking. Fares and total journey times are not calculated.")
                        .font(.caption).foregroundStyle(.secondary)
                    ForEach(plan.options) { option in optionCard(option, selected: selected.id == option.id) }
                    journeySteps(selected)
                    VStack(alignment: .leading, spacing: 10) {
                        Label("About this pilot", systemImage: "info.circle").font(.headline)
                        ForEach(plan.warnings, id: \.self) { Text($0).font(.caption).foregroundStyle(.secondary) }
                        Text(plan.network.attribution).font(.caption2).foregroundStyle(.secondary)
                        ForEach(plan.network.sources, id: \.self) { source in
                            if let url = URL(string: source) {
                                Link("Source · \(url.host ?? "operator")", destination: url).font(.caption)
                            }
                        }
                        if let url = URL(string: plan.network.licenseURL) { Link("Data licence", destination: url).font(.caption) }
                    }.padding(16).background(.white.opacity(0.3), in: RoundedRectangle(cornerRadius: 18))
                }
            }.padding(18)
        }
        .background(cream).foregroundStyle(ink).tint(coral)
        .modifier(IstanbulSurface())
        .environment(\.timeZone, TimeZone(identifier: "Europe/Istanbul")!)
        .navigationTitle("Your route").navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        .task(id: query) { await model.load(request: request, departure: departure, walkingLimit: Double(walkingLimit)) }
        .onDisappear { model.cancel() }
    }

    private func routeMap(_ option: PilotOption) -> some View {
        Map {
            ForEach(Array(option.legs.enumerated()), id: \.offset) { _, leg in
                if leg.isWalking {
                    MapPolyline(coordinates: leg.coordinates.map(\.coordinate)).stroke(teal, lineWidth: 4)
                } else {
                    MapPolyline(coordinates: leg.coordinates.map(\.coordinate))
                        .stroke(coral, style: StrokeStyle(lineWidth: 4, dash: [7, 5]))
                }
            }
            Marker(request.start.name, coordinate: request.start.coordinate).tint(teal)
            Marker(request.destination.name, coordinate: request.destination.coordinate).tint(coral)
            ForEach(Array(option.rides.enumerated()), id: \.offset) { _, ride in
                Annotation("\(ride.line.id) · \(ride.board.name)", coordinate: ride.board.coordinate.coordinate) {
                    Image(systemName: "tram.fill").font(.caption).padding(7)
                        .foregroundStyle(.white).background(coral, in: Circle())
                }
            }
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
        .frame(height: 300).clipShape(RoundedRectangle(cornerRadius: 22))
        .id(option.id)
        .accessibilityLabel("Apple Maps walking paths and indicative archived rail alignment. Not live vehicle positions.")
    }

    private func optionCard(_ option: PilotOption, selected: Bool) -> some View {
        Button { selectedID = option.id } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label(option.title, systemImage: option.rides.isEmpty ? "figure.walk" : "tram.fill").font(.system(.headline, design: .serif))
                    Spacer()
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle").foregroundStyle(coral)
                }
                HStack {
                    Text("\(Int(option.walkingMeters.rounded())) m walking")
                    Spacer()
                    Text(option.rides.isEmpty ? "₺0 transit fare" : "Fare pending")
                }.font(.caption)
                Text("~\(Int(ceil(option.walkingSeconds / 60))) min walking · \(option.rides.count) boarding(s)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .foregroundStyle(ink).padding(16).background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected ? coral : .clear, lineWidth: 1.5))
            .shadow(color: ink.opacity(0.04), radius: 8, y: 4)
        }
        .buttonStyle(CityPressStyle()).accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func journeySteps(_ option: PilotOption) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your journey").font(IstanbulStyle.title(23))
            ForEach(Array(option.legs.enumerated()), id: \.offset) { index, leg in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)").font(.caption.bold())
                        .frame(width: 28, height: 28).foregroundStyle(.white).background(coral, in: Circle())
                    VStack(alignment: .leading, spacing: 6) {
                        switch leg {
                        case .walk(let from, let to, let path):
                            Text("Walk: \(from) → \(to)").font(.subheadline.bold())
                            Text("\(Int(path.distanceMeters.rounded())) m · ~\(Int(ceil(path.expectedSeconds / 60))) min").font(.caption)
                            if !path.instructions.isEmpty {
                                DisclosureGroup("Walking instructions") {
                                    ForEach(Array(path.instructions.enumerated()), id: \.offset) { _, instruction in
                                        Text(instruction).font(.caption).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 3)
                                    }
                                }.font(.caption)
                            }
                        case .ride(let ride):
                            Text("\(ride.line.id) toward \(ride.direction)").font(.subheadline.bold())
                            Text("\(ride.board.name) → \(ride.alight.name) · \(ride.stops.count - 1) stop(s)").font(.caption)
                            DisclosureGroup("Stops") {
                                ForEach(ride.stops) { Text($0.name).font(.caption).frame(maxWidth: .infinity, alignment: .leading) }
                            }.font(.caption)
                            Text("Normal hours 06:00–00:00 · check departures").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }.padding(18).background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 22))
    }
}
