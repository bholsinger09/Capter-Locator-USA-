//
//  IncidentsMapViewModelTests.swift
//  SwiftChapterUSA Finder Tests
//
//  Created on April 30, 2026.
//

import XCTest
import MapKit
import Combine
@testable import SwiftChapterUSA_finder

@MainActor
class IncidentsMapViewModelTests: XCTestCase {
    var viewModel: IncidentsMapViewModel!
    var mockIncidentManager: MockIncidentManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        mockIncidentManager = MockIncidentManager()
        viewModel = IncidentsMapViewModel(incidentManager: mockIncidentManager)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockIncidentManager = nil
        cancellables = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.selectedState, "All States")
        XCTAssertNil(viewModel.selectedType)
        XCTAssertFalse(viewModel.showVerifiedOnly)
    }
    
    // MARK: - Fetch Tests
    
    func testFetchIncidents() async {
        // Given
        let incident1 = createSampleIncident(university: "UCLA", latitude: 34.0689, longitude: -118.4452)
        let incident2 = createSampleIncident(university: "USC", latitude: 34.0224, longitude: -118.2851)
        mockIncidentManager.incidents = [incident1, incident2]
        
        // When
        await viewModel.fetchIncidents()
        
        // Then
        XCTAssertEqual(viewModel.filteredIncidents.count, 2)
    }
    
    func testFetchCampusStatistics() async {
        // Given
        let ucla1 = create SampleIncident(university: "UCLA", severity: .high)
        let ucla2 = createSampleIncident(university: "UCLA", severity: .critical)
        let usc = createSampleIncident(university: "USC", severity: .moderate)
        mockIncidentManager.incidents = [ucla1, ucla2, usc]
        
        // When
        await viewModel.fetchCampusStatistics()
        
        // Then
        XCTAssertGreaterThanOrEqual(viewModel.campusStats.count, 2)
        let uclaStats = viewModel.campusStats.first { $0.universityName == "UCLA" }
        XCTAssertNotNil(uclaStats)
        XCTAssertEqual(uclaStats?.totalIncidents, 2)
    }
    
    // MARK: - Filtering Tests
    
    func testFilterByState() async {
        // Given
        let california = createSampleIncident(state: "California", university: "UCLA")
        let texas = createSampleIncident(state: "Texas", university: "UT Austin")
        mockIncidentManager.incidents = [california, texas]
        
        // When
        viewModel.selectedState = "California"
        await viewModel.fetchIncidents()
        
        // Then
        let filtered = viewModel.filteredIncidents
        XCTAssertTrue(filtered.allSatisfy { $0.state == "California" })
    }
    
    func testFilterByType() async {
        // Given
        let biasIncident = createSampleIncident(type: .professorBias)
        let censorshipIncident = createSampleIncident(type: .speechCode)
        mockIncidentManager.incidents = [biasIncident, censorshipIncident]
        
        // When
        viewModel.selectedType = .professorBias
        await viewModel.fetchIncidents()
        
        // Then
        let filtered = viewModel.filteredIncidents
        XCTAssertTrue(filtered.allSatisfy { $0.incidentType == .professorBias })
    }
    
    func testFilterVerifiedOnly() async {
        // Given
        var verified = createSampleIncident(title: "Verified")
        verified.verificationStatus = .verified
        
        var pending = createSampleIncident(title: "Pending")
        pending.verificationStatus = .pending
        
        mockIncidentManager.incidents = [verified, pending]
        
        // When
        viewModel.showVerifiedOnly = true
        await viewModel.fetchIncidents()
        
        // Then
        let filtered = viewModel.filteredIncidents
        XCTAssertTrue(filtered.allSatisfy { $0.verificationStatus == .verified })
    }
    
    func testFilterBySeverity() async {
        // Given
        let low = createSampleIncident(severity: .low)
        let moderate = createSampleIncident(severity: .moderate)
        let high = createSampleIncident(severity: .high)
        let critical = createSampleIncident(severity: .critical)
        
        mockIncidentManager.incidents = [low, moderate, high, critical]
        
        // When
        viewModel.selectedSeverity = .high
        await viewModel.fetchIncidents()
        
        // Then
        let filtered = viewModel.filteredIncidents
        XCTAssertTrue(filtered.allSatisfy { $0.severity == .high })
    }
    
    func testCombinedFilters() async {
        // Given
        var match = createSampleIncident(state: "California", type: .professorBias, severity: .high)
        match.verificationStatus = .verified
        
        let wrongState = createSampleIncident(state: "Texas", type: .professorBias, severity: .high)
        let wrongType = createSampleIncident(state: "California", type: .speechCode, severity: .high)
        let wrongSeverity = createSampleIncident(state: "California", type: .professorBias, severity: .low)
        
        mockIncidentManager.incidents = [match, wrongState, wrongType, wrongSeverity]
        
        // When
        viewModel.selectedState = "California"
        viewModel.selectedType = .professorBias
        viewModel.selectedSeverity = .high
        viewModel.showVerifiedOnly = true
        await viewModel.fetchIncidents()
        
        // Then
        let filtered = viewModel.filteredIncidents
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, match.id)
    }
    
    // MARK: - Search Tests
    
    func testSearchByKeyword() async {
        // Given
        let relevant = createSampleIncident(title: "Professor bias in statistics class")
        let irrelevant = createSampleIncident(title: "Event cancelled")
        mockIncidentManager.incidents = [relevant, irrelevant]
        
        // When
        viewModel.searchText = "professor"
        await viewModel.fetchIncidents()
        
        // Then
        let filtered = viewModel.filteredIncidents
        XCTAssertGreaterThan(filtered.count, 0)
        XCTAssertTrue(filtered.contains(where: { $0.id == relevant.id }))
    }
    
    // MARK: - Map Region Tests
    
    func testGetMapRegionForAllIncidents() async {
        // Given
        let la = createSampleIncident(university: "UCLA", latitude: 34.0689, longitude: -118.4452)
        let sf = createSampleIncident(university: "Berkeley", latitude: 37.8715, longitude: -122.2730)
        mockIncidentManager.incidents = [la, sf]
        
        // When
        await viewModel.fetchIncidents()
        let region = viewModel.getMapRegion()
        
        // Then
        XCTAssertNotNil(region)
        // Region should encompass both locations
        XCTAssertGreaterThan(region.span.latitudeDelta, 0)
        XCTAssertGreaterThan(region.span.longitudeDelta, 0)
    }
    
    func testGetMapRegionForState() async {
        // Given
        let la = createSampleIncident(state: "California", latitude: 34.0689, longitude: -118.4452)
        let sf = createSampleIncident(state: "California", latitude: 37.8715, longitude: -122.2730)
        mockIncidentManager.incidents = [la, sf]
        
        // When
        viewModel.selectedState = "California"
        await viewModel.fetchIncidents()
        let region = viewModel.getMapRegion()
        
        // Then
        XCTAssertNotNil(region)
    }
    
    // MARK: - Campus Statistics Tests
    
    func testCampusStatsAreSortedByHostility() async {
        // Given
        var lowIncident = createSampleIncident(university: "Low University", severity: .low)
        var highIncident1 = createSampleIncident(university: "High University", severity: .critical)
        var highIncident2 = createSampleIncident(university: "High University", severity: .critical)
        
        mockIncidentManager.incidents = [lowIncident, highIncident1, highIncident2]
        
        // When
        await viewModel.fetchCampusStatistics()
        
        // Then
        XCTAssertGreaterThan(viewModel.campusStats.count, 0)
        // First stats should be most hostile
        if viewModel.campusStats.count >= 2 {
            let first = viewModel.campusStats[0]
            let second = viewModel.campusStats[1]
            XCTAssertGreaterThanOrEqual(first.hostilityScore, second.hostilityScore)
        }
    }
    
    func testGetStatsForSpecificCampus() async {
        // Given
        let ucla1 = createSampleIncident(university: "UCLA", severity: .high)
        let ucla2 = createSampleIncident(university: "UCLA", severity: .moderate)
        mockIncidentManager.incidents = [ucla1, ucla2]
        
        // When
        await viewModel.fetchCampusStatistics()
        let stats = viewModel.campusStats.first { $0.universityName == "UCLA" }
        
        // Then
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.totalIncidents, 2)
        XCTAssertEqual(stats?.universityName, "UCLA")
    }
    
    // MARK: - Selection Tests
    
    func testSelectIncident() {
        // Given
        let incident = createSampleIncident()
        
        // When
        viewModel.selectedIncident = incident
        
        // Then
        XCTAssertEqual(viewModel.selectedIncident?.id, incident.id)
        XCTAssertTrue(viewModel.showIncidentDetail)
    }
    
    func testDeselectIncident() {
        // Given
        viewModel.selectedIncident = createSampleIncident()
        viewModel.showIncidentDetail = true
        
        // When
        viewModel.selectedIncident = nil
        
        // Then
        XCTAssertNil(viewModel.selectedIncident)
        XCTAssertFalse(viewModel.showIncidentDetail)
    }
    
    // MARK: - State-Specific Tests
    
    func testGetAvailableStates() async {
        // Given
        mockIncidentManager.incidents = [
            createSampleIncident(state: "California"),
            createSampleIncident(state: "California"),
            createSampleIncident(state: "Texas"),
            createSampleIncident(state: "Florida")
        ]
        
        // When
        await viewModel.fetchIncidents()
        let states = viewModel.availableStates
        
        // Then
        XCTAssertTrue(states.contains("California"))
        XCTAssertTrue(states.contains("Texas"))
        XCTAssertTrue(states.contains("Florida"))
        XCTAssertEqual(Set(states).count, 3) // Should have 3 unique states
    }
    
    // MARK: - Heat Map Tests
    
    func testGenerateHeatMapData() async {
        // Given - Multiple incidents at same location
        let incident1 = createSampleIncident(university: "UCLA", latitude: 34.0689, longitude: -118.4452)
        let incident2 = createSampleIncident(university: "UCLA", latitude: 34.0689, longitude: -118.4452)
        let incident3 = createSampleIncident(university: "UCLA", latitude: 34.0689, longitude: -118.4452)
        
        mockIncidentManager.incidents = [incident1, incident2, incident3]
        
        // When
        await viewModel.fetchIncidents()
        let heatMapPoints = viewModel.getHeatMapPoints()
        
        // Then
        XCTAssertGreaterThan(heatMapPoints.count, 0)
        // Should have weighted points based on incident count
    }
    
    // MARK: - Helper Methods
    
    private func createSampleIncident(
        title: String = "Test Incident",
        university: String = "Test University",
        state: String = "California",
        type: Incident.IncidentType = .professorBias,
        severity: Incident.Severity = .moderate,
        latitude: Double? = 34.0689,
        longitude: Double? = -118.4452
    ) -> Incident {
        return Incident(
            title: title,
            description: "Test description",
            incidentDate: Date(),
            universityName: university,
            city: "Los Angeles",
            state: state,
            latitude: latitude,
            longitude: longitude,
            incidentType: type,
            severity: severity,
            reporterEmail: "test@example.com"
        )
    }
}
