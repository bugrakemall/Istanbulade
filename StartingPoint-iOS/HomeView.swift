import SwiftUI

private enum Theme {
    static let background = Color(red: 0.93, green: 0.91, blue: 0.87)
    static let card = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let coral = Color(red: 0.86, green: 0.43, blue: 0.34)
    static let ink = Color(red: 0.08, green: 0.18, blue: 0.23)
    static let teal = Color(red: 0.22, green: 0.52, blue: 0.55)
}

struct HomeView: View {
    @State private var startingPoint = StartingPoint.initial
    private var origin: String { startingPoint.name }
    @State private var destination = ""
    @State private var selectingOrigin = false
    @State private var showingPlaces = false
    @State private var showingNotice = false
    @State private var selectedJourney: Journey?
    @State private var notice = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    VStack(alignment: .leading, spacing: 12) {
                        routeCard
                        if let error = RouteCatalog.loadError {
                            Text(error).font(.footnote).foregroundStyle(.red)
                        }
                        Text("Quick access").font(.subheadline.weight(.medium))
                        HStack(spacing: 12) {
                            quickButton("Hotel", icon: "bed.double.fill") {
                                notice = "Hotel selection will be added with saved places."
                                showingNotice = true
                            }
                            quickButton("Saved places", icon: "bookmark.fill") {
                                notice = "Your saved places will appear here."
                                showingNotice = true
                            }
                        }
                        Button {
                            notice = "Istanbul scenes and city sounds are planned for the Explore screen."
                            showingNotice = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "ferry.fill").font(.title)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("A little Istanbul break").font(.headline)
                                    Text("Discover the city's rhythm").font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(Theme.ink)
                            .padding(14)
                            .background(Theme.teal.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, -48)
                }
            }
            .background(Theme.background)
            .foregroundStyle(Theme.ink)
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showingPlaces) {
                if selectingOrigin {
                    StartingPointPickerView(current: startingPoint) { point in
                        startingPoint = point
                        showingPlaces = false
                    }
                } else {
                    DestinationPickerView(selectingOrigin: false, currentName: destination) { name in
                        destination = name
                        showingPlaces = false
                    }
                }
            }
            .sheet(item: $selectedJourney) { NavigationStack { RouteOptionsView(journey: $0) } }
            .alert("Prototype", isPresented: $showingNotice) {
                Button("OK", role: .cancel) { }
            } message: { Text(notice) }
        }
        .tint(Theme.coral)
        .buttonStyle(CityPressStyle())
    }

    private var hero: some View {
        GeometryReader { proxy in
            Image("BeyogluHero")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .accessibilityLabel("Galata Tower, a red tram and the Bosphorus")
        }
        .frame(height: 340)
        .overlay(alignment: .topLeading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Beyoğlu").font(.system(size: 28, weight: .bold))
                    Text("Explore Istanbul").font(.subheadline)
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
            .padding(22)
        }
        .foregroundStyle(.white)
    }

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where to today?")
                .font(.system(size: 23, weight: .bold))
                .padding(.top, 4)
                VStack(spacing: 8) {
                    placeField("From", value: origin, icon: "circle.inset.filled") {
                        selectingOrigin = true
                        showingPlaces = true
                    }
                    placeField("To", value: destination.isEmpty ? "Choose a place" : destination,
                               icon: "mappin.circle.fill") {
                        selectingOrigin = false
                        showingPlaces = true
                    }
                }
            Button {
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
                if startingPoint.curatedName == nil {
                    notice = "Starting point selected: \(origin) (\(startingPoint.coordinateText)). Routing from arbitrary coordinates will be connected in the next stage. Your selected destination is kept."
                    showingNotice = true
                } else if let journey = RouteCatalog.routes.first(where: { $0.origin == startingPoint.curatedName && $0.destination == destination }) {
                    selectedJourney = journey
                } else {
                    notice = "This place is on the map, but a route for this pair has not been added yet. Available journeys include Galata or Taksim → Sultanahmet, Sultanahmet → Grand Bazaar, Eminönü → Kadıköy or Üsküdar, and Sabiha Gökçen → Kadıköy."
                    showingNotice = true
                }
            } label: {
                Label("Compare routes", systemImage: "arrow.left.arrow.right")
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
        .background(Theme.background, in: RoundedRectangle(cornerRadius: 25))
    }

    private var canCompare: Bool {
        startingPoint.isValid && !destination.isEmpty && !isSameStartAndDestination
    }
    private var isSameStartAndDestination: Bool {
        guard let place = PlaceCatalog.places.first(where: { $0.name == destination }) else { return false }
        return startingPoint.isSamePlace(as: place)
    }

    private func placeField(_ title: String, value: String, icon: String,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(Theme.teal)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.caption).foregroundStyle(.secondary)
                    Text(value).font(.subheadline.weight(.medium))
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

    private func quickButton(_ title: String, icon: String,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(Theme.ink)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var bottomBar: some View {
        HStack {
            tab("Routes", icon: "point.topleft.down.to.point.bottomright.curvepath", selected: true)
            tab("Saved", icon: "bookmark", selected: false)
            tab("Explore", icon: "safari", selected: false)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Theme.card)
    }

    private func tab(_ title: String, icon: String, selected: Bool) -> some View {
        Button {
            guard !selected else { return }
            notice = "The \(title) screen will be added next."
            showingNotice = true
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(selected ? Theme.coral : Theme.ink)
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
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
