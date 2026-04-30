//
//  IncidentReporterViewModel.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import Foundation
import Combine

@MainActor
class IncidentReporterViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Basic Information
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var incidentDate: Date = Date()
    
    // Location
    @Published var selectedUniversity: String = ""
    @Published var campusLocation: String = ""
    @Published var selectedState: String = ""
    @Published var city: String = ""
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    // Classification
    @Published var selectedType: Incident.IncidentType = .professorBias
    @Published var selectedSeverity: Incident.Severity = .moderate
    @Published var tags: [String] = []
    
    // People Involved
    @Published var targetedIndividual: String = ""
    @Published var perpetratorName: String = ""
    @Published var perpetratorRole: String = ""
    @Published var witnesses: [String] = []
    
    // Evidence
    @Published var evidenceURLs: [String] = []
    @Published var evidenceDescription: String = ""
    @Published var newsArticleURLs: [String] = []
    
    // Reporter Information
    @Published var reporterName: String = ""
    @Published var isAnonymous: Bool = false
    
    // UI State
    @Published var isSubmitting: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var errorMessage: String?
    @Published var validationErrors: [String] = []
    
    // Dependencies
    private let incidentManager: any IncidentManagerProtocol
    private let authManager: AuthenticationManager
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        validationErrors = []
        
        // Title validation
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Title is required")
        } else if title.count < 3 {
            validationErrors.append("Title must be at least 3 characters")
        }
        
        // Description validation
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Description is required")
        } else if description.count < 20 {
            validationErrors.append("Description must be at least 20 characters")
        }
        
        // University validation
        if selectedUniversity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("University is required")
        }
        
        // Date validation
        if incidentDate > Date() {
            validationErrors.append("Incident date cannot be in the future")
        }
        
        return validationErrors.isEmpty
    }
    
    // MARK: - Initialization
    
    init(incidentManager: any IncidentManagerProtocol, authManager: AuthenticationManager) {
        self.incidentManager = incidentManager
        self.authManager = authManager
        
        // Pre-fill with user's location if available
        if let user = authManager.currentUser {
            self.selectedState = user.state
            if let university = user.university {
                self.selectedUniversity = university
            }
            if !isAnonymous {
                self.reporterName = "\(user.firstName) \(user.lastName)"
            }
        }
    }
    
    // MARK: - Actions
    
    /// Submit the incident report
    func submitIncident() async {
        guard isFormValid else {
            print("⚠️ [IncidentReporter] Form validation failed")
            return
        }
        
        guard let userEmail = authManager.currentUser?.email else {
            errorMessage = "You must be logged in to report an incident"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        // Create incident object
        let incident = Incident(
            title: title,
            description: description,
            incidentDate: incidentDate,
            universityName: selectedUniversity,
            campusLocation: campusLocation.isEmpty ? nil : campusLocation,
            city: city.isEmpty ? "Unknown" : city,
            state: selectedState.isEmpty ? "Unknown" : selectedState,
            latitude: latitude,
            longitude: longitude,
            incidentType: selectedType,
            severity: selectedSeverity,
            tags: tags,
            targetedIndividual: targetedIndividual.isEmpty ? nil : targetedIndividual,
            perpetrator: perpetratorName.isEmpty ? nil : perpetratorName,
            perpetratorRole: perpetratorRole.isEmpty ? nil : perpetratorRole,
            witnesses: witnesses.filter { !$0.isEmpty },
            evidenceURLs: evidenceURLs,
            evidenceDescription: evidenceDescription.isEmpty ? nil : evidenceDescription,
            newsArticleURLs: newsArticleURLs,
            reporterEmail: userEmail,
            reporterName: isAnonymous ? nil : reporterName,
            isAnonymous: isAnonymous,
            chapterID: authManager.currentUser?.chapterId,
            chapterName: authManager.currentUser?.university
        )
        
        // Submit to backend
        let success = await incidentManager.createIncident(incident)
        
        isSubmitting = false
        
        if success {
            print("✅ [IncidentReporter] Successfully submitted incident")
            showSuccessAlert = true
            resetForm()
        } else {
            print("❌ [IncidentReporter] Failed to submit incident")
            errorMessage = incidentManager.errorMessage ?? "Failed to submit incident. Please try again."
        }
    }
    
    /// Reset the form to initial state
    func resetForm() {
        title = ""
        description = ""
        incidentDate = Date()
        selectedUniversity = ""
        campusLocation = ""
        selectedType = .professorBias
        selectedSeverity = .moderate
        tags = []
        targetedIndividual = ""
        perpetratorName = ""
        perpetratorRole = ""
        witnesses = []
        evidenceURLs = []
        evidenceDescription = ""
        newsArticleURLs = []
        isAnonymous = false
        reporterName = ""
        
        // Restore user defaults
        if let user = authManager.currentUser {
            selectedState = user.state
            if let university = user.university {
                selectedUniversity = university
            }
            if !isAnonymous {
                reporterName = "\(user.firstName) \(user.lastName)"
            }
        }
        
        validationErrors = []
        errorMessage = nil
    }
    
    /// Add a tag
    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
        }
    }
    
    /// Remove a tag
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    /// Add evidence URL
    func addEvidenceURL(_ url: String) {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !evidenceURLs.contains(trimmed) {
            evidenceURLs.append(trimmed)
        }
    }
    
    /// Remove evidence URL
    func removeEvidenceURL(_ url: String) {
        evidenceURLs.removeAll { $0 == url }
    }
    
    /// Add news article URL
    func addNewsArticleURL(_ url: String) {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !newsArticleURLs.contains(trimmed) {
            newsArticleURLs.append(trimmed)
        }
    }
    
    /// Remove news article URL
    func removeNewsArticleURL(_ url: String) {
        newsArticleURLs.removeAll { $0 == url }
    }
    
    /// Add witness
    func addWitness(_ witness: String) {
        let trimmed = witness.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !witnesses.contains(trimmed) {
            witnesses.append(trimmed)
        }
    }
    
    /// Remove witness
    func removeWitness(_ witness: String) {
        witnesses.removeAll { $0 == witness }
    }
}
