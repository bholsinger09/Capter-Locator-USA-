//
//  EventRSVP.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import Foundation
import CloudKit

struct EventRSVP: Identifiable, Codable {
    var id: UUID = UUID()
    var recordName: String? // CloudKit record identifier
    var eventID: UUID
    var eventTitle: String
    var userEmail: String
    var userName: String
    var rsvpDate: Date = Date()
    var status: RSVPStatus
    var guestCount: Int = 1
    var checkedIn: Bool = false
    var checkedInAt: Date?
    var notes: String?
    
    enum RSVPStatus: String, Codable, CaseIterable {
        case confirmed = "Confirmed"
        case waitlist = "Waitlist"
        case cancelled = "Cancelled"
        
        var color: String {
            switch self {
            case .confirmed: return "green"
            case .waitlist: return "orange"
            case .cancelled: return "red"
            }
        }
        
        var icon: String {
            switch self {
            case .confirmed: return "checkmark.circle.fill"
            case .waitlist: return "clock.fill"
            case .cancelled: return "xmark.circle.fill"
            }
        }
    }
    
    var formattedRSVPDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: rsvpDate)
    }
    
    // Convert to CloudKit record
    func toRecord() -> CKRecord {
        let recordID: CKRecord.ID
        if let recordName = recordName {
            recordID = CKRecord.ID(recordName: recordName)
        } else {
            recordID = CKRecord.ID(recordName: id.uuidString)
        }
        
        let record = CKRecord(recordType: "EventRSVP", recordID: recordID)
        record["id"] = id.uuidString as CKRecordValue
        record["eventID"] = eventID.uuidString as CKRecordValue
        record["eventTitle"] = eventTitle as CKRecordValue
        record["userEmail"] = userEmail as CKRecordValue
        record["userName"] = userName as CKRecordValue
        record["rsvpDate"] = rsvpDate as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        record["guestCount"] = guestCount as CKRecordValue
        record["checkedIn"] = (checkedIn ? 1 : 0) as CKRecordValue
        if let checkedInAt = checkedInAt {
            record["checkedInAt"] = checkedInAt as CKRecordValue
        }
        if let notes = notes {
            record["notes"] = notes as CKRecordValue
        }
        
        return record
    }
    
    // Create from CloudKit record
    static func fromRecord(_ record: CKRecord) -> EventRSVP? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let eventIDString = record["eventID"] as? String,
              let eventID = UUID(uuidString: eventIDString),
              let eventTitle = record["eventTitle"] as? String,
              let userEmail = record["userEmail"] as? String,
              let userName = record["userName"] as? String,
              let rsvpDate = record["rsvpDate"] as? Date,
              let statusString = record["status"] as? String,
              let status = RSVPStatus(rawValue: statusString)
        else {
            return nil
        }
        
        let guestCount = record["guestCount"] as? Int ?? 1
        let checkedIn = (record["checkedIn"] as? Int ?? 0) != 0
        
        return EventRSVP(
            id: id,
            recordName: record.recordID.recordName,
            eventID: eventID,
            eventTitle: eventTitle,
            userEmail: userEmail,
            userName: userName,
            rsvpDate: rsvpDate,
            status: status,
            guestCount: guestCount,
            checkedIn: checkedIn,
            checkedInAt: record["checkedInAt"] as? Date,
            notes: record["notes"] as? String
        )
    }
}
