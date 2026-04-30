//
//  Incident.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import Foundation
import CloudKit
import CoreLocation

struct Incident: Identifiable, Codable {
    var id: UUID = UUID()
    var recordName: String? // CloudKit record identifier
    
    // Basic Information
    var title: String
    var description: String
    var incidentDate: Date
    var reportedDate: Date = Date()
    
    // Location Information
    var universityName: String
    var campusLocation: String? // Specific building/area
    var city: String
    var state: String
    var latitude: Double?
    var longitude: Double?
    
    // Incident Classification
    var incidentType: IncidentType
    var severity: Severity
    var tags: [String] = []
    
    // People Involved
    var targetedIndividual: String? // Student/group affected
    var perpetrator: String? // Professor name, admin name, etc.
    var perpetratorRole: String? // "Professor", "Dean", "Student", etc.
    var witnesses: [String] = []
    
    // Evidence
    var evidenceURLs: [String] = [] // Photos, videos, documents
    var evidenceDescription: String?
    var newsArticleURLs: [String] = []
    
    // Reporter Information
    var reporterEmail: String
    var reporterName: String?
    var isAnonymous: Bool = false
    var chapterID: UUID? // Associated chapter if applicable
    var chapterName: String?
    
    // Status & Verification
    var verificationStatus: VerificationStatus = .pending
    var verifiedBy: String? // Admin/moderator email
    var verifiedDate: Date?
    var isPublic: Bool = true
    var isActive: Bool = true
    
    // Engagement
    var viewCount: Int = 0
    var supportCount: Int = 0 // "I experienced this too" count
    var shareCount: Int = 0
    
    // Resolution
    var resolutionStatus: ResolutionStatus = .unresolved
    var resolutionDescription: String?
    var resolutionDate: Date?
    
    // Metadata
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    enum IncidentType: String, Codable, CaseIterable {
        case professorBias = "Professor Bias/Indoctrination"
        case gradePenalty = "Grade Retaliation"
        case speechCode = "Speech Code Violation"
        case eventCancellation = "Event Cancelled/Disrupted"
        case posterRemoval = "Poster/Flyer Removal"
        case denyFunding = "Denied Funding/Recognition"
        case harassment = "Harassment/Intimidation"
        case deplatforming = "Deplatforming/Disinvitation"
        case administrativeAction = "Administrative Overreach"
        case doubleStandard = "Viewpoint Discrimination"
        case physicalViolence = "Physical Violence/Assault"
        case propertyDamage = "Property Damage"
        case socialMedia = "Social Media Censorship"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .professorBias: return "person.fill.questionmark"
            case .gradePenalty: return "graduationcap.fill"
            case .speechCode: return "text.badge.xmark"
            case .eventCancellation: return "calendar.badge.exclamationmark"
            case .posterRemoval: return "doc.text.fill.badge.ellipsis"
            case .denyFunding: return "dollarsign.circle.fill"
            case .harassment: return "exclamationmark.triangle.fill"
            case .deplatforming: return "mic.slash.fill"
            case .administrativeAction: return "building.2.fill"
            case .doubleStandard: return "scale.3d"
            case .physicalViolence: return "hand.raised.fill"
            case .propertyDamage: return "hammer.fill"
            case .socialMedia: return "network.slash"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
    
    enum Severity: String, Codable, CaseIterable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case critical = "Critical"
        
        var color: String {
            switch self {
            case .low: return "yellow"
            case .moderate: return "orange"
            case .high: return "red"
            case .critical: return "purple"
            }
        }
        
        var priority: Int {
            switch self {
            case .low: return 1
            case .moderate: return 2
            case .high: return 3
            case .critical: return 4
            }
        }
    }
    
    enum VerificationStatus: String, Codable {
        case pending = "Pending Review"
        case verified = "Verified"
        case disputed = "Disputed"
        case rejected = "Rejected"
        case needsMoreInfo = "Needs More Information"
    }
    
    enum ResolutionStatus: String, Codable {
        case unresolved = "Unresolved"
        case inProgress = "In Progress"
        case resolved = "Resolved"
        case dismissed = "Dismissed"
        case escalated = "Escalated to Legal"
    }
    
    // MARK: - Computed Properties
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var isRecent: Bool {
        let daysSinceIncident = Calendar.current.dateComponents([.day], from: incidentDate, to: Date()).day ?? 0
        return daysSinceIncident <= 30
    }
    
    var isVerified: Bool {
        return verificationStatus == .verified
    }
    
    var hasEvidence: Bool {
        return !evidenceURLs.isEmpty || !newsArticleURLs.isEmpty
    }
    
    var displayTitle: String {
        return isAnonymous ? "Anonymous Report - \(universityName)" : title
    }
}

// MARK: - Campus Statistics
struct CampusStats: Identifiable {
    let id = UUID()
    let universityName: String
    let state: String
    let city: String
    let coordinate: CLLocationCoordinate2D?
    
    var totalIncidents: Int
    var verifiedIncidents: Int
    var criticalIncidents: Int
    var recentIncidents: Int // Last 30 days
    
    var hostilityScore: Double {
        // Calculate a 0-100 score based on incidents
        let baseScore = Double(totalIncidents) * 5.0
        let severityBonus = Double(criticalIncidents) * 10.0
        let recentBonus = Double(recentIncidents) * 3.0
        return min(100, baseScore + severityBonus + recentBonus)
    }
    
    var rating: CampusRating {
        switch hostilityScore {
        case 0..<10: return .friendly
        case 10..<30: return .neutral
        case 30..<60: return .cautious
        case 60..<80: return .hostile
        default: return .veryHostile
        }
    }
    
    enum CampusRating: String {
        case friendly = "Free Speech Friendly"
        case neutral = "Neutral"
        case cautious = "Requires Caution"
        case hostile = "Hostile Environment"
        case veryHostile = "Very Hostile"
        
        var color: String {
            switch self {
            case .friendly: return "green"
            case .neutral: return "blue"
            case .cautious: return "yellow"
            case .hostile: return "orange"
            case .veryHostile: return "red"
            }
        }
        
        var icon: String {
            switch self {
            case .friendly: return "checkmark.shield.fill"
            case .neutral: return "shield.fill"
            case .cautious: return "exclamationmark.shield.fill"
            case .hostile: return "xmark.shield.fill"
            case .veryHostile: return "flame.fill"
            }
        }
    }
}

// MARK: - Search Filters
struct IncidentFilters {
    var searchText: String = ""
    var selectedStates: Set<String> = []
    var selectedTypes: Set<Incident.IncidentType> = []
    var selectedSeverity: Set<Incident.Severity> = []
    var verifiedOnly: Bool = false
    var dateRange: DateRange = .allTime
    var sortBy: SortOption = .mostRecent
    
    enum DateRange {
        case allTime
        case lastWeek
        case lastMonth
        case lastYear
        case custom(start: Date, end: Date)
    }
    
    enum SortOption: String, CaseIterable {
        case mostRecent = "Most Recent"
        case oldest = "Oldest First"
        case highestSeverity = "Highest Severity"
        case mostSupported = "Most Supported"
        case campusName = "Campus Name"
    }
}
