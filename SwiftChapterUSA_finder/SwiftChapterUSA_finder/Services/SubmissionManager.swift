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
        
        do {
            // Query using CreationDate which is always indexed and available
            let predicate = NSPredicate(format: "creationDate != nil")
            let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: predicate)
            // Sort by creation date (newest first)
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            print("📥 [CloudKit] Fetching all ChapterUpdateSubmission records...")
            let results = try await publicDatabase.records(matching: query)
            print("📥 [CloudKit] Found \(results.matchResults.count) total records")
            
            let allSubmissions = results.matchResults.compactMap { _, result -> ChapterUpdateSubmission? in
                guard case .success(let record) = result else { 
                    print("⚠️ [CloudKit] Failed to unwrap record result")
                    return nil 
                }
                let submission = ChapterUpdateSubmission.fromRecord(record)
                if submission == nil {
                    print("⚠️ [CloudKit] Failed to parse record: \(record.recordID.recordName)")
                }
                return submission
            }
            
            // Already sorted by CloudKit query
            print("✅ [CloudKit] Processed \(allSubmissions.count) total submissions")
            
            await MainActor.run {
                self.submissions = allSubmissions
                self.errorMessage = nil
            }
        } catch {
            print("❌ [CloudKit] Fetch failed: \(error)")
            if let ckError = error as? CKError {
                print("❌ [CloudKit] CKError code: \(ckError.code.rawValue)")
                print("❌ [CloudKit] CKError description: \(ckError.localizedDescription)")
            }
            await MainActor.run {
                self.errorMessage = "Failed to fetch submissions: \(error.localizedDescription)"
            }
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
