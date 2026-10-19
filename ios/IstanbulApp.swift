import SwiftUI
import UIKit

private let ink = Color(red: 0.063, green: 0.169, blue: 0.231)
private let paper = Color(red: 0.984, green: 0.953, blue: 0.894)
private let coral = Color(red: 0.933, green: 0.376, blue: 0.278)
private func editorial(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .default) }

struct Place: Identifiable, Decodable {
    let id, name, district, category: String
    let photo: Int
    let latitude, longitude: Double
    let story: String
    let duration: String
    let activities: [String]
    let nearby: [String]
    let source: String
    var hasMapLocation: Bool { latitude != 0 && longitude != 0 }
    var point: CGPoint { CGPoint(x: (longitude - 28.97) * 84000, y: (41.03 - latitude) * 111000) }
    var symbol: String { category == "Tarih" ? "building.columns" : category == "Lezzet" ? "fork.knife" : category == "Kültür" ? "building.columns.fill" : category == "Doğa" ? "leaf" : category == "Semt" ? "building.2" : "mountain.2" }
}

private let places: [Place] = {
    guard let url = Bundle.main.url(forResource: "places", withExtension: "json", subdirectory: "assets"), let data = try? Data(contentsOf: url), let catalog = try? JSONDecoder().decode([Place].self, from: data) else { fatalError("Yer kataloğu yüklenemedi.") }
    return catalog
}()

final class GuideStore: ObservableObject {
    @Published var saved: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "saved") ?? []) {
        didSet { UserDefaults.standard.set(Array(saved), forKey: "saved") }
    }
    @Published var plan: [String] = UserDefaults.standard.stringArray(forKey: "plan") ?? [] {
        didSet { UserDefaults.standard.set(plan, forKey: "plan") }
    }
    func toggle(_ id: String) { if saved.contains(id) { saved.remove(id) } else { saved.insert(id) } }
}

private enum Photos {
    static func load(_ name: String) -> UIImage {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "assets"), let image = UIImage(contentsOfFile: url.path) else { return UIImage() }
        return image
    }
    static let scenes = ["ferry","street","coast","park"].map { load("scene-" + $0 + "-calm") }
    static let images: [UIImage] = [scenes[0]] + ["galata","kiz","sultanahmet","gulhane","eminonu","balat","ortakoy","karakoy"].map { load("illustration-" + $0 + "-calm") }
}
private struct SceneArtwork: View {
    let index: Int
    var body: some View {
        GeometryReader { geo in
            if Photos.scenes.indices.contains(index) {
                Image(uiImage: Photos.scenes[index]).resizable().scaledToFill().frame(width: geo.size.width, height: geo.size.height).clipped()
            } else { Color.orange.opacity(0.2) }
        }.accessibilityHidden(true)
    }
}

private struct PhotoCreditRecord: Decodable { let id, title, author, license, licenseUrl, source: String }
private let nativePhotoCredits: [PhotoCreditRecord] = {
    guard let url = Bundle.main.url(forResource: "photo-credits", withExtension: "json", subdirectory: "assets"), let data = try? Data(contentsOf: url), let entries = try? JSONDecoder().decode([PhotoCreditRecord].self, from: data) else { return [] }
    return entries
}()
private struct PhotoCreditView: View {
    let id: String
    var body: some View {
        if let c = nativePhotoCredits.first(where: { $0.id == id }), let source = URL(string: c.source), let license = URL(string: c.licenseUrl) {
            HStack(spacing: 4) { Link("Fotoğraf: \(c.author)", destination: source); Text("·"); Link(c.license, destination: license) }.font(.system(size: 8)).foregroundStyle(.secondary)
        }
    }
}

struct TravelPhoto: View {
    let index: Int
    var fit: Bool = false
    var body: some View {
        GeometryReader { geo in
            if Photos.images.indices.contains(index) {
                Image(uiImage: Photos.images[index]).resizable().aspectRatio(contentMode: fit ? .fit : .fill).frame(width: geo.size.width, height: geo.size.height).clipped()
            } else { Color.gray.opacity(0.2) }
        }
        .accessibilityHidden(true)
    }
}

