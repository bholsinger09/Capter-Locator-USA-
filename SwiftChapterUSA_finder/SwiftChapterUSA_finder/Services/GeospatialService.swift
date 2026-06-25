//
//  GeospatialService.swift
//  SwiftChapterUSA Finder
//
//  Provides geospatial indexing, distance calculations, and location-based analytics.
//

import Foundation
import Combine

// MARK: - Models
struct Location: Identifiable, Codable, Hashable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let title: String
    let type: LocationType
    
    enum LocationType: String, Codable {
        case chapter, event, university
    }
}

struct RegionStatistics: Identifiable, Codable {
    let id: UUID = UUID()
    let state: String
    let centerLatitude: Double
    let centerLongitude: Double
    let chapterCount: Int
    let eventCount: Int
    let advocacyActionCount: Int
    let averageMemberCount: Int
}

struct HeatmapPoint: Identifiable, Codable {
    let id: UUID = UUID()
    let latitude: Double
    let longitude: Double
    let intensity: Double // 0.0 to 1.0
    let region: String
}

// MARK: - Quadtree Node for Spatial Indexing
class QuadtreeNode {
    let bounds: Bounds
    var locations: [Location] = []
    var children: [QuadtreeNode]?
    
    private let maxLocationsPerNode = 4
    
    struct Bounds {
        let minLat: Double
        let maxLat: Double
        let minLon: Double
        let maxLon: Double
        
        func contains(_ lat: Double, _ lon: Double) -> Bool {
            lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon
        }
        
        func intersects(_ other: Bounds) -> Bool {
            !(maxLat < other.minLat || minLat > other.maxLat ||
              maxLon < other.minLon || minLon > other.maxLon)
        }
    }
    
    init(bounds: Bounds) {
        self.bounds = bounds
    }
    
    func insert(_ location: Location) {
        guard bounds.contains(location.latitude, location.longitude) else { return }
        
        if children == nil {
            locations.append(location)
            
            if locations.count > maxLocationsPerNode {
                subdivide()
            }
        } else {
            for child in children! {
                child.insert(location)
            }
        }
    }
    
    private func subdivide() {
        let midLat = (bounds.minLat + bounds.maxLat) / 2
        let midLon = (bounds.minLon + bounds.maxLon) / 2
        
        children = [
            QuadtreeNode(bounds: Bounds(minLat: midLat, maxLat: bounds.maxLat,
                                       minLon: bounds.minLon, maxLon: midLon)),
            QuadtreeNode(bounds: Bounds(minLat: midLat, maxLat: bounds.maxLat,
                                       minLon: midLon, maxLon: bounds.maxLon)),
            QuadtreeNode(bounds: Bounds(minLat: bounds.minLat, maxLat: midLat,
                                       minLon: bounds.minLon, maxLon: midLon)),
            QuadtreeNode(bounds: Bounds(minLat: bounds.minLat, maxLat: midLat,
                                       minLon: midLon, maxLon: bounds.maxLon))
        ]
        
        let existingLocations = locations
        locations.removeAll()
        
        for location in existingLocations {
            for child in children! {
                child.insert(location)
            }
        }
    }
    
    func query(bounds: Bounds) -> [Location] {
        guard bounds.intersects(self.bounds) else { return [] }
        
        var result: [Location] = []
        
        if children == nil {
            result.append(contentsOf: locations.filter { loc in
                bounds.contains(loc.latitude, loc.longitude)
            })
        } else {
            for child in children! {
                result.append(contentsOf: child.query(bounds: bounds))
            }
        }
        
        return result
    }
}

// MARK: - Geospatial Service
class GeospatialService: ObservableObject {
    @Published var nearbyLocations: [Location] = []
    @Published var regionStatistics: [RegionStatistics] = []
    @Published var heatmapData: [HeatmapPoint] = []
    @Published var isLoadingLocation = false
    
    private var quadtree: QuadtreeNode
    private var chapters: [Chapter] = []
    private var events: [Event] = []
    
    // Constants
    private let earthRadiusKm = 6371.0
    
    // US Bounds for quadtree
    private let usBounds = QuadtreeNode.Bounds(
        minLat: 24.5, maxLat: 49.4,
        minLon: -125.0, maxLon: -66.9
    )
    
    init() {
        self.quadtree = QuadtreeNode(bounds: usBounds)
    }
    
    // MARK: - Distance Calculation
    /// Calculates distance between two coordinates using Haversine formula (in kilometers)
    func distance(from: (lat: Double, lon: Double),
                  to: (lat: Double, lon: Double)) -> Double {
        let lat1 = from.lat.toRadians()
        let lat2 = to.lat.toRadians()
        let deltaLat = (to.lat - from.lat).toRadians()
        let deltaLon = (to.lon - from.lon).toRadians()
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }
    
    // MARK: - Spatial Indexing
    /// Rebuild spatial index with chapters and events
    func indexLocations(chapters: [Chapter], events: [Event]) {
        self.chapters = chapters
        self.events = events
        
        quadtree = QuadtreeNode(bounds: usBounds)
        
        // Index chapters
        for chapter in chapters {
            if let lat = chapter.latitude, let lon = chapter.longitude {
                let location = Location(
                    id: chapter.id,
                    latitude: lat,
                    longitude: lon,
                    title: chapter.displayName,
                    type: .chapter
                )
                quadtree.insert(location)
            }
        }
        
        // Index events
        for event in events {
            if let lat = event.latitude, let lon = event.longitude {
                let location = Location(
                    id: event.id,
                    latitude: lat,
                    longitude: lon,
                    title: event.title,
                    type: .event
                )
                quadtree.insert(location)
            }
        }
        
        generateHeatmap()
    }
    
