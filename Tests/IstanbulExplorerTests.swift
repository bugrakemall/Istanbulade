import Foundation
import XCTest
@testable import IstanbulExplorer

final class IstanbulExplorerTests: XCTestCase {
    func testTopkapiIsInHistoricalAndMuseums() throws {
        let place = try XCTUnwrap(ExplorerPlace.all.first { $0.name == "Topkapı Palace" })

        XCTAssertTrue(place.categories.contains(.historical))
        XCTAssertTrue(place.categories.contains(.museums))
    }

    func testWeatherDecodesBothTemperatures() throws {
        let json = #"{"temperature_2m": 18.5, "apparent_temperature": 16.0}"#
        let weather = try JSONDecoder().decode(IstanbulWeather.self, from: Data(json.utf8))

        XCTAssertEqual(weather.temperature, 18.5)
        XCTAssertEqual(weather.feelsLike, 16.0)
    }

    func testWeatherFailsWhenFeelsLikeIsMissing() {
        let json = #"{"temperature_2m": 18.5}"#

        XCTAssertThrowsError(
            try JSONDecoder().decode(IstanbulWeather.self, from: Data(json.utf8))
        ) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("Eksik alan hatası bekleniyordu: \(error)")
            }
            XCTAssertEqual(key.stringValue, "apparent_temperature")
        }
    }

    func testRSSSelectsFirstIstanbulHeadline() throws {
        let rss = """
        <rss version="2.0"><channel>
            <item>
                <title>Ankara’da yeni sergi</title>
                <link>https://www.trthaber.com/ankara.html</link>
            </item>
            <item>
                <title>İstanbul’da müze açıldı</title>
                <link>https://www.trthaber.com/istanbul.html</link>
            </item>
            <item>
                <title>İstanbul’da yeni sergi</title>
                <link>https://www.trthaber.com/sergi.html</link>
            </item>
        </channel></rss>
        """

        let headline = try XCTUnwrap(IstanbulHeadline.parseRSS(Data(rss.utf8)))

        XCTAssertEqual(headline.title, "İstanbul’da müze açıldı")
        XCTAssertEqual(headline.url.absoluteString, "https://www.trthaber.com/istanbul.html")
    }
}
