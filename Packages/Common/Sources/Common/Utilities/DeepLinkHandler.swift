//
//  DeepLinkHandler.swift
//  Common
//
//  Created on October 18, 2026.
//

import Foundation

public struct ReferralDeepLink {
    public let referrerId: UUID?
    public let chapterId: UUID?
    
    public var isValid: Bool {
        referrerId != nil
    }
}

public class DeepLinkHandler {
    public static func parseReferralLink(_ url: URL) -> ReferralDeepLink? {
        guard url.scheme == "tpusa-finder" else { return nil }
        guard url.host == "join" else { return nil }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var referrerId: UUID?
        var chapterId: UUID?
        
        if let queryItems = components?.queryItems {
            for item in queryItems {
                if item.name == "referrer", let value = item.value {
                    referrerId = UUID(uuidString: value)
                } else if item.name == "chapter", let value = item.value {
                    chapterId = UUID(uuidString: value)
                }
            }
        }
        
        return ReferralDeepLink(referrerId: referrerId, chapterId: chapterId)
    }
    
    public static func isReferralLink(_ url: URL) -> Bool {
        guard url.scheme == "tpusa-finder" else { return false }
        guard url.host == "join" else { return false }
        return true
    }
}
