//
//  IncidentReporterViewModelTests.swift
//  SwiftChapterUSA Finder Tests
//
//  Created on April 30, 2026.
//

import XCTest
import Combine
@testable import SwiftChapterUSA_finder

@MainActor
class IncidentReporterViewModelTests: XCTestCase {
    var viewModel: IncidentReporterViewModel!
    var mockIncidentManager: MockIncidentManager!
    var mockAuthManager: AuthenticationManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        mockIncidentManager = MockIncidentManager()
        mockAuthManager = AuthenticationManager()
        viewModel = IncidentReporterViewModel(
            incidentManager: mockIncidentManager,
            authManager: mockAuthManager
        )
        cancellables = Set<AnyCancellable>()
        
        // Setup authenticated user
        mockAuthManager.register(
            email: "test@example.com",
            password: "password",
            firstName: "Test",
            lastName: "User",
            state: "California",
            university: "UCLA"
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockIncidentManager = nil
        mockAuthManager = nil
        cancellables = nil
        try await super.tearDown()
    }
    
    // MARK: - Form Validation Tests
    
    func testFormValidation_AllFieldsValid() {
        // Given
        viewModel.title = "Valid Title"
        viewModel.description = "This is a valid description with enough detail."
        viewModel.selectedUniversity = "UCLA"
        viewModel.incidentDate = Date()
        viewModel.selectedType = .professorBias
        viewModel.selectedSeverity = .moderate
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertTrue(isValid, "Form should be valid with all required fields")
        XCTAssertTrue(viewModel.validationErrors.isEmpty, "Should have no validation errors")
    }
    
    func testFormValidation_MissingTitle() {
        // Given
        viewModel.title = ""
        viewModel.description = "Valid description"
        viewModel.selectedUniversity = "UCLA"
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertFalse(isValid, "Form should be invalid without title")
        XCTAssertTrue(viewModel.validationErrors.contains("Title is required"), "Should have title error")
    }
    
    func testFormValidation_TitleTooShort() {
        // Given
        viewModel.title = "AB"
        viewModel.description = "Valid description"
        viewModel.selectedUniversity = "UCLA"
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertFalse(isValid, "Form should be invalid with short title")
        XCTAssertTrue(viewModel.validationErrors.contains(where: { $0.contains("at least 3 characters") }))
    }
    
    func testFormValidation_MissingDescription() {
        // Given
        viewModel.title = "Valid Title"
        viewModel.description = ""
        viewModel.selectedUniversity = "UCLA"
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertFalse(isValid, "Form should be invalid without description")
        XCTAssertTrue(viewModel.validationErrors.contains("Description is required"))
    }
    
    func testFormValidation_DescriptionTooShort() {
        // Given
        viewModel.title = "Valid Title"
        viewModel.description = "Short"
        viewModel.selectedUniversity = "UCLA"
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertFalse(isValid, "Form should be invalid with short description")
        XCTAssertTrue(viewModel.validationErrors.contains(where: { $0.contains("at least 20 characters") }))
    }
    
    func testFormValidation_MissingUniversity() {
        // Given
        viewModel.title = "Valid Title"
        viewModel.description = "Valid description with enough characters"
        viewModel.selectedUniversity = ""
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertFalse(isValid, "Form should be invalid without university")
        XCTAssertTrue(viewModel.validationErrors.contains("University is required"))
    }
    
    func testFormValidation_FuturDate() {
        // Given
        viewModel.title = "Valid Title"
        viewModel.description = "Valid description"
        viewModel.selectedUniversity = "UCLA"
        viewModel.incidentDate = Date().addingTimeInterval(86400) // Tomorrow
        
        // When
        let isValid = viewModel.isFormValid
        
        // Then
        XCTAssertFalse(isValid, "Form should be invalid with future date")
        XCTAssertTrue(viewModel.validationErrors.contains("Incident date cannot be in the future"))
    }
    
    // MARK: - Submission Tests
    
    func testSubmitIncident_Success() async {
        // Given
        viewModel.title = "Professor Bias"
        viewModel.description = "Professor made politically biased comments during lecture"
        viewModel.selectedUniversity = "UCLA"
        viewModel.selectedType = .professorBias
        viewModel.selectedSeverity = .moderate
        viewModel.incidentDate = Date()
        
        mockIncidentManager.createIncidentShouldSucceed = true
        
        // When
        await viewModel.submitIncident()
        
        // Then
        XCTAssertTrue(viewModel.showSuccessAlert, "Should show success alert")
        XCTAssertFalse(viewModel.isSubmitting, "Should not be submitting")
        XCTAssertNil(viewModel.errorMessage, "Should have no error message")
        XCTAssertEqual(mockIncidentManager.createIncidentCallCount, 1, "Should call createIncident once")
    }
    
