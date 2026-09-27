//
//  Chapter.swift
//  Chapters
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation

public struct Chapter: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var name: String
    public var state: String
    public var city: String
    public var university: String?
    public var presidentName: String
    public var contactEmail: String
    public var phoneNumber: String?
    public var description: String
    public var memberCount: Int
    public var meetingLocation: String?
    public var meetingSchedule: String?
    public var dateEstablished: Date
    public var isActive: Bool = true
    public var latitude: Double?
    public var longitude: Double?
    public var stateCoordinatorName: String?
    public var stateCoordinatorLinkedIn: String?
    
    public var displayName: String {
        if let university = university {
            return "\(university) Chapter"
        } else {
            return "\(city), \(state) Chapter"
        }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        state: String,
        city: String,
        university: String? = nil,
        presidentName: String,
        contactEmail: String,
        phoneNumber: String? = nil,
        description: String,
        memberCount: Int,
        meetingLocation: String? = nil,
        meetingSchedule: String? = nil,
        dateEstablished: Date,
        isActive: Bool = true,
        latitude: Double? = nil,
        longitude: Double? = nil,
        stateCoordinatorName: String? = nil,
        stateCoordinatorLinkedIn: String? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.city = city
        self.university = university
        self.presidentName = presidentName
        self.contactEmail = contactEmail
        self.phoneNumber = phoneNumber
        self.description = description
        self.memberCount = memberCount
        self.meetingLocation = meetingLocation
        self.meetingSchedule = meetingSchedule
        self.dateEstablished = dateEstablished
        self.isActive = isActive
        self.latitude = latitude
        self.longitude = longitude
        self.stateCoordinatorName = stateCoordinatorName
        self.stateCoordinatorLinkedIn = stateCoordinatorLinkedIn
    }
}
