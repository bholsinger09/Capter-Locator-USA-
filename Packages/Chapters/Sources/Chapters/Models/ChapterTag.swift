//
//  ChapterTag.swift
//  Chapters
//
//  Created on October 23, 2026.
//

import Foundation

public enum ChapterTag: String, CaseIterable {
    case new = "new"
    case popular = "popular"
    
    public var displayName: String {
        switch self {
        case .new:
            return "🆕 New"
        case .popular:
            return "🔥 Popular"
        }
    }
    
    public var shortName: String {
        switch self {
        case .new:
            return "New"
        case .popular:
            return "Popular"
        }
    }
    
    public var color: String {
        switch self {
        case .new:
            return "green"
        case .popular:
            return "orange"
        }
    }
}

extension Chapter {
    /// Determines which tags this chapter should display
    public func getTags() -> [ChapterTag] {
        var tags: [ChapterTag] = []
        
        // Tag as "New" if established within the last 60 days
        let twoMonthsAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date())!
        if dateEstablished >= twoMonthsAgo {
            tags.append(.new)
        }
        
        // Tag as "Popular" if member count is high (e.g., > 25 members)
        if memberCount > 25 {
            tags.append(.popular)
        }
        
        return tags
    }
    
    /// Check if chapter has a specific tag
    public func hasTag(_ tag: ChapterTag) -> Bool {
        return getTags().contains(tag)
    }
}
