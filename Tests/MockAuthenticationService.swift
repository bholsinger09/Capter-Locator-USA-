//
//  MockAuthenticationService.swift
//  SwiftChapterUSA Finder Tests
//
//  Created on November 15, 2025.
//

import Foundation
import AuthenticationServices
@testable import SwiftChapterUSA_finder

class MockAuthenticationService: AuthenticationServiceProtocol {
    var isAuthenticated = false
    var currentUser: User?
    var errorMessage: String?
    
    var registerCalled = false
    var loginCalled = false
    var logoutCalled = false
    var updateUserCalled = false
    var signInWithAppleCalled = false
    
    func register(email: String, password: String, firstName: String, lastName: String, state: String, university: String?) {
        registerCalled = true
        let user = User(email: email, firstName: firstName, lastName: lastName, state: state, university: university)
        currentUser = user
        isAuthenticated = true
    }
    
    func login(email: String, password: String) {
        loginCalled = true
        if email == "test@example.com" && password == "password" {
            currentUser = User(email: email, firstName: "Test", lastName: "User", state: "California")
            isAuthenticated = true
            errorMessage = nil
        } else {
            errorMessage = "Invalid credentials"
        }
    }
    
    func logout() {
        logoutCalled = true
        isAuthenticated = false
        currentUser = nil
    }
    
    func updateUser(_ user: User) {
        updateUserCalled = true
        currentUser = user
    }
    
    func signInWithApple(authorization: ASAuthorization) {
        signInWithAppleCalled = true
        // Mock Apple Sign In - create test user
        let user = User(
            email: "apple.user@privaterelay.appleid.com",
            firstName: "Apple",
            lastName: "User",
            state: "California",
            appleUserID: "test.apple.id"
        )
        currentUser = user
        isAuthenticated = true
        errorMessage = nil
    }
}
