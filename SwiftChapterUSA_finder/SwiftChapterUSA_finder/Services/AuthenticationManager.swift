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
    
    private let userDefaultsKey = "currentUser"
    
    init() {
        loadUser()
    }
    
    func register(email: String, password: String, firstName: String, lastName: String, state: String, university: String?) {
        // In a real app, this would connect to a backend API
        // For now, we'll simulate registration
        
        // Normalize email to lowercase
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if user already exists (case-insensitive)
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData),
           savedUser.email.lowercased() == normalizedEmail {
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
        
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData),
           savedUser.email.lowercased() == normalizedEmail {
            currentUser = savedUser
            isAuthenticated = true
            errorMessage = nil
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
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUser() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
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
        
        // Check if user already exists
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedData),
           savedUser.appleUserID == userID {
            // Existing Apple Sign In user
            currentUser = savedUser
            isAuthenticated = true
            errorMessage = nil
        } else {
            // New Apple Sign In user - create account with default state
            let newUser = User(
                email: email,
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
        
        // Remove user account data
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        // Clear all user-related preferences and cached data
        UserDefaults.standard.removeObject(forKey: "userPosts")
        UserDefaults.standard.removeObject(forKey: "userChapterMembership")
        UserDefaults.standard.removeObject(forKey: "userPreferences")
        
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
