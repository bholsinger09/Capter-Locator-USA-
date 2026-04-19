//
//  User.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

struct User: Identifiable, Codable {
    var id: UUID = UUID()
    var email: String
    var firstName: String
    var lastName: String
    var state: String
    var university: String?
    var chapterId: UUID?
    var dateJoined: Date = Date()
    var isMember: Bool = false
    var appleUserID: String? // For Sign in with Apple
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
