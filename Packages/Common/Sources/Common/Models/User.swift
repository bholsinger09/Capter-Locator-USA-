//
//  User.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

public struct User: Identifiable, Codable {
    public var id: UUID = UUID()
    public var email: String
    public var firstName: String
    public var lastName: String
    public var state: String
    public var university: String?
    public var chapterId: UUID?
    public var dateJoined: Date = Date()
    public var isMember: Bool = false
    public var appleUserID: String? // For Sign in with Apple
    
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    public init(
        id: UUID = UUID(),
        email: String,
        firstName: String,
        lastName: String,
        state: String,
        university: String? = nil,
        chapterId: UUID? = nil,
        dateJoined: Date = Date(),
        isMember: Bool = false,
        appleUserID: String? = nil
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.state = state
        self.university = university
        self.chapterId = chapterId
        self.dateJoined = dateJoined
        self.isMember = isMember
        self.appleUserID = appleUserID
    }
}
