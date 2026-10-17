# Istanbulade — SwiftUI source

## Current version: internal district routes

The district journey screen now calculates rail connections locally. It does not launch Google Maps, Apple Maps or a browser to find a route. No API key or network request is needed to calculate the bundled rail connections. Apple Maps tiles still need internet to display.

Supported districts: Beyoğlu, Fatih, Şişli, Sarıyer, Kadıköy, Üsküdar, Maltepe, Kartal, Pendik, Tuzla, Bakırköy, Zeytinburnu and Küçükçekmece. Other districts are labelled as not covered and cannot be confirmed. Reference stations represent the districts; this is not door-to-door routing. The picker displays the actual reference-station name before confirmation.

`DistrictNetwork.swift` searches the bundled M2/M4/Marmaray graph, prioritising fewer transfers then fewer station hops. Only Yenikapı and Ayrılık Çeşmesi are modelled as interchanges. M2's Seyrantepe branch is excluded. Marmaray is modelled through Tuzla; Gebze/Halkalı are direction labels. Times, fares, service alerts, transfers on other lines and minimum-price guarantees are not included. The route screen lists all stops and direction for each ride. Dashed map lines are schematic connections between reference points, not track shapes or walkable paths. Interchange walking is not measured.

Visual changes: a new `CityScenes` illustration atlas (tram on left / Galata on right, Sultanahmet, Galata and Maiden's Tower), compact centred journey card, lighter landmark thumbnails, a map-backed district picker with confirmation and in-app route cards. The walking-limit control is removed. The map remains native Apple Maps, not the AI-generated map in the original concept image. This source has not yet been visually rendered in Xcode; it is not presented as a pixel-identical implementation.

## Run on a Mac

Requires Xcode 16+ and iOS 17+. This ZIP is source-only, without a `.xcodeproj`.

1. Create an iOS App named `IstanbulHome`, SwiftUI, Swift, minimum iOS 17.
2. Replace the generated App file with `IstanbulHomeApp.swift` (only one `@main`). Add all root Swift files to the app target. In particular include the new `DistrictNetwork.swift` and `DistrictJourneyView.swift`.
3. Add `district-network.json`, `pilot-network.json` and `routes.json` to the app target / Copy Bundle Resources. Missing district data produces a visible setup error.
4. Merge the supplied Assets.xcassets sets into the project's asset catalogue: **CityScenes**, BeyogluHero and LandmarkAtlas. Copying Swift files alone will not update the artwork.
5. Run on an iPhone simulator. Test Beyoğlu → Kadıköy, the reverse, and Üsküdar → Pendik. Search for Adalar: it must show not covered and must not open external navigation.

The previous coordinate/landmark routing files are retained for later work and are not on the district home flow. If re-enabling GPS, add `NSLocationWhenInUseUsageDescription` to the app target Info; `LocationPrivacy.plist` is a snippet, not a bundle resource. No background tracking.

## Verification

Windows checks passed for 156 directed district pairs, explicit transfers, reverse connectivity, coordinates, source delimiters and required assets. These checks validate graph/data/package consistency; they do not execute Swift or render SwiftUI.

`Tests/DistrictNetworkTests.swift` contains 5 XCTest cases, including all supported pairs, M2/B1/M4 interchanges, reverse directions, a direct Marmaray trip and unsupported pairs. Add these only to a hosted Unit Test target, not the app target. Module name defaults to `IstanbulHome`. Tests and Xcode build have **not been run here**. The other test files concern retained previous features.

See `DISTRICT_DATA.md` for source dates and coverage limits. Previous pilot audit: `TRANSIT_DATA_AUDIT.md`.
