//
//  Event.swift
//  Events
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation

public struct Event: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var title: String
    public var description: String
    public var eventDate: Date
    public var location: String
    public var chapterId: UUID?
    public var organizerName: String
    public var capacity: Int?
    public var isVirtual: Bool = false
    public var eventURL: String?
    public var imageURL: String?
    public var isActive: Bool = true
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        eventDate: Date,
        location: String,
        chapterId: UUID? = nil,
        organizerName: String,
        capacity: Int? = nil,
        isVirtual: Bool = false,
        eventURL: String? = nil,
        imageURL: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.eventDate = eventDate
        self.location = location
        self.chapterId = chapterId
        self.organizerName = organizerName
        self.capacity = capacity
        self.isVirtual = isVirtual
        self.eventURL = eventURL
        self.imageURL = imageURL
        self.isActive = isActive
    }
}

public struct EventRSVP: Identifiable, Codable, Hashable {
    public enum RSVPStatus: String, Codable {
        case confirmed
        case pending
        case declined
    }
    
    public var id: UUID = UUID()
    public var eventId: UUID
    public var userId: UUID
    public var status: RSVPStatus
    public var guestCount: Int
    public var rsvpDate: Date
    
    public init(
        id: UUID = UUID(),
        eventId: UUID,
        userId: UUID,
        status: RSVPStatus = .pending,
        guestCount: Int = 1,
        rsvpDate: Date = Date()
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.status = status
        self.guestCount = guestCount
        self.rsvpDate = rsvpDate
    }
}
