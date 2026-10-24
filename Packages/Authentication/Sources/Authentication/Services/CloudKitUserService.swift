//
//  CloudKitUserService.swift
//  Authentication
//
//  CloudKit service for persisting user data
//  Falls back to local UserDefaults when CloudKit is unavailable

import Foundation
import CloudKit
import Common

public class CloudKitUserService: NSObject, ObservableObject {
    public static let shared = CloudKitUserService()
    
    private let container: CKContainer
    private let database: CKDatabase
    private let recordType = "Users"
    private let lastUserEmailKey = "lastSignedInEmail"
    
    @Published public var isReady = false
    @Published public var errorMessage: String?
    
    override init() {
        self.container = CKContainer(identifier: "iCloud.com.holsinger.chapterfinder")
        self.database = container.privateCloudDatabase
        super.init()
        checkCloudKitAvailability()
    }
    
    private func checkCloudKitAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isReady = true
                    print("✅ CloudKit available for user persistence")
                case .noAccount:
                    self?.errorMessage = "iCloud account required"
                    print("❌ No iCloud account - falling back to local storage")
                    self?.isReady = false
                case .restricted:
                    self?.errorMessage = "CloudKit access restricted"
                    print("❌ CloudKit restricted - falling back to local storage")
                    self?.isReady = false
                case .couldNotDetermine:
                    self?.errorMessage = "Could not determine iCloud status"
                    print("❌ Could not determine iCloud status - falling back to local storage")
                    self?.isReady = false
                @unknown default:
                    self?.errorMessage = "Unknown iCloud status"
                    print("❌ Unknown iCloud status - falling back to local storage")
                    self?.isReady = false
                }
            }
        }
    }
    
    // MARK: - Save User
    public func saveUser(_ user: User) async throws {
        // Always save to local storage first
        saveUserLocally(user)
        
        // Try to save to CloudKit if available
        guard isReady else {
            print("⚠️ CloudKit not ready - user saved locally only")
            return
        }
        
        let record = CKRecord(recordType: recordType)
        record["email"] = user.email
        record["firstName"] = user.firstName
        record["lastName"] = user.lastName
        record["state"] = user.state
        record["university"] = user.university
        record["appleUserID"] = user.appleUserID
        record["dateJoined"] = user.dateJoined
        record["isMember"] = user.isMember as NSNumber
        
        do {
            _ = try await database.save(record)
            print("✅ User saved to CloudKit: \(user.email)")
        } catch {
            print("⚠️ CloudKit save failed (local storage kept): \(error)")
        }
    }
    
    // MARK: - Fetch User by Email
    public func fetchUser(email: String) async throws -> User? {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try CloudKit first if available
        if isReady {
            let predicate = NSPredicate(format: "email == %@", normalizedEmail)
            let query = CKQuery(recordType: recordType, predicate: predicate)
            
            do {
                let (recordDict, _) = try await database.records(matching: query)
                
                for (_, result) in recordDict {
                    if case .success(let record) = result {
                        return userFromRecord(record)
                    }
                }
            } catch {
                print("⚠️ CloudKit fetch by email failed: \(error)")
            }
        }
        
        // Fall back to local storage
        return fetchUserLocally(email: normalizedEmail)
    }
    
    // MARK: - Fetch User by Apple ID
    public func fetchUser(appleUserID: String) async throws -> User? {
        // Try CloudKit first if available
        if isReady {
            let predicate = NSPredicate(format: "appleUserID == %@", appleUserID)
            let query = CKQuery(recordType: recordType, predicate: predicate)
            
            do {
                let (recordDict, _) = try await database.records(matching: query)
                
                for (_, result) in recordDict {
                    if case .success(let record) = result {
                        return userFromRecord(record)
                    }
                }
            } catch {
                print("⚠️ CloudKit fetch by Apple ID failed: \(error)")
            }
        }
        
        // Fall back to local storage
        return fetchUserLocallyByAppleID(appleUserID)
    }
    
    // MARK: - Local Storage Helpers
    private func saveUserLocally(_ user: User) {
        let userKey = "user_\(user.email)"
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            UserDefaults.standard.set(user.email, forKey: lastUserEmailKey)
            print("💾 User saved to local storage: \(user.email)")
        }
    }
    
    private func fetchUserLocally(email: String) -> User? {
        let userKey = "user_\(email)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: savedData) {
            print("💾 User loaded from local storage: \(email)")
            return user
        }
        return nil
    }
    
    private func fetchUserLocallyByAppleID(_ appleUserID: String) -> User? {
        // Check if we have a stored email from previous sign-in
        if let lastEmail = UserDefaults.standard.string(forKey: lastUserEmailKey) {
            let userKey = "user_\(lastEmail)"
            if let savedData = UserDefaults.standard.data(forKey: userKey),
               let user = try? JSONDecoder().decode(User.self, from: savedData) {
                if user.appleUserID == appleUserID {
                    print("💾 User loaded from local storage by Apple ID: \(lastEmail)")
                    return user
                }
            }
        }
        return nil
    }
    
    // MARK: - Helper
    private func userFromRecord(_ record: CKRecord) -> User {
        let email = record["email"] as? String ?? ""
        let firstName = record["firstName"] as? String ?? ""
        let lastName = record["lastName"] as? String ?? ""
        let state = record["state"] as? String ?? ""
        let university = record["university"] as? String
        let appleUserID = record["appleUserID"] as? String
        let dateJoined = record["dateJoined"] as? Date ?? Date()
        let isMember = (record["isMember"] as? NSNumber)?.boolValue ?? false
        
        return User(
            email: email,
            firstName: firstName,
            lastName: lastName,
            state: state,
            university: university,
            dateJoined: dateJoined,
            isMember: isMember,
            appleUserID: appleUserID
        )
    }
}