    // MARK: - Nearby Search
    /// Find chapters and events within specified radius (in km) from a location
    func findNearby(latitude: Double, longitude: Double,
                    radiusKm: Double) -> [Location] {
        let latDelta = (radiusKm / earthRadiusKm).toDegrees()
        let lonDelta = (radiusKm / (earthRadiusKm * cos((latitude).toRadians()))).toDegrees()
        
        let bounds = QuadtreeNode.Bounds(
            minLat: latitude - latDelta,
            maxLat: latitude + latDelta,
            minLon: longitude - lonDelta,
            maxLon: longitude + lonDelta
        )
        
        let candidates = quadtree.query(bounds: bounds)
        
        // Filter by actual distance
        return candidates.filter { location in
            distance(from: (latitude, longitude),
                    to: (location.latitude, location.longitude)) <= radiusKm
        }.sorted { loc1, loc2 in
            let dist1 = distance(from: (latitude, longitude),
                               to: (loc1.latitude, loc1.longitude))
            let dist2 = distance(from: (latitude, longitude),
                               to: (loc2.latitude, loc2.longitude))
            return dist1 < dist2
        }
    }
    
    /// Find nearby chapters with additional details
    func findNearbyChapters(latitude: Double, longitude: Double,
                           radiusKm: Double) -> [(chapter: Chapter, distanceKm: Double)] {
        let nearby = findNearby(latitude: latitude, longitude: longitude, radiusKm: radiusKm)
        
        return nearby.compactMap { location in
            guard let chapter = chapters.first(where: { $0.id == location.id }) else {
                return nil
            }
            let dist = distance(from: (latitude, longitude),
                              to: (location.latitude, location.longitude))
            return (chapter: chapter, distanceKm: dist)
        }
    }
    
    /// Find nearby events with additional details
    func findNearbyEvents(latitude: Double, longitude: Double,
                         radiusKm: Double) -> [(event: Event, distanceKm: Double)] {
        let nearby = findNearby(latitude: latitude, longitude: longitude, radiusKm: radiusKm)
        
        return nearby.compactMap { location in
            guard let event = events.first(where: { $0.id == location.id }) else {
                return nil
            }
            let dist = distance(from: (latitude, longitude),
                              to: (location.latitude, location.longitude))
            return (event: event, distanceKm: dist)
        }
    }
    
    // MARK: - Regional Analytics
    /// Calculate statistics for each state/region
    func calculateRegionStatistics() -> [RegionStatistics] {
        let states = Set(chapters.map { $0.state })
        
        return states.map { state in
            let stateChapters = chapters.filter { $0.state == state }
            let stateEvents = events.filter { $0.state == state }
            
            let avgLat = stateChapters.compactMap { $0.latitude }.reduce(0, +) /
                        Double(max(stateChapters.count, 1))
            let avgLon = stateChapters.compactMap { $0.longitude }.reduce(0, +) /
                        Double(max(stateChapters.count, 1))
            
            let avgMembers = stateChapters.isEmpty ? 0 :
                            stateChapters.map { $0.memberCount }.reduce(0, +) / stateChapters.count
            
            return RegionStatistics(
                state: state,
                centerLatitude: avgLat,
                centerLongitude: avgLon,
                chapterCount: stateChapters.count,
                eventCount: stateEvents.count,
                advocacyActionCount: stateChapters.reduce(0) { $0 + $1.memberCount / 10 },
                averageMemberCount: avgMembers
            )
        }
    }
    
    // MARK: - Heatmap Generation
    /// Generate heatmap points based on chapter and event density
    private func generateHeatmap() {
        let states = Set(chapters.map { $0.state })
        
        var points: [HeatmapPoint] = []
        
        for state in states {
            let stateChapters = chapters.filter { $0.state == state }
            let stateEvents = events.filter { $0.state == state }
            
            let totalActivity = stateChapters.count + stateEvents.count
            
            // Create multiple heatmap points for regions with high activity
            let chapterLocations = stateChapters.compactMap { chapter -> (lat: Double, lon: Double)? in
                guard let lat = chapter.latitude, let lon = chapter.longitude else { return nil }
                return (lat, lon)
            }
            
            // Cluster locations into grid cells
            let intensity = Double(min(totalActivity, 100)) / 100.0
            
            if let centerLat = stateChapters.compactMap({ $0.latitude }).average(),
               let centerLon = stateChapters.compactMap({ $0.longitude }).average() {
                points.append(HeatmapPoint(
                    latitude: centerLat,
                    longitude: centerLon,
                    intensity: intensity,
                    region: state
                ))
            }
        }
        
        self.heatmapData = points
    }
    
    // MARK: - Ranking Algorithms
    /// Rank chapters by engagement (members + recent events)
    func rankChapters(chapters: [Chapter], events: [Event]) -> [(chapter: Chapter, score: Double)] {
        return chapters.map { chapter in
            let memberScore = Double(chapter.memberCount) / 100.0 // Normalize
            let eventCount = events.filter { $0.chapterID == chapter.id }.count
            let eventScore = Double(eventCount) * 2.0 // Weight events higher
            
            let totalScore = memberScore + eventScore
            return (chapter: chapter, score: totalScore)
        }.sorted { $0.score > $1.score }
    }
}

// MARK: - Helper Extensions
extension Double {
    func toRadians() -> Double {
        self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        self * 180.0 / .pi
    }
}

extension Array where Element == Double {
    func average() -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}