@main
struct IstanbulApp: App {
    @StateObject private var store = GuideStore()
    var body: some Scene { WindowGroup { GuideRoot().environmentObject(store).preferredColorScheme(.light).tint(coral) } }
}

struct NativeDay: Identifiable {
    let id, name, mood, duration: String
    let art: Int
    let ids: [String]
}
private let nativeDays: [NativeDay] = [
    .init(id: "kiyi", name: "Kıyıdan sokağa", mood: "Meraklı", duration: "3 saat", art: 2, ids: ["karakoy","galata","eminonu","kiz"]),
    .init(id: "kahve", name: "Bir kahve, bir keşif", mood: "Meraklı", duration: "2 saat", art: 1, ids: ["karakoy","galata"]),
    .init(id: "gunbatimi", name: "Gün batımına doğru", mood: "Meraklı", duration: "2–3 saat", art: 0, ids: ["eminonu","kiz","ortakoy"]),
    .init(id: "yesil", name: "Ağaçların altında", mood: "Sakin", duration: "2 saat", art: 3, ids: ["gulhane","sultanahmet","eminonu"]),
    .init(id: "deniz", name: "Denize karşı bir mola", mood: "Sakin", duration: "1–2 saat", art: 2, ids: ["kiz","ortakoy"]),
    .init(id: "adim", name: "Sokak sokak İstanbul", mood: "Enerjik", duration: "4 saat", art: 1, ids: ["balat","eminonu","karakoy","galata"]),
    .init(id: "katman", name: "Şehrin katmanları", mood: "Enerjik", duration: "3–4 saat", art: 0, ids: ["sultanahmet","gulhane","eminonu","galata"])
]

struct GuideRoot: View {
    @State private var entered = false
    @State private var page = 0
    @State private var selected = places[0]
    @State private var detail: Place?
    @State private var panel: GuidePanel?
    @State private var idea: NativeDay?
    @State private var day = nativeDays[0]
    var body: some View {
        ZStack {
            paper.ignoresSafeArea()
            if entered {
                VStack(spacing: 0) {
                    if page == 0 {
                        DiscoverScreen(open: { detail = $0 }, showMap: { page = 1 }, pick: { idea = $0 }, restart: { entered = false })
                    } else {
                        IstanbulMap(day: day, selected: $selected, open: { detail = selected })
                    }
                    HStack(spacing: 0) {
                        tab("Keşfet", "safari", active: page == 0) { page = 0 }
                        tab("Harita", "map", active: page == 1) { page = 1 }
                        tab("Günüm", "calendar", active: false) { panel = .plan }
                        tab("Kaydedilenler", "bookmark", active: false) { panel = .saved }
                    }.padding(.top, 11).padding(.bottom, 5).background(paper)
                }.ignoresSafeArea(edges: .top)
            } else {
                WelcomeScreen { withAnimation(.easeInOut(duration: 0.3)) { entered = true } }
            }
        }.foregroundStyle(ink)
        .sheet(item: $detail) { place in PlaceSheet(place: place) { selected = place; page = 1; detail = nil }.presentationDragIndicator(.visible) }
        .sheet(item: $panel) { kind in CollectionSheet(kind: kind) { place in panel = nil; selected = place; page = 1 }.presentationDragIndicator(.visible) }
        .sheet(item: $idea) { chosen in NativeDaySheet(day: chosen) { day = chosen; page = 1; idea = nil }.presentationDragIndicator(.visible) }
    }
    private func tab(_ title: String, _ symbol: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) { VStack(spacing: 6) { Image(systemName: symbol).font(.system(size: 21, weight: .light)); Text(title).font(.system(size: 9)) }.frame(maxWidth: .infinity).frame(minHeight: 45).foregroundStyle(active ? coral : Color.secondary) }
    }
}

