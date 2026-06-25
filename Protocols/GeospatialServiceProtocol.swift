//
//  GeospatialServiceProtocol.swift
//  SwiftChapterUSA Finder
//
//  Protocol for geospatial operations to support dependency injection and testing.
//

import Foundation

protocol GeospatialServiceProtocol {
    /// Calculate distance between two coordinates in kilometers
    func distance(from: (lat: Double, lon: Double),
                  to: (lat: Double, lon: Double)) -> Double
    
    /// Index locations for spatial queries
    func indexLocations(chapters: [Chapter], events: [Event])
    
    /// Find nearby locations within a specified radius
    func findNearby(latitude: Double, longitude: Double,
                    radiusKm: Double) -> [Location]
    
    /// Find nearby chapters with distance information
    func findNearbyChapters(latitude: Double, longitude: Double,
                           radiusKm: Double) -> [(chapter: Chapter, distanceKm: Double)]
    
    /// Find nearby events with distance information
    func findNearbyEvents(latitude: Double, longitude: Double,
                         radiusKm: Double) -> [(event: Event, distanceKm: Double)]
    
    /// Calculate region statistics for all indexed locations
    func calculateRegionStatistics() -> [RegionStatistics]
    
    /// Rank chapters by engagement metrics
    func rankChapters(chapters: [Chapter], events: [Event]) -> [(chapter: Chapter, score: Double)]
}

// Extend GeospatialService to conform to protocol
extension GeospatialService: GeospatialServiceProtocol {
}
