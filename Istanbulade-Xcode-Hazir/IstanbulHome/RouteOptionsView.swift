import SwiftUI

struct RouteOptionsView: View {
    let journey: Journey
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String?
    private let ink = Color(red: 0.08, green: 0.18, blue: 0.23)
    private let coral = Color(red: 0.86, green: 0.43, blue: 0.34)
    private let cream = Color(red: 0.93, green: 0.91, blue: 0.87)
    private var selected: JourneyOption { journey.options.first(where: { $0.id == selectedID }) ?? journey.options[0] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath").foregroundStyle(coral)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(journey.origin).font(.subheadline.bold())
                        Text("→ \(journey.destination)").font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 18))
                Text("Choose your way").font(.title2.bold())
                Text("Select an option to see its journey steps.").font(.subheadline).foregroundStyle(.secondary)
                ForEach(journey.options) { option in
                    Button {
                        selectedID = option.id
                    } label: {
                        HStack(alignment: .top, spacing: 13) {
                            Image(systemName: option.symbol).font(.title2).foregroundStyle(coral)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(option.title).font(.headline)
                                Text(option.fareTRY == 0 ? "No transit ticket needed" : "Public transport · check departures")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            VStack(alignment: .trailing, spacing: 8) {
                                Text(option.fareTRY == 0 ? "₺0" : "Fare pending").font(.subheadline.bold())
                                Image(systemName: selected.id == option.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.id == option.id ? coral : .gray)
                            }
                        }
                        .foregroundStyle(ink).padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected.id == option.id ? coral : .clear, lineWidth: 1.5))
                    }
                    .buttonStyle(CityPressStyle())
                    .accessibilityAddTraits(selected.id == option.id ? .isSelected : [])
                }
                VStack(alignment: .leading, spacing: 18) {
                    Text("Your journey").font(.title3.bold())
                    ForEach(Array(selected.steps.enumerated()), id: \.offset) { index, text in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)").font(.caption.bold())
                                .frame(width: 28, height: 28).foregroundStyle(.white).background(coral, in: Circle())
                            Text(text).font(.subheadline)
                        }
                    }
                    if let url = selected.walkingURL {
                        Link(destination: url) {
                            Label("Open walking directions", systemImage: "arrow.up.right")
                                .font(.subheadline.bold()).frame(maxWidth: .infinity, minHeight: 48)
                                .foregroundStyle(.white).background(coral, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(18).background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 22))
                Text("Times and transit fares are pending verification; options are not ranked by cheapest or fastest. ₺0 covers walking only, excluding attraction admission.")
                    .font(.footnote).foregroundStyle(.secondary)
                ForEach(selected.sources, id: \.self) { source in
                    if let url = URL(string: source) {
                        Link("Official information · \(url.host ?? "operator")", destination: url).font(.footnote)
                    }
                }
            }.padding(18)
        }
        .background(cream).foregroundStyle(ink).tint(coral)
        .navigationTitle("Your route").navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
    }
}