struct WelcomeScreen: View {
    let enter: () -> Void
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                SceneArtwork(index: 0)
                LinearGradient(colors: [.clear, .clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 13) {
                    Text("İstanbul’a karış.").font(editorial(geo.size.width * 0.09)).tracking(-1.7).lineLimit(1).minimumScaleFactor(0.7)
                    Text("Bir vapur, bir sokak, bin hikâye.").font(.system(size: 17)).tracking(-0.5)
                    Button(action: enter) { HStack(spacing: 17) { Text("Keşfe başla").font(.system(size: 16, weight: .bold)); Image(systemName: "arrow.right").foregroundStyle(coral) }.frame(maxWidth: .infinity).frame(height: 54).background(paper, in: Capsule()).foregroundStyle(ink) }.padding(.top, 10)
                    Button(action: enter) { Image(systemName: "chevron.down").font(.system(size: 23, weight: .light)) }.accessibilityLabel("Şehrin içine kaydır").padding(.top, 7)
                }.padding(.horizontal, 24).padding(.bottom, 43).foregroundStyle(.white)
            }
            .overlay(alignment: .top) { VStack(spacing: 4) { Text("✦").font(.system(size: 25)).foregroundStyle(coral); Text("istanbul").font(.system(size: 35, weight: .heavy)).tracking(-1); Text("ŞEHRİN İÇİNE").font(.system(size: 7, weight: .semibold)).tracking(3.6) }.padding(.top, geo.safeAreaInsets.top + 38).foregroundStyle(ink) }
            .contentShape(Rectangle()).gesture(DragGesture(minimumDistance: 40).onEnded { if $0.translation.height < -65 { enter() } }).ignoresSafeArea()
        }
    }
}

