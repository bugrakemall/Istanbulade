import SwiftUI

enum IstanbulStyle {
    static let cream = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let paper = Color(red: 0.99, green: 0.97, blue: 0.92)
    static let coral = Color(red: 0.95, green: 0.39, blue: 0.32)
    static let teal = Color(red: 0.04, green: 0.49, blue: 0.52)
    static let ink = Color(red: 0.06, green: 0.16, blue: 0.23)
    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .serif) }
}

/// Four square illustration tiles, cropped without stretching.
struct CityArtwork: View {
    let tile: Int
    var body: some View {
        GeometryReader { proxy in
            let side = max(proxy.size.width, proxy.size.height)
            let index = min(3, max(0, tile))
            Image("CityScenes")
                .resizable().frame(width: side * 2, height: side * 2)
                .offset(x: -CGFloat(index % 2) * side + (proxy.size.width - side) / 2,
                        y: -CGFloat(index / 2) * side + (proxy.size.height - side) / 2)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                .clipped()
        }.accessibilityHidden(true)
    }
}

struct IstanbulSurface: ViewModifier {
    func body(content: Content) -> some View {
        content.background(IstanbulStyle.cream).foregroundStyle(IstanbulStyle.ink)
            .tint(IstanbulStyle.coral)
            .toolbarBackground(IstanbulStyle.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .preferredColorScheme(.light)
    }
}

struct LandmarkTile: View {
    let placeID: String
    var body: some View {
        LandmarkArtwork(placeID: placeID)
            .padding(5)
            .background(LinearGradient(colors: [IstanbulStyle.teal.opacity(0.28), IstanbulStyle.paper], startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Six transparent illustrations on one atlas. Rendered crops leave the original asset intact.
struct LandmarkArtwork: View {
    let placeID: String
    private var slice: (column: CGFloat, top: CGFloat, height: CGFloat)? {
        switch placeID {
        case "galata": return (0, 0, 563)
        case "hagia", "sultanahmet": return (1, 0, 563)
        case "blue": return (0, 563, 485)
        case "bazaar": return (1, 563, 485)
        case "eminonu", "kadikoy", "uskudar", "ferry": return (0, 1048, 488)
        case "taksim": return (1, 1048, 488)
        default: return nil
        }
    }
    var body: some View {
        GeometryReader { geometry in
            if let slice {
                Image("LandmarkAtlas")
                    .resizable()
                    .frame(width: geometry.size.width * 2,
                           height: geometry.size.height * 1536 / slice.height)
                    .offset(x: -slice.column * geometry.size.width,
                            y: -slice.top * geometry.size.height / slice.height)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                    .clipped()
            } else {
                Image(systemName: "airplane")
                    .resizable().scaledToFit().foregroundStyle(Color(red: 0.21, green: 0.44, blue: 0.49))
                    .padding(12)
            }
        }
        .accessibilityHidden(true)
    }
}

struct CoralMapPin: View {
    var body: some View {
        ZStack(alignment: .top) {
            PinShape().fill(Color(red: 0.88, green: 0.44, blue: 0.34))
            Circle().fill(.white).frame(width: 12, height: 12).padding(.top, 8)
        }
        .frame(width: 30, height: 42)
        .shadow(color: .black.opacity(0.16), radius: 3, y: 3)
    }
    private struct PinShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path { p in
                p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
                p.addCurve(to: CGPoint(x: 0, y: rect.height * 0.36), control1: CGPoint(x: 0, y: rect.height * 0.65), control2: CGPoint(x: 0, y: rect.height * 0.55))
                p.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.36), control1: CGPoint(x: 0, y: -rect.height * 0.12), control2: CGPoint(x: rect.maxX, y: -rect.height * 0.12))
                p.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control1: CGPoint(x: rect.maxX, y: rect.height * 0.55), control2: CGPoint(x: rect.maxX, y: rect.height * 0.65))
                p.closeSubpath()
            }
        }
    }
}
