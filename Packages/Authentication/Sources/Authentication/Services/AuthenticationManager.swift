//
//  AuthenticationManager.swift
//  Authentication
//
//  Created on November 15, 2025.
//

import Foundation
import Combine
import AuthenticationServices
import Common

public class AuthenticationManager: ObservableObject, AuthenticationServiceProtocol {
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?
    @Published public var errorMessage: String?
    @Published public var isOnline = true
    
    private let lastLoggedInEmailKey = "lastLoggedInEmail"
    
    public init() {
        // Don't load user on init - let the app decide if they should auto-login
        // This prevents the test user from being auto-created
        restoreLastLoggedInUser()
    }
    
    private func restoreLastLoggedInUser() {
        // Only restore if user was previously logged in
        guard let lastEmail = UserDefaults.standard.string(forKey: lastLoggedInEmailKey) else {
            print("🔍 [DEBUG] No previously logged in user found")
            return
        }
        
        print("🔍 [DEBUG] Restoring previously logged in user: \(lastEmail)")
        let userKey = "user_\(lastEmail)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            currentUser = savedUser
            isAuthenticated = true
            print("   ✅ User restored from local storage: \(savedUser.email)")
        }
    }
    
    public func register(email: String, password: String, firstName: String, lastName: String, state: String, university: String?) {
        // Normalize email to lowercase
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if user already exists (case-insensitive)
        let userKey = "user_\(normalizedEmail)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let _ = try? JSONDecoder().decode(User.self, from: savedData) {
            errorMessage = "An account with this email already exists. Please sign in."
            return
        }
        
        // Check for pending referrer ID from deep link
        var referredBy: UUID?
        if let referrerIdString = UserDefaults.standard.string(forKey: "pendingReferrerId") {
            referredBy = UUID(uuidString: referrerIdString)
            UserDefaults.standard.removeObject(forKey: "pendingReferrerId")
        }
        
        var newUser = User(
            email: normalizedEmail,
            firstName: firstName,
            lastName: lastName,
            state: state,
            university: university,
            referredBy: referredBy
        )
        
        // Generate a personal referral code for the new user
        let referralService = ReferralService()
        _ = referralService.createPersonalReferralCode(for: &newUser)
        
        currentUser = newUser
        isAuthenticated = true
        errorMessage = nil
        
        // Save to local storage
        saveUser()
    }
    
    public func login(email: String, password: String) {
        // In a real app, this would authenticate with a backend
        // For now, we'll simulate login
        
        // Normalize email to lowercase
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Demo account for App Store review
        if normalizedEmail == "demo@appstore.com" && password == "AppReview2025" {
            let demoUser = User(
                email: "demo@appstore.com",
                firstName: "Demo",
                lastName: "Reviewer",
                state: "California",
                university: "Stanford University"
            )
            currentUser = demoUser
            isAuthenticated = true
            errorMessage = nil
            return
        }
        
        // Load user data for this email
        let userKey = "user_\(normalizedEmail)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            currentUser = savedUser
            isAuthenticated = true
            errorMessage = nil
            // Update last logged in user
            UserDefaults.standard.set(normalizedEmail, forKey: lastLoggedInEmailKey)
        } else {
            errorMessage = "Invalid credentials. Please register first."
        }
    }
    
    public func logout() {
        isAuthenticated = false
        currentUser = nil
        // Don't delete user data - they should be able to log back in
    }
    
    private func saveUser() {
        guard let user = currentUser else { return }
        
        // Save user data with email as key
        let userKey = "user_\(user.email)"
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            // Track last logged in user
            UserDefaults.standard.set(user.email, forKey: lastLoggedInEmailKey)
        }
    }
    
    public func updateUser(_ user: User) {
        currentUser = user
        saveUser()
    }
    
    public func signInWithApple(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Failed to get Apple ID credentials"
            return
        }
        
        let userID = appleIDCredential.user
        let email = appleIDCredential.email ?? "apple.user@privaterelay.appleid.com"
        let firstName = appleIDCredential.fullName?.givenName ?? "Apple"
        let lastName = appleIDCredential.fullName?.familyName ?? "User"
        
        print("🔐 [DEBUG] Apple Sign-In:")
        print("   userID: \(userID)")
        print("   email (raw): \(appleIDCredential.email ?? "nil - will use stored email")")
        print("   firstName: \(firstName)")
        print("   lastName: \(lastName)")
        print("   isOnline: \(Reachability.shared.isConnected)")
        
        // Normalize email to lowercase
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("   normalizedEmail: \(normalizedEmail)")
        
        // Check local storage for existing user by appleUserID
        if let existingUser = fetchUserLocally(appleUserID: userID) {
            print("   ✅ Found existing Apple user")
            currentUser = existingUser
            print("   📊 [DEBUG] currentUser set to existing: \(existingUser.email)")
            print("   📊 [DEBUG] About to set isAuthenticated = true")
            isAuthenticated = true
            print("   📊 [DEBUG] isAuthenticated is now: \(isAuthenticated)")
            errorMessage = nil
            print("   ✅ currentUser updated to \(existingUser.email)")
            return
        }
        
        // Check local storage for existing user by email
        if let existingUser = fetchUserLocally(email: normalizedEmail) {
            print("   ✅ Found existing user by email")
            var updatedUser = existingUser
            updatedUser.appleUserID = userID
            currentUser = updatedUser
            print("   📊 [DEBUG] currentUser set to updated: \(updatedUser.email)")
            print("   📊 [DEBUG] About to set isAuthenticated = true")
            isAuthenticated = true
            print("   📊 [DEBUG] isAuthenticated is now: \(isAuthenticated)")
            errorMessage = nil
            print("   ✅ currentUser updated with appleUserID")
            saveUser()
            return
        }
        
        // Create new Apple Sign-In user
        print("   ✅ Creating new Apple user")
        let newUser = User(
            email: normalizedEmail,
            firstName: firstName,
            lastName: lastName,
            state: "California",
            university: nil,
            appleUserID: userID
        )
        
        currentUser = newUser
        print("   📊 [DEBUG] currentUser set to new: \(newUser.email)")
        print("   📊 [DEBUG] About to set isAuthenticated = true")
        isAuthenticated = true
        print("   📊 [DEBUG] isAuthenticated is now: \(isAuthenticated)")
        errorMessage = nil
        print("   ✅ currentUser set to new user: \(newUser.email)")
        saveUser()
    }
    
    private func fetchUserLocally(appleUserID: String) -> User? {
        let defaults = UserDefaults.standard
        for (key, value) in defaults.dictionaryRepresentation() {
            if key.hasPrefix("user_"), let data = value as? Data,
               let user = try? JSONDecoder().decode(User.self, from: data),
               user.appleUserID == appleUserID {
                print("   💾 User fetched from local storage by appleUserID")
                return user
            }
        }
        return nil
    }
    
    private func fetchUserLocally(email: String) -> User? {
        let userKey = "user_\(email)"
        guard let savedData = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: savedData) else {
            return nil
        }
        print("   💾 User fetched from local storage: \(email)")
        return user
    }
    
    public func deleteAccount() {
        // PERMANENT ACCOUNT DELETION
        // This permanently deletes all user data from the device.
        // There is no recovery or restoration possible after this action.
        
        guard let user = currentUser else { return }
        
        // Remove this specific user's account data
        let userKey = "user_\(user.email)"
        UserDefaults.standard.removeObject(forKey: userKey)
        
        // Clear last logged in if this was the last user
        if UserDefaults.standard.string(forKey: lastLoggedInEmailKey) == user.email {
            UserDefaults.standard.removeObject(forKey: lastLoggedInEmailKey)
        }
        
        // Clear all user-related preferences and cached data for this account
        UserDefaults.standard.removeObject(forKey: "userPosts_\(user.email)")
        UserDefaults.standard.removeObject(forKey: "userChapterMembership_\(user.email)")
        UserDefaults.standard.removeObject(forKey: "userPreferences_\(user.email)")
        
        // Clear app state
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
        
        // Note: In a production app with backend services, this would also:
        // - Make an API call to delete all server-side user data
        // - Remove user from all chapters and groups
        // - Delete user-generated content (posts, comments, etc.)
        // - Permanently remove the account from the system
    }
}