struct DiscoverScreen: View {
    @EnvironmentObject private var store: GuideStore
    @State private var query = ""
    @State private var category = "Tümü"
    @State private var district = "Tüm bölgeler"
    @State private var mood = "Meraklı"
    let open: (Place) -> Void
    let showMap: () -> Void
    let pick: (NativeDay) -> Void
    let restart: () -> Void
    private var filtered: [Place] { places.filter { (category == "Tümü" || $0.category == category) && (district == "Tüm bölgeler" || $0.district == district) && (query.isEmpty || ($0.name + " " + $0.district).localizedStandardContains(query)) } }
    private var ideas: [NativeDay] { Array((nativeDays.filter { $0.mood == mood } + nativeDays.filter { $0.mood != mood }).prefix(3)) }
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack {
                        SceneArtwork(index: 1).offset(y: max(-30, min(50, geo.frame(in: .global).minY * -0.12)))
                        LinearGradient(colors: [.black.opacity(0.17), .clear], startPoint: .top, endPoint: .bottom)
                        VStack {
                            HStack {
                                Button(action: restart) { VStack(alignment: .leading, spacing: 2) { Text("✦").font(.system(size: 14)).foregroundStyle(coral); Text("istanbul").font(.system(size: 27, weight: .heavy)).tracking(-1); Text("ŞEHRİN İÇİNE").font(.system(size: 6)).tracking(2.4) }.foregroundStyle(.white) }
                                Spacer()
                                Button(action: showMap) { Image(systemName: "map").foregroundStyle(ink).frame(width: 41, height: 41).background(paper, in: Circle()) }.accessibilityLabel("Haritayı aç")
                            }.padding(.top, 45)
                            HStack { Button { open(places[3]) } label: { Label("Karaköy", systemImage: "mappin").font(.system(size: 11, weight: .semibold)).padding(9).background(paper, in: Capsule()) }; Spacer(); Button { open(places[0]) } label: { Label("Galata", systemImage: "mappin").font(.system(size: 11, weight: .semibold)).padding(9).background(paper, in: Capsule()) }.offset(y: -35) }.padding(.horizontal, 35).padding(.top, 75)
                            Spacer()
                        }.padding(.horizontal, 22)
                    }.clipped()
                }.frame(height: 340)
                VStack(alignment: .leading, spacing: 19) {
                    VStack(alignment: .leading, spacing: 11) {
                        Text("BUGÜN NASIL HİSSEDİYORSUN?").font(.system(size: 8, weight: .medium)).tracking(2)
                        HStack(spacing: 7) { ForEach(["Sakin","Meraklı","Enerjik"], id: \.self) { item in Button { withAnimation(.easeInOut(duration: 0.2)) { mood = item } } label: { HStack(spacing: 7) { Image(systemName: item == "Sakin" ? "leaf" : item == "Meraklı" ? "safari" : "sun.max"); Text(item) }.font(.system(size: 11)).frame(maxWidth: .infinity).frame(height: 38).background(mood == item ? coral : Color.clear, in: Capsule()).overlay(Capsule().strokeBorder(mood == item ? coral : ink.opacity(0.12))).foregroundStyle(mood == item ? .white : ink) } } }
                    }
                    Text(mood == "Sakin" ? "Biraz yavaşla, İstanbul." : mood == "Enerjik" ? "Şehir seni bekliyor." : "Bugün şehre karış.").font(editorial(29)).tracking(-1.2).lineLimit(1).minimumScaleFactor(0.7)
                    VStack(spacing: 9) {
                        dayCard(ideas[0], large: true).frame(height: 170)
                        HStack(spacing: 9) { dayCard(ideas[1]); dayCard(ideas[2]) }.frame(height: 115)
                    }
                    HStack { Text("Biraz da keşfe çık.").font(editorial(24)).tracking(-0.8); Spacer(); Button("Haritada gör", action: showMap).font(.system(size: 9)) }.padding(.top, 12)
                    HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Bir semt, bir yer, bir hikâye…", text: $query).font(.system(size: 12)) }.padding(14).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(ink.opacity(0.12)))
                    ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 7) { ForEach(["Tümü","Tarih","Kültür","Semt","Lezzet","Doğa","Manzara"], id: \.self) { item in Button { category = item } label: { Text(item).font(.system(size: 10)).frame(maxWidth: .infinity).padding(.vertical, 9).background(category == item ? ink : ink.opacity(0.04), in: Capsule()).foregroundStyle(category == item ? .white : ink) } } } }
                    Picker("Bölge", selection: $district) { Text("Tüm bölgeler").tag("Tüm bölgeler"); ForEach(Array(Set(places.map { $0.district })).sorted(), id: \.self) { Text($0).tag($0) } }.tint(ink)
                    Text("\(filtered.count) keşif · Süreler öneridir").font(.system(size: 11)).foregroundStyle(.secondary)
                    if filtered.isEmpty { Text("Bu aramada bir durak bulunamadı.").font(.system(size: 12)).foregroundStyle(.secondary) }
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 17) {
                        ForEach(filtered) { p in
                            VStack(alignment: .leading, spacing: 7) {
                                Button { open(p) } label: { PlaceArtwork(place: p).aspectRatio(1, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 11)) }.overlay(alignment: .topTrailing) { Button { store.toggle(p.id) } label: { Image(systemName: store.saved.contains(p.id) ? "bookmark.fill" : "bookmark").font(.system(size: 12)).padding(9).background(paper, in: Circle()) }.padding(7).accessibilityLabel("\(p.name) kaydet") }
                                Button { open(p) } label: { Text(p.name).font(.system(size: 14, weight: .bold)).multilineTextAlignment(.leading) }
                                Text("\(p.district) · \(p.category)").font(.system(size: 9)).foregroundStyle(.secondary)
                            }
                        }
                    }
                    Button(action: showMap) { HStack { Text("✦").font(.system(size: 31)).foregroundStyle(coral); Text("Haritayı aç. Hikâyeni bul.").font(.system(size: 16, weight: .semibold)); Spacer(); Image(systemName: "arrow.right") }.padding(19).background(ink, in: RoundedRectangle(cornerRadius: 14)).foregroundStyle(paper) }.padding(.top, 10)
                    Text("İstanbul’u aceleye getirme.").font(.system(size: 10)).foregroundStyle(.secondary).padding(.vertical, 20)
                }.padding(.horizontal, 18).padding(.top, 22).background(UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25).fill(paper)).offset(y: -24).padding(.bottom, -24)
            }
        }.scrollIndicators(.hidden)
    }
    private func dayCard(_ day: NativeDay, large: Bool = false) -> some View {
        Button { pick(day) } label: {
            ZStack(alignment: .bottomLeading) {
                SceneArtwork(index: day.art)
                LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 6) { Text(day.name).font(.system(size: large ? 20 : 12, weight: .bold)).tracking(-0.3); if large { Text("\(day.duration) · \(day.ids.count) durak").font(.system(size: 10)) } }.padding(13).foregroundStyle(.white)
            }.clipShape(RoundedRectangle(cornerRadius: 12))
        }.buttonStyle(.plain)
    }
}

