//
//  User.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

public struct User: Identifiable, Codable, Hashable {
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
    public var referredBy: UUID? // Who referred this user
    public var referralCode: String? // This user's personal referral code
    public var hideReferralStatus: Bool = false // Privacy option
    
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
        appleUserID: String? = nil,
        referredBy: UUID? = nil,
        referralCode: String? = nil,
        hideReferralStatus: Bool = false
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
        self.referredBy = referredBy
        self.referralCode = referralCode
        self.hideReferralStatus = hideReferralStatus
    }
}
