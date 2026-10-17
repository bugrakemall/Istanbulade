import Foundation

struct Journey: Decodable, Identifiable, Hashable {
    let id: String
    let origin: String
    let destination: String
    let options: [JourneyOption]
}

struct JourneyOption: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let symbol: String
    let fareTRY: Double?
    let steps: [String]
    let mapOrigin: String?
    let mapDestination: String?
    let sources: [String]

    var walkingURL: URL? {
        guard let mapOrigin, let mapDestination else { return nil }
        var url = URLComponents(string: "https://maps.apple.com/")!
        url.queryItems = [URLQueryItem(name: "saddr", value: mapOrigin),
                         URLQueryItem(name: "daddr", value: mapDestination),
                         URLQueryItem(name: "dirflg", value: "w")]
        return url.url
    }
}

enum RouteCatalog {
    private struct File: Decodable { let checkedOn: String; let routes: [Journey] }
    private static let result: Result<File, Error> = Result {
        guard let url = Bundle.main.url(forResource: "routes", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(File.self, from: Data(contentsOf: url))
    }
    static var routes: [Journey] { (try? result.get().routes) ?? [] }
    static var loadError: String? {
        switch result {
        case .success: return nil
        case .failure: return "Route data could not be loaded. Add routes.json to the app target and Copy Bundle Resources."
        }
    }
    static var places: [String] {
        Array(Set(routes.flatMap { [$0.origin, $0.destination] })).sorted()
    }
    static var origins: [String] { Array(Set(routes.map(\.origin))).sorted() }
    static func destinations(from origin: String) -> [String] {
        Array(Set(routes.filter { $0.origin == origin }.map(\.destination))).sorted()
    }
}
