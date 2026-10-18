//
//  ReferralLink.swift
//  Common
//
//  Created on October 18, 2026.
//

import Foundation

public enum ReferralStatus: String, Codable, CaseIterable {
    case joined = "joined"
    case active = "active"
    case inactive = "inactive"
    
    public var displayName: String {
        switch self {
        case .joined:
            return "Just Joined"
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        }
    }
}

public struct ReferralLink: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var referrerId: UUID
    public var refereeId: UUID
    public var refereeName: String // Cached for display
    public var chapterId: UUID?
    public var joinDate: Date
    public var status: ReferralStatus = .joined
    
    public init(
        id: UUID = UUID(),
        referrerId: UUID,
        refereeId: UUID,
        refereeName: String,
        chapterId: UUID? = nil,
        joinDate: Date = Date(),
        status: ReferralStatus = .joined
    ) {
        self.id = id
        self.referrerId = referrerId
        self.refereeId = refereeId
        self.refereeName = refereeName
        self.chapterId = chapterId
        self.joinDate = joinDate
        self.status = status
    }
}
