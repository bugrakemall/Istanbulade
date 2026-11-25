import XCTest

final class IstanbulExplorerUITests: XCTestCase {
    @MainActor
    func testHistoricalPlacesOpensFromCategoriesTab() {
        let app = XCUIApplication()
        app.launch()

        let slider = app.sliders["welcome.slider"]
        guard slider.waitForExistence(timeout: 10) else {
            return XCTFail("Giriş kaydırıcısı bulunamadı.")
        }

        // Kaydırıcının sol ucundan sağ ucuna sürükleyerek giriş yap.
        let start = slider.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        let end = slider.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.5))
        start.press(forDuration: 0.15, thenDragTo: end)

        let categories = app.tabBars.buttons["Categories"]
        guard categories.waitForExistence(timeout: 5) else {
            return XCTFail("Categories sekmesi bulunamadı.")
        }
        categories.tap()

        let historical = app.buttons["category.Historical Places"]
        guard historical.waitForExistence(timeout: 5) else {
            return XCTFail("Historical Places kartı bulunamadı.")
        }
        historical.tap()

        XCTAssertTrue(app.navigationBars["Historical Places"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Hagia Sophia"].exists)
    }
}
