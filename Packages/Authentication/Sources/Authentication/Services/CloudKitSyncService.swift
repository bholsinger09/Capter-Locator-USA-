//
//  CloudKitSyncService.swift
//  Authentication
//
//  Handles syncing between local UserDefaults and CloudKit
//

import Foundation
import CloudKit
import Common
import Combine

public enum SyncStatus {
    case synced
    case syncing
    case notSynced
    case offline
}

public class CloudKitSyncService: ObservableObject {
    public static let shared = CloudKitSyncService()
    
    private let container: CKContainer
    private let database: CKDatabase
    
    @Published public private(set) var syncStatus: SyncStatus = .offline
    
    private init() {
        self.container = CKContainer(identifier: "iCloud.com.holsinger.chapterfinder")
        self.database = container.publicCloudDatabase
    }
    
    // MARK: - Save Operations
    
    public func saveUserWithSync(_ user: User) async throws {
        // Always save locally first (guaranteed success)
        saveUserLocally(user)
        
        // Then try to sync to CloudKit if online
        if Reachability.shared.isConnected {
            await MainActor.run {
                self.syncStatus = .syncing
            }
            
            do {
                try await saveUserToCloudKit(user)
                await MainActor.run {
                    self.syncStatus = .synced
                    print("✅ User synced to CloudKit: \(user.email)")
                }
            } catch {
                await MainActor.run {
                    self.syncStatus = .notSynced
                    print("⚠️ User saved locally, CloudKit sync failed: \(error)")
                }
            }
        } else {
            await MainActor.run {
                self.syncStatus = .offline
                print("⚠️ Offline - User saved locally only")
            }
        }
    }
    
    // MARK: - Fetch Operations
    
    public func fetchUserWithSync(email: String) async throws -> User? {
        // Try CloudKit first if online
        if Reachability.shared.isConnected {
            do {
                if let user = try await fetchUserFromCloudKit(email: email) {
                    // Also update local storage
                    saveUserLocally(user)
                    return user
                }
            } catch {
                print("⚠️ CloudKit fetch failed, falling back to local: \(error)")
            }
        }
        
        // Fall back to local
        return fetchUserLocally(email: email)
    }
    
    public func fetchUserWithSync(appleUserID: String) async throws -> User? {
        // Try CloudKit first if online
        if Reachability.shared.isConnected {
            do {
                if let user = try await fetchUserFromCloudKit(appleUserID: appleUserID) {
                    // Also update local storage
                    saveUserLocally(user)
                    return user
                }
            } catch {
                print("⚠️ CloudKit fetch failed, falling back to local: \(error)")
            }
        }
        
        // Fall back to local
        return fetchUserLocally(appleUserID: appleUserID)
    }
    
    // MARK: - Local Storage Helpers
    
    private func saveUserLocally(_ user: User) {
        let userKey = "user_\(user.email)"
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            UserDefaults.standard.set(user.email, forKey: "lastLoggedInEmail")
            print("💾 User saved to local storage: \(user.email)")
        }
    }
    
    private func fetchUserLocally(email: String) -> User? {
        let userKey = "user_\(email)"
        guard let savedData = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: savedData) else {
            return nil
        }
        print("💾 User fetched from local storage: \(email)")
        return user
    }
    
    private func fetchUserLocally(appleUserID: String) -> User? {
        // Search through all saved users for matching appleUserID
        let defaults = UserDefaults.standard
        for (key, value) in defaults.dictionaryRepresentation() {
            if key.hasPrefix("user_"), let data = value as? Data,
               let user = try? JSONDecoder().decode(User.self, from: data),
               user.appleUserID == appleUserID {
                print("💾 User fetched from local storage by appleUserID")
                return user
            }
        }
        return nil
    }
    
    // MARK: - CloudKit Operations
    
    private func saveUserToCloudKit(_ user: User) async throws {
        let record = CKRecord(recordType: "Users")
        record["appleUserID"] = user.appleUserID ?? ""
        record["email"] = user.email
        record["firstName"] = user.firstName
        record["lastName"] = user.lastName
        record["chapterID"] = user.chapterId?.uuidString ?? ""
        // Check isAdmin based on appleUserID (consistent regardless of email privacy settings)
        record["isAdmin"] = (user.appleUserID == "000832.309eac005e8947f49cc100a8d29cd7bb.1828") ? 1 : 0
        record["referralCode"] = user.referralCode ?? ""
        record["createdAt"] = user.dateJoined
        record["lastLoginAt"] = Date()
        
        _ = try await database.save(record)
    }
    
    private func fetchUserFromCloudKit(email: String) async throws -> User? {
        let predicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: "Users", predicate: predicate)
        
        let results = try await database.records(matching: query)
        guard let result = results.matchResults.first else {
            return nil
        }
        
        let record = try result.1.get()
        return parseUserRecord(record)
    }
    
    private func fetchUserFromCloudKit(appleUserID: String) async throws -> User? {
        let predicate = NSPredicate(format: "appleUserID == %@", appleUserID)
        let query = CKQuery(recordType: "Users", predicate: predicate)
        
        let results = try await database.records(matching: query)
        guard let result = results.matchResults.first else {
            return nil
        }
        
        let record = try result.1.get()
        return parseUserRecord(record)
    }
    
    private func parseUserRecord(_ record: CKRecord) -> User? {
        guard let email = record["email"] as? String else {
            return nil
        }
        
        let user = User(
            email: email,
            firstName: record["firstName"] as? String ?? "User",
            lastName: record["lastName"] as? String ?? "",
            state: "California",
            university: nil,
            appleUserID: record["appleUserID"] as? String
        )
        
        return user
    }
}