    func testSubmitIncident_Failure() async {
        // Given
        viewModel.title = "Test Incident"
        viewModel.description = "Valid description with enough detail"
        viewModel.selectedUniversity = "UCLA"
        
        mockIncidentManager.createIncidentShouldSucceed = false
        mockIncidentManager.errorMessage = "Network error"
        
        // When
        await viewModel.submitIncident()
        
        // Then
        XCTAssertFalse(viewModel.showSuccessAlert, "Should not show success alert")
        XCTAssertFalse(viewModel.isSubmitting, "Should not be submitting")
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
    }
    
    func testSubmitIncident_InvalidForm() async {
        // Given
        viewModel.title = "" // Invalid
        viewModel.description = "Valid description"
        
        // When
        await viewModel.submitIncident()
        
        // Then
        XCTAssertFalse(viewModel.showSuccessAlert, "Should not show success alert")
        XCTAssertEqual(mockIncidentManager.createIncidentCallCount, 0, "Should not call createIncident")
    }
    
    func testSubmitIncident_SubmittingStateChanges() async {
        // Given
        viewModel.title = "Test"
        viewModel.description = "Valid description with enough detail"
        viewModel.selectedUniversity = "UCLA"
        
        var submittingStates: [Bool] = []
        viewModel.$isSubmitting
            .sink { submittingStates.append($0) }
            .store(in: &cancellables)
        
        mockIncidentManager.createIncidentShouldSucceed = true
        
        // When
        await viewModel.submitIncident()
        
        // Then
        XCTAssertTrue(submittingStates.contains(true), "Should be submitting at some point")
        XCTAssertFalse(viewModel.isSubmitting, "Should not be submitting when complete")
    }
    
    // MARK: - Anonymous Reporting Tests
    
    func testSubmitAnonymousIncident() async {
        // Given
        viewModel.title = "Anonymous Report"
        viewModel.description = "This is an anonymous incident report"
        viewModel.selectedUniversity = "UCLA"
        viewModel.isAnonymous = true
        viewModel.reporterName = "" // Should be ignored for anonymous
        
        mockIncidentManager.createIncidentShouldSucceed = true
        
        // When
        await viewModel.submitIncident()
        
        // Then
        XCTAssertTrue(viewModel.showSuccessAlert)
        if let createdIncident = mockIncidentManager.lastCreatedIncident {
            XCTAssertTrue(createdIncident.isAnonymous, "Incident should be marked anonymous")
            XCTAssertNil(createdIncident.reporterName, "Reporter name should be nil for anonymous")
        }
    }
    
    // MARK: - Evidence Upload Tests
    
    func testAddEvidence() {
        // Given
        let evidenceURL = "https://example.com/evidence.jpg"
        
        // When
        viewModel.evidenceURLs.append(evidenceURL)
        
        // Then
        XCTAssertEqual(viewModel.evidenceURLs.count, 1)
        XCTAssertEqual(viewModel.evidenceURLs.first, evidenceURL)
    }
    
    func testRemoveEvidence() {
        // Given
        viewModel.evidenceURLs = ["url1", "url2", "url3"]
        
        // When
        viewModel.evidenceURLs.remove(at: 1)
        
        // Then
        XCTAssertEqual(viewModel.evidenceURLs.count, 2)
        XCTAssertFalse(viewModel.evidenceURLs.contains("url2"))
    }
    
    // MARK: - Form Reset Tests
    
    func testResetForm() {
        // Given
        viewModel.title = "Test"
        viewModel.description = "Description"
        viewModel.selectedUniversity = "UCLA"
        viewModel.campusLocation = "Library"
        viewModel.perpetratorName = "Professor X"
        viewModel.evidenceURLs = ["url1", "url2"]
        
        // When
        viewModel.resetForm()
        
        // Then
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.description, "")
        XCTAssertEqual(viewModel.selectedUniversity, "")
        XCTAssertEqual(viewModel.campusLocation, "")
        XCTAssertEqual(viewModel.perpetratorName, "")
        XCTAssertTrue(viewModel.evidenceURLs.isEmpty)
        XCTAssertFalse(viewModel.isAnonymous)
    }
    
    // MARK: - Tag Management Tests
    
    func testAddTag() {
        // Given
        let tag = "censorship"
        
        // When
        viewModel.tags.append(tag)
        
        // Then
        XCTAssertTrue(viewModel.tags.contains(tag))
    }
    
    func testRemoveTag() {
        // Given
        viewModel.tags = ["tag1", "tag2", "tag3"]
        
        // When
        viewModel.tags.removeAll { $0 == "tag2" }
        
        // Then
        XCTAssertEqual(viewModel.tags.count, 2)
        XCTAssertFalse(viewModel.tags.contains("tag2"))
    }
}

