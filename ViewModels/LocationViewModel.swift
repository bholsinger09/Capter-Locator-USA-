//
//  LocationViewModel.swift
//  SwiftChapterUSA Finder
//
//  ViewModel for location-based features and analytics.
//

import SwiftUI
import Combine
import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var nearbyChapters: [(chapter: Chapter, distanceKm: Double)] = []
    @Published var nearbyEvents: [(event: Event, distanceKm: Double)] = []
    @Published var regionStats: [RegionStatistics] = []
    @Published var heatmapData: [HeatmapPoint] = []
    @Published var rankedChapters: [(chapter: Chapter, score: Double)] = []
    @Published var isLoadingLocation = false
    @Published var selectedRadius: Double = 50 // km
    @Published var errorMessage: String?
    
    private var locationManager: CLLocationManager
    private let geospatialService: GeospatialService
    private var cancellables = Set<AnyCancellable>()
    
    init(geospatialService: GeospatialService) {
        self.geospatialService = geospatialService
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Subscribe to geospatial service updates
        geospatialService.$heatmapData
            .assign(to: &$heatmapData)
        
        geospatialService.$regionStatistics
            .assign(to: &$regionStatistics)
    }
    
    // MARK: - Location Permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        isLoadingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLoadingLocation = false
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            isLoadingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
            self.isLoadingLocation = false
        }
    }
    
    // MARK: - Geospatial Queries
    func updateNearbyLocations(chapters: [Chapter], events: [Event]) {
        geospatialService.indexLocations(chapters: chapters, events: events)
        
        guard let userLoc = userLocation else {
            errorMessage = "User location not available"
            return
        }
        
        nearbyChapters = geospatialService.findNearbyChapters(
            latitude: userLoc.latitude,
            longitude: userLoc.longitude,
            radiusKm: selectedRadius
        )
        
        nearbyEvents = geospatialService.findNearbyEvents(
            latitude: userLoc.latitude,
            longitude: userLoc.longitude,
            radiusKm: selectedRadius
        )
    }
    
    func updateRegionStatistics(chapters: [Chapter], events: [Event]) {
        geospatialService.indexLocations(chapters: chapters, events: events)
        regionStats = geospatialService.calculateRegionStatistics()
    }
    
    func calculateRankedChapters(chapters: [Chapter], events: [Event]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let ranked = self.geospatialService.rankChapters(chapters: chapters, events: events)
            DispatchQueue.main.async {
                self.rankedChapters = ranked
            }
        }
    }
    
    func getRankedChapters(chapters: [Chapter], events: [Event]) -> [(chapter: Chapter, score: Double)] {
        geospatialService.indexLocations(chapters: chapters, events: events)
        return geospatialService.rankChapters(chapters: chapters, events: events)
    }
    
    // MARK: - Helper Methods
    func distanceString(_ km: Double) -> String {
        if km < 1.0 {
            return String(format: "%.0f m", km * 1000)
        } else {
            return String(format: "%.1f km", km)
        }
    }
    
    func radiusOptions() -> [Double] {
        [5, 10, 25, 50, 100, 200]
    }
}
