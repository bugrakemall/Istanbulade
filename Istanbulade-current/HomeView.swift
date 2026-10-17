import SwiftUI

private enum Theme {
    static let background = IstanbulStyle.cream
    static let card = IstanbulStyle.paper
    static let coral = IstanbulStyle.coral
    static let ink = IstanbulStyle.ink
    static let teal = IstanbulStyle.teal
}

struct HomeView: View {
    @State private var origin = ""
    @State private var destination = ""
    @State private var selectingOrigin = false
    @State private var showingPlaces = false
    @State private var showingNotice = false
    @State private var routingRequest: DistrictJourney?
    @State private var notice = ""

    var body: some View {
        NavigationStack {
            GeometryReader { viewport in
              ScrollView {
                VStack(spacing: 0) {
                    hero.frame(height: max(270, min(360, viewport.size.height * 0.44)))
                    VStack(alignment: .leading, spacing: 12) {
                        routeCard
                        explorePlaces
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                    .padding(.top, -20)
                }
                .frame(maxWidth: 430)
                .frame(maxWidth: .infinity)
              }
            }
            .background(Theme.background)
            .foregroundStyle(Theme.ink)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showingPlaces) {
                DistrictPickerView(title: selectingOrigin ? "Starting district" : "Choose destination", current: selectingOrigin ? origin : destination) { name in
                    if selectingOrigin { origin = name } else { destination = name }
                    showingPlaces = false
                }
            }
            .sheet(item: $routingRequest) { NavigationStack { DistrictJourneyView(journey: $0) } }
            .alert("Prototype", isPresented: $showingNotice) {
                Button("OK", role: .cancel) { }
            } message: { Text(notice) }
        }
        .tint(Theme.coral)
        .buttonStyle(CityPressStyle())
        .modifier(IstanbulSurface())
    }

    private var hero: some View {
        GeometryReader { proxy in
            CityArtwork(tile: 0)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .accessibilityLabel("Galata Tower, a red tram and the Bosphorus")
        }
        .overlay(alignment: .topLeading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Beyoğlu").font(IstanbulStyle.title(32))
                    Text("Near you").font(.caption)
                    Capsule().fill(Theme.coral).frame(width: 28, height: 3).padding(.top, 5)
                }
                Spacer()
                Button {
                    notice = "You're all caught up. Travel updates will appear here."
                    showingNotice = true
                } label: {
                    Image(systemName: "bell")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Notifications")
                .buttonStyle(CityPressStyle(kind: .bell))
            }
            .padding(20)
        }
        .foregroundStyle(Theme.ink)
    }

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where to today?")
                .font(IstanbulStyle.title(24))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                VStack(spacing: 8) {
                    placeField("From", value: origin.isEmpty ? "Choose a starting district" : origin, icon: "mappin.circle.fill") {
                        selectingOrigin = true
                        showingPlaces = true
                    }
                    placeField("To", value: destination.isEmpty ? "Choose a district" : destination,
                               icon: "mappin.circle.fill") {
                        selectingOrigin = false
                        showingPlaces = true
                    }
                }
            Button {
                if origin.isEmpty {
                    selectingOrigin = true
                    showingPlaces = true
                    return
                }
                if destination.isEmpty {
                    selectingOrigin = false
                    showingPlaces = true
                    return
                }
                guard canCompare else {
                    notice = "Choose two different places."
                    showingNotice = true
                    return
                }
                routingRequest = DistrictJourney(from: origin, to: destination)
            } label: {
                Label("Compare routes", systemImage: "arrow.right")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .foregroundStyle(.white)
                    .background(Theme.coral, in: RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(CityPressStyle(kind: .primary))
            if isSameStartAndDestination {
                Text("Choose two different places.").font(.caption)
            }
        }
        .padding(14)
        .background(Theme.background, in: RoundedRectangle(cornerRadius: 28))
    }

    private var canCompare: Bool {
        !origin.isEmpty && !destination.isEmpty && !isSameStartAndDestination
    }
    private var isSameStartAndDestination: Bool {
        !origin.isEmpty && origin == destination
    }

    private func placeField(_ title: String, value: String, icon: String,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(title == "From" ? Theme.teal : Theme.coral)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.caption).foregroundStyle(.secondary)
                    Text(value).font(.system(.subheadline, design: .serif).weight(.semibold))
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption)
            }
            .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
            .padding(10)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Theme.ink.opacity(0.12)))
        }
        .foregroundStyle(Theme.ink)
    }

    private var explorePlaces: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore Istanbul").font(IstanbulStyle.title(22))
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) { destinationTiles }
                VStack(alignment: .leading, spacing: 14) { destinationTiles }
            }
        }.padding(.horizontal, 4).padding(.top, 12)
    }

    @ViewBuilder private var destinationTiles: some View {
        ForEach(0..<3, id: \.self) { index in
            Button {
                destination = ["Fatih", "Beyoğlu", "Üsküdar"][index]
                selectingOrigin = false
                showingPlaces = true
            } label: {
                VStack(alignment: .leading, spacing: 7) {
                    CityArtwork(tile: index + 1).frame(height: 118).clipShape(RoundedRectangle(cornerRadius: 10))
                    Text(["Sultanahmet", "Galata Tower", "Maiden’s Tower"][index]).font(.system(.caption, design: .serif).bold()).lineLimit(2)
                    Text(["Historic peninsula", "Iconic views", "Across the Bosphorus"][index]).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                }.frame(minWidth: 88, maxWidth: .infinity, alignment: .leading)
            }.foregroundStyle(Theme.ink).accessibilityLabel("Choose district: \(["Fatih", "Beyoğlu", "Üsküdar"][index])")
        }
    }

}

// Reusable native interactions. Button actions and accessibility stay intact.
struct CityPressStyle: ButtonStyle {
    enum Kind { case card, primary, bell }
    var kind: Kind = .card
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .symbolEffect(.bounce, options: .speed(1.6),
                          value: configuration.isPressed && !reduceMotion)
            .overlay {
                if kind == .primary && !reduceMotion {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.32), .clear],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: 60, height: geometry.size.height * 2)
                            .rotationEffect(.degrees(22))
                            .offset(x: configuration.isPressed ? -90 : geometry.size.width + 90,
                                    y: -geometry.size.height / 2)
                            .animation(configuration.isPressed ? nil : .easeOut(duration: 0.55),
                                       value: configuration.isPressed)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .allowsHitTesting(false)
                }
            }
            .brightness(configuration.isPressed ? -0.035 : 0)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.955 : 1))
            .rotationEffect(.degrees(!reduceMotion && kind == .bell && configuration.isPressed ? -12 : 0))
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.32, dampingFraction: 0.52),
                       value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, pressed in
                pressed
            }
    }
}

#Preview { HomeView() }
