//
//  CloudKitTagService.swift
//  Chapters
//
//  CloudKit service for persisting and syncing chapter tags
//

import Foundation
import CloudKit

public class CloudKitTagService: NSObject, ObservableObject {
    public static let shared = CloudKitTagService()
    
    private let container = CKContainer.default()
    private let database: CKDatabase
    private let recordType = "ChapterTags"
    
    @Published public var isInitialized = false
    @Published public var errorMessage: String?
    
    override init() {
        self.database = container.privateCloudDatabase
        super.init()
        setupCloudKit()
    }
    
    // MARK: - Setup
    
    private func setupCloudKit() {
        // Check iCloud account availability
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isInitialized = true
                    print("✅ CloudKit available")
                case .noAccount:
                    self?.errorMessage = "iCloud account required. Please sign in to iCloud."
                    print("❌ No iCloud account")
                case .restricted:
                    self?.errorMessage = "CloudKit access is restricted"
                    print("❌ CloudKit restricted")
                case .couldNotDetermine:
                    self?.errorMessage = "Could not determine iCloud status"
                    print("❌ Could not determine iCloud status")
                @unknown default:
                    self?.errorMessage = "Unknown iCloud status"
                }
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("CloudKit error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Save Tags
    
    public func saveTags(_ tags: [String], forChapterId chapterId: UUID) async throws {
        let record = CKRecord(recordType: recordType)
        record["chapterId"] = chapterId.uuidString
        record["tags"] = tags
        record["updatedAt"] = Date()
        
        do {
            _ = try await database.save(record)
            print("✅ Tags saved to CloudKit for chapter \(chapterId)")
        } catch {
            print("❌ Error saving tags to CloudKit: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetch Tags
    
    public func fetchTags(forChapterId chapterId: UUID) async throws -> [String] {
        let predicate = NSPredicate(format: "chapterId == %@", chapterId.uuidString)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        do {
            let (recordIds, _) = try await database.records(matching: query)
            
            for (_, recordResult) in recordIds {
                switch recordResult {
                case .success(let record):
                    let tags = record["tags"] as? [String] ?? []
                    print("✅ Fetched tags from CloudKit for chapter \(chapterId): \(tags)")
                    return tags
                case .failure(let error):
                    print("❌ Error fetching record: \(error)")
                    continue
                }
            }
            
            return []
        } catch {
            print("❌ Error fetching tags from CloudKit: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetch All Tags
    
    public func fetchAllChapterTags() async throws -> [UUID: [String]] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        do {
            let (recordIds, _) = try await database.records(matching: query)
            var result: [UUID: [String]] = [:]
            
            for (_, recordResult) in recordIds {
                switch recordResult {
                case .success(let record):
                    if let chapterIdStr = record["chapterId"] as? String,
                       let chapterId = UUID(uuidString: chapterIdStr),
                       let tags = record["tags"] as? [String] {
                        result[chapterId] = tags
                    }
                case .failure(let error):
                    print("❌ Error decoding record: \(error)")
                    continue
                }
            }
            
            print("✅ Fetched all chapter tags from CloudKit")
            return result
        } catch {
            print("❌ Error fetching all chapter tags: \(error)")
            throw error
        }
    }
    
    // MARK: - Delete Tags
    
    public func deleteTags(forChapterId chapterId: UUID) async throws {
        let predicate = NSPredicate(format: "chapterId == %@", chapterId.uuidString)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        do {
            let (recordIds, _) = try await database.records(matching: query)
            
            for (_, recordResult) in recordIds {
                switch recordResult {
                case .success(let record):
                    try await database.deleteRecord(withID: record.recordID)
                case .failure(let error):
                    print("❌ Error processing record: \(error)")
                    continue
                }
            }
            
            print("✅ Tags deleted from CloudKit for chapter \(chapterId)")
        } catch {
            print("❌ Error deleting tags from CloudKit: \(error)")
            throw error
        }
    }
    
    // MARK: - Sync
    
    public func syncTags(for chapters: inout [Chapter]) async {
        do {
            let allTags = try await fetchAllChapterTags()
            
            for i in 0..<chapters.count {
                if let tags = allTags[chapters[i].id] {
                    chapters[i].tags = tags
                }
            }
            
            print("✅ Synced all chapters with CloudKit tags")
        } catch {
            print("❌ Error syncing tags: \(error)")
        }
    }
}
