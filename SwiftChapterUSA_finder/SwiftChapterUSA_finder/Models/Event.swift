//
//  Event.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import Foundation
import CloudKit

struct Event: Identifiable, Codable {
    var id: UUID = UUID()
    var recordName: String? // CloudKit record identifier
    var title: String
    var description: String
    var eventDate: Date
    var endDate: Date?
    var location: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var chapterID: UUID
    var chapterName: String
    var state: String
    var university: String?
    var organizerName: String
    var organizerEmail: String
    var imageURL: String?
    var capacity: Int?
    var rsvpCount: Int = 0
    var eventType: EventType
    var isVirtual: Bool = false
    var virtualMeetingURL: String?
    var requiresRSVP: Bool = true
    var createdAt: Date = Date()
    var createdBy: String // User email
    var isActive: Bool = true
    var tags: [String] = []
    
    enum EventType: String, Codable, CaseIterable {
        case meeting = "Meeting"
        case networking = "Networking"
        case speaker = "Speaker Event"
        case workshop = "Workshop"
        case social = "Social"
        case fundraiser = "Fundraiser"
        case protest = "Protest/Rally"
        case volunteer = "Volunteer"
        case conference = "Conference"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .meeting: return "person.3.fill"
            case .networking: return "person.2.fill"
            case .speaker: return "mic.fill"
            case .workshop: return "hammer.fill"
            case .social: return "party.popper.fill"
            case .fundraiser: return "dollarsign.circle.fill"
            case .protest: return "megaphone.fill"
            case .volunteer: return "hands.sparkles.fill"
            case .conference: return "building.columns.fill"
            case .other: return "calendar.badge.plus"
            }
        }
    }
    
    var isPast: Bool {
        eventDate < Date()
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(eventDate)
    }
    
    var isFull: Bool {
        guard let capacity = capacity else { return false }
        return rsvpCount >= capacity
    }
    
    var spotsRemaining: Int? {
        guard let capacity = capacity else { return nil }
        return max(0, capacity - rsvpCount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: eventDate)
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let startStr = formatter.string(from: eventDate)
        
        if let endDate = endDate {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            let endStr = formatter.string(from: endDate)
            return "\(startStr) - \(endStr)"
        }
        
        return startStr
    }
    
    // Convert to CloudKit record
    func toRecord() -> CKRecord {
        let recordID: CKRecord.ID
        if let recordName = recordName {
            recordID = CKRecord.ID(recordName: recordName)
        } else {
            recordID = CKRecord.ID(recordName: id.uuidString)
        }
        
        let record = CKRecord(recordType: "Event", recordID: recordID)
        record["id"] = id.uuidString as CKRecordValue
        record["title"] = title as CKRecordValue
        record["description"] = description as CKRecordValue
        record["eventDate"] = eventDate as CKRecordValue
        if let endDate = endDate {
            record["endDate"] = endDate as CKRecordValue
        }
        record["location"] = location as CKRecordValue
        if let address = address {
            record["address"] = address as CKRecordValue
        }
        if let latitude = latitude {
            record["latitude"] = latitude as CKRecordValue
        }
        if let longitude = longitude {
            record["longitude"] = longitude as CKRecordValue
        }
        record["chapterID"] = chapterID.uuidString as CKRecordValue
        record["chapterName"] = chapterName as CKRecordValue
        record["state"] = state as CKRecordValue
        if let university = university {
            record["university"] = university as CKRecordValue
        }
        record["organizerName"] = organizerName as CKRecordValue
        record["organizerEmail"] = organizerEmail as CKRecordValue
        if let imageURL = imageURL {
            record["imageURL"] = imageURL as CKRecordValue
        }
        if let capacity = capacity {
            record["capacity"] = capacity as CKRecordValue
        }
        record["rsvpCount"] = rsvpCount as CKRecordValue
        record["eventType"] = eventType.rawValue as CKRecordValue
        record["isVirtual"] = (isVirtual ? 1 : 0) as CKRecordValue
        if let virtualMeetingURL = virtualMeetingURL {
            record["virtualMeetingURL"] = virtualMeetingURL as CKRecordValue
        }
        record["requiresRSVP"] = (requiresRSVP ? 1 : 0) as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["createdBy"] = createdBy as CKRecordValue
        record["isActive"] = (isActive ? 1 : 0) as CKRecordValue
        record["tags"] = tags.joined(separator: ",") as CKRecordValue
        
        return record
    }
    
    // Create from CloudKit record
    static func fromRecord(_ record: CKRecord) -> Event? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = record["title"] as? String,
              let description = record["description"] as? String,
              let eventDate = record["eventDate"] as? Date,
              let location = record["location"] as? String,
              let chapterIDString = record["chapterID"] as? String,
              let chapterID = UUID(uuidString: chapterIDString),
              let chapterName = record["chapterName"] as? String,
              let state = record["state"] as? String,
              let organizerName = record["organizerName"] as? String,
              let organizerEmail = record["organizerEmail"] as? String,
              let eventTypeString = record["eventType"] as? String,
              let eventType = EventType(rawValue: eventTypeString),
              let createdAt = record["createdAt"] as? Date,
              let createdBy = record["createdBy"] as? String
        else {
            return nil
        }
        
        let rsvpCount = record["rsvpCount"] as? Int ?? 0
        let isVirtual = (record["isVirtual"] as? Int ?? 0) != 0
        let requiresRSVP = (record["requiresRSVP"] as? Int ?? 1) != 0
        let isActive = (record["isActive"] as? Int ?? 1) != 0
        
        let tagsString = record["tags"] as? String ?? ""
        let tags = tagsString.isEmpty ? [] : tagsString.components(separatedBy: ",")
        
        return Event(
            id: id,
            recordName: record.recordID.recordName,
            title: title,
            description: description,
            eventDate: eventDate,
            endDate: record["endDate"] as? Date,
            location: location,
            address: record["address"] as? String,
            latitude: record["latitude"] as? Double,
            longitude: record["longitude"] as? Double,
            chapterID: chapterID,
            chapterName: chapterName,
            state: state,
            university: record["university"] as? String,
            organizerName: organizerName,
            organizerEmail: organizerEmail,
            imageURL: record["imageURL"] as? String,
            capacity: record["capacity"] as? Int,
            rsvpCount: rsvpCount,
            eventType: eventType,
            isVirtual: isVirtual,
            virtualMeetingURL: record["virtualMeetingURL"] as? String,
            requiresRSVP: requiresRSVP,
            createdAt: createdAt,
            createdBy: createdBy,
            isActive: isActive,
            tags: tags
        )
    }
}
