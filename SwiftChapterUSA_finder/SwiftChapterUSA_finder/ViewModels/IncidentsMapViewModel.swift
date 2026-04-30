//
//  IncidentsMapViewModel.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import Foundation
import MapKit
import Combine

@MainActor
class IncidentsMapViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var incidents: [Incident] = []
    @Published var campusStats: [CampusStats] = []
    @Published var selectedIncident: Incident? {
        didSet {
            showIncidentDetail = selectedIncident != nil
        }
    }
    @Published var selectedCampus: CampusStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Filters
    @Published var searchText: String = "" {
        didSet { applyFilters() }
    }
    @Published var selectedState: String = "All States" {
        didSet { applyFilters() }
    }
    @Published var selectedType: Incident.IncidentType? {
        didSet { applyFilters() }
    }
    @Published var selectedSeverity: Incident.Severity? {
        didSet { applyFilters() }
    }
    @Published var showVerifiedOnly: Bool = false {
        didSet { applyFilters() }
    }
    
    // UI State
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Center of US
        span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
    )
    @Published var showIncidentDetail = false
    @Published var showFilter = false
    @Published var viewMode: ViewMode = .map
    
    // Filtered results
    @Published var filteredIncidents: [Incident] = []
    
    enum ViewMode {
        case map
        case list
        case statistics
    }
    
    // Dependencies
    private let incidentManager: any IncidentManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var availableStates: [String] {
        let states = Set(incidents.map { $0.state })
        return Array(states).sorted()
    }
    
    var incidentCount: Int {
        filteredIncidents.count
    }
    
    var verifiedIncidentCount: Int {
        filteredIncidents.filter { $0.isVerified }.count
    }
    
    var criticalIncidentCount: Int {
        filteredIncidents.filter { $0.severity == .critical }.count
    }
    
    // MARK: - Initialization
    
    init(incidentManager: any IncidentManagerProtocol) {
        self.incidentManager = incidentManager
        
        // Subscribe to incident manager changes
        if let manager = incidentManager as? IncidentManager {
            manager.$incidents
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newIncidents in
                    self?.incidents = newIncidents
                    self?.applyFilters()
                }
                .store(in: &cancellables)
            
            manager.$isLoading
                .receive(on: DispatchQueue.main)
                .assign(to: &$isLoading)
            
            manager.$errorMessage
                .receive(on: DispatchQueue.main)
                .assign(to: &$errorMessage)
        }
    }
    
    // MARK: - Data Fetching
    
    func fetchIncidents() async {
        await incidentManager.fetchIncidents()
        applyFilters()
    }
    
    func fetchCampusStatistics() async {
        let stats = await incidentManager.getAllCampusStatistics()
        campusStats = stats
    }
    
    func refreshData() async {
        await fetchIncidents()
        await fetchCampusStatistics()
    }
    
    // MARK: - Filtering
    
    private func applyFilters() {
        var filtered = incidents
        
        // Filter by search text
        if !searchText.isEmpty {
            let lowercaseSearch = searchText.lowercased()
            filtered = filtered.filter { incident in
                incident.title.lowercased().contains(lowercaseSearch) ||
                incident.description.lowercased().contains(lowercaseSearch) ||
                incident.universityName.lowercased().contains(lowercaseSearch) ||
                incident.tags.contains(where: { $0.lowercased().contains(lowercaseSearch) })
            }
        }
        
        // Filter by state
        if selectedState != "All States" {
            filtered = filtered.filter { $0.state == selectedState }
        }
        
        // Filter by type
        if let type = selectedType {
            filtered = filtered.filter { $0.incidentType == type }
        }
        
        // Filter by severity
        if let severity = selectedSeverity {
            filtered = filtered.filter { $0.severity == severity }
        }
        
        // Filter verified only
        if showVerifiedOnly {
            filtered = filtered.filter { $0.verificationStatus == .verified }
        }
        
        filteredIncidents = filtered
    }
    
    func clearFilters() {
        searchText = ""
        selectedState = "All States"
        selectedType = nil
        selectedSeverity = nil
        showVerifiedOnly = false
    }
    
    // MARK: - Map Functions
    
    func getMapRegion() -> MKCoordinateRegion {
        guard !filteredIncidents.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
            )
        }
        
        let coordinates = filteredIncidents.compactMap { $0.coordinate }
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
            )
        }
        
        // Calculate bounding box
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5, // Add 50% padding
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func focusOnIncident(_ incident: Incident) {
        guard let coordinate = incident.coordinate else { return }
        
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        selectedIncident = incident
    }
    
    func focusOnCampus(_ campus: CampusStats) {
        guard let coordinate = campus.coordinate else { return }
        
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        selectedCampus = campus
    }
    
    // MARK: - Heat Map
    
    struct HeatMapPoint: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let weight: Double // 0.0 to 1.0
        let incidentCount: Int
    }
    
    func getHeatMapPoints() -> [HeatMapPoint] {
        // Group incidents by location
        var locationGroups: [String: [Incident]] = [:]
        
        for incident in filteredIncidents {
            guard let coord = incident.coordinate else { continue }
            let key = "\(coord.latitude),\(coord.longitude)"
            locationGroups[key, default: []].append(incident)
        }
        
        // Find max count for normalization
        let maxCount = locationGroups.values.map { $0.count }.max() ?? 1
        
        // Create heat map points
        return locationGroups.compactMap { key, incidents in
            guard let coord = incidents.first?.coordinate else { return nil }
            
            let count = incidents.count
            let criticalCount = incidents.filter { $0.severity == .critical }.count
            let highCount = incidents.filter { $0.severity == .high }.count
            
            // Weight based on count and severity
            let baseWeight = Double(count) / Double(maxCount)
            let severityBonus = (Double(criticalCount) * 0.5 + Double(highCount) * 0.25) / Double(count)
            let weight = min(1.0, baseWeight + severityBonus)
            
            return HeatMapPoint(
                coordinate: coord,
                weight: weight,
                incidentCount: count
            )
        }
    }
    
    // MARK: - Statistics
    
    func getMostHostileCampuses(limit: Int = 10) -> [CampusStats] {
        Array(campusStats.prefix(limit))
    }
    
    func getCampusStats(for university: String) -> CampusStats? {
        campusStats.first { $0.universityName == university }
    }
    
    func getIncidentsGroupedByType() -> [(type: Incident.IncidentType, count: Int)] {
        let grouped = Dictionary(grouping: filteredIncidents) { $0.incidentType }
        return grouped.map { (type: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    func getIncidentsGroupedBySeverity() -> [(severity: Incident.Severity, count: Int)] {
        let grouped = Dictionary(grouping: filteredIncidents) { $0.severity }
        return grouped.map { (severity: $0.key, count: $0.value.count) }
            .sorted { $0.severity.priority > $1.severity.priority }
    }
    
    func getIncidentTrend(days: Int = 30) -> [Date: Int] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        
        let recentIncidents = filteredIncidents.filter { $0.incidentDate >= startDate }
        
        var trend: [Date: Int] = [:]
        for incident in recentIncidents {
            let day = calendar.startOfDay(for: incident.incidentDate)
            trend[day, default: 0] += 1
        }
        
        return trend
    }
    
    // MARK: - Actions
    
    func supportIncident(_ incident: Incident) async {
        _ = await incidentManager.incrementSupportCount(for: incident)
        await fetchIncidents()
    }
    
    func shareIncident(_ incident: Incident) -> String {
        """
        🚨 Free Speech Incident Report
        
        📍 \(incident.universityName), \(incident.state)
        📅 \(incident.incidentDate.formatted(date: .abbreviated, time: .omitted))
        ⚠️ Type: \(incident.incidentType.rawValue)
        🔴 Severity: \(incident.severity.rawValue)
        
        \(incident.title)
        
        \(incident.description)
        
        #FreeSpeech #TPUSA #CampusFreedom
        """
    }
}
