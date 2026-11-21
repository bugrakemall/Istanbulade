import Foundation

struct IstanbulWeather: Decodable {
    let temperature: Double
    let feelsLike: Double

    // API'deki alan adlarını Swift'teki değişkenlere bağlıyoruz.
    private enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case feelsLike = "apparent_temperature"
    }

    private struct Response: Decodable {
        let current: IstanbulWeather
    }

    static func fetch() async throws -> IstanbulWeather {
        // İstanbul merkezinin sabit koordinatları. Kullanıcı konumu gerekmiyor.
        let endpoint = "https://api.open-meteo.com/v1/forecast?latitude=41.0082&longitude=28.9784&current=temperature_2m,apparent_temperature&temperature_unit=celsius"
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }

        let request = URLRequest(url: url, timeoutInterval: 15)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(Response.self, from: data).current
    }
}
