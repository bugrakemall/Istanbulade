import Foundation

struct DistrictNetwork: Decodable {
    struct Line: Decodable {
        let id: String
        let forward: String
        let reverse: String
        let stops: [String]
    }
    struct District: Decodable, Identifiable {
        var id: String { name }
        let name: String
        let latitude: Double
        let longitude: Double
        let stationIDs: [String]
        let artwork: String
        var point: GeoPoint { GeoPoint(latitude: latitude, longitude: longitude) }
    }
    struct Ride: Identifiable {
        let line: String
        let direction: String
        let stops: [String]
        var id: String { line + stops.joined(separator: ">") }
        let mapPoints: [GeoPoint]
    }
    struct Route {
        let from: District
        let to: District
        let rides: [Ride]
        var transfers: Int { max(0, rides.count - 1) }
        var stopCount: Int { rides.reduce(0) { $0 + $1.stops.count - 1 } }
    }
    let checkedOn: String
    let notes: String
    let sources: [String]
    let lines: [Line]
    let transfers: [[String]]
    let districts: [District]
    let mapReferences: [String: GeoPoint]

    static func load() throws -> DistrictNetwork {
        guard let url = Bundle.main.url(forResource: "district-network", withExtension: "json") else {
            throw PilotRoutingError.data("Add district-network.json to Copy Bundle Resources.")
        }
        let network = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
        try network.validate()
        return network
    }
    private struct Node { let line: Int; let index: Int }
    private var nodes: [String: Node] {
        var result: [String: Node] = [:]
        for (lineIndex, line) in lines.enumerated() {
            for index in line.stops.indices { result["\(line.id):\(index)"] = Node(line: lineIndex, index: index) }
        }
        return result
    }
    func validate() throws {
        guard !lines.isEmpty, Set(lines.map(\.id)).count == lines.count,
              lines.allSatisfy({ $0.stops.count >= 2 }),
              Set(districts.map(\.name)).count == districts.count else { throw PilotRoutingError.data("Invalid district network.") }
        let all = nodes
        guard mapReferences.values.allSatisfy({ $0.isValid }),
              districts.allSatisfy({ $0.point.isValid && !$0.stationIDs.isEmpty && $0.stationIDs.allSatisfy { all[$0] != nil && mapReferences[$0] != nil } }),
              transfers.allSatisfy({ $0.count == 2 && all[$0[0]] != nil && all[$0[1]] != nil && all[$0[0]]?.line != all[$0[1]]?.line }) else {
            throw PilotRoutingError.data("Invalid district references or transfers.")
        }
    }

    /// Dijkstra: fewer explicit transfers first, then fewer station hops. No duration/price claim.
    func route(from start: String, to end: String) -> Route? {
        guard start != end, let from = districts.first(where: { $0.name == start }),
              let to = districts.first(where: { $0.name == end }) else { return nil }
        let all = nodes
        struct Cost: Comparable {
            let transfers: Int
            let hops: Int
            static func < (a: Self, b: Self) -> Bool { a.transfers == b.transfers ? a.hops < b.hops : a.transfers < b.transfers }
        }
        var costs: [String: Cost] = [:], previous: [String: String] = [:]
        for id in from.stationIDs { costs[id] = Cost(transfers: 0, hops: 0) }
        var visited = Set<String>()
        var goal: String?
        while let current = costs.keys.filter({ !visited.contains($0) }).min(by: {
            costs[$0]! == costs[$1]! ? $0 < $1 : costs[$0]! < costs[$1]!
        }) {
            if to.stationIDs.contains(current) { goal = current; break }
            visited.insert(current)
            guard let node = all[current], let cost = costs[current] else { return nil }
            var adjacent: [(String, Bool)] = []
            for next in [node.index - 1, node.index + 1] where lines[node.line].stops.indices.contains(next) {
                adjacent.append(("\(lines[node.line].id):\(next)", false))
            }
            for pair in transfers {
                if pair[0] == current { adjacent.append((pair[1], true)) }
                if pair[1] == current { adjacent.append((pair[0], true)) }
            }
            for (next, transfer) in adjacent where !visited.contains(next) {
                let candidate = Cost(transfers: cost.transfers + (transfer ? 1 : 0), hops: cost.hops + (transfer ? 0 : 1))
                if costs[next] == nil || candidate < costs[next]! { costs[next] = candidate; previous[next] = current }
            }
        }
        guard let goal else { return nil }
        var path = [goal]
        while let parent = previous[path.last!] { path.append(parent) }
        path.reverse()
        var groups: [[Node]] = []
        for id in path {
            guard let node = all[id] else { return nil }
            if let last = groups.last?.last, last.line == node.line { groups[groups.count - 1].append(node) }
            else { groups.append([node]) }
        }
        let rides = groups.compactMap { group -> Ride? in
            guard let first = group.first, let last = group.last, group.count >= 2 else { return nil }
            let line = lines[first.line]
            let points = group.compactMap { mapReferences["\(line.id):\($0.index)"] }
            return Ride(line: line.id, direction: first.index < last.index ? line.forward : line.reverse, stops: group.map { line.stops[$0.index] }, mapPoints: points)
        }
        guard !rides.isEmpty else { return nil }
        return Route(from: from, to: to, rides: rides)
    }
}
