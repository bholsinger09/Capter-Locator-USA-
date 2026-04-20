//
//  Chapter.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

struct Chapter: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var state: String
    var city: String
    var university: String?
    var presidentName: String
    var contactEmail: String
    var phoneNumber: String?
    var description: String
    var memberCount: Int
    var meetingLocation: String?
    var meetingSchedule: String?
    var dateEstablished: Date
    var isActive: Bool = true
    var latitude: Double?
    var longitude: Double?
    var stateCoordinatorName: String?
    var stateCoordinatorEmail: String?
    var stateCoordinatorLinkedIn: String?
    
    var displayName: String {
        if let university = university {
            return "\(university) Chapter"
        } else {
            return "\(city), \(state) Chapter"
        }
    }
}
