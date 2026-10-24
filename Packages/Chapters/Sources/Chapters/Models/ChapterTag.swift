//
//  ChapterTag.swift
//  Chapters
//
//  Created on October 23, 2026.
//

import Foundation

public enum ChapterTag: String, CaseIterable, Codable {
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
    /// Get tags that have been manually added to this chapter
    public func getTags() -> [ChapterTag] {
        return tags.compactMap { ChapterTag(rawValue: $0) }
    }
    
    /// Check if chapter has a specific tag
    public func hasTag(_ tag: ChapterTag) -> Bool {
        return tags.contains(tag.rawValue)
    }
    
    /// Add a tag to this chapter
    public mutating func addTag(_ tag: ChapterTag) {
        if !tags.contains(tag.rawValue) {
            tags.append(tag.rawValue)
        }
    }
    
    /// Remove a tag from this chapter
    public mutating func removeTag(_ tag: ChapterTag) {
        tags.removeAll { $0 == tag.rawValue }
    }
}
