import Foundation
import Combine

enum PilotLeg {
    case walk(from: String, to: String, path: WalkingPath)
    case ride(RailRide)
    var coordinates: [GeoPoint] {
        switch self { case .walk(_, _, let path): return path.coordinates; case .ride(let ride): return ride.indicativeGeometry }
    }
    var isWalking: Bool { if case .walk = self { return true }; return false }
}

struct PilotOption: Identifiable {
    let id: String
    let legs: [PilotLeg]
    var rides: [RailRide] { legs.compactMap { if case .ride(let ride) = $0 { return ride }; return nil } }
    var walkingMeters: Double { legs.reduce(0) { value, leg in if case .walk(_, _, let path) = leg { return value + path.distanceMeters }; return value } }
    var walkingSeconds: Double { legs.reduce(0) { value, leg in if case .walk(_, _, let path) = leg { return value + path.expectedSeconds }; return value } }
    var title: String { rides.isEmpty ? "Walk" : "Walk + " + rides.map(\.line.id).joined(separator: " + ") }
}

struct PilotPlan {
    let options: [PilotOption]
    let warnings: [String]
    let network: PilotNetwork
}

@MainActor
struct PilotRoutePlanner {
    let network: PilotNetwork
    let walking: any PilotWalkingProviding

    func plan(start: StartingPoint, destination: IstanbulPlace, departure: Date, walkingLimit: Double) async throws -> PilotPlan {
        let from = GeoPoint(latitude: start.latitude, longitude: start.longitude)
        let to = GeoPoint(latitude: destination.latitude, longitude: destination.longitude)
        guard network.coverage.contains(from), network.coverage.contains(to),
              network.supportedDestinationIDs.contains(destination.id) else { throw PilotRoutingError.outsidePilot }
        guard walkingLimit.isFinite && walkingLimit > 0 else { throw PilotRoutingError.data("Invalid walking limit.") }
        let timeZone = TimeZone(identifier: network.timezone)!
        var options: [PilotOption] = []
        var failedWalking = 0, filteredService = 0
        if from.distance(to: to) <= walkingLimit {
            do {
                let path = try await walking.route(from: from, to: to)
                if path.distanceMeters <= walkingLimit {
                    options.append(PilotOption(id: "walk", legs: [.walk(from: start.name, to: destination.name, path: path)]))
                }
            } catch {
                try Task.checkCancellation()
                failedWalking += 1
            }
        }
        let templates = PilotPathFinder.candidates(network: network, from: from, to: to, walkingLimit: walkingLimit)
        for template in templates {
            try Task.checkCancellation()
            do {
                let first = template.rides[0], last = template.rides.last!
                let access = try await walking.route(from: from, to: first.board.coordinate)
                guard access.distanceMeters <= walkingLimit else { continue }
                var earliest = departure.addingTimeInterval(access.expectedSeconds)
                var legs: [PilotLeg] = [.walk(from: start.name, to: first.board.name, path: access)]
                var valid = true
                for (index, ride) in template.rides.enumerated() {
                    guard ride.line.permitsEarliestBoarding(earliest, timeZone: timeZone) else {
                        filteredService += 1; valid = false; break
                    }
                    legs.append(.ride(ride))
                    // Only F1 has a current operator-published full ride time. T1/waits remain unknown.
                    if let seconds = ride.line.knownFullRideSeconds { earliest.addTimeInterval(seconds) }
                    if index + 1 < template.rides.count {
                        let next = template.rides[index + 1]
                        let transfer = try await walking.route(from: ride.alight.coordinate, to: next.board.coordinate)
                        guard transfer.distanceMeters <= min(template.transferLimit ?? 350, walkingLimit) else { valid = false; break }
                        legs.append(.walk(from: ride.alight.name + " (" + ride.line.id + ")",
                                          to: next.board.name + " (" + next.line.id + ")", path: transfer))
                        earliest.addTimeInterval(transfer.expectedSeconds)
                    }
                }
                guard valid else { continue }
                let egress = try await walking.route(from: last.alight.coordinate, to: to)
                guard egress.distanceMeters <= walkingLimit else { continue }
                legs.append(.walk(from: last.alight.name, to: destination.name, path: egress))
                options.append(PilotOption(id: template.id, legs: legs))
            } catch {
                try Task.checkCancellation()
                failedWalking += 1
            }
        }
        try Task.checkCancellation()
        guard !options.isEmpty else {
            let detail = failedWalking > 0
                ? "Some walking connections could not be retrieved from Apple Maps. Check your connection, retry, or increase the walking limit. No straight-line walking routes were substituted."
                : "No option meets the walking limit and conservative normal-hours filter. Increase the walking limit or choose a daytime departure."
            throw PilotRoutingError.noOptions(detail)
        }
        options.sort {
            if $0.rides.count != $1.rides.count { return $0.rides.count < $1.rides.count }
            return $0.walkingMeters < $1.walkingMeters
        }
        var warnings = [
            "Pilot: T1 Kabataş–Beyazıt and F1 only. Options favour fewer boardings, then less walking; not cheapest/fastest rankings.",
            "Normal operator hours: 06:00–00:00 Istanbul time. Exact departures, waiting times, service alerts and transfer arrivals are unverified. The final 30 minutes are conservatively excluded; that is an app policy, not an official last-train time.",
            "Transit geometry/stop centres come from an archived GTFS package. Stop order and general hours were cross-checked on \(network.checkedOn); entrances were not newly surveyed. Total journey time and fares are not calculated."
        ]
        if filteredService > 0 { warnings.append("Some transit candidates were omitted by the conservative service-window filter.") }
        if failedWalking > 0 { warnings.append("Some pedestrian connections failed to load; alternatives may be missing.") }
        if let accuracy = start.accuracyMeters, accuracy.isFinite, accuracy > 250, accuracy < Double(Int.max) {
            warnings.append("Your starting position is approximate (±\(Int(accuracy.rounded())) m). Nearby stop choices may differ; use a map pin to refine it.")
        }
        return PilotPlan(options: options, warnings: warnings, network: network)
    }
}

@MainActor
final class PilotRoutingModel: ObservableObject {
    @Published private(set) var plan: PilotPlan?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    private var provider: AppleWalkingDirections?
    private var revision = UUID()

    func load(request: PilotRoutingRequest, departure: Date, walkingLimit: Double) async {
        cancel()
        let token = UUID(); revision = token
        plan = nil; error = nil; isLoading = true
        let walking = AppleWalkingDirections(); provider = walking
        do {
            let network = try PilotNetwork.load()
            let result = try await PilotRoutePlanner(network: network, walking: walking)
                .plan(start: request.start, destination: request.destination, departure: departure, walkingLimit: walkingLimit)
            try Task.checkCancellation()
            guard token == revision else { return }
            plan = result; isLoading = false
        } catch {
            guard token == revision else { return }
            isLoading = false
            if !Task.isCancelled && !(error is CancellationError) { self.error = error.localizedDescription }
        }
    }
    func cancel() { revision = UUID(); provider?.cancel(); provider = nil; isLoading = false }
}