private struct NativeDaySheet: View {
    @EnvironmentObject private var store: GuideStore
    let day: NativeDay
    let showMap: () -> Void
    @State private var added = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SceneArtwork(index: day.art).frame(height: 260)
                VStack(alignment: .leading, spacing: 18) {
                    Text("SENİN İSTANBUL’UN").font(.system(size: 8)).tracking(2)
                    Text(day.name).font(editorial(31)).tracking(-1)
                    Text("Yaklaşık \(day.duration) · \(day.ids.count) durak").font(.system(size: 12)).foregroundStyle(.secondary)
                    ForEach(Array(day.ids.enumerated()), id: \.element) { i, id in
                        if let p = places.first(where: { $0.id == id }) { HStack(spacing: 13) { Text(String(i + 1)).font(.system(size: 12)).frame(width: 30, height: 30).background(coral.opacity(0.2), in: Circle()); VStack(alignment: .leading, spacing: 5) { Text(p.name).font(.system(size: 14, weight: .semibold)); Text("\(p.district) · \(p.category)").font(.system(size: 10)).foregroundStyle(.secondary) } } }
                    }
                    Button(action: showMap) { Label("Haritada keşfet", systemImage: "map").font(.system(size: 14, weight: .semibold)).frame(maxWidth: .infinity).padding().background(coral, in: Capsule()).foregroundStyle(.white) }
                    Button { for id in day.ids where !store.plan.contains(id) { store.plan.append(id) }; added = true } label: { Label(added ? "Günüme eklendi" : "Günüme ekle", systemImage: added ? "checkmark" : "calendar").font(.system(size: 13)) }
                    Text("Bir keşif fikridir. Süreler yaklaşık; deniz veya toplu taşıma geçişi gerekebilir. Yol tarifi değildir.").font(.system(size: 10)).foregroundStyle(.secondary)
                }.padding(.horizontal, 24).padding(.bottom, 30)
            }
        }.background(paper).foregroundStyle(ink)
    }
}

struct MapData: Decodable {
    struct Road: Decodable { let kind: String; let points: [[Double]] }
    let coasts, parks: [[[Double]]]
    let roads: [Road]
}
final class MapModel: ObservableObject {
    @Published var data: MapData?
    @Published var failed = false
    init() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let url = Bundle.main.url(forResource: "map-data", withExtension: "json", subdirectory: "assets") else { throw CocoaError(.fileNoSuchFile) }
                let map = try JSONDecoder().decode(MapData.self, from: Data(contentsOf: url))
                DispatchQueue.main.async { self.data = map }
            } catch { DispatchQueue.main.async { self.failed = true } }
        }
    }
}

