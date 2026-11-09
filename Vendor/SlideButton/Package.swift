// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SlideButton",
    platforms: [.iOS(.v15)],
    products: [.library(name: "SlideButton", targets: ["SlideButton"])],
    targets: [.target(name: "SlideButton")]
)
