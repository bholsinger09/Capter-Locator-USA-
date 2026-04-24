//
//  SubmissionManager.swift
//  SwiftChapterUSA Finder
//
//  Created on April 21, 2026.
//

import Foundation
import CloudKit
import Combine

class SubmissionManager: ObservableObject {
    @Published var submissions: [ChapterUpdateSubmission] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let publicDatabase: CKDatabase
    
    init() {
        container = CKContainer(identifier: "iCloud.ChapterFinder")
        privateDatabase = container.privateCloudDatabase
        publicDatabase = container.publicCloudDatabase
        
        // Force Development environment for testing
        // This allows schema to be created automatically
        print("🔧 [CloudKit] Using container: \(container.containerIdentifier ?? "unknown")")
        print("🔧 [CloudKit] Environment: Development (auto-creates schema)")
    }
    
    // Submit a new chapter update
    func submitUpdate(_ submission: ChapterUpdateSubmission) async throws {
        isLoading = true
        defer { isLoading = false }
        
        print("📤 [CloudKit] Attempting to submit update...")
        print("📤 [CloudKit] Container: \(container.containerIdentifier ?? "unknown")")
        print("📤 [CloudKit] Submission ID: \(submission.id)")
        print("📤 [CloudKit] State: \(submission.state), University: \(submission.university)")
        
        let record = submission.toRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ [CloudKit] Successfully saved record: \(savedRecord.recordID.recordName)")
            await MainActor.run {
                errorMessage = nil
            }
        } catch {
            print("❌ [CloudKit] Save failed: \(error)")
            if let ckError = error as? CKError {
                print("❌ [CloudKit] CKError code: \(ckError.code.rawValue)")
                print("❌ [CloudKit] CKError description: \(ckError.localizedDescription)")
            }
            await MainActor.run {
                errorMessage = "Failed to submit update: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // Fetch all submissions (admin only)
    func fetchAllSubmissions() async {
        isLoading = true
        defer { isLoading = false }
        
        print("📥 [CloudKit] Fetching all submissions...")
        print("📥 [CloudKit] Container: \(container.containerIdentifier ?? "unknown")")
        
        await MainActor.run {
            self.submissions = []
        }
        
        // Use CKQueryOperation to fetch all records with cursor-based pagination
        // This doesn't require any queryable fields
        let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: NSPredicate(value: true))
        
        var allRecords: [CKRecord] = []
        var queryCursor: CKQueryOperation.Cursor? = nil
        
        repeat {
            do {
                let result: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
                
                if let cursor = queryCursor {
                    // Continue from cursor
                    result = try await publicDatabase.records(continuingMatchFrom: cursor)
                } else {
                    // Initial query
                    result = try await publicDatabase.records(matching: query)
                }
                
                // Extract successful records
                let records = result.matchResults.compactMap { _, recordResult -> CKRecord? in
                    guard case .success(let record) = recordResult else { return nil }
                    return record
                }
                
                allRecords.append(contentsOf: records)
                queryCursor = result.queryCursor
                
                print("📥 [CloudKit] Fetched \(records.count) records, total so far: \(allRecords.count)")
                
            } catch {
                print("❌ [CloudKit] Fetch failed: \(error)")
                if let ckError = error as? CKError {
                    print("❌ [CloudKit] CKError code: \(ckError.code.rawValue)")
                    print("❌ [CloudKit] CKError description: \(ckError.localizedDescription)")
                }
                await MainActor.run {
                    self.errorMessage = "Failed to fetch submissions: \(error.localizedDescription)"
                }
                return
            }
        } while queryCursor != nil
        
        // Convert to our model and sort
        let allSubmissions = allRecords.compactMap { record in
            ChapterUpdateSubmission.fromRecord(record)
        }.sorted { $0.submittedAt > $1.submittedAt }
        
        print("✅ [CloudKit] Processed \(allSubmissions.count) total submissions")
        
        await MainActor.run {
            self.submissions = allSubmissions
            self.errorMessage = nil
        }
    }
    
    // Update submission status
    func updateSubmissionStatus(_ submission: ChapterUpdateSubmission, status: ChapterUpdateSubmission.SubmissionStatus) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let recordName = submission.recordName else {
            let error = NSError(domain: "SubmissionManager", code: -1, 
                              userInfo: [NSLocalizedDescriptionKey: "Record name not available"])
            await MainActor.run {
                errorMessage = "Failed to update status: Record name missing"
            }
            throw error
        }
        
        do {
            // Use recordName directly - no query needed!
            let recordID = CKRecord.ID(recordName: recordName)
            let record = try await publicDatabase.record(for: recordID)
            
            record["status"] = status.rawValue as CKRecordValue
            _ = try await publicDatabase.save(record)
            
            await fetchAllSubmissions()
        } catch {
            await MainActor.run {
                errorMessage = "Failed to update status: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // Delete a submission
    func deleteSubmission(_ submission: ChapterUpdateSubmission) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let recordName = submission.recordName else {
            let error = NSError(domain: "SubmissionManager", code: -1, 
                              userInfo: [NSLocalizedDescriptionKey: "Record name not available"])
            await MainActor.run {
                errorMessage = "Failed to delete submission: Record name missing"
            }
            throw error
        }
        
        do {
            // Use recordName directly - no query needed!
            let recordID = CKRecord.ID(recordName: recordName)
            _ = try await publicDatabase.deleteRecord(withID: recordID)
            
            await fetchAllSubmissions()
        } catch {
            await MainActor.run {
                errorMessage = "Failed to delete submission: \(error.localizedDescription)"
            }
            throw error
        }
    }
}
