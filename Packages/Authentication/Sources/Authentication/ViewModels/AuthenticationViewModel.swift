//
//  AuthenticationViewModel.swift
//  Authentication
//
//  Created on November 15, 2025.
//

import Foundation
import Combine
import Common

public class AuthenticationViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var selectedState = "Alabama"
    @Published public var university = ""
    @Published public var errorMessage: String?
    @Published public var isLoginMode = true
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    public var currentUser: User? {
        authService.currentUser
    }
    
    public init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Validation
    
    public var isLoginFormValid: Bool {
        !email.isEmpty && email.contains("@") && !password.isEmpty
    }
    
    public var isRegistrationFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    // MARK: - Actions
    
    public func login() {
        guard isLoginFormValid else {
            errorMessage = "Please enter valid email and password"
            return
        }
        
        authService.login(email: email, password: password)
        errorMessage = authService.errorMessage
    }
    
    public func register() {
        guard isRegistrationFormValid else {
            if firstName.isEmpty || lastName.isEmpty {
                errorMessage = "Please enter your name"
            } else if !email.contains("@") {
                errorMessage = "Please enter a valid email"
            } else if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
            } else if password != confirmPassword {
                errorMessage = "Passwords do not match"
            }
            return
        }
        
        authService.register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            state: selectedState,
            university: university.isEmpty ? nil : university
        )
    }
    
    public func logout() {
        authService.logout()
    }
    
    public func toggleMode() {
        isLoginMode.toggle()
        errorMessage = nil
        password = ""
        confirmPassword = ""
    }
    
    public func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        university = ""
        errorMessage = nil
    }
}
