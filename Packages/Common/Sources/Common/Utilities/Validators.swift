//
//  Validators.swift
//  Common
//
//  Input validation utilities
//

import Foundation

public struct Validators {
    /// Validates email format
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates password strength (at least 8 characters)
    public static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    /// Validates that passwords match
    public static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword && !password.isEmpty
    }
    
    /// Validates required field is not empty
    public static func isNotEmpty(_ text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// Validates URL format
    public static func isValidURL(_ urlString: String) -> Bool {
        // Basic URL validation - checks if URL can be constructed
        if let url = URL(string: urlString), 
           url.scheme != nil && url.host != nil {
            return true
        }
        return false
    }
}
