//
//  IncidentManagerTests.swift
//  SwiftChapterUSA Finder Tests
//
//  Created on April 30, 2026.
//

import XCTest
import Combine
@testable import SwiftChapterUSA_finder

@MainActor
class IncidentManagerTests: XCTestCase {
    var incidentManager: IncidentManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        incidentManager = IncidentManager()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        incidentManager = nil
        cancellables = nil
        try await super.tearDown()
    }
    
    // MARK: - Incident Creation Tests
    
    func testCreateIncident_Success() async throws {
        // Given
        let incident = createSampleIncident()
        
        // When
        let result = await incidentManager.createIncident(incident)
        
        // Then
        XCTAssertTrue(result, "Incident creation should succeed")
        XCTAssertNil(incidentManager.errorMessage, "Error message should be nil on success")
    }
    
    func testCreateIncident_SetsCreatedDate() async throws {
        // Given
        var incident = createSampleIncident()
        let beforeDate = Date()
        
        // When
        _ = await incidentManager.createIncident(incident)
        
        // Then
        let afterDate = Date()
        XCTAssertTrue(incident.createdAt >= beforeDate)
        XCTAssertTrue(incident.createdAt <= afterDate)
    }
    
    // MARK: - Fetch Incidents Tests
    
    func testFetchIncidents_LoadingState() async throws {
        // Given
        var loadingStates: [Bool] = []
        incidentManager.$isLoading
            .sink { loadingStates.append($0) }
            .store(in: &cancellables)
        
        // When
        await incidentManager.fetchIncidents()
        
        // Then
        // Should have: false (initial), true (loading), false (completed)
        XCTAssertTrue(loadingStates.contains(true), "Should be loading at some point")
        XCTAssertFalse(incidentManager.isLoading, "Should not be loading when complete")
    }
    
    func testFetchIncidents_PopulatesArray() async throws {
        // Given
        let incident1 = createSampleIncident(title: "Incident 1")
        let incident2 = createSampleIncident(title: "Incident 2")
        
        await incidentManager.createIncident(incident1)
        await incidentManager.createIncident(incident2)
        
        // When
        await incidentManager.fetchIncidents()
        
        // Then
        XCTAssertGreaterThanOrEqual(incidentManager.incidents.count, 2, "Should fetch created incidents")
    }
    
    // MARK: - Filter Tests
    
    func testFetchIncidentsByState() async throws {
        // Given
        let californiaIncident = createSampleIncident(state: "California")
        let texasIncident = createSampleIncident(state: "Texas")
        
        await incidentManager.createIncident(californiaIncident)
        await incidentManager.createIncident(texasIncident)
        
        // When
        let results = await incidentManager.fetchIncidents(forState: "California")
        
        // Then
        XCTAssertGreaterThan(results.count, 0, "Should find California incidents")
        XCTAssertTrue(results.allSatisfy { $0.state == "California" }, "All results should be from California")
    }
    
    func testFetchIncidentsByUniversity() async throws {
        // Given
        let uclaIncident = createSampleIncident(university: "UCLA")
        let uscIncident = createSampleIncident(university: "USC")
        
        await incidentManager.createIncident(uclaIncident)
        await incidentManager.createIncident(uscIncident)
        
        // When
        let results = await incidentManager.fetchIncidents(forUniversity: "UCLA")
        
        // Then
        XCTAssertGreaterThan(results.count, 0, "Should find UCLA incidents")
        XCTAssertTrue(results.allSatisfy { $0.universityName == "UCLA" }, "All results should be from UCLA")
    }
    
    func testFetchIncidentsByType() async throws {
        // Given
        let biasIncident = createSampleIncident(type: .professorBias)
        let censorshipIncident = createSampleIncident(type: .speechCode)
        
        await incidentManager.createIncident(biasIncident)
        await incidentManager.createIncident(censorshipIncident)
        
        // When
        let results = await incidentManager.fetchIncidents(ofType: .professorBias)
        
        // Then
        XCTAssertGreaterThan(results.count, 0, "Should find professor bias incidents")
        XCTAssertTrue(results.allSatisfy { $0.incidentType == .professorBias })
    }
    
    func testFetchVerifiedIncidentsOnly() async throws {
        // Given
        var verifiedIncident = createSampleIncident(title: "Verified")
        verifiedIncident.verificationStatus = .verified
        
        var pendingIncident = createSampleIncident(title: "Pending")
        pendingIncident.verificationStatus = .pending
        
        await incidentManager.createIncident(verifiedIncident)
        await incidentManager.createIncident(pendingIncident)
        
        // When
        let results = await incidentManager.fetchVerifiedIncidents()
        
        // Then
        XCTAssertGreaterThan(results.count, 0, "Should find verified incidents")
        XCTAssertTrue(results.allSatisfy { $0.verificationStatus == .verified })
    }
    
    // MARK: - Update Tests
    
    func testUpdateIncident_Success() async throws {
        // Given
        var incident = createSampleIncident()
        _ = await incidentManager.createIncident(incident)
        
        // When
        incident.title = "Updated Title"
        incident.description = "Updated Description"
        let result = await incidentManager.updateIncident(incident)
        
        // Then
        XCTAssertTrue(result, "Update should succeed")
        XCTAssertNil(incidentManager.errorMessage)
    }
    
    func testUpdateIncident_UpdatesTimestamp() async throws {
        // Given
        var incident = createSampleIncident()
        _ = await incidentManager.createIncident(incident)
        let originalUpdatedAt = incident.updatedAt
        
        // Small delay to ensure timestamp difference
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // When
        incident.title = "Updated"
        _ = await incidentManager.updateIncident(incident)
        await incidentManager.fetchIncidents()
        
        // Then
        if let updated = incidentManager.incidents.first(where: { $0.id == incident.id }) {
            XCTAssertGreaterThan(updated.updatedAt, originalUpdatedAt, "Updated timestamp should be more recent")
        }
    }
    
    // MARK: - Delete Tests
    
    func testDeleteIncident_Success() async throws {
        // Given
        let incident = createSampleIncident()
        _ = await incidentManager.createIncident(incident)
        
        // When
        let result = await incidentManager.deleteIncident(incident)
        
        // Then
        XCTAssertTrue(result, "Delete should succeed")
    }
    
    func testDeleteIncident_RemovesFromList() async throws {
        // Given
        let incident = createSampleIncident()
        _ = await incidentManager.createIncident(incident)
        await incidentManager.fetchIncidents()
        let initialCount = incidentManager.incidents.count
        
        // When
        _ = await incidentManager.deleteIncident(incident)
        await incidentManager.fetchIncidents()
        
        // Then
        XCTAssertLessThan(incidentManager.incidents.count, initialCount, "Incident count should decrease")
        XCTAssertFalse(incidentManager.incidents.contains(where: { $0.id == incident.id }), "Deleted incident should not be in list")
    }
    
    // MARK: - Support/Vote Tests
    
    func testIncrementSupportCount() async throws {
        // Given
        var incident = createSampleIncident()
        _ = await incidentManager.createIncident(incident)
        let originalCount = incident.supportCount
        
        // When
        let result = await incidentManager.incrementSupportCount(for: incident)
        
        // Then
        XCTAssertTrue(result, "Support increment should succeed")
        
        await incidentManager.fetchIncidents()
        if let updated = incidentManager.incidents.first(where: { $0.id == incident.id }) {
            XCTAssertEqual(updated.supportCount, originalCount + 1, "Support count should increase by 1")
        }
    }
    
    // MARK: - Campus Statistics Tests
    
    func testGetCampusStatistics() async throws {
        // Given
        let ucla1 = createSampleIncident(university: "UCLA", severity: .high)
        let ucla2 = createSampleIncident(university: "UCLA", severity: .critical)
        let usc = createSampleIncident(university: "USC", severity: .low)
        
        await incidentManager.createIncident(ucla1)
        await incidentManager.createIncident(ucla2)
        await incidentManager.createIncident(usc)
        
        // When
        let stats = await incidentManager.getCampusStatistics(for: "UCLA")
        
        // Then
        XCTAssertNotNil(stats, "Should return statistics")
        XCTAssertEqual(stats?.universityName, "UCLA")
        XCTAssertGreaterThanOrEqual(stats?.totalIncidents ?? 0, 2, "Should have at least 2 incidents")
        XCTAssertGreaterThan(stats?.hostilityScore ?? 0, 0, "Hostility score should be calculated")
    }
    
    func testGetAllCampusStatistics() async throws {
        // Given
        await incidentManager.createIncident(createSampleIncident(university: "UCLA"))
        await incidentManager.createIncident(createSampleIncident(university: "USC"))
        await incidentManager.createIncident(createSampleIncident(university: "Berkeley"))
        
        // When
        let allStats = await incidentManager.getAllCampusStatistics()
        
        // Then
        XCTAssertGreaterThanOrEqual(allStats.count, 3, "Should have stats for at least 3 campuses")
        let universities = allStats.map { $0.universityName }
        XCTAssertTrue(universities.contains("UCLA"))
        XCTAssertTrue(universities.contains("USC"))
        XCTAssertTrue(universities.contains("Berkeley"))
    }
    
    func testCampusStatistics_HostilityScore() async throws {
        // Given - Create multiple severe incidents for one campus
        for i in 0..<5 {
            var incident = createSampleIncident(university: "Test University")
            incident.severity = .critical
            await incidentManager.createIncident(incident)
        }
        
        // When
        let stats = await incidentManager.getCampusStatistics(for: "Test University")
        
        // Then
        XCTAssertNotNil(stats)
        XCTAssertGreaterThan(stats?.hostilityScore ?? 0, 50, "Multiple critical incidents should create high hostility score")
    }
    
    // MARK: - Verification Tests
    
    func testVerifyIncident() async throws {
        // Given
        var incident = createSampleIncident()
        incident.verificationStatus = .pending
        _ = await incidentManager.createIncident(incident)
        
        // When
        let result = await incidentManager.verifyIncident(incident, verifiedBy: "admin@example.com")
        
        // Then
        XCTAssertTrue(result, "Verification should succeed")
        
        await incidentManager.fetchIncidents()
        if let verified = incidentManager.incidents.first(where: { $0.id == incident.id }) {
            XCTAssertEqual(verified.verificationStatus, .verified)
            XCTAssertEqual(verified.verifiedBy, "admin@example.com")
            XCTAssertNotNil(verified.verifiedDate)
        }
    }
    
    // MARK: - Search Tests
    
    func testSearchIncidents() async throws {
        // Given
        await incidentManager.createIncident(createSampleIncident(title: "Professor bias against conservative"))
        await incidentManager.createIncident(createSampleIncident(title: "Event cancelled by administration"))
        await incidentManager.createIncident(createSampleIncident(title: "Grade penalty for opinion"))
        
        // When
        let results = await incidentManager.searchIncidents(query: "professor")
        
        // Then
        XCTAssertGreaterThan(results.count, 0, "Should find incidents matching 'professor'")
        XCTAssertTrue(results.allSatisfy { incident in
            incident.title.lowercased().contains("professor") ||
            incident.description.lowercased().contains("professor")
        })
    }
    
    // MARK: - Helper Methods
    
    private func createSampleIncident(
        title: String = "Test Incident",
        university: String = "Test University",
        state: String = "California",
        type: Incident.IncidentType = .professorBias,
        severity: Incident.Severity = .moderate
    ) -> Incident {
        return Incident(
            title: title,
            description: "This is a test incident description.",
            incidentDate: Date().addingTimeInterval(-86400), // Yesterday
            universityName: university,
            campusLocation: "Main Building",
            city: "Los Angeles",
            state: state,
            latitude: 34.0689,
            longitude: -118.4452,
            incidentType: type,
            severity: severity,
            tags: ["test", "sample"],
            reporterEmail: "reporter@example.com",
            reporterName: "Test Reporter",
            isAnonymous: false
        )
    }
}
