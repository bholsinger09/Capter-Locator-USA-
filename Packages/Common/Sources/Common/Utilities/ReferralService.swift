//
//  ReferralService.swift
//  Common
//
//  Created on October 18, 2026.
//

import Foundation

public protocol ReferralServiceProtocol {
    func generateReferralCode(for userId: UUID) -> String
    func createPersonalReferralCode(for user: inout User) -> ReferralCode
    func createChapterReferralCode(for userId: UUID, chapterId: UUID) -> ReferralCode
    func recordReferral(referrerId: UUID, refereeId: UUID, refereeName: String, chapterId: UUID?) -> ReferralLink
    func getRecruitsForUser(userId: UUID) -> [ReferralLink]
    func validateReferralCode(_ code: String) -> UUID? // Returns referrer ID if valid
    func deactivateReferralCode(_ code: String)
}

public class ReferralService: ReferralServiceProtocol {
    private let referralCodesKey = "referralCodes"
    private let referralLinksKey = "referralLinks"
    
    public init() {}
    
    // MARK: - Code Generation
    
    public func generateReferralCode(for userId: UUID) -> String {
        // Generate a short, memorable code: USER_ID + timestamp hash
        // Format: XXXX-XXXX (8 chars)
        let timestamp = Int(Date().timeIntervalSince1970)
        let combined = userId.uuidString + String(timestamp)
        let hash = combined.hashValue
        let code = String(format: "%08X", abs(hash)).prefix(8)
        return String(code)
    }
    
    public func createPersonalReferralCode(for user: inout User) -> ReferralCode {
        let code = generateReferralCode(for: user.id)
        
        let referralCode = ReferralCode(
            referrerId: user.id,
            chapterId: nil, // Personal code has no specific chapter
            code: code
        )
        
        // Save code to UserDefaults
        saveReferralCode(referralCode)
        
        // Update user with their referral code
        user.referralCode = code
        
        return referralCode
    }
    
    public func createChapterReferralCode(for userId: UUID, chapterId: UUID) -> ReferralCode {
        let code = generateReferralCode(for: userId) + "-\(chapterId.uuidString.prefix(4))"
        
        let referralCode = ReferralCode(
            referrerId: userId,
            chapterId: chapterId,
            code: code
        )
        
        saveReferralCode(referralCode)
        return referralCode
    }
    
    // MARK: - Referral Recording
    
    public func recordReferral(
        referrerId: UUID,
        refereeId: UUID,
        refereeName: String,
        chapterId: UUID? = nil
    ) -> ReferralLink {
        let link = ReferralLink(
            referrerId: referrerId,
            refereeId: refereeId,
            refereeName: refereeName,
            chapterId: chapterId,
            status: .joined
        )
        
        saveReferralLink(link)
        return link
    }
    
    // MARK: - Retrieval
    
    public func getRecruitsForUser(userId: UUID) -> [ReferralLink] {
        guard let data = UserDefaults.standard.data(forKey: referralLinksKey),
              let links = try? JSONDecoder().decode([ReferralLink].self, from: data) else {
            return []
        }
        
        return links.filter { $0.referrerId == userId }
            .sorted { $0.joinDate > $1.joinDate } // Most recent first
    }
    
    // MARK: - Validation
    
    public func validateReferralCode(_ code: String) -> UUID? {
        guard let data = UserDefaults.standard.data(forKey: referralCodesKey),
              let codes = try? JSONDecoder().decode([ReferralCode].self, from: data) else {
            return nil
        }
        
        let validCode = codes.first { referralCode in
            referralCode.code == code &&
            referralCode.isActive &&
            !referralCode.isExpired()
        }
        
        return validCode?.referrerId
    }
    
    public func deactivateReferralCode(_ code: String) {
        guard var codes = getReferralCodes() else { return }
        
        if let index = codes.firstIndex(where: { $0.code == code }) {
            codes[index].isActive = false
            saveReferralCodes(codes)
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveReferralCode(_ code: ReferralCode) {
        var codes = getReferralCodes() ?? []
        codes.append(code)
        saveReferralCodes(codes)
    }
    
    private func getReferralCodes() -> [ReferralCode]? {
        guard let data = UserDefaults.standard.data(forKey: referralCodesKey) else {
            return nil
        }
        return try? JSONDecoder().decode([ReferralCode].self, from: data)
    }
    
    private func saveReferralCodes(_ codes: [ReferralCode]) {
        if let encoded = try? JSONEncoder().encode(codes) {
            UserDefaults.standard.set(encoded, forKey: referralCodesKey)
        }
    }
    
    private func saveReferralLink(_ link: ReferralLink) {
        var links = getReferralLinks() ?? []
        links.append(link)
        saveReferralLinks(links)
    }
    
    private func getReferralLinks() -> [ReferralLink]? {
        guard let data = UserDefaults.standard.data(forKey: referralLinksKey) else {
            return nil
        }
        return try? JSONDecoder().decode([ReferralLink].self, from: data)
    }
    
    private func saveReferralLinks(_ links: [ReferralLink]) {
        if let encoded = try? JSONEncoder().encode(links) {
            UserDefaults.standard.set(encoded, forKey: referralLinksKey)
        }
    }
}

// MARK: - Extensions

extension ReferralCode {
    func isExpired() -> Bool {
        // Codes don't expire, but you could add an expiration date field
        // For now, active codes are always valid
        return false
    }
}
