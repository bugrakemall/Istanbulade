import Foundation
import CoreLocation

struct GeoPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
    var isValid: Bool { latitude.isFinite && longitude.isFinite && CLLocationCoordinate2DIsValid(coordinate) }
    func distance(to other: GeoPoint) -> Double {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
}

struct PilotNetwork: Decodable {
    struct Coverage: Decodable {
        let south: Double, north: Double, west: Double, east: Double
        func contains(_ point: GeoPoint) -> Bool {
            point.isValid && (south...north).contains(point.latitude) && (west...east).contains(point.longitude)
        }
    }
    struct Stop: Decodable, Hashable, Identifiable {
        let id: String, sourceStopID: String, name: String
        let coordinate: GeoPoint
        let shapeDistanceMeters: Double
    }
    struct ShapePoint: Decodable {
        let coordinate: GeoPoint
        let distanceMeters: Double
    }
    struct Line: Decodable, Identifiable {
        let id: String, name: String, towardForward: String, towardReverse: String
        let openMinute: Int, closeMinute: Int
        let officialURL: String
        let knownFullRideSeconds: Double?
        let stops: [Stop]
        let shape: [ShapePoint]

        /// Conservative envelope, NOT a verified departure or last train time.
        func permitsEarliestBoarding(_ date: Date, timeZone: TimeZone) -> Bool {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone
            let minute = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
            // Last departures are unknown: suppress the final 30 min rather than promise a connection.
            if closeMinute > openMinute { return minute >= openMinute && minute < closeMinute - 30 }
            return minute >= openMinute || minute < closeMinute - 30
        }
    }
    struct Transfer: Decodable {
        let fromStopID: String, toStopID: String, sourceURL: String
        let maxWalkingMeters: Double
    }
    let checkedOn: String, timezone: String, geometryStatus: String, timetableStatus: String
    let attribution: String, licenseURL: String
    let coverage: Coverage
    let supportedDestinationIDs: [String]
    let sources: [String]
    let lines: [Line]
    let transfers: [Transfer]

    static func load() throws -> PilotNetwork {
        guard let url = Bundle.main.url(forResource: "pilot-network", withExtension: "json") else {
            throw PilotRoutingError.data("Add pilot-network.json to the app target's Copy Bundle Resources.")
        }
        let network = try JSONDecoder().decode(PilotNetwork.self, from: Data(contentsOf: url))
        try network.validate()
        return network
    }
    func validate() throws {
        let stops = lines.flatMap(\.stops)
        guard !lines.isEmpty, Set(lines.map(\.id)).count == lines.count,
              Set(stops.map(\.id)).count == stops.count,
              coverage.south <= coverage.north, coverage.west <= coverage.east,
              GeoPoint(latitude: coverage.south, longitude: coverage.west).isValid,
              GeoPoint(latitude: coverage.north, longitude: coverage.east).isValid,
              TimeZone(identifier: timezone) != nil else { throw PilotRoutingError.data("Invalid pilot network.") }
        for line in lines {
            guard line.stops.count >= 2, line.stops.allSatisfy({ $0.coordinate.isValid }),
                  line.shape.allSatisfy({ $0.coordinate.isValid && $0.distanceMeters.isFinite }),
                  line.stops.allSatisfy({ $0.shapeDistanceMeters.isFinite && $0.shapeDistanceMeters >= 0 }),
                  zip(line.stops, line.stops.dropFirst()).allSatisfy({ pair in pair.0.shapeDistanceMeters <= pair.1.shapeDistanceMeters }),
                  zip(line.shape, line.shape.dropFirst()).allSatisfy({ pair in pair.0.distanceMeters <= pair.1.distanceMeters }),
                  (0..<1440).contains(line.openMinute), (1...1440).contains(line.closeMinute) else {
                throw PilotRoutingError.data("Invalid line data: \(line.id)")
            }
        }
        for transfer in transfers {
            guard stops.contains(where: { $0.id == transfer.fromStopID }),
                  stops.contains(where: { $0.id == transfer.toStopID }),
                  transfer.maxWalkingMeters.isFinite, transfer.maxWalkingMeters > 0 else {
                throw PilotRoutingError.data("Invalid transfer data.")
            }
        }
    }
}