// MARK: - Mock Incident Manager

class MockIncidentManager: IncidentManagerProtocol {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    var errorMessage: String?
    
    var createIncidentShouldSucceed = true
    var createIncidentCallCount = 0
    var lastCreatedIncident: Incident?
    
    func createIncident(_ incident: Incident) async -> Bool {
        createIncidentCallCount += 1
        lastCreatedIncident = incident
        
        if createIncidentShouldSucceed {
            incidents.append(incident)
            return true
        } else {
            errorMessage = "Failed to create incident"
            return false
        }
    }
    
    func fetchIncidents() async {
        isLoading = true
        defer { isLoading = false }
        // Mock implementation
    }
    
    func fetchIncidents(forState state: String) async -> [Incident] {
        return incidents.filter { $0.state == state }
    }
    
    func fetchIncidents(forUniversity university: String) async -> [Incident] {
        return incidents.filter { $0.universityName == university }
    }
    
    func fetchIncidents(ofType type: Incident.IncidentType) async -> [Incident] {
        return incidents.filter { $0.incidentType == type }
    }
    
    func fetchVerifiedIncidents() async -> [Incident] {
        return incidents.filter { $0.verificationStatus == .verified }
    }
    
    func updateIncident(_ incident: Incident) async -> Bool {
        return true
    }
    
    func deleteIncident(_ incident: Incident) async -> Bool {
        incidents.removeAll { $0.id == incident.id }
        return true
    }
    
    func incrementSupportCount(for incident: Incident) async -> Bool {
        return true
    }
    
    func getCampusStatistics(for university: String) async -> CampusStats? {
        let universityIncidents = incidents.filter { $0.universityName == university }
        guard !universityIncidents.isEmpty else { return nil }
        
        return CampusStats(
            universityName: university,
            state: universityIncidents.first?.state ?? "",
            city: universityIncidents.first?.city ?? "",
            coordinate: universityIncidents.first?.coordinate,
            totalIncidents: universityIncidents.count,
            verifiedIncidents: universityIncidents.filter { $0.isVerified }.count,
            criticalIncidents: universityIncidents.filter { $0.severity == .critical }.count,
            recentIncidents: universityIncidents.filter { $0.isRecent }.count
        )
    }
    
    func getAllCampusStatistics() async -> [CampusStats] {
        let universities = Set(incidents.map { $0.universityName })
        var stats: [CampusStats] = []
        
        for university in universities {
            if let stat = await getCampusStatistics(for: university) {
                stats.append(stat)
            }
        }
        
        return stats
    }
    
    func verifyIncident(_ incident: Incident, verifiedBy: String) async -> Bool {
        return true
    }
    
    func searchIncidents(query: String) async -> [Incident] {
        return incidents.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.description.localizedCaseInsensitiveContains(query)
        }
    }
}

// MARK: - Protocol Definition

protocol IncidentManagerProtocol: ObservableObject {
    var incidents: [Incident] { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    
    func createIncident(_ incident: Incident) async -> Bool
    func fetchIncidents() async
    func fetchIncidents(forState state: String) async -> [Incident]
    func fetchIncidents(forUniversity university: String) async -> [Incident]
    func fetchIncidents(ofType type: Incident.IncidentType) async -> [Incident]
    func fetchVerifiedIncidents() async -> [Incident]
    func updateIncident(_ incident: Incident) async -> Bool
    func deleteIncident(_ incident: Incident) async -> Bool
    func incrementSupportCount(for incident: Incident) async -> Bool
    func getCampusStatistics(for university: String) async -> CampusStats?
    func getAllCampusStatistics() async -> [CampusStats]
    func verifyIncident(_ incident: Incident, verifiedBy: String) async -> Bool
    func searchIncidents(query: String) async -> [Incident]
}
