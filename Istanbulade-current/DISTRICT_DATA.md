# District graph sources — 2026-10-17

- [Metro İstanbul M2](https://www.metro.istanbul/Hatlarimiz/HatDetay?hat=M2): main-line station order, Yenikapı–Marmaray interchange and branch warning verified. Seyrantepe is **not** inserted into the through line; the branch is omitted.
- [Metro İstanbul M4](https://www.metro.istanbul/Hatlarimiz/HatDetay?hat=M4): current station order and Ayrılık Çeşmesi–Marmaray interchange verified. Pendik metro is **not** treated as a same-station interchange with Pendik Marmaray.
- [TCDD Marmaray journey service](https://www.tcddtasimacilik.gov.tr/marmaray/tr/neredennereye): official operator reference. Its dynamically loaded station list was not readable through the research tool; it was not used to claim live timetable verification.
- [TCDD historical station infrastructure PDF](https://static.tcdd.gov.tr/webfiles/userfiles/files/3313.pdf): historical Marmaray station reference. The app contains the established Halkalı–Tuzla corridor as a static station-order subset, with no current departure claims. Newer stations beyond Tuzla and the whole Gebze section are excluded.

Data contains 76 line-specific nodes, two interchange pairs and 13 district references. Routes are between named representative rail stations, not administrative centroids and not the user's GPS location. Coordinates are approximate references, not surveyed entrances. Marmaray appears as B1 internally and Marmaray in the UI. The app uses its own locally authored station-connection graph, not Apple transit directions.

Shortest path cost is lexicographic: transfer count first, then station hops. Only this limited graph is searched. No inference that the result is fastest, cheapest or complete for all transport options. Ferry, bus, metrobus, other metro lines, walking access, timetable feasibility and fares are not calculated.

Map geometry is deliberately schematic: sparse reference points are connected with dashed lines. Do not interpret these as exact rails, pedestrian crossings, road directions or measured distances. Basemap is Apple Maps. CityScenes is a project-specific generated illustration atlas; its landmarks and ferries are artwork, not vehicles or geographic data.

`work/check-district-network.cjs` in the authoring workspace validates graph connectivity and static UI integration. XCTest is provided for executing the Swift search on a Mac. Neither source checks nor a generated design image replace an Xcode build or an actual device screenshot.
