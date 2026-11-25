import Foundation

struct IstanbulHeadline {
    let title: String
    let url: URL

    static func fetch() async throws -> IstanbulHeadline? {
        guard let url = URL(string: "https://www.trthaber.com/turkiye_articles.rss") else {
            throw URLError(.badURL)
        }
        let request = URLRequest(url: url, timeoutInterval: 15)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try parseRSS(data)
    }

    // Ayrı metot sayesinde aynı RSS okuyucusunu internet olmadan test edebiliriz.
    static func parseRSS(_ data: Data) throws -> IstanbulHeadline? {
        let reader = HeadlineReader()
        let parser = XMLParser(data: data)
        parser.delegate = reader
        guard parser.parse(), reader.foundFeed else { throw URLError(.cannotParseResponse) }
        return reader.headline
    }
}

private final class HeadlineReader: NSObject, XMLParserDelegate {
    private(set) var foundFeed = false
    private(set) var headline: IstanbulHeadline?
    private var insideItem = false
    private var field: String?
    private var title = ""
    private var link = ""

    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?,
                qualifiedName: String?, attributes: [String: String]) {
        if name == "rss" { foundFeed = true }
        if name == "item" {
            insideItem = true
            title = ""
            link = ""
        } else if insideItem && (name == "title" || name == "link") {
            field = name
        }
    }

    func parser(_ parser: XMLParser, foundCharacters text: String) {
        // XMLParser metni parça parça verebilir, bu yüzden parçaları birleştiriyoruz.
        if field == "title" { title += text }
        if field == "link" { link += text }
    }

    func parser(_ parser: XMLParser, foundCDATA data: Data) {
        if let text = String(data: data, encoding: .utf8) {
            self.parser(parser, foundCharacters: text)
        }
    }

    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?,
                qualifiedName: String?) {
        if name == field { field = nil }
        guard name == "item" else { return }
        insideItem = false
        field = nil

        // Akış en yeni haberlerle başlar. İlk geçerli İstanbul başlığını sakla.
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard headline == nil, cleanTitle.localizedStandardContains("İstanbul"),
              let url = URL(string: link.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme == "https", url.host == "www.trthaber.com" else { return }
        headline = IstanbulHeadline(title: cleanTitle, url: url)
    }
}
