//
//  ReferralCode.swift
//  Common
//
//  Created on October 18, 2026.
//

import Foundation

public struct ReferralCode: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var referrerId: UUID
    public var chapterId: UUID?
    public var code: String
    public var createdDate: Date = Date()
    public var isActive: Bool = true
    
    public init(
        id: UUID = UUID(),
        referrerId: UUID,
        chapterId: UUID? = nil,
        code: String,
        createdDate: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.referrerId = referrerId
        self.chapterId = chapterId
        self.code = code
        self.createdDate = createdDate
        self.isActive = isActive
    }
}
