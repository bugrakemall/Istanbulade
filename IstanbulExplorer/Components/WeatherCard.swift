import SwiftUI

struct WeatherCard: View {
    @State private var weather: IstanbulWeather?
    @State private var failed = false
    @State private var requestID = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Istanbul Weather", systemImage: "thermometer.medium")
                .font(.subheadline.bold())

            if let weather {
                Text("\(weather.temperature, specifier: "%.1f") °C")
                    .font(.title2.bold())
                Text("Feels like \(weather.feelsLike, specifier: "%.1f") °C")
                    .font(.caption)

                // Kaynak yazısı yalnızca API yanıtı başarıyla okununca görünür.
                if let source = URL(string: "https://open-meteo.com/") {
                    Link("Data retrieved from Open-Meteo", destination: source)
                        .font(.caption2)
                        .underline()
                }
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