struct IstanbulMap: View {
    let day: NativeDay
    @StateObject private var model = MapModel()
    @Binding var selected: Place
    let open: () -> Void
    @State private var center = CGPoint(x: 1450, y: 1550)
    @State private var span: CGFloat = 4300
    @State private var dragOrigin: CGPoint?
    @State private var pinchOrigin: CGFloat?
    @State private var query = ""
    @State private var simplified = false
    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / span
            let project: (CGPoint) -> CGPoint = { CGPoint(x: ($0.x - center.x) * scale + geo.size.width / 2, y: ($0.y - center.y) * scale + geo.size.height / 2) }
            ZStack {
                Color(red: 0.16, green: 0.39, blue: 0.44)
                if let data = model.data {
                    Canvas { ctx, _ in
                        func path(_ points: [[Double]], closed: Bool = false) -> Path {
                            Path { p in
                                for (i, point) in points.enumerated() { let v = project(CGPoint(x: point[0], y: point[1])); if i == 0 { p.move(to: v) } else { p.addLine(to: v) } }
                                if closed { p.closeSubpath() }
                            }
                        }
                        for coast in data.coasts {
                            var points = coast
                            if points.first != points.last {
                                points += points[0][0] < 0 ? [[15000,-18000],[-18000,-18000],[-18000,18000]] : [[18000,18000],[18000,-18000]]
                            }
                            ctx.fill(path(points, closed: true), with: .color(Color(red: 0.94, green: 0.88, blue: 0.76)))
                        }
                        for park in data.parks { ctx.fill(path(park, closed: true), with: .color(Color(red: 0.66, green: 0.74, blue: 0.56))) }
                        for road in data.roads {
                            let major = ["motorway","trunk","primary","secondary"].contains(road.kind)
                            if simplified && !major { continue }
                            ctx.stroke(path(road.points), with: .color(.white.opacity(0.85)), lineWidth: max(major ? 1 : 0.5, (major ? 13 : 4.4) * scale))
                        }
                        for (name, lon, lat) in [("BEYOĞLU",28.981,41.037),("GALATA",28.974,41.0285),("KARAKÖY",28.985,41.024),("EMİNÖNÜ",28.966,41.0168),("HALİÇ",28.960,41.031),("ÜSKÜDAR",29.022,41.023)] {
                            let p = CGPoint(x: (lon - 28.97) * 84000, y: (41.03 - lat) * 111000)
                            ctx.draw(Text(name).font(.system(size: 9, weight: .medium)).tracking(2).foregroundStyle(ink.opacity(0.55)), at: project(p))
                        }
                    }
                    .gesture(DragGesture().onChanged { value in
                        if dragOrigin == nil { dragOrigin = center }
                        guard let origin = dragOrigin else { return }
                        center = CGPoint(x: min(5000,max(-2500,origin.x - value.translation.width / scale)), y: min(4200,max(-2500,origin.y - value.translation.height / scale)))
                    }.onEnded { _ in dragOrigin = nil })
                    .simultaneousGesture(MagnificationGesture().onChanged { value in
                        if pinchOrigin == nil { pinchOrigin = span }
                        span = min(8500, max(1300, (pinchOrigin ?? span) / value))
                    }.onEnded { _ in pinchOrigin = nil })
                    ForEach(places.filter { $0.hasMapLocation }) { p in
                        let pos = project(p.point)
                        if pos.x > -30 && pos.x < geo.size.width + 30 && pos.y > -30 && pos.y < geo.size.height + 30 {
                            Button { selected = p } label: { Image(systemName: p.symbol).font(.system(size: 16)).foregroundStyle(.white).frame(width: 39, height: 39).background(selected.id == p.id ? coral : ink, in: Circle()).overlay(Circle().stroke(paper, lineWidth: 2)) }.position(pos).accessibilityLabel(p.name)
                        }
                    }
                } else { Text(model.failed ? "Harita verisi bulunamadı." : "İstanbul’un sokakları hazırlanıyor…").font(.system(size: 12)).padding().background(paper, in: Capsule()) }
                VStack {
                    HStack {
                        HStack { Image(systemName: "magnifyingglass"); TextField("Bir yer keşfet", text: $query).font(.system(size: 12)) }.padding(15).background(paper, in: Capsule())
                        roundButton("square.3.layers.3d") { simplified.toggle() }
                    }
                    if !query.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(places.filter { $0.hasMapLocation && ($0.name + " " + $0.district).localizedStandardContains(query) }) { p in Button(p.name) { selected = p; center = CGPoint(x: p.point.x, y: p.point.y + span * 0.12); query = "" }.font(.system(size: 13)) }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding().background(paper, in: RoundedRectangle(cornerRadius: 15))
                    }
                    Spacer()
                    HStack { Spacer(); VStack(spacing: 8) { roundButton("plus") { span = max(1300, span * 0.76) }; roundButton("minus") { span = min(8500, span * 1.32) }; roundButton("location") { center = CGPoint(x:720,y:1050); span = 4300 } } }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SENİN İSTANBUL’UN").font(.system(size: 7)).tracking(2)
                        HStack {
                            VStack(alignment: .leading, spacing: 6) { Text(day.name).font(editorial(25)); Text("\(day.duration) · \(day.ids.count) durak").font(.system(size: 11)) }
                            Spacer()
                            Button(action: open) { Image(systemName: "arrow.right").foregroundStyle(.white).frame(width: 39, height: 39).background(coral, in: Circle()) }.accessibilityLabel("Seçili mekânın ayrıntıları")
                        }
                        HStack(alignment: .top, spacing: 4) {
                            ForEach(Array(day.ids.enumerated()), id: \.element) { i, id in
                                if let p = places.first(where: { $0.id == id }) {
                                    Button { selected = p; center = CGPoint(x: p.point.x, y: p.point.y + span * 0.15) } label: {
                                        VStack(spacing: 7) { Text(String(i + 1)).font(.system(size: 12)).foregroundStyle(.white).frame(width: 26, height: 26).background(coral, in: Circle()); Text(p.name).font(.system(size: 8)).multilineTextAlignment(.center).lineLimit(2) }.frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }.padding(.top, 3)
                    }.padding(20).background(paper, in: RoundedRectangle(cornerRadius: 23)).padding(.top, 8)
                    Link("© OpenStreetMap katkıcıları · ODbL", destination: URL(string: "https://www.openstreetmap.org/copyright")!).font(.system(size: 8)).padding(4).background(paper.opacity(0.9), in: RoundedRectangle(cornerRadius: 3)).frame(maxWidth: .infinity, alignment: .leading)
                }.padding(17)
            }.clipped()
        }
    }
    private func roundButton(_ name: String, action: @escaping () -> Void) -> some View { Button(action: action) { Image(systemName: name).frame(width: 43, height: 43).background(paper, in: Circle()) }.accessibilityLabel(name == "plus" ? "Yakınlaştır" : name == "minus" ? "Uzaklaştır" : name == "location" ? "Başlangıç görünümü" : "Harita katmanları") }
}

