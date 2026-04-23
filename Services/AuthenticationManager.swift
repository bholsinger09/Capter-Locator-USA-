//
//  AuthenticationManager.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation
import Combine
import AuthenticationServices

class AuthenticationManager: ObservableObject, AuthenticationServiceProtocol {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let lastLoggedInEmailKey = "lastLoggedInEmail"
    
    init() {
        loadUser()
    }
    
    func register(email: String, password: String, firstName: String, lastName: String, state: String, university: String?) {
        // In a real app, this would connect to a backend API
        // For now, we'll simulate registration
        
        // Normalize email to lowercase
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if user already exists (case-insensitive)
        let userKey = "user_\(normalizedEmail)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let _ = try? JSONDecoder().decode(User.self, from: savedData) {
            errorMessage = "An account with this email already exists. Please sign in."
            return
        }
        
        let newUser = User(
            email: normalizedEmail,
            firstName: firstName,
            lastName: lastName,
            state: state,
            university: university
        )
        
        currentUser = newUser
        isAuthenticated = true
        errorMessage = nil
        saveUser()
    }
    
    func login(email: String, password: String) {
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
    
    func logout() {
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
    
    private func loadUser() {
        // Load the last logged in user
        guard let lastEmail = UserDefaults.standard.string(forKey: lastLoggedInEmailKey) else {
            return
        }
        
        let userKey = "user_\(lastEmail)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            currentUser = savedUser
            isAuthenticated = true
        }
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        saveUser()
    }
    
    func signInWithApple(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Failed to get Apple ID credentials"
            return
        }
        
        let userID = appleIDCredential.user
        let email = appleIDCredential.email ?? "apple.user@privaterelay.appleid.com"
        let firstName = appleIDCredential.fullName?.givenName ?? "Apple"
        let lastName = appleIDCredential.fullName?.familyName ?? "User"
        
        // Normalize email to lowercase
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if user already exists with this Apple ID
        let userKey = "user_\(normalizedEmail)"
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData),
           savedUser.appleUserID == userID {
            // Existing Apple Sign In user
            currentUser = savedUser
            isAuthenticated = true
            errorMessage = nil
        } else {
            // New Apple Sign In user - create account with default state
            let newUser = User(
                email: normalizedEmail,
                firstName: firstName,
                lastName: lastName,
                state: "California", // Default state, user can update in profile
                university: nil,
                appleUserID: userID
            )
            currentUser = newUser
            isAuthenticated = true
            saveUser()
            errorMessage = nil
        }
    }
    
    func deleteAccount() {
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