enum PilotRoutingError: LocalizedError {
    case data(String), outsidePilot, noOptions(String)
    var errorDescription: String? {
        switch self {
        case .data(let message): return message
        case .outsidePilot: return "This pilot covers Beyoğlu–Kabataş–Karaköy–Eminönü–Sultanahmet and Beyazıt only. Choose a start and tourist destination in that area."
        case .noOptions(let message): return message
        }
    }
}

struct PilotRoutingRequest: Identifiable {
    let id = UUID()
    let start: StartingPoint
    let destination: IstanbulPlace
}

struct RailRide {
    let line: PilotNetwork.Line
    let stops: [PilotNetwork.Stop]
    let direction: String
    var board: PilotNetwork.Stop { stops[0] }
    var alight: PilotNetwork.Stop { stops[stops.count - 1] }
    var indicativeGeometry: [GeoPoint] {
        let low = min(board.shapeDistanceMeters, alight.shapeDistanceMeters)
        let high = max(board.shapeDistanceMeters, alight.shapeDistanceMeters)
        var points = line.shape.filter { $0.distanceMeters > low && $0.distanceMeters < high }.map(\.coordinate)
        if board.shapeDistanceMeters > alight.shapeDistanceMeters { points.reverse() }
        return [board.coordinate] + points + [alight.coordinate]
    }
}

struct RailTemplate {
    let rides: [RailRide]
    let transferLimit: Double?
    var id: String { rides.map { "\($0.line.id):\($0.board.id)>\($0.alight.id)" }.joined(separator: "+") }
}

enum PilotPathFinder {
    static func ride(_ line: PilotNetwork.Line, from: String, to: String) -> RailRide? {
        guard let first = line.stops.firstIndex(where: { $0.id == from }),
              let last = line.stops.firstIndex(where: { $0.id == to }), first != last else { return nil }
        let stops = Array(line.stops[min(first, last)...max(first, last)])
        return RailRide(line: line, stops: first < last ? stops : Array(stops.reversed()),
                        direction: first < last ? line.towardForward : line.towardReverse)
    }

    static func candidates(network: PilotNetwork, from: GeoPoint, to: GeoPoint, walkingLimit: Double) -> [RailTemplate] {
        let stations = network.lines.flatMap { line in line.stops.map { (line, $0) } }
        // Distance is a lower bound for pruning only. Every retained foot leg is later routed by MapKit.
        let entries = stations.filter { from.distance(to: $0.1.coordinate) <= walkingLimit }
            .sorted { from.distance(to: $0.1.coordinate) < from.distance(to: $1.1.coordinate) }.prefix(3)
        let exits = stations.filter { to.distance(to: $0.1.coordinate) <= walkingLimit }
            .sorted { to.distance(to: $0.1.coordinate) < to.distance(to: $1.1.coordinate) }.prefix(3)
        var result: [RailTemplate] = []
        for (entryLine, entry) in entries {
            for (exitLine, exit) in exits {
                if entryLine.id == exitLine.id,
                   let direct = ride(entryLine, from: entry.id, to: exit.id) {
                    result.append(RailTemplate(rides: [direct], transferLimit: nil))
                }
                guard entryLine.id != exitLine.id else { continue }
                for transfer in network.transfers {
                    for pair in [(transfer.fromStopID, transfer.toStopID), (transfer.toStopID, transfer.fromStopID)] {
                        if let first = ride(entryLine, from: entry.id, to: pair.0),
                           let second = ride(exitLine, from: pair.1, to: exit.id) {
                            result.append(RailTemplate(rides: [first, second], transferLimit: transfer.maxWalkingMeters))
                        }
                    }
                }
            }
        }
        func score(_ template: RailTemplate) -> Double {
            from.distance(to: template.rides[0].board.coordinate)
                + to.distance(to: template.rides.last!.alight.coordinate)
                + Double(template.rides.count - 1) * 350
        }
        var ids = Set<String>()
        return Array(result.sorted { score($0) < score($1) }.filter { ids.insert($0.id).inserted }.prefix(6))
    }
}