struct PlaceSheet: View {
    @EnvironmentObject private var store: GuideStore
    let place: Place
    @State private var relatedPlace: Place?
    let showMap: () -> Void
    var allowsMap: Bool = true
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 19) {
                PlaceArtwork(place: place).aspectRatio(1, contentMode: .fit)
                VStack(alignment: .leading, spacing: 18) {
                    Text("\(place.district.uppercased()) · \(place.category.uppercased())").font(.system(size: 9)).tracking(2).foregroundStyle(.secondary)
                    Text(place.name).font(editorial(44))
                    Text(place.photo >= 0 ? "İstanbul için özel çizim · Sanatsal yorum" : "İstanbul keşif rehberi").font(.system(size: 9)).foregroundStyle(.secondary)
                    Text(place.story).font(.system(size: 15)).lineSpacing(6).foregroundStyle(.secondary)
                    Label(place.duration + " · Önerilen süre", systemImage: "clock").font(.system(size: 13, weight: .semibold))
                    Text("Burada ne yapabilirsin?").font(.headline)
                    ForEach(place.activities, id: \.self) { activity in Label(activity, systemImage: "checkmark").font(.system(size: 14)) }
                    Text("Gezini birleştir").font(.headline)
                    ForEach(place.nearby, id: \.self) { id in
                        if let next = places.first(where: { $0.id == id }) { Button { relatedPlace = next } label: { HStack { Text(next.name); Spacer(); Image(systemName: "arrow.up.right") } }.font(.system(size: 14)).padding(.vertical, 8) }
                    }
                    Text("Süreler ulaşım ve kuyruk beklemelerini içermez. Farklı bölgeleri birleştirmeden önce ulaşımı ayrıca planla.").font(.system(size: 11)).foregroundStyle(.secondary)
                    if let url = URL(string: place.source) { Link("Mekân hakkında kaynak", destination: url).font(.system(size: 12)) }
                    if allowsMap && place.hasMapLocation { Button(action: showMap) { Label("Haritada gör", systemImage: "map").frame(maxWidth: .infinity).padding().background(ink, in: Capsule()).foregroundStyle(.white) } }
                    HStack {
                        Button { store.toggle(place.id) } label: { Label(store.saved.contains(place.id) ? "Kaydedildi" : "Kaydet", systemImage: store.saved.contains(place.id) ? "bookmark.fill" : "bookmark") }
                        Spacer()
                        Button { if !store.plan.contains(place.id) { store.plan.append(place.id) } } label: { Label(store.plan.contains(place.id) ? "Planda ✓" : "Planıma ekle", systemImage: "calendar") }
                    }.font(.system(size: 12)).padding(.vertical, 12)
                    if nativePhotoCredits.contains(where: { $0.id == place.id }) { DisclosureGroup("Gerçek fotoğraf ve lisans") {
                        if let url = Bundle.main.url(forResource: place.id, withExtension: "jpg", subdirectory: "assets"), let image = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 12))
                            PhotoCreditView(id: place.id).padding(.top, 8)
                        }
                        Text("Gerçek fotoğraf belirtilen CC lisansıyla sunulur. Ana sahneler ve kartlar özel illüstrasyonlardır.").font(.system(size: 10)).foregroundStyle(.secondary)
                    }.font(.system(size: 12)) }
                }.padding(.horizontal, 24).padding(.bottom, 30)
            }
        }.background(paper).foregroundStyle(ink)
        .sheet(item: $relatedPlace) { next in PlaceSheet(place: next, showMap: showMap, allowsMap: false).environmentObject(store) }
    }
}

