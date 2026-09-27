//
//  GeospatialService.swift
//  Geospatial
//

import Foundation
import Common
import Combine

public class GeospatialService: ObservableObject {
    @Published public var userLocation: (latitude: Double, longitude: Double)?
    @Published public var nearbyChapters: [NearbyChapter] = []
    
    public init() {}
    
    public func updateUserLocation(latitude: Double, longitude: Double) {
        userLocation = (latitude, longitude)
    }
    
    public func findNearbyChapters(latitude: Double, longitude: Double, radiusInMiles: Double = 50) {
        // Placeholder for geospatial calculation
        nearbyChapters = []
    }
    
    public func calculateDistance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
        // Haversine formula for distance calculation
        let R: Double = 3959 // Earth's radius in miles
        let dLat = (to.lat - from.lat) * .pi / 180
        let dLon = (to.lon - from.lon) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(from.lat * .pi / 180) * cos(to.lat * .pi / 180) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }
}

public struct NearbyChapter: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let distance: Double
    public let latitude: Double
    public let longitude: Double
}
