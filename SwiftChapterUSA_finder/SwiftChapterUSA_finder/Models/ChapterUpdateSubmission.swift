//
//  ChapterUpdateSubmission.swift
//  SwiftChapterUSA Finder
//
//  Created on April 21, 2026.
//

import Foundation
import CloudKit

struct ChapterUpdateSubmission: Identifiable, Codable {
    var id: String
    var recordName: String? // CloudKit record name for updates/deletes
    var state: String
    var university: String
    var contactName: String
    var contactEmail: String
    var submittedBy: String
    var submittedAt: Date
    var status: SubmissionStatus
    
    enum SubmissionStatus: String, Codable, CaseIterable {
        case pending = "Pending"
        case reviewed = "Reviewed"
        case approved = "Approved"
        case rejected = "Rejected"
    }
    
    init(id: String = UUID().uuidString,
         recordName: String? = nil,
         state: String,
         university: String,
         contactName: String,
         contactEmail: String,
         submittedBy: String,
         submittedAt: Date = Date(),
         status: SubmissionStatus = .pending) {
        self.id = id
        self.recordName = recordName
        self.state = state
        self.university = university
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.submittedBy = submittedBy
        self.submittedAt = submittedAt
        self.status = status
    }
    
    // Convert to CloudKit record
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "ChapterUpdateSubmission")
        record["id"] = id as CKRecordValue
        record["state"] = state as CKRecordValue
        record["university"] = university as CKRecordValue
        record["contactName"] = contactName as CKRecordValue
        record["contactEmail"] = contactEmail as CKRecordValue
        record["submittedBy"] = submittedBy as CKRecordValue
        record["submittedAt"] = submittedAt as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        return record
    }
    
    // Create from CloudKit record
    static func fromRecord(_ record: CKRecord) -> ChapterUpdateSubmission? {
        guard let id = record["id"] as? String,
              let state = record["state"] as? String,
              let university = record["university"] as? String,
              let contactName = record["contactName"] as? String,
              let contactEmail = record["contactEmail"] as? String,
              let submittedBy = record["submittedBy"] as? String,
              let submittedAt = record["submittedAt"] as? Date,
              let statusString = record["status"] as? String,
              let status = SubmissionStatus(rawValue: statusString) else {
            return nil
        }
        
        return ChapterUpdateSubmission(
            id: id,
            recordName: record.recordID.recordName,
            state: state,
            university: university,
            contactName: contactName,
            contactEmail: contactEmail,
            submittedBy: submittedBy,
            submittedAt: submittedAt,
            status: status
        )
    }
}
