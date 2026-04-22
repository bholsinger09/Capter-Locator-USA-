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
        
        let record = submission.toRecord()
        
        do {
            _ = try await publicDatabase.save(record)
            await MainActor.run {
                errorMessage = nil
            }
        } catch {
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
        
        let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "submittedAt", ascending: false)]
        
        do {
            let results = try await publicDatabase.records(matching: query)
            let fetchedSubmissions = results.matchResults.compactMap { _, result -> ChapterUpdateSubmission? in
                guard case .success(let record) = result else { return nil }
                return ChapterUpdateSubmission.fromRecord(record)
            }
            
            await MainActor.run {
                self.submissions = fetchedSubmissions
                self.errorMessage = nil
            }
        } catch {
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
