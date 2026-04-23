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
        
        let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: NSPredicate(value: true))
        // Temporarily remove sorting until schema is configured
        // query.sortDescriptors = [NSSortDescriptor(key: "submittedAt", ascending: false)]
        
        do {
            let results = try await publicDatabase.records(matching: query)
            print("📥 [CloudKit] Query executed successfully")
            print("📥 [CloudKit] Match results count: \(results.matchResults.count)")
            
            let fetchedSubmissions = results.matchResults.compactMap { _, result -> ChapterUpdateSubmission? in
                guard case .success(let record) = result else { 
                    print("⚠️ [CloudKit] Failed to get record from result")
                    return nil 
                }
                print("📥 [CloudKit] Processing record: \(record.recordID.recordName)")
                return ChapterUpdateSubmission.fromRecord(record)
            }
            
            // Sort in memory instead
            let sortedSubmissions = fetchedSubmissions.sorted { $0.submittedAt > $1.submittedAt }
            
            print("✅ [CloudKit] Processed \(sortedSubmissions.count) submissions")
            
            await MainActor.run {
                self.submissions = sortedSubmissions
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
        
        let predicate = NSPredicate(format: "id == %@", submission.id)
        let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: predicate)
        
        do {
            let results = try await publicDatabase.records(matching: query)
            guard let firstResult = results.matchResults.first,
                  case .success(let record) = firstResult.1 else {
                throw NSError(domain: "SubmissionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Record not found"])
            }
            
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
        
        let predicate = NSPredicate(format: "id == %@", submission.id)
        let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: predicate)
        
        do {
            let results = try await publicDatabase.records(matching: query)
            guard let firstResult = results.matchResults.first,
                  case .success(let record) = firstResult.1 else {
                throw NSError(domain: "SubmissionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Record not found"])
            }
            
            _ = try await publicDatabase.deleteRecord(withID: record.recordID)
            await fetchAllSubmissions()
        } catch {
            await MainActor.run {
                errorMessage = "Failed to delete submission: \(error.localizedDescription)"
            }
            throw error
        }
    }
}
