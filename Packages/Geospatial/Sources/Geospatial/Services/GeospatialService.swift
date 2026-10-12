//
//  GeospatialService.swift
//  Geospatial
//

import Foundation
import Common
import Combine
import Chapters

public class GeospatialService: ObservableObject {
    @Published public var userLocation: (latitude: Double, longitude: Double)?
    @Published public var nearbyChapters: [NearbyChapter] = []
    
    public init() {}
    
    public func updateUserLocation(latitude: Double, longitude: Double) {
        userLocation = (latitude, longitude)
    }
    
    public func findNearbyChapters(latitude: Double, longitude: Double, chapters: [Chapter], radiusInMiles: Double = 100) {
        let userCoords = (lat: latitude, lon: longitude)
        var nearby: [NearbyChapter] = []
        
        for chapter in chapters {
            // Use default coordinates for states/chapters if not specified
            if let chapterLat = chapter.latitude, let chapterLon = chapter.longitude {
                let distance = calculateDistance(from: userCoords, to: (lat: chapterLat, lon: chapterLon))
                
                if distance <= radiusInMiles {
                    let direction = calculateDirection(from: userCoords, to: (lat: chapterLat, lon: chapterLon))
                    nearby.append(NearbyChapter(
                        id: chapter.id,
                        name: chapter.displayName,
                        distance: distance,
                        latitude: chapterLat,
                        longitude: chapterLon,
                        direction: direction
                    ))
                }
            }
        }
        
        self.nearbyChapters = nearby.sorted { $0.distance < $1.distance }
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
    
    private func calculateDirection(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> String {
        let dLon = to.lon - from.lon
        let y = sin(dLon * .pi / 180) * cos(to.lat * .pi / 180)
        let x = cos(from.lat * .pi / 180) * sin(to.lat * .pi / 180) -
                sin(from.lat * .pi / 180) * cos(to.lat * .pi / 180) * cos(dLon * .pi / 180)
        let bearing = atan2(y, x) * 180 / .pi
        let normalizedBearing = fmod((bearing + 360), 360)
        
        if normalizedBearing < 22.5 || normalizedBearing >= 337.5 { return "N" }
        else if normalizedBearing < 67.5 { return "NE" }
        else if normalizedBearing < 112.5 { return "E" }
        else if normalizedBearing < 157.5 { return "SE" }
        else if normalizedBearing < 202.5 { return "S" }
        else if normalizedBearing < 247.5 { return "SW" }
        else if normalizedBearing < 292.5 { return "W" }
        else { return "NW" }
    }
}

public struct NearbyChapter: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let distance: Double
    public let latitude: Double
    public let longitude: Double
    public let direction: String
    
    public init(id: UUID, name: String, distance: Double, latitude: Double, longitude: Double, direction: String) {
        self.id = id
        self.name = name
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.direction = direction
    }
}
