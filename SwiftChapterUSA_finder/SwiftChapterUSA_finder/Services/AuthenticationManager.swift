//
//  AuthenticationManager.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation
import Combine

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
        
        let newUser = User(
            email: email,
            firstName: firstName,
            lastName: lastName,
            state: state,
            university: university
        )
        
        currentUser = newUser
        isAuthenticated = true
        saveUser()
    }
    
    func login(email: String, password: String) {
        // In a real app, this would authenticate with a backend
        // For now, we'll simulate login
        
        // Demo account for App Store Review
        if email.lowercased() == "demo@appstore.com" && password == "AppReview2025" {
            let demoUser = User(
                email: "demo@appstore.com",
                firstName: "App Store",
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
           savedUser.email == email {
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
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
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
}
