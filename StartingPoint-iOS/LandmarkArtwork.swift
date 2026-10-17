import SwiftUI

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
