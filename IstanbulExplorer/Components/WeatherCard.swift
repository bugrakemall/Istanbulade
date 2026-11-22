import SwiftUI

struct WeatherCard: View {
    @State private var weather: IstanbulWeather?
    @State private var failed = false
    @State private var requestID = 0
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Istanbul Weather", systemImage: "thermometer.medium")
                .font(.subheadline.bold())

            if let weather {
                Text("\(weather.temperature, specifier: "%.1f") °C")
                    .font(.title2.bold())
                Text("Feels like \(weather.feelsLike, specifier: "%.1f") °C")
                    .font(.caption)

                Button("View weather") { showDetails = true }
                    .font(.caption.bold())
                Text("Data retrieved from Open-Meteo").font(.caption2)
            } else if failed {
                Text("Weather unavailable.").font(.caption)
                Button("Try again") { requestID += 1 }
                    .font(.subheadline)
            } else {
                ProgressView("Loading weather…").font(.caption)
            }

        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(Color(red: 0.85, green: 0.92, blue: 0.96), in: RoundedRectangle(cornerRadius: 10))
        // Karttaki değerleri uygulama içindeki detay ekranına taşıyoruz.
        .sheet(isPresented: $showDetails) {
            if let weather {
                NavigationStack {
                    Form {
                        Section("Current conditions") {
                            LabeledContent("Temperature") {
                                Text("\(weather.temperature, specifier: "%.1f") °C")
                            }
                            LabeledContent("Feels like") {
                                Text("\(weather.feelsLike, specifier: "%.1f") °C")
                            }
                        }
                        Section {
                            Text("Data retrieved from Open-Meteo")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle("Istanbul Weather")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showDetails = false }
                        }
                    }
                }
            }
        }
        // Kart açılınca ve Try again isteği yenileyince API çağrılır.
        .task(id: requestID) {
            weather = nil
            failed = false
            do {
                let result = try await IstanbulWeather.fetch()
                if !Task.isCancelled { weather = result }
            } catch {
                if !Task.isCancelled { failed = true }
            }
        }
    }
}