enum GuidePanel: String, Identifiable { case saved, plan; var id: String { rawValue } }
struct CollectionSheet: View {
    @EnvironmentObject private var store: GuideStore
    let kind: GuidePanel
    let open: (Place) -> Void
    var list: [Place] { kind == .saved ? places.filter { store.saved.contains($0.id) } : store.plan.compactMap { id in places.first { $0.id == id } } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(kind == .saved ? "Kaydettiklerin." : "Bugünün hikâyesi.").font(editorial(42)).padding(.top, 25)
                Text(kind == .saved ? "Bir gün gitmek istediğin yerler, burada." : "Duraklarını keşif sırana göre biriktir. Bu liste otomatik rota değildir.").font(.system(size: 13)).foregroundStyle(.secondary)
                if list.isEmpty { Text("Henüz bir durak yok. Keşfet sayfasından kendi İstanbul’unu oluşturmaya başla.").font(.system(size: 14)).padding(.vertical, 35) }
                ForEach(list) { p in HStack { Button { open(p) } label: { HStack { PlaceArtwork(place: p).frame(width: 65, height: 72).clipShape(RoundedRectangle(cornerRadius: 10)); Text(p.name).font(editorial(25)) } }; Spacer(); Button { if kind == .saved { store.saved.remove(p.id) } else { store.plan.removeAll { $0 == p.id } } } label: { Image(systemName: "xmark").font(.system(size: 12)) }.accessibilityLabel("\(p.name) kaldır") } }
                Text("Bu cihazda saklanır. Hesap açman gerekmez.").font(.system(size: 10)).foregroundStyle(.secondary)
            }.padding(24)
        }.background(paper).foregroundStyle(ink)
    }
}

// New destinations have their own editorial card, never another landmark's illustration.
private struct PlaceArtwork: View {
    let place: Place
    var body: some View {
        if place.photo >= 0 { TravelPhoto(index: place.photo, fit: true) }
        else {
            ZStack {
                LinearGradient(colors: [Color(red: 0.96, green: 0.84, blue: 0.70), paper], startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: place.symbol).font(.system(size: 30, weight: .light)).foregroundStyle(coral)
                    Spacer(minLength: 2)
                    Text(place.district.uppercased()).font(.system(size: 9, weight: .medium)).tracking(1)
                    Text(place.name).font(.system(size: 18, weight: .semibold)).multilineTextAlignment(.leading).lineLimit(3).minimumScaleFactor(0.7)
                }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
            }.foregroundStyle(ink)
        }
    }
}
